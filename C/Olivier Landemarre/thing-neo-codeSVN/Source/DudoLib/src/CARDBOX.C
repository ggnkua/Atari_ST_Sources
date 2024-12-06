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
static int off = 2;

/**
 * Diese Methode zeichnet den unteren Teil der Karteikarte.
 *
 *  +-----+
 *  |     |
 * +---------------+
 * |/ / / / / / / /|
 * |/ / / / / / / /|
 * |/ / / / / / / /|
 * +---------------+
 *
 * @param *parmblock Zeiger auf die Parmblock-Struktur
 * @return liefert dem AES welche ob_state-Flags es noch bearbeiten muss (0 keine)
 */
WORD cdecl cardbox(PARMBLK *parmblock) {
	WORD pxy[8];

	clipping(parmblock, TRUE);

	pxy[0] = parmblock->pb_x;
	pxy[1] = parmblock->pb_y + 1;
	pxy[2] = pxy[0] + parmblock->pb_w - 1;
	pxy[3] = pxy[1] + parmblock->pb_h - 2;

	/* Hintergrund */
	vswr_mode(userdef->vdi_handle, MD_REPLACE);
	vsf_interior(userdef->vdi_handle, FIS_SOLID);
	vsf_color(userdef->vdi_handle, userdef->backgrd_color);
	v_bar(userdef->vdi_handle, pxy);

	/* Umrandung der Karte */
	pxy[0] = parmblock->pb_x;
	pxy[1] = parmblock->pb_y;
	pxy[2] = pxy[0];
	pxy[3] = pxy[1] + parmblock->pb_h - 1;
	pxy[4] = pxy[2] + parmblock->pb_w - off - 1;
	if (get3dLook() == FALSE)
		pxy[3] -= off;
	pxy[5] = pxy[3];
	pxy[6] = pxy[4];
	pxy[7] = pxy[1];
	vsl_color(userdef->vdi_handle, G_BLACK);
	v_pline(userdef->vdi_handle, 4, pxy);

	if (get3dLook() == FALSE) {
		/* Schatten */
		pxy[0] = parmblock->pb_x + off;
		pxy[1] = parmblock->pb_y + parmblock->pb_h - 2;
		pxy[2] = parmblock->pb_x + parmblock->pb_w - 2;
		pxy[3] = pxy[1];
		pxy[4] = pxy[2];
		pxy[5] = parmblock->pb_y + off;
		v_pline(userdef->vdi_handle, 3, pxy);

		pxy[1]++;
		pxy[2]++;
		pxy[3] = pxy[1];
		pxy[4] = pxy[2];
		v_pline(userdef->vdi_handle, 3, pxy);
	} else {
		/* weisser Lichteffekt */
		pxy[0] += 1;
		pxy[2] = pxy[0];
		pxy[3] = pxy[1] + parmblock->pb_h - 3;
		vsl_color(userdef->vdi_handle, G_WHITE);
		v_pline(userdef->vdi_handle, 2, pxy);

		/* dunkelgrauer Schatteneffekt */
		pxy[0] = parmblock->pb_x + 1;
		pxy[1] = parmblock->pb_y + parmblock->pb_h - 2;
		pxy[2] = parmblock->pb_x + parmblock->pb_w - 2 - 2;
		pxy[3] = pxy[1];
		pxy[4] = pxy[2];
		pxy[5] = parmblock->pb_y;
		vsl_color(userdef->vdi_handle, G_LBLACK);
		v_pline(userdef->vdi_handle, 3, pxy);
	}

	clipping(parmblock, FALSE);

	return (0);
}

/**
 * Diese Methode zeichnet den Reiter der Karteikarte.
 *
 *  +-----+
 *  |/ / /|
 * +---------------+
 * |               |
 * |               |
 * |               |
 * +---------------+
 *
 * @param *parmblock Zeiger auf die Parmblock-Struktur
 * @return liefert dem AES welche ob_state-Flags es noch bearbeiten muss (0 keine)
 */
WORD cdecl cardtitle(PARMBLK *parmblock) {
	WORD pxy[12], extent[8], xpos, ypos, text_effects, du;
	UBPARM *ubparm;

	ubparm = (UBPARM *) parmblock->pb_parm;

	clipping(parmblock, TRUE);
	clearObject(parmblock);

	vswr_mode(userdef->vdi_handle, MD_REPLACE);
	vst_alignment(userdef->vdi_handle, TA_LEFT, TA_TOP, &du, &du);
	vsf_interior(userdef->vdi_handle, FIS_SOLID);
	vsl_color(userdef->vdi_handle, G_BLACK);

	/* Textposition bestimmen. */
	vqt_extent(userdef->vdi_handle, ubparm->text, extent);
	xpos = parmblock->pb_x + (parmblock->pb_w - extent[4] - extent[6]) / 2;
	ypos = parmblock->pb_y + (parmblock->pb_h - extent[1] - extent[7]) / 2;

	if (get3dLook() == FALSE) {
		pxy[0] = parmblock->pb_x;
		pxy[1] = parmblock->pb_y + parmblock->pb_h - 1;
		pxy[2] = pxy[0];
		pxy[3] = parmblock->pb_y;
		pxy[4] = parmblock->pb_x + parmblock->pb_w - off - 2;
		pxy[5] = pxy[3];
		pxy[6] = pxy[4];
		pxy[7] = pxy[1];

		if (parmblock->pb_currstate & OS_SELECTED) {
			pxy[8] = pxy[0] + parmblock->pb_w - 1;
			pxy[9] = pxy[1];
			v_pline(userdef->vdi_handle, 5, pxy);

			/* Schatten */
			vsf_color(userdef->vdi_handle, G_BLACK);
			pxy[0] = parmblock->pb_x + parmblock->pb_w - 3;
			pxy[1] = parmblock->pb_y + 2;
			pxy[2] = pxy[0] + 1;
			pxy[3] = parmblock->pb_y + parmblock->pb_h - 1;
			v_bar(userdef->vdi_handle, pxy);
		} else {
			pxy[0] += 3;
			pxy[2] = pxy[0];
			pxy[3] += 3;
			pxy[4]++;
			pxy[5] = pxy[3];
			pxy[6] = pxy[4];
			v_pline(userdef->vdi_handle, 4, pxy);

			/* Abschlusslinie am Boden */
			pxy[0] = parmblock->pb_x;
			pxy[1] = parmblock->pb_y + parmblock->pb_h - 1;
			pxy[2] = pxy[0] + parmblock->pb_w - 1;
			pxy[3] = pxy[1];
			v_pline(userdef->vdi_handle, 2, pxy);
		}
	} else {
		/* schwarze Umrandung bei SELECTED */
		pxy[0] = parmblock->pb_x;
		pxy[1] = parmblock->pb_y + parmblock->pb_h - 2;
		pxy[3] = parmblock->pb_y + 3;
		pxy[6] = pxy[0] + parmblock->pb_w - 1 - 3;
		pxy[8] = pxy[0] + parmblock->pb_w - 1;

		/* Positions-Korrektur, wenn nicht SELECTED */
		if ((parmblock->pb_currstate & OS_SELECTED) == FALSE) {
			pxy[0] += 2;
			pxy[1]--;
			pxy[3] += 3;
			pxy[6] -= 2;
			pxy[8] -= 2;
		}

		pxy[2] = pxy[0];
		pxy[4] = pxy[2] + 3;
		pxy[5] = pxy[3] - 3;
		pxy[7] = pxy[5];
		pxy[9] = pxy[3];
		pxy[10] = pxy[8];
		pxy[11] = pxy[1];
		vsl_color(userdef->vdi_handle, G_BLACK);
		v_pline(userdef->vdi_handle, 6, pxy);

		/* weisser Lichteffekt */
		pxy[0]++;
		pxy[2]++;
		pxy[5]++;
		pxy[6]--;
		pxy[7]++;
		vsl_color(userdef->vdi_handle, G_WHITE);
		v_pline(userdef->vdi_handle, 4, pxy);

		/* dunkelgrauer Schatteneffekt */
		pxy[0] = pxy[6] + 1;
		pxy[1] = pxy[7];
		pxy[2] = pxy[8] - 1;
		pxy[3] = pxy[9];
		pxy[4] = pxy[10] - 1;
		pxy[5] = pxy[11];
		vsl_color(userdef->vdi_handle, G_LBLACK);
		v_pline(userdef->vdi_handle, 3, pxy);

		if ((parmblock->pb_currstate & OS_SELECTED) == FALSE) {
			/* Abschlusslinie am Boden */
			pxy[0] = parmblock->pb_x;
			pxy[1] = parmblock->pb_y + parmblock->pb_h - 2;
			pxy[2] = pxy[0] + parmblock->pb_w - 1;
			pxy[3] = pxy[1];
			pxy[4] = pxy[2];
			pxy[5] = pxy[3] + 1;
			vsl_color(userdef->vdi_handle, G_BLACK);
			v_pline(userdef->vdi_handle, 2, pxy);

			pxy[1] = parmblock->pb_y + parmblock->pb_h - 1;
			pxy[3] = pxy[1];
			vsl_color(userdef->vdi_handle, G_WHITE);
			v_pline(userdef->vdi_handle, 2, pxy);
		}
	}

	/* Textposition anpassen */
	if (parmblock->pb_currstate & OS_SELECTED) {
/*		xpos--;*/
	} else {
		xpos++;
		ypos += 2;
	}
	vswr_mode(userdef->vdi_handle, MD_TRANS);
	vst_color(userdef->vdi_handle, G_BLACK);
	if (parmblock->pb_currstate & OS_DISABLED)
		text_effects = TF_LIGHTENED;
	else
		text_effects = TF_NORMAL;
	v_xgtext(xpos, ypos, text_effects, ubparm, parmblock);
	clipping(parmblock, FALSE);

	return (0);
}

/**
 * Diese Methode zeichnet den horizontale Linie falls keine Reiter vorhanden sind.
 *
 *  +-----+
 *  |     |
 * +-------/-/-/-/-+
 * |               |
 * |               |
 * |               |
 * +---------------+
 *
 * @param *parmblock Zeiger auf die Parmblock-Struktur
 * @return liefert dem AES welche ob_state-Flags es noch bearbeiten muss (0 keine)
 */
WORD cdecl cardline(PARMBLK *parmblock) {
	short pxy[4];

	clipping(parmblock, TRUE);

	vswr_mode(userdef->vdi_handle, MD_REPLACE);
	vsl_color(userdef->vdi_handle, G_BLACK);

	pxy[0] = parmblock->pb_x;
	pxy[1] = parmblock->pb_y + parmblock->pb_h -1;
	pxy[2] = pxy[0] + parmblock->pb_w -1 -2;
	pxy[3] = pxy[1];

	if (get3dLook() == TRUE) {
		pxy[1]--;
		pxy[3]--;
	}
	v_pline(userdef->vdi_handle, 2, pxy);

	if (get3dLook() == TRUE) {
		pxy[1]++;
		pxy[2] -= 2;
		pxy[3]++;
		vsl_color(userdef->vdi_handle, G_WHITE);
		v_pline(userdef->vdi_handle, 2, pxy);
	}

	clipping(parmblock, FALSE);

	return(0);
}
