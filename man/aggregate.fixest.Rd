% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/MiscFuns.R
\name{aggregate.fixest}
\alias{aggregate.fixest}
\title{Aggregates the values of DiD coefficients a la Sun and Abraham}
\usage{
\method{aggregate}{fixest}(x, agg, full = FALSE, use_weights = TRUE, ...)
}
\arguments{
\item{x}{A \code{fixest} object.}

\item{agg}{A character scalar describing the variable names to be aggregated, it is pattern-based. All variables that match the pattern will be aggregated. It must be of the form \code{"(root)"}, the parentheses must be there and the resulting variable name will be \code{"root"}. You can add another root with parentheses: \code{"(root1)regex(root2)"}, in which case the resulting name is \code{"root1::root2"}. To name the resulting variable differently you can pass a named vector: \code{c("name" = "pattern")} or \code{c("name" = "pattern(root2)")}. It's a bit intricate sorry, please see the examples.}

\item{full}{Logical scalar, defaults to \code{FALSE}. If \code{TRUE}, then all coefficients are returned, not only the aggregated coefficients.}

\item{use_weights}{Logical, default is \code{TRUE}. If the estimation was weighted, whether the aggregation should take into account the weights. Basically if the weights reflected frequency it should be \code{TRUE}.}

\item{...}{Arguments to be passed to \code{\link[fixest]{summary.fixest}}.}
}
\value{
It returns a matrix representing a table of coefficients.
}
\description{
Simple tool that aggregates the value of CATT coefficients in staggered difference-in-difference setups (see details).
}
\details{
This is a function helping to replicate the estimator from Sun and Abraham (2020). You first need to perform an estimation with cohort and relative periods dummies (typically using the function \code{\link[fixest]{i}}), this leads to estimators of the cohort average treatment effect on the treated (CATT). Then you can use this function to retrieve the average treatment effect on each relative period, or for any other way you wish to aggregate the CATT.

Note that contrary to the SA article, here the cohort share in the sample is considered to be a perfect measure for the cohort share in the population.
}
\examples{

#
# DiD example
#

# first we set up the data

set.seed(1)
n_group = 20
n_per_group = 5

id_i = paste0((1:n_group), ":", rep(1:n_per_group, each = n_group))
id_t = 1:10

base = expand.grid(id = id_i, year = id_t)
base$group = as.numeric(gsub(":.+", "", base$id))

base$year_treated = base$group
base$year_treated[base$group > 10] = 10000
base$treat_post = (base$year >= base$year_treated) * 1
base$time_to_treatment = pmax(base$year - base$year_treated, -1000)
base$treated = (base$year_treated < 10000) * 1

# The effect of the treatment is cohort specific and increases with time
base$y_true = base$treat_post * (1 + 1 * base$time_to_treatment - 1 * base$group)
base$y = base$y_true + rnorm(nrow(base))


# The controls have a time_to_treatment equal to -1000

# we drop the always treated
base = base[base$group > 1,]

# Now we perform the estimation
res_naive = feols(y ~ i(treated, time_to_treatment,
                        ref = -1, drop = -1000) | id + year, base)

res_cohort = feols(y ~ i(time_to_treatment, f2 = group,
                         drop = c(-1, -1000)) | id + year, base)

coefplot(res_naive, ylim = c(-6, 8))
att_true = tapply(base$y_true, base$time_to_treatment, mean)[-1]
points(-9:8 + 0.15, att_true, pch = 15, col = 2)

# The aggregate effect for each period
agg_coef = aggregate(res_cohort, "(ti.*nt)::(-?[[:digit:]]+)")
x = c(-9:-2, 0:8) + .35
points(x, agg_coef[, 1], pch = 17, col = 4)
ci_low = agg_coef[, 1] - 1.96 * agg_coef[, 2]
ci_up = agg_coef[, 1] + 1.96 * agg_coef[, 2]
segments(x0 = x, y0 = ci_low, x1 = x, y1 = ci_up, col = 4)

legend("topleft", col = c(1, 2, 4), pch = c(20, 15, 17),
       legend = c("Naive", "True", "Sun & Abraham"))


# The ATT
aggregate(res_cohort, c("ATT" = "treatment::[^-]"))
mean(base[base$treat_post == 1, "y_true"])

# With etable
etable(res_naive, res_cohort, agg = "(ti.*nt)::(-?[[:digit:]]+):gro")

}
\references{
Liyang Sun and Sarah Abraham, forthcoming, "Estimating Dynamic Treatment Effects in Event Studies with Heterogeneous Treatment Effects". Journal of Econometrics.
}
\author{
Laurent Berge
}
