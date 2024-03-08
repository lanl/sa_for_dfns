# Code to grab several PDFs from Justin's lqd_correction_fpca.R code
## Step 1: run that code up until the first group of plots

## Step 2: run these :)
par(mfrow=c(3,1))
i = 1
plot(x_full_std, train_list[[i]]$fD, type="l", col="black",
     yaxt="n", ylab="", xaxt="n", xlab="", ylim=c(0,10), xlim=c(0,0.5))
i = 2
plot(x_full_std, train_list[[i]]$fD, type="l", col="black",
     yaxt="n", ylab="", xaxt="n", xlab="", ylim=c(0,10), xlim=c(0,0.5))
i = 3
plot(x_full_std, train_list[[i]]$fD, type="l", col="black",
     yaxt="n", ylab="", xaxt="n", xlab="", ylim=c(0,10), xlim=c(0,0.5))
