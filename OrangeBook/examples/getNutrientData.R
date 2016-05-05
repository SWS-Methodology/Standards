library(data.table)
library(faosws)

GetTestEnvironment(
    baseUrl = "https://hqlprswsas1.hq.un.fao.org:8181/sws",
    token = "d0e1f76f-61a6-4183-981c-d0fec7ac1845"
#     baseUrl = "https://hqlqasws1.hq.un.fao.org:8181/sws",
#     token = "7fe7cbec-2346-46de-9a3a-8437eca18e2a"
)

GetCodeList(domain = "suafbs", dataset = "nutrient_factors_cpc",
            dimension = "measuredElementNutritive")
cpcCodes = GetCodeList(domain = "suafbs", dataset = "nutrient_factors_cpc",
                       dimension = "measuredItemCPC")
cpcCodes = cpcCodes[, code]
GetCodeList(domain = "suafbs", dataset = "nutrient_factors_cpc",
            dimension = "timePointFake")[, code]

key = DatasetKey(domain = "suafbs", dataset = "nutrient_factors_cpc",
                 dimensions = list(
                     Dimension(name = "measuredElementNutritive", keys = c("203", "204", "208", "904")),
                     Dimension(name = "measuredItemCPC", keys = cpcCodes),
                     Dimension(name = "timePointFake", keys = "1")
                 ))
nutrientData = GetData(key, normalized = FALSE)
setnames(nutrientData, paste0("Value_measuredElementNutritive_", c(203, 204, 208, 904)),
         c("Protein", "Fat", "Energy", "Energy2"))
nutrientData[, Energy2 := NULL] # Maybe kiloJoules???  Seems to be 4.18 times greater than the other...
save(nutrientData, file = "~/Documents/Github/privateFAO/OrangeBook/nutrientData.RData")
