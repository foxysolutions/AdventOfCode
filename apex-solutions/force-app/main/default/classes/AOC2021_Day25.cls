/**
 * Class to support all logic for the 25th days' challenge!
 * Call as:
 *  AOC2021_Day25 challenge = new AOC2021_Day25( AOC_Base.MODE.EXAMPLE );
 *  challenge.part1();
 *
 * @author    Reinier van den Assum (rvandenassum@deloitte.nl)
 * @created   December 2021
 */
public with sharing class AOC2021_Day25 extends AOC_Base{
    private final String CUCUMBER_FACING_EAST = '>';
    private final String CUCUMBER_FACING_SOUTH = 'v';

    public AOC2021_Day25( AOC_Base.MODE runmode ){
        this.runmode = runmode;
        this.setInputLines( 'AOC2021_Day25' );
    }

    enum DIRECTION {
        EAST,
        SOUTH
    }

    private class CucumberSpot{
        public DIRECTION dir;
        public Coordinate currPosition;
        public Integer matrixWidth, matrixHeight;

        public CucumberSpot( Coordinate curr, DIRECTION dir, Integer w, Integer h ){
            this.currPosition = curr;
            this.dir = dir;
            this.matrixWidth = w;
            this.matrixHeight = h;
        }

        public Boolean performStep( Set<String> coordList, Set<String> startIterationCoordList ){
            Coordinate nextCoord = ( this.dir == DIRECTION.EAST )
                ? new Coordinate( Math.mod( this.currPosition.x + 1, matrixWidth ), this.currPosition.y )
                : new Coordinate( this.currPosition.x, Math.mod( this.currPosition.y + 1, matrixHeight ) );
            // If there is no item yet
            if( !startIterationCoordList.contains( nextCoord.getString() ) ){
                coordList.remove( this.currPosition.getString() );
                coordList.add( nextCoord.getString() );
                this.currPosition = nextCoord;
                return true;
            }
            return false;
        }
    }

    public void part1(){
        System.debug( '*** Performing Async, but no response expected due to CPU Timeout' );
        AOC2021_Day25.part1_Async();
    }

    @Future
    public static void part1_Async(){
        AOC2021_Day25 inst = new AOC2021_Day25( MODE.FOR_REAL );
        inst.performPart1();
    }

    public void performPart1(){
        Set<String> cucumberPerCoord = new Set<String>();
        List<CucumberSpot> cucumbersEast = new List<CucumberSpot>();
        List<CucumberSpot> cucumbersSouth = new List<CucumberSpot>();

        // Added from topleft to bottom right to ensure the most left one will always check first
        for( Integer y = 0, yMax = inputLines.size(); y < yMax; y++ ){
            List<String> inputRow = inputLines[ y ].split( '' );
            for( Integer x = 0, xMax = inputRow.size(); x < xMax; x++ ){
                String coordValue = inputRow[ x ];
                if( coordValue != '.' ){
                    Coordinate c = new Coordinate( x, y );
                    DIRECTION d = ( coordValue.equals( CUCUMBER_FACING_EAST ) ) ? DIRECTION.EAST : DIRECTION.SOUTH;
                    CucumberSpot cuc = new CucumberSpot( c, d, xMax, yMax );
                    cucumberPerCoord.add( c.getString() );
                    if( d == DIRECTION.EAST ){
                        cucumbersEast.add( cuc );
                    } else if( d == DIRECTION.SOUTH ){
                        cucumbersSouth.add( cuc );
                    }
                }
            }
        }

        Integer iteration = 0;
        Boolean cucumberMoved;
        do{
            cucumberMoved = false;
            Set<String> startState = cucumberPerCoord.clone();
            for( Integer i = 0, j = cucumbersEast.size(); i < j; i++ ){
                if( cucumbersEast[ i ].performStep( cucumberPerCoord, startState ) ){
                    cucumberMoved = true;
                }
            }
            // reset state to make sure all East steps are already taken into account;
            startState = cucumberPerCoord.clone();
            for( Integer i = 0, j = cucumbersSouth.size(); i < j; i++ ){
                if( cucumbersSouth[ i ].performStep( cucumberPerCoord, startState ) ){
                    cucumberMoved = true;
                }
            }
            iteration++;
        } while( cucumberMoved );

        System.debug( '*** Answer part 1: ' + iteration );
    }
}