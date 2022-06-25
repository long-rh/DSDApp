
# init.R
#
# Example R code to install packages if not already installed
#

my_packages = c("daewr", "shinythemes")

install_if_missing = function(p) {
  if (p %in% rownames(installed.packages()) == FALSE) {
    install.packages(p)
  }
}
#install.packages("StepReg_1.4.2.zip",repos = NULL, type = "win.binary")
install.packages("StepReg.tar.gz", repos = NULL, type = "source")
invisible(sapply(my_packages, install_if_missing))