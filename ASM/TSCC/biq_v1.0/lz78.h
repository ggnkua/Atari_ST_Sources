#ifndef LZ78_H
#define LZ78_H

#define BITS 12						/* Setting the number of bits to 12, 13 */
#define HASHING_SHIFT (BITS-8)		/* or 14 affects several constants.     */
#define MAX_VALUE (1 << BITS) - 1	/* Note that MS-DOS machines need to    */
#define MAX_CODE (MAX_VALUE - 1)		/* compile their code in large model if */
									/* 14 bits are selected.                */
#if BITS == 14
	#define TABLE_SIZE 18041		/* The string table size needs to be a  */
#endif								/* prime number that is somewhat larger */
#if BITS == 13						/* than 2^BITS.                         */
	#define TABLE_SIZE 9029
#endif
#if BITS <= 12
	#define TABLE_SIZE 5021
#endif

#define STACK_LEN 4000


static int * code_value;					/* This is the code value array        */
static unsigned int * prefix_code;			/* This array holds the prefix codes   */
static unsigned char * append_character;	/* This array holds the appended chars */
static unsigned char decode_stack[STACK_LEN];	/* This array holds the decoded string */

static int input_bit_count = 0;
static unsigned long input_bit_buffer = 0l;

static int output_bit_count=0;
static unsigned long output_bit_buffer=0l;



/*!
	\brief Main lz78 compression routine.
	
	'len' specifies the length of the input buffer.

*/
void enLZ78(unsigned char * input, long len, FILE * output);


/*!
	\brief Main lz78 expansion routine.
*/
void deLZ78(FILE * input, unsigned char * output);


/*!
	\brief String hashing routine for the encoder.
	
	This is the hashing routine.  It tries to find a match for the prefix+char
	string in the string table.  If it finds it, the index is returned.  If
	the string is not found, the first available index in the string table is
	returned instead.
*/
int find_match(unsigned int hash_prefix,unsigned int hash_character);


/*!
	\brief Reversely decode a string from the append table.
*/
unsigned char * decode_string(unsigned char * buffer,unsigned int code);


/*!
	\brief Read a variable length bitfield from the given input.
	
	Note: the implementation is anything but fast.
*/
int input_code(FILE * input);


/*!
	\brief Write a variable length bitfield to the given output.
	
	Note: the implementation is anything but fast.	
*/
void output_code(FILE * output,unsigned int code);

#endif
