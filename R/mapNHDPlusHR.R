#' @export
mapNHDPlusHR <- function(aoi){
  
  hucs <- nhdplusTools::get_huc(AOI = aoi, type = "huc04")
  
  flowlines <- vector("list", length = nrow(hucs))
  
  for(i in 1:nrow(hucs)){
    
    nhdhr <- paste0(wavacore::wava_data_path("all", "nhdplushr"), "/", stringr::str_sub(hucs$huc4[i], 1, 2), "/")
    
    file <- list.files(nhdhr, pattern = paste0(hucs$huc4[i], "_HU4_GDB.gdb"), full.names = TRUE)
    
    # filter out and clip the catchment features within the park boundaries:
    flowlines[[i]] <- sf::st_read(dsn = file, layer = "NHDFlowline") %>%
      sf::st_zm()
    
    if(sf::st_crs(aoi)$epsg != 4269){
      flowlines[[i]] <- flowlines[[i]] %>%
        .[sf::st_transform(aoi, 4269),]
    } else {
      
      flowlines[[i]] <- flowlines[[i]] %>%
        .[aoi,]
    }
    
  }
  
  flowlines<- dplyr::bind_rows(flowlines) %>%
    
    
    return(flowlines)
  
}
