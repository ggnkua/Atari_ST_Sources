#include "stdio.h"
#include "gemdefs.h"
#include "obdefs.h"
#include "osbind.h"
#include "mkrsc.h"
#include "globals.h"


int init()
{
	if (!rsrc_load("mkrsc.rsc")) {
        form_alert(1, "[0][Cannot find mkrcs.rsc file|Terminating ...][OK]");
		exit(1);
	}
 /* set addresses for dialog boxes and menubar */
   	rsrc_gaddr(0, MKRSCMNU, &mkrscmnu);
    rsrc_gaddr(0, BUTTONT, &buttont);
    rsrc_gaddr(0, OLDTREE, &oldtree);
    rsrc_gaddr(0, TIST, &tist);
    rsrc_gaddr(0, BOXCT, &boxct);
    rsrc_gaddr(0, TREICONT, &treicont);
    rsrc_gaddr(0, OBICONT, &obicont);
    rsrc_gaddr(0, MNUICONT, &mnuicont);
    rsrc_gaddr(0, NAMOBJT, &namobjt);
    rsrc_gaddr(0, DUMMNU, &dummnu);
    rsrc_gaddr(0, MTBOX1, &mtbox1);
    rsrc_gaddr(0, NEWTREE, &newtree);
    rsrc_gaddr(0, BOXT, &boxt);
    rsrc_gaddr(0, ABOUTT, &aboutt);
    rsrc_gaddr(0, SORTD, &sortd);
    rsrc_gaddr(0, NEWTOP, &newtop);

	mkrscmnu[SNAP].ob_state = CHECKED;
	snap = TRUE;

}


/*
    open_workstation  -  Open a VDI virtual workstation.
    from Laser C VDI examples. Also sets up the MFDB

    Note:
      information about the workstation is returned in the
      parameter `form'. appl_init() must be called previously.
*/
int open_workstation(form)
    register MFDB   *form;
{
	register int x;
	int      work_in[11];
	int      work_out[57];
	int      dummy;
	int      whandle;
	int		 ret;
#ifdef __GNUC__
    short    GDOS = 0;
#else
    int      GDOS = 0;
#endif
  
      /*
          Does GDOS exist?
      */
#ifndef __GNUC__
      asm {
			move.w  #-2, D0
			trap    #2
			cmp.w   #-2, D0
			beq     gdos_not_installed
			move.w  #1, GDOS(A6)
	gdos_not_installed:
      }
#else
    __asm__ volatile
    ("
            movew  #-2, d0
            trap   #2
            cmpw   #-2, d0
            beq    1f
            movew  #1, %0
         1:"
    : "=g"(GDOS)	/* outputs */
    :
    : "d0", "d1", "d2", "a0", "a1", "a2"); /* clobbered reggies */
#endif

    /*
        Initialize workstation variables.
    */
    if (GDOS)
        work_in[0] = Getrez() + 2;
    else
        work_in[0] = 1;

    for(x=1; x<10; x++)
        work_in[x] = 1;

    /*
        Set for Raster Coordinate System.
    */
    work_in[10] = 2;

    /*
        Get the workstaion handle and the character sizes
        Get the desktop dimensions
        Open Virtual Workstation
    */
        whandle = graf_handle(&gl_wchar,&gl_hchar,&gl_wbox,&gl_hbox);
     	ret = wind_get(0, WF_WORKXYWH, &xdesk, &ydesk, &wdesk, &hdesk);
        v_opnvwk(work_in, &whandle, work_out);

    /*  
        Check for error.
    */
    if (!whandle) {
        Cconws("\033E Error: Cannot open Virtual Device");
        Bconin(2);
        exit(1);
    }

    /*
        Set up the Memory Form Definition Block (MFDB).  This 
        structure is defined in <gemdefs.h>.
    */

    /*
        The Base address of the drawing screen.
    */
    form -> fd_addr = Logbase();

    /*
        The width of the screen in pixels.
    */
    form -> fd_w    = work_out[0] + 1;

    /*
        The height of the screen in pixels.
    */
    form -> fd_h    = work_out[1] + 1;

    /*
        The number of words in the width of the screen.
    */
    form -> fd_wdwidth  = form -> fd_w / 16;

    /*
        Working in a raster coordinate system.  
    */
    form -> fd_stand       = 0;

    /*
        The number of drawing planes.
    */
    switch(work_out[13]) {
        case 16: form -> fd_nplanes = 4; break;
        case 8: form -> fd_nplanes = 3; break;
        case 4: form -> fd_nplanes = 2; break;
        default: form -> fd_nplanes = 1; break;
    }  

    /*
        Return the workstation whandle.
    */
    return whandle;
}

 
/*
	shutdown - is the code that closes down the application.  This routine
		is called when errors occurs and guarantees that all window's will
		be closed properly before exiting.
*/
shutdown(code)
	int code;
{
	/*
		Clean up memory.
	*/
	cleanup();

	/*
		Clean up the io buffer because of bug in TOS ?
	*/

	while(Cconis()) Crawcin();

	/*
		Close the workstation and shut down the application.
	*/

	v_clsvwk(handle);

	appl_exit();

	/*
		bye ...
	*/
	exit(code);
}


/*
	cleanup - releases the memory used by the application.
*/
cleanup()
{
	windowptr	thewin;

	/*
		Close down the windows.
	*/
	if(firstwindow)
	for (thewin = firstwindow; thewin; thewin = thewin -> next)
		dispose_window(thewin);

/*		Free memory used by resource.	*/
	
	rsrc_free(); 

}

init_path()	/* initialize fs_inpath with current path */
{
	int drv;
	char lastpath[80];

	drv = Dgetdrv();
	Dgetpath(lastpath,drv+1);
	sprintf(fs_inpath,"%c:%s\\*.*",'A' + drv,lastpath);
	strcpy(fs_insel,"untitled");
}

int	create_newtops()
{
	int numobjs, order[25], i, j;

	j = 1;
	tredesk[0] = *newtop;
	tredesk[0].ob_x = xdesk;
	tredesk[0].ob_y = ydesk;
	tredesk[0].ob_width = wdesk;
	tredesk[0].ob_height = hdesk;

	numobjs = trav_tree(treicont,order);
	for(i=1;i<numobjs;i++)
		tredesk[j++] = treicont[order[i]];

	tredesk[0].ob_flags = 0;
	tredesk[j-1].ob_flags = 0x20;
	objc_add(tredesk,0,1);


	j = 1;
	mnudesk[0] = *newtop;
	mnudesk[0].ob_x = xdesk;
	mnudesk[0].ob_y = ydesk;
	mnudesk[0].ob_width = wdesk;
	mnudesk[0].ob_height = hdesk;

	numobjs = trav_tree(mnuicont,order);
	for(i=1;i<numobjs;i++)
		mnudesk[j++] = mnuicont[order[i]];
	mnudesk[0].ob_flags = 0;
	mnudesk[j-1].ob_flags = 0x20;
	objc_add(mnudesk,0,1);

	j = 1;
	obdesk[0] = *newtop;
	obdesk[0].ob_x = xdesk;
	obdesk[0].ob_y = ydesk;
	obdesk[0].ob_width = wdesk;
	obdesk[0].ob_height = hdesk;

	numobjs = trav_tree(obicont,order);
	for(i=1;i<numobjs;i++)
		obdesk[j++] = obicont[order[i]];
	obdesk[0].ob_flags = 0;
	obdesk[j-1].ob_flags = 0x20;
	objc_add(obdesk,0,1);

	hightreadr = (int)(((long)tredesk) >>16);
	lowtreadr = (int)tredesk;
	highmnuadr = (int)(((long)mnudesk) >>16);
	lowmnuadr = (int)mnudesk;
	highobadr = (int)(((long)obdesk) >>16);
	lowobadr = (int)obdesk;

	treicont[1].ob_x = xdesk;
	treicont[1].ob_y = ydesk;
	mnuicont[1].ob_x = xdesk;
	mnuicont[1].ob_y = ydesk;
	obicont[1].ob_x = xdesk;
	obicont[1].ob_y = ydesk;
}
	
