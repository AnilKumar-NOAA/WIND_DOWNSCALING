library(ggplot2)
library(zoo)
getwd()

setwd("/EXTRAFILES/2021YEAR/ISELLE_ANALYSIS")


wind.df4 = read.csv(file="hilo_hi_6min.csv")
attach(wind.df4)
head(wind.df4)
tail(wind.df4)

par(mfrow=c(2,2))
OBS_WSPD[OBS_WSPD == 9999] <- NA
OBS_PSFC[OBS_PSFC == 9999] <- NA
OBS_WDIR[OBS_WDIR == 9999] <- NA
OBS_GUST[OBS_GUST == 9999] <- NA
plot(OBS_WSPD,  type='o', col="black", ylim=c(0,25), xaxt="n",ann=FALSE, cex.axis=1.5, cex=1.5)
box()
lines(HWRFLES_WSPD, type="o", pch=23, lty=2, col="red")
lines(DFLES_WSPD, type="o", pch=23, lty=2, col="blue")

# Create a title with a red, bold/italic font
title(main="Hilo, HI \n Station - 1617760", col.main="black", cex=4)
#title("Eagle Point , TX \n Station 8771013", cex.main = 1.5, col.main= "black")

# Label the x and y axes with dark green text
title(xlab="(UTC/Date) Aug 2014", col.lab=rgb(0,0,0), cex.lab=1.5)
title(ylab="Surf Wind Speed (mph)", col.lab=rgb(0,0,0), cex.lab=1.5)
OBS_GUST
# Create a legend at (1, g_range[2]) that is slightly smaller 
# (cex) and uses the same line colors and points used by 
# the actual plots 
legend(1, 25, c("OBS","HWRF-LES-HighRES","HWRF-LES-Default"), cex=0.90, 
       col=c("black","red"), pch=21:22, lty=1:2);
labels1 = c("00/07","12/07","00/08","12/08","00/09")

axis(1, at=seq(1,501,120), labels=labels1,lwd=2, cex.axis=1.5, cex=1.5)

# PLOT WIND GUST

plot(OBS_GUST,  type='o', col="black", ylim=c(0,25), xaxt="n",ann=FALSE, cex.axis=1.5, cex=1.5)
box()
lines(HWRFLES_GUST, type="o", pch=23, lty=2, col="red")
lines(DFLES_GUST, type="o", pch=23, lty=2, col="blue")

# Create a title with a red, bold/italic font
title(main="Hilo, HI \n Station - 1617760", col.main="black", cex=4)
#title("Eagle Point , TX \n Station 8771013", cex.main = 1.5, col.main= "black")

# Label the x and y axes with dark green text
title(xlab="(UTC/Date) Aug 2014", col.lab=rgb(0,0,0), cex.lab=1.5)
title(ylab="Wind Gust (mph)", col.lab=rgb(0,0,0), cex.lab=1.5)

# Create a legend at (1, g_range[2]) that is slightly smaller 
# (cex) and uses the same line colors and points used by 
# the actual plots 
legend(1, 25, c("OBS","HWRF-LES-HighRES","HWRF-LES-Default"), cex=0.90, 
       col=c("black","red"), pch=21:22, lty=1:2);
labels1 = c("00/07","12/07","00/08","12/08","00/09")

axis(1, at=seq(1,501,120), labels=labels1,lwd=2, cex.axis=1.5, cex=1.5)




plot(OBS_PSFC,  type='o', col="black", ylim=c(1000,1020), xaxt="n",ann=FALSE, cex.axis=1.5, cex=1.5)

box()
lines(HWRFLES_PSFC, type="o", pch=23, lty=2, col="red")
lines(DFLES_PSFC, type="o", pch=23, lty=2, col="blue")

title(main="Hilo, HI \n Station - 1617760", col.main="black", cex=4)
title(xlab="(UTC/Date) Aug 2014", col.lab=rgb(0,0,0), cex.lab=1.5)
title(ylab="Sfc Press (mb)", col.lab=rgb(0,0,0), cex.lab=1.5)
legend(1, 1000, c("OBS","HWRF-LES-HighRES","HWRF-LES-Default"), cex=0.90, 
       col=c("black","red"), pch=21:22, lty=1:2);
labels1 = c("00/07","12/07","00/08","12/08","00/09")

axis(1, at=seq(1,501,120), labels=labels1,lwd=2, cex.axis=1.5, cex=1.5)

plot(OBS_WDIR,  type='o', col="black", ylim=c(0,360), xaxt="n",ann=FALSE, cex.axis=1.5, cex=1.5)
box()

lines(HWRFLES_WDIR, type="o", pch=22, lty=2, col="red")
lines(DFLES_WDIR, type="o", pch=22, lty=2, col="blue")
title(main="Hilo, HI \n Station - 1617760", col.main="black", cex=4)
title(xlab="(UTC/Date) Aug 2014", col.lab=rgb(0,0,0), cex.lab=1.5)

title(ylab="Wind Dir (deg)", col.lab=rgb(0,0,0), cex.lab=1.5)

# Create a legend at (1, g_range[2]) that is slightly smaller 
# (cex) and uses the same line colors and points used by 
# the actual plots 
legend(400, 100, c("OBS","HWRF-LES-HighRES","HWRF-LES-Default"), cex=0.90, 
       col=c("black","red"), pch=21:22, lty=1:2);
labels1 = c("00/07","12/07","00/08","12/08","00/09")

axis(1, at=seq(1,501,120), labels=labels1,lwd=2, cex.axis=1.5, cex=1.5)


