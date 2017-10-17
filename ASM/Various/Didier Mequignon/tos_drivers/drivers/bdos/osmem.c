/*
 * osmem.c - allocate/release os memory                         
 *
 * Copyright (c) 2001 Lineo, Inc.
 *
 * Authors:
 *  KTB   Karl T. Braun (kral)
 *  MAD   Martin Doering
 *
 * This file is distributed under the GPL, version 2 or at your
 * option any later version.  See doc/license.txt for details.
 */



#ifndef DBGFREMEM
#define DBGFREMEM       0
#endif

#ifndef DBGOSMEM
#define DBGOSMEM        0
#endif



/*
 *  mods
 *
 *  mod no.      date      who  comments
 *  ------------ --------  ---  --------
 *  M01.01a.0708 08 Jul 86 ktb  xmgetblk wasn't checking root index
 *
 */

#include "config.h"
#include "portab.h"
#include "fs.h"
#include "bios.h"                               /*  M01.01.02   */
#include "mem.h"
#include "gemerror.h"

/*
 *  local constants
 */

#define LENOSM 32000

/*
 *  internal variables
 */

static  short    osmptr;
static  short    osmlen;
static  short    osmem[LENOSM];

/*
 *  root - root array for 'quick' pool.
 *      root is an array of ptrs to memblocks of size 'i' paragraphs,
 *      where 'i' is the index into the araay (a paragraph is 16 bites).
 *      Each list is singly linked.  Items on the list are
 *      deleted/added in LIFO order from the root.
 */

#define MAXQUICK        32
short     *root[MAXQUICK];

/*
 *  local debug counters
 */

static  long    dbgfreblk;
static  long    dbggtosm;
static  long    dbggtblk;


/*
 * getosm - get a block of memory from the main o/s memory pool
 * (as opposed to the 'fast' list of freed blocks).
 *
 * Treats the os pool as a large array of integers, allocating from the base.
 *
 * Arguments:
 *  n -  number of words
 */

static short *getosm(short n)
{
    short *m;

    if( n > osmlen ) 
    {
      /*  not enough room  */
#if     OSMPANIC
        mgtpanic( root , 20 ) ; /*  will not return             */
#endif
        dbggtosm++ ;
        return(0);
    }

    m = &osmem[osmptr];         /*  start at base               */
    osmptr += n;                        /*  new base                    */
    osmlen -= n;                        /*  new length of free block    */
    return(m);                  /*  allocated memory            */
}

/*
 *  xmgetblk - get a block of memory from the o/s pool.
 *
 * First try to get a block of size i**16 bytes (i paragraphs) from
 * the 'fast' list - a list of lists of blocks, where list[i] is a
 * list of i paragraphs sized blocks.  These lists are singly linked
 * and are deleted/removed in LIFO order from the root.  If there is
 * no free blocks on the desired list, we call getosm to get a block
 * from the os memory pool
 *
 * Arguments:
 *  i - list of i paragraphs sized blocks
 */

void *xmgetblk(short i)
{
    short j,w,*m,*q,**r;

    w = i << 3;                 /*  number of words             */

    /*
     *  allocate block
     */

    /*  M01.01a.0708.01  */
    if( i >= MAXQUICK )
    {
        dbggtblk++ ;
        return( NULL ) ;
    }

    if(  *(r = &root[i])  )
    {
        /*  there is an item on the list  */
        m = *r;                 /*  get 1st item on list        */
        *r = *((short **) m);     /*  root pts to next item       */
    }
    else
    {   /*  nothing on list, try pool  */
        if ( (m = getosm(w+1)) )        /*  add size of control word    */
            *m++ = i;   /*  put size in control word    */
    }

    /*
     *  zero out the block
     */

    if( (q = m) )
        for( j = 0 ; j < w ; j++ )
            *q++ = 0;

    return(m);
}

/*
 *  xmfreblk - free up memory allocated through mgetblk
 */

void xmfreblk(void *m)
{
    short i;

    i = *(((short *)m) - 1);
    if( i < 0 || i >= MAXQUICK )
    {
        /*  bad index  */
#if     DBGOSMEM
        kprintf("xmfreblk: bad index (0x%x)\n") ;
        kprintf("stack at %08lx\n",&m) ;
        while(1) ;
#endif
        dbgfreblk++ ;
    }
    else
    {
        /*  ok to free up  */
        *((short **) m) = root[i];
        root[i] = m;
#if     DBGFREMEM
        if(  *((short **)m) == m )
        {
            kprintf("xmfreblk: Circular link in root[%x]\n",i) ;
            kprintf("\tat %lx\n",m) ;
        }
#endif

    }
}

/*
 * called by bdosmain to initialise the OS memory pool.
 */

void osmem_init(void)
{
    osmptr = 0;
    osmlen = LENOSM;
    dbgfreblk = 0;
    dbggtosm = 0;
    dbggtblk = 0;
}
