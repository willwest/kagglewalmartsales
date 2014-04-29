require(ggplot2)

theme_set(theme_gray(base_size = 18))

df <- read.csv('../data/train.w.features.csv', header=TRUE, stringsAsFactors=TRUE)

##########################################
####### Data Exploration: Holidays #######
# Pick out a specific store, and display the weekly sales
# orered by date, highlighting the weeks in which there is
# a holiday.

store1 <- subset(df, Store==1)
store1d1 <- subset(store1, Dept==1)
store1d1$Date <- as.Date(store1d1$Date)


plot <- ggplot(store1d1, aes(x=Date, y=Weekly_Sales, fill=IsHoliday)) + geom_bar(stat="identity") + scale_fill_manual(values=c("#999999", "#E69F00"))
ggsave("../../out/weekly_sales.pdf", width=12)

##########################################
##########################################