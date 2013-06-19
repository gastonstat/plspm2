Ciao bello
============================

GR (and LT): Ecco il prototipo del pacchetto (sotto il nome `plspm2`)! 

## Installation

**Passo 1)** In order to install `plspm2` you need to use the R package devtools. Run in your R console:
```r
# install "devtools"
install.packages("devtools") 
library(devtools)
```

**Passo 2)** Then you need to install the package `turner`.
Run in your R console:
```r
# install "turner"
install_github('turner', username='gastonstat')
```

**Passo 3)** And finally, you install `plspm2`
Run in your R console:
```r
# install "plspm2""
install_github('plspm2', username='gastonstat')

# load plspm2
library(plspm2)
```


## Model for Russett data (original data set)
Let's prepare the ingredients:
```r
# load dataset russett 
# (variable 'demo' as numeric)
data(russa)

# load dataset russett
# (variable 'demo' as factor)
data(russb)

# russett all numeric
rus_path = rbind(c(0, 0, 0), c(0, 0, 0), c(1, 1, 0))
rownames(rus_path) = c("AGRI", "IND", "POLINS")
colnames(rus_path) = c("AGRI", "IND", "POLINS")
rus_blocks = list(1:3, 4:5, 6:9)
rus_scaling = list(c("NUM", "NUM", "NUM"),
               c("NUM", "NUM"),
               c("NUM", "NUM", "NUM", "NUM"))
rus_modes = c("A", "A", "A")
```

## Example 1
PLS-PM using data set 'russa' and scaling all 'NUM'
```r
# PLS-PM using data set 'russa'
rus_pls1 = plspm(russa, rus_path, rus_blocks, rus_scaling, rus_modes, 
                 scheme = "centroid", plscomp=c(1,1,1), tol = 0.0000001)

rus_pls1

# outer model
rus_pls1$outer_model

# inner model
rus_pls1$inner_model

# scores
head(rus_pls1$scores)

# plot inner model
plot(rus_pls1)
```


## Example 2
PLS-PM using data set 'russa', and different scaling
```r
# new scaling
rus_scaling2 = list(c("NUM", "NUM", "NUM"),
                   c("ORD", "ORD"),
                   c("NUM", "NUM", "NUM", "NOM"))

# PLS-PM using data set 'russa'
rus_pls2 = plspm(russa, rus_path, rus_blocks, rus_scaling2, rus_modes, 
                 scheme = "centroid", plscomp=c(1,1,1), tol = 0.0000001)

# outer model
rus_pls2$outer_model
```

## Example 3
Now let's use data set 'russb' (it contains a factor!)
```r
# take a peek
head(russb)

# PLS-PM using data set 'russb'
rus_pls3 = plspm(russb, rus_path, rus_blocks, rus_scaling2, rus_modes, 
                 scheme = "centroid", plscomp=c(1,1,1), tol = 0.0000001)

# outer model
rus_pls3$outer_model
```

## Example 4
Let's make things more interesting, flexible and versatile. How?
What if you could have more freedom specifying the arguments? Now you can!
```r
# blocks
rus_blocchi = list(
   c("gini", "farm", "rent"),
   c("gnpr", "labo"),
   c("inst", "ecks", "death", "demo"))

# scaling
rus_scaling3 = list(c("numeric", "numeric", "numeric"),
               c("ordinal", "ORDINAL"),
               c("NuM", "numer", "NUM", "nominal"))
               
# PLS-PM using data set 'russb'
rus_pls4 = plspm(russb, rus_path, rus_blocchi, rus_scaling3, rus_modes, 
                 scheme = "centroid", plscomp=c(1,1,1), tol = 0.0000001)

# outer model
rus_pls4$outer_model
```


Authors Contact
---------------
Gaston Sanchez (gaston.stat at gmail.com)
Laura Trinchera (ltr at rouenbs.fr)
Giorgio Russolillo (giorgio.russolillo at cnam.fr)

