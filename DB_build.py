### Instructions for building sqlite DB using PeMS Data ###
# 
import numpy as np
import pandas as pd
import csv, sqlite3
import os

os.chdir('./traffic')

# Consider following a sqlite3 tutorial:
# http://sebastianraschka.com/Articles/2014_sqlite_in_python_tutorial.html
    
trafficDB = sqlite3.connect("5min.db",timeout=100)


res = trafficDB.execute("SELECT name FROM sqlite_master WHERE type='table';")
print(res.fetchall()) # example of how to get the first table name (str)


# 5MIN
# 52 COLUMNS, but only 11 are labeled
beginning_names = ["timestamp", "station", "district", "freeway", "direction", "length", "numSamples", "percentObs", "flow", "occupancy", "speed"]
# this file is a concatenation of all the downloaded files for April 2018 (02-27)
# use this bash command:
# cat d04_text_station_5min_2018_04_*.txt.gz > all_d04_text_station_5min_2018_04.txt.gz
all_five_min = pd.read_csv("./data/all_d04_text_station_5min_2018_04.txt.gz",compression="gzip",
                           header=None,usecols=range(11),names=beginning_names)
all_five_min[['date','timestamp']] = all_five_min['timestamp'].str.split(' ',expand=True)
all_five_min.to_sql("5min", trafficDB, if_exists='replace')

# METADATA
meta_headers = ["station","freeway","direction","district","county","city","state_PM","abs_PM","latitude","longitude","length","type","noLanes","name"]
d04_meta = pd.read_table("./data/d04_text_meta_2018_04_13.txt",header=None,skiprows=1,usecols=range(14),names=meta_headers)
d04_meta.to_sql("d04_metadata",trafficDB,if_exists='fail')

# PeMS BOTTLENECKS
bottle_headers = ["station","name","type","shift","freeway","abs_PM","state_PM","latitude","longitude","days_active","avg_extent(mi)","total_delay(veh-hrs)","total_duration(mins)"]
bottlenecks = pd.read_table("./data/d04_top_bottlenecks_4_02_4_27.txt",header=None,skiprows=1,names=bottle_headers)
bottlenecks["freeway"], bottlenecks["direction"] = zip(*bottlenecks["freeway"].str.split("-").tolist())
tempCol = bottlenecks["direction"]
bottlenecks = bottlenecks.drop("direction",axis=1)
bottlenecks.insert(5,"direction",tempCol)
bottlenecks.to_sql("d04_bottlenecks_april",trafficDB,if_exists='fail')

# PeMS BOTTLENECKS -- WEEKDAYS ONLY, NORMALIZED
bottle_headers_2 = ["station","name","type","shift","freeway","abs_PM","state_PM","latitude","longitude","days_active","avg_extent(mi)","total_delay(veh-hrs)","avg_duration(mins)"]
bottlenecks2 = pd.read_table("./data/d04_top_bottlenecks_weekdays_4_02_4_27_t45_normalized.txt",header=None,skiprows=1,names=bottle_headers_2)
bottlenecks2["freeway"], bottlenecks2["direction"] = zip(*bottlenecks2["freeway"].str.split("-").tolist())
tempCol = bottlenecks2["direction"]
bottlenecks2 = bottlenecks2.drop("direction",axis=1)
bottlenecks2.insert(5,"direction",tempCol)
bottlenecks2.to_sql("d04_bottlenecks_april_t45_normalized",trafficDB,if_exists='fail')

trafficDB.close()
