#include "joystick.h"

/************************************************************************/
/*   Used to access the matrix.  You must first write the appropriate	*/
/* value before any of the results can be used.  You must also be in	*/
/* EXECUTIVE status when accessing the hardware registers.				*/
/************************************************************************/
short	*joystick = (short *)JOYSTICK;
short	*fire_buttons = (short *)FIREBUTTONS;

short	joy_result;			/* used to store result when reading 0xFF9202 */
short	fire_result;		/* used to store result when reading 0xFF9200 */
short	key_result;			/* used to store result when reading 0xFF9202 */
char	joypad_cur[MAX_PLAYERS];		/* useful bit configuration data */
char	joypad_old[MAX_PLAYERS];		/* useful bit configuration data */
char	joypad_edge[MAX_PLAYERS];		/* useful bit configuration data */
char	firebuttons_cur[MAX_PLAYERS];	/* useful bit configuration data */
char	firebuttons_old[MAX_PLAYERS];	/* useful bit configuration data */
char	firebuttons_edge[MAX_PLAYERS];	/* useful bit configuration data */
short	keypad_cur[MAX_PLAYERS];		/* useful bit configuration data */
short	keypad_old[MAX_PLAYERS];		/* useful bit configuration data */
short	keypad_edge[MAX_PLAYERS];		/* useful bit configuration data */

/************************************************************************/
/*   This function looks at the joypad only.  The function returns		*/
/*  with joypad[] set accordingly:										*/
/*																		*/
/*     joypad[] =														*/
/*                JOYBIT_UP    [00001000] --> 	RIGHT					*/
/*                JOYBIT_LEFT  [00000100] --> 	LEFT					*/
/*                JOYBIT_DOWN  [00000010] --> 	DOWN					*/
/*                JOYBIT_RIGHT [00000001] --> 	UP						*/
/*																		*/
/************************************************************************/
get_joystick()
{
	int i;
	short	joystick_matrix_write[2] = {0xFE, 0xEF};

	for(i=0; i < MAX_PLAYERS; i++)
	{
		joypad_old[i] = joypad_cur[i];
		joypad_cur[i] = 0;

		*joystick = joystick_matrix_write[i];
		joy_result = *joystick;
		switch(joy_result)
		{
			case JOY1_UP: joypad_cur[i] = (joypad_cur[i] | 0x01);	
				break;
			case JOY1_DOWN: joypad_cur[i] = (joypad_cur[i] | 0x02);
				break;
			case JOY1_LEFT: joypad_cur[i] = (joypad_cur[i] | 0x04);
				break;
			case JOY1_RIGHT: joypad_cur[i] = (joypad_cur[i] | 0x08);
				break;
			case JOY1_UPRIGHT: joypad_cur[i] = (joypad_cur[i] | 0x09);
				break;
			case JOY1_UPLEFT: joypad_cur[i] = (joypad_cur[i] | 0x05);
				break;
			case JOY1_DOWNRIGHT: joypad_cur[i] = (joypad_cur[i] | 0x0A);
				break;
			case JOY1_DOWNLEFT: joypad_cur[i] = (joypad_cur[i] | 0x06);
				break;
			case JOY2_UP: joypad_cur[i] = (joypad_cur[i] | 0x01);	
				break;
			case JOY2_DOWN: joypad_cur[i] = (joypad_cur[i] | 0x02);
				break;
			case JOY2_LEFT: joypad_cur[i] = (joypad_cur[i] | 0x04);
				break;
			case JOY2_RIGHT: joypad_cur[i] = (joypad_cur[i] | 0x08);
				break;
			case JOY2_UPRIGHT: joypad_cur[i] = (joypad_cur[i] | 0x09);
				break;
			case JOY2_UPLEFT: joypad_cur[i] = (joypad_cur[i] | 0x05);
				break;
			case JOY2_DOWNRIGHT: joypad_cur[i] = (joypad_cur[i] | 0x0A);
				break;
			case JOY2_DOWNLEFT: joypad_cur[i] = (joypad_cur[i] | 0x06);
				break;
			default:
				break;
		}
		joypad_edge[i] = ((joypad_cur[i] ^ joypad_old[i]) & joypad_cur[i]);
	}

} /* get_joystick() */

/************************************************************************/
/*   This function looks at the fire buttons only. The function returns	*/
/*  with firebuttons[] set accordingly.									*/
/*																		*/
/*     firebuttons[] =													*/
/*                FIREBIT_OPTION [00010000] --> 	OPTION				*/
/*                FIREBIT_PAUSE  [00001000] --> 	PAUSE				*/
/*                FIREBIT_2      [00000100] --> 	FIRE 2				*/
/*                FIREBIT_1      [00000010] --> 	FIRE 1				*/
/*                FIREBIT_0      [00000001] --> 	FIRE 0				*/
/*																		*/
/************************************************************************/
get_firebuttons()
{
	int i;
	short buttons_matrix_write[8] = {0xFE,0xEF,0xFD,0xDF,0xFB,0xBF,0xF7,0x7F};

	for(i=0; i < MAX_PLAYERS; i++)
	{
		firebuttons_old[i] = firebuttons_cur[i];
		firebuttons_cur[i] = 0;

		*joystick = buttons_matrix_write[i+0];
		fire_result = *fire_buttons;
		switch(fire_result)
		{
			case FIRE1_0:	firebuttons_cur[i] = (firebuttons_cur[i] | 0x01);	
				break;
			case PAUSE1:	firebuttons_cur[i] = (firebuttons_cur[i] | 0x08);
				break;
			case FIRE2_0:	firebuttons_cur[i] = (firebuttons_cur[i] | 0x01);	
				break;
			case PAUSE2:	firebuttons_cur[i] = (firebuttons_cur[i] | 0x08);
				break;
			default:
				break;
		}
		*joystick = buttons_matrix_write[i+2];
		fire_result = *fire_buttons;
		switch(fire_result)
		{
			case FIRE1_1:	firebuttons_cur[i] = (firebuttons_cur[i] | 0x02);	
				break;
			case FIRE2_1:	firebuttons_cur[i] = (firebuttons_cur[i] | 0x02);	
				break;
		}
		*joystick = buttons_matrix_write[i+4];
		fire_result = *fire_buttons;
		switch(fire_result)
		{
			case FIRE1_2:	firebuttons_cur[i] = (firebuttons_cur[i] | 0x04);	
				break;
			case FIRE2_2:	firebuttons_cur[i] = (firebuttons_cur[i] | 0x04);	
				break;
		}
		*joystick = buttons_matrix_write[i+6];
		fire_result = *fire_buttons;
		switch(fire_result)
		{
			case OPTION1:	firebuttons_cur[i] = (firebuttons_cur[i] | 0x10);	
				break;
			case OPTION2:	firebuttons_cur[i] = (firebuttons_cur[i] | 0x10);	
				break;
		}
		firebuttons_edge[i] = ((firebuttons_cur[i] ^ firebuttons_old[i]) & firebuttons_cur[i]);
	}

} /* get_firebuttons() */

/************************************************************************/
/*   This function looks at the keypad only.  The function returns		*/
/*  with keypad[] set accordingly.										*/
/*																		*/
/*     keypad[] =														*/
/*                KEYBIT_POUND	[00001000 00000000] -->		#			*/
/*                KEYBIT_0		[00000100 00000000] --> 	0			*/
/*                KEYBIT_STAR	[00000010 00000000] --> 	*			*/
/*                KEYBIT_9		[00000001 00000000] --> 	9			*/
/*                KEYBIT_8		[00000000 10000000] --> 	8			*/
/*                KEYBIT_7		[00000000 01000000] --> 	7			*/
/*                KEYBIT_6		[00000000 00100000] --> 	6			*/
/*                KEYBIT_5		[00000000 00010000] --> 	5			*/
/*                KEYBIT_4		[00000000 00001000] --> 	4			*/
/*                KEYBIT_3		[00000000 00000100] --> 	3			*/
/*                KEYBIT_2		[00000000 00000010] --> 	2			*/
/*                KEYBIT_1		[00000000 00000001] --> 	1			*/
/*																		*/
/************************************************************************/
get_keypad()
{
	int i;
	short	keypad_matrix_write[6] = {0xFD,0xDF,0xFB,0xBF,0xF7,0x7F};

	for(i=0; i < MAX_PLAYERS; i++)
	{
		keypad_old[i] = keypad_cur[i];
		keypad_cur[i] = 0;

		*joystick = keypad_matrix_write[i+0];
		key_result = *joystick;
		switch(key_result)
		{
			case KEY1_STAR:	keypad_cur[i] = (keypad_cur[i] | 0x0200);
				break;
			case KEY1_7:	keypad_cur[i] = (keypad_cur[i] | 0x0040);
				break;
			case KEY1_4:	keypad_cur[i] = (keypad_cur[i] | 0x0008);
				break;
			case KEY1_1:	keypad_cur[i] = (keypad_cur[i] | 0x0001);
				break;
			case KEY2_STAR:	keypad_cur[i] = (keypad_cur[i] | 0x0200);
				break;
			case KEY2_7:	keypad_cur[i] = (keypad_cur[i] | 0x0040);
				break;
			case KEY2_4:	keypad_cur[i] = (keypad_cur[i] | 0x0008);
				break;
			case KEY2_1:	keypad_cur[i] = (keypad_cur[i] | 0x0001);
				break;
		}
		*joystick = keypad_matrix_write[i+2];
		key_result = *joystick;
		switch(key_result)
		{
			case KEY1_0:	keypad_cur[i] = (keypad_cur[i] | 0x0400);
				break;
			case KEY1_8:	keypad_cur[i] = (keypad_cur[i] | 0x0080);
				break;
			case KEY1_5:	keypad_cur[i] = (keypad_cur[i] | 0x0010);
				break;
			case KEY1_2:	keypad_cur[i] = (keypad_cur[i] | 0x0002);
				break;
			case KEY2_0:	keypad_cur[i] = (keypad_cur[i] | 0x0400);
				break;
			case KEY2_8:	keypad_cur[i] = (keypad_cur[i] | 0x0080);
				break;
			case KEY2_5:	keypad_cur[i] = (keypad_cur[i] | 0x0010);
				break;
			case KEY2_2:	keypad_cur[i] = (keypad_cur[i] | 0x0002);
				break;
		}
		*joystick = keypad_matrix_write[i+4];
		key_result = *joystick;
		switch(key_result)
		{
			case KEY1_POUND: keypad_cur[i] = (keypad_cur[i] | 0x0800);	
				break;
			case KEY1_9:	keypad_cur[i] = (keypad_cur[i] | 0x0100);
				break;
			case KEY1_6:	keypad_cur[i] = (keypad_cur[i] | 0x0020);
				break;
			case KEY1_3:	keypad_cur[i] = (keypad_cur[i] | 0x0004);
				break;
			case KEY2_POUND: keypad_cur[i] = (keypad_cur[i] | 0x0800);	
				break;
			case KEY2_9:	keypad_cur[i] = (keypad_cur[i] | 0x0100);
				break;
			case KEY2_6:	keypad_cur[i] = (keypad_cur[i] | 0x0020);
				break;
			case KEY2_3:	keypad_cur[i] = (keypad_cur[i] | 0x0004);
				break;
		}
		keypad_edge[i] = ((keypad_cur[i] ^ keypad_old[i]) & keypad_cur[i]);
	}

} /* get_keypad() */
