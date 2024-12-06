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

extern UWORD RadioButtonNormal[64], RadioButtonSelected[64];
extern UWORD RadioButtonNormalDisabled[64], RadioButtonSelectedDisabled[64],
		RadioButtonNormalBackgrd[64], RadioButtonNormalBackgrdLBLACK[64],
		RadioButtonSelectedBackgrd[64], RadioButtonSelectedBackgrdLBLACK[64];

/*------------------------------------------------------------------*/
/*  private functions                                               */
/*------------------------------------------------------------------*/

/**
 * Diese Methode zeichnet Radiobuttons.
 *
 * @param *parmblock Zeiger auf die Parmblock-Struktur
 * @return liefert dem AES welche ob_state-Flags es noch bearbeiten muss (0 keine)
 */
WORD cdecl radiobutton(PARMBLK *parmblock) {
	WORD pxy[8], bpxy[4], cppxy[8], color_index[] = { G_BLACK, G_WHITE },
			text_effects, du;
	MFDB rbutton = { NULL, 16, 0, 1, 0, 1 }, screen;
	UBPARM *ubparm;

	ubparm = (UBPARM *) parmblock->pb_parm;

	clipping(parmblock, TRUE);

	if (get3dLook() == TRUE) {
		/*
		 * Damit keine Reste von DISABLED mehr da sind, muessen wir
		 * das ganze Objekt neuzeichnen.
		 */
		if (parmblock->pb_prevstate & OS_DISABLED || parmblock->pb_currstate & OS_DISABLED) {
			clearObject(parmblock);
		}
	}

	/*
	 * Da meine Userdefs aus Images mit fester Groesse bestehen,
	 * muessen einfachere mit der Hand gezeichnet werden, wenn der
	 * Systemfont nicht in der richtigen Groesse vorhanden ist.
	 */
	if (userdef->img_size == IMGSIZE_NONE) {
		vsl_color(userdef->vdi_handle, G_BLACK);

		/* RO->LO->LU */
		pxy[0] = parmblock->pb_x + userdef->img_width - 2;
		pxy[1] = parmblock->pb_y + 1;
		pxy[2] = parmblock->pb_x + 1;
		pxy[3] = pxy[1];
		pxy[4] = pxy[2];
		pxy[5] = parmblock->pb_y + parmblock->pb_h - 2;
		v_pline(userdef->vdi_handle, 3, pxy);

		if (get3dLook() == TRUE)
			vsl_color(userdef->vdi_handle, G_WHITE);

		/* RO->RU->LU */
		pxy[1] = parmblock->pb_y + 2;
		pxy[2] = pxy[0];
		pxy[3] = parmblock->pb_y + parmblock->pb_h - 2;
		pxy[4] = parmblock->pb_x + 2;
		pxy[5] = pxy[3];
		v_pline(userdef->vdi_handle, 3, pxy);

		bpxy[0] = parmblock->pb_x + 3;
		bpxy[1] = parmblock->pb_y + 3;
		bpxy[2] = parmblock->pb_x + userdef->img_width - 4;
		bpxy[3] = parmblock->pb_y + parmblock->pb_h - 4;
	} else {
		screen.fd_addr = NULL;
		rbutton.fd_h = (userdef->char_h < 16) ? 8 : 16;

		/* Quellraster */
		cppxy[0] = 0;
		cppxy[1] = 0;
		cppxy[2] = 15;
		cppxy[3] = userdef->char_h - 1;

		/* Zielraster */
		cppxy[4] = parmblock->pb_x;
		cppxy[5] = parmblock->pb_y;
		cppxy[6] = cppxy[4] + userdef->img_width - 1;
		cppxy[7] = cppxy[5] + parmblock->pb_h - 1;
	}
	vswr_mode(userdef->vdi_handle, MD_REPLACE);
	vst_alignment(userdef->vdi_handle, TA_LEFT, TA_TOP, &du, &du);

	if (get3dLook() == FALSE) {
		if (userdef->img_size == IMGSIZE_NONE) {
			if (parmblock->pb_currstate & OS_SELECTED)
				vsf_color(userdef->vdi_handle, G_BLACK);
			else
				vsf_color(userdef->vdi_handle, G_WHITE);
			vsf_interior(userdef->vdi_handle, FIS_SOLID);
			v_bar(userdef->vdi_handle, bpxy);
		} else {
			if (parmblock->pb_currstate & OS_SELECTED)
				rbutton.fd_addr = (void *) RadioButtonSelected;
			else
				rbutton.fd_addr = (void *) RadioButtonNormal;

			vrt_cpyfm(userdef->vdi_handle, MD_REPLACE, cppxy, &rbutton, &screen, color_index);
		}

		vswr_mode(userdef->vdi_handle, MD_TRANS);
		vst_color(userdef->vdi_handle, G_BLACK);
		text_effects = TF_NORMAL;
		v_xgtext(parmblock->pb_x + userdef->img_width + userdef->spaceChar_w, parmblock->pb_y, text_effects, ubparm, parmblock);

		clipping(parmblock, FALSE);
		return (parmblock->pb_currstate & ~OS_SELECTED);
	} else {
		if (parmblock->pb_currstate & OS_SELECTED) {
			if (userdef->img_size == IMGSIZE_NONE) {
				vsf_color(userdef->vdi_handle, G_LBLACK);
				vsf_interior(userdef->vdi_handle, FIS_SOLID);
				v_bar(userdef->vdi_handle, bpxy);
			} else {
				if (parmblock->pb_currstate & OS_DISABLED) {
					rbutton.fd_addr = (void *) RadioButtonSelectedDisabled;
				} else {
					color_index[0] = userdef->backgrd_color;
					rbutton.fd_addr = (void *) RadioButtonSelectedBackgrd;
					vrt_cpyfm(userdef->vdi_handle, MD_REPLACE, cppxy, &rbutton, &screen, color_index);

					color_index[0] = G_LBLACK;
					rbutton.fd_addr = (void *) RadioButtonSelectedBackgrdLBLACK;
					vrt_cpyfm(userdef->vdi_handle, MD_TRANS, cppxy, &rbutton, &screen, color_index);

					color_index[0] = G_BLACK;
					rbutton.fd_addr = (void *) RadioButtonSelected;
				}
				vrt_cpyfm(userdef->vdi_handle, MD_TRANS, cppxy, &rbutton, &screen, color_index);
			}
		} else {
			if (userdef->img_size == IMGSIZE_NONE) {
				vsf_color(userdef->vdi_handle, userdef->backgrd_color);
				vsf_interior(userdef->vdi_handle, FIS_SOLID);
				v_bar(userdef->vdi_handle, bpxy);
			} else {
				if (parmblock->pb_currstate & OS_DISABLED) {
					rbutton.fd_addr = (void *) RadioButtonNormalDisabled;
				} else {
					color_index[0] = userdef->backgrd_color;
					rbutton.fd_addr = (void *) RadioButtonNormalBackgrd;
					vrt_cpyfm(userdef->vdi_handle, MD_REPLACE, cppxy, &rbutton, &screen, color_index);

					color_index[0] = G_LBLACK;
					rbutton.fd_addr = (void *) RadioButtonNormalBackgrdLBLACK;
					vrt_cpyfm(userdef->vdi_handle, MD_TRANS, cppxy, &rbutton, &screen, color_index);

					color_index[0] = G_BLACK;
					rbutton.fd_addr = (void *) RadioButtonNormal;
				}
				vrt_cpyfm(userdef->vdi_handle, MD_TRANS, cppxy, &rbutton, &screen, color_index);
			}
		}

		vswr_mode(userdef->vdi_handle, MD_TRANS);
		vst_color(userdef->vdi_handle, G_BLACK);
		if (parmblock->pb_currstate & OS_DISABLED)
			text_effects = TF_LIGHTENED;
		else
			text_effects = TF_NORMAL;

		v_xgtext(parmblock->pb_x + userdef->img_width + userdef->spaceChar_w, parmblock->pb_y, text_effects, ubparm, parmblock);

		clipping(parmblock, FALSE);
		return (0);
	}
}
