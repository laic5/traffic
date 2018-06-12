# cluster_bottlenecks.R
setwd('Documents/SQ2018/STA160/traffic/')
library(RSQLite)
library(ppclust)
library(fpc)

library(ggplot2)
library(ggthemes)
# Connect to database:
min5 = dbConnect(SQLite(), dbname="5min.db")
# list of all tables:
dbListTables(min5)
# list of all columns in the table:
dbListFields(min5, dbListTables(min5)[3]) 
dbListFields(min5, dbListTables(min5)[4]) 

# Start by looking at 1 day only to cluster 5-min 
df_0402 = dbGetQuery(min5, "select station,freeway,type, direction,flow,occupancy,speed 
                          from '5min' 
                          where date='04/02/2018' and freeway = '80' and type='ML'" )

### exploring the speed data:

# histogram of all speeds
hist(df_0402$speed)

# missing data:

(which(is.na(df_0402$speed)))   # no. vds with missing speed data = 57024


# clutering by 2 features, flow and speed
names(df_0402)[c(4,6)]
features = as.matrix(df_0402[,c(4,6)])
dim(features)

# missing data:
length(which(is.na(df_0402[,4])))   # no. vds with missing flow data = 0
length(which(is.na(df_0402[,6])))   # no. vds with missing speed data = 57024
# temporary solution; imputation may be necessary
features = na.omit(features)
nrow(df_0402) - length(which(is.na(df_0402[,6]))) == dim(features)[1]   

flow_df = dbGetQuery(min5, "SELECT station,freeway,direction,flow,speed,noLanes
                     FROM '5min' INNER JOIN 'd04_metadata' USING(station,freeway,direction)")


table(flow_df$noLanes)/sum(table(flow_df$noLanes))
levels(factor(flow_df$flow))
hist(df_0402$flow)

### Fuzzy C-Means Clustering of VDS based on speed and flow at 5-min intervals
pfcm = pfcm(btl_features, centers = 7)    # extremely slow
# KNN is O(n*c*d*i) while FCM is O(n*c^2*d*i)
summary(pfcm)

# Standard K-Means Clustering 
# looking for 3 distinct periods: fast,regular,congested 
(kmn = kmeans(features,5,nstart=30))
kmn
plot(features)

dbDisconnect(min5)

list.dirs()
##################################################################


df_280S = dbGetQuery(min5, "SELECT station,timestamp,type,flow,speed 
                     FROM '5min' INNER JOIN 'd04_metadata' USING(station,freeway,direction,type)
                     WHERE date='04/02/2018' AND freeway = '280' AND direction='S' AND type='ML' ")
df_280S$timestamp = as.POSIXct(paste("2018-04-02",df_280S$timestamp," "),
                                  format="%Y-%m-%d %H:%M:%S")
features_280S = as.matrix(df_280S[,c(2,4,5)])
(kmn = kmeans(features_280S,4,nstart=30))

mph_heat = ggplot(data = speed_280S,
       aes(x = timestamp, y = as.factor(abs_PM), fill = speed)) + 
  geom_raster() +
  xlab("Time of Day") +
  ylab("Postmile") +
  scale_fill_distiller(palette = 1, direction = -1) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1),
        axis.text.y = element_blank())
mph_heat


levels(factor(speed_280S$abs_PM[which(speed_280S$speed < 40)]))
levels(factor(detected_bottleencks$abs_PM))
detected_bottleencks = bottleneck_finder(speed_280S,direction=F)

result = search_slowdowns(2,speed_280S[which(speed_280S$speed < 40)[2]],direction = F)
table(detected_bottleencks$station)

#########################################################################################
# I thought that PCA might be a good idea because these four features are highly correlated
# but dimensionality reduction is not necessary prior to clustering (for K-means at least)
# maybe we should just assess 
btl_df = dbGetQuery(min5, "select * from 'd04_bottlenecks_april_t45_normalized' where type='ML'" )
btl_df$days_active = btl_df$days_active/max(btl_df$days_active)
btl_features = as.matrix(btl_df[,12:15])  # interested in the four features provided by PeMS

cor(btl_features)

# Testing various values of (k)
wss <- vector()
for (i in 2:12) {
  kmn = kmeans(btl_features, centers =i,nstart=25,iter.max = 25)
  wss[i] = kmn$betweenss/kmn$totss
}
vector(wss)
wss = as.data.frame(wss)
names(wss) = "percentage"

ggplot(data=(as.data.frame(wss)), aes(x = factor(seq(1,nrow(wss))), y = percentage)) + 
   geom_point(colour = "red", size = 3) + geom_line() +
  scale_y_continuous(breaks = seq(0, 1, by=0.025), limits=c(0.8,1))+
  xlab("k") + ylab("between_SS / total_SS") + 
    ggtitle("K-Means Clustering of April Bottlenecks") + theme_economist() 
  


####################################################################################
# adding metadata to clustering: 
library(dplyr)
full_meta = dbGetQuery(min5, "SELECT * FROM 'd04_metadata' WHERE type='ML'")
meta = dbGetQuery(min5, "SELECT station,county,city,length,noLanes FROM 'd04_metadata'  WHERE type='ML'")
btl_meta = left_join(btl_df, meta, by = 'station')
length(which(is.na(btl_meta$city)))
btl_meta = btl_meta[(which(!is.na(btl_meta$city))),]
names(btl_meta)
btl_meta$county = as.factor(btl_meta$county)
btl_meta$city = as.factor(btl_meta$city)
# It is necessary to perform one-hot encoding on the categorical variables:

for(unique_value in unique(btl_meta$county)){
  btl_meta[paste("county", unique_value, sep = ".")] = ifelse(btl_meta$county == unique_value, 1, 0)
}
for(unique_value in unique(btl_meta$city)){
  btl_meta[paste("city", unique_value, sep = ".")] = ifelse(btl_meta$city == unique_value, 1, 0)
}
names(btl_meta)
btl_meta = btl_meta %>% select (-c(county, city))
btl_meta_features = as.matrix(btl_meta[,12:ncol(btl_meta)])

wss2 <- vector()
for (i in 2:12) {
  kmn2 = kmeans(btl_meta_features, centers =i,nstart=25,iter.max = 25)
  wss2[i] = kmn2$betweenss/kmn2$totss
}

wss2 = as.data.frame(wss2)
names(wss2) = "percentage"

ggplot(data=(as.data.frame(wss2)), aes(x = factor(seq(1,nrow(wss2))), y = percentage)) + 
  geom_point(colour = "red", size = 3) + geom_line() +
  scale_y_continuous(breaks = seq(0, 1, by=0.025), limits=c(0.8,1))+
  labs(title = "K-Means Clustering of April Bottlenecks",
       subtitle = "Includes additional metadata features: district, city, length, noLanes",
       x = "k", y = "between_SS / total_SS")  + theme_economist() 
