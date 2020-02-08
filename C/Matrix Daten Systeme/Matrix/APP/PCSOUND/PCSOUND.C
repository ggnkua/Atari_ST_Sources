# include <stdio.h>
# include <stdlib.h>
# include <tos.h>
# include <ext.h>

# include "sndbind.h"

# define MByte (1024L * 1024L)

typedef struct
{
	long	play;
	long	record;
	long	res1;
	long	res2;
} BUF_PTR ;

int msg (char * s)
{
	printf (s);
	while (!kbhit());
	return getch();
}

void main ( void )
{
	int snd_status;
	long available, buflen;
	char * buf;
	int quit = 0;
	long curadder, curadc;
	BUF_PTR ptr;
		
	snd_status =  (int) locksnd();
	
	if ( snd_status == 1 )
	{
		printf ("sound system OK\n");
		sndstatus(1);
		soundcmd (LTATTEN,0);				/* Set Left Attenuation to zero */
		soundcmd (RTATTEN,0);				/* Set Right Attenuation to zero */
		soundcmd (LTGAIN,0x80);				/* Set Left Gain to 8 */
		soundcmd (RTGAIN,0x80);				/* Set Right Gain to 8 */
		settrack (1, 1);
		curadder = soundcmd(ADDERIN, INQUIRE);
		curadc = soundcmd (ADCINPUT, INQUIRE);
		soundcmd (ADDERIN, 3);				/* Adder input from ADC only */
		soundcmd (ADCINPUT, 0);
		setmode (STEREO16);
		
		available = (long) Malloc (-1);
		
		if (available > 4L * MByte)
			buflen = 4L * MByte;
		else if (available > 3L * MByte)
			buflen = 3L * MByte;
		else if (available > 2L * MByte)
			buflen = 2L * MByte;
		else if (available > 1L * MByte)
			buflen = 1L * MByte;
		else
			buflen = 0L;
		
		printf ("Record buffer is %li bytes long\n", buflen);
			
		if (buflen > 0L)
		{
			if ((buf = malloc (buflen)) != NULL)
			{
				devconnect (ADC, DAC, CLK_25M, CLK25K, NO_SHAKE);

				for ( ; quit != 'q' ; )
				{
					msg ("Press a key to record\n");
					
					setbuffer (RECORD, buf, buf + buflen);
					buffoper (RECORD_ENABLE | RECORD_REPEAT);
					printf ("Recording...\nPress a key to stop\n\n\033f");
					while (!kbhit())
					{
						buffptr (&ptr);
						printf ("\033A%li\n", ptr.record);
					}
					getch();

					setbuffer (PLAY, buf, buf + buflen);
					buffoper (PLAY_ENABLE);
					printf ("Playing\n\n");
					while (!kbhit())
					{
						buffptr (&ptr);
						printf ("\033A%li\n", ptr.play);
					}
					getch();
					quit = msg ("\033ePress a key to restart or 'Q' to quit\n");
				}				
				free (buf);
			}
			else
				printf ("malloc failed!\n");
		}
		sndstatus (1);
		soundcmd (ADDERIN, (int)curadder);
		soundcmd (ADCINPUT, (int)curadc);
		unlocksnd ();
	}
	else
		printf ("sound system ***LOCKED***\n");
}
