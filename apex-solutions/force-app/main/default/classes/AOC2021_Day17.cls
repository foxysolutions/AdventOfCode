/**
 * Class to support all logic for the 17th days' challenge!
 * Call as:
 *  AOC2021_Day17 challenge = new AOC2021_Day17( AOC_Base.MODE.EXAMPLE );
 *  challenge.part1();
 *  challenge.part2();
 *
 * @author    Reinier van den Assum (rvandenassum@deloitte.nl)
 * @created   December 2021
 */
public with sharing class AOC2021_Day17 extends AOC_Base{
    private List<Integer> RANGE_X;
    private List<Integer> RANGE_Y;
    private List<ValidVelocity> validVelocities = new List<ValidVelocity>();

    public AOC2021_Day17( AOC_Base.MODE runmode ){
        this.runmode = runmode;
        this.setInputLines( 'AOC2021_Day17' );
        // Parse fixed input to know the x- and y-Range where within the probe should land
        List<String> inputSplit = inputLines[ 0 ].remove( 'target area: ' ).split( ',\\s+' ); // target area: x=20..30, y=-10..-5
        RANGE_X = splitStringToIntegers( inputSplit[ 0 ].split( '=' )[ 1 ], '\\.\\.' );
        RANGE_Y = splitStringToIntegers( inputSplit[ 1 ].split( '=' )[ 1 ], '\\.\\.' );

        // Since both parts use exactly the same logic, perform the logic centralised and store required values
        this.determineAllValidVelocitories();
    }

    private void determineAllValidVelocitories(){
        // X can be bound both on Lower and Upperbound:
        // - LowerBound: Given X in-/decreases each iteration, the max reachable X is calculated by N + N-1 + N-2 + ... till 0 (fibonacci)
        //               The sum of these values can be calculated via ( N ( N + 1 ) ) / 2 => ( N² + N ) / 2
        //               Therefore, the strict minimum LowerBound for X can be set to SQUARE_ROOT( 2 * Min-X-Range )
        //               Note, SQRT( N² + N ) will always be between 0.3 - 0.5 (limit) and thus this is a safe lowerbound, when stripping decimal
        // - UpperBound: We shouldn't shoot further than the Max X-Range
        for( Integer x = Integer.valueOf( Math.sqrt( 2 * RANGE_X[ 0 ] ) ); x <= RANGE_X[ 1 ]; x++ ){
            for( Integer y = RANGE_Y[ 0 ]; y < RANGE_Y[ 0 ]*-1; y++ ){
                Coordinate velocityToSimulate = new Coordinate( x, y );
                ValidVelocity simulationResults = this.simulateProbeMovement( velocityToSimulate );
                if( simulationResults != null  ){
                    validVelocities.add( simulationResults );
                }
            }
        }
    }

    public void part1(){
        // Loop over all valid Velocities to determine the one where the probe reached the highest point
        Integer highestPoint = 0;
        for( Integer i = 0, j = validVelocities.size(); i < j; i++ ){
            highestPoint = Math.max( highestPoint, validVelocities[ i ].maxHeight );
        }
        System.debug( '*** Answer part 1: ' + highestPoint );
    }

    public void part2(){
        System.debug( '*** Answer part 2: ' + validVelocities.size() );
    }

    private ValidVelocity simulateProbeMovement( Coordinate velocity ){
        Coordinate startVelocity = velocity.clone();
        Coordinate c = new Coordinate( 0, 0 );
        Integer maxHeight = 0;
        while( c.x <= RANGE_X[ 1 ] && c.y >= RANGE_Y[ 0 ] ){
            this.simulateNextStep( c, velocity );
            if( c.y > maxHeight ){
                maxHeight = c.y;
            }
            if( c.x >= RANGE_X[ 0 ] && c.x <= RANGE_X[ 1 ] && c.y >= RANGE_Y[ 0 ] && c.y <= RANGE_Y[ 1 ] ){
                return new ValidVelocity( startVelocity, maxHeight, c );
            }
        }
        return null;
    }

    private void simulateNextStep( Coordinate probePosition, Coordinate velocity ){
        probePosition.x += velocity.x;
        probePosition.y += velocity.y;
        velocity.x += ( velocity.x > 0 ) ? -1 : ( ( velocity.x < 0 ) ? 1 : 0 );
        velocity.y -= 1;
    }

    private class ValidVelocity{
        public Coordinate velocity;
        public Coordinate landingCoordinate;
        public Integer maxHeight;

        public ValidVelocity( Coordinate v, Integer h, Coordinate c ){
            this.velocity = v;
            this.maxHeight = h;
            this.landingCoordinate = c;
        }
    }
}