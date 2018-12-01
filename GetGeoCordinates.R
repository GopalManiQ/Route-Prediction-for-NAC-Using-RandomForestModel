library(ggmap)
rm(list=ls(all=TRUE))

# Select the file from the file chooser
fileToLoad <- file.choose(new = TRUE)

# Read in the CSV data and store it in a variable 
origAddress <- read.csv(fileToLoad, stringsAsFactors = FALSE)
str(origAddress)

# Initialize the data frame
geocoded <- data.frame(stringsAsFactors = FALSE)

# Loop through the addresses to get the latitude and longitude of each address and add it to the
# origAddress data frame in new columns lat and lon
for(i in 1:nrow(origAddress))
{
  
  tryCatch({
    
  # Print("Working...")
  result <- geocode(origAddress$DELIVERYPOINT[i], output = "latlona", source = "google")
  origAddress$lon[i] <- as.numeric(result[1])
  origAddress$lat[i] <- as.numeric(result[2])
  origAddress$geoAddress[i] <- as.character(result[3])
  
  }, error=function(e){})
}

# Write a CSV file containing origAddress to the working directory
write.csv(origAddress, "geocoded.csv", row.names=FALSE)
