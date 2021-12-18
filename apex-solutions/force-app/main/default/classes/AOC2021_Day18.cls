/**
 * Class to support all logic for the 18th days' challenge!
 * Call as:
 *  AOC2021_Day18 challenge = new AOC2021_Day18( AOC_Base.MODE.EXAMPLE );
 *  challenge.part1();
 *  challenge.part2();
 *
 * Today's difficulty was in:
 * - Determine adjacent left/right value for explosions, based on only knowing parent (left/right)
 * - Correct sequential order of reduction action, always process explosions first in sequence; only process one split at the time
 *
 * @author    Reinier van den Assum (rvandenassum@deloitte.nl)
 * @created   December 2021
 */
public with sharing class AOC2021_Day18 extends AOC_Base{
    private static final Integer DEPTH_EXPLODE = 4;
    private static final Integer NUMBER_AFTER_EXPLODE = 0;
    List<String> NUMBERS_LIST = new List<String>{ '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' };
    enum NODE_POSITION{
        LEFT,
        RIGHT
    }
    // List of parsed and reduced input lines (Tree is closest data-type for a Root with multiple left/right Nodes (leaves))
    private List<SnailNode> INPUT_REDUCED_TREES = new List<SnailNode>();

    public AOC2021_Day18( AOC_Base.MODE runmode ){
        this.runmode = runmode;
        this.setInputLines( 'AOC2021_Day18' );
        // While FOR_REAL part2() is ran Async, the EXAMPLE runmode can benefit of a centralised processing of input-lines
        this.INPUT_REDUCED_TREES = this.convertAndReduceInputLines();
    }

    public void part1(){
        List<SnailNode> homeworkLines = getClonedInput();
        // Loop over lines of 'homework' and add second to first, and third to the previous sum result
        SnailNode sumResult = homeworkLines.remove( 0 );
        while( !homeworkLines.isEmpty() ){
            SnailNode nextSumRow = homeworkLines.remove( 0 );
            sumResult = new SnailNode( sumResult, nextSumRow ).reduce();
        }
        System.debug( '*** Final sum-display: ' + sumResult.getString( true ) );
        System.debug( '*** Answer part 1: ' + sumResult.getMagnitude() );
    }

    /**
     * Another day requiring Asynchronous execution, since trying all addition combinations (99x99=9801) takes 40-50sec.
     */
    public void part2(){
        switch on this.runmode{
            when EXAMPLE{
                this.performPart2();
            }
            when FOR_REAL{
                // Since it takes more than 10 seconds which is CPU Time limit, call this beauty Async
                System.debug( '*** Answer part 2: Running Async, check Log Analyzer in IDE for the answer' );
                AOC2021_Day18.runPart2Async();
            }
        }
    }
        @Future
        public static void runPart2Async(){
            Long start = System.now().getTime();
            AOC2021_Day18 classInstance = new AOC2021_Day18( AOC_Base.MODE.FOR_REAL );
            classInstance.performPart2();
            System.debug( '*** Completed Async in ' + ( System.now().getTime() - start ) + 'ms' );
        }

    public void performPart2(){
        List<SnailNode> homeworkLines = this.convertAndReduceInputLines();
        // Loop over all possible combinations (note, i+j is different than j+i in SnailMath, hence, process all combinations)
        Integer numLines = homeworkLines.size();
        Long maxMagnitude = 0;
        for( Integer i = 0; i < numLines; i++ ){
            for( Integer j = 0; j < numLines; j++ ){
                if( i == j ){ continue; } // Avoid spending processing time on adding the same line to itself
                maxMagnitude = Math.max( maxMagnitude, new SnailNode( homeworkLines[ i ].deepClone(), homeworkLines[ j ].deepClone() ).reduce().getMagnitude() );
            }
        }
        System.debug( '*** Answer part 2: ' + maxMagnitude );
    }

    /**
     * Method to convert input Strings > List<String> (performance) > SnailNode Tree
     * When Tree is constructed, Reduce the input-line to get rid of too much numbers by processing explosions and splits
     */
    private List<SnailNode> convertAndReduceInputLines(){
        List<SnailNode> processedLines = new List<SnailNode>();
        for( Integer i = 0, j = inputLines.size(); i < j; i++ ){
            List<String> snailNumChars = inputLines[ i ].split( '' );

            SnailNode root = new SnailNode(); // Construct root Node
            SnailNode prevNode;
            SnailNode currNode = root;
            NODE_POSITION currNodePosition = NODE_POSITION.LEFT;

            // Skip outer characters ('[', ']') as the root Snail is constructed above
            for( Integer c = 1, d = snailNumChars.size() - 1; c < d; c++ ){
                String nextChar = snailNumChars[ c ];
                // When new pair is provided
                if( nextChar == '[' ){
                    // Construct new ChildNode and add as Child to ParentNode, on the correct position (left vs. right)
                    prevNode = currNode;
                    currNode = new SnailNode();
                    prevNode.setNode( currNode, currNodePosition );
                    // After having currNode a fresh new Node, make sure NodePosition is reset to Left
                    currNodePosition = NODE_POSITION.LEFT;

                // When a Regular Number is provided, simply parse the number and set to the current cursor-position
                } else if( NUMBERS_LIST.contains( nextChar ) ){
                    currNode.setNumber( Integer.valueOf( nextChar ), currNodePosition );

                // Interpret ',' as position-switcher within this current Node
                } else if( nextChar == ',' ){
                    currNodePosition = NODE_POSITION.RIGHT;

                // When currentNode syntax gets closed, move cursor back to Parent
                } else if( nextChar == ']' ){
                    prevNode = currNode;
                    currNode = prevNode.parentNode;
                }
            }
            // After converting List of characters to the SnailNode-Tree, Reduce the numbers (perform Explosions and Splits)
            root.reduce();
            processedLines.add( root );
        }
        return processedLines;
    }

    /**
     * @return Cloned version to avoid reference obfuscation (e.g. on shared input, but also for part2() to guarantee each addition has same starting point)
     */
    private List<SnailNode> getClonedInput(){
        List<SnailNode> clonedList = new List<SnailNode>();
        for( Integer i = 0, j = INPUT_REDUCED_TREES.size(); i < j; i++ ){
            clonedList.add( INPUT_REDUCED_TREES[ i ].deepClone() );
        }
        return clonedList;
    }

    /**
     * Inner class to allow tracking of all details relevant for the Nodes for the SnailNumbers
     * Each Node has two positions (left and right) which both can either be a ChildNode or a number
     */
    private class SnailNode{
        // Attributes to store either a Node, or a Number - setter-methods are used to avoid both assigned for one position
        public SnailNode leftNode;
        public SnailNode rightNode;
        public Integer leftNumber;
        public Integer rightNumber;
        // Keep track of two-way-relation, allow easier depth processing
        public SnailNode parentNode;

        /**
         * Multiple Constructors to support different phases in process:
         * - No parameters - during input parsing and cloning
         * - Two SnailNodes - during addition of sums
         */
        SnailNode(){}
        SnailNode( SnailNode a, SnailNode b ){
            this.setNode( a, NODE_POSITION.LEFT );
            this.setNode( b, NODE_POSITION.RIGHT );
        }

        /**
         * GETTER METHODS
         */

        /**
         * @param showDepth TRUE to show the depth in front of each Node for easier debugging
         * @return          Readable format of the current SnailNode and it's childNotes
         */
        public String getString( Boolean showDepth ){
            return ( ( showDepth ) ? '(' + this.getDepth() + ') ' : '' )
                + '[ ' + ( ( this.leftNode != null ) ? this.leftNode.getString( showDepth ) : String.valueOf( this.leftNumber ) )
                + ', '
                + ( ( this.rightNode != null ) ? this.rightNode.getString( showDepth ) : String.valueOf( this.rightNumber ) )
                + ' ]';
        }

        /**
         * Recursive method to calculate the Depth of the current Node.
         * Initially stored of a depth-Integer, but with the additions, this required too much manipulations
         */
        public Integer getDepth(){
            return ( this.parentNode != null ) ? this.parentNode.getDepth() + 1 : 0;
        }

        /**
         * Recursive method to calculate the magnitude ( 3 * leftValue + 2 * rightValue ) from the current Node and it's childs
         */
        public Long getMagnitude(){
            return ( ( this.leftNumber == null ) ? this.leftNode.getMagnitude() : this.leftNumber ) * 3
                + ( ( this.rightNumber == null ) ? this.rightNode.getMagnitude() : this.rightNumber ) * 2;
        }

        /**
         * SETTER METHODS
         */

        /**
         * Method to set a Node and automatically reference parentNode and ensure the relative Number is cleared for consistency
         */
        public SnailNode setNode( SnailNode s, NODE_POSITION inputPos ){
            if( s == null ){ return this; } // Avoid null-pointers and simplify deepClone logic
            s.parentNode = this;
            switch on inputPos{
                when LEFT{
                    this.leftNode = s;
                    this.leftNumber = null;
                }
                when RIGHT{
                    this.rightNode = s;
                    this.rightNumber = null;
                }
            }
            return this;
        }

        /**
         * Method to set a Number and automatically ensure the relative Node is cleared for consistency
         */
        public SnailNode setNumber( Integer regularNumber, NODE_POSITION inputPos ){
            if( regularNumber == null ){ return this; } // Avoid incorrectly removing a Node when keeping deepClone logic simple
            switch on inputPos{
                when LEFT{
                    this.leftNumber = regularNumber;
                    this.leftNode = null;
                }
                when RIGHT{
                    this.rightNumber = regularNumber;
                    this.rightNode = null;
                }
            }
            return this;
        }
        public SnailNode increaseNumber( Integer numberIncrement, NODE_POSITION inputPos ){
            switch on inputPos{
                when LEFT{
                    this.leftNumber += numberIncrement;
                }
                when RIGHT{
                    this.rightNumber += numberIncrement;
                }
            }
            return this;
        }


        /**
         * Method to reduce() the SnailNumbers - aka, perform all Explosions and Splits till there are no one left
         * Applying a do-while, to ensure each next item is automatically picked up
         * Crucial:
         * - ALL Explosions should be processed first, from left to right (Explosions cannot cause new Explosions, but can cause Splits)
         * - Splits should be processed from left to right AND might cause an Explosion which should be processed first
         *      In addition a Split, causing an Explosion could cause a new Split-eligible Node to occur more to the left
         *
         * Because of the above, it's implemented to always loop through full Tree to check for Exploding-Nodes
         * Then, when none left, process the first-next Split; pause and loop over Exploding-eligible-Nodes again, till no Splits possible
         */
        public SnailNode reduce(){
            Boolean splitHappened = false;
            do{
                // Process all Explosion from left to right
                this.handleExplosions();

                // By definition all left-most splits should be handled first, hence, start tree-search each time from top of Tree,
                // as one Split might cause an Explosion which then cause a Split to be required more to the left
                splitHappened = this.handleNextSplit();
            } while( splitHappened );
            return this;
        }

        /**
         * REDUCTION ACTIONS
         */

        /**
         * Recursive method to loop over all Nodes and check if any depth is greater or equal than the Explosion-threshold
         * When a Node should Explode based on Reduction-ruling:
         * - Replace current pair by 0
         * - Move leftNumber to the adjacent left number (where adjacent refers to the string-syntax)
         * - Move rightNumber to the adjacent right number (where adjacent refers to the string-syntax)
         */
        public void handleExplosions(){
            this.handleExplosions( null );
        }
        private void handleExplosions( NODE_POSITION currNodePositionOnParent ){
            if( this.leftNode != null ){
                this.leftNode.handleExplosions( NODE_POSITION.LEFT );
            }
            if( this.rightNode != null ){
                this.rightNode.handleExplosions( NODE_POSITION.RIGHT );
            }

            if( this.getDepth() >= DEPTH_EXPLODE && this.leftNode == null && this.rightNode == null ){
                // Assumption is that an exploding Pair/Node would only contain Numbers and no ChildNodes
                this.increaseAdjacentNumber( this.leftNumber, NODE_POSITION.LEFT );
                this.increaseAdjacentNumber( this.rightNumber, NODE_POSITION.RIGHT );

                // Remove current node from NodeGraph and replace by number 0
                this.parentNode.setNumber( NUMBER_AFTER_EXPLODE, currNodePositionOnParent );
            }
        }

        /**
         * Recursive method to loop through all Nodes (left-to-right) to detect if a split is needed (two-digit-number)
         * When a Number should be Split based on Reduction-ruling:
         * - Replace the Number by a Pair, where the values are:
         *      Left: Half of the Number, 0.5 rounded down
         *      Right: Half of the Number, 0.5 rounded up
         *
         * @return TRUE when a split was performed, FALSE when no regular number exceeded or equaled 10
         */
        public Boolean handleNextSplit(){
            if( this.leftNode != null ){
                Boolean splitInChildHappened = this.leftNode.handleNextSplit();
                // When a Child was split, return true to first process Explosions again; else don't return to continue with Right Position
                if( splitInChildHappened ){
                    return true;
                }
            } else if( this.leftNumber >= 10 ){
                this.splitNumber( this.leftNumber, NODE_POSITION.LEFT );
                return true;
            }

            if( this.rightNode != null ){
                return this.rightNode.handleNextSplit();
            } else if( this.rightNumber >= 10 ){
                this.splitNumber( this.rightNumber, NODE_POSITION.RIGHT );
                return true;
            }
            return false;
        }

            /**
             * Utility method to effectively perform the split, given the number to split and which position in the Node it should be placed
             */
            private void splitNumber( Integer numToSplit, NODE_POSITION position ){
                this.setNode(
                    new SnailNode()
                        .setNumber( numToSplit / 2, NODE_POSITION.LEFT ) // Let Apex calculate and return Integer (so floor())
                        .setNumber( Integer.valueOf( ( numToSplit / 2.0 ) + 0.5 ), NODE_POSITION.RIGHT ), // Ensure .5 is rounded up
                    position
                );
            }

        /**
         * Utility method to effectively increase a value from an Exploded Node to the adjacent number on left or right;
         * Below one finds some examples for the RIGHT-adjacent number, where only a subset of the tree is shown;
         * - 0 is a Node with children
         * - [] indicates the exploding Node
         * - x is the increased number; - refers to any other number, irrelevant for this example
         * 1)          2)               3)
         *  [],x             0               0
         *                 0   x,-       0       0
         *               0 []          0  []  x,-  0
         *
         * As one can see there are 3 scenarios:
         * 1) Adjacent position is on same Node                     When searching Right value after exploding the Left position of a Node
         * 2) Adjacent position is first child in sibling branch    When exploding node is most-right Node of a Left-branch
         *                                                          and first Parent with a different Left Node only has a Left number
         * 3) Adjacent position is down in a sibling branch         Similar to 2) but then the first-Parent also has a full branch down
         *                                                          Note, in this Right-adjacent search, due to the Branch-swap, direction ALSO SWAPS!
         */
        public void increaseAdjacentNumber( Integer numberToAdd, NODE_POSITION position ){
            switch on position{
                when LEFT{
                    // Get closest/adjacent Left number compared to current (Exploding) position
                    if( this.parentNode.leftNumber != null ){
                        this.parentNode.increaseNumber( numberToAdd, position );
                    } else{
                        SnailNode parentWithDiffLeftNode = this.getFirstParentWithLeftNode();
                        if( parentWithDiffLeftNode == null ){ return; } // No more Left Node exists
                        // When Exploding Node was in Right-Branch, and Left is just a number, simply increase
                        if( parentWithDiffLeftNode.leftNumber != null ){
                            parentWithDiffLeftNode.increaseNumber( numberToAdd, position );

                        // When directions are shift, and the Left adjacent value is now on the most Right Number of the Left Parent Adjacent node
                        } else{
                            parentWithDiffLeftNode.leftNode.getMostRightNodeWithNumber().increaseNumber( numberToAdd, NODE_POSITION.RIGHT );
                        }
                    }
                }
                when RIGHT{
                    // Get closest/adjacent Right number compared to current (Exploding) position
                    if( this.parentNode.rightNumber != null ){
                        this.parentNode.increaseNumber( numberToAdd, position );
                    } else{
                        SnailNode parentWithDiffRightNode = this.getFirstParentWithRightNode();
                        if( parentWithDiffRightNode == null ){ return; } // No more Right Node exists
                        // When Exploding Node was in Left-Branch, and Right is just a number, simply increase
                        if( parentWithDiffRightNode.rightNumber != null ){
                            parentWithDiffRightNode.increaseNumber( numberToAdd, position );

                            // When directions are shift, and the Right adjacent value is now on the most Left Number of the Right Parent Adjacent node
                        } else{
                            parentWithDiffRightNode.rightNode.getMostLeftNodeWithNumber().increaseNumber( numberToAdd, NODE_POSITION.LEFT );
                        }
                    }
                }
            }
        }
        /**
         * Method to return the Node which contains the first right/left value compared to the current one
         * In case the parent has no rightNode (then it should have a rightNumber (!)) return the parentNode
         */
        private SnailNode getFirstParentWithLeftNode(){
            return ( this.parentNode?.leftNode == this )
                ? this.parentNode.getFirstParentWithLeftNode() // When current node is the left node of it's parent, go one level up
                : this.parentNode;  // When parentNode is either empty, or having a different LeftNode OR only a LeftNumber, return
        }
        private SnailNode getFirstParentWithRightNode(){
            return ( this.parentNode?.rightNode == this )
                ? this.parentNode.getFirstParentWithRightNode() // When current node is the right Node of it's parent, go one level up
                : this.parentNode;  // When parentNode is either empty, or having a different RightNode OR only a RightNumber, return
        }
        private SnailNode getMostLeftNodeWithNumber(){
            return ( this.leftNode != null ) ? this.leftNode.getMostLeftNodeWithNumber() : this;
        }
        private SnailNode getMostRightNodeWithNumber(){
            return ( this.rightNode != null ) ? this.rightNode.getMostRightNodeWithNumber() : this;
        }

        /**
         * Method to ensure a full/deep-clone is made of a SnailNode to avoid part1() and part2() to mess with the others' input
         * Note, the setter-methods are used, to make sure the Parent reference is set correctly automatically
         * Couldn't be handled by JSON, due to circular references (since parent and child are linked both ways by references)
         */
        public SnailNode deepClone(){
            SnailNode clonedNode = new SnailNode()
                .setNode( this.leftNode?.deepClone(), NODE_POSITION.LEFT )
                .setNode( this.rightNode?.deepClone(), NODE_POSITION.RIGHT )
                .setNumber( this.leftNumber, NODE_POSITION.LEFT )
                .setNumber( this.rightNumber, NODE_POSITION.RIGHT );
            return clonedNode;
        }
    }
}