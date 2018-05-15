
library(RSQLite)
library(ppclust)
library(fpc)


# Connect to database:
min5 = dbConnect(SQLite(), dbname="5min.db")
# list of all tables:
dbListTables(min5)
# list of all columns in the table:
dbListFields(min5, dbListTables(min5)[4]) 

df = dbGetQuery(min5, "select station,flow,occupancy,speed from '5min' 
                          where date='04/02/2018' ")
names(df)

# Fuzzy C-Means Clustering of VDS based on speed and flow at 5-min intervals
features = as.matrix(df[,c(2,4)])
features = na.omit(features)    # temporary solution; imputation may be necessary

pfcm = pfcm(features, centers = 3)    # extremely slow
# KNN is O(n*c*d*i) while FCM is O(n*c^2*d*i)
summary(pcfm)

# Standard K-Means Clustering 
(kmn = kmeans(features,3,nstart=10))


dbDisconnect(min5)
