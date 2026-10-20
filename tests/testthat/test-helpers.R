test_that("make_ym() truncates dates and strings to the first of the month", {
  expect_equal(make_ym("2020-03-15"), lubridate::ymd("2020-03-01"))
  expect_equal(make_ym(as.Date("2021-12-31")), lubridate::ymd("2021-12-01"))
})

test_that("calc_water_year() switches year at the start month", {
  dates <- as.Date(c("2020-09-30", "2020-10-01", "2021-01-15"))
  expect_equal(calc_water_year(dates), c(2020, 2021, 2021))
  # a water year that starts in July
  expect_equal(calc_water_year(as.Date(c("2020-06-30", "2020-07-01")),
                               water_year_start_month = 7),
               c(2020, 2021))
})

test_that("baseflow_eckhardt() splits discharge into baseflow and quickflow", {
  q <- c(10, 12, 20, 15, 11, 9, 8, 8, 7, 7)
  out <- baseflow_eckhardt(q)
  expect_named(out, c("q", "bf", "quickflow"))
  expect_equal(nrow(out), length(q))
  expect_true(all(out$bf <= out$q))
  expect_true(all(out$bf >= 0))
  expect_equal(out$quickflow, out$q - out$bf)
})

test_that("baseflow_eckhardt() rejects an invalid starting baseflow", {
  expect_error(baseflow_eckhardt(c(10, 12, 14), bf_0 = 11), "Invalid bf_0")
})
