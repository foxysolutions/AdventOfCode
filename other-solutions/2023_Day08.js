/**
* Script for Day 08
* Call script with expected runmode
* node 2023_Day08.js 0
* node 2023_Day08.js 1
*/
const utils = require( './utils.js' );
const utils_math = require( './utils_math.js' );
const inputLines = utils.getInputLines( '2023', '08' );

var graph = [];
var directions;
var startingNodes = [];

solvePuzzle01 = () => {
    if( graph.length == 0 ){ processInput(); }

    // Loop over the 'graph' and perform all direction-steps from line 1
    var currNode = 'AAA';
    var numIterations = 0;
    do{
        numIterations++;
        for( let dir of directions ){
            currNode = graph[ currNode ][ dir ];
        }

    // If not landed in the end-node, perform another round
    } while( currNode != 'ZZZ' );

    // Return the number of direction-iterations, multiply by the total directions (to reduce increment actions)
    return numIterations * directions.length;
}

solvePuzzle02 = () => {
    if( graph.length == 0 ){ processInput(); }

    // For all startNodes ('..A') loop over the directions to determine when an endingNode ('..Z') is reached
    // Initially extended part1-solution, but took too long to find ending result due to large data
    var currNodes = startingNodes;
    var numDirectionsToEndingNode = [];
    currNodes.forEach( ( currNode ) => {
        var numSteps = 0;
        directionIndex = 0;
        do{
            currNode = graph[ currNode ][ directions[ directionIndex ] ];
            // Increment steps and set next direction index
            numSteps++;
            directionIndex = ( directionIndex == directions.length - 1 ) ? 0 : directionIndex + 1;
        } while( !currNode.endsWith( 'Z' ) );
        // Store the number of directions which were required to reach an endingNode from this startingNode
        numDirectionsToEndingNode.push( numSteps );
    } );
    // For all startingNodes, determine the least common multiple to know after how many steps you're in only ending nodes
    return numDirectionsToEndingNode.reduce( ( acc, curr ) => utils_math.lowest_common_multiple( acc, curr ), 1 );
}

const processInput = () => {
    inputLines.forEach( ( line, i ) => {
       if( i == 0 ){ directions = line.split( '' ); }
       else if( i == 1 ){ return; }
       else{
           let [ node, leftright ] = line.split( ' = ' );
           let [ lNode, rNode ] = leftright.replace( '(', '' ).replace( ')', '' ).split( ', ' );
           graph[ node ] = { L: lNode, R: rNode }
           if( node.endsWith( 'A' ) ){
               startingNodes.push( node );
           }
       }
    } );
}

let startTime = utils.getCurrentTime();
console.log( 'Answer part 1: ' + solvePuzzle01() );
console.log( 'Answer part 2: ' + solvePuzzle02() );
console.log( 'Completed in', utils.getDuration( startTime ) );