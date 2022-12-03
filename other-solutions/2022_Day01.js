/**
 * Script for Day 01
 * Call script with expected runmode
 *  node 2022_Day01.js example
 *  node 2022_Day01.js real
 */
const utils = require( './utils.js' );

var caloriesPerElf;

getCaloriesPerElf = () => {
    let inputLines = utils.getInputLines( '2022', '01' );

    // Loop over input and keep track of number of calories
    // Each time an empty line is spotted, start counting next elfs' calories
    caloriesPerElf = [ 0 ];
    inputLines.forEach( ( line ) => {
        if( !line || line.length === 0 ){
            caloriesPerElf.push( 0 );
            return;
        }
        caloriesPerElf[ caloriesPerElf.length - 1 ] += parseInt( line );
    } );
}
 
solvePuzzle01 = () => {
    if( !caloriesPerElf ){
        getCaloriesPerElf();
    }

    // Return the maximum calories any elf is carrying
    return Math.max( ...caloriesPerElf );
}
 
solvePuzzle02 = () => {
    if( !caloriesPerElf ){
        getCaloriesPerElf();
    }

    let topThreeElves = Object.values( caloriesPerElf ).sort( ( a, b ) => b - a ).slice( 0, 3 );
    return topThreeElves[ 0 ] + topThreeElves[ 1 ] + topThreeElves[ 2 ];
}
 
let startTime = utils.getCurrentTime();
console.log( 'Answer part 1: ' + solvePuzzle01() );
console.log( 'Answer part 2: ' + solvePuzzle02() );
console.log( '\r\nCompleted in', utils.getDuration( startTime ) );