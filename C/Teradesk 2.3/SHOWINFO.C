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
#include <vdi.h>
#include <stdlib.h>
#include <string.h>
#include <library.h>
#include <mint.h>
#include <xdialog.h>

#include "desk.h"
#include "error.h"
#include "resource.h"
#include "showinfo.h"
#include "xfilesys.h"
#include "icon.h"
#include "file.h"
#include "window.h"

/* DjV 022 120103 170103 ---vvv--- */
XDINFO dinfo; 	
int dopen;    	/* flag that dialog is open */ 
int oldtype;	/* previous item type       */

/* 
 * Openinfo either opens or redraws a dialog.
 * now, closeinfo must come after si_drive, folder_info and file_info 
 * because those routines do not close the dialog after each item anymore
 */

void closeinfo(void)
{
	if ( dopen )
	{
		xd_close (&dinfo);
		dopen = FALSE;
	}
}

void openinfo
( 
	OBJECT *tree /* pointer to drive/file/folder dialog to be opened */ 
)
{
	graf_mouse( ARROW, NULL );
	if ( !dopen )
	{
		xd_open( tree, &dinfo );
		dopen = TRUE;
	}
	else
		xd_draw ( &dinfo, ROOT, MAX_DEPTH );
}

/* DjV 022 120103 170103 ---^^^--- */

/* DjV 017 190103 ---vvv--- */
/*
 * trim path to be displayed in order to remove 
 * item name, so that more of the path can fit into field;
 * does not trim if it is only disk drive name.
 */
/* there is already a similar routine but it doesn't do quite the same */

void path_to_disp ( char *fpath )
{
	char *nend;
		
	nend = strrchr ( fpath, '\\' );
	if ( nend != NULL )
	{
		if ( *(nend -1L) == ':' ) nend++;
		*nend = 0;
	}
}
/* DjV 017 190103 ---^^^--- */

static void cv_ttoform(char *tstr, unsigned int time)
{
	unsigned int sec, min, hour, h;

	sec = (time & 0x1F) * 2;
	h = time >> 5;
	min = h & 0x3F;
	hour = (h >> 6) & 0x1F;
	digit(tstr, hour);
	digit(tstr + 2, min);
	digit(tstr + 4, sec);
}

static void cv_dtoform(char *tstr, unsigned int date)
{
	unsigned int day, mon, year, h;

	day = date & 0x1F;
	h = date >> 5;
	mon = h & 0xF;
	year = ((h >> 4) & 0x7F) + 80;
	digit(tstr, day);
	digit(tstr + 2, mon);
	digit(tstr + 4, year);
}

static int si_error(const char *name, int error)
{
	return xhndl_error(MESHOWIF, error, name);
}

#pragma warn -par
int si_drive(const char *path, int *x, int *y) /* DjV 006 010103 */
{
	SNAME dskl;				/* HR 240203 */
	long nfolders, nfiles, bytes;
	int drive, error = 0, result = 0;
	DISKINFO diskinfo;

	if (check_drive(path[0] - 'A') != FALSE)
	{
		drive = path[0];

		driveinfo[DIDRIVE].ob_spec.obspec.character = drive;

		graf_mouse(HOURGLASS, NULL);

		if ((error = cnt_items(path, &nfolders, &nfiles, &bytes, 0x11 | options.attribs, FALSE, NULL)) == 0) /* DjV 017 150103 */
			if ((error = x_getlabel(drive - 'A', dskl)) == 0)
				x_dfree(&diskinfo, drive - 'A' + 1);

		graf_mouse(ARROW, NULL);

		if (error == 0)
		{
			long clsize  = diskinfo.b_secsiz * diskinfo.b_clsiz;

			cv_fntoform(driveinfo + DILABEL, dskl);		/* HR 240103 */
			rsc_ltoftext(driveinfo, DIFOLDER, nfolders);
			rsc_ltoftext(driveinfo, DIFILES, nfiles);
			rsc_ltoftext(driveinfo, DIBYTES, bytes);
			rsc_ltoftext(driveinfo, DIFREE, diskinfo.b_free * clsize);
			rsc_ltoftext(driveinfo, DISPACE, diskinfo.b_total * clsize);
			/* DjV 022 120103 ---vvv--- */
			openinfo ( driveinfo );
			if( xd_form_do( &dinfo, ROOT ) == DIABORT )
			{
				xd_change( &dinfo, DIABORT, NORMAL, TRUE ); 
				result = XABORT;
			}
			else
				xd_change( &dinfo, DIOK, NORMAL, TRUE ); 
			/* DjV 022 120103 ---^^^--- */
		}
		else
			result = si_error(path, error);
	}

	return result;
}

#pragma warn .par

static int frename(const char *oldname, const char *newname)
{
	int error;

	graf_mouse(HOURGLASS, NULL);
	error = x_rename(oldname, newname);
	graf_mouse(ARROW, NULL);

	if (error == 0)
		wd_set_update(WD_UPD_MOVED, oldname, newname);

	return error;
}

int folder_info(const char *oldname, const char *fname, XATTR *attr)	/* DjV 017 150103 global function */
{
	char *name, *time, *date;
	char nfname[256], *newname;
	long nfolders, nfiles, bytes;
	int error, /* start, */ button, result = 0;

	name = xd_get_obspec(folderinfo + FINAME).tedinfo->te_ptext;	/* HR 021202 */
	time = folderinfo[FITIME].ob_spec.tedinfo->te_ptext;
	date = folderinfo[FIDATE].ob_spec.tedinfo->te_ptext;

	graf_mouse(HOURGLASS, NULL);
	error = cnt_items(oldname, &nfolders, &nfiles, &bytes, 0x11 | options.attribs, FALSE, NULL); /* DjV 017 150103 */
	graf_mouse(ARROW, NULL);

	if (error == 0)
	{
		/* DjV 021 120103
		 * trim path to be displayed in order to remove 
		 * item name, so that more of the path can fit into field;
		 * does not trim if it is only disk drive name.
		 */
		strcpy ( nfname, oldname ); /* conveninent to use nfname */
		path_to_disp ( nfname );
		cv_fntoform(folderinfo + FIPATH, nfname);			/* HR 240103 */
		cv_fntoform(folderinfo + FINAME, fname);			/* HR 240103 */

		cv_ttoform(time, attr->mtime);
		cv_dtoform(date, attr->mdate);
		rsc_ltoftext(folderinfo, FIFOLDER, nfolders);
		rsc_ltoftext(folderinfo, FIFILES, nfiles);
		rsc_ltoftext(folderinfo, FIBYTES, bytes);
		if (tos1_4())
		{
/*			start = FINAME;
*/			folderinfo[FINAME].ob_flags |= EDITABLE;
		}
		else
		{
/*			start = 0;
*/			folderinfo[FINAME].ob_flags &= ~EDITABLE;
		}

		/* DjV 022 120103 ---vvv--- */
		/* 
		 * Will there be a problem in TOS < 1.4 (can't test, don't have)
		 * because "start" is not used anymore?
		 */
		/* button = si_dialog(folderinfo, start, x, y); */
		openinfo ( folderinfo );
		button = xd_form_do( &dinfo, ROOT );
		/* DjV 022 120103 ---^^^--- */

		if (button == FIOK)
		{
			xd_change( &dinfo, FIOK, NORMAL, TRUE ); /* DjV 022 120103 */

			cv_formtofn(nfname, name);

			if (strcmp(nfname, fname) != 0)
			{
				if ((newname = fn_make_newname(oldname, nfname)) != NULL)
				{
					if ((error = frename(oldname, newname)) != 0)
						result = si_error(fname, error);
					free(newname);
				}
			}
		}
		else if (button == FIABORT)
		{												/* DjV 022 120103 */
			xd_change( &dinfo, FIABORT, NORMAL, TRUE ); /* DjV 022 120103 */
			result = XABORT;
		}												/* DjV 022 120103 */
		else if ( button == FISKIP )					/* DjV 022 120103 */
		{												/* DjV 017 190103 */
			xd_change( &dinfo, FISKIP, NORMAL, TRUE );	/* DjV 022 120103 */
			result = XSKIP;								/* DjV 017 190103 */
		}												/* DjV 017 190103 */
	}
	else
		result = si_error(fname, error);

	return result;
}

static void set_file_attribs(int attribs)		/* HR 151102: preserve extended bits */
{
	/* DjV 014 030103 */
	set_opt( fileinfo, attribs, FA_READONLY, ISWP );
	set_opt( fileinfo, attribs, FA_HIDDEN, ISHIDDEN );
	set_opt( fileinfo, attribs, FA_SYSTEM, ISSYSTEM );
}

static int get_file_attribs(int old_attribs)
{
	int attribs = (old_attribs & 0xFFF8);

	/* DjV 014 030103 */
	get_opt ( fileinfo, &attribs, FA_READONLY, ISWP );
	get_opt ( fileinfo, &attribs, FA_HIDDEN, ISHIDDEN );
	get_opt ( fileinfo, &attribs, FA_SYSTEM, ISSYSTEM );

	return attribs;
}

static int fattrib(const char *name, int attribs)
{
	int error;

	graf_mouse(HOURGLASS, NULL);
	error = x_fattrib(name, 1, attribs);
	graf_mouse(ARROW, NULL);

	return (error >= 0) ? 0 : error;
}

int file_info(const char *oldname, const char *fname, XATTR *attr)	/* DjV 017 160103 global function */
{
	char *name, *time, *date, nfname[256], *newname;
	int button, attrib = attr->attr, result = 0;

	name = xd_get_obspec(fileinfo + FLNAME).tedinfo->te_ptext;
	time = fileinfo[FLTIME].ob_spec.tedinfo->te_ptext;
	date = fileinfo[FLDATE].ob_spec.tedinfo->te_ptext;

	/* DjV 021 150103 ---vvv--- */
	strcpy ( nfname, oldname );
	path_to_disp ( nfname );
	/* DjV 021 120103 ---^^^--- */

	cv_fntoform(fileinfo + FLPATH, nfname);			/* HR 240103 */
	cv_fntoform(fileinfo + FLNAME, fname);			/* HR 240103 */

	cv_ttoform(time, attr->mtime);
	cv_dtoform(date, attr->mdate);
	rsc_ltoftext(fileinfo, FLBYTES, attr->size);
#if _MINT_				/* HR 151102 */
	if (!mint)
#endif
		set_file_attribs(attrib);

	/* DjV 022 120103 ---vvv--- */

	/* button = si_dialog(fileinfo, FLNAME, x, y); */
	openinfo ( fileinfo );
	button = xd_form_do( &dinfo, ROOT );

	/* DjV 022 120103 ---^^^--- */

	if (button == FLOK)
	{
		int error = 0, new_attribs;

		xd_change( &dinfo, FLOK, NORMAL, TRUE );

#if _MINT_				/* HR 151102 */
		if (mint)
			new_attribs = attrib;
		else
#endif
			new_attribs = get_file_attribs(attrib);

		cv_formtofn(nfname, name);

		if ((newname = fn_make_newname(oldname, nfname)) != NULL)
		{
#if _MINT_				/* HR 151102 */
			if (!mint)
#endif
			{
				if (((new_attribs & FA_READONLY) == 0) && (new_attribs != attrib))
					error = fattrib(oldname, new_attribs);
			}

			if ((strcmp(nfname, fname) != 0) && (error == 0))
				error = frename(oldname, newname);

#if _MINT_				/* HR 151102 */
			if (!mint)
#endif
			{
				if (((new_attribs & FA_READONLY) != 0) && (error == 0) && (new_attribs != attrib))
					error = fattrib(newname, new_attribs);
			}

			if (error != 0)
				result = si_error(fname, error);

			if (result != XFATAL)
			{
				if ((new_attribs != attrib) && (strcmp(nfname, fname) == 0))
					wd_set_update(WD_UPD_COPIED, oldname, NULL);
			}

			free(newname);
		}
	}
	else if (button == FLABORT)
	{												/* DJV 022 120103 */
		xd_change( &dinfo, FLABORT, NORMAL, TRUE ); /* DjV 022 120103 */
		result = XABORT;
	} 												/* DjV 022 120103 */
	else if (button == FLSKIP )						/* DjV 022 120103 */
	{												/* DjV 017 190103 */
		xd_change( &dinfo, FLSKIP, NORMAL, TRUE ); 	/* DjV 022 120103 */
		result = XSKIP;								/* DjV 017 190103 */
	}												/* DjV 017 190103 */

	return result;
}

void item_showinfo(WINDOW *w, int n, int *list, int search )  /* DjV 017 150103 */
{
	int i, item, error, x, y, oldmode, result = 0;
	ITMTYPE type;
	boolean curr_pos;
	XATTR attrib;
	const char *path, *name;

	long nd, nf, nb; /* DjV 017 150103 */
	LNAME pattern; /* DjV 017 170103 */ /* HR 240203 */
	int button; /* DjV 017 170103 */

	x = -1;
	y = -1;
	curr_pos = FALSE;


	/* DjV 020 150103 ---vvv--- */

	if ( search )
	{

		/* open a dialog to input search pattern */

		rsc_title(newfolder, NDTITLE, FOFINAME );
		*dirname = 0;
		button = xd_dialog(newfolder, DIRNAME);

		if ((button == NEWDIROK) && (strlen(dirname) != 0))
			cv_formtofn(pattern, dirname);
		else
			return;
	}
	/* DjV 020 150103 ---^^^--- */

	oldtype = itm_type(w, list[0]); /* DjV 022 120103 */
	dopen = FALSE; 					/* DJV 022 120103 */

	for (i = 0; i < n; i++)
	{
		item = list[i];

		if ((x >= 0) && (y >= 0))
		{
			oldmode = xd_setposmode(XD_CURRPOS);
			curr_pos = TRUE;
		}

		type = itm_type(w, item);

		/* DJV 022 120103 ---vvv--- */
		if ( (type != oldtype) && dopen )
		{
			closeinfo();
			oldtype = type;
		}
		/* DJV 022 120103 ---^^^--- */

		if ((type == ITM_FOLDER) || (type == ITM_FILE) || (type == ITM_PROGRAM) || (type == ITM_DRIVE))
		{
			if ((path = itm_fullname(w, item)) == NULL)
				result = XFATAL;
			else
			{
				/* DJV 017 150103 290103 ---vvv--- */
				if ( search ) 
				{
					if ( (nd = cnt_items ( path, &nd, &nf, &nb, 0x1 | options.attribs, TRUE, pattern ) ) != XSKIP )
						break;
				}
				else
				{
					/* DjV 017 150103 ---^^^--- */

					if (type == ITM_DRIVE)
						result = si_drive(path, &x, &y);
					else
					{
						name = itm_name(w, item);

						graf_mouse(HOURGLASS, NULL);
						error = itm_attrib(w, item, 0, &attrib);
						graf_mouse(ARROW, NULL);

						if (error != 0)
							result = si_error(name, error);
						else
						{
							if (type == ITM_FOLDER)
								result = folder_info(path, name, &attrib /* , &x, &y */);
							else
								result = file_info(path, name, &attrib /* , &x, &y */);
						}
					}
				}
				free(path);
			}
		}

		if (curr_pos == TRUE)
			xd_setposmode(oldmode);

		if ((result == XFATAL) || (result == XABORT))
			break;
	}

	if ( dopen )		/* DjV 022 120103 */
		closeinfo();

	wd_do_update();
	graf_mouse ( ARROW, NULL ); /* DjV 017 190103 */
}
