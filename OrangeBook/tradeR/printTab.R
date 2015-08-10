# Wrapper around pander::pandoc.table to reduce some typing
#
# style "grid" produces LibreOffice friendly tables

printTab <- function(tbl, 
                     style,
                     split.table = Inf,
                     ...) {
  
  output_format <- knitr::opts_knit$get("rmarkdown.pandoc.to")
  
  if(output_format == "latex") return(knitr::kable(tbl, ...))

  if(output_format == "docx") return(pander::pandoc.table(tbl, 
                       style = "grid", 
                       split.table = Inf, 
                       ...))
}
