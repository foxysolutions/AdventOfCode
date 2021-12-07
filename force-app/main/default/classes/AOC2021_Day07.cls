/**
 * Class to support all logic for the 7th days' challenge!
 * Call as:
 *  AOC2021_Day07 challenge = new AOC2021_Day07( AOC_Base.MODE.EXAMPLE );
 *  challenge.part1();
 *  challenge.part2();
 *
 * The median provides the middle value, which thus has comparable distances to both sides
 * The mean/average provides the average value, which means outliers are equally taken into account
 *
 * Several quirks/tricky things in Java/Apex:
 * - Integer / Integer = Integer. Since conversion to Integer is simply stripping the decimal values, 5/2=2, while 5.0/2=2.5
 * - Math.round() rounds a 0.5 to the nearest EVEN number; hence 9.0 / 2 = 4.5, but Math.round( 4.5 ) = 4, as 4 is even
 *
 * @author    Reinier van den Assum (rvandenassum@deloitte.nl)
 * @created   December 2021
 */
public with sharing class AOC2021_Day07 extends AOC_Base{
    private Integer medianSpot, averageSpot;
    private Map<Integer, Integer> numCrabsPerSpot = new Map<Integer, Integer>();

    public AOC2021_Day07( AOC_Base.MODE runmode ){
        this.runmode = runmode;
        this.setInputLines( 'AOC2021_Day07' );
        this.processInputs();
    }

    public void part1(){
        // When all distances are equally heavy and travel time doesn't impact the solution, it is most efficient to 'meet-in-the-middle'.
        // This isn't the average, since one crab might be in an extreme outlier. Hence, sort the List and pick the middle number, the Median.
        System.debug( '*** Answer part 1: Meet at '+ this.medianSpot + ' with ' + this.calculateTotalFuelCosts( this.medianSpot, false ) + ' total fuel costs' );
    }

    public void part2(){
        // When outliers way more heavily, but in an equal way, and when every crab needs to move.
        // The Average aka Mean spot provides the best place to meet, since more lower numbers will impact it, but one outlier, which would cost a lot of fuel ways as well.
        System.debug( '*** Answer part 2: Meet at '+ this.averageSpot + ' with '+ this.calculateTotalFuelCosts( this.averageSpot, true ) + ' total fuel costs' );
    }

    /**
     * Method to calculate the total FuelCost based on a suggested spot-index. Looping over all spots to determine required fuel
     * to travel from that spot to the suggested spot and multiply it by the number of crabs which would need to travel
     *      (apparently/unfortunately, crabs don't 'carpool' yet, or this would have impact on whether or not the whale would eat us...)
     *
     * @param suggestedSpot         The spot all crabs should meet
     * @param weightedFuelImpact    Whether or not the fuel is weighted to increase more heavily for longer distances
     *                              If FALSE, each 'step' costs 1 fuel-unit; TRUE, each 'step' costs 1 fuel-unit, but the next one costs 2, 3, 4, ...
     * @return Total fuel costs for all crabs to travel to the suggested spot in their little submarines
     */
    private Long calculateTotalFuelCosts( Integer suggestedSpot, Boolean weightedFuelImpact ){
        Long fuelCost = 0;
        // Loop over all spots with Crabs and calculate fuelCost by distance, multiplied by number of crabs
        for( Integer spotLocation : this.numCrabsPerSpot.keySet() ){
            Integer travelDistance = Math.abs( spotLocation - suggestedSpot );
            // When fuel is not weighted; each 'step' costs 1 unit, hence the fuel cost per crab is equal to the distance to travel
            // When fuel is weighted; 1 => 1; 2 => 1+2 = 3; 3 => 1+2+3 = 6; 4 => 1+2+3+4 = 10... this can be calculated by multiplying it by half+0.5
                // E.g. 4 / 2 + 0.5 = 2,5; 2.5 * 4 = 10;    10 steps => 55 costs ( 10 / 2 + 0.5 ) = 5.5; 5.5*10 = 55
            Integer fuelCostPerCrab = ( weightedFuelImpact )
                ? this.roundToInteger( ( ( travelDistance / 2.0 ) + 0.5 ) * travelDistance )
                : travelDistance;
            fuelCost += fuelCostPerCrab * this.numCrabsPerSpot.get( spotLocation );
        }
        return fuelCost;
    }

    private void processInputs(){
        // Parse input to get the starting number of Crabs per horizontal location
        List<Integer> crabLocationsInput = this.splitStringToIntegers( this.inputLines[ 0 ], ',' );
        Integer numberOfCrabs = crabLocationsInput.size();

        // Determine Median value by sorting list of crabSpots and picking middle value
        // Multiple by 1.0 to make sure one is Decimal, else Java (underneath Apex) will simply return an Integer (see class header)
        crabLocationsInput.sort();
        this.medianSpot = crabLocationsInput[ this.roundToInteger( numberOfCrabs * 1.0 / 2 ) ];

        // Determine average/Mean value by calculating sum of Crab spots and dividing by number of Crabs
        // Construct Map of number of crabs per specific spot-index; this way we could operate on <2N, while looping over all crabs for fuel costs would be 2N
        // In case multiple Crabs are at the same spot, this reduces the number of iterations on fuel calculations (hence <1N);
        // Hence, highly depending on input, whether or not the efficiency is more than the additional costs of Map-construction
        Long totalCrabSpots = 0;
        for( Integer i = 0, j = crabLocationsInput.size(); i < j; i++ ){
            Integer crabSpot = crabLocationsInput[ i ];
            this.increaseCounter( this.numCrabsPerSpot, crabSpot , 1 );
            totalCrabSpots += crabSpot;
        }
        // Multiple by 1.0 to make sure one is Decimal, else Java (underneath Apex) will simply return an Integer (see class header)
        this.averageSpot = this.roundToInteger( totalCrabSpots * 1.0 / numberOfCrabs );
    }

    private void increaseCounter( Map<Integer, Integer> countMap, Integer key, Integer numToAdd ){
        Integer currentValue = countMap.get( key );
        if( currentValue == null ){ currentValue = 0; }
        countMap.put( key, ( currentValue + numToAdd ) );
    }
}