/*
 * BibFind
 *
 * A program which reads a specified biblio file
 * on start up, and then provides menus and a window
 * for searching and displaying records within that file.
 *
 * This file sets up BibFind as a desk ACCessory.
 *
 */
#include "bibgui.h"
#include "BIBFIND.c" /* the RSM exported C code for BIBFIND.RSC */

/* Sets up the biblio file, starts accessory. */
void do_acc (void) {
	int menu_addr; /* address of menu for application */
	struct rec_data * rd; /* the bib record data */
	int msg_buf[8];

	rd = recdata_create ();
	if (rd == NULL) {
		printf ("ERROR: Could not find biblio.bib file.\n");
		printf ("       BibFind acc not installed.\n");
	} else {
		menu_addr = menu_register (gl_apid, "  BibFind");
		rs_init ();

		while (1) {
			evnt_mesag (msg_buf);

			switch (msg_buf[0]) {
				case AC_OPEN:
					if (msg_buf[4] == menu_addr) {
						menu_bar (MAIN_MENU, TRUE);
						do_window (rd, MAIN_MENU, FIND_DIALOG);
					}
				case AC_CLOSE:
					if (msg_buf[4] == menu_addr) {
						menu_bar (MAIN_MENU, FALSE);
					}
			}
		}
	}
}

/* function to control start and close of program */
void main (int argc, char ** argv) {
	appl_init ();
	open_vwork ();
	do_acc ();
}

