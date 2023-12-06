/**
 * Script for Day 15 exercise since Apex wasn't able to manage within the CPU Limits
 * Call script with expected runmode
 *  node 2021_Day15_1_Dijkstra.js example
 *  node 2021_Day15_1_Dijkstra.js real
 *
 * Performance: 26 sec & 12 min
 */
const utils = require( './utils.js' );
const dijkstra = require( './dijkstra.js' );

// Transform input file to costGraph
const matrix = utils.getInputLinesApex( utils.constructInputFileNameApex( '2021', '15' ) )
    .map( line => line.split( '' )
        .map( n => parseInt( n, 10 ) ) );

var costGraph = {};
const addToCostGraph = ( fromCoord, toCoord, cost ) => {
    costGraph[ fromCoord ] = { ...costGraph[ fromCoord ], [toCoord]: cost };
}

for( var y = 0, numRows = matrix.length; y < numRows; y++ ){
    let line = matrix[ y ];
    for( var x = 0, numCols = line.length; x < numCols; x++ ){
        let currCoord = utils.constructCoordString( x, y );
        let currCost = line[ x ];
        if( x > 0 ){
            addToCostGraph( utils.constructCoordString( ( x - 1 ), y ), currCoord, currCost );
        }
        if( x < numCols - 1 ){
            addToCostGraph( utils.constructCoordString( ( x + 1 ), y ), currCoord, currCost );
        }
        if( y > 0 ){
            addToCostGraph( utils.constructCoordString( x, ( y - 1 ) ), currCoord, currCost );
        }
        if( y < numRows - 1 ){
            addToCostGraph( utils.constructCoordString( x, ( y + 1 ) ), currCoord, currCost );
        }
    }
}

let startTime = utils.getCurrentTime();
let shortestPathResult = dijkstra.findShortestPath( costGraph, utils.constructCoordString( 0, 0 ), utils.constructCoordString( numCols - 1, numRows - 1 ) )
console.log( 'Solution for part 2: ', shortestPathResult[ 'distance' ] );
console.log( 'Completed in ', utils.getDuration( startTime ) );