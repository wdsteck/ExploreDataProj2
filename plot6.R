#
# plot6.R script
#
# This script performs an exploratory data analysis for the second
# class project.
#
# The data is located at:
#       https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip
#
# This script answers the following question:
#       Compare emissions from motor vehicle sources in Baltimore
#       City with emissions from motor vehicle sources in Los Angeles
#       County, California (𝚏𝚒𝚙𝚜 == "𝟶𝟼𝟶𝟹𝟽"). Which city has seen
#	greater changes over time in motor vehicle emissions?
#

# Download the zip file and uncompress it giving the 2 source files.

dataFileURL <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
dataFileZip <- "NEI_data.zip"
dataFileSrcSCC <- "Source_Classification_Code.rds"
dataFileSrcSUM <- "summarySCC_PM25.rds"
dataFileOut <- "plot6.png"

if ((!file.exists(dataFileSrcSCC)) | (!file.exists(dataFileSrcSUM))) {
        if (!file.exists(dataFileZip)) {
                print("Downloading Data Zip File")
                if (download.file(dataFileURL, dataFileZip)) {
                        stop(paste("Could not download data file <",
				   dataFileURL, "> to zip file <",
				   dataFileZip, ">", sep = ""))
                }
        }
        print("Unzipping Data Source Files")
        unzip(dataFileZip)
	if ((!file.exists(dataFileSrcSCC)) | (!file.exists(dataFileSrcSUM))) {
                stop(paste("Could not unzip data zip file <", dataFileZip,
			   "> to data files <", dataFileSrcSCC, "> and ",
			   dataFileSrcSUM, ">.", sep = ""))
	}
        print("Data Files Successfully loaded.")
}

# Extract the data from the data file.
print("Reading Source Files")

NEI <- readRDS(dataFileSrcSUM)
SCC <- readRDS(dataFileSrcSCC)

print("Analyzing the Data")

# finding the SCC values from Coal Sources
SCC <- SCC[grepl("Vehicles", SCC$EI.Sector, ignore.case=TRUE), c("SCC", "EI.Sector")]

# pulling those Baltimore City and LA County emissions values
# that are from Motor Vehicle sources
NEI <- NEI[(NEI$SCC %in% SCC$SCC) & ((NEI$fips == "24510") | (NEI$fips == "06037")),]

print("Creating Plot")

# Create the chart

# first open the png device.
png(dataFileOut, width = 480, height = 480)

# Find the Emissions over each year of data

aggdata <- aggregate(Emissions ~ year+fips, NEI, sum,
                     na.rm = TRUE, na.action="na.pass")

# Plot the data. Fiddle with the axis scales to make the plot look nicer

plot(x = range(aggdata$year, na.rm = TRUE),
     y = range(aggdata$Emissions, na.rm = TRUE),
     main = "Total PM2.5 Emmissions from Vehicle Sources\nin Baltimore City, MD and LA County, CA over Time",
     xlab = "Year",
     ylab = "Emissions (in Tons)",
     xaxt = "n",
     xlim = c(min(aggdata$year, na.rm = TRUE),
              max(aggdata$year, na.rm = TRUE) + 1),
     ylim = c(0, ceiling(max(aggdata$Emissions, na.rm=TRUE))),
     type = "n"
     )

# Add a grid to compare the slopes of the regression lines
grid(lty = 3, col = "dark grey")

# only show the labels for the years we are plotting on the x axis
axis(side = 1, at = aggdata$year)

# Plot the Baltimore City points and linear regression line
points(aggdata$year[aggdata$fips == "24510"],
       aggdata$Emissions[aggdata$fips == "24510"],
       pch = 19,
       col="red"
       )
abline(lm(aggdata$Emissions[aggdata$fips == "24510"] ~
                  aggdata$year[aggdata$fips == "24510"]),
       col = "red")

# Plot the LA County points and linear regression line
points(aggdata$year[aggdata$fips == "06037"],
       aggdata$Emissions[aggdata$fips == "06037"],
       pch = 19,
       col="blue"
       )
abline(lm(aggdata$Emissions[aggdata$fips == "06037"] ~
                  aggdata$year[aggdata$fips == "06037"]),
       col = "blue")

# add data point labels
datlab <- round(aggdata$Emissions, digits = 2)
text(aggdata$year, aggdata$Emissions, datlab, pos=4, cex = .7)

# Add legend
legend("right", pch = 19, 
       col = c("red", NA, "blue"), 
       legend = c("Baltimore City", NA, "LA County"),
       cex = .8,
       title = "Emissions",
       text.width = 2
       )


# Close the device
dev.off()

print("Complete")
