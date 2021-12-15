/**
 * Class to support all logic for the 14th days' challenge!
 * Call as:
 *  AOC2021_Day14 challenge = new AOC2021_Day14( AOC_Base.MODE.EXAMPLE );
 *  challenge.part1();
 *  challenge.part2();
 *
 * Challenge today was understanding and properly reading the challenge.
 * In short, it was about looping over the input, processing each pair in the string (NNCB > [ NN, NC, CB ] )
 * For each pair the matching character should be injected [ASSUMING there is ALWAYS a match]
 * In this approach, it doesn't really matter where the pair is set in the list, as we'll process them all
 * Hence, location of a pair doesn't matter, and thus we can prevent List/String manipulations and simply count the pairs
 *
 * @author    Reinier van den Assum (rvandenassum@deloitte.nl)
 * @created   December 2021
 */
public with sharing class AOC2021_Day14 extends AOC_Base{
    Map<String, String> INJECTION_BY_PAIR = new Map<String, String>();
    Map<String, Long> INPUT_NUM_CHARACTERS = new Map<String, Long>();
    Map<String, Long> INPUT_NUM_PAIRS = new Map<String, Long>();
    List<String> INPUT_POLYMER_TEMPLATE;

    public AOC2021_Day14( AOC_Base.MODE runmode ){
        this.runmode = runmode;
        this.setInputLines( 'AOC2021_Day14' );

        // Fetch polymer template and store as List
        this.INPUT_POLYMER_TEMPLATE = inputLines[ 0 ].split( '' );
        this.setInitialNumberOfOccurrences();

        // Process the 'conversion table' of which letter should be injected for which pair
        for( Integer i = 2, j = inputLines.size(); i < j; i++ ){
            List<String> input = inputLines[ i ].split( ' -> ' );
            INJECTION_BY_PAIR.put( input[ 0 ], input[ 1 ] );
        }
    }

    /**
     * Loop over the Input Polymer template and count number of letter- and pair-occurrences
     * Keep track of single 'prevChar' variable to avoid duplicate List-retrievals
     */
    private void setInitialNumberOfOccurrences(){
        String prevChar;
        for( Integer i = 0, j = INPUT_POLYMER_TEMPLATE.size(); i < j; i++ ){
            String currChar = INPUT_POLYMER_TEMPLATE[ i ];
            increaseCounter( INPUT_NUM_CHARACTERS, currChar, 1 );
            if( i > 0 ){
                increaseCounter( INPUT_NUM_PAIRS, prevChar + currChar, 1 );
            }
            prevChar = currChar;
        }
    }

    public void part1(){
        // Fetch input parameters, clone to avoid impacting input of future method calls
        Map<String, Long> numPairs = INPUT_NUM_PAIRS.clone();
        Map<String, Long> numCharacters = INPUT_NUM_CHARACTERS.clone();

        for( Integer i = 0; i < 10; i++ ){
            this.performPairInjectionIteration( numPairs, numCharacters );
        }
        System.debug( '*** Answer part 1 '+ this.getMostMinusLeastOccurrence( numCharacters ) );
    }

    public void part2(){
        // Fetch input parameters, clone to avoid impacting input of future method calls
        Map<String, Long> numPairs = INPUT_NUM_PAIRS.clone();
        Map<String, Long> numCharacters = INPUT_NUM_CHARACTERS.clone();

        for( Integer i = 0; i < 40; i++ ){
            this.performPairInjectionIteration( numPairs, numCharacters );
        }
        System.debug( '*** Answer part 2 '+ this.getMostMinusLeastOccurrence( numCharacters ) );
    }

    /**
     * Method to perform one Iteration of Pair Injection to all current Pairs in the polymer template
     * Since there is no uniqueness in pairs (doesn't matter whether at start of in middle), we can aggregate the similar ones (like the Lantern fish of Day 6)
     * Hence, simply loop over all pairs and their number of occurrences of the START of iteration and apply the template-injection
     */
    private void performPairInjectionIteration( Map<String, Long> numPairs, Map<String, Long> numCharacters ){
        // Clone countMaps to only process the pairs and counters as they were at the start of this iteration
        // Else, pairs could be processed twice in one iteration:
        //      e.g. pairs (NN, NC) where NN is processed first and injected with C; then there are 2 NC pairs AFTER that iteration
        Map<String, Long> startNumPairs = numPairs.clone();

        // Loop over all Pairs available at the start of this iteration
        for( String pair : startNumPairs.keySet() ){
            String injectionChar = INJECTION_BY_PAIR.get( pair );
            if( String.isNotBlank( injectionChar ) ){
                // Fetch how often this pair occurred in the polymer template at the start of this iteration
                Long numOfThisPair = startNumPairs.get( pair );

                // Increase counter for newly introduced pairs due to injection (e.g. NN -> C, results in the duples: 'NC' and 'CN')
                List<String> pairValues = pair.split( '' );
                increaseCounter( numPairs, pairValues[ 0 ] + injectionChar, numOfThisPair );
                increaseCounter( numPairs, injectionChar + pairValues[ 1 ], numOfThisPair );

                // Decrease counter for original pair which was split and thus no duple/pair anymore
                increaseCounter( numPairs, pair, -1 * numOfThisPair );

                // Increase counter for the newly injected character
                increaseCounter( numCharacters, injectionChar, numOfThisPair );
            }
        }
    }

    private Long getMostMinusLeastOccurrence( Map<String, Long> numCharacters ){
        String leastComomonLetter, mostCommonLetter;
        Long leastCommonOccurrence, mostCommonOccurrence;
        for( String character : numCharacters.keySet() ){
            Long numOccurrence = numCharacters.get( character );
            if( numOccurrence > mostCommonOccurrence || mostCommonOccurrence == null ){
                mostCommonOccurrence = numOccurrence;
                mostCommonLetter = character;
            }
            if( numOccurrence < leastCommonOccurrence || leastCommonOccurrence == null ){
                leastCommonOccurrence = numOccurrence;
                leastComomonLetter = character;
            }
        }

        System.debug( '*** Most common letter ' + mostCommonLetter + ' (' + mostCommonOccurrence + ')' );
        System.debug( '*** Least common letter ' + leastComomonLetter + ' (' + leastCommonOccurrence + ')' );
        return ( mostCommonOccurrence - leastCommonOccurrence );
    }

    /**
     * Original solution, keeping track of the full List of characters and processing each at the time
     */
    public void part1_old(){
        List<String> polymerTemplate = inputLines[ 0 ].split( '' );
        for( Integer n = 0, l = 10; n < l; n++ ){
            // Construct initial variables per iteration
            Integer injectIndex = 1;
            String nextTemplate = polymerTemplate[ 0 ] + polyMerTemplate[ 1 ];
            String nextInjection = INJECTION_BY_PAIR.get( nextTemplate );

            // Loop over all pairs and inject the index, ONLY when the next pair exists in the INJECTION_BY_PAIR Map
            Boolean processNext = true;
            while( processNext ){
                polymerTemplate.add( injectIndex, nextInjection );
                injectIndex += 2;
                if( injectIndex >= polymerTemplate.size() ){
                    processNext = false;
                    continue;
                }
                nextTemplate = nextTemplate.right( 1 ) + polymerTemplate[ injectIndex ];
                nextInjection = INJECTION_BY_PAIR.get( nextTemplate );
                if( nextInjection == null ){
                    processNext = false;
                }
            }
        }

        // Loop over the polymer template and count number of occurrence per letter
        Map<String, Long> letterOccurrences = new Map<String, Long>();
        for( Integer i = 0, j = polymerTemplate.size(); i < j; i++ ){
            increaseCounter( letterOccurrences, polymerTemplate[ i ], 1 );
        }
        // Determine most and least common and letter and their respective number of occurrences
        String leastComomonLetter, mostCommonLetter;
        Long leastCommonOccurrence, mostCommonOccurrence;
        for( String letter : letterOccurrences.keySet() ){
            Long numOccurrence = letterOccurrences.get( letter );
            if( numOccurrence > mostCommonOccurrence || mostCommonOccurrence == null ){
                mostCommonOccurrence = numOccurrence;
                mostCommonLetter = letter;
            }
            if( numOccurrence < leastCommonOccurrence || leastCommonOccurrence == null ){
                leastCommonOccurrence = numOccurrence;
                leastComomonLetter = letter;
            }
        }
        System.debug( '*** ' + mostCommonLetter + '( ' + mostCommonOccurrence + ') - ' + leastComomonLetter + '( ' + leastCommonOccurrence + ' ) ' );
        System.debug( '*** Answer part 1: ' + ( mostCommonOccurrence - leastCommonOccurrence ) );
    }
}