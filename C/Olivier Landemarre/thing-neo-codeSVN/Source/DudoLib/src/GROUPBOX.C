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
 * Diese Methode zeichnet Gruppenboxen mit zugehoeriger Ueberschrift.
 *
 * +- Test --------+
 * |  o aaaaa      |
 * |  o bbbbb      |
 * |  o ccccc      |
 * +---------------+
 *
 * @param *parmblock Zeiger auf die Parmblock-Struktur
 * @return liefert dem AES welche ob_state-Flags es noch bearbeiten muss (0 keine)
 */
WORD cdecl groupbox(PARMBLK *parmblock) {
	WORD pxy[12], extent[8], text_width, x_pos, du;
	UBPARM *ubparm;

	ubparm = (UBPARM *) parmblock->pb_parm;

	clipping(parmblock, TRUE);
	clearObject(parmblock);

	vswr_mode(userdef->vdi_handle, MD_TRANS);
	vsl_color(userdef->vdi_handle, ubparm->te_rahmencol);

	vst_alignment(userdef->vdi_handle, ubparm->te_just, TA_TOP, &du, &du);
	vst_effects(userdef->vdi_handle, TF_NORMAL);
	vqt_extent(userdef->vdi_handle, ubparm->text, extent);
	text_width = max(extent[2], extent[4]);

	x_pos = parmblock->pb_x;
	switch (ubparm->te_just) {
	case TA_LEFT:
		x_pos += userdef->spaceChar_w;
		pxy[0] = x_pos - 1;
		break;

	case TA_RIGHT:
		x_pos += parmblock->pb_w - userdef->spaceChar_w - 1;
		pxy[0] = x_pos - text_width - 1;
		break;

	case TA_CENTER:
		x_pos += (parmblock->pb_w / 2) - 1;
		pxy[0] = x_pos - text_width / 2 - 1;
		break;
	}

	pxy[1] = parmblock->pb_y + userdef->char_h / 2 - 1;
	pxy[2] = parmblock->pb_x;
	pxy[3] = pxy[1];
	pxy[4] = pxy[2];
	pxy[5] = parmblock->pb_y + parmblock->pb_h - 1;
	pxy[6] = pxy[2] + parmblock->pb_w - 1;
	pxy[7] = pxy[5];
	pxy[8] = pxy[6];
	pxy[9] = pxy[1];
	pxy[10] = pxy[0] + text_width;
	pxy[11] = pxy[1];
	v_pline(userdef->vdi_handle, 6, pxy);

	if (get3dLook() == TRUE) {
		/* weisser Rahmen */
		pxy[1]++;
		pxy[2]++;
		pxy[3]++; /* = pxy[1];*/
		pxy[4]++; /* = pxy[2];*/
		pxy[5]++;
		pxy[6]++;
		pxy[7]++; /* = pxy[5];*/
		pxy[8]++; /* = pxy[6];*/
		pxy[9]++; /* = pxy[1];*/
		pxy[11]++;

		vsl_color(userdef->vdi_handle, G_WHITE);
		v_pline(userdef->vdi_handle, 6, pxy);

		pxy[0] = pxy[2] = parmblock->pb_x + 1;
		pxy[1] = pxy[3] = parmblock->pb_y + parmblock->pb_h - 1;
		vsl_color(userdef->vdi_handle, userdef->backgrd_color);
		v_pline(userdef->vdi_handle, 2, pxy);
		pxy[0] = pxy[2] = parmblock->pb_x + parmblock->pb_w - 1;
		pxy[1] = pxy[3] = parmblock->pb_y + (userdef->char_h >> 1);
		v_pline(userdef->vdi_handle, 2, pxy);
	}

	vst_color(userdef->vdi_handle, G_WHITE);
	v_gtext(userdef->vdi_handle, x_pos + 1, parmblock->pb_y + 1, ubparm->text);

	vst_color(userdef->vdi_handle, ubparm->te_textcol);
	v_gtext(userdef->vdi_handle, x_pos, parmblock->pb_y, ubparm->text);

	clipping(parmblock, FALSE);

	return (0);
}
