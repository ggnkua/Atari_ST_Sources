#include	<mt_mem.h>
#include	<PORTAB.H>
#include	<TOS.H>
#include	<MT_AES.H>
#include	<STDIO.H>

#include	"Thread.h"

/*-----------------------------------------------------------------------------*/
/* Globale Variablen                                                           */
/*-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
extern	void cdecl	setstack( void * );

void	cdecl WaitThreadAppId( LONG Pid )
{	return;}

static void cdecl	init_function (BASPAG *P)
{
    threadfun *fun = (threadfun *) P->p_dlen;
    setstack ((void *)((long)P->p_hitpa - 4));
/*	Psemaphore( 2, 'THR ', -1 );	*/
    Pterm (fun (P->p_blen));
}

int	DOThread (threadfun *fun, long arg, long stksize, char *name )
{
    BASPAG *b;

    b = (BASPAG *) Pexec (5, 0L, "", 0L);
    Mshrink (0, b, stksize + sizeof (BASPAG));
    b->p_tbase = init_function;
    b->p_tlen = stksize + sizeof (BASPAG);

    b->p_blen = arg;
    b->p_dlen = (long)fun;
    b->p_hitpa = (char *)b + stksize + sizeof (BASPAG);
    
	return(( int ) Pexec( 104, name, b, 0 ));
}
