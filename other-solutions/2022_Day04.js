/**
 * Script for Day 04
 * Call script with expected runmode
 *  node 2022_Day04.js example
 *  node 2022_Day04.js real
 */
const utils = require( './utils.js' );

const inputLines = utils.getInputLines( '2022', '04' );

// section unique id and Elf assigned range of sections
// detect overlaps
solvePuzzle01 = () => {
    let numFullOverlap = 0;
    inputLines.forEach( ( line ) => {
        let elfRanges = line.split( ',' );
        let elf1 = elfRanges[ 0 ].split( '-' ).map( n => parseInt( n, 10 ) );
        let elf2 = elfRanges[ 1 ].split( '-' ).map( n => parseInt( n, 10 ) );
        if( ( elf1[ 0 ] <= elf2[ 0 ] && elf1[ 1 ] >= elf2[ 1 ] )
            || ( elf2[ 0 ] <= elf1[ 0 ] && elf2[ 1 ] >= elf1[ 1 ] ) ){
            numFullOverlap++;
        }
    } );

    return numFullOverlap;
}


solvePuzzle02 = () => {
    let numOverlap = 0;
    inputLines.forEach( ( line ) => {
        let elfRanges = line.split( ',' );
        let elf1 = elfRanges[ 0 ].split( '-' ).map( n => parseInt( n, 10 ) );
        let elf2 = elfRanges[ 1 ].split( '-' ).map( n => parseInt( n, 10 ) );
        if( elf1[ 1 ] >= elf2[ 0 ] && elf2[ 1 ] >= elf1[ 0 ] ){
            numOverlap++;
        }
    } );

    // Return
    return numOverlap;
}
 
let startTime = utils.getCurrentTime();
console.log( 'Answer part 1: ' + solvePuzzle01() );
console.log( 'Answer part 2: ' + solvePuzzle02() );
console.log( '\r\nCompleted in', utils.getDuration( startTime ) );