# install.packages("shinyapps")
# library(shinyapps)
# shinyapps::setAccountInfo(name='josh-browning-fao',
#     		  token='8BB9073601D332A675DA3F8712F43018',
# 			  secret='<Get from shinyapps.io>')

library(shinyapps)
setwd("~/GitHub/privateFAO/OrangeBook/capacityDevelopment/")
# files = dir("../Helper Functions/", pattern = "*.R", full.names = TRUE)
# sapply(files, function(x) file.copy(from = x, to = "R/"))
deployApp(appName = "capacity-development-plfhmeikcrp8uf3yhw8oiygpihi8n0v1vip5n2v8r6o74qshqz",
          account = "josh-browning-fao")
