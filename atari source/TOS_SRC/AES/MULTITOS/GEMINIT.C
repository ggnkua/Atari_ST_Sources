/*	GEMINIT.C	4/23/84 - 02/08/85	Lee Lorenzen		*/
/*	to 68k		2/23/75 - 05/03/85	Lowell Webster		*/
/*	Ram based		  05/15/85	Derek Mui		*/
/* 	Fix the main		  07/11/85 	Derek Mui		*/
/*	08/28/85  Fix when no disk attached		Derek Mui	*/
/*	10/23/85  Fix at pred_inf to read inf file from root  D.Mui	*/
/*	05/22/85  Initialize in dispatch semaphore 	M Schmal	*/
/*	Fix at pred_dinf for bit on 	2/12/87		Derek Mui	*/
/*	Change at main to get mouse add	11/30/87	D.Mui		*/
/*	Update		12/10/87			D.Mui		*/
/*	Change at ini_dlong	12/17/87		D.Mui		*/
/*	Added ad_out1, ad_out2	1/7/88			D.Mui		*/
/*	Added er_num, no_aes	1/8/88			D.Mui		*/
/*	Move drawstk from deskglob to here at main 1/15/88	D.Mui	*/
/*	Add ad_fsel		1/21/88			D.Mui		*/
/*	Take out ad_out1 and ad_out2	1/27/88		D.Mui		*/ 
/*	Change pred_dinf		1/28/88		D.Mui		*/
/*	Take out ad_envrn		1/28/88		D.Mui		*/
/*	Add autoexec 			2/11/88		D.Mui		*/
/*	Add g_autoboot	2/11/88				D.Mui		*/
/*	Change the resolution masking	2/23/88		D.Mui		*/
/*	Check to turn bit on when autoboot	3/10/88	D.Mui		*/
/*	In line coded of ini_dlongs	3/24/88		D.Mui		*/
/*	Fix at pred_dinf for scan_2	5/2/88		D.Mui		*/
/*	Change at pref_dinf for gl_restype 4/25/89	D.Mui		*/
/*	Change at gsx_malloc for new size  7/26/89	D.Mui		*/
/*	Turn on the cache in pred_dinf		6/25/90	D.Mui		*/
/*	Make sure the scan_2 for cache checking doesn't reset temp	*/
/*	Look for newdesk.inf then desktop.inf in pred_dinf 6/26/90	*/ 
/*	Change RES4 to RES5 for solid pattern	6/27/90	D.Mui		*/
/*	Changed wm_start to wm_init		900628 kbad		*/
/*	Moved all_run to gemcli.c		07/16/90	D.Mui	*/
/*	Fix at gsx_malloc to save 1/2 of the screen	7/19/90	D.Mui	*/
/*	Added initialization of crt_error semaphore	900731  D.Mui	*/
/*	Removed #include flavor.h: DOWARNING now here 900801 kbad	*/
/*	Also removed TT conditional.  If it's longframe, it's TT	*/
/*	Clean up and take out sh_up		9/5/90		D.Mui	*/
/*	Change size_theglo			9/6/90		D.Mui	*/
/*	Move process init to GEMPD		9/14/90		D.Mui	*/
/*	Take out crt_error			10/2/90		D.Mui	*/	
/*	Modified the main			5/1/91		D.Mui	*/
/*	Check control key for nodisk system at main 8/13/91	D.Mui	*/
/*	Read the GEM.CNF for path stuff		3/17/92		D.Mui	*/
/*	Convert to Lattice C 5.51		2/16/93		C.Gee	*/
/*	Force the use of prototypes		2/23/93		C.Gee	*/
/*	Copied over scan_2() and save_2() from deskinf.c and		*/
/*	renamed them scan2_2() and save2_2().				*/
/*	Copied over hex_dig() and uhex_dig() also.			*/
/*	Load rsc file from disk			2/11/92		H.Krober*/

/*	-----------------------------------------------------------
*	AES Version 4.0	MultiTOS version is written by Derek M. Mui
*	Copyright (C) 1992 
*	Atari (U.S.) Corp
*	All Rights Reserved
*	-----------------------------------------------------------
*/	


/*	-------------------------------------------------------------
*	GEM Application Environment Services		  Version 1.0
*	Serial No.  XXXX-0000-654321		  All Rights Reserved
*	Copyright (C) 1985			Digital Research Inc.
*	-------------------------------------------------------------
*/
#include "pgem.h"
#include "pmisc.h"

#include "machine.h"
#include "dispvars.h"
#include "objaddr.h"
#include "osbind.h"
#include "mintbind.h"
#include "rslib.h"
#include "signal.h"
#include "gemusa.h"
#include "gemdos.h"
#include "softload.h"
#include "vdomode.h"

/*
 *	Set the SOFTLOAD flag to implement softloaded GEM AES resources.
 *	The AES will then try to read its resource file from
 *	[A|C]:\MULTITOS\GEM.RSC. 
 *	NOTE: You have to define SOFTLOAD in gemrom.c, too, because there
 *	      are the actual functions.
 *	See Defines in SOFTLOAD.H
 */
/*
 *	Set the LOADKBT flag to implement softloaded keyboard tables. The
 *	system will try to load the keyboad table from 
 *	[A|C]:\MULTITOS\KEYBD.TBL
 *
 *	THE FORMAT OF KEYBD.TBL IS:
 *
 *	[ unshifted keyboard table (128 Bytes)     ]
 *	[ shifted keyboard table (128 Bytes)       ]
 *	[ caps lock keyboard table (128 Bytes)     ]
 *	{ alternate unshifted keyboard table **    }
 *	{ alternate shifted keyboard table **      }
 *	{ alternate caps lock keyboard table **    }
 *
 *	**: An alternate keyboard table is a list of two bytes pairs.
 *	    The list is NUL terminated.
 *
 *	Use an assembler (madmac), aln and fixrom to create the tables. You
 *	can get the data for the tables from bios.s.
 * 
 *	This works only a 100% on machines with the AKP code (since 5/92)
 *	in the bios. Older versions have the alternate key handling hard
 *	coded while the bios with AKP uses tables for the alternate key
 *	handling.
 *	
 *	See Defines in SOFTLOAD.H
 */


BYTE	*scan2_2( REG BYTE *pcurr, REG UWORD *pwd );
BYTE	*save2_2( REG BYTE *pcurr, UWORD wd );
WORD	hex2_dig( REG BYTE achar );
BYTE	uhex2_dig( REG WORD wd);
VOID	bi_opendev( VOID );

#define CACHE_ON	0x00003919L
#define CACHE_OFF	0x00000808L
#define LONGFRAME	*(WORD *)(0x59eL)


EXTERN	WORD	pref_save;
EXTERN	WORD	gl_mkind;
EXTERN	MFORM	gl_cmform;
EXTERN	WORD	gl_mfid;
EXTERN	WORD	envsize;
EXTERN	PD	*scr_pd;
EXTERN	WORD	gl_curpid;
EXTERN  UWORD	a_rezword;
EXTERN	UWORD	b_rezword;
EXTERN	BYTE	DEFPATH[];
EXTERN	BYTE	PATHEQUAL[];
EXTERN	WORD	st_lang;
EXTERN	PD	*shutpd;
EXTERN	PD	*alr;
EXTERN	WORD	gl_width;
EXTERN	WORD	gl_debug;
EXTERN	WORD	phanwind;
EXTERN	WORD	st_redraw;
EXTERN	WORD	dy_redraw;
EXTERN	OBJECT	*gl_wtree;
EXTERN	PD	*rlr;
EXTERN	BYTE	*ad_envrn;
EXTERN	OBJECT	*critobj[];
EXTERN	WORD	ml_alrt[];
EXTERN	BYTE	*runacc;
EXTERN	GRECT	gl_rscreen;
EXTERN	WORD	al_center;
EXTERN	OBJECT	*mn_addr;		/* supplement menu_bar memory address */
EXTERN	WORD	gl_smid;
EXTERN	OBJECT	*gl_mntree;
EXTERN 	PD	*plr;
EXTERN 	WORD	gl_ncols;
EXTERN 	WORD	gl_nrows;
EXTERN 	WORD	gl_hchar;
EXTERN 	WORD	gl_wchar;
EXTERN 	WORD	gl_recd;
EXTERN 	WORD	gl_rlen;
EXTERN 	LONG	gl_rbuf;
EXTERN 	WORD	gl_bdesired;
EXTERN 	WORD	gl_btrue;
EXTERN	WORD	gl_button;
EXTERN 	WORD	gl_bdelay;
EXTERN 	WORD	gl_ticktime;
EXTERN 	BYTE	*ad_shcmd;
EXTERN 	BYTE	*ad_shtail;
EXTERN 	BYTE	infdata[];
EXTERN 	LONG	ad_path;
EXTERN 	WORD	intin[];
EXTERN 	LONG	tikaddr;
EXTERN 	LONG	tiksav;
EXTERN 	WORD	cpdid;
EXTERN	BYTE	*sysbase;
EXTERN	WORD	gl_dacnt;
EXTERN	WORD	gl_dabase;
EXTERN	PD	*currpd;
EXTERN	WORD	gl_accid;
EXTERN	WORD	reschid;
EXTERN	WORD	shutdown;
EXTERN	LONG	shel_magic;
EXTERN	WORD	gl_port;
EXTERN	WS	gl_ws;
EXTERN	WORD	gl_moff;
EXTERN	WORD	gl_mouse;
EXTERN	WORD	_inaes;

GLOBAL	LONG	aesAKP;
GLOBAL	USERBLK	*aesDDD;

GLOBAL	WORD	gl_doitonce;
GLOBAL	WORD	gl_restype;	
				/* screen resolution 1 = default, 
				2 = 320x200, 3 = 640x200,  4 = 640x400
				5 = 640x480, 6 = 1280x960, 7 = 320x480
				*/
GLOBAL	WORD	gl_rschange;
GLOBAL	GRECT	gl_offscreen;
GLOBAL	THEGLO	D;
GLOBAL	LONG	ad_sysglo;
GLOBAL	LONG	ad_armice;
GLOBAL	LONG	ad_hgmice;
GLOBAL	LONG	ad_stdesk;
GLOBAL	LONG	ad_fsel;
GLOBAL	WORD	biosfd;		/* file descriptor for BIOS file */
GLOBAL	WORD	autoexec;	/* autoexec a file ?	*/
GLOBAL	WORD	g_flag;
GLOBAL  WORD	ctldown;	/* ctrl key down ?	*/
GLOBAL	WORD	scr_exit;
GLOBAL	PD	*shellpd;
GLOBAL	WORD	aesid;
GLOBAL	PD	*errpd;
GLOBAL	BYTE	*ad_aescnf;
GLOBAL	BYTE	*loadapp;

GLOBAL	UWORD	act3dtxt;	/* look of 3D activator text */
GLOBAL	UWORD	act3dface;	/* selected look of 3D activator */
GLOBAL	UWORD	ind3dtxt;	/* look of 3D indicator text */
GLOBAL	UWORD	ind3dface;	/* selected look of 3D indicators */
GLOBAL	UWORD	gl_indbutcol;	/* indicator button color */
GLOBAL	UWORD	gl_actbutcol;	/* activator button color */
GLOBAL	UWORD	gl_alrtcol;	/* alert background color */
GLOBAL	LONG	gl_vdo;
GLOBAL	WORD	gl_multi;	/* Multitasking or not	*/

GLOBAL	WORD	adeskp[3];	/* AES copy of desktop backgrounds */
GLOBAL	WORD	awinp[3];	/* AES copy of desktop window backgrounds */

/* ++ERS 12/16/92 */
GLOBAL  BYTE *a_strtproc;	/* alert box Screen uses to start desktop */
GLOBAL  BYTE *a_faildesk;	/* alert box Screen uses when an error
				   occurs when launching the desktop */

GLOBAL	BYTE	*icnslots;	/* for icon slot management   */
GLOBAL	BYTE	currIcnmax;	/* see gemctrl.c & gemwmlib.c */

BYTE	AESCNF[] = "C:\\GEM.CNF";
BYTE	AESCNF2[] = "C:\\MULTITOS\\GEM.CNF";
BYTE	ARGV[] = "ARGV=";
BYTE	SETENV[] = "setenv";
BYTE	RUN[] = "run";
BYTE	SHELL[] = "shell";
BYTE	AE_TREDRAW[] = "AE_TREDRAW=\\";
BYTE	AE_SREDRAW[] = "AE_SREDRAW=\\";
BYTE	AE_DEBUG[] = "AE_DEBUG=\\";
BYTE	AE_PORT[] = "AE_PORT=\\";
BYTE	AE_PNTSIZE[] = "AE_PNTSIZE=\\";
BYTE	AE_FONTID[] = "AE_FONTID=\\";
BYTE	AE_LANG[] = "AE_LANG=\\";

#ifdef LOADKBT

EXTERN LONG dos_lseek();

#define KBTMAGIC	0x2771

#define KBTSTDLEN	386

MLOCAL BYTE 	*kbt_buf;
MLOCAL BYTE	KBTFNAME[25]; /* = "C:\\MULTITOS\\KEYBD.TBL"; */
MLOCAL VOID	set_kbdtbl( VOID );

typedef struct {
	BYTE	*unshift;
	BYTE	*shift;
	BYTE	*capslock;
	BYTE	*altunsh;
	BYTE	*altsh;
	BYTE	*altcl;
} KEYTAB;

#endif


/*	Get AES cookies		*/

	WORD
aescookie( cookie, p_value )
	LONG	cookie;
	LONG	*p_value;
{
	LONG	*cookjar;
	WORD	status;

	status = FALSE;	

	if ( cookjar = ( LONG *)( *(LONG*)(0x5a0)) )
	{
	  while( *cookjar )
	  {
	    if ( *cookjar == cookie )
	    {
	      *p_value = *( cookjar + 1 );
	      status = TRUE;
	      break;
	    }
	    else	
	      cookjar += 2;
	  }
	}

	return( status );
}

/*	Check to see if MiNT is there 	*/

	WORD
cMiNT( VOID )
{
	LONG	value;

	return( gl_multi = aescookie( 0x4D694E54L, &value ) );
}


/*	Set AES debug mode	*/

	VOID
s_debug( buffer )
	BYTE	*buffer;
{
	gl_debug = (WORD)(*buffer - '0');
}


	VOID
s_sport( buffer )
	BYTE	*buffer;
{
	gl_port = (WORD)(*buffer - '0');
}


/*	Set the language value	*/

	VOID
s_lang( buffer )
	BYTE	*buffer;
{
	st_lang = *buffer - '0';
	if ( ( st_lang == 3 ) || ( st_lang > 6 ) || (st_lang < 0))
	  st_lang = 0;

}


	VOID
s_sredraw( buffer )
	BYTE	*buffer;
{
	if ( *buffer == '1' )
	  st_redraw = 1;

	if ( *buffer == '0' )
	  st_redraw = 0;
}

	VOID
s_tredraw( buffer )
	BYTE	*buffer;
{
	if ( *buffer == '1' )
	  dy_redraw = 1;

	if ( *buffer == '0' )
	  dy_redraw = 0;
}

/*	Set the environment stuff	*/

	VOID
s_env( buffer )
	BYTE	*buffer;
{
	sh_write( 8, 1, 0, buffer, "" );
}



/*	Launch an AES application
 *	The incoming inbuffer has the entire line of command includes
 *	the spaces and it is terminated by NULL
 */

	VOID
ldaes( inbuffer )
	BYTE	*inbuffer;
{
	BYTE		*tail;
	MLOCAL char blank[2];

	tail = scasb( inbuffer, ' ' );	/* find the tail */
	if ( *tail == ' ' )		/* Yes	*/
	{
	  *tail = 0;
	  tail++;
	}
	else
	  tail = "";

	strcpy( tail, &ad_shtail[1] );
	ad_shtail[0] = strlen( tail );

	upperstr( inbuffer );

	sh_draw( inbuffer );
	dos_setdir( inbuffer, 0 );
	sh_write( 0, 0, 0, inbuffer, ad_shtail );
	blank[0] = ' ';
	sh_draw( blank );
}

/*	Set up the initial stuff, do it only once */

	BYTE
*set_up( VOID )
{
	PD	*p;
	WORD	id,i;
	BYTE	*bptr;
	UWORD	size;

	if (gl_multi)
		id = ( WORD )Pgetpid();
	else
		id = 0;
	ps_rename( id, "AESSYS.", TRUE );
	rlr = plr = (PD*)0;
	gl_curpid = 0;
	currpd = p = xget_pd( "AESSYS", AESSYSTEM );
	aesid = currpd->p_pid;
	strcpy( "  AESSYSTEM", p->p_prgname );
	p->p_baseaddr = sysbase;
	p->p_sysid = id;
	p->p_state = PS_RUN;
	unlink_pd( &alr, p );
	scheduler( p );
	
	size = 0;

	if ( *ad_envrn )	/* if there is an environment */
	  size = sh_len( ad_envrn );

	size += 1024;

	if ( bptr = ( BYTE *)dos_xalloc( (LONG)size, 0x43 ) )
	{
	  envsize = size;

	  bfill( size, 0, bptr );		/* clear the buffer	*/

	  if ( *ad_envrn )
	    LBCOPY( bptr, ad_envrn, sh_len( ad_envrn ) );
	  else
	    strcpy( DEFPATH, bptr );

	  ad_envrn = bptr;			/* new source */

	  /* Get rid of the argv stuff	*/

	  sh_envrn( ( LONG *)&bptr, ARGV );

	  if ( bptr )	/* find it	*/
	  {
	    i = strlen( ARGV );
	    bptr -= i;
	    *bptr = 0;
	  }	
				/* find the PATH=0C: */
	  sh_envrn( ( LONG *)&bptr, PATHEQUAL );
	  
	  if ( bptr )		/* yes, construct a new one	*/
	  {	
	    if ( !*bptr )
	    {	
	      *bptr++ = *((WORD*)0x446L) + 'A';	/* get boot device */
	      *bptr++ = ':';	/* get boot device */
	      *bptr++ = '\\';
	      *bptr = 0;
	    }
	  }	
	}
	else
	  Debug6( "Failed to create environment string\r\n" );


	catchsignal( -1 );	/* redirect all the signal to function */
				/* that does nothing	*/
	Psignal( SIGCHLD, sigchld );	
				/* catch the child's exit signal */
	return( p->p_uda->u_spsuper );
}


/*	Clean up the struct THEGLO	*/

	VOID
clr_theglo( VOID )
{
	bfill( sizeof(THEGLO), 0, ( BYTE *)&D );
}


	VOID
main( VOID )
{
	REG WORD	i;
	LONG		tree;
	REG THEGLO	*DGLO;
	LONG		*ptr;
	WORD		buffer[4];
	OBJECT		*obj;

	currpd = idtopd( aesid );

	DGLO = &D;

	ad_aescnf = (BYTE*)0;		/* GEM.CNF file buffer address	*/
	ad_shcmd = &DGLO->s_cmd[0];
	ad_shtail = &DGLO->s_tail[0];
	ad_path = ( LONG )&DGLO->g_dir[0];

	ad_sysglo = ( LONG )&DGLO->g_sysglo[0];
	al_center = TRUE;			/* center the alert box	*/

	DGLO->s_save = ( BYTE *)dos_xalloc( (LONG)SIZE_AFILE, 3 );
	DGLO->s_size = SIZE_AFILE;

	gl_recd = FALSE;			/* init event recorder	*/
	gl_rlen = 0;
	gl_rbuf = 0x0L;
						/* No buttons state	*/
	gl_button = gl_bdesired = gl_btrue = 0x0;			
	gl_bdelay = 0x0;			/* No delay		*/
	gl_mntree = 0;

	fpcnt = 0;
	fpt = 0;
	fph = 0;

	alr = (PD*)0;
	drl = (PD*)0;			/* Dispatcher ready list	*/
	nrl = (PD*)0;			/* Not ready list		*/
	slr = (PD*)0;			/* Screen owner			*/
	shutpd = shellpd = scr_pd = (PD*)0;
	reschid = cpdid = spdid = gl_smid = 0;

	tel = zel = 0;				/* zombie event list	*/
						/* timer event list	*/

	gl_dacnt = 0;
	gl_dabase = 0;
	gl_accid = 0;
	gl_debug = 0;				/* Debug mode */
	gl_port = 2;				/* go to the screen	*/

	scr_exit = FALSE;			/* screen manager not exit */
	shutdown = FALSE;			/* not in shutdown mode	   */
	st_redraw = 1;				/* send redraw when program*/
						/* starts up and don't send*/
	dy_redraw = 0;				/* redraw when program dies*/	

	/* get the default language from ROM ++ERS 12/17/92 */
	/* this may be overridden (later) by the _AKP cookie or by AE_LANG */

	ptr = * ((LONG **)0x4f2);	/* RAM header */
	ptr = (LONG *) ptr[2];		/* ROM header */

	st_lang = ( WORD )((ptr[7] & 0x7ffe0000L) >> 17L);
	if (st_lang == 8)		/* swiss german */
		st_lang = 1;
	else if (st_lang == 7)		/* swiss french */
		st_lang = 2;
	else if (st_lang < 0 || st_lang > 6)
		st_lang = 0;

	shel_magic = 0x0L;			/* shell magic number	*/

	if (gl_multi) {
	  if (gl_doitonce)
	    mt_opendev();	/* install our special AES device */
	    bi_opendev();	/* install BIOS replacements */
#if 0
				/* This is the trap2 AES semaphore */
					/* ("_MUI") */
	  Psemaphore( 0, 0x5F4D5549L, 0x0L );
#else
	  _inaes = 1;
#endif

/*
 * ERS: create a semaphore (_SCP) which applications can use to control
 * access to the scrap directory. The AES itself doesn't actually need
 * this semaphore for anything, so we free it right away. - 12/8/92
 */
	  Psemaphore( 0, 0x5F534350L, 0x0L );
	  Psemaphore( 3, 0x5F534350L, 0x0L );
	}

	cli();					/* no ticks during init	*/
	takecpm();				/* take the trap2 vector*/
	sti();					/* restart the tick	*/

	if ( !setrunacc() )
	{
	  bailout( "Failed to setup acc exec code" );
	  goto i_7;
	}
						/* screen manager 	*/
	/* New stuff 8/13/91	*/

	ctldown = Kbshift( -1 ) & 0x0004 ? TRUE : FALSE;

	/* Read the system COOKIES	*/
	
	aesAKP = -1;
	aescookie( 0x5F414B50, &aesAKP );	/* _AKP */

	/* The _AKP value is defined as 	*/
	/* X, X,  LANGUAGE, KEYBOARD	*/
	if (aesAKP != -1L)
	{
	  st_lang = ( WORD )(( aesAKP >> 8 ) & 0x00ff );
	  if ( ( st_lang > 6 ) || ( st_lang < 0 ) || ( st_lang == 3 ) )
	    st_lang = 0;
#ifdef LOADKBT
	set_kbdtbl();
#endif
	}

	aesDDD = 0;
	aescookie( 0x5F444444, ( LONG *)&aesDDD );	/* _DDD */
	if ( aesDDD )
	{
	  Debug1( "_DDD found draw routine at " );
	  Ndebug1( aesDDD );
	}


	/* Read the GEM.CNF and extract any usual variables	*/
	/* Do this before the rsc_read()			*/

	r_aescnf();				
	s_aescnf( SETENV, ( WORD(*)())&s_env );		/* get all the env path	*/
	s_aescnf( AE_DEBUG, (WORD(*)())&s_debug );	/* get the debug mode	*/
	s_aescnf( AE_SREDRAW, (WORD(*)())&s_sredraw );	/* get the redraw mode	*/
	s_aescnf( AE_TREDRAW, (WORD(*)())&s_tredraw );	/* get the terminate mode	*/
	s_aescnf( AE_PORT, (WORD(*)())&s_sport );	/* get the debug port	*/
	s_aescnf( AE_LANG, (WORD(*)())&s_lang );	/* get the language type	*/


	if ( !rsc_read() )			/* read in resource	*/
	  goto i_7;


 	/* Pre read the inf get the resolution */

	pred_dinf();		/* read the resolution value */	
						/* set default drive	*/
	dos_sdrv( (isdrive() & 0x04) >> 1 );

	gsx_init();	/* open work station and set the right resolution */
					
	/* 8/1/92	*/
	/* July 30 1992 - ml. Init 3D-look of indicators and activators */
	act3dtxt = 1;	    /* don't move text for activators */
	act3dface = 0;	    /* no color change when activator is selected */
	ind3dtxt = 0;	    /* move text for indicators */
	ind3dface = 1;	    /* change color when indicator is selected */


	if (gl_ws.ws_ncolors <= LWHITE) {    /* init button color */
    	    gl_actbutcol = gl_indbutcol = WHITE;
    	    gl_alrtcol = WHITE;	/* init alert background color */
	} else {
    	    gl_actbutcol = gl_indbutcol = LWHITE;
    	    gl_alrtcol = LWHITE;	/* init alert background color */
	}

	gl_offscreen.g_x = gl_width + 2;
	gl_offscreen.g_y = 0;
	gl_offscreen.g_w = 0;
	gl_offscreen.g_h = 0;

	rom_ram( 0, ad_sysglo );		/* read the GEM resource*/

/* 	Init the current mouse form and ownership	*/

	rs_gaddr(ad_sysglo, R_FRIMG, 0, ( LONG *)&ptr);
	ad_armice = LLGET(ptr[MICE0]);		/* get the arrow mouse	*/	
	ad_hgmice = LLGET(ptr[MICE2]);		/* get the busy bee	*/
	if ( gl_moff )
	  gsx_mon();

	gr_arrow( aesid );

	sh_tographic();		/* go into graphic mode	and set the mouse to busy bee */
	sh_background();	/* set the ad_stdesk		*/

	gsx_sclip( &gl_rscreen );
	ob_draw( ad_stdesk, 0, MAX_DEPTH );

	/* Bring up start up dialogue box */

	if ( gl_doitonce )
	{
	  if (gl_multi)
	  {
	    rs_gaddr( ad_sysglo, R_TREE, STARTUP, &tree );
	    ob_center( tree, ( GRECT *)&buffer[0] );
	    ob_draw( tree, 0, MAX_DEPTH );
	    Fselect( 2000, 0x0L, 0x0L, 0x0L );
	    ob_draw( ad_stdesk, 0, MAX_DEPTH );	/* clear the box	*/
	  }
	  gl_doitonce = FALSE;
	}

				/* preget the critcial error object */
	for( i = 0; i < MAXERR; i++ )
	  rs_gaddr( ad_sysglo, R_TREE, ml_alrt[i], ( LONG *)&critobj[i] );

	if ( !wm_init() )	/* start the window library	*/
	  goto i_7;

    	
	mn_create();	/* allocate max screen buffer must do it after	*/
			/* window library startup			*/
	
	mn_init();	/* 5/13/92	*/
			/* must do it before any get_pd call		*/

	ini_fsel();	/* initalize file selector	*/
	
					/* set file selector string	*/
	rs_gaddr(ad_sysglo, R_STRING, FSTRING, ( LONG *)&ad_fsel);
	rs_gaddr(ad_sysglo, R_FRSTR, LOADAPP, ( LONG *)&ptr);
	loadapp = ( BYTE *)*ptr;

	/* get the alert strings that SCREEN will need */
	/* ++ERS 12/16/92 */
	rs_gaddr( ad_sysglo, R_STRING, STRTPROC, ( LONG *)&a_strtproc );
	rs_gaddr( ad_sysglo, R_STRING, FAILDESK, ( LONG *)&a_faildesk );

	cli();				/* take the critical err	*/
	gl_ticktime = gsx_tick( tikaddr, &tiksav );
	ev_dclick( 3, TRUE );		/* set init. click rate		*/
	sti();

	if ( !iscrmgr() )		/* create a screen process	*/
	{
	  bailout( "Failed to create a screen process!\r\n" );
	  goto i_6;
	}
					/* set phantom window's owner	*/
	srchwp( phanwind )->owner = scr_pd;
	srchwp( phanwind )->cowner = scr_pd;

					/* get the AES menu		*/
	rs_gaddr( ad_sysglo, R_TREE, AESMENU, ( LONG *)&scr_pd->p_mnaddr );
	if (!gl_multi)
	{			/* set title to read "TOS" instead of "MultiTOS" */
	  obj = (OBJECT *)scr_pd->p_mnaddr;
	  strcpy("  TOS  ", (BYTE *)obj[AESTITLE].ob_spec);
	}
	set_desk( scr_pd );	/* set the background window to screen */

	if ( !idesk(1) )	/* allocate a desktop process	*/
	{
	  bailout( "Failed to create a desktop process!\r\n" );
	  goto i_6;
	}
 					/* create an error process	*/
	if ( ! ( errpd = get_pd( "ERROR", AESSYSTEM ) ) )
	{
	  bailout( "Failed to create a critical error process!\r\n" );
	  goto i_6;
	}
	else
	{
	  errpd->p_state = PS_RUN;
	  unlink_pd( &alr, errpd );
	  scheduler( errpd );
	  errpd->p_sysid = -1;
	}


	if ( !ctldown )
	{
	  ldaccs();			/* load in accessory	*/
  	  if (gl_multi)		/* for TESTING only */
	    s_aescnf( RUN, (WORD(*)())&ldaes );	/* load in files from autoaes */
	}

	if ( ad_aescnf )
	{
	  Debug6( "Free aescnf buffer\r\n" );
	  dos_free( ( LONG )ad_aescnf );
	  ad_aescnf = (BYTE*)0;
	}

	unlink_pd( &alr, shellpd );	/* Make the desktop as the last process to execute */
	link_tail( &alr, shellpd );

	*((BYTE*)0x484) |= 0x08;

	/*	Change mouse to arrow */

	gr_arrow( aesid );
	
	rundisp();			/* run dsptch forever	*/
	Debug1("Main: Return from rundisp()\r\n");
	
	a_rezword = b_rezword;
 
	currpd = idtopd( aesid );

	unlink_pd( &rlr, errpd );
	free_pd( errpd );		/* free the error process */
	free_pd( scr_pd );
	scr_pd = (PD*)0;
i_6:
	Debug6( "Go into alpha mode\r\n" );
	sh_toalpha();

	rsc_free();			/* free up AES resource	*/

	if ( D.s_size )			/* free the shel put library memory */
	{
	  D.s_size = 0;
	  Debug6( "Free shel_put memory\r\n" );
	  dos_free( ( LONG )D.s_save );
	}

	gsx_mfree();			/* free blt memory	*/
	Debug6( "Free blt memory\r\n" );

	dos_free( ( LONG )mn_addr );		/* menu bar address	*/		

	/* free_accs(); */			/* free up the acc's	*/
	
	/* freepds(); */			/* free the PD memory	*/

	Debug6( "Free window library memory\r\n" );

	wm_free();			/* free window library	*/

	mn_new();			/* Fixed 7/8/92		*/

	Debug6( "Into alpha mode\r\n" );
	gsx_escapes(2);			/* exit alpha mode	*/
	
	Debug6( "Unload fonts\r\n" );
	v_unload_font();		/* Unload fonts		*/
	Debug6( "Close work station\r\n" );
	gsx_wsclose();			/* close workstation	*/

i_7:
	cli();			
 	gl_ticktime = gsx_tick( tiksav, &tiksav );
	givecpm();			/* return trap2 vector	*/
	dos_free( ( LONG )runacc );
	sti();

	waitforaes();			/* get the semaphore */
#if 0
					/* destroy the semaphore */
	Psemaphore( 1, 0x5F4D5549L, 0x0L );
#else
	_inaes = 0;
#endif
	if ( ad_aescnf )
	{
	  dos_free( ( LONG )ad_aescnf );
	  ad_aescnf = (BYTE*)0;
	}	  

	/* reset the mouse on off */

	gsx_1code( SHOW_CUR, 0 );/* force mouse on to reset all the on/off flag	*/
	gsx_ncode( HIDE_CUR, 0, 0 );		/* now turn off the mouse */
	gl_moff = 1;
	gl_mouse = FALSE;		
}



	LONG
set_cache( newcacr )
	REG LONG newcacr;
{
#if 0
	asm( ".dc.w $4e7a,$0002" );	/* movec.l cacr,d0	*/
	asm( ".dc.w $4e7b,$7002" );	/* movec.l d7,cacr	*/
#endif
	#pragma inline asm_c1()	{ "$4e7a"; "0002"; }

	#pragma inline asm_c2()	{ "$4e7b"; "$7002"; }

	return( 0L );			/* Return a dummy LONG  */
}



/*	
*	Read in the GEM.CNF and store the data in the
*	shell buffer
*/

	VOID
r_aescnf( VOID )
{
	WORD	handle,bsize;
	BYTE	dta[60];
	LONG	*lptr;
	BYTE	name[40];	

	strcpy( AESCNF, name );
	name[0] = *((WORD*)0x446L ) + 'A';	/* get the boot device	*/

	dos_dta( ( LONG )dta );
					/* search GEM.CNF	*/
	if ( dos_sfirst( ( LONG )name, 0 ) )
	{
	  lptr = ( LONG *)&dta[26];
	  if ( ad_aescnf = ( BYTE *)dos_xalloc( (*lptr) + 1 , 3 ) )
	  {				/* read inf file	  */
	    handle = dos_open( name, 0 );
	    bsize = dos_read( handle, (WORD)(*lptr), ( LONG )ad_aescnf );
	    dos_close( handle );
	    ad_aescnf[bsize] = 0;	/* end of file mark	*/
	  }
	  return;
	}

/* if we didn't find it in the root, maybe it's in the MULTITOS
 * subdirectory
 */
	strcpy( AESCNF2, name );
	name[0] = *((WORD*)0x446L ) + 'A';	/* get the boot device	*/

					/* search GEM.CNF	*/
	if ( dos_sfirst( ( LONG )name, 0 ) )
	{
	  lptr = ( LONG *)&dta[26];
	  if ( ad_aescnf = ( BYTE *)dos_xalloc( (*lptr) + 1 , 3 ) )
	  {				/* read inf file	  */
	    handle = dos_open( name, 0 );
	    bsize = dos_read( handle, (WORD)(*lptr), ( LONG )ad_aescnf );
	    dos_close( handle );
	    ad_aescnf[bsize] = 0;	/* end of file mark	*/
	  }
	}
}	


/*	Skip to the next line	*/

	BYTE
*sk_tonext( ptr )
	REG BYTE	*ptr;
{
	while( *ptr )
	{
	  if ( ( *ptr == 0x0D ) || ( *ptr == 0xA ) )
	  {
	    ptr += 1;
	    if ( *ptr )
	    {
	      if ( ( *ptr == 0x0D ) || ( *ptr == 0xA ) )
	      {
	        ptr += 1;
	        break;
	      }
	    }
	    else
	      break;
	  }
	  ptr++;
	}
	
	return( ptr );
}



/*	Scan the GEM.CNF for special code	*/
	
	WORD
s_aescnf( name, function )
	BYTE	*name;
	WORD	(*function)( BYTE * );
{
	BYTE	*addr;
	BYTE	*dest;
	WORD	ret;

	ret = FALSE;

	if ( addr = ad_aescnf ) 
	{
	  while( *addr )
	  {
	    if ( *addr != '#' )
	    {
	      if ( nstrcmp( name, &addr ) )
	      {
	        dest = strscn( addr, &D.g_loc1[0], 0x0D );
	        if ( *(dest - 1 ) == 0x0A )
		  dest--;
	
	        *dest = 0;
	        ret = (*function)( &D.g_loc1[0] );
	      }
	    }
	    addr = sk_tonext( addr );	
	  }
	}

	return( ret );
}

	
	
/*
*	Preread the desktop.inf file and get the resolution set
*	accordingly. If there are no disks or a desktop.inf does
*	not exist or the resolutions match then return FALSE.
*/

	WORD
pred_dinf( VOID )
{
	WORD		i;
	WORD		res;
	WORD		cache;
	REG WORD	bsize, fh, change, cont;
	BYTE		*pbuf;
	REG BYTE	*temp;
	WORD		defdrv;

	gl_vdo = 0x0L;
				/* _VDO */		/* 7/17/92 */
	aescookie( 0x5F56444FL, &gl_vdo );

	bsize = sh_get( (BYTE*)0, -1 );	/* Inquire the size */

	if ( !( pbuf = ( BYTE *)dos_xalloc( (LONG)((UWORD)bsize), 3 ) ) )
	{
	  fm_alert( 1, ( LONG )"[1][AES - No inf file memory][ OK ]" );
	  return( 0 );
	}

	change = TRUE;			/* changed 1/7/93 ++ERS */
	sh_get( pbuf, bsize );

	fh = -1;		/* no .inf file read in yet */

/* set up defaults */
 	adeskp[0] = 0x41;	/* 4 = dithered, 1 = black */
	adeskp[1] = 0x73;	/* 7 = solid, 3 = green */
	adeskp[2] = 0x7D;	/* 7 = solid, D = light cyan */
	awinp[0] = 0x70;
	awinp[1] = 0x70;
	awinp[2] = 0x70;

	if ( ctldown )
	   goto p_1;

	if ( isdrive() )		/* there is a disk	*/
	{
	  defdrv = dos_gdrv();		/* save default drive	*/
	  dos_chdir( ( LONG )"\\");	/* open newdesk.inf	*/
	  fh = dos_open( "NEWDESK.INF", 0x0 );
	  if ( fh < 0 ) 		/* no file 		*/
	  {				/* try desktop.inf	*/
	    fh = dos_open( infdata, 0x0 );
	    if ( fh < 0 )		/* no file		*/	
	    {		
	      if ( isdrive() & 0x04 )	/* try the hard disk	*/
	      {
	        do_cdir( 2, "\\" );
	        fh = dos_open( "NEWDESK.INF", 0x0 );
		if ( fh < 0 ) {		/* failed to open	*/
	          fh = dos_open( infdata, 0x0 );
		}
	      }
	      else
	        goto p_1;
	    }
	  }

	  if ( fh >= 0 ) 		/* if no error then	*/
	  {				/* read inf file	*/
	    bsize = dos_read( fh, SIZE_AFILE, ( LONG )pbuf );
	    dos_close(fh);
	    change = TRUE;
	    dos_sdrv( defdrv );		/* set it back to default	*/
	  }
	}
					/* if we read it from disk, 	*/
					/* reschange may have changed.	*/
p_1:
	if (fh < 0)
		rom_ram( 3, pbuf );	/* res is default from ROM	*/
					/* we only need to do this if   */
					/* there was no .inf file 	*/
					/* added 2/9/93 hmk		*/
	if ( change )
	{
	  temp = pbuf;
	  temp[bsize] = NULL;
	  cont = TRUE;
	  while ( *temp && cont )
	  {
	    if (*temp != '#')
	      temp++;
	    else
	    {
	      temp++;		
	      switch( *temp )
	      {
#if 0
		case 'Z':		/* get the auto boot file	*/
	          if ( autoexec )	
	          {
		    temp += 2;		/* get the flag		*/
		    temp = scan2_2( temp, &g_flag );
		    temp = escan_str( temp, &g_autoboot[0] );
	          }
	          break;
	
		case 'B':		/* Set environment strings */
		  temp += 2;
		  temp = escan_str( temp, &D.g_loc1[0] );
		  sh_write( 8, 1, 0, &D.g_loc1[0], "" );
		  break;
#endif
		case 'Q':
		  temp += 2;
		  for (i = 0; i < 3; i++)
		  {
		    temp = scan2_2(temp, &adeskp[i]);
		    temp = scan2_2(temp, &awinp[i]);
		  }
		  break;
		case 'E':

		  if ( LONGFRAME )
		  {
		    scan2_2( temp+11, &cache );	/* fixed 6/26/90 Mui	*/
						/* fixed 7/17/92	*/
		    if ( cache & 2 )
		      set_cache( CACHE_ON );
		  }
		  else
		  {		/* turn on the bit ?		*/
		    scan2_2( temp + 5, &res );		/* 02/16/93 ERS and CJG */
		    xbios( ( ( res & 0xF0 ) >> 4 ) ?  0x00400001L : 0x00400000L );
		  }


					/* if sparrow mode 7/17/92	*/
		  if ( ( gl_vdo & HIGHWORD ) == FALCON )	
		  {			/* not an extended mode 	*/	
		    if ( gl_rschange )	/* 7/21/92 */
		    {
		      temp = save2_2( temp+14, a_rezword >> 8 ); 	
		      save2_2( temp, a_rezword );	
		    }
		    else
		    {
		      if ( *(temp+8) == 0xD || *(temp+14) == 0xD )
		      {
			temp += 5;
			scan2_2(temp, &res);
			a_rezword = res2mode(res & 0x0F);
		      }
		      else
		      {
		        temp += 14;
		        temp = scan2_2( temp, &res );
		        a_rezword = res << 8;
		        temp = scan2_2( temp, &res ); 	
		        a_rezword |= res;
	/* VGA monitors can't display 80 column true color modes */
			if (mon_type() == 2 &&	/* VGA monitor */
			    (a_rezword & NUMCOLS) == BPS16 &&
			    (a_rezword & COL80) )
			{
			  a_rezword &= ~NUMCOLS;
			  a_rezword |= BPS8;
			}
		      }
		    }
		  }	/* regular mode */
	 	  else
	 	  {
		    temp += 5;		/* skip other envr stuff	*/
		    scan2_2(temp, &res);	/* don't get the return code	*/

		    if ( gl_rschange )	/* if we've been here before	*/
		      save2_2( temp, (res & 0xF0 )|( res_type(gl_restype) ));
		    else
		    {
		      res &= 0xF;
		      gl_rschange = FALSE;
		      pref_save = res;	/* Set the desktop res number 	*/
		      a_rezword = res2mode(res);
		      if ( !sys_reschange( res_handle( res ) ) )
		        change = FALSE;	/* NO no res change		*/
		    }
		  }
		  break;

		default:
		  break;
	      } 
	    }
	  }
	}
				/* put in common area for special	*/
				/*  desk accessories			*/
	autoexec = FALSE;
	sh_put( pbuf, SIZE_AFILE );
	dos_free( ( LONG )pbuf );
	return ( change );
}



/*	This function is called when the start up procedure
 *	fails. It wait for a key to reboot
 */

	VOID
bailout( ptr )
	BYTE	*ptr;
{
				/* Must go to the screen */
	Cconws( ptr );
	Cconws( "Please reboot the machine!" );
	while( !Bconstat( 2 ) );
}

#ifdef LOADKBT

/*
 *	Try to read keyboard table from disk
 */
	MLOCAL VOID
set_kbdtbl()
{
	WORD	fd;
	KEYTAB	*kbtp;
	BYTE	*p;
	LONG	len;
	WORD	hdr;	/* header containig magic word */

	strcpy("C:\\MULTITOS\\KEYBD.TBL", KBTFNAME);
	KBTFNAME[0] = ( isdrive() & 0x4 ) ? 'C' : 'A';
	if ( ( fd = dos_open(KBTFNAME, RMODE_RD) ) >= 0 )
	{
	  len = dos_lseek(fd, 2, 0L);
	  if (len <= 0L)
		goto sl_end;
	  dos_lseek(fd, 0, 0L);
	  if ( dos_read( fd, (WORD)sizeof(WORD), (LONG)&hdr ) <= 0 )
		goto sl_end;
	  if (hdr != KBTMAGIC)	/* check magic word to see if it's a kbt */
		goto sl_end;  
	  if ((kbt_buf = dos_xalloc(len, 0)) == NULL)
		goto sl_end;
	  if ( dos_read( fd, (WORD) len, (LONG)kbt_buf ) > 0 )
	  {
		kbtp = (KEYTAB * ) Keytbl(-1L, -1L, -1L);
		kbtp->unshift = kbt_buf;	/* normal key table */
		kbtp->shift = (BYTE *) (kbt_buf + 128L); /* shifted */
		kbtp->capslock = (BYTE *) (kbt_buf + 256L); /* caps lock */
		/*
 		 * are there tables for the alternate key?
		 */
		if (len > KBTSTDLEN) {
			kbtp->altunsh = (BYTE *) (kbt_buf + 384L);
			/* the tables are nul terminated */
			for (p = kbtp->altunsh; *p; p++);
			kbtp->altsh = ++p;
			for (p = kbtp->altsh; *p; p++);
			kbtp->altcl = ++p;
		}
	  }
sl_end:
	  dos_close( fd );
	}
}
#endif






/*	Scan off and convert the next two hex digits and return with
	pcurr pointing one space past the end of the four hex digits
*/

	BYTE
*scan2_2(pcurr, pwd)
	REG BYTE		*pcurr;
	REG UWORD		*pwd;
{
	REG UWORD		temp;
	
	temp = 0x0;
	temp |= hex2_dig(*pcurr++) << 4;
	temp |= hex2_dig(*pcurr++);
	if (temp == 0x00ff)
	  temp = NIL;
	*pwd = temp;
	pcurr++;
	return(	pcurr );
}


/*	Reverse of scan2_2()	*/

	BYTE
*save2_2(pcurr, wd)
	REG	BYTE		*pcurr;
	UWORD		wd;
{
	*pcurr++ = uhex2_dig((wd >> 4) & 0x000f);
	*pcurr++ = uhex2_dig(wd & 0x000f);
	*pcurr++ = ' ';
	return(	pcurr );
}


/*	Reverse of hex_dig()	*/

	BYTE
uhex2_dig(wd)
	REG WORD		wd;
{
	if ( (wd >= 0) && (wd <= 9) )
	  return(wd + '0');
	
	if ( (wd >= 0x0a) && (wd <= 0x0f) )
	  return(wd + 'A' - 0x0a);

	return(' ');
}




/*
*	Convert a single hex ASCII digit to a number
*/

	WORD
hex2_dig(achar)
	REG BYTE		achar;
{
	if ( (achar >= '0') && (achar <= '9') )
	  return(achar - '0');
	
	if ( (achar >= 'A') && (achar <= 'F') )
	  return(achar - 'A' + 10);

	return(0);
}


/*
 * MiNT BIOS device replacement.
 * Under MiNT+MultiTOS, we redirect device -1 to point to this device,
 * to that old (buggy) programs that mix GEM and BIOS calls will
 * actually get all their input from the AES; i.e. Bconout(2) will
 * return "true" only if there is data available in the process' AES
 * buffer.
 */

struct kerinfo *bi_kernel;

#define BI_FWRITE (*bi_kernel->dos_tab[0x40])
#define BI_GETPID (*bi_kernel->dos_tab[0x10b])
#define BI_SYIELD (*bi_kernel->dos_tab[0xff])
#define BI_FCNTL  (*bi_kernel->dos_tab[0x104])

GLOBAL int consfd;

LONG BID_open(FILEPTR *f)
{
	(*bi_kernel->debug)("MT_open");
	f->flags |= O_TTY;
	return 0;
}

/* BUG: we only read 1 (long word) character at a time. That's fine
 * for what we're going to use this for (namely emulation
 * of BIOS I/O)
 */

LONG BID_read(FILEPTR *f, char *buf, LONG bytes)
{
	WORD pid;
	PD *pd;
	REG CQUEUE *qptr;
	REG LONG r;

	pid = (WORD) BI_GETPID();
	if (pid <= 0) return -1L;
	pd = systopd(pid);
	if (!pd) return 0;

	(*bi_kernel->debug)("BID_read(%ld)", bytes);
	qptr = &pd->p_cda.c_q;
	while (!qptr->c_cnt) {
		BI_SYIELD();
	}
/* BUG: technically we should grab the AES semaphore before
 * dequeueing characters. However, we're in supervisor mode
 * here, so no task switches can happen; and I'm not
 * certain that the current process doesn't already have the
 * AES semaphore!
 */

	r = (UWORD) dq( pd );
	r = ((r & 0x0000ff00L) << 8) | (r & 0x00ffL);
	*((long *)buf) = r;
	(*bi_kernel->debug)("BID_read: result is %lx", r);
	return 4L;
}

LONG BID_write(FILEPTR *f, char *buf, LONG bytes)
{
	long ret = 0;
/* BUG: the O_NDELAY flag doesn't work; doesn't matter,
 * we're the only legitimate users of this device
 */
	buf += 3;	/* point to the character part of the longword */
	while (bytes > 0) {
	    if (BI_FWRITE(consfd, 1L, buf) <= 0)
		break;
	    buf += 4; bytes -= 4; ret+= 4;
	}
	return ret;
}

#define FIONREAD	(('F'<< 8) | 1)
#define FIONWRITE	(('F'<< 8) | 2)

LONG BID_ioctl(FILEPTR *f, WORD mode, void *buf)
{
	PD *p;
	LONG *r = (LONG *)buf;
	CQUEUE *qptr;

	if (mode == FIONREAD) {
		p = systopd( BI_GETPID() );
		if (!p) return -1L;
		qptr = &p->p_cda.c_q;
		*r = qptr->c_cnt;
	} else if (mode == FIONWRITE) {
		*r = 1L;
	} else {
/* note that the kernel interface wants arguments in a different order
 * than we get, hence the reversal
 */
		return BI_FCNTL(consfd, buf, mode);
	}
	return 0;
}

LONG BID_error(FILEPTR *f)
{
	return -1;
}

LONG BID_close(FILEPTR *f, WORD pid)
{
	return 0;
}

/*
 * BUG: Fselect won't work. We don't care, we don't use it.
 */
LONG BID_select(FILEPTR *f, LONG p, WORD mode)
{
	return 1L;
}

VOID BID_unselect(FILEPTR *f, LONG p, WORD mode)
{
}

DEVDRV bi_devinfo = {
BID_open,	/* open */
BID_write,	/* write */
BID_read,	/* read */
(LONG (*)(FILEPTR *, LONG, WORD))BID_error,	/* lseek */
BID_ioctl,	/* ioctl */
(LONG (*)(FILEPTR *, WORD *, WORD))BID_error,	/* datime */
BID_close,	/* close */
BID_select,	/* select */
BID_unselect	/* unselect */
};

MLOCAL struct tty aestty;

struct dev_descr BID_descr = {
	&bi_devinfo,
	0,
	O_TTY,
	&aestty
};

VOID
bi_opendev( )
{
	bi_kernel = (struct kerinfo *)Dcntl(DEV_INSTALL, "U:\\DEV\\AES_BIOS",
						&BID_descr);

	biosfd = (WORD)Fopen("U:\\DEV\\AES_BIOS", 2);
	if (biosfd <= 0)
		bailout("Unable to open AES BIOS device\r\n");

/* open "consolefd" as a global file */
	consfd = (WORD)Fopen("U:\\DEV\\CONSOLE", 0x1002);

/* now redirect our CON: handle to point at AES_BIOS, so that all of our
 * children will do their BIOS I/O through the AES_BIOS device
 */
	Fforce(-1, biosfd);
}
