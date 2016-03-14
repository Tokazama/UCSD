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
x <- diag(n) # desing matrix that represents each image as a factor
fit <- .lm.fit(x, imat)
mrss <- sqrt(fit$residuals / (n - 1)) # mean residual sum of squares

# here we create a visual for a singl subject
c <- rep(1, n)
c[82] <- -(n-1) # contrast subject image against everyone else 
                # 82 correpsonds to the the subject at row 82
                # in the `sub_ucsd` data frame
se <- t(as.matrix( mrss * c %*% XX %*% c)) # standard errors
se[se == 0] <- 1 # 0/0 produces NAs, so now all 0s are divided by 1
statmat <- (c %*% fit$coefficients) / se # create t-statistic
istat <- makeImage(mask, statmat)


# alternatively, we can loop over the entire dataset
x <- matrix(nrow = n, ncol = 2)
x[, 1] <- 1
x[,2] <- 0
new_ilist <- list()
c <- matrix(c(1, -1), nrow =1 ) # contrast
for ( i in 1:n){
  if (i > 1)
    x[i - 1, 2] <- 0
  x[i, 2] <- 1
  fit <- .lm.fit(x, imat)
  mrss <- sqrt(fit$residuals / (n - 1))
  se <- t(as.matrix( mrss * c %*% XX %*% c))
  se[se == 0] <- 1
  statmat <- (c %*% fit$coefficients) / se
  img <- makeImage(mask, statmat)
  renderSurfaceFunction
}
