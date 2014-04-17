/*	APGSXIF.C	05/06/84 - 02/04/85	Lee Lorenzen		*/
/*	Reg Opt		03/08/85 - 03/09/85	Derek Mui		*/
/*	Crunching	4/10/86			Derek Mui		*/
/*	Fix at gsx_xbox	6/11/86			Derek Mui		*/
/*	Change at gsx_start for new pixel ratio	7/26/89	D.Mui		*/
/*	Restore into C lanuage from 3.01	8/30/90	D.Mui		*/
/*	Inquire the number of planes by making extend call 2/13/92	*/
/*	Add GDOS support for gsx_tblt & gsx_tcalc 5/21/93 H.M.Krober	*/
/*	Add set_cufont call to set current font	  5/21/93 H.M.Krober	*/
/*
*	-------------------------------------------------------------
*	GEM Application Environment Services		  Version 1.0
*	Serial No.  XXXX-0000-654321		  All Rights Reserved
*	Copyright (C) 1985			Digital Research Inc.
*	-------------------------------------------------------------
*/

#include "portab.h"
#include "machine.h"
#include "obdefs.h"
#include "vdidefs.h"
#include "mintbind.h"
#include "osbind.h"
#include "gemdos.h"

#include "pgem.h"
#include "pmisc.h"

EXTERN	VOID 	gsx2( VOID );

EXTERN	WORD	min();
EXTERN	WORD	ctldown;
EXTERN	BYTE	AE_PNTSIZE[];
EXTERN	BYTE	AE_FONTID[];

GLOBAL	WORD	gl_space;
GLOBAL	WORD	gl_sspace;
GLOBAL	WORD	gl_fsm;		/* 0 system font 	*/
				/* 1 .... load font 	*/
GLOBAL	WORD	gl_spd;		/* Speedo engine	*/

GLOBAL	WORD	gl_numfonts;
GLOBAL	WORD	scnd_load;

GLOBAL	WORD	gl_size;
GLOBAL	WORD	gl_width;
GLOBAL	WORD	gl_height;

GLOBAL WORD	gl_nrows;
GLOBAL WORD	gl_ncols;

GLOBAL WORD	gl_wchar;	/* character cell width	*/
GLOBAL WORD	gl_hchar;	/* character cell height*/

GLOBAL WORD	gl_wschar;	/* small character cell width */
GLOBAL WORD	gl_hschar;	/* small character cell height*/

GLOBAL WORD	gl_wptschar;	/* regular point size	*/
GLOBAL WORD	gl_hptschar;	

GLOBAL WORD	gl_wsptschar;	/* small point size	*/
GLOBAL WORD	gl_hsptschar;

GLOBAL WORD	gl_wbox;
GLOBAL WORD	gl_hbox;

GLOBAL WORD	gl_xclip;
GLOBAL WORD	gl_yclip;
GLOBAL WORD	gl_wclip;
GLOBAL WORD	gl_hclip;

GLOBAL WORD 	gl_nplanes;
GLOBAL WORD 	gl_handle;

GLOBAL FDB	gl_src;
GLOBAL FDB	gl_dst;

GLOBAL WS	gl_ws;
GLOBAL WORD	contrl[12];
GLOBAL WORD	intin[256];
GLOBAL WORD	ptsin[256];
GLOBAL WORD	intout[256];
GLOBAL WORD	ptsout[256];

GLOBAL LONG	ad_intin;

GLOBAL WORD	gl_mode;
GLOBAL WORD	gl_mask;
GLOBAL WORD	gl_tcolor;
GLOBAL WORD	gl_lcolor;
GLOBAL WORD	gl_fis;
GLOBAL WORD	gl_patt;
GLOBAL WORD	gl_font;
GLOBAL WORD	gl_fid;		/* font id			*/
GLOBAL GRECT	gl_rscreen;	/* full screen size		*/
GLOBAL GRECT	gl_rfull;	/* work area below the menu	*/
GLOBAL GRECT	gl_rzero;	/* zero GRECT			*/
GLOBAL GRECT	gl_rcenter;	/* center of the screen		*/	
GLOBAL GRECT	gl_rmenu;	/* menu area			*/


GLOBAL WORD	cu_font;	/* current font type used	*/
				/* font types:			*/
				/*  0 = Speedo Proportional	*/
				/*  1 = Speedo Monospaced	*/
				/*  2 = GDOS Bitmap		*/
				/*  3 = System Font		*/
				/*  5 = Small Font		*/
				
GLOBAL WORD	cu_fntid;	/* current font id (GDOS)	*/	
GLOBAL WORD	cu_size;	/* current font size 		*/
GLOBAL WORD	cu_wchar;	/* current char width		*/
GLOBAL WORD	cu_hchar;	/* current char height		*/
GLOBAL WORD	cu_space;	/* current char space		*/
GLOBAL WORD	cu_hptschar;	/* current char width pts	*/
GLOBAL WORD	cu_wptschar;	/* current char height pst	*/
GLOBAL WORD	cu_spd;		/* current font is speedo font	*/
GLOBAL WORD	cu_prop;	/* current font uses 		*/
				/*   proportional output	*/


WORD	bitstmap;		/* TRUE = use Bitstream char map*/
				/* FALSE = use ATARI char map   */

WORD	gl_bitstmap;


/*
 *	Bitstream character mapping table
 */
short ATable[] = {
      0,    295,    292,    294,    293,     336,    559,    353,    302,    505,     
     31,
    330,     31,     31,    522,    523,     16,     17,     18,     19,     20,
     21,     22,     23,     24,     25,     31,     31,     31,     31,     31,
     31,    
     0,      1,      2,      3,      4,      5,      6,      7,      8,      9,
     10,     11,     12,     13,     14,     15,     16,     17,     18,     19,
     20,     21,     22,     23,     24,     25,     26,     27,     28,     29,
     30,     31,     32,     33,     34,     35,     36,     37,     38,     39,
     40,     41,     42,     43,     44,     45,     46,     47,     48,     49,
     50,     51,     52,     53,     54,     55,     56,     57,     58,     59,
     60,     61,     62,     63,     64,     65,     66,     67,     68,     69,
     70,     71,     72,     73,     74,     75,     76,     77,     78,     79,
     80,     81,     82,     83,     84,     85,     86,     87,     88,     89,
     90,     91,     92,     93,     94,    314,    148,    215,    252,    258,
    256,    260,    117,    149,    248,    246,    250,    236,    238,    240,
    255,    113,    251,    118,    114,    203,    205,    201,    213,    211,
    221,    206,    216,     98,     97,    274,    121,     99,    262,    242,
    199,    209,    195,    196,     31,     31,    127,    310,    309,    153,
    151,    128,    125,    126,    254,    207,    115,    119,    120,    116,
    259,    253,    208,    136,    130,    108,    279,    503,    504,    334,
    275,    276,     31,     31,     31,     31,     31,     31,     31,     31,
     31,     31,     31,     31,     31,     31,     31,     31,     31,     31,
     31,     31,     31,     31,     31,     31,     31,     31,     31,    110,
     31,    303,    319,    320,    313,    326,    316,    327,    325,    328,
    317,    324,    318,    321,    428,    329,    298,    299,    287,    286,
    290,    291,    300,    301,    285,    289,    499,    500,    341,    302,
    543,    160,    161,    230
};




	BOOLEAN
gsx_sclip(pt)
	GRECT		*pt;
{
	REG WORD	*ppts;

	ppts = &ptsin[0];

	r_get( (WORD *)pt, &gl_xclip, &gl_yclip, &gl_wclip, &gl_hclip);

	if ( gl_wclip && gl_hclip )
	{
	  ppts[0] = gl_xclip;
	  ppts[1] = gl_yclip;
	  ppts[2] = gl_xclip + gl_wclip - 1;
	  ppts[3] = gl_yclip + gl_hclip - 1;
	  vst_clip( TRUE, &ppts[0]);
	} 
	else 
	  vst_clip( FALSE, &ppts[0]);

	return( TRUE );
}


	VOID
gsx_gclip(pt)
	GRECT		*pt;
{
	r_set( (WORD *)pt, gl_xclip, gl_yclip, gl_wclip, gl_hclip);
}


	WORD
gsx_chkclip(pt)
	REG GRECT		*pt;
{
						/* if clipping is on	*/
	if (gl_wclip && gl_hclip)
	{
 	  if ((pt->g_y + pt->g_h) < gl_yclip)
	    return(FALSE);			/* all above	*/
	  if ((pt->g_x + pt->g_w) < gl_xclip) 
	    return(FALSE);			/* all left	*/
	  if ((gl_yclip + gl_hclip) <= pt->g_y)
	    return(FALSE);			/* all below	*/
	  if ((gl_xclip + gl_wclip) <= pt->g_x)
	    return(FALSE);			/* all right	*/
	}
	return(TRUE);
}


	VOID
gsx_pline(offx, offy, cnt, pts)
	WORD		offx, offy;
	REG WORD		cnt;
	REG WORD		*pts;
{
	REG WORD		i, j;

	for (i=0; i<cnt; i++)
	{
	  j = i * 2;
	  ptsin[j] = offx + pts[j];
	  ptsin[j+1] = offy + pts[j+1];
	}

	gsx_xline( cnt, &ptsin[0]);
}

						/* in DRAWLINE.A86	*/
	VOID
gsx_cline(x1, y1, x2, y2)
	UWORD		x1, y1, x2, y2;
{
/*	WORD		x, y, w, h;*/

	gsx_moff();
	v_pline( 2, &x1 );
	gsx_mon();
}

	VOID
gsx_attr(text, mode, color)
	UWORD		text;
	REG UWORD		mode, color;
{
	REG WORD		tmp;
	REG WORD		*pcntr;
	pcntr = &contrl[0];

	tmp = intin[0];
	pcntr[1] = 0;
	pcntr[3] = 1;
	pcntr[6] = gl_handle;
	if (mode != gl_mode)
	{
	  pcntr[0] = SET_WRITING_MODE;
	  intin[0] = gl_mode = mode;
	  gsx2();
	}
	pcntr[0] = FALSE;
	if (text)
	{
	  if (color != gl_tcolor)
	  {
	    pcntr[0] = S_TEXT_COLOR;
	    gl_tcolor = color;
	  }
	}	
	else
	{
	  if (color != gl_lcolor)
	  {
	    pcntr[0] = S_LINE_COLOR;
	    gl_lcolor = color;
	  }
	}
	if (pcntr[0])
	{
	  intin[0] = color;
	  gsx2();
	}
	intin[0] = tmp;
}


	VOID
gsx_bxpts(pt)
	REG GRECT		*pt;
{
	REG WORD		*ppts;
	ppts = &ptsin[0];

	ppts[0] = pt->g_x;
	ppts[1] = pt->g_y;
	ppts[2] = pt->g_x + pt->g_w - 1;
	ppts[3] = pt->g_y;
/*	ppts[4] = pt->g_x + pt->g_w - 1;	*/
	ppts[4] = ppts[2];
	ppts[5] = pt->g_y + pt->g_h - 1;
	ppts[6] = pt->g_x;
/*	ppts[7] = pt->g_y + pt->g_h - 1;	*/
	ppts[7] = ppts[5];
	ppts[8] = pt->g_x;
	ppts[9] = pt->g_y;
}


	VOID
gsx_box(pt)
	GRECT		*pt;
{
	gsx_bxpts(pt);
	v_pline( 5, &ptsin[0] );
}


/*	Draw an XOR box		*/

	VOID
gsx_xbox(pt)
	GRECT		*pt;
{

	gsx_bxpts(pt);
	gsx_xline( 4, &ptsin[0] );
	ptsin[2] = ptsin[6];		/* fix the clipping problem of */
	ptsin[3] = ptsin[7] - 1;	/* xbox		*/
	gsx_xline( 2, &ptsin[0] );
}



	VOID
gsx_xcbox(pt)
	REG GRECT		*pt;
{
	REG WORD		wa, ha;
	REG WORD		*ppts;
	ppts = &ptsin[0];

	wa = 2 * gl_wbox;
	ha = 2 * gl_hbox;
	ppts[0] = pt->g_x;
	ppts[1] = pt->g_y + ha;
	ppts[2] = pt->g_x;
	ppts[3] = pt->g_y;
	ppts[4] = pt->g_x + wa;
	ppts[5] = pt->g_y;
	gsx_xline( 3, &ppts[0] );
	ppts[0] = pt->g_x + pt->g_w - wa;
	ppts[1] = pt->g_y;
	ppts[2] = pt->g_x + pt->g_w - 1;
	ppts[3] = pt->g_y;
/*	ppts[4] = pt->g_x + pt->g_w - 1;	*/
	ppts[4] = ppts[2];
	ppts[5] = pt->g_y + ha;
	gsx_xline( 3, &ppts[0] );
	ppts[0] = pt->g_x + pt->g_w - 1;
	ppts[1] = pt->g_y + pt->g_h - ha;
/*	ppts[2] = pt->g_x + pt->g_w - 1;	*/
	ppts[2] = ppts[0];
	ppts[3] = pt->g_y + pt->g_h - 1;
	ppts[4] = pt->g_x + pt->g_w - wa;
/*	ppts[5] = pt->g_y + pt->g_h - 1;	*/
	ppts[5] = ppts[3];
	gsx_xline( 3, &ppts[0] );
	ppts[0] = pt->g_x + wa;
	ppts[1] = pt->g_y + pt->g_h - 1;
	ppts[2] = pt->g_x;
/*	ppts[3] = pt->g_y + pt->g_h - 1;	*/
	ppts[3] = ppts[1];
	ppts[4] = pt->g_x;
	ppts[5] = pt->g_y + pt->g_h - ha;
	gsx_xline( 3, &ppts[0] );
}

VOID
gsx_fix(pfd, theaddr, wb, h)
	REG FDB			*pfd;
	REG LONG		theaddr;
	REG WORD		wb;
	WORD		h;
{
	if ( theaddr == 0x0L )
	{
	  pfd->fd_w = gl_ws.ws_xres + 1;
	  pfd->fd_wdwidth = pfd->fd_w / 16;
	  pfd->fd_h = gl_ws.ws_yres + 1;
	  pfd->fd_nplanes = gl_nplanes;
	}
	else
	{
	  pfd->fd_wdwidth = wb / 2;
	  pfd->fd_w = wb * 8;
	  pfd->fd_h = h;
	  pfd->fd_nplanes = 1;
	}
	pfd->fd_stand = FALSE;
	pfd->fd_addr = theaddr;
}


	VOID
gsx_blt(saddr, sx, sy, swb, daddr, dx, dy, dwb, w, h, rule, fgcolor, bgcolor)
	LONG		saddr;
	REG UWORD		sx, sy, swb;
	LONG		daddr;
	REG UWORD		dx, dy;
	UWORD		dwb, w, h, rule;
	WORD		fgcolor, bgcolor;
{
	REG WORD		*ppts;
	ppts = &ptsin[0];

	gsx_fix(&gl_src, saddr, swb, h);
	gsx_fix(&gl_dst, daddr, dwb, h);

	gsx_moff();
	ppts[0] = sx;
	ppts[1] = sy;
	ppts[2] = sx + w - 1;
	ppts[3] = sy + h - 1;
	ppts[4] = dx;
	ppts[5] = dy;
	ppts[6] = dx + w - 1;
	ppts[7] = dy + h - 1 ;
	if (fgcolor == -1)
	  vro_cpyfm( rule, &ppts[0], (WORD *)&gl_src, (WORD *)&gl_dst);
	else
	  vrt_cpyfm( rule, &ppts[0], (WORD *)&gl_src, (WORD *)&gl_dst, 
		fgcolor, bgcolor);
	gsx_mon();
}


	VOID
bb_screen(scrule, scsx, scsy, scdx, scdy, scw, sch)
	WORD		scrule, scsx, scsy, scdx, scdy, scw, sch;
{
	gsx_blt(0x0L, scsx, scsy, 0, 
		0x0L, scdx, scdy, 0,
		scw, sch, scrule, -1, -1);
}


	VOID
gsx_trans(saddr, swb, daddr, dwb, h, fg, bg)
	LONG		saddr;
	UWORD		swb;
	LONG		daddr;
	UWORD		dwb;
	REG UWORD		h;
	WORD		fg, bg;
{
	gsx_fix(&gl_src, saddr, swb, h);
	gl_src.fd_stand = TRUE;
	gl_src.fd_nplanes = 1;

	gsx_fix(&gl_dst, daddr, dwb, h);
	vrn_trnfm( (WORD *)&gl_src, (WORD *)&gl_dst );
}



/*	Set font point size
*	The point size is different from the character height  
*		
*/

	VOID
s_pntsize( buffer )
	BYTE	*buffer;
{
	LONG	l;
	WORD	size;
	
	if ( asctobin( buffer, &l ) )
	{
	  if ( size = (WORD)l )
	  {
	    if ( gl_fsm ) {
		vst_arbpt( size, &gl_wptschar, &gl_hptschar, &gl_wchar, &gl_hchar );
		gl_hchar += 1;		/* necessary for Speedo fonts; otherwise in replacement */
		gl_hptschar += 1;	/* mode (BOXTEXT) the top line gets overdrawn.		*/
	    } else
	      size = v_setpoint( size,	&gl_wptschar, &gl_hptschar, &gl_wchar, &gl_hchar );
		
	    gl_ws.ws_chmaxh = gl_hptschar;		/* max height of character	*/
	    gl_size = size;
	  }
	}
}


/*	Load fonts	*/

	VOID
gsx_lfont( buffer )
	BYTE	*buffer;
{
	WORD	id,i,type;
	BYTE	name[40];
	LONG	l;

	if ( asctobin( buffer, &l ) )
	{
#if 0	  /* already done, see gsx_start +++ 5/18/93 HMK */
	  num = v_load_fonts();
#endif
	  for ( i = 0; i < gl_numfonts; i++ )
	  {
	    id = v_font_name( i, name, &type );
	
	    if ( id == (WORD)l )
	    {
	      gl_fid = id;
	      gl_fsm = type;
	      gl_bitstmap = bitstmap = type;
	      v_setfont( gl_fid );
	      s_pntsize("10");	/* set default point size */	
	      break;
	    }
	  }
	}
}

WORD	work_in[11];
WORD	work_out[57];

	VOID
gsx_start()
{
/*	REG WORD	nc;*/
	WORD		dummy;
	LONG		*l;
	WORD		i, handle;          
						/* force update		*/
	gl_mode = gl_mask = gl_tcolor = gl_lcolor = -1;
	gl_fis = gl_patt = gl_font = -1;
	gl_xclip = 0;
	gl_yclip = 0;
	gl_width = gl_wclip = gl_ws.ws_xres + 1;
	gl_height = gl_hclip = gl_ws.ws_yres + 1;
	gl_fsm = 0;
	gl_fid = 1;
	gl_numfonts = 1;
	gl_bitstmap = bitstmap = 0;
  
	for (i = 0; i < 10; i++)
		work_in[i] = 1;
	work_in[10] = 2;	/* RC */
	v_opnvwk(work_in, &handle, work_out, &work_out[45]);
	v_clsvwk(handle);

	intin[0] = 1;
	gsx_ncode( 102, 0, 1 );
	gl_nplanes = intout[4];

	/* Check for if _SPD presents	*/

	gl_spd = 0;

	if (aescookie( 0x46534d43L, (LONG *)&l ) )	/* FSMC */
	{
	  if ( (*l++ == 0x5F535044L) && 
	  (((WORD)(*l >> 16L)) >= 0x0411) && !ctldown) { /* _SPD */
	    	gl_spd = 1; /* at least Version 4.11 */
	  }
	}

	Debug1( "Number of planes is " );
	Ndebug1( (LONG)gl_nplanes );

	/* The driver may have more than two fonts.  The large font */
	/* to the services is the default font in the driver.  This */
	/* font will give us 80 chars across the screen in all but  */
	/* 320 pels in x, when it will be the 40 column font.	    */

	gsx_ncode(38, 0, 0);		/* inquire text attributes	*/
	gl_wptschar = ptsout[0];	/* character width		*/
	gl_hptschar = ptsout[1];	/* character height		*/
	gl_wchar = ptsout[2];		/* Cell width			*/
	gl_hchar = ptsout[3];		/* Cell height			*/
	
	gl_size = 0;
	gl_ws.ws_chmaxh = gl_hptschar;	/* max height of character	*/
					/* Set the small char height size	*/
	vst_height( gl_ws.ws_chminh, &gl_wsptschar, &gl_hsptschar, &gl_wschar, &gl_hschar );
					/* Set the default char height size	*/
	vst_height( gl_ws.ws_chmaxh, &gl_wptschar, &gl_hptschar, &gl_wchar, &gl_hchar );


					/* Load AES font type	*/
	if (gl_spd) {
		if (!scnd_load)
			Cconws("Loading GDOS fonts.\r\n");
		scnd_load = TRUE;
		gl_numfonts = v_load_fonts();	/* +++ HMK 5/18/93*/
	}
	Debug7( "Set font\r\n" );

	(VOID) s_aescnf( AE_FONTID,  (WORD (*)()) &gsx_lfont );
	(VOID) s_aescnf( AE_PNTSIZE, (WORD (*)()) &s_pntsize );

/* if font is not initialized, assume system font */
/* ++ERS 12/18/92 */
	if (gl_fid < 0) {
		gl_fid = 1;
	}

	if ( gl_spd && gl_fsm && gl_fid != 1 )	/* if Speedo font	*/
	{				/* get the widthest font value	*/
	  vqt_width( 'M', &gl_space, &dummy, &dummy ); 
	  gl_wchar = gl_space;

	 /* gl_ws.ws_chminh += 2;*/	/* this is a kludge */
					/* which still doesn't work: ERS */
	}
#if 0				
	/* MOVED UP, 05/93 HMK */
	/* SMALL will always default to ROM system font !!! */
					/* get the small size character	*/
	vst_height( gl_ws.ws_chminh, &gl_wsptschar, &gl_hsptschar, &gl_wschar, &gl_hschar );

	if ( gl_spd && gl_fsm && gl_fid != 1 )	/* if Speedo font	*/
	{
	  vqt_width( 'M', &gl_sspace, &dummy, &dummy );
	  gl_wschar = gl_sspace;
	}
	Debug1( "System min char height is " );
	Ndebug1( (LONG)gl_ws.ws_chminh );
#endif
/*	v_set_alignment( 0, 1 );	*/

	if ( gl_hchar < ( gl_hptschar + 2 ) ) {
	  Debug1("gsx_start: gl_hchar = gl_hptschar + 2;\r\n");
	  gl_hchar = gl_hptschar + 2;
	}

	gl_ncols = gl_width / gl_wchar ;
	gl_nrows = gl_height / gl_hchar;
	gl_hbox = gl_hchar + 3;

	/* Changed 7/26/90	*/

	gl_wbox = (gl_hbox * gl_ws.ws_hpixel) / gl_ws.ws_wpixel;

	if ( gl_wbox < ( gl_wchar + 2 ) )
	  gl_wbox = gl_wchar + 2;

	/* Set up current font information, +++ HMK 05/18/93  */
	cu_font		= IBM;
	cu_fntid	= gl_fid;

	cu_wchar	= gl_wchar;
	cu_hchar	= gl_hchar;
	cu_space	= gl_space;
	cu_wptschar	= gl_wptschar;
	cu_hptschar	= gl_hptschar;
#if 0					/* done in gsx_lfont() */
	gl_bitstmap = bitstmap = (cu_fntid > 1);	
#endif
	cu_prop		= TRUE;		/* for system font, use v_gtext */
	cu_spd		= gl_fsm;

Debug1("gsx_start: GL_HCHAR    ="); Ndebug1((LONG)gl_hchar);
Debug1("gsx_start: GL_HPTSCHAR ="); Ndebug1((LONG)gl_hptschar);


	vsl_type( 7 );		/* User defined line pattern */
	vsl_width( 1 );		/* line width	*/
	vsl_udsty( 0xffff );	/* Line pattern	*/	
	r_set((WORD *)&gl_rscreen, 0, 0, gl_width, gl_height);
	r_set((WORD *)&gl_rfull, 0, gl_hbox, gl_width, (gl_height - gl_hbox));
	r_set((WORD *)&gl_rzero, 0, 0, 0, 0);
	r_set((WORD *)&gl_rcenter, (gl_width-gl_wbox)/2, (gl_height-(2*gl_hbox))/2, 
			gl_wbox, gl_hbox);
	r_set((WORD *)&gl_rmenu, 0, 0, gl_width, gl_hbox);
	ad_intin = (LONG)(ADDR(&intin[0]));
}


	VOID
bb_fill(mode, fis, patt, hx, hy, hw, hh)
	WORD		mode, fis;
	REG WORD		patt, hx, hy, hw, hh;
{
	REG WORD		*ppts;
	ppts = &ptsin[0];

	gsx_fix(&gl_dst, 0x0L, 0, 0);
	ppts[0] = hx;
	ppts[1] = hy;
	ppts[2] = hx + hw - 1;
	ppts[3] = hy + hh - 1;

	gsx_attr(TRUE, mode, gl_tcolor);
	if (fis != gl_fis)
	{
	  vsf_interior( fis);
	  gl_fis = fis;
	}
	if (patt != gl_patt)
	{
	  vsf_style( patt );
	  gl_patt = patt;
	}
	vr_recfl( &ppts[0], (WORD *)&gl_dst );
}


	UWORD		
ch_width(fn)
	WORD		fn;
{				/* just for system font */
	if (fn == IBM)
	  return(gl_wchar);
	if (fn == SMALL)
	  return(gl_wschar);

	return(0);
}



	UWORD
ch_height(fn)
	WORD		fn;
{				/* just for system font */
	if (fn == IBM)
	  return(gl_hchar);
	if (fn == SMALL)
	  return(gl_hschar);

	return(0);
}

/*
 *	set_cufont  +++ HMK 5/93
 *	This function is called in gemoblib before every
 *	gsx_tblt to set the proper font.
 */


	UWORD
set_cufont(font, font_id, size)
WORD	font;
WORD	font_id;
WORD	size;

{
	WORD		dummy;
	WORD		buf;
	
	if (((font == IBM) || (font == SMALL)) && (cu_font == font)) {
		return cu_font;
	} else if ((font == cu_font) && (font_id == cu_fntid) && (cu_size == size)) {
		if (font < 2)	/* SPEEDO FONT */
			bitstmap = TRUE;
		return cu_font;
	}

	buf = intin[0];

	Debug7("set_cufont: font = ");  Ndebug7((LONG) font);
	Debug7("set_cufont: fontid = ");  Ndebug7((LONG) font_id);
	Debug7("set_cufont: fontsize = ");  Ndebug7((LONG) size);
	Debug7("set_cufont: gl_spd = ");  Ndebug7((LONG) gl_spd);

	if (!gl_spd && (font_id > 1)) {		/* if no GDOS, default to system font */
		if (font < 3)
			font = IBM;
	}
	Debug7("set_cufont: font = ");  Ndebug7((LONG) font);

	switch (font) {
	case GDOS_MONO:			/* MONO SPACED FONT (ALWAYS SPEEDO!!!) */
		if (v_setfont(font_id) != font_id)
			goto GO_IBM;
		cu_font = font;
		cu_fntid = font_id;
		cu_size = size;
		bitstmap = TRUE;
		cu_prop = FALSE;
		cu_spd = TRUE;
		if (size == -1)
			size = (gl_size) ? gl_size : 10;
		vst_arbpt( size, &cu_wptschar, &cu_hptschar, &cu_wchar, &cu_hchar );
		cu_hchar += 1;		/* necessary for Speedo fonts; otherwise in replacement */
		cu_hptschar += 1;	/* mode (BOXTEXT) the top line gets overdrawn.		*/
		vqt_width( 'M', &cu_space, &dummy, &dummy ); 
		cu_wchar = cu_space;
		break;

	case GDOS_BITM:		/* old GDOS bitmap font       		  */
	case GDOS_MBITM:	/* old GDOS bitmap font (monospaced)      */
	case GDOS_PROP:		/* PROPORTIONAL FONT (SPEEDO) 		  */

		if (v_setfont(font_id) != font_id)
			goto GO_IBM;
		cu_font = font;		
		cu_prop = TRUE;
		cu_fntid = font_id;
		cu_size = size;
		bitstmap = (font == GDOS_PROP);
		if (size == -1)
			size = (gl_size) ? gl_size : 10;
		if (gl_spd && (font == GDOS_PROP)) {
			cu_spd = TRUE;
			vst_arbpt( size, &cu_wptschar, &cu_hptschar, &cu_wchar, &cu_hchar );
			cu_hchar += 1;		/* necessary for Speedo fonts; otherwise in replacement */
			cu_hptschar += 1;	/* mode (BOXTEXT) the top line gets overdrawn.		*/	
		} else {
			cu_spd = FALSE;		    
			v_setpoint( size, &cu_wptschar, &cu_hptschar, &cu_wchar, &cu_hchar );
		}
		break;
GO_IBM:
	default:
	case IBM:		/* default system font */
		cu_font = IBM;	
		gl_fid = v_setfont(gl_fid);

		if (!gl_size) {
				vst_height( gl_ws.ws_chmaxh, &dummy, &dummy, &dummy, &dummy );
				cu_prop = TRUE;  /* use v_gtext */	
				cu_spd = FALSE; 
		} else {
			if ( gl_fsm ) {
	  			vst_arbpt( gl_size, &dummy, &dummy, &dummy, &dummy );
				cu_prop = FALSE;
				cu_spd = TRUE; 
	    		} else {
				v_setpoint( gl_size, &dummy, &dummy, &dummy, &dummy );
				cu_prop = TRUE;
				cu_spd = FALSE; 
			}
		}
		cu_fntid = gl_fid;
		cu_size = size;
		bitstmap = gl_bitstmap;

		cu_wchar = gl_wchar;
		cu_hchar = gl_hchar;
		cu_space = gl_space;
	  	cu_hptschar = gl_hptschar;
	  	cu_wptschar = gl_wptschar;
		break;

	case SMALL:		/* small system font */
		cu_font = font;
		cu_fntid = 1;
		cu_size = size;
		bitstmap = FALSE;
		cu_wchar = gl_wschar;
		cu_hchar = gl_hschar;
		cu_space = gl_wschar;
	  	cu_hptschar = gl_hsptschar;
	  	cu_wptschar = gl_wsptschar;	
	  	cu_space = gl_sspace;
		cu_prop = TRUE;			/* use v_gtext */
		cu_spd = FALSE;
		v_setfont(1);			/* always ROM system font !!! */
		vst_height( gl_ws.ws_chminh, &dummy, &dummy, &dummy, &dummy ); 
		break;
	}
	intin[0] = buf;

	return	cu_font;
}


/*	Calculate where to put the text		*/

	VOID
gsx_tcalc(ptext, ptextw, ptexth, pnumchs)
	LONG			ptext;
	REG WORD		*ptextw;
	WORD			*ptexth;
	REG WORD		*pnumchs;
{
	WORD			buf;
	WORD			dummy;	
	WORD			wc;
	WORD			hc;
	WORD			snum;

	wc = cu_wchar;
	hc = cu_hchar;
  
	*pnumchs = str2intin((BYTE*)ptext); 
					/* figure out the min width of  text	*/
	if ((cu_font == GDOS_PROP) || (cu_font == GDOS_BITM)) {
		WORD	pptw = 0;			/* system font is mono spaced, HACK!!! */
		REG	BYTE *s;

		buf = intin[0];
		snum = *pnumchs;

		for (s = (BYTE *) ptext; *s ; s++) {
			vqt_width(*s, &wc, &dummy, &dummy);
			pptw += wc;
			if (pptw > *ptextw) {
				snum = (WORD) (s - ptext);
				break;
			}
		}
		intin[0] = buf;

		*ptextw = min(*ptextw, pptw);
	} else {
		*ptextw = min(*ptextw, *pnumchs * wc );
	}
					/* figure out the min height of text	*/
	*ptexth = min(*ptexth, hc );

			/* if the height and width are big enough to put	*/
	if (*ptexth / hc) {		/* the text then do it			*/	
	  if ((cu_font == GDOS_PROP) || (cu_font == GDOS_BITM))
		*pnumchs = min(*pnumchs, snum);
	  else
		*pnumchs = min(*pnumchs, *ptextw / wc );
	} else
	  *pnumchs = 0;

}  /* gsx_tcalc */


	VOID
gsx_tblt(x, y, tb_nc)
	REG WORD	x, y;
	WORD		tb_nc;
{
	WORD		space;
	WORD		buf;

	Debug7("gsx_tblt: cu_font = "); Ndebug7((LONG) cu_font);

	Debug7("gsx_tblt: GL_HCHAR    ="); Ndebug7((LONG)gl_hchar);
	Debug7("gsx_tblt: GL_HPTSCHAR ="); Ndebug7((LONG)gl_hptschar);

	if (cu_font == IBM)
	{
	  y += gl_hptschar;	
	  space = gl_space;
	} 
	else if (cu_font == SMALL)
	{
	  y += gl_hsptschar;	
	  space = gl_sspace;
	} 
	else
	{
	  y += cu_hptschar;
	  space = cu_space; 
	}
	if (bitstmap && (cu_font != SMALL)) {
		buf = intin[0];		/* If a Speedo font is the system font */	
		vst_charmap(0);		/* we have to use the Bitstream char   */
		intin[0] = buf;		/* map to get special characters < 32. */
					/* (we do our own mapping)	       */
	}

	if ( (cu_prop) || !gl_spd )
	{
	  contrl[0] = 8;		/* TEXT */
	  contrl[1] = 1;
	  contrl[6] = gl_handle;
	  ptsin[0] = x;
	  ptsin[1] = y;
	  contrl[3] = tb_nc;
	  gsx2();
	}
	else
	  v_monotext( x, y, tb_nc, space );

	if (bitstmap && (cu_font < 2)) {
		vst_charmap(1);		/* Use ATARI char map */
		bitstmap = FALSE;
	}
}



	VOID
gsx_xline( ptscount, ppoints )
	WORD		ptscount;
	REG WORD		*ppoints;
{
	static	WORD	hztltbl[2] = { 0x5555, 0xaaaa };
	static  WORD	verttbl[4] = { 0x5555, 0xaaaa, 0xaaaa, 0x5555 };
	REG WORD		*linexy;
	REG WORD		st, i;

	for ( i = 1; i < ptscount; i++ )
	{
	  if ( *ppoints == *(ppoints + 2) )
	  {
	    st = verttbl[( (( *ppoints) & 1) | ((*(ppoints + 1) & 1 ) << 1))];
	  }	
	  else
	  {
	    linexy = ( *ppoints < *( ppoints + 2 )) ? ppoints : ppoints + 2;
	    st = hztltbl[( *(linexy + 1) & 1)];
	  }
	  vsl_udsty( st );
	  v_pline( 2, ppoints );
	  ppoints += 2;
	}
	vsl_udsty( 0xffff );
}	


WORD	str2intin(s)
REG	UBYTE *s;
{	
	REG WORD	i;
	REG WORD	*ip, *t;


	ip = (WORD *) ad_intin;

	if (bitstmap) {
		Debug7("Bitstream charset: "); Debug7(s); Debug7("\r\n");
		t = ATable;
		for (i = 0; *s; i++) {
			*ip++ = t[*s++];
		} 
	} else {
		Debug7("ATARI charset: "); Debug7(s); Debug7("\r\n");
		i = LBWMOV((BYTE *)ip, (BYTE *)s); 
	}
	return i;
}
