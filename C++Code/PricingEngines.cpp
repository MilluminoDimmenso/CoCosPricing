/* 
 * File:   PricingEngines.cpp
 * Author: conan
 * 
 * Created on July 28, 2015, 4:48 PM
 */

#include <cstdlib>
#include <cmath>
#include <iostream>
#include <fstream>
#include <string>
#include <sstream>

#include "PricingEngines.hpp"

// Blitz headers for array management

#include <blitz/array.h>
#include <blitz/range.h>

using namespace std;
using namespace blitz;

void cocosPricingEngine::readInputFile(string theInputString) {


    ifstream inputFileStream;

    string dataRead;


    int i;

    inputFileStream.open(theInputString.c_str());

    if (!inputFileStream) {

        cout << "Couldn't open file" << theInputString.c_str() << endl;

        exit(EXIT_FAILURE);

    }

    for (;;) {

        inputFileStream >> dataRead;

        if (dataRead == "END_DATA") break;

        if (dataRead == "NUMBER_OF_SCENARIOS") {

            inputFileStream >> numberOfScenarios;

            cout << "Number of scenarios: " << numberOfScenarios << endl;

        } else if (dataRead == "NUMBER_OF_YEARS") {

            inputFileStream >> numberOfYears;

            cout << "Number of years: " << numberOfYears << endl;

        } else if (dataRead == "SHORT_RATE_DATABASE_NAME") {

            inputFileStream >> shortRateDataBaseName;

            cout << "Short rate database name: " << shortRateDataBaseName << endl;

        } else if (dataRead == "CDS_DATABASE_NAME") {

            inputFileStream >> cdsDataBaseName;

            cout << "CDS database name: " << cdsDataBaseName << endl;

        } else if (dataRead == "SPREAD_LOOK_BACK_DAYS") {

            inputFileStream >> spreadLookBackDays;

            cout << "Spread look back days: " << spreadLookBackDays << endl;

        } else if (dataRead == "COCOS_TRIGGER_LEVEL") {

            inputFileStream >> cocosTriggerLevel;

            cout << "Cocos trigger level: " << cocosTriggerLevel << endl;

        } else if (dataRead == "GRACE_PERIODS_IN_YEARS") {

            inputFileStream >> gracePeriodsInYears;

            cout << "Grace period (in years) : " << gracePeriodsInYears << endl;

        } else if (dataRead == "COUPON_FREQUENCY") {

            inputFileStream >> couponFrequency;

            cout << "Coupon frequency: " << couponFrequency << endl;

            switch (couponFrequency) {

                case 1:
                    daysInAPaymentPeriods = DAYS_IN_A_YEAR;
                    break;
                case 2:
                    daysInAPaymentPeriods = DAYS_IN_A_SEMESTER;
                    break;
                case 4:
                    daysInAPaymentPeriods = DAYS_IN_A_QUARTER;
                    break;
                case 12:
                    daysInAPaymentPeriods = DAYS_IN_A_MONTH;
                    break;
                default:
                    cout << "Frequency not defined" << endl;
                    exit(0);
                    break;
            };

            numberOfCouponPayments = int ( (numberOfYears * DAYS_IN_A_YEAR) / daysInAPaymentPeriods);

            cout << "Number of coupon payments: " << numberOfCouponPayments << endl;

        }

    } // End for ( ; ; )

    discountFactorAtPaymentDates.resize(numberOfScenarios, numberOfCouponPayments);

    averageLookBackSpreadAtPaymentDates.resize(numberOfScenarios, numberOfCouponPayments);


    averageLookBackSpreadAtPaymentDates = -1.0;

    discountFactorAtPaymentDates = -1.0;

    inputFileStream.close();

    // Open database connection

    mysql_init(&dataBaseHandler);


    if (!mysql_real_connect(&dataBaseHandler, "localhost", "ospite", "mysql06", NULL, 0, NULL, CLIENT_LOCAL_FILES)) {

        cout << "Failed to connect to mysql server " << endl;

        exit(0);

    }



} // End readInputFile

void cocosPricingEngine::queryInterestRates() {

    MYSQL_RES *queryResult;

    MYSQL_ROW currentDataBaseRow;

    ostringstream commandLine;

    double sumOfRates;

    double recordIdUpper, recordIdLower;

    int numberOfRows;

    int i, j, k;


    commandLine.seekp(0, ios::beg);

    commandLine << "SELECT COUNT(RecordId) FROM " << shortRateDataBaseName
            << ".SpreadScenarios WHERE Scenario = 1;" << ends;


    if (mysql_query(&dataBaseHandler, commandLine.str().c_str())) {

        cout << mysql_error(&dataBaseHandler) << endl;

        exit(0);

    }

    queryResult = mysql_use_result(&dataBaseHandler);

    currentDataBaseRow = mysql_fetch_row(queryResult);

    numberOfRows = atoi(*(currentDataBaseRow));

    mysql_free_result(queryResult);

    recordIdLower = 1;

    recordIdUpper = numberOfRows;

    for (i = 0; i < numberOfScenarios; i++) {

        cout.flush() << "Processing interest rate scenario " << i + 1 << " of " << numberOfScenarios << "\r";

        commandLine.seekp(0, ios::beg);

        commandLine << "SELECT Spread FROM " << shortRateDataBaseName
                << ".SpreadScenarios WHERE RecordId >= " << recordIdLower << " AND RecordId <= " << recordIdUpper << ";" << ends;


        if (mysql_query(&dataBaseHandler, commandLine.str().c_str())) {

            cout << mysql_error(&dataBaseHandler) << endl;

            exit(0);

        }


        queryResult = mysql_use_result(&dataBaseHandler);

        j = 1;

        k = 0;

        sumOfRates = 0.0;

        while ((currentDataBaseRow = mysql_fetch_row(queryResult))) {

            sumOfRates += (atof(*(currentDataBaseRow)) / (100 * DAYS_IN_A_YEAR));

            if (!(j % DAYS_IN_A_SEMESTER)) {

                discountFactorAtPaymentDates(i, k) = exp(-sumOfRates);

                k++;
            }

            j++;

        } // End while ( .... )

        recordIdLower = recordIdUpper + 1;

        recordIdUpper += numberOfRows;

        mysql_free_result(queryResult);

    } // End for ( i = 0; i < numberOfScenarios; i ++ )


    cout << "\n";

    Array<double, 2> ZZ(5, numberOfCouponPayments);

    firstIndex H;
    secondIndex G;

    ZZ(0, Range::all()) = mean(discountFactorAtPaymentDates(G, H), G);
    ZZ(1, Range::all()) = discountFactorAtPaymentDates(22, Range::all());
    ZZ(2, Range::all()) = discountFactorAtPaymentDates(2, Range::all());
    ZZ(3, Range::all()) = discountFactorAtPaymentDates(13, Range::all());
    ZZ(4, Range::all()) = discountFactorAtPaymentDates(14, Range::all());

    this->writeDataInCSVFormat("/tmp/SimulatedTermStructure.csv", ZZ);

    sumOfRates = 0.0;

    for (i = 0; i < numberOfCouponPayments; i++) {

        sumOfRates += ZZ(0, i);

    }

    parYieldRate = 2.0 * ((1.0 - ZZ(0, numberOfCouponPayments - 1)) / sumOfRates);

    cout << "Par yield rate: " << parYieldRate << endl;

} // End queryInterestRates

void cocosPricingEngine::queryCdsSpreads() {

    MYSQL_RES *queryResult;

    MYSQL_ROW currentDataBaseRow;

    Array <double, 1> recordIdAtPaymentDates;

    Array <double, 1> greaterThanThreshold;

    ostringstream commandLine;

    double recordIdUpper, recordIdLower;

    int numberOfRows;

    int i, j, k;


    commandLine.seekp(0, ios::beg);

    commandLine << "SELECT COUNT(RecordId) FROM " << cdsDataBaseName
            << ".SpreadScenarios WHERE Scenario = 1;" << ends;


    if (mysql_query(&dataBaseHandler, commandLine.str().c_str())) {

        cout << mysql_error(&dataBaseHandler) << endl;

        exit(0);

    }

    queryResult = mysql_use_result(&dataBaseHandler);

    currentDataBaseRow = mysql_fetch_row(queryResult);

    numberOfRows = atoi(*(currentDataBaseRow));

    recordIdAtPaymentDates.resize(numberOfCouponPayments);
    greaterThanThreshold.resize(numberOfScenarios);

    mysql_free_result(queryResult);

    recordIdLower = 1;

    recordIdUpper = numberOfRows;

    for (i = 0; i < numberOfScenarios; i++) {

        cout.flush() << "Processing cds scenario " << i + 1 << " of " << numberOfScenarios << "\r";

        commandLine.seekp(0, ios::beg);

        commandLine << "SELECT RecordId FROM " << cdsDataBaseName
                << ".SpreadScenarios WHERE RecordId >= " << recordIdLower << " AND RecordId <= "
                << recordIdUpper << " AND Time MOD " << daysInAPaymentPeriods << " = 0;" << ends;


        if (mysql_query(&dataBaseHandler, commandLine.str().c_str())) {

            cout << mysql_error(&dataBaseHandler) << endl;

            exit(0);

        }

        queryResult = mysql_use_result(&dataBaseHandler);

        j = 0;

        recordIdAtPaymentDates = -1;


        while ((currentDataBaseRow = mysql_fetch_row(queryResult))) {

            recordIdAtPaymentDates(j) = atof(*(currentDataBaseRow));

            j++;

            if (j == numberOfCouponPayments) break;

        } // End while ( .... )

        recordIdLower = recordIdUpper + 1;

        recordIdUpper += numberOfRows;

        mysql_free_result(queryResult);

        k = 0;

        for (j = 0; j < numberOfCouponPayments; j++) {

            averageLookBackSpreadAtPaymentDates(i, j) = this->queryLookBackAverageSpread(recordIdAtPaymentDates(j));

            if (averageLookBackSpreadAtPaymentDates(i, j) >= cocosTriggerLevel) k++;
        }

        greaterThanThreshold(i) = k;

    } // End for ( i = 0; i < numberOfScenarios; i ++ )

    cout << "\n";

    cout << "Cocos trigger dates:\n";

    cout.flush() << greaterThanThreshold << endl;

    this->writeDataForDotPlot("/tmp/CocosTriggeringTime.csv", averageLookBackSpreadAtPaymentDates);

} // End queryInterestRates

double cocosPricingEngine::pricingCocosBond() {


    double bondPrice;
    double scenarioBondPrice;

    int flagCocosTriggered;

    int i, j;

    bondPrice = 0.0;

    for (i = 0; i < numberOfScenarios; i++) {

        scenarioBondPrice = 0.0;

        for (j = 0; j < numberOfCouponPayments; j++) {


            if (averageLookBackSpreadAtPaymentDates(i, j) >= cocosTriggerLevel) {

                flagCocosTriggered = 6;

            }


            if (flagCocosTriggered > 0) {

                flagCocosTriggered--;

            } else {

                scenarioBondPrice += ((parYieldRate / 2.0) * discountFactorAtPaymentDates(i, j));

            }

        } // for (j = 0; j < numberOfCouponPayments; j++)

        if (flagCocosTriggered <= 0) {

            scenarioBondPrice += (discountFactorAtPaymentDates(i, numberOfCouponPayments - 1));

        }

        bondPrice += scenarioBondPrice;

    } // for (i = 0; i < numberOfScenarios; i++)


    bondPrice /= numberOfScenarios;


    return ( bondPrice);

} // pricingPlainVanillaCouponBond ( )

double cocosPricingEngine::pricingPlainVanillaCouponBond() {


    double bondPrice;
    double scenarioBondPrice;

    int i, j;

    bondPrice = 0.0;

    for (i = 0; i < numberOfScenarios; i++) {

        scenarioBondPrice = 0.0;

        for (j = 0; j < numberOfCouponPayments; j++) {

            scenarioBondPrice += ((parYieldRate / 2.0) * discountFactorAtPaymentDates(i, j));

        } // for (j = 0; j < numberOfCouponPayments; j++)

        scenarioBondPrice += (discountFactorAtPaymentDates(i, numberOfCouponPayments - 1));


        bondPrice += scenarioBondPrice;

    } // for (i = 0; i < numberOfScenarios; i++)


    bondPrice /= numberOfScenarios;


    return ( bondPrice);

} // pricingPlainVanillaCouponBond ( )

double cocosPricingEngine::queryLookBackAverageSpread(int recordIdAtPaymentDate) {


    MYSQL_RES *queryResult;

    MYSQL_ROW currentDataBaseRow;

    ostringstream commandLine;

    double averageSpread;

    commandLine.seekp(0, ios::beg);


    commandLine << "SELECT AVG(Spread) FROM " << cdsDataBaseName
            << ".SpreadScenarios WHERE RecordId >= " << (recordIdAtPaymentDate - spreadLookBackDays) << " AND RecordId <= "
            << recordIdAtPaymentDate << ";" << ends;


    if (mysql_query(&dataBaseHandler, commandLine.str().c_str())) {

        cout.flush() << mysql_error(&dataBaseHandler) << endl;

        exit(0);

    }

    queryResult = mysql_use_result(&dataBaseHandler);

    currentDataBaseRow = mysql_fetch_row(queryResult);

    averageSpread = atof(*(currentDataBaseRow));

    mysql_free_result(queryResult);

    return ( averageSpread);

} // End queryLookBackAverageSpread ( )

void cocosPricingEngine::loadDataFromFile(string theResultsFileName) {


    ostringstream commandLine;

    commandLine.seekp(0, ios::beg);

    commandLine << "LOAD DATA INFILE '/tmp/"
            << theResultsFileName
            << "' INTO TABLE " << cdsDataBaseName << ".CrossValidationResults"
            << " FIELDS TERMINATED BY ',' LINES TERMINATED BY '\\n' IGNORE 1 LINES;" << ends;


    if (mysql_query(&dataBaseHandler, commandLine.str().c_str())) {

        cout << mysql_error(&dataBaseHandler) << endl;

        exit(0);

    }

} // End loadDataFromFile ( )

void cocosPricingEngine::writeDataInCSVFormat(string gamsFileName, const Array<double, 2 > &dataMatrix) {

    ofstream outputFileStream;

    double timeIndex = 0.5;

    int i, j;



    outputFileStream.open(gamsFileName.c_str());

    if (!outputFileStream) {

        cout << "Couldn't open file " << gamsFileName << endl;
        exit(0);

    }

    for (i = 0; i < dataMatrix.columns(); i++) {

        outputFileStream << timeIndex << ",";

        for (j = 0; j < dataMatrix.rows(); j++) {

            outputFileStream << dataMatrix(j, i);

            if (j == (dataMatrix.rows() - 1)) {

                outputFileStream << endl;

            } else {

                outputFileStream << ",";

            }

        } // End  for (i = 0; i < dataMatrix.rows(); i++)

        timeIndex += 0.5;

    } // End  for (j = 0; j < dataMatrix.columns(); j++)

    outputFileStream.close();

} // End  writeDataInCSVFormat  ( )

void cocosPricingEngine::writeDataForDotPlot(string gamsFileName, const Array<double, 2 > &dataMatrix) {

    ofstream outputFileStream;

    double timeIndex;

    int i, j;



    outputFileStream.open(gamsFileName.c_str());

    if (!outputFileStream) {

        cout << "Couldn't open file " << gamsFileName << endl;
        exit(0);

    }

    outputFileStream << "Scenario,CocosEvent,Type\n";
    
    for (i = 0; i < dataMatrix.rows(); i++) {

        timeIndex = 0.5;

        for (j = 0; j < dataMatrix.columns(); j++) {

            if (dataMatrix(i, j) >= cocosTriggerLevel) {

                
                if ( timeIndex >= (numberOfYears - gracePeriodsInYears) ) {
                    
                    outputFileStream << (i + 1) << "," << timeIndex << ",2" << endl;
                    
                } else {
                
                        outputFileStream << (i + 1) << "," << timeIndex << ",1" << endl;
                
                }                
                                
            }

            timeIndex += 0.5;

        }// End for (j = 0; j < dataMatrix.columns(); j++)

    } // End  for (i = 0; i < dataMatrix.rows(); i++)

    outputFileStream.close();

} // End  writeDataInCSVFormat  ( )

