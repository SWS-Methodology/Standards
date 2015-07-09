library(faosws)
library(data.table)
GetTestEnvironment(
    baseUrl = "https://hqlprswsas1.hq.un.fao.org:8181/sws",
    token = "e77abee7-9b0d-4557-8c6f-8968872ba7ca"
#     baseUrl = "https://hqlqasws1.hq.un.fao.org:8181/sws",
#     token = "7fe7cbec-2346-46de-9a3a-8437eca18e2a" #Michael's token
)

if(Sys.info()[7] == "josh"){ # Josh Work
    workingDir = "~/Documents/Github/Working/OrangeBook/"
} else if(Sys.info()[7] %in% c("browningj", "rockc_000")){ # Josh virtual & home
    workingDir = "~/Github/Working/OrangeBook/"
} else {
    stop("No working dir for current user!")
}

wheatKeys = c("0111", "23110", "23140.01", "23140.02", "23140.03", "23220.01",
              "23220.02", "23490.02", "23710", "39120.01", "F0020", "F0022")
cattleKeys = c("21111.01", "21111.02", "21182", "21184.01", "21185",
               "21512.01", "23991.04", "F0875")
palmOilKeys = c("01491.02", "2165", "21691.14", "21910.06", "21700.01",
                "21700.02", "F1243", "34550", "F1275", "34120")
key = DatasetKey(
    domain = "agriculture",
    dataset = "agriculture",
    dimensions = list(
        ## All countries (needed for models)
        Dimension(name = "geographicAreaM49",
                  keys = GetCodeList("agriculture", "agriculture",
                                     "geographicAreaM49")[type == "country", code]),
        Dimension(name = "measuredElement", keys = c("5113", "5025", "5312", "5510", "5421",
                                                     "5520", "5525", "5023", "5327", "5016",
                                                     "5141", "5120")),
        Dimension(name = "measuredItemCPC", keys = c(wheatKeys, cattleKeys, palmOilKeys)),
        ## 15 years
        Dimension(name = "timePointYears", keys = as.character(1996:2011))
    ))
pivoting = list(Pivoting(code = "geographicAreaM49"),
                Pivoting(code = "timePointYears"),
                Pivoting(code = "measuredItemCPC"),
                Pivoting(code = "measuredElement"))
data = GetData(key, normalized = FALSE, pivoting = pivoting)
data[, Value_measuredElement_5141 := as.numeric(Value_measuredElement_5141)]
# data = data[, c("geographicAreaM49", "timePointYears", "measuredItemCPC",
#                 colnames(data)[grepl("Value_", colnames(data))]), with = FALSE]

partnerCountry = GetCodeList(domain = "trade", dataset = "ct_raw_tf",
                             dimension = "partnerCountryM49")[type == "country", code]
map = GetTableData(schemaName = "ess", tableName = "hs_2_cpc")
hsKeys = map[cpc %in% gsub("\\..*", "", c(wheatKeys, cattleKeys, palmOilKeys)),
             unique(hs)]
key = DatasetKey(
    domain = "trade",
    dataset = "ct_raw_tf",
    dimensions = list(
        Dimension(name = "reportingCountryM49", keys = "842"),
        Dimension(name = "partnerCountryM49", keys = partnerCountry),
        Dimension(name = "measuredElementTrade", keys = c("5600", "5900")),
        Dimension(name = "measuredItemHS", keys = hsKeys),
        Dimension(name = "timePointYears", keys = "2011")
    ))
tradeData = GetData(key)
tradeData = tradeData[, list(Value = sum(Value)),
                      by = c("measuredElementTrade","measuredItemHS")]
setnames(tradeData, "measuredItemHS", "hs")

## Map codes to HS, scale values with split factors
tradeData = merge(tradeData, map, by = "hs")
tradeData[, Value := Value * split]
tradeData[, c("hs", "split", "conversion_factor") := NULL]
tradeData = dcast.data.table(data = tradeData, formula = cpc ~ measuredElementTrade,
                             value.var = "Value", fun.aggregate = sum)
setnames(tradeData, c("5600", "5900"), c("Value_measuredElement_5600",
                                         "Value_measuredElement_5800"))

## Merge the trade data in, and allocate split values arbitrarily
## Define a merge key for data
data[, cpc := gsub("\\..*", "", measuredItemCPC)]
data = merge(data, tradeData, by = "cpc", all = TRUE)
## Allocate splits randomly
data[, splitProp := abs(rnorm(.N)), by = "cpc"]
data[, Value_measuredElement_5600 := Value_measuredElement_5600 *
         splitProp/sum(splitProp), by = "cpc"]
data[, splitProp := abs(rnorm(.N)), by = "cpc"]
data[, Value_measuredElement_5800 := Value_measuredElement_5800 *
         splitProp/sum(splitProp), by = "cpc"]
data[, splitProp := NULL]
data[, cpc := NULL]

## Bring in commodity names
# cpcNames = fread(paste0(workingDir, "cpcNames.csv"))
# data = merge(data, cpcNames, by = "Item", all = TRUE)

write.csv(data, file = paste0(workingDir, "standardizationData.csv"),
          row.names = FALSE)

###############################################################################
# Commodity trees
###############################################################################

load(paste0(workingDir, "../../faoswsAupus/data/commodityTrees.RData"))
suaTree[, parentID := faoswsUtil::fcl2cpc(formatC(parentID, width = 4, flag = "0"))]
suaTree[, childID := faoswsUtil::fcl2cpc(formatC(childID, width = 4, flag = "0"))]
cpcCodes = data[!is.na(measuredItemCPC), unique(measuredItemCPC)]
suaTree = suaTree[childID %in% cpcCodes | parentID %in% cpcCodes, ]
write.csv(suaTree, file = paste0(workingDir, "standardizationTree.csv"),
          row.names = FALSE)

###############################################################################
# Share trees
###############################################################################

files = dir(paste0(workingDir, "../../faoswsAupus/R"), full.names = TRUE)
sapply(files, source)

aupusParam = getAupusParameter(areaCode = "231", assignGlobal = FALSE,
                               yearsToUse = 2011)
shareData = getShareData(aupusParam = aupusParam, database = "new")
shareData = collapseSpecificData(aupusParam = aupusParam, listData = shareData)
write.csv(shareData, file = paste0(workingDir, "shareData.csv"))

shareData = data.table(measuredItemParentFS = c("0111", "0111", "0111", "0111", "0111"),
                       measuredItemChildFS = c(23110, 39120.01, 23140.01, 23140.02, 23140.03),
                       Value_share = c(95, 95, 95, 1, 4))
shareData = rbind(shareData,
    data.table(
        measuredItemParentFS = c(21111.01, 21111.01, 21111.01, 21111.01, 21111.01, 21111.01, 21111.01),
        measuredItemChildFS = c(21111.02, 21512.01, 21182, 21185, 21184.01, "F0875", 23911.04),
        Value_share = c(40, 40, 10, 10, 10, 10, 20)
    ))
shareData = rbind(shareData,
    data.table(
        measuredItemParentFS = c(2165, 2165),
        measuredItemChildFS = c(34120, 21932.02),
        Value_share = c(50, 50)
    ))

write.csv(shareData, file = paste0(workingDir, "shareData.csv"), row.names = FALSE)
