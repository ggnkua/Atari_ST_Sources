#include "extern.h"

static OBJECT indic_on[] = {
										 	-1, 1, 1, G_IBOX, NONE, NORMAL, 0x111F0L, 0, 0, 0, 0,
                       0, 2, 2, G_IBOX, NONE, NORMAL, 0x101F1L, 1, 1, 0, 0,
                       1, -1, -1, G_BOX, LASTOB, NORMAL, 0x1C8L, 0, 0, 0, 0
												   };
															  	
static OBJECT indic_off[] ={
											-1, 1, 1, G_IBOX, NONE, NORMAL, 0x101F0L, 0, 0, 0, 0,
                       0, 2, 2, G_IBOX, NONE, NORMAL, 0x111F1L, 1, 1, 0, 0,
                       1, -1, -1, G_BOX, LASTOB, NORMAL, 0x1C8L, 0,0, 0, 0
													 };

static OBJECT down_text[] ={
											-1, 1, 1, G_IBOX, NONE, NORMAL, 0x111F0L, 0, 0, 0, 0,
											 0, 2, 2, G_IBOX, NONE, NORMAL, 0x101F1L, 1, 1, 0, 0,
											 1, -1, -1, G_FBOXTEXT, LASTOB, NORMAL, 0x0L, 0, 0, 0, 0
                           };

static OBJECT up_text[] = {
											-1, 1, 1, G_IBOX, NONE, NORMAL, 0x101F0L, 0, 0, 0, 0,
											 0, 2, 2, G_IBOX, NONE, NORMAL, 0x111F1L, 1, 1, 0, 0,
											 1, -1, -1, G_FBOXTEXT, LASTOB, NORMAL, 0x0L, 0, 0, 0, 0
                           };

static OBJECT dis_text[] = {
											-1, 1, 1, G_IBOX, NONE, NORMAL, 0x111F1L, 0, 0, 0, 0,
											 0, 2, 2, G_IBOX, NONE, NORMAL, 0x10170L, 1, 1, 0, 0,
                       1, 3, 3, G_IBOX, NONE, NORMAL, 0x11171L, 1, 1, 0, 0,
                       2, -1, -1, G_FBOXTEXT, LASTOB, NORMAL, 0x5L, 0,0, 0, 0};

static OBJECT activ_on[] = {
											-1, 1, 1, G_IBOX, NONE, NORMAL, 0x31170L, 0, 0, 0, 0,
											 0, 2, 2, G_IBOX, NONE, NORMAL, 0x30171L, 2, 2, 0, 0,
											1, -1, -1, G_FBOXTEXT, LASTOB, NORMAL, 0x4L, 0,0, 0,0
											  		};

static OBJECT activ_off[] ={
											-1, 1, 1, G_IBOX, NONE, NORMAL, 0x30170L, 0, 0, 0, 0,
											 0, 2, 2, G_IBOX, NONE, NORMAL, 0x31171L, 2, 2, 0, 0,
											 1, -1, -1, G_FBOXTEXT, LASTOB, NORMAL, 0x3L, 0,0, 0, 0,
											  		};

static OBJECT background[] = {
											-1, 1, 1, G_IBOX, NONE, NORMAL, 0x11171L, 0, 0, 0, 0,
											 0, 2, 2, G_IBOX, NONE, NORMAL, 0x10170L,  1, 1, 0, 0,
											 1, 3, 3, G_IBOX, NONE, NORMAL, 0x11171L, 1, 1, 0, 0,
											 2, -1, -1, G_BOX, LASTOB, NORMAL, 0x143L, 0,0, 0, 0
								 						 };

static OBJECT headline[] = {
											-1, 1, 1, G_IBOX, NONE, NORMAL, 0x10170L, 0, 0, 0, 0,
											 0, 2, 2, G_IBOX, NONE, NORMAL, 0x11171L, 0, 0, 0, 1,
											 1, -1, -1, G_FBOXTEXT, LASTOB, NORMAL, 0x2L, 0, 0, 0, 0
											 		 };

static x_color = 0x48, x_bkg = 0x48;

/* -----------------
   | Init RSC-File |
   | and local obj.|
   ----------------- */
void init_rsrc(void)
{
int rgb_in[3];

if (work_out[13] == 4)
	{
	rgb_in[0] = 850;
	rgb_in[1] = 850;
	rgb_in[2] = 850;
	vs_color(vdi_handle, 2, rgb_in);
	rgb_in[0] = 570;
	rgb_in[1] = 570;
	rgb_in[2] = 850;
	vs_color(vdi_handle, 3, rgb_in);

	indic_on[2].ob_spec.obspec.interiorcol = 2;
	indic_off[2].ob_spec.obspec.interiorcol = 2;
	x_color = 0x72;
	x_bkg = 0x73;
	}

if (work_out[13] > 2)
	{
	indic_on[2].ob_spec.obspec.fillpattern = 7;
	indic_off[2].ob_spec.obspec.fillpattern = 7;
	}
		
rsrc_gaddr(R_TREE, COLBKG, &w_bkg);
wind_get(0, WF_WORKXYWH, &w_bkg[0].ob_x, &w_bkg[0].ob_y, 
													 &w_bkg[0].ob_width, &w_bkg[0].ob_height);
wind_set(0, WF_NEWDESK, w_bkg, ROOT);
}

/* -----------------
   | Object output |
   ----------------- */                                  
void obj_out(OBJECT *tree, int start, int r_x, int r_y, int r_w, int r_h)
{
OBJECT *t2;
int a;

if (!(tree[start].ob_type & 0x700))
	{
	if (tree[start].ob_type == G_BOX)
		if (tree[start].ob_spec.obspec.fillpattern == 4
				&& tree[start].ob_spec.obspec.interiorcol == LBLACK)
			{
			tree[start].ob_spec.obspec.fillpattern = x_bkg >> 4;
			tree[start].ob_spec.obspec.interiorcol = x_bkg & 0xF;
			}

	if (tree[start].ob_type == G_TEXT || tree[start].ob_type == G_BOXTEXT
			|| tree[start].ob_type == G_FTEXT || tree[start].ob_type == G_FBOXTEXT)
		if ((tree[start].ob_spec.tedinfo->te_color & 0x70) == 0x40
				&& (tree[start].ob_spec.tedinfo->te_color & 0xF) == LBLACK)
			tree[start].ob_spec.tedinfo->te_color = (tree[start].ob_spec.tedinfo->te_color & ~0x7f) | x_bkg;

	objc_draw(tree, start, 0, r_x, r_y, r_w, r_h);
	}
else
	{
	switch(tree[start].ob_type & 0xFF00)
		{
		case 0x100:         /* Indicator */
			if (tree[start].ob_state & SELECTED)
				t2 = indic_on;
			else
				t2 = indic_off;
			break;

		case 0x200:         /* down text */
			t2 = down_text;

			((char *)&tree[start].ob_spec.tedinfo->te_color)[1] &= 0x80;
			((char *)&tree[start].ob_spec.tedinfo->te_color)[1] |= x_color;
			t2[2].ob_spec.tedinfo = tree[start].ob_spec.tedinfo;
			break;

		case 0x300:         /* up button */
			if (tree[start].ob_state & DISABLED)
				{
				t2 = dis_text;
	
				a = t2[3].ob_width = tree[start].ob_width;
				t2[2].ob_width = a + 1;
				t2[1].ob_width = a + 3;
				t2[0].ob_width = a + 4;
				a = t2[3].ob_height = tree[start].ob_height;
				t2[2].ob_height = a + 1;
				t2[1].ob_height = a + 3;
				t2[0].ob_height = a + 4;

				((char *)&tree[start].ob_spec.tedinfo->te_color)[1] &= 0x80;
				((char *)&tree[start].ob_spec.tedinfo->te_color)[1] |= 0x40 | (x_bkg & 0xF);
				t2[3].ob_spec.tedinfo = tree[start].ob_spec.tedinfo;

				objc_offset(tree, start, &t2[0].ob_x, &t2[0].ob_y);
				objc_draw(t2, 0, MAX_DEPTH, r_x, r_y, r_w, r_h);
				return;
        }
       else
       	{
				if (tree[start].ob_state & SELECTED)
					t2 = down_text;
				else
					t2 = up_text;
				
				((char *)&tree[start].ob_spec.tedinfo->te_color)[1] &= 0x80;
				((char *)&tree[start].ob_spec.tedinfo->te_color)[1] |= x_color;
				t2[2].ob_spec.tedinfo = tree[start].ob_spec.tedinfo;
				}
			break;

		case 0x400:         /* Activator */
			if (tree[start].ob_state & SELECTED)
				t2 = activ_on;
			else
				t2 = activ_off;

			objc_offset(tree, start, &t2[0].ob_x, &t2[0].ob_y);
			if (tree[start].ob_flags & DEFAULT)
				{
				t2[0].ob_x--;
				t2[0].ob_y--;
				t2[1].ob_x = 3;
				t2[1].ob_y = 3;
				
				a = t2[2].ob_width = tree[start].ob_width;
				t2[1].ob_width = a + 4;
				t2[0].ob_width = a + 7;
				a = t2[2].ob_height = tree[start].ob_height;
				t2[1].ob_height = a + 4;
				t2[0].ob_height = a + 7;
				}
			else
				{
				t2[1].ob_x = 2;
				t2[1].ob_y = 2;
				
				a = t2[2].ob_width = tree[start].ob_width;
				t2[1].ob_width = a + 2;
				t2[0].ob_width = a + 4;
				a = t2[2].ob_height = tree[start].ob_height;
				t2[1].ob_height = a + 2;
				t2[0].ob_height = a + 4;
				}
				
			((char *)&tree[start].ob_spec.tedinfo->te_color)[1] &= 0x80;
			((char *)&tree[start].ob_spec.tedinfo->te_color)[1] |= x_color;
			t2[2].ob_spec.tedinfo = tree[start].ob_spec.tedinfo;

			objc_draw(t2, 0, MAX_DEPTH, r_x, r_y, r_w, r_h);
			return;
		
		case 0x500:
			t2 = background;

			a = t2[3].ob_width = tree[start].ob_width;
			t2[2].ob_width = a + 1;
			t2[1].ob_width = a + 3;
			t2[0].ob_width = a + 4;
			a = t2[3].ob_height = tree[start].ob_height;
			t2[2].ob_height = a + 1;
			t2[1].ob_height = a + 3;
			t2[0].ob_height = a + 4;

			objc_offset(tree, start, &t2[0].ob_x, &t2[0].ob_y);
			objc_draw(t2, 0, MAX_DEPTH, r_x, r_y, r_w, r_h);
			return;
			
		case 0x600:
			t2 = headline;

			tree[start].ob_spec.tedinfo->te_color =	0x143;
			t2[2].ob_spec.tedinfo = tree[start].ob_spec.tedinfo;

			a = t2[2].ob_width = tree[start].ob_width;
			t2[1].ob_width = a + 1;
			t2[0].ob_width = a + 1;
			a = t2[2].ob_height = tree[start].ob_height;
			t2[1].ob_height = a;
			t2[0].ob_height = a + 1;

			objc_offset(tree, start, &t2[0].ob_x, &t2[0].ob_y);
			t2[0].ob_x += 2;
			t2[0].ob_y += 2;
			objc_draw(t2, 0, MAX_DEPTH, r_x, r_y, r_w, r_h);
			return;

		case 0xD00:         /* up button (white) */
			if (tree[start].ob_state & DISABLED)
				{
				t2 = dis_text;
	
				a = t2[3].ob_width = tree[start].ob_width;
				t2[2].ob_width = a + 1;
				t2[1].ob_width = a + 3;
				t2[0].ob_width = a + 4;
				a = t2[3].ob_height = tree[start].ob_height;
				t2[2].ob_height = a + 1;
				t2[1].ob_height = a + 3;
				t2[0].ob_height = a + 4;

				((char *)&tree[start].ob_spec.tedinfo->te_color)[1] &= 0x80;
				t2[3].ob_spec.tedinfo = tree[start].ob_spec.tedinfo;
				t2[3].ob_state |= DISABLED;

				objc_offset(tree, start, &t2[0].ob_x, &t2[0].ob_y);
				objc_draw(t2, 0, MAX_DEPTH, r_x, r_y, r_w, r_h);
				t2[3].ob_state &= ~DISABLED;
				return;
        }
       else
       	{
				if (tree[start].ob_state & SELECTED)
					t2 = down_text;
				else
					t2 = up_text;
				
				((char *)&tree[start].ob_spec.tedinfo->te_color)[1] &= 0x80;
				t2[2].ob_spec.tedinfo = tree[start].ob_spec.tedinfo;
				}
			break;
		}

	a = t2[2].ob_width = tree[start].ob_width;
	t2[1].ob_width = a + 1;
	t2[0].ob_width = a + 2;
	a = t2[2].ob_height = tree[start].ob_height;
	t2[1].ob_height = a + 1;
	t2[0].ob_height = a + 2;

	objc_offset(tree, start, &t2[0].ob_x, &t2[0].ob_y);
	objc_draw(t2, 0, MAX_DEPTH, r_x, r_y, r_w, r_h);
	}
}

/* ------------------------
   | Extended Object-Draw |
   ------------------------ */
void xobjc_draw(OBJECT *tree, int start, int level, int r_x, int r_y, int r_w, int r_h)
{
if (!(tree[start].ob_flags & HIDETREE))
	{
	obj_out(tree, start, r_x, r_y, r_w, r_h);
	if (tree[start].ob_head != -1 && level)
		xdraw_level(tree, tree[start].ob_head, level - 1, r_x, r_y, r_w, r_h);
	}
}

/* ------------------
   | draw one level |
   ------------------ */
void xdraw_level(OBJECT *tree, int start, int level, int r_x, int r_y, int r_w, int r_h)
{
int last = start;

do
	{
	if (!(tree[start].ob_flags & HIDETREE))
		{
		obj_out(tree, start, r_x, r_y, r_w, r_h);
		if (tree[start].ob_head != -1 && level)
			xdraw_level(tree, tree[start].ob_head, level - 1, r_x, r_y, r_w, r_h);
		}
		
	last = start;		
	start = tree[start].ob_next;
	if (start == -1)
		return;
	}while(tree[start].ob_tail != last);
}
