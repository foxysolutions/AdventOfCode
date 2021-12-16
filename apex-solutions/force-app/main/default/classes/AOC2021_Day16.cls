/**
 * Class to support all logic for the 16th days' challenge!
 * Call as:
 *  AOC2021_Day16 challenge = new AOC2021_Day16( AOC_Base.MODE.EXAMPLE );
 *  challenge.part1();
 *  challenge.part2();
 *
 * @author    Reinier van den Assum (rvandenassum@deloitte.nl)
 * @created   December 2021
 */
public with sharing class AOC2021_Day16 extends AOC_Base{
    private static final Long PACKET_TYPE_ID_LITERAL_VALUE = 4;
    private static final Integer LENGHT_TYPE_0_NUM_BITS = 15;
    private static final Integer LENGHT_TYPE_1_NUM_BITS = 11;

    public List<List<String>> INPUT_BINARYLIST = new List<List<String>>();

    // Conversion table from Binary value based on input Hex value
    Map<String, String> BINARY_BY_HEX = new Map<String, String>{
        '0' => '0000',
        '1' => '0001',
        '2' => '0010',
        '3' => '0011',
        '4' => '0100',
        '5' => '0101',
        '6' => '0110',
        '7' => '0111',
        '8' => '1000',
        '9' => '1001',
        'A' => '1010',
        'B' => '1011',
        'C' => '1100',
        'D' => '1101',
        'E' => '1110',
        'F' => '1111'
    };

    public AOC2021_Day16( AOC_Base.MODE runmode ){
        this.runmode = runmode;
        this.setInputLines( 'AOC2021_Day16' );
        // Prepare Binary-package-input-String by input-Hex characters
        for( Integer l = 0, k = inputLines.size(); l < k; l++ ){
            List<String> inputHexChar = inputLines[ l ].split( '' );
            List<String> binaryList = new List<String>();
            for( Integer i = 0, j = inputHexChar.size(); i < j; i++ ){
                binaryList.addAll( BINARY_BY_HEX.get( inputHexChar[ i ] ).split( '' ) );
            }
            INPUT_BINARYLIST.add( binaryList );
        }
    }

    public void part1(){
        for( Integer i = 0, j = INPUT_BINARYLIST.size(); i < j; i++ ){
            PackageWrap p = parsePackage( INPUT_BINARYLIST[ i ].clone() );
            System.debug( '*** Answer part 1: ' + ( ( runmode == MODE.EXAMPLE ) ?  inputLines[ i ] + ' > ' : '' ) + p.getSumOfVersions() );
        }
    }

    public void part2(){
        for( Integer i = 0, j = INPUT_BINARYLIST.size(); i < j; i++ ){
            PackageWrap p = parsePackage( INPUT_BINARYLIST[ i ].clone() );
            System.debug( '*** Answer part 2: ' + ( ( runmode == MODE.EXAMPLE ) ?  inputLines[ i ] + ' > ' : '' ) + p.getValue() );
        }
    }

    /**
     * (Recursive) method to parse the (remaining) binary input String to corresponding Packages
     * 1) Parse package header (first 6 digits) > Version & TypeId
     * 2) Parse package body
     *      Type = 4        Read Literal value (checking 5-bits groups and identifying last 5-bits by starting by 0)
     *      Else            Process Subpackages
     *          15-bits     Subpackages based on given bit-length of all subpackages
     *          11-bits     Subpackages based on given number of subpackages
     *
     * @param inputBinary   List of (remaining) binary bits to be processed, allowing recursive approach to parse subpackages
     * @return  Wrapper of Package to allow calling method to utilise according to needs
     */
    private PackageWrap parsePackage( List<String> inputBinary ){
        // Parse package header [3][3]: [Version][TypeId]
        Long packageVersion = this.binaryToLong( inputBinary.remove( 0 ) + inputBinary.remove( 0 ) + inputBinary.remove( 0 ) );
        Long packageTypeId = this.binaryToLong( inputBinary.remove( 0 ) + inputBinary.remove( 0 ) + inputBinary.remove( 0 ) );

        PackageWrap p = new PackageWrap( packageVersion, packageTypeId );

        if( packageTypeId == PACKET_TYPE_ID_LITERAL_VALUE ){
            // Derive literal value: Go over 5 bits groups; remove 1 from start index, except 0 for last; and ignore the last added (unlabeled) 0
            List<String> literalBits = new List<String>();
            while( inputBinary.remove( 0 ) == '1' ){ // continue while next 5-bit group isn't the last one
                // Check remaining 4 digits of this group to add as Integer to the literal of this package
                for( Integer i = 0; i < 4; i++ ){ literalBits.add( inputBinary.remove( 0 ) ); }
            }
            // The last '0' is removed by the previous while, so only process the last remaining 4-digits of this literal value
            for( Integer i = 0; i < 4; i++ ){ literalBits.add( inputBinary.remove( 0 ) ); }

            return p.setLiteral( this.binaryToLong( String.join( literalBits, '' ) ) );

        } else{ // operator package, containing subpackages
            String lengthTypeId = inputBinary.remove( 0 );
            // 0 > next 15 bits are number representing total length in bits of subpackagt
            // 1 > next 11 bits are number representing number of sub-packats
            Integer numBits = ( lengthTypeId == '0' ) ? LENGHT_TYPE_0_NUM_BITS : LENGHT_TYPE_1_NUM_BITS;
            List<String> lengthTypeBits = new List<String>();
            for( Integer i = 0; i < numBits; i++ ){
                lengthTypeBits.add( inputBinary.remove( 0 ) );
            }

            // When 15, those bits represent total length of sub-packets
            if( numBits == LENGHT_TYPE_0_NUM_BITS ){
                Long totalLengthSubPackages = this.binaryToLong( String.join( lengthTypeBits, '' ) );
                // Check whether original subpackage bit length - remaining is still within length of this 15-operator-subpackage
                Integer bitLength = inputBinary.size();
                while( bitLength - inputBinary.size() < totalLengthSubPackages ){
                    p.addSubPackage( this.parsePackage( inputBinary ) );
                }
                return p;

            // When 11, the related number indicates NUMBER of sub-packages; hence loop over number and construct the subpackages
            } else if( numBits == LENGHT_TYPE_1_NUM_BITS ){
                Long numSubPackages = this.binaryToLong( String.join( lengthTypeBits, '' ) );
                for( Integer i = 0; i < numSubPackages; i++ ){
                    p.addSubPackage( this.parsePackage( inputBinary ) );
                }
                return p;
            }
        }
        return null;
    }

    private class PackageWrap{
        public Long version;
        public Long typeId;
        public List<PackageWrap> subPackages = new List<PackageWrap>();
        public Long literalValue;

        public PackageWrap( Long version, Long typeId ){
            this.version = version;
            this.typeId = typeId;
        }
        public PackageWrap addSubPackage( PackageWrap sub ){
            this.subPackages.add( sub );
            return this;
        }
        public PackageWrap setLiteral( Long val ){
            this.literalValue = val;
            return this;
        }

        public Long getSumOfVersions(){
            Long versionSum = this.version;
            for( Integer i = 0, j = subPackages.size(); i < j; i++ ){
                versionSum += subPackages[ i ].getSumOfVersions();
            }
            return versionSum;
        }

        public Long getValue(){
            switch on typeId{
                when 0{ // Sum of subpackages
                    Long packageValue = subPackages[ 0 ]?.getValue();
                    for( Integer i = 1, j = subPackages.size(); i < j; i++ ){
                        packageValue += subPackages[ i ].getValue();
                    }
                    return packageValue;
                }
                when 1{ // Product of subpackages
                    Long packageValue = subPackages[ 0 ]?.getValue();
                    for( Integer i = 1, j = subPackages.size(); i < j; i++ ){
                        packageValue *= subPackages[ i ].getValue();
                    }
                    return packageValue;
                }
                when 2{ // Minimum of subpackages
                    Long packageValue = subPackages[ 0 ]?.getValue();
                    for( Integer i = 1, j = subPackages.size(); i < j; i++ ){
                        packageValue = Math.min( packageValue, subPackages[ i ].getValue() );
                    }
                    return packageValue;
                }
                when 3{ // Maximum of subpackages
                    Long packageValue = subPackages[ 0 ]?.getValue();
                    for( Integer i = 1, j = subPackages.size(); i < j; i++ ){
                        packageValue = Math.max( packageValue, subPackages[ i ].getValue() );
                    }
                    return packageValue;
                }
                when 4{
                    return literalValue;
                }
                when 5{ // Greater than of subpackages
                    return ( subPackages[ 0 ]?.getValue() > subPackages[ 1 ]?.getValue() ) ? 1 : 0;
                }
                when 6{ // Less than of subpackages
                    return ( subPackages[ 0 ]?.getValue() < subPackages[ 1 ]?.getValue() ) ? 1 : 0;
                }
                when 7{ // Equal subpackages
                    return ( subPackages[ 0 ]?.getValue() == subPackages[ 1 ]?.getValue() ) ? 1 : 0;
                }
            }
            return null;
        }
    }
}

/**
 * Example input validations
 * Input                        Sum Version     Value total
 * D2FE28                            6               2021
 * 38006F45291200                    9 (1+6+2)        1 (first 10 is smaller than second 20 )
 * EE00D40C823060                   14                3 (max of 1, 2, 3)
 * 8A004A801A8002F478               16 (4+1+5+6)
 * 620080001611562C8802118E34       12
 * C0015000016115A2E0802F182340     23
 * A0016C880162017C3686B18A3D4780   31
 * C200B40A82                       14                   3 (sum of 1, 2)
 * 04005AC33890                      8                  54 (product of 6 * 9)
 * 880086C3E88112                   15                  7 (minimum of 7, 8, 9)
 * CE00C43D881120                   11                  9 (minimum of 7, 8, 9)
 * D8005AC2A8F0                     13                  1 (5 is smaller than 15)
 * F600BC2D8F                       19                  0 (5 NOT greater 15)
 * 9C005AC2F8F0                     16                  0 (5 NOT equal to 15)
 * 9C0141080250320F1802104A08       20                  1 (1+3 == 2*2)
 */