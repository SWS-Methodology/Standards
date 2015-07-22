library(faosws)
library(faoswsUtil)
library(lme4)
library(data.table)
library(magrittr)
library(reshape2)
library(igraph)

buildModel = FALSE
wheatKeys = c("0111", "23110", "23140.01", "23140.02", "23140.03", "23220.01",
              "23220.02", "23490.02", "23710", "39120.01", "F0020", "F0022")
cattleKeys = c("21111.01", "21111.02", "21182", "21184.01", "21185",
               "21512.01", "23991.04", "F0875")
palmOilKeys = c("01491.02", "2165", "21691.14", "21910.06", "21700.01",
                "21700.02", "F1243", "34550", "F1275", "34120")
sugarKeys = c("01802", "23512", "F7156", "23210.04", "2351", "23511", "23520",
              "23540", "23670.01", "24110", "2413", "24131", "24139",
              "24490.92", "39140.02", "F7157", "01801", "39140.01", "F7161",
              "01809", "F7162", "F7163")
areaCodesM49 <- "840"

selectedYear = as.character(1990:2011)
areaVar = "geographicAreaM49"
yearVar = "timePointYears"
itemVar = "measuredItemSuaFbs"
itemAgVar = "measuredItemCPC"
elementVar = "measuredElementSuaFbs"
elementAgVar = "measuredElement"
valuePrefix = "Value_"
flagObsPrefix = "flagObservationStatus_"
flagMethodPrefix = "flagMethod_"

if(Sys.info()[7] == "rockc_000"){
    lossModelPath = "//hqlprsws1.hq.un.fao.org/sws_r_share/browningj/loss/lossModel.RData"
} else if(Sys.info()[7] == "josh"){
    lossModelPath = "/media/hqlprsws1_qa/browningj/loss/lossModel.RData"
} else if(Sys.info()[7] == "Golini"){
  lossModelPath = "//hqlprsws1.hq.un.fao.org/sws_r_share/browningj/loss/lossModel.RData"
} else {
    stop("Need lossModelPath for this user!")
}


GetTestEnvironment(
    baseUrl = "https://hqlqasws1.hq.un.fao.org:8181/sws",
    token = "7fe7cbec-2346-46de-9a3a-8437eca18e2a"
#     baseUrl = "https://hqlprswsas1.hq.un.fao.org:8181/sws",
#     token = "d0e1f76f-61a6-4183-981c-d0fec7ac1845" # Josh's token
)

## Function to obtain all CPC item 
getAllItemCPC = function(){
    itemEdgeList =
        adjacent2edge(
            GetCodeTree(domain = "agriculture",
                        dataset = "agriculture",
                        dimension = itemAgVar)
        )
    itemEdgeGraph = graph.data.frame(itemEdgeList)
    itemDist = shortest.paths(itemEdgeGraph, v = "0", mode = "out")
    fbsItemCodes = colnames(itemDist)[is.finite(itemDist)]
    fbsItemCodes
}


getProductionData = function(){
    allCountries =
        GetCodeList(domain = "agriculture",
                    dataset = "agriculture",
                    dimension = areaVar)[type == "country", code]
    
    productionKey = DatasetKey(
        domain = "agriculture",
        dataset = "agriculture",
        dimensions = list(
            Dimension(name = areaVar,
                      keys = allCountries),
            Dimension(name = elementAgVar,
                      keys = "5510"),
            Dimension(name = itemAgVar,
                      keys = requiredItems),
            Dimension(name = yearVar,
                      keys = selectedYear)
        )
    )

    ## Pivot to vectorize yield computation
    productionPivot = c(
        Pivoting(code = areaVar, ascending = TRUE),
        Pivoting(code = itemAgVar, ascending = TRUE),
        Pivoting(code = yearVar, ascending = FALSE),
        Pivoting(code = elementAgVar, ascending = TRUE)
    )

    ## Query the data
    productionQuery = GetData(
        key = productionKey,
        flags = TRUE,
        normalized = FALSE,
        pivoting = productionPivot
    )

    ## Convert time to numeric
    productionQuery[, timePointYears := as.numeric(timePointYears)]
    productionQuery

}

getImportData = function(){
    allCountries =
        GetCodeList(domain = "trade",
                    dataset = "total_trade_CPC",
                    dimension = areaVar)[type == "country", code]

    importKey = DatasetKey(
        domain = "trade",
        dataset = "total_trade_CPC",
        dimensions = list(
            Dimension(name = areaVar,
                      keys = allCountries),
            Dimension(name = "measuredElementTrade",
                      keys = "5600"),
            Dimension(name = itemAgVar,
                      keys = requiredItems),
            Dimension(name = yearVar,
                      keys = selectedYear)
        )
    )

    ## Pivot to vectorize yield computation
    importPivot = c(
        Pivoting(code = areaVar, ascending = TRUE),
        Pivoting(code = itemAgVar, ascending = TRUE),
        Pivoting(code = yearVar, ascending = FALSE),
        Pivoting(code = "measuredElementTrade", ascending = TRUE)
    )

    ## Query the data
    importQuery = GetData(
        key = importKey,
        flags = TRUE,
        normalized = FALSE,
        pivoting = importPivot
    )

    ## NOTE (Michael): The unit for trade is in kg while for other
    ##                 elements are tonnes, so we divide the trade by
    ##                 1000 to match the unit.
    importQuery[, Value_measuredElementTrade_5600 :=
                   computeRatio(Value_measuredElementTrade_5600, 1000)]
    
    setnames(importQuery,
             old = grep("measuredElementTrade",
                 colnames(importQuery), value = TRUE),
             new = gsub("measuredElementTrade", "measuredElement",
                 grep("measuredElementTrade",
                      colnames(importQuery), value = TRUE)))


    ## Convert time to numeric
    importQuery[, timePointYears := as.numeric(timePointYears)]
    importQuery

}




getOfficialLossData = function(){
    allCountries =
        GetCodeList(domain = "lossWaste",
                    dataset = "loss",
                    dimension = areaVar)[type == "country", code]

    ## HACK (Michael): This is a hack, beacause the item hierachy
    ##                 configuration is different in the loss data set
    getLossItemCPC = function(){
        itemEdgeList =
            adjacent2edge(
                GetCodeTree(domain = "lossWaste",
                            dataset = "loss",
                            dimension = itemVar)
            )
        itemEdgeGraph = graph.data.frame(itemEdgeList)
        itemDist = shortest.paths(itemEdgeGraph, v = "0", mode = "out")
        fbsItemCodes = colnames(itemDist)[is.finite(itemDist)]
        fbsItemCodes
    }

    lossItems = getLossItemCPC()
   
    
    ## NOTE (Michael): The cpc tree loaded in the loss data set is
    ##                 different to the rest. Thus I can not query
    ##                 item such as 0419.

    lossKey = DatasetKey(
        domain = "lossWaste",
        dataset = "loss",
        dimensions = list(
            Dimension(name = areaVar,
                      keys = allCountries),
            Dimension(name = elementVar,
                      keys = "5120"),
            Dimension(name = itemVar,
                      keys = lossItems),
            Dimension(name = yearVar,
                      keys = selectedYear)
        )
    )

    ## Pivot to vectorize yield computation
    lossPivot = c(
        Pivoting(code = areaVar, ascending = TRUE),
        Pivoting(code = itemVar, ascending = TRUE),
        Pivoting(code = yearVar, ascending = FALSE),
        Pivoting(code = elementVar, ascending = TRUE)
    )

    ## Query the data
    lossQuery = GetData(
        key = lossKey,
        flags = TRUE,
        normalized = FALSE,
        pivoting = lossPivot
    )

    setnames(lossQuery,
             old = grep(elementVar,
                 colnames(lossQuery), value = TRUE),
             new = gsub(elementVar, "measuredElement",
                 grep(elementVar,
                      colnames(lossQuery), value = TRUE)))
    setnames(lossQuery,
             old = itemVar,
             new = itemAgVar)


    ## Convert time to numeric
    lossQuery[, timePointYears := as.numeric(timePointYears)]
    lossQuery[flagObservationStatus_measuredElement_5120 == "", ]
}

getSelectedLossData = function(){

    
    ## Pivot to vectorize yield computation
    lossPivot = c(
        Pivoting(code = areaVar, ascending = TRUE),
        Pivoting(code = itemVar, ascending = TRUE),
        Pivoting(code = yearVar, ascending = FALSE),
        Pivoting(code = elementVar, ascending = TRUE)
    )

    ## Query the data
    lossQuery = GetData(
        key = swsContext.datasets[[1]],
        normalized = FALSE,
        pivoting = lossPivot
    )

    setnames(lossQuery,
             old = grep(elementVar,
                 colnames(lossQuery), value = TRUE),
             new = gsub(elementVar, "measuredElement",
                 grep(elementVar,
                      colnames(lossQuery), value = TRUE)))
    setnames(lossQuery,
             old = itemVar,
             new = itemAgVar)

    ## Convert time to numeric
    lossQuery[, timePointYears := as.numeric(timePointYears)]
    lossQuery
}


##' The above getSelectedLossData function only pulls in loss observations that
##' are available.  Clearly that's not right: we want to estimate loss for all
##' missing values, not just ones where we currently have estimates.
getSelectedLossData = function(){

    dimensions = lapply(swsContext.datasets[[1]]@dimensions, function(x){
        out = data.table(mergeKey = 1, value = x@keys)
        setnames(out, "value", x@name)
    })
    lossQuery = merge(dimensions[[1]], dimensions[[4]], by = "mergeKey")
    lossQuery = merge(lossQuery, dimensions[[2]], by = "mergeKey")
    lossQuery[, mergeKey := NULL]
    lossQuery[, Value_measuredElement_5120 := 0]
    lossQuery[, flagObservationStatus_measuredElement_5120 := "M"]
    lossQuery[, flagMethod_measuredElement_5120 := "u"]

    setnames(lossQuery,
             old = grep(elementVar,
                 colnames(lossQuery), value = TRUE),
             new = gsub(elementVar, "measuredElement",
                 grep(elementVar,
                      colnames(lossQuery), value = TRUE)))
    setnames(lossQuery,
             old = itemVar,
             new = itemAgVar)

    ## Convert time to numeric
    lossQuery[, timePointYears := as.numeric(timePointYears)]
    lossQuery
}



getLossWorldBankData = function(){
    allCountries =
        GetCodeList(domain = "WorldBank",
                    dataset = "wb_ecogrw",
                    dimension = areaVar)[type == "country", code]
   
    infrastructureKey =
        DatasetKey(domain = "WorldBank",
                   dataset = "wb_infrastructure",
                   dimensions =
                       list(
                           Dimension(name = areaVar,
                                     keys = allCountries),
                           Dimension(name = "wbIndicator",
                                     keys = "IS.ROD.PAVE.ZS"),
                           Dimension(name = yearVar,
                                     keys = selectedYear)
                       )
                   )
    
    gdpKey =
        DatasetKey(domain = "WorldBank",
                   dataset = "wb_ecogrw",
                   dimensions =
                       list(
                           Dimension(name = areaVar,
                                     keys = allCountries),
                           Dimension(name = "wbIndicator",
                                     keys = c("NY.GDP.MKTP.PP.KD",
                                         "NY.GDP.PCAP.KD")),
                           Dimension(name = yearVar,
                                     keys = selectedYear)
                       )
                   )

    newPivot = c(
        Pivoting(code = areaVar, ascending = TRUE),
        Pivoting(code = "wbIndicator", ascending = TRUE),
        Pivoting(code = yearVar, ascending = FALSE)
    )

    base =
        data.table(geographicAreaM49 = character(),
                   wbIndicator = character(),
                   timePointYears = character(),
                   Value = numeric())

    merged =
        Reduce(f = function(base, key){
            rbind(base, GetData(key, pivoting = newPivot))
        }, x = list(infrastructureKey, gdpKey), init = base)
    
    casted =
        dcast.data.table(merged,
                         geographicAreaM49 + timePointYears ~ wbIndicator,
                         value.var = "Value")
    setnames(casted,
             old = c("IS.ROD.PAVE.ZS", "NY.GDP.MKTP.PP.KD",
                 "NY.GDP.PCAP.KD"),
             new = c("sharePavedRoad", "gdpPPP", "gdpPerCapita"))
    casted[, timePointYears := as.numeric(timePointYears)]
    setkeyv(casted, cols = c(areaVar, yearVar))
    casted
}


## Function to load the loss food group classification
getLossFoodGroup = function(){
    lossFoodGroup = GetTableData(schemaName = "ess", tableName = "loss_food_group")
    setnames(lossFoodGroup, old = colnames(lossFoodGroup),
             new = c("measuredItemFS", "measuredItemNameFS", "foodGroupName",
                 "foodGroup", "foodGeneralGroup", "foodPerishableGroup",
                 "measuredItemCPC"))
    lossFoodGroup[, list(measuredItemCPC, foodGroupName,
                         foodGeneralGroup, foodPerishableGroup)]
    lossFoodGroup
}

## Function to load the loss region classification
getLossRegionClass = function(){
    regionMapping =
        GetTableData(schemaName = "ess", tableName = "loss_region_mapping")
    setnames(regionMapping, old = colnames(regionMapping),
             new = c("geographicAreaM49", "lossRegionClass"))    
    regionMapping
}


imputeSharePavedRoad = function(wbData, pavedRoadVar){
    foo = function(x){
        if(length(na.omit(x)) >= 2){
            tmp = na.locf(na.approx(x, na.rm = FALSE), na.rm = FALSE)
        } else {
            tmp = x
        }
        tmp
    }
    wbData[, `:=`(c(pavedRoadVar),
                  foo(.SD[[pavedRoadVar]])),
         by = "geographicAreaM49"]
}

mergeAllLossData = function(lossData, ...){
    explanatoryData = list(...)
    Reduce(f = function(x, y){
        keys = intersect(colnames(x), colnames(y))
        setkeyv(x, keys)
        setkeyv(y, keys)
        merge(x, y, all.x = TRUE)
    },
           x = explanatoryData, init = lossData
           )
}


removeCarryLoss = function(data, lossVar){
    data[, variance := var(.SD[[lossVar]], na.rm = TRUE),
         by = c("geographicAreaM49", "measuredItemCPC")]
    data[, duplicateValue := duplicated(.SD[[lossVar]]),
         by = c("geographicAreaM49", "measuredItemCPC")]
    data = data[!(variance == 0 & duplicateValue), ]
    data[, `:=`(c("variance", "duplicateValue"), NULL)]
    data         
}

imputeLoss = function(data, lossVar, lossObservationFlagVar, lossMethodFlagVar,
    lossModel, lossVarModel){
    imputedData = copy(data)
    imputedData[, lossPredicted := exp(predict(lossModel, newdata = imputedData,
                                allow.new.levels = TRUE))]
    imputedData[(is.na(imputedData[[lossVar]]) |
                 imputedData[[lossObservationFlagVar]] %in% c("E", "I", "T", "M")) &
                !is.na(lossPredicted),
                `:=`(c(lossVar, lossObservationFlagVar, lossMethodFlagVar),
                     list(lossPredicted, "I", "e"))]
    imputedData[, lossPredicted := NULL]
    
    imputedData[, lossVariance := apply(lossLmeVariance$t, 2, sd)]
    
    imputedData
}

swsContext.datasets = list()
swsContext.datasets[[1]] = DatasetKey(
    domain = "agriculture",
    dataset = "agriculture",
    dimensions =
        list(Dimension(name = areaVar, keys = "840"),
             Dimension(name = yearVar, keys = as.character(2011)),
             Dimension(name = elementVar, keys = "5120"),
             Dimension(name = itemVar, keys = c(wheatKeys, cattleKeys,
                                                palmOilKeys, sugarKeys))
    ))


###############################################################################
## Build Model
###############################################################################

if(buildModel){
    finalModelData = 
        {
            requiredItems <<- getAllItemCPC()
            production <<- getProductionData()
            import <<- getImportData()
            loss <<- getOfficialLossData()
            ## NOTE (Michael): Don't really need world bank data, as those
            ##                 variables does not aid to the model
            ##
            ## wb <<- getLossWorldBankData()
            lossFoodGroup <<- getLossFoodGroup()
            lossRegionClass <<- getLossRegionClass()
            countryTable <<-
                GetCodeList(domain = "agriculture",
                            dataset = "agriculture",
                            dimension = areaVar)[type == "country",
                                list(code, description)]
            setnames(countryTable,
                     old = c("code", "description"),
                     new = c(areaVar, "geographicAreaM49Name"))
        } %>%
        mergeAllLossData(lossData = loss,
                         production, import, lossFoodGroup,
                         lossRegionClass, countryTable) %>%
        subset(x = .,
               subset = Value_measuredElement_5120 > 0 &
                        foodGeneralGroup == "primary" &
                        Value_measuredElement_5510 != 0,
               select = c("geographicAreaM49", "geographicAreaM49Name",
                   "measuredItemCPC", "timePointYears",
                   "Value_measuredElement_5120", "Value_measuredElement_5510",
                   "Value_measuredElement_5600", "foodGroupName",
                   "foodPerishableGroup", "lossRegionClass")) %>%
        removeCarryLoss(data = ., lossVar = "Value_measuredElement_5120") %>%
        ## Convert variables to factor
        .[, `:=`(c("measuredItemCPC", "foodGroupName", 
                   "foodPerishableGroup", "lossRegionClass"),
                 lapply(c("measuredItemCPC", "foodGroupName", 
                          "foodPerishableGroup", "lossRegionClass"),
                        FUN = function(x) as.factor(.SD[[x]])
                        )
                 )
          ]
    
    ## NOTE (Michael): Here we have not yet added in import yet, since
    ##                 there are only data for 2010. However, import
    ##                 should be added when it is available.
    
    ## lossLmeModel =
    ##     lmer(log(Value_measuredElement_5120) ~ -1 + timePointYears +
    ##          log(Value_measuredElement_5510 + 1) + 
    ##          (log(Value_measuredElement_5510 + 1)|
    ##               lossRegionClass/geographicAreaM49Name:
    ##                   foodPerishableGroup/foodGroupName/measuredItemCPC),
    ##          data = finalModelData)
    
    lossLmeModel =
        lmer(log(Value_measuredElement_5120) ~ timePointYears +
             log(Value_measuredElement_5510 + 1) + 
             (-1 + log(Value_measuredElement_5510 + 1)|
                  foodPerishableGroup/foodGroupName/measuredItemCPC/geographicAreaM49Name),
             data = finalModelData)
    
    lossLmeVariance = bootMer(lossLmeModel,
                              FUN = function(lossLmeModel) predict(lossLmeModel),
                              nsim = 2)
        
    save(c(lossLmeModel,lossLmeVariance), file = lossModelPath)
} else {
    load(lossModelPath)
}


###############################################################################
## Predict with model
###############################################################################

finalPredictData = 
    {
        requiredItems <<- c(wheatKeys, cattleKeys, palmOilKeys, sugarKeys)
        production <<- getProductionData()
        import <<- getImportData()
        lossFoodGroup <<- getLossFoodGroup()
        lossRegionClass <<- getLossRegionClass()
        countryTable <<-
            GetCodeList(domain = "agriculture",
                        dataset = "agriculture",
                        dimension = "geographicAreaM49")[type == "country",
                            list(code, description)]
        setnames(countryTable,
                 old = c("code", "description"),
                 new = c("geographicAreaM49", "geographicAreaM49Name"))
        loss <<- getSelectedLossData()
    } %>%
    mergeAllLossData(lossData = loss,
                     production, import, lossFoodGroup,
                     lossRegionClass, countryTable) %>%
    subset(x = .,
           ## Why these filters??  The first prevents missing values from ever
           ## being imputed.
           subset = #Value_measuredElement_5120 > 0 &
                    foodGeneralGroup == "primary",
                    #Value_measuredElement_5510 != 0,
           select = c("geographicAreaM49", "geographicAreaM49Name",
               "measuredItemCPC", "timePointYears", "Value_measuredElement_5120",
               "flagObservationStatus_measuredElement_5120",
               "flagMethod_measuredElement_5120",
               "Value_measuredElement_5510", "Value_measuredElement_5600",
               "foodGroupName", "foodPerishableGroup", "lossRegionClass")) %>%
    removeCarryLoss(data = ., lossVar = "Value_measuredElement_5120") %>%
    ## Convert variables to factor
    .[, `:=`(c("measuredItemCPC", "foodGroupName", 
               "foodPerishableGroup", "lossRegionClass"),
             lapply(c("measuredItemCPC", "foodGroupName", 
                      "foodPerishableGroup", "lossRegionClass"),
                    FUN = function(x) as.factor(.SD[[x]])
                    )
             )
      ]


## Impute selected data
finalPredictData = imputeLoss(data = finalPredictData,
   lossVar = "Value_measuredElement_5120",
   lossObservationFlagVar =
       "flagObservationStatus_measuredElement_5120",
   lossMethodFlagVar = "flagMethod_measuredElement_5120",
   lossModel = lossLmeModel,
   lossVarModel = lossLmeVariance)
lossEstimates = finalPredictData
lossEstimates[, timePointYears := as.character(timePointYears)]

if(Sys.info()[7] == "rockc_000"){
    save(lossEstimates, file = "~/GitHub/privateFAO/OrangeBook/lossEstimates.RData")
} else if(Sys.info()[7] == "josh"){
    save(lossEstimates, file = "~/Documents/Github/privateFAO/OrangeBook/lossEstimates.RData")
} else if(Sys.info()[7] == "Golini"){
  save(lossEstimates, file = "C:/Users/Golini/Documents/Github/privateFAO/OrangeBook/lossEstimates_Nata.RData")
} else {
    stop("Need path for this user!")
}