/*	ST_TYPE.C
*	Program to find details of the ST similar to HiSoft's CHECKST.PRG
*
*	Thanks to HiSoft for the idea and their excellent service to the 
*	ST community and for Lattice C v5
*
*	Mark S Baines
*	v1.3
*	20 10 90
*	Lattice C v5.06.01
*
*	NB: many functions are necessarily Lattice v5 ones and so this code will
*	probably not compile on another compiler without work. Also I've no idea
*	whether this will work on ALL ST varieties, it should though :->
*/


#include <aes.h>
#include <vdi.h>
#include <dos.h>
#include <osbind.h>
#include <stdlib.h>
#include <stdio.h>

static char *country;					/* global variables */
static char *memory;
static char *rez;
static char *rom_date;
static char *device = "CON:";			/* for printing to the console */

int gdos;
long phystop_value, sysbase_value;
short blitter, rom_ver, aes_ver; 
unsigned short dos_ver;


char *which_country(int value)			/* return country of ROM string */
{
	switch(value)
	{
		case 0: country = "USA"; break;
		case 1: country = "Germany"; break;
		case 2: country = "France"; break;
		case 3: country = "Great Britain"; break;
		case 4: country = "Spain"; break;
		case 5: country = "Italy"; break;
		case 6: country = "Sweden"; break;
		case 7: country = "Switzerland (French)"; break;
		case 8: country = "Switzerland (German)"; break;
		case 9: country = "Turkey"; break;
		case 10: country = "Finland"; break;
		case 11: country = "Norway"; break;
		case 12: country = "Denmark"; break;
		case 13: country = "Saudi Arabia"; break;	/* 13 and 14 may be */
		case 14: country = "Holland"; break;		/* transposed */
		default: country = "Unknown"; break;
	}
	return (country);
}	


long sysbase(void)						/* find contents of ST variable '_sysbase' */
{
	long m = *(long*) 0x4F2;
	return m;
}


char *peek_date(char *rom_date)			/* peek ROM for ROM date */
{
	rom_date[0] = *(char*) (sysbase_value + 0x18);
	rom_date[1] = *(char*) (sysbase_value + 0x19);
	rom_date[2] = *(char*) (sysbase_value + 0x1A);
	rom_date[3] = *(char*) (sysbase_value + 0x1B);
	return rom_date;
}


long phystop(void)						/* find contents of ST variable 'phystop' */
{
	long m = *(long*) 0x42E;
	return m;
}


char *which_mem(long value)				/* return amount of memory string */
{
	switch(value)
	{
		case 0x40000: memory = "256 K"; break;
		case 0x80000: memory = "512 K"; break;
		case 0x100000: memory = "1 Mb"; break;
		case 0x180000: memory = "1.5 Mb"; break;
		case 0x200000: memory = "2 Mb"; break;
		case 0x280000: memory = "2.5 Mb"; break;
		case 0x300000: memory = "3 Mb"; break;
		case 0x380000: memory = "3.5 Mb"; break;
		case 0x400000: memory = "4 Mb"; break;
		default: memory = "Unknown"; break;
	}
	return (memory);
}


char *which_res(short value)			/* return the resolution string */
{
	switch(value)
	{
		case 0: rez = "Low Colour Resolution"; break;
		case 1: rez = "Medium Colour Resolution"; break;
		case 2: rez = "Mono - High Resolution"; break;
		default: rez = "Unknown - A3 Monitor, Atari TT??"; break;
	}
	return (rez);
}


void results(void)						/* get results */
{
	appl_init();						/* for AES version number */
	dos_ver = Sversion();				/* GEMDOS version */
	rez = which_res(Getrez());			/* monitor resolution */
	blitter = Blitmode(-1);				/* blitter present */
	gdos = vq_gdos();					/* GDOS present */
	aes_ver = _AESglobal[0];			/* AES version */
	country = which_country(_country);	/* country of ROM */
	rom_ver = _tos;						/* TOS version */
	phystop_value = Supexec(phystop);	/* get end of physical memory under Supervisor mode */
	memory = which_mem(phystop_value);	/* amount of RAM memory */
	sysbase_value = Supexec(sysbase);	/* get ROM start address under Supervisor mode */
	rom_date = Supexec(peek_date);		/* ROM creation date under Supervisor mode */
	appl_exit();
}


void printout(void)						/* printout results */
{
	FILE *fp;

	fp = fopen(device,"w");				/* open file device for writing */
	fprintf(fp,"ST TYPE v1.3\n");		/* print results to device */
	fprintf(fp,"by Mark S Baines 1990\n\n");
	fprintf(fp,"TOS Version:    %d.%d\n\n",rom_ver>>8,rom_ver&0xff);
	fprintf(fp,"ROM Date:       %x %x %x%x\n\n",rom_date[1],rom_date[0],rom_date[2],rom_date[3]);
	fprintf(fp,"GEMDOS Version: %d.%d\n\n",dos_ver&0xff,dos_ver>>8);
	fprintf(fp,"AES Version:    %d.%x\n\n",aes_ver>>8,aes_ver&0xff);
	fprintf(fp,"Nationality:    %s\n\n",country);
	fprintf(fp,"Monitor:        %s\n\n",rez);
	fprintf(fp,"RAM Memory:     %s\n\n",memory);
	if (blitter&2)
		fprintf(fp,"Blitter Chip:   Yes\n\n");
	else
		fprintf(fp,"Blitter Chip:   No\n\n");
	if (gdos == 0)
		fprintf(fp,"GDOS Loaded:    No\n\n");
	else
		fprintf(fp,"GDOS Loaded:    Yes\n\n");
	fclose(fp);							/* close file device */
}


void main(void)							/* get and display results */
{
	int c;

	results();							/* get results */
	printout();							/* print to console */
	printf("\a\nPress \033pp\033q to send to Printer\n");
	printf("Press Return to exit\n");
	
	c = getch();
	if (c == 'p' || c == 'P')
	{
		device = "PRN:";				/* print to printer if user requires */
		printout();
		exit(EXIT_SUCCESS);		
	}
	else								/* or exit */
		exit(EXIT_SUCCESS);
}
