/*****************************************************************************
**
** format.c - Generic format utility
**
** CREATED
** LTG
**
** MODIFICATIONS
** 19 Nov 85 SCC	Changed command tail parsing to not assume leading
**			space before drive letter.
**
** 20 Nov 85 SCC	Added imbedded version string containing date.
**
** 25 Mar 86 SCC	Increased stack size (by change in MINIS.S)
**
** 15 Jul 86 SCC	Added check for media change error return from the format call.
**
** NAMES
**
**	LTG	Lou T. Garavaglia
**	SCC	Steven C. Cavender
**
******************************************************************************
*/

#include <mini.h>
#include <gemerror.h>

#define FORMAT_DRIVE 1

#define GetBPB(a) bios(7,a)
#define RWAbs(a,b,c,d,e) bios(4,a,b,c,d,e)

char version[] = "GEM DOS generic FORMAT utility 1.2  7/15/1986 16:22";

#define BUFSIZ 10000
char buf[BUFSIZ];

#define BPB struct _bpb
BPB /* bios parameter block */
{
	int	recsiz;
	int	clsiz;
	int 	clsizb;
	int	rdlen;	/* root directory length in records */
	int	fsiz;	/* fat size in records */
	int	fatrec;	/* first fat record (of last fat) */
	int	datrec;	/* first data record */
	int	numcl;	/* number of data clusters available */
        int     b_flags;
} ;

/***************************************************************************/

main(p)
char *p;
{
	char  *d;
	int i, j, drv, rec, fs, f1, f2, nd;
	BPB *b;
	long err, sp;

	/* Get drive letter from command tail using base page pointer.*/

	if (p[0x80])
	{
		p += 0x81;
		while (*p == ' ')	/* scan past initial blanks */
			p++;
		drv = (*p >= 'a') && (*p <= 'z') ? *p -'a' : *p - 'A';
		if (drv & 0xFFF0)	/* out of range? */
			P_Term(1);
	}
	else
		P_Term(2);

	buf[0] = FORMAT_DRIVE;

	/* Format the disk.*/

	while ( (err = F_IOCtl(5, drv+1, 1, &buf)) == E_CHNG )
		;
	if ( err )
		P_Term( (int)err );

	/* Init the disk's FATS and root directory. */

	for (i=0; i < BUFSIZ; i++)
		buf[i] = 0;

	buf[0] = 0xF7;
	buf[1] = 0xFF;
	buf[2] = 0xFF;

	sp = S_State(0L);

	b = GetBPB(drv);

	if (b->b_flags & 1)
		buf[3] = 0xFF;

	f1 = b->fatrec - b->fsiz;
	f2 = b->fatrec;
	fs = b->fsiz;
	RWAbs(1,buf,fs,f1,drv);
	RWAbs(1,buf,fs,f2,drv);
	nd = b->recsiz / 32;
	d = buf;

	for (i = 0; i < nd; i++)
	{
		*d++ = 0;
		for (j = 0; j < 31; j++)
			*d++ = 0;
	}

	rec = f2 + fs;

	for (i = 0; i < b->rdlen; i++, rec++)
		RWAbs(1,buf,1,rec,drv);

	S_State(sp);
}
