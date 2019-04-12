
<!-- README.md is generated from README.Rmd. Please edit that file -->
shapr
=====

[![CircleCI](https://circleci.com/gh/NorskRegnesentral/shapr.svg?style=svg&circle-token=7c2a3a4edc870b4694982f0fe8ac66f92d639099)](https://circleci.com/gh/NorskRegnesentral/shapr)

The most common task of machine learning is to train a model which is able to predict an unknown outcome (response variable) based on a set of known input variables/features. When using such models for real life applications, it is often crucial to understand why a certain set of features lead to exactly that prediction. However, explaining predictions from complex, or seemingly simple, machine learning models is a practical and ethical question, as well as a legal issue. Can I trust the model? Is it biased? Can I explain it to others? We want to explain individual predictions from a complex machine learning model by learning simple, interpretable explanations.

Shapley values is the only prediction explanation framework with a solid theoretical foundation (Lundberg and Lee (2017)). Unless the true distribution of the features are known, and there are less than say 10-15 features, these Shapley values needs to be estimated/approximated. Popular methods like Shapley Sampling Values (Štrumbelj and Kononenko (2014)), SHAP/Kernel SHAP (Lundberg and Lee (2017)), and to some extent TreeSHAP (Lundberg, Erion, and Lee (2018)), assume that the features are independent when approximating the Shapley values for prediction explanation. This may lead to very inaccurate Shapley values, and consequently wrong interpretations of the predictions. Aas, Jullum, and Løland (2019) extends and improves the Kernel SHAP method of Lundberg and Lee (2017) to account for the dependence between the features, resulting in significantly more accurate approximations to the Shapley values. See the paper for details.

This package implements the methodology of Aas, Jullum, and Løland (2019).

The following methodology/features are currently implemented:

-   Native support of explanation of predictions with the following model classes `stats::glm`, `stats::lm`,`ranger::ranger`, `xgboost::xgboost` and `mgcv::gam`.
-   Accounting for feature dependence assuming the features are Gaussian (Aas, Jullum, and Løland (2019)).
-   Accounting for feature dependence with a Gaussian copula (Gaussian dependence structure, any marginal) (Aas, Jullum, and Løland (2019)).
-   Accounting for feature dependence using the Mahalanobis distance based empirical (conditional) distribution approach of Aas, Jullum, and Løland (2019)
-   Combine any of the three methods
-   Optional use of the AICc criterion of Hurvich, Simonoff, and Tsai (1998) when optimizing the bandwidth parameter in the empirical (conditional) approach of Aas, Jullum, and Løland (2019).

<!--
Current methodological restrictions:

- The features must follow a continuous distribution
- Discrete features typically work just fine in practice although the theory breaks down
- Ordered/unordered categorical features are not supported
-->
Future releases will include:

-   Support for models not supported natively.
-   Support for parallelization over explanations, features subsets for non-parallelizable prediction functions.
-   Simplify the use of the combination method.
-   Plotting functionality for Shapley values
-   Computational improvement of the AICc optimization approach
-   Adaptive selection of method to account for the feature dependence

Note that both the features and the prediction must be numeric. The approach is constructed for continuous features. Discrete features may also work just fine with the empirical (conditional) distribution approach. Unlike SHAP and TreeSHAP, we decompose probability predictions directly to ease the interpretability, i.e. not via log odds transformations.

All feedback and suggestions are very welcome.

Installation
------------

To install the current development version, use

``` r
devtools::install_github("NorskRegnesentral/shapr")
```

An example
----------

`shapr` supports computation of Shapley values with any predictive model which takes a set of numeric features and produces a numeric outcome.

The following example shows how a simple `xgboost` model is trained using the *Boston Housing Data*, and how `shapr` explains the individual predictions.

``` r
library(MASS)
library(xgboost)
library(shapr)

data("Boston")

x_var <-  c("lstat", "rm", "dis", "indus")
y_var <- "medv"

x_train <- as.matrix(Boston[-(1:10), x_var])
y_train <- Boston[-(1:10), y_var]
x_test <- as.matrix(Boston[1:10, x_var])

# Quick look at the dependence between the features
cor(x_train)
#>            lstat         rm        dis      indus
#> lstat  1.0000000 -0.6106362 -0.5075796  0.6073291
#> rm    -0.6106362  1.0000000  0.2051866 -0.3897134
#> dis   -0.5075796  0.2051866  1.0000000 -0.7059103
#> indus  0.6073291 -0.3897134 -0.7059103  1.0000000

# The features are are highly correlated

# Fit basic xgboost model to training data
model <- xgboost(
  data = x_train, 
  label = y_train, 
  nround = 20, 
  verbose = FALSE
)

# Prepare the data for explanation
l <- prepare_kshap(
  Xtrain = x_train, 
  Xtest = x_test
)

# Specifying the phi_0, i.e. the expected prediction without any features
pred_zero <- mean(y_train)
print(pred_zero)
#> [1] 22.45484

# Computing the actual Shapley values with kernelSHAP accounting for feature dependence using
# the empirical (conditional) distribution approach with bandwidth parameter sigma = 0.1 (default)
explanation <- compute_kshap(
  model = model,
  l = l,
  pred_zero = pred_zero
)

# Printing the Shapley values for the test data
print(explanation$Kshap)
#>           [,1]       [,2]       [,3]        [,4]        [,5]
#>  [1,] 22.45484  5.3814963 -0.4823530  1.56978008  4.92163556
#>  [2,] 22.45484  0.3344492 -0.8322893  0.97687526  0.37509350
#>  [3,] 22.45484  6.1609843  4.8894905  0.53138409 -2.08265017
#>  [4,] 22.45484  8.9163071  0.3154509 -0.18616672  2.17972216
#>  [5,] 22.45484  0.7486236  6.2298609  0.24828117  2.73695892
#>  [6,] 22.45484  2.5868833 -3.8420937 -0.02532364  3.10387793
#>  [7,] 22.45484 -1.0434064 -1.5499314  1.19064778 -0.83828715
#>  [8,] 22.45484 -5.3505414 -0.4604888  1.34558699 -0.52891751
#>  [9,] 22.45484 -6.0891236 -1.1543907  1.57635992  0.02279797
#> [10,] 22.45484 -4.0430392 -1.2308774  0.55839033 -0.78247565
```

References
----------

Aas, Kjersti, Martin Jullum, and Anders Løland. 2019. “Explaining Individual Predictions When Features Are Dependent: More Accurate Approximations to Shapley Values.” *arXiv Preprint arXiv:1903.10464*.

Hurvich, Clifford M, Jeffrey S Simonoff, and Chih-Ling Tsai. 1998. “Smoothing Parameter Selection in Nonparametric Regression Using an Improved Akaike Information Criterion.” *Journal of the Royal Statistical Society: Series B (Statistical Methodology)* 60 (2). Wiley Online Library: 271–93.

Lundberg, Scott M, and Su-In Lee. 2017. “A Unified Approach to Interpreting Model Predictions.” In *Advances in Neural Information Processing Systems*, 4765–74.

Lundberg, Scott M, Gabriel G Erion, and Su-In Lee. 2018. “Consistent Individualized Feature Attribution for Tree Ensembles.” *arXiv Preprint arXiv:1802.03888*.

Štrumbelj, Erik, and Igor Kononenko. 2014. “Explaining Prediction Models and Individual Predictions with Feature Contributions.” *Knowledge and Information Systems* 41 (3). Springer: 647–65.