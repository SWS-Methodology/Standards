## Function for printing the main table
printTable = function(data, standParams){
    printDT = copy(data)
    if(!"updateFlag" %in% colnames(printDT)){
        printDT[, updateFlag := FALSE]
    }
    printDT = printDT[, c(standParams$mergeKey, "element", "Value", "updateFlag"),
                      with = FALSE]
    printDT[, element := paste0("Value_measuredElement_", element)]
    
    fbsElements = c(standParams$productionCode, standParams$feedCode,
                    standParams$seedCode, standParams$wasteCode,
                    standParams$foodCode, standParams$stockCode,
                    standParams$importCode, standParams$exportCode,
                    standParams$foodProcCode)

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
             c("Production", "Feed", "Seed", "Waste",
               "Food", "StockChange", "Imports", "Exports",
               "Food Processing"))
    setnames(printDT, "measuredItemCPC", "Item")

    if(Sys.info()[7] == "josh"){ # Josh Work
        description = fread("~/Documents/Github/privateFAO/OrangeBook/elementDescription.csv")
    } else if(Sys.info()[7] %in% c("browningj", "rockc_000")){ # Josh virtual & home
        description = fread("~/GitHub/privateFAO/OrangeBook/elementDescription.csv")
    } else {
        stop("No working dir for current user!")
    }
    printDT = merge(printDT, description, by = "Item")

    items = c("Name", "Production", "Imports", "Exports", "StockChange",
              "Food", "Food Processing", "Feed", "Waste", "Seed", "Industrial",
              "Tourist", "Residual")
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
printProductionTable = function(data, standParams){
    printDT = copy(data)
    printDT = printDT[, c(standParams$mergeKey, "element", "Value"),
                      with = FALSE]
    ## Round to 0 or 4 (yield only) decimals
    printDT[element == standParams$yieldCode, Value := round(Value, 4)]
    printDT[element != standParams$yieldCode, Value := round(Value, 0)]
    printDT[, element := paste0("Value_measuredElement_", element)]
    printDT = tidyr::spread(data = printDT, key = "element", value = "Value")
    
    ## Bring in item names
    if(Sys.info()[7] == "josh"){ # Josh Work
        description = fread("~/Documents/Github/privateFAO/OrangeBook/elementDescription.csv")
    } else if(Sys.info()[7] %in% c("browningj", "rockc_000")){ # Josh virtual & home
        description = fread("~/GitHub/privateFAO/OrangeBook/elementDescription.csv")
    } else {
        stop("No working dir for current user!")
    }
    setnames(printDT, paste0("Value_measuredElement_", c(standParams$areaHarvCode,
                                                         standParams$productionCode,
                                                         standParams$yieldCode)),
             c("Area Harvested", "Production", "Yield"))
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
    printMean[, element := paste0("Value_measuredElement_", element)]
    printMean[, Value := round(Value)]
    printMean = tidyr::spread(data = printMean, key = "element", value = "Value")
    
    printSd = copy(data)
    printSd = printSd[, c(standParams$mergeKey, "element", "standardDeviation"),
                      with = FALSE]
    printSd[, element := paste0("Value_measuredElement_", element)]
    printSd[, standardDeviation := round(standardDeviation)]
    printSd = tidyr::spread(data = printSd, key = "element", value = "standardDeviation")
    
    printDT = rbind(printMean, printSd)
    printDT[, Variable := c("Mean", "Standard Dev.")]
    
    fbsElements = c(standParams$productionCode, standParams$feedCode,
                    standParams$seedCode, standParams$wasteCode,
                    standParams$foodCode, standParams$stockCode,
                    standParams$importCode, standParams$exportCode,
                    standParams$foodProcCode)
    
    setnames(printDT, paste0("Value_measuredElement_", fbsElements),
             c("Production", "Feed", "Seed", "Waste", "Food",
               "StockChange", "Imports", "Exports", "Food Processing"))
    setnames(printDT, "measuredItemCPC", "Item")

    items = c("Variable", "Production", "Imports", "Exports", "StockChange",
              "Food", "Food Processing", "Feed", "Waste", "Seed", "Industrial",
              "Tourist", "Residual")
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
printStandardizationTable = function(data, standParams){
    printDT = copy(data)
    
    ## Bring in item names
    if(Sys.info()[7] == "josh"){ # Josh Work
        description = fread("~/Documents/Github/privateFAO/OrangeBook/elementDescription.csv")
    } else if(Sys.info()[7] %in% c("browningj", "rockc_000")){ # Josh virtual & home
        description = fread("~/GitHub/privateFAO/OrangeBook/elementDescription.csv")
    } else {
        stop("No working dir for current user!")
    }
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