/**
 * Class to support all logic for the 9th days' challenge!
 * Call as:
 *  AOC2021_Day09 challenge = new AOC2021_Day09( AOC_Base.MODE.EXAMPLE );
 *  challenge.part1();
 *  challenge.part2();
 *
 * @author    Reinier van den Assum (rvandenassum@deloitte.nl)
 * @created   December 2021
 */
public with sharing class AOC2021_Day09 extends AOC_Base{
    Integer MATRIX_NUM_ROWS;
    Integer MATRIX_NUM_COLS;
    List<List<Integer>> CAVE_HEIGHTMAP = new List<List<Integer>>();
    List<Coordinate> CAVE_LOWPOINTS = new List<Coordinate>();

    private Integer BASIN_MAX_HEIGHT = 8;

    /**
     * Both parts require a parsed height map. Hence, perform in constructor to avoid duplicate code
     */
    public AOC2021_Day09( AOC_Base.MODE runmode ){
        this.runmode = runmode;
        this.setInputLines( 'AOC2021_Day09' );
        this.MATRIX_NUM_ROWS = inputLines.size();
        for( Integer i = 0, j = MATRIX_NUM_ROWS; i < j; i++ ){
            CAVE_HEIGHTMAP.add( this.splitStringToIntegers( inputLines[ i ], '' ) );
        }
        this.MATRIX_NUM_COLS = CAVE_HEIGHTMAP[ 0 ].size();
    }

    public void part1(){
        if( CAVE_LOWPOINTS.isEmpty() ){
            this.findLowestCoordinates();
        }
        Integer sumRiskLevel = 0;
        for( Integer i = 0, j = CAVE_LOWPOINTS.size(); i < j; i++ ){
            Coordinate lowCoord = CAVE_LOWPOINTS[ i ];
            sumRiskLevel += 1 + CAVE_HEIGHTMAP[ lowCoord.x ][ lowCoord.y ];
        }
        System.debug( '*** Answer part 1: ' + sumRiskLevel );
    }

    /**
     * Purpose is to find the three largest basins.
     * A basin is always surrounding a low-point and continues till the moment the next spot is lower than the current,
     * or when the next spot has a height of 9. All other items should be included in the basin.
     */
    public void part2(){
        // When Lowest points aren't known, first calculate those
        if( CAVE_LOWPOINTS.isEmpty() ){
            this.findLowestCoordinates();
        }
        List<Integer> basinSizes = new List<Integer>();
        // Determine basin size for each lowest-cave-point
        for( Integer i = 0, j = CAVE_LOWPOINTS.size(); i < j; i++ ){
            Coordinate lowCoord = CAVE_LOWPOINTS[ i ];

            // Initiate 'worklist' with the first lowCoord and from there start the search till the next spot is lower/9
            List<Coordinate> coordsToCheck = new List<Coordinate>{ lowCoord };
            List<String> coordsProcessed = new List<String>(); // stored as String for easier comparison

            // Loop over all coordinates which are part of the basin, so check whether their adjacent coords should be included as well
            while( !coordsToCheck.isEmpty() ){
                Coordinate currCoord = coordsToCheck.remove( 0 );
                String currCoordString = currCoord.getString();
                // Check whether this coordinate was already processed before, since one coordinate might 'border' with multiple other basin coords
                if( coordsProcessed.contains( currCoordString ) ){
                    continue;
                }
                coordsProcessed.add( currCoordString );

                // Fetch height of current coordinate to compare with all adjacent coordinates
                Integer currHeight = CAVE_HEIGHTMAP[ currCoord.x ][ currCoord.y ];

                // Validate whether the any direction is still higher than the current. If so, add to basin and to list to check their neighbors
                if( currCoord.x > 0 ){
                    validateAndAddNextCoordToBasin( currHeight, currCoord.x - 1, currCoord.y, coordsToCheck );
                }
                if( currCoord.x < MATRIX_NUM_ROWS - 1 ){
                    validateAndAddNextCoordToBasin( currHeight, currCoord.x + 1, currCoord.y, coordsToCheck );
                }
                if( currCoord.y > 0 ){
                    validateAndAddNextCoordToBasin( currHeight, currCoord.x, currCoord.y - 1, coordsToCheck );
                }
                if( currCoord.y < MATRIX_NUM_COLS - 1 ){
                    validateAndAddNextCoordToBasin( currHeight, currCoord.x, currCoord.y + 1, coordsToCheck );
                }
            }
            // After verifying all adjacent coordinates, define the basinSize as the number of 'valid basin coords' which were processed
            basinSizes.add( coordsProcessed.size() );
        }

        // Sort the basins by size to allow fetching the top 3
        basinSizes.sort();
        Integer lastIndex = basinSizes.size() - 1;
        Integer totalSize = basinSizes[ lastIndex - 1 ];
        for( Integer i = lastIndex, j = Math.max( 0, lastIndex - 3 ); i > j; i-- ){
            // Since we multiply values, make sure to add the first one, else 0 * N remains 0...
            totalSize = ( i == lastIndex )
                ? basinSizes[ i ]
                : totalSize * basinSizes[ i ];
        }
        System.debug( '*** Answer part 2: ' + ( lastIndex + 1 ) + ' come to ' + totalSize );
    }

    /**
     * Check whether the next suggested coordinate should be perceived as part of this basin
     * Note, initially did a comparison on .contains() to prevent duplicate values (or Set) but unfortunately inner classes are hard to compare
     *  One could opt to store the coordToCheck as String, though for performance reasons, choice went for one additional loop and excluding the record via coordsProcessed
     * Adjacent coordinate is pare of the basin, when it is higher than the current spot, but not exceeding the max-basin height (8)
     *
     * @param currHeight        Height of the current coordinate to check
     * @param nextX             X-coord of adjacent spot to check
     * @param nextY             Y-coord of adjacent spot to check
     * @param coordsToCheck     List of coordinates which are in queue to be checked
     */
    private void validateAndAddNextCoordToBasin( Integer currHeight, Integer nextX, Integer nextY, List<Coordinate> coordsToCheck ){
        Integer nextHeight = CAVE_HEIGHTMAP[ nextX ][ nextY ];
        if( nextHeight <= BASIN_MAX_HEIGHT && currHeight < nextHeight ){
            coordsToCheck.add( new Coordinate( nextX, nextY ) );
        }
    }

    /**
     * Method to centralise logic for finding lowest coordinates and assigning to a global class attribute.
     * isLowest is determined based on the current height compared to its' neighbors, taking into account grid boundaries.
     * Due to a full-surrounding check, this can only be performed after full-initiation of the matrix
     */
    private void findLowestCoordinates(){
        for( Integer x = 0; x < MATRIX_NUM_ROWS; x++ ){
            for( Integer y = 0; y < MATRIX_NUM_COLS; y++ ){
                Integer currHeight = CAVE_HEIGHTMAP[ x ][ y ];
                Boolean isLowest =
                     ( ( ( x > 0 )                   ? currHeight < CAVE_HEIGHTMAP[ x - 1 ][ y ] : TRUE ) // comparing up
                    && ( ( x < MATRIX_NUM_ROWS - 1 ) ? currHeight < CAVE_HEIGHTMAP[ x + 1 ][ y ] : TRUE ) // comparing down
                    && ( ( y > 0 )                   ? currHeight < CAVE_HEIGHTMAP[ x ][ y - 1 ] : TRUE ) // comparing left
                    && ( ( y < MATRIX_NUM_COLS - 1 ) ? currHeight < CAVE_HEIGHTMAP[ x ][ y + 1 ] : TRUE ) );// comparing right

                if( isLowest ){
                    CAVE_LOWPOINTS.add( new Coordinate( x, y ) );
                }
            }
        }
    }

    /**
     * Inner Coordinate class to easily 'share' x-y coords without need of String manipulations (split, etc.) and casting (to Integer)
     */
    private class Coordinate{
        private Integer x;
        private Integer y;
        public Coordinate( Integer xInput, Integer yInput ){
            this.x = xInput;
            this.y = yInput;
        }

        public String getString(){
            return this.x + ',' + this.y;
        }
    }
}