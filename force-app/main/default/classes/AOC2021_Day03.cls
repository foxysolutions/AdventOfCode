/**
 * Class to support all logic for the third days' challenge!
 * Call as:
 *  AOC2021_Day03 challenge = new AOC2021_Day03( AOC_Base.MODE.EXAMPLE );
 *  challenge.part1();
 *  challenge.part2();
 *
 * @author    Reinier van den Assum (rvandenassum@deloitte.nl)
 * @created   December 2021
 */
public with sharing class AOC2021_Day03 extends AOC_Base{
    private static final String BINARY_0 = '0';
    private static final String BINARY_1 = '1';

    private List<List<String>> inputsParsed;

    public AOC2021_Day03( AOC_Base.MODE runmode ){
        this.runmode = runmode;
        this.setInputLines( 'AOC2021_Day03' );
    }

    public void part1(){
        // Tracking variables
        String gammaRate_mostCommon = '';
        String epsilonRate_leastCommon = '';

        // To allow re-use across methods, without forcing sequence and too much looping, check whether input already parsed
        Boolean constructInputs = ( this.inputsParsed == null );
        if( constructInputs ){
            this.inputsParsed = new List<List<String>>();
        }
        Integer numLines = this.inputLines.size();
        Integer numColumns = ( numLines > 0 ) ? this.inputLines[ 0 ].length() : 0;

        // Loop over all columns; and per row determine the number of 1-valuess
        for( Integer c = 0; c < numColumns; c++ ){
            Integer numOnes = 0;
            for( Integer r = 0, s = inputLines.size(); r < s; r++ ){
                // Make sure in first iteration to parse the binary values to a List<String>
                if( constructInputs ){ this.inputsParsed.add( this.inputLines[ r ].split( '' ) ); }
                // When input value concerns a 1, add to counter
                if( this.inputsParsed[ r ][ c ] == BINARY_1 ){
                    numOnes++;
                }
            }
            // At end of columns (after processing all rows), check which binary value to append to tracking variables
            // Gamma Rate should be appended with the most common binary value of that row, epsilon the least common
            if( numOnes * 2 >= numLines ){
                gammaRate_mostCommon += BINARY_1;
                epsilonRate_leastCommon += BINARY_0;
            } else{
                gammaRate_mostCommon += BINARY_0;
                epsilonRate_leastCommon += BINARY_1;
            }
            if( c == 0 ){ constructInputs = false; }
        }

        // Convert Binary output to Integer and output the product
        Integer gamma = this.binaryToInteger( gammaRate_mostCommon );
        Integer epsilon = this.binaryToInteger( epsilonRate_leastCommon );
        System.debug( '*** Answer part 1: gamma: ' + gamma + ' * epsilon: ' + epsilon + ' = ' + gamma * epsilon );
    }

    public void part2(){
        // When part2() called as first method of this class, make sure inputs are parsed;
        // Note in part1() it a for-loop could be skipped (1N) by including it in the processing, but due to do-while, for part2() this is more effective to prepare upfront
        if( this.inputsParsed == null ){
            List<List<String>> inputsParsed = new List<List<String>>();
            for( Integer i = 0, j = this.inputLines.size(); i < j; i++ ){
                inputsParsed.add( this.inputLines[ i ].split( '' ) );
            }
        }

        Integer oxygenPower = this.getPowerFromInput( inputsParsed.clone(), true );
        Integer co2Power = this.getPowerFromInput( inputsParsed.clone(), false );
        System.debug( '*** Answer part 2: oxygen: ' + oxygenPower + ' * co2Power: ' + co2Power + ' = ' + oxygenPower * co2Power );
    }

        /**
         * Method to loop over all inputs and determine which rows contain 0s and which 1s
         * If highest-wins, remove those who occur the least common; and vice-versa
         * Continue next column till only one row left matching the most/least common values
         *
         * @param inputs        Matrix of binary values
         * @param highestWins   When TRUE the rows will remain with the binary value that occurred most often in that column; FALSE the least often
         *                      Note, when equal number of occurrences with TRUE the 1s continue, with FALSE the 0s continue
         * @return Integer which was represented by the one binary-row which shared the most/least occurrences
         */
        private Integer getPowerFromInput( List<List<String>> inputs, Boolean highestWins ){
            Integer colIndex = 0;
            Integer numColumns = inputs[ 0 ].size();
            do{
                // Determine the line numbers of all 0s and 1s
                Map<String, List<Integer>> rowNumsPerBinaryValue = new Map<String, List<Integer>>{ BINARY_0 => new List<Integer>(), BINARY_1 => new List<Integer>() };
                for( Integer r = 0, s = inputs.size(); r < s; r++ ){
                    rowNumsPerBinaryValue.get( inputs[ r ][ colIndex ] ).add( r );
                }
                // Determine which indices should be removed from the remaining inputs list
                List<Integer> indexes_Ones = rowNumsPerBinaryValue.get( BINARY_1 );
                List<Integer> indexes_Zeros = rowNumsPerBinaryValue.get( BINARY_0 );
                List<Integer> indicesToBeRemoved = ( highestWins )
                    ? ( indexes_Ones.size() >= indexes_Zeros.size() ) ? indexes_Zeros : indexes_Ones
                    : ( indexes_Ones.size() < indexes_Zeros.size() ) ? indexes_Zeros : indexes_Ones;
                // Remove indices from back-to-front to ensure they all exist (when removing front-to-back, all later indices need to be lowered)
                for( Integer i = indicesToBeRemoved.size() - 1, j = 0; i >= j; i-- ){
                    inputs.remove( indicesToBeRemoved[ i ] );
                }
                colIndex++;
            } while( inputs.size() > 1 && colIndex < numColumns );

            // When the single matching input is found, or when the last column was reached, return the first remaining binary-value-input as Integer
            return this.binaryToInteger( String.join( inputs[ 0 ], '' ) );
        }
}