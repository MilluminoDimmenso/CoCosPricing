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

    
    if (argc < 2) {

        cout << "Usage: " << *argv << " < Run File >\n";

        exit(EXIT_FAILURE);

    }
    
    
    cocosPricingEngine *cocosPrice = new cocosPricingEngine [1];
    
    cocosPrice->readInputFile(argv[1]);
    
    return ( EXIT_SUCCESS);
}

