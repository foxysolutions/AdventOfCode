/**
 * Class to support all logic for the 24th days' challenge!
 * Call as:
 *  AOC2021_Day24 challenge = new AOC2021_Day24( AOC_Base.MODE.EXAMPLE );
 *  challenge.part1();
 *  challenge.part2();
 *
 * @author    Reinier van den Assum (rvandenassum@deloitte.nl)
 * @created   December 2021
 */
public with sharing class AOC2021_Day24 extends AOC_Base{
    // Storing 14-digits ModelCodes as List of Integers, since Long have a max of 11-digits
    protected List<List<Integer>> validModelCodes;

    public AOC2021_Day24( AOC_Base.MODE runmode ){
        this.runmode = runmode;
        this.setInputLines( 'AOC2021_Day24' );
        // Determine all possible valid ModelCodes (MCs) to allow part1() and part2() to do their jobs
        this.validModelCodes = this.getValidModelCodes();
    }

    public void part1(){
        // From all sorted valid MCs, get the latest/maximum, validate and dump if correct
        List<Integer> maximumValidModelCode = this.validModelCodes[ this.validModelCodes.size() - 1 ];
        if( this.validateModelCode( maximumValidModelCode ) ){
            System.debug( '*** Answer part 1: ' + String.join( maximumValidModelCode, '' ) );
        } else{
            throw new InvalidDataException( 'Part1: What?! '+ String.join( maximumValidModelCode, '' ) + ' is invalid... Go fix :)' );
        }
    }

    public void part2(){
        // From all sorted valid MCs, get the first/minimum, validate and dump if correct
        List<Integer> minimumValidModelCode = this.validModelCodes[ 0 ];
        if( this.validateModelCode( minimumValidModelCode ) ){
            System.debug( '*** Answer part 2: ' + String.join( minimumValidModelCode, '' ) );
        } else{
            throw new InvalidDataException( 'Part2: What?! '+ String.join( minimumValidModelCode, '' ) + ' is invalid... Go fix :)' );
        }
    }

    /**
     * After investigating input (actions list), it occurred that the 255 lines could be split in 14x 18-actions of which ONLY lines 4, 5 and 15 differentiated...
     * 	    0	        1	        2       	3	        4	        5	        6	        7	        8	        9	        10	        11	        12	        13
     * 0	inp w	    inp w	    inp w	    inp w	    inp w	    inp w	    inp w	    inp w	    inp w	    inp w	    inp w	    inp w	    inp w	    inp w
     * 1	mul x 0	    mul x 0	    mul x 0	    mul x 0	    mul x 0	    mul x 0	    mul x 0	    mul x 0	    mul x 0	    mul x 0	    mul x 0	    mul x 0	    mul x 0	    mul x 0
     * 2	add x z	    add x z	    add x z	    add x z	    add x z	    add x z	    add x z	    add x z	    add x z	    add x z	    add x z	    add x z	    add x z	    add x z
     * 3	mod x 26	mod x 26	mod x 26	mod x 26	mod x 26	mod x 26	mod x 26	mod x 26	mod x 26	mod x 26	mod x 26	mod x 26	mod x 26	mod x 26
     * 4	div z 1	    div z 1	    div z 1	    div z 1	    div z 26	div z 26	div z 1	    div z 26	div z 1	    div z 26	div z 1	    div z 26	div z 26	div z 26    << a
     * 5	add x 13	add x 13	add x 10	add x 15	add x -8	add x -10	add x 11	add x -3	add x 14	add x -4	add x 14	add x -5	add x -8	add x -11   << b
     * 6	eql x w	    eql x w	    eql x w	    eql x w	    eql x w	    eql x w	    eql x w	    eql x w	    eql x w	    eql x w	    eql x w	    eql x w	    eql x w	    eql x w
     * 7	eql x 0	    eql x 0	    eql x 0	    eql x 0	    eql x 0	    eql x 0	    eql x 0	    eql x 0	    eql x 0	    eql x 0	    eql x 0	    eql x 0	    eql x 0	    eql x 0
     * 8	mul y 0	    mul y 0	    mul y 0	    mul y 0	    mul y 0	    mul y 0	    mul y 0	    mul y 0	    mul y 0	    mul y 0	    mul y 0	    mul y 0	    mul y 0	    mul y 0
     * 9	add y 25	add y 25	add y 25	add y 25	add y 25	add y 25	add y 25	add y 25	add y 25	add y 25	add y 25	add y 25	add y 25	add y 25
     * 10	mul y x	    mul y x	    mul y x	    mul y x	    mul y x	    mul y x	    mul y x	    mul y x	    mul y x	    mul y x	    mul y x	    mul y x	    mul y x	    mul y x
     * 11	add y 1	    add y 1	    add y 1	    add y 1	    add y 1	    add y 1	    add y 1	    add y 1	    add y 1	    add y 1	    add y 1	    add y 1	    add y 1	    add y 1
     * 12	mul z y	    mul z y	    mul z y	    mul z y	    mul z y	    mul z y	    mul z y	    mul z y	    mul z y	    mul z y	    mul z y	    mul z y	    mul z y	    mul z y
     * 13	mul y 0	    mul y 0	    mul y 0	    mul y 0	    mul y 0	    mul y 0	    mul y 0	    mul y 0	    mul y 0	    mul y 0	    mul y 0	    mul y 0	    mul y 0	    mul y 0
     * 14	add y w	    add y w	    add y w	    add y w	    add y w	    add y w	    add y w	    add y w	    add y w	    add y w	    add y w	    add y w	    add y w	    add y w
     * 15	add y 15	add y 16	add y 4	    add y 14    add y 1	    add y 5	    add y 1	    add y 3	    add y 3	    add y 7	    add y 5	    add y 13	add y 3	    add y 10    << c
     * 16	mul y x	    mul y x	    mul y x	    mul y x 	mul y x	    mul y x	    mul y x	    mul y x	    mul y x	    mul y x	    mul y x	    mul y x	    mul y x	    mul y x
     * 17	add z y	    add z y	    add z y	    add z y 	add z y	    add z y	    add z y	    add z y	    add z y	    add z y	    add z y	    add z y	    add z y	    add z y
     *
     * Some key-findings:
     * - all 14 blocks share the same action-structure, of which only lines 4, 5 and 15 have differentiating numbers
     * - z is the only variable shared across the 14 action-groups (rest is reset each blcok, e.g. mul x 0 on line 1)
     * - w is the only variable we can 'manipulate' as it is defined by the N-th number in the model code
     * - if a == 1 (div z 1) then b >= 10 (add x 13)
     * - if a == 26 (div z 26) then b < 0 (add x -8)
     * - 7 times a == 1 and thus, b >= 10; and 7 times a == 26 and thus b < 0
     * - since this alters the same amount of time and given the structure, we can 'cancel out' z to end up as 0 by reversing the a==26 with the previous a==1
     *
     * This method processes the 14 lists and gathers the a, b, c variables (line 4, 5, 15 resp.)
     * Then all valid model codes are determined to keep z == 0 at the end (e.g. implying y to be 0 OR -1*z on action 18)
     */
    private List<List<Integer>> getValidModelCodes(){
        List<List<Integer>> validModelCodes = new List<List<Integer>>();

        // First determine the 14 a,b,c variables per 18-actions block and keep track of Block-index
        List<BlockVariables> varsPerBlock = new List<BlockVariables>();
        for( Integer i = 0, j = inputLines.size(); i < j; i += 18 ){
            varsPerBlock.add( new BlockVariables(
                i / 18,
                Integer.valueOf( inputLines[ i + 4 ].split( ' ' )[ 2 ] ),
                Integer.valueOf( inputLines[ i + 5 ].split( ' ' )[ 2 ] ),
                Integer.valueOf( inputLines[ i + 15 ].split( ' ' )[ 2 ] )
            ) );
        }

        // Loop over the variables per blocks and do the magic!
        List<BlockVariables> prevBlockList = new List<BlockVariables>();
        List<Integer> digitsBase = new List<Integer>{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
        for( Integer i = 0, j = varsPerBlock.size(); i < j; i++ ){
            BlockVariables vars = varsPerBlock[ i ];

            // When a == 1 (or x >= 0) add this Block as first previous
            if( vars.a == 1 ){
                addToFrontOfList( prevBlockList, vars );

            // When a == 26 (or x < 0) and z should be divided by 26, set previous Block and current Block to 'cancel out'
            } else if( vars.a == 26 ){
                BlockVariables previousBlockVars = prevBlockList.remove( 0 );

                // To cancel out z between a==1 and a==26 blocks, we need to set w (digit in model code) to be following
                // prev.w = NUM - ( prev.c + curr.b )
                // curr.w = prev.w + prev.c + curr.b
                //  Making curr.w == NUM - prev.c - curr.b + prev.c + curr.b == NUM;
                // This ensures prev.z and curr.z will cancel out, keeping z = 0 at the end
                // Only values of 1-9 are valid for w, hence first determine lower and upper bound
                Integer compl = previousBlockVars.c + vars.b;
                Integer lowerW = Math.max( 1, 1 - compl );
                Integer upperW = Math.min( 9, 9 - compl );

                // When first ActionBlock, simply add 'dummy' to allow 'looping over' and add( 0 ) to not cause index-out-of-bounds
                if( validModelCodes.isEmpty() ){
                    validModelCodes.add( digitsBase );
                }
                // For each validModelCode, apply the different possible w-values; ensuring to keep model codes in sorted order
                for( Integer vc = 0, vcMax = validModelCodes.size(); vc < vcMax; vc++ ){
                    List<Integer> digits = validModelCodes[ vc ];
                    // Loop over all possible w, duplicate the existing modelCode and add BEFORE original to keep List sorted
                    for( Integer wMinusCompl = lowerW; wMinusCompl < upperW; wMinusCompl++ ){
                        List<Integer> digitsExtended = digits.clone();
                        validModelCodes.add( vc, digitsExtended );
                        vc++; vcMax++;
                        digitsExtended[ previousBlockVars.actionIndex ] = wMinusCompl;
                        digitsExtended[ vars.actionIndex ] = wMinusCompl + compl;
                    }
                    // When all lower-up-till-upper-w are done, apply maximum value to original (to keep it the latest in list)
                    digits[ previousBlockVars.actionIndex ] = upperW;
                    digits[ vars.actionIndex ] = upperW + compl;
                }
            } else{
                throw new InvalidDataException( 'variable a should be either 1 or 26, not '+ vars.a );
            }
        }
        System.debug( '*** Constructed in total '+ validModelCodes.size() + ' valid model codes' );
        return validModelCodes;
    }

    private class BlockVariables{
        Integer a, b, c;
        Integer actionIndex;
        BlockVariables( Integer i, Integer a, Integer b, Integer c ){
            this.actionIndex = i;
            this.a = a;
            this.b = b;
            this.c = c;
        }
    }

    private Boolean validateModelCode( List<Integer> modelCodeList ){
        Map<String, Long> vars = new Map<String, Long>{
            'w' => 0, 'x' => 0, 'y' => 0, 'z' => 0
        };
        Set<String> availableVar = vars.keySet();
        Integer nextInputIndex = 0;

        // Loop over rule book to validate all actions
        for( Integer i = 0, j = inputLines.size(); i < j; i++ ){
            List<String> inpSplit = inputLines[ i ].split( ' ' );
            String firstVarName = inpSplit[ 1 ];
            String optSecondVarOfVal = ( inpSplit.size() == 3 ) ? inpSplit[ 2 ] : null;
            Long secondVal = 0;
            if( String.isNotBlank( optSecondVarOfVal ) ){
                secondVal = ( availableVar.contains( optSecondVarOfVal ) )
                    ? vars.get( optSecondVarOfVal )
                    : Integer.valueOf( optSecondVarOfVal );
                if( secondVal == null ){
                    secondVal = 0;
                } // when variable not defined/known (in Map) yet
            }
            // Go over rule-book to apply the action
            switch on inpSplit[ 0 ]{
                when 'inp'{
                    vars.put( firstVarName, modelCodeList[ nextInputIndex ] );
                    nextInputIndex++;
                }
                when 'add'{
                    vars.put( firstVarName, ( vars.get( firstVarName ) + secondVal ) );
                }
                when 'mul'{
                    vars.put( firstVarName, ( vars.get( firstVarName ) * secondVal ) );
                }
                when 'div'{
                    // Integer / Integer always truncates to Integers
                    vars.put( firstVarName, ( vars.get( firstVarName ) / secondVal ) );
                }
                when 'mod'{
                    vars.put( firstVarName, ( Math.mod( vars.get( firstVarName ), secondVal ) ) );
                }
                when 'eql'{
                    vars.put( firstVarName, ( vars.get( firstVarName ) == secondVal ) ? 1 : 0 );
                }
            }
        }
        // Validate whether modelcode is valid
        Long modelCodeValid = vars.get( 'z' );
        return ( modelCodeValid != null && modelCodeValid == 0 );
    }
}