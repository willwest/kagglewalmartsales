options(width=150)

features <- read.csv("../data/features.csv", stringsAsFactors=FALSE)
stores <- read.csv("../data/stores.csv", stringsAsFactors=FALSE)
test <- read.csv("../data/test.csv", stringsAsFactors=FALSE)
train <- read.csv("../data/train.csv", stringsAsFactors=FALSE)

# Combine store type and size with features
features <- merge(features, stores, by="Store")

# Get rid of excessive columns
features$IsHoliday <- NULL

# Merge features with training data
train <- merge(train, features, by=c("Store","Date"))

# Write training data to file
write.csv(train, file="../out/combined.csv", row.names=FALSE)