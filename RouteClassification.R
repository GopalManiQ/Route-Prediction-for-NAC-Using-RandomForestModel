library(e1071)
library(vegan)
library(tidyr)
library(plyr)
library(VIM)
library(DMwR)
library(cluster)
library(fossil)
library(MASS)
library(caTools)
library(sqldf)
library(pdfCluster)
library(VGAM)
library("nnet")
library(randomForest)


rm(list=ls(all=TRUE))
setwd("C:\\Users\\Gopal Mukkamala\\Desktop\\Sid\'s Farm\\Vrushali mam\\Route Classification")

library("nnet")
library(VGAM)
#Read Customer Master 
CustomerData <- read.csv("customerMasterReport.csv", header = T, sep = ",")
#Read Aug Monthly Indent for Customer
MonthlyIndent <- read.csv("ordersCalenderCSV.csv", header = T, sep = ",") 


#PreProcessing
i=1
j=i+9
day=subset(MonthlyIndent,select=c(1:9))
str(day)
day$Day = i
I1=subset(MonthlyIndent,select=c(j))
day=cbind(day,I1)
names(day)[11]<-"Indent"
day$Month="Aug"
TotalMonthIndent=day
str(TotalMonthIndent)
for(i in 2:31)
{
  j=i+9
  day=subset(MonthlyIndent,select=c(1:9))
  str(day)
  day$Day = i
  I1=subset(MonthlyIndent,select=c(j))
  day=cbind(day,I1)
  str(day)
  names(day)[11]<-"Indent"
  day$Month="Aug"
  TotalMonthIndent=rbind(TotalMonthIndent,day)
}
TotalMonthCustomerIndent = sqldf("select * from TotalMonthIndent where Indent <> 0 and Indent <>''")
TotalMonthCustomerIndent
#Get current Route Wise Count
TotalCustomerRouteWiseCount = sqldf("select * from TotalMonthCustomerIndent where RouteName in('Aparna Towers',
                  'Hitech City',
                'Himayathnagar line',
                'jubilee hills,mehdipatnam,khairatabad route',
                'Begampet line',
                'TOLICHOWKI, ATTAPUR',
                'AMEENPUR, BEERAMGUDA',
                'VIVEKANANDA NAGAR ,ALLWYN  COLONY',
                'MASJIDBANDA',
                'NALLAGANDLA 1',
                'AMEERPET, SANATH NAGAR',
                'HICC ',
                'WHITE FIELDS 2',
                'Telecomnagar',
                'Kphb 6th phase and Kphb 9th phase',
                'FINANCIAL DISTRICT',
                'Moosapet',
                'Kondapur&RTO office',
                'PBEL CITY ROUTE',
                'JAINS CARLTON CREEK',
                'Secunderabad line',
                'Manikonda 2',
                'Golf View Agent (Kumar Swamy)',
                'Pragathinagar Bachupally',
                'Teja chandanagar 2',
                'KPHB5-JNTU',
                'KOKAPET',
                'WhiteFields',
                'L AND T',
                'SMR FOUNTAINHEAD & MATRUSREE NAGAR',
                'RICHMOND VILLAS',
                'SRINIVAS',
                'Miyapur',
                'TEJA CHANDANAGAR',
                'SUBRAMANIAM TELECOMNAGAR',
                'My Home Abhra',
                'Pragathinagar Bhavyanagar V.V.nagar',
                'Lodha and RTP',
                'Manikonda',
                'SUBBARAO',
                'Mantri',
                'NEW AREA CUSTOMERS')")
TotalCustomerRouteWiseCount = sqldf("select RouteName,count(distinct(CustomerId)) from TotalMonthCustomerIndent Group By RouteName")
write.csv(TotalCustomerRouteWiseCount, file = "RouteCount.csv",row.names=FALSE)
DaywiseIndentCount = sqldf("select day, count(Indent) from TotalMonthCustomerIndent Group By day")
write.csv(DaywiseIndentCount, file = "DaywiseIndentCount.csv",row.names=FALSE)

#Get all Route Data for MAP
MapData = sqldf("select * from CustomerData where ROUTE in('Aparna Towers',
                  'Hitech City',
                'Himayathnagar line',
                'jubilee hills,mehdipatnam,khairatabad route',
                'Begampet line',
                'TOLICHOWKI, ATTAPUR',
                'AMEENPUR, BEERAMGUDA',
                'VIVEKANANDA NAGAR ,ALLWYN  COLONY',
                'MASJIDBANDA',
                'NALLAGANDLA 1',
                'AMEERPET, SANATH NAGAR',
                'HICC ',
                'WHITE FIELDS 2',
                'Telecomnagar',
                'Kphb 6th phase and Kphb 9th phase',
                'FINANCIAL DISTRICT',
                'Moosapet',
                'Kondapur&RTO office',
                'PBEL CITY ROUTE',
                'JAINS CARLTON CREEK',
                'Secunderabad line',
                'Manikonda 2',
                'Golf View Agent (Kumar Swamy)',
                'Pragathinagar Bachupally',
                'Teja chandanagar 2',
                'KPHB5-JNTU',
                'KOKAPET',
                'WhiteFields',
                'L AND T',
                'SMR FOUNTAINHEAD & MATRUSREE NAGAR',
                'RICHMOND VILLAS',
                'SRINIVAS',
                'Miyapur',
                'TEJA CHANDANAGAR',
                'SUBRAMANIAM TELECOMNAGAR',
                'My Home Abhra',
                'Pragathinagar Bhavyanagar V.V.nagar',
                'Lodha and RTP',
                'Manikonda',
                'SUBBARAO',
                'Mantri',
                'NEW AREA CUSTOMERS')
                and LATITUDE <> '' and LONGITUDE <> ''")
write.csv(MapData, file = "MapData.csv",row.names=FALSE)

#Create Customer Data for Route Classification
TrainData = sqldf("select * from CustomerData where ROUTE in('Aparna Towers',
                  'Hitech City',
                  'Himayathnagar line',
                  'jubilee hills,mehdipatnam,khairatabad route',
                  'Begampet line',
                  'TOLICHOWKI, ATTAPUR',
                  'AMEENPUR, BEERAMGUDA',
                  'VIVEKANANDA NAGAR ,ALLWYN  COLONY',
                  'MASJIDBANDA',
                  'NALLAGANDLA 1',
                  'AMEERPET, SANATH NAGAR',
                  'HICC ',
                  'WHITE FIELDS 2',
                  'Telecomnagar',
                  'Kphb 6th phase and Kphb 9th phase',
                  'FINANCIAL DISTRICT',
                  'Moosapet',
                  'Kondapur&RTO office',
                  'PBEL CITY ROUTE',
                  'JAINS CARLTON CREEK',
                  'Secunderabad line',
                  'Manikonda 2',
                  'Golf View Agent (Kumar Swamy)',
                  'Pragathinagar Bachupally',
                  'Teja chandanagar 2',
                  'KPHB5-JNTU',
                  'KOKAPET',
                  'WhiteFields',
                  'L AND T',
                  'SMR FOUNTAINHEAD & MATRUSREE NAGAR',
                  'RICHMOND VILLAS',
                  'SRINIVAS',
                  'Miyapur',
                  'TEJA CHANDANAGAR',
                  'SUBRAMANIAM TELECOMNAGAR',
                  'My Home Abhra',
                  'Pragathinagar Bhavyanagar V.V.nagar',
                  'Lodha and RTP',
                  'Manikonda',
                  'SUBBARAO',
                  'Mantri')
                  and LATITUDE <> '' and LONGITUDE <> ''")
write.csv(TrainData, file = "TrainData.csv",row.names=FALSE)
TrainData <- read.csv("TrainData.csv", header = T, sep = ",")

#Create Customer Data for Route Classification Test Data
TestData = sqldf("select * from CustomerData where ROUTE = 'NEW AREA CUSTOMERS' and LATITUDE <> '' and LONGITUDE <> ''")
write.csv(TestData, file = "TestData.csv",row.names=FALSE)
TestData <- read.csv("TestData.csv", header = T, sep = ",")
str(TestData)
dim(TestData)

#Random Forest
RandomForestModel <- randomForest(ROUTE~LATITUDE+LONGITUDE,data=TrainData, keep.forest=TRUE, ntree=43)
prediction <-predict(RandomForestModel,TrainData,type="response", norm.votes=TRUE)
result_train <- table("actual _values"= TrainData$ROUTE,"pred-Route" = prediction)
result_train
ACC = (result_train[1,1]+result_train[2,2])/sum(result_train)
ACC
##Write Train prediction
dtTrain=data.frame(cbind(TrainData, prediction))
write.csv(dtTrain, file = "RFTrainPrediction.csv",row.names=FALSE)


#Read Test Data
str(TestData)
dim(TestData)
prediction <-predict(RandomForestModel,TestData,type="response", norm.votes=TRUE)
##Write Train prediction
dtTest=data.frame(cbind(TestData, prediction))
write.csv(dtTest, file = "RFTestPrediction.csv",row.names=FALSE)

#Combinedata for visualization
dtVis=data.frame(rbind(dtTrain,dtTest))
write.csv(dtVis, file = "RFVis.csv",row.names=FALSE)
aggdt=aggregate(dtVis[, 9:10], list(dtVis$ROUTE), mean)
write.csv(aggdt, file = "meanpoint.csv",row.names=FALSE)

#aggdt=aggregate(dtVis[, 9:10], list(dtVis$ROUTE), median)
#write.csv(aggdt, file = "medianpoint.csv",row.names=FALSE)
aggdt$RouteName = aggdt$Group.1
aggdt$MLATITUDE = aggdt$LATITUDE
aggdt$MLONGITUDE = aggdt$LONGITUDE
Distance = sqldf("select * from dtTest,aggdt where PREDICTION = RouteName")
write.csv(Distance, file = "Distance.csv",row.names=FALSE)

DistanceCSV <- read.csv("Distance.csv", header = T, sep = ",")
library(dplyr)

earth.dist <- function (lat1,long1,lat2,long2)
{
  rad <- pi/180
  a1 <- lat1 * rad
  a2 <- long1 * rad
  b1 <- lat2 * rad
  b2 <- long2 * rad
  dlon <- b2 - a2
  dlat <- b1 - a1
  a <- (sin(dlat/2))^2 + cos(a1) * cos(b1) * (sin(dlon/2))^2
  c <- 2 * atan2(sqrt(a), sqrt(1 - a))
  R <- 6378.145
  d <- R * c
  return(d)
}

for (row in 1:nrow(DistanceCSV)) { 
  DistanceCSV$kmd[row] <- earth.dist(DistanceCSV$LATITUDE[row],DistanceCSV$LONGITUDE[row],DistanceCSV$MLATITUDE[row],DistanceCSV$MLONGITUDE[row]) 
}
write.csv(DistanceCSV, file = "DistanceCSV_1.csv",row.names=FALSE)
str(DistanceCSV)
NACPredRoute=subset(DistanceCSV,select=-c(16:21))
str(NACPredRoute)
write.csv(NACPredRoute, file = "NACPredRoute.csv",row.names=FALSE)
PredictionRoute = sqldf("select prediction,count(Id) from NACPredRoute Group By prediction")
PredictionRoute
write.csv(PredictionRoute, file = "PredictionRoute.csv",row.names=FALSE)

ClusterData= sqldf("select * from NACPredRoute where kmd < 100")
kmeanTrainData=subset(ClusterData,select=c(LATITUDE,LONGITUDE))
sum(is.na(kmeanTrainData))
str(kmeanTrainData)
dim(kmeanTrainData)
# K-means:  Determine number of clusters by considering the withinness measure
wss <- 0
for (i in 1:10) {
  wss[i] <- sum(kmeans(kmeanTrainData,centers=i)$withinss)
}
plot(1:10, wss, 
     type="b", 
     xlab="Number of Clusters",
     ylab="Within groups sum of squares") 

set.seed(123)
fit <- kmeans(kmeanTrainData, 8) # 8 cluster solution
fit$withinss
fit$betweenss
#study the mdoel
fit$cluster

fit$tot.withinss
fit
fit$centers

mydata <- data.frame(kmeanTrainData, 
                     fit$cluster)
ClsuterData=cbind(ClusterData,mydata)
write.csv(ClsuterData,"kmeans.csv")


