/********************************************
	file: onepage.c
	utility: Display one window full of data.
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C. Moreau:
	comments:
*********************************************/

/********************************************
	includes
*********************************************/
#include <stdio.h>
#include <string.h>

#ifdef __PUREC__ 
#include <aes.h>
#include <vdi.h>
#include <compend.h>
#else
#include <aesbind.h>
#include <vdibind.h>
#endif

#include "cursor.h"
#include "init.h"
#include "onepage.h"
#include "wind.h"

/********************************************
	defines
*********************************************/

/********************************************
	locals vars declarations & definitions
*********************************************/

/********************************************
	globals vars declarations
*********************************************/
char hexa_str[80], ascii_str[80];
char table[600];

/********************************************
	locals functions declarations
*********************************************/
static void one_line0(windowptr	thewin,long pos);
static void one_line1(windowptr	thewin,long pos);

/********************************************
	globals functions definitions
*********************************************/
/*
	name: one_page
	utility: draw one window full of data
	comment: 
	parameters:
	return:
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C. Moreau: 
*/
void one_page(windowptr thewin, GRECT *r1)
{
		/* number of char in the window */
	long nc = (thewin->work.g_h/gl_hchar)*NB_DATA_IN_LINE;
	register long pos_char;

		/* Clipping on */
	pxyarray[0] = r1->g_x;
	pxyarray[1] = r1->g_y;
	pxyarray[2] = r1->g_x + r1->g_w-1;
	pxyarray[3] = r1->g_y + r1->g_h-1;
	vs_clip(thewin->graf.handle, CLIP_ON, pxyarray);

	if (partial)
	{
		nc -= thewin->position - thewin->topchar + NB_DATA_IN_LINE;

		for (pos_char = 0; pos_char < nc; pos_char += NB_DATA_IN_LINE)
		{
			one_line0(thewin, thewin->position+pos_char);
		}

		partial = FALSE;
	}
	else
	{
		window_blank(thewin);

		for (pos_char = 0; pos_char < nc; pos_char += NB_DATA_IN_LINE)
		{
			one_line0(thewin, thewin->topchar+pos_char);
		}
	}

	vs_clip(thewin->graf.handle, CLIP_OFF, pxyarray);
}

/*
	name: getbyte
	utility: retreive any byte in file in ram
	comment: 
	parameters:
	return:
	date: 1989
	author: Jim Charlton
	modifications:
*/
unsigned getbyte(windowptr thewin, long pos)
{	
	if (pos < thewin->flen)
	{
		linkbufptr amem = thewin->headptr;
		char *addr;
		
		while (amem->inuse<=pos)
		{
			pos -= amem->inuse;
			amem = amem->next;
		}
		addr = (char *)(amem->block+pos);
		return (*addr);
	}
	else
		return ((unsigned)0x00);
}

/*
	name: putbyte
	utility: put byte lnum into file at pos
	comment: 
	parameters:
	return:
	date: 1989
	author: Jim Charlton
	modifications:
*/
void putbyte(windowptr thewin, long pos, long lnum)
{
	if (pos < thewin->flen)
	{
		linkbufptr amem = thewin->headptr;
		char *addr;
		
		while (amem->inuse<=pos)
		{
			pos -= amem->inuse;
			amem = amem->next;
		}
		addr = (char *)(amem->block+pos);
		*addr = (char)lnum;
		thewin->changed = TRUE;
	}
}

/*
	name: one_line0
	utility: 
	comment: 
	parameters:
	return:
	date: 1989
	author: Jim Charlton
	modifications:
*/
static void one_line0(windowptr thewin, long pos)
{
		/* aligned position of data in file */
	const long aligned_pos = (pos/NB_DATA_IN_LINE)*NB_DATA_IN_LINE;		/* take the 16 multiple closer */

	if ( 	(aligned_pos > thewin->endmark)
			|| ( (aligned_pos+NB_DATA_IN_LINE) < thewin->startmark ) )
		one_line1(thewin, aligned_pos);
	else
		one_line2(thewin, aligned_pos);
}

/*
	name: one_line1
	utility: handles unmarked text
	comment: 
	parameters:
		windowptr thewin:	window data.
		long pos: aligned position.
	return:
		none
	date: 1989
	author: Jim Charlton
	modifications:
		dec 1996: C. Moreau: Take off rounding to 16 (aligned pos) 
*/
static void one_line1(windowptr thewin, long pos)
{
		/* line number in window */
	const int lineno = (int)(pos - thewin->topchar)/NB_DATA_IN_LINE;
	int tx = thewin->work.g_x + 7;
	int ty = thewin->work.g_y + gl_hchar*(lineno+1);
	unsigned num;
	register int wordno;	/* word number on line */
	register int datano;	/* data number in word */
	unsigned char *hexa_ptr = hexa_str;
	unsigned char *ascii_ptr = ascii_str;

	for (wordno=0; wordno<NB_DATA_IN_LINE; wordno+=2)
	{
		for (datano=0; datano<2 ; datano++)
		{
        	if (pos+wordno+datano < thewin->flen-1)
			{
				num = getbyte(thewin, pos+wordno+datano);
				if (num)
					*(ascii_ptr++) = num;
				else
					*(ascii_ptr++) = BLANK;

				memcpy(hexa_ptr, table+num*2, 2);
				hexa_ptr += 2;
			}
			else
			{
				*(ascii_ptr++) = BLANK;

				memcpy(hexa_ptr, DOUBLE_BLANK, 2);
				hexa_ptr += 2;
			}
		}
		memcpy(hexa_ptr, DOUBLE_BLANK, 2);
		hexa_ptr += 2;
	}
	memcpy(hexa_ptr, DOUBLE_BLANK, 3);
	hexa_ptr += 3;
	
	vswr_mode(thewin->graf.handle, MD_REPLACE);
	v_gtext(thewin->graf.handle, tx, ty, hexa_str);
	
	tx += ASCII_DATA_OFFSET*gl_wchar; 
	*(ascii_ptr++) = '\0';
	v_gtext(thewin->graf.handle, tx, ty, ascii_str);
}

/*
	name: one_line2
	utility: handles mixed marked and unmarked
	comment: 
		windowptr thewin:	window data.
		long pos: aligned position.
	return:
		none
	date: 1989
	author: Jim Charlton
	modifications:
		dec 1996: C. Moreau: Take off rounding to 16 (aligned pos) 
*/
void one_line2(windowptr thewin,long pos)
{
	unsigned num;
	register int wordno;	/* word number on line */
	register int datano;	/* data number in word */
	const int lineno = (int)(pos - thewin->topchar)/NB_DATA_IN_LINE;
	int tx = thewin -> work.g_x + 7;
	int ty = thewin -> work.g_y + gl_hchar*(lineno+1);
	char *ascii_ptr = ascii_str;

	hexa_str[2]='\0';	/* prepare string (always 2 char long) */
	
	for (wordno = 0; wordno < NB_DATA_IN_LINE; wordno += 2)
	{
		for (datano = 0; datano < 2; datano++)
		{
			if(pos+wordno+datano < thewin->flen-1)
			{
				num = getbyte(thewin, pos+wordno+datano);
				if (num)
					*(ascii_ptr++) = num;
				else
					*(ascii_ptr++) = BLANK;

				strncpy(hexa_str, table+num*2, 2);

				if( (pos+wordno+datano >= thewin->startmark)	\
						&& (pos+wordno+datano <= thewin->endmark) ) 
					vswr_mode(thewin->graf.handle, MD_ERASE);
			}
			else
			{
				strncpy(hexa_str, DOUBLE_BLANK, 3);
				*(ascii_ptr++) = BLANK;
			}

			v_gtext(thewin->graf.handle, tx, ty, hexa_str);
			vswr_mode(thewin->graf.handle, MD_REPLACE);
			tx += 2*gl_wchar;
		}

		strncpy(hexa_str, DOUBLE_BLANK, 3);
		v_gtext(thewin->graf.handle, tx, ty, hexa_str);
		tx += 2*gl_wchar;
	}

	*(ascii_ptr++)='\0';
	v_gtext(thewin->graf.handle, tx, ty, ascii_str);
}

/*
	name: set_table
	utility: makes a table of ASCII hex bytes for 0 to 255
	comment: 
	parameters: none
	return: none
	date: 1989
	author: Jim Charlton
	modifications:
*/
void set_table(void)
{
	register unsigned i;
	
	for(i=0; i<256; i++)
		sprintf(table+2*i, "%02x", i);
}
