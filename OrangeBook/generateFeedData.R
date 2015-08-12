library("data.table")
library("RJSONIO")
library("RCurl")
library("faosws")
library(reshape2)
library(dplyr)


if(Sys.info()[7] == "Golini"){ # Nata work
  workingDir = "~/Github/privateFAO/OrangeBook/"
  GetTestEnvironment(
    baseUrl = "https://hqlprswsas1.hq.un.fao.org:8181/sws",
    token = "16d41d05-55a5-4e13-8ebe-fed8c3426579" # Nata's token
  )
  } else {
  stop("No working dir for current user!")
}



# Load the required data *'

# selareas=swsContext.datasets[[1]]@dimensions$geographicAreaFS@keys
areaCodesM49 = "840"
# selyears=swsContext.datasets[[1]]@dimensions$timePointYears@keys
selectedYear = "2011"
animKeys=c("02111", "02122", "02123", "02140", "02151", "02155", "02154", "02153", "02152")
estKeys=c("1", "2", "3")
nutrKeys=c("1", "2")

areaVar = "geographicAreaM49"
yearVar = "timePointYears"
itemVar = "measuredItemCPC"
elementVar = "measuredElement"

# 1.) List of the areas start and end years'

data1=GetCodeList(domain="agriculture", dataset="agriculture", dimension="geographicAreaM49")
data1[, startyr:=as.integer(substr(startDate, 1, 4))]
data1[, endyr:=as.integer(substr(endDate, 1, 4))]
areareg = data1[which(type=="country"), list(code, startyr, endyr)]
setnames(areareg, "code", "geographicAreaM49")


      
dim1=Dimension(name="geographicAreaM49", keys = areaCodesM49)
dim2=Dimension(name="measuredElement", keys = c("5111", "5112"))
dim3=Dimension(name="measuredItemCPC", keys = animKeys)
dim4=Dimension(name="timePointYears", keys = selectedYear)

productionKeys = DatasetKey(domain="agriculture", dataset="agriculture", dimensions=list(dim1, dim2, dim3, dim4))

productionPivot <- c(
	Pivoting(code= "geographicAreaM49", ascending = TRUE), 
	Pivoting(code= "measuredItemCPC", ascending = TRUE), 
	Pivoting(code= "measuredElement", ascending = TRUE), 
	Pivoting(code = "timePointYears", ascending = TRUE))

data1=GetData(key = productionKeys, 
            flags = TRUE, 
            normalized = TRUE , 
            metadata = FALSE, 
            pivoting = productionPivot)

data1[, ValAnim:=ifelse(measuredElement=="5111", Value, Value*1000)]
data1[, FlagAnim:=ifelse((flagObservationStatus=="M" & flagMethod=="u") | is.na(Value), 2, ifelse(flagObservationStatus=="M" & flagMethod=="n",3,1))]
animalData=data1[, list(geographicAreaM49, measuredItemCPC, timePointYears, ValAnim, FlagAnim)]

# remove(data1, dim1, dim2, dim3, dim4, keys, productionPivot)


# 3.) Animal unit index'

dim1=Dimension(name="geographicAreaM49", keys = areaCodesM49)
dim2=Dimension(name="measuredItemCPC", keys = animKeys)
dim3=Dimension(name="estimator", keys = estKeys)
dim4=Dimension(name="nutrientTypeM", keys = nutrKeys)
dim5=Dimension(name="timePointYears", keys = selectedYear)

requirementKeys = DatasetKey(domain="feed", dataset="animal_unit_index", dimensions=list(dim1, dim2, dim3, dim4, dim5))

requirementPivot <- c(
	Pivoting(code= "geographicAreaM49", ascending = TRUE), 
	Pivoting(code= "measuredItemCPC", ascending = TRUE), 
	Pivoting(code= "estimator", ascending = TRUE), 
	Pivoting(code= "nutrientTypeM", ascending = TRUE), 
	Pivoting(code = "timePointYears", ascending = TRUE))

data2 = GetData(key = requirementKeys, 
              flags = TRUE, 
              normalized = TRUE , 
              metadata = FALSE, 
              pivoting = requirementPivot)

data2[, FlagAUI:=ifelse((flagObservationStatus=="M" & flagMethod=="u") | is.na(Value), 2, ifelse(flagObservationStatus=="M" & flagMethod=="n",3,1))]
animalUnitIndex = data2[,list(geographicAreaM49, measuredItemCPC, nutrientTypeM, estimator, timePointYears, Value, FlagAUI)]
setnames(animalUnitIndex, "Value", "ValAUI")
setnames(animalUnitIndex, "nutrientTypeM", "nutrientType")

#remove(df0, d1, d2, d3, d4, d5, k, p)


# 4.) Non-forage rate'

dim1=Dimension(name="geographicAreaM49", keys=areaCodesM49)
dim2=Dimension(name="measuredItemCPC", keys=animKeys)
dim3=Dimension(name="estimatorM", keys=estKeys)
dim4=Dimension(name="timePointYears", keys=selectedYear)

intensityKey=DatasetKey(domain="feed", dataset="non_forage_rate", dimensions=list(dim1, dim2, dim3, dim4))

intensityPivot <- c(
	Pivoting(code= "geographicAreaM49", ascending = TRUE), 
	Pivoting(code= "measuredItemCPC", ascending = TRUE), 
	Pivoting(code= "estimatorM", ascending = TRUE), 
	Pivoting(code = "timePointYears", ascending = TRUE))

intensityData=GetData(key = intensityKey, flags = TRUE, normalized = TRUE , metadata = FALSE, pivoting = intensityPivot)
intensityData[, FlagNFR:=ifelse((flagObservationStatus=="M" & flagMethod=="u") | is.na(Value), 2, ifelse(flagObservationStatus=="M" & flagMethod=="n",3,1))]

intensity=intensityData[, list(geographicAreaM49, measuredItemCPC, estimatorM, timePointYears, Value, FlagNFR)]
setnames(intensity, "Value", "ValNFR")
setnames(intensity, "estimatorM", "estimator")

#remove(df0, d1, d2, d3, d4, k, p)


# 5.) Feed for aquaculture'

dim1=Dimension(name="geographicAreaM49", keys=areaCodesM49)
dim2=Dimension(name="estimator", keys=estKeys)
dim3=Dimension(name="nutrientTypeM", keys=c("3", "4"))
dim4=Dimension(name="timePointYears", keys=selectedYear)

aquaKeys=DatasetKey(domain="feed", dataset="aquaculture_feed", dimensions=list(dim1, dim2, dim3, dim4))

aquaPivot <- c(
	Pivoting(code= "geographicAreaM49", ascending = TRUE), 
	Pivoting(code= "estimator", ascending = TRUE), 
	Pivoting(code= "nutrientTypeM", ascending = TRUE), 
	Pivoting(code = "timePointYears", ascending = TRUE))

data5=GetData(key = aquaKeys, flags = TRUE, normalized = TRUE , metadata = FALSE, pivoting = aquaPivot)
data5[, nutrientType:=ifelse(nutrientTypeM=="3", "1", "2")]
aqua = data5[,list(geographicAreaM49, nutrientType, estimator, timePointYears, Value, flagObservationStatus, flagMethod)]

#remove(df0, d1, d2, d3, d4, k, p)


# 6.) Population'

dim1=Dimension(name="geographicAreaM49", keys=areaCodesM49)
dim2=Dimension(name="measuredElementPopulation", keys="21")
dim3=Dimension(name="timePointYears", keys=selectedYear)

populationKeys=DatasetKey(domain="population", dataset="population", dimensions=list(dim1, dim2, dim3))

populationPivot <- c(
	Pivoting(code= "geographicAreaM49", ascending = TRUE), 
	Pivoting(code= "measuredElementPopulation", ascending = TRUE),
	Pivoting(code = "timePointYears", ascending = TRUE))

data6 = GetData(key = populationKeys, flags = TRUE, normalized = TRUE , metadata = FALSE, pivoting = populationPivot)
population = data6[, list(geographicAreaM49, timePointYears, Value, flagPopulation)]
setnames(population, "Value", "Population")

#remove(df0, d1, d2, d3, k, p)


# Calculate feed requirement of livestock and poultry *'

# 1.) Create the roster *'

# data0 = data.table(geographicAreaM49="1", measuredItemCPC="1", nutrientType="1", estimator="1", timePointYears="1")
# data1 = df0[which(FALSE),]
# 
# for (x1 in animlist) {
#   for (x2 in nutrlist) {
#     for (x3 in estlist) {
#       for (x4 in selyears) {
#         df2=data.table(geographicAreaM49=selareas, measuredItemCPC=x1, nutrientType=x2, estimator=x3, timePointYears=x4)
#         df3=rbind(df1, df2)
#         df1=df3
#       }
#     }
#   }
# }
# df4=merge(df1, areareg, by="geographicAreaM49", all.x=TRUE)
# 
# roster=df4[which((as.integer(timePointYears)>=startyr | is.na(startyr)) & (as.integer(timePointYears)<=endyr | is.na(endyr))), list(geographicAreaM49, measuredItemCPC, nutrientType, estimator, timePointYears)]
# 
# remove(df0, df1, df2, df3, df4, x1, x2, x3, x4)


# 2.) Merge information on animal numbers, AUI and non-forage rate'

animalNumInd = merge(animalData,animalUnitIndex,
              by = c("geographicAreaM49", "measuredItemCPC","timePointYears"),
              all.x = TRUE)

animalNumIndInt = merge(animalNumInd,intensity,
                        by = c("geographicAreaM49", "measuredItemCPC","timePointYears","estimator"),
                        all.x = TRUE)

# df0=merge(roster, anim, by=c("geographicAreaM49", "measuredItemCPC", "timePointYears"), all.x=TRUE)
# 'df1=df0[which(is.na(df0$ValAnim)==FALSE),]'
# df1=df0
# df2=merge(df1, aui, by=c("geographicAreaM49", "measuredItemCPC", "nutrientType", "estimator", "timePointYears"), all.x=TRUE)
# df3=merge(df2, nfr, by=c("geographicAreaM49", "measuredItemCPC", "estimator", "timePointYears"), all.x=TRUE)


# 3.) Multiply and transform into GJ or tonnes of protein'

animalNumIndInt$FlagAnim[which(is.na(animalNumIndInt$FlagAnim))]=3
animalNumIndInt$FlagAUI[which(is.na(animalNumIndInt$FlagAUI))]=2
animalNumIndInt$FlagNFR[which(is.na(animalNumIndInt$FlagNFR))]=2

# Note: NAs in the agricultural production file are interpreted as quasi zero.'


animalNumIndInt[, RefFeed:=ifelse(nutrientType=="1", 35.6, 0.319)]
animalNumIndInt[, ValFeed:=ValAnim*ValAUI*ValNFR*RefFeed]

animalNumIndInt[, FlagFeed:=apply(cbind(FlagAnim, FlagAUI, FlagNFR), 1, FUN=max)]
animalNumIndInt$FlagFeed[which(animalNumIndInt$ValAnim<1 & animalNumIndInt$FlagAnim==1)]=1
animalNumIndInt$ValFeed[which(animalNumIndInt$FlagFeed>1)]=0

refrank=c(2,3,1)
animalNumIndInt[, RankFlag:=refrank[FlagFeed]]

lspfeed=animalNumIndInt[, list(geographicAreaM49, measuredItemCPC, nutrientType, timePointYears, estimator, ValFeed, RankFlag)]

#remove(df0, df1, df2, df3, refrank)


# Aggregate feed of each species and aquaculture feed *'

# Meaning of the flags and their ranks in the aggregation below '
# 3: negligible (Mn) -> Rank 1 '
# 2: not known (Mu)  -> Rank 3 '
# 1: estimated (Ee)  -> Rank 2 '

setnames(aqua, "Value", "ValFeed")
aqua[, measuredItemCPC:="aqua" ]
aqua[, RankFlag:=ifelse((flagObservationStatus=="M" & flagMethod=="u") | is.na(ValFeed), 1, 
                        ifelse(flagObservationStatus=="M" & flagMethod=="n",1,2))]

# Note: When aquaculture feed is not known, it is assumed to be negligible.'

aqua = aqua[, list(geographicAreaM49, measuredItemCPC, nutrientType, timePointYears, estimator, ValFeed, RankFlag)]
totalDemand = rbind(lspfeed, aqua)

totalDemand[, Value:=sum(ValFeed), by=list(geographicAreaM49, nutrientType, estimator, timePointYears)]
totalDemand[, AggFlag:=max(RankFlag), by=list(geographicAreaM49, nutrientType, estimator, timePointYears)]


totalDemand=unique(totalDemand[, list(geographicAreaM49, nutrientType, estimator, timePointYears, Value, AggFlag)])

refstat=c("M", "E", "M")
refmeth=c("u", "e", "u")
totalDemand[, flagObservationStatus:=refstat[AggFlag]]
totalDemand[, flagMethod:=refmeth[AggFlag]]


feedDemand = totalDemand[, list(geographicAreaM49, nutrientType, estimator, timePointYears, Value, flagObservationStatus, flagMethod)]
feedDemand[, feedBaseUnit:=ifelse(nutrientType=="1", "1", "3")]

totalDemandPopulationData=merge(totalDemand, population, by=c("geographicAreaM49", "timePointYears"), all.x=TRUE)

# 239006 for kjoule conversion
totalDemandPopulationData[, ValPerCap:=ifelse(nutrientType=="1", Value*239006/365/(Population*1000), Value*1000000/365/(Population*1000))]
totalDemandPopulationData[, StatusPerCap:=ifelse(is.na(flagPopulation) | flagPopulation=="M", "M", flagObservationStatus)]
totalDemandPopulationData[, MethodPerCap:=ifelse(is.na(flagPopulation) | flagPopulation=="M", "u", flagMethod)]
totalDemandPopulationData$ValPerCap[which(is.na(totalDemandPopulationData$flagPopulation) | totalDemandPopulationData$flagPopulation=="M")]=0

feedPerCap=totalDemandPopulationData[, list(geographicAreaM49, nutrientType, estimator, timePointYears, ValPerCap, StatusPerCap, MethodPerCap)]

#remove(df0, df1, df2, df3, refmeth, refstat)

setnames(feedPerCap, "ValPerCap", "Value")
setnames(feedPerCap, "StatusPerCap", "flagObservationStatus")
setnames(feedPerCap, "MethodPerCap", "flagMethod")
feedPerCap[, feedBaseUnit:=ifelse(nutrientType=="1", "2", "4")]

finalFeedDemandData = rbind(feedDemand, feedPerCap)

finalFeedDemandData = finalFeedDemandData[, list(geographicAreaM49, nutrientType, estimator, feedBaseUnit, timePointYears, Value, flagObservationStatus, flagMethod)]


#SaveData(domain="feed", dataset="total_feed", data=final)

## SUMMARY
## Having measured Energy (MJ) and Protein (t) requirements of herds by country and year, this script 
## allocates FAOSTAT commodities from which the animals retrieve their requirements. The results 
## are disaggregated estimates of quantities (t) of feed use that can be implementet in Food Balance Sheets.

# feedlist <- as.data.table(read.csv(paste0(workingDir,'feedlist.csv'), sep = ",")) 
# aa = feedlist$item[1:33]
# aa = paste("00",aa,sep="")
# bb = feedlist$item[34:196]
# bb = paste("0",bb,sep="")
# feedlist$item = c(aa,bb,as.character(feedlist$item[197:length(feedlist$item)]))
# feedlist = as.data.table(feedlist)
# feedlist[, item := faoswsUtil::fcl2cpc(as.character(item))]
# feedlist$item[55] = "01802"
# write.csv(feedlist,paste0(workingDir,"feedListCPC.csv"),row.names = F)

feedlist <- read.csv(paste0(workingDir,'feedListCPC.csv'), sep = ",") 

# 2. Preparation of Parameters

## Feeditems
feedlist <- within(feedlist, {
  ENERGY <- ENERGY * 1000
  PROTEIN <- PROTEIN /100
})

## Potential Feeds (All feeditems excluding Oil meals, meals and brans)
potentialfeedlist <- feedlist[feedlist$feedClassification == "Potential Feed",]
potentialfeeds <- potentialfeedlist$item

## Protein meals and Items that have only feed purpose

proteinfeedlist <- feedlist[feedlist$feedClassification == "FeedOnly",]
proteinfeeds <- proteinfeedlist$item

## Feed Demand 

energyData = finalFeedDemandData %>%
                filter(feedBaseUnit == 1 & estimator == 1) %>%
                select(geographicAreaM49,timePointYears,Value)

energyData = as.data.table(energyData)

setnames(energyData, c("geographicAreaM49","timePointYears","eDemand"))

proteinData = finalFeedDemandData%>%
                filter(feedBaseUnit == 3 & estimator == 1)%>%
                select(geographicAreaM49,timePointYears,Value)

proteinData = as.data.table(proteinData)

setnames(proteinData, c("geographicAreaM49","timePointYears","pDemand"))

demand = merge(energyData,proteinData,
               by = c("geographicAreaM49","timePointYears"),
               all = TRUE)


demand <- within(demand, {
  eDemand <- eDemand * 1000
})


# 3. Subtract Nutrients provided by FeedOnly items (oilcakes, brans, etc.)

## Retrieve Availability (Supply) of FeedOnly items

feedKeysFCL <- as.character(read.csv(paste0(workingDir,'feedlist.csv'), sep = ",")[,1])

dim1=Dimension(name="geographicAreaFS", keys = "231")
dim2=Dimension(name="measuredElementFS", keys = c("51","61","91","131","141"))
dim3=Dimension(name="measuredItemFS", keys = feedKeysFCL)
dim4=Dimension(name="timePointYears", keys = selectedYear)

avabDataKeys = DatasetKey(domain="faostat_one", dataset="FS1_SUA_UPD", dimensions=list(dim1, dim2, dim3, dim4))

avaDataPivot <- c(
  Pivoting(code= "geographicAreaFS", ascending = TRUE), 
  Pivoting(code= "measuredElementFS", ascending = TRUE), 
  Pivoting(code= "measuredItemFS", ascending = TRUE), 
  Pivoting(code = "timePointYears", ascending = TRUE))

avabData = GetData(key = avabDataKeys, 
               flags = TRUE, 
               normalized = TRUE , 
               metadata = FALSE, 
               pivoting = avaDataPivot)

avabData = avabData[, "flagFaostat" := NULL]

avabData = dcast(avabData, geographicAreaFS + measuredItemFS + timePointYears ~ measuredElementFS )
setnames(avabData,c("geographicAreaFS","measuredItemFS","timePointYears","processedValue","foodValue",
                    "productionValue","importsValue","exportsValue"))


# get feed Data

dim1=Dimension(name="geographicAreaFS", keys = "231")
dim2=Dimension(name="measuredElementFS", keys = "101")
dim3=Dimension(name="measuredItemFS", keys = feedKeysFCL)
dim4=Dimension(name="timePointYears", keys = selectedYear)

feedDataKeys = DatasetKey(domain="faostat_one", dataset="FS1_SUA_UPD", dimensions=list(dim1, dim2, dim3, dim4))

feedDataPivot <- c(
  Pivoting(code= "geographicAreaFS", ascending = TRUE), 
  Pivoting(code= "measuredElementFS", ascending = TRUE), 
  Pivoting(code= "measuredItemFS", ascending = TRUE), 
  Pivoting(code = "timePointYears", ascending = TRUE))

feedData = GetData(key = feedDataKeys, 
                   flags = TRUE, 
                   normalized = TRUE , 
                   metadata = FALSE, 
                   pivoting = feedDataPivot)

feedData[, measuredElementFS := NULL]
setnames(feedData,c("geographicAreaFS","measuredItemFS","timePointYears","feedValue","feedFlag"))



avabData = merge(avabData, feedData,
              by = c("geographicAreaFS","measuredItemFS","timePointYears"),
              all = TRUE)

avabData$geographicAreaM49 = faoswsUtil::fs2m49(avabData$geographicAreaFS)
avabData = avabData[order(as.numeric(avabData$measuredItemFS)),]
              
aa = avabData$measuredItemFS[1:24]
aa = paste("00",aa,sep="")
bb = avabData$measuredItemFS[25:160]
bb = paste("0",bb,sep="")
avabData$measuredItemFS = c(aa,bb,as.character(avabData$measuredItemFS[161:length(avabData$measuredItemFS)]))
avabData$measuredItemCPC = faoswsUtil::fcl2cpc(avabData$measuredItemFS)


avabData = as.data.table(avabData)
proteinSupplyData = avabData %>%
                    filter (measuredItemCPC %in% proteinfeeds)


## Calculate Energy and Protein Availability
### allocate feed conversion actors for energy and protein

proteinfeedlist = as.data.table(proteinfeedlist)
proteinfeedlist[,"itemname" := NULL]

setnames(proteinfeedlist,c( "measuredItemCPC","ENERGY", "PROTEIN","feedClassification"))

proteinSupply <- merge(proteinSupplyData, proteinfeedlist,
                 by = "measuredItemCPC",
                 all.x=TRUE)

proteinSupply[is.na(proteinSupply)] = 0

proteinSupply[,availabilityValue := productionValue +  importsValue - exportsValue]

proteinSupply$availabilityValue = ifelse(proteinSupply$availabilityValue<0,0,proteinSupply$availabilityValue)


### calculate Availability
proteinSupply[,energySupply := availabilityValue * ENERGY]
proteinSupply[,proteinSupply := availabilityValue * PROTEIN]

### sum energy and protein availabilities from different items 

aggEnergy = aggregate(energySupply ~ geographicAreaM49, proteinSupply, function(x) sum(as.numeric(x)))

aggProtein = aggregate(proteinSupply ~ geographicAreaM49, proteinSupply, function(x) sum(as.numeric(x)))

# 
# aggEnergy[is.na(aggEnergy)] <- 0
# aggProtein[is.na(aggProtein)] <- 0
# aggEnergy$aggenergy[aggenErgy$aggEnergy <0] <-0
# aggProtein$aggProtein[aggProtein$aggProtein <0] <-0

demand <- merge(demand, aggEnergy, 
                by ="geographicAreaM49",
                all.x = TRUE)

demand <- merge(demand, aggProtein,
                by ="geographicAreaM49",
                all.x = TRUE)

demand[is.na(demand)] <- 0

### Subtract Availability from Demand
demand[, REDemand := eDemand - energySupply]
demand[, RPDemand := pDemand - proteinSupply]

demand$REDemand[demand$REDemand < 0 ] <- 0
demand$RPDemand[demand$RPDemand < 0 ] <- 0

# 5. Official Feed

Official <- subset(avabData, feedFlag == "" & (measuredItemCPC %in% potentialfeeds))

feedlist = as.data.table(feedlist)
feedlist[,c("itemname","feedClassification") := NULL]

setnames(feedlist,c("measuredItemCPC","ENERGY","PROTEIN"))

officialNutrientsData = merge(Official, feedlist,
                            by = "measuredItemCPC",
                            all.x = TRUE)

officialNutrientsData[, officialEnergy := feedValue * ENERGY]

officialNutrientsData[, officialProtein := feedValue * PROTEIN]

totOfficialEnergy <- aggregate(officialEnergy ~ geographicAreaM49 + timePointYears, 
                               officialNutrientsData, 
                               function(x) sum(as.numeric(x)))

totOfficialProtein <- aggregate(officialProtein ~ geographicAreaM49 + timePointYears, 
                                officialNutrientsData, 
                                function(x) sum(as.numeric(x)))

totOfficialNutrients = merge(totOfficialEnergy,totOfficialProtein,
                              by = c("geographicAreaM49","timePointYears"),
                              all =TRUE)

demand = merge(demand, totOfficialNutrients,
               by = c("geographicAreaM49","timePointYears"),
               all =TRUE)

demand[, RREDemand := REDemand - officialEnergy]
demand[, RRPDemand := RPDemand - officialProtein]

demand$RREDemand[demand$RREDemand < 0] <- 0
demand$RRPDemand[demand$RRPDemand < 0] <- 0

resDemand = demand %>%
              select(geographicAreaM49,timePointYears,RREDemand, RRPDemand)


# 4. Establish distributions of feed based on Availability 

## Retrieve Potential feed items data

potentialFeedData = subset(avabData, measuredItemCPC %in% potentialfeeds & !is.na(feedValue) & feedFlag != "")

potentialFeedNutrients = merge(potentialFeedData, feedlist,
                                by = "measuredItemCPC",
                                all.x = TRUE)

## Apply nutritive factors and calculate nutrient availability

potentialFeedNutrients[is.na(potentialFeedNutrients)] = 0
potentialFeedNutrients[, avail := productionValue + importsValue - exportsValue - processedValue - foodValue]
potentialFeedNutrients$avail = ifelse(potentialFeedNutrients$avail < 0, 0, potentialFeedNutrients$avail)


potentialFeedNutrients[, energyAvail := avail * ENERGY]
potentialFeedNutrients[, proteinAvail := avail * PROTEIN]


## Sum nutrient Availabilities for each country and year (for construction of shares)

totEnergyAvail <- aggregate(energyAvail ~ geographicAreaM49 + timePointYears, 
                            potentialFeedNutrients, 
                                function(x) sum(as.numeric(x)))


totProteinAvail <- aggregate(proteinAvail ~ geographicAreaM49 + timePointYears, 
                            potentialFeedNutrients, 
                            function(x) sum(as.numeric(x)))

## Construct shares of feed availablility


potentialFeedNutrients[, eShare := energyAvail / totEnergyAvail$energyAvail]
potentialFeedNutrients[, pShare := proteinAvail / totProteinAvail$proteinAvail]


# 5. Allocate Feed

## merge demand and availability data
demandSupply <- merge(resDemand, potentialFeedNutrients, 
              by=c("geographicAreaM49", "timePointYears"),
              all.y = TRUE)

## apply availability shares to demand (Residual: after substraction carried out in step 3)

demandSupply[, eFeed := (eShare * RREDemand) / ENERGY]
demandSupply[, pFeed := (pShare * RRPDemand) / PROTEIN]


## construct indicator measuring if both protein and energy demands are satisfied with current setup

demandSupply[, pCheck := eFeed * PROTEIN]

eFeedProtein = aggregate(pCheck ~ geographicAreaM49 + timePointYears, 
                         demandSupply, 
                        function(x) sum(as.numeric(x)))

demandSupply[, eCheck := pFeed * ENERGY]

pFeedEnergy = aggregate(eCheck ~ geographicAreaM49 + timePointYears, 
                         demandSupply, 
                         function(x) sum(as.numeric(x)))

setnames(eFeedProtein,c("geographicAreaM49", "timePointYears","sumPCheck"))
setnames(pFeedEnergy,c("geographicAreaM49", "timePointYears","sumECheck"))

demandSupply = merge(demandSupply, eFeedProtein,
                     by=c("geographicAreaM49", "timePointYears"),
                     all.x = TRUE)

demandSupply = merge(demandSupply, pFeedEnergy,
                     by=c("geographicAreaM49", "timePointYears"),
                     all.x = TRUE)

# 
# str(demandSupply)
# 
# feed = demandSupply %>%
#         select(geographicAreaM49,timePointYears,measuredItemCPC,sumPCheck,RRPDemand, pFeed, eFeed) %>%

demandSupply[, feed := ifelse(demandSupply$sumPCheck < demandSupply$RRPDemand, demandSupply$pFeed, demandSupply$eFeed) ]
      


## Optimize feed allocation under the condition that both energy and protein demands are satisfied
# dmsp$pfeed[is.na(dmsp$pfeed)] <- 0
# dmsp$efeed[is.na(dmsp$efeed)] <- 0

# create auxiliary funcion which returns all years for a given country
# yearlist <- subset(dmsp, ,c(1,2))
# 
# yearlist <- unique(yearlist)
# 
# years <- function(x) {yearlist$year[yearlist$area==x]}



## Apply optimization function: note Avialability is not a constraint

# feed <- data.table()
# 
# for(i in unique(yearlist$area))
#   for(j in 1:length(yearlist$year[yearlist$area==i]))
#     feed <- rbind(feed, optimize(i, years(i)[j] ))


## Check if all conditions are met and  demand is met

# finalenergy <- ddply(feed, .(area, year), function(x) {sum(x$finalfeed * x$ENERGY)})
# colnames(finalenergy) <- c("area", "year", "finalenergy")
# finalprotein <- ddply(feed, .(area, year), function(x) {sum(x$finalfeed * x$PROTEIN)})
# colnames(finalprotein) <- c("area", "year", "finalprotein")
# feed <- merge(feed, finalenergy, by=c("area", "year"), all.x=T)
# feed <- merge(feed, finalprotein, by=c("area", "year"), all.x=T)
# 
# feed$finalcheck <- ifelse((feed$REDemand - feed$finalenergy) > 1, "GAP",
#                           ifelse((feed$RPDemand - feed$finalprotein) > 1, "GAP", "MET")) 

## Reunite estimated with official and cakes & bran feed data

selectedOfficialNutrientsData = officialNutrientsData %>%
                                    select(geographicAreaM49,timePointYears,measuredItemCPC,feedValue)

selectedOfficialNutrientsData$flagObservationStatus_measuredElement_5520 = 
                                rep("",length(selectedOfficialNutrientsData$feedValue))

selectedOfficialNutrientsData$flagMethod_measuredElement_5520 = rep("-",length(selectedOfficialNutrientsData$feedValue))

selectedProteinSupply = proteinSupply %>%
  select(geographicAreaM49,timePointYears,measuredItemCPC,availabilityValue)

setnames(selectedProteinSupply,c("geographicAreaM49","timePointYears","measuredItemCPC","feedValue"))

selectedProteinSupply$flagObservationStatus_measuredElement_5520 = 
  rep("E",length(selectedProteinSupply$feedValue))


selectedProteinSupply$flagMethod_measuredElement_5520 = 
  rep("b",length(selectedProteinSupply$feedValue))



selectedDemandSupply = demandSupply %>%
  select(geographicAreaM49,timePointYears,measuredItemCPC,feed)

setnames(selectedDemandSupply,c("geographicAreaM49","timePointYears","measuredItemCPC","feedValue"))


selectedDemandSupply$flagObservationStatus_measuredElement_5520 = 
  rep("E",length(selectedDemandSupply$feedValue))


selectedDemandSupply$flagMethod_measuredElement_5520 = 
  rep("e",length(selectedDemandSupply$feedValue))



generatedFeedData = rbind(selectedOfficialNutrientsData,selectedProteinSupply,selectedDemandSupply)


# To compare the data on SWS and the estimates from the model
# feedData$geographicAreaM49 = faoswsUtil::fs2m49(feedData$geographicAreaFS)
# 
# aa = feedData$measuredItemFS[1:16]
# aa = paste("00",aa,sep="")
# bb = feedData$measuredItemFS[17:60]
# bb = paste("0",bb,sep="")
# feedData$measuredItemFS = c(aa,bb,as.character(feedData$measuredItemFS[61]))
# feedData$measuredItemCPC = faoswsUtil::fcl2cpc(feedData$measuredItemFS)
# 
# pippo = feedData %>%
#   select(measuredItemCPC,feedValue,feedFlag)
# 
# pippa = generatedFeedData %>%
#   select(measuredItemCPC,feedValue)
# 
# setnames(pippa, c("measuredItemCPC","feedValueNew"))  
# 
# ffff = merge(pippo , pippa,
#              by = "measuredItemCPC",
#              all = TRUE)
# ffff [,discr := feedValue - feedValueNew]  


feedEstimates = generatedFeedData

setnames(feedEstimates,c("geographicAreaM49","timePointYears","measuredItemCPC","Value_measuredElement_5520",
                         "flagObservationStatus_measuredElement_5520","flagMethod_measuredElement_5520"))

if (Sys.info()[7] == "Golini"){
  save(feedEstimates, file = "C:/Users/Golini/Documents/Github/privateFAO/OrangeBook/feedEstimates.RData")
} else {
  stop("Need path for this user!")
}

