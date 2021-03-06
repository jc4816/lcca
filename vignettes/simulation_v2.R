## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)

## -----------------------------------------------------------------------------
library(lcca)
library(MASS)
library(gplots)

sim_lcca <- function(I, r){
  ccor.list = rep(0, 100)
  ccor.dim.list = rep(0, 100)
  xcv_x0.array= array(0, dim=c(144,1,100))
  xcv_x1.array = array(0, dim=c(144,1,100))
  xcv_y0.array = array(0, dim=c(81,1,100))
  xcv_y1.array = array(0, dim=c(81,1,100))

  set.seed(12345678)

  for(i in (1:100)){
    ## -----------------------------------------------------------------------------
    mu = c(0,0,0,0,0,0)
    stddev = sqrt(rep(c(8,4,2),2))
    cormatx = diag(1,6,6)
    cormatx[1,5] <- r
    cormatx[5,1] <- r
    covmatx = stddev %*% t(stddev) * cormatx

    ## Generate scores
    xi = mvrnorm(n = I, mu = mu, Sigma = covmatx, empirical = FALSE)

    ## X
    visit.X =rpois(I,1)+3
    time.X = unlist(lapply(visit.X, function(x) scale(c(0,cumsum(rpois(x-1,1)+1)))))
    J.X = sum(visit.X)
    xi.X = xi[,1:3]
    V.x=144
    phix0 = matrix(0,V.x,3); phix0[1:12, 1]<-.1; phix0[1:12 + 12, 2]<-.1; phix0[1:12 + 12*2, 3]<-.1
    phix1 = matrix(0,V.x,3); phix1[1:12 + 12*3, 1]<-.1; phix1[1:12 + 12*4, 2]<-.1; phix1[1:12 + 12*5, 3]<-.1
    zeta.X = t(matrix(rnorm(J.X*3), ncol=J.X)*c(8,4,2))*2
    X = phix0 %*% t(xi.X[rep(1:I, visit.X),]) + phix1 %*% t(time.X * xi.X[rep(1:I, visit.X),]) + matrix(rnorm(V.x*J.X, 0, .1), V.x, J.X)

    ## Y
    visit.Y=rpois(I,1)+3
    time.Y = unlist(lapply(visit.Y, function(x) scale(c(0,cumsum(rpois(x-1,1)+1)))))
    K.Y = sum(visit.Y)
    V.y=81
    xi.Y = xi[,4:6]
    phiy0 = matrix(0,V.y,3); phiy0[1:9, 1]<-.1; phiy0[1:9 + 9, 2]<-.1; phiy0[1:9 + 9*2, 3]<-.1
    phiy1 = matrix(0,V.y,3); phiy1[1:9 + 9*3, 1]<-.1; phiy1[1:9 + 9*4, 2]<-.1; phiy1[1:9 + 9*5, 3]<-.1
    zeta.Y = t(matrix(rnorm(K.Y*3), ncol=K.Y)*c(8,4,2))*2
    Y = phiy0 %*% t(xi.Y[rep(1:I, visit.Y),]) + phiy1 %*% t(time.Y * xi.Y[rep(1:I, visit.Y),]) + matrix(rnorm(V.y*K.Y ,0, .1), V.y, K.Y)

    ## -----------------------------------------------------------------------------

    x = list(X=X, time=time.X, I=I, J=sum(visit.X), visit=visit.X)
    y = list(X=Y, time=time.Y, I=I, J=sum(visit.Y), visit=visit.Y)

    re = lcca.linear(x=x, y=y)

    ccor.dim.list[i] <- re$ccor.dim
    ccor.list[i] <- re$ccor
    xcv_x0.array[,,i] <- matrix(re$xcv_x0, nrow=144, ncol=1)
    xcv_x1.array[,,i] <- matrix(re$xcv_x1, nrow=144, ncol=1)
    xcv_y0.array[,,i] <- matrix(re$xcv_y0, nrow=81, ncol=1)
    xcv_y1.array[,,i] <- matrix(re$xcv_y1, nrow=81, ncol=1)

    xcv_x0s <- abs(cor(xcv_x0.array[,,i], phix0)[,1])
    xcv_x1s <- abs(cor(xcv_x1.array[,,i], phix1)[,1])

    xcv_y0s <- abs(cor(xcv_y0.array[,,i], phiy0)[,1])
    xcv_y1s <- abs(cor(xcv_y1.array[,,i], phiy1)[,1])
  }

  out=list(ccor.dim.list=ccor.dim.list, ccor.list=ccor.list,
           xcv_x0s=xcv_x0s,
           xcv_x1s=xcv_x1s,
           xcv_y0s=xcv_y0s,
           xcv_y1s=xcv_y1s)
  return(out)
}


## I=50, r=0.8
## I=50, r=0.5
## I=50, r=0.3
## I=50, r=0.1


## I=100, r=0.8
sim1 <- sim_lcca(I=100, r=0.8)

# Dimensions
mean(sim1$ccor.dim.list)
sd(sim1$ccor.dim.list)

# CCs
mean(sim1$ccor.list)
sd(sim1$ccor.list)

# CVs




## I=100, r=0.5
sim2 <- sim_lcca(I=100, r=0.5, varthresh=0.97)

## I=100, r=0.3
sim3 <- sim_lcca(I=100, r=0.2, varthresh=0.97)

## I=100, r=0.1
sim4 <- sim_lcca(I=100, r=0.8, varthresh=0.95)


## I=200, r=0.8
## I=200, r=0.5
## I=200, r=0.3
## I=200, r=0.1


## I=400, r=0.8
## I=400, r=0.5
## I=400, r=0.3
## I=400, r=0.1



