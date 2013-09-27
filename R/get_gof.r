#' @title Goodness-of-fit for \code{plspm}
#'
#' @details
#' Internal function. \code{get_gof} is called by \code{plspm}
#'
#' @param comu communalities
#' @param R2 R-squared coefficient
#' @param blocks list of variables in each block
#' @param path_matrix Inner Design Matrix
#' @keywords internal
#' @template internals
#' @export
get_gof <- function(comu, R2, blocks, path_matrix)
{
  lvs = nrow(path_matrix)
  blocklist = indexify(blocks)  
  endo = rowSums(path_matrix)
  endo[endo != 0] = 1  
  
  # average of communalities
  R2_aux <- R2[endo == 1]
  comu_aux <- n_comu <- 0    
  for (j in 1:lvs)
  {
    if (length(blocklist==j) > 1)
    {
      comu_aux = comu_aux + sum(comu[blocklist==j])
      n_comu = n_comu + length(blocklist==j)
    }
  }
  gof = sqrt((comu_aux / n_comu) * mean(R2_aux))
  # output
  gof
}
