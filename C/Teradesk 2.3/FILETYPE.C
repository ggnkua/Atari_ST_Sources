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
#include <vdi.h>
#include <xdialog.h>
#include <mint.h>

#include "desk.h"
#include "error.h"
#include "resource.h"
#include "slider.h"
#include "xfilesys.h"
#include "file.h"
#include "filetype.h"
#include "window.h"

#define NLINES		4

typedef struct filetype
{
	SNAME name;
	struct filetype *next;
} FTYPE;

typedef struct
{
	ITM_INTVARS;				/* Interne variabelen bibliotheek. */
} ITM_WINDOW;

FTYPE *filetypes;

static FTYPE *add(char *name)
{
	FTYPE *f, *prev;

	f = filetypes;
	prev = NULL;

	while (f != NULL)
	{
		prev = f;
		f = f->next;
	}

	if ((f = malloc(sizeof(FTYPE))) == NULL)
		xform_error(ENSMEM);
	else
	{
		strcpy(f->name, name);
		f->next = NULL;

		if (prev == NULL)
			filetypes = f;
		else
			prev->next = f;
	}

	return f;
}

static void rem(FTYPE *item)
{
	FTYPE *f, *prev;

	f = filetypes;
	prev = NULL;

	while ((f != NULL) && (f != item))
	{
		prev = f;
		f = f->next;
	}

	if (f == item)
	{
		if (prev == NULL)
			filetypes = f->next;
		else
			prev->next = f->next;

		free(f);
	}
}

static void rem_all_filetypes(void)
{
	FTYPE *f, *next;

	f = filetypes;

	while (f != NULL)
	{
		next = f->next;
		free(f);
		f = next;
	}

	filetypes = NULL;
}

static int cnt_types(void)
{
	int n = 0;
	FTYPE *f = filetypes;

	while (f != NULL)
	{
		n++;
		f = f->next;
	}

	return n;
}

static FTYPE *get_item(int item)
{
	int i = 0;
	FTYPE *f = filetypes;

	while ((f != NULL) && (i != item))
	{
		i++;
		f = f->next;
	}

	return f;
}

static void set_selector(SLIDER *slider, boolean draw, XDINFO *info)
{
	int i;
	FTYPE *f;
	OBJECT *o;

	for (i = 0; i < 4; i++)
	{
		o = &setmask[FTYPE1 + i];

		if ((f = get_item(i + slider->line)) == NULL)
			*o->ob_spec.tedinfo->te_ptext = 0;
		else
			cv_fntoform(o, f->name);				/* HR 240103 */
	}

	if (draw == TRUE)
		xd_draw(info, FTPARENT, MAX_DEPTH);
}

static int find_selected(void)
{
	int object;

	return ((object = xd_get_rbutton(setmask, FTPARENT)) < 0) ? 0 : object - FTYPE1;
}

static boolean filetype_dialog(char *name)
{
	int button;

	rsc_title(newfolder, NDTITLE, DTADDMSK);

	cv_fntoform(newfolder + DIRNAME, name);		/* HR 240103 */

	button = xd_dialog(newfolder, DIRNAME);

	if ((button == NEWDIROK) && (strlen(dirname) != 0))
	{
		cv_formtofn(name, dirname);
		return TRUE;
	}
	else
		return FALSE;
}

void wd_set_filemask(WINDOW *w)
{
	((ITM_WINDOW *) w)->itm_func->wd_filemask(w);
}

/* Default funktie voor het zetten van een filemask. Bij het
   aanroepen moet het huidige masker in mask staan. Na afloop zal
   hierin het nieuwe masker staan. Als het resultaat TRUE is, dan
   is op OK gedrukt, als het resultaat FALSE is, dan is op Cancel
   gedrukt, of er is een fout opgetreden. */

char *wd_filemask(const char *mask)
{
	int button;
	int i;
	XDINFO info;
	boolean stop = FALSE, redraw, dc, ok;
	FTYPE *f;
	SNAME name, newmask;			/* HR 240203 */
	char *result;
	SLIDER sl;

	sl.type = 1;
	sl.up_arrow = FTUP;
	sl.down_arrow = FTDOWN;
	sl.slider = FTSLIDER;
	sl.sparent = FTSPAR;
	sl.lines = NLINES;
	sl.n = cnt_types();
	sl.line = 0;
	sl.set_selector = set_selector;
	sl.first = FTYPE1;
	sl.findsel = find_selected;

	/* DjV 004 290103 ---vvv--- */
	if ( mask == NULL )
	{
		setmask[FILETYPE].ob_state |= DISABLED;
		*setmask[FILETYPE].ob_spec.tedinfo->te_ptext = 0;
	}		
	else
	{
	/* DjV 004 290103 ---^^^--- */
		cv_fntoform(setmask + FILETYPE, mask);			/* HR 240103 */
		setmask[FILETYPE].ob_state &= ~DISABLED;	/* DjV 004 290103 */
	}												/* DjV 004 290103 */

	/* DjV 004 020103 Put file attributes buttons into right state */
	set_opt( setmask, options.attribs, FA_HIDDEN, MSKHID );
	set_opt( setmask, options.attribs, FA_SYSTEM, MSKSYS );
	set_opt( setmask, options.attribs, FA_SUBDIR, MSKDIR );
	set_opt( setmask, options.attribs, FA_PARDIR, MSKPAR );

	sl_init(setmask, &sl);

	xd_open(setmask, &info);

	while (stop == FALSE)
	{
		redraw = FALSE;

		button = sl_form_do(setmask, FILETYPE, &sl, &info);
		dc = (button & 0x8000) ? TRUE : FALSE;
		button &= 0x7FFF;

		if ((button < FTYPE1) || (button > FTYPE4))
		{
			switch (button)
			{
			case FTADD:
				name[0] = 0;

				if (filetype_dialog(name) == TRUE)
				{
					add(name);
					sl.n = cnt_types();
					redraw = TRUE;
					sl_set_slider(setmask, &sl, &info);
				}
				break;
			case FTDELETE:
				i = find_selected() + sl.line;
				if ((f = get_item(i)) != NULL)
				{
					rem(f);
					sl.n = cnt_types();
					redraw = TRUE;
					sl_set_slider(setmask, &sl, &info);
				}
				break;
			default:
				ok = (button == FTOK) ? TRUE : FALSE;
				stop = TRUE;
				break;
			}
			xd_change(&info, button, NORMAL, (stop == FALSE) ? 1 : 0);
		}
		else if ( button >= MSKHID && button <= MSKPAR )
		{
			/* DjV 004 020103 do nothing until exit */	
		}		
		else
		{
			strcpy(filetype, setmask[button].ob_spec.tedinfo->te_ptext);
			xd_draw(&info, FILETYPE, 1);
			if (dc == TRUE)
			{
				ok = TRUE;
				stop = TRUE;
			}
		}

		if (redraw == TRUE)
			set_selector(&sl, TRUE, &info);
	}

	xd_close(&info);

	if (ok == TRUE)
	{
		/* DjV 004 030103 ---vvv--- */
		get_opt( setmask, &options.attribs, FA_HIDDEN, MSKHID );
		get_opt( setmask, &options.attribs, FA_SYSTEM, MSKSYS );
		get_opt( setmask, &options.attribs, FA_SUBDIR, MSKDIR ); /* DjV 004 280103 wrongly was MSKHID */ 
		get_opt( setmask, &options.attribs, FA_PARDIR, MSKPAR );
		/* DjV 004 020103 ---^^^--- */

		if ( mask == NULL )		/* DjV 004 290103 */
			return NULL;		/* DjV 004 290103 */
		else					/* DjV 004 290103 */
		{						/* DjV 004 290103 */
			cv_formtofn(newmask, filetype);
			if ((result = malloc(strlen(newmask) + 1)) != NULL)
				strcpy(result, newmask);
			else
				xform_error(ENSMEM);
			return result;
		}						/* DjV 004 290103 */
	}
	else
		return NULL;
}

void ft_init(void)
{
	filetypes = NULL;
#ifdef MEMDEBUG
	atexit(rem_all_filetypes);
#endif
}

void ft_default(void)
{
	rem_all_filetypes();

	add("*");			/* HR 271102: no more distinction between MiNT/TOS */
	add("*.*");			/*            The comparison is made case INsensitive */
	add("*.CFG");
	add("*.C");
	add("*.H");
	add("*.S");
	add("*.PRJ");
	add("*.PRG");
	add("*.TOS");
	add("*.TTP");
	add("*.ACC");
}

int ft_load(XFILE *file)
{
	SNAME name;			/* HR 240203 */
	int error;

	rem_all_filetypes();

	do
	{
		if (x_freadstr(file, name, sizeof(name), &error) == NULL)		/* HR 240103: max l */
			return error;

		if ((strlen(name) != 0) && (add(name) == NULL))
			return ERROR;
	}
	while (strlen(name) != 0);

	return 0;
}

int ft_save(XFILE *file)
{
	FTYPE *f;
	int error;

	f = filetypes;

	while (f)
	{
		if ((error = x_fwritestr(file, f->name)) < 0)
			return error;

		f = f->next;
	}

	return x_fwritestr(file, "");
}
