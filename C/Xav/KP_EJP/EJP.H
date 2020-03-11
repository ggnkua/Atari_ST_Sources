/*
**	ejp.h
**	=====
**
**	By Xav
**	======
**
**
**	Definitions and functions to make it easier and clearer to read the 
**	enhanced joystick ports
**
**	Includes definitions for:-
**
**		+ Joypads
**
**
**
**	And functions to:-
**
**		+ Read joypad A
**		+ Store the current joypad positions as the "old" positions
**
*/

/*
**	Include header files
*/

#include <osbind.h>				/* Contains Super()	*/
#include <stdlib.h>				/* Contains NULL		*/
#include "masks.h"
#include "ejp_defs.h"


/*
** Function prototypes
*/

void read_joypadA (struct JOYPAD *joypad_A);
void store_old_positions(struct JOYPAD *joyp_struct);



/*
**	Define the button names: FIRE_A_B is fire button A for port B
*/

#define	PAUSE_A				0xFFFE	/*	Bit 0  clear	*/
#define FIRE_A_A			0xFFFD	/*	Bit 1  clear	*/
#define	PAUSE_B				0xFFFB	/*	Bit 2  clear	*/
#define FIRE_A_B			0xFFF7	/*	Bit 3  clear	*/

#define	FIRE_B_A			0xFFFD	/*	Bit 1  clear	*/
#define	FIRE_B_B			0xFFF7	/*	Bit 3  clear	*/

#define	FIRE_C_A			0xFFFD	/*	Bit 1  clear	*/
#define	FIRE_C_B			0xFFF7	/*	Bit 3  clear	*/

#define OPTION_A			0xFFFD	/*	Bit 1  clear	*/
#define OPTION_B			0xFFF7	/*	Bit 3  clear	*/

#define	UP_A					0xFEFF	/*	Bit 8  clear	*/
#define DOWN_A				0xFDFF	/*	Bit 9  clear	*/
#define	LEFT_A				0xFBFF	/*	Bit 10 clear	*/
#define	RIGHT_A				0xF7FF	/*	Bit 11 clear	*/
#define	UP_B					0xEFFF	/*	Bit 12 clear	*/
#define	DOWN_B				0xDFFF	/*	Bit 13 clear	*/
#define LEFT_B				0xBFFF	/*	Bit 14 clear	*/
#define	RIGHT_B				0x7FFF	/*	Bit 15 clear	*/

#define	KEYPAD_STAR_A	0xFEFF	/*	Bit 8  clear	*/
#define KEYPAD_7_A		0xFDFF	/*	Bit 9  clear	*/
#define	KEYPAD_4_A		0xFBFF	/*	Bit 10 clear	*/
#define	KEYPAD_1_A		0xF7FF	/*	Bit 11 clear	*/
#define	KEYPAD_STAR_B	0xEFFF	/*	Bit 12 clear	*/
#define	KEYPAD_7_B		0xDFFF	/*	Bit 13 clear	*/
#define KEYPAD_4_B		0xBFFF	/*	Bit 14 clear	*/
#define	KEYPAD_1_B		0x7FFF	/*	Bit 15 clear	*/

#define	KEYPAD_0_A		0xFEFF	/*	Bit 8  clear	*/
#define KEYPAD_8_A		0xFDFF	/*	Bit 9  clear	*/
#define	KEYPAD_5_A		0xFBFF	/*	Bit 10 clear	*/
#define	KEYPAD_2_A		0xF7FF	/*	Bit 11 clear	*/
#define	KEYPAD_0_B		0xEFFF	/*	Bit 12 clear	*/
#define	KEYPAD_8_B		0xDFFF	/*	Bit 13 clear	*/
#define KEYPAD_5_B		0xBFFF	/*	Bit 14 clear	*/
#define	KEYPAD_2_B		0x7FFF	/*	Bit 15 clear	*/

#define	KEYPAD_HASH_A	0xFEFF	/*	Bit 8  clear	*/
#define KEYPAD_9_A		0xFDFF	/*	Bit 9  clear	*/
#define	KEYPAD_6_A		0xFBFF	/*	Bit 10 clear	*/
#define	KEYPAD_3_A		0xF7FF	/*	Bit 11 clear	*/
#define	KEYPAD_HASH_B	0xEFFF	/*	Bit 12 clear	*/
#define	KEYPAD_9_B		0xDFFF	/*	Bit 13 clear	*/
#define KEYPAD_6_B		0xBFFF	/*	Bit 14 clear	*/
#define	KEYPAD_3_B		0x7FFF	/*	Bit 15 clear	*/



/*
**	Joypad returns are boolean, so define TRUE and FALSE
*/

#define TRUE	1
#define FALSE	0


/**********************************************************
**
**	Functions begin here
**
**	Current functions are:-
**
**		+ read_joypadA();
**		+ store_old_positions();
**
*/


/*
**	read_joypadA(struct JOYPAD *joypad_A);
**
**	Reads joypad A once and fills in the JOYPAD
**	structure, ready for the main program to read.
*/

void read_joypadA(struct JOYPAD *joypad_A)
{
	void *stack_address;
	short *mask_address = (short *)0xFF9202;
	short *firebuttons = (short *)0xFF9200;
	short *keypad = (short *)0xFF9202;
	unsigned long firebuttons_pressed;
	unsigned long keypad_pressed;	
	
	
	/*
	**	First store the existing positions as the "old" ones
	*/

	store_old_positions(joypad_A);

	/*
	**	Read group 1 (up, down, left, right, pause, fire A)
	*/

	/* Supervisor mode	*/	
	stack_address = Super(NULL);

		/* Write the mask	*/
		*mask_address = PORTA_GROUP1;
		
		/* Read the results	*/
		firebuttons_pressed = *firebuttons;
		keypad_pressed = *keypad;			
	
	/* Back into user mode	*/
	Super(stack_address);
	
	
	/* Now just assign a TRUE to each element of the structure if
			the appropriate button is being pressed	*/
		
	if(~(keypad_pressed | UP_A)) joypad_A->UP = TRUE; 
		else joypad_A->UP = FALSE;
	
	if(~(keypad_pressed | DOWN_A)) joypad_A->DOWN = TRUE;
		else joypad_A->DOWN = FALSE;
	
	if(~(keypad_pressed | LEFT_A)) joypad_A->LEFT = TRUE;
		else joypad_A->LEFT = FALSE;
	
	if(~(keypad_pressed | RIGHT_A)) joypad_A->RIGHT = TRUE;
		else joypad_A->RIGHT = FALSE;

	if(~(firebuttons_pressed | PAUSE_A)) joypad_A->PAUSE = TRUE;
		else joypad_A->PAUSE = FALSE;
			
	if(~(firebuttons_pressed | FIRE_A_A)) joypad_A->FIRE_A = TRUE;
		else joypad_A->FIRE_A = FALSE;
		

	/*
	**	Read group 2 (*, 7, 4, 1, fire B)
	*/

	stack_address = Super(NULL);
	
		*mask_address = PORTA_GROUP2;
		firebuttons_pressed = *firebuttons;
		keypad_pressed = *keypad;			
	
	Super(stack_address);
	
	
	if(~(keypad_pressed | KEYPAD_STAR_A)) joypad_A->NUMPAD_STAR = TRUE; 
		else joypad_A->NUMPAD_STAR = FALSE;

	if(~(keypad_pressed | KEYPAD_7_A)) joypad_A->NUMPAD_7 = TRUE;
		else joypad_A->NUMPAD_7 = FALSE;
	
	if(~(keypad_pressed | KEYPAD_4_A)) joypad_A->NUMPAD_4 = TRUE;
		else joypad_A->NUMPAD_4 = FALSE;
	
	if(~(keypad_pressed | KEYPAD_1_A)) joypad_A->NUMPAD_1 = TRUE;
		else joypad_A->NUMPAD_1 = FALSE;
			
	if(~(firebuttons_pressed | FIRE_B_A)) joypad_A->FIRE_B = TRUE;
		else joypad_A->FIRE_B = FALSE;



	/*
	**	Read group 3 (0, 8, 5, 2, fire C)
	*/

	stack_address = Super(NULL);
	
		*mask_address = PORTA_GROUP3;
		firebuttons_pressed = *firebuttons;
		keypad_pressed = *keypad;			
	
	Super(stack_address);
	
	
	if(~(keypad_pressed | KEYPAD_0_A)) joypad_A->NUMPAD_0 = TRUE; 
		else joypad_A->NUMPAD_0 = FALSE;

	if(~(keypad_pressed | KEYPAD_8_A)) joypad_A->NUMPAD_8 = TRUE;
		else joypad_A->NUMPAD_8 = FALSE;
	
	if(~(keypad_pressed | KEYPAD_5_A)) joypad_A->NUMPAD_5 = TRUE;
		else joypad_A->NUMPAD_5 = FALSE;
	
	if(~(keypad_pressed | KEYPAD_2_A)) joypad_A->NUMPAD_2 = TRUE;
		else joypad_A->NUMPAD_2 = FALSE;

	if(~(firebuttons_pressed | FIRE_C_A)) joypad_A->FIRE_C = TRUE;
		else joypad_A->FIRE_C = FALSE;
		
		
	/*
	**	Read group 4 (#, 9, 6, 3, Option)
	*/

	stack_address = Super(NULL);
	
		*mask_address = PORTA_GROUP4;
		firebuttons_pressed = *firebuttons;
		keypad_pressed = *keypad;			
	
	Super(stack_address);
	
	
	if(~(keypad_pressed | KEYPAD_HASH_A)) joypad_A->NUMPAD_HASH = TRUE; 
		else joypad_A->NUMPAD_HASH = FALSE;

	if(~(keypad_pressed | KEYPAD_9_A)) joypad_A->NUMPAD_9 = TRUE;
		else joypad_A->NUMPAD_9 = FALSE;
	
	if(~(keypad_pressed | KEYPAD_6_A)) joypad_A->NUMPAD_6 = TRUE;
		else joypad_A->NUMPAD_6 = FALSE;
	
	if(~(keypad_pressed | KEYPAD_3_A)) joypad_A->NUMPAD_3 = TRUE;
		else joypad_A->NUMPAD_3 = FALSE;

	if(~(firebuttons_pressed | OPTION_A)) joypad_A->OPTION = TRUE;
		else joypad_A->OPTION = FALSE;

	return;
}


/*
**	void store_old_positions(struct JOYPAD *joyp_struct)
*/

void store_old_positions(struct JOYPAD *joyp_struct)
{
	joyp_struct->OLD_UP = joyp_struct->UP;
	joyp_struct->OLD_DOWN = joyp_struct->DOWN;
	joyp_struct->OLD_LEFT = joyp_struct->LEFT;
	joyp_struct->OLD_RIGHT = joyp_struct->RIGHT;
	joyp_struct->OLD_FIRE_A = joyp_struct->FIRE_A;
	joyp_struct->OLD_FIRE_B = joyp_struct->FIRE_B;
	joyp_struct->OLD_FIRE_C = joyp_struct->FIRE_C;
	joyp_struct->OLD_PAUSE = joyp_struct->PAUSE;
	joyp_struct->OLD_OPTION = joyp_struct->OPTION;
	joyp_struct->OLD_NUMPAD_0 = joyp_struct->NUMPAD_0;
	joyp_struct->OLD_NUMPAD_1 = joyp_struct->NUMPAD_1;
	joyp_struct->OLD_NUMPAD_2 = joyp_struct->NUMPAD_2;
	joyp_struct->OLD_NUMPAD_3 = joyp_struct->NUMPAD_3;
	joyp_struct->OLD_NUMPAD_4 = joyp_struct->NUMPAD_4;
	joyp_struct->OLD_NUMPAD_5 = joyp_struct->NUMPAD_5; 
	joyp_struct->OLD_NUMPAD_6 = joyp_struct->NUMPAD_6;
	joyp_struct->OLD_NUMPAD_7 = joyp_struct->NUMPAD_7;
	joyp_struct->OLD_NUMPAD_8 = joyp_struct->NUMPAD_8;
	joyp_struct->OLD_NUMPAD_9 = joyp_struct->NUMPAD_9;
	joyp_struct->OLD_NUMPAD_STAR = joyp_struct->NUMPAD_STAR;
	joyp_struct->OLD_NUMPAD_HASH = joyp_struct->NUMPAD_HASH;

	return;
}	