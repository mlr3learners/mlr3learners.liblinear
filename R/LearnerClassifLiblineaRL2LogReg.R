#' @title L2-Regularized Logistic Regression Learner
#'
#' @name mlr_learners_classif.liblinearl2logreg
#'
#' @description
#' L2-Regularized logistic regression learner.
#' Calls [LiblineaR::LiblineaR()] (`type = 0`) from package \CRANpkg{LiblineaR}.
#'
#'
#' @templateVar id classif.liblinearl2logreg
#' @template section_dictionary_learner
#'
#' @export
#' @template seealso_learner
#' @template example
LearnerClassifLiblineaRL2LogReg = R6Class("LearnerClassifLiblineaRL2LogReg", # nolint
  inherit = LearnerClassif,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      ps = ParamSet$new(
        params = list(
          ParamDbl$new(id = "cost", default = 1, lower = 0, tags = "train"),
          ParamDbl$new(id = "epsilon", default = 0.01, lower = 0, tags = "train"),
          ParamDbl$new(id = "bias", default = 1, tags = "train"),
          ParamInt$new(id = "cross", default = 0L, lower = 0L, tags = "train"),
          ParamLgl$new(id = "verbose", default = FALSE, tags = "train"),
          ParamUty$new(id = "wi", default = NULL, tags = "train"),
          ParamLgl$new(id = "findC", default = FALSE, tags = "train"),
          ParamLgl$new(id = "useInitC", default = TRUE, tags = "train")
        )
      )
      # 50 is an arbitrary choice here
      ps$add_dep("findC", "cross", CondAnyOf$new(seq(2:50)))
      ps$add_dep("useInitC", "findC", CondEqual$new(TRUE))

      super$initialize(
        id = "classif.liblinearl2logreg",
        packages = "LiblineaR",
        feature_types = "numeric",
        predict_types = c("response", "prob"),
        param_set = ps,
        properties = c("twoclass", "multiclass"),
        man = "mlr3learners.liblinear::mlr_learners_classif.liblinearl2logreg"
      )
    }
  ),
  private = list(
    .train = function(task) {
      pars = self$param_set$get_values(tags = "train")
      data = task$data()
      train = data[, task$feature_names, with = FALSE]
      target = data[, task$target_names, with = FALSE]

      mlr3misc::invoke(LiblineaR::LiblineaR, data = train, target = target, type = 0L, .args = pars)
    },

    .predict = function(task) {
      newdata = task$data(cols = task$feature_names)

      if (self$predict_type == "response") {
        p = invoke(predict, self$model, newx = newdata)
        PredictionClassif$new(task = task, response = p$predictions)
      } else {
        p = invoke(predict, self$model, newx = newdata, proba = TRUE)
        PredictionClassif$new(task = task, prob = p$probabilities)
      }
    }
  )
)
