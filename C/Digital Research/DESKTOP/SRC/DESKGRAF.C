/*	DESKGRAF.C	04/11/84 - 03/17/85	Lee Lorenzen		*/
/*	merge source	5/27/87			mdf			*/

/*
*       Copyright 1999, Caldera Thin Clients, Inc.                      
*       This software is licenced under the GNU Public License.         
*       Please see LICENSE.TXT for further information.                 
*                                                                       
*                  Historical Copyright                                 
*	-------------------------------------------------------------
*	GEM Application Environment Services		  Version 2.3
*	Serial No.  XXXX-0000-654321		  All Rights Reserved
*	Copyright (C) 1985			Digital Research Inc.
*	-------------------------------------------------------------
*/

#include <rclib.h>
#include <portab.h>
#include <machine.h>
#if GEMDOS
#if TURBO_C
#include <vdi.h>
#include <aes.h>
#endif
#else
#include <obdefs.h>
#endif
#include "deskapp.h"
#include "deskfpd.h"
#include "deskwin.h"
#include "deskbind.h"
#include "deskgraf.h"

#define ORGADDR 0x0L

GLOBAL WORD	gl_width;
GLOBAL WORD	gl_height;

GLOBAL WORD	gl_nrows;
GLOBAL WORD	gl_ncols;

GLOBAL WORD	gl_wchar;
GLOBAL WORD	gl_hchar;

GLOBAL WORD	gl_wschar;
GLOBAL WORD	gl_hschar;

GLOBAL WORD	gl_wptschar;
GLOBAL WORD	gl_hptschar;

GLOBAL WORD	gl_wbox;
GLOBAL WORD	gl_hbox;

GLOBAL WORD	gl_xclip;
GLOBAL WORD	gl_yclip;
GLOBAL WORD	gl_wclip;
GLOBAL WORD	gl_hclip;

GLOBAL WORD gl_nplanes;
GLOBAL WORD gl_handle;

GLOBAL MFDB	gl_src;
GLOBAL MFDB	gl_dst;

GLOBAL WORD	contrl[12];
GLOBAL WORD	intin[128];
GLOBAL WORD	ptsin[20];
GLOBAL WORD	intout[10];
GLOBAL WORD	ptsout[10];
GLOBAL WORD	gl_ws[58];

GLOBAL LONG	ad_intin;

GLOBAL WORD	gl_mode;
GLOBAL WORD	gl_mask;
GLOBAL WORD	gl_tcolor;
GLOBAL WORD	gl_lcolor;
GLOBAL WORD	gl_fis;
GLOBAL WORD	gl_patt;
GLOBAL WORD	gl_font;

GLOBAL GRECT	gl_rscreen;
GLOBAL GRECT	gl_rfull;
GLOBAL GRECT	gl_rzero;
GLOBAL GRECT	gl_rcenter;
GLOBAL GRECT	gl_rmenu;

/*
*	Routine to set the clip rectangle.  If the w,h of the clip
*	is 0, then no clip should be set.  Ohterwise, set the 
*	appropriate clip.
*/
WORD gsx_sclip(GRECT *pt)
{
	rc_get(pt, &gl_xclip, &gl_yclip, &gl_wclip, &gl_hclip);

	if ( gl_wclip && gl_hclip )
	{
		ptsin[0] = gl_xclip;
		ptsin[1] = gl_yclip;
		ptsin[2] = gl_xclip + gl_wclip - 1;
		ptsin[3] = gl_yclip + gl_hclip - 1;
		vs_clip( gl_handle, TRUE, &ptsin[0]);
	}
	else
		vs_clip( gl_handle, FALSE, &ptsin[0]);
	return( TRUE );
}

/* Routine to get the current clip setting */
VOID gsx_gclip(GRECT *pt)
{
	rc_set(pt, gl_xclip, gl_yclip, gl_wclip, gl_hclip);
}

VOID gsx_xline(WORD ptscount, WORD *ppoints)
{
	static	WORD	hztltbl[2] = { 0x5555, 0xaaaa };
	static  WORD	verttbl[4] = { 0x5555, 0xaaaa, 0xaaaa, 0x5555 };
	WORD	*linexy,i;
	WORD	st;

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
		vsl_udsty( gl_handle, st );
		v_pline( gl_handle, 2, ppoints );
		ppoints += 2;
	}
	vsl_udsty( gl_handle, 0xffff );
}	

/*
*	Routine to draw a certain number of points in a polyline
*	relative to a given x,y offset.
*/
VOID gsx_pline(WORD offx, WORD offy, WORD cnt, WORD *pts)
{
	WORD	i, j;

	for (i=0; i<cnt; i++)
	{
		j = i * 2;
		ptsin[j] = offx + pts[j];
		ptsin[j+1] = offy + pts[j+1];
	}
	gsx_xline( cnt, &ptsin[0]);
}

/* Routine to set the text, writing mode, and color attributes. */
VOID gsx_attr(UWORD text, UWORD mode, UWORD color)
{
	if (mode != gl_mode)
	{
		vswr_mode( gl_handle, mode );
		gl_mode = mode;
	}
	if (text)
	{
		if (color != gl_tcolor)
		{
			vst_color( gl_handle, color );
			gl_tcolor = color;
		}
	}	
	else
	{
		if (color != gl_lcolor)
		{
			vsl_color( gl_handle, color);
			gl_lcolor = color;
		}
	}
}

/* Routine to fix up the MFDB of a particular raster form */
VOID gsx_fix(MFDB *pfd, LONG theaddr, WORD wb, WORD h)
{
	if (theaddr == ORGADDR)
	{
		pfd->fd_w = gl_ws[0] + 1;
		pfd->fd_wdwidth = pfd->fd_w / 16;
		pfd->fd_h = gl_ws[1] + 1;
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
	pfd->fd_addr = (void FAR *)theaddr;
}

/* Routine to blit, to and from a specific area */
VOID gsx_blt(LONG saddr, UWORD sx, UWORD sy, UWORD swb, LONG daddr,
	UWORD dx, UWORD dy, UWORD dwb, UWORD w, UWORD h, UWORD rule,
	WORD fgcolor, WORD bgcolor)
{
	WORD cols[2];

	gsx_fix(&gl_src, saddr, swb, h);
	gsx_fix(&gl_dst, daddr, dwb, h);

	graf_mouse(M_OFF, NULL);
	ptsin[0] = sx;
	ptsin[1] = sy;
	ptsin[2] = sx + w - 1;
	ptsin[3] = sy + h - 1;
	ptsin[4] = dx;
	ptsin[5] = dy;
	ptsin[6] = dx + w - 1;
	ptsin[7] = dy + h - 1 ;
	if (fgcolor == -1)
		vro_cpyfm( gl_handle, rule, &ptsin[0], &gl_src, &gl_dst);
	else
	{
		cols[0] = fgcolor;
		cols[1] = bgcolor;
		vrt_cpyfm( gl_handle, rule, &ptsin[0], &gl_src, &gl_dst, cols);
	}
	graf_mouse(M_ON, NULL);
}

/* Routine to blit around something on the screen */
VOID bb_screen(WORD scrule, WORD scsx, WORD scsy, WORD scdx, WORD scdy, WORD scw, WORD sch)
{
	gsx_blt(0x0L, scsx, scsy, 0, 
		0x0L, scdx, scdy, 0,
		scw, sch, scrule, -1, -1);
}

/* Routine to transform a standard form to device specific form. */
VOID gsx_trans(LONG saddr, UWORD swb, LONG daddr, UWORD dwb, UWORD h)
{
	gsx_fix(&gl_src, saddr, swb, h);
	gl_src.fd_stand = TRUE;
	gl_src.fd_nplanes = 1;

	gsx_fix(&gl_dst, daddr, dwb, h);
	vr_trnfm( gl_handle, &gl_src, &gl_dst );
}

/*
*	Routine to initialize all the global variables dealing
*	with a particular workstation open
*/
VOID gsx_start(VOID)
{
	WORD	char_height, nc;

	gl_xclip = 0;
	gl_yclip = 0;
	gl_width = gl_wclip = gl_ws[0] + 1;
	gl_height = gl_hclip = gl_ws[1] + 1;

	nc = gl_ws[39];
	gl_nplanes = 0;
	while (nc != 1)
	{
		nc >>= 1;
		gl_nplanes++;
	}
	char_height = gl_ws[46];
	vst_height( gl_handle, char_height, &gl_wptschar, &gl_hptschar, 
		&gl_wschar, &gl_hschar );
	char_height = gl_ws[48];
	vst_height( gl_handle, char_height, &gl_wptschar, &gl_hptschar, 
		&gl_wchar, &gl_hchar );
	gl_ncols = gl_width / gl_wchar;
	gl_nrows = gl_height / gl_hchar;
	gl_hbox = gl_hchar + 3;
	gl_wbox = (gl_hbox * gl_ws[4]) / gl_ws[3];
	vsl_type( gl_handle, 7 );
	vsl_width( gl_handle, 1 );
	vsl_udsty( gl_handle, 0xffff );
	rc_set(&gl_rscreen, 0, 0, gl_width, gl_height);
	rc_set(&gl_rfull, 0, gl_hbox, gl_width, (gl_height - gl_hbox));
	rc_set(&gl_rzero, 0, 0, 0, 0);
	rc_set(&gl_rcenter, (gl_width-gl_wbox)/2, (gl_height-(2*gl_hbox))/2, 
		gl_wbox, gl_hbox);
	rc_set(&gl_rmenu, 0, 0, gl_width, gl_hbox);
	ad_intin = (LONG)ADDR(&intin[0]);
}

VOID gsx_tblt(WORD tb_f, WORD x, WORD y, BYTE *tb_s)
{
	WORD	pts_height;

	if (tb_f == IBM)
	{
		if (tb_f != gl_font)
		{
			pts_height = gl_ws[48];
			vst_height( gl_handle, pts_height, &gl_wptschar, &gl_hptschar, 
				&gl_wchar, &gl_hchar );
			gl_font = tb_f;
		}
		y += gl_hptschar;
	}
	v_gtext( gl_handle, x, y, tb_s );
}

/* Routine to do a filled bit blit, (a rectangle). */
VOID bb_fill(WORD mode, WORD fis, WORD patt, WORD hx, WORD hy, WORD hw, WORD hh)
{
	gsx_fix(&gl_dst, 0x0L, 0, 0);
	ptsin[0] = hx;
	ptsin[1] = hy;
	ptsin[2] = hx + hw - 1;
	ptsin[3] = hy + hh - 1;

	gsx_attr(TRUE, mode, gl_tcolor);
	if (fis != gl_fis)
	{
		vsf_interior( gl_handle, fis);
		gl_fis = fis;
	}
	if (patt != gl_patt)
	{
		vsf_style( gl_handle, patt );
		gl_patt = patt;
	}
	/*vr_recfl( &ptsin[0], &gl_dst );*/
	vr_recfl( gl_handle, &ptsin[0] );
}

VOID gsx_vopen(VOID)
{
	WORD	i;

	for(i=0; i<10; i++)
		intin[i] = 1;
	intin[10] = 2;	/* device coordinate space */
	v_opnvwk( intin, &gl_handle, gl_ws );
}
