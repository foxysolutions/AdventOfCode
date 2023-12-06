/**
* Script for Day 06
* Call script with expected runmode
* node 2023_Day06.js 0
* node 2023_Day06.js 1
*/
const utils = require( './utils.js' );
const inputLines = utils.getInputLines( '2023', '06' );

solvePuzzle01 = () => {
    // Fetch input from fixed num of Lines, splitting, trimming and then splitting by x spaces and transforming to num
    var raceLengths   = inputLines[ 0 ].split( ':' )[ 1 ].trim().split( /\s+/ ).map( ( n ) => Number( n ) );
    var bestDistances = inputLines[ 1 ].split( ':' )[ 1 ].trim().split( /\s+/ ).map( ( n ) => Number( n ) );

    // Loop over the retrieved races and multiply number of options to win
    var totalScore = 1;
    for( let i = 0, j = raceLengths.length; i < j; i++ ){
        totalScore *= determineWinningOptions( raceLengths[ i ], bestDistances[ i ] );
    }

    return totalScore;
}

solvePuzzle02 = () => {
    // Fetch input from fixed num of Lines, replacing all space as 'incorrect', splitting and transforming to num
    var raceTime = Number( inputLines[ 0 ].replaceAll( ' ', '' ).split( ':' )[ 1 ] );
    var bestDist = Number( inputLines[ 1 ].replaceAll( ' ', '' ).split( ':' )[ 1 ] );

    // Let logic loop over all possible press-release-times and determine with how many one would win
    return determineWinningOptions( raceTime, bestDist );
}

const determineWinningOptions = ( raceTime, bestDist ) => {
    var numWaysToWin = 0;
    for( let n = 0; n <= raceTime; n++ ){
        // If you hold button n ms, the boat gets a speed of n (mm/ms), for remaining ( length - n ) ms of the race
        if( ( ( raceTime - n ) * n ) > bestDist ){
            numWaysToWin++;
        }
    }
    return numWaysToWin;
}

let startTime = utils.getCurrentTime();
console.log( 'Answer part 1: ' + solvePuzzle01() );
console.log( 'Answer part 2: ' + solvePuzzle02() );
console.log( 'Completed in', utils.getDuration( startTime ) );