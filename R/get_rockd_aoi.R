#' This function uses the get_rockd.R function to pull geologic layers from 
#' the Macrostrat API over an area of interest. Because the api doesn't have a
#' native method for pulling from an aoi, the function first converts a polygon
#' area of interest into a gridded set of points. Then, it pulls geologic outcrop
#' polygons for the points successively. After pulling for a point, it masks
#' remaining points that overlap the outcrop extent to avoide redundancy in
#' pulls. Because multiple geologic products typically exist for a given point,
#' (and therefore multiple polygons of varying size and resolution), this function
#' is hard-coded to pull outcrop extents from the smallest available map
#' intersecting the first point. This assumes that the map with the smallest
#' extent also has the finest resolution. This method is used instead of querying
#' the best "resolution" because resolution is included in the metadata as a
#' categorical variable (e.g., tiny, medium, large).  This makes it difficult
#' to compare between the same category.  Generally speaking, if the map has a
#' smaller extent, the resolution is finer (think geologic quadrangle compared
#' to regional or state-wide maps).
#' 
#' @param aoi An `sf` polygon object containing area to extract outcrop extents for.
#' @param crop If true, crops outcrop extent to aoi. False, keeps expansive bounds.
#' 
#' @return An `sf` object of Macrostrat (https://macrostrat.org/) geologic outcrop extents that intersect the area of interest.

get_rockd_aoi <- function(aoi, crop = TRUE) {
  
  #aoi <- park_boundary
  
  #' Function to convert aoi to gridded points
  #' @param polygon = polygon area to make points in
  #' @param cellsize = size of cells to divide polygon and place point at center.
  poly_to_points <- function(polygon, cellsize) {
    
    # Create a grid covering the extent of the polygon
    grid <- st_make_grid(st_bbox(polygon), cellsize = cellsize)
    
    # Intersect the grid with the polygon
    grid_intersect <- suppressWarnings(st_intersection(grid, polygon)) %>%
      suppressMessages()
    
    # Convert to sf POINTS object
    grid_points <- st_centroid(grid_intersect) %>%
      suppressMessages()
    
    return(grid_points)
  }
  
  # Convert aoi to points
  aoi_points <- aoi %>%
    poly_to_points(cellsize = .005)
  
  # Pull geology for first point
  geo_1 <- get_rockd(aoi_points[1,]) 
  
  # Transform aoi_points to crs of geo_1
  aoi_points <- aoi_points %>%
    st_transform(st_crs(geo_1))
  
  #map_sources <- rmacrostrat::def_sources(source_id = geo_1$source_id) %>%
  #  dplyr::filter(area == min(area, na.rm = TRUE))
  
  # Get character string of available map sources
  map_sources_str <- geo_1$source_id %>% toString() %>% gsub(" ", "",.) %>% paste(collapse = ",")
  
  # Download map source metadata to allow selection of smallest area (or resolution)
  map_sources <- RCurl::getURL(paste0("https://macrostrat.org/api/v2/defs/sources?source_id=", 
                                      map_sources_str, 
                                      "&format=geojson_bare"),
                               .opts = RCurl::curlOptions(ssl.verifypeer=FALSE, verbose=FALSE)) %>% 
    geojsonsf::geojson_wkt() %>%
    dplyr::filter(area == min(area, na.rm = TRUE))
  
  # From list, select minimum area
  source <- map_sources$source_id
  
  # Filter geo_1 to only include geologic layers from that source
  geo_1 <- geo_1 %>%
    dplyr::filter(source_id == source)
  
  # Select all points that don't overlap with geo_1 and subsequently pull
  # geology for those points, repeating this selection process
  new_aoi_points <- aoi_points %>% 
    st_intersects(geo_1) %>% 
    lengths() %>% 
    `==`(0) %>% 
    aoi_points[.] %>%
    suppressMessages()
  
  
  start_pt_num <- 1 # base point index that subsequent code will reset to
  pt_num <- start_pt_num # assign to updatable point index
  
  while (length(new_aoi_points) > 0) {
    
    # Number of points at start of loop
    num_pts_start_loop <- length(new_aoi_points)
    
    # Print for status update (can remove)
    print(paste0("Points left: ", num_pts_start_loop))
    
    # Error check -- if pt_index is greater than # pts, reset
    if (pt_num > num_pts_start_loop) {
      pt_num <- start_pt_num
    }
    
    # Get geology for pt_num
    geo_2 <- get_rockd(new_aoi_points[pt_num,]) %>%
      dplyr::filter(source_id == source)
    
    # Remove points that intersect the new geologic extent
    new_aoi_points <- new_aoi_points %>% 
      st_intersects(geo_2) %>% 
      lengths() %>% 
      `==`(0) %>% 
      new_aoi_points[.] %>%
      suppressMessages()
    
    # Bind geo_2 to geo_1
    geo_1 <- bind_rows(geo_1, geo_2)
    
    # Calc num points left after removing points
    num_pts_end_loop <- length(new_aoi_points)
    
    # Check that num points actually changed. If not, could be an "overlap"
    # issue with query. Bump up index and search next point.
    if (num_pts_end_loop == num_pts_start_loop) {
      pt_num <- pt_num + 1 
    } else if (num_pts_end_loop < num_pts_start_loop) {
      pt_num <- start_pt_num
    } 
    
    # If there are no points left, or if on the last point for the second time
    # break while loop
    if ((num_pts_end_loop == 1) && (num_pts_start_loop == 1)) {
      break
    }
    
  }
  
  # Crop if arg is TRUE
  if (crop == TRUE) {
    final_geo <- geo_1 %>%
      st_crop(aoi %>% st_transform(st_crs(geo_1)))
  } else if (crop == FALSE) {
    final_geo <- geo_1
  }
  
  return(final_geo)
}
