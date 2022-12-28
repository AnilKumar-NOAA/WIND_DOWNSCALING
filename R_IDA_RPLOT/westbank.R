library(ggplot2)
library(zoo)
getwd()

setwd("/Users/anilkumar/IDA_RPLOT")

wind.df3 = read.csv(file="westbank_6min.csv")
attach(wind.df3)
head(wind.df3)
tail(wind.df3)

par(mfrow=c(2,2))
OBS_WSPD[OBS_WSPD == 9999] <- NA
OBS_PSFC[OBS_PSFC == 9999] <- NA
OBS_WDIR[OBS_WDIR == 9999] <- NA
OBS_GUST[OBS_GUST == 9999] <- NA
OBS_GUST[OBS_GUST == 5139.49] <- NA
OBS_WSPD[OBS_WSPD == 5139.49] <- NA
plot(OBS_WSPD,  type='o', col="black", ylim=c(0,60), xaxt="n",ann=FALSE, cex.axis=1.5, cex=1.5)

lines(HWRFLES_WSPD, type="o", pch=23, lty=2, col="red")


# Create a title with a red, bold/italic font
title(main="West Bank 1, LA \n Station - 8762482", col.main="black", cex=4)
#title("Eagle Point , TX \n Station 8771013", cex.main = 1.5, col.main= "black")

# Label the x and y axes with dark green text
title(xlab="(UTC/Date) Aug 2021", col.lab=rgb(0,0,0), cex.lab=1.5)
title(ylab="Wind Speed (mph)", col.lab=rgb(0,0,0), cex.lab=1.5)

# Create a legend at (1, g_range[2]) that is slightly smaller 
# (cex) and uses the same line colors and points used by 
# the actual plots 
legend(1, 50, c("OBS","HWRF-LES"), cex=0.90, 
       col=c("black","red"), pch=21:22, lty=1:2);
labels1 = c("06/29","12/29","18/29","00/30","06/30")

axis(1, at=seq(1,241,60), labels=labels1,lwd=2, cex.axis=1.5, cex=1.5)

# PLOT WIND GUST

plot(OBS_GUST,  type='o', col="black", ylim=c(0,60), xaxt="n",ann=FALSE, cex.axis=1.5, cex=1.5)

lines(HWRFLES_GUST, type="o", pch=23, lty=2, col="red")

# Create a title with a red, bold/italic font
title(main="West Bank 1, LA \n Station - 8762482", col.main="black", cex=4)
#title("Eagle Point , TX \n Station 8771013", cex.main = 1.5, col.main= "black")

# Label the x and y axes with dark green text
title(xlab="(UTC/Date) Aug 2021", col.lab=rgb(0,0,0), cex.lab=1.5)
title(ylab="Wind Gust (mph)", col.lab=rgb(0,0,0), cex.lab=1.5)

# Create a legend at (1, g_range[2]) that is slightly smaller 
# (cex) and uses the same line colors and points used by 
# the actual plots 
legend(1, 100, c("OBS","HWRF-LES"), cex=0.90, 
       col=c("black","red"), pch=21:22, lty=1:2);
labels1 = c("06/29","12/29","18/29","00/30","06/30")

axis(1, at=seq(1,241,60), labels=labels1,lwd=2, cex.axis=1.5, cex=1.5)


plot(OBS_PSFC,  type='o', col="black", ylim=c(940,1020), xaxt="n",ann=FALSE, cex.axis=1.5, cex=1.5)


lines(HWRFLES_PSFC, type="o", pch=23, lty=2, col="red")

title(main="West Bank 1, LA \n Station - 8762482", col.main="black", cex=4)
title(xlab="(UTC/Date) Aug 2021", col.lab=rgb(0,0,0), cex.lab=1.5)
title(ylab="Sfc Press (mb)", col.lab=rgb(0,0,0), cex.lab=1.5)
legend(1, 960, c("OBS","HWRF-LES"), cex=0.90, 
       col=c("black","red"), pch=21:22, lty=1:2);
labels1 = c("06/29","12/29","18/29","00/30","06/30")

axis(1, at=seq(1,241,60), labels=labels1,lwd=2, cex.axis=1.5, cex=1.5)

plot(OBS_WDIR,  type='o', col="black", ylim=c(0,240), xaxt="n",ann=FALSE, cex.axis=1.5, cex=1.5)
box()

lines(HWRFLES_WDIR, type="o", pch=22, lty=2, col="red")

title(main="West Bank 1, LA \n Station - 8762482", col.main="black", cex=4)
title(xlab="(UTC/Date) Aug 2021", col.lab=rgb(0,0,0), cex.lab=1.5)

title(ylab="Wind Dir (deg)", col.lab=rgb(0,0,0), cex.lab=1.5)

# Create a legend at (1, g_range[2]) that is slightly smaller 
# (cex) and uses the same line colors and points used by 
# the actual plots 
legend(400, 100, c("OBS","HWRF-LES-HighRES"), cex=0.40, 
       col=c("black","red"), pch=21:22, lty=1:2);
labels1 = c("06/29","12/29","18/29","00/30","06/30")

axis(1, at=seq(1,241,60), labels=labels1,lwd=2, cex.axis=1.5, cex=1.5)