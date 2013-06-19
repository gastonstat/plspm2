#' @title PLS-PM: Partial Least Squares Path Modeling
#'
#' @description
#' Estimate path models with latent variables by partial least squares approach
#'
#' @details
#' The function \code{plspm} estimates a path model by partial least squares
#' approach providing the full set of results. \cr
#'
#' The argument \code{path_matrix} is a matrix of zeros and ones that indicates
#' the structural relationships between latent variables. \code{path_matrix} 
#' must be a lower triangular matrix; it contains a 1 when column \code{j}
#' affects row \code{i}, 0 otherwise. \cr
#'
#' @param Data matrix or data frame containing the manifest variables.
#' @param path_matrix A square (lower triangular) boolean matrix representing 
#' the inner model (i.e. the path relationships betwenn latent variables).
#' @param blocks list of vectors with column indices or column names
#' from \code{Data} indicating the sets of manifest variables forming 
#' each block (i.e. which manifest variables correspond to each block).
#' @param scaling optional list of string vectors indicating the type of 
#' measurement scale for each manifest variable specified in \code{blocks}.
#' \code{scaling} must be specified when working with non-metric variables.
#' @param modes character vector indicating the type of measurement for each
#' block. Possible values are: \code{"A", "B", "newA", "PLScore", "PLScow"}. 
#' The length of \code{modes} must be equal to the length of \code{blocks}).
#' @param scheme string indicating the type of inner weighting
#' scheme. Possible values are \code{"centroid"}, \code{"factorial"}, or
#' \code{"path"}.
#' @param scaled logical value indicating whether manifest variables should be 
#' standardized. Only used when \code{scaling = NULL}. When (\code{TRUE} data is 
#' scaled to standardized values (mean=0 and variance=1). 
#' The variance is calculated dividing by \code{N} instead of \code{N-1}).
#' @param tol decimal value indicating the tolerance criterion for the
#' iterations (\code{tol=0.000001}). Can be specified between 0 and 0.001.
#' @param maxiter integer indicating the maximum number of iterations
#' (\code{maxiter=100} by default). The minimum value of \code{maxiter} is 100.
#' @param plscomp optional vector indicating the number of PLS components
#' (for each block) to be used when handling non-metric data 
#' (only used if \code{scaling} is provided)
#' @param boot.val logical value indicating whether bootstrap validation is
#' performed (\code{FALSE} by default). 
#' @param br integer indicating the number bootstrap resamples. Used only
#' when \code{boot.val=TRUE}. When \code{boot.val=TRUE}, the default number of 
#' re-samples is 100, but it can be specified in a range from 100 to 1000.
#' @param plsr logical value indicating whether pls regression is applied
#' to calculate path coefficients (\code{FALSE} by default).
#' @param dataset logical value indicating whether the data matrix should be
#' retrieved (\code{TRUE} by default).
#' @return An object of class \code{"plspm"}. 
#' @return \item{outer_model}{Results of the outer model. Includes:
#' outer weights, standardized loadings, communalities, and redundancies}
#' @return \item{inner_model}{Results of the inner (structural) model. 
#' Includes: path coeffs and R-squared for each endogenous latent variable}
#' @return \item{scores}{Matrix of latent variables used to estimate the inner
#' model. If \code{scaled=FALSE} then \code{scores} are latent variables
#' calculated with the original data (non-stardardized). If \code{scaled=TRUE}
#' then \code{scores} and \code{latents} have the same values}
#' @return \item{path_coefs}{Matrix of path coefficients 
#' (this matrix has a similar form as \code{path_matrix})}
#' @return \item{crossloadings}{Correlations between the latent variables 
#' and the manifest variables (also called crossloadings)}
#' @return \item{inner_summary}{Summarized results of the inner model. 
#' Includes: type of LV, type of measurement, number of indicators, R-squared,
#' average communality, average redundancy, and average variance
#' extracted}
#' @return \item{effects}{Path effects of the structural relationships. 
#' Includes: direct, indirect, and total effects}
#' @return \item{unidim}{Results for checking the unidimensionality of blocks
#' (These results are only meaningful for reflective blocks)}
#' @return \item{gof}{Goodness-of-Fit index}
#' @return \item{data}{Data matrix containing the manifest variables used in the
#' model. Only when \code{dataset=TRUE}}
#' @return \item{boot}{List of bootstrapping results; only available 
#' when argument \code{boot.val=TRUE}}
#' @author Gaston Sanchez, Giorgio Russolilo
#'
#' @references Tenenhaus M., Esposito Vinzi V., Chatelin Y.M., and Lauro C.
#' (2005) PLS path modeling. \emph{Computational Statistics & Data Analysis},
#' \bold{48}, pp. 159-205.
#'
#' Lohmoller J.-B. (1989) \emph{Latent variables path modelin with partial
#' least squares.} Heidelberg: Physica-Verlag.
#'
#' Wold H. (1985) Partial Least Squares. In: Kotz, S., Johnson, N.L. (Eds.),
#' \emph{Encyclopedia of Statistical Sciences}, Vol. 6. Wiley, New York, pp.
#' 581-591.
#'
#' Wold H. (1982) Soft modeling: the basic design and some extensions. In: K.G.
#' Joreskog & H. Wold (Eds.), \emph{Systems under indirect observations:
#' Causality, structure, prediction}, Part 2, pp. 1-54. Amsterdam: Holland.
#' @seealso \code{\link{innerplot}}, \code{\link{plot.plspm}}
#' @example R/satis-plspm-ex.r
#' @export
plspm <-
function(Data, path_matrix, blocks, scaling = NULL, modes = NULL, 
         scheme = "centroid", scaled = TRUE, tol = 0.000001, maxiter = 100, 
         plscomp = NULL, plsr = FALSE, boot.val = FALSE, br = NULL, 
         dataset = TRUE)
{
  # =======================================================================
  # checking arguments
  # =======================================================================
  valid = check_args(Data=Data, path_matrix=path_matrix, blocks=blocks, 
                     scaling=scaling, modes=modes, scheme=scheme, 
                     scaled=scaled, tol=tol, maxiter=maxiter, 
                     plscomp=plscomp, plsr=plsr, 
                     boot.val=boot.val, br=br, dataset=dataset)
  
  Data = valid$Data
  path_matrix = valid$path_matrix
  blocks = valid$blocks
  specs = valid$specs
  boot.val = valid$boot.val
  br = valid$br
  dataset = valid$dataset
  
  # =======================================================================
  # Preparing data and blocks indexification
  # =======================================================================
  # building data matrix 'MV'
  MV = get_manifests(Data, blocks)
  check_MV = test_manifest_scaling(MV, specs$scaling)
  # generals about obs, mvs, lvs
  gens = get_generals(MV, path_matrix)
  # blocks indexing
  names(blocks) = gens$lvs_names
  block_sizes = lengths(blocks)
  blockinds = indexify(blocks)
  
  # transform to numeric if there are factors in MV
  if (test_factors(MV)) {
    numeric_levels = get_numerics(MV)
    MV = numeric_levels$MV
    categories = numeric_levels$categories
  }  
  # apply corresponding treatment (centering, reducing, ranking)
  X = get_treated_data(MV, specs)
  
  # =======================================================================
  # Outer weights and LV scores
  # =======================================================================
  metric = get_metric(specs$scaling)
  if (metric) {
    # object 'weights' contains outer w's, W, ODM, iter
    weights = get_weights(X, path_matrix, blocks, specs)
    ok_weights = test_null_weights(weights, specs)
    outer_weights = weights$w
    LV = get_scores(X, weights$W)
  } else {
    # object 'weights' contains outer w's, W, Y, QQ, ODM, iter
    weights = get_weights_nonmetric(X, path_matrix, blocks, specs)
    ok_weights = test_null_weights(weights, specs)
    outer_weights = weights$w
    LV = weights$Y
    X = do.call(cbind, weights$QQ)  # quantified MVs
  }
  
  # =======================================================================
  # Path coefficients and total effects
  # =======================================================================
  inner_results = get_paths(path_matrix, LV, plsr)
  inner_model = inner_results[[1]]
  Path = inner_results[[2]]
  R2 = inner_results[[3]]
  Path_effects = get_effects(Path)

  # =======================================================================
  # Outer model: loadings, communalities, redundancy, crossloadings
  # =======================================================================
#  xloads = cor(MV, LV)
  xloads = cor(X, LV)
  loadings = rowSums(xloads * weights$ODM)
  communality = loadings^2
  R2_aux = rowSums(weights$ODM %*% diag(R2, gens$lvs, gens$lvs))
  redundancy = communality * R2_aux
  crossloadings = data.frame(xloads)
  crossloadings$block = rep(gens$lvs_names, block_sizes)
  crossloadings = crossloadings[,c('block',colnames(xloads))]
  
  # outer model data frame
  outer_model = data.frame(block = rep(gens$lvs_names, block_sizes),
                           weight = outer_weights, 
                           loading = loadings, 
                           communality = communality,
                           redundancy = redundancy,
                           row.names = gens$mvs_names)
  
  # Unidimensionality
  unidim = get_unidim(DM = MV, blocks = blocks, modes = modes)
  
  # Summary Inner model
  inner_summary = get_inner_summary(path_matrix, blocks, modes,
                                    communality, redundancy, R2)
  
  # GoF Index
  gof = get_gof(communality, R2, blocks, path_matrix)
  
  # =======================================================================
  # Results
  # =======================================================================
  # deliver dataset?
  if (dataset) data = MV else data = NULL
  # deliver bootstrap validation results? 
  bootstrap = FALSE
  if (boot.val) 
  {
    if (nrow(X) <= 10) {
      warning("Bootstrapping stopped: very few cases.") 
    } else { 
      bootstrap = get_boots(MV, path_matrix, blocks, specs, br, plsr)
    }
  }
  
  # list with model specifications
  model = list(IDM=path_matrix, blocks=blocks, scaling=specs$scaling,
               scheme=specs$scheme, modes=specs$modes, scaled=specs$scaled,
               tol=specs$tol, maxiter=specs$maxiter, iter=weights$iter,
               boot.val=boot.val, plsr=plsr, br=br, gens=gens)
  
  ## output
  res = list(outer_model = outer_model, 
             inner_model = inner_model,
             path_coefs = Path, 
             scores = LV,
             crossloadings = crossloadings, 
             inner_summary = inner_summary, 
             effects = Path_effects,
             unidim = unidim, 
             gof = gof, 
             boot = bootstrap, 
             data = data, 
             model = model)
  class(res) = "plspm"
  return(res)
}
