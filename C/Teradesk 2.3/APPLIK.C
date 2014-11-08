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
#include <ctype.h>
#include <string.h>
#include <stdlib.h>
#include <tos.h>
#include <vdi.h>
#include <boolean.h>
#include <mint.h>
#include <xdialog.h>

#include "desk.h"
#include "error.h"
#include "resource.h"
#include "startprg.h"
#include "xfilesys.h"
#include "file.h"
#include "prgtype.h"
#include "window.h"
#include "applik.h"
#include "va.h"		/* HR 060203 */

typedef struct
{
	int appltype : 4;
	unsigned int path:1;
	unsigned int fkey:6;
	unsigned int argv:1;
	int resvd1:4;
	int resvd2;
} SINFO;

APPLINFO *applikations;

static void lfree(FTYPE **list)
{
	FTYPE *h, *next;

	h = *list;
	while (h)
	{
		next = h->next;
		free(h);
		h = next;
	}
	*list = NULL;
}

static APPLINFO *find_appl(const char *program)
{
	APPLINFO *h;

	h = applikations;
	while (h != NULL)
	{
		if (strcmp(program, h->name) == 0)
			return h;
		h = h->next;
	}
	return NULL;
}

static void rem_appl(APPLINFO *appl)
{
	if (appl == NULL)
		return;

	if (appl->prev != NULL)
		appl->prev->next = appl->next;
	else
		applikations = appl->next;

	if (appl->next != NULL)
		appl->next->prev = appl->prev;

	free(appl->name);
	free(appl->cmdline);
	lfree(&appl->filetypes);
	free(appl);
}

static APPLINFO *add_appl(const char *name, const char *cmdline)
{
	APPLINFO *appl, *h;

	if ((appl = malloc(sizeof(APPLINFO))) != NULL)
	{
		if ((h = applikations) == NULL)
		{
			applikations = appl;
			appl->prev = NULL;
		}
		else
		{
			while (h->next != NULL)
				h = h->next;
			h->next = appl;
			appl->prev = h;
		}
		appl->next = NULL;
		appl->name = name;
		appl->cmdline = cmdline;
	}
	else
	{
		free(name);
		free(cmdline);
	}

	return appl;
}

static void rem_filetype(FTYPE **list, FTYPE *current)
{
	if (current->prev == NULL)
		*list = current->next;
	else
		current->prev->next = current->next;

	if (current->next != NULL)
		current->next->prev = current->prev;

	free(current);
}

static boolean add_filetype(FTYPE **list, FTYPE *current, char *filetype)
{
	FTYPE *p, *last;

	if ((p = malloc(sizeof(FTYPE))) == NULL)
		return FALSE;
	else
	{
		strncpy(p->filetype, filetype, sizeof(SNAME));		/* HR 240203 */
		if (current != NULL)
		{
			p->prev = current;
			if ((p->next = current->next) != NULL)
				p->next->prev = p;
			current->next = p;
		}
		else
		{
			if ((last = *list) != NULL)
			{
				while (last->next != NULL)
					last = last->next;
				p->prev = last;
				p->next = NULL;
				last->next = p;
			}
			else
			{
				*list = p;
				p->prev = NULL;
				p->next = NULL;
			}
		}
	}
	return TRUE;
}

static void set_prgtype(ApplType type)
{
	xd_set_rbutton(applikation, APPAR2, AGEM + (int) type);
}

static ApplType get_prgtype(void)
{
	return (ApplType) (xd_get_rbutton(applikation, APPAR2) - AGEM);
}

static void set_prgpath(boolean prgpath)
{
	xd_set_rbutton(applikation, APPAR1, (prgpath == TRUE) ? APPRG : APWINDOW);
}

static boolean get_prgpath(void)
{
	return (xd_get_rbutton(applikation, APPAR1) == APPRG) ? TRUE : FALSE;
}

static void set_fkey(int fkey)
{
	if (fkey == 0)
		*applfkey = 0;
	else
		itoa(fkey, applfkey, 10);
}

static int get_fkey(APPLINFO *cur)
{
	int fkey;
	APPLINFO *appl;

	if ((fkey = atoi(applfkey)) == 0)
		return 0;

	if (((appl = find_fkey(fkey)) != NULL) && (cur != appl))
	{
		if (alert_printf(2, MFKEYUSD, fkey) == 1)
			appl->fkey = 0;
		else
			return -1;
	}
	return fkey;
}

/********************************************************************
 *																	*
 * Funktie voor het verversen van geinstalleerde applikaties.		*
 *																	*
 ********************************************************************/

static boolean app_set_path(APPLINFO *info, const char *newpath)
{
	char *h;

	if ((h = strdup(newpath)) == NULL)
	{
		alert_printf(1, MAPPLPM, fn_get_name(newpath));
		return FALSE;
	}

	free(info->name);
	info->name = h;

	return TRUE;
}

void app_update(wd_upd_type type, const char *fname1, const char *fname2)
{
	APPLINFO *info;

	if ((info = find_appl(fname1)) != NULL)
	{
		if (type == WD_UPD_DELETED)
			rem_appl(info);
		if (type == WD_UPD_MOVED)
			app_set_path(info, fname2);
	}
}

/********************************************************************
 *																	*
 * Hulpfunkties voor install_appl()									*
 *																	*
 ********************************************************************/

static boolean copy_list(FTYPE **dest, FTYPE *src)
{
	FTYPE *p;

	*dest = NULL;
	p = src;
	while (p)
	{
		if (add_filetype(dest, NULL, p->filetype) == FALSE)
		{
			xform_error(ENSMEM);
			return FALSE;
		}
		p = p->next;
	}
	return TRUE;
}

static boolean do_add(FTYPE **list, FTYPE *current)
{
	int button;
	SNAME type;			/* HR 240203 */
	boolean ret;

	rsc_title(newfolder, NDTITLE, DTADDFT);

	*dirname = 0;

	button = xd_dialog(newfolder, DIRNAME);

	if (button == NEWDIROK)
	{
		cv_formtofn(type, dirname);
		if ((ret = add_filetype(list, current, type)) == FALSE)
			xform_error(ENSMEM);
	}
	else
		ret = FALSE;

	return ret;
}

void app_install(void)
{
	int item, button, fkey;
	ApplType type;
	boolean ppath, quit = FALSE, argv;
	const char *pname, *name;
	char *newcml;
	WINDOW *w;
	APPLINFO *appl;
	FTYPE *list, *current;
	XDINFO info;

	if (applikation->r.w > max_w)
	{
		alert_printf(1, MDIALTBG);
		return;
	}

	if (((w = wd_selected_wd()) == NULL) || ((item = wd_selected()) < 0))
		return;

	name = itm_name(w, item);
	if ((pname = itm_fullname(w, item)) == NULL)
		return;
	appl = find_appl(pname);

	cv_fntoform(applikation + APNAME, name);		/* HR 240103 */

	if (appl == NULL)
	{
		list = NULL;
		strcpy(applcmdline, "%f");
		prg_info(pname, &type, &argv, &ppath);
		fkey = 0;
		applikation[APREM].ob_state |= DISABLED;		/* HR 151102 */
	}
	else
	{
		if (copy_list(&list, appl->filetypes) == FALSE)
		{
			free(pname);
			return;
		}
		strcpy(applcmdline, appl->cmdline);
		type = appl->appltype;
		ppath = appl->path;
		fkey = appl->fkey;
		argv = appl->argv;
		applikation[APREM].ob_state &= ~DISABLED;		/* HR 151102 */
	}

	set_prgtype(type);
	set_prgpath(ppath);
	set_fkey(fkey);

	if (argv == TRUE)				/* HR 151102 */
		applikation[APARGV].ob_state |= SELECTED;
	else
		applikation[APARGV].ob_state &= ~SELECTED;

	current = list;
	*appltype = 0;

	xd_open(applikation, &info);

	while (quit == FALSE)
	{
		if (current == NULL)
			current = list;

		cv_fntoform(applikation + APTYPE, (current != NULL) ? current->filetype : "");		/* HR 240103 */

		xd_draw(&info, APTYPE, MAX_DEPTH);

		button = xd_form_do(&info, APCMLINE) & 0x7FFF;

		switch (button)
		{
		case APOK:
			if ((fkey = get_fkey(appl)) < 0)
				break;

			if (appl != NULL)
			{
				free(pname);
				lfree(&appl->filetypes);
			}

			if ((appl == NULL) || (strcmp(applcmdline, appl->cmdline) != 0))
			{
				if ((newcml = strdup(applcmdline)) != NULL)
				{
					if (appl != NULL)
					{
						free(appl->cmdline);
						appl->cmdline = newcml;
					}
				}
				else
				{
					xform_error(ENSMEM);
					if (appl == NULL)
						goto exit1;
				}
			}

			if ((appl == NULL) && ((appl = add_appl(pname, newcml)) == NULL))
			{
				xform_error(ENSMEM);
				goto exit2;
			}

			appl->filetypes = list;
			appl->appltype = get_prgtype();
			appl->path = get_prgpath();
			appl->fkey = fkey;
			appl->argv = (applikation[APARGV].ob_state & SELECTED) ? TRUE : FALSE;
			quit = TRUE;
			break;
		case ADDTYPE:
			if (do_add(&list, current) == FALSE)
				break;
		case APNEXT:
			if (current && (current->next != NULL))
				current = current->next;
			break;
		case DELTYPE:
			if (current)
			{
				FTYPE *next;

				if ((next = current->next) == NULL)
					next = current->prev;
				rem_filetype(&list, current);
				current = next;
			}
			break;
		case APPREV:
			if (current && (current->prev != NULL))
				current = current->prev;
			break;
		case APREM:
			rem_appl(appl);
		default:
		  exit1:free(pname);
		  exit2:lfree(&list);
			quit = TRUE;
			break;
		}
		xd_change(&info, button, NORMAL, (quit == FALSE) ? 1 : 0);
	}
	xd_close(&info);
}

APPLINFO *app_find(const char *file)
{
	APPLINFO *h;
	FTYPE *t;

	h = applikations;
	while (h != NULL)
	{
		t = h->filetypes;
		while (t)
		{
			if (cmp_wildcard(file, t->filetype) == TRUE)
				return h;
			t = t->next;
		}
		h = h->next;
	}
	return NULL;
}

APPLINFO *find_fkey(int fkey)
{
	APPLINFO *h;

	h = applikations;

	while (h)
	{
		if (h->fkey == fkey)
			return h;
		h = h->next;
	}

	return NULL;
}

/*
 * Determine the length of the command line.
 */
static
long app_get_arglen
(
	const char *format,
	WINDOW *w,
	int *sellist,
	int n,
	const char *fname			 /* DjV 028 160203 */
)
{
	const char *c = format;
	char h, *mes;
	long l = 0;
	int i, item;
	ITMTYPE type;

	while (*c)
	{
		/* if ((*c++ == '%') && (n > 0)) DJV 028 160203 */
		if ((*c++ == '%') && ( (n > 0) || (n == -1) ) ) /* DjV 028 160203 */
		{
			h = tolower(*c++);
			if ((h == 'n') || (h == 'f'))
			{
				for (i = 0; i < n; i++)
				{
					item = sellist[i];
					type = itm_type(w, item);

					if ((type == ITM_TRASH) || (type == ITM_PRINTER))
					{
						switch (type)
						{
						case ITM_TRASH:
							rsrc_gaddr(R_STRING, MTRASHCN, &mes);
							break;
						case ITM_PRINTER:
							rsrc_gaddr(R_STRING, MPRINTER, &mes);
							break;
						}
						if (alert_printf(1, MNODRAGP, mes) == 1)
							continue;
						else
							return -1L;
					}
					else
					{
						if (i != 0)
							l++;
						if ((h == 'f') || (type == ITM_DRIVE))
							l += itm_info(w, item, ITM_FNAMESIZE);
						else if (h == 'n')
							l += itm_info(w, item, ITM_NAMESIZE);
					}
				}
				/* DjV 028 160203 ---vvv--- */
				if ( n == -1 )
				{
					if ( h == 'f' )
						l += strlen (fname);
					else if ( h == 'n' )
						l += strlen(fn_get_path(fname)); 
				}
				/* DjV 028 160203 ---^^^--- */
			}
			else
				l++;
		}
		else
			l++;
	}

	return l;
}

/*
 * Build the command line from the format string and the
 * selected objects.
 */

/* static boolean app_set_cml(const char *format, WINDOW *w,
						   int *sellist, int n, char *dest) DjV 028 160203 */
static boolean app_set_cml(const char *format, WINDOW *w,
						   int *sellist, int n, const char *fname, char *dest) /* DjV 028 160203 */
{
	const char *c = format, *s;
	char h, *d = dest, *tmp;
	int i, item;
	ITMTYPE type;

	while (*c == ' ')
		c++;

	while ((h = *c++) != 0)
	{
		/* if ((h == '%') && (n > 0)) DjV 028 160203 */
		if ((h == '%') && ( (n > 0) || (n == -1)) ) /* DJV 028 160203 */
		{
			h = *c++;
			if ((tolower(h) == 'f') || (tolower(h) == 'n'))
			{
				for (i = 0; i < n; i++)
				{
					item = sellist[i];
					type = itm_type(w, item);

					if ((type != ITM_TRASH) && (type != ITM_PRINTER))
					{
						if (i != 0)
							*d++ = ' ';

						if ((tolower(h) == 'f') || (type == ITM_DRIVE))
						{
							if ((tmp = itm_fullname(w, item)) == NULL)
								return FALSE;
						}
						else
						{
							if ((tmp = strdup(itm_name(w, item))) == NULL)
								return FALSE;
						}

						if (isupper(h))
							strlwr(tmp);

						s = tmp;
						while (*s)
							*d++ = *s++;
						free(tmp);
					}
				}
				/* DjV 028 160203 ---vvv--- */
				if ( n == -1 )
				{
					if ( tolower(h) == 'f' )
						s = fname;
					else if ( tolower(h) == 'n' )
						s = fn_get_name(fname);
					while (*s)
						*d++ = (isupper(h)) ? tolower(*s++) : *s++ ;
				}
				/* DjV 028 160203 ---^^^--- */
			}
			else
				*d++ = h;
		}
		else
			*d++ = h;
	}

	*d++ = 0;

	return TRUE;
}

/*
 * Check and build the command line from the fromat string and
 * the selected objects.
 */

/* static char *app_build_cml(const char *format, WINDOW *w,
						   int *list, int n) DjV 028 160203 */
static char *app_build_cml(const char *format, WINDOW *w,
						   int *list, int n, const char *fname) /* DjV 028 160203 */
{
	long l;
	char *cmdline;

	/* if ((l = app_get_arglen(format, w, list, n)) < 0) DjV 028 160203 */
	if ((l = app_get_arglen(format, w, list, n, fname)) < 0) /* DjV 028 160203 */
		return NULL;

	l += 2;		/* Length byte and terminating 0. */

	if ((cmdline = malloc(l)) != NULL)
	{
		/* if (app_set_cml(format, w, list, n, cmdline + 1) == FALSE) DjV 028 160203 */
		if (app_set_cml(format, w, list, n, fname, cmdline + 1) == FALSE) /* DjV 028 160203 */
		{
			free(cmdline);
			return NULL;
		}

		if ((l = strlen(cmdline + 1)) <= 125)
			*cmdline = (char) l;
		else
			*cmdline = 127;
	}

	return cmdline;
}

#pragma warn -par

/*
 * Start a program or an application.
 *
 * Parameters:
 *
 * program	- name of program to start. Is allowed to be NULL if
 *			  'app' is not NULL
 * app		- application to start. Is allowed to be NULL if
 *			  'program' is not NULL
 * w		- window from which objects were dragged to the
 *			  application, or NULL if no objects were dragged to
 *			  the program (i.e. program was started directly)
 * sellist	- list of selected objects in 'w'
 * n		- number of selected objects in 'w', or 0 if no objects
 *			  are dragged to the program.
 * dragged	- not used
 *
 * Result: TRUE if succesfull, FALSE if not.
 */

/* DjV 028 160203 
 * modified to use *program to pass explicit 
 * path and name of file to open in case of n=-1 && app != NULL
 */
boolean app_exec(const char *program, APPLINFO *app, WINDOW *w,
				 int *sellist, int n, int kstate, boolean dragged)
{
	APPLINFO *appl;				/* Application info of program. */
	const char *cl_format;		/* Format of commandline. */
	char *cmdline = cmdlinetxt;	/* Command line. */ /* HR 240203 */
	const char *name;			/* Program name. */
	const char *def_path;		/* Default path of program. */
	boolean argv;				/* Use ARGV protocol flag. */
	ApplType appl_type;			/* Type of program. */
	boolean result;

	/* If application is NULL, findout if 'program' is installed as
	   an application. */

	appl = (app == NULL) ? find_appl(program) : app;

	if (appl == NULL)
	{
		boolean ppath;

		/* 'program' is not installed as an application. Use default
		   settings. */

		cl_format = "%f";
		name = (char *) program;
		prg_info(name, &appl_type, &argv, &ppath);
		def_path = (ppath == TRUE) ? NULL : wd_toppath();

		/* Abort if program does not exist. */

		if (x_exist(name, EX_FILE) == FALSE)
		{
			alert_printf(1, MPRGNFND, fn_get_name(name));
			return FALSE;
		}
	}
	else
	{
		/* 'app' is not NULL or 'program' is installed as an
		   application. Use the settings set by the user in the
		   'Install application' dialog. */

		cl_format = appl->cmdline;
		name = appl->name;
		appl_type = appl->appltype;
		argv = appl->argv;
		def_path = (appl->path == TRUE) ? NULL : wd_toppath();

		/* If the application does not exist, ask the user to
		   locate it or to remove it. */

		if (x_exist(name, EX_FILE) == FALSE)
		{
			int button;

			if ((button = alert_printf(1, MAPPNFND, fn_get_name(name))) == 3)
				return FALSE;
			else if (button == 2)
			{
				rem_appl(appl);
				return FALSE;
			}
			else if ((newname = locate(name, L_PROGRAM)) == NULL)
				return FALSE;
			else
			{
				free(name);
				appl->name = name = newname;
			}
		}
	}

	if (n == 0)
	{
		/* If there are no files passed to the program (n is 0) and
		   the program is a TTP or GTP program, then ask the user to
		   enter a command line. */
		/* HR 240203: considerable code reduction because the commandline dialogue
		              has now a single scrollable editable text field. */

		if ((appl_type == PTTP) || (appl_type == PGTP))
		{
			if (xd_dialog(getcml, CMDLINE) != CMLOK)
				return FALSE;

			cmdline[0] = strlen(cmdline + 1);
		}
		else
		{
			cmdline[0] = 0;
			cmdline[1] = 0;
		}
	}
	/* else DjV 028 160203 */
	else if ( n > 0 )	/* DjV 028 160203 */
	{
		/* There are files passed to the program, build the command
		   line. */

		/* if ((cmdline = app_build_cml(cl_format, w, sellist, n)) == NULL) DjV 028 160203 */
		if ((cmdline = app_build_cml(cl_format, w, sellist, n, NULL)) == NULL) /* DjV 028 160203 */
			return FALSE;
	}
	/* DjV 028 160203 ---vvv--- */
	/* File to open is passed by explicit path or name */
	else if ( n == -1 )
		if ((cmdline = app_build_cml(cl_format, w, sellist, n, program)) == NULL) /* DjV 028 160203 */
			return FALSE;
	/* DjV 028 160203 ---^^^--- */

	if ((argv == FALSE) && (strlen(cmdline + 1) > 125))
	{
		/* Check if the commandline is too long. */

		/* alert_printf(1, MCMDTLNG); DjV 035 050203 */
		xform_error ( ECOMTL ); /* DjV 035 050203 */

		result = FALSE;
	}
	else
	{
		/* No error, start the program. */

		if (!va_start_prg(name, &cmdline[1]))
			start_prg(name, cmdline, def_path, appl_type, argv, kstate);
		result = TRUE;
	}

/*	free(cmdline);			/* HR 240203 */
*/
	return result;
}

#pragma warn .par

/********************************************************************
 *																	*
 * Funkties voor initialisatie, laden en opslaan.					*
 *																	*
 ********************************************************************/

void app_init(void)
{
	applikations = NULL;
#ifdef MEMDEBUG
	atexit(app_default);
#endif
}

void app_default(void)
{
	while (applikations != NULL)
		rem_appl(applikations);
}

int app_load(XFILE *file)
{
	SINFO appl;
	APPLINFO *h;
	char *name, *cmdline;
	SNAME filetype;			/* HR 240203 */
	long n;
	int error;

	app_default();

	do
	{
		if ((n = x_fread(file, &appl, sizeof(SINFO))) != sizeof(SINFO))
			return (n < 0) ? (int) n : EEOF;

		if (appl.appltype != -1)
		{
			if ((name = x_freadstr(file, NULL, sizeof(LNAME), &error)) == NULL)		/* HR 240103: max l */ /* HR 240203 */
				return error;

			if ((cmdline = x_freadstr(file, NULL, sizeof(LNAME), &error)) == NULL)		/* HR 240103: max l */ /* HR 240203 */
			{
				free(name);
				return error;
			}

			if ((h = add_appl(name, cmdline)) == NULL)
				return ENSMEM;

			h->appltype = appl.appltype;
			h->path = (boolean) appl.path;
			h->fkey = appl.fkey;
			h->argv = appl.argv;
			h->filetypes = NULL;

			do
			{
				if (x_freadstr(file, filetype, sizeof(filetype), &error) == NULL)		/* HR 240103: max l */
					return error;

				if ((filetype[0] != 0) && (add_filetype(&(h->filetypes), NULL, filetype) == FALSE))
					return ENSMEM;
			}
			while (filetype[0] != 0);
		}
	}
	while (appl.appltype != -1);

	return 0;
}

int app_save(XFILE *file)
{
	SINFO appl;
	APPLINFO *h;
	FTYPE *t;
	long n;
	int error;

	h = applikations;

	while (h)
	{
		appl.appltype = h->appltype;
		appl.path = (unsigned int) h->path;
		appl.fkey = h->fkey;
		appl.argv = h->argv;
		appl.resvd1 = 0;
		appl.resvd2 = 0;

		if ((n = x_fwrite(file, &appl, sizeof(SINFO))) < 0)
			return (int) n;

		if ((error = x_fwritestr(file, h->name)) < 0)
			return error;

		if ((error = x_fwritestr(file, h->cmdline)) < 0)
			return error;

		t = h->filetypes;

		while (t)
		{
			if ((error = x_fwritestr(file, t->filetype)) < 0)
				return error;
			t = t->next;
		}
		if ((error = x_fwritestr(file, "")) < 0)
			return error;

		h = h->next;
	}

	appl.appltype = -1;
	appl.path = FALSE;

	return ((n = x_fwrite(file, &appl, sizeof(SINFO))) < 0) ? (int) n : 0;
}
