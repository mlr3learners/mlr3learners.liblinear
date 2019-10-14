#' @title L2-Regularized L1-Loss Support Vector Classification
#'
#' @aliases mlr_learners_classif.liblinearl2l1svc
#' @format [R6::R6Class] inheriting from [mlr3::LearnerClassif].
#'
#' @description
#' A [mlr3::LearnerClassif] for a L2-Regularized L1-Loss Support Vector Classification implemented in [LiblineaR::LiblineaR()] in package \CRANpkg{LiblineaR}.
#'
#' @export
LearnerClassifLiblineaRL2L1SVC = R6Class("LearnerClassifLiblineaRL2L1SVC", inherit = LearnerClassif,
  public = list(
    initialize = function() {
      ps = ParamSet$new(
        params = list(
          ParamDbl$new(id = "cost", default = 1, lower = 0, tags = "train"),
          ParamDbl$new(id = "epsilon", default = 0.1, lower = 0, tags = "train"),
          ParamDbl$new(id = "bias", default = 1, tags = "train")
        )
      )

      super$initialize(
        id = "classif.liblinearl2l1svc",
        packages = "LiblineaR",
        feature_types = "numeric",
        predict_types = "response",
        param_set = ps,
        properties = c("twoclass", "multiclass")
      )
    },

    train_internal = function(task) {
      pars = self$param_set$get_values(tags = "train")
      data = task$data()
      train = data[,task$feature_names, with=FALSE]
      target = data[,task$target_names, with=FALSE]

      invoke(LiblineaR::LiblineaR, data = train, target = target, type = 3L, .args = pars)
    },

    predict_internal = function(task) {
      newdata = task$data(cols = task$feature_names)

      p = invoke(predict, self$model, newx = newdata)
      PredictionClassif$new(task = task, response = p$predictions)
    }
  )
)