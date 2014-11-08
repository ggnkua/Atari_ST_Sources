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

#define END			32767
#define NLINES		4

typedef struct prgtype
{
	SNAME name;					/* HR 240203 */
	ApplType appl_type;
	boolean argv;
	boolean path;
	struct prgtype *next;
} PRGTYPE;

typedef struct
{
	int appl_type:4;
	unsigned int argv:1;
	unsigned int path:1;
	int resvd:10;
} SINFO;

PRGTYPE *prgtypes;

void prg_info(const char *prgname, ApplType *type, boolean *argv,
			  boolean *path)
{
	const char *name;
	PRGTYPE *p;

	if ((name = strrchr(prgname, '\\')) == NULL)
		name = prgname;
	else
		name++;

	p = prgtypes;

	while (p != NULL)
	{
		if (cmp_wildcard(name, p->name) == TRUE)
		{
			*type = p->appl_type;
			*argv = p->argv;
			*path = p->path;
			return;
		}
		p = p->next;
	}

	*type = PGEM;
	*argv = FALSE;
	*path = TRUE;

	return;
}

boolean prg_isprogram(const char *name)
{
	PRGTYPE *p;

	p = prgtypes;

	while (p != NULL)
	{
		if (cmp_wildcard(name, p->name) == TRUE)
			return TRUE;
		p = p->next;
	}

	return FALSE;
}

static PRGTYPE *add(char *name, ApplType appl_type, boolean argv, boolean path, int pos)
{
	PRGTYPE *p, *prev, *n;
	int i = 0;

	p = prgtypes;
	prev = NULL;

	while ((p != NULL) && (i != pos))
	{
		prev = p;
		p = p->next;
		i++;
	}

	if ((n = malloc(sizeof(PRGTYPE))) == NULL)
		xform_error(ENSMEM);
	else
	{
		strcpy(n->name, name);
		n->appl_type = appl_type;
		n->argv = argv;
		n->path = path;
		n->next = p;

		if (prev == NULL)
			prgtypes = n;
		else
			prev->next = n;
	}

	return n;
}

static void rem(PRGTYPE *item)
{
	PRGTYPE *p, *prev;

	p = prgtypes;
	prev = NULL;

	while ((p != NULL) && (p != item))
	{
		prev = p;
		p = p->next;
	}

	if (p == item)
	{
		if (prev == NULL)
			prgtypes = p->next;
		else
			prev->next = p->next;

		free(p);
	}
}

static void rem_all(PRGTYPE **list)
{
	PRGTYPE *p, *next;

	p = *list;

	while (p != NULL)
	{
		next = p->next;
		free(p);
		p = next;
	}

	*list = NULL;
}

static void rem_all_prgtypes(void)
{
	rem_all(&prgtypes);
}

static void copy_all(PRGTYPE **copy)
{
	PRGTYPE *p;

	*copy = prgtypes;
	p = prgtypes;
	prgtypes = NULL;

	while (p != NULL)
	{
		add(p->name, p->appl_type, p->argv, p->path, END);
		p = p->next;
	}

	p = prgtypes;
	prgtypes = *copy;
	*copy = p;
}

static int cnt_types(void)
{
	int n = 1;
	PRGTYPE *p = prgtypes;

	while (p != NULL)
	{
		n++;
		p = p->next;
	}

	return n;
}

static PRGTYPE *get_item(int item)
{
	int i = 0;
	PRGTYPE *p = prgtypes;

	while ((p != NULL) && (i != item))
	{
		i++;
		p = p->next;
	}

	return p;
}

static int find_selected(void)
{
	int object;

	return ((object = xd_get_rbutton(setprgprefs, PTPARENT)) < 0) ? 0 : object - PTYPE1;
}

static void set_selector(SLIDER *slider, boolean draw, XDINFO *info)
{
	int i;
	PRGTYPE *p;
	OBJECT *o;

	for (i = 0; i < NLINES; i++)
	{
		o = &setprgprefs[PTYPE1 + i];

		if ((p = get_item(i + slider->line)) == NULL)
			*o->ob_spec.tedinfo->te_ptext = 0;
		else
			cv_fntoform(o, p->name);		/* HR 240103 */
	}

	if (draw == TRUE)
		xd_draw(info, PTPARENT, MAX_DEPTH);
}

static void set_prgtype(ApplType type)
{
	xd_set_rbutton(addprgtype, APTPAR2, APGEM + (int) type);
}

static ApplType get_prgtype(void)
{
	return (ApplType) (xd_get_rbutton(addprgtype, APTPAR2) - APGEM);
}

static void set_prgpath(boolean prgpath)
{
	xd_set_rbutton(addprgtype, APTPAR1, (prgpath == TRUE) ? ATPRG : ATWINDOW);
}

static boolean get_prgpath(void)
{
	return (xd_get_rbutton(addprgtype, APTPAR1) == ATPRG) ? TRUE : FALSE;
}

static boolean prgtype_dialog(char *name, ApplType *type, boolean *argv, boolean *path, boolean edit)
{
	int button;

	rsc_title(addprgtype, APTITLE, (edit == TRUE) ? DTEDTPRG : DTADDPRG);

	cv_fntoform(addprgtype + PRGNAME, name);			/* HR 240103 */
	set_prgtype(*type);
	set_prgpath(*path);

	if (*argv == TRUE)
		addprgtype[ATARGV].ob_state |= SELECTED;		/* HR 151102 */
	else
		addprgtype[ATARGV].ob_state &= ~SELECTED;

	button = xd_dialog(addprgtype, PRGNAME);

	if ((button == APTOK) && (strlen(prgname) != 0))
	{
		cv_formtofn(name, prgname);
		*type = get_prgtype();
		*path = get_prgpath();
		*argv = (addprgtype[ATARGV].ob_state & SELECTED) ? TRUE : FALSE;

		return TRUE;
	}
	else
		return FALSE;
}

void prg_setprefs(void)
{
	int button, prefs = options.cprefs & 0xFDDF;
	int i;
	XDINFO info;
	boolean stop = FALSE, redraw, argv, path;
	PRGTYPE *copy, *p;
	SNAME name;			/* HR 240203 */
	ApplType type;
	SLIDER sl_info;

	set_opt(setprgprefs, options.cprefs, TOS_KEY, PKEY);	/* DjV 014 020103 */
	set_opt(setprgprefs, options.cprefs, TOS_STDERR, PSTDERR);	/* DjV 014 020103 */

	copy_all(&copy);

	sl_info.type = 1;
	sl_info.up_arrow = PUP;
	sl_info.down_arrow = PDOWN;
	sl_info.slider = PSLIDER;
	sl_info.sparent = PSPARENT;
	sl_info.lines = NLINES;
	sl_info.n = cnt_types();
	sl_info.line = 0;
	sl_info.set_selector = set_selector;
	sl_info.first = PTYPE1;
	sl_info.findsel = find_selected;

	sl_init(setprgprefs, &sl_info);

	xd_open(setprgprefs, &info);

	while (stop == FALSE)
	{
		redraw = FALSE;

		button = sl_form_do(setprgprefs, 0, &sl_info, &info) & 0x7FFF;

		switch (button)
		{
		case PTADD:
			name[0] = 0;
			type = PGEM;
			argv = TRUE;
			path = TRUE;

			if (prgtype_dialog(name, &type, &argv, &path, FALSE) == TRUE)
			{
				i = find_selected() + sl_info.line;
				add(name, type, argv, path, i);
				sl_info.n = cnt_types();
				redraw = TRUE;
				sl_set_slider(setprgprefs, &sl_info, &info);
			}
			break;
		case PTDELETE:
			i = find_selected() + sl_info.line;
			if ((p = get_item(i)) != NULL)
			{
				rem(p);
				sl_info.n = cnt_types();
				redraw = TRUE;
				sl_set_slider(setprgprefs, &sl_info, &info);
			}
			break;
		case PTEDIT:
			i = find_selected() + sl_info.line;
			if ((p = get_item(i)) != NULL)
			{
				redraw = TRUE;
				prgtype_dialog(p->name, &p->appl_type, &p->argv, &p->path, TRUE);
			}
			break;
		default:
			stop = TRUE;
			break;
		}
		if (redraw == TRUE)
			set_selector(&sl_info, TRUE, &info);
		xd_change(&info, button, NORMAL, (stop == FALSE) ? 1 : 0);
	}

	xd_close(&info);

	if (button == POPTOK)
	{
		prefs |= ((setprgprefs[PKEY].ob_state & SELECTED) != 0) ? TOS_KEY : 0;
		prefs |= ((setprgprefs[PSTDERR].ob_state & SELECTED) != 0) ? TOS_STDERR : 0;
		options.cprefs = prefs;
		rem_all(&copy);
		wd_seticons();
	}
	else
	{
		rem_all_prgtypes();
		prgtypes = copy;
	}
}

void prg_init(void)
{
	prgtypes = NULL;
#ifdef MEMDEBUG
	atexit(rem_all_prgtypes);
#endif
}

void prg_default(void)
{
	rem_all_prgtypes();

#if _MINT_
	if (mint)				/* HR 151102 */
	{
		add("*.prg", PGEM, TRUE, TRUE, END);
		add("*.app", PGEM, TRUE, TRUE, END);
		add("*.gtp", PGTP, TRUE, TRUE, END);
		add("*.acc", PACC, TRUE, TRUE, END);
		add("*.tos", PTOS, TRUE, FALSE, END);
		add("*.ttp", PTTP, TRUE, FALSE, END);
	}
	else
#endif
	{
		add("*.PRG", PGEM, TRUE, TRUE, END);
		add("*.APP", PGEM, TRUE, TRUE, END);
		add("*.GTP", PGTP, TRUE, TRUE, END);
		add("*.TOS", PTOS, TRUE, FALSE, END);
		add("*.TTP", PTTP, TRUE, FALSE, END);
	}
}

#define PRG_PATH		8		/* 0 = window, 1 = programma */
#define TOS_PATH		16		/* 0 = window, 1 = programma */

int prg_load(XFILE *file)
{
	SINFO pt;
	SNAME name;				/* HR 240203 */
	boolean path;
	ApplType type;
	long n;
	int error;

	rem_all_prgtypes();

	do
	{
		if ((n = x_fread(file, &pt, sizeof(SINFO))) != sizeof(SINFO))
			return (n < 0) ? (int) n : EEOF;

		if (pt.appl_type != -1)
		{
			if (x_freadstr(file, name, sizeof(name), &error) == NULL)		/* HR 240103: max l */
				return error;

			type = (ApplType) pt.appl_type;

			path = (boolean) pt.path;

			if (add(name, type, (boolean) pt.argv, path, END) == NULL)
				return ERROR;
		}
	}
	while (pt.appl_type != -1);

	return 0;
}

int prg_save(XFILE *file)
{
	SINFO pt;
	PRGTYPE *p;
	long n;
	int error;

	p = prgtypes;

	while (p)
	{
		pt.appl_type = (int) p->appl_type;
		pt.argv = (unsigned int) p->argv;
		pt.path = (unsigned int) p->path;
		pt.resvd = 0;

		if ((n = x_fwrite(file, &pt, sizeof(SINFO))) < 0)
			return (int) n;

		if ((error = x_fwritestr(file, p->name)) < 0)
			return error;

		p = p->next;
	}

	pt.appl_type = -1;

	return ((n = x_fwrite(file, &pt, sizeof(SINFO))) < 0) ? (int) n : 0;
}
