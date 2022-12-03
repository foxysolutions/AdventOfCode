const fs = require( 'fs' );

constructCoordString = ( x, y ) => {
    return x + ',' + y;
}

splitCoordString = ( coordString ) => {
    return coordString.split( ',' ).map( n => parseInt( n, 10 ) );
}

constructInputFileName = ( yearString, dayString ) => {
    let runmode = getInputRunmode();
    return 'AOC' + yearString + '_Day' + dayString + '_' + ( ( runmode == MODE_REAL ) ? 'Input' : ( ( runmode == MODE_EXAMPLE ) ? 'Example' : 'ERROR' ) );
}

getCurrentTime = () => {
    return new Date().getTime();
}

getDuration = ( startTime ) => {
    return ( getCurrentTime() - startTime );
}

getInputLines = ( staticResourceName ) => {
    const fileContent = fs.readFileSync( '../apex-solutions/force-app/main/default/staticresources/'+ staticResourceName + '.resource', 'UTF-8' );
    return fileContent.split( /\r?\n/ );
}

getInputLines = ( year, day ) => {
    const fileContent = fs.readFileSync( '../challenges/' + year + '/' + constructInputFileName( year, day ), 'UTF-8' );
    return fileContent.split( /\r?\n/ );
}

const MODE_REAL = 'real';
const MODE_EXAMPLE = 'example';
getInputRunmode = () => {
    let scriptParams = process.argv; // [ {Node.exe path}, {script path}, {parameters} ]
    if( scriptParams.length == 2 ){
        return MODE_REAL;
    } else if( scriptParams.length == 3 ){
    	let runMode = scriptParams[ 2 ]; // real or example
    	if( runMode != MODE_REAL && runMode != MODE_EXAMPLE ){
            throw Exception( 'Please provide a valid run mode' );
        }
        return runMode;
    } else{
        throw Exception( 'please call the script either including runMode, OR without to default to example' );
    }
}

consoleLogSameLine = ( line ) => {
    process.stdout.clearLine();
    process.stdout.cursorTo( 0 );
    process.stdout.write( line );
}

module.exports = {
    // Coordinates processing
    constructCoordString, splitCoordString,
    // Input processing
    constructInputFileName, getInputLines, getInputRunmode,
    // Duration processing
    getCurrentTime, getDuration,
    // Debug/print functions
    consoleLogSameLine
};