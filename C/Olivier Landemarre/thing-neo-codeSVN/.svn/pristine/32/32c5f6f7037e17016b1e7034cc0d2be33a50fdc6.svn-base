/**
 * DudoLib - Dirchs user defined object library
 * Copyright (C) 1994-2012 Dirk Klemmt
 *
 * This program is free software: you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation, either
 * version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this program. If not, see
 * <http://www.gnu.org/licenses/>.
 *
 * @copyright  Dirk Klemmt 1994-2012
 * @author     Dirk Klemmt
 * @license    LGPL
 */

#define FORCE_GEMLIB_UDEF
#include "..\include\dudolib.h"

extern UWORD arupnorm[64], arupnormdis[64], arupsel[64], ardnnorm[64],
		ardnnormdis[64], ardnsel[64], arltnorm[64], arltnormdis[64],
		arltsel[64], arrtnorm[64], arrtnormdis[64], arrtsel[64];

/**
 *
 */
WORD cdecl arrowbutton(PARMBLK *parmblock) {
	WORD pxy[4], cppxy[8], box_breite, color_index[] = { G_BLACK, G_WHITE };
	UBPARM *ubparm;
	MFDB screen, arrow;

	ubparm = (UBPARM *) parmblock->pb_parm;

	clipping(parmblock, TRUE);

	if (userdef->char_w == 8)
		box_breite = 2 * userdef->char_w;
	else
		box_breite = userdef->char_w;

	if (userdef->backgrd_color != G_WHITE) {
		/*
		 * Damit keine Reste von DISABLED mehr da sind, muessen wir das
		 * ganze Objekt neuzeichnen.
		 */
		if (parmblock->pb_prevstate & OS_DISABLED || parmblock->pb_currstate & OS_DISABLED) {
			pxy[0] = parmblock->pb_x;
			pxy[1] = parmblock->pb_y;
			pxy[2] = parmblock->pb_x + parmblock->pb_w;
			pxy[3] = parmblock->pb_y + parmblock->pb_h;

			vsf_color(userdef->vdi_handle, userdef->backgrd_color);
			vsf_interior(userdef->vdi_handle, FIS_SOLID);
			v_bar(userdef->vdi_handle, pxy);
		}
	}

	arrow.fd_w = 16;
	arrow.fd_h = (userdef->char_h < 16) ? 8 : 16;
	arrow.fd_wdwidth = 1;
	arrow.fd_stand = 0;
	arrow.fd_nplanes = 1;

	screen.fd_addr = NULL;

	/* Quellraster */
	cppxy[0] = 0;
	cppxy[1] = 0;
	cppxy[2] = 15;
	cppxy[3] = userdef->char_h - 1;

	/* Zielraster */
	cppxy[4] = parmblock->pb_x;
	cppxy[5] = parmblock->pb_y;
	cppxy[6] = cppxy[4] + box_breite - 1;
	cppxy[7] = cppxy[5] + parmblock->pb_h - 1;

	/* richtigen Pfeil waehlen */
	switch ((WORD) ubparm->text[0]) {
	case '':
		if (parmblock->pb_currstate & OS_SELECTED)
			arrow.fd_addr = (VOID *) arupsel;
		else {
			if (parmblock->pb_currstate & OS_DISABLED)
				arrow.fd_addr = (VOID *) arupnormdis;
			else
				arrow.fd_addr = (VOID *) arupnorm;
		}
		break;

	case '':
		if (parmblock->pb_currstate & OS_SELECTED)
			arrow.fd_addr = (VOID *) ardnsel;
		else {
			if (parmblock->pb_currstate & OS_DISABLED)
				arrow.fd_addr = (VOID *) ardnnormdis;
			else
				arrow.fd_addr = (VOID *) ardnnorm;
		}
		break;

	case 3/*''*/:
		if (parmblock->pb_currstate & OS_SELECTED)
			arrow.fd_addr = (VOID *) arrtsel;
		else {
			if (parmblock->pb_currstate & OS_DISABLED)
				arrow.fd_addr = (VOID *) arrtnormdis;
			else
				arrow.fd_addr = (VOID *) arrtnorm;
		}
		break;

	case '':
		if (parmblock->pb_currstate & OS_SELECTED)
			arrow.fd_addr = (VOID *) arltsel;
		else {
			if (parmblock->pb_currstate & OS_DISABLED)
				arrow.fd_addr = (VOID *) arltnormdis;
			else
				arrow.fd_addr = (VOID *) arltnorm;
		}
		break;

	default:
		arrow.fd_addr = (VOID *) arltsel;
	}
	vrt_cpyfm(userdef->vdi_handle, MD_TRANS, cppxy, &arrow, &screen, color_index);

	clipping(parmblock, FALSE);

	parmblock->pb_currstate &= ~OS_SELECTED;
	parmblock->pb_currstate &= ~OS_DISABLED;

	return (parmblock->pb_currstate);
}
