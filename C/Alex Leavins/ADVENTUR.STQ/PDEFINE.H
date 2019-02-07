/************************************************************************/
/*	DEFINE.H  Typical miscellaneous C definitions.			*/
/*
/* This contains all the useful little definitions of things like TRUE,
/* FALSE, etc.  It also contains all the little FORTRAN like test labels
/* like EQ for ==, and all that good stuff.
/*
/************************************************************************/

#define NIL 0			/* Nil Pointer */
#define NULL 0			/* Null value... */

#define NO  0			/* "FALSE" */
#define YES 1			/* "TRUE" */

#define LEFT  1
#define RIGHT 2
#define UP    10
#define DOWN  20

#define TRUE 1
#define FALSE 0

#define EOS '\0'		/* End of String marker */

#define NEWLINE '\n'		/* Carriage Return */

#define	FAILURE	(-1)		/* Function failure return val */
#define SUCCESS	(0)		/* Function success return val */
#define	FOREVER	for(;;)		/* Infinite loop declaration   */

#define EQ	==		/* Equals test label		*/
#define LT	<		/* Less than test label		*/
#define GT	>		/* Greater than test label	*/
#define LE	<=		/* Less than or equal test label*/
#define GE	>=		/* Greater than or equal test	*/
#define NE	!=		/* Not equal test label		*/

#define AND	&&		/* Logical AND operator		*/
#define OR	||		/* Logical OR  operator		*/

#define B_AND	&		/* Bitwise AND operator		*/
#define B_OR	|		/* Bitwise OR operator		*/
#define B_XOR	^		/* Bitwise Exclusive OR		*/

#define END     255		/* End of string character	*/
#define ON      1
#define OFF     0
#define LENGTH  0
#define odd_value 0x0011
