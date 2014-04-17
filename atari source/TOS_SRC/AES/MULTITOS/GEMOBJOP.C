/*
*	GEMOBJOP.C
*
*	-------------------------------------------------------------
*	GEM Application Environment Services		  Version 1.0
*	TOS Atari operating system
*	Copyright (C) 1985	 Atari Corp. 	Digital Research Inc.
*	-------------------------------------------------------------
*	Updates:
*	rewrite		01/03/87		Mike Schmal
*		ob_sst	-general poor coding rewrite.
*		get_par -removed unused var.
*	remove obaddr	06/10/85		Mike Schmal
*	Reg Opt		03/08/85 - 03/09/85	Derek Mui
*	Change at ob_sst for extended type	7/7/92	Minna Lai
*	Remove extended type stuff	1/12/93 Eric Smith
*	02/16/93	cjg	Converted to Lattice C 5.51
*	02/23/93	cjg	Force the use of prototypes 
*/

/*	-----------------------------------------------------------
*	AES Version 4.0	MultiTOS version is written by Derek M. Mui
*	Copyright (C) 1992 
*	Atari (U.S.) Corp
*	All Rights Reserved
*	-----------------------------------------------------------
*/	
#include "pgem.h"
#include "pmisc.h"

#include "machine.h"
#include "objaddr.h"
#include "vdidefs.h"

#define	TED_THICKNESS	22

EXTERN	WS	gl_ws;

/*
* ob_sst	Routine to set the user variables pspec, pstate, ptype,
*		pflags, pt, pth.
*
*		returns object border/text color or the 3byte of the pointer
*		to a tedinfo structure (isn't this help full).
*/

	BYTE
ob_sst(tree, obj, pspec, pstate, ptype, pflags, pt, pth)
	LONG		tree;
	WORD		obj;
	REG LONG	*pspec;
	WORD		*pstate, *ptype;
	REG WORD	*pflags;
	GRECT		*pt;
	WORD		*pth;
{
	REG WORD	th;
	REG OBJECT	*tmp;

	tmp = ( OBJECT *)OB_NEXT(obj);

	pt->g_w = tmp->ob_width;	/* set user grect width */
	pt->g_h = tmp->ob_height;	/* set user grect height */
	*pflags = tmp->ob_flags;	/* set user flags variable */
	*pspec = tmp->ob_spec;		/* set user spec variable */
	*pstate = tmp->ob_state;	/* set user state variable */
	*ptype = tmp->ob_type & 0x00ff;	/* set user type variable */

					/* IF indirect then get pointer */
	if (*pflags & INDIRECT)	  *pspec = LLGET(tmp->ob_spec);


	th = 0;				/* border thickness */

	switch( *ptype )
	{
	  case G_TITLE:			/* menu title thickness = 1 */
		th = 1;
		break;

	  case G_TEXT:			/* for these items tedinfo thickness */
	  case G_BOXTEXT:
	  case G_FTEXT:
	  case G_FBOXTEXT:
		th = LWGET(*pspec+TED_THICKNESS);
		break;

	  case G_BOX:			/* for these use object thickness */
	  case G_BOXCHAR:
	  case G_IBOX:
		th = LBYTE2(((BYTE *)pspec));
		break;

	  case G_BUTTON:		/* for a button make thicker */
		th--;
		if ( *pflags & EXIT)	/* one thicker ( - (neg) is thicker) */
		  th--;
		if ( *pflags & DEFAULT)	/* still one more thick */
		  th--;
		break;
	}

	if (th > 128)	th -= 256;	/* clamp it */

	*pth = th;			/* set user variable */

					/* returns object border/text color */
					/* or the 3byte of the pointer to a */
					/* tedinfo structure (real helpfull)*/
	return(LBYTE3(((BYTE *)pspec)));
}


	VOID
everyobj(tree, this, last, routine, startx, starty, maxdep)
	REG LONG		tree;
	REG WORD		this, last;
	WORD		(*routine)( LONG, WORD, WORD, WORD );
	WORD		startx, starty;
	WORD		maxdep;
{
	REG WORD		tmp1;
	REG WORD		depth;
	WORD		x[8], y[8];

	x[0] = startx;
	y[0] = starty;
	depth = 1;
						/* non-recursive tree	*/
						/*   traversal		*/
child:
						/* see if we need to	*/
						/*   to stop		*/
	if ( this == last)
	  return;
						/* do this object	*/
	x[depth] = x[depth-1] + LWGET(OB_X(this));
	y[depth] = y[depth-1] + LWGET(OB_Y(this));
	(*routine)(tree, this, x[depth], y[depth]);
						/* if this guy has kids	*/
						/*   then do them	*/
	tmp1 = LWGET(OB_HEAD(this));

	if ( tmp1 != NIL )
	{
	  if ( !( LWGET(OB_FLAGS(this)) & HIDETREE ) && 
		( depth <= maxdep ) )
	  {
	    depth++;
	    this = tmp1;
	    goto child;
	  }
	}
sibling:
						/* if this is the root	*/
						/*   which has no parent*/
						/*   or it is the last	*/
						/*   then stop else... 	*/
	tmp1 = LWGET(OB_NEXT(this));
	if ( (tmp1 == last) ||
	     (this == ROOT) )	
	  return;
						/* if this obj. has a	*/
						/*   sibling that is not*/
						/*   his parent, then	*/
						/*   move to him and do	*/
						/*   him and his kids	*/
	if ( LWGET(OB_TAIL(tmp1)) != this )
	{
	  this = tmp1;
	  goto child;
	}
						/* else move up to the	*/
						/*   parent and finish	*/
						/*   off his siblings	*/ 
	depth--;
	this = tmp1;
	goto sibling;
}



/*
*	Routine that will find the parent of a given object.  The
*	idea is to walk to the end of our siblings and return
*	our parent.  If object is the root then return NIL as parent.
*/
	WORD
get_par(tree, obj)
	REG LONG		tree;
	REG WORD		obj;
{
	REG WORD		pobj;

	pobj = obj;

	if (obj == ROOT)
	   return(NIL);

	do {
		obj = pobj;
		pobj = LWGET(OB_NEXT(obj));
	} while ( (LWGET(OB_TAIL(pobj)) != obj) );

	return(pobj);
}

