#' Get Watersheds for Point Locations
#'
#' This function delineates watersheds for given point locations using NHDPlus data.
#' It handles both small tributaries and main NHD flowlines, automatically detecting the
#' appropriate method based on the proximity to the nearest NHD flowline.
#'
#' @param sf An sf object representing the area of interest. If provided, the 
#'   coordinates parameter is ignored. Default is NULL.
#' @param coordinates A numeric vectorcontaining longitude and latitude
#'   coordinates (in that order). Only used if sf parameter is NULL. Default is NULL.
#' @param crs The coordinate system of the coordinates if that approach is used. 
#' @param snap Whether to snap the point to the nearest NHD flowline. Default is FALSE.
#' @export
getXYWatersheds <- function(sf = NULL, coordinates = NULL, crs = NULL, snap = FALSE){
  
  if(is.null(sf)){
    
    # Create a data frame with a column named 'geometry'
    df <- tibble::tibble(long = coordinates[1],
                         lat = coordinates[2])
    
    aoi_raw <- sf::st_as_sf(df, coords = c("long", "lat"), crs = crs) 
    
  }
  
  if(is.null(coordinates)){
    
    aoi_raw <- sf
  }
  
  if(sf::st_crs(aoi_raw)$epsg != 4326){
    
    aoi <- aoi_raw %>% sf::st_transform(crs = 4326)
    
  } else {
    
    aoi <- aoi_raw
  }
  
  if(snap == FALSE){
    # Get the NHDPlus flowline near the site and create a 30m buffer around it
    # This is considered a "danger zone" to avoid placing points on the flowline
    # if they aren't in fact on the flowline
    flowline_danger_zone <- nhdplusTools::get_nhdplus(AOI = aoi, realization = "flowline") %>%
      sf::st_buffer(30)
    
    # is point on a small tributary? (ie too small for NHD flowlines)
    if(is.na(as.numeric(sf::st_intersects(aoi %>% sf::st_buffer(100), flowline_danger_zone)))){
      
      
      # If the site is known to be a small watershed but is still very near "main" flowline...
      if(!is.na(as.numeric(sf::st_intersects(aoi %>% sf::st_buffer(35), flowline_danger_zone)))){
        
        # create a 35m buffer around the site location
        site_buffer <- aoi %>%
          sf::st_buffer(35) 
        
        # get points from the buffer boundary while avoiding any along the flowline
        boundary_points <- site_buffer %>%
          sf::st_boundary() %>%      
          sf::st_cast("POINT") %>%    
          dplyr::mutate(point_id = dplyr::row_number()) %>%   
          sf::st_difference(., flowline_danger_zone) %>%  # remove points that fall within the flowline buffer
          # reduce the number of points by taking only every 50th point
          dplyr::filter(point_id %% 50 == 0) %>%
          dplyr::bind_rows(aoi)  # add the original site point to the collection
        
        splits <- vector("list")
        
        # loop through each boundary point to get split catchments
        for(i in 1:nrow(boundary_points)){
          
          # Get the split catchment for each point
          # We're looking for areas without a catchmentID (NA values)
          splits[[i]] <- nhdplusTools::get_split_catchment(point = sf::st_as_sfc(boundary_points[i,])) %>%
            dplyr::filter(is.na(catchmentID)) %>%
            sf::st_make_valid() %>%
            dplyr::mutate(area = as.numeric(sf::st_area(.)))  # Calculate the area
        }
        
        # Combine all splits and select the largest one
        splits <- dplyr::bind_rows(splits) %>%
          dplyr::filter(as.numeric(area) == max(as.numeric(area))) %>%  # Keep only the largest area
          dplyr::select(-catchmentID,-id) 
        
        return(splits)
        
      } else {
        
        # If site is on small trib but far away from flowline
        mini_ws <- nhdplusTools::get_split_catchment(point = sf::st_as_sfc(aoi)) %>%
          dplyr::filter(is.na(catchmentID)) %>%
          sf::st_make_valid() %>%
          dplyr::mutate(area = as.numeric(sf::st_area(.))) %>%
          dplyr::select(-catchmentID,-id)
        
        if(sf::st_crs(mini_ws) != sf::st_crs(aoi_raw)){
          
          mini_ws <- mini_ws %>% sf::st_transform(crs = sf::st_crs(aoi_raw)$epsg)
          
        }
        
        return(mini_ws)
        
      }
      
    } else {
      
      # Site is along flowline...
      flowline <- nhdplusTools::get_nhdplus(AOI = aoi, realization = "flowline", t_srs = 4326)
      
      # "Snap" our site to the nearest NHD flowline feature
      nearest_points <- sf::st_nearest_points(aoi, flowline)
      
      snapped_points_sf <- sf::st_cast(nearest_points, "POINT")[2,]
      
      trace <- nhdplusTools::get_raindrop_trace(snapped_points_sf, direction = "down")
      
      raindrop <- sf::st_sfc(sf::st_point(trace$intersection_point[[1]][1:2]),
                             crs = 4326)
      # Clip/split our catchment to only include the portion of the
      # catchment upstream of our site and grab whole watershed 
      nhd_catch <- nhdplusTools::get_split_catchment(raindrop, upstream = T)[2,] %>%
        sf::st_make_valid() %>%
        dplyr::mutate(area = as.numeric(sf::st_area(.))) %>%
        dplyr::select(area)
      
      if(sf::st_crs(nhd_catch) != sf::st_crs(aoi_raw)){
        
        nhd_catch <- nhd_catch %>% sf::st_transform(crs = sf::st_crs(aoi_raw)$epsg)
        
      }
      
    }
    
  }
  
  if(snap == TRUE){
    
    # Site is along flowline...
    flowline <- nhdplusTools::get_nhdplus(AOI = aoi, realization = "flowline", t_srs = 4326)
    
    # "Snap" our site to the nearest NHD flowline feature
    nearest_points <- sf::st_nearest_points(aoi, flowline)
    
    snapped_points_sf <- sf::st_cast(nearest_points, "POINT")[2,]
    
    trace <- nhdplusTools::get_raindrop_trace(snapped_points_sf, direction = "down")
    
    raindrop <- sf::st_sfc(sf::st_point(trace$intersection_point[[1]][1:2]),
                           crs = 4326)
    # Clip/split our catchment to only include the portion of the
    # catchment upstream of our site and grab whole watershed 
    nhd_catch <- nhdplusTools::get_split_catchment(raindrop, upstream = T)[2,] %>%
      sf::st_make_valid() %>%
      dplyr::mutate(area = as.numeric(sf::st_area(.))) %>%
      dplyr::select(area)
    
    if(sf::st_crs(nhd_catch) != sf::st_crs(aoi_raw)){
      
      nhd_catch <- nhd_catch %>% sf::st_transform(crs = sf::st_crs(aoi_raw)$epsg)
      
    }
    
    
  }
  
  
  return(nhd_catch)
  
}
