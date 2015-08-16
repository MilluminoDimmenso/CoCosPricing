/* 
 * File:   CoCosPricing.cpp
 * Author: conan
 *
 * Created on July 28, 2015, 12:57 PM
 */

#include <cstdlib>
#include <cmath>
#include <iostream>
#include <fstream>
#include <string>

// Mysql API library

#include <mysql/mysql.h>

// Blitz array library

#include <blitz/array.h>
#include <blitz/range.h>

#include "PricingEngines.hpp"

using namespace std;
using namespace blitz;

/*
 * 
 */

int main(int argc, char** argv) {


    ofstream outputFileStream;


    if (argc < 2) {

        cout << "Usage: " << *argv << " < Run File >\n";

        exit(EXIT_FAILURE);

    }


    double plainVanillaBondPrice;
    double cocosBondPrice;


    cocosPricingEngine *cocosPrice = new cocosPricingEngine [1];

    cocosPrice->readInputFile(argv[1]);

    cocosPrice->queryInterestRates();

    cocosPrice->queryCdsSpreads();

    plainVanillaBondPrice = cocosPrice->pricingPlainVanillaCouponBond();

    cout.flush() << "Plain vanilla bond price: " << plainVanillaBondPrice << endl;

    cocosBondPrice = cocosPrice->pricingCocosBond();

    cout.flush() << "Cocos bond price: " << cocosBondPrice << endl;


    outputFileStream.open("/tmp/CurrentCoCosResults.csv");

    if (!outputFileStream) {

        cout << "Couldn't open file /tmp/CurrentCoCosResults.csv\n";
        exit(0);

    }

    outputFileStream << cocosPrice->getTriggerLevel() << "," << cocosPrice->getGracePeriodsInYears()
            << "," << cocosPrice->getBurnInPeriodsInYears() << "," << cocosBondPrice << endl;

    outputFileStream.close();


    return ( EXIT_SUCCESS);
}

