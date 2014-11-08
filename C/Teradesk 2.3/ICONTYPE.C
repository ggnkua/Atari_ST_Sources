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
#include "prgtype.h"
#include "window.h"
#include "icon.h"
#include "icontype.h"

#define NLINES		4
#define END			32767

typedef struct icontype
{
	SNAME type;				/* HR 240203 */
	int icon;
	SNAME icon_name;		/* HR 240203 */
	struct icontype *next;
} ICONTYPE;

typedef struct
{
	int icon;
	int resvd;
} ITYPE;

static ICONTYPE *files, *folders, **curlist;

static int find_icon(const char *name, ICONTYPE *list)
{
	ICONTYPE *p = list;

	while (p)
	{
		if (cmp_wildcard(name, p->type) == TRUE)
			return min(n_icons - 1, p->icon);
		p = p->next;
	}
	return -1;
}

/* HR 151102: find icons by name, not index */
int icnt_geticon(const char *name, ITMTYPE type)
{
	int icon;

	if ((type == ITM_PREVDIR) || (type == ITM_FOLDER))
	{
		if ((icon = find_icon(name, folders)) < 0)
			icon = rsrc_icon_rscid ( FOINAME, iname ); /* HR 151102 DjV 024 140103 */
	}
	else
	{
		if ((icon = find_icon(name, files)) < 0)
		{
			if (prg_isprogram(name) == FALSE)
				icon = rsrc_icon_rscid ( FIINAME, iname ); /* HR 151102 DjV 024 140103 */
			else
				icon = rsrc_icon_rscid ( APINAME, iname ); /* HR 151102 DjV 024 140103 */
		}
	}

	if (icon < 0)				/* HR 151102 */
		icon = 0;

	return icon;
}

static void free_list(ICONTYPE **list)
{
	ICONTYPE *p = *list, *next;

	while (p)
	{
		next = p->next;
		free(p);
		p = next;
	}

	*list = NULL;
}

static ICONTYPE *add(ICONTYPE **list, char *name, int icon, int pos)
{
	ICONTYPE *p, *prev, *n;
	int i = 0;

	p = *list;
	prev = NULL;

	while ((p != NULL) && (i != pos))
	{
		prev = p;
		p = p->next;
		i++;
	}

	if ((n = malloc(sizeof(ICONTYPE))) == NULL)
		xform_error(ENSMEM);
	else
	{
		strcpy(n->type, name);
		strsncpy(n->icon_name,					/* HR 120203: secure cpy */
		        icons[icon].ob_spec.ciconblk->monoblk.ib_ptext,
		        sizeof(n->icon_name));							/* HR 151102: maintain rsrc icon name */
		n->icon = icon;
		n->next = p;

		if (prev == NULL)
			*list = n;
		else
			prev->next = n;
	}

	return n;
}

static void rem(ICONTYPE **list, ICONTYPE *item)
{
	ICONTYPE *p, *prev;

	p = *list;
	prev = NULL;

	while ((p != NULL) && (p != item))
	{
		prev = p;
		p = p->next;
	}

	if (p == item)
	{
		if (prev == NULL)
			*list = p->next;
		else
			prev->next = p->next;

		free(p);
	}
}

static boolean copy(ICONTYPE **copy, ICONTYPE *list)
{
	ICONTYPE *p;

	p = list;
	*copy = NULL;

	while (p != NULL)
	{
		if (add(copy, p->type, p->icon, END) == NULL)
		{
			free_list(copy);
			return FALSE;
		}
		p = p->next;
	}

	return TRUE;
}

static int cnt_types(ICONTYPE *list)
{
	int n = 1;
	ICONTYPE *p = list;

	while (p != NULL)
	{
		n++;
		p = p->next;
	}

	return n;
}

static ICONTYPE *get_item(ICONTYPE *list, int item)
{
	int i = 0;
	ICONTYPE *p = list;

	while ((p != NULL) && (i != item))
	{
		i++;
		p = p->next;
	}

	return p;
}

static void pset_selector(SLIDER *slider, boolean draw, XDINFO *info)
{
	int i;
	ICONTYPE *p;
	OBJECT *o;

	for (i = 0; i < NLINES; i++)
	{
		o = &seticntype[ITYPE1 + i];

		if ((p = get_item(*curlist, i + slider->line)) == NULL)
			*o->ob_spec.tedinfo->te_ptext = 0;
		else
			cv_fntoform(o, p->type);			/* HR 240103 */
	}

	if (draw == TRUE)
		xd_draw(info, IPARENT, MAX_DEPTH);
}

static int pfind_selected(void)
{
	int object;

	return ((object = xd_get_rbutton(seticntype, IPARENT)) < 0) ? 0 : object - ITYPE1;
}

/* DJV 040 160203 ---vvv--- */
/* This routine is exactly the same as in icon.c !!! */

static void set_selector(SLIDER *slider, boolean draw, XDINFO *info);


static boolean icntype_dialog(char *name, int *icon, boolean edit)
{
	int button;
	SLIDER sl_info;

	/* rsc_title(addicntype, AITTITLE, (edit == TRUE) ? DTEDTICT : DTADDICT); DjV 034 050203 */
	rsc_title(addicon, AITITLE, (edit == TRUE) ? DTEDTICT : DTADDICT);

	/* cv_fntoform(addicntype + AITTYPE, name); DJV 034 050203 */			/* HR 240103 */
	cv_fntoform(addicon + ICNTYPE, name);  /* DjV 034 050203 */


	/* DjV 034 050203 ---vvv--- */
	addicon[CHNBUTT].ob_flags |= HIDETREE;
	addicon[ADDBUTT].ob_flags &= ~HIDETREE;
	addicon[ICBTNS].ob_flags |= HIDETREE;
	/* addicon[ICSHFIL].ob_flags &= ~HIDETREE; DjV 034 090203 */
	/* addicon[ICSHFLD].ob_flags &= ~HIDETREE; DjV 034 090203 */
	addicon[DRIVEID].ob_flags |= HIDETREE;
	addicon[ICNLABEL].ob_flags |= HIDETREE; /* DjV 034 090203 */
	/* DJV 034 050203 ---^^^--- */

	sl_info.type = 0;
	/* DJV 034 050203 ---vvv--- */
	/*
	sl_info.up_arrow = ITUP;
	sl_info.down_arrow = ITDOWN;
	sl_info.slider = ITSLIDER;
	sl_info.sparent = ITPARENT;
	*/
	sl_info.up_arrow = ICNUP;
	sl_info.down_arrow = ICNDWN;
	sl_info.slider = ICSLIDER;
	sl_info.sparent = ICPARENT;
	/* DJV 034 050203 ---^^^--- */
	sl_info.lines = 1;
	sl_info.n = n_icons;
	sl_info.line = *icon;
	sl_info.set_selector = set_selector;
	sl_info.first = 0;
	sl_info.findsel = 0;

	/* button = sl_dialog(addicntype, AITTYPE, &sl_info); DjV 034 050203 */
	button = sl_dialog(addicon, ICNTYPE, &sl_info); /* DJV 034 050203 */

	/* DjV 015 020103 ---vvv--- */
	
	/*
	 * Found out that assignment of window icons doesn't work in V2.01;
	 * removing testing for length of dirname appears to fix it
	 * but probaly is not the right thing to do...
	 */
	 
  	/*	if ((button == AITOK) && (strlen(dirname) != 0)) */
	/* if ( button == AITOK ) DjV 034 050203 */
	if ( button == ADDICNOK ) /* DjV 034 050203 */
	
	/* DjV 015 020103 ---^^^--- */
	{
		cv_formtofn(name, icnname);
		*icon = sl_info.line;
		return TRUE;
	}
	else
		return FALSE;
}

void icnt_settypes(void)
{
	int button, icon;
	int i;
	XDINFO info;
	boolean stop = FALSE, redraw;
	ICONTYPE *cfiles, *cfolders, *p, **newlist;
	SNAME name;			/* HR 240203 */
	SLIDER sl;

	curlist = (seticntype[ITFOLDER].ob_state & SELECTED) ? &cfolders : &cfiles;

	cfiles = NULL;
	cfolders = NULL;

	if ((copy(&cfiles, files) == FALSE) || (copy(&cfolders, folders) == FALSE))
	{
		free_list(&cfiles);
		free_list(&cfolders);
	}

	sl.type = 1;
	sl.up_arrow = IUP;
	sl.down_arrow = IDOWN;
	sl.slider = ISLIDER;
	sl.sparent = ISPARENT;
	sl.lines = NLINES;
	sl.n = cnt_types(*curlist);
	sl.line = 0;
	sl.set_selector = pset_selector;
	sl.first = ITYPE1;
	sl.findsel = pfind_selected;

	sl_init(seticntype, &sl);

	xd_open(seticntype, &info);

	while (stop == FALSE)
	{
		redraw = FALSE;

		button = sl_form_do(seticntype, 0, &sl, &info) & 0x7FFF;

		if ((button != ITFOLDER) && (button != ITFILES))
		{
			/* DjV 034 090203 ---vvv--- */
			if ( curlist == &cfolders )	
			{
				addicon[ICSHFLD].ob_flags &= ~HIDETREE; 
				addicon[ICSHFIL].ob_flags |=  HIDETREE;
			}
			else if ( curlist == &cfiles )	
			{
				addicon[ICSHFLD].ob_flags |=  HIDETREE;
				addicon[ICSHFIL].ob_flags &= ~HIDETREE;
			}
			/* DjV 034 090203 ---^^^--- */

			switch (button)
			{
			case ITADD:
				name[0] = 0;
				icon = 0;

				if (icntype_dialog(name, &icon, FALSE) == TRUE)
				{
					i = pfind_selected() + sl.line;
					add(curlist, name, icon, i);
					sl.n = cnt_types(*curlist);
					redraw = TRUE;
					sl_set_slider(seticntype, &sl, &info);
				}
				break;
			case ITDEL:
				i = pfind_selected() + sl.line;
				if ((p = get_item(*curlist, i)) != NULL)
				{
					rem(curlist, p);
					sl.n = cnt_types(*curlist);
					redraw = TRUE;
					sl_set_slider(seticntype, &sl, &info);
				}
				break;
			case ITCHNG:
				i = pfind_selected() + sl.line;
				if ((p = get_item(*curlist, i)) != NULL)
				{
					redraw = TRUE;
					icntype_dialog(p->type, &p->icon, TRUE);
				}
				break;
			default:
				stop = TRUE;
				break;
			}
			xd_change(&info, button, NORMAL, (stop == FALSE) ? 1 : 0);
		}
		else
		{
			newlist = (button == ITFOLDER) ? &cfolders : &cfiles;
			if (newlist != curlist)
			{
				redraw = TRUE;
				curlist = newlist;
				sl.n = cnt_types(*newlist);
				sl.line = 0;
				sl_set_slider(seticntype, &sl, &info);
			}
		}
		if (redraw == TRUE)
			pset_selector(&sl, TRUE, &info);
	}

	xd_close(&info);

	if (button == ITOK)
	{
		free_list(&files);
		free_list(&folders);
		files = cfiles;
		folders = cfolders;
		wd_seticons();
	}
	else
	{
		free_list(&cfiles);
		free_list(&cfolders);
	}
}

void icnt_init(void)
{
	files = NULL;
	folders = NULL;
}

void icnt_default(void)
{
	free_list(&files);
	free_list(&folders);
}

static int load_list(XFILE *file, ICONTYPE **list)
{
	ITYPE it;
	SNAME name,
	      icon_name;			/* HR 240203 */
	long n;
	int error;

	free_list(list);

	do
	{
		if ((n = x_fread(file, &it, sizeof(ITYPE))) != sizeof(ITYPE))
			return (n < 0) ? (int) n : EEOF;

		if (it.icon != -1)
		{
			int icon;
			if (x_freadstr(file, name, sizeof(name), &error) == NULL)		/* HR 240103: max l */
				return error;
			if (x_freadstr(file, icon_name, sizeof(icon_name), &error) == NULL)		/* HR 240103: max l */
				return error;

			icon = rsrc_icon(icon_name);		/* HR 151102: find icons by name, not index */
			if (icon >= 0)
				if (add(list, name, icon, END) == NULL)
					return ERROR;
		}
	}
	while (it.icon != -1);

	return 0;
}

int icnt_load(XFILE *file)
{
	int error;

	if ((error = load_list(file, &files)) < 0)
		return error;
	return load_list(file, &folders);
}

static boolean save_list(XFILE *file, ICONTYPE *list)
{
	ITYPE it;
	ICONTYPE *p;
	int error;
	long n;

	p = list;

	while (p)
	{
		it.icon = p->icon;
		it.resvd = 0;

		if ((n = x_fwrite(file, &it, sizeof(ITYPE))) < 0)
			return (int) n;

		if ((error = x_fwritestr(file, p->type)) < 0)
			return error;
		if ((error = x_fwritestr(file, p->icon_name)) < 0)
			return error;

		p = p->next;
	}

	it.icon = -1;

	return ((n = x_fwrite(file, &it, sizeof(ITYPE))) < 0) ? (int) n : 0;
}

int icnt_save(XFILE *file)
{
	int error;

	if ((error = save_list(file, files)) < 0)
		return error;
	return save_list(file, folders);
}
