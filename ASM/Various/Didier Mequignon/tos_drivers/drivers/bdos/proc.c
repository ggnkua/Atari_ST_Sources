/*
 * proc.c - process management routines
 *
 * Copyright (c) 2001 Lineo, Inc. and Authors:
 *
 *  KTB     Karl T. Braun (kral)
 *  MAD     Martin Doering
 *  ACH     ???
 *  LVL     Laurent Vogel
 *
 * 2006/10/01 Didier Mequignon, add SLB support from MiNT sources
 *                                      Author: Thomas Binder
 *
 * This file is distributed under the GPL, version 2 or at your
 * option any later version.  See doc/license.txt for details.
 */



#define  _MINT_OSTRUCT_H
#include <osbind.h>
#include "config.h"
#include "portab.h"
#include "asm.h"
#include "fs.h"
#include "bios.h"
#include "mem.h"
#include "proc.h"
#include "gemerror.h"
#include "slb.h"

#define DBGPROC 0

/*
 * forward prototypes
 */

extern void display_string(char *string);
extern void ltoa(char *buf, long n, unsigned long base);

extern long length(const char *text);
extern void copy(const char *src, char *dest);
extern void cat(const char *src, char *dest);
extern void _bzero(void *ptr, long len);
extern void *memcpy(void *dst, const void *src, unsigned long len);

extern void flush_cache_pexec(PD *p, char *path);
extern long slb_exec(void);

static void ixterm(PD *r);
static WORD envsize(char *env);
static void init_pd_fields(PD *p, char *tail, long max, MD *env_md);
static void init_pd_files(PD *p);
static MD *alloc_env(char *v);
static void proc_go(PD *p);

static void slb_close_on_exit(PD *p);
static void remove_slb(SHARED_LIB	*slb_remove);

/*
 * global variables
 */

extern PD      *run;           /* ptr to PD for current process */
WORD    supstk[SUPSIZ]; /* common sup stack for all processes*/
/* The linked list of used SLBs */
SHARED_LIB *slb_list;

/*
 * internal variables
 */

static jmp_buf bakbuf;         /* longjmp buffer */


/*
 * memory internal routines
 * 
 * These violate the encapsulation of the memory internal structure.
 * Could perhaps better go in the memory part.
 */

static MPB *find_mpb(void *addr);
static void free_all_owned(PD *p, MPB *mpb);
static void set_owner(void *addr, PD *p, MPB *mpb);
static void reserve_block(void *addr, MPB *mpb);

static MPB *find_mpb(void *addr)
{
    if(((long)addr) >= start_stram && ((long)addr) <= end_stram) {
        return &pmd;
    } else if(has_ttram) {
        return &pmdtt;
    } else {
        /* returning NULL would mean check for NULL in all mpb functions */
        return &pmd;
    }
}

/* reserve a block, i.e. remove it from the allocated list */
static void reserve_block(void *addr, MPB *mpb)
{
    MD *m,**q;

    for (m = *(q = &mpb->mp_mal); m ; m = *q) {
        if (m->m_own == run) {
            *q = m->m_link; /* pouf ! like magic */
            xmfreblk(m);
        } else {
            q = &m->m_link;
        }
    }
}

/* free each item in the allocated list, that is owned by 'p' */
static void free_all_owned(PD *p, MPB *mpb)
{
    MD *m, **q;

    for( m = *( q = &mpb->mp_mal ) ; m ; m = *q ) {
        if (m->m_own == p) {
            *q = m->m_link;
            freeit(m,mpb);
        } else {
            q = &m->m_link;
        }
    }
}
    
/* change the memory owner based on the block address */
static void set_owner(void *addr, PD *p, MPB *mpb)
{
    MD *m;
    for( m = mpb->mp_mal ; m ; m = m->m_link ) {
        if(m->m_start == (long)addr) {
            m->m_own = p;
            return;
        }  
    }
}

/* some functions */

static long stricmp (const char *str1, const char *str2)
{
	register char c1, c2;
	do
	{
		c1 = *str1++;
		if(c1>='A' && c1<='Z')
			c1 += 0x20;
		c2 = *str2++;
		if(c2>='A' && c2<='Z')
			c2 += 0x20;
	}
	while(c1 && c1 == c2);
	return (long) (c1 - c2);
}

static long strncmp(const char *str1, const char *str2, long len)
{
	register char c1, c2;
	do
	{
		c1 = *str1++;
		c2 = *str2++;
	}
	while(--len >= 0 && c1 && c1 == c2);
	if(len < 0)
		return 0L;
	return (long) (c1 - c2);
}

static char *getenv(PD *bp, const char *var)
{
	char *env_str = bp->p_env;
	long len = length(var);
	if(env_str && len)
	{
		while(*env_str)
		{
			if((strncmp(env_str, var, len) == 0) && (env_str[len] == '='))
				return env_str + len + 1;
			while(*env_str)
				env_str++;
			env_str++;
		}
	}
	return NULL;
}

/**
 * ixterm - terminate a process
 *
 * terminate process with PD 'r'.
 *
 * @r: PD of process to terminate
 */

static void     ixterm( PD *r )
{
    register WORD h;
    register WORD i;

    /* check the standard devices in both file tables  */

    for( i = 0 ; i < NUMSTD ; i++ )
        if( (h = r->p_uft[i]) > 0 )
            xclose(h);

    for (i = 0; i < OPNFILES; i++)
        if (r == sft[i].f_own)
            xclose(i+NUMSTD);


    /* check directory usage  M01.01.07 */

    for( i = 0 ; i < NUMCURDIR ; i++ )
    {
        if( (h = r->p_curdir[i]) != 0 )
            diruse[h]-- ;
    }

    /* free each item in the allocated list, that is owned by 'r' */

    free_all_owned(r, &pmd);
    if(has_ttram) 
        free_all_owned(r, &pmdtt);
}


/*
 * envsize - determine size of env area
 *
 * counts bytes starting at 'env' upto and including the terminating
 * double null.
 */

static  WORD envsize( char *env )
{
    register char       *e ;
    register WORD       cnt ;

    for( e = env, cnt = 0 ; !(*e == '\0' && *(e+1) == '\0') ; ++e, ++cnt )
        ;

    return( cnt + 2 ) ;         /*  count terminating double null  */
}



/** xexec - (p_exec - 0x4b) execute a new process
 *
 * load&go(cmdlin,cmdtail), load/nogo(cmdlin,cmdtail), justgo(psp)
 * create psp - user receives a memory partition
 *
 * @flg: 0: load&go, 3: load/nogo, 4: justgo, 5: create psp, 6: ???
 * @s:   command
 * @t:   tail
 * @v:   environment
 */

/* these variables are used to avoid the following warning:
 * variable `foo' might be clobbered by `longjmp' or `vfork'
 */
static PD *cur_p;
static MD *cur_m;
static MD *cur_env_md;

long xexec(WORD flag, char *path, char *tail, char *env)
{
    PD *p;
    PGMHDR01 hdr;
    MD *m, *env_md;
    LONG rc;
    long max, needed;
    FH fh;

#if DBGPROC
    char buf[10];
    display_string("BDOS: xexec - flag or mode = ");
    ltoa(buf, (long)flag, 10);
    display_string(buf);
    display_string("\r\n");
#endif

    /* first branch - actions that do not require loading files */
    switch(flag) {
    case PE_BASEPAGEFREE:
        /* set the owner of the memory to be this process */
        p = (PD *) tail;
        set_owner(p, p, find_mpb(p));
        set_owner(p->p_env, p, find_mpb(p->p_env));
        /* fall through */
    case PE_BASEPAGE:        
        /* just create a basepage */
        env_md = alloc_env(env);
        if(env_md == NULL) {
#if DBGPROC
            display_string("xexec: Not Enough Memory!\r\n");
#endif
            return(ENSMEM);
        }
        max = (long) ffit(-1L, &pmd); 
        if(max >= sizeof(PD)) {
            m = ffit(max, &pmd);
            p = (PD *) m->m_start;
        } else {
            /* not even enough memory for basepage */
            freeit(env_md, &pmd);
#if DBGPROC
            display_string("xexec: No memory for TPA\r\n");
#endif
            return(ENSMEM);
        }
        /* memory ownership */
        m->m_own = env_md->m_own = run;

        /* initialize the PD */
        init_pd_fields(p, tail, max, env_md);
        init_pd_files(p);

        return (long) p;
    case PE_GOTHENFREE:
        /* set the owner of the memory to be this process */
        p = (PD *) tail;
        set_owner(p, p, find_mpb(p));
        set_owner(p->p_env, p, find_mpb(p->p_env));
        /* fall through */
    case PE_GO:
        p = (PD *) tail;
#if DBGPROC
        display_string("BDOS: xexec - curdrv ");
        ltoa(buf, (long)p->p_curdrv, 10);
        display_string(buf);
        display_string("\r\n");
#endif
#if 1
				flush_cache_pexec(p, path);
#else
#ifdef COLDFIRE
#if (__GNUC__ > 3)
    		asm volatile (" .chip 68060\n\t cpusha BC\n\t .chip 5485\n\t"); /* flush from CF68KLIB */
#else
    		asm volatile (" .chip 68060\n\t cpusha BC\n\t .chip 5200\n\t"); /* flush from CF68KLIB */
#endif
#else /* 68060 */
    		asm volatile (" cpusha BC\n\t");
#endif /* COLDFIRE */
#endif
        proc_go(p);
        /* should not return ? */
        return (long)p;
    case PE_LOADGO:
    case PE_LOAD:
        break;
    default:
        return EINVFN;
    }
    
    /* we now need to load a file */
#if DBGPROC
    display_string("BDOS: xexec - trying to find the command ...\r\n");
#endif
    if (ixsfirst(path,0,0L)) {
#if DBGPROC
        display_string("BDOS: Command ");
        display_string(path);
        display_string(" not found!!!\r\n");
#endif
        return(EFILNF);     /*  file not found      */
    }

    /* load the header - if IO error occurs now, the longjmp in rwabs will
     * jump directly back to bdosmain.c, which is not a problem because
     * we haven't allocated anything yet.
     */
    rc = kpgmhdrld(path, &hdr, &fh);
    if(rc) {
#if DBGPROC
        char buf[10];
        display_string("BDOS: xexec - kpgmhdrld returned  ");
        ltoa(buf, rc, 10);
        display_string(buf);
        display_string(" (0x");
        ltoa(buf, rc, 16);
        display_string(buf);
        display_string(")\r\n");
#endif
        return(rc);
    }

    /* allocate the environment first, always in ST RAM */
    env_md = alloc_env(env);
    if ( env_md == NULL ) {
#if DBGPROC
        display_string("xexec: Not Enough Memory!\r\n");
#endif
        return(ENSMEM);
    }
    
    /* allocate the basepage depending on memory policy */
    needed = hdr.h01_tlen + hdr.h01_dlen + hdr.h01_blen + sizeof(PD);
    max = 0;
        
    /* first try */
    p = NULL;
    m = NULL;
    if(has_ttram && (hdr.h01_flags & PF_TTRAMLOAD)) {
        /* use ttram preferably */
        max = (long) ffit(-1L, &pmdtt); 
        if(max >= needed) {
            m = ffit(max, &pmdtt);
            p = (PD *) m->m_start;
        } 
    }
    /* second try */
    if(p == NULL) {
        max = (long) ffit(-1L, &pmd); 
        if(max >= needed) {
            m = ffit(max, &pmd);
            p = (PD *) m->m_start;
        } 
    }
    /* still failed? free env_md and return */
    if(p == NULL) {
#if DBGPROC
        display_string("xexec: No memory for TPA\r\n");
#endif
        freeit(env_md, &pmd);
        return(ENSMEM);
    }
//    assert(m != NULL);

    /* memory ownership - the owner is either the new process being created,
     * or the parent 
     */
    if(flag == PE_LOADGO) {
        m->m_own = env_md->m_own = p;
    } else {
        m->m_own = env_md->m_own = run;
    }   

    /* initialize the fields in the PD structure */
    init_pd_fields(p, tail, max, env_md);
    
    /* set the flags (must be done after init_pd) */
    p->p_flags = hdr.h01_flags;

    /* use static variable to avoid the obscure longjmp warning */
    cur_p = p;
    cur_m = m;
    cur_env_md = env_md;

    /* we have now allocated memory, so we need to intercept longjmp. */
    memcpy(bakbuf, errbuf, sizeof(errbuf));
    if ( setjmp(errbuf) ) {
#if DBGPROC
        display_string("Error and longjmp in xexec()\r\n");
#endif

        /* free any memory allocated yet */
        freeit(cur_env_md, &pmd);
        freeit(cur_m, find_mpb((void *)cur_m->m_start));
        
        /* we still have to jump back to bdosmain.c so that the proper error
         * handling can occur.
         */
        longjmp(bakbuf, 1);
    }

    /* now, load the rest of the program and perform relocation */
    rc = kpgmld(cur_p, fh, &hdr);
    if ( rc ) {
#if DBGPROC
        char buf[10];
        display_string("BDOS: xexec - kpgmld returned ");
        ltoa(buf, rc, 10);
        display_string(buf);
        display_string(" (0x");
        ltoa(buf, rc, 16);
        display_string(buf);
        display_string(")\r\n");
#endif
        /* free any memory allocated yet */
        freeit(cur_env_md, &pmd);
        freeit(cur_m, find_mpb((void *)cur_m->m_start));
    
        return rc;
    }

    /* at this point the program has been correctly loaded in memory, and 
     * more IO errors cannot occur, so it is safe now to finish initializing
     * the new process.
     */
    init_pd_files(cur_p);
      
    /* invalidate instruction cache for the TEXT segment only
     * programs that jump into their DATA, BSS or HEAP are kindly invited 
     * to do their cache management themselves.
     */
#if DBGPROC
    display_string("BDOS: xexec - invalidate_icache");
#endif
//    invalidate_icache(((char *)cur_p) + sizeof(PD), hdr.h01_tlen);
#if 1
		flush_cache_pexec(cur_p, path);
#else
#ifdef COLDFIRE
#if (__GNUC__ > 3)
    asm volatile (" .chip 68060\n\t cpusha BC\n\t .chip 5485\n\t"); /* flush from CF68KLIB */
#else
    asm volatile (" .chip 68060\n\t cpusha BC\n\t .chip 5200\n\t"); /* flush from CF68KLIB */
#endif
#else /* 68060 */
    asm volatile (" cpusha BC\n\t");
#endif /* COLDFIRE */
#endif

    if(flag != PE_LOAD)
        proc_go(cur_p);
    return (long) cur_p;
}

/* initialize the structure fields */
static void init_pd_fields(PD *p, char *tail, long max, MD *env_md)
{
    int i;
    char *b;
   
    /* first, zero it out */
    _bzero(p, sizeof(PD)) ;

    /* memory values */
    p->p_lowtpa = (long) p;                /*  M01.01.06   */
    p->p_hitpa  = (long) p  +  max;        /*  M01.01.06   */
    p->p_xdta = &p->p_cmdlin[0];   /* default p_xdta is p_cmdlin */
    p->p_env = (char *) env_md->m_start;

    /* copy tail */
    b = &p->p_cmdlin[0];
    for( i = 0 ; (i < PDCLSIZE)  && (*tail) ; i++ )
        *b++ = *tail++;

    *b++ = 0;
}

/* duplicate files */
static void init_pd_files(PD *p)
{
    int i;
    
    /* inherit standard files from me */
    for (i = 0; i < NUMSTD; i++) {
        WORD h = run->p_uft[i];
        if ( h > 0 )
            ixforce(i, h, p);
        else
            p->p_uft[i] = h;
    }

    /* and current directory set */
    for (i = 0; i < 16; i++)
        ixdirdup(i,run->p_curdir[i],p);

    /* and current drive */
    p->p_curdrv = run->p_curdrv;
#if DBGPROC
    {
        char buf[10];
        display_string("BDOS: init_pd_files curdrv ");
        ltoa(buf, (long)p->p_curdrv, 10);
        display_string(buf);
        display_string("\r\n");
    }
#endif
}

/* allocate the environment, always in ST RAM */
static MD *alloc_env(char *env)
{
    MD *env_md;
    int size;

    /* determine the env size */
    if (env == NULL)
        env = run->p_env;
    size = (envsize(env) + 1) & ~1;  /* must be even */
 
    /* allocate it */
    env_md = ffit((long) size, &pmd);
    if ( env_md == NULL ) {
        return NULL;
    }

    /* copy it */
    memcpy((void *)(env_md->m_start), env, size);
    
    return env_md;
}

/* proc_go launches the new process by creating the right data
 * structure in memory, then pretending resuming from an ordinary
 * BDOS call by calling gouser().
 * 
 * Here is an excerpt of gouser() from rwa.S:
 * _gouser:
 *   move.l  _run,a5
 *   move.l  d0,0x68(a5)
 *   move.l  0x7c(a5),a6     // stack pointer (maybe usp, maybe ssp)
 *   move.l  (a6)+,a4        // other stack pointer
 *   move.w  (a6)+,d0
 *   move.l  (a6)+,a3        // retadd
 *   movem.l (a6)+,d1-d7/a0-a2
 *   btst    #13,d0
 *   bne     retsys          // a6 is (user-supplied) system stack
 *   move.l  a4,sp
 *   move.l  a6,usp
 * gousr:  
 *   move.l  a3,-(sp)
 *   move    d0,-(sp)
 *   movem.l 0x68(a5),d0/a3-a6
 *
 */

struct gouser_stack {
  LONG other_sp;   /* a4, the other stack pointer */
  WORD sr;         /* d0, the status register */
  LONG retaddr;    /* a3, the return address */
  LONG fill[11];   /* 10 registers d1-d7/a0-a2 and one dummy so that ... */
  PD * basepage;   /* ... upon startup the basepage is in 4(sp) */
};

static void proc_go(PD *p)
{
    struct gouser_stack *sp;

#if DBGPROC
    display_string("BDOS: xexec - trying to load (and execute) a command ...\r\n");
#endif
    p->p_parent = run;
        
    /* create a stack at the end of the TPA */
    sp = (struct gouser_stack *) (p->p_hitpa - sizeof(struct gouser_stack));
    
    sp->basepage = p;      /* the stack contains the basepage */
       
    sp->retaddr = p->p_tbase;    /* return address a3 is text start */
#ifdef NETWORK
#ifdef LWIP
    {
        extern void install_auto_breakpoint(long address);
        install_auto_breakpoint(p->p_tbase);
    }
#endif
#endif
    sp->sr = 0;                  /* the process will start in user mode */
    
    /* the other stack is the supervisor stack */
    sp->other_sp = (long) &supstk[SUPSIZ];
    
    /* store this new stack in the saved a7 field of the PD */
    p->p_areg[7-3] = (long) sp;
    
#if 1
    /* the following settings are not documented, and hence theoretically 
     * the assignments below are not necessary.
     * However, many programs test if A0 = 0 to check if they are running
     * as a normal program or as an accessory, so we need to clear at least
     * this register!
     */
    {   /* d1-d7/a0-a2 and dummy return address set to zero */
        int i;
        for(i = 0; i < 11 ; i++) 
            sp->fill[i] = 0;
    }
    p->p_areg[6-3] = (long) sp;    /* a6 to hold a copy of the stack */
    p->p_areg[5-3] = p->p_dbase;   /* a5 to point to the DATA segt */
    p->p_areg[4-3] = p->p_bbase;   /* a4 to point to the BSS segt */
#endif
    
    /* the new process is the one to run */
    run = (PD *) p;

    gouser();
}



/*
 * x0term - (p_term0 - 0x00)Terminate Current Process
 *
 * terminates the calling process and returns to the parent process
 * without a return code
 */

void    x0term(void)
{
    xterm(0);
}

/*
 * xterm - terminate a process
 *
 * terminate the current process and transfer control to the colling
 * process.  All files opened by the terminating process are closed.
 *
 * Function 0x4C        p_term
 */

void    xterm(UWORD rc)
{
    PD *p = run;

    (* (WORD(*)(void)) Setexc(0x102, (long)-1L))(); /*  call user term handler */
    run = run->p_parent;
		slb_close_on_exit(p);
    ixterm(p);
    /* gouser() will store the current value of D0 in the active PD
     * so it cannot be used here. See proc_go() above.
     * termuser() will enter the gouser() code at the proper place.
     * sep 2005 RCL
     */
    run->p_dreg[0] = rc;
    termuser();
}


/*      
 * xtermres - Function 0x31   p_termres
 */

WORD    xtermres(long blkln, WORD rc)
{
    xsetblk(0,run,blkln);
    reserve_block(run, find_mpb(run));
    xterm(rc);
}

/*
 * mark_users
 *
 * Helper function that (un)marks a process as user of a shared library.
 *
 * Input:
 * sl: The SLB's descriptor
 * pd: The PD to be (un)marked
 * setflag: Mark (1) or unmark (0) the process as user
 */
 
static void mark_users(SHARED_LIB *sl, PD *pd, int setflag)
{
	int i;
	for (i=0;i<MAXPD;i++)
	{
		if (sl->slb_users[i] == pd)
		{
			if (!setflag)
				sl->slb_users[i]=0;
			return;
		}
	}
	if (setflag)
	{
		for (i=0;i<MAXPD;i++)
		{
			if (!sl->slb_users[i]) /* free */
			{
				sl->slb_users[i]=pd;
				return;
			}
		}
	}
}

/*
 * is_user
 *
 * Helper function that checks whether a process is user of a shared library.
 *
 * Input:
 * sl: The SLB's descriptor
 * pd: The PD in question
 *
 * Returns:
 * 0: Process is not user of the SLB
 * 1: Process is user of the SLB
 */
 
int is_user(SHARED_LIB *sl, PD *pd)
{
	int i;
	for (i=0;i<MAXPD;i++)
	{
		if (sl->slb_users[i] == pd)
			return(1);	
	}
	return(0);
}

/*
 * slb_close_on_exit
 *
 * Helper function that gets called whenenver a process terminates. It then
 * closes any shared library the process might haven't closed.
 *
 */
 
static void slb_close_on_exit(PD *p)
{
	SHARED_LIB *slb;
	/* Is curproc user of a shared library? */
	for (slb = slb_list; slb; slb = slb->slb_next)
	{
		if (is_user (slb, p))
		{
			slb->slb_used--;
			mark_users(slb, p, 0);
		}		
		if (slb->slb_used <= 0)
		{
#if DBGPROC
			display_string("BDOS: pterm: slb_exit()\r\n");
#endif
			slb->slb_head->slh_slb_exit();
			slb->slb_name[0] = 0;
			remove_slb(slb);
		}
	}
}

static void remove_slb(SHARED_LIB	*slb_remove)
{
	SHARED_LIB	*slb;
	SHARED_LIB	*last = NULL;
	for (slb = slb_list; slb; slb = slb->slb_next)
	{
		if (slb == slb_remove)
			break;
		last = slb;
	}
	if (slb == NULL)
		return;
	if (last)
		last->slb_next = slb->slb_next;
	else
		slb_list = slb->slb_next;
	xmfree(slb->slb_region);
}

/*
 * load_and_init_slb
 *
 * Helper function for xslbopen(); loads and initializes a shared library.
 *
 * Input:
 * (See xslbopen())
 *
 * Returns:
 * 0: SLB has been successfully loaded and initialized
 * Otherwise: GEMDOS error
 */
 
static long load_and_init_slb(char *name, char *path, long min_ver, SHARED_LIB **sl)
{
	long r, hitpa, *exec_longs;
	char fullpath[1024];
	PD *b;
 	long mr;
	/* Construct the full path name of the SLB */
	copy(path,fullpath);
	r = length(fullpath);
	if(fullpath[r-1] != '\\')
	{
		fullpath[r] = '\\';
		fullpath[r+1] = 0;
	}
	cat(name,fullpath);
	/* Create the new shared library structure */
	mr = xmxalloc(sizeof(SHARED_LIB) + length(name), MX_PREFTTRAM);
	if (mr == 0)
	{
#if DBGPROC
		display_string("BDOS: slbopen: Couldn't get region for new SHARED_LIB structure\r\n");
#endif
		return(ENSMEM);
	}
	*sl = (SHARED_LIB *)mr;
	_bzero(*sl, sizeof(SHARED_LIB));
	(*sl)->slb_region = mr;
	/* Load, but don't run the SLB */
	r = xexec(PE_LOAD, fullpath, fullpath, 0L);
	if (r <= 0L)
	{
#if DBGPROC
		display_string("BDOS: slbopen: Couldn't create basepage\r\n");
#endif
		xmfree(mr);
		return(r);
	}
	b = (PD *)r;
	/* Test for the new program format */
	exec_longs = (long *)b->p_tbase;
	if (exec_longs[0] == 0x283a001aL && exec_longs[1] == 0x4efb48faL)
		(*sl)->slb_head = (SLB_HEAD *)(b->p_tbase + 228);
	else
		(*sl)->slb_head = (SLB_HEAD *)b->p_tbase;
	/* Check the magic value */
	if ((*sl)->slb_head->slh_magic != SLB_HEADER_MAGIC)
	{
#if DBGPROC
		display_string("BDOS: slbopen: SLB is missing the magic value\r\n");
#endif
		r = EPLFMT;
		goto slb_error;
	}
	/* Check the name */
	if (stricmp((*sl)->slb_head->slh_name, name))
	{
#if DBGPROC
		display_string("BDOS: slbopen: name mismatch\r\n");
#endif
		r = EFILNF;
		goto slb_error;
	}
	/* Check the version number */
	(*sl)->slb_version = (*sl)->slb_head->slh_version;
	if ((*sl)->slb_version < min_ver)
	{
#if DBGPROC
		char buf[10];
		display_string("BDOS: slbopen: SLB is version ");
		ltoa(buf, (*sl)->slb_version, 10);
		display_string(buf);
		display_string(", requested was ");
		ltoa(buf, min_ver, 10);
		display_string(buf);
		display_string("\r\n");
#endif
		r = ERANGE;
		goto slb_error;
	}
	/* Shrink the TPA to the minimum, including stack for init */
	hitpa = (long)b + 256 + b->p_tlen + b->p_dlen + b->p_blen + SLB_INIT_STACK;
	if (hitpa < b->p_hitpa)
	{
		b->p_hitpa = hitpa;
		r = xsetblk(0, (void *)b, b->p_hitpa - (long)b);
		if (r)
		{
#if DBGPROC
			display_string("BDOS: slbopen: Couldn't shrink basepage\r\n");
#endif
			goto slb_error;
		}
	}
	else if (hitpa > b->p_hitpa)
	{
#if DBGPROC
		display_string("BDOS: slbopen: Warning: SLB uses minimum TPA\r\n");
#endif
	}
	/* Run the shared library, i.e. call its init() routine. */
#if DBGPROC
	display_string("BDOS: slbopen: slb_init()\r\n");
#endif
	r = (*sl)->slb_head->slh_slb_init();
	if (r < 0L)
	{
#if DBGPROC
		display_string("BDOS: slbopen: slb_init() error\r\n");
#endif
slb_error:
		xmfree(mr);
		xmfree((long)b);
		return(r);
	}
	/*
	 * Fill the shared library structure 
	 */
	copy(name, (*sl)->slb_name);
	(*sl)->slb_next = slb_list;
	slb_list = *sl;
	return(0);
}

/*
 * xslbopen
 *
 * Implementation of Slbopen().
 *
 * Input:
 * name: Filename of the shared library to open/load (without path)
 * path: Path to look for name; if NULL, the lib is searched through SLBPATH.
 * min_ver: Minimum version number of the library
 * sl: Pointer to store the library's descriptor in
 * fn: Pointer to store the pointer to the library's execution function in
 *
 * Returns:
 * <0: GEMDOS error code, opening failed
 * Otherwise: The version number of the opened SLB
 *
 * Function 0x16        slbopen
 */
 
long xslbopen(char *name, char *path, long min_ver, SHARED_LIB **sl, SLB_EXEC *fn)
{
	SHARED_LIB *slb;
	long r;
#if DBGPROC
	char buf[10];
	display_string("BDOS: slbopen: path: ");
	display_string(path);
	display_string(", name: ");
	display_string(name);
	display_string(", version ");
	ltoa(buf, min_ver, 10);
	display_string(buf);
	display_string("\r\n");
#endif
	/* No empty names allowed */
	if (!*name)
	{
#if DBGPROC
		display_string("BDOS: slbopen: Empty name\r\n");
#endif
		return(EACCDN);
	}
	/* Check whether this library is already in memory */
	for (slb = slb_list; slb; slb = slb->slb_next)
	{
		if (!stricmp(slb->slb_name, name))
			break;
	}
	if (slb)
	{
		/* If yes, check the version number */
		if (slb->slb_version < min_ver)
		{
#if DBGPROC
	    char buf[10];
			display_string("BDOS: slbopen: Already loaded library is version ");
			ltoa(buf, slb->slb_version, 10);
			display_string(buf);
			display_string(", requested was ");
			ltoa(buf, min_ver, 10);
			display_string(buf);
			display_string("\r\n");
#endif
			return(ERANGE);
		}
		/* Ensure curproc hasn't already opened this library */
		if (is_user(slb, run))
		{
#if DBGPROC
			display_string("BDOS: slbopen: Library was already opened by this proccess\r\n");
#endif
			return(EACCDN);
		}
		*sl = slb;
	}
	else
	{
		/* Library is not available, try to load it */
		r = -1;
		if (path)
			r = load_and_init_slb(name, path, min_ver, sl);
		if (!path || (r < 0))
		{
			path = getenv(run, "SLBPATH");
			if (!path)
				path = ".\\";
			r = load_and_init_slb(name, path, min_ver, sl);
		}
		if (r < 0L)
		{
#if DBGPROC
			display_string("BDOS: slbopen: Could not open shared library\r\n");
#endif
			return(r);
		} 
		slb = *sl;
	}
#if DBGPROC
	display_string("BDOS: slbopen: slb_open()\r\n");
#endif
	r = slb->slb_head->slh_slb_open(run);
	if (r <0L)
	{
#if DBGPROC
		display_string("BDOS: slbopen: slb_open() error\r\n");
#endif		
	}
	mark_users(slb, run, 1);
	slb->slb_used++;
	*fn = (SLB_EXEC)slb_exec;
	return(slb->slb_version);
}

/*
 * xslbclose
 *
 * Implementation of slbclose().
 *
 * Input:
 * sl: The descriptor of the library to close
 *
 * Returns:
 * 0: Library has been closed
 * Otherwise: GEMDOS error code
 *
 * Function 0x17        slbclose
 */

long xslbclose(SHARED_LIB *sl)
{
	SHARED_LIB *slb;
#if DBGPROC
	display_string("BDOS: slbclose\r\n");
#endif
	/* Now try to find the structure in the global list */
	for (slb = slb_list; slb; slb = slb->slb_next)
	{
		if (slb == sl)
			break;
	}
	if (slb == NULL)
	{
#if DBGPROC
		display_string("BDOS: slbclose: Library structure not found\r\n");
#endif
		return(EIHNDL);
	}
	/* Check whether curproc is user of this SLB */
	if (!is_user(slb, run))
	{
#if DBGPROC
		display_string("BDOS: slbclose: Process is not user of this SLB\r\n");
#endif
		return(EACCDN);
	}
	slb->slb_used--;
	mark_users(slb, run, 0);
#if DBGPROC
	display_string("BDOS: slbclose: slb_close()\r\n");
#endif
	slb->slb_head->slh_slb_close(run);
	if (slb->slb_used <= 0)
	{
#if DBGPROC
		display_string("BDOS: pterm: slb_exit()\r\n");
#endif
		slb->slb_head->slh_slb_exit();
		slb->slb_name[0] = 0;
		remove_slb(slb);
	}
	return(0);
}

