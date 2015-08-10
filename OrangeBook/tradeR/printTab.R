# Wrapper around pander::table to reduce some typing
#
# style "grid" produces LibreOffice friendly tables

printTab <- function(tbl, style = "grid", ...) {
  pander::table(tbl, style = style, ...)
}
