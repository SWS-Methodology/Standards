USDA_2_SUA_comm <- function(Commodity_Description){
  
  if(Commodity_Description == "Meal, Copra"){
    return(measuredItemFS = "F2161")
  }
  
  if(Commodity_Description == "Meal, Cottonseed"){
    return(measuredItemFS = "0143" ) # Cottonseed
  }
  
  if(Commodity_Description == "Meal, Fish"){
    return(measuredItemFS = "NA") #????
  }
  
  if(Commodity_Description == "Meal, Palm Kernel"){
    return(measuredItemFS = "01491.02") # Palm Kernel
  }
  
  if(Commodity_Description == "Meal, Peanut"){
    return(measuredItemFS = "01422") # Groundnuts in Shell
  }
  
  if(Commodity_Description == "Meal, Rapeseed"){
    return(measuredItemFS = "01443")  # Rapeseed
  }
  
  
  if(Commodity_Description == "Meal, Soybean"){
    return(measuredItemFS = "0141") # Soybeans
  }
  
  if(Commodity_Description == "Meal, Soybean (Local)"){
    return(measuredItemFS = "NA") # ???
  }
  
  if(Commodity_Description == "Meal, Sunflowerseed"){
    return(measuredItemFS = "01445") # Sunflowerseed
  }
  
  if(Commodity_Description == "Oil, Coconut"){
    return(measuredItemFS = "F2160")
  }
  
  if(Commodity_Description == "Oil, Cottonseed"){
    return(measuredItemFS = "0143")
  }
  
  if(Commodity_Description == "Oil, Olive"){
    return(measuredItemFS = "F2163")
  }
  
  if(Commodity_Description == "Oil, Palm"){
    return(measuredItemFS = "2165")
  }
  
  if(Commodity_Description == "Oil, Palm Kernel"){
    return(measuredItemFS = "21691.14")
  }
  
  if(Commodity_Description == "Oil, Peanut"){
    return(measuredItemFS = "2162") # Oil of Groundnuts
  }
  
  if(Commodity_Description == "Oil, Rapeseed"){
    return(measuredItemFS = "NA") # ???
  }
  
  if(Commodity_Description == "Oil, Soybean"){
    return(measuredItemFS = "2161")
  }
  
  if(Commodity_Description == "Oil, Soybean (Local)"){
    return(measuredItemFS = "NA") # ?????
  }
  
  if(Commodity_Description == "Oil, Sunflowerseed"){
    return(measuredItemFS = "NA")
  }
  
#   else 
#     return(measuredItemFS = 0)
  
}