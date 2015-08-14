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


    void readInputFile(string theInputString);

    void writeDataInCSVFormat(string gamsFileName, const Array<double, 2 > &dataMatrix);
    
    void writeDataForDotPlot(string gamsFileName, const Array<double, 2 > &dataMatrix);
    
    double pricingPlainVanillaCouponBond();
    
    double pricingCocosBond();
    
    // Database prototypes

    void queryInterestRates();
    
    void queryCdsSpreads();
    
    void loadDataFromFile(string theResultsFileName);

    double queryLookBackAverageSpread ( int recordIdAtPaymentDate );
    
    
private:

    MYSQL dataBaseHandler;

    Array<double, 2> discountFactorAtPaymentDates;
    Array<double, 2> averageLookBackSpreadAtPaymentDates;
    
    double parYieldRate;
    double cocosTriggerLevel;
    
    string shortRateDataBaseName;
    string cdsDataBaseName;

    int numberOfScenarios;

    int bondMaturity;

    int spreadLookBackDays;

    int couponFrequency;

    int numberOfBondPayments;

    int numberOfPaymentPeriods;
    
    int daysBetweenPaymentPeriods;
    
    int gracePeriodsInYears;
    

}; // End cocosPricingEngine


#endif	/* PRICINGENGINES_HPP */

