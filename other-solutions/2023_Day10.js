/**
* Script for Day 10
* Call script with expected runmode
* node 2023_Day10.js 0
* node 2023_Day10.js 1
*/
const utils = require( './utils.js' );
const pathUtils = require( './utils_path_algorithms.js' );
const inputLines = utils.getInputLines( '2023', '10' );

var graph;
var startingNode;
var loop;

const SIGN_START = 'S';
const SIGN_ENCLOSED = '#';
const SIGN_OUTSIDE = ' ';
const SIGNS_DIRECTIONS = {
    '|':    [ { x: 0, y: -1 }, { x: 0, y: +1 } ], // north, south
    '-':    [ { x: -1, y: 0 }, { x: +1, y: 0 } ], // west, east
    'L':    [ { x: 0, y: -1 }, { x: +1, y: 0 } ], // north, east
    'J':    [ { x: -1, y: 0 }, { x: 0, y: -1 } ], // west, north
    '7':    [ { x: -1, y: 0 }, { x: 0, y: +1 } ], // west, south
    'F':    [ { x: 0, y: +1 }, { x: +1, y: 0 } ], // south, east
    '.':    [] // ground, no directions
}

solvePuzzle01 = () => {
    if( !graph ){ prepareInput(); }

    // Perform Breadth-first-search to find the 'round-trip' from start to start (since it's a loop)
    loop = pathUtils.breadthFirstSearch( graph, startingNode );
    // The maximum distance is thus the total loop-length, divided by two, since route can be started in both directions
    return loop.length / 2;
}

solvePuzzle02 = ( visualization = false ) => {
    // Ensure puzzle01 is ran, to prevent duplication of preparation and loop-coord-determination (breadth first search)
    if( !loop ){ solvePuzzle01(); }

    // Loop over the map and check whether the node/coordinate is part of loop; if not, count in case enclosed within loop pipes
    // "isEnclosed" is determined by toggling at 'crossings'
    let matrix = []; // visualization purposes
    let numEnclosedTiles = 0;
    inputLines.forEach( ( line, y ) => {
        if( visualization ){ matrix.push( new Array( line.length ) ); } // if desired, construct matrix

        var isEnclosed = false;
        var corner = false;
        line.split( '' ).forEach( ( val, x ) => {
            // If node not part of loop, check whether currently 'within loop' and increment if so;
            if( !loop.includes( utils.constructCoordString( x, y ) ) ){
                if( isEnclosed ){
                    numEnclosedTiles++;
                    if( visualization ){ matrix[ y ][ x ] = SIGN_ENCLOSED; }
                } else if( visualization ){
                    matrix[ y ][ x ] = SIGN_OUTSIDE;
                }

            // If node is part of the loop, determine whether this is a 'crossing', moving from left to right
            } else{
                if( visualization ){ matrix[ y ][ x ] = val; }

                // Determine whether the loop is 'crossed', moving left to right
                switch( val ){
                    case '|':   isEnclosed = !isEnclosed++; break;   // Pipe north-south, thus crosses
                    case '-':   break;                               // Pipe west-east, thus no cross
                    // Others imply 'corners'; check if 'first' corner; e.g. L--J vs. |L-7
                    case 'L': case '7': case 'F': case 'J':
                                [ corner, isEnclosed ] = handleCorner( corner, val, isEnclosed ); break;
                    default:    throw Error( 'unexpected character' );
                }
            }
        } );
    } );
    if( visualization ){ matrix.forEach( line => console.log( JSON.stringify( line ) ) ); }

    return numEnclosedTiles;
}

/**
 * Check whether the current corner-pipe indicates a 'crossing' and the next node being in/outside the loop
 * Per Line, it's provided what the optional 'opening corner pipe' was, the current value and whether now on inside of loop-pipes or not
 *
 * - Always:    Return toggled isEnclosed  As each corner (opening or closing inside) is a 'crossing'
 * - L7 & FJ:   Prevent toggle given the change of direction and thus whether something is within or outside the loop (example below)
 *              .|L-7.F-J|. < for this line all ground (".") is outside the loop, due to changed direction by L7 & FJ
 */
const handleCorner = ( openingCorner, val, isEnclosed ) => {
    if( openingCorner ){
        return [
            false,              // Remove opening corner, as current pipe-part is closed
            ( openingCorner === 'L' && val === '7' || openingCorner === 'F' && val === 'J' )
                ? isEnclosed    // in case of 'direction-changing' pipe-corner combination don't interpret crossing
                : !isEnclosed   // all other scenarios, toggle isEnclosed
        ];
    } else{
        return [ val, !isEnclosed ];
    }
}

/**
 * Method to convert the input lines to a graph of possible directions
 * Based on direction signs, calculate possible coordinate-connections
 *
 * Since startingNode is indicated by an S, it's unknown what real pipe-shape is; determine by reverse direction logic
 * Replace the starting sign ("S") with the real pipe-shape to allow correct 'crossing' calculation
 */
const prepareInput = () => {
    graph = {};
    inputLines.forEach( ( line, y ) => {
        line.split( '' ).forEach( ( val, x ) => {
            if( val == SIGN_START ){
                startingNode = utils.constructCoordString( x, y );

                // If startingNode is found, check previous graph elements if one already connects to starting node and reverse link
                startingConnectedNodes = [];
                for( let coordString of Object.keys( graph ) ){
                    graph[ coordString ].forEach( ( connectedCoord ) => {
                        if( connectedCoord == startingNode ){
                            startingConnectedNodes.push( coordString );
                        }
                    } );
                }
                graph[ startingNode ] = startingConnectedNodes;

            } else{
                // Loop over the coordinate-deltas given the current direction-sign (val) and add to graph
                let connectedCoords = [];
                SIGNS_DIRECTIONS[ val ].forEach( ( coordDelta ) => {
                    let nextCoordString = utils.constructCoordString( x + coordDelta.x, y + coordDelta.y );
                    connectedCoords.push( nextCoordString );

                    // Check whether startingNode already known and whether this is connected, to reverse link in graph
                    if( startingNode && nextCoordString == startingNode ){
                        graph[ startingNode ].push( utils.constructCoordString( x, y ) );
                    }
                } );
                graph[ utils.constructCoordString( x, y ) ] = connectedCoords;
            }
        } );
    } );

    // Logic to replace S with the effective corner pipe-shape
    // Get connected coordinates; sort them (having smallest x-val first) to allow easier matching with directions
    let startCoord = utils.getCoordFromString( startingNode );
    let connectedDirections = [];
    let neighborCoords = graph[ startingNode ].sort();
    let nsw = coordDelta( startCoord, getCoordFromString( neighborCoords[ 0 ] ) ); // north, south, west options
    let nse = coordDelta( startCoord, getCoordFromString( neighborCoords[ 1 ] ) ); // north, south, east options

    // Based on coordinate deltas, match with real Direction signs and replace in input for further processing
    for( let dirSign of Object.keys( SIGNS_DIRECTIONS ) ){
        let directionDeltas = SIGNS_DIRECTIONS[ dirSign ];
        if( directionDeltas[ 0 ].x == nsw.x && directionDeltas[ 0 ].y == nsw.y
         && directionDeltas[ 1 ].x == nse.x && directionDeltas[ 1 ].y == nse.y ){
            // Replace Start sign with the effective pipe-corner
            inputLines[ startCoord.y ] = inputLines[ startCoord.y ].replace( SIGN_START, dirSign );
            break;
        }
    }
}

let startTime = utils.getCurrentTime();
console.log( 'Answer part 1: ' + solvePuzzle01() );
console.log( 'Answer part 2: ' + solvePuzzle02( false ) );
console.log( 'Completed in', utils.getDuration( startTime ) );

/**
Examples:

Simple for puzzle 1
..F7.
.FJ|.
SJ.L7
|F--J
LJ...

Example for puzzle 2 with 'enclosed values'
.......
.S---7.
.|...|.
.L---J.
.......
Expecting 3 enclosed

...........
.S-------7.
.|F-----7|.
.||.....||.
.||.....||.
.|L-7.F-J|.
.|..|.|..|.
.L--J.L--J.
...........
Expecting 4 enclosed

.F----7F7F7F7F-7....
.|F--7||||||||FJ....
.||.FJ||||||||L7....
FJL7L7LJLJ||LJ.L-7..
L--J.L7...LJS7F-7L7.
....F-J..F7FJ|L7L7L7
....L7.F7||L7|.L7L7|
.....|FJLJ|FJ|F7|.LJ
....FJL-7.||.||||...
....L---J.LJ.LJLJ...
Expecting 8 enclosed
*/