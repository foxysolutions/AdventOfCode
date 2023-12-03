/**
* Script for Day 03
* Call script with expected runmode
* node 2023_Day03.js 0
* node 2023_Day03.js 1
*/
const utils = require( './utils.js' );
const inputLines = utils.getInputLines( '2023', '03' );

const REGEX_NUM = /\d+/g
const CHAR_GEAR = '*'

var matrix = [];
var matrixLengthX, matrixLengthY;
var numPositions = [];
var gearsObj = {};

solvePuzzle01 = () => {
    if( matrix.length == 0 ){ convertInputToMatrix(); }

    // Loop over the identified Numbers and if it has any adjacent special character, add to sum
    let sumNums = 0;
    for( let numPos of numPositions ){ // { x, y, num, len }
        if( hasAdjacentSpecialChar( numPos ) ){
            sumNums += numPos.num;
        }
    }

    return sumNums;
}

solvePuzzle02 = () => {
    if( matrix.length == 0 ){ convertInputToMatrix(); }

    // Loop over the identified Gears including their related Numbers
    // If a Gear-character is adjacent to exactly TWO numbers, add the product of both number to sum
    var totalProduct = 0;
    for( gearMatches of Object.values( gearsObj ) ){
        if( gearMatches.length == 2 ){
            totalProduct += gearMatches[ 0 ].num * gearMatches[ 1 ].num;
        }
    }

    return totalProduct;
}

const convertInputToMatrix = () => {
    inputLines.forEach( ( line, row ) => {
        matrix.push( line.split( '' ) );

        // Detect all Integers in the row by regex and store both index and position
        let lastIndex = 0;
        line.match( REGEX_NUM )?.forEach( ( num ) => {
           // Get index of number, skipping all previous to prevent partial matches like ..159..30..15
           // Ensure to set lastIndex AFTER the number to prevent partial match within the last number like ..834..4
           numIndex = line.indexOf( num, lastIndex );
           lastIndex = numIndex + num.length;
           numPositions.push( { x: numIndex, y: row, num: Number( num ), len: num.length } );
        } );
    } );
    matrixLengthX = matrix[ 0 ].length;
    matrixLengthY = matrix.length;
}

// Check whether the number is surrounded by a special character; note, a number can occupy multiple 'cells'
// A | 0 1 2 3      - Loop over all columns between (x-1) to (x+len);
// B | 4 * * 5      - Check the columns before (x-1) and after (x+len)
// C | 6 7 8 9      - Loop over all columns between (x-1) to (x+len);
const hasAdjacentSpecialChar = ( numPos ) => {
    // Once determine the x-range for row A & C - restrict by matrix-'width'/boundaries
    xRange = range( Math.max( 0, numPos.x - 1 ), Math.min( numPos.x + numPos.len, matrixLengthX - 1 ) );

    // Loop row above (A), only if existing
    if( numPos.y > 0 ){
        for( x of xRange ){
            if( isSpecialCharacter( x, numPos.y - 1, numPos ) ){
                return true;
            }
        }
    }

    // Loop 'number-row' (B), thus only the one before and after, if existing
    if( numPos.x > 0 && isSpecialCharacter( numPos.x - 1, numPos.y, numPos ) ){ return true; }
    if( ( numPos.x + numPos.len ) < matrixLengthX && isSpecialCharacter( numPos.x + numPos.len, numPos.y, numPos ) ){ return true; }

    // Loop row below (C), only if existing
    if( numPos.y < matrixLengthY - 1 ){
        for( x of xRange ){
            if( isSpecialCharacter( x, numPos.y + 1, numPos ) ){
                return true;
            }
        }
    }

    // If there was no special character in the adjacent cells, return false
    return false;
}

const isSpecialCharacter = ( x, y, numPos ) => {
    let char = matrix[ y ][ x ];
    // If Gear character (*) add Number with position info to gearsObject, grouped by coordinate of Gear
    if( char == CHAR_GEAR ){
        let coordString = x + ',' + y;
        if( coordString in gearsObj ){
            gearsObj[ coordString ].push( numPos );
        } else{
            gearsObj[ coordString ] = [ numPos ];
        }
        return true;
    }
    // Else, if the character is not a . && not a number, identify as 'special character'
    return char != '.' && isNaN( char );
}

const range = ( start, end, step = 1 ) => {
    const length = end + 1 - start;
    return Array.from( { length }, ( elem, i ) => start + i * step );
}

let startTime = utils.getCurrentTime();
console.log( 'Answer part 1: ' + solvePuzzle01() );
console.log( 'Answer part 2: ' + solvePuzzle02() );
console.log( 'Completed in', utils.getDuration( startTime ) );