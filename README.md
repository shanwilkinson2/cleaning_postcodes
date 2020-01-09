# cleaning_postcodes

* Function which aims to take postcodes inputted & correct common errors so the postcodes can be matched to a list of existing postcodes
* Does not check if the postcodes actually exist, just that the format is compatible with those that do exist.

## errors currently corrected:
* lowercase
* leading/ trailing spaces
* special characters to numbers (ie !"£ to 123)
* double space changed to single space
* no spaces
## not yet corrected 
* spaces in the wrong place
* O to 0 where it must be a number
