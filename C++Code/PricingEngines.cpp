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

            numberOfCouponPayments = int ( ( numberOfYears *  DAYS_IN_A_YEAR ) / daysInAPaymentPeriods );
            
            cout << "Number of coupon payments: " << numberOfCouponPayments << endl;
            
        }

    } // End for ( ; ; )

    inputFileStream.close();

    // Open database connection

    mysql_init(&dataBaseHandler);


    if (!mysql_real_connect(&dataBaseHandler, "localhost", "ospite", "mysql06", NULL, 0, NULL, CLIENT_LOCAL_FILES)) {

        cout << "Failed to connect to mysql server " << endl;

        exit(0);

    }

    
 
} // End readInputFile


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