/*
 *	BLANK
 *
 *	A program to blank out a floppy disk.
 *	The disk must have been formatted before.
 *	Much faster than reformatting or even
 *	deleting all that's on the disk by files.
 *
 *	For the Atari ST.
 *
 *	By Moshe Braner, 880406
 */

#include <osbind.h>
#undef  Getbpb
#define Getbpb(a)	bios(7, a)

#define WORD int	/* 16 bits, 'int' in Laser C */

#define OK	0

#define READ	0
#define WRITE	1

typedef struct bpb {
	WORD	recsiz;
	WORD	clsiz;
	WORD	clsizb;
	WORD	rdlen;
	WORD	fsiz;
	WORD	fatrec;
	WORD	datrec;
	WORD	numcl;
	WORD	bflags;
} BPB;

char buf[7*512];

/*
 * Print message and quit.
 */
error(msg)
	char msg[];
{
	Cconws(msg);
	Cconws("\007\r\n\n\tHit any key ");
	Bconin(2);
	exit(0);
}

main()
{
	int	i, bps, spc, fats, dir, spd, spf, dat, sec, secs, drv;
	BPB	*bpb;

	char	*msg1 = "\r\n\tError reading!";
	char	*msg2 = "\r\n\tError writing!";

	Cconws("\033E\r\n\n\tBLANK 1.0\tby Moshe Braner");

loop:	Cconws("\r\n\n\tEnter letter label of drive to blank: ");
	drv = Bconin(2);
	if (drv == 0x1B)
		exit(0);
	if (drv>='a' && drv<='p')
		drv += 'A'-'a';
	Bconout(2, drv);
	if (drv < 'A' || drv > 'P')
		goto loop;
	drv -= 'A';		/* 0=A, 1=B, ... */

	/* get disk parameters from bios parameter block */

	Cconws("\r\n\tInsert disk to blank, hit any key: ");
	i = Bconin(2);
	if (i == 0x1B)
		exit(0);
	bpb = (BPB *) Getbpb(drv);
	if (bpb==0)
		error(msg1);
	dir = bpb->rdlen;		/* length of dir in sectors	*/
	spf = bpb->fsiz;		/* sectors per FAT		*/
	dat = bpb->datrec;		/* no. of first data sector	*/

	/* read FAT from disk to RAM */

	sec = dat - dir - 2*spf;
	if (Rwabs (READ, buf, spf, sec, drv) != OK)
		error(msg1);

	/* zero out everything beyond the first 3 bytes */

	for (i=3; i<7*512; i++)
		buf[i] = 0;

	/* write it back, to both FATs */

	Cconws("\007\r\n\n\t\tWARNING:");
	Cconws("\r\n\tAbout to erase ALL data in drive ");
	Bconout(2,drv+'A');
	Cconws(".\r\n\n\t\tProceed (y/n)? ");
	i = Bconin(2);
	if (i!='y' && i!='Y')
		exit(0);

	if (Rwabs (WRITE, buf, spf, sec, drv) != OK)
		error(msg2);
	sec += spf;
	if (Rwabs (WRITE, buf, spf, sec, drv) != OK)
		error(msg2);

	/* zero out root directory */

	buf[0] = buf[1] = buf[2] = 0;
	sec = dat - dir;
	if (Rwabs (WRITE, buf, dir, sec, drv) != OK)
		error(msg2);

	error(".\r\n\n\tBLANK finished, no errors.");
}

