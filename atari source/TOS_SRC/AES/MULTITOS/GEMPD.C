/*	GEMPD.C			9/25/90			D.Mui		*/
/*	Change at get_pd	9/25/90			D.Mui		*/
/*	Convert to Lattice C 5.51	02/16/93	C.Gee		*/
/*	Force the use of prototypes	02/23/93	C.Gee		*/

/*	-----------------------------------------------------------
*	AES Version 4.0	MultiTOS version is written by Derek M. Mui
*	Copyright (C) 1992 
*	Atari (U.S.) Corp
*	All Rights Reserved
*	-----------------------------------------------------------
*/	

/*
*	-------------------------------------------------------------
*	GEM Application Environment Services		  Version 1.1
*	Serial No.  XXXX-0000-654321		  All Rights Reserved
*	Copyright (C) 1985			Digital Research Inc.
*	-------------------------------------------------------------
*/
#include "pgem.h"
#include "pmisc.h"

#include "machine.h"
#include "dispvars.h"
#include "mintbind.h"


EXTERN	WORD	gl_multi;
EXTERN	OBJECT	*gl_wtree;
EXTERN	PD	*alr;
EXTERN	WORD	shutdown;
EXTERN	OBJECT	*mn_addr;
EXTERN	WORD	mn_maxitem;
EXTERN	WORD	gl_mkind;
EXTERN	MFORM	gl_cmform;

GLOBAL	WORD	gl_curpid;	/* current next available pid */

/*	Find the accessory process id accroding to the	*/
/*	Menu Register Item number or accid number	*/

	WORD
facc( which )	
	WORD	which;
{
	REG PD	*p;

	p = plr;
	
	while ( p )
	{
	  if ( p->p_state != PS_DEAD )
	  {
	    if ( ( p->p_type & AESACC ) && ( p->p_accid == which ) )
	      return( p->p_pid );
	  }

	  p = p->p_thread;
	}

	return( -1 );
}	


/*	Look for the process name and return process pointer	*/

	PD
*fpdnm( pname, pid )
	BYTE		*pname;
	UWORD		pid;
{
	BYTE		temp[PSNAME+1];
	BYTE		temp1[PSNAME+1];
	REG PD		*p;

	if ( pname != NULLPTR )
	{
	  temp1[PSNAME] = temp[PSNAME] = NULL;	  
	  movs(PSNAME, pname, temp1 );
	  upperstr( temp1 );	
	}

	p = plr;

	while( p )
	{
	  if ( pname != NULLPTR )
	  {
	    movs(PSNAME, p->p_name, temp );
	    if ( strcmp( temp1, temp ) )
	      break;
	  }
	  else
	    if ( p->p_pid == pid )
	       break;

	  p = p->p_thread;
	}

	return( p );
}


/*	Convert id to PD address	*/

	PD		
*idtopd( id )
	WORD	id;
{
	return( fpdnm( NULLPTR, id ) );
}



/*	Free all the PDs		*/

	VOID
freepds( VOID )
{
	REG PD	*p;
	PD	*p1;

	p = plr;

	while( p )
	{
	  p1 = p->p_thread;
	  dos_free( ( LONG )p );
	  p = p1;
	}
}



/*	Free a PD	*/

	VOID
free_pd( p )
	PD	*p;
{
	REG PD	*p1;
	LONG	*ptr;

	if ( plr )		/* find the process on the thread pointer */
	{
	  p1 = plr;
	  if ( p == p1 )	/* at the head	*/
	    plr = p->p_thread;
	  else
	  {
	    while( p1 )			/* unlink it from the middle of	*/
	    {				/* the list			*/
	      if ( p1->p_thread == p )
	      {
		p1->p_thread = p->p_thread;
		break;
	      }

	      p1 = p1->p_thread;
	    }	
	  }

	  Debug7( p->p_name );
	  Debug7( "'s pd is freed\r\n" );
	  if (!gl_multi && ( p->p_type & AESACC ) && 
	  ( ptr = ( LONG *)p->p_baseaddr ) )
     	  {				
		 if ( ptr[11] )		/* free envr string	*/
		 	dos_free( ptr[11] );
	 	 dos_free( ( LONG )p->p_baseaddr );	/* free progra, space	*/	
	  }
	  dos_free( ( LONG )p );
	}
}


/*	Name the process	*/

	VOID
p_nameit(p, pname)
	PD		*p;
	BYTE		*pname;
{
 	WORD i;
 	BYTE c;
 
	bfill(PSNAME, ' ',  &p->p_name[0]);
	/* someone could send us a long name, don't copy the whole thing */
 	/* ++ERS 2/11/93 */
 
 	for (i = 0; i < PSNAME; i++)
 	{
 	  c = *pname++;
 	  if (c == '.' || c == 0) break;
 	  p->p_name[i] = c;
 	}
}


/*	Allocate a new process pointer			*/
/*	The process id can't be a negative number	*/

	PD 
*xget_pd( name, type )
	BYTE	*name;
	WORD	type;
{
	PD		*p;
	REG PD		*p1;

	if ( p1 = ( PD *)dos_xalloc( (LONG)sizeof( PD ), 0x23 ) )	/* alloc memory	*/
	{
	  bfill( sizeof( PD ), 0 , ( BYTE *)p1 );	/* clean up	*/
	  					/* initalize it	*/
	  p1->p_qaddr = &p1->p_queue[0];
	  p1->p_qindex = 0;
	  p1->p_uda = &p1->p_udarea;
	  p1->p_uda->u_spsuper = ( BYTE *)&p1->p_udarea.u_supstk;
	  p1->p_uda->u_insuper = 1;

	  p_nameit( p1, name );
	  p1->p_state = PS_NEW;
	  p1->p_type = type;			/* Application */
/*
	  if ( type == AESSYSTEM )
	    p1->p_state = PS_RUN;
*/
	  p1->p_prvstate = p1->p_state;
	  p1->p_mouse.mokind = gl_mkind;
	  p1->p_mouse.moform = gl_cmform;
	  p1->p_newdesk = ( BYTE *)gl_wtree;
	  p1->p_newroot = 0;
	  p1->p_prgname[0] = ' ';	/* name for the menu bar	*/
	  p1->p_prgname[1] = ' ';
	  p1->p_accid = -1;
	  p1->p_ppid = -1;
	  p1->p_mobj = -1;
	  p1->p_tick = 2;	/* give them 2 ticks to count down this	*/
				/* is to prevent process continue to	*/
				/* run in PS_ALLRUN state		*/
#if 0
	  strcpy( name, &p1->p_prgname[2] );
#else
 	  nstrcpy( name, &p1->p_prgname[2], 13 );
#endif
	  Debug7( p1->p_name );
	  Debug7( "allocated at " );
	  Ndebug7( (LONG) p1 );

	  if ( gl_curpid < 0 )		/* negative number? 	*/
	    gl_curpid = 0;	
 
	  if ( !( p = plr ) )
	    plr = p1;
	  else
	  {
	    while( p )
	    {
	      if ( p->p_pid == gl_curpid )
	      {
		gl_curpid++;
		p = plr;
	      }
	      else
	      {
	 	if ( !p->p_thread )
		{
		  p->p_thread = p1;
	 	  break;
		}
		else
		  p = p->p_thread;	
	      }
	    }	
	  }
	
	  p1->p_pid = gl_curpid++;
	  if (!gl_multi)
	    p1->p_sysid = p1->p_pid;
	  link_tail( &alr, p1 );	/* start up processes list */

	  Debug1( p1->p_name );
	  Debug1( " is created\r\n" );

	}/* allocation OK */

	return( p1 );
}


/*	Get pd with checking	*/

	PD
*get_pd( name, type )
	BYTE	*name;
	WORD	type;
{
	if ( ( shutdown ) || ( mn_addr->ob_tail >= mn_maxitem ) )
	  return( (PD*)0 );

	return( xget_pd( name, type ) );
}


/*	Set a process and make it executable	*/

	PD
*pstart( px, pcode, ldaddr )
	REG PD		*px;
	WORD		(*pcode)( PD *, BYTE * );	/* first line of code	*/
	BYTE		*ldaddr;	/* load address		*/
{
	if (gl_multi)
	{
	  px->p_textaddr = ldaddr;
	  px->p_sysid = (*pcode)( px, ldaddr );
	} else {
	  px->p_textaddr = (BYTE *)pcode;
	  px->p_baseaddr = ldaddr;
/*	  px->p_sysid was set up along with the PD */
	}
	return( px );
}
