/*
	file: main.c
	utility:
	date: 1989
	author: Jim Charlton
	modifications:
		1996: C. Moreau: 
	comments: 
*/
#include <stddef.h>
#include <stdlib.h>

#ifdef __PUREC__ 
#include <aes.h>
#include <tos.h>
#include <vdi.h>
#include <compend.h>
#else
#include <aesbind.h>
#include <osbind.h>
#include <vdibind.h>
#endif

#include "bufman.h"
#include "events.h"
#include "init.h"
#include "main.h"
#include "menu.h"
#include "wind.h"

/*
	globals vars
*/
int gl_apid;		/* global application identifier */

/*
	name: main
	utility: executes initialization code and the starts the program. 
	comment: 
	parameters:
	return: none
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C.Moreau:
		10 may 96: C.Moreau: reduce link to init.c: init() 
*/
void main(int argc, char *argv[])
{
	/*
		Initiailize the ROMs.
	*/
	if ((gl_apid = appl_init()) != -1)
	{
		init(&argc, &argv);
	
		/*
			Handle events for application.
		*/
		TaskMaster(); 
	
		/*
			bye...  Note: This will never be executed.
		*/
	
		shutdown(0);
	}
}

/*
	name: shutdown
	utility: is the code that closes down the application. 
	comment: This routine is called when errors occurs and
		guarantees that all window's will be closed properly
		before exiting.
	parameters:
	return:
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C.Moreau: 
*/
void shutdown(int code)
{
	int	dummy,event;

	/*
		Close down the windows.
	*/
	while(thefrontwin)
	{
		dispose_buf( thefrontwin );
		window_dispose(thefrontwin);
	}
		
	/*
		free cutbuffer space
	*/
	if (cutbuffer)
		free(cutbuffer);

	/*
		Clean up the io buffer because of bug in TOS ?
	*/
	do
	{
		event = evnt_multi( MU_TIMER|MU_KEYBD,0,0,0,
			0,0,0,0,0, 0,0,0,0,0,
			NULL, 1, 0,
			&dummy, &dummy, &dummy, &dummy, &dummy, &dummy );
	} while( event & MU_KEYBD );

	/*
		Shut down the application.
	*/
	graf_mouse(ARROW, NULL);
	menu_bar(menu, MENU_REMOVE);
	v_clsvwk(phys_handle);
	appl_exit();

	/*
		bye ...
	*/
 	exit(code);
}

