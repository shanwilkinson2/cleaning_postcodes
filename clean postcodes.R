library(dplyr)
library(stringr)
# library(assertive)
# library(purrr)

# create sample postcodes 
  pcodes <- c("M1 1AF", "M46 0AA", "BL1 1RU", "bl1 1ru", " bl! 1ru" , 
              "SY11 2PR", "  W1A 1AA", "SW1A 1AA", "M46 OAA", "BL1", 
              "BOLTON", "bl! 1R", "bl1  1ru", "BL1  1RU", "WN  1 2  DA",
              '!\"£$%^&*()', "BL& $RR", 'BL$ "RF', "BL1 1PPP", "BL11PP")

clean_postcodes <- function(pcodes) {  
  pcode_regex <- "^[A-Z]{1,2}\\d[A-Z\\d]? {1}\\d[A-Z]{2}$"
  
# create a dataframe to hold input postcode, whether postcode is valid as it is, 
  # output postcode, whether pcode is finally valid
  output <- data.frame(input_pcode = as.character(pcodes), 
                      input_valid = str_detect(pcodes, pcode_regex),
                      output_pcode = as.character(pcodes),
                      stringsAsFactors = FALSE)
  output$output_valid <- output$input_valid

# trim trailing & leading whitespace, convert to uppercase, replace double spaces, check if valid now   
  output$output_pcode <- ifelse(output$output_valid == FALSE, 
                                yes = output$output_pcode %>%
                                  str_trim() %>%
                                  str_to_upper() %>%
                                  str_replace_all("  ", " "), 
                                no = output$output_pcode)
  output$output_valid <- ifelse(str_detect(output$output_pcode, 
                                          pcode_regex), 
                               yes = TRUE, no = FALSE)

# get rid of any special characters & check again
  output$output_pcode <- ifelse(output$output_valid == FALSE, 
                                yes = output$output_pcode %>%
                                  str_replace_all("!", "1") %>%
                                  str_replace_all('\"', '2') %>% 
                                  str_replace_all("\\$", "4") %>%
                                  str_replace_all("£", "3") %>%
                                  str_replace_all("%", "5") %>%
                                  str_replace_all('\\^', '6') %>% 
                                  str_replace_all("&", "7") %>%
                                  str_replace_all("\\*", "8") %>%
                                  str_replace_all("\\(", "9") %>%
                                  str_replace_all("\\)", "0"),
                                no = output$output_pcode)
  output$output_valid <- ifelse(str_detect(output$output_pcode, 
                                           pcode_regex), 
                                yes = TRUE, no = FALSE)
  
  return(output)
}
  
# This doesn't cover overseas territories and only enforces the format, NOT the existence of different areas. It is based on the following rules:
# 
# Can accept the following formats:
# 
# “GIR 0AA”
# A9 9ZZ
# A99 9ZZ
# AB9 9ZZ
# AB99 9ZZ
# A9C 9ZZ
# AD9E 9ZZ
# Where:
# 
# 9 can be any single digit number.
# A can be any letter except for Q, V or X.
# B can be any letter except for I, J or Z.
# C can be any letter except for I, L, M, N, O, P, Q, R, V, X, Y or Z.
# D can be any letter except for I, J or Z.
# E can be any of A, B, E, H, M, N, P, R, V, W, X or Y.
# Z can be any letter except for C, I, K, M, O or V.