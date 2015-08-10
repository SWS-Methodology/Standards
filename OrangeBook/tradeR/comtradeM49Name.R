#' Convert Comtrade M49 code into country name.

comtradeM49Name <- function(code, ...) {
#   
#   Error in structure(.Call(C_objectSize, x), class = "object_size") : 
#     unimplemented type (31) in 'object.size'
  
  if(length(code) > 1) return(vapply(code, 
                                     comtradeM49Name, 
                                     character(1), ...))
  
  areas <- getComtradeM49()
  areas$name[areas$code == code]
}