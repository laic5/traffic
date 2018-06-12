# Bay Area Traffic

Intelligent transport systems (ITS) are known to provide valuable insights regarding road congestion and traffic management. Using vehicle detector data from the Caltrans Performance Measurement System, we conducted both exploratory and explanatory analyses on Bay Area traffic flow, bottleneck behavior, bottleneck identification, potential causes of congestion, and long-term evolution of traffic. We we able to obtain preliminary evidence for traffic congestion using California Highway Patrol (CHP) reports. Weather reports were also collected from external sources to help explain patterns in traffic flow. These results were used to inform the bottleneck characterization process, in which we attempted to implement the CalTrans’ identification algorithm and cluster the results after collecting informative features that were not used in the original procedure. While no discernable improvements could be made, several problems were identified in the original methods that interfered with analysis. In closing, we created animations of vehicle delay in select highway regions and highlighted cases where traffic intensity evidently increased over year-long spans.

We used publicly available data from [PeMS](http://pems.dot.ca.gov) to extract findings for traffic over time. We focused primarily on the Bay Area region. Helpful variables we looked at include flow _(number of vehicles that crossed over a highway sensor during a time frame)_, speed _(in mpg)_, longitude/latitude, and more. Our interest in bottlenecks _(defined as negative differentials in flow over time)_ motivated our project. Our insights include
1. [Cluster analysis of bottlnecks](https://github.com/laic5/traffic/blob/master/docs/_layouts/bottleneck_exploratory.nb.pdf)
2. [Delays on Highway 101 going into San Francisco, 2014-2018](https://github.com/laic5/traffic/blob/master/docs/_layouts/fiveyear.pdf)
3. [Effects of intense rain on traffic patterns](https://github.com/laic5/traffic/blob/master/docs/_layouts/rain%20vis.pdf)

In conclusion, we have learned a lot about traffic patterns and bottlenecks in the Bay Area after exploring multiple sides of the PeMS sensor data. The weather and CHP incidents gave us insights on external factors affecting bottlenecks. The cluster analysis showed us how bottlenecks can differ from one another and what’s a typical bottleneck and what’s not. The 5 year analysis gave us an overall view of how traffic has changed in the past 5 years.

## Gallery of interesting visualizations from our report
![Delays in 2018](https://github.com/laic5/traffic/raw/master/plots/delay2018.gif)
![Congestion on I280 South](https://github.com/laic5/traffic/raw/master/plots/img1.png)
![Flow per Year on Highway 101](https://github.com/laic5/traffic/raw/master/plots/img2.png)
