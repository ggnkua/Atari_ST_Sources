/* The C code containing C1 and C2 routines called by MCCALLC.S */
/* assembler code. */

/* Written By MORF for the ICTARI user group. */

/* This passing parameter protocol is standard I think ! */
/* (passing parameters as longs (32bit) using the stack */
/* If not (then) it is the one used by LATTICE C */
/* The LNK files are for the Lattice LINKER */

int C1(char chr1, int value2, int value3)
/* Prints all passed parameters, adds value2 to value3 and returns the */
/* result to the calling routine. */
{
int ret;

	ret = value2+value3;

	printf("\n RUNNING C1"); 		/*Just to prove it worked.*/
	printf("\n chr1=%c, value2=%d, value3=%d", chr1, value2, value3);
	
	return (ret);		/* return value is bunged into D0 */
}

char C2(char chr1)
/* Prints out the passed character and returns it to calling routine */
{
	printf("\n RUNNING C2");
	printf("\n chr1 passed=%c ", chr1);
	
	return (chr1);		/* return value is bunged in D0 */
}