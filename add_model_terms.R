#This program adds quadratic/interaction terms to df. 

add_quadratic <- function(df){
  k <- ncol(df)
  #2-factor interaction
  cnt <- 0
  for (i in 1:k) {
    if (i<k) {
      for(j in (i+1):k){
        a <- colnames(df)[i]
        b <- colnames(df)[j]
        cnt <- cnt + 1
        df <- data.frame(df, df[a]*df[b])
        colnames(df)[k+cnt] <- paste(a,b,sep=".")#なぜか"."になってしまう
      } 
    }
  }
  #quadratic
  for (i in 1:k) {
    a <- colnames(df)[i]
    cnt <- cnt + 1
    df <- data.frame(df, df[a]*df[a])
    colnames(df)[k+cnt] <- paste(a,a, sep = ".")
  }
  return(df)
}


add_interaction <- function(df){
  k <- ncol(df)
  #2-factor interaction
  cnt <- 0
  for (i in 1:k) {
    if (i<k) {
      for(j in (i+1):k){
        a <- colnames(df)[i]
        b <- colnames(df)[j]
        cnt <- cnt + 1
        df <- data.frame(df, df[a]*df[b])
        colnames(df)[k+cnt] <- paste0(a,b)
      } 
    }
  }
  return(df)
}


add_quadratic_heredity <- function(df, c){
  df2 <- df
  k <- ncol(df)
  factors<- c(1:k)
  active_factors <- c[-1]
  #2-factor interactions except for ones between active_factors
  cnt <- 0
  for (i in active_factors) {
    a <- colnames(df)[i]
    for(j in factors[-active_factors]){
        b <- colnames(df)[j]
        cnt <- cnt + 1
        df2 <- data.frame(df2, df[a]*df[b])
        colnames(df2)[k+cnt] <- paste0(a,b)
    } 
  }
  #2-factor interactions of ones between active_factors
  l <-length(active_factors)
  for (i in active_factors) {
    if (i<l) {
      for(j in active_factors[(i+1):l]){
        a <- colnames(df)[i]
        b <- colnames(df)[j]
        cnt <- cnt + 1
        df2 <- data.frame(df2, df[a]*df[b])
        colnames(df2)[k+cnt] <- paste0(a,b)
      }
    }
  }
  
  #quadratic of active_factor
  for (i in active_factors) {
    a <- colnames(df)[i]
    cnt <- cnt + 1
    df2 <- data.frame(df2, df[a]*df[a])
    colnames(df2)[k+cnt] <- paste0(a,a)
  }
  return(df2)
}
