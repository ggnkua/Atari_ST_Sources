/*
	file: printer.c
	utility:
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C. Moreau: Adding Gdos support
	comments: 
*/
#include <stdio.h>
#include <string.h>

#ifdef __PUREC__ 
#include <tos.h>
#include <compend.h>
#else
#include <osbind.h>
#endif

#include "e:\proging\c\libs\malib\alert.h"

#include "cursor.h"
#include "init.h"
#include "onepage.h"
#include "printer.h"
#include "wind.h"

#include "bfed_rsc.h"

/* 
	locals functions
*/
static void print_line(windowptr thewin,long	pos);
static void pr_print(char *str);

/*
	name: print
	utility: send file or block to printer
	comment: 
	parameters:
	return:
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C. Moreau: 
*/
void print(windowptr thewin)
{

	if(!Bcostat(0))
	{
		rsc_alert(PRN_OFF);
	}
	else
	{
		long pos;

		while(Cconis())
			Crawcin(); /* make sure io buffer clear */

		if(thewin->markson)
		{
			if (rsc_falert(PRN_BLK, thewin->title) == 1)	
				for (pos=thewin->startmark; pos<thewin->endmark+NB_DATA_IN_LINE;
						pos+=NB_DATA_IN_LINE)
				{
					print_line(thewin, pos);
					if (Cconis())
					{
						Crawcin();
					 	break;  /* any key to abort */
					}		
				}
		}		
		else
		{
			if (rsc_falert(PRN_FILE, thewin->title) == 1)	
				for (pos=0; pos<thewin->flen+NB_DATA_IN_LINE+1;
						pos+=NB_DATA_IN_LINE)
				{
					print_line(thewin, pos);
					if (Cconis())
					{
						Crawcin();
					 	break;  /* any key to abort */
					}		
				}
		}
	}		
}

/*
	name: print_line
	utility: send a line to the printer
	comment: 
	parameters:
		windowptr thewin: window data
		long pos: aligned data
	return:
	date: 1989
	author: Jim Charlton
	modifications:
*/
static void print_line(windowptr	thewin, long	pos)
{
	const long  l = (pos/NB_DATA_IN_LINE)*NB_DATA_IN_LINE;
	unsigned num;
	register int j,k;
	char *hexa_ptr = hexa_str;
	char *ascii_ptr = ascii_str;

	for (j=0; j < 16 ; j +=2 )
	{  
		for (k=0; k < 2  ; k++	)
		{
			if(l+j+k < thewin->flen-1)
			{
				num = getbyte(thewin,l + j + k);
				if(num>31)
					*(ascii_ptr++) = num;
				else
					*(ascii_ptr++) = (unsigned)0x2E;
				strncpy(hexa_ptr, table+num*2,2);
				hexa_ptr += 2;
			}
			else
			{
				strncpy(hexa_ptr, DOUBLE_BLANK, 2);
				hexa_ptr += 2;
				*(ascii_ptr++) = BLANK;
			}
		}
		memcpy(hexa_ptr, DOUBLE_BLANK, 2);
		hexa_ptr+=2;
	}	
	memcpy(hexa_ptr, DOUBLE_BLANK, 3);
	hexa_ptr+=3;
	pr_print(hexa_str);
	*(ascii_ptr++)=0x0D;
	*(ascii_ptr++)=0x0A;
	*(ascii_ptr++)='\0';
	pr_print(ascii_str);
}

/*
	name: pr_print
	utility: send a string to the printer
	comment: 
	parameters:
	return:
	date: 1989
	author: Jim Charlton
	modifications:
*/
static void pr_print(char *str)
{
	register int i;

	for (i=0;i<(strlen(str)+1);i++)
		Bconout(0,str[i]);
}	
