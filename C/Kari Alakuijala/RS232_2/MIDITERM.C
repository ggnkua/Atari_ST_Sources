/* MIDITERM.C                              copyright 1989 by Kari Alakuijala */

#include <stdio.h>
#include <osbind.h>

#define CON 2
#define MIDI 3

int i, j;                               /* i contains speed,j 6850 ctrl reg. */
long tmpstck;
char *k = 16776196;                     /* $FFFC04 = MIDI ACIA CTRL register */




main()
{
	logo();
	handle_RS_port();
	terminal();
}


logo()
{
	clearscreen();
	printf("                               Miditerm.C\n");
	printf("                               ----------\n");
	printf("\n\nThis is a sample terminal programme for use with MIDI or the 2nd\n");
	printf("RS-232 interface. A compete multitasking BBS programme under MT C-\n");
	printf("shell will come out after 6 months. This file is only added to show\n");
	printf("some programming examples and to test the 2nd RS-232 interface.\n\n");
	printf("Enter some parameters:\n\n");
}


handle_RS_port()
{
	getspeed();                     /* Get datas from console and */
	setspeed();                     /* set them to timer A of 68901. */
	clearscreen();
	getparms();                     /* Get datas from console and */
	setparms();                     /* set them to MIDI ACIA ctrl reg. */
}


terminal()
{
	char c, d;
	clearscreen();
	printf("VT52 -terminal mode activated. Press CONTROL-A to enter commands:\n\n");
	menu();
	while(d!='x')
	{
		d=0;
		while(d!=1)
		{
			if(Bconstat(MIDI))
			{
				c=Bconin(MIDI);
				Bconout(CON,c);
			}
			if(Bconstat(CON))
			{
				d=Bconin(CON);
				if (d!=1) Bconout(MIDI,d);
			}
		}
		Cursconf(3,0);          /* jamms cursor */
		while (Bconstat(CON));
		d=Bconin(CON);	
		Cursconf(2,0);          /* resumes blinking cursor */
		if(d!='b' & d!='l' & d!='h' & d!='x' & d!='v' & d!='p')
		{
			Bconout(MIDI,1);
			Bconout(MIDI,d);
		}

		if (d=='b')
		{
			supervise(96,10);
		}

		if (d=='l')
		{
			supervise(96,150);
		}

		if (d=='h')
		{
			supervise(64,120);
		}

		if (d=='x')
		{
			printf("\n\nReturn to Desktop!\n");
			delay(60);
		}

		if (d=='v')
		{
			getspeed();
			setspeed();
		}

		if (d=='p')
		{
			printf("\n");
			getparms();
			setparms();
		}
	}
}


getspeed()
{
	while (i<75 || i>19200)
	{
		i=0;
		printf("\nGive me the 2nd RS speed in bps (75, ... ,4800,6400,9600,19200): ");
		scanf("%d",&i);
	}
	i=19200/i;                      /* 75-19200 --> 256-1 */
	i=i&255;                        /* 256 --> 0 */             
	delay(60);
}


getparms()
{
	printf("Give me the settings for word lenght/stop bits/parity\n\n");
	printf("  1) 7 databits, 2 stopbits, even parity\n");
	printf("  2) 7 databits, 2 stopbits, odd parity\n");
	printf("  3) 7 databits, 1 stopbit,  even parity\n");
	printf("  4) 7 databits, 1 stopbit,  odd parity\n");
	printf("  5) 8 databits, 2 stopbits, no parity\n");
	printf("  6) 8 databits, 1 stopbit,  no parity\n");
	printf("  7) 8 databits, 1 stopbit,  even parity\n");
	printf("  8) 8 databits, 1 stopbit,  odd parity\n");
	while(j<1 || j>8)
	{
		j=0;
		printf("\nGive me (1-8): ");
		scanf("%d",&j);
	}
	j=(j-1)*4+129;
	delay(60);
}


setspeed()
{
	Xbtimer(0,1,i&255,-1);          /* start timer A of 68901
		        Value of 68901's Timer A ctrl register: 1
		        Value of 68901's Timer A data register: i */
}


setparms()
{
	tmpstck=Super((long)0);
	*k=j;
	Super(tmpstck);                 /* set integer J to 6850 control
	                                   register at $FFFC04 */
}


clearscreen()
{
	Bconout(CON,27);
	Bconout(CON,'E');
}


delay(loops)
int loops;
{
	int loop;
	for(loop=1;loop<=loops;loop++)Vsync();
}


menu()
{
		printf("  b) Send break.\n");
		printf("  l) Send long break.\n");
		printf("  h) Drop DTR (hangup).\n");
		printf("  x) Return to Desktop.\n");
		printf("  v) Set 2nd RS speed.\n");
		printf("  p) Set 2nd RS other parameters.\n\n\n");
}


supervise(add,dely)
int add,dely;
{
j=j+add;
setparms();
delay(dely);
j=j-add;
setparms();
}
