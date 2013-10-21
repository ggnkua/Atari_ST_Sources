/*
 * XaAES - XaAES Ain't the AES (c) 1992 - 1998 C.Graham
 *                                 1999 - 2003 H.Robbers
 *
 * A multitasking AES replacement for MiNT
 *
 * This file is part of XaAES.
 *
 * XaAES is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * XaAES is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with XaAES; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include <osbind.h>
#include <string.h>
#include <ctype.h>			/* We use the version without macros!! */
#ifdef LATTICE
#undef abs		/* MiNTlib (PL46) #define is buggy! */
#define abs(i)	__builtin_abs(i)
#endif

#include "xa_types.h"
#include "xa_globl.h"

#include "rectlist.h"
#include "objects.h"
#include "menuwidg.h"
#include "widgets.h"
#include "xa_form.h"

/*
 *	OBJECT TREE ROUTINES
 *	- New version of the object display routine modularises the whole system.
 */


/*
 * HR change ob_spec
 */
global
void set_ob_spec(OBJECT *root, int s_ob, unsigned long cl)
{
	if (root[s_ob].ob_flags & INDIRECT)
		root[s_ob].ob_spec.indirect->lspec = cl;
	else
		root[s_ob].ob_spec.lspec = cl;
}

/*
 * Set clipping to entire screen
 */
global
void clear_clip(void)
{
	rtopxy(C.global_clip,&screen.r);
	vs_clip(C.vh, 1, C.global_clip);
}

global
void set_clip(const RECT *r)
{
	if (r->w <= 0 or r->h <= 0)
		rtopxy(C.global_clip,&screen.r);
	else	
		rtopxy(C.global_clip,r);
	vs_clip(C.vh, 1, C.global_clip);
}

/* HR: I wonder which one is faster;
		This one is smaller. and easier to follow. */
global
void g2d_box(int b, RECT *r, int colour)
{
	if (b > 0)			/* inside runs from 3 to 0 */
	{
		if (b >  4) b =  3;
		else        b--;
		l_color(colour);
		while (b >= 0)
			gbox(-b, r), b--;
	}
	elif (b < 0)		/* outside runs from 4 to 1 */
	{
		if (b < -4) b = -4;
		l_color(colour);
		while (b < 0)
			gbox(-b, r), b++;
	}
}

/* sheduled for redundancy */
global
void draw_2d_box(G_i x, G_i y, G_i w, G_i h, int border_thick, int colour)
{
	RECT r;
	r.x = x, r.y = y, r.w = w, r.h = h;
	g2d_box(border_thick, &r, colour);
}

global
void write_disable(RECT *r, int colour)
{
	static G_i pattern[16] =
	{
		0x5555, 0xaaaa, 0x5555, 0xaaaa,
		0x5555, 0xaaaa, 0x5555, 0xaaaa,
		0x5555, 0xaaaa, 0x5555, 0xaaaa,
		0x5555, 0xaaaa, 0x5555, 0xaaaa
	};

	wr_mode(MD_TRANS);
	f_color(colour);
	vsf_udpat(C.vh, pattern, 1);
	f_interior(FIS_USER);
	gbar(0, r);
}

global
bool is_menu(OBJECT *tree)
{
	bool m = false;
	int title = tree[0].ob_head;
	if (title > 0)
		title = tree[title].ob_head;
	if (title > 0)
		title = tree[title].ob_head;
	if (title > 0)
		m = (tree[title].ob_type&0xff) == G_TITLE;
	return m;
}

#if GENERATE_DIAGS

static
char
*ob_types[] =
{
	"box",
	"text",
	"boxtext",
	"image",
	"progdef",
	"ibox",
	"button",
	"boxchar",
	"string",
	"ftext",
	"fboxtext",
	"icon",
	"title",
	"cicon",
	"xaaes slist",
	"popup",
	"resv",
	"edit",
	"shortcut",
	"39",
	"40"
};

/* OB_STATES OB_FLAGS */
global
char
*pstates[] = {"SEL","CROSS","\10","DIS","OUTL","SHA","WBAK","D3D",
             "8","9","10","11","12","13","14","15"},
*pflags[]  = {"S","DEF","EXIT","ED","RBUT","LAST","TOUCH","HID",
             ">>","INDCT","BACKGR","SUBM","12","13","14","15"}
;

static
char other[80],nother[160];

global
char *object_type(OBJECT *tree, int t)
{
	unsigned int ty = tree[t].ob_type,tx;
	if (ty >= G_BOX and ty < G_MAX)
		return ob_types[ty-G_BOX];
	tx = ty&0xff;
	if (tx >= G_BOX and tx < G_MAX)
		sdisplay(other,"ext: 0x%x + %s",ty>>8,ob_types[tx-G_BOX]);
	else
		sdisplay(other,"unknown: 0x%x,%d",ty,ty);
	return other;
}

global
char *object_txt(OBJECT *tree, int t)			/* HR: I want to know the culprit in a glance */
{
	int ty = tree[t].ob_type;
	*nother = 0;
	switch (ty&0xff)
	{
		case G_FTEXT:
		case G_TEXT:
		case G_BOXTEXT:
		case G_FBOXTEXT:
		{
			TEDINFO *ted = get_ob_spec(tree + t)->tedinfo;
			sdisplay(nother," '%s'",ted->te_ptext);
			break;
		}
		case G_BUTTON:
		case G_TITLE:
		case G_STRING:
		case G_SHORTCUT:
			sdisplay(nother," '%s'",get_ob_spec(tree + t)->string);
	}	
	return nother;
}

global
void show_bits(G_u bits, char *prf, char *t[], char *x)
{
	int i=0;
	*x=0;
	if (bits)
	{
		strcpy(x,prf);
		while(bits)
		{
			if (bits&1)
				strcat(x,t[i]), strcat(x,"|");
			bits>>=1;
			i++;
		}
		i = strlen(x)-1;
		if (x[i] == '|')
			x[i] = ',';
	}
}

#endif

/*
 * Walk an object tree, calling display for each object
 * HR: is_menu is true if a menu.
 */

global
XA_TREE nil_tree = {0};

/*
 * Initialise the object display jump table
 */

static
ObjectDisplay *objc_jump_table[G_MAX];

global
void init_objects(void)
{
	int f;

	for (f = 0; f < G_MAX; f++)
		objc_jump_table[f] = nil;			/* Anything with a nil pointer won't get called */
	
	objc_jump_table[G_BOX     ] = d_g_box;
	objc_jump_table[G_TEXT    ] = d_g_text;
	objc_jump_table[G_BOXTEXT ] = d_g_boxtext;
	objc_jump_table[G_IMAGE   ] = d_g_image;
	objc_jump_table[G_PROGDEF ] = d_g_progdef;
	objc_jump_table[G_IBOX    ] = d_g_ibox;
	objc_jump_table[G_BUTTON  ] = d_g_button;
	objc_jump_table[G_BOXCHAR ] = d_g_boxchar;
	objc_jump_table[G_STRING  ] = d_g_string;
	objc_jump_table[G_FTEXT   ] = d_g_ftext;
	objc_jump_table[G_FBOXTEXT] = d_g_fboxtext;
	objc_jump_table[G_ICON    ] = d_g_icon;
	objc_jump_table[G_TITLE   ] = d_g_title;
	objc_jump_table[G_CICON   ] = d_g_cicon;
	objc_jump_table[G_SLIST   ] = d_g_slist;
	objc_jump_table[G_SHORTCUT] = d_g_string;		/* HR */
}

/*
 * Display a primitive object
 */

global
void display_object(LOCK lock, XA_TREE *wt, int item, G_i parent_x, G_i parent_y, int which)
{
	RECT r;
	OBJECT *ob = wt->tree + item;
	ObjectDisplay *display_routine = nil;		/* HR */

	/* HR: state_mask is for G_PROGDEF originally.
	   But it means that other objects must unflag what they
	   can do themselves in the same manner.
	   The best thing (no confusion) is to generalize the concept.
	   Which I did. :-) */

	G_u state_mask = (SELECTED|CROSSED|CHECKED|DISABLED|OUTLINED);
	int t = ob->ob_type & 0xff;

	r.x = parent_x + ob->r.x;
	r.y = parent_y + ob->r.y;
	r.w = ob->r.w; 
	r.h = ob->r.h;

	if (   r.x       > C.global_clip[2]		/* x+w */
		or r.x+r.w-1 < C.global_clip[0]		/* x   */
		or r.y       > C.global_clip[3]		/* y+h */
		or r.y+r.h-1 < C.global_clip[1]		/* y   */
		)
		return;

	if (t < G_MAX)						/* HR */
		display_routine = objc_jump_table[t];	/* Get display routine for this type of object from jump table */

	if (display_routine == nil)			/* If we don't have a display routine for a given object type, draw a box instead */
#if 0
		display_routine = objc_jump_table[G_IBOX];
#else
	{
/*		int i;
*/		DIAG((D_objc,wt->owner,"ob_type: %d(0x%x)\n", t, ob->ob_type));
/*		for (i=0; i<G_MAX; i++)
			DIAG((D_objc,wt->owner,"%08lx\n",objc_jump_table[i]));
*/		return;				/* HR: dont attempt doing what could be indeterminate!!! */
	}
#endif

	wt->current = item;			/* Fill in the object display parameter structure */			
	wt->parent_x = parent_x;
	wt->parent_y = parent_y;
	wt->r = r;				/* HR: absolute RECT, ready for use everywhere. */
	wt->state_mask = &state_mask;

	wr_mode(MD_TRANS);		/* Better do this before AND after (fail safe) */

#if GENERATE_DIAGS
{
	OBJECT *get_widgets(void);
	if (wt->tree != get_widgets())
	{
		char flagstr[128],statestr[128];
		show_bits(ob->ob_flags, "flg=", pflags, flagstr);
		show_bits(ob->ob_state, "st=", pstates, statestr);
		DIAG((D_o,wt->owner,"ob=%d, %d/%d,%d/%d; %s%s %s %s\n",
			 item,
			 r.x, r.y, r.w, r.h,
			 object_type(wt->tree,item),
			 object_txt(wt->tree,item),
			 flagstr,
			 statestr));
	}
}
#endif

	(*display_routine)(lock, wt);			/* Call the appropriate display routine */

	wr_mode(MD_TRANS);

	/* Handle CHECKED object state: */
	if ((ob->ob_state & state_mask) & CHECKED)		/* HR */
	{
		t_color(BLACK);
		v_gtext(C.vh, r.x + 2, r.y, "\10");	/* ASCII 8 = checkmark */
	}

	/* Handle DISABLED state: */
	/* (May not look too hot in colour mode, but it's better than
		no disabling at all...) */
	
	if ((ob->ob_state & state_mask) & DISABLED)
		write_disable(&r, WHITE);	/* HR 090202 */

	/* Handle CROSSED object state: */
	if ((ob->ob_state & state_mask) & CROSSED)	/* HR */
	{
		G_i p[4];
		l_color(BLACK);
		p[0] = r.x;
		p[1] = r.y;
		p[2] = r.x + r.w - 1;
		p[3] = r.y + r.h - 1;
		v_pline(C.vh, 2, p);
		p[0] = r.x + r.w - 1;
		p[2] = r.x;
		v_pline(C.vh, 2, p);
	}

	/* Handle OUTLINED object state: */
	if ((ob->ob_state & state_mask) & OUTLINED)	/* HR */
	{
		/* special handling of root object. */
		if (!wt->zen or item != 0)
		{
			if (!MONO and d3_any(ob))
			{
				tl_hook(1, &r, screen.dial_colours.lit_col);
				br_hook(1, &r, screen.dial_colours.shadow_col);
				tl_hook(2, &r, screen.dial_colours.lit_col);
				br_hook(2, &r, screen.dial_colours.shadow_col);
				gbox(3, &r);
			othw
				l_color(WHITE);
				gbox(1, &r);
				gbox(2, &r);
				l_color(BLACK);
				gbox(3, &r);
			}
		}
	}

	if ((ob->ob_state & state_mask) & SELECTED)
		write_selection(0, &r);

	wr_mode(MD_TRANS);
}

global
int draw_object_tree(LOCK lock, XA_TREE *wt, OBJECT *tree, int item, int depth, int which)
{
	XA_TREE this;
	int next;
	int current = 0, rel_depth = 1, head;
	G_i x, y;
	bool start_drawing = false;

	IFDIAG(G_i *cl = C.global_clip;)

	if (wt == nil)
	{
		this = nil_tree;
		wt = &this;
		wt->edit_obj = -1;
		wt->owner = C.Aes;
	}

	if (tree == nil and wt->tree != nil)		/* HR 190701 */
		tree = wt->tree;

	wt->tree = tree;
	if (!wt->owner)					/* HR 191101 */
		wt->owner = C.Aes;

	x = -wt->dx;					/* HR 111101: dx,dy are provided by sliders if present. */
	y = -wt->dy;
	DIAG((D_objc,wt->owner,"dx = %d, dy = %d\n", x, y));
	DIAG((D_objc,wt->owner,"[%d]draw_object_tree for %s to %d/%d,%d/%d; %lx + %d depth:%d\n",
					which, t_owner(wt), x + tree->r.x, y + tree->r.y,
					tree->r.w, tree->r.h, tree, item, depth));
	DIAG((D_objc,wt->owner,"  -   (%d)%s%s\n", wt->is_menu, is_menu(tree) ? "menu" : "object", wt->zen ? " with zen" : ""));
	DIAG((D_objc,wt->owner,"  -   clip: %d.%d/%d.%d    %d/%d,%d/%d\n",
			cl[0], cl[1], cl[2], cl[3], cl[0], cl[1], cl[2] - cl[0] + 1, cl[3] - cl[1] + 1));

	depth++;
	
	do
	{
		if (current == item)
		{
			start_drawing = true;
			rel_depth = 0;
		}

		if (start_drawing != 0)
			if ((tree[current].ob_flags & HIDETREE) == 0)
				display_object(lock, wt, current, x, y, 10);	/* Display this object */

		head = tree[current].ob_head;
										/* Any non-hidden children? */
		if (     head != -1
			and (tree[current].ob_flags & HIDETREE) == 0
			and (
				     start_drawing == 0
				 or (    start_drawing != 0
				     and rel_depth < depth
				    )
			    )
			)
		{
			x += tree[current].r.x;
			y += tree[current].r.y;
			rel_depth++;
			current = head;
		} else
		{
			next = tree[current].ob_next;		/* Try for a sibling */
	
			while(    next != -1				/* Trace back up tree if no more siblings */
				  and tree[next].ob_tail == current
				 )
			{
				current = next;
				x -= tree[current].r.x;
				y -= tree[current].r.y;
				next = tree[current].ob_next;
				rel_depth--;
			}
			current = next;
		}
	
	} while (current != -1 and !(start_drawing and rel_depth < 1));

	wr_mode(MD_TRANS);
	f_interior(FIS_SOLID);

	return true;
}

/*
 * Walk an object tree, calling display for each object
 * HR: is_menu is true if a menu.
 */

/* draw_object_tree */

/*
 * Get the true screen coords of an object
 */
global
int object_offset(OBJECT *tree, int object, G_i dx, G_i dy, G_i *mx, G_i *my)
{
	int next;
	int current = 0;
	G_i x = -dx, y = -dy;
	
	do
	{
		if (current == object)	/* Found the object in the tree? cool, return the coords */
		{
			*mx = x + tree[current].r.x;
			*my = y + tree[current].r.y;
			return 1;
		}

		if (tree[current].ob_head != -1)	/* Any children? */
		{
			x += tree[current].r.x;
			y += tree[current].r.y;
			current = tree[current].ob_head;
		} else
		{
			next = tree[current].ob_next;		/* Try for a sibling */

			while((next != -1) and (tree[next].ob_tail == current))
			{	/* Trace back up tree if no more siblings */
				current = next;
				x -= tree[current].r.x;
				y -= tree[current].r.y;
				next = tree[current].ob_next;
			}
			current = next;
		}
	} while(current != -1);		/* If 'current' is -1 then we have finished */

	return 0;	/* Bummer - didn't find the object, so return error */
}

/*
 * Find which object is at a given location
 *
 */
global
int find_object(OBJECT *tree, int object, int depth, G_i mx, G_i my, G_i dx, G_i dy)
{
	int next;
	int current = 0, rel_depth = 1;
	G_i x = -dx, y = -dy;
	bool start_checking = false;
	int pos_object = -1;

	do
	{
		if (current == object)	/* We can start considering objects at this point */
		{
			start_checking = true;
			rel_depth = 0;
		}
		
		if (start_checking)
		{
			if (    (tree[current].ob_flags&HIDETREE) == 0		/* HR */
				and tree[current].r.x + x                     <= mx
				and tree[current].r.y + y                     <= my
				and tree[current].r.x + x + tree[current].r.w >= mx
				and tree[current].r.y + y + tree[current].r.h >= my
				)
			{
				pos_object = current;	/* This is only a possible object, as it may have children on top of it. */
			}
		}

		if (   (   (!start_checking)
		        or (rel_depth < depth)
		       )
		    and (tree[current].ob_head != -1)
		    and (tree[current].ob_flags&HIDETREE) == 0			/* HR */
		   )
		{		/* Any children? */
			x += tree[current].r.x;
			y += tree[current].r.y;
			rel_depth++;
			current = tree[current].ob_head;
		} else
		{
			next = tree[current].ob_next;							/* Try for a sibling */

			while((next != -1) and (tree[next].ob_tail == current))	/* Trace back up tree if no more siblings */
			{
				current = next;
				x -= tree[current].r.x;
				y -= tree[current].r.y;
				next = tree[current].ob_next;
				rel_depth--;
			}
			current = next;
		}
		
	} while((current != -1) and (rel_depth > 0));

	return pos_object;
}

/* HR 200201 */
XA_TREE *check_widget_tree(LOCK lock, XA_CLIENT *client, OBJECT *tree)
{
	XA_WINDOW *wind = client->fmd.wind;
	XA_TREE *wt = &client->wt;
	DIAG((D_form,client,"check_widget_tree for %s: cl:%lx, ed:%d, tree:%lx, %d/%d\n",
				c_owner(client), wt->tree, wt->edit_obj, tree, tree->r.x, tree->r.y));

	if (wind)			/* HR 220401: x & y governed by fmd.wind */
	{
		XA_WIDGET *widg = get_widget(wind, XAW_TOOLBAR);
		XA_TREE *ct = widg->stuff;

		if (ct)
			wt = ct;

		wt->zen = true;
		wt->tree = tree;
		wt->owner = client;

		DIAG((D_form,client,"check_widget_tree: fmd.wind: %d/%d, wt: %d/%d\n",
					client->fmd.wind->wa.x, client->fmd.wind->wa.y,
					wt->tree ? wt->tree->r.x : -1, wt->tree ? wt->tree->r.y : -1));

		if (!ct)		
			tree->r.x = client->fmd.wind->wa.x,
			tree->r.y = client->fmd.wind->wa.y;
		/* else governed by widget.loc */

	}
	else if (tree != wt->tree)
	{
		memset(wt, 0, sizeof(XA_TREE));
		wt->edit_obj = -1;
		wt->tree = tree;
		wt->owner = client;
	}

	DIAG((D_form,client,"  --  zen: %d\n", wt->zen));
	return wt;
}

/*
 *	Object Tree Handling Interface
 */
AES_function XA_objc_draw		/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	RECT *r = (RECT *)&pb->intin[2];
	OBJECT *tree = pb->addrin[0];
	int item = pb->intin[0];
/*	XA_WINDOW *wind = client->fmd.wind;
*/
	CONTROL(6,1,1)

	DIAG((D_objc,client,"objc_draw rectangle: %d/%d,%d/%d\n", r->x, r->y, r->w, r->h));

	if (tree)
	{
/*		if (wind)
			if (!wind->dial_followed)			/* HR 091201 */
		{
			if (item != 0)
			{
				f_color(screen.dial_colours.bg_col);
				gbar(0, &client->fmd.wind->wa);
			}
			wind->dial_followed = true;
		}
*/
		hidem();
		set_clip(r);		/* HR 110601: checks for special case? w <= 0 or h <= 0 */
	
		pb->intout[0] = draw_object_tree(	lock,
											check_widget_tree(lock, client, tree),
											tree,
											item,
											pb->intin[1],		/* depth */
											0
										);
		clear_clip();
		showm();
	}
	else
		pb->intout[0] = 0;

	return XAC_DONE;
}

AES_function XA_objc_offset	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	OBJECT *tree = pb->addrin[0];

	CONTROL(1,3,1)

	pb->intout[0] = object_offset(	tree, 
									pb->intin[0],
									0,
									0,
									pb->intout + 1,
									pb->intout + 2);

	return XAC_DONE;
}

AES_function XA_objc_find		/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	CONTROL(4,1,1)

	pb->intout[0] = find_object(pb->addrin[0],
								pb->intin[0],
								pb->intin[1],
								pb->intin[2],
								pb->intin[3],
								0, 0);

DIAG((D_o,client,"XA_objc_find %lx + %d, %d/%d --> %d\n",
				pb->addrin[0], pb->intin[0], pb->intin[2], pb->intin[3], pb->intout[0]));

	return XAC_DONE;
}

/* HR 120601: objc_change:
 * We go back thru the parents of the object until we meet a opaque object.
 *    This is to ensure that transparent objects are drawn correctly.
 * Care must be taken that outside borders or shadows are included in the draw.
 * Only the objects area is redrawn, so it must be intersected with clipping rectangle.
 * New function object_area(RECT *c, tree, item)
 *
 *	Now we can use this for the standard menu's and titles!!!
 */
global
int thickness(OBJECT *ob)
{
	int t = 0, flags;
	TEDINFO *ted;
	switch(ob->ob_type&0xff)
	{
	case G_BOX:
	case G_IBOX:
	case G_BOXCHAR:
		t = get_ob_spec(ob)->this.framesize;
		if (t & 128)
			t = -(1 + (t ^ 0xff));
		break;
	case G_BUTTON:
		flags = ob->ob_flags;
		t = -1;
		if (flags&EXIT)
			t--;
		if (flags&DEFAULT)
			t--;
		break;
	case G_BOXTEXT:
	case G_FBOXTEXT:
		ted = get_ob_spec(ob)->tedinfo;
		t = (char)ted->te_thickness;
		if (t & 128)
			t = -(1 + (t ^ 0xff));
	}
	return t;
}

global
int max(int a, int b)
{
	return a > b ? a : b;
}

global
int min(int a, int b)
{
	return a < b ? a : b;
}

global
void object_rectangle(RECT *c, OBJECT *ob, int i, G_i transx, G_i transy)
{
	OBJECT *b = ob + i;

	object_offset(ob, i, transx, transy, &c->x, &c->y);
	c->w = b->r.w;
	c->h = b->r.h;
}

global
void object_area(RECT *c, OBJECT *ob, int i, G_i transx,  G_i transy)
{
	OBJECT *b = ob + i;
	G_i dx = 0, dy = 0, dw = 0, dh = 0, db = 0;
	int thick = thickness(b);   /* type dependent */

	object_rectangle(c, ob, i, transx, transy);

	if (thick < 0)
		db = thick;

/* HR 0080801: oef oef oef, if foreground any thickness has the 3d enlargement!! */
	if (d3_foreground(b)) 
		db -= 2;

	dx = db;
	dy = db;
	dw = 2*db;
	dh = 2*db;

	if (b->ob_state & OUTLINED)
	{
		dx = min(dx, -3);
		dy = min(dy, -3);
		dw = min(dw, -6);
		dh = min(dh, -6);
	}

	/*	Are we shadowing this object? (Borderless objects aren't shadowed!) */
	if (thick < 0 and b->ob_state & SHADOWED)
	{
		dw += 2*thick;
		dh += 2*thick;
	}

	c->x += dx;
	c->y += dy;
	c->w -= dw;
	c->h -= dh;
/*	DIAGS(("object_area: %s thick: %d, 3d: 0x%04x\n  --   c:%d/%d,%d/%d  d:%d/%d,%d/%d\n",
		object_type(ob,i), thick, b->ob_flags,
		c->x,c->y,c->w,c->h,dx,dy,dw,dh));
*/
}

bool check_tree(XA_CLIENT *client, OBJECT *tree, int item);

/* A quick hack to catch *most* of the problems with transparent objects */
bool transparent(OBJECT *root, int i)
{
	switch (root[i].ob_type & 0xff)
	{
	case G_STRING:
	case G_SHORTCUT:
	case G_TITLE:
	case G_IBOX:
/*	case G_TEXT:		need more evaluation, not urgent
	case G_FTEXT:
*/		return true;		/* transparent */
	}
	return false;		/* opaque */
}

global
void change_object(LOCK lock, XA_TREE *wt, OBJECT *root, int i, RECT *r, int state,
                        bool draw)
{
	int start  = i;

	root[start].ob_state = state;

	if (draw)
	{
		RECT c; int q;

		while (transparent(root, start))
			if ((q = get_parent(root,start)) < 0)
				break;
			else
				start = q;

		hidem();
		object_area(&c,root,i,wt ? wt->dx : 0, wt ? wt->dy : 0);
		if (   !r
			or (r and rc_intersect(*r,&c))
			)
		{
			set_clip(&c);
			draw_object_tree(lock, wt, root, start, MAX_DEPTH, 1);
			clear_clip();
		}
		showm();
	}
}

global
void redraw_object(LOCK lock, XA_TREE *wt, int item)
{
	hidem();
	draw_object_tree(lock, wt, nil, item, MAX_DEPTH, 2);
	showm();
}

AES_function XA_objc_change	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	OBJECT *tree = pb->addrin[0];

	CONTROL(8,1,1)

	if (tree)
	{
		change_object(	lock,
						check_widget_tree(lock, client, tree),		/* HR 200201 */
						tree,
						pb->intin[0],
						(RECT *)&pb->intin[2],
						pb->intin[6],
						pb->intin[7]);	
		pb->intout[0] = 1;
	}
	else
		pb->intout[0] = 0;

	return XAC_DONE;
}

/* HR 020604: child must be inserted at the END of the list of children!!! */

AES_function XA_objc_add	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	OBJECT *root = (OBJECT *)pb->addrin[0];
	int parent, new_child, last_child;
	
	CONTROL(2,1,1)

	parent = pb->intin[0];
	new_child = pb->intin[1];

	if (new_child == parent or new_child == -1 or parent == -1)
		pb->intout[0] = 0;
	else
	{
		last_child = root[parent].ob_tail;
		root[new_child].ob_next = parent;
		root[parent   ].ob_tail = new_child;
		if (last_child == -1)	/* No siblings */
			root[parent    ].ob_head = new_child;
		else
			root[last_child].ob_next = new_child;

		root[new_child].ob_head = -1;		/* HR 060801 */
		root[new_child].ob_tail = -1;

		pb->intout[0] = 1;
	}

	return XAC_DONE;
}

static
int remove_object(OBJECT *root, int object)
{
	int parent, current, last;

	current = object;
	do
	{						/* Find parent */
		last = current;
		current = root[current].ob_next;
	} while (root[current].ob_tail != last);
	parent = current;
	
	if (root[parent].ob_head == object)	/* First child */
	{
		if (root[object].ob_next == parent)		/* No siblings */
			root[parent].ob_head = root[parent].ob_tail = -1;
		else						/* Siblings */
			root[parent].ob_head = root[object].ob_next;
	} else								/* Not first child */
	{
		current = root[parent].ob_head;
		do
		{						/* Find adjacent sibling */
			last = current;
			current = root[current].ob_next;
		} while (current != object);
		root[last].ob_next = root[object].ob_next;
		if (root[object].ob_next == parent)
			root[parent].ob_tail = last;	/* Last child removed */
	}
	
	return parent;
}

AES_function XA_objc_delete	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	CONTROL(1,1,1)

	remove_object((OBJECT *)pb->addrin[0], pb->intin[0]);

	pb->intout[0] = 1;

	return XAC_DONE;
}

AES_function XA_objc_order	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	OBJECT *root = (OBJECT *)pb->addrin[0];
	int parent, object, current;
	G_u pos;		/* -1 (top) is a large positive number */
	
	CONTROL(2,1,1)

	object = pb->intin[0];
	parent = remove_object(root, object);

	pos = pb->intin[1];	
	current = root[parent].ob_head;
	if (current == -1)		/* No siblings */
	{
		root[parent].ob_head = root[parent].ob_tail = object;
		root[object].ob_next = parent;
	} else if (!pos)	/* First among siblings */
	{
		root[object].ob_next = current;
		root[parent].ob_head = object;
	} else				/* Search for position */
	{
		for(pos--; pos and root[current].ob_next != parent; pos--)
			current = root[current].ob_next;
		if (root[current].ob_next == parent)
			root[parent].ob_tail = object;
		root[object].ob_next = root[current].ob_next;
		root[current].ob_next = object;
	}

	pb->intout[0] = 1;

	return XAC_DONE;
}



/* Johan's versions of these didn't work on my system, so I've redefined them 
   - This is faster anyway */

static
const unsigned char character_type[] =
{
	0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0,
	CGs, 0, 0, 0, 0, 0, 0, 0,
	0, 0, CGw, 0, 0, 0, CGdt, 0,
	CGd, CGd, CGd, CGd, CGd, CGd, CGd, CGd,
	CGd, CGd, CGp, 0, 0, 0, 0, CGw,
	0, CGu|CGa, CGu|CGa, CGu|CGa, CGu|CGa, CGu|CGa, CGu|CGa, CGu|CGa,
	CGu|CGa, CGu|CGa, CGu|CGa, CGu|CGa, CGu|CGa, CGu|CGa, CGu|CGa, CGu|CGa,
	CGu|CGa, CGu|CGa, CGu|CGa, CGu|CGa, CGu|CGa, CGu|CGa, CGu|CGa, CGu|CGa,
	CGu|CGa, CGu|CGa, CGu|CGa, 0, CGp, 0, 0, CGxp,
	0, CGa, CGa, CGa, CGa, CGa, CGa, CGa,
	CGa, CGa, CGa, CGa, CGa, CGa, CGa, CGa,
	CGa, CGa, CGa, CGa, CGa, CGa, CGa, CGa,
	CGa, CGa, CGa, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
};

global
bool ed_char(XA_TREE *wt, TEDINFO *ed_txt, G_u keycode)
{
	char *txt = ed_txt->te_ptext;
	int cursor_pos = wt->edit_pos,
		  x, key, tmask, n, chg;
	bool update = false;

	switch(keycode)
	{	
	case 0x011b:		/* ESCAPE clears the field */
		txt[0] = '\0';
		cursor_pos = 0;
		update = true;
		break;

	case 0x537f:		/* DEL deletes character under cursor */
		if (txt[cursor_pos])
		{
			for(x = cursor_pos; x < ed_txt->te_txtlen - 1; x++)
				txt[x] = txt[x + 1];
			
			update = true;
		}
		break;
			
	case 0x0e08:		/* BACKSPACE deletes character left of cursor (if any) */
		if (cursor_pos)
		{
			for(x = cursor_pos; x < ed_txt->te_txtlen; x++)
				txt[x - 1] = txt[x];

			cursor_pos--;
			update = true;
		}
		break;
				
	case 0x4d00:	/* RIGHT ARROW moves cursor right */
		if ((txt[cursor_pos]) and (cursor_pos < ed_txt->te_txtlen - 1))
		{
			cursor_pos++;
			update = true;
		}
		break;

	case 0x4d36:	/* SHIFT+RIGHT ARROW move cursor to far right of current text */
		for(x = 0; txt[x]; x++)
			;

		if (x != cursor_pos)
		{
			cursor_pos = x;
			update = true;
		}
		break;
			
	case 0x4b00:	/* LEFT ARROW moves cursor left */
		if (cursor_pos)
		{
			cursor_pos--;
			update = true;
		}
		break;
			
	case 0x4b34:	/* SHIFT+LEFT ARROW move cursor to start of field */
	case 0x4700:	/* CLR/HOME also moves to far left */
		if (cursor_pos)
		{
			cursor_pos = 0;
			update = true;
		}
		break;

	default:		/* Just a plain key - insert character */
		chg = 0;		/* Ugly hack! */
		if (cursor_pos == ed_txt->te_txtlen - 1)
		{
			cursor_pos--;
			chg = 1;
		}
				
		key = keycode & 0xff;
		tmask=character_type[key];

		n = strlen(ed_txt->te_pvalid) - 1;
		if (cursor_pos < n)
			n = cursor_pos;

		switch(ed_txt->te_pvalid[n])
		{
		case '9':
			tmask &= CGd;
			break;
		case 'a':
			tmask &= CGa|CGs;
			break;
		case 'n':
			tmask &= CGa|CGd|CGs;
			break;
		case 'p':
			tmask &= CGa|CGd|CGp|CGxp;
			/*key = toupper((char)key);*/
			break;
		case 'A':
			tmask &= CGa|CGs;
			key = toupper((char)key);
			break;
		case 'N':
			tmask &= CGa|CGd|CGs;
			key = toupper((char)key);
			break;
		case 'F':
			tmask &= CGa|CGd|CGp|CGxp|CGw;
			/*key = toupper((char)key);*/
			break;
		case 'f':
			tmask &= CGa|CGd|CGp|CGxp|CGw;
			/*key = toupper((char)key);*/
			break;
		case 'P':
			tmask &= CGa|CGd|CGp|CGxp|CGw;
			/*key = toupper((char)key);*/
			break;
		case 'X':
			tmask = 1;
			break;
		case 'x':
			tmask = 1;
			key = toupper((char)key);
			break;
		default:
			tmask = 0;
			break;			
		}
		
		if (!tmask)
		{
			for(n = x = 0; ed_txt->te_ptmplt[n]; n++)
			{
		   		if (ed_txt->te_ptmplt[n] == '_')
					x++;
				else if (    ed_txt->te_ptmplt[n] == key
					     and x >= cursor_pos
					    )
					break;
			}
			if (key and (ed_txt->te_ptmplt[n] == key))
			{
				for(n = cursor_pos; n < x; n++)
					txt[n] = ' ';
				txt[x] = '\0';
				cursor_pos = x;
			} else
			{
				cursor_pos += chg;		/* Ugly hack! */
				wt->edit_pos = cursor_pos;
				return XAC_DONE;
			}
		} else
		{
			txt[ed_txt->te_txtlen - 2] = '\0';	/* Needed! */
			for(x = ed_txt->te_txtlen - 1; x > cursor_pos; x--)
				txt[x] = txt[x - 1];

			txt[cursor_pos] = (char)key;

			cursor_pos++;
		}

		update = true;
		break;
	}
	wt->edit_pos = cursor_pos;
	return update;
}

#if 1 /* WDIAL    HR: must test the reorganized objc_edit anyhow */

#if GENERATE_DIAGS
char *edfunc[] =
{
	"ED_START",
	"ED_INIT",
	"ED_CHAR",
	"ED_END",
	"*ERR*"
};
#endif

global						/* HR 271101: separate function, also used by wdlg_xxx extension. */
int edit_object(LOCK lock,
			XA_CLIENT *client,
			int func,
			XA_TREE *wt, OBJECT *form,
			int ed_obj, int keycode,
			int *newpos)
{
	TEDINFO *ted;
	OBJECT *otree = wt->tree;
	int ret, last = 0, old = -1;
	bool update = false;

#if GENERATE_DIAGS
	char *funcstr = func < 0 or func > 3 ? edfunc[4] : edfunc[func];
	DIAG((D_form,wt->owner,"  --  edit_object: %lx, obj:%d, k:%x, m:%s\n", form, ed_obj, keycode, funcstr));
#endif

	ret = 0;

	do
		if (last == ed_obj and (form[last].ob_flags & EDITABLE) == 0)		/* HR: 101200 */
			return false; 
	while( ! (form[last++].ob_flags & LASTOB));	/* HR: Check LASTOB before incrementing Could this be the cause ??? of the crash? */

	if (ed_obj >= last)				/* HR 101200 */
		return ret;

	wt = check_widget_tree(lock, client, form);		/* HR 200201 */
	if (otree != form)
	{
		wt->edit_obj = ed_obj;
		update = true;
		old = wt->edit_obj;
	}

	ted = get_ob_spec(&form[ed_obj])->tedinfo;

	ret = 1;

	switch(func)
	{
	case ED_INIT:		 /* set current edit field */
		wt->edit_obj = ed_obj;
		if (*(ted->te_ptext) eq '@')			/* HR: 101200 */
			*(ted->te_ptext) = 0;
		wt->edit_pos = strlen(ted->te_ptext);	/* HR: 070101 */
		update = true;
		break;

	case ED_CHAR:		/* process a character */
		wt->edit_obj = ed_obj;		
		update = update or ed_char(wt, ted, keycode);
		*newpos = wt->edit_pos;
		break;
			
	case ED_END:		/* turn off the cursor */
		update = true;
		break;
	default:
		return ret;
	}

	if (update)
	{
		DIAGS(("newpos %lx, wt %lx, old %d, ed_obj %d\n", newpos, wt, old, ed_obj));
		if (old != -1)
			redraw_object(lock, wt, old);
		redraw_object(lock, wt, ed_obj);
		*newpos = wt->edit_pos;
	}

	return ret;
}
/* HR: Only the '\0' in the te_ptext field is determining the corsor position, NOTHING ELSE!!!!
		te_tmplen is a constant and strictly owned by the APP.
*/

AES_function XA_objc_edit		/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{

	CONTROL(4,2,1)

	DIAG((D_form,client,"objc_edit\n"));

	if (pb->addrin[0])
		pb->intout[0] =
		edit_object(lock,
					client,
		            pb->intin[3],
		            &client->wt,
					pb->addrin[0],
					pb->intin[0],
					pb->intin[1],
					&pb->intout[1]);
	else
		pb->intout[0] = 0;

	return XAC_DONE;
}

#else			/* unchanged */
#include "obsolete/objc_edi.h"
#endif

/* HR: objc_sysvar
   I think some programs need this to be able to do extended
    objects in 3D using progdefs.
    And shure they have the right to call this when they can do
    3D objects at all.    (appl_getinfo).
    .....
    I was right: Hip hip hurray!!! Luna.app buttons now OK.
    Now many more modern programs will behave correct.
*/
 
AES_function XA_objc_sysvar	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
DIAG((D_appl,client,"objc_sysvar %s: %d for %s\n", pb->intin[0] == SV_INQUIRE ? "inq" : "set", pb->intin[1], c_owner(client)));

	CONTROL(4,3,0)

	if (pb->intin[0] == SV_INQUIRE)		/* SV_SET later: or not??? */
	{
		pb->intout[0] = 1;
		switch(pb->intin[1])
		{
		case LK3DIND:
			pb->intout[1] = 0;		/* text move (selecting) */
			pb->intout[2] = 0;		/* color change (selecting) */
			break;
		case LK3DACT:
			pb->intout[1] = 1;		/* text move (selecting) */
			pb->intout[2] = 0;		/* color change (selecting) */
			break;
		case INDBUTCOL:
			pb->intout[1] = screen.dial_colours.bg_col;
			break;
		case ACTBUTCOL:
			pb->intout[1] = screen.dial_colours.bg_col;
			break;
		case BACKGRCOL:
			pb->intout[1] = screen.dial_colours.bg_col;
			break;
		case AD3DVAL:
			pb->intout[1] = 2;  /* d3_pushbutton enlargement values :-) */
			pb->intout[2] = 2;
			break;
		default:
			pb->intout[0] = 0;
		}
	}
	else
		pb->intout[0] = 0;

	return XAC_DONE;
}
