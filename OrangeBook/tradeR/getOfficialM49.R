#' Retrieve table with area codes used by the UN
#'
#' Numeric codes from this table are used in TariffLine data in partner field.
#' For example 250 for France, 840 for the US.
#' Look at getComtradeM49() for codes used in reporter field
#' @param cache Logical. Should cache version be used if it exists or be created
#'   if does not exist. TRUE by default.


getOfficialM49 <- function(cache = T) {
  
    if(exists(".OfficialM49areas") & cache)
    return(.OfficialM49areas)
  
  url <- "http://unstats.un.org/unsd/methods/m49/m49alpha.htm"
  
  tbl <- XML::readHTMLTable(url, 
                     as.data.frame = T, 
                     skip.rows = 1:22,
                     which = 4,
                     stringsAsFactors = F)
  names(tbl) <- c("code", "name", "iso3")
  tbl$iso3[tbl$iso3 == ""] <- NA
  tbl$iso3[tbl$name == "Sark"] <- NA # Error in parse of HTML
  
  if(cache) {
    .OfficialM49areas <<- tbl
    return(.OfficialM49areas)
  }
  
  tbl
}
