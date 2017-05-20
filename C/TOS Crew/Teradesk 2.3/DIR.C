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
#include <limits.h>
#include <stdlib.h>
#include <string.h>
#include <vdi.h>
#include <boolean.h>
#include <library.h>
#include <mint.h>
#include <xdialog.h>
#include <xscncode.h>

#include "desk.h"
#include "sprintf.h"		/* HR 240203: get rid of stream io */
#include "xfilesys.h"
#include "dir.h"
#include "error.h"
#include "events.h"
#include "file.h"
#include "filetype.h"
#include "font.h"
#include "icon.h"
#include "resource.h"
#include "screen.h"
#include "showinfo.h"
#include "window.h"
#include "copy.h"
#include "icontype.h"
#include "open.h"
#include "desktop.h" /* DjV 019 110103 */

#define DFLAGS			(NAME|CLOSER|FULLER|MOVER|INFO|SIZER|UPARROW|DNARROW|VSLIDE|LFARROW|RTARROW|HSLIDE)
#define MAXWINDOWS		8				/* Maximum number of directory windows. */
#define DELTA			2				/* Distance between two lines in pixels. */
#define TOFFSET			2
#define XOFFSET			8
#define YOFFSET			4
#define ICON_W			80
#define ICON_H			46
#define BORDERS			4				/* Total length of left and right border of a line. */


#define DEFAULT_EXT		"*"
#define MAXLENGTH		128				/* Maximum length of a filename to display in a window. HR: 128 */
#define MINLENGTH		12				/* Minimum length of a filename to display in a window. */
#define ITEMLEN			44				/* Length of a line, without the filename. */
/* HR 151102: must have both at the same time. */
#define TOSDEFAULT_EXT		"*"
#define TOSITEMLEN			51				/* Length of a line. */

#define SIZELEN 8 /* DjV 010 261202 length of field for file size, i.e. max 9999999 ~10MB */

typedef struct
{
	unsigned int fulled : 1;
	unsigned int resvd:15;
} WDFLAGS;

typedef struct
{
	unsigned int mode;
	long size;
	unsigned int mtime, mdate;
	unsigned int attrib;
} FATTR;

typedef struct
{
	boolean selected,
	        newstate,
	        visible,
	        link;
	int index;
	FATTR attrib;
	ITMTYPE item_type;
	int icon;
	const char *icname,
	           *name;
} NDTA;

typedef struct
{
	ITM_INTVARS;				/* Interne variabelen bibliotheek. */
	int scolumns;				/* aantal kolommen als systeemfont wordt gebruikt */

	int rows;					/* aantal zichtbare rijen en kolommen */
	int columns;

	int nrows;					/* aantal rijen waarmee gescrolled moet worden */
	int ncolumns;

	int px;
	int py;

	const char *path;
	const char *fspec;
	char title[80];
	char info[60];

	int fs_type;				/* HR 151102: We need to know the filesystem type for formatting purposes. */
	int nfiles;					/* number of files in directory */
	int nvisible;				/* number of visible files in directory */
	int nlines;
	int nselected;
	long usedbytes;
	int namelength;				/* length of longest name in the directory */
	NDTA *buffer;
	boolean refresh;

	struct winfo *winfo;		/* pointer to WINFO structure. */
} DIR_WINDOW;

typedef struct winfo
{
	int x;						/* positie van het window */
	int y;
	int w;						/* afmetingen van het werkgebied */
	int h;
	WDFLAGS flags;
	boolean used;
	DIR_WINDOW *dir_window;
} WINFO;

typedef struct
{
	int x;
	int y;
	int w;
	int h;
	WDFLAGS flags;
	int resvd;
} SINFO1;

typedef struct
{
	int index;
	int px;
	int py;
} SINFO2;

typedef struct
{
	int id;
	int size;
	int resvd1;
	int resvd2;
} FDATA;

#define bold 1
#define light 2
#define italic 4
#define ulined 8
#define white 16

static WINFO dirwindows[MAXWINDOWS];
static RECT dmax;
static char prevdir[] = "..";
FONT dir_font;

extern int scansh ( int key, int kstate );  /* DjV 019 110103 */

extern SEL_INFO selection; 					/* DjV 017 280103 */

static void dir_draw(DIR_WINDOW *w, boolean message);
static void do_redraw(DIR_WINDOW *w, RECT *r1, boolean clear);

static int dir_hndlkey(WINDOW *w, int scancode, int keystate);
static void dir_hndlbutton(WINDOW *w, int x, int y, int n, int button_state, int keystate);
static void dir_redraw(WINDOW *w, RECT *area);
static void dir_topped(WINDOW *w);
static void dir_closed(WINDOW *w);
static void dir_fulled(WINDOW *w);
static void dir_arrowed(WINDOW *w, int arrows);
static void dir_hslider(WINDOW *w, int newpos);
static void dir_vslider(WINDOW *w, int newpos);
static void dir_sized(WINDOW *w, RECT *newsize);
static void dir_moved(WINDOW *w, RECT *newpos);
static void dir_top(WINDOW *w);
static int linelength(DIR_WINDOW *w); /* DjV 012 271202 needed before defined */

static WD_FUNC dir_functions =
{
	dir_hndlkey,
	dir_hndlbutton,
	dir_redraw,
	dir_topped,
	dir_topped,
	dir_closed,
	dir_fulled,
	dir_arrowed,
	dir_hslider,
	dir_vslider,
	dir_sized,
	dir_moved,
	0L,
	dir_top
};

static int		itm_find	(WINDOW *w, int x, int y);
static boolean	itm_state	(WINDOW *w, int item);
static ITMTYPE	itm_type	(WINDOW *w, int item);
static int		itm_icon	(WINDOW *w, int item);
static const
       char *	itm_name	(WINDOW *w, int item);
static char *	itm_fullname(WINDOW *w, int item);
static int		itm_attrib	(WINDOW *w, int item, int mode, XATTR *attrib);
static long		itm_info	(WINDOW *w, int item, int which);
static boolean	dir_open	(WINDOW *w, int item, int kstate);
static boolean	dir_copy	(WINDOW *dw, int dobject, WINDOW *sw, int n, int *list, ICND *icns, int x, int y, int kstate);
static void		itm_select	(WINDOW *w, int selected, int mode, boolean draw);
static void		itm_rselect	(WINDOW *w, int x, int y);
static boolean	itm_xlist	(WINDOW *w, int *nselected, int *nvisible, int **sel_list, ICND **icns, int mx, int my);
static boolean	itm_list	(WINDOW *w, int *n, int **list);
/* static const char *dir_path	(WINDOW *w);		Djv 031 070203 --> dir.h  */
static void		dir_set_update	(WINDOW *w, wd_upd_type type, const char *fname1, const char *fname2);
static void		dir_do_update	(WINDOW *w);
static void		dir_filemask	(WINDOW *w);
static void		dir_newfolder	(WINDOW *w);
static void		dir_disp_mode	(WINDOW *w, int mode);
static void		dir_sort		(WINDOW *w, int sort);
/* static void	dir_attrib		(WINDOW *w, int attrib);  HR 050303 */
static void		dir_fields		(WINDOW *w, int attrib);  /* HR 050303 */
static void		dir_seticons	(WINDOW *w);

static ITMFUNC itm_func =
{
	itm_find,					/* itm_find */
	itm_state,					/* itm_state */
	itm_type,					/* itm_type */
	itm_icon,					/* itm_icon */
	itm_name,					/* itm_name */
	itm_fullname,				/* itm_fullname */
	itm_attrib,					/* itm_attrib */
	itm_info,					/* itm_info */

	dir_open,					/* itm_open */
	dir_copy,					/* itm_copy */
	item_showinfo,				/* itm_showinfo */

	itm_select,					/* itm_select */
	itm_rselect,				/* itm_rselect */
	itm_xlist,					/* itm_xlist */
	itm_list,					/* itm_list */

	dir_path,					/* wd_path */
	dir_set_update,				/* wd_set_update */
	dir_do_update,				/* wd_do_update */
	dir_filemask,				/* wd_filemask */
	dir_newfolder,				/* wd_newfolder */
	dir_disp_mode,				/* wd_disp_mode */
	dir_sort,					/* wd_sort */
/*	dir_attrib,			*/		/* wd_attrib */ 
	dir_fields,					/* wd_fields  HR 240203  */
	dir_seticons				/* wd_seticons */
};

static void calc_nlines(DIR_WINDOW *w);
static void set_sliders(DIR_WINDOW *w);
static void calc_rc(DIR_WINDOW *w, RECT *work);

/********************************************************************
 *																	*
 * Funkties voor het sorteren van directories.						*
 *																	*
 ********************************************************************/

/* Sorteer op zichtbaarheid */

static int _s_visible(NDTA *e1, NDTA *e2)
{
	if ((e1->visible == TRUE) && (e2->visible == FALSE))
		return -1;
	if ((e2->visible == TRUE) && (e1->visible == FALSE))
		return 1;
	return 0;
}

/* Sorteer op folder of file. */

static int _s_folder(NDTA *e1, NDTA *e2)
{
	int h;

	if ((h = _s_visible(e1, e2)) != 0)
		return h;
	if ((e1->attrib.attrib & 0x10) && ((e2->attrib.attrib & 0x10) == 0))
		return -1;
	if ((e2->attrib.attrib & 0x10) && ((e1->attrib.attrib & 0x10) == 0))
		return 1;
	return 0;
}

/* Funktie voor het sorteren van een directory op naam. */

static int sortname(NDTA *e1, NDTA *e2)
{
	int h;

	if ((h = _s_folder(e1, e2)) != 0)
		return h;
	return strcmp(e1->name, e2->name);
}

/* Funktie voor het sorteren van een directory op extensie. */

static int sortext(NDTA *e1, NDTA *e2)
{
	int h;
	char *ext1, *ext2;

	if ((h = _s_folder(e1, e2)) != 0)

		return h;

	if (strcmp(e1->name, prevdir) == 0)
		return -1;
	if (strcmp(e2->name, prevdir) == 0)
		return 1;

	ext1 = strchr(e1->name, '.');
	ext2 = strchr(e2->name, '.');
	if ((ext1 != NULL) || (ext2 != NULL))
	{
		if (ext1 == NULL)
			return -1;
		if (ext2 == NULL)
			return 1;
		if ((h = strcmp(ext1 + 1, ext2 + 1)) != 0)
			return h;
	}
	return strcmp(e1->name, e2->name);
}

/* Funktie voor het sorteren op lengte. */

static int sortlength(NDTA *e1, NDTA *e2)
{
	int h;

	if ((h = _s_folder(e1, e2)) != 0)
		return h;
	if (e1->attrib.size > e2->attrib.size)
		return 1;
	if (e2->attrib.size > e1->attrib.size)
		return -1;
	return strcmp(e1->name, e2->name);
}

/* Funktie voor het sorteren op datum. */

static int sortdate(NDTA *e1, NDTA *e2)
{
	int h;

	if ((h = _s_folder(e1, e2)) != 0)
		return h;
	if (e1->attrib.mdate < e2->attrib.mdate)
		return 1;
	if (e2->attrib.mdate < e1->attrib.mdate)
		return -1;
	if (e1->attrib.mtime < e2->attrib.mtime)
		return 1;
	if (e2->attrib.mtime < e1->attrib.mtime)
		return -1;
	return strcmp(e1->name, e2->name);
}

static int unsorted(NDTA *e1, NDTA *e2)
{
	int h;

	if ((h = _s_visible(e1, e2)) != 0)
		return h;
	if (e1->index > e2->index)
		return 1;
	else
		return -1;
}

static void sort_directory(NDTA *buffer, int n, int sort)
{
	int (*sortproc) (NDTA *e1, NDTA *e2);

	switch (sort)
	{
	case WD_SORT_NAME:
		sortproc = sortname;
		break;
	case WD_SORT_EXT:
		sortproc = sortext;
		break;
	case WD_SORT_DATE:
		sortproc = sortdate;
		break;
	case WD_SORT_LENGTH:
		sortproc = sortlength;
		break;
	case WD_NOSORT:
		sortproc = unsorted;
		break;
	}

	qsort(buffer, n, sizeof(NDTA), sortproc);
}

static void dir_sort(WINDOW *w, int sort)
{
	sort_directory(((DIR_WINDOW *) w)->buffer, ((DIR_WINDOW *) w)->nfiles, sort);
	dir_draw((DIR_WINDOW *) w, FALSE);
}

/********************************************************************
 *																	*
 * Funkties voor het laden van directories in een window.			*
 *																	*
 ********************************************************************/

/* Zet de inforegel van een window. Als n = 0 is dit het aantal
   bytes en files, als n ongelijk is aan 0 is dit de tekst
   'n items selected' */

static void dir_info(DIR_WINDOW *w, int n, long bytes)
{
	char *s;

	if (n > 0)
	{
		char *msg;

		rsrc_gaddr(R_STRING, (n == 1) ? MISINGUL : MIPLURAL, &s);
		rsrc_gaddr(R_STRING, MSITEMS, &msg);
		sprintf(w->info, msg, bytes, n, s);
	}
	else
	{
		char *msg;

		rsrc_gaddr(R_STRING, (w->nvisible == 1) ? MISINGUL : MIPLURAL, &s);
		rsrc_gaddr(R_STRING, MITEMS, &msg);
		sprintf(w->info, msg, w->usedbytes, w->nvisible, s);
	}

	xw_set((WINDOW *) w, WF_INFO, w->info);
}

static void dir_title(DIR_WINDOW *w)
{
	long fl, pl, columns;
	const char *h, *s;

	if ((columns = (long) (w->scolumns - 4)) > 70L)
		columns = 70L;

	if ((fl = strlen(w->fspec)) < columns)
	{
		pl = strlen(w->path);

		if ((fl + pl) < columns)
			h = w->path;
		else
		{
			h = w->path + (pl + fl - columns);
			h = ((s = strchr(h, '\\')) != NULL) ? s + 1 : w->path + pl;
		}
		make_path(w->title, h, w->fspec);
	}
	else
		strcpy(w->title, w->fspec);

	xw_set((WINDOW *) w, WF_NAME, w->title);
}

static void dir_free_buffer(DIR_WINDOW *w)
{
	long i;
	NDTA *b = w->buffer;

	if (b != NULL)
	{
		for (i = 0; i < w->nfiles; i++)
			free(b[i].name);
		x_free(b);
		w->buffer = NULL;
	}
}

static void set_visible(DIR_WINDOW *w)
{
	NDTA *b = w->buffer;
	long i;
	int n = 0;

	if (b == NULL)
		return;

	for (i = 0; i < w->nfiles; i++)
	{
		b->selected = FALSE;
		b->newstate = FALSE;

		/* DjV 004 261202 ---vvv--- */
		
		/* substituted "2" and "4" with FA_HIDDEN and FA_SYSTEM */
		/* added bit4 =16= directory:  FA_SUBDIR */

		if (   (   (options.attribs  & FA_HIDDEN) != 0
		        || (b->attrib.attrib & FA_HIDDEN) == 0
		       )
		    && (   (options.attribs  & FA_SYSTEM) != 0
		        || (b->attrib.attrib & FA_SYSTEM) == 0
		       )
		    && (   (options.attribs  & FA_SUBDIR) != 0
		        || (b->attrib.attrib & FA_SUBDIR) == 0
		       )
		    && (   (options.attribs  & FA_PARDIR) != 0  /* DjV 004 300103 */
		        || (b->attrib.attrib & FA_PARDIR) == 0	/* DjV 004 300103 */ 
		       )
		    && (   (b->attrib.mode & S_IFMT)       == S_IFDIR
			    || cmp_wildcard(b->name, w->fspec) == TRUE
			   )
		   )
							/* DjV 004 261202 ---^^^--- */
		{
			b->visible = TRUE;
			n++;
		}
		else
			b->visible = FALSE;

		b++;
	}
	w->nvisible = n;
}

void xattr_to_fattr(XATTR *xattr, FATTR *fattr)
{
	fattr->mode = xattr->mode;
	fattr->size = xattr->size;
	fattr->mtime = xattr->mtime;
	fattr->mdate = xattr->mdate;
	fattr->attrib = xattr->attr;
}

/* Funktie voor het copieren van een dta naar de buffer van een
   window. */

static int copy_DTA(NDTA *dest, char *name, XATTR *src, int index, bool link)	/* HR 130203: link */
{
	long l;
	char *h;

	dest->index = index;
	dest->link  = link;				/* HR 130203: handle links */

	if ((src->mode & S_IFMT) == S_IFDIR)
		dest->item_type = (strcmp(name, prevdir) == 0) ? ITM_PREVDIR : ITM_FOLDER;
	else
		dest->item_type = ITM_FILE;

	xattr_to_fattr(src, &dest->attrib);
	dest->icon = icnt_geticon(name, dest->item_type);

	if ((h = malloc((l = strlen(name)) + 1L)) != NULL)
	{
		strcpy(h, name);
		dest->name = h;
		return (int) l;
	}
	else
		return ENSMEM;
}

/* Funktie voor het inlezen van een directory. Het resultaat is
   ongelijk nul als er een fout is opgetreden. De directory wordt
   gesorteerd. */

static int read_dir(DIR_WINDOW *w)
{
	NDTA *b;
	int error = 0, bufsiz, maxl = 0;
	long size, free_mem, length, n;
	XATTR attr = {0};					/* HR 050203 */
	char name[256];
	XDIR *dir;

	n = 0;
	length = 0;

	if (w->buffer != NULL)
		dir_free_buffer(w);

	free_mem = (long) x_alloc(-1L) - 16384L;
	free_mem = free_mem - free_mem % sizeof(NDTA);

	w->buffer = ((size = min(2000L * sizeof(NDTA), free_mem)) > 0) ? x_alloc(size) : NULL;

	if (w->buffer != NULL)
	{
		b = w->buffer;
		bufsiz = (int) (size / sizeof(NDTA));

		dir = x_opendir(w->path, &error);

		if (dir)
		{
#if _MINT_
			w->fs_type = dir->type;		/* HR 151102: Need to know the filesystem type elsewhere. */
#endif
			while (error == 0)
			{
				error = x_xreaddir(dir, name, 256, &attr);

				if (error == 0)
				{
					bool link = false;

					if (n == bufsiz)
					{
						alert_printf(1, MDIRTBIG);
						break;
					}

/* HR 130203: Handle links.  vvvvvvvvvvv  */

					if ((attr.mode & S_IFMT) == (unsigned int)S_IFLNK)
					{
/*						boolean x_inq_xfs(const char *path);
*/						char fulln[256];
						strcpy(fulln, dir->path);
						strcat(fulln, name);
				/*		alert_msg(" %s ", fulln); */
						x_attr(0, fulln, &attr);
						
						link = true;
					}

/* HR 130203: Handle links.  ^^^^^^^^^^^  */

					if (   (strcmp(".", name) != 0)
					    && ((error = copy_DTA(&b[n], name, &attr, n, link)) >= 0)
					   )
					{
						length += attr.size;
						if (error > maxl)
							maxl = error;
						error = 0;
						n++;
					}
				}
			}
			x_closedir(dir);
		}

		if ((error == ENMFIL) || (error == EFILNF))
			error = 0;
	}
	else
		error = ENSMEM;

	w->nfiles = (int) n;
	w->usedbytes = length;
	w->namelength = maxl;

	if (error != 0)
	{
		dir_free_buffer(w);
		w->nfiles = 0;
		w->nvisible = 0;
		w->usedbytes = 0;
	}
	else
	{
		set_visible(w);
		sort_directory(b, (int) n, options.sort);
		if (n != bufsiz)
			x_shrink(w->buffer, max(n, 1) * sizeof(NDTA));
	}

	return error;
}

static void dir_setinfo(DIR_WINDOW *w)
{
	w->nselected = 0;
	w->refresh = FALSE;

	calc_nlines(w);

	dir_title(w);
	dir_info(w, 0, 0L);
	set_sliders(w);
}

/* Funktie voor het inlezen van een directory in de buffer van een
   window. */

static int dir_read(DIR_WINDOW *w)
{
	int error;

	error = read_dir(w);
	dir_setinfo(w);

	return error;
}

static void dir_refresh_wd(DIR_WINDOW *w)
{
	int error;

	graf_mouse(HOURGLASS, NULL);
	if ((error = dir_read(w)) != 0)
		xform_error(error);
	graf_mouse(ARROW, NULL);
	dir_draw(w, TRUE);
	wd_reset((WINDOW *) w);
}

static void dir_readnew(DIR_WINDOW *w)
{
	w->py = 0;
	dir_refresh_wd(w);
}

/*
 * Funktie om te controleren of het pad van file fname gelijk is
 * aan path.
 */

static boolean cmp_path(const char *path, const char *fname)
{
	const char *h;
	long l;

	if ((h = strrchr(fname, '\\')) == NULL)
		return FALSE;
	l = h - fname;
	if (isroot(path) == TRUE)
		l++;
	if (strlen(path) != l)
		return FALSE;
	return (strncmp(path, fname, l) != 0) ? FALSE : TRUE;
}

#pragma warn -par

static void dir_set_update(WINDOW *w, wd_upd_type type, const char *fname1, const char *fname2)
{
	DIR_WINDOW *dw;

	dw = (DIR_WINDOW *) w;

	if (type == WD_UPD_ALLWAYS)
		dw->refresh = TRUE;
	else
	{
		if (cmp_path(dw->path, fname1) != FALSE)
			dw->refresh = TRUE;

		if ((type == WD_UPD_MOVED) && (cmp_path(dw->path, fname2) != FALSE))
			dw->refresh = TRUE;
	}
}

#pragma warn .par

static void dir_do_update(WINDOW *w)
{
	if (((DIR_WINDOW *) w)->refresh == TRUE)
		dir_refresh_wd((DIR_WINDOW *) w);
}

/* DJV 029 160203 ---vvv--- */
/* for unconditional refresh */
void dir_always_update(WINDOW *w)
{
	dir_refresh_wd( (DIR_WINDOW *)w );
}
/* DjV 029 160203 ---^^^--- */

/********************************************************************
 *																	*
 * Funktie voor het zetten van de mode van een window.				*
 *																	*
 ********************************************************************/

#pragma warn -par

static void dir_disp_mode(WINDOW *w, int mode)
{
	RECT work;

	xw_get(w, WF_WORKXYWH, &work);

	calc_rc((DIR_WINDOW *) w, &work);
	calc_nlines((DIR_WINDOW *) w);
	set_sliders((DIR_WINDOW *) w);
	do_redraw((DIR_WINDOW *) w, &work, TRUE);
}

#pragma warn .par

/********************************************************************
 *																	*
 * Funkties voor het zetten van het file mask van een window.		*
 *																	*
 ********************************************************************/

static void dir_newdir(DIR_WINDOW *w)
{
	set_visible(w);
	wd_reset((WINDOW *) w);
	dir_setinfo(w);
	sort_directory(w->buffer, w->nfiles, options.sort);
	dir_draw(w, TRUE);
}

static void dir_filemask(WINDOW *w)
{
	char *newmask;

	if ((newmask = wd_filemask(((DIR_WINDOW *) w)->fspec)) != NULL)
	{
		free(((DIR_WINDOW *) w)->fspec);
		((DIR_WINDOW *) w)->fspec = newmask;
		dir_newdir((DIR_WINDOW *) w);
	}
}

/********************************************************************
 *																	*
 * Funkties voor het zetten van de file attributen van een window.	*
 *																	*
 ********************************************************************/

#pragma warn -par

static void dir_attrib(WINDOW *w, int attrib)
{
	set_visible((DIR_WINDOW *) w);
	dir_newdir((DIR_WINDOW *) w);
}

static void dir_fields(WINDOW *w, int attrib)
{
	set_visible((DIR_WINDOW *) w);
	dir_newdir((DIR_WINDOW *) w);
}

#pragma warn .par

/********************************************************************
 *																	*
 * Funktie voor het zetten van de iconen van objecten in een 		*
 * window.															*
 *																	*
 ********************************************************************/

static void dir_seticons(WINDOW *w)
{
	NDTA *b;
	long i, n;

	b = ((DIR_WINDOW *) w)->buffer;
	n = ((DIR_WINDOW *) w)->nfiles;

	for (i = 0; i < n; i++)
		b[i].icon = icnt_geticon(b[i].name, b[i].item_type);

	if (options.mode != TEXTMODE)
		dir_draw((DIR_WINDOW *) w, FALSE);
}

/********************************************************************
 *																	*
 * Funktie voor het maken van een nieuwe directory.					*
 *																	*
 ********************************************************************/

static void dir_newfolder(WINDOW *w)
{
	int button, error;
	char *nsubdir;
	LNAME name;			/* HR 240203: hopefully the last too short name repaired. */
	DIR_WINDOW *dw;

	dw = (DIR_WINDOW *) w;

	rsc_title(newfolder, NDTITLE, DTNEWDIR);

	*dirname = 0;

	button = xd_dialog(newfolder, DIRNAME);

	if ((button == NEWDIROK) && (*dirname))
	{
		cv_formtofn(name, dirname);

		if ((error = x_checkname(dw->path, name)) == 0)
		{
			if ((nsubdir = fn_make_path(dw->path, name)) != NULL)
			{
				graf_mouse(HOURGLASS, NULL);
				error = x_mkdir(nsubdir);
				graf_mouse(ARROW, NULL);

				if (error == EACCDN)
					alert_printf(1, MDEXISTS);
				else
					xform_error(error);

				if (error == 0)
				{
					wd_set_update(WD_UPD_COPIED, nsubdir, NULL);
					wd_do_update();
				}
				free(nsubdir);
			}
		}
		else
			xform_error(error);
	}
}

/********************************************************************
 *																	*
 * Hulp funkties.													*
 *																	*
 ********************************************************************/

static void dir_draw(DIR_WINDOW *w, boolean message)
{
	RECT area;

	xw_get((WINDOW *) w, WF_CURRXYWH, &area);

	if (message)
		xw_send_redraw((WINDOW *) w, &area);
	else
		do_redraw(w, &area, FALSE);
}

/* Funktie voor het berekenen van het aantal rijen en kolommen in
   een window. */

static void calc_rc(DIR_WINDOW *w, RECT *work)
{
	if (options.mode == TEXTMODE)
	{
		w->rows     = (work->h +  dir_font.ch - 1) / (dir_font.ch + DELTA);
		w->columns  = (work->w +  dir_font.cw - 1) / dir_font.cw;
		w->nrows    =  work->h / (dir_font.ch + DELTA);
		w->ncolumns =  work->w /  dir_font.cw;
	}
	else
	{
		w->rows     = (work->h + ICON_H - 1 /* - YOFFSET*/ ) / ICON_H;
		w->columns  =  work->w / ICON_W;
		w->nrows    = (work->h - YOFFSET) / ICON_H;
		w->ncolumns =  w->columns;
	}

	w->scolumns = work->w / screen_info.fnt_w;
}

/* Funktie voor het berekenen van het totale aantal regels in een
   window. */

static void calc_nlines(DIR_WINDOW *w)
{
	if (options.mode == TEXTMODE)
		w->nlines = w->nvisible;
	else
	{
		int columns = w->columns;

		w->nlines = (w->nvisible + columns - 1) / columns;
	}
}

/* Funktie voor het zetten van de default grootte */

static void dir_set_defsize(WINFO *w)
{
	RECT border, work;

	xw_get((WINDOW *) w->dir_window, WF_CURRXYWH, &border);
	xw_get((WINDOW *) w->dir_window, WF_WORKXYWH, &work);

	w->x = border.x - screen_info.dsk.x;
	w->y = border.y - screen_info.dsk.y;
	w->w = work.w / screen_info.fnt_w;
	w->h = work.h / (screen_info.fnt_h + DELTA);
}

/* Funktie die uit opgegeven grootte de werkelijke grootte van het
   window berekent. */

static void dir_wsize(DIR_WINDOW *w, RECT *input, RECT *output)
{
	RECT work;
	int fw, fh;

	fw = screen_info.fnt_w;
	fh = screen_info.fnt_h + DELTA;

	xw_calc(WC_WORK, DFLAGS, input, &work, NULL);

	work.x += fw / 2;
	work.w += fw / 2;
	work.h += fh / 2 - DELTA;

	work.x -= (work.x % fw);
	work.w -= (work.w % fw);
	work.h -= (work.h % fh) - DELTA;

	work.w = min(work.w, dmax.w);
	work.h = min(work.h, dmax.h);

	xw_calc(WC_BORDER, DFLAGS, &work, output, NULL);

	calc_rc(w, &work);
	calc_nlines(w);
}

/* Funktie voor het bereken van de grootte van een window uit de in
   w opgeslagen grootte. */

static void dir_calcsize(WINFO *w, RECT *size)
{
	if (w->flags.fulled == 1)
	{
		RECT high = screen_info.dsk;
		if (options.mode == TEXTMODE)
		{
			high.x = w->x + screen_info.dsk.x;
			/* high.w = w->w * screen_info.fnt_w;  DjV 012 261202 */

			/* DjV 012 271202 050103 ---vvv---  */

			/*
			 * Calculate length of directory line 
			 * taking into account directory font size;
			 * calculate width of "fulled" window so as to display all fields
			 * (seems that left BORDERS=2*2 is -not- in directory font units but
			 * in default system font units)
			 * For some unclear reason it looks better if 
			 * two char width more are added (vert.slider width?)
			 */
     	
			high.w = linelength(w->dir_window) * dir_font.cw + (BORDERS + 2) * screen_info.fnt_w; 

			/*
			 * Calculate vertical size of the fulled directory window;
			 * if there are not many items, add two empty lines at the end;
			 * otherwise, clipping will be performed elsewhere;
			 * below: 5= 2 empty lines + 3 lines for win.header and slider?
			 */

			/* DjV 012 170103 removed vertical operation- doesn't seem useful 
			high.h = (w->dir_window->nlines + 5 ) * ( dir_font.ch + DELTA );
			*/

			/* DjV 012 271202 050103 ---^^^--- */

		}
		dir_wsize(w->dir_window, &high, size);
	}
	else
	{
		RECT def, border;

		def.x = w->x + screen_info.dsk.x;
		def.y = w->y + screen_info.dsk.y;
		def.w = w->w * screen_info.fnt_w;	/* hoogte en breedte van het werkgebied. */
		def.h = w->h * (screen_info.fnt_h + DELTA) + DELTA;

		/* Bereken hoogte en breedte van het window */
		xw_calc(WC_BORDER, DFLAGS, &def, &border, NULL);

		border.x = def.x;
		border.y = def.y;

		dir_wsize(w->dir_window, &border, size);
	}
}

/********************************************************************
 *																	*
 * Functions for setting the sliders.								*
 *																	*
 ********************************************************************/

/* Calculate the length of a line in a window. In the TOS version it
   returns a constant, in the MiNT version it returns a value
   depending on the length of the longest filename. */

/* DjV 010 261202 Length of line depends on which fields are shown */

#pragma warn -par

static int linelength(DIR_WINDOW *w)
{

	int l; /* DjV 010 261202: l=length of filename             */
	int f; /* DjV 010 261202: f=length of other visible fields */
  
	if (w->fs_type)				/* HR 151102, 021202 */

	/*	return TOSITEMLEN; DjV 010 261202 */
		l = 12; /* DjV 010 261202 TOS: length of filename */
	else
	{
	/* 	int l; DjV 010 261202 */
	
		if (w->namelength < MINLENGTH)
			l = MINLENGTH;
		else if (w->namelength > MAXLENGTH)
			l = MAXLENGTH;
		else
			l = w->namelength;
	
	/*	return ITEMLEN + l; DjV 010 261202 */
	}
	
	/* DjV 010 261202 ---vvv--- Calculate length of fields */

	/* 
	 * Beside filename there will always be:
	 * 3 spaces for the char marking directory
	 * 2 spaces separating filename from the rest
	 * additional 2 spaces separator after each field
	 * below should be: f = 5 = 3+2, but for some unclear reason
	 * hor.slider works better if one char less is specified here
	 * left and right border are -not- included in calculation
	 */
	  
	f = 4;
	
	if ( options.V2_2.fields & WD_SHSIZ ) f = f + SIZELEN + 2;	/* size: 8 char + 2 sep */
	if ( options.V2_2.fields & WD_SHDAT ) f = f + 10; 			/* date: 8 char + 2 sep. */
	if ( options.V2_2.fields & WD_SHTIM ) f = f + 10; 			/* time: 8 char + 2 sep. */
	if ( options.V2_2.fields & WD_SHATT )             			/* attributes: depending on fs */
	{
#if _MINT_
		if ( mint  && ( w->fs_type == 0 )  )
			f = f + 12;		/* other (i.e.mint) filesystem: attributes 10 char + 2 sep. */
		else
#endif
			f = f + 7;			/* TOS/FAT filesystem: attributes 5 char + 2 sep. */
	} 
	
	return f + l;
	
	/* DjV 010 261202 ---^^^--- */
	
}

#pragma warn .par

/* Funktie voor het zetten van de grootte van de verticale
   slider. */

static void set_vslsize(DIR_WINDOW *w)
{
	long p, lines, wlines;

	wlines = w->nrows;
	lines = w->nlines;

	w->py = (lines < wlines) ? 0 : (int) min(w->py, lines - wlines);
	p = (lines > wlines) ? (wlines * 1000L) / lines : 1000;
	xw_set((WINDOW *) w, WF_VSLSIZE, (int) p);
}

/* Funktie voor het zetten van de positie van de verticale
   slider. */

static void set_vslpos(DIR_WINDOW *w)
{
	long h, lines, wlines;
	int pos;

	wlines = w->nrows;
	lines = w->nlines;

	w->py = (lines < wlines) ? 0 : (int) min(w->py, lines - wlines);
	h = lines - wlines;
	pos = (h > 0) ? (int) ((1000L * w->py) / h) : 0;
	xw_set((WINDOW *) w, WF_VSLIDE, pos);
}

/* Funktie voor het zetten van de grootte van de horizontale
   slider. */

static void set_hslsize(DIR_WINDOW *w)
{
	int p, wwidth, lwidth;

	if (options.mode == TEXTMODE)
	{
		wwidth = w->ncolumns;				/* Width of the window. */
		lwidth = linelength(w) + BORDERS;	/* Total width of a line. */

		w->px = (lwidth < wwidth) ? 0 : min(w->px, lwidth - wwidth);
		p = (lwidth > wwidth) ? (int) (((long) wwidth * 1000L) / (long) lwidth) : 1000;
	}
	else
		p = 1000;

	xw_set((WINDOW *) w, WF_HSLSIZE, p);
}

/* Funktie voor het zetten van de positie van de horizontale
   slider. */

static void set_hslpos(DIR_WINDOW *w)
{
	int wwidth, pos, lwidth;
	long h;

	if (options.mode == TEXTMODE)
	{
		wwidth = w->ncolumns;				/* Width of the window. */
		lwidth = linelength(w) + BORDERS;	/* Total width of a line. */

		w->px = (lwidth < wwidth) ? 0 : min(w->px, lwidth - wwidth);
		h = lwidth - wwidth;
		pos = (h > 0) ? (int) ((1000L * (long) w->px) / h) : 0;
	}
	else
		pos = 0;

	xw_set((WINDOW *) w, WF_HSLIDE, pos);
}

/* Funktie voor het zetten van alle sliders van een window. */

static void set_sliders(DIR_WINDOW *w)
{
	set_hslsize(w);
	set_hslpos(w);
	set_vslsize(w);
	set_vslpos(w);
}

/********************************************************************
 *																	*
 * Functies voor het tekenen van de inhoud van een directorywindow.	*
 *																	*
 ********************************************************************/

/*
 * Bereken de rechthoek die de te tekenen tekst omsluit.
 *
 * Parameters:
 *
 * tw		- pointer naar window
 * item		- regelnummer
 * r		- resultaat
 * work		- RECT structuur met de grootte van het werkgebied van het
 *			  window.
 */

static void dir_comparea(DIR_WINDOW *dw, int item, RECT *r, RECT *work)
{
	int offset, delta;

	if (dw->px > TOFFSET)
	{
		offset = dw->px - TOFFSET;
		r->x = work->x;
	}
	else
	{
		offset = 0;
		r->x = work->x + (TOFFSET - dw->px) * dir_font.cw;
	}
	r->y = DELTA + work->y + (int) (item - dw->py) * (dir_font.ch + DELTA);
	r->w = dir_font.cw * (linelength(dw) - offset);
	if ((delta = r->x + r->w - work->x - work->w) > 0)
		r->w -= delta;
	r->h = dir_font.ch;
}

/*
 * Convert a time to a string.
 *
 * Parameters:
 *
 * tstr		- destination string
 * time		- current time in GEMDOS format
 *
 * this string is 8 characters long 
 *
 * Result: Pointer to the end of tstr.
 */

static char *timestr(char *tstr, unsigned int time)
{
	unsigned int sec, min, hour, h;

	sec = (time & 0x1F) * 2;
	h = time >> 5;
	min = h & 0x3F;
	hour = (h >> 6) & 0x1F;
	digit(tstr, hour);
	tstr[2] = ':';
	digit(tstr + 3, min);
	tstr[5] = ':';
	digit(tstr + 6, sec);

	return tstr + 8;
}

/*
 * Convert a date to a string.
 *
 * Parameters:
 *
 * tstr		- destination string
 * date		- current date in GEMDOS format
 *
 * this string is 8 characters long 
 *
 * Result: Pointer to the end of tstr.
 */

static char *datestr(char *tstr, unsigned int date)
{
	unsigned int day, mon, year, h;

	day = date & 0x1F;
	h = date >> 5;
	mon = h & 0xF;
	year = (((h >> 4) & 0x7F) + 80) % 100;
	digit(tstr, day);
	tstr[2] = '-';
	digit(tstr + 3, mon);
	tstr[5] = '-';
	digit(tstr + 6, year);

	return tstr + 8;
}

/*
 * Macros used in dir_line.
 * FILL_UNTIL fills a string until a counter reaches a certain value.
 */

#define FILL_UNTIL(dest, i, value)			while (i < (value))	\
											{					\
												*dest++ = ' ';	\
												i++;			\
											}

/*
 * Make a string with the contents of a line in a directory window.
 */

/* static void dir_line(DIR_WINDOW *dw, char *s, int item) DjV 031 150203 */
static void dir_line(DIR_WINDOW *dw, char *s, int item, boolean clip) /* DJV 031 150203 */
{
	NDTA *h;
	char *d, t[16];
	const char *p;
	int i, lwidth;
	int parent;    /* DjV 010 261202 flag that this is a .. (parent) dir */

	lwidth = linelength(dw);
	parent= FALSE;  /* DjV 010 261202 */

	if (item < dw->nvisible)
	{
		h = &dw->buffer[(long) item];
		d = s; /* beginning of a directory line */

		*d++ = ' ';
		*d++ = (h->attrib.mode & S_IFMT) == S_IFDIR ? '\007' : ' '; /* dir mark */
		*d++ = ' ';

		p = h->name;
		i = 0;

#if _MINT_
		if (mint && dw->fs_type == 0)		/* HR 151102 */
		{
			while ((*p) && (i < MAXLENGTH))
			{
				*d++ = *p++;
				i++;
			}

	        FILL_UNTIL(d, i, dw->namelength)		/* HR 050203: use correct value. */
		}
		else
#endif
		{	/* not mint fs */
			/* Copy the filename. Handle '..' as a special case. */
	
			if (strcmp(h->name, prevdir))
			{
				/* Copy the filename, until the start of the extension
				   is found. */
	
				while ((*p) && (*p != '.'))
				{
					*d++ = *p++;
					i++;
				}
	
				FILL_UNTIL(d, i, 9);
	
				/* Copy the extension. */
	
				if (*p++ == '.')
				{
					while (*p)
					{
						*d++ = *p++;
						i++;
					}
				}
			}
			else
			{
				/* '..'. Just copy. */
	
				parent= TRUE; /* DjV 010 261202 */

				while (*p)
				{
					*d++ = *p++;
					i++;
				}
			}
	
			FILL_UNTIL(d, i, 12);

		}  /* mint fs? */

		*d++ = ' '; /* DjV 010 261202 always separate filename from other fields */
		*d++ = ' '; /* DjV 010 261202 */

		if ( options.V2_2.fields & WD_SHSIZ )	/* DjV 010 261202 - show file size? */
		{									/* DjV 010 261202 */
    
			if ((h->attrib.mode & S_IFMT) != S_IFDIR) /* this is not a subdirectory */
			{
				int l;

				ltoa(h->attrib.size, t, 10); /* File size to string      */
				l = (int) strlen(t);         /* how long is this string? */
				p = t;
				i = 0;
				/* FILL_UNTIL(d, i, 8 - l);         DjV 010 261202 */
				FILL_UNTIL(d, i, SIZELEN - l);   /* DjV 010 261202 */
				while (*p)
					*d++ = *p++;
			}
			else
			{
				i = 0;
				/*	FILL_UNTIL(d, i, 8);      DjV 010 261202 */
				FILL_UNTIL(d, i, SIZELEN); /* DjV 010 261202 */

			}

			*d++ = ' '; /* separate size from the next fields */
			*d++ = ' ';
		  
		} /* DjV 010 261202 */

		if ( options.V2_2.fields & WD_SHDAT )  	/* DjV 010 261202 */
		{									/* DjV 010 261202 */
			if ( !parent ) 	/* DjV 010 261202 don't show meaningless date for parent folder */
			{				/* DjV 010 261202 */
				d = datestr(d, h->attrib.mdate);	/* HR 151102: date first */
				*d++ = ' ';
				*d++ = ' ';
			/* DjV 010 261202 ---vvv--- */
			}
			else
			{                         
				i=0;                       
				FILL_UNTIL ( d, i, 10 );     
			}
			/* DjV 010 261202 ---^^^--- */
      
		} /* DjV 010 261202 */  

		if ( options.V2_2.fields & WD_SHTIM )	/* DjV 010 261202 */
		{									/* DjV 010 261202 */
			if ( !parent ) 	/* DjV 010 261202 don't show meaningless time for parent folder */
			{				/* DjV 010 261202 */
				d = timestr(d, h->attrib.mtime);
				*d++ = ' ';
				*d++ = ' ';
			/* DjV 010 261202 ---vvv--- */
			}
			else
			{                         
				i=0;                        
				FILL_UNTIL ( d, i, 10 );     
			}								
			/* DjV 010 261202 ---^^^--- */

		} /* DjV 010 261202 */

		if ( options.V2_2.fields & WD_SHATT ) 	/* DjV 010 261202 */
		{									/* DjV 010 261202 */
#if _MINT_
			if (mint && dw->fs_type == 0)		/* HR 151102 */
			{
				switch(h->attrib.mode & S_IFMT)
				{
					case S_IFDIR :
						*d++ = 'd';
						break;
					case S_IFREG :
						*d++ = '-';
						break;
					case S_IFCHR :
						*d++ = 'c';
						break;
					case S_IFIFO :
						*d++ = 'p';
						break;
					case S_IFLNK :
						*d++ = 'l';
						break;
					case S_IMEM :
						*d++ = 'm';
						break;
					default : 
						*d++ = '?';
						break;
				}
	
				*d++ = (h->attrib.mode & S_IRUSR) ? 'r' : '-';
				*d++ = (h->attrib.mode & S_IWUSR) ? 'w' : '-';
				*d++ = (h->attrib.mode & S_IXUSR) ? 'x' : '-';
				*d++ = (h->attrib.mode & S_IRGRP) ? 'r' : '-';
				*d++ = (h->attrib.mode & S_IWGRP) ? 'w' : '-';
				*d++ = (h->attrib.mode & S_IXGRP) ? 'x' : '-';
				*d++ = (h->attrib.mode & S_IROTH) ? 'r' : '-';
				*d++ = (h->attrib.mode & S_IWOTH) ? 'w' : '-';
				*d++ = (h->attrib.mode & S_IXOTH) ? 'x' : '-';
			} /* mint ? */
			else
#endif
			{
				*d++ = ((h->attrib.mode & S_IFMT) == S_IFDIR) ? 'd' : '-';
				*d++ = (h->attrib.attrib & 0x04) ? 's' : '-';
				*d++ = (h->attrib.attrib & 0x02) ? 'h' : '-';
				*d++ = (h->attrib.attrib & 0x01) ? '-' : 'w';
				*d++ = (h->attrib.attrib & 0x20) ? 'a' : '-';
			}

			*d++ = ' ';
			*d++ = ' ';
		
		} /* DjV 010 261202 */
		
		*d = 0;
	}
	else
	{
		/* This should never happen. Line is not visible. Return
		   a string filled with spaces. */

		for (i = 0; i < lwidth; i++)
			s[i] = ' ';
		s[lwidth] = 0;
	}

	/* Clip the string on the rigth border of the window. */

	if ( clip )	/* DjV 031 150203 */
		s[min(dw->columns + dw->px - 2, lwidth)] = 0;
}

/* DjV 029 120203 ---vvv--- */
/* 
 * routine get_dir_line conveniently obtains some information 
 * needed for hardcopy directory printout. Needed because
 * DIR_WINDOW is not known outside DIR.C, and so that it does 
 * have to be defined in header file
 *
 * item >= 0 : get directory line #item;
 * item = -1 : get window title
 * item = -2 : get window info line
 * note: routine actually copies the string to destination
 */
 
void get_dir_line
(
	WINDOW *dw,	/* pointer to window structure */ 
	char *str,	/* output string */ 
	int item	/* item number */
)
{
	if ( item >= 0 )				/* get directory line */
		dir_line ( (DIR_WINDOW *)dw, str, item, FALSE );
	else if ( item == -1 )			/* get window title */
		strcpy(str, ((DIR_WINDOW *)dw)->title);
	else if ( item == -2 )			/* get window info line */
		strcpy(str, ((DIR_WINDOW *)dw)->info);
}
/* DjV 029 120203 ---^^^--- */

static void dir_prtchar(DIR_WINDOW *dw, int column, int item, RECT *area, RECT *work)
{
	RECT r, in;
	char s[256];
	int c = column - dw->px;

	/* dir_line(dw, s, item); DjV 031 150203 */
	dir_line(dw, s, item, TRUE); /* DjV 031 150203 */

	r.x = work->x + c * dir_font.cw;
	r.y = work->y + DELTA + (int) (item - dw->py) * (dir_font.ch + DELTA);
	r.w = dir_font.cw;
	r.h = dir_font.ch;

	if (xd_rcintersect(area, &r, &in) == TRUE)
	{
		if ((column >= 2) && (column < linelength(dw) + 2))
		{
			bool link = dw->buffer[(long)item].link;		/* HR 130203 */

			s[column - 1] = 0;
			pclear(&r); 						/* DJV 011 030203 */
			vswr_mode( vdi_handle, MD_TRANS); 	/* DjV 011 030203 */

			if (link)
				vst_effects(vdi_handle, ulined|italic);		/* HR 130203 */

			v_gtext(vdi_handle, r.x, r.y, &s[column - 2]);

			if (link)
				vst_effects(vdi_handle, 0);		/* HR 130203 */

			if ((item < dw->nlines) && (dw->buffer[(long) item].selected == TRUE))
				invert(&in);
		}
		else
			pclear(&in);  /* DjV 011 030203 */
	}
}

/********************************************************************
 *																	*
 * Funkties voor het afdrukken in iconmode.							*
 *																	*
 ********************************************************************/

static OBJECT *make_tree(DIR_WINDOW *dw, int sl, int lines, boolean smode,
						 RECT *work)
{
	int columns, yoffset, row;
	long n, start, i;
	OBJECT *obj;
	CICONBLK *cicnblk;

	columns = dw->columns;

	n = columns * lines;
	start = sl * columns;
	if ((start + n) > dw->nvisible)
		n = max(dw->nvisible - start, 0);

	if ((obj = malloc((n + 1) * sizeof(OBJECT) + n * sizeof(CICONBLK))) == NULL)		/* HR 151102: ciconblk (the largest) */
	{
		xform_error(ENSMEM);
		return NULL;
	}

	cicnblk = (CICONBLK *) & obj[n + 1];

	if ((row = (sl - dw->py) * ICON_H) == 0)
		yoffset = YOFFSET;
	else
		yoffset = 0;

	obj[0].ob_next = -1;
	obj[0].ob_head = -1;
	obj[0].ob_tail = -1;
	obj[0].ob_type = (smode == FALSE) ? G_BOX : G_IBOX;
	obj[0].ob_flags = NORMAL;
	obj[0].ob_state = NORMAL;
	obj[0].ob_spec.obspec.framesize = 0;
	
	/* DjV 011 251202 ---vvv--- 
	obj[0].ob_spec.obspec.interiorcol = 0;
	obj[0].ob_spec.obspec.fillpattern = 7;
	*/
	/* this works only for icon mode? */
	obj[0].ob_spec.obspec.interiorcol = options.V2_2.win_color;
	obj[0].ob_spec.obspec.fillpattern = options.V2_2.win_pattern;
	/* DjV 011 251202 ---^^^--- */
	
	obj[0].ob_spec.obspec.textmode = 1;
	obj[0].r.x = work->x;
	obj[0].r.y = row + work->y + YOFFSET - yoffset;
	obj[0].r.w = work->w;
	obj[0].r.h = lines * ICON_H;

	for (i = 0; i < n; i++)
	{
		int icon_no;
		NDTA *h = &dw->buffer[start + i];
		boolean selected;

		icon_no = h->icon;

		if (smode == TRUE)
		{
			if (h->selected == h->newstate)
				continue;
			selected = h->newstate;
		}
		else
			selected = h->selected;

		obj[i + 1].ob_head = -1;
		obj[i + 1].ob_tail = -1;
		obj[i + 1].ob_type = icons[icon_no].ob_type;	/* HR 151102 */
		obj[i + 1].ob_flags = NONE;
		obj[i + 1].ob_state = (selected == FALSE) ? NORMAL : SELECTED;
		obj[i + 1].ob_spec.ciconblk = &cicnblk[i];		/* HR 151102 */
		obj[i + 1].r.x = ((int) i % columns) * ICON_W + XOFFSET;
		obj[i + 1].r.y = ((int) i / columns) * ICON_H + yoffset;
		obj[i + 1].r.w = ICON_W;
		obj[i + 1].r.h = ICON_H;

		cicnblk[i] = *icons[icon_no].ob_spec.ciconblk;

		cicnblk[i].monoblk.ib_ptext = (char *) h->name;
		cicnblk[i].monoblk.ib_char &= 0xFF00;
		cicnblk[i].monoblk.ib_char |= 0x20;

		objc_add(obj, 0, (int) i + 1);
	}

	return obj;
}

static void draw_tree(OBJECT *tree, RECT *clip)
{
	objc_draw(tree, ROOT, MAX_DEPTH, clip->x, clip->y, clip->w, clip->h);
}

static void draw_icons(DIR_WINDOW *dw, int sl, int lines, RECT *area,
					   boolean smode, RECT *work)
{
	OBJECT *obj;

	if ((obj = make_tree(dw, sl, lines, smode, work)) == NULL)
		return;

	draw_tree(obj, area);

	free(obj);
}

static void icn_comparea(DIR_WINDOW *dw, int item, RECT *r1, RECT *r2, RECT *work)
{
	int s, columns, x, y;
	CICONBLK *h;			/* HR 151102: ciconblk (the largest) */

	columns = dw->columns;

	s = item - columns * dw->py;
	x = s % columns;
	y = s / columns;

	if ((s < 0) && (x != 0))
	{
		y -= 1;
		x = columns + x;
	}

	x = work->x + x * ICON_W + XOFFSET;
	y = work->y + y * ICON_H + YOFFSET;

	h = icons[dw->buffer[(long) item].icon].ob_spec.ciconblk;	/* HR 151102 */

	*r1 = h->monoblk.ic;
	r1->x += x;
	r1->y += y;

	*r2 = h->monoblk.tx;
	r2->x += x;
	r2->y += y;
}

static void dir_prtline(DIR_WINDOW *dw, int line, RECT *area, RECT *work)
{
	if (options.mode == TEXTMODE)
	{
		RECT r, in, r2;
		char s[256];
		int i;

		/* dir_line(dw, s, line); DjV 031 150203 */
		dir_line(dw, s, line, TRUE); /* DJV 031 150203 */
		dir_comparea(dw, line, &r, work);

		if (xd_rcintersect(area, &r, &in) == TRUE)
		{
			bool link = false;
			if (line < dw->nvisible)
				link = dw->buffer[(long)line].link;		/* HR 130203 */

			i = (dw->px < 2) ? 0 : (dw->px - 2);

			pclear( &r );							/* DjV 011 030203 */
			vswr_mode( vdi_handle, MD_TRANS ); 		/* DjV 011 030203 */

			if (link)
				vst_effects(vdi_handle, ulined|italic);		/* HR 130203 */

			v_gtext(vdi_handle, r.x, r.y, &s[i]);
			
			if (link)
				vst_effects(vdi_handle, 0);		/* HR 130203 */

			if ((line < dw->nvisible) && (dw->buffer[(long)line].selected == TRUE))
				invert(&in);
		}
		r2.y = r.y;
		r2.h = dir_font.ch;
		if (dw->px < 2)
		{
			r2.x = work->x;
			r2.w = (2 - dw->px) * dir_font.cw;
			if (xd_rcintersect(area, &r2, &in) == TRUE)
				pclear(&r2);  /* DjV 011 030203 */
		}
		r2.x = r.x + r.w;
		r2.w = work->x + work->w - r2.x;
		if (xd_rcintersect(area, &r2, &in) == TRUE)
			pclear(&r2);  /* DjV 011 030203 */
	}
	else
		draw_icons(dw, line, 1, area, FALSE, work);
}

/* Funktie voor het opnieuw tekenen van alle regels in een window.
   Alleen voor tekst windows. */

static void dir_prtlines(DIR_WINDOW *dw, RECT *area, RECT *work)
{
	int i;

	set_txt_default(dir_font.id, dir_font.size);

	for (i = 0; i < dw->rows; i++)
		dir_prtline(dw, dw->py + i, area, work);
}

static void do_draw(DIR_WINDOW *dw, RECT *r, OBJECT *tree, boolean clr,
					boolean text, RECT *work)
{
	if (text)
	{
		if (clr == TRUE)
			/* clear(r);    DjV 011 030203 */
			pclear(r);   /* DjV 011 030203 */
		dir_prtlines(dw, r, work);
	}
	else
		draw_tree(tree, r);
}

static void do_redraw(DIR_WINDOW *w, RECT *r1, boolean clear)
{
	RECT r2, in, work;
	boolean text;
	OBJECT *obj;

	if (clip_desk(r1) == FALSE)
		return;

	xw_get((WINDOW *) w, WF_WORKXYWH, &work);

	if (options.mode == TEXTMODE)
		text = TRUE;
	else
	{
		if ((obj = make_tree(w, w->py, w->rows, FALSE, &work)) == NULL)
			return;
		text = FALSE;
	}

	xd_wdupdate(BEG_UPDATE);
	graf_mouse(M_OFF, NULL);
	xw_get((WINDOW *) w, WF_FIRSTXYWH, &r2);

	while ((r2.w != 0) && (r2.h != 0))
	{
		if (xd_rcintersect(r1, &r2, &in) == TRUE)
		{
			xd_clip_on(&in);
			do_draw(w, &in, obj, clear, text, &work);
			xd_clip_off();
		}

		xw_get((WINDOW *) w, WF_NEXTXYWH, &r2);
	}

	graf_mouse(M_ON, NULL);
	xd_wdupdate(END_UPDATE);

	if (!text)
		free(obj);
}

/********************************************************************
 *																	*
 * Funkties voor scrollen.											*
 *																	*
 ********************************************************************/

/* Funktie om een pagina naar boven te scrollen. */

static void w_pageup(DIR_WINDOW *w)
{
	int oldy;

	oldy = w->py;

	w->py -= w->nrows;

	if (w->py < 0)
		w->py = 0;

	if (w->py != oldy)
	{
		set_vslpos(w);
		dir_draw(w, FALSE);
	}
}

/* Funktie om een pagina naar beneden te scrollen. */

static void w_pagedown(DIR_WINDOW *w)
{
	int oldy;

	oldy = w->py;

	w->py += w->nrows;

	if ((w->py + w->nrows) > w->nlines)
		w->py = max(w->nlines - w->nrows, 0);

	if (w->py != oldy)
	{
		set_vslpos(w);
		dir_draw(w, FALSE);
	}
}

/* Funktie om een pagina naar links te scrollen. */

static void w_pageleft(DIR_WINDOW *w)
{
	int oldx;

	if (options.mode == TEXTMODE)
	{
		oldx = w->px;
		w->px -= w->ncolumns;
		if (w->px < 0)
			w->px = 0;

		if (w->px != oldx)
		{
			set_hslpos(w);
			dir_draw(w, FALSE);
		}
	}
}

/* Funktie om een pagina naar beneden te scrollen. */

static void w_pageright(DIR_WINDOW *w)
{
	int oldx, lwidth;

	if (options.mode == TEXTMODE)
	{
		lwidth = linelength(w) + BORDERS;
		oldx = w->px;
		w->px += w->ncolumns;

		if ((w->px + w->ncolumns) > lwidth)
			w->px = max(lwidth - w->ncolumns, 0);

		if (w->px != oldx)
		{
			set_hslpos(w);
			dir_draw(w, FALSE);
		}
	}
}

static int find_firstline(int wy, RECT *area, boolean *prev)
{
	int line, lh;

	lh = (options.mode == TEXTMODE) ? DELTA + dir_font.ch : ICON_H;
	line = (area->y - wy);
	*prev = ((line % lh) == 0) ? FALSE : TRUE;

	return (line / lh);
}

static int find_lastline(int wy, RECT *area, boolean *prev)
{
	int line, lh;

	lh = (options.mode == TEXTMODE) ? DELTA + dir_font.ch : ICON_H;
	line = (area->y + area->h - wy);
	*prev = ((line % lh) == 0) ? FALSE : TRUE;

	return ((line - 1) / lh);
}

static int find_leftcolumn(int wx, RECT *area, boolean *prev)
{
	int column;

	column = (area->x - wx);
	*prev = ((column % dir_font.cw) == 0) ? FALSE : TRUE;

	return (column / dir_font.cw);
}

static int find_rightcolumn(int wx, RECT *area, boolean *prev)
{
	int column;

	column = (area->x + area->w - wx);
	*prev = ((column % dir_font.cw) == 0) ? FALSE : TRUE;

	return ((column - 1) / dir_font.cw);
}

static void dir_prtcolumn(DIR_WINDOW *dw, int column, RECT *area, RECT *work)
{
	int i;

	for (i = 0; i < dw->rows; i++)
		dir_prtchar(dw, column, dw->py + i, area, work);
}

static void w_scroll(DIR_WINDOW *w, int type)
{
	RECT work, area, r, in, src, dest;
	int column, wx, wy, lh, line;
	boolean prev;

	switch (type)
	{
	case WA_UPLINE:
		if (w->py <= 0)
			return;
		w->py -= 1;
		break;
	case WA_DNLINE:
		if ((w->py + w->nrows) >= w->nlines)
			return;
		w->py += 1;
		break;
	case WA_LFLINE:
		if ((w->px <= 0) || (options.mode != TEXTMODE))
			return;
		w->px -= 1;
		break;
	case WA_RTLINE:
		if (((w->px + w->ncolumns) >= (linelength(w) + BORDERS)) || (options.mode != TEXTMODE))
			return;
		w->px += 1;
		break;
	default:
		return;
	}

	xw_get((WINDOW *) w, WF_WORKXYWH, &work);

	wx = work.x;
	wy = work.y;
	area = work;

	if (options.mode != TEXTMODE)
	{
		area.x += XOFFSET;
		area.w -= XOFFSET;
		area.y += YOFFSET;
		area.h -= YOFFSET;
	}

	if (clip_desk(&area) == FALSE)
		return;

	xd_wdupdate(BEG_UPDATE);

	if ((type == WA_UPLINE) || (type == WA_DNLINE))
		set_vslpos(w);
	else
		set_hslpos(w);

	graf_mouse(M_OFF, NULL);
	xw_get((WINDOW *) w, WF_FIRSTXYWH, &r);

	set_txt_default(dir_font.id, dir_font.size);

	while ((r.w != 0) && (r.h != 0))
	{
		if (xd_rcintersect(&r, &area, &in) == TRUE)
		{
			xd_clip_on(&in);

			src = in;
			dest = in;

			if ((type == WA_UPLINE) || (type == WA_DNLINE))
			{
				lh = (options.mode == TEXTMODE) ? DELTA + dir_font.ch : ICON_H;

				if (type == WA_UPLINE)
				{
					dest.y += lh;
					line = find_firstline(wy, &in, &prev);
				}
				else
				{
					src.y += lh;
					line = find_lastline(wy, &in, &prev);
				}
				line += w->py;
				dest.h -= lh;
				src.h -= lh;
			}
			else
			{
				if (type == WA_LFLINE)
				{
					dest.x += dir_font.cw;
					column = find_leftcolumn(wx, &in, &prev);
				}
				else
				{
					src.x += dir_font.cw;
					column = find_rightcolumn(wx, &in, &prev);
				}
				column += w->px;
				dest.w -= dir_font.cw;
				src.w -= dir_font.cw;
			}

			if ((src.h > 0) && (src.w > 0))
				move_screen(&dest, &src);

			if ((type == WA_UPLINE) || (type == WA_DNLINE))
			{
				dir_prtline(w, line, &in, &work);
				if (prev == TRUE)
				{
					line += (type == WA_UPLINE) ? 1 : -1;
					dir_prtline(w, line, &in, &work);
				}
			}
			else
			{
				dir_prtcolumn(w, column, &in, &work);
				if (prev == TRUE)
				{
					column += (type == WA_LFLINE) ? 1 : -1;
					dir_prtcolumn(w, column, &in, &work);
				}
			}

			xd_clip_off();
		}
		xw_get((WINDOW *) w, WF_NEXTXYWH, &r);
	}

	graf_mouse(M_ON, NULL);

	xd_wdupdate(END_UPDATE);
}

/********************************************************************
 *																	*
 * Funkties voor het openen en sluiten van windows.					*
 *																	*
 ********************************************************************/

static void dir_rem(DIR_WINDOW *w)
{
	free(w->path);
	free(w->fspec);

	dir_free_buffer(w);
	w->winfo->used = FALSE;
}

void dir_close(WINDOW *w, int mode)
{
	char *p;

	if ((isroot(((DIR_WINDOW *) w)->path) == TRUE) || mode)
	{
		xw_close(w);
		dir_rem((DIR_WINDOW *) w);
		wd_reset(NULL);
		xw_delete(w);			/* HR 131202: after dir_rem (MP) */
	}
	else
	{
		if ((p = fn_get_path(((DIR_WINDOW *) w)->path)) != NULL)
		{
			free(((DIR_WINDOW *) w)->path);
			((DIR_WINDOW *) w)->path = p;
			dir_readnew((DIR_WINDOW *) w);
		}
	}
}

/********************************************************************
 *																	*
 * Funkties voor het afhandelen van window events.					*
 *																	*
 ********************************************************************/

#pragma warn -par

static int dir_hndlkey(WINDOW *w, int scancode, int keystate)
{
	int lines;
	int result = 1;

	switch (scancode)
	{
	case CURDOWN:
		w_scroll((DIR_WINDOW *) w, WA_DNLINE);
		break;
	case CURUP:
		w_scroll((DIR_WINDOW *) w, WA_UPLINE);
		break;
	case CURLEFT:
		w_scroll((DIR_WINDOW *) w, WA_LFLINE);
		break;
	case CURRIGHT:
		w_scroll((DIR_WINDOW *) w, WA_RTLINE);
		break;
	case PAGE_DOWN:				/* HR 240103: PgUp/PgDn keys on PC keyboards (Emulators and MILAN) */
	case SHFT_CURDOWN:
		w_pagedown((DIR_WINDOW *) w);
		break;
	case PAGE_UP:				/* HR 240103: PgUp/PgDn keys on PC keyboards (Emulators and MILAN) */
	case SHFT_CURUP:
		w_pageup((DIR_WINDOW *) w);
		break;
	case SHFT_CURLEFT:
		w_pageleft((DIR_WINDOW *) w);
		break;
	case SHFT_CURRIGHT:
		w_pageright((DIR_WINDOW *) w);
		break;
	case HOME:
		((DIR_WINDOW *) w)->px = 0;
		((DIR_WINDOW *) w)->py = 0;
		set_sliders((DIR_WINDOW *) w);
		dir_draw((DIR_WINDOW *) w, FALSE);
		break;
	case SHFT_HOME:
		((DIR_WINDOW *) w)->px = 0;
		lines = ((DIR_WINDOW *) w)->nlines;
		if (((DIR_WINDOW *) w)->nrows < lines)
		{
			((DIR_WINDOW *) w)->py = lines - ((DIR_WINDOW *) w)->nrows;
			set_sliders((DIR_WINDOW *) w);
			dir_draw((DIR_WINDOW *) w, FALSE);
		}
		break;
	case ESCAPE:
		force_mediach(((DIR_WINDOW *) w)->path);
		dir_refresh_wd((DIR_WINDOW *) w);
		break;
	default:
		if ( scansh( scancode, keystate ) == options.V2_2.kbshort[MCLOSEW-MFIRST] )	/* DjV 019 110103 */
			dir_close(w, 1);
		else
		{
			int key = scancode & ~XD_SHIFT, i;

			if ((scancode & XD_SHIFT) && (key >= ALT_A) && (key <= ALT_Z))
			{
				i = key - (XD_ALT | 'A');

				if (check_drive(i))
				{
					char *newpath;

					if ((newpath = strdup("A:\\")) != NULL)
					{
						newpath[0] = (char) i + 'A';
						free(((DIR_WINDOW *) w)->path);
						((DIR_WINDOW *) w)->path = newpath;
						dir_readnew((DIR_WINDOW *) w);
					}
					else
						xform_error(ENSMEM);
				}
			}
			else
				result = 0;
		}
		break;
	}

	return result;
}

/*
 * Button event handler voor directory windows.
 *
 * Parameters:
 *
 * w			- Pointer naar window
 * x			- x positie muis
 * y			- y positie muis
 * n			- aantal muisklikken
 * button_state	- Toestand van de muisknoppen
 * keystate		- Toestand van de SHIFT, CONTROL en ALTERNATE toets
 */

static void dir_hndlbutton(WINDOW *w, int x, int y, int n,
						   int button_state, int keystate)
{
	wd_hndlbutton(w, x, y, n, button_state, keystate);
}

#pragma warn .par

static void dir_redraw(WINDOW *w, RECT *area)
{
	RECT r;

	r = *area;
	do_redraw((DIR_WINDOW *) w, &r, TRUE);
}

static void dir_topped(WINDOW *w)
{
	xw_set(w, WF_TOP);
}

static void dir_closed(WINDOW *w)
{
	dir_close(w, 0);
}

static void dir_fulled(WINDOW *w)
{
	RECT size;
	WINFO *winfo = ((DIR_WINDOW *) w)->winfo;

	winfo->flags.fulled = (winfo->flags.fulled == 1) ? 0 : 1; /* toggle */
	dir_calcsize(winfo, &size);
	xw_set(w, WF_CURRXYWH, &size);
	set_sliders((DIR_WINDOW *) w);
}

static void dir_arrowed(WINDOW *w, int arrows)
{
	switch (arrows)
	{
	case WA_UPPAGE:
		w_pageup((DIR_WINDOW *) w);
		break;
	case WA_DNPAGE:
		w_pagedown((DIR_WINDOW *) w);
		break;
	case WA_UPLINE:
	case WA_DNLINE:
	case WA_LFLINE:
	case WA_RTLINE:
		w_scroll((DIR_WINDOW *) w, arrows);
		break;
	case WA_LFPAGE:
		w_pageleft((DIR_WINDOW *) w);
		break;
	case WA_RTPAGE:
		w_pageright((DIR_WINDOW *) w);
		break;
	}
}

static void dir_hslider(WINDOW *w, int newpos)
{
	long h;
	int oldx;

	h = (long) (linelength((DIR_WINDOW *) w) + BORDERS - ((DIR_WINDOW *) w)->ncolumns);
	oldx = ((DIR_WINDOW *) w)->px;
	((DIR_WINDOW *) w)->px = (int) (((long) newpos * h) / 1000L);
	if (oldx != ((DIR_WINDOW *) w)->px)
	{
		set_hslpos((DIR_WINDOW *) w);
		dir_draw((DIR_WINDOW *) w, FALSE);
	}
}

static void dir_vslider(WINDOW *w, int newpos)
{
	long h, oldy;

	h = (long) (((DIR_WINDOW *) w)->nlines - ((DIR_WINDOW *) w)->nrows);
	oldy = ((DIR_WINDOW *) w)->py;
	((DIR_WINDOW *) w)->py = (int) (((long) newpos * h) / 1000L);
	if (oldy != ((DIR_WINDOW *) w)->py)
	{
		set_vslpos((DIR_WINDOW *) w);
		dir_draw((DIR_WINDOW *) w, FALSE);
	}
}

static void dir_sized(WINDOW *w, RECT *newsize)
{
	RECT area;
	int old_w, old_h;

	xw_get(w, WF_WORKXYWH, &area);

	old_w = area.w;
	old_h = area.h;

	dir_moved(w, newsize);

	xw_get(w, WF_WORKXYWH, &area);

	if (((area.w < old_w) || (area.h < old_h)) && (options.mode != TEXTMODE))
		dir_draw((DIR_WINDOW *) w, TRUE);

	dir_title((DIR_WINDOW *) w);
	set_sliders((DIR_WINDOW *) w);
}

static void dir_moved(WINDOW *w, RECT *newpos)
{
	WINFO *wd = ((DIR_WINDOW *) w)->winfo;
	RECT size;
	dir_wsize((DIR_WINDOW *) w, newpos, &size);
	wd->flags.fulled = 0;
	xw_set(w, WF_CURRXYWH, &size);
	dir_set_defsize(wd);
}

#pragma warn -par

static void dir_top(WINDOW *w)
{
	int n = 0;
	WINDOW *h = xw_first();

	while (h != NULL)
	{
		n++;
		h = xw_next();
	}

	menu_ienable(menu, MCLOSE, 1);
	menu_ienable(menu, MCLOSEW, 1);
	menu_ienable(menu, MNEWDIR, 1);
	menu_ienable(menu, MSELALL, 1);
	menu_ienable(menu, MSETMASK, 1);
	menu_ienable(menu, MCYCLE, (n > 1) ? 1 : 0);
}

#pragma warn .par

/********************************************************************
 *																	*
 * Funkties voor het openen van een tekst window.					*
 *																	*
 ********************************************************************/

/* Open een window. path en fspec moet een gemallocde string zijn.
   Deze mogen niet vrijgegeven worden door de aanroepende funktie.
   Bij een fout worden deze strings vrijgegeven. */

static WINDOW *dir_do_open(WINFO *info, const char *path,
						   const char *fspec, int px, int py,
						   int *error)
{
	DIR_WINDOW *w;
	RECT size;
	int errcode;

	if ((w = (DIR_WINDOW *) xw_create(DIR_WIND, &dir_functions, DFLAGS, &dmax,
									  sizeof(DIR_WINDOW), NULL, &errcode)) == NULL)
	{
		if (errcode == XDNMWINDOWS)
		{
			alert_printf(1, MTMWIND);
			*error = ERROR;
		}
		else if (errcode == XDNSMEM)
			*error = ENSMEM;
		else
			*error = ERROR;

		free(path);
		free(fspec);

		return NULL;
	}

	info->dir_window = w;
	w->itm_func = &itm_func;
	w->px = px;
	w->py = py;
	w->path = path;
	w->fspec = fspec;
	w->buffer = NULL;
	w->nfiles = 0;
	w->nvisible = 0;
	w->winfo = info;

	dir_calcsize(info, &size);

	graf_mouse(HOURGLASS, NULL);
	*error = dir_read(w);
	graf_mouse(ARROW, NULL);

	if (*error != 0)
	{
		dir_rem(w);
		xw_delete((WINDOW *) w);		/* HR 131202: after dir_rem (MP) */
		return NULL;
	}
	else
	{
		xw_open((WINDOW *) w, &size);
		info->used = TRUE;
		return (WINDOW *) w;
	}
}

#pragma warn -par

/* boolean dir_add_window(const char *path) DjV 017 280103 */
boolean dir_add_window(const char *path, const char *name ) /* DjV 017 280103 */
{
	int j = 0, error;
	char *fspec;

	WINDOW
		*dw;	/* DjV 017 280103 */

	while ((j < MAXWINDOWS - 1) && (dirwindows[j].used != FALSE))
		j++;

	if (dirwindows[j].used == TRUE)
	{
		alert_printf(1, MTMWIND);
		free(path);
		return FALSE;
	}
	else
	{
		if ((fspec = strdup(DEFAULT_EXT)) == NULL)				/* HR 271102 */
		{
			xform_error(ENSMEM);
			free(path);
			return FALSE;
		}
		else
		{
			/* if (dir_do_open(&dirwindows[j], path, fspec, 0, 0, &error) == NULL)  DjV 017 280103 */
			if ( (dw = dir_do_open(&dirwindows[j], path, fspec, 0, 0, &error)) == NULL) /* DjV 017 280103 */
			{
				xform_error(error);
				return FALSE;
			}
			else
				/* DjV 017 280103 ---vvv--- */
				/* use this to show search result */
				if ( name != NULL )
				{ 
					int
						nv,    /* number of visible items in the directory */
						i,     /* item counter */
						hp,vp; /* calculated slider positions */

					NDTA
						*h;

					nv = dirwindows[j].dir_window->nvisible;

					for ( i = 0; i < nv; i++ )
					{
						h = &dirwindows[j].dir_window->buffer[i];
						if ( strcmp( h->name, name ) == 0 )
						{
							/* 
							 * Calculate positions of sliders;
							 * horizontal slider is here in case
							 * of future development of multicolumn
							 * display, when it might be needed.
							 * Therefore, if-then-else below is more complicated
							 * than it need currently be 
							 */
							if ( options.mode == TEXTMODE )
							{
								hp = 0; /* until multicolumn */
								vp = min( 1000, (int)( (long)(i + 1) * 1000 / nv ) );
							}
							else
							{
								hp = 0; /* always ? */ 
								vp = min( 1000, (int)( (long)(i + 1) * 1000 / nv ) );

							}
							dir_hslider ( dw, hp ); /* in fact, currently not needed */ 
							dir_vslider ( dw, vp );

							selection.w = dw;
							selection.selected = i;
							selection.n = 1; 					
							itm_select( dw, i, 3, TRUE );
							itm_set_menu( dw );
							
							break;
						}
					}
				}
				/* DjV 017 280103 ---^^^--- */

				return TRUE;
		}
	}
}

#pragma warn .par

/********************************************************************
 *																	*
 * Functies voor het veranderen van het window font.				*
 *																	*
 ********************************************************************/

void dir_setfont(void)
{
	int i;
	RECT work;
	WINFO *wd;

	if (fnt_dialog(DTDFONT, &dir_font, FALSE) == TRUE)
	{
		for (i = 0; i < MAXWINDOWS; i++)
		{
			wd = &dirwindows[i];
			if (wd->used != FALSE)
			{
				xw_get((WINDOW *) wd->dir_window, WF_WORKXYWH, &work);
				calc_rc(wd->dir_window, &work);
				set_sliders(wd->dir_window);
				dir_draw(wd->dir_window, TRUE);

				/* 
				 * DjV 012 261202 note: change of directory font 
				 * should perhaps affect size of a fulled window 
				 */
			}
		}
	}
}

/********************************************************************
 *																	*
 * Funkties voor het initialisatie, laden en opslaan.				*
 *																	*
 ********************************************************************/

void dir_init(void)
{
	RECT work;

	xw_calc(WC_WORK, DFLAGS, &screen_info.dsk, &work, NULL);
	dmax.x = screen_info.dsk.x;
	dmax.y = screen_info.dsk.y;
	dmax.w = work.w - (work.w % screen_info.fnt_w);
	dmax.h = work.h + DELTA - (work.h % (screen_info.fnt_h +DELTA));
}

void dir_default(void)
{
	int i;

	dir_font = def_font;

	for (i = 0; i < MAXWINDOWS; i++)
	{
		dirwindows[i].x = 100 + i * screen_info.fnt_w * 2 - screen_info.dsk.x;
		dirwindows[i].y = 30 + i * screen_info.fnt_h - screen_info.dsk.y;
		dirwindows[i].w = screen_info.dsk.w / (2 * screen_info.fnt_w);
		dirwindows[i].h = (screen_info.dsk.h * 11) / (20 * screen_info.fnt_h + 20 * DELTA);
		dirwindows[i].flags.fulled = 0;
		dirwindows[i].used = FALSE;
	}
}

int dir_load(XFILE *file)
{
	int i, n;
	long s;
	SINFO1 sinfo;
	WINFO *w;
	FDATA font;

	if (options.version < 0x125)
		dir_font = def_font;
	else
	{
		if ((s = x_fread(file, &font, sizeof(FDATA))) != sizeof(FDATA))
			return (s < 0) ? (int) s : EEOF;
		fnt_setfont(font.id, font.size, &dir_font);
	}

	if (options.version == 0x119)
	{
		dir_default();
		n = 6;
	}
	else
		n = MAXWINDOWS;

	for (i = 0; i < n; i++)
	{
		w = &dirwindows[i];

		if ((s = x_fread(file, &sinfo, sizeof(SINFO1))) != sizeof(SINFO1))
			return (s < 0) ? (int) s : EEOF;

		w->x = sinfo.x;
		w->y = sinfo.y;
		w->w = sinfo.w;
		w->h = sinfo.h;
		w->flags = sinfo.flags;
		w->used = FALSE;
	}
	return 0;
}

int dir_save(XFILE *file)
{
	int i;
	SINFO1 sinfo;
	WINFO *w;
	long n;
	FDATA font;

	font.id = dir_font.id;
	font.size = dir_font.size;
	font.resvd1 = 0;
	font.resvd2 = 0;

	if ((n = x_fwrite(file, &font, sizeof(FDATA))) < 0)
		return (int) n;

	for (i = 0; i < MAXWINDOWS; i++)
	{
		w = &dirwindows[i];

		sinfo.x = w->x;
		sinfo.y = w->y;
		sinfo.w = w->w;
		sinfo.h = w->h;
		sinfo.flags = w->flags;
		sinfo.resvd = 0;

		if ((n = x_fwrite(file, &sinfo, sizeof(SINFO1))) < 0)
			return (int) n;
	}

	return 0;
}

int dir_load_window(XFILE *file)
{
	SINFO2 sinfo;
	char *path, *fspec;
	int error;
	long n;

	if ((n = x_fread(file, &sinfo, sizeof(SINFO2))) != sizeof(SINFO2))
		return (n < 0) ? (int) n : EEOF;

	if ((path = x_freadstr(file, NULL, sizeof(LNAME), &error)) == NULL)		/* HR 240103: max l */ /* HR 240203 */
		return error;

	if ((fspec = x_freadstr(file, NULL, sizeof(LNAME), &error)) == NULL)		/* HR 240103: max l */ /* HR 240203 */
	{
		free(path);
		return error;
	}

	if (dir_do_open(&dirwindows[sinfo.index], path, fspec, sinfo.px, sinfo.py, &error) == NULL)
	{
		if ((error == EPTHNF) || (error == EFILNF) || (error == ERROR))
			return 0;
		return error;
	}

	return 0;
}

int dir_save_window(XFILE *file, WINDOW *w)
{
	SINFO2 sinfo;
	DIR_WINDOW *dw;
	int i = 0, error;
	long n;

	while (dirwindows[i].dir_window != (DIR_WINDOW *) w)
		i++;

	dw = dirwindows[i].dir_window;

	sinfo.index = i;
	sinfo.px = dw->px;
	sinfo.py = dw->py;

	if ((n = x_fwrite(file, &sinfo, sizeof(SINFO2))) < 0)
		return (int) n;

	if ((error = x_fwritestr(file, dw->path)) < 0)
		return error;

	if ((error = x_fwritestr(file, dw->fspec)) < 0)
		return error;

	return 0;
}

/********************************************************************
 *																	*
 * Funkties voor items in directory windows.						*
 *																	*
 ********************************************************************/

/* Routine voor het vinden van een element. x en y zijn de
   coordinaten van de muis. Het resultaat is -1 als er geen
   item is aangeklikt. */

static int itm_find(WINDOW *w, int x, int y)
{
	int hy, item;
	RECT r1, r2, work;
	DIR_WINDOW *dw;

	dw = (DIR_WINDOW *) w;

	xw_get(w, WF_WORKXYWH, &work);

	if (options.mode == TEXTMODE)
	{
		hy = (y - work.y - DELTA);
		if (hy < 0)
			return -1;
		hy /= (dir_font.ch + DELTA);
		item = hy + (int) dw->py;
		if (item >= dw->nvisible)
			return -1;

		dir_comparea(dw, item, &r1, &work);

		if (inrect(x, y, &r1) == TRUE)
			return item;
		else
			return -1;
	}
	else
	{
		int columns, hx;

		columns = dw->columns;

		hx = (x - work.x) / ICON_W;
		hy = (y - work.y) / ICON_H;

		if ((hx < 0) || (hy < 0) || (hx >= columns))
			return -1;

		item = hx + (dw->py + hy) * columns;
		if (item >= dw->nvisible)
			return -1;

		icn_comparea(dw, item, &r1, &r2, &work);

		if (inrect(x, y, &r1))
			return item;
		else if (inrect(x, y, &r2))
			return item;
		else
			return -1;
	}
}

/* Funktie die aangeeft of een directory item geselecteerd is. */


static boolean itm_state(WINDOW *w, int item)
{
	return ((DIR_WINDOW *) w)->buffer[(long) item].selected;
}

/* Funktie die het type van een directory item teruggeeft. */

static ITMTYPE itm_type(WINDOW *w, int item)
{
	return ((DIR_WINDOW *) w)->buffer[(long) item].item_type;
}

static int itm_icon(WINDOW *w, int item)
{
	return ((DIR_WINDOW *) w)->buffer[(long) item].icon;
}

/* Funktie die de directory van een window teruggeeft. */

/* static DjV 031 070203 */
const char *dir_path(WINDOW *w)
{
	return ((DIR_WINDOW *) w)->path;
}

/* Funktie die de naam van een directory item teruggeeft. */

static const char *itm_name(WINDOW *w, int item)
{
	return ((DIR_WINDOW *) w)->buffer[(long) item].name;
}

static char *itm_fullname(WINDOW *w, int item)
{
	NDTA *itm = &((DIR_WINDOW *) w)->buffer[(long) item];

	if (itm->item_type == ITM_PREVDIR)
		return fn_get_path(((DIR_WINDOW *) w)->path);
	else
		return fn_make_path(((DIR_WINDOW *) w)->path, itm->name);
}

/* Funktie die de dta van een directory item teruggeeft. */

static int itm_attrib(WINDOW *w, int item, int mode, XATTR *attr)
{
	NDTA *itm = &((DIR_WINDOW *) w)->buffer[(long) item];
	char *name;
	int error;

	if ((name = x_makepath(((DIR_WINDOW *) w)->path, itm->name, &error)) == NULL)
		return error;
	else
	{
		error = (int) x_attr(mode, name, attr);
		free(name);
		return error;
	}
}

static long itm_info(WINDOW *w, int item, int which)
{
	long l = 0;

	if ((which == ITM_PATHSIZE) || (which == ITM_FNAMESIZE))
	{
		l = strlen(((DIR_WINDOW *) w)->path);
		if (which == ITM_PATHSIZE)
			return l;
		if (((DIR_WINDOW *) w)->path[l - 1] != '\\')
			l++;
	}
	return l + strlen(((DIR_WINDOW *) w)->buffer[(long) item].name);
}

/* Funktie voor het zetten van de nieuwe status van de items in een
   window */

static void dir_setnws(DIR_WINDOW *w)
{
	long i, h, bytes = 0;
	int n = 0;
	NDTA *b;

	h = w->nvisible;
	b = w->buffer;

	for (i = 0; i < h; i++)
	{
		NDTA *h = &b[i];

		h->selected = h->newstate;
		if (h->selected == TRUE)
		{
			n++;
			bytes += h->attrib.size;
		}
	}

	dir_info(w, n, bytes);
	w->nselected = n;
}

/* Funktie voor het selecteren en deselecteren van items waarvan
   de status veranderd is. */

static void dir_drawsel(DIR_WINDOW *w)
{
	long i, h;
	NDTA *b;
	RECT r1, r2, d, work;

	xw_get((WINDOW *) w, WF_WORKXYWH, &work);

	if (options.mode == TEXTMODE)
	{
		h = (long) min(w->py + w->rows, w->nlines);
		b = w->buffer;

		wind_update(BEG_UPDATE);

		graf_mouse(M_OFF, NULL);
		xw_get((WINDOW *) w, WF_FIRSTXYWH, &r2);
		while ((r2.w != 0) && (r2.h != 0))
		{
			xd_clip_on(&r2);
			for (i = w->py; i < h; i++)
			{
				if (b[i].selected != b[i].newstate)
				{
					dir_comparea(w, (int) i, &r1, &work);
					if (xd_rcintersect(&r1, &r2, &d) == TRUE)
						invert(&d);
				}
			}

			xd_clip_off();
			xw_get((WINDOW *) w, WF_NEXTXYWH, &r2);
		}
		graf_mouse(M_ON, NULL);

		wind_update(END_UPDATE);
	}
	else
	{
		OBJECT *tree;

		if ((tree = make_tree(w, w->py, w->rows, TRUE, &work)) == NULL)
			return;

		wind_update(BEG_UPDATE);

		xw_get((WINDOW *) w, WF_FIRSTXYWH, &r2);
		while ((r2.w != 0) && (r2.h != 0))
		{
			draw_tree(tree, &r2);
			xw_get((WINDOW *) w, WF_NEXTXYWH, &r2);
		}

		wind_update(END_UPDATE);

		free(tree);
	}
}

/* Funktie voor het selecteren van een item in een window.
   mode = 0: selecteer selected en deselecteer de rest.
   mode = 1: inverteer de status van selected.
   mode = 2: deselecteer selected.
   mode = 3: selecteer selected.
   mode = 4: selecteer alles. */

static void itm_select(WINDOW *w, int selected, int mode, boolean draw)
{
	long i, h;
	NDTA *b;

	h = ((DIR_WINDOW *) w)->nvisible;
	b = ((DIR_WINDOW *) w)->buffer;

	if (b == NULL)
		return;

	switch (mode)
	{
	case 0:
		for (i = 0; i < h; i++)
			b[i].newstate = (i == selected) ? TRUE : FALSE;
		break;
	case 1:
		for (i = 0; i < h; i++)
			b[i].newstate = b[i].selected;
		b[selected].newstate = (b[selected].selected) ? FALSE : TRUE;
		break;
	case 2:
		for (i = 0; i < h; i++)
			b[i].newstate = (i == selected) ? FALSE : b[i].selected;
		break;
	case 3:
		for (i = 0; i < h; i++)
			b[i].newstate = (i == selected) ? TRUE : b[i].selected;
		break;
	case 4:
		for (i = 0; i < h; i++)
			b[i].newstate = TRUE;
		break;
	}

	if (draw == TRUE)
		dir_drawsel((DIR_WINDOW *) w);
	dir_setnws((DIR_WINDOW *) w);
}

/* Funktie, die de index van de eerste file die zichtbaar is,
   teruggeeft. Ook wordt het aantal teruggegeven. */

static void calc_vitems(DIR_WINDOW *dw, int *s, int *n)
{
	int h;

	if (options.mode == TEXTMODE)
	{
		*s = dw->py;
		h = dw->rows;
	}
	else
	{
		int columns = dw->columns;

		*s = columns * dw->py;
		h = columns * dw->rows;
	}

	if ((*s + h) > dw->nvisible)
		h = dw->nvisible - *s;

	*n = h;
}

/* Rubberbox funktie met scrolling */

static void rubber_box(DIR_WINDOW *w, RECT *work, int x, int y, RECT *r)
{
	int x1 = x, y1 = y, x2 = x, y2 = y, ox = x, oy = y, hy = y;
	int kstate, h, scroll, delta, absdelta;
	boolean released, redraw;

	absdelta = (options.mode == TEXTMODE) ? dir_font.ch + DELTA : ICON_H;

	wind_update(BEG_MCTRL);
	graf_mouse(POINT_HAND, NULL);

	set_rect_default();
	draw_rect(x1, y1, x2, y2);

	do
	{
		redraw = FALSE;
		scroll = -1;

		released = xe_mouse_event(0, &x2, &y2, &kstate);

		if (y2 < screen_info.dsk.y)
			y2 = screen_info.dsk.y;

		if ((y2 < work->y) && (w->py > 0) && (y1 < INT_MAX - absdelta))
		{
			redraw = TRUE;
			scroll = WA_UPLINE;
			delta = absdelta;
		}

		if ((y2 >= work->y + work->h) && ((w->py + w->nrows) < w->nlines) && (y1 > -INT_MAX + absdelta))
		{
			redraw = TRUE;
			scroll = WA_DNLINE;
			delta = -absdelta;
		}

		if ((released != FALSE) || (x2 != ox) || (y2 != oy))
			redraw = TRUE;

		if (redraw != FALSE)
		{
			set_rect_default();
			draw_rect(x1, hy, ox, oy);

			if (scroll >= 0)
			{
				y1 += delta;
				if (y1 < (h = work->y))
					hy = h - 1;
				else if (y1 > (h = work->y + work->h))
					hy = h;
				else
					hy = y1;
				w_scroll(w, scroll);
			}

			if (released == FALSE)
			{
				set_rect_default();
				draw_rect(x1, hy, x2, y2);
				ox = x2;
				oy = y2;
			}
		}
	}
	while (released == FALSE);

	graf_mouse(ARROW, NULL);
	wind_update(END_MCTRL);

	if ((h = x2 - x1) < 0)
	{
		r->x = x2;
		r->w = -h + 1;
	}
	else
	{
		r->x = x1;
		r->w = h + 1;
	}

	if ((h = y2 - y1) < 0)
	{
		r->y = y2;
		r->h = -h + 1;
	}
	else
	{
		r->y = y1;
		r->h = h + 1;
	}
}

/* Funktie voor het selecteren van items die binnen een bepaalde
   rechthoek liggen. */

static void itm_rselect(WINDOW *w, int x, int y)
{
	long i, h;
	int s, n;
	RECT r1, r2, r3, work;
	NDTA *b, *ndta;

	xw_get(w, WF_WORKXYWH, &work);

	rubber_box((DIR_WINDOW *) w, &work, x, y, &r1);

	s = 0;
	n = ((DIR_WINDOW *) w)->nfiles;
	h = (long) (s + n);
	b = ((DIR_WINDOW *) w)->buffer;

	if (options.mode == TEXTMODE)
	{
		for (i = s; i < h; i++)
		{
			ndta = &b[i];

			dir_comparea((DIR_WINDOW *) w, (int) i, &r2, &work);
			if (rc_intersect2(&r1, &r2))
				ndta->newstate = (ndta->selected) ? FALSE : TRUE;
		}
	}
	else
	{
		for (i = s; i < h; i++)
		{
			ndta = &b[i];

			icn_comparea((DIR_WINDOW *) w, (int) i, &r2, &r3, &work);

			if (rc_intersect2(&r1, &r2))
				ndta->newstate = (ndta->selected) ? FALSE : TRUE;
			else if (rc_intersect2(&r1, &r3))
				ndta->newstate = (ndta->selected) ? FALSE : TRUE;
			else
				ndta->newstate = ndta->selected;
		}
	}

	dir_drawsel((DIR_WINDOW *) w);
	dir_setnws((DIR_WINDOW *) w);
}

static void get_itmd(DIR_WINDOW *wd, int obj, ICND *icnd, int mx, int my, RECT *work)
{
	if (options.mode == TEXTMODE)
	{
		int x, y, w, h;

		icnd->item = obj;
		icnd->np = 5;
		x = work->x + (2 - wd->px) * dir_font.cw - mx;
		y = work->y + DELTA + (obj - (int) wd->py) * (dir_font.ch + DELTA) - my;
		w = 12 * dir_font.cw - 1;
		h = dir_font.ch - 1;
		icnd->coords[0] = x;
		icnd->coords[1] = y;
		icnd->coords[2] = x;
		icnd->coords[3] = y + h;
		icnd->coords[4] = x + w;
		icnd->coords[5] = y + h;
		icnd->coords[6] = x + w;
		icnd->coords[7] = y;
		icnd->coords[8] = x + 1;
		icnd->coords[9] = y;
	}
	else
	{
		int columns, s;
		RECT ir, tr;

		columns = wd->columns;
		s = obj - columns * wd->py;

		icn_comparea(wd, obj, &ir, &tr, work);

		ir.x -= mx;
		ir.y -= my;
		ir.w -= 1;
		tr.x -= mx;
		tr.y -= my;
		tr.w -= 1;
		tr.h -= 1;

		icnd->item = obj;
		icnd->np = 9;
		icnd->m_x = work->x + (s % columns) * ICON_W + ICON_W / 2 - mx;
		icnd->m_y = work->y + (s / columns) * ICON_H + ICON_H / 2 - my;

		icnd->coords[0] = tr.x;
		icnd->coords[1] = tr.y;
		icnd->coords[2] = ir.x;
		icnd->coords[3] = tr.y;
		icnd->coords[4] = ir.x;
		icnd->coords[5] = ir.y;
		icnd->coords[6] = ir.x + ir.w;
		icnd->coords[7] = ir.y;
		icnd->coords[8] = ir.x + ir.w;
		icnd->coords[9] = tr.y;
		icnd->coords[10] = tr.x + tr.w;
		icnd->coords[11] = tr.y;
		icnd->coords[12] = tr.x + tr.w;
		icnd->coords[13] = tr.y + tr.h;
		icnd->coords[14] = tr.x;
		icnd->coords[15] = tr.y + tr.h;
		icnd->coords[16] = tr.x;
		icnd->coords[17] = tr.y + 1;
	}
}

static boolean get_list(DIR_WINDOW *w, int *nselected, int *nvisible, int **sel_list)
{
	int j = 0, n = 0, nv = 0, *list, s, h;
	long i, m;
	NDTA *d;

	d = w->buffer;
	m = w->nvisible;

	calc_vitems(w, &s, &h);
	h += s;

	for (i = 0; i < m; i++)
	{
		if (d[i].selected == TRUE)
		{
			n++;
			if (((int) i >= s) && ((int) i < h))
				nv++;
		}
	}

	*nvisible = nv;

	if ((*nselected = n) == 0)
	{
		*sel_list = NULL;
		return TRUE;
	}

	list = malloc(n * sizeof(int));

	*sel_list = list;

	if (list == NULL)
	{
		xform_error(ENSMEM);
		return FALSE;
	}
	else
	{
		for (i = 0; i < m; i++)
			if (d[i].selected == TRUE)
				list[j++] = (int) i;

		return TRUE;
	}
}

/* Routine voor het maken van een lijst met geselekteerde items. */

static boolean itm_xlist(WINDOW *w, int *nselected, int *nvisible,
						 int **sel_list, ICND **icns, int mx, int my)
{
	int j = 0;
	long i;
	ICND *icnlist;
	NDTA *d;
	RECT work;

	xw_get(w, WF_WORKXYWH, &work);

	if (get_list((DIR_WINDOW *) w, nselected, nvisible, sel_list) == FALSE)
		return FALSE;

	if (nselected == 0)
	{
		*icns = NULL;
		return TRUE;
	}

	icnlist = malloc(*nvisible * sizeof(ICND));
	*icns = icnlist;

	if (icnlist == NULL)
	{
		xform_error(ENSMEM);
		free(*sel_list);
		return FALSE;
	}
	else
	{
		int s, n, h;

		calc_vitems((DIR_WINDOW *) w, &s, &n);
		h = s + n;
		d = ((DIR_WINDOW *) w)->buffer;

		for (i = s; (int) i < h; i++)
			if (d[i].selected == TRUE)
				get_itmd((DIR_WINDOW *) w, (int) i, &icnlist[j++], mx, my, &work);

		return TRUE;
	}
}

/* Routine voor het maken van een lijst met geseleketeerde items. */

static boolean itm_list(WINDOW *w, int *n, int **list)
{
	int dummy;

	return get_list((DIR_WINDOW *) w, n, &dummy, list);
}

static boolean dir_open(WINDOW *w, int item, int kstate)
{
	char *newpath;

	if ((itm_type(w, item) == ITM_FOLDER) && ((kstate & 8) == 0))
	{
		if ((newpath = itm_fullname(w, item)) != NULL)
		{
			free(((DIR_WINDOW *) w)->path);
			((DIR_WINDOW *) w)->path = newpath;
			dir_readnew((DIR_WINDOW *) w);
		}

		return FALSE;
	}
	else if ((itm_type(w, item) == ITM_PREVDIR) && ((kstate & 8) == 0))
	{
		dir_close(w, 0);

		return FALSE;
	}
	else
		return item_open(w, item, kstate);
}

#pragma warn -par

static boolean dir_copy(WINDOW *dw, int dobject, WINDOW *sw, int n,
						int *list, ICND *icns, int x, int y, int kstate)
{
	return item_copy(dw, dobject, sw, n, list, kstate);
}

#pragma warn .par
