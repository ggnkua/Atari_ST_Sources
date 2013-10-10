#include "extern.h"

/* ------------------------
   | Initialize icon tree |
   ------------------------ */
void init_icons(void)
{
int i;

rsrc_gaddr(R_TREE, ICON_X, &ic_src);

for (i = 0; i < MAX_ICONS; i++)
	w_bkg[icon_no[i]].ob_flags |= HIDETREE;

new_icon(IC_T, "Papierkorb", TRASH_IC, work_out[0], work_out[1]);
}

/* ----------------
   | Set new icon |
   ---------------- */
void new_icon(int no, char *text, int ic_no, int x, int y)
{
int xx, xy, xw, xh, i;

memcpy(w_bkg[no].ob_spec.iconblk, 
			 ic_src[ic_no].ob_spec.iconblk, sizeof(ICONBLK));

w_bkg[no].ob_width = ic_src[ic_no].ob_width;
w_bkg[no].ob_height = ic_src[ic_no].ob_height;
w_bkg[no].ob_spec.iconblk->ib_ptext = text;

w_bkg[no].ob_spec.iconblk->ib_xtext = ic_src[ic_no].ob_spec.iconblk->ib_xtext;
w_bkg[no].ob_spec.iconblk->ib_ytext = ic_src[ic_no].ob_spec.iconblk->ib_ytext;
w_bkg[no].ob_spec.iconblk->ib_wtext = ic_src[ic_no].ob_spec.iconblk->ib_wtext;
w_bkg[no].ob_spec.iconblk->ib_htext = ic_src[ic_no].ob_spec.iconblk->ib_htext;

if (x == -1)
	{
	x = 0;
	y = 0;
	
	do
		{
		for (i = 0; i < MAX_ICONS; i++)
			if (!(w_bkg[icon_no[i]].ob_flags & HIDETREE))
				if (rect_intersect(x, y, 
													 w_bkg[no].ob_width, 
													 w_bkg[no].ob_height,
													 
													 w_bkg[icon_no[i]].ob_x, 
													 w_bkg[icon_no[i]].ob_y,
													 w_bkg[icon_no[i]].ob_width, 
													 w_bkg[icon_no[i]].ob_height,

													 &xx, &xy, &xw, &xh))
					break;													 
					
		if (i < MAX_ICONS)
			{
			x += w_bkg[icon_no[i]].ob_width;
			if (x + w_bkg[no].ob_width > w_bkg[ROOT].ob_width)
				{
				x = 0;
				y += w_bkg[icon_no[i]].ob_height;
				}
			}
		}while(i < MAX_ICONS);

	if (y + w_bkg[no].ob_height > w_bkg[ROOT].ob_height)	
		{
		x = 0;
		y = 0;
		}
	}

w_bkg[no].ob_flags &= ~HIDETREE;
set_iconpos(no, x, y);
force_wredraw(0);
}

/* ---------------------
   | Set icon position |
   --------------------- */
void set_iconpos(int no, int x, int y)
{
if (x + w_bkg[no].ob_width > w_bkg[0].ob_width)
	x = w_bkg[0].ob_width - w_bkg[no].ob_width;

if (y + w_bkg[no].ob_height > w_bkg[0].ob_height)
	y = w_bkg[0].ob_height - w_bkg[no].ob_height;
	
w_bkg[no].ob_x = x;
w_bkg[no].ob_y = y;
}

/* -------------------------------
   | Delete icon from background |
   ------------------------------- */
void delete_icon(int no)
{
w_bkg[no].ob_flags |= HIDETREE;
force_wredraw(0);
}

/* --------------------
   | Search free icon |
   -------------------- */
int search_freeicon(void)
{
int i;

for (i = 0; i < MAX_ICONS; i++)
	if (w_bkg[icon_no[i]].ob_flags & HIDETREE)
		return i + 1;
		
return 0;
}

/* ------------
   | Use icon |
   ------------ */
void icon_use(void)
{
int obj, i, d_obj;
int d_x, d_y;

obj = objc_find(w_bkg, ROOT, MAX_DEPTH, mx, my);
for (i = 0; i < MAX_ICONS; i++)
	if (icon_no[i] == obj)
		break;

if (br == 2)
	{
	unmark_icons();
	sample_reopen(-(i + 1));
	dialog_reopen(-(i + 1));
	}
else
	{
	graf_mkstate(&mx, &my, &mb, &ks);
	if (mb == 1 && obj > 0)
		{
	  graf_dragbox(w_bkg[obj].ob_width, 
		 						 w_bkg[obj].ob_height,
    	           w_bkg[obj].ob_x + w_bkg[ROOT].ob_x,
    	           w_bkg[obj].ob_y + w_bkg[ROOT].ob_y,
   	  	         w_bkg[ROOT].ob_x, w_bkg[ROOT].ob_y,
   							 w_bkg[ROOT].ob_width, w_bkg[ROOT].ob_height,
       	  	     &d_x, &d_y);

		if (!wind_find(d_x, d_y))                 
			{
			graf_mkstate(&mx, &my, &mb, &ks);
			d_obj = objc_find(w_bkg, ROOT, MAX_DEPTH, mx, my);
			if (d_obj == IC_T)
				{
				w_bkg[IC_T].ob_state |= SELECTED;
				objc_offset(w_bkg, IC_T, &d_x, &d_y);
				form_dial(FMD_FINISH, 0, 0, 0, 0, d_x, d_y,
									w_bkg[IC_T].ob_width,	w_bkg[IC_T].ob_height);
				sample_delete(-(i + 1));
				dialog_delete(-(i + 1));
				w_bkg[IC_T].ob_state &= ~SELECTED;
				form_dial(FMD_FINISH, 0, 0, 0, 0, d_x, d_y,
									w_bkg[IC_T].ob_width,	w_bkg[IC_T].ob_height);
				}
			else
				{
  	  	w_bkg[obj].ob_x = d_x - w_bkg[ROOT].ob_x;
	 	 		w_bkg[obj].ob_y = d_y - w_bkg[ROOT].ob_y;
		   	force_wredraw(ROOT);
 	  		}
	 		}
 		}
	else
		{
		unmark_icons();
		if (obj > 0)		 
			{
			w_bkg[obj].ob_state |= SELECTED;
			obj = search_sw(-(i + 1));
			if (obj > -1)
				last_sample = obj;
			force_wredraw(ROOT);
			}
		}
	}
}

/* ----------------
   | Unmark icons |
   ---------------- */
void unmark_icons(void)
{
int i, flg;

flg = 0;
for (i = 0; i < MAX_ICONS; i++)
	if (w_bkg[icon_no[i]].ob_state & SELECTED)
		{
		flg = 1;
		w_bkg[icon_no[i]].ob_state &= ~SELECTED;
		}
last_sample = -1;

if (flg)
	force_wredraw(ROOT);
}