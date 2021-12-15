/**
 * Class to support all logic for the 8th days' challenge!
 * Call as:
 *  AOC2021_Day08 challenge = new AOC2021_Day08( AOC_Base.MODE.EXAMPLE );
 *  challenge.part1();
 *  challenge.part2();
 *
 * @author    Reinier van den Assum (rvandenassum@deloitte.nl)
 * @created   December 2021
 */
public with sharing class AOC2021_Day08 extends AOC_Base{
    private static final Map<String, List<Integer>> INDICES_PER_DIGIT = new Map<String, List<Integer>>{
        '1' => new List<Integer>{ 2, 5 }, // 2
        '7' => new List<Integer>{ 0, 2, 5 }, // 3
        '4' => new List<Integer>{ 1, 2, 3, 5 }, // 4
        '2' => new List<Integer>{ 0, 2, 3, 4, 6 }, // 5
        '3' => new List<Integer>{ 0, 2, 3, 5, 6 }, // 5
        '5' => new List<Integer>{ 0, 1, 3, 5, 6 }, // 5
        '0' => new List<Integer>{ 0, 1, 2, 4, 5, 6 }, // 6
        '6' => new List<Integer>{ 0, 1, 3, 4, 5, 6 }, // 6
        '9' => new List<Integer>{ 0, 1, 2, 3, 5, 6 }, // 6
        '8' => new List<Integer>{ 0, 1, 2, 3, 4, 5, 6 } // 7
    };

    private static final Map<Integer, String> LENGTH_PER_TRACEABLEDIGIT = new Map<Integer, String>{
        2 => '1',
        3 => '7',
        4 => '4',
        7 => '8'
    };

    public AOC2021_Day08( AOC_Base.MODE runmode ){
        this.runmode = runmode;
        this.setInputLines( 'AOC2021_Day08' );
    }

    public void part1(){
        Integer numberTracableOutputDigits = 0;
        Set<Integer> tracableLenghts = LENGTH_PER_TRACEABLEDIGIT.keySet();
        for( Integer i = 0, j = inputLines.size(); i < j; i++ ){
            List<String> input = inputLines[ i ].split ( '\\|' );
            List<String> outputDigits = input[ 1 ].trim().split( ' ' );
            for( Integer d = 0, e = outputDigits.size(); d < e; d++ ){
                if( tracableLenghts.contains( outputDigits[ d ].length() ) ){
                    numberTracableOutputDigits++;
                }
            }
        }
        System.debug( '*** Answer part 1: ' + numberTracableOutputDigits );
    }

    public void part2(){
        Long totalSumOutput = 0;
        for( Integer i = 0, j = inputLines.size(); i < j; i++ ){
            List<String> input = inputLines[ i ].split ( '\\|' );
            List<String> trainingDigits = input[ 0 ].trim().split( ' ' );
            List<String> outputDigits = input[ 1 ].trim().split( ' ' );

            // Train the 7-segment-digit-system based on training data
            SevenSegmentDigitSystem digitSystem = new SevenSegmentDigitSystem( trainingDigits );

            // Loop over output digits and use trained digitSystem to convert to numbers and calculate the sum
            List<String> outputDigitConstruction = new List<String>();
            for( Integer d = 0, e = outputDigits.size(); d < e; d++ ){
                String nextOutputEncodedString = outputDigits[ d ];
                // First try to identify digit by length, to prevent need of sorting etc
                String nextDigit = LENGTH_PER_TRACEABLEDIGIT.get( nextOutputEncodedString.length() );
                if( String.isBlank( nextDigit ) ){
                    // When the length is not sufficient, sort the digit input to match with dictionary
                    nextDigit = digitSystem.getDigitByEncodedString(
                        this.sortStringCharacters( nextOutputEncodedString )
                    );
                }
                outputDigitConstruction.add( nextDigit );
            }
            try{
                totalSumOutput += Integer.valueOf( String.join( outputDigitConstruction, '' ) );
            } catch( TypeException ex ){
                System.debug( '*** Couldn\'t convert to Integer for line ' + i + ' with '+ outputDigitConstruction );
                throw ex;
            }
        }
        System.debug( '*** Answer part 2: '+ totalSumOutput );
    }

    private String sortStringCharacters( String unsortedString ){
        List<String> unsortedCharacters = unsortedString.split( '' );
        unsortedCharacters.sort();
        return String.join( unsortedCharacters, '' );
    }

    /**
     * Inner class to construct the 'seven digit system' per line of input
     *      0               a
     *   1      2       b       c
     *      3               d
     *   4      5       e       f
     *      6               g
     */
    private class SevenSegmentDigitSystem{
        List<String> sevenDigitCharacters = new List<String>{ '', '', '', '', '', '', '' };
        private Map<String, String> digitPerOrderedCharacters = new Map<String, String>();

        /**
         * Constructor to parse the training set for 'known'/'traceable digits and from there construct the full seven-digit-system
         * Assumption is that the training set ALWAYS contains all 10 possible digits
         * End-result is to be able to know which sorted-encodedString represents which number
         *
         * For clarity, the below terminology is used:
         * - '1'            The numerical digit which is represented in 7-segment-digit-system by '25'/'cf'
         * - 5-index        The 5-index aka 6th number in the 7-segment-digit-system, and thus the bottom-right (see class header)
         * - encodedString  Representation of a number in the 7-segment-digit-system, like 'cf' for '1' in the default system (see class header)
         */
        public SevenSegmentDigitSystem( List<String> trainingSet ){
            Map<Integer, List<List<String>>> trainingInputByLength = new Map<Integer, List<List<String>>>();

            // Loop over training set to reconstruct the shifted 7-segment-system.
            // Split the encodedStrings, sort them for easier comparison and group them per length for easier processing
            for( Integer i = 0, j = trainingSet.size(); i < j; i++ ){
                List<String> trainingInputList = trainingSet[ i ].split( '' );
                trainingInputList.sort();

                Integer length = trainingInputList.size();
                List<List<String>> existingInput = trainingInputByLength.get( length );
                if( existingInput != null ){
                    existingInput.add( trainingInputList );
                } else{
                    trainingInputByLength.put( length, new List<List<String>>{ trainingInputList } );
                }

                // When length of input is unique for possible values, directly assign the sorted encodedString
                if( LENGTH_PER_TRACEABLEDIGIT.containsKey( length ) ){
                    this.digitPerOrderedCharacters.put( String.join( trainingInputList, '' ), LENGTH_PER_TRACEABLEDIGIT.get( length ) );
                }
            }

            // Start process of translating the incoming encodedString to a logical 7-segment-system

            // Determine 2- and 5-index & '6'-encodedString
            // '1' is represented by index 2 and 5 (2,5); Only '0', '6' and '9' have a length of 6; '6' contains only 5, while both '0' and '9' have 2 AND 5
            // Note e.g. 5-lengths can't be used, since '2' contains only 2-index; '3' contains both 2 and 5; but '5' also only contains 5, hence, no exclusion clarity can be gained
            List<String> digit_1 = trainingInputByLength.get( 2 )[ 0 ];
            String sixEncodedString = this.deduceIndicesByExclusion(
                digit_1,                        // characters for either 2- or 5-index
                trainingInputByLength.get( 6 ), // List of encoded string for '0', '6' and '9'
                5,                              // 5-index is shared across all encoded strings
                2,                              // 2-index is missing on '6' only
                true                            // Return the mismatching encodedString aka '6'
            );
            this.digitPerOrderedCharacters.put( sixEncodedString, '6' );

            // Determine 0-index
            // '7' is only 3-length; Knowing '1' (2,5) and '7' (0,2,5), allows to isolate isolate the 0-index
            Set<String> digit_7 = new Set<String>( trainingInputByLength.get( 3 )[ 0 ] ); // Convert to Set to allow removal by values
            digit_7.removeAll( digit_1 );
            this.sevenDigitCharacters[ 0 ] = digit_7.iterator().next();

            // Determine 1- and 3- index
            // '4' is represented by (1,2,3,5); 2 and 5 are known, hence, we can close in the characters for 1- and 3-index
            // Only '0', '6' and '9' have a length of 6; '0' contains only 1, while both '6' and '9' have 1 AND 3
            Set<String> digit_4 = new Set<String>( trainingInputByLength.get( 4 )[ 0 ] ); // Convert to Set to allow removal by values
            digit_4.removeAll( digit_1 );
            String zeroEncodedString = this.deduceIndicesByExclusion(
                new List<String>( digit_4 ),    // characters for either 3- or 5-index [remaining of '4' after removing 2- and 5- from '1']
                trainingInputByLength.get( 6 ), // List of encoded string for '0', '6' and '9'
                1,                              // 1-index is shared across all encoded strings
                3,                              // 3-index is missing on '0' only
                true                            // Return the mismatching encodedString aka '0'
            );
            this.digitPerOrderedCharacters.put( zeroEncodedString, '0' );

            // Determine 4- and 6-index
            // Only remaining unknown indices are 4 and 6. To fetch those, remove all known characters from '8' (which contains all characters)
            // Only '0', '6' and '9' have length of 6; '9' contains only 6, while both '0' and '6' have 4 AND 6
            Set<String> digit_8 = new Set<String>( trainingInputByLength.get( 7 )[ 0 ] ); // Convert to Set to allow removal by values
            digit_8.removeAll( this.sevenDigitCharacters );
            String nineEncodedString = this.deduceIndicesByExclusion(
                new List<String>( digit_8 ),    // characters for either 4- or 6-index [remaining of '8' after removing all known]
                trainingInputByLength.get( 6 ), // List of encoded string for '0', '6' and '9'
                6,                              // 6-index is shared across all encoded strings
                4,                              // 4-index is missing on '9' only
                true                            // Return the mismatching encodedString aka '9'
            );
            this.digitPerOrderedCharacters.put( nineEncodedString, '9' );

            // Done! We determined all characters per index. Now, construct the remaining unknown 7-segment-digit encodedStrings
            // Note, all unique-lengths ('1', '4', '7', '8') or deduced encodedString ('0', '6', '9') are known, so only parse those which haven't been linked to a digit ('2', '3', '5')
            // Get all potential numbers and exclude digits which have already been assigned
            Set<String> unidentifiedEncodedStrings = INDICES_PER_DIGIT.keySet().clone();
            unidentifiedEncodedStrings.removeAll( this.digitPerOrderedCharacters.values() );
            for( String digitToConstructEncodedStringFor : unidentifiedEncodedStrings ){
                List<Integer> indicesForDigit = INDICES_PER_DIGIT.get( digitToConstructEncodedStringFor );
                List<String> segmentCodeForDigit = new List<String>();
                for( Integer i = 0, j = indicesForDigit.size(); i < j; i++ ){
                    segmentCodeForDigit.add( this.sevenDigitCharacters[ indicesForDigit[ i ] ] );
                }
                segmentCodeForDigit.sort();
                this.digitPerOrderedCharacters.put( String.join( segmentCodeForDigit, '' ), digitToConstructEncodedStringFor );
            }
        }

        /**
         * Method to deduce which character belongs to which 7-segment-index and apply this to this System
         * Knowing two characters, their potential indices AND a list of numbers which all share ONE index, allows to deduce which character belongs to which character
         * By definition we expect 2 or 3 unknownDigits, of which either ONE misses an index (returnMismatch = true) OR TWO are missing the index (returnMismatch = false)
         * In all cases, one can not only determine which character should be on which index, but also gain the encodedString for a full number
         *
         * @param digitOptions      List of TWO characters of which we know which indices they belong, but not which character to which index;
         * @param encodedStrings    List of unknown encoded strings of which we know ALL share one index, but one or two doesn't contain the other
         * @param sharedIndex       The 7-segment-index for the character which is shared across all unknownDigits
         * @param lackingIndex      The 7-segment-index for the character which is NOT available in all unknownDigits
         * @param returnMismatch    TRUE, the encodedString which didn't have both characters; FALSE, the encodedString which had both characters
         * @return The encoded string for a full number, given it contains both digitOptions, or only one of those
         */
        private String deduceIndicesByExclusion( List<String> digitOptions, List<List<String>> encodedStrings, Integer sharedIndex, Integer lackingIndex, Boolean returnMismatch ){
            String encodedStringWithBothCharacters;
            for( Integer i = 0, j = encodedStrings.size(); i < j; i++ ){
                List<String> unknownEncodedStrings = encodedStrings[ i ];
                // When one of the '1'-digits is NOT this six-length-digit is the 6
                Boolean firstNotIncluded = !unknownEncodedStrings.contains( digitOptions[ 0 ] );
                Boolean secondNotIncluded = !unknownEncodedStrings.contains( digitOptions[ 1 ] );
                if( firstNotIncluded || secondNotIncluded ){
                    // when the first is not included, this must be the lackingIndex; where then the second is the sharedIndex
                    this.sevenDigitCharacters[ lackingIndex ] = ( firstNotIncluded ) ? digitOptions[ 0 ] : digitOptions[ 1 ];
                    this.sevenDigitCharacters[ sharedIndex ] = ( firstNotIncluded ) ? digitOptions[ 1 ] : digitOptions[ 0 ];
                    // When there is only one mismatching encodedString, return this string for efficiency
                    if( returnMismatch ){
                        return String.join( unknownEncodedStrings, '' );
                    }
                } else if( !returnMismatch ){
                    // When encodedString contains BOTH digitOptions, save that value to return at the end, to prevent not having the indices set correctly
                    encodedStringWithBothCharacters = String.join( unknownEncodedStrings, '' );
                }
            }
            // Only for returnMismatch == FALSE we can end here (OR invalid input when all numbers shared); hence, return the encodedString for the only number that shared both Index-characters
            return encodedStringWithBothCharacters;
        }

        public String getDigitByEncodedString( String encodedString ){
            return this.digitPerOrderedCharacters.get( encodedString );
        }
    }
}