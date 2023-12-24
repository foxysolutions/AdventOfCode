/**
* Script for Day 16
* Call script with expected runmode
* node 2023_Day16.js 0
* node 2023_Day16.js 1
*/
const utils = require( './utils.js' );
const inputLines = utils.getInputLines( '2023', '16' );

// Define directions and x- and y-deltas; added 'label'-attribute for swifter map-key comparisons
const DIR_RIGHT = { x: +1, y: 0, l: 'R' }, DIR_LEFT = { x: -1, y: 0, l: 'L' },
      DIR_UP    = { x: 0, y: -1, l: 'U' }, DIR_DOWN = { x: 0, y: +1, l: 'D' };

// Define the 'next direction' depending on 'entry-direction' vs. 'approaching object'
// Much more efficient to do via map and simplify code than having many nested if-else statements to cover all scenarios
const DIR_CHANGE_BY_CONTENT = {
    // empty space, proceed in same direction
    '.':    {   [ DIR_RIGHT.l ]:    [ DIR_RIGHT ],
                [ DIR_LEFT.l ]:     [ DIR_LEFT ],
                [ DIR_UP.l ]:       [ DIR_UP ],
                [ DIR_DOWN.l ]:     [ DIR_DOWN ]
            },
    // mirror 1
    '\\':   {   [ DIR_RIGHT.l ]:    [ DIR_DOWN ],
                [ DIR_LEFT.l ]:     [ DIR_UP ],
                [ DIR_UP.l ]:       [ DIR_LEFT ],
                [ DIR_DOWN.l ]:     [ DIR_RIGHT ]
            },
    // mirror 2
    '/':    {   [ DIR_RIGHT.l ]:    [ DIR_UP ],
                [ DIR_LEFT.l ]:     [ DIR_DOWN ],
                [ DIR_UP.l ]:       [ DIR_RIGHT ],
                [ DIR_DOWN.l ]:     [ DIR_LEFT ]
            },
    // splitter 1
    '|':    {   [ DIR_RIGHT.l ]:    [ DIR_UP, DIR_DOWN ],   // flat end, split
                [ DIR_LEFT.l ]:     [ DIR_UP, DIR_DOWN ],   // flat end, split
                [ DIR_UP.l ]:       [ DIR_UP ],             // pointy end, proceed same direction
                [ DIR_DOWN.l ]:     [ DIR_DOWN ]            // pointy end, proceed same direction
            },
    // splitter 2
    '-':    {   [ DIR_RIGHT.l ]:    [ DIR_RIGHT ],          // pointy end, proceed same direction
                [ DIR_LEFT.l ]:     [ DIR_LEFT ],           // pointy end, proceed same direction
                [ DIR_UP.l ]:       [ DIR_LEFT, DIR_RIGHT ],// flat end, split
                [ DIR_DOWN.l ]:     [ DIR_LEFT, DIR_RIGHT ] // flat end, split
            }
};

// Internally used variables
var grid, maxX, maxY;
var beamStepsPending;
var energizedCoords = {};

solvePuzzle01 = () => {
    if( !grid ){ processInput(); }
    // Process all beam interactions, starting with 0,0 as first item and moving right
    return processBeamsFromStart( { x: -1, y: 0, dir: DIR_RIGHT } );
}

processBeamsFromStart = ( startingBeam ) => {
    // Construct the beam-steps to complete by clearing lists and set starting beam-operations as first;
    beamStepsPending = [ startingBeam ];
    energizedCoords = {};

    // Continue to process beam-steps till last one processed
    // Initially approach with recursion, but not feasible due to max. stack debt exceptions
    while( beamStepsPending.length > 0 ){
        processBeamStep( beamStepsPending.shift() );
    }

    // Return number of coordinates 'energized'
    return Object.keys( energizedCoords ).length;
}

/**
 * For each next beam-step, check:
 * 1) Whether next coordinate would still be within grid, else stop processing
 * 2) Whether next coordinate was already reached; could be from multiple directions, but if already from same direction, stop processing
 * 3) Fetch the next encountered object ('.', '/', '\', '|', or '-'), determine the caused direction (change) and add to pending step
 */
processBeamStep = ( beamObj ) => {
    let nextX = beamObj.x + beamObj.dir.x;
    let nextY = beamObj.y + beamObj.dir.y;
    nextCoordString = utils.constructCoordString( nextX, nextY );
    if( nextX < 0 || nextX >= maxX || nextY < 0 || nextY >= maxY ){ // Beam went out of grid-bounds, thus this beam-processing can be stopped
        return;
    }
    // Check whether coord already touched before
    if( nextCoordString in energizedCoords ){
        // If already energized from same direction, stop logic, as is linear and will not result in different coords energized
        if( energizedCoords[ nextCoordString ].includes( beamObj.dir.l ) ){
            return;
        } else{
            energizedCoords[ nextCoordString ].push( beamObj.dir.l );
        }
    } else{ // If this coord wasn't energized before, register it from the direction currently reached
        energizedCoords[ nextCoordString ] = [ beamObj.dir.l ];
    }

    // Get next direction(s) based on the character in the nextCoordinate
    // For most, this only results in one next direction (either same or mirrored), but sometimes two due to splitter character
    DIR_CHANGE_BY_CONTENT[ grid[ nextY ][ nextX ] ][ beamObj.dir.l ].forEach( ( dirObj ) => {
        beamStepsPending.push( { x: nextX, y: nextY, dir: dirObj } );
    } );
}

const processInput = () => {
    grid = inputLines.map( line => line.split( '' ) );
    maxX = grid[ 0 ].length;
    maxY = grid.length;
}

solvePuzzle02 = () => {
    if( !grid ){ processInput(); }

    var maxNumEnergized = 0;
    var optimalStartingCoord;
    // For each row, check to start from left > right; or from right > left
    for( let y = 0; y < maxY; y++ ){
        // For row y, check num energized going from left > right, if highest, store input
        let numEnergized = processBeamsFromStart( { x: -1, y: y, dir: DIR_RIGHT } );
        if( numEnergized > maxNumEnergized ){
            maxNumEnergized = numEnergized;
            optimalStartingCoord = utils.constructCoordString( 0, y );
        }

        // For row y, check num energized going from right > left, if highest, store input
        numEnergized = processBeamsFromStart( { x: maxX, y: y, dir: DIR_LEFT } );
        if( numEnergized > maxNumEnergized ){
            maxNumEnergized = numEnergized;
            optimalStartingCoord = utils.constructCoordString( maxX - 1, y );
        }
    }
    // For each column, check to start from bottom > top; or from top > bottom
    for( let x = 0; x < maxX; x++ ){
        // For column x, check num energized going from top > bottom, if highest, store input
        let numEnergized = processBeamsFromStart( { x: x, y: -1, dir: DIR_DOWN } );
        if( numEnergized > maxNumEnergized ){
            maxNumEnergized = numEnergized;
            optimalStartingCoord = utils.constructCoordString( x, 0 );
        }

        // For column x, check num energized going from bottom > top, if highest, store input
        numEnergized = processBeamsFromStart( { x: x, y: maxY, dir: DIR_UP } );
        if( numEnergized > maxNumEnergized ){
            maxNumEnergized = numEnergized;
            optimalStartingCoord = utils.constructCoordString( x, maxY - 1 );
        }
    }

    console.log( 'max energized for ' + optimalStartingCoord + ' resulting in ' + maxNumEnergized );
    return maxNumEnergized;
}

let startTime = utils.getCurrentTime();
console.log( 'Answer part 1: ' + solvePuzzle01() );
console.log( 'Answer part 2: ' + solvePuzzle02() );
console.log( 'Completed in', utils.getDuration( startTime ) );