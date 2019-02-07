/*
 * Disk tester.
 *
 * reads all the sectors on a disk and reports if they are good or bad.
 *
 * version 1.0  03/15/88
 * by Dan Moore and Dave Small
 * Copyright 1988 Antic Publishing Inc.
 *
 */
 
#include <osbind.h>
#include <stdio.h>

	/* variables	  */
char	io_buff[5120];		/* ten sectors			*/
int	sectors;		/* sectors per track		*/
int	dblsided;		/* one or two			*/
int	drive;			/* A or B			*/
char	good_bad[10];		/* allow for 10 sector disks    */

	/* system defines */
#define MAPTOP		(11)	/* top line of sector map	*/
#define LEGTOP		(MAPTOP + 10)	/* top of sector map legend */
#define LEGCOL		(60)	/* left edge of legend		*/
#define SIDECOL		(15)	/* column to print side for map */
#define SECTCOL		(55)	/* column for sector/sides info */
#define MSGTOP		(24)	/* bottom line of screen for messages */

#define GOOD		(1)
#define BAD		(0)

#define ESC		(0x1b)

/*
 * redefine getchar for single character input using BIOS
 * redefine putchar for single character output using BIOS
 */
#ifdef getchar
# undef getchar
#endif
#define getchar() ((int)(Bconin(2) & 0xff))

#ifdef putchar
# undef putchar
#endif
#define putchar(c) (Bconout((2), (c)))

/*
 * misc. screen handling routines
 */
void
clrscr()	/* nuke the screen */
{
	putchar(ESC);
	putchar('E');	/* clear home command */
}

void
clreol()	/* nuke the line */
{
	putchar(ESC);
	putchar('K');	/* clear to eol command */
}

void
movcur(r, c)
int r,c;
{
	putchar(ESC);
	putchar('Y');
	putchar(32 + r);
	putchar(32 + c);
}

void
curoff()
{
	putchar(ESC);
	putchar('f');
}

void
curon()
{
	putchar(ESC);
	putchar('e');
}

/*
 * disk map routines
 */
void
printsector(track, sector, c)
int track, sector;
char c;
{
	movcur(MAPTOP + sector, track);
	putchar(c);
}

void
trackprinter(start, end, sectors)
int start, end, sectors;
{
	int track, sector;

	for (track = start; track <= end; track++)
		for (sector = 0; sector < sectors; sector++)
			printsector(track, sector, 'X');
}

void
showmap()
{
	/*
	 * draws a map of the sectors on the mac disk.  Tracks are columns
	 * sectors are rows.
	 */
	register int i, j;

	curoff();

	movcur(MAPTOP-3, 37);
	printf("\033pTRACK");	/* reverse on here */
	movcur(MAPTOP-2, 0);
	for (i = 0; i < 8; i++)		/* upper number line (tens) */
		for (j = 0; j < 10; j++)
			putchar(i + '0');
	movcur(MAPTOP-1, 0);		/* actually one line up from map */
	for (i = 0; i < 8; i++)		/* lower number line (ones) */
		for (j = 0; j < 10; j++)
			putchar(j + '0');
	printf("\033q");	/* reverse off here */

	/* print the empty map */
	trackprinter( 0, 79, sectors);

	printf("\033p");	/* reverse on */
	movcur(LEGTOP, LEGCOL);
	if (dblsided) {
		printf("+ = both sides good");
		movcur(LEGTOP + 1, LEGCOL);
		printf("- = both sides bad ");
		movcur(LEGTOP + 2, LEGCOL);
		printf("1 = side one bad   ");
		movcur(LEGTOP + 3, LEGCOL);
		printf("2 = side two bad   ");
	}
	else {	/* one line lower than double sided legend */
		printf("+ = good sector");
		movcur(LEGTOP + 1, LEGCOL);
		printf("- = bad sector ");
	}
	printf("\033q");	/* reverse off */
}

void
verifytracks()
{
	/*
	 * read all sectors (9 or 10) from the track.
	 */
	register int  track, sector;
	register char which;

	for (track = 0; track <= 79; track++) {
		if (dblsided) {	/* which side now? */
			movcur(MAPTOP-3, SIDECOL);
			printf("\033pSIDE 1\033q");
		}
		/* buffer, filler, drive, sector, track, side, count */
		if (Floprd(io_buff, 0L, drive, 1, track, 0, sectors) != 0) {
			for (sector = 0; sector < sectors; sector++) {
				if (Floprd(io_buff, 0L, drive, sector + 1, track, 0, 1) != 0) {
					if (dblsided)
						which = '1';
					else 
						which = '-';
					good_bad[sector] = BAD;
				}
				else {
					which = '+';
					good_bad[sector] = GOOD;
				}
				printsector(track, sector, which);
			}
		}
		else { /* all good */
			for (sector = 0; sector < sectors; sector++) {
				good_bad[sector] = GOOD;
				printsector(track, sector, '+');
			}
		}

		if (dblsided) {
			if (dblsided) {	/* which side now? */
				movcur(MAPTOP-3, SIDECOL);
				printf("\033pSIDE 2\033q");
			}
			/* buffer, filler, drive, sector, track, side, count */
			if (Floprd(io_buff, 0L, drive, 1, track, 1, sectors) != 0) {
				for (sector = 0; sector < sectors; sector++) {
					if (Floprd(io_buff, 0L, drive, sector + 1, track, 0, 1) != 0) {
						if (good_bad[sector] == GOOD)
							which = '2';
						else 
							which = '-';
					}
					else 
						if (good_bad[sector] == GOOD)
							which = '+';
						else
							which = '1';
					printsector(track, sector, which);
				}
			}
			else { /* all good */
				for (sector = 0; sector < sectors; sector++) {
					if (good_bad[sector] == GOOD)
						printsector(track, sector, '+');
					else	/* side one was bad */
						printsector(track, sector, '1');
				}
			}
		}
	}
}

/*
 * the main body
 */
void
main()
{
	register int c;

	setbuf(stdout, 0L);	/* unbuffered i/o */
	setbuf(stdin, 0L);

	for(;;) {
		clrscr();
		curoff();

		printf("\n\t\t\t\    \033pThe Amazing Disk Certifier\033q\n");
		printf("\t\t\t            version 1.0\n");
		printf("\t\t\t    by Dan Moore and Dave Small\n");
		printf("\t\t\tCopyright 1988 Antic Publishing Inc.\n");
		/*
		 * find out which drive to test
		 */
		do {
			movcur(10, 16);
			printf(" \033pA\033q  -- test drive A");
			movcur(11, 16);
			printf(" \033pB\033q  -- test drive B");
			movcur(12, 16);
			printf(" \033pQ\033q  -- Quit");

			c = getchar() | 0x20;

			if (c == 'q') {
				clrscr();
				exit();		/* you can go home now */
			}
		}
		while (!((c == 'a') || (c == 'b')));

		/* what did they choose */
		drive = (c == 'b');

		/* nuke the old prompts now */
		movcur(10, 16);
		printf("                   ");
		movcur(11, 16);
		printf("                   ");
		movcur(12, 16);
		printf("           ");

		/*
		 * single or double sided
		 */
		do {
			movcur(10, 0);
			printf("Is drive %c single or double sided (S or D)? ", drive + 'A');
			clreol();
			c = getchar() | 0x20;	/* forced lower case */
		}
		while (!((c == 's') || (c == 'd')));

		/* erase the prompt */
		movcur(10, 0);
		printf("                                           ");

		/* which was it? */
		dblsided = (c == 'd');

		/* try reading sector 10 on track zero to see if this
		 * is a 9 or 10 sector disk.  Lets do this instead of
		 * reading the sectors/track entry in the boot block.
		 * this will allow us to work with non-GEM disks.
		 */
		if (Floprd(io_buff, 0L, drive, 10, 0, 0, 1) != 0)
			sectors = 9;
		else
			sectors = 10;

		/* go do it now */
		showmap();

		/* tell how many sectors are being tested */
		movcur(MAPTOP-3, SECTCOL);
		printf("\033p%d SECTORS %d SIDED\033q", sectors, dblsided + 1);

		verifytracks();

		movcur(MSGTOP, 0);
		printf("\033pTest completed.  Press RETURN to continue\033q");
		while (getchar() != '\r');
	}
}
