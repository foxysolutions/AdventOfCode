/**
 * Class to support all logic for the 13th days' challenge!
 * Call as:
 *  AOC2021_Day13 challenge = new AOC2021_Day13( AOC_Base.MODE.EXAMPLE );
 *  challenge.part1();
 *  challenge.part2();
 *
 * @author    Reinier van den Assum (rvandenassum@deloitte.nl)
 * @created   December 2021
 */
public with sharing class AOC2021_Day13 extends AOC_Base{
    Map<String, Coordinate> INPUT_COORDINATES = new Map<String, Coordinate>();
    List<FoldingAction> FOLDING_WORKLIST = new List<FoldingAction>();

    public AOC2021_Day13( AOC_Base.MODE runmode ){
        this.runmode = runmode;
        this.setInputLines( 'AOC2021_Day13' );
        // Since both methods require the input-coordinates to already be interpreted and have the 'worklist' of folding actions
        // below method processes input and allows each method to determine their own folding and output strategy
        this.processInput();
    }

    public void part1(){
        // Make a copy of the constructed input
        Map<String, Coordinate> coordsMap = ( Map<String, Coordinate> ) JSON.deserializeStrict( JSON.serialize( INPUT_COORDINATES ), Map<String, Coordinate>.class );
        // Complete ONLY the first folding request!
        this.performFoldingAction( FOLDING_WORKLIST[ 0 ], coordsMap );
        System.debug( '*** Answer part 1: ' + coordsMap.size() );
    }

    public void part2(){
        // Make a copy of the constructed input
        Map<String, Coordinate> coordsMap = ( Map<String, Coordinate> ) JSON.deserializeStrict( JSON.serialize( INPUT_COORDINATES ), Map<String, Coordinate>.class );
        // Loop over and perform all folding requests to existing coordinates
        for( Integer i = 0, j = FOLDING_WORKLIST.size(); i < j; i++ ){
            this.performFoldingAction( FOLDING_WORKLIST[ i ], coordsMap );
        }
        // Dump it to detect which 8 uppercase characters are shown!
        System.debug( '*** Answer part 2: ' );
        this.displayListCoordinates( coordsMap.values(), 'o', ' ', true );
    }

    private void processInput(){
        Boolean processingCoordInput = true;
        for( Integer i = 0, j = inputLines.size(); i < j; i++ ){
            String inputStr = inputLines[ i ];
            // When blank line - change from processing coordinates to processing folding-actions
            if( String.isBlank( inputStr ) ){
                processingCoordInput = false;

            // When processing a coordinate, construct Coordinate and store based on coordString to allow easier comparison (removal etc)
            } else if( processingCoordInput ){
                INPUT_COORDINATES.put( inputStr, new Coordinate( inputStr ) );

            // When processing folding action line, convert once to a easy-to-use structure to prevent duplicate processing
            } else{
                FOLDING_WORKLIST.add( new FoldingAction( inputStr ) );
            }
        }
    }

    /**
     * Method to apply the FoldingAction as provided to the input to the existing coordinates Map
     * When folding a paper, the paper reduces in size (comparable to when cutting the paper, but then consolidating the overlaying data)
     * Hence, for simplicity, (0,0) is seen as the base of the paper, to avoid determining the new (0,0) after each fold
     * Thus, only coordinates 'after' the folding-axis are 'affected'
     *   0 1 2 3        >           0 1 2 3
     * 0   x      (0,3) > (0,1)   0   x   x
     * 1     x    (3,4) > (3,0)   1 x   x
     * 2 -------
     * 3 x
     * 4       x
     *
     * 1) For all coordinates 'after' the folding-axis (compared to 0,0 as start) apply the folding
     * 2) New coordinate is calculating by calculating the same delta from the folding-axis-number as before, to the other side
     *      newX = n - ( x - n ) = n - x + n = 2n - x
     * 3) Remove old coordinate (as paper is 'cut') and add the newly constructed coordinate
     */
    private void performFoldingAction( FoldingAction action, Map<String, Coordinate> coordsMap ){
        List<Coordinate> originalCoordinates = coordsMap.values();
        for( Coordinate coord : originalCoordinates ){
            Integer delta = ( action.axisName == 'x' ) ? coord.x - action.axisNum : coord.y - action.axisNum;
            if( delta > 0 ){
                String originalCoord = coord.getString();
                if( action.axisName == 'x' ){
                    coord.x = action.axisNum - delta;
                } else if( action.axisName == 'y' ){
                    coord.y = action.axisNum - delta;
                }
                coordsMap.remove( originalCoord );
                coordsMap.put( coord.getString(), coord );
            }
        }
    }

    /**
     * Simple inner class to allow easy grouping of folding-axis name and number and allowing to centralise parsing
     * Note, when left in the method itself, one would have required to split first Action both for part1() and part2()
     */
    private class FoldingAction{
        public String axisName;
        public Integer axisNum;

        public FoldingAction( String actionString ){
            List<String> action = actionString.removeStart( 'fold along ' ).split( '=' );
            this.axisName = action[ 0 ];
            this.axisNum = Integer.valueOf( action[ 1 ] );
        }
    }
}