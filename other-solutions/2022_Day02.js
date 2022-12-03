/**
 * Script for Day 02
 * Call script with expected runmode
 *  node 2022_Day02.js example
 *  node 2022_Day02.js real
 */
const utils = require( './utils.js' );

// A = Rock, B = Paper, C = Scissor
// X = Rock, Y = Paper, Z = Scissor
const shapePoints = { 'X':1, 'Y':2, 'Z':3 };
const shapeComboResults = {
    'XA': 3, 'XB': 0, 'XC': 6,
    'YA': 6, 'YB': 3, 'YC': 0,
    'ZA': 0, 'ZB': 6, 'ZC': 3
};

//const roundEnd 

solvePuzzle01 = () => {
    let inputLines = utils.getInputLines( '2022', '02' );
    let roundScores = [];

    inputLines.forEach( ( line ) => {
        // A X => opponent chose Rock, you chose Rock
        let chosen = line.split( ' ' );
        roundScores.push( shapePoints[ chosen[ 1 ] ] + shapeComboResults[ [ chosen[ 1 ] + chosen[ 0 ] ] ] );
    } );

    // Return sum of individual round scores
    return roundScores.reduce( ( a, b ) => a + b );
}

// X = need to lose (0), Y = draw (3), Z = win (6)
const roundresult = { X: 0, Y: 3, Z: 6 };
const shapeToChose = {
    'AX': 'Z', 'AY': 'X', 'AZ': 'Y',
    'BX': 'X', 'BY': 'Y', 'BZ': 'Z',
    'CX': 'Y', 'CY': 'Z', 'CZ': 'X'
};

solvePuzzle02 = () => {
    let inputLines = utils.getInputLines( '2022', '02' );
    let roundScores = [];

    inputLines.forEach( ( line ) => {
        // A X => opponent chose Rock, you have to lose
        let chosen = line.split( ' ' );
            // shape points for the shape you should chose when opp choses [0] and you should [1] + the fact you [1] (lose, draw, win)
        roundScores.push( shapePoints[ shapeToChose[ chosen[ 0 ] + chosen[ 1 ] ] ] + roundresult[ chosen[ 1 ] ] );
    } );

    // Return sum of individual round scores
    return roundScores.reduce( ( a, b ) => a + b );
}
 
let startTime = utils.getCurrentTime();
console.log( 'Answer part 1: ' + solvePuzzle01() );
console.log( 'Answer part 2: ' + solvePuzzle02() );
console.log( '\r\nCompleted in', utils.getDuration( startTime ) );