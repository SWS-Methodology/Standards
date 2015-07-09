library(faosws)
library(data.table)
library(ggplot2)
library(data.table)
if(Sys.info()[7] == "rockc_000"){
    files = dir("~/GitHub/faoswsStock/R/", full.names = TRUE)
} else if(Sys.info()[7] == "josh"){
    files = dir("~/Documents/Github/faoswsStock/R/", full.names = TRUE)
} else {
    stop("Need path for this user!")
}
sapply(files, source)

## Get SWS Parameters
GetTestEnvironment(
    baseUrl = "https://hqlprswsas1.hq.un.fao.org:8181/sws",
    token = "d0e1f76f-61a6-4183-981c-d0fec7ac1845"
#     baseUrl = "https://hqlqasws1.hq.un.fao.org:8181/sws",
#     token = "7fe7cbec-2346-46de-9a3a-8437eca18e2a"
)

wheatKeys = c("0111", "23110", "23140.01", "23140.02", "23140.03", "23220.01",
              "23220.02", "23490.02", "23710", "39120.01", "F0020", "F0022")
cattleKeys = c("21111.01", "21111.02", "21182", "21184.01", "21185",
               "21512.01", "23991.04", "F0875")
palmOilKeys = c("01491.02", "2165", "21691.14", "21910.06", "21700.01",
                "21700.02", "F1243", "34550", "F1275", "34120")
areaCodesM49 <- "840"

if(Sys.info()[7] == "josh"){
    R_SWS_SHARE_PATH = "~/Documents/Github/faoswsStock/savedModels/"
}
if(Sys.info()[7] == "rockc_000"){ #Josh's laptop
    R_SWS_SHARE_PATH = "~/Github/faoswsStock/savedModels/"
}

data = getStockData()
model = buildStockModel(data = data)

## Code from predictModelAg.R
timeRange = 1990:2010 # Change documentation if this changes!
estimateYear = 2011 # Change documentation if this changes!

m49Area = "840"
fsArea  = faoswsUtil::m492fs(m49Area)
fsArea  = fsArea[!is.na(fsArea)]
areaDim = Dimension(name = "geographicAreaFS", keys = fsArea)
cpcItem = c(wheatKeys, cattleKeys, palmOilKeys)
fclItem = as.character(as.numeric(faoswsUtil::cpc2fcl(cpcItem, returnFirst = TRUE)))
fclItem = fclItem[!is.na(fclItem)]
itemDim = Dimension(name = "measuredItemFS", keys = fclItem)
yearDim = Dimension(name = "timePointYears",
                    keys = as.character(c(timeRange)))
elemDim = Dimension(name = "measuredElementFS", keys = "71")
key = DatasetKey(domain = "faostat_one", dataset = "FS1_SUA",
                 dimensions = list(areaDim, itemDim, yearDim, elemDim))
oldSuaData = GetData(key)

## Add in the estimateYear so that you have a place to write to
toBind = copy(oldSuaData)
toBind[, c("timePointYears", "Value", "flagFaostat") :=
           list(as.character(estimateYear), NA_real_, "M")]
oldSuaData = rbind(oldSuaData, unique(toBind))

## Load Stock Model
availableModels = list.files(R_SWS_SHARE_PATH, full.names = TRUE)
choosenModel = chooseStockModel(availableModels)
## This loads an object called "model"
load(choosenModel)

## Predict with the stock model
model$groupingColumns[1] = "geographicAreaFS"
model$groupingColumns[2] = "measuredItemFS"
model$yearColumn = "timePointYears"
model$valueColumn = "Value"
preds = predictStockModel(model, newdata = oldSuaData)

## Reshape data to write back to SWS:
preds = preds[timePointYears == estimateYear, ]
preds[, Value := expectedValue]
preds[, geographicAreaM49 := faoswsUtil::fs2m49(geographicAreaFS)]
preds[, measuredItemCPC := faoswsUtil::fcl2cpc(formatC(as.numeric(measuredItemFS),
                                           width = 4, format = "g", flag = "0"))]
preds[, measuredElement := measuredElementFS]
preds = preds[, list(geographicAreaM49, measuredItemCPC, measuredElement,
                     timePointYears, Value)]
preds[, flagObservationStatus := "I"]
preds[, flagMethod := "e"]
preds = preds[!is.na(Value), ]
stockEstimates = preds

if(Sys.info()[7] == "rockc_000"){
    save(stockEstimates, file = "~/GitHub/Working/OrangeBook/stockEstimates.RData")
} else if(Sys.info()[7] == "josh"){
    save(stockEstimates, file = "~/Documents/Github/Working/OrangeBook/stockEstimates.RData")
} else {
    stop("Need path for this user!")
}
