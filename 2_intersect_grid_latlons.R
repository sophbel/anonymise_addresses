
library(sf)
library(dplyr)
library(ncdf4)
library(raster)


# PARAMETERS ---
# file with an example of CALIOPE model
### direct from esarchive when accessed from the workstation
# grid_filename <- "/esarchive/scratch/ccarnere/AQS_database/postprocessed/regional/daily_means/sconcno2/sconcno2_2017091700.nc"
### locally accessing the mounted esarchive
# grid_filename <- "/home/sbelman/Documents/esarchive/scratch/ccarnere/AQS_database/postprocessed/regional/daily_means/sconcno2/sconcno2_2017091700.nc"
### downloaded file
grid_filename <- "/home/sbelman/Documents/BRD/incidence/anonymize/data/sconcno2_2017091700.nc"
# replace here the path to your csv file containing point data (lat,lon)
# latlons_filename <- "/esarchive/scratch/.....csv"
# latlons_filename <-readRDS("/home/sbelman/Documents/BRD/incidence/anonymize/data/lat_longs.RData")
# latlons_filename <-"/home/sbelman/Documents/BRD/incidence/anonymize/data/lat_longs.RData"
## read in address data including any crucial name or ID and the address (street, number, zip code, barrio, city) [it is somewhat flexible but check converted longs. and lats. on map at the end to ensure they are sensible]
df<-data.frame(name=c("Sophies House", "Bloc District","BSC","Mexcla","Acellera Labs SL"),address=c("C. de Nàpols, 281, Gràcia, 08025 Barcelona","Carrer de Zamora, 96-106, Sant Martí, 08018 Barcelona","Plaça d'Eusebi Güell, 1-3, Les Corts, 08034 Barcelona","C/ de Ramón y Cajal, 35, Gràcia, 08012 Barcelona","C/ del Dr. Trueta, 183, Sant Martí, 08005 Barcelona"))
## convert addresses to latitude and longitude
lat_lons_file<- df %>%
  geocode(address, method = 'osm', lat = latitude , long = longitude)%>%
  data.frame()

# ---

# projection of model grid
proj <- "+proj=utm +zone=31 +ellps=intl +units=m +no_defs"

# read file containing AQ daily means of gridded corrected data
GRID <- raster(grid_filename, crs=4326) %>% 
  rasterToPolygons()

daily_sf <- st_as_sf(GRID, crs=4326)
daily_sf <- daily_sf %>% 
  # st_transform(CRS(proj))
st_transform(4326)


# generate a column to identify model grid cells
daily_sf$grid_ID <- 1:nrow(daily_sf)


## convert latitudes and longitudes to simple features (sf) file
latlons <- st_as_sf(lat_lons_file, coords = c("longitude", "latitude"))
## set the crs and transform to match the air qualty data
latlons <- st_set_crs(latlons, 4326) 

## check CRS match
(st_crs(latlons)==st_crs(daily_sf))

# intersect the daily gridded data with the latitude and longitude point data in the simple features file
areas_intersect <- st_intersection(daily_sf, latlons)


ggplot()+
  geom_sf(data=daily_sf,aes(fill=Nitrogen.Dioxide.Concentration),color=NA)+
  geom_sf(data=latlons)

ggplot(latlons)+
  geom_sf()



