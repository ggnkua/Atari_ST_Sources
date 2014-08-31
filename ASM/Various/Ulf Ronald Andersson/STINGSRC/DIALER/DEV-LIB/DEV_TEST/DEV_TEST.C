#include "import.h"
#include <device.h>

#include "export.h"

/*
 * Small program to print out all available serial ports and the
 * available speeds
 */
GLOBAL WORD main( VOID )
{
	DEV_LIST	*ports, *walk;
	LONG		*speeds;
	
	if( (ports=InitDevices( NULL, NULL ))==NULL )
		return( FAILURE );
	
	walk = ports;
	while( walk )
	{
		if( OpenDevice( walk ) )
		{
			speeds = GetSpeedList( walk );
			
			printf( "\nPort: %s (curr. DTE: %ld)", walk->name, walk->curr_dte );
			printf( "\nAvailable DTE speeds:" );
			while( *speeds>=0 )
				printf( "\n                      %ld", *speeds++ );
			
			/*
			 * Here could be some more code, e.g. initializing the 
			 * modem and so on. Some examples:
			 *
			 * Init the modem:
			 * PortSendBlock( walk, "atz0\r", 5, FALSE ); 
			 *
			 * Dial out:
			 * PortSendBlock( walk, "atd499112448701\r", 16, FALSE );
			 *
			 * Check, if a char is available from the port and read it:
			 * if( CharAvailable( walk ) )
			 *     c = PortGetByte( walk );
			 */
			CloseDevice( walk );
			
			printf( "\n\n                             ... [RETURN] to continue" );
			getchar( );
		}
		
		
		walk = walk->next;
	}
	
	TermDevices( );
	
	return( SUCCESS );
}

