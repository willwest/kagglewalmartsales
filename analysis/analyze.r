require(ggplot2)
require(plyr)

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
ggsave(plot=plot, filename="../out/weekly_sales.pdf", width=12, height=4)


####### Data Exploration: Holidays #######
# Average the weekly sales of all stores, highlighting the
# weeks in which there is a holiday
# (BAR GRAPH)
avg_sales <- ddply(df, .(Date, IsHoliday), summarize, Weekly_Sales=mean(Weekly_Sales))
avg_sales$Date <- as.Date(avg_sales$Date)

plot2 <- ggplot(avg_sales, aes(x=Date, y=Weekly_Sales, fill=IsHoliday)) + geom_bar(stat="identity") + scale_fill_manual(values=c("#999999", "#E69F00"))
ggsave(plot=plot2, filename="../out/avg_sales.pdf", width=12, height=4)


####### Data Exploration: All #######
# Average the weekly sales of all stores
# (LINE GRAPH)
plot3 <- ggplot(avg_sales, aes(x=Date, y=Weekly_Sales)) + geom_line() + scale_fill_manual(values=c("#999999", "#E69F00"))
ggsave(plot=plot3, filename="../out/line_all.pdf", width=12, height=4)

####### Data Exploration: Holidays #######
# Average the weekly sales of all stores, highlighting the
# weeks in which there is a holiday. Color the week based
# on which holiday is shown, so we can compare effects.





####### Data Exploration: Features #######
# Pick out a specific store, and display the weekly sales
# orered by date, highlighting the weeks in which there is
# a holiday.
require(GGally)

# get random sample of df rows
df.sample <- df[sample(nrow(df), 1000), ]


pdf(file='../out/features_scatter.pdf')
ggpairs(df.sample[,c("Temperature", "Fuel_Price", "CPI", "Unemployment", "Size")], axisLabels="none", diag=list(continuous="density", discrete="bar"),  params=list(labelSize=3, size=1, gridLabelSize=10), upper=list(params=list(size=5)))


##########################################
##########################################