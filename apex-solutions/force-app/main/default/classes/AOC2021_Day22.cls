/**
 * Class to support all logic for the 22th days' challenge!
 * Call as:
 *  AOC2021_Day22 challenge = new AOC2021_Day22( AOC_Base.MODE.EXAMPLE );
 *  challenge.part1();
 *  challenge.part2();
 *
 * @author    Reinier van den Assum (rvandenassum@deloitte.nl)
 * @created   December 2021
 */
public with sharing class AOC2021_Day22 extends AOC_Base{
    public AOC2021_Day22( AOC_Base.MODE runmode ){
        this.runmode = runmode;
        this.setInputLines( 'AOC2021_Day22' );
    }

    /**
     * Original code for part1(), calculating the number of active coordinates by simply adding and removing the unique coordinate string
     * With restriction of only -50, 50 on all axis this was already exceeding the Synchronous Apex CPU limit
     * Could have rewritten this to utilise efficiencies in part2(), by enriching the getNumCoordinates() by a 'withinCube'-parameter,
     * but thought would be easier to leave it like this and focus on the next challenge.
     */
    public void part1(){
        System.debug( '*** Executing Async since both Example and Input weren\'t possible within 10 Sync seconds' );
        AOC2021_Day22.part1_Async();
    }
    @Future
    public static void part1_Async(){
        AOC2021_Day22 inst = new AOC2021_Day22( MODE.FOR_REAL );
        inst.performPart1();
    }
    public void performPart1(){
        Integer minValue = -50;
        Integer maxValue = 50;
        Set<String> onCubes = new Set<String>();
        // Loop over input lines and determine whether to turn on or off
        for( Integer i = 0, j = inputLines.size(); i < j; i++ ){
            List<String> str = inputLines[ i ].split( ' ' );
            List<String> coordRanges = str[ 1 ].split( '\\,' );
            List<Integer> xRange = this.splitStringToIntegers( coordRanges[ 0 ].split( '=' )[ 1 ], '\\.\\.' );
            List<Integer> yRange = this.splitStringToIntegers( coordRanges[ 1 ].split( '=' )[ 1 ], '\\.\\.' );
            List<Integer> zRange = this.splitStringToIntegers( coordRanges[ 2 ].split( '=' )[ 1 ], '\\.\\.' );

            // Loop over the coords of interest and add or remove from turned-on-cubes-list
            for( Integer x = Math.max( minValue, xRange[ 0 ] ), xMax = Math.min( maxValue, xRange[ 1 ] ); x <= xMax; x++ ){
                for( Integer y = Math.max( minValue, yRange[ 0 ] ), yMax = Math.min( maxValue, yRange[ 1 ] ); y <= yMax; y++ ){
                    for( Integer z = Math.max( minValue, zRange[ 0 ] ), zMax = Math.min( maxValue, zRange[ 1 ] ); z <= zMax; z++ ){
                        String coordString = x + ',' + y + ',' + z;
                        if( str[ 0 ] == 'on' ){
                            onCubes.add( coordString );

                        } else if( str[ 0 ] == 'off' ){
                            onCubes.remove( coordString );

                        } else{
                            throw new InvalidDataException( 'No valid action provided ' + str[ 0 ] );
                        }
                    }
                }
            }
        }

        System.debug( '*** Answer part 1: ' + onCubes.size() );
    }

    // Luckily no need to perform Async, as Real Input (420 actions) executes in 9-10sec; and Example (60 actions) in 300-400ms
    public void part2(){
        List<Cube> distinctCubes = new List<Cube>();

        // Loop over input lines and determine whether to turn on or off
        for( Integer i = 0, j = inputLines.size(); i < j; i++ ){
            List<String> inputStr = inputLines[ i ].split( ' ' );
            List<String> coordRanges = inputStr[ 1 ].split( '\\,' );
            // Construct the input cube based on String ranges provided by input
            Cube inputCube = new Cube(
                this.splitStringToIntegers( coordRanges[ 0 ].split( '=' )[ 1 ], '\\.\\.' ),
                this.splitStringToIntegers( coordRanges[ 1 ].split( '=' )[ 1 ], '\\.\\.' ),
                this.splitStringToIntegers( coordRanges[ 2 ].split( '=' )[ 1 ], '\\.\\.' )
            );

            // Loop over all existing cubes and split cubes to ensure there are no shared ranges with new input cube
            // Afterwards, only add the new one if requested (else, the split already ensured the overlap is removed/avoided)
            List<Cube> newDistinctCubes = new List<Cube>();
            for( Integer c = 0, numCubes = distinctCubes.size(); c < numCubes; c++ ){
                newDistinctCubes.addAll( distinctCubes[ c ].splitToNotOverlapWith( inputCube ) );
            }
            // Add the input cube when those coordinates should be 'on'
            if( inputStr[ 0 ] == 'on' ){
                newDistinctCubes.add( inputCube );
            }
            distinctCubes = newDistinctCubes;
        }

        Long numCubes = 0;
        for( Integer i = 0, j = distinctCubes.size(); i < j; i++ ){
            Cube c = distinctCubes[ i ];
            Long numCoords = c.getNumCoordinates();
            numCubes += numCoords;
        }

        System.debug( '*** Answer part 2: ' + numCubes );
    }
}