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
        Map<String, Integer> occurrencePerCoordinate = new Map<String, Integer>();

        for( Integer i = 0, j = inputLines.size(); i < j; i++ ){
            String str = inputLines[ i ];
            List<String> coordinates = str.split( ' -> ' );
            List<Integer> coordinatesFrom = this.splitStringToIntegers( coordinates[ 0 ], ',' );
            List<Integer> coordinatesTo = this.splitStringToIntegers( coordinates[ 1 ], ',' );

            // Requirement is that vents only count when non-diagonal (so when one of axis are equal)
            Boolean xAxisMatch = coordinatesFrom[ 0 ] == coordinatesTo[ 0 ];
            Boolean yAxisMatch = coordinatesFrom[ 1 ] == coordinatesTo[ 1 ];
            if( xAxisMatch || yAxisMatch ){

                // Determine the axis which is fixed for this input and which we need to 'loop over'
                Integer baseCoord = ( xAxisMatch ) ? coordinatesFrom[ 0 ] : coordinatesFrom[ 1 ];
                Integer fromCoord = ( xAxisMatch ) ? coordinatesFrom[ 1 ] : coordinatesFrom[ 0 ];
                Integer toCoord = ( xAxisMatch ) ? coordinatesTo[ 1 ] : coordinatesTo[ 0 ];
                // Since the vent might 'go backward' on this axis, correct to simplify logic of looping to always increase. Hence, swap coords
                if( fromCoord > toCoord ){
                    Integer originalFrom = fromCoord;
                    fromCoord = toCoord;
                    toCoord = originalFrom;
                }
                for( ; fromCoord <= toCoord; fromCoord++ ){
                    String nextCoord = ( xAxisMatch )
                        ? baseCoord + ',' + fromCoord
                        : fromCoord + ',' + baseCoord;
                    this.increaseCounterWithKey( occurrencePerCoordinate, nextCoord );
                }
            }
        }

        // Loop over the 'dummy matrix' where the number of overlap is 2+
        Integer count = 0;
        for( Integer numOccurrences : occurrencePerCoordinate.values() ){
            if( numOccurrences > 1 ){
                count++;
            }
        }

        System.debug( '*** Answer part 1: '+ count );
    }

    public void part2(){
        Map<String, Integer> occurrencePerCoordinate = new Map<String, Integer>();

        for( Integer i = 0, j = inputLines.size(); i < j; i++ ){
            String str = inputLines[ i ];
            List<String> coordinates = str.split( ' -> ' );
            List<Integer> coordinatesFrom = this.splitStringToIntegers( coordinates[ 0 ], ',' );
            List<Integer> coordinatesTo = this.splitStringToIntegers( coordinates[ 1 ], ',' );

            // Initially tried to make sure all axis would only increase, but with the 0,2 -> 2,0 example, this would cause the wrong coordinates
            //    0  1  2
            // 0        x
            // 1     x
            // 2  x
            // When having both axis to increase, this would invalidate the input to become 0,0 -> 2,2 which is the reverse structure
            // Hence, logic restrict to only order the x-axis to increase to simplify loop-structure, but if so, swap y-axis as well
            Integer xFrom = coordinatesFrom[ 0 ];
            Integer xTo = coordinatesTo[ 0 ];
            Integer yFrom = coordinatesFrom[ 1 ];
            Integer yTo = coordinatesTo[ 1 ];
            if( xFrom > xTo ){
                Integer xBase = xFrom;
                xFrom = xTo;
                xTo = xBase;
                Integer yBase = yFrom;
                yFrom = yTo;
                yTo = yBase;
            }

            // Construct the coordinates in the given input-range and increase the 'danger' on that coordinate
            // Note, there is slight different behaviour regarding horizontal & vertical vs. diagonal
            // > When one of the axis doesn't change (horizontal or vertical, resp.) you want to loop over all the values in other axe (e.g. 0,0 -> 0,2 => 0,0; 0,1; 0,2)
            // > When both axis change (diagonal), you want to increase/decrease each time and NOT loop all values (e.g. 0,0 -> 2,2 => 0,0; 1,1; 2;2)
            //      and NOT (0,0; 0,1; 0,2; 1,0; 1,1; 1,2; 2,0; 2,1; 2,2)
            Boolean horizontalMovement = xFrom != xTo;
            for( ; xFrom <= xTo; xFrom++ ){
                Boolean yAxisHasNextCoordinate = true;
                Boolean yAxisIncrease = ( yFrom <= yTo );
                do{
                    String nextCoord = xFrom + ',' + yFrom;
                    this.increaseCounterWithKey( occurrencePerCoordinate, nextCoord );

                    // Increase y-Axis if needed, but ONLY if needed, otherwise next x-iteration becomes invalid
                    if( yAxisIncrease ){
                        yAxisHasNextCoordinate = ( yFrom < yTo );
                        if( yAxisHasNextCoordinate ){ yFrom++; }
                    } else{
                        yAxisHasNextCoordinate = ( yFrom > yTo );
                        if( yAxisHasNextCoordinate ){ yFrom--; }
                    }
                } while( yAxisHasNextCoordinate && !horizontalMovement );
            }
        }

        // Loop over the 'dummy matrix' where the number of overlap is 2+
        Integer count = 0;
        for( Integer numOccurrences : occurrencePerCoordinate.values() ){
            if( numOccurrences > 1 ){
                count++;
            }
        }

        System.debug( '*** Answer part 2: '+ count );
    }

    private void increaseCounterWithKey( Map<String, Integer> countMap, String key ){
        Integer currentValue = countMap.get( key );
        if( currentValue == null ){ currentValue = 0; }
        countMap.put( key, currentValue+1 );
    }
}