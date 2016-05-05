#' Retrieve modified area codes used in UN Comtrade
#' 
#' These codes are used in reporter column of Tariffline. This function has 
#' side-effect: by default it creates cached copy of data in invisible variable
#' .ComtradeM49areas
#' 
#' @param cache Logical. Should cache version be used if it exists or be created
#'   if does not exist. TRUE by default.


getComtradeM49 <- function(cache = T) {
  
  if(exists(".ComtradeM49areas") & cache)
    return(.ComtradeM49areas)
  
  url <- "http://comtrade.un.org/data/cache/reporterAreas.json"
  
  tbl <- jsonlite::fromJSON(url)$results
  
  colnames(tbl) <- c("code", "name")
  
  tbl <- tbl[tbl$code != "all",]
  
  if(cache) {
    .ComtradeM49areas <<- tbl
    return(.ComtradeM49areas)
  }
  
  if(!cache) return(tbl)
  
  stop("Unxpected logic in getComtradeM49()")
  
}