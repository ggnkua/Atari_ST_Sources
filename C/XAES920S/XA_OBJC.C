/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <stdlib.h>
#include <osbind.h>
#include <string.h>
#include "ctype.h"			/* We use the version without macros!! */
#ifdef LATTICE
#undef abs		/* MiNTlib (PL46) #define is buggy! */
#define abs(i)	__builtin_abs(i)
#endif

#include "xa_types.h"
#include "xa_globl.h"

#include "rectlist.h"
#include "objects.h"
#include "menuwidg.h"

/*
 *	OBJECT TREE ROUTINES
 *	- New version of the object display routine modularises the whole system.
 */

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
},

/* OB_STATES OB_FLAGS */
*pstates[] = {"SEL","CROSS","\10","DIS","OUTL","SHA","WBAK","D3D",
             "8","9","10","11","12","13","14","15"},
*pflags[]  = {"S","DEF","EXIT","ED","RBUT","LAST","TOUCH","HID",
             ">>","INDCT","BACKGR","SUBM","12","13","14","15"}
;

static
char other[80],nother[160];

global
char *object_type(OBJECT *tree, short t)
{
	unsigned short ty = tree[t].ob_type,tx;
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
char *object_txt(OBJECT *tree, short t)			/* HR: I want to know the culprit in a glance */
{
	short ty = tree[t].ob_type;
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
void show_bits(unsigned short bits, char *prf, char *t[], char *x)
{
	short i=0;
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

static
ObjectDisplay *objc_jump_table[G_MAX];

/*
 * HR change ob_spec
 */
global
void set_ob_spec(OBJECT *root, short s_ob, unsigned long cl)
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

#if 1

/* HR: I wonder which one is faster;
		This one is smaller. and easier to follow. */
global
void g2d_box(short b, RECT *r, short colour)
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
void draw_2d_box(short x, short y, short w, short h, short border_thick, short colour)
{
	RECT r;
	r.x = x, r.y = y, r.w = w, r.h = h;
	g2d_box(border_thick, &r, colour);
}

#else
#include "obsolete/d2d_box.h"
#endif

/*
 * Initialise the object display jump table
 */
global
void init_objects(void)
{
	short f;

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
#if UNCLEAN
#include "obsolete/disp_obj.h"
#else
global
void display_object(LOCK lock, XA_TREE *wt, short item, short parent_x, short parent_y, bool is_menu)
{
	RECT r;
	OBJECT *ob = wt->tree + item;
	ObjectDisplay *display_routine = nil;		/* HR */

	/* HR: state_mask is for G_PROGDEF originally.
	   But it means that other objects must unflag what they
	   can do themselves in the same manner.
	   The best thing (no confusion) is to generalize the concept.
	   Which I did. :-) */

	short state_mask = (SELECTED|CROSSED|CHECKED|DISABLED|OUTLINED);
	short t = ob->ob_type & 0xff;
/*
	if (wt->clip.w <= 0 or wt->clip.h <= 0)
		wt->clip = screen.r;		/* set_clip */
*/
	r.x = parent_x + ob->r.x;
	r.y = parent_y + ob->r.y;
	r.w = ob->r.w; 
	r.h = ob->r.h;

	if (   r.x       > C.global_clip[2]
		or r.x+r.w-1 < C.global_clip[0]
		or r.y       > C.global_clip[3]
		or r.y+r.h-1 < C.global_clip[1]
		)
		return;

	if (t < G_MAX)						/* HR */
		display_routine = objc_jump_table[t];	/* Get display routine for this type of object from jump table */

	if (display_routine == nil)			/* If we don't have a display routine for a given object type, draw a box instead */
#if 0
		display_routine = objc_jump_table[G_IBOX];
#else
	{
		short i;
		DIAG((D.objc,wt->pid,"ob_type: %d(0x%x)\n", t, ob->ob_type));
/*		for (i=0; i<G_MAX; i++)
			DIAG((D.objc,wt->pid,"%08lx\n",objc_jump_table[i]));
*/		return;				/* HR: dont attempt doing what could be indeterminate!!! */
	}
#endif

	wt->item = item;			/* Fill in the object display parameter structure */			
	wt->parent_x = parent_x;
	wt->parent_y = parent_y;
	wt->r = r;				/* HR: absolute RECT, ready for use everywhere. */
	wt->state_mask = &state_mask;
	wt->is_menu = is_menu;		/* HR 241100 */

	wr_mode(MD_TRANS);		/* Better do this before AND after (fail safe) */

#if GENERATE_DIAGS
{
	OBJECT *get_widgets(void);
	if (wt->tree != get_widgets())
	{
		char flagstr[128],statestr[128];
		show_bits(ob->ob_flags, "flg=", pflags, flagstr);
		show_bits(ob->ob_state, "st=", pstates, statestr);
		DIAG((D.o,wt->pid,"ob=%d, %d/%d,%d/%d; %s%s %s %s\n",
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
	{
		static short pattern[16] =
		{
			0x5555, 0xaaaa, 0x5555, 0xaaaa,
			0x5555, 0xaaaa, 0x5555, 0xaaaa,
			0x5555, 0xaaaa, 0x5555, 0xaaaa,
			0x5555, 0xaaaa, 0x5555, 0xaaaa
		};

		f_color(WHITE);
		vsf_udpat(C.vh, pattern, 1);
		f_interior(FIS_USER);
		gbar(0, &r);
	}

	/* Handle CROSSED object state: */
	if ((ob->ob_state & state_mask) & CROSSED)	/* HR */
	{
		short coords[10];
		l_color(BLACK);
		coords[0] = r.x;
		coords[1] = r.y;
		coords[2] = r.x + r.w - 1;
		coords[3] = r.y + r.h - 1;
		v_pline(C.vh, 2, coords);
		coords[0] = r.x + r.w - 1;
		coords[2] = r.x;
		v_pline(C.vh, 2, coords);
	}

	/* Handle OUTLINED object state: */
	if ((ob->ob_state & state_mask) & OUTLINED)	/* HR */
	{
		/* special handling of root object. */
		if (!MONO and d3_any(ob) and item == 0)
		{
			if (wt->zen)
			{
				l_color(screen.dial_colours.bg_col);
				gbox(1, &r);
				gbox(2, &r);
				gbox(3, &r);
			othw
				tl_hook(1, &r, screen.dial_colours.lit_col);
				br_hook(1, &r, screen.dial_colours.shadow_col);
				tl_hook(2, &r, screen.dial_colours.lit_col);
				br_hook(2, &r, screen.dial_colours.shadow_col);
				gbox(3, &r);
			}
		othw
			l_color(WHITE);
			gbox(1, &r);
			gbox(2, &r);
			l_color(wt->zen != 0 and item == 0 ? WHITE : BLACK);
			gbox(3, &r);
		}
	}

	if ((ob->ob_state & state_mask) & SELECTED)
		write_selection(&r);

	wr_mode(MD_TRANS);
}
#endif

global
bool is_menu(OBJECT *tree)
{
	bool m = false;
	short title = tree[0].ob_head;
	if (title > 0)
		title = tree[title].ob_head;
	if (title > 0)
		title = tree[title].ob_head;
	if (title > 0)
		m = (tree[title].ob_type&0xff) == G_TITLE;
	return m;
}

/*
 * Walk an object tree, calling display for each object
 * HR: is_menu is true if a menu.
 */

static
XA_TREE nil_tree = {0};

global
short draw_object_tree(LOCK lock, XA_TREE *wt, OBJECT *tree, short item, short depth, bool is_menu, short which)
{
	XA_TREE this;
	short next;
	short current = 0, rel_depth = 1, head;
	short x = 0, y = 0, start_drawing = false;

	IFDIAG(short *cl = C.global_clip;)

	if (wt == nil)
	{
		this = nil_tree;
		wt = &this;
		wt->edit_obj = -1;
	}

	if (tree == nil and wt->tree != nil)		/* HR 190701 */
		tree = wt->tree;

	wt->tree = tree;

	DIAG((D.objc,wt->pid,"[%d]draw_object_tree for %d; %lx + %d depth:%d\n", which, wt->pid, tree, item, depth));
	DIAG((D.objc,wt->pid,"  -   %s%s\n", is_menu ? "menu" : "object", wt->zen ? " with zen" : ""));
	DIAG((D.objc,wt->pid,"  -   clip: %d.%d/%d.%d    %d/%d,%d/%d\n",
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
		{
			if ((tree[current].ob_flags & HIDETREE) == 0)
				display_object(lock, wt, current, x, y, is_menu);	/* Display this object */
		}

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
 * Get the true screen coords of an object
 */
global
short object_offset(OBJECT *tree, short object, short *mx, short *my)
{
	short next;
	short current = 0;
	short x = 0, y = 0;
	
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
short find_object(OBJECT *tree, short object, short depth, short mx, short my)
{
	short next;
	short current = 0, rel_depth = 1;
	short x = 0, y = 0, start_checking = false;
	short pos_object = -1;

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
bool check_widget_tree(XA_CLIENT *client, OBJECT *tree)
{
	XA_TREE *wt = &client->wt;
	DIAG((D.form,client->pid,"check_widget_tree for %d: cl:%ld, ed:%d, tree:%ld, %d/%d\n",
				client->pid, wt->tree, wt->edit_obj, tree, tree->r.x, tree->r.y));

	if (client->zen)			/* HR 220401: x & y governed by zen */
	{
		DIAG((D.form,client->pid,"check_widget_tree: zen: %d/%d, wt: %d/%d\n",
					client->zen->wa.x, client->zen->wa.y,
					wt->tree ? wt->tree->r.x : -1, wt->tree ? wt->tree->r.y : -1));
		tree->r = client->zen->wa;
		if (tree->ob_state&OUTLINED)
			adjust_size(-3, &tree->r);
	}
	else if (tree != wt->tree)
	{
		memset(wt, 0, sizeof(XA_TREE));
		wt->edit_obj = -1;
		wt->tree = tree;
		wt->pid = client->pid;
		return true;			/* changed! */
	}

	return false;
}

/*
 *	Object Tree Handling Interface
 */
AES_function XA_objc_draw		/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	RECT *r = (RECT *)&pb->intin[2];
	OBJECT *tree = pb->addrin[0];

	CONTROL(6,1,1)

	check_widget_tree(client, tree);		/* HR 200201 */
	client->wt.zen = client->zen != nil;	/* HR 300301 */

	DIAG((D.objc,client->pid,"objc_draw rectangle: %d/%d,%d/%d\n", r->x, r->y, r->w, r->h));
	hidem();

	set_clip(r);		/* HR 110601: checks for special case? w <= 0 or h <= 0 */

	pb->intout[0] = draw_object_tree(	lock,
										&client->wt,
										tree,
										pb->intin[0],		/* item */
										pb->intin[1],		/* depth */
										is_menu(tree),
										0
									);
	clear_clip();
	showm();
	
	return XAC_DONE;
}

AES_function XA_objc_offset	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	OBJECT *tree = pb->addrin[0];

	CONTROL(1,3,1)

	pb->intout[0] = object_offset(	tree, 
									pb->intin[0],
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
								pb->intin[3]);

DIAG((D.o,-1,"XA: find_object %lx + %d, %d/%d --> %d\n",
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
short thickness(OBJECT *ob)
{
	short t = 0, flags;
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
int max(short a, short b)
{
	return a > b ? a : b;
}

global
int min(short a, short b)
{
	return a < b ? a : b;
}

global
void object_area(RECT *c,OBJECT *ob, short i)
{
	OBJECT *b = ob + i;
	short dx = 0, dy = 0, dw = 0, dh = 0, db = 0,
	      thick = thickness(b);   /* type dependent */

	object_offset(ob, i, &c->x, &c->y);
	c->w = b->r.w;
	c->h = b->r.h;

	if (thick <= 0)			/* HR 0080801: oef oef oef, thickness 0 has the 3d enlargement!! */
	{
		db = thick;
		if (d3_foreground(b))
			db -= 2;
	}

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

bool check_tree(XA_CLIENT *client, OBJECT *tree, short item);

/* A quick hack to catch *most* of the problems with transparent objects */
bool transparent(OBJECT *root, short i)
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
void change_object(LOCK lock, XA_TREE *wt, OBJECT *root, short i, RECT *r, short state,
                        bool draw, bool is_menu)
{
	short start  = i;

	root[start].ob_state = state;

	if (draw)
	{
		RECT c; short q;

		while (transparent(root, start))
			if ((q = get_parent(root,start)) < 0)
				break;
			else
				start = q;

		hidem();
		object_area(&c,root,i);
		if (   !r
			or (r and rc_intersect(r,&c))
			)
		{
			set_clip(&c);
			draw_object_tree(lock, wt, root, start, MAX_DEPTH, is_menu, 1);
			clear_clip();
		}
		showm();
	}
}

global
void redraw_object(LOCK lock, XA_TREE *wt, short item)
{
	hidem();
	draw_object_tree(lock, wt, nil, item, MAX_DEPTH, is_menu(wt->tree), 2);
	showm();
}

AES_function XA_objc_change	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	OBJECT *tree = pb->addrin[0];

	CONTROL(8,1,1)

	check_widget_tree(client, tree);		/* HR 200201 */
	change_object(	lock,
					&client->wt,
					tree,
					pb->intin[0],
					(RECT *)&pb->intin[2],
					pb->intin[6],
					pb->intin[7],
					is_menu(tree) );	
	pb->intout[0] = 1;
	
	return XAC_DONE;
}

/* HR 020604: child must be inserted at the END of the list of children!!! */

AES_function XA_objc_add	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	OBJECT *root = (OBJECT *)pb->addrin[0];
	short parent, new_child, last_child;
	
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
short remove_object(OBJECT *root, short object)
{
	short parent, current, last;

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
	short parent, object, current;
	unsigned short pos;		/* -1 (top) is a large positive number */
	
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

#if 1
global
bool ed_char(XA_TREE *wt, TEDINFO *ed_txt, short keycode)
{
	char *txt = ed_txt->te_ptext;
	short cursor_pos = wt->edit_pos,
		  o, x, key, tmask, n, chg;
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
#else
#include "obsolete/ed_char.h"
#endif

/* HR: Only the '\0' in the te_ptext field is determining the corsor position, NOTHING ELSE!!!!
		te_tmplen is a constant and strictly owned by the APP.
*/

AES_function XA_objc_edit		/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	XA_TREE *wt = &client->wt;
	OBJECT *form = pb->addrin[0];
	short ed_obj = pb->intin[0];
	short keycode = pb->intin[1];
	TEDINFO *ted;
	short  last = 0, old = -1;
	bool update = false;
	RECT r;

	CONTROL(4,2,1)

	DIAG((D.form,client->pid,"objc_edit: %lx, obj:%d, k:%x, m:%d\n", form, ed_obj, keycode, pb->intin[3]));
	pb->intout[0] = 0;

	do
		if (last == ed_obj and (form[last].ob_flags & EDITABLE) == 0)		/* HR: 101200 */
			return XAC_DONE; 
	while( ! (form[last++].ob_flags & LASTOB));	/* HR: Check LASTOB before incrementing Could this be the cause ??? of the crash? */

	if (ed_obj >= last)				/* HR 101200 */
		return XAC_DONE;

	if (!check_widget_tree(client, form))		/* HR 200201 */
		if (wt->edit_obj != ed_obj)
			update = true, old = wt->edit_obj;
	
	ted = get_ob_spec(&form[ed_obj])->tedinfo;

	pb->intout[0] = 1;

	switch(pb->intin[3])
	{
	case 1:			/* ED_INIT - set current edit field */
		wt->edit_obj = ed_obj;
		if (*(ted->te_ptext) eq '@')			/* HR: 101200 */
			*(ted->te_ptext) = 0;
		wt->edit_pos = strlen(ted->te_ptext);	/* HR: 070101 */
		update = true;
		break;

	case 2:			/* ED_CHAR - process a character */
		wt->edit_obj = ed_obj;		
		update = update or ed_char(wt, ted, keycode);
		pb->intout[1] = wt->edit_pos;
		break;
			
	case 3:		/* ED_END - turn off the cursor */
		update = true;
		break;
	default:
		return XAC_DONE;
	}

	if (update)
	{
		if (old != -1)
			redraw_object(lock, wt, old);
		redraw_object(lock, wt, ed_obj);
		pb->intout[1] = wt->edit_pos;
	}

	return XAC_DONE;
}

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
DIAG((D.appl,-1,"objc_sysvar %s: %d for %s(%d)\n", pb->intin[0] == SV_INQUIRE ? "inq" : "set", pb->intin[1], client->name, client->pid));

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
