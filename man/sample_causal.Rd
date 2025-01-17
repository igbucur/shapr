% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sampling.R
\name{sample_causal}
\alias{sample_causal}
\title{Sample conditional Gaussian variables following a causal chain graph with do-calculus.}
\usage{
sample_causal(
  index_given,
  n_samples,
  mu,
  cov_mat,
  m,
  x_test,
  causal_ordering,
  confounding
)
}
\arguments{
\item{index_given}{Integer vector. The indices of the features to condition upon. Note that
\code{min(index_given) >= 1} and \code{max(index_given) <= m}.}

\item{m}{Positive integer. The total number of features.}

\item{x_test}{Numeric matrix. Contains the features of the observation whose
predictions ought to be explained (test data).}

\item{causal_ordering}{List of vectors specifying (partial) causal ordering. Each element in
the list is a component in the order, which can contain one or more variable indices in a vector.
For example, in list(1, c(2, 3)), 2 > 1 and 3 > 1, but 2 and 3 are not comparable.}

\item{confounding}{Logical vector specifying which variables are affected by confounding.
Confounding must be speficied globally with a single TRUE / FALSE value for all components,
or separately for each causal component in the causal ordering.}
}
\value{
data.table
}
\description{
Sample conditional Gaussian variables following a causal chain graph with do-calculus.
}
\examples{
m <- 10
n_samples <- 50
mu <- rep(1, m)
cov_mat <- cov(matrix(rnorm(n_samples * m), n_samples, m))
x_test <- matrix(MASS::mvrnorm(1, mu, cov_mat), nrow = 1)
cnms <- paste0("x", seq(m))
colnames(x_test) <- cnms
index_given <- c(4, 7)
causal_ordering <- list(c(1:3), c(4:6), c(7:10))
confounding <- c(TRUE, FALSE, TRUE)
r <- shapr:::sample_causal(index_given, n_samples, mu, cov_mat, m, x_test, causal_ordering, confounding)

}
\author{
Tom Heskes, Ioan Gabriel Bucur
}
\keyword{internal}
