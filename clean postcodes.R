library(dplyr)
library(stringr)

# create sample postcodes 
pcodes <- c("M1 1AF", "M46 0AA", "BL1 1RU", "SY11 2PR", "W1A 1AA", "SW1A 1AA", "M46 OAA", "BL1", "BOLTON", "bl! 1R", "bl1 1ru", "BL1  1RU")

#"^[A-Z]{1,2}\d[A-Z\d]? ?\d[A-Z]{2}$"

str_detect(pcodes, "^[A-Z]{1,2}\\d[A-Z\\d]? ?\\d[A-Z]{2}$")


  
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