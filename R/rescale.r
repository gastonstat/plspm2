#' @title Rescale Latent Variable Scores
#' 
#' @description 
#' Rescale standardized latent variable scores to original scale 
#' of manifest variables
#' 
#' @details
#' \code{rescale} requires all outer weights to be positive
#' 
#' @param pls object of class \code{"plspm"}
#' @param Y Optional dataset (matrix or data frame) used when argument
#' \code{dataset=NULL} inside \code{pls}.
#' @return A data frame with the rescaled latent variable scores
#' @author Gaston Sanchez
#' @seealso \code{\link{plspm}}
#' @export
#' @examples
#' 
#' \dontrun{
#'  ## example with customer satisfaction analysis
#'  
#'  # load data satisfaction
#'  data(satisfaction)
#'  
#'  # define inner model matrix
#'  IMAG = c(0,0,0,0,0,0)
#'  EXPE = c(1,0,0,0,0,0)
#'  QUAL = c(0,1,0,0,0,0)
#'  VAL = c(0,1,1,0,0,0)
#'  SAT = c(1,1,1,1,0,0) 
#'  LOY = c(1,0,0,0,1,0)
#'  sat.inner = rbind(IMAG, EXPE, QUAL, VAL, SAT, LOY)
#'  
#'  # define outer model list
#'  sat.outer = list(1:5, 6:10, 11:15, 16:19, 20:23, 24:27)
#'  
#'  # define vector of reflective modes
#'  sat.mod = rep("A", 6)
#'  
#'  # apply plspm
#'  my_pls = plspm(satisfaction, sat.inner, sat.outer, sat.mod, 
#'               scaled=FALSE)
#'               
#'  # rescaling standardized scores of latent variables
#'  new_scores = rescale(my_pls)
#'  
#'  # compare standardized LVs against rescaled LVs
#'  summary(my_pls$scores)
#'  summary(new_scores)
#'  }
#'
rescale <- function(pls, Y = NULL)
{
  # =======================================================
  # checking arguments
  # =======================================================
  if (!inherits(pls, "plspm"))
    stop("\nSorry, an object of class 'plspm' is expected")
  # test availibility of dataset (either Y or pls$data)
  test_dataset(Y, pls$data, pls$model$gens$obs)
  # non-metric scaling is allowed
  metric = get_metric(pls$model$scaling)
  if (!metric) 
    stop("\nSorry, 'rescale()' requires 'pls' to have scaling=NULL")
  # all outer weights must be positive
  wgs = pls$outer_model$weight
  if (any(wgs < 0))
    stop("\nSorry, 'rescale()' requires all outer weights to be positive")
  
  # =======================================================
  # prepare ingredients
  # =======================================================
  IDM = pls$model$IDM
  blocks = pls$model$blocks   
  modes = pls$model$modes
  lvs = nrow(IDM)
  mvs = sum(lengths(blocks))
  LVS = pls$scores
  
  # create block list
  blocklist = indexify(blocks)
  
  # outer design matrix 'ODM' with normalized weights
  ODM = matrix(0, mvs, lvs)
  for (j in 1:lvs) 
    ODM[blocklist==j,j] = wgs[blocklist == j] / sum(wgs[blocklist == j])
  
  # calculating rescaled scores
  if (!is.null(pls$data)) 
  {
    # get rescaled scores
    if (is.data.frame(pls$data)) pls$data = as.matrix(pls$data)
    Scores = pls$data %*% ODM
  } else {         
    # building data matrix 'DM' when dataset=FALSE
    DM = matrix(NA, nrow(pls$scores), mvs)
    for (k in 1:lvs)
      DM[,blocklist==k] <- as.matrix(Y[,blocks[[k]]])
    # get rescaled scores
    Scores = DM %*% ODM
  }
  
  # result
  dimnames(Scores) = list(rownames(pls$scores), rownames(IDM))
  as.data.frame(Scores)
}
