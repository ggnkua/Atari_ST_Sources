/* gemskel.c 
 * Copyright 1990, Atari Corporation
 * ================================================================
 */

#include <alt\gemskel.h>	/* gets aesalt, aes, vdi, stddef */
#include <gemlib.h>
#include <stdlib.h>		/* for exit() */
#include <tos.h>		/* Getrez() */

#include "country.h"
#include "text.h"
#include "handlers.h"
#include "mainstuf.h"


/* DEFINES
 * ================================================================
 */
#define STLOW 2
#define TTLOW 9


/* PROTOTYPES
 * ================================================================
 */
void Gem_Exit( int num );


/* EXTERNS
 * ================================================================
 */


/* GLOBALS
 * ================================================================
 */

/* VDI arrays */
int	contrl[12], intin[128], intout[128], ptsin[128], ptsout[128],
	work_in[12], work_out[57];
int	vhandle, xres, yres;
int	num_pens;
GRECT   gl_full;		/* window full size  */
GRECT   gl_screen;		/* screen size	     */
GRECT   gl_work;		/* window work area  */
GRECT   gl_curr;		/* window border area*/


/* AES variables */
int gl_apid, gl_hchar, gl_wchar, gl_hbox, gl_wbox;
int AES_Version;

/* FUNCTIONS
 * ================================================================
 */


/* main()
 * ================================================================
 */
void
main( void )
{
	int 	i;

	appl_init();
	AES_Version = _AESglobal[0];	/* Get the AES version number */

	vhandle = graf_handle( &gl_wchar, &gl_hchar, &gl_wbox, &gl_hbox );

	work_in[0] = Getrez()+2; /* let's not gag GDOS */
	for( i = 1; i < 10; work_in[i++] = 1 );
	work_in[10] = 2;
	v_opnvwk( work_in, &vhandle, work_out );
	xres = work_out[0];
	yres = work_out[1];
	num_pens = work_out[13];

	gl_screen.g_x = gl_screen.g_y = 0;
        gl_screen.g_w = xres + 1;
        gl_screen.g_h = yres + 1;

	/* We're too wide for ST LOW Rez */
        if(( work_in[0] == STLOW ) || ( work_in[0] == TTLOW ))
        {
	    form_alert( 1, alow );
	    v_clsvwk( vhandle );
	    appl_exit();
	    exit( 0 );
        }

	wind_get( 0, WF_WORKXYWH, &gl_full.g_x, &gl_full.g_y,
				  &gl_full.g_w, &gl_full.g_h );

	initialize();
	if( !rsrc_init())
        {
	   form_alert( 1, arsc );
	   Gem_Exit( -1 );
        }

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
