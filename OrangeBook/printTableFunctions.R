printTable = function(data, updateColName = NULL){
    printDT = copy(data)
    setnames(printDT, paste0("Value_measuredElement_", fbsElements),
             c("OpeningStock", "AreaSown", "AreaHarv", "Production",
               "Input", "Yield", "Feed", "Seed", "Waste", "Processed", "Food",
               "StockChange", "Imports", "Exports"))
    setnames(printDT, "measuredItemCPC", "Item")

    items = c("Item", "Production", "Imports", "Exports",
              "StockChange", "Food", "Feed", "Waste", "Seed", "Industrial",
              "Tourist", "Residual")
    sapply(items, function(colName){
        if(!colName %in% colnames(printDT)){
            printDT[, c(colName) := 0]
        }
    })
    out = knitr::kable(printDT[, items, with = FALSE])
    ## Trying to get bold to work with kable:
    out[1] = gsub("| Item", "|**Item**", out[1], fixed = TRUE)
    return(out)
}

printProductionTable = function(data){
    printDT = copy(data)
    setnames(printDT, paste0("Value_measuredElement_", c(5312, 5510, 5421)),
             c("Area Harvested", "Production", "Yield"))
    setnames(printDT, "measuredItemCPC", "Item")

    items = c("Item", "Area Harvested", "Yield", "Production")
    sapply(items, function(colName){
        if(!colName %in% colnames(printDT)){
            printDT[, c(colName) := 0]
        }
    })
    out = knitr::kable(printDT[, items, with = FALSE])
    return(out)
}
