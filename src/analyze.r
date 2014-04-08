require(ggplot2)
require(zoo)
require(lubridate)
require(plyr)

prepare.data <- function(df){
	# Combine store type and size with features
	features <- merge(features, stores, by="Store")

	# Get rid of excessive columns
	features$IsHoliday <- NULL

	# Merge features with data
	df <- merge(df, features, by=c("Store","Date"))

	df <- df[order(df$Store, df$Dept, df$Date),]

	# parse date into individual features
	df$Date <- as.Date((strptime(df$Date, "%Y-%m-%d")))
	df <- cbind(df, Year = year(df$Date), Month = month(df$Date, label=TRUE), Day = day(df$Date))
}

features <- read.csv("../data/features.csv", stringsAsFactors=FALSE)
stores <- read.csv("../data/stores.csv", stringsAsFactors=FALSE)
train <- read.csv("../data/train.csv", stringsAsFactors=FALSE)
#test <- read.csv("../data/test.csv", stringsAsFactors=FALSE)

train <- prepare.data(train)
train <- train[,c("Weekly_Sales", "Date", "Year", "Month", "IsHoliday")]

train$Weekly_Sales <- as.numeric(train$Weekly_Sales)

df <- ddply(train, .(Year,Month), summarize, Monthly_Sales=sum(Weekly_Sales))

dates <- paste(df$Year, df$Month, "01", sep="-")
df$Date <- as.Date(strptime(dates, "%Y-%b-%d"))

head(df)

plot <- ggplot(df, aes(x=Month, y=Monthly_Sales))+geom_bar(stat="bin")
# plot <- qplot(Month, Monthly_Sales, data=df, geom="bar")
ggsave(file="../out/plots/weekly_sales.pdf", plot=plot)