/*

   AUTODISK - program to copy floppy disk to RAM disk upon system
                boot, and also set the system clock.
   By Moshe Braner  <braner@amvax.tn.cornell.edu>          861223

FUNCTION
   This program is to be placed in the \AUTO folder on the boot disk,
   AFTER the RAMdisk program.  (It assumes the reset-immune RAM disk is
   already installed.)  After asking the user for the current time and
   date, and setting the ST's two clocks accordingly, this program copies
   the whole floppy disk data, FATs, directory and all, onto the RAMdisk.
   (It first finds out which sector is the last one actually holding data,
   and copies all sectors up to that one.)

HINTS
   For best results:  Freshly format a disk, make an AUTO directory,
   put in it first RAMDISK.PRG and then AUTODISK.PRG, then put on the
   disk all other files you want to load to the RAMdisk at boot time,
   but no others.  You can set these files up in folders if you want:
   first make the folders, then put the files on the disk directly into
   the folders.  For maximum speed do not make any deletions of files,
   nor copy files from the disk to itself.
   You may save the desktop (with the RAMdisk icon installed, and perhaps
   the RAMdisk's window open) on the disk, too.  Make sure the RAMdisk
   is more than big enough to hold all those files.

ACKNOWLEDGEMENTS
   This program made possible in part by Eric Terrell, who posted
   "eternal.s".  The method of setting the ST's clocks is borrowed
   from "settime", posted by Allan Pratt of Atari.

WARNINGS
   This program is for booting off a floppy disk.  For hard disks (or
   future, very large, floppies) the program (and/or the RAMdisk program)
   needs some tweaking, at least at the points marked ">>>>".
   This program will not work with "copy protected" disk formats,
   including the "FAST" format with its "dead" sectors.
*/

#include <osbind.h>

#define SECSIZE	512	/* >>>> for now 512-byte sectors only */

#define WORD	int	/* 16 bits: 'int' in Megamax */

#define OK	0
#define READ	0

/* read unsigned bytes and Intel-style integers */
#define US(p,o)	(p[o]&0xFF)
#define UI(p,o)	(US(p,o)+256*US(p,o+1))

#define fixup(s) (s[s[1]+2] = '\0')	/* null-terminate a GEMDOS string */

int
strlen(s)
	char *s;
{
	register int i=0;
	while (s[i++]);
	return (i-1);
}

error(msg)
	char msg[];
{
	Cconws(msg);
	Cconws("\r\n\n\tHit any key ");
	Cconin();
	exit(0);
}

int
dotime(s)
	register char *s;
{
	register int len;
	register int hour, minute, second;

	len = strlen(s);
	if (len < 4 || len == 5 || len > 6) goto badtime;

	hour = (s[0]-'0') * 10 + (s[1]-'0');
	minute = (s[2]-'0') * 10 + (s[3]-'0');
	if (len == 6) second = (s[4]-'0') * 10 + (s[5]-'0');
	else second = 0;

	if (hour < 0 || hour > 23 ||
	    minute < 0 || minute > 59 ||
	    second < 0 || second > 59) goto badtime;

	if (Tsettime((hour << 11) + (minute << 5) + (second >> 1))==0)
	    return (0);

badtime:
	Cconws("\r\nIllegal time (bad format or out of range)\r\n");
	return (1);
}

int
dodate(s)
	register char *s;
{
	register int len;
	register int month,day,year;

	len = strlen(s);
	if (len != 6) goto baddate;

	year =  (s[0]-'0') * 10 + (s[1]-'0') - 80;
	month = (s[2]-'0') * 10 + (s[3]-'0');
	day =   (s[4]-'0') * 10 + (s[5]-'0');

	if (year < 0 || year > 119 || 
	    month < 1 || month > 12 || 
	    day < 1 || day > 31) goto baddate;

	if (Tsetdate((year << 9) + (month << 5) + day)==0) return (0);

baddate:
	Cconws("\r\nIllegal date (bad format or out of range)\r\n");
	return (1);
}

main()
{
	register int i, res, secs;
	register char *buf;
	int	bps, spc, fats, dir, spd, spf, spt, drive, sides;
	WORD	date, time;
	WORD	*bpb;
	char	boot[SECSIZE], str[10];
	long	stack, datime;
	char	*msg = "\nError reading disk!";

	Cconws("\033E\r\n\n\tAUTODISK\tby Moshe Braner\r\n\n");

	/* see if IKBD time is valid */
	datime = Gettime();		/* get ikbd date & time */
	date = datime >> 16;
	time = datime & 0xffff;

	if (((date & 0x1f) != 0) &&
	    (((date >> 5) & 0x0f) != 0))
		if (Tsetdate(date)==0 && Tsettime(time)==0)
			goto timedone;

	/* we want to prompt the user	*/

	str[0] = 7;	/* set up buffer for Cconrs call */
	do {
		Cconws("\r\n\tEnter the time (hhmm[ss]): ");
		Cconrs(str);
		fixup(str);
	} while (dotime(str+2));

	do {
		Cconws("\r\n\tEnter the date (yymmdd): ");
		Cconrs(str);
		fixup(str);
	} while (dodate(str+2));

	datime = ((long)Tgetdate() << 16) + Tgettime();	/* get GEM's time */
	Settime(datime);			/* update the ikbd's time */
	Cconws("\r\n");

timedone:

	drive = Dgetdrv();		/* use current drive		*/

	/* get disk parameters from boot sector */

	if (Rwabs (READ, boot, 1, 0, drive) != OK)
		error("\nError reading boot sector!");
	bps = UI(boot, 11);		/* bytes per sector		*/
	spc = US(boot, 13);		/* sectors per cluster		*/
	res = UI(boot, 14);		/* no. of reserved sec		*/
	fats = US(boot, 16);		/* no. of FATs			*/
	dir = UI(boot, 17);		/* no. of dir entries		*/
	spd = UI(boot, 19);		/* sectors per disk		*/
	spf = UI(boot, 22);		/* sectors per FAT		*/
	spt = UI(boot, 24);		/* sectors per track		*/
	sides = UI(boot, 26);		/* sides of disk		*/
	secs = 32 * dir;		/* >>>> 32-byte dir entries	*/
	secs /= bps;			/* length of dir in sectors	*/

	/* find start address of RAM disk */

	stack = Super(0L);		/* get into supervisor mode	*/
	buf = *((char **) 0x42E);	/* physical top of memory	*/
	Super(stack);			/* back to user mode		*/

	/* adjust RAMdisk BPB */

	bpb = (WORD *) buf;		/* RAMdisk BPB area		*/
	if (bpb[0] != bps)
		error("\nDisk and RAMdisk incompatible!");	/* >>>>	*/
	if (bpb[255] == 0x4144)		/* our own magic number		*/
		error("\n\tOld RAM disk!");
	bpb[255] = 0x4144;		/*    "AD"			*/
	bpb[1] = spc;
	bpb[2] = bps*spc;
	bpb[3] = secs;
	bpb[4] = spf;
	bpb[5] = spf + res;
	bpb[6] = 2*spf + bpb[3] + res;	/* >>>> assumes 2 FATs		*/

	/* copy the data from floppy to RAM */

	Cconws("\n\tCopying data...\r\n");

	buf += 512;			/* start of RAMdisk data area	*/
	buf += bps*res;			/* start of FAT area		*/
	secs += fats*spf;		/* read FATs + dir		*/
	if (Rwabs (READ, buf, secs, res, drive) != OK)
		error(msg);
	res += secs;			/* no. of sectors already read	*/
	i = 3*(spd-res);		/* >>>> 12-bit FAT entries	*/
	i = 3 + i/spc/2;
	while (buf[--i] == 0);		/* search for last used sector	*/
	buf += bps*secs;		/* next place to put stuff	*/
	i *= spc*2;
	secs = i/3;			/* no. of sectors left to read	*/
	if (secs > spd-res)		/* safety check			*/
		secs = spd-res;
	if (Rwabs (READ, buf, secs, res, drive) != OK)
		error(msg);

	Cconws("\n\tAUTODISK finished, no errors\r\n");
	for (datime=0; datime<50000; datime++);
}
