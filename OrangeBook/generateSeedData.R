library(data.table)
if(Sys.info()[7] == "rockc_000"){
    files = dir("~/GitHub/faoswsSeed/R/", full.names = TRUE)
} else if(Sys.info()[7] == "josh"){
    files = dir("~/Documents/Github/faoswsSeed/R/", full.names = TRUE)
} else {
    stop("Need path for this user!")
}
sapply(files, source)

wheatKeys = c("0111", "23110", "23140.01", "23140.02", "23140.03", "23220.01",
              "23220.02", "23490.02", "23710", "39120.01", "F0020", "F0022")
cattleKeys = c("21111.01", "21111.02", "21182", "21184.01", "21185",
               "21512.01", "23991.04", "F0875")
palmOilKeys = c("01491.02", "2165", "21691.14", "2", "21700.01",
                "21700.02", "F1243", "34550", "F1275", "34120")
areaCodesM49 <- "840"

library(data.table)
library(faosws)
library(faoswsFlag)
library(faoswsUtil)
library(magrittr)
library(igraph)
library(lme4)

## Setting up variables
buildModel = TRUE
areaVar = "geographicAreaM49"
yearVar = "timePointYears"
itemVar = "measuredItemCPC"
elementVar = "measuredElement"
areaSownElementCode = "5025"
areaHarvestedElementCode = "5312"
seedElementCode = "5525"
valuePrefix = "Value_measuredElement_"
flagObsPrefix = "flagObservationStatus_measuredElement_"
flagMethodPrefix = "flagMethod_measuredElement_"


## Get SWS Parameters
GetTestEnvironment(
#     baseUrl = "https://hqlprswsas1.hq.un.fao.org:8181/sws",
#     token = "d0e1f76f-61a6-4183-981c-d0fec7ac1845"
    baseUrl = "https://hqlqasws1.hq.un.fao.org:8181/sws",
    token = "7fe7cbec-2346-46de-9a3a-8437eca18e2a"
)

## Get area and climate data from the SWS
area =
    getAllAreaData() %>%
    imputeAreaSown(data = .)
climate = getWorldBankClimateData()

if(buildModel){
    ## Get seed data from the SWS
    seed =
        getOfficialSeedData() %>%
        removeCarryForward(data = ., variable = "Value_measuredElement_5525") %>%
        buildCPCHierarchy(data = ., cpcItemVar = itemVar, levels = 3)

    ## Merge together the three different datasets and construct a mixed effects
    ## model
    seedModelData =
        mergeAllSeedData(seedData = seed, area, climate) %>%
        .[Value_measuredElement_5525 > 1 & Value_measuredElement_5025 > 1, ]
    seedLmeModel = 
        lmer(log(Value_measuredElement_5525) ~ Value_wbIndicator_SWS.FAO.TEMP +
                 timePointYears + 
             (log(Value_measuredElement_5025)|cpcLvl3/measuredItemCPC:geographicAreaM49),
             data = seedModelData)
    if(Sys.info()[7] == "rockc_000"){
        save(seedLmeModel,
             file = "//hqlprsws1.hq.un.fao.org/sws_r_share/browningj/seed/seedModel.RData")
    } else if(Sys.info()[7] == "josh"){
        save(seedLmeModel,
             file = "/media/hqlprsws1_qa/browningj/seed/seedModel.RData")
    } else {
        stop("Need path for this user!")
    }
} else {
    if(Sys.info()[7] == "rockc_000"){
        load(file = "//hqlprsws1.hq.un.fao.org/sws_r_share/browningj/seed/seedModel.RData")
    } else if(Sys.info()[7] == "josh"){
        load(file = "/media/hqlprsws1_qa/browningj/seed/seedModel.RData")
    } else {
        stop("Need path for this user!")
    }
}

# seedLmeVariance = bootMer(seedLmeModel, )

swsContext.datasets = list()
swsContext.datasets[[1]] = DatasetKey(
    domain = "agriculture",
    dataset = "agriculture",
    dimensions =
        list(Dimension(name = areaVar, keys = "840"),
             Dimension(name = yearVar, keys = as.character(2011)),
             Dimension(name = elementVar, keys = c("5025", "5525")),
             Dimension(name = itemVar, keys = c(wheatKeys, cattleKeys, palmOilKeys))
    ))

selectedSeed =
    getSelectedSeedData(swsContext.datasets[[1]]) %>%
    removeCarryForward(data = ., variable = "Value_measuredElement_5525") %>%
    buildCPCHierarchy(data = ., cpcItemVar = itemVar, levels = 3) %>%
    mergeAllSeedData(seedData = ., area, climate) %>%
    .[Value_measuredElement_5525 > 1 & Value_measuredElement_5025 > 1, ]

selectedSeed[, predicted :=
              exp(predict(seedLmeModel, selectedSeed, allow.new.levels = TRUE))]
# Getting strange error: "Error: sum(nb) == q is not TRUE".  Temporary hack for
# work computer
# 
# selectedSeed[1, predicted := 1929614]
seedEstimates = selectedSeed
seedEstimates[, timePointYears := as.character(timePointYears)]

if(Sys.info()[7] == "rockc_000"){
    save(seedEstimates, file = "~/GitHub/Working/OrangeBook/seedEstimates.RData")
} else if(Sys.info()[7] == "josh"){
    save(seedEstimates, file = "~/Documents/Github/Working/OrangeBook/seedEstimates.RData")
} else {
    stop("Need path for this user!")
}