################################################################################
### In this file I:
### - aggregated the hospitalization data of the regions (depending on the buffer)
###   to their corresponding meteorological station
### - as some days were missing, I added the dates and inserted 0 hospitalizations!
###   and added a column with the day of the week
### - to this data, I saved the corresponding foehn and temp data, maybe inducing some NAs
###   for dates that no temp / foehn data was apparent
### - I saved both the data per station, and per buffer size combined of all stations




# packages
library(dplyr)


# read hospitalization data
data = read.csv("/data-raw/MedStat/med_stat_data/hosp_daily.csv", header =T)
data$station = NA


# get foehn data for every station
files_foehn = list.files("/data/foehn_processed")

# get temperature data for every station
files_temp = list.files("/data/temp_processed")


# get regions sorted to station files
files_regions = list.files("/data/MetStatRegions/centroids/per_station")

# recreate all the buffer sies that are in files_regions, in THE SAME ORDER
buffer_sizes = c(seq(10000,15000,1000), seq(4000, 9000, 1000))


# start loop for 4 buffers
for(i in 1:length(buffer_sizes)){

  # get buffer size and sorted regions
  buffer = buffer_sizes[i]
  regions = read.csv(paste0("C:/Users/tinos/Documents/Master - Climate Science/3 - Master Thesis/data/MetStatRegions/centroids/per_station/", files_regions[i]))

  # get colnames of the stations for later
  station_names = colnames(regions)

  # create empty aggregated_by_buffer data.frame for later here
  aggregated_by_buffer = data.frame(DT_EINTRTTSDAT = character(),
                                    all = numeric(),
                                    a014 = numeric(),
                                    a1564y = numeric(),
                                    a6574y = numeric(),
                                    a7584y = numeric(),
                                    a85plusy = numeric(),
                                    mal = numeric(),
                                    fem = numeric(),
                                    inf = numeric(),
                                    ment = numeric(),
                                    cvd = numeric(),
                                    resp = numeric(),
                                    uri = numeric(),
                                    station = character(),
                                    dow = character())

  # start loop for different station names
  for (j in 1:ncol(regions)) {

    # to clear the index for later
    data$station = NA

    # current station name
    station_current = station_names[j]
    # print(station_current) # for code checking

    # get all region names of that station, exclude empty entries
    region_names = regions[regions[,j] != "",j ]
    # print(region_names) # for code checking

    ## assign the station name to data$station when one of the region names is present
    # first create index
    index <- sapply(data$ID_WOHNREGION, function(row_text) {
      any(sapply( region_names,function(word) grepl(word, row_text, ignore.case = TRUE)))
    })

    data$station[index] = station_current


    # summarize when the station name is present in data$station by date
    aggregated_by_station <- data %>%
      filter(station == station_current) %>%  # Filter out rows where station is NA
      group_by(DT_EINTRITTSDAT) %>%           # Group by the date column
      summarise(across(all:uri, sum),         # across al variables we sum
                station = station_current)    # but we keep the station name

    # rename date column so that it matches with foehn and temp later
    aggregated_by_station <- aggregated_by_station %>%
      rename("date" = DT_EINTRITTSDAT)

    ## insert dates that got excluded by the aggregation process
    start_date = min(aggregated_by_station$date, na.rm = TRUE)
    end_date = max(aggregated_by_station$date, na.rm = TRUE)
    end_date_alter = "2019-12-31"


    if(as.Date(end_date) >= as.Date(end_date_alter)){
      end_date <- end_date_alter
    }


    # create empty df with continous dates
    df_with_dates = data.frame(date = as.character(seq.Date(from = as.Date(start_date), to = as.Date(end_date), by = "day")))

    # merge df with hosp data
    df_full <- df_with_dates %>%
      left_join(aggregated_by_station, by = "date")

    # fill NA in station with station name
    df_full$station = station_current

    # fill NA in values with 0
    df_full[is.na(df_full)] <- 0

    # reasign proper df name
    aggregated_by_station <- df_full




    # cbind the foehn data to the appropriate station
    # find the correct file
    station_current_up = substr(toupper(station_current), 1,3)

    matching_strings <- grep(station_current_up, files_foehn, value = TRUE)

    foehn_data = read.csv(paste0("/data/foehn_processed/", matching_strings))
    foehn_data <- foehn_data %>%
      rename("date" = time_conv)

    aggregated_by_station <- aggregated_by_station %>%
      left_join(foehn_data[,2:3], by = "date")


    # cbind the temp data
    # find the correct file
    matching_strings <- grep(station_current_up, files_temp, value = TRUE)
    temp_data = read.csv(paste0("/data/temp_processed/", matching_strings))
    temp_data$date <- as.character(as.Date(strptime(as.character(temp_data$time), format = "%Y%m%d")))

    aggregated_by_station <- aggregated_by_station %>%
      left_join(temp_data[,3:4], by = "date")

    # print(nrow(aggregated_by_station)) # TODO delete later


    # create day of the week column
    aggregated_by_station$date <- as.Date(aggregated_by_station$date)
    aggregated_by_station$dow <- weekdays(aggregated_by_station$date)


    # create 2 stratum variables of 1: station-year-month, 2: station-year-month-dow
    aggregated_by_station$dow   = as.factor(aggregated_by_station$dow)
    aggregated_by_station$year  = as.factor(format(aggregated_by_station$date, "%Y"))
    aggregated_by_station$month = as.factor(format(aggregated_by_station$date, "%m"))

    aggregated_by_station$stratum_dow = with(aggregated_by_station, factor(paste(station, year, month, dow, sep="-")))
    aggregated_by_station$stratum = with(aggregated_by_station, factor(paste(station, year, month, sep="-")))


    # append the data to the buffer aggregated dataset
    aggregated_by_buffer = rbind(aggregated_by_buffer, aggregated_by_station)

  }

  # only allow complete cases
  aggregated_by_buffer <- aggregated_by_buffer[complete.cases(aggregated_by_buffer), ]

  # save the combined buffer set
  write.csv(aggregated_by_buffer, file = paste0("/data/MedStat_aggregated/centroid_aggregated/hosp_buffer_", buffer, ".csv"))

}


