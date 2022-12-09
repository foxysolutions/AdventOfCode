/**
 * Script for Day 03
 * Call script with expected runmode
 *  node 2022_Day03.js example
 *  node 2022_Day03.js real
 */
const utils = require( './utils.js' );

const inputLines = utils.getInputLines( '2022', '03' );
const prioList = [ '', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
                   'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z' ];

// Spot the duplicate type in the two compartments per rucksack
// Add count priorities per type, based on priority list
solvePuzzle01 = () => {
    let sum = 0;

    inputLines.forEach( ( line ) => {
        let numPerCompartment = line.length / 2;
        let compartment2 = line.substr( numPerCompartment, numPerCompartment );
        let duplicateType = [];

        line.substr( 0, numPerCompartment ).split( '' ).forEach( ( char ) => {
            if( !duplicateType.includes( char ) && compartment2.includes( char ) ){
                sum += prioList.indexOf( char );
                duplicateType.push( char );
            }
        } );
    } );

    // Return sum of priorities of type occurring in both compartments of a rucksack
    return sum;
}

// Badge defines ONLY type all three elves can carry - and 2 will only carry other items
solvePuzzle02 = () => {
    let sum = 0;

    for( let i = 0, j = inputLines.length / 3; i < j; i++ ){
        let rucksack2 = inputLines[ i * 3 + 1 ].split( '' );
        let rucksack3 = inputLines[ i * 3 + 2 ].split( '' );

        let duplicateType = [];
        inputLines[ i * 3 ].split( '' ).forEach( ( char ) => {
            if( !duplicateType.includes( char ) && rucksack2.includes( char ) && rucksack3.includes( char ) ){
                sum += prioList.indexOf( char );
                duplicateType.push( char );
            }
        } );
    }

    // Return sum of individual round scores
    return sum;
}
 
let startTime = utils.getCurrentTime();
console.log( 'Answer part 1: ' + solvePuzzle01() );
console.log( 'Answer part 2: ' + solvePuzzle02() );
console.log( '\r\nCompleted in', utils.getDuration( startTime ) );