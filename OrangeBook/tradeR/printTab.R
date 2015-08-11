# Wrapper around pander::pandoc.table to reduce some typing
#
# style "grid" produces LibreOffice friendly tables

printTab <- function(tbl, 
                     col.names = NULL,
                     style = NULL,
                     split.table = Inf,
                     ...) {
  
  output_format <- knitr::opts_knit$get("rmarkdown.pandoc.to")
  
  if(is.null(style)) {
    style <- "rmarkdown" # For latex
    if(output_format == "docx") style <- "grid"
  }
    
  if(!is.null(col.names)) colnames(tbl) <- col.names #Pandoc.table doesn't have it
  
  pander::pandoc.table(tbl, 
                       style = style, 
                       split.table = split.table, 
                       ...)
}