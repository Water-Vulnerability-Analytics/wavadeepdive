#' Import park visitation data, broken down by type.
#' 
#' This function uses the Data Store REST Api to download national park boundary 
#' shapefiles. 
#' Use this resource to get updated REST URL: https://irmaservices.nps.gov/datastore/v6/documentation/datastore-api.html#/Search_By_Reference_Code/ReferenceCodeSearch_Get
#' And this to find updated download links: https://irma.nps.gov/DataStore/Reference/Profile/2224545?lnv=True 
#' 
#' @param park The 4 digit national park code(s) for parks of interest
#' @param save Whether to save (TRUE) the resulting shapefile or not (FALSE)
#' @param path If `save = TRUE`, the file path to save the shapefile
#' 
#' @return A spatial sf object for each specified park boundary

getOvernightStays <- function(park){
  
  suppressMessages(suppressWarnings({
  
  raw_table <- rvest::read_html(paste0('https://irma.nps.gov/Stats/MvcReportViewer.aspx?_id=5f032a4d-01f9-4078-94b4-6c26358cc826&_m=Remote&_r=%2fNPS.Stats.Reports%2fPark+Specific+Reports%2fOvernight+Stays+(1979+-+Last+Calendar+Year)&_15=True&_16=True&_18=True&_19=True&_34=False&_35=False&_39=880px&Park=', park)) %>%
    rvest::html_table() %>%
    .[[34]]
  
  column_names <- raw_table[2, ]
  
  # Create a new data frame with the correct column names
  fixed_table <- raw_table %>%
    # Remove the empty rows and the one that contains the column names
    slice(c(-1, -2)) %>%  
    # Set the column names to the extracted values
    set_names(column_names) %>% 
    # Remove commas, convert all columns to numeric
    mutate(across(everything(), ~ str_replace_all(., ",", ""))) %>%
    mutate(across(everything(), as.numeric)) %>%
    # Add park name as column
    mutate(park = park)
  
  }))
  
  return(fixed_table)
  
}

# # Code to grab for all parks:
#  parks <- getParkSystem() %>%
#    .$UNIT_CODE %>%
#    map(~try(getOvernightStays(park = .), silent = TRUE)) %>%
#    keep(., is.data.frame) %>%
#    bind_rows()
# 
# # Parks with this info:
# sort(unique(parks$park))
# #
# #
# #
# # # Parks without this info:
# no_data <- getParkSystem() %>%
#   sf::st_drop_geometry() %>%
#   dplyr::filter(!UNIT_CODE %in% parks$park)
# 
# getUnitVisitationSub <- function(park){
#   
#   suppressMessages(suppressWarnings({
#     
#     raw_table <- rvest::read_html(paste0("https://irma.nps.gov/Stats/MvcReportViewer.aspx?_id=d09e9a98-bfc0-4186-8d0c-44dd2baee357&_m=Remote&_r=%2fNPS.Stats.Reports%2fPark+Specific+Reports%2fSummary+of+Visitor+Use+By+Month+and+Year+(1979+-+Last+Calendar+Year)&_15=True&_16=True&_18=True&_19=True&_34=False&_35=False&_39=880px&Park=", park)) %>%
#       rvest::html_table(., trim = TRUE, header = TRUE, "/html/body/form/div[3]/span/div/table/tbody/tr[5]/td[3]/div/div[1]/div/table/tbody/tr/td/table/tbody/tr[1]/td/table/tbody/tr/td/table/tbody/tr[4]/td[3]/table/tbody/tr[2]") %>%
#       rvest::html_table() 
#     
#     table_data <- xml2::xml_attr(raw_table)
#     
#     column_names <- raw_table[2, ]
#     
#     # Create a new data frame with the correct column names
#     fixed_table <- raw_table %>%
#       # Remove the empty rows and the one that contains the column names
#       slice(c(-1, -2)) %>%  
#       # Set the column names to the extracted values
#       set_names(column_names) %>% 
#       # Remove commas, convert all columns to numeric
#       mutate(across(everything(), ~ str_replace_all(., ",", ""))) %>%
#       mutate(across(everything(), as.numeric)) %>%
#       # Add park name as column
#       mutate(park = park)
#     
#   }))
#   
#   return(fixed_table)
#   
# }
# How to clean the excel version of the output:
# raw =  readxl::read_excel("data/misc/BRCA_visitor_sub_raw.xlsx", skip = 2, col_names = TRUE)
# 
# #test <-  raw %>% filter(!is.na(...1) & !grepl("Totals", ...1)) %>% filter(is.na(`Recreation Visitors`))
# 
# raw_new <- raw %>% 
#   filter(!is.na(...1) & !grepl("Totals", ...1)) %>% 
#   mutate(year = ifelse(is.na(`Recreation Visitors`), ...1, NA)) %>%
#   fill(year, .direction = "down") %>%
#   filter(!is.na(`Recreation Visitors`)) %>%
#   mutate(ym = ym(paste(year, "-", month(parse_date_time(...1, orders = "b")))),
#          UNIT_CODE = "BRCA") %>%
#   select(-...1) %>%
#   select(UNIT_CODE, year, ym, everything()) %>%
#   janitor::clean_names() %>%
#   write_csv("data/park/BRCA/visitors_hr.csv")
