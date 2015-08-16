library(lattice)

library(tseries)

qqmathD2 <- function ( Y, XLAB, YLAB ) { 
       	qqmath(Y, distribution = function(p) qD2 ( p ),
	xlab = XLAB, ylab = YLAB, font.lab = 2,
       	prepanel = prepanel.qqmathline,
       	panel = function(x, ...) {
          panel.qqmathline(x, ...)
          panel.qqmath(x, ...) } 
       	)
}

qD2 <- function ( P ) {

	Y <- q(D2)(P)

	return ( Y )
		
}

 D2 <- DiscreteDistribution ( supp = s, prob = b)


qqmathSU <- function ( Y, XLAB, YLAB, XSI, LAMBDA, GAMMA, DELTA ) { 
       	qqmath(Y, distribution = function(p) qSU ( p,  XSI, LAMBDA, GAMMA, DELTA ), 
	xlab = XLAB, ylab = YLAB, font.lab = 2,
       	prepanel = prepanel.qqmathline,
       	panel = function(x, ...) {
          panel.qqmathline(x, ...)
          panel.qqmath(x, ...) } 
       	)
}

qqmathSB <- function ( Y, XLAB, YLAB, XSI, LAMBDA, GAMMA, DELTA ) { 
       	qqmath(Y, distribution = function(p) qSB ( p,  XSI, LAMBDA, GAMMA, DELTA ), 
	xlab = XLAB, ylab = YLAB, font.lab = 2,
       	prepanel = prepanel.qqmathline,
       	panel = function(x, ...) {
          panel.qqmathline(x, ...)
          panel.qqmath(x, ...) } 
       	)
}

qqmathNormal <- function ( Y, XLAB, YLAB ) { 
       	qqmath(Y, distribution = function(p) qnorm(p, mean=mean(Y), sd=sd(Y)),
	xlab = XLAB, ylab = YLAB, font.lab = 2,
       	prepanel = prepanel.qqmathline,
       	panel = function(x, ...) {
          panel.qqmathline(x, ...)
          panel.qqmath(x, ...) } 
       	)
}

print(PlotOne, split= c(1,1,2,1), more=T)

print(PlotTwo, split= c(2,1,2,1))

dev.copy2eps ( file="FileName.eps" );

f.value = c(30,40,50,60,70,80)/100,	 
f.value = c(1,2.5,5,10,30,40,50,60,70,80,90,95,98.5,99)/100,	 
f.value = c(0.1,0.5,1,2.5,5,10,30,40,50,60,70,80,90,95,98.5,99,99.5,99.9)/100

qqmathLogNormal <- function ( Y, XLAB, YLAB ) { 
       	qqmath(Y, distribution = function(p) qlnorm(p, meanlog=mean(log(Y)), sdlog=sd(log(Y))),
	xlab = XLAB, ylab = YLAB, font.lab = 2,
       	prepanel = prepanel.qqmathline,
       	panel = function(x, ...) {
          panel.qqmathline(x, ...)
          panel.qqmath(x, ...) } 
       )
}

f.value = c(1,2.5,5,10,30,40,50,60,70,80,90,95,98.5,99)/100,


densityplotNormal <- function ( Y, BW, XLAB, YLAB ) {
        densityplot(Y, bw = BW, xlab = XLAB, ylab = YLAB, font.lab = 2,
             panel = function(x, ...) {
                panel.mathdensity(dmath = dnorm, col="red", 
                args = list(mean=mean(x), sd=sd(x)))
                panel.densityplot(x, ...) }
        )
}
	

densityplotLogNormal <- function ( Y, BW, XLAB, YLAB ) {
        densityplot(Y, bw = BW, xlab = XLAB, ylab = YLAB, font.lab = 2,
             panel = function(x, ...) {
                panel.mathdensity(dmath = dlnorm, col="red", 
                args = list(mean=mean(log(x)), sd=sd(log(x))))
                panel.densityplot(x, ...) }
        )
}

histogramNormal <- function ( Y, XLAB, YLAB ) { 
	histogram( Y, type = "density", xlab = XLAB, ylab = YLAB, font.lab = 2,
          panel = function(x, ...) {
              panel.histogram(x, ...)
              panel.mathdensity(dmath = dnorm, col = "red", lwd = 3,
                                args = list(mean=mean(x),sd=sd(x)))
          } )

}

histogramLogNormal <- function ( Y, XLAB, YLAB ) { 
	histogram( Y, type = "density", xlab = XLAB, ylab = YLAB, font.lab = 2,
          panel = function(x, ...) {
              panel.histogram(x, ...)
              panel.mathdensity(dmath = dlnorm, col = "red", lwd = 3,
                                args = list(mean=mean(log(x)),sd=sd(log(x))))
          } )

}


library(RMySQL)
 
drv <- dbDriver("MySQL")
 
con <- dbConnect(drv, user="ospite", password="mysql06")

rs <- dbSendQuery(con,"USE DJ_VARTA")

queryString <- "SELECT BO FROM CompoundedReturnTree where ancestor > 1"

rs <- dbSendQuery(con, queryString )

BO <- fetch(rs, n=-1)
 
a <- fetch(rs, n=-1)




dSU  <- function ( Y, gamma, delta ) {

	a <- ( delta / sqrt ( 2 * pi ) )
	
	b <- ( 1.0 / sqrt ( Y^2 + 1 ) )

	c <- Y + sqrt ( Y^2 + 1 )

	d <- exp ( -0.5 * ( gamma + delta * log( c ) )^2 )

	e <- a * b * d

	return ( e )
}


dSU  <- function ( X, xsi, lambda, gamma, delta ) {

	Y <- ( X - xsi ) / lambda

	a <- ( delta / sqrt ( 2 * pi ) )
	
	b <- ( 1.0 / sqrt ( Y^2 + 1 ) )

	c <- Y + sqrt ( Y^2 + 1 )

	d <- exp ( -0.5 * ( gamma + delta * log( c ) )^2 )

	e <- a * b * d

	return ( e )
}



qSU <- function ( P,  xsi, lambda, gamma, delta ) {

	Z <- qnorm ( P )		

	A <- (Z - gamma) / delta

	Y <- (exp ( A ) - exp ( -A )) / 2.0

	return ( xsi + lambda * Y )
		
}

rSU <- function ( N,  xsi, lambda, gamma, delta ) {

	Z <- rnorm ( N )		

	A <- (Z - gamma) / delta

	Y <- (exp ( A ) - exp ( -A )) / 2.0

	return ( xsi + lambda * Y )
		
}

rSB <- function ( N,  xsi, lambda, gamma, delta ) {

	Z <- rnorm ( N )		

	A <- (Z - gamma) / delta

	Y <- 1.0 / ( 1.0 + exp ( -A ) )

	return ( xsi + lambda * Y )
		
}


zSU <- function ( Z,  xsi, lambda, gamma, delta ) {

	A <- (Z - gamma) / delta

	Y <- (exp ( A ) - exp ( -A )) / 2.0

	return ( xsi + lambda * Y )
		
}



qSB <- function ( P,  xsi, lambda, gamma, delta ) {

	Z <- qnorm ( P )	

	A <- (Z - gamma) / delta

	Y <- 1.0 / ( 1.0 + exp ( - A ) )

	return ( xsi + lambda * Y )
}

pSB <- function ( X,  xsi, lambda, gamma, delta ) {


	Y <- ( X - xsi ) / lambda

	a <- log ( Y / ( 1 - Y ) )

	z <- ( gamma + delta * a )

	return ( pnorm ( z ) )
}

fSB <- function ( X,  xsi, lambda ) {

	Y <- ( X - xsi ) / lambda

	f <- log ( Y / ( 1 - Y ) )

	return ( f )
}

psiSU <- function ( X, xsi, lambda, gamma, delta  ) {

        Y <- ( X - xsi ) / lambda

        H <- Y + sqrt(Y^2 + 1)

        Z <- gamma + delta * log ( H )

        return ( Z )
}


gSU <- function ( Z, xsi, lambda, gamma, delta  ) {

        Y <- ( Z - gamma ) / delta

        H <- exp(Y) - exp(-Y)

        X <- (lambda/2) * H  + xsi

        return ( X )

}

pSU <- function ( X,  xsi, lambda, gamma, delta ) {


	Y <- ( X - xsi ) / lambda

	a <- log ( Y + sqrt( Y^2 + 1 ) )

	z <- ( gamma + delta * a )

	return ( pnorm ( z ) )
}




x <- seq(-2, 2, length = 100)

j <- c(dSU ( x, 0, 0.5), dSU ( x, 0, 0.8), dSU ( x, 0, 1.5), dnorm(x))

x <- rep(x,4)

which = rep(c("0.5","0.8","1.5","normal"),c(100,100,100,100))

xy1 <- xyplot(j~x,groups=which, key = simpleKey(c("gamma = 0.5","gamma = 0.8","gamma = 1.5","gaussian"), points=FALSE, lines =TRUE, x=.7,y=.7, columns = 2, transparent=T),type="l", lwd=2, panel=panel.superpose)

mypanelXY <- function(x,y) {
  panel.xyplot(x,y)
  panel.abline(v = 0, lty = 3)
  panel.abline(h = 0, lty = 3)
  panel.abline(a=c(0,1),lwd=3)
}

mypanelDensity <- function(x) {
  panel.densityplot(x)
  panel.abline(v = 0, lty = 3)
  panel.abline(h = 0, lty = 3)
}

mypanelBW <- function(x,y,...) {
  panel.bwplot(x,y,...)
  panel.abline(v = -3.71346109190276, lty = 3)
}

ss.line <- trellis.par.get("superpose.line") // To get superposed line parameters 

trellis.par.set("superpose.line", ss.line) // To change superposed line parameters

aa.text <- trellis.par.get("add.text") // To get simpleKey legend paramters

trellis.par.set("add.text", aa.text) // To change simpleKey legend paramters

plot.symbol <- trellis.par.get("plot.symbol")

EMP3m <- ecdf(S[[1]])

P3m <- JohnsonFit( S[,1], moment="find" ) 

HH <-c(EMP3m(x),pJohnson(x,P3m))

x <- rep(x,2)

which = rep(c("EMP","JOHN"), c(1000,1000))


m  <- function ( omega, kurtosis ) {

	a <-((kurtosis + 3) / (omega^2 + 2*omega +3))
	
	b <- 2 * (omega^2 - a)

	c <- -2 + sqrt(4 + b)
	
	return ( c )
}


om <- function ( delta ) {


	a = (1.0 / delta^2)

	b = exp ( a )

	return ( b )

}

EX <- function ( X, xsi, omega ) {


	beta2 <- kurtosis(X)

	mm <- m(omega,beta2)

	c <- sqrt ( omega - 1.0 - mm )

	sigma <- sd(X)

	ss <- sign(moment(X,central=TRUE,order=3))

	mean <- xsi + ss * (sigma/(omega-1)) * c

	return (mean)
}

SDX <- function ( X, lambda, omega ) {

	beta2 <- kurtosis(X)

	mm <- m(omega,beta2)

	a <- sqrt ( ((omega+1) / (2*mm)) )
	
	sd <- lambda * (omega-1) * a

	return (sd)

}

library(RMySQL)
 
drv <- dbDriver("MySQL")
 
con <- dbConnect(drv, user="ospite", password="mysql06")

rs <- dbSendQuery(con,"USE DJ_VARTA")


queryString <- "SELECT BO FROM CompoundedReturnTree where ancestor > 1"


rs <- dbSendQuery(con, queryString )


BO <- fetch(rs, n=-1)

BO <- BO -1

mean(BO)
sd(BO)
skewness(BO)
kurtosis(BO)

qqmathNormal( as.matrix(BO), "", "" )

cor(AL,BO)

densityplotNormal( as.matrix(BO), 0.08, "", "" )

densityplotLogNormal( as.matrix(BO), 0.08, "", "" )

qqmathLogNormal( as.matrix(BO), "", "" )
cor(AL,IP)


mydata <- read.csv("set.csv", header=TRUE, sep=',')
radius <- sqrt( mydata$P/ pi )
symbols(mydata$MSCI_EXEMU, mydata$JPM_GB, circles=radius, inches=0.20, fg="white", bg="red", xlab="USD_GBP", ylab="USD_JPY")

AA <- OptimalDesign[OptimalDesign$Asset.Names %in% c("RF", "BONDS_1_3"), ]
AA <- OptimalDesign[OptimalDesign$Asset.Names == "RF", ]

AA <- OptimalDesign[OptimalDesign$delta %in% c(0.70, 1.00), ]
barchart(g~Percentages|factor(alpha),group=delta,data=AA,origin=0,auto.key=TRUE)
barchart(Asset.Names~Percentages|factor(g),group=alpha==0.7,subset=delta==1.0,data=CC,origin=0,auto.key=TRUE)


%%%%%%%%%%%%% For xyplot %%%%%%%%%%%%%%%
library(lattice)
library(latticeExtra)

DD <- OptimalDesign.30.2[(OptimalDesign.30.2$Percentages > 0.0) & (OptimalDesign.30.2$delta %in% c(0.7,0.8,1)) & 
                           (OptimalDesign.30.2$alpha %in% c(0.7,0.8,1)), ]

my.setting <- list(superpose.symbol=list(pch=c(15,16,17,18), 
                                         cex=1.0, col=c("red","blue","green","black")))

OptionCost <- xyplot(Option.Cost~factor(g)|factor(delta),
                     group=alpha,data=DD,
                     auto.key=list(columns=3),
                     aspect = "xy",scales=list(alternating=FALSE,x=list(rot=90)),
                     layout = c(3, 1),
                     strip = strip.custom(style = 5))

update(OptionCost,xlab="Minimum guarantee rate (g)",
       ylab="Minimum guarantee cost",
       legend = NULL, 
       auto.key=list(columns=3,title="alpha",cex.title=1.0,border=TRUE,padding.text=3), 
       par.settings = my.setting, 
       panel=function(x,y,...){panel.grid(h=-1, v=-1);panel.xyplot(x,y,...);})

%%%%%%%%%%%%%%%%%%%%%%%% alpha effect %%%%%%%%%%%%%%%%%%

DD <- OptimalDesign.30.2[(OptimalDesign.30.2$Percentages > 0.0) & (OptimalDesign.30.2$delta %in% c(0.7,0.8,1)) & (OptimalDesign.30.2$alpha %in% c(0.7,0.8,1)), ]

my.setting <- list(superpose.symbol=list(pch=c(15,16,17,18), 
                                         cex=1.0, col=c("red","blue","green","black")),
                   superpose.line=list(col=c("red","blue","green","black")))

OptionCost <- xyplot(Option.Cost~factor(g),group=alpha,data=DD,
                     auto.key=list(columns=4),type="b",
                     scales=list(x=list(rot=90)),strip = strip.custom(style = 1))

update(OptionCost,xlab="Minimum guarantee rate (g)",
       ylab="Minimum guarantee cost",
       legend = NULL, 
       auto.key=list(columns=4,title="alpha",cex.title=1.0,border=TRUE,padding.text=3), 
       par.settings = my.setting, 
       panel=function(x,y,...){panel.grid(h=-1, v=-1);panel.xyplot(x,y,...);})

%%%%%%%%%%%%%%% delta effect %%%%%%%%%%%%%%%%%

EE <- OptimalDesign.30.2[(OptimalDesign.30.2$Percentages > 0.0) & (OptimalDesign.30.2$delta %in% c(0.7,0.9)) & (OptimalDesign.30.2$g %in% c(0.03)), ]


my.setting <- list(superpose.symbol=list(pch=c(15,16), 
                                           cex=1.0, col=c("red","blue")),
                     superpose.line=list(col=c("red","blue")))

OptionCost <- xyplot(Option.Cost~factor(alpha),group=delta,data=EE,
                     auto.key=list(columns=2),type="b",
                     scales=list(x=list(rot=90)),strip = strip.custom(style = 1))

update(OptionCost,xlab="alpha",
       ylab="Minimum guarantee cost",
       legend = NULL, 
       auto.key=list(columns=2,title="delta",cex.title=1.0,border=TRUE,padding.text=3), 
       par.settings = my.setting, 
       panel=function(x,y,...){panel.grid(h=-1, v=-1);panel.xyplot(x,y,...);})


%%%%%%%%%%%%%%%%%%%%%%%%%% alpha vs delta effect %%%%%%%%%%%%%%%%

% FF <- OptimalDesign.30.2[(OptimalDesign.30.2$Percentages > 0.0) & (OptimalDesign.30.2$alpha %in% c(0.7,1.0)) & (OptimalDesign.30.2$g %in% c(0.03)), ]

YY <- OptimalDesign.30.2.All.Delta[(OptimalDesign.30.2.All.Delta$Percentages > 0.0) & (OptimalDesign.30.2.All.Delta$alpha %in% c(0.7,1.0)) & (OptimalDesign.30.2.All.Delta$g %in% c(0.03)), ]


my.setting <- list(superpose.symbol=list(pch=c(15,16), 
                                         cex=1.0, col=c("red","blue")),
                   superpose.line=list(col=c("red","blue")))

OptionCost <- xyplot(Option.Cost~factor(delta),group=alpha,data=YY,
                     auto.key=list(columns=2),type="b",
                     scales=list(x=list(rot=90)),strip = strip.custom(style = 1))

update(OptionCost,xlab="delta",
       ylab="Minimum guarantee cost",
       legend = NULL, 
       auto.key=list(columns=2,title="alpha",cex.title=1.0,border=TRUE,padding.text=3), 
       par.settings = my.setting, 
       panel=function(x,y,...){panel.grid(h=-1, v=-1);panel.xyplot(x,y,...);})



%%%% For Barchart %%%%%%%%%%%%%%

str(simpleTheme(col=rainbow(12)))

% for multiple plot legend must be added later

my.key <- simpleKey(text = levels(droplevels(OptimalDesign$Asset.Names[2:13])),
                    columns=6,
                    rectangles=TRUE,
                    points=FALSE,
                    space="top")

my.key$rectangles$col=rainbow(12)

barchart(as.matrix(OptimalDesign.2[OptimalDesign.2$g==0.02 
                                   & OptimalDesign.2$alpha==0.7,6:17]),
         origin=0,par.settings = simpleTheme(col=rainbow(12)),
         scales=list(y=list(draw=FALSE)) )

%%%%%%%%% For Barchart %%%%%%%%%%%
  
Portfolios.0 <- barchart(Asset.Names~Percentages|factor(delta)+factor(alpha),
                         data=BB,subset=g==0.0,origin=0, 
                         xlab="Portfolio percentages", 
                         main = list(label="Minimum guarantee 0%", 
                                     cex=0.9, font=2, x=0.9, y=0), 
                         layout = c(4, 1), strip = strip.custom(style = 5),
                         scales=list(y=list(cex=0.6)))

Portfolios.2 <- barchart(Asset.Names~Percentages|factor(delta)+factor(alpha),
                         data=BB,subset=g==0.02,origin=0, 
                         xlab="Portfolio percentages", 
                         main  = list(label="Minimum guarantee 2%", cex=0.9, font=2, x=0.9, y=0), 
                         layout = c(4, 1), strip = strip.custom(style = 5),
                         scales=list(y=list(cex=0.6)))

Portfolios.4 <- barchart(Asset.Names~Percentages|factor(delta)+factor(alpha),
                         data=BB,subset=g==0.04,origin=0, 
                         xlab="Portfolio percentages", 
                         main  = list(label="Minimum guarantee 4%", cex=0.9, font=2, x=0.9, y=0), 
                         layout = c(4, 1), strip = strip.custom(style = 5),
                         scales=list(y=list(cex=0.6)))

plot(Portfolios.0, split = c(1, 1, 1, 3), more = TRUE)
plot(Portfolios.2, split = c(1, 2, 1, 3), more = TRUE)
plot(Portfolios.4, split = c(1, 3, 1, 3), more = FALSE)
%%%%%%%%%% For Box and Whisker %%%%%%%%%%%

Portfolio.Bw <- bwplot(Asset.Names~Percentages|factor(alpha), group=g,
                       data=ZZ,origin=0,
                       xlab="Portfolio percentages",
                       strip = strip.custom(style = 5),scales=list(y=list(cex=0.6)))

plot(Portfolio.Bw)

%%%%%%%%%% A complete portfolio view %%%%%%%%%%
  
CC <- OptimalDesign.30.2[(OptimalDesign.30.2$Percentages > 0.0) & 
                      (OptimalDesign.30.2$alpha %in% c(0.7,0.8,0.9)) & 
                      (OptimalDesign.30.2$delta %in% c(0.9)), ]

Portfolios.All.2 <- barchart(Asset.Names~Percentages|factor(g)+factor(alpha),
                           data=CC,origin=0, xlab="Portfolio percentages",                             
                           strip = strip.custom(style = 5),scales=list(y=list(cex=0.7)),
                           par.strip.text=list(cex=0.7))

plot(Portfolios.All.2)


%%%%%%%%%%%%%%%%% Pattern portfolios %%%%%%%%%%%
library(RColorBrewer)
my.colours <- brewer.pal(6,"Greens")  

my.setting <- list(superpose.polygon=list(col=my.colours[3:6]),
                   strip.background=list(col=my.colours[1]),
                   strip.border=list(col="black"))
  
ZZ <- OptimalDesign.30.2[(OptimalDesign.30.2$Percentages > 0.005) & 
                             (OptimalDesign.30.2$alpha %in% c(0.7,0.9)) & 
                             (OptimalDesign.30.2$delta %in% c(0.9)) &
                             (OptimalDesign.30.2$g %in% c(0.0, 0.01, 0.03, 0.05)), ]

Portfolios.ZZ <- barchart(Asset.Names~Percentages|factor(alpha),group = g,
                             data=ZZ,origin=0, xlab="Portfolio percentages",                             
                             strip = strip.custom(style = 5),
                             scales=list(alternating = FALSE, y=list(cex=0.7)),
                             auto.key=list(columns=4,title="g",points = FALSE, rectangles=TRUE, 
                                           cex.title=1.0,border=FALSE,padding.text=2, adj=1), 
                             par.settings = my.setting, 
                             par.strip.text=list(cex=1),
                             panel=function(x,y,...){panel.grid(h=-1, v=-1);panel.barchart(x,y,...);})

plot(Portfolios.ZZ)

% my.setting <- list(superpose.polygon=list(col=c("blue","red", "cyan", "green")))


%%%%%%%%%%%%%%%% Simulation AL %%%%%%%%%%%%%%%%%%%%

my.setting <- list(superpose.symbol=list(pch=c(15,16),
                                         cex=1.0, col=c("red","blue")),
                     superpose.line=list(col=c("red","blue")))

  
xyplot(Asset+Liability~Year|Type,data=Simulation,type="b",
       scales=list(relation="free"),
       xlab="Years",
       ylab="Value of the asset and liability account",
       auto.key=list(columns=2,border=TRUE,padding.text=3,points=T,lines=T),
       panel=function(x,y,...){panel.grid(h=-1, v=-1);panel.xyplot(x,y,...);})


%%%%%%%%%%%%%%%%%%%% Returns %%%%%%%%%%%%%%%%
  
AA <- Simulation[(Simulation$Year > 1992), ]

AA <- droplevels(AA)

my.setting <- list(superpose.symbol=list(pch=15,
                                         cex=1.0, col="green"),
                   superpose.line=list(col="green"))

xyplot(Returns~Year|Type,data=AA,type="b",
       scales=list(relation="same"),
       xlab="Years",
       ylab="Yearly returns (%)",
       panel=function(x,y,...){panel.grid(h=-1, v=-1);
                               panel.xyplot(x,y,...);
                               panel.abline(h=3,col.line="red")})

%%%%%%%%%%%%%%%%%%%%% Compute the Mahalanobis distance %%%%%%%%%%%%%%%%%

mu <- as.matrix(as.numeric(MOM[1,]))

mu <- mu-0.01

stdev <- as.matrix(as.numeric(MOM[2,]))

A <- matrix(0, nrow(stdev), nrow(stdev))

diag(A) <- stdev

C <- as.matrix(CORR)

COV <- A %*% C %*% A

Mahalabonis <- t(mu) %*% solve(COV) %*% mu

Mahalabonis

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

write.table(format(COV, scientific=TRUE),
            file="~/Desktop/Shared/Data/COV.txt",
            row.names=FALSE,col.names=FALSE,sep="\t",quote=FALSE)

%%%%%%%%%%%%%%%%%%%%% CDS Spread Model %%%%%%%%%%%%%%%%%%%%%%

my.setting <- list(superpose.symbol=list(pch=c(15,16,17),
                                         cex=1.0, col=c("red","blue", "green")),
                   superpose.line=list(col=c("red","blue","green")))

FittedValues$NewDate <- format(as.Date(FittedValues$Date), format="%d/%m/%y")

x.tick.number <- 50
at <- seq(1, nrow(FittedValues), by=x.tick.number)
labels <- FittedValues$NewDate[at]

xyplot(Jumps~time(NewDate),data=FittedValues,type="l",
       xlab="Years",scales=list(x=list(at=at, labels=labels, rot=45)),
       auto.key=list(columns=2,border=TRUE,padding.text=3,lines=T))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% qq() %%%%%%%%%%%%%%%%%%%%%%%%
require(lattice)

ff = c(0.01,0.1,1,2.5,5,10,30,40,50,60,70,80,90,95,98.5,99,99.9,99.99)/100

v.gr <- make.groups ( TIS$V2, AA )

qq(which~data,v.gr)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Spread %%%%%%%%%%%%%%%%%%%%%%
require(lattice)
require(latticeExtra)
require(RColorBrewer)

IST <- SimulatedSpreads[1:400,1:ncol(SimulatedSpreads)]

True <- Partition.2

AA <- array(c(nrow(IST),1))
BB <- array(c(nrow(IST),1))
CC <- array(c(nrow(IST),1))
DD <- array(c(nrow(IST),1))
EE <- array(c(nrow(IST),1))
HH <- array(c(nrow(IST),1))


for (i in 1:nrow(IST)){
  
  AA[i] <- mean(as.numeric(IST[i,2:ncol(IST)]))
  BB[i] <- quantile(as.numeric(IST[i,2:ncol(IST)]),0.05)
  CC[i] <- quantile(as.numeric(IST[i,2:ncol(IST)]),0.95)
  HH[i] <- sd(as.numeric(IST[i,2:ncol(IST)]))
  DD[i] <- AA[i] + HH[i]
  EE[i] <- AA[i] - HH[i]
  
}

df <- data.frame(IST$V1,AA,BB,CC,DD,EE,IST$V30,IST$V300,IST$V500)

df2 <- data.frame(True$V1,True$V2)

my.colours <- brewer.pal(8,"Spectral")  

my.setting <- list(superpose.line=list(col=c(my.colours[1:2],
                                             my.colours[6],"black",my.colours[7:8]),
                                       lwd=c(1,1,1,3,2,2)))

a <- xyplot(AA+BB+CC+IST.V30+IST.V300~IST.V1,data=df,type="l")

b <- xyplot(True.V2~True.V1,data=df2,type="l",col="black",lwd=3)

b + as.layer(a)


xyplot(AverageMinus1SD+AveragePlus1SD+Average+True.Series+PercentileAt5pc+PercentileAt95pc~Time,data=Simulation,type="l",
       scales=list(relation="free"),
       par.settings = my.setting,
       xlab="Days",
       ylab="Spread",
       auto.key=list(columns=3,border=TRUE,padding.text=3,
                     text=c("Average - 1SD","Average + 1SD","Average","True Series", "Percentile @ 5%", "Percentile @ 95%"),
                     lines=T,points=F),
       panel=function(x,y,...){panel.grid(h=-1, v=-1);panel.xyplot(x,y,...);})

my.setting <- list(superpose.line=list(col=c("black",my.colours[1:2],my.colours[6:8]),
                                       lwd=c(3,2,2,1,1,1)))

xyplot(True.Series+PercentileAt5pc+PercentileAt95pc+Scenario_1+Scenario_2+Scenario_3~Time,data=Simulation,type="l",
       scales=list(relation="free"),
       par.settings = my.setting,
       xlab="Days",
       ylab="Spread",
       auto.key=list(columns=3,border=TRUE,padding.text=3,
                     text=c("True Series", "Percentile @ 5%", "Percentile @ 95%", "Scenario 1","Scenario 2","Scenario 3"),
                     lines=T,points=F),
       panel=function(x,y,...){panel.grid(h=-1, v=-1);panel.xyplot(x,y,...);})


densityplotLogNormal <- function (Y, BW, XLAB, YLAB) {
  densityplot(Y, bw = BW, xlab = XLAB, ylab = YLAB, font.lab = 2,
              panel = function(x, ...) {
                panel.mathdensity(dmath = dlnorm, col="red", 
                                  args = list(mean=mean(log(x)), sd=sd(log(x))))
                panel.densityplot(x, ...) }
  )
}


GG <- IST[1000,3:100]


GG <- GG[GG < 500]



densityplotLogNormal(GG,100,"","")

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Error Bars %%%%%%%%%%%%%%%%%%%%%
require(Hmisc)

AA <- xYplot(Cbind(MSE,Lower,Upper) ~ mu, data=MSE,type="b",
             scales=list(y=list(limits=c(0.0375,0.0525)) ),
             panel=function(x,y,...){panel.xYplot(x,y,...);
                                     panel.abline(h=0.04254508,col.line="red",lwd=1,lty=3)})

AA$x.scales$tick.number <- 20
print(AA)


%%%%%%%%%%%%%%%%%%%%%%%% Poisson %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

lambda <- 0.05

T <- 545

N <- rpois(1,lambda*T)

U <- array(N,1)

JumpTimes <-array(N,1)

for (i in 1:N) {
  
  U[i] = runif(1,0,1)

} 

JumpTimes <- round(T * sort(U))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
require(RMySQL)
require(lattice)

drv <- dbDriver("MySQL")

con <- dbConnect(drv, user="ospite", password="mysql06")

rs <- dbSendQuery(con,"USE COCOS")

queryString <- "SELECT MAX(Scenario) FROM SpreadScenarios WHERE Time=1"
rs <- dbSendQuery(con, queryString )
numberOfScenarios <- fetch(rs, n=-1)
numberOfScenarios <- as.numeric(numberOfScenarios)

queryString <- "SELECT MAX(Time) FROM SpreadScenarios WHERE Scenario=1"
rs <- dbSendQuery(con, queryString )
numberOfPeriods <- fetch(rs, n=-1)
numberOfPeriods <- as.numeric(numberOfPeriods)

QQ99 <- array(c(numberOfPeriods,1))
QQ95 <- array(c(numberOfPeriods,1))
QQ5 <- array(c(numberOfPeriods,1))

# for (i in 1:numberOfPeriods){
#   
#   queryString <- sprintf("SELECT Spread FROM SpreadScenarios WHERE Time= %i", i )
#   rs <- dbSendQuery(con, queryString )
#   ZZ <- fetch(rs, n=-1)
#   ZZ <- as.numeric(ZZ$Spread)
#   
#   QQ95[i] = as.numeric(quantile(ZZ,0.95))
#   QQ5[i] = as.numeric(quantile(ZZ,0.05)) 
#   print (i)
#   
# }
#

queryString <- "SELECT AVG(Spread) AS AVG FROM SpreadScenarios GROUP BY Time"
rs <- dbSendQuery(con, queryString )
AA <- fetch(rs, n=-1)

queryString <- "SELECT Time FROM SpreadScenarios WHERE Scenario=1"
rs <- dbSendQuery(con, queryString )
TT <- fetch(rs, n=-1)

queryString <- "SELECT Spread FROM SpreadScenarios WHERE Scenario=250"
rs <- dbSendQuery(con, queryString )
BB <- fetch(rs, n=-1)

queryString <- "SELECT Spread FROM SpreadScenarios WHERE Scenario=816"
rs <- dbSendQuery(con, queryString )
CC <- fetch(rs, n=-1)

queryString <- "SELECT MAX(Spread) AS MAX FROM SpreadScenarios GROUP BY Time"
rs <- dbSendQuery(con, queryString )
DD <- fetch(rs, n=-1)


queryString <- "SET group_concat_max_len = 10485760"
rs <- dbSendQuery(con, queryString )


EndHorizon <- 7500

queryString <- "SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(GROUP_CONCAT(Spread ORDER BY Spread SEPARATOR ','),',',(0.05 * COUNT(*) + 1)),',',-1) AS 'Q05' FROM SpreadScenarios GROUP BY Time"
rs <- dbSendQuery(con, queryString )
SS <- fetch(rs, n=-1)
Q05 <- as.numeric(SS$Q05[1:EndHorizon])

queryString <- "SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(GROUP_CONCAT(Spread ORDER BY Spread SEPARATOR ','),',',(0.95 * COUNT(*) + 1)),',',-1) AS 'Q95' FROM SpreadScenarios GROUP BY Time"
rs <- dbSendQuery(con, queryString )
SS <- fetch(rs, n=-1)
Q95 <- as.numeric(SS$Q95[1:EndHorizon])

queryString <- "SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(GROUP_CONCAT(Spread ORDER BY Spread SEPARATOR ','),',',(0.99 * COUNT(*) + 1)),',',-1) AS 'Q99' FROM SpreadScenarios GROUP BY Time"
rs <- dbSendQuery(con, queryString )
SS <- fetch(rs, n=-1)
Q99 <- as.numeric(SS$Q99[1:EndHorizon])


df <- data.frame(AA$AVG[1:EndHorizon],TT$Time[1:EndHorizon],BB$Spread[1:EndHorizon],CC$Spread[1:EndHorizon],Q95,Q05,DD$MAX[1:EndHorizon],Q99) 

colnames(df)[1] <- "AVG"
colnames(df)[2] <- "Time"
colnames(df)[3] <- "BB"
colnames(df)[4] <- "CC"
colnames(df)[5] <- "Q95"
colnames(df)[6] <- "Q05"
colnames(df)[7] <- "MAX"
colnames(df)[8] <- "Q99"


xyplot(AVG+BB+CC~Time,type="l",data=df)

# xyplot(AVG~Time,type="l",data=df)
# 
# xyplot(MAX~Time,type="l",data=df)

xyplot(AVG+Q95+MAX~Time,type="l",data=df)

xyplot(AVG+Q95~Time,type="l",data=df)

xyplot(Q99+Q95+MAX~Time,type="l",data=df)

xyplot(BB+AVG~Time,type="l",data=df)

xyplot(AVG~Time,type="l",data=df)


queryString <- "SELECT * FROM SpreadScenarios WHERE Spread > 500"
rs <- dbSendQuery(con, queryString )
YY <- fetch(rs, n=-1)

dbDisconnect(con)


queryString <- "SELECT Scenario,Spread FROM SpreadScenarios WHERE Time=1721"

rs <- dbSendQuery(con, queryString )

MM <- fetch(rs, n=-1)

which.max(MM$Spread)

%%%%%%%%%%%%%%%%%%%%% Term Structure %%%%%%%%%%%%%%%%%%

require(lattice)

SimulatedTermStructure[2:6] <- - (1.0/SimulatedTermStructure$Time) * log(SimulatedTermStructure[2:6])

xyplot(AVG~Time,type="l",data=SimulatedTermStructure)


xyplot(AVG+C1+C2~Time,type="l",data=DD)
xyplot(AVG+C1+C2+C3~Time,type="l",data=DD)
xyplot(AVG+C1+C2+C3+C4~Time,type="l",data=DD)

%%%%%%%%%%%%%%%%%%%%% Trigger Experiment %%%%%%%%%%%%%%%%%%%%

require(lattice)

barchart(CoCos.Price~factor(Trigger.Level),group=Shift.Period,data=AA,
         auto.key=list(columns=5,title="Shift Periods",points = FALSE, rectangles=TRUE, 
                       cex.title=1.0,border=FALSE,padding.text=2, adj=1),
         horizontal=FALSE,xlab="Trigger Levels", 
         ylab="Discount (in points)", origin=0,)

barchart(CoCos.Price~factor(Trigger.Level)|factor(Shift.Period),data=AA,
         horizontal=FALSE,xlab="Trigger Levels", ylab="Discount (in points)", origin=0)