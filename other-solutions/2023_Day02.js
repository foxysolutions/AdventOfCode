/**
* Script for Day 02
* Call script with expected runmode
* node 2023_Day02.js 0
* node 2023_Day02.js 1
*/
const utils = require( './utils.js' );
const inputLines = utils.getInputLines( '2023', '02' );

const CUBES_VALIDATION = {
    'red': 12,
    'green': 13,
    'blue': 14
};

const games = [];

// Process inputlines and determine and store the highest drawn number per colour per game
prepareGame = () => {
    inputLines.forEach( ( line ) => {
        let game_input_split = line.split( ': ' );
        let gameId = Number( game_input_split[ 0 ].split( ' ' )[ 1 ] );

        game = { id: gameId };
        for( let gameSet of game_input_split[ 1 ].split( '; ' ) ){
            for( let gameCube of gameSet.split( ', ' ) ){
                cubePart = gameCube.split( ' ' );
                let num = Number( cubePart[ 0 ] );
                let color = cubePart[ 1 ];

                if( color in game ){
                    game[ color ] = Math.max( game[ color ], num );
                } else{
                    game[ color ] = num;
                }
            }
        }

        games.push( game );
    } );
}

// Loop over the games, and check whether any colour-maximum exceeded the cube-validation
solvePuzzle01 = () => {
    if( games.length == 0 ){ prepareGame(); }

    var gameSumPossible = 0;
    var invalidGames = [];
    for( let game of games ){
        let isValid = true;
        for( let col of Object.keys( CUBES_VALIDATION ) ){
            if( game[ col ] > CUBES_VALIDATION[ col ] ){
                isValid = false;
                break;
            }
        }

        if( isValid ){
            gameSumPossible += game.id;
        } else{
            invalidGames.push( game.id );
        }
    }
    console.log( 'invalid games ', invalidGames );
    return gameSumPossible;
}

// Loop over the games, and multiply the colour-maximums
// This represents the 'least number of dices per colour needed for a valid game'
solvePuzzle02 = () => {
    if( games.length == 0 ){ prepareGame(); }

    var totalSum = 0;
    for( let game of games ){
        let gamePower = 1;
        for( let col of Object.keys( CUBES_VALIDATION ) ){
            gamePower *= game[ col ];
        }
        totalSum += gamePower;
    }
    return totalSum;
}

let startTime = utils.getCurrentTime();
console.log( 'Answer part 1: ' + solvePuzzle01() );
console.log( 'Answer part 2: ' + solvePuzzle02() );
console.log( 'Completed in', utils.getDuration( startTime ) );