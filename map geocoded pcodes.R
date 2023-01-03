library(dplyr)
library(leaflet)
library(leaflet.extras)
library(sf)

# map geocoded postcodes to points & an MSOA choropleth

# fill in this #########################################################

  # file location either needs to be \\ or / NOT \
  file_location <- "G:\\Mapping Data\\R\\clean_postcodes"
  filename <- "comm champs 2022-11-22 cleaned.xlsx"
  
# run the rest #######################################################
  

# read in file containing lat long (e.g. as created by postcode cleaning)
  # needs lat/ long rather than easting/ northing as interactive map is round projection not flat
  geocoded_pcodes <- readxl::read_xlsx(paste0(file_location,"/", filename))

# get borough boundary to put on the map
  # borough boundaries
    boroughs <- st_read("G:\\Mapping Data\\R\\map\\OS boundary file\\Data\\GB\\district_borough_unitary.TAB")
    boroughs <- boroughs %>%
      mutate(borough = stringr::str_remove(Name, " District \\(B\\)")) %>%
      st_transform(crs = 4326) # transforms to lat/ long from OSGB36  
  
  # filter boroughs Bolton only
  boroughs_bolton <- filter(boroughs, borough %in% "Bolton")
  # plot(st_geometry(boroughs_bolton)) # check areas look right 
  rm(boroughs) # remove whole country of boroughs
  
# sort MSOA boundaries & names
  # MSOA  
  # https://geoportal.statistics.gov.uk/datasets/middle-layer-super-output-areas-december-2011-boundaries-bgc
  msoas_2011 <- st_read("G:\\Mapping Data\\R\\map\\MSOA/Middle_Layer_Super_Output_Areas_December_2011_Boundaries_BGC.shp")
  
  # add borough variable from MSOA name
  msoas_2011 <- msoas_2011 %>%
    mutate(borough = stringr::str_sub(msoa11nm, 1, nchar(as.character(msoa11nm))-4)) %>%
    st_transform(crs = 4326) # transforms to lat/ long from OSGB36
  
  # filter msoas 2011 Bolton only
  msoas_bolton <- filter(msoas_2011, borough %in% "Bolton")
  # plot(st_geometry(msoas_bolton)) # check areas look right  
  rm(msoas_2011) # remove whole country of lsoas
  
  # get house of commons library names 
  msoa_hocnames <- read.csv("G:\\Mapping Data\\Postcode files/HoC MSOA-Names-2.2.csv")
  
  # join house of commons library names to boundaries
  msoas_bolton <- left_join(msoas_bolton, msoa_hocnames, 
                              by = c("msoa11cd" = "msoa21cd"))

# summarise counts to MSOA
  pcode_msoa_summary <- geocoded_pcodes %>%
    group_by(msoa_code) %>%
    summarise(num_items = n()) 
  pcode_msoa_summary <- msoas_bolton %>%
    # join to msoa boundary
    left_join(pcode_msoa_summary, 
              by = c("msoa11cd" = "msoa_code")) %>%
    # recode missing counts as zero
    mutate(num_items = ifelse(is.na(num_items), 0, num_items))
  
# make a map #################################################################
  # to save remove # before 'my_map' 
  # red message 'Data contains xxx rows with either missing or invalid lat/lon values and will be ignored' 
    # will come up if some postcodes didn't match
  
##############################################################################  
  
# make a palette for choropleth
  # colorNumeric = continuous variable
  my_pal <- colorNumeric(palette = "Blues",
                    domain = pcode_msoa_summary$num_items,
                    reverse = FALSE
                    )
  
# remove the hash before "my_map" when you're ready to save
# my_map <-   
  leaflet(geocoded_pcodes) %>%
    # B&W basemap
      addProviderTiles("Stamen.TonerLite") %>%
    # out outline for borough boundary
      addPolylines(data = boroughs_bolton, color = "black", weight = 3) %>%
    # add msoa choropleth layer
      addPolygons(data = pcode_msoa_summary,
                  weight = 1.5, color = "grey",
                  fillColor = ~my_pal(num_items), fillOpacity = 0.5,
                  label = ~paste("MSOA:", msoa11nm, msoa21hclnm, num_items),
                  group = "MSOAs"
      ) %>%
    # add circle markers for postcodes
    addCircleMarkers(lng = ~long, lat = ~lat, 
                     color = "green",
                     radius =3,
                     label = ~output_pcode,
                     group = "Postcodes") %>%
    # add a layers control to turn on & off stuff in 'group'
    addLayersControl(overlayGroups = c("Postcodes", "MSOAs"), 
                     position = "topleft") %>%
    # Add a legend for the choropleth
    addLegend(position = "bottomright", 
              pal = my_pal, 
              values = ~pcode_msoa_summary$num_items,
              title = "Number of items", # <------------ WRITE TITLE HERE
              opacity = 0.8) %>%
    # add a button that resets the view
    addResetMapButton() %>%
    # add a title
    addControl("<b>Write title here</b>", # <----------- WRITE TITLE HERE
               position = "topright")

  
# save map  
  htmlwidgets::saveWidget(my_map, paste0(file_location, "/", "map.html"))