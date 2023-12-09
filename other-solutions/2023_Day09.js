/**
* Script for Day 09
* Call script with expected runmode
* node 2023_Day09.js 0
* node 2023_Day09.js 1
*/
const utils = require( './utils.js' );
const inputLines = utils.getInputLines( '2023', '09' );

const DETERMINE_NEXT = 'next', DETERMINE_FIRST = 'first';

solvePuzzle01 = () => {
    var valuePredictSum = 0;
    inputLines.forEach( ( line, i ) => {
        valuePredictSum += determineDeltas(
            line.split( ' ' ).map( n => Number( n ) ),
            DETERMINE_NEXT
        );
    } );

    return valuePredictSum;
}

solvePuzzle02 = () => {
    var valueFirstSum = 0;
    inputLines.forEach( ( line, i ) => {
        valueFirstSum += determineDeltas(
            line.split( ' ' ).map( n => Number( n ) ),
            DETERMINE_FIRST
        );
    } );

    return valueFirstSum;
}

const determineDeltas = ( numbers, mode ) => {
    var deltaList = [];
    for( let i = 1, j = numbers.length; i < j; i++ ){
        deltaList.push( numbers[ i ] - numbers[ i - 1 ] );
    }
    if( deltaList.every( n => n == 0 ) ){
        return numbers[ 0 ];
    } else if( mode == DETERMINE_FIRST ){
        return numbers[ 0 ] - determineDeltas( [ ...deltaList ], mode );
    } else if( mode == DETERMINE_NEXT ){
        return numbers[ numbers.length - 1 ] + determineDeltas( [ ...deltaList ], mode );
    } else{
        throw Error( 'Invalid mode so cant determine how to proceed' );
    }
}

let startTime = utils.getCurrentTime();
console.log( 'Answer part 1: ' + solvePuzzle01() );
console.log( 'Answer part 2: ' + solvePuzzle02() );
console.log( 'Completed in', utils.getDuration( startTime ) );