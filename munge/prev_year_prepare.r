setwd("/Users/wmw71190/kagglewalmartsales/munge")

train <- read.csv("../data/prev_year_all.train.csv", stringsAsFactors=FALSE)

train <- train[,c("Weekly_Sales","Store","Dept","Date","IsHoliday","Temperature","Fuel_Price","MarkDown1","MarkDown2","MarkDown3","MarkDown4","MarkDown5","CPI","Unemployment","Type","Size","Year","Month","Day","prevYear","next_friday","prev_friday","prev_friday_sales","next_friday_sales","prediction")]
train <- train[order(train$Store, train$Dept, train$Date),]

test <- read.csv("../data/prev_year_all.test.csv", stringsAsFactors=FALSE)
test$Weekly_Sales <- 0
test <- test[,c("Weekly_Sales","Store","Dept","Date","IsHoliday","Temperature","Fuel_Price","MarkDown1","MarkDown2","MarkDown3","MarkDown4","MarkDown5","CPI","Unemployment","Type","Size","Year","Month","Day","prevYear","next_friday","prev_friday","prev_friday_sales","next_friday_sales","prediction")]
test <- test[order(test$Store, test$Dept, test$Date),]


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
  df$IsHolidayFALSE <- NULL
  
  # get rid of extraneous data
  df$Year <- NULL
  df$Month <- NULL
  df$Day <- NULL
  df$prevYear <- NULL
  df$next_friday <- NULL
  df$prev_friday <- NULL
  df$prev_friday_sales <- NULL
  df$next_friday_sales <- NULL

  # Convert date string to Date class
  df$Date <- as.Date(df$Date)
  
  # for now, get rid of date
  df$Date <- NULL
  
  # Covert all NA's to zeros
  df[is.na(df)] <- 0
  
  return(df)
}

prepare.data2 <- function(df){
  df$Store <- NULL
  df$Dept <- NULL
  df$Type <- NULL
  
  df$IsHoliday <- factor(df$IsHoliday)
  df <- cbind(df, model.matrix( ~ IsHoliday - 1, data=df))
  df$IsHoliday <- NULL
  df$IsHolidayFALSE <- NULL
  
  # get rid of extraneous data
  df$Year <- NULL
  df$Month <- NULL
  df$Day <- NULL
  df$prevYear <- NULL
  df$next_friday <- NULL
  df$prev_friday <- NULL
  df$prev_friday_sales <- NULL
  df$next_friday_sales <- NULL
  
  # for now, get rid of date
  df$Date <- NULL
  
  # Covert all NA's to zeros
  df[is.na(df)] <- 0
  
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

train.prepared <- prepare.data2(train)
test.prepared <- prepare.data2(test)

# Write training data to file
write.table(train.prepared, file="../out/combined.train.csv", row.names=FALSE, col.names=FALSE, sep=',')

# Write testing data to file
write.table(test.prepared, file="../out/combined.test.csv", row.names=FALSE, col.names=FALSE, sep=',')

