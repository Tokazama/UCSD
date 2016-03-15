root <- "/Users/zach8769/Desktop/"

# load data frame
ucsd <- read.csv(paste(root, "ucsd/data/ucsd.csv", sep = ""), header = TRUE)

# subset data frame so that when I omit missing values it only omits subjects missing scans
sub_ucsd <- ucsd[, 1:5]
sub_ucsd <- na.omit(sub_ucsd)

# create list of subject paths to images
paths <- paste(root, "ucsd/", sub_ucsd$folder, "/t1/warp/brainWarp.nii.gz", sep = "")

# convert paths to image list
ilist <- imageFileNames2ImageList(paths)

# get a mask from an image (all images will produce the same mask because preprocessing involved masking them
mask <-getMask(ilist[[1]])

# conver image list to image matrix
imat <- imageListToMatrix(ilist, mask)

# we now need to normalize each image by fitting it to an ANOVA model
n <- nrow(imat) # number of subjects


# here we create a visual for a singl subject
x <- matrix(nrow = n, ncol = 2)
x[, 1] <- 1
x[,2] <- 0
x[81, 2] <- 1 # contrast subject image against everyone else 
                # 81 correpsonds to the the subject at row 81
                # in the `sub_ucsd` data frame
fit <- .lm.fit(x, imat)
mrss <- sqrt(colSums(fit$residuals) / (n - 1)) # mean residual sum of squares
c <- matrix(c(1, -1), nrow =1 ) # contrast

  qr <-z[c("qr", "qraux", "pivot", "tol", "rank")]
  qr <-structure(qr, class = "qr")
  XX <-chol2inv(qr.R(qr))

se <- t(as.matrix( mrss * (c[1,] %*% XX %*% c[1,]))) # standard errors
se[se == 0] <- 1 # 0/0 produces NAs, so now all 0s are divided by 1
statmat <- (c %*% fit$coefficients) / se # create t-statistic
istat <- makeImage(mask, statmat)
antsImageWrite(istat, file = paste(dirname(paths[81]), "/scaled.nii.gz", sep = ""))

# alternatively, we can loop over the entire dataset
x <- matrix(nrow = n, ncol = 2)
x[, 1] <- 1
x[, 2] <- 0
new_ilist <- list()
c <- matrix(c(1, -1), nrow =1 ) # contrast

progress <- txtProgressBar(min = 0, max = n, style = 3)
for ( i in 1:n){
  if (i > 1)
    x[i - 1, 2] <- 0
  x[i, 2] <- 1
  fit <- .lm.fit(x, imat)
  mrss <- sqrt(fit$residuals / (n - 1))
  se <- t(as.matrix( mrss * c[1,] %*% XX %*% c[1,]))
  se[se == 0] <- 1
  statmat <- (c %*% fit$coefficients) / se
  istat <- makeImage(mask, statmat)
  antsImageWrite(istat, file = paste(dirname(paths[i]), "/scaled.nii.gz", sep = ""))
  setTxtProgressBar(progress, i)
}
close(progress)
