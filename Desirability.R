#個別満足度の計算
#y1: モデルで計算される目的変数
#t: 目標値
#purpose: minimize/maximize/target
#weight: 1より大きい時最適化の優先度が高まる


sigmoid_for_min <- function(x, target=-1, upper=1){
  x0 <- x-(upper+target)/2
  a = log(99)/(upper-(upper+target)/2)#5%
  return(1/(1+exp(x0*a)))
}

sigmoid_for_max <- function(x, lower=-1, target=1){
  x0 <- x-(lower+target)/2
  a = -log(99)/(lower-(lower+target)/2)#5%
  return(1/(1+exp(-x0*a)))
}


gauss_for_target <- function(x, lower=-1, target=Inf, upper=1){
  if (target==Inf) {
    w <- (upper-lower)/6
    x0 <- x-(lower+upper)/2#targetはlowerとupperの中心とする
    d <- exp(-x0^2/(2*w^2))
  }else {
    if (x<=target) {
      w <- (target-lower)/3
      d <- exp(-(x-target)^2/(2*w^2))
    }
    if (x>target) {
      w <- (upper-target)/3
      d <- exp(-(x-target)^2/(2*w^2))
    }
  }
  return(d) 
}



Desirability <- function(y1, L, t, U, purpose="minimize", weight=1){
  if (purpose == "minimize") {
    d1 <- sigmoid_for_min(y1, t, U)
  }
  if (purpose == "maximize") {
    d1 <- sigmoid_for_max(y1, L, t)
  }
  if (purpose == "target") {
    d1 <- gauss_for_target(y1, L, t, U)
  }
  return(d1)
}

#y <- seq(0, 4, 0.1)
#plot(y, Desirability(y, NA, 1, 3, "minimize"), "l")
#plot(y, Desirability(y, 1, 3, NA, "maximize"), "l")
#plot(y, Desirability(y, 1, 2, 3, "target"), "l")
# # 
# # 
# y <- seq(-10, 10, 1)
# plot(y, Desirability(y, 1, 5, -50, "maximize"))
# # 
# y <- seq(1, 8, .05)
# for (yi in y) {
#   plot(yi, Desirability(yi, 1, 4, 6, purpose="target"), xlim=c(1,8), ylim=c(0, 1.1), xlab="", ylab="")
#   par(new=T)
# }
