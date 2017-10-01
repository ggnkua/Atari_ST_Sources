/*	RCSOBJS.C	11/20/84 - 1/25/85 	Tim Oren		*/
/*************************************************************
 * Copyright 1999 by Caldera Thin Clients, Inc.              *
 * This software is licensed under the GNU Public License.   *
 * Please see LICENSE.TXT for further information.           *
 *************************************************************/
#include <stdlib.h>
#include <portab.h>
#include <machine.h>
#if GEMDOS
#if TURBO_C
#include <aes.h>
#include <vdi.h>
#endif
#else
#include <obdefs.h>
#include <gembind.h>
#endif
#include "rcsdefs.h"
#include "rcs.h"
#include "rcsdata.h"
#include "rcslib.h"
#include "rcsintf.h"
#include "rcsalert.h"
#include "rcsmenu.h"
#include "rcsmain.h"
#include "rcsasm.h"
#include "rcsobjs.h"

EXTERN	BOOLEAN iconedit_flag;
EXTERN	WORD	gridw, gridh;

WORD snap_xs(WORD x)
{
	WORD i;

	x += (i = iconedit_flag ? gridw : gl_wchar) / 2;
	return (x - x % i);
}

WORD snap_ys(WORD y)
{
	WORD i;

	y += (i = iconedit_flag ? gridh : gl_hchar) / 2;
	return (y - y % i);
}

WORD clamp_xs(LONG tree, WORD x)
{
	x = min(x, GET_WIDTH(tree, ROOT) - view.g_w);
	return max(0, x);
}

WORD clamp_ys(LONG tree, WORD y)
{
	y = min(y, GET_HEIGHT(tree, ROOT) - view.g_h);
	return max(0, y);
}

VOID do_hsinc(WORD inc)
{
	rcs_xpan = clamp_xs(ad_view, snap_xs(rcs_xpan + inc));
}

VOID do_vsinc(WORD inc)
{
	rcs_ypan = clamp_ys(ad_view, snap_ys(rcs_ypan + inc));
}

VOID set_rootxy(LONG tree)
{
	SET_X(tree, ROOT, view.g_x - rcs_xpan);
	SET_Y(tree, ROOT, view.g_y - rcs_ypan);
}

WORD newsize_obj(LONG tree, WORD obj, WORD neww, WORD newh, WORD ok)
{
	WORD	pobj;
	GRECT	p;

	if (!neww || !newh)
		return(TRUE);
	else
	{
		objc_xywh(tree, obj, &p);
		pobj = get_parent(tree, obj);

		if (!ok)
		{
			if (pobj != posn_obj(tree, pobj, &p.g_x, &p.g_y, neww, newh, TRUE))
			{
				if (!rcs_xpert)
					if (hndl_alert(2, string_addr(STSIZEP)) == 1)
						return(FALSE);
				if (rcs_lock)
				{
					hndl_locked();
					return(FALSE);
				}
			}
		}
		SET_WIDTH(tree, obj, neww);
		SET_HEIGHT(tree, obj, newh);
		return(TRUE);
	}
}

VOID slid_objs(VOID)
{
	WORD	h_size, v_size;
	WORD	w, h;

	w = GET_WIDTH(ad_view, ROOT);
	h = GET_HEIGHT(ad_view, ROOT);
	h_size = (WORD) umul_div(view.g_w, 1000, w);
	h_size = min(1000, h_size);
	v_size = (WORD) umul_div(view.g_h, 1000, h);
	v_size = min(1000, v_size);
	set_slsize(rcs_view, h_size, v_size); 
	h_size = max(1, w - view.g_w);
	h_size = (WORD) umul_div(rcs_xpan, 1000, h_size);
	v_size = max(1, h - view.g_h);
	v_size = (WORD) umul_div(rcs_ypan, 1000, v_size);
	set_slpos(rcs_view, h_size, v_size);
}

VOID view_objs(VOID)
{
	rcs_xpan = clamp_xs(ad_view, rcs_xpan);	
	rcs_ypan = clamp_ys(ad_view, rcs_ypan);
	set_rootxy(ad_view);
	slid_objs();
	send_redraw(rcs_view, &view);
}

VOID type_obj(WORD obj)
{
	WORD	exitobj, obtype, obmsb;
	LONG	otaddr, tree, taddr;
	GRECT	p;
	BYTE	xtype[4];

	tree = ad_view;
	obtype = LWGET(otaddr = OB_TYPE(obj));
	obmsb = LHIBT(obtype);
	obtype = LLOBT(obtype);
	objc_xywh(tree, obj, &p);

	ini_tree(&tree, NOBJTREE);
	hide_obj(tree, STRTYPES);
	hide_obj(tree, BOXTYPES);
	hide_obj(tree, TXTTYPES);

	sprintf(xtype, "%hd", obmsb);
	taddr = GET_SPEC(tree, XTYPE);
	LLSET(TE_PTEXT(taddr), ADDR(xtype));
	LLSET(TE_TXTLEN(taddr),0x4L);

	switch (obtype)
	{
		case G_STRING:
		case G_BUTTON:
			unhide_obj(tree, STRTYPES);
			table_code(tree, STRTYPE0, str_types, 2, obtype);
			break;
		case G_BOX:
		case G_IBOX:
		case G_BOXCHAR:
			unhide_obj(tree, BOXTYPES);
			table_code(tree, BOXTYPE0, box_types, 3, obtype);
			break;
		case G_TEXT:
		case G_FTEXT:
		case G_BOXTEXT:
		case G_FBOXTEXT:
			unhide_obj(tree, TXTTYPES);
			table_code(tree, TXTTYPE0, txt_types, 4, obtype);
			break;
		default:
			return;
	}

	exitobj = hndl_dial(tree, 0, &p);

	if (exitobj == NOOKITEM)
	{
		rcs_edited = TRUE;
		obmsb = atoi(xtype) & 0xff;
		switch (obtype)
		{
			case G_STRING:
			case G_BUTTON:
				obtype = str_types[encode(tree, STRTYPE0, 2)];
				break;
			case G_BOX:
			case G_IBOX:
			case G_BOXCHAR:
				obtype = box_types[encode(tree, BOXTYPE0, 3)];
				break;
			case G_TEXT:
			case G_FTEXT:
			case G_BOXTEXT:
			case G_FBOXTEXT:
				obtype = txt_types[encode(tree, TXTTYPE0, 4)];
				break;
			default:
				return;
		}

		LWSET(otaddr, (obmsb << 8) | obtype);
		set_hot();
	}
	map_tree(tree, ROOT, NIL, (fkt_parm)desel_obj);

	obj_redraw(ad_view, obj);
}  

VOID del_ob(WORD sobj)
{
	LONG	tree;
	WORD	n, menu_obj;

	if (rcs_lock)
		hndl_locked();
	else
	{
		tree = ad_view;
		switch (rcs_state)
		{
			case FREE_STATE:
			case PANL_STATE:
			case DIAL_STATE:
				obj_redraw(tree, sobj);
				zap_objindex(tree, sobj);
				map_dslct(tree, sobj);
				objc_delete((OBJECT FAR *)tree, sobj);
				return;
			case MENU_STATE:
				if (in_menu(tree, sobj))
				{
					if (is_menu(tree, get_parent(tree, sobj)) == 1)
						return;
					else
					{
						zap_objindex(tree, sobj);
						map_dslct(tree, sobj);
						objc_delete((OBJECT FAR *)tree, sobj);
						break;
					}
				}
				n = is_menu(tree, sobj);
				if (n)
				{
					if (n == 1)
						return;
					else
					{
						zap_objindex(tree, sobj);
						SET_HEAD(tree, sobj, NIL);
						SET_TAIL(tree, sobj, NIL);
						SET_HEIGHT(tree, sobj, gl_hchar);
						SET_WIDTH(tree, sobj,
						GET_WIDTH(tree, menu_n(tree, n)));
						break;
					}
				}
				n = in_bar(tree, sobj);
				if (n)
				{
					if (n == 1)
						return;
					else
					{
						menu_obj = menu_n(tree, n);
						zap_objindex(tree, menu_obj);
						map_dslct(tree, menu_obj);
						objc_delete((OBJECT FAR *)tree, menu_obj);
						zap_objindex(tree, sobj);
						map_dslct(tree, sobj);
						objc_delete((OBJECT FAR *)tree, sobj);
						fix_menu_bar(tree);
						break;
					}
				}
				return;
			case ALRT_STATE:
				SET_SPEC(tree, sobj, -1L);
				fix_alert(tree);
				dslct_1obj(tree, sobj);
				break;
			default:
				return;
		}
		view_objs();
	}
}

LOCAL VOID constrain_obj(LONG tree, WORD obj, WORD *px, WORD *py)
{
	WORD	tx, ty, x, y;

	switch (rcs_state)
	{
		case FREE_STATE:
		case DIAL_STATE:
		case MENU_STATE:
			objc_offset((OBJECT FAR *)tree, obj, &x, &y);
			tx = *px - x;
			ty = *py - y;
			snap_xy(&tx, &ty);
			*px = x + tx;
			*py = y + ty;
			return;
		case PANL_STATE:
			return;
		default:
			return;
	}
}

WORD posn_obj(LONG tree, WORD obj, WORD *px, WORD *py, WORD w, WORD h, WORD exact_ok)
{
	GRECT	o;
	WORD	tx, ty; 

	FOREVER
	{
		tx = *px;
		ty = *py;
		constrain_obj(tree, obj, &tx, &ty);
		objc_xywh(tree, obj, &o); 
		/* rectangle must fit, but not exactly, to nest under the obj */
		if (tx >= o.g_x && ty >= o.g_y &&
			tx + w <= o.g_x + o.g_w &&
			ty + h <= o.g_y + o.g_h )
		{
			if (exact_ok)
				break;	
			if (tx > o.g_x || ty > o.g_y ||
				tx + w < o.g_x + o.g_w ||
				ty + h < o.g_y + o.g_h )
				break;
		}
		if (obj == ROOT)
			return (NIL);
		obj = get_parent(tree, obj);
	}
	*px = tx - o.g_x;
	*py = ty - o.g_y;
	return (obj);
}

VOID cut_obj(WORD sobj, WORD dup)
{
	if (rcs_lock)
		hndl_locked();
	else
	{
		if (rcs_state == MENU_STATE)
			if (!menu_ok(ad_view, sobj) & !dup)
				return;
		rcs_clipkind = OBJKIND;
		ad_clip = copy_tree(ad_view, sobj, TRUE);
		if (!dup)
			del_ob(sobj);
	}
}

VOID paste_obj(WORD dobj, WORD dx, WORD dy, WORD dup)
{
	if (rcs_clipkind == OBJKIND)
	{
		if (new_obj(ad_clip, ROOT, dobj, dx, dy))
			if (!dup)
				clr_clip();
	}
}

WORD new_obj(LONG stree, WORD sobj, WORD dobj, WORD dx, WORD dy)
{
	LONG	tree, taddr, otaddr;
	WORD	sx, sy, dw, dh, add_at, type, obmsb;

	if (rcs_lock)
	{
		hndl_locked();
		return (FALSE);
	}
	else
	{
		tree = stree;
		dw = GET_WIDTH(tree, sobj);
		dh = GET_HEIGHT(tree, sobj);
		type = LLOBT(GET_TYPE(tree, sobj));

		switch (rcs_state)
		{
			case FREE_STATE:
				if (type != G_IMAGE && type != G_STRING)
					return (FALSE);
			case PANL_STATE:
			case DIAL_STATE:
				objc_offset((OBJECT FAR *)stree, sobj, &sx, &sy);
				if (sx == dx && sy == dy)	/* Don't copy */
					return (FALSE);		/* right on top */
				else
				{
					dobj = posn_obj(ad_view, dobj, &dx, &dy, dw, dh, FALSE);
					if (dobj == NIL)
						return (FALSE);
					else
					{
						sobj = copy_objs(stree, sobj, ad_view, TRUE);
						tree = ad_view;				     
						if ( type == G_IMAGE || type == G_ICON)
						{
							obmsb = 1;
							otaddr = OB_TYPE(sobj);
							LWSET(otaddr, (obmsb << 8) | type );
						}
						if (stree == ad_pbx)
							SET_STATE(tree, sobj, NORMAL);
						objc_add((OBJECT FAR *)ad_view, dobj, sobj);
						SET_X(tree, sobj, dx);
						SET_Y(tree, sobj, dy);
						obj_redraw(tree, sobj);
						return (TRUE);
					}
				}
			case MENU_STATE:
				if (LLOBT(GET_TYPE(tree, sobj)) == G_TITLE)
				{
					tree = ad_view;
					if (GET_HEAD(tree, ROOT) == dobj)  /* is_bar? */
						add_at = -1;
					else if ((add_at = in_bar(tree, dobj) - 1) < 1)
						return (FALSE);
					sobj = copy_objs(stree, sobj, ad_view, TRUE);
					SET_Y(tree, sobj, 0);
					objc_add((OBJECT FAR *)tree, get_active(tree), sobj);
					objc_order((OBJECT FAR *)tree, sobj, add_at);
					sobj = blank_menu(tree, sobj);
					objc_add((OBJECT FAR *)tree, GET_TAIL(tree, ROOT), sobj);
					objc_order((OBJECT FAR *)tree, sobj, add_at);
					fix_menu_bar(tree);
					break;
				}
				if (stree == ad_view && is_menu(tree, sobj))
					return (FALSE);
				else
				{
					dobj = posn_obj(ad_view, dobj, &dx, &dy, dw, dh, TRUE);
					if (dobj == NIL)
						return (FALSE);
					else
					{
						tree = ad_view;
						if (in_menu(tree, dobj))
						{
							dx += GET_X(tree, dobj);
							dy += GET_Y(tree, dobj);
							dobj = get_parent(tree, dobj);
						}
						if (is_menu(tree, dobj) < 2)
							return (FALSE);
						else
						{
							sobj = copy_objs(stree, sobj, ad_view, TRUE);
							objc_add((OBJECT FAR *)tree, dobj, sobj);
							SET_X(tree, sobj, dx);
							SET_Y(tree, sobj, dy);
						}
					}
				}
				break;
			case ALRT_STATE:
				taddr = GET_SPEC(tree, sobj);
				tree = ad_view;
				switch (type)
				{
					case G_IMAGE:
						if (stree == ad_clip)
							return (FALSE);
						add_at = ALRTIMG;
						break;
					case G_STRING:
						add_at = pt_roomp(tree, ALRTSTR0, 5);
						if ( !add_at )
							return (FALSE);
						break;
					case G_BUTTON:
						add_at = pt_roomp(tree, ALRTBTN0, 3);
						if ( !add_at )
							return (FALSE);
						break;
					default:
						return (FALSE);
				}
				SET_SPEC(tree, add_at, taddr);
				fix_alert(tree);
				break;
			default:
				return (FALSE);
		}

		view_objs();
		return (TRUE);
	}
}

VOID mov_obj(WORD sobj, WORD dobj, WORD dx, WORD dy)
{
	LONG	tree;
	WORD	dw, dh;
	WORD	pobj, n, add_at;

	tree = ad_view;
	dw = GET_WIDTH(tree, sobj);
	dh = GET_HEIGHT(tree, sobj);
	obj_redraw(tree, sobj);

	switch (rcs_state)
	{
		case FREE_STATE:
		case PANL_STATE:
		case DIAL_STATE:
			pobj = get_parent(tree, sobj);
			dobj = posn_obj(tree, dobj, &dx, &dy, dw, dh, FALSE);
			if (dobj == NIL)
				return;
			if (pobj != dobj)
			{
				if (rcs_lock)
				{
					hndl_locked();
				 	return;
				}
				if (!rcs_xpert)
					if (hndl_alert(2, string_addr(STMOVED)) == 1)
						return;
				objc_delete((OBJECT FAR *)tree, sobj);
				objc_add((OBJECT FAR *)tree, dobj, sobj);
			}
			SET_X(tree, sobj, dx);
			SET_Y(tree, sobj, dy);
   		 	obj_redraw(tree, sobj);
			return;
		case MENU_STATE:
			if (rcs_lock)
			{
				hndl_locked();
				return;
			}
			n = in_bar(tree, sobj);
			if (n)
			{
				if (n == 1 || dobj == sobj)
					return;
				if (GET_HEAD(tree, ROOT) == dobj)  /* is_bar? */
					add_at = -1;
				else if ((add_at = in_bar(tree, dobj) - 1) < 1)
					return;
				objc_order((OBJECT FAR *)tree, sobj, add_at);
				sobj = menu_n(tree, n);
				objc_order((OBJECT FAR *)tree, sobj, add_at);
				fix_menu_bar(tree);
				view_objs();
				return;
			}
			if (!in_menu(tree, sobj))
				return;
			pobj = get_parent(tree, sobj);
			if (is_menu(tree, pobj) == 1)
				return;
			dobj = posn_obj(tree, dobj, &dx, &dy, dw, dh, FALSE);
			if (dobj == NIL)
				return;
			if (in_menu(tree, dobj))
			{
				dx += GET_X(tree, dobj);
				dy += GET_Y(tree, dobj);
				dobj = get_parent(tree, dobj);
			}
			if (is_menu(tree, dobj) < 2)
				return;
			SET_X(tree, sobj, dx);
			SET_Y(tree, sobj, dy);
			view_objs();
			return;
		default:
			return;
	}
}

VOID size_obj(LONG tree, WORD obj)
{
	LONG	amax, obspec;
	GRECT	p;
	WORD	cobj, pobj, n,type;
	WORD	wlim, hlim, wmax, hmax, wtmp, htmp;

	wlim = gl_wchar;
	hlim = gl_hchar;
	amax = 0L;

	switch (rcs_state)
	{
		case FREE_STATE:
			if (obj != ROOT)
				return;
		case PANL_STATE:
			wlim = hlim = 2;

		case DIAL_STATE:			      
			obspec = OB_SPEC(obj);
			if ( (type = LLOBT(GET_TYPE(tree, obj))) == G_BUTTON )
				wlim = (WORD)LSTRLEN(LLGET(obspec)) * gl_wchar;
			else if (type == G_BOXTEXT || type == G_FBOXTEXT ||
				 type == G_FTEXT)
				wlim = (WORD)LSTRLEN(LLGET(TE_PTEXT(LLGET(obspec)))) 
					*  gl_wchar;
			break;
		case MENU_STATE:
			if ( in_which_menu(tree, obj) == 1  && in_menu(tree, obj) == 1 )
				return;
			if (menu_ok(tree, obj))
				break;
			if ((n = is_menu(tree, obj)) > 1)
			{
				wlim = GET_WIDTH(tree, bar_n(tree, n));
				amax = (LONG) (gl_nrows * gl_hchar) *
					(LONG) (gl_ncols * gl_wchar) / 4L;
				break;
			}
			return;
		default:
			return;
	}

	if (GET_HEAD(tree, obj) != NIL)
		for (cobj = GET_HEAD(tree, obj); cobj != obj; 
			cobj = GET_NEXT(tree, cobj))
		{
			wlim = max(wlim, GET_X(tree, cobj) + 
				GET_WIDTH(tree, cobj));
			hlim = max(hlim, GET_Y(tree, cobj) +
				GET_HEIGHT(tree, cobj));
		}

	obj_redraw(tree, obj);  
	objc_xywh(tree, obj, &p);

	if (obj == ROOT)
	{
		wmax = full.g_w + full.g_x;
		hmax = full.g_h + full.g_y;
	}
	else
	{
		pobj = get_parent(tree, obj);
		if (rcs_state == MENU_STATE)
		if (in_bar(tree, obj))
			pobj = get_parent(tree, pobj);
		objc_offset((OBJECT FAR *)tree, pobj, &wtmp, &htmp);
		wmax = min(view.g_w + view.g_x, wtmp + GET_WIDTH(tree, pobj)); 
		hmax = min(view.g_h + view.g_y, htmp + GET_HEIGHT(tree, pobj)); 
	}
	wmax -= p.g_x;
	hmax -= p.g_y;

	graf_mouse(FINGER, 0x0L); 
	clamp_rubbox(p.g_x, p.g_y, wlim, hlim, wmax, hmax, amax, 
		&p.g_w, &p.g_h, &full);
	graf_mouse(ARROW, 0x0L);

	if (rcs_state != PANL_STATE)
		snap_wh(&p.g_w, &p.g_h);
	SET_WIDTH(tree, obj, p.g_w);
	SET_HEIGHT(tree, obj, p.g_h);

	if (rcs_state == MENU_STATE)	/* Realign bar if necessary */
	if (in_bar(tree, obj))
	{
		fix_menu_bar(tree);
		view_objs();
	}
	else
	{
		if (obj == ROOT)	/* If ROOT resized, then window */
			view_objs();	/* must be rescrolled */
		else
			obj_redraw(tree, pobj); 
		obj_redraw(tree, obj);
	}
}	

VOID slct_obj(LONG tree, WORD obj)
{
	WORD	nbar, type;

	if (rcs_nsel)
		mslct_obj(tree, obj);
	else
	{
		type = LLOBT(GET_TYPE(tree, obj));
		switch (rcs_state)
		{
			case MENU_STATE:
				if (obj == THEACTIVE)
					return;		/* just in case... */
				else
				{
					nbar = in_bar(tree, obj);
					if (nbar)
					{
						if (rcs_menusel)
							hide_obj(tree, rcs_menusel);
						obj_redraw(tree, rcs_menusel);
						unhide_obj(tree, rcs_menusel =
						menu_n(tree, nbar));
						obj_redraw(tree, rcs_menusel);
						break;
					}
					if (in_menu(tree, obj))
						break;
					if (is_menu(tree, obj) > 1)
						break;
					if (rcs_menusel)
					{
						hide_obj(tree, rcs_menusel);
						obj_redraw(tree, rcs_menusel);
						rcs_menusel = FALSE;
					}
					return;
				}
			case ALRT_STATE:
				if (type != G_STRING && type != G_BUTTON)
					return;
				break;
			case FREE_STATE:
			case PANL_STATE:
			case DIAL_STATE:
				break;
			default:
				return;
		}

		rcs_nsel = 1;
		rcs_sel[0] = obj;

		set_menus();
		set_hot();
		set_switch();
		obj_redraw(tree, obj);
	}
}

VOID mslct_obj(LONG tree, WORD obj)
{
	WORD	i;

	if (rcs_state == MENU_STATE)
		if (!in_menu(tree, obj))
		{
			dslct_obj(tree, obj);
			slct_obj(tree, obj);
			return;
		}

	for (i = rcs_nsel; i; )		/* Prevent duplicates */
		if (rcs_sel[--i] == obj)
		{
			dslct_1obj(tree, obj);
			return;
		}

	if (rcs_nsel + 1 < MAXSEL)
	{
		rcs_sel[rcs_nsel++] = obj;

		set_menus();
		set_hot();
		set_switch();
		obj_redraw(tree, obj);
	}
}

VOID dslct_1obj(LONG tree, WORD obj)
{
	WORD	i;

	for (i = rcs_nsel; i; i--)
		if (rcs_sel[i - 1] == obj)
			break;
	if (i)
	{
		for (; i < rcs_nsel; i++)
			rcs_sel[i - 1] = rcs_sel[i];
		rcs_nsel--;
		set_menus();
		set_hot();
		set_switch();
		obj_redraw(tree, obj);
	}
}

VOID map_dslct(LONG tree, WORD obj)
{
	map_tree(tree, obj, GET_NEXT(tree, obj), (fkt_parm)dslct_1obj);
}

VOID dslct_obj(LONG tree, WORD obj)
{
	if (!iconedit_flag)
	{
		for (; rcs_nsel; )
			obj_redraw(ad_view, rcs_sel[--rcs_nsel] );
		set_menus();
		clr_hot();
	}
}

VOID unhid_part(WORD obj)
{
	WORD	iobj;

	for (iobj = GET_HEAD(ad_view, obj); iobj != obj; 
		iobj = GET_NEXT(ad_view, iobj))
		unhide_obj(ad_view, iobj);
	obj_redraw(ad_view, obj);
}

LOCAL WORD less_ob(LONG tree, WORD obj1, WORD obj2, WORD mode)
{
	WORD	x1, y1, x2, y2;

	x1 = GET_X(tree, obj1);
	y1 = GET_Y(tree, obj1);
	x2 = GET_X(tree, obj2);
	y2 = GET_Y(tree, obj2);

	switch (mode)
	{
		case SORTX:
			return (x2 < x1);
		case SORTY:
			return (y2 < y1);
		case SORTXY:
			if (x1 == x2)
				return (y2 < y1);
			else
				return (x2 < x1);
		case SORTYX:
			if (y1 == y2)
				return (x2 < x1);
			else
				return (y2 < y1);
        default:
			return (FALSE);
	}
}

LOCAL VOID sort_tree(LONG tree, WORD pobj, WORD mode)
{
	WORD	i, n, sobj, tobj, obj;

	n = 0;
	for (obj = GET_HEAD(tree, pobj); obj != pobj; 
		obj = GET_NEXT(tree, obj))
		n++;
	if (n != 1)
	{
		for (i = 0; ++i < n; )
		{
			for (tobj = sobj = nth_child(tree, pobj, i);
				tobj != pobj; tobj = GET_NEXT(tree, tobj))
				if (less_ob(tree, sobj, tobj, mode))
					sobj = tobj;
			if (obj != sobj)
				objc_order((OBJECT FAR *)tree, sobj, i - 1);
		}
	}
}

VOID sort_part(WORD obj)
{
	LONG	tree;
	GRECT	p;
	WORD	mode;

	objc_xywh(ad_view, obj, &p);

	ini_tree(&tree, SORTTREE);
	sel_obj(tree, SRTYITEM);

	hndl_dial(tree, 0, &p);

	if (SELECTED & GET_STATE(tree, STOKITEM))
	{
		mode = encode(tree, SRTXITEM, 4);
		sort_tree(ad_view, obj, mode);
	}
	map_tree(tree, ROOT, NIL, (fkt_parm)desel_obj);
}

VOID flatten_part(WORD obj)
{
	LONG	tree;
	WORD	pobj, cobj, nobj;
	WORD	x, y;

	tree = ad_view;
	x = GET_X(ad_view, obj);
	y = GET_Y(ad_view, obj);

	pobj = get_parent(tree, obj);
	dslct_1obj(tree, obj);
	del_objindex(tree, obj);
	objc_delete((OBJECT FAR *)tree, obj);

	for (cobj = GET_HEAD(tree, obj); cobj != obj; cobj = nobj)
	{
		SET_X(tree, cobj, x + GET_X(tree, cobj));
		SET_Y(tree, cobj, y + GET_Y(tree, cobj));
		nobj = GET_NEXT(tree, cobj);
		objc_add((OBJECT FAR *)tree, pobj, cobj);
	}
}
