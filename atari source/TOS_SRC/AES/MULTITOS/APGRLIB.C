/*	APGRLIB.C	4/11/84 - 02/03/85	Gregg Morris		*/
/*	for 68k		03/06/85 - 03/09/85	Lowell Webster		*/
/*	Reg Opt		03/09/85		Derek Mui		*/
/*	Restore into C language	from 3.01	8/30/90	D.Mui		*/
/*	Changes to gr_gtext, gr_just for GDOS	5/25/93 H.M.Krober	*/
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

#include "pgem.h"
#include "pmisc.h"

EXTERN WORD	gl_width;
EXTERN WORD	gl_height;
EXTERN WORD	gl_hchar;
EXTERN WS	gl_ws;
EXTERN WORD	intin[];
EXTERN WORD	cu_hptschar;

VOID
gr_inside(pt, th)
REG	GRECT		*pt;
REG	WORD		th;
{
	pt->g_x += th;
	pt->g_y += th;
	pt->g_w -= ( 2 * th );
	pt->g_h -= ( 2 * th );
}


/************************************************************************/
/* g r _ r e c t							*/
/************************************************************************/
	VOID
gr_rect(icolor, ipattern, pt)
	UWORD		icolor;
	REG UWORD		ipattern;
	REG GRECT		*pt;
{
	REG WORD		fis;

	fis = FIS_PATTERN;
	if (ipattern == IP_HOLLOW)
	  fis = FIS_HOLLOW;
	else if (ipattern == IP_SOLID)
	  fis = FIS_SOLID;

	vsf_color(icolor);
	bb_fill(MD_REPLACE, fis, ipattern, 
	  	pt->g_x, pt->g_y, pt->g_w, pt->g_h);
}


/*
*	Routine to adjust the x,y starting point of a text string
*	to account for its justification.  The number of characters
*	in the string is also returned.
*/
	WORD
gr_just(just, ptext, w, h, pt)
	WORD		just;
	LONG		ptext;
	REG WORD	w, h;
	REG GRECT	*pt;
{
	WORD		numchs;
						/* figure out the	*/
						/*   width of the text	*/
						/*   string in pixels	*/
	gsx_tcalc(ptext, &pt->g_w, &pt->g_h, &numchs);

	h -= pt->g_h;
	if ( h > 0 )				/* check height		*/
	  pt->g_y += ((h + 1) / 2);

	w -= pt->g_w;
	if ( w > 0 )
	{
	  switch(just)
	  {
	    case TE_CNTR:			/* center text in	*/
						/*   rectangle		*/
		pt->g_x += (w + 1) / 2;
		break;	
	    case TE_RIGHT:			/* right justify	*/
		pt->g_x += w;
		break;
	  } /* switch */
	}

	return(numchs);
}


/*
*	Routine to draw a string of graphic text.
*/
	VOID
gr_gtext(just, ptext, pt, tmode)
	WORD		just;
	LONG		ptext;
	GRECT		*pt;
	WORD		tmode;
{
	WORD		dummy;
	WORD		numchs;
	GRECT		t;
						/* figure out where &	*/
						/*   how to put out	*/
	rc_copy((WORD *)pt, (WORD *)&t);
	numchs = gr_just(just, ptext, t.g_w, t.g_h, &t);
	if (numchs > 0)
	  gsx_tblt(t.g_x, t.g_y, numchs);

}



/*
*	Routine to crack out the border color, text color, inside pattern,
*	and inside color from a single color information word.
*/
	VOID
gr_crack(color, pbc, ptc, pip, pic, pmd)
	REG UWORD		color;
	WORD		*pbc, *ptc, *pic;
	REG WORD		*pip, *pmd;
{
						/* 4 bit encoded border	*/
						/*   color 		*/
	*pbc = (LHIBT(color) >> 4) & 0x0f;
						/* 4 bit encoded text	*/
						/*   color		*/
	*ptc = LHIBT(color) & 0x0f;
						/* 3 bit encoded pattern*/
	*pip = (LLOBT(color) >> 4) & 0x0f;
						/* 4th bit used to set	*/
						/*   text writing mode	*/
	if (*pip & 0x08)
	{
	  *pip &= 0x07;
	  *pmd = MD_REPLACE;
	}
	else
	  *pmd = MD_TRANS;
						/* 4 bit encoded inside	*/
						/*   color		*/
	*pic = LLOBT(color) & 0x0f;
}


/*
*	Routine to draw an icon, which is a graphic image with a text
*	string underneath it.
*/
	VOID
gr_gicon(state, pmask, pdata, ptext, ch, chx, chy, pi, pt)
	REG WORD		state;
	LONG		pmask;
	LONG		pdata;
	LONG		ptext;
	REG WORD		ch;
	WORD		chx, chy;
	REG GRECT		*pi;
	REG GRECT		*pt;
{
	REG WORD		fgcol, bgcol, tmp;
						/* crack the color/char	*/
						/*   definition word	*/
	fgcol = (ch >> 12) & 0x000f;
	bgcol = (ch >> 8) & 0x000f;
	ch &= 0x0ff;
						/* invert if selected	*/
	if (state & SELECTED)
	{
	  tmp = fgcol;	
	  fgcol = bgcol;
	  bgcol = tmp;
	}
						/* do mask unless its on*/
						/* a white background	*/
	if ( !( (state & WHITEBAK) && (bgcol == WHITE) ) )
	{
	  gsx_blt(pmask, 0, 0, pi->g_w/8, 0x0L, pi->g_x, pi->g_y, 
			gl_width/8, pi->g_w, pi->g_h, MD_TRANS,
			bgcol, fgcol); 
	  gr_rect(bgcol, IP_SOLID, pt);
	}
						/* draw the data	*/
	gsx_blt(pdata, 0, 0, pi->g_w/8, 0x0L, pi->g_x, pi->g_y, 
			gl_width/8, pi->g_w, pi->g_h, MD_TRANS,
			fgcol, bgcol); 
						/* draw the character	*/
	gsx_attr(TRUE, MD_TRANS, fgcol);
	if ( ch )
	{
	  intin[0] = ch;
    	  set_cufont(SMALL, 0, 0);
	  gsx_tblt(pi->g_x+chx, pi->g_y+chy, 1);
	}
						/* draw the label	*/
	set_cufont(SMALL, 0, 0);
	gr_gtext(TE_CNTR, ptext, pt, MD_TRANS);
}


/*
*	Routine to draw a box of a certain thickness using the current
*	attribute settings
*/
	VOID
gr_box(x, y, w, h, th)
	WORD		x, y, w, h;
	REG WORD	th;
{
	GRECT		t, n;

	r_set((WORD *)&t, x, y, w, h);
	if (th != 0)
	{
	  if (th < 0)
	    th--;
	  gsx_moff();
	  do
	  {
	    th += (th > 0) ? -1 : 1;
	    rc_copy((WORD *)&t, (WORD *)&n);
	    gr_inside(&n, th);
	    gsx_box(&n);
	  } while (th != 0);
	  gsx_mon();
	}
}
