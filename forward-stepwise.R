source("./add_model_terms.R")
#library(MuMIn)#AICc
selectX2 <- function(X_main, X_resevoir, Y, enter=0.2){
  selected <- list()
  X_model <- X_main
  M <- length(Y)-ncol(X_main)-1-1-1
  df <- cbind(X_model, "Y"=Y)
  for (j in 1:M) {
    if (j>ncol(X_resevoir)) {
      break
    }
    model <- lm(Y~., df)#model
    n <- nobs(model)
    k <- length(coef(model))+1
    aicc <- -2*stats::logLik(model)[1]+2*k+2*k*(k+1)/(n-k-1)
    p <- c()
    selected[["params"]][j] <- list(colnames(X_model))
    #selected[["AICc"]][j] <- list(AICc(model))
    selected[["AICc"]][j] <- list(aicc)
    for (i in 1:ncol(X_resevoir)) {
      X_add <- cbind(X_model, X_resevoir[,i])
      df_add <- cbind(X_add, "Y"=Y)
      added.model <- lm(Y~., df_add)#added model
      a <- anova(model, added.model)
      p <- append(p,a$`Pr(>F)`[2])
    }
    p_min <- min(na.omit(p))
    if (p_min<enter) {
      added_term_index <- which(p==p_min)#最小???p値を持つ???のindex
      X_model <- cbind(X_model, X_resevoir[added_term_index])
      X_resevoir <- X_resevoir[-added_term_index]#最小???p値を持つ???を除???
      df <- cbind(X_model, "Y"=Y)
    }else{
      break 
    }
  }
  return(selected) 
}


selectX2_all <- function(X_resevoir, Y, enter=0.2){
  selected <- list()
  M <- length(Y)-1-1-1
  df <- data.frame("Y"=Y)
  X_model <- c()
  
  for (j in 1:M) {
    if (j>ncol(X_resevoir)) {
      break
    }
    model <- lm(Y~., df)#model
    selected[["params"]][j] <- list(colnames(X_model))
    #selected[["AICc"]][j] <- list
    selected[["AICc"]][j] <- list(aicc)
    p <- c()
    for (i in 1:ncol(X_resevoir)) {
      if (j==1) {
        X_add <- data.frame(X_resevoir[,i])
      }else{
        X_add <- data.frame(cbind(X_model, X_resevoir[,i]))
      }
      df_add <- cbind(X_add, "Y"=Y)
      added.model <- lm(Y~., df_add)#added model
      a <- anova(model, added.model)
      p <- append(p,a$`Pr(>F)`[2])
    }
    p_min <- min(na.omit(p))
    if (p_min<enter) {
      added_term_index <- which(p==p_min)#最小???p値を持つ???のindex
      if (j==1) {
        X_model <- data.frame(X_resevoir[added_term_index])
      }else{
        X_model <- cbind(X_model, X_resevoir[added_term_index])
      }
      X_resevoir <- X_resevoir[-added_term_index]#最小???p値を持つ???を除???
      df <- cbind(X_model, "Y"=Y)
    }else{
      break 
    }
  }
  return(selected)
}
