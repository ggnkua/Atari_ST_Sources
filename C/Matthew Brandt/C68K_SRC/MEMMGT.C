#include        <stdio.h>
#include        "c.h"
#include        "expr.h"
#include        "gen.h"
#include        "cglbdec.h"

/*
 *	68000 C compiler
 *
 *	Copyright 1984, 1985, 1986 Matthew Brandt.
 *  all commercial rights reserved.
 *
 *	This compiler is intended as an instructive tool for personal use. Any
 *	use for profit without the written consent of the author is prohibited.
 *
 *	This compiler may be distributed freely for non-commercial use as long
 *	as this notice stays intact. Please forward any enhancements or question
s
 *	to:
 *
 *		Matthew Brandt
 *		Box 920337
 *		Norcross, Ga 30092
 */

struct blk {
        struct blk      *next;
        char            m[1];           /* memory area */
        };

static int      glbsize = 0,    /* size left in current global block */
                locsize = 0,    /* size left in current local block */
                glbindx = 0,    /* global index */
                locindx = 0;    /* local index */

static struct blk       *locblk = 0,    /* pointer to local block */
                        *glbblk = 0;    /* pointer to global block */

char    *xalloc(siz)
int     siz;
{       struct blk      *bp;
        char            *rv;
	if( siz & 1 )		/* if odd size */
		siz += 1;	/* make it even */
        if( global_flag ) {
                if( glbsize >= siz ) {
                        rv = &(glbblk->m[glbindx]);
                        glbsize -= siz;
                        glbindx += siz;
                        return rv;
                        }
                else    {
                        bp = calloc(1,sizeof(struct blk) + 2047);
			if( bp == NULL )
			{
				printf(" not enough memory.\n");
				exit(1);
			}
                        bp->next = glbblk;
                        glbblk = bp;
                        glbsize = 2048 - siz;
                        glbindx = siz;
                        return glbblk->m;
                        }
                }
        else    {
                if( locsize >= siz ) {
                        rv = &(locblk->m[locindx]);
                        locsize -= siz;
                        locindx += siz;
                        return rv;
                        }
                else    {
                        bp = calloc(1,sizeof(struct blk) + 2047);
			if( bp == NULL )
			{
				printf(" not enough local memory.\n");
				exit(1);
			}
                        bp->next = locblk;
                        locblk = bp;
                        locsize = 2048 - siz;
                        locindx = siz;
                        return locblk->m;
                        }
                }
}

release_local()
{       struct blk      *bp1, *bp2;
        int             blkcnt;
        blkcnt = 0;
        bp1 = locblk;
        while( bp1 != 0 ) {
                bp2 = bp1->next;
                free( bp1 );
                ++blkcnt;
                bp1 = bp2;
                }
        locblk = 0;
        locsize = 0;
        lsyms.head = 0;
        printf(" releasing %d bytes local tables.\n",blkcnt * 2048);
}

release_global()
{       struct blk      *bp1, *bp2;
        int             blkcnt;
        bp1 = glbblk;
        blkcnt = 0;
        while( bp1 != 0 ) {
                bp2 = bp1->next;
                free(bp1);
                ++blkcnt;
                bp1 = bp2;
                }
        glbblk = 0;
        glbsize = 0;
        gsyms.head = 0;         /* clear global symbol table */
        printf(" releasing %d bytes global tables.\n",blkcnt * 2048);
        strtab = 0;             /* clear literal table */
}

