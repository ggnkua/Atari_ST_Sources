
/*
  This driver understands protocol version 1
	
  No screen must be wider than 1280 or taller than 1024 pixels.
*/

/*
  Compiled with Lattice C 5.52
  
  Important: MUST be compiled with:
		-b0	non base relative data
		-v	disable stack checks
	
	Dont use register arguments.
	Either int size is be OK but I use 16-bit ints for smaller prog size.
*/

#include <stdio.h>
#include <stdlib.h>
#include <linea.h>
#include <osbind.h>
#include "driver.h"


short init_monitor(void);


int main(int argc, char *argv[])
{
struct driver *driver;
int version;
int mode;

	linea0();

	if (argc<4)
		goto usage;
	if (sscanf(argv[1],"VER=%x",&version)!=1)
		goto usage;
	if (sscanf(argv[2],"BUF=%lx",&driver)!=1)
		goto usage;
	if (sscanf(argv[3],"MODE=%x",&mode)!=1)
		goto usage;
	

	driver->address = (long)Physbase();
	driver->planes = 1;
	driver->bytesperline = 80;
	driver->width = 640;
	driver->height = 480;
	driver->font = -1;					/* IMPORTANT */
	driver->init = init_monitor;
	driver->start = (long)Physbase();
	driver->end = (long)Physbase()+80*480;
	driver->gem=driver->tos=0;


	/* work out if its being used by the system */
	if (1 /*(long)Logbase() == SCREEN*/)	
		{
		long cursor;
		driver->gem=1;
		cursor=(long)V_CUR_AD;
		if ( 1 /*(cursor>=SCREEN) && (cursor<(SCREEN+80*480))*/ )
			driver->tos=1;	/* if TOS cursor somewhere in the video RAM */
		}

	if (mode&0x100)
		driver->height>>=1;	/* halve the height if required */
	return 0;

usage:
	printf("XXX screen driver for Falcon 2 colour 640*480 Version 1.0\n\
Modified from Moniterm driver by Kevin O'Donovan.\n");

	if (getenv("SHELL")==NULL)
		Bconin(2);	/* for non-CLI users (crazy people) */
	return 10;
}


/* this initialisation code is called AFTER this program has terminated,
   so it must not assume any registers (eg baseregs) or make library
   calls that assume files are open (eg printf) or attempt to
   terminate or allocate GEMDOS memory. You have been warned

   This function will be called in Supervisor mode.

   If for some reason you cannot install, return a non-zero
   value. This code can initialise hardware registers, 	for example,
   as no actual initialisation should be performed in main() as the user
   may not, after all, 	require the services of this monitor.
*/

short init_monitor(void)
{
	return 0;					/* always install */
}
