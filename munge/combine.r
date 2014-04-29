require(lubridate)
require(zoo)
require(plyr)

setwd("/Users/wmw71190/kagglewalmartsales/munge/")

test_data <- read.csv("../data/test.w.features.csv", stringsAsFactors=FALSE)
train_data <- read.csv("../data/train.w.features.csv", stringsAsFactors=FALSE)

sample_submission <- read.csv("../data/submissionTemplate.csv", stringsAsFactors=FALSE)
sample_submission$Date <- as.Date(sample_submission$Date)
sample_submission$prediction <- NULL

prepare.data <- function(df){
  
  # Convert features into numeric
  df$Store <- factor(df$Store)
  df <- cbind(df, model.matrix( ~ Store - 1, data=df))
  df$Store <- NULL
  
  df$Dept <- factor(df$Dept)
  df <- cbind(df, model.matrix( ~ Dept - 1, data=df))
  df$Dept <- NULL
  
  df$Type <- factor(df$Type)
  df <- cbind(df, model.matrix( ~ Type - 1, data=df))
  df$Type <- NULL
  
  df$IsHoliday <- factor(df$IsHoliday)
  df <- cbind(df, model.matrix( ~ IsHoliday - 1, data=df))
  df$IsHoliday <- NULL
  
  df$Year <- NULL
  df$Month <- NULL
  df$Day <- NULL
  df$prevYear <- NULL
  
  # Convert date string to Date class
  df$Date <- as.Date(df$Date)
  
  # Covert all NA's to zeros
  df[is.na(df)] <- 0
  
  print(head(df))
  
  return(df)
}

get.holiday.type <- function(df){
  christmas_dates <- c("2010-12-31", "2011-12-30", "2012-12-28", "2013-12-27")
  super_bowl_dates <- c("2010-02-12", "2011-02-11", "2012-02-10", "2013-02-08")
  labor_day_dates <- c("2010-09-10", "2011-09-09", "2012-09-07", "2013-09-06")
  thanksgiving_dates <- c("2010-11-26", "2011-11-25", "2012-11-23", "2013-11-29")
  
  christmas_dates <- as.Date(christmas_dates)
  super_bowl_dates <- as.Date(super_bowl_dates)
  labor_day_dates <- as.Date(labor_day_dates)
  thanksgiving_dates <- as.Date(thanksgiving_dates)
  
  df$IsChristmas <- (df$Date %in% christmas_dates)*1
  df$IsSuperBowl <- (df$Date %in% super_bowl_dates)*1
  df$IsLaborDay <- (df$Date %in% labor_day_dates)*1
  df$IsThanksgiving <- (df$Date %in% thanksgiving_dates)*1
  
  df$Date <- NULL
  
  print(df)
  return(df)
}

w.holiday.features <- function(train, test){
  train <- prepare.data(train)
  test <- prepare.data(test)
  
  train <- get.holiday.type(train)
  test <- get.holiday.type(test)
  
  # Write training data to file
  write.table(train, file="../out/combined.train.csv", row.names=FALSE, col.names=FALSE, sep=',')
  
  # Write testing data to file
  write.table(test, file="../out/combined.test.csv", row.names=FALSE, col.names=FALSE, sep=',')
  
  return(NULL)
}

w.last.year.pred <- function(train, test){
  
  # get data frame of previous year fridays
  dates <- prev.year.dates(unique(test_data$Date))
  test_data$Date <- as.Date(test_data$Date)
  test_data <- merge(test_data, dates, by="Date")
  test_data$Weekly_Sales <- NULL
  
  predictions <- ddply(test_data, .(Dept, Store), agg.sales)
  
  predictions[predictions$prediction==0,]$prediction <- mean(predictions$prediction)
  
  predictions <- predictions[,c("Store","Dept","Date","prediction")]
  
  final <- merge(sample_submission, pred_copy, by=c("Store","Dept","Date"))
  final <- final[order(final$Store, final$Dept, final$Date),]
  final <- final[,c("id","prediction")]
  
  # get rid of bad header names
  final$Id <- final$id
  final$Weekly_Sales <- final$prediction
  final$id <- NULL
  final$prediction <- NULL
  
  write.table(final, file='../out/prev_year_submit.csv',row.names=FALSE, col.names=TRUE, sep=",", quote=FALSE)
  
}

w.last.year.pred.and.features <- function(train, test){
  
}

prev.year.dates <- function(date_vector){
  # Subtract a year
  prev.year.date <- as.Date(date_vector) - years(1)
  
  # Calculate number of days until Friday
  # get day of week
  dow <- wday(prev.year.date)
  
  # get how many days until this friday
  days_until_friday <- 6 - dow %% 7
  
  # Get date of the next Friday
  next_friday <- prev.year.date + days(days_until_friday)
  
  # Get the date of the previous Friday
  prev_friday <- next_friday - days(7)
  
  # Return the averaged sales figure
  return(data.frame(Date=as.Date(date_vector), next_friday=as.Date(next_friday), prev_friday=as.Date(prev_friday)))
}

agg.sales.test <- function(df){
  # Get the sales of both Fridays
  sales <- subset(train, train$Store==df$Store[1] & train$Dept==df$Dept[1])[,c("Date","Weekly_Sales")]
  
  # get model vector of weeks, add any missing weeks as NA
  all_weeks <- data.frame(Date=seq(from=as.Date("2010-02-05"), to=as.Date("2012-10-19"), by="week"))
  sales$Date <- as.Date(sales$Date)
  sales <- merge(all_weeks, sales, all.x=TRUE, by="Date")
  
  df$prev_friday_sales <- merge(df, sales, by.x="prev_friday", by.y="Date")$Weekly_Sales

  df$next_friday_sales <- merge(df, sales, by.x="next_friday", by.y="Date")$Weekly_Sales
  
  df$prediction <- apply(df[,c("prev_friday_sales","next_friday_sales")],1,mean, na.rm=TRUE)
    
  df$prediction[is.na(df$prediction)] <- 0
  
  return(df)
}


agg.sales.train <- function(df){
  # Get the sales of both Fridays
  sales <- subset(train_data, train_data$Store==df$Store[1] & train_data$Dept==df$Dept[1])[,c("Date","Weekly_Sales")]
  
  # get model vector of weeks, add any missing weeks as NA
  all_weeks <- data.frame(Date=seq(from=as.Date("2010-02-05"), to=as.Date("2011-10-28"), by="week"))
  sales$Date <- as.Date(sales$Date)
  sales <- merge(all_weeks, sales, all.x=TRUE, by="Date")
  
  df$prev_friday_sales <- merge(df, sales, by.x="prev_friday", by.y="Date")$Weekly_Sales
  
  df$next_friday_sales <- merge(df, sales, by.x="next_friday", by.y="Date")$Weekly_Sales
  
  df$prediction <- apply(df[,c("prev_friday_sales","next_friday_sales")],1,mean, na.rm=TRUE)
  
  df$prediction[is.na(df$prediction)] <- 0
  
  return(df)
}

############################################
############    TESTING   ##################
############################################

# get data frame of previous year fridays
dates <- prev.year.dates(unique(test_data$Date))
test_data$Date <- as.Date(test_data$Date)
test_data <- merge(test_data, dates, by="Date")
test_data$Weekly_Sales <- NULL

predictions <- ddply(test_data, .(Dept, Store), agg.sales.test)

predictions[predictions$prediction==0,]$prediction <- mean(predictions$prediction)

predictions <- predictions[,c("Store","Dept","Date","prediction")]

# write the predictions to a file for later
#write.table(predictions, file='../data/prev_year_all.test.csv', row.names=FALSE, col.names=TRUE, sep=',', quote=FALSE)

############################################
############    TRAINING  ##################
############################################
# Convert training data dates into Date type
train_data$Date <- as.Date(train_data$Date)

# Choose 2011-02-18 as the start of the training data...
# Can't get past year's weekly sales before that date.
train.w.prev <- subset(train_data, train_data$Date >= as.Date("2011-02-18"))

# get prev year dates for train.w.prev
train.dates <- prev.year.dates(unique(train.w.prev$Date))

# merge train.w.prev data with previous/next dates
train.w.prev.merged <- merge(train.w.prev, train.dates, by="Date")

train.w.prev.merged$Weekly_Sales <- NULL

predictions.train <- ddply(train.w.prev.merged, .(Dept, Store), agg.sales.train)

predictions.train[predictions.train$prediction==0,]$prediction <-  mean(predictions.train$prediction)

# add Weekly_Sales (ground truth) to dataframe
predictions.train.merged <- merge(predictions.train, train_data[,c("Weekly_Sales","Store","Dept","Date")], by=c("Store","Dept","Date"))
  
# write the predictions to a file for later
write.table(predictions.train.merged, file='../data/prev_year_all.train.csv', row.names=FALSE, col.names=TRUE, sep=',', quote=FALSE)

