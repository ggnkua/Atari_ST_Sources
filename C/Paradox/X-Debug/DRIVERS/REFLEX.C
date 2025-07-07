
/* a Reflex screen driver for XXX
	Note that this driver will think a Moniterm is a Reflex card
	
	This driver understands protocol version 1
*/

/*
	Compiled with Lattice C 5.06.02

	Important: MUST be compiled with:
		-b0	non base relative data
		-v	disable stack checks
	
	Dont use register arguments.
	This REQUIRES 16-bit ints (as it is based on Lazer C)

	No screen must be wider than 1280 or taller than 1024 pixels.
*/

/* define test to test on a Moniterm */
#define TEST 0

#include <stdio.h>
#include <stdlib.h>
#include <linea.h>
#include <osbind.h>
#include "driver.h"


#define	SCREEN	0x00C00000L

extern short check_ram(long addr);
short init_monitor(void);

int reg_table[16];
unsigned char *reg_base;

int main(int argc, char *argv[])
{
struct driver *driver;
int version;
int mode;
FILE *fp;
int i;
char name[] = "A:\\REFLEX.INF";
long old;

	linea0();

	if (argc<4)
		goto usage;
	if (sscanf(argv[1],"VER=%x",&version)!=1)
		goto usage;
	if (sscanf(argv[2],"BUF=%lx",&driver)!=1)
		goto usage;
	if (sscanf(argv[3],"MODE=%x",&mode)!=1)
		goto usage;
	
	if (check_ram(SCREEN+10)==0)
		return 10;						/* if Reflex not there (+10 avoids trashing magic entries) */	

	/* read the config file */

	old=Super(0L);
	name[0]=(*(short*)0x446) + 'A';		/* get boot drive */
	Super(old);

	fp=fopen(name,"rt");
	if (fp==NULL)
		return 10;						/* if no file */

	for (i=0; i<16; i++)            /* Read set-up file            */
		fscanf(fp,"%x",&reg_table[i]);

	fclose(fp);

	/* its there. Init the driver structure */
	driver->address = SCREEN;
	driver->planes = 1;
	#if TEST
	driver->bytesperline = 160;
	#else
	driver->bytesperline = 128;
	#endif
	driver->width = (reg_table[2]-reg_table[1])*16;
	driver->height = reg_table[6]-reg_table[5];
	if (reg_table[11] & (1<<9))
		driver->height<<=1;
	driver->font = -1;					/* IMPORTANT */
	driver->init = init_monitor;
	driver->start = SCREEN;
	driver->end = SCREEN+0x20000L;		/* it has 128k of RAM */
	driver->gem=driver->tos=(long)Logbase()==SCREEN ? 1 : 0;

	if (mode&0x100)
		driver->height>>=1;				/* halve the height if required */
	return 0;

usage:
	printf("X-Debug screen driver for Reflex Version 1.0\n\
Copyright ½ 1991 Andy Pennell. All Rights Reserved\n");

	if (getenv("SHELL")==NULL)
		Bconin(2);						/* for non-CLI users (crazy people) */
	return 10;
}



void setreg(no,value)                   /* set value of 34061 register  */
unsigned int no, value;
{
        reg_base[1+(no<<3)]= (unsigned char) (value & 0xFF);
        reg_base[5+(no<<3)]= (unsigned char) (value >> 8);
}

unsigned int getreg(no)                 /* get value of 34061 register  */
unsigned int no;
{
unsigned int value;

    value= reg_base[1+(no<<3)] | ((unsigned int)(reg_base[5+(no<<3)]) << 8);
    return(value);
}


void setclk(unsigned int value)
{
unsigned int *word;

        word= (unsigned int *)reg_base;
        *word= (*word & 0xFF) | (value << 8);
}



/*	this initialisation code is called AFTER this program has terminated, so it must not assume
	any registers (eg baseregs) or make library calls that assume files are open (eg printf) or attempt
	to terminate or allocate GEMDOS memory. You have been warned

	This function will be called in Supervisor mode.

	If for some reason you cannot install, return a non-zero value. This code can initialise hardware registers,
	for example, as no actual initialisation should be performed in main() as the user may not, after all,
	require the services of this monitor.
*/

short init_monitor(void)
{
int i;

	reg_base = (char*) 0xC80000L;
	
        setclk(reg_table[15]);          /* set to clock no. 0 (80 MHz)          */

        for (i=0; i<=12; i++)           /* Set Reflex registers         */
        setreg(i, reg_table[i]);

	setreg(12,0x2000 | getreg(12));		/* turn display on */

	return 0;					/* always install */
}
