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


bottlenecks = read.csv("./data/d04_top_bottlenecks_4_02_4_27.txt", sep='\t', stringsAsFactors = F)
boundary_df = read.csv("./data/d04_text_meta_2018_04_13.txt", sep='\t', stringsAsFactors = F)[, c("Latitude", "Longitude")]
find_hull = function(df) df[chull(df$Longitude, df$Latitude),]
hull = find_hull(boundary_df)

norcal_map = get_map("Oakland CA",zoom=8,maptype="roadmap")
ggmap(norcal_map)

border_plt = ggmap(norcal_map) + geom_polygon(data = hull, aes(x = Longitude, y = Latitude), alpha = 0.05, color = "turquoise", inherit.aes = F)

# Locations of all the stations
border_plt + geom_point(data = boundary_df, aes(x = Longitude, y = Latitude), alpha = 0.1, color = "turquoise") + ggtitle("Locations of all Stations in D4")

# Bottlenecks by days active
border_plt  + geom_point(data = bottlenecks, aes(x = Longitude, y = Latitude, size = X..Days.Active), color='red', alpha = 0.05) + ggtitle("Top Bottlenecks by Days Active, 4/2 - 4/27")

# Bottlenecks by Total delay
#custom_pal = (brewer_pal(palette = "Reds")(8))[3:8]
border_plt  + geom_point(data = bottlenecks, aes(x = Longitude, y = Latitude, color = Total.Duration..mins., size = Total.Duration..mins.), alpha = 0.2) + 
  scale_color_distiller("Duration", palette = "RdPu", direction = 1) + 
  ggtitle("Top Bottlenecks by Total Duration (min), 4/2 - 4/27")


