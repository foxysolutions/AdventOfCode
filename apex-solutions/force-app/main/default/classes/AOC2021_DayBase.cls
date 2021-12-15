/**
 * Class to support all logic for the Nth days' challenge!
 * Call as:
 *  AOC2021_DayBase challenge = new AOC2021_DayBase( AOC_Base.MODE.EXAMPLE );
 *  challenge.part1();
 *  challenge.part2();
 *
 * @author    Reinier van den Assum (rvandenassum@deloitte.nl)
 * @created   December 2021
 */
public with sharing class AOC2021_DayBase extends AOC_Base{
    public AOC2021_DayBase( AOC_Base.MODE runmode ){
        this.runmode = runmode;
        this.setInputLines( 'AOC2021_DayBase' );
    }

    public void part1(){
        for( Integer i = 0, j = inputLines.size(); i < j; i++ ){
            String str = inputLines[ i ];
            System.debug( '*** ' + str );
        }
        System.debug( '*** Answer part 1: ' );
    }

    public void part2(){
        System.debug( '*** Answer part 2: ' );
    }
}