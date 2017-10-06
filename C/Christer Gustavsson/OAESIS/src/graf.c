/****************************************************************************

 Module
  graf.c
  
 Description
  Dynamic graphical routines in oAESis.
  
 Author(s)
 	cg (Christer Gustavsson <d2cg@dtek.chalmers.se>)

 Revision history
 
  960103 cg
   Added standard header.
  
  960424 cg
   Implemented graf_{grow,move}box.
 
  960501 cg
   Fixed bug in graf_mouse() in the M_LAST and M_RESTORE code.
   
 Copyright notice
  The copyright to the program code herein belongs to the authors. It may
  be freely duplicated and distributed without fee, but not charged for.
 
 ****************************************************************************/

/****************************************************************************
 * Used interfaces                                                          *
 ****************************************************************************/

#include <mintbind.h>
#include <osbind.h>
#include <stdio.h>

#include "appl.h"
#include "debug.h"
#include "evnt.h"
#include "evnthndl.h"
#include "gemdefs.h"
#include "global.h"
#include "graf.h"
#include "misc.h"
#include "objc.h"
#include "resource.h"
#include "rsrc.h"
#include "types.h"
#include "vdi.h"
#include "wind.h"

/****************************************************************************
 * Macros                                                                   *
 ****************************************************************************/

#define GRAF_STEPS 15

/****************************************************************************
 * Module global variables                                                  *
 ****************************************************************************/

static MFORM m_arrow,m_text_crsr,m_busy_bee,m_point_hand,m_flat_hand,
             m_thin_cross,m_thick_cross,m_outln_cross;
static MFORM current,last,last_saved;

/****************************************************************************
 * Local functions (use static!)                                            *
 ****************************************************************************/

void icon2mform(MFORM *mf,OBJECT *icon) {
	WORD	i;

	/*convert resource icons to MFORM's*/
	
	mf->mf_xhot = 0;
	mf->mf_yhot = 0;
	mf->mf_nplanes = 1;
	mf->mf_fg = 1;
	mf->mf_bg = 0;
	
	for(i = 0; i < 16; i++) {
		mf->mf_mask[i] = icon->ob_spec.iconblk->ib_pmask[i];
		mf->mf_data[i] = icon->ob_spec.iconblk->ib_pdata[i];
	};
}

/****************************************************************************
 * Public functions                                                         *
 ****************************************************************************/
 
void	Graf_init_module(void) {	
	icon2mform(&m_arrow,&globals.mouseformstad[MARROW]);
	icon2mform(&m_text_crsr,&globals.mouseformstad[MTEXT_CRSR]);
	icon2mform(&m_busy_bee,&globals.mouseformstad[MBUSY_BEE]);
	icon2mform(&m_point_hand,&globals.mouseformstad[MPOINT_HAND]);
	icon2mform(&m_flat_hand,&globals.mouseformstad[MFLAT_HAND]);
	icon2mform(&m_thin_cross,&globals.mouseformstad[MTHIN_CROSS]);
	icon2mform(&m_thick_cross,&globals.mouseformstad[MTHICK_CROSS]);
	icon2mform(&m_outln_cross,&globals.mouseformstad[MOUTLN_CROSS]);
	
	current = m_arrow;
	last = m_arrow;
	last_saved = m_arrow;
}

/* 0x0046 graf_rubberbox() */

/****************************************************************************
 * Graf_do_rubberbox                                                        *
 *  Implementation of graf_rubberbox().                                     *
 ****************************************************************************/
WORD                /* 1 if ok or 0.                                        */
Graf_do_rubberbox(  /*                                                      */
WORD   vid,         /* VDI workstation id.                                  */
WORD   eventpipe,   /* Event message pipe handle.                           */
WORD   bx,          /* Top left corner x.                                   */
WORD   by,          /* Top left corner y.                                   */
WORD   minw,        /* Minimum width.                                       */
WORD   minh,        /* Minimum height.                                      */
WORD   *endw,       /* Final width.                                         */
WORD   *endh)       /* Final height.                                        */
/****************************************************************************/
{
	EVNTREC er;
	WORD    xyarray[10];
	WORD    lastw = globals.mouse_x - bx,lasth = globals.mouse_y - by;
	WORD    neww,newh;

	if(!(globals.mouse_button & LEFT_BUTTON)) {	
		*endw = globals.mouse_x - bx;
		*endh = globals.mouse_y - by;

		if(*endw < minw) {
			*endw = minw;
		};

		if(*endh < minh) {
			*endh = minh;
		};
	
		return 1;
	};
	
	Vdi_vswr_mode(vid,MD_XOR);
  Vdi_vsl_type(vid,DOTTED);

  xyarray[0] = bx;
  xyarray[1] = by;
  xyarray[2] = bx + lastw - 1;
  xyarray[3] = xyarray[1];
  xyarray[4] = xyarray[2];
  xyarray[5] = by + lasth - 1;
  xyarray[6] = xyarray[0];
  xyarray[7] = xyarray[5];
  xyarray[8] = xyarray[0];
  xyarray[9] = xyarray[1];
	 
	Vdi_v_hide_c(vid);
  Vdi_v_pline(vid,5,xyarray);
  Vdi_v_show_c(vid,1);
	
	while(Fread(eventpipe,sizeof(EVNTREC),&er)) {
		if(er.ap_event == APPEVNT_MOUSE) {
			neww = (WORD)((er.ap_value & 0xffff) - bx);
  		newh = (WORD)((er.ap_value >> 16) - by);

			if(neww < minw) {
				neww = minw;
			};

			if(newh < minh) {
				newh = minh;
			};

			if((lastw != neww) || (lasth != newh)) {
	      Vdi_v_hide_c(vid);
	      Vdi_v_pline(vid,5,xyarray);

	      lastw = neww;
	      lasth = newh;

			  xyarray[0] = bx;
			  xyarray[1] = by;
			  xyarray[2] = bx + lastw - 1;
			  xyarray[3] = xyarray[1];
			  xyarray[4] = xyarray[2];
			  xyarray[5] = by + lasth - 1;
			  xyarray[6] = xyarray[0];
			  xyarray[7] = xyarray[5];
			  xyarray[8] = xyarray[0];
			  xyarray[9] = xyarray[1];
	 
	      Vdi_v_pline(vid,5,xyarray);
	      Vdi_v_show_c(vid,1);
	    };
		};
		
		if(er.ap_event == APPEVNT_BUTTON) {
			if(!(er.ap_value & LEFT_BUTTON)) {
				break;
			};
		};
	};

  Vdi_v_hide_c(vid);
  Vdi_v_pline(vid,5,xyarray);
	Vdi_v_show_c(vid,1);

	*endw = lastw;
	*endh = lasth;
	
	return 1;
}

/****************************************************************************
 * Graf_rubberbox                                                           *
 *  0x0046 graf_rubberbox().                                                *
 ****************************************************************************/
void              /*                                                        */
Graf_rubberbox(   /*                                                        */
AES_PB *apb)      /* AES parameter block.                                   */
/****************************************************************************/
{
	Evhd_gain_mctrl(apb->global->apid,TRUE);

	apb->int_out[0] = Graf_do_rubberbox(apb->global->int_info->vid,
										apb->global->int_info->eventpipe,apb->int_in[0],
										apb->int_in[1],apb->int_in[2],apb->int_in[3],
										&apb->int_out[1],&apb->int_out[2]);

	Evhd_release_mctrl();
}


/* 0x0071 graf_dragbox() */

/****************************************************************************
 * Graf_do_dragbox                                                          *
 *  Implementation of graf_dragbox().                                       *
 ****************************************************************************/
WORD              /* 1 if ok or 0.                                          */
Graf_do_dragbox(  /*                                                        */
WORD   vid,       /* VDI workstation id.                                    */
WORD   eventpipe, /* Event message pipe handle.                             */
WORD   w,         /* Width of box.                                          */
WORD   h,         /* Height of box.                                         */
WORD   sx,        /* Starting x.                                            */
WORD   sy,        /* Starting y.                                            */
RECT   *bound,    /* Bounding rectangle.                                    */
WORD   *endx,     /* Ending x.                                              */
WORD   *endy)     /* Ending y.                                              */
/****************************************************************************/
{
	EVNTREC er;
	WORD    relx = sx - globals.mouse_x;
	WORD    rely = sy - globals.mouse_y;
	WORD    xyarray[10];
	WORD    lastx = sx,lasty = sy;
	WORD    newx,newy;

	if(!(globals.mouse_button & LEFT_BUTTON)) {	
		*endx = sx;
		*endy = sy;
	
		return 1;
	};

	Vdi_vswr_mode(vid,MD_XOR);
  Vdi_vsl_type(vid,DOTTED);

  xyarray[0] = lastx;
  xyarray[1] = lasty;
  xyarray[2] = lastx + w - 1;
  xyarray[3] = xyarray[1];
  xyarray[4] = xyarray[2];
  xyarray[5] = lasty + h - 1;
  xyarray[6] = xyarray[0];
  xyarray[7] = xyarray[5];
  xyarray[8] = xyarray[0];
  xyarray[9] = xyarray[1];
	 
	Vdi_v_hide_c(vid);
  Vdi_v_pline(vid,5,xyarray);
  Vdi_v_show_c(vid,1);
	
	while(Fread(eventpipe,sizeof(EVNTREC),&er)) {
		if(er.ap_event == APPEVNT_MOUSE) {
			newx = (WORD)((er.ap_value & 0xffff) + relx);
  		newy = (WORD)((er.ap_value >> 16) + rely);

			if(newx < bound->x) {
				newx = bound->x;
			}
			else if(newx > (bound->x + bound->width - w)) {
				newx = bound->x + bound->width - w;
			};

			if(newy < bound->y) {
				newy = bound->y;
			}
			else if(newy > (bound->y + bound->height - h)) {
				newy = bound->y + bound->height - h;
			};

			if((lastx != newx) || (lasty != newy)) {
	      Vdi_v_hide_c(vid);
	      Vdi_v_pline(vid,5,xyarray);

 		    xyarray[0] = newx;
	      xyarray[1] = newy;
	      xyarray[2] = newx + w - 1;
	      xyarray[3] = xyarray[1];
	      xyarray[4] = xyarray[2];
	      xyarray[5] = newy + h - 1;
	      xyarray[6] = xyarray[0];
	      xyarray[7] = xyarray[5];
	      xyarray[8] = xyarray[0];
	      xyarray[9] = xyarray[1];
	 
	      Vdi_v_pline(vid,5,xyarray);
	      Vdi_v_show_c(vid,1);
	      
	      lastx = newx;
	      lasty = newy;
	    };
		};
		
		if(er.ap_event == APPEVNT_BUTTON) {
			if(!(er.ap_value & LEFT_BUTTON)) {
				break;
			};
		};
	};

  Vdi_v_hide_c(vid);
  Vdi_v_pline(vid,5,xyarray);
	Vdi_v_show_c(vid,1);

	*endx = lastx;
	*endy = lasty;
	
	return 1;
}

/****************************************************************************
 * Graf_dragbox                                                             *
 *  0x0047 graf_dragbox().                                                  *
 ****************************************************************************/
void              /*                                                        */
Graf_dragbox(     /*                                                        */
AES_PB *apb)      /* AES parameter block.                                   */
/****************************************************************************/
{
	Evhd_gain_mctrl(apb->global->apid,TRUE);

	apb->int_out[0] = Graf_do_dragbox(apb->global->int_info->vid,
										apb->global->int_info->eventpipe,apb->int_in[0],
										apb->int_in[1],apb->int_in[2],apb->int_in[3],
										(RECT *)&apb->int_in[4],&apb->int_out[1],
										&apb->int_out[2]);

	Evhd_release_mctrl();
}


/****************************************************************************
 * Graf_do_grmobox                                                          *
 *  Implementation of graf_growbox() and graf_movebox().                    *
 ****************************************************************************/
WORD              /*                                                        */
Graf_do_grmobox(  /*                                                        */
WORD vid,         /* VDI workstation id.                                    */
RECT *r1,         /* Start rectangle.                                       */
RECT *r2)         /* End rectangle.                                         */
/****************************************************************************/
{
	WORD f,g;
	WORD xy[10];
	
	WORD dx = (r2->x - r1->x) / GRAF_STEPS;
	WORD dy = (r2->y - r1->y) / GRAF_STEPS;
	WORD dw = (r2->width - r1->width) / GRAF_STEPS;
	WORD dh = (r2->height - r1->height) / GRAF_STEPS;

	Vdi_vswr_mode(vid,MD_XOR);
	Vdi_vsl_type(vid,3);
 
	Vdi_v_hide_c(vid);

	for(g = 0; g < 2; g++) {
 	 xy[0] = r1->x;
	  xy[1] = r1->y;
	  xy[2] = r1->x + r1->width - 1;
	  xy[3] = xy[1];
	  xy[4] = xy[2];
	  xy[5] = r1->y + r1->height - 1;
	  xy[6] = xy[0];
	  xy[7] = xy[5];
	  xy[8] = xy[0];
	  xy[9] = xy[1];
	
		for(f=0; f < GRAF_STEPS; f++)			/* Draw initial growing outline */
	{
	    Vdi_v_pline(vid,5,xy);
	
			xy[0] += dx;
			xy[1] += dy;
			xy[2] += dx + (dw << 1);
			xy[3] = xy[1];
			xy[4] = xy[2];
			xy[5] += dy + (dh << 1);
			xy[6] = xy[0];
			xy[7] = xy[5];
			xy[8] = xy[0];
			xy[9] = xy[1];
		}
	}
	
  Vdi_v_show_c(vid,1);

	Vdi_vswr_mode(vid,MD_TRANS);
	
	return 1;
}

/****************************************************************************
 * Graf_movebox                                                             *
 *  0x0048 graf_movebox().                                                  *
 ****************************************************************************/
void              /*                                                        */
Graf_movebox(     /*                                                        */
AES_PB *apb)      /* AES parameter block.                                   */
/****************************************************************************/
{
	RECT r1,r2;
	
	r1.x = apb->int_in[2];
	r1.y = apb->int_in[3];
	r1.width = apb->int_in[0];
	r1.height = apb->int_in[1];
	
	r2.x = apb->int_in[4];
	r2.y = apb->int_in[5];
	r2.width = apb->int_in[0];
	r2.height = apb->int_in[1];

	Wind_beg_update();
	
	apb->int_out[0] = Graf_do_grmobox(apb->global->int_info->vid,&r1,&r2);
	
	Wind_end_update();
}

/****************************************************************************
 * Graf_growbox                                                             *
 *  0x0049 graf_growbox().                                                  *
 ****************************************************************************/
void              /*                                                        */
Graf_growbox(     /*                                                        */
AES_PB *apb)      /* AES parameter block.                                   */
/****************************************************************************/
{
	Wind_beg_update();

	apb->int_out[0] = Graf_do_grmobox(apb->global->int_info->vid,
																		(RECT *)&apb->int_in[0],
																		(RECT *)&apb->int_in[4]);

	Wind_end_update();
}

/****************************************************************************
 * Graf_shrinkbox                                                           *
 *  0x004a graf_shrinkbox().                                                *
 ****************************************************************************/
void              /*                                                        */
Graf_shrinkbox(   /*                                                        */
AES_PB *apb)      /* AES parameter block.                                   */
/****************************************************************************/
{
	apb->int_out[0] = 1;
}

/****************************************************************************
 * Graf_do_watchbox                                                         *
 *  Implementation of graf_watchbox().                                      *
 ****************************************************************************/
WORD              /* 1 if inside object when button was released or 0.      */
Graf_do_watchbox( /*                                                        */
WORD   apid,      /* Application id.                                        */
WORD   vid,       /* VDI workstation id.                                    */
WORD   eventpipe, /* Event message pipe.                                    */
OBJECT *tree,     /* Resource tree.                                         */
WORD   obj,       /* Object to watch.                                       */
WORD   instate,   /* State when inside object.                              */
WORD   outstate)  /* State when outside object.                             */
/****************************************************************************/
{
  EVENTIN ei = {
    MU_BUTTON | MU_M1,
    0,
    LEFT_BUTTON,
    0,
    0,
    {0,0,0,0},
    0,
    {0,0,0,0},
    0,
    0
    };
							
	EVENTOUT	eo;
	COMMSG    buffer;
	RECT      clip;
	
	Objc_calc_clip(tree,obj,&clip);
	Objc_do_offset(tree,obj,(WORD *)&ei.m1r);
	ei.m1r.width = tree[obj].ob_width;
	ei.m1r.height = tree[obj].ob_height;
	
	if(Misc_inside(&ei.m1r,globals.mouse_x,globals.mouse_y)) {
		ei.m1flag = MO_LEAVE;
		
		Objc_do_change(vid,tree,obj,&clip,instate,REDRAW);
	}
	else {
		ei.m1flag = MO_ENTER;

		Objc_do_change(vid,tree,obj,&clip,outstate,REDRAW);
	};
	
	Evhd_gain_mctrl(apid,FALSE);
	
	while(1) {
		Evnt_do_multi(apid,eventpipe,-1,&ei,&buffer,&eo,0);
		
		if(eo.events & MU_BUTTON) {
			break;
		};
		
		if(ei.m1flag == MO_LEAVE) {
			ei.m1flag = MO_ENTER;
	
			Objc_do_change(vid,tree,obj,&clip,outstate,REDRAW);
		}
		else {
			ei.m1flag = MO_LEAVE;

			Objc_do_change(vid,tree,obj,&clip,instate,REDRAW);
		};
	};
	
	Evhd_release_mctrl();
					
	if(ei.m1flag == MO_LEAVE) {
		return 1;
	};
	
	return 0;
}

/****************************************************************************
 * Graf_watchbox                                                            *
 *  0x004b graf_watchbox().                                                 *
 ****************************************************************************/
void              /*                                                        */
Graf_watchbox(    /*                                                        */
AES_PB *apb)      /* AES parameter block.                                   */
/****************************************************************************/
{
	apb->int_out[0] = Graf_do_watchbox(apb->global->apid,
										apb->global->int_info->vid,
										apb->global->int_info->eventpipe,
										(OBJECT *)apb->addr_in[0],
										apb->int_in[1],apb->int_in[2],apb->int_in[3]);
}

/****************************************************************************
 * Graf_do_slidebox                                                         *
 *  Implementation of graf_slidebox().                                      *
 ****************************************************************************/
WORD              /* Relative offset.                                       */
Graf_do_slidebox( /*                                                        */
WORD   apid,      /* Application id.                                        */
WORD   vid,       /* VDI workstation id.                                    */
WORD   eventpipe, /* Event message pipe.                                    */
OBJECT *tree,     /* Resource tree.                                         */
WORD   parent,    /* Parent object.                                         */
WORD   obj,       /* Slider object.                                         */
WORD   orient)    /* Orientation. 0 => horizontal, 1 => vertical.           */
/****************************************************************************/
{
	RECT bound;
	RECT slid;
	WORD x,y;
	
	if(!tree) {
		return 0;
	};
	
	Objc_area_needed(tree,obj,&slid);
	Objc_area_needed(tree,parent,&bound);
	
	Evhd_gain_mctrl(apid,TRUE);
	
	Graf_do_dragbox(vid,eventpipe,
									slid.width,slid.height,
									slid.x,slid.y,&bound,&x,&y);
									
	Evhd_release_mctrl();
	
	if(orient == 0) {
		if(tree[obj].ob_width != tree[parent].ob_width) {
			return (WORD)((((LONG)x - (LONG)bound.x) * 1000L) /
										((LONG)(tree[parent].ob_width - tree[obj].ob_width)));
		};
	}
	else {
		if(tree[obj].ob_height != tree[parent].ob_height) {
			return (WORD)((((LONG)y - (LONG)bound.y) * 1000L) /
										((LONG)(tree[parent].ob_height - tree[obj].ob_height)));
		};
	};
									
	return 0;
}

/****************************************************************************
 * Graf_slidebox                                                            *
 *  0x004c graf_slidebox().                                                 *
 ****************************************************************************/
void              /*                                                        */
Graf_slidebox(    /*                                                        */
AES_PB *apb)      /* AES parameter block.                                   */
/****************************************************************************/
{
	apb->int_out[0] = Graf_do_slidebox(apb->global->apid,
										apb->global->int_info->vid,
										apb->global->int_info->eventpipe,
										(OBJECT *)apb->addr_in[0],
										apb->int_in[0],apb->int_in[1],apb->int_in[2]);
}

/*graf_handle 0x004d*/

void Graf_do_handle(WORD *cwidth,WORD *cheight,WORD *width
							,WORD *height) {
	*cwidth = globals.clwidth;
	*cheight = globals.clheight;
	*width = globals.blwidth;
	*height = globals.blheight;
}

void	Graf_handle(AES_PB *apb) {
	apb->int_out[0] = apb->global->int_info->vid;
	
	Graf_do_handle(&apb->int_out[1]
								,&apb->int_out[2],&apb->int_out[3]
								,&apb->int_out[4]);	
}

/*graf_mouse 0x004e*/
WORD Graf_do_mouse(WORD vid,WORD mode,MFORM *formptr) {
	if(vid >= 0) {
		MFORM tmp;
		
		switch(mode) {
			case ARROW: /*0x000*/
				last = current;
				current = m_arrow;
				Vdi_v_hide_c(vid);
				Vdi_vsc_form(vid,&m_arrow);
				Vdi_v_show_c(vid,0);
				break;
				
			case TEXT_CRSR: /*0x001*/
				last = current;
				current = m_text_crsr;
				Vdi_v_hide_c(vid);
				Vdi_vsc_form(vid,&m_text_crsr);
				Vdi_v_show_c(vid,0);
				break;
				
			case BUSY_BEE: /*0x002*/
				last = current;
				current = m_busy_bee;
				Vdi_v_hide_c(vid);
				Vdi_vsc_form(vid,&m_busy_bee);
				Vdi_v_show_c(vid,0);
				break;
				
			case POINT_HAND: /*0x003*/
				last = current;
				current = m_point_hand;
				Vdi_v_hide_c(vid);
				Vdi_vsc_form(vid,&m_point_hand);
				Vdi_v_show_c(vid,0);
				break;
				
			case FLAT_HAND: /*0x004*/
				last = current;
				current = m_flat_hand;
				Vdi_v_hide_c(vid);
				Vdi_vsc_form(vid,&m_flat_hand);
				Vdi_v_show_c(vid,0);
				break;
			
			case THIN_CROSS: /*0x005*/
				last = current;
				current = m_thin_cross;
				Vdi_v_hide_c(vid);
				Vdi_vsc_form(vid,&m_thin_cross);
				Vdi_v_show_c(vid,0);
				break;
			
			case THICK_CROSS: /*0x006*/
				last = current;
				current = m_thick_cross;
				Vdi_v_hide_c(vid);
				Vdi_vsc_form(vid,&m_thick_cross);
				Vdi_v_show_c(vid,0);
				break;
			
			case OUTLN_CROSS: /*0x007*/
				last = current;
				current = m_outln_cross;
				Vdi_v_hide_c(vid);
				Vdi_vsc_form(vid,&m_outln_cross);
				Vdi_v_show_c(vid,0);
				break;
			
			case USER_DEF	:
				last = current;
				current = *formptr;
				Vdi_v_hide_c(vid);
				Vdi_vsc_form(vid,formptr);
				Vdi_v_show_c(vid,0);
				break;
				
			case M_OFF	:
				Vdi_v_hide_c(vid);
				break;
				
			case M_ON	:
				Vdi_v_show_c(vid,0);
				break;
				
			case M_SAVE:
				last_saved = current;
				break;
			
			case M_LAST:
				last = current;
				current = last_saved;

				Vdi_v_hide_c(vid);
				Vdi_vsc_form(vid,&current);
				Vdi_v_show_c(vid,0);

				break;
				
			case M_RESTORE:
				tmp = current;
				current = last;
				last = tmp;

				Vdi_v_hide_c(vid);
				Vdi_vsc_form(vid,&current);
				Vdi_v_show_c(vid,0);

				break;			
			
			default:
				DB_printf("%s: Line %d: Graf_do_mouse:\r\n"
								"Unknown mode %d\r\n",__FILE__,__LINE__,mode);
				return 0;
		};
	}
	else {
		return 0;
	};

	return 1;
}

void Graf_mouse(AES_PB *apb) {
	apb->int_out[0] = Graf_do_mouse(apb->global->int_info->vid,apb->int_in[0],(MFORM *)apb->addr_in[0]);
}

/*graf_mkstate 0x004f*/
void	Graf_mkstate(AES_PB *apb) {
	apb->int_out[0] = 1;
	apb->int_out[1] = globals.mouse_x;
	apb->int_out[2] = globals.mouse_y;
	apb->int_out[3] = globals.mouse_button;
	apb->int_out[4] = (WORD)Kbshift(-1) & 0x1f;
}
