/* part.c */


/*
 * 24-Nov-88	jye. 	change and add codes so that can be used for MS-DOS
 */
#include "obdefs.h"
#include "gemdefs.h"
#include "osbind.h"
#include "mydefs.h"
#include "part.h"
#include "bsl.h"
#include "hdx.h"
#include "addr.h"


extern char sbuf[];
extern int npart;
extern int uplim;
extern long bslsiz;
extern long gbslsiz();
extern int noinfo;		/* 1: no information inside the wincap */


/*
 * Fill in partition entry with default information
 * and configuration values from the current "pr" wincap entry.
 *
 */
fillpart(n, part)
int n;
PART *part;
{
    long num;
    char *partid;
    char *idstr = "XX";
    char *wgetstr();

    idstr[1] = n + '0';

    /* see if `pX' is mentioned */
    *idstr = 'p';
    if (wgetnum(idstr, &num) == OK)
    {
	/* do the ST partition assignment */
		npart++;
		part->p_siz = (LONG)(num / 512);
	   	part->p_flg = P_EXISTS;
		if (part->p_siz < MB16)	{
    		part->p_id[0] = 'G';
    		part->p_id[1] = 'E';
    		part->p_id[2] = 'M';
		} else {
    		part->p_id[0] = 'B';
    		part->p_id[1] = 'G';
    		part->p_id[2] = 'M';
		}
    }
}


/* set the partition informations to the partition structures */

setpart(part, hsize)
PART *part;
long hsize;
{
    long onepart, remain;
	int i;

	npart = 4;
	onepart = hsize/4;
	remain = (hsize - onepart * 4) / 4;
	for ( i = 0; i < 4; i++, part++)	{
		if (i == 4)	{
			part->p_siz = hsize - (onepart + remain) * 3;
		} else {
			part->p_siz = onepart+remain;
		}
   		part->p_flg = P_EXISTS;
		if (part->p_siz < MB16)	{
   			part->p_id[0] = 'G';
   			part->p_id[1] = 'E';
   			part->p_id[2] = 'M';
		} else {
   			part->p_id[0] = 'B';
   			part->p_id[1] = 'G';
   			part->p_id[2] = 'M';
		}
	}
}



/*
 * Force checksum of sector image to a value
 */
forcesum(image, sum)
UWORD *image;
UWORD sum;
{
    register int i;
    register UWORD w;

    w = 0;
	/* up limit is half of buffer size - 2 */
    for (i = 0; i < ((UWORD)BPS/2 - 1); ++i)
	w += *image++;
    *image++ = sum - w;
}


/*
 * Put word in memory in 8086 byte-reversed format.
 *
 */
iw(wp, w)
UWORD *wp;
UWORD w;
{
    char *p;

    p = (char *)wp;
    p[0] = (w & 0xff);
    p[1] = ((w >> 8) & 0xff);
}

/*
 * Put long word in memory in 8086 word-reversed format.
 *
 */
ilong(lp, l)
long *lp;
long l;
{
    UWORD *p;

    p = (UWORD *)lp;
    iw(&p[0],(UWORD)(l & 0xffff));
    iw(&p[1],(UWORD)((l >> 16) & 0xffff));
}

/*
 * Get long word in memory, from 8086 word-reversed format.
 *
 */
glong(al, lp)   /* al is a swaped return long word,*/
				/* lp is a to be swaped long word */
long *al;
long *lp;

{
   char *p, *q;

    p = (char *)al;
    q = (char *)lp;
	p[0] = q[3];
	p[1] = q[2];
	p[2] = q[1];
	p[3] = q[0];
}

/*
 * Get word in memory, from 8086 byte-reversed format.
 *
 */
UWORD gw(wp, aw)
UWORD *wp;
UWORD *aw;
{
    char *p, *q;

    p = (char *)wp;
    q = (char *)aw;
    q[0] = p[1];
    q[1] = p[0];
    return *aw;
}
