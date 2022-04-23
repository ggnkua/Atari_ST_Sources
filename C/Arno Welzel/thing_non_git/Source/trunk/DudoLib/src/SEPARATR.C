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

#include "..\include\dudolib.h"

/*------------------------------------------------------------------*/
/*  private functions                                               */
/*------------------------------------------------------------------*/
WORD cdecl separator(PARMBLK *parmblock) {
	WORD pxy[4];
	UBPARM *ubparm;

	ubparm = (UBPARM *) parmblock->pb_parm;

	/*
	 * In der Menueleiste darf nicht mit angeschaltetem Clipping
	 * gezeichnet werden. Ist das Menue allerdings abgerissen,
	 * wie das bei Geneva der Fall sein kann, so muss natuerlich
	 * geclippt werden.
	 * Wenn in einem Menue gezeichnet werden soll, so sind pb_wc
	 * und pb_hc = 0.
	 */
	if (parmblock->pb_wc != 0 && parmblock->pb_hc != 0) {
		clipping(parmblock, TRUE);
		if (ubparm->isMenu == FALSE)
			clearObject(parmblock);
	}

	if (get3dLook() == FALSE) {
		vswr_mode(userdef->vdi_handle, MD_REPLACE);
		vsf_interior(userdef->vdi_handle, FIS_PATTERN);
		vsf_style(userdef->vdi_handle, 4);
		vsf_color(userdef->vdi_handle, BLACK);
	} else {
		vswr_mode(userdef->vdi_handle, MD_TRANS);
		vsl_color(userdef->vdi_handle, WHITE);
		vsf_color(userdef->vdi_handle, ubparm->te_rahmencol);
	}

	if (parmblock->pb_w >= parmblock->pb_h) {
		pxy[0] = parmblock->pb_x;
		pxy[1] = parmblock->pb_y + (parmblock->pb_h - ubparm->te_thickness) / 2;
		pxy[2] = pxy[0] + parmblock->pb_w - 1;
		pxy[3] = pxy[1] + ubparm->te_thickness - 1;
		v_bar(userdef->vdi_handle, pxy);

		if (get3dLook() == TRUE && ubparm->separator3d == TRUE) {
			pxy[3]++;
			pxy[1] = pxy[3];
			v_pline(userdef->vdi_handle, 2, pxy);
		}
	} else {
		pxy[0] = parmblock->pb_x + (parmblock->pb_w - ubparm->te_thickness) / 2;
		pxy[1] = parmblock->pb_y;
		pxy[2] = pxy[0] + ubparm->te_thickness - 1;
		pxy[3] = pxy[1] + parmblock->pb_h - 1;
		v_bar(userdef->vdi_handle, pxy);

		if (get3dLook() == TRUE && ubparm->separator3d == TRUE) {
			pxy[2]++;
			pxy[0] = pxy[2];
			v_pline(userdef->vdi_handle, 2, pxy);
		}
	}

	if (parmblock->pb_wc != 0 && parmblock->pb_hc != 0)
		clipping(parmblock, FALSE);

	return (0);
}
