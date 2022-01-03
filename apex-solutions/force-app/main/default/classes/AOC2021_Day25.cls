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

    enum DIRECTION{
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

        System.debug( '*** Input is processed and Queueable will be triggered to handle logic Asynchronous' );
        System.enqueueJob( new Queue_SeaCucumberMovement( cucumberPerCoord, cucumbersEast, cucumbersSouth, 0 ) );
    }

    public void part2(){
        System.debug( '*** Note, todays\' puzzle has no part2(), it\'s time for Christmas!' );
    }

    public class Queue_SeaCucumberMovement implements Queueable{
        Integer iteration;
        Set<String> cucumberPerCoord = new Set<String>();
        List<CucumberSpot> cucumbersEast = new List<CucumberSpot>();
        List<CucumberSpot> cucumbersSouth = new List<CucumberSpot>();
        Integer MAX_CPU_LIMIT;

        /**
         * Constructor for Queueable class to allow continuation at a certain stage
         */
        public Queue_SeaCucumberMovement( Set<String> cucumberPerCoord, List<CucumberSpot> cucumbersEast, List<CucumberSpot> cucumbersSouth, Integer iterCount ){
            this.cucumberPerCoord = cucumberPerCoord;
            this.cucumbersEast = cucumbersEast;
            this.cucumbersSouth = cucumbersSouth;
            this.iteration = iterCount;
            System.debug( '*** New Instance: iteration ' + this.iteration + '; ' +
                'cucumbersEast ' + this.cucumbersEast.size() + '; ' +
                'cucumbersSouth ' + this.cucumbersSouth.size() + '; ' +
                'total Coords ' + this.cucumberPerCoord.size() );
        }

        public void execute( QueueableContext ctx ){
            Long start = System.now().getTime();
            // Only define CPU Limit within Execute() as initiation is initially performed in Synchronous mode (thus 10s instead of 60s)
            this.MAX_CPU_LIMIT = Limits.getLimitCpuTime();

            Boolean cucumberMoved;
            do{
                // First verify whether there is sufficient time left for next iteration
                Long currDuration = System.now().getTime() - start;
                if( currDuration >= this.MAX_CPU_LIMIT * 0.99 ){ // Each iteration takes about approx. 600 sec, thus 1% should be saved as backup
                    System.debug( '*** Ending current Queueable and triggering new one ' + currDuration + '/' + MAX_CPU_LIMIT );
                    System.enqueueJob( new Queue_SeaCucumberMovement( this.cucumberPerCoord, this.cucumbersEast, this.cucumbersSouth, this.iteration ) );
                    return;
                }

                cucumberMoved = false;
                // Set state to make sure one East-step in this iteration doesn't effect a later East-Moving Sea Cucumber in the same iteration
                Set<String> startState = cucumberPerCoord.clone();
                for( Integer i = 0, j = cucumbersEast.size(); i < j; i++ ){
                    if( cucumbersEast[ i ].performStep( cucumberPerCoord, startState ) ){
                        cucumberMoved = true;
                    }
                }
                // Reset state to make sure all East steps are already taken into account;
                startState = cucumberPerCoord.clone();
                for( Integer i = 0, j = cucumbersSouth.size(); i < j; i++ ){
                    if( cucumbersSouth[ i ].performStep( cucumberPerCoord, startState ) ){
                        cucumberMoved = true;
                    }
                }
                iteration++;
            } while( cucumberMoved );

            System.debug( '*** Answer part 1: ' + iteration );
            System.debug( '*** Completed in ' + ( System.now().getTime() - start ) );
        }
    }
}
/**
DEBUG LOGS when running part1() for Real data:

Anonymous Apex:
*** Input is processed and Queueable will be triggered to handle logic Asynchronous
*** New Instance: iteration 0; cucumbersEast 4730; cucumbersSouth 4727; total Coords 9457
*** Completed in 1091

First Queueable:
*** Ending current Queueable and triggering new one 59470/60000
*** New Instance: iteration 112; cucumbersEast 4730; cucumbersSouth 4727; total Coords 9457

Second Queueable:
*** Ending current Queueable and triggering new one 59429/60000
*** New Instance: iteration 244; cucumbersEast 4730; cucumbersSouth 4727; total Coords 9457

Third Queueable:
*** Ending current Queueable and triggering new one 59832/60000
*** New Instance: iteration 359; cucumbersEast 4730; cucumbersSouth 4727; total Coords 9457

Fourth Queueable:
*** Answer part 1: 435
*** Completed in 31573
*/