
/***************************************************************************

    XFDRIVER.C

    - F: device driver routines

    03/02/89 created

    05/07/89 01:00

***************************************************************************/

#include <stdio.h>
#include <osbind.h>
#include <obdefs.h>
#include <gemdefs.h>
#include <strings.h>
#include "xglobal.h"

int rgwDOShand[8] =
    {
    -1, -1, -1, -1, -1, -1, -1, -1
    };

int rgwDOSmode[8];


F_open()
    {
    register char wRetStat;
    int cch, iocb, iocb16;
    int hand;
    char ch, aux1, aux2;
    register unsigned int vector;
    char rgch[80];
    register char *pch = rgch, *pchName;

    iocb16 = reg_X;
    iocb = iocb16 >> 4;
    vector = Dpeek(0x344+iocb16);
    pchName = (char *)lMemory + vector;

    aux1 = Peek(0x34A+iocb16);

    wRetStat=146;
    cch=0;

    parse_fn(pchName, rgch);

 /* Now check for the special case where the use wants a disk directory. */
 /* Open a file _.DIR and stuff a DOS 2.0 type directory listing into it. */

    if (aux1 == 4)
        hand = Fopen(rgch,0);
    else if (aux1 == 8)
        hand = Fcreate(rgch,0);
    else
        goto exit;

    if (hand < 0)
        {
        if (hand == -33)
            wRetStat = 170;
        else
            wRetStat = 165;
        }
    else
        {
        wRetStat = 1;
        rgwDOShand[iocb] = hand;
        rgwDOSmode[iocb] = aux1;
        }

exit:      
    reg_Y = wRetStat;

    reg_Z = wRetStat;
    reg_N = (wRetStat & 0x80) ? TRUE : FALSE;
    reg_PC = 0xE45B;
    }

F_close()
    {
    register char wRetStat;
    register int iocb16, iocb;

    iocb16 = reg_X;
    iocb = iocb16 >> 4;

    Fclose(rgwDOShand[iocb]);
    rgwDOShand[iocb] = -1;

    wRetStat = 1;
    reg_Y = wRetStat;

    reg_Z = wRetStat;
    reg_N = (wRetStat & 0x80) ? TRUE : FALSE;
    reg_PC = 0xE45B;
    }

F_get()
    {
    register char wRetStat;
    int iocb, iocb16;
    char ch;
#ifdef BURSTIO
    register unsigned cch, vector;
    int fTEXT;
    register long lcb;
    register IOCB *piocb = (IOCB *)(lMemory + 0x20);
#endif

    iocb16 = reg_X;
    iocb = iocb16 >> 4;

    if (Fread (rgwDOShand[iocb], 1L, &ch) == 1L)
        reg_Y = 1;
    else
        reg_Y = 136;

    reg_A = ch;
     
   /* print("get: ch = %d\n", ch); */

    reg_Z = reg_Y;
    reg_N = (reg_Y & 0x80) ? TRUE : FALSE;
    reg_PC = 0xE45B;
    return;

#ifdef BURSTIO
    iocb16 = reg_X;
    iocb = iocb16 >> 4;

    vector = Dpeek(0x344+iocb16);
    cch = Dpeek(0x348+iocb16);

    print("get: vector = %4x   cch = %d  iocb = %d\n", vector, cch, iocb);

    wRetStat=131;

    if (rgwDOSmode[iocb]&8)
        goto Dget_exit;   /* write only */

    if ((piocb->iccmd & 2) == 0)
        {
        while (cch--)
            {
            lcb = Fread (rgwDOShand[iocb], 1L, lMemory+vector);
            ch = *(char *)(lMemory + vector++);
            if (lcb<0)
                wRetStat = 163;
            else if (lcb == 0)    /* EOF */
                wRetStat = 136;
            else
                {
                if (piocb->icbal++ == 0)   /* increment buffer pointer */
                    piocb->icbah++;
                if (piocb->icbll == 255)
                    piocb->icblh--;       /* decrement buffer length */
                wRetStat = 1;
                }
            if ((lcb <= 0) || (ch == (char)155))
                goto Dget_exit;
            }
        wRetStat = 137;   /* truncated record error */
        }
    else
        {
        lcb = Fread (rgwDOShand[iocb],(long)cch,lMemory + vector);
        ch = *(char *)(lMemory + vector + cch - 1);

        if (lcb<0)
            wRetStat=163;
        else if (lcb==0)    /* EOF */
            wRetStat=136;
        else
            {
            piocb->icbal += piocb->icbll;     /* increment buffer pointer */
            piocb->icbah += piocb->icblh;
            piocb->icbll = 1;    /* decrement buffer length */
            piocb->icblh = 0;    /* decrement buffer length */
            wRetStat = 1;
            }
        }

Dget_exit:
    piocb->icsta = wRetStat;
    reg_Y = wRetStat;
    reg_A = ch;

    reg_Z = wRetStat;
    reg_N = (wRetStat & 0x80) ? TRUE : FALSE;
    reg_PC = 0xE45B;
#endif /* BURSTIO */
    }

F_put()
    {
    register char wRetStat;
    unsigned int iocb, iocb16;
    char ch;

#ifdef BURSTIO
    register unsigned cch, vector;
    register long lcb;

    register IOCB *piocb = (IOCB *)(lMemory + 0x20);
#endif

    iocb16 = reg_X;
    iocb = iocb16 >> 4;

    ch = reg_A;

/*    print("put: ch = %d\n", ch); */

    if (Fwrite (rgwDOShand[iocb], 1L, &ch) == 1L)
        {
        reg_Y = 1;
        }
    else
        {
        reg_Y = 144;
        }
     
    reg_Z = reg_Y;
    reg_N = (reg_Y & 0x80) ? TRUE : FALSE;
    reg_PC = 0xE45B;
    return;

#ifdef BURSTIO
    /* burst I/O stuff */
    ch = reg_A;

    vector = Dpeek(0x344+iocb16);
    cch = Dpeek(0x348+iocb16);

    print("put: vector = %4x   cch = %d  iocb = %d\n", vector, cch, iocb);

    wRetStat = 135;
    if ((rgwDOSmode[iocb]&8)==0)
        goto Dput_exit;   /* not open for write */

    if (cch == 0)
        lcb = Fwrite (rgwDOShand[iocb], 1L, &ch);
    else
        lcb = Fwrite (rgwDOShand[iocb],(long)cch,lMemory + vector);

    if (lcb != (long)cch)
        wRetStat=163;
    else
        {
        piocb->icbal += piocb->icbll;     /* increment buffer pointer */
        piocb->icbah += piocb->icblh;
        piocb->icbll = 1;    /* decrement buffer length */
        piocb->icblh = 0;    /* decrement buffer length */
        wRetStat = 1;
        }

Dput_exit:
    reg_Y = wRetStat;
    reg_Z = wRetStat;
    reg_N = (wRetStat & 0x80) ? TRUE : FALSE;
    reg_PC = 0xE45B;
#endif /* BURSTIO */
    }

F_stat()
    {
    register char wRetStat = 1;

    reg_Z = wRetStat;
    reg_N = (wRetStat & 0x80) ? TRUE : FALSE;
    reg_PC = 0xE45B;
    }

F_XIO()
    {
    register char wRetStat = 1;

    reg_Z = wRetStat;
    reg_N = (wRetStat & 0x80) ? TRUE : FALSE;
    reg_PC = 0xE45B;
    }

/* Parse over the "Fn:" which leaves just the filename */

parse_fn(pchName, pch)
register char *pchName, *pch;
    {
    register char ch;

    while (*pchName++ != ':')
       ;

    while ((ch = *pchName++) != (char)155)
        {
        if (ch == '/')
            ch = '\\';
        *pch++ = ch;
        }

    *pch = 0;
    }


#ifdef NEVER
/********************************************
**
** R: routines.
** Note, we do not bother to check filename
** or IOCB # since there is only one modem.
**
********************************************/

R_open()
    {
    Rsconf(9, 1, -1, -1, -1, -1);   /* set baud, 9=300, 7=1200, 4=2400 */

    reg_Y = 1;

    reg_Z = 1;
    reg_N = 0;
    reg_PC = 0xE45B;
    }

R_close()
    {
    reg_Y = 1;

    reg_Z = 1;
    reg_N = 0;
    reg_PC = 0xE45B;
    }

R_get()
    {
    if (Cauxis() != 0)
        {
        reg_A = Cauxin();
        reg_Y = 1;
        }
    else
        {
        reg_A = 0;
        reg_Y = 136;
        }

   /* print("get: ch = %d\n", ch); */

    reg_Z = reg_Y;
    reg_N = (reg_Y & 0x80) ? TRUE : FALSE;
    reg_PC = 0xE45B;
    }

R_put()
    {
    if (Cauxos() != 0)
        {
        Cauxout(reg_A);
        reg_Y = 1;
        }
    else
        reg_Y = 144;
     
    reg_Z = reg_Y;
    reg_N = (reg_Y & 0x80) ? TRUE : FALSE;
    reg_PC = 0xE45B;
    }

R_stat()
    {
    if (Cauxis() != 0)
        reg_Y = 1;
    else
        reg_Y = 136;    

    reg_Z = reg_Y;
    reg_N = (reg_Y & 0x80) ? TRUE : FALSE;
    reg_PC = 0xE45B;
    }

R_XIO()
    {
    reg_Y = 146;

    reg_Z = reg_Y;
    reg_N = (reg_Y & 0x80) ? TRUE : FALSE;
    reg_PC = 0xE45B;
    }

#endif
