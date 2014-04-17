/*
*************************************************************************
*			Revision Control System
* =======================================================================
*  $Revision: 2.2 $	$Source: /u2/MRS/osrevisions/aes/gemrom.c,v $
* =======================================================================
*  $Author: mui $	$Date: 89/04/26 18:26:27 $	$Locker: kbad $
* =======================================================================
*  $Log:	gemrom.c,v $
* Revision 2.2  89/04/26  18:26:27  mui
* TT
* 
* Revision 2.1  89/02/22  05:29:13  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.5  88/11/01  18:02:04  kbad
* Revamped PRG define
* 
* Revision 1.4  88/10/03  12:08:52  kbad
* New build obsoletes ROM/IMG/PRG changes.
* 
* Revision 1.3  88/09/22  04:49:08  kbad
* Added "tosrsc" label of inline linked resource
* 
* Revision 1.2  88/09/08  18:59:25  kbad
* added <flavor.h> for prg/img/rom flag
* 
* Revision 1.1  88/06/02  12:34:59  lozben
* Initial revision
* 
*************************************************************************
*/
/*	NEW	GEMROM.C	01/11/88 - 1/19/88	Derek Mui	*/
/*	Look for TOS.RSC and read in GEM.RSC,DESKTOP.RSC,DESKTOP.INF	*/
/*	Make sure you set the switches right at machine.h		*/
/*	Change at rsc_read do_cdir	1/28/88		D.Mui		*/
/*	Change at rsc_read for TOS and ROM system 3/11/88		*/
/*	Incorporated all the resources together	7/14/92	D.Mui		*/
/*	Chnage the rsc table and time code format 7/16/92	D.Mui	*/

#include <portab.h>
#include <machine.h>
#include <obdefs.h>
#include <taddr.h>

EXTERN LONG	dos_alloc();
EXTERN WORD	dos_open();
EXTERN WORD	dos_read();
EXTERN WORD	dos_close();
EXTERN VOID	do_rsfix();

EXTERN LONG	rs_global;
EXTERN LONG	rs_hdr;
EXTERN WORD	diskin;
EXTERN WORD	DOS_ERR;

GLOBAL LONG	gemptr;			/* GEM's rsc pointer		*/
GLOBAL LONG	deskptr;		/* DESKTOP'S rsc pointer	*/
GLOBAL LONG	infptr;

GLOBAL UWORD	infsize;
GLOBAL UWORD	gemsize;
GLOBAL UWORD	desksize;
GLOBAL LONG	gl_pglue;

GLOBAL WORD	nodesk;
GLOBAL WORD	nogem;

GLOBAL	WORD	st_lang;	/* Language code	*/
GLOBAL	UWORD	st_time;	/* time code		*/
GLOBAL	UWORD	st_date;
GLOBAL	UWORD	st_dchar;
GLOBAL	WORD	st_keybd;
MLOCAL	UWORD	*tosrsc;	

EXTERN	BYTE	USARSC[];	/* USA, UK	*/
EXTERN	BYTE	GRMRSC[];	/* GERMAN	*/
EXTERN	BYTE	FRERSC[];	/* FRENCH	*/
EXTERN	BYTE	ITARSC[];	/* ITALIAN	*/
/*EXTERN	BYTE	SWERSC[];*/	/* SWEDISH	*/
EXTERN	BYTE	SPARSC[];	/* SPANISH	*/

MLOCAL	BYTE	*TIMETABLE[] =
{/* Eurotime, Eurodate and seperator */
	0,0,'/',	/* USA	*/
	1,1,'.',	/* GERMANY	*/
	1,1,'/',	/* FRENCH	*/
	0,0,'/',	/* USA	*/
	1,1,'/',	/* SPAIN	*/
	1,1,'/',	/* ITALY	*/
	1,2,'-'		/* SWEDEN,NORWAY,FINLAND*/
};	

MLOCAL	BYTE	*RSCTABLE[] =
{
	USARSC,		/* USA, UK	*/
	GRMRSC,		/* GERMAN	*/
	FRERSC,		/* FRENCH	*/
	USARSC,		/* reserved	*/
	SPARSC,		/* SPANISH	*/
	ITARSC,		/* ITALIAN	*/
	USARSC		/* suppose to be SWEDISH	*/
};	


				/* do this whenever the Gem or	*/
				/* desktop is ready		*/
	WORD
rom_ram( which, pointer )
	REG LONG	pointer;
{
	WORD		size;
	REG WORD	doit;

	if ( which == 3 )		/* read in desktop.inf		*/
	{
	  LBCOPY( pointer, infptr, infsize );
	  return( infsize );
	}
	
	rs_global = pointer;
	doit = TRUE;

	if ( !which  )			/* read in gem rsc		*/
	{
	  if ( nogem )
	    doit = FALSE;
	  else
	    nogem = TRUE;		/* already read in		*/

	  rs_hdr = gemptr;
	  size = gemsize;
	}
	else
	{
	  if ( nodesk )
	    doit = FALSE;
	  else
	    nodesk = TRUE;

	  rs_hdr = deskptr;
	  size = desksize;
	}


	LLSET( pointer + 14, rs_hdr );
	LWSET( pointer + 18, size );

	if ( doit )
	{
	  do_rsfix( rs_hdr, size ); 
	  rs_fixit( pointer );
	}
}


rsc_free( )
{
	dos_free( gl_pglue );
	gemptr = 0x0L;
	deskptr = 0x0L;
}


/*	Read in the resource file	*/	

rsc_read()
{
	UWORD		size;
	REG UWORD	*intptr;
	BYTE		*a,*b;
	LONG		value;
	WORD		code;
	
	/* The value is defined as 	*/
	/* X, X, LANGUAGE, KEYVBOARD	*/

	if ( getcookie( 0x5F414B50L, &value ) )	/* get _AKP cookie */
	{
	  st_keybd = value & 0x00FFL;
	  st_lang = ( value >> 8 ) & 0x00FFL;	/* get the keyboard preferences */
	}
	else
	  st_keybd = st_lang = 0;

	if ( ( st_keybd > 8 ) || ( st_keybd < 0 ) )
	  st_keybd = 0;

	if ( ( st_lang > 6 ) || ( st_lang < 0 ) || ( st_lang == 3 ) )
	  st_lang = 0;

	code = st_lang * 3;

	st_time = TIMETABLE[code++];
	st_date = TIMETABLE[code++];
	st_dchar = TIMETABLE[code];

	/* The IDT format is as follow				*/
	/* HIGH WORD  |	         LOW WORD			*/
	/* 31 - 16    | 15-12      11-8     	  7-0 bit 	*/
	/* Reserved   |	st_time    st_date  	  st_char	*/
	/*  		0 12 hour  0  MM-DD-YY   		*/
	/*		1 24 hour  1  DD-MM-YY			*/	
	/*			   2  YY-MM-DD			*/
	/*			   3  YY-DD-MM			*/

	if ( getcookie( 0x5F494454L, &value ) )	/* get _IDT cookie */
	{
	  st_date = ( value >> 8 ) & 0xFL;	/* get the date preferences */
	  st_time = ( value >> 12 ) & 0xFL;
	  if ( !( st_dchar = value & 0xffL ) )
	    st_dchar = '/';	
	}

	tosrsc = RSCTABLE[st_lang];	

	if ( !( gl_pglue = dos_alloc( (LONG)tosrsc[2] ) ) )
	{
	  trap( 9, "Unable to install AES resource!\r\n" );
	  return( FALSE );
	}
						/* copy rsc to ram */
	intptr = tosrsc;

	size = intptr[2];
	a = tosrsc;
	b = gl_pglue;

	while( size )
	{
	  *b++ = *a++;
	  size--;
	}

	intptr = gl_pglue;
	gemptr = (LONG)(gl_pglue + 10);		/* now fix the resource	  */
	deskptr = (LONG)(gl_pglue + intptr[0]);
	infptr = (LONG)(gl_pglue + intptr[1] );
	gemsize = intptr[0];
	desksize = intptr[1] - intptr[0];
	infsize = intptr[2] - intptr[1];
	nodesk = 0;
	nogem = 0;
}
