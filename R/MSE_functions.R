#' Check Convergence
#' 
#' Have I undertaken enough simulations (nsim)? Has my MSE converged on stable
#' (reliable) peformance metrics?
#' 
#' 
#' @param MSEobj An MSE object of class \code{'MSE'}
#' @param thresh The convergence threshold (percentage). If mean performance
#' metrics are within thresh percent of the second to last interation, the MSE
#' can be considered to have converged.
#' @param Plot Should figures be plotted?
#' @author A. Hordyk
#' @export Converge
Converge <- function(MSEobj, thresh = 2, Plot = TRUE) {
  nm <- MSEobj@nMPs
  nsim <- MSEobj@nsim
  proyears <- MSEobj@proyears
  
  Yd <- CumlYd <- array(NA, c(nm, nsim))
  P10 <- CumlP10 <- array(NA, c(nm, nsim))
  P50 <- CumlP50 <- array(NA, c(nm, nsim))
  P100 <- CumlP100 <- array(NA, c(nm, nsim))
  POF <- CumlPOF <- array(NA, c(nm, nsim))
  yind <- max(MSEobj@proyears - 4, 1):MSEobj@proyears
  RefYd <- MSEobj@OM$RefY
  
  for (m in 1:nm) {
    Yd[m, ] <- round(apply(MSEobj@C[, m, yind], 1, mean, na.rm = T)/RefYd *  100, 1)
    POF[m, ] <- round(apply(MSEobj@F_FMSY[, m, ] >= 1, 1, sum, na.rm = T)/proyears * 100, 1)
    P10[m, ] <- round(apply(MSEobj@B_BMSY[, m, ] <= 0.1, 1, sum, na.rm = T)/proyears * 100, 1)
    P50[m, ] <- round(apply(MSEobj@B_BMSY[, m, ] <= 0.5, 1, sum, na.rm = T)/proyears * 100, 1)
    P100[m, ] <- round(apply(MSEobj@B_BMSY[, m, ] <= 1, 1, sum, na.rm = T)/proyears * 100, 1)
    CumlYd[m, ] <- cumsum(Yd[m, ])/seq_along(Yd[m, ])  #/ mean(Yd[m,], na.rm=TRUE) 
    CumlPOF[m, ] <- cumsum(POF[m, ])/seq_along(POF[m, ])  # / mean(POF[m,], na.rm=TRUE)
    CumlP10[m, ] <- cumsum(P10[m, ])/seq_along(P10[m, ])  # / mean(P10[m,], na.rm=TRUE)
    CumlP50[m, ] <- cumsum(P50[m, ])/seq_along(P50[m, ])  # / mean(P50[m,], na.rm=TRUE)
    CumlP100[m, ] <- cumsum(P100[m, ])/seq_along(P100[m, ])  # / mean(P100[m,], na.rm=TRUE)
  }
  
  # CumlYd[is.nan(CumlYd)] <- 1 CumlPOF[is.nan(CumlPOF)] <- 1
  # CumlP10[is.nan(CumlP10)] <- 1 CumlP50[is.nan(CumlP50)] <- 1
  # CumlP100[is.nan(CumlP100)] <- 1
  
  if (Plot) {	  
    op <- par(mfrow = c(2, 3), cex.axis = 1.5, cex.lab = 1.7, oma = c(1, 1, 0, 0), mar = c(5, 5, 1, 1), bty = "l")
    matplot(t(CumlYd), type = "l", xlab = "Iteration", ylab = "Rel. Yield")
    matplot(t(CumlPOF), type = "l", xlab = "Iteration", ylab = "Prob. F/FMSY > 1")
    matplot(t(CumlP10), type = "l", xlab = "Iteration", ylab = "Prob. B/BMSY < 0.1")
    matplot(t(CumlP50), type = "l", xlab = "Iteration", ylab = "Prob. B/BMSY < 0.5")
    matplot(t(CumlP100), type = "l", xlab = "Iteration", ylab = "Prob. B/BMSY < 1")
    
  }
  
  Chk <- function(X) {
    # checks if difference in last 10 iterations is greater than thresh
    L <- length(X)
    Y <- 1:min(nsim, 10)
    
    # return(mean(abs((X[L-1:10] - X[L]))/X[L], na.rm=TRUE) > thresh)
    return(mean(abs((X[L - Y] - X[L])), na.rm = TRUE) > thresh)
  }
  
  NonCon <- sort(unique(c(which(apply(CumlYd, 1, Chk)), 
                          which(apply(CumlPOF, 1, Chk)), 
                          which(apply(CumlP10, 1, Chk)), 
                          which(apply(CumlP50, 1, Chk)), 
                          which(apply(CumlP100, 1, Chk)))))
  
  if (length(NonCon) > 0) {
    if (Plot) {
      plot(c(0, 1), c(0, 1), type = "n", axes = FALSE, xlab = "", 
           ylab = "")
      text(0.5, 0.5, "Some MPs have not converged", cex = 1)
      # ev.new()
      par(mfrow = c(2, 3), cex.axis = 1.5, cex.lab = 1.7, oma = c(1, 
                                                                  1, 0, 0), mar = c(5, 5, 1, 1), bty = "l")
      if (length(NonCon) > 1) {
        matplot(t(CumlYd[NonCon, ]), type = "l", xlab = "Iteration",  ylab = "Rel. Yield", lwd = 2, lty=1:length(NonCon))
      } else matplot((CumlYd[NonCon, ]), type = "l", xlab = "Iteration",  ylab = "Rel. Yield", lwd = 2, lty=1:length(NonCon))
      if (length(NonCon) > 1) {
        matplot(t(CumlPOF[NonCon, ]), type = "l", xlab = "Iteration", ylab = "Prob. F/FMSY > 1", lwd = 2, lty=1:length(NonCon))
      } else matplot((CumlPOF[NonCon, ]), type = "l", xlab = "Iteration", ylab = "Prob. F/FMSY > 1", lwd = 2, lty=1:length(NonCon))  
      if (length(NonCon) > 1) {
        matplot(t(CumlP10[NonCon, ]), type = "l", xlab = "Iteration", ylab = "Prob. B/BMSY < 0.1", lwd = 2, lty=1:length(NonCon))
      } else matplot((CumlP10[NonCon, ]), type = "l", xlab = "Iteration", ylab = "Prob. B/BMSY < 0.1", lwd = 2, lty=1:length(NonCon))
      if (length(NonCon) > 1) {
        matplot(t(CumlP50[NonCon, ]), type = "l", xlab = "Iteration", ylab = "Prob. B/BMSY < 0.5", lwd = 2, lty=1:length(NonCon))
      } else matplot((CumlP50[NonCon, ]), type = "l", xlab = "Iteration", ylab = "Prob. B/BMSY < 0.5", lwd = 2, lty=1:length(NonCon))
      if (length(NonCon) > 1) {
        matplot(t(CumlP100[NonCon, ]), type = "l", xlab = "Iteration", ylab = "Prob. B/BMSY < 1", lwd = 2, lty=1:length(NonCon))
      } else matplot((CumlP100[NonCon, ]), type = "l", xlab = "Iteration", ylab = "Prob. B/BMSY < 1", lwd = 2, lty=1:length(NonCon))
      
      legend(nsim * 1.25, 50, legend = MSEobj@MPs[NonCon], col = 1:length(NonCon), 
             bty = "n", xpd = NA, lty = 1:length(NonCon), lwd = 2, cex = 1.25)
    }
    
    message("Some MPs may not have converged in ", nsim, " iterations (threshold = ", thresh, "%)")
    message("MPs are: ", paste(MSEobj@MPs[NonCon], " "))
    message("MPs #: ", paste(NonCon, " "))
    return(data.frame(Num = NonCon, MP = MSEobj@MPs[NonCon]))
  }
  if (length(NonCon) == 0) {
    if (Plot) {
      plot(c(0, 1), c(0, 1), type = "n", axes = FALSE, xlab = "", 
           ylab = "")
      text(0.5, 0.5, "All MPs converged", cex = 1)
    }
    message("All MPs appear to have converged in ", nsim, " iterations (threshold = ", 
            thresh, "%)")
  }
  par(op)
}



#' MSE convergence diagnostic
#' 
#' Have I undertaken enough simulations (nsim)? Has my MSE converged on stable
#' (reliable) peformance metrics?
#' 
#' 
#' @param MSEobj An object of class 'MSE'
#' @param thresh The convergence threshold (percentage). If mean perforamnce
#' metrics are within thresh percent of the second to last interation, the MSE
#' can be considered to have converged.
#' @param Plot Should figures be plotted?
#' @author A. Hordyk
#' @export CheckConverg
CheckConverg <- function(MSEobj, thresh = 2, Plot = TRUE) {
  .Deprecated("Converge")
  nm <- MSEobj@nMPs
  nsim <- MSEobj@nsim
  proyears <- MSEobj@proyears
  
  Yd <- CumlYd <- array(NA, c(nm, nsim))
  P10 <- CumlP10 <- array(NA, c(nm, nsim))
  P50 <- CumlP50 <- array(NA, c(nm, nsim))
  P100 <- CumlP100 <- array(NA, c(nm, nsim))
  POF <- CumlPOF <- array(NA, c(nm, nsim))
  yind <- max(MSEobj@proyears - 4, 1):MSEobj@proyears
  RefYd <- MSEobj@OM$RefY
  
  for (m in 1:nm) {
    Yd[m, ] <- round(apply(MSEobj@C[, m, yind], 1, mean, na.rm = T)/RefYd * 
                       100, 1)
    POF[m, ] <- round(apply(MSEobj@F_FMSY[, m, ] >= 1, 1, sum, na.rm = T)/proyears * 
                        100, 1)
    P10[m, ] <- round(apply(MSEobj@B_BMSY[, m, ] <= 0.1, 1, sum, na.rm = T)/proyears * 
                        100, 1)
    P50[m, ] <- round(apply(MSEobj@B_BMSY[, m, ] <= 0.5, 1, sum, na.rm = T)/proyears * 
                        100, 1)
    P100[m, ] <- round(apply(MSEobj@B_BMSY[, m, ] <= 1, 1, sum, na.rm = T)/proyears * 
                         100, 1)
    CumlYd[m, ] <- cumsum(Yd[m, ])/seq_along(Yd[m, ])  #/ mean(Yd[m,], na.rm=TRUE) 
    CumlPOF[m, ] <- cumsum(POF[m, ])/seq_along(POF[m, ])  # / mean(POF[m,], na.rm=TRUE)
    CumlP10[m, ] <- cumsum(P10[m, ])/seq_along(P10[m, ])  # / mean(P10[m,], na.rm=TRUE)
    CumlP50[m, ] <- cumsum(P50[m, ])/seq_along(P50[m, ])  # / mean(P50[m,], na.rm=TRUE)
    CumlP100[m, ] <- cumsum(P100[m, ])/seq_along(P100[m, ])  # / mean(P100[m,], na.rm=TRUE)
  }
  
  # CumlYd[is.nan(CumlYd)] <- 1 CumlPOF[is.nan(CumlPOF)] <- 1
  # CumlP10[is.nan(CumlP10)] <- 1 CumlP50[is.nan(CumlP50)] <- 1
  # CumlP100[is.nan(CumlP100)] <- 1
  if (Plot) {
    op <- par(mfrow = c(2, 3), cex.axis = 1.5, cex.lab = 1.7, oma = c(1, 1, 0, 0), 
              mar = c(5, 5, 1, 1), bty = "l")
    matplot(t(CumlYd), type = "l", xlab = "Iteration", ylab = "Rel. Yield")
    matplot(t(CumlPOF), type = "l", xlab = "Iteration", ylab = "Prob. F/FMSY > 1")
    matplot(t(CumlP10), type = "l", xlab = "Iteration", ylab = "Prob. B/BMSY < 0.1")
    matplot(t(CumlP50), type = "l", xlab = "Iteration", ylab = "Prob. B/BMSY < 0.5")
    matplot(t(CumlP100), type = "l", xlab = "Iteration", ylab = "Prob. B/BMSY < 1")
    
  }
  
  Chk <- function(X) {
    # checks if difference in last 10 iterations is greater than thresh
    L <- length(X)
    Y <- 1:min(nsim, 10)
    
    # return(mean(abs((X[L-1:10] - X[L]))/X[L], na.rm=TRUE) > thresh)
    return(mean(abs((X[L - Y] - X[L])), na.rm = TRUE) > thresh)
  }
  
  NonCon <- sort(unique(c(which(apply(CumlYd, 1, Chk)), which(apply(CumlPOF, 
                                                                    1, Chk)), which(apply(CumlP10, 1, Chk)), which(apply(CumlP50, 1, 
                                                                                                                         Chk)), which(apply(CumlP100, 1, Chk)))))
  
  if (length(NonCon) == 1) 
    NonCon <- rep(NonCon, 2)
  if (length(NonCon) > 0) {
    if (Plot) {
      plot(c(0, 1), c(0, 1), type = "n", axes = FALSE, xlab = "", 
           ylab = "")
      text(0.5, 0.5, "Some MPs have not converged", cex = 1)
      # ev.new()
      par(mfrow = c(2, 3), cex.axis = 1.5, cex.lab = 1.7, oma = c(1, 
                                                                  1, 0, 0), mar = c(5, 5, 1, 1), bty = "l")
      matplot(t(CumlYd[NonCon, ]), type = "b", xlab = "Iteration", 
              ylab = "Rel. Yield", lwd = 2)
      matplot(t(CumlPOF[NonCon, ]), type = "b", xlab = "Iteration", 
              ylab = "Prob. F/FMSY > 1", lwd = 2)
      matplot(t(CumlP10[NonCon, ]), type = "b", xlab = "Iteration", 
              ylab = "Prob. B/BMSY < 0.1", lwd = 2)
      matplot(t(CumlP50[NonCon, ]), type = "b", xlab = "Iteration", 
              ylab = "Prob. B/BMSY < 0.5", lwd = 2)
      matplot(t(CumlP100[NonCon, ]), type = "b", xlab = "Iteration", 
              ylab = "Prob. B/BMSY < 1", lwd = 2)
      legend(nsim * 1.25, 50, legend = MSEobj@MPs[NonCon], col = 1:length(NonCon), 
             bty = "n", xpd = NA, lty = 1, lwd = 2, cex = 1.25)
    }
    
    message("Some MPs may not have converged in ", nsim, " iterations (threshold = ", 
            thresh, "%)")
    message("MPs are: ", paste(MSEobj@MPs[NonCon], " "))
    message("MPs #: ", paste(NonCon, " "))
    return(data.frame(Num = NonCon, MP = MSEobj@MPs[NonCon]))
  }
  if (length(NonCon) == 0) {
    if (Plot) {
      plot(c(0, 1), c(0, 1), type = "n", axes = FALSE, xlab = "", 
           ylab = "")
      text(0.5, 0.5, "All MPs converged", cex = 1)
    }
    message("All MPs appear to have converged in ", nsim, " iterations (threshold = ", 
            thresh, "%)")
  }
  par(op)
}


















# Kobe plot Kplot<-function(MSEobj,maxsim=60,nam=NA){
# nr<-floor((MSEobj@nMPs)^0.5) nc<-ceiling((MSEobj@nMPs)/nr)

# FMSYr<-quantile(MSEobj@F_FMSY,c(0.001,0.90),na.rm=T)
# BMSYr<-quantile(MSEobj@B_BMSY,c(0.001,0.975),na.rm=T)

# #dev.new2(width=nc*3,height=nr*3.6)
# par(mfrow=c(nr,nc),mai=c(0.45,0.45,0.45,0.01),omi=c(0.45,0.3,0.35,0.01))

# colsse<-rainbow(MSEobj@proyears,start=0.63,end=0.95)[1:MSEobj@proyears]
# colsse<-makeTransparent(colsse,95)

# for(mm in 1:MSEobj@nMPs){
# plot(c(MSEobj@B_BMSY[1,mm,1],MSEobj@B_BMSY[1,mm,2]),
# c(MSEobj@F_FMSY[1,mm,1],MSEobj@F_FMSY[1,mm,2]),xlim=BMSYr,ylim=FMSYr,
# col=colsse[1],type='l')

# OO<-round(sum(MSEobj@B_BMSY[,mm,MSEobj@proyears]<1&MSEobj@F_FMSY[,mm,MSEobj@proyears]>1,na.rm=T)/MSEobj@nsim*100,1)
# OU<-round(sum(MSEobj@B_BMSY[,mm,MSEobj@proyears]>1&MSEobj@F_FMSY[,mm,MSEobj@proyears]>1,na.rm=T)/MSEobj@nsim*100,1)
# UO<-round(sum(MSEobj@B_BMSY[,mm,MSEobj@proyears]<1&MSEobj@F_FMSY[,mm,MSEobj@proyears]<1,na.rm=T)/MSEobj@nsim*100,1)
# UU<-round(sum(MSEobj@B_BMSY[,mm,MSEobj@proyears]>1&MSEobj@F_FMSY[,mm,MSEobj@proyears]<1,na.rm=T)/MSEobj@nsim*100,1)

# #alp<-80
# #polygon(c(1,-1000,-1000,1),c(1,1,1000,1000),col=makeTransparent('orange',alp),border=makeTransparent('orange',alp))
# #polygon(c(1,1000,1000,1),c(1,1,1000,1000),col=makeTransparent('yellow',alp),border=makeTransparent('yellow',alp))
# #polygon(c(1,-1000,-1000,1),c(1,1,-1000,-1000),col=makeTransparent('yellow',alp),border=makeTransparent('yellow',alp))
# #polygon(c(1,1000,1000,1),c(1,1,-1000,-1000),col=makeTransparent('green',alp),border=makeTransparent('yellow',alp))


# abline(h=1,col='grey',lwd=3) abline(v=1,col='grey',lwd=3)
# #abline(v=c(0.1,0.5),col='grey',lwd=2) rng<-1:min(maxsim,MSEobj@nsim)
# for(i in rng){ for(y in 1:(MSEobj@proyears-1)){
# lines(c(MSEobj@B_BMSY[i,mm,y],MSEobj@B_BMSY[i,mm,y+1]),
# c(MSEobj@F_FMSY[i,mm,y],MSEobj@F_FMSY[i,mm,y+1]),
# col=colsse[y],lwd=1.6) } }

# points(MSEobj@B_BMSY[rng,mm,1],MSEobj@F_FMSY[rng,mm,1],pch=19,cex=0.8,col=colsse[1])
# points(MSEobj@B_BMSY[rng,mm,MSEobj@proyears],MSEobj@F_FMSY[rng,mm,MSEobj@proyears],pch=19,cex=0.8,col=colsse[MSEobj@proyears])

# if(mm==1)legend('right',c('Start','End'),bty='n',text.col=c(colsse[1],colsse[MSEobj@proyears]),pch=19,col=c(colsse[1],colsse[MSEobj@proyears]))
# legend('topleft',paste(OO,'%',sep=''),bty='n',text.font=2)
# legend('topright',paste(OU,'%',sep=''),bty='n',text.font=2)
# legend('bottomleft',paste(UO,'%',sep=''),bty='n',text.font=2)
# legend('bottomright',paste(UU,'%',sep=''),bty='n',text.font=2)

# mtext(MSEobj@MPs[mm],3,line=0.45) }
# mtext('B/BMSY',1,outer=T,line=1.4) mtext('F/FMSY',2,outer=T,line=0.2)
# if(is.na(nam))mtext(deparse(substitute(MSEobj)),3,outer=T,line=0.25,font=2)
# if(!is.na(nam))mtext(MSEobj@Name,3,outer=T,line=0.25,font=2) }





# Value of information analysis
# Value of information




# Manipulation of MSE Object
# --------------------------------------------------- Subset the MSE
# object by particular MPs (either MP number or name), or particular
# simulations

#' Check that MSE object includes all slots
#' 
#' Check that an MSE object includes all slots in the latest version of DLMtool
#' Use `updateMSE` to update the MSE object
#' 
#' @param MSEobj A MSE object.
#' @author A. Hordyk
#' @export checkMSE
checkMSE <- function(MSEobj) {
  nms <- slotNames(MSEobj)
  errs <- NULL
  for (x in seq_along(nms)) {
    chk <- try(slot(MSEobj, nms[x]), silent=TRUE)
    if (class(chk) == "try-error") errs <- c(errs, x)
  }
  if (length(errs) > 0) {
    message("MSE object slots not found: ", paste(nms[errs], ""))
    stop("slot names of MSEobj don't match MSE object class. Try use `updateMSE`", call.=FALSE)
    return(FALSE)
  }
  return(TRUE)
}



#' Subset MSE object by management procedure (MP) or simulation.
#' 
#' Subset the MSE object by particular MPs (either MP number or name), or
#' particular simulations, or a subset of the projection years (e.g., 1: <
#' projection years).
#' 
#' @param MSEobj A MSE object.
#' @param MPs A vector MPs names or MP numbers to subset the MSE object.
#' Defaults to all MPs.
#' @param sims A vector of simulation numbers to subset the MSE object. Can
#' also be a logical vector. Defaults to all simulations.
#' @param years A numeric vector of projection years. Should start at 1 and
#' increase by one to some value equal or less than the total number of
#' projection years.
#' @author A. Hordyk
#' @export Sub
Sub <- function(MSEobj, MPs = NULL, sims = NULL, years = NULL) {
  
  checkMSE(MSEobj) # check that MSE object contains all slots 
  
  Class <- class(MPs) 
  if (Class == "NULL") subMPs <- MSEobj@MPs
  if (Class == "integer" | Class == "numeric") subMPs <- MSEobj@MPs[as.integer(MPs)]
  if (Class == "character") subMPs <- MPs
  if (Class == "factor") subMPs <- as.character(MPs)
  SubMPs <- match(subMPs, MSEobj@MPs)  #  which(MSEobj@MPs %in% subMPs)
  not <- (subMPs %in% MSEobj@MPs)  # Check for MPs misspelled
  ind <- which(not == FALSE)
  newMPs <- MSEobj@MPs[SubMPs]
  if (length(SubMPs) < 1) stop("MPs not found")
  if (length(ind > 0)) {
    message("Warning: MPs not found - ", paste0(subMPs[ind], " "))
    message("Subsetting by MPs: ", paste0(newMPs, " "))
  }
  
  
  ClassSims <- class(sims)
  if (ClassSims == "NULL")  SubIts <- 1:MSEobj@nsim
  if (ClassSims == "integer" | ClassSims == "numeric") {
    # sims <- 1:min(MSEobj@nsim, max(sims))
    SubIts <- as.integer(sims)
  }
  if (ClassSims == "logical")  SubIts <- which(sims)
  nsim <- length(SubIts)
  
  ClassYrs <- class(years)
  AllNYears <- MSEobj@proyears
  if (ClassYrs == "NULL") 
    Years <- 1:AllNYears
  if (ClassYrs == "integer" | ClassYrs == "numeric") 
    Years <- years
  if (max(Years) > AllNYears) 
    stop("years exceeds number of years in MSE")
  if (min(Years) <= 0) 
    stop("years must be positive")
  if (min(Years) != 1) {
    message("Not starting from first year. Are you sure you want to do this?")
    message("Probably a bad idea!")
  }
  if (!all(diff(Years) == 1)) 
    stop("years are not consecutive")
  if (length(Years) <= 1) 
    stop("You are going to want more than 1 projection year")
  MSEobj@proyears <- max(Years)
  
  SubF <- MSEobj@F_FMSY[SubIts, SubMPs, Years, drop = FALSE]
  SubB <- MSEobj@B_BMSY[SubIts, SubMPs, Years, drop = FALSE]
  SubC <- MSEobj@C[SubIts, SubMPs, Years, drop = FALSE]
  SubBa <- MSEobj@B[SubIts, SubMPs, Years, drop = FALSE]
  SubFMa <- MSEobj@FM[SubIts, SubMPs, Years, drop = FALSE]
  SubTACa <- MSEobj@TAC[SubIts, SubMPs, Years, drop = FALSE]
  
  OutOM <- MSEobj@OM[SubIts, ]
  # check if slot exists
  tt <- try(slot(MSEobj, "Effort"), silent = TRUE)
  if (class(tt) == "try-error")  slot(MSEobj, "Effort") <- array(NA)
  if (all(is.na(tt)) || all(tt == 0)) slot(MSEobj, "Effort") <- array(NA)
  if (all(is.na(MSEobj@Effort))) {
    SubEffort <- array(NA)
  } else {
    SubEffort <- MSEobj@Effort[SubIts, SubMPs, Years, drop = FALSE]
  }
  
  # check if slot exists
  tt <- try(slot(MSEobj, "SSB"), silent = TRUE)
  if (class(tt) == "try-error") slot(MSEobj, "SSB") <- array(NA)
  if (all(is.na(tt)) || all(tt == 0))slot(MSEobj, "SSB") <- array(NA)
  if (all(is.na(MSEobj@SSB))) {
    SubSSB <- array(NA)
  } else {
    SubSSB <- MSEobj@SSB[SubIts, SubMPs, Years, drop = FALSE]
  }
  
  # check if slot exists
  tt <- try(slot(MSEobj, "VB"), silent = TRUE)
  if (class(tt) == "try-error") slot(MSEobj, "VB") <- array(NA)
  if (all(is.na(tt)) || all(tt == 0)) slot(MSEobj, "VB") <- array(NA)
  if (all(is.na(MSEobj@VB))) {
    SubVB <- array(NA)
  } else {
    SubVB <- MSEobj@VB[SubIts, SubMPs, Years, drop = FALSE]
  }
  
  # check if slot exists
  tt <- try(slot(MSEobj, "PAA"), silent = TRUE)
  if (class(tt) == "try-error") slot(MSEobj, "PAA") <- array(NA)
  if (all(is.na(tt)) || all(tt == 0))slot(MSEobj, "PAA") <- array(NA)
  if (all(is.na(MSEobj@PAA))) {
    SubPAA <- array(NA)
  } else {
    SubPAA <- MSEobj@PAA[SubIts, SubMPs, , drop = FALSE]
  }  
  
  # check if slot exists
  tt <- try(slot(MSEobj, "CAL"), silent = TRUE)
  if (class(tt) == "try-error") slot(MSEobj, "CAL") <- array(NA)
  if (all(is.na(tt)) || all(tt == 0)) slot(MSEobj, "CAL") <- array(NA)
  if (all(is.na(MSEobj@CAL))) {
    SubCAL <- array(NA)
  } else {
    SubCAL <- MSEobj@CAL[SubIts, SubMPs, , drop = FALSE]
  } 
  
  # check if slot exists
  tt <- try(slot(MSEobj, "CAA"), silent = TRUE)
  if (class(tt) == "try-error") slot(MSEobj, "CAA") <- array(NA)
  if (all(is.na(tt)) || all(tt == 0)) slot(MSEobj, "CAA") <- array(NA)
  if (all(is.na(MSEobj@CAA))) {
    SubCAA <- array(NA)
  } else {
    SubCAA <- MSEobj@CAA[SubIts, SubMPs, , drop = FALSE]
  } 
  
  CALbins <- MSEobj@CALbins 
  
  SubResults <- new("MSE", Name = MSEobj@Name, nyears = MSEobj@nyears, 
                    proyears = MSEobj@proyears, nMPs = length(SubMPs), MPs = newMPs, 
                    nsim = length(SubIts), OM = OutOM, Obs = MSEobj@Obs[SubIts, , drop = FALSE],
                    B_BMSY = SubB, F_FMSY = SubF, B = SubBa, SSB=SubSSB, VB=SubVB, 
                    FM = SubFMa,  SubC, 
                    TAC = SubTACa, SSB_hist = MSEobj@SSB_hist[SubIts, , , , drop = FALSE], 
                    CB_hist = MSEobj@CB_hist[SubIts, , , , drop = FALSE], 
                    FM_hist = MSEobj@FM_hist[SubIts, , , , drop = FALSE], 
                    Effort = SubEffort, PAA=SubPAA, CAL=SubCAL, CAA=SubCAA , CALbins=CALbins,
                    Misc=list())
  
  return(SubResults)
}

#' Join multiple MSE objects together
#' 
#' Joins two or more MSE objects together. MSE objects must have identical
#' number of historical years, and projection years.
#' 
#' 
#' @param MSEobjs A list of MSE objects. Must all have identical operating
#' model and MPs. MPs which don't appear in all MSE objects will be dropped.
#' @return An object of class \code{MSE}
#' @author A. Hordyk
#' @export joinMSE
joinMSE <- function(MSEobjs = NULL) {
  # join two or more MSE objects
  if (class(MSEobjs) != "list") stop("MSEobjs must be a list")
  if (length(MSEobjs) < 2) stop("MSEobjs list doesn't contain multiple MSE objects")
  
  lapply(MSEobjs, checkMSE) # check that MSE objects contains all slots 
  
  MPNames <- lapply(MSEobjs, getElement, name = "MPs")  # MPs in each object 
  allsame <- length(unique(lapply(MPNames, unique))) == 1
  
  if (!allsame) {
    # drop the MPs that don't appear in all MSEobjs
    mpnames <- unlist(MPNames)
    npack <- length(MSEobjs)
    tab <- table(mpnames)
    ind <- tab == npack
    commonMPs <- names(tab)[ind]
    MSEobjs <- lapply(MSEobjs, Sub, MPs = commonMPs)
    message("MPs not in all MSE objects:")
    message(paste(names(tab)[!ind], ""))
    message("Dropped from final MSE object.")
  }
  
  Nobjs <- length(MSEobjs)
  for (X in 1:Nobjs) {
    tt <- MSEobjs[[X]]
    assign(paste0("obj", X), tt)
    if (X > 1) {
      tt <- MSEobjs[[X]]
      tt2 <- MSEobjs[[X - 1]]
      if (!all(slotNames(tt) == slotNames(tt2))) 
        stop("The MSE objects don't have the same slots")
      if (any(tt@MPs != tt2@MPs)) 
        stop("MPs must be the same for all MSE objects")
    }
  }
  
  # Check that nyears and proyears are the same for all
  chkmat <- matrix(NA, nrow = Nobjs, ncol = 2)
  nms <- NULL
  for (X in 1:Nobjs) {
    tt <- get(paste0("obj", X))
    chkmat[X, ] <- c(tt@nyears, tt@proyears)
    if (X > 1) 
      if (!any(grepl(tt@Name, nms))) 
        stop("MSE objects have different names")
    nms <- append(nms, tt@Name)
  }
  chk <- all(colSums(chkmat) == chkmat[1, ] * Nobjs)
  if (!chk) stop("The MSE objects have different number of nyears or proyears")
  
  # Join them together
  Allobjs <- mget(paste0("obj", 1:Nobjs))
  sns <- slotNames(Allobjs[[1]])
  sns<-sns[sns!="Misc"] # ignore the Misc slot
  outlist <- vector("list", length(sns))
  for (sn in 1:length(sns)) {
    templs <- lapply(Allobjs, slot, name = sns[sn])
    if (class(templs[[1]]) == "character") {
      outlist[[sn]] <- templs[[1]]
    }
    if (class(templs[[1]]) == "numeric" | class(templs[[1]]) == "integer") {
      if (sns[sn] == "CALbins") {
        tempInd <- which.max(unlist(lapply(templs, length)))
        CALbins <- templs[[tempInd]]
      } else {
        outlist[[sn]] <- do.call(c, templs)
      }
    }
    if (class(templs[[1]]) == "matrix" | class(templs[[1]]) == "data.frame") {
      outlist[[sn]] <- do.call(rbind, templs)
    }
    if (class(templs[[1]]) == "array") {
      if (sns[sn] == "CAL") { # hack for different sized CAL arrays 
        tempVal <- lapply(templs, dim)
        if (all(unlist(lapply(tempVal, length)) == 3)) {
          nBins <- sapply(tempVal, function(x) x[3])
          nsims <- sapply(tempVal, function(x) x[1])
          nMPs <- sapply(tempVal, function(x) x[2])
          if (!mean(nBins) == max(nBins)) { # not all same size 
            Max <- max(nBins)
            index <- which(nBins < Max)
            for (kk in index) {
              dif <- Max - dim(templs[[kk]])[3]
              templs[[kk]] <- abind::abind(templs[[kk]], array(0, dim=c(nsims[kk], nMPs[kk], dif)), along=3)
            } 
          }      
          outlist[[sn]] <- abind::abind(templs, along = 1)
        } else {
          outlist[[sn]] <- templs[[1]]
        }
      } else {
        outlist[[sn]] <- abind::abind(templs, along = 1)
      }
      
    }
  }
  
  names(outlist) <- sns
  
  newMSE <- new("MSE", Name = outlist$Name, nyears = unique(outlist$nyears), 
                proyears = unique(outlist$proyears), nMP = unique(outlist$nMP), 
                MPs = unique(outlist$MPs), nsim = sum(outlist$nsim), OM = outlist$OM, 
                Obs = outlist$Obs, B_BMSY = outlist$B_BMSY, F_FMSY = outlist$F_FMSY, 
                outlist$B, outlist$SSB, outlist$VB,
                outlist$FM, outlist$C, outlist$TAC, outlist$SSB_hist, 
                outlist$CB_hist, outlist$FM_hist, outlist$Effort, outlist$PAA,
                outlist$CAA, outlist$CAL, CALbins, Misc=list())
  
  newMSE
}

# Evaluate Peformance of MPs
# --------------------------------------------------- Function examines
# how consistently an MP outperforms another.


#' How dominant is an MP?
#' 
#' The DOM function examines how consistently an MP outperforms another. For
#' example DCAC might provide higher yield than AvC on average but outperforms
#' AvC in less than half of simulations.
#' 
#' 
#' @param MSEobj An object of class 'MSE'
#' @param MPtg A character vector of management procedures for cross
#' examination
#' @return A matrix of performance comparisons length(MPtg) rows by MSE@nMPs
#' columns
#' @author A. Hordyk
#' @export DOM
DOM <- function(MSEobj, MPtg = NA) {
  if (any(is.na(MPtg))) 
    MPtg <- MSEobj@MPs
  proyears <- MSEobj@proyears
  nMP <- MSEobj@nMPs
  nsim <- MSEobj@nsim
  ind <- which(MSEobj@MPs %in% MPtg)
  MPr <- which(!(MSEobj@MPs %in% MPtg))
  yind <- max(MSEobj@proyears - 4, 1):MSEobj@proyears
  y1 <- 1:(MSEobj@proyears - 1)
  y2 <- 2:MSEobj@proyears
  Mat <- matrix(0, nrow = length(MPtg), ncol = nMP)
  rownames(Mat) <- MPtg
  colnames(Mat) <- MSEobj@MPs
  POF <- P100 <- YieldMat <- IAVmat <- Mat
  for (X in 1:length(MPtg)) {
    # Overfishing (F > FMSY)
    ind1 <- as.matrix(expand.grid(1:nsim, ind[X], 1:proyears))
    ind2 <- as.matrix(expand.grid(1:nsim, 1:nMP, 1:proyears))
    t1 <- apply(array(MSEobj@F_FMSY[ind1] > 1, dim = c(nsim, 1, proyears)), 
                c(1, 2), sum, na.rm = TRUE)
    t2 <- apply(array(MSEobj@F_FMSY[ind2] > 1, dim = c(nsim, nMP, proyears)), 
                c(1, 2), sum, na.rm = TRUE)
    POF[X, ] <- round(apply(matrix(rep(t1, nMP), nrow = nsim) < t2, 
                            2, sum)/nsim * 100, 0)
    # B < BMSY
    t1 <- apply(array(MSEobj@B_BMSY[ind1] < 1, dim = c(nsim, 1, proyears)), 
                c(1, 2), sum, na.rm = TRUE)
    t2 <- apply(array(MSEobj@B_BMSY[ind2] < 1, dim = c(nsim, nMP, proyears)), 
                c(1, 2), sum, na.rm = TRUE)
    P100[X, ] <- round(apply(matrix(rep(t1, nMP), nrow = nsim) < t2, 
                             2, sum, na.rm = TRUE)/nsim * 100, 0)
    # Relative yield in last 5 years
    ind1 <- as.matrix(expand.grid(1:nsim, ind[X], yind))
    ind2 <- as.matrix(expand.grid(1:nsim, 1:nMP, yind))
    t1 <- apply(array(MSEobj@C[ind1], dim = c(nsim, 1, length(yind))), 
                c(1, 2), sum, na.rm = TRUE)
    t2 <- apply(array(MSEobj@C[ind2], dim = c(nsim, nMP, length(yind))), 
                c(1, 2), sum, na.rm = TRUE)
    YieldMat[X, ] <- round(apply(matrix(rep(t1, nMP), nrow = nsim) > 
                                   t2, 2, sum, na.rm = TRUE)/nsim * 100, 0)
    # interannual variation in catch
    ind1 <- as.matrix(expand.grid(1:nsim, ind[X], y1))
    ind2 <- as.matrix(expand.grid(1:nsim, ind[X], y2))
    AAVY1 <- apply(array(((MSEobj@C[ind1] - MSEobj@C[ind2])^2)^0.5, 
                         dim = c(nsim, 1, length(y1))), 1, mean, na.rm = T)/apply(array(MSEobj@C[ind2], 
                                                                                        dim = c(nsim, 1, length(y1))), 1, mean, na.rm = T)
    ind1 <- as.matrix(expand.grid(1:nsim, 1:nMP, y1))
    ind2 <- as.matrix(expand.grid(1:nsim, 1:nMP, y2))
    AAVY2 <- apply(array(((MSEobj@C[ind1] - MSEobj@C[ind2])^2)^0.5, 
                         dim = c(nsim, nMP, length(y1))), c(1, 2), mean, na.rm = T)/apply(array(MSEobj@C[ind2], 
                                                                                                dim = c(nsim, nMP, length(y1))), c(1, 2), mean, na.rm = T)
    IAVmat[X, ] <- round(apply(matrix(rep(AAVY1, nMP), nrow = nsim) < 
                                 AAVY2, 2, sum, na.rm = TRUE)/nsim * 100, 0)
  }
  out <- list()
  out$POF <- POF
  out$P100 <- P100
  out$Yd <- YieldMat
  out$AAVY <- IAVmat
  return(out)
}





