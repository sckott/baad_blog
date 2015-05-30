
data1 <- readRDS("baad_pre/output/baad.rds")$data
data2 <- readRDS("baad_post/output/baad.rds")$data

source("baad_pre/reports/report-fun.R")

makePlot <- function(data, subset, xvar, yvar,  ...) {

    plot(data[, xvar], data[, yvar], log = "xy", col =  make.transparent("grey",
        0.5),  las = 1, yaxt = "n", xaxt = "n", pch = 16, cex=1.5, ...)
    axis.log10(1)
    axis.log10(2)
    points(subset[, xvar], subset[, yvar], col = "red", pch = 16)
}

png("plot.png", width=1000, height=500)
par(mfcol=c(1,2), oma=c(0,2,0,0))
makePlot(data1, data1[data1$studyName=="Kitazawa1959",], "d.bh", "a.lf", 
  xlab="stem diameter (m)", ylab=expression("leaf area"~~(m^2)), 
  main="a) Initial data (with error)", xlim=10^c(-3, 2), ylim=10^c(-3, 4))
makePlot(data2, data2[data2$studyName=="Kitazawa1959",], "d.bh", "a.lf", 
  xlab="stem diameter (m)", ylab="", main="b) Cleaned data",
  xlim=10^c(-3, 2), ylim=10^c(-3, 4))
legend("bottomright", 
        legend=c("BAAD", "Kitazawa1959"),
        pch=16, bty="n",
        col=c(make.transparent("grey", 0.5), "red"))
dev.off()
