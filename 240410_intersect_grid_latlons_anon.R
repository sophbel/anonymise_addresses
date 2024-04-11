install.packages("sf","dplyr","ncdf4","raster","mapview")

library(sf)
library(dplyr)
library(ncdf4)
library(raster)
library(mapview)


# file with an example of CALIOPE model
### downloaded file
grid_filename <- "/home/sbelman/Documents/BRD/incidence/anon_grid_intersect/data/sconcno2_singleday.nc"
# replace here the path to your csv file containing point data (lat,lon)
## read in address data including any crucial name or ID and the address (street, number, zip code, barrio, city) [it is somewhat flexible but check converted longs. and lats. on map at the end to ensure they are sensible]
df<-data.frame(patient_id=c('1a','1b','1c','1d','1e'),name=c("Sophies House", "Bloc District","BSC","Mexcla","Acellera Labs SL"),address=c("C. de Nàpols, 281, Gràcia, 08025 Barcelona","Carrer de Zamora, 96-106, Sant Martí, 08018 Barcelona","Plaça d'Eusebi Güell, 1-3, Les Corts, 08034 Barcelona","C/ de Ramón y Cajal, 35, Gràcia, 08012 Barcelona","C/ del Dr. Trueta, 183, Sant Martí, 08005 Barcelona"))
## convert addresses to latitude and longitude
lat_lons_file<- df %>%
  geocode(address, method = 'osm', lat = latitude , long = longitude)%>%
  data.frame()

# ---
# projection of model grid
## alternative projection which you could use
# proj <- "+proj=utm +zone=31 +ellps=intl +units=m +no_defs"

# read file containing AQ daily means of gridded corrected data
GRID <- raster(grid_filename, crs=4326) %>% 
  rasterToPolygons()

daily_sf <- st_as_sf(GRID, crs=4326)
daily_sf <- daily_sf %>% 
    st_transform(4326)


# generate a column to identify model grid cells
daily_sf$grid_ID <- 1:nrow(daily_sf)


## convert latitudes and longitudes to simple features (sf) file
latlons <- st_as_sf(lat_lons_file, coords = c("longitude", "latitude"))
## set the crs and transform to match the air qualty data
latlons <- st_set_crs(latlons, 4326) 

## check CRS match
if((st_crs(latlons)==st_crs(daily_sf)) ==TRUE) {print("CRS projections match")}

# intersect the daily gridded data with the latitude and longitude point data in the simple features file
areas_intersect <- st_intersection(daily_sf, latlons)

## plot to ensure that the points overlap with the gridded data
p<-ggplot()+
  geom_sf(data=daily_sf,aes(fill=Nitrogen.Dioxide.Concentration),color=NA)+
  geom_sf(data=latlons)
ggsave(p,file="/home/sbelman/Documents/BRD/incidence/anon_grid_intersect/output/intersection_plot.png")

anonymized_IDs<-st_drop_geometry(areas_intersect[c("grid_ID","patient_id")])
write.table(anonymized_IDs,file="/home/sbelman/Documents/BRD/incidence/anon_grid_intersect/output/anonymized_IDs.csv",sep = ",",quote = FALSE,col.names =TRUE,row.names = FALSE)



mapview(latlons)+
  mapview(daily_sf)
