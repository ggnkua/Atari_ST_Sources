/*
*************************************************************************
*			Revision Control System
* =======================================================================
*  $Revision: 2.4 $	$Source: /u2/MRS/osrevisions/aes/geminit.c,v $
* =======================================================================
*  $Author: kbad $	$Date: 89/07/28 13:04:59 $	$Locker: kbad $
* =======================================================================
*  $Log:	geminit.c,v $
* Revision 2.4  89/07/28  13:04:59  kbad
* Added accs_init(), but there are still some strange interactions with
* the critical error handler, so it is bracketed by #ifdef ACC_DELAY.
* Also changed the desktop backdrop pattern to solid in color modes here,
* before gemshlib:sh_main() so that the autoboot application gets the
* right pattern drawn.  It still gets set in sh_main as well.
* 
* Revision 2.3  89/07/27  03:21:49  kbad
* gsx_malloc: min gl_mlen for TT = 0xc800L
* 
* Revision 2.2  89/04/26  18:24:25  mui
* TT
* 
* Revision 2.1  89/02/22  05:27:35  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.15  89/01/24  07:18:57  kbad
* Change to directory of autoboot app
* 
* Revision 1.14  88/10/24  12:27:53  mui
* Save 1/4 of the screen memory - added gsx_malloc
* 
* Revision 1.12  88/10/17  13:36:55  kbad
* Yanked fs_start to fix fs_input growing clip rect problem
* 
* Revision 1.11  88/09/22  04:49:42  kbad
* Moved rsrc_gaddr of desktop to before wm_start
* 
* Revision 1.10  88/09/08  18:57:55  kbad
* added <flavor.h> for DOWARNING flag
* 
* Revision 1.9  88/08/08  18:56:56  mui
* zero out the dispatcher list before bringing up system alert
* 
* Revision 1.8  88/08/08  12:32:38  mui
* don't wait for accessories to finish, they only get one chance to run
* 
* Revision 1.7  88/08/05  16:38:52  mui
* add escape button
* 
* Revision 1.6  88/08/04  19:29:19  mui
* at autoboot, wait until all the acc finish their work before we go
* into the auto boot sequence
* 
* Revision 1.4  88/08/02  13:03:15  kbad
* changed dowarning box to match build date of 1.04d 8/1/88
* 
* Revision 1.3  88/07/28  17:29:06  mui
* Nothing
* 
* Revision 1.2  88/07/15  16:08:31  mui
* add warning message
* 
* Revision 1.1  88/06/02  12:34:14  lozben
* Initial revision
* 
*************************************************************************
*/
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
/*	Fixed the background pattern in TT high	11/14/90	D.Mui	*/
/*	Init the current mouse form		5/8/91		D.Mui	*/
/*	Check control key for nodisk system at main 8/13/91	D.Mui	*/
/*	Exit graphic mode before closing work station 12/20/91		*/
/*	Change at gsx_malloc for saving 25 columns of screen 7/7/92 Mui	*/
/*	Add 3D stuff				7/7/92		D.Mui	*/
/*	Add code to do sparrow res change	7/17/92		D.Mui	*/
/*	Add new variables			8/1/92		D.Mui	*/

/*	-------------------------------------------------------------
*	GEM Application Environment Services		  Version 1.0
*	Serial No.  XXXX-0000-654321		  All Rights Reserved
*	Copyright (C) 1985			Digital Research Inc.
*	-------------------------------------------------------------
*/

#include <portab.h>
#include <machine.h>
#include <struct88.h>
#include <baspag88.h>
#include <obdefs.h>
#include <gemlib.h>
#include <taddr.h>
#include <gemusa.h>
#include <funcdef.h>
#include <osbind.h>
#include <vdidefs.h>
#include <mode.h>

#define DOWARNING	0	/* Do we need initial warning box ? 	     */
				/* There is also a flag in Gemjstrt.s:       */
				/* 'dodowarn', which must be set along       */
				/* with the value of DOWARNING               */

#define CACHE_ON	0x00003919L
#define CACHE_OFF	0x00000808L
#define LONGFRAME	*(WORD *)(0x59eL)

EXTERN BYTE	*save_2();
EXTERN BYTE	*dos_alloc();
EXTERN WORD	dos_open();
EXTERN WORD	dos_read();
EXTERN WORD	dos_close();
EXTERN WORD	dos_sdrv();
EXTERN WORD	isdrive();
EXTERN WORD	app_reschange();
EXTERN BYTE	*scan_2();
EXTERN BYTE	*escan_str();
EXTERN WORD	rom_ram();
EXTERN WORD	sh_get();
EXTERN WORD	sh_put();

EXTERN	WORD	xrat;
EXTERN	WORD	yrat;
EXTERN WORD	gl_rschange;
EXTERN WORD	gl_restype;
EXTERN WORD	DOS_ERR;
EXTERN WORD	gl_ncols;
EXTERN WORD	gl_nrows;
EXTERN WORD	gl_hchar;
EXTERN WORD	gl_wchar;
EXTERN WORD	gl_height;

EXTERN	WORD	gl_hbox;
EXTERN WORD	diskin;		/* in gemjstrt.s	*/

EXTERN LONG	ad_shcmd;
EXTERN LONG	ad_shtail;
EXTERN WORD	sh_gem;
EXTERN WORD	sh_doexec;

EXTERN BYTE	infdata[];
EXTERN LONG	ad_intin;
						
#define ARROW 0
#define HGLASS 2

						/* in DOSIF.A86		*/
EXTERN		cli();
EXTERN		sti();
EXTERN		takecpm();
EXTERN		givecpm();
						/* in GEMCTRL.C		*/
EXTERN PD	*ictlmgr();
						/* in GEMCLI.C		*/
EXTERN VOID	ldaccs();
						/* in SHLIB.C		*/
EXTERN VOID	sh_main();

EXTERN UWORD	d_rezword;
EXTERN WORD	gl_recd;
EXTERN WORD	gl_rlen;
EXTERN LONG	gl_rbuf;

EXTERN PD	*gl_mowner;
EXTERN PD	*gl_kowner;
EXTERN PD	*ctl_pd;

EXTERN LONG	ad_shcmd;
EXTERN LONG	ad_shtail;

EXTERN LONG	ad_path;
EXTERN LONG	ad_windspb;

EXTERN  WORD	intin[];
EXTERN	WORD	ptsout[];
EXTERN  WORD	intout[];
EXTERN  WORD	hdr_buff[];


EXTERN TEDINFO	edblk;
EXTERN BITBLK	bi;
EXTERN ICONBLK	ib;

EXTERN WORD	gl_bclick;
EXTERN WORD	gl_bdesired;
EXTERN WORD	gl_btrue;
EXTERN WORD	gl_bdelay;

EXTERN LONG	tikaddr;
EXTERN LONG	tiksav;
EXTERN WORD	gl_ticktime;

EXTERN THEGLO	D;

EXTERN	WS	gl_ws;
EXTERN	LONG	gl_mlen;
EXTERN	FDB	gl_tmp;
EXTERN	WORD	gl_nplanes;
EXTERN	MFORM	gl_cmform;
EXTERN	MFORM	gl_omform;

GLOBAL WORD	do_once;
GLOBAL EVB	evx;
GLOBAL LONG	gl_vdo;
GLOBAL LONG	ad_sysglo;
GLOBAL LONG	ad_armice;
GLOBAL LONG	ad_hgmice;
GLOBAL LONG	ad_stdesk;
GLOBAL LONG	ad_fsel;
GLOBAL LONG	drawstk;

GLOBAL WORD	er_num;		/* for output.s	*/
GLOBAL WORD	no_aes;		/* gembind.s	*/
GLOBAL WORD	sh_up;		/* is the sh_start being ran yet ? */
GLOBAL WORD	autoexec;	/* autoexec a file ?	*/
GLOBAL BYTE	g_autoboot[128];
GLOBAL WORD	g_flag;
GLOBAL WORD	ctldown;	/* ctrl key down ?	*/
/* 8/1/92 */
GLOBAL UWORD	act3dtxt;	/* look of 3D activator text */
GLOBAL UWORD	act3dface;	/* selected look of 3D activator */
GLOBAL UWORD	ind3dtxt;	/* look of 3D indicator text */
GLOBAL UWORD	ind3dface;	/* selected look of 3D indicators */
GLOBAL UWORD	gl_indbutcol;	/* indicator button color */
GLOBAL UWORD	gl_actbutcol;	/* activator button color */
GLOBAL UWORD	gl_alrtcol;	/* alert background color */

GLOBAL WORD	crt_error;	/* critical error handler semaphore	    */
				/* set in jbind.s, checked by dispatcher    */

GLOBAL WORD	adeskp[3];	/* desktop colors & backgrounds */
GLOBAL WORD	awinp[3];	/* window colors & backgrounds */

EXTERN BYTE *strcpy();		/* optimize.s	*/
EXTERN BYTE *sh_name();		/* gemshlib.c	*/
EXTERN WORD do_cdir();		/* jdos.s	*/

MLOCAL BYTE autopath[128];

#if DOWARNING
GLOBAL WORD	dowarn;
#endif

EXTERN WORD	button;


#ifdef ACC_DELAY

/* The AES startup code should wait for all accessories to finish initializing
 * before it starts the first main process running.  To determine that all
 * accessories have initialized, we will wait until every accessory is blocked
 * waiting for a message event.
 *
 * A process with a message block can be identified by walking the PD's EVB
 * list, and finding an EVB that is not an EVDELAY and is not pointed to
 * by anything in the PD's CDA.  This EVB is a message EVB by process of
 * elimination.
 *
 * Thus, we can loop until all accessories have a blocked waiting for a
 * message event with the following code:
 */
extern PD	*fpdnm(); /* given name and/or pid, return the PD */
extern		sh_tographic();

accs_init()
{
	PD	*pd;
REG	EVB	*e, *ce;
REG	CDA	*c;
	BOOLEAN	notdone;
REG	WORD    pid;

    sh_tographic();
    do {
    /* initialize to DONE, change if we find one with no message block */
	notdone = FALSE;
    /* let everybody run */
	all_run();

    /* look at all accessory EVB lists (ctlmgr==0, screenmgr==1) */
	pid = 2;
	pd = fpdnm( NULLPTR, pid );
	while( pd ) {
	    c = pd->p_cda;
        /* walk through EVB list looking for CDA matches */
	    for( ce = -1L, e = pd->p_evlist; ce && e; e = e->e_nextp ) {
            /* timer wait? */
		if( e->e_flag & EVDELAY ) continue;
            /* input block? */
		for( ce = c->c_iiowait; ce && ce != e; ce = ce->e_link );
		if( ce == e ) continue;
            /* mouse rect? */
		for( ce = c->c_msleep; ce && ce != e; ce = ce->e_link );
		if( ce == e ) continue;
            /* button wait? */
		for( ce = c->c_bsleep; ce && ce != e; ce = ce->e_link );
            /* if ce is null here, we found a message EVB */
	    }
	    if( ce ) {
	    /* found one w/ no message blocks, or w/ NO event blocks */
	    /* fall out and let 'em run */
		notdone = TRUE;
		pd = NULLPTR;
	    } else {
	    /* this guy had a message block, try the next pd */
		pd = fpdnm( NULLPTR, ++pid );
	    }
	}

    } while( notdone );
}
#endif ACC_DELAY


/*	Set the resolution	*/

	VOID	
setres()
{
	int	mode;

	if ( ( gl_vdo & 0x30000L ) == 0x30000L )
	{
	  intin[0] = 5;
	  d_rezword = trap14( 95, d_rezword );
/*	  ptsout[0] = d_rezword;	*/
	  gl_ws.ws_pts0 = d_rezword;	
	}
}


main()
{
	REG WORD		i;
	LONG		tmpadbi;
	LONG		tree;
	REG THEGLO		*DGLO;
	PD		*slr;
	REG BYTE		*apath;

	DGLO = &D;


	er_num = ALRT04CRT;			/* output.s		*/
	no_aes = ALRTNOFUN;			/* for gembind.s	*/

				
	/****************************************/				
	/*		ini_dlongs();		*/
	/****************************************/

	ad_shcmd = &DGLO->s_cmd[0];
	ad_shtail = &DGLO->s_tail[0];
	ad_path = &DGLO->g_dir[0];

				/* init. long pointer to global array	*/
				/* which is used by resource calls	*/

	ad_sysglo = &DGLO->g_sysglo[0];
	ad_windspb = &wind_spb;

	/****************************************/


	drawstk = dos_alloc (0x00000400L);	/* draw stack is 1K	*/
	drawstk += (0x00000400L);		/* init to top		*/

	
						/* no ticks during init	*/
	hcli();

						/* take the 0efh int.	*/
	takecpm();
						/* init event recorder	*/
	gl_recd = FALSE;
	gl_rlen = 0;
	gl_rbuf = 0x0L;
						/* initialize pointers	*/
						/*   to heads of event	*/
						/*   list and thread	*/
						/*   list		*/
	elinkoff = (BYTE *) &evx.e_link - (BYTE *) &evx;
						/* link up all the evb's*/
						/*   to the event unused*/
						/*   list		*/
	eul = 0;	
	for( i = 0; i < NUM_EVBS; i++ )
	{
	  DGLO->g_evb[i].e_nextp = eul;
	  eul = &DGLO->g_evb[i];
	}
						/* initialize list	*/
						/*   and unused lists	*/

	drl = 0;
	nrl = 0;
	zlr = 0;
	dlr = 0;
	fpcnt = 0;
	fpt = 0;
	fph = 0;
	infork = 0;
	crt_error = FALSE;
						/* initialize sync	*/
						/*   blocks		*/
	wind_spb.sy_tas = 0;
	wind_spb.sy_owner = 0;
	wind_spb.sy_wait = 0;

	gl_btrue = 0x0;
	gl_bdesired = 0x0;
	gl_bdelay = 0x0;
	gl_bclick = 0x0;
						/* init initial process	*/
	for( i = 0; i < NUM_PDS; i++ )
	  pinit(&DGLO->g_pd[i], &DGLO->g_cda[i]);

	DGLO->g_pd[0].p_uda = &DGLO->g_uda;
	DGLO->g_pd[1].p_uda = &DGLO->g_2uda;
	DGLO->g_pd[2].p_uda = &DGLO->g_3uda;
						/* if not rlr then	*/
						/* initialize his	*/
						/* stack pointer	*/

	DGLO->g_2uda.u_spsuper = &DGLO->g_2uda.u_supstk;
	DGLO->g_3uda.u_spsuper = &DGLO->g_3uda.u_supstk;

	curpid = 0;

	rlr = &DGLO->g_pd[curpid];
	rlr->p_pid = curpid++;
	rlr->p_link = 0;
	rlr->p_stat = PS_RUN;
	cda = rlr->p_cda;
						/* restart the tick	*/
	hsti();

						/* screen manager 	*/
						/* process init. this	*/
						/* process starts out	*/
						/* owning the mouse	*/
						/* and the keyboard.	*/
						/* it has a pid == 1	*/
	gl_mowner = gl_kowner = ctl_pd = ictlmgr(rlr->p_pid);

	/* New stuff 8/13/91	*/

	ctldown = Getshift( -1 ) & 0x0004 ? TRUE : FALSE;


	rsc_read();				/* read in resource	*/

	if ( !ctldown )
	  ldaccs();				/* load in accessories	*/

	pred_dinf();				/* pre read the inf	*/
						/* get the resolution 	*/
						/* and the auto boot 	*/
						/* name			*/

						/* load gem resource	*/
						/*   and fix it up 	*/
						/*   before we go	*/


						/* load all desk acc's	*/

						/* init button stuff	*/
	set_defdrv();				/* set default drive	*/

						/* do gsx open work	*/
						/*   station	 	*/
	gsx_init();

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


	rom_ram( 0, ad_sysglo );

	rs_gaddr(ad_sysglo, R_BIPDATA, MICE0, &ad_armice);
	ad_armice = LLGET(ad_armice);
	rs_gaddr(ad_sysglo, R_BIPDATA, MICE2, &ad_hgmice);
	ad_hgmice = LLGET(ad_hgmice);

	gl_cmform = *( (MFORM*)ad_hgmice );
				/* fix up icons		*/
	for( i = 0; i < 3; i++ )
	{
	  rs_gaddr(ad_sysglo, R_BITBLK, i, &tmpadbi);
	  LBCOPY(ADDR(&bi), tmpadbi, sizeof(BITBLK));
/*	  gsx_trans(bi.bi_pdata, bi.bi_wb, bi.bi_pdata, bi.bi_wb, bi.bi_hl);	*/
	}
						/* take the critical err*/
						/*   handler int.	*/
	cli();
	takeerr();
	sti();

	sh_tographic();				/* go into graphic mode	*/
	sh_gem = TRUE;

						/* take the tick int.	*/
	cli();
	gl_ticktime = gsx_tick(tikaddr, &tiksav);
	sti();
						/* set init. click rate	*/
	ev_dclick(3, TRUE);
						/* get st_desk ptr	*/
	rs_gaddr(ad_sysglo, R_TREE, SCREEN, &ad_stdesk);
	tree = ad_stdesk;
						/* fix up the GEM rsc.	*/
						/*   file now that we	*/
						/*   have an open WS	*/ 

/* This code is also in gemshlib, but it belongs here so that the correct
 * default GEM backdrop pattern is set for accessories and autoboot app.
 */
	i = trp14( 4 );
	if ( i != 2 && i != 6 ) 	/* set solid pattern in color modes */
          LLSET( ad_stdesk+12, 0x00001173L );
	else
          LLSET( ad_stdesk+12, 0x00001143L );

	wm_init();
	mn_init();
		
	ini_fsel();

				/* startup gem libs	*/
/*	fs_start();*/

	for( i = 0; i < 3; i++ )
	  LWSET( OB_WIDTH(i), ( gl_wchar * gl_ncols ) );

	LWSET( OB_HEIGHT(0),( gl_hchar * gl_nrows ) );
	LWSET( OB_HEIGHT(1), (gl_hchar + 2));
	LWSET( OB_HEIGHT(2), (gl_hchar + 3));

	rs_gaddr(ad_sysglo, R_STRING, FSTRING, &ad_fsel);

	indisp = FALSE;			/* init in dispatch semaphore	*/
					/* to not indisp		*/
#if DOWARNING
	if ( !dowarn )
	{
	  slr = drl;			/* save the dispatcher list 	*/
	  drl = 0;			/* Don't allow anybody to run	*/
	  fm_alert( 0, "[1][\
 \016\017 Developer Release \016\017 |\
    08/08/88  TOS 1.4 |\
 |\
 WARNING: This OS release |\
         is NOT supported. ]\
[Launch TOS]" );
	  dowarn = TRUE;

	  drl = slr;			/* restore it		*/
	}
#endif

					/* off we go !!!	*/
	dsptch();

#ifdef ACC_DELAY
	accs_init();
#else
					/* let them run		*/
	all_run();
#endif


	if ( g_autoboot[0] )	/* if there is a auto boot program */
	{
#ifndef ACC_DELAY
	  for ( i = 0; i < 6; i++ )	/* let the acc's have a chance	*/
	    all_run();
#endif
					/* change to dir of autoboot	*/
	  apath = &autopath[0];
	  strcpy( g_autoboot, apath );
	  *(sh_name( apath )) = 0;	/* change path\filename to path */
	  do_cdir( apath[0]-'A', apath );

	  sh_write( 1, ( g_flag -  0 ), 0, &g_autoboot[0], "" );
	}

	do_once = FALSE;		/* desktop do it once flag */
	sh_main();

	rsc_free();			/* free up resource	*/

	drawstk -= (0x00000400L);	/* reset to bottom	*/
	dos_free(drawstk);

	gsx_mfree();
	mn_new();

	cli();
	giveerr();
	sti();

						/* free up the acc's	*/
	free_accs();
						/* free up special glue	*/
						/* give back the tick	*/
	cli();
 	gl_ticktime = gsx_tick(tiksav, &tiksav);
	sti();

	gsx_escapes(2);				/* exit alpha mode	*/

						/* close workstation	*/
	gsx_wsclose();

						/* return GEM's 0xEF int*/
	cli();
	givecpm();
	sti();
}

/*	process init	*/

	VOID
pinit(ppd, pcda)
	REG PD	*ppd;
	CDA	*pcda;
{
	ppd->p_cda = pcda;
	ppd->p_qaddr = &ppd->p_queue[0];
	ppd->p_qindex = 0;
	bfill(8, ' ', &ppd->p_name[0]);
}


LONG
set_cache( newcacr )
REG LONG newcacr;
{
	asm( ".dc.w $4e7a,$0002" );	/* movec.l cacr,d0	*/
	asm( ".dc.w $4e7b,$7002" );	/* movec.l d7,cacr	*/
}

/*
*	pre read the desktop.inf file and get the resolution set
*	accordingly. If there are no disks or a desktop.inf does
*	not exist or the resolutions match then return FALSE.
*
* ++ERS 1/14/93: also read the preferred desktop backgrounds
*/
	WORD
pred_dinf()
{
	WORD		res;
	WORD		cache;
	REG WORD	bsize, fh, change, cont;
	BYTE		*pbuf;
	REG BYTE	*temp;
	WORD		defdrv;
	BYTE		*chrptr;
	WORD		i;

	gl_vdo = 0x0L;
				/* _VDO */		/* 7/17/92 */
	getcookie( 0x5F56444FL, &gl_vdo );

	
	g_autoboot[0] = 0;
	pbuf = dos_alloc( (LONG)SIZE_AFILE );
	change = FALSE;
	sh_get( pbuf, SIZE_AFILE );

        rom_ram( 3, pbuf, NULL );	/* res is default from ROM	*/

	adeskp[0] = 0x41;	/* 4 = dither, 1 = black */
	adeskp[1] = 0x73;	/* 7 = solid color, 3 = green */
	adeskp[2] = 0x7D;	/* 7 = solid color, D = light cyan */
	awinp[0] = 0x70;
	awinp[1] = 0x70;
	awinp[2] = 0x70;

	if ( ctldown )
	  goto p_1;

	if ( isdrive() && diskin )	/* there is a disk	*/
	{
	  defdrv = dos_gdrv();		/* save default drive	*/
	  dos_chdir("\\");		/* open newdesk.inf	*/
	  fh = dos_open( "NEWDESK.INF", 0x0 );
	  if ( DOS_ERR ) 		/* no file 		*/
	  {				/* try desktop.inf	*/
	    fh = dos_open( infdata, 0x0 );
	    if ( DOS_ERR )		/* no file		*/	
	    {		
	      if ( isdrive() & 0x04 )	/* try the hard disk	*/
	      {
	        do_cdir( 2, "\\" );
	        fh = dos_open( "NEWDESK.INF", 0x0 );
		if ( DOS_ERR )		/* failed to open	*/
	          fh = dos_open( infdata, 0x0 );
	      }
	      else
	        DOS_ERR = 1;
	    }
	  }

	  if ( !DOS_ERR  ) 		/* if no error then	*/
	  {				/* read inf file	*/
	    bsize = dos_read(fh, SIZE_AFILE, pbuf);
	    dos_close(fh);
	    change = TRUE;
	    dos_sdrv( defdrv );		/* set it back to default	*/
	  }
	}
					/* if we read it from disk, 	*/
					/* reschange may have changed.	*/
p_1:
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
	      temp++;			/* get the auto boot file	*/
	      if ( ( *temp == 'Z' ) && ( autoexec ) )	
	      {
		temp += 2;		/* get the flag		*/
		temp = scan_2( temp, &g_flag );
		temp = escan_str( temp, &g_autoboot[0] );
	      }	
	      else if ( *temp == 'Q' )
	      {
	        temp += 2;
		for (i = 0; i < 3; i++)
		{
		  temp = scan_2( temp, &adeskp[i] );
		  temp = scan_2( temp, &awinp[i] );
		}
	      }
	      else if ( *temp == 'E' )
	      {
		if ( LONGFRAME )
		{
		  scan_2( temp+11, &cache );	/* fixed 6/26/90 Mui	*/
						/* fixed 7/17/92	*/
		  if ( cache & 2 )
		    set_cache( CACHE_ON );
		}
		else
		{	/* turn on the bit ?		*/
		  trp14( ( ( res & 0xF0 ) >> 4 ) ?  0x00400001L : 0x00400000L );
		}
					/* if sparrow mode 7/17/92	*/
		if ( ( gl_vdo & 0xFFFF0000L ) == 0x00030000L )	
		{			/* not an extended mode 	*/	
		  if ( gl_rschange )	/* 7/21/92 */
		  {
		    temp = save_2( temp+14, d_rezword >> 8 ); 	
		    save_2( temp, d_rezword );	
		  }
		  else
		  {	
		    if ( *(temp+14) != 0xD )
		    {
		      temp += 14;
		      temp = scan_2( temp, &res );
		      d_rezword = res << 8;
		      temp = scan_2( temp, &res ); 	
		      d_rezword |= res;  	
		    }
		    else
		      break;
		  }
		}
		else
		{
		  temp += 5;		/* skip other envr stuff	*/
		  scan_2(temp, &res);	/* don't get the return code	*/
		  if ( gl_rschange )	/* if we've been here before	*/
		    save_2( temp, (res & 0xF0 )|( gl_restype ));
		  else
		  {	
		    res &= 0xF;
		    gl_rschange = FALSE;
		    if ( !app_reschange( res ) )
		      change = FALSE;	/* NO no res change		*/
		  } 
		}
	      }
	    }
	  }
	}
				/* put in common area for special	*/
				/*  desk accessories			*/
	autoexec = FALSE;
	sh_put( pbuf, SIZE_AFILE );
	dos_free( pbuf );
	return ( change );
}


/*     Save 25 columns and full height of the screen memory	*/

	WORD
gsx_malloc()
{
	LONG	len;
	
	gsx_fix( &gl_tmp, 0x0L, 0x0L );
	len = (LONG)((UWORD)gl_wchar) * (LONG)25 * (LONG)((UWORD)gl_height)
		    * (LONG)((UWORD)gl_nplanes);
	len = len / 8;
	gl_mlen = len;
	gl_tmp.fd_addr = dos_alloc( gl_mlen ); 
	if ( !gl_tmp.fd_addr )
	{
	  gl_mlen = 0;
	  trap( 9, "Unable to alloc AES blt buffer!\r\n" );
	  return( FALSE );
	}
}


/*	return TRUE if HARD DISK	*/
/*	Doesn't NEED to return anything -- 881109 kbad */

set_defdrv()
{
/* This fugly statement gets drvbits, masks drive C,
*  and does a GEMDOS Setdrive to drive A (0) if C doesn't exist,
*  or to C (2) if it does exist.  Don't ask.  It had to be shrunk.
*/
	dos_sdrv( (isdrive() & 0x04) >> 1 );
/*
*	WORD	ret;
*	if (isdrive() & 0x04)
*	{
*	  dos_sdrv(0x02);
*	  return(TRUE);
*	}
*	else
*	{
*	  dos_sdrv(0x0);
*	  return(FALSE);
*	}	
*/
}


	WORD
gsx_xmfset( pmfnew )
	LONG		pmfnew;
{
	gsx_moff();
	LWCOPY(ad_intin, pmfnew, 37);
 	gsx_ncode(ST_CUR_FORM, 0, 37);
	gsx_mon();
}


	WORD
gsx_mfset( pmfnew )
	LONG		pmfnew;
{
	gsx_moff();
	gl_omform = gl_cmform;
	LWCOPY(ad_intin, pmfnew, 37);
 	gsx_ncode(ST_CUR_FORM, 0, 37);
	gl_cmform = *( (MFORM*)pmfnew );
	gsx_mon();
}


/*	Graf mouse		*/

	VOID
gr_mouse( mkind, grmaddr )
	REG WORD	mkind;
	MFORM		*grmaddr;
{
	LONG		maddr;
	MFORM		omform;

	if ( mkind > 255 )
  	{
	  switch( mkind )
	  {
            case 256:
  	      gsx_moff();
	      break;
	    
   	    case 257:
  	      gsx_mon();
	      break;
	
	    case 258:		/* save mouse form	*/
	      rlr->p_mouse = gl_cmform;
	      break;
		
	    case 259:		/* restore saved mouse form	*/
	      omform = rlr->p_mouse;
	      gsx_mfset( &omform );
	      break;

	    case 260:		/* restore previous mouse form	*/
	      omform = gl_omform;
	      gsx_mfset( &omform );
	      break;
	  }
       	}
       	else
       	{
          if ( mkind != 255 )		/* set new mouse form	*/
  	  {
  	    rs_gaddr(ad_sysglo, R_BIPDATA, 3 + mkind, &maddr);
  	    grmaddr = LLGET(maddr);
  	  }

          gsx_mfset( grmaddr );
      	}
}

/*	Change code to compensate 3D objects	*/

	WORD
gr_slidebox(tree, parent, obj, isvert)
	REG LONG		tree;
	WORD		parent;
	WORD		obj;
	WORD		isvert;
{
	REG GRECT	*pt, *pc;	/* new pointer for Reg Opt	*/
	GRECT		t, c;
	REG LONG	divnd, divis;
	OBJECT		*objc;
	WORD		pflags,cflags;
	WORD		ret,setxy,setwh;

	pt = &t;
	pc = &c;
				/* get the parent real position */
	ob_actxywh(tree, parent, pc);
				/* get the relative position	*/
	ob_relxywh(tree, obj, pt);

	objc = tree;
 	pflags = objc[parent].ob_flags;
	cflags = objc[obj].ob_flags;	

	if ( ( pflags & IS3DOBJ ) )
	  pflags = 1;
	else
	  pflags = 0;

	if ( ( cflags & IS3DOBJ ) )
	  cflags = 1;
	else
	  cflags = 0;
	  
	setxy = 0;

	if ( cflags ) 	/* if the child is 3D, then check 	    */
	{	
	  if ( !pflags ) /* if parent is not 3D, then the child is   */
	  {		/* ADJ3DPIX off, we need to adjust it	    */
  	    pt->g_x -= ADJ3DPIX;
	    pt->g_y -= ADJ3DPIX;
	    setxy = 1;	
	  }	
	  pt->g_w += (ADJ3DPIX << 1);
	  pt->g_h += (ADJ3DPIX << 1);
	}

	gr_dragbox( pt->g_w, pt->g_h, pt->g_x + pc->g_x, pt->g_y + pc->g_y, 
		    pc, &pt->g_x, &pt->g_y ); 

	if ( isvert )		/* vertical movement	*/
	{
	  divnd = pt->g_y - pc->g_y;
	  divis = pc->g_h - pt->g_h;
	}
	else			/* horizontal movement	*/
	{
	  divnd = pt->g_x - pc->g_x;
	  divis = pc->g_w - pt->g_w;
	}

	if ( setxy )
	{
	  if ( divnd )
  	    divnd += ADJ3DPIX;
	}

	if (divis)
	{
	  ret = ( divnd * 1000 ) / divis;
	  if ( ret > 1000 )
	    ret = 1000;
	  return( ret );
	}	
	else
	  return(0);
}


/*
*	Routine to watch the mouse while the button is down and
*	it stays inside/outside of the specified rectangle.
*	Return TRUE as long as the mouse is down.  Block until the
*	mouse moves into or out of the specified rectangle.
*/

	WORD
gr_stilldn(out, x, y, w, h)
	WORD		out, x, y, w, h;
{
/*	WORD		rets[6];*/
	WORD		status;
/*	WORD		state;	*/
					/* compiler had better	*/
					/*   put the values out,*/
					/*   x, y, w, h in the	*/
					/*   right order on the	*/
					/*   stack to form a	*/
					/*   MOBLK		*/
	while( TRUE )
	{
	  forker();
	  if ( !( button & 0x01 ) )
	  {
	    status = FALSE;		
	    break;
	  }
	  else
	  {
	    if ( out != inside( xrat, yrat, &x ) )
	    {
	      status = TRUE;
	      break;
	    }
 	  }  	
	}
	return( status );
} /* gr_stilldn */


#if 0
/*
*	Routine to watch the mouse while the button is down and
*	it stays inside/outside of the specified rectangle.
*	Return TRUE as long as the mouse is down.  Block until the
*	mouse moves into or out of the specified rectangle.
*/

	WORD
gr_stilldn(out, x, y, w, h)
	WORD		out, x, y, w, h;
{
	WORD		rets[6];
	WORD		event;

					/* compiler had better	*/
					/*   put the values out,*/
					/*   x, y, w, h in the	*/
					/*   right order on the	*/
					/*   stack to form a	*/
					/*   MOBLK		*/
	while(1)
	{
	  event = ev_multi( MU_BUTTON|MU_M1|MU_TIMER, &out, NULLPTR, 0x0L,
			  0x00010100L, 0x0L, &rets[0] );/* 01ff00L */

	  if ( event & MU_BUTTON )	/* button up */
	    return( FALSE );

	  if ( event & MU_M1 )
	    return(TRUE);

	  if ( event & MU_TIMER )
	  {
	    if ( !( rets[2] & 0x01 ) )
	      return( FALSE );	
	  }
	}
} /* gr_stilldn */
#endif
