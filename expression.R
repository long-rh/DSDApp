expression <- function(result_lm, return_Y=FALSE) {
  coef_name <- names(result_lm$coefficients)
  coef_name[1] <- ""
  coef <- numeric(length(result_lm$coefficients))
  coef[1] <- round(result_lm$coefficients[[1]], 2)
  for (i in 2:length(result_lm$coefficients)) {
    if (result_lm$coefficients[i]>=0) {
      coef[i] <- paste0("+", as.character(round(result_lm$coefficients[i], 2)))#2 decimal-digits
    }else{
      coef[i] <- as.character(round(result_lm$coefficients[i], 2))#2 decimal-digits
    }
  }

  expression <- paste0(coef, coef_name)
  
  string <- paste(expression, collapse="" )
  string
  
  string_y <- as.character(result_lm$terms[[2]])
  if (return_Y) {
    return(string_y)
  }else{
    string <- paste(string_y, paste("=", string))
    return(string)
  }
}