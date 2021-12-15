/**
 * Class to support all logic for the fourth days' challenge!
 * Call as:
 *  AOC2021_Day05 challenge = new AOC2021_Day05( AOC_Base.MODE.EXAMPLE );
 *  challenge.part1();
 *  challenge.part2();
 *
 * Choice today is to NOT construct a full matrix, but only keep track of the occurring coordinates.
 * There is no info regarding the size of the matrix, so one should either assume or first loop all values
 * In addition in Apex you can't simply construct an Array[ 100 ][ 100 ], so this would require quite some initiations.
 * Since only occurrences need to be counted, it is sufficient to have the coordinate-uniqueness in a Map and ignore
 * all the coordinates which are not touched/relevant. Which saves both on construction and on looping for the answer.
 *
 * @author    Reinier van den Assum (rvandenassum@deloitte.nl)
 * @created   December 2021
 */
public with sharing class AOC2021_Day05 extends AOC_Base{

    public AOC2021_Day05( AOC_Base.MODE runmode ){
        this.runmode = runmode;
        this.setInputLines( 'AOC2021_Day05' );
    }

    public void part1(){
        Map<String, Long> occurrencePerCoordinate = new Map<String, Long>();

        for( Integer i = 0, j = inputLines.size(); i < j; i++ ){
            String str = inputLines[ i ];
            List<String> coordinates = str.split( ' -> ' );
            List<Integer> coordinatesFrom = this.splitStringToIntegers( coordinates[ 0 ], ',' );
            List<Integer> coordinatesTo = this.splitStringToIntegers( coordinates[ 1 ], ',' );

            // Only process coordinate range when one of axes is fixed, so horizontal vs. vertical (input definition excludes diagonals)
            Boolean xAxisMatch = coordinatesFrom[ 0 ] == coordinatesTo[ 0 ];
            Boolean yAxisMatch = coordinatesFrom[ 1 ] == coordinatesTo[ 1 ];
            if( xAxisMatch || yAxisMatch ){
                // Determine the axis which is fixed, logically we should then loop over all coordinates in the range of the other axis
                Integer fixedCoord = ( xAxisMatch ) ? coordinatesFrom[ 0 ] : coordinatesFrom[ 1 ];
                Integer fromCoord = ( xAxisMatch ) ? coordinatesFrom[ 1 ] : coordinatesFrom[ 0 ];
                Integer toCoord = ( xAxisMatch ) ? coordinatesTo[ 1 ] : coordinatesTo[ 0 ];
                // To simplify looping, optionally swap direction to ensure incremental for-loop suits all scenarios
                if( fromCoord > toCoord ){
                    Integer originalFrom = fromCoord;
                    fromCoord = toCoord;
                    toCoord = originalFrom;
                }
                for( ; fromCoord <= toCoord; fromCoord++ ){
                    this.increaseCounter(
                        occurrencePerCoordinate,
                        ( ( xAxisMatch )
                            ? fixedCoord + ',' + fromCoord
                            : fromCoord + ',' + fixedCoord ),
                        1
                    );
                }
            }
        }

        // Loop over processed coordinates and count each coordinate which occurred 2+ times
        Integer count = 0;
        for( Long numOccurrences : occurrencePerCoordinate.values() ){
            if( numOccurrences > 1 ){
                count++;
            }
        }

        System.debug( '*** Answer part 1: ' + count );
    }

    public void part2(){
        Map<String, Long> occurrencePerCoordinate = new Map<String, Long>();

        for( Integer i = 0, j = inputLines.size(); i < j; i++ ){
            // Process input line to from and to coordinate and initiate local variables to reduce number of recurring List-retrieval operations
            String str = inputLines[ i ];
            List<String> coordinates = str.split( ' -> ' );
            List<Integer> coordinatesFrom = this.splitStringToIntegers( coordinates[ 0 ], ',' );
            List<Integer> coordinatesTo = this.splitStringToIntegers( coordinates[ 1 ], ',' );
            Integer xFrom = coordinatesFrom[ 0 ];
            Integer yFrom = coordinatesFrom[ 1 ];
            Integer xTo = coordinatesTo[ 0 ];
            Integer yTo = coordinatesTo[ 1 ];

            // Process input-range of coordinates by increasing the occurrence/'danger'-count on each in-between coordinate
            // Note, there is slight different behaviour regarding horizontal & vertical vs. diagonal
            // > When one of the axes doesn't change (horizontal or vertical), loop over all values in other axis (e.g. 0,0 -> 0,2 => 0,0; 0,1; 0,2)
            // > When both axes change (diagonal), increase/decrease both axes each iteration and do NOT loop all values (e.g. 0,0 -> 2,2 => 0,0; 1,1; 2;2)
            //      and NOT (0,0; 0,1; 0,2; 1,0; 1,1; 1,2; 2,0; 2,1; 2,2)
            // When only one axis changes, the sequence of processing the other doesn't batter (forward/backward), hence process always incremental for simplicity
            if( xFrom == xTo ){ // Only vertical movement, since x-axis remains the same
                for( Integer yMin = Math.min( yFrom, yTo ), yMax = Math.max( yFrom, yTo ); yMin <= yMax; yMin++ ){
                    this.increaseCounter( occurrencePerCoordinate, xFrom + ',' + yMin, 1 );
                }
            } else if( yFrom == yTo ){ // Only horizontal movement, since y-axis remains the same
                for( Integer xMin = Math.min( xFrom, xTo ), xMax = Math.max( xFrom, xTo ); xMin <= xMax; xMin++ ){
                    this.increaseCounter( occurrencePerCoordinate, xMin + ',' + yFrom, 1 );
                }
            } else{ // When both axes have movement, this can only be 45* aka diagonal movement, by input definition
                // Then, as explained above, both axes should increase/decrease each iteration (see example)
                // To prevent multiple comparable for-loops (one for increment, one for decrease, etc.) or re-ordering complexity (one can only order ONE of axes, see below)
                // most effective is to loop over number of coordinates in range and avoid usage of any axis-coordinates within the for-loop logic
                Boolean xAxisIncrease = ( xFrom < xTo );
                Boolean yAxisIncrease = ( yFrom < yTo );
                for( Integer n = 0, numCoordinatesInRange = Math.abs( xTo - xFrom ) + 1; n < numCoordinatesInRange; n++ ){
                    this.increaseCounter( occurrencePerCoordinate, xFrom + ',' + yFrom, 1 );
                    xFrom += ( xAxisIncrease ) ? 1 : -1;
                    yFrom += ( yAxisIncrease ) ? 1 : -1;
                }
            }
        }

        // Loop over the 'dummy matrix' where the number of overlap is 2+
        Integer count = 0;
        for( Long numOccurrences : occurrencePerCoordinate.values() ){
            if( numOccurrences > 1 ){
                count++;
            }
        }

        System.debug( '*** Answer part 2: ' + count );
    }

    /**
     * Example of re-ordering challenge when both axes change in the range of coordinates. Imagine 0,2 -> 2,0
     * When re-ordering ONLY the y-axis (0,0 -> 2,2), the coordinate range would become the reverse of input, as shown below
     * 0,2 -> 2,0       0,0 -> 2,0 (WRONG)
     *    0  1  2          0  1  2
     * 0        x       0  x
     * 1     x          1     x
     * 2  x             2        x
     * Trick is - when both axes change - to re-order the coordinates as a pair; when swapping xFrom <> xTo, also swap yFrom <> yTo
     */
}