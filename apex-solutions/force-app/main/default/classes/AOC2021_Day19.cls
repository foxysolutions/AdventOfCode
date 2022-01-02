/**
 * Class to support all logic for the 19th days' challenge!
 * Call as:
 *  AOC2021_Day19 challenge = new AOC2021_Day19( AOC_Base.MODE.EXAMPLE );
 *  challenge.part1();
 *  challenge.part2(); // note, part2() is included in part1();
 *
 * Some performance tricks:
 * - Stopping loop when not sufficient matches left to still reach the success-threshold (comparison of 2 scanners cost 2500-3000ms and after efficiency 1500-2000ms)
 * - Keeping track of Scanners which can never be matched and with that remove the logic to keep track of already processed Scanner when breaking midterm due to nearing CPU limit
 * - Keeping track of Unique Beacon Coords instead of introducing additional loop over all Scanners to determine unique Beacon Coordinates across all Scanners
 * - Queueables to allow splitting workload and stay within Apex CPU Timeout limits
 *
 * @author    Reinier van den Assum (rvandenassum@deloitte.nl)
 * @created   December 2021
 */
public with sharing class AOC2021_Day19 extends AOC_Base{
    public AOC2021_Day19( AOC_Base.MODE runmode ){
        this.runmode = runmode;
        this.setInputLines( 'AOC2021_Day19' );
    }

    /**
     * Part1() is resolved by using Asynchronous Apex, based on Queueable technique
     * Note, Developer & Trial Editions are limited to allow only 5 chained Queueables, for larger datasets one will need to use a non-Deloper org
     * E.g. today's Real Input with 36 Scanners results in 784 Scanner comparisons
     */
    public void part1(){
        // Process input beacon lines to the corresponding Scanner number, defined as Pending, since not yet in shared axis-system
        Map<Integer, List<Coordinate>> beaconCoordsByScanner_Pending = this.processInput();

        // Define base variables; setting Scanner 0 as axis-base; removing it from Pending list and putting it to the Resolved Scanner map
        Map<Integer, List<Coordinate>> beaconCoordsByScanner_Resolved = new Map<Integer, List<Coordinate>>{
            0 => beaconCoordsByScanner_Pending.remove( 0 )
        };

        System.debug( '*** Input is processed and Queueable will be triggered to handle logic Asynchronous' );
        System.debug( '*** Note, for Developer Orgs only datasets with small number of Scanners can be completed, due to max. of 5 chained Queueables, if needed use non-Developer Org' );
        System.enqueueJob( new Queue_ScannerMatching( beaconCoordsByScanner_Pending, beaconCoordsByScanner_Resolved ) );
    }

    public void part2(){
        System.debug( '*** Implemented in implementation for part1()' );
    }

    private Map<Integer, List<Coordinate>> processInput(){
        Map<Integer, List<Coordinate>> beaconCoordsByScanner = new Map<Integer, List<Coordinate>>();
        Integer scannerIndex = 0;
        List<Coordinate> scannerBeaconCoords = new List<Coordinate>();
        for( Integer i = 0, j = inputLines.size(); i < j; i++ ){
            String str = inputLines[ i ];
            if( str.startsWith( '---' ) ){
                // Reset Beacon Coords variable and add as reference to next List-index (since there is no closing line)
                scannerBeaconCoords = new List<Coordinate>();
                beaconCoordsByScanner.put( scannerIndex++, scannerBeaconCoords ); // put on Index and afterwards increase with 1
            } else if( String.isNotBlank( str ) ){
                // Assign non-empty input to the scannerBeaconCoords which are referenced by the Scanner Index in the Map
                scannerBeaconCoords.add( new Coordinate( str ) );
            }
        }
        return beaconCoordsByScanner;
    }

    public class Queue_ScannerMatching implements Queueable{
        Map<Integer, List<Coordinate>> beaconCoordsByScanner_Pending; // Unprocessed Coordinates
        Map<Integer, List<Coordinate>> beaconCoordsByScanner_Resolved; // Coordinates in Scanner 0 coordinate-axis-system
        Set<String> scannersWithoutOverlap; // Scanner Number Combinations of Scanners which do not share suffiicent overlap
        Set<String> uniqueBeaconCoords; // All unique Coordinate Strings cross rebased Scanner
        List<Coordinate> distances; // Distances from Scanner 0
        Integer MAX_CPU_LIMIT;

        private final Integer MINIMUM_MATCHING_BEACONS = 12;

        /**
         * Constructor for Queueable class to allow continuation at a certain stage
         */
        public Queue_ScannerMatching( Map<Integer, List<Coordinate>> pendingScanners, Map<Integer, List<Coordinate>> resolvedScanners ){
            this( pendingScanners, resolvedScanners, new Set<String>(), null, null );
        }
        public Queue_ScannerMatching( Map<Integer, List<Coordinate>> pendingScanners, Map<Integer, List<Coordinate>> resolvedScanners, Set<String> scannersWithoutOverlap, Set<String> uniqueCoords, List<Coordinate> distancesFromZero ){
            this.beaconCoordsByScanner_Pending = pendingScanners;
            this.beaconCoordsByScanner_Resolved = resolvedScanners;
            this.scannersWithoutOverlap = scannersWithoutOverlap;
            if( uniqueCoords != null ){
                this.uniqueBeaconCoords = uniqueCoords;
            } else{
                // For first iteration, set unique Beacon Coords of Scanner 0 (since List to Coordinate-Strings method exists only in this Queueable class)
                this.uniqueBeaconCoords = new Set<String>( this.convertListCoordinatesToStrings( resolvedScanners.get( 0 ) ) );
            }
            this.distances = ( distancesFromZero == null ) ? new List<Coordinate>() : distancesFromZero;

            System.debug( '*** New Instance: resolved ' + JSON.serialize( resolvedScanners.keySet() ) + '; ' +
                'pending ' + JSON.serialize( pendingScanners.keySet() ) + '; ' +
                'non-overlapping scanners ' + JSON.serialize( scannersWithoutOverlap ) + '; ' +
                'with distances: ' + JSON.serialize( this.distances ) +
                ' and ' + this.uniqueBeaconCoords.size() + ' unique Beacons; ' );
        }

        /**
         * The magic! Loop over all pending Scanners, to see whether it can be matched/rebased to a Known/Resolved Scanner; continue till all known
         */
        public void execute( QueueableContext ctx ){
            Long start = System.now().getTime();
            // Only define CPU Limit within Execute() as initiation is initially performed in Synchronous mode (thus 10s instead of 60s)
            this.MAX_CPU_LIMIT = Limits.getLimitCpuTime();

            while( !beaconCoordsByScanner_Pending.isEmpty() ){
                // Loop over all Scanners of which axis-system is not yet identified/known
                for( Integer indexUnknownScanner : beaconCoordsByScanner_Pending.keySet() ){
                    // Loop over all Scanners of which Beacon Coords are alerady 'rebased' to allow relative comparisons
                    for( Integer indexIdentifiedScanner : beaconCoordsByScanner_Resolved.keySet() ){
                        System.debug( '*** Checking ' + indexUnknownScanner + ' vs. known coords of ' + indexIdentifiedScanner );

                        Long currentDuration = System.now().getTime() - start;
                        if( currentDuration >= ( MAX_CPU_LIMIT * 0.90 ) ){
                            System.debug( '*** Ending current Queueable and triggering new one ' + currentDuration + '/' + MAX_CPU_LIMIT );
                            // Note, no need to keep track of current indexIdentifiedScanner, since when not matching this is stored in scannersWithoutOverlap
                            System.enqueueJob( new Queue_ScannerMatching( this.beaconCoordsByScanner_Pending, this.beaconCoordsByScanner_Resolved, this.scannersWithoutOverlap, this.uniqueBeaconCoords, this.distances ) );
                            return;
                        }

                        // Avoid duplicate checking, when already known they don't have any/sufficient overlapping Coords
                        if( scannersWithoutOverlap.contains( indexIdentifiedScanner + ',' + indexUnknownScanner ) ){
                            continue;
                        }

                        // Try to find a valid base-axis-system, by changing sign and axis-shuffle
                        MatchResult match = this.findAlignmentBeacons(
                            beaconCoordsByScanner_Resolved.get( indexIdentifiedScanner ),
                            beaconCoordsByScanner_Pending.get( indexUnknownScanner )
                        );

                        // When a valid rebase & shift of coordinates led to at least 12 matching Beacons, remove Scanner index from 'unidentified' Map
                        // Add the rebased and shifted Coordinates to Known Scanners to ensure all Coordinates are in same Scanner-0-Coordinate System
                        if( match != null ){
                            beaconCoordsByScanner_Pending.remove( indexUnknownScanner );
                            beaconCoordsByScanner_Resolved.put( indexUnknownScanner, match.rebasedCoords );
                            this.uniqueBeaconCoords.addAll( this.convertListCoordinatesToStrings( match.rebasedCoords ) );
                            this.distances.add( match.distance );
                            break;
                        } else{
                            // When no or less than 12 Beacon Coordinates could be found a common base, prevent future checks
                            scannersWithoutOverlap.add( indexIdentifiedScanner + ',' + indexUnknownScanner );
                        }
                    }
                }
            }
            System.debug( '*** Answer part 1: ' + this.uniqueBeaconCoords.size() );

            // Part 2 - calculate Maximum Manhattan distance between two Scanners (based on Distance to Scanner 0)
            //   1  2  3  4     Loop over all distances and compare to all other items;
            // 1 x              Since 1-3 and 3-1 share the same Manhattan distances, only compare 'upper-side-of-diagonal'
            // 2 -  x           Thus for i = 1, only process 2, 3 and 4 (aka i + 1 till end)
            // 3 -  -  x
            // 4 -  -  -  x
            Long maxDistance;
            for( Integer i = 0, j = this.distances.size(); i < j; i++ ){
                Coordinate distancesOne = this.distances[ i ];
                for( Integer k = ( i + 1 ), l = this.distances.size(); k < l; k++ ){
                    Long dist = distancesOne.getManhattanDistance( this.distances[ k ] );
                    if( maxDistance == null || maxDistance < dist ){
                        maxDistance = dist;
                    }
                }
            }
            System.debug( '*** Answer part 2: ' + maxDistance );
            System.debug( '*** Completed in ' + ( System.now().getTime() - start ) );
        }

        public List<String> convertListCoordinatesToStrings( List<Coordinate> coordList ){
            List<String> coordStrings = new List<String>();
            for( Integer i = 0, j = coordList.size(); i < j; i++ ){
                coordStrings.add( coordList[ i ].getString() );
            }
            return coordStrings;
        }

        /**
         * Axis-base mutation input
         */
        // Specify all Negative/Positive comparisons possible
        private final List<Coordinate> COORD_SIGN_MUTATIONS = new List<Coordinate>{
            new Coordinate( 1, 1, 1 ),
            new Coordinate( 1, 1, -1 ),
            new Coordinate( 1, -1, 1 ),
            new Coordinate( 1, -1, -1 ),
            new Coordinate( -1, 1, 1 ),
            new Coordinate( -1, 1, -1 ),
            new Coordinate( -1, -1, 1 ),
            new Coordinate( -1, -1, -1 )
        };
        private final Integer NUM_SIGN_MUTATIONS = COORD_SIGN_MUTATIONS.size();
        // Specify all possible axis-shuffles (0,1,2 is keeping it the same; 0, 2, 1 means y and z swap)
        private final List<Coordinate> COORD_AXIS_SHUFFLE = new List<Coordinate>{
            new Coordinate( 0, 1, 2 ),
            new Coordinate( 0, 2, 1 ),
            new Coordinate( 1, 0, 2 ),
            new Coordinate( 1, 2, 0 ),
            new Coordinate( 2, 0, 1 ),
            new Coordinate( 2, 1, 0 )
        };
        private final Integer NUM_AXIS_SHUFFLES = COORD_AXIS_SHUFFLE.size();

        /**
         * Method to find the Coordinate-mutation required to have at least 12 matching Beacons across the baseCoords and the Beacon Coordinates of the next Scanner
         * When mutation-action is known, apply to all Beacon Coordinates and return, to allow keeping track of total number of unique Beacons across all Scanner detections
         *
         * 1) Loop over all potential Axis shuffles (caused by different Scanner-device-orientation)
         * 2) Loop over all Sign differentiations (related to Scanner-device-orientation, e.g. when Scanners are floating on the opposite of the same Beacons)
         * 3) For each sign-axis-shuffle-mutation, rebase the Coordinates for the to-be-checked-Scanner matching that coordinate system
         * 4) Loop over BaseCoords and all possible NextScannerCoords to determine linear axis-additions to make this NextScannerCoord match the BaseCoord
         * 5) Loop over other NextScannerCoords and apply the same linear axis-additions (step 4) to verify whether this would allow more coordinates to be matched
         * 6) After processing all, check if more than 12 NextScannerCoords could be matched to a BaseCoord, if so, it's a match, we found the alignment!
         * Return the mutated NextScannerCoords, so all Beacon Coordinates are converted to respect the same coordinate system
         *
         * @param baseCoords            List of Coordinate instances of the Beacons which are in range of Scanner 0 (base Scanner)
         * @param nextScannerCoords     List of Beacon Coordinates detected by another Scanner, which should be converted to satisfy the same coordinate-system
         * @return                      Updated List of Coordinates which are in the same axis-base as the BaseCoords (to allow counting uniqueness)
         */
        private MatchResult findAlignmentBeacons( List<Coordinate> baseCoords, List<Coordinate> nextScannerCoords ){
            // Convert List of Coordinates to List of Strings to allow easier 'contains' (as input for performance to avoid duplicate construction)
            List<String> baseCoordStrings = this.convertListCoordinatesToStrings( baseCoords );
            // 1 + 2) Loop over all potential Axis shuffles and Sign differentiations
            for( Integer shuffleIndex = 0; shuffleIndex < NUM_AXIS_SHUFFLES; shuffleIndex++ ){
                Coordinate axisShuffle = COORD_AXIS_SHUFFLE[ shuffleIndex ];
                for( Integer signIndex = 0; signIndex < NUM_SIGN_MUTATIONS; signIndex++ ){
                    Coordinate signMutations = COORD_SIGN_MUTATIONS[ signIndex ];

                    // 3) Rebase all Next-Scanner-Beacon-Coordinates to respect the coordinate system defined by the axis-shuffle & sign combination
                    List<Coordinate> rebasedCoordinates = this.rebaseCoordinates( nextScannerCoords, signMutations, axisShuffle );

                    // 4) Loop over BaseCoords and all possible (rebased) NextScannerCoords to determine linear axis-additions to make this NextScannerCoord match the BaseCoord
                    for( Integer i = 0, j = baseCoords.size(); i < j; i++ ){
                        Coordinate a = baseCoords[ i ];

                        for( Integer n = 0, numNextScannerCoords = rebasedCoordinates.size(); n < numNextScannerCoords; n++ ){
                            Coordinate b = rebasedCoordinates[ n ];

                            // Determine the linear changes needed to match this BaseCoord (a) with the NextScannerCoord (b)
                            Coordinate coordShifting = new Coordinate(
                                b.x - a.x,
                                b.y - a.y,
                                b.z - a.z
                            );

                            // Loop (again) over all rebased Beacon Coordinates and apply above CoordShifting relevant to match coordinate n
                            // Keep track of the rebased (above) and shifted (below) coordinates in case more than 12 matches are found
                            Integer numMatches = 0;
                            List<Coordinate> rebasedAndShiftedCoordinates = new List<Coordinate>();
                            for( Integer n2 = 0; n2 < numNextScannerCoords; n2++ ){
                                // To prevent too much looping, validate if this a-b shift & rebase would still be feasible to exceed Minimum number of Matching Beacons
                                // When number of remaining items, minus the number of remaining required matches is less than 0, break rest of loop
                                if( ( ( numNextScannerCoords - n2 ) - ( MINIMUM_MATCHING_BEACONS - numMatches ) < 0 ) ){
                                    break;
                                }
                                Coordinate otherCoord = rebasedCoordinates[ n2 ];

                                // Apply linear axis shift applied to match coordinate a & b, to otherCoord
                                Coordinate rebasedShiftedCoord = new Coordinate(
                                    otherCoord.x - coordShifting.x,
                                    otherCoord.y - coordShifting.y,
                                    otherCoord.z - coordShifting.z
                                );
                                rebasedAndShiftedCoordinates.add( rebasedShiftedCoord );

                                // Check if newly found Coordinate of next Scanner also exists in Beacon Coords of Base Scanner
                                if( baseCoordStrings.contains( rebasedShiftedCoord.getString() ) ){
                                    numMatches++;
                                    continue;
                                }
                            }
                            // Only AFTER processing ALL records, validate if there were more than the minimum (to make sure ALL coords first get rebased & shifted)
                            if( numMatches >= MINIMUM_MATCHING_BEACONS ){
                                System.debug( '*** Found valid mutation for coordinate ' + coordShifting.getString() );
                                return new MatchResult( rebasedAndShiftedCoordinates, coordShifting );
                            }
                        }
                    }
                }
            }
            return null;
        }

        /**
         * Method to allow rebasing Coordinates to a different Coordinate System.
         *
         * @param coordinates       List of original Coordinates which should be rebased to the different system
         * @param signMutation      Specific Sign Mutation to swap sign (positive vs. negative)
         * @param rebaseMutation    Rebasing coordinates system, swapping x for y, z of x, etc.
         * @return List of input Coordinates rebased to different Coordinate System
         */
        private List<Coordinate> rebaseCoordinates( List<Coordinate> coordinates, Coordinate signMutation, Coordinate rebaseMutation ){
            List<Coordinate> rebasedCoordinates = new List<Coordinate>();
            for( Integer i = 0, j = coordinates.size(); i < j; i++ ){
                Coordinate curr = coordinates[ i ];
                rebasedCoordinates.add( new Coordinate(
                    signMutation.x * ( ( rebaseMutation.x == 0 ) ? curr.x : ( ( rebaseMutation.x == 1 ) ? curr.y : ( ( rebaseMutation.x == 2 ) ? curr.z : 0 ) ) ),
                    signMutation.y * ( ( rebaseMutation.y == 0 ) ? curr.x : ( ( rebaseMutation.y == 1 ) ? curr.y : ( ( rebaseMutation.y == 2 ) ? curr.z : 0 ) ) ),
                    signMutation.z * ( ( rebaseMutation.z == 0 ) ? curr.x : ( ( rebaseMutation.z == 1 ) ? curr.y : ( ( rebaseMutation.z == 2 ) ? curr.z : 0 ) ) )
                ) );
            }
            return rebasedCoordinates;
        }
    }

    /**
     * Inner class to allow easy returning of both distances (in Coordinate format) and the rebased Coordinates
     */
    public class MatchResult{
        List<Coordinate> rebasedCoords;
        Coordinate distance;
        MatchResult( List<Coordinate> coords, Coordinate dist ){
            this.rebasedCoords = coords;
            this.distance = dist;
        }
    }
}

/**
DEBUG LOGS when running part1() for Example data:

Anonymous Apex:
*** Input is processed and Queueable is triggered to handle logic Asynchronous
*** Note, for Developer Orgs only datasets with small number of Scanners can be completed, due to max. of 5 chained Queueables, if needed use non-Developer Org
*** New Instance: resolved [0]; pending [1,2,3,4]; non-overlapping scanners []; and 25 unique Beacons
** Completed in 103

First Queueable:
*** Checking 1 vs. known coords of 0
*** Found valid mutation for coordinate -68,1246,43
*** Checking 2 vs. known coords of 0
*** Checking 2 vs. known coords of 1
*** Checking 3 vs. known coords of 0
*** Checking 3 vs. known coords of 1
*** Found valid mutation for coordinate 92,2380,20
*** Checking 4 vs. known coords of 0
*** Checking 4 vs. known coords of 1
*** Ending current Queueable and triggering new one 54855/60000
*** New Instance: resolved [0,1,3]; pending [2,4]; non-overlapping scanners ["0,2","1,2","0,3","0,4"]; with distances: [{"z":43,"y":1246,"x":-68},{"z":20,"y":2380,"x":92}] and 51 unique Beacons;

Second Queueable:
*** Checking 2 vs. known coords of 0
*** Checking 2 vs. known coords of 1
*** Checking 2 vs. known coords of 3
*** Checking 4 vs. known coords of 0
*** Checking 4 vs. known coords of 1
*** Found valid mutation for coordinate 20,1133,-1061
*** Checking 2 vs. known coords of 0
*** Checking 2 vs. known coords of 1
*** Checking 2 vs. known coords of 3
*** Checking 2 vs. known coords of 4
*** Found valid mutation for coordinate -1105,1205,-1229
*** Answer part 1: 79
*** Answer part 2: 3621
*** Completed in 55430
*/

/**
 * Small matchers example
 *
--- scanner 0 ---
0,2,1
4,1,1
3,3,1

--- scanner 1 ---
-1,-1,1
-5,0,1
-2,1,1
*/
