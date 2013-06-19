#' @title Outer Weights Non-Metric Data
#' 
#' @details
#' Internal function. \code{get_weights} is called by \code{plspm}
#' 
#' @note
#' Calculate outer weights for non-metric data (under Lohmoller's algorithm)
#' 
#' @param X scaled data
#' @param path_matrix matrix with path connections
#' @param blocks list with variables in each block
#' @param specs list with algorithm specifications
#' @return list of outer weights, ODM, scores, QQ, iter
#' @keywords internal
#' @template internals
#' @export
get_weights_nonmetric <-
function(X, path_matrix, blocks, specs)
{
  lvs = nrow(path_matrix)
  mvs = ncol(X)
  num_obs = nrow(X)
  correction = sqrt(nrow(X) / (nrow(X)-1))
  blockinds = indexify(blocks)
  block_sizes = lengths(blocks)
  PLScomp = specs$plscomp
  
  # dummy matrices for categorical manifest variables
  dummies = get_dummies(X, specs)
  
  ## transforming X in a list of blocks
  Xblocks = vector("list", lvs)
  start_end = from_to(blocks)
  from = start_end$from
  to = start_end$to
  for (q in 1:lvs) {
    if (from[q] == to[q]) {
      Xblocks[[q]] = as.matrix(X[,from[q]:to[q]])
    } else {
      Xblocks[[q]] = X[,from[q]:to[q]]      
    }
  }

  # list for quantification of blocks' variables
  QQ = Xblocks  
  # missing data flags
  missing_data = sapply(Xblocks, is_missing)

  # outer design matrix 'ODM' and matrix of outer weights 'W'
  ODM = list_to_dummy(blocks)
  
  # =======================================================================
  # initialization
  # =======================================================================
  # outer weights (normalized)
  w_ones = list_ones(block_sizes)
  w = lapply(w_ones, normalize)
  # LV scores
  Y = matrix(0, num_obs, lvs)
  for (q in 1:lvs) {
    if (missing_data[q]) {
      for (i in 1:nrow(X)) {
        aux_numerator = sum(QQ[[q]][i,]*w[[q]], na.rm=TRUE)
        aux_denom = sum(w[[q]][which(is.na(QQ[[q]][i,]*w[[q]]) == FALSE)]^2)
        Y[i,q] <- aux_numerator / aux_denom
      }
    } else {
        Y[,q] = QQ[[q]] %*% w[[q]]        
    }
  }
  
  # =======================================================================
  # iterative cycle
  # =======================================================================
  # matrix of inner weights
  E = matrix(0, lvs, lvs)
  link = t(path_matrix) + path_matrix
  z_temp = matrix(0, num_obs, 1)
  iter = 0
  repeat 
  {
    iter = iter + 1
#    y_old = as.numeric(Y)
    Y_old = Y
    
    # =============================================================
    # updating inner weights
    # =============================================================
    E <- switch(specs$scheme, 
                "centroid" = sign(cor(Y) * link),
                "factor" = cor(Y) * link,
                "path" = get_path_scheme(path_matrix, Y))
    # internal estimation of LVs 'Z'
    Z = Y %*% E
    
    # for each block
    for (q in 1:lvs) 
    {
      # standardize inner estimates if PLScore mode
      if (specs$modes[q] != "PLScow") {
        Z[,q] <- scale(Z[,q]) * correction
      }
      # =============================================================
      # Quantification of the MVs in block ["QQ"]
      # =============================================================
      # for each MV in block 'q'
      for (p in 1:block_sizes[q]) {
        if (specs$scaling[[q]][p] == "nom") {
          # extract corresponding dummy matrix
          aux_dummy = dummies[[blocks[[q]][p]]]
          # apply scaling
          QQ[[q]][,p] = get_nom_scale(Z[,q], Xblocks[[q]][,p], aux_dummy)
          QQ[[q]][,p] = get_num_scale(QQ[[q]][,p])
        }
        if (specs$scaling[[q]][p] == "ord") {
          # extract corresponding dummy matrix
          aux_dummy = dummies[[blocks[[q]][p]]]
          # apply scaling
          QQ[[q]][,p] = get_ord_scale(Z[,q], Xblocks[[q]][,p], aux_dummy)
          QQ[[q]][,p] = get_num_scale(QQ[[q]][,p])
        }       			
        if (specs$scaling[[q]][p] == "num") {
          QQ[[q]][,p] = get_num_scale(QQ[[q]][,p])
        }
        ### DO WE REALLY NEED THIS LINE:
        #if (specs$scaling[[q]][p] == "raw") {
        #  QQ[[q]][,p] = QQ[[q]][,p]
        #}
      }
      
      # =============================================================
      # updating outer weights "w"
      # =============================================================
      # reflective way
      if (specs$modes[q] == "A") {
        if (missing_data[q]) {
          for (l in 1:block_sizes[q]) {
            aux_numerator = sum(QQ[[q]][,l] * Z[,q], na.rm=TRUE)
            aux_denom = sum(Z[,q][which(is.na(QQ[[q]][,l]*Z[,q]) == FALSE)]^2)
            w[[q]][l] = aux_numerator / aux_denom
          }          
        } else {
          # complete data in block q
          w[[q]] = (1/num_obs) * (t(QQ[[q]]) %*% Z[,q])
        }
      }
      # formative way
      if (specs$modes[q] == "B") {
        w[[q]] = solve(t(QQ[[q]]) %*% QQ[[q]]) %*% t(QQ[[q]]) %*% Z[,q]
      }
      # PLScore way
      if (specs$modes[q] == "PLScore") {
        w[[q]] = get_PLSRdoubleQ(Z[,q], NULL, QQ[[q]], NULL, PLScomp[q])$B
      }
      # PLScow way
      if (specs$modes[q] == "PLScow") {
        w[[q]] = get_PLSRdoubleQ(Z[,q], NULL, QQ[[q]], NULL, PLScomp[q])$B
        w[[q]] = w[[q]] / sqrt(sum(w[[q]]^2))
      }
      
      # =============================================================
      # outer estimations ["y"]
      # =============================================================
      if (missing_data[q]) {
        for (i in 1:num_obs) {
          aux_numerator = sum(QQ[[q]][i,] * w[[q]], na.rm=TRUE)
          aux_denom = sum(w[[q]][which(is.na(QQ[[q]][i,] * w[[q]]) == FALSE)]^2)
          Y[i,q] = aux_numerator / aux_denom
        }        
      } else {
        Y[,q] <- QQ[[q]] %*% w[[q]]
      }
      # correction needed if mode PLScow
      if (specs$modes[q] != "PLScow") {
        Y[,q] = scale(Y[,q]) * correction
      } 
    }
    # check convergence
    convergence <- sum((abs(Y_old) - abs(Y))^2)
    # Y_old: keep it as a matrix
#    convergence <- sum((abs(y_old) - abs(as.numeric(Y)))^2)
    if (convergence < specs$tol | iter > specs$maxiter) 
      break
  } # end repeat
  
  # preparing results
  if (iter == specs$maxiter) {
    results = NULL
  } else {
    W = list_to_matrix(lapply(w, as.numeric))
    w = unlist(lapply(w, as.numeric))
#    names(w) = colnames(X)
    dimnames(W) = list(colnames(X), rownames(path_matrix))
    dimnames(Y) = list(rownames(X), rownames(path_matrix))
    results = list(w = w, W = W, Y = Y, QQ = QQ, ODM = ODM, iter = iter)
  }
  # output
  results  
}
