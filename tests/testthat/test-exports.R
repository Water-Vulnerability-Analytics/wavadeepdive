test_that("the package exports its retrieval and analysis functions", {
  exports <- getNamespaceExports("wavadeepdive")
  expected <- c("getPODCalifornia", "getPODColorado", "getPODNevada",
                "getPODNewMexico", "getPODUtah", "getWaterRightsMontana",
                "getWaterSuppliersUtah", "getWaterUseUtah", "getNOAA",
                "getSNOTEL", "listNWIS", "get_climate_future",
                "get_climate_historic", "get_aoi_source", "make_ym",
                "calc_water_year", "baseflow_eckhardt",
                "select_cfs_deep_dive")
  expect_true(all(expected %in% exports))
})

test_that("functions that read the shared data folder fail clearly without it", {
  withr::local_options(wava.data_dir = file.path(tempdir(), "no-such-folder"))
  expect_error(getPODNevada())
})
