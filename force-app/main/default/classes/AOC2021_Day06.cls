/**
 * Class to support all logic for the fourth days' challenge!
 * Call as:
 *  AOC2021_Day06 challenge = new AOC2021_Day06( AOC_Base.MODE.EXAMPLE );
 *  challenge.part1();
 *  challenge.part2();
 *
 * Unfortunately for the Lantern fish, in this simulation model their not so unique.
 * Therefore, for efficiency and processing power, don't model each fish to be it's unique own, but group all
 * Lantern fish sharing the same day in their birth-cycle.
 *
 * In addition, one should be aware Apex Integer values have a maximum of 2,147,483,647.
 * Exceeding that value would cause unexpected behaviour, like getting a negative value after adding two positives.
 * Hence, all counters are set to Long datatype to guarantee correct calculations.
 *
 * @author    Reinier van den Assum (rvandenassum@deloitte.nl)
 * @created   December 2021
 */
public with sharing class AOC2021_Day06 extends AOC_Base{
    private static final Integer CYCLE_RESET = 6;
    private static final Integer CYCLE_BORN = 8;

    public AOC2021_Day06( AOC_Base.MODE runmode ){
        this.runmode = runmode;
        this.setInputLines( 'AOC2021_Day06');
    }

    public void part1(){
        System.debug( '*** Answer part 1: ' + this.simulateLanternGrowth( 80 ) );
    }

    public void part2(){
        System.debug( '*** Answer part 2: ' + this.simulateLanternGrowth( 256 ) );
    }

    private Long simulateLanternGrowth( Integer numDays ){
        // Parse input to get the starting number of Lantern Fish per day in their Cycle
        List<Integer> lanternCycleInput = this.splitStringToIntegers( this.inputLines[ 0 ], ',' );
        Map<Integer, Long> numFishPerDayInCycle = new Map<Integer, Long>();
        for( Integer i = 0, j = lanternCycleInput.size(); i < j; i++ ){
            this.increaseCounter( numFishPerDayInCycle, lanternCycleInput[ i ], 1 );
        }

        // Loop over requested number of days to simulate and process the 'Lantern-cycle'
        for( Integer day = 0; day < numDays; day++ ){
            // Fetch number of fish which will be RESET and to be added as BORN (6 and 8, resp.)
            // Note, item is removed from Map, to ensure it's not counted twice, e.g. when there are no fish in 1-cycle-day-left to override in Map
            Long numGivingBirth = numFishPerDayInCycle.remove( 0 );

            // Loop over the other fish in cycle and shift them down as one more day is passing
            // Note, initially looped over keyset of Map, but a keyset() is not necessarily returned in the correct order [0, 1, 2, 3, ...]
            // Also, it's likely after a certain period all cycle-days have fish (depending on input),
            // so loop-over-days vs. loop-over-keyset are expected to equalize in performance after some day-iterations
            for( Integer c = 1; c <= CYCLE_BORN; c++ ){
                Long numFishInCycle = numFishPerDayInCycle.remove( c );
                // Because 0 is removed before for-loop, each number of fish can be safely added to one-day-earlier as it is removed already
                if( numFishInCycle != null ){
                    numFishPerDayInCycle.put( c - 1, numFishInCycle );
                }
            }
            // After promoting all fish one day in their cycle, process the Lantern Births, when applicable
            // Done after all 'promotions', to avoid a reset-cycle-lantern to immediately be promoted from 6 > 5 days
            if( numGivingBirth != null ){
                this.increaseCounter( numFishPerDayInCycle, CYCLE_BORN, numGivingBirth );
                this.increaseCounter( numFishPerDayInCycle, CYCLE_RESET, numGivingBirth );
            }
        }

        // After all days are simulated, loop over all number of fish in their corresponding days-left-in-cycle to calculate total population
        Long populationSize = 0;
        List<Long> numLanternFishPerCycle = numFishPerDayInCycle.values();
        for( Integer i = 0, j = numLanternFishPerCycle.size(); i < j; i++ ){
            populationSize += numLanternFishPerCycle[ i ];
        }
        return populationSize;
    }

    private void increaseCounter( Map<Integer, Long> countMap, Integer key, Long numToAdd ){
        Long currentValue = countMap.get( key );
        if( currentValue == null ){ currentValue = 0; }
        countMap.put( key, ( currentValue + numToAdd ) );
    }
}