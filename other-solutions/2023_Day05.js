/**
* Script for Day 05
* Call script with expected runmode
* node 2023_Day05.js 0
* node 2023_Day05.js 1
*/
const utils = require( './utils.js' );
const fs = require( 'fs' );
const inputBlocks = fs.readFileSync( getInputFileLocation( '2023', '05' ), 'UTF-8' ).split( /\r?\n\r?\n/ );

solvePuzzle01 = () => {
    var localInputBlocks = [ ...inputBlocks ];
    var seedValues = localInputBlocks.shift().split( ': ' )[ 1 ].split( ' ' ).map( ( n ) => Number( n ) );

    do{
        var blockName;
        var seedsAdjusted = [];
        localInputBlocks.shift().split( '\r\n' ).forEach( ( elem, i ) => {
            if( i == 0 ){ blockName = elem; return; }
            let [ dest, source, range ] = elem.split( ' ' ).map( ( n ) => Number( n ) );

            // Loop over seeds and if applicable, alter number, note if not in range, number stays the same
            // NOTE: if a value is adjusted, it should not be adjusted by a following line!
            seedValues.forEach( ( val, i ) => {
                if( !seedsAdjusted.includes( i ) && val >= source && val < source + range ){
                    seedValues[ i ] += ( dest - source );
                    seedsAdjusted.push( i );
                }
            } );
        } );
    } while( localInputBlocks.length > 0 );

    return Math.min( ...seedValues );
}

solvePuzzle02 = () => {
    var localInputBlocks = [ ...inputBlocks ];

    let inputVals = localInputBlocks.shift().split( ': ' )[ 1 ].split( ' ' ).map( ( n ) => Number( n ) );
    var seedRanges = [];
    for( let i = 0, j = inputVals.length; i < j; i += 2 ){
        seedRanges.push( { val: inputVals[ i ], range: inputVals[ i + 1 ] } );
    }

    do{
        var blockName;
        var seedsAdjusted = [];
        localInputBlocks.shift().split( '\r\n' ).forEach( ( elem, i ) => {
            if( i == 0 ){ blockName = elem; return; }
            var [ dest, source, range ] = elem.split( ' ' ).map( ( n ) => Number( n ) );
            var mapDelta = dest - source;

            // loop over seeds and if applicable, alter number, note if not in range, number stays the same
            // NOTE: if a value is adjusted, it should not be adjusted by a following line!
            seedRanges.forEach( ( sr, i ) => {
                if( seedsAdjusted.includes( i ) ){
                    return;
                }
                srEnd = sr.val + sr.range - 1;
                let mapStart = source;
                let mapEnd = source + range - 1;

                // [ 10, 11, 12, 13, 14, 15 ] - seedRange
                if( mapEnd < sr.val ){} // all of mapping is before
                else if( mapStart > srEnd ){} // all of mapping is after
                else if( mapStart > sr.val ){ // map starts mid-seeds      11-13        11-17
                    seedRanges[ i ].range = mapStart - sr.val;         // [ 10, 1 ]    [ 10, 1 ]
                    if( mapEnd < srEnd ){ // map ends before seeds         true         false
                        // map falls within seedRange
                        // create new adjusted seedRange
                        seedRanges.push( {                             // [ 11, 3 ]
                            val:    mapStart + ( mapDelta ),
                            range:  range
                        } );
                        // register these are already adjusted
                        seedsAdjusted.push( seedRanges.length - 1 );
                        // and create range for remaining seedRange  //   [ 14, 2 ]
                        seedRanges.push( {
                            val:    mapEnd + 1,
                            range:  srEnd - mapEnd
                        } );
                    } else{ // map ends after seeds                        false         true
                        // curr seedRange already adjusted on line 70
                        // create new adjusted seedRange for remaining                 [ 11, 5 ]
                        seedRanges.push( {
                            val:    mapStart + ( mapDelta ),
                            range:  srEnd - mapStart + 1
                        } );
                        // register these are already adjusted
                        seedsAdjusted.push( seedRanges.length - 1 );
                    }
                } else if( mapEnd < srEnd ){ // map starts before and ends within     8-12 (8, 5)
                    // adjust the existing seedRange in val & range                    [ 10, 3 ]
                    seedRanges[ i ] = {
                        val:    sr.val + ( mapDelta ),
                        range:  mapEnd - sr.val + 1
                    }
                    // register these are already adjusted
                    seedsAdjusted.push( i );
                    // and create range for remaining (not adjusted) seedRange         [ 13, 3 ]
                    seedRanges.push( {
                        val:    mapEnd + 1,
                        range:  srEnd - mapEnd + 1
                    } );
                } else{ // map overlaps full seed range, adjust full range
                    seedRanges[ i ].val += ( mapDelta );
                    seedsAdjusted.push( i );
                }
            } );
        } );
    } while( localInputBlocks.length > 0 );

    return Math.min( ...seedRanges.map( sr => sr.val ) );
}

let startTime = utils.getCurrentTime();
console.log( 'Answer part 1: ' + solvePuzzle01() );
console.log( 'Answer part 2: ' + solvePuzzle02() );
console.log( 'Completed in', utils.getDuration( startTime ) );