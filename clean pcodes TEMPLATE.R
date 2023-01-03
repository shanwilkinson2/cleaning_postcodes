# clean postcodes 

#######################################################################################################

# instructions:
  # save file to be cleaned in the named folder (or change the named folder to where it is)
  # make sure the column containing the postcodes to be cleaned has a single row above the postcodes 
    # containing the title "raw_pcode"
  # change named filename to the name of your file. 
    # must include the file extension e.g. ".xlsx"
  # run the rest of the code
  # output file will be in the named folder with the same name but "cleaned" added

# change this bit #####################################################################################

# filename to read in
  # folders can't be separated by \ must be either \\ or/
    file_location <- "C:\\Temp"
  # filename must include file extension eg .xlsx
    # add a column title for the postcodes called "raw_pcode", taking up 1 row only, 
    # row 2 onwards are assumed to contain the data, delete any extra heading rows, or add a heading row if needed
    filename <- "Postcodes for Rebecca 2022-12-12.xlsx"
    
# run the rest #######################################################################################

# load packages
  library(dplyr)
  library(readxl)
  library(writexl)
  library(stringr)
  library(data.table)    
    
# get postcode cleaning function
  source("G:\\Mapping Data\\R\\clean_postcodes/clean postcodes function.R")

# read in data
  pcode_file <- read_xlsx(paste0(file_location,"/", filename))
  
# read in postcode lookup - check it's the latest dated version
  postcode_lookup <- fread(paste0("G:\\Mapping Data\\Postcode files/", "postcode lookup 2021-11.csv"))  
 
# pick out the postcode field, do the cleaning & join in postcode lookup fields  
   pcodes_to_clean <- pcode_file %>%
    # select just postcode
    select(raw_pcode) %>%
    # add output of postcode cleaning function
    cbind(clean_postcodes(pcode_file$raw_pcode)) %>%
    # add in postcode lookup fields
    left_join(postcode_lookup,
             by = c("output_pcode" = "postcode"))

# add new fields to file
   pcode_file_out <- cbind(pcode_file, 
                           pcodes_to_clean %>% 
                             # raw_pcode is in both, take it out of the cleaned file
                             select(-raw_pcode)
                           )

# save file in same location as input file with same name 
  # cuts off old file extension assuming it's .xlsx (ie 1st character to 6th from the end)
  # save as xlsx 
  write_xlsx(pcode_file_out, paste0(file_location, "/", stringr::str_sub(filename, 1, -6), " cleaned.xlsx"))
