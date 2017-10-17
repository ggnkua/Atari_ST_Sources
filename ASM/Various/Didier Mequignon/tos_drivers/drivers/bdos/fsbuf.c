/*
 * fsbuf.c - buffer mgmt for file system
 *
 * Copyright (c) 2001 Lineo, Inc.
 *
 * Authors:
 *  SCC   Steve C. Cavender
 *
 * This file is distributed under the GPL, version 2 or at your
 * option any later version.  See doc/license.txt for details.
 */



#define  _MINT_OSTRUCT_H
#include <osbind.h>
#include "config.h"
#ifdef NETWORK
#ifdef LWIP
#include "../../include/vars.h"
#endif
#endif
#include "portab.h"
#include "asm.h"
#include "fs.h"
#include "bios.h"
#include "gemerror.h"

#define DBGFBUF 0

extern void display_string(char *string);
extern void ltoa(char *buf, long n, unsigned long base);

/*
 * bufl_init - BDOS buffer list initialization
 *
 * LVL - This should really go in BDOS...
 */

static BYTE secbuf[4][16384]; /* sector buffers: 16kB is TOS 4.0x limit though
                                when set here as [4][16384] the BDOS goes
                                crazy. 4kB is enough for my 500 MB partition */

static BCB bcbx[4];    /* buffer control block array for each buffer */
extern BCB *bufl[];    /* buffer lists - two lists:  fat,dir / data */

void bufl_init(void)
{
    /* set up sector buffers */

    bcbx[0].b_link = &bcbx[1];
    bcbx[2].b_link = &bcbx[3];

    /* make BCBs invalid */

    bcbx[0].b_bufdrv = -1;
    bcbx[1].b_bufdrv = -1;
    bcbx[2].b_bufdrv = -1;
    bcbx[3].b_bufdrv = -1;

    /* initialize buffer pointers in BCBs */

    bcbx[0].b_bufr = &secbuf[0][0];
    bcbx[1].b_bufr = &secbuf[1][0];
    bcbx[2].b_bufr = &secbuf[2][0];
    bcbx[3].b_bufr = &secbuf[3][0];

    /* initialize the buffer list pointers */
    
    bufl[BI_FAT] = &bcbx[0];                    /* fat buffers */
    bufl[BI_DATA] = &bcbx[2];                   /* dir/data buffers */
}



/*
 * flush -
 *
 * NOTE: longjmp_rwabs() is a macro that includes a longjmp() which is 
 *       executed if the BIOS returns an error, therefore flush() does 
 *       not need to return any error codes.
 */

void flush(BCB *b)
{
    short n,d;
    long sector;
    DMD *dm;

    /* if buffer not in use or not dirty, no work to do */

    if ((b->b_bufdrv == -1) || (!b->b_dirty)) {
        b->b_bufdrv = -1;
        return;
    }

#if DBGFBUF
    display_string("flush\r\n");
#endif
    
    dm = (DMD*) b->b_dm;                /*  media descr for buffer      */
    n = b->b_buftyp;
    d = b->b_bufdrv;
    b->b_bufdrv = -1;           /* invalidate in case of error */

    sector = b->b_bufrec+dm->m_recoff[n];
    longjmp_rwabs(1, b->b_bufr, 1, sector < 32768 ? sector : -1, d, sector);

    /* flush to both fats */

    if (n == 0)
    {
        sector = b->b_bufrec+dm->m_recoff[0]-(long)dm->m_fsiz;
        longjmp_rwabs(1, b->b_bufr, 1, sector < 32768 ? sector : -1, d, sector);
    }
    b->b_bufdrv = d;                    /* re-validate */
    b->b_dirty = 0;
}



/*
 * getrec - return the ptr to the buffer containing the desired record
 */

char *getrec(long recn, DMD *dm, short wrtflg)
{
    register BCB *b;
    BCB *p,*mtbuf,**q,**phdr;
    short n,cl,err,delta;

    /* put bcb management here */
    cl = (short)(recn >> dm->m_clrlog);  /*  calculate cluster nbr       */
    delta =  (short)dm->m_dtl->d_strtcl - cl;
    if((delta > 0) && (delta <= (short)(dm->m_recoff[2] >> dm->m_clrlog)))  /* DM 26/12/10 */
//    if (cl < (short)dm->m_dtl->d_strtcl)
        n = 0;                  /* FAT operat'n */
    else if(recn >= (long)((unsigned long)dm->m_numcl * (unsigned long)dm->m_clsiz))
        n = 1;                  /*  DIR (?)     */
    else
        n = 2;                  /*  DATA (?)    */

#if DBGFBUF
    {
        char buf[10];
        display_string("getrec recn ");
        ltoa(buf, recn, 10);
        display_string(buf);
        display_string(", cl ");
        ltoa(buf, (long)cl & 0xffff, 10);
        display_string(buf);
        display_string(", d_strtcl ");
        ltoa(buf, (long)dm->m_dtl->d_strtcl, 10);
        display_string(buf);
        display_string(", wrtflg ");
        ltoa(buf, (long)wrtflg, 10);
        display_string(buf);
        display_string(", n ");
        ltoa(buf, (long)n, 10);
        display_string(buf);
        display_string(", m_recoff[n] ");
        ltoa(buf, dm->m_recoff[n], 10);
        display_string(buf);        
        display_string("\r\n");
    }
#endif

    mtbuf = 0;
    phdr = &bufl[(n != 0)];

    /*
     * See, if the desired record for the desired drive is in memory.
     * If it is, we will use it.  Otherwise we will use
     *          the last invalid (available) buffer,  or
     *          the last (least recently) used buffer.
     */

    for (b = *(q = phdr); b; b = *(q = &b->b_link))
    {
        if ((b->b_bufdrv == dm->m_drvnum) && (b->b_bufrec == recn))
            break;
        /*
         * keep track of the last invalid buffer
         */
        if (b->b_bufdrv == -1)          /*  if buffer not valid */
            mtbuf = b;          /*    then it's 'empty' */
    }

    if (!b)
    {
        long sector;
        
        /*
         * not in memory.  If there was an 'empty' buffer, use it.
         */
        if (mtbuf)
            b = mtbuf;

        /*
         * find predecessor of mtbuf, or last guy in list, which
         * is the least recently used.
         */

doio:   for (p = *(q = phdr); p->b_link; p = *(q = &p->b_link))
            if (b == p)
                break;
        b = p;

        /*
         * flush the current contents of the buffer, and read in the
         * new record.
         */

        flush(b);
        sector = recn+dm->m_recoff[n];

#if DBGFBUF
    {
        char buf[10];
        display_string("getrec recn ");
        ltoa(buf, recn, 10);
        display_string(buf);
        display_string(", sector ");
        ltoa(buf, (long)sector, 10);
        display_string(buf);
        display_string(", n ");
        ltoa(buf, (long)n, 10);
        display_string(buf);
        display_string(", m_recoff[n] ");
        ltoa(buf, dm->m_recoff[n], 10);
        display_string(buf);        
        display_string("\r\n");
    }
#endif

        longjmp_rwabs(0, b->b_bufr, 1, sector < 32768 ? sector : -1, dm->m_drvnum, sector);

        /*
         * make the new buffer current
         */

        b->b_bufrec = recn;
        b->b_dirty = 0;
        b->b_buftyp = n;
        b->b_bufdrv = dm->m_drvnum;
        b->b_dm = (long) dm;
    }
    else
    {   /* use a buffer, but first validate media */
#ifdef NETWORK
#ifdef LWIP
        extern long pxCurrentTCB, tid_TOS;
        if(pxCurrentTCB != tid_TOS)
        {
            short (*p)(short);
            p = (short (*)(short))*(void **)hdv_mediach;
            err = (*p)(b->b_bufdrv);
        }
        else      
#endif
#endif  
        err = Mediach(b->b_bufdrv);
        if (err != 0) {
            if (err == 1) {
                goto doio; /* media may be changed */
            } else if (err == 2) {
                /* media definitely changed */
                errdrv = b->b_bufdrv;
                rwerr = E_CHNG; /* media change */
                errcode = rwerr;
                longjmp(errbuf,1);
            }
        }
    }

    /*
     *  now put the current buffer at the head of the list
     */

    *q = b->b_link;
    b->b_link = *phdr;
    *phdr = b;

    /*
     *  if we are writing to the buffer, dirty it.
     */

    if (wrtflg) {
        b->b_dirty = 1;
    }

    return(b->b_bufr);
}



/*
 * packit - pack into user buffer
 * more especially, convert a filename of the form
 *   NAME    EXT
 * into:
 *   NAME.EXT
 *
 * MAD: 12/13/01 - ripped out ugly gotos
 */

char *packit(register char *s, register char *d)
{
    char *s0;
    register short i;

    if ((*s))
    {
        s0 = s;
        for (i=0; (i < 8) && (*s) && (*s != ' '); i++)
            *d++ = *s++;

        if (*s0 != '.')
        {
            s = s0 + 8; /* ext */

            if (*s != ' ')
            {
                *d++ = '.';
                for (i=0; (i < 3) && (*s) && (*s != ' '); i++)
                    *d++ = *s++;
            }
        }
    }

    *d = 0;
    return(d);
}
