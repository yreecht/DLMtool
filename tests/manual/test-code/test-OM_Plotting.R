testthat::context("Test OM Plotting functions")
dev.new()  
# DLMextra(TRUE)
# library(DLMextra)
library(testthat)
rm(list=ls())
# setup()

testthat::test_that("plotStock works with all available Stock objects", {
   rm(list=ls())
  objs <- avail('Stock')
  
  for (i in seq_along(objs)) {
    # graphics.off()
    obj <- get(objs[i])
    seed <- ceiling(runif(1, 1, 1000))
    set.seed(seed)
    info <- paste(objs[i], seed)
    testthat::expect_error(plot(obj), NA, info=info)
    # expect_warning(plot(obj), NA, info=objs[i])
    # graphics.off()
  }
})

testthat::test_that("plotFleet works with all available Fleet objects", {
   rm(list=ls())
  objs <- avail('Fleet')
 
  for (i in seq_along(objs)) {
    # graphics.off()
    obj <- get(objs[i])
    seed <- ceiling(runif(1, 1, 1000))
    set.seed(seed)
	  stock <- sample(avail("Stock"),1)
    info <- paste(objs[i], stock, seed)
    testthat::expect_error(plotFleet(obj, get(stock)), NA, info=info)
    # expect_warning(plotFleet(obj, get(stock)), NA, info=info)
    # graphics.off()
  }
})

testthat::test_that("plotImp works with all available Imp objects", {
  rm(list=ls()) 
  objs <- avail('Imp')
  
  for (i in seq_along(objs)) {
    # graphics.off()
    obj <- get(objs[i])
    seed <- ceiling(runif(1, 1, 1000))
    set.seed(seed)
    info <- paste(objs[i], seed)
    testthat::expect_error(plot(obj), NA, info=info)
    # expect_warning(plot(obj), NA, info=objs[i])
    # graphics.off()
  }
})

testthat::test_that("plotObs works with all available Obs objects", {
  rm(list=ls())
  objs <- avail('Obs')
  
  for (i in seq_along(objs)) {
    # graphics.off()
    obj <- get(objs[i])
    seed <- ceiling(runif(1, 1, 1000))
    set.seed(seed)
    info <- paste(objs[i], seed)
    testthat::expect_error(plot(obj), NA, info=info)
    # expect_warning(plot(obj), NA, info=objs[i])
    # graphics.off()
  }
})


DLMextra(TRUE)
library(DLMextra)

testthat::test_that("plotOM works with all OMs", {
  rm(list=ls())
  objs <- avail('OM')
  for (i in seq_along(objs)) {
    # graphics.off()
    obj <- get(objs[i])
    obj@nsim <- 48
    seed <- ceiling(runif(1, 1, 1000))
    obj@seed <- seed
    info <- paste(objs[i], seed)
    testthat::expect_error(plot(obj, silent=TRUE), NA, info=info)
    # expect_warning(plot(obj), NA, info=objs[i])
    # graphics.off()
  }
})

if(!is.null(dev.list()))  dev.off()


