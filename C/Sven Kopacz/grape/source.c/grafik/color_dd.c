#include <grape_h.h>
#include "grape.h"
#include "maininit.h"
#include "coled.h"
#include "mask.h"
#include "mforms.h"
/* Funktion aus GRAPE.C */

/* Funktionen fr Color-Drag & Drop */

void color_dd(OBJECT *src_tree, int src_ob)
{
	int	but, mx, my, ox, oy, dum;
	int	tx, ty, tw, th;
	int	wid, ob, target_ok=0;
	WINDOW	*win;
	OBJECT	*tree;
	CMY_COLOR col;
	
	evnt_timer(150,0);
	graf_mkstate(&dum, &dum, &but, &dum);
	if(!but)
	{/* Nur angeklickt->Als Farbselektion werten */
 		if(src_tree == otool) /* Aužer das war die Stiftfarbe */
 		{ /* Dann Farbpalette ”ffnen */
 			fetz_her(&wcolpal);
 			return;
 		}
		col.red=((U_OB*)(src_tree[src_ob]_UP_))->color.r[0];
		col.yellow=((U_OB*)(src_tree[src_ob]_UP_))->color.g[0];
		col.blue=((U_OB*)(src_tree[src_ob]_UP_))->color.b[0];
		set_pen_col(&col);
		return;
	}
	
	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);
	
	fill_dd_ob(src_tree, src_ob);

	graf_mkstate(&ox, &oy, &but, &dum);
	form_center(ocoldd, &tx, &ty, &tw, &th);
	tx=ox-tw/2; ty=oy-th/2;
	if(tx < sx) tx=sx;
	if(ty < sy) ty=sy;
	if(tx+tw > sx+sw) tx=sx+sw-tw;
	if(ty+th > sy+sh) ty=sy+sh-th;
	screen_buf(FMD_START, tx, ty, tw, th);
	ocoldd[0].ob_x=tx; ocoldd[0].ob_y=ty;
	objc_draw(ocoldd, 0, 2, sx ,sy, sw, sh);
	do
	{
		graf_mkstate(&mx, &my, &but, &dum);
		if((ox != mx) || (oy != my))
		{
			screen_buf(FMD_FINISH, tx, ty, tw, th);
			ox=mx; oy=my;
			tx=ox-tw/2; ty=oy-th/2;
			if(tx < sx) tx=sx;
			if(ty < sy) ty=sy;
			if(tx+tw > sx+sw) tx=sx+sw-tw;
			if(ty+th > sy+sh) ty=sy+sh-th;
			screen_buf(FMD_START, tx, ty, tw, th);
			ocoldd[0].ob_x=tx; ocoldd[0].ob_y=ty;
			objc_draw(ocoldd, 0, 2, sx ,sy, sw, sh);

			target_ok=0;
			wid=wind_find(mx, my);
			win=w_find(wid);
			if(win && win->dialog)
			{
				ob=objc_find(win->dinfo->tree, 0, 8, mx, my);
			 	if(ob > 0)
			 	{
				 	tree=win->dinfo->tree;
				 	if((tree[ob].ob_type & 255) == G_USERDEF)
					 	if( ((U_OB*)(tree[ob]_UP_))->type == 3)
					 		if(!(tree[ob].ob_state & DISABLED))
					 		target_ok=1;
			 	}
			}
			else if(wid == main_win.id)
			{
				tree=NULL;
				ob=objc_find(otoolbar, 0, 8, mx, my);
				if(ob < 0)	/* Nicht auf Toolbar */
					target_ok=1;
			}
			
			if(target_ok)
				graf_mouse(ARROW, NULL);
			else
				graf_mouse(USER_DEF, UD_CROSS);
		}
	}while(but & 1);

	screen_buf(FMD_FINISH, tx, ty, tw, th);
	
	graf_mouse(ARROW, NULL);
	wind_update(END_MCTRL);
	wind_update(END_UPDATE);
	
	if(target_ok && ((src_tree != tree) || (src_ob != ob)) )
	{
		col.red=((U_OB*)(src_tree[src_ob]_UP_))->color.r[0];
		col.yellow=((U_OB*)(src_tree[src_ob]_UP_))->color.g[0];
		col.blue=((U_OB*)(src_tree[src_ob]_UP_))->color.b[0];
		if(tree)
		{
			set_user_color(win, tree, ob, &col);
			if(win->dinfo->dservice)
				win->dinfo->dservice(-ob);
			else
				win->dinfo->dwservice(win, -ob);
		}
		else /* Auf Hauptfenster gezogen */
			fill_act_plane(&col);
	}
}

void screen_buf(int mode, int x, int y, int w, int h)
{
	static long *adr;
	static int init=0, planes;
	unsigned int hi, lo, dum;
	MFDB src, des;
	int	pxy[8];
	
	if(!init)
	{
		wind_get(0,WF_SCREEN,&hi, &lo,&dum,&dum);
		adr=(long*)(65536l*(ulong)hi+(ulong)lo);
		vq_extnd(handle, 1, work_out);
		planes=work_out[4];
		init=1;
	}

	if (mode == FMD_START)
	{
		src.fd_addr=NULL;
		src.fd_stand=0;
		des.fd_addr=adr;
		pxy[0]=x;
		pxy[1]=y;
		pxy[2]=x+w-1;
		pxy[3]=y+h-1;
		pxy[4]=0;
		pxy[5]=0;
		pxy[6]=w-1;
		pxy[7]=h-1;

		des.fd_w=sw/2;
		des.fd_h=sh/2;
		des.fd_wdwidth=sw/32;
		des.fd_stand=0;
		des.fd_nplanes=planes;
	}
	else if (mode == FMD_FINISH)
	{
		src.fd_addr=adr;
		des.fd_stand=0;
		des.fd_addr=NULL;
		pxy[4]=x;
		pxy[5]=y;
		pxy[6]=x+w-1;
		pxy[7]=y+h-1;

		pxy[0]=0;
		pxy[1]=0;
		pxy[2]=w-1;
		pxy[3]=h-1;

		src.fd_w=sw/2;
		src.fd_h=sh/2;
		src.fd_wdwidth=sw/32;
		src.fd_stand=0;
		src.fd_nplanes=planes;
	}
	graf_mouse(M_OFF,NULL);	
	vro_cpyfm(handle, 3, pxy, &src, &des);
	graf_mouse(M_ON,NULL);	
}

void fill_dd_ob(OBJECT *src_tree, int src_ob)
{
	/* Fllt das Color-D&D-Objekt mit der Quellfarbe aus ob in tree
	   (muž natrlich Userdef vom Typ 3 sein */
	   
	unsigned char r, g, b;
	int						m, n;
	
	r=((U_OB*)(src_tree[src_ob]_UP_))->color.r[0];
	g=((U_OB*)(src_tree[src_ob]_UP_))->color.g[0];
	b=((U_OB*)(src_tree[src_ob]_UP_))->color.b[0];

	m=((U_OB*)(ocoldd[COLDDOB]_UP_))->color.w*ocoldd[COLDDOB].ob_height;
	
	for(n=0; n < m; ++n)
	{
		((U_OB*)(ocoldd[COLDDOB]_UP_))->color.r[n]=r;
		((U_OB*)(ocoldd[COLDDOB]_UP_))->color.g[n]=g;
		((U_OB*)(ocoldd[COLDDOB]_UP_))->color.b[n]=b;
	}
}	

void set_user_color(WINDOW *win, OBJECT *tree, int ob, CMY_COLOR *col)
{
	/* Setzt im Objekt ob des Dialogs tree des Fensters win
		 die Farbe col.
		 Objekt muž natrlich Userdef Typ 3 sein */

	int a, b, x, y, w, h;

	b=((U_OB*)(tree[ob]_UP_))->color.w*tree[ob].ob_height;
	
	for(a=0; a < b; ++a)
	{
		((U_OB*)(tree[ob]_UP_))->color.r[a]=col->red;
		((U_OB*)(tree[ob]_UP_))->color.g[a]=col->yellow;
		((U_OB*)(tree[ob]_UP_))->color.b[a]=col->blue;
	}
	
	objc_offset(tree, ob, &x, &y);
	w=tree[ob].ob_width;
	h=tree[ob].ob_height;
	w_redraw(win, x, y, w, h, 0);
	
}