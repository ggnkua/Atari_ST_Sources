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

/**
 * Diese Methode zeichnet transparenten Text.
 *
 * @param *parmblock Zeiger auf die Parmblock-Struktur
 * @return liefert dem AES welche ob_state-Flags es noch bearbeiten muss (0 keine)
 */
WORD cdecl transtext(PARMBLK *parmblock) {
	WORD text_effects, tx, du;
	UBPARM *ubparm;

	ubparm = (UBPARM *) parmblock->pb_parm;

	clipping(parmblock, TRUE);
	clearObject(parmblock);

	tx = parmblock->pb_x;
	switch (ubparm->te_just) {
	case TA_LEFT:
		break;
	case TA_CENTER:
		tx += parmblock->pb_w / 2;
		break;
	case TA_RIGHT:
		tx += parmblock->pb_w;
		break;
	}

	vswr_mode(userdef->vdi_handle, MD_TRANS);
	vst_alignment(userdef->vdi_handle, ubparm->te_just, TA_TOP, &du, &du);

	if (get3dLook() == TRUE && (parmblock->pb_currstate & OS_DISABLED)) {
		text_effects = TF_LIGHTENED;
		parmblock->pb_currstate &= ~OS_DISABLED;
		v_xgtext(tx, parmblock->pb_y, text_effects, ubparm, parmblock);
	} else {
		text_effects = TF_NORMAL;
		v_xgtext(tx, parmblock->pb_y, text_effects, ubparm, parmblock);
	}

	if (parmblock->pb_currstate & OS_CHECKED) {
		BYTE *p;
		WORD pos;

		p = ubparm->text;
		pos = ubparm->uline_pos;
		ubparm->text = "\010";
		ubparm->uline_pos = -1;
		vst_alignment(userdef->vdi_handle, TA_LEFT, TA_TOP, &du, &du);
		v_xgtext(parmblock->pb_x + 1, parmblock->pb_y, text_effects, ubparm, parmblock);
		ubparm->text = p;
		ubparm->uline_pos = pos;
		parmblock->pb_currstate &= ~OS_CHECKED;
	}

	if (parmblock->pb_currstate & OS_SELECTED) {
		WORD pxy[4];

		vswr_mode(userdef->vdi_handle, MD_XOR);
		vsf_perimeter(userdef->vdi_handle, 0);
		vsf_interior(userdef->vdi_handle, FIS_SOLID);
		vsf_color(userdef->vdi_handle, G_BLACK);
		pxy[0] = parmblock->pb_x;
		pxy[1] = parmblock->pb_y;
		pxy[2] = pxy[0] + parmblock->pb_w - 1;
		pxy[3] = pxy[1] + parmblock->pb_h - 1;
		v_bar(userdef->vdi_handle, pxy);
		vswr_mode(userdef->vdi_handle, MD_REPLACE);
		parmblock->pb_currstate &= ~OS_SELECTED;
	}

	clipping(parmblock, FALSE);

	return (parmblock->pb_currstate);
}
