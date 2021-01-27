/*  Copyright (c) 1992 - present by Henk Robbers Amsterdam.
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

#ifndef WIN_MENU_H
#define WIN_MENU_H

/*		Functions for driving own menu's for instance in windows
		If the mouse does'nt cover any of the logical menu items
		and a pull_down is down, it is automatically pushed.
		(removed from the screen)
*/

typedef struct
{
	bool evm_dir,	/* false wait for into, true wait for out of */
	     valid;		/* item attributes are valid (if false, must be set) */
	short mn,			/* menu_bar  item nr if on else false */
	    pn,			/* pull_down item nr if on else false */
	    en;			/* menu_entry item nr if on else false */
	RECT r,			/* MU_M? rectangle */
	     dsk,		/* desk rectangle */
	     b,			/* rectangle for whole bar */
	     t;			/* rectangle for titles */
	short hl,			/* VDI handle */
		wh;			/* window handle */
	OBJECT *m;		/* menu tree */
	void *d;		/* dump area for pull_down */
} M_S;				/* Menu Status */

typedef
void 	DRAWM			(M_S *ms, RECT men, RECT cl);
typedef
bool 	MENU_ACT		(M_S *ms,short titel,short item);

typedef struct		/* pass shortcut by value */
{
	char c[12];
} M_KEY;

typedef
short 	MENU_KS			(M_S *ms,M_KEY key,short *nmt);

bool	m_inside		(short x,short y,RECT o);
bool	is_outside		(RECT o,RECT i);
bool	is_inside		(RECT i,RECT o);
short 	change_ob		(OBJECT *ob,short item,RECT cl,bool sta);
RECT	ob_rect			(OBJECT *ob,short item);
bool 	menu_avail		(M_S *ms, short i);
void 	menu_dis		(OBJECT *m, short item, bool dis);
void	menu_init		(M_S *ms, short item, short hl, RECT desk);
short 	menu_evm		(M_S *ms, short evmask, short event);
short 	menu_title		(M_S *ms, bool state);
void	menu_place		(M_S *ms, RECT men);
void	menu_clear		(M_S *ms);
bool	menu_loop		(M_S *ms, MENU_ACT *act,short types[]);
bool	menu_mouse		(M_S *ms, short mx,short my);
short 	menu_button		(M_S *ms, short *mt);
MENU_KS menu_keys;

/* construct string from key according to
	conventions for shortcuts in menu entries */
M_KEY	m_key			(short kcode);

DRAWM	menu_draw;



#endif
