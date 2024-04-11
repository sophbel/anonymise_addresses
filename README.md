# Anonymise Addresses in Catalonia to 1km Grid Square IDs

## Steps to run

### install R packages
```install.packages("sf","dplyr","ncdf4","raster","mapview")``` <br>
### clone this repository into your computer using git clone
```git clone https://github.com/sophbel/anonymise_addresses.git```

### Open '240410_intersect_grid_latlons_anon.R'
Change the code to read in a CSV containing the addresses and an identifiable ID for each line. Line 20 contains the test data frame. Comment this out and replace line 18 with your data.


