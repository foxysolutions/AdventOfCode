/**
 * Class to support all logic for the 21th days' challenge!
 * Call as:
 *  AOC2021_Day21 challenge = new AOC2021_Day21( AOC_Base.MODE.EXAMPLE );
 *  challenge.part1();
 *  // challenge.part2(); - unfortunately NOT possible in Apex...
 *
 * @author    Reinier van den Assum (rvandenassum@deloitte.nl)
 * @created   December 2021
 */
public with sharing class AOC2021_Day21 extends AOC_Base{
    public AOC2021_Day21( AOC_Base.MODE runmode ){
        this.runmode = runmode;
        this.setInputLines( 'AOC2021_Day21' );
    }

    /**
     * Method to find the first Player to reach the maxScore based on a 1-100 dice
     * Note, with retrospect the initiation of a Players could have been limited to only two
     */
    public void part1(){
        Integer maxScore = 1000;
        List<Player> players = new List<Player>();
        for( Integer i = 0, j = inputLines.size(); i < j; i++ ){
            players.add( new Player( Integer.valueOf( inputLines[ i ].split( ': ' )[ 1 ] ), maxScore, i + 1 ) );
        }

        Boolean hasWinningUser = false;
        Long losingScore;
        Integer middleNextThrow = 2; // Set to middle of first three throws, 1, 2, 3
        Integer numDiceRolls; // To be set when winning player is identified
        while( !hasWinningUser ){
            for( Integer i = 0, j = players.size(); i < j; i++ ){
                Player player = players[ i ];

                // Throw 3-dice three times | keep track of middle next one since: 1 + 2 + 3 = 6 ==> 3 * 2 (middle #)
                // Move Player to new position based on num eyes thrown and check if the player has won
                // When won, break for-loop to prevent any following player to also still throw, even while player has won
                if( player.performSteps( 3 * middleNextThrow ) ){
                    hasWinningUser = true;
                    losingScore = players[ 1 - i ].score;
                    numDiceRolls = middleNextThrow + 1; // Set number of Dice roll (middle of last one + 1 to get the last one)
                    break;
                }
                // Else, when no winning throw, increase the middleLastDiceThrow for next player
                // Note, no need to take care of max. of 100, since the %10 for the steps in the perform steps already eliminates
                middleNextThrow += 3;
            }
        }
        System.debug( '*** Answer part 1: ' + losingScore + ' * ' + numDiceRolls + ' = ' + losingScore * numDiceRolls );
    }

    private class Player{
        Integer playerNum;
        Integer currPositionIndex;
        Long score = 0;
        Integer winningScore;

        Player( Integer startPosition, Integer winningScore, Integer playerNumber ){
            this.currPositionIndex = startPosition - 1;
            this.winningScore = winningScore;
            this.playerNum = playerNumber; // used for debugging
        }

        Boolean performSteps( Integer numMoves ){
            this.currPositionIndex = Math.mod( this.currPositionIndex + numMoves, 10 );
            this.score += ( this.currPositionIndex + 1 );
            return ( this.score >= winningScore );
        }
    }

    /**
     * Method to handle part2() where each turn one player introduces 3 new universes where each player continues till the winning-score is reached
     * While a player wins when a minimum score of 21 is reached, the number of iterations increases significantly.
     * In Apex this becomes slightly a challenge due to the Apex CPU Limits (10sec Sync and 60sec Async);
     * - Synchronous:   Able to find the highest number of wins till a score of 14
     * - Asynchronous:  Able to find the highest number of wins till a score of 18/19
     * Unfortunately our multi-universal-dice-roll-challenge has a winning score threshold of 21, which is too much
     * Runtime approx. doubles per increase of winning score (11 [700-750ms], 12 [2000-2500ms], 13 [4500-5000ms], 14 [8500-9000ms])
     *
     * Luckily, the program state is simple and allows to be split in multiple 'isolated' jobs
     * Since "Future method cannot be called from a future or batch method" (preventing a Future to trigger a follow-up Future),
     * Queueables are used to solve as much as possible and then chain a next one to allow up till 5 times 60 seconds
     *
     * Unfortunately, both todays' inputs (Example and Real) have one iteration which costs more than 60 seconds on it's own...
     * Still committed the code, since the first 2 throws of Real Input are feasible in one Queueable
     */
    public void part2(){
        // Determine input when in instance-mode and having inputLines available; not needed afterwards
        Integer posP1 = Integer.valueOf( inputLines[ 0 ].split( ': ' )[ 1 ] ) - 1;
        Integer posP2 = Integer.valueOf( inputLines[ 1 ].split( ': ' )[ 1 ] ) - 1;
        System.debug( '*** Performing part2() Asynchronous, so check Logs for created Queueable' );
        System.enqueueJob( new Queue_DiracDiceRoll( posP1, posP2, 0, null ) );
    }

    private class CumulativeThrow{
        Integer throwTotal;
        Integer throwFrequency;
        CumulativeThrow( Integer rollSum, Integer freq ){
            this.throwTotal = rollSum;
            this.throwFrequency = freq;
        }
    }
    // List number of options to get a totalNumber based on three dice resulting in 1, 2 or 3
    public static List<CumulativeThrow> CUMULATIVE_THROWS = new List<CumulativeThrow>{
        new CumulativeThrow( 3, 1 ), // 1+1+1
        new CumulativeThrow( 4, 3 ), // 1+1+2, 1+2+1, 2+1+1
        new CumulativeThrow( 5, 6 ),
        new CumulativeThrow( 6, 7 ),
        new CumulativeThrow( 7, 6 ),
        new CumulativeThrow( 8, 3 ), // 2+3+3, 3+2+3, 3+3+2
        new CumulativeThrow( 9, 1 )  // 3+3+3
    };

    public class Queue_DiracDiceRoll implements Queueable{
        Integer posP1, posP2, currRollFrequencyIndex;
        List<Long> numWinsPrevAsync;
        Integer MAX_CPU_LIMIT;

        public Queue_DiracDiceRoll( Integer posP1, Integer posP2, Integer lastInProcessRFIndex, List<Long> numPrevWins ){
            this.posP1 = posP1;
            this.posp2 = posp2;
            this.currRollFrequencyIndex = lastInProcessRFIndex;
            this.numWinsPrevAsync = numPrevWins;
            System.debug( '*** New Instance: positions [' + this.posP1 + ', ' + this.posP2 + ']; and CumThrow Index ' + this.currRollFrequencyIndex + '; previous wins ' + numPrevWins );
        }

        public void execute( QueueableContext ctx ){
            Long start = System.now().getTime();
            // Only define CPU Limit within Execute() as initiation is initially performed in Synchronous mode (thus 10s instead of 60s)
            this.MAX_CPU_LIMIT = Limits.getLimitCpuTime();

            // Determine number of wins given current player positions
            List<Long> numWinsPerPlayer = calculateWins( posP1, 0, posP2, 0 );
            // Combine current output (either [ Long, Long ] or null) with optional WinStates of previous Async jobs
            if( numWinsPrevAsync != null ){
                if( numWinsPerPlayer == null ){
                    numWinsPerPlayer = numWinsPrevAsync;
                } else{
                    numWinsPerPlayer[ 0 ] += numWinsPrevAsync[ 0 ];
                    numWinsPerPlayer[ 1 ] += numWinsPrevAsync[ 1 ];
                }
            }

            if( ALL_PROCESSED ){
                Long maxWins = Math.max( numWinsPerPlayer[ 0 ], numWinsPerPlayer[ 1 ] );
                System.debug( '*** Answer part 2: ' + maxWins );
            } else{
                System.debug( '*** Apex CPU Limit was almost reached, hence triggered new Async Job to continue' );
                System.enqueueJob( new Queue_DiracDiceRoll( posP1, posP2, currRollFrequencyIndex, numWinsPerPlayer ) );
            }
            System.debug( '*** Completed this Queueable in ' + ( System.now().getTime() - start ) );
        }

        /**
         * Recursive player-agnostic method to calculate the number of wins throughout the descending universes
         * - Since logic for player 1 vs. player 2 is identical, simply swap the players during the calculations
         * - To prevent looping 3 dice each time, the roll-combinations are is preset using RollFrequency class
         * - To keep calculations simple the position is set by 'index' allowing % 10, else one should always add 1
         * @return WinState containing number of wins for both players, where WinState[ 0 ] relates to currPlayer
         */
        private Boolean ALL_PROCESSED = true;
        private List<Long> calculateWins( Integer posCurrPlayer, Long scoreCurrPlayer, Integer posOtherPlayer, Long scoreOtherPlayer ){
            if( scoreOtherPlayer >= 21 ){
                return new List<Long>{ 0, 1 }; // return win for otherPlayer, since currPlayer is about to roll
            }
            // Determine whether it's root recursion (then scoreOtherPlayer has no score from previous Player1)
            // Used both for 'clear debugging' and identification whether ALL Cumulative Dice Rolls or only from a certain index should be processed
            Boolean isRootRecursion = ( scoreOtherPlayer == 0 );

            if( MAX_CPU_LIMIT - Limits.getCpuTime() < 100 ){
                System.debug( '*** CPU Time limit was nearly reached, hence break: ' + Limits.getCpuTime() + ' / ' + MAX_CPU_LIMIT );
                ALL_PROCESSED = false;
                return null;
            }

            List<Long> winState = new List<Long>{ 0, 0 };
            Integer numRollFrequencies = AOC2021_Day21.CUMULATIVE_THROWS.size();
            // Loop over all possible cumulative dice combinations and their frequencies and update the Win State
            // Note, later Async Jobs should avoid processing already completed item, but lower recursions should always complete all
            // So e.g. calculate wins when Player 1 first throws 5 in total, but then also check what happens if Player 2 throws 3 in total
            for( Integer i = ( isRootRecursion ? currRollFrequencyIndex : 0 ); i < numRollFrequencies; i++ ){
                CumulativeThrow rollFrequency = AOC2021_Day21.CUMULATIVE_THROWS[ i ];
                if( isRootRecursion ){
                    System.debug( '*** Starting Player 1 iteration for ' + rollFrequency.throwTotal + ' - current CPU: ' + Limits.getCpuTime() + '/' + this.MAX_CPU_LIMIT );
                }
                // Determine new position for current player and initiate next recursion (win-check is performed on top)
                Integer newPosCurrPlayer = Math.mod( posCurrPlayer + rollFrequency.throwTotal, 10 );
                List<Long> swappedWinState = calculateWins(
                    posOtherPlayer,
                    scoreOtherPlayer,
                    newPosCurrPlayer,
                    scoreCurrPlayer + ( newPosCurrPlayer + 1 )
                );
                // When Apex CPU Limit was reached in a child, return null to parent, unless in rootRecursion
                // Note, e.g. 3, 4, 5 are completed within 60 seconds, then the calling method should know the wins per player
                if( swappedWinState == null ){
                    return ( isRootRecursion ) ? winState : null;
                }
                winState[ 0 ] += swappedWinState[ 1 ] * rollFrequency.throwFrequency;
                winState[ 1 ] += swappedWinState[ 0 ] * rollFrequency.throwFrequency;
                if( isRootRecursion ){
                    System.debug( '*** Completed iteration with swapped win ' + swappedWinState );
                    // Increase current Cumulative Dice Combinations as next Async Job would need to continue there
                    currRollFrequencyIndex++;
                }
            }
            return winState;
        }
    }
}
/**
DEBUG LOGS when running part1() and part2():

Anonymous Apex:
*** Answer part 1: 916 * 1005 = 920580
*** Performing part2() Asynchronous, so check Logs for created Queueable
*** New Instance: positions [5, 3]; and CumThrow Index 0; previous wins null
*** Completed in 42

First Queueable:
*** Starting Player 1 iteration for 3 - current CPU: 12/60000
*** Completed iteration with swapped win (9881516866, 79296121763)
*** Starting Player 1 iteration for 4 - current CPU: 28394/60000
*** Completed iteration with swapped win (783940300, 8000898413)
*** Starting Player 1 iteration for 5 - current CPU: 37096/60000
*** CPU Time limit was nearly reached, hence break: 59901 / 60000
*** Apex CPU Limit was almost reached, hence triggered new Async Job to continue
*** New Instance: positions [5, 3]; and CumThrow Index 2; previous wins (103298817002, 12233337766)
*** Completed this Queueable in 64172

Second Queueable:
*** Starting Player 1 iteration for 5 - current CPU: 9/60000
*** CPU Time limit was nearly reached, hence break: 59901 / 60000
*** Apex CPU Limit was almost reached, hence triggered new Async Job to continue
*** New Instance: positions [5, 3]; and CumThrow Index 2; previous wins (103298817002, 12233337766)
*** Completed this Queueable in 63921
*/