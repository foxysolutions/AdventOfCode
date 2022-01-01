/**
 * Class to support all logic for the 15th days' challenge!
 * Call as:
 *  AOC2021_Day15 challenge = new AOC2021_Day15( AOC_Base.MODE.EXAMPLE );
 *  challenge.prepare_input_part1();
 *  // Also attempted to prepare for part2() (25 times original), but that caused CPU Timeouts both Sync and Async
 *
 * @author    Reinier van den Assum (rvandenassum@deloitte.nl)
 * @created   December 2021
 */
public with sharing class AOC2021_Day15 extends AOC_Base{
    private final String COORD_SEP = '-';

    public AOC2021_Day15( AOC_Base.MODE runmode ){
        this.runmode = runmode;
        this.setInputLines( 'AOC2021_Day15' );
    }

    /**
     * Initial approach for part1() was to construct the Graph in Apex, paste that to JS and then run Dijkstra
     * However, for re-usability, in the end the Graph construction was also implemented in JS
     */
    public void prepare_input_part1(){
        Map<String, Map<String, Integer>> costGraph = new Map<String, Map<String, Integer>>();
        List<List<Integer>> riskLevelMatrix = new List<List<Integer>>();
        for( Integer i = 0, j = inputLines.size(); i < j; i++ ){
            riskLevelMatrix.add( this.splitStringToIntegers( inputLines[ i ], '' ) );
        }

        Integer numRows = riskLevelMatrix.size();
        Integer numCols = riskLevelMatrix[ 0 ].size();
        for( Integer y = 0; y < numRows; y++ ){
            for( Integer x = 0; x < numCols; x++ ){
                String currCoordinate = x + COORD_SEP + y;
                Integer currRisk = riskLevelMatrix[ y ][ x ];
                if( x > 0 ){
                    addToCostGraph( costGraph, ( ( x - 1 ) + COORD_SEP + y ), currCoordinate, currRisk );
                }
                if( x < numCols - 1 ){
                    addToCostGraph( costGraph, ( ( x + 1 ) + COORD_SEP + y ), currCoordinate, currRisk );
                }
                if( y > 0 ){
                    addToCostGraph( costGraph, ( x + COORD_SEP + ( y - 1 ) ), currCoordinate, currRisk );
                }
                if( y < numRows - 1 ){
                    addToCostGraph( costGraph, ( x + COORD_SEP + ( y + 1 ) ), currCoordinate, currRisk );
                }
            }
        }
        System.debug( '*** Cost Graph JSON Input part 1: ' + JSON.serialize( costGraph ) );
    }

    private void addToCostGraph( Map<String, Map<String, Integer>> costGraph, String fromCoordinate, String toCoordinate, Integer cost ){
        Map<String, Integer> toCostNodes = costGraph.get( fromCoordinate );
        if( toCostNodes == null ){
            costGraph.put( fromCoordinate, new Map<String, Integer>{ toCoordinate => cost } );
        } else if( !toCostNodes.containsKey( toCoordinate ) ){
            toCostNodes.put( toCoordinate, cost );
        } else{
            System.debug( '*** Something went wrong! '+ fromCoordinate + ' and '+ toCoordinate + ' were already in the Graph!?' );
        }
    }
}