require(zoo)
require(lubridate)

merge.data <- function(df){
	# Combine store type and size with features
	features <- merge(features, stores, by="Store")

	# Get rid of excessive columns
	features$IsHoliday <- NULL

	# Merge features with data
	df <- merge(df, features, by=c("Store","Date"))

	df <- df[order(df$Store, df$Dept, df$Date),]

	# parse date into individual features
	df$Date <- as.Date((strptime(df$Date, "%Y-%m-%d")))
	df <- cbind(df, Year = year(df$Date), Month = month(df$Date), Day = day(df$Date))

	# add feature for previous year
	df$prevYear <- df$Year-1

	return(df)
}

features <- read.csv("../data/features.csv", stringsAsFactors=FALSE)
stores <- read.csv("../data/stores.csv", stringsAsFactors=FALSE)
train <- read.csv("../data/train.csv", stringsAsFactors=FALSE)
test <- read.csv("../data/test.csv", stringsAsFactors=FALSE)

# Reorder columns so that target is left-most column
train <- train[,c("Weekly_Sales","Store", "Dept","IsHoliday", "Date")]

# Do the same for the test data, so they are consistent
test$Weekly_Sales <- 0
test <- test[,c("Weekly_Sales","Store", "Dept","IsHoliday", "Date")]

train <- merge.data(train)

test <- merge.data(test)



# Write data to file
write.table(train, file="../data/train.w.features.csv", row.names=FALSE, sep=',')

# Write data to file
write.table(test, file="../data/test.w.features.csv", row.names=FALSE, sep=',')