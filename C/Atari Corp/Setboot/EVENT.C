/*
 *	Krober                                         
 */
#include <gemlib.h>

WORD	init_evnt(va_alist)
va_dcl
{
	va_list		ap;
	GEMBUF		*a;
	WORD		evnts;
	register WORD	kindex;
	register WORD	arg_type;
	WORD		do_slider();
	
	va_start(ap);
	a = va_arg(ap, GEMBUF*);
	if (!(evnts = va_arg(ap, WORD))) 
		return FAILURE;

	/*
	 *	init evnt struct with std values
	 */
	a->evnt.evnts = evnts;
	a->evnt.clicks = 2;	/* wait for max 2 clicks */
	a->evnt.wbutton = 1;	/* left button */
	a->evnt.state = 1;	/* button pushed */
	a->evnt.m1inout = 0;
	a->evnt.rect1.g_x = 0;
	a->evnt.rect1.g_y = 0;
	a->evnt.rect1.g_w = 0;
	a->evnt.rect1.g_h = 0;
	a->evnt.m2inout = 0;
	a->evnt.rect2.g_x = 0;
	a->evnt.rect2.g_y = 0;
	a->evnt.rect2.g_w = 0;
	a->evnt.rect2.g_h = 0;
	a->evnt.lowtime = 1;
	a->evnt.hightime = 0;

	a->evnt.usr_menu = NULL;
	a->evnt.usr_button = NULL;
	a->evnt.usr_keybd = NULL;
	a->evnt.icon_exec = NULL;
	a->evnt.icon_sel = NULL;
	/* std event fcts */
	
	a->evnt.do_msg	= do_msg;
	a->evnt.do_menu = do_menu;
	a->evnt.do_keybd = do_keybd;
	a->evnt.do_button = do_button;
	a->evnt.do_m1 = do_m1;
	a->evnt.do_m2 = do_m2;
	a->evnt.do_redraw = do_redraw;
	a->evnt.do_top = do_top;
	a->evnt.do_close = do_close;
	a->evnt.do_full = do_full;
	a->evnt.do_arrow = do_slider;
	a->evnt.do_vslid = do_slider;
	a->evnt.do_hslid = do_slider;
	a->evnt.do_size = do_size;
	a->evnt.do_move = do_move;
	a->evnt.do_newtop = do_newtop;
	a->evnt.do_timer = do_timer;
	a->evnt.do_popup = do_popup;		/* ??? ??? */
	a->evnt.before_do_slider = NULL;
#ifdef ACC
	a->evnt.do_accopen = do_accopen;
	a->evnt.do_accclose = do_accclose;
#endif

	while ((arg_type = va_arg(ap, WORD)) != 0) {
		switch (arg_type) {
		case IE_MENUKEY:
			kindex = va_arg(ap, WORD);
			a->evnt.keytable[kindex].special = va_arg(ap, WORD);
			a->evnt.keytable[kindex].mtitle = va_arg(ap, WORD);
			a->evnt.keytable[kindex].mentry = va_arg(ap, WORD);
			break;
		case IE_MENU: {
			WORD	index;
			WORD	(*usr_menu)();
			
			index = va_arg(ap, WORD);
			usr_menu = va_arg(ap, WFCTP);
			init_menu(a, index, usr_menu);
			
			break;
			}
		case IE_KEYBD:
			a->evnt.usr_keybd = va_arg(ap, WFCTP);
			break;
		case IE_BUTTON:		
			a->evnt.usr_button = va_arg(ap, WFCTP);
			break;
		case IE_DESKPOPUP:		
			a->popup.usr_popup = va_arg(ap, WFCTP);
			break;
		/* 
		 * at the moment we implement icons in the user prg
		 * and call it with the event_button()
		 *
		case IE_ICON:
			a->evnt.icon_exec = va_arg(ap, WFCTP);
			a->evnt.icon_sel = va_arg(ap, WFCTP);
			break;
		*/
		}
	}

	va_end(ap);


	return SUCCESS;
}

/*
 *	:change_evnt()
 *	not used at the moment
 *	will change; one day we will use va_list
 */


WORD	change_evnt(a, which, a1, a2, a3, a4, a5, a6)
GEMBUF	*a;
WORD	which;
LONG	a1;
{
	switch (which) {
		case MU_KEYBD:
			if (a1 != 0l)
				a->evnt.do_keybd = (WORD *()) a1;
			break;
		case MU_BUTTON:
			if (a1 != 0l)
				a->evnt.do_button = (WORD *())a1;
			a->evnt.clicks = a2;
			a->evnt.wbutton = a3;
			a->evnt.state = a4;
			break;
		case MU_M1:
			if (a1 != 0l)
				a->evnt.do_m1 = (WORD *()) a1;
			a->evnt.m1inout = a2;
			a->evnt.rect1.g_x = a3;
			a->evnt.rect1.g_y = a4;	
			a->evnt.rect1.g_w = a5;
			a->evnt.rect1.g_h = a6;
			break;
		case MU_M2:
			if (a1 != 0l)
				a->evnt.do_m2 = (WORD *()) a1;
			a->evnt.m2inout = a2;
			a->evnt.rect2.g_x = a3;
			a->evnt.rect2.g_y = a4;	
			a->evnt.rect2.g_w = a5;
			a->evnt.rect2.g_h = a6;
			break;
		case MU_MESAG:
			break;
		case MU_TIMER:
			if (a1 != 0l)
				a->evnt.do_timer = (WORD *()) a1;
			a->evnt.lowtime = a2;
			a->evnt.hightime = a3;
			break;
	}	
}

/*
 *	:add_evnt()
 */
WORD	add_evnt(a, event)
GEMBUF	*a;
WORD	event;
{
	a->evnt.evnts |= event;
	
	return SUCCESS;
}

/*
 *	:del_evnt()
 */
WORD	del_evnt(a, event)
GEMBUF	*a;
WORD	event;
{
	a->evnt.evnts &= (~event);
	
	return SUCCESS;
}



/*
 * 	:evnt()
 */

WORD	evnt(a)
GEMBUF 	*a;
{
	register WORD event;		/* the occured event 		*/
	
	if (!a->evnt.evnts)
		panic(INT_ERR, "do_evnt() 1", NOEVNTSET, ABORT);
	
	FOREVER {
		event = evnt_multi(	a->evnt.evnts,  
					a->evnt.clicks, 
					a->evnt.wbutton, 
					a->evnt.state,
			 		a->evnt.m1inout, 
			 		a->evnt.rect1.g_x,
			 		a->evnt.rect1.g_y,
			 		a->evnt.rect1.g_w,
			 		a->evnt.rect1.g_h,
			 		a->evnt.m2inout, 
			 		a->evnt.rect2.g_x,
			 		a->evnt.rect2.g_y,
			 		a->evnt.rect2.g_w,
			 		a->evnt.rect2.g_h,
			 		a->evnt.msgbuf, 
			 		a->evnt.lowtime,
			 		a->evnt.hightime, 
			 		&a->evnt.mousex,
			 		&a->evnt.mousey,
			 		&a->evnt.mbutton,
			 		&a->evnt.keystate,
			 		&a->evnt.key, 
			 		&a->evnt.mtimes);
		begin_update(a);	
		if (event & MU_MESAG)
			(*a->evnt.do_msg)(a, a->evnt.msgbuf);
			
		if (event & MU_KEYBD)
				(*a->evnt.do_keybd)(a, a->evnt.key, 
					a->evnt.keystate);

		if (event & MU_BUTTON)
			(*a->evnt.do_button)(a, a->evnt.mtimes,
				a->evnt.mousex, a->evnt.mousey, 
				a->evnt.mbutton, a->evnt.keystate);
				
		if (event & MU_M1) {
			(*a->evnt.do_m1)(a);
		}
		if (event & MU_M2) {
			(*a->evnt.do_m2)(a);
		}
		if (event & MU_TIMER)
			(*a->evnt.do_timer)(a);
		end_update(a);
						
	} 	/* FOREVER */
}	/* event() */


/*
 *	:do_msg()
 */
 
WORD	do_msg(a, buf)
GEMBUF	*a;
WORD	*buf;		/* message buffer */
{
	switch(buf[0]) {
		/* appl_read() */
		case MN_SELECTED:
			(*a->evnt.do_menu)(a, buf[3], buf[4]); 
			break;
		case MN_POPUP:
			(*a->evnt.do_popup)(a, buf[3], buf[4]);
			break;
		case WM_REDRAW:
			(*a->evnt.do_redraw)(a, buf[3], buf[4], buf[5], 
					buf[6], buf[7]);
			break;
		case WM_TOPPED:
			(*a->evnt.do_top)(a, buf[3]);
			break;
		case WM_CLOSED:
			(*a->evnt.do_close)(a, buf[3]);
			break;
		case WM_FULLED:
			(*a->evnt.do_full)(a, buf[3]);
			break;
		case WM_ARROWED:		
			(*a->evnt.do_arrow)(a, buf[3], buf[4], -1);
			break;	
		case WM_HSLID:			
			(*a->evnt.do_hslid)(a, buf[3], WM_HSLID, buf[4]);
			break;
		case WM_VSLID:			
			(*a->evnt.do_vslid)(a, buf[3], WM_VSLID, buf[4]);
			break;
		case WM_SIZED:
			(*a->evnt.do_size)(a, buf[3], buf[4], buf[5], 
					buf[6], buf[7]);
			break;
		case WM_MOVED:
			(*a->evnt.do_move)(a, buf[3], buf[4], buf[5],
					buf[6], buf[7]);
			break;
		case WM_NEWTOP:
			(*a->evnt.do_newtop)(a, buf[3]);
			break;
#ifdef ACC
		case AC_OPEN:
			(*a->evnt.do_accopen)(a, buf[3]);
			break;
		case AC_CLOSE:
			(*a->evnt.do_accclose)(a, buf[3]); 
			break;
#endif
	} 	/* switch (buf[0]) */
	a->evnt.lastevnt = a->evnt.msgbuf[0];
}


/*
 *	:do_menu()
 */

WORD	do_menu(a, mtitle, mentry)
GEMBUF	*a;
WORD	mtitle;		/* title of the chosen menu */
WORD	mentry;		/* entry of the ... */
{
	show_mouse(a);
	if (a->evnt.usr_menu != NULL)
		(*a->evnt.usr_menu)(a, mtitle, mentry);	
	menu_tnormal(a->menu_addr, mtitle, TRUE);
}

/*
 *	:do_keybd()
 */
WORD	do_keybd(a, key, keystate)
GEMBUF *a;
WORD	key;
WORD	keystate;
{
	WORD	wh, foo;
	WORD	menu = FALSE;
	WORD	kindex;
	WINDOW	*wp;

	/*
	 *	look, if key selects an menu entry
	 */
	kindex = key >> 8;
	if ((menu = a->evnt.keytable[kindex].mtitle)) {
		switch (a->evnt.keytable[kindex].special) {
		case KMENU_ALT:
			if (keystate != K_ALT)
				menu = FALSE;
			break;
		case KMENU_CNTRL:
			if (keystate != K_CTRL)
				menu = FALSE;
			break;
		case KMENU_SHIFT:
			if ((keystate != K_LSHIFT) && (keystate != K_RSHIFT))
				menu = FALSE;
			break;
		case (KMENU_ALT | KMENU_CNTRL):
			if (keystate != (K_ALT + K_CTRL))
				menu = FALSE;
			break;
		case (KMENU_ALT | KMENU_SHIFT):
			if ((keystate != (K_ALT + K_LSHIFT)) &&
			(keystate != (K_ALT + K_RSHIFT)))
				menu = FALSE;
			break;
		case (KMENU_CNTRL | KMENU_SHIFT):
			if ((keystate != (K_CTRL + K_LSHIFT)) &&
			(keystate != (K_CTRL + K_RSHIFT)))
				menu = FALSE;
			break;
		case (KMENU_CNTRL | KMENU_ALT | KMENU_SHIFT):
			if ((keystate != (K_ALT + K_CTRL + K_LSHIFT)) &&
			(keystate != (K_ALT + K_CTRL + K_RSHIFT)))
				menu = FALSE;
			break;
		default:
			menu = FALSE;
			break;
		}
	}
	if (menu) { 
		menu_tnormal(a->menu_addr, 
			a->evnt.keytable[kindex].mtitle, FALSE);
		begin_update(a);
		(*a->evnt.do_menu)(a, a->evnt.keytable[kindex].mtitle,	
			a->evnt.keytable[kindex].mentry);	
		end_update(a);
	} else {
		/*
		 *	no, then give it to the application
		 */
		wind_get(0, WF_TOP, &wh, &foo, &foo, &foo);	
		if (((wp = find_wind(a, wh)) != NULL) && 
		(wp->evnt.do_keybd != NULL))
			(*wp->evnt.do_keybd)(a, wh, key, keystate);
		else if (a->evnt.usr_keybd != NULL)
			(*a->evnt.usr_keybd)(a, key, keystate);
	}
}

/*
 *	:do_timer()
 *	at the moment it is misused to check the right mouse button
 *	for popup menus (timer_count = 0!!!)
 *	because evnt_multi does NOT support a two button mouse correctly
 */
WORD	do_timer(a)
GEMBUF	*a;
{
	WORD	bstatus, mx, my, kstatus;
	
	graf_mkstate(&mx, &my, &bstatus, &kstatus);
	if (bstatus & 2)	/* right button pressed ? */
		send_msg(MN_POPUP, mx, my, 0, 0, 0);
}

/*
 *	:do_button()
 *	handle button events 
 *	(only left button, right buttons are handled by a special fct)
 */

WORD	do_button(a, clicks, mx, my, button, kstate)
GEMBUF	*a;
WORD	clicks;		/* # of mouse clicks */
WORD	mx, my;		/* mouse coordinates */
WORD	button;		/* which mouse button */
WORD	kstate;		/* status of non-ascii keys (e.g. alt, shift ...) */
{
	WINDOW	*wp;
	WORD	wh, foo;
	WORD	icon;
	
	wind_get(0, WF_TOP, &wh, &foo, &foo, &foo); /* get top window */

	if (((wp = find_wind(a, wh)) == NULL) || 
	(!in_grect(mx, my, &wp->work)) || (wp->evnt.do_button == NULL)) {
		if (a->evnt.usr_button != NULL)
			(*a->evnt.usr_button)(a, wh, mx, my, button, clicks, 
				kstate);
	} 
	else 
		(*(wp->evnt.do_button))(a, wh, mx, my, button, clicks,
				kstate); 
	return SUCCESS;
}

do_m1()
{
}

do_m2()
{
}

/*
 *	:do_redraw()
 *	NEW VERSION (june 89)
 */

WORD	do_redraw(a, wh, x, y, w, h)
GEMBUF 	*a;
WORD	wh;
WORD	x, y, w, h;
{
        GRECT 		t1, t2;
        REG WINDOW 	*wp;

     	t2.g_x = x;
      	t2.g_y = y;
      	t2.g_w = w;
      	t2.g_h = h; 
      	
      	if ((wp = find_wind(a, wh)) == NULL)
      		return FALSE;
      		
      	/*
      	 *	if a WM_SIZED caused this redraw event & xredraw == TRUE
      	 *	then send two redraw events (for each rect inst. of the whole)
      	 */
      	if ((wp->redrawblk.redraw != NULL) && (wp->redraw_evnt == WM_SIZED)) {
		t1.g_x = wp->work.g_x + wp->old.g_w;
		t1.g_y = wp->work.g_y;
		t1.g_w = wp->work.g_w - wp->old.g_w;
		t1.g_h = min(wp->old.g_h, wp->work.g_h);
		
		t2.g_x = wp->work.g_x;
		t2.g_y = wp->work.g_y + wp->old.g_h;
		t2.g_w = wp->work.g_w;
		t2.g_h = wp->work.g_h - wp->old.g_h;
		
		wp->redraw_evnt = WM_REDRAW;
		if ((t1.g_w  > 0) && (t1.g_h > 0))
			clean_wind(a, &t1);
		if ((t2.g_w > 0) && (t2.g_h > 0))
			clean_wind(a, &t2);	/* looks nicer */
		hide_mouse(a);
		if ((t1.g_w > 0) && (t1.g_h > 0)) {
			set_clip(a, TRUE, &t1);
			_xredraw(a, wp, &t1);
			set_clip(a, FALSE, &t1);
		}
		if ((t2.g_w > 0) && (t2.g_h > 0)) {
			set_clip(a, TRUE, &t2);
			_xredraw(a, wp, &t2);
			set_clip(a, FALSE, &t2);
		}
		show_mouse(a);
		
		return TRUE;		/* all done, so leave fct. */
					/* better would be an else, */
					/* but too much tabs !!! */
	}
	
	/*
	 *	normal redraw event (no WM_SIZED), 
	 *	so let's do what we have to do...
	 */
	wp->redraw_evnt = WM_REDRAW;
	
	wind_get(wh, WF_FIRSTXYWH, &t1.g_x, &t1.g_y, &t1.g_w, &t1.g_h);
	while (t1.g_w && t1.g_h) {
		if (rc_intersect(&wp->work, &t1) && rc_intersect(&t2, &t1)) {
			set_clip(a, TRUE, &t1);
			if (wp->redrawblk.redraw != NULL) {
				clean_wind(a, &t1);
				hide_mouse(a);	
				_xredraw(a, wp, &t1);
				show_mouse(a);
			} else if (wp->evnt.do_redraw != NULL) 
				(*(wp->evnt.do_redraw))(a, wh, &t1);
			else 
				clean_wind(a, &t1);
			set_clip(a, FALSE, &t1);
		}
                wind_get(wh, WF_NEXTXYWH, &t1.g_x, &t1.g_y, &t1.g_w, &t1.g_h);
        }
        return TRUE;
}
 

/*
 *	:_xredraw()
 *	calc the start & end column, start & end line and call the
 *	xredraw fcts
 */
 
static WORD _xredraw(a, wp, r)
GEMBUF		*a;
REG WINDOW	*wp;		/* window ptr */
REG GRECT	*r;		/* rectangle to be redrawn */
{	
	WORD 		startcol, endcol;
	WORD 		startline, endline;
	WORD		xc, yc;
	REG WREDRAW	*rb;
	
	if (wp->slide.hdocsize != 0) { /* aligne ??? */
		startcol = wp->slide.hdocpos + (r->g_x - wp->work.g_x) / 
			wp->slide.hdocunit;
		endcol = wp->slide.hdocpos + (r->g_x - wp->work.g_x +
			r->g_w) / wp->slide.hdocunit;
	} else 
		startcol = endcol = 0;
				
	if (wp->slide.vdocsize != 0) { /* aligne ??? */	
		startline = wp->slide.vdocpos + (r->g_y  - wp->work.g_y) / 
			wp->slide.vdocunit;
		endline = wp->slide.vdocpos + (r->g_y - wp->work.g_y + 
			r->g_h) / wp->slide.vdocunit;
	} else
		startline = endline = 0;
					
	xc = wp->work.g_x + ((r->g_x - wp->work.g_x) / wp->slide.hdocunit * 
		 wp->slide.hdocunit);
	yc = wp->work.g_y + ((r->g_y - wp->work.g_y 
		/* + wp->slide.vdocunit - 1*/  ) / 
		wp->slide.vdocunit * 
		wp->slide.vdocunit);
	rc_cpy(r, &wp->redraw_area);
				
	for (rb = &wp->redrawblk; rb != NULL; rb = rb->next) 
		(*rb->redraw)(a, wp, startcol, endcol, startline, endline, 
			xc, yc, rb->xinc, rb->yinc);
}

/*
 *	:do_top()
 */
do_top(a, wi_handle)
GEMBUF	*a;
WORD	wi_handle;	/* window handle */
{
	WINDOW	*wp;
	
	if ((wp = find_wind(a, wi_handle)) == NULL)
		return FAILURE;
		
	wind_set(wi_handle, WF_TOP, wi_handle, 0, 0, 0);
	send_redraw(wi_handle, &wp->work);
	if (wp->evnt.do_top != NULL)
		(*wp->evnt.do_top)(a, wi_handle);
	return SUCCESS;
}


/*
 *	:do_close()
 */
WORD	do_close(a, wi_handle)
GEMBUF	*a;
WORD	wi_handle;
{
	WINDOW	*wp;
	
	if ((wp = find_wind(a, wi_handle)) == NULL)
		return FAILURE;
	
	if ((*wp->evnt.do_preclose) != NULL)
		if ((*wp->evnt.do_preclose)(a, wi_handle) == FALSE)
			return SUCCESS;		/* ?!?!? */
			
	close_wind(a, wi_handle);
	
	if ((*wp->evnt.do_close) != NULL)
		if ((*wp->evnt.do_close)(a, wi_handle))
			delete_wind(a, wi_handle); 

	return SUCCESS;
}

/*
 *	:do_full()
 */
WORD	do_full(a, wh)
GEMBUF 	*a;
WORD 	wh;
{
	           	/* depending on current window state, make window    */
            		/*   full size -or- return to previous shrunken size */
    			/* graf_ calls are optional special effects.         */
        GRECT   prev;
        GRECT   curr;
        GRECT   full;
	WINDOW	*wp;

        wind_get(wh, WF_CURRXYWH, &curr.g_x, &curr.g_y, &curr.g_w, &curr.g_h);
        wind_get(wh, WF_PREVXYWH, &prev.g_x, &prev.g_y, &prev.g_w, &prev.g_h);
        wind_get(wh, WF_FULLXYWH, &full.g_x, &full.g_y, &full.g_w, &full.g_h);
        if ( rc_equal(&curr, &full) )
                {               /* Is full, change to previous          */
                graf_shrinkbox(prev.g_x, prev.g_y, prev.g_w, prev.g_h,
                        full.g_x, full.g_y, full.g_w, full.g_h);
       wind_set(wh, WF_CURRXYWH, prev.g_x, prev.g_y, prev.g_w, prev.g_h);
       wind_get(wh, WF_WORKXYWH, &prev.g_x, &prev.g_y, &prev.g_w, &prev.g_h);
                send_redraw(wh, &prev);
                }
        else
                {               /* is not full, so set to full          */
                graf_growbox(curr.g_x, curr.g_y, curr.g_w, curr.g_h,
                        full.g_x, full.g_y, full.g_w, full.g_h);
         wind_set(wh, WF_CURRXYWH, full.g_x, full.g_y, full.g_w, full.g_h);
         wind_get(wh, WF_WORKXYWH, &prev.g_x, &prev.g_y, &prev.g_w, &prev.g_h);
	 	send_redraw(wh, &prev);
        	}
        if ((wp = find_wind(a, wh)) == NULL)
        	return FAILURE;
        rc_cpy(&wp->work, &wp->old);
	rc_cpy(&prev, &wp->work);
	wind_calc(WC_BORDER, wp->parts, prev.g_x, prev.g_y, prev.g_w, prev.g_h, 
		&wp->border.g_x, &wp->border.g_y, 
		&wp->border.g_w, &wp->border.g_h);
	
	if (wp->slide.vdocunit > 0) {
		WORD 	h = wp->work.g_h / wp->slide.vdocunit;
			
		wp->slide.vdocwindsize = h;	
		wind_set(wp->handle, WF_VSLSIZE, 
			 calc_slider(h, 1000, wp->slide.vdocsize), 
			 0, 0, 0);
		if (wp->slide.vsizesnap && (wp->slide.vdocpos + h) >
		wp->slide.vdocsize) {
			wp->slide.vdocpos = max(wp->slide.vdocsize - h, 0);
		}
		wind_set(wp->handle, WF_VSLIDE, 
				slider_pos(wp->slide.vdocpos,
			 	0, h, 1000, wp->slide.vdocsize), 
			 	0, 0, 0);
	}
	if (wp->slide.hdocunit > 0) {
		WORD 	w = wp->work.g_w / wp->slide.hdocunit;
		
		wp->slide.hdocwindsize = w;
		wind_set(wp->handle, WF_HSLSIZE, 
			calc_slider(w, 1000, wp->slide.hdocsize), 
			0, 0, 0);
		if (wp->slide.hsizesnap && (wp->slide.hdocpos + w) >
		wp->slide.hdocsize) {
			wp->slide.hdocpos = max(wp->slide.hdocsize - w, 0);	
		}
		wind_set(wp->handle, WF_HSLIDE, 
				slider_pos(wp->slide.hdocpos,
			 	0, w, 1000, wp->slide.hdocsize), 
			 	0, 0, 0);
	}

	if (wp->evnt.do_full != NULL)
		(*wp->evnt.do_full)(a, wh);
		
	return SUCCESS;
}

/*
 *	not used anylonger; all done by do_slider()
 */
WORD	do_arrow(a, wh, arrow)	
GEMBUF	*a;
WORD	wh;	/* window handle */ 
WORD	arrow;	/* which arrow */ 
{
	WINDOW	*wp;
	GRECT	r;
	
	if ((wp = find_wind(a, wh)) == NULL)
		return FALSE;

	if (wp->evnt.do_slider != NULL)
		(*wp->evnt.do_slider)(a, wh, WM_ARROWED, arrow);


	/*
	switch (arrow) {
		case WA_DNLINE:
			r.g_x = wp->work.g_x;
			r.g_y = wp->work.g_y + a->gl_hchar;
			r.g_w = wp->work.g_w;
			r.g_h = wp->work.g_h - a->gl_hchar;
			wp->old.g_x = wp->work.g_x;
			wp->old.g_y = wp->work.g_y;
			wp->old.g_w = wp->work.g_w;
			wp->old.g_h = wp->work.g_h - a->gl_hchar;
			break;
		case WA_RTLINE:
			r.g_x = wp->work.g_x + a->gl_wchar;
			r.g_y = wp->work.g_y;
			r.g_w = wp->work.g_w - a->gl_wchar;
			r.g_h = wp->work.g_h;
			wp->old.g_x = wp->work.g_x;
			wp->old.g_y = wp->work.g_y;
			wp->old.g_w = wp->work.g_w - a->gl_wchar;
			wp->old.g_h = wp->work.g_h;
			break;
	} 
	wp->redraw_evnt = WM_ARROWED;
	set_clip(a, TRUE, &wp->work);
	hndl_textredraw(a, whm &r);
	set_clip(a, FALSE, &wp->work);
	*/
	
}

do_vslid()
{
}


do_hslid()
{
}
/*
 *	:do_size()
 */
WORD do_size(a, wh, x, y , w, h)
GEMBUF 	*a;
WORD 	wh;		/* window handle */
WORD 	x, y, w, h;	/* new coordinates */
{
	WINDOW 	*wp;
	GRECT 	r1, r2;
	WORD	pxy[8];
	
	if ((wp = find_wind(a, wh)) != NULL) {
		w = (w < (4 * a->gl_hbox)) ? (4 * a->gl_hbox) : w;
		h = (h < (4 * a->gl_hbox)) ? (4 * a->gl_hbox) : h;
		rc_cpy(&(wp->work), &(wp->old)); 
		wind_calc(WC_WORK, wp->parts, x, y, w, h, &wp->work.g_x, 
			&wp->work.g_y, &wp->work.g_w, &wp->work.g_h);

		wp->work.g_w = align(wp->work.g_w, wp->align.g_w);
		wp->work.g_h = align(wp->work.g_h, wp->align.g_h);
				
		wind_calc(WC_BORDER, wp->parts, wp->work.g_x, wp->work.g_y, 
			wp->work.g_w, wp->work.g_h, &wp->border.g_x,
			&wp->border.g_y, &wp->border.g_w, &wp->border.g_h);
		wind_set(wh, WF_CURRXYWH, wp->border.g_x, wp->border.g_y, 
			wp->border.g_w, wp->border.g_h);
		/*
		 *	if new size < old size we don't set WM_SIZED 
		 *	because otherwise we get problems in our redraw
		 *	fct when after that sizing a new window (acc) is
		 *	selected and produces a redraw event for our window
		 */
		if ((wp->work.g_w >= wp->old.g_w) || 
		(wp->work.g_h >= wp->old.g_h)) {
			wp->redraw_evnt = WM_SIZED;
		}
		if (wp->slide.vdocunit > 0) {
			WORD 	h = wp->work.g_h / wp->slide.vdocunit;
		
			wp->slide.vdocwindsize = h;	
			wind_set(wp->handle, WF_VSLSIZE, 
				 calc_slider(h, 1000, wp->slide.vdocsize), 
				 0, 0, 0);
			if (wp->slide.vsizesnap && (wp->slide.vdocpos + h) >
			wp->slide.vdocsize) {
				WORD	vdp = wp->slide.vdocpos;
				
				wp->slide.vdocpos = 
					max(wp->slide.vdocsize - h, 0);
					
				if (wp->slide.vdocpos != vdp) {
					wp->redraw_evnt = WM_REDRAW; 
							/* rewdraw all */
				}
			}
			wind_set(wp->handle, WF_VSLIDE, 
				slider_pos(wp->slide.vdocpos,
				0, h, 1000, wp->slide.vdocsize), 
				0, 0, 0);
		}
		if (wp->slide.hdocunit > 0) {
			WORD 	w = wp->work.g_w / wp->slide.hdocunit;
			
			wp->slide.hdocwindsize = w;	
			wind_set(wp->handle, WF_HSLSIZE, 
				calc_slider(w, 1000, wp->slide.hdocsize), 
				0, 0, 0);
			if (wp->slide.hsizesnap && (wp->slide.hdocpos + w) >
			wp->slide.hdocsize) {
				WORD	hdp = wp->slide.hdocpos;
				
				wp->slide.hdocpos = 
					max(wp->slide.hdocsize - w, 0);	

				if (wp->slide.hdocpos != hdp) {
					wp->redraw_evnt = WM_REDRAW; 
							/* rewdraw all */
				}
			}
			wind_set(wp->handle, WF_HSLIDE, 
				slider_pos(wp->slide.hdocpos,
				0, w, 1000, wp->slide.hdocsize), 
				0, 0, 0);
		}
	
		if (wp->evnt.do_size != NULL)
			(*wp->evnt.do_size)(a, wh);
	
	}
		
}

/*
 *	:do_move()
 *	std window moving routine
 */

WORD 	do_move(a, wh, x, y , w, h)
GEMBUF 	*a;
WORD 	wh;		/* window handle */
WORD 	x, y, w, h;	/* new coordinates */
{
	WINDOW *wp;
	
	if ((wp = find_wind(a, wh)) != NULL) {
		if (wp->evnt.do_premove != NULL)
			(*wp->evnt.do_premove)(a, wh);
			
		if (y < (a->desk.g_y + 1))
			y = a->desk.g_y + 1;
		wind_calc(WC_WORK, wp->parts, x, y, w, h, &(wp->work.g_x), 
			&(wp->work.g_y), &(wp->work.g_w), &(wp->work.g_h));
		
		if (wp->align.g_x > 1)	
			wp->work.g_x = align(wp->work.g_x, wp->align.g_x);
		if (wp->align.g_y > 1)	
			wp->work.g_y = align(wp->work.g_y, wp->align.g_y);
		wp->old.g_x = wp->work.g_x;	/* ??? */
		wp->old.g_y = wp->work.g_y;	
	
		wind_calc(WC_BORDER, wp->parts, wp->work.g_x, wp->work.g_y, 
			wp->work.g_w, wp->work.g_h, &wp->border.g_x, 
			&wp->border.g_y, &wp->border.g_w, &wp->border.g_h);
		wind_set(wh, WF_CURRXYWH, wp->border.g_x, wp->border.g_y, 
			wp->border.g_w, wp->border.g_h);
		if (wp->evnt.do_move != NULL)
			(*wp->evnt.do_move)(a, wh);
	}
	
}

/*
 *	:do_newtop()
 */

do_newtop(a, wi_handle)
GEMBUF	*a;
WORD	wi_handle;	/* window handle */
{
	WINDOW	*wp;
	
	if ((wp = find_wind(a, wi_handle)) == NULL)
		return FAILURE;
		
	/*
	wind_set(wi_handle, WF_TOP, wi_handle, 0, 0, 0);
	send_redraw(wi_handle, &wp->work);
	*/
	if (wp->evnt.do_newtop != NULL)
		(*wp->evnt.do_newtop)(a, wi_handle);
		
	return SUCCESS;
}


#ifdef ACC
do_accopen()
{
}

do_accclose()
{
}
#endif



/*
 *	:do_slider()
 *	NEW VERSION (June 89)
 *	will cause to update all old window gemlib appl.
 *	do_redraw also changed
 */

LOCAL WORD do_slider(a, wh, sld_evnt, sldpos)

GEMBUF	*a;
WORD	wh;
WORD	sld_evnt;
WORD	sldpos;
{
	REG WINDOW	*wp;		
	WORD		foo;		/* dummy */
	WORD		sx, sy, sw, sh, dx, dy, dw, dh; /* deltas for cpy_r */
	WORD		startcol, endcol, startline, endline; /* redraw */
	WORD		x, y;		/* x, y coord where redraw will start */
	GRECT		src, dst;	/* copy raster src & dest rect */
	GRECT		area;		/* redraw area */
	GRECT		work;		/* window work area */
	WORD		mx, my, ms, ks; /* mouse statuts */
	WORD		hslide = FALSE;	/* flag if hslider has to be updated */
	WORD		vslide = FALSE; /*	   vslider		     */
	WORD		seen_doc_w;	/* seen doc in units */
	WORD		seen_doc_h;
	WORD		pos;		/* new doc pos after slider was moved */
	REG WREDRAW	*rb;
	
	if ((wp = find_wind(a, wh)) == NULL)
		return FAILURE;

	wp->redraw_evnt = sld_evnt;
	/*
	 *	for special cases, like our desktop...
	 */
	if (a->evnt.before_do_slider != NULL)
		(*a->evnt.before_do_slider)(a, wh, sld_evnt, sldpos);
	/*
	 *	copy work area rect & calc size of seen doc
	 */
	work.g_x = wp->work.g_x;
	work.g_y = wp->work.g_y;
	work.g_w = ((wp->work.g_x + wp->work.g_w) > 
		(a->desk.g_x + a->desk.g_w)) ?
		((a->desk.g_x + a->desk.g_w) - work.g_x) : wp->work.g_w;
	work.g_h = ((wp->work.g_y + wp->work.g_h) > 
		(a->desk.g_y + a->desk.g_h)) ?
		((a-> desk.g_y + a->desk.g_h) - work.g_y) : wp->work.g_h;
			
	seen_doc_w = work.g_w / wp->slide.hdocunit;
	seen_doc_h = work.g_h / wp->slide.vdocunit;

 begins:
 	sx = sy = sw = sh = 0;
 	dx = dy = dw = dh = 0;

	switch (sld_evnt) {
	case WM_HSLID:
		pos = (WORD) ((LONG) sldpos * 
			(LONG)(wp->slide.hdocsize - seen_doc_w) / 1000L);

		if (pos == wp->slide.hdocpos)
			goto ends;
		if ((pos < (wp->slide.hdocpos + seen_doc_w - 1)) && 
		(pos > (wp->slide.hdocpos - seen_doc_w + 1))) {
			if (pos > wp->slide.hdocpos) {
				sx = (pos - wp->slide.hdocpos) * 
					wp->slide.hdocunit;
				dw = sw = -sx;
				
				area.g_x = work.g_x + work.g_w - sx;
				area.g_y = work.g_y;
				area.g_w = sx;  
				area.g_h = work.g_h;
			} else {
				dx = (wp->slide.hdocpos - pos) * 
					wp->slide.hdocunit;
				dw = sw = -dx;
				
				area.g_x = work.g_x;
				area.g_y = work.g_y;
				area.g_w = dx;  
				area.g_h = work.g_h;
			}
		} else
			rc_cpy(&wp->work, &area);

		wp->slide.hdocpos = pos;
		hslide = TRUE;
		break;
	case WM_VSLID:
		pos = (WORD) ((LONG) sldpos * 
			(LONG)(wp->slide.vdocsize - seen_doc_h) / 1000L);

		if (pos == wp->slide.vdocpos)
			goto ends;
		if ((pos < (wp->slide.vdocpos + seen_doc_h - 1)) && 
		(pos > (wp->slide.vdocpos - seen_doc_h + 1))) {
			if (pos > wp->slide.vdocpos) {
				sy = (pos - wp->slide.vdocpos) * 
					wp->slide.vdocunit;
				dh = sh = -sy;
				
				area.g_x = work.g_x;
				area.g_y = work.g_y + work.g_h - sy;
				area.g_w = work.g_w;  
				area.g_h = sy;
			} else {
				dy = (wp->slide.vdocpos - pos) * 
					wp->slide.vdocunit;
				dh = sh = -dy;
				
				area.g_x = work.g_x;
				area.g_y = work.g_y;
				area.g_w = work.g_w;  
				area.g_h = dy;
			}
		} else
			rc_cpy(&wp->work, &area);

		wp->slide.vdocpos = pos;
		vslide = TRUE;
		break;
	case WA_UPPAGE:
		if (wp->slide.vdocpos <= 0)
			goto ends;
		wp->slide.vdocpos = max(wp->slide.vdocpos - seen_doc_h, 0);
		rc_cpy(&work, &area);
		vslide = TRUE;
		break;
	case WA_DNPAGE:
		if ((wp->slide.vdocpos + (work.g_h / wp->slide.vdocunit)) >=
		wp->slide.vdocsize)
			goto ends;
		wp->slide.vdocpos = min(wp->slide.vdocpos + seen_doc_h, 
				wp->slide.vdocsize - seen_doc_h);
		rc_cpy(&wp->work, &area);
		vslide = TRUE;
		break;
	case WA_RTPAGE:
		if ((wp->slide.hdocpos + (work.g_w / wp->slide.hdocunit)) >=
		wp->slide.hdocsize)
			goto ends;
		wp->slide.hdocpos = min(wp->slide.hdocpos + seen_doc_w, 
				wp->slide.hdocsize - seen_doc_w);
		rc_cpy(&wp->work, &area);
		hslide = TRUE;
		break;
	case WA_LTPAGE:	
		if (wp->slide.hdocpos <= 0)
			goto ends;
		wp->slide.hdocpos = max(wp->slide.hdocpos - seen_doc_w, 0);
		rc_cpy(&work, &area);
		hslide = TRUE;
		break;
	case WA_DNLINE:
		if ((wp->slide.vdocpos + seen_doc_h + 1) > wp->slide.vdocsize)
			goto ends;
			
		wp->slide.vdocpos += 1;
		sy = wp->slide.vdocunit;  
		dy = 0;
		dh = sh = (-wp->slide.vdocunit); 
		sx = 0; dx = 0; sw = 0; dw = 0; 
		
		area.g_x = work.g_x;
		area.g_y = work.g_y + work.g_h - wp->slide.vdocunit;
		area.g_w = work.g_w;
		area.g_h = wp->slide.vdocunit;
		vslide = TRUE;
		break;
	case WA_UPLINE:
		if (wp->slide.vdocpos <= 0)
			goto ends;
			
		wp->slide.vdocpos -= 1;
		sy = 0;  
		dy = wp->slide.vdocunit;  
		dh = sh = (-wp->slide.vdocunit); 
		sx = 0; dx = 0; sw = 0; dw = 0; 
		
		area.g_x = work.g_x;
		area.g_y = work.g_y;
		area.g_w = work.g_w;
		area.g_h = wp->slide.vdocunit;
		vslide = TRUE;
		break;
	case WA_RTLINE:
		if ((wp->slide.hdocpos + seen_doc_w + 1) > wp->slide.hdocsize)
			goto ends;
			
		wp->slide.hdocpos += 1;
		sx = wp->slide.hdocunit;  
		dx = 0;
		dw = sw = (-wp->slide.hdocunit); 
		sy = 0; dy = 0; sh = 0; dh = 0; 
		
		area.g_x = work.g_x + work.g_w - wp->slide.hdocunit;
		area.g_y = work.g_y;
		area.g_w = wp->slide.hdocunit;
		area.g_h = work.g_h;
		hslide = TRUE;
		break;
	case WA_LTLINE:
		if (wp->slide.hdocpos <= 0)
			goto ends;
			
		wp->slide.hdocpos -= 1;
		sx = 0;
		dx = wp->slide.hdocunit;
		dw = sw = (-wp->slide.hdocunit); 
		sy = 0; dy = 0; sh = 0; dh = 0; 
		
		area.g_x = work.g_x;
		area.g_y = work.g_y;
		area.g_w = wp->slide.hdocunit;
		area.g_h = work.g_h;
		hslide = TRUE;
		break;
	default:
		return FAILURE;		/* unknown event */
		break;
	}
 	hide_mouse(a);
 	
	/*
	 *	make the copy raster if needed
	 */
	if ((sx != 0) || (sy != 0) || (dx != 0) || (dy != 0)) {
		src.g_x = work.g_x + sx;
		src.g_y = work.g_y + sy;
		src.g_w = work.g_w + sw;
		src.g_h = work.g_h + sh;
		dst.g_x = work.g_x + dx;
		dst.g_y = work.g_y + dy;
		dst.g_w = work.g_w + dw;
		dst.g_h = work.g_h + dh;
		copy_area(a, &src, &dst);
	}

	/*
	 *	now call user redraw fct
	 */
	startcol = wp->slide.hdocpos + (area.g_x - work.g_x) / 
			wp->slide.hdocunit;
	endcol =  wp->slide.hdocpos + (area.g_x - work.g_x + area.g_w) / 
			wp->slide.hdocunit;
	startline = wp->slide.vdocpos + (area.g_y - wp->work.g_y) / 
			wp->slide.vdocunit;
	endline =  wp->slide.vdocpos + (area.g_y - work.g_y + area.g_h) / 
			wp->slide.vdocunit;
	x = work.g_x + ((area.g_x - work.g_x) / wp->slide.hdocunit * 
		wp->slide.hdocunit);
	y = work.g_y + ((area.g_y - work.g_y) / wp->slide.vdocunit * 
		wp->slide.vdocunit);

	rc_cpy(&area, &wp->redraw_area);
	

	set_clip(a, TRUE, &area);
	clean_wind(a, &area);
	
	for (rb = &wp->redrawblk; rb != NULL; rb = rb->next) {
		(*(rb->redraw))(a, wp, startcol, endcol, startline, endline, 
			x, y, rb->xinc, rb->yinc);
	}
	show_mouse(a);
	set_clip(a, FALSE, &area);
	
	/*
	 *	look if button still pressed
	 */
	graf_mkstate(&mx, &my, &ms, &ks);

	if (ms & 1)			/* left button still pressed */
		goto begins;		/* play it again sam */
		
	/*
	 *	now update slider pos
	 *	not done in loop, because it will slow it down (?!)
	 */
 ends:
	if (hslide) {
		wind_set(wp->handle, WF_HSLIDE, slider_pos(wp->slide.hdocpos,
		  0, wp->work.g_w / wp->slide.hdocunit, 1000, 
		  wp->slide.hdocsize), 0, 0, 0);
	}
	if (vslide) {
		wind_set(wp->handle, WF_VSLIDE, slider_pos(wp->slide.vdocpos,
		  0, wp->work.g_h / wp->slide.vdocunit, 1000, 
		  wp->slide.vdocsize), 0, 0, 0);
	}

	return SUCCESS;
}

