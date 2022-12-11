/**
* Script for Day 05
* Call script with expected runmode
* node 2022_Day05.js 0
* node 2022_Day05.js 1
*/
const utils = require( './utils.js' );
const inputLines = utils.getInputLines( '2022', '05' );

var stacks = [];
var movements = [];

processInput = () => {
    let pileConstruction = true;
    inputLines.forEach( ( line ) => {
        if( line.startsWith( ' 1' ) || line == '' ){
            pileConstruction = false;
            return;
        }

        // When we're constructing the stacks/piles, read input, process properly and split to correct piles
        if( pileConstruction ){
            let items = line.replaceAll( '    ', ' ' ).replaceAll( '[', '' ).replaceAll( ']', '' ).split( ' ' );
            
            // When first line and stacks are empty, define first layer to have correct number of piles in the stacks-array
            if( stacks.length === 0 ){
                items.forEach( ( item ) => {
                    if( item === '' ){
                        stacks.push( [] );
                    } else{
                        stacks.push( [ item ] );
                    }
                } );
            
            // When stack-piles are known, push non-empty crate identifiers to the correct pile based on the items-index
            }else{
                items.forEach( ( item, index ) => {
                    if( item !== '' ){
                        stacks[ index ].push( item );
                    }
                } );
            }
        } else{
            // Process movement
            regResult = line.match( /move (\d+) from (\d+) to (\d+)/ ); // [ full, # boxes, pile-start, pile-to ]
            movements.push( { numBoxes: parseInt( regResult[ 1 ], 10 ), pileFrom: parseInt( regResult[ 2 ] - 1, 10 ), pileTo: parseInt( regResult[ 3 ] - 1, 10 ) } );
        }
    } );
}

solvePuzzle01 = () => {
    let stacks1 = JSON.parse( JSON.stringify( stacks ) );
    movements.forEach( ( moveAction ) => {
        for( let i = 0; i < moveAction.numBoxes; i++ ){
            stacks1[ moveAction.pileTo ].unshift( stacks1[ moveAction.pileFrom ].shift() );
        }
    } );    

    let firstCrates = '';
    stacks1.forEach( ( pile ) => {
        if( pile.length > 0 ){
            firstCrates += pile[ 0 ];
        }
    } );
    return firstCrates;
}


solvePuzzle02 = () => {
    let stacks2 = JSON.parse( JSON.stringify( stacks ) );

    movements.forEach( ( moveAction ) => {
        // Splice to retrieve and remove the first N items from existing pile; then add them to front of 'to'-pile
        let boxesToMove = stacks2[ moveAction.pileFrom ].splice( 0, moveAction.numBoxes );
        stacks2[ moveAction.pileTo ] = boxesToMove.concat( stacks2[ moveAction.pileTo ] );
    } );    

    let firstCrates = '';
    stacks2.forEach( ( pile ) => {
        if( pile.length > 0 ){
            firstCrates += pile[ 0 ];
        }
    } );
    return firstCrates;
}

let startTime = utils.getCurrentTime();
processInput();
console.log( 'Answer part 1: ' + solvePuzzle01() );
console.log( 'Answer part 2: ' + solvePuzzle02() );
console.log( 'Completed in', utils.getDuration( startTime ) );