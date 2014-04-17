/*	GEMWMLIB.C	WINDOWS.C -	The Window Manager	*/
/*	Oct 29 1990	ml.	Created this.			*/
/* 	Feb 14 1991	ml.	Really started working on this.	*/
/*	Sep 20, 1991	Derek Mui	folded in changes	*/
/*	In wm_get, when the window is not opened, returns zero	*/
/*	rectangles list			1/14/92		D.Mui	*/
/*	Fix dos_free at mm_free		2/26/92		D.Mui	*/ 
/*	All the ttxt and itxt will use window's own buffer	*/
/*	2/2/8/92					D.Mui	*/
/*	Fix the problem if there is no h or v compoments but 	*/
/*	only sizer				3/2/92	M.Lai	*/
/*	Fix pointers when moving the window structure 3/2/92 M.L*/
/*	Add phantom window 			 3/9/92	D.Mui	*/
/*	Clear the type field when creating a window	6/6/92	*/
/*	Implemented wf_bottom in wm_set and wm_get	6/13/92	*/
/*					Minna Lai		*/
/*	Fixed at wm_set for sizing the window from large to 	*/
/*	small - No redraw message	Minna Lai	6/22/92	*/
/*								*/
/*	Changed w_bld to take a parameter to specify 3D		*/
/*	activator			Eric Smith	1/13/93	*/
/*								*/
/*	Converted to Lattice C 5.51	Cary Gee       02/12/93 */
/*	Force the use of prototypes	Cary Gee       02/22/93 */
/*								*/
/*	Add iconfy features to wmset/wmget H.M.Krober  05/04/93 */ 
/*								*/
/*	Added ToolBar features to window. C.Gee     05/26/93    */
/*								*/
/*	Changed wm_min() to:		  C.Gee	    06/01/93	*/
/*          1) initialize W1...W3/H1...H3 to 0.    		*/
/*          2) input a WINDOW ptr instead of KIND  		*/
/*	    3) Increment for INFO is a gl_hbox instead of yinc  */
/*								*/
/*	Added WF_FTOOLBAR and WF_NTOOLBAR to get the rect list  */
/*	for the TOOLBAR area.		  C.Gee     06/01/93    */
/*								*/
/*	Fixed bug with slider pos. in wind_set(WF_UNICONIFY,..	*/
/*					H. Krober   07/15/93	*/
/*								*/
/*	Add support for icon tiling	H. Krober   07/19/93    */
/*								*/
/*	MultiTOS window library is written by Minna Lai		
*	-----------------------------------------------------------
*	AES Version 4.0	MultiTOS version is written by Derek M. Mui
*	Copyright (C) 1992 
*	Atari (U.S.) Corp
*	All Rights Reserved
*	-----------------------------------------------------------
*/	
#include "pgem.h"
#include "pmisc.h"

#include "machine.h"
#include "dispvars.h"
#include "message.h"
#include "windlib.h"
#include "mintbind.h"
#include "gemusa.h"



/* whether window objects are 3D or not */
#define NO3D	0
#define IS3D	1


EXTERN	USERBLK	*aesDDD;
EXTERN	WORD	gl_mnpid;
EXTERN	WORD	aesid;
EXTERN	GRECT	gl_rzero;
EXTERN	PD	*currpd;
EXTERN	WORD	gl_kbid;
EXTERN	OBJECT	*ad_stdesk;
EXTERN	PD      *gl_mowner;
EXTERN	LONG    gl_mntree;
EXTERN	PD	*shellpd, *scr_pd;
EXTERN	WORD	gl_multi;

EXTERN WORD	gl_handle;
EXTERN WORD	gl_wchar, gl_hchar;	/* char size in pixels */
EXTERN WORD	gl_wbox, gl_hbox;	/* char box size in pixels */
EXTERN WORD	gl_width, gl_height;
EXTERN GRECT	gl_rfull;
EXTERN GRECT	gl_rscreen;
EXTERN GRECT	gl_offscreen;
EXTERN WORD	gl_nplanes;

EXTERN BYTE	*icnslots;		/* for icon slot management	*/
EXTERN BYTE	currIcnmax;		/* see gemctrl.c		*/


WORD	deskwind;		/* Background 0 window handle	*/
WORD	phanwind;		/* phantom window handle	*/

WORD	hparts, vparts;		/* window elements masks	*/
WORD	wtcolor[MAXOBJ];	/* topped window object colors	*/
WORD	wbcolor[MAXOBJ];	/* background window object colors */
OBJECT	*gl_newdesk;		/* address of new DESKTOP	*/
WORD	gl_newroot;		/* root object of new DESKTOP	*/
WINDOW	*hashtbl[NUMWIN];	/* window structures hash table */
WORD	hhead;			/* ascending handle # linked list */
WORD	gl_topw, botw;		/* top and bottom window handles */
MEMHDR	*wmhead, *wmtail;	/* window memory linked list	*/
MEMHDR	*rmhead, *rmtail;	/* rect lists memory linked list */

GLOBAL	WORD	gl_newid;	/* process id that owns the background	*/
GLOBAL	OBJECT	*gl_wtree;	/* points to default window background	*/
GLOBAL	OBJECT	w_tree;		/* default window background structure	*/

/*
 * Search for the window structure that corresponds to the
 * given handle.
 *
 *    Returns a pointer to the window structure of the given
 * handle, or NULLPTR if the window structure is not found.
 *
 */

	WINDOW
*srchwp( handle )
	WORD handle;
{
	WINDOW		*wp;		/* pointer to window structure */
	WORD		bucket;		/* bucket number in hash table */

	wp = ( WINDOW *)NULLPTR;	/* assume no window structure */

	/* look for window structure only if handle is valid */

	if ( handle >= 0 ) 
	{
	  bucket = handle % NUMWIN;
	  for(wp = hashtbl[bucket]; 
	    ( wp != ( WINDOW *)NULLPTR ) && ( wp->handle != handle ); 
	    wp = wp->wnext )
	    ;
    	}

	return( wp );
}


/*	Change the menu bar	*/

	VOID
setmenu( p )
	PD	*p;
{
	if (!gl_multi && !gl_mnpid)
		return;
	if ( ( p->p_mnaddr ) && ( p->p_pid != gl_mnpid ) ) 
	{
	  Debug1( "Setmenu\r\n" );

	  /* if 0x100 is set, mn_bar wants a process id */
	  mn_bar( ( LONG )p->p_pid, TRUE|0x0100 );
	}
	else
	{
	  if ( !p->p_mnaddr )
	    Debug1( "Setmenu has no menu bar address\r\n" );  

	  if ( p->p_pid == gl_mnpid )
	    Debug1( "Setmenu menu id is same\r\n" );
	}
}


/*	Readjust all the sliders position	*/ 

	VOID
w_setslide( wp, field )
	WINDOW		*wp;
	WORD		field;
{
	LONG		blen;
	UWORD		sz;

	if (field == WF_HSLIDE || field == WF_HSLSIZE) 
	{
	  blen = (LONG)wp->obj[W_HSLIDE].ob_width;
	  if ( wp->hslsz == -1 || (sz = ( UWORD )( (blen * (LONG)wp->hslsz) / 1000L )) < gl_wbox) 
	    sz = gl_wbox;

	  if ( sz > ( ADJ3DPIX << 1 ) ) 
	    wp->obj[W_HELEV].ob_width = sz - (ADJ3DPIX << 1);

	  wp->obj[W_HELEV].ob_x = ( WORD )(((blen - (LONG)sz) * (LONG)wp->hslpos / 1000L) + (LONG)ADJ3DPIX );
	} 
	else	/* field == WF_VSLIDE || field == WF_VSLSIZE */ 
	{	
	  blen = (LONG)wp->obj[W_VSLIDE].ob_height;
	  if ( wp->vslsz == -1 ||
	       (sz = ( UWORD )( (blen * (LONG)wp->vslsz) / 1000L )) < gl_hbox) 
	    sz = gl_hbox;

	  if ( sz > ( ADJ3DPIX << 1 ) )
	    wp->obj[W_VELEV].ob_height = sz - (ADJ3DPIX << 1);

	  wp->obj[W_VELEV].ob_y = ( WORD )( ((blen - (LONG)sz) * (LONG)wp->vslpos / 1000L) + (LONG)ADJ3DPIX );
	}
}
	


        VOID
w_nilit(num, olist)
        REG WORD                num;
        REG OBJECT              olist[];
{
        while( num-- )
        {
          olist[num].ob_next = olist[num].ob_head = olist[num].ob_tail = NIL;
        }
}


/*	Set the background window stuff
 *	Returns TRUE when background change
 *	otherwise FALSE
 *
 */

	WORD
set_desk( p )
	PD	*p;
{
	WORD	ret;

	if ((p->p_newdesk == ( BYTE *)gl_wtree) && shellpd)	/* Default background 	*/
	  p = gl_multi ? shellpd : scr_pd;				/* Use the shell's	*/

	ret = ( gl_newid != p->p_pid ) ? TRUE : FALSE;

	srchwp( deskwind )->owner = p;
	gl_newid = p->p_pid;
	gl_newdesk = ( OBJECT *)p->p_newdesk;
	gl_newroot = p->p_newroot;
	return( ret );
}


/*	Close all the windows that belong to this process	*/

	VOID
wm_clspd( p, message )
	PD	*p;
	WORD	message;
{
	WORD		i;
	REG WINDOW	*win;

	for ( i = 0; i < NUMWIN; i++ )
	{
w1:	    if ( win = hashtbl[i] )
	    {
	      while( win )
	      {
	        if ( ( win->owner == p ) && ( win->handle != deskwind ) )
	        {
		  if ( message )
		  {
	            if ( win->status.opened ) 
		      ap_sendmsg( WM_CLOSE, p->p_pid, win->handle, 0, 0, 0, 0 );

		    goto w2;
		  }

	          wmdelete( win->handle );
		  goto w1;
	        }
	        else
w2:		  win = win->wnext;
	      }
	    }
	}
}


/*	Get the top window structure	*/

	WINDOW
*wm_top()
{
	WORD	x[4];
	WORD	y[4];

	wm_get( 0, WF_TOP, x, y );
	return( srchwp( x[0] ) );
}


/*
 * Wm_init() -	initializes window colors, then start up the window
 *		manager.
 *	     -	this is called by geminit; only at boot time; so that
 *		window color defaults don't get munched when apps are
 *		launched; etc.
 */
	WORD
wm_init()
{
    REG	WORD	i;	/* counter */
    WORD numcolors;

    numcolors = (gl_nplanes < 4) ? 2 : 16;

    for (i = 0; i < MAXOBJ; i++) {
    	if (numcolors < 16)
		wtcolor[i] = wbcolor[i] = 0x1101;
	else {
		wtcolor[i] = 0x9178;
		wbcolor[i] = 0x9078;
	}
    }

    if (numcolors < 16) {
	wtcolor[W_NAME] |= 0xa0;
	wtcolor[W_VSLIDE] = wtcolor[W_HSLIDE] |= 0x10;
	wbcolor[W_VSLIDE] = wbcolor[W_HSLIDE] |= 0x10;
    } else {
	wtcolor[W_INFO] = 0x9948;
	wtcolor[W_HSLIDE] = wtcolor[W_VSLIDE] = 0x9179;
	wbcolor[W_HSLIDE] = wbcolor[W_VSLIDE] = 0x9079;
	wtcolor[W_VBAR] = wbcolor[W_VBAR] = 0x8068;
	wtcolor[W_HBAR] = wbcolor[W_HBAR] = 0x8068;
    }

    return( wm_start() );
}


/*
 * Wm_start() - initializes internal variables and data structures
 *		of the window manager.
 *	      - returns TRUE (1) if successful, and FALSE (0) if not.
 */
	WORD
wm_start()
{
    REG WINDOW  *wp;	/* pointer to window structure */
    REG RLIST   *rp;	/* pointer to RLIST structure */
    REG WORD	i;	/* counter */
    GRECT	desksiz;
    WORD	whandles[8];
		
    /* Allocate memory for memory header and window structures */
    if ((wmhead = (MEMHDR *)
	    dos_xalloc((LONG)(NUMWIN*sizeof(WINDOW)+sizeof(MEMHDR)), 3 )) 
			== ( MEMHDR *)NULLPTR )
    {
	bailout( "Fail to do wm_start\r\n" );
	return FALSE; 
    }
    else
      bfill( (NUMWIN*sizeof(WINDOW)+sizeof(MEMHDR)), 0, ( BYTE *)wmhead );

    wmtail = wmhead;		    /* init WINDOW memory linked list */
    wmhead->mnext = ( MEMHDR *)NULLPTR;	    /* there is no next memory block */
    wmhead->numused = 0;	    /* no slot is used yet */

    /* init window structures and hash table entries */
    for (wp = (WINDOW *)(wmhead+1), i = 0;
	 i < NUMWIN;
	 i++, wp++) {
	wp->status.used = FALSE;    /* window structure is available */
	wp->wwhere = wmhead;	    /* remember where it resides in */
	hashtbl[i] = ( WINDOW *)NULLPTR;	    /* initialize hash table entries */
    }

    gl_topw = botw = NIL;	    	    /* no opened window yet */
    hhead = NIL;		    /* init ascending handle # linked list */

    /* Allocate memory for memory header and rectangle lists */
    if ((rmhead = (MEMHDR *)
	    dos_xalloc((LONG)(NUMRECT*sizeof(RLIST)+sizeof(MEMHDR)), 3 )) 
		       == ( MEMHDR *)NULLPTR )
    {
	bailout( "Fail to do rectangle list\r\n" );
	return FALSE; 
    }
    else
      bfill( (NUMRECT*sizeof(RLIST)+sizeof(MEMHDR)), 0, ( BYTE *)rmhead );

    rmtail = rmhead;		    /* init RLIST memory linked list */
    rmhead->mnext = ( MEMHDR *)NULLPTR;	    /* there is no next memory block */
    rmhead->numused = 0;	    /* no slot is used yet */

    /* init RLIST structures as available */
    for (rp = (RLIST *)(rmhead+1), i = 0; i < NUMRECT; i++, rp++) {
	rp->rstatus.rused = FALSE;
	rp->rwhere = rmhead;
    }

    gl_newdesk = ( OBJECT *)NULLPTR;		    /* no new DESKTOP */
    gl_newroot = ROOT;

    desksiz.g_x = -1;
    desksiz.g_y = gl_hbox - 1;
    desksiz.g_w = gl_rfull.g_w + 2;
    desksiz.g_h = gl_rfull.g_h + 2;

    /* create the default window background */
	
    w_tree = *ad_stdesk;	
    w_tree.ob_head = w_tree.ob_tail = w_tree.ob_next = NIL;
    rc_copy( ( WORD *)&gl_rfull, ( WORD *)&w_tree.ob_x );

    gl_wtree = &w_tree;			/* default window background	*/

    /* create DESKTOP window for now */

    deskwind = wm_create(0, &desksiz);

   /* Fake the full x y w and h for deskwind */
    wp = srchwp( deskwind );
    r_set( ( WORD *)&wp->full, 0, gl_hbox, gl_rfull.g_w, gl_rfull.g_h );

    wmopen(deskwind, &desksiz);
    /* create a phantom window	*/

    if (!gl_multi) {
	/* The HACK of the year!
	 * To make MultiTOS more compatible in single tasking mode
	 * we create 7 (# of possible windows in old TOS) dummy windows.
	 * Now the phantom window (which didn't exist in old TOS) will
	 * get handle number 8. That way, programs like Calamus will still
	 * work. Without this hack they wouldn't becuase they assume that
	 * they will always get window handle 1 for their first created window.
	 * After creating the phantom window, we are deleting these dummy
	 * windows again. (04/22/93 hmk)
	 */
	for (i = 0; i < 7; i++) 
		whandles[i] = wm_create(0, &desksiz);
    }
		
    phanwind = wm_create( 0, &desksiz);	/* create phantom window */

    if (!gl_multi) {
	/*
	 *	Deleting dummy windows.
	 *	See few lines above for descr.
	 */
	for (i = 0; i < 7; i++)
		wm_delete(whandles[i]);
    }

   /* Fake the full x y w and h for deskwind */
    wp = srchwp( phanwind );
    r_set( ( WORD *)&wp->full, 0, gl_hbox, gl_rfull.g_w, gl_rfull.g_h );

    return TRUE;			/* everything is fine */
}




/*
 * Wm_create() - allocates the application's full-size window and 
 *		 returns the window's handle.
 *	       - returns FAILURE (-1) if no handle is available or
 *		 if an error occurred.
 */
	WORD
wm_create( kind, rect )
	UWORD	    kind;	/* kind of window to be created */
	REG GRECT   *rect;	/* x, y, width and height of full size window */
{
    REG	WORD 	i;		/* counter */
    REG WINDOW	*wp;		/* pointer to window structure */

    /* find next available window structure and handle	*/
    /* if none available, return with a FAILURE		*/
    if( ( wp = newwp() ) == ( WINDOW *)NULLPTR || newhndl(wp) == FAILURE) {
	Debug5("wm_create fails\r\n");
	return FAILURE;
    }


    wp->type = 0;
    wp->status.opened = FALSE;		/* window has not been opened yet */
    wp->cowner = wp->owner = currpd;	/* init owner of window */
#if 0
    wp->mowner = NIL;			/* no mouse owner FOR NOW */
#endif
    wp->fxywh = wp->nxywh = (RLIST *)NULLPTR;	/* no rectangle list yet */
    wp->kind = kind;			/* save kind of window */
    wp->ad_tools = ( OBJECT *)NULLPTR;	/* Clear ToolBar Tree cjg 05/26/93*/

    /* initialize window object colors */
    /* also, set all objects to not display, initially */
    for (i = 0; i < MAXOBJ; i++) {
	wp->tcolor[i] = wtcolor[i];
	wp->bcolor[i]= wbcolor[i];
	wp->obj[i].ob_type = G_IBOX;
	wp->obj[i].ob_flags = HIDETREE;
    }

    /* initialize window coordinates and size */
    w_rect(&(wp->prev), 0, 0, 0, 0);
    *(GRECT *)&(wp->obj[W_WORK].ob_x) = wp->prev;
    wp->curr = wp->prev;
    wp->full = *rect;

    /* initialize sliders positions and sizes */
    wp->hslpos = wp->vslpos = 0;
    wp->hslsz = wp->vslsz = -1;

    /* the window has not been opened yet */
    wp->ontop = wp->under = NIL;

    /* assume no parent, child or sibling relationship FOR NOW */
    wp->parent = wp->child = wp->sibling = NIL;

    /* first object is the background, and it has a shadow */
    w_bld(wp, W_BOX, G_IBOX, NIL, GBOX_OBS, NO3D);
    wp->obj[W_BOX].ob_state |= SHADOWED;

    hparts = kind & HPARTS;	/* mask for vertical slider elements */
    vparts = kind & VPARTS;	/* mask for horizontal slider elements */

    if (kind & TPARTS) {	/* any title bar elements? */
	w_bld(wp, W_TITLE, G_BOX, W_BOX, GBOX_OBS, NO3D);

	if (kind & CLOSER) {
	    w_bld(wp, W_CLOSER, G_BOXCHAR, W_TITLE, 0x05010000, IS3D);
	}

	if (kind & NAME) 
	{
	    w_bld(wp, W_NAME, G_BOXTEXT, W_TITLE, ( LONG )(&(wp->ttxt)), IS3D);
/*	    w_ted(&(wp->ttxt), "Title Bar", 2, wtcolor[W_TITLE]);	*/
	    wp->ttxt.te_ptext = ( LONG )&wp->tbuf[0];	/* changed 2/28/92	*/
	    w_ted(&(wp->ttxt), "", 2, wtcolor[W_TITLE]);
	


	} else if (kind & MOVER) {
	    w_bld(wp, W_NAME, G_IBOX, W_BOX, 0L, NO3D);
	}

	if (kind & FULLER) {
	    w_bld(wp, W_FULLER, G_BOXCHAR, W_TITLE, 0x07010000, IS3D);
	}

	if (kind & SMALLER) {
	    w_bld(wp, W_SMALLER, G_BOXCHAR, W_TITLE, 0x7f010000, IS3D);
	}
    }

    if (kind & INFO) {
	w_bld(wp, W_INFO, G_BOXTEXT, W_BOX, ( LONG )(&(wp->itxt)), NO3D);
/*	w_ted(&(wp->itxt), "Info Line", 0, wtcolor[W_INFO]);	*/
	wp->itxt.te_ptext = ( LONG )&wp->ibuf[0];	/* changed 2/28/92	*/
	w_ted(&(wp->itxt), "", 0, wtcolor[W_INFO]);
    }

#ifdef MNBAR
    if (kind & MNBAR) {
	w_bld(wp, W_MNBAR, G_BOXTEXT, W_BOX, &(wp->mtxt), NO3D);
	w_ted(&(wp->mtxt), " Desk  File  View  Options", 0, wtcolor[W_MNBAR]);
    }
#endif

    if (kind & SIZER) {
	w_bld(wp, W_SIZER, G_BOXCHAR, W_BOX, 0x06010000, IS3D);

	if (!hparts && !vparts) {
	    w_bld(wp, W_VBAR, G_BOX, W_BOX, GBOX_OBS, NO3D);

	/* Changed 3/2/1992 ml. */
	/*
	    w_bld(wp, W_HBAR, G_BOX, W_BOX, GBOX_OBS, IS3D);
	*/
	}
    } else if (hparts && vparts) {
	w_bld(wp, W_SIZER, G_BOX, W_BOX, GBOX_OBS, IS3D);
    }

    if (vparts) {
	w_bld(wp, W_VBAR, G_BOX, W_BOX, GBOX_OBS, NO3D);

	if (kind & UPARROW) {
	    w_bld(wp, W_UPARROW, G_BOXCHAR, W_VBAR, 0x01010000, IS3D);
	}

	if (kind & DNARROW) {
	    w_bld(wp, W_DNARROW, G_BOXCHAR, W_VBAR, 0x02010000, IS3D);
	}

	if (kind & VSLIDE) {
	    w_bld(wp, W_VSLIDE, G_BOX, W_VBAR, 0x00010000, NO3D);
	    w_bld(wp, W_VELEV, G_BOX, W_VSLIDE, GBOX_OBS, IS3D);
	}
    }

    if (hparts) {
	w_bld(wp, W_HBAR, G_BOX, W_BOX, GBOX_OBS, NO3D);

	if (kind & LFARROW) {
	    w_bld(wp, W_LFARROW, G_BOXCHAR, W_HBAR, 0x04010000, IS3D);
	}

	if (kind & RTARROW) {
	    w_bld(wp, W_RTARROW, G_BOXCHAR, W_HBAR, 0x03010000, IS3D);
	}

	if (kind & HSLIDE) {
	    w_bld(wp, W_HSLIDE, G_BOX, W_HBAR, 0x00010000, NO3D);
	    w_bld(wp, W_HELEV, G_BOX, W_HSLIDE, GBOX_OBS, IS3D);
	}
    }
    wp->iconflag = FALSE;
    wp->iconslot = (BYTE) -1;

    w_rect(&(wp->icon), 0, 0, 0, 0);
    wp->savekind = 0;

    storewp(wp);	/* store window structure into database */
    w_adjust( wp, rect, FALSE);
    Debug5( wp->owner->p_name );
    Debug5( " creates " );
    Ndebug5( (LONG)wp->handle );  		

    return(wp->handle);	/* returns a handle */
}



/*	Open a window, called by system level process
 * Wm_open() - opens a window in its given size and location.
 *	     - returns FALSE (0) if given handle is invalid,
 *	       or if window has already been opened.
 *	     - returns TRUE (1) if everything is fine.
 * +++ 7/19/93 HMK
 * if the window has the iconified flag set and x, y, width  and height are
 * -1, -1, -1, -1, an icon slot will be used!!

 */
	WORD
wmopen(handle, rect)
	WORD	    handle;	/* handle of window to be opened */
	REG GRECT   *rect;	/* x, y, width and height of opened window */
{
    REG WINDOW  *wp;	    	/* pointer to window structure */
    WORD	ret,w,h;	/* return code */

    				/* if window structure can't be found		*/
				/* or window already opened, return error	*/

    if ((wp = srchwp(handle)) == ( WINDOW *)NULLPTR || wp->status.opened) {
	Debug5("wm_open fails, handle="); Ndebug5((LONG)handle);
	if (wp->status.opened)
		Debug5("window is already opened!\r\n");
	return ( FALSE );
    }

    Debug5( wp->owner->p_name );
    Debug5( " opens " );
    Ndebug5( (LONG)handle );
	
    if ( handle != phanwind )
      wmclose( phanwind );

    wp = srchwp( handle );
	

    if (wp->iconflag && (rect->g_x == -1) && (rect->g_y == -1)) {
	WORD set;
						/* use icon slot */
	set = TRUE;
	if (icnslots == NULL)  			/* +++ 7/18/93 */
		set = FALSE ;
	else if (findIcnslot(icnslots, &currIcnmax, &rect->g_x, &rect->g_y, 
	&wp->iconslot) == FALSE )
		set = FALSE;
		
	if (!set) {
		rect->g_y = gl_rfull.g_y + gl_rfull.g_h - WINICON_H - 1;
		rect->g_x = 0;
	}

    }
    if (wp->iconflag && (rect->g_w == -1) && (rect->g_h == -1)) {
	rect->g_w = WINICON_W;
	rect->g_h = WINICON_H;
    }

				/* check the minimun size */
    wm_min( wp, &w, &h );

    if ( w > rect->g_w )
      rect->g_w = w;

    if ( h > rect->g_h )
      rect->g_h = h;
		
    w_adjust( wp, rect, TRUE);		/* init window components */
    wp->prev = wp->curr;
    wp->status.opened = TRUE;	    	/* Grand opening!	*/

    ret = totop( handle, WMOPEN );	/* top it	*/

    if ( ( ret ) && ( handle != phanwind ) )
      	setmenu( wp->owner );

    return ( ret );
}

/*
 * Wm_open() - opens a window in its given size and location.
 *	     - returns FALSE (0) if given handle is invalid,
 *	       or if window has already been opened.
 *	     - returns TRUE (1) if everything is fine.
 *
 * +++ 7/19/93 HMK
 * if the window has the iconified flag set and x, y, width  and height are
 * -1, -1, -1, -1, an icon slot will be used!!
 */
	WORD
wm_open(handle, rect)
	WORD	    handle;	/* handle of window to be opened */
	REG GRECT   *rect;	/* x, y, width and height of opened window */
{
    WORD	ret;	    	/* return code */

    wm_update(1);
    ret = wmopen( handle, rect );	
    wm_update(0);
    return ( ret );
}


/*	Close a window, called by system level prcocess	*/

	WORD
wmclose( handle )
	WORD	handle;			/* handle of window to be closed */
{
	REG WINDOW	*wp, *wp1;	/* pointers to window structure */
	GRECT		dirty;		/* rectangle of dirty area */
	PD		*p,*p1;
	WORD		closetop;

	if ( ( handle == deskwind ) || ( wp = srchwp(handle)) == ( WINDOW *)NULLPTR || !wp->status.opened )
	  return FALSE;

	Debug5( wp->owner->p_name );
	Debug5( "closes " );
	Ndebug5( (LONG)handle );

	closetop = FALSE;		/* assume not closing the top win */

	wp->prev = wp->curr;		/* save previous coords */

	w_rect(&(wp->curr), 0, 0, 0, 0);  /* reset current coords and work area coords */

    	*(GRECT *)&(wp->obj[W_WORK].ob_x) = wp->curr;

#if 0
	if (wp->iconflag) 
#endif
		retIcnslot(icnslots, &wp->iconslot, &currIcnmax);

	wp->status.opened = FALSE;	/* remember that window has been closed */

				    	/* delete window's rectangle list if there is one */
    	if (wp->fxywh) 
	{
	  delrect( ( RLIST *)0L, ( BYTE *)wp->fxywh);
	  wp->fxywh = wp->nxywh = ( RLIST *)NULLPTR;
    	}

	dirty = wp->prev;
	dirty.g_w += SHADOW;
	dirty.g_h += SHADOW;
	w_drawchange(&dirty, NIL, NIL);
				    /* maintain linked list of opened windows */
    	if ( handle == gl_topw ) 
	{
	  closetop = TRUE;
	  if ((gl_topw = wp->under) != NIL) 
	    totop(gl_topw, WMCLOSE);
	  else 
	    botw = NIL;
        } 
        else 
	  if (handle == botw) 
	  {
	    botw = wp->ontop;
	    wp = srchwp(botw);
	    wp->under = NIL;
          } 
	  else 
	  {
	    wp1 = srchwp(wp->under);
	    wp1->ontop = wp->ontop;
	    wp1 = srchwp(wp->ontop);
	    wp1->under = wp->under;
          }

	if ( ( closetop ) && ( handle != phanwind ) )
	{			/* check the next top window */
	  if ( gl_topw == deskwind )
	  {
	    if ( !( gl_kbid = gl_mnpid ) )
	      Debug1( "Key owner is zero 1\r\n" );
	    else
	      goto w_1;		      		    	
	  }
	  else
	  {		
w_1:	    p = srchwp( gl_topw )->owner;	    

	    if ( ( p->p_state != PS_DEAD ) && ( p->p_state != PS_ZOMBIE ) )
	    {
	      if ( ( p->p_type & AESAPP ) && ( p->p_mnaddr ) )
	      {				/* In case mn_bar is 0 */
		p1 = ( gl_mnpid ) ? idtopd( gl_mnpid ) : currpd;
	        if ( ( p != p1 ) || ( gl_topw == deskwind ) )
	        {
	          if ( ( handle = w_tophandle( p1 ) ) == -1 )
	  	  {
	            openphanwind( p1 );
		    return( TRUE );
		  }
		  else
	 	  {
/*                    wmset( handle, WF_TOP, (GRECT*)0 );*/
                    wmset( handle, WF_TOP, ( WORD *)((GRECT*)0) );
		    p = p1;
		  }
		}
	      }

	      if ( !( gl_kbid = p->p_pid ) )
	        Debug1( "Key owner is zero 2\r\n" );		

              ap_sendmsg( WM_ONTOP, p->p_pid, gl_topw, 0, 0, 0, 0 );
	    }
	  }
	}

        return TRUE;
}


/*
 * Wm_close() - closes an opened window
 *	      - returns FALSE (0) if given handle is invalid,
 *	        or if window has already been closed.
 *	      - returns TRUE (1) if everything is fine.
 *
 */
	WORD
wm_close( handle )
	WORD	handle;			/* handle of window to be closed */
{
	WORD	ret;
	WINDOW	*wp;
					/* illegal handle */	
	Debug5( currpd->p_name );
	Debug5( " close window " );

	if ( !( wp = srchwp( handle ) ) )
	  return( FALSE );

	if ( handle != phanwind )	
	{
	  if ( !( currpd->p_type & AESSYSTEM ) && ( currpd != wp->owner ) )
	    return( FALSE );
	}
	
	
	wm_update( 1 );
	ret = wmclose( handle );
	wm_update( 0 );

	if ( !ret )
	{
	  Debug1( currpd->p_name );
	  Debug1( " close window " );
	  Debug1( " failed\r\n" );
	}
	else
	{
	  Debug7( currpd->p_name );
	  Debug7( " close window " );
	  Debug7( " OK\r\n" );
	}

        return ( ret );
}


/*
 *	Delete a window, called by system level process	
 * Wm_delete() - closes the window if it is not already closed,
 *		 and frees the window structure.
 *	       - returns FALSE (0) if given handle is invalid.
 *	       - returns TRUE (1) if everything is fine.
 *
 */
	WORD
wmdelete(handle)
	WORD	handle;		/* handle of window to be deleted */
{
    REG	WINDOW  *wp, *wp1, *wp2;    /* pointers to window structures */
    MEMHDR	*mp;		    /* pointer to memory header */
    WORD	bucket;		    /* index into hash table */

    if ( ( handle == deskwind ) || (wp = srchwp(handle)) == ( WINDOW *)NULLPTR)
	return FALSE;

    Debug5( wp->owner->p_name );
    Debug5( " deletes " );
    Ndebug5( (LONG)handle );

    /* delete window's rectangle list if there is one */

    if (wp->fxywh)
	delrect( ( RLIST *)0L, ( BYTE *)wp->fxywh);

    if (wp->status.opened)	/* if not already closed, */
	wmclose(handle);	/* close the window first */

    /* Remove window structure of deleted window from database */
    bucket = handle % NUMWIN;
    if (hashtbl[bucket] == wp) {
	hashtbl[bucket] = wp->wnext;
    } else {
	for (wp1 = hashtbl[bucket];
	    wp1->wnext != wp;
	    wp1 = wp1->wnext)
	    ;
	wp1->wnext = wp->wnext;
    }

    /* Maintain list of handle numbers */
    if (handle == hhead) {
	hhead = wp->nxthndl;
    } else {
	for (wp1 = srchwp(hhead);
	    wp1->nxthndl != handle;
	    wp1 = srchwp(wp1->nxthndl))
	    ;
	wp1->nxthndl = wp->nxthndl;
    }

    /*
     * Check if window structure resides in last block of memory
     * allocated, if not, fill the window structure with one from
     * the last block, and free the last block if it then becomes
     * empty.  Update the database with this _moved_ window structure.
     */

    if ((mp = wp->wwhere) != wmtail) {
	for (wp1 = (WINDOW *)(wmtail+1); wp1->status.used == FALSE; wp1++)
	    ;
	*wp = *wp1;
	wp->wwhere = mp;	/* restore address of memory block */

				/* changed 3/2/92	*/
	/* adjust the address because the structure has been moved	*/ 
	wp->obj[W_NAME].ob_spec = ( LONG )&(wp->ttxt);
	wp->obj[W_INFO].ob_spec = ( LONG )&(wp->itxt);
	wp->ttxt.te_ptext = ( LONG )&wp->tbuf[0];	/* changed 2/28/92	*/
	wp->itxt.te_ptext = ( LONG )&wp->ibuf[0];	/* changed 2/28/92	*/

	bucket = wp1->handle % NUMWIN;
	if (hashtbl[bucket] == wp1) {
	    hashtbl[bucket] = wp;
	} else {
	    for (wp2 = hashtbl[bucket];
		wp2->wnext != wp1;
		wp2 = wp2->wnext)
		;
	    wp2->wnext = wp;
	}
	wp1->status.used = FALSE;
    } else {
	wp->status.used = FALSE;
    }

    wmtail->numused -= 1;

    if (!wmtail->numused && wmhead != wmtail) {
	dos_free( ( LONG )wmtail );
	for (mp = wmhead; mp->mnext != wmtail; mp = mp->mnext)
	    ;
	mp->mnext = ( MEMHDR *)NULLPTR;
	wmtail = mp;
    }

    return TRUE;
}

/*
 * Wm_delete() - closes the window if it is not already closed,
 *		 and frees the window structure.
 *	       - returns FALSE (0) if given handle is invalid.
 *	       - returns TRUE (1) if everything is fine.
 *
 */
	WORD
wm_delete(handle)
	WORD	handle;		/* handle of window to be deleted */
{
	WORD	ret;
	WINDOW	*wp;

    if ( ( handle == deskwind ) || (wp = srchwp(handle)) == ( WINDOW *)NULLPTR)
	return FALSE;

    if ( !( currpd->p_type & AESSYSTEM ))
    {
      if ( currpd != wp->owner )
	return( FALSE );
    }

    wm_update( 1 );	
    ret = wmdelete( handle );
    wm_update( 0 );

    return( ret );
}


/*
 * Wm_get() - returns information of window in the given array
 *	    - returns FALSE (0) if given handle is invalid
 *	    - returns TRUE (1) if everything is fine
 *
 */
	WORD
wm_get(handle, field, ow, iw)
	REG WORD    handle;	/* window handle */
	WORD	    field;	/* flag to identify what info to be returned */
	REG WORD    ow[];	/* return values */
	WORD	    iw[];
{
    WORD	ret;
    REG WINDOW	*wp;
    REG	GRECT	*r;
    WORD		area;
	
    if ( ( field == WF_DCOLOR ) || ( field == WF_TOP ) || ( field == WF_SCREEN ) ||
	 ( field == WF_BOTTOM )	)
      goto wg_1;
	 
    if ((wp = srchwp(handle)) == ( WINDOW *)NULLPTR )
    {
	Debug1(currpd->p_name); Debug1( ": Wind_get illegal handle=" );Ndebug1((LONG)handle); 	
	return FALSE;
    } 		

wg_1:

    ret = TRUE;

    switch (field) {

	case WF_WORKXYWH:
	    r = (GRECT *)ow;
	    *r = *(GRECT *)&(wp->obj[W_WORK].ob_x);
 	    break;

	case WF_CURRXYWH:
	    r = (GRECT *)ow;
	    *r = wp->curr;
	    break;

	case WF_PREVXYWH:
	    r = (GRECT *)ow;
	    *r = wp->prev;
	    break;

	case WF_FULLXYWH:
	    r = (GRECT *)ow;
	    *r = wp->full;
	    break;

	case WF_HSLIDE:
	    ow[0] = wp->hslpos;
	    break;

	case WF_VSLIDE:
	    ow[0] = wp->vslpos;
	    break;

	case WF_HSLSIZE:
	    ow[0] = wp->hslsz;
	    break;

	case WF_VSLSIZE:
	    ow[0] = wp->vslsz;
	    break;

	case WF_TOP:
	    wp = srchwp( gl_topw );
	    ow[0] = gl_topw;
	    ow[1] = wp->owner->p_pid;
	    ow[2] = wp->under;
	    break;

	case WF_FTOOLBAR:
	case WF_FIRSTXYWH:

	    area = (( field == WF_FIRSTXYWH )?( WF_WORKXYWH ):( WF_TOOLBAR ));

	    r = (GRECT *)ow;

	    if ( !wp->status.opened )
	    {
	      r->g_w = 0;
	      r->g_h = 0;
	      break;
	    }

	    /* If checking for the TOOLBAR area, there must be a valid
	     * tree AND the window cannot be iconified.
	     */
	    if( area == WF_TOOLBAR ) {
	       if( !wp->ad_tools || wp->iconflag ) {
		 r->g_w = 0;
		 r->g_h = 0;
		 break;
	       }
            }


	    /* delete old list if there is one */
	    if (wp->fxywh) {
		delrect( 0L, ( BYTE *)wp->fxywh );
		wp->fxywh = wp->nxywh = ( RLIST *)NULLPTR;
	    }
	    /* generate new list */
	    if (wp->fxywh = genrlist(handle, area)) {
	    	wp->nxywh = (wp->fxywh)->rnext;
		*r = (wp->fxywh)->rect;
	    } else {
		*r = wp->curr;
		r->g_w = 0;
		r->g_h = 0;
	    }

	    break;

	case WF_NTOOLBAR:
	case WF_NEXTXYWH:
	    r = (GRECT *)ow;
	    if ( wp->nxywh ) 
	    {
	      *r = (wp->nxywh)->rect;
	      wp->nxywh = (wp->nxywh)->rnext;
	    } 
	    else 
	    {
	      *r = wp->curr;
	      r->g_w = 0;
	      r->g_h = 0;
	    }

	    break;

	case WF_NEWDESK:
	    if ( gl_newdesk )
	    {
	      *(LONG *)ow = ( LONG )gl_newdesk;
	      ow[2] = gl_newroot;
	    }
	    else
	    {
	      *(LONG *)ow = ( LONG )gl_wtree;
	      ow[2] = ROOT;
	    }
	    break;

	case WF_SCREEN:
	    gsx_mret( ( LONG *)&ow[0], ( LONG *)&ow[2]);
	    break;

	case WF_COLOR:				/* Feb 26 1992 ml. */
	    ow[0] = iw[0];
	    ow[1] = wp->tcolor[iw[0]];
	    ow[2] = wp->bcolor[iw[0]];
	    break;

	case WF_DCOLOR:
	    ow[0] = iw[0];
	    ow[1] = wtcolor[iw[0]];
	    ow[2] = wbcolor[iw[0]];
	    break;

	case WF_OWNER:
	    ow[0] = wp->owner->p_pid;
	    ow[1] = wp->status.opened;
	    ow[2] = wp->ontop;
	    ow[3] = wp->under;
	    break;

	case WF_BEVENT:
	    ow[0] = wp->type;		/* get the click always? */
	    break;

	case WF_BOTTOM:
	    ow[0] = srchwp(0)->ontop; 
	    break;

	case WF_REDRAW:
	    *((LONG*)&ow[0]) = ( LONG )wp->drawaddr;
	    break;
	case WF_ICONIFY:	  /* return iconified state */
	    ow[0] = wp->iconflag; /* window status: TRUE==ICON, FALSE==NORMAL */
	    ow[1] = WINICON_W;	  /* std. width of an icon */
	    ow[2] = WINICON_H;	  /* std. height of an icon */
	    break;
	case WF_UNICONIFY:
	    r = (GRECT *)ow;	/* window's size when not iconified */
	    *r = wp->icon;
	    break;
#if 0
	case WF_ICONSLOT:
	   ow[0] = wp->iconslot;
	   break;
#endif
	case WF_TOOLBAR:	/* Get Tree for the ToolBar cjg 05/26/93 */
	     *(LONG *)ow = ( LONG )wp->ad_tools;
	     break;
	case WF_RESVD:
	default:
	    ret = FALSE;
	    break;
    }

    return ret;
}


/*	System level wm_set 
 *
 */
	WORD
wmset(handle, field, iw)
	REG WORD    handle;	    /* window handle */
	REG WORD    field;	    /* flag to identify what info to be changed */
	REG WORD    iw[];	    /* values to change to */
{
	REG WINDOW	*wp;	    /* pointer to window structure */
	WORD		ret, obj, drawit;
	GRECT		rect, rect1;
	WORD		which;
	WORD		oldbcolor, oldtcolor;
	WORD		i;
	PD		*p;
	WORD		uniflag = FALSE;
	WORD		w, h;
	WORD		tflag;
	GRECT		trect;

	if ((wp = srchwp(handle)) == ( WINDOW *)NULLPTR)
	  return FALSE;	

    	ret = TRUE;		    /* assume everything will be ok */

    	switch (field) 
	{
	  case WF_NAME:
	    if ( !( wp->kind & NAME ) )
	    {
	       ret = FALSE;
	       break;
	    }
				/* changed 3/1/92	*/
	    nstrcpy( ( BYTE *)(*(LONG *)iw), ( BYTE *)wp->ttxt.te_ptext, 128 );	
/*	    wp->ttxt.te_ptext = *(LONG *)iw;	*/
	    if (wp->status.opened)
	    {
		w_clipdraw( wp, W_TITLE, ( GRECT *)NULLPTR);
	    }
	    break;

	  case WF_INFO:
	    if ( !( wp->kind & INFO ) )
	    {
	       ret = FALSE;
	       break;
	    }
				/* changed 3/1/92	*/
	    nstrcpy( ( BYTE *)(*(LONG *)iw), ( BYTE *)wp->itxt.te_ptext, 128 );
/*	    wp->itxt.te_ptext = *(LONG *)iw;	*/
	    if (wp->status.opened)
	    {
		w_clipdraw( wp, W_INFO, ( GRECT *)NULLPTR);
	    }
	    break;
#if 0
	  case WF_ICONSLOT:
	    wp->iconslot = iw[0];
	    break;
#endif
	  case WF_UNICONIFYXYWH: /* set size which will be send when */
	    rect = *(GRECT *)iw; /* a WM_UNICONIFY message occurs    */
	    w_adjust(wp, &rect, FALSE); 
	    rc_copy(&rect, &wp->icon);
	    break;

	  case WF_UNICONIFY:
	    wp->ttxt.te_font = IBM; 	/* normal font */
	    wp->kind = wp->savekind;	/* get parts back */
	    wp->savekind = 0;
	    wp->iconflag = FALSE;	/* not an icon window anymore */
	    w_showparts(wp);		/* show window parts again */

	    uniflag = TRUE;		/* make sure that the prev == curr */
	    goto currxywh;		/* set to previous window size */

	  case WF_ICONIFY:
	    wp->ttxt.te_font = SMALL;	/* small font */
	    w_hideparts(wp);		/* hide window parts */
	    wp->savekind = wp->kind;	/* remember window parts */
	    wp->kind = 0;
	    wp->iconflag = TRUE;	/* we are now an iconified window */
	    if (wp->savekind & NAME) 
		    wp->kind |= NAME;
	    if (wp->savekind & MOVER) 
		    wp->kind |= MOVER;
	    rc_copy(&wp->curr, &wp->icon); /* store current coords */
			
	    /* now set it to icon window sizes ... */

	  case WF_CURRXYWH:
currxywh:
	    if ( iw[1] < gl_hbox )
	      iw[1] = gl_hbox;

	    rect = *(GRECT *)iw;

	    /* Check for a minimum size...*/
	    wm_min( wp, &w, &h );

            if ( w > rect.g_w )
                 rect.g_w = w;

	    tflag = FALSE;
            if ( h > rect.g_h ) {
		 tflag = TRUE;		/* cjg 06/2/93 */
                 rect.g_h = h;
	    }
	
	    w_adjust(wp, &rect, FALSE);  
					 /* above fct. messes up sliders, so */
	    if (field == WF_UNICONIFY) { /* restore slider pos. HMK 7/15/93  */
		    if (wp->kind & HSLIDE)
			    w_setslide( wp, WF_HSLIDE );
		    if (wp->kind & VSLIDE)
			    w_setslide( wp, WF_VSLIDE );
	    }

	    if (wp->status.opened) {
		/* send redraw message to opened windows which */
		/* intersect with the dirty area */
		rect = wp->prev;
		rect.g_w += SHADOW;
		rect.g_h += SHADOW;

		rect1 = wp->curr;
		rect1.g_w += SHADOW;
		rect1.g_h += SHADOW;

		if ( ( handle != gl_topw ) || 
		     ((rect.g_x+rect.g_w > gl_width)&&(rect1.g_x < rect.g_x))
		    || ((rect.g_y+rect.g_h > gl_height)&&(rect1.g_y < rect.g_y))
		    || rect.g_w != rect1.g_w || rect.g_h != rect1.g_h
		    || rect.g_x < gl_rfull.g_x ) 
		{
		    w_clipdraw( wp, W_BOX, ( GRECT *)NULLPTR );
		    if (rect1.g_x != rect.g_x || rect1.g_y != rect.g_y
			|| rect1.g_w > rect.g_w || rect1.g_h > rect.g_h) {
		    	ap_sendmsg( WM_REDRAW, wp->owner->p_pid, handle,
				wp->curr.g_x, wp->curr.g_y, wp->curr.g_w, 
				wp->curr.g_h);
		    }
		    /* Check if we should redraw the TOOLBAR area
		     * cjg 06/02/93
		     */
		    if( wp->ad_tools && !wp->iconflag ) {

		      if( ( rect.g_x != rect1.g_x ) ||
			  ( rect.g_y != rect1.g_y)  ||
			  tflag ) {		/* forced new height only */

		          w_tooldraw( wp, W_BOX, &wp->curr );
		      }
		      else {

			  /* This is if x1 == x2, y1 == y2, height == d/c
			   * and w2 > w1 - Do a redraw of the dirty area
			   * of the toolbar.
			   */
			   if( rect1.g_w > rect.g_w ) {
			      WORD x, y;
#if 0
			      ob_actxywh( ( LONG )wp->ad_tools, ROOT, &trect );
#else
			      ob_gclip((LONG)wp->ad_tools, ROOT, &x, &y,
				&trect.g_x, &trect.g_y, &trect.g_w, &trect.g_h); 
#endif

			      trect.g_w = ( rect1.g_w - rect.g_w + SHADOW +
					  (( trect.g_x - rect.g_x ) << 2 ));

	      		      trect.g_x = rect.g_x + rect.g_w - SHADOW - 
			  		  ( trect.g_x - rect.g_x ) - 1;

		              w_tooldraw( wp, W_BOX, &trect );
			   }
		      }

		    }
		} 
		else 
		{
		      gsx_sclip( &gl_rfull );
		      gsx_moff();
		      bb_screen( S_ONLY, rect.g_x, rect.g_y, rect1.g_x,
			       rect1.g_y, rect.g_w, rect.g_h );
		      gsx_mon();
		}

		w_drawchange( &rect, handle, handle );
	    }
	    if (uniflag)
		rc_copy(&wp->curr, &wp->prev);
	    break;

 	case WF_HSLSIZE:
	case WF_HSLIDE:
	    if ( !( wp->kind & HSLIDE ) )
	    {
	       ret = FALSE;
	       break;
	    }
	    goto ws_2;

	case WF_VSLSIZE:
	case WF_VSLIDE:
	    if ( !( wp->kind & VSLIDE ) )
	    {
	       ret = FALSE;
	       break;
	    }
ws_2:
	    if (iw[0] > 1000)
		iw[0] = 1000;
	    else if (iw[0] < -1)
		iw[0] = -1;

	    switch (field) {
		case WF_HSLIDE:

		    wp->hslpos = iw[0];
		    break;

		case WF_VSLIDE:
		    wp->vslpos = iw[0];
		    break;

		case WF_HSLSIZE:
		    wp->hslsz = iw[0];
		    break;

		case WF_VSLSIZE:
		    wp->vslsz = iw[0];
		    break;
	    }

	    if ( field == WF_HSLIDE || field == WF_HSLSIZE ) 
	    {
		obj = W_HSLIDE;
	    } 
	    else	/* field == WF_VSLIDE || field == WF_VSLSIZE */ 
	    {	
		obj = W_VSLIDE;
	    }

	    w_setslide( wp, field );

	    /* if window is already opened, redraw it */

	    if ( wp->status.opened )
	   	w_clipdraw( wp, obj, ( GRECT *)NULLPTR);

	    break;

	case WF_TOP:
	    if ( handle != gl_topw )
	    {
	      if ( ret = totop( handle, WMSET ) )
	      {
/*		gr_mouse( wp->owner->p_mkind, (BYTE*)0 );	*/
	        if ( !( gl_kbid = wp->owner->p_pid ) )
	           Debug1( "Key owner is zero 4\r\n" );
	        /* send_ctrl( wp->owner, 0 ); */
		if ( handle != phanwind )
		  wmclose( phanwind );
	      }
	    }

	    Debug7( "WF_TOP call setmenu by " );
	    Debug7( wp->owner->p_name );
	    Debug7( "\r\n" );	
	    setmenu( ( phanwind == gl_topw ) ? wp->cowner : wp->owner );
	    break;


	case WF_NEWDESK:		/* reset the background */
	    drawit = FALSE;

	    if ( !( gl_newdesk = ( OBJECT *)( *(LONG *)&iw[0] ) ) )
	    {				/* if the user reset the background */
					/* then redraw it if necessary	    */
	      if ( currpd->p_pid == gl_newid )
	      {
		if ( currpd->p_newdesk != ( BYTE *)gl_wtree )
		  drawit = TRUE;
	      }

	      gl_newdesk = gl_wtree;
	      gl_newroot = ROOT;
	    }
	    else
	    {
	      gl_newroot = iw[2];
	      if ( aesDDD && gl_newdesk[0].ob_type != G_USERDEF )
	      {
		gl_newdesk[0].ob_type = G_USERDEF;
		gl_newdesk[0].ob_spec = ( LONG )aesDDD;
		dk_newdraw(&gl_rfull);
	      }	
	    }

	    gl_newid = currpd->p_pid;
	    srchwp( deskwind )->owner = currpd;
	    currpd->p_newdesk = ( BYTE *)gl_newdesk;
	    currpd->p_newroot = gl_newroot;

	    if ( drawit )
	      dk_redraw( gl_newdesk, gl_newroot, &gl_rfull );

	    break;

	case WF_COLOR:
	    which = iw[0];
wfagain:
	    if (iw[1] != -1)
		wp->tcolor[which] = iw[1];
	    if (iw[2] != -1)
		wp->bcolor[which] = iw[2];

	    if (wp->handle == gl_topw)
		setcol(wp, which, TRUE);
	    else
		setcol(wp, which, FALSE);

	    /* if window is already opened, redraw it */
	    /* BUG: iconified windows can't be redrawn, w_clipdraw loses */

	    if (wp->status.opened && !wp->iconflag)
		w_clipdraw( wp, which, ( GRECT *)NULLPTR);

/* kludge: take the colors for the fuller and use them for the
 * iconifier
 */
	    if (which == W_FULLER) {
		which = W_SMALLER;
		goto wfagain;
	    }
	    break;

	case WF_DCOLOR:
	    which = iw[0];
wfdagain:
	    oldtcolor = wtcolor[which];
	    oldbcolor = wbcolor[which];
	    if (iw[1] != -1)
		wtcolor[which] = iw[1];
	    if (iw[2] != -1)
		wbcolor[which] = iw[2];
/* Now update any existing windows to use the new colors */
	    for (i = 0; i < NUMWIN; i++) {
		for(wp = hashtbl[i]; wp; wp = wp->wnext) {
		    if (wp->handle == deskwind || wp->handle == phanwind)
			continue;
	/* only update the window if it is using the default color */
		    if (oldtcolor == wp->tcolor[which])
			wp->tcolor[which] = wtcolor[which];
		    if (oldbcolor == wp->bcolor[which])
			wp->bcolor[which] = wbcolor[which];

		    setcol( wp, which, (wp->handle == gl_topw) ); 

	    /* BUG: iconified windows can't be redrawn, w_clipdraw loses */
		    if (wp->status.opened && !wp->iconflag)
		        w_clipdraw( wp, which, (GRECT *)NULLPTR );
		}
	    }
	    if (which == W_FULLER) {
	     	which = W_SMALLER;
		goto wfdagain;
	    }
	    break;

	case WF_BEVENT:
	    wp->type = iw[0];	/* get the click always? */
	    wp->drawaddr = ( BYTE * )( *((LONG*)&iw[2] )); 	
	    break;

	case WF_BOTTOM:			/* Feb 26 1992 ml. */
	    i = (gl_topw == handle);	/* do some stuff if top window is changed */
	    ret = tobot(handle);
	    if (ret && i) {
		wp = srchwp( gl_topw );
		if (!wp) break;
		p = wp->owner;
	        if ( ( p->p_state != PS_DEAD ) && ( p->p_state != PS_ZOMBIE ) )
	        {
	            if ( ( p->p_type & AESAPP ) )
	            {				/* In case mn_bar is 0 */
			ap_sendmsg( WM_ONTOP, p->p_pid, gl_topw, 0, 0, 0, 0 );
			gl_kbid = p->p_pid;
			setmenu( (phanwind == gl_topw) ? wp->cowner : wp->owner );
		    }
		}
	    }
	    break;
	
	case WF_REDRAW:	     /* set the redraw address of a particular win */
	    wp->drawaddr = ( BYTE *)( *((LONG*)&iw[0] ));
	    break;


	case WF_TOOLBAR:    /* Set the tree for the ToolBar cjg - 05/26/93 */
	     wp->ad_tools = ( OBJECT *)( *(LONG *)&iw[0] );

	     /* Readjust the window structure, redraw
	      * and send a WM_SIZE and WM_REDRAW message notifying the app.
	      * 1) The window is OPEN
	      * 2) The window is NOT iconified
	      */

	     if( wp->status.opened && !wp->iconflag ) {
		/* Check for a minimum size...*/
	        wm_min( wp, &w, &h );

                if ( w > wp->curr.g_w )
                   wp->curr.g_w = w;

                if ( h > wp->curr.g_h )
                   wp->curr.g_h = h;

	        w_adjust( wp, &wp->curr, TRUE );
		w_clipdraw( wp, W_BOX, ( GRECT *)NULLPTR );
		w_tooldraw( wp, W_BOX, ( GRECT *)NULLPTR );

	    	ap_sendmsg( WM_SIZED, wp->owner->p_pid, handle,
			    wp->curr.g_x, wp->curr.g_y, wp->curr.g_w, 
			    wp->curr.g_h);

	    	ap_sendmsg( WM_REDRAW, wp->owner->p_pid, handle,
			    wp->curr.g_x, wp->curr.g_y, wp->curr.g_w, 
			    wp->curr.g_h);
	     }
	     break;

	case WF_RESVD:	    /* old WMLIB has code, but doc says RESERVED */
	default:
	    ret = FALSE;
	    break;
    }

    return ret;
}


/*
 * Wm_set() - changes information of a window
 *	    - returns FALSE (0) if given handle is invalid
 *	    - returns TRUE (1) if everything is fine
 *
 */
	WORD
wm_set(handle, field, iw)
	REG WORD    handle;	    /* window handle */
	REG WORD    field;	    /* flag to identify what info to be changed */
	REG WORD    iw[];	    /* values to change to */
{
	REG WINDOW	*wp;	    /* pointer to window structure */
	WORD		ret;

	if ( ( field == WF_NEWDESK ) || ( field == WF_DCOLOR ) )
	  goto ws_1;

	if ((wp = srchwp(handle)) == ( WINDOW *)NULLPTR)
	  return FALSE;	

	if ( field == WF_COLOR )
	  goto ws_1;

	if ( handle != deskwind )
	{
	  if (!(currpd->p_type & AESSYSTEM))
	  {
	    if ( wp->owner != currpd )
	      return( FALSE );
	  }
	}
	else
	{			/* handle 0 can only do the WF_NEWDESK */
	  if ( field != WF_NEWDESK )
	    return( FALSE );
	}

ws_1:
	wm_update( 1 );
	ret = wmset( handle, field, iw );
	wm_update( 0 );	/* give up the window sync */
        return ret;
}


/*
 * Wm_find() - finds which window is under the mouse's x, y position
 *
 */
	WORD
wm_find(mx, my)
	WORD mx;		/* mouse's x position */
	WORD my;		/* mouse's y position */
{
    REG WINDOW  *wp;    /* pointer to window structure */

    for (wp = srchwp(gl_topw); wp; wp = srchwp(wp->under)) 
    {
      if ( inside( mx, my, ( GRECT *)&wp->curr.g_x ) )
	return (wp->handle);
    }
    return NIL;		/* return -1 if not on top of any window */
}




/*
 * Wm_calc() - calculates the x, y coordinates and width, height of a
 *		window's border area or work area
 *
 */
	WORD
wm_calc(type, kind, ix, iy, iw, ih, ox, oy, ow, oh)
WORD type;	/* the type of calculation to perform */
WORD kind;	/* components present in the window */
WORD ix;		/* input x-coordinate of window */
WORD iy;		/* input y-coordinate of window */
WORD iw;		/* input width of window */
WORD ih;		/* input height of window */
WORD *ox;	/* output x-coordinate of work/border area */
WORD *oy;	/* output y-coordinate of work/border area */
WORD *ow;	/* output width of work/border area */
WORD *oh;	/* output height of work/border area */
{
    REG WORD	tb, bb, lb, rb;
    REG	WORD	yinc, xinc;
    WORD	hparts, vparts;

    tb = bb = rb = 0;
    lb = 1;
	
    xinc = gl_wbox + (ADJ3DPIX << 1);
    yinc = gl_hbox + (ADJ3DPIX << 1);
	
    if (kind & (NAME | CLOSER | FULLER | SMALLER))
	tb += yinc;
    if (kind & INFO)
	tb += gl_hbox;
#ifdef MNBAR
    if (kind & MNBAR)
	tb += yinc;
#endif
    vparts = kind & (UPARROW | DNARROW | VSLIDE);
    hparts = kind & (LFARROW | RTARROW | HSLIDE);

    if ((kind & SIZER) && (!vparts && !hparts))
	rb += xinc;

    if (vparts)
	rb += xinc;

    if (hparts)
	bb += yinc;

    if ( !rb )	/* if no right elements */
      rb = 1;

    if ( !bb )	/* if no bottom elements */
      bb = 1;
	
    if ( !tb )	/* if no top elements	*/
      tb = 1;

					/* negate values to calc*/
					/*   Border Area	*/
    if (type == WC_BORDER) {
	lb = -lb;
	tb = -tb;
	rb = -rb;
	bb = -bb;						
    }

    *ox = ix + lb;
    *oy = iy + tb;
    *ow = iw - lb - rb;
    *oh = ih - tb - bb;

    return TRUE;	
}


/*
 * Wm_min() - calculates the min width and height of a window's border 
 *	      area
 *
 */
VOID
wm_min( wp, ow, oh )
	WINDOW	 	*wp;	/* window pointer */
	WORD 		*ow;	/* output width of work/border area */
	WORD 		*oh;	/* output height of work/border area */

{
    REG WORD	w1, w2, w3, h1, h2, h3;
    REG	WORD	yinc, xinc;
    WORD	hparts, vparts;
    REG	WORD	kind;	/* coponents present in the window */
    GRECT	rclip;

    kind = wp->kind;

    w1 = w2 = w3 = h1 = h2 = h3 = 0;	/* init to 0 cjg 06/01/93 */

    xinc = gl_wbox + (ADJ3DPIX << 1);
    yinc = gl_hbox + (ADJ3DPIX << 1);
	
    if ( kind & (NAME | CLOSER | FULLER | SMALLER) )
    {
	h1 += yinc;
	if ( kind & NAME )
	  w1 += xinc;

	if ( kind & CLOSER )
	  w1 += xinc;

	if ( kind & FULLER )
	  w1 += xinc;

	if (kind & SMALLER)
	  w1 += xinc;
    }

    if ( kind & INFO ) {
/*	h1 += yinc; */
	h1 += gl_hbox;	/* Changed from yinc to gl_hbox cause the */
			/* INFO line is NOT 3D... cgj 06/01/93    */
    }

#ifdef MNBAR
    if ( kind & MNBAR )
	h1 += yinc;
#endif
    /* Add in the height of the toolbar, if one exists
     * AND if the window is not iconified
     * The height includes any 3D, shadow etc effects.
     * cjg 05/27/93
     */
    if( wp->ad_tools && !wp->iconflag ) {
      WORD x, y;
#if 0
      ob_actxywh( ( LONG )wp->ad_tools, ROOT, &rclip );
#else
      ob_gclip((LONG)wp->ad_tools, ROOT, &x, &y,
	&rclip.g_x, &rclip.g_y, &rclip.g_w, &rclip.g_h);
#endif
      h1 += rclip.g_h;
    }

    vparts = kind & (UPARROW | DNARROW | VSLIDE);
    hparts = kind & (LFARROW | RTARROW | HSLIDE);

    if ( vparts )
	w2 += xinc;

    if ( hparts )
	h3 += yinc;

    if ( kind & UPARROW )
        h2 += yinc;

    if ( kind & DNARROW )
        h2 += yinc;

    if ( kind & VSLIDE )
        h2 += yinc;

    if ( kind & LFARROW )
	w3 += xinc;

    if ( kind & RTARROW )
	w3 += xinc;

    if ( kind & HSLIDE )
	w3 += xinc;

    if ( kind & SIZER ) 
    {	
	if ( (!vparts && !hparts) )
	{
	  w2 += xinc;
	  h2 += yinc;
	}

	if ( vparts )
	  h2 += yinc;
	
	if ( !vparts && hparts )  	
	  w3 += xinc;
    }

   *ow = max( ( w1 + w2 ), w3 );
   h2 =  max( h2, h3 );
   *oh = h2 + h1;
}


/*	
 * Wm_new() - Delete all the window structures and clean 
 *	      up the window update semaphore.  This 
 *	      routine is very critical, so don't call 
 *	      it when you are not sure.  You must call 
 *	      this guy right after you return from the 
 *	      child process.	Only at this moment the 
 *	      system can be able to recover itself.
 *
 * Comments:
 *	(Jul 23 91 ml.) This may need to be modified for
 * future multitasking system.
 *	
 */
	WORD
wm_new()
{
	wm_clspd( currpd, FALSE );
	return TRUE;
}


/*	Free all the window library	*/

	VOID
wm_free()
{
	REG MEMHDR	*mp;	/* pointer to memory header */
	MEMHDR		*next;
	
	/* Free all window structures */

	mp = wmhead;
	while( mp )
	{
	  next = mp->mnext;
	  dos_free( ( LONG )mp );
	  mp = next; 
	}

	/* Free all rectangle list structures */

	mp = rmhead;
	while( mp )
	{
	  next = mp->mnext;
	  dos_free( ( LONG )mp );
	  mp = next; 
	}
}


/*
 * Allocate a window structure for a new window.
 *
 *     Returns a pointer to an available window 
 * structure or NULLPTR if none is available.
 *
 */
	WINDOW
*newwp( VOID )
{
    WINDOW  *wp;	/* pointer to window structure */
    MEMHDR  *mp;	/* pointer to memory header */
    WORD    i;		/* count */
	
    if (wmtail->numused == NUMWIN) {
	if ((mp = (MEMHDR *)
		dos_xalloc((LONG)(NUMWIN*sizeof(WINDOW)+sizeof(MEMHDR)), 3)) 
	    == ( MEMHDR *)NULLPTR) {
	    Debug1( "Fail to do newwp\r\n" );
	    return( ( WINDOW *)NULLPTR);
	} else {
	
	    bfill( (NUMWIN*sizeof(WINDOW)+sizeof(MEMHDR)), 0, ( BYTE *)mp );

	    /* init window structures as available */
	    for (wp = (WINDOW *)(mp+1), i = 0; i < NUMWIN; i++, wp++) {
		wp->status.used = FALSE;
		wp->wwhere = mp;
	    }

	    wmtail->mnext = mp;
	    mp->mnext = ( MEMHDR *)NULLPTR;
	    wmtail = mp;
	    wmtail->numused = 1;
	    wp = (WINDOW *)(wmtail+1);
	}
    } else {
	for (wp = (WINDOW *)(wmtail+1); wp->status.used == TRUE; wp++)
	    ;

	wmtail->numused += 1;
    }

    wp->status.used = TRUE;
    return(wp);
}


/*
 * Allocate a window handle to a new window
 *
 *    Returns an available handle number, or FAILURE (-1) if
 * none is available.
 *
 */
	WORD
newhndl(nwp)
	REG WINDOW  *nwp;		    /* pointer to new window structure */
{
    REG	    WINDOW  *wp, *nxtwp;    /* pointers to window structure */
    WORD    found;

    /*
     * Starting from head of linked list, search for non-
     * consecutive handle numbers.  If two handle numbers
     * are found to be non-consecutive, the new handle is
     * the smaller number plus one.  If all handle numbers	
     * are consecutive, the new handle is the biggest number
     * plus one.
     *
     * Once an available handle number is found, insert the
     * new window structure into the linked list.
     */

    if (hhead == NIL) {			/* no created window */
	hhead = nwp->handle = 0;
	nwp->nxthndl = NIL;
    } else if (hhead) {			/* if head handle is not 0 */
	nwp->nxthndl = hhead;
	nwp->handle = hhead -= 1;
    } else {				/* have to search through list */
	wp = srchwp(hhead);
	found = FALSE;
	while (wp->nxthndl != NIL && !found) {
	    nxtwp = srchwp(wp->nxthndl);
	    if (nxtwp->handle - wp->handle > 1)
		found = TRUE;
	    else
		wp = nxtwp;
	}
	nwp->nxthndl = wp->nxthndl;
	wp->nxthndl = nwp->handle = wp->handle + 1;
    }
    return(nwp->handle);
}


/*
 * Store the given window structure into the database
 * of window structures.
 *
 */
	VOID
storewp(wp)
	WINDOW	*wp;
{
    WORD    bucket;		/* bucket number in hash table */
	
    bucket = wp->handle % NUMWIN;
    wp->wnext = hashtbl[bucket];
    hashtbl[bucket] = wp;
}




/*
 * totop() - tops the given window, and untops the current top window
 *	     (if there is one.)
 *
 */
	WORD
totop( handle, caller )
	WORD	handle;		/* handle of window to be topped */
	WORD	caller;		/* WMOPEN: called by wm_open() */
				/* WMCLOSE: called by wm_close()  */
				/* WMSET: called by wm_set()  */
{
	REG WINDOW  	*ntwp;
	WINDOW		*onwp, *unwp, *twp;
	GRECT		temp, inter, temp2;
	WORD		nxtw,notset;
	PD		*p;

    /* search for window structure of the given handle */

    if ((ntwp = srchwp(handle)) == ( WINDOW *)NULLPTR
	|| (caller == WMSET && !ntwp->status.opened))
	return FALSE;
	
    if ( caller == WMSET )
    {
	notset = TRUE;
	for (nxtw = ntwp->ontop; nxtw != NIL; nxtw = onwp->ontop ) 
	{
	    onwp = srchwp(nxtw);
	    inter = ntwp->curr;
	    inter.g_w += SHADOW;
	    inter.g_h += SHADOW;		 
	    temp2 = onwp->curr;
	    temp2.g_w += SHADOW;
	    temp2.g_h += SHADOW; 		 
	    if (rc_intersect(&temp2, &inter))
	    {
	      if ( notset )
	      {
	 	temp = inter;
		notset = FALSE;	
	      }
	      else	
		rc_union( &inter, &temp );
	    }
	}
    }


    twp = ( WINDOW *)NULLPTR;

    /* maintain linked list of opened windows */

    if ( gl_topw == NIL ) 
    {
	botw = handle;
    } else if (caller != WMCLOSE) {    /* orig. top window wasn't closed */
	if (caller == WMSET) {
	    onwp = srchwp(ntwp->ontop);
	    if ((onwp->under = ntwp->under) != NIL) {
		unwp = srchwp(ntwp->under);
		unwp->ontop = ntwp->ontop;
	    }
	}
	twp = srchwp(gl_topw);
	twp->ontop = handle;
    	ntwp->under = gl_topw;
    }

    ntwp->ontop = NIL;
    gl_topw = handle;

    if ( twp ) 	    /* draw the untopped window if there is one */
    {
      activate(twp, NO);
      w_clipdraw(twp, W_BOX, ( GRECT *)NULLPTR);	/* changed 6/16/92	*/
      if ( twp->handle )	/* send untopped message */
        ap_sendmsg( WM_UNTOPPED, twp->owner->p_pid, twp->handle,
	    	    0, 0, 0, 0 );
    }

    /* draw border of the newly topped window */

    activate(ntwp, YES);		
    w_clipdraw(ntwp, W_BOX, ( GRECT *)NULLPTR);	/* changed 6/16/92	*/

    if ( gl_topw != phanwind )	
    {
      p = srchwp(gl_topw)->owner;
      if ( !( gl_kbid = p->p_pid ) )
	Debug1( "Key owner is zero 5\r\n" );

    }	
    /* draw content of newly topped window if it's not the background  */

    if ( handle != deskwind )
    {
      if ( caller == WMOPEN )
      {
	w_tooldraw( ntwp, W_BOX, &ntwp->curr );
	ap_sendmsg( WM_REDRAW, ntwp->owner->p_pid, handle,
	    ntwp->curr.g_x, ntwp->curr.g_y, ntwp->curr.g_w, ntwp->curr.g_h);
      }
      else
      if ( ( caller == WMSET ) && ( !notset ) )
      {
	w_tooldraw( ntwp, W_BOX, &temp );
	ap_sendmsg( WM_REDRAW, ntwp->owner->p_pid, handle,
	    temp.g_x, temp.g_y, temp.g_w, temp.g_h);
      }

   }

    return TRUE;
}



/*
 * tobot() - make the given window to be the bottom window, and top
 *	     the next one if necessary
 *	   - the DESKTOP window is considered to be the "real" bottom
 *	     window at all times, and does not count in this function
 *
 */
WORD
tobot(handle)
WORD	handle;		/* handle of window to be topped */
{
	REG WINDOW  	*nbwp, *onbwp, *unnbwp;
	WINDOW		*bwp, *onnbwp;
	GRECT		dirty;
	PD		*p;
	
    /* search for window structure of the given handle */
    if ((nbwp = srchwp(handle)) == ( WINDOW *)NULLPTR || (!nbwp->status.opened))
	return FALSE;

    bwp = srchwp(deskwind);
    onbwp = srchwp(bwp->ontop);
    if (onbwp->handle == handle)
        return TRUE;

    unnbwp = srchwp(nbwp->under);
			    /* need to top another window? */
    if (handle == gl_topw) 
    {
	gl_topw = unnbwp->handle;

	/* change border of newly bottomed window */
	activate(nbwp, NO);
	w_clipdraw(nbwp, W_BOX, ( GRECT *)NULLPTR);

	/* draw border of the newly topped window */
	activate(unnbwp, YES);
	w_clipdraw(unnbwp, W_BOX, ( GRECT *)NULLPTR);

	ap_sendmsg( WM_ONTOP, unnbwp->owner->p_pid, gl_topw, 0, 0, 0, 0);

/*	w_setactive();	*/

       if ( gl_topw != phanwind )	
       {
         p = srchwp(gl_topw)->owner;
         if ( !( gl_kbid = p->p_pid ) )
	   Debug1( "Key owner is zero 5\r\n" );
       }	
    } 
    else 
    {
	onnbwp = srchwp(nbwp->ontop);
	onnbwp->under = nbwp->under;
    }

    /* maintain linked list of opened windows */

    unnbwp->ontop = nbwp->ontop;
    nbwp->under = onbwp->under;
    nbwp->ontop = bwp->ontop;
    onbwp->under = bwp->ontop = handle;

    dirty = nbwp->curr;
    dirty.g_w += SHADOW;
    dirty.g_h += SHADOW;
    w_drawchange(&dirty, handle,NIL);
    return TRUE;
}


/*
 * Activate() - change appearance of window components depending on
 *		whether it is active (topped) or not.
 */
	VOID
activate(wp, topped)
	REG WINDOW  *wp;    /* pointer to window structure to be modified */
	WORD	    topped; /* YES: activate window components */
		    /* NO:  deactivate window components */
{
    REG	WORD	kind;		/* window kind */
    WORD	hparts, vparts;

    setcol(wp, W_BOX, topped);

    if ((kind = wp->kind) & TPARTS) {
	if ((kind = wp->kind) & NAME) {
/*	    if (topped)
		wp->obj[W_NAME].ob_state = NORMAL;
	    else
		wp->obj[W_NAME].ob_state = DISABLED;
*/
	    setcol(wp, W_NAME, topped);
	}

	if (kind & CLOSER) {
	    setcol(wp, W_CLOSER, topped);
	}

        if (kind & FULLER) {
	    setcol(wp, W_FULLER, topped);
	}

	if (kind & SMALLER) {
	    setcol(wp, W_SMALLER, topped);
	}
    }

    if (kind & INFO)
	setcol(wp, W_INFO, topped);

    hparts = kind & HPARTS;
    vparts = kind & VPARTS;

    if (kind & SIZER) {
	setcol(wp, W_SIZER, topped);

	if (!hparts && !vparts) {
	    setcol(wp, W_VBAR, topped);
	    setcol(wp, W_HBAR, topped);
	}
    }

    if (vparts) {
	setcol(wp, W_VBAR, topped);

	if (kind & UPARROW) {
	    setcol(wp, W_UPARROW, topped);
	}

	if (kind & DNARROW) {
	    setcol(wp, W_DNARROW, topped);
	}

	if (kind & VSLIDE) {
	    setcol(wp, W_VSLIDE, topped);
	    setcol(wp, W_VELEV, topped);
	}
    }

    if (hparts) {
	setcol(wp, W_HBAR, topped);

	if (kind & LFARROW) {
	    setcol(wp, W_LFARROW, topped);
	}

	if (kind & RTARROW) {
	    setcol(wp, W_RTARROW, topped);
	}

	if (kind & HSLIDE) {
	    setcol(wp, W_HSLIDE, topped);
	    setcol(wp, W_HELEV, topped);
	}
    }

#ifdef MNBAR
    if (kind & MNBAR)
	setcol(wp, W_MNBAR, topped);
#endif
}



/*
 * Setcol() - set the color of an object.
 */
	VOID
setcol(wp, ndx, topped)
	REG WINDOW  *wp;	/* pointer to window structure */
	WORD	    ndx;	/* index into object structure */
	WORD	    topped;	/* YES: top window color */
{
    if  ( ( wp->obj[ndx].ob_type & 0x00FF ) == G_BOXTEXT) {
	if (topped)
	    ((TEDINFO *)(wp->obj[ndx].ob_spec))->te_color = wp->tcolor[ndx];
	else
	    ((TEDINFO *)(wp->obj[ndx].ob_spec))->te_color = wp->bcolor[ndx];
    } else {
	wp->obj[ndx].ob_spec &= 0xffff0000L;
	if (topped)
	    wp->obj[ndx].ob_spec |= ((LONG)wp->tcolor[ndx] & 0x0000ffffL);
	else
	    wp->obj[ndx].ob_spec |= ((LONG)wp->bcolor[ndx] & 0x0000ffffL);
    }
}



/*
 * W_adjust() - adjust x, y, w and h of each component in the 
 *		given window with the window's x, y, w and h.
 */
VOID
w_adjust(wp, rect, wflag)
REG WINDOW  *wp;	/* pointer to window structure */
REG GRECT   *rect;	/* pointer to window's coords and dimensions */
WORD	    wflag;	/* FALSE - Check for a move  */
			/* TRUE  - Don't check for a move*/
{
    WORD	ulx;	    /* x offset from upper left corner */
    WORD	uly;	    /* y offset from upper left corner */
    WORD	urx;	    /* x offset from upper right corner */
    WORD	ury;	    /* y offset from upper right corner */
    WORD	llx;	    /* x offset from lower left corner */
    WORD	lly;	    /* y offset from lower left corner */
    WORD	lrx;	    /* x offset from lower right corner */
    WORD	lry;	    /* y offset from lower right corner */
    WORD	inx, iny;   /* x and y increments */
    WORD	blen;	    /* length of base bar */
    UWORD	sz;	    /* slider size */
    WORD	w3dbox, h3dbox;
    GRECT	drect;	    /* offsets for toolbar cjg -05/27/93 */

    /***
     *
     * In the old Window Library, after the first wm_open(), 
     * prev_xywh = curr_xywh = rect;
     *
     ***/

    /* init previous and current window dimensions */
    wp->prev = wp->curr;
    wp->curr = *rect;

    /* init dimensions of window background */
    w_obrect(wp, W_BOX, rect->g_x, rect->g_y, rect->g_w, rect->g_h);

    /* reinit work area if it is just a move */
    if (!wflag && (rect->g_w == wp->prev.g_w) && (rect->g_h == wp->prev.g_h)) {
	/* initialize window work area */
	wp->obj[W_WORK].ob_x -= (wp->prev.g_x - rect->g_x);
	wp->obj[W_WORK].ob_y -= (wp->prev.g_y - rect->g_y);
	/* Initialize the toolbar for a move - cjg 05/27/93
	 * We use the displacement of prev and rect to offset to
         * our new position.
	 */
	if( wp->ad_tools && !wp->iconflag ) {
 	  wp->ad_tools[ ROOT ].ob_x -= ( wp->prev.g_x - rect->g_x );
 	  wp->ad_tools[ ROOT ].ob_y -= ( wp->prev.g_y - rect->g_y );
	}
	return;
    }

    /* init offsets from the four corners and the x and y increments */
    ulx = uly = urx = ury = llx = lly = lrx = lry = 0;
    w3dbox = gl_wbox + (ADJ3DPIX << 1);
    h3dbox = gl_hbox + (ADJ3DPIX << 1);

    inx = w3dbox;
    iny = h3dbox;

    if (wp->kind & TPARTS) {
	w_obrect(wp, W_TITLE, 0, 0, rect->g_w, h3dbox);
	uly = ury = iny;

	if (wp->kind & CLOSER) {
	    w_obrect(wp, W_CLOSER, ADJ3DPIX, ADJ3DPIX, gl_wbox, gl_hbox);
	    ulx = inx;
	}

	if (wp->kind & FULLER) 
	{
	    w_obrect(wp, W_FULLER, (rect->g_w-w3dbox+ADJ3DPIX), ADJ3DPIX, gl_wbox, 
		gl_hbox);
	    urx = inx;
	}

	if (wp->kind & SMALLER)
	{
	    w_obrect(wp, W_SMALLER, (rect->g_w-urx-w3dbox+ADJ3DPIX), ADJ3DPIX,
		gl_wbox, gl_hbox);
	    urx += inx;
	}
	if (wp->kind & NAME || wp->kind & MOVER) 
	{
	    sz = rect->g_w-ulx-urx-(ADJ3DPIX << 1);
	    w_obrect(wp, W_NAME, (ulx+ADJ3DPIX), ADJ3DPIX, sz, gl_hbox);
	}
    }

    if (wp->kind & INFO) {
	w_obrect(wp, W_INFO, 0, uly, rect->g_w, gl_hbox);
	uly = ury += gl_hbox;
    }

    /* Add in support for a ToolBar Tree cjg -05/26/93
     * Position this under the INFO bar.
     * This tree is added in if 'ad_tools' is NON-ZERO AND if
     * the window is not currenty icondified.
     */
    if( wp->ad_tools && !wp->iconflag ) {
	
	/* Get the offsets of x,y,w,h to account for the 
	 * ObFlags, Border Width and 3D effect...
	 */
	ob_dxywh( ( LONG )wp->ad_tools, ROOT,
		  &drect.g_x, &drect.g_y,
		  &drect.g_w, &drect.g_h );

	wp->ad_tools[ ROOT ].ob_x = rect->g_x + 1 - drect.g_x;
	wp->ad_tools[ ROOT ].ob_y = rect->g_y + uly - drect.g_y;
	wp->ad_tools[ ROOT ].ob_width = rect->g_w - SHADOW - drect.g_w;
	uly = ury += wp->ad_tools[ ROOT ].ob_height + drect.g_h;
    }

#ifdef MNBAR
    if (wp->kind & MNBAR) {
	w_obrect(wp, W_MNBAR, 0, uly, rect->g_w, h3dbox);
	uly = ury += iny;
    }
#endif

    urx = 0;	/* reinitialize upper right x offset */

    if ((hparts = wp->kind & HPARTS))
	lry = iny;
    if ((vparts = wp->kind & VPARTS))
	lrx = inx;

    if (wp->kind & SIZER) 
    {
	w_obrect(wp, W_SIZER, (rect->g_w-w3dbox+ADJ3DPIX), (rect->g_h-h3dbox+ADJ3DPIX),
		gl_wbox, gl_hbox);
	lry = iny;
	lrx = inx;

	if (!hparts && !vparts) 
	{
	    w_obrect(wp, W_VBAR, (rect->g_w-w3dbox), ury, w3dbox, 
		(rect->g_h-ury-lry));
	    urx = inx;
	}
    } 
    else
    {	 
	if (hparts && vparts)	/* if has horizontal or vertical parts ,we still need sizer */ 
	{
	  w_obrect(wp, W_SIZER, (rect->g_w-w3dbox+ADJ3DPIX), 
		(rect->g_h-h3dbox+ADJ3DPIX), gl_wbox, gl_hbox);
	  lry = iny;
	  lrx = inx;
	}
    }

    if (vparts) 
    {
	blen = rect->g_h - ury - lry;
	urx = inx;
	w_obrect(wp, W_VBAR, (rect->g_w-w3dbox), ury, w3dbox, blen);

	if (wp->kind & UPARROW) 
	{
	    w_obrect(wp, W_UPARROW, ADJ3DPIX, ADJ3DPIX, gl_wbox, gl_hbox);
	    ury += iny;
	}

	if (wp->kind & DNARROW) 
	{
	    w_obrect(wp, W_DNARROW, ADJ3DPIX, (blen-h3dbox+ADJ3DPIX), gl_wbox, 
		gl_hbox);
	    lry += iny;
	}

	if (wp->kind & VSLIDE) 
	{
	    sz = rect->g_h - ury - lry; 
	    w_obrect(wp, W_VSLIDE, 0, (ury-uly), w3dbox, sz);

	    /* Apr-21-92  ml. Use wp->hslsz to determine size of elevator */
	    if (wp->vslsz == -1)
	    {
	       w_obrect(wp, W_VELEV, ADJ3DPIX, ADJ3DPIX, gl_wbox, 
			gl_hbox - (ADJ3DPIX << 1) );
	    }
	    else
	    {
	        sz = ( UWORD )( ( (LONG)sz * (LONG)wp->vslsz ) / 1000L );
		if (sz < gl_hbox)
		  sz = gl_hbox;
		if ( sz > ( ADJ3DPIX << 1 ) ) 	
		  sz = sz - (ADJ3DPIX << 1);
		w_obrect(wp, W_VELEV, ADJ3DPIX, ADJ3DPIX, gl_wbox, 
		    sz );
	    }
	}
    }


    if (hparts) 
    {
	blen = rect->g_w - lrx;
	lly = iny;
	w_obrect(wp, W_HBAR, 0, (rect->g_h-h3dbox), blen, h3dbox);

	if (wp->kind & LFARROW) {
	    w_obrect(wp, W_LFARROW, ADJ3DPIX, ADJ3DPIX, gl_wbox, gl_hbox);
	    llx = inx;
	}

	if (wp->kind & RTARROW) {
	    w_obrect(wp, W_RTARROW, (blen-w3dbox+ADJ3DPIX), ADJ3DPIX, gl_wbox, 
		gl_hbox);
	    lrx += inx;
	}

	if (wp->kind & HSLIDE) 
	{
	    sz = rect->g_w - llx - lrx;
	    w_obrect(wp, W_HSLIDE, llx, 0, sz, h3dbox);

	    /* Apr-21-92  ml. Use wp->hslsz to determine size of elevator */
	    if (wp->hslsz == -1)
	    {	
	      w_obrect( wp, W_HELEV, ADJ3DPIX, ADJ3DPIX, 
			gl_wbox - (ADJ3DPIX << 1), gl_hbox );
	    } 	
	    else
	    {
		sz = ( UWORD )(( (LONG)sz * (LONG)wp->hslsz ) / 1000L );
		if (sz < gl_wbox)
		  sz = gl_wbox;
		if ( sz > ( ADJ3DPIX << 1 ) ) 	
		  sz = sz - (ADJ3DPIX << 1);
		w_obrect(wp, W_HELEV, ADJ3DPIX, ADJ3DPIX, sz, gl_hbox );
	    }
	}
    }

    /* initialize window work area */

    if ( !uly )	/* if no element */
      uly = 1;
    if ( !lly )
      lly = 1;
    if ( !urx )
      urx = 1;

    w_rect((GRECT *)&(wp->obj[W_WORK].ob_x), (rect->g_x+1), 
	    (rect->g_y+uly), (rect->g_w-urx-1), (rect->g_h-uly-lly));
}


/*
 * W_clipdraw() - set clipping according to the rectangle list
 *		  of the current size of the window, or the 
 *		  clipping rectangle passed in, and draw the
 *		  object specified.
 */
	VOID
w_clipdraw(wp, obj, pc)
	WINDOW	*wp;	    /* pointer to window structure */
	WORD	obj;	    /* object to be drawn */
	GRECT	*pc;	    /* pointer to clipping rectangle */
{
    REG RLIST	*rl;
    GRECT	rclip;
    RLIST	*rlist;
		
    if (wp->obj[obj].ob_flags & HIDETREE)
	return;

    gsx_moff();

    rlist = genrlist(wp->handle, WF_CURRXYWH);

    for ( rl = rlist; rl; rl = rl->rnext ) 
    {
			/* if no clipping rectangle given, clip to screen and itself */
	rclip = rl->rect;

	if ( !rc_intersect( &gl_rfull, &rclip ) )	/* clip to screen */
	   continue;

	if ( !pc || rc_intersect(pc, &rclip ) ) 
	{
	    gsx_sclip(&rclip);
	    ob_draw( ( LONG )wp->obj, obj, MAX_DEPTH);
	}
    }

    gsx_mon();

    if ( rlist )
	delrect( ( RLIST *)0L, ( BYTE *)rlist );
}



/*
 * W_drawchange() - draw the borders of opened windows which 
 *		    intersects with the dirty area, and send
 *		    redraw messages to those windows
 */
	VOID
w_drawchange(dirty, skip, stop)
	GRECT	*dirty;		/* rectangle of dirty area */
	UWORD	skip,stop;	/* window to be skipped */
{
	UWORD   handle;		/* window handle */
	GRECT   exposed;	/* area to be drawn */
	REG WINDOW  *wp;	/* pointer to window structure */
	WORD	receiver;
	OBJECT	*obj;
	WORD	root;
	
    for (handle = botw; handle != stop; handle = wp->ontop) 
    {
	wp = srchwp(handle);

	if (handle == skip)
		continue;

	exposed = wp->curr;
	exposed.g_w += SHADOW;
	exposed.g_h += SHADOW;

	if ( rc_intersect(dirty, &exposed) ) 
	{
	  w_clipdraw(wp, W_BOX, &exposed);
	  w_tooldraw( wp, W_BOX, &exposed );

	  if ( handle )			/* if not background window */
	  {
	    if ( wp->owner == currpd )
	    {
	      if ( wp->w_msg[0] )	/* union with the old rectangles */
		rc_union( &exposed, ( GRECT *)&wp->w_msg[4] );
	      else
	      {	 	
				/* if send to itself then send the redraw	*/
	        wp->w_msg[0] = WM_REDRAW;	/* msg to win buffer	*/
	        wp->w_msg[1] = currpd->p_pid;	/* instead to prevent	*/
	        wp->w_msg[2] = 0;		/* dead lock 		*/
	        wp->w_msg[3] = handle;
	        wp->w_msg[4] = exposed.g_x;
	        wp->w_msg[5] = exposed.g_y;
	        wp->w_msg[6] = exposed.g_w;
	        wp->w_msg[7] = exposed.g_h;
	        continue;
	      }
	    }
	    else
	      receiver = wp->owner->p_pid;
	  }
	  else
	  {
				/* Redraw the dirty window	*/
	    if ( !gl_newdesk )
	    {
	      obj = gl_wtree;
	      root = ROOT;
	    }
	    else
	    {
	      obj = gl_newdesk;
	      root = gl_newroot;
	    }
	
	    dk_redraw( obj, root, &exposed );
	    continue;	
	  }

	  ap_sendmsg( WM_REDRAW, receiver, handle, exposed.g_x, 
		      exposed.g_y, exposed.g_w, exposed.g_h);
	}
    }
}



/*
 * W_bld() - initialize a window component and add it to the object
 *		tree of the window structure.
 *
 */
	VOID
w_bld(wp, ob, type, parent, spec, is3d)
	WINDOW	 *wp;
	REG WORD ob;
	WORD	 type, parent;
	LONG	 spec;
	WORD	 is3d;
{
    REG OBJECT  *obaddr;

    /* initialize object */
    obaddr = &(wp->obj[ob]);
    obaddr->ob_next = obaddr->ob_head = obaddr->ob_tail = NIL;
    obaddr->ob_type = type;
    obaddr->ob_flags = is3d ? (IS3DOBJ|IS3DACT) : 0;
    obaddr->ob_state = NORMAL;
    obaddr->ob_spec = spec;
    if (type != G_BOXTEXT)
	obaddr->ob_spec |= ((LONG)wtcolor[ob] & 0x0000ffffL);

    /* add object to tree */
    if (parent != NIL)
	ob_add( ( LONG )wp->obj, parent, ob);
}


/*
 *	Hide window parts for iconifying window.
 *	Only the title bar is present when a window gets icnonified.
 */

VOID
w_hideparts(wp)
WINDOW	*wp;
{
	OBJECT		*obaddr;
	WORD		hparts, vparts;
	WORD		kind;

	/* initialize object */
    	obaddr = wp->obj;
	kind = wp->kind;

	hparts = kind & HPARTS;	/* mask for vertical slider elements */
        vparts = kind & VPARTS;	/* mask for horizontal slider elements */

	if (kind & CLOSER)
		ob_delete((LONG)obaddr, W_CLOSER);
	if (kind & FULLER)
		ob_delete((LONG)obaddr, W_FULLER);
	if (kind & SMALLER)
		ob_delete((LONG)obaddr, W_SMALLER);
	if (kind & INFO)
		ob_delete((LONG)obaddr, W_INFO);
	if (kind & SIZER) {
		ob_delete((LONG)obaddr, W_SIZER);

		if (!hparts && !vparts) {
			ob_delete((LONG)obaddr, W_VBAR);
		}
    	} else if (hparts && vparts) {
		ob_delete((LONG)obaddr, W_SIZER);
    	}

	if (vparts) {
		ob_delete((LONG)obaddr, W_VBAR);

		if (kind & UPARROW) {
			ob_delete((LONG)obaddr, W_UPARROW);
		}

		if (kind & DNARROW) {
			ob_delete((LONG)obaddr, W_DNARROW);
		}

		if (kind & VSLIDE) {
			ob_delete((LONG)obaddr, W_VSLIDE);
			ob_delete((LONG)obaddr, W_VELEV);
		}
    	}

	if (hparts) {
		ob_delete((LONG)obaddr, W_HBAR);

		if (kind & LFARROW) {
			ob_delete((LONG)obaddr, W_LFARROW);
		}

		if (kind & RTARROW) {
			ob_delete((LONG)obaddr, W_RTARROW);
		}

		if (kind & HSLIDE) {
			ob_delete((LONG)obaddr, W_HSLIDE);
			ob_delete((LONG)obaddr, W_HELEV);
		}
    	}

}
/*
 *	Show window parts for uniconified window.
 */

VOID w_showparts(wp)
WINDOW	*wp;
{
	REG OBJECT  	*obaddr;
	WORD		hparts, vparts;
	WORD		kind;
	/* initialize object */
    	obaddr = wp->obj;
	kind = wp->kind;

	hparts = kind & HPARTS;	/* mask for vertical slider elements */
        vparts = kind & VPARTS;	/* mask for horizontal slider elements */

	if (kind & CLOSER)
		ob_add((LONG)obaddr, W_TITLE, W_CLOSER);
	if (kind & FULLER)
		ob_add((LONG)obaddr, W_TITLE, W_FULLER);
	if (kind & SMALLER)
		ob_add((LONG)obaddr, W_TITLE, W_SMALLER);
	if (kind & INFO)
		ob_add((LONG)obaddr, W_BOX, W_INFO);
	if (kind & SIZER) {
		ob_add((LONG)obaddr, W_BOX, W_SIZER);

		if (!hparts && !vparts) {
			ob_add((LONG)obaddr, W_BOX, W_VBAR);
		}
    	} else if (hparts && vparts) {
		ob_add((LONG)obaddr, W_BOX, W_SIZER);
    	}

	if (vparts) {
		ob_add((LONG)obaddr, W_BOX, W_VBAR);

		if (kind & UPARROW) {
			ob_add((LONG)obaddr, W_VBAR, W_UPARROW);
		}

		if (kind & DNARROW) {
			ob_add((LONG)obaddr, W_VBAR, W_DNARROW);
		}

		if (kind & VSLIDE) {
			ob_add((LONG)obaddr, W_VBAR, W_VSLIDE);
			ob_add((LONG)obaddr, W_VSLIDE, W_VELEV);
		}
    	}

	if (hparts) {
		ob_add((LONG)obaddr, W_BOX, W_HBAR);

		if (kind & LFARROW) {
			ob_add((LONG)obaddr, W_HBAR, W_LFARROW);
		}

		if (kind & RTARROW) {
			ob_add((LONG)obaddr, W_HBAR, W_RTARROW);
		}

		if (kind & HSLIDE) {
			ob_add((LONG)obaddr, W_HBAR, W_HSLIDE);
			ob_add((LONG)obaddr, W_HSLIDE, W_HELEV);
		}
    	}

	if (wp->handle != gl_topw)
		activate(wp, NO);
	else
		activate(wp, YES);
}
	VOID
w_obrect(wp, ob, obx, oby, obw, obh)
	WINDOW	*wp;
	WORD	ob;
	WORD	obx, oby, obw, obh;
{
    REG OBJECT  *obaddr;

    obaddr = &(wp->obj[ob]);
    obaddr->ob_x = obx;
    obaddr->ob_y = oby;
    obaddr->ob_width = obw;
    obaddr->ob_height = obh;
}


	VOID
w_rect(raddr, gx, gy, gw, gh)
	REG GRECT   *raddr;
	WORD	    gx, gy, gw, gh;
{
    raddr->g_x = gx;
    raddr->g_y = gy;
    raddr->g_w = gw;
    raddr->g_h = gh;
}


	VOID
w_ted(tedaddr, ptext, just, color)
	REG TEDINFO *tedaddr;
	BYTE	*ptext;
	WORD	just, color;
{
				/* changed 2/28/92	*/
    nstrcpy( ptext, ( BYTE *)tedaddr->te_ptext, 128 );
    tedaddr->te_just = just;
    tedaddr->te_color = color;
    tedaddr->te_txtlen = strlen(ptext);
    tedaddr->te_font = IBM;
    tedaddr->te_thickness = 1;
    tedaddr->te_tmplen = 0;
}


/*
 * Ap_sendmsg() - send message to current process
 */
	VOID
ap_sendmsg( type, towhom, w3, w4, w5, w6, w7)
	WORD	type, towhom;
	WORD	w3, w4, w5, w6, w7;
{
	WORD	ap_msg[8];	

	ap_msg[0] = type;
	ap_msg[1] = aesid;
	ap_msg[2] = 0;
	ap_msg[3] = w3;
	ap_msg[4] = w4;
	ap_msg[5] = w5;
	ap_msg[6] = w6;
	ap_msg[7] = w7;
	ap_rdwr( AQWRT, towhom, EV_BUFSIZE, ( BYTE *)&ap_msg[0] );
}



/*	Open a phantom window	*/

	VOID
openphanwind( p )
	PD	*p;
{
	if ( !wmopen( phanwind, &gl_offscreen ) )
          wmset( phanwind, WF_TOP, ( WORD *)( (GRECT*)0) );

	if ( !p )		/* in case some one does a mn_bar 0 */
	  p = currpd;

	srchwp( phanwind )->cowner = p;	
	gl_kbid = p->p_pid;
}


/*	
 *	Given a process, look for its top window
 *	Excluding the background window
 */

	WORD
w_tophandle( p )
	PD	*p;
{
	REG WINDOW	*win;

	if ( !p )
	  return( -1 );

	win = wm_top();

	while( win )
	{
	  if ( ( win->owner == p ) && win->handle && win->status.opened )
	     return( win->handle );
	  else
	  {
	    if ( win->under != NIL )
              win = srchwp( win->under );
	    else
	      break;
	  }
	}
	
	return( -1 );
}


/*	Read the window system redraw message	*/

	WORD
rd_wmmsg( p, buffer )
	PD		*p;
	WORD		buffer[];
{
	WORD		i;
	REG WINDOW	*win;

	for ( i = 0; i < NUMWIN; i++ )
	{
	  if ( win = hashtbl[i] )
	  {
	    while( win )
	    {
	      if ( ( win->owner == p ) && ( win->w_msg[0] ) )
	      {
		LWCOPY( buffer, &win->w_msg[0], MSG_SIZE );
		win->w_msg[0] = 0;
		return( TRUE );
	      }

	      win = win->wnext;
	    }
	  }
	}
	return( FALSE );

}



	VOID
dk_newdraw( px )
	GRECT	*px;
{
	GRECT	pt;
	PARMBLK	par;
	GRECT	temp;

	Debug1( "Dk_newdraw\r\n" );

	*(WORD *)(&((USERBLK *)aesDDD)->ub_parm) = gl_handle;
	gsx_moff();

	par.pb_parm = ((USERBLK *)aesDDD)->ub_parm;
	Debug1( "Dk_resdraw vdi handle is " );
	Ndebug1( (LONG)gl_handle );
	par.pb_prevstate = NORMAL;
	par.pb_currstate = NORMAL;
	rc_copy( &gl_wtree->ob_x, &par.pb_x );
	wm_get( deskwind, WF_FIRSTXYWH, ( WORD *)&pt, ( WORD *)&temp );

	while( pt.g_w && pt.g_h )
	{
	  if ( rc_intersect( px, &pt ) )
	  {
	    gsx_sclip( &pt );
	    rc_copy( ( WORD *)&pt, &par.pb_xc );
	    far_call( ( WORD(*)())aesDDD->ub_code, ( LONG )&par );
	  }

	  wm_get( deskwind, WF_NEXTXYWH, ( WORD *)&pt, ( WORD *)&temp );
	}

	gsx_mon();
}


/*	Redraw the desktop background	*/

	VOID
dk_redraw( obj, root, px )
	OBJECT	*obj;
	WORD	root;
	GRECT	*px;
{
	GRECT		pt;
	GRECT		temp;
	BYTE		*spec;
	WORD		type,set;

	gsx_moff();

	set = FALSE;

	if ( ( aesDDD ) && ( obj[0].ob_type != G_USERDEF ) )
	{
	  type = obj[0].ob_type;	/* swap the new user define background */
	  spec = ( BYTE *)obj[0].ob_spec;
	  obj[0].ob_type = G_USERDEF;
	  obj[0].ob_spec = ( LONG )aesDDD;
	  set = TRUE;
	}

	wm_get( deskwind, WF_FIRSTXYWH, ( WORD *)&pt, ( WORD *)&temp );

	while( pt.g_w && pt.g_h )
	{
	  if ( rc_intersect( px, &pt ) )
	  {
	    gsx_sclip( &pt );
	    ob_draw( ( LONG )obj, root, MAX_DEPTH );
	  }

	  wm_get( deskwind, WF_NEXTXYWH, ( WORD *)&pt, ( WORD *)&temp );
	}

	if ( set )
	{			/* restore the background	*/
	  obj[0].ob_type = type;
	  obj[0].ob_spec = ( LONG )spec;	
	}

	gsx_mon();
}

          
/*
 * w_tooldraw() - REDRAW the TOOLBAR AREA
 *		  set clipping according to the rectangle list
 *		  of the current size of the window, or the 
 *		  clipping rectangle passed in, and draw the
 *		  object specified.
 */
	VOID
w_tooldraw(wp, obj, pc)
	WINDOW	*wp;	    /* pointer to window structure */
	WORD	obj;	    /* object to be drawn */
	GRECT	*pc;	    /* pointer to clipping rectangle */
{
    REG RLIST	*rl;
    GRECT	rclip;
    RLIST	*rlist;
		
    if (wp->obj[obj].ob_flags & HIDETREE)
	return;

    /* If not W_BOX OR no toolbar or iconified, just return */
    if( ( obj != W_BOX ) || !wp->ad_tools || wp->iconflag )
        return;

    gsx_moff();

    rlist = genrlist(wp->handle, WF_TOOLBAR );

    for ( rl = rlist; rl; rl = rl->rnext ) 
    {
			/* if no clipping rectangle given, clip to screen and itself */
	rclip = rl->rect;

	if ( !rc_intersect( &gl_rfull, &rclip ) )	/* clip to screen */
	   continue;

	if ( !pc || rc_intersect(pc, &rclip ) ) 
	{

	    gsx_sclip(&rclip);

	    /* TOOLBAR Support.	cjg 05/26/93 */
	    ob_draw( ( LONG )wp->ad_tools, ROOT, MAX_DEPTH );
	}
    }

    gsx_mon();

    if ( rlist )
	delrect( ( RLIST *)0L, ( BYTE *)rlist );
}
          

/*
 *	Icon Slot Manager
 *	+++ HMK 7/18/93
 */

BYTE *allocIcnslots()
{
	REG BYTE *ip, *p;
	REG WORD i;
	WORD	 size;


Debug1("gl_rfull.g_w="); Ndebug1((LONG)gl_rfull.g_w);
Debug1("gl_rfull.g_h="); Ndebug1((LONG)gl_rfull.g_h);

	size = (gl_rfull.g_w / WINICON_W) * (gl_rfull.g_h / WINICON_H);

	ip = p = (BYTE *) dos_xalloc((LONG) size, 3);

	for (i = 0; i < size; i++)
		*p++ = 0;

	return ip;
}

	VOID
freeIcnslots(ip)
	BYTE	*ip;
{
	if (ip != NULL)
		dos_free((LONG)ip);
}

	WORD
findIcnslot(slots, curr_icnmax, x, y, slotnr)
	REG BYTE *slots;
	BYTE	 *curr_icnmax;
	WORD	 *x, *y;
	BYTE	 *slotnr;
{
	REG WORD i, c, r;
	WORD	 rows, cols;

	rows = gl_rfull.g_h / WINICON_H;
	cols = gl_rfull.g_w / WINICON_W;

Debug1("find: rows="); Ndebug1((LONG) rows);
Debug1("find: cols="); Ndebug1((LONG) cols);

	do {
		for (r = rows - 1; r >= 0; r--) {
			for (c = 0; c < cols; c++) {
				i = (r * cols) + c;
				if ((slots[i] <= *curr_icnmax) && 
				    (slots[i] < 127)) {
					slots[i] += 1;
					*x = c * WINICON_W;
					*y = ((r+1) * WINICON_H) - gl_rfull.g_y;
					*slotnr = (BYTE) i;
Debug1("slot nr="); Ndebug1((LONG) i);
Debug1("row="); Ndebug1((LONG) r);
Debug1("col="); Ndebug1((LONG) c);
Debug1("x="); Ndebug1((LONG) *x);
Debug1("y="); Ndebug1((LONG) *y);
Debug1("curr_icnmax="); Ndebug1((LONG) *curr_icnmax);
					return TRUE;
				}
			}
		}
		(*curr_icnmax)++;
	} while (*curr_icnmax < 127);
	
	return FALSE;
}

	VOID
retIcnslot(slots, slotnr, curr_icnmax)
	BYTE	*slots;
	BYTE	*slotnr;
	BYTE	*curr_icnmax;
{
	WORD		flag;
	REG WORD	i, n;
	WORD		rows, cols;

Debug1("ret: slotnr="); Ndebug1((LONG) *slotnr);

	if (*slotnr == (BYTE) -1)
		return;

	slots[*slotnr] -= 1;
	*slotnr = (BYTE) -1;

	rows = gl_rfull.g_h / WINICON_H;
	cols = gl_rfull.g_w / WINICON_W;
	
Debug1("ret: before curr_icnmax="); Ndebug1((LONG) *curr_icnmax);
	n = rows * cols;
	flag = TRUE;
	for (i = 0; i < n; i++, slots++) {
		if (*slots >= *curr_icnmax)
			flag = FALSE;	 
	}
	if (flag)
		(*curr_icnmax)--;

	Debug1("ret: after curr_icnmax="); Ndebug1((LONG) *curr_icnmax);
}

