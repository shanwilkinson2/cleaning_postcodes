# cleaning_postcodes

* Function which aims to take postcodes inputted (as either a vector or column of a dataframe) & correct common errors so the postcodes can be matched to a list of existing postcodes
* Does not check if the postcodes actually exist, just that the format is compatible with those that do exist
* Only checks for full postcodes not part postcodes

## errors currently corrected:
* lowercase
* leading/ trailing spaces
* special characters to numbers (ie !"£ to 123)
* other special characters deleted
* double space changed to single space
* strips postcode out of an address
* no spaces - space inserted 4 from the end
* more than one space not double
* single space in the wrong place
* o to zero in second half only eg WA11 OQZ to WA11 0QZ 

## not yet corrected 
* E for 3 where it must be a number


