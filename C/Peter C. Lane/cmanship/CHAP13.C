/*
 * Chapter 13 CMANSHIP
 * File Selectors
 */

#include <aes.h>
#include <tos.h>
#include <vdi.h>
#include "stdio.h"
#include "string.h"

int work_in[11],
    work_out[57],
    pxyarray[10],
    contrl[12],
    intin[128],
    ptsin[128],
    intout[128],
    ptsout[128];

int handle, dum;

void open_vwork (void);
void sel_file (void);
void prnt_info (char * file, int button);
void button_wait (void);
void text_info (char * file, int button);

void main (void) {
	appl_init ();
	open_vwork ();
	sel_file ();    /* go select file */
/*	button_wait (); */ /* wait for a mouse button press */
	v_clsvwk (handle);
	appl_exit ();
}

void open_vwork (void) {
	int i;

	handle = graf_handle (&dum, &dum, &dum, &dum);
	for (i = 0; i < 10; work_in[i++] = 1);
	work_in[10] = 2;
	v_opnvwk(work_in, &handle, work_out);
}

/* do file selector box */
void sel_file (void) {
	int button, i;
	char path[50], file[13];

	for (i=0; i < 50; path[i++] = '\0');
	for (i=0; i < 13; file[i++] = '\0');
	path[0] = Dgetdrv() + 65;
	strcpy (&path[1], ":\\*.*");
	fsel_input(path,file, &button);
	text_info (file, button);
}

/* print out the user's choices */
void prnt_info (char * file, int button) {
	v_gtext (handle, 28, 50, "The file you chose was: ");
	v_gtext (handle,220, 50, file);
	v_gtext (handle, 28, 66, "And you pressed the ");
	if (button == 0) {
		v_gtext (handle, 188, 66, "CANCEL button.");
	} else {
		v_gtext (handle, 188, 66, "OK button.");
	}
}

/* print out to terminal (as waiting for mouse leaves
   application unfinished, under Mint) */
void text_info (char * file, int button) {
	printf ("The file you chose was: %s\n", file);
	printf ("And you pressed the %s button.\n", (button == 0 ? "CANCEL": "OK"));
	getch ();
}

/* Waits for left button to be pressed and released. */
void button_wait (void) {
	evnt_button (1, 1, 1, &dum, &dum, &dum, &dum);
	evnt_button (1, 1, 0, &dum, &dum, &dum, &dum);
}