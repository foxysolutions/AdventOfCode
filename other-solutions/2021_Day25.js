/**
 * Script for Day 25, since Apex even in Async mode ran out of CPU Time limit
 * Call script with expected runmode
 *  node 2021_Day25.js example
 *  node 2021_Day25.js real
 *
 * Performance: 28ms & 3min
 */
const utils = require( './utils.js' );

const SPOT_EMPTY = '.';
const SPOT_EAST = '>';
const SPOT_SOUTH = 'v';

performMovementsTillAllStuck = () => {
    // Loop over input lines and define East-Moving and South-Moving Sea Cucumbers (SCs)
    // Significantly better performing compared to looping over full Matrix twice as skipping all SPOT_EMPTY (2x)
    // and skipping South-Moving when checking East-Moving and vice versa
    let eastMoving = [];
    let southMoving = [];
    let inputLines = utils.getInputLinesApex( utils.constructInputFileName( '2021', '25' ) );
    const maxX = inputLines[ 0 ].length;
    const maxY = inputLines.length;
    inputLines.forEach( ( line, y ) => line.split( '' ).forEach( ( elem, x ) => {
        if( elem == SPOT_EAST ){
            eastMoving.push( utils.constructCoordString( x, y ) );
        } else if( elem == SPOT_SOUTH ){
            southMoving.push( utils.constructCoordString( x, y ) );
        } // else, empty spot
    } ) );

    // Define number of Cucumbers per moving-direction (as number never changes)
    const numEastMoving = eastMoving.length;
    const numSouthMoving = southMoving.length;

    // Start iteration, performing all movements and keeping track whether any of the Sea Cucumbers moved; if not, stop, they're stuck
    let iteration = 0;
    let anySeaCucumberMoved;
    do{
        // Always reset the Boolean to ensure one really moved; and increase the iteration number
        anySeaCucumberMoved = false;
        iteration++;

        // Set initial state to avoid any movement in this iteration to impact another Sea Cucumber in the same iteration ('all happen at the same time')
        allCucumbersBeforeEast = [...eastMoving, ...southMoving];
        // Loop over all EastMoving SCs; when nextCoord isn't in the list of all SCs, move the SC (remove current coord and add the new one)
        // Note, introduced j-variable to avoid processing newly added newCoords in this iteration directly
        for( let i = 0, j = numEastMoving; i < j; i++ ){
            let [ x, y ] = utils.splitCoordString( eastMoving[ i ] );
            let nextCoord = utils.constructCoordString( ( x + 1 ) % maxX, y );

            // When nextCoord isn't occupied by any SC, move the SC by removing the current item in the list and appending the new Coord;
            // Decrease both current index and maxIndex to ensure all EastMoving SCs are processed exactly once in this iteration
            if( !allCucumbersBeforeEast.includes( nextCoord ) ){
                eastMoving.splice( i, 1 );
                eastMoving.push( nextCoord );
                i--, j--;
                anySeaCucumberMoved = true;
            }
        }

        // Set initial state after all EastMoving SCs have moved, to avoid one SouthMoving SC to impact another SM in the same iteration
        allCucumbersBeforeSouth = [...eastMoving, ...southMoving];
        for( let i = 0, j = numSouthMoving; i < j; i++ ){
            let [ x, y ] = utils.splitCoordString( southMoving[ i ] );
            let nextCoord = utils.constructCoordString( x, ( y + 1 ) % maxY );

            if( !allCucumbersBeforeSouth.includes( nextCoord ) ){
                southMoving.splice( i, 1 );
                southMoving.push( nextCoord );
                i--, j--;
                anySeaCucumberMoved = true;
            }
        }
        utils.consoleLogSameLine( 'completed iteration ' + iteration + ' which had movement: ' + anySeaCucumberMoved );
    } while( anySeaCucumberMoved );
    return iteration;
}

let startTime = utils.getCurrentTime();
utils.consoleLogSameLine( 'Answer part 1: ' + performMovementsTillAllStuck() );
console.log( '\r\nCompleted in', utils.getDuration( startTime ) );