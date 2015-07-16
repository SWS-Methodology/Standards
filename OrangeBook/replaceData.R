##' Replace data
##' 
##' This function allows for the easy replacement of all of the data for a 
##' particular element of the FBS/SUA.  The purpose of this function is really 
##' just for the example: we have the originalData as well as a newData table 
##' that we want to insert into the original.  We just pass them into this 
##' function, and it updates everything appropriately (keeping missing values 
##' for all elements).
##' 
##' @param originalData The current data.table containing all the SUA/FBS data.
##' @param newData A new data.table containing all the key columns (with the 
##'   same name as originalData) and two other columns:
##'   Value_measuredElement_XXXX and standardDeviation_measuredElement_XXXX.
##' @params mergeKey A vector of column names specifying the key for merging 
##'   originalData and newData.
##'   
##' @return Nothing is returned, but originalData is updated.
##'   

replaceData = function(originalData, newData, mergeKey){
    origKey = key(originalData)
    setkeyv(originalData, mergeKey)
    ## Don't need to worry about messing up newData's key since it's a copy
    setkeyv(newData, mergeKey)
    valColumn = colnames(newData)[grep("Value_", colnames(newData))]
    sdColumn = colnames(newData)[grep("standardDeviation_", colnames(newData))]
    replaceElement = gsub("[A-Za-z_]*", "", valColumn)
    originalData[newData, c("Value", "standardDeviation") :=
        list(ifelse(element == replaceElement, get(valColumn), Value),
             ifelse(element == replaceElement, get(sdColumn), standardDeviation)),]
    setkeyv(originalData, origKey)
}