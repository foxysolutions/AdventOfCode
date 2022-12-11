const fs = require( 'fs' );

/**
 * Input processing methods
 */
constructCoordString = ( x, y ) => {
    return x + ',' + y;
}

splitCoordString = ( coordString ) => {
    return coordString.split( ',' ).map( n => parseInt( n, 10 ) );
}

/**
 * Performance and debug measure methods
 */
getCurrentTime = () => {
    return new Date().getTime();
}

getDuration = ( startTime ) => {
    return ( getCurrentTime() - startTime );
}

consoleLogSameLine = ( line ) => {
    process.stdout.clearLine();
    process.stdout.cursorTo( 0 );
    process.stdout.write( line );
}

/**
 * Input file retrieval and creation
 */
constructInputFileName = ( year, day, inputMode = null ) => {
    if( inputMode == null ){ inputMode = getInputRunmode(); }
    return 'AOC' + year + '_Day' + day + '_' + inputMode;
}

getInputFileLocation = ( year, day, inputMode = null ) => {
    return '../challenges/' + year + '/' + constructInputFileName( year, day, inputMode );
}

getInputLines = ( year, day ) => {    
    const fileContent = fs.readFileSync( getInputFileLocation( year, day ), 'UTF-8' );
    return fileContent.split( /\r?\n/ );
}

// Outdated method used in 2021 for Apex implementations
getInputLinesApex = ( staticResourceName ) => {
    const fileContent = fs.readFileSync( '../apex-solutions/force-app/main/default/staticresources/'+ staticResourceName + '.resource', 'UTF-8' );
    return fileContent.split( /\r?\n/ );
}

createInputFiles = ( year, day ) => {
    fs.writeFile( getInputFileLocation( year, day, MODE_EXAMPLE ), '', ( err, file ) => { if( err ){ throw err; } } );
    fs.writeFile( getInputFileLocation( year, day, MODE_REAL ), '', ( err, file ) => { if( err ){ throw err; } } );
}

createScriptFile = ( year, day ) => {
    let scriptFileName = year + '_Day' + day + '.js';
    fs.writeFile(
        scriptFileName, 
        SCRIPT_BOILERPLATE.replaceAll( '{day}', day ).replaceAll( '{year}', year ).replaceAll( '{scriptName}', scriptFileName ),
        ( err, file ) => { if( err ){ throw err; } }
    );
}

const MODE_REAL = 'Input';
const MODE_EXAMPLE = 'Example';
getInputRunmode = () => {
    let scriptParams = process.argv; // [ {Node.exe path}, {script path}, {parameters} ]
    if( scriptParams.length == 2 ){
        return MODE_REAL;
    } else if( scriptParams.length == 3 ){
    	let runMode = scriptParams[ 2 ]; // real or example
    	if( runMode = '0' ){
            return MODE_EXAMPLE;
        } else if( runMode = '1' ){
            return MODE_REAL;
        } else if( runMode != MODE_REAL && runMode != MODE_EXAMPLE ){
            throw Exception( 'Please provide a valid run mode' );
        }
        return runMode;
    } else{
        throw Exception( 'please call the script either including runMode, OR without to default to example' );
    }
}

module.exports = {
    // Coordinates processing
    constructCoordString, splitCoordString,
    // Input processing
    constructInputFileName, getInputLines, getInputRunmode,
    // Duration processing
    getCurrentTime, getDuration,
    // Debug/print functions
    consoleLogSameLine,
    // File construction
    createInputFiles, createScriptFile
};


const SCRIPT_BOILERPLATE = 
`/**
* Script for Day {day}
* Call script with expected runmode
* node {scriptName} 0
* node {scriptName} 1
*/
const utils = require( './utils.js' );
const inputLines = utils.getInputLines( '{year}', '{day}' );

solvePuzzle01 = () => {
    inputLines.forEach( ( line ) => {
       
    } );

    return null;
}


solvePuzzle02 = () => {
    inputLines.forEach( ( line ) => {

    } );

    return null;
}

let startTime = utils.getCurrentTime();
console.log( 'Answer part 1: ' + solvePuzzle01() );
console.log( 'Answer part 2: ' + solvePuzzle02() );
console.log( 'Completed in', utils.getDuration( startTime ) );`