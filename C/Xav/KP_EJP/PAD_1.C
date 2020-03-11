/*
**	pad_1.c
**
**	Written by Xav to accompany the EJP series in
**	Atari Computing. Designed for Lattice C, but should
**	be adaptable to suit any compiler.
**
**
**	Your homework, should you choose to accept it, is to
**	modify this code (and the ejp.h header file) to check
**	port B as well. 
**
**	At the moment the program doesn't actually end, so you could 
**	try adding some code to detect a particular combination of 
**	buttons on the joypad in order to quit the program. 
**	Alternatively, if your C programming is a little more 
**	advanced than that, you could check for a mouse button or 
**	a keypress.
**
**	It also doesn't do any checks to see whether or not the
**	machine actually has EJPs, so you might like to make it a
**	little more "bullet proof" by checking the _MCH cookie for
**	an STe (but not a Mega STe) or a Falcon030
*/



#include "ejp.h"



/* Function prototypes	*/

void main(void);								/* Program entry		*/




/*
**	void main (void);
**
**	Program entry point. Since this is such a minor program,
**	all the processsing also takes place here (apart from the
**	actual reading of the EJP - see ejp.h for details).
*/

void main(void)
{
	struct JOYPAD joypad_A;	/* Defined in ejp_defs.h	*/
	
	
	while(1)								/* To loop indefinitely			*/
	{
		/* First fill the structure												*/
		read_joypadA(&joypad_A);		/* Defined in ejp.h			*/
		
		
		/* Now just print out the results. Note that we		*/
		/* can't just use a "case" statement as there			*/
		/* may be more than one button being pressed.			*/
		
		if(joypad_A.UP == TRUE)
			printf("Up, ");
	
		if(joypad_A.DOWN == TRUE)
			printf("Down, ");
	
		if(joypad_A.LEFT == TRUE)
			printf("Left, ");
		
		if(joypad_A.RIGHT == TRUE)
			printf("Right, ");
			
		if(joypad_A.FIRE_A == TRUE)
			printf("A, ");

		if(joypad_A.FIRE_B == TRUE)
			printf("B, ");

		if(joypad_A.FIRE_C == TRUE)
			printf("C, ");
	
		if(joypad_A.PAUSE == TRUE)
			printf("Pause, ");
			
		if(joypad_A.OPTION == TRUE)
			printf("Option, ");				
		
		if(joypad_A.NUMPAD_1 == TRUE)
			printf("1, ");
		
		if(joypad_A.NUMPAD_2 == TRUE)
			printf("2, ");
	
		if(joypad_A.NUMPAD_3 == TRUE)
			printf("3, ");
				
		if(joypad_A.NUMPAD_4 == TRUE)
			printf("4, ");

		if(joypad_A.NUMPAD_5 == TRUE)
			printf("5, ");
		
		if(joypad_A.NUMPAD_6 == TRUE)
			printf("6, ");
	
		if(joypad_A.NUMPAD_7 == TRUE)
			printf("7, ");
	
		if(joypad_A.NUMPAD_8 == TRUE)
			printf("8, ");

		if(joypad_A.NUMPAD_9 == TRUE)
			printf("9, ");

		if(joypad_A.NUMPAD_STAR == TRUE)
			printf("*, ");

		if(joypad_A.NUMPAD_0 == TRUE)
			printf("0, ");

		if(joypad_A.NUMPAD_HASH == TRUE)
			printf("#, ");


		/* Finally, move the cursor onto the next line	*/
		printf("\n");
	
	}	/* End of while loop	*/
	

	/* Never actually reaches this line	*/
	return;
}
	
	
/*
**	There. Who said EJP programming was difficult?
*/

	
		
		