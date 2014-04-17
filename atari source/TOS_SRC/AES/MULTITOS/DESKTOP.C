/*	DESKTOP.C		3/15/89 - 7/26/89	Derek Mui	*/
/*	Take out vdi_handle	6/28/89					*/
/*	Read in icn file	9/23/89			D.Mui		*/
/*	New adj_menu to adjust menu	6/27/90		D.Mui		*/
/*	Take the wind_update in deskmain	8/9/90	D.Mui		*/
/*	Add m_cpu to check CPU	9/19/90			D.Mui		*/
/*	Fix the cache menu so that it checks the cache when menu is down*/
/*					10/24/90	D.Mui		*/
/*	Moved the wind_set in the main to just before menu_bar. It is 	*/
/*	to fix the acc problem			12/4/90	D.Mui		*/
/*	Change appl_init to ap_init and appl_exit to ap_exit 4/3/91	*/
/*	Add wm_update before bringing up the menu bar 4/18/91 Mui	*/
/*	Install desktop critical error handler	4/22/91	D.Mui		*/
/*	Rename deskmain to desktop		5/1/91	D.Mui		*/
/*	Check control key for nodisk system at re_icon 8/13/91	D.Mui	*/
/*	Change all the iconblk to ciconblk	7/11/92	D.Mui		*/
/*      Load rsc file from disk			2/10/92 H.Krober        */
/*	Start the separation of desktop and aes 3/18/93 C.Gee		*/
/*	Implement flags for PRG vs SYS version  4/14/93 C.Gee		*/
/*	Speedo GDOS font support in windows	5/25/83 H.Krober	*/ 

/************************************************************************/
/*	New Desktop for Atari ST/TT Computer				*/
/*	Atari Corp							*/
/*	Copyright 1989,1990 	All Rights Reserved			*/
/************************************************************************/

#include "portab.h"
#include "machine.h"
#include "obdefs.h"
#include "deskdefi.h"
#include "deskwin.h"
#include "osbind.h"
#include "extern.h"
#include "mintbind.h"	
#include "signal.h"
#include "vdomode.h"
#include "deskusa.h"
#if 0
#include "linea.h"
#endif
#include "pdesk.h"
#include "pmisc.h"
#include "pboth.h"
#include "softload.h"
/*
 *	Set the SOFTLOAD flag to implement softloaded desktop resources.
 *	The desktop will then try to read its resource file from
 *	[A|C]:\MULTITOS\DESKTOP.RSC. If the load failes because the file
 *	is not present, a file selector box will ask the user to find
 * 	the resource file for the system. If this dialog box is exited
 *	using the 'Cancel' button, the resource will be copied from ROM.
 *
 *	NOTE: You have to define SOFTLOAD in deskrom.c, too, because there
 *	      are the actual functions.
 *
 *	See the Defines in SOFTLOAD.H
 */

/*
 *	Turn on resource file version number checking by setting the
 *	DESKRSVER to 1. Use "rscvers versnr DESKTOP.RSC"
 *	to create a DESKTOP.RSC with a version number in the first byte of the
 *	resource header. This is to prevent user from using the wrong
 *	resource file.
 *	See the Defines in SOFTLOAD.H
 */

/*
 *	Set the DESKPRG flag to compile this file for a
 *	replacement Desktop. Clear it for making GEM.SYS
 *      DESKPRG must also be set/cleared in
 *	      DESKSTAR.S, DESKVARI.C, DESKROM.C, DOSBIND.C
 *	See the Define in softload.h
 */

typedef struct cblk
{
	LONG		cb_pcontrol;
	WORD		*cb_pglobal;
	LONG		cb_pintin;
	LONG		cb_pintout;
	LONG		cb_padrin;
	LONG		cb_padrout;		
}CBLK;


EXTERN	UWORD	d_rezword;
#ifdef OBSOLETE_CODE
EXTERN	WORD	icn_whandle;
#endif
EXTERN	BYTE	*lp_mid;
EXTERN	BYTE	*lp_start;
EXTERN	WORD	d_exit;
EXTERN	BYTE	*q_addr;
EXTERN	UWORD	apsize;
EXTERN	OBJECT	*deskptr;		/* desktop resource	*/ /* this shouldn't be extern anymore, since the rsc is loaded from here now */
EXTERN	LONG	gl_vdo;
EXTERN	CBLK	c;
EXTERN	WORD	ctldown;
EXTERN	WORD	st_lang;

GLOBAL	WORD	d_multi;		/* flag for multitasking mode (MiNT) */
GLOBAL  LONG	mintvers;		/* MiNT version number */
GLOBAL	WORD	v_handle;
GLOBAL	WORD	desk_id;
GLOBAL	WORD	m_st;		/* machine type flag	*/	
GLOBAL	WORD	m_cpu;		/* cpu type		*/
GLOBAL	WORD	numicon;	/* the number of icon in the resource	*/	
GLOBAL	BYTE	*iconmem;	/* icon data memory address	*/
GLOBAL	BYTE	restable[6];	/* resolution table	*/
				/* Low , Medium, High, TT Medium, TT High, TT Low */
GLOBAL	WORD	d_maxcolor;
GLOBAL	USERBLK	chxcache;
GLOBAL	WORD	pglobal[15];
CICONBLK	*ciconaddr;
GLOBAL	WORD	d_spd;
GLOBAL	WORD	d_numfonts;
GLOBAL	FNTLST	*d_fontlst;
GLOBAL	UWORD	st_time;	/* time code		*/
GLOBAL	UWORD	st_date;
GLOBAL	UWORD	st_dchar;
GLOBAL	WORD	st_keybd;

GLOBAL	OBJECT	*fontmn;	/* font popup menu in	*/ 
				/* "Set Color & Style"	*/
				/* dialog box		*/
EXTERN	WORD	win_font;	/* window font 		*/
EXTERN	WORD	win_fsize;	/* window font szie 	*/


MLOCAL	BYTE	TIMETABLE[] =	/* was: BYTE *TIMETABLE[], changed for LC */
{/* Eurotime, Eurodate and seperator */
	0,0,'/',	/* USA	*/
	1,1,'.',	/* GERMANY	*/
	1,1,'/',	/* FRENCH	*/
	0,0,'/',	/* USA	*/
	1,1,'/',	/* SPAIN	*/
	1,1,'/',	/* ITALY	*/
	1,2,'-'		/* SWEDEN,NORWAY,FINLAND*/
};
	
#if DESKPRG
GLOBAL	WORD	gl_debug = 0;	/* Debug level for soft loaded desktop only */
GLOBAL	WORD	gl_port  = 1;	/* port for debug messages */

VOID	Ndebug( WORD level, LONG number );
VOID	Debug( WORD level, BYTE *str );
#endif

#if SOFTLOAD
MLOCAL BYTE	DESKRSC[40]; /* = "C:\\MULTITOS\\DESKTOP.RSC"; */

/*
 *	->> These message have to get internationalized!
 */

BYTE	*RSCVMSG =	"[1][Desktop resource in MULTITOS|\
directory has incorrect version|number. Resource was not|loaded from disk.]\
[ OK ]";

GLOBAL WORD	romdesk;
#endif


/*	Check if we're running MINT or not */
	WORD
desk_cMiNT( VOID )
{
	return( d_multi = getcookie( 0x4D694E54L, &mintvers ) );
}



MLOCAL WORD tosvers;

/* get the TOS version number; this *must* be executed in supervisor mode */

MLOCAL VOID gettosvers()
{
	LONG *sysbase;

	sysbase = *((LONG **)(0x4f2L));	/* get the RAM OS header */
	sysbase = (LONG *)sysbase[2];	/* get the real one */

	tosvers = (WORD)(sysbase[0] & 0x0000ffffL);
}


/*	Catch desktop terminate signal */

	VOID
desk_term()
{
	d_exit = L_EXIT;
	return;			/* DOES THIS BELONG HERE ??? (hmk 2/16/93) */
#if 0
	/* IS THIS STUFF NEEDED? IF SO< WHERE?   */
	Debug1( "Desktop catches terminate signal\r\n" );

	ciconaddr = (CICONBLK*) 0;
	if ( iconmem )
	{
	  LBCOPY( (BYTE *)temp, (BYTE *)c.cb_pglobal, 30 );
	  *((LONG*)(&c.cb_pglobal[7])) = iconmem;
	  rsrc_free(); 	
	  iconmem = (BYTE*) 0;
	  LBCOPY( c.cb_pglobal, temp, 30 );	
	}
	iconaddr = (OBJECT*) 0;
	iconmem = (BYTE*) 0;
	inf_path[0] = 0;		
	Pterm(1);
#endif
}


	WORD
ch_xcache()
{
	ch_cache( FALSE );
	return( 0 );
}


/*	Read in icn file	*/

	WORD
re_icon( )
{
	REG WORD	ret;
	WORD		temp[15];
	LONG		*ptr;
	BYTE		buf2[18];	
	BYTE		*iaddr;

	ret = FALSE;

	if ( !ctldown )			/* no control key down */
	{
	  LBCOPY( (BYTE *)temp,(BYTE *)c.cb_pglobal, 30 );
	  strcpy( cicndata, buf2 );	/* Try color icon file	*/
	  buf2[0] = ( isdrive() & 0x4 ) ? 'C' : 'A';
 
	  if ( !rsrc_load( buf2 ) )
	  {
	    strcpy( icndata, buf2 );	/* Try old icon file	*/
	    buf2[0] = ( isdrive() & 0x4 ) ? 'C' : 'A';
	    if ( !rsrc_load( buf2 ) )	
	      goto i_1;
	  }

	  ptr = (LONG*) &c.cb_pglobal[7]; /* get the new rsc address	*/
	  iaddr = (BYTE *) *ptr;
		
	  if ( iconmem )		/* free up memory	*/
	  {				/* use rs_free to free memory	*/
	    *ptr = (LONG) iconmem;	/* because it may have color icons */	
	    rsrc_free();
	  }

	  iconmem = iaddr;		
	  iconaddr = get_tree( 0 );	
	  numicon = iconaddr[0].ob_tail;
	  iconaddr++;			/* get the icon address	*/
	  ret = TRUE;
i_1:					/* restore the pglobal	*/
	  LBCOPY( (BYTE *)c.cb_pglobal,(BYTE *)temp, 30 );
	}

	return( ret );
}


	WORD
d_load_fonts()			/* load GDOS fonts */
{
	REG WORD	i;
	REG FNTLST	*fontsp;
	WORD		Mwchar, Iwchar;
	WORD		dummy;
	WORD		attrib[10];
	WORD		nfonts_used;

	if (d_spd && !ctldown)	/* Is Speedo GDOS there? */
		d_numfonts = d_v_load_fonts();
	else
		d_numfonts = 1; /* only system font available */
	Debug1("NEWDESK: Fonts loaded\r\n");
	if ((d_fontlst = malloc(d_numfonts * sizeof(FNTLST))) == NULL) {
		do1_alert( FCNOMEM );
		return( FALSE );
	}
	/*
	 *	Get font names
	 */
	nfonts_used = 0;
	for (i = 1, fontsp = d_fontlst; i <= d_numfonts; i++) {
		fontsp->fnt_id = d_v_font_name(i, &fontsp->fnt_name[2], &fontsp->fnt_type);
		fontsp->fnt_name[0] = ' ';	/* build strings so we can also */
		fontsp->fnt_name[1] = ' ';	/* use them in the popup menu 	*/
		fontsp->fnt_name[34] = ' ';
		fontsp->fnt_name[35] = '\0';

		if (fontsp->fnt_type == 0) {	  /* NO SPEEDO FONT */
			d_vqt_attributes(attrib); /* save current text attributes */
			d_v_setfont(fontsp->fnt_id);	  /* set to window font 	  */
			d_vqt_width('M', &Mwchar, &dummy, &dummy);						
			d_vqt_width('.', &Iwchar, &dummy, &dummy);
			if (Mwchar == Iwchar) {
				nfonts_used++;
				fontsp++;	/* only get monospaced bitmap fonts */	
			}
			d_v_setfont(attrib[0]); /* restore system font */
		} else {
			nfonts_used++;
			fontsp++;
		}
		Debug1( fontsp->fnt_name);
	}
	d_numfonts = nfonts_used;

	return( TRUE );
}

/*
 *	Objects for the font popup menu
 */
OBJECT  fntmnb1 = { -1, -1, -1, G_BOX, NONE, SHADOWED, 0xFF1100L, 2, 0, 35, 0 };
OBJECT	fntmnb2 = { -1, -1, -1, G_STRING, NONE, NORMAL, 0L, 0,  1, 35, 1 };

	WORD	
build_fontmenu()	/* build font popup menu for "Set Color & Style" dialog" */
{
	REG WORD	i;
	REG FNTLST	*fontsp;	
	OBJECT		*tree;
	TEDINFO		*ted;

	/*	First, soemthing else...
	 *	Hack Speedo font into the "Desktop Info"
	 *	dialog box.
	 */
	if (d_numfonts > 1) {
		rsrc_gaddr(R_TREE, ADDINFO, &tree); /* Desktop Info... */
		ted = (TEDINFO *) tree[GEMMSG].ob_spec;
		ted->te_font = GDOS_PROP;
		ted->te_fontid = 5003;	/* Swiss (5000 is Speedo offset!!!) */
		ted->te_fontsize = -1;	/* Take size of system font */
	}

	/*
	 *	Now the popup menu stuff...
	 */
	if ((fontmn = ( OBJECT *)malloc( (LONG)( ( d_numfonts + 1 ) * sizeof(OBJECT) ))) == NULL) {
		do1_alert( FCNOMEM );
		return FALSE;
	}
	LBCOPY((BYTE*) fontmn, (BYTE*) &fntmnb1, sizeof(OBJECT));	/* outside box	*/
	rsrc_obfix(fontmn, 0);

	fontsp = d_fontlst;
	for (i = 1; i <= d_numfonts; i++, fontsp++) {
		LBCOPY((BYTE *)&fontmn[i], (BYTE *) &fntmnb2, sizeof(OBJECT));
		rsrc_obfix(fontmn, i);
		objc_add(fontmn, 0, i); 
		fontmn[i].ob_spec = (LONG) fontsp->fnt_name;
		fontmn[i].ob_y = (i - 1) * gl_hchar;
		fontmn[i].ob_width = fontmn[0].ob_width;
		fontmn[0].ob_height += gl_hchar;
	}
	return TRUE;
}

/*	Initalize the icon and allocate backid memory	*/

	WORD
ini_icon()
{
	REG WORD	i;
	REG OBJECT	*obj;
	REG IDTYPE	*itype;
	    CICONBLK	*icblk;

	backid = (IDTYPE *) malloc( (LONG)( sizeof( IDTYPE ) * 
		( maxicon + 1 ) ) );

	if ( !backid )
	{
	  do1_alert( FCNOMEM );	/* ++ERS 12/16/92 */
	  return( FALSE );
	}
	
	obj = background;
	
	for ( i = 1; i <= maxicon; i++ )
	{
	  itype = &backid[i];
	  obj[i].ob_type = G_CICON;	/* 7/11/92 */
	  obj[i].ob_flags = HIDETREE;
	  obj[i].ob_state = NORMAL;
	  obj[i].ob_width = dicon.g_w;
	  obj[i].ob_height = dicon.g_h;
	  icblk = (CICONBLK*)(iconaddr[0].ob_spec);
	  itype->i_cicon = *icblk;
	  itype->i_cicon.monoblk.ib_ptext = (LONG) &itype->i_name[0]; 	
	  obj[i].ob_spec = (LONG) &itype->i_cicon;
	  itype->i_path = (BYTE*)0;
	}

	return( TRUE );
}

/*	Shift the menu	*/

	VOID
adj_menu( which )
	WORD	which;
{
	OBJECT	*obj;
	WORD	w,x,y;

	obj = menu_addr;		/* shift the menu	*/
	objc_offset( menu_addr, which, &x, &y );
	
	w = obj[which].ob_width + x;
	if ( w >= ( full.g_w + full.g_x ) )
	{
	  x = w - ( full.g_w + full.g_x ) + gl_wchar;
	  obj[which].ob_x -= x;	
	}			
}


/*	Initalize the desktop resource		*/

	WORD
ini_rsc()
{
	REG OBJECT	*obj;
	GRECT	pt;
	ICONBLK		*iblk;
	WORD		w,i;
	CICONBLK	*icblk;
	BYTE		*verstring;
	TEDINFO		*ted;

#if SOFTLOAD
	if (romdesk) {				/* if loading rsc from */
						/* disk failed and we  */
						/* have to use the rom */
						/* version, then we've */
						/* to do an rsrc_rcfix */ 
		Debug1( "Rsrc_rcfix\r\n" );
		rsrc_rcfix( (LONG)deskptr );
	}
#else
	Debug1( "Rsrc_rcfix\r\n" );
	rsrc_rcfix( (LONG)deskptr );
#endif
	Debug1( "Get tree\r\n" );					
	menu_addr = get_tree( ADMENU );	/* get the menu address		*/
	adj_menu( IDSKITEM - 1 );
	adj_menu( ICONITEM - 1 );			

	if ( !iconaddr )		/* if icon has read in 	*/
	{				/* then read it again	*/
	  if ( !re_icon() )
	  {
	    iconaddr = get_tree( ADICON );
	    numicon = iconaddr[0].ob_tail;
	    iconaddr++;
	  }
	}
	background = get_tree( BACKGROU ); /* was BACKROUND, changed for LC */
	maxicon = background[0].ob_tail;/* max background icon		*/
/* 	Allocate memory for color icons 
 * 	These should go away if we have a RCS that can handle color icon 
 */

	if ( !ciconaddr )	/* 7/10/92 */
	{
	  if ( ciconaddr = (CICONBLK*) malloc( (LONG)( sizeof(CICONBLK) * 
	  maxicon ) ) )
	  {		
	    for ( i = 0; i < maxicon; i++ )
	    {
	      background[i+1].ob_spec = (LONG) &ciconaddr[i];
	      background[i+1].ob_type = (UWORD) G_CICON;
	    }
	  }
	  else
	  {
 	    Cconws( "Color icon failed \r\n" );
	    return(FALSE);
	  }
	}
	rc_copy( (WORD *)&full, (WORD *)&background[0].ob_x );

	/* Precalculate the disk icon's pline values	*/

	if ( iconaddr[0].ob_type == G_CICON )
	{
	  icblk = (CICONBLK*)iconaddr[0].ob_spec;
	  iblk = &icblk->monoblk; 
	}
	else
	  iblk = (ICONBLK*)(iconaddr[0].ob_spec);

	rc_copy( &iblk->ib_xicon,(WORD *) &pt );	/* get the icon's xywh	*/

	d_xywh[0] = pt.g_x;			/* disk icon outline	*/
	d_xywh[3] = d_xywh[1] = pt.g_y;
	d_xywh[4] = d_xywh[2] = d_xywh[0] + pt.g_w; 
	d_xywh[5] = d_xywh[3] + pt.g_h;
	
	rc_copy( &iblk->ib_xtext,(WORD *)&pt );
	d_xywh[8] = d_xywh[6] = pt.g_x + pt.g_w;
	d_xywh[13] = d_xywh[7] = pt.g_y;
	d_xywh[11] = d_xywh[9] = d_xywh[7] + pt.g_h;
	d_xywh[12] = d_xywh[10] = pt.g_x;
	d_xywh[16] = d_xywh[14] = d_xywh[0];
	d_xywh[15] = d_xywh[5];
	d_xywh[17] = d_xywh[1];
				
	dicon.g_x = 0;			/* precalculate text icon's x,y,w,h */
	dicon.g_y = 0;
	dicon.g_w = iblk->ib_wtext;
	dicon.g_h = iblk->ib_hicon + iblk->ib_htext;

	rc_copy( (WORD *)&dicon, (WORD *)&r_dicon );
	r_dicon.g_w += 5;
	r_dicon.g_h += 7;
	r_dicon.g_w += ( full.g_w % r_dicon.g_w ) / ( full.g_w / r_dicon.g_w );
	r_dicon.g_h += ( full.g_h % r_dicon.g_h ) / ( full.g_h / r_dicon.g_h );
				
	w = gl_wchar * 14;		/* text outline	*/

	obj = get_tree( TEXTLINE ); /* was TEXTLINES, changed for LC */
	f_xywh[9] = f_xywh[8] = f_xywh[6] = f_xywh[3] = f_xywh[1] = f_xywh[0] = 0;
	f_xywh[2] = w;
	f_xywh[4] = w;
	f_xywh[5] = obj[TSTYLE].ob_height;
	f_xywh[7] = obj[TSTYLE].ob_height;

/* set up the "Desktop Info..." dialog to show multi/single tasking,
 * and also the right TOS version number
 */
	obj = get_tree(ADDINFO);
	ted = (TEDINFO *)obj[VERTEXT].ob_spec;
	verstring = (BYTE *)ted->te_ptext;
	trap14(0x26, gettosvers);	/* Supexec(gettosvers) */

/* if MiNT is not present, don't show the MiNT copyright box */
/* also, show "MultiTOS" instead of "TOS"
 */
	if (!d_multi) {
		obj[MINTCBOX].ob_flags |= HIDETREE;
	} else {
		tosvers = (WORD)mintvers;
		verstring = get_string(MTOSVERS);
		ted->te_ptext = verstring;
	}
/* put the version number into the right place in the string */
/* ASSUMPTION: major TOS version is < 10 */
	while (*verstring && *verstring != '#')
		verstring++;
	if (*verstring) {
		*verstring++ = '0' + tosvers/256;
		tosvers &= 0xff;
		*verstring++ = '.';
		*verstring++ = '0' + (tosvers/16);
		*verstring++ = '0' + (tosvers % 16);
	}
	Debug1( "Ini_rsc done\r\n" );	
	return( TRUE );
}

#if SOFTLOAD
/*
 *	chrscver()
 *	Check version number or rsc file
 *	Returns:  1, proper version
 *		  0, wrong version
 *		 -1, unable to open
 */
WORD
chkrscver(fname, vers)		/* check version number of rsc file */
BYTE	*fname;			/* file name */
BYTE	vers;			/* version number it should have */ 
{
	WORD	fd;
	BYTE	rvers;
	BYTE	cvers;
	WORD	rhdr;
	WORD	ret = 0;

	if ( ( fd = dos_open(fname, 0) ) >= 0 )
	{
	  if ( dos_read( fd, 2, (LONG)&rhdr) > 0 )
	  {
	     /*
 	      *	Check the version number in the 1st byte of the rsc header.
	      * The format is: %1xxxxxxx
 	      *                 |  |
	      *                 |  +- version number
	      *                 +---- always one
	      */
	     rvers = (BYTE) (rhdr >> 8);	/* just the first byte */
	     cvers = (BYTE) (vers | 0x80);	/* set version nr. */
	     if (rvers == cvers) {
			ret = 1;
	     }
	   }
	   dos_close(fd);
	} else {
		ret = -1;
	}
	return ret;
}


VOID deskrsc()			/* load the desk rsc from disk */
{
	
	WORD	load = 0;
#if DESKRSVER
	WORD	verflg;
#endif
	UWORD	*rscaddr;

	strcpy("C:\\MULTITOS\\DESKTOP.RSC", DESKRSC);
	DESKRSC[0] = ( isdrive() & 0x4 ) ? 'C' : 'A';

	/*
 	 * Before loading the resource file, check its version
	 * so that we are using the proper one.
  	 *
	 *	Returns:  1, proper version
	 *		  0, wrong version
	 *		 -1, unable to open
	 */
#if DESKRSVER
	if ((verflg = chkrscver(DESKRSC, DSKRSVER)) == 1) {
		load = rsrc_load(DESKRSC);	
	} else if (verflg == 0) {
		form_alert(1, RSCVMSG);
	}
#endif
	if (!load)
	{
		rsc_read();		/* cjg 03/30/93 */
		deskptr = NULL;
		rom_ram(1, (LONG)deskptr);		/* use ROM desktop rsc */
		romdesk = TRUE;
	}
	else
	{
		rsrc_gaddr(0, 0, (LONG *)&rscaddr);
		romdesk = FALSE;
		deskptr = (OBJECT *) rscaddr;
	}
}
#endif



MLOCAL	BYTE	DESK_MAGIC[] = "4c4c444D";
MLOCAL	BYTE	SH_MAGIC[] = "SH_MAGIC=";

/*	Process 2 - Desktop 	*/

#if DESKPRG
	VOID
main( VOID )

#else
	VOID
deskmain()
#endif
{
	REG WORD	i;
	WORD		ret,doitonce,code;
	WORD		*ptr;	
	BYTE		temp[30];
	LONG		value;
	LONG		*pvalue;
	WORD		temp1, temp2;

#if !DESKPRG
	WORD		x;
#endif

	catchsignal( SIGTERM );	/* Redirect all the Signals	*/
				/* Catch only the terminate signal */	
	Psignal( SIGTERM, desk_term );

	initkballoc();		/* initialize the lmalloc() functions */

	if ( !inf_path[0] )	/* Not set up yet		*/	
	  m_infpath( inf_path );

	desk_id = appl_init( );	/* initalize the application	*/

				/* Let AES knows that we will handle AP_TERM 	*/
	shel_write( 9, 0x1, 0,(LONG)Nostr,(LONG)Nostr );
	
#if DESKPRG
	ret = graf_handle( &gl_wchar, &gl_hchar, &gl_wbox, &gl_hbox );
#else
	ret = graf_handle( &x, &x, &x, &x );
#endif
	v_handle = ret;

	desk_vopnvwk( &v_handle, Getrez()+2, &ptr );
	
	if ( !v_handle )
	{
/* we can't really translate this string because the resource file
 * isn't open yet. Bummer! ++ERS 12/16/92
 */
	  form_alert( 1, "[1][ Desktop failed to open | work station ][ BYE ]" );
	  goto m_6;
	}

#if DESKPRG
	gl_ncols = ( ptr[0] + 1 )/ gl_wchar;	/* get # of columns */
	gl_nrows = ( ptr[1] + 1 )/ gl_hchar;	/* get # of rows    */
#endif
	d_maxcolor = ptr[13];		/* vdi max number of color	*/

	doitonce = TRUE;
#ifdef OBSOLETE_CODE
	icn_whandle = -1;
#endif
	d_exit = L_NOEXIT;

	ciconaddr = (CICONBLK*)0;	/* 7/10/92 */
	ctldown = trap13( 0x0b, -1 ) & 0x0004 ? TRUE : FALSE;	/* 07/19/93 */

	Debug1( "Desktop checks cookie\r\n" );
	
	desk_cMiNT();	/* check to see if we are multitasking */	

#if DESKPRG
	gl_vdo = 0x0L;
				/* _VDO */		/* 7/19/93 */
	getcookie( 0x5F56444FL, &gl_vdo );
#endif

	if ( getcookie( 0x5F414B50L, &value ) )	/* get _AKP cookie */
	{
	  st_keybd = (WORD) (value & 0x00FFL);
	  code = (WORD)(( value >> 8 ) & 0x00FF); 
					/* get the keyboard preferences */
	}
	else
	  st_keybd = code = 0;

	if ( ( st_keybd > 8 ) || ( st_keybd < 0 ) )
	  st_keybd = 0;

	if ( ( code > 6 ) || ( code < 0 ) || ( code == 3 ) )
	  code = 0;

	code = code * 3;
					/* set the default IDT stuff */
	st_time  = (UWORD) TIMETABLE[code++];
	st_date  = (UWORD) TIMETABLE[code++];
	st_dchar = (UWORD) TIMETABLE[code];

	/* The _IDT format is as follow				*/
	/* HIGH WORD  |	         LOW WORD			*/
	/* 31 - 16    | 15-12      11-8     	  7-0 bit 	*/
	/* Reserved   |	st_time    st_date  	  st_char	*/
	/*  		0 12 hour  0  MM-DD-YY   		*/
	/*		1 24 hour  1  DD-MM-YY			*/	
	/*			   2  YY-MM-DD			*/
	/*			   3  YY-DD-MM			*/
		
	if ( getcookie( 0x5F494454L, &value ) )	/* get _IDT cookie */
	{
	  st_date = (UWORD)((value >> 8) & 0xFL); /* get the date preferences */
	  st_time = (UWORD)(( value >> 12 ) & 0xFL);
	  if ( !( st_dchar = (UWORD)(value & 0xffL )) )
	    st_dchar = '/';
	}
top:
	
#if !DESKPRG			/* Do this only with the ROM version */
	Debug1( "Desktop does deskerr\r\n" );

	deskerr();
#endif
#if SOFTLOAD
	deskrsc();		/* read desktop resource */
#else
	Debug1( "Desktop does rom ram\r\n" );
	Ndebug1( deskptr );
	rsc_read();			/* cjg 03/19/93 */
	rom_ram( 1, (LONG)deskptr );	/* read in desktop resource	*/
#endif

	ret = TRUE;		/* assume everything is OK	*/

	d_spd = 0;
	if ( getcookie( 0x46534d43L, (LONG *)&pvalue ) ) /* FSMC */
	{
	  if ( (*pvalue++ == 0x5F535044L) && 
	  (((WORD)(*pvalue >> 16)) >= 0x0411)) /* _SPD */
	  	d_spd = 1;    /* at least Version 4.11 */
	} 

	win_font = 0;	/* system font */	
	win_fsize = (gl_hchar <= 10) ? 9 : 10; /* font size in points */

	if (!d_load_fonts()) 	/* Load Speedo GDOS fonts	*/
		goto m_2;			

	appnode = (APP*)0;	/* No app buffer yet		*/
	applist = (APP*)0;	/* No app list yet		*/
	apsize = 0;		/* Initalize app size		*/
	autofile[0] = 0;

	desk_mice( HOURGLASS );	/* busy bee pointer		*/	
				/* get the full window size	*/

	wind_get( 0, WF_WORKXYWH, &full.g_x, &full.g_y, &full.g_w, &full.g_h );

	Debug1( "Desktop does ini_rsc\r\n" );

	ini_rsc();		/* init the resource		*/

	Debug1( "Ini_icon\r\n" );
	if ( !ini_icon() )	/* hide all the desktop icons	*/
	  goto m_2;

	Debug1( "Mem_init\r\n" );
	if ( !mem_init() )	/* init the app path buffer	*/
	{
m_2:

#if !DESKPRG			/* Do this only with the ROM Version */
	  desknoerr();	  
#endif
	  goto m_1;		/* and desk app buffer		*/
	}

	/* initalize all the windows before reading in inf file	*/

	Debug1( "Ini_window\r\n" );
	ini_windows( );	 

	if ( doitonce )			/* do it once only	*/
	  adjobjects();			/* adjust object positions      */
		
	Debug1( "Read inf file\r\n" );
	read_inf();			/* Let see what the user want	*/

	Debug1( "Q_inf\r\n" );
	q_inf();			/* make a copy of inf file	*/
#if !DESKPRG
/* CJG 03/19/93	temporarily disabled... */
	desknoerr();
#endif
					/* Get the real res mode for FALCON	*/
	if ( ( gl_vdo & HIGHWORD ) == FALCON )
	{
	  d_rezword = setmode(-1);
	  pref_save = mode2res(d_rezword);
	}
	else
	{
	  pref_save = res_type(Getrez()+2);
	  d_rezword = res2mode(pref_save);
	}

					/* change the menu bar		*/
	do_view( ( s_view == S_ICON ) ? ICONITEM : TEXTITEM );

	switch( s_sort )
	{
	  case S_NAME:
	    i = NAMEITEM;
	    break;
	  case S_DATE:
	    i = DATEITEM;
	    break;
	  case S_SIZE:
	    i = SIZEITEM;
	    break;
	  case S_TYPE:
	    i = TYPEITEM;
	    break;
	  case S_NO:
	    i = NOSORT;
	}

	Debug1( "Wind_set\r\n" );
	temp1 = (WORD)((LONG) background >> 16L);
	temp2 = (WORD)((LONG)background & 0x0000FFFFL);
	wind_set( 0, WF_NEWDESK, temp1, temp2, 0, 0 );

	Debug1( "Do_view\r\n" );
	do_view( i );			/* fix up the menu bar	*/

	ch_machine( );			/* check the machine	*/
					/* set up the right menu text */
					/* do it here!!!!!!	*/	
	strcpy( get_fstring( ( m_cpu == 30 ) ? CACHETXT : BLTTXT ),
		(BYTE *) menu_addr[BITBLT].ob_spec );

	menu_addr[SUPERITE].ob_type = G_USERDEF; /* was SUPERITEM, changed LC */
	chxcache.ub_code = (LONG) ch_xcache;
	menu_addr[SUPERITE].ob_spec = (LONG) &chxcache; 
		/*  +----------------> was SUPERITEM, changed for LC */

	Debug1( "Ch_cache\r\n" );
	ch_cache( TRUE );		/* set the cache	*/

					/* check desktop file	*/	
	put_keys();			/* set up the key menu	*/

	if (!build_fontmenu()) 		/* Build the font popup menu */
		goto m_1;		/* for "Set Color & Style"   */
					/* dialog box 		     */

	Debug1( "Put menu bar\r\n" );

	if ( d_exit != L_WAKEUP )
	{
	  menu_bar( menu_addr, TRUE );	/* show the menu	*/
	  do_redraw( 0, &full, 0 );	/* draw the background	*/
	}



#if !DESKPRG
	Debug1( "Menu_register\r\n" );
 	menu_register( desk_id, get_fstring(DESKNAME) );
#endif

	Debug1( "Open def\r\n" );
	open_def();			/* open default windows	*/
	desk_mice( ARROW );

	if ( doitonce )
	{
	  if ( autofile[0] )
	    shel_write( 1, ( autofile[1] == '1' ) ? 1 : 0, 0,
		(LONG)&autofile[3],(LONG)Nostr );
	}

	doitonce = FALSE;

	Debug1( "Actions\r\n" );
	
	d_exit = L_NOEXIT;

	actions();			/* handle the events	*/

	wind_update( 1 );		/* Block out any more events	*/
	desk_mice( HOURGLASS );		

	free_windows( );		/* free up all windows	*/	

	wind_set( 0, WF_NEWDESK, 0, 0, 0, 0 );
	
	free( lp_start );		/* free string buffer	*/

	free( appnode );		/* free app buffer	*/
	
	free( backid );

	free( q_addr );			/* update inf file on disk	*/

	wind_update( 0 );		/* release window	*/

					/* Loop again		*/
	if ( ( d_exit == L_READINF ) || ( d_exit == L_WAKEUP ) )
	  goto top;

	Debug7( "Desktop frees mn_bar\r\n" );

	menu_bar( 0x0L, FALSE );
m_1:
	if ( ciconaddr )	/* start everything over again	*/	
	{
	  free( ciconaddr );
	  ciconaddr = (CICONBLK *) 0;
	}

	iconaddr = (OBJECT*) 0;

	if ( iconmem )
	{
	  LBCOPY( (BYTE *)temp,(BYTE *) c.cb_pglobal, 30 );
	  *((LONG*)(&c.cb_pglobal[7])) = (LONG) iconmem;
	  rsrc_free(); 	
	  iconmem = (BYTE*) 0;
	  LBCOPY((BYTE *)c.cb_pglobal,(BYTE *)temp, 30 );	
	}

	inf_path[0] = 0;
	d_v_unload_fonts();
	d_v_clsvwk( );
m_6:
	appl_exit();
	Pterm( 1 );
}


/*	Check the machine type and set res table	*/

	VOID
ch_machine()
{
	LONG	value;

	m_st = TRUE;		
			/* _VDO	*/
	if ( getcookie( 0x5F56444FL, &value ) )
	{			/* 7/16/92 */
	  if ( ( ( value >> 16L ) & 0x0000FFFFL ) >= 0x02 )	/* TT	*/
	    m_st = FALSE;
	}
			/* _CPU	*/
	getcookie( 0x5F435055L, &value );
	m_cpu =  (WORD) value;

	/* the restable is set according to gl_restype value	*/

	bfill( 6, 0, restable );	/* zero the table	*/

	if ( !m_st )			/* TT machine	*/
	{
	  if ( pref_save == 5 )		/* TT High	*/
	    restable[4] = 1;
	  else
	  {
	    bfill( 4, 1, restable );	/* LOW MEDIUM HIGH	*/
	    restable[5] = 1;		/* TT-LOW MEDIUM	*/
	  }
	}	
	else
	{
	  if ( pref_save == 3 )		/* ST HIGH		*/
	    restable[2] = 1;
	  else
	  {
	    restable[0] = 1;
	    restable[1] = 1;	
	  }		
	}
}

#ifdef OLD_WAY

#pragma inline asm1() { "4e7a"; "0002"; }

#pragma inline asm2() { "4e7b"; "7002"; }

#pragma inline asm3() { "4e7a"; "7002"; }

#pragma inline asm4() { "2007"; }

	LONG
inq_cache( data )
	REG LONG	data;
{
	BYTE	*old;
	WORD	super;

	super = (WORD) Super( 0x1L );
	
	if ( !super )
	  old = (BYTE *) Super( 0x0L );
		asm1();
	  /*asm( ".dc.w $4e7a,$0002" );*/ /* movec.l cacr,d0		*/
	  if ( data != -1 )
		asm2();
	    /*asm( ".dc.w $4e7b,$7002" );*/ /* movec.l d7,cacr		*/
	  asm3();
	  /*asm( ".dc.w $4e7a,$7002" );*/ /* movec.l cacr,d7		*/

	if ( !super )
	  Super( old );

	asm4();
	/*asm( ".dc.w $2007" );*/
}
#endif /* OLD_WAY */

LONG getcacr( void );
void putcacr( LONG cacr );

#pragma inline d0=getcacr() { "4e7a"; "0002"; }	/* movec.l cacr,d0 */
#pragma inline putcacr(d0) { "4e7b"; "0002"; }  /* movec.l d0,cacr */

	LONG
inq_cache( data )
	REG LONG	data;
{
	BYTE	*oldssp;
	WORD	super;
	LONG	oldcacr;

	super = (WORD) Super( 0x1L );
	
	if ( !super )
	  oldssp = (BYTE *) Super( 0x0L );

	if ( data != -1 ) {
		putcacr( data );
	}
	oldcacr = getcacr();

	if ( !super )
	  Super( oldssp );

	return oldcacr;
}


/*	Turn on the cache or bitblt 	*/

	VOID
ch_cache( set )
	WORD	set;
{
	WORD	value;
	LONG	data;
	WORD	temp;

	menu_addr[BITBLT].ob_state &= ~DISABLED;

	if ( m_cpu == 30 )
	{
	  if ( set )
	    data = ( s_cache ) ? CACHE_ON : CACHE_OFF;
	  else
	    data = 0xFFFFFFFFL;

	  if ( inq_cache( data ) == XCA_ON )
	    s_cache = TRUE;
	  else
	    s_cache = FALSE;

	  value = s_cache;

	}
	else
	{				/* turn the blt on	*/
					/* blt is there		*/
ch_1:	  if ( ( temp = (WORD)trap14( 64, -1 ) ) & 0x2 )	
	  {
	    if ( set )
	    {
	      trap14( 64, ( cbit_save ) ? 1 : 0  );
	      set = FALSE;
	      goto ch_1;	/* check status again	*/
	    }
	    else
	      cbit_save = ( temp & 0x1 ) ? TRUE : FALSE; 	
	      		
	    value = cbit_save;

	  }
	  else
	  {
	    value = FALSE;
	    menu_addr[BITBLT].ob_state |= DISABLED;
	  }
	}

	if ( value )
	  menu_addr[BITBLT].ob_state |= CHECKED;
	else 
	  menu_addr[BITBLT].ob_state &= ~CHECKED;
}


	
/* Adjust Object Positions */

	VOID
adjobjects()
{
    REG OBJECT 	*obj;
    WORD	x,y,w,h,dx,dy;	    
	
    obj = get_tree( ADINSDIS );
    objc_gclip( obj, IUP, &dx, &dy, &x, &y, &w, &h );
    obj[ IDOWN ].ob_y = h + obj[IUP].ob_y;   
    obj[ IDRIVE ].ob_y += 2;
    obj[ ITRASH ].ob_y += 2;
    obj[ IPRINTER ].ob_y += 2;

    obj = get_tree( INWICON );
    objc_gclip( obj, WUP, &dx, &dy, &x, &y, &w, &h );
    obj[ WDOWN ].ob_y = h + obj[ WUP ].ob_y;
    obj[ WFOLDER ].ob_height = gl_hchar;
    obj[ WNONE ].ob_height = gl_hchar;
    obj[ WOK ].ob_height = gl_hchar;
    obj[ WREMOVE ].ob_height = gl_hchar;
    obj[ WSKIP ].ob_height = gl_hchar;
    obj[ WQUIT ].ob_height = gl_hchar;    

    obj = get_tree( MNSYSTEM );
    objc_gclip( obj, MFUP, &dx, &dy, &x, &y, &w, &h );
    obj[ MFDOWN ].ob_y = h + obj[ MFUP ].ob_y;
    objc_gclip( obj, MKUPS, &dx, &dy, &x, &y, &w, &h );    
    obj[ MKDOWNS ].ob_y = h + obj[ MKUPS ].ob_y;
    obj[ MFBASE ].ob_height += 2;

    obj = get_tree( ADFILEIN );
    obj[ FIOK ].ob_y   += 2;
    obj[ FISKIP ].ob_y += 2;
    obj[ FICNCL ].ob_y += 2;
    obj[ FIRONLY ].ob_y -= 1;
    obj[ FIRWRITE ].ob_y -= 1;
}


#if DESKPRG

	VOID
Ndebug( level, number )
	WORD	level;
	LONG	number;
{
	BYTE	buffer[14];

	lbintohex( number, buffer );
	Debug( level, buffer );
	Debug( level, "\r\n" );	
}

/*	Debug routine	*/

	VOID
Debug( level, str )
	WORD	level;
	BYTE	*str;
{
	if ( gl_debug >= level )
	{
#if 1
	  while( *str )
	    trap13( 3, gl_port, *str++ );
#else
	  trap(9, str);
#endif
	}
}
#endif

