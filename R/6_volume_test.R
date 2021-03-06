###############################################################################
# R Code: Using RGISTools to estimate the water levels in reservoirs and lakes
###############################################################################
# Militino, A.F., Montesino-SanMartin, Pérez-Goya, U.,M., Ugarte, M.D.
# Public University of Navarre
# License: Availability of material under 
# [CC-BY-SA](https://creativecommons.org/licenses/by-sa/2.0/).

###############################################################################
# PREPARATION
###############################################################################

# install lakemorpho
# install.packages(lakemorpho)

# load libraries
library(RGISTools)
library(lakemorpho)

# load results
load(url("https://raw.githubusercontent.com/mmontesinosanmartin/itoiz_article/master/Data/results_analysis.RData"))

altimetryUTM<-projectRaster(altimetry.itoiz,crs=CRS("+init=epsg:25830")) 
  

sel<-c(1,8,15,17,19,23,26) ## Landstat images
sen<-(1:28)[-sel]
names(imgs.ndwi)[sen] ## Sentinel images
  
b2<-array(0,length(sen)) ## Water Volume ##
b5<-array(0,length(sen)) ## length shoreline ##
b6<-array(0,length(sen)) ## Water surface ##

a0<-lapply(shorelns[sen],function(r){as(r,"Spatial")})
a1<-lapply(a0,function(r){spTransform(r,CRS("+init=epsg:25830"))})
a1.coor<-lapply(a1,function(r){coordinates(r)})

###############################################################################
# ANALYSIS
###############################################################################

for (i in 1:length(sen)) { 
  a2<-a1[[i]]
  plot(a2,main=paste(i))
  
  a2.coor<-coordinates(a2) 
  a2.poli<-Polygon(a2.coor[[1]][[1]])
  
  Srs1 = Polygons(list(a2.poli), "s1")
  SpP = SpatialPolygons(list(Srs1)) 
  crs(SpP)<-proj4string(a2)
  centroids <- coordinates(SpP)
  x <- centroids[,1]
  y <- centroids[,2] 
  SpP.SPDF <- SpatialPolygonsDataFrame(SpP,data=data.frame(x=x, y=y,row.names=row.names(SpP)))
  
  input<-lakeSurroundTopo(SpP.SPDF,altimetryUTM)
  b2[i]<-lakeVolume(input)/1e+6
  b5[i]<-lakeShorelineLength(input)/1e3
  b6[i]<-lakeSurfaceArea(input)/1e4
  
  aux<-c(i,b2[i],b5[i],b6[i])
  names(aux)<-c("num","Volume hm3","length km","surface ha")
  print(aux)
}
 

 
indice<-c(1,1,2,2,2,3,3,4,4,5,5,5,6,7,7,7,7,8,8,8,9)
mes<-c("Jul18","Aug18","Sep18","Oct18","Dic18","Jan19","Feb19","Mar19","Apr19")
b0<-data.frame(b2,b5,b6,indice)
b1<-aggregate(b0,list(indice),mean)
b1$mes<-mes

###############################################################################
# REPRESENTATION
###############################################################################

par(mfrow=c(2,2))

# volume
plot(b1[,2],type="l",main="Water Volume (hm3)",axes=F,ylab="",xlab="")
axis(1,1:9,mes)
axis(2)
box()

# length shoreline
plot(b1[,3],type="l",main="Length Shoreline (km)",axes=F,ylab="",xlab="")
axis(1,1:9,mes)
axis(2)
box()

# water surface
plot(b1[,4],type="l",main="Water Surface (ha)",axes=F,ylab="",xlab="")
axis(1,1:9,mes)
axis(2)
box()
########### 


