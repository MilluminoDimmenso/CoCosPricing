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


    MYSQL_RES *queryResult;

    MYSQL_ROW currentDataBaseRow;

    ostringstream commandLine;


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

        } else if (dataRead == "BOND_MATURITY") {

            inputFileStream >> bondMaturity;

            cout << "Bond maturity: " << bondMaturity << endl;

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

        } else if (dataRead == "DEFAULT_TRIGGER_LEVEL") {

            inputFileStream >> defaultTriggerLevel;

            cout << "Default trigger level : " << defaultTriggerLevel << endl;

        } else if (dataRead == "GRACE_PERIODS_IN_YEARS") {

            inputFileStream >> gracePeriodsInYears;

            cout << "Grace period (in years) : " << gracePeriodsInYears << endl;

        } else if (dataRead == "BURN_IN_PERIODS_IN_YEARS") {

            inputFileStream >> burnInPeriodsInYears;

            cout << "Burn-in periods (in years) : " << burnInPeriodsInYears << endl;

        } else if (dataRead == "STANDSTILL_PERCENTAGE") {

            inputFileStream >> standStillPercentage;

            cout << "Percentage of nominal paid during standstill : " << standStillPercentage << endl;

        } else if (dataRead == "COUPON_FREQUENCY") {

            inputFileStream >> couponFrequency;

            cout << "Coupon frequency: " << couponFrequency << endl;

            switch (couponFrequency) {

                case 1:
                    daysBetweenPaymentPeriods = DAYS_IN_A_YEAR;
                    break;
                case 2:
                    daysBetweenPaymentPeriods = DAYS_IN_A_SEMESTER;
                    break;
                case 4:
                    daysBetweenPaymentPeriods = DAYS_IN_A_QUARTER;
                    break;
                case 12:
                    daysBetweenPaymentPeriods = DAYS_IN_A_MONTH;
                    break;
                default:
                    cout << "Frequency not defined" << endl;
                    exit(0);
                    break;
            };

            numberOfBondPayments = int ( (bondMaturity * DAYS_IN_A_YEAR) / daysBetweenPaymentPeriods);

            cout << "Number of bond payments: " << numberOfBondPayments << endl;

        }

    } // End for ( ; ; )

    inputFileStream.close();

    // Open database connection

    mysql_init(&dataBaseHandler);


    if (!mysql_real_connect(&dataBaseHandler, "localhost", "ospite", "mysql06", NULL, 0, NULL, CLIENT_LOCAL_FILES)) {

        cout << "Failed to connect to mysql server " << endl;

        exit(0);

    }

    //
    // The numberOfPaymentPeriods is greater or equal to
    // the numberOfBondPayments. This is necessary to allow that
    // the scheduled payments of the bond is shifted forward in case
    // the COCOS is triggered.
    //

    commandLine.seekp(0, ios::beg);

    commandLine << "SELECT COUNT(RecordId) FROM " << shortRateDataBaseName
            << ".SpreadScenarios WHERE Scenario = 1;" << ends;


    if (mysql_query(&dataBaseHandler, commandLine.str().c_str())) {

        cout << mysql_error(&dataBaseHandler) << endl;

        exit(0);

    }

    queryResult = mysql_use_result(&dataBaseHandler);

    currentDataBaseRow = mysql_fetch_row(queryResult);

    numberOfPaymentPeriods = int ( (atoi(*(currentDataBaseRow))) / daysBetweenPaymentPeriods);

    numberOfPaymentPeriods -= (burnInPeriodsInYears * couponFrequency);

    if (numberOfPaymentPeriods <= numberOfBondPayments) {

        cout << "Error!\nThe numberOfPaymentPeriods must be greater than numberOfBondPayments\n";

        exit(0);
    }


    mysql_free_result(queryResult);


    discountFactorAtPaymentDates.resize(numberOfScenarios, numberOfPaymentPeriods);

    discountFactorAtPaymentDates = -100.0;

    averageLookBackSpreadAtPaymentDates.resize(numberOfScenarios, numberOfPaymentPeriods);

    averageLookBackSpreadAtPaymentDates = -100.0;

    cashFlowAtPaymentDates.resize(numberOfScenarios, numberOfPaymentPeriods);

    cashFlowAtPaymentDates = 0.0;

} // End readInputFile

void cocosPricingEngine::queryInterestRates() {

    MYSQL_RES *queryResult;

    MYSQL_ROW currentDataBaseRow;

    ostringstream commandLine;

    double sumOfRates;

    double recordIdUpper, recordIdLower;

    int numberOfRows;

    int burnInCounter;

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

        burnInCounter = (burnInPeriodsInYears * DAYS_IN_A_YEAR);

        while ((currentDataBaseRow = mysql_fetch_row(queryResult))) {

            if (burnInCounter > 0) {

                burnInCounter--;

                continue;

            }


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

    Array<double, 2> ZZ(5, numberOfPaymentPeriods);

    firstIndex H;
    secondIndex G;

    ZZ(0, Range::all()) = mean(discountFactorAtPaymentDates(G, H), G);
    ZZ(1, Range::all()) = discountFactorAtPaymentDates(22, Range::all());
    ZZ(2, Range::all()) = discountFactorAtPaymentDates(2, Range::all());
    ZZ(3, Range::all()) = discountFactorAtPaymentDates(13, Range::all());
    ZZ(4, Range::all()) = discountFactorAtPaymentDates(14, Range::all());

    this->writeDataInCSVFormat("/tmp/SimulatedTermStructure.csv", ZZ);

    sumOfRates = 0.0;

    for (i = 0; i < numberOfBondPayments; i++) {

        sumOfRates += ZZ(0, i);

    }

    parYieldRate = 2.0 * ((1.0 - ZZ(0, numberOfBondPayments - 1)) / sumOfRates);

    // TO BE DELETED

    // parYieldRate = 0.0650269;

    // parYieldRate = 0.055;

    // parYieldRate = 0.045;

    // parYieldRate = 0.0664466;

    // TO BE DELETED

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

    int burnInCounter;

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

    recordIdAtPaymentDates.resize(numberOfBondPayments);
    greaterThanThreshold.resize(numberOfScenarios);

    mysql_free_result(queryResult);

    recordIdLower = 1;

    recordIdUpper = numberOfRows;

    for (i = 0; i < numberOfScenarios; i++) {

        cout.flush() << "Processing cds scenario " << i + 1 << " of " << numberOfScenarios << "\r";

        commandLine.seekp(0, ios::beg);

        commandLine << "SELECT RecordId FROM " << cdsDataBaseName
                << ".SpreadScenarios WHERE RecordId >= " << recordIdLower << " AND RecordId <= "
                << recordIdUpper << " AND Time MOD " << daysBetweenPaymentPeriods << " = 0;" << ends;


        if (mysql_query(&dataBaseHandler, commandLine.str().c_str())) {

            cout << mysql_error(&dataBaseHandler) << endl;

            exit(0);

        }

        queryResult = mysql_use_result(&dataBaseHandler);

        j = 0;

        recordIdAtPaymentDates = -1;

        burnInCounter = (burnInPeriodsInYears * couponFrequency);

        while ((currentDataBaseRow = mysql_fetch_row(queryResult))) {

            if (burnInCounter > 0) {

                burnInCounter--;

                continue;

            }

            recordIdAtPaymentDates(j) = atof(*(currentDataBaseRow));

            j++;

            if (j == numberOfBondPayments) break;

        } // End while ( .... )

        recordIdLower = recordIdUpper + 1;

        recordIdUpper += numberOfRows;

        mysql_free_result(queryResult);

        k = 0;

        for (j = 0; j < numberOfBondPayments; j++) {

            averageLookBackSpreadAtPaymentDates(i, j) = this->queryLookBackAverageSpread(recordIdAtPaymentDates(j));

            if (averageLookBackSpreadAtPaymentDates(i, j) >= cocosTriggerLevel) k++;
        }

        greaterThanThreshold(i) = k;

    } // End for ( i = 0; i < numberOfScenarios; i ++ )

    cout << "\n";

    this->writeDataForDotPlot("/tmp/CocosTriggeringTime.csv", averageLookBackSpreadAtPaymentDates);

} // End queryCdsSpreads

double cocosPricingEngine::priceCocosBondFixedStanstill() {


    ofstream outputFileStream;

    double bondPrice;
    double scenarioBondPrice;

    int cocosGracePeriodCounter;
    int standStillOnFlag;

    int maturityShift;

    int i, j;


    outputFileStream.open("/tmp/CocosBondPrices.csv");

    if (!outputFileStream) {

        cout << "Couldn't open file /tmp/CocosBondPrices.csv\n";
        exit(0);

    }

    outputFileStream << "Scenario,Price\n";

    bondPrice = 0.0;

    for (i = 0; i < numberOfScenarios; i++) {

        standStillOnFlag = 0;

        scenarioBondPrice = 0.0;

        maturityShift = 0;

        cocosGracePeriodCounter = 0;

        for (j = 0; j < numberOfBondPayments; j++) {

            if (averageLookBackSpreadAtPaymentDates(i, j) >= cocosTriggerLevel) {

                if (!standStillOnFlag) {

                    cocosGracePeriodCounter = gracePeriodsInYears * couponFrequency;

                    standStillOnFlag = 1;

                    if (j >= (numberOfBondPayments - (gracePeriodsInYears * couponFrequency))) {

                        //
                        // If we breach the threshold (gracePeriodsInYears * couponFrequency)-periods
                        // before maturity, we shift the principal payment of the number of periods
                        // between (gracePeriodsInYears * couponFrequency) and (numberOfBondPayments - j).
                        // Basically, if we breach the threshold in a window of periods which is smaller
                        // than the number of periods before maturity, we postpone the
                        // principal payment by a number of periods which is equal to this window.
                        //

                        maturityShift = (gracePeriodsInYears * couponFrequency) - (numberOfBondPayments - j) + 1;

                    }

                } // End if (!standStillOnFlag)

            } // End if (averageLookBackSpreadAtPaymentDates(i, j) >= cocosTriggerLevel)

            if (cocosGracePeriodCounter > 0) {

                cocosGracePeriodCounter--;

                cashFlowAtPaymentDates(i, j) = 0.0;

            } else {

                scenarioBondPrice += ((parYieldRate / 2.0) * discountFactorAtPaymentDates(i, j));

                cashFlowAtPaymentDates(i, j) = (parYieldRate / 2.0);

                standStillOnFlag = 0;
            }

        } // for (j = 0; j < numberOfBondPayments; j++)

        if (!maturityShift) {

            //
            // In case maturityShift = 0, the final payment due is the principal plus the coupon: 1+c
            //

            cashFlowAtPaymentDates(i, (numberOfBondPayments + maturityShift) - 1) = 1.0 + (parYieldRate / 2.0);

        } else {

            //
            // In case maturityShift <> 0, the only payment due is the principal
            //
            
            cashFlowAtPaymentDates(i, (numberOfBondPayments + maturityShift) - 1) = 1.0;

        }

        scenarioBondPrice += (discountFactorAtPaymentDates(i, (numberOfBondPayments + maturityShift) - 1));

        outputFileStream << i + 1 << "," << scenarioBondPrice << endl;

        bondPrice += scenarioBondPrice;

    } // for (i = 0; i < numberOfScenarios; i++)


    bondPrice /= numberOfScenarios;

    this->writeDataInCSVFormat("/tmp/CashFlows.csv", cashFlowAtPaymentDates);

    outputFileStream.close();

    return ( bondPrice);

} // priceCocosBondFixedStanstill() ( )

double cocosPricingEngine::priceCocosBondStochasticStandstill() {


    double bondPrice;
    double scenarioBondPrice;

    int cocosGracePeriodCounter;

    int maturityShift;

    int i, j;

    bondPrice = 0.0;

    for (i = 0; i < numberOfScenarios; i++) {

        scenarioBondPrice = 0.0;

        maturityShift = 0;

        cocosGracePeriodCounter = 0;

        for (j = 0; j < numberOfBondPayments; j++) {

            if (averageLookBackSpreadAtPaymentDates(i, j) >= cocosTriggerLevel) {

                cocosGracePeriodCounter = 1;

                if (j == (numberOfBondPayments - 1)) {

                    //
                    // If we breach the threshold at maturity, we forgive the interest payment
                    // and we delay by one period the principal payment.
                    //

                    maturityShift = 1;

                }

            } // End if (averageLookBackSpreadAtPaymentDates(i, j) >= cocosTriggerLevel)

            if (cocosGracePeriodCounter > 0) {

                cocosGracePeriodCounter--;

            } else {

                scenarioBondPrice += ((parYieldRate / 2.0) * discountFactorAtPaymentDates(i, j));
            }

        } // for (j = 0; j < (numberOfBondPayments + maturityShift); j++)

        scenarioBondPrice += (discountFactorAtPaymentDates(i, (numberOfBondPayments + maturityShift) - 1));

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

        for (j = 0; j < numberOfBondPayments; j++) {

            scenarioBondPrice += ((parYieldRate / 2.0) * discountFactorAtPaymentDates(i, j));

        } // for (j = 0; j < numberOfBondPayments; j++)

        scenarioBondPrice += (discountFactorAtPaymentDates(i, numberOfBondPayments - 1));


        bondPrice += scenarioBondPrice;

    } // for (i = 0; i < numberOfScenarios; i++)


    bondPrice /= numberOfScenarios;


    return ( bondPrice);

} // pricingPlainVanillaCouponBond ( )

double cocosPricingEngine::priceDefaultableBond() {


    //
    // We are basically assuming that the interest rate process is the
    // risk free rate.
    //

    ofstream outputFileStream;

    double bondPrice;
    double scenarioBondPrice;

    int flagDefault;

    int i, j;


    outputFileStream.open("/tmp/DefaulableBondPrices.csv");

    if (!outputFileStream) {

        cout << "Couldn't open file /tmp/DefaulableBondPrices.csv\n";
        exit(0);

    }


    outputFileStream << "Scenario,Price\n";

    bondPrice = 0.0;

    for (i = 0; i < numberOfScenarios; i++) {

        scenarioBondPrice = 0.0;

        flagDefault = 0;

        for (j = 0; j < numberOfBondPayments; j++) {

            if (averageLookBackSpreadAtPaymentDates(i, j) >= defaultTriggerLevel) {

                // If a default event occurs, pays 50% of principal and exit

                scenarioBondPrice += 0.5 * discountFactorAtPaymentDates(i, j);

                flagDefault = 1;

                break;

            } // End if (averageLookBackSpreadAtPaymentDates(i, j) >= cocosTriggerLevel)

            scenarioBondPrice += ((parYieldRate / 2.0) * discountFactorAtPaymentDates(i, j));

        } // for (j = 0; j < (numberOfBondPayments + maturityShift); j++)

        if (!flagDefault) {

            scenarioBondPrice += (discountFactorAtPaymentDates(i, (numberOfBondPayments) - 1));

        }

        outputFileStream << i + 1 << "," << scenarioBondPrice << endl;

        bondPrice += scenarioBondPrice;

    } // for (i = 0; i < numberOfScenarios; i++)

    bondPrice /= numberOfScenarios;

    outputFileStream.close();

    return ( bondPrice);

} // priceDefaultableBond() ( )

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


                if (timeIndex >= (bondMaturity - gracePeriodsInYears)) {

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

