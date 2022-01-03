# AdventOfCode
Repository to store the solutions for the problems of AdventOfCode. Doing it in Apex, challenge accepted!

## Goal

Within Deloitte an internal competition is ongoing, with a real Salesforce hoodie at stake! So get ready :).

## Repository

Since the repo might look a little complex / full, please find some useful hooks in the Table of Content below. 

* [Advent Of Code 2021](https://adventofcode.com/2021)
* [Challenge descriptions](challenges)
* [Solutions in Apex](apex-solutions/force-app/main/default/classes)
* [Solutions in other techniques](other-solutions)

# 2021

Below is an overview of all exercises, their title and solution description.
Per exercise the Solution is described by language used, where default is Apex
and only some have Javascript in case it wasn't possible to bypass the Apex CPU Time Limit.
Then it was always tried with Queueables but due to DEV Org restriction of only queueing 5, 
this would also be still restricted to 300 seconds in total.

| Day | Name | Description | Solution |
| :--- | :--- | :--- | :--- |
| 01 | [Sonar Sweep](challenges/2021/01_SonarSweep_Increase-Decrease-Detection.txt) | Increase/Decrease Detection | [Apex](apex-solutions/force-app/main/default/classes/AOC2021_Day01.cls) & [Excel](other-solutions/2021_Solutions.xlsx) | 
| 02 | [Dive!](challenges/2021/02_Dive_SubmarineControl-ForwardDownUp.txt) | Submarine Control | [Apex](apex-solutions/force-app/main/default/classes/AOC2021_Day02.cls) & [Excel](other-solutions/2021_Solutions.xlsx) | 
| 03 | [Binary Diagnostic](challenges/2021/03_BinaryDiagnostic_MostLeastCommonBinaryDigits.txt) | Most/Least Common Binary Digit | [Apex](apex-solutions/force-app/main/default/classes/AOC2021_Day03.cls) & [Excel](other-solutions/2021_Solutions.xlsx) |
| 04 | [Giant Squid](challenges/2021/04_GiantSquid_BingoBoards.txt) | Bingo Boards | [Apex](apex-solutions/force-app/main/default/classes/AOC2021_Day04.cls) & [Excel](other-solutions/2021_Solutions.xlsx) |
| 05 | [Hydrothermal Venture](challenges/2021/05_HydrothermalVenture_OverlappingLineSegments.txt) | Overlapping Line Segments | [Apex](apex-solutions/force-app/main/default/classes/AOC2021_Day05.cls) |
| 06 | [LanternFish](challenges/2021/06_LanternFish_Reproduction-PopulationGrowth.txt) | Population Growth | [Apex](apex-solutions/force-app/main/default/classes/AOC2021_Day06.cls) & [Excel](other-solutions/2021_Solutions.xlsx) |
| 07 | [The Treachery Of Whales](challenges/2021/07_TheTreacheryOfWhales_CrabAlignmentFuelCosts.txt) | Crab Alignment Fuel Costs | [Apex](apex-solutions/force-app/main/default/classes/AOC2021_Day07.cls) & [Excel](other-solutions/2021_Solutions.xlsx) |
| 08 | [Seven Segment Search](challenges/2021/08_SevenSegmentSearch_DigitDisplay-SegmentDecoding.txt) | Digit Display/Segment Decoding | [Apex](apex-solutions/force-app/main/default/classes/AOC2021_Day08.cls) |
| 09 | [Smoke Basin](challenges/2021/09_SmokeBasin_LowestPoints-BasinSizes.txt) | LowestPoint Basin sizes | [Apex](apex-solutions/force-app/main/default/classes/AOC2021_Day09.cls) & [Excel](other-solutions/2021_Solutions.xlsx) (p1) |
| 10 | [Syntax Scoring](challenges/2021/10_SyntaxScoring_Brackets-CorruptLines-Autocomplete.txt) | Brackets (corrupt lines & auto-complete) | [Apex](apex-solutions/force-app/main/default/classes/AOC2021_Day10.cls) | 
| 11 | [Dumbo Octopus](challenges/2021/11_DumboOctopus_Flashes-EnergyLevelSimulations.txt) | Energy Flash Level simulations | [Apex](apex-solutions/force-app/main/default/classes/AOC2021_Day11.cls) | 
| 12 | [Passage Pathing](challenges/2021/12_PassagePathing_FindingAllPossiblePaths.txt) | Finding ALL Possible Paths | [Apex](apex-solutions/force-app/main/default/classes/AOC2021_Day12.cls) | 
| 13 | [Transparent Origami](challenges/2021/13_TransparentOrigami_FoldingMatrices.txt) | Folding Matrices | [Apex](apex-solutions/force-app/main/default/classes/AOC2021_Day13.cls) | 
| 14 | [Extended Polymerization](challenges/2021/14_ExtendedPolymerization_LetterDuple-Injections.txt) | Letter Duple injections | [Apex](apex-solutions/force-app/main/default/classes/AOC2021_Day14.cls) | 
| 15 | [Chiton](challenges/2021/15_Chiton_ShortestPath.txt) | Shortest Path (Dijkstra & Priority Queue | [Apex](apex-solutions/force-app/main/default/classes/AOC2021_Day15.cls): input prepare part 1 <br /> JS: [part 1](other-solutions/2021_Day15_1_Dijkstra.js) & [part 2](other-solutions/2021_Day15_2_PriorityQueue.js) | 
| 16 | [Package Decoder](challenges/2021/16_PackageDecoder_HexaBinaryParser.txt) | Hexa Binary (subpackage) Converter | [Apex](apex-solutions/force-app/main/default/classes/AOC2021_Day16.cls) | 
| 17 | [TrickShot](challenges/2021/17_TrickShot_ProbeOrbitSimulations.txt) | Probe Orbit simulation | [Apex](apex-solutions/force-app/main/default/classes/AOC2021_Day17.cls) | 
| 18 | [Snailfish](challenges/2021/18_Snailfish_TreeSums_Explosions_Splits.txt) | Exploding/Split sums in Trees | [Apex](apex-solutions/force-app/main/default/classes/AOC2021_Day18.cls) (Future) | 
| 19 | [BeaconScanner](challenges/2021/19_BeaconScanner_RebaseCoordinateSystem.txt) | Coordinate Rotation | [Apex](apex-solutions/force-app/main/default/classes/AOC2021_Day19.cls) (Queueable) | 
| 20 | [Trench Map](challenges/2021/20_TrenchMap_ImageEnlightment.txt) | Image Enlightment | [Apex](apex-solutions/force-app/main/default/classes/AOC2021_Day20.cls) |
| 21 | [Dirac Dice](challenges/2021/21_DiracDice_QuantumDie_PlayerWins.txt) | Quantum Die Player Wins | [Apex](apex-solutions/force-app/main/default/classes/AOC2021_Day21.cls) (Queueable): part 1 <br /> [JS](other-solutions/2021_Day21.js): part2 | 
| 22 | [Reactor Reboot](challenges/2021/22_ReactorReboot_DistinctEnabledCubeCoordinates.txt) | Distinct Cube Coordinates | [Apex](apex-solutions/force-app/main/default/classes/AOC2021_Day22.cls) (Future) | 
| 23 | [Amphipods](challenges/2021/23_Amphipods_ManualRelocations.txt) | Relocating rooms to group | [Manual](other-solutions/2021_Day23_Manual.txt) | 
| 24 | [Arithmetic Logic Unit](challenges/2021/24_ArithmeticLogicUnit_14Digit_ModelCode_Constructor.txt) | Model code generator & validator | [Apex](apex-solutions/force-app/main/default/classes/AOC2021_Day24.cls) | 
| 25 | [Sea Cucumber](challenges/2021/25_SeaCucumber_SnakeMoveTillStuck.txt) | (Snake) Move till stuck | [Apex](apex-solutions/force-app/main/default/classes/AOC2021_Day25.cls) (Queuable): Full <br /> [JS](other-solutions/2021_Day25.js): Full |

Cheers!

Reinier van den Assum
https://www.foxy-solutions.com