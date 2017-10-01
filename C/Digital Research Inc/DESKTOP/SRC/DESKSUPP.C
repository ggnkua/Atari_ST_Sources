/*	DESKSUPP.C	05/04/84 - 06/20/85	Lee Lorenzen		*/
/*	for 3.0 (xm)	3/12/86	 - 01/17/87	MDF			*/
/*	for 3.0			11/13/87		mdf		*/

/*
*       Copyright 1999, Caldera Thin Clients, Inc.                      
*       This software is licenced under the GNU Public License.         
*       Please see LICENSE.TXT for further information.                 
*                                                                       
*                  Historical Copyright                                 
*	-------------------------------------------------------------
*	GEM Desktop					  Version 3.0
*	Serial No.  XXXX-0000-654321		  All Rights Reserved
*	Copyright (C) 1987			Digital Research Inc.
*	-------------------------------------------------------------
*/

#include <stddef.h>
#include <portab.h>
#include <machine.h>
#include <rclib.h>
#if GEMDOS
#include <stdlib.h>
#include <string.h>
#if TURBO_C
#include <aes.h>
#include <tos_intr.h>
#endif
#else
#include <obdefs.h>
#include <gembind.h>
#include <dos.h>
#endif
#include "taddr.h"
#include "desktop.h"
#include "deskapp.h"
#include "deskfpd.h"
#include "deskwin.h"
#include "deskfun.h"
#include "deskinf.h"
#include "deskbind.h"
#include "deskpro.h"
#include "deskrsrc.h"
#include "deskact.h"
#include "deskmain.h"
#include "optimize.h"
#include "desksupp.h"

EXTERN WORD	DOS_ERR;
EXTERN WORD	DOS_AX;
EXTERN WORD	gl_hbox;
EXTERN WORD	gl_whsiztop;
EXTERN GRECT	gl_rfull;
EXTERN GRECT	gl_normwin;

#if MULTIAPP
EXTERN WORD	pr_kbytes;
EXTERN LONG	pr_ssize;
EXTERN LONG	pr_topdsk;
EXTERN LONG	pr_topmem;
EXTERN WORD	gl_keepac;
#endif

EXTERN GLOBES	G;

#define max(x,y) ((x)>(y)?(x):(y))

/* Clear out the selections for this particular window */
VOID desk_clear(WORD wh)
{
	WNODE	*pw;
	GRECT	c;

	/* get current size	*/
	wind_get(wh, WF_WORKXYWH, &c.g_x, &c.g_y, &c.g_w, &c.g_h);
	/* find its tree of items */
	pw = win_find(wh);
	if (pw)
	{
		/* clear all selections	*/
		act_allchg(wh, G.a_screen, pw->w_root, 0, &gl_rfull, &c,
			SELECTED, FALSE, TRUE);
	}
}

/* Verify window display by building a new view. */
VOID desk_verify(WORD wh, WORD changed)
{
	WNODE	*pw;
	WORD	xc, yc, wc, hc;

	/* get current size	*/
	pw = win_find(wh);
	if (pw)
	{
		if (changed)
		{
			wind_get(wh, WF_WORKXYWH, &xc, &yc, &wc, &hc);
			win_bldview(pw, xc, yc, wc, hc);
		}
		G.g_croot = pw->w_root;
	}
	G.g_cwin = wh;
	G.g_wlastsel = wh;
}

WORD do_wredraw(WORD w_handle, WORD xc, WORD yc, WORD wc, WORD hc)
{
	GRECT	clip_r, t;
	WNODE	*pw;
	LONG	tree;
	WORD	root;

	clip_r.g_x = xc;
	clip_r.g_y = yc;
	clip_r.g_w = wc;
	clip_r.g_h = hc;
	if (w_handle == 0)
		return( TRUE );
	else
	{
		pw = win_find(w_handle);
		tree = G.a_screen;
		root = pw->w_root;

		graf_mouse(M_OFF, NULL);

		wind_get(w_handle, WF_FIRSTXYWH, &t.g_x, &t.g_y, &t.g_w, &t.g_h);
		while ( t.g_w && t.g_h )
		{
			if ( rc_intersect(&clip_r, &t) )
				objc_draw((OBJECT FAR *)tree, root, MAX_DEPTH, t.g_x, t.g_y, t.g_w, t.g_h);
			wind_get(w_handle, WF_NEXTXYWH, &t.g_x, &t.g_y, &t.g_w, &t.g_h);
		}
		graf_mouse(M_ON, 0x0L);
		return( TRUE );
	}
}

/* Picks ob_x, ob_y, ob_width, ob_height fields out of object list. */
VOID get_xywh(OBJECT olist[], WORD obj, WORD *px, WORD *py, WORD *pw, WORD *ph)
{
	*px = olist[obj].ob_x;
	*py = olist[obj].ob_y;
	*pw = olist[obj].ob_width;
	*ph = olist[obj].ob_height;
}

/* Picks ob_spec field out of object list. */
ICONBLK  *get_spec(OBJECT olist[], WORD obj)
{
#if TURBO_C
	return( olist[obj].ob_spec.iconblk );
#else
	return( olist[obj].ob_spec );
#endif
}

VOID do_xyfix(WORD *px, WORD *py)
{
	WORD	tx, ty, tw, th;

	wind_get(0, WF_WORKXYWH, &tx, &ty, &tw, &th);
	tx = *px;
	*px = (tx & 0x000f);
	if ( *px < 8 )
		*px = tx & 0xfff0;
	else
		*px = (tx & 0xfff0) + 16;
	*py = max(*py, ty);
}

VOID do_wopen(WORD new_win, WORD wh, WORD curr, WORD x, WORD y, WORD w, WORD h)
{
	GRECT	c;

	do_xyfix(&x, &y);
	get_xywh(G.g_screen, G.g_croot, &c.g_x, &c.g_y, &c.g_w, &c.g_h);
	act_chg(G.g_cwin, G.a_screen, G.g_croot, curr, &c, SELECTED, 
		FALSE, TRUE, TRUE);
	if (new_win)
		wind_open(wh, x, y, w, h);
	G.g_wlastsel = wh;
}

VOID do_wfull(WORD wh)
{
	WORD	tmp_wh, y;
	GRECT	curr, prev, full, temp;

	gl_whsiztop = NIL;
	wind_get(wh, WF_CURRXYWH, &curr.g_x, &curr.g_y, &curr.g_w, &curr.g_h);
	wind_get(wh, WF_PREVXYWH, &prev.g_x, &prev.g_y, &prev.g_w, &prev.g_h);
	wind_get(wh, WF_FULLXYWH, &full.g_x, &full.g_y, &full.g_w, &full.g_h);
	/* have to check for shrinking a window that */
	/* was full when Desktop was first started. */
	if ( (rc_equal(&curr, &prev)) && (curr.g_h > gl_normwin.g_h) )
	{
		/* shrink full window */
		/* find the other window (assuming only 2 windows) */
		if ( G.g_wlist[0].w_id == wh)
			tmp_wh = G.g_wlist[1].w_id;
		else
			tmp_wh = G.g_wlist[0].w_id;
		/* decide which window we're shrinking */
		wind_get(tmp_wh, WF_CURRXYWH, &temp.g_x, &temp.g_y,
			&temp.g_w, &temp.g_h);
		if (temp.g_y > gl_normwin.g_y)
			y = gl_normwin.g_y;	/* shrinking upper window */
		else	/* shrinking lower window */
			y = gl_normwin.g_y + gl_normwin.g_h + (gl_hbox / 2);
		wind_set(wh, WF_CURRXYWH, gl_normwin.g_x, y,
			gl_normwin.g_w, gl_normwin.g_h);
	} /* if */
	else if ( rc_equal(&curr, &full) )
		/* already full, so change back to previous */
		wind_set(wh, WF_CURRXYWH, prev.g_x, prev.g_y, prev.g_w, prev.g_h);
	else
	{
		/* make it full */
		gl_whsiztop = wh;
		wind_set(wh, WF_TOP, full.g_x, full.g_y, full.g_w, full.g_h);
		wind_set(wh, WF_CURRXYWH, full.g_x, full.g_y, full.g_w, full.g_h);
	}
} /* do_wfull */

/* Open a directory, it may be the root or a subdirectory. */
WORD do_diropen(WNODE *pw, WORD new_win, WORD curr_icon, WORD drv,
	BYTE *ppath, BYTE *pname, BYTE *pext, GRECT *pt, WORD redraw)
{
	WORD	ret;
	PNODE	*tmp;

	/* convert to hourglass	*/
	graf_mouse(HOURGLASS, 0x0L);
	/* open a path node	*/
#if GEMDOS
	tmp = pn_open(drv, ppath, pname, pext, FA_SUBDIR);
#else
	tmp = pn_open(drv, ppath, pname, pext, F_SUBDIR);
#endif
	if ( tmp == NULL)
	{
		graf_mouse(ARROW, 0x0L);
		return(FALSE);
	}
	else
	{
		pw->w_path = tmp;
		/* activate path by search and sort of directory */
		ret = pn_active(pw->w_path);
		if ( ret != E_NOFILES )
		{
			/* some error condition	*/
		}
		/* set new name and info lines for window */
		win_sname(pw);
		wind_set(pw->w_id, WF_NAME, ADDR(&pw->w_name[0]), 0, 0);

		/* do actual wind_open */
		do_wopen(new_win, pw->w_id, curr_icon, 
			pt->g_x, pt->g_y, pt->g_w, pt->g_h);
		if (new_win)
			win_top(pw);
		/* verify contents of windows object list */
		/* by building view and make it curr. */
		desk_verify(pw->w_id, TRUE);
		/* make it redraw */
		if (redraw && ( !new_win ))
			fun_msg(WM_REDRAW, pw->w_id, pt->g_x, pt->g_y, pt->g_w, pt->g_h);

		graf_mouse(ARROW, 0x0L);
		return(TRUE);
	}
} /* do_diropen */

/* Open an application */
WORD do_aopen(ANODE *pa, WORD isapp, WORD curr, WORD drv, BYTE *ppath, BYTE *pname)
{
	WORD	ret, done;
	WORD	isgraf, isover, isparm, uninstalled;
	BYTE	*ptmp, *pcmd, *ptail;
	BYTE	name[13];

	done = FALSE;
	/* set flags */
	isgraf = pa->a_flags & AF_ISGRAF;
#if MULTIAPP
	pr_kbytes = pa->a_memreq;	/* K bytes needed for app */
	isover = (pa->a_flags & AF_ISFMEM) ? 2 : -1;
	if ((isover == 2) && gl_keepac)	/* full-step ok? */
	{
		rsrc_gaddr(R_STRING, STNOFSTP, &G.a_alert);
		form_alert(1, G.a_alert);
		return(FALSE);
	}
#else
	isover = (pa->a_flags & AF_ISFMEM) ? 2 : 1;
#endif
	isparm = pa->a_flags & AF_ISPARM;
	uninstalled = ( (*pa->a_pappl == '*') || 
		(*pa->a_pappl == '?') ||
		(*pa->a_pappl == '\0') );
	/* change current dir. to selected icon's */
	pro_chdir(drv, ppath);
	/* see if application was selected directly or a */
	/* data file with an associated primary application */
	pcmd = ptail = NULL;
	G.g_cmd[0] = G.g_tail[1] = '\0';
	ret = TRUE;

	if ( (!uninstalled) && (!isapp) )
	{
		/* an installed	docum. */
		pcmd = pa->a_pappl;
		ptail = pname;
	}
	else
	{
		if ( isapp )
		{
			/* DOS-based app. has been selected */
			if (isparm)
			{
				pcmd = &G.g_cmd[0];
				ptail = &G.g_tail[1];
				ret = opn_appl(pname, "\0", pcmd, ptail);
			}
			else
				pcmd = pname;
		} /* if isapp */
		else
		{
			/* DOS-based document has been selected */
			fun_alert(1, STNOAPPL, NULL);
			ret = FALSE;
		} /* else */
	} /* else */
	/* see if it is a batch file */
	if ( wildcmp( ini_str(STGEMBAT), pcmd) )
	{
		/* if is app. then copy	typed in parameter */
		/* tail, else it was a document installed */
		/* to run a batch file */
		strcpy(&G.g_1text[0], (isapp) ? &G.g_tail[1] : ptail);
		ptmp = &name[0];
		pname = pcmd;
		while ( *pname != '.' )
			*ptmp++ = *pname++;
		*ptmp = '\0';
		ret = pro_cmd(&name[0], &G.g_1text[0], TRUE);
		pcmd = &G.g_cmd[0];
		ptail = &G.g_tail[1];
	} /* if */
	/* user wants to run another application */
	if (ret)
	{
		if ( (pcmd != &G.g_cmd[0]) && (pcmd != NULL) )
		{
#if 0
			strcpy(&G.g_cmd[0], &G.g_srcpth[0]);
			strcat(&G.g_cmd[0], "\\");
#else
			G.g_cmd[0] = '\0';
#endif
			strcat(&G.g_cmd[0], pcmd);
		}
		if ( (ptail != &G.g_tail[1])  && (ptail != NULL) )
			strcpy(&G.g_tail[1], ptail);
		done = pro_run(isgraf, isover, G.g_cwin, curr);
	} /* if ret */
#if MULTIAPP
	return(FALSE);	/* don't want to exit */
#else
	return(done);
#endif
} /* do_aopen */

/* Open a disk */
WORD do_dopen(WORD curr)
{
	WORD	drv;
	WNODE	*pw;
	ICONBLK	*pib;

	pib = (ICONBLK *) get_spec(G.g_screen, curr);
	pw = win_alloc();
	if (pw)
	{
		drv = (0x00ff & pib->ib_char);
		pro_chdir(drv, "");
		if (!DOS_ERR)
			do_diropen(pw, TRUE, curr, drv, "", "*", "*", 
				(GRECT *)&G.g_screen[pw->w_root].ob_x, TRUE);
		else
			win_free(pw);
	}
	else
	{
		rsrc_gaddr(R_STRING, STNOWIND, &G.a_alert);
		form_alert(1, (const BYTE FAR *)G.a_alert);
	}
	return( FALSE );
}

/* Open a folder */
VOID do_fopen(WNODE *pw, WORD curr, WORD drv, BYTE *ppath, BYTE *pname,
	BYTE *pext, WORD chkall, WORD redraw)
/* chkall - TRUE if coming from do_chkall */
{
	GRECT	t;
	WORD	ok;
	BYTE	*pp, *pnew;

	ok = TRUE;
	pnew = ppath;
	wind_get(pw->w_id, WF_WORKXYWH, &t.g_x, &t.g_y, &t.g_w, &t.g_h);
	pro_chdir(drv, "");
	if (DOS_ERR)
	{
		if ( DOS_AX == E_PATHNOTFND )
		{
			if (!chkall)
				fun_alert(1, STDEEPPA, NULL);
			else
			{
				pro_chdir(drv, "");
				pnew = "";
			}
		} /* if */
		else
			return;	/* error opening disk drive	*/
	} /* if DOS_ERR */
	else
	{
		pro_chdir(drv, ppath);
		if (DOS_ERR)
		{
			if ( DOS_AX == E_PATHNOTFND )
			{
				/* DOS path is too long? */
				if (chkall)
				{
					pro_chdir(drv, "");
					pnew = "";
				}
				else
				{
					fun_alert(1, STDEEPPA, NULL);
					/* back up one level */
					pp = ppath;
					while (*pp)
						pp++;
					while(*pp != '\\')
						pp--;
					*pp = '\0';
					pname = "*";
					pext  = "*";
					return;
				} /* else */
			} /* if DOS_AX */
			else
				return;	/* error opening disk drive */
		} /* if DOS_ERR */
	} /* else */
	pn_close(pw->w_path);
	if (ok)
	{
		ok = do_diropen(pw, FALSE, curr, drv, pnew, pname, pext, &t, redraw);
		if ( !ok )
		{
			fun_alert(1, STDEEPPA, NULL);
			/* back up one level */
			pp = ppath;
			while (*pp)
				pp++;
			while (*pp != '\\')
				pp--;
			*pp = '\0';
			do_diropen(pw, FALSE, curr, drv, pnew, pname, pext, &t, redraw);
		}
	}
} /* do_fopen */

/* Open an icon */
WORD do_open(WORD curr)
{
	WORD	done;
	ANODE	*pa;
	WNODE	*pw;
	FNODE	*pf;
	WORD	drv, isapp;
	BYTE	path[66], name[9], ext[4];

	done = FALSE;

	pa = i_find(G.g_cwin, curr, &pf, &isapp);
	pw = win_find(G.g_cwin);
	if ( pf )
		fpd_parse(&pw->w_path->p_spec[0],&drv,&path[0],&name[0],&ext[0]);

	if ( pa )
	{	
		switch( pa->a_type )
		{
			case AT_ISFILE:
#if MULTIAPP
				if (strcmp("DESKTOP.APP", &pf->f_name[0]) == 0)
					break;
#endif
				done = do_aopen(pa,isapp,curr,drv,&path[0],&pf->f_name[0]);
				break;
			case AT_ISFOLD:
#if GEMDOS
				if ( (pf->f_attr & FA_FAKE) && pw )
#else
				if ( (pf->f_attr & F_FAKE) && pw )
#endif
					fun_mkdir(pw);
				else
				{
					if (path[0] != '\0')
						strcat(&path[0], "\\");
					if ( (strlen(&path[0]) + LEN_ZFNAME) >= (LEN_ZPATH-3) )
						fun_alert(1, STDEEPPA, NULL);
					else
					{
						strcat(&path[0], &pf->f_name[0]);
						pw->w_cvrow = 0; /* reset slider */
						do_fopen(pw, curr, drv, &path[0], &name[0],
							&ext[0], FALSE, TRUE);
					}
				}
				break;
			case AT_ISDISK:
				drv = (0x00ff & pa->a_letter);
				path[0] = '\0';
				name[0] = ext[0] = '*';
				name[1] = ext[1] = '\0';
				do_fopen(pw, curr, drv, &path[0], &name[0], &ext[0],
					FALSE, TRUE);
				break;
		}
	}
	return(done);
}

/* Get information on an icon. */
WORD do_info(WORD curr)
{
	WORD	ret, junk;
	ANODE	*pa;
	WNODE	*pw;
	FNODE	*pf;
	LONG	tree;

	pa = i_find(G.g_cwin, curr, &pf, &junk);
	pw = win_find(G.g_cwin);

	if ( pa )
	{	
		switch( pa->a_type )
		{
			case AT_ISFILE:
				ret = inf_file(&pw->w_path->p_spec[0], pf);
				if (ret)
					fun_rebld(pw);
				break;
			case AT_ISFOLD:
#if GEMDOS
				if (pf->f_attr & FA_FAKE)
#else
				if (pf->f_attr & F_FAKE)
#endif
				{
					tree = G.a_trees[ADNFINFO];
					inf_show(tree, 0);
					LWSET(OB_STATE(NFINOK), NORMAL);
				}
				else
					inf_folder(&pw->w_path->p_spec[0], pf);
				break;
			case AT_ISDISK:
				inf_disk( pf->f_junk );
				break;
		}
	}
	return( FALSE );
}

#if M68000

/* don't need this routine */

#else

/*
*	This routines purpose is to format a disk by execing a
*	FORMAT.COM above us in memory.  Unfortunately, the ROM BIOS
*	has a bug of using the contents of FORMAT's PSP while doing
*	a Disk Verify function using INT 13h.  This forces us to 
*	place the FORMAT we exec into a safe location in memory.
*	The safe location is an address with segment values between
*	x00x and xEDx. We fudge this on both side by 400 paragraphs.
*	Thanks alot, Bill and Phil.
*/
/*	The MULTIAPP version of this routine is closely tied to the	*/
/*	routine pro_chcalc() in DESKPRO.C.  The high and low memory	*/
/*	boundaries have to be jimmied to force the channel allocator	*/
/*	to put FORMAT in the right place.				*/
VOID romerr(WORD curr)
{
#if MULTIAPP
	LONG	savelo, savehi;

	savelo = pr_topdsk;
	savehi = pr_topmem;

	if ( (pr_topdsk & 0xff00) >= 0xe900)
		pr_topdsk += 0x00001b00L;

	pr_kbytes = 32;
	pr_topmem = pr_topdsk + 0x8000l + pr_ssize;

	if (pr_topmem <= savehi)
		pro_run(FALSE, 3, -1, curr);

	pr_topdsk = savelo;
	pr_topmem = savehi;

#else
	UWORD	seg;
	LONG	testform, lavail;

	lavail = dos_avail();
	testform = dos_alloc( lavail );
	seg = testform >> 16;
	dos_free(testform);
	testform = 0x0L;
	if ( ((seg << 4) & 0xff00) >= 0xe900)
		testform = dos_alloc( 0x00001b00L );

	pro_run(FALSE, 0, -1, curr);

	if (testform)
		dos_free(testform);

#endif
} /* romerr */

#endif

#if GEMDOS

#include "format.rsh"
#include "format.h"

BOOLEAN IsInit = FALSE;

MLOCAL VOID gemdos_format(BYTE drv)
{
	int	track_no, i;
	char *buf;
	OBJECT *tree;
	WORD xd, yd, wd, hd, ret;

	if (!IsInit)
	{
		for (i=T0OBJ; i<T1OBJ; i++)
		{
			rsrc_obfix(&rs_object[T0OBJ], i-T0OBJ);
#if TURBO_C
			if ((rs_object[i].ob_type == G_STRING) ||
				(rs_object[i].ob_type == G_BUTTON))
			{
				rs_object[i].ob_spec.free_string =
					rs_strings[rs_object[i].ob_spec.index];
			}
			else if (rs_object[i].ob_type == G_FTEXT)
			{
				rs_object[i].ob_spec.tedinfo =
					&rs_tedinfo[rs_object[i].ob_spec.index];
				rs_object[i].ob_spec.tedinfo->te_ptext =
					rs_strings[(LONG)rs_object[i].ob_spec.tedinfo->te_ptext];
				rs_object[i].ob_spec.tedinfo->te_ptmplt =
					rs_strings[(LONG)rs_object[i].ob_spec.tedinfo->te_ptmplt];
				rs_object[i].ob_spec.tedinfo->te_pvalid =
					rs_strings[(LONG)rs_object[i].ob_spec.tedinfo->te_pvalid];
			}
#else
			if ((rs_object[i].ob_type == G_STRING) ||
				(rs_object[i].ob_type == G_BUTTON))
			{
				rs_object[i].ob_spec =
					rs_strings[(LONG)rs_object[i].ob_spec];
			}
			else if (rs_object[i].ob_type == G_FTEXT)
			{
				rs_object[i].ob_spec =
					(BYTE *)&rs_tedinfo[(LONG)rs_object[i].ob_spec];
				((TEDINFO *)rs_object[i].ob_spec)->te_ptext =
					rs_strings[(LONG)((TEDINFO *)rs_object[i].ob_spec)->te_ptext];
				rs_object[i].ob_spec.tedinfo.te_ptmplt =
					rs_strings[(LONG)((TEDINFO *)rs_object[i].ob_spec)->te_ptmplt];
				rs_object[i].ob_spec.tedinfo.te_pvalid =
					rs_strings[(LONG)((TEDINFO *)rs_object[i].ob_spec)->te_pvalid];
			}
#endif
		}
		for (i=T1OBJ; i<NUM_OBS; i++)
		{
			rsrc_obfix(&rs_object[T1OBJ], i-T1OBJ);
#if TURBO_C
			if ((rs_object[i].ob_type == G_STRING) ||
				(rs_object[i].ob_type == G_BUTTON))
			{
				rs_object[i].ob_spec.free_string =
					rs_strings[rs_object[i].ob_spec.index];
			}
#else
			if ((rs_object[i].ob_type == G_STRING) ||
				(rs_object[i].ob_type == G_BUTTON))
			{
				rs_object[i].ob_spec =
					rs_strings[(LONG)rs_object[i].ob_spec.index];
			}
#endif
		}
		IsInit = TRUE;
	}
	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);
	tree = &rs_object[T0OBJ];
	tree[FMTEXIT].ob_flags = SELECTABLE | EXIT;
	tree[FMTBEG].ob_flags = SELECTABLE | EXIT;
	tree[FMTEINS].ob_flags = SELECTABLE | RBUTTON;
	tree[FMTZWEI].ob_flags = SELECTABLE | RBUTTON;
	objc_change(tree, FMTEINS, 0, 0, 0, 0, 0, NORMAL, FALSE);
	objc_change(tree, FMTZWEI, 0, 0, 0, 0, 0, SELECTED, FALSE);
#if TURBO_C
	tree[FMTLABEL].ob_spec.tedinfo->te_ptext[0] = '\0';
	tree[FMTDRV].ob_spec.free_string[0] = drv;
#else
	((TEDINFO *)tree[FMTLABEL].ob_spec)->te_ptext[0] = '\0';
	tree[FMTDRV].ob_spec[0] = drv;
#endif
	form_center(tree, &xd, &yd, &wd, &hd);
	form_dial(FMD_START, 0, 0, 0, 0, xd, yd, wd, hd);
	objc_draw(tree, ROOT, 1, xd, yd, wd, hd);
	ret = form_do(tree, FMTLABEL) & 0x7FFF;
	form_dial(FMD_FINISH, 0, 0, 0, 0, xd, yd, wd, hd);
	objc_change(tree, ret, 0, 0, 0, 0, 0, NORMAL, FALSE);
	if (ret == FMTBEG)
	{
		tree = &rs_object[T1OBJ];
		form_center(tree, &xd, &yd, &wd, &hd);
		form_dial(FMD_START, 0, 0, 0, 0, xd, yd, wd, hd);
		tree[FMTSLID].ob_width = 0;
		objc_draw(tree, ROOT, MAX_DEPTH, xd, yd, wd, hd);
		graf_mouse(BUSYBEE, NULL);
		buf = malloc(9 * 512);
		if (buf)
		{
			for (track_no = 79; track_no >= 0; track_no--)
			{
				Flopfmt(buf, 0, drv - 'A', 9, track_no,
					0, 1, 0x87654321L, 0xE5E5);
				if ((rs_object[T0OBJ+FMTZWEI].ob_state & SELECTED) != 0)
				{
					Flopfmt(buf, 0, drv - 'A', 9, track_no,
						1, 1, 0x87654321L, 0xE5E5);
				}
				tree[FMTSLID].ob_width =
					tree[FMTBAHN].ob_width * (79 - track_no) / 79;
				objc_draw(tree, FMTBAHN, MAX_DEPTH, xd, yd, wd, hd);
			}
			tree[FMTSLID].ob_width = tree[FMTBAHN].ob_width;
			objc_draw(tree, FMTBAHN, MAX_DEPTH, xd, yd, wd, hd);
			/* write bootsector */
			if ((rs_object[T0OBJ+FMTZWEI].ob_state & SELECTED) != 0)
				Protobt(buf, 0x02000000L, 3, 0);
			else
				Protobt(buf, 0x02000000L, 2, 0);
			Flopwr(buf, 0, drv - 'A', 1, 0, 0, 1);
			/* write FAT 1 and FAT 2 */
			memset(buf, 0, 7 * 512);
			buf[0] = 0xF9;
			buf[1] = 0xFF;
			buf[2] = 0xFF;
			Flopwr(buf, 0, drv - 'A', 2, 0, 0, 5);
			Flopwr(buf, 0, drv - 'A', 7, 0, 0, 3);
			if ((tree[FMTZWEI].ob_state & SELECTED) != 0)
				Flopwr(buf + 3 * 512, 0, drv - 'A', 1, 0, 1, 2);
			else
				Flopwr(buf + 3 * 512, 0, drv - 'A', 1, 1, 0, 2);
			/* write directory */
			memset(buf, 0, 3);
#if TURBO_C
			if (rs_object[T0OBJ+FMTLABEL].ob_spec.tedinfo->te_ptext[0] != '\0')
			{
				/* set label */
				strncpy(buf, rs_object[T0OBJ+FMTLABEL].ob_spec.tedinfo->te_ptext, 11);
#else
			if (((TEDINFO *)rs_object[T0OBJ+FMTLABEL].ob_spec)->te_ptext[0] != '\0')
			{
				/* set label */
				strncpy(buf, ((TEDINFO *)rs_object[T0OBJ+FMTLABEL].ob_spec)->te_ptext, 11);
#endif
				buf[11] = 0x08;
			}
			if ((rs_object[T0OBJ+FMTZWEI].ob_state & SELECTED) != 0)
				Flopwr(buf, 0, drv - 'A', 3, 0, 1, 7);
			else
				Flopwr(buf, 0, drv - 'A', 3, 1, 0, 7);
			free(buf);
		}
		form_dial(FMD_FINISH, 0, 0, 0, 0, xd, yd, wd, hd);
		graf_mouse(ARROW, NULL);
		inf_disk(drv);
	}
	wind_update(END_MCTRL);
	wind_update(END_UPDATE);
}

#endif

/* Format the currently selected disk. */
VOID do_format(WORD curr)
{
	WORD	junk, ret;
#if !M68000
	WORD	foundit;
#endif
	BYTE	msg[6];
	ANODE	*pa;
	FNODE	*pf;

	pa = i_find(G.g_cwin, curr, &pf, &junk);

	if ( (pa) && (pa->a_type == AT_ISDISK) )
	{
		msg[0] = pf->f_junk;
		msg[1] = '\0';
		ret = fun_alert(2, STFORMAT, msg);
		strcat(msg, ":");
		if (ret == 1)
		{
#if M68000
#if GEMDOS
			gemdos_format(msg[0]);
#else
			ret = pro_cmd( ini_str(STDKFRM1), &msg[0], TRUE);
			if (ret)
				pro_run(FALSE, FALSE, G.g_cwin, curr);
#endif
#else
			strcpy(&G.g_cmd[0], ini_str(STDKFRM1));
			foundit = shel_find(G.a_cmd);
			if (!foundit)
			{
				strcpy(&G.g_cmd[0], ini_str(STDKFRM2));
				foundit = shel_find(G.a_cmd);
			}
			if (foundit)
			{
				strcpy(&G.g_tail[1], &msg[0]);

				takedos();
				takekey();
				takevid();

				romerr(curr);
				givevid();
				givekey();
				givedos();
			} /* if */
			else
				fun_alert(1, STNOFRMT, NULLPTR);
#endif
			graf_mouse(ARROW, 0x0L);	
		} /* if ret */
	} /* if */
} /* do_format */

/*
*	Routine to check the all windows directory by doing a change
*	disk/directory to it and redrawing the window;
*/
VOID do_chkall(WORD redraw)
{
	WORD	ii;
	WORD	drv;
	BYTE	path[66], name[9], ext[4];
	WNODE	*pw;

	for (ii = 0; ii < NUM_WNODES; ii++)
	{
		pw = &G.g_wlist[ii];
		if (pw->w_id)
		{
			fpd_parse(&pw->w_path->p_spec[0], &drv, &path[0],
				&name[0], &ext[0]);
			do_fopen(pw, 0, drv, &path[0], &name[0], &ext[0], TRUE, redraw);
		}
		else
		{
			desk_verify(0, TRUE);
		}
	}
} /* do_chkall */
