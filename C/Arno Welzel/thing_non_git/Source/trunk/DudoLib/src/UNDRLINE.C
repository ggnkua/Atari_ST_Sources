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
WORD cdecl underline(PARMBLK *parmblock) {
	WORD pxy[4], x_pos, du;
	UBPARM *ubparm;

	ubparm = (UBPARM *) parmblock->pb_parm;

	clipping(parmblock, TRUE);

	vswr_mode(userdef->vdi_handle, MD_TRANS);
	vsl_color(userdef->vdi_handle, ubparm->te_rahmencol);
	vst_color(userdef->vdi_handle, ubparm->te_textcol);

	vst_effects(userdef->vdi_handle, TF_NORMAL);
	vst_alignment(userdef->vdi_handle, ubparm->te_just, TA_TOP, &du, &du);

	/* TA_LEFT */
	x_pos = parmblock->pb_x;
	switch (ubparm->te_just) {
	case TA_RIGHT:
		x_pos += parmblock->pb_w - 1;
		break;

	case TA_CENTER:
		x_pos += (parmblock->pb_w / 2) - 1;
		break;
	}

	/* Unterstrich zeichnen */
	pxy[0] = parmblock->pb_x;
	pxy[1] = parmblock->pb_y + parmblock->pb_h - 1;
	pxy[2] = pxy[0] + parmblock->pb_w - 1;
	pxy[3] = pxy[1];

	v_pline(userdef->vdi_handle, 2, pxy);
	v_gtext(userdef->vdi_handle, x_pos, parmblock->pb_y, ubparm->text);

	clipping(parmblock, FALSE);

	return (0);
}
