/**
 * Class to support all logic for the 11th days' challenge!
 * Call as:
 *  AOC2021_Day11 challenge = new AOC2021_Day11( AOC_Base.MODE.EXAMPLE );
 *  challenge.part1();
 *  challenge.part2();
 *
 * Played today with Recursion vs. worklist; where recursion is iteratively processing all items in the tree
 * while the worklist first processes all increases and then only the list of spots/octopi to process
 * For the fun element of this Advent Of Code, developed both to compare behaviour and most importantly performance
 * Below times include initialization, part1() and part2() and are taken over at least 15 run times
 * Average worklist: 350 - 550 ms
 * Average recursion: 1000 - 1200 ms
 *
 * @author    Reinier van den Assum (rvandenassum@deloitte.nl)
 * @created   December 2021
 */
public with sharing class AOC2021_Day11 extends AOC_Base{
    List<List<Integer>> MATRIX_ENERGYLEVEL = new List<List<Integer>>();
    Integer MATRIX_NUMROWS = 0;
    Integer MATRIX_NUMCOLS = 0;
    Integer ENERGY_LEVEL_FLASH = 10;
    Integer ENERGY_LEVEL_RESET = 0;

    Boolean USE_RECURSION;

    public AOC2021_Day11( AOC_Base.MODE runmode ){
        this( runmode, true );
    }
    public AOC2021_Day11( AOC_Base.MODE runmode, Boolean useRecursion ){
        this.runmode = runmode;
        this.setInputLines( 'AOC2021_Day11' );
        for( Integer i = 0, j = inputLines.size(); i < j; i++ ){
            MATRIX_ENERGYLEVEL.add( this.splitStringToIntegers( inputLines[ i ], '' ) );
        }
        this.MATRIX_NUMROWS = MATRIX_ENERGYLEVEL.size();
        this.MATRIX_NUMCOLS = MATRIX_ENERGYLEVEL[ 0 ].size();
        this.USE_RECURSION = useRecursion;
        System.debug( '*** Using ' + ( ( useRecursion ) ? 'recursive method' : 'worklist' ) );
    }

    public void part1(){
        Integer numSimulations = 100;
        List<List<Integer>> energyLevelMatrix = ( List<List<Integer>> ) JSON.deserializeStrict( JSON.serialize( this.MATRIX_ENERGYLEVEL ), List<List<Integer>>.class );

        Long totalFlashes = 0;
        for( Integer n = 0; n < numSimulations; n++ ){
            totalFlashes += this.runSimulation( energyLevelMatrix );
        }
        System.debug( '*** Answer part 1: ' + totalFlashes );
    }

    public void part2(){
        List<List<Integer>> energyLevelMatrix = ( List<List<Integer>> ) JSON.deserializeStrict( JSON.serialize( this.MATRIX_ENERGYLEVEL ), List<List<Integer>>.class );
        Integer totalNumOctopus = MATRIX_NUMROWS * MATRIX_NUMCOLS;

        // Continue simulating till all octopus flash at once
        Integer numFlashesSimulation = 0;
        Integer numIterations = 0;
        do{
            numIterations++;
            numFlashesSimulation = this.runSimulation( energyLevelMatrix );
        } while( numFlashesSimulation < totalNumOctopus );

        System.debug( '*** Answer part 2: ' + numIterations );
    }

    private Integer runSimulation( List<List<Integer>> energyLevelMatrix ){
        Integer iterationFlashes = 0;
        List<String> flashedOctopusCoords = new List<String>();
        List<Coordinate> flashedOctopusThisIteration = new List<Coordinate>();
        // Loop over all octopus and increase them as default
        for( Integer r = 0; r < MATRIX_NUMROWS; r++ ){
            for( Integer c = 0; c < MATRIX_NUMCOLS; c++ ){
                if( this.USE_RECURSION ){
                    iterationFlashes += this.increaseEnergyRecursive( r, c, energyLevelMatrix, flashedOctopusCoords );
                } else{
                    // Increase energy level of octopus r-c
                    energyLevelMatrix[ r ][ c ]++;
                    // When exceeding the flashing-threshold, 'FLASH!' and register to worklist for processing
                    if( energyLevelMatrix[ r ][ c ] == ENERGY_LEVEL_FLASH ){
                        flashedOctopusThisIteration.add( new Coordinate( r, c ) );
                    }
                }
            }
        }
        while( !flashedOctopusThisIteration.isEmpty() ){
            iterationFlashes += this.processFlashedOctopus( flashedOctopusThisIteration.remove( 0 ), energyLevelMatrix, flashedOctopusThisIteration );
        }
        return iterationFlashes;
    }

    private Integer increaseEnergyRecursive( Integer x, Integer y, List<List<Integer>> energyLevelMatrix, List<String> flashedOctopusCoords ){
        Integer numFlashes = 0;
        // First check if octopus didn't already flash this round to prevent one octopus to flash twice per iteration
        if( energyLevelMatrix[ x ][ y ] == ENERGY_LEVEL_RESET && flashedOctopusCoords.contains( x + ',' + y ) ){
            return numFlashes;
        }

        energyLevelMatrix[ x ][ y ]++;
        if( energyLevelMatrix[ x ][ y ] == ENERGY_LEVEL_FLASH ){
            energyLevelMatrix[ x ][ y ] = ENERGY_LEVEL_RESET;
            flashedOctopusCoords.add( x + ',' + y );
            numFlashes++;

            // Loop over all possible adjacent cells and process the flash
            for( Integer xDelta = -1; xDelta <= 1; xDelta++ ){
                for( Integer yDelta = -1; yDelta <= 1; yDelta++ ){
                    // Exclude current coordinate from duplicate processing
                    if( xDelta == 0 && yDelta == 0 ){
                        continue;
                    }

                    // For all adjacent cells, validate whether they are valid/existing to prevent list-index-out-of-bounds
                    Integer nextX = x + xDelta;
                    Integer nextY = y + yDelta;
                    if( nextX >= 0 && nextX < this.MATRIX_NUMROWS && nextY >= 0 && nextY < this.MATRIX_NUMCOLS ){
                        // Recursively increase the level of energy for the existing adjacent octopus
                        numFlashes += this.increaseEnergyRecursive( nextX, nextY, energyLevelMatrix, flashedOctopusCoords );
                    }
                }
            }
        }

        return numFlashes;
    }

    private Integer processFlashedOctopus( Coordinate c, List<List<Integer>> energyLevelMatrix, List<Coordinate> flashedOctopus ){
        Integer numFlashes = 0;
        // Loop over all possible adjacent cells and process the flash
        for( Integer xDelta = -1; xDelta <= 1; xDelta++ ){
            for( Integer yDelta = -1; yDelta <= 1; yDelta++ ){
                // For the octopus that actually flashed, reset its' energylevel and add to counter
                if( xDelta == 0 && yDelta == 0 ){
                    energyLevelMatrix[ c.x ][ c.y ] = 0;
                    numFlashes++;
                    continue; // this is the current coordinate we're checking
                }

                // For all other adjacent cells, validate whether they are valid/existing to prevent list-index-out-of-bounds
                Integer nextX = c.x + xDelta;
                Integer nextY = c.y + yDelta;
                if( nextX >= 0 && nextX < this.MATRIX_NUMROWS && nextY >= 0 && nextY < this.MATRIX_NUMCOLS ){
                    // First check if octopus didn't already flash this round to prevent one octopus to flash twice per iteration
                    if( energyLevelMatrix[ nextX ][ nextY ] == 0 ){
                        continue;
                    }
                    // When octopus didn't flash yet, increase energy based on adjacent flash
                    energyLevelMatrix[ nextX ][ nextY ]++;
                    // When octopus should flash, register to 'worklist'
                    if( energyLevelMatrix[ nextX ][ nextY ] == ENERGY_LEVEL_FLASH ){ // only process the first exceeding of 9
                        flashedOctopus.add( new Coordinate( nextX, nextY ) );
                    }
                }
            }
        }
        return numFlashes;
    }
}