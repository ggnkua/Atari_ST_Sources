/*
 *	setbtem.c
 *	07/23/91 hmk	
 *	GEM routines used by the SETBOOT program
 */

#define	GEMLIBINIT 1
 
#include "setbtgem.h"
#include "setbtmsg.h"

/*
 *	init_appl()
 *	initilizes a gem application
 *
 */
 
GEMBUF 	*init_appl(coord_system, rscname)
WORD	coord_system;	/* Coordinate system, NC (normelized) or RC (raster) */
BYTE 	*rscname;	/* file name of the rscfile */
{
	static GEMBUF applbuf;/* contains info about the appl & env around it */
	register WORD i;
	WORD nowhere;	/* dummy */
		
	/* vdi handle is only for exiting debug and panic */
	
	vdi_handle = 0;
	
	/* intialize application */
#ifdef MWC	
	appl_init();
	applbuf.ap_id = gl_apid;
#else
	applbuf.ap_id = appl_init();
#endif	
	if (applbuf.ap_id == ERR) {
		form_alert(1, "[1][Initializing GEM failed.][Abort]");
		exit(1);
	}
	wind_get(WC_BORDER, WF_FULLXYWH, &applbuf.desk.g_x, &applbuf.desk.g_y,
		 			 &applbuf.desk.g_w, &applbuf.desk.g_h);
	applbuf.update = FALSE;
	applbuf.mouse = TRUE;

	graf_mouse(ARROW, &nowhere);	
	begin_update(&applbuf);
	
	applbuf.handle = graf_handle(&applbuf.gl_wchar, &applbuf.gl_hchar, 
				     &applbuf.gl_wbox, &applbuf.gl_hbox);
	
	applbuf.txtoff = applbuf.gl_hbox - applbuf.gl_hchar;
	
	/* open workstation */

	for (i = 0; i < 10; i++)
		work_in[i] = 1;		/* applbuf.work_in ??? */
	work_in[10] = coord_system;  
	v_opnvwk(work_in, &applbuf.handle, work_out); 
	
	vdi_handle = applbuf.handle;
	applbuf.res = Getrez();

	/* set up the applbuf */
	
	applbuf.scrn.g_x = 0;
	applbuf.scrn.g_y = 0;
	applbuf.scrn.g_w = work_out[0];
        applbuf.scrn.g_h = work_out[1];
	
        vq_extnd(applbuf.handle, 1, work_out);         
        applbuf.scrn_planes = work_out[4];
	
       	applbuf.scrn_fdb.fd_addr = 0l;  
        applbuf.scrn_fdb.fd_w = 0;
        applbuf.scrn_fdb.fd_wdwidth = 0;
        applbuf.scrn_fdb.fd_h = 0;
        applbuf.scrn_fdb.fd_nplanes = 0;
	applbuf.scrn_fdb.fd_stand = 0;
	applbuf.scrn_fdb.fd_r1 = 0;        
	applbuf.scrn_fdb.fd_r2 = 0;        
	applbuf.scrn_fdb.fd_r3 = 0;        
        
	applbuf.menu_addr = 0l;			/* no menu bar yet */

	/* 
	 *	redraw desktop, if not bit 16 is set in coord_system
	 */
	
	draw_std_desk(&applbuf);	

	end_update(&applbuf);	
	/* 
	 *	load rsc-file 
	 */
	if (rscname != NULL)
		load_rsrc(&applbuf, rscname);
			
	return &applbuf;
}

/*
 *	exit_appl()
 *	Exit GEM application
 */
 
WORD 	exit_appl(a)
GEMBUF 	*a;
{

	/*
	 *	turn off menu bar
	 */
	if (a->menu_addr != 0l)
		menu_bar(a->menu_addr, FALSE);

	/*
	 *	set wind_update(FALSE)
	 */
	end_update(a);
	
	/*
	 *	give rsrc memory free
	 */
	rsrc_free();

	v_clsvwk(a->handle);
	appl_exit();
	exit(0);
}

/*
 * 	evnt()
 */

WORD	evnt(a)
GEMBUF 	*a;
{
	register WORD event;		/* the occured event 	*/
	WORD	msgbuf[8];
	WORD	mousex, mousey, mbutton;
	WORD	keystate, key, mtimes;
	
	for (;;) {
		event = evnt_multi(	MU_MESAG | MU_KEYBD | MU_BUTTON,  
					2, 1, 1, 
					0, 0, 0, 0, 0,
					0, 0, 0, 0, 0,
			 		msgbuf, 
			 		0, 0,
			 		&mousex, &mousey, &mbutton,
			 		&keystate, &key, 
			 		&mtimes);	
		if (event & MU_MESAG)
			gem_msg(a, msgbuf);
	} 	
}	/* evnt() */


/*
 *	gem_msg()
 */
 
WORD	gem_msg(a, buf)
GEMBUF	*a;
WORD	*buf;		/* message buffer */
{
	begin_update(a);
	switch(buf[0]) {
		case MN_SELECTED:
			gem_menu(a, buf[3], buf[4]); 
			break;
	} 	/* switch (buf[0]) */
	end_update(a);
}


/*
 *	gem_menu()
 */

WORD	gem_menu(a, mtitle, mentry)
GEMBUF	*a;
WORD	mtitle;		/* title of the chosen menu */
WORD	mentry;		/* entry of the ... */
{
	show_mouse(a);
	handle_menu(a, mtitle, mentry);			/* in asv.c */
	menu_tnormal(a->menu_addr, mtitle, TRUE);
}


/*
 *	show_mouse()
 *	turn on the mouse cursor, if it's not already on
 */

VOID 	show_mouse(a)
GEMBUF 	*a;
{
	WORD	nowhere;
	
	if (!a->mouse) {
		graf_mouse(M_ON, &nowhere);	
		a->mouse = TRUE;
	}
}

/*
 *	hide_mouse()
 */

VOID 	hide_mouse(a)
GEMBUF 	*a;
{
	WORD 	nowhere;
	
	if (a->mouse) {
		graf_mouse(M_OFF, &nowhere);
		a->mouse = FALSE;
	}
}

/*
 *	begin_update()
 *	begin window update, disable menu actions & hide mouse
 */	

VOID 	begin_update(a)
GEMBUF 	*a;
{
	if (!a->update) {
		/*hide_mouse(a);*/		/* ??? */
		wind_update(BEG_UPDATE);
		a->update = TRUE;
	}
}

/*
 *	end_update()
 */
 
VOID 	end_update(a)
GEMBUF 	*a;
{
	if (a->update) {
		/*show_mouse(a);*/		/* ??? */
		wind_update(END_UPDATE);
		a->update = FALSE;
	}
}

/*
 *	load_rsc()
 */
 
WORD	load_rsrc(a, rscname)
GEMBUF	*a;
BYTE	*rscname;
{
	if (!rsrc_load(rscname)) {
		form_alert(1, "[1][Cannot find ASV.RSC][Abort]");
		exit_appl(a);
	}
	
	return TRUE;
}

/*
 *	std desktop object mask
 */
 	
#define SPEC 0x11C1L

static	OBJECT mask = {
	/* next/head/tail/type/flags   /state/specification/x/y/w/h */
	    -1, -1,  -1, G_BOX, LASTOB, NORMAL, SPEC,      0,0,640,400
};
		
/*
 *	draw standard desktop
 */

VOID	draw_std_desk(a)
GEMBUF	*a;
{	
	mask.ob_x = a->desk.g_x;
	mask.ob_y = a->desk.g_y;
	mask.ob_width  = a->desk.g_w;
	mask.ob_height = a->desk.g_h;
	
	objc_draw(&mask, ROOT, 0, a->desk.g_x, a->desk.g_y, 
				  a->desk.g_w, a->desk.g_h);
	wind_set(0, WF_NEWDESK, &mask, ROOT);
}

/*
 *	init_menu()
 */
 			
WORD	init_menu(a, index)
GEMBUF	*a;	
WORD	index;		/* index got from rcs (usally the name of the object) */
{
	
	if (!rsrc_gaddr(R_TREE, index, &(a->menu_addr))) {
		form_alert(1, "[1][Cannot display menu bar.][Abort]");
		exit_appl(a);
	}
	menu_bar(a->menu_addr, TRUE);
}


/*
 *	do_form()
 */
 
WORD	do_form(a, index, first_str)
GEMBUF	*a;
WORD	index;
WORD	first_str;
{
	LONG o_addr;	/* addr of the object */
	WORD o_x, o_y, o_w, o_h;
	WORD ret_button;	

	rsrc_gaddr(R_TREE, index, &o_addr); 
	form_center(o_addr, &o_x, &o_y, &o_w, &o_h);
	form_dial(0, 0, 0, 0, 0, o_x, o_y, o_w + 3, o_h + 3);
	
	objc_draw(o_addr, 0, MAX_DEPTH, o_x, o_y, o_w + 3, o_h + 3);
	
	ret_button = form_do(o_addr, first_str) & 0x7FFF;
	
	form_dial(3, 0, 0, 0, 0, o_x, o_y, o_w + 3, o_h + 3);

	desel_obj(o_addr, ret_button);
	
	return ret_button;
}

/*
 >>>>>>>>>>>>>>>>>>>>>>> Object flag utilities <<<<<<<<<<<<<<<<<<<<<<<<<<<
 */
	WORD
undo_obj(tree, which, bit)	/* clear specified bit in object state	*/
	OBJECT	*tree;
	WORD	which;
	UWORD	bit;
	{
	UWORD	state;

	return tree[which].ob_state &= ~bit;
	}

	WORD
desel_obj(tree, which)		/* turn off selected bit of spcfd object*/
	OBJECT	*tree;
	WORD	which;
	{
	return undo_obj(tree, which, (UWORD) SELECTED);
	}

	WORD
do_obj(tree, which, bit)	/* set specified bit in object state	*/
	OBJECT	*tree;
	WORD	which, bit;
	{
	WORD	state;

	return tree[which].ob_state |= bit;
	}

	WORD
sel_obj(tree, which)		/* turn on selected bit of spcfd object	*/
	OBJECT	*tree;
	WORD	which;
	{
	return do_obj(tree, which, SELECTED);
	}

