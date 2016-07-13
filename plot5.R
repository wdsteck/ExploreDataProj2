#
# plot5.R script
#
# This script performs an exploratory data analysis for the second
# class project.
#
# The data is located at:
#       https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip
#
# This script answers the following question:
#       How have emissions from motor vehicle sources changed from
#	1999–2008 in Baltimore City?
#

# Download the zip file and uncompress it giving the 2 source files.

dataFileURL <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
dataFileZip <- "NEI_data.zip"
dataFileSrcSCC <- "Source_Classification_Code.rds"
dataFileSrcSUM <- "summarySCC_PM25.rds"
dataFileOut <- "plot5.png"

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

# pulling those Baltimore City emissions values that are from Motor Vehicle sources
NEI <- NEI[(NEI$SCC %in% SCC$SCC) & (NEI$fips == "24510"),]

print("Creating Plot")

# Create the chart

# first open the png device.
png(dataFileOut, width = 480, height = 480)

# Find the Emissions over each year of data

aggdata <- aggregate(Emissions ~ year, NEI, sum,
                     na.rm = TRUE, na.action="na.pass")

# Plot the data. Fiddle with the axis scales to make the plot look nicer
plot(aggdata,
     main = "Total PM2.5 Emmissions from Vehicle Sources in the Baltimore City, MD over Time",
     xlab = "Year",
     ylab = "Emissions (in Tons)",
     pch = 19,
     type = "p",
     xlim = c(min(aggdata$year, na.rm = TRUE),
              max(aggdata$year, na.rm = TRUE) + 1),
     ylim = c(0, ceiling(max(aggdata$Emissions, na.rm=TRUE))),
     xaxt = "n"
)

# only show labels for the years we are plotting on the x axis
axis(side = 1, at = aggdata$year)

# add a regression line
abline(lm(aggdata$Emissions ~ aggdata$year), col = "red")

# add data point labels
datlab <- round(aggdata$Emissions, digits = 2)
text(aggdata$year, aggdata$Emissions, datlab, pos=4, cex = .7)

# Close the device
dev.off()

print("Complete")
