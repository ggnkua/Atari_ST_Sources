#include "nau_feld.h"

extern int work_in[12],
       work_out[57];

extern int handle,
       phys_handle;

extern int gl_hchar,	/* Zeichenhoehe  */
       gl_wchar,	/* Zeichenbreite */
       gl_hbox,	/* Box-Hoehe und */
       gl_wbox;	/* Box-Breite in die ein Char passt */

extern screen_param sc;

extern int gl_apid;  /* Applikations-Handle vom AES */
