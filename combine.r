require(lubridate)
require(zoo)

prepare.data <- function(df, features, stores){

	# Get rid of individual dates
	df$Date <- NULL

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

	# Covert all NA's to zeros
	df[is.na(df)] <- 0

	print(head(df))

	return(df)
}

test <- read.csv("../data/test.w.features.csv", stringsAsFactors=FALSE)
train <- read.csv("../data/train.w.features.csv", stringsAsFactors=FALSE)

train <- prepare.data(train, features, stores)
test <- prepare.data(test, features, stores)


# Write training data to file
write.table(train, file="../out/combined.train.csv", row.names=FALSE, col.names=FALSE, sep=',')

# Write testing data to file
write.table(test, file="../out/combined.test.csv", row.names=FALSE, col.names=FALSE, sep=',')

