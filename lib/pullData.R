#############


####
fetchWIData <- function(rawData) {
    url <- "https://opendata.arcgis.com/datasets/5374188992374b318d3e2305216ee413_12.csv"
    df <- read.csv(url, fileEncoding="UTF-8-BOM", stringsAsFactors = FALSE) 
    
    ## archive data pull
    if (!is.null(rawData)) {
        saveRDS(df, rawData)
    }
    
    return(df)
}  ## fetchWIData

########################
fetchNYData <- function(rawData) {
    
    df <- GET("https://health.data.ny.gov/resource/xdss-u53e.json?$limit=5000000")
    df <- content(df, as = "text") #JSON response structured into raw data
    df <- fromJSON(df)
    df <- as.data.frame(df)
    ## archive data pull
    if (!is.null(rawData)) {
        saveRDS(df, rawData)
    }
    
    return(df)
}  ## fetchNYData


smoothByPosRate <- function(df) {
    
    df <- df %>%
        
        arrange(date) %>%
        
        mutate(pos_new = positive - lag(positive, 1, 0),
               neg_new = negative - lag(negative,1,0) ) %>%
        mutate(
            test_new = pos_new + neg_new,
            test_new = na.fill(test_new, "extend"),
            pos_rate = pos_new / test_new,
            pos_rate = na.fill(pos_rate, "extend")) %>%
        select( -neg_new, -negative) %>%
        nest() %>% 
        mutate(pos_rate_gam = map(data, function(df) fitted(gam(pos_rate ~ s(as.numeric(date)), data = df, family = "quasibinomial", weights = test_new)))) %>%
        unnest(cols = c(data, pos_rate_gam)) %>% 
        group_by(date) %>% 
        mutate(case = pos_new *
                   (pos_rate_gam/quantile(pos_rate_gam, probs = 0.025, na.rm = TRUE))^0.1) %>% 
        ungroup()
    
    return(df)
}

formatWIData <- function(df) {
    df <-
        df %>%
        clean_names() %>% 
        select(name:test_new) %>% 
        mutate(date = ymd_hms(date)) %>% 
        group_by(name) %>% 
        
        # enforce monotonicity  
        arrange(desc(date)) %>%
        mutate(positive = cummin(positive),
               negative = cummin(negative)) %>%
        mutate(tests = positive + negative) %>%
        select(-deaths, -dth_new,-dth_7dayavg)
    
    return(smoothByPosRate(df))
}  ## formatWIData


formatNYData <- function(df) {
    df <- df %>% 
        clean_names() %>%  
        mutate(tests = as.numeric(cumulative_number_of_tests),
               positive = as.numeric(cumulative_number_of_positives)) %>% 
        mutate(date = as.Date(ymd_hms(test_date))) %>% 
        rename(name = county) %>%
        group_by(name) %>%
        
        # enforce monotonicity  
        arrange(desc(date)) %>%
        mutate(positive = cummin(positive),
               tests = cummin(tests),
               negative = tests - positive)
    return(smoothByPosRate(df))
} ## formatNYData

#####
pullData <- function(state,rawData = NULL) {
    if (state == "WI") {
        df_raw <- fetchWIData(rawData)
        df <- formatWIData(df_raw)
        return(df)
    }
    
    if (state == "NY") {
        df_raw <- fetchNYData(rawData)
        df <- formatNYData(df_raw)
        return(df)
    }
    
    
    
}

