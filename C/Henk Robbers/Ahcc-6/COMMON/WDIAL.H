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

/*	WDIAL.H
 *  =======
 */

#define FASTRACK 1				/* rack up/down by fast copy ( vro_cpyfm() ) */

extern short edcur;

void	wdial_draw		(IT *w, short start),
		wdial_change	(IT *w, bool draw, short start, short item, short fm, short fv, short sm, short sv),
		wdial_xytoi		(IT *w, short mx, short my),
		wdial_edob		(IT *w, short edob),
		wdial_setcur	(IT *w, short edob);
VpW		set_dialinfs,
		wdial_itotmpl;
VpV		close_dials;
IT *	wind_dial		(INFO_T t, short blok);
IT *	create_dialw	(char *name,
						 short   tree,
						 OBJECT *o,
						 short item,
						 WINIT winit,
						 VpW fresh,
						 DEXIT d_do);

BUTTON	wdial_button;
KEYBD	wdial_keybd;
CURSOR	wdial_cur;
