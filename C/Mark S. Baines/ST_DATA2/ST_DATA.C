/*	ST_DATA.C
*	Program to find details of the ST similar to HiSoft's CHECKST.PRG
*
*	Thanks to HiSoft for the idea and their excellent service to the 
*	ST community and for Lattice C v5
*
*	Linnhe Computing - Mark S Baines
*	v2.0
*	Modified version of ST_TYPE.C v1.3 and corrected version if ST_DATA v1.0
*	Date started: 06 04 91
*
*	Lattice C v5.06.02
*	Compile Options: -b1 -cafsu -d0 -flm -Lnv -m0 -mt -r1 -rr -t -v -w
*	NB: many functions are necessarily Lattice v5 ones and so this code will
*	probably not compile on another compiler without work.
*	This should work on ALL ST varieties up to ROM 1.62 maybe even the TT!
*	Bug that caused TOS version number for TOS 1.62 to print as 1.98 now fixed
*	Sorry!
*/


#include <aes.h>
#include <vdi.h>
#include <dos.h>
#include <osbind.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

static char *country;					/* global variables */
static char *memory;
static char *rez;
static char *rom_date;
static char drives[32];
static char date_value[13];
static char time_value[10];
static char *month[] = {"dummy","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"};
void *physbase_value;
void *logbase_value;
static char *device = "CON:";			/* for printing to the screen */
FILE *fp; 

int gdos;
long phystop_value, sysbase_value, end_os_value, membot_value, memtop_value;
long exec_os_value; 
short blitter, rom_ver, aes_ver, key_delay, key_repeat, fverify_value, bootdev_value;
short nflops_value, seekrate_value, conterm_value;
unsigned short dos_ver;

/* clear screen, cursor home */			/* some VT52 control codes */
#define CLEAR "\033E" 
#define CLS printf("%s",CLEAR)

/* reverse video */
#define R_VID "\033p" 
#define RVS_VID printf("%s",R_VID)

/* normal video */
#define N_VID "\033q" 
#define NORM_VID printf("%s",N_VID)


										/* functions declarations */
char *which_country(int value)			/* return country of ROM string */
{
	switch (value)
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
	return country;
}	


char *peek_date(char *rom_date) 		/* peek ROM for ROM date */
{
	rom_date[0] = *(char*) (sysbase_value + 0x18);
	rom_date[1] = *(char*) (sysbase_value + 0x19);
	rom_date[2] = *(char*) (sysbase_value + 0x1A);
	rom_date[3] = *(char*) (sysbase_value + 0x1B);
	return rom_date;
}


long sysbase(void)						/* find contents of ST variable '_sysbase' */
{
	long m = *(long*) 0x4F2;
	return m;
}


long phystop(void)						/* find contents of ST variable 'phystop' */
{
	long m = *(long*) 0x42E;
	return m;
}


char *which_mem(long value) 			/* return amount of memory string */
{
	switch (value)
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
		default: memory = "Unknown - More than 4Mb?!"; break;
	}
	return memory;
}


char *which_res(short value)			/* return the resolution string */
{
	switch (value)
	{
		case 0: rez = "ST Low Colour Resolution"; break;
		case 1: rez = "ST Medium Colour Resolution"; break;
		case 2: rez = "ST Mono - High Resolution"; break;
		default: rez = "Unknown - TT??"; break;
	}
	return rez;
}


long membot(void)						/* find contents of ST variable 'membot' */
{
	long m = *(long*) 0x432;
	return m;
}


long memtop(void)						/* find contents of ST variable 'memtop' */
{
	long m = *(long*) 0x436;
	return m;
}


long end_os(void)						/* find contents of ST variable 'end_os' */
{
	long m = *(long*) 0x4FA;
	return m;
}


long exec_os(void)						/* find contents of ST variable 'exec_os' */
{
	long m = *(long*) 0x4FE;
	return m;
}


long fverify(void) 						/* find contents of ST variable 'fverify' */
{
	long m = *(short*) 0x444;
	return m;
}


long bootdev(void) 						/* find contents of ST variable '_bootdev' */
{
	long m = *(short*) 0x446;
	return m;
}


long nflops(void)						/* find contents of ST variable '_nflops' */
{
	long m = *(short*) 0x4A6;
	return m;
}


long conterm(void)						/* find contents of ST variable 'conterm' */
{
	long m = *(char*) 0x484;
	return m;
}


long seekrate(void)						/* find contents of ST variable 'seekrate' */
{
	long m = *(short*) 0x440;
	if (m==0) m = 6;
	if (m==1) m = 12;
	return m;
}


void drivemap(void) 					/* call and process BIOS 'Drvmap' function */
{
	unsigned long bmap;
	int i;

	bmap = Drvmap();					/* get bitmap of drives installed */
	for (i = 0; i < 32; i++)
		if (bmap &1 << i)				/* convert bitmap to array of drive characters */
		drives[i] = i + 'A';
}


void date_time(void)					/* get system date/time and process into ASCII string */
{
	long date;
	char x[6], *p;
	
	date = Gettime();					/* get IKBD date/time */
	ftunpk(date, x);					/* unpack GEMDOS format to array of 6 chars */
	p = stpdate(date_value, 7, x);		/* convert date part of array to ASCII string */
	p = stptime(time_value, 2, &x[3]);	/* convert time part of array to ASCII string */
}


void keyboard(void) 					/* get keyboard initial delay and repeat rate */
{
	short key;

	key = Kbrate(-1,-1);				/* get keyboard rates, do not update values */
	key_delay = key >> 8;				/* initial delay in high byte */
	key_repeat = key &0xff; 			/* repeat rate in low byte */
	key_delay *= 20;					/* convert values in 50Hz system ticks to millisecs */
	key_repeat *= 20;
}	


void results(void)						/* get results */
{
	dos_ver = Sversion();				/* get GEMDOS version */
	rez = which_res(Getrez());			/* get monitor resolution */
	blitter = Blitmode(-1); 			/* get blitter status */
	gdos = vq_gdos();					/* is GDOS present */
	aes_ver = _AESglobal[0];			/* get AES version */
	country = which_country(_country);	/* get country of ROM */
	rom_ver = _tos; 					/* get TOS version */
	phystop_value = Supexec(phystop);	/* get end of physical memory under Supervisor mode */
	memory = which_mem(phystop_value);	/* get amount of RAM memory */
	sysbase_value = Supexec(sysbase);	/* get ROM start address under Supervisor mode */
	rom_date = Supexec(peek_date);		/* get ROM creation date under Supervisor mode */
	membot_value = Supexec(membot); 	/* get start of TPA */
	memtop_value = Supexec(memtop); 	/* get end of TPA */
	end_os_value = Supexec(end_os); 	/* get end of OS */
	exec_os_value = Supexec(exec_os);	/* get start of AES */
	logbase_value = Logbase();			/* get start of current drawing area */
	physbase_value = Physbase();		/* get start of current screen display */
	drivemap(); 						/* get bitmap of mounted drives */
	bootdev_value = Supexec(bootdev);	/* get boot drive */
	nflops_value = Supexec(nflops); 	/* get number of floppy drives */
	fverify_value = Supexec(fverify);	/* get disk verify status */
	seekrate_value = Supexec(seekrate); /* get seekrate of floppy drives */
	conterm_value = Supexec(conterm); 	/* get bell and keyclick status */
	keyboard(); 						/* get keyboard repeat rate and delay */
	date_time();						/* get and process system date/time */
}


void printout_1(void)					/* printout results page 1 */
{										/* print results to 'device' ie screen or printer */
	int i;

	fp = fopen(device, "w");			/* open file device for writing */	

	fprintf(fp, " ST DATA v2.0	by Linnhe Computing   Mark S Baines 1991\n\n");
	fprintf(fp, " ROM and Hardware details\n\n");
	fprintf(fp, " TOS Version:                %x.%x\n", rom_ver >> 8, rom_ver & 0xff);
	fprintf(fp, " ROM Date:                   %x %s %x%x\n", rom_date[1], month[rom_date[0]], rom_date[2], rom_date[3]);
	fprintf(fp, " GEMDOS Version:             %d.%d\n", dos_ver & 0xff, dos_ver >> 8);
	fprintf(fp, " AES Version:                %d.%x\n\n", aes_ver >> 8, aes_ver & 0xff);
	fprintf(fp, " ROM Nationality:            %s\n", country);
	fprintf(fp, " Monitor Attached:           %s\n", rez);
	fprintf(fp, " RAM Memory:                 %s\n", memory);
	if (blitter & 2)
		fprintf(fp, " Blitter Chip Present:       Yes\n\n");
	else
		fprintf(fp, " Blitter Chip Present:       No\n\n");
	fprintf(fp, " Drives Mounted:            ");
	for (i = 0; i <= strlen(drives); i++) 
		fprintf(fp, " %c", drives[i]);
	fprintf(fp, "\n");
	fprintf(fp, " Boot Drive:                 %c:\\\n", bootdev_value + 'A');
	fprintf(fp, " Number of Floppy Drives:    %d\n\n", nflops_value);
	fprintf(fp, " System Date and Time:       %s  %s\n", date_value, time_value);
	fclose(fp);
}
	

void printout_2(void)					/* printout results page 2 */
{										/* print results to 'device' ie screen or printer */

	fp = fopen(device, "w");			/* open file device for writing */	

	fprintf(fp, " System Variables and Configuration Details\n\n");
	fprintf(fp, " Base of OS:                 $%lX\n", sysbase_value);
	fprintf(fp, " End of OS:                  $%lX\n", end_os_value);
	fprintf(fp, " Start of TPA:               $%lX\n", membot_value);
	fprintf(fp, " End of TPA:                 $%lX\n", memtop_value);
	fprintf(fp, " End of RAM:                 $%lX\n", phystop_value);
	fprintf(fp, " Start of AES:               $%lX\n", exec_os_value);
	fprintf(fp, " Physbase:                   $%lX\n", physbase_value);
	fprintf(fp, " Logbase:                    $%lX\n\n", logbase_value);
	if (gdos == 0)		
		fprintf(fp, " GDOS Installed:             No\n\n");
	else
		fprintf(fp, " GDOS Installed:             Yes\n\n");
	if (fverify_value != 0)
		fprintf(fp, " Disk Verify Status:         On\n");
	else
		fprintf(fp, " Disk Verify Status:         Off\n"); 
	fprintf(fp, " Floppy Drive Seekrate:      %dms\n\n", seekrate_value);
	fprintf(fp, " Key Delay Rate:             %dms\n", key_delay);
	fprintf(fp, " Key Repeat Rate:            %dms\n", key_repeat);
	if ((conterm_value & 1) == 1)
		fprintf(fp, " Key Click Status:           On\n");
	else
		fprintf(fp, " Key Click Status:           Off\n");
	if ((conterm_value & 4) >> 2 == 1)
		fprintf(fp, " Alarm Bell Status:          On\n");
	else		
		fprintf(fp, " Alarm Bell Status:          Off\n");

	fclose(fp);
}


int print_control(void)					/* print the 2 pages to screen initially */
{
	char c;

	CLS;
	printout_1();
	printf("\a\n\n\n\n Press %sSPACE%s for next page", R_VID, N_VID);
	do { 
		} while (getch() != ' ');
	CLS;
	printout_2();
	printf("\a\n\n Press %sSPACE%s for previous page    ", R_VID, N_VID);
	printf(" Press %sP%s to send to Printer\n", R_VID, N_VID);
	printf("                      Press %sRETURN%s to exit", R_VID, N_VID);

	c = getch();						/* wait for key */
	if (c == 'p' || c == 'P')
	{
		device = "PRN:";				/* print to printer if user requires */
		printout_1();
		printout_2();
		return(0);						/* return to main() to exit */ 	
	}
	else if (c == ' ')					/* print page 1 to screen again */
	{
		CLS;
		print_control();
	}
	else return(0);						/* return to main() to exit */
		
}


void main(void) 						/* get and display results */
{
	appl_init();						/* Initialize application - for AES version number */
	graf_mouse(M_OFF, 0);				/* mouse cursor off */
	results();							/* get results */
	print_control();					/* print results */
	graf_mouse(M_ON, 0);				/* mouse cursor off */
	appl_exit();
	exit(EXIT_SUCCESS);					/* exit */
}
