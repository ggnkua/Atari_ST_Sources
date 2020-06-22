/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <OSBIND.H>
#include <VDI.H>
#include "XA_TYPES.H"
#include "XA_CODES.H"
#include "XA_DEFS.H"
#include "XA_GLOBL.H"
#include "SYSTEM.H"
#include "ABOUT.H"

short shutdown_contrl[]={XA_SHUTDOWN,0,0,0,0};
AESPB shutdown_pb;

/*
	Handle clicks on the system default menu
*/
void do_system_menu(short clicked_title, short menu_item)
{
	switch(menu_item)
	{
		case XA_SYSTEM_ABOUT:	/* Open the "About XaAES..." dialog */
			open_about();
			break;
		case SHUTDOWN:			/* Shutdown the system */
			shutdown=TRUE;
			break;
		
	}
	
}
