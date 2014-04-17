/*	GEMGSXIF.C	05/06/84 - 02/17/85	Lee Lorenzen		*/
/*	68k		02/20/85 - 03/25/85	Lowell Webster		*/
/*	Reg Opt		03/09/85		Derek Mui		*/
/*	speed bee	05/14/85		jim eisenstein		*/
/*	Comment something out	07/11/85	Derek Mui		*/
/*	6 resolutions	1/30/86			Derek Mui		*/
/*	At gsx_wsopen, at gsx_malloc					*/
/*	Store mouse addr at gsx_mfset	2/28/86	Derek Mui		*/
/*	New flag to tell if the mouse is really on 3/3/86	D.Mui	*/
/*	Take out save mouse address		1/7/87	Derek Mui	*/
/*	Restore into C language from 3.01	8/29/90	D.Mui		*/
/*	Fix gsx_wsopen for TT resolutions	8/29/90	D.Mui		*/
/*	Change at gsx_mfset			5/8/91	D.Mui		*/
/*	Convert to Lattice C 5.51		2/17/93 C.Gee		*/
/*	Force the use of prototypes		2/23/93	C.Gee		*/

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
#include "vdidefs.h"
#include "osbind.h"
#include "vdomode.h"


EXTERN	MFORM	gl_cmform;
EXTERN	MFORM	gl_omform;
EXTERN	WORD	gl_omkind;
EXTERN	WORD	gl_mkind;
EXTERN	WORD	gl_restype;
EXTERN 	WORD	gl_rschange;
EXTERN	LONG	gl_vdo;
EXTERN	WORD	gl_mfid;
EXTERN	WORD	gl_omfid;

						/* in GEMDOS.C		*/
EXTERN	LONG	drwaddr;
						/* in APGSXIF.C		*/
EXTERN	WORD	gl_xrat;
EXTERN	WORD	gl_yrat;
EXTERN	WORD	cu_xrat;
EXTERN	WORD	cu_yrat;
EXTERN	WORD	gl_button;
EXTERN	WORD	gl_width;
EXTERN	WORD	gl_height;
EXTERN	WORD	gl_nrows;
EXTERN	WORD	gl_ncols;

EXTERN	WORD	gl_wchar;
EXTERN	WORD	gl_hchar;

EXTERN	WORD	gl_wschar;
EXTERN	WORD	gl_hschar;

EXTERN WORD	gl_wptschar;
EXTERN WORD	gl_hptschar;

EXTERN WORD	gl_wsptschar;
EXTERN WORD	gl_hsptschar;

EXTERN WORD	gl_wbox;
EXTERN WORD	gl_hbox;

EXTERN WORD	gl_xclip;
EXTERN WORD	gl_yclip;
EXTERN WORD	gl_wclip;
EXTERN WORD	gl_hclip;

EXTERN WORD	gl_nplanes;
EXTERN WORD 	gl_handle;

EXTERN FDB	gl_src;
EXTERN FDB	gl_dst;

EXTERN	WORD	gl_fsm;
EXTERN WS		gl_ws;
EXTERN WORD		contrl[];
EXTERN WORD		intin[];
EXTERN WORD		ptsin[];
EXTERN WORD		intout[];
EXTERN WORD		ptsout[];
EXTERN LONG		ad_intin;

GLOBAL	UWORD		a_rezword;	/* AES's resolution word	*/
GLOBAL	UWORD		b_rezword;	/* secondary resoultion word	*/

GLOBAL	FDB		gl_tmp;
GLOBAL	FDB		gl_crit;	/* critical error blt buffer */


GLOBAL	LONG		old_mcode;
GLOBAL	LONG		old_bcode;
GLOBAL	WORD		gl_moff;		/* counting semaphore	*/
						/*  == 0 implies ON	*/
						/*  >  0 implies OFF	*/
GLOBAL LONG		gl_mlen;
GLOBAL WORD		gl_graphic;

GLOBAL	WORD		gl_mouse;	/* mouse on flag		*/

MLOCAL WORD	restable[] = { 0,2,5,7,3,4,6,8,9,-1 };
MLOCAL WORD	restype[]  = { 0,1,1,1,2,3,4,5,6,-1 };


/*	Change from res type to real device handle	*/

	WORD
res_handle( in )
	WORD	in;
{
	WORD	i;

	i = 0;
	while( TRUE )
	{
	  if ( restype[i] == in )
	    return( restable[i] );	
	  if ( restype[i] == -1 )
	    return( 0 );
	  i++;
	}
}


/*	Change from device handle to res type	*/

	WORD
res_type( in )
	WORD	in;
{
	WORD	i;

	i = 0;
	while( TRUE )
	{
	  if ( restable[i] == in )
	    return( restype[i] );	
	  if ( restable[i] == -1 )
	    return( 0 );
	  i++;
	}
}


/*     save 25 columns and full height of the screen memory	*/

	VOID
gsx_malloc( VOID )
{
	LONG	len;
	
	gsx_fix( &gl_tmp, 0x0L, 0x0, 0x0 );
	len = (LONG)((UWORD)gl_wchar) * 25L * (LONG)((UWORD)gl_height)
		    * (LONG)((UWORD)gl_nplanes);
	len = len / 8L;
	gl_mlen = len;

	if ( !( gl_tmp.fd_addr = dos_xalloc( gl_mlen, 0x23 ) ) )
	  bailout( "AES failed to allocate blt buffer\r\n" );
	else
	{
	  gl_tmp.fd_addr += 4;

	  gl_crit = gl_tmp;		/* critical error blt buffer */
	  if ( !( gl_crit.fd_addr = dos_xalloc( gl_mlen, 0x23 ) ) )
	    bailout( "AES failed to allocate critical error blt buffer\r\n" );
	}
}


#if 0
/*     save 1/2 of the screen memory	*/

	VOID
gsx_malloc( VOID )
{
	gsx_fix( &gl_tmp, 0x0L, 0x0L );
	gl_mlen = (LONG)(( gl_ws.ws_yres + 1 ) * ( gl_ws.ws_xres + 1 ) );
	gl_mlen = ( gl_mlen * (LONG)gl_nplanes * 3L ) / 40L; 
	if ( !( gl_tmp.fd_addr = dos_xalloc( gl_mlen, 0x23 ) ) )
	  bailout( "AES failed to allocate blt buffer\r\n" );
	else
	{
	  gl_tmp.fd_addr += 4;

	  gl_crit = gl_tmp;		/* critical error blt buffer */
	  if ( !( gl_crit.fd_addr = dos_xalloc( gl_mlen, 0x23 ) ) )
	    bailout( "AES failed to allocate critical error blt buffer\r\n" );
	}
}
#endif

	VOID
gsx_mfree( VOID )
{
	if ( gl_tmp.fd_addr )
	{
	  gl_tmp.fd_addr -= 4;
	  dos_free( gl_tmp.fd_addr );
/*	  gl_tmp.fd_addr = (BYTE*)0;*/
	  gl_tmp.fd_addr = ( LONG )0L;
	}

	if ( gl_crit.fd_addr )
	{
	  dos_free( gl_crit.fd_addr );
/*	  gl_crit.fd_addr = (BYTE*)0;*/
	  gl_crit.fd_addr = ( LONG )0L;
	}
}


	VOID
gsx_mret(pmaddr, pmlen)
	LONG		*pmaddr;
	LONG		*pmlen;
{
	*pmaddr = gl_tmp.fd_addr;
	*pmlen = gl_mlen;
}

	VOID
gsx_ncode(code, n, m)
	WORD		code;
	WORD		n, m;
{
	REG WORD		*pctrl;
	pctrl = &contrl[0];

	pctrl[0] = code;
	pctrl[1] = n;
	pctrl[3] = m;
	pctrl[6] = gl_handle;
	gsx2();
}

	VOID
gsx_1code(code, value)
	WORD		code;
	WORD		value;
{
	intin[0] = value;
	gsx_ncode(code, 0, 1);
}


	VOID
gsx_init( VOID )
{
	gsx_wsopen();
	gsx_start();
	gsx_setmb( ( UWORD *)&far_bchange, ( UWORD *)&far_mchange, &drwaddr);
	gsx_ncode(MOUSE_ST, 0, 0);
	cu_xrat = gl_xrat = ptsout[0];
	cu_yrat = gl_yrat = ptsout[1];
}


	VOID
gsx_graphic(tographic)
	REG WORD		tographic;
{
	if (gl_graphic != tographic)
	{
	  gl_graphic = tographic;
	  if (gl_graphic)
	  {
	    gsx_escapes(2);
	    gsx_setmb( ( UWORD*)&far_bchange, ( UWORD *)&far_mchange, &drwaddr);
	  }
	  else
	  {
	    gsx_escapes(3);
	    gsx_resetmb();
	  }
	}
}


	VOID
gsx_escapes(esc_code)
	WORD	esc_code;
{
	contrl[5] = esc_code;
	gsx_ncode(5, 0, 0);
}

	VOID
v_hardcopy( VOID )
{
	gsx_escapes(17);
}


	VOID
gsx_wsopen( VOID )
{
	REG WORD	i;
	WORD		res;

	for(i=0; i<10; i++)
	  intin[i] = 1;

	intin[10] = 2;			/* device coordinate space */

	intin[0] = gl_restype;

	if ( ( gl_vdo & HIGHWORD ) == FALCON )
	{
	  intin[0] = 5;		/* FALCON special res handle */


	  a_rezword = Validmode( a_rezword );	/* massage the res mode word */

/* 80 column true color is not supported on VGA */
	  if ((a_rezword & VGA) && (a_rezword & NUMCOLS) == BPS16)
		a_rezword &= ~COL80;
 
	  gl_ws.ws_pts0 = b_rezword = a_rezword;	
	}

	/* Use gl_ws as intout and gl_ws.ws_pt0 as ptsout	*/

	v_opnwk( &intin[0], &gl_handle, ( WORD *)&gl_ws, &gl_ws.ws_pts0 );

	if ( ( gl_vdo & HIGHWORD ) == FALCON )
	  a_rezword = (WORD)setmode( -1 );	
	
	Bconout( 2, ' ' );		/* put system in raw mode */

	res = (WORD)Getrez();

	gl_restype = res + 2;
/*	gl_restype = res_type( res );	*/

	Debug1( "Gl_restype is " );
	Ndebug1( (LONG)gl_restype );

#if 0
	gl_restype = 5;			/* assume 1280x960	*/

	if ( gl_ws.ws_xres == 640-1 )
	{
	  if ( gl_ws.ws_yres == 200-1 )		/* 640x200	*/
	    gl_restype = 2;
	  else
	    if ( gl_ws.ws_yres == 400-1 )	/* 640x400	*/
	      gl_restype = 3;
	    else
	      gl_restype = 4;			/* 640x480 	*/
	}
	else
	{
	  if ( gl_ws.ws_xres == 320-1 ) 
	  {
	    if ( gl_ws.ws_yres == 200-1 )	/* 320x200	*/
	      gl_restype = 1;
	    else
	      gl_restype = 6;			/* 320x480	*/
	  }
	}
#endif
	gl_rschange = FALSE;
	gl_graphic = TRUE;
}



	VOID
gsx_wsclose( VOID )
{
	gsx_ncode(CLOSE_WORKSTATION, 0, 0);
}


	VOID
ratinit( VOID )
{
	gsx_1code(SHOW_CUR, 0);
	gl_moff = 0;
}


	VOID
ratexit( VOID )
{
	gsx_moff();
}

	VOID
bb_set(sx, sy, sw, sh, pts1, pts2, pfd, psrc, pdst)
	REG WORD		sx, sy, sw, sh;
	REG WORD		*pts1, *pts2;
	FDB		*pfd;
	FDB		*psrc, *pdst;
{
	WORD		oldsx;

						/* get on word boundary	*/
	oldsx = sx;
	sx = (sx / 16) * 16;
	sw = ( ((oldsx - sx) + (sw + 15)) / 16 ) * 16;

	gl_tmp.fd_stand = TRUE;
	gl_tmp.fd_wdwidth = sw / 16;
	gl_tmp.fd_w = sw;
	gl_tmp.fd_h = sh;
	
	gsx_moff();
	pts1[0] = sx;
	pts1[1] = sy;
	pts1[2] = sx + sw - 1;
	pts1[3] = sy + sh - 1;
	pts2[0] = 0;
	pts2[1] = 0;
	pts2[2] = sw - 1;
	pts2[3] = sh - 1 ;

	gsx_fix(pfd, 0L, 0, 0);
	vro_cpyfm( S_ONLY, &ptsin[0], ( WORD *)psrc, ( WORD *)pdst );
	gsx_mon();
}


	VOID
bb_save(ps)
	REG GRECT		*ps;
{	
	bb_set(ps->g_x, ps->g_y, ps->g_w, ps->g_h, &ptsin[0], &ptsin[4], 
		&gl_src, &gl_src, &gl_tmp);
}


	VOID
bb_restore(pr)
	REG GRECT		*pr;
{
	bb_set(pr->g_x, pr->g_y, pr->g_w, pr->g_h, &ptsin[4], &ptsin[0], 
		&gl_dst, &gl_tmp, &gl_dst);
}


	VOID
gsx_setmb(boff, moff, pdrwaddr)
	UWORD		*boff, *moff;
	LONG		*pdrwaddr;
{
	i_lptr1( (LONG)boff );	
	gsx_ncode(BUT_VECX, 0, 0);
	m_lptr2( (LONG)&old_bcode );

	i_lptr1( (LONG) moff );	
	gsx_ncode(MOT_VECX, 0, 0);
	m_lptr2( (LONG)&old_mcode );

/*	i_lptr1( justretf, 0x0 );	
	gsx_ncode(CUR_VECX, 0, 0);
	m_lptr2( pdrwaddr );		don't intercept draw vector */
}


	VOID
gsx_resetmb( VOID )
{
	i_lptr1( old_bcode );	
	gsx_ncode(BUT_VECX, 0, 0);

	i_lptr1( old_mcode );
	gsx_ncode(MOT_VECX, 0, 0);

/*	i_lptr1( drwaddr );	
	gsx_ncode(CUR_VECX, 0, 0);     dont' replace cursor draw vector */
}


	WORD
gsx_tick(tcode, ptsave)
	LONG		tcode;
	LONG		*ptsave;
{
	i_lptr1( tcode );	
	gsx_ncode(TIM_VECX, 0, 0);
	m_lptr2( (LONG)ptsave );
	return(intout[0]);
}


	VOID
gsx_xmfset( pmfnew )
	LONG		pmfnew;
{
	gsx_moff();
	LWCOPY( ( WORD *)ad_intin, ( WORD *)pmfnew, 37);
 	gsx_ncode(ST_CUR_FORM, 0, 37);
	gsx_mon();
}


	VOID
gsx_mfset(pmfnew)
	LONG		pmfnew;
{
	gsx_moff();
	gl_omform = gl_cmform;		/* save the current mouse form */
	gl_omkind = gl_mkind;		/* save the current mouse kind */
	gl_omfid = gl_mfid;
	LWCOPY( ( WORD *)ad_intin, ( WORD *)pmfnew, 37);
 	gsx_ncode(ST_CUR_FORM, 0, 37);
	gl_cmform = *( (MFORM*)pmfnew );
	gsx_mon();
}


/*	Return the real mouse location	*/

	VOID
gsx_mxmy( pmx, pmy )
	WORD		*pmx, *pmy;
{
	*pmx = gl_xrat;
	*pmy = gl_yrat;
}


	WORD
gsx_button( VOID )
{
	return( gl_button );
}


	VOID
gsx_moff( VOID )
{
	if (!gl_moff)
	{
	  gsx_ncode(HIDE_CUR, 0, 0);
	  gl_mouse = FALSE;
	}

	gl_moff++;
}


	VOID
gsx_mon( VOID )
{
	gl_moff--;
	if (!gl_moff)
	{
	  gsx_1code(SHOW_CUR, 1);
	  gl_mouse = TRUE ;
	}
}


/*	Open physical work station	*/

	VOID
v_opnwk( pwork_in, phandle, pwork_out, ppt_out )
	WORD	*pwork_in;
	WORD	*phandle;
REG	WORD	*pwork_out;
	WORD	*ppt_out;
{
	i_ptsout( ( LONG )ppt_out );	/* set ptsout to work_out array */
	i_intin( ( LONG )pwork_in );	/* set intin to point to callers data  */
	i_intout( ( LONG )pwork_out );	/* set intout to point to callers data */

	gsx_ncode(OPEN_WORKSTATION, 0, 11);

	*phandle = contrl[6];		
	i_intin( ( LONG )&intin );	/* reset all the arrays	*/
	i_intout( ( LONG )&intout );
 	i_ptsin( ( LONG )&ptsin );
	i_ptsout( ( LONG )&ptsout );
}

	VOID
v_opnvwk( pwork_in, phandle, pwork_out, ppt_out )
	WORD	*pwork_in;
	WORD	*phandle;
REG	WORD	*pwork_out;
	WORD	*ppt_out;
{
	i_ptsout( ( LONG )ppt_out );	/* set ptsout to work_out array */
	i_intin( ( LONG )pwork_in );	/* set intin to point to callers data  */
	i_intout( ( LONG )pwork_out );	/* set intout to point to callers data */
	
	contrl[0] = 100;
	contrl[1] = 0;
	contrl[3] = 11;
	gsx2();


	*phandle = contrl[6];		
	i_intin( ( LONG )&intin );	/* reset all the arrays	*/
	i_intout( ( LONG )&intout );
 	i_ptsin( ( LONG )&ptsin );
	i_ptsout( ( LONG )&ptsout );
}

	VOID
v_clsvwk(handle)
WORD	handle;
{
	contrl[0] = 101;
	contrl[1] = 0;
	contrl[3] = 0;

	contrl[6] = handle;

	gsx2();

}


	VOID
v_pline( count, pxyarray )
	WORD	count;
	WORD	*pxyarray;
{
	i_ptsin( (LONG)pxyarray );
	gsx_ncode(POLYLINE, count, 0);
	i_ptsin( (LONG)&ptsin );
}


	VOID
vst_clip( clip_flag, pxyarray )
	REG WORD	clip_flag;
	WORD	*pxyarray;
{
/*	WORD		tmp;	*/
	WORD		value;

	value = ( clip_flag != 0 ) ? 2 : 0;
	i_ptsin( ( LONG )pxyarray );
	intin[0] = clip_flag;
	gsx_ncode(TEXT_CLIP, value, 1);
	i_ptsin( ( LONG )&ptsin);
}

	VOID
vst_charmap(mode)
WORD	mode;
{
	intin[0] = mode;
	gsx_ncode(236, 0, 1);
}


	VOID			/* WORD */
vst_height( height, pchr_width, pchr_height, pcell_width, pcell_height )
	WORD	height;
	WORD	*pchr_width;
	WORD	*pchr_height;
	WORD	*pcell_width;
	WORD	*pcell_height;
{
	REG WORD		*ppts;
	ppts = &ptsout[0];

	ptsin[0] = 0;
	ptsin[1] = height;
	gsx_ncode(CHAR_HEIGHT, 1, 0);
	*pchr_width = ppts[0];
	*pchr_height = ppts[1];
	*pcell_width = ppts[2];
	*pcell_height = ppts[3];
}


	VOID
vr_recfl( pxyarray, pdesMFDB )
	WORD	*pxyarray;
	WORD	*pdesMFDB;
{
	i_ptr( ( LONG )pdesMFDB );
	i_ptsin( ( LONG )pxyarray );
	gsx_ncode(FILL_RECTANGLE, 2, 1);
	i_ptsin( ( LONG )&ptsin );
}


	VOID
vro_cpyfm( wr_mode, pxyarray, psrcMFDB, pdesMFDB )
	WORD	wr_mode;
	WORD	*pxyarray;
	WORD	*psrcMFDB;
	WORD	*pdesMFDB;
{
	intin[0] = wr_mode;
	i_ptr( ( LONG )psrcMFDB );
	i_ptr2( ( LONG )pdesMFDB );
	i_ptsin( ( LONG )pxyarray );
	gsx_ncode(COPY_RASTER_FORM, 4, 1);
	i_ptsin( ( LONG )&ptsin );
}


	VOID
vrt_cpyfm( wr_mode, pxyarray, psrcMFDB, pdesMFDB, fgcolor, bgcolor )
	WORD    wr_mode;
	WORD    *pxyarray;
	WORD    *psrcMFDB;
	WORD    *pdesMFDB;
	WORD	fgcolor, bgcolor;
{
	REG WORD		*pintin;
	pintin = &intin[0];

	pintin[0] = wr_mode;
	pintin[1] = fgcolor;
	pintin[2] = bgcolor;
	i_ptr( ( LONG )psrcMFDB );
	i_ptr2( ( LONG )pdesMFDB );
	i_ptsin( ( LONG )pxyarray );
	gsx_ncode(121, 4, 3);
	i_ptsin( ( LONG )&ptsin );
}


	VOID
vrn_trnfm( psrcMFDB, pdesMFDB )
	WORD	*psrcMFDB;
	WORD	*pdesMFDB;
{
	i_ptr( ( LONG )psrcMFDB );
	i_ptr2( ( LONG )pdesMFDB );
	gsx_ncode(TRANSFORM_FORM, 0, 0);
}


	VOID
vsl_width( width )
	WORD	width;
{
	ptsin[0] = width;
	ptsin[1] = 0;
	gsx_ncode(S_LINE_WIDTH, 1, 0);
}


	WORD
v_load_fonts( VOID )
{
	intin[0] = 0;
	gsx_ncode(LOAD_ALPHA_TEXT,0,1 );
	return( intout[0] );
}

	WORD
v_font_name( i, name, fsmflag )
	WORD	i;
	BYTE	*name;
	WORD	*fsmflag;
{
	intin[0] = i;
	gsx_ncode( FONT_NAME, 0, 1 );
	for ( i = 1; i <=32; i++ )
	  *name++ = (BYTE)intout[i];

	*fsmflag = intout[33];
	return( intout[0] );
}
 	
	WORD
v_setfont( id )
	WORD	id;
{
	intin[0] = id;
	gsx_ncode( SET_FONT, 0, 1 );
	return( intout[0] );
}


	VOID
v_set_alignment( hor_in, ver_in )
	WORD	hor_in,ver_in;
{
	intin[0] = hor_in;
	intin[1] = ver_in;
	gsx_ncode( SET_ALIGNMENT, 0, 2 );
}


	WORD
v_setpoint( point, wchar, hchar, wbox, hbox )
	WORD	point;
	WORD	*wchar,*hchar,*wbox,*hbox;
{
	intin[0] = point;
	gsx_ncode( ST_CH_HEIGHT, 0, 1 );	/* vst_point */
	*wchar = ptsout[0];
	*hchar = ptsout[1];
	*wbox = ptsout[2];
	*hbox = ptsout[3];
	return intout[0];
}	


	VOID
v_unload_font( VOID )
{
	if ( gl_fsm )
	  gsx_ncode(UNLOAD_ALPHA_TEXT,0,1 );
}


	VOID
v_monotext( x,y,i,width )
	WORD  x,y,i;
	WORD  width;
{
	ptsin[0] = x;
	ptsin[1] = y;
	ptsin[2] = width;
	gsx_ncode( 233, 1, i );
}


	WORD
vst_arbpt( point,chwd,chht,cellwd,cellht )
	WORD point;
	WORD *chwd,*chht,*cellwd,*cellht;
{
	intin[0] = point;
	gsx_ncode( 246, 0, 1 );
	*chwd    = ptsout[0];
	*chht    = ptsout[1];
	*cellwd  = ptsout[2];
	*cellht  = ptsout[3];
	return(intout[0]);
}


	VOID
vqt_width( inchar, space, dummx, dummy ) 
	WORD	inchar;
	WORD	*space,*dummx,*dummy;
{
	intin[0] = inchar;
	gsx_ncode( 117, 0, 1 );
	*space = ptsout[0];
	*dummx = ptsout[2];
	*dummy = ptsout[4];
}
	
