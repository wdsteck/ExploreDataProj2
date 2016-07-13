#
# plot3.R script
#
# This script performs an exploratory data analysis for the second
# class project.
#
# The data is located at:
#       https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip
#
# This script answers the following question:
#	Of the four types of sources indicated by the 𝚝𝚢𝚙𝚎 (point, nonpoint,
#	onroad, nonroad) variable, which of these four sources have seen
#	decreases in emissions from 1999–2008 for Baltimore City? Which
#	have seen increases in emissions from 1999–2008? Use the ggplot2
#	plotting system to make a plot answer this question.

# Download the zip file and uncompress it giving the 2 source files.

dataFileURL <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
dataFileZip <- "NEI_data.zip"
dataFileSrcSCC <- "Source_Classification_Code.rds"
dataFileSrcSUM <- "summarySCC_PM25.rds"
dataFileOut <- "plot3.png"

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

require(ggplot2)

# Extract the data from the data file.
print("Reading Source Files")

NEI <- readRDS(dataFileSrcSUM)
SCC <- readRDS(dataFileSrcSCC)

print("Creating Plot")

# Create the chart

# first open the png device.
png(dataFileOut, width = 480, height = 480)

# Extract the Baltimore City, MD data

baltData <- NEI[NEI$fips == "24510",]

baltData$type <- factor(baltData$type)

# Find the Emissions over each year of data
aggdata <- aggregate(Emissions ~ year+type, baltData, sum,
                     na.rm = TRUE, na.action="na.pass")

pl <- ggplot(aggdata, aes(x=aggdata$year,
                    y = aggdata$Emissions,
                    color=aggdata$type))
pl <- pl + theme_bw()
pl <- pl + geom_point()
pl <- pl + geom_smooth(method = lm, se = FALSE)
pl <- pl + xlab("Year") + ylab("Emissions (in Tons)")
pl <- pl + ggtitle("Total PM2.5 Emissions in Baltimore City, MD by Emission Source")
pl <- pl + scale_color_discrete(name = "Emission Source")
pl <- pl + scale_x_continuous(breaks = aggdata$year,
                              limits = c(min(aggdata$year), max(aggdata$year + 1)))
pl <- pl + geom_label(data = aggdata, size = 3, hjust = 0, nudge_x = .05,
                     aes(label = round(aggdata$Emissions, digits = 0)))

print(pl)

# Close the device
dev.off()

print("Complete")
