/*	RCSLIB.C	10/11/84 - 1/25/85 	Tim Oren		*/
/*************************************************************
 * Copyright 1999 by Caldera Thin Clients, Inc.              *
 * This software is licensed under the GNU Public License.   *
 * Please see LICENSE.TXT for further information.           *
 *************************************************************/
#include <ctype.h>
#include <stdio.h>
#include <portab.h>
#include <machine.h>
#include <rclib.h>
#if GEMDOS
#include <tos.h>
#include <aes.h>
#include <vdi.h>
#else
#include <obdefs.h>
#include <gembind.h>
#endif
#include "rcsdefs.h"
#include "rcsvdi.h"
#include "rcslib.h"

EXTERN	MFDB	gl_dst;

VOID set_slsize(WORD w_handle, WORD h_size, WORD v_size)
{
	WORD	cur_size, foo;

	wind_get(w_handle, WF_HSLSIZE, &cur_size, &foo, &foo, &foo);
	if (cur_size != h_size)
		wind_set(w_handle, WF_HSLSIZE, h_size, 0, 0, 0);
	wind_get(w_handle, WF_VSLSIZE, &cur_size, &foo, &foo, &foo);
	if (cur_size != v_size)
		wind_set(w_handle, WF_VSLSIZE, v_size, 0, 0, 0);
}	

VOID set_slpos(WORD w_handle, WORD h_pos, WORD v_pos)
{
	WORD	cur_pos, foo;

	wind_get(w_handle, WF_HSLIDE, &cur_pos, &foo, &foo, &foo);
	if (cur_pos != h_pos)
		wind_set(w_handle, WF_HSLIDE, h_pos, 0, 0, 0);
	wind_get(w_handle, WF_VSLIDE, &cur_pos, &foo, &foo, &foo);
	if (cur_pos != v_pos)
		wind_set(w_handle, WF_VSLIDE, v_pos, 0, 0, 0);
}

WORD ini_tree(LONG *tree, WORD which)	/* find tree address */
{
	return ( rsrc_gaddr(R_TREE, which, tree) );
}

LONG image_addr(WORD which)
{
	LONG	where;

	rsrc_gaddr(R_IMAGEDATA, which, &where);
	return (where);
} 

LONG string_addr(WORD which)
{
	LONG	where;

	rsrc_gaddr(R_STRING, which, &where);
	return (where);
} 

VOID arrange_tree(LONG tree, WORD wint, WORD hint,WORD *maxw, WORD *maxh)
{
	WORD	obj, x, y, rowh, wroot;

	wroot = GET_WIDTH(tree, ROOT);
	if ( wroot )
	{
		x = wint;
		y = hint;
		rowh = 0;
		*maxw = 0;

		for (obj = GET_HEAD(tree, ROOT); obj != ROOT; 
			obj = GET_NEXT(tree, obj))
		{
			if (rowh && (x + GET_WIDTH(tree, obj)) > wroot)
			{
				x = wint;
				y += (rowh + hint);
				rowh = 0;
			}
			SET_X(tree, obj, x);
			SET_Y(tree, obj, y);
			if ( !(GET_FLAGS(tree, obj) & HIDETREE) )
			{
				x += (GET_WIDTH(tree, obj) + wint); 
				*maxw = max(*maxw, x);
				rowh = max(rowh, GET_HEIGHT(tree, obj));
			}
		}
		*maxh = y + rowh + hint;
	}
}

/*
*	Routine that will find the parent of a given object.  The
*	idea is to walk to the end of our siblings and return
*	our parent.  If object is the root then return NIL as parent.
*/
WORD get_parent(LONG tree, WORD obj)
{
	WORD		pobj;

	if (obj == NIL)
		return (NIL);
	else
	{
		pobj = GET_NEXT(tree, obj);
		if (pobj != NIL)
		{
			while( GET_TAIL(tree, pobj) != obj ) 
			{
				obj = pobj;
				pobj = GET_NEXT(tree, obj);
			}
		}
		return(pobj);
	}
} /* get_parent */

WORD nth_child(LONG tree, WORD nobj, WORD n)
{
	for (nobj = GET_HEAD(tree, nobj); --n; nobj = GET_NEXT(tree, nobj))
		;
	return (nobj);
}

WORD child_of(LONG tree, WORD nobj, WORD obj)
{
	WORD	nbar;

	nobj = GET_HEAD(tree, nobj);
	for (nbar = 1; nobj != obj; nbar++)
		nobj = GET_NEXT(tree, nobj);
	return (nbar);
}

VOID table_code(LONG tree, WORD obj0, WORD *types, WORD ntypes, WORD type)
{
	WORD	itype;

	for (itype = 0; itype < ntypes; itype++)
		if (type == types[itype])
		{
			sel_obj(tree, obj0 + itype);
			return;
		}
}

WORD encode(LONG tree, WORD ob1st, WORD num)
{
	for (; num--; )
		if (GET_STATE(tree, ob1st+num) & SELECTED)
			return(num);
	return (0);
}

VOID map_tree(LONG tree, WORD this, WORD last, fkt_parm routine)
{
	WORD		tmp1;

	/* non-recursive tree traversal */
child:
	/* see if we need to to stop */
	if (this == last)
		return;
	/* do this object */
	(*routine)(tree, this);
	/* if this guy has kids then do them */
	tmp1 = GET_HEAD(tree, this);
	if ( tmp1 != NIL )
	{
		this = tmp1;
		goto child;
	}

sibling:
	/* if this obj. has a	*/
	/*   sibling that is not*/
	/*   his parent, then	*/
	/*   move to him and do	*/
	/*   him and his kids	*/
	tmp1 = GET_NEXT(tree, this);
	if ( (tmp1 == last) || (tmp1 == NIL) )
		return;
	if ( GET_TAIL(tree, tmp1) != this )
	{
		this = tmp1;
		goto child;
	}
	/* if this is the root	*/
	/*   which has no parent*/
	/*   then stop else 	*/
	/*   move up to the	*/
	/*   parent and finish	*/
	/*   off his siblings	*/ 
	this = tmp1;
	goto sibling;
}

VOID snap_xy(WORD *x, WORD *y)
{
	*x += gl_wchar / 2;	
	*y += gl_hchar / 2;
	*x -= *x % gl_wchar;
	*y -= *y % gl_hchar;
}

VOID snap_wh(WORD *w, WORD *h)
{
	*w += gl_wchar / 2;
	*h += gl_hchar / 2;
	*w = max(*w - *w % gl_wchar, gl_wchar);
	*h = max(*h - *h % gl_hchar, gl_hchar);
}

VOID text_wh(LONG taddr, WORD type, WORD *w, WORD *h)
{
	WORD	font;

	font = LWGET(TE_FONT(taddr));
	taddr = LLGET( (type == G_TEXT || type == G_BOXTEXT)? TE_PTEXT(taddr): TE_PTMPLT(taddr) );
	*h = ch_height(font);
	*w = ch_width(font) * (WORD)LSTRLEN(taddr);
}

VOID icon_wh(LONG taddr, WORD *w, WORD *h)
{
	ICONBLK	here;
	GRECT	p;

	LBCOPY(ADDR(&here), taddr, sizeof(ICONBLK));
	rc_copy((GRECT *) &here.ib_xchar, &p);
	rc_union((GRECT *) &here.ib_xicon, &p);
	rc_union((GRECT *) &here.ib_xtext, &p);
	*w = p.g_x + p.g_w;
	*h = p.g_y + p.g_h;
}

VOID icon_tfix(LONG taddr)
{
	WORD	dw;

	dw = (LWGET(IB_WICON(taddr)) - LWGET(IB_WTEXT(taddr))) / 2;
	LWSET(IB_XICON(taddr), (dw<0)? -dw: 0);
	LWSET(IB_XTEXT(taddr), (dw<0)? 0: dw);
}

VOID trans_bitblk(LONG obspec)
{
	LONG	taddr;
	WORD	wb, hl;

	if ( (taddr = LLGET(BI_PDATA(obspec))) != -1L)
	{
		wb = LWGET(BI_WB(obspec));
		hl = LWGET(BI_HL(obspec));
		gsx_trans(taddr, wb, taddr, wb, hl);
	}
}

VOID rast_op(WORD mode, GRECT *s_area, MFDB *s_mfdb, GRECT *d_area, MFDB *d_mfdb)
{
	WORD	pxy[8];

	grect_to_array(s_area, pxy);
	grect_to_array(d_area, &pxy[4]);
	vro_cpyfm( gl_handle, mode, pxy, s_mfdb, d_mfdb);
}

VOID outl_obj(LONG tree, WORD obj, GRECT *clprect)
{
	GRECT	p;

	objc_xywh(tree, obj, &p);
	rc_intersect( clprect, &p);
	graf_mouse(M_OFF, NULL);
	gsx_outline(&p);
	graf_mouse(M_ON, NULL);
}

VOID invert_obj(LONG tree, WORD obj, GRECT *clprect)
{
	GRECT	hot;

	objc_xywh(tree, obj, &hot);
	rc_intersect( clprect, &hot );
	graf_mouse(M_OFF, NULL);
	gsx_invert(&hot);
	graf_mouse(M_ON, NULL);
	if (iconedit_flag)
	{
		if (LWGET(OB_STATE(obj)) == SELECTED)
		    LWSET(OB_STATE(obj), NORMAL);
		else
		    LWSET(OB_STATE(obj), SELECTED);
	}
}

VOID trans_obj(LONG tree, WORD obj)
{
	WORD	type, wb, hl;
	LONG	taddr, obspec;

	type = LLOBT(GET_TYPE(tree, obj));
	if ( (obspec = GET_SPEC(tree, obj)) != -1L)
	{
		switch (type)
		{
			case G_IMAGE:
				trans_bitblk(obspec);
				break;
			case G_ICON:
				hl = LWGET(IB_HICON(obspec));
				wb = (LWGET(IB_WICON(obspec)) + 7) >> 3;
				if ( (taddr = LLGET(IB_PDATA(obspec))) != -1L)
					gsx_trans(taddr, wb, taddr, wb, hl);
				if ( (taddr = LLGET(IB_PMASK(obspec))) != -1L)
					gsx_trans(taddr, wb, taddr, wb, hl);
				break;
			default:
				break;
		}
	}
}

VOID unfix_chpos(LONG where, WORD x_or_y)
{
	WORD	cpos, coff, cbits;

	cpos = LWGET(where);
	coff = cpos / (x_or_y? gl_hchar: gl_wchar);
	cbits = cpos % (x_or_y? gl_hchar: gl_wchar);
	LWSET(where, coff | (cbits << 8));
}

LOCAL VOID fix_chpos(LONG pfix, WORD ifx)
{
	WORD	coffset;
	WORD	cpos;

	cpos = LWGET(pfix);
	coffset = (WORD) LHIBT(cpos) & 0xff;	/* Alcyon bug ! */
	cpos = (WORD) LLOBT(cpos) & 0xff;
	if (ifx)
		cpos *= gl_wchar;
	else
		cpos *= gl_hchar;
	if ( coffset > 128 )			/* crude	*/
		cpos -= (256 - coffset);
	else
		cpos += coffset;
	LWSET(pfix, cpos);
}

VOID rs_obfix(LONG tree, WORD curob)
{
	WORD		i, val;
	LONG		p;

	/* set X,Y,W,H with	*/
	/*   fixch, use val	*/
	/*   to alternate TRUEs	*/
	/*   and FALSEs		*/
	p = OB_X(curob);

	val = TRUE;
	for (i=0; i<4; i++)
	{
		fix_chpos(p+(LONG)(2*i), val);
		val = !val;
	}
}

LOCAL VOID undo_obj(LONG tree, WORD which, WORD bit)
{
	WORD	state;

	state = GET_STATE(tree, which);
	SET_STATE(tree, which, state & ~bit);
}

LOCAL VOID do_obj(LONG tree, WORD which, WORD bit)
{
	WORD	state;

	state = GET_STATE(tree, which);
	SET_STATE(tree, which, state | bit);
}

VOID enab_obj(LONG tree, WORD which)
{
	undo_obj(tree, which, DISABLED);
}

VOID disab_obj(LONG tree, WORD which)
{
	do_obj(tree, which, DISABLED);
}

VOID sel_obj(LONG tree, WORD which)
{
	do_obj(tree, which, SELECTED);
}

VOID desel_obj(LONG tree, WORD which)
{
	undo_obj(tree, which, SELECTED);
}

VOID chek_obj(LONG tree, WORD which)
{
	do_obj(tree, which, CHECKED);
}

VOID unchek_obj(LONG tree, WORD which)
{
	undo_obj(tree, which, CHECKED);
}

LOCAL VOID unflag_obj(LONG tree, WORD which, WORD bit)
{
	WORD	flags;

	flags = GET_FLAGS(tree, which);
	SET_FLAGS(tree, which, flags & ~bit);
}

LOCAL VOID flag_obj(LONG tree, WORD which, WORD bit)
{
	WORD	flags;

	flags = GET_FLAGS(tree, which);
	SET_FLAGS(tree, which, flags | bit);
}

VOID hide_obj(LONG tree, WORD which)
{
	flag_obj(tree, which, HIDETREE);
}

VOID unhide_obj(LONG tree, WORD which)
{
	unflag_obj(tree, which, HIDETREE);
}

LOCAL VOID indir_obj(LONG tree, WORD which)
{
	flag_obj(tree, which, INDIRECT);
}

LOCAL VOID dir_obj(LONG tree, WORD which)
{
	unflag_obj(tree, which, INDIRECT);
}

VOID sble_obj(LONG tree, WORD which)
{
	flag_obj(tree, which, SELECTABLE);
}

VOID unsble_obj(LONG tree, WORD which)
{
	unflag_obj(tree, which, SELECTABLE);
}

VOID objc_xywh(LONG tree, WORD obj, GRECT *p)
{
	objc_offset((OBJECT FAR *)tree, obj, &p->g_x, &p->g_y);
	p->g_w = GET_WIDTH(tree, obj);
	p->g_h = GET_HEIGHT(tree, obj);
}

VOID ob_setxywh(LONG tree, WORD obj, GRECT *pt)
{
	LWCOPY(OB_X(obj), ADDR(pt), sizeof(GRECT)/2);
}

VOID ob_relxywh(LONG tree, WORD obj, GRECT *pt)
{
	LWCOPY(ADDR(pt), OB_X(obj), sizeof(GRECT)/2);
}

WORD min(WORD a, WORD b)
{
	return( (a < b) ? a : b );
}

WORD max(WORD a, WORD b)
{
	return( (a > b) ? a : b );
}

VOID strup(BYTE *p1)
{
	for(; *p1; p1++)
		*p1 = toupper(*p1);
}

VOID LLSTRCPY(LONG src, LONG dest)
{
	BYTE	b;

	do {
		b = LBGET(src++);
		LBSET(dest++, b);
	} while (b);
}

WORD LLSTRCMP(LONG l1, LONG l2)
{
	BYTE	b;

	b = LBGET(l1++);
	while (b)
	{
		if (b != LBGET(l2++))
			return (FALSE);
		else
			b = LBGET(l1++);
	}
	return (!LBGET(l2));
}

VOID LWINC(LONG x)
{
	LWSET(x, 1 + LWGET(x));
}

WORD dmcopy(FILE *stream, LONG msrc, LONG mdest, WORD mln)	/* disk to memory copy */
{
	if (fseek(stream, msrc, SEEK_SET))
		return( 0 );
	else if ( fread( (void *)mdest, 1, mln, stream) < mln)
		return( 0 );
	else
		return(mln);
} /* dmcopy */

LOCAL LONG obj_addr(LONG tree, WORD obj, WORD offset)
{
	return (tree + (UWORD) (obj * sizeof(OBJECT) + offset));
}

WORD GET_NEXT(LONG tree, WORD x)
{
	return LWGET(obj_addr(tree, x, 0));
}

WORD GET_HEAD(LONG tree, WORD x)
{
	return LWGET(obj_addr(tree, x, 2));
}

WORD GET_TAIL(LONG tree, WORD x)
{
	return LWGET(obj_addr(tree, x, 4));
}

WORD GET_TYPE(LONG tree, WORD x)
{
	return LWGET(obj_addr(tree, x, 6));
}

WORD GET_FLAGS(LONG tree, WORD x)
{
	return LWGET(obj_addr(tree, x, 8));
}

WORD GET_STATE(LONG tree, WORD x)
{
	return LWGET(obj_addr(tree, x, 10));
}

LONG GET_SPEC(LONG tree, WORD x)
{
	return LLGET(obj_addr(tree, x, 12));
}

WORD GET_X(LONG tree, WORD x)
{
	return LWGET(obj_addr(tree, x, 16));
}

WORD GET_Y(LONG tree, WORD x)
{
	return LWGET(obj_addr(tree, x, 18));
}

WORD GET_WIDTH(LONG tree, WORD x)
{
	return LWGET(obj_addr(tree, x, 20));
}

WORD GET_HEIGHT(LONG tree, WORD x)
{
	return LWGET(obj_addr(tree, x, 22));
}

VOID SET_NEXT(LONG tree, WORD x, WORD val)
{
	LWSET(obj_addr(tree, x, 0), val);
}

VOID SET_HEAD(LONG tree, WORD x, WORD val)
{
	LWSET(obj_addr(tree, x, 2), val);
}

VOID SET_TAIL(LONG tree, WORD x, WORD val)
{
	LWSET(obj_addr(tree, x, 4), val);
}

LOCAL VOID SET_TYPE(LONG tree, WORD x, WORD val)
{
	LWSET(obj_addr(tree, x, 6), val);
}

VOID SET_FLAGS(LONG tree, WORD x, WORD val)
{
	LWSET(obj_addr(tree, x, 8), val);
}

VOID SET_STATE(LONG tree, WORD x, WORD val)
{
	LWSET(obj_addr(tree, x, 10), val);
}

VOID SET_SPEC(LONG tree, WORD x, LONG val)
{
	LLSET(obj_addr(tree, x, 12), val);
}

VOID SET_X(LONG tree, WORD x, WORD val)
{
	LWSET(obj_addr(tree, x, 16), val);
}

VOID SET_Y(LONG tree, WORD x, WORD val)
{
	LWSET(obj_addr(tree, x, 18), val);
}

VOID SET_WIDTH(LONG tree, WORD x, WORD val)
{
	LWSET(obj_addr(tree, x, 20), val);
}

VOID SET_HEIGHT(LONG tree, WORD x, WORD val)
{
	LWSET(obj_addr(tree, x, 22), val);
}
