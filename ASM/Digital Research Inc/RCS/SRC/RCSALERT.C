/*	RCSALERT.C	 1/17/85 - 1/17/85	Tim Oren		*/
/*************************************************************
 * Copyright 1999 by Caldera Thin Clients, Inc.              *
 * This software is licensed under the GNU Public License.   *
 * Please see LICENSE.TXT for further information.           *
 *************************************************************/
#include <portab.h>
#include <machine.h>
#include <rclib.h>
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
#include "rcsalert.h"

VOID pt_parse(LONG tree, WORD obj0, WORD nobj, LONG where, WORD *here)
{
	WORD	iobj;
	BYTE	tmp;

	tmp = NULL;
	for (iobj = 0; tmp != ']' && iobj < nobj; iobj++)
	{
		SET_SPEC(tree, obj0 + iobj, where + *here);
		tmp = LBGET(where + *here);
		while (tmp != ']' && tmp != '|')
		{
			*here += 1;
			tmp = LBGET(where + *here);
		}
		LBSET(where + *here, '\0');
		*here += 1;
	}
}

VOID parse_alert(LONG tree, LONG where)
{
	LONG	stree, obspec;
	WORD	icon, curr_id;

	icon = LBGET(where + 1) - '0';
	if (icon < 1 || icon > 3)
		obspec = -1L;
	else
	{
		ini_tree(&stree, ALRTPBX);
		obspec = GET_SPEC(stree, APBXIMG0 + icon - 1);
	}
	SET_SPEC(tree, ALRTIMG, obspec);
	curr_id = 4;
	pt_parse(tree, ALRTSTR0, 5, where, &curr_id);
	curr_id++;
	pt_parse(tree, ALRTBTN0, 3, where, &curr_id);
}

WORD is_alert(LONG where)
{
	return (LBGET(where) == '[' && LBGET(where + 2) == ']');
}

VOID comp_alerts(LONG hdr)
{
	LONG	frstr, trindex, where, tree, maddr;
	WORD	nalert, nfrstr, istr, ndex;
	BYTE	name[9];

	ini_tree(&maddr, NEWALRT);
	frstr = hdr + LW( LWGET(RSH_FRSTR(hdr)) );
	nfrstr = LWGET(RSH_NSTRING(hdr));
	for (nalert = istr = 0; istr < nfrstr; istr++)
	{
		where = LLGET(frstr + (UWORD) (istr * sizeof(LONG)));
		if (is_alert(where))
			nalert++;
	}
	if (nalert)
	{
		trindex = mak_trindex(nalert);

		for (istr = 0; istr < LWGET(RSH_NSTRING(hdr)); istr++)
		{
			where = LLGET(frstr + (UWORD) (istr * sizeof(LONG)));
			if (is_alert(where))
			{
				tree = copy_tree(maddr, ROOT, TRUE);
				parse_alert(tree, where);
				LLSET(frstr + (UWORD) (istr * sizeof(LONG)), -1L);
				fix_alert(tree);
				LLSET(trindex, tree);
				trindex += (UWORD) sizeof(LONG);
				if ((ndex = find_value((BYTE *) where)) != NIL)
					set_value(ndex, (BYTE *) tree);
				else
				{
					unique_name(&name[0], "ALERT%hd", istr);
					ndex = new_index((BYTE *) tree, ALRT, name);
				}
			}
		}
		if (nalert == LWGET(RSH_NSTRING(hdr)))
			LWSET(RSH_NSTRING(hdr), 0);
	} 
}

VOID pt_unparse(LONG tree, WORD obj0, WORD nobj, LONG where, WORD *here)
{
	LONG	obspec;
	WORD	iobj, lstr;

	LBSET(where + *here, '[');
	*here += 1;
	for (iobj = 0; iobj < nobj; iobj++)
	{
		if ( (obspec = GET_SPEC(tree, obj0 + iobj)) == -1L)
			break;
		else
		{
			lstr = (WORD)LSTRLEN(obspec);
			if ( !lstr )
				break;
			else
			{
				if (iobj)
				{
					LBSET(where + *here, '|');
					*here += 1;
				}
				LLSTRCPY(obspec, where + *here);
				*here += lstr;
			}
		}
	}
	LBSET(where + *here, ']');
	*here += 1;
}

VOID unparse_alert(LONG tree, LONG where)
{
	LONG	stree, obspec;
	WORD	picnum, here;

	obspec = GET_SPEC(tree, ALRTIMG);
	if (obspec == -1L)
		picnum = 0;
	else
	{
		ini_tree(&stree, ALRTPBX);
		for (picnum = 2; picnum >= 0; picnum--)
			if (obspec == GET_SPEC(stree, APBXIMG0 + picnum))
				break;
		picnum++;
	}
	LBSET(where, '[');
	LBSET(where + 1, '0' + (BYTE) picnum);
	LBSET(where + 2, ']');
	here = 3;
	pt_unparse(tree, ALRTSTR0, 5, where, &here);
	pt_unparse(tree, ALRTBTN0, 3, where, &here);
	LBSET(where + here, '\0');
	get_mem(here + 1);
}

VOID dcomp_alerts(VOID)
{
	LONG	frstr, where, tree;
	WORD	nalert, ntrind, nfrstr, itree, ntree, ndex;

	ntrind = LWGET(RSH_NTREE(head));
	for (nalert = itree = 0; itree < ntrind; itree++)
	{
		ndex = find_value((BYTE *) tree_addr(itree));
		if (ndex != NIL && get_kind(ndex) == ALRT)
			nalert++;
	}

	if (nalert)
	{
		nfrstr = LWGET(RSH_NSTRING(head));
		frstr = mak_frstr(nalert);

		for (ntree = itree = 0; itree < ntrind; itree++)
		{
			tree = tree_addr(itree);
			ndex = find_value((BYTE *) tree);
			if (ndex == NIL || get_kind(ndex) != ALRT)
			{
				if (ntree != itree)
					LLSET(tree_ptr(ntree), tree_addr(itree));
				ntree++;
			}
			else
			{
				where = get_mem(0);
				unparse_alert(tree, where);
				LLSET(frstr, where);
				frstr += (UWORD) sizeof(LONG);
				set_value(ndex, (BYTE *) nfrstr++);
			}
		}
		LWSET(RSH_NTREE(head), ntree);
	}
}

WORD pt_roomp(LONG tree, WORD obj0, WORD nobj)
{
	WORD	iobj;
	LONG	taddr;

	for (iobj = 0; iobj < nobj; iobj++)
	{
		taddr = GET_SPEC(tree, obj0 + iobj);
		if (taddr == -1L)
			return (obj0 + iobj);
		else if (!LSTRLEN(taddr))
			return (obj0 + iobj);
	}
	return (0);
} 

VOID pt_count(LONG tree, WORD obj0, WORD nobj, WORD *n, WORD *mxl)
{
	LONG	taddr;
	WORD	iobj, slen;

	*n = *mxl = 0;
	for (iobj = 0; iobj < nobj; iobj++)
	{
		taddr = GET_SPEC(tree, obj0 + iobj);
		if (taddr != -1L)
		{
			slen = (WORD)LSTRLEN(taddr);
			if (slen)
			{
				if (*n != iobj)
				{
					SET_SPEC(tree, obj0 + *n, taddr);
					SET_SPEC(tree, obj0 + iobj, -1L);
				}
				*n += 1;
				*mxl = max(*mxl, slen);
			}
		}
		hide_obj(tree, obj0 + iobj);
	}
}

VOID al_count(LONG tree, WORD *pic, WORD *nmsg, WORD *mxlmsg, WORD *nbut, WORD *mxlbut)
{
	*pic = (GET_SPEC(tree, ALRTIMG) != -1L);
	hide_obj(tree, ALRTIMG);
	pt_count(tree, ALRTSTR0, 5, nmsg, mxlmsg);
	pt_count(tree, ALRTBTN0, 3, nbut, mxlbut);
} 

VOID al_space(LONG tree, WORD haveicon, WORD nummsg, WORD mlenmsg, WORD numbut, WORD mlenbut)
{
	WORD		i;
	GRECT		al, ic, bt, ms;

	rc_set(&al, 0, 0, 1+INTER_WSPACE, 1+INTER_HSPACE);
	rc_set(&ms, 1 + INTER_WSPACE, 1 + INTER_HSPACE, mlenmsg, 1);

	if (haveicon)
	{
		rc_set(&ic, 1+INTER_WSPACE, 1+INTER_HSPACE, 4, 4);
		al.g_w += ic.g_w + INTER_WSPACE;
		al.g_h += ic.g_h + INTER_HSPACE + 1;
		ms.g_x = ic.g_x + ic.g_w + INTER_WSPACE;
	}

	al.g_w += ms.g_w + INTER_WSPACE + 1;
	rc_set(&bt, al.g_w, 1 + INTER_HSPACE, mlenbut, 1);

	al.g_w += bt.g_w + INTER_WSPACE + 1;
	al.g_h = max(al.g_h, 2 + (2 * INTER_HSPACE) + nummsg );
	al.g_h = max(al.g_h, 2 + INTER_HSPACE + (numbut * 2) - 1);
	ob_setxywh(tree, ROOT, &al);		/* init. root object	*/
						/* add icon object	*/
	if (haveicon)
	{
		ob_setxywh(tree, 1, &ic);
		unhide_obj(tree, ALRTIMG);
	}
	/* add msg objects	*/
	for(i=0; i<nummsg; i++)
	{
		ob_setxywh(tree, ALRTSTR0+i, &ms);
		ms.g_y++;
		unhide_obj(tree, ALRTSTR0+i);
	}
	/* add button objects	*/
	for(i=0; i<numbut; i++)
	{
		SET_FLAGS(tree, ALRTBTN0 + i, SELECTABLE | EXIT);
		SET_STATE(tree, ALRTBTN0 + i, NORMAL);
		ob_setxywh(tree, ALRTBTN0+i, &bt);
		bt.g_y += 2;
	}
	/* set last object flag	*/
	SET_FLAGS(tree, ALRTBTN0 + numbut - 1, SELECTABLE | EXIT | LASTOB);
}

VOID fix_alert(LONG tree)
{
	WORD	pic, pnummsg, plenmsg, pnumbut, plenbut;

	al_count(tree, &pic, &pnummsg, &plenmsg, &pnumbut, &plenbut);
	al_space(tree, pic, pnummsg, plenmsg, pnumbut, plenbut);
	map_tree(tree, ROOT, NIL, (fkt_parm)rs_obfix);
	SET_X(tree, ROOT, view.g_x);
	SET_Y(tree, ROOT, view.g_y);
}
