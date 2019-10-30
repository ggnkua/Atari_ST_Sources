/********************************************************************
 *																0.20*
 *	Popup menu bars for inside dialog boxes and dropside menus		*
 *	by Ken Hollis													*
 *																	*
 *	Copyright (c) 1994, Bitgate Software.  All Rights Reserved.		*
 *																	*
 *	These are the preliminaries for the actual popup routines.		*
 *	They don't quite work the way I want them to, but after all.	*
 *	They *ARE* the first versions, after all...						*
 *																	*
 ********************************************************************/

#include <tos.h>		/* Standard TOS bindings */
#include <stdio.h>		/* Standard IO bindings */

#include "xaes.h"

void *dpbuffer;

GLOBAL void PPopup_DialXY(OBJECT *srctree, int srcindex, OBJECT *desttree)
{
	int	tx, ty;
	int ox, oy;

	desttree->ob_x = srctree->ob_x;
	desttree->ob_y = srctree->ob_y;

	objc_offset(srctree, srcindex, &ox, &oy);

	desttree->ob_x += ox;
	desttree->ob_y += oy;

	desttree->ob_x--;
	desttree->ob_y--;

	if ((tx = (desttree->ob_x + desttree->ob_width) - (desk.g_x + desk.g_w)) < 0)
		tx = 0;
	else
		tx += 8;

	if (((desttree->ob_y + desttree->ob_height) - (desk.g_y + desk.g_h)) < 0)
		ty = 0;
	else
		ty -= desttree->ob_y + desttree->ob_height;

	desttree->ob_x -= tx;
	desttree->ob_y += ty;
}

GLOBAL void PDropdown_DialXY(OBJECT *srctree, int srcindex, OBJECT *desttree)
{
	int	tx, ty;
	int ox, oy;

	desttree->ob_x = srctree->ob_x;
	desttree->ob_y = srctree->ob_y + srctree->ob_height;

	objc_offset(srctree, srcindex, &ox, &oy);

	desttree->ob_x += ox;
	desttree->ob_y += oy;

	desttree->ob_x--;
	desttree->ob_y -= 2;

	if ((tx = (desttree->ob_x + desttree->ob_width) - (desk.g_x + desk.g_w)) < 0)
		tx = 0;
	else
		tx += 8;

	if (((desttree->ob_y + desttree->ob_height) - (desk.g_y + desk.g_h)) < 0)
		ty = 0;
	else
		ty -= desttree->ob_y + desttree->ob_height;

	desttree->ob_x -= tx;
	desttree->ob_y += ty;
}

GLOBAL void PPopup_WinXY(WINDOW *win, int srcindex, OBJECT *desttree)
{
	int	tx, ty;
	GRECT work;

	WWindGet(win, WF_WORKXYWH, &work.g_x, &work.g_y, &work.g_w, &work.g_h);

	desttree->ob_x = win->tree[srcindex].ob_x + work.g_x;
	desttree->ob_y = win->tree[srcindex].ob_y + work.g_y;

	desttree->ob_x--;
	desttree->ob_y--;

	if ((tx = (desttree->ob_x + desttree->ob_width) - (desk.g_x + desk.g_w)) < 0)
		tx = 0;

	if ((ty = (desttree->ob_y + desttree->ob_height) - (desk.g_y + desk.g_h)) < 0)
		ty = 0;

	desttree->ob_x -= tx;
	desttree->ob_y -= ty;
}

GLOBAL void PDropdown_WinXY(WINDOW *win, int srcindex, OBJECT *desttree)
{
	int	tx, ty;
	GRECT work;

	WWindGet(win, WF_WORKXYWH, &work.g_x, &work.g_y, &work.g_w, &work.g_h);

	desttree->ob_x = win->tree[srcindex].ob_x + work.g_x;
	desttree->ob_y = (win->tree[srcindex].ob_y + win->tree[srcindex].ob_height) + work.g_y;

	desttree->ob_x--;
	desttree->ob_y -= 2;

	if ((tx = (desttree->ob_x + desttree->ob_width) - (desk.g_x + desk.g_w)) < 0)
		tx = 0;

	if ((ty = (desttree->ob_y + desttree->ob_height) - (desk.g_y + desk.g_h)) < 0)
		ty = 0;

	desttree->ob_x -= tx;
	desttree->ob_y -= ty;
}

GLOBAL void PMovePopupCoord(OBJECT *desttree, int x, int y)
{
	int	tx, ty;

	desttree->ob_x = x;
	desttree->ob_y = y;

	desttree->ob_x--;
	desttree->ob_y--;

	if ((tx = (desttree->ob_x + desttree->ob_width) - (desk.g_x + desk.g_w)) < 0)
		tx = 0;

	if ((ty = (desttree->ob_y + desttree->ob_height) - (desk.g_y + desk.g_h)) < 0)
		ty = 0;

	desttree->ob_x -= tx;
	desttree->ob_y -= ty;

	if (desttree->ob_x < desk.g_x)
		desttree->ob_x = desk.g_x;

	if (desttree->ob_y < desk.g_y)
		desttree->ob_y = desk.g_y;
}

GLOBAL int PDoPopup(WINDOW *win, int index, OBJECT *menu_addr, int show, int x, int y, int w, int h)
{
	int LastOb,CurrOb,work_out[57];
	int button,mx,my,firstbut;
	void *ourbuffer;
	OBJECT *ptr;
	GRECT work;

	UNUSED(menu_addr);
	UNUSED(show);

	WWindGet(win, WF_WORKXYWH, &work.g_x, &work.g_y, &work.g_w, &work.g_h);

	vq_extnd(VDIhandle, 1, work_out);

	rsrc_gaddr(R_TREE, index, &ptr);

	ourbuffer = scrsave(VDIhandle, ptr->ob_x, ptr->ob_y, ptr->ob_width, ptr->ob_height);

	if (x!=0 && y!=0 && w!=0 && h!=0)
		graf_growbox(x + work.g_x, y + work.g_y, w, h, ptr->ob_x, ptr->ob_y, ptr->ob_width, ptr->ob_height);

	objc_draw(ptr, 0, 6, ptr->ob_x, ptr->ob_y, ptr->ob_width, ptr->ob_height);
	LastOb = -1;

	vq_mouse(VDIhandle,&firstbut,&mx,&my);

/*	if (firstbut == 2) {
		while (firstbut==2)
			vq_mouse(VDIhandle, &firstbut, &mx, &my);

		firstbut = 0;
	} */

	do {
		vq_mouse(VDIhandle,&button,&mx,&my);
		CurrOb = objc_find(ptr, 0, MAX_DEPTH, mx, my);
		if ((CurrOb==-1) && (ptr[LastOb].ob_flags & SELECTABLE) && !(ptr[LastOb].ob_state & DISABLED)) {
			objc_change(ptr,LastOb,0,desk.g_x,desk.g_y,desk.g_w,desk.g_h,NORMAL,1);
			objc_draw(ptr,LastOb,0,desk.g_x,desk.g_y,desk.g_w,desk.g_h);
			LastOb = -1;
		}
		if ((CurrOb>0) && (LastOb!=CurrOb) && (ptr[LastOb].ob_flags & SELECTABLE) && !(ptr[LastOb].ob_state & DISABLED)) {
			if ((LastOb>0) && !(ptr[LastOb].ob_state & DISABLED)) {
				objc_change(ptr,LastOb,0,desk.g_x,desk.g_y,desk.g_w,desk.g_h,NORMAL,1);
				objc_draw(ptr,LastOb,0,desk.g_x,desk.g_y,desk.g_w,desk.g_h);
			}
			LastOb = -1;
		}
		if ((CurrOb!=LastOb) && (ptr[CurrOb].ob_flags & SELECTABLE) && !(ptr[CurrOb].ob_state & DISABLED)) {
			if ((LastOb>0) && !(ptr[LastOb].ob_state & DISABLED)) {
				objc_change(ptr,LastOb,0,desk.g_x,desk.g_y,desk.g_w,desk.g_h,NORMAL,1);
				objc_draw(ptr,LastOb,0,desk.g_x,desk.g_y,desk.g_w,desk.g_h);
			}
			if ((CurrOb>0) && !(ptr[CurrOb].ob_state & DISABLED)) {
				objc_change(ptr,CurrOb,0,desk.g_x,desk.g_y,desk.g_w,desk.g_h,SELECTED,1);
				objc_draw(ptr,CurrOb,0,desk.g_x,desk.g_y,desk.g_w,desk.g_h);
			}
			LastOb = CurrOb;
		}
	} while(button == firstbut);

	if ((LastOb>0) && !(ptr[LastOb].ob_state & DISABLED) && (ptr[LastOb].ob_flags & SELECTABLE)) {
		objc_change(ptr,LastOb,0,desk.g_x,desk.g_y,desk.g_w,desk.g_h,NORMAL,1);
		objc_draw(ptr,LastOb,0,desk.g_x,desk.g_y,desk.g_w,desk.g_h);
	}
	if ((CurrOb>0) && !(ptr[CurrOb].ob_state & DISABLED) && (ptr[CurrOb].ob_flags & SELECTABLE)) {
		objc_change(ptr,CurrOb,0,desk.g_x,desk.g_y,desk.g_w,desk.g_h,NORMAL,1);
		objc_draw(ptr,CurrOb,0,desk.g_x,desk.g_y,desk.g_w,desk.g_h);
	}

	do {
		vq_mouse(VDIhandle,&button,&mx,&my);
	} while(button);

	scrrestore(ourbuffer);

	if (x!=0 && y!=0 && w!=0 && h!=0) {
		graf_shrinkbox(x + work.g_x, y + work.g_y, w, h, ptr->ob_x, ptr->ob_y, ptr->ob_width, ptr->ob_height);
		vswr_mode(VDIhandle, MD_XOR);
	}

	return(LastOb);
}

GLOBAL int PDoPopupAddr(OBJECT *index)
{
	int LastOb,CurrOb,work_out[57];
	int button,mx,my,firstbut,but;
	void *ourbuffer;

	vq_extnd(VDIhandle, 1, work_out);

	ourbuffer = scrsave(VDIhandle, index->ob_x, index->ob_y, index->ob_width, index->ob_height);
	objc_draw(index, 0, 6, index->ob_x, index->ob_y, index->ob_width, index->ob_height);
	LastOb = -1;

/*	if (firstbut == 2) {
		while (firstbut==2)
			vq_mouse(VDIhandle, &firstbut, &mx, &my);

		firstbut = 0;
	} */

	vq_mouse(VDIhandle,&firstbut,&mx,&my);

	but = (firstbut == 1) ? 0 : 1;

	do {
		vq_mouse(VDIhandle,&button,&mx,&my);
		CurrOb = objc_find(index, 0, MAX_DEPTH, mx, my);
		if ((CurrOb==-1) && (LastOb!=-1) && (index[LastOb].ob_flags & SELECTABLE) && !(index[LastOb].ob_state & DISABLED)) {
			objc_change(index,LastOb,0,desk.g_x,desk.g_y,desk.g_w,desk.g_h,NORMAL,1);
			LastOb = -1;
		}
		if ((CurrOb>0) && (LastOb!=CurrOb) && (index[LastOb].ob_flags & SELECTABLE) && !(index[LastOb].ob_state & DISABLED)) {
			if ((LastOb>0) && !(index[LastOb].ob_state & DISABLED)) {
				objc_change(index,LastOb,0,desk.g_x,desk.g_y,desk.g_w,desk.g_h,NORMAL,1);
			}
			LastOb = -1;
		}
		if ((CurrOb!=LastOb) && (index[CurrOb].ob_flags & SELECTABLE) && !(index[CurrOb].ob_state & DISABLED)) {
			if ((LastOb>0) && !(index[LastOb].ob_state & DISABLED)) {
				objc_change(index,LastOb,0,desk.g_x,desk.g_y,desk.g_w,desk.g_h,NORMAL,1);
			}
			if ((CurrOb>0) && !(index[CurrOb].ob_state & DISABLED)) {
				objc_change(index,CurrOb,0,desk.g_x,desk.g_y,desk.g_w,desk.g_h,SELECTED,1);
			}
			LastOb = CurrOb;
		}
	} while(button != but);

	if ((LastOb>0) && !(index[LastOb].ob_state & DISABLED) && (index[LastOb].ob_flags & SELECTABLE)) {
		objc_change(index,LastOb,0,desk.g_x,desk.g_y,desk.g_w,desk.g_h,NORMAL,1);
		objc_draw(index,LastOb,0,desk.g_x,desk.g_y,desk.g_w,desk.g_h);
	}
	if ((CurrOb>0) && !(index[CurrOb].ob_state & DISABLED) && (index[CurrOb].ob_flags & SELECTABLE)) {
		objc_change(index,CurrOb,0,desk.g_x,desk.g_y,desk.g_w,desk.g_h,NORMAL,1);
		objc_draw(index,CurrOb,0,desk.g_x,desk.g_y,desk.g_w,desk.g_h);
	}

	do {
		vq_mouse(VDIhandle,&button,&mx,&my);
	} while(button);

	scrrestore(ourbuffer);

	return(LastOb);
}

GLOBAL int PShowPopupDesk(OBJECT *index)
{
	dpbuffer = scrsave(VDIhandle, index->ob_x, index->ob_y, index->ob_width, index->ob_height);
	if (dpbuffer) {
		objc_draw(index, 0, 6, index->ob_x, index->ob_y, index->ob_width, index->ob_height);
		return TRUE;
	} else
		return FALSE;
}

GLOBAL int PEndPopupDesk(OBJECT *index)
{
	if (dpbuffer) {
		scrrestore(dpbuffer);
		return TRUE;
	} else {
		form_dial(3, index->ob_x, index->ob_y, index->ob_width, index->ob_height,
					 index->ob_x, index->ob_y, index->ob_width, index->ob_height);
		return FALSE;
	}
}

GLOBAL int PDoPopupDeskMenu(OBJECT *index, int *retbtn)
{
	int LastOb,CurrOb;
	int button,mx,my,firstbut;

	*retbtn = 0;
	LastOb = -1;

	vq_mouse(VDIhandle,&firstbut,&mx,&my);

/*	if (firstbut == 2) {
		while (firstbut==2)
			vq_mouse(VDIhandle, &firstbut, &mx, &my);

		firstbut = 0;
	} */

	do {
		vq_mouse(VDIhandle,&button,&mx,&my);
		CurrOb = objc_find(index, 0, MAX_DEPTH, mx, my);

		if (CurrOb==-1) {
			if ((LastOb>0) && !(index[LastOb].ob_state & DISABLED) && (index[LastOb].ob_flags & SELECTABLE)) {
				objc_change(index,LastOb,0,desk.g_x,desk.g_y,desk.g_w,desk.g_h,NORMAL,1);
				objc_draw(index,LastOb,0,desk.g_x,desk.g_y,desk.g_w,desk.g_h);
			}
			if ((CurrOb>0) && !(index[CurrOb].ob_state & DISABLED) && (index[CurrOb].ob_flags & SELECTABLE)) {
				objc_change(index,CurrOb,0,desk.g_x,desk.g_y,desk.g_w,desk.g_h,NORMAL,1);
				objc_draw(index,CurrOb,0,desk.g_x,desk.g_y,desk.g_w,desk.g_h);
			}

			*retbtn = FALSE;
			return 0;
		}
		
		if ((CurrOb==-1) && (index[LastOb].ob_flags & SELECTABLE) && !(index[LastOb].ob_state & DISABLED)) {
			objc_change(index,LastOb,0,desk.g_x,desk.g_y,desk.g_w,desk.g_h,NORMAL,1);
			LastOb = -1;
		}
		if ((CurrOb>0) && (LastOb!=CurrOb) && (index[LastOb].ob_flags & SELECTABLE) && !(index[LastOb].ob_state & DISABLED)) {
			if ((LastOb>0) && !(index[LastOb].ob_state & DISABLED)) {
				objc_change(index,LastOb,0,desk.g_x,desk.g_y,desk.g_w,desk.g_h,NORMAL,1);
			}
			LastOb = -1;
		}
		if ((CurrOb!=LastOb) && (index[CurrOb].ob_flags & SELECTABLE) && !(index[CurrOb].ob_state & DISABLED)) {
			if ((LastOb>0) && !(index[LastOb].ob_state & DISABLED)) {
				objc_change(index,LastOb,0,desk.g_x,desk.g_y,desk.g_w,desk.g_h,NORMAL,1);
			}
			if ((CurrOb>0) && !(index[CurrOb].ob_state & DISABLED)) {
				objc_change(index,CurrOb,0,desk.g_x,desk.g_y,desk.g_w,desk.g_h,SELECTED,1);
			}
			LastOb = CurrOb;
		}
	} while(button == firstbut);

	if ((LastOb>0) && !(index[LastOb].ob_state & DISABLED) && (index[LastOb].ob_flags & SELECTABLE)) {
		objc_change(index,LastOb,0,desk.g_x,desk.g_y,desk.g_w,desk.g_h,NORMAL,1);
		objc_draw(index,LastOb,0,desk.g_x,desk.g_y,desk.g_w,desk.g_h);
	}
	if ((CurrOb>0) && !(index[CurrOb].ob_state & DISABLED) && (index[CurrOb].ob_flags & SELECTABLE)) {
		objc_change(index,CurrOb,0,desk.g_x,desk.g_y,desk.g_w,desk.g_h,NORMAL,1);
		objc_draw(index,CurrOb,0,desk.g_x,desk.g_y,desk.g_w,desk.g_h);
	}

	do {
		vq_mouse(VDIhandle,&button,&mx,&my);
	} while(button);

	*retbtn = TRUE;
	return(LastOb);
}