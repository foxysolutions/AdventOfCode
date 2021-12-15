/**
 * Class to support all logic for the 10th days' challenge!
 * Call as:
 *  AOC2021_Day10 challenge = new AOC2021_Day10( AOC_Base.MODE.EXAMPLE );
 *  challenge.part1();
 *  challenge.part2();
 *
 * @author    Reinier van den Assum (rvandenassum@deloitte.nl)
 * @created   December 2021
 */
public with sharing class AOC2021_Day10 extends AOC_Base{
    Map<String, String> OPEN_CLOSING_PAIRS = new Map<String, String>{
        '(' => ')',
        '[' => ']',
        '{' => '}',
        '<' => '>'
    };

    Map<String, Integer> POINTS_ILLEGAL_CHARACTER = new Map<String, Integer>{
        ')' => 3,
        ']' => 57,
        '}' => 1197,
        '>' => 25137
    };

    Map<String, Integer> POINTS_AUTOCOMPLETE_CHARACTER = new Map<String, Integer>{
        ')' => 1,
        ']' => 2,
        '}' => 3,
        '>' => 4
    };

    /**
     * Both parts require a parsed height map. Hence, perform in constructor to avoid duplicate code
     */
    public AOC2021_Day10( AOC_Base.MODE runmode ){
        this.runmode = runmode;
        this.setInputLines( 'AOC2021_Day10' );
    }

    public void part1(){
        Long totalIllegalCharacterScore = 0;
        List<Long> autoCompleteScores = new List<Long>();

        // Loop over input lines to parse syntax
        for( Integer i = 0, j = inputLines.size(); i < j; i++ ){
            List<String> inputCharacters = inputLines[ i ].split( '' );
            List<String> pairsToClose = new List<String>();
            Integer numPairsToCloseLeft = 0; // Keep track of counter, to avoid repetitive .size() retrievals
            Boolean corruptLine = false;

            // Loop over line-characters:
            // Each time a pair opens, keep track of the closing character as first-expected-closing character
            // When another closing character is expected (aka illegal character) add corresponding 'score' to total-illegal-character-scores
            for( Integer l = 0, m = inputCharacters.size(); l < m; l++ ){
                String currChar = inputCharacters[ l ];
                String matchingClosingChar = OPEN_CLOSING_PAIRS.get( currChar );

                // When it's an opening char, add the closing char to front of List (note, 'index' 0 will add 'before existing', so index-out-of-bounds on empty-list
                if( matchingClosingChar != null ){
                    if( numPairsToCloseLeft == 0 ){
                        pairsToClose.add( matchingClosingChar );
                    } else{
                        pairsToClose.add( 0, matchingClosingChar );
                    }
                    numPairsToCloseLeft++;

                // When it's a closing char, check whether it matches with the expected character, else classify as 'illegal-character' and add to score
                // Note, a line is classified as 'corrupt' when hitting the first illegal character. Hence, stop processing when found.
                } else if( !currChar.equals( pairsToClose.remove( 0 ) ) ){
                    totalIllegalCharacterScore += POINTS_ILLEGAL_CHARACTER.get( currChar );
                    corruptLine = true;
                    break;
                } else{ // When it was a closing char AND it matching the one removed, also update performance-counter (to avoid .size() for each addition of next characters)
                    numPairsToCloseLeft--;
                }
            }
            // Part 2 autocomplete all non-corrupted lines
            // For efficiency this is located in part1() code, to only require one inputLine-loop and parsing logic for closing pairs and identifying non-corrupt lines
            if( !corruptLine ){
                // Loop over remaining closing-characters and calculate score
                Long lineScore = 0;
                for( Integer n = 0; n < numPairsToCloseLeft; n++ ){
                    lineScore = lineScore * 5 + POINTS_AUTOCOMPLETE_CHARACTER.get( pairsToClose.remove( 0 ) );
                }
                autoCompleteScores.add( lineScore );
            }
        }
        // Part 1 Simply return the score of illegal characters
        System.debug( '*** Answer part 1: ' + totalIllegalCharacterScore );
        // Part 2 Return the middle auto-complete score
        autoCompleteScores.sort();
        System.debug( '*** Answer to part 2: '+ autoCompleteScores[ this.roundToInteger( ( autoCompleteScores.size() - 1 ) / 2.0 ) ] );
    }

    public void part2(){
        // Since both the remaining closing characters and the list of incomplete vs. corrupt were fully constructed in part1(), it's combined today!
        System.debug( '*** Solution of part 2 is included in answer of part 1' );
    }
}