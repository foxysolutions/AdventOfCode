/**
 * Script for Day 15 part 2, which could use Dijkstra but would take ages
 * Call script with expected runmode
 *  node 2021_Day15_2_PriorityQueue.js example
 *  node 2021_Day15_2_PriorityQueue.js real
 *
 * NOTE: Requires priorityqueuejs; hence first run
 *  npm install priorityqueuejs
 *
 * Performance: 83 ms & 2100 ms
 */
const fs = require( 'fs' );
const utils = require( './utils.js' );

const PriorityQueue = require( 'priorityqueuejs' );

function getAdjacent( matrix, currCoordString ){
	let [ x, y ] = utils.splitCoordString( currCoordString );

    let adjacentCoordStrings = [];
    if( x > 0 ){    adjacentCoordStrings.push( utils.constructCoordString( x - 1, y ) ); }
    if( x < maxX_Full - 1 ){ adjacentCoordStrings.push( utils.constructCoordString( x + 1, y ) ); }
    if( y > 0 ){    adjacentCoordStrings.push( utils.constructCoordString( x, y - 1 ) ); }
    if( y < maxY_Full - 1 ){ adjacentCoordStrings.push( utils.constructCoordString( x, y + 1 ) ); }
	return adjacentCoordStrings;
}

function getCost( matrix, coordString ){
    // Determine cost on the fly:
    // 1) Converting requested coordinate back to original Coordinate taking module of original size
    // 2) Adding an increase for each 'repetition' (so 0,0 > 1,1 of matrices is +2 costs/risks)
    // 3) Respect maximum risk of 9, decreasing if needed
	let [ x, y ] = utils.splitCoordString( coordString );
	let cost = matrix[ y % maxY ][ x % maxX ] + Math.floor( y / maxY ) + Math.floor( x / maxX );
    while( cost > 9 ){
        cost -= 9;
    }
	return cost;
}

determineLowestRisk = ( startNode, endNode ) => {
    // Define PriorityQueue and the Priority-ruling
    let queue = new PriorityQueue( (a, b) => b.cost - a.cost );
    let prevPoint = {};
    let costs = { '0,0' : 0 };
    let visited = {};

    /**
     * The real magic!
     */
    queue.enq( { coord: '0,0', cost: 0 } );

    while( !queue.isEmpty() ){
        let currCoord = queue.deq().coord;

        // When queued coordinate was already visited, skip rest of logic
        if( visited[ currCoord ] ){
            continue;
        }

        // Get Adjacent Coordinates and determine next based on lowest costs (like Dijkstra)
        for( let nextCoordString of getAdjacent( matrix, currCoord ) ){
            const newCost = costs[ currCoord ] + getCost( matrix, nextCoordString );
            if( !costs[ nextCoordString ] || costs[ nextCoordString ] > newCost ){
                queue.enq( { coord: nextCoordString, cost: newCost } );
                costs[ nextCoordString ] = newCost;
                prevPoint[ nextCoordString ] = currCoord;
            }
        }
        visited[ currCoord ] = true;
    }

    return costs[ endNode ];
}

/**
 * Input parsing
 */
let startTime = utils.getCurrentTime();

// Get input data and set program standards
const numRepetition = 5;
const matrix = utils.getInputLines( utils.constructInputFileName( '2021', '15' ) )
    .map( line => line.split( '' )
        .map( n => parseInt( n, 10 ) ) );

// Set Matrix sizing to allow efficient processing in later methods
const [ maxX, maxY ] = [ matrix[ 0 ].length, matrix.length ];
const [ maxX_Full, maxY_Full ] = [ maxX * numRepetition, maxY * numRepetition ];

console.log( 'Solution for part 2: ',
    determineLowestRisk(
        utils.constructCoordString( 0, 0 ),
        utils.constructCoordString( maxX_Full - 1, maxY_Full - 1 )
    ) );
console.log( 'Completed in ', utils.getDuration( startTime ) );