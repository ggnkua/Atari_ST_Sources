/*	GEMCLI.C		2/21/91			D.Mui		*/
/*	Crunch at ldaccs	3/18/88			D.Mui		*/
/*	Take out sysacc define		2/11/88		D.Mui		*/
/*	Fix at ldaccs .. load accessory from root  10/23/85 D.Mui	*/
/*	Fix at ldaccs for *.acc file	09/09/85	Derek Mui	*/
/*	Fix at ldaccs for no disk 	08/28/85	Derek Mui	*/
/*	Change ldaccs	07/15/85 - 07/16/85	Derek Mui		*/
/*	Reg Opt		03/09/85		Derek Mui		*/
/*	to 68k		02/22/85 - 05/20/85	LKW			*/
/*	GEMCLI.C	1/28/84 - 02/02/85	Lee Jay Lorenzen	*/
/*	Make used_acc as global	7/16/90		D.Mui			*/
/*	Start the process in to be suspended state 8/9/90	D.Mui	*/
/*	Big change at ldaccs() sndcli()		9/25/90		D.Mui	*/
/*	Convert to Lattice C 5.51		2/17/93		C.Gee	*/
/*	Force the use of prototypes		2/24/93		C.Gee	*/

/*	-----------------------------------------------------------
*	AES Version 4.0	MultiTOS version is written by Derek M. Mui
*	Copyright (C) 1992 
*	Atari (U.S.) Corp
*	All Rights Reserved
*	-----------------------------------------------------------
*/	

/*
*	-------------------------------------------------------------
*	GEM Application Environment Services		  Version 1.0
*	Serial No.  XXXX-0000-654321		  All Rights Reserved
*	Copyright (C) 1985			Digital Research Inc.
*	-------------------------------------------------------------
*/
#include "pgem.h"
#include "pmisc.h"

#include "machine.h"
#include "dispvars.h"
#include "mintbind.h"

EXTERN	PD	*alr;
EXTERN	WORD	gl_multi;
EXTERN	WORD	(*runacc)(PD *, BYTE *);
EXTERN	WORD	mn_maxitem;
EXTERN	BYTE	*ad_shcmd;
EXTERN	THEGLO	D;
EXTERN	BYTE	*ad_envrn;
EXTERN	WORD	sh_accflag;

GLOBAL	WORD	used_acc;
GLOBAL	BYTE	STACCFULL[] = "C:\\*.ACC";
GLOBAL	BYTE	STACC[] = "*.ACC";
GLOBAL	BYTE	ACCPATH[] = "ACCPATH=";

#define PSETFLAGS	(('P'<< 8) | 4)
#define PGETFLAGS	(('P'<< 8) | 5)


/*	Convert the mint id into U:\proc\X.???	*/

	VOID	
mint_name( id, buf2 )
	WORD	id;	
	BYTE	*buf2;
{
	BYTE		ext[4];
	BYTE		ext2[4];
	WORD		i;

	lbintoasc( (LONG)id, ext );
	strcpy( "000", ext2 );
	i = strlen( ext );
	strcpy( ext, &ext2[3 - i] );
	strcpy( "U:\\proc\\X.", buf2 );
	strcat( ext2, buf2 );
}


	VOID
ps_rename( id, name, special )
	WORD	id,special;
	BYTE	*name;
{
	BYTE	buf1[26];
	BYTE	buf2[26];
	WORD	handle,i;
	LONG	flags;
	BYTE	ext[4];
	BYTE	ext2[4];


	if (!gl_multi)
		return;

	lbintoasc( (LONG)id, ext );
	strcpy( "000", ext2 );
	i = strlen( ext );
	strcpy( ext, &ext2[3-i] );
	strcpy( "U:\\proc\\", buf1 ); 	/* set up the new name	*/
	strcat( name, buf1 );
	strcpy( ext2, scasb( buf1, '.' ) + 1 );	
	
	mint_name( id, buf2 );		/* get the system name	*/

	dos_rename( buf2, buf1 );

	if ( special )
	{
	  handle = dos_open( buf2, 0 );
	  if ( handle < 0 )
	  {
	    bailout( "AES error! Please destroy this copy!\r\n" );
	    return;
	  }
	  Fcntl( handle, &flags, PGETFLAGS );
	  flags &= ~0xf0L;		/* clear out existing protection mode */
	  flags |=  0x20L;		/* write in new prot mode: Super */
	  flags |= 0x00008000L;	/* set the F_OS_SPECIAL bit */
	  Fcntl( handle, &flags, PSETFLAGS );
	  dos_close( handle );
	}
}


/*
*	Routine to load program file pointed at by pfilespec, then
*	create new process context for it.  This uses the load overlay
*	function of DOS.  The room for accessories variable will be
*	decremented by the size of the accessory image.  If the
*	accessory is too big to fit it will be not be loaded.
*/

	PD
*sndcli( pfilespec, tail, envrn, show )
	REG BYTE	*pfilespec;
	BYTE		*tail,*envrn;
	WORD		show;
{
	WORD		handle;
	LONG		*ldaddr;
	REG PD		*p;
	BYTE		*name;



	strcpy( pfilespec, ad_shcmd );	/* very important */
	name = sh_name( ad_shcmd );		

	if ( p = get_pd( name, AESACC ) )
	{
	  if ( ( handle = dos_open( pfilespec, 0 ) ) >= 0 )
	  {			/* allocate PD memory for 	*/	
	  			/* accessory Pexec 3		*/
	    dos_close( handle );
	    if ( show ) {
	      if (!gl_multi)
		      sh_accflag = TRUE;		/* do not redraw whole screen when launching accs. */
	      sh_draw( pfilespec );
	      if (!gl_multi)
		      sh_accflag = FALSE;	
	    }

	    if ( pgmld( ad_shcmd, &ldaddr, tail, envrn ) != -1 )	
	    {
/*	      p->p_state = PS_ALLRUN;*/	/* run until event wait		*/
	      p->p_baseaddr = ( BYTE *)ldaddr;
	      if (gl_multi) {
	        p->p_textaddr = ( BYTE *)ldaddr[2];/* real text segment		*/
	        ldaddr[2] = ( LONG )runacc;
	        if ( ( p->p_sysid = dos_pexec( 106, 0x0L, ( BYTE *)ldaddr, 0x0L ) ) >= 0 )
	        {				/* converts X.??? number into name.id */
		  Psetpgrp( p->p_sysid, p->p_sysid );
		  ps_rename( p->p_sysid, name, 0 );
		  strcpy( pfilespec, p->p_where );
		  strcpy( tail, p->p_wtail );
	          return( p );
	        } 
	      } else {
  		  pstart(p, runacc, (BYTE *) ldaddr);
		  ps_rename( p->p_sysid, name, 0 );
		  strcpy( pfilespec, p->p_where );
		  strcpy( tail, p->p_wtail );
		  used_acc++;
	          return( p );
	      }
	    }
	  }
	    
	  unlink_pd( &alr, p );
	  free_pd( p );
	}


	return( (PD*)0 );
}


/*
*	Routine to load in desk accessory's.  Files by the name of *.ACC
*	will be loaded, if there is sufficient room for them in the system.
*	If SYSTEM.ACC is not zero, it is treated as the beginning of a
*	desk accessory in system rom and is executed.
*	The cartridge is searched for *.ACC and each one is executed.
*	If there is any space left, *.ACC etc. are then loaded from disk.
*	It will first try the hard disk, if there is no acc files then it
*	will go back to the boot drive.
*/


	VOID
ldaccs( VOID )
{
	WORD		ret,i;
	WORD		defdrv;
	BYTE		name[60];
	BYTE		rspath[128];
	BYTE		blank[2];

	LSTCPY( rspath, STACCFULL );
	blank[0] = ' ';
	blank[1] = 0;

	dos_dta( ( LONG )name );	/* set the DMA address		*/
				/* get the boot device		*/
	defdrv = *((WORD*)0x446L );
#if 0	
	defdrv = dos_gdrv();	/* save the default drive	*/

	if ( isdrive() )
	{
	  if ( isdrive() & 0x04 )
	     dos_sdrv( 0x04 );	/* set the hard disk	*/
				/* search the file	*/
	  dos_chdir( "\\" );

	  if ( !( ret = dos_sfirst( rspath, 0 ) ) )
	  {
	    dos_sdrv( defdrv );	/* restore default drive*/
	    dos_chdir("\\");	/* always at root	*/
	    ret = dos_sfirst( rspath, 0 );
	  }
	}
	else
	  ret = FALSE;
#endif

	rspath[0] = defdrv + 'A';
	dos_setdir( rspath, 0 );
	strcpy( rspath, ad_shcmd );  
	ret = dos_sfirst( ( LONG )rspath, 0 );
	Debug1( "ACC first try to load from " );
	Debug1( rspath );
	Debug1( "\r\n" );


	if ( !ret )		/* try the ACCPATH	*/
	{
	  LSTCPY( rspath, STACC );

	  if ( (ret = sh_find( ( LONG )rspath, ( WORD(*)())NULLPTR, ACCPATH, TRUE ) ) )
	  {
/*	    dos_setdir( rspath, 0 );	*/
	    Debug1( "ACC is loading from -> " ); 
	    Debug1( rspath );
	    Debug1( "\r\n" );
	  }
	}

	if ( ret )
	{
	  dos_setdir( rspath, 0 );
	  ret = dos_sfirst( ( LONG )rspath, 0 );
	  i = 0;

	  while( ( ret ) && ( i < ( mn_maxitem - 4 ) ) )
  	  {
	    PD *p;
	    waitforaes();
	    p = sndcli( &name[30], "", (BYTE *)ad_envrn, TRUE );
	    releaes();
	    if ( p )
	      i++;		/* increment number of accessory count	*/
	    else
	      break;

	    if ( !( ret = dos_snext() ) )
	      sh_draw( blank );
	  }
	}

	dos_sdrv( defdrv );	/* restore default drive*/
}


/*	Free the accessories	*/

	VOID
free_accs( VOID )
{
	PD	*p;
	LONG	*ptr;

	p = plr;

	while( p )
	{
	  if ( p->p_type & AESACC )
		free_pd(p);
	  if ( ptr = ( LONG *)p->p_baseaddr )
	  {				
	    if ( ptr[11] )		/* free envr string	*/
	      dos_free( ptr[11] );
	    dos_free( ( LONG )p->p_baseaddr );	/* free progra, space	*/	
	  }
	  p = p->p_thread;
	}
}


/*	Give everyone a chance to run, at least once	*/

	VOID
all_run()
{
	WORD		i;
	PD		*p;

	p = rlr; 
	i = used_acc;
	while (p) {
		i++;
		p = p->p_link;
	}
	for(; i ; i-- )
	  yieldcpu();
						/* then get in the wait	*/
						/*   line		*/
	wm_update(TRUE);
	wm_update(FALSE);	
}

	VOID
accwait()
{
	PD	*p;
	WORD	flag;

	Debug1("Enter accwait\r\n");
	do {
		flag = FALSE;
		for (p = plr; p; p = p->p_thread) {
			if ((p->p_type & AESACC) && (p != currpd)) {
				if (p->p_qindex > 0) {
					Debug1(p->p_name);
					Debug1(": has message\r\n");
					flag = TRUE;
					ev_timer(20); /* kick AES */
					break;
				}				
			}
		}
	} while (flag);
	Debug1("Exit accwait\r\n");

}

#if 0
WORD	scanq(p)
PD	*p;
{
	if (p->p_qindex > 0)
		return TRUE;
	else
		return FALSE;

}
#endif
