# plspm

**plspm** is an R package dedicated to Partial Least Squares Path Modeling (PLS-PM) analysis. Versions later than 4.0 include a whole new set of features to handle non-metric variables.

## Installation

**Passo 1)** In order to install `plspm2` you need to use the R package devtools. Run in your R console:
```ruby
# install "devtools"
install.packages("devtools") 
library(devtools)
```

**Passo 2)** Then you need to install the packages `tester` and `turner`.
Run in your R console:
```ruby
# install "tester" and "turner"
install_github('tester', username='gastonstat')
install_github('turner', username='gastonstat')
```

**Passo 3)** And finally, you install `plspm2`. 
Run in your R console:
```ruby
# install "plspm2""
install_github('plspm2', username='gastonstat')

# load plspm2
library(plspm2)
```


## PLS-PM with Metric Data

Typical example with a Customer Satisfaction Model
```ruby
# load dataset satisfaction
data(satisfaction)

# define path matrix (inner model)
IMAG = c(0,0,0,0,0,0)
EXPE = c(1,0,0,0,0,0)
QUAL = c(0,1,0,0,0,0)
VAL = c(0,1,1,0,0,0)
SAT = c(1,1,1,1,0,0) 
LOY = c(1,0,0,0,1,0)
sat_path = rbind(IMAG, EXPE, QUAL, VAL, SAT, LOY)

# define list of blocks (outer model)
sat_blocks = list(1:5, 6:10, 11:15, 16:19, 20:23, 24:27)

# vector of modes (reflective indicators)
sat_mod = rep("A", 6) 

# apply plspm with bootstrap validation
satpls = plspm(satisfaction, sat_path, sat_blocks, sat_mod, scaled=FALSE, boot.val=TRUE)

# default print
satpls

# summary of results
summary(satpls)

# plot inner model results
plot(satpls, what="inner")

# plot outer model loadings
plot(satpls, what="loadings")

# plot outer model weights
plot(satpls, what="weights")
```


## PLS-PM with Non-Metric Data
Example with the classic Russett data (original data set)
```ruby
# load dataset russett A
# (variable 'demo' as numeric)
data(russa)

# load dataset russett B
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

### Example 1
PLS-PM using data set `russa` and scaling all 'NUM'
```ruby
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


### Example 2
PLS-PM using data set `russa`, and different scaling
```ruby
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

### Example 3
Now let's use data set `russb` (it contains a factor!)
```ruby
# take a peek
head(russb)

# PLS-PM using data set 'russb'
rus_pls3 = plspm(russb, rus_path, rus_blocks, rus_scaling2, rus_modes, 
                 scheme = "centroid", plscomp=c(1,1,1), tol = 0.0000001)

# outer model
rus_pls3$outer_model
```

### Example 4
Now let's change modes
```ruby
# modes new A
rus_modes2 = c("newA", "newA", "newA")

# PLS-PM using data set 'russa'
rus_pls4 = plspm(russa, rus_path, rus_blocks, rus_scaling2, rus_modes2, 
                 scheme = "centroid", plscomp=c(1,1,1), tol = 0.0000001)

# outer model
rus_pls4$outer_model
```

### Example 5
Let's make things more interesting, flexible and versatile. How?
What if you could have more freedom specifying the arguments? Now you can!
Note that you can specify `blocks` using variables' names, the `scaling` types are NOT case senstive, neither are `modes` nor `scheme`. Isn't that cool?
```ruby
# blocks
rus_blocchi = list(
   c("gini", "farm", "rent"),
   c("gnpr", "labo"),
   c("inst", "ecks", "death", "demo"))

# scaling
rus_scaling3 = list(c("numeric", "numeric", "numeric"),
               c("ordinal", "ORDINAL"),
               c("NuM", "numer", "NUM", "nominal"))
    
# modes new A
rus_modes3 = c("newa", "NEWA", "NewA")

# PLS-PM using data set 'russb'
rus_pls5 = plspm(russb, rus_path, rus_blocchi, rus_scaling3, rus_modes3, 
                 scheme = "CENTROID", plscomp=c(1,1,1), tol = 0.0000001)

# outer model
rus_pls5$outer_model
```


Authors Contact
---------------
[Gaston Sanchez](http://www.gastonsanchez.com)
  (`gaston.stat at gmail.com`)

[Laura Trinchera](http://rouenbs.academia.edu/LauraTrinchera)
  (`ltr at rouenbs.fr`)

[Giorgio Russolillo](http://cnam.academia.edu/GiorgioRussolillo)
  (`giorgio.russolillo at cnam.fr`)

