rootdir <-"/Users/zach8769/

table <-paste(datadir,"Desktop/data/ucsd.csv",sep="")
ucsd <-read.csv(table)
subs<-ucsd[,1]
paths<-paste(rootdir,"Desktop/ucsd/",subs,"/t1/atlas/jlf.nii.gz",sep="")
ilist<-imageFileNames2ImageList(paths)
labels <-read.csv('Desktop/data/labels.csv')
nlab <-nrow(labels)
nsub <-length(ilist)
volumes <-matrix(nrow=nsub, ncol=nlab)
colnames(volumes) <-labels[,2]
for (i in 1:nsub){
  atlas <-ilist[[i]]
  labstat <-labelStats(atlas,atlas)
  imgstats <-merge(labstat, labels, by=1)
  volumes[i,] <-t(imgstats[,7])
  }
volumes <-cbind(subs, volumes)
ucsd <-merge(ucsd, volumes, by=1)
newtable <-paste(rootdir, "Desktop/data/newucsd.csv",sep="")
write.csv(ucsd, file=newtable)
