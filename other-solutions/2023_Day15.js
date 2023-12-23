/**
* Script for Day 15
* Call script with expected runmode
* node 2023_Day15.js 0
* node 2023_Day15.js 1
*/
const utils = require( './utils.js' );
// Today not multi-lines, but one line being comma-separated, hence split upfront for easier usage
const inputLines = utils.getInputLines( '2023', '15' )[ 0 ].split( ',' );

solvePuzzle01 = () => {
    // Loop over the inputItems and sum the hashAlgorithms
    var sumResults = 0;
    inputLines.forEach( ( line, i ) => {
        sumResults += hashAlgorithm( line );
    } );

    return sumResults;
}

// For each character in the string, calc ASCII code, multiply sum by 17 and take modulo/remaining when dividing by 256
const hashAlgorithm = ( s ) => {
    let currVal = 0;
    for( let i = 0, j = s.length; i < j; i++ ){
        currVal = ( ( currVal + s.charCodeAt( i ) ) * 17 ) % 256;
    }
    return currVal;
}

solvePuzzle02 = () => {
    // Initiate 256 boxes with an empty list of lenses to start with
    var boxes = Array.from( Array( 256 ), () => [] );
    inputLines.forEach( ( line, i ) => {
        const [ fullMatch, label, operator, focalLength ] = line.match( '([a-z]+)([=|\-])([0-9]?)');
        const boxNr = hashAlgorithm( label );
        const lensIndex = boxes[ boxNr ].findIndex( ( obj ) => obj.l == label );
        // If '-', remove the lens from the related box, matching on label, IF existing
        if( operator == '-' ){
            if( lensIndex >= 0 ){
                boxes[ boxNr ].splice( lensIndex, 1 );
            }

        // If '=', add the lens at the end of the box, OR replace a lens matching the label (update to focalLength of new lens)
        } else if( operator == '=' ){
            if( lensIndex == -1 ){
                boxes[ boxNr ].push( { l: label, fl: focalLength } );
            } else{
                boxes[ boxNr ][ lensIndex ].fl = focalLength;
            }
        }
    } );

    // Calculate sum of focus power, boxNr * slotNr * focusLength, where numbers start at 1 instead of 0;
    var sumFocusingPower = 0;
    boxes.forEach( ( lenses, boxNr ) => {
        lenses.forEach( ( lensObj, slotNr ) => {
            sumFocusingPower += ( 1 + boxNr ) * ( slotNr + 1 ) * lensObj.fl;
        } );
    } );

    return sumFocusingPower;
}

let startTime = utils.getCurrentTime();
console.log( 'Answer part 1: ' + solvePuzzle01() );
console.log( 'Answer part 2: ' + solvePuzzle02() );
console.log( 'Completed in', utils.getDuration( startTime ) );