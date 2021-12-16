/**
 * Base class allowing to centralise logic which is highly effective across distinct day-challenges.
 * Less is more, so DRY and no WET! (Don't Repeat Yourself or We Enjoy Typing, respectively)
 *
 * @author    Reinier van den Assum (rvandenassum@deloitte.nl)
 * @created   December 2021
 */
public virtual class AOC_Base{
    protected List<String> inputLines;
    protected MODE runmode;

    public enum MODE{
        EXAMPLE,
        FOR_REAL
    }
    private static final Map<MODE, String> SR_POSTFIX_BYMODE = new Map<MODE, String>{
        MODE.EXAMPLE => 'Example',
        MODE.FOR_REAL => 'Input'
    };

    /**
     * INPUT PROCESSING
     */

    /**
     * Most crucial method of them all. Parsing the input file to some Apex-comfortable format.
     * Due to Exception checks, extending classes can assume inputLines are correctly formatted.
     *
     * @param staticResourceFileStart   Start of StaticResource renamed saved in Salesforce to be processed, to be completed by run mode
     * @exception                       InvalidDataException when input isn't valid (e.g. SR doesn't exist, is left empty)
     */
    protected void setInputLines( String staticResourceFileStart ){
        String staticResourceFileName = staticResourceFileStart + '_' + SR_POSTFIX_BYMODE.get( this.runmode );
        List<StaticResource> srList = [SELECT Id, Body FROM StaticResource WHERE Name = :staticResourceFileName];
        String input = ( !srList.isEmpty() ) ? srList[ 0 ].Body?.toString() : null ;
        if( String.isBlank( input ) ){
            throw new InvalidDataException( 'No/Empty static resource was found with name ' + staticResourceFileName + ': ' + JSON.serializePretty( srList ) );
        }

        // No need to check for 'trailing enters' as those are automatically ignored by Salesforce
        this.inputLines = input.split( '\\n' );
    }

    /**
     * Util method to allow splitting a String and directly converting the values to Integers (trimming if needed)
     *
     * @param input         String of Integer values, separated by character
     * @param separator     Character values in String are separated by
     * @return              List of Integer values
     */
    protected List<Integer> splitStringToIntegers( String input, String separator ){
        List<Integer> outputList = new List<Integer>();
        List<String> stringInputs = input.split( separator );
        for( Integer i = 0, j = stringInputs.size(); i < j; i++ ){
            try{
                outputList.add( Integer.valueOf( stringInputs[ i ].trim() ) );
            } catch( Exception ex ){
                System.debug( '*** '+ ex.getMessage() );
                System.debug( '*** Tried to parse '+ JSON.serializePretty( stringInputs ) + ' at index ' + i );
                throw ex;
            }
        }
        return outputList;
    }

    /**
     * COLLECTION SUPPORT
     */

    /**
     * Method to easily add an Object into a List stored within a Map
     */
    protected void addToListInMap( Map<String, List<String>> inputMap, String keyString, String valString ){
        if( inputMap.containsKey( keyString ) ){
            inputMap.get( keyString ).add( valString );
        } else{
            inputMap.put( keyString, new List<String>{ valString } );
        }
    }

    /**
     * Method to easily increase a Counter in a Map based on the provided Key, to avoid duplicate containsKey() scattered through code
     */
    protected void increaseCounter( Map<String, Long> countMap, String key, Long numToAdd ){
        Long currentValue = countMap.get( key );
        if( currentValue == null ){ currentValue = 0; }
        countMap.put( key, ( currentValue + numToAdd ) );
    }

    /**
     * CONVERSION SUPPORT
     */
    protected Long binaryToLong( String value ){
        Long result;
        if( String.isNotBlank( value ) && value.containsOnly( '01' ) ){
            result = 0;
            for( String s : value.split( '' ) ){
                result = ( result << 1 ) | ( s == '1' ? 1 : 0 );
            }
        }
        return result;
    }

    /**
     * While Apex' Math.round() does round to the nearest neighbor, on 'equal distance' aka 0.5 it rounds
     * to the even neighbor, instead to always round up. Hence, this doesn't behave like standard mathematics.
     * This method allows to round() to the nearest neighbor AND up when exactly 0.5.
     */
    protected Integer roundToInteger( Decimal value ){
        // Integer.valueOf() simply cuts the decimal values 1.9 > 1; hence, add 0.5 and then strip all decimal values
        // This way 1.5 becomes 2.0 and is stripped to 2; while 1.2 becomes 1.7 and thus remains 1;
        return Integer.valueOf( value + 0.5 );
    }

    public class InvalidDataException extends Exception{}


    /**
     * REUSABLE DATA STRUCTURES
     */
    /**
     * Inner Coordinate class to easily 'share' x-y coords without need of String manipulations (split, etc.) and casting (to Integer)
     */
    public class Coordinate{
        public Integer x;
        public Integer y;
        public Coordinate( Integer xInput, Integer yInput ){
            this.x = xInput;
            this.y = yInput;
        }
        public Coordinate( String coordInput ){
            List<String> coords = coordInput.split( ',' );
            this.x = Integer.valueOf( coords[ 0 ] );
            this.y = Integer.valueOf( coords[ 1 ] );
        }

        public String getString(){
            return this.x + ',' + this.y;
        }
    }

    /**
     * VISUALIZATION / DEBUG MECHANISMS
     */
    /**
     * Method to plot a List of Coordinates onto a visual Matrix, independent of coordinate-ranges (like console.table)
     * 1) Loop over all coordinates and add them to a List<List<>> structure for easier display
     *      Ensure the index exists before populating the value
     * 2) Optionally construct the header and row logic to show nicely, without causing space-imperfections
     * 3) Loop over the matrix rows and columns and display nicely in debug
     *
     * @param coordLines    (Req.) List of Coordinates which should be displayed
     * @param filledChar    (Opt.) Character to show when Coordinate was in the input-list; default 'x'; should be max 1 character
     * @param emptyChar     (Opt.) Character to show for all Coordinates not in the input-list; default ' '; should be max 1 character
     * @param showIndices   (Opt.) Boolean to indicate whether indices should be shown as header (column-index) and line-prefix (row-index)
     */
    public void displayListCoordinates( List<Coordinate> coordLines ){
        this.displayListCoordinates( coordLines, 'x', ' ', true );
    }
    public void displayListCoordinates( List<Coordinate> coordLines, String filledChar, String emptyChar, Boolean showIndices ){
        // Convert Coordinates-List to Matrix (aka List<List<>>), ensuring the Matrix has sufficient rows and columns
        List<List<String>> matrix = new List<List<String>>();
        for( Integer i = 0, j = coordLines.size(); i < j; i++ ){
            Coordinate coord = coordLines[ i ];
            // Ensure there are sufficient rows to fit the y-coordinate
            if( matrix.size() - 1 < coord.y ){
                for( Integer n = matrix.size(), m = coord.y; n <= m; n++ ){
                    matrix.add( new List<String>() );
                }
            }
            // Ensure there are sufficient columns for this row to fit the x-coordinate
            if( matrix[ coord.y ].size() - 1 < coord.x ){ // size() is always +1 compared to 'lastIndex'
                // For completeness (and consistency) ensure all rows have sufficient columns
                for( Integer r = 0, p = matrix.size(); r < p; r++ ){
                    List<String> columnsOfRow = matrix[ r ];
                    for( Integer c = columnsOfRow.size(), d = coord.x; c <= d; c++ ){
                        columnsOfRow.add( emptyChar );
                    }
                }
            }
            // Set filled-character in the x,y location
            matrix[ coord.y ][ coord.x ] = filledChar;
        }
        // After full matrix-construction/conversion - dump the table!
        System.debug( LoggingLevel.INFO, 'MATRIX OUTPUT' );
        Integer numRowDigits = String.valueOf( matrix.size() ).length() + 1; // set to 3 if 100 to ensure the table is properly aligned + 1 for nicer looks
        if( showIndices ){ // Draft index header
            Integer numColums = matrix[ 0 ].size();

            // Construct the 'header-rows' to indicate the hundreds and tens to allow a vertical index-construction to avoid column-width issues
            List<String> hundredIndicators = new List<String>();
            List<String> tenIndicators = new List<String>();
            List<String> singleIndicators = new List<String>();
            List<String> axisNumberSeparator = new List<String>();

            for( Integer i = 0; i < numColums; i++ ){
                // In case a round hundred/ten increase (e.g. 100, 200, 300), store that number; same for tens
                hundredIndicators.add( ( Math.mod( i, 100 ) == 0 ) ? String.valueOf( i / 100 ) : ' ' );
                tenIndicators.add( ( Math.mod( i, 10 ) == 0 ) ? String.valueOf( i / 10 ) : ' ' );
                singleIndicators.add( String.valueOf( Math.mod( i, 10 ) ) );
                axisNumberSeparator.add( '-' );
            }

            // Construct header-prefix to make sure the header and value rows align nicely (value rows are preceided with rownumber)
            String headerPrefix = this.lPad( '', numRowDigits, ' ' ) + '  '; // add number of spaces for number of RowDigits + 2 for 'clarity'
            if( numColums > 100 ){  System.debug( LoggingLevel.INFO, headerPrefix + String.join( hundredIndicators, ' ' ) ); }
            if( numColums > 10 ){   System.debug( LoggingLevel.INFO, headerPrefix + String.join( tenIndicators, ' ' ) ); }
            System.debug( LoggingLevel.INFO, headerPrefix + String.join( singleIndicators, ' ' ) );
            // Dump a line between header index numbers and matrix-values
            System.debug( LoggingLevel.INFO, headerPrefix + String.join( axisNumberSeparator, ' ' ) );
        }

        for( Integer r = 0, p = matrix.size(); r < p; r++ ){
            System.debug( LoggingLevel.INFO,
                ( ( showIndices ) ? this.lPad( String.valueOf( r ), numRowDigits, ' ' ) + '  ' : '' )
                + String.join( matrix[ r ], ' ' ) );
        }
    }

    /**
     * Method to centralise the prefixing of a text value to ensure the total width/length of that text matches the input-requirement
     */
    public String lPad( String text, Integer length, String paddingCharacter ){
        String result = String.isBlank( text ) ? '' : text;
        while( result.length() < length ){
            result = paddingCharacter + result;
        }
        return result;
    }
}