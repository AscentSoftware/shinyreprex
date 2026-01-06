#' Custom S7 Classes
#'
#' @description
#' Additional classes to include in S7 to use in `repro_code` and
#' `repro_code_chunk` methods:
#'
#' ## Reactives
#'
#' These variables need to be handled in a specific way to extract non-static values
#' stored in reactive calls.
#'
#' \describe{
#' \item{class_reactive}{The class capturing \code{\link[shiny]{reactive}} calls}
#' \item{class_event_cache}{The class capturing \code{\link[shiny]{bindCache}} calls}
#' \item{class_event_reactive}{The class capturing \code{\link[shiny]{bindEvent}} calls}
#' \item{class_bind_reactive}{
#' The union of `class_event_cache` and `class_event_reactive`
#' }
#' }
#'
#' ## Special Functions
#'
#' When determining evaluating a chunk, the function name gets attached to the class of the
#' chunk, these are special cases that need to be handled in a non-standard way.
#'
#' \describe{
#' \item{class_call_function}{The class capturing anonymous function definitions}
#' \item{class_call_reactive}{The class capturing evaluated \code{\link[shiny]{reactive}} objects}
#' \item{class_call_reactval}{
#' The class capturing evaluated \code{\link[shiny]{reactiveValues}} objects
#' }
#' \item{class_call_if}{The class capturing `if` calls}
#' \item{class_call_null}{The class capturing undefined calls, such as `pkg::fn`}
#' \item{class_call_shiny}{
#' The class capturing ignorable shiny function calls such as
#' \code{\link[shiny]{req}} and \code{\link[shiny]{validate}}
#' }
#' \item{class_call_subset}{The class capturing a subset (\code{$}) call}
#' }
#'
#' @usage NULL
#' @format NULL
#'
#' @keywords internal
#' @rdname s7_classes
class_reactive <- S7::new_S3_class("reactiveExpr")

class_event_cache <- S7::new_S3_class("reactive.cache")
class_event_reactive <- S7::new_S3_class("reactive.event")
class_bind_reactive <- S7::new_union(class_event_reactive, class_event_cache)

class_call_function <- S7::new_S3_class("function")
class_call_reactive <- S7::new_S3_class(".__reactive")
class_call_reactval <- S7::new_S3_class(".__reactval")
class_call_if <- S7::new_S3_class("if")
class_call_null <- S7::new_S3_class("NULL")
class_call_shiny <- S7::new_union(S7::new_S3_class("req"), S7::new_S3_class("validate"))
class_call_subset <- S7::new_S3_class("$")
