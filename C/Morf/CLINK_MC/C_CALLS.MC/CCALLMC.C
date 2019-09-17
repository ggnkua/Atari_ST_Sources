/*******************************************/
/* Example Lattice C5  -  C link to 68k MC */
/* ------------------     ---------------- */
/* This example consists of :-             */
/* CCALLMC.C     C source code             */
/* CCALLMC1.S    68k Assembler source      */
/* CCALLMC.LNK   LATTICE LINK DESCRIPTION  */
/*                                         */
/* Compile the C code. Assemble the MC     */
/* NB: Use the lattice assembler NOT devpac*/
/*     unless it's devpac 3. You NEED      */
/*     LATTICE Linkable code !!!!!         */
/* Then use the Lattice Linker to link to  */
/* a .PRG file.  (ie) use LINK WITH on the */
/*                    C file.              */
/*******************************************/

extern int MC1(int value1, int value2, int value3); /* external function
											 prototype */

void main(void)
{
int value1 = 100;
int value2 = 200;
int value3 = 300;
int ret = 0;

	ret = MC1(value1, value2, value3);		/* call machine code just
									   like any subroutine !  */

	printf("\n CALL MC1 returned %d", ret); /*Just to prove it worked.*/

/* you might want a pause after excecution - I couldn't be bothered */
}