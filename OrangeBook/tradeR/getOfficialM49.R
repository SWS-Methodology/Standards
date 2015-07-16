#' Retrieve table with area codes used by the UN
#'
#' Numeric codes from this table are used in TariffLine data in partner field.
#' For example 250 for France, 840 for the US.
#' Look at getComtradeM49() for codes used in reporter field



getOfficialM49 <- function() {
  url <- "http://unstats.un.org/unsd/methods/m49/m49alpha.htm"
  
  tbl <- XML::readHTMLTable(url, 
                     as.data.frame = T, 
                     skip.rows = 1:22,
                     which = 4,
                     stringsAsFactors = F)
  names(tbl) <- c("code", "name", "iso3")
  tbl$iso3[tbl$iso3 == ""] <- NA
  tbl$iso3[tbl$name == "Sark"] <- NA # Error in parse of HTML
  
  tbl
}
