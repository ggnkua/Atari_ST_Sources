/*	WINDOW.C 	The Window Manager	Minna Lai		*/
/* Oct 29 1990	ml.	Created this.					*/
/* Feb 14 1991	ml.	Really started working on this.			*/
/* Feb 28 1992	ml.	Started to add 3D look to window gadgets.	*/
/*			(routines affected: w_adjust(), w_clipdraw)	*/
/* Apr 21 1992	ml.	Fixed W_HSLSZ and W_VSLSZ bug			*/
/* 8/7/92	D.Mui	Fix wm_set to accomdate 3D buttons		*/
/* 8/7/92 - 8/10/92	Fix w_adjust to accomdate 3D buttons		*/
/* 8/13/92	D.Mui	Fix at wm_start for opening background window	*/
/* 8/13/92	D.Mui	Check minimum window size before open		*/
/* 9/3/92	D.Mui	Implement WF_BEVENT and WF_BOTTOM		*/
/* 9/10/92	D.Mui	Return WM_ONTOP or WM_UNTOPPED message		*/

#include <portab.h>
#include <machine.h>
#include <struct88.h>
#include <baspag88.h>
#include <obdefs.h>
#include <taddr.h>
#include <gemlib.h>
#include <osbind.h>

/* whether window objects are 3D or not */
#define NO3D	0
#define IS3D	1

/* in GEMFLAG.C */
EXTERN WORD     unsync();
EXTERN WORD     tak_flag();

/* in GSXIF.C */
EXTERN WORD     gsx_gclip();
EXTERN WORD     gsx_sclip();
EXTERN VOID     gsx_mret();
EXTERN VOID     gsx_moff();
EXTERN VOID     gsx_mon();
EXTERN VOID     gsx_attr();
EXTERN VOID     gsx_1code();

/* in GEMGRLIB.S */
EXTERN	WORD	gr_stilldn();

/* in GEMOBLIB.C */
EXTERN VOID	ob_actxywh();
EXTERN VOID     ob_add();
EXTERN VOID     ob_draw();

EXTERN LONG     ad_stdesk;
EXTERN WORD     ml_ocnt;
EXTERN PD       *ctl_pd;
EXTERN PD       *gl_mowner;
EXTERN LONG     gl_mntree;

EXTERN WORD	gl_wchar, gl_hchar;	/* char size in pixels */
EXTERN WORD	gl_wbox, gl_hbox;	/* char box size in pixels */
EXTERN WORD	gl_width, gl_height;
EXTERN GRECT	gl_rfull;
EXTERN GRECT	gl_rscreen;

EXTERN WORD	deskwind;		/* DESKTOP window handle */


WORD	phanwind;		/* PHANTOM window handle */
WORD	hparts, vparts;		/* window elements masks */
WORD	wtcolor[MAXOBJ];	/* topped window object colors	*/
WORD	wbcolor[MAXOBJ];	/* background window object colors */
LONG	newdesk;		/* address of new DESKTOP */
WORD	newroot;		/* root object of new DESKTOP */
WINDOW	*hashtbl[NUMWIN];	/* window structures hash table */
WORD	hhead;			/* ascending handle # linked list */
WORD	topw, botw;		/* top and bottom window handles */
MEMHDR	*wmhead, *wmtail;	/* window memory linked list */
MEMHDR	*rmhead, *rmtail;	/* rect lists memory linked list */

WORD	wind_msg[8];		/* buffer to store window messages */
LONG	ad_windspb;


/*
 * Wm_init() -	initializes window colors, then start up the window
 *		manager.
 *	     -	this is called by geminit; only at boot time; so that
 *		window color defaults don't get munched when apps are
 *		launched; etc.
 */
VOID
wm_init()
{
    REG	WORD	i;	/* counter */

    for (i = 0; i < MAXOBJ; i++) {
	wtcolor[i] = wbcolor[i] = 0x1101;
    }
    wtcolor[W_NAME] |= 0xa0;
    wtcolor[W_VSLIDE] = wtcolor[W_HSLIDE] |= 0x10;
    wbcolor[W_VSLIDE] = wbcolor[W_HSLIDE] |= 0x10;

    wm_start();
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
    REG int	i;	/* counter */
    GRECT	windsiz;
    WINDOW	*srchwp();

    /* Allocate memory for memory header and window structures */
    if ((wmhead = (MEMHDR *)
	    Malloc((LONG)(NUMWIN*sizeof(WINDOW)+sizeof(MEMHDR)))) == NULLPTR)
	return FALSE;

    wmtail = wmhead;		    /* init WINDOW memory linked list */
    wmhead->mnext = NULLPTR;	    /* there is no next memory block */
    wmhead->numused = 0;	    /* no slot is used yet */

    /* init window structures and hash table entries */
    for (wp = (WINDOW *)(wmhead+1), i = 0;
	 i < NUMWIN;
	 i++, wp++) {
	wp->status.used = FALSE;    /* window structure is available */
	wp->wwhere = wmhead;	    /* remember where it resides in */
	hashtbl[i] = NULLPTR;	    /* initialize hash table entries */
    }

    topw = botw = NIL;	    	    /* no opened window yet */
    hhead = NIL;		    /* init ascending handle # linked list */

    /* Allocate memory for memory header and rectangle lists */
    if ((rmhead = (MEMHDR *)
	    Malloc((LONG)(NUMRECT*sizeof(RLIST)+sizeof(MEMHDR)))) == NULLPTR)
	return FALSE;

    rmtail = rmhead;		    /* init RLIST memory linked list */
    rmhead->mnext = NULLPTR;	    /* there is no next memory block */
    rmhead->numused = 0;	    /* no slot is used yet */

    /* init RLIST structures as available */
    for (rp = (RLIST *)(rmhead+1), i = 0; i < NUMRECT; i++, rp++) {
	rp->rstatus.rused = FALSE;
	rp->rwhere = rmhead;
    }

    newdesk = NULLPTR;		    /* no new DESKTOP */
    newroot = 0;

    /* These number is fixed	*/
	
    windsiz.g_x = -1;		/* These codes depend on the last */
    windsiz.g_y = gl_hbox - 1;	/* section of the w_adjust */
    windsiz.g_w = gl_rfull.g_w + 2;
    windsiz.g_h = gl_rfull.g_h + 2;

    /* create DESKTOP window for now */

    deskwind = wm_create(0, &windsiz);
    
    /* Fake the full x y w and h for deskwind */
    wp = srchwp( deskwind );
    r_set( &wp->full, 0, gl_hbox, gl_rfull.g_w, gl_rfull.g_h );

    /* Open the background window */	
    wm_open(deskwind, &windsiz);
    return TRUE;		    /* everything is fine */
}


/*
 * Wm_create() - allocates the application's full-size window and 
 *		 returns the window's handle.
 *	       - returns FAILURE (-1) if no handle is available or
 *		 if an error occurred.
 */
WORD
wm_create(kind, rect)
UWORD	    kind;	/* kind of window to be created */
REG GRECT   *rect;	/* x, y, width and height of full size window */
{
    REG	int 	i;		/* counter */
    REG	WORD	*tc, *bc;	/* pointers to color array */
    REG WINDOW	*wp;		/* pointer to window structure */
    WINDOW	*newwp();

    /* find next available window structure and handle	*/
    /* if none available, return with a FAILURE		*/
    if ((wp = newwp()) == NULLPTR || newhndl(wp) == FAILURE)
	return FAILURE;

    wp->type = 0;
    wp->status.opened = FALSE;		/* window has not been opened yet */
    wp->owner = rlr;		    	/* init owner of window */
    wp->mowner = NIL;			/* no mouse owner FOR NOW */
    wp->fxywh = wp->nxywh = NULLPTR;	/* no rectangle list yet */
    wp->kind = kind;			/* save kind of window */

    /* initialize window object colors */
    for (i = 0; i < MAXOBJ; i++) {
	wp->tcolor[i] = wtcolor[i];
	wp->bcolor[i]= wbcolor[i];
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
    wp->obj[W_BOX].ob_state |= SHADOWED;;

    hparts = kind & HPARTS;	/* mask for vertical slider elements */
    vparts = kind & VPARTS;	/* mask for horizontal slider elements */

    if (kind & TPARTS) {	/* any title bar elements? */
	w_bld(wp, W_TITLE, G_BOX, W_BOX, GBOX_OBS, NO3D);

	if (kind & CLOSER) {
	    w_bld(wp, W_CLOSER, G_BOXCHAR, W_TITLE, 0x05010000, IS3D);
	}

	if (kind & NAME) {
	    w_bld(wp, W_NAME, G_BOXTEXT, W_TITLE, &(wp->ttxt), IS3D);
	    w_ted(&(wp->ttxt), "Title Bar", 2, wtcolor[W_TITLE]);
	} else if (kind & MOVER) {
	    w_bld(wp, W_NAME, G_IBOX, W_BOX, 0L, NO3D);
	}

	if (kind & FULLER) {
	    w_bld(wp, W_FULLER, G_BOXCHAR, W_TITLE, 0x07010000, IS3D);
	}
    }

    if (kind & INFO) {
	w_bld(wp, W_INFO, G_BOXTEXT, W_BOX, &(wp->itxt), NO3D);
	w_ted(&(wp->itxt), "Info Line", 0, wtcolor[W_INFO]);
    }

    if (kind & MNBAR) {
	w_bld(wp, W_MNBAR, G_BOXTEXT, W_BOX, &(wp->mtxt), NO3D);
	w_ted(&(wp->mtxt), " Desk  File  View  Options", 0, wtcolor[W_MNBAR]);
    }

    if (kind & SIZER) {
	w_bld(wp, W_SIZER, G_BOXCHAR, W_BOX, 0x06010000, IS3D);

	if (!hparts && !vparts) {
	    w_bld(wp, W_VBAR, G_BOX, W_BOX, GBOX_OBS, NO3D);
	    /* Taken out to expand work area by 1 line	    */
	    /* w_bld(wp, W_HBAR, G_BOX, W_BOX, GBOX_OBS, IS3D);    */
	}
    } else if (hparts && vparts) {
	w_bld (wp, W_SIZER, G_BOX, W_BOX, GBOX_OBS, IS3D);
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
/*	    w_bld(wp, W_VELEV, G_BOX, W_VSLIDE, GBOX_OBS, NO3D);	*/
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
/*          w_bld(wp, W_HELEV, G_BOX, W_HSLIDE, GBOX_OBS, NO3D);	*/
	}
    }

    storewp(wp);	/* store window structure into database */
    return(wp->handle);	/* returns a handle */
}


/*
 * Wm_open() - opens a window in its given size and location.
 *	     - returns FALSE (0) if given handle is invalid,
 *	       or if window has already been opened.
 *	     - returns TRUE (1) if everything is fine.
 */
WORD
wm_open(handle, rect)
WORD	    handle;	    /* handle of window to be opened */
REG GRECT   *rect;	    /* x, y, width and height of opened window */
{
    REG WINDOW  *wp;	    /* pointer to window structure */
    WINDOW	*srchwp();
    WORD	ret,x,w,h;	    /* return code */

    /* if window structure can't be found or window already opened,
       return error */
    if ((wp = srchwp(handle)) == NULLPTR || wp->status.opened)
	return FALSE;

    wm_update(TRUE);

    /* check the minimum size	*/
	
    wm_min( wp->kind, &w, &h );

    if ( w > rect->g_w )
      rect->g_w = w;

    if ( h > rect->g_h )
      rect->g_h = h;

    w_adjust(wp, rect);	    	    /* init window components */
    wp->prev = wp->curr;
    wp->status.opened = TRUE;	    /* Grand opening!		*/

    ret = totop(handle, WMOPEN);    /* top it */
    wm_update(FALSE);
    return ret;
}


/*
 * Wm_close() - closes an opened window
 *	      - returns FALSE (0) if given handle is invalid,
 *	        or if window has already been closed.
 *	      - returns TRUE (1) if everything is fine.
 *
 */
WORD
wm_close(handle)
WORD	handle;			/* handle of window to be closed */
{
    REG WINDOW	*wp, *wp1;	/* pointers to window structure */
    GRECT	dirty;		/* rectangle of dirty area */

    if ((wp = srchwp(handle)) == NULLPTR || !wp->status.opened)
	return FALSE;

    wm_update(TRUE);
    /* save previous coords */
    wp->prev = wp->curr;

    /* reset current coords and work area coords */
    w_rect(&(wp->curr), 0, 0, 0, 0);
    *(GRECT *)&(wp->obj[W_WORK].ob_x) = wp->curr;

    /* remember that window has been closed */
    wp->status.opened = FALSE;

    /* delete window's rectangle list if there is one */
    if (wp->fxywh) {
	delrect(0L, wp->fxywh);
	wp->fxywh = wp->nxywh = NULLPTR;
    }

    dirty = wp->prev;
    dirty.g_w += SHADOW;
    dirty.g_h += SHADOW;
    w_drawchange(&dirty, NIL, NIL);

    /* maintain linked list of opened windows */
    if (handle == topw) {
	if ((topw = wp->under) != NIL) 
	{
	    totop(topw, WMCLOSE);
	    wp = srchwp(topw);  	
    	    ap_sendmsg(wind_msg, WM_ONTOP, wp->owner->p_pid, topw, 
		       0, 0, 0, 0 );
	} else {
	    botw = NIL;
	}
    } else if (handle == botw) {
	botw = wp->ontop;
	wp = srchwp(botw);
	wp->under = NIL;
    } else {
	wp1 = srchwp(wp->under);
	wp1->ontop = wp->ontop;
	wp1 = srchwp(wp->ontop);
	wp1->under = wp->under;
    }
    wm_update(FALSE);
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
    WINDOW	*srchwp();
    REG	WINDOW  *wp, *wp1, *wp2;    /* pointers to window structures */
    MEMHDR	*mp;		    /* pointer to memory header */
    int		bucket;		    /* index into hash table */

    if ((wp = srchwp(handle)) == NULLPTR)
	return FALSE;

    /* delete window's rectangle list if there is one */
    if (wp->fxywh)
	delrect(0L, wp->fxywh);

#if	1
    if (wp->status.opened)	/* if not already closed, */
	wm_close(handle);	/* close the window first */
#endif

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
				/* update internal pointers */
	wp->obj[W_NAME].ob_spec = &(wp->ttxt);
	wp->obj[W_INFO].ob_spec = &(wp->itxt);
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
	Mfree(wmtail);
	for (mp = wmhead; mp->mnext != wmtail; mp = mp->mnext)
	    ;
	mp->mnext = NULLPTR;
	wmtail = mp;
    }
    return TRUE;
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
    int		ret, i;
    REG WINDOW	*wp;
    REG	GRECT	*r;
    WINDOW	*srchwp();
    RLIST	*genrlist();


    if ( ( field == WF_DCOLOR ) || ( field == WF_TOP ) || ( field == WF_SCREEN ) ||
	 ( field == WF_BOTTOM )	)
      goto wg_1;

    if ((wp = srchwp(handle)) == NULLPTR)
	return FALSE;

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
	    wp = srchwp( topw );
	    ow[0] = topw;
	    ow[1] = wp->owner->p_pid;
	    ow[2] = wp->under;
	    break;

	    break;

	case WF_FIRSTXYWH:
	    r = (GRECT *)ow;
	    /* delete old list if there is one */
	    if (wp->fxywh) {
		delrect(0L, wp->fxywh);
		wp->fxywh = wp->nxywh = NULLPTR;
	    }
	    /* generate new list */
	    if (wp->fxywh = genrlist(handle, WF_WORKXYWH)) {
	    	wp->nxywh = (wp->fxywh)->rnext;
		*r = (wp->fxywh)->rect;
	    } else {
		*r = wp->curr;
		r->g_w = 0;
		r->g_h = 0;
	    }
	    break;

	case WF_NEXTXYWH:
	    r = (GRECT *)ow;
	    if (wp->nxywh) {
		*r = (wp->nxywh)->rect;
		wp->nxywh = (wp->nxywh)->rnext;
	    } else {
		*r = wp->curr;
		r->g_w = 0;
		r->g_h = 0;
	    }
	    break;

	case WF_NEWDESK:
	    *(LONG *)ow = newdesk;
	    ow[2] = newroot;
	    break;

	case WF_SCREEN:
	    gsx_mret(&ow[0], &ow[2]);
	    break;

	case WF_COLOR:
	    ow[1] = wp->tcolor[iw[0]];
	    ow[2] = wp->bcolor[iw[0]];
	    break;

	case WF_DCOLOR:
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
	    ow[0] = wp->type;
	    break;
	
	case WF_BOTTOM:
	    ow[0] = srchwp(0)->ontop; 
	    break;

	case WF_RESVD:
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
    WINDOW	*srchwp();
    int		ret, obj;
    long	blen;
    UWORD	sz;
    REG	WORD	*r, *r1, i;
    REG	OBJECT	*work;
    GRECT	rect, rect1;

    if ( ( field == WF_NEWDESK ) || ( field == WF_DCOLOR ) )
      goto ws_1;
	
    if ((wp = srchwp(handle)) == NULLPTR)
	return FALSE;	

ws_1:

    ret = TRUE;		    /* assume everything will be ok */

    wm_update(1);	    /* grab the window sync */

    switch (field) {
	case WF_NAME:
	    wp->ttxt.te_ptext = *(LONG *)iw;
	    if (wp->status.opened)
		w_clipdraw(wp, W_TITLE, NULLPTR);
	    break;

	case WF_INFO:
	    wp->itxt.te_ptext = *(LONG *)iw;
	    if (wp->status.opened)
		w_clipdraw(wp, W_INFO, NULLPTR);
	    break;

	case WF_CURRXYWH:
	    if ( iw[1] < gl_hbox )
	      iw[1] = gl_hbox;

	    rect = *(GRECT *)iw;

	    w_adjust(wp, &rect);

	    if (wp->status.opened) {
		/* send redraw message to opened windows which */
		/* intersect with the dirty area */
		rect = wp->prev;
		rect.g_w += SHADOW;
		rect.g_h += SHADOW;

		rect1 = wp->curr;
		rect1.g_w += SHADOW;
		rect1.g_h += SHADOW;

		if ((handle != topw)
		    || ((rect.g_x+rect.g_w > gl_width)&&(rect1.g_x < rect.g_x))
		    || ((rect.g_y+rect.g_h > gl_height)&&(rect1.g_y < rect.g_y))
		    || rect.g_w != rect1.g_w || rect.g_h != rect1.g_h
		    || rect.g_x < gl_rfull.g_x) {

		    w_clipdraw(wp, W_BOX, NULLPTR);
		    if (rect1.g_x != rect.g_x || rect1.g_y != rect.g_y
			|| rect1.g_w > rect.g_w || rect1.g_h > rect.g_h) {
			ap_sendmsg(wind_msg, WM_REDRAW, wp->owner->p_pid, 
			    handle, wp->curr.g_x, wp->curr.g_y, wp->curr.g_w, 
			    wp->curr.g_h);
		    }

		} else {
		    gsx_sclip(&gl_rfull);
		    bb_screen(S_ONLY, rect.g_x, rect.g_y, rect1.g_x, 
			rect1.g_y, rect.g_w, rect.g_h);
		}

		w_drawchange(&rect, handle,handle);
	    }
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

	    if (field == WF_HSLIDE || field == WF_HSLSIZE) 
	    {
		obj = W_HSLIDE;
		blen = wp->obj[W_HSLIDE].ob_width;
		if (wp->hslsz == -1 ||
		    (sz = blen * wp->hslsz / 1000) < gl_wbox) {
		    sz = gl_wbox;
		}
		if ( sz >= ( ADJ3DPIX << 1 ) ) 
		  wp->obj[W_HELEV].ob_width = sz - (ADJ3DPIX << 1);
/*
		blen -= ADJ3DPIX;
		sz += ADJ3DPIX;		
*/
/*		sz += ADJ3DPIX;	*/
		wp->obj[W_HELEV].ob_x = ((blen - sz) * wp->hslpos / 1000) + ADJ3DPIX;
/*	  	if ( wp->hslpos >= 1000 )
		  wp->obj[W_HELEV].ob_x -= ADJ3DPIX;
*/		  

	    } 
	    else 
	    {	/* field == WF_VSLIDE || field == WF_VSLSIZE */

		obj = W_VSLIDE;
		blen = wp->obj[W_VSLIDE].ob_height;
		if (wp->vslsz == -1 ||
		    (sz = blen * wp->vslsz / 1000) < gl_hbox) {
		    sz = gl_hbox;
		}
		if ( sz >= ( ADJ3DPIX << 1 ) )
		  wp->obj[W_VELEV].ob_height = sz - (ADJ3DPIX << 1);

/*		sz += ADJ3DPIX;	*/
		wp->obj[W_VELEV].ob_y = ((blen - sz) * wp->vslpos / 1000) + ADJ3DPIX;
/*		if ( wp->vslpos >= 1000 )
		  wp->obj[W_VELEV].ob_y -= ADJ3DPIX;
*/
	    }

	    /* if window is already opened, redraw it */
	    if (wp->status.opened)
		w_clipdraw(wp, obj, NULLPTR);
	    break;

	case WF_TOP:
	    if (handle != topw)
		ret = totop(handle, WMSET);
	    break;


	case WF_NEWDESK:
	    newdesk = *(LONG *)&iw[0];
	    newroot = iw[2];
	    break;

	case WF_COLOR:
	    if (iw[1] != -1)
		wp->tcolor[iw[0]] = iw[1];
	    if (iw[2] != -1)
		wp->bcolor[iw[0]] = iw[2];

	    if (wp->handle == topw)
		setcol(wp, iw[0], TRUE);
	    else
		setcol(wp, iw[0], FALSE);

	    /* if window is already opened, redraw it */

	    if (wp->status.opened)
		w_clipdraw(wp, iw[0], NULLPTR);

	    break;

	case WF_DCOLOR:
	    if (iw[1] != -1)
		wtcolor[iw[0]] = iw[1];
	    if (iw[2] != -1)
		wbcolor[iw[0]] = iw[2];
	    break;

	case WF_BEVENT:
	    wp->type = iw[0];
	    break;
	
	case WF_BOTTOM:
	    ret = tobot(handle);
	    break;

	case WF_RESVD:	    /* old WMLIB has code, but doc says RESERVED */
	default:
	    ret = FALSE;
	    break;
    }

    wm_update(0);	    /* give up the window sync */
    return ret;
}


/*
 * Wm_find() - finds which window is under the mouse's x, y position
 *
 */
WORD
wm_find(mx, my)
int mx;		/* mouse's x position */
int my;		/* mouse's y position */
{
    REG WINDOW  *wp;    /* pointer to window structure */

    for (wp = srchwp(topw); wp; wp = srchwp(wp->under)) {
	if (mx >= wp->curr.g_x && mx <= wp->curr.g_x + wp->curr.g_w
	    && my >= wp->curr.g_y && my <= wp->curr.g_y + wp->curr.g_h)
	    return (wp->handle);
    }
    return NIL;		/* return -1 if not on top of any window */
}


/*
 * Wm_update() - locks or unlocks the current state of the window 
 *		 tree while an application is responding to a 
 *		 window update message in his message pipe or is 
 *		 making some other direct screen update based on
 *		 his current rectangle list.
 *
 */
	WORD
wm_update(code)
int code;	/* flag for the call's function */
{
    if (code < 2) {
	if (code) {
	    if (!tak_flag(&wind_spb))
		ev_block(AMUTEX, ad_windspb);
	    } else {
		unsync(&wind_spb);
	}
    } else {
	code -= 2;
	take_ownership(code);
    }
    return(TRUE);
}


/*
 * Wm_calc() - calculates the x, y coordinates and width, height of a
 *		window's border area or work area
 *
 */
	WORD
wm_calc(type, kind, ix, iy, iw, ih, ox, oy, ow, oh)
int type;	/* the type of calculation to perform */
int kind;	/* components present in the window */
int ix;		/* input x-coordinate of window */
int iy;		/* input y-coordinate of window */
int iw;		/* input width of window */
int ih;		/* input height of window */
int *ox;	/* output x-coordinate of work/border area */
int *oy;	/* output y-coordinate of work/border area */
int *ow;	/* output width of work/border area */
int *oh;	/* output height of work/border area */
{
    REG WORD	tb, bb, lb, rb;
    REG	WORD	yinc, xinc;
    int		hparts, vparts;

    tb = bb = rb = 0;
    lb = 1;
	
    xinc = gl_wbox + (ADJ3DPIX << 1);
    yinc = gl_hbox + (ADJ3DPIX << 1);
	
    if (kind & (NAME | CLOSER | FULLER))
	tb += yinc;
    if (kind & INFO)
	tb += gl_hbox;
    if (kind & MNBAR)
	tb += yinc;

    vparts = kind & (UPARROW | DNARROW | VSLIDE);
    hparts = kind & (LFARROW | RTARROW | HSLIDE);

    if ( ( kind & SIZER ) && (!vparts && !hparts) )
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
			
    /* negate values to calc Border Area	*/

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
wm_min( kind, ow, oh )
	REG WORD 	kind;	/* coamponents present in the window */
	WORD 		*ow;	/* output width of work/border area */
	WORD 		*oh;	/* output height of work/border area */
{
    REG WORD	w1, w2, w3, h1, h2, h3;
    REG	WORD	yinc, xinc;
    WORD	hparts, vparts;

    w1 = w2 = w3 = h1 = h2 = h3 = 1;

    xinc = gl_wbox + (ADJ3DPIX << 1);
    yinc = gl_hbox + (ADJ3DPIX << 1);
	
    if ( kind & (NAME | CLOSER | FULLER) )
    {
	h1 += yinc;
	if ( kind & NAME )
	  w1 += xinc;

	if ( kind & CLOSER )
	  w1 += xinc;

	if ( kind & FULLER )
	  w1 += xinc;
    }

    if ( kind & INFO )
	h1 += yinc;

    if ( kind & MNBAR )
	h1 += yinc;

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
	REG SPB	*sy;
	REG MEMHDR  *mp;	/* pointer to memory header */

	/* Free all window structures */
	for (mp = wmhead; mp; mp = mp->mnext)
	    Mfree(mp);

	/* Free all rectangle list structures */
	for (mp = rmhead; mp; mp = mp->mnext)
	    Mfree(mp);

	wm_start();		/* reinit all data structures */

	ml_ocnt = 0;		/* reset the semaphore */
	gl_mntree = 0x0L;	/* reset menu tree */
	gl_mowner = ctl_pd;	/* reset mouse owner */

	sy = ad_windspb;

	if ( sy->sy_tas )	/* anybody owning the screen ? */
	{	 
	  while( sy->sy_tas )	/* in gemflag.c	*/
	    unsync( sy );
	}

	return TRUE;
}


/*
 * Allocate a window structure for a new window.
 *
 *     Returns a pointer to an available window 
 * structure or NULLPTR if none is available.
 *
 */
WINDOW*
newwp()
{
    WINDOW  *wp;	/* pointer to window structure */
    MEMHDR  *mp;	/* pointer to memory header */
    int	    i;		/* count */
	
    if (wmtail->numused == NUMWIN) {
	if ((mp = (MEMHDR *)
		Malloc((LONG)(NUMWIN*sizeof(WINDOW)+sizeof(MEMHDR)))) 
	    == NULLPTR) {
	    return(NULLPTR);
	} else {
	    /* init window structures as available */
	    for (wp = (WINDOW *)(mp+1), i = 0; i < NUMWIN; i++, wp++) {
		wp->status.used = FALSE;
		wp->wwhere = mp;
	    }

	    wmtail->mnext = mp;
	    mp->mnext = NULLPTR;
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
    WINDOW  *srchwp();
    int	    found;

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
    int	    bucket;		/* bucket number in hash table */
	
    bucket = wp->handle % NUMWIN;
    wp->wnext = hashtbl[bucket];
    hashtbl[bucket] = wp;
}


/*
 * Search for the window structure that corresponds to the
 * given handle.
 *
 *    Returns a pointer to the window structure of the given
 * handle, or NULLPTR if the window structure is not found.
 *
 */
WINDOW*
srchwp(handle)
int handle;
{
    WINDOW  *wp;		/* pointer to window structure */
    int	    bucket;		/* bucket number in hash table */

    wp = NULLPTR;		/* assume no window structure */

    /* look for window structure only if handle is valid */
    if (handle >= 0) {
	bucket = handle % NUMWIN;
	for(wp = hashtbl[bucket]; 
	    wp != NULLPTR && wp->handle != handle; 
	    wp = wp->wnext)
	    ;
    }

    return(wp);
}


/*
 * totop() - tops the given window, and untops the current top window
 *	     (if there is one.)
 *
 */
WORD
totop(handle, caller)
WORD	handle;		/* handle of window to be topped */
WORD	caller;		/* WMOPEN: called by wm_open() */
			/* WMCLOSE: called by wm_close()  */
			/* WMSET: called by wm_set()  */
{
    REG WINDOW  *ntwp;
    WINDOW	*onwp, *unwp, *twp;
    WORD	nxtw, i;
    GRECT	obscured, inter, ontop;

    twp = NULLPTR;

    /* search for window structure of the given handle */
    if ((ntwp = srchwp(handle)) == NULLPTR
	|| (caller == WMSET && !ntwp->status.opened))
	return FALSE;

/* For optimizing redraws 6-16-92 ml. */
    for (nxtw = ntwp->ontop, i = 0; nxtw != NIL; nxtw = onwp->ontop) {
	onwp = srchwp(nxtw);
	ontop = onwp->curr;
	ontop.g_w += SHADOW;
	ontop.g_h += SHADOW;
	inter = ntwp->curr;
	inter.g_w += SHADOW;
	inter.g_h += SHADOW;
	if (rc_intersect(&ontop, &inter)) {
	    if (!i) {
		obscured = inter;
		i++;
	    } else {
		rc_union(&inter, &obscured);
	    }
	}
    }

    /* maintain linked list of opened windows */
    if (topw == NIL) {
	botw = handle;
    } else if (caller != WMCLOSE) {    /* orig. top window wasn't closed */
	if (caller == WMSET) {
	    onwp = srchwp(ntwp->ontop);
	    if ((onwp->under = ntwp->under) != NIL) {
		unwp = srchwp(ntwp->under);
		unwp->ontop = ntwp->ontop;
	    }
	}
	twp = srchwp(topw);
	twp->ontop = handle;
    	ntwp->under = topw;
    }

    ntwp->ontop = NIL;
    topw = handle;

    /* draw the untopped window if there is one */
    if (twp) 
    {
	activate(twp, NO);
    	w_clipdraw(twp, W_BOX, NULLPTR);
	if ( twp->handle )		/* send untopped message */
	    ap_sendmsg( wind_msg, WM_UNTOPPED, twp->owner->p_pid, twp->handle,
		        0, 0, 0, 0 );
    }

    /* draw border of the newly topped window */
    activate(ntwp, YES);
    w_clipdraw(ntwp, W_BOX, NULLPTR);
    w_setactive();

    /* draw content of newly topped window if it's not the DESKTOP  */
    if (handle != deskwind) {
	if (caller == WMOPEN) {
	    ap_sendmsg(wind_msg, WM_REDRAW, ntwp->owner->p_pid, handle,
		ntwp->curr.g_x, ntwp->curr.g_y, ntwp->curr.g_w, ntwp->curr.g_h);
	} else if (caller == WMSET) {
	    ap_sendmsg(wind_msg, WM_REDRAW, ntwp->owner->p_pid, handle,
		obscured.g_x, obscured.g_y, obscured.g_w, obscured.g_h);
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
WORD	handle;		/* handle of window to be bottmed */
{
    REG WINDOW  *nbwp, *onbwp, *unnbwp;
    WINDOW	*bwp, *onnbwp;
    GRECT	dirty;

    /* search for window structure of the given handle */
    if ((nbwp = srchwp(handle)) == NULLPTR || (!nbwp->status.opened))
	return FALSE;

    bwp = srchwp(deskwind);
    onbwp = srchwp(bwp->ontop);
    if (onbwp->handle == handle)	/* if already bottomed,	*/
        return TRUE;			/*   return		*/

    unnbwp = srchwp(nbwp->under);

    /* need to top another window? */
    if (handle == topw) {
	topw = unnbwp->handle;

	/* change border of newly bottomed window */
	activate(nbwp, NO);
	w_clipdraw(nbwp, W_BOX, NULLPTR);

	/* draw border of the newly topped window */
	activate(unnbwp, YES);
	w_clipdraw(unnbwp, W_BOX, NULLPTR);
	w_setactive();
    } else {
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

    /* notify owner of newly topped window */
    ap_sendmsg(wind_msg, WM_ONTOP, unnbwp->owner->p_pid, unnbwp->handle, 
	       0, 0, 0, 0 );

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

    if (!(kind = wp->kind))
	return;

    setcol(wp, W_BOX, topped);

    if (kind & TPARTS) {
	if (kind & NAME) {
	    setcol(wp, W_NAME, topped);
	}

	if (kind & CLOSER) {
	    setcol(wp, W_CLOSER, topped);
	}

        if (kind & FULLER) {
	    setcol(wp, W_FULLER, topped);
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

    if (kind & MNBAR)
	setcol(wp, W_MNBAR, topped);
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
    if ((wp->obj[ndx].ob_type & 0x00ff) == G_BOXTEXT) {
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
w_adjust(wp, rect)
REG WINDOW  *wp;	/* pointer to window structure */
REG GRECT   *rect;	/* pointer to window's coords and dimensions */
{
    int		ulx;	    /* x offset from upper left corner */
    int		uly;	    /* y offset from upper left corner */
    int		urx;	    /* x offset from upper right corner */
    int		ury;	    /* y offset from upper right corner */
    int		llx;	    /* x offset from lower left corner */
    int		lly;	    /* y offset from lower left corner */
    int		lrx;	    /* x offset from lower right corner */
    int		lry;	    /* y offset from lower right corner */
    int		inx, iny;   /* x and y increments */
    int		blen;	    /* length of base bar */
    int		sz;	    /* slider size */
    int		w3dbox, h3dbox;

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
    if (rect->g_w == wp->prev.g_w && rect->g_h == wp->prev.g_h) {
	/* initialize window work area */
	wp->obj[W_WORK].ob_x -= (wp->prev.g_x - rect->g_x);
	wp->obj[W_WORK].ob_y -= (wp->prev.g_y - rect->g_y);
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

    if (wp->kind & MNBAR) {
	w_obrect(wp, W_MNBAR, 0, uly, rect->g_w, h3dbox);
	uly = ury += iny;
    }

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
	/* the won't fit in 16 bits, 'cause it's scaled by 1000: ++ERS 1/11/93 */
		sz = ( (long)sz * wp->vslsz ) / 1000;
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
	w_obrect(wp, W_HBAR, 0, (rect->g_h-h3dbox), blen, gl_hbox);

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
	/* the won't fit in 16 bits, 'cause it's scaled by 1000: ++ERS 1/11/93 */
		sz = ((long) sz * wp->hslsz) / 1000;
			 
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


#if 0
/*
 * W_adjust() - adjust x, y, w and h of each component in the 
 *		given window with the window's x, y, w and h.
 */
VOID
w_adjust(wp, rect)
REG WINDOW  *wp;	/* pointer to window structure */
REG GRECT   *rect;	/* pointer to window's coords and dimensions */
{
    int		ulx;	    /* x offset from upper left corner */
    int		uly;	    /* y offset from upper left corner */
    int		urx;	    /* x offset from upper right corner */
    int		ury;	    /* y offset from upper right corner */
    int		llx;	    /* x offset from lower left corner */
    int		lly;	    /* y offset from lower left corner */
    int		lrx;	    /* x offset from lower right corner */
    int		lry;	    /* y offset from lower right corner */
    int		inx, iny;   /* x and y increments */
    int		blen;	    /* length of base bar */
    int		sz;	    /* slider size */
    int		w3dbox, h3dbox;

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
    if (rect->g_w == wp->prev.g_w && rect->g_h == wp->prev.g_h) {
	/* initialize window work area */
	wp->obj[W_WORK].ob_x -= (wp->prev.g_x - rect->g_x);
	wp->obj[W_WORK].ob_y -= (wp->prev.g_y - rect->g_y);
	return;
    }

    /* init offsets from the four corners and the x and y increments */
    ulx = uly = urx = ury = llx = lly = lrx = lry = 0;
    w3dbox = gl_wbox + (ADJ3DPIX << 1);
    h3dbox = gl_hbox + (ADJ3DPIX << 1);
    inx = w3dbox - 1;
    iny = h3dbox - 1;

    if (wp->kind & TPARTS) {
	w_obrect(wp, W_TITLE, 0, 0, rect->g_w, h3dbox);
	uly = ury = iny;

	if (wp->kind & CLOSER) {
	    w_obrect(wp, W_CLOSER, ADJ3DPIX, ADJ3DPIX, gl_wbox, gl_hbox);
	    ulx = inx;
	}
/*
	if (wp->kind & FULLER) 
	{
	    w_obrect(wp, W_FULLER, (rect->g_w-w3dbox+1), ADJ3DPIX, gl_wbox, 
		gl_hbox);
	    urx = inx;
	}
*/
	if (wp->kind & FULLER) 
	{
	    w_obrect(wp, W_FULLER, (rect->g_w-w3dbox+ADJ3DPIX), ADJ3DPIX, gl_wbox, 
		gl_hbox);
	    urx = inx;
	}

	if (wp->kind & NAME || wp->kind & MOVER) {
	    w_obrect(wp, W_NAME, (ulx+ADJ3DPIX), ADJ3DPIX, 
		(rect->g_w-ulx-urx-(ADJ3DPIX << 1)), gl_hbox);

	}
    }

    if (wp->kind & INFO) {
	w_obrect(wp, W_INFO, 0, uly, rect->g_w, h3dbox);
	uly = ury += iny;
    }

    if (wp->kind & MNBAR) {
	w_obrect(wp, W_MNBAR, 0, uly, rect->g_w, h3dbox);
	uly = ury += iny;
    }

    urx = 0;	/* reinitialize upper right x offset */

    if ((hparts = wp->kind & HPARTS))
	lry = iny;
    if ((vparts = wp->kind & VPARTS))
	lrx = inx;

    if (wp->kind & SIZER) 
    {
/*	w_obrect(wp, W_SIZER, (rect->g_w-w3dbox+1), (rect->g_h-h3dbox+1),
		gl_wbox, gl_hbox);
*/
	w_obrect(wp, W_SIZER, (rect->g_w-w3dbox+2), (rect->g_h-h3dbox+2),
		gl_wbox, gl_hbox);
	lry = iny;
	lrx = inx;

	if (!hparts && !vparts) 
	{
/*	    w_obrect(wp, W_VBAR, (rect->g_w-w3dbox+1), ury, w3dbox, 
		(rect->g_h-ury-lry));
*/
	    w_obrect(wp, W_VBAR, (rect->g_w-w3dbox+2), ury, w3dbox, 
		(rect->g_h-ury-lry));
	    urx = inx;
	}
    } 
    else if (hparts && vparts) 
	{
/*	w_obrect(wp, W_SIZER, (rect->g_w-w3dbox+1), (rect->g_h-h3dbox+1),
		gl_wbox, gl_hbox);
*/
	w_obrect(wp, W_SIZER, (rect->g_w-w3dbox+2), (rect->g_h-h3dbox+2),
		gl_wbox, gl_hbox);
	lry = iny;
	lrx = inx;
    }

    if (vparts) {
	blen = rect->g_h - ury - lry - 1;
	urx = inx;
	w_obrect(wp, W_VBAR, (rect->g_w-w3dbox), ury, w3dbox, blen);

	if (wp->kind & UPARROW) {
	    w_obrect(wp, W_UPARROW, ADJ3DPIX, ADJ3DPIX, gl_wbox, gl_hbox);
	    ury += iny;
	}

	if (wp->kind & DNARROW) {
	    w_obrect(wp, W_DNARROW, ADJ3DPIX, (blen-h3dbox+1), gl_wbox, 
		gl_hbox);
	    lry += iny;
	}

	if (wp->kind & VSLIDE) {
/*
	    sz = rect->g_h - ury - lry - (ADJ3DPIX << 1) - 1; 
	    w_obrect(wp, W_VSLIDE, 0, (ury-uly+1), w3dbox, sz);	
*/

	    sz = rect->g_h - ury - lry - (ADJ3DPIX << 1); 
	    w_obrect(wp, W_VSLIDE, 0, (ury-uly), w3dbox, sz);

	    /* Apr-21-92  ml. Use wp->hslsz to determine size of elevator */
	    if (wp->vslsz == -1)
		w_obrect(wp, W_VELEV, ADJ3DPIX, ADJ3DPIX, gl_wbox, gl_hbox);
	    else
		w_obrect(wp, W_VELEV, ADJ3DPIX, ADJ3DPIX, gl_wbox, 
		    sz * wp->vslsz /1000);
	}
    }


    if (hparts) {
	blen = rect->g_w - lrx - 1;
	lly = iny;
	w_obrect(wp, W_HBAR, 0, (rect->g_h-h3dbox), blen, h3dbox);

	if (wp->kind & LFARROW) {
	    w_obrect(wp, W_LFARROW, ADJ3DPIX, ADJ3DPIX, gl_wbox, gl_hbox);
	    llx = inx;
	}

	if (wp->kind & RTARROW) {
	    w_obrect(wp, W_RTARROW, (blen-w3dbox+1), ADJ3DPIX, gl_wbox, 
		gl_hbox);
	    lrx += inx;
	}

	if (wp->kind & HSLIDE) {
	    sz = rect->g_w - llx - lrx - (ADJ3DPIX << 1) - 1;
	    w_obrect(wp, W_HSLIDE, (llx+ADJ3DPIX), 0, sz, h3dbox);

	    /* Apr-21-92  ml. Use wp->hslsz to determine size of elevator */
	    if (wp->hslsz == -1)
		w_obrect(wp, W_HELEV, ADJ3DPIX, ADJ3DPIX, gl_wbox, gl_hbox);
	    else
		w_obrect(wp, W_HELEV, ADJ3DPIX, ADJ3DPIX, 
		    sz * wp->hslsz /1000, gl_hbox);
	}
    }

    /* initialize window work area */
    w_rect((GRECT *)&(wp->obj[W_WORK].ob_x), (rect->g_x+1), 
	    (rect->g_y+uly), (rect->g_w-urx-1), (rect->g_h-uly-lly));
}
#endif


/*
 * W_clipdraw() - set clipping according to the rectangle list
 *		  of the current size of the window, or the 
 *		  clipping rectangle passed in, and draw the
 *		  object specified.
 */
VOID
w_clipdraw(wp, obj, pc)
WINDOW	*wp;	    /* pointer to window structure */
int	obj;	    /* object to be drawn */
GRECT	*pc;	    /* pointer to clipping rectangle */
{
    REG RLIST	*rl;
    GRECT	rclip;
    RLIST	*genrlist(), *rlist;
	
    gsx_moff();
    wm_update(TRUE);
    rlist = genrlist(wp->handle, WF_CURRXYWH);
    for (rl = rlist; rl; rl = rl->rnext) {
	/* if no clipping rectangle given, clip to screen and itself */
	rclip = rl->rect;
	if (!rc_intersect(&gl_rfull, &rclip))	/* clip to screen */
	   continue;
	
/*	    rclip = gl_rfull;	*/
	if (!pc || rc_intersect(pc, &rclip)) 
	{
	    gsx_sclip(&rclip);
	    ob_draw(wp->obj, obj, MAX_DEPTH);
	}
    }
    wm_update(FALSE);
    gsx_mon();

    if (rlist)
	delrect(0L, rlist);
}



/*
 * W_drawchange() - draw the borders of opened windows which 
 *		    intersects with the dirty area, and send
 *		    redraw messages to those windows
 */
VOID
w_drawchange(dirty, skip,stop)
	GRECT	*dirty;		/* rectangle of dirty area */
	UWORD	skip,stop;	/* window to be skipped */
{
    UWORD   handle;	/* window handle */
    GRECT   exposed;	/* area to be drawn */
    WINDOW  *wp;	/* pointer to window structure */

    for (handle = botw; handle != stop; handle = wp->ontop) {
	wp = srchwp(handle);

	if (handle == skip)
	    continue;

	exposed = wp->curr;
	exposed.g_w += SHADOW;
	exposed.g_h += SHADOW;

	if (rc_intersect(dirty, &exposed)) {
	    w_clipdraw(wp, W_BOX, &exposed);
	    if (handle)
		ap_sendmsg(wind_msg, WM_REDRAW, wp->owner->p_pid, handle, 
		    exposed.g_x, exposed.g_y, exposed.g_w, exposed.g_h);
	    else
	    {	
		ap_sendmsg(wind_msg, WM_REDRAW, ctl_pd->p_pid, handle, 
		    exposed.g_x, exposed.g_y, exposed.g_w, exposed.g_h);
	      
/*      drawdesk( exposed.g_x, exposed.g_y, exposed.g_w, exposed.g_h);*/
	    }
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
WINDOW	*wp;
REG int	ob;
int	type, parent;
long	spec;
WORD	is3d;
{
    REG OBJECT  *obaddr;

    /* initialize object */
    obaddr = &(wp->obj[ob]);
    obaddr->ob_next = obaddr->ob_head = obaddr->ob_tail = NIL;
    obaddr->ob_flags = is3d ? (IS3DOBJ|IS3DACT) : 0;
    obaddr->ob_type = type;
    obaddr->ob_state = NORMAL;
    obaddr->ob_spec = spec;
    if (type != G_BOXTEXT)
	obaddr->ob_spec |= ((LONG)wtcolor[ob] & 0x0000ffffL);

    /* add object to tree */
    if (parent != NIL)
	ob_add(wp->obj, parent, ob);
}


VOID
w_obrect(wp, ob, obx, oby, obw, obh)
WINDOW	*wp;
int	ob;
int	obx, oby, obw, obh;
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
int	    gx, gy, gw, gh;
{
    raddr->g_x = gx;
    raddr->g_y = gy;
    raddr->g_w = gw;
    raddr->g_h = gh;
}


VOID
w_ted(tedaddr, ptext, just, color)
REG TEDINFO *tedaddr;
char	*ptext;
int	just, color;
{
    tedaddr->te_ptext = ptext;
    tedaddr->te_just = just;
    tedaddr->te_color = color;
    tedaddr->te_txtlen = strlen(ptext);
    tedaddr->te_font = 3;
    tedaddr->te_thickness = 1;
    tedaddr->te_tmplen = 0;
}


/*
 * W_setactive() - set control rectangle and mouse owner
 */
VOID
w_setactive()
{
    GRECT   d;
    WINDOW  *wp, *srchwp();

    wp = srchwp(topw);
    d = *(GRECT *)&(wp->obj[W_WORK].ob_x);
    ct_chgown(wp->owner, &d);
}


/* 
 * Ap_sendmsg() - send message to current process
 */
VOID
ap_sendmsg(ap_msg, type, towhom, w3, w4, w5, w6, w7)
REG WORD    ap_msg[];
WORD	    type, towhom;
WORD	    w3, w4, w5, w6, w7;
{
    ap_msg[0] = type;
    ap_msg[1] = rlr->p_pid;
    ap_msg[2] = 0;
    ap_msg[3] = w3;
    ap_msg[4] = w4;
    ap_msg[5] = w5;
    ap_msg[6] = w6;
    ap_msg[7] = w7;
    ap_rdwr(AQWRT, towhom, 16, ADDR(&ap_msg[0]));
}


