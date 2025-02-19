% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fixest_multi.R
\name{$.fixest_multi}
\alias{$.fixest_multi}
\title{Extracts the root of a fixest_multi object}
\usage{
\method{$}{fixest_multi}(x, name)
}
\arguments{
\item{x}{A \code{fixest_multi} object, obtained from a \code{fixest} estimation leading to multiple results.}

\item{name}{The name of the root element to select.}
}
\value{
It either returns a \code{fixest_multi} object or a \code{fixest} object it there is only one estimation associated to the root element.
}
\description{
Extracts an element at the root of a fixest_multi object.
}
\examples{

base = iris
names(base) = c("y", "x1", "x2", "x3", "species")

# Multiple estimation
res = feols(y ~ csw(x1, x2, x3), base, split = ~species)

# Let's the results for the setosa species
res$setosa

# now for versicolor
etable(res$versicolor)

}
\seealso{
The main fixest estimation functions: \code{\link[fixest]{feols}}, \code{\link[fixest:feglm]{fepois}}, \code{\link[fixest:femlm]{fenegbin}}, \code{\link[fixest]{feglm}}, \code{\link[fixest]{feNmlm}}. Tools for mutliple fixest estimations: \code{\link[fixest]{summary.fixest_multi}}, \code{\link[fixest]{print.fixest_multi}}, \code{\link[fixest]{as.list.fixest_multi}}, \code{\link[fixest]{sub-sub-.fixest_multi}}, \code{\link[fixest]{sub-.fixest_multi}}, \code{\link[fixest]{cash-.fixest_multi}}.
}
