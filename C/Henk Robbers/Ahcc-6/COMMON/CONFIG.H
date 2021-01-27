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
 *	CONFIG.H
 */

#ifndef CONFIG_H
#define CONFIG_H

CFGNEST file_cfg;		/* voorlopig de enige */

typedef struct
{
	bool
		wrd,		/* find words */
		any,		/* find anywhere */
		wpre,		/* find wordprefix */
		wpost,		/* find wordpostfix */
	    csens,		/* find is case sensative */
	    fbck,		/* find backward */
	    forw;		/* find forward */
}
FIND_OPTIONS;

typedef struct
{
	CFG_LOCAL loc;	/* local options */

	char *check;
	FIND_OPTIONS o;
	short
		hookscase,	/* word hooks case sensitivity */
	    surr,		/* select incl surrounding space */
	    deep,		/* recursive handling of folf=ders */
	    talk,		/* verbose     " */
	    once,		/* stop searching at first occurence */
	    rtun;		/* return is undo point. */

#if DIGGER
	MAX_dir ppupath;
	bool
		ppu,
		volat,		/* journal is volatile */
		sidf,		/* save cfg with objectfile */
		sizer,
		vslider,
		hslider;
	short width, height,
		tabber;
#endif

	bool s;			/* use clipboard in stead of private copy/paste buffer (BUFF), and see below. */
	bool a;			/* Autosave settings (at the end because its always there)(initializations last comma not needed) */
} CONFIG;

enum
{
	OGET, OSET
};

char *	radio_c		(FIND_OPTIONS *o);
void	opt_to_cfg	(OpEntry *tab,short ob, short db, OBJECT *otree, OBJECT *mtree);
void	radio_to_cfg(OpEntry *tab,short ob, short db, OBJECT *otree);
OpEntry *findopt	(OpEntry *tab,short ob, short db);
void	options		(OpEntry *tab,bool set);
void	listsets	(OpEntry *tab);
char *	crlf		(char *f);
char *	cfgname		(void);
extern OpEntry loctab[],settab[],ttdtab[],ttdcfg[];
extern OpEntry ttdfil[];
extern CONFIG cfg;


#endif
