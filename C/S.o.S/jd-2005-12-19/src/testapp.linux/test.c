#include <mint/falcon.h>
#include <unistd.h>
#include "joystick.h"
#include <stdio.h>
#include <fcntl.h>

#define JOY_DEV "/dev/joypad1"

int main()
{
	int joy_fd;
	int quit=0;

	struct JS_DATA_TYPE js;


	/* open the joystick */

	if( ( joy_fd = open( JOY_DEV, O_RDONLY ) ) < 0 )
	{
		printf( "Unable to open joystick device %s\n", JOY_DEV );
		return -1;
	}


	printf( "Press any key to quit\n\n" );

	while( !Cconis() )
	{
		/* read the joystick state into js */
		if( read( joy_fd, &js, JS_RETURN ) != JS_RETURN )
		{
			printf( "\nFailed read\n" );
		}

			/* print the results */
		printf("X: % 4d Y: % 4d Fire:%1d%1d%1d%1d System:%1d%1d%1d%1d Special:%1d%1d%1d%1d %1d%1d%1d%1d %1d%1d%1d%1d %1d%1d%1d%1d \r"
				,js.x	/* X axis */
				,js.y	/* Y axis */
				,(js.buttons & 0x00000008) ? 1 : 0		/* Fire    */
				,(js.buttons & 0x00000004) ? 1 : 0
				,(js.buttons & 0x00000002) ? 1 : 0
				,(js.buttons & 0x00000001) ? 1 : 0
				
				,(js.buttons & 0x00000080) ? 1 : 0		/* System  */
				,(js.buttons & 0x00000040) ? 1 : 0
				,(js.buttons & 0x00000020) ? 1 : 0
				,(js.buttons & 0x00000010) ? 1 : 0

				,(js.buttons & 0x80000000) ? 1 : 0		/* special */
				,(js.buttons & 0x40000000) ? 1 : 0		
				,(js.buttons & 0x20000000) ? 1 : 0		
				,(js.buttons & 0x10000000) ? 1 : 0		
				
				,(js.buttons & 0x08000000) ? 1 : 0		
				,(js.buttons & 0x04000000) ? 1 : 0		
				,(js.buttons & 0x02000000) ? 1 : 0		
				,(js.buttons & 0x01000000) ? 1 : 0		

				,(js.buttons & 0x00800000) ? 1 : 0		
				,(js.buttons & 0x00400000) ? 1 : 0		
				,(js.buttons & 0x00200000) ? 1 : 0		
				,(js.buttons & 0x00100000) ? 1 : 0	
				
				,(js.buttons & 0x00080000) ? 1 : 0
				,(js.buttons & 0x00040000) ? 1 : 0
				,(js.buttons & 0x00020000) ? 1 : 0
				,(js.buttons & 0x00010000) ? 1 : 0 );


	}

	close(joy_fd);	/* close joystick device */

	printf( "\n\nDone.\n\n" );

	return 0;
}