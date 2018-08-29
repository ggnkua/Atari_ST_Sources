/*                
 *	module:	window.c
 *	
 *	this is an unpublished work, written by Hans-Martin Kroeber
 *
 *	Copyright 1988 by venator software
 */

#include <gemlib.h>

/*
 *	in test:
 */

WORD	hndl_txtredraw();


/*
 *	:create_window(a, type, WINDOW_ARG_TYPE, WINDOW_ARG, ..., 0)
 *	GEMBUF	*a;
 *	WORD	type;		/ type of window, e.g. EDITOR, TEXT, PAINT../
 *	WORD	WINDOW_ARG_TYPE;/ e.g. NAME, CLOSE, INFO, ... /
 *	????	WINDOW_ARG 	/ ARG, e.g. window name, fct for silder up,../
 *
 *	see docs (if they exist)	
 *
 *	STILL IN WORK!
 */
 
WINDOW	*create_wind(va_alist)
va_dcl
{
	va_list		ap;		/* ptr to arg list */
	REG WORD	arg_type;	/* current argument type */
	GEMBUF		*a;		/* gemlib buffer pointer */
	WINDOW		*wp;		/* ptr to new window */
	WORD		coord_kind;	/* kind of given coord: WORK | BORDER */
	GRECT		area;		/* given window area */
	GRECT		tr;		/* temp rectangle */
	REG WREDRAW	*rb, *rbp;	/* ptr to redraw block list */
	WORD		cwcoord = FALSE;
	WORD		dummy;
	BYTE		*cp;
	WORD		strlen();
	BYTE 		*vcalloc();
	
	va_start(ap);
	
	a = (GEMBUF *) va_arg(ap, GEMBUF *);

	/*
	 *	open not more than MAXWIND
	 */
	if ((a->wind_count + 1) > MAXWIND) {
		errmsg(ENOWIND);
		return NULL;
	}

	begin_update(a);
	/* 	
	 *	get window pointer, if no memory call gem error 
	 */
	
	if ((wp = (WINDOW *) vcalloc(a, 1, sizeof(WINDOW))) == NULL) { 
		end_update(a);
		errmsg(EWNOMEM);
		return NULL;
	}
	/* 
	 *	insert window into window list	
	 */		
	if (!a->wind_count) {	/* if first window */
		wp->prev = NULL;
		wp->next = NULL;
		a->wind = wp;	/* set pointer to first wind in GEMBUF */
	}
	else {
		WINDOW *vp;
		
		vp = last_wind(a);
		vp->next = wp;
		wp->prev = vp;
		wp->next = NULL;
	}
	a->wind_count++;	

	area.g_x = -1;

	/*
	 *	set up window struct
	 */
	wp->type = va_arg(ap, WORD);
	
	wp->status = CLOSE;

	wp->slide.hdocsize = 0;
	wp->slide.hdocunit = 1;
	wp->slide.hdocpos = 0;
	wp->slide.vdocsize = 0;
	wp->slide.vdocunit = 1;
	wp->slide.vdocpos = 0;
	
	
	switch (wp->type) {
	case WT_DF:			/* dailog form window */
		break;
	case WT_GRAPH:
		break;
	case WT_TEXT:
		wp->align.g_x = a->gl_wchar;
		wp->align.g_y = 1;
		wp->align.g_w = a->gl_wchar;
		wp->align.g_h = a->gl_hchar;
		/*
		 *	get memory to hold memory screen
		 *	this one is text oriented, so we don't need so much
		 *	we calc the follwing way: 
		 *	needed memory = (deskwidth / charwidth) *
		 *			(deskheigth / charheigth)
		 */
		wp->scrnbuf.w = a->desk.g_w;
		wp->scrnbuf.h = a->desk.g_h;
		wp->scrnbuf.b_w = wp->scrnbuf.w / a->gl_wchar;	
		wp->scrnbuf.b_h = wp->scrnbuf.h / a->gl_hchar;	
		wp->scrnbuf.planes = 1; /* no color chars (not an amiga) */
		wp->scrnbuf.xoff = 0;
		wp->scrnbuf.yoff = 0;
		wp->scrnbuf.cols = wp->scrnbuf.b_w; /* should be a parameter */
		wp->scrnbuf.lines = wp->scrnbuf.b_h;

		if ((wp->scrnbuf.addr = vmalloc(a, wp->scrnbuf.cols * 
		wp->scrnbuf.lines)) == NULL)
			return NULL;
		/* 
		 *	clear screen (fill buffer with spaces)
  		 */
		wind_clr_txtbuf(wp);
			
		wp->evnt.do_redraw = hndl_txtredraw;
		break;
		
	case WT_EDITOR:
		wp->align.g_x = a->gl_wchar;
		wp->align.g_y = 1;
		wp->align.g_w = a->gl_wchar;
		wp->align.g_h = a->gl_hchar;
		/*
		 *	get memory to hold memory screen
		 *	this one is text oriented, so we don't need so much
		 *	we calc the follwing way: 
		 *	needed memory = (deskwidth / charwidth) *
		 *			(deskheigth / charheigth)
		 */

		wp->scrnbuf.w = a->desk.g_w;
		wp->scrnbuf.h = a->desk.g_h;
		wp->scrnbuf.b_w = wp->scrnbuf.w / a->gl_wchar;	
		wp->scrnbuf.b_h = wp->scrnbuf.h / a->gl_hchar;	
		wp->scrnbuf.planes = 1; /* no color chars (not an amiga) */
		wp->scrnbuf.xoff = 0;
		wp->scrnbuf.yoff = 0;
		wp->scrnbuf.cols = wp->scrnbuf.b_w;	/* ??? */		
		wp->scrnbuf.lines = wp->scrnbuf.b_h;

		if ((wp->scrnbuf.addr = vmalloc(a, wp->scrnbuf.cols * 
		wp->scrnbuf.lines)) == NULL)
			return NULL;
		/* 
		 *	clear screen (fill buffer with spaces)
  		 */
		wind_clr_txtbuf(wp);

		
		wp->evnt.do_redraw = hndl_txtredraw;
		/* wp->evnt.do_redraw = redraw_textwind; */
		/*
		 *	build first line
		 */
		if ((((EDITINF *)wp->conbuf) = 
		(EDITINF *) vmalloc(a, sizeof(EDITINF))) == NULL)
		    	return NULL;
		    	
		if ((((EDITINF *)wp->conbuf)->currline = 
		(EDITINF *) vmalloc(a, sizeof(EDITLIN))) == NULL)
		    	return NULL;
		  
		((EDITINF *)wp->conbuf)->firstline = 
			((EDITINF *)wp->conbuf)->currline;
		((EDITINF *)wp->conbuf)->lastline = 
			((EDITINF *)wp->conbuf)->currline;
		((EDITLIN *)((EDITINF *)wp->conbuf)->currline)->prev =
			 NULL;
		((EDITLIN *)((EDITINF *)wp->conbuf)->currline)->next =
			 NULL;
		WED_LINECONTXT(wp) = NULL;
			    	
		WED_LINEBUF(wp)[0] 	= CR;
		WED_LINEBUF(wp)[1]	= LF;
		WED_LINEBUF(wp)[2] 	= '\0';
			
		WED_CURS_X(wp) 	= 0;
		WED_CURS_Y(wp) 	= 1;	
		WED_PREV_CURS_X(wp)	= 0;
		WED_PREV_CURS_Y(wp)	= 1;
		WED_LAST_CURS_X(wp)	= 0;
		WED_LAST_CURS_Y(wp)	= 1;

		WED_TAB_SIZE(wp) = 8;

		WED_FIRSTWINDLINE(wp) = WED_FIRSTLINE(wp);
		WED_LASTWINDLINE(wp) = NULL;	/* ???? */
				
		break;
	default:
		wp->align.g_x = 1;	
		wp->align.g_y = 1;
		wp->align.g_w = 1;
		wp->align.g_h = 1;
		break;
	}
	/*
	 *	build header for redraw list
	 */
	rb = &wp->redrawblk;
	rb->next = NULL;
	rbp = NULL;
	
	wp->evnt.do_keybd = NULL;

	/*
	 *	evaluate aruments
	 */
	while ((arg_type = va_arg(ap, WORD)) != 0) {
		switch (arg_type) {
		case CW_NAME:
			cp = va_arg(ap, BYTE *);
			if ((wp->name = vmalloc(a, strlen(cp) + 1)) == NULL)
				return NULL;
			strcpy(wp->name, cp);
			wp->parts |= NAME;
			break;
		case CW_CLOSER:
			wp->evnt.do_close =  va_arg(ap, WFCTP);
			wp->parts |= CLOSER;
			break;
		case CW_PRECLOSE:
			wp->evnt.do_preclose =  va_arg(ap, WFCTP);
			break;
		case CW_FULLER:
			wp->evnt.do_full =  va_arg(ap, WFCTP);
			wp->parts |= FULLER;
			break;
		case CW_MOVER:
			wp->evnt.do_move =  va_arg(ap, WFCTP);
			wp->parts |= MOVER;
			break;
		case CW_PREMOVE:
			wp->evnt.do_premove =  va_arg(ap, WFCTP);
			break;
		case CW_INFO:
			cp = va_arg(ap, BYTE *);
			if ((wp->info = vmalloc(a, strlen(cp) + 1)) == NULL)
				return NULL;
			strcpy(wp->info, cp);
			wp->parts |= INFO;
			break;
		case CW_SIZER:
			wp->parts |= SIZER;
			wp->evnt.do_size =  va_arg(ap, WFCTP);
			break;
		case CW_SLIDER:
			wp->parts |= va_arg(ap, WORD);
			wp->evnt.do_slider = va_arg(ap, WFCTP);
			wp->slide.do_slider = wp->evnt.do_slider;
			break;
		case CW_TOP:
			wp->evnt.do_top = va_arg(ap, WFCTP);
			break;
		case CW_NEWTOP:
			wp->evnt.do_newtop = va_arg(ap, WFCTP);
			break;
		case CW_BUTTON:
			wp->evnt.do_button = va_arg(ap, WFCTP);
			break;
		case CW_KEYBD:
			wp->evnt.do_keybd = va_arg(ap, WFCTP);
			break;
		case CW_REDRAW:
			wp->evnt.do_redraw = va_arg(ap, WFCTP);
			break;
		case CW_XREDRAW:
			rb->redraw = va_arg(ap, WFCTP);
			rb->xinc = va_arg(ap, WORD);
			rb->yinc = va_arg(ap, WORD);
			if ((rb->next = (WREDRAW *) vmalloc(a, sizeof(WREDRAW)))
			== NULL)
				return NULL;
			rbp = rb;		/* save ptr to prev element */
			rb = rb->next;
			rb->next = NULL;
			break;
		case CW_EVNTS:
			/*
			 */

			break;	
		case CW_COORD:
			cwcoord = TRUE;
			wp->status = va_arg(ap, WORD);
			coord_kind = va_arg(ap, WORD);
			area.g_x = va_arg(ap, WORD);
			area.g_y = va_arg(ap, WORD);
			area.g_w = va_arg(ap, WORD);
			area.g_h = va_arg(ap, WORD);
			if ((dummy = va_arg(ap, WORD)) != -1) {
				wp->align.g_x = dummy;
				wp->align.g_y = va_arg(ap, WORD);
				wp->align.g_w = va_arg(ap, WORD);
				wp->align.g_h = va_arg(ap, WORD);
			}
			else {
				dummy = va_arg(ap, WORD);
				dummy = va_arg(ap, WORD);
				dummy = va_arg(ap, WORD);
			}
			arg_type = 0;
			break;
		case CW_HSIZE:
			wp->slide.hdocsize = va_arg(ap, WORD);
			wp->slide.hdocunit = va_arg(ap, WORD);
			wp->slide.hdocpos = 0;
			break;
		case CW_VSIZE:
			wp->slide.vdocsize = va_arg(ap, WORD);
			wp->slide.vdocunit = va_arg(ap, WORD);
			wp->slide.vdocpos = 0;
			break;
		case CW_HSIZESNAP:
			wp->slide.hsizesnap = va_arg(ap, WORD);
			break;
		case CW_VSIZESNAP:
			wp->slide.vsizesnap = va_arg(ap, WORD);
			break;
		case CW_POPUP:
			init_popup(a, &wp->popup, (BYTE *) va_arg(ap, BYTE *));
			wp->popup.usr_popup = (WFCTP) va_arg(ap, WFCTP);
			break;
		case CW_CONTEXT:
			wp->conbuf = va_arg(ap, BYTE *);
			break;
		}
		
	}	

	va_end(ap);
	
	/*
	 *	del last element of redraw blk list
	 */
	if (rbp != NULL) {
		rbp->next = NULL;
		vfree(a, rb);
	}
	/*
	 *	calc max window size & set max and min window size
	 */
	wind_calc(WC_WORK, wp->parts, 
		a->desk.g_x, a->desk.g_y + 1, a->desk.g_w, a->desk.g_h - 1,
		&tr.g_x, &tr.g_y, &tr.g_w, &tr.g_h);
	wind_calc(WC_BORDER, wp->parts,
		align(tr.g_x, wp->align.g_x), align(tr.g_y, wp->align.g_y),
		align(tr.g_w, wp->align.g_w), align(tr.g_h, wp->align.g_h),
		&wp->max.g_x, &wp->max.g_y, &wp->max.g_w, &wp->max.g_h);
	wp->min.g_x = 0;
	wp->min.g_y = 0;
	wp->min.g_w = 4 * a->gl_hchar;
	wp->min.g_h = 4 * a->gl_hchar;
	/*
	 *	create wind
	 */
	if ((wp->handle = wind_create(wp->parts, wp->max)) < 0) {
		end_update(a);
		errmsg(ENOWIND);
		vfree(a, wp);
		return NULL;
	}
	/*
	 *	set name and info line
	 */
	if (wp->parts & NAME)
		wind_set(wp->handle, WF_NAME, wp->name, wp->name);
	if (wp->parts & INFO)
		wind_set(wp->handle, WF_INFO, wp->info, wp->info);	
	/* 
	 *	calc window coordinates and size 	
	 */
	if (area.g_x == -1) {/* gemlib shall set coordinates */
		wp->status = OPEN;
		wp->work.g_x = a->desk.g_x + (a->gl_hchar << a->wind_count);
		wp->work.g_y = a->desk.g_y + (a->gl_hchar << a->wind_count);
		wp->work.g_w = a->desk.g_w - wp->work.g_x - 
				(a->gl_hchar << a->wind_count);
		wp->work.g_h = a->desk.g_h - wp->work.g_y - 
				(a->gl_hchar << a->wind_count);
				
		wp->work.g_x = (wp->work.g_x < wp->min.g_x) ?
				 wp->min.g_x : wp->work.g_x;
		wp->work.g_y = (wp->work.g_y < wp->min.g_y) ?
				 wp->min.g_y : wp->work.g_y;
		wp->work.g_w = (wp->work.g_w < wp->min.g_w) ?
				 wp->min.g_w : wp->work.g_w;
		wp->work.g_h = (wp->work.g_h < wp->min.g_h) ?
				 wp->min.g_h : wp->work.g_h;
				 
		wind_calc(WC_BORDER, wp->parts, wp->work, 
			&wp->border.g_x, &wp->border.g_y,
			&wp->border.g_w, &wp->border.g_h);
	}
	else {
		if (coord_kind == WC_BORDER) 	/* calc work coordinates */
			wind_calc(WC_WORK, wp->parts, area, 
				&wp->work.g_x, &wp->work.g_y, 
				&wp->work.g_w, &wp->work.g_h);
		else
			rc_cpy(&area, &wp->work);
		align_rect(&wp->work, &wp->align);
		wind_calc(WC_BORDER, wp->parts, area, 
			&wp->border.g_x, &wp->border.g_y, 
			&wp->border.g_w, &wp->border.g_h);
		if (out_desk(a, &wp->border))
			rc_cpy(&wp->max, &wp->border);
	}
	rc_cpy(&wp->work, &wp->old);

	/*
	 *	set slider sizes
	 */
	if ((wp->parts & HSLIDE) && (wp->slide.hdocsize != 0) && 
	(wp->slide.hdocunit != 0)) {
		wp->slide.hdocwindsize = wp->work.g_w / wp->slide.hdocunit;	
		wind_set(wp->handle, WF_HSLSIZE, 
			calc_slider(wp->slide.hdocwindsize, 1000,
			wp->slide.hdocsize), 0, 0, 0);
	}
	if ((wp->parts & VSLIDE) && (wp->slide.vdocsize != 0) && 
	(wp->slide.vdocunit != 0)) {
		wp->slide.vdocwindsize = wp->work.g_h / wp->slide.vdocunit;	
		wind_set(wp->handle, WF_VSLSIZE, 
			calc_slider(wp->slide.vdocwindsize, 1000,
			wp->slide.vdocsize), 0, 0, 0);
	}
				
		
	/* 
	 *	open window
	 */
	if (wp->status == OPEN) {
		if (a->open_wind >= MAXOPENWIND) {
			errmsg(ENOOPWIND);
			wp->status = CLOSE;
		} else {	
			a->open_wind++;
			graf_growbox(wp->border.g_x + (wp->border.g_w / 2), 
				wp->border.g_y + (wp->border.g_h / 2),
				a->gl_wbox, a->gl_hbox, 
				wp->border.g_x, wp->border.g_y, 
				wp->border.g_w, wp->border.g_h);
			wind_open(wp->handle, 
				wp->border.g_x,	wp->border.g_y, 
				wp->border.g_w, wp->border.g_h);
			clean_wind(a, &wp->work);
		}
	}
	end_update(a);	

	return wp;			
}

/*
 *	:change_wind(a, wp, WINDOW_ARG_TYPE, WINDOW_ARG, ...)
 *	GEMBUF *a;
 *	WINDOW *wp;
 *	change window structure (param. see above at create_wind & docs)
 *	NOTE: as many others, this routine is still in WORK!
 */

WORD	change_wind(va_alist)
va_dcl
{

	va_list	ap;
	GEMBUF	*a;
	WINDOW	*wp;
	WORD	arg_type;
	WORD	dummy;
	WORD	coord_kind;
	GRECT	area;
	BYTE	*cp;
	
	va_start(ap);
	
	a = va_arg(ap, GEMBUF *);
	wp = va_arg(ap, WINDOW *);
	
	while ((arg_type = va_arg(ap, WORD)) != 0) {
		switch (arg_type) {
		case CW_NAME:
			cp = va_arg(ap, BYTE *);
			if ((wp->parts & NAME) && (wp->name != NULL))
				vfree(a, wp->name);
			if ((wp->name = vmalloc(a, strlen(cp) + 1)) == NULL)
				return FAILURE;
			strcpy(wp->name, cp);
			wp->parts |= NAME;
			wind_set(wp->handle, WF_NAME, wp->name, wp->name);
			break;
		case CW_CLOSER:
			wp->evnt.do_close =  va_arg(ap, WFCTP);
			wp->parts |= CLOSER;
			break;
		case CW_PRECLOSE:
			wp->evnt.do_preclose =  va_arg(ap, WFCTP);
			break;
		case CW_FULLER:
			wp->evnt.do_full =  va_arg(ap, WFCTP);
			wp->parts |= FULLER;
			break;
		case CW_MOVER:
			wp->evnt.do_move =  va_arg(ap, WFCTP);
			wp->parts |= MOVER;
			break;
		case CW_PREMOVE:
			wp->evnt.do_premove =  va_arg(ap, WFCTP);
			break;
		case CW_INFO:
			cp = va_arg(ap, BYTE *);
			if ((wp->parts & INFO) && (wp->info != NULL))
				vfree(a, wp->info);
			if ((wp->info = vmalloc(a, strlen(cp) + 1)) == NULL)
				return FAILURE;
			strcpy(wp->info, cp);
			wp->parts |= INFO;
			wind_set(wp->handle, WF_INFO, wp->info, wp->info);
			break;
		case CW_SIZER:
			wp->parts |= SIZER;
			wp->evnt.do_size =  va_arg(ap, WFCTP);
			break;
		case CW_SLIDER:
			wp->parts |= va_arg(ap, WORD);
			wp->evnt.do_slider = va_arg(ap, WFCTP);
			wp->slide.do_slider = wp->evnt.do_slider;
			break;
		case CW_TOP:
			wp->evnt.do_top = va_arg(ap, WFCTP);
			break;
		case CW_NEWTOP:
			wp->evnt.do_newtop = va_arg(ap, WFCTP);
			break;
		case CW_BUTTON:
			wp->evnt.do_button = va_arg(ap, WFCTP);
			break;
		case CW_KEYBD:
			wp->evnt.do_keybd = va_arg(ap, WFCTP);
			break;
		case CW_REDRAW:
			wp->evnt.do_redraw = va_arg(ap, WFCTP);
			break;
		case CW_XREDRAW:
			/*	at the moment not changeable
			rb->redraw = va_arg(ap, WFCTP);
			rb->xinc = va_arg(ap, WORD);
			rb->yinc = va_arg(ap, WORD);
			if ((rb->next = (WREDRAW *) vmalloc(a, sizeof(WREDRAW)))
			== NULL)
				return NULL;
			rbp = rb;		
			rb = rb->next;
			rb->next = NULL;
			*/
			break;
		case CW_EVNTS:
			/*
			 */

			break;	
		case CW_COORD:
			wp->status = va_arg(ap, WORD);
			coord_kind = va_arg(ap, WORD);
			area.g_x = va_arg(ap, WORD);
			area.g_y = va_arg(ap, WORD);
			area.g_w = va_arg(ap, WORD);
			area.g_h = va_arg(ap, WORD);
			if ((dummy = va_arg(ap, WORD)) != -1) {
				wp->align.g_x = dummy;
				wp->align.g_y = va_arg(ap, WORD);
				wp->align.g_w = va_arg(ap, WORD);
				wp->align.g_h = va_arg(ap, WORD);
			}
			else {
				dummy = va_arg(ap, WORD);
				dummy = va_arg(ap, WORD);
				dummy = va_arg(ap, WORD);
			}
			arg_type = 0;
			break;
		case CW_HSIZE:
			wp->slide.hdocsize = va_arg(ap, WORD);
			wp->slide.hdocunit = va_arg(ap, WORD);
			/*
			 *	there should be something to change
			 *	the sliderpos also
			 */
			wp->slide.hdocpos = 0;
			
			if ((wp->parts & HSLIDE) && (wp->slide.hdocsize != 0) 
			&& (wp->slide.hdocunit != 0)) {
				wp->slide.hdocwindsize = wp->work.g_w / 
					wp->slide.hdocunit;
				wind_set(wp->handle, WF_HSLSIZE, 
				 calc_slider(wp->slide.hdocwindsize,
				 1000, wp->slide.hdocsize), 0, 0, 0);
				wind_set(wp->handle, WF_HSLIDE, 0, 0, 0, 0); 
			}
			break;
		case CW_VSIZE:
			wp->slide.vdocsize = va_arg(ap, WORD);
			wp->slide.vdocunit = va_arg(ap, WORD);
			wp->slide.vdocpos = 0; 
			
			if ((wp->parts & VSLIDE) && (wp->slide.vdocsize != 0) 
			&& (wp->slide.vdocunit != 0)) {
				wp->slide.vdocwindsize = wp->work.g_h / 
					wp->slide.vdocunit;
				wind_set(wp->handle, WF_VSLSIZE, 
				 calc_slider(wp->slide.vdocwindsize,
				 1000, wp->slide.vdocsize), 0, 0, 0);
				wind_set(wp->handle, WF_VSLIDE, 0, 0, 0, 0); 
			}
			break;
		case CW_HSIZESNAP:
			wp->slide.hsizesnap = va_arg(ap, WORD);
			break;
		case CW_VSIZESNAP:
			wp->slide.vsizesnap = va_arg(ap, WORD);
			break;
		case CW_POPUP:
			init_popup(a, &wp->popup, (BYTE *) va_arg(ap, BYTE *));
			wp->popup.usr_popup = (WFCTP) va_arg(ap, WFCTP);
			
			break;
		}

	}	
	va_end(ap);	

	return SUCCESS;
}
/*
 *	:open_wind()
 */

WORD	open_wind(a, wp, coord_type, x, y, w, h)
GEMBUF	*a;
WINDOW	*wp;
WORD	coord_type;
{
	if (wp->status == OPEN) {
		wind_set(wp->handle, WF_TOP, wp->handle, 0, 0, 0);
		rc_cpy(&wp->work, &wp->old);
		return SUCCESS;
	}
	
	if (a->open_wind >= MAXOPENWIND) {
		errmsg(ENOOPWIND);
		wp->status = CLOSE;
		return FAILURE;
	} else {	
		a->open_wind++;
		begin_update(a);
		if (coord_type == WC_WORK)  {
			wp->work.g_x = x;
			wp->work.g_y = y;
			wp->work.g_w = w;
			wp->work.g_h = h;
			if (wp->align.g_x != -1)
				align_rect(&wp->work, &wp->align);
			wind_calc(WC_BORDER, wp->parts, 
				wp->work.g_x, wp->work.g_y, 
				wp->work.g_w, wp->work.g_h, 
				&wp->border.g_x, &wp->border.g_y,
				&wp->border.g_w, &wp->border.g_h);
		} else {
			wind_calc(WC_WORK, wp->parts, 
				x, y, w, h, 
				&wp->work.g_x, &wp->work.g_y,
				&wp->work.g_w, &wp->work.g_h);
			if (wp->align.g_x != -1)
				align_rect(&wp->work, &wp->align);
			wind_calc(WC_BORDER, wp->parts, 
				wp->work.g_x, wp->work.g_y, 
				wp->work.g_w, wp->work.g_h, 
				&wp->border.g_x, &wp->border.g_y,
				&wp->border.g_w, &wp->border.g_h);
		}
		
		if ((wp->parts & HSLIDE) && (wp->slide.hdocsize != 0) 
		&& (wp->slide.hdocunit != 0)) {
			wp->slide.hdocwindsize = wp->work.g_w / 
				wp->slide.hdocunit;
			/*
			wind_set(wp->handle, WF_HSLSIZE, 
				calc_slider(wp->slide.hdocwindsize,
				1000, wp->slide.hdocsize), 0, 0, 0);
			wind_set(wp->handle, WF_HSLIDE, 0, 0, 0, 0); 
			*/
		}		
		if ((wp->parts & VSLIDE) && (wp->slide.vdocsize != 0) 
		&& (wp->slide.vdocunit != 0)) {
			wp->slide.vdocwindsize = wp->work.g_h / 
				wp->slide.vdocunit;
			/*
			wind_set(wp->handle, WF_VSLSIZE, 
				calc_slider(wp->slide.vdocwindsize,
				1000, wp->slide.vdocsize), 0, 0, 0);
			wind_set(wp->handle, WF_VSLIDE, 0, 0, 0, 0); 
			*/
		}
		wind_open(wp->handle, wp->border);
		wp->status = OPEN;
		end_update(a);
	}
	rc_cpy(&wp->work, &wp->old);
	
	return SUCCESS;
}
/*
 *	clean_wind()
 *	fills the inside of a window with white box
 */

VOID 	clean_wind(a, box)
GEMBUF 	*a;
GRECT 	*box;
{
        WORD pxyarray[4];
     
        grect_to_array(box, pxyarray);
        vsf_interior(a->handle, 2);
        vsf_style(a->handle, 8);
        vsf_color(a->handle, 0);
        if (a->mouse)
		v_hide_c(a->handle);
        v_bar(a->handle, pxyarray);
        if (a->mouse)
	        v_show_c(a->handle);
        vsf_color(a->handle, 1);
}

/*
 *	close window
 */

WORD 	close_wind(a, wi_handle)
GEMBUF	*a;
WORD	wi_handle;
{
	WINDOW *w;
	
	if ((w = find_wind(a, wi_handle)) == NULL)
		return FALSE;
		
	if (w->status == CLOSE)
		return SUCCESS;
		
	w->status = CLOSE;
	a->open_wind--;
	graf_shrinkbox( w->border.g_x + (w->border.g_w / 2), 
			w->border.g_y + (w->border.g_h / 2),
			a->gl_wbox, a->gl_hbox, 
			w->border.g_x, w->border.g_y, 
			w->border.g_w, w->border.g_h);
	wind_close(wi_handle);
	return TRUE;
}	

/* 
 * 	delete window
 */
 
WORD 	delete_wind(a, wi_handle)
GEMBUF 	*a;
register WORD wi_handle; 
{
	register WINDOW *wp;
	
	if ((wp = find_wind(a, wi_handle)) == NULL)
		return FALSE;
	if (wp->prev != NULL)
		wp->prev->next = wp->next;
	if (wp->next != NULL)	
		wp->next->prev = wp->prev;

	if (wp->name != NULL)
		vfree(a, wp->name);
	if (wp->info != NULL)
		vfree(a, wp->info);

	vfree(a, wp);
	
	wind_delete(wi_handle);
	a->wind_count--;

	return SUCCESS;
}	 

/*
 *	find_wind()
 *	find window with GEM window handle or gemlib window nr
 */

WINDOW 	*find_wind(a, handle)
GEMBUF 	*a;
register WORD 	handle;	/* window to look for (GEM handle) */
{
	register WINDOW *w;
	
	w = a->wind;	/* first window */
	
	for (; (w != NULL) && (w->handle !=  handle);)
			w = w->next;
	return w;
}	
		
/*
 *	last_wind()
 *	find the last window int the window list  
 */

WINDOW 	*last_wind(a)
GEMBUF	*a;
{
	register WINDOW *w;
	
	w = a->wind;
	
	while (w->next != NULL)
		w = w->next;
	return w;
}


/*
 *	some text handling fcts for windows
 *	ONLY TESTS!
 */
 
/* 
 *	clear screen (fill buffer with spaces)
 */
wind_clr_txtbuf(wp)
register WINDOW	*wp;
{
	register WORD	x, y, w, h;
	register BYTE	*s;	
		
	s = wp->scrnbuf.addr;
	w = wp->scrnbuf.b_w;
	h = wp->scrnbuf.b_h;
	
	for (y = 0; y <	h; y++)
		for (x = 0; x < w; x++)
			*s++ = ' ';	/* '\0' */
}
		

/*
 *	print_wind()
 *	print a string in a text-type window's scrnbuffer
 *	note: you'll see the str on the scrn only after a redraw event
 */

WORD	print_wind(a, wp, x, y, s)
GEMBUF	*a;
WINDOW	*wp;
WORD	x, y;
register BYTE	*s;
{
	register BYTE	*t;
	register WORD	len, col, tab;
	WORD		tab_size;
	
	if (wp->type == WT_EDITOR)
		tab_size = WED_TAB_SIZE(wp);
	else
		tab_size = 8;
	
	len = wp->scrnbuf.b_w;
	t = (BYTE *) (wp->scrnbuf.addr + y * len + x);
	
	tab = 8;	/* wp->editor.tabwidth */
	
	for (col = x; (*s != '\0') && (col < len); s++) {
		if ((*s == '\r') || (*s == '\n')) {
			*t++ = ' '; 	/* '\0' (depends on text output fct) */
			col++;
		} else if (*s == '\t') {
			tab = col + (tab_size - (col % tab_size)); 
			for (; col < tab; col++)
				*t++ = ' ';
		} else {
			*t++ = *s;
			col++;
		}
	}
	/* *t = '\0'; */ /* */
	
	return SUCCESS;
}

/*
 *	redraw_txtwind()
 *
 */

WORD	redraw_textwind(a, whandle, area)
GEMBUF	*a;
WORD	whandle;
GRECT	*area;
{
	WINDOW		*wp;
	register BYTE	*s;
	register WORD	x, y, height, gl_hchar, scrn_bwidth; 
		
	if ((wp = find_wind(a, whandle)) == NULL)
		return FAILURE;

	clean_wind(a, area);

	/*
	x = a->gl_wchar;
	y = a->gl_hchar;
	area->g_x = ((area->g_x - (x >> 1)) / x) * x;
	area->g_y = ((area->g_y - (y >> 1)) / y) * y;
	area->g_w = ((area->g_w + (x >> 1)) / x) * x;
	area->g_h = ((area->g_h + (y >> 1)) / y) * y;

	if (area->g_x < wp->work.g_x)
		area->g_x = wp->work.g_x;
	if (area->g_y < wp->work.g_y)
		area->g_y = wp->work.g_y;
	if (area->g_w > wp->work.g_w)
		area->g_w = wp->work.g_w;
	if (area->g_h > wp->work.g_h)
		area->g_h = wp->work.g_h;

	area->g_x = (((area->g_x - work.g_x)) / x) * x;
	*/
	
	scrn_bwidth = wp->scrnbuf.b_w;
	s = (BYTE *) (wp->scrnbuf.addr + ((area->g_y - wp->work.g_y) / 
		a->gl_hchar) * scrn_bwidth + (area->g_x - wp->work.g_x) /
		a->gl_wchar);

	
	y = wp->work.g_y + a->gl_hchar + ((area->g_y - wp->work.g_y) / 
		a->gl_hchar) *	a->gl_hchar;
	
	x = wp->work.g_x + ((area->g_x - wp->work.g_x) / a->gl_wchar) *
		a->gl_wchar;

	gl_hchar = a->gl_hchar;
	height = y + area->g_h;

	set_clip(a, FALSE, area);

	set_clip(a, FALSE, area);
	
	area->g_w += 1;

	set_clip(a, TRUE, area);
	
	for ( ; y < height; y += gl_hchar, s += scrn_bwidth) {
		v_gtext(a->handle, x, y, s);
	}

}

/*
 *	window text redraw routines
 */

/*
 *      calc_param() calculates the needed parameters for text_output
 */        

VOID 	calc_param(a, wp, r, rect, w_w, w_y, dx, dy, _xoff, _yoff, xdiff, ydiff)
GEMBUF 		*a;
WINDOW		*wp;
REDRAW_BLK 	*r;
GRECT 		*rect;
WORD 		w_w, w_y, dx, dy, _xoff, _yoff, xdiff, ydiff;
{
	WORD l;
        
	r->xc = (rect->g_x / a->gl_wchar) * a->gl_wchar;
	r->yc = w_y + (ydiff * a->gl_hchar);
              
	r->xl = ((_xoff + (r->xl = (w_w + 2 * a->gl_wchar - 1) / a->gl_wchar))
		 > wp->scrnbuf.b_w) ?	
		 	(wp->scrnbuf.b_w - _xoff - (dx / a->gl_wchar)) : r->xl;
	r->xl = max(r->xl, 0);
        if ((_xoff + xdiff + r->xl) >= wp->scrnbuf.b_w) { 
                r->xl = max((wp->scrnbuf.b_w - xdiff - _xoff), 0);
                if (r->xl < 3) {
                        l = (r->xl == 2) ? 1 : 2;
                        r->xc -= (l * a->gl_wchar);
                        xdiff -= l;
                }           
        } 
        r->h = ((rect->g_y + rect->g_h - r->yc + a->gl_hchar - 1) / 
        	a->gl_hchar) * a->gl_hchar;
        l = _yoff + ydiff + (dy / a->gl_hchar); 
        if ((r->h / a->gl_hchar) > (wp->scrnbuf.b_h - l))
               r->h = (wp->scrnbuf.b_h - l) * a->gl_hchar; 
                
        r->s = (BYTE *) (wp->scrnbuf.addr + (l * wp->scrnbuf.b_w +
        	((_xoff + xdiff + (dx / a->gl_wchar)))));
}        

/*
 *      text_redraw(xc1, yc, y_limit, p, xl)
 *      this is our supadupa fct for redrawing the text in window
 *      after a REDRAW msg
 *      xc1 is the x-coord in chars, not pixels
 *      yc         y-coord
 *      y_limit    height     
 *      p          pointer to the string at xc1, yc
 *      xl         length     
 *      return TRUE or FALSE
 *	
 *	IF ORG_V_GTEXT is used we use the v_gtext() fct
 *	otherwise we fill vdi-arrays by our own and jump with vdi()
 */

#define ORG_V_GTEXT	1

#ifdef	ORG_V_GTEXT
WORD 	text_output(a, wp, xc1, yc, y_limit, p, xl)
GEMBUF	*a;
WINDOW	*wp;			/* window pointer */
register WORD 	xl, y_limit; 	/* length in chars, heigth in points */
register BYTE 	*p;		/* pointer to first to be redrawn char */
WORD 	xc1, yc;		/* x, y coordinates */
{
        register WORD 	z;
        WORD 	xc2, xc3;
	WORD	width;		/* width of text screen */
	WORD 	handle;
        static	BYTE 	s1[2] = " ";
        static 	BYTE	s2[3] = "  ";
        register BYTE	*sp2;
	register BYTE	*q;		/* points to p + xl  */
	register WORD 	hchar;		/* height of a char  */

        if (xl <= 0) 
                return FALSE;

        xl = ((xl - 3) < 0) ? xl : (xl - 3);
        
	xc2 = xc1 + a->gl_wchar;
	xc3 = xc2 + (xl * a->gl_wchar);

	handle = a->handle;
	width = wp->scrnbuf.b_w - 1;
	hchar = a->gl_hchar;
	sp2 = s2;
	y_limit += yc;
        for (z = yc + hchar - a->txtoff; z < y_limit; z += hchar, p += width) {
                *s1 = *p++;
                v_gtext(handle, xc1, z, s1);
                q = p + xl;
                sp2[0] = *q;
                sp2[1] = *(q + 1);
		*q = '\0';
                v_gtext(handle, xc2, z, p);
                v_gtext(handle, xc3, z, sp2);      
                *q = sp2[0];
        }
        
        return TRUE;
}
#else

WORD 		text_output(a, wp, xc1, yc, y_limit, p, xl)
GEMBUF		*a;
WINDOW		*wp;			/* window pointer */
register 	WORD 	xl, y_limit; 	/* length in chars, heigth in points */
register 	BYTE 	*p;		/* pointer to 1st to be redrawn char */
WORD 		xc1, yc;		/* x, y coordinates */
{
        register WORD 	z;
        WORD 		xc2, xc3;
	WORD		width;			/* width of text screen */
	WORD		*contrl3p;		/* vdi &control[3] */
	WORD		*ptsin1p;		/* vdi &ptsin[1] */
        register 	WORD	*intinp;	/* ptr to vdi intin */
	register 	BYTE	*q;		/* points to p + xl  */
	WORD 		hchar, i;		/* height of a char  */

        if (xl <= 0) 
                return FALSE;

        xl = ((xl - 3) < 0) ? xl : (xl - 3);
        
	xc2 = xc1 + a->gl_wchar;
	xc3 = xc2 + (xl * a->gl_wchar);

	width = wp->scrnbuf.b_w /*- 1*/;
	hchar = a->gl_hchar;
	y_limit += yc;

	contrl[0] = 8;			/* v_gtext opcode */
	contrl[1] = 1;			/* # of points in ptsin */
	contrl[6] = a->handle;		/* vdi handle */

	contrl3p = &contrl[3];		/* # of chars */
	ptsin1p	= &ptsin[1];		/* y coord. */
	intinp	= intin;
	
	xl++;	/* becaus of below's */ /* */
        for (z = yc + hchar - a->txtoff; z < y_limit; z += hchar, p += width) {
		q = p;
		
		*ptsin1p = z;

		*ptsin = xc1;
		/*
		*intin = (WORD) *q++;
		*contrl3p = 1;
		vdi();	

		*ptsin = xc2;
		*/
		for (i = 0, intinp = intin; i < xl; i++)
			*intinp++ = (WORD) *q++;	
		*contrl3p = xl;
		vdi();

		*ptsin = xc3;
		intinp = intin;
		*intinp++ = (WORD) *q++;
		*intinp = (WORD) *q;
		*contrl3p = 2;
		vdi();
        }
        
        return TRUE;
}
#endif

/*
 *      txt  r e d r a w   f c t
 *      see document
 */

WORD 	hndl_txtredraw(a, wh, ra)
GEMBUF	*a;
WORD 	wh;		/* window handle */
GRECT 	*ra;		/* redraw area */
{
	WINDOW	*wp;		/* pointer to redraw window */
	GRECT	ww;		/* working copy of window work coord */
	GRECT 	wo;		/* copy of window old coord */
	GRECT	wc;		/* working copy of wo (intersect calc) */
	GRECT 	t1, t2;		/* some rectangels */
	REDRAW_BLK b;		/* redraw parameter block */
	WORD 	xdiff, ydiff; 	/* diff betw. window's top and redraw rect */ 
	WORD	_xoff, _yoff;	/* ver. & horz offset */
	WORD	mx, my, mbutton, keybd;

	if ((wp = find_wind(a, wh)) == NULL)
		return FALSE;			/* window not found */
	
	hide_mouse(a);

	_xoff = wp->scrnbuf.xoff;
	_yoff = wp->scrnbuf.yoff;
	rc_copy(&wp->work, &ww);	
	rc_copy(&wp->old, &wo);
	
	ra->g_w = (ra->g_x + ra->g_w > a->scrn.g_w) ? 
			(a->scrn.g_w - ra->g_x) : ra->g_w; 
        ra->g_h = (ra->g_y + ra->g_h > a->scrn.g_h) ? 
        		(a->scrn.g_h - ra->g_y) : ra->g_h;
        wo.g_w = (wo.g_x + wo.g_w > a->scrn.g_w) ? 
        		(a->scrn.g_w - wo.g_x) : wo.g_w;
        wo.g_h = (wo.g_y+wo.g_h > a->scrn.g_h) ? 
        		(a->scrn.g_h - wo.g_y) : wo.g_h;
        
        rc_copy(&wo, &wc);

	switch (wp->redraw_evnt) {
	case WM_SIZED:
		xdiff = 0;
		ydiff = 0;
		if (wo.g_w < ra->g_w) {
			t1.g_x = wo.g_x + wo.g_w;
			t1.g_y = wo.g_y;
			t1.g_w = ww.g_w - wo.g_w;
			t1.g_h = min(ww.g_h, wo.g_h);
		} 
		if (wo.g_h < ww.g_h) {
			t2.g_x = ww.g_x;
			t2.g_y = ww.g_y + wo.g_h;
			t2.g_w = ww.g_w;
			t2.g_h = ww.g_h - wo.g_h;
		}        
		if (t1.g_h) {		
			clean_wind(a, &t1);
			calc_param(a, wp, &b, &t1, t1.g_w, t1.g_y, wo.g_w, 0, 
				_xoff, _yoff, xdiff, ydiff);
			text_output(a, wp, b.xc, b.yc, b.h, b.s, b.xl);
		}
		if (t2.g_h) {
			clean_wind(a, &t2);
			calc_param(a, wp, &b, &t2, ra->g_w, t2.g_y, 0, wo.g_h,
				 _xoff, _yoff, xdiff, ydiff);
			text_output(a, wp, b.xc, b.yc, b.h, b.s, b.xl);
		}
		break;

	case WM_ARROWED:
	case WM_HSLID:
	case WM_VSLID:
		if (rc_intersect(ra, &wc) && 
		!((ra->g_x == wo.g_x) && (ra->g_y == wo.g_y))) {
			t1.g_x = ra->g_x;
			t1.g_y = ra->g_y;
			t1.g_w = wc.g_w;
			t1.g_h = wc.g_h;
			t2.g_x = wo.g_x;
			t2.g_y = wo.g_y;
			t2.g_w = wc.g_w;
			t2.g_h = wc.g_h;
			copy_area(a, &t1, &t2);
                               
			if (ra->g_y == wo.g_y) {
				ra->g_x = (ra->g_x <= wo.g_x) ? 
					ra->g_x : (wo.g_x + wc.g_w);
				ra->g_w = ww.g_w - t1.g_w;
			} else {
				ra->g_y = (ra->g_y <= wo.g_y) ? 
					ra->g_y : (wo.g_y + wc.g_h);
				ra->g_h = ww.g_h - t1.g_h;
			}
  
		}
		clr_grect(&wo);
		xdiff = (ra->g_x - ww.g_x) / a->gl_wchar;
		ydiff = (ra->g_y - ww.g_y) / a->gl_hchar;
		
		calc_param(a, wp, &b, ra, ra->g_w, ww.g_y, 0, 0, 
				_xoff, _yoff, xdiff, ydiff);
		do {
			copy_area(a, &t1, &t2);
			/*b.s = ;*/
			text_output(a, wp, b.xc, b.yc, b.h, b.s, b.xl);
			graf_mkstate(&mx, &my, &mbutton, &keybd);
		} while (mbutton & 1);	/* left button still pressed */
		break;
				
	default:	/* WM_REDRAW */
 
		xdiff = (ra->g_x - ww.g_x) / a->gl_wchar;
		ydiff = (ra->g_y - ww.g_y) / a->gl_hchar;
 
		if (ra->g_h) {
			clean_wind(a, ra);	/* looks faster */
			calc_param(a, wp, &b, ra, ra->g_w, ww.g_y, 0, 0, 
				_xoff, _yoff, xdiff, ydiff);
			text_output(a, wp, b.xc, b.yc, b.h, b.s, b.xl);
		}
	}

	wp->redraw_evnt = 0;

	show_mouse(a);

	return SUCCESS;
}

