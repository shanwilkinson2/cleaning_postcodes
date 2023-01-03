# cleaning postcodes

## Explanation of files included

### "clean postcodes.R"
* Function for cleaning postcode to a standard format, further details below
* fully self contained
* use by calling source()

### "clean pcodes TEMPLATE.R"
* template for importing uncleaned postcode file (xlsx format) cleaning, merging with an existing postcode lookup & outputting new file with added fields to original location 
* Needs updating to file locations & postcode lookup file

### "map geocoded pcodes.R"
* template for creating a leaflet map showing point & Middle Super Output area choropleth 
* requires input file with lat/ long e.g. that created from "clean pcodes TEMPLATE.R"

### "postcode lookup.R"
* template for creating a postcode lookup for Bolton
* Needs updating for different areas, may need review when boundaries etc change

## Clean postcodes function details
* Function which aims to take postcodes inputted (as either a vector or column of a dataframe) & correct common errors so the postcodes can be matched to a list of existing postcodes
* Does not check if the postcodes actually exist, just that the format is compatible with those that do exist
* Only checks for full postcodes not part postcodes

### Errors currently corrected:
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

### For potential future inclusion 
* E for 3 where it must be a number


