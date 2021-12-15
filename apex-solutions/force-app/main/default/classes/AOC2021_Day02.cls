/**
 * Class to support all logic for the seconds days' challenge!
 * Call as:
 *  AOC2021_Day02 challenge = new AOC2021_Day02( AOC_Base.MODE.EXAMPLE );
 *  challenge.part1();
 *  challenge.part2();
 *
 * @author    Reinier van den Assum (rvandenassum@deloitte.nl)
 * @created   December 2021
 */
public with sharing class AOC2021_Day02 extends AOC_Base{
    private final static String MOVEMENT_FORWARD = 'forward';
    private final static String MOVEMENT_DOWN = 'down';
    private final static String MOVEMENT_UP = 'up';
    private static final String MOVEMENT_SPLIT = ' ';

    public AOC2021_Day02( AOC_Base.MODE runmode ){
        this.runmode = runmode;
        this.setInputLines( 'AOC2021_Day02' );
    }

    public void part1(){
        // Result variables
        Integer horizontal = 0, depth = 0;

        // Loop over input
        for( Integer i = 0, j = this.inputLines.size(); i < j; i++ ){
            // Split line by space to get the movement direction and the movement units
            List<String> movementSplit = inputLines[ i ].split( MOVEMENT_SPLIT );
            String direction = movementSplit[ 0 ];
            Integer units = Integer.valueOf( movementSplit[ 1 ] ); // Note, might throw an Exception

            if( String.isBlank( direction ) ){
                throw new InvalidDataException( 'No Direction set for line '+ i + 1 + ': '+ movementSplit );
            } else if( direction.equalsIgnoreCase( MOVEMENT_FORWARD ) ){
                horizontal += units;
            } else if( direction.equalsIgnoreCase( MOVEMENT_DOWN ) ){
                depth += units; // Note, when going down, depth increases
            } else if( direction.equalsIgnoreCase( MOVEMENT_UP ) ){
                depth -= units;
            }
        }

        System.debug( '*** Final position: '+ horizontal + ' at depth of '+ depth );
        System.debug( '*** Answer part 1: '+ horizontal * depth );
    }

    public void part2(){
        // Result variables
        Integer horizontal = 0, depth = 0, aim = 0;

        // Loop over input
        for( Integer i = 0, j = this.inputLines.size(); i < j; i++ ){
            // Split line by space to get the movement direction and the movement units
            List<String> movementSplit = inputLines[ i ].split( MOVEMENT_SPLIT );
            String direction = movementSplit[ 0 ];
            Integer units = Integer.valueOf( movementSplit[ 1 ] ); // Note, might throw an Exception

            if( String.isBlank( direction ) ){
                throw new InvalidDataException( 'No Direction set for line '+ i + 1 + ': '+ movementSplit );
            } else if( direction.equalsIgnoreCase( MOVEMENT_FORWARD ) ){
                horizontal += units;
                depth += ( aim * units );
            } else if( direction.equalsIgnoreCase( MOVEMENT_DOWN ) ){
                aim += units;
            } else if( direction.equalsIgnoreCase( MOVEMENT_UP ) ){
                aim -= units;
            }
        }

        System.debug( '*** Final position: '+ horizontal + ' at depth of '+ depth );
        System.debug( '*** Answer part 2: '+ horizontal * depth );
    }
}