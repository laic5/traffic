month_names = c("January", "Feburary", "March", "April")
filenames = list.files(pattern = "gz")
four_months = vector("list", length(filenames))

for (i in 1:length(filenames)){
  
  myFile = gzfile(filenames[i], open = "r")
  em.data = read.csv(myFile, header = FALSE)
  close(myFile)
  
  em.data = em.data[,c(1:12)]
  names(em.data) = c("timestamp", "station", "district", "freeway", "direction", "laneType", "length", "numSamples", "precentObs", "flow", "occupancy", "speed")
  
  ordered_stations = c(400141, 400249, 407219)
  
  doc_name = paste("Fremont", month_names[i], sep='')
  png(paste(doc_name, ".png", sep=''))
  
  flow.data = sapply(ordered_stations, extract_flow, df=em.data)
  
  pal.2 = colorRampPalette(c("red", "yellow", "green"), space="rgb")
  breaks = seq(min(flow.data), max(flow.data),length.out=100)
  par(mar=c(1,1,1,1))
  image(flow.data, col=pal.2(length(breaks)-1), breaks=breaks, xaxt="n", yaxt="n", ylab="", xlab="", main=paste("Flow for Fremont in", month_names[i]))
  
  text(0.1,1, ordered_stations[3])
  text(0.1,0.5, ordered_stations[2])
  text(0.1,0, ordered_stations[1])
  
  dev.off()
  
  # save data 
  
  #    four_months[[i]] = em.data
  
}

# plot for all fours
#save(jan, feb, mar, apr, file = "Fremont.RData")
load("Fremont.RData")

doc_name = "Fremont_All_Four"
png(paste(doc_name, ".png", sep=''))

flow.data = sapply(ordered_stations, extract_flow, df=em.data)

pal.2 = colorRampPalette(c("red", "yellow", "green"), space="rgb")
breaks = seq(min(flow.data), max(flow.data),length.out=100)
par(mar=c(1,1,1,1))
image(flow.data, col=pal.2(length(breaks)-1), breaks=breaks, xaxt="n", yaxt="n", ylab="", xlab="", main="Flow for Fremont in Jan-Apr")

text(0.1,1, ordered_stations[3])
text(0.1,0.5, ordered_stations[2])
text(0.1,0, ordered_stations[1])

dev.off()

####################### data analysis

# function to extract date and time (hour)
get_date = function(vec_timestamp){
  d = as.numeric(gsub("[0-9]{2}/([0-9]{2})/[0-9]{4}.*", "\\1", vec_timestamp))
  return(d)
}

get_hour = function(vec_timestamp){
  h = as.numeric(gsub(".* ([0-9]{2}):[0-9]{2}:[0-9]{2}", "\\1", vec_timestamp))
  return(h)
}

# only subset the stations we cared
jan3 = subset(jan, jan$station %in% c(400141, 400249, 407219))
feb3 = subset(feb, feb$station %in% c(400141, 400249, 407219))
mar3 = subset(mar, mar$station %in% c(400141, 400249, 407219))
apr3 = subset(apr, apr$station %in% c(400141, 400249, 407219))

# add the day and hour information to the data
jan3$day = get_date(jan3$timestamp)
jan3$hour = get_hour(jan3$timestamp)

feb3$day = get_date(feb3$timestamp)
feb3$hour = get_hour(feb3$timestamp)

mar3$day = get_date(mar3$timestamp)
mar3$hour = get_hour(mar3$timestamp)

apr3$day = get_date(apr3$timestamp)
apr3$hour = get_hour(apr3$timestamp)

## rainy day
rain = read.csv("Rain_week.csv")

# create a column to classify rain or not 
rain$israin = rain$summary %in% c("Light Rain", "Light Rain and Breezy", "Rain", "Heavy Rain and Breezy", "Rain and Breezy")

# split rain by month
rain_m = split(rain, rain$MONTH)
rain_m[[2]] = rain_m[[2]][!duplicated(rain_m[[2]]),] # duplication records in Feb
lapply(rain_m, function(x) range(x$DAY)) # rain data: day range for each month available
# $`1`
# [1] 17 29
# 
# $`2`
# [1]  9 23
# 
# $`3`
# [1] 12 24
# 
# $`4`
# [1]  9 23

# subset flow information where the rain date is available

jan3 = jan3[jan3$day %in% 17:29,]
feb3 = feb3[feb3$day %in% 9:23,]
mar3 = mar3[mar3$day %in% 12:24,]
apr3 = apr3[apr3$day %in% 9:23,]

# put them in list
em = list(jan3, feb3, mar3, apr3)
names(em) = c("jan", "feb", "mar", "apr")

# split it by station 
em2 = lapply(em, function(x) split(x, x$station))

# check dimension first before merge
lapply(em2, function(y) lapply(y, dim))
lapply(rain_m, dim)

# add the information of the rain data to the station 
em3 = em2
for (i in 1:4){
  for (j in 1:3){
    em3[[i]][[j]] = cbind(em2[[i]][[j]], rain_m[[i]])
  }
}

# clean dataset: em3
names(em3)
names(em3$jan)

# plot the flow for each station
em4 = lapply(em3, function(x) do.call("rbind", x)) # put them back in the same dataframe in each month 

flow.range = range(sapply(em4, function(x) range(x$flow)))
day.range = range(sapply(em4, function(x) range(x$day)))

par(mfrow=c(4,3))
for (i in 1:4){
  for (j in 1:3){
    temp = split(em3[[i]][[j]], em3[[i]][[j]]$day)
    with(temp[[1]], plot(hour, flow, type = 'l', main = paste(names(em3)[i], names(em3[[i]])[j]), ylim = flow.range, col="grey"))
    for (k in 2:length(temp)){
      with(temp[[k]], points(hour, flow, col="grey", cex=0.5))
      #             if (sum(temp[[k]]$israin)>0){
      #                 abline(v = temp[[k]]$hour[which(temp[[k]]$israin)], col="blue")
      #             }
    }
    for (k in 2:length(temp)){
      with(temp[[k]], lines(hour, flow, col="grey"))
    }
    hour_mean = tapply(em3[[i]][[j]]$flow, em3[[i]][[j]]$hour, mean)
    with(em3[[i]][[j]], lines(unique(hour), hour_mean, col="red"))
  }
}

## plot them across time

par(mfrow=c(4,3))
for (i in 1:4){
  for (j in 1:3){
    day_mean = tapply(em3[[i]][[j]]$flow, em3[[i]][[j]]$day, mean)
    with(em3[[i]][[j]], plot(day, flow, cex = 0.5, col="grey", ylim = flow.range, main = paste(names(em3)[i], names(em3[[i]])[j])))
    with(em3[[i]][[j]], lines(unique(day), day_mean, col="red"))
    abline(v = em3[[i]][[j]]$day[which(em3[[i]][[j]]$israin)], col="blue", lty=2)
  }
}