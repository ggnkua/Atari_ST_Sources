/*  Copyright (c) 1990 - present by Henk Robbers Amsterdam.
 *
 * This file is part of AHCC.
 *
 * AHCC is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * AHCC is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with AHCC; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/*
 *	CONFIG.C
 *
 */

#include <string.h>


#include "mallocs.h"
#include "aaaa_lib.h"
#include "hierarch.h"
#include "aaaa.h"
#ifdef JOURNAL
#include "journal.h"
#endif
#include "config.h"

#ifdef WINDIAL
#include "wdial.h"
#endif

#if GEMSHELL || TEXTFILE || BINARY
#include "kit.h"
#endif

#if DIGGER
#include "digger/ttd_kit.h"
#include "digger/dig.h"
#endif

#include "ahcm.h"

/*
 *	Configuration default values.
 *  These values are used if they are neither defined in the
 *  config table or in the resource.
 */
global
CONFIG cfg =
{
	{
		' ',		/* vistab */
		-1,			/* vistco */
		4,			/* tabn */
		4,			/* tabp */
		true,		/* tabl */
		4,			/* tabs */
		MAXL,		/* split */
		true,		/* lib_str */
		true,		/* rootname */
		true,		/* autoindent */
		false,		/* trail */
		false,		/* boldtag */
		false,		/* line numbers */
		false,		/* small font */
		{false,0,1,2},		/* scroll info's */
		{true, 1,2,3}
	},
	"",		/*check*/
	{
		1, 			/* word */
		0,			/* any */
		0,			/* prefix */
		0,			/* postfix */
		1,			/* case */
		0,			/* bck */
		1,			/* forw */
	},
	0,			/* surr */
	1,			/* deep */
	0,			/* talk */
	0,			/* once */
	0,			/* hkcase */
	0,			/* rtun */
#if DIGGER
	"PPU2O",	/* ppupath */
	false,		/* ppu */
	true,			/* volatile journal */
	false,
	true, true, true,				/* sizer -- hslider */
	79, 0, 8,
#endif
	true			/* autosave: always there, so at the end for comma's above */
};

#ifdef GEMSHELL
extern
OBJECT *db2;		/*	b2 debug options dialogue */
#endif

#if 0
/* eenvoudiger */
global
char * radio_c(FIND_OPTIONS *o) /* char */
{
static char str[16];
	char *s = str;

	*s++ = '(';
	if (o->wrd)		*s++ = 'W';
	if (o->wpre)	*s++ = 'B';
	if (o->wpost)	*s++ = 'E';
	if (o->csens)	*s++ = 'C';

	if (*(s-1) eq '(')
		return "";	/* nothing */

	*s++ = ')';
	*s = 0;
	return str;
}
#else
/* mooier */
char * radio_c(FIND_OPTIONS *o)	/* comment */
{
static char str[72];
	char *s = str;

	*s++ = '(';
	*s = 0;
	if (o->csens)	strcat(s, "Case sensitive, ");
	if (o->wrd)		strcat(s, "Word, ");
	if (o->wpre)	strcat(s, "Prefix, ");
	if (o->wpost)	strcat(s, "Postfix, ");

	if (*(s+strlen(s)-2) ne ',')
		return "";	/* nothing */

	*(s+strlen(s)-2) = ')';		/* last , --> ) */
	return str;
}
#endif

static
void setopt(OpEntry *tab, OBJECT *otree, OBJECT *mtree)
{
	short *v = tab->a;

	if (tab->ob and otree)
	{
		if (*v)
			otree[tab->ob].state|= SELECTED;
		else
			otree[tab->ob].state&=~SELECTED;
	}

	if (tab->menuob and mtree)
	{
		if (*v)
			mtree[tab->menuob].state|= CHECKED;
		else
			mtree[tab->menuob].state&=~CHECKED;
#ifdef WINDIAL
		if (tab->ob and otree)
			wdial_draw(get_it(-1, tab->ty), tab->ob);
#endif
	}
}

static
void getopt(OpEntry *tab, OBJECT *otree, OBJECT *mtree)
{
	short *v = tab->a;
	if (tab->ob and otree)
		*v = (otree[tab->ob    ].state&SELECTED) ne 0 ? 1 : 0;
	if (tab->menuob and mtree)
		*v = (mtree[tab->menuob].state&CHECKED ) ne 0 ? 1 : 0;
}

global
OpEntry *findopt(OpEntry *tab, short ob, short db)
{
	while(tab->s.str[0])
		if (   (tab->ob     eq ob and tab->ty     eq db)
		    or (tab->menuob eq ob and tab->menuty eq db)
		   )
			return tab;
		else
			tab++;

	return nil;
}

static
void set_cfg(OpEntry *tab, short ob, short db, OBJECT *otree)
{
	short *v = tab->a;

	if   (tab->menuty eq db)
		*v ^= 1;
	elif (tab->ty     eq db)
		*v = otree[ob].state & SELECTED;
}

global
void opt_to_cfg(OpEntry *tab, short ob, short db, OBJECT *otree, OBJECT *mtree)
{
	if (tab)		/* a window might not have a local tab */
	{
		tab=findopt(tab, ob, db);
		if (tab)
		{
			set_cfg(tab, ob, db, otree);
			setopt(tab,  otree,  mtree);		/* set state in trees */
		}
	}
}

static
void radio_opt(OpEntry *tab, short ob, short db, OBJECT *otree)
{
	short xob, p;

	p = get_parent(otree,ob);

	if (p > 0)
	{
		xob = otree[p].head;
		do
		{
			OBJECT *nob = otree + xob;

			if (nob->flags & RBUTTON)
				opt_to_cfg(tab, xob, db, otree, nil);

			if (xob eq otree[p].tail)
				break;
			xob = nob->next;
		}od
	}
}

global
void radio_to_cfg(OpEntry *tab, short ob, short db, OBJECT *otree)
{
	OpEntry *radio = tab;

	if (tab)		/* a window might not have a local tab */
	{
		tab=findopt(tab, ob, db);
		if (tab ne nil)
		{
			set_cfg (tab,    ob, db, otree);
			radio_opt(radio, ob, db, otree);
		}
	}
}

global
void options(OpEntry *tab, bool set)
{
	while(tab->s.str[0])
	{
		OBJECT *otree = nil, *mtree = nil;
		if ( tab->s.o.srt eq 'd' and (tab->menuob or tab->ob))
		{
#ifdef AMENU
			if (tab->menuob and tab->menuty eq AMENU)
				mtree = Menu;
#endif
#ifdef OMENU
			if (tab->menuob and tab->menuty eq OMENU)
				mtree = dmen.m;
#endif
#ifdef JOURNAL
			if (tab->menuob and tab->menuty eq JOURNAL)
				mtree = jmen.m;
#endif
#if defined BUGGER && defined GEMSHELL && DEBUG
			if (tab->ob and tab->ty eq BUGGER)
				otree = db2;
#endif
#ifdef KIT
			if (tab->ob and tab->ty eq KIT)
				otree = pkit.tree;
#endif
#ifdef TTD_KIT
			if (tab->ob and tab->ty eq TTD_KIT)
				otree = pkit.tree;
#endif

			if (mtree or otree)
				if (set)
					setopt(tab, otree, mtree);
				else
					getopt(tab, otree, mtree);
		}
		tab++;
	}
}

#ifdef JOURNAL
global
void listsets(OpEntry tab[])
{
	char s[512];
	while(tab->s.str[0])
	{
		if (tab->a and tab->max >= 0)
		{
			if (tab->s.o.srt eq 's')
				sprintf(s, tab->s.str, tab->a);
			else
				sprintf(s, tab->s.str, *(short *)tab->a);
			if (tab->s.o.srt ne '{')
				send_msg(s);
		}
		tab++;
	}
}
#endif

global
void changeconfig(OpEntry *tab, void *old, void *new)
{
	while(tab->s.str[0])
	{
		if (    tab->a
		    and tab->s.str[0] ne '{'
		    and tab->s.o.srt  ne '{')
		{
			(long)tab->a -= (long)old;
			(long)tab->a += (long)new;
		}
		tab++;
	}
}

global
OpEntry *copyconfig(OpEntry *tab, void *old, void *new)
{
	short l = 1;
	OpEntry *newtab, *this = tab;

	while(this->s.str[0]) l++, this++;		/* count entries */

	l *= sizeof(OpEntry);
	newtab = mmalloc(l, "while opening", "not opened", AH_COPYCONFIG);
	if (newtab)
	{
		memcpy(newtab, tab, l);
		changeconfig(newtab, old, new);
	}

	return newtab;
}

global
char *cfgname(void)	/* ex project file */
{
	static MAX_dir nm;
	strcpy(nm, prg_name);
	strlwr(nm);
	strcat(nm, ".cfg");
	return nm;
}


