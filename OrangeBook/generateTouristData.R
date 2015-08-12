## Load required functions
library(faosws)
library(dplyr)
library(reshape2)
library(data.table)
library(faoswsUtil)

workingDir = "~/GitHub/privateFAO/OrangeBook/"
if(Sys.info()[7] == "Golini"){ # Natalia
    GetTestEnvironment(
        baseUrl = "https://hqlprswsas1.hq.un.fao.org:8181/sws",
        #token = "6f322cc0-d4f7-4efc-9dfe-0452aafd2994" NATA: Expired section
        token = "030e170a-3a35-4c77-acda-be89feb1c6e2" # Nata's token
    )
} else if(Sys.info()[7] == "josh"){ # Josh work
    GetTestEnvironment(
        baseUrl = "https://hqlprswsas1.hq.un.fao.org:8181/sws",
        token = "5c9850df-d271-4de2-9db4-de7bc353edde" # Josh's token
    )
    workingDir = "~/Documents/Github/privateFAO/OrangeBook/"
} else {
    stop("No user defined yet!")
}

load(paste0(workingDir, "foodEstimates.RData"))

## set the keys to get the tourist data from the FAO working system
destinationAreaCodes <- faosws::GetCodeList("tourism", "tourist_flow",
    "destinationCountryM49")
originAreaCodes <- faosws::GetCodeList("tourism", "tourist_flow",
    "originCountryM49")
tourismElementCodes <- faosws::GetCodeList("tourism", "tourist_consumption",
    "tourismElement")

## set the year range to pull data from the SWS
yearRange <- "2011"

##Pull the bidirectional movement data from SWS pertaining to tourist visitors
##to all countries
dim1 <- Dimension(name = "destinationCountryM49",
                  keys = destinationAreaCodes[, code])
dim2 <- Dimension(name = "originCountryM49", keys = originAreaCodes[, code])
dim3 <- Dimension(name = "tourismElement", keys = ("60"))
dim4 <- Dimension(name = "timePointYears", keys = yearRange)
key <- DatasetKey(domain = "tourism", dataset = "tourist_flow",
                  dimensions = list(dim1, dim2, dim3, dim4))

## download the first tourist data from the SWS
data1 <- GetData(key, flags = FALSE)

## remove the tourismElement column which is of no value to me here
data1 <- data1[, which(!grepl("tourism", colnames(data1))), with=FALSE]

## change column names to small simple ones representing destination, origin,
## year and overnight visitor number
setnames(data1, old = colnames(data1), new = c("dest", "orig", "year", "onVisNum"))

## onVisNum in USA in the 2011
# aa = as.data.frame(
# data1%>%
#   filter(dest==840)
# )
# sum(aa$onVisNum)

## onVisNum USA in other countries the 2011
# bb = as.data.frame(
# data1%>%
#   filter(orig==840)
# )
# sum(bb$onVisNum)

# sum(aa$onVisNum) - sum(bb$onVisNum) 
# -12311217


## set the keys to get the tourist data from the FAO working system
areaCodes = faosws::GetCodeList("tourism", "tourist_consumption",
    "geographicAreaM49")

## Pull number of mean number of days stayed, and number of single-day visitors
## from SWS pertaining to visitors to all countries
dim1 = Dimension(name = "geographicAreaM49", keys = areaCodes [, code])
dim2 = Dimension(name = "tourismElement", keys = c("20", "30"))
dim3 = Dimension(name = "timePointYears", keys = yearRange)
key = DatasetKey(domain = "tourism", dataset = "tourist_consumption",
                  dimensions = list(dim1, dim2, dim3))

## download the bi-direction tourism data from the SWS
data2 <- GetData(key, flags = FALSE)

## set the column names to small simple ones representing destination, database
## element, year and value
setnames(data2, old = colnames(data2), new = c("dest", "element", "year", "value"))

## cast the data table to get it in long format
data3 <- as.data.table(dcast(data2, dest + year ~ element))

## change the column names to something readable, "onVisDays" stands for the
## mean number of days that overnight visitors stayed in the destination country.
## "totDayVisNum" is the number of people who visited the country but for a
## single day, e.g. from a cruise ship
setnames(data3, old = colnames(data3), new = c("dest", "year", "onVisDays",
                                           "totDayVisNum"))

## replace missing day visitor numbers (NA) with zero, because it won't effect
## end calculations, but NA's cause equations to fail
data3$totDayVisNum[is.na(data3$totDayVisNum)] <- 0


## merge the two data sets, one containing overnight visitor numbers and number
## of days they visited, the other data set the number of tourists travelling to
## and from each country
data4 <- merge(data1, data3, by=c("dest", "year"), all.x = TRUE)

## rearrange the column order to make it easier to view
data4 <- setcolorder(data4, neworder = c("year", "orig", "dest", "onVisNum",
                                "onVisDays", "totDayVisNum"))

## a small number of countries are missing values for overnight visitor days,
## "onVisDays" and this affects the bi-directional calculations for them, but
## also all of the other countries as well, so this imputes the missing number
## of days, by taking the mean of all day numbers present, grouped by year.
data4[, onVisDays := ifelse(is.na(onVisDays), mean(onVisDays, na.rm=TRUE),
                            onVisDays), by = year]

## calculate the total number tourist visitor days, the product of overnight
## visitor number and days per visit
data4[, onVisTotDays := onVisNum * onVisDays]

## calculate a new total overnight visitor number per country of destination, to
## be used later to proportion the day visitor number, because we do not have
## data for country of origin, and allocate them to a country of origin,
## assuming they arrive in the same relative proportions as the overnight
## visitors
data4[, totOnVisNum := sum(onVisNum), by=list(year,dest)]

## create a new total visitor days by summing the overnight viistor days, and
## the day visitor days
data4[, totVisDays := onVisTotDays + totDayVisNum]


# head(data4)
# 
# aa = as.data.frame(
# data4%>%
#  filter(dest==840)
# )
# sum(aa$onVisNum)
# sum(aa$totDayVisNum)
# sum(aa$onVisTotDays)
# sum(aa$totDayVisNum)+sum(aa$totVisDays)
# 
# bb = as.data.frame(
#   data4%>%
#     filter(orig==840)
# )
# summary(bb$onVisDays)
# sum(bb$totDayVisNum)
# sum(bb$onVisTotDays)
# sum(bb$totDayVisNum)+sum(bb$totVisDays)



## set the keys to get the calorie consuption, by individual FBS commodity for
## each country from the FAO working system
foodAreaCodes <- faosws::GetCodeList("suafbs", "fbs", "geographicAreaM49")
foodElementCodes <- faosws::GetCodeList("suafbs", "fbs", "measuredElementSuaFbs")
## the Item codes contain a hierarchy.  We need to determine all the child
## nodes of the hierarchy and add them to get total consumption.
foodItemTree <- GetCodeTree("faostat_one", "FS1_SUA", "measuredItemFS")
oldAreaCodes <- GetCodeList("faostat_one", "FS1_SUA", "geographicAreaFS")
foodItemTree <- adjacent2edge(foodItemTree)
children <- setdiff(foodItemTree$children, foodItemTree$parent)

##Pull the supply utilization account(SUA) food balance sheet (FBS) data from
##SWS pertaining to calorie consumption from each commodity in each country
dim1 <- Dimension(name = "geographicAreaFS",
                  keys = oldAreaCodes[type == "country", code])
## A bit hackish: get population from total calories and total calories/person/day
dim2 <- Dimension(name = "measuredElementFS", keys = c("261", "264"))
dim3 <- Dimension(name = "measuredItemFS", keys = children)
dim4 <- Dimension(name = "timePointYears", keys = yearRange)
key <- DatasetKey(domain = "faostat_one", dataset = "FS1_SUA",
                  dimensions = list(dim1, dim2, dim3, dim4))

## download the calorie consumption data from the SWS
data6 <- GetData(key, flags = FALSE)

data6 <- dcast.data.table(data6,
            geographicAreaFS + measuredItemFS + timePointYears ~ measuredElementFS,
            value.var = "Value")
setnames(data6, c("261", "264"), c("totalCal", "calPerPersonPerDay"))
data6[, population := totalCal / 365 / calPerPersonPerDay * 1e6]
data6[, population := mean(population, na.rm = TRUE), by = "geographicAreaFS"]
data6[, totalCal := NULL]

## Convert the area codes and item codes to M49 and CPC
areaMap = GetTableData(schemaName = "ess", tableName = "fal_2_m49")
itemMap = GetTableData(schemaName = "ess", tableName = "fcl_2_cpc")
data6[, measuredItemFS := formatC(as.numeric(measuredItemFS), width = 4,
                                  format = "g", flag = "0")]
setkeyv(data6, "measuredItemFS")
setnames(itemMap, "fcl", "measuredItemFS")
setkeyv(itemMap, "measuredItemFS")
data6 = merge(data6, itemMap)
setnames(data6, "cpc", "measuredItemCPC")
data6[, measuredItemFS := NULL]

## And now the area codes
setkeyv(data6, "geographicAreaFS")
setnames(areaMap, "fal", "geographicAreaFS")
setkeyv(areaMap, "geographicAreaFS")
data6 = merge(data6, areaMap)
setnames(data6, "m49", "geographicAreaM49")
data6[, geographicAreaFS := NULL]

## set the column names to small simple ones representing destination, database
## element, year and value
setnames(data6, old = c("geographicAreaM49", "measuredItemCPC",
                        "timePointYears", "calPerPersonPerDay"),
         new = c("orig", "item", "year", "calValue"))


# head(data6)
# as.data.frame(data6 %>%
#   filter(orig == 840) 
# )

## Compute total calories per person per day in orig country
data6[, totalLocalCalories := sum(calValue), by = c("orig", "year")]
# 
# aa = as.data.frame(data6 %>%
#   filter(orig == 840) 
# )
# sum(aa$calValue) #OK!


## merge data4 and data6 to allow calculation of calories by commodity
data7 <- merge(data4, data6, allow.cartesian=TRUE, by = c("year", "orig"))
## Get rid of some of the tourist columns that we don't need anymore:
data7[, c("onVisNum", "onVisDays", "totDayVisNum",
          "onVisTotDays", "totOnVisNum") := NULL]

## calculate the total calories consumed, by item, for the entire year
data7[, totCaloriesByItemPerYear := totVisDays * calValue]


caloriesByOrig = data7[, sum(totCaloriesByItemPerYear, na.rm = TRUE),
                       by = c("year", "orig", "item")]
caloriesByDest = data7[, sum(totCaloriesByItemPerYear, na.rm = TRUE),
                       by = c("year", "dest", "item")]

# caloriesByOrig %>%
#   filter(item == 23110 & orig == 840)
# 
# caloriesByDest %>%
#   filter(item == 23110 & dest == 840)


## Why we have calorories for 0111? 
# as.data.frame(
# caloriesByDest %>%
#   select(dest,item, V1) %>%
#   filter(item == "0111") 
# )
# 
# 
# as.data.frame(
#   caloriesByOrig %>%
#     select(orig,item, V1) %>%
#     filter(item == "0111") 
# )

## calculate the mean calories consumed, by item, for the entire year

## NATA: why we need to read the nutrientData and not to load the nutrientData.RData?
## Source in the nutrient data
# if(Sys.info()[7] == "Golini"){
#   nutrientData = read.csv("~/GitHub/privateFAO/OrangeBook/nutrientData.csv",sep=",",header=TRUE)[,c(3,5:7)]
# } else {
#   stop("No user defined yet!")
# }
# 
# str(nutrientData)
## NATA: from which script the cvs file nutrientData.csv was generated?
## It is not in a corrected form: look at definition of Value. It is a factors with same levels in characters 
# 
# caloriesByOrigFinal = merge(as.data.frame(caloriesByOrig), as.data.frame(nutrientData),
#                              by.x = "item", by.y = "measuredItemCPC")
# 
# ## NATA: seems that measuredElementNutritive == "208" indicates Kjoules
# ## and measuredElementNutritive == "904" Kcal
# caloriesByOrigFinal = filter(caloriesByOrigFinal, measuredElementNutritive == "208")

# NATA: Here I used the nutrientData.RData

## Source in the nutrient data
load(paste0(workingDir, "nutrientData.RData"))

#str(nutrientData)
#head(nutrientData)


nutrientData[, Energy_Kcal := Energy * 0.23900573614]

nutrientData = nutrientData %>%
                  select(measuredItemCPC,Energy_Kcal)

setnames(caloriesByOrig, c("timePointYear","orig","measuredItemCPC","Value"))

caloriesByOrigFinal = merge(caloriesByOrig, nutrientData,
                              by = "measuredItemCPC",
                            all =TRUE)


caloriesByOrigFinal[,quantityValueOrig := (Value / Energy_Kcal) / 10000]


setnames(caloriesByDest, c("timePointYear","dest","measuredItemCPC","Value"))

caloriesByDestFinal = merge(caloriesByDest, nutrientData,
                            by = "measuredItemCPC",
                            all = TRUE)

caloriesByDestFinal[,quantityValueDest := (Value / Energy_Kcal) / 10000]

caloriesByOrigFinal = caloriesByOrigFinal %>%
  select(measuredItemCPC,timePointYear,orig,quantityValueOrig)


caloriesByDestFinal = caloriesByDestFinal %>%
  select(measuredItemCPC,timePointYear,dest,quantityValueDest)

data8 = merge(as.data.frame(caloriesByDestFinal),as.data.frame(caloriesByOrigFinal),
                        by.x = c("measuredItemCPC","timePointYear","dest"),
                        by.y = c("measuredItemCPC","timePointYear","orig"),
                        all = TRUE)


## NATA: it makes sense to set to NAs equal to 0? 

data8$quantityValueDest[is.na(data8$quantityValueDest)] = 0
data8$quantityValueOrig[is.na(data8$quantityValueOrig)] = 0

data8$touristPredicted = data8$quantityValueDest - data8$quantityValueOrig

colnames(data8) = c("measuredItemCPC","timePointYears","geographicAreaM49","quantityValueDest","quantityValueOrig",
                              "touristPredicted")

wheatKeys = c("0111", "23110", "23140.01", "23140.02", "23140.03", "23220.01",
              "23220.02", "23490.02", "23710", "39120.01", "F0020", "F0022")
cattleKeys = c("02111", "21111.01", "21111.02", "21182", "21184.01", "21185",
               "21512.01", "23991.04", "F0875")
palmOilKeys = c("01491.02", "2165", "21691.14", "21910.06", "21700.01",
                "21700.02", "F1243", "34550", "F1275", "34120")
sugarKeys = c("01802", "23512", "F7156", "23210.04", "2351", "23511", "23520",
              "23540", "23670.01", "24110", "2413", "24131", "24139",
              "24490.92", "39140.02", "F7157", "01801", "39140.01", "F7161",
              "01809", "F7162", "F7163")

selectedTourist = data8 %>%
                    filter(geographicAreaM49 == 840 &  measuredItemCPC %in% c(wheatKeys, cattleKeys, sugarKeys, palmOilKeys))

colnames(selectedTourist) = c("measuredItemCPC","timePointYears","geographicAreaM49","quantityValueDest","quantityValueOrig",
  "Value_measuredElement_tou")

touristEstimates = data.table(selectedTourist)

#  touristEstimates %>%
#    filter(measuredItemCPC == 23110)
#  
#  touristEstimates %>%
#    filter(measuredItemCPC == 0111)
#  
#  sum(touristEstimates$Value_measuredElement_tou)
  

# touristEstimates %>%
#   filter (measuredItemCPC == "0111")
#  caloriesByOrig %>%
#    filter (orig == 840, item == "0111")
#  caloriesByDest %>%
#    filter (dest == 840, item == "0111")
# nutrientData %>%
#   filter (measuredItemCPC == "0111")


save(touristEstimates, file = paste0(workingDir, "touristEstimates.RData"))
