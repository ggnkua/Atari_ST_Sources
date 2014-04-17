/*	GEMWRECT.C	01/25/84 - 02/05/85	Lee Jay Lorenzen	*/
/*	Reg Opt		03/09/85		Derek Mui		*/

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

#include <compiler.h>
#include <machine.h>
#include <pdstruct.h>
#include <obdefs.h>
#include <gemlib.h>

#define TOP 0
#define LEFT 1
#define RIGHT 2
#define BOTTOM 3
						/* in OPTIMIZE.C	*/
EXTERN WORD	min();
EXTERN WORD	max();
						/* in WMLIB.C		*/
EXTERN WORD	w_getsize();

EXTERN LONG	gl_wtree;
EXTERN WINDOW	*srchwp();
EXTERN THEGLO	D;

GLOBAL ORECT	*rul;
GLOBAL ORECT	gl_mkrect;


	ORECT
*get_orect()
{
	ORECT		*po;

	if ( po = rul )
	  rul = rul->o_link;
	else
	  fm_alert( 1, "[1][ No more orect! ][ OK ]" );

	return(po);
}


	ORECT
*mkpiece(tlrb, new, old)
	WORD		tlrb;
	REG ORECT		*new, *old;
{
	REG ORECT		*rl;

	rl = get_orect();
	rl->o_link = old;
						/* do common calcs	*/
	rl->o_x = old->o_x;
	rl->o_w = old->o_w;
	rl->o_y = max(old->o_y, new->o_y);
	rl->o_h = min(old->o_y + old->o_h, new->o_y + new->o_h) - rl->o_y;
						/* use/override calcs	*/
	switch(tlrb)
	{
	  case TOP:
		rl->o_y = old->o_y;
		rl->o_h = new->o_y - old->o_y;
	  	break;
	  case LEFT:
		rl->o_w = new->o_x - old->o_x;
	  	break;
	  case RIGHT:
		rl->o_x = new->o_x + new->o_w;
		rl->o_w = (old->o_x + old->o_w) - (new->o_x + new->o_w);
	  	break;
	  case BOTTOM:
		rl->o_y = new->o_y + new->o_h;
		rl->o_h = (old->o_y + old->o_h) - (new->o_y + new->o_h);
	  	break;
	}
	return(rl);
}


	ORECT
*brkrct(new, r, p)
	REG ORECT		*new, *r;
	REG ORECT		*p;
{
	REG WORD		i;
	WORD		have_piece[4];
						/* break up rectangle r	*/
						/*   based on new,	*/
						/*   adding new orects	*/
						/*   to list p		*/
	if ( (new->o_x < r->o_x + r->o_w) &&
	     (new->o_x + new->o_w > r->o_x) &&
	     (new->o_y < r->o_y + r->o_h) &&
	     (new->o_y + new->o_h > r->o_y) )
	{
						/* there was overlap	*/
						/*   so we need new	*/
						/*   rectangles		*/
	  have_piece[TOP] = ( new->o_y > r->o_y );
	  have_piece[LEFT] = ( new->o_x > r->o_x );
	  have_piece[RIGHT] = ( new->o_x + new->o_w < r->o_x + r->o_w );
	  have_piece[BOTTOM] = ( new->o_y + new->o_h < r->o_y + r->o_h );

	  for(i=0; i<4; i++)
	  {
	    if ( have_piece[i] )
	      p = (p->o_link = mkpiece(i, new, r));
	  }
						/* take out the old guy	*/
	  p->o_link = r->o_link;
	  r->o_link = rul;
	  rul = r;
	  return(p);
	}
	return(0x0);
}


	VOID
mkrect(tree, wh, junkx, junky)
	LONG		tree;
	WORD		wh;
	WORD		junkx, junky;
{
	REG WINDOW		*pwin;
	ORECT		*new;
	REG ORECT		*r, *p;

	pwin = srchwp( wh );
						/* get the new rect	*/
						/*   that is used for	*/
						/*   breaking other 	*/
						/*   this windows rects	*/
	new = &gl_mkrect;
						/* 			*/
	r = (p = &pwin->w_rlist)->o_link;
						/* redo rectangle list	*/
	while ( r )
	{
	  if ( p = brkrct(new, r, p) )
	  {
						/* we broke a rectangle	*/
						/*   which means this	*/
						/*   can't be blt	*/
	    pwin->w_flags |= VF_BROKEN;
	    r = p->o_link;
	  }
	  else
	    r = (p = r)->o_link;
	}
}



	VOID
newrect(tree, wh, junkx, junky)
	LONG		tree;
	WORD		wh;
	WORD		junkx, junky;
{
	REG WINDOW		*pwin;
	ORECT			*r0;
	REG ORECT		*new, *r;

	pwin = srchwp( wh );

	r0 = pwin->w_rlist;
						/* dump rectangle list	*/
	if ( r0 )
	{
	  for (r=r0; r->o_link; r=r->o_link);
	  r->o_link = rul;
	  rul = r0;
	}
						/* zero the rectangle	*/
						/*   list		*/
	pwin->w_rlist = 0x0;
						/* start out with no	*/
						/*   broken rectangles	*/
	pwin->w_flags &= ~VF_BROKEN;
						/* if no size then	*/
						/*   return		*/
	w_getsize(WS_TRUE, wh, &gl_mkrect.o_x);
	if ( !(gl_mkrect.o_w && gl_mkrect.o_h) )
	  return;
						/* init. a global orect	*/
						/*   for use during 	*/
						/*   mkrect calls	*/
	gl_mkrect.o_link = (ORECT *) 0x0;
						/* break other window's	*/
						/*   rects with our 	*/
						/*   current rect	*/
	everyobj(tree, ROOT, wh, mkrect, 0, 0, MAX_DEPTH);
						/* get an orect in this	*/
						/*   windows list 	*/
	new = get_orect();
	new->o_link  = (ORECT *) 0x0;
	w_getsize(WS_TRUE, wh, &new->o_x);
	pwin->w_rlist = new;
}
