/**
* Script for Day 01
* Call script with expected runmode
* node 2023_Day01.js 0
* node 2023_Day01.js 1
*/
const utils = require( './utils.js' );
const inputLines = utils.getInputLines( '2023', '01' );

/**
 * Get all numbers from the line and add the first and last
 * Tried with regex, but not possible since abc21adsf should count as [2, 1]
 */
solvePuzzle01 = () => {
    var totalSum = 0;
    inputLines.forEach( ( line ) => {
        let nums = [];
        line.split( '' ).forEach( ( char ) => {
            if( !isNaN( char ) ){
                nums.push( char );
            }
        } );
        let stringCombined = nums[ 0 ] + '' + nums[ nums.length - 1 ];
        console.log( line, ' > ', nums, ' > ', stringCombined )
        totalSum += parseInt( stringCombined );
    } );
    return totalSum;
}

/**
 * Interpret written numbers as numbers as well, but don't replace 1-10 since twone should become 21 and NOT 'tw1'
 */
const NUM_WRITTEN = [ 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 'ten' ];
solvePuzzle02 = () => {
    var totalSum = 0;
    inputLines.forEach( ( line ) => {
        let nums = [];
        line.split( '' ).forEach( ( char, i ) => {
            if( !isNaN( char ) ){
                nums.push( char );
            } else{
                // check if this letter is the start of a digit and if so add
                // Note, there were no examples twone to become 21 or only 2 (thus replacing or proceeding)
                // Most of the time there are multiple in one line, so there is no impact, went for simplest and most efficient
                NUM_WRITTEN.forEach( ( word, n ) => {
                    if( line.slice( i ).startsWith( word ) ){
                        nums.push( n + 1 );
                    }
                } );
            }
        } );
        let stringCombined = nums[ 0 ] + '' + nums[ nums.length - 1 ];
        console.log( line, ' > ', nums, ' > ', stringCombined )
        totalSum += parseInt( stringCombined );
    } );
    return totalSum;

    return null;
}

let startTime = utils.getCurrentTime();
console.log( 'Answer part 1: ' + solvePuzzle01() );
console.log( 'Answer part 2: ' + solvePuzzle02() );
console.log( 'Completed in', utils.getDuration( startTime ) );