/****************************************************************/
/* File name:	DISKID.C	Revised:	1990.12.28	*/
/* Creator:	U.R. Andersson	Created:	1990.12.28	*/
/* Copyright:	(c)1990 U.R. Andersson, all rights reserved.	*/
/*   but...	Rights for non-commercial uses released to PD.	*/
/****************************************************************/

/*
 * Program to display or alter media identification codes
 * Developed with Sozobon C
 */

#include	<stdio.h>
#include	<osbind.h>

WORD	buf[256];

main(argc, argv)
char	**argv;
{	unsigned	long	magic;
	int 	i, drive;
	if( argc != 3 )
	{	puts("diskid: needs two arguments");
		puts("  arg 1 = drive specifier ('a'..'p')");
		puts("  arg 2 = number => new id = number");
		puts("       or '*'  => new id = random");
		puts("       or '?'  => old id unaltered");
		goto bye;
	}
	drive = (*argv[1] & 0xDF) - 'A';
	if( drive < 0  ||  drive > 15 )
	{	puts("diskid: arg 1 = illegal drive spec");
		goto bye;
	}
	if( Floprd(buf, 0L, drive, 1, 0, 0, 1) )
	{	puts("diskid: Error reading boot sector!");
		goto bye;
	}
	magic = ((long) buf[4] << 16) | buf[5];
	printf("diskid: Old medium id = 0x%08.8lx\n", magic);
	if(*argv[2] == '?')
		goto bye;
	if(*argv[2] == '*')
		magic = Random() << 8;
	else
	{	i = sscanf(argv[2], "%li", &magic);
		if( i==0 )
		{	puts("diskid: arg 2 = erroneous medium id");
			goto bye;
		}
	}
	buf[4] = magic >> 16;
	buf[5] = magic;
	if( Flopwr(buf, 0L, drive, 1, 0, 0, 1) )
	{	puts("diskid: Error writing boot sector!");
		goto bye;
	}
	Mediach(drive);
	Getbpb(drive);
	if( Floprd(buf, 0L, drive, 1, 0, 0, 1) )
	{	puts("diskid: Error checking boot sector! ");
		goto bye;
	}
	magic = ((long) buf[4] << 16) | buf[5];
	printf("diskid: New medium id = 0x%08.8lx\n", magic);
bye:
	puts("diskid: Done.  Hit any key to continue.");
	Cnecin();
} /* ends main(argc,argv) */

/* End of:	DISKID.C	*/
