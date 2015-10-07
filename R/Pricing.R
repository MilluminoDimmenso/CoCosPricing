%%%%%%%%%%%%%%%%%%%%% Trigger Experiment %%%%%%%%%%%%%%%%%%%%
require(lattice)

AA <- CoCosExperiments.JUMPS
BB <- CoCosExperiments.NOJUMPS

AA$CoCos.Price <- (1.0 - AA$CoCos.Price)*100
BB$CoCos.Price <- (1.0 - BB$CoCos.Price)*100

CC <- AA[(AA$Burn.In == 0) & (AA$Shift.Period == 3) & (AA$Standstill.Percentage == 0.0),]
DD <- BB[(BB$Burn.In == 0) & (BB$Shift.Period == 3) & (BB$Standstill.Percentage == 0.0),]

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

EE <- c(CC$Trigger.Level,DD$Trigger.Level)
FF <- c(CC$CoCos.Price,DD$CoCos.Price)
HH <- rep(c("JUMPS","NOJUMPS"), c(5,5))

df <- data.frame(EE,FF,HH) 

colnames(df)[1] <- "Trigger.Levels"
colnames(df)[2] <- "Discounts"
colnames(df)[3] <- "Type"

barchart(Discounts~factor(Trigger.Levels), data=df, group=Type,
         horizontal=FALSE,xlab="Trigger Levels", 
         key = simpleKey(c("Jumps","No Jumps"),
                         points=FALSE, lines =FALSE, rectangles = TRUE, columns = 2),
         ylab="Discount (in points)", origin=0)


%%%%%%%%%%%%%%%%%%%% CoCos Triggering Time %%%%%%%%%%%%%%%%%%%%%%

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

LL <- CoCosExperiments.FIXED.STOCH
LL$CoCos.Price.F.StandStill <- (1.0 - LL$CoCos.Price.F.StandStill)*100
LL$CoCos.Price.S.StandStill <- (1.0 - LL$CoCos.Price.S.StandStill)*100

HH <- LL[LL$Shift.Period==1, ]
KK <- LL[LL$Shift.Period==3, ]
YY <- LL[LL$Shift.Period==5, ]


EE <- c(HH$Trigger.Level,KK$Trigger.Level,YY$Trigger.Level)
FF <- c(HH$CoCos.Price.F.StandStill,KK$CoCos.Price.F.StandStill,YY$CoCos.Price.S.StandStill)
HH <- rep(c("Fized-3y","Fixed-5y","Stochastic"), c(5,5,5))

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
  