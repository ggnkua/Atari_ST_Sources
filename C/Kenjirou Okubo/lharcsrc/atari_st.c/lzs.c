/*************************************************
		LHarc version 1.13b (c)Yoshi, 1988-89.

		adaption to ATARI ST with TURBO-C 1.1
		from LZS.ASM
		by J. Moeller 1990/01/28

HTAB = 4
*************************************************/

#ifndef __TOS__
#error Please try assembling 'lzs.asm'!
#endif

#include <stdio.h>

#define BUFFERSIZ	16*1024		/* also defined in 'LHARC.C' */
#define MAXBLK		64

unsigned char buf2 [BUFFERSIZ],	/* IO-Buffer */
			  buf3 [BUFFERSIZ];
unsigned crctbl [256];

#define RDERR		13
#define WTERR		14

#define setcrc(ch) (crc = (crc >> 8) ^ crctbl [(crc ^ (ch)) & 0xff])

extern unsigned char crcflg;
extern unsigned crc;
extern char *infname, *outfname;
extern unsigned blkcnt;				
extern unsigned char flg_n;

extern void error (int errcode, char *p);

void mkcrc (void)
{
  register unsigned i;

  for (i = 0; i<= 255; i++)
   {
     register unsigned j, x;

     x = i;
     for (j = 0; j <= 7; j++)
      {
        if (x & 1)
           x = (x >> 1) ^ 0xa001;
        else
           x >>= 1;
      }
     crctbl [i] = x;
   }
}

/*****************************
	Copy <size> Bytes
	from <Source> to <Dest>
*****************************/

void copyfile (FILE *Source,
               FILE *Dest,
               long size)
{
	register int ch;

	if (size == 0L)
		return;

	if (crcflg)
	{
		int printcount;

		printcount = 4096;
		if (printcount > size)
			printcount = (unsigned) size;
		if (blkcnt > MAXBLK)
			blkcnt = MAXBLK;
		crc = 0;
		while (size-- > 0 && (ch = getc (Source)) != EOF) {
			setcrc (ch);
			if (Dest != NULL) putc (ch, Dest);
			if (!flg_n)
				if (--printcount == 0) {
					if (blkcnt > 0) {
						putc ('o', stderr);
						blkcnt--;
					}
					printcount = 4096;
					if (printcount > size)
						printcount = (unsigned) size;
				}
		}
	} else {
		while (size-- > 0 && (ch = getc (Source)) != EOF)
			if (Dest != NULL)
				putc (ch, Dest);
	}
	if (ferror (Source))
		error (RDERR, infname);
	if (Dest != NULL && ferror (Dest))
		error (WTERR, outfname);
}
