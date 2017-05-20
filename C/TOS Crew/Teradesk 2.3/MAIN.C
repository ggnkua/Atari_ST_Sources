/*
 * Teradesk. Copyright (c) 1993, 1994, 2002 W. Klaren.
 *
 * This file is part of Teradesk.
 *
 * Teradesk is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * Teradesk is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Teradesk; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include <np_aes.h>			/* HR 151102: modern */
#include <stdlib.h>
#include <string.h>
#include <tos.h>
#include <vdi.h>
#include <boolean.h>
#include <library.h>
#include <mint.h>
#include <system.h>
#include <xdialog.h>
#include <xscncode.h>

#include "batch.h"
#include "desk.h"
#include "environm.h"
#include "error.h"
#include "events.h"
#include "font.h"
#include "open.h"
#include "resource.h"
#include "version.h"
#include "xfilesys.h"
#include "dir.h"
#include "edit.h"
#include "file.h"
#include "filetype.h"
#include "icon.h"
#include "prgtype.h"
#include "screen.h"
#include "window.h"
#include "applik.h"
#include "icontype.h"
#include "va.h"		/* HR 060203 */
#include "video.h" /* DjV 007 150103 */

#define RSRCNAME	"desktop.rsc"

#define EVNT_FLAGS	(MU_MESAG|MU_BUTTON|MU_KEYBD)

Options options;
int ap_id;
char *optname;
int vdi_handle, ncolors, npatterns, max_w, max_h, nfonts; /* DjV 011 180103 */
SCRINFO screen_info;
FONT def_font;
static int menu_items[] =
{MINFO, TDESK, TLFILE, TVIEW, TOPTIONS};

int chrez = FALSE; 	/* DjV 007 050103 */

#if _MINT_
boolean mint = FALSE, magx = FALSE,	geneva = FALSE;	/* HR 151102 */ /* DjV 035 080203 for geneva */
#endif

boolean quit = FALSE, shutdown = FALSE; /* DjV 013 291202 */;

char *global_memory;


char msg_resnfnd[] = "[1][Unable to find resource file.|"
					 "Resource file niet gevonden.|"
					 "Impossible de trouver le|fichier resource.|"
					 "Resource Datei nicht gefunden.][ OK ]";

int hndlmessage(int *message);

/*
 * Execute the desktop.bat file.
 *
 * Result : FALSE if there is no error, TRUE if there is an error.
 */

static boolean exec_deskbat(void)
{
	char *batname;
	int error;

	/* Remove the ARGV variable from the environment. */

	clr_argv();

	/* Initialize the name of the configuration file. */

	if ((optname = strdup("desktop.cfg")) == NULL)
		error = ENSMEM;
	else
	{
		/* Find the desktop.bat file. */

		if ((batname = xshel_find("desktop.bat", &error)) != NULL)
		{
			/* Execute it. */

			exec_bat(batname);
			free(batname);
		}
	}

	if ((error != 0) && (error != EFILNF))
	{
		xform_error(error);
		return TRUE;
	}
	else
		return FALSE;
}

static void info(void)
{
	/* DjV 009 120203 ---vvv--- */
	/* Note: constant part of info for this dialog is handled in resource.c */
	long stsize, ttsize; /* size of ST-RAM and TT/ALT-RAM */
	if ( tos2_0() )
	{
		(void *)stsize = Mxalloc( -1L, 0 );			/* HR 230203; void * */
		(void *)ttsize = Mxalloc( -1L, 1 );
	}
	else
	{
		(void *)stsize = Malloc( -1L );
		ttsize = 0L;
	}
	/* rsc_ltoftext(infobox, INFOFMEM, (long) x_alloc(-1L)); */
	rsc_ltoftext(infobox, INFSTMEM, stsize ); 
	rsc_ltoftext(infobox, INFTTMEM, ttsize ); 
	/* DjV 009 120203 ---^^^--- */
	xd_dialog(infobox, 0);
}

/* DjV 008 251202:  ---vvv--- */

/* showhelp displays two help dialogs on HELP key */

static void showhelp (void)
{

	int button;

	button = xd_dialog( helpno1, 0 );
	if ( button == HELP1OK ) xd_dialog( helpno2, 0 );

}

/* DjV 008 251202  ---^^^--- */

/********************************************************************
 *																	*
 * Hulpfunkties voor dialoogboxen.									*
 * HR 151102 strip_name, cramped_name courtesy XaAES				*
 *																	*
 ********************************************************************/

/* HR 220401: strip leading and trailing spaces. */

/* static DjV 028 060203 */
void strip_name(char *to, const char *fro)
{
	const char *last = fro + strlen(fro) - 1;
	while (*fro && *fro == ' ')  fro++;
	if (*fro)
	{
		while (*last == ' ')
			last--;
		while (*fro && fro != last + 1)
			*to++ = *fro++;
	}
	*to = 0;
}

/* should become c:\s...ng\foo.bar */

void cramped_name(const char *s, char *t, int w)
{
	const char *q=s;
	char *p=t, tus[256];
	int l, d, h;

	l = strlen(q);
	d = l - w;

	if (d > 0)
	{
		strip_name(tus, s);
		q = tus;
		l = strlen(tus);
		d = l - w;
	}

	if (d <= 0)
		strcpy(t,s);
	else
	{
		if (w < 12)		/* 8.3 */
			strcpy(t, q+d); /* only the last ch's */
		else
		{
			h = (w-3)/2;
			strncpy(p,q,h);
			p+=h;
			*p++='.';
			*p++='.';
			*p++='.';
			strcpy(p,q+l-h);
		}
	}
}

char *strsncpy(char *dst, const char *src, size_t len)	/* HR 120203: secure cpy (0 --> len-1) */
{
	strncpy(dst, src, len - 1);		/* len is typical: sizeof(achararray) */
	*(dst + len - 1) = 0;
	return dst;
}

void digit(char *s, int x)
{
	x = x % 100;
	s[0] = x / 10 + '0';
	s[1] = x % 10 + '0';
}

/* HR 240103 */
void cv_tos_fn2form(char *dest, const char *source)
{
	int s = 0, d = 0;

	while ((source[s] != 0) && (source[s] != '.'))
		dest[d++] = source[s++];
	if (source[s] == 0)
		dest[d++] = 0;
	else
	{
		while (d < 8)
			dest[d++] = ' ';
		s++;
		while (source[s] != 0)
			dest[d++] = source[s++];
		dest[d++] = 0;
	}
}

/* This_is_a_thirty_two__bytes_name */

/* HR 240103: wrapper function for editable and possibly userdef fields. */
void cv_fntoform(OBJECT *ob, const char *src)
{
	char *dst = xd_get_obspec(ob).tedinfo->te_ptext;
	int  l    = xd_get_obspec(ob).tedinfo->te_txtlen;
	
#if _MINT_
	if (ob->ob_flags & EDITABLE)	/* HR 240103: cramping not applicable. */
	{
		if ((ob->ob_type&0xff) == XD_SCRLEDIT)
			l = sizeof(LNAME);			/* HR 240203 */
		strsncpy(dst, src, l);			/* HR 230203: secure copy */
	}
	else
		cramped_name(src, dst, l);			/* HR 151102 */
#else
		cv_tos_fn2form(dst, src);
#endif
}

/* HR 240103 */
void cv_tos_form2fn(char *dest, const char *source)
{
	int s = 0, d = 0;

	while ((source[s] != 0) && (s < 8))
		if (source[s] != ' ')
			dest[d++] = source[s++];
		else
			s++;
	if (source[s] == 0)
		dest[d++] = 0;
	else
	{
		dest[d++] = '.';
		while (source[s] != 0)
			if (source[s] != ' ')
				dest[d++] = source[s++];
			else
				s++;
		dest[d++] = 0;
	}
}

void cv_formtofn(char *dest, const char *source)
{
#if _MINT_		/* HR 151102 */
	strcpy(dest,source);
#else
	cv_tos_form2fn(dest, source);
#endif
}

/* 
 * Generalize set_opt to change display of any options button from bit flags, 
 * not only related to cprefs
 */

void set_opt( OBJECT *tree, int flags, int opt, int button)
{
	if ( flags & opt )
		tree[button].ob_state |= SELECTED;
	else
		tree[button].ob_state &= ~SELECTED;		
}

/* Inverse function to the above- set flags from the button */

void get_opt( OBJECT *tree, int *flags, int opt, int button)
{
	if ( tree[button].ob_state & SELECTED )
		*flags |= opt;
	else
		*flags &= ~opt;

}

static void set_dialmode(void)
{
	xd_setdialmode(options.dial_mode, hndlmessage, menu, (int) (sizeof(menu_items) / sizeof(int)), menu_items);
}


/* DjV 019 080103 ---vvv--- */

/* See also desk.h */

/* 
 * A routine for displaying a keyboard shortcut in an ASCII readable form; 
 * <DEL>, <BS>, <TAB> and <SP> are displayed as "DEL", "BS", "TAB" and "SP",
 * other single characters are represented by that character;
 * "control" is represented by "^";
 * Uppercase or ctrl-uppercase are assumed;
 * resultant string is never more than 4 characters long;
 * XD_CTRL is used for convenience; no need to define a new flag
 */

static void disp_short
(
	char *string,	/* resultant string */ 
	int kbshort,	/* keyboard shortcut to be displayed */ 
	int left		/* left-justify and 0-terminate string if true */
)
{
	int i,j;		/* counters */

	i = 3;			/* position of the leftmost character */

	switch ( kbshort & 0xFF )
	{
		case 0x08: 				/* Backspace */
			string[i--] = 'S';
			string[i--] = 'B';
			break;
		case 0x09: 				/* Tab */
			string[i--] = 'B';
			string[i--] = 'A';
			string[i--] = 'T';
			break;
		case 0x20: 				/* Space */
			string[i--] = 'P';
			string[i--] = 'S';
			break;
		case 0x7F: 				/* Delete */
			string[i--] = 'L';
			string[i--] = 'E';
			string[i--] = 'D';
			break;
		default:				/* Other */
			if ( kbshort ) 
				string[i--] =  (char)(kbshort & 0xFF);
			break; 	
	}
	
	if ( kbshort & XD_CTRL )	/* Preceded by ^ ? */
		string[i--] = '^';		
	
	for ( j = i; j >= 0; j-- ) /* fill blanks to the left */
		string[j] = ' ';	 
	
	if ( i >= 0 && left )		/* if needed- left justify, 0 terminate */
	{
		string[4] = 0;
		strip_name( string, string );
	}

}


/* 
 * A routine for inserting keyboard menu shortcuts into menu texts
 * it also marks where the domain of a new menu title begins;
 * for this, bit-flag XD_ALT is used (just convenient, no need to define
 * something else)
 */

static void ins_shorts(void)
{
	int 
		menui, 	/* menu item counter */
		lm;		/* length of string in menu item */ 

	char
		*where; /* address of location of shortcut in a menu string */

	for ( menui = MFIRST; menui <= MLAST; menui++ ) 		/* for each menu item */
	{
		if ( menu[menui].ob_type == G_STRING )		 		/* which is a string... */
		{
			if ( menu[menui].ob_spec.free_string[1] == ' ') /* and not a separator line */
			{
				lm = strlen(menu[menui].ob_spec.free_string); /* includes trailing spaces */
				where = menu[menui].ob_spec.free_string + (long)(lm - 5);

				disp_short( where, options.V2_2.kbshort[menui - MFIRST], FALSE);

			} 		/* ' ' ? 			*/
		}			/* string ? 		*/
		else
		{
			options.V2_2.kbshort[menui - MFIRST] = XD_ALT; /* under new title from now on */
		}
	}				/* for... 			*/
}

/* DjV 019 080103 ---^^^--- */


/* check for duplicate or invalid keys */
static
boolean check_key(int button, int *tmp)
{
	int i, j;

	if ( button != OPTCANC && button != OPTKCLR )
	{
		for ( i = 0; i < NITEM; i++ )
			for ( j = i + 1; j <= NITEM; j++ )
				/* XD_ALT below in order to skip items related to boxes */
				if (       (tmp[i] & XD_SCANCODE) != 0
			    	|| (   (tmp[i] & ~XD_ALT) != 0
			    	    &&  tmp[i] == tmp[j]
			    	   )
					|| ( tmp[i] == (XD_CTRL | BACKSPC) ) /* DjV 019 280103 */
					|| ( tmp[i] == (XD_CTRL | TAB) 		 /* DjV 019 280103 */
					|| ( tmp[i] == XD_CTRL ) )			 /* DjV 019 280103 */
			       )
				{
					alert_printf ( 1, DUPKEY, setprefs[OPTKKEY].ob_spec.tedinfo->te_ptext );
					return TRUE;
				}
	}
	return FALSE;
}

/* DjV 039 090203 ---vvv--- */
/*
 * routine arrow_form_do handles some redraws around a xd_form_do
 * which are needed to create effect of a pressed (3d) arrow buton
 * related to a scrolled field
 */

int arrow_form_do
(
	XDINFO *treeinfo, 	/* dialog tree info */
	int *oldbutton		/* previously pressed button, 0 if none */
)
{
	OBJECT *tree;
	int button;

	tree = treeinfo->tree;

	if ( *oldbutton > 0 )
	{
		evnt_timer(150, 0);
		if ( (xe_button_state() & 1) == 0 )
		{
			tree[*oldbutton].ob_state &= ~SELECTED; 
			xd_draw ( treeinfo, *oldbutton, 1 ); 
			*oldbutton = 0;
		}	
	}
	button = xd_form_do(treeinfo, ROOT) & 0x7FFF;

	if ( button != *oldbutton )
	{
		tree[button].ob_state |= SELECTED;
		xd_draw ( treeinfo, button, 1 );
		*oldbutton = button;
	}
	return button;
}

/* DjV 039 090203 ---^^^--- */

static void setpreferences(void)
{
	int button;
	int oldbutton; /* DjV 039 090203 aux for arrow_form_do */

	/* DjV 019 060103 070103 ---vvv--- */

	static XDINFO prefinfo; 
	static int menui=MFIRST;/* .rsc index of currently displayed menu item */
	int mi;					/* menui - MFIRST */
	int redraw;				/* true if to redraw menu item and key def */
	int lm;					/* length of text field in current menu item */
	int lf;					/* length of form for menu item text */
	int i;				 	/* counters */
	int tmp[NITEM+2];		/* temporary kbd shortcuts (until OK) */
	char aux[5];			/* temp. buffer for string manipulation */

	/* DjV 019 060103 070103 ---^^^--- */

	xd_set_rbutton(setprefs, OPTPAR2, (options.cprefs & DIALPOS_MODE) ? DMOUSE : DCENTER);
	xd_set_rbutton(setprefs, OPTPAR1, DNORMAL + options.dial_mode);

	itoa(options.tabsize, tabsize, 10);
	/* itoa(options.bufsize, copybuffer, 10); DjV 016 050103 moved to another dialog*/

	/* DjV 019 060103 ---vvv--- */

	/* button = xd_dialog(setprefs, TABSIZE); */

	/* Get length of space for displaying menu items */

	lf = setprefs[OPTMTEXT].ob_spec.tedinfo->te_txtlen - 1;

	/* Copy shortcuts to a temporary buffer (until OK'd)  */

	for ( i = 0; i <= NITEM; i++ )
		tmp[i] = options.V2_2.kbshort[i];

	/* Open dialog; then loop until OK or Cancel */
	
	xd_open(setprefs, &prefinfo);

	redraw = TRUE;
	button = OPTMNEXT; /* anything*/
	oldbutton = -1; 	/* DjV 039 090203 */

	while ( button != OPTOK && button != OPTCANC )
	{

		/* Display text of current menu item */

		mi = menui - MFIRST;

		if ( redraw )
		{
			lm = strlen(menu[menui].ob_spec.free_string); /* How long? Assumed always to be lm > 5 */

			/* Copy menu text to dialog, remove shortcut text */

			strncpy 
			( 
				setprefs[OPTMTEXT].ob_spec.tedinfo->te_ptext, 
				menu[menui].ob_spec.free_string, 
				min(lm, lf) 
			);

			for ( i= min(lf, lm - 5); i < lf; i++ )
				setprefs[OPTMTEXT].ob_spec.tedinfo->te_ptext[i] = ' ';

			/* Display defined shortcut */

			disp_short( setprefs[OPTKKEY].ob_spec.tedinfo->te_ptext, tmp[mi], TRUE );
        
			xd_draw ( &prefinfo, OPTMTEXT, 1 );
			xd_draw ( &prefinfo, OPTKKEY, 1 );
			redraw = FALSE;
		}

		/* HR Do not use goto's!!! */
		do 		/* again: */
		{
			/* xd_change( &prefinfo, button, NORMAL, TRUE ); DjV 039 090203 */
			/* button = xd_form_do ( &prefinfo, ROOT ); DjV 039 090203 */
			button = arrow_form_do ( &prefinfo, &oldbutton ); /* DjV 039 090203 */

			/* Interpret shortcut from the dialog */

			strip_name( aux, setprefs[OPTKKEY].ob_spec.tedinfo->te_ptext );
			/* strupr ( aux ); DjV 019 280103 not needed anymore */
			strcpy ( setprefs[OPTKKEY].ob_spec.tedinfo->te_ptext, aux );
			
			i = strlen( aux );
			tmp[mi] = 0;

			switch ( i )
			{
				case 0:						/* nothing defined */
					break;
				case 1:						/* single-character shortcut */
					tmp[mi] = (int)aux[0];
					break;
				case 2:						/* two-character ^something shortcut */
					if (    aux[0] == '^' 
					     && aux[1] >= 'A'	/* DjV 019 280103 changed > 0x20 to >= 'A' */
						 && aux[1] <= 'Z' )	/* DjV 019 280103 changed > 0x7f fo <= 'Z' */
						tmp[mi] =  (int)aux[1] | XD_CTRL;
					else					/* DjV 019 280103 */
						tmp[mi] = XD_CTRL;  /* DjV 019 280103 illegal */
					break;	
				default:					/* longer shortcuts */
					if ( aux[0] == '^' )
					{
						tmp[mi] = XD_CTRL;
						aux[0] = ' ';
						strip_name( aux, aux );
					}
					if ( strcmp( aux, "BS" ) == 0 )
						tmp[mi] |= BACKSPC;	/* DjV 019 280103 used macros instad of hex values*/
					else if ( strcmp( aux, "TAB" ) == 0 )
						tmp[mi] |= TAB;		/* DjV 019 280103 */
					else if ( strcmp( aux, "SP" ) == 0 )
						tmp[mi] |= SPACE;	/* DjV 019 280103 */
					else if ( strcmp( aux, "DEL" ) == 0 )
						tmp[mi] |= DELETE;	/* DjV 019 280103 */
					else
						tmp[mi] = XD_SCANCODE; /* use this to mark invalid */
					break;
			}
		}
		while (check_key(button, tmp));

		/* 
		 * Only menu items which lie between MFIRST and MLAST are considered;
		 * if menu structure is changed, this interval should be redefined too;
		 * only those menu items with a space in the second char position
		 * are considered; other items are assumed not to be valid menu texts
		 * note: below will crash in the (ridiculous) situation when the
		 * first or the last menu item is not a good text
		 */

		switch ( button )
		{
			case OPTMPREV:
				while ( menui > MFIRST && menu[--menui].ob_type != G_STRING);
				if ( menu[menui].ob_spec.free_string[1] != ' ' ) menui--;
				redraw = TRUE;
				break;
			case OPTMNEXT:
				while ( menui < MLAST && menu[++menui].ob_type != G_STRING);
				if ( menu[menui].ob_spec.free_string[1] != ' ' ) menui++;
				redraw = TRUE;
				break;
			case OPTKCLR:
				for ( i = 0; i <= NITEM; i++ )
					tmp[i] = 0;
				redraw = TRUE;
				break;
			default:
				break;
		}
	} /* while... */

	xd_close(&prefinfo);

	/* DjV 019 060103 ---^^^--- */
	if (button == OPTOK)
	{
		int posmode = XD_CENTERED;

		/* DjV 019 070103 ---vvv--- */

		/* Reset pressed OK button */
	  		
		xd_change( &prefinfo, OPTOK, NORMAL, FALSE );

		/* Move shortcuts into perm. storage and menu and display them */

		for ( i = 0; i <= NITEM; i++ )
			options.V2_2.kbshort[i] = tmp[i];

		ins_shorts();

		/* DjV 019 070103 ---^^^--- */

		if (xd_get_rbutton(setprefs, OPTPAR2) == DMOUSE)
		{
			/* prefs |= DIALPOS_MODE; DjV 016 090103 */
			options.cprefs |= DIALPOS_MODE;
			posmode = XD_MOUSE;

		}
		else
			options.cprefs &= ~DIALPOS_MODE;

		options.dial_mode = xd_get_rbutton(setprefs, OPTPAR1) - DNORMAL;

		/* DjV 016 050103 ---vvv--- */
		/* moved to copyoptions
		if ((options.bufsize = atoi(copybuffer)) < 1)
			options.bufsize = 1;
		*/
		/* DjV 016 050103 ---^^^--- */
 
		if ((options.tabsize = atoi(tabsize)) < 1)
			options.tabsize = 1;

		set_dialmode();
		xd_setposmode(posmode);
	}
	/* DjV 019 070103 ---vvv--- */
	else
		xd_change( &prefinfo, OPTCANC, NORMAL, FALSE );

	/* DjV 019 070103 ---^^^--- */
}

/* DjV 016 050103 ---vvv--- */

static void copyprefs(void)
{
	int button;

	/* Set states of appropriate options buttons */

	set_opt(copyoptions, options.cprefs, CF_COPY, CCOPY);
	set_opt(copyoptions, options.cprefs, CF_DEL, CDEL);
	set_opt(copyoptions, options.cprefs, CF_OVERW, COVERW);
	set_opt(copyoptions, options.cprefs, CF_PRINT, CPRINT); /* DjV 031 010203 */
	/* set_opt(copyoptions, options.cprefs, CF_KEEP, CKEEP); DjV 016 140203 nothing done yet */

	itoa(options.bufsize, copybuffer, 10);

	button = xd_dialog(copyoptions, 0);

	if (button == COPTOK) /* selected OK ? */
	{	  
		/* Get new states of options buttons and new copy buffer size */

		get_opt( copyoptions, &options.cprefs, CF_COPY, CCOPY );
		get_opt( copyoptions, &options.cprefs, CF_DEL, CDEL );
		get_opt( copyoptions, &options.cprefs, CF_OVERW, COVERW );
		get_opt( copyoptions, &options.cprefs, CF_PRINT, CPRINT ); /* DjV 031 010203 */
		/* get_opt( copyoptions, &options.cprefs, CF_KEEP, CKEEP ); DjV 016 140203 nothing done about thio yet */

		if ((options.bufsize = atoi(copybuffer)) < 1)
			options.bufsize = 1;
	}
}

/* DjV 016 050103 ---^^^--- */

static void opt_default(void)
{
	options.version = CFG_VERSION;
	options.magic = MAGIC;
	/* options.cprefs = CF_COPY | CF_DEL | CF_OVERW; DjV 031 010203 */
	options.cprefs = CF_COPY | CF_DEL | CF_OVERW | CF_PRINT; /* DJV 031 010203 */
	/* options.sort = 0; DjV 010 251202 */
	options.sort = WD_SORT_NAME; /* DjV 010 251202: substituted "0" with WD_SORT_NAME */
	options.V2_2.fields = WD_SHSIZ | WD_SHDAT | WD_SHTIM | WD_SHATT; /* DjV 010 251202 */
	/*	options.attribs = 0; DjV 004 251202 */
	options.attribs = FA_SUBDIR | FA_SYSTEM; /* DjV 004 251202 */
	options.tabsize = 8;
	/* options.mode = 0  DjV 010 251202 */
	options.mode = TEXTMODE; /* DjV 010 251202: subst. "0" with "TEXTMODE" */
	options.bufsize = 512;
	options.dial_mode = XD_NORMAL;
	options.resvd1 = 0;
	options.resvd2 = 0;
	get_set_video(0); /* DjV 007 030103 get current video mode for default */
	/* DjV 019 080103 ---vvv--- */
	
	/* Define some default keyboard shortcuts here ... */

	options.V2_2.kbshort[MOPEN - MFIRST] =    XD_CTRL | 'O';
	options.V2_2.kbshort[MSHOWINF - MFIRST] = XD_CTRL | 'I';
	options.V2_2.kbshort[MSEARCH - MFIRST] =  XD_CTRL | 'F';
	options.V2_2.kbshort[MPRINT - MFIRST] =   XD_CTRL | 'P'; /* DjV 029 300103 */
	options.V2_2.kbshort[MSELALL - MFIRST] =  XD_CTRL | 'A';
	options.V2_2.kbshort[MQUIT - MFIRST] =    XD_CTRL | 'Q';
	options.V2_2.kbshort[MDELETE - MFIRST] =  XD_CTRL | 0x7f; /* ^DEL */
	options.V2_2.kbshort[MSAVESET - MFIRST] = XD_CTRL | 'S';

	ins_shorts();
	/* DjV 019 080103 ---^^^--- */
}

static void load_options(void)
{
	XFILE *file;
	Options tmp;
	int error = 0;
	long n, opt_n;

	get_set_video(0); /* DjV 007 030103 get current video mode */
	
	if ((file = x_fopen(optname, O_DENYW | O_RDONLY, &error)) != NULL)
	{
		opt_n = sizeof(Options);
		tmp.version = 0;
		x_fread(file, &tmp, sizeof(int));

/* HR 240103: load older cfg versions */
		if (   tmp.version >= MIN_VERSION
		    && tmp.version <  CFG_VERSION
		   )
		{
			memset(&tmp.V2_2, 0, sizeof(tmp.V2_2));
			opt_n -= sizeof(tmp.V2_2);
		}

		x_fclose(file);
	}

	if ((file = x_fopen(optname, O_DENYW | O_RDONLY, &error)) != NULL)
	{
		if ((n = x_fread(file, &tmp, opt_n)) == opt_n)
		{
			if (   tmp.version >= MIN_VERSION		/* DjV 005 120103 (was 0x119) */
			    && tmp.version <= CFG_VERSION
			    && tmp.magic   == MAGIC
			   )
			{
				options = tmp;
				if (opt_n != sizeof(Options))		/* HR 240103 */
				{
					options.V2_2.fields = WD_SHSIZ | WD_SHDAT | WD_SHTIM | WD_SHATT; /* DjV 010 251202 HR 240103 */
					options.attribs = FA_SUBDIR | FA_SYSTEM; /* DjV 004 251202 HR 240103 */
				}
				ins_shorts();     /* DjV 019 080103 put kbd shortcuts into menu texts */
				wd_deselect_all();
				wd_default();

				if (tmp.cprefs & SAVE_COLORS)
					error = load_colors(file);

				if (error == 0)
					if ((error = dsk_load(file)) == 0)
						if ((error = ft_load(file)) == 0)
							if ((error = icnt_load(file)) == 0)
								if ((error = app_load(file)) == 0)
									if ((error = prg_load(file)) == 0)
										error = wd_load(file);
			}
			else
			{
				alert_printf(1, MVALIDCF);
				x_fclose(file);
				return;
			}
			/* DjV 007 030103 ---vvv--- */
			
			/* If read ok, set video state but do not change resolution */
			
			get_set_video(1);
			
			/* DjV 007 030103 ---^^^--- */
		}
		else
		{
			error = (n < 0) ? (int) n : EEOF;
			hndl_error(MLOADCFG, error);
			x_fclose(file);
			return;
		}
		x_fclose(file);
	}

	if (error != 0)
	{
		hndl_error(MLOADCFG, error);

		opt_default();
		dsk_default();
		ft_default();
		icnt_default();
		app_default();
		prg_default();
		wd_default();
	}

	if (options.version < 0x0130)
		options.dial_mode = (options.cprefs & 0x80) ? XD_BUFFERED : XD_NORMAL;

	xd_setposmode((options.cprefs & DIALPOS_MODE) ? XD_MOUSE : XD_CENTERED);
	set_dialmode();

	options.version = CFG_VERSION;
}

static void save_options(void)
{
	XFILE *file;
	long n;
	int error = 0, h;

	graf_mouse(HOURGLASS, NULL);

	if ((file = x_fopen(optname, O_DENYRW | O_WRONLY, &error)) != NULL)
	{
		if ((n = x_fwrite(file, &options, sizeof(Options))) == sizeof(Options))
		{
			if (options.cprefs & SAVE_COLORS)
				error = save_colors(file);

			if (error == 0)
				if ((error = dsk_save(file)) == 0)
					if ((error = ft_save(file)) == 0)
						if ((error = icnt_save(file)) == 0)
							if ((error = app_save(file)) == 0)
								if ((error = prg_save(file)) == 0)
									error = wd_save(file);
		}
		else
			error = (int) n;

		if (((h = x_fclose(file)) < 0) && (error == 0))
			error = h;
	}

	graf_mouse(ARROW, NULL);

	if (error != 0)
		hndl_error(MSAVECFG, error);

	wd_set_update(WD_UPD_COPIED, optname, NULL);
	wd_do_update();
}

static void save_options_as(void)
{
	char *newname;

	if ((newname = locate(optname, L_SAVECFG)) != NULL)
	{
		free(optname);
		optname = newname;
		save_options();
	}
}

static void load_settings(void)
{
	char *newname;

	if ((newname = locate(optname, L_LOADCFG)) != NULL)
	{
		free(optname);
		optname = newname;
		load_options();
	}
}

/*
 * Initiation function.
 *
 * Result: FALSE if no error, TRUE if error.
 */

static boolean init(void)
{
	int error;
	char *fullname;

	xw_get(NULL, WF_WORKXYWH, &screen_info.dsk);

	if ((fullname = xshel_find(optname, &error)) != NULL)
	{
		free(optname);
		optname = fullname;
	}
	else
	{
		if ((error == EFILNF) && ((fullname = x_fullname(optname, &error)) != NULL))
		{
			free(optname);
			optname = fullname;
		}
		if (error != 0)
		{
			xform_error(error);
			return TRUE;
		}
	}

	if (dsk_init() == TRUE)
		return TRUE;

	ft_init();
	icnt_init();
	app_init();
	prg_init();
	wd_init();

	menu_bar(menu, 1);

	x_setpath("\\");

	load_options();

	return FALSE;
}

static void init_vdi(void)
{
	int dummy, work_out[58], pix_height;

	screen_info.phy_handle = graf_handle(&screen_info.fnt_w, &screen_info.fnt_h, &dummy, &dummy);

	vq_extnd(vdi_handle, 0, work_out);

	max_w = work_out[0] + 1;	/* Screen width (pixels)  */
	max_h = work_out[1] + 1;	/* Screen height (pixels) */
	ncolors = work_out[13];		/* Number of colours      */
	npatterns = work_out[14];	/* Number of patterns DjV 011 180103 */
	pix_height = work_out[4];


	/* DjV 007 190103 
	 * Note: vqt_attributes below uses work_out and destroys information
	 * in work_out[0] to work_out[9]; not a nice thing to do!
	 */

	vqt_attributes(vdi_handle, work_out);

	fnt_setfont(1, (int) (((long) work_out[7] * (long) pix_height * 72L + 12700L) / 25400L), &def_font);

	screen_info.vdi_handle = vdi_handle;
}

static int alloc_global_memory(void)
{
#if _MINT_
	if (magx || mint)
		global_memory = Mxalloc(GLOBAL_MEM_SIZE, 0x43);
	else
#endif
		global_memory = Malloc(GLOBAL_MEM_SIZE);

	return (global_memory) ? 0 : ENSMEM;
}

static void hndlmenu(int title, int item, int kstate)
{
	int qbutton; /* DjV 013 291202 */

	if ((menu[item].ob_state & DISABLED) == 0)
	{
		switch (item)
		{
		case MINFO:
			info();
			break;
		case MQUIT:
			/* DjV 013 291202 ---vvv--- */
			qbutton = alert_printf(3,QUITALRT); /* DjV 013 090203  shutdown revived */
			switch (qbutton)
			{
				case 3:
					break;
				case 2:
					shutdown=TRUE; /* no effect yet */
					/* break;DjV 013 090203 only without shutdown */
				case 1:      
			/* DjV 013 291202 ---^^^--- */
					menu_tnormal(menu, title, 1);
					quit = TRUE;
					break;
			}        /* DjV 013 291202 */
			break;
		case MOPTIONS:
			setpreferences();
			break;
		case MPRGOPT:
			prg_setprefs();
			break;
		case MSAVESET:
			save_options();
			break;
		case MLOADOPT:
			load_settings();
			break;
		case MSAVEAS:
			save_options_as();
			break;
		case MAPPLIK:
			app_install();
			break;
		case MIDSKICN:
			dsk_insticon();
			break;
		case MIWDICN:
			icnt_settypes();
			break;
		case MCHNGICN:
			dsk_chngicon();
			break;
		case MREMICON:
			dsk_remicon();
			break;
		case MEDITOR:
			set_editor();
			break;
		/* DjV 016 050103 ---vvv--- */	
		case MCOPTS:
			copyprefs();
			break;
		/* DjV 016 050103 ---^^^--- */
		case MWDOPT:
			dsk_options();
			break;
		/* DjV 007 250102 ---vvv--- */	
		case MVOPTS:
			chrez=voptions();
			if ( chrez ) quit=TRUE;
			break;
		/* DjV 007 250102 ---^^^--- */
		default:
			wd_hndlmenu(item, kstate);	/* handle all the rest in window.c */
			break;
		}
	}
	menu_tnormal(menu, title, 1);
}

/* DjV 019 100103 ---vvv--- */

/* 
 * this little routine converts keyboard scancodes into format in which
 * keyboard shortcuts are saved ( XD_CTRL | char_ascii_code )
 * this routine should prevent, somewhat better than earlier code,
 * unwanted (erroneous) recognition of weird key combinations
 */
int scansh ( int key, int kstate )
{
	int a;

	a = key & 0xff;
	if ( a <= 'z' && a >= 'a' )
		a &= 0xdf; 						/* to uppercase */
	if ( kstate == 4 ) 					/* ctrl  */
		/* DjV 019 280103 ---vvv--- bug correction */
		/* a |= (XD_CTRL | 64); */
		if ( a == SPACE || a == ESCAPE )	/* ^SP ^ESC  */
			a |= XD_CTRL;
		else if ( a == 0x1f ) 				/* ^DEL      */
			a |= ( XD_CTRL | 0x60 );
		else 								/* ^A ... ^\ */
			a |= ( XD_CTRL | 0x40 );
		/* DjV 019 280103 ---^^^--- */
	else
	if ( kstate > 2 || key < 0 ) 		/* everything but shift or plain */
		a = -1;							/* shortcut def. is never this value */
	return a;
}
/* DjV 019 100103 ---^^^--- */

static void hndlkey(int key, int kstate)
{
	int i = 0, k;
	APPLINFO *appl;
	int title; 				/* DjV 019 110103 rsc index of current menu title */

	if ( (unsigned int)key == HELP )
		showhelp();						/* DjV 007 251202 */

	k = key & ~XD_CTRL;

	if ((((unsigned int) k >= 0x803B) && ((unsigned int) k <= 0x8044)) ||
		(((unsigned int) k >= 0x8154) && ((unsigned int) k <= 0x815D)))
	{
		k &= 0xFF;
		k = (k >= 0x54) ? (k - 0x54 + 11) : (k - 0x3B + 1);

		if ((appl = find_fkey(k)) != NULL)
			app_exec(NULL, appl, NULL, NULL, 0, kstate, FALSE);
	}
	else
	{
		/* k = key & ~XD_ALT;          DjV 019 100103 */
		k = scansh ( key, kstate ); /* DjV 019 100103 */

		/* DjV 019 110103 ---vvv--- */
		/*
		while ((keys[i].scancode != k) && (i < (NKEYS - 1)))
			i++;

		if (keys[i].scancode == k)
		*/

		title = TFIRST;
		while (   (options.V2_2.kbshort[i] != k) && (i <= ( MLAST - MFIRST)) )
		{
			if ( (options.V2_2.kbshort[i] & XD_ALT) != 0 ) title++;  
			i++;
		}

		if ( options.V2_2.kbshort[i] == k )
		{
			/*
			menu_tnormal(menu, keys[i].title, 0);
			hndlmenu(keys[i].title, keys[i].item, kstate);
			*/
			menu_tnormal(menu, title, 0 );
			hndlmenu( title, i + MFIRST, kstate );
		
		}
		/* DjV 019 110103 ---^^^--- */

		else
		{
			i = 0;
			if ((key >= ALT_A) && (key <= ALT_Z))
			{
				i = key - (XD_ALT | 'A');
				if (check_drive(i))
				{
					char *path;

					if ((path = strdup("A:\\")) != NULL)
					{
						path[0] = (char) i + 'A';
						/* dir_add_window(path); DjV 017 280103 */
						dir_add_window(path, NULL); /* DjV 017 280103 */
						itm_set_menu(xw_top()); /* DjV 029 160203 */
					}
					else
						xform_error(ENSMEM);
				}
			}
		}
	}
}

int _hndlmessage(int *message, boolean allow_exit)
{
	if (   (   message[0] >= AV_PROTOKOLL
	        && message[0] <= VA_HIGH			/* HR 060203 */
	       )
	    || (   message[0] >= FONT_CHANGED
	        && message[0] <= FONT_ACK
	       )
	   )
		handle_av_protocol(message);
	else
	{
		switch (message[0])
		{
		case AP_TERM:
			if (allow_exit)
				quit = TRUE;
			else
			{
				static int ap_tfail[8] = { AP_TFAIL, 0 };

				shel_write(10, 0, 0, (char *) ap_tfail, NULL);
			}
			break;

		case SH_WDRAW:
			wd_update_drv(message[3]);
			break;
		}
	}

	return 0;
}

int hndlmessage(int *message)
{
	return _hndlmessage(message, FALSE);
}

static void evntloop(void)
{
	int event;
	XDEVENT events;

	events.ev_mflags = EVNT_FLAGS;
	events.ev_mbclicks = 0x102;			/* HR 151102: right button is double click */
	events.ev_mbmask = 3;
	events.ev_mbstate = 0;
	events.ev_mm1flags = 0;
	events.ev_mm2flags = 0;
	events.ev_mtlocount = 0;
	events.ev_mthicount = 0;

	while (!quit)
	{
		event = xe_xmulti(&events);

		clr_key_buf();		/*	HR 151102: This imposed a unsolved problem with N.Aes 1.2 (lockup of teradesk after live moving) */
/* It is not a essential function. */

		if (event & MU_MESAG)
		{
			if (events.ev_mmgpbuf[0] == MN_SELECTED)
				hndlmenu(events.ev_mmgpbuf[3], events.ev_mmgpbuf[4], events.ev_mmokstate);
			else
				_hndlmessage(events.ev_mmgpbuf, TRUE);
		}

		if (event & MU_KEYBD)
			hndlkey(events.xd_keycode, events.ev_mmokstate);
	}
}

#if _MINT_
int have_ssystem;
#endif

int main(void)
{
	int error;

#if _MINT_				/* HR 151102 */
	have_ssystem = Ssystem(-1, 0, 0) == 0;		/* HR 151102: use Ssystem where possible */

	mint   = (find_cookie('MiNT') == -1) ? FALSE : TRUE;
	magx   = (find_cookie('MagX') == -1) ? FALSE : TRUE;	/* HR 151102 */
	geneva = (find_cookie('Gnva') == -1) ? FALSE : TRUE;    /* DjV 035 080203 */
	mint  |= magx;			/* Quick & dirty */

	if (mint)
	{
		Psigsetmask(0x7FFFE14EL);
		Pdomain(1);
	}
#endif

	x_init();

	if ((ap_id = appl_init()) < 0)
		return -1;

	if  (_GemParBlk.glob.version >= 0x400)
	{
		shel_write(9, 1, 0, NULL, NULL);
		menu_register(ap_id, "  Tera Desktop");
	}

	if (rsrc_load(RSRCNAME) == 0)
		form_alert(1, msg_resnfnd);
	else
	{
		if ((error = init_xdialog(&vdi_handle, malloc, free,
								  "Tera Desktop", 1, &nfonts)) < 0)
			xform_error(error);
		else
		{
			init_vdi();
			rsc_init();

			if (((max_w / screen_info.fnt_w) < 40) || ((max_h / screen_info.fnt_h) < 25))
				alert_printf(1, MRESTLOW);
			else
			{
				if ((error = alloc_global_memory()) == 0)
				{
					if (exec_deskbat() == FALSE)
					{
						if (load_icons() == FALSE)
						{
							if (init() == FALSE)
							{
								graf_mouse(ARROW, NULL);
								evntloop();

								wd_del_all();
								menu_bar(menu, 0);
								xw_close_desk();
							}

							free_icons();		/* HR 151102 */

							wind_set(0, WF_NEWDESK, NULL, 0);
							dsk_draw();
						}
					}

					Mfree(global_memory);
				}
				else
					xform_error(error);
			}

			if (vq_gdos() != 0)
				vst_unload_fonts(vdi_handle, 0);
			exit_xdialog();
		}

		rsrc_free();
	}

	/* DjV 013 030103 100203 ---vvv--- */
	/*
	 * The following section handles system shutdown and resolution change
	 * If a resolution change is required, shutdown is performed first
	 * If only shutdown s required, system will reset at the end.
	 */ 

	/* appl_exit(); */

	if ( chrez || shutdown ) /* If change resolution or shutdown ... */
	{

		/* Tell all applications which would understand it to end */

		quit = shel_write ( 4, 2, 0, NULL, NULL ); 	/* complete shutdown */
		evnt_timer( 3000, 0 );						/* Wait a bit? */

		/*

		/* 
		 * In Mint, must tell all proceseses to terminate nicely ?
		 * but this is only in this group ? What to do?
		 */

		Pkill(0, SIGTERM); 
		evnt_timer(3000, 0); /* Wait a bit? */
		*/

		/* 
		 * After all applications have hopefully been closed,
		 * change the screen resolution if needed;
		 * else- reset the computer
		 */
		if ( chrez )
			get_set_video(2);

#if 1
		else
	#if _MINT_
		if (!mint)			/* HR 230203: Dont reset under MiNT or MagiC !!!!! */
	#endif
		{
			/* Perform a reset here */

	#if 0		/* with warnings */
			long *m;					/* to memory locations */
			long rv;					/* reset vector */

			Super ( 0L );				/* Supervisor; old stack won't be needed again */
			*(m = 0x420L) = 0L;			/* memctrl  */
			*(m = 0x43aL) = 0L;			/* memval2  */
			*(m = 0x426L) = 0L;			/* resvalid */	
			m = *( m = 0x4f2 );			/* to start of OS */
			rv = *(m + 4);				/* to routine that  handles the reset */
			Supexec(rv);				/* execute it */
	#else			/* HR: without warnings */
			long (*rv)();					/* reset vector */

			Super ( 0L );				/* Supervisor; old stack won't be needed again */
			memctrl = 0L;
			memval2 = 0L;
			resvalid = 0L;
			(long)rv = *((long *)os_start + 4);	/* routine that handles the reset */
			Supexec(rv);				/* execute it */
	#endif
		}
#endif
	}
	else	/* Just Quit */		
		appl_exit();
	
	/* DjV 013 030103 100203 ---^^^--- */
	
	return 0;
}
