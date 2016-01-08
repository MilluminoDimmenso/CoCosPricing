%%%%%%%%%%%%%%%%%%%%% Trigger Experiment %%%%%%%%%%%%%%%%%%%%
require(lattice)

AA <- SyntheticsYieldCurves

AA$CoCos.Price.F.StandStill <- AA$CoCos.Price.F.StandStill - 1.0

BB <- AA[(AA$Shift.Period == 3),]

labels <- seq(-0.5, 1.5, by=0.25)  


xyplot(CoCos.Price.F.StandStill~factor(Trigger.Level),
       data=BB,type="b",group=IR.Curve,
       auto.key=list(column=3,lines=TRUE),
       scales=list(y=list(at=labels)),
       xlab="Trigger Level",
       ylab="CoCos Price",
       panel=function(x,y,...){panel.grid(h=-1, v=-1);panel.xyplot(x,y,...);})
         


# DD <- BB[(BB$Burn.In == 0) & (BB$Shift.Period == 1) & (BB$Standstill.Percentage == 0.0),]
# YY <- ZZ[(ZZ$Burn.In == 0) & (ZZ$Shift.Period == 1) & (ZZ$Standstill.Percentage == 0.0),]
# SS <- TT[(TT$Burn.In == 0) & (TT$Shift.Period == 1) & (TT$Standstill.Percentage == 0.0),]


barchart(CoCos.Price~factor(Trigger.Level)|factor(Shift.Period),
         group=Shift.Period,data=AA,
         auto.key=list(columns=5,title="Shift Periods",points = FALSE, rectangles=TRUE, 
                       cex.title=1.0,border=FALSE,padding.text=2, adj=1),
         horizontal=FALSE,xlab="Trigger Levels", 
         ylab="Discount (in points)", origin=0,)

barchart(CoCos.Price~factor(Trigger.Level)|factor(Shift.Period),data=AA,
         horizontal=FALSE,xlab="Trigger Levels", ylab="Discount (in points)", origin=0)


barchart(CoCos.Price~factor(Trigger.Level)|factor(Burn.In),group=Shift.Period,data=AA,
         auto.key=list(columns=5,title="Shift Periods",points = FALSE, rectangles=TRUE, 
                       cex.title=1.0,border=FALSE,padding.text=2, adj=1),
         horizontal=FALSE,xlab="Trigger Levels", 
         ylab="Discount (in points)", origin=0,)

barchart(CoCos.Price~factor(Trigger.Level), data=CC,
         main = "S-CoCos with Jumps",
         horizontal=FALSE,xlab="Trigger Levels", 
         ylab="Discount (in points)", origin=0)

barchart(CoCos.Price~factor(Trigger.Level), data=DD,
         main = "S-CoCos without Jumps",
         horizontal=FALSE,xlab="Trigger Levels", 
         ylab="Discount (in points)", origin=0)

EE <- c(CC$Trigger.Level,DD$Trigger.Level,YY$Trigger.Level,SS$Trigger.Level)
FF <- c(CC$CoCos.Price.F.StandStill,DD$CoCos.Price.F.StandStill,
        YY$CoCos.Price.F.StandStill,SS$CoCos.Price.F.StandStill)
HH <- rep(c("ECB_6.5","ECB_5.5","ECB_4.5","ECB_4.0"), c(5,5,5,5))

df <- data.frame(EE,FF,HH) 

colnames(df)[1] <- "Trigger.Levels"
colnames(df)[2] <- "Prices"
colnames(df)[3] <- "Type"

at <- seq(1, 6, by=1)
labels <- seq(0.0, 1.5, by=0.25)  


barchart(Prices~factor(Trigger.Levels), data=df, group=Type,
         horizontal=FALSE,xlab="Trigger Levels", 
         key = simpleKey(c("Coupon@4.0%","Coupon@4.5%","Coupon@5.5%","Coupon@6.5%"),
                         points=FALSE, lines =FALSE, rectangles = TRUE, columns = 2),
         ylab="Prices", origin=0, 
         ylim=c(0,1.5),
         scales=list(y=list(at=labels)),
         panel = function(x, ...) {
           panel.abline( h = 1, lty = "dotted", col="black")
           panel.abline( h = 1.25, lty = "dotted", col="black")
           panel.barchart(x, ...)
           })




%%%%%%%%%%%%%%%%%%%% CoCos Triggering Time %%%%%%%%%%%%%%%%%%%%%%
require(lattice)
y.tick.number <- 5
at <- seq(1, nrow(CocosTriggeringTime), by=y.tick.number)
labels <-   levels(factor(CocosTriggeringTime$Scenario))[at]  

CoCos <- dotplot(Scenario~CocosEvent,
          data=CocosTriggeringTime,
          scales=list(x=list(cex=0.8),
                      y=list(at=at,labels=labels,cex=0.8,tck=c(1,1),
                             alternating=3)),
        col=c("red"), cex=c(0.5), pch=c(0), 
          xlab="Time",ylab="Scenarios")

print(CoCos)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Discount vs Triggers %%%%%%%%%%%%%%%%%%%
  
AA <- CoCosExperiments.FIXED.NEW
BB <- CoCosExperiments.FIXED.NEW

AA$CoCos.Price <- (1.0 - AA$CoCos.Price)*100
BB$CoCos.Price <- (1.0 - BB$CoCos.Price)*100

CC <- AA[(AA$Burn.In == 0) & (AA$Shift.Period == 3) & (AA$Standstill.Percentage == 0.0),]
DD <- BB[(BB$Burn.In == 0) & (BB$Shift.Period == 3) & (BB$Standstill.Percentage == 0.0),]

EE <- c(CC$Trigger.Level,DD$Trigger.Level)
FF <- c(CC$CoCos.Price,DD$CoCos.Price)
HH <- rep(c("Fixed","Fixed.New"), c(5,5))

df <- data.frame(EE,FF,HH) 

colnames(df)[1] <- "Trigger.Levels"
colnames(df)[2] <- "Discounts"
colnames(df)[3] <- "Type"

library(RColorBrewer)
my.colours <- brewer.pal(6,"Blues")  

my.setting <- list(superpose.polygon=list(col=c(my.colours[1],my.colours[4])),
                   strip.background=list(col=my.colours[1]),
                   strip.border=list(col="black"))

# group=Type,

barchart(Discounts~factor(Trigger.Levels), data=df,
         horizontal=FALSE,xlab="Trigger Levels", 
         auto.key=list(columns=2,points = FALSE, rectangles=TRUE, 
                       cex.title=1.0,border=FALSE,padding.text=2, adj=1),          
         ylab="Discount (in points)", 
         origin=0,
         par.settings = my.setting)

#key = simpleKey(c("Multiple","Single"),
#                points=FALSE, lines =FALSE, rectangles = TRUE, columns = 2),

%%%%%%%%%%%%%%%%%%%%%%% Discount vs Trigger group by Standstill %%%%%%%%%%%%%%%%%%%
require(lattice)

require(RColorBrewer)
  
LL <- CoCosExperiments.FIXED.NEW
LL$CoCos.Price <- (1.0 - LL$CoCos.Price)*100


my.colours <- brewer.pal(6,"Blues")  

my.setting <- list(superpose.polygon=list(col=my.colours[1:6]),
                   strip.background=list(col=my.colours[1]),
                   strip.border=list(col="black"))

# subset=Trigger.Level %in% c(300,400),

barchart(CoCos.Price~factor(Trigger.Level), data=LL, group=Shift.Period,
         horizontal=FALSE,xlab="Trigger Levels", subset=Trigger.Level %in% c(400),
         auto.key=list( size = 4,corner = c(1, 1), x = 0.3, y = 1, columns=1,
                        title="Standstill in years",points = FALSE, rectangles=TRUE, 
                       cex.title=1.0,border=FALSE, padding.text=1, between= 0.2),          
         ylab="Discount (in points)", 
         origin=0,
         par.settings = my.setting)

%%%%%%%%%%%%%%%%%%%%%%% Fixed and Stochastic Standstill mechanism %%%%%%%%%%%%%%%%%%%

require(lattice)
require(RColorBrewer)

LL <- CoCosExperiments
LL$CoCos.Price.F.StandStill <- (1.0 - LL$CoCos.Price.F.StandStill)*100
LL$CoCos.Price.S.StandStill <- (1.0 - LL$CoCos.Price.S.StandStill)*100

HH <- LL[LL$Shift.Period==1, ]
KK <- LL[LL$Shift.Period==3, ]
YY <- LL[LL$Shift.Period==5, ]


EE <- c(YY$Trigger.Level,KK$Trigger.Level,YY$Trigger.Level)
FF <- c(YY$CoCos.Price.F.StandStill,KK$CoCos.Price.F.StandStill,YY$CoCos.Price.S.StandStill)
HH <- rep(c("Fixed-5y","Fixed-3y","Stochastic"), c(5,5,5))

df <- data.frame(EE,FF,HH) 

colnames(df)[1] <- "Trigger.Levels"
colnames(df)[2] <- "Discounts"
colnames(df)[3] <- "Type"

my.colours <- brewer.pal(6,"Blues")  

my.setting <- list(superpose.polygon=list(col=my.colours[1:6]),
                   strip.background=list(col=my.colours[1]),
                   strip.border=list(col="black"))

barchart(Discounts~factor(Trigger.Levels), 
         data=df, group=Type,
         horizontal=FALSE,xlab="Trigger Levels",
         auto.key=list( size = 4,corner = c(1, 1), x = 0.9, y = 0.9, columns=3,
                        title="CoCos Mechanism",points = FALSE, rectangles=TRUE, 
                        cex.title=1.0,border=FALSE, padding.text=2, between= 0.1),          
         ylab="Discount (in points)", 
         origin=0,
         par.settings = my.setting)

write.csv(file="FixedVsStochastic.csv",df)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CDS Spread Densities %%%%%%%%%%%%%%%%%

require(RMySQL)
require(lattice)


drv <- dbDriver("MySQL")

con <- dbConnect(drv, user="ospite", password="mysql06")

rs <- dbSendQuery(con,"USE COCOS_TROUBLE_REGIME")

queryString <- "SELECT AVG(Spread) AS SpreadAverage FROM SpreadScenarios WHERE Time >= 3570 AND Time <= 3600 GROUP BY Scenario"
rs <- dbSendQuery(con, queryString )
BB <- fetch(rs, n=-1)

my.setting <- list(superpose.line=list(col=c("green","red","blue","black")))

histogram(~AverageSpreads,data=CC,
            xlab = "Final Cost",subset= Type=="QUITE",
            col=c("green"),
            lwd = 3,
            groups=Type,
            plot.points=TRUE,
            cex=0.5,
            par.settings = my.setting, 
            auto.key=list(column=1))


rs <- dbSendQuery(con,"USE COCOS_TROUBLE_REGIME")


dbDisconnect(con)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% defaultable vs cocos %%%%%%%%%%%%%%%%%%
require(lattice)

ZZ <- CocosBondPrices$Price - mean(CocosBondPrices$Price)
YY <- DefaulableBondPrices$Price - mean(DefaulableBondPrices$Price)

AA <- c(ZZ,YY)
HH <- rep(c("CoCos Bond","Defaultable Bond"), c(1000,1000))

df <- data.frame(AA,HH) 

colnames(df)[1] <- "Prices"
colnames(df)[2] <- "Type"

densityplot(~Prices,data=df,xlab="Losses",group=Type,auto.key=list(column=2),cex=0.5)

qqmath(~Prices|Type, distribution = function(p) qnorm(p, mean=mean(df$Prices), sd=sd(df$Prices)),
       data=df,xlab="Losses",auto.key=list(column=2),
       prepanel = prepanel.qqmathline,
       panel = function(x, ...) {
         panel.qqmathline(x, ...)
         panel.qqmath(x, ...) } 
)

subset= Type=="Defaultable Bond",

write.csv(file="CoCosVsDefaultable.csv",df)
