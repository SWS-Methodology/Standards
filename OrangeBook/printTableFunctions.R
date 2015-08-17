## Rounding numbers for display
roundNum = function(x){
    initialSign = sign(x)
    x = abs(x)
    # 1 or 2 digits: multiple of 5.
    # 3 digits: multiple of 10.
    # 4 to 7 digits: multiple of 100
    # 8+ digits: 4 significant digits.
    if(is.na(x)){
        return(x)
    } else if(x < 100){
        x = round(x/5, 0)*5
    } else if(x < 1000){
        x = round(x/10)*10
    } else if(x < 10000000){
        x = round(x/100)*100
    } else {
        x = formatC(x, digits = 4)
        x = as.numeric(x)
    }
    x = x * initialSign
    x = formatC(x, big.mark = ",", format = "s")
    return(x)
}

## Function for printing the main table
printTable = function(data, standParams, workingDir){
    printDT = copy(data)
    if(!"updateFlag" %in% colnames(printDT)){
        printDT[, updateFlag := FALSE]
    }
    printDT = printDT[, c(standParams$mergeKey, "element", "Value", "updateFlag"),
                      with = FALSE]
    printDT[, element := paste0("Value_measuredElement_", element)]
    printDT[, Value := sapply(Value, roundNum)]
    
    ## Don't print some elements
    skippedElements = c(24110, 2413, 23210.05, 24490.92)
    printDT = printDT[!get(standParams$itemVar) %in% skippedElements, ]
    
    fbsElements = c(standParams$productionCode, standParams$feedCode,
                    standParams$seedCode, standParams$wasteCode,
                    standParams$foodCode, standParams$stockCode,
                    standParams$importCode, standParams$exportCode,
                    standParams$foodProcCode, standParams$industrialCode,
                    standParams$touristCode)

    ## Add bold style to updated values, round to no decimals, NA to "-"
    printDT[, Value := as.character(round(as.numeric(Value), 0))]
    printDT[is.na(Value), Value := "-"]
    if("updateFlag" %in% colnames(printDT)){
        printDT[(updateFlag), Value := paste0("**", Value, "**")]
        printDT[, updateFlag := NULL]
    }
    printDT = tidyr::spread(data = printDT, key = "element", value = "Value",
                            fill = NA)
    setnames(printDT, paste0("Value_measuredElement_", fbsElements),
             c("Production", "Feed", "Seed", "Loss",
               "Food", "StockChange", "Imports", "Exports",
               "Food Processing", "Industrial", "Tourist"))
    setnames(printDT, "measuredItemCPC", "Item")

    description = fread(paste0(workingDir, "/elementDescription.csv"),
                            colClasses = c("character", "character"))
    printDT = merge(printDT, description, by = "Item")

    items = c("Name", "Production", "Imports", "Exports", "StockChange",
              "Food", "Food Processing", "Feed", "Seed", "Tourist",
              "Industrial", "Loss")
    sapply(items, function(colName){
        if(!colName %in% colnames(printDT)){
            printDT[, c(colName) := 0]
        } else {
            printDT[is.na(get(colName)), c(colName) := "-"]
        }
    })
    out = knitr::kable(printDT[, items, with = FALSE], align = 'r')
    return(out)
}

## Function for printing area harvested/yield/production
printProductionTable = function(data, standParams, workingDir){
    printDT = copy(data)
    printDT = printDT[, c(standParams$mergeKey, "element", "Value"),
                      with = FALSE]
    ## Round to 0 or 4 (yield only) decimals
    printDT[element == standParams$yieldCode, Value := round(Value, 4)]
    printDT[element != standParams$yieldCode, Value := sapply(Value, roundNum)]
    printDT[, element := paste0("Value_measuredElement_", element)]
    printDT = tidyr::spread(data = printDT, key = "element", value = "Value")
    
    ## Bring in item names
    description = fread(paste0(workingDir, "/elementDescription.csv"),
                            colClasses = c("character", "character"))
    setnames(printDT, paste0("Value_measuredElement_", c(standParams$areaHarvCode,
                                                         standParams$productionCode,
                                                         standParams$yieldCode)),
             c("Area Harvested (hectare)", "Production (tonnes)", "Yield (tonnes/hectare"))
    setnames(printDT, "measuredItemCPC", "Item")
    printDT = merge(printDT, description, by = "Item")

    items = c("Name", "Area Harvested", "Yield", "Production")
    sapply(items, function(colName){
        if(!colName %in% colnames(printDT)){
            printDT[, c(colName) := 0]
        }
    })
    out = knitr::kable(printDT[, items, with = FALSE])
    return(out)
}

## Function printing expected value and standard error for the primary product
printDistributionTable = function(data, standParams){
    printMean = copy(data)
    printMean = printMean[, c(standParams$mergeKey, "element", "Value"),
                      with = FALSE]
    printMean[, Value := sapply(Value, roundNum)]
    printMean[, element := paste0("Value_measuredElement_", element)]
    printMean[is.na(Value), Value := 0]
    printMean = tidyr::spread(data = printMean, key = "element", value = "Value")
    ## On some occassions, a strange error happens here which introduces a row
    ## of NA's.  Just delete that row:
    printMean = printMean[!is.na(get(standParams$itemVar)), ]
    
    printSd = copy(data)
    printSd[, Value := sapply(Value, roundNum)]
    printSd = printSd[, c(standParams$mergeKey, "element", "standardDeviation"),
                      with = FALSE]
    printSd[, element := paste0("Value_measuredElement_", element)]
    printSd[, standardDeviation := round(standardDeviation)]
    printSd = tidyr::spread(data = printSd, key = "element", value = "standardDeviation")
    ## On some occassions, a strange error happens here which introduces a row
    ## of NA's.  Just delete that row:
    printSd = printSd[!is.na(get(standParams$itemVar)), ]
    
    printDT = rbind(printMean, printSd)
    printDT[, Variable := c("Mean", "Standard Dev.")]
    
    fbsElements = c(standParams$productionCode, standParams$feedCode,
                    standParams$seedCode, standParams$wasteCode,
                    standParams$foodCode, standParams$stockCode,
                    standParams$importCode, standParams$exportCode,
                    standParams$foodProcCode, standParams$industrialCode,
                    standParams$touristCode)
    
    setnames(printDT, paste0("Value_measuredElement_", fbsElements),
             c("Production", "Feed", "Seed", "Waste", "Food",
               "StockChange", "Imports", "Exports", "Food Processing",
               "Industrial", "Tourist"))
    setnames(printDT, "measuredItemCPC", "Item")

    items = c("Variable", "Production", "Imports", "Exports", "StockChange",
              "Food", "Food Processing", "Feed", "Waste", "Seed", "Industrial",
              "Tourist")
    sapply(items, function(colName){
        if(!colName %in% colnames(printDT)){
            printDT[, c(colName) := 0]
        }
    })
    out = knitr::kable(printDT[, items, with = FALSE])
    
    return(out)
}

## Function for printing the table which shows how an aggregate distribution
## gets calculated (during standardization).
printStandardizationTable = function(data, standParams, workingDir){
    printDT = copy(data)
    printDT = data.frame(printDT)
    printDT[, sapply(printDT, is.numeric)] =
        apply(printDT[, sapply(printDT, is.numeric)], c(1,2), roundNum)
    printDT = data.table(printDT)
    
    ## Bring in item names
    description = fread(paste0(workingDir, "/elementDescription.csv"),
                            colClasses = c("character", "character"))
    printDT = merge(printDT, description, by = "Item")
    
    if("adjustment" %in% colnames(printDT)){
        setnames(printDT, c("prodMean", "prodSd", "wheatMean",
                            "wheatSd", "adjustment"),
                 c("Production (processed)", "SD(Production)",
                   "Wheat Equivalent", "SD(Wheat Equivalent)", "Adjustment"))
        
        return(knitr::kable(printDT[, c("Name", "Production (processed)",
                                        "SD(Production)", "Wheat Equivalent",
                                        "SD(Wheat Equivalent)", "Adjustment"),
                                    with = FALSE], digits = 0))
    } else {
        setnames(printDT, c("prodMean", "prodSd", "wheatMean", "wheatSd"),
                 c("Production (processed)", "SD(Production)",
                   "Wheat Equivalent", "SD(Wheat Equivalent)"))
        
        return(knitr::kable(printDT[, c("Name", "Production (processed)",
                                        "SD(Production)", "Wheat Equivalent",
                                        "SD(Wheat Equivalent)"),
                                    with = FALSE], digits = 0))
    }
}