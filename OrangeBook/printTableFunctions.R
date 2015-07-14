## Function for printing the main table
printTable = function(data){
    printDT = copy(data)
    printDT[, c("metFlag", "obsFlag", "standardDeviation") := NULL]
    printDT[, element := paste0("Value_measuredElement_", element)]
    ## Add bold style to updated values, round to no decimals
    printDT[, Value := as.character(round(as.numeric(Value), 0))]
    if("updateFlag" %in% colnames(printDT)){
        printDT[(updateFlag), Value := paste0("**", Value, "**")]
        printDT[, updateFlag := NULL]
    }
    printDT = tidyr::spread(data = printDT, key = "element", value = "Value")
    setnames(printDT, paste0("Value_measuredElement_", fbsElements),
             c("OpeningStock", "AreaSown", "AreaHarv", "Production",
               "Input", "Yield", "Feed", "Seed", "Waste", "Processed", "Food",
               "StockChange", "Imports", "Exports"))
    setnames(printDT, "measuredItemCPC", "Item")

    if(Sys.getenv("USER") == "josh"){ # Josh Work
        description = fread("~/Documents/Github/privateFAO/OrangeBook/elementDescription.csv")
    } else if(Sys.getenv("USER") %in% c("browningj", "rockc_000")){ # Josh virtual & home
        description = fread("~/GitHub/privateFAO/OrangeBook/elementDescription.csv")
    } else {
        stop("No working dir for current user!")
    }
    printDT = merge(printDT, description, by = "Item")

    items = c("Name", "Production", "Imports", "Exports",
              "StockChange", "Food", "Feed", "Waste", "Seed", "Industrial",
              "Tourist", "Residual")
    sapply(items, function(colName){
        if(!colName %in% colnames(printDT)){
            printDT[, c(colName) := 0]
        }
    })
    out = knitr::kable(printDT[, items, with = FALSE])
    
    ## Trying to get bold to work with kable:
    out[1] = gsub("|Name", "|**Name**", out[1], fixed = TRUE)
    return(out)
}

## Function for printing area harvested/yield/production
printProductionTable = function(data){
    printDT = copy(data)
    printDT[, c("metFlag", "obsFlag") := NULL]
    printDT[, element := paste0("Value_measuredElement_", element)]
    printDT = tidyr::spread(data = printDT, key = "element", value = "Value")
    
    ## Bring in item names
    if(Sys.getenv("USER") == "josh"){ # Josh Work
        description = fread("~/Documents/Github/privateFAO/OrangeBook/elementDescription.csv")
    } else if(Sys.getenv("USER") %in% c("browningj", "rockc_000")){ # Josh virtual & home
        description = fread("~/GitHub/privateFAO/OrangeBook/elementDescription.csv")
    } else {
        stop("No working dir for current user!")
    }
    setnames(printDT, paste0("Value_measuredElement_", c(5312, 5510, 5421)),
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
printDistributionTable = function(data){
    printMean = copy(data)
    printMean[, c("metFlag", "obsFlag", "standardDeviation") := NULL]
    printMean[, element := paste0("Value_measuredElement_", element)]
    printMean = tidyr::spread(data = printMean, key = "element", value = "Value")
    
    printSd = copy(data)
    printSd[, c("metFlag", "obsFlag", "Value") := NULL]
    printSd[, element := paste0("Value_measuredElement_", element)]
    printSd = tidyr::spread(data = printSd, key = "element", value = "standardDeviation")
    
    printDT = rbind(printMean, printSd)
    printDT[, Variable := c("Mean", "Standard Dev.")]
    
    setnames(printDT, paste0("Value_measuredElement_", fbsElements),
             c("OpeningStock", "AreaSown", "AreaHarv", "Production",
               "Input", "Yield", "Feed", "Seed", "Waste", "Processed", "Food",
               "StockChange", "Imports", "Exports"))
    setnames(printDT, "measuredItemCPC", "Item")

    items = c("Variable", "Production", "Imports", "Exports",
              "StockChange", "Food", "Feed", "Waste", "Seed", "Industrial",
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
printStandardizationTable = function(data){
    printDT = copy(data)
    
    ## Bring in item names
    if(Sys.getenv("USER") == "josh"){ # Josh Work
        description = fread("~/Documents/Github/privateFAO/OrangeBook/elementDescription.csv")
    } else if(Sys.getenv("USER") %in% c("browningj", "rockc_000")){ # Josh virtual & home
        description = fread("~/GitHub/privateFAO/OrangeBook/elementDescription.csv")
    } else {
        stop("No working dir for current user!")
    }
    printDT = merge(printDT, description, by = "Item")
    
    setnames(printDT, c("prodMean", "prodSd", "wheatMean", "wheatSd"),
             c("Production (processed)", "SD(Production)",
               "Wheat Equivalent", "SD(Wheat Equivalent)"))
    
    knitr::kable(printDT[, c("Name", "Production (processed)", "SD(Production)",
               "Wheat Equivalent", "SD(Wheat Equivalent)"), with = FALSE])
}