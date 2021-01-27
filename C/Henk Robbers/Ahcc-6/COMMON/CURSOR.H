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

/* 	CURSOR.H
 *	========
 */

extern MFORM kader16, kader8, lowpijl;

MUIS	m_kader;
CURSOR	std_cursor;
bool	make_visible	(IT *w,CINF vi,bool top);
bool	make_vis_cur	(IT *w);		/* for w->cu & make top */
bool	make_vis_top	(IT *w);		/* for w->cu & already top */
void	mtob			(IT *w, short mx, short my, long *pbx, long *pby);
void	write_curect	(short hl, short pxy[]);
void	xy_to_unit		(IT *w, short mx, short my, long *pbx, long *pby);
short	C_cmp			(CINF *a, CINF *b);
void	cussse			(IT *w, char *s);
void	sh_1			(char *s, CINF c);
void	sh_2			(char *s, CINF c1, CINF c2);
void	sh_3			(char *s, CINF c1, CINF c2, CINF c3);
bool	do_std_cursor	(IT *w, short kcode);
