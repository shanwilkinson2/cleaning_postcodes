# postcode lookup

# from ONS open geography portal https://geoportal.statistics.gov.uk/
# ONS postcode directory

library(data.table)
library(dplyr)

pcode_folder <- "G:\\Mapping Data\\Postcode files\\"
pcode_folder2 <- "ONSPD_AUG_2022_UK/"

postcodes_BL <- fread(paste0(pcode_folder, pcode_folder2, "Data/", "multi_csv/ONSPD_AUG_2022_UK_BL.csv"))
postcodes_WN <- fread(paste0(pcode_folder, pcode_folder2, "Data/", "multi_csv/ONSPD_AUG_2022_UK_WN.csv"))
postcodes_M <- fread(paste0(pcode_folder, pcode_folder2, "Data/", "multi_csv/ONSPD_AUG_2022_UK_M.csv"))

postcodes <- rbind(postcodes_BL, postcodes_WN) %>%
  rbind(postcodes_M)

# remove seperate files
  rm(postcodes_BL)
  rm(postcodes_WN)
  rm(postcodes_M)

bolton_postcodes <- postcodes %>% 
  filter(oslaua == "E08000001") %>%
  select(-c(lsoa01, msoa01, oa01, oac01, ))

bolton_postcodes2 <- bolton_postcodes %>%
  # change date so it's the date of issue: YYYYMM
  mutate(terminated = ifelse(doterm<202208, TRUE, FALSE),
         terminated = ifelse(is.na(terminated), FALSE, TRUE)) # doterm = date of termination YYYYMM

# stuff to add in - come with the postcode download
ward_names <- fread(paste0(pcode_folder, pcode_folder2, "Documents/", "Ward names and codes UK as at 05_22_onspd_v2.csv"))
msoa_names <- fread(paste0(pcode_folder, pcode_folder2, "Documents/","MSOA (2021) names and codes EW as at 12_21.csv"))
lsoa_names <- fread(paste0(pcode_folder, pcode_folder2, "Documents/","LSOA (2021) names and codes EW as at 12_21.csv"))
oa_classification <- fread(paste0(pcode_folder, pcode_folder2, "Documents/","2011 Census Output Area Classification Names and Codes UK.csv"))

# house of commons library names 
msoa_hocnames <- read.csv(paste0(pcode_folder, "HoC MSOA-Names-2.2.csv"))
# names(msoa_hocnames)[1] <- "msoa21cd"
msoa_hocnames <- msoa_hocnames %>%
  select(msoa21cd, msoa_hocname = msoa21hclnm)

# IMD
    imd <- fread("G:\\Mapping Data\\R/imd2019_domains.csv") %>%
      janitor::clean_names() %>%
      select(-c(lsoa_name, la_code, la_name))
    
# neighbourhoods
    neighbourhoods <- fread(paste0(pcode_folder, "neighbourhoods_lsoa_lookup.csv"))
    

# joins
bolton_postcodes3 <- bolton_postcodes2 %>%
  rename(msoa_code = msoa21) %>%
  left_join(msoa_names, by = c("msoa_code" = "MSOA21CD")) %>%
  left_join(msoa_hocnames, by = c("msoa_code" = "msoa21cd")) %>%
  relocate(msoa_hocname, .after = msoa_code) %>%
  relocate(MSOA21NM, .after = msoa_code) %>%

  left_join(lsoa_names, by = c("lsoa21" = "LSOA21CD")) %>%
  relocate(LSOA21NM, .after = lsoa21) %>%
  
  left_join(ward_names, by = c("osward" = "WD22CD")) %>%
  relocate(WD22NM, .after = osward) %>%
  
  left_join(neighbourhoods %>%
              select(lsoa_code = lsoa_name, neighbourhood_name, district_name),
            by = c("lsoa21" = "lsoa_code")) %>%
  
  left_join(imd %>%
              select(lsoa_code, imd_decile)
            , by = c("lsoa21" = "lsoa_code")) 

bolton_postcodes4 <- bolton_postcodes3 %>%
# rename
  rename(postcode = pcd,
    msoa_name = MSOA21NM, 
    lsoa_name = LSOA21NM, lsoa_code = lsoa21,
    ward_name = WD22NM, ward_code = osward,
    easting = oseast1m, northing = osnrth1m
    ) %>%
  mutate(postcode_nospaces = stringr::str_remove_all(postcode, " ")) %>% # gets rid of all spaces
  relocate(postcode_nospaces, .after = postcode) %>%
  select(postcode, postcode_nospaces, terminated, lsoa_code: lsoa_name, neighbourhood_name, district_name, imd_decile, 
         msoa_code: msoa_hocname, ward_code: ward_name, lat:long, easting:northing)

# save output
  fwrite(bolton_postcodes4, paste0(pcode_folder, "postcode lookup 2022-08.csv"))

# remove intermediate files
  rm(bolton_postcodes)
  rm(bolton_postcodes_live)
  rm(bolton_postcodes2)
  rm(bolton_postcodes3)
  rm(bolton_postcodes4)
  
  rm(imd)
  rm(lsoa_names)
  rm(msoa_hocnames)
  rm(msoa_names)
  rm(neighbourhoods)
  rm(ward_names)
  rm(pcode_folder)
  

