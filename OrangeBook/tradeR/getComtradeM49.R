#' Retrieve modified area codes used in UN Comtrade
#' 
#' These codes are used in reporter column of Tariffline

getComtradeM49 <- function() {
  
  url <- "http://comtrade.un.org/data/cache/reporterAreas.json"
  
  tbl <- jsonlite::fromJSON(url)$results
  
  colnames(tbl) <- c("code", "name")
  
  tbl[tbl$code != "all",]
  
}