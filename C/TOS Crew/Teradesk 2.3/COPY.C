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
#include <xscncode.h>
#include <xdialog.h>

#include "desk.h"
#include "copy.h"
#include "error.h"
#include "events.h"
#include "printer.h"
#include "resource.h"
#include "xfilesys.h"
#include "file.h"
#include "window.h"
#include "applik.h"
#include "showinfo.h" 	/* DjV 017 150103 */
#include "dir.h" 		/* DjV 017 170103 */

/* DjV 031 070203 ---vvv--- */
/* moved to COPY.H
#define CMD_COPY	 0
#define CMD_MOVE	 1
#define CMD_DELETE	 2
*/
/* DjV 031 070203 ---^^^--- */

typedef struct copydata
{
	int result;
	XDIR *dir;
	char *spath;
	char *dpath;
	char *sname;
	char *dname;
	boolean chk;
	struct copydata *prev;
} COPYDATA;

static boolean /* DjV 031 070203 cfdial_open, */ set_oldpos, overwrite, rename_files;

boolean cfdial_open; /* DJV 031 070203 */

static XDINFO cfdial;

static int del_folder(const char *name, int function, int prev);

/********************************************************************
 *																	*
 * Routines voor de dialoogbox.										*
 *																	*
 ********************************************************************/

/* DjV 031 070203 static */
int open_cfdialog(int mask, long folders, long files,
						 long bytes, int function)
{
	int button, title;

/*	if ((options.cprefs & mask) != 0)			/* HR 151102: always display */
*/	{
		switch (function)
		{
		case CMD_COPY:
			title = (rename_files == TRUE) ? DTCOPYRN : DTCOPY;
			break;
		case CMD_MOVE:
			title = (rename_files == TRUE) ? DTMOVERN : DTMOVE;
			break;
		case CMD_DELETE:
			title = DTDELETE;
			break;
		/* DJV 031 070203 ---vvv--- */
		case CMD_PRINT:
			title = DTPRINT;
			break;
		case CMD_PRINTDIR: /* for future development */
			title = DTPRINTD;
			break;
		/* DjV 031 070203 ---^^^--- */
		}

		rsc_ltoftext(copyinfo, NFOLDERS, folders);
		rsc_ltoftext(copyinfo, NFILES, files);
		rsc_ltoftext(copyinfo, NBYTES, bytes);

		/* *cpfile = 0; 	DjV 029 140203 */
		/* *cpfolder = 0;	DjV 029 140203 */

		rsc_title(copyinfo, CPTITLE, title);

		xd_open(copyinfo, &cfdial);
		cfdial_open = TRUE;

		if ((options.cprefs & mask) != 0)			/* HR 151102: If confirm call xd_form_do */
			button = xd_form_do(&cfdial, 0);
		else
		{										  /* DJV 032 010203 */
			xd_draw ( &cfdial, ROOT, MAX_DEPTH ); /* DjV 032 010203 */
			button = COPYOK;
		}										  /* DjV 032 010203 */
	}
/*	else
	{
		button = COPYOK;
		cfdial_open = FALSE;
	}
*/
	set_oldpos = FALSE;

	return button;
}

/* DjV 031 070203 static */ void close_cfdialog(int button)
{
	if (cfdial_open == TRUE)
	{
		xd_change(&cfdial, button, NORMAL, 0);
		xd_close(&cfdial);
	}
}

void upd_copyinfo(long folders, long files, long bytes)	/* DjV 031 070203: global */
{
	if (cfdial_open == TRUE)
	{
		rsc_ltoftext(copyinfo, NFOLDERS, folders);
		rsc_ltoftext(copyinfo, NFILES, files);
		rsc_ltoftext(copyinfo, NBYTES, bytes);

		xd_draw(&cfdial, NFOLDERS, 1);
		xd_draw(&cfdial, NFILES, 1);
		xd_draw(&cfdial, NBYTES, 1);
	}
}

void upd_name(const char *name, int item)	/* DjV 031 070203: global */
{
	char *fname;	/* DjV 031 070203 */

	if (cfdial_open == TRUE)
	{
		fname = fn_get_name(name);
		cv_fntoform ( copyinfo + item, fname );		/* DjV 031 070203 */
		xd_draw(&cfdial, item, 1);
	}
}

/********************************************************************
 *																	*
 * Routines die de stack vervangen.									*
 *																	*
 ********************************************************************/

static int push(COPYDATA **stack, const char *spath, const char *dpath,
				boolean chk)
{
	COPYDATA *new;
	int error = 0;

	if ((new = malloc(sizeof(COPYDATA))) == NULL)
		error = ENSMEM;
	else
	{
		new->spath = (char *) spath;
		new->dpath = (char *) dpath;
		new->chk = chk;
		new->result = 0;
		if ((new->dir = x_opendir(spath, &error)) != NULL)
		{
			new->prev = *stack;
			*stack = new;
		}
		else
			free(new);
	}
	return error;
}

static boolean pull(COPYDATA **stack, int *result)
{
	COPYDATA *top = *stack;

	x_closedir(top->dir);
	*result = top->result;
	*stack = top->prev;
	free(top);

	return (*stack == NULL) ? TRUE : FALSE;
}

static int stk_readdir(COPYDATA *stack, char *name, XATTR *attr,
					   boolean *eod)
{
	int error;

	while (((error = (int) x_xreaddir(stack->dir, name, 256, attr)) == 0)
		   && ((strcmp("..", name) == 0) || (strcmp(".", name) == 0)));

	if ((error == ENMFIL) || (error == EFILNF))
	{
		error = 0;
		*eod = TRUE;
	}
	else
		*eod = FALSE;

	return error;
}

/********************************************************************
 *																	*
 * Routine voor het tellen van het aantal files en folders in een	*
 * directory.														*
 *																	*
 ********************************************************************/

int cnt_items(const char *path, long *folders, long *files, long *bytes, int attribs, int search, char *pattern)	/* DjV 017 150103 */
{
	COPYDATA *stack = NULL;
	boolean ready = FALSE, eod = FALSE;
	int error, dummy;
	char name[256];
	XATTR attr;

	int result = XSKIP; 				/* DjV 017 160103 */
	unsigned int type = 0, oldtype = 0; /* DjV 017 150103 item type */
	char *fpath;				 		/* DjV 017 160103 item path; 280103 removed "nend" */
	bool found;							/* DjV 017 170103 match found */

	*folders = 0;
	*files = 0;
	*bytes = 0;
	fpath = NULL;
	found = FALSE;

	if ((error = push(&stack, path, NULL, FALSE)) != 0)
		return error;

	do
	{
		if ( search )						/* DjV 017 190103 */
			graf_mouse(HOURGLASS, NULL );	/* DjV 017 190103 */

		if (error == 0)
		{
			if (((error = stk_readdir(stack, name, &attr, &eod)) == 0) && (eod == FALSE))
			{
				/* DjV 017 160103 ---vvv--- */
				/*
				 * code below closes prev. dialog if prev. displayed item
				 * was a file and next is a folder- or v.v.
				 */
				type = attr.mode & S_IFMT;
				if ( search )
				{
					if ( (found = cmp_wildcard ( name, pattern )) != 0 ) 
						fpath = x_makepath(stack->spath, name, &error);

					if ( found && (type != oldtype) && (type == S_IFDIR || type == S_IFREG) )
					{
						closeinfo();
						oldtype = type;
					}
				}
				else
					found = FALSE;
				/* DjV 017 160103 ---^^^--- */

				/* if ((attr.mode & S_IFMT) == S_IFDIR)    DjV 017 280103 */
				if (type == S_IFDIR) 					/* DjV 017 280103 */
				{
					if ( (attribs & FA_SUBDIR) != 0 ) /* DjV 017 290103 */
						*folders += 1;
					if ((stack->sname = x_makepath(stack->spath, name, &error)) != NULL)
					{ 		/* DjV 017 160103 */

						if ((error = push(&stack, stack->sname, NULL, FALSE)) != 0)
							free(stack->sname);

						/* DjV 017 150103 190103 280103 ---vvv--- */
						/* BEWARE of recursion below; folder_info contains cnt_items  */
						else if ( search && found && ( (attribs & FA_SUBDIR) != 0 ) )
							if ( (result = folder_info( fpath, name, &attr )) != 0)
								free(fpath);
						/* DjV 017 150103 190103 280103 ---^^^--- */
					} 	/* DjV 017 160103 */
				}
				/* if ((attr.mode & S_IFMT) == S_IFREG) DjV 017 280103 */
				if (type == S_IFREG)			/*  DjV 017 280103 */
				{
					/* DjV 017 160103 ---vvv--- */
					/*
					 * below: show hidden or file is not hidden, or
					 * show system or file is not system
					 */

					if (   (   (attribs   & FA_HIDDEN) != 0
					        || (attr.attr & FA_HIDDEN) == 0
					       )
					    && (   (attribs   & FA_SYSTEM) != 0
						    || (attr.attr & FA_SYSTEM) == 0
						   )
					   )
					/* DjV 017 160103 ---^^^--- */
					{
						*files += 1;
						*bytes += attr.size;

						/* DjV 017 150103  190103 280103 ---vvv--- */
						/* BEWARE of recursion below; file_info contains cnt_items  */
						if ( search && found )	
							if ( (result = file_info(fpath, name, &attr ) ) != 0 )
								free(path); 
						/* DjV 017 150103  190103 280103 ---^^^--- */		

					}
				}
				/* DjV 017 280103 removed some of my own code here */
			}
		}

		if ((eod == TRUE) || (error != 0))
		{
			if ((ready = pull(&stack, &dummy)) == FALSE)
				free(stack->sname);
		}
		/* DjV 017 170103 ---vvv--- */
		/*
		 * result will be 0 only if selected OK in dialogs 
		 */ 
		if ( search && (result != XSKIP) )
		{
			closeinfo();
			if ( fpath != NULL && result == 0 )
			{
	
				/* DjV 017 280103 removed some commented-out code (my own) */

				path_to_disp ( fpath );
				menu_ienable(menu, MSEARCH, 0); /* DjV 017 280103 */
				wd_deselect_all(); 				/* DjV 017 280103 */
				dir_add_window ( fpath, name  ); /* DjV 017 280103 */
			}

			return result; 
		}
		/* DjV 017 170103 ---^^^--- */
	}
	while (ready == FALSE);

	if ( search && !error )		/* DjV 017 190103 */
		return XSKIP;			/* DjV 017 190103 */
	else						/* DjV 017 190103 */
		return error;
}

static int dir_error(int error, const char *file)
{
	return xhndl_error(MEREADDR, error, file);
}

/* static DjV 031 080203 */
boolean count_items(WINDOW *w, int n, int *list, long *folders,
						   long *files, long *bytes)
{
	int i = 0, error = 0, item;
	ITMTYPE type;
	const char *path;
	long dfolders, dfiles, length;
	boolean ok = TRUE;
	XATTR attr;

	*folders = 0;
	*files = 0;
	*bytes = 0;

	graf_mouse(HOURGLASS, NULL);

	while ((i < n) && (ok == TRUE))
	{
		item = list[i];
		type = itm_type(w, item);
		error = 0;

		if ((type == ITM_FILE) || (type == ITM_PROGRAM))
		{
			if ((error = itm_attrib(w, item, 0, &attr)) == 0)
			{
				*files += 1;
				*bytes += attr.size;
			}
			else
				list[i] = -1;
		}
		else
		{
			if ((path = itm_fullname(w, item)) != NULL)
			{
				if ((error = cnt_items(path, &dfolders, &dfiles, &length, 0x37, FALSE, NULL)) == 0) /* DjV 017 150103 */
				{
					*folders += dfolders + ((type == ITM_DRIVE) ? 0 : 1);
					*files += dfiles;
					*bytes += length;
				}
				else
					list[i] = -1;
				free(path);
			}
			else
				ok = FALSE;
		}

		if (error != 0)
		{
			if (dir_error(error, itm_name(w, item)) != XERROR)
				ok = FALSE;
		}
		i++;
	}

	graf_mouse(ARROW, NULL);

	if ((*files == 0) && (*folders == 0))
		ok = FALSE;

	return ok;
}

/********************************************************************
 *																	*
 * Kopieer routine voor een file.									*
 *																	*
 ********************************************************************/

static int filecopy(const char *sname, const char *dname,
					int src_attrib, DOSTIME *time)
{
	int fh1, fh2, error = 0;
	long slength, dlength, size, mbsize;
	void *buffer;

	mbsize = (long) options.bufsize * 1024L;

	if ((size = (long) x_alloc(-1L) - 8192L) > mbsize)
		size = mbsize;

	if ((size >= 1024L) && (buffer = x_alloc(size)) != NULL)
	{
		fh1 = x_open(sname, O_DENYW | O_RDONLY);
		if (fh1 < 0)
			error = fh1;
		else
		{
			slength = x_read(fh1, size, buffer);
			if (slength < 0)
				error = (int) slength;
			else
			{
				fh2 = x_create(dname, src_attrib);
				if (fh2 < 0)
					error = fh2;
				else
				{
					dlength = x_write(fh2, slength, buffer);

					if ((dlength < 0) || (slength != dlength))
						error = (dlength < 0) ? (int) dlength : EDSKFULL;

					while ((slength == size) && (error == 0))
					{
						if ((slength = x_read(fh1, size, buffer)) > 0)
						{
							dlength = x_write(fh2, slength, buffer);
							if ((dlength < 0) || (slength != dlength))
								error = (dlength < 0) ? (int) dlength : EDSKFULL;
						}
						else if (slength < 0)
							error = (int) slength;
					}

					if (error == 0)
						x_datime(time, fh2, 1);

					x_close(fh2);

					if (error != 0)
						x_unlink(dname);
				}
			}
			x_close(fh1);
		}
		x_free(buffer);
	}
	else
		error = ENSMEM;

	return error;
}

/********************************************************************
 *																	*
 * Routine voor het afhandelen van fouten.							*
 *																	*
 ********************************************************************/

/* static DjV 031 080203 */
int copy_error(int error, const char *name, int function)
{
	int msg;

	if (function == CMD_DELETE)
		msg = MEDELETE;
	else
	{
		if (function == CMD_MOVE)
			msg = MEMOVE;
		else
			msg = MECOPY;
	}

	return xhndl_error(msg, error, name);
}

/********************************************************************
 *																	*
 * Routine voor het controleren van het kopieren.					*
 *																	*
 ********************************************************************/

static boolean check_copy(WINDOW *w, int n, int *list, const char *dest)
{
	int i = 0, item;
	const char *path, *mes;
	long l;
	boolean result = TRUE;
	ITMTYPE type;

	while ((i < n) && (result == TRUE))
	{
		item = list[i];

		if ((((type = itm_type(w, item)) == ITM_FOLDER) || (type == ITM_DRIVE)) && (dest != NULL))
		{
			if ((path = itm_fullname(w, item)) == NULL)
				result = FALSE;
			else
			{
				l = strlen(path);
				if ((strncmp(path, dest, l) == 0) &&
					(((type != ITM_DRIVE) && ((dest[l] == '\\') || (dest[l] == 0))) ||
					 ((type == ITM_DRIVE) && (dest[l] != 0))))
				{
					alert_printf(1, MILLCOPY);
					result = FALSE;
				}
			}
		}
		else
		{
			switch (type)
			{
			case ITM_TRASH:
				rsrc_gaddr(R_STRING, MTRASHCN, &mes);
				break;
			case ITM_PRINTER:
				rsrc_gaddr(R_STRING, MPRINTER, &mes);
				break;
			default:
				mes = NULL;
				break;
			}

			if (mes != NULL)
			{
				alert_printf(1, MNOCOPY, mes);
				result = FALSE;
			}
		}
		i++;
	}
	return result;
}

/********************************************************************
 *																	*
 * Routine voor het afhandelen van een naamconflict.				*
 *																	*
 ********************************************************************/

static int _rename(char *old, int function)
{
	int error, result;
	char *new, *name, newname[256];

	cv_formtofn(newname, oldname);
	name = fn_get_name(old);

	if ((new = fn_make_newname(old, newname)) == NULL)
		return XFATAL;
	else
	{
		if ((error = x_rename(old, new)) == 0)
		{
			wd_set_update(WD_UPD_MOVED, old, new);
			result = 0;
		}
		else
		{
			if (error == EACCDN)
			{
				alert_printf(1, MERENAME, name);
				result = XERROR;
			}
			else
				result = copy_error(error, name, function);
		}
		free(new);
	}
	return result;
}

static int exist(const char *sname, int smode, const char *dname,
				 int *dmode, int function)
{
	int error;
	XATTR attr;

	if ((error = (int) x_attr(0, dname, &attr)) == 0)
	{
		*dmode = attr.mode & S_IFMT;

		if ((overwrite == TRUE) && strcmp(sname, dname) && (*dmode == smode))
			return XOVERWRITE;
		else
			return XEXIST;
	}
	else
		return (error == EFILNF) ? 0 : copy_error(error, fn_get_name(dname), function);
}

static int hndl_nameconflict(char **dname, int smode,
							 const char *sname, int function)
{
	boolean again, stop, first = TRUE;
	int button, result = 0, oldmode, dmode;
	XDINFO xdinfo;
	char dupl[256];

	smode &= S_IFMT;

	if ((result = exist(sname, smode, *dname, &dmode, function)) != XEXIST)
		return result;

	rsc_title(nameconflict, RNMTITLE, DTNMECNF);

	do
	{
		again = FALSE;

		if ((strcmp(sname, *dname) == 0) || ((dmode == S_IFDIR) && (tos1_4() == FALSE)))
			nameconflict[OLDNAME].ob_flags &= ~EDITABLE;
		else
			nameconflict[OLDNAME].ob_flags |= EDITABLE;

		cv_fntoform(nameconflict + OLDNAME, fn_get_name(*dname));	/* HR 240103 */
		strcpy(newname, oldname);
		strcpy(dupl, oldname);

		stop = FALSE;

		do
		{
			result = 0;

			graf_mouse(ARROW, NULL);

			if (first != FALSE)
			{
				if (set_oldpos == TRUE)
					oldmode = xd_setposmode(XD_CURRPOS);

				xd_open(nameconflict, &xdinfo);

				if (set_oldpos == TRUE)
					xd_setposmode(oldmode);

				first = FALSE;
			}
			else
				xd_draw(&xdinfo, ROOT, MAX_DEPTH);

			button = xd_form_do(&xdinfo, NEWNAME);
			xd_change(&xdinfo, button, NORMAL, 0);

			graf_mouse(HOURGLASS, NULL);

			if (button == NCOK)
			{
				if ((*newname == 0) || (*oldname == 0))
					alert_printf(1, MFNEMPTY);
				else
				{
					if (strcmp(dupl, oldname))
					{
						if ((result = _rename(*dname, function)) != XERROR)
						{
							stop = TRUE;
							if (result == 0)
								again = TRUE;
						}
					}
					else
						stop = TRUE;
				}
			}
			else
				stop = TRUE;
		}
		while (stop == FALSE);

		if (result == 0)
		{
			if ((button == NCOK) || (button == NCALL))
			{
				if ((button == NCOK) && strcmp(dupl, newname))
				{
					char *new, name[256];

					cv_formtofn(name, newname);
					if ((new = fn_make_newname(*dname, name)) == NULL)
					{
						result = copy_error(ENSMEM, fn_get_name(*dname), function);
						again = FALSE;
					}
					else
					{
						free(*dname);
						*dname = new;
						again = TRUE;
					}
				}

				if (button == NCALL)
					overwrite = TRUE;

				if (result == 0)
				{
					if (smode != dmode)
						again = TRUE;

					if (strcmp(sname, *dname) == 0)
					{
						alert_printf(1, MCOPYSLF);
						again = TRUE;
					}
					result = XOVERWRITE;
				}
			}
			else
				result = (button == NCABORT) ? XABORT : XSKIP;
		}
	}
	while ((again == TRUE) && ((result = exist(sname, smode, *dname, &dmode, function)) == XEXIST));

	xd_close(&xdinfo);
	set_oldpos = TRUE;

	return result;
}

static int hndl_rename(char *name)
{
	int button,oldmode;

	cv_fntoform(nameconflict + OLDNAME, name);		/* HR 240103 */
	cv_fntoform(nameconflict + NEWNAME, name);		/* HR 240103 */

	rsc_title(nameconflict, RNMTITLE, DTRENAME);

	nameconflict[OLDNAME].ob_flags &= ~EDITABLE;
	nameconflict[NCALL].ob_state |= DISABLED;

	graf_mouse(ARROW, NULL);

	if (set_oldpos == TRUE)
		oldmode = xd_setposmode(XD_CURRPOS);

	button = xd_dialog(nameconflict, NEWNAME);

	if (set_oldpos == TRUE)
		xd_setposmode(oldmode);

	set_oldpos = TRUE;

	graf_mouse(HOURGLASS, NULL);

	nameconflict[NCALL].ob_state &= ~DISABLED;

	if (button == NCOK)
	{
		cv_formtofn(name, newname);
		return 0;
	}
	else
	{
		if (button == NCABORT)
			return XABORT;
		else
			return XSKIP;
	}
}

/********************************************************************
 *																	*
 * Routines voor het kopieren van files.							*
 *																	*
 ********************************************************************/

static int copy_file(const char *sname, const char *dpath, XATTR *attr,
					 int function, int prev, boolean chk)
{
	char *dname, name[256];
	int error, result;
	DOSTIME time;

	strcpy(name, fn_get_name(sname));

	if ((rename_files == TRUE) && ((result = hndl_rename(name)) != 0))
		return (result == XSKIP) ? 0 : result;

	if ((error = x_checkname(dpath, name)) == 0)
	{
		if ((dname = x_makepath(dpath, name, &error)) != NULL)
		{
			result = (chk) ? hndl_nameconflict(&dname, attr->mode, sname, function) : 0;

			if ((result == 0) || (result == XOVERWRITE))
			{
				if ((function == CMD_MOVE) && (sname[0] == dname[0]))
				{
					if ((error = (result == XOVERWRITE) ? x_unlink(dname) : 0) == 0)
						error = x_rename(sname, dname);
				}
				else
				{
					time.time = attr->mtime;
					time.date = attr->mdate;

					error = filecopy(sname, dname, attr->attr, &time);

					if ((function == CMD_MOVE) && (error == 0))
					{
						if ((error = x_unlink(sname)) != 0)
							wd_set_update(WD_UPD_COPIED, dname, NULL);
					}
				}

				if (error == 0)
				{
					if (function == CMD_MOVE)
						wd_set_update(WD_UPD_MOVED, sname, dname);
					else
						wd_set_update(WD_UPD_COPIED, dname, NULL);
					result = 0;
				}
				else
					result = copy_error(error, name, function);
			}
			else if (result == XSKIP)
				result = 0;

			free(dname);
		}
		else
			result = copy_error(error, name, function);
	}
	else
		result = copy_error(error, name, function);

	return ((result != 0) ? result : prev);
}

static int create_folder(const char *sname, const char *dpath,
						 char **dname, XATTR *attr, long *folders,
						 long *files, long *bytes, int function,
						 boolean *chk)
{
	int error, result;
	long nfiles, nfolders, nbytes;
	char name[256];

	strcpy(name, fn_get_name(sname));

	if ((rename_files == TRUE) && ((result = hndl_rename(name)) != 0))
		return result;

	if ((error = x_checkname(dpath, name)) == 0)
	{
		if ((*dname = x_makepath(dpath, name, &error)) != NULL)
		{
			result = (chk) ? hndl_nameconflict(dname, attr->mode, sname, function) : 0;

			if (result == 0)
			{
				if ((error = x_mkdir(*dname)) != 0)
				{
					free(*dname);
					result = copy_error(error, name, function);
				}
				else
					*chk = FALSE;
			}
			else
			{
				if (result == XOVERWRITE)
					result = 0;
				else
				{
					if (result == XSKIP)
					{
						if ((error = cnt_items(sname, &nfolders, &nfiles, &nbytes, 0x37, FALSE, NULL)) == 0) /* DjV 017 150103 */
						{
							*files -= nfiles;
							*folders -= nfolders;
							*bytes -= nbytes;
						}
						else
							result = copy_error(error, name, function);
					}
					free(*dname);
				}
			}
		}
		else
			result = copy_error(error, name, function);
	}
	else
		result = copy_error(error, name, function);

	return result;
}

static int copy_path(const char *spath, const char *dpath,
					 const char *fname, long *folders, long *files,
					 long *bytes, int function, boolean chk)
{
	COPYDATA *stack = NULL;
	boolean ready = FALSE, eod = FALSE;
	int error, result /* , key DjV 031 070203 */;
	char name[256];
	XATTR attr;

	if ((error = push(&stack, spath, dpath, chk)) != 0)
		return copy_error(error, fname, function);

	do
	{
		if ((stack->result != XFATAL) && (stack->result != XABORT))
		{
			if (((error = stk_readdir(stack, name, &attr, &eod)) == 0) && (eod == FALSE))
			{
				if ((attr.mode & S_IFMT) == S_IFDIR)
				{
					int tmpres;
					boolean tmpchk = stack->chk;

					upd_name(name, CPFOLDER);

					if ((stack->sname = x_makepath(stack->spath, name, &error)) != NULL)
					{
						if ((tmpres = create_folder(stack->sname, stack->dpath, &stack->dname, &attr, folders, files, bytes, function, &tmpchk)) == 0)
						{
							if ((error = push(&stack, stack->sname, stack->dname, tmpchk)) != 0)
							{
								wd_set_update(WD_UPD_COPIED, stack->dname, NULL);
								free(stack->sname);
								free(stack->dname);
								tmpres = copy_error(error, name, function);
							}
						}
						else
							free(stack->sname);
					}
					else
						tmpres = copy_error(error, name, function);

					if (tmpres != 0)
					{
						*folders -= 1;
						stack->result = (tmpres == XSKIP) ? stack->result : tmpres;
						upd_name("", CPFOLDER);
					}
				}
				if ((attr.mode & S_IFMT) == S_IFREG)
				{
					upd_name(name, CPFILE);

					if ((stack->sname = x_makepath(stack->spath, name, &error)) != NULL)
					{
						stack->result = copy_file(stack->sname, stack->dpath, &attr, function, stack->result, stack->chk);
						free(stack->sname);
					}
					else
						stack->result = copy_error(error, name, function);
					*files -= 1;
					*bytes -= attr.size;

					upd_name("", CPFILE);
				}
			}
			else
			{
				if (error < 0)
					stack->result = copy_error(error, fn_get_name(stack->spath), function);
			}
		}

		if (stack->result != XFATAL)
		{
			/* DjV 033 010203 ---vvv--- */
			/*
			int result;

			if ((result = key_state(&key, cfdial_open)) > 0)
			{
				if (key == ESCAPE)
					stack->result = XABORT;
			}
			else if (result < 0)
				stack->result = XABORT;
			*/

			if ( escape_abort( cfdial_open ) )
				stack->result = XABORT;

			/* DjV 033 010203 ---^^^--- */
		}

		if ((stack->result == XFATAL) || (stack->result == XABORT) || (eod == TRUE))
		{
			if ((ready = pull(&stack, &result)) == FALSE)
			{
				if ((result == 0) && (function == CMD_MOVE) && ((result = del_folder(stack->sname, function, 0)) == 0))
					wd_set_update(WD_UPD_MOVED, stack->sname, stack->dname);
				else
					wd_set_update(WD_UPD_COPIED, stack->dname, NULL);

				if (result != 0)
					stack->result = result;

				free(stack->sname);
				free(stack->dname);
				*folders -= 1;

				if ((stack->result != XFATAL) && (stack->result != XABORT))
				{
					upd_name(stack->dpath, CPFOLDER);
					upd_copyinfo(*folders, *files, *bytes);
				}
			}
		}
		else
			upd_copyinfo(*folders, *files, *bytes);
	}
	while (ready == FALSE);

	return result;
}

static boolean copylist(WINDOW *w, int n, int *list, const char *dest,
					  long *folders, long *files, long *bytes, int function)
{
	int i, error, /* key, DjV 031 070203 */ item, result, tmpres;
	XATTR attr;
	const char *path, *name;
	char *dpath;
	boolean chk;

	upd_name(dest, CPFOLDER);

	for (i = 0; i < n; i++)
	{
		if ((item = list[i]) == -1)
			continue;

		name = itm_name(w, item);

		if ((path = itm_fullname(w, item)) == NULL)
			result = copy_error(ENSMEM, name, function);
		else
		{
			switch (itm_type(w, item))
			{
			case ITM_FILE:
			case ITM_PROGRAM:
				upd_name(name, CPFILE);

				if ((error = itm_attrib(w, item, 0, &attr)) == 0)
				{
					result = copy_file(path, dest, &attr, function, result, TRUE);
					*bytes -= attr.size;
				}
				else
					result = copy_error(error, name, function);
				*files -= 1;

				upd_name("", CPFILE);
				break;
			case ITM_FOLDER:
				chk = TRUE;

				upd_name(path, CPFOLDER);

				if ((error = itm_attrib(w, item, 0, &attr)) == 0)
				{
					if ((tmpres = create_folder(path, dest, &dpath, &attr, folders, files, bytes, function, &chk)) == 0)
					{
						if (((tmpres = copy_path(path, dpath, name, folders, files, bytes, function, chk)) == 0) && (function == CMD_MOVE) && ((tmpres = del_folder(path, function, 0)) == 0))
							wd_set_update(WD_UPD_MOVED, path, dpath);
						else
							wd_set_update(WD_UPD_COPIED, dpath, NULL);
						free(dpath);
					}
					else if (tmpres == XSKIP)
						tmpres = 0;
				}
				else
					tmpres = copy_error(error, name, function);

				if (tmpres != 0)
					result = tmpres;

				*folders -= 1;

				upd_name(dest, CPFOLDER);
				break;
			case ITM_DRIVE:
				tmpres = copy_path(path, dest, name, folders, files, bytes, function, TRUE);
				if (tmpres != 0)
					result = tmpres;
				break;
			}
			free(path);
		}

		upd_copyinfo(*folders, *files, *bytes);

		if (result != XFATAL)
		{
			/* DjV 033 010203 ---vvv--- */
			/*
			int r;

			if ((r = key_state(&key, cfdial_open)) > 0)
			{
				if (key == ESCAPE)
					result = XABORT;
			}
			else if (r < 0)
				result = XABORT;
			*/
			
			if ( escape_abort(cfdial_open) )
				result = XABORT;
		}

		if ((result == XABORT) || (result == XFATAL))
			break;
	}
	return ((result == XFATAL) ? FALSE : TRUE);
}

static boolean itm_copy(WINDOW *dw, int dobject, WINDOW *sw, int n,
						int *list, int kstate)
{
	long folders, files, bytes;
	boolean result = FALSE, cont;
	int button, function;
	const char *dest;

	if (dobject < 0)
	{
		if (xw_type(dw) == DIR_WIND)
		{
			if ((dest = strdup(wd_path(dw))) == NULL)
			{
				xform_error(ENSMEM);
				return FALSE;
			}
		}
		else
		{
			alert_printf(1, MILLCOPY);
			return FALSE;
		}
	}
	else
	{
		if ((dest = itm_fullname(dw, dobject)) == NULL)
			return FALSE;

		if ((itm_type(dw, dobject) == ITM_DRIVE) && (check_drive((int) dest[0] - 'A') == FALSE))
		{
			free(dest);
			return FALSE;
		}
	}

	function = (kstate & K_CTRL) ? CMD_MOVE : CMD_COPY;
	rename_files = (kstate & K_ALT) ? TRUE : FALSE;
	overwrite = (options.cprefs & CF_OVERW) ? FALSE : TRUE;

	if (check_copy(sw, n, list, dest) == TRUE)
	{
/*		cont = (options.cprefs & CF_COPY) ? count_items(sw, n, list, &folders, &files, &bytes) : TRUE; */
		cont = count_items(sw, n, list, &folders, &files, &bytes);		/* HR 151102: always display. */

		if (cont == TRUE)
		{
			/* DjV 031 140203 ---vvv--- */
			cv_fntoform ( copyinfo + CPFOLDER, dest );	
			if ( itm_type(sw, list[0]) == ITM_FILE || itm_type(sw, list[0]) == ITM_PROGRAM )
				cv_fntoform( copyinfo + CPFILE, itm_name( sw,list[0] ) );
			else
				*cpfile = 0;
			/* DjV 031 140203 ---^^^--- */
			button = open_cfdialog(CF_COPY, folders, files, bytes, function);

			if (button == COPYOK)
			{
				graf_mouse(HOURGLASS, NULL);
				result = copylist(sw, n, list, dest, &folders, &files, &bytes, function);
				graf_mouse(ARROW, NULL);
			}

			close_cfdialog(button);

			wd_do_update();
		}
	}

	free(dest);

	return result;
}

/********************************************************************
 *																	*
 * Routines voor het wissen van files.								*
 *																	*
 ********************************************************************/

static int del_file(const char *name, int prev)
{
	int error;

	if ((error = x_unlink(name)) == 0)
		wd_set_update(WD_UPD_DELETED, name, NULL);

	return ((error != 0) ? copy_error(error, fn_get_name(name), CMD_DELETE) : prev);
}

static int del_folder(const char *name, int function, int prev)
{
	int error;

	if ((error = x_rmdir(name)) == 0)
	{
		if (function == CMD_DELETE)
			wd_set_update(WD_UPD_DELETED, name, NULL);

	}

	return ((error != 0) ? copy_error(error, fn_get_name(name), function) : prev);
}

static int del_path(const char *path, const char *fname, long *folders,
					long *files, long *bytes)
{
	COPYDATA *stack = NULL;
	boolean ready = FALSE, eod = FALSE;
	int error, result /* , key DjV 031 070203 */ ;
	char name[256];
	XATTR attr;

	if ((error = push(&stack, path, NULL, FALSE)) != 0)
		return copy_error(error, fname, CMD_DELETE);

	do
	{
		if ((stack->result != XFATAL) && (stack->result != XABORT))
		{
			if (((error = stk_readdir(stack, name, &attr, &eod)) == 0) && (eod == FALSE))
			{
				if ((attr.mode & S_IFMT) == S_IFDIR)
				{
					upd_name(name, CPFOLDER);

					if ((stack->sname = x_makepath(stack->spath, name, &error)) != NULL)
						if ((error = push(&stack, stack->sname, NULL, FALSE)) != 0)
							free(stack->sname);
					if (error != 0)
					{
						*folders -= 1;
						stack->result = copy_error(error, name, CMD_DELETE);
						upd_name(stack->spath, CPFOLDER);
					}
				}
				if ((attr.mode & S_IFMT) == S_IFREG)
				{
					upd_name(name, CPFILE);

					if ((stack->sname = x_makepath(stack->spath, name, &error)) != NULL)
					{
						stack->result = del_file(stack->sname, stack->result);
						free(stack->sname);
					}
					else
						stack->result = copy_error(error, name, CMD_DELETE);
					*files -= 1;
					*bytes -= attr.size;

					upd_name("", CPFILE);
				}
			}
			else
			{
				if (error < 0)
					stack->result = copy_error(error, fn_get_name(stack->spath), CMD_DELETE);
			}
		}

		if (stack->result != XFATAL)
		{
			/* DjV 033 010203 ---vvv--- */
			/*
			int result;

			if ((result = key_state(&key, cfdial_open)) > 0)
			{
				if (key == ESCAPE)
					stack->result = XABORT;
			}
			else if (result < 0)
				stack->result = XABORT;
			*/

			if ( escape_abort(cfdial_open) ) 
				stack->result = XABORT;

			/* DJV 033 010203 ---^^^--- */
		}

		if ((stack->result == XFATAL) || (stack->result == XABORT) || (eod == TRUE))
		{
			if ((ready = pull(&stack, &result)) == FALSE)
			{
				stack->result = (result == 0) ? del_folder(stack->sname, CMD_DELETE, stack->result) : result;
				*folders -= 1;
				free(stack->sname);

				if ((stack->result != XFATAL) && (stack->result != XABORT))
				{
					upd_name(stack->spath, CPFOLDER);
					upd_copyinfo(*folders, *files, *bytes);
				}
			}
		}
		else
			upd_copyinfo(*folders, *files, *bytes);
	}
	while (ready == FALSE);

	return result;
}

static boolean del_list(WINDOW *w, int n, int *list, long *folders, long *files, long *bytes)
{
	int i, /* key, DjV 031 070203 */ item, error, result;
	ITMTYPE type;
	const char *path, *name;
	XATTR attr;

	for (i = 0; i < n; i++)
	{
		if ((item = list[i]) == -1)
			continue;

		name = itm_name(w, item);

		if ((path = itm_fullname(w, item)) == NULL)
			result = copy_error(ENSMEM, name, CMD_DELETE);
		else
		{
			type = itm_type(w, item);

			if ((type == ITM_FILE) || (type == ITM_PROGRAM))
			{
				upd_name(name, CPFILE);

				if ((error = itm_attrib(w, item, 0, &attr)) == 0)
				{
					result = del_file(path, result);
					*bytes -= attr.size;
				}
				else
					result = copy_error(error, name, CMD_DELETE);
				*files -= 1;

				upd_name("", CPFILE);
			}
			else
			{
				int tmpres;

				upd_name(path, CPFOLDER);

				tmpres = del_path(path, name, folders, files, bytes);
				if (type == ITM_FOLDER)
				{
					result = (tmpres == 0) ? del_folder(path, CMD_DELETE, result) : tmpres;
					*folders -= 1;
				}

				upd_name("", CPFOLDER);
			}
			free(path);
		}

		upd_copyinfo(*folders, *files, *bytes);

		if (result != XFATAL)
		{

			/* DjV 033 010203 ---vvv--- */
			/*
			int r;

			if ((r = key_state(&key, cfdial_open)) > 0)
			{
				if (key == ESCAPE)
					result = XABORT;
			}
			else if (r < 0)
				result = XABORT;
			*/

			if ( escape_abort(cfdial_open) )
				result = XABORT;

			/* DjV 033 010203 ---^^^--- */

		}

		if ((result == XABORT) || (result == XFATAL))
			break;
	}
	return ((result == XFATAL) ? FALSE : TRUE);
}

boolean itm_delete(WINDOW *w, int n, int *list)
{
	long folders, files, bytes;
	int button;
	boolean result = FALSE, cont;

	if (check_copy(w, n, list, NULL) == FALSE)
		return FALSE;

/*	cont = (options.cprefs & CF_DEL) ? count_items(w, n, list, &folders, &files, &bytes) : TRUE; */

	cont = count_items(w, n, list, &folders, &files, &bytes);		/* HR 151102: always display */
	if (cont == TRUE)
	{
		/* DjV 031 140203 ---vvv--- */
		if ( itm_type(w, list[0]) == ITM_FOLDER )
			cv_fntoform ( copyinfo + CPFOLDER, itm_name(w,list[0]) );	
		else
			*cpfolder = 0;
		if ( itm_type(w, list[0]) == ITM_FILE || itm_type(w, list[0]) == ITM_PROGRAM )
			cv_fntoform( copyinfo + CPFILE, itm_name( w,list[0] ) );
		else
			*cpfile = 0;
		/*  DjV 031 140203 ---^^^--- */
		
		button = open_cfdialog(CF_DEL, folders, files, bytes, CMD_DELETE);

		if (button == COPYOK)
		{
			graf_mouse(HOURGLASS, NULL);
			result = del_list(w, n, list, &folders, &files, &bytes);
			graf_mouse(ARROW, NULL);
		}

		close_cfdialog(button);

		wd_do_update();
	}

	return result;
}

/********************************************************************
 *																	*
 * Hoofdprogramma kopieer gedeelte.									*
 *																	*
 ********************************************************************/

boolean item_copy(WINDOW *dw, int dobject, WINDOW *sw, int n,
				  int *list, int kstate)
{
	const char *program;
	ITMTYPE type;
	int wtype;
	boolean result = FALSE;

	wtype = xw_type(dw);

	if ((wtype == DIR_WIND) || ((wtype == DESK_WIND) && (dobject >= 0)))
	{
		if ((dobject >= 0) && ((type = itm_type(dw, dobject)) != ITM_FOLDER) && (type != ITM_DRIVE) && (type != ITM_PREVDIR))
		{
			switch (type)
			{
			case ITM_TRASH:
				return itm_delete(sw, n, list);
			case ITM_PRINTER:
				return item_print(sw, n, list);
			case ITM_PROGRAM:
				if ((program = itm_fullname(dw, dobject)) != NULL)
				{
					result = app_exec(program, NULL, sw, list, n, kstate, TRUE);
					free(program);
				}
				return result;
			default:
				alert_printf(1, MILLCOPY);
				return FALSE;
			}
		}
		else
			return itm_copy(dw, dobject, sw, n, list, kstate);
	}
	else
	{
		alert_printf(1, MILLCOPY);
		return FALSE;
	}
}
