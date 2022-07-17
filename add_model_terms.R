#This program adds quadratic/interaction terms to df. 

add_quadratic <- function(df, only_additional=FALSE, only_quad=FALSE){
  k <- ncol(df)
  #2-factor interaction
  cnt <- 0
  if (!only_quad) {
    for (i in 1:k) {
      if (i<k) {
        for(j in (i+1):k){
          a <- colnames(df)[i]
          b <- colnames(df)[j]
          cnt <- cnt + 1
          df <- data.frame(df, df[a]*df[b])
          colnames(df)[k+cnt] <- paste0(a,".",b)
        } 
      }
    }
  }
  #quadratic
  for (i in 1:k) {
    a <- colnames(df)[i]
    cnt <- cnt + 1
    df <- data.frame(df, df[a]*df[a])
    colnames(df)[k+cnt] <- paste0(a,".",a)
  }
  if (only_additional) {
    return(df[(k+1):ncol(df)])
  } else{
    return(df)
  }
}


add_interaction <- function(df, only_additional=FALSE){
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
        colnames(df)[k+cnt] <- paste0(a,".",b)
      } 
    }
  }
  if (only_additional) {
    return(df[(k+1):ncol(df)])
  } else{
    return(df)
  }
}
