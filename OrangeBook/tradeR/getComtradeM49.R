#' Retrieve modified area codes used in UN Comtrade
#' 
#' These codes are used in reporter column of Tariffline

getComtradeM49 <- function() {
  
  url <- "http://comtrade.un.org/data/cache/reporterAreas.json"
  
  jsonlite::fromJSON(url)
  
}