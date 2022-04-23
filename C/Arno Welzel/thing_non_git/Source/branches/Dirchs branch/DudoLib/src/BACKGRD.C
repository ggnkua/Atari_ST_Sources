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
/*  public functions                                                */
/*------------------------------------------------------------------*/

/**
 * Diese Methode liefert, ob die Bibliothek einen 3D-Rahmen um alle
 * Objekte dieses erweiterten Objekt-Typs zeichnet (TRUE) oder
 * nicht (FALSE).
 *
 * @return TRUE - 3D-Rahmen zeichnen, FALSE sonst
 */
BOOLEAN getBackgroundBorder(void) {
	if (userdef != NULL)
		return (userdef->backgrdborder);

	return (FALSE);
}

/**
 * Mit dieser Methode wird spezifiziert, ob die Bibliothek einen 3D-Rahmen
 * um alle Objekte dieses erweiterten Objekt-Typs zeichnen soll (TRUE) oder
 * nicht (FALSE).
 * Wird der Dialog in ein Fenster gelegt, so ist es optisch schoener,
 * wenn kein zusaetzlicher 3D-Rahmen gezeichnet wird.
 *
 * @param flag 3D-Rahmen zeichnen (TRUE) oder nicht (FALSE)
 */
void setBackgroundBorder(BOOLEAN flag) {
	if (userdef == NULL)
		return;

	if (flag != TRUE)
		userdef->backgrdborder = FALSE;
	else
		userdef->backgrdborder = flag;
}

/**
 *
 *
 * @param *tree Zeiger auf Objekt-Baum
 * @param object Index des Objekts im Objekt-Baum
 * @param WORD x
 * @param WORD y
 * @param WORD w
 * @param WORD h
 */
void setBackgroundBorderOffset(OBJECT *objectTree, WORD objectIdx, WORD x, WORD y, WORD w, WORD h) {
	UBPARM *ubparm;

	if (objectTree == NULL)
		return;

	if ((objectTree[objectIdx].ob_type & 0xFF) != G_USERDEF)
		return;

	ubparm = (UBPARM *) objectTree[objectIdx].ob_spec.userblk->ub_parm;
	if (ubparm != NULL && ubparm->magic == 'DIRK') {
		ubparm->backgrdoffset[0] = x;
		ubparm->backgrdoffset[1] = y;
		ubparm->backgrdoffset[2] = w;
		ubparm->backgrdoffset[3] = h;
	}
}

/**
 * Diese Methode liefert, ob die Bibliothek eine 1 Pixel breite schwarze
 * Linie um das uebergebene Objekt zeichnet (TRUE) oder nicht (FALSE).
 *
 * @param *tree Zeiger auf Objekt-Baum
 * @param object Index des Objekts im Objekt-Baum
 *
 * @return TRUE - Linie zeichnen, FALSE sonst
 */
BOOLEAN getBackgroundBorderLine(OBJECT *objectTree, WORD objectIdx) {
	UBPARM *ubparm;

	if (objectTree == NULL)
		return (FALSE);

	if ((objectTree[objectIdx].ob_type & 0xFF) != G_USERDEF)
		return (FALSE);

	ubparm = (UBPARM *) objectTree[objectIdx].ob_spec.userblk->ub_parm;
	if (ubparm->magic == 'DIRK')
		return (ubparm->backgrdborderline);

	return (FALSE);
}

/**
 * Mit dieser Methode wird spezifiziert, ob die Bibliothek eine 1 Pixel breite
 * schwarze Linie um das uebergebene Objekt zeichnen soll (TRUE) oder
 * nicht (FALSE).
 *
 * @param *tree Zeiger auf Objekt-Baum
 * @param object Index des Objekts im Objekt-Baum
 * @param flag TRUE - Linie zeichnen, FALSE sonst
 */
void setBackgroundBorderLine(OBJECT *objectTree, WORD objectIdx, BOOLEAN flag) {
	UBPARM *ubparm;

	if (objectTree == NULL)
		return;

	if ((objectTree[objectIdx].ob_type & 0xFF) != G_USERDEF)
		return;

	ubparm = (UBPARM *) objectTree[objectIdx].ob_spec.userblk->ub_parm;
	if (ubparm->magic == 'DIRK')
		ubparm->backgrdborderline = flag;
}

/*------------------------------------------------------------------*/
/*  private functions                                               */
/*------------------------------------------------------------------*/
#define RAHMENDICKE	3

/**
 * Diese Methode zeichnet die Dialoghintergrundbox.
 *
 * @param *parmblock Zeiger auf die Parmblock-Struktur
 * @return liefert dem AES welche ob_state-Flags es noch bearbeiten muss (0 keine)
 */
WORD cdecl backgrdbox(PARMBLK *parmblock) {
	WORD pxy[10];
	UBPARM *ubparm;

	ubparm = (UBPARM *) parmblock->pb_parm;

	clipping(parmblock, TRUE);
	vswr_mode(userdef->vdi_handle, MD_REPLACE);

	if (ubparm->isPopup == TRUE) {
		pxy[0] = parmblock->pb_x + 1 + ubparm->backgrdoffset[0];
		pxy[1] = parmblock->pb_y + parmblock->pb_h - 2 - ubparm->backgrdoffset[3];
		pxy[2] = parmblock->pb_x + parmblock->pb_w - 2 - ubparm->backgrdoffset[2];
		pxy[3] = pxy[1];
		pxy[4] = pxy[2];
		pxy[5] = parmblock->pb_y + 1 + ubparm->backgrdoffset[1];
		vsl_color(userdef->vdi_handle, BLACK);
		v_pline(userdef->vdi_handle, 3, pxy);

		pxy[1]++;
		pxy[2]++;
		pxy[3] = pxy[1];
		pxy[4] = pxy[2];
		v_pline(userdef->vdi_handle, 3, pxy);

		ubparm->backgrdoffset[2] += 2;
		ubparm->backgrdoffset[3] += 2;
	}

	/* Eine 1 Pixel breite schwarze Linie um die Dialogbox zeichnen? */
	if (getBackgroundBorderLine(parmblock->pb_tree, parmblock->pb_obj) == TRUE || ubparm->isPopup == TRUE) {
		pxy[0] = parmblock->pb_x + ubparm->backgrdoffset[0];
		pxy[1] = parmblock->pb_y + ubparm->backgrdoffset[1];
		pxy[2] = parmblock->pb_x + parmblock->pb_w - 1 - ubparm->backgrdoffset[2];
		pxy[3] = pxy[1];
		pxy[4] = pxy[2];
		pxy[5] = pxy[1] + parmblock->pb_h - 1 - ubparm->backgrdoffset[3];
		pxy[6] = pxy[0];
		pxy[7] = pxy[5];
		pxy[8] = pxy[0];
		pxy[9] = pxy[1];
		vsl_color(userdef->vdi_handle, BLACK);
		v_pline(userdef->vdi_handle, 5, pxy);

		ubparm->backgrdoffset[0]++;
		ubparm->backgrdoffset[1]++;
		ubparm->backgrdoffset[2]++;
		ubparm->backgrdoffset[3]++;
	}

	/* Box mit Hintergrundfarbe fuellen */
	vsf_color(userdef->vdi_handle, userdef->backgrd_color);
	vsf_interior(userdef->vdi_handle, FIS_SOLID);
	pxy[0] = parmblock->pb_x + ubparm->backgrdoffset[0];
	pxy[1] = parmblock->pb_y + ubparm->backgrdoffset[1];
	pxy[2] = parmblock->pb_x + parmblock->pb_w - 1 - ubparm->backgrdoffset[2];
	pxy[3] = parmblock->pb_y + parmblock->pb_h - 1 - ubparm->backgrdoffset[3];
	v_bar(userdef->vdi_handle, pxy);

	if (get3dLook() == TRUE) {
		/* weisse Linien zeichnen */
		vsl_color(userdef->vdi_handle, WHITE);

		pxy[0] = parmblock->pb_x + parmblock->pb_w - 1 - ubparm->backgrdoffset[2];
		pxy[1] = parmblock->pb_y + ubparm->backgrdoffset[1];
		pxy[2] = parmblock->pb_x + ubparm->backgrdoffset[0];
		pxy[3] = pxy[1];
		pxy[4] = pxy[2];
		pxy[5] = parmblock->pb_y + parmblock->pb_h - 1 - ubparm->backgrdoffset[3];
		v_pline(userdef->vdi_handle, 3, pxy);

		if (getBackgroundBorder() == TRUE && ubparm->isPopup == FALSE) {
			pxy[0] -= RAHMENDICKE - 1;
			pxy[1] += RAHMENDICKE;
			pxy[2] = pxy[0];
			pxy[3] = pxy[5] - RAHMENDICKE + 1;
			pxy[4] = parmblock->pb_x + RAHMENDICKE + ubparm->backgrdoffset[0];
			pxy[5] = pxy[3];
			v_pline(userdef->vdi_handle, 3, pxy);
		}
		/* dunkelgraue Linien zeichnen */
		vsl_color(userdef->vdi_handle, LBLACK);

		pxy[0] = parmblock->pb_x + parmblock->pb_w - 1 - ubparm->backgrdoffset[2];
		pxy[1] = parmblock->pb_y + 1 + ubparm->backgrdoffset[1];
		pxy[2] = pxy[0];
		pxy[3] = parmblock->pb_y + parmblock->pb_h - 1 - ubparm->backgrdoffset[3];
		pxy[4] = parmblock->pb_x + ubparm->backgrdoffset[0];
		pxy[5] = pxy[3];
		v_pline(userdef->vdi_handle, 3, pxy);

		if (getBackgroundBorder() == TRUE && ubparm->isPopup == FALSE) {
			pxy[0] -= 2;
			pxy[1] += 1;
			pxy[2] = parmblock->pb_x + 2 + ubparm->backgrdoffset[0];
			pxy[3] = pxy[1];
			pxy[4] = pxy[2];
			pxy[5] -= 2;
			v_pline(userdef->vdi_handle, 3, pxy);

			/* schwarze Linien zeichnen */
			vsl_color(userdef->vdi_handle, BLACK);

			pxy[0] = parmblock->pb_x + 3 + ubparm->backgrdoffset[0];
			pxy[1] = parmblock->pb_y + 3 + ubparm->backgrdoffset[1];
			pxy[2] = parmblock->pb_x + parmblock->pb_w - 4 - ubparm->backgrdoffset[2];
			pxy[3] = pxy[1];
			pxy[4] = pxy[2];
			pxy[5] = parmblock->pb_y + parmblock->pb_h - 4 - ubparm->backgrdoffset[3];
			pxy[6] = pxy[0];
			pxy[7] = pxy[5];
			pxy[8] = pxy[0];
			pxy[9] = pxy[1];
			v_pline(userdef->vdi_handle, 5, pxy);
		}
	}

	if (getBackgroundBorderLine(parmblock->pb_tree, parmblock->pb_obj) == TRUE || ubparm->isPopup == TRUE) {
		ubparm->backgrdoffset[0]--;
		ubparm->backgrdoffset[1]--;
		ubparm->backgrdoffset[2]--;
		ubparm->backgrdoffset[3]--;
	}

	if (ubparm->isPopup == TRUE) {
		ubparm->backgrdoffset[2] -= 2;
		ubparm->backgrdoffset[3] -= 2;
	}
	clipping(parmblock, FALSE);

	return (0);
}
