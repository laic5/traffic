'''
Visualize all the station locations and top bottlenecks.
Variables considered: Longitude, latitude, Total duration, days active
Uses ggmap and ggplot2
'''

setwd("./sta160")

library(scales)
library(maps)
library(ggmap)
library(ggplot2)

boundary_df = read.csv("./data/d04_text_meta_2018_04_13.txt", sep='\t', stringsAsFactors = F)

stations = c(403429,401698,407290,406658,401211,405602,406657)
ordered_stations = c(405602, 401211, 401698)

em = boundary_df[boundary_df$ID %in% ordered_stations,]

norcal_map = get_map("Emeryville CA",zoom=14,maptype="roadmap")
ggmap(norcal_map)

# Locations of all the stations
ggmap(norcal_map) + geom_point(data = em, aes(x = Longitude, y = Latitude), alpha = .5, color = "red") + geom_text(data = em, aes(label= ID, x = Longitude, y = Latitude, vjust = -0.5), color = 'black', size = 2) + ggtitle("Emeryville stations")

em[,c("Latitude","Longitude")]



###########################
em6 = read.csv("em6.csv")
em4 = read.csv("em4.csv")
em5 = read.csv("em5.csv")


### plotting flow over time for one station 401211
temp = em6[em6$station == 401211,]
temp5 = em5[em5$station == 401211,]
temp4 = em4[em4$station == 401211,]

plot(temp$timestamp, temp$flow, type = "l")
lines(temp4$timestamp, temp4$flow, col="red")
lines(temp5$timestamp, temp5$flow, col="green")
###

extract_flow = function(df, st) {
  flow = df[df$station == st,]$flow
  return (as.matrix(flow))
}

extract_flow(em6, 401211)
flow6 = sapply(ordered_stations, extract_flow, df=em6)
image(flow6)
text(0.1,1, ordered_stations[3])
text(0.1,0.5, ordered_stations[2])
text(0.1,0, ordered_stations[1])

# plot the 3 station flows for the whole day, on 4/6
N = length(flow6[,1]) # number of 5 min points in a day
plot(1:N, flow6[,1], type='l')
lines(1:N, flow6[,2], type='l', col='red')
lines(1:N, flow6[,3], type='l', col='green') # this flow is much higher than the other 2



source("image_scale.R")
layout(matrix(c(1,2,0), nrow=3, ncol=1), widths=c(1), heights=c(4,1))
layout.show(2)
pal.2=colorRampPalette(c("red", "yellow", "green"), space="rgb")
breaks = seq(min(flow6), max(flow6),length.out=100)
par(mar=c(1,1,1,1))
image(flow6, col=pal.2(length(breaks)-1), breaks=breaks, xaxt="n", yaxt="n", ylab="", xlab="", main="Flow for Emeryville 4/6")

#Add scale
par(mar=c(1,1,1,3))
image.scale(flow6, col=pal.2(length(breaks)-1), breaks=breaks, horiz=TRUE)
box()
