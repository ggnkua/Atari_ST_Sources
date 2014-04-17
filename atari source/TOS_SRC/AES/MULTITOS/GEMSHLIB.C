/*	GEMSHLIB.C	4/18/84 - 01/07/85	Lee Lorenzen		*/
/*	68k		2/18/85 - 05/28/85	Lowell Webster		*/
/*	International 	07/19/85		Derek Mui		*/
/*	french		08/08/85		Mike Schmal		*/
/*	Increase buffer size to 16 at sh_envrn	Derek Mui		*/
/*	Fix at sh_find to look for file at root dir 10/25/85	D.Mui	*/
/*	Check error after dos_exec only for PRG file 10/29/85	D.Mui	*/
/*	Change to solid background for low medium res 11/08/85  D.Mui	*/
/*	Kludge at sh_envrn	11/12/85	Nobody			*/
/*	Update solid background	at sh_main	2/3/86	Derek Mui	*/
/*	change mouse form before showing the mouse sh_tographic		*/
/*						2/7/86	Derek Mui	*/
/*	Set the button semaphore when leaving desktop	2/27/86 D.Mui	*/
/*	Fix at the sh_main to fix the cart exect problem 3/18/86 D.Mui  */
/*	Added sh_rom for reading rom only once 	3/19/86			*/
/*	Take out sh_fixtail so it won't upper case the tail 4/2/86 D.Mui*/
/*	Fix at sh_main for no solid background in high res  4/7/86 D.Mui*/
/*	Fix the sh_rom, read the rom cart once	7/1/86	Derek Mui	*/
/*	Added sh_iscart for cart program 	7/1/86	Derek Mui	*/
/*	Fix at cart entry point			7/2/86	Derek Mui	*/
/*	Auto boot application	12/22/87 - 12/23/87	D.Mui		*/
/*	Rewrite sh_main	1/12/88 - 1/14/88		D.Mui		*/
/*	Rewrite sh_find, sh_envrn, sh_path				*/
/*	1/28/88 - 1/29/88				D.Mui		*/
/*	Added sh_spath	2/2/88				D.Mui		*/
/*	Change the set path befor dos_exec 4/29/88	D.Mui		*/
/*	Sh_write to do forking			4/30/91	D.Mui		*/
/*	Added sh_spath			4/30/91		D.Mui		*/
/*	Change the sh_path to accept new environment name 3/12/92	*/
/*	Fix at sh_envrn for overshooting the buffer	3/13/92	D.Mui	*/ 
/*	Shel_write will look for PATH if current file not found		*/
/*	3/24/92						D.Mui		*/
/*	Convert to Lattice C 5.51	02/12/93	C.Gee		*/
/*	Force to use prototypes		02/22/93	C.Gee		*/

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
#include "objaddr.h"
#include "dispvars.h"
#include "gemdos.h"
#include "message.h"
#include "osbind.h"
#include "aesmint.h"
#include "rslib.h"
#include "signal.h"
#include "gemusa.h"

EXTERN	LONG	trap();

EXTERN	WORD	gl_rschange;
EXTERN	UWORD	a_rezword;
EXTERN	UWORD	b_rezword;
EXTERN	WORD	gl_multi;
EXTERN	WORD	gl_width;
EXTERN	WORD	gl_height;
EXTERN	WORD	gl_handle;
EXTERN	WORD	biosfd;
EXTERN	WORD	consfd;
EXTERN	USERBLK	*aesDDD;			/* in GSXIF.C		*/
EXTERN	LONG	gl_vdo;
EXTERN	WORD	gl_restype;
EXTERN	PD	*shutpd;
EXTERN	PD	*alr;
EXTERN	PD	*scr_pd;
EXTERN	WORD	aesid;
EXTERN	WORD	gl_hchar;
EXTERN	WORD	gl_wchar;
EXTERN	WORD	gl_ncols;
EXTERN	WORD	gl_nrows;
EXTERN	WORD	ctldown;
EXTERN	BYTE	Nostr[];
EXTERN	WORD	gl_bpend;	
EXTERN	GRECT	gl_rscreen;
EXTERN	LONG	ad_sysglo;
EXTERN	LONG	ad_stdesk;
EXTERN	THEGLO	D;
EXTERN	PD	*gl_mowner;
EXTERN	OBJECT	*mn_addr;
EXTERN	WORD	mn_maxitem;
EXTERN	PD	*shellpd;
EXTERN	BYTE	SHELL[];
EXTERN  BYTE	ARGV[];
EXTERN	BYTE	ACCPATH[];

EXTERN	WORD	adeskp[];		/* in GEMINIT.C */
EXTERN	WORD	awinp[];

EXTERN	WORD	gl_nplanes;		/* in APGSXIF.C */

EXTERN	WORD	spdid;

GLOBAL	WORD	envsize;
GLOBAL	BYTE	*ad_envrn;
GLOBAL	BYTE	*ad_shcmd;		/* Shell command buffer	*/
GLOBAL	BYTE	*ad_shtail;		/* Shell command tail	*/
GLOBAL	LONG	ad_path;
GLOBAL	WORD	sh_iscart;		/* cart program 	*/
GLOBAL	WORD	sh_graphic;
GLOBAL	WORD	sh_accflag;		/* Used for sh_draw to not redraw whole */
					/* screen when launching Accs.		*/
					/* See sendcli() in gemcli.c		*/

GLOBAL	WORD	sh_inwrite;		/* Only for single tasking mode!	*/
					/* Flag set when application other than	*/
					/* the DESKTOP did a sh_write. If flag	*/
					/* set sh_write will launch specified	*/
					/* application after the current prg.	*/
					/* terminated. This flag is also tested	*/
					/* in swap_next() in GEMDISP.C. This is */
					/* done to prevent the menu bar to 	*/
					/* change to the DESKTOP's menu bar	*/
					/* during the process of launching the	*/
					/* next application.			*/
					
BYTE		sh_xpath[CMDLEN];		/* auxially path buffer	*/
BYTE		sh_xtail[CMDLEN];
WORD		sh_xisgem;

PD		*saveshpd;			/* used in sh_exec() */

GLOBAL	WORD	shutdown;	/* system in shutdown mode	    */
GLOBAL	WORD	reschid;	/* process that requests res chg */
GLOBAL	WORD	st_redraw;	/* start up redraw mode		*/
GLOBAL	WORD	dy_redraw;	/* terminate redraw mode	*/
GLOBAL	LONG	shel_magic;

GLOBAL	BYTE	DEFPATH[]= "PATH=C:\\";
GLOBAL	BYTE	PATHEQUAL[] = "PATH=";
GLOBAL	BYTE	GEMEXT[] = "GEMEXT=";
GLOBAL	BYTE	TOSEXT[] = "TOSEXT=";
GLOBAL	BYTE	ACCEXT[] = "ACCEXT=";
GLOBAL	BYTE	TOSRUN[] = "TOSRUN=";

/*
 *	Count the size of the environment strings
 *	Including the NULL NULL at the end
 */	

	UWORD
sh_len( path )
	REG BYTE	*path;
{
	UWORD	len;

	len = 0;

	do
	{
	  len++;

	  if ((!*path) && ( !*(path+1)))
	  {
	    len++;
	    break;
	  }

	  path++;
		  
	}while(TRUE);

	return( len );
}



/*	Build an ARGV type environment and append to in the
 *	existing AES environment path
 *	The first byte of the tail will have 0x7F
 *	to indictae the ARGV presents in the environment.
 * 	We need to assume that the command tail argument are 
 *	seperated by space and ends with a NULL
 */	
	BYTE
*sh_argv( file, tail )
	BYTE	*file,*tail;
{
	UWORD		len,len1,i;
	BYTE		*addr;
	REG BYTE	*ptr;

	if ( tail[0] )
	{
	  if ( len = strlen( &tail[1] ) )
	    len += 1;		/* include the ending zero */
	  else
	    return ( (BYTE*)0 );	
	}
	else
	  return( (BYTE*)0 );	
					/* remove old ARGV= */
	sh_write( 8, 1, 0, ARGV, (BYTE*)0 );

	len1 = sh_len( ad_envrn );

	if ( addr = ( BYTE *)dos_xalloc( (LONG)( len + len1 + strlen( file ) 
				+ strlen( ARGV ) + 8 ), 3 ) ) 
	{
	  tail[0] = 0x7F;
	  LBCOPY( addr, ad_envrn, len1 );/* copy the original env stuff */
	  ptr = strcpy( ARGV, &addr[len1-1] );
	  ptr = strcpy( file, ptr );
	  tail++;		/* points to actual tail	*/	

	  for ( i = 0; i < len; i++ )
	  {
	    if ( tail[i] == ' ' )
	      *ptr = 0;
	    else
	      *ptr = tail[i];

	    ptr++;
	  }
	  *ptr++ = 0;
	  *ptr = 0;
	}

	return( addr );
}


/*	Check for change of resolution	*/

	WORD
sys_reschange( res )
	WORD	res;
{
	if ( res == gl_restype )
	{
	  return( FALSE );	
	}
	gl_restype = res;
	gl_rschange = TRUE;
	return( TRUE );
}


/*	Set Resolution change	*/

	WORD
sh_reschg( mode, res )
	WORD	mode, res;
{
	WORD	ret;

	ret = FALSE;
				/* if no one claims reschange */
	if ( ( !reschid ) || ( reschid == currpd->p_pid ) )	
	{
	  if ( ( mode == 1 ) && ( ( gl_vdo & HIGHWORD ) == FALCON ) &&
		 ( res != a_rezword ) )
	  {
	    gl_rschange = ret = TRUE;	/* OK to do res change	*/
	    b_rezword = res;		/* new res	*/	
	  }

	  if ( ( !mode ) && ( res != gl_restype ) )
	    ret = sys_reschange( res );
	}
	if ( ret )
	  reschid = currpd->p_pid;

	return( ret );
}

/*
 * close all accessories
 */
	VOID
close_accs()
{
	PD *p1;
	WORD code = 0;	/* dunno if this is right */

	p1 = plr;
	while( p1 )
	{
	  if ( (p1->p_type & AESACC) && currpd != p1 )
	  {
	    
	    wm_clspd( p1, TRUE ); 	  
	    ap_sendmsg( AC_CLOSE, p1->p_pid, p1->p_accid, p1->p_accid, 
			code, 0, 0 );	    
	  }
	  p1 = p1->p_thread;
	}
	all_run();
	accwait();
}

/*	Set the system into shutdown mode
*	isgem -1 to check to see if the current process can do shut down
*	isgem 0 to abort shutdown
*	isgem 1 to partially shutdown mode - accessories still alive
*	isgem 2 to completely shutdown - nothing left but screen and AES
*/

	WORD
sh_shutdown( isgem, code )
	WORD	isgem,code;
{
	REG PD	*p1;
	WORD	ret;

	switch( isgem )
	{
	  case -1:		/* check mode	*/
	    if ( shutdown )
	    {	
	      if ( currpd != shutpd )
		return( FALSE );	
	    } 		
	    return( TRUE );
	
	  case 0:	
	    if ( !shutdown )	/* if not in shutdown mode */
	      return( FALSE );
	    else
	    {			/* Don't shut down system	*/
	      if ( currpd == shutpd )
	      {
	        shutdown = FALSE;
	        shutpd = (PD*)0;	
	        return( TRUE );
	      }
	      else
	        return( FALSE );
	    }
	    break;

	  case 1:
	  case 2:
	    if ( shutdown )	/* if already in shutdown mode */
	    {
	      if ( currpd != shutpd )
	        return( FALSE );/* return error		       */
	      else
	        return( TRUE );
	    }
	    break;

	  default:
	    return( FALSE );
	}

	p1 = plr;
	while( p1 )
	{
	  if ( currpd != p1 )
	  {
	    if ( p1->p_type & AESAPP )
	    {
	      if ( !( p1->p_events & TERM_MSG ) )
	        return( FALSE );
	    }

	    if ( p1->p_type & AESACC )
	    {
	      if ( ( isgem == 2 ) && ( !( p1->p_events & TERM_MSG ) ) )
	        return( FALSE );		  
	    }	
	  }  
	  p1 = p1->p_thread;
	}

	ret = TRUE;
	p1 = plr;
	while( p1 )
	{
	  if ( currpd != p1 )
	  {
	    if ( p1->p_type & AESACC )
	    {
	      wm_clspd( p1, TRUE );	
	      ap_sendmsg( AC_CLOSE, p1->p_pid, p1->p_accid, p1->p_accid, 
		        code, 0, 0 );

	      if ( isgem == 2 )
	        goto s_1;
	    }

	    if ( p1->p_type & AESAPP )
	    {
s_1:	      ret = FALSE;
	      ap_sendmsg( AP_TERM, p1->p_pid, p1->p_pid, 0, code, 0, 0 );
	    }
	  }
	   	  
	  p1 = p1->p_thread;
	}

	if ( ret )
	{
	  ap_sendmsg( SHUT_COMPLETED, currpd->p_pid, 1, 0, 0, 0, 0 );
	  Debug6( "Send shut_completed messag to " );
	  Debug6( currpd->p_name );
	  Debug6( "\r\n" );
	}
	
	shutpd = currpd;
	shutdown = TRUE;
	return( TRUE );	
}



/*	Broadcast a message to every process in the system	*/	

	WORD	
sh_broadcast( sender, message )
	WORD	sender;
	BYTE	*message;
{
	REG PD	*p;

	p = plr;

	while( p )
	{
	  if ( ( p != scr_pd ) && ( p->p_pid != aesid ) && ( p->p_pid != sender ) )
	    ap_rdwr( AQWRT, p->p_pid, EV_BUFSIZE, message );

	  p = p->p_thread;
	}

	return( TRUE );
}


/*	Routine called everytime dos_find has another path to search */

	VOID
sh_draw( lcmd )
	BYTE	*lcmd;
{
 	REG	LONG	tree;

	gsx_sclip( &gl_rscreen );
	upperstr( lcmd );
	tree = ad_stdesk;
	LLSET( LLGET(OB_SPEC(TITLE)), ( LONG )lcmd );

	if (gl_multi || sh_accflag)
		ob_draw( tree, ASCREEN, MAX_DEPTH );
	else
		ob_draw( tree, 0, MAX_DEPTH );

}


/*
*	Routine to take a full path, and scan back from the end to 
*	find the starting byte of the particular filename
*/
	BYTE
*sh_name(ppath)
	BYTE		*ppath;
{
	REG BYTE	*pname;

	pname = ppath;
	while( *pname++ )
	;

	do {
	    --pname;
	} while ( (pname >= ppath) && (*pname != '\\') && (*pname != ':') );

	return( ++pname );
}

#if 0
	VOID
execBP( PD *p, BYTE *basepage )
{
	WORD i;
	WORD pid = p->p_pid;

	i = dos_pexec(6, 0L, basepage, 0L);
Debug7("Back from pexec()\r\n");
        if ( !forkq( (WORD(*)())pdterm, ( ((LONG)pid)<<16 ) | i ) )  
  	{
	  Debug1( "Failed to register terminate\r\n" );
	}
Debug7("Back from forkq()\r\n");
}
#else
extern VOID execBP(BYTE *, BYTE *);
#endif

/*	New routine to launch an application	*/

	WORD
sh_fork( program, tail, envrn )
	BYTE	*program,*tail,*envrn;
{
	PD	*p;
	LONG	i;
	BYTE	*bptr;
	BYTE	savechr;
	WORD	msgbuf[8];

	if ( p = get_pd( sh_name( program ), AESAPP ) )
	{
	  Debug1( "Shel exec -> " );
	  Debug1( program );
	  Debug1( "\r\n" );

	  p->p_ppid = currpd->p_pid;	  

	  Debug1( "Tail length -> " );
	  Ndebug1( (LONG)tail[0] );

	  if ( tail[0] )
	  {
	    Debug1( "->" );
	    Debug1( &tail[1] );
	    Debug1( "<-\r\n" );
	  }
	  else
	    Debug1( "No tail\r\n" );

	  Debug7( "Environment: -> " );

	  bptr = envrn;
	  while( *bptr )
	  {
	    Debug7( bptr );	
	    Debug7( "\r\n" );
	    i = strlen( bptr ) + 1;
	    bptr += i;
	  }

	  Debug1( "Run dos_exec\r\n" );

	  LBCOPY( p->p_where, program, CMDLEN );
	  LBCOPY( p->p_wtail, tail, CMDLEN );	

	  /* just in case the tail is longer than 128 byte */	
	  
	  savechr = tail[CMDLEN-1];
	  tail[CMDLEN-1] = 0;
		
	  if (gl_multi)
	  {
    	    i = dos_pexec( 100, program, tail, envrn );
	  }
	  else
	  {
	    Debug1("Free memory: "); Ndebug1((LONG)dos_xalloc(-1L, 3));
	    i = dos_pexec( 3, program, tail, envrn );
	  }
	  tail[CMDLEN-1] = savechr;
	  Debug1( "After dos_exec\r\n" );

	  if ( i < 0L )	/* fail */
	  {
	    Debug1( "Dos_pexec fails: error code " );
	    Ndebug1( i );
	    unlink_pd( &alr, p );
	    free_pd( p );
	  }
	  else
	  {
	    if (gl_multi)
	      p->p_sysid = (WORD)i;
	    else
	    {
	/* schedule the child's execution */
		Debug1( "sh_fork: doing pstart\r\n" );
		pstart(p, (BYTE *)execBP, (BYTE *)i);
		Debug1( "sh_fork: after pstart, going into while loop now\r\n" );
	/* now wait for the child to finish */
		if (saveshpd != NULL)
			shellpd = saveshpd;	/* see HACK alert in sh_exec */

		if (!(currpd->p_type & AESSYSTEM)) {
			do {			/* wait for child to finish */
				ev_mesag( (BYTE *) msgbuf );
			} while (msgbuf[0] != CH_EXIT);
		}
		Debug1( "sh_fork: after while loop\r\n" );
		all_run();	/* Make sure SCREEN runs first to */
				/* update the menu bar. */
	    }
	    return( p->p_pid );
	  }
	}

	return( 0 );
}


/*	Set the default shell background	*/

	VOID
sh_background( VOID )
{
	WORD		i;
	WORD		*wptr;
	REG OBJECT	*obj;
						/* get st_desk ptr	*/
	rs_gaddr(ad_sysglo, R_TREE, SCREEN, &ad_stdesk);

	obj = ( OBJECT *)ad_stdesk;

	for( i = 0; i < 3; i++ )
	  obj[i].ob_width = gl_width;

	obj[0].ob_height = gl_height;
	obj[1].ob_height = gl_hchar + 2;	/* this makes it look like menu bar */
	obj[2].ob_height = gl_hchar + 2;

	if ( aesDDD )			/* user defined background	*/
    	{
	  wptr = (WORD *) (&((USERBLK *)aesDDD)->ub_parm);
	  *wptr = gl_handle;	
      	  obj[0].ob_type = G_USERDEF;	
      	  obj[0].ob_spec = ( LONG )aesDDD;		
    	}	
	else
	{
/* we got the max number of colors from the VDI open workstation function
 * when we did gsx_init
 */
	  if (gl_nplanes <= 1)
	    i = 0;
	  else if (gl_nplanes == 2)
	    i = 1;
	  else
	    i = 2;

	  obj[0].ob_spec = 0x00001100L | adeskp[i];
	}
}


/*	Application reads in the command that invokes it	*/

	WORD
sh_read(pcmd, ptail)
	LONG		pcmd, ptail;
{
	LBCOPY( ( BYTE *)pcmd, ad_shcmd, CMDLEN);
	LBCOPY( ( BYTE *)ptail, ad_shtail, CMDLEN);
	return(TRUE);
}



/*	Exec a file	*/

	WORD
sh_exec( doex, isgem, isargv, pcmd, ptail )
	WORD		doex, isgem, isargv;
	BYTE		*pcmd, *ptail;
{
	PD		*p;
	REG WORD	ret;
	WORD		handle,changed,type;
	LONG		*ptr;
	BYTE		*bptr,*envrn,*cptr,*newaddr;
	BYTE		temp;
	UWORD		length;
	BYTE		*dptr;	/* ++ERS 12/10/92 */


	ret = 0;		/* return code, assuming failed  */

	if (doex & 0xEF00)	/* extended mode: note 0x1000 doesn't require
				   the other extensions	*/
	{
	  ptr = ( LONG *)pcmd;		/* This is the file name */
	  pcmd = ( BYTE *)ptr[0];
	}

	/* We will allow the application caller to pass in command tail		*/
	/* longer than 128 bytes in order to create long ARGV environment stuff.*/
	/* In this case, we need to allocate a buffer to do the sh_exec		*/

	newaddr = (BYTE*)0;
	length = CMDLEN;

	if ( ptail[0] == 0xFF )	/* extended length		*/
	{			
	  if ( length = strlen( &ptail[1] ) )
	  {
	    length += 2;	/* two more for leading byte and NULL	*/		
	    if ( newaddr = ( BYTE *)dos_xalloc( (LONG)length, 0x03 ) )
	      ad_shtail = newaddr; 	
	    else
	      return( FALSE );	
	  }
	  else
	    length = CMDLEN;
	}
	
	bfill( CMDLEN, 0, ad_shcmd );	/* clear the buffer	*/
	bfill( length, 0, ad_shtail );
	
	LBCOPY( ad_shcmd, pcmd, CMDLEN );
	LBCOPY( ad_shtail, ptail, length );

	Debug1( "Sh_write of " );
	Debug1( ad_shcmd );
	Debug1( "\r\n" );

	Debug1( "Sh_write tail is " );
	Debug1( ad_shtail );
	Debug1( "\r\n" );

	upperstr( ad_shcmd );		/* set upper case */

	if ( !(ret = sh_xfind( ad_shcmd, PATHEQUAL )))	/* search the file	*/
	{
	  if ( ( (doex & 0x00ff) == 3 ) || ( !(doex & 0x00ff ) ) )
	  {
	    LBCOPY( ad_shcmd, pcmd, CMDLEN );
	    upperstr( ad_shcmd );		/* set upper case */
	    ret = sh_xfind( ad_shcmd, ACCPATH );
	  }
	}

	if ( !ret )
	  goto ex_exit;	

					/* if no type	*/
	if ( (!( doex & 0x00FF )) && ret )
	{
	  if ( ( ret = sh_chktype( ad_shcmd, &type ) ) )
	  {
	    Debug6( "Check file type OK\r\n" );
	    doex |= 1;		/* Assune GEM */
	    isgem = 1;

	    if ( type == 1 )	/* TOS	*/
	    {
	      Debug6( "It is a TOS file\r\n" );
	      isgem = 0;
	    }
	    else
	      if ( type == 2 )	/* ACC	*/
	      {
		doex |= 3;
		Debug6( "It is a ACC file\r\n" );
	      }
	  }
	}


	envrn = ad_envrn;
				/* set default directory*/
	if ( !( doex & 0x0400 ) )
	   dos_setdir( ad_shcmd, 0 );

	if (doex & 0xFF00) /* if high byte is set */
	{
	  if ( doex & 0x0100 )	/* set memory limit	*/
	    Psetlimit( 3, ptr[1] );

	  if ( doex & 0x0400 )	/* set default directory */
	  {
	    if ( ptr[3] )
	    {
	      Debug1( "1 Set default dir at " );
	      Debug1( (BYTE *)ptr[3] ); 	
	      Debug1( "\r\n" );	
	      dos_setdir( ( BYTE *)ptr[3], 1 );
	    }
	    else
	    {
	      dos_setdir( ad_shcmd, 0 );
	      Debug1( "2 Set default dir at " );
	      Debug1( ad_shcmd ); 	
	      Debug1( "\r\n" );	
	    }
	  }

	  if ( doex & 0x0800 )	/* set environment path	*/
	    envrn = ( BYTE *)ptr[4];
	}


	changed = FALSE;

	if ( isargv )		/* create extended ARGV stuff	*/
	{
	  if ( ( ad_envrn == envrn ) && ( ad_shtail[0] ) )
	  {			/* use the bptr just in case it fails */
	    if ( bptr = sh_argv( ad_shcmd, ad_shtail ) )
	    {
	      changed = TRUE;
	      envrn = bptr;
	    }
	  }
	}
 
	switch( doex & 0x00FF )
	{

	  case 1:
	  case 2:
	
	    if ( isgem )		/* run graphic program */
	    {
	      if (gl_multi == 0)
	      {
		/*
		 *  Only the desktop can launch programs instantly
		 *  (doex & 0x1000). Other programs will have to exit
		 *  before they can launch another program.
		 *  --> This is true only for single tasking mode.
		 */
		if (doex & 0x1000) {
			/* H A C K   A L E R T ! ! !
			 * If you launch a DESK.PRG from the ROM
			 * desktop you want it to return to 
			 * DESK.PRG after you ran an application.
			 * With mode 0x1000 we can assume that
			 * the currpd is the desktop (DESK.PRG).
			 * So with setting shellpd to currpd we
			 * make sure that the swap_next in appl_exit
			 * will bring us back to DESK.PRG.
			 * Without the hack, we would get back to 
			 * the ROM desktop since shellpd still
			 * points to it.
			 */
			saveshpd = shellpd;	/* save old shell pd */
			shellpd = currpd;	/* HACK !!! */
			shellpd->p_type |= AESSHELL;

			close_accs();
			mn_bar(0x0L, 0x200);
			/*sh_background(); *no needed* */
			set_desk(scr_pd);
		        sh_draw( sh_name(ad_shcmd) );

			ret = sh_fork( ad_shcmd, ad_shtail, envrn );
			/*
			 * What's going on?
			 * In old TOS, an application had to exit before
			 * an application was launched using shel_write. 
			 * Even the desktop exited. Now in the single
			 * tasking version of MultiTOS the desktop stays
			 * resident and launches appl. using mode 0x1000.
			 * If an application like EasyDraw does a shel_write
			 * we just set a flag (sh_inwrite). When it exits and
			 * we come back from sh_fork and sh_inwrite is set,
			 * we do a sh_fork again, launching the appl. the exited
			 * appl. wanted to launch using sh_write. If sh_inwrite
			 * is not set we simply return to the desktop.
			 * Roger?
			 */ 	
			while (sh_inwrite) {
			        sh_draw( sh_name(ad_shcmd) );
				mn_bar(0x0L, 0x200);
				sh_inwrite = FALSE;
				ret = sh_fork( ad_shcmd, ad_shtail, envrn );
			}	
		} else {
			sh_inwrite = TRUE;
		}
		wm_update(1);
		swap_next( currpd, TRUE );
		w_drawchange(&gl_rscreen, NIL, NIL);
		wm_update(0);
	      } else {
		ret = sh_fork( ad_shcmd, ad_shtail, envrn );
	      }
	    }
	    else			/* run tos program	*/
	    {

	      if (gl_multi == 0)
	      {
		close_accs();
		sh_toalpha();
		ret = sh_fork( ad_shcmd, ad_shtail, envrn );
		sh_tographic();
		gr_arrow( aesid );
		w_drawchange(&gl_rscreen, NIL, NIL);
		break;
	      }
	      if ( ( handle = dos_open( "u:\\pipe\\tosrun", 2 ) ) >= 0 )
	      {				/* put in dir path	*/

		Debug1( "TOSRUN ad_shcmd is " );
		Debug1( ad_shcmd );
		Debug1( "\r\n" );
					/* We need to construct a path	*/
					/* with directory and file path	*/
					/* seperated by space		*/
					/* e.g. c:\mint c:\mint\top.ttp	*/

		if ( doex & 0x0400 )	/* user set directory		*/
	 	  goto ss_3;
		
		bptr = r_slash( ad_shcmd );
		if ( bptr == ad_shcmd )	/* at current directory		*/
		{			/* get current drive		*/	
ss_3:		  D.g_loc2[0] = dos_gdrv();
		  D.g_loc2[1] = ':';
		  D.g_loc2[2] = '\\';
		  dos_gdir( D.g_loc2[0] + 1, ( LONG )&D.g_loc2[2] );
		  D.g_loc2[0] += 'A';		  
		  Debug1( "3 Set dir " );
		  Debug1( &D.g_loc2[0] );
		  Debug1( "\r\n" );
		}
		else
		{	
		  if ( *(bptr-1) == ':' )
	 	    bptr++;
		  
		  temp = *bptr;
		  *bptr = 0;
		  strcpy( ad_shcmd, &D.g_loc2[0] );
		  *bptr = temp;
		}

		strcat( " ", &D.g_loc2[0] );
		strcat( ad_shcmd, &D.g_loc2[0] );
		strcat( " ", &D.g_loc2[0] );
		bptr = ad_shtail;
		if ( bptr[0] == 1 )
		{
		  if ( bptr[1] == 0x0D )
		  {
		    bptr[1] = 0;
		    bptr[0] = 0;
		  }
		}
		bptr[ bptr[0] + 1 ] = 0;

		strcat( &bptr[1], &D.g_loc2[0] );
		Debug1( "TOSRUN write pipe " );
		Debug1( &D.g_loc2[0] );
		Debug1( "\r\n" );
		dos_write( handle, (LONG)(strlen(&D.g_loc2[0])+1), &D.g_loc2[0] );
		dos_close( handle );
		ret = TRUE;
	      }
	      else
	      {
	        sh_envrn( ( LONG *)&cptr, TOSRUN );	
	        if ( cptr )				
	        {
/*
 * Copy the old ad_shcmd over into the first argument
 * slot; to do this, we need to create a new command
 * tail: ERS 12/10/92
 */
		   length += strlen( ad_shcmd ) + 3;
		   dptr = ( BYTE *)dos_xalloc( (LONG)length, 0x03 );
		   if (!dptr)
		     return( FALSE );
		   bfill( length, 0, dptr );
		   dptr[0] = ( BYTE )0xFF;
		   strcpy( ad_shcmd, &dptr[1] );
		   if ( ad_shtail[0] )
		   {
		     strcat( " ", &dptr[1] );
		     strcat( &ad_shtail[1], &dptr[1] );
		   }
		   ad_shtail = dptr;
		   if ( newaddr )
		     dos_free( ( LONG )newaddr );
		   newaddr = dptr;

		   if ( changed )
		   {
		     dos_free( ( LONG )envrn );
		     envrn = ad_envrn;
		     changed = FALSE;
		   }
 		   LBCOPY( ad_shcmd, cptr, CMDLEN );
		   if ( !changed )
		   {
		     if ( ad_shtail[0] )
		     {
		       if ( bptr = sh_argv( cptr, ad_shtail ) )	
		       {	
		         changed = TRUE;
		         envrn = bptr;	
		       }
		       else
		       {
		         ret = FALSE;
		         break;
		       }
		     }
		   }

	           ret = sh_fork( cptr, ad_shtail, envrn );
		   if ( !ret )
		     Debug1( "Shel fork fails\r\n" );
	           break;
	        }/* if cptr */
	      }/* else */
	    }

	    break;

	  case 3:	/* launch accessory */
	    if ( !gl_multi && !(currpd->p_type & (AESSYSTEM|AESSHELL)) )
	    {
	      Debug1("Single tasking ACC launch not permitted\r\n");
	    }
	    else if ( mn_addr->ob_tail < mn_maxitem )
	    {
	      if ( p = sndcli( ad_shcmd, ad_shtail, envrn, FALSE ) )
	      {
	        send_ctrl( p, 1 );	/* put in parent's id	*/
		p->p_ppid = currpd->p_pid;
	        ret = p->p_pid;
	      }
	      else
		Debug1( "Sh_exec 3 fails\r\n" );
	    }
	    break;
	  case 13:	/* start softload desktop in single tasking mode */
		if (!gl_multi) {
			mn_bar(0x0L, 0x200);
			/*sh_background();*/
			set_desk(scr_pd);
			sh_draw( sh_name(ad_shcmd) );
			ret = sh_fork( ad_shcmd, ad_shtail, envrn );
		}
		break;

	}

	if ( changed )
	  dos_free( ( LONG )envrn );

	if ( doex & 0x0100 )
	  Psetlimit( 3, 0x0L );

	if ( ( doex & 0x0200 ) && ret )
	{
	  if ( p = idtopd( ret ) )
	    Prenice( p->p_sysid, (WORD)ptr[2] );
	}

ex_exit:
	if ( newaddr )
	{
	  dos_free( ( LONG )newaddr );	
	  ad_shtail = &D.s_tail[0];	/* reset the command tail buffer */	
	}  	

	Debug1( "Exit sh_exec\r\n" );

/* Don't stay in the subdirectory, or else the kernel will think that
 * the directory is busy: ++ ERS 12/21/92
 */
	if (gl_multi)
	    dos_chdir( (LONG)"\\");

	return( ret );
}




/*  Shel_write, routine to set the next application to run 		

    doexec = 0x??XX

    The XX has the following meanings:

    0 exits and return to desktop	
	     ( ignored )

    1 runs application
     
    2 runs application and set default directory

    3 Launch an accessory		

      New stuff ....

      The ?? is the high 8 bits that have the	
      following meanings:
      bit 0 = set Plimit3
      bit 1 = set Prenice
      bit 2 = set default directory
      bit 3 = set environment string
      bit 4 = undocumented feature for desktop to 
	      launch programs in single tasking mode 
	      (Desktop will stay resident!!!)

	and so on up to 8 settings

      If the high byte of doex is set then the
      pcmd is changed to a pointer points to
      a long array structure which is defined as

      BYTE  *file name
      LONG  Limit on Malloc
      LONG  Renice value ( int )
      BYTE  *Default directory path
	    If the value is NULLPTR, then use the file name path. 	

    4 Set shutdown mode
      - Isgem is the mode, 1 for shutdown, 0 for not shutdown
	
    5 Set resolution change mode	
      - Isgem is the new resolution number

    6 AES mode

    7 Broadcast message

    8 Environment string mode

    9 Message informer

   10 Send message to AES	

*/

	WORD
sh_write(doex, isgem, isover, pcmd, ptail)
	WORD		doex, isgem, isover;
	BYTE		*pcmd, *ptail;
{
	WORD		i;
	WORD		*wptr;
	WORD		buffer[8];
	WORD sa_rezword, sb_rezword, s_restype;

	switch( doex & 0x00FF )
	{
	  case 0:		/* shell write don't care mode */
	  case 1:
/*	  case 2:	*/
	  case 3:

	    if ( !shutdown )
	    {
/*	      Debug1( "Shel_write " );
	      Debug1( pcmd );
	      Debug1( "\r\n" );
*/
	      i = sh_exec(doex,isgem,isover,pcmd,ptail);
	      if ( !i )
		Debug1( "Sh_exec fails\r\n" );

	      return( i );
	    }
	    else
	      break;

	  case 4:	/* shutdown the system */
	    return( sh_shutdown( isgem, AP_TERM ) );

	  case 5:
	    switch( isover )
	    {
	      case 0:
	      case 1:
		sa_rezword = a_rezword;
		sb_rezword = b_rezword;
		s_restype = gl_restype;

	        if ( sh_shutdown( -1, 0 ) )	/* can we shutdown? */
	        {				/* can we change res? */
     		  if ( sh_reschg( isover, isgem ) )/* do the shut down mode */
		  {
	            i = sh_shutdown( 1, AP_RESCHG );
		    if (!i)
		    {
		      a_rezword = sa_rezword;
		      b_rezword = sb_rezword;
		      gl_restype = s_restype;
		    }
		    return i;
		  }
		}			/* res. chg. failed, restore old values */
		a_rezword = sa_rezword;
		b_rezword = sb_rezword;
		gl_restype = s_restype;
	    }

	    return( FALSE );
#if 0	    
	  case 6:		/* AES environment	*/
	    if ( isgem == 1 )	/* Set mode	*/
	    {
	      wptr = pcmd;	/* Default shell installed	*/
	      if ( currpd == shellpd )
	      {
	        shel_magic = *((LONG*)&wptr[1]);
	        buffer[0] = SH_START;
	        buffer[1] = aesid;
	        buffer[2] = 0;
	        buffer[3] = shellpd->p_pid;
	        buffer[6] = LHIWD(shel_magic);
	        buffer[7] = LLOWD(shel_magic);/* broadcast to everyone */	
	        sh_broadcast( currpd->p_pid, buffer );	
		return( TRUE );
	      }	
	      else	
	        return( FALSE );
	    }

	    if ( isgem == 0 )	/* Get mode	*/
	    {	  
	      wptr = pcmd;	/* get the default shell id	*/
	      wptr[0] = ( shellpd ) ? shellpd->p_pid : -1;

		/* magic number set by the default desktop */ 

	      wptr[1] = LHIWD(shel_magic);	
	      wptr[2] = LLOWD(shel_magic);
	      return( TRUE );
	    }
	
	    break;
#endif
	  case 7:		/* Broadcast mode */	
	    return( sh_broadcast( currpd->p_pid, pcmd ) );

	  case 8:
	    if ( isgem == 0 )	/* Inquire size */
	    {
	      i = sh_len( ad_envrn );
	      lbintoasc( (LONG)i, ( BYTE *)buffer );
	      Debug7( "Sh_len -> " );
	      Debug7( (BYTE *)buffer );
	      Debug7( "\r\n" );	
	      return( i );
	    }

	    if ( isgem == 1 )	/* set path	*/
	    {
	      Debug7( "Shell set path -> " );
	      Debug7( pcmd );
	      Debug7( "\r\n" );
	      return( sh_spath( pcmd ) );
	    }
				/* get the buffer */
				/* return number of leftover bytes */
	    if ( isgem == 2 )
	    {
	      i = sh_len( ad_envrn );
	      LBCOPY( pcmd, ad_envrn, ( i > isover ) ? isover : i );
	      return( ( i > isover ) ? ( i - isover ) : 0 );
	    }

	    break;

	  case 9:		/* register message type	*/
	    currpd->p_events = (LONG)((UWORD)isgem);
	    return( 1 );
	
	  case 10:		/* Pass message to AES	*/
	    wptr = ( WORD *)pcmd;
				/* abort the termination sequence */
	    if ( wptr[0] == AP_TFAIL )
	    {
	      if ( shutpd )
	      {
		ap_sendmsg( ( reschid ) ? RESCH_COMPLETED : SHUT_COMPLETED, 
			 	shutpd->p_pid, 0, currpd->p_pid, wptr[1], 0, 0 );

		reschid = 0;
		shutpd = (PD*)0;
		shutdown = 0;
	 	b_rezword = a_rezword;	/* better reset the rezword */
		return( 1 );
	      }	
	    }

	    break;

	  case 11:		/* undocumented feature */
	    if ( isgem == 1 )	/* sleep or wake up	*/
	    {
	      currpd->p_sleep = 0;
	      if ( currpd->p_type & AESSHELL )
		shellpd = currpd;
		
	      wm_update(1);
	
	      if ( wm_top()->cowner != currpd )
	        openphanwind( currpd );

	      setmenu( currpd );
	      set_desk( currpd );
	      wm_update(0); 	
	    } 		 
	    else
	    {
	      if ( !isgem )	/* sleep	*/
	      {
		currpd->p_sleep = 1;
		if ( currpd->p_type & AESSHELL )/* shell go to sleep */
		  shellpd = scr_pd;		/* swap the background */

		swap_next( currpd, FALSE );
	      }
	    }	 	 	

	    break;

	  case 12:		/* undocumented feature to launch desktop */
	    if ( idesk(0) )
	      return( 1 );
	
	    break;

	  case 13:		/* start softload desktop in single tasking mode */
	    if (!gl_multi && !shutdown )
	    {
	      i = sh_exec(doex,isgem,isover,pcmd,ptail);
	      if ( !i )
		Debug1( "Sh_exec fails\r\n" );

	      return( i );
	    }
	    else
	      break;

		
	  default:
	    break;
	}

	return( 0 );
}


/*
*	Shel_get will return the actual number of bytes copied
*	IF len == -1, then returns the size of the buffer
*/

	UWORD
sh_get( pbuffer, len )
	BYTE		*pbuffer;
	UWORD		len;
{
	UWORD		size;
 
	if ( len == -1 )
	  return( D.s_size );

	size = ( len > D.s_size ) ? D.s_size : len;
	LBCOPY( pbuffer, D.s_save, size );
	return( size );
}


/*
*	Shel_put check the incoming size and allocate buffer if it
*	is bigger than the current one
*/
	WORD
sh_put( pdata, len )
	BYTE		*pdata;
	UWORD		len;
{
	BYTE		*addr;
	
	if ( len > D.s_size )
	{
	  if ( addr = ( BYTE *)dos_xalloc( (LONG)len, 3 ) )
	  {
	    dos_free( ( LONG )D.s_save );
	    D.s_save = addr;
	    D.s_size = len;
	  }
	  else
	    return( FALSE );
	} else {
	  D.s_size = len;
	}
	LBCOPY( D.s_save, pdata, len );
	return( TRUE );
}


/*
*	Convert the screen to graphics-mode in preparation for the 
*	running of a GEM-based graphic application.
*/

	WORD
sh_tographic( VOID )
{
	WORD oldsr;

	sh_graphic = TRUE;

	oldsr = spl7();
	retake();				/* retake the gem trap	*/
	spl(oldsr);				/* and error trap	*/
						
	gsx_graphic( TRUE );			/* convert to graphic	*/
	gsx_sclip( &gl_rscreen );		/* set initial clip rect*/
	gsx_malloc();				/* allocate screen space*/
	gr_bee( aesid );			/* put mouse to bee	*/
	ratinit();				/* start up the mouse	*/

	return(TRUE);
}


/*
*	Convert the screen and system back to alpha-mode in preparation
*	for the running of a DOS-based character application.
*/
	WORD
sh_toalpha( VOID )
{
	WORD oldsr;

	sh_graphic = FALSE;

	gr_arrow( aesid );			/* force mouse to arrow */

	oldsr = spl7();
	giveerr();				/* give up gem and 	*/
	spl(oldsr);				/* error trap		*/
						
	ratexit();				/* turn off the mouse	*/
	gsx_mfree();				/* free the blt buffer	*/
	gsx_graphic(FALSE);			/* close workstation	*/

	return(TRUE);
}


/*
*	Search for a particular string in the DOS environment and return
*	a long pointer to the character after the string if it is found. 
*	*psrch includes the '=' character.
*	Otherwise, return a NULLPTR in ppath.	Author unknown
*/

	VOID
sh_envrn( ppath, psrch )
REG	LONG		*ppath;		/* output pointer   */
	BYTE		psrch[];
{
	REG BYTE	*chrptr;
	REG BYTE	*byteptr;

	chrptr = ad_envrn;
						/* double nulls to end	*/
	while( (*chrptr) || (*(chrptr + 1)) )
	{
	  byteptr = psrch;			/* set the start	*/
						/* compare		*/
	  while( (*byteptr) && (*byteptr++ == *chrptr++) )
	  ;
	  if( !(*byteptr) )			/* end of search string */
	  {
	    *ppath = ( LONG )chrptr;
	    return;
	  }
	  else
	  {
	    while( *chrptr++ )	/* skip to the end of this key	*/
	    ;			/* Fixed by D.Mui 3/13/92	*/
	
	    if ( !(*chrptr) )	/* Fixed by D.Mui 3/13/92	*/
	      break;
	  }
	}

	*ppath = 0x0L;				/* failed, return null	*/
}


/*
*	Search first, search next style routine to pick up each path
*	in the PATH= portion of the DOS environment.  It returns the
*	next higher number to look for until there are no more
*	paths to find.
*
*	gemjstrt.s sets the path to PATH=0C:\000 if drive C exists,
*	otherwise it's the default  PATH=0A:\000
*	(unless munged by HINSTALL or an auto folder program)
*/

	WORD
sh_path( whichone, dp, pname, envrn )
	WORD		whichone;
	REG BYTE	*dp;
	REG BYTE	*pname;
	BYTE		*envrn;
{
	REG BYTE	last;
	REG BYTE	*lp;
	REG WORD	i;
	LONG		temp;
	WORD		oldpath = FALSE;

			/* find envrn in the environment which	*/
			/* is a double null-terminated string	*/
	sh_envrn( &temp, envrn );

	if ( !temp )
	  return( FALSE );

	lp = ( BYTE *)temp;

/* This kludge, er, section of code maintains compatibility with
*	the old style PATH=\0<path>\0, to support folks who run an auto-
*	folder environment-setter, and use the old-style PATH environment.
* (880825 kbad)
*/
	if( ! *lp )				/* look for old type env*/
	{					/* by looking for key	*/
	  while( *(++lp) )			/* after PATH=\0	*/
	  {
	    if( *lp == '=' )			/* key found =: path is	*/
	      return( FALSE );			/* really null, so punt	*/
	  }
	  oldpath = TRUE;			/* it really is a path	*/
	  lp = ( BYTE *)temp;			/* so munge the null	*/
	  *lp = ';';
        }
/* end compatibility code ----------------				*/

						/* if found count in to	*/
						/*   appropriate path	*/

	last = *lp;
	for( i = whichone; i > 0; i-- )
	  while( (last = *lp++) && (last != ';') && (last != ',') )
	  ;					/* added commas (8808 kbad) */

	if( !last )
	{
						/* restore the null	*/
	  if( oldpath ) *(char *)temp = '\0';	/* (for compatibility)	*/
	  return( FALSE );
	}

						/* copy over path	*/
	while( (*lp) && (*lp != ';') && (*lp != ',') )
	{					/* added commas (8808 kbad) */
	  last = *lp++;
	  *dp++ = last;
	}
/* NOTE: this next test means that null pathnames in the PATH env. var
* 	will be treated as ROOT rather than CURRENT directory.  Current
*	diretory in the path must be denoted by an explicit '.' e.g.:
*	PATH=.;A:\000 (880825 kbad)
*/						/* see if extra slash	*/
						/*   is needed		*/
	if ( (last != '\\') && (last != ':') )
	  *dp++ = '\\';
						/* append file name	*/
	LSTCPY( dp, pname );

						/* restore the null	*/
	if (oldpath) *(char *)temp = '\0';	/* (for compatibility)	*/

						/* make whichone refer	*/
						/*   to next path	*/
	return( whichone+1 );
}



/*	Shel search	*/

	WORD
sh_search( routine )
	REG	WORD	(*routine)( LONG );
{
	if ( routine )
	  (*routine)( ad_path );

	return( dos_sfirst( ad_path, F_RDONLY | F_HIDDEN | F_SYSTEM ) );
}

/*
*	Routine to verify that a file is present.  It first looks in the
*	current directory and then looks down the search path.  Before
*	it looks at each point it firsts call the passed-in routine with
*	the filespec that is looking for. Author unknown.
*	It uses the ad_shcmd 
*/

	WORD
sh_find(pspec, routine, envrn, pathsearch )
REG	LONG		pspec;
REG	WORD		(*routine)();
	BYTE		*envrn;
	WORD		pathsearch;
{
REG	WORD		path, found = 0;
REG	BYTE		*pname;
	BYTE		tmpname[14];
	LONG		savedta;


	savedta = trap( 0x2F );			/* Fgetdta()		*/
	dos_dta( ( LONG )&D.g_dta[0] );		/* use this		*/

	pname = sh_name( ( BYTE *)pspec );	/* get the file name	*/
	nstrcpy( pname, &tmpname[0], 13 );		/* copy it		*/

	pname = sh_name( ad_shcmd );	/* first look in program's dir	*/
	path = (WORD)(pname - ad_shcmd);
	pname = &tmpname[0];
	if( path ) {  				/* if a path exists	*/

	    LBCOPY( ( BYTE *)ad_path, ad_shcmd, path );	/* copy the path	*/
	    LSTCPY( ( BYTE *)(ad_path+path), pname );	/* add the name		*/
	    found = sh_search( routine );	/* look for it		*/
	}

	if ( ( !found ) && ( pathsearch ) )
	{				/* if not found there, look cwd	*/
	    path = 0;
	    strcpy( ( BYTE *)pspec, ( BYTE *)ad_path );
	    do 
	    {
		found = sh_search( routine );
		if( !found )
		    path = sh_path( path, ( BYTE *)ad_path, pname, envrn );
	    } while( path && !found );	/* then in env paths		*/
	}

	if( found )				/* if file found	*/
	  strcpy( ( BYTE *)ad_path, ( BYTE *)pspec );	/* return full filespec	*/

	dos_dta( savedta );			/* restore DTA		*/
	return( found );
}



/*
 *	Modify the AES environment path			
 *  ->	PATH=XXXXXXX0 to add the enviroment name
 *  ->	PATH=0 to remove path				
 */

	WORD
sh_spath( path )
	BYTE	*path;
{
	REG BYTE	*start;
 	BYTE		*dest,*new,*p1,*p2;
	WORD		add;
	UWORD		len;
	int		size,cursize;
	BYTE		temp;

				/* Look for '=' */
	p1 = scasb( path, '=' );
	if ( *p1 != '=' )	/* Illegal path name	*/
	   return( FALSE );

	temp = *(p1+1);		/* is it to add or remove ? */	
	add = ( temp ) ? TRUE : FALSE;
	if (temp)
	  *(p1+1) = 0;

	len = strlen( path );
	sh_envrn( ( LONG *)&p2, path );

	if (temp)
	  *(p1+1) = temp;		/* restore the path	*/

	if ( !p2 )		/* if not found */
	{
	  if ( !add )		/* and to delete */
	    return( FALSE );
	}
	else
	{
	  if ( !*p2 )		/* 7/30/92	*/
	   *(p2+1) = 0;

	  p2 -= len;

	  dest = start = ad_envrn;

	  while( *start )
	  {
	    if ( start != p2 )
	    {
	      len = strlen( start );
	      dest = strcpy( start, dest );
	      start += len;
	    }
	    else
	    {			/* skip this one */
	      while( *start )	
	       start++;
	    }
	    start++; 
	  }
	
	  if ( dest == ad_envrn )/* at the head */
	    *dest++ = 0;
 	
	  *dest = 0;		/* put in extra zero */
	  if ( !add )		/* if remove done */
	    return(1);
	}
	
	cursize = sh_len( ad_envrn );
				/* check new path size	*/
	size = strlen( path ) + 1;

	if ( ( envsize - cursize ) <= size )
	{			/* not enough room */
	  len = envsize + size + 1024;
	  
	  if ( !( new = dest = ( BYTE *)(dos_xalloc( (long)len, 0x43 ) ) ))
	    return( 0 );

	  size = len;
			/* copy the new to the head */
	  dest = strcpy( path, dest );
			/* copy the old paths	*/
	  start = ad_envrn;

	  while( *start )
	  {
	    dest = strcpy( start, dest );
	    len = strlen( start ) + 1;
	    start += len;
	  }
	
	  dos_free( ( LONG )ad_envrn );
	  ad_envrn = new; 
	  envsize = size;
	}
	else
	{
	  if ( cursize == 2 )
	    cursize = 1;	
	  dest = strcpy( path, &ad_envrn[cursize-1] );
	}

	*dest = 0;		/* put in extra zero */
	return( 1 );
}


/*	Launch a user defined shell	*/	

	WORD	
l_shell( buffer )
	BYTE	*buffer;
{
	WORD	id;
	WORD	mode;

	if ( !shellpd )	/* Not launched */
	{
	  if (gl_multi)
		mode = 0x0001;
	  else
		mode = 0x000d;
	  if ( id = sh_write(mode, 1, 0, buffer, "" ) )
	  {
	    sh_draw( buffer );
	    shellpd = idtopd( id );
	    shellpd->p_type |= AESSHELL;
	  }
	}
	else
	  id = shellpd->p_pid;

	return( id );
}



/*	Launch the default desktop or look for user defined shell */

	PD
*idesk( mode )
	WORD	mode;
{
	WORD	ret;

	ret = FALSE;

	if ( mode )	/* start up mode	*/
	{
	  if ( !ctldown )
	    ret = s_aescnf( SHELL, &l_shell );
	}

	if ( !ret )
	{
	  if ( ( shellpd = get_pd( "NEWDESK", AESAPP|AESSHELL ) ) )
	  {
	    pstart( shellpd, &runaes, ( BYTE *)&desktop );
	    ps_rename( shellpd->p_sysid, "NEWDESK.", FALSE );
	  }
	  else
	    return( (PD*)0 );
	}

	set_desk( shellpd );
	return( shellpd );
}



BYTE	savebuf[128];

/*	Append the extension to do search again			*/
/*	If the file name has an extension dot, it will abort	*/

	WORD
sh_pfind( file, envrn, search, pathname )
	BYTE	*file,*envrn,*pathname;
	WORD	search;
{
	REG BYTE	*ptr;
	BYTE		*extptr;
	WORD		ret,i,changed;

	sh_envrn( ( LONG *)&extptr, envrn );

	if ( !extptr )		/* No environment	*/
	  return( FALSE );

	ptr = extptr;

	strcpy( file, savebuf );

	extptr = scasb( sh_name( file ), '.' );
	if ( *extptr == '.' )
	  return( FALSE );
	
	ret = FALSE;

	Debug6( "Sh_pfind starts to find \r\n" );
	Debug6( file );
	Debug6( "\r\n" );

	while( ( *ptr ) && !ret ) 
	{
	   changed = FALSE;
	   *extptr = '.';
	
	   for ( i = 1; i < 4; i++ )
	   {
	     if ( !*ptr )
		break;

	     if ( ( *ptr != ',' ) && ( *ptr != ';' ) )
	     {
	       changed = TRUE;
	       extptr[i] = *ptr++;
	     }
	     else
	     {
	       ptr++;
	       while( *ptr )
	       {
		 if ( ( *ptr != '.' ) && ( *ptr != ',' ) )
		   break;
		 else
		   ptr++;
	       }
	       break;
	     }
	   }
		
	   if ( changed )
	   {
	     extptr[i] = 0;
	     Debug6( "Sh_pfind -> " );
	     Debug6( file );
	     Debug6( "\r\n" );
	     ret = sh_find( ( LONG )file, ( WORD(*)())0L, pathname, search );
	   }

	   if ( !ret )
	     strcpy( savebuf, file ); 	/* restore the name */
	}

	return( ret );
}


BYTE	*exttable[] = { GEMEXT, TOSEXT, ACCEXT, (BYTE*)0 };


/*	
*	Check for the file extension type
*	0 for GEM application		
*	1 for TOS application
*	2 for ACC 	
*/

	WORD
sh_chktype( file, type )
	BYTE	*file;
	WORD	*type;
{
	REG BYTE	*ptr;
	BYTE		buf[4];
	WORD		changed,i,j,ret;
	BYTE		*temp,*extptr;
					
	extptr = scasb( sh_name( file ), '.' );
	if ( *extptr == '.' )	
	  *extptr++;

	ret = FALSE;
	j = 0;

	while( ( exttable[j] ) && ( !ret ) )
	{
	  *type = j; 	
	  sh_envrn( ( LONG *)&temp, exttable[j++] );
	  if ( !temp )
	    return( FALSE );

	  ptr = temp;

	  while( ( *ptr ) && !ret ) 
	  {
	     changed = FALSE;
	
	     for ( i = 0; i < 3; i++ )
	     {
	       if ( !*ptr )
		break;

	       if ( ( *ptr != ',' ) && ( *ptr != ';' ) )
	       {
	         changed = TRUE;
	         buf[i] = *ptr++;
	       }
	       else
	       {
	         ptr++;
	         while( *ptr )
	         {
		   if ( ( *ptr != '.' ) && ( *ptr != ',' ) )
		     break;
		   else
		     ptr++;
	         }
	         break;
	       }
	     }

	     if ( changed )
	     {
	       buf[i] = 0;
	       Debug6( "Compare to " );
	       Debug6( buf );
	       Debug6( "\r\n" );
	       upperstr( buf );
	       ret = strcmp( extptr, buf );
	     }
	  }
	}    

	return( ret );
}





/*	Expanded function to verify if a file is present
 *	Look for file at the current directory
 * INPUT			PATH?	EXT?
 *
 * lines			y	y
 * lines.			y	n	(dot in name means EXT=n)
 * d:\mint\util.mnt\lines	n	y	(any path char means PATH=n)
 * d:\mint\util.mnt\lines.prg	n	n	(both path and dot)
*/


	WORD
sh_xfind( file, pathname )
	BYTE	*file,*pathname;
{
	WORD	ret,i;
	BYTE	*ptr;
	WORD	pathsearch;

	pathsearch = TRUE;
	ptr = file;

	while( *ptr )
	{
	  if ( ( *ptr == ':' ) || ( *ptr == '\\' ) )
	  {
	    pathsearch = FALSE;
	    break;
	  }
	  ptr++;
	}

	if ( !( ret = sh_find( ( LONG )file, (WORD(*)())0L, pathname, pathsearch ) ) )
	{
	  i = 0;
	  while( exttable[i] )
	  {
	    if ( ( ret = sh_pfind( file, exttable[i++], pathsearch, pathname ) ) )
	      break;
	  }
	}

	if ( ret )
	{
	  Debug6( "The final path is " );	  
	  Debug6( file );
	}
	
	return( ret );
}
