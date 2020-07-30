/* Tabs expandieren und komprimieren */
/*****************************************************************************
*
*											  7UP
*									  Modul: TABULAT.C
*									 (c) by TheoSoft '90
*
*****************************************************************************/
#include <portab.h>
#include <stdio.h>
#include <stdlib.h>
#include <aes.h>
#include "windows.h"
#include "forms.h"

#include "alert.h"
#include "7up.h"

#define  BLANK  ' '
#define  NEWLINE '\n'
#define  TAB	 '\t'
#define  NUL	 '\0'

extern OBJECT *winmenu,*tabmenu;

char *stpexpan(register char *ptarget, char *psource, register int incr, register int tarsize, register int *linelen)
{
	 char c;
	 register int len;		/* Running total of characters put  */
									/* into ptarget, also index of next */
									/* char in ptarget.					  */
	 int numspaces;

	 len = 0;
	 tarsize--;
	 while (((c = *psource) != NULL) && (len < tarsize))
	 {
	switch (c)
	{
		 case TAB:
		if ((incr > 0) &&
			 ((numspaces = (incr - (len % incr))) != 0))
		{
			 if ((len += numspaces) < tarsize)
			 {	 /* There's enough room.				 */
			while (numspaces--)
				 *ptarget++ = BLANK;
			break;
			 }
			 else	 /* There isn't enough room, */
			continue;	/* so quit.		  */
		}

		 /* Else TAB expansion is not in effect:			*/
		 /* just fall through and copy the TAB to ptarget.	  */

		 default:
		*ptarget++ = c;
		len++;
		break;
	}
	psource++;
	 }
	 *ptarget = '\0';
	 *linelen=len;
	 return (c ? psource : NULL);
}

char *stptabfy(char *psource, int incr)
{
	 char c;
	 register int col = 0;  /* Column counter (modulo incr).		*/
	 register int numblanks = 0; /* Number of blanks we've saved up.	*/

	 char	*pfrom = psource;
	 register char *pto	= psource;

	 do
	 {
	switch (c = *pfrom++)
	{
		 case BLANK:
		numblanks++;
		col++;
		if ((incr <= 0) ||
			 (col % incr == 0))
		{
			 *pto++	 = (char) ((numblanks > 1) ? TAB : BLANK);
			 numblanks = 0;
		}
		break;

		 case TAB:
		col	  =
		numblanks = 0;	 /* Discard the saved blanks	*/
		*pto++	  = TAB;
		break;

		 default:
		col++;
		for (; numblanks; numblanks--)
			 *pto++ = BLANK;		/* Spill any saved blanks */
		*pto++ = c;
		break;
	}
	 } while (c);

	 return (psource);
}

int hndl_tab(OBJECT *tree,WINDOW *wp)
{
	char str[3];
	int tab=0;
	if(wp)
	{
		sprintf(str,"%d",wp->tab);
		form_write(tree,TABULAT,str,FALSE);
		if(form_exhndl(tree,TABULAT,FALSE)==TABOK)
		{
			form_read(tree,TABULAT,str);
			if(*str)
				tab=atoi(str);
			else
				form_alert(1,Atabulat[0]);
			if(tab<1)
				tab=1;
		}
		else
			tab=wp->tab;
	}
	return(tab);
}
