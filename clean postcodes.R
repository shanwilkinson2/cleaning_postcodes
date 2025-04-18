library(dplyr)
library(stringr)
library(glue)
library(magrittr)

# library(assertive)
# library(purrr)

# create sample postcodes 
  pcodes <- c("M1 1AF", "M46 0AA", "BL1 1RU", "bl1 1ru", " bl! 1ru" , 
              "SY11 2PR", "  W1A 1AA", "SW1A 1AA", "M46 OAA", "BL1", 
              "BOLTON", "bl! 1R", "bl1  1ru", "BL1  1RU", "WN  1 2  DA",
              '!\"£$%^&*()', "BL& $RR", 'BL$ "RF', "BL1 1PPP", "BL11PP", 
              "M11af", "sw1a1AA", "Westhoughton", "M4. 5UP,", "bl 15AX",
              "41 High Street, Bolton, BL3 6HJ", "6 Park Road Westhoughton SW1A 1AA", "14 Church Rd, Bolton",
             "bl1&nbsp;1pp")

clean_postcodes <- function(pcodes) {  
  
# regex to match postcode format  
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
                                  str_replace_all("&NBSP;", " ") %>%
                                  str_replace_all("  ", " "), 
                                no = output$output_pcode)
  
  # check for postcode validity 
    # <<- assigns from parent environments 
    # <- doesn't work as it only uses a local version within the check_again function
  check_again <- function() {
    output$output_valid <<- ifelse(str_detect(output$output_pcode, 
                                          pcode_regex), 
                               yes = TRUE, no = FALSE)
  }
  check_again()

# get rid of any special characters & check again
  # [[:punct:]] = punctuation
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
                                  str_replace_all("\\)", "0") %>%
                                  str_replace_all("[[:punct:]]", ""),
                                no = output$output_pcode)
  check_again()
  
# strip postcode out of other text
  output$output_pcode <- ifelse(output$output_valid == FALSE, 
                                yes = ifelse(str_detect(output$output_pcode, "[A-Z]{1,2}\\d[A-Z\\d]? {1}\\d[A-Z]{2}") == TRUE, 
                                             yes = str_extract(output$output_pcode, "[A-Z]{1,2}\\d[A-Z\\d]? {1}\\d[A-Z]{2}"),
                                             no = output$output_pcode),
                                no = output$output_pcode)
  check_again()
  
# dodgy spacing 
  # more than one space - get rid of all spaces
  output$output_pcode <- ifelse(output$output_valid == FALSE &
                                between(str_count(output$output_pcode, "[:alnum:]"), 5, 7) & # 5-7 letters and/or numbers 
                                str_count(output$output_pcode, "\\s") > 1, # more than 1 space
                                yes = str_replace_all(output$output_pcode, "\\s", ""), # no spaces, can put single space in below
                                no = output$output_pcode)  

  # one space in the wrong place - get rid of it
  output$output_pcode <- ifelse((output$output_valid == FALSE & 
                                   str_count(output$output_pcode, "\\s") == 1 & 
                                   str_detect(output$output_pcode, "^[A-Z]{1,2}\\d[A-Z\\d]? {1}") == FALSE), # first half of postcode with space in right place
                                yes = str_replace_all(output$output_pcode, "\\s", ""), 
                                no = output$output_pcode)
  # no spaces - if postcode length is between 5 & 7, put one in 4 from the end
  output$output_pcode <- ifelse((output$output_valid == FALSE & 
                                   str_count(output$output_pcode, "\\s") == 0 & 
                                   between(nchar(output$output_pcode), 5, 7)),
                                yes = paste(str_sub(output$output_pcode, 1, -4), 
                                            str_sub(output$output_pcode, -3, -1)), 
                                no = output$output_pcode)
  check_again()
  
# numbers to letters & vice versa (but only in the second half as where they tend to crop up)
  # o to zero
  output$output_pcode <- ifelse((output$output_valid == FALSE & 
                                 str_detect(output$output_pcode, "^[A-Z]{1,2}\\d[A-Z\\d]? {1}O")), # first half of postcode followed by letter O
                                yes = paste0(str_sub(output$output_pcode, 1, -4), "0",
                                            str_sub(output$output_pcode, -2, -1)), 
                                no = output$output_pcode)
  # check again
  check_again()  
  
  # message - summary of those that needed cleaning & how many were successfully cleaned

    cleaning_stats <- output[output$input_valid == FALSE, c(2,4)]
    message(glue("{length(which(cleaning_stats$output_valid == TRUE))}/{nrow(cleaning_stats)} ",
                 "({round(length(which(cleaning_stats$output_valid == TRUE))/nrow(cleaning_stats)*100)}%) ",
                 "of initially invalid postcodes were successfully cleaned"))
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
