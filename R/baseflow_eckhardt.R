#' Eckhardt Digital Filter for Baseflow Separation
#'
#' Performs baseflow separation on daily streamflow data using the 
#' two-parameter Eckhardt digital filter.
#'
#' @param q A numeric vector of daily streamflow (discharge).
#' @param alpha A numeric value (0 to 1) representing the recession constant. 
#'   Typical values are 0.95 to 0.99.
#' @param BFImax A numeric value representing the maximum baseflow index 
#'   attainable for the specific catchment.
#'
#' @return A data frame containing the original discharge (q), 
#'   calculated baseflow (bf), and quickflow (qf).
#' 
#' @details
#' The filter equation is defined as:
#' $$b_t = \frac{(1 - BFI_{max}) \alpha b_{t-1} + (1 - \alpha) BFI_{max} q_t}{1 - \alpha BFI_{max}}$$
#' where $b_t \le q_t$.
#' 
#' Alpha ($\alpha$): This is the recession constant. This is equivalent to tao_s.
#' If recession is slow (typical for groundwater-dominated springs), $\alpha$ 
#' will be closer to 0.99.
#'
#'BFImax: This is a "conceptual" maximum.
#'    0.80: For perennial streams with porous aquifers.
#'    0.50: For ephemeral streams with high-intensity runoff.
#'    0.25: For "flashy" watersheds with hard-rock geology.
#'
#'
baseflow_eckhardt <- function(q, alpha = 0.98, BFImax = 0.8) {
  
  n <- length(q)
  bf <- numeric(n)
  
  # Initialize: Assume first day baseflow is 50% of discharge 
  # or use a more specific starting point if available.
  bf[1] <- q[1] * BFImax
  
  # Calculate filter constants to save computation in the loop
  c1 <- (1 - BFImax) * alpha
  c2 <- (1 - alpha) * BFImax
  denom <- 1 - (alpha * BFImax)
  
  for (t in 2:n) {
    # Eckhardt recursive formula
    bt_calc <- (c1 * bf[t-1] + c2 * q[t]) / denom
    
    # Constraint: Baseflow cannot exceed total discharge
    bf[t] <- min(bt_calc, q[t])
    
    # Prevent negative baseflow
    if (bf[t] < 0) bf[t] <- 0
  }
  
  quickflow <- q - bf
  
  return(data.frame(
    q = q,
    bf = bf, quickflow = quickflow
  ))
}
