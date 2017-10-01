/*	DESKFUN.C	08/30/84 - 05/30/85		Lee Lorenzen	*/
/*			10/2/86  - 01/16/87		MDF		*/
/*	merge source	5/27/87  - 5/28/87		mdf		*/
/*	for 2.3		6/11/87				mdf		*/

/*
*       Copyright 1999, Caldera Thin Clients, Inc.                      
*       This software is licenced under the GNU Public License.         
*       Please see LICENSE.TXT for further information.                 
*                                                                       
*                  Historical Copyright                                 
*	-------------------------------------------------------------
*	GEM Desktop					  Version 2.3
*	Serial No.  XXXX-0000-654321		  All Rights Reserved
*	Copyright (C) 1985 - 1987		Digital Research Inc.
*	-------------------------------------------------------------
*/

#include <stddef.h>
#include <stdio.h>
#include <string.h>
#include <portab.h>
#include <machine.h>
#if GEMDOS
#if TURBO_C
#include <tos.h>
#include <tos_intr.h>
#include <aes.h>
#endif
#else
#include <dos.h>
#include <obdefs.h>
#include <gembind.h>
#endif
#include "desktop.h"
#include "deskapp.h"
#include "deskfpd.h"
#include "deskinf.h"
#include "deskwin.h"
#include "deskbind.h"
#include "deskdir.h"
#include "deskmain.h"
#include "desksupp.h"
#include "optimize.h"
#include "deskfun.h"

EXTERN WORD	DOS_ERR;
EXTERN WORD	gl_apid;

EXTERN GLOBES	G;

/*
*	Routine to transfer a string that requires integrated variables
*	that are merged in.  The resultant alert is then displayed;
*/
WORD fun_alert(WORD defbut, WORD stnum, BYTE *pvarstr)
{
	rsrc_gaddr(R_STRING, stnum, &G.a_alert);
	if (pvarstr != NULL)
	{
		LSTCPY(ADDR(&G.g_2text[0]), G.a_alert);
		sprintf(&G.g_1text[0], &G.g_2text[0], pvarstr);
		G.a_alert = (LONG)ADDR(&G.g_1text[0]);
	}
	return( form_alert(defbut, (const BYTE FAR *)G.a_alert) );
}

VOID fun_msg(WORD type, WORD w3, WORD w4, WORD w5, WORD w6, WORD w7)
{
	/* keep DESKTOP messages internal to DESKTOP -- no AES call	*/
	G.g_rmsg[0] = type;
	G.g_rmsg[1] = gl_apid;
	G.g_rmsg[2] = 0;
	G.g_rmsg[3] = w3;
	G.g_rmsg[4] = w4;
	G.g_rmsg[5] = w5;
	G.g_rmsg[6] = w6;
	G.g_rmsg[7] = w7;
	hndl_msg();
}

/* Rebuild window path and pflist */
VOID fun_rebld(WNODE *pwin)
{
	WORD	i, x, y, w, h;
	BYTE	*ptst;

	graf_mouse(HOURGLASS, 0x0L);
	/* set up path to check against all windows */
	ptst = &pwin->w_path->p_spec[0];
	/* check all wnodes	*/
	for(i = NUM_WNODES; i; i--)
	{
		pwin = win_ith(i);
		/* if opened and same path then rebuild */
		if ( (pwin->w_id) && (strcmp(&pwin->w_path->p_spec[0], ptst) == 0) )
		{
			pn_active(pwin->w_path);
			desk_verify(pwin->w_id, TRUE);
/*			win_sinfo(pwin);
			wind_set(pwin->w_id, WF_INFO, ADDR(&pwin->w_info[0]), 0, 0);
*/
			wind_get(pwin->w_id, WF_WORKXYWH, &x, &y, &w, &h);
			fun_msg(WM_REDRAW, pwin->w_id, x, y, w, h);
		} /* if */
	} /* for */
	graf_mouse(ARROW, 0x0L);
} /* fun_rebld */

/* Routine that creates a new directory in the specified window/path */
WORD fun_mkdir(WNODE *pw_node)
{
	PNODE	*pp_node;
	LONG	tree;
	WORD	more, cont, i;
	BYTE	fnew_name[12], unew_name[13], *ptmp;

	tree = G.a_trees[ADMKDBOX];
	pp_node = pw_node->w_path;
	ptmp = &G.g_srcpth[0];
	strcpy(ptmp, &pp_node->p_spec[0]);
	i = 0;
	while (*ptmp++)
	{
		if (*ptmp == '\\')
			i++;
	}
	if (i > MAX_LEVEL)
	{
		fun_alert(1, STFO8DEE, NULL);
		return(FALSE);
	}
	else
	{
		cont = TRUE;
		while (cont)
		{
			fnew_name[0] = '\0';
			inf_sset(tree, MKNAME, &fnew_name[0]);
			show_hide(FMD_START, tree);
			form_do((OBJECT FAR *)tree, 0);
			cont = FALSE;
			if (inf_what(tree, MKOK, MKCNCL))
			{
				inf_sget(tree, MKNAME, &fnew_name[0]);
				unfmt_str(&fnew_name[0], &unew_name[0]);
				if ( unew_name[0] != '\0' )
				{
					add_fname(&G.g_srcpth[0], &unew_name[0]);
#if GEMDOS
					DOS_ERR = (Dcreate(ADDR(&G.g_srcpth[0])) < 0);
#else
					dos_mkdir(ADDR(&G.g_srcpth[0]));
#endif
					if (DOS_ERR)
					{
						cont = fun_alert(2, STFOEXIS, NULL) - 1;
						del_fname(&G.g_srcpth[0]);
					}
					else
					{
						more = d_errmsg();
						if (more)
							fun_rebld(pw_node);
					} /* else */
				} /* if */
			} /* if OK */
		} /* while */
		show_hide(FMD_FINISH, tree);
		return(TRUE);
	}
} /* fun_mkdir */

WORD fun_op(WORD op, PNODE *pspath, BYTE *pdest, WORD dulx, WORD duly,
	WORD from_disk, WORD src_ob)
{
	WORD	fcnt, dcnt;
	LONG	size;

	/* do the operation	*/
	if (op != -1)
	{
		if (op == OP_COPY)
		{
			if ( !par_chk(&pspath->p_spec[0], pspath->p_flist, 
				&G.g_tmppth[0]) )
				return(FALSE);
		}
		/* get count of source files */
		dir_op(OP_COUNT, &pspath->p_spec[0], pspath->p_flist, pdest,
			 &fcnt, &dcnt, &size, dulx, duly, from_disk, src_ob);
		/* do the operation	*/
		if ( fcnt || dcnt )
		{
			dir_op(op, &pspath->p_spec[0], pspath->p_flist, pdest,
				&fcnt, &dcnt, &size, dulx, duly, from_disk, src_ob);
			return(TRUE);
		} /* if */
	} /* if */
	graf_mouse(ARROW, 0x0L);
	return(FALSE);
} /* fun_op */

/*
*	Routine to call when a list of files has been dragged on
*	top of a particular destination inside of a window.
*/
WORD fun_wdst(PNODE *pspath, BYTE *pdspec, WORD datype, FNODE *pdf,
	WORD dulx, WORD duly, WORD from_disk, WORD src_ob, WORD *pdo_both)
/*
pspath     - source path
pdspec     - destination file spec
datype     - destination icon
pdf        - destination file/fold
dulx, duly - destination x, y
from_disk  - TRUE if src is disk
src_ob     - source object
pdo_both   - see AT_ISFOLD below
*/
{
	WORD	op;
	BYTE	*pdname, drv_ltr, *ptmp;
	ICONBLK	*spib;
	WNODE	*pwname1, *pwname2;

	/* default case: don't	*/
	*pdo_both = FALSE;			/* redraw both windows	*/
	/* set up destination path name */
	if (G.g_iview == V_TEXT)
	{
		ptmp = &G.g_tmppth[0];	/* set in dr_fnode() */
		while (*ptmp < 'A' - 1)	/* find drive letter */
			ptmp++;
		drv_ltr = *ptmp; 
	} /* if V_TEXT */
	strcpy(&G.g_tmppth[0], &pdspec[0]);
	pdname = &G.g_tmppth[0];
	while (*pdname != '*')
		pdname++;
	*pdname = '\0';
	/* check destination */
	op = -1;
	switch( datype )
	{
		case AT_ISFOLD:
			/* if destination is folder then append */
			/* folder to window	path, if it is a */
			/* fake then treat it like open space */
#if GEMDOS
			if (pdf->f_attr & FA_FAKE)
#else
			if (pdf->f_attr & F_FAKE)
#endif
				strcat(pdname, "*.*");
			else
			{
				pdname = strcpy(pdname, &pdf->f_name[0]);
				strcpy(pdname-1, "\\*.*");
			}
			op = OP_COPY;
			/* check to see if this dest. folder */
			/* is also an open window */
			pwname1 = (WNODE *)&G.g_wlist[0].w_name[0];
			pwname2 = (WNODE *)&G.g_wlist[1].w_name[0];
			if ( cmp_names(&G.g_tmppth[0], (BYTE *)pwname1) ||
				cmp_names(&G.g_tmppth[0], (BYTE *)pwname2) )
				*pdo_both = TRUE;
			break;
		case AT_ISDISK:
			/* if destination is disk then use */
			/* icon char. to build dest path */
			if (G.g_iview == V_TEXT)
				G.g_tmppth[0] = drv_ltr;
			else
			{
				spib = get_spec(G.g_screen, pdf->f_obid);
				G.g_tmppth[0] = (0x00FF & spib->ib_char);
			} /* else */
			strcpy(&G.g_tmppth[1], ":\\*.*");
			op = OP_COPY;
			break;
		case AT_ISFILE:
			/* if destination is window or a file */
			/* icon then use window path */
			strcat(pdname, "*.*");
			op = OP_COPY;
			break;
		case AT_ISTRSH:
			op = OP_DELETE;
			break;
	} /* switch */
	return( fun_op(op, pspath, &G.g_tmppth[0], dulx, duly, from_disk, src_ob) );
} /* fun_wdst */

/*
*	Routine to call when the source of a drag is a disk
*	and the destination is either a window or another
*	disk.
*/
WORD fun_disk(WORD src_ob, WNODE *pdw, WORD datype, FNODE *pdf,
	WORD dulx, WORD duly)
{
	WORD	ret, do_both;
	FNODE	*pf;
	ICONBLK	*spib;
	PNODE	*pspath;
	BYTE	chr;

	if (G.g_iview == V_TEXT)
		chr = LBGET(G.g_udefs[src_ob].ub_parm); /* get drive from user obj */
	else
	{
		spib = get_spec(G.g_screen, src_ob);
		chr = spib->ib_char;
	} /* else */
	/* build a source path */
#if GEMDOS
	pspath = pn_open(chr, "", "*", "*", FA_SUBDIR);
#else
	pspath = pn_open(chr, "", "*", "*", F_SUBDIR);
#endif
	/* if one available	*/
	if (pspath)
	{
		/* read the directory */
		ret = pn_active(pspath);
		/* if files to copy	*/
		ret = FALSE;
		if (pspath->p_flist)
		{
			/* select all files	*/
			for (pf = pspath->p_flist; pf; pf = pf->f_next)
				pf->f_obid = 0;
			G.g_screen[0].ob_state = SELECTED;
			/* do the copy or delete*/
			if (pdw != (WNODE *) 0)
				ret = fun_wdst(pspath, &pdw->w_path->p_spec[0], datype,
					pdf, dulx, duly, TRUE, src_ob, &do_both);
			else
				ret = fun_op(OP_DELETE, pspath, &G.g_tmppth[0],
					dulx, duly, TRUE, src_ob);
			/* return to normalcy */
			G.g_screen[0].ob_state = NORMAL;
		} /* if */
		pn_close(pspath);
		/* rebuild any windows with dpib.ib_char in title */
		desk_clear(0);
	} /* if pspath */
	return(ret);
} /* fun_disk */

/*
*	Routine to call when several icons have been dragged from a
*	window to another window (it might be the same window) and 
*	dropped on a particular icon or open space.
*/
VOID fun_drag(WORD src_wh, WORD dst_wh, WORD dst_ob, WORD dulx, WORD duly)
{
	WORD	ret, junk, datype, src_ob, do_both;
	WNODE	*psw, *pdw;
	ANODE	*pda;
	FNODE	*pdf;

	psw = win_find(src_wh);
	pdw = win_find(dst_wh);
	if (pdw->w_path->p_spec[0] != '@' || dst_ob > 3)
	{
		pda = i_find(dst_wh, dst_ob, &pdf, &junk);
		datype = (pda) ? pda->a_type : AT_ISFILE;

		if (psw->w_path->p_spec[0] != '@')
		{
			ret = fun_wdst(psw->w_path, &pdw->w_path->p_spec[0], 
				datype, pdf, dulx, duly, FALSE, 0, &do_both);
			if (ret)
			{
				if (src_wh != dst_wh)
					desk_clear(src_wh);
				if (do_both)		/* force redraw of both windows	*/
				{
					fun_rebld(&G.g_wlist[0]);
					fun_rebld(&G.g_wlist[1]);
				}
				else
					fun_rebld(pdw);
			} /* if ret */
		} /* if */
		else
		{
			src_ob = 0;
			while ( (src_ob = win_isel(G.g_screen, G.g_croot, src_ob)) != 0 )
			{
				ret = fun_disk(src_ob, pdw, datype, pdf, dulx, duly);
				if (ret)
					fun_rebld(pdw);
			} /* while */
		} /* else */
	}
} /* fun_drag */

/*
*	Routine to call when several icons have been dragged from a
*	desktop to the desktop and dropped on a particular icon.
*/
VOID fun_del(WNODE *pdw)
{
	WORD	src_ob, ret;
	ICONBLK	*spib;
	BYTE	drvch[2], *ptmp;

	if (pdw->w_path->p_spec[0] != '@')
	{
		ret = fun_op(OP_DELETE, pdw->w_path, &G.g_tmppth[0], 0, 0, 0, 0);
		if (ret)
/*			fun_rebld(pdw);*/
			do_chkall(TRUE);
	}
	else
	{
		src_ob = 0;
		while ( (src_ob = win_isel(G.g_screen, G.g_croot, src_ob)) != 0 )
		{
			ret = 1;
			if (G.g_iview == V_TEXT)
			{
				ptmp = &G.g_tmppth[0];
				while (*ptmp < 0x40)
					ptmp++;
				drvch[0] = *ptmp;
			} /* if V_TEXT */
			else
			{
				spib = get_spec(G.g_screen, src_ob);
				drvch[0] = (0x00FF & spib->ib_char);
			} /* else */
			drvch[1] = '\0';
			graf_mouse(ARROW, 0x0L);
			ret = fun_alert(2, STDELDIS, &drvch[0]);
			graf_mouse(HOURGLASS, 0x0L);
			if (ret == 1)
			{
				fun_disk(src_ob, NULL, AT_ISTRSH, NULL, 0, 0);
				do_chkall(TRUE);
			}
		} /* while */
		graf_mouse(ARROW, 0x0L);
	} /* else */
} /* fun_del */

WORD cmp_names(BYTE *psrc, BYTE *pdst)
{
	WORD	ret;
	BYTE	*lastslsh, *ptmp;

	/* scan to lastslsh */
	lastslsh = scan_slsh(psrc);
	/* null it */
	*lastslsh = '\0';
	/* find trailing slash */
	ptmp = pdst;
	while (*ptmp)
		ptmp++;
	ptmp--;
	*ptmp = '\0'; /* null it */
	/* see if they match */
	ret = (strcmp(psrc, pdst) == 0);
	/* restore it */
	*lastslsh = '\\';
	*ptmp = '\\';
	/* return if same */
	return( ret );
} /* cmp_names */
