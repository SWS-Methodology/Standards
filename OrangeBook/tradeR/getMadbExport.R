getMadbExport <- function(country, hs) {
  url <- "http://madb.europa.eu/"
  
  r <- rvest::html(url,
                   path ="madb/atDutyOverviewPubli.htm",
                   query = list(option = 1,
                                display = 50,
                                language = "all",
                                year1 = "",
                                year2 = "",
                                sector = "all",
                                country = "all",
                                langId = "en",
                                datacat_id = "AT",
                                showregimes = "",
                                countryid = country,
                                submit = "Search",
                                countries = country,
                                hscode= as.character(hs)))
  
  
  tbl <- rvest::html_nodes(r, xpath = "//table[1]") %>% 
    rvest::html_table(fill = T, header = T) %>% 
    as.data.frame(stringsAsFactors = F) %>% 
    select(hs = 1, desc = 2) %>% 
    filter(!is.na(hs)) %>% 
    mutate(
      dash = stringr::str_replace(
        stringr::str_extract(desc, 
                             "^.*?[A-Za-z]{1}"), 
        "[A-Za-z]$", ""),
      desc = stringr::str_replace(desc, "^(- )*", "")
    )
  
  tbl %>% select(-dash)  
}
