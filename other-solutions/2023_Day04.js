/**
* Script for Day 04
* Call script with expected runmode
* node 2023_Day04.js 0
* node 2023_Day04.js 1
*/
const utils = require( './utils.js' );
const inputLines = utils.getInputLines( '2023', '04' );

var cards = []; // { winningNums, cardNums }

solvePuzzle01 = () => {
    if( cards.length == 0 ){ convertLinesToCards(); }

    // Loop over cards and check the number of winning numbers; first gives 1 pt, after doubles
    let totalScore = 0;
    cards.forEach( ( card, i ) => {
        var cardScore = 0;
        for( num of card.cardNums ){
            if( card.winningNums.includes( num ) ){
                cardScore = ( cardScore == 0 ) ? 1 : cardScore * 2;
            }
        }
        totalScore += cardScore;
    } );

    return totalScore;
}

solvePuzzle02 = () => {
    if( cards.length == 0 ){ convertLinesToCards(); }

    // Loop over cards and keep track of the numbers; each card of index 1 has the same score, thus we can multiply
    let numCards = Array( inputLines.length ).fill( 1 );
    cards.forEach( ( card, i ) => {
        var nextCards = 0;
        for( num of card.cardNums ){
            if( card.winningNums.includes( num ) ){
                nextCards++;
            }
        }
        // Loop over additionally won next cards to add copies, equal to the number of cards of the current index
        let numCardsCurrIndex = numCards[ i ];
        for( let n = i+1, m = i+1+nextCards; n < m; n++ ){
            numCards[ n ] += numCardsCurrIndex;
        }
    } );
    // Answer is the sum of all available cards
    return numCards.reduce( ( total, item ) => total + item );
}

const convertLinesToCards = () => {
    // Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
    inputLines.forEach( ( line, i ) => {
        let [ winningString, cardString ] = line.split( ': ' )[ 1 ].split( ' | ');
        cards.push( {
            winningNums: winningString.split( /\s+/ ),
            cardNums:    cardString.split( /\s+/ )
        } );
    } );
}

let startTime = utils.getCurrentTime();
console.log( 'Answer part 1: ' + solvePuzzle01() );
console.log( 'Answer part 2: ' + solvePuzzle02() );
console.log( 'Completed in', utils.getDuration( startTime ) );