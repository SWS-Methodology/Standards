# install.packages("~/Documents/SVN/faosws_0.3.8.tar.gz", type = "src", repo = NULL)

## load the library
library(faosws)
library(faoswsUtil)
library(faoswsFlag)
library(data.table)
library(magrittr)
library(igraph)
library(dplyr)

## Setting up variables
areaVar = "geographicAreaM49"
yearVar = "timePointYears"
itemVar = "measuredItemCPC"
elementVar = "induseElement"
## Make this a parameter in the module
selectedYear = "2011"

## set up for the test environment and parameters
if(Sys.info()[7]  == "Golini"){
  GetTestEnvironment(
    baseUrl = "https://hqlprswsas1.hq.un.fao.org:8181/sws",
    token = "5ac3c6a2-9840-41b3-940f-51376de08584"
  )
  workingDir = "~/Github/privateFAO/OrangeBook/"
  files = dir(workingDir,full.names = TRUE)
  load(file = paste0(workingDir,"vegetableOilsData.RData"))
  load(file = paste0(workingDir,"nutrientData.RData"))
} else if(Sys.info()[7] == "josh"){
  GetTestEnvironment(
    baseUrl = "https://hqlprswsas1.hq.un.fao.org:8181/sws",
    token = "5c9850df-d271-4de2-9db4-de7bc353edde" # Josh's token
  )
  workingDir = "~/Documents/Github/privateFAO/OrangeBook/"
  files = dir(workingDir,full.names = TRUE)
  load(file = paste0(workingDir,"vegetableOilsData.RData"))
  load(file = paste0(workingDir,"nutrientData.RData"))
}

getCPCTreeItem = function(dataContext){
  ## itemTable =
  ##     GetCodeList(domain = slot(dataContext, "domain"),
  ##                 dataset = slot(dataContext, "dataset"),
  ##                 dimension = itemVar)
  ## HACK (Michael): Since we don't have the columne 'type' ready
  ##                 for selection, we will select all item which
  ##                 are under the CPC heading '0'.
  itemEdgeList =
    adjacent2edge(
      GetCodeTree(domain = "agriculture",
                  dataset = "agriculture",
                  dimension = itemVar)
    )
  
  itemEdgeGraph = graph.data.frame(itemEdgeList)
  itemDist = shortest.paths(itemEdgeGraph, v = "CPC", mode = "out")
  fbsItemCodes = colnames(itemDist)[is.finite(itemDist) &
                                      colnames(itemDist) != "CPC"]
  fbsItemCodes
}



## Function to get bio-fuel utilization
## Data are provided by OECD-FAO Aglink Cosimo.  
## 2000-2012

getBioFuelData = function(){
  
  allCountries =
    GetCodeList(domain = "industrialUse",
                dataset = "biofuel",
                dimension = areaVar)[type == "country", code]
  
  bioFuelKey = DatasetKey(
    domain = "industrialUse",
    dataset = "biofuel",
    dimensions = list(
      Dimension(name = areaVar,
                keys = allCountries),
      Dimension(name = elementVar,
                keys = "5150"),
      Dimension(name = itemVar,
                keys = allCPCItem),
      Dimension(name = yearVar,
                keys = selectedYear)
    )
  )
  
  ## Pivot to vectorize yield computation
  bioFuelPivot = c(
    Pivoting(code = areaVar, ascending = TRUE),
    Pivoting(code = itemVar, ascending = TRUE),
    Pivoting(code = yearVar, ascending = FALSE),
    Pivoting(code = elementVar, ascending = TRUE)
  )
  
  bioFuelQuery = GetData(
    key = bioFuelKey,
    flags = TRUE,
    normalized = FALSE,
    pivoting = bioFuelPivot
  )
  setnames(bioFuelQuery,
           old = grep("induseElement", colnames(bioFuelQuery), value = TRUE),
           new = gsub("induseElement", "measuredElement",
                      grep("induseElement", colnames(bioFuelQuery),
                           value = TRUE)))
  
  
  ## Convert time to numeric
  bioFuelQuery[, timePointYears := as.numeric(timePointYears)]
  bioFuelQuery
}



allCPCItem = getCPCTreeItem()
agricFeedStuffsForBioFuelData = getBioFuelData()

# unique(agricFeedStuffsForBioFuelData$measuredItemCPC)
#    agricFeedStuffsForBioFuelData %>%
#      filter(geographicAreaM49 == 840)



## Get information on industrial use of vegetable oils 
## provided by USDA PS&D database 
## https://apps.fas.usda.gov/psdonline/

# vegetableOilsData = read.csv("psd_oilseeds.csv", sep = "," , dec = ".", header=T)
# save(vegetableOilsData, file = "vegetableOilsData.RData")


# Attribute_ID == 140 is Industrial Dom. Cons. 
# Attribute_ID == 156 is Use for Alcohol Indust
vegetableOilsDataForIndUses = vegetableOilsData %>%
  filter(Attribute_ID == 140 & Calendar_Year == selectedYear)

source(paste0(workingDir,"function_USDA_2_SUA_country.R"))
source(paste0(workingDir,"function_USDA_2_SUA_com.R"))

funcCountryCodes <- lapply(vegetableOilsDataForIndUses$Country_Name, USDA_2_SUA_country)
vegetableOilsDataForIndUses <- cbind(vegetableOilsDataForIndUses, geographicAreaM49 = do.call("rbind", funcCountryCodes))

funcComCodes <- lapply(vegetableOilsDataForIndUses$Commodity_Description, USDA_2_SUA_comm)
vegetableOilsDataForIndUses <- cbind(vegetableOilsDataForIndUses, measuredItemCPC = do.call("rbind", funcComCodes))

vegetableOilsDataForIndUses = vegetableOilsDataForIndUses %>%
  select(geographicAreaM49,measuredItemCPC,Calendar_Year,Value)

vegetableOilsDataForIndUses = as.data.table(vegetableOilsDataForIndUses)

setnames(vegetableOilsDataForIndUses, c("geographicAreaM49","measuredItemCPC","timePointYears","Value"))


vegetableOilsDataForIndUses$geographicAreaM49 = as.character(vegetableOilsDataForIndUses$geographicAreaM49)
vegetableOilsDataForIndUses$measuredItemCPC = as.character(vegetableOilsDataForIndUses$measuredItemCPC)
vegetableOilsDataForIndUses$timePointYears = as.character(vegetableOilsDataForIndUses$timePointYears)

agricFeedStuffsForBioFuelData$geographicAreaM49 = as.character(agricFeedStuffsForBioFuelData$geographicAreaM49)
agricFeedStuffsForBioFuelData$measuredItemCPC = as.character(agricFeedStuffsForBioFuelData$measuredItemCPC)
agricFeedStuffsForBioFuelData$timePointYears = as.character(agricFeedStuffsForBioFuelData$timePointYears)


#setnames(vegetableOilsDataForIndUses, c("geographicAreaM49", "measuredItemCPC",   "timePointYears",    "Value"))

## Merge the two data set

IndustrialUsesData = merge(agricFeedStuffsForBioFuelData,vegetableOilsDataForIndUses,
                           by = c("geographicAreaM49","measuredItemCPC","timePointYears"),
                           all = TRUE)


IndustrialUsesData$Value_measuredElement_5150 = as.numeric(IndustrialUsesData$Value_measuredElement_5150)
IndustrialUsesData$Value_measuredElement_5150[which(is.na(IndustrialUsesData$Value_measuredElement_5150))] = 0
IndustrialUsesData$Value[which(is.na(IndustrialUsesData$Value))] = 0



# Value_measuredElement_5150 is in tonns
# Value is in 1000MT

IndustrialUsesData[,Value_measuredElement_ind := Value_measuredElement_5150 + Value*1000]

# IndustrialUsesData%>%
#   filter (geographicAreaM49 == 840)

## Now we need of Nutritive elements
# IndustrialUsesCompletedData <- merge(IndustrialUsesData, nutrientData, 
#                                   by = c("measuredItemCPC"),
#                                   all = TRUE)
# 
# IndustrialUsesCompletedData %>%
#       filter(geographicAreaM49 == 840)
# 
# 
# IndustrialUsesCompletedData[,Value_measuredElement_ind := sumOfElement / Energy] 

selectedIndustrialUsesData = IndustrialUsesData %>% 
                                select(measuredItemCPC,geographicAreaM49,timePointYears,Value_measuredElement_ind) %>%
                                filter(geographicAreaM49 == 840)

industrialEstimates = selectedIndustrialUsesData[measuredItemCPC!="NA",]

# How to mange the flags? We have flags only for vegetableOilsDataForIndUses data


if(Sys.info()[7] == "Golini"){
  save(industrialEstimates, file = "C:/Users/Golini/Documents/Github/privateFAO/OrangeBook/industrialEstimates.RData")
} else {
  stop("Need path for this user!")
}

