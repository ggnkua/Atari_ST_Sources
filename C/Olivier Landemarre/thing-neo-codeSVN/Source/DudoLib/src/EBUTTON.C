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

/*------------------------------------------------------------------*/
/*  private functions                                               */
/*------------------------------------------------------------------*/

/**
 * Diese Methode zeichnet Exit-Buttons.
 *
 * @param *parmblock Zeiger auf die Parmblock-Struktur
 * @return liefert dem AES welche ob_state-Flags es noch bearbeiten muss (0 keine)
 */
WORD cdecl exitbutton(PARMBLK *parmblock) {
	WORD pxy[6], pxy1[6], extent[8], xPos, yPos, text_effects, du, frame_size,
			i;
	UBPARM *ubparm;

	ubparm = (UBPARM *) parmblock->pb_parm;

	clipping(parmblock, TRUE);

	vswr_mode(userdef->vdi_handle, MD_REPLACE);
	vst_alignment(userdef->vdi_handle, TA_LEFT, TA_TOP, &du, &du);

	if (get3dLook() == FALSE && (parmblock->pb_tree[parmblock->pb_obj].ob_flags & ~OF_LASTOB) != OF_TOUCHEXIT) {
		parmblock->pb_h -= 2;
		parmblock->pb_w -= 2;
	}

	/*
	 * Textposition bestimmen (die +3 und -6 muessen wegen der
	 * Vergroesserung der Buttons vor dem Redraw berechnet werden).
	 */
	vqt_extent(userdef->vdi_handle, ubparm->text, extent);
	xPos = parmblock->pb_x + 3 + (parmblock->pb_w - 6 - extent[4] - extent[6]) / 2;
	yPos = parmblock->pb_y + 3 + (parmblock->pb_h - 6 - extent[1] - extent[7]) / 2;

	pxy[0] = parmblock->pb_x;
	pxy[1] = parmblock->pb_y;
	pxy[2] = pxy[0] + parmblock->pb_w - 1;
	pxy[3] = pxy[1] + parmblock->pb_h - 1;

	if ((parmblock->pb_tree[parmblock->pb_obj].ob_flags & ~OF_LASTOB) == OF_TOUCHEXIT) {
		frame_size = 1;
	} else {
		if (parmblock->pb_tree[parmblock->pb_obj].ob_flags & OF_DEFAULT)
			frame_size = 3;
		else
			frame_size = 2;

		if (get3dLook() == TRUE)
			frame_size--;

		/* Auf richtige Rahmengroesse runterrechnen. */
		for (i = 3; i > frame_size; i--) {
			pxy[0]++;
			pxy[1]++;
			pxy[2]--;
			pxy[3]--;
		}
	}

	vsf_interior(userdef->vdi_handle, FIS_SOLID);
	vsf_color(userdef->vdi_handle, G_BLACK);
	v_bar(userdef->vdi_handle, pxy);
	for (i = 1; i <= frame_size; i++) {
		pxy[0]++;
		pxy[1]++;
		pxy[2]--;
		pxy[3]--;
	}

	if (get3dLook() == FALSE) {
		if (parmblock->pb_currstate & OS_SELECTED) {
			ubparm->te_textcol = G_WHITE;
		} else {
			vsf_color(userdef->vdi_handle, G_WHITE);
			v_bar(userdef->vdi_handle, pxy);

			ubparm->te_textcol = G_BLACK;
		}
	} else {
		vsf_color(userdef->vdi_handle, userdef->backgrd_color);
		v_bar(userdef->vdi_handle, pxy);

		pxy1[0] = pxy[0];
		pxy1[1] = pxy[3];
		pxy1[2] = pxy[0];
		pxy1[3] = pxy[1];
		pxy1[4] = pxy[2] - 1;
		pxy1[5] = pxy[1];

		if (parmblock->pb_currstate & OS_SELECTED)
			vsl_color(userdef->vdi_handle, G_LBLACK);
		else
			vsl_color(userdef->vdi_handle, G_WHITE);
		v_pline(userdef->vdi_handle, 3, pxy1);

		pxy1[0]++;
		pxy1[2] = pxy[2];
		pxy1[3] = pxy[3];
		pxy1[4]++;

		if (parmblock->pb_currstate & OS_SELECTED)
			vsl_color(userdef->vdi_handle, G_WHITE);
		else
			vsl_color(userdef->vdi_handle, G_LBLACK);
		v_pline(userdef->vdi_handle, 3, pxy1);

		if (parmblock->pb_currstate & OS_SELECTED) {
			xPos++;
			yPos++;
		}
		ubparm->te_textcol = G_BLACK;
	}

	vswr_mode(userdef->vdi_handle, MD_TRANS);
	if (get3dLook() == TRUE && (parmblock->pb_currstate & OS_DISABLED)) {
		text_effects = TF_LIGHTENED;
		v_xgtext(xPos, yPos, text_effects, ubparm, parmblock);
		parmblock->pb_currstate &= ~OS_DISABLED;
	} else {
		text_effects = TF_NORMAL;
		v_xgtext(xPos, yPos, text_effects, ubparm, parmblock);
	}

	clipping(parmblock, FALSE);

	parmblock->pb_currstate &= ~OS_SELECTED;
	return (parmblock->pb_currstate);
}
