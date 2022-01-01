/**
 * Script for Day 21 exercise since Apex wasn't able to manage within the CPU Limits
 * Call script with Player 1 and 2 starting at spot 4 and 8, respectively
 *      node 2021_Day21.js 4 8
 */
const utils = require( './utils.js' );

let scriptParams = process.argv;
if( scriptParams.length == 4 ){ // [ {Node.exe path}, {script path}, {parameter} ]
	inputPosP1 = scriptParams[ 2 ];
	inputPosP2 = scriptParams[ 3 ];
} else{
    throw Exception( 'please call the script including only two additional parameters, referring to player startings position' );
}

// Totals and occurrences when throwing three 1,2,3-dices (3 only thrown via 1+1+1, 9 only via 3+3+3)
rollFrequencies = [ [3, 1], [4, 3], [5, 6], [6, 7], [7, 6], [8, 3], [9, 1] ];

calculateWins = ( posCurrPlayer, scoreCurrPlayer, posOtherPlayer, scoreOtherPlayer ) => {
	// Only check Other Player, since CurrPlayer is about to move and can never be passed 21 already
	if( scoreOtherPlayer >= 21 ){
		return [ 0, 1 ];
	}
	// Since arrow function variables are by default public, so define let to make sure it is within this method only
	let winState = [ 0, 0 ];
	
	// Loop over all rollFrequencies and calculate the number wins for all potential outcomes
	rollFrequencies.forEach( ( diceTotalFrequencyList ) => {
        let startThrow = ( scoreOtherPlayer == 0 ) ? utils.getCurrentTime() : 0; // Only for 'parent recursion' keep track of startTime
		let throwTotal = diceTotalFrequencyList[ 0 ];
		let throwFrequency = diceTotalFrequencyList[ 1 ];
		
		// Determine next position for current player based on sum of eyes thrown (note, position is tracked as index 0-9)
		let newPosCurrPlayer = ( posCurrPlayer + throwTotal ) % 10;
		// Swap players as their actions are identical and determine all potential options for current state
		let swappedWins = calculateWins(
			posOtherPlayer,
			scoreOtherPlayer,
			newPosCurrPlayer,
			scoreCurrPlayer + newPosCurrPlayer + 1
		);
		// Add the swapped wins multiplied by the likelihood/occurrence of this throw
		winState[ 0 ] += swappedWins[ 1 ] * throwFrequency;
		winState[ 1 ] += swappedWins[ 0 ] * throwFrequency;
		if( scoreOtherPlayer == 0 ){
			console.log( 'Completed win-scenarios when Player 1 starts with ' + throwTotal + ' in ' + utils.getDuration( startThrow ) );
		}
	} );
	return winState;
}

let startTime = utils.getCurrentTime();
winCounts = calculateWins( inputPosP1 - 1, 0, inputPosP2 - 1, 0 );
console.log( 'Solution for part 2: ',  Math.max( winCounts[ 0 ], winCounts[ 1 ] ) );
console.log( 'Completed in ', utils.getDuration( startTime ) );