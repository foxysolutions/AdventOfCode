/**
* Script for Day 07
* Call script with expected runmode
* node 2023_Day07.js 0
* node 2023_Day07.js 1
*/
const utils = require( './utils.js' );
const inputLines = utils.getInputLines( '2023', '07' );

var CURR_PART;
const PART1 = 'p1', PART2 = 'p2';

var cardScore1 = [ '2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K', 'A' ];
var cardScore2 = [ 'J', '2', '3', '4', '5', '6', '7', '8', '9', 'T', 'Q', 'K', 'A' ];

solvePuzzle01 = () => {
    CURR_PART = PART1;
    return solveGenericPuzzle();
}

solvePuzzle02 = () => {
    CURR_PART = PART2;
    return solveGenericPuzzle();
}

solveGenericPuzzle = () => {
    // identifyTypes()  - convert input lines to processable data and assigning a score per hand
    // sort()           - based on hand-score (type + 1st card) determine rank, else check 2nd card, 3rd till difference
    // reduce( callbackFn , initialValue ) - Calculate total winnings by adding hand-bid * hand-rank
    return identifyTypes().sort( handSortFunction ).reduce(
        ( total, hand, i ) => Number( total ) + hand.bid * ( i + 1 ),
        0
    );
}

/**
 * Method to convert input lines to processable data, count cards, and assign a score per hand
 * - For each hand, split input to cards and bid
 * - Count the frequency of each 'card-character' ( { 'T': 2 })
 * - Translate to a map showing the card-characters per count/frequency ( { '2': [ 'T' ] } )
 *   - Keep track of the highest frequency of cards in this hand
 *   - If P2:
 *      - Keep count of Jokers aside, to simplify determining what card the Joker will act alike for highest score
 *      - After knowing all frequencies, determine most frequent occurring and add the Jokers
 * - Calculate (made-up) score to simplify sort-comparison
 * - Add hand object to list for further processing
 */
const identifyTypes = () => {
    var localHands = [];
    inputLines.forEach( ( cards, i ) => {
        // Process input towards handObj
        let inputSplit = cards.split( ' ' );
        var handObj = {
            hand:           inputSplit[ 0 ].split( '' ),
            bid:            inputSplit[ 1 ],
            countOfCards:   {},
            highestCount:   0,
            score:          0
        };

        // Count frequency of each card-character
        var cardCount = [];
        for( let c of handObj.hand ){
            cardCount[ c ] = 1 + ( ( c in cardCount ) ? cardCount[ c ] : 0 );
        }

        // Translate to a map stating the number of cards per certain frequency
        // If Part2, keep Jokers aside, to simplify identifying acting card
        //  E.g. if 'AAJJJ', Jokers should act as 'A', but would be hard to determine as A is not most freq. occurring
        var numJokers = 0;
        for( let card of Object.keys( cardCount ) ){
            if( CURR_PART == PART2 && card == 'J' ){
                numJokers = cardCount[ card ];
            } else{
                // Convert { 'T': 2 } > { '2': [ 'T' ] }
                let count = cardCount[ card ];
                if( count in handObj.countOfCards ){
                    handObj.countOfCards[ count ].push( card );
                } else{
                    handObj.countOfCards[ count ] = [ card ];
                }
                // Keep track of highest count
                if( count > handObj.highestCount ){
                    handObj.highestCount = count;
                }
            }
        }

        // For Part2, if there is a Joker, add this to the most freq. occurring card
        // Since frequency always wins over others ( 3+2 < 4 ) it's always best to add to most occurring
        if( CURR_PART == PART2 && numJokers > 0 ){
            // In case of JJJJJ just assign a random card to get five of a kind
            if( handObj.highestCount == 0 ){
                handObj.countOfCards[ 5 ] = '2';
            } else{
                // Decide the card the joker will act like (2-9, T, ...) - most occurring card
                let jokerUpCard = handObj.countOfCards[ handObj.highestCount ].shift();

                // If this leaves no other cards remaining, for proper administration remove the 'count' from obj;
                if( handObj.countOfCards[ handObj.highestCount ].length == 0 ){
                    delete handObj.countOfCards[ handObj.highestCount ];
                }

                // Add all Jokers to most frequent occurring card and add to count-map
                handObj.highestCount += numJokers;
                handObj.countOfCards[ handObj.highestCount ] = jokerUpCard;
            }
        }

        // Assign score to current hand;
        // Adding the score per hand-type + the first card as this would always be included
        // Score doesn't include 2nd, 3rd, ... card given the likelihood of 2AAAAA giving false score
        // Given there are 13 cards, the type-scoring should be at least 14pts apart, chose for 15 by simplicity
        if( '5' in handObj.countOfCards ){
            handObj.score = 100; // five of a kind
        } else if( '4' in handObj.countOfCards ){
            handObj.score = 85; // four of a kind
        } else if( '3' in handObj.countOfCards ){
            if( '2' in handObj.countOfCards ){
                handObj.score = 70; // full house
            } else{
                handObj.score = 55; // three of a kind
            }
        } else if( '2' in handObj.countOfCards ){
            if( handObj.countOfCards[ '2' ].length == 2 ){
                handObj.score = 40; // two pair
            } else{
                handObj.score = 25; // one pair
            }
        }
        // Add first hand score, based on 'card-scoring' per type
        handObj.score += ( CURR_PART == PART1 )
            ? cardScore1.indexOf( handObj.hand[ 0 ] )
            : cardScore2.indexOf( handObj.hand[ 0 ] );
        localHands.push( handObj );
    } );
    return localHands;
}

/**
 * Sorting method based on score;
 * Note, given need to multiply by rank, the lowest score should be at index 0
 */
const handSortFunction = ( a, b ) => {
    if( a.score < b.score ){
        return -1;  // sort a before b;
    } else if( a.score > b.score ){
        return 1;   // sort b before a;
    } else if( a.score == b.score ){
        // If type + 1st card score are equal, check 2nd card, if still equal, check 3rd, ... till 5th
        let cardScoreDiff = 0;
        let index = 1;
        do{
            cardScoreDiff = ( CURR_PART == PART1 )
                ? cardScore1.indexOf( a.hand[ index ] ) - cardScore1.indexOf( b.hand[ index ] )
                : cardScore2.indexOf( a.hand[ index ] ) - cardScore2.indexOf( b.hand[ index ] );
            index++;
        } while( cardScoreDiff == 0 && index < 5 );

        // e.g. 'K' (11) vs. 'T'  (9) > a-b =  2 so 'T' is first
        // e.g. 'T'  (9) vs. 'K' (11) > a-b = -2 so 'T' is first
        return cardScoreDiff;
    }
}

let startTime = utils.getCurrentTime();
console.log( 'Answer part 1: ' + solvePuzzle01() );
console.log( 'Answer part 2: ' + solvePuzzle02() );
console.log( 'Completed in', utils.getDuration( startTime ) );