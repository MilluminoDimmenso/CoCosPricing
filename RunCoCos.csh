#!/bin/tcsh


# 2ST-OD 2ST-RD 2ST-HC50 3ST-OD 3ST-RD1 3ST-RD2

if ( $# < 1 ) then
  echo "Usage: " $0 "<InputString>"
  exit
endif

# 
# 

echo "Trigger Level,Shift Period,Burn In,Standstill Percentage,CoCos Price F-StandStill,CoCos Price S-StandStill,Defaultable Bond Price" > /tmp/CoCosExperiments.csv

foreach burnIn ( 0 )

  foreach standStill ( 0.0 )

    foreach triggerLevel ( 200 300 400 500 600 )
        
        foreach defaultLevel ( 500 )

            foreach shiftPeriods ( 1 3 5 )

                echo "NUMBER_OF_SCENARIOS" > InFiles/InputFileCurrentRun.in
                echo "1000" >> InFiles/InputFileCurrentRun.in
                echo "BOND_MATURITY" >> InFiles/InputFileCurrentRun.in
                echo "20" >> InFiles/InputFileCurrentRun.in
                echo "SHORT_RATE_DATABASE_NAME" >> InFiles/InputFileCurrentRun.in
                echo "COCOS_RATES" >> InFiles/InputFileCurrentRun.in
                echo "CDS_DATABASE_NAME" >> InFiles/InputFileCurrentRun.in
                echo "COCOS" >> InFiles/InputFileCurrentRun.in
                echo "SPREAD_LOOK_BACK_DAYS" >> InFiles/InputFileCurrentRun.in
                echo "30" >> InFiles/InputFileCurrentRun.in
                echo "COCOS_TRIGGER_LEVEL" >> InFiles/InputFileCurrentRun.in
                echo $triggerLevel >> InFiles/InputFileCurrentRun.in
                echo "DEFAULT_TRIGGER_LEVEL" >> InFiles/InputFileCurrentRun.in
                echo $defaultLevel >> InFiles/InputFileCurrentRun.in
                echo "GRACE_PERIODS_IN_YEARS" >> InFiles/InputFileCurrentRun.in
                echo $shiftPeriods >> InFiles/InputFileCurrentRun.in
                echo "BURN_IN_PERIODS_IN_YEARS" >> InFiles/InputFileCurrentRun.in
                echo $burnIn >> InFiles/InputFileCurrentRun.in
                echo "STANDSTILL_PERCENTAGE" >> InFiles/InputFileCurrentRun.in
                echo $standStill >> InFiles/InputFileCurrentRun.in
                echo "COUPON_FREQUENCY" >> InFiles/InputFileCurrentRun.in
                echo "2" >> InFiles/InputFileCurrentRun.in
                echo "END_DATA" >> InFiles/InputFileCurrentRun.in

                mv InFiles/InputFileCurrentRun.in InFiles/InputFile.in

                $1 InFiles/InputFile.in

                cat /tmp/CurrentCoCosResults.csv >> /tmp/CoCosExperiments.csv
            end

        end

    end

  end 

end