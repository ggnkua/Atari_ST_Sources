/*
 * BibFind
 *
 * A program which reads a specified biblio file
 * on start up, and then provides menus and a window
 * for searching and displaying records within that file.
 *
 * This file sets up BibFind as a PRG.
 */
#include "bibgui.h"

/* Sets up the biblio file, loads resource file, and launches
 * program.
 */
void do_program (void) {
	OBJECT * menu_addr; /* address of menu for application */
	OBJECT * dial_addr; /* address of dialog for application */
	struct rec_data * rd; /* the bib record data */

	if (!rsrc_load("\BIBFIND.rsc")) {
		form_alert(1, "[1][BibFind .rsc file missing!][OK]");
	} else {
		/* get dialog reference */
		rsrc_gaddr (R_TREE, FIND_DIALOG, &dial_addr);
		/* install menu */
		rsrc_gaddr (R_TREE, MAIN_MENU, &menu_addr);
		menu_bar (menu_addr, TRUE);

		/* load in data, using busybee for mouse */
		graf_mouse (BUSYBEE, 0L);

		rd = recdata_create ();
		if (rd == NULL) {
			form_alert(1, "[1]ERROR: Could not find biblio.bib file.][OK]");
		} else {
			do_window (rd, menu_addr, dial_addr);
			menu_bar (menu_addr, FALSE);
		}
	}
}

/* function to control start and close of program */
void main (int argc, char ** argv) {
	appl_init ();
	open_vwork ();
	do_program ();
	rsrc_free ();
	v_clsvwk (app_handle);
	appl_exit ();
}

