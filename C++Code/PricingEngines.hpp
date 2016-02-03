/* 
 * File:   PricingEngines.hpp
 * Author: conan
 *
 * Created on July 28, 2015, 4:48 PM
 */


// This two define statements must always be changed accordingly

#define DAYS_IN_A_YEAR 360
#define DAYS_IN_A_SEMESTER 180
#define DAYS_IN_A_QUARTER 90
#define DAYS_IN_A_MONTH 30

#ifndef PRICINGENGINES_HPP
#define	PRICINGENGINES_HPP

#include <string>

#include <mysql/mysql.h>

#include <blitz/array.h>


using namespace blitz;

class cocosPricingEngine {
public:

    // Default constructor

    inline cocosPricingEngine() {
    };

    // Default destructor

    inline ~cocosPricingEngine() {
    };

    inline int getMaxMaturityShift() {

        return maxMaturityShift;

    }

    inline double getTriggerLevel() {

        return cocosTriggerLevel;

    }

    inline double getStandStillPercentage() {

        return standStillPercentage;

    }

    inline int getGracePeriodsInYears() {

        return gracePeriodsInYears;

    }

    inline int getBurnInPeriodsInYears() {

        return burnInPeriodsInYears;

    }

    void readInputFile(string theInputString);

    void writeDataInCSVFormat(string gamsFileName, const Array<double, 2 > &dataMatrix);

    void writeDataForDotPlot(string gamsFileName, const Array<double, 2 > &dataMatrix);

    double pricingPlainVanillaCouponBond();

    double priceCocosBondFixedStanstill();

    double priceCocosBondStochasticStandstill();

    double priceDefaultableBond();

    // Database prototypes

    void queryInterestRates();

    void queryCdsSpreads();

    void loadDataFromFile(string theResultsFileName);

    double queryLookBackAverageSpread(int recordIdAtPaymentDate);

    // Least square Montecarlo prototypes

    void leastSquareRegression(int currentTime, const Array <double, 2> &theStandardLogRates, 
        Array <double, 2> &regressionBetas);

    void computeStandardizedLogRates(Array <double, 2> &theLogRates);

    void computeBasisRegressors(const Array<double, 1 > &theVariable, Array <double, 2> &theBasisRegressors);

    void computeResponceVariable(int theCurrentTime, const Array <double, 2> &theRegressionBetas,
            Array <double, 1> &theResponceVariable);

private:

    MYSQL dataBaseHandler;

    Array<double, 2> cashFlowAtPaymentDates;
    Array<double, 2> triggedSpreadLevels;
    Array<double, 2> discountFactorAtPaymentDates;
    Array<double, 2> averageLookBackSpreadAtPaymentDates;

    double parYieldRate;
    double cocosTriggerLevel;
    double defaultTriggerLevel;


    double standStillPercentage;

    string shortRateDataBaseName;
    string cdsDataBaseName;

    int numberOfBasisFunctions;

    int numberOfScenarios;

    int maxMaturityShift;

    int bondMaturity;

    int spreadLookBackDays;

    int couponFrequency;

    int numberOfBondPayments;

    int numberOfPaymentPeriods;

    int daysBetweenPaymentPeriods;

    int gracePeriodsInYears;

    int burnInPeriodsInYears;

}; // End cocosPricingEngine


#endif	/* PRICINGENGINES_HPP */

