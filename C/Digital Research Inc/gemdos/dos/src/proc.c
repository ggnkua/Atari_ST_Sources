/*  proc.c - process management routines				*/
/*  xexec, xterm, x0term, xtermres					*/

/*
**  mods
**
**  mod no.	date       who	comments
**  ---------	---------  ---	--------
**  M01.01.01	22 Oct 85  ktb	split up mem.c
**
**  M01.01.02	22 Oct 85  ktb	changed var 'long *p;' to 'PD *p;', since that
**				seems to be what it is used for. (not marked)
**
**  M01.01.03	22 Oct 85  ktb	added var 'p1' to aid portability.
**
**  M01.01.04	23 Oct 85  ktb	removed var 'int absflg;', 'int j;';
**		Not used.
**
**  M01.01.05	23 Oct 85  ktb	initialized var 'env' & 'm' to keep lint quite.
**
**  M01.01.06	13 Nov 85  ktb	proper usage of pointer variables.
**
**  M01.01.07	18 Nov 85  ktb	no one was ever decrementing diruse
**
**  see fsdir.c for a meaningless explanation of the following mod #'s
**
**  M01.01.SCC.MEM.02 - M01.01.07 change
**
**  M0101082701  27 Aug 86 ktb	cleaned up some unecessary code
**
**  M0101082702  27 Aug 86 ktb	cleaned up code that sizes env
**
**  M0101082703  27 Aug 86 ktb	unessecary extra pointer, use cast instead.
**
**
*/

#include	"gportab.h"
#include	"fs.h"
#include	"bios.h"				/*  M01.01.02	*/
#include	"mem.h"
#include	"gemerror.h"
#include	"btools.h"

#define	DBGPROC	0

#ifndef	M0101082701
#define	M0101082701	1
#endif

#ifndef	M0101082702
#define	M0101082702	1
#endif


/*
**  run - ptr to PD for current process
*/

GLOBAL	PD	*run;


/*
**  supstk - common sup stack for all procs  
*/

GLOBAL	int	supstk[SUPSIZ];		


/*
**  bakbuf - longjump buffer
*/

GLOBAL	long	bakbuf[3];


/*  
**  xexec - execute a new process
**	Function 0x4B	p_exec
**
** 	flag = 0: load&go, 3:load/nogo, 4:justgo, 5:create psp 
** 	load&go(cmdlin,cmdtail), load/nogo(cmdlin,cmdtail), justgo(psp) 
** 	create psp - user receives a memory partition 
**
*/


long	xexec(flg,s,t,v) 
	int flg;			/*  0, 3, 4, or 5		*/
	char *s,*t,*v; 			/* command, tail, environment	*/
{	
	PD	*p;
	char	*b, *e;
	int	i, h;			/*  M01.01.04		*/
	int	cnt ;			/*  M0101082702		*/
	long	rc, max;
	MD	*m, *env;
	long	*spl;
#if	!M0101082703
	int	*spw;
#endif

	m = env = 0L ;

	/*
	**  check validity of flg - 1,2 or >5 is not allowed
	*/

	if(   flg && (  flg < 3 || flg > 5  )    )
		return(EINVFN);

	/*
	**  if we have to load, find the file
	*/

	if ((flg == 0) || (flg == 3))
		if (ixsfirst(s,0,0L))
			return(EFILNF);		/*  file not found	*/

	xmovs(sizeof(errbuf),errbuf,bakbuf);

	if (rc = setjmp(errbuf))
	{
		if (rc != E_CHNG)
			longjmp(bakbuf,rc);

		 /* we allocated memory in a previous incarnation */

		if (flg != 4)
		{
			freeit(m,&pmd);
			freeit(env,&pmd);
		}

		longjmp(bakbuf,rc);
	}

	/* will we need memory and a psp ? */

	if (flg != 4)
	{	/* get largest memory partition available */

		if (!v)
			v = run->p_env;

		/*
		**  determine minimum
		*/

#if	M0101082702
		i = envsize( v ) ;
		if( i & 1 ) 			/*  must be even	*/
			++i ;
#else

		for (e = v, i = 0; ; i++)
		{
			if (!(*e++))
				if (!(*e++))
					break;
				else
					i++;	/* add an extra */
		}

		i += 2;			/*  count the double nulls	*/

		if (i & 1)		/*  make an even number		*/
			i += 1;
#endif
		/*
		**  allocate environment
		*/

		if (!(env = ffit((long) i,&pmd)))
		{
#if	DBGPROC
			kprintf("xexec: Not Enough Memory!\n\r") ;
#endif
			return(ENSMEM) ;
		}

		e = (char *) env->m_start;

		/* 
		**  now copy it 
		*/

		bmove( v , e , i ) ;


		/* 
		**  allocate base page
		*/

		max = (long) ffit( -1L , &pmd ) ;	/*  amount left */

		if( max < sizeof(PD) )
		{	/*  not enoufg even for PD  */
			freeit(env,&pmd);
#if	DBGPROC
			kprintf("xexec: No Room For Base Pg\n\r") ;
#endif
			return(ENSMEM);	
		}

		/*  allocate the base page.  The owner of it is either the
			new process being created, or the parent  */

		m = ffit(max,&pmd);

		p = (PD *) m->m_start;		/*  PD is first in bp	*/

#if	M0101082701
		env->m_own =  flg == 0 ? p : run ;
		m->m_own = env->m_own ;
#else
		m->m_own = 			/*  set owner of bp	*/
		  env->m_own = (  ((flg == 0) || (flg == 4)) ?  p : run  );
#endif
		max = m->m_length;		/*  length of tpa	*/

		/*
		**  We know we have at least enough room for the PD (room 
		**	for the rest of the pgm checked for in pgmld)
		**  initialize the PD (first, by zero'ing it out)
		*/


#if	1
		bzero( (char *) p , sizeof(PD)  ) ;
#else
		for( i = sizeof(PD) , b = (char*) p ; i-- ; *b++ = 0  )
			;
#endif

		p->p_lowtpa = (long) p ;		/*  M01.01.06	*/
		p->p_hitpa  = (long) p  +  max ;	/*  M01.01.06	*/
		p->p_xdta = &p->p_cmdlin[0] ;	/* default p_xdta is p_cmdlin */
		p->p_env = (char *) env->m_start ;


		/* now inherit standard files from me */

		for (i = 0; i < NUMSTD; i++)
		{
			if ((h = run->p_uft[i]) > 0)
				ixforce(i,run->p_uft[i],p);
			else
				p->p_uft[i] = h;
		}

		/* and current directory set */

		for (i = 0; i < 16; i++)
			ixdirdup(i,run->p_curdir[i],p);

		/* and current drive */

		p->p_curdrv = run->p_curdrv;

		/* copy tail */

		b = &p->p_cmdlin[0] ;
		for( i = 0 ; (i < PDCLSIZE)  && (*t) ; i++ )
			*b++ = *t++;

		*b++ = 0;
		t = (char *) p;
	}

	/* 
	**  for 3 or 0, need to load, supply baspage containing: 
	** 	tpa limits, filled in with start addrs,lens 
	*/

	if((flg == 0) || (flg == 3)) 
		if (rc = xpgmld(s,t))
		{
#if	DBGPROC
			kprintf("cmain: error returned from xpgmld = %lx\n\r",
				rc) ;
#endif
			ixterm(t);			
			return(rc);
		}

	if ((flg == 0) || (flg == 4))
	{
		p = (PD *) t;
		p->p_parent = run;
		spl = (long *) p->p_hitpa;
		*--spl = (long) p;
		*--spl = 0L; /* bogus retadd */

		 /* 10 regs (40 bytes) of zeroes  */

		for (i = 0; i < 10; i++)
			*--spl = 0L;

		*--spl = p->p_tbase; /* text start */
#if	!M0101082703
		spw = (int *) spl;
		*--spw = 0; /* startup status reg */
		spl = (long *) spw;
#else
		*--(WORD *)spl = 0 ;
#endif
		*--spl = (long) &supstk[SUPSIZ];
		p->p_areg[6-3] = p->p_areg[7-3] = (long) spl;
		p->p_areg[5-3] = p->p_dbase;
		p->p_areg[4-3] = p->p_bbase;
		run = (PD *) p;

#if	M0101082701
		gouser() ;
#else
		if (flg != 5)
			gouser();
#endif
	}

	/* sub-func 3 and 5 return here */

	return( (long) t );
}

/*
** [1]	The limit on this loop should probably be changed to use sizeof(PD)
*/


#if	M0101082702
/*
**  envsize - determine size of env area
**	counts bytes starting at 'env' upto and including the terminating
**	double null.
*/

int	envsize( env )
	char	*env ;
{
	REG char	*e ;
	REG int 	cnt ;

	for( e = env, cnt = 0 ; !(*e == NULL && *(e+1) == NULL) ; ++e, ++cnt )
		;

	return( cnt + 2 ) ;		/*  count terminating double null  */
}
#endif


/*
**  x0term - Terminate Current Process
**	terminates the calling process and returns to the parent process
**	with a return code of 0 (success).
**
**	Function 0x00	p_term0
*/

VOID	x0term()					/* SCC  18 Mar 85 */
{							/* SCC  18 Mar 85 */
	xterm(0);					/* SCC  18 Mar 85 */
}							/* SCC  18 Mar 85 */

/*
**  xterm - terminate a process
**	terminate the current process and transfer control to the colling
**	process.  All files opened by the terminating process are closed.
**
**	Function 0x4C	p_term
*/

VOID	xterm(rc)
	unsigned int	rc;
{
	PD *r;

	(* (int(*)()) trap13(5,0x102,-1L))() ;	/*  call user term handler */

	run = (r = run)->p_parent;
	ixterm( r );
	run->p_dreg[0] = rc;
	gouser();
}


/*	
**  xtermres - 
**	Function 0x31	p_termres
*/

int	xtermres(blkln,rc)
	int	rc;
	long	blkln;
{
	MD *m,**q;

	xsetblk(0,run,blkln);

	for (m = *(q = &pmd.mp_mal); m ; m = *q)
		if (m->m_own == run)
		{
			*q = m->m_link; /* pouf ! like magic */
			xmfreblk(m);
		}
		else
			q = &m->m_link;

	xterm(rc);
}	



/*
**  ixterm - terminate a process
**	terminate process with PD 'r'.
*/

VOID	ixterm( r )
	PD	*r;		/*  PD of process to terminate		*/
{
	REG MD	*m, 
		**q;
	REG int	h;
	REG int	i;

	/*  check the standard devices in both file tables  */

	for( i = 0 ; i < NUMSTD ; i++ )
		if( (h = r->p_uft[i]) > 0 )
			xclose(h);

	for (i = 0; i < OPNFILES; i++)
		if (r == sft[i].f_own)
			xclose(i+NUMSTD);


	/*  check directory usage  M01.01.07 */

	for( i = 0 ; i < NUMCURDIR ; i++ )
	{
		if( (h = r->p_curdir[i]) != 0 )
			diruse[h]-- ;
	}

	/*
	**  for each item in the allocated list that is owned by 'r', 
	**	free it
	*/

	for( m = *( q = &pmd.mp_mal ) ; m ; m = *q )
	{
		if (m->m_own == r)
		{
			*q = m->m_link;
			freeit(m,&pmd);
		}
		else 
			q = &m->m_link;
	}
}

