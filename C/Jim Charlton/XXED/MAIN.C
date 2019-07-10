#include <gemdefs.h>
#include <osbind.h>
#include <obdefs.h>

#define  extern
#include "globals.h"
#undef   extern


/*
	main - executes initialization code and the starts the program.
*/
main()
{
	int  dummy, button;
	MFDB	main_mfdb;

	/*
		Initiailize the ROMs.
	*/
	gl_apid = appl_init();
	phys_handle1 = open_vwork(&main_mfdb);

/*		Get gl_hchar and gl_wchar	*/

	phys_handle2 = graf_handle(&gl_wchar, &gl_hchar, &dummy, &dummy);

	if(Getrez() == 0)
		{	button = form_alert(1, "[1][ Sorry....    | Need medium or high resolution. ][OK]");
		shutdown(2);
		}      

	/*
		Load resources.
	*/
	init_resources();

	/*
		Read menu resource, draw menu bar, read dialog resources.
	*/
	init_menu();
	init_dialog();
	init_path();

	/*
		Initialize the mouse.
	*/
	graf_mouse(ARROW, NULL);

	set_table();	/*  makes two byte ascii hex table   */


	/*
		Handle events for application.
	*/
	TaskMaster(); 

	/*
		bye...  Note: This will never be executed.
	*/
	shutdown(0);
}

set_table()	/* makes a table of ASCII hex bytes for 0 to 255  */
{	unsigned i;
	
	table[0] = '\0';
	for(i=0;i<256;i++)
		sprintf(table+2*i,"%02x",i);
}
