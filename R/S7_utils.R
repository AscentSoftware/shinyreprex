#' Custom S7 Classes
#'
#' @description
#' Additional classes to include in S7 to use in \code{repro_code} methods:
#'
#' \describe{
#' \item{class_reactive}{The class capturing \code{reactive} objects}
#' }
#'
#' @noRd
class_reactive <- S7::new_S3_class("reactiveExpr")

class_event_cache <- S7::new_S3_class("reactive.cache")
class_event_reactive <- S7::new_S3_class("reactive.event")
class_bind_reactive <- S7::new_union(class_event_reactive, class_event_cache)
