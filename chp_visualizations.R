library(ggplot2)
library(ggmap)
library(plyr)

file = gzfile('./data/all_text_chp_incidents_month_2018_04.txt.gz','rt')
chp = read.csv(file, header=F)

want_chp_columns = c(0, 3, 4, 5, 6, 9, 10, 11, 14, 15, 18, 19)
want_chp_columns = want_chp_columns + 1
chp = chp[, want_chp_columns]
chp_incidents_cols = c("incidentID", "timestamp", "description", "location", "area", "latitude", "longitude", "district", "freeway", "direction", "severity", "duration")
colnames(chp) = chp_incidents_cols

chp4 = chp[which(chp$district == 4),]

# number of incidents per freeway
g = ggplot(chp4, aes(as.factor(freeway))) + geom_bar() + 
  ggtitle("Number of CHP Incidents per Freeway"); g

# locations of all the incidents
border_plt + geom_point(data = chp4, aes(x = longitude, y = latitude, size = duration), color = "seagreen2", alpha = 0.05)


# bar plot of the top types of incidents
chp4_top_incidents
g = ggplot(chp4, aes(as.factor(description))) + geom_bar() + 
  ggtitle("Frequency of CHP Incidents"); g



shorten_incident = function(incident) {
  incident = as.character(incident)
  namesplit = strsplit(incident, "-")
  if (grepl("^[[:digit:]][[:alpha:]]*",(namesplit[[1]][1])))
    return (namesplit[[1]][2])
  else
    return (namesplit[[1]][1])
}
chp_short_incidents = chp4
chp_short_incidents$description = sapply((chp_short_incidents$description), shorten_incident)
# find num occurrences for each incident and get rows where only above 10 times
Len = with(chp_short_incidents, ave(description, description, FUN = length))
top_incidents = chp_short_incidents[as.numeric(Len) > 50, ]

ggplot(top_incidents, aes(as.factor(description))) + geom_bar() + 
  ggtitle("Top CHP Incidents")
