/* Test to exercise the TAPEBIOS.TOS program 		*/
/* This program is part of the TapeBIOS distribution	*/
/* Adapted by Alan Hourihane, from code by P. Moreau	*/
/* Needs TapeBIOS driver loaded				*/

#include<stdio.h>
#include<osbind.h>
#include"tapebind.h"

extern long get_cookie();
extern void exit();
extern int Mode_Sense();
extern int RSense();
extern void bclear();

#define BBLKS 254L
#define BBLKW 254
#define HBLKS 127L
#define HBLKW 127
#define BSIZE BBLKS*512L
#define HSIZE HBLKS*512L

/* 3.5 megs for disc/tape io test */
#define IOTS BBLKW * 30

int
main()
{
	int i, blk, stat;
	long x; 				/* Long index and GP */
	char *buffer;
	char *ptr;

	printf("Tape Test Program for TapeBIOS. Copyright 1992, A. Hourihane.\r\n");

	if (!get_cookie("TAPE")) {
		printf("TapeBIOS is not installed.\r\n");
		exit(1);
	}

	buffer = (char*)Malloc(BSIZE);
	if(!buffer)
	{
	    printf("Malloc error allocating %ld byte buffer\r\n", BSIZE);
	    exit(1);
	}

	printf("Test Unit Ready\r\n");
	stat = Tready();
	if(stat)
	{
	   printf("\tTape drive is Not ready\r\n");
	   goto bye;
	}

	printf("Load Tape\r\n");
	stat = Tload(0L);			/* Load tape NO RETENSION */
	if (stat) goto bye;

	printf("Mode Sense\r\n");
	stat = Mode_Sense();			/* Mode Sense */

	printf("Creating data buffer patterns\r\n");
	for(ptr = buffer, x = 0L; x < BSIZE; x++) *ptr++ = (char)(x);
	
	printf("Write Tape\r\n");
	stat = Twrite(buffer, BBLKS);		/* Write 64 512 byte blocks */
	if(stat) goto bye;
	
	printf("Write Filemark\r\n");
	stat = Tfmark(2L);			/* Write 2 filemarks */
	if(stat) goto bye;
	
	printf("Rewind Tape\r\n");
	stat = Trewind();			/* Rewind tape */
	if(stat) goto bye;
	
	printf("Clearing data buffer\r\n");
	bclear(buffer, BSIZE);
	
	printf("Read Tape\r\n");
	stat = Tread(buffer, BBLKS);		/* Read 64 512 byte blocks */
	if(stat) goto bye;
	
	printf("Rewind Tape\r\n");
	stat = Trewind();			/* Rewind Tape */
	if(stat) goto bye;
	
	printf("Checking data buffer\r\n");
	for(ptr = buffer, x = 0L; x < BSIZE; x++, ptr++)
	{
	    if(*ptr != (char)(x))
		printf("\r\nData error offset %lx, was %02x, sb %02x",
		    x, (unsigned int)(*ptr), (int)(x));
	}
	
	printf("Disk - Tape I/O test\r\n");

	for(blk = 0; blk < IOTS; blk += BBLKW)
	{
	    i = Rwabs(0, buffer, BBLKW, blk, 2);	/* Read Hard Disk */
	    if(i)
	    {
		printf("\r\n\tDisk IO error 0x%02x reading block %d\r\n", i, blk);
		goto bye;
	    }
	    stat = Twrite(buffer, BBLKS);	/* Write 1 Tape block */
	    if(stat)
	    {
		printf("\r\n\tTape IO error 0x%02x writing block %d\r\n", stat, blk);
		if(stat == 2)			/* Check Condition ? */
		{
		    printf("\tCheck Condition\r\n");
		    stat = RSense();	/* Request Sense if Check */
		}
	    }
	    printf("Blocks transfered %d\r\n\033A", blk);
	}
	
	printf("\r\nWrite Filemark\r\n");
	stat = Tfmark(2L);			/* Write 2 file marks */
	if(stat) goto bye;
	
	printf("Rewind Tape\r\n");
	stat = Trewind();			/* Rewind Tape */
	if(stat) goto bye;
	
	/*  Read data from disc and tape and compare data */
	
	for(blk = 0; blk < IOTS; blk += HBLKW)
	{
	    i = Rwabs(0, buffer, HBLKW, blk, 2);	/* Read Hard Disk */
	    if(i)
	    {
		printf("\r\n\tDisk IO error 0x%02x reading block %d\r\n", i, blk);
		goto bye;
	    }
	    stat = Tread(&buffer[HSIZE], HBLKS);	/* Write Tape drive */
	    if(stat)
	    {
		printf("\r\n\tTape IO error 0x%02x reading block %d\r\n", stat, blk);
		if(stat == 2)			/* Check Condition ? */
		{
		    printf("\tCheck Condition\r\n");
		    stat = RSense();	/* Request Sense if Check */
		}
	    }
	    
	    for(x = 0L; x < HSIZE; x++)
	    {
	       if(buffer[x] != buffer[x+HSIZE])
	       {
		   printf("\r\n\033pData Error!\033q\7\r\n");
		   x = HSIZE+1L;
	       }
	    }
	    printf("Blocks verified %d\r\n\033A", blk);
	} 
	printf("\r\nTest Completed.\r\n");
bye:
	if (stat == 0x02)			/* Check Condition */
	{
	    printf("\tCheck Condition\n");
	    stat = RSense();
	}
	else if(stat) 
	{
	    printf("\tExit with Error - Tape status = %02x\r\n");
	    printf("\tCheck Programmers manual.\r\n");
	}
	
	printf("Unload Tape\r\n");
	stat = Tunload(0L);			/* Unload tape NO RETENSION */

	printf("Hit [RETURN] when ready ... ");
	i = getc(stdin);	

	return 0;
}

int RSense()
{
    int stat, i;
    char sense[512];
    
    bclear(&sense[0], 32L);
    stat = Trsense(&sense[0], 64L);
    printf("\tSense Data: ");
    for(i = 0; i < 11; i++) printf(" %02x", (int)(sense[i]) & 0xFF);
    printf("\r\n");
    return(stat);
}

int Mode_Sense()
{
	int stat;
	long x;
	char buffer[512];

	bclear(&buffer[0], 13L);
	stat = Tmsense(&buffer[0], 255L);	/* Display Mode Sense */
	if(stat) return(stat);
	printf("    Media Type		 : %02x\r\n", (int)(buffer[1]) & 0xFF);
	printf("    Write Protect	 : %s\r\n", (buffer[2] & 0x80) ? "On" : "Off");
	printf("    Buffered Mode	 : %s\r\n", (buffer[2] & 0x10) ? "On" : "Off");
	printf("    Speed		 : %d\r\n", (int)(buffer[2] & 3));
	printf("    Density Code	 : %02x\r\n", (int)(buffer[4]));
	x = ((long)(buffer[5]) & 0xff) << 16;
	x |= ((long)(buffer[6]) & 0xff) << 8;
	x |= ((long)(buffer[7]) & 0xff);
	printf("    Number of Blocks	 : %ld\r\n", x);
	x = ((buffer[9] & 0xff) << 16);
	x |= ((buffer[10] & 0xff) << 8);
	x |= ((buffer[11]) & 0xff);
	printf("    Block Size		 : %ld\r\n", x);
	printf("    Disable Erase Ahead  : %s\r\n", (buffer[12] & 4) ? "On" : "Off");
	printf("    Auto Inhibit	 : %s\r\n", (buffer[12] & 2) ? "On" : "Off");
	printf("    Soft Error Count	 : %s\r\n", (buffer[12] & 1) ? "Supressed" : "Enabled");
	return(stat);
}

void
bclear(p, cnt)
char *p;
long cnt;
{
    long x;

    for(x = 0L; x < cnt; x++)
	*p++ = 0;
}

