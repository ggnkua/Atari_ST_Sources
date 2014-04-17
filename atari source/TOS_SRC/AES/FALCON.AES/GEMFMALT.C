/*
*************************************************************************
*			Revision Control System
* =======================================================================
*  $Revision: 2.2 $	$Source: /u2/MRS/osrevisions/aes/gemfmalt.c,v $
* =======================================================================
*  $Author: mui $	$Date: 89/04/26 18:22:40 $	$Locker: kbad $
* =======================================================================
*  $Log:	gemfmalt.c,v $
* Revision 2.2  89/04/26  18:22:40  mui
* TT
* 
* Revision 2.1  89/02/22  05:26:06  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.1  88/06/02  12:33:39  lozben
* Initial revision
* 
*************************************************************************
*/
/*	GEMFMALT.C		09/01/84 - 01/07/85	Lee Lorenzen	*/
/*	CHANGED			02/19/85 - 02/23/85	Derek Mui	*/
/*	Reg Opt			03/08/85		Derek Mui	*/
/*	1.1			03/21/85 - 05/11/85	Lowell Webster	*/
/*	Modify fm_build to handle 6 resolutions	2/6/86	Derek Mui	*/
/*	Change the mouse logic at fm_alert	3/5/86	Derek Mui	*/
/*	Fix at fm_strbrk	3/16/87	- 3/17/87	Derek Mui	*/
/*	Fix at fm_strbrk to allow 31 characters  4/8/87	Derek Mui	*/
/*	Fix at fm_alert		4/9/87			Derek Mui	*/
/*	Add more defines	11/23/87		D.Mui		*/
/*	New rsc update		12/9/87			D.Mui		*/
/*	Changed fm_build and fm_alert to build 3d buttons 7/16/92 D.Mui	*/

/*
*	-------------------------------------------------------------
*	GEM Application Environment Services		  Version 1.1
*	Serial No.  XXXX-0000-654321		  All Rights Reserved
*	Copyright (C) 1985			Digital Research Inc.
*	-------------------------------------------------------------
*/

#include <portab.h>
#include <machine.h>
#include <struct88.h>
#include <baspag88.h>
#include <obdefs.h>
#include <taddr.h>
#include <gemlib.h>
#include <gemusa.h>
#include <vdidefs.h>

#define LORES	320

#define MAX_MSGS     5
#define MAX_BTNS     3
#define MSG_OFF      2
#define BUT_OFF      7
#define NUM_ALOBJS   10
#define NUM_ALSTRS   8
#define MAX_MSGLEN   30	/* changed	*/
#define INTER_WSPACE 2
#define INTER_HSPACE 0

						/* in GSXIF.C		*/
EXTERN	VOID	bb_restore();
EXTERN	VOID	bb_save();
						/* in OBLIB.C		*/
EXTERN	WORD	ob_add();
EXTERN	VOID	ob_draw();
						/* in OBED.C		*/
EXTERN	VOID	ob_actxywh();
						/* in RSLIB.C		*/
EXTERN VOID	rs_obfix();

EXTERN GRECT	gl_rcenter;

EXTERN LONG	ad_sysglo;
EXTERN LONG	ad_armice;

GLOBAL BYTE	gl_nils[6] = {0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF};

EXTERN	WS	gl_ws;
EXTERN	UWORD	gl_alrtcol;
EXTERN	WORD	gl_hbox;
EXTERN	WORD	gl_hchar;
EXTERN WORD	gl_wchar;
EXTERN WORD	gl_width;
EXTERN WORD	gl_ncols;
EXTERN WORD	gl_moff;		/* CHANGED 5/10 LKW	*/


/*
*	Routine to break a string into smaller strings.  Breaks occur
*	whenever an | or a ] is encountered.
*/
	WORD
fm_strbrk(tree, palstr, stroff, pcurr_id, pnitem, pmaxlen)
	LONG		tree;
	LONG		palstr;
	WORD		stroff;
	WORD		*pcurr_id;
	WORD		*pnitem;
	WORD		*pmaxlen;
{
	REG WORD		nitem, curr_id;
	REG WORD		len, maxlen;
	REG BYTE		tmp;
	LONG			pstr;
	WORD			nxttmp;

	nitem = maxlen = 0; 
	curr_id = *pcurr_id;
	tmp = NULL;

	while( tmp != ']')
	{
	  pstr = LLGET(OB_SPEC(stroff + nitem));
	  len = 0;

	  do
	  {
	    tmp = LBGET(palstr + curr_id);

	    if ( len >= 31 )
	    {
	       LBSET(pstr + len, NULL);
	       tmp = NULL;
	       while( TRUE )
	       {
	         tmp = LBGET(palstr + curr_id);
 	         if ( ( tmp != ']' ) && ( tmp != '|' ) )
		 {
		   curr_id++;	
		   continue;
		 }
		 else
		   break;
	       }
	     }			    

	    curr_id++;
            nxttmp = LBGET(palstr + curr_id);

	    if ( (tmp == ']') || (tmp == '|') )
	    {
	      if (tmp == nxttmp)
	      {
		if ( len < 31 )
		  curr_id++;
		else
		  tmp = NULL;
	      }
	      else
	      {
		nxttmp = tmp;
		tmp = NULL;
	      }
	    }

	    LBSET(pstr + len, tmp);
	    len++;
	  } while( tmp != NULL );

	  tmp = nxttmp;	
	  maxlen = max(len - 1, maxlen);
	  nitem++;
	}
	*pcurr_id = curr_id;
	*pnitem = nitem;
	*pmaxlen = maxlen;
}


/*
*	Routine to parse a string into an icon #, multiple message
*	strings, and multiple button strings.  For example,
*
*		[0][This is some text|for the screen.][Ok|Cancel]
*		0123456
*
*	becomes:
*		icon# = 0;
*		1st msg line = This is some text
*		2nd msg line = for the screen.
*		1st button = Ok
*		2nd button = Cancel
*/

fm_parse(tree, palstr, picnum, pnummsg, plenmsg, pnumbut, plenbut)
	LONG		tree;
	REG LONG	palstr;
	WORD		*picnum;
	WORD		*pnummsg, *plenmsg;
	WORD		*pnumbut, *plenbut;
{
	WORD		curr_id;

	*picnum = LBGET(palstr + 1) - '0';
	curr_id = 4;
	fm_strbrk(tree, palstr, MSG_OFF, &curr_id, pnummsg, plenmsg);
	curr_id++;
	fm_strbrk(tree, palstr, BUT_OFF, &curr_id, pnumbut, plenbut);
	*plenbut += 1;
}

	VOID
fm_build(tree, haveicon, nummsg, mlenmsg, numbut, mlenbut)
	REG LONG	tree;
	WORD		haveicon;
	WORD		nummsg, mlenmsg;
	WORD		numbut, mlenbut;
{
	REG WORD	i,j;
	GRECT		al, ic;
	GRECT		bt, ms;
	WORD		icw,ich;

	icw = 4;
	ich = 4;
	/* 	define the icw and ich at here please	*/
	
	i = (mlenbut * numbut) + ( (numbut-1) * 2 );
	i = max( i, mlenmsg );   	/* find the max char length	*/
				 	/* find the max char height	*/
	j = max( nummsg, 1 );
	r_set(&al, 0x0L, i+2, j);	/* this is the alert box 	*/
					/* this is the message object   */
	r_set(&ms, 2, 0x0300, mlenmsg, 1);

	if (haveicon)
	{
	  r_set(&ic, 1, 1, icw, ich);
	  al.g_w += icw + 1;
	  al.g_h = max( al.g_h, 1 + ich );		
	  ms.g_x += icw;
	}

	al.g_h += 3;		

	/* center the buttons */

	i = (al.g_w -  ( (numbut - 1) * 2 ) - (mlenbut * numbut)) / 2;

	/* set the button	*/

	r_set( &bt, i, al.g_h - 2, mlenbut, 1 ); 

	/* now make the al.g_h smaller	*/

/*	al.g_h -= 1;
	al.g_h += ( (gl_hchar/2) << 8 );
*/

	ob_setxywh(tree, ROOT, &al);

	for(i=0; i<NUM_ALOBJS; i++)
	  LBCOPY(OB_NEXT(i), &gl_nils[0], 6);

						/* add icon object	*/
	if (haveicon)
	{
	  ob_setxywh(tree, 1, &ic);
	  ob_add(tree, ROOT, 1);
	}
						/* add msg objects	*/
	for(i=0; i<nummsg; i++)
	{
	  ob_setxywh(tree, MSG_OFF+i, &ms);
	  ms.g_y += 1;
	  ob_add(tree, ROOT, MSG_OFF+i);
	}
					
	/* add button objects	*/

	for(i=0; i<numbut; i++)
	{
	  LWSET(OB_FLAGS(BUT_OFF+i), SELECTABLE | EXIT | IS3DOBJ | IS3DACT );
	  LWSET(OB_STATE(BUT_OFF+i), NORMAL);
	  ob_setxywh(tree, BUT_OFF+i, &bt);
	  bt.g_x += mlenbut + 2 ;
	  ob_add(tree, ROOT, BUT_OFF+i);
	}
						/* set last object flag	*/
	LWSET(OB_FLAGS(BUT_OFF+numbut-1), SELECTABLE | EXIT | LASTOB | IS3DOBJ | IS3DACT );
}


	WORD
fm_alert(defbut, palstr)
	WORD		defbut;
	LONG		palstr;
{
	REG WORD	i;
	REG LONG	tree;
	WORD		inm, nummsg, mlenmsg, numbut, mlenbut;
	LONG		plong,addr;
	GRECT		d, t;
	WORD		ratalert;		/* CHANGED 5/10 LKW	*/
	WORD		x,y;		/* save the button height */
	WORD		x1,y1,w,h;
	UWORD		color;
	LONG		spec;
					/* 7/16/92		  */

						/* init tree pointer	*/
	rs_gaddr(ad_sysglo, R_TREE, ALERT, &addr);
	tree = addr;

	spec = LLGET( OB_SPEC(ROOT) );
	spec &= 0xFFFFFF80L;
	spec |= 0x70L;		/* 70 means "solid" (was 0x40L, "dithered") */

	if ( gl_alrtcol >= gl_ws.ws_ncolors )
	  color = WHITE;
	else
	  color = gl_alrtcol;
 
	spec |= ( color & 0x000F );
 	LLSET( OB_SPEC(ROOT), spec ); 

	LWSET( OB_TYPE( 1 ), G_IMAGE );
	rs_gaddr( ad_sysglo, R_BIPDATA, NOTEBB, &plong );
	LLSET( OB_SPEC( 1 ), plong );	


	LWSET(OB_STATE(ROOT), OUTLINED);
	fm_parse(tree, palstr, &inm, &nummsg, &mlenmsg, &numbut, &mlenbut);
	fm_build(tree, (inm != 0), nummsg, mlenmsg, numbut, mlenbut);

	if (defbut)
	{
	  plong = OB_FLAGS(BUT_OFF + defbut - 1);
	  LWSET(plong, LWGET(plong) | DEFAULT);
	}

	if (inm != 0)
	{
	  rs_gaddr(ad_sysglo, R_BITBLK, inm-1, &plong);
	  LLSET(OB_SPEC(1), plong);
	}
						/* convert to pixels	*/
	for(i=0; i<NUM_ALOBJS; i++)
	  rs_obfix(tree, i);

	/* LWSET(OB_WIDTH(1), 32);	*/
	/* LWSET(OB_HEIGHT(1), 32);	*/

	LLSET( OB_WIDTH(1), 0x00200020L );

	/* fixed 7/16/92	*/

	for( i=0; i<3; i++ )
	  LWSET( OB_HEIGHT(BUT_OFF+i), gl_hbox );

	/* recalculate the box height	*/
  	
	if ( !defbut )
	  defbut = 1;

	ob_gclip( tree, BUT_OFF + defbut - 1, &x1, &y1, &x, &y, &w, &h );
	y = y - LWGET( OB_Y(0) );
	y += h + 2;
	LWSET(OB_HEIGHT(0), y );
						/* center tree on screen*/
	ob_center(tree, &d);
						/* save screen under-	*/
						/*   neath the alert	*/
	wm_update(TRUE);
	gsx_gclip(&t);
	bb_save(&d);

						/* draw the alert	*/
	gsx_sclip(&d);
	ob_draw(tree, ROOT, MAX_DEPTH);
	ctlmouse( TRUE );			/* turn on the mouse	*/
						/* let user pick button	*/
	i = fm_do(tree, 0) & 0x7FFF;

	ctlmouse ( FALSE );			/* back to the way it was */

						/* restore saved screen	*/
	gsx_sclip(&d);
	bb_restore(&d);
	gsx_sclip(&t);
	wm_update(FALSE);


						/*	3/3/86		*/
#if UNLINKED
	if (ratalert)				/* CHANGED 5/10 LKW	*/
	  gsx_moff();				/* CHANGED 5/10 LKW	*/
#endif
						/* return selection	*/
	return( i - BUT_OFF + 1 );
}
