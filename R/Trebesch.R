library(lattice)
load("Trebesch.RData")
trellis.par.set(scales=list(x=list(cex=1.0),y=list(cex=1.0)), 
                superpose.symbol=list(pch=c(0,1), cex=c(0.9,0.7), col=c("blue","red")))
dotplot(Country~Numeric.Dates, group=Type, 
        data=Trebesch.Sample,  col=c("blue","red"), 
        cex=c(1.2,0.9), pch=c(0,1), auto.key=list(columns=2),xlab="")
dotplot(Country~Numeric.Dates, 
        group=Type, data=TrebeschSample.2,  
        col=c("blue","red"), cex=c(1.2,0.9), 
        pch=c(0,1), auto.key=list(columns=2),xlab="")
dotplot(Country~Numeric.Dates, group=Type, 
        data=TrebeschSample.3,  
        col=c("blue","red"), cex=c(0.9,0.7), 
        pch=c(0,1), auto.key=list(columns=2),xlab="")
dotplot(Country~Numeric.Dates, group=Type, data=Trebesch.All, 
        scales=list(x=list(cex=0.8),y=list(cex=0.5)), 
        col=c("blue","red"), cex=c(0.8,0.6), pch=c(0,1), 
        auto.key=list(columns=2),xlab="")


dotplot(factor(Scenario)~CocosEvent,
        data=CocosTriggeringTime,group=Type,
        scales=list(x=list(cex=0.8),y=list(cex=0.5)), col=c("blue","red"), cex=c(0.8,0.6), pch=c(0,1), 
        xlab="Time",ylab="Scenario")



