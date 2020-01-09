# cleaning_postcodes

* Function which aims to take postcodes inputted & correct common errors so the postcodes can be matched to a list of existing postcodes
* Does not check if the postcodes actually exist, just that the format is compatible with those that do exist.

## errors currently corrected:
* lowercase
* leading/ trailing spaces
* special characters to numbers (ie !"£ to 123)
* other special characters deleted
* double space changed to single space
* no spaces - space inserted 4 from the end
## not yet corrected 
* spaces in the wrong place
* O to 0, E for 3 where it must be a number
* extra text at beginning or end eg part answer to another question
* extra non letter characters eg . instead of space

