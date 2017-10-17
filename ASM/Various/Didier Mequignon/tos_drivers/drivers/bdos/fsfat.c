/*
 * fsfat.c - fat mgmt routines for file system           
 *
 * Copyright (c) 2001 Lineo, Inc.
 *
 * Authors:
 *  xxx <xxx@xxx>
 *
 * This file is distributed under the GPL, version 2 or at your
 * option any later version.  See doc/license.txt for details.
 */



#include        "portab.h"
#include        "asm.h"
#include        "fs.h" 
#include        "bios.h"                /*  M01.01.01                   */
#include        "gemerror.h"


#define DBGFSFAT 0

extern void display_string(char *string);
extern void ltoa(char *buf, long n, unsigned long base);



/*
**  cl2rec -
**      M01.0.1.03
*/

RECNO cl2rec(CLNO cl, DMD *dm)
{
        return((RECNO)cl * (RECNO)dm->m_clsiz);
}




/*
**  clfix -
**      replace the contents of the fat entry indexed by 'cl' with the value
**      'link', which is the index of the next cluster in the chain.
**
**      M01.01.03
*/

void clfix(CLNO cl, CLNO link, DMD *dm)
{
        short f[1],mask;
        long pos;

        if (dm->m_16)
        {
                swpw(link);
                pos = (long)(cl) << 1;                  /*  M01.01.04   */
                ixlseek(dm->m_fatofd,pos);
                ixwrite(dm->m_fatofd,2L,&link);
                return;
        }

        pos = (cl + (cl >> 1));

        link = link & 0x0fff;

        if (cl & 1)
        {
                link = link << 4;
                mask = 0x000f;
        }
        else
                mask = 0xf000;

        ixlseek(dm->m_fatofd,pos);

        /* pre -read */
        ixread(dm->m_fatofd,2L,f);

        swpw(f[0]);
        f[0] = (f[0] & mask) | link;
        swpw(f[0]);

        ixlseek(dm->m_fatofd,pos);
        ixwrite(dm->m_fatofd,2L,f);
}




/*
**  getcl -
**      get the contents of the fat entry indexed by 'cl'.
**
**  returns
**      0xffff if entry contains the end of file marker
**      otherwise, the contents of the entry (16 bit value always returned).
**
**      M01.0.1.03
*/

CLNO getcl(CLNO cl, DMD *dm)      /* cl was short, DM 02.01.11 */
{
        unsigned short f[1];

        if(cl >= dm->m_numcl)     /* DM 02.01.11 */
//        if (cl < 0)
        {
#if DBGFSFAT
                char buf[10];
                display_string("getcl(cl=");
                ltoa(buf, (long)cl, 10);
                display_string(buf);
                display_string(")\r\n");
#endif
                return(cl+1);              
        }

        if (dm->m_16)
        {                               /*  M01.01.04  */
                ixlseek( dm->m_fatofd , (long)( (long)(cl) << 1 ) ) ;
                ixread(dm->m_fatofd,2L,f);
                swpw(f[0]);
                return(f[0]);
        }

        ixlseek(dm->m_fatofd,((long) (cl + (cl >> 1))));
        ixread(dm->m_fatofd,2L,f);
        swpw(f[0]);

        if (cl & 1)
                cl = f[0] >> 4;
        else
                cl = 0x0fff & f[0];

        if (cl == 0x0fff)
                return(-1);

        return(cl);
}




/*
**  nextcl -
**      get the cluster number which follows the cluster indicated in the curcl
**      field of the OFD, and place it in the OFD.
**
**  returns
**      E_OK    if success,
**      -1      if error
**
*/

short nextcl(OFD *p, short wrtflg)
{
        DMD     *dm ;
        CLNO    i ;
        CLNO    rover ;
        CLNO    cl,cl2 ;                                /*  M01.01.03   */

        cl = p->o_curcl;
        dm = p->o_dmd;

        if(cl >= dm->m_numcl) {     /* DM 02.01.11 */
/*        if((short)(cl) < 0) { */
            cl2 = cl + 1;
            goto retcl;
        } else if(cl != 0) {
            cl2 = getcl(cl,dm);
        } else { /* was  if (cl == 0) */
            cl2 = (p->o_strtcl ? p->o_strtcl : 0xffff );
        }

        if (wrtflg && (cl2 == 0xffff ))
        { /* end of file, allocate new clusters */
                rover = cl;
                for (i=2; i < dm->m_numcl; i++) 
                {
                        if (rover < 2)
                                rover = 2;

                        if (!(cl2 = getcl(rover,dm)))
                                break;
                        else
                                rover = (rover + 1) % dm->m_numcl;
                }

                cl2 = rover;

                if (i < dm->m_numcl)
                {
                        clfix(cl2,0xffff,dm);
                        if (cl)
                                clfix(cl,cl2,dm);
                        else
                        {
                                p->o_strtcl = cl2;
                                p->o_flag |= O_DIRTY;
                        }
                }
                else
                        return(0xffff);
        }

        if (cl2 == 0xffff)
                return(0xffff);

retcl:  p->o_curcl = cl2;
        p->o_currec = cl2rec(cl2,dm);
        p->o_curbyt = 0;

        return(E_OK);
}




/*      Function 0x36   d_free
                get disk free space data into buffer *
        Error returns
                ERR

        Last modified   SCC     15 May 85
*/

long xgetfree(long *buf, short drv) 
{
        long i,free;
        DMD *dm;

        drv = (drv ? drv-1 : run->p_curdrv);

        if ((i = ckdrv(drv)) < 0)
                return(ERR);

        dm = drvtbl[i];
        free = 0;
        for (i = 2; i < dm->m_numcl; i++)
                if (!getcl((CLNO)i,dm))
                        free++;
        buf[0] = (long)(free);
        buf[1] = (long)(dm->m_numcl);
        buf[2] = (long)(dm->m_recsiz);
        buf[3] = (long)(dm->m_clsiz);

        return(E_OK);
}

