/*
 * umem.c - user memory management interface routines                   
 *
 * Copyright (c) 2001 Lineo, Inc.
 *
 * Authors:
 *  KTB   Karl T. Braun (kral)
 *  MAD   Martin Doering
 *  LVL   Laurent Vogel
 *
 * This file is distributed under the GPL, version 2 or at your
 * option any later version.  See doc/license.txt for details.
 */


#define DBGUMEM 0



#define  _MINT_OSTRUCT_H
#include <mint/osbind.h>
#include <mint/sysvars.h>
#include "config.h"
#include "portab.h"
#include "fs.h"
#include "asm.h"
#include "bios.h"
#include "mem.h"
#include "gemerror.h"


/*
 *  global variables
 */

MPB pmd;
MPB pmdtt;
short has_ttram;  

/* internal variables */

long start_stram;
long end_stram;
long screen_addr;

/*
 * static functions
 */

#if DBGUMEM

extern void display_string(char *string);
extern void ltoa(char *buf, long n, unsigned long base);

static void dump_mem_map(void)
{
#if 0
    MD *m;
    short i;
    char buf[10];
    
    display_string("===mem_dump==========================\r\n");
    display_string("| mp_mfl = 0x");
    ltoa(buf, (long)(m = pmd.mp_mfl), 16);
    display_string(buf);
    display_string(" {\r\n|   ");
    i = 0;
    for(; m != NULL ; m = m->m_link) {
        if(i >= 3) {
            display_string("\r\n|   ");
            i = 0;
        }
        i++; 
        display_string("[0x");
        ltoa(buf, m->m_start, 16);
        display_string(buf);
        display_string(", 0x");
        ltoa(buf,  m->m_length, 16);
        display_string(buf);
        display_string("], ");
    }
    display_string("\r\n| }\r\n");
    display_string("| mp_mal = 0x");
    ltoa(buf, (long)(m = pmd.mp_mal), 16);
    display_string(buf);
    display_string(" {\r\n|   ");
    i = 0;
    for(; m != NULL ; m = m->m_link) {
        if(i >= 3) {
            display_string(" \r\n|   ");
            i = 0;
        }
        i++; 
        display_string("[0x");
        ltoa(buf, m->m_start, 16);
        display_string(buf);
        display_string(", 0x");
        ltoa(buf,  m->m_length, 16);
        display_string(buf);
        display_string("], ");
    }
    display_string("\r\n| }\r\n");
    display_string("| mp_rover = 0x");
    ltoa(buf, (long)(pmd.mp_rover), 16);
    display_string(buf);
    display_string("\r\n===/mem_dump==========================\r\n");
#endif
}
#endif

/*
 *  xmalloc - allocate memory
 *
 *      Function 0x48   m_alloc
 */

long xmalloc(long amount)
{
    if( run->p_flags & PF_TTRAMMEM ) {
        /* allocate TT RAM, or ST RAM if not enough TT RAM */
        return xmxalloc(amount, MX_PREFTTRAM);
    } else {
        /* allocate only ST RAM */
        return xmxalloc(amount, MX_STRAM);
    }
}

/*
 *  xsrealloc - reallocate screen memory
 *
 *      Function 0x15   s_realloc
 */

long xsrealloc(long amount)
{
    if(screen_addr)
       xmfree(screen_addr);
    screen_addr = xmxalloc(amount, MX_STRAM);
    return(screen_addr);
}

/*
 *  xmfree - Function 0x49      m_free
 */

long xmfree(long addr)
{
    MD *p,**q;
    MPB *mpb;

#if DBGUMEM
    char buf[10];
    display_string("BDOS: xmfree(0x");
    ltoa(buf, (long) addr, 16);
    display_string(buf);
    display_string(")\r\n");
#endif

    if(addr >= start_stram && addr <= end_stram) {
        mpb = &pmd;
    } else if(has_ttram) {
        mpb = &pmdtt;
    } else {
        return EIMBA;
    }

    for (p = *(q = &mpb->mp_mal); p; p = *(q = &p->m_link))
        if (addr == p->m_start)
            break;

    if (!p)
        return(EIMBA);

    *q = p->m_link;
    freeit(p,mpb);

    return(E_OK);
}

/*
 * xsetblk - Function 0x4A      m_shrink
 *
 * Arguments:
 *  n   - dummy, not used
 *  blk - addr of block to free
 *  len - length of block to free
 */

long xsetblk(short n, void *blk, long len)
{
    MD *m,*p;
    MPB *mpb;

#if DBGUMEM
    char buf[10];
    display_string("BDOS: Mshrink(0x");
    ltoa(buf, (long) blk, 16);
    display_string(buf);
    display_string(", 0x");
    ltoa(buf, len, 16);
    display_string(buf);
    display_string(")\r\n");
#endif

    if(((long)blk) >= start_stram && ((long)blk) <= end_stram) {
        mpb = &pmd;
    } else if(has_ttram) {
        mpb = &pmdtt;
    } else {
        return EIMBA;
    }

    /*
     * Traverse the list of memory descriptors looking for this block.
     */

    for (p = mpb->mp_mal; p; p = p->m_link)
        if(  (long) blk == p->m_start  )
            break;

    /*
     * If block address doesn't match any memory descriptor, then abort.
     */

    if (!p)
        return(EIMBA);

    /*
     * If the caller is not shrinking the block size, then abort.
     */

    if (p->m_length < len)
        return(EGSBF);

    /*
     * Always shrink to an even word length.
     */
#if 0
    if (len & 1)
        len++;
#else
    len += 15; /* line (16 bytes) alignment */
    len &= ~15;
#endif

    /*
     * Create a memory descriptor for the freed portion of memory.
     */

    m = MGET(MD);

#if     DBGUMEM
    /* what if 0? */
    if( m == 0 )
        display_string("umem.c/xsetblk: Null Return From MGET\r\n");
#endif

    m->m_start = p->m_start + len;
    m->m_length = p->m_length - len;
    p->m_length = len;
    freeit(m,mpb);

    return(E_OK);
}

/*
 *  xmxalloc - allocate memory
 *
 *      Function 0x44   m_xalloc
 */

#define MX_STRAM 0
#define MX_TTRAM 1
#define MX_PREFSTRAM 2
#define MX_PREFTTRAM 3

long xmxalloc(long amount, short mode)
{
    MD *m;
    long ret_value;

#if DBGUMEM
    char buf[10];
    display_string("BDOS: xmxalloc(0x");
    ltoa(buf, amount, 16);
    display_string(buf);
    display_string(", ");
    ltoa(buf, (long)mode, 10);
    display_string(buf);
    display_string(") = 0x");
//    assert(has_ttram || mode == MX_STRAM);
#endif

    /*
     * if amount == -1L, return the size of the biggest block
     * 
     */
    if(amount == -1L) {
        switch(mode) {
        case MX_STRAM:
            ret_value = (long) ffit(-1L,&pmd);
            break;
        case MX_TTRAM:
            ret_value = (long) ffit(-1L,&pmdtt);
            break;
        case MX_PREFSTRAM:
        case MX_PREFTTRAM:
            /* TODO - I assume that the correct behaviour is to return
             * the biggest size in either pools. The documentation is unclear.
             */ 
            {
                long tmp = (long) ffit(-1L,&pmd);
                ret_value = (long) ffit(-1L,&pmdtt);
                if(ret_value < tmp) ret_value = tmp;
            }
            break;
        default:
            /* unknown mode */
            ret_value = 0;
        }
        goto ret;
    }

    /* 
     * return NULL if asking for a negative or null amount
     */

    if( amount <= 0 ) {
        ret_value = 0;
        goto ret;
    }

    /*
     * Round odd-value requests to next higher even number.
     */
#if 0
    if ((amount & 1))
        amount++;
#else
      amount += 15;
      amount &= ~15; /* line alignment */
#endif

    /*
     * Pass the request on to the internal routine. 
     */

    switch(mode) {
    case MX_STRAM:
        m = ffit(amount,&pmd);
        break;
    case MX_TTRAM:
        m = ffit(amount,&pmdtt);
        break;
    case MX_PREFSTRAM:
        m = ffit(amount,&pmd);
        if(m == NULL) 
            m = ffit(amount,&pmdtt);
        break;
    case MX_PREFTTRAM:
        m = ffit(amount,&pmdtt);
        if(m == NULL) 
            m = ffit(amount,&pmd);
        break;
    default:
        /* unknown mode */
        m = 0;
    }

    /*
     * The internal routine returned a pointer to a memory descriptor, or NULL
     * Return its pointer to the start of the block.
     */

    if(m == NULL) {
        ret_value = 0;
    } else {
        ret_value = (long) m->m_start;
    }

ret:
#if DBGUMEM
    ltoa(buf, ret_value, 16);
    display_string(buf);
    display_string("\r\n");
    dump_mem_map();
#endif

    return(ret_value);
}

/*
 * Maddalt() informs GEMDOS of the existence of additional 'alternative' 
 * RAM that would not normally have been identified by the system.  
 *
 * Available as of GEMDOS version 0.19 only.  
 * Parameters: start indicates the starting address for the block of 
 * memory to be added to the GEMDOS free list. size indicates the length 
 * of this block in bytes.  
 *  
 * Maddalt() returns E_OK (0) if the call succeeds or a negative GEMDOS error 
 * code otherwise.  
 *
 * This call should only be used to identify RAM not normally identified 
 * by the BIOS at startup (added through a VME-card or hardware 
 * modification). Once this RAM has been identified to the system it 
 * may not be removed and should only be allocated and used via the 
 * standard system calls. In addition, programs wishing to use this 
 * RAM must have their alternative RAM load bit set or use Mxalloc() 
 * to specifically request alternative RAM.
 */

long xmaddalt(long start, long size)
{
    MD *md;
    if(size <= 1) return -1;
    if(size & 1) size --;
    /* does it overlap with ST RAM? */
    if(start <= start_stram && start+size >= start_stram) return -1;
    if(start <= end_stram && start+size >= end_stram) return -1;

    md = MGET(MD);
    if(md == NULL) return ENSMEM;
    md->m_start = start;
    md->m_length = size;
    md->m_own = NULL;
    if(has_ttram) {
        /* some alternative RAM has already been registered, just insert it
         * to the beginning of the free block list.
         */
        MD *tmp = pmdtt.mp_mfl;
        pmdtt.mp_mfl = md;
        if(pmdtt.mp_rover == tmp) pmdtt.mp_rover = md;
        md->m_link = tmp;
    } else {
        md->m_link = NULL;
        pmdtt.mp_mfl = md;
        pmdtt.mp_mal = NULL;
        pmdtt.mp_rover = md;
        has_ttram = 1;
    }
    return 0;
}

/*
 * user memory init
 * called by bdosmain at the beginning; will call getmpb and immediately
 * keep the start and end addresses to be able later to determine if
 * addresses belong to one pool or the other.
 */

void umem_init(void)
{
    /* get the MPB */
    Getmpb((long)&pmd);
    /* derive the addresses, assuming the MPB is in clean state */ 
    start_stram = *_membot; // pmd.mp_mfl->m_start;
    end_stram = pmd.mp_mfl->m_start + pmd.mp_mfl->m_length;
    pmd.mp_mfl->m_start += 15;
    pmd.mp_mfl->m_start &= ~15;
    pmd.mp_mfl->m_length &= ~15;
    if(pmd.mp_rover == NULL)
        pmd.mp_rover = pmd.mp_mfl;
    /* there is no known TT RAM initially */
    has_ttram = 0;
    screen_addr = 0; /* for xsrealloc() */
}
