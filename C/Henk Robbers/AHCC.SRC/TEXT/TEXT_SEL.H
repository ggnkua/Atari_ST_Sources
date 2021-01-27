/* Copyright (c) 1990 - present by H. Robbers Amsterdam.
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

/* 	TXT_SEL.H
 *	=========
 */

#define T (unsigned char)		/* keep this local */
#define mcmp_nonw(s) (chcl[T*s] <  LOWEST_W)
#define mcmp_word(s) (chcl[T*s] >= LOWEST_W)
#define mcmp_lcom(s) (* s    eq '/' and *(s+1) eq '*')
#define mcmp_ncom(s) (* s    eq '/' and *(s+1) eq '/')
#define mcmp_rcom(s) (*(s-1) eq '*' and * s    eq '/')

#define HKSL 16
typedef struct		/* preset if not in KIT's dialogue */
{
	TEDINFO *twl,     *twr;			/* viz */
	char	 swl[HKSL],swr[HKSL];	/* tedinfo->text */
	short      owl,      owr;			/* object no's of FTEXT's */
} HOOKS;

typedef bool SEL_CMP (char *f);
typedef bool SEL_WCMP(char *fs, char *fe);

SEL_CMP		cmp_space,cmp_word,cmp_nonw;
SELECT		text_select;
DESELECT	text_deselect;
XSELECT		text_wselect;
BUTTON		txtsel_button;
DRAG_SEL	drag_selection;

bool	repair_various		(IT *w, short mt);
bool	repair_proto		(IT *w);
void	select_and_get_word	(IT *w, char *word);
void	printselection		(IT *w);
void	scroll				(IT *w, short *mx, short *my);
bool	str_any				(IT *w, CINF *cf, SEL_CMP *cmp, NEXT_CH *nxt);
void	str_surr			(IT *w, CINF *fs, CINF *fe, SEL_CMP *cmp);
