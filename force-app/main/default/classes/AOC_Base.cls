/**
 * Base class allowing to centralise logic which is highly effective across distinct day-challenges.
 * Less is more, so DRY and no WET! (Don't Repeat Yourself or We Enjoy Typing, respectively)
 *
 * @author    Reinier van den Assum (rvandenassum@deloitte.nl)
 * @created   December 2021
 */
public virtual class AOC_Base{
    protected List<String> inputLines;

    /**
     * Most crucial method of them all. Parsing the input file to some Apex-comfortable format.
     * Due to Exception checks, extending classes can assume inputLines are correctly formatted.
     *
     * @param staticResourceFileName    Name of the StaticResource saved in Salesforce to be processed
     * @exception                       InvalidDataException when input isn't valid (e.g. SR doesn't exist, is left empty)
     */
    protected void setInputLines( String staticResourceFileName ){
        List<StaticResource> srList = [SELECT Id, Body FROM StaticResource WHERE Name = :staticResourceFileName];
        String input = ( !srList.isEmpty() ) ? srList[ 0 ].Body?.toString() : null ;
        if( String.isBlank( input ) ){
            throw new InvalidDataException( 'No/Empty static resource was found with name '+ staticResourceFileName + ': '+ JSON.serializePretty( srList ) );
        }

        // No need to check for 'trailing enters' as those are automatically ignored by Salesforce
        this.inputLines = input.split( '\\n' );
    }

    public class InvalidDataException extends Exception{}
}