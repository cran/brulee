% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/linear_reg-fit.R
\name{brulee_linear_reg}
\alias{brulee_linear_reg}
\alias{brulee_linear_reg.default}
\alias{brulee_linear_reg.data.frame}
\alias{brulee_linear_reg.matrix}
\alias{brulee_linear_reg.formula}
\alias{brulee_linear_reg.recipe}
\title{Fit a linear regression model}
\usage{
brulee_linear_reg(x, ...)

\method{brulee_linear_reg}{default}(x, ...)

\method{brulee_linear_reg}{data.frame}(
  x,
  y,
  epochs = 20L,
  penalty = 0.001,
  mixture = 0,
  validation = 0.1,
  optimizer = "LBFGS",
  learn_rate = 1,
  momentum = 0,
  batch_size = NULL,
  stop_iter = 5,
  verbose = FALSE,
  ...
)

\method{brulee_linear_reg}{matrix}(
  x,
  y,
  epochs = 20L,
  penalty = 0.001,
  mixture = 0,
  validation = 0.1,
  optimizer = "LBFGS",
  learn_rate = 1,
  momentum = 0,
  batch_size = NULL,
  stop_iter = 5,
  verbose = FALSE,
  ...
)

\method{brulee_linear_reg}{formula}(
  formula,
  data,
  epochs = 20L,
  penalty = 0.001,
  mixture = 0,
  validation = 0.1,
  optimizer = "LBFGS",
  learn_rate = 1,
  momentum = 0,
  batch_size = NULL,
  stop_iter = 5,
  verbose = FALSE,
  ...
)

\method{brulee_linear_reg}{recipe}(
  x,
  data,
  epochs = 20L,
  penalty = 0.001,
  mixture = 0,
  validation = 0.1,
  optimizer = "LBFGS",
  learn_rate = 1,
  momentum = 0,
  batch_size = NULL,
  stop_iter = 5,
  verbose = FALSE,
  ...
)
}
\arguments{
\item{x}{Depending on the context:
\itemize{
\item A \strong{data frame} of predictors.
\item A \strong{matrix} of predictors.
\item A \strong{recipe} specifying a set of preprocessing steps
created from \code{\link[recipes:recipe]{recipes::recipe()}}.
}

The predictor data should be standardized (e.g. centered or scaled).}

\item{...}{Options to pass to the learning rate schedulers via
\code{\link[=set_learn_rate]{set_learn_rate()}}. For example, the \code{reduction} or \code{steps} arguments to
\code{\link[=schedule_step]{schedule_step()}} could be passed here.}

\item{y}{When \code{x} is a \strong{data frame} or \strong{matrix}, \code{y} is the outcome
specified as:
\itemize{
\item A \strong{data frame} with 1 numeric column.
\item A \strong{matrix} with 1 numeric column.
\item A numeric \strong{vector}.
}}

\item{epochs}{An integer for the number of epochs of training.}

\item{penalty}{The amount of weight decay (i.e., L2 regularization).}

\item{mixture}{Proportion of Lasso Penalty (type: double, default: 0.0). A
value of mixture = 1 corresponds to a pure lasso model, while mixture = 0
indicates ridge regression (a.k.a weight decay).}

\item{validation}{The proportion of the data randomly assigned to a
validation set.}

\item{optimizer}{The method used in the optimization procedure. Possible choices
are 'LBFGS' and 'SGD'. Default is 'LBFGS'.}

\item{learn_rate}{A positive number that controls the initial rapidity that
the model moves along the descent path. Values around 0.1 or less are
typical.}

\item{momentum}{A positive number usually on \verb{[0.50, 0.99]} for the momentum
parameter in gradient descent.  (\code{optimizer = "SGD"} only)}

\item{batch_size}{An integer for the number of training set points in each
batch. (\code{optimizer = "SGD"} only)}

\item{stop_iter}{A non-negative integer for how many iterations with no
improvement before stopping.}

\item{verbose}{A logical that prints out the iteration history.}

\item{formula}{A formula specifying the outcome term(s) on the left-hand side,
and the predictor term(s) on the right-hand side.}

\item{data}{When a \strong{recipe} or \strong{formula} is used, \code{data} is specified as:
\itemize{
\item A \strong{data frame} containing both the predictors and the outcome.
}}
}
\value{
A \code{brulee_linear_reg} object with elements:
\itemize{
\item \code{models_obj}: a serialized raw vector for the torch module.
\item \code{estimates}: a list of matrices with the model parameter estimates per
epoch.
\item \code{best_epoch}: an integer for the epoch with the smallest loss.
\item \code{loss}: A vector of loss values (MSE) at each epoch.
\item \code{dim}: A list of data dimensions.
\item \code{y_stats}: A list of summary statistics for numeric outcomes.
\item \code{parameters}: A list of some tuning parameter values.
\item \code{blueprint}: The \code{hardhat} blueprint data.
}
}
\description{
\code{brulee_linear_reg()} fits a linear regression model.
}
\details{
This function fits a linear combination of coefficients and predictors to
model the numeric outcome. The training process optimizes the
mean squared error loss function.

The function internally standardizes the outcome data to have mean zero and
a standard deviation of one. The prediction function creates predictions on
the original scale.

By default, training halts when the validation loss increases for at least
\code{step_iter} iterations. If \code{validation = 0} the training set loss is used.

The \emph{predictors} data should all be numeric and encoded in the same units (e.g.
standardized to the same range or distribution). If there are factor
predictors, use a recipe or formula to create indicator variables (or some
other method) to make them numeric. Predictors should be in the same units
before training.

The model objects are saved for each epoch so that the number of epochs can
be efficiently tuned. Both the \code{\link[=coef]{coef()}} and \code{\link[=predict]{predict()}} methods for this
model have an \code{epoch} argument (which defaults to the epoch with the best
loss value).

The use of the L1 penalty (a.k.a. the lasso penalty) does \emph{not} force
parameters to be strictly zero (as it does in packages such as \pkg{glmnet}).
The zeroing out of parameters is a specific feature the optimization method
used in those packages.
}
\examples{
\donttest{
if (torch::torch_is_installed()  & rlang::is_installed(c("recipes", "yardstick", "modeldata"))) {

 ## -----------------------------------------------------------------------------

 library(recipes)
 library(yardstick)

 data(ames, package = "modeldata")

 ames$Sale_Price <- log10(ames$Sale_Price)

 set.seed(122)
 in_train <- sample(1:nrow(ames), 2000)
 ames_train <- ames[ in_train,]
 ames_test  <- ames[-in_train,]


 # Using matrices
 set.seed(1)
 brulee_linear_reg(x = as.matrix(ames_train[, c("Longitude", "Latitude")]),
                    y = ames_train$Sale_Price,
                    penalty = 0.10, epochs = 1, batch_size = 64)

 # Using recipe
 library(recipes)

 ames_rec <-
  recipe(Sale_Price ~ Bldg_Type + Neighborhood + Year_Built + Gr_Liv_Area +
         Full_Bath + Year_Sold + Lot_Area + Central_Air + Longitude + Latitude,
         data = ames_train) \%>\%
    # Transform some highly skewed predictors
    step_BoxCox(Lot_Area, Gr_Liv_Area) \%>\%
    # Lump some rarely occurring categories into "other"
    step_other(Neighborhood, threshold = 0.05)  \%>\%
    # Encode categorical predictors as binary.
    step_dummy(all_nominal_predictors(), one_hot = TRUE) \%>\%
    # Add an interaction effect:
    step_interact(~ starts_with("Central_Air"):Year_Built) \%>\%
    step_zv(all_predictors()) \%>\%
    step_normalize(all_numeric_predictors())

 set.seed(2)
 fit <- brulee_linear_reg(ames_rec, data = ames_train,
                           epochs = 5, batch_size = 32)
 fit

 autoplot(fit)

 library(ggplot2)

 predict(fit, ames_test) \%>\%
   bind_cols(ames_test) \%>\%
   ggplot(aes(x = .pred, y = Sale_Price)) +
   geom_abline(col = "green") +
   geom_point(alpha = .3) +
   lims(x = c(4, 6), y = c(4, 6)) +
   coord_fixed(ratio = 1)

 library(yardstick)
 predict(fit, ames_test) \%>\%
   bind_cols(ames_test) \%>\%
   rmse(Sale_Price, .pred)

 }

}
}
\seealso{
\code{\link[=predict.brulee_linear_reg]{predict.brulee_linear_reg()}}, \code{\link[=coef.brulee_linear_reg]{coef.brulee_linear_reg()}},
\code{\link[=autoplot.brulee_linear_reg]{autoplot.brulee_linear_reg()}}
}
