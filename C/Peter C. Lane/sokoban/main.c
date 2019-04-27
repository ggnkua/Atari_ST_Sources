/* start point for sokoban program */

#include "windows.h"

extern int app_handle; /* application graphics handle */

void main (int argc, char ** argv) {
	appl_init ();
	open_vwork ();
	start_program ();
	rsrc_free ();
	v_clsvwk (app_handle);
	appl_exit ();
}
