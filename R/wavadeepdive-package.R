#' @keywords internal
"_PACKAGE"

## Functions from other packages that the code calls without a `pkg::` prefix.
## The playground got these from `library()` calls in setup.R.
#' @importFrom data.table data.table
#' @importFrom dataRetrieval read_waterdata_metadata whatNWISsites
#' @importFrom dplyr any_of as_tibble bind_rows case_when contains count
#' @importFrom dplyr distinct filter if_else inner_join left_join mutate
#' @importFrom dplyr rename_with right_join row_number select sym
## ggfortify provides the autoplot() method for PCA objects; importing any of
## its functions loads it.
#' @importFrom ggfortify ggbiplot
#' @importFrom ggforce geom_mark_circle
#' @importFrom ggplot2 autoplot aes element_blank element_text geom_hline
#' @importFrom ggplot2 geom_point geom_rect geom_vline ggplot guide_legend
#' @importFrom ggplot2 guides labs scale_fill_gradient scale_fill_manual
#' @importFrom ggplot2 scale_shape_manual theme
#' @importFrom ggrepel geom_text_repel
#' @importFrom jsonlite fromJSON
#' @importFrom lubridate as_date month year
#' @importFrom nhdplusTools get_nhdplus get_raindrop_trace get_split_catchment
#' @importFrom purrr map_dfr
#' @importFrom readr read_csv read_delim
#' @importFrom sf sf_use_s2 st_area st_as_sf st_as_sfc st_bbox st_boundary
#' @importFrom sf st_buffer st_cast st_crop st_crs st_difference
#' @importFrom sf st_drop_geometry st_intersects st_make_grid st_make_valid
#' @importFrom sf st_nearest_points st_read st_transform st_zm
#' @importFrom stats prcomp quantile
#' @importFrom stringr str_detect str_extract str_replace
#' @importFrom stringr str_replace_all str_sub word
#' @importFrom terra crs
#' @importFrom tibble column_to_rownames rowid_to_column rownames_to_column
#' @importFrom tidyr drop_na pivot_longer pivot_wider
#' @importFrom tigris states
#' @importFrom units set_units
#' @importFrom utils data download.file setTxtProgressBar txtProgressBar unzip
#' @importFrom wavacore wava_data_path
NULL

## Column names used inside dplyr and data.table calls.
utils::globalVariables(c(
   ":=", ".", ".I", ".N", ".SD", "ALLOWNERS", "area",
   "associatedCaseNumbers.x", "associatedCaseNumbers.y", "associatedContacts",
   "b_age", "b_int_age", "b_int_id", "Backcountry", "begin_date",
   "buffer_length2", "catchmentID", "CF", "ConcessionerCamping",
   "ConcessionerLodging", "count_nu", "county.x", "county.y", "CurrInUse",
   "data_type_cd", "DIVERSION_SITE_NAME", "division.x", "division.y",
   "elevation", "end_date", "first_year", "GCM", "geometry", "gnisId.x",
   "gnisId.y", "hx_hy_dist", "hx_ly_dist", "id", "ID", "Label", "LAST_NAME",
   "latitude", "LATITUDE", "locationAccuracy.x", "locationAccuracy.y",
   "longitude", "LONGITUDE", "lx_hy_dist", "lx_ly_dist",
   "MiscellaneousOvernightStays", "Month", "name", "NonRecreationDayUse",
   "NonRecreationOvernightStays", "NonRecreationOvernightUse",
   "NonRecreationVisits", "OBJECTID", "own_lname", "OWNER", "owner_name",
   "parameter_cd", "parameter_nm", "parm_cd", "PC1", "PC2", "pm.x", "pm.y",
   "POD_ID", "point_id", "pr", "range.y", "Rank", "RCP", "RecreationDayUse",
   "RecreationOvernightUse", "RecreationVisits", "Region", "rowid",
   "RVCampers", "SCAN_SNOTEL_metadata", "section.y", "select_cfs", "site_no",
   "site_tp_cd", "source_id", "SOURCE_NAME", "source_table_locs",
   "source_type", "station_nm", "streamMile.x", "streamMile.y",
   "structureName.x", "structureName.y", "structureType.x", "structureType.y",
   "Symbol", "t_age", "t_int_age", "t_int_id", "tasmax", "tasmin",
   "TentCampers", "tmax_C", "tmin_C", "tmmn", "tmmx", "township.y",
   "UNIT_CODE", "UnitCode", "val", "var", "var_temp", "visits",
   "waterDistrict.x", "waterDistrict.y", "waterSource.x", "waterSource.y",
   "weight", "within_aoi", "WRNAME", "x", "X", "x.y", "y", "Y", "y.y", "Year"
))
