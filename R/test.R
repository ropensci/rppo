#' A Test function
#'
#' This function is just for testing
#' @param state Are you happy = true
#' @keywords test
#' @export
#' @examples
#' cat_function()

ppotest <- function(happy=TRUE){
  if(happy==TRUE){
    print("I love cats!")
  }
  else {
    print("I am not a cool person.")
  }
}
