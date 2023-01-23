#x:名前付きの主効果ベクトル
#list1: 主効果の名前ベクトル
#list2: 2次効果の名前ベクトル
#coefs:1次2次組み合わせたモデルの係数
#return_para==TRUEのときx0を返す
fn <- function(x, list1, list2, coefs, return_para=FALSE){
  x0 <- c(1)
  names(x0) <- c("(Intercept)")
  for (i in 1:length(list1)) {
    x0 <- append(x0, x[list1[i]])
  }
  x2 <- c()
  if (length(list2)>0) {
    for (i in 1:length(list2)) {
      lab <- unlist(strsplit(list2[i], split = "\\."))
      x2 <- append(x2, x[lab[1]]*x[lab[2]])
      names(x2)[i] <- list2[i]
    }
    x0 <- append(x0, x2)
  }
  if (return_para) {
    return(x0)
  }
  #print(x0)
  y <- sum(coefs*x0)
  #print(y)
  return(y)
}
