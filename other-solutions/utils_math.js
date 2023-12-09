
/**
 * "Common" methods, finding the common multiple, divisor or denominator
 */

/**
 * Method to determine the largest integer dividing each of integers to have their remainder being zero
 */
const greatest_common_divisor = ( a, b ) => {
  if( b === 0 ){ return a; }
  return greatest_common_divisor( b, a % b );
};

/**
 * Method to determine smallest positive integer that can be divided by both a and b;
 */
const lowest_common_multiple = ( a, b ) => {
  return ( a * b ) / greatest_common_divisor( a, b );
};

module.exports = {
    // Common methods
    greatest_common_divisor, lowest_common_multiple
};