/**
 * Method to allow speedy creation of files and make sure consistent and correct (day/year references)
 * node generate.js 2022 11
 */
let scriptParams = process.argv; // [ {Node.exe path}, {script path}, {parameters} ]
if( scriptParams.length !== 4 ){
    throw Exception( 'Please call the script with both year and day number e.g. node generate.js 2022 04' );
}
const year = scriptParams[ 2 ];
const day = scriptParams[ 3 ];

const utils = require( './utils.js' );
utils.createInputFiles( year, day );
utils.createScriptFile( year, day );