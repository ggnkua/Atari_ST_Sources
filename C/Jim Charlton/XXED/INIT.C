
#include <osbind.h>
#include <gemdefs.h>
#include <obdefs.h>

#include "xxed.h"	/* header file created by RCP     */
#include "globals.h"  	/* contains definition of menubar */


init_resources()  /* loads resource array */
{
/*	if (!rsrc_load("xxed.rsc")) {
		form_alert(1, "[0][Cannot find xxed.rsc file|Terminating ...][OK]");
		exit(2);
	}
*/
		mrsrc_load(XXEDRSC);  /* using .C RSC */

}

init_menu()  /* sets up menu bar  */
{
	rsrc_gaddr(0, MENUBAR, &menubar);
	menubar[FSIZE].ob_spec = fsize_str;
	menubar[POS].ob_spec = pos_str;
	menu_bar(menubar, 1);
}

init_dialog()  /* sets up dialog boxes  */
{
    rsrc_gaddr(0, DIALOG2, &dialog2);
    rsrc_gaddr(0, DIALOG1, &dialog1);
    rsrc_gaddr(0, DIALOG3, &dialog3);
    rsrc_gaddr(0, DIALOG4, &dialog4);
    rsrc_gaddr(0, DIALOG5, &dialog5);
    rsrc_gaddr(0, DIALOG6, &dialog6);

	((TEDINFO *)dialog1[SSTRING].ob_spec)->te_ptext = s_str;
	((TEDINFO *)dialog1[SSTRING].ob_spec)->te_txtlen = 24;
	((TEDINFO *)dialog1[RSTRING].ob_spec)->te_ptext = r_str;
	((TEDINFO *)dialog1[RSTRING].ob_spec)->te_txtlen = 24;
	dialog4[DRSTR1].ob_spec = dr_str;
	dialog1[SSTRBUT].ob_state = SELECTED;
	dialog1[RSTRBUT].ob_state = SELECTED;

}

init_path()	/* initialize fs_inpath with current path */
{
	int drv;

	drv = Dgetdrv();
	Dgetpath(lastpath,0);
	sprintf(fs_inpath,"%c:%s\\*.*",'A' + drv,lastpath);
	strcpy(fs_insel,"untitled");
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
		Shut down the application.
	*/
	v_clsvwk(phys_handle1);
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
	for (thewin = firstwindow; thewin; thewin = thewin -> next)
	{	dispose_buf(thewin);
		dispose_window(thewin);
	}

	/*
		free cutbuffer space
	*/

	if(cutbuffer) free(cutbuffer);


	/*
		Free memory used by resource.
	
	rsrc_free();  not needed now as using .C RSC

	*/
}


/*
	open_vwork - Open a virtual workstation.

	Note: a virtual workstation is associated with each window created.
		This means that each window's graphic attributes are independent
		of the other's.
*/
int open_vwork(form)
	register MFDB	*form;
{
	register int x;
	int 	 work_in[11];
	int		 handle, d;
	int		 work_out[57];

	/*
		Initialize workstation variables.
	*/
	for(x=0; x<10; x++)
		work_in[x] = 1;

	work_in[10] = 2;

	handle = graf_handle(&d, &d, &d, &d);
	v_opnvwk(work_in, &handle, work_out);

	form -> fd_addr 	= Logbase();
	form -> fd_w		= work_out[0] + 1;
	form -> fd_h		= work_out[1] + 1;
	form -> fd_wdwidth	= form -> fd_w / 16;
	form -> fd_stand	= 0;

	switch(work_out[13]) {
		case 16: form -> fd_nplanes = 4; break;
		case 08: form -> fd_nplanes = 3; break;
		case 04: form -> fd_nplanes = 2; break;
		default: form -> fd_nplanes = 1; break;
	}

	return handle;
}
