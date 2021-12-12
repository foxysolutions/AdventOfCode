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
     * Method to easily add an Object into a List stored within a Map
     */
    public static void addToListInMap( Map<String, List<String>> inputMap, String keyString, String valString ){
        if( inputMap.containsKey( keyString ) ){
            inputMap.get( keyString ).add( valString );
        } else{
            inputMap.put( keyString, new List<String>{ valString } );
        }
    }

    protected Integer binaryToInteger( String value ){
        Integer result;
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
}