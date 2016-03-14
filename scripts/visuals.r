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
c <- rep(1, n)
c[ sub_ucsd[rownames(sub_ucsd) %in% "105"] ] <- -(n-1) # contrast subject image against everyone else
mrss <- sqrt(fit$residuals / (n - 1)) # mean residual sum of squares
se <- t(as.matrix( mrss * c %*% XX %*% c)) # standard errors
se[se == 0] <- 1 # 0/0 produces NAs, so now all 0s are divided by 1
statmat <- (c %*% fit$coefficients) / se # create t-statistic

istat <- makeImage(mask, statmat)


