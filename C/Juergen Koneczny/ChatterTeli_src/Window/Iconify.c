#include	<mt_mem.h>
#include	<PORTAB.H>
#include	<MT_AES.H>
#include	<STDDEF.H>

#include	"Menu.h"
#include	"Window.h"
#include	"Window\Event.h"


WORD	cdecl	HandleIconifyDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD )
{
	if ( Obj < 0 )
	{
		switch( Obj )
		{
			case	HNDL_INIT:
				break;
			case	HNDL_CLSD:
				return( 0 );
			case	HNDL_MESG:
			{
				if( Events->msg[0] == WM_UNICONIFY )
					return( 0 );
				break;
			}
		}
	}
	return( 1 );
}

ULONG	MenuKontextIconify( WORD WinId, WORD Global[15] )
{
	return( MENUE_KONTEXT_WINDOW_CYCLE );
}
