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
#include <time.h>
#include <tos.h>
#include <vdi.h>
#include <xdialog.h>
#include <xscncode.h>
#include <mint.h>

#include "desk.h"
#include "resource.h"
#include "printer.h"
#include "error.h"
#include "xfilesys.h"
#include "window.h"
#include "file.h"
#include "dir.h"			/* DjV 031 070203 */
#include "events.h"
#include "copy.h" /* DjV 031 070203 */

#define PBUFSIZ	1024L

/* DjV 031 150203 ---vvv--- */
/* 
 * Printer line length; directory line longer than this is wrapped;
 * sometime plinelen may be made settable 
 */
int plinelen = 80; 	/* decent values are between 64 and 132 */
XATTR pattr;		/* item attributes */

/* DjV 031 150203 ---^^^--- */

static boolean prtchar(char ch)
{
	long time;
	boolean ready = FALSE, result;
	int button;

	do
	{
		time = clock() + 1000;
		while ((clock() < time) && (Cprnos() == 0));
		if (Cprnos() != 0)
		{
			Cprnout(ch);
			result = FALSE;
			ready = TRUE;
		}
		else
		{
			button = alert_printf(2, MPRNRESP);
			result = TRUE;
			ready = (button == 2) ? TRUE : FALSE;
		}
	}
	while (ready == FALSE);

	return result;
}

/* DjV 013 150203 ---vvv--- */
/* 
 * print_eol() prints CR LF for end of line;
 * same as prtchar above, it returns FALSE when OK!
 */

static boolean print_eol(void)
{
	boolean status = FALSE;
	if ( ( status = prtchar( (char)13 )	) == FALSE )	/* CR */
		status = prtchar( (char)10 );					/* LF */
	return status;
}

/* 
 * print_line prints a cr-lf terminated line for directory print 
 * If the line is longer than plinelen it is wrapped to the next printer line.
 * Function returns FALSE if ok, in line with other print functions
 */

static boolean print_line 
( 
	char *dline 	/* 0-terminated line to print */
)
{
	char *p;					/* address of position in dline string */
	int i;						/* position in printer line */
	boolean status = FALSE;		/* prtchar print status */

	p = dline;
	i = 0;
	while ( !status && (*p != 0) )
	{
		status = prtchar(*p); 		/* beware: prtchar is false when OK ! */
		p++;
		i++;
		if ( !status && ((*p == 0) || (i >= plinelen)) ) /* end of line or line too long */
		{
			i = 0;					/* reset linelength counter */
			status = print_eol();	/* print cr lf */
		}	/* if...    */ 
	} 		/* while... */

	return status;					/* this one is FALSE if ok, too! */
}
/* DjV 013 150203 ---^^^--- */

static int print_file(WINDOW *w, int item)
{
	/* int handle, error = 0, i, key, result = 0, r; DjV 033 010203 */
	int handle, error = 0, i, result = 0; /* DjV 033 010203 */
	char *buffer;
	const char *name;
	long l;			/* index in buffer[] */
	int ll = 0;		/* DjV 031 150203 line length counter */
	boolean stop = FALSE;

	if ((name = itm_fullname(w, item)) == NULL)
		return XFATAL;

	buffer = x_alloc(PBUFSIZ);

	if (buffer != NULL)
	{
		graf_mouse(HOURGLASS, NULL);

		if ((handle = x_open(name, O_DENYW | O_RDONLY)) >= 0)
		{
			do
			{
				if ((l = x_read(handle, PBUFSIZ, buffer)) >= 0)
				{
					for (i = 0; i < (int) l; i++)
					{
						/* DjV 031 150203 ---vvv--- */
						/* 
						 * line wrap & new line handling;
						 */
						ll++;
						if ( (buffer[i] == (char)13) || (buffer[i] == (char)10) || (buffer[i] == (char)12) )
							ll = 0; /* reset linelength counter at CR, LF or FF */
						else if ( ll >= plinelen )
						{
							ll = 0;
							if (( stop = print_eol() ) == TRUE)
								break;
						}
						/* DjV 031 150203 ---^^^--- */

						if ((stop = prtchar(buffer[i])) == TRUE)
							break;
					}
					/* DjV 033 010203 ---vvv--- */
					/*
					if ((r = key_state(&key, TRUE)) > 0)
					{
						if (key == ESCAPE)
							stop = TRUE;
					}
					else if (r < 0)
						stop = TRUE;
					*/

					if ( escape_abort(TRUE) )
						stop = TRUE;

					/* DjV 033 010203 ---^^^--- */
				}
				else
					error = (int) l;
			}
			while ((l == PBUFSIZ) && (stop == FALSE));

			x_close(handle);
			print_eol(); /* DjV 031 150203 print cr lf at end of file */
		}
		else
			error = handle;

		if (stop == TRUE)
			result = XABORT;

		if (error != 0)
			result = xhndl_error(MEPRINT, error, itm_name(w, item));

		graf_mouse(ARROW, NULL);
		x_free(buffer);
	}
	else
	{
		xform_error(ENSMEM);
		result = XFATAL;
	}

	free(name);

	return result;
}

static boolean check_print(WINDOW *w, int n, int *list)
{
	int i;
	boolean noerror;
	char *mes = "";

	for (i = 0; i < n; i++)
	{
		noerror = FALSE;

		switch (itm_type(w, list[i]))
		{
		case ITM_PRINTER:
			rsrc_gaddr(R_STRING, MPRINTER, &mes);
			break;
		case ITM_TRASH:
			rsrc_gaddr(R_STRING, MTRASHCN, &mes);
			break;
		case ITM_DRIVE:
			rsrc_gaddr(R_STRING, MDRIVE, &mes);
			break;
		case ITM_FOLDER:
			rsrc_gaddr(R_STRING, MFOLDER, &mes);
			break;
		case ITM_PROGRAM:
			rsrc_gaddr(R_STRING, MPROGRAM, &mes);
			break;
		case ITM_FILE:
			noerror = TRUE;
			break;
		}
		if (noerror == FALSE)
			break;
	}
	if (noerror == FALSE)
		alert_printf(1, MNOPRINT, mes);

	return noerror;
}

boolean prt_file(WINDOW *w, int item)
{
	return (print_file(w, item) == 0) ? TRUE : FALSE;
}

boolean item_print(WINDOW *wd, int n, int *list)
{
	int i = 0, button, result = 0;
	boolean noerror = TRUE;

	/* DjV 031 070203 ---vvv--- */
	/* XDINFO info; */
	long nfiles=0, nfolders=0, nbytes=0, error;
	const char *name;
	/* DjV 031 070203 ---^^^--- */

	if (check_print(wd, n, list) == FALSE)
		return FALSE;

	/* DjV 031 080203 ---vvv--- */

	/* rsc_ltoftext(print, NITEMS, n); */

	/* xd_open(print, &info); */
	if ( count_items(wd, n, list, &nfolders, &nfiles, &nbytes) )	/* HR 151102: always display. */
	{	/* DjV 031 140203 */

		cv_fntoform ( copyinfo + CPFOLDER, fn_get_name(dir_path(wd)) );	  	/* DjV 031 140203 */
		cv_fntoform ( copyinfo + CPFILE, itm_name(wd, list[0]) ); 			/* DjV 031 140203 */

		button = open_cfdialog( CF_PRINT, 0L, (long)n, nbytes, CMD_PRINT ); /* DJV 031 070203 */
	} /* DjV 031 140203 */
	else
		button = 0;

	/* if (button == PRINTOK) */ 
	if ( button == COPYOK ) 
	/* DjV 031 080203 ---^^^--- */
	{
		if ((i < n) && (result != XFATAL) && (result != XABORT))
		{
			/* DjV 031 080203 ---vvv--- */
			name = itm_name(wd, list[i]);
			upd_name( dir_path(wd), CPFOLDER );	
			upd_name ( name, CPFILE ); 
			/* DjV 031 080203 ---^^^--- */

			result = print_file(wd, list[i]);

			if (result == XFATAL)
				noerror = FALSE;

			/* DJV 031 070203 150203 ---vvv--- */
			/* 
			rsc_ltoftext(print, NITEMS, n - i - 1);
			xd_draw(&info, NITEMS, 1);
			*/
			if ((error = itm_attrib(wd, list[i], 0, &pattr)) == 0)
			{
				nbytes -= pattr.size;
				upd_copyinfo ( 0L, n - i - 1, nbytes ); 
			}
			else
				result = copy_error(error, name, 0); /* 0= any op but move or delete is "copy" */
			/* DjV 031 070203 150203 ---^^^--- */

			i++;
		}
	}
	else
		noerror = FALSE;

	/* DjV 031 070203 ---vvv--- */
	/*
	xd_change(&info, button, NORMAL, 0);
	xd_close(&info);
	*/
	if ( button != 0 )
		close_cfdialog( button );
	/* DjV 031 070203 ---^^^--- */

	return noerror;
}

/* DjV 029 140203 ---vvv--- */

/* Routine dir_print prints directory of current window */

void dir_print
(
	WINDOW *wd, 	/* to window structure */
	int n, 			/* number of items */
	int *list		/* to item list */
)
{
	boolean 
		noerror = TRUE;	/* true while no error */

	char 
		dline[134];		/* sufficiently long string for directory line */

	long 
		nfiles = 0,		/* file count */
	 	nfolders = 0,	/* folder count */
		nbytes = 0;		/* bytes sum */

	int
		error,			/* error id; =0 if  no errors */ 
		i,				/* item counter */
		button,			/* pressed button id. */
		type;			/* item type (file, folder...) */ 
	

	/* Count files, folders and bytes in this directory only (don't recurse) */

	for ( i = 0; i < n; i++ )
	{
		type = itm_type(wd, list[i]);
		if ( type == ITM_FILE || type == ITM_PROGRAM )
		{
			if ( (error = itm_attrib( wd, list[i], 0 ,&pattr) ) == 0 )
			{
				nbytes += pattr.size;
				nfiles++;
			}
			else
				error = copy_error(error, itm_name(wd, list[i]), 0); /* 0= any op but move or delete */
		}
		else if ( type == ITM_FOLDER )
			nfolders++;

		if ( error != 0 )
		{
			noerror = FALSE;
			break;
		}
	}

	if ( noerror )
	{
		/* Open confirmation dialog */

		cv_fntoform ( copyinfo + CPFOLDER, dir_path(wd) );
		*cpfile = 0;
		button = open_cfdialog( CF_PRINT, nfolders, nfiles, nbytes, CMD_PRINTDIR ); 

		/* If confirmed, print indeed */

		if ( button == COPYOK ) 
		{
			strcpy ( dline, get_freestring(TDIROF) ); 		/* Get "Directory of " string */
			get_dir_line( wd, &dline[strlen(dline)], -1 );	/* Append window title */

			if ( (noerror = !print_line(dline) ) == TRUE )
				noerror = !print_eol();

			i = 0;
			while ( (i < n) && noerror )
			{
				get_dir_line( wd, dline, list[i] );
				if ( dline[1] == (char)7 )
					dline[1] = '\\';	/* Mark folders with "\" */
				noerror = !print_line(dline);
				if ( escape_abort( cfdial_open ) )
					noerror = FALSE;
				i++;
			}
	
			if ( noerror )
			{
 				get_dir_line ( wd, dline, -2 );						/* get directory info line */
				if ( (noerror = !print_eol()) == TRUE )				/* print blank line */
					if ( ( noerror = !print_line(dline) ) == TRUE )	/* print directory total */
						noerror = !print_eol();						/* print blank line */
			}	/* noerror */
		}		/* button  */
		else
			noerror = FALSE;

	} /* if noerror */

	if ( button != 0 )
		close_cfdialog(button);
}
