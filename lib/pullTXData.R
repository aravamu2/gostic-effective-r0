
##### TEXAS #####
#################### LOADING THE DATA ############################################
fetchTXData <- function(rawData) {
    testURL <- c(
        "https://dshs.texas.gov/coronavirus/TexasCOVID-19CumulativeTestsOverTimebyCounty.xlsx",
        "https://dshs.texas.gov/coronavirus/TexasCOVID-19CumulativeTestsbyCounty.xlsx")
    
    caseURL <- "https://dshs.texas.gov/coronavirus/TexasCOVID19DailyCountyCaseCountData.xlsx"

    data_tests <- read.xlsx(testURL[1])
    data_tests_2 <- read.xlsx(testURL[2])
    data_cases <- read.xlsx(caseURL, startRow = 2)

    dataList <- list(data_tests = data_tests,
                     data_tests_2= data_tests_2,
                     data_cases = data_cases)
    
    ## archive data pull
    if (!is.null(rawData)) {
        saveRDS(dataList, rawData)
    }
    
    return(dataList)


} ## function fetchTXData



## data tests

formatTXData <- function(dataList,beginDate,endDate) {
    data_tests <- dataList$data_tests
    data_tests_2 <- dataList$data_tests_2
    data_case <- dataList$data_case

    find_date =  function(x){ gsub("Tests Through ", "", x) }

    data_tests[1,] = lapply(data_tests[1,], find_date)
    data_tests = row_to_names(data_tests, row_number = 1)
    data_tests = t(data_tests)
    data_tests = as.data.frame(data_tests)
    data_tests = row_to_names(data_tests, row_number = 1)
    data_tests$date = as.Date(rownames(data_tests),"%B %d")


    data_tests_2 = row_to_names(data_tests_2, row_number = 1)
    data_tests_2 = t(data_tests_2)
    data_tests_2 = as.data.frame(data_tests_2)
    data_tests_2 = row_to_names(data_tests_2, row_number = 1)
    data_tests_2$date = tail(data_tests$date,1) + seq(1:dim(data_tests_2)[1])

                                        # same counties in both datasets
    columns_real = intersect(colnames(data_tests), colnames(data_tests_2))
    data_tests = data_tests[,columns_real]
    data_tests_2 = data_tests_2[,columns_real]

                                        # rbinding
    data_tests = rbind(data_tests, data_tests_2)

    remove(data_tests_2)

    ## cases
    #data_cases = read.xlsx("https://dshs.texas.gov/coronavirus/TexasCOVID19DailyCountyCaseCountData.xlsx", startRow = 2)

    last_5_chars = function(x){ str_sub(x, -5) }
    no_starts =  function(x){ gsub("\\*", "", x) }

    data_cases[1,] = lapply(data_cases[1,], no_starts)
    data_cases[1,] = lapply(data_cases[1,], last_5_chars)
    data_cases = row_to_names(data_cases, row_number = 1)
    data_cases = t(data_cases)
    data_cases = as.data.frame(data_cases)
    data_cases = row_to_names(data_cases, row_number = 1)
    data_cases$date = as.Date(rownames(data_cases),"%m-%d")

                                        # same counties in both datasets
    columns_real = intersect(colnames(data_tests), colnames(data_cases))
    data_tests = data_tests[,columns_real]
    data_cases = data_cases[,columns_real]


                                        # same number of observations
    common_dates = as.Date(intersect(data_tests$date,data_cases$date), origin = "1970-01-01")
    data_tests = data_tests[data_tests$date %in% common_dates,]
    data_cases = data_cases[data_cases$date %in% common_dates,]

    rownames(data_tests) = common_dates
    rownames(data_cases) = common_dates
    
    remove(common_dates)

    data_TX = {}
    df_TX = {}

    columns_real = head(columns_real,-1)

    for (county in columns_real){
  
        data_TX$confirm = data_cases[,c(county)]
        data_TX$tests = data_tests[,c(county)]
        data_TX$date = data_cases$date
        data_TX = as.data.frame(data_TX)
        data_TX$name = rep(county, dim(data_TX)[1])
  
        no_number_1 =  function(x){ gsub("--", NA, x) }
        no_number_2 =  function(x){ gsub("-", NA, x) }
  
        data_TX$tests = lapply(data_TX$tests, no_number_1)
        data_TX$tests = lapply(data_TX$tests, no_number_2)

        data_TX$confirm = lapply(data_TX$confirm, no_number_1)
        data_TX$confirm = lapply(data_TX$confirm, no_number_2)
  
        df_TX = rbind(df_TX, data_TX)
  
        data_TX = NULL
    }
    
    remove(data_TX)
    remove(data_cases)
    remove(data_tests)
    remove(columns_real)

    df_TX <- df_TX %>% mutate(tests = as.numeric(tests),
                              confirm = as.numeric(confirm)) %>% 
        clean_names() %>%
        group_by(name) %>%  
        arrange(date) %>% 
        mutate(pos_new = confirm - lag(confirm, 1, 0),
               test_new = tests - lag(tests, 1, 0),
               test_new = ifelse( test_new < 0 , 0, test_new),
               pos_new = ifelse( pos_new < 0 , 0, pos_new)) %>% 
        mutate(test_new = na.fill(test_new, "extend"),
               pos_rate = pmin(1, pos_new / test_new),
               pos_rate = na.fill(pos_rate, "extend")) %>% 
        nest() %>% 
        mutate(pos_rate_gam = map(data, function(df) fitted(gam(pos_rate ~ s(as.numeric(date)), data = df, family = "quasibinomial", weights = test_new)))) %>%
        unnest(cols = c(data, pos_rate_gam)) %>% 
        group_by(date) %>% 
        mutate(case = pos_new * (pos_rate_gam/quantile(pos_rate_gam, probs = 0.025, na.rm = TRUE))^0.1) %>% 
        ungroup() 
    return(df_TX)
}
##### CAUTION WITH COUNTIES LIKE KING IN TEXAS ######
#view(df_TX[df_TX$name == "King",])
##### CAUTION WITH COUNTIES LIKE KING IN TEXAS ######
