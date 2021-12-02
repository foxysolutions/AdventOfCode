/**
 * Class to support all logic for the first days' challenge!
 * Call as:
 *  AOC21_Day01 challenge = new AOC21_Day01( AOC_Base.MODE.EXAMPLE );
 *  challenge.part1();
 *  challenge.part2();
 *
 * @author    Reinier van den Assum (rvandenassum@deloitte.nl)
 * @created   December 2021
 */
public with sharing class AOC21_Day01 extends AOC_Base{
    public AOC21_Day01( AOC_Base.MODE runmode ){
        this.runmode = runmode;
        this.setInputLines( 'AOC2021_Day1' );
    }

    public void part1(){
        // Result variable
        Integer numIncreases = 0;

        // Loop over input, keeping track of previous number (hence, skipping first one)
        Integer previousNumber = Integer.valueOf( inputLines[ 0 ] );
        for( Integer i = 1, j = this.inputLines.size(); i < j; i++ ){
            // Compare current lineNumber with previous one, when larger, increment counter
            Integer lineNumber = Integer.valueOf( inputLines[ i ] );
            if( lineNumber > previousNumber ){
                numIncreases++;
            }
            // Always set current number as previous before next iteration
            previousNumber = lineNumber;
        }

        System.debug( '*** Answer part 1: '+ numIncreases );
    }

    public void part2(){
        // Result variable
        Integer numIncreases = 0;

        // Construct attributes to keep track of previous and next window-total; allowing variable window sizing
        Integer windowSize = 3;
        Integer numLinesInput = this.inputLines.size();
        windowSize = Math.min( windowSize, numLinesInput ); // avoid list-index out of bounds

        List<Integer> integerInputs = new List<Integer>(); // Copy of yet parsed input, to prevent too much casting ( Integer.valueOf() )
        Integer previousWindowTotal = 0;
        Integer newWindowTotal = 0;
        // Construct total of first measurement window
        for( Integer i = 0, j = windowSize; i < j; i++ ){
            Integer lineNumber = Integer.valueOf( inputLines[ i ] );
            previousWindowTotal += lineNumber;
            integerInputs.add( lineNumber );
        }
        // Continue with first value after first-measurement-window to construct new Window (subtract 'out of scope' and add new value)
        for( Integer i = windowSize, j = this.inputLines.size(); i < j; i++ ){
            Integer lineNumber = Integer.valueOf( inputLines[ i ] );
            integerInputs.add( lineNumber );
            newWindowTotal = previousWindowTotal + lineNumber - integerInputs[ i - windowSize ];

            // Compare current lineNumber with previous one, when larger, increment counter
            if( newWindowTotal > previousWindowTotal ){
                numIncreases++;
            }
            // Always set current total as previous before next iteration
            previousWindowTotal = newWindowTotal;
        }

        System.debug( '*** Answer part 2: '+ numIncreases );
    }
}