prepare.data <- function(df, features, stores){
	# Combine store type and size with features
	features <- merge(features, stores, by="Store")

	# Get rid of excessive columns
	features$IsHoliday <- NULL

	# Merge features with data
	df <- merge(df, features, by=c("Store","Date"))

	df <- df[order(df$Store, df$Dept, df$Date),]

	print(head(df))

	# For now, don't use the Date column
	# ...we will definitely need to use this later, but
	# for a first try it isn't necessary
	df$Date <- NULL

	# # Convert features into numeric

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

	# df$Date <- factor(df$Date)
	# df <- cbind(df, model.matrix( ~ Date - 1, data=df))
	# df$Date <- NULL

	# Covert all NA's to zeros
	df[is.na(df)] <- 0

	return(df)
}

features <- read.csv("../data/features.csv", stringsAsFactors=FALSE)
stores <- read.csv("../data/stores.csv", stringsAsFactors=FALSE)
test <- read.csv("../data/test.csv", stringsAsFactors=FALSE)
train <- read.csv("../data/train.csv", stringsAsFactors=FALSE)

# Reorder columns so that target is left-most column
train <- train[,c("Weekly_Sales","Store", "Dept","IsHoliday", "Date")]


# Do the same for the test data, so they are consistent
test$Weekly_Sales <- 0
test <- test[,c("Weekly_Sales","Store", "Dept","IsHoliday", "Date")]

train <- prepare.data(train, features, stores)
test <- prepare.data(test, features, stores)


# Write training data to file
write.table(train, file="../out/combined.train.csv", row.names=FALSE, col.names=FALSE, sep=',')

# Write testing data to file
write.table(test, file="../out/combined.test.csv", row.names=FALSE, col.names=FALSE, sep=',')

