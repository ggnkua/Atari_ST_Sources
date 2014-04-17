
/*
 * bal.c
 *
 * Test code for balance problem..
 *
 */

#define MAX_BAL		20

/* Balance Max and Min   */
#define BAL_MAX		38		/* really from -14 to 14 */
#define BAL_MIN		0
#define BAL_MID 	19

#include <stdio.h>
#include <stdlib.h>
#include <tos.h>

int left, right;

void
set_balance( int balance )
{

	/* If the current balance is set in the left direction.. */

	if( balance < BAL_MID ) {

		/* Set left to the highest level, set the right to 
		 * reflect that it is lower. 
		 */
		 
		left  = MAX_BAL;
		right = MAX_BAL - ( abs ( (MAX_BAL/2 - balance ) ) );
	} else {
	
		left  = MAX_BAL - ( abs ( ( MAX_BAL/2 - balance ) ) );
		right = MAX_BAL;
	}
}

void
main( void )
{
	int i;

	for( i=0; i<39; i++ ) {
		set_balance( i );
		printf("Left: %d       Right: %d \r\n",left, right );
	}
}
	