library(data.table)
if(Sys.info()[7] == "rockc_000"){
    files = dir("~/GitHub/sws_r_api/r_modules/food_imputation/R/", full.names = TRUE)
} else if(Sys.info()[7] == "josh"){
    files = dir("~/Documents/Github/sws_r_api/r_modules/food_imputation/R", full.names = TRUE)
} else {
    stop("Need path for this user!")
}
sapply(files, source)

GetTestEnvironment(
#     baseUrl = "https://hqlprswsas1.hq.un.fao.org:8181/sws",
#     token = "e77abee7-9b0d-4557-8c6f-8968872ba7ca"
    baseUrl = "https://hqlqasws1.hq.un.fao.org:8181/sws",
    token = "7fe7cbec-2346-46de-9a3a-8437eca18e2a" #Michael's token
)

wheatKeys = c("0111", "23110", "23140.01", "23140.02", "23140.03", "23220.01",
              "23220.02", "23490.02", "23710", "39120.01", "F0020", "F0022")
cattleKeys = c("21111.01", "21111.02", "21182", "21184.01", "21185",
               "21512.01", "23991.04", "F0875")
palmOilKeys = c("01491.02", "2165", "21691.14", "21910.06", "21700.01",
                "21700.02", "F1243", "34550", "F1275", "34120")
areaCodesFS <- GetCodeList("faostat_one", "FS1_SUA_UPD", "geographicAreaFS")
areaCodesFS <- areaCodesFS[type == "country" &
    is.na(startDate) | as.Date(startDate) < as.Date("2011-01-01") &
    is.na(endDate) | as.Date(endDate) > as.Date("2011-01-01"), code]
areaCodesFS <- intersect(areaCodesFS, GetCodeList("population", "population",
                                                  "geographicAreaM49")[, code])
areaCodesM49 <- faoswsUtil::fs2m49(areaCodesFS)
areaCodesM49 <- areaCodesM49[!is.na(areaCodesM49)]
areaCodesFS <- faoswsUtil::m492fs(areaCodesM49)

## Define the keys that we'll need for all the dimensions
## We need different area codes for the SUA domain
yearsForSD <- 15
## We will need the year of imputation as well as previous years to compute the
## standard deviation.  We'll grab as many years as specified by the user.
yearCodes <- 2011 + (-yearsForSD:0)
yearCodes <- as.character(yearCodes)
## GDP per capita (constant 2500 US$) is under this key
gdpCodes <- "NY.GDP.PCAP.KD"
## The element 21 contains the FBS population numbers
populationCodes <- "21"
## The element 141 contains the FBS food numbers
foodCodes <- "141"
suaCodes <- faoswsUtil::cpc2fcl(c(wheatKeys, cattleKeys, palmOilKeys))
comCodes <- GetCodeList("food", "food_factors","foodCommodityM")$code
fdmCodes <- GetCodeList("food", "food_factors","foodFdm")$code
funCodes <- GetCodeList("food", "food_factors","foodFunction")$code
varCodes <- "y_e" ## Only need elasticities from the food domain table

## Define the dimensions
dimM49 <- Dimension(name = "geographicAreaM49", keys = areaCodesM49)
dimFS <- Dimension(name = "geographicAreaFS", keys = areaCodesFS)
dimPop <- Dimension(name = "measuredElementPopulation", keys = populationCodes)
dimTime <- Dimension(name = "timePointYears", keys = yearCodes)
dimGDP <- Dimension(name = "wbIndicator", keys = gdpCodes)
dimFood <- Dimension(name = "measuredElementFS", keys = foodCodes)
dimSua <- Dimension(name = "measuredItemFS", keys = suaCodes)
dimCom <- Dimension(name = "foodCommodityM", keys = comCodes)
dimFdm <- Dimension(name = "foodFdm", keys = fdmCodes)
dimFun <- Dimension(name = "foodFunction", keys = funCodes)
dimVar <- Dimension(name = "foodVariable", keys = varCodes)

## Define the pivots.  We won't need this for all dimensions, so we'll only
## define the relevant ones.
pivotM49 <- Pivoting(code = "geographicAreaM49")
pivotPop <- Pivoting(code = "measuredElementPopulation")
pivotTime <- Pivoting(code = "timePointYears")
pivotGDP <- Pivoting(code = "wbIndicator")

## Define the keys
keyPop <- DatasetKey(domain = "population", dataset = "population",
                     dimensions = list(dimM49, dimPop, dimTime))
keyGDP <- DatasetKey(domain = "WorldBank", dataset = "wb_ecogrw",
                     dimensions = list(dimM49, dimGDP, dimTime))
dimSua@keys = as.character(as.numeric(dimSua@keys))
keyFood <- DatasetKey(domain = "faostat_one", dataset = "FS1_SUA_UPD",
                      dimensions = list(dimFS, dimFood, dimSua, dimTime))
keyFdm <- DatasetKey(domain = "food", dataset = "food_factors",
                     dimensions = list(dimM49, dimCom, dimFdm, dimFun, dimVar))

## Download all the datasets:

## download the population data from the SWS.  Using the pivoting argument, we 
## can specify the column order.  Since we're only pulling one key for the 
## population dimension, it makes sense to use that as the last dimension with 
## normalized = FALSE.  Doing this makes the last column the population, and
## names it Value_measuredElementPopulation_21.  We'll just rename it to
## population.
popData <- GetData(keyPop, flags=FALSE, normalized = FALSE,
                   pivoting = c(pivotM49, pivotTime, pivotPop))
setnames(popData, "Value_measuredElementPopulation_21", "population")
## download the gdp data from the SWS.  We're again only pulling one wbIndicator
## dimension, so we'll do the same thing we did for population.
gdpData <- GetData(keyGDP, flags=FALSE, normalized = FALSE,
                   pivoting = c(pivotM49, pivotTime, pivotGDP))
setnames(gdpData, "Value_wbIndicator_NY.GDP.PCAP.KD", "GDP")
## download the food data from the SWS
foodData <- GetData(keyFood, flags = FALSE, normalized = TRUE)
setnames(foodData, "Value", "food")
## download the food dimension data (elasticities) from the SWS
fdmData <- GetData(keyFdm, flags=FALSE, normalized = FALSE)
setnames(fdmData, "Value_foodVariable_y_e", "elasticity")

## Merge the datasets together, and perform some processing.

## merge the current population and gross domestic product data into a single
## dataset
GdpPopData <- merge(popData, gdpData, all = TRUE,
                    by = c("geographicAreaM49", "timePointYears"))

# foodData$com_cod <-  rep(NA,length(foodData$com_sua_cod))
# foodData$fdm_cod <- rep(NA,length(foodData$com_sua_cod))

funcCodes <- lapply(foodData$measuredItemFS, sua_2_fbs_fdm)
foodData <- cbind(foodData, do.call("rbind", funcCodes))
foodData[, foodFdm := as.character(foodFdm)]
foodData[, foodCommodityM := as.character(foodCommodityM)]
foodData <- foodData[!is.na(foodFdm), ]
foodData[, geographicAreaM49 := faoswsUtil::fs2m49(as.character(geographicAreaFS))]
## Mapping creates some NA M49 codes.  Remove those rows, as they don't exist in
## the FBS domain.
foodData <- foodData[!is.na(geographicAreaM49), ]
foodData[, geographicAreaFS := NULL]

GdpPopFoodDataM49 = merge(foodData, GdpPopData, all.x = TRUE,
                          by = c("geographicAreaM49", "timePointYears"))

data_base <- merge(GdpPopFoodDataM49, fdmData,
                   by = c("foodCommodityM","foodFdm", "geographicAreaM49"), 
                   all.x = TRUE)

## HACK: Remove rows with missing func_form.  This may not be the right thing to
## do: we may need to update the elasticities table.
data_base <- data_base[!is.na(foodFunction), ]

## First, sort the data by area and time.  The time sorting is important as we
## will later assume row i+1 is one time step past row i.
setkeyv(data_base, c("geographicAreaM49", "timePointYears"))

## The funcional form 4 (originally presented in Josef's data) was replaced by
## functional form 3 The functional form 32 is a typo. It was replaced by
## functional form 3.
data_base$foodFunction<-ifelse(data_base$foodFunction==4 | data_base$foodFunction==32,3,data_base$foodFunction)
data_base[, foodHat := calculateFood(food = .SD$food, elas = .SD$elasticity,
                                     gdp_pc = .SD$GDP/.SD$population,
                                     ## We can use the first value since they're all the same:
                                     functionalForm = .SD$foodFunction[1]),
          by = c("measuredItemFS", "geographicAreaM49")]  

# ## calculate calories  
# data$hat_cal_pc_2013 <- ifelse(data$hat_food_pc_2012 > 0, data$hat_cal_pc_2012*
#                                       data$hat_food_pc_2013/data$hat_food_pc_2012,0)
# 
# ## calculate proteins 
# data$hat_prot_pc_2013 <- ifelse(data$hat_food_pc_2012 > 0, data$hat_prot_pc_2012*
#                                        data$hat_food_pc_2013/data$hat_food_pc_2012,0)
#   
# ## calculate fats 
# data$hat_fat_pc_2013 <- ifelse(data$hat_food_pc_2012 > 0, data$hat_fat_pc_2012*
#                                       data$hat_food_pc_2013/data$hat_food_pc_2012,0)                  


# In statistics, a forecast error is the difference between the actual or real
# and the predicted or forecast value of a time series or any other phenomenon
# of interest.
# In simple cases, a forecast is compared with an outcome at a single
# time-point and a summary of forecast errors is constructed over a collection
# of such time-points. Here the forecast may be assessed using the difference
# or using a proportional error.
# By convention, the error is defined using the value of the outcome minus the
# value of the forecast.
data_base[, error := food - foodHat]

# Geographic Area, measuredElement = 141, measuredItem = SUA item code, Dist
# Param = log(Mu) or log(Sigma), Year = Year
foodEstimates <- data_base[,
    ## Since we're ordered by time, foodHat[.N] will give the last estimate for
    ## the food element, and this is exactly what we want.
    list(mean = foodHat[.N],
         var = mean(error^2, na.rm = TRUE),
         timePointYears = max(timePointYears)),
    by = c("geographicAreaM49", "measuredElementFS", "measuredItemFS")]
foodEstimates[, measuredItemCPC := faoswsUtil::fcl2cpc(
    formatC(as.numeric(measuredItemFS), width = 4, flag = "0"))]

if(Sys.info()[7] == "rockc_000"){
    save(foodEstimates, file = "~/GitHub/Working/OrangeBook/foodEstimates.RData")
} else if(Sys.info()[7] == "josh"){
    save(foodEstimates, file = "~/Documents/Github/Working/OrangeBook/foodEstimates.RData")
} else {
    stop("Need path for this user!")
}