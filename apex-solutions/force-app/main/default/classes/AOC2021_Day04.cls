/**
 * Class to support all logic for the fourth days' challenge!
 * Call as:
 *  AOC2021_Day04 challenge = new AOC2021_Day04( AOC_Base.MODE.EXAMPLE );
 *  challenge.part2();
 *  challenge.part1();
 * Note, SF logs has some issues with volume of processing; calling part2() and then part1() prints all correct
 * The other way around for some reason swallows the System.debugs() of part1...
 *
 * Note, ideally one would have simply stored the occurrence of each number in the List of inputs.
 * That way simply the Math.max() over each column and row would have given you the Bingo-round number.
 * Nevertheless, since answer of winning BingoBard is the sum of unmarked numbers, that also need to be tracked,
 * hence, the iterative approach to first initiate all BingoBoards and only after start checking drawn numbers sequentially.
 *
 * @author    Reinier van den Assum (rvandenassum@deloitte.nl)
 * @created   December 2021
 */
public with sharing class AOC2021_Day04 extends AOC_Base{
    private List<Integer> drawnNumbersInOrder; // List, since Sets are ordered
    private List<BingoBoard> boardList = new List<BingoBoard>();

    public AOC2021_Day04( AOC_Base.MODE runmode ){
        this.runmode = runmode;
        this.setInputLines( 'AOC2021_Day04' );
        // Process the input to set the drawnNumbers and initiate all Boards
        this.processInput();
    }

    public void part1(){
        // Make copy of processed Boards to avoid any removals etc to impact other methods
        // Note .clone() doesn't change reference to BingoBard and .deepClone() is only allowed to SObjects. Hence, JSON parsing
        List<BingoBoard> boards = ( List<BingoBoard> ) JSON.deserializeStrict( JSON.serialize( this.boardList ), List<BingoBoard>.class );
        Integer winningBoardSum;
        Integer drawnNumber;

        // Loop over the drawn numbers and for each Board check whether that results in Bingo
        // For the first Board hitting Bingo (even while could be one having Bingo on same drawn number), stop and return sum
        for( Integer i = 0, j = this.drawnNumbersInOrder.size(); i < j; i++ ){
            drawnNumber = this.drawnNumbersInOrder[ i ];
            for( Integer b = 0, c = boards.size(); b < c; b++ ){
                if( boards[ b ].processNumber( drawnNumber ) ){
                    winningBoardSum = boards[ b ].getSumOfNumbers();
                    System.debug( '*** Bingo on board with index '+ b + '!' );
                    break;
                }
            }
            // Check whether a Board has hit Bingo, else continue by 'drawing' next number
            if( winningBoardSum != null ){
                break;
            }
        }
        System.debug( '*** Answer part 1: First Board won by number '+ drawnNumber + ' with remaining sum of '+ winningBoardSum + ', so: '+ winningBoardSum * drawnNumber );
    }

    public void part2(){
        // Make copy of processed Boards to avoid any removals etc to impact other methods
        // Note .clone() doesn't change reference to BingoBard and .deepClone() is only allowed to SObjects. Hence, JSON parsing
        List<BingoBoard> boards = ( List<BingoBoard> ) JSON.deserializeStrict( JSON.serialize( this.boardList ), List<BingoBoard>.class );
        Integer lastWinningBoardSum;
        Integer drawnNumber;

        // Loop over the drawn numbers and for each Board check whether that results in Bingo
        // For each Board hitting Bingo, remove it from the Board list and continue till the only remaining Board hits bingo
        for( Integer i = 0, j = drawnNumbersInOrder.size(); i < j; i++ ){
            drawnNumber = drawnNumbersInOrder[ i ];
            for( Integer b = 0, c = boards.size(); b < c; b++ ){
                if( boards[ b ].processNumber( drawnNumber ) ){
                    if( c == 1 ){ // When this is the last Board in the list claiming "Bingo!"
                        lastWinningBoardSum = boards[ b ].getSumOfNumbers();
                        // No need to 'break' as for-loop would be done either way
                    } else{
                        boards.remove( b );
                        b--; c--; // Decrease indices to make sure for-loop continues correctly
                    }
                }
            }
            // Check whether a Board has hit Bingo, else continue by 'drawing' next number
            if( lastWinningBoardSum != null ){
                break;
            }
        }
        System.debug( '*** Answer part 2: Last board won by number ' + drawnNumber + ' with remaining sum of '+ lastWinningBoardSum + ' so '+ lastWinningBoardSum * drawnNumber );
    }

    private void processInput(){
        // Split first line to know which numbers are drawn
        this.drawnNumbersInOrder = this.splitStringToIntegers( this.inputLines[ 0 ], ',' );

        // Loop over input lines, when empty, create a new Board, else, split the input and add as a Row to the Board
        Integer boardIndex = -1; // set to -1 since first line is always empty, to first board initiation will set this to 0;
        for( Integer i = 1, j = this.inputLines.size(); i < j; i++ ){
            String rowString = inputLines[ i ];
            if( String.isNotBlank( rowString ) ){
                // Add Row to the Board, splitting by regex and trimming;
                // - Regex is required to parse duplicate spaces correctly, as board-input is nicely visualized " 5 19  8  7" etc
                // - Trim is required to parse first-character spaces; else you'd get e.g. [ " ", "5", "19", " ", "8", " ", "7"]
                this.boardList[ boardIndex ].addRowOfNumbers( this.splitStringToIntegers( rowString.trim(), '[ ]+' ) );
            } else{
                // When empty line of input, interpret to set a new BoardIndex
                this.boardList.add( new BingoBoard() );
                boardIndex++;
            }
        }
    }

    /**
     * Wrapper class to keep track of a BingoBoard. Split to Rows and Columns since visualization is not (yet) required
     * and this allows easier processing then handling a List<Set<>>
     *
     * Note, a List<Set> is required as per row/column the order doesn't matter for processing, but Set is more
     * efficient than List since it is ordered; allowing e.g. a quicker removal as the value can be used instead of first looping all items for index
     */
    private class BingoBoard{
        List<Set<Integer>> remainingRows = new List<Set<Integer>>();
        List<Set<Integer>> remainingCols = new List<Set<Integer>>();
        Integer matrixSize = 0;

        public void addRowOfNumbers( List<Integer> rowInput ){
            // Simply add the new row after the previously known Rows
            remainingRows.add( new Set<Integer>( rowInput ) );

            // Loop over new input Row and add to each columns-List
            Boolean firstInitiation = remainingRows.size() == 1;
            for( Integer i = 0, j = rowInput.size(); i < j; i++ ){
                if( firstInitiation ){ // First row of numbers being added, construct N column-Lists (number of items in row)
                    remainingCols.add( new Set<Integer>{ rowInput[ i ] } );
                } else{
                    remainingCols[ i ].add( rowInput[ i ] );
                }
            }

            // Increase matrix size, so when processing we can avoid to fetch List.size() each iteration
            matrixSize++;
        }

        /**
         * Logic to loop over all rows & columns and remove the drawn number.
         * Each time a number is removed, check whether that row/column still has any numbers left.
         * If not, mark as Bingo, but makes sure all other rows/columns are still processed, since it is traversed
         * so when on row 1 the original last number matched, this number would be in the last 'column-row'
         */
        public Boolean processNumber( Integer newNumber ){
            Boolean hasBingo = false;
            for( Integer i = 0; i < matrixSize; i++ ){
                if( remainingRows[ i ].remove( newNumber ) && remainingRows[ i ].isEmpty() ){
                    hasBingo = true;
                }
                if( remainingCols[ i ].remove( newNumber ) && remainingCols[ i ].isEmpty() ){
                    hasBingo = true;
                }
            }
            return hasBingo;
        }

        /**
         * Method to loop over the remaining rows to calculate the sum.
         * Note, size of each row-Set might differentiate as only remaining values are kept in the Set
         * @return Sum of all Integers remaining on the BingoBoard
         */
        public Integer getSumOfNumbers(){
            Integer totalSum = 0;
            for( Integer i = 0; i < matrixSize; i++ ){
                for( Integer val : remainingRows[ i ] ){
                    totalSum += val;
                }
            }
            return totalSum;
        }
    }
}