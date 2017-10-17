/*
 * bdosmain.c - GEMDOS main function dispatcher
 *
 * Copyright (c) 2001 Lineo, Inc.
 *               2002 The EmuTOS development team
 *
 * Authors:
 *  EWF  Eric W. Fleischman
 *  JSL  Jason S. Loveman
 *  SCC  Steven C. Cavender
 *  LTG  Louis T. Garavaglia
 *  KTB  Karl T. Braun (kral)
 *  ACH  Anthony C. Hay (DR UK)
 *  MAD  Martin Doering
 *
 * This file is distributed under the GPL, version 2 or at your
 * option any later version.  See doc/license.txt for details.
 */



#define DBGOSIF 0



#define         _MINT_OSTRUCT_H
#include        <osbind.h>
#include        "config.h"
#ifdef NETWORK
#ifdef LWIP
#include        "../../include/vars.h"
#endif
#endif
#include        "portab.h"
#include        "fs.h"
#include        "asm.h"
#include        "bios.h"
#include        "mem.h"
#include        "proc.h"
#include        "slb.h"
#include        "console.h"
#include        "time.h"
#include        "gemerror.h"


/*
**  externals
*/

extern void display_string(char *string);
extern void ltoa(char *buf, long n, unsigned long base);

extern SHARED_LIB *slb_list;

/* 
 * in rwa.S
 */

extern long xsuper(long);
extern long oscall(short, ...);

extern void enter(void);
extern void bdos_trap2(void);
extern void (*old_trap2)(void);

/*
 *  prototypes / forward declarations
 */

long ni(void);
long xgetver(void);



/*
 * FND - Function Descriptor
 *
 * Each entry in the function table (below) consists of the address of
 * the function which corresponds to the function number, and a function
 * type.
 */

#define FND struct _fnd
FND
{
        long    (*fncall)();
        short     fntyp;
};



/*
 * funcs - table of os functions, indexed by function number
 *
 * Each entry is for an FND structure. The function 'ni' is used
 * as the address for functions not implemented.
 */

FND funcs[0x58] =
{

    
     { (long(*)()) x0term, 0 }, /* 0x00 */

    /*
     * console functions
     *
     * on these functions, the 0x80 flag indicates std file used
     * 0x80 is std in, 0x81 is stdout, 0x82 is stdaux, 0x83 stdprn
     */

    { xconin,   0x80 }, /* 0x01 */
    { (long(*)()) xtabout,  0x81 },     /* 0x02 */
    { xauxin,   0x82 }, /* 0x03 */
    { (long(*)()) xauxout,  0x82 }, /* 0x04 */
    { (long(*)()) xprtout,  0x83 }, /* 0x05 */
    { (long(*)()) rawconio, 0 },    /* 0x06 */
    { x7in,     0x80 }, /* 0x07 */
    { x8in,     0x80 }, /* 0x08 */
    { (long(*)()) xprt_line,  0x81 },   /* 0x09 */
    { (long(*)()) readline,   0x80 },   /* 0x0A */
    { xconstat, 0x80 }, /* 0x0B */

    /*
     * disk functions
     *
     * on these functions the 0x80 flag indicates whether a handle
     * is required, the low bits represent the parameter ordering,
     * as usual.
     */

    { ni,       0 },
    { ni,       0 },

    { (long(*)()) xsetdrv,  0 },    /* 0x0E */

    { ni,       0 },

    /*
     * extended console functions
     *
     * Here the 0x80 flag indicates std file used, as above
     */

    { xconostat, 0x81 },        /* 0x10 */
    { xprtostat, 0x83 },        /* 0x11 */
    { xauxistat, 0x82 },        /* 0x12 */
    { xauxostat, 0x82 },        /* 0x13 */

    { xmaddalt, 1 },    /* 0x14 */
    { xsrealloc,0 },    /* 0x15 */
    { xslbopen, 4 },    /* 0x16 */
    { xslbclose,0 },    /* 0x17 */
    { ni,       0 },

    { xgetdrv,  0 },    /* 0x19 */
    { (long(*)()) xsetdta, 1 }, /* 0x1A */

    { xsuper,   0 },    /* 0x20 - switch to supervisor mode */
    { ni,       0 },
    { ni,       0 },
    { ni,       0 },
    { ni,       0 },

    /* xgsps */

    { ni,       0 },    /* 0x20 */
    { ni,       0 },
    { ni,       0 },
    { ni,       0 },
    { ni,       0 },
    { ni,       0 },
    { ni,       0 },
    { ni,       0 },
    { ni,       0 },
    { ni,       0 },

    { xgetdate, 0 },    /* 0x2A */
    { (long(*)()) xsetdate, 0 },    /* 0x2B */
    { xgettime, 0 },    /* 0x2C */
    { (long(*)()) xsettime, 0 },    /* 0x2D */

    { ni,       0 },

    { (long(*)()) xgetdta, 0 }, /* 0x2F */
    { xgetver,  0},     /* 0x30 */
    { (long(*)()) xtermres, 1 },        /* 0x31 */

    { ni,       0 },
    { ni,       0 },
    { ni,       0 },
    { ni,       0 },

    { (long(*)()) xgetfree, 1 },    /* 0x36 */

    { ni,       0 },
    { ni,       0 },

    { xmkdir,   1 },    /* 0x39 */
    { xrmdir,   1 },    /* 0x3A */
    { xchdir,   1 },    /* 0x3B */
    { (long(*)()) xcreat, 1 },      /* 0x3C */
    { (long(*)()) xopen,    1 },    /* 0x3D */
    { (long(*)()) xclose,   0x0 },  /* 0x3E - will handle its own redirection */
    { (long(*)()) xread,    0x82 }, /* 0x3F */
    { (long(*)()) xwrite,   0x82 }, /* 0x40 */
    { xunlink,  1 },                /* 0x41 */
    { (long(*)()) xlseek,   0x81 }, /* 0x42 */
    { (long(*)()) xchmod, 1 },      /* 0x43 */
    { (long(*)()) xmxalloc, 1 },    /* 0x44 */
    { dup,      0 },                /* 0x45 */
    { (long(*)()) xforce,   0 },    /* 0x46 */
    { (long(*)()) xgetdir,  1 },    /* 0x47 */
    { xmalloc,  1 },                /* 0x48 */
    { xmfree,   1 },                /* 0x49 */
    { (long(*)()) xsetblk,  2 },    /* 0x4A */
    { (long(*)()) xexec, 3 },       /* 0x4B */
    { (long(*)()) xterm, 0 },       /* 0x4C */

    { ni,       0 },
                
    { (long(*)()) xsfirst,  1 },    /* 0x4E */
    { xsnext,   0 },                /* 0x4F */

    { ni,       0 },                /* 0x50 */
    { ni,       0 },
    { ni,       0 },
    { ni,       0 },
    { ni,       0 },
    { ni,       0 },

    { (long(*)()) xrename, 2 },     /* 0x56 */
    { (long(*)()) xgsdtof, 1 }      /* 0x57 */
};




/*
 *  xgetver -
 *      return current version number
 */

long    xgetver(void)
{
//        return(0x2000L);                /*  minor.major */
        return(0x3000L);                /*  minor.major */
#if DBGOSIF
        display_string("BDOS: xgetver - Get version  successful ...\r\n");
#endif
}


/*
 *  ni -
 */

long    ni(void)
{
        return(EINVFN);
}



/*
 *  osinit - the bios calls this routine to initialize the os
 */

void    osinit(void)
{
    /* take over the handling of TRAP #1 */
    (void)Setexc(0x21, (long)enter);
    /* intercept TRAP #2 only for xterm(), keeping the old value
     * so that our trap handler can call the old one
     */
    old_trap2 = (void(*)()) Setexc(0x22, (long)bdos_trap2);

    bufl_init();                /* initialize BDOS buffer list */
    osmem_init();
    umem_init();
    time_init();
		slb_list = NULL;

    run = MGET(PD);
#if DBGOSIF
    {
        char buf[10];
        display_string("BDOS: Address of basepage = 0x");
        ltoa(buf, (LONG)&run, 16);
        display_string(buf);
        display_string("\r\n");
    }
#endif

    /* set up system initial standard handles */

    run->p_uft[0] = H_Console;          /* stdin        =       con:    */
    run->p_uft[1] = H_Console;          /* stdout       =       con:    */
    run->p_uft[2] = H_Console;          /* stderr       =       con:    */
    run->p_uft[3] = H_Aux;              /* stdaux       =       aux:    */
    run->p_uft[4] = H_Print;            /* stdprn       =       prn:    */

    add[0] = remove[0] = add[1] = remove[1] = add[2] = remove[2] = 0 ;

#if DBGOSIF
    display_string("BDOS: cinit - osinit successful ...\r\n");
#endif
}



/*
 *  ncmps -  compare two text strings, ingoreing case.
 */

static short ncmps(short n, char *s, char *d)
{
    while (n--)
        if (uc(*s++) != uc(*d++))
            return(0);

    return(1);
}



/*
 *  freetree -  free the directory node tree
 */

static void freetree(DND *d)
{
    short i;

    if (d->d_left) freetree(d->d_left);
    if (d->d_right) freetree(d->d_right);
    if (d->d_ofd)
    {
        xmfreblk(d->d_ofd);
    }
    for (i = 0; i < NCURDIR; i++)
    {
        if (dirtbl[i] == d)
        {
            dirtbl[i] = 0;
            diruse[i] = 0 ;     /*  M01.01.06           */
        }
    }
    xmfreblk(d);
}



/*
 *  offree -
 */

static void offree(DMD *d)
{
    short i;
    OFD *f;
    for (i=0; i < OPNFILES; i++)
        if( ((long) (f = sft[i].f_ofd)) > 0L )
            if (f->o_dmd == d)
            {
                xmfreblk(f);
                sft[i].f_ofd = 0;
                sft[i].f_own = 0;
                sft[i].f_use = 0;
            }
}


/*
 * These both are just wrappers for some BIOS function. They are made
 * to avoid the 'clobbered by longjmp or vfork' compiler warnings!
 */
static BPB * MyGetbpb(WORD errdrv)
{
#ifdef NETWORK
#ifdef LWIP
    extern long pxCurrentTCB, tid_TOS;
    if(pxCurrentTCB != tid_TOS)
    {
        BPB * (*p)(short);
        p = (BPB * (*)(short))*(void **)hdv_bpb;
        return((*p)(errdrv));
    }
#endif
#endif      
    return (BPB *) Getbpb(errdrv);
}

static long MyBconout(short dev, short c)
{
    return Bconout(dev, c);
}



/*
 *  osif -
 */

#if 0     // was #if    DBGOSIF
/*
 * if in debug mode, use this 'front end' so we can tell if we exit
 * from osif
 */

long    osif(short *pw )
{
    long        osif2() ;
    char        *p ;
    long        r ;

    p = (char *) &pw ;
    osifdmp( p-4 , pw ) ;               /*  pass return addr and pw ptr */

    r = osif2( pw ) ;

    osifret() ;
    return( r ) ;
}
#else
/*
 * if not in debug mode, go directory to 'osif2'.  Do not pass go, do
 * not collect $200, and do not spend time on an extra call
 */
#define osif2   osif

#endif

long    osif2(short *pw)
{
    char **pb,*pb2,*p,ctmp;
    BPB *b;
    BCB *bx;
    DND *dn;
    short typ,h,i,fn;
    short num,max;
    long rc,numl;
    FND *f;


restrt:
    fn = pw[0];
    if (fn > 0x57)
        return(EINVFN);
#if 0
    {
        char buf[10];
        display_string("bdos(fn = 0x");
        ltoa(buf, (long)fn, 16);
        display_string(buf);
        display_string(")\r\n");
    }
#endif
    
    if ( setjmp(errbuf) )
    {
        rc = errcode;
        /* hard error processing */
#if DBGOSIF
        {
            char buf[10];
            display_string("Error code gotten from some longjmp(), back in osif(): ");
            ltoa(buf, rc, 10);
            display_string(buf);
            display_string("\r\n");
        }
#endif
        /* is this a media change ? */
        if (rc == E_CHNG) {
            /* first, out with the old stuff */
            dn = drvtbl[errdrv]->m_dtl;
            offree(drvtbl[errdrv]);
            xmfreblk(drvtbl[errdrv]);
            drvtbl[errdrv] = 0;

            if (dn)
                freetree(dn);

            for (i = 0; i < 2; i++)
                for (bx = bufl[i]; bx; bx = bx->b_link)
                    if (bx->b_bufdrv == errdrv)
                        bx->b_bufdrv = -1;

            /* then, in with the new */
            b = MyGetbpb(errdrv);       /* use wrapper just to avoid longjmp() compiler warning */
            if ( (long)b <= 0 ) {
                drvsel &= ~(1<<errdrv);
                if ( (long)b )
                    return( (long)b );
                return(rc);
            }

            if(  log_(b,errdrv)  )
                return (ENSMEM);

            rwerr = 0;
            errdrv = 0;
            goto restrt;
        }

        /* else handle as hard error on disk for now */

        for (i = 0; i < 2; i++)
            for (bx = bufl[i]; bx; bx = bx->b_link)
                if (bx->b_bufdrv == errdrv)
                    bx->b_bufdrv = -1;
        return(rc);
    }

    f = &funcs[fn];
    typ = f->fntyp;

    if (typ && fn && ((fn<12) || ((fn>=16) && (fn<=19)))) /* std funcs */
    {
        h = run->p_uft[typ & 0x7f];
        if ( h > 0)
        { /* do std dev function from a file */
            switch(fn)
            {
            case 6:
                if (pw[1] != 0xFF)
                    goto rawout;
            case 1:
            case 3:
            case 7:
            case 8:
                xread(h,1L,&ctmp);
                return(ctmp);

            case 2:
            case 4:
            case 5:
                /*  M01.01.07  */
                /*  write the char in the short at pw[1]  */
            rawout:
                xwrite( h , 1L , ((char*) &pw[1])+1 ) ;
                return 0; /* dummy */

            case 9:
                pb2 = *((char **) &pw[1]);
                while (*pb2) xwrite(h,1L,pb2++);
                return 0; /* dummy */

            case 10:
                pb2 = *((char **) &pw[1]);
                max = *pb2++;
                p = pb2 + 1;
                for (i = 0; max--; i++,p++)
                {
                    if (xread(h,1L,p) == 1)
                    {
                        oscall(0x40,1,1L,p);
                        if (*p == 0x0d)
                        {       /* eat the lf */
                            xread(h,1L,&ctmp);
                            break;
                        }
                    }
                    else
                        break;
                }
                *pb2 = i;
                return(0);

            case 11:
            case 16:
            case 17:
            case 18:
            case 19:
                return(0xFF);
            }
        }

        if ((fn == 10) || (fn == 9))
            typ = 1;
        else
            typ = 0;
    }

    if (typ & 0x80)
    {
        if (typ == 0x81)
            h = pw[3];
        else
            h = pw[1];

        if (h >= NUMSTD)
            numl = (long) sft[h-NUMSTD].f_ofd;
        else if (h >= 0)
        {
            h = run->p_uft[h];
            if ( h > 0)
                numl = (long) sft[h-NUMSTD].f_ofd;
            else
                numl = h;
        }
        else
            numl = h;

        if (!numl)
            return(EIHNDL); /* invalid handle: media change, etc */

        if (numl < 0)
        {       /* prn, aux, con */
                /* -3   -2   -1  */

            num = numl;

            /*  check for valid handle  */ /* M01.01.0528.01 */
            if( num < -3 )
                return( EIHNDL ) ;

            pb = (char **) &pw[4];

            /* only do things on read and write */

            if (fn == 0x3f) /* read */
            {
                if (pw[2])      /* disallow HUGE reads      */
                    return(0);

                if (pw[3] == 1)
                {
                    **pb = conin(HXFORM(num));
                    return(1);
                }

                return(cgets(HXFORM(num),pw[3],*pb));
            }

            if (fn == 0x40) /* write */
            {
                if (pw[2])      /* disallow HUGE writes     */
                    return(0);

                pb2 = *pb;      /* char * is buffer address */


                for (i = 0; i < pw[3]; i++)
                {
                    if( num == H_Console )
                        tabout( HXFORM(num) , *pb2++ ) ;
                    else
                    {           /* M01.01.1029.01 */
                        rc = MyBconout( HXFORM(num), *pb2++ ) ;
                        if (rc < 0)
                            return(rc);
                    }
                }

                return(pw[3]);
            }

            return(0);
        }
    }
    rc = 0;
    if ((fn == 0x3d) || (fn == 0x3c))  /* open, create */
    {
        p = *((char **) &pw[1]);
        if (ncmps(5,p,"CON:"))
            rc = 0xFFFFL;
        else if (ncmps(5,p,"AUX:"))
            rc = 0xFFFEL;
        else if (ncmps(5,p,"PRN:"))
            rc = 0xFFFDL;
    }
    if (!rc)
    {
        typ &= 0x07f;
        switch(typ)
        {
        case 0:
            rc = (*f->fncall)(pw[1],pw[2]);
            break;

        case 1:
            rc = (*f->fncall)(pw[1],pw[2],pw[3],pw[4]);
            break;

        case 2:
            rc = (*f->fncall)(pw[1],pw[2],pw[3],pw[4],pw[5],pw[6]);
            break;

        case 3:
            rc = (*f->fncall)(pw[1],pw[2],pw[3],pw[4],pw[5],pw[6],pw[7],pw[8]);
            break;

        case 4:
            rc = (*f->fncall)(pw[1],pw[2],pw[3],pw[4],pw[5],pw[6],pw[7],pw[8],pw[9],pw[10]);
            break;
        }
    }
    return(rc);
}

