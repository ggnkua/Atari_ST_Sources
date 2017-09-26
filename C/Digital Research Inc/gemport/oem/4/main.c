#define automem 0	/* =0 automem is hardcoded; =1 do automem discovery */
			/* also must set cond assem in biosa.s		*/
/* ccp, startup code for file system -JSL */
#include "fs.h"
#include "disk.h"

extern long oscall();
#define xexec(a,b,c,d) oscall(0x4b,a,b,c,d)

/* defines for GETMPB call */
		/* defines for automemory sizing which is rel to getmpb call */
#if automem
char *ptr = {65535};		/* memory pointer init = 64K -1 */
extern	int  qt;		/* boolean for autom () automemory sizing */
extern long  lastref;		/* last valid address referenced */
#endif
extern long lowtpa;		/* defined in biosa.s; varies whether under   */
				/* cp/m-68k or not			      */
extern long lentpa;		/* now this is established in biosa.s; if not */
				/* determined by automemory sizing then will  */
				/* equal the old value of 0x60000	      */

extern char env[];
long mdx[4];

char secbuf[4][512]; 		/* sector buffers */
BCB bcbx[4]; 			/* bcb for each buffer */

/* two buffer lists, fat,dir/data */
BCB *bufl[2];

/* drive C is profile, A and B are 5 1/4 twiggys */
/* ... the way God intended disks to be */

BPB bpbx[] = {  {  512, 2, 1024,  5,  3,  4, 12,  390, 0 },
		{  512, 2, 1024,  5,  3,  4, 12,  390, 0 },
 		{  512, 2, 1024, 32, 12, 13, 57, 4000, 2 } ,	/* fixed */
 		{  512, 2, 1024, 32, 12, 13, 57, 4000, 2 } } ;	/* fixed */

/*
 *                      recsiz       rootrecs    datrec#    flags(16-bit fat)
 *                          clsiz       fatrecs      numclust	 (fixed disk)
 *                              clsizb       fatrec#        
 * Atari ROM Disk
 *	BPB bpbx[1] = {  512, 2, 1024,  2,  1,  1,  4,  254,   0 } ;
 * IBM 5 1/4 DSDD
 *	BPB bpbx[1] = {  512, 2, 1024,  7,  2,  3, 12,  350,   0 } ;
 * Lisa profile for GEMDOS demo	  old:     12  13  57  4000    0
 *	BPB bpbx[1] = {  512, 2, 1024, 32, 20, 21, 74, 5000,   1 } ;
 * Lisa twiggys
 *	BPB bpbx[1] = {  512, 2, 1024, 15,  3,  4, 22,  840,   0 } ;
 * Lisa sony drive (SS)
 *	BPB bpbx[1] = {  512, 2, 1024,  5,  3,  4, 12,  390,   0 } ;
 * Compaq hard disk C:
 *	BPB bpbx[1] = {  512, 8, 4096, 32,  7,  8, 47, 2119,   0 } ;
 * 8 inch SSSD				       *7,*13 on some disks 
 *	BPB bpbx[1] = {  128, 4,  512, 17,  6, 10, 16,  492,   0 } ;
 * 8 inch DSDD
 *	BPB bpbx[1] = { 1024, 1, 1024, 6,   2,  3,  5, 1221,   0 } ;
 */

cmain()
{
	/* set up sector buffers */
	bcbx[0].b_link = &bcbx[1];
	bcbx[2].b_link = &bcbx[3];
	bcbx[0].b_bufdrv = -1;
	bcbx[1].b_bufdrv = -1;
	bcbx[2].b_bufdrv = -1;
	bcbx[3].b_bufdrv = -1;
	bcbx[0].b_bufr = &secbuf[0][0];
	bcbx[1].b_bufr = &secbuf[1][0];
	bcbx[2].b_bufr = &secbuf[2][0];
	bcbx[3].b_bufr = &secbuf[3][0];
	bufl[0] = &bcbx[0]; 			/* fat buffers */
	bufl[1] = &bcbx[2]; 			/* dir/data buffers */
	osinit();

#if floppy
	xsetdrv(0);                     /* 0 if GEMDOSFI.SYS, 2 if GEMDOSHI.SYS */
#else
        xsetdrv(2);
#endif
	xexec(0,"COMMAND.PRG","",env);
}

bgetmpb(m)		/* trap13, function 0 */
long **m;
{
	m[0] = m[2] = &mdx;
	m[1] = 0;
	mdx[0] = mdx[3] = 0;
	mdx[1] = lowtpa;
	mdx[2] = lentpa;
}

#if automem
autom ()		/* automemory sizing; contin from biosa.s */
{
	char  temp;

	quit = 0;
	while (! quit)		/* continue until get bus error */
	{
	    temp = ptr;		/* cause bus error if ptr not pt to valid @ */
	    lastref = (long) ptr;	/* preserve the current valid @ val */
	    ptr += 16384;		/* increase by 16K */
	}
}
#endif


BPB *bgetbpb(d)		/* trap13, function 7 */
int d;
{
	return(&bpbx[d]);
}

long timetck ()		/* trap13, fnct 6; ret # of miliseconds per tick */
{
	return (13L);	/* see sony.s on ln 139: 13 ms between traces */
}

