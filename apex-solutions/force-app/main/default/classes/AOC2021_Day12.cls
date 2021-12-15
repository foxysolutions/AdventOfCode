/**
 * Class to support all logic for the 12th days' challenge!
 * Call as:
 *  AOC2021_Day12 challenge = new AOC2021_Day12( AOC_Base.MODE.EXAMPLE );
 *  challenge.part1();
 *  challenge.part2();
 *
 * Experimented today with String vs. List operations; Find below for the Real input
 * - Storing Routes as Lists     950 - 1400 ms (most often around 1200ms)
 * - Storing Routes as String   1100 - 1600 ms (most often around 1400ms)
 * In short, when working character-based with multiple manipulations, Strings are preferred!
 *
 * Another experiment was with keeping track of List<List<String>> (valid routes) vs. numValidRoutes
 * Surprisingly, they were both as performing as the other, despite the extra expected memory needed for the first one
 *
 * @author    Reinier van den Assum (rvandenassum@deloitte.nl)
 * @created   December 2021
 */
public with sharing class AOC2021_Day12 extends AOC_Base{
    Map<String, List<String>> PATHS = new Map<String, List<String>>();
    final String CAVE_START = 'start';
    final String CAVE_END = 'end';

    public AOC2021_Day12( AOC_Base.MODE runmode ){
        this.runmode = runmode;
        this.setInputLines( 'AOC2021_Day12' );
        for( Integer i = 0, j = inputLines.size(); i < j; i++ ){
            List<String> fromTo = inputLines[ i ].split( '-' );
            // Add path both normal and reverse to PATHS, unless it would go towards START or from END
            if( fromTo[ 1 ] != CAVE_START && fromTo[ 0 ] != CAVE_END ){
                addToListInMap( PATHS, fromTo[ 0 ], fromTo[ 1 ] );
            }
            if( fromTo[ 0 ] != CAVE_START && fromTo[ 1 ] != CAVE_END ){
                addToListInMap( PATHS, fromTo[ 1 ], fromTo[ 0 ] );
            }
        }
    }

    public void part1(){
        // Keeping track of only the number of valid routes
        System.debug( '*** Answer part 1 (numbers): ' +
            this.findNumberOfValidRoutes(
                new List<String>(), // Current (initial) route
                CAVE_START,         // Next cave to investigate
                false,              // Whether or not duplicates are allowed
                0,                  // Current number of valid routes
                ( Map<String, List<String>> ) JSON.deserializeStrict( JSON.serializePretty( PATHS ), Map<String, List<String>>.class )
            )
        );

        // Keeping track of the exact valid routes
        List<List<String>> validRoutes = new List<List<String>>();
        this.findAllValidRoutes(
            new List<String>(), // Current (initial) route
            CAVE_START,         // Next cave to investigate
            false,              // Whether or not duplicates are allowed
            validRoutes,        // Current (initial) List of all validRoutes
            ( Map<String, List<String>> ) JSON.deserializeStrict( JSON.serializePretty( PATHS ), Map<String, List<String>>.class )
        );
        System.debug( '*** Answer part 1 (list routes): ' + validRoutes.size() );
    }

    /**
     * Unfortunately no matter what was tried, the recursive approach for part2() (allowing one duplicate) always caused Apex-CPU-time-limit-exceeded Exceptions.
     * - WorkList with Queue of Routes to check, including inner class to keep track of duplicates
     * - Defining Routes and looping over each route to find next option, cloning in case multiple options
     * Hence, conclusion is to approach it the same as part1(), but then Async to increase CPU Limit from 10 to 60
     */
    public void part2(){
        switch on this.runmode{
            when EXAMPLE{
                this.performPart2();
            }
            when FOR_REAL{
                // Since it takes a little more than 10 seconds which is CPU Time limit, call this beauty Async
                System.debug( '*** Answer part 2: Running Async, check Log Analyzer in IDE for the answer' );
                AOC2021_Day12.runPart2Async();
            }
        }
    }
    @Future
    public static void runPart2Async(){
        AOC2021_Day12 classInstance = new AOC2021_Day12( AOC_Base.MODE.FOR_REAL );
        classInstance.performPart2();
    }

    public void performPart2(){
        List<List<String>> validRoutes = new List<List<String>>();
        this.findAllValidRoutes(
            new List<String>(), // Current (initial) route
            CAVE_START,         // Next cave to investigate
            true,               // Whether or not duplicates are allowed
            validRoutes,        // Current (initial) List of all validRoutes
            ( Map<String, List<String>> ) JSON.deserializeStrict( JSON.serializePretty( PATHS ), Map<String, List<String>>.class )
        );
        System.debug( '*** Answer part 2: '+ validRoutes.size() );
    }

    /**
     * Recursive method to count the number of total values based on all possible paths per starting point
     * Only count the number of routes instead of storing them for performance reasons and exact routes are not desired
     * Optionally one can allow one lowercase-duplicate
     * @return  Path-list when the END cave was reached, null otherwise; so initiating call can only expect null
     */
    private List<String> findAllValidRoutes( List<String> currRoute, String nextCave, Boolean allowDuplicate, List<List<String>> validRoutes, Map<String, List<String>> pathsByStart ){
        if( nextCave.isAllLowerCase() && currRoute.contains( nextCave ) ){
            if( !allowDuplicate ){
                return null;
            }
            allowDuplicate = false;
        }
        currRoute.add( nextCave );
        if( nextCave == CAVE_END ){
            return currRoute;
        }

        List<String> nextOptions = pathsByStart.get( nextCave );
        for( Integer i = 0, j = nextOptions.size(); i < j; i++ ){
            List<String> foundRoute = this.findAllValidRoutes( currRoute.clone(), nextOptions[ i ], allowDuplicate, validRoutes, pathsByStart );
            if( foundRoute != null ){
                validRoutes.add( foundRoute );
            }
        }
        // When nextCave is NOT Cave_END and not other options, return null as dead end
        return null;
    }

    /**
     * Recursive method to count the number of total values based on all possible paths per starting point
     * Only count the number of routes instead of storing them for performance reasons and exact routes are not desired
     * Optionally one can allow one lowercase-duplicate
     * @return  Number of valid routes found including those of that iteration
     */
    private Long findNumberOfValidRoutes( List<String> currRoute, String nextCave, Boolean allowDuplicate, Long numValidRoutes, Map<String, List<String>> pathsByStart ){
        if( nextCave.isAllLowerCase() && currRoute.contains( nextCave ) ){
            if( !allowDuplicate ){
                return 0;
            }
            allowDuplicate = false;
        }
        currRoute.add( nextCave );
        if( nextCave == CAVE_END ){
            return 1;
        }

        List<String> nextOptions = pathsByStart.get( nextCave );
        Long foundRoutes = 0;
        for( Integer i = 0, j = nextOptions.size(); i < j; i++ ){
            foundRoutes += this.findNumberOfValidRoutes( currRoute.clone(), nextOptions[ i ], allowDuplicate, numValidRoutes, pathsByStart );
        }
        // When nextCave is NOT Cave_END and no other options, return the number of valid routes plus the found new ones in this branch
        return numValidRoutes + foundRoutes;
    }
}