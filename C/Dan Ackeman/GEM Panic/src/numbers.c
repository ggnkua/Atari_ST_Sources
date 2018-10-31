/* Numbers.C
 *
 * a bunch of routines for printing numbers onto the backing store
 *
 * A few modifications and the number of routines
 * could be reduced or turned into wrappers for one
 * general call.  I've left them seperate at the moment
 * for two reasons (1) laziness and (2) speed, the offsets
 * are fixed so I don't have look anything up.
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "global.h"

extern GRECT work;			/* desktop and work areas */

MFDB digitsource = {0L,6*16,12,6,0,1,0,0,0};

int text_ht = 12;

int mono_digits[] = {
0x7c30,0x7878,0xc0f8,0x30fe,0x7c7c,0x0000,
0xfe70,0xfc7c,0xccf8,0x70fe,0xfefe,0x0000,
0xc670,0xcc0c,0xccc0,0xe006,0xc6c6,0x0000,
0xc630,0x0c0c,0xccc0,0xc006,0xc6c6,0x0000,
0xc630,0x0c0c,0xccf8,0xc00c,0xc6c6,0x0000,
0xc630,0x1c38,0xccfc,0xfc0c,0x7cfe,0xfe00,
0xc630,0x183c,0xcc0e,0xfe18,0x7c7e,0x0000,
0xc630,0x380e,0xfc06,0xc618,0xc606,0x0000,
0xc630,0x7006,0x7c06,0xc618,0xc606,0x0000,
0xc630,0xe0c6,0x0cce,0xc618,0xc60e,0x0000,
0xfefc,0xfefe,0x0cfc,0xfe18,0xfe1c,0x0000,
0x7cfc,0xfe7c,0x0c78,0x7c18,0x7c18,0x0000
	};

/* convert_numbers()
 *
 * takes our mono_digits and covert them into a MFDB
 * for the current resolution.
 */

void
convert_numbers(void)
{ 
 	/* convert our numbers */
	digitsource.fd_addr = mono_digits;

	fix_image(&digitsource,1);
}

/* clear()
 *
 * makes a solid box area in the backing store
 * useful if you want your score etc to be printed in a box
 */
  
void
clear(int x,int y,int w,int h)
{
	int pxy[8];
	
	pxy[0] = pxy[1] = 0;
	pxy[2] = w-1;
	pxy[3] = h-1;
	pxy[4] = x;
	pxy[5] = y;
	pxy[6] = x + w - 1;
	pxy[7] = y + h - 1;

	vro_cpyfm(vdi_handle,(planes>9)?ALL_BLACK:ALL_WHITE,pxy,&back_pic,&back_pic);
}

/* prinl()
 *
 * prints a number into the backing store
 */

void
prinl(register long num,int x,int y,int fill)
{
	register int ndx = 0;
	char buf[10];
	int array[8];
	int penalty = 0;
	register long temp_num;

	/* make sure the number is in the acceptable range */
	if (num > 9999999L) num = 0L;
	
	if (num <0L)
	{
		penalty = 1;
		temp_num = 0-num;
	}
	else	
		temp_num = num;
		
	/* if number is zero, be sure to show one digit */
	if (!temp_num) buf[ndx++] = 0;

	/* build the number in reverse order */
	while (temp_num)
	{
		buf[ndx++] = (temp_num % 10);
		temp_num /= 10;
	}

	if (penalty)
		buf[ndx++] = 10;
	
	if (fill)
	{	x += 8 * (7-ndx);
	}

	while (--ndx >= 0)
	{
		array[0] = buf[ndx] * 8;
		array[1] = 0;
		array[2] = array[0] + 7;
		array[3] = text_ht - 1;
		array[4] = x;
		array[5] = y;
		array[6] = x + 7;
		array[7] = y + text_ht - 1;

		/* this line does the numbers in inverse */
		
		vro_cpyfm(vdi_handle,(planes>9)?NOT_SXORD:NOTS_AND_D,array,&digitsource,&back_pic);

		x += 8;
	}
}

/* show_score()
 * 
 * displays the score at a set address
 * If you want to change where your score
 * prints it's hardcoded right now and takes
 * a global variable 
 */
 
void
show_score(void)
{
	int array[8];

	array[0] = array[4] = 190;
	array[1] = array[5] = 5;
	array[2] = array[6] = array[0]+(7*8)-1;
	array[3] = array[7] = array[1]+text_ht-1;

	vro_cpyfm(vdi_handle,S_ONLY,array,&picsource,&back_pic);

	prinl(score,190,5,TRUE);

	add_rect(win[GAME_WIN].window_obj[ROOT].ob_x+array[0],
		win[GAME_WIN].window_obj[ROOT].ob_y+array[1],
		win[GAME_WIN].window_obj[ROOT].ob_x+array[2],
		win[GAME_WIN].window_obj[ROOT].ob_y+array[3]+1);

	if (score >= bonus_ship)
	{
		/*sound_play(S_BONUS);*/
		bonus_ship += BONUS;
		ships++;
		show_ships();
	}
}

#if 0
/* disabled as GemPanic doesn't use it */

/* show_time()
 * 
 * displays a countdown timer at a set address
 * If you want to change where your score
 * prints it's hardcoded right now and takes
 * a global variable 
 */
 
void
show_time(void)
{
	int array[8];

	array[0] = array[4] = 350;
	array[1] = array[5] = 5;
	array[2] = array[6] = 350+(7*8)-1;
	array[3] = array[7] = 5+text_ht-1;

	vro_cpyfm(vdi_handle,S_ONLY,array,&picsource,&back_pic);

	prinl(game_time,350,5,TRUE);
	add_rect(win[GAME_WIN].window_obj[ROOT].ob_x+array[0],
		win[GAME_WIN].window_obj[ROOT].ob_y+array[1],
		win[GAME_WIN].window_obj[ROOT].ob_x+(7*8),
		win[GAME_WIN].window_obj[ROOT].ob_y+text_ht);
}
#endif

/* show_ships()
 * 
 * displays number of remaining lives at a set address
 * If you want to change where your score
 * prints it's hardcoded right now and takes
 * a global variable 
 */
 
void
show_ships(void)
{
	int array[8];

	array[0] = array[4] = 320;
	array[1] = array[5] = 5;
	array[2] = array[6] = 320+(7*8)-1;
	array[3] = array[7] = 5+text_ht-1;

	vro_cpyfm(vdi_handle,S_ONLY,array,&picsource,&back_pic);

	prinl(ships,320,5,TRUE);
	add_rect(win[GAME_WIN].window_obj[ROOT].ob_x+array[0],
		win[GAME_WIN].window_obj[ROOT].ob_y+array[1],
		win[GAME_WIN].window_obj[ROOT].ob_x+array[2],
		win[GAME_WIN].window_obj[ROOT].ob_y+array[3]);
}

/* show_wave()
 * 
 * displays current wave number at a set address
 * If you want to change where your score
 * prints it's hardcoded right now and takes
 * a global variable 
 */
 
void
show_wave(void)
{
	int array[8];

	array[0] = array[4] = 37;
	array[1] = array[5] = 5;
	array[2] = array[6] = array[0]+(7*8)-1;
	array[3] = array[7] = array[1]+text_ht-1;

	vro_cpyfm(vdi_handle,S_ONLY,array,&picsource,&back_pic);

	prinl(wave,array[0],array[1],TRUE);
	add_rect(win[GAME_WIN].window_obj[ROOT].ob_x+array[0],
		win[GAME_WIN].window_obj[ROOT].ob_y+array[1],
		win[GAME_WIN].window_obj[ROOT].ob_x+array[2],
		win[GAME_WIN].window_obj[ROOT].ob_y+array[3]);
}

/* show_debug()
 * 
 * displays a number at a set address
 * If you want to change where your score
 * prints it's hardcoded right now and takes
 * a global variable 
 */
 
void
show_debug(int test)
{
	int array[8];

	array[0] = array[4] = 37;
	array[1] = array[5] = 20;
	array[2] = array[6] = array[0]+(7*8)-1;
	array[3] = array[7] = array[1]+text_ht-1;

	vro_cpyfm(vdi_handle,S_ONLY,array,&picsource,&back_pic);

	prinl(test,array[0],array[1],TRUE);

	add_rect(win[GAME_WIN].window_obj[ROOT].ob_x+array[0],
		win[GAME_WIN].window_obj[ROOT].ob_y+array[1],
		win[GAME_WIN].window_obj[ROOT].ob_x+array[2],
		win[GAME_WIN].window_obj[ROOT].ob_y+array[3]);
}
