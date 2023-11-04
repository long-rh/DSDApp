df <- read.csv("DSD8.csv")

model1 <- function(df){
  a <- 5
  b <- 4
  c <- 6
  d <- 8
  e <- 10
  ab <- 4
  aa <- 8
  ac <- 6
  v <- rnorm(nrow(df), 2)
  return(a*df$A+b*df$B+c*df$C+d*df$D+e*df$E
         +ab*df$A*df$B
         +aa*df$A*df$A
         +ac*df$A*df$C+v)
}

model2 <- function(df){
  a <- 4
  b <- 5
  c <- 6
  d <- 8
  aa <- 5
  bb <- 8
  cc <- 6
  v <- rnorm(nrow(df), 2)
  return(a*df$A+b*df$B+c*df$C+d*df$D
         +aa*df$A*df$A
         +bb*df$B*df$B
         +cc*df$C*df$C+v)
}



df$Y <- model1(df)
write.csv(df, "DSD8-with-Y1.csv", row.names = FALSE)

df$Y <- model2(df)
write.csv(df, "DSD8-with-Y2.csv", row.names = FALSE)
