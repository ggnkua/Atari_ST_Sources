/****************************************************************************

 Module
  wind.c
  
 Description
  Window routines used in oAESis.
  
 Author(s)
 	cg     (Christer Gustavsson <d2cg@dtek.chalmers.se>)

 Revision history
 
  951226 cg
   Added standard header.
  960101 cg
   Added BEG_MCTRL and END_MCTRL modes to wind_update.
  960102 cg
   WF_TOP mode of wind_get() implemented.
  960103 cg
   WF_NEWDESK mode of wind_set() implemented.
   WF_HSLIDE, WF_VSLIDE, WF_VSLSIZE and WF_HSLSIZE modes of wind_set()
   and wind_get() implemented.
 
 Copyright notice
  The copyright to the program code herein belongs to the authors. It may
  be freely duplicated and distributed without fee, but not charged for.
 
 ****************************************************************************/

/****************************************************************************
 * Used interfaces                                                          *
 ****************************************************************************/

#include	<alloc.h>
#include	<basepage.h>
#include	<mintbind.h>
#include	<osbind.h>
#include	<signal.h>
#include	<stdio.h>
#include	<string.h>
#include	<support.h>

#include "appl.h"
#include "debug.h"
#include "evnt.h"
#include "evnthndl.h"
#include "gemdefs.h"
#include "global.h"
#include "lxgemdos.h"
#include "mintdefs.h"
#include "mesagdef.h"
#include "misc.h"
#include "objc.h"
#include "rdwrs.h"
#include "resource.h"
#include "rlist.h"
#include "types.h"
#include "vdi.h"
#include "wind.h"

/****************************************************************************
 * Macros                                                                   *
 ****************************************************************************/

#define W_ALL (-1)  /* set _all_ widgets */

#define IMOVER 0x8000  /* Used with set_win_elem() to make icon window */

/****************************************************************************
 * Typedefs of module global interest                                       *
 ****************************************************************************/

typedef struct {
  WORD wid;
  RECT r;
}WMSG;

/****************************************************************************
 * Module global variables                                                  *
 ****************************************************************************/

static CSEMA update = {
	-1,
	-1,
	0,
	-1
};

static WORD	elemnumber = -1;
static WORD	tednumber;


static WINLIST *win_list = 0L;
static WINLIST *win_free = 0L;

static WORD	win_next = 0;

static OBJC_COLORWORD top_colour[20] = {
	BLACK,BLACK,1,7,LWHITE,
	BLACK,BLACK,1,7,LWHITE,
	BLACK,BLACK,1,7,LWHITE,
	BLACK,BLACK,0,7,LYELLOW,
	BLACK,BLACK,1,7,LWHITE,
	BLACK,BLACK,0,7,WHITE,
	BLACK,BLACK,1,7,LWHITE,
	BLACK,BLACK,1,7,LWHITE,
	BLACK,BLACK,1,7,LWHITE,
	BLACK,BLACK,1,7,LWHITE,
	BLACK,BLACK,1,7,LWHITE,
	BLACK,BLACK,1,7,LWHITE,
	BLACK,BLACK,1,7,LWHITE,
	BLACK,BLACK,1,7,LWHITE,
	BLACK,BLACK,1,7,LWHITE,
	BLACK,BLACK,1,7,LWHITE,
	BLACK,BLACK,1,7,LWHITE,
	BLACK,BLACK,1,7,LWHITE,
	BLACK,BLACK,1,7,LWHITE,
	BLACK,BLACK,1,7,LWHITE
};

static OBJC_COLORWORD untop_colour[20] = {
	BLACK,BLACK,1,7,LWHITE,
	BLACK,BLACK,1,7,LWHITE,
	BLACK,BLACK,1,7,LWHITE,
	BLACK,BLACK,1,7,LWHITE,
	BLACK,BLACK,1,7,LWHITE,
	BLACK,BLACK,0,7,WHITE,
	BLACK,BLACK,1,7,LWHITE,
	BLACK,BLACK,1,7,LWHITE,
	BLACK,BLACK,1,7,LWHITE,
	BLACK,BLACK,1,7,LWHITE,
	BLACK,BLACK,1,7,LWHITE,
	BLACK,BLACK,1,7,LWHITE,
	BLACK,BLACK,1,7,LWHITE,
	BLACK,BLACK,1,7,LWHITE,
	BLACK,BLACK,1,7,LWHITE,
	BLACK,BLACK,1,7,LWHITE,
	BLACK,BLACK,1,7,LWHITE,
	BLACK,BLACK,1,7,LWHITE,
	BLACK,BLACK,1,7,LWHITE,
	BLACK,BLACK,1,7,LWHITE
};

static WORD widgetmap[] = {
	0,0,WCLOSER,WMOVER,WFULLER,
	WINFO,0,0,WSIZER,0,
	WUP,WDOWN,WVSB,WVSLIDER,0,
	WLEFT,WRIGHT,WHSB,WHSLIDER,WSMALLER
};

/****************************************************************************
 * Local functions (use static!)                                            *
 ****************************************************************************/

static void set_widget_colour(WINSTRUCT *win,WORD widget,OBJC_COLORWORD *untop,OBJC_COLORWORD *top) {
	U_OB_SPEC      *ob_spec;
	WORD           object = 0;
	OBJC_COLORWORD *colour;

	if(win->tree) {
		object = widgetmap[widget];
		
		if(win->tree[object].ob_flags & INDIRECT) {
			ob_spec = (U_OB_SPEC *)win->tree[object].ob_spec.indirect;
		}
		else {
			ob_spec = (U_OB_SPEC *)&win->tree[object].ob_spec;
		};
		
		switch(win->tree[object].ob_type & 0xff) {
		case G_BOX:
		case G_IBOX:
		case G_BOXCHAR:
			colour = &((OBJC_COLORWORD *)ob_spec)[1];
			break;
		
		case G_TEXT:
		case G_BOXTEXT:
		case G_FTEXT:
		case G_FBOXTEXT:
			colour = (OBJC_COLORWORD *)&ob_spec->tedinfo->te_color;
			break;
		
		case G_IMAGE:
			colour = (OBJC_COLORWORD *)&ob_spec->bitblk->bi_color;
			break;
		
		case G_BUTTON:
		case G_PROGDEF:
		case G_STRING:
		case G_TITLE:
			return;
			
		default:
			DB_printf("Unsupported type %d in set_widget_colour.",win->tree[object].ob_type);
		};
		
		if(win->status & WIN_TOPPED) {
			*colour = *top;
		}
		else {
			*colour = *untop;
		};
	};
}


static void packelem(OBJECT *tree,WORD object,WORD left,WORD right,
                     WORD top,WORD bottom) {

	if((left != -1) && (right != -1)) {
		if(left == 0) {
			tree[object].ob_x = D3DSIZE;
		}
		else {
			tree[object].ob_x = tree[left].ob_x + tree[left].ob_width + D3DSIZE * 2;
		};
		
		if(right == 0) {
			tree[object].ob_width = tree[0].ob_width - tree[object].ob_x - D3DSIZE;
		}
		else {
			tree[object].ob_width = tree[right].ob_x - tree[object].ob_x - D3DSIZE * 2;
		}
	}
	else if(left != -1) {
		if(left == 0) {
			tree[object].ob_x = D3DSIZE;
		}
		else {
			tree[object].ob_x = tree[left].ob_x + tree[left].ob_width + D3DSIZE * 2;
		};		
	}
	else if(right != -1) {
		if(right == 0) {
			tree[object].ob_x = tree[0].ob_width - tree[object].ob_width - D3DSIZE;
		}
		else {
			tree[object].ob_x = tree[right].ob_x - tree[object].ob_width - D3DSIZE * 2;
		};
	};
	
	
	if((top != -1) && (bottom != -1)) {
		if(top == 0) {
			tree[object].ob_y = D3DSIZE;
		}
		else {
			tree[object].ob_y = tree[top].ob_y + tree[top].ob_height + D3DSIZE * 2;
		};
		
		if(bottom == 0) {
			tree[object].ob_height = tree[0].ob_height - tree[object].ob_y - D3DSIZE;
		}
		else {
			tree[object].ob_height = tree[bottom].ob_y - tree[object].ob_y - D3DSIZE * 2;
		}
	}
	else if(top != -1) {
		if(top == 0) {
			tree[object].ob_y = D3DSIZE;
		}
		else {
			tree[object].ob_y = tree[top].ob_y + tree[top].ob_height + D3DSIZE * 2;
		};		
	}
	else if(bottom != -1) {
		if(bottom == 0) {
			tree[object].ob_y = tree[0].ob_height - tree[object].ob_height - D3DSIZE;
		}
		else {
			tree[object].ob_y = tree[bottom].ob_y - tree[object].ob_height - D3DSIZE * 2;
		};
	};	
}


static OBJECT *alloc_win_elem(void) {
	WORD    i = 0,tnr = 0;
	OBJECT  *t;
	TEDINFO *ti;
	LONG    size;

	while(elemnumber == -1) {
		switch(globals.windowtad[i].ob_type) {
			case	G_TEXT		:
			case	G_BOXTEXT	:
			case	G_FTEXT		:
			case	G_FBOXTEXT	:
				tnr++;
		}
		
		if(globals.windowtad[i].ob_flags & LASTOB)
		{
			elemnumber = i + 1;
			tednumber = tnr;
		}
		
		i++;
	}
	
	size = sizeof(OBJECT) * elemnumber + sizeof(TEDINFO) * tednumber;
	
	t = (OBJECT *)Mxalloc(size,GLOBALMEM);
	
	if(t != NULL) {
		ti = (TEDINFO *)&t[elemnumber];
		
		memcpy(t,globals.windowtad,sizeof(OBJECT) * elemnumber);
		
		for(i = 0; i < elemnumber; i++) {
			switch(globals.windowtad[i].ob_type) {
				case	G_TEXT		:
				case	G_BOXTEXT	:
				case	G_FTEXT		:
				case	G_FBOXTEXT	:
					t[i].ob_spec.tedinfo = ti;
					memcpy(ti, globals.windowtad[i].ob_spec.tedinfo, sizeof(TEDINFO));
					ti++;
			};
		};
	};
	
	return t;
}

static void set_win_elem(OBJECT *tree,WORD elem) {
	WORD bottomsize = 0;
	WORD rightsize = 0;
	WORD left = 0,right = 0,top = 0,bottom = 0;

	if((HSLIDE | LFARROW | RTARROW) & elem) {
		bottomsize = tree[WLEFT].ob_height + (D3DSIZE << 1);
	};
	
	if((LFARROW | HSLIDE | RTARROW) & elem) {
		bottomsize = tree[WLEFT].ob_height + (D3DSIZE << 1);
	};
	
	if(((bottomsize == 0) && (SIZER & elem))
		|| ((VSLIDE | UPARROW | DNARROW) & elem)) {
		rightsize = tree[WSIZER].ob_width + (D3DSIZE << 1);
	};
	
	if(CLOSER & elem) {
		tree[WCLOSER].ob_flags &= ~HIDETREE;	
		
		packelem(tree,WCLOSER,0,-1,0,-1);
		left = WCLOSER;
	}	
	else {
		tree[WCLOSER].ob_flags |= HIDETREE;
	}
	
	if(FULLER & elem) {
		tree[WFULLER].ob_flags &= ~HIDETREE;	
		
		packelem(tree,WFULLER,-1,0,0,-1);
		right = WFULLER;
	}	
	else {
		tree[WFULLER].ob_flags |= HIDETREE;
	}
		
	if(SMALLER & elem) {
		tree[WSMALLER].ob_flags &= ~HIDETREE;	
		
		packelem(tree,WSMALLER,-1,right,0,-1);
		right = WSMALLER;
	}	
	else {
		tree[WSMALLER].ob_flags |= HIDETREE;
	}
		
	if(MOVER & elem) {
		tree[WMOVER].ob_flags &= ~HIDETREE;
		tree[TFILLOUT].ob_flags |= HIDETREE;
		
		tree[WMOVER].ob_height = tree[WCLOSER].ob_height;
		tree[WMOVER].ob_spec.tedinfo->te_font = IBM;

		packelem(tree,WMOVER,left,right,0,-1);
		top = WMOVER;
	}
	else {
		tree[WMOVER].ob_flags |= HIDETREE;

		if((left != 0) || (right != 0)) {
			tree[TFILLOUT].ob_flags &= ~HIDETREE;

			packelem(tree,TFILLOUT,left,right,0,-1);
			top = TFILLOUT;
		}
		else {
			tree[TFILLOUT].ob_flags |= HIDETREE;
		};
	};
	
	if(INFO & elem) {
		tree[WINFO].ob_flags &= ~HIDETREE;

		packelem(tree,WINFO,0,0,top,-1);
		top = WINFO;		
	}
	else {
		tree[WINFO].ob_flags |= HIDETREE;
	};

	right = 0;
	left = 0;

	if(elem & UPARROW) {
		tree[WUP].ob_flags &= ~HIDETREE;
		
		packelem(tree,WUP,-1,0,top,-1);
		top = WUP;
	}
	else {
		tree[WUP].ob_flags |= HIDETREE;
	};

	if(SIZER & elem) {
		tree[WSIZER].ob_flags &= ~HIDETREE;
		tree[SFILLOUT].ob_flags |= HIDETREE;	
		
		packelem(tree,WSIZER,-1,0,-1,0);
		bottom = right = WSIZER;
	}	
	else {
		tree[WSIZER].ob_flags |= HIDETREE;
		
		if((bottomsize > 0) && (rightsize > 0)) {
			tree[SFILLOUT].ob_flags &= ~HIDETREE;
			
			packelem(tree,SFILLOUT,-1,0,-1,0);
			bottom = right = SFILLOUT;
		}
		else {
			tree[SFILLOUT].ob_flags |= HIDETREE;
		}
	}
	
	if(elem & DNARROW) {
		tree[WDOWN].ob_flags &= ~HIDETREE;

		packelem(tree,WDOWN,-1,0,-1,bottom);
		bottom = WDOWN;		
	}
	else {
		tree[WDOWN].ob_flags |= HIDETREE;
	};
	
	if(elem & VSLIDE) {
		tree[WVSB].ob_flags &= ~HIDETREE;

		packelem(tree,WVSB,-1,0,top,bottom);		
	}
	else
	{
		tree[WVSB].ob_flags |= HIDETREE;
	}
	
	if(!(VSLIDE & elem) && (rightsize > 0))
	{
		tree[RFILLOUT].ob_flags &= ~HIDETREE;

		packelem(tree,RFILLOUT,-1,0,top,bottom);		
	}
	else {
		tree[RFILLOUT].ob_flags |= HIDETREE;
	}
	
	if(LFARROW & elem) {
		tree[WLEFT].ob_flags &= ~HIDETREE;
		
		packelem(tree,WLEFT,0,-1,-1,0);
		left = WLEFT;
	}
	else {
		tree[WLEFT].ob_flags |= HIDETREE;
	}
	
	if(RTARROW & elem) {
		tree[WRIGHT].ob_flags &= ~HIDETREE;
		
		packelem(tree,WRIGHT,-1,right,-1,0);
		right = WRIGHT;
	}
	else {
		tree[WRIGHT].ob_flags |= HIDETREE;
	};
	
	if(elem & HSLIDE) {
		tree[WHSB].ob_flags &= ~HIDETREE;
		
		packelem(tree,WHSB,left,right,-1,0);
	}
	else {
		tree[WHSB].ob_flags |= HIDETREE;
	}
	
	if(!(HSLIDE & elem) && (bottomsize > 0)) {
		tree[BFILLOUT].ob_flags &= ~HIDETREE;
		
		packelem(tree,BFILLOUT,left,right,-1,0);
	}
	else {
		tree[BFILLOUT].ob_flags |= HIDETREE;
	};
	
	if(IMOVER & elem) {
		tree[WMOVER].ob_flags &= ~HIDETREE;
		tree[WMOVER].ob_height = globals.csheight + 2;
		tree[WMOVER].ob_spec.tedinfo->te_font = SMALL;
		packelem(tree,WMOVER,0,0,0,-1);

		tree[WAPP].ob_flags |= HIDETREE;
	}
	else {
		tree[WAPP].ob_flags &= ~HIDETREE;
	};
}

static WORD	changeslider(WORD vid,WINSTRUCT *win,WORD redraw,WORD which,
				WORD position,WORD size) {	
	WORD redraw2 = 0;

	if(which & VSLIDE) {
		WORD newheight,newy;
		
		if(position != -1) {
			if(position > 1000) {
				win->vslidepos = 1000;
			}
			else if(position < 1) {
				win->vslidepos = 1;
			}
			else {
				win->vslidepos = position;
			};
		};
		
		if(size != -1) {
			if(size > 1000) {
				win->vslidesize = 1000;
			}
			else if(size < 1) {
				win->vslidesize = 1;
			}
			else {
				win->vslidesize = size;
			};
		};

		newy = (WORD)(((LONG)win->vslidepos * (LONG)(win->tree[WVSB].ob_height - win->tree[WVSLIDER].ob_height)) / 1000L);
		newheight = (WORD)(((LONG)win->vslidesize * (LONG)win->tree[WVSB].ob_height) / 1000L);

		if((win->tree[WVSLIDER].ob_y != newy) ||
			(win->tree[WVSLIDER].ob_height != newheight)) {
			win->tree[WVSLIDER].ob_y = newy;
			win->tree[WVSLIDER].ob_height = newheight;
			
			redraw2 = 1;
		};
	}
	
	if(which & HSLIDE) {
		WORD newx,newwidth;
		
		if(position != -1) {
			if(position > 1000) {
				win->hslidepos = 1000;
			}
			else if(position < 1) {
				win->hslidepos = 1;
			}
			else {
				win->hslidepos = position;
			};
		};
		
		if(size != -1) {
			if(size > 1000) {
				win->hslidesize = 1000;
			}
			else if(size < 1) {
				win->hslidesize = 1;
			}
			else {
				win->hslidesize = size;
			};
		};
		
		newx = (WORD)(((LONG)win->hslidepos * (LONG)(win->tree[WHSB].ob_width - win->tree[WHSLIDER].ob_width)) / 1000L);
		newwidth = (WORD)(((LONG)win->hslidesize * (LONG)win->tree[WHSB].ob_width) / 1000L);

		if((win->tree[WHSLIDER].ob_x != newx) ||
			(win->tree[WHSLIDER].ob_width != newwidth)) {
			win->tree[WHSLIDER].ob_x = newx;
			win->tree[WHSLIDER].ob_width = newwidth;
			
			redraw2 = 1;
		};
	};

	if(redraw && redraw2 && (win->status & WIN_OPEN)) {							
		if(which & VSLIDE) {
			Wind_draw_elements(vid,win,&globals.screen,WVSB);
		};
		
		if(which & HSLIDE) {
			Wind_draw_elements(vid,win,&globals.screen,WHSB);
		};
	};

	return 1;
}

/*setwinsize sets the size and position of window win to size*/

static void	setwinsize(WINSTRUCT *win,RECT *size) {
	WORD	dx,dy,dw,dh;

	win->lastsize = win->totsize;
	
	win->totsize = *size;
	
	dx = size->x - win->lastsize.x;
	dy = size->y - win->lastsize.y;
	dw = size->width - win->lastsize.width;
	dh = size->height - win->lastsize.height;
	
	win->worksize.x += dx;
	win->worksize.y += dy;
	win->worksize.width += dw;
	win->worksize.height += dh;

	if(win->tree) {
		win->tree[0].ob_x = win->totsize.x;
		win->tree[0].ob_y = win->totsize.y;
		win->tree[0].ob_width = win->totsize.width;
		win->tree[0].ob_height = win->totsize.height;
	
		win->tree[WMOVER].ob_width += dw;
		
		win->tree[WFULLER].ob_x += dw;

		win->tree[WSMALLER].ob_x += dw;
	
		win->tree[WDOWN].ob_x += dw;
		win->tree[WDOWN].ob_y += dh;	
	
		win->tree[WSIZER].ob_x += dw;
		win->tree[WSIZER].ob_y += dh;	
	
		win->tree[WRIGHT].ob_x += dw;
		win->tree[WRIGHT].ob_y += dh;	
	
		win->tree[WLEFT].ob_y += dh;	
	
		win->tree[WVSB].ob_x += dw;
		win->tree[WVSB].ob_height += dh;	
	
		win->tree[WHSB].ob_y += dh;
		win->tree[WHSB].ob_width += dw;	
	
		win->tree[WINFO].ob_width += dw;
		
		win->tree[WUP].ob_x += dw;
		
		win->tree[TFILLOUT].ob_width += dw;
	
		win->tree[RFILLOUT].ob_height += dh;
		win->tree[RFILLOUT].ob_x += dw;
	
		win->tree[BFILLOUT].ob_width += dw;
		win->tree[BFILLOUT].ob_y += dy;
	
		win->tree[SFILLOUT].ob_x += dw;
		win->tree[SFILLOUT].ob_y += dh;

		win->tree[WAPP].ob_width = win->tree[WMOVER].ob_width;
		
		changeslider(-1,win,0,HSLIDE | VSLIDE,-1,-1);
	};
}

/*winalloc creates/fetches a free window structure/id*/

static WINSTRUCT	*winalloc(void) {
	WINLIST	*wl;
	
	if(win_free) {
		wl = win_free;
		win_free = win_free->next;
	}
	else {
		wl = (WINLIST *)Mxalloc(sizeof(WINLIST),GLOBALMEM);
		wl->win = (WINSTRUCT *)Mxalloc(sizeof(WINSTRUCT),GLOBALMEM);
		wl->win->id = win_next;
		win_next++;
	};
	
	wl->next = win_list;
	win_list = wl;
	
	return wl->win;
}

/* delwinelem deletes an object created with crwinelem*/

static void	delwinelem(OBJECT *o) {
	if(o) {
		Mfree(o);
	};
}

static WORD	top_window(WORD vid,WORD winid) { 
	WORD          wastopped = 0;
	WINSTRUCT     *oldtop;
	REDRAWSTRUCT	m;
	
	RLIST	*rl = 0L;
	RLIST	*rl2 = 0L;
	
	WINLIST	**wl = &globals.win_vis;
	WINLIST	*wl2;
	WINLIST	*ourwl;
	
	WORD	dx,dy;
	
	if(winid == 0) {
		if(globals.win_vis && (globals.win_vis->win->status & WIN_TOPPED)) {
			WORD i;
			
			globals.win_vis->win->status &= ~WIN_TOPPED;

			for(i = 0; i <= W_SMALLER; i++) {
				set_widget_colour(globals.win_vis->win,i,&globals.win_vis->win->untop_colour[i],&globals.win_vis->win->top_colour[i]);
			};
	
			Wind_draw_elements(vid,globals.win_vis->win,&globals.win_vis->win->totsize,0);
		};
	}
	else {
		while(*wl) {
			if((*wl)->win->id == winid)
				break;
				
			wl = &(*wl)->next;
		};
		
		if(!*wl)
			return 0;
		
		wl2 = *wl;
		
		*wl = (*wl)->next;

		if(globals.win_vis) {
			if(globals.win_vis->win->status & WIN_DIALOG) {
				wl2->next = globals.win_vis->next;
				globals.win_vis->next = wl2;
			}
			else {
				COMMSG m;
				
				oldtop = globals.win_vis->win;
				wl2->next = globals.win_vis;
				globals.win_vis = wl2;
				
				if(!(wl2->win->status & WIN_TOPPED)) {
					wl2->win->status |= WIN_TOPPED;
					oldtop->status &= ~WIN_TOPPED;
					
					wastopped = 1;
				};
				
				m.type = MH_TOP;
				m.sid = 0;
				m.length = 0;
				m.msg0 = wl2->win->owner;
	
				Appl_do_write(0, 16, &m);
			};
		}
		else
		{	
			wl2->next = 0L;
			globals.win_vis = wl2;
		};
	
		m.type = WM_REDRAW;
		
		if(globals.realmove) {
			m.sid = -1;
		}
		else {
			m.sid = 0;
		};
		
		ourwl = wl2;
	
		m.wid = ourwl->win->id;
		m.length = 0;
	
		dx = wl2->win->totsize.x;
		dy = wl2->win->totsize.y;	
			
		wl2 = wl2->next;
	
		while(wl2) {
			RLIST	*rd = 0L;
			
			Rlist_rectinter(&rl,&ourwl->win->totsize,&wl2->win->rlist);
			
			Rlist_insert(&rd,&wl2->win->rlist);
				
			wl2->win->rlist = rd;
			wl2->win->rpos = wl2->win->rlist;
			
			wl2 = wl2->next;
		};
		
	
		Rlist_insert(&rl2,&rl);
		
		rl = rl2;
	
		while(rl) {
			m.area.x = rl->r.x;
			m.area.y = rl->r.y;
			
			m.area.width = rl->r.width;
			m.area.height = rl->r.height;
		
			if(!wastopped) {
				Wind_draw_elemfast(vid,ourwl->win,&rl->r,0);
			};
			
			if(globals.realmove) {
				m.area.x -= dx;
				m.area.y -= dy;
			};
			
			Appl_do_write(ourwl->win->owner,16,&m);
	
			rl = rl->next;
		};
	
		Rlist_insert(&ourwl->win->rlist,&rl2);
	
		ourwl->win->rpos = ourwl->win->rlist;
	
		if(wastopped) {
			WORD i;
			
			for(i = 0; i <= W_SMALLER; i++) {
				set_widget_colour(oldtop,i,&oldtop->untop_colour[i],&oldtop->top_colour[i]);
				set_widget_colour(ourwl->win,i,&ourwl->win->untop_colour[i],&ourwl->win->top_colour[i]);
			};
	
			Wind_draw_elements(vid,ourwl->win,&ourwl->win->totsize,0);
			Wind_draw_elements(vid,oldtop,&oldtop->totsize,0);
		};
	};
		
	return 1;
}

static WORD	bottom_window(WORD vid,WORD winid) { 
	WORD          wastopped = 0;
	WINSTRUCT     *newtop = 0L;
	REDRAWSTRUCT	m;
	
	WINLIST	**wl = &globals.win_vis;
	WINLIST	*ourwl;
	
	while(*wl) {
		if((*wl)->win->id == winid)
			break;
			
		wl = &(*wl)->next;
	};
		
	if(!*wl) {
		return 0;
	};
		
	ourwl = *wl;
		
	*wl = (*wl)->next;

	if(*wl) {
		if((*wl)->win->status & WIN_MENU) {
			wl = &(*wl)->next;
		};
	};

	if((ourwl->win->status & WIN_TOPPED) && *wl) {
		if(!((*wl)->win->status & WIN_DESKTOP)) {
			newtop = (*wl)->win;
			(*wl)->win->status |= WIN_TOPPED;
			ourwl->win->status &= ~WIN_TOPPED;
			wastopped = 1;
		};
	};

	if(newtop) {
		COMMSG m;
		
		m.type = MH_TOP;
		m.sid = 0;
		m.length = 0;
		m.msg0 = newtop->owner;

		Appl_do_write(0, 16, &m);
	};

	m.type = WM_REDRAW;
	
	if(globals.realmove) {
		m.sid = -1;
	}
	else {
		m.sid = 0;
	};
	
	m.length = 0;

	while(*wl) {
		RLIST *newrects = 0L;
		
		if((*wl)->win->status & WIN_DESKTOP) {
			break;
		};
		
		Rlist_rectinter(&newrects,&(*wl)->win->totsize,&ourwl->win->rlist);
		
		Rlist_insert(&(*wl)->win->rlist,&newrects);

		if(!((*wl)->win->status & WIN_MENU)) {
			m.wid = (*wl)->win->id;
	
			m.area.x = ourwl->win->totsize.x;
			m.area.y = ourwl->win->totsize.y;
			
			m.area.width = ourwl->win->totsize.width;
			m.area.height = ourwl->win->totsize.height;
		
			if((*wl)->win != newtop) {
				Wind_draw_elements(vid,(*wl)->win,&m.area,0);
			};
			
			if(globals.realmove) {
				m.area.x -= (*wl)->win->totsize.x;
				m.area.y -= (*wl)->win->totsize.y;
			};
			
			Appl_do_write((*wl)->win->owner,16,&m);
		};
		
		wl = &(*wl)->next;
	};

	ourwl->next = *wl;
	*wl = ourwl;

	if(wastopped) {
		WORD i;
		
		for(i = 0; i <= W_SMALLER; i++) {
			set_widget_colour(ourwl->win,i,&ourwl->win->untop_colour[i],&ourwl->win->top_colour[i]);
			set_widget_colour(newtop,i,&newtop->top_colour[i],&newtop->top_colour[i]);
		};

		Wind_draw_elements(vid,ourwl->win,&ourwl->win->totsize,0);
		Wind_draw_elements(vid,newtop,&newtop->totsize,0);
	};
		
	return 1;
}

static WORD	changewinsize(WINSTRUCT *win,RECT *size,WORD vid,WORD drawall) {	
	WORD dx = size->x - win->totsize.x;
	WORD dy = size->y - win->totsize.y;
	WORD dw = size->width - win->totsize.width;
	WORD dh = size->height - win->totsize.height;
	RECT oldtotsize = win->totsize;
	RECT oldworksize = win->worksize;

	setwinsize(win,size);

	if(win->status & WIN_OPEN) {
		if(dx || dy) { /* pos (and maybe size) is to be changed */
			REDRAWSTRUCT	m;
			
			WINLIST	*wl = globals.win_vis;
			
			while(wl)
			{
				if(wl->win == win)
				{
					wl = wl->next;
					break;
				};
					
				wl = wl->next;
			};
			
			if(wl) {
				RLIST	*rlwalk;
				RLIST	*rlournew = NULL;
				RLIST	*rlourold = win->rlist;
				RLIST	*old_rlist = Rlist_duplicate(win->rlist);
				RLIST	*rlmove = NULL;
				RLIST *rlmove1 = NULL;
				WINLIST *wlwalk = wl;
			
				win->rlist = 0L;
			
				/*grab the rectangles we need from our old list*/
				
				Rlist_rectinter(&rlournew,size,&rlourold);
			
				while(wlwalk) {
					/*get the new rectangles we need*/
					
					Rlist_rectinter(&rlournew,size,&wlwalk->win->rlist);

					wlwalk = wlwalk->next;
				};
				
				Rlist_insert(&win->rlist,&rlournew);

				if(drawall) {
					m.type = WM_REDRAW;
					
					if(globals.realmove) {
						m.sid = -1;
					}
					else {
						m.sid = 0;
					};
					
					m.length = 0;
					m.wid = win->id;
	
					m.area = *size;
					
					Wind_draw_elements(vid,win,&m.area,0);

					if(globals.realmove) {
						m.area.x = 0;
						m.area.y = 0;
					};
	
					Appl_do_write(win->owner,16,&m);
				}
				else {			
					/*figure out which rectangles that are moveable*/
	
					if(dw || dh) {
						Rlist_rectinter(&rlmove1,&win->worksize,&win->rlist);
					}
					else {
						rlmove1 = win->rlist;
						win->rlist = NULL;
					};
												
					rlwalk = old_rlist;
					
					while(rlwalk) {
						rlwalk->r.x += dx;
						rlwalk->r.y += dy;
						
						Rlist_rectinter(&rlmove,&rlwalk->r,&rlmove1);
						
						rlwalk = rlwalk->next;
					};
					
					/*move the rectangles that are moveable*/
	
					Rlist_sort(&rlmove,dx,dy);
					
					rlwalk = rlmove;
	
					Vdi_v_hide_c(vid);
	
					while(rlwalk) {
						MFDB	mfdbd,mfdbs;
						WORD	koordl[8];
						
						mfdbd.fd_addr = 0L;
						mfdbs.fd_addr = 0L;
						
						koordl[4] = rlwalk->r.x;
						koordl[5] = rlwalk->r.y + rlwalk->r.height - 1;
						koordl[6] = rlwalk->r.x + rlwalk->r.width - 1;
						koordl[7] = rlwalk->r.y;
						koordl[0] = koordl[4] - dx;
						koordl[1] = koordl[5] - dy;
						koordl[2] = koordl[6] - dx;
						koordl[3] = koordl[7] - dy;
						
						Vdi_vro_cpyfm(vid,S_ONLY,koordl,&mfdbs,&mfdbd);
						
						rlwalk = rlwalk->next;
					};
	
					Vdi_v_show_c(vid,1);
	
					/*update rectangles that are not moveable*/
								
					m.type = WM_REDRAW;
					
					if(globals.realmove) {
						m.sid = -1;
					}
					else {
						m.sid = 0;
					};
					
					m.length = 0;
					m.wid = win->id;
	
					Rlist_insert(&win->rlist,&rlmove1);
				
					rlwalk = win->rlist;
					
					while(rlwalk) {
						m.area.x = rlwalk->r.x;
						m.area.y = rlwalk->r.y;
											
						m.area.width = rlwalk->r.width;
						m.area.height = rlwalk->r.height;
	
						Wind_draw_elemfast(vid,win,&m.area,0);
					
						if(globals.realmove) {
							m.area.x -= size->x;
							m.area.y -= size->y;
						};
	
						Appl_do_write(win->owner,16,&m);
	
						rlwalk = rlwalk->next;
					};
									
					Rlist_insert(&win->rlist,&rlmove);
				};
				
				Rlist_erase(&old_rlist);

				wlwalk = wl;

				while(wlwalk) {
					RLIST	*rltheirnew = NULL;
					
					/*give away the rectangles we don't need*/
					
					Rlist_rectinter(&rltheirnew,&wlwalk->win->totsize,&rlourold);
				
					/*update the new rectangles*/
				
					rlwalk = rltheirnew;
					
					while(rlwalk) {
						m.area.width = rlwalk->r.width;
						m.area.height = rlwalk->r.height;
					
						m.area.x = rlwalk->r.x;
						m.area.y = rlwalk->r.y;
						
						Wind_draw_elemfast(vid,wlwalk->win,&m.area,0);
										
						rlwalk = rlwalk->next;
					};				
				
					if(rltheirnew && !(wlwalk->win->status & WIN_DESKTOP)) {
						m.type = WM_REDRAW;
					
						if(globals.realmove) {
							m.sid = -1;
						}
						else {
							m.sid = 0;
						};
	
						m.length = 0;
						m.wid = wlwalk->win->id;
		
						m.area = oldtotsize;
		
						if(globals.realmove) {
							m.area.x -= wlwalk->win->totsize.x;
							m.area.y -= wlwalk->win->totsize.y;
						};
						
						Appl_do_write(wlwalk->win->owner,16,&m);
					};
				
					Rlist_insert(&wlwalk->win->rlist,&rltheirnew);

					wlwalk->win->rpos = wlwalk->win->rlist;

					wlwalk = wlwalk->next;
				};
	
				win->rpos = win->rlist;
			};			
		}
		else if(dw || dh)	/*only size changed*/ {
			RECT	rt;
			RECT	dn;

			REDRAWSTRUCT	m;

			RLIST	*rl = 0L;
			RLIST	*rl2;
			RLIST	*rltop = 0L;
			
			WINLIST	*wl = globals.win_vis;
						

			rt.x = size->x + size->width;

			if(dw < 0) {
				rt.width = -dw;
			}
			else {
				rt.x -= dw;
				rt.width = dw;
			};
			
			rt.y = size->y;
			rt.height = size->height;
				
			dn.y = size->y + size->height;

			if(dh < 0) {
				dn.height = -dh;
				dn.width = oldtotsize.width;
			}
			else {
				dn.y -= dh;
				dn.height = dh;
				dn.width = size->width;
			};

			dn.x = size->x;
		
			if(dw < 0) {
				Rlist_rectinter(&rl,&rt,&win->rlist);
			};
		
			if(dh < 0) {
				Rlist_rectinter(&rl,&dn,&win->rlist);
			};

			/* Find our window */
		
			while(wl) {
				if(wl->win == win) {
					wl = wl->next;
					break;
				};
					
				wl = wl->next;
			};
		
			while(wl) {
				RLIST	*rd = 0;

				if(dw < 0) {
					Rlist_rectinter(&rd,&wl->win->totsize,&rl);
				}
				else if(dw > 0) {
					Rlist_rectinter(&rltop,&rt,&wl->win->rlist);
				};
				
				if(dh < 0) {
					Rlist_rectinter(&rd,&wl->win->totsize,&rl);
				}
				else if(dh > 0) {
					Rlist_rectinter(&rltop,&dn,&wl->win->rlist);
				};
			
				rl2 = rd;
				
				while(rl2) {
					Wind_draw_elemfast(vid,wl->win,&rl2->r,0);
				

					rl2 = rl2->next;
				};

				m.type = WM_REDRAW;
				
				if(globals.realmove) {
					m.sid = -1;
				}
				else {
					m.sid = 0;
				};
					
				m.length = 0;

				if(rd && !(wl->win->status & WIN_DESKTOP)) {
					m.wid = wl->win->id;
				
					m.area = oldtotsize;
									
					if(globals.realmove) {
						m.area.x -= wl->win->totsize.x;
						m.area.y -= wl->win->totsize.y;
					};
						
					Appl_do_write(wl->win->owner,16,&m);
				};

				Rlist_insert(&wl->win->rlist,&rd);
				
				wl->win->rpos = wl->win->rlist;
				
				wl = wl->next;
			};

			rl2 = 0;

			Rlist_rectinter(&rl2,&oldworksize,&win->rlist);

			Rlist_rectinter(&rltop,&win->worksize,&win->rlist);
			
			Rlist_insert(&win->rlist,&rl2);
			
			rl2 = rltop;
			rltop = 0L;
			
			Rlist_insert(&rltop,&rl2);

			m.wid = win->id;

			rl2 = rltop;
			
			while(rl2) {
				m.area.x = rl2->r.x;
				m.area.y = rl2->r.y;
				
				if(globals.realmove) {
					m.area.x -= size->x;
					m.area.y -= size->y;
				};
				
				m.area.width = rl2->r.width;
				m.area.height = rl2->r.height;
				
				Appl_do_write(win->owner,16,&m);
				
				rl2 = rl2->next;
			};
			
			Rlist_insert(&win->rlist,&rltop);

			rl2 = win->rlist;

			while(rl2) {
				Wind_draw_elemfast(vid,win,&rl2->r,0);

				rl2 = rl2->next;
			};

			win->rpos = win->rlist;
		};
	};
		
	return 1;
}

/*calcworksize calculates the worksize or the total size of
a window. If dir == WC_WORK the worksize will be calculated and 
otherwise the total size will be calculated.*/

static void	calcworksize(WORD elem,RECT *orig,RECT *new,WORD dir) {
	WORD	bottomsize = 1;
	WORD	headsize = 1;
	WORD	leftsize = 1;
	WORD	rightsize = 1;
	WORD	topsize;
	
	if((HSLIDE | LFARROW | RTARROW) & elem) {
		bottomsize = globals.windowtad[WLEFT].ob_height + (D3DSIZE << 1);
	};
	
	if((CLOSER | MOVER | FULLER | NAME) & elem) {
		topsize = globals.windowtad[WMOVER].ob_height + (D3DSIZE << 1);
	}
	else if(IMOVER & elem) {
		topsize = globals.csheight + 2 + D3DSIZE * 2;
	}
	else {
		topsize = 0;
	};
	
	if(INFO & elem) {
		headsize = topsize + globals.windowtad[WINFO].ob_height + 2 * D3DSIZE;
	}
	else {
		if(topsize)
			headsize = topsize;
		else
			headsize = 1;
	};
	
	if((LFARROW | HSLIDE | RTARROW) & elem) {
		bottomsize = globals.windowtad[WLEFT].ob_height + (D3DSIZE << 1);
	};
	
	if(((bottomsize < globals.windowtad[WLEFT].ob_height) && (SIZER & elem))
		|| ((VSLIDE | UPARROW | DNARROW) & elem))
	{
		rightsize = globals.windowtad[WSIZER].ob_width + (D3DSIZE << 1);
	};

	if(dir == WC_WORK) {
		new->x = orig->x + leftsize;
		new->y = orig->y + headsize;
		new->width = orig->width - leftsize - rightsize;
		new->height = orig->height - headsize - bottomsize;
	}
	else {
		new->x = orig->x - leftsize;
		new->y = orig->y - headsize;
		new->width = orig->width + leftsize + rightsize;
		new->height = orig->height + headsize + bottomsize;
	};
}

/****************************************************************************
 * Public functions                                                         *
 ****************************************************************************/

/*Wind_init_module initializes the window system*/

void	Wind_init_module(void) {
  WORD	vid = globals.vid;
  WORD	i;
  WORD	work_in[] = {1,7,1,1,1,1,1,1,1,1,2};
  WORD	work_out[57];
  
  WINLIST	*wl;
  
  WINSTRUCT	*ws;
	
  
  /* open up a vdi workstation to use in the process */
  
  Vdi_v_opnvwk(work_in,&vid,work_out);
	
  if(globals.num_pens < 16) {
  	for(i = 0; i <= W_SMALLER; i++) {
  		untop_colour[i].pattern = 0;
  		untop_colour[i].fillc = WHITE;
  		top_colour[i].pattern = 0;
  		top_colour[i].fillc = WHITE;
  	}
  }
	
  ws = winalloc();
  ws->status = WIN_OPEN | WIN_DESKTOP | WIN_UNTOPPABLE;
  ws->owner = 0;
  
  
  ws->tree = NULL;

  ws->worksize.x = globals.screen.x;
  ws->worksize.y = globals.screen.y + globals.clheight + 3;
  ws->worksize.width = globals.screen.width;
  ws->worksize.height = globals.screen.height - globals.clheight - 3;
  
  ws->maxsize = ws->totsize = ws->worksize;

  wl = (WINLIST *)Mxalloc(sizeof(WINLIST),GLOBALMEM);
  
  wl->win = ws;
  
  wl->next = globals.win_vis;
  globals.win_vis = wl;

  wl->win->rlist = (RLIST *)Mxalloc(sizeof(RLIST),GLOBALMEM);
  wl->win->rlist->r.x = globals.screen.x;
  wl->win->rlist->r.y = globals.screen.y;
  wl->win->rlist->r.width = globals.screen.width;
  wl->win->rlist->r.height = globals.screen.height;
  wl->win->rlist->next = NULL;
  
  Vdi_v_clsvwk(vid);
  
  /* Create screen drawing semaphore */
  
	update.id = Rdwrs_create_sem();  
}

void	Wind_exit_module(void) {
  /* Destroy screen drawing semaphore */

	Rdwrs_destroy_sem(update.id);  
}


/****************************************************************************
 * Wind_update_deskbg                                                       *
 *  Update all of the desk background.                                      *
 ****************************************************************************/
void                     /*                                                 */
Wind_update_deskbg(      /*                                                 */
WORD vid)                /* VDI workstation id.                             */
/****************************************************************************/
{
	WINSTRUCT *win;

	win = Wind_find_description(0);
	Wind_draw_elements(vid,win,&globals.screen,0);
}

/****************************************************************************
 * Wind_find_description                                                    *
 *  Find the window structure of the window with identification number id.  *
 ****************************************************************************/
WINSTRUCT	*             /* Found description or NULL.                       */
Wind_find_description(  /*                                                  */
WORD id)                /* Identification number of window.                 */
/****************************************************************************/
{
	WINLIST	*wl;

	wl = win_list;
	
	while(wl) {
		if(wl->win->id == id)
		{
			return wl->win;
		}

		wl = wl->next;
	};

	return NULL;
}

/****************************************************************************
 * Wind_appl_top                                                            *
 *  Top the top window of an application.                                   *
 ****************************************************************************/
WORD            /* 0 if error or 1 if ok.                                   */
Wind_appl_top(  /*                                                          */
WORD vid,       /* VDI workstation id.                                      */
WORD apid)      /* Application id.                                          */
/****************************************************************************/
{
	WORD    wid = 0;
	WINLIST *wl;
	
	Rdwrs_operation(WSTARTREAD);
	
	wl = globals.win_vis;
	
	while(wl) {
		if(wl->win->owner == apid) {
			wid = wl->win->id;
			break;
		};
		
		wl = wl->next;
	};
	
	Rdwrs_operation(WENDREAD);

	top_window(vid,wid);
	
	return 1;
}


/****************************************************************************
 * Wind_do_delete                                                           *
 *  Implementation of wind_delete().                                        *
 ****************************************************************************/
WORD            /* 0 if error or 1 if ok.                                   */
Wind_do_delete( /*                                                          */
WORD vid,       /* VDI workstation id.                                      */
WORD id)        /* Identification number of window to delete.               */
/****************************************************************************/
{
	WINLIST	**wl;
		
	wl = &win_list;
	
	while(*wl) {		
		if((*wl)->win->id == id)
			break;
	
		wl = &(*wl)->next;
	};
	
	if(!(*wl)) {
		/*no such window found! return*/
		return 0;
	};
	
	if((*wl)->win->status & WIN_OPEN) {
		Wind_do_close(vid,id);
	};
	
	delwinelem((*wl)->win->tree);
	
	if(id == (win_next - 1)) {
		WORD	found;
		WINLIST	*wt = *wl;
		
		*wl = (*wl)->next;
		
		Mfree(wt->win);
		Mfree(wt);
		win_next--;
		
		do {
			WINLIST 	**wlwalk = &win_list;
			
			found = 0;
			
			while(*wlwalk) {
				if((*wlwalk)->win->id == (win_next - 1))
				{
					found = 1;
					break;
				};
				
				wlwalk = &(*wlwalk)->next;
			};
			
			if(!found)
			{
				wlwalk = &win_free;
				
				while(*wlwalk)
				{
					if((*wlwalk)->win->id == (win_next - 1))
					{
						WINLIST	*wltemp = *wlwalk;
						
						*wlwalk = (*wlwalk)->next;
						
						Mfree(wltemp->win);
						Mfree(wltemp);
						
						win_next--;
						
						break;
					};
					
					wlwalk = &(*wlwalk)->next;
				};
			};
			
		}while(!found && win_next);

	}
	else
	{
		WINLIST	*wt = *wl;
		
		*wl = (*wl)->next;
		
		wt->next = win_free;
		win_free = wt;
	};
	
	return 1;
}



/****************************************************************************
 * Wind_draw_elements                                                       *
 *  Draw the elements of the window win that intersects with the rectangle  *
 *  r.                                                                      *
 ****************************************************************************/
void                 /*                                                     */
Wind_draw_elements(  /*                                                     */
WORD vid,            /* VDI workstation id.                                 */
WINSTRUCT *win,      /* Window description.                                 */
RECT *r,             /* Clipping rectangle.                                 */
WORD start)          /* Start object.                                       */
/****************************************************************************/
{
	RLIST	*rl = win->rlist;

	if(win->id == 0) {
		OBJECT *deskbg;
	
		Rdwrs_operation(ASTARTREAD);
		
		deskbg = Appl_get_deskbg();
		
		if(deskbg) {
			while(rl) {		
				RECT	r2;
			
				if(Misc_intersect(&rl->r,r,&r2)) {
					Objc_do_draw(vid,deskbg,start,9,&r2);
				};
					
				rl = rl->next;
			};
		};
		
		Rdwrs_operation(AENDREAD);		
	}
	else if(win->tree) {	
		while(rl) {		
			RECT	r2;
		
			if(Misc_intersect(&rl->r,r,&r2)) {
				Objc_do_draw(vid,win->tree,start,3,&r2);
			};
			rl = rl->next;
		};
	};
}

/****************************************************************************
 * Wind_draw_elemfast                                                       *
 *  Draw the elements of the window win that intersects with the rectangle  *
 *  r.                                                                      *
 ****************************************************************************/
void                 /*                                                     */
Wind_draw_elemfast(  /*                                                     */
WORD vid,            /* VDI workstation id.                                 */
WINSTRUCT *win,      /* Window description.                                 */
RECT *r,             /* Clipping rectangle.                                 */
WORD start)          /* Start object.                                       */
/****************************************************************************/
{
	if(win->id == 0) {
		OBJECT *deskbg;
	
		Rdwrs_operation(ASTARTREAD);
		
		deskbg = Appl_get_deskbg();
		
		if(deskbg) {
			Objc_do_draw(vid,deskbg,start,9,r);
		};
		
		Rdwrs_operation(AENDREAD);		
	}
	else if(win->tree) {	
		Objc_do_draw(vid,win->tree,start,3,r);
	};
}


/****************************************************************************
 * Wind_do_create                                                           *
 *  Implementation of wind_create().                                        *
 ****************************************************************************/
WORD             /* 0 if error or 1 if ok.                                  */
Wind_do_create(  /*                                                         */
WORD owner,      /* Owner of window.                                        */
WORD elems,      /* Elements of window.                                     */
RECT *maxsize,   /* Maximum size allowed.                                   */
WORD status)     /* Status of window.                                       */
/****************************************************************************/
{
	WINSTRUCT	*ws;
	
	ws = winalloc();
	
	ws->status = status;
	ws->owner = owner; 
	
	ws->maxsize = *maxsize;

	ws->rlist = NULL;
	ws->rpos = NULL;

	ws->vslidepos = 1;
	ws->vslidesize = 1000;
	ws->hslidepos = 1;
	ws->hslidesize = 1000;
	
	if((ws->status & WIN_DIALOG) || (ws->status & WIN_MENU)) {
		ws->tree = 0L;
		ws->totsize = *maxsize;
		ws->worksize = ws->totsize;
	}
	else {
		WORD    i;
		AP_INFO *ai;
		
		ws->tree = alloc_win_elem();
		set_win_elem(ws->tree,elems);
		ws->elements = elems;
	
		Rdwrs_operation(ASTARTREAD);
		ai = Appl_internal_info(owner);
		
		if(ai) {
			ws->tree[WAPP].ob_spec.tedinfo->te_ptext =
				(char *)Mxalloc(strlen(&ai->name[2]) + 1,GLOBALMEM);
			strcpy(ws->tree[WAPP].ob_spec.tedinfo->te_ptext,&ai->name[2]);
			
			if(globals.wind_appl == 0) {
				ws->tree[WAPP].ob_spec.tedinfo->te_ptext[0] = 0;
			};
		};
		
		Rdwrs_operation(AENDREAD);
	
		ws->totsize.x = ws->tree[0].ob_x;
		ws->totsize.y = ws->tree[0].ob_y;
		ws->totsize.width = ws->tree[0].ob_width;
		ws->totsize.height = ws->tree[0].ob_height;
	
		calcworksize(elems,&ws->totsize,&ws->worksize,WC_WORK);
		
		for(i = 0; i <= W_SMALLER; i++) {
			ws->top_colour[i] = top_colour[i];
			ws->untop_colour[i] = untop_colour[i];
		}
		
		ws->own_colour = 0;
	};

	return ws->id;
}

/*wind_create 0x0064*/

void	Wind_create(AES_PB *apb) {	
	Rdwrs_operation(WSTARTWRITE);

	apb->int_out[0] = Wind_do_create(apb->global->apid
		,apb->int_in[0],(RECT *)&apb->int_in[1],0);

	Rdwrs_operation(WENDWRITE);
}


/****************************************************************************
 * Wind_do_open                                                             *
 *  Implementation of wind_open().                                          *
 ****************************************************************************/
WORD           /* 0 if error or 1 if ok.                                    */
Wind_do_open(  /*                                                           */
WORD vid,      /* VDI workstation id.                                       */
WORD id,       /* Identification number of window to open.                  */
RECT *size)    /* Initial size of window.                                   */
/****************************************************************************/
{
	WINLIST	     *wl,*wp;
	WINSTRUCT    *ws,*oldtop;
	RLIST	       *rl = 0L;
	REDRAWSTRUCT m;
	WORD         owner;
	WORD         i;
	WORD         wastopped = 0;

	ws = Wind_find_description(id);

	if(ws) {
		if(!(ws->status & WIN_OPEN)) {
			wl = (WINLIST *)Mxalloc(sizeof(WINLIST),GLOBALMEM);
		
			wl->win = ws;
			
			setwinsize(wl->win,size);
		
			if(globals.win_vis) {
				if(globals.win_vis->win->status & WIN_DIALOG) {
					wl->next = globals.win_vis->next;
					globals.win_vis->next = wl;
					wl->win->status &= ~WIN_TOPPED;
				}
				else
				{					
					oldtop = globals.win_vis->win;
					wl->next = globals.win_vis;
					globals.win_vis = wl;

					if(!(wl->win->status & WIN_MENU)) {
						COMMSG m;

						wl->win->status |= WIN_TOPPED;
						oldtop->status &= ~WIN_TOPPED;
						wastopped = 1;
	
						m.type = MH_TOP;
						m.sid = 0;
						m.length = 0;
						m.msg0 = wl->win->owner;

						Appl_do_write(0, 16, &m);
					};
				};
			}
			else {	
				wl->next = 0L;
				globals.win_vis = wl;
				wl->win->status |= WIN_TOPPED;
			};
			
			wp = wl->next;
		
			while(wp != 0L) {
				RLIST	*rd = 0L;
				
				Rlist_rectinter(&rl,&wl->win->totsize,&wp->win->rlist);
				
				Rlist_insert(&rd,&wp->win->rlist);
					
				wp->win->rlist = rd;
				wp = wp->next;
			};
		
			wl->win->rlist = 0L;
			Rlist_insert(&wl->win->rlist,&rl);
		
			wl->win->status |= WIN_OPEN;
			
			for(i = 0; i <= W_SMALLER; i++) {
				set_widget_colour(ws,i,&ws->untop_colour[i],&ws->top_colour[i]);
			};
			
			if(!(wl->win->status & (WIN_DIALOG | WIN_MENU))){
				m.type = WM_REDRAW;
				m.length = 0;
				
				if(globals.realmove) {
					m.sid = -1;
					m.area.x = 0; /*x and y are relative to the position of the window*/
					m.area.y = 0;
				}
				else {
					m.sid = 0;
					m.area.x = wl->win->totsize.x;
					m.area.y = wl->win->totsize.y;
				};
				
				m.area.width = wl->win->totsize.width;
				m.area.height = wl->win->totsize.height;
				
				m.wid = wl->win->id;
			
				owner = wl->win->owner;

				Wind_draw_elements(vid,wl->win,&wl->win->totsize,0);				
			
				Appl_do_write(owner,MSG_LENGTH,&m);
			};

			if(wastopped) {
				WORD i;
				
				for(i = 0; i <= W_SMALLER; i++) {
					set_widget_colour(oldtop,i,&oldtop->untop_colour[i],&oldtop->top_colour[i]);
				};

				Wind_draw_elements(vid,oldtop,&oldtop->totsize,0);
			};
		}
		else {
			return 0;
		};
	}
	else {
		return 0;
	};
	
	return 1;
}

/*wind_open 0x0065*/

void Wind_open(AES_PB *apb) {
	Rdwrs_operation(WSTARTWRITE);

	apb->int_out[0] = Wind_do_open(apb->global->int_info->vid,
											apb->int_in[0],(RECT *)&apb->int_in[1]);

	Rdwrs_operation(WENDWRITE);
}

/*wind_close 0x0066*/

/****************************************************************************
 * Wind_do_close                                                            *
 *  Implementation of wind_close().                                         *
 ****************************************************************************/
WORD           /* 0 if error or 1 if ok.                                    */
Wind_do_close( /*                                                           */
WORD vid,      /* VDI workstation id.                                       */
WORD wid)      /* Identification number of window to close.                 */
/****************************************************************************/
{
	WINLIST	  **wl = &globals.win_vis;
	WINSTRUCT *newtop = NULL;
	
	while(*wl) {
		if((*wl)->win->id == wid)
			break;
			
		wl = &(*wl)->next;
	};
	
	if(*wl) {
		WINLIST      *wp = (*wl)->next;
		REDRAWSTRUCT m;
		
		if(((*wl)->win->status & WIN_TOPPED) && wp) {
			(*wl)->win->status &= ~WIN_TOPPED;
			wp->win->status |= WIN_TOPPED;
			newtop = wp->win;
		};
		
		while(wp) {			
			RLIST	*rl = NULL;
			RLIST	*tl;
			
			Rlist_rectinter(&rl,&wp->win->totsize,&(*wl)->win->rlist);
			
			/* Redraw "new" rectangles of windows below */
			
			if(rl) {
				if(!(wp->win->status & (WIN_DESKTOP | WIN_MENU))) {
					m.type = WM_REDRAW;
					m.length = 0;
					m.wid = wp->win->id;
					
					if(globals.realmove) {
						m.sid = -1;
						m.area.x = (*wl)->win->totsize.x - wp->win->totsize.x;
						m.area.y = (*wl)->win->totsize.y - wp->win->totsize.y;
					}
					else {
						m.sid = 0;
						m.area.x = (*wl)->win->totsize.x;
						m.area.y = (*wl)->win->totsize.y;
					};
					
					m.area.width = (*wl)->win->totsize.width;
					m.area.height = (*wl)->win->totsize.height;	
	
					Appl_do_write(wp->win->owner,16,&m);
				};
				
				if(wp->win != newtop) {
					tl = rl;
				
					while(tl) {				
						Wind_draw_elemfast(vid,wp->win,&tl->r,0);
	
						tl = tl->next;
					};
				};
						
				Rlist_insert(&wp->win->rlist,&rl);
				wp->win->rpos = wp->win->rlist;
			};		

			wp = wp->next;
		}		
		
		wp = *wl;
		
		*wl = (*wl)->next;

		wp->win->status &= ~WIN_OPEN;
		Mfree(wp);
		
		if(newtop) {
			WORD i;
				
			for(i = 0; i <= W_SMALLER; i++) {
				set_widget_colour(newtop,i,&newtop->untop_colour[i],&newtop->top_colour[i]);
			};

			Wind_draw_elements(vid,newtop,&newtop->totsize,0);
		};

		return 1;
	}
	else
	{
		return 0;
	}
}

void	Wind_close(AES_PB *apb) {
	Rdwrs_operation(WSTARTWRITE);

	apb->int_out[0] = Wind_do_close(apb->global->int_info->vid,
																	apb->int_in[0]);

	Rdwrs_operation(WENDWRITE);
}


/*wind_delete 0x0067*/
void	Wind_delete(AES_PB *apb) {
	Rdwrs_operation(WSTARTWRITE);
	apb->int_out[0] = Wind_do_delete(apb->global->int_info->vid,
																	apb->int_in[0]);
	Rdwrs_operation(WENDWRITE);
}

/*wind_get 0x0068*/

/****************************************************************************
 * Wind_do_get                                                              *
 *  Implementation of wind_get().                                           *
 ****************************************************************************/
WORD           /* 0 if error or 1 if ok.                                    */
Wind_do_get(   /*                                                           */
WORD handle,   /* Identification number of window.                          */
WORD mode,     /* Tells what to return.                                     */
WORD *parm1,   /* Parameter 1.                                              */
WORD *parm2,   /* Parameter 2.                                              */
WORD *parm3,   /* Parameter 3.                                              */
WORD *parm4)   /* Parameter 4.                                              */
/****************************************************************************/
{
	WINSTRUCT	*win;
	WORD      ret;

	Rdwrs_operation(WSTARTREAD);
	
	win = Wind_find_description(handle);

	if(win) {
		switch(mode) {	
			case WF_WORKXYWH	:	/*0x0004*/
				ret = 1;
				*parm1 = win->worksize.x;
				*parm2 = win->worksize.y;
				*parm3 = win->worksize.width;
				*parm4 = win->worksize.height;
				break;
			
			case	WF_CURRXYWH	:	/*0x0005*/
				ret = 1;
				*parm1 = win->totsize.x;
				*parm2 = win->totsize.y;
				*parm3 = win->totsize.width;
				*parm4 = win->totsize.height;
				break;

			case	WF_PREVXYWH	:	/*0x0006*/
				ret = 1;
				*parm1 = win->lastsize.x;
				*parm2 = win->lastsize.y;
				*parm3 = win->lastsize.width;
				*parm4 = win->lastsize.height;
				break;
			
			case	WF_FULLXYWH	:	/*0x0007*/
				ret = 1;
				*parm1 = win->maxsize.x;
				*parm2 = win->maxsize.y;
				*parm3 = win->maxsize.width;
				*parm4 = win->maxsize.height;
				break;
				
			case WF_HSLIDE: /*0x08*/
				ret = 1;
				*parm1 = win->hslidepos;
				break;

			case WF_VSLIDE: /*0x09*/
				ret = 1;
				*parm1 = win->vslidepos;
				break;

			case WF_TOP: /*0x000a*/
				if(globals.win_vis) {
					*parm1 = globals.win_vis->win->id;
					*parm2 = globals.win_vis->win->owner;
					
					if(globals.win_vis && globals.win_vis->next) {
						*parm3 = globals.win_vis->next->win->id;
					}
					else {
						*parm3 = -1;
					};
					
					ret = 1;
				}
				else {
					ret = 0;
				};
				break;

			case	WF_FIRSTXYWH:	/*0x000b*/
				win->rpos = win->rlist;
			case	WF_NEXTXYWH:	/*0x000c*/
				{
					RECT r;
					
					ret = 1;
					
					while(win->rpos) {
						if(Misc_intersect(&win->rpos->r,&win->worksize,&r)) {
							break;
						};
						
						win->rpos = win->rpos->next;
					};					
					
					if(!win->rpos) {
						*parm1 = 0;
						*parm2 = 0;
						*parm3 = 0;
						*parm4 = 0;
					}
					else {
						win->rpos = win->rpos->next;

						*parm1 = r.x;
						*parm2 = r.y;
						*parm3 = r.width;
						*parm4 = r.height;
					};
				};
				break;

			case WF_HSLSIZE: /*0x0f*/
				ret = 1;
				*parm1 = win->hslidesize;
				break;				

			case WF_VSLSIZE: /*0x10*/
				ret = 1;
				*parm1 = win->vslidesize;
				break;				

			case WF_SCREEN: /*0x11*/
				ret = 1;
				*parm1 = 0;
				*parm2 = 0;
				*parm3 = 0;
				*parm4 = 0;
				break;
				
			case WF_OWNER: /*0x14*/
				if(win) {
					ret = 1;
					*parm1 = win->owner;
					
					if(win->status & WIN_OPEN) {
						WINLIST *wl = globals.win_vis;
						
						*parm2 = 1;

						if(wl->win == win) {
							*parm3 = -1;
						}
						else if(wl) {
							while(wl->next) {
								if(wl->next->win == win) {
									*parm3 = wl->win->id;
									break;
								};
								
								wl = wl->next;
							};
							
							wl = wl->next;
						};
						
						if(wl) {
							wl = wl->next;
						
							if(wl) {
								*parm4 = wl->win->id;
							}
							else {
								*parm4 = -1;
							};
						}
						else {
							*parm4 = -1;
						};							
					}
					else {
						*parm2 = 0;
						*parm3 = -1;
						*parm4 = -1;
					};
				}
				else {
					ret = 0;
				};
				break;

			case WF_ICONIFY: /* 0x1a */
				if(win->status & WIN_ICONIFIED) {
					*parm1 = 1;
				}
				else {
					*parm1 = 0;
				};

				*parm2 = globals.icon_width;
				*parm3 = globals.icon_height;

				ret = 1;
				break;

			case WF_WINX:
			case WF_WINXCFG:
				ret = 0;
				break;

			default:
				DB_printf("%s: Line %d: Wind_do_get:\r\n"
								"Unknown mode %d  (0x%x) wind_get(%d,%d,...)",
								__FILE__,__LINE__,mode,mode,
								handle,mode);
				ret = 0;
		};
	}
	else
		ret = 0;

	Rdwrs_quick(WENDREAD);
	
	return ret;
}


void	Wind_get(AES_PB *apb) {
	apb->int_out[0] = Wind_do_get(apb->int_in[0],apb->int_in[1],
																&apb->int_out[1],&apb->int_out[2],
																&apb->int_out[3],&apb->int_out[4]);
}


/*wind_set 0x0069*/
void	Wind_set(AES_PB *apb) {
	WINSTRUCT	*win;
	
	Rdwrs_operation(WSTARTWRITE);
	
	win = Wind_find_description(apb->int_in[0]);

	if(win) {
		switch(apb->int_in[1]) {	
			case	WF_NAME	:	/*0x0002*/
				Mfree(win->tree[WMOVER].ob_spec.tedinfo->te_ptext);
				win->tree[WMOVER].ob_spec.tedinfo->te_ptext =
					(BYTE *)Mxalloc(strlen(((BYTE **)&apb->int_in[2])[0]) + 1,GLOBALMEM);
				strcpy(win->tree[WMOVER].ob_spec.tedinfo->te_ptext,((BYTE **)&apb->int_in[2])[0]);
				
				Wind_draw_elements(apb->global->int_info->vid,win,&win->totsize,WMOVER);

				apb->int_out[0] = 1;
				break;

			case	WF_INFO	:	/*0x0003*/
				Mfree(win->tree[WINFO].ob_spec.tedinfo->te_ptext);
				win->tree[WINFO].ob_spec.tedinfo->te_ptext =
					(BYTE *)Mxalloc(strlen(((BYTE **)&apb->int_in[2])[0]) + 1,GLOBALMEM);
				strcpy(win->tree[WINFO].ob_spec.tedinfo->te_ptext,((BYTE **)&apb->int_in[2])[0]);

				Wind_draw_elements(apb->global->int_info->vid,win,&win->totsize,WINFO);

				apb->int_out[0] = 1;
				break;
				
			case	WF_CURRXYWH	:	/*0x0005*/
				apb->int_out[0] = 
					changewinsize(win,(RECT *)&apb->int_in[2],apb->global->int_info->vid,0);
				break;

			case	WF_HSLIDE: /*0x08*/
				apb->int_out[0] = 
						changeslider(apb->global->int_info->vid,win,1,HSLIDE,apb->int_in[2],-1);
				break;

			case	WF_VSLIDE: /*0x09*/
				apb->int_out[0] = 
					changeslider(apb->global->int_info->vid,win,1,VSLIDE,apb->int_in[2],-1);
				break;

			case	WF_TOP	:	/*0x000a*/
				apb->int_out[0] =
						top_window(apb->global->int_info->vid,apb->int_in[0]);
				break;

			case WF_NEWDESK: /*0x000e*/
				{
					if((((OBJECT **)&apb->int_in[2])[0])->ob_y +
						(((OBJECT **)&apb->int_in[2])[0])->ob_height < globals.screen.height) {
						(((OBJECT **)&apb->int_in[2])[0])->ob_y =
						globals.screen.height - (((OBJECT **)&apb->int_in[2])[0])->ob_height;
					};
				
					if(Appl_set_deskbg(apb->global->apid,
							apb->global->int_info->vid,((OBJECT **)&apb->int_in[2])[0]) == 0) {
						apb->int_out[0] = 1;
					}
					else {
						apb->int_out[0] = 0;
					};
				};
				break;

			case	WF_HSLSIZE: /*0x0f*/
				apb->int_out[0] = 
					changeslider(apb->global->int_info->vid,win,1,HSLIDE,-1,apb->int_in[2]);
				break;

			case	WF_VSLSIZE: /*0x10*/
				apb->int_out[0] = 
					changeslider(apb->global->int_info->vid,win,1,VSLIDE,-1,apb->int_in[2]);
				break;

			case WF_COLOR:  /*0x12*/
				DB_printf("Wind_set WF_COLOR not implemented");
				apb->int_out[0] = 0;
				break;

			case WF_DCOLOR: /*0x13*/
				top_colour[apb->int_in[2]] = *(OBJC_COLORWORD *)&apb->int_in[3];
				untop_colour[apb->int_in[2]] = *(OBJC_COLORWORD *)&apb->int_in[4];
				apb->int_out[0] = 0;
				break;

			case WF_BEVENT: /*0x18*/
				if(apb->int_in[2] & 1) {
					win->status |= WIN_UNTOPPABLE;
				}
				else {
					win->status &= ~WIN_UNTOPPABLE;
				};
				
				apb->int_out[0] = 1;
				break;

			case WF_BOTTOM: /*0x0019*/
				apb->int_out[0] =
						bottom_window(apb->global->int_info->vid,apb->int_in[0]);
				break;

			case WF_ICONIFY: /*0x1a*/
				win->origsize = win->totsize;
				set_win_elem(win->tree,IMOVER);
				win->status |= WIN_ICONIFIED;
				calcworksize(IMOVER,&win->totsize,&win->worksize,WC_WORK);
				apb->int_out[0] = changewinsize(win,(RECT *)&apb->int_in[2],apb->global->int_info->vid,1);
				break;

			case WF_UNICONIFY: /*0x1b*/
				set_win_elem(win->tree,win->elements);
				win->status &= ~WIN_ICONIFIED;
				calcworksize(win->elements,&win->totsize,&win->worksize,WC_WORK);
				apb->int_out[0] = changewinsize(win,(RECT *)&apb->int_in[2],apb->global->int_info->vid,1);
				break;

			default:
				DB_printf("%s: Line %d: Wind_set:\r\n"
								"Unknown mode %d",__FILE__,__LINE__,apb->int_in[1]);
				apb->int_out[0] = 0;
		};
	}
	else
		apb->int_out[0] = 0;
	
	Rdwrs_operation(WENDWRITE);
}


/****************************************************************************
 * Wind_on_coord                                                            *
 *  Find window on known coordinates.                                       *
 ****************************************************************************/
WINSTRUCT *    /* Window description or NULL.                               */
Wind_on_coord( /*                                                           */
WORD x,        /* X coordinate.                                             */
WORD y)        /* Y coordinate.                                             */
/****************************************************************************/
{
  WINLIST *l = globals.win_vis;
  
  while(l) {
    if((x >= l->win->totsize.x) &&
       (x < (l->win->totsize.x + l->win->totsize.width)) &&
       (y >= l->win->totsize.y) &&
       (y < (l->win->totsize.y + l->win->totsize.height))) {
      return l->win;
    };
    
    l = l->next;
  };
  
  return NULL;
}

/*wind_find 0x006a*/
void	Wind_find(AES_PB *apb) {
	WINSTRUCT *win;
	
	Rdwrs_operation(WSTARTREAD);
	win = Wind_on_coord(apb->int_in[0],apb->int_in[1]);
	
	if(win) {
		apb->int_out[0] = win->id;
	}
	else {
		apb->int_out[0] = 0;
	};
	
	Rdwrs_operation(WENDREAD);
}

/****************************************************************************
 * Wind_beg_update                                                          *
 *  Begin to update screen.                                                 *
 ****************************************************************************/
WORD                   /* 1 if ok or 0.                                     */
Wind_beg_update(void)  /*                                                   */
/****************************************************************************/
{
	return Rdwrs_get_sem(&update);
}

/****************************************************************************
 * Wind_end_update                                                          *
 *  End update of screen.                                                   *
 ****************************************************************************/
WORD                   /* 1 if ok or 0.                                     */
Wind_end_update(void)  /*                                                   */
/****************************************************************************/
{
	return Rdwrs_rel_sem(&update);
}

/*wind_update 0x006b*/
void	Wind_update(AES_PB *apb) {
	switch(apb->int_in[0]) {
	case	BEG_UPDATE + 0x100: /* check & set */
		if((update.count > 0) && (apb->global->apid != update.apid)) {
			apb->int_out[0] = 0;
			break;
		}

	case	BEG_UPDATE:
		apb->int_out[0] = Wind_beg_update();
		break;

	case	END_UPDATE:
		apb->int_out[0] = Wind_end_update();
		break;

/*	
	case	BEG_MCTRL + 0x100:
		apb->int_out[0] = Evhd_gain_mctrl(apb->global->apid);
		break;
*/

	case BEG_MCTRL:
		apb->int_out[0] = Evhd_gain_mctrl(apb->global->apid,FALSE);
		break;

	case END_MCTRL:
		apb->int_out[0] = Evhd_release_mctrl();
		break;

	default:
		DB_printf("%s: Line %d: Wind_update:\r\n"
		       "Unknown mode %d",__FILE__,__LINE__,apb->int_in[1]);
		apb->int_out[0] = 0;
	}
}



/*wind_calc 0x006c*/
void	Wind_calc(AES_PB *apb) {
	calcworksize(apb->int_in[1],(RECT *)&apb->int_in[2]
		,(RECT *)&apb->int_out[1],apb->int_in[0]);
	
	apb->int_out[0] = 1;
}

/****************************************************************************
 * Wind_do_new                                                              *
 *  Implementation of wind_new().                                           *
 ****************************************************************************/
WORD           /* 0 if error or 1 if ok.                                    */
Wind_do_new(   /*                                                           */
WORD vid,      /* VDI workstation id.                                       */
WORD apid)     /* Application whose windows should be erased.               */
/****************************************************************************/
{
	WINLIST *wl;
	
	Rdwrs_operation(WSTARTWRITE);
	
	wl = globals.win_vis;

	while(wl) {
		if((wl->win->owner == apid) && !(wl->win->status & WIN_DESKTOP)) {
			Wind_do_delete(vid,wl->win->id);
			
			wl = globals.win_vis;
		}
		else {
			wl = wl->next;
		};
	};
	
	wl = win_list;
	
	while(wl) {
		if(wl->win->owner == apid) {
			Wind_do_delete(vid,wl->win->id);
			
			wl = win_list;
		}
		else {	
			wl = wl->next;
		};
	};

	Rdwrs_operation(WENDWRITE);
	
	return 1;
}

/****************************************************************************
 * Wind_new                                                                 *
 *  0x006d wind_new().                                                      *
 ****************************************************************************/
void              /*                                                        */
Wind_new(         /*                                                        */
AES_PB *apb)      /* AES parameter block.                                   */
/****************************************************************************/
{
	apb->int_out[0] = Wind_do_new(apb->global->int_info->vid,apb->global->apid);
}