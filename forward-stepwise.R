source("./add_model_terms.R")
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
    p <- c()
    selected[["params"]][j] <- list(colnames(X_model))
    selected[["AICc"]][j] <- list(AICc(model))
    for (i in 1:ncol(X_resevoir)) {
      X_add <- cbind(X_model,X_resevoir[,i])
      df_add <- cbind(X_add, "Y"=Y)
      added.model <- lm(Y~., df_add)#added model
      a <- anova(model, added.model)
      p <- append(p,a$`Pr(>F)`[2])
    }
    p_min <- min(na.omit(p))
    if (p_min<enter) {
      added_term_index <- which(p==p_min)#最小のp値を持つ項のindex
      X_model <- cbind(X_model, X_resevoir[added_term_index])
      X_resevoir <- X_resevoir[-added_term_index]#最小のp値を持つ項を除く
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
    selected[["AICc"]][j] <- list(AICc(model))
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
      added_term_index <- which(p==p_min)#最小のp値を持つ項のindex
      if (j==1) {
        X_model <- data.frame(X_resevoir[added_term_index])
      }else{
        X_model <- cbind(X_model, X_resevoir[added_term_index])
      }
      X_resevoir <- X_resevoir[-added_term_index]#最小のp値を持つ項を除く
      df <- cbind(X_model, "Y"=Y)
    }else{
      break 
    }
  }
  return(selected) 
}

# df <- read.csv("dsd-stepwise.csv")
# X <- df[1:4]
# s <- selectX2(X, X_resevoir = add_quadratic(X,only_additional =TRUE), Y=df$Y)
# s <- selectX2_all(X_resevoir = add_quadratic(X), Y=df$Y)

