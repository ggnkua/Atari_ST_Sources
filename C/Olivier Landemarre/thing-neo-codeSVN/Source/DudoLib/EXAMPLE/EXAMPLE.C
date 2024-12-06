/**
 * DudoLib Example - Dirchs user defined object library Example
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

#include <gem.h>

#include "example.h"
#include "..\include\dudolib.h"

#define BUFFER_LENGTH	256

BOOLEAN loadRsrc(void);
static void redrawCard(OBJECT *objectBodyTree, WORD objectBodyIdx, WORD x, WORD y, WORD w, WORD h);

OBJECT *example;

void main(void) {
	int appl_id, vdi_handle;
	int objectExitIdx;
	WORD work_in[11] = { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2 }, work_out[57];
	LONG du;
	GRECT size;

	CARD *exampleCard = NULL;

	graf_mouse(ARROW, NULL);

	/* Programm beim AES anmelden. */
	appl_id = appl_init();
	if (appl_id < 0) {
		form_alert(1, "[3]Application Initialization|Error!][Exit]");
		exit(1);
	}

	/* Resource-Datei laden. */
	if (loadRsrc() == FALSE) {
		form_alert(1, "[3][Can't load RSC-File !][Exit]");
		exit(1);
	}

	/* Die einzelnen Karteikarten zusammenhaengen. */
	if (cardAdd(&exampleCard, example, BUTTON_BACKGRD, BOX_BACKGRD) == USR_OUTOFMEMORY) {
		form_alert(1, "[3][Out of memory!][Exit]");
		exit(1);
	}
	if (cardAdd(&exampleCard, example, BUTTON_BUTTON, BOX_BUTTON) == USR_OUTOFMEMORY) {
		form_alert(1, "[3][Out of memory!][Exit]");
		cardRemoveAll(exampleCard);
		exit(1);
	}
	if (cardAdd(&exampleCard, example, BUTTON_HEADLINE, BOX_HEADLINE) == USR_OUTOFMEMORY) {
		form_alert(1, "[3][Out of memory!][Exit]");
		cardRemoveAll(exampleCard);
		exit(1);
	}
	if (cardAdd(&exampleCard, example, BUTTON_RAHMEN, BOX_RAHMEN) == USR_OUTOFMEMORY) {
		form_alert(1, "[3][Out of memory!][Exit]");
		cardRemoveAll(exampleCard);
		exit(1);
	}
	if (cardAdd(&exampleCard, example, BUTTON_SEPARATOR, BOX_SEPARATOR) == USR_OUTOFMEMORY) {
		form_alert(1, "[3][Out of memory!][Exit]");
		cardRemoveAll(exampleCard);
		exit(1);
	}

	/* physikalisches WK-Handle ermitteln */
	vdi_handle = graf_handle(&(WORD) du, &(WORD) du, &(WORD) du, &(WORD) du);

	/* virtuelle (Bildschirm) WK oeffnen */
	v_opnvwk(work_in, &vdi_handle, work_out);

	/* Dudo-Library initialisieren */
	if (initDudolib() != USR_NOERROR) {
		form_alert(1, "[3][Failed to initialize|DudoLib!][Exit]");
		exit(1);
	}

	/* Userdefs im Dialog installieren. */
	setUserdefs(example, FALSE);
/*	set3dLook(FALSE);*/
	setBackgroundBorderLine(example, 0, TRUE);
/*	setBackgroundBorder(FALSE);*/

#if 0
	/* Ueberschreiben der internen Zeichenfunktion der Karteikarte. */
	setCardRedraw(exampleCard, redrawCard);
#endif

	/* Dialog zeichnen */
	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);

	form_center(example, &size.g_x, &size.g_y, &size.g_w, &size.g_h);
	form_dial(FMD_START, size.g_x, size.g_y, size.g_w, size.g_h, size.g_x, size.g_y, size.g_w, size.g_h);

	objc_draw(example, ROOT, MAX_DEPTH, size.g_x, size.g_y, size.g_w, size.g_h);

	/* Hauptschleife */
	do {
		objectExitIdx = form_do(example, ROOT) & 0x7FFF;
		switch (objectExitIdx) {
		case BUTTON_BACKGRD:
			setActiveCard(exampleCard, BUTTON_BACKGRD, TRUE);
			break;

		case BUTTON_BUTTON:
			setActiveCard(exampleCard, BUTTON_BUTTON, TRUE);
			break;

		case BUTTON_HEADLINE:
			setActiveCard(exampleCard, BUTTON_HEADLINE, TRUE);
			break;

		case BUTTON_RAHMEN:
			setActiveCard(exampleCard, BUTTON_RAHMEN, TRUE);
			break;

		case BUTTON_SEPARATOR:
			setActiveCard(exampleCard, BUTTON_SEPARATOR, TRUE);
			break;
		}
	} while (objectExitIdx != ENDE);

	form_dial(FMD_FINISH, size.g_x, size.g_y, size.g_w, size.g_h, size.g_x, size.g_y, size.g_w, size.g_h);
	setObjectState(example, objectExitIdx, OS_SELECTED, FALSE);

	wind_update(END_UPDATE);
	wind_update(END_MCTRL);

	/* Karteikarten freigeben. */
	cardRemoveAll(exampleCard);

	/* Userdefs aus dem Dialog entfernen. */
	unsetUserdefs(example);

	/* Library abmelden. */
	releaseDudolib();

	/* virtuelle WK schliessen */
	v_clsvwk(vdi_handle);

	/* Programm beim AES abmelden */
	appl_exit();

	exit(0);
}

/**
 * Resource-File laden.
 *
 * @return True - hat geklappt, False sonst
 */
BOOLEAN loadRsrc(void) {
	graf_mouse(BUSYBEE, NULL);
	if (rsrc_load("example.rsc") == FALSE) {
		graf_mouse(ARROW, NULL);
		return (FALSE);
	}
	graf_mouse(ARROW, NULL);

	rsrc_gaddr(R_TREE, TREE, &example);

	return (TRUE);
}

/**
 * Beispiel-Methode wie die interne Zeichenfunktion durch eine eigene ersetzt werden kann.
 *
 * @param *objectTree Zeiger auf Objekt-Baum
 * @param objectBodyIdx Objekt-Index des Objekts
 * @param x x-Position des zu zeichnenden Karteikarten-Objektes
 * @param y y-Position respektiv
 * @param w dessen Breite
 * @param h dessen Hoehe
 */
static void redrawCard(OBJECT *objectBodyTree, WORD objectBodyIdx, WORD x, WORD y, WORD w, WORD h) {
	objc_draw(objectBodyTree, objectBodyIdx, MAX_DEPTH, x, y, w, h);
}
