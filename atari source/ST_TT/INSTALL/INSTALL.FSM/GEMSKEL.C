/* gemskel.c 
 * Copyright 1990, Atari Corporation
 * ================================================================
 */

#include <sys\gemskel.h>	/* gets aesalt, aes, vdi, stddef */
#include <stdlib.h>		/* for exit() */
#include <tos.h>		/* Getrez() */

#include "country.h"
#include "text.h"

void do_main( void );
void Gem_Exit( int num );

#define STLOW 2
#define TTLOW 9


/* Globals allocated herein
 * ================================================================
 */

/* VDI arrays */
int		contrl[12], intin[128], intout[128], ptsin[128], ptsout[128],
		work_in[12], work_out[57];
int		vhandle, xres, yres;

/* AES variables */
int gl_apid, gl_hchar, gl_wchar, gl_hbox, gl_wbox;
GRECT	desk;

/* Functions
 * ================================================================
 */


void
main( void )
{
	int 	i;

	appl_init();

	vhandle = graf_handle( &gl_wchar, &gl_hchar, &gl_wbox, &gl_hbox );

	work_in[0] = Getrez()+2; /* let's not gag GDOS */
	for( i = 1; i < 10; work_in[i++] = 1 );
	work_in[10] = 2;
	v_opnvwk( work_in, &vhandle, work_out );
	xres = work_out[0];
	yres = work_out[1];

	/* We're too wide for ST LOW Rez */
        if(( work_in[0] == STLOW ) || ( work_in[0] == TTLOW ))
        {
	    form_alert( 1, alow );
	    v_clsvwk( vhandle );
	    appl_exit();
	    exit( 0 );
        }
        
        
	Wind_get( 0, WF_WORKXYWH, ( WARGS *)&desk );

	rsrc_init();
	do_main();
	Gem_Exit( 0 );
}


void
Gem_Exit( int code )
{
   v_clsvwk( vhandle );
   rsrc_exit();
   appl_exit();
   exit( code );
}
