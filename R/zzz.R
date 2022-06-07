bc <- function(x) if(!length(x)) NULL else x[lengths(x)>0]

assert <- function(x, what, name = deparse(substitute(x))){
  if(l <- length(x)){
    if(!inherits(x = x, what = what))
      stop(name, " must be of class ", paste0(what, collapse = ", "), call. = FALSE)
    if(length(what) > 1 && "character" %in% what && any(c("integer", "numeric") %in% what))
      if(!grepl("^[0-9]*$", x)) stop(name, " must be coercibled to integer.", call. = FALSE)
  }
  x
}

# print method so the file is readable when printing it
print.ppo_text <- cat
