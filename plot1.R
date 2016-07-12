#
# plot1.R script
#
# This script performs an exploratory data analysis for the second
# class project.
#
# The data is located at:
#       https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip
#
# This script answers the following question:
# 

setwd("/Users/bill/Desktop/class/exploratory data/proj2")

# Download the zip file and uncompress it giving the 2 source files.

dataFileURL <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
dataFileZip <- "NEI_data.zip"
dataFileSrcSCC <- "Source_Classification_Code.rds"
dataFileSrcSUM <- "summarySCC_PM25.rds"
dataFileOut <- "plot1.png"

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
}

print("Files loaded.")

# Extract the data from the data file.
print("Reading Source Files")

NEI <- readRDS(dataFileSrcSUM)
SCC <- readRDS(dataFileSrcSCC)

print("Reading Source Files Complete")

# Create the chart

# first open the png device.
png(dataFileOut, width = 480, height = 480)

# Plot the Data chart

# Close the device
dev.off()
