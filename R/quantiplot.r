#' @title Quantification Plot
#' 
#' @description
#' Quantification Plots for Non-Metric PLS-PM
#' 
#' @param pls a non-metric \code{"plspm"} object
#' @param lv number of latent variable
#' @param mv number of manifest variable
#' @param pch Either an integer specifying a symbol or a single character to be
#' used as the default in plotting points
#' @param col color
#' @param lty type of line
#' @param \dots Further arguments passed on to \code{\link{plot}}.
#' @export
quantiplot <- 
function(pls, lv = NULL, mv = NULL, pch = 16, col = "darkblue", lty = 2, ...) 
{
  if (class(pls) != "plspm" && is.null(pls$model$specs$scaling))  
    stop("\n'qualiplot()' requires a non-metric plspm object")
  
  # TODO: check that 'mv' belongs to 'lv'
  
  # extract original and quantified mv
  mv_original = pls$data[,mv]
  mv_quantified = pls$manifests[,mv]
  
  # plot values
  plot(mv_original, mv_quantified, 
       xlab = "raw values", ylab = "scaling values", 
       pch = pch, col = col, ...)
  # add lines
  lines(sort(mv_original), sort(mv_quantified), 
        col = col, lty = lty)
  # dad title
  title(main = colnames(pls$data[mv]), ...)
}

# quantiplot(rus_pls1, lv=1, mv=2)
