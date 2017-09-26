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

#include <aes.h>
#include <vdi.h>

#include "example.h"
#include "..\include\dudolib.h"

#define BUFFER_LENGTH	256

BOOLEAN loadRsrc(VOID);
static void redraw_card(OBJECT *body_tree, int body, int x, int y, int w, int h);

int appl_id, vdi_handle;
OBJECT *example;

void main(void) {
	int exit_obj;
	WORD work_in[11] = { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2 }, work_out[57];
	LONG du;
	GRECT size;

	CARD *example_card = NULL;

	graf_mouse(ARROW, NULL);

	/* Programm beim AES anmelden. */
	appl_id = appl_init();
	if (appl_id < 0) {
		form_alert(1, "[3]Application Initialization|Error!][Exit]");
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

	/* Resource-Datei laden. */
	if (loadRsrc() == FALSE) {
		form_alert(1, "[3][Can't load RSC-File !][Cancel]");
		exit(1);
	}

	/* Userdefs im Dialog installieren. */
	setUserdefs(example, FALSE);
/*	set3dLook(FALSE);*/
	setBackgroundBorderLine(example, 0, TRUE);
/*	setBackgroundBorder(FALSE);*/

	/* Die einzelnen Karteikarten zusammenhaengen. */
	cardAdd(&example_card, example, BUTTON_BACKGRD, example, BOX_BACKGRD, redraw_card);
	cardAdd(&example_card, example, BUTTON_BUTTON, example, BOX_BUTTON, redraw_card);
	cardAdd(&example_card, example, BUTTON_HEADLINE, example, BOX_HEADLINE, redraw_card);
	cardAdd(&example_card, example, BUTTON_RAHMEN, example, BOX_RAHMEN, redraw_card);
	cardAdd(&example_card, example, BUTTON_SEPARATOR, example, BOX_SEPARATOR, redraw_card);

	/* Karteikarte nach vorne bringen. */
	setActiveCard(example_card, BUTTON_BACKGRD, FALSE);

	/* Dialog zeichnen */
	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);

	form_center(example, &size.g_x, &size.g_y, &size.g_w, &size.g_h);
	form_dial(FMD_START, size.g_x, size.g_y, size.g_w, size.g_h, size.g_x,
			size.g_y, size.g_w, size.g_h);

	objc_draw(example, ROOT, MAX_DEPTH, size.g_x, size.g_y, size.g_w, size.g_h);
	do {
		exit_obj = form_do(example, ROOT) & 0x7FFF;
		switch (exit_obj) {
		case BUTTON_BACKGRD:
			setActiveCard(example_card, BUTTON_BACKGRD, TRUE);
			break;

		case BUTTON_BUTTON:
			setActiveCard(example_card, BUTTON_BUTTON, TRUE);
			break;

		case BUTTON_HEADLINE:
			setActiveCard(example_card, BUTTON_HEADLINE, TRUE);
			break;

		case BUTTON_RAHMEN:
			setActiveCard(example_card, BUTTON_RAHMEN, TRUE);
			break;

		case BUTTON_SEPARATOR:
			setActiveCard(example_card, BUTTON_SEPARATOR, TRUE);
			break;
		}
	} while (exit_obj != ENDE);

	form_dial(FMD_FINISH, size.g_x, size.g_y, size.g_w, size.g_h, size.g_x,
			size.g_y, size.g_w, size.g_h);

	example[exit_obj].ob_state &= (~SELECTED);

	wind_update(END_UPDATE);
	wind_update(END_MCTRL);

	/* Karteikarten freigeben. */
	cardRemove(example_card);

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

LOCAL BOOLEAN loadRsrc(void) {
	graf_mouse(BUSYBEE, NULL);
	if (rsrc_load("example.rsc") == FALSE) {
		graf_mouse(ARROW, NULL);
		return (FALSE);
	}
	graf_mouse(ARROW, NULL);

	rsrc_gaddr(R_TREE, TREE, &example);

	return (TRUE);
}

static void redraw_card(OBJECT *body_tree, int body, int x, int y, int w, int h) {
	objc_draw(body_tree, body, MAX_DEPTH, x, y, w, h);
}
