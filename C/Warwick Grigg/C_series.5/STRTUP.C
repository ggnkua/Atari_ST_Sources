/* ----------------- ST FORMAT PINBALL PROGRAM ------- ------------------------

	Title:		PINBALL

	Module:		strtup.c

	Version:	1.1

	Author:		Warwick Grigg

	Copyright (c) Warwick Grigg 1990. All rights reserved.

----------------------------------------------------------------------------- */
#include <macros.h>
#include <osbind.h>
#include <gemfast.h>
#include <stdio.h>
#include "errexit.h"

/*	LOCAL DATA	*/

static int pallette[16];/* Place to store pallette so we can restore at end   */


int AppStart()				/* Initialise GEM etc.		*/
{
    extern int gl_apid;			/* the AES application id	*/
    int work_in[12], work_out[57];	/* arrays for openvwk		*/
    int v_hnd;				/* VDI handle 			*/
    int i;				/* loop index			*/
    int dummy;				/* dummy return variable	*/
    
    appl_init();			/* initialise GEM's AES		*/
    if(gl_apid == -1)
	errexit("Sorry, the GEM AES won't initialise\n");
    v_hnd = graf_handle(&dummy, &dummy, &dummy, &dummy);
    for(i = 0; i < 10; i++)
    	work_in[i] = 1;
    work_in[10] = 2;			/* raster co-ordinates		*/
    v_opnvwk(work_in, &v_hnd, work_out);/* open GEM virtual workstation */
    if (!v_hnd)
	errexit("Sorry, I can't open a GEM VDI virtual workstation\n");
    Cursconf(0, 0);			/* configure cursor off		*/
    for (i=0; i<16; i++) {		/* get initial pallette setting	*/
	pallette[i] = Setcolor(i, -1);
    }
    return v_hnd;
}

void AppEnd(v_hnd)
int v_hnd;
{
    v_clsvwk(v_hnd);			/* close GEM virtual workstation*/
    appl_exit();			/* closedown AES session	*/
    Setpallete(&pallette[0]);		/* restore pallete		*/
}
