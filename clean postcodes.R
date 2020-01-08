library(dplyr)
library(stringr)
# library(purrr)

# create sample postcodes 
  pcodes <- c("M1 1AF", "M46 0AA", "BL1 1RU", "bl1 1ru", " bl! 1ru" , "SY11 2PR", "  W1A 1AA", "SW1A 1AA", "M46 OAA", "BL1", "BOLTON", "bl! 1R", "bl1  1ru", "BL1  1RU")

# create a dataframe to hold input postcode, output postcode, whether postcode is valid as it is
  output <- data.frame(input_pcode = as.character(pcodes), 
                      valid = str_detect(pcodes, "^[A-Z]{1,2}\\d[A-Z\\d]? ?\\d[A-Z]{2}$"),
                      stringsAsFactors = FALSE)

# if postcode is valid as it is, copy input postcode to output postcode  
  output$output_pcode <- ifelse(output$valid == TRUE, yes = output$input_pcode, no = "")

# want to keep the column as initial validity so can see how much time it's saved. 
  # create a new valid vector as cleaning is done
  output$final_valid <- output$valid
  
# trim trailing & leading whitespace, convert to uppercase, replace double spaces, check if valid now   
  output$output_pcode <- ifelse(output$valid == FALSE, 
                                yes = output$input_pcode %>%
                                  str_trim() %>%
                                  str_to_upper() %>%
                                  str_replace_all("  ", " "), 
                                no = output$output_pcode)
  output$final_valid <- ifelse(str_detect(output$output_pcode, "^[A-Z]{1,2}\\d[A-Z\\d]? ?\\d[A-Z]{2}$"), yes = TRUE, no = FALSE)

  
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