#include <mint/falcon.h>
#include <unistd.h>
#include <joystick.h>
#include <stdio.h>
#include <fcntl.h>
#include <sys/ioctl.h>

#define JOY_DEV "/dev/joypad0"

int main()
{
	int joy_fd;
	int quit=0;

	int x_corr=100;
	int y_corr=0;
	int timeout=25;
	
	int temp;

	struct joystick js;


	/* open the joystick */

	if( ( joy_fd = open( JOY_DEV, O_RDONLY ) ) < 0 )
	{
		printf( "Unable to open joystick device %s\n", JOY_DEV );
		return -1;
	}

	ioctl (joy_fd,JOY_SETTIMEOUT,&timeout);
	ioctl (joy_fd,JOY_SET_X_OFFSET,&x_corr);
	ioctl (joy_fd,JOY_SET_Y_OFFSET,&y_corr);

	printf( "Press any key to quit\n\n" );

	while( !Cconis() )
	{
		/* read the joystick state into js */
		if( read( joy_fd, &js, 4*sizeof(int) ) != 4*sizeof(int) )
		{
			printf( "\nFailed read\n" );
		}

			/* print the results */
		printf("X: % 4d Y: % 4d B1:%1d B2:%1d \r"
				,js.x	/* X axis */
				,js.y	/* Y axis */
				,js.b1	/* Fire    */
				,js.b2 );

	}


	printf( "\n\n" );
	ioctl (joy_fd,JOY_GET_X_OFFSET,&temp);
	printf( "X-offset: % 4d\n" , temp );
	ioctl (joy_fd,JOY_GET_Y_OFFSET,&temp);
	printf( "Y-offset: % 4d\n" , temp );
	ioctl (joy_fd,JOY_GETTIMEOUT,&temp);
	printf( "Timeout : % 4d\n" , temp );

	printf( "\n\n" );

	close(joy_fd);	/* close joystick device */


	return 0;
}