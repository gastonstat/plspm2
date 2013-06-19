#'@S3method print plspm
print.plspm <- function(x, ...)
{
  cat("Partial Least Squares Path Modeling (PLS-PM)", "\n")
  cat(rep("-", 45), sep="")
  cat("\n   NAME            ", "DESCRIPTION")  
  cat("\n1  $outer_model    ", "outer model")
  cat("\n2  $inner_model    ", "inner model")
  cat("\n3  $path_coefs     ", "path coefficients matrix")
  cat("\n4  $scores         ", "latent variable scores")
  if (!inherits(x, "plspm.fit"))
  {
    cat("\n5  $crossloadings  ", "cross-loadings")
    cat("\n6  $inner_summary  ", "summary inner model")
    cat("\n7  $effects        ", "total effects")
    cat("\n8  $unidim         ", "unidimensionality")
    cat("\n9  $gof            ", "goodness-of-fit")
    cat("\n10 $boot           ", "bootstrap results")
    cat("\n11 $data           ", "data matrix")
  }
  cat("\n")
  cat(rep("-", 45), sep="")
  cat("\nYou can also use the function 'summary'", "\n\n")    
  invisible(x)
}
