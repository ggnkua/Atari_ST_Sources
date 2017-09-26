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

extern UWORD CheckBoxSelected[64], CheckBoxNormalDisabled[64],
		CheckBoxSelectedDisabled[64];

/*------------------------------------------------------------------*/
/*  local function prototypes                                       */
/*------------------------------------------------------------------*/
static VOID draw_kreuz(PARMBLK *parmblock);

/*------------------------------------------------------------------*/
/*  private functions                                               */
/*------------------------------------------------------------------*/
WORD cdecl checkbox(PARMBLK *parmblock) {
	WORD pxy[8], cppxy[8], color_index[] = { BLACK, WHITE }, text_effects, du;
	MFDB screen, checkbox = { NULL, 16, 0, 1, 0, 1 };
	UBPARM *ubparm;

	ubparm = (UBPARM *) parmblock->pb_parm;

	clipping(parmblock, TRUE);
	vswr_mode(userdef->vdi_handle, MD_REPLACE);

	if (get3dLook() == TRUE) {
		/*
		 * Damit keine Reste von DISABLED mehr da sind, muessen wir
		 * das komplette Objekt neuzeichnen.
		 */
		if (parmblock->pb_prevstate & DISABLED || parmblock->pb_currstate & DISABLED) {
			clearObject(parmblock);
		}
	}

	if (userdef->img_size != IMGSIZE_NONE) {
		screen.fd_addr = NULL;
		checkbox.fd_h = (userdef->char_h < 16) ? 8 : 16;

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

	if ((parmblock->pb_currstate & DISABLED) == FALSE || get3dLook() == FALSE || userdef->img_size == IMGSIZE_NONE) {
		/* RO->LO->LU */
		pxy[0] = parmblock->pb_x + userdef->img_width - 2;
		pxy[1] = parmblock->pb_y + 1;
		pxy[2] = parmblock->pb_x + 1;
		pxy[3] = pxy[1];
		pxy[4] = pxy[2];
		pxy[5] = parmblock->pb_y + parmblock->pb_h - 2;
		vsl_color(userdef->vdi_handle, BLACK);
		v_pline(userdef->vdi_handle, 3, pxy);

		/* RO->RU->LU */
		pxy[1] = parmblock->pb_y + 2;
		pxy[2] = pxy[0];
		pxy[3] = parmblock->pb_y + parmblock->pb_h - 2;
		pxy[4] = parmblock->pb_x + 2;
		pxy[5] = pxy[3];
		if (get3dLook() == TRUE && (parmblock->pb_currstate & DISABLED) == FALSE)
			vsl_color(userdef->vdi_handle, WHITE);
		v_pline(userdef->vdi_handle, 3, pxy);

		/* Kreuz loeschen */
		pxy[0] = parmblock->pb_x + 2;
		pxy[1] = parmblock->pb_y + 2;
		pxy[2] = parmblock->pb_x + userdef->img_width - 3;
		pxy[3] = parmblock->pb_y + parmblock->pb_h - 3;

		if (get3dLook() == FALSE)
			vsf_color(userdef->vdi_handle, WHITE);
		else
			vsf_color(userdef->vdi_handle, userdef->backgrd_color);
		vsf_interior(userdef->vdi_handle, FIS_SOLID);
		v_bar(userdef->vdi_handle, pxy);
	}

	vst_alignment(userdef->vdi_handle, TA_LEFT, TA_TOP, &du, &du);

	if (get3dLook() == FALSE) {
		if (userdef->img_size == IMGSIZE_NONE) {
			if (parmblock->pb_currstate & SELECTED)
				vsl_color(userdef->vdi_handle, BLACK);
			else
				vsl_color(userdef->vdi_handle, WHITE);

			draw_kreuz(parmblock);
		} else if (parmblock->pb_currstate & SELECTED) {
			checkbox.fd_addr = (void *) CheckBoxSelected;
			vrt_cpyfm(userdef->vdi_handle, MD_TRANS, cppxy, &checkbox, &screen, color_index);
		}

		vswr_mode(userdef->vdi_handle, MD_TRANS);
		vst_color(userdef->vdi_handle, BLACK);
		text_effects = TF_NORMAL;
		v_xgtext(parmblock->pb_x + userdef->img_width + userdef->spaceChar_w, parmblock->pb_y, text_effects, ubparm, parmblock);

		clipping(parmblock, FALSE);

		return (parmblock->pb_currstate & ~SELECTED);

	} else {
		if (parmblock->pb_currstate & SELECTED) {
			if (userdef->img_size == IMGSIZE_NONE) {
				vsl_color(userdef->vdi_handle, BLACK);
				draw_kreuz(parmblock);
			} else {
				if (parmblock->pb_currstate & DISABLED)
					checkbox.fd_addr = (VOID *) CheckBoxSelectedDisabled;
				else
					checkbox.fd_addr = (VOID *) CheckBoxSelected;
				vrt_cpyfm(userdef->vdi_handle, MD_TRANS, cppxy, &checkbox, &screen, color_index);
			}
		} else {
			if (userdef->img_size == IMGSIZE_NONE) {
				vsl_color(userdef->vdi_handle, userdef->backgrd_color);
				draw_kreuz(parmblock);
			} else if (parmblock->pb_currstate & DISABLED) {
				checkbox.fd_addr = (VOID *) CheckBoxNormalDisabled;
				vrt_cpyfm(userdef->vdi_handle, MD_TRANS, cppxy, &checkbox, &screen, color_index);
			}
		}

		vswr_mode(userdef->vdi_handle, MD_TRANS);
		if (parmblock->pb_currstate & DISABLED)
			text_effects = TF_LIGHTENED;
		else
			text_effects = TF_NORMAL;

		v_xgtext(parmblock->pb_x + userdef->img_width + userdef->spaceChar_w, parmblock->pb_y, text_effects, ubparm, parmblock);
		clipping(parmblock, FALSE);

		return (0);
	}
}

static VOID draw_kreuz(PARMBLK *parmblock) {
	WORD pxy[4];

	/* RO->LU */
	pxy[0] = parmblock->pb_x + userdef->img_width - 4;
	pxy[1] = parmblock->pb_y + 3;
	pxy[2] = parmblock->pb_x + 3;
	pxy[3] = parmblock->pb_y + parmblock->pb_h - 4;
	v_pline(userdef->vdi_handle, 2, pxy);

	/* LO->RU */
	pxy[0] = parmblock->pb_x + 3;
	pxy[1] = parmblock->pb_y + 3;
	pxy[2] = parmblock->pb_x + userdef->img_width - 4;
	pxy[3] = parmblock->pb_y + parmblock->pb_h - 4;
	v_pline(userdef->vdi_handle, 2, pxy);
}
