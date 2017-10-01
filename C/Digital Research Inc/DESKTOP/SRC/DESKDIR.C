/*	DESKDIR.C	09/03/84 - 06/05/85	Lee Lorenzen		*/
/*			4/7/86   - 8/27/86	MDF			*/
/*	merge source	5/19/97  - 5/28/87	mdf			*/
/*	for 3.0		11/13/87		mdf			*/

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
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <portab.h>
#include <machine.h>
#if GEMDOS
#if TURBO_C
#include <tos.h>
#include <tos_intr.h>
#include <aes.h>
#include <vdi.h>
#endif
#else
#include <dos.h>
#include <obdefs.h>
#include <gembind.h>
#endif
#include "taddr.h"
#include "desktop.h"
#include "deskapp.h"
#include "deskfpd.h"
#include "deskwin.h"
#include "deskfun.h"
#include "deskinf.h"
#include "deskbind.h"
#include "deskgraf.h"
#include "desksupp.h"
#include "deskrsrc.h"
#include "optimize.h"
#include "deskdir.h"

#define abs(x) ( (x) < 0 ? -(x) : (x) )
#define MAX_TWIDTH 45				/* used in blank_it()	*/

EXTERN WORD	DOS_AX;
EXTERN WORD	DOS_ERR;
EXTERN WORD	gl_wchar;
EXTERN WORD	gl_hchar;

EXTERN GLOBES	G;

MLOCAL BYTE	ml_files[4], ml_dirs[4];
MLOCAL WORD	ml_dlfi, ml_dlfo, ml_dlok, ml_dlcn;
MLOCAL WORD	ml_dlpr, ml_havebox;
MLOCAL BYTE	ml_fsrc[13], ml_fdst[13], ml_fstr[13], ml_ftmp[13];

/* Routine to DRAW a DIALog box centered on the screen */
VOID draw_dial(LONG tree)
{
	WORD	xd, yd, wd, hd;

	form_center((OBJECT FAR *)tree, &xd, &yd, &wd, &hd);
	objc_draw((OBJECT FAR *)tree, ROOT, MAX_DEPTH, xd, yd, wd, hd);
} /* draw_dial */

VOID show_hide(WORD fmd, LONG tree)
{
	WORD	xd, yd, wd, hd;

	form_center((OBJECT FAR *)tree, &xd, &yd, &wd, &hd);
	form_dial(fmd, 0, 0, 0, 0, xd, yd, wd, hd);
	if (fmd == FMD_START)
		objc_draw((OBJECT FAR *)tree, ROOT, MAX_DEPTH, xd, yd, wd, hd);
}

VOID do_namecon(VOID)
{
	graf_mouse(ARROW, 0x0L);
	if (ml_havebox)
		draw_dial(G.a_trees[ADCPALER]);
	else
	{
		show_hide(FMD_START, G.a_trees[ADCPALER]);
		ml_havebox = TRUE;
	}
	form_do((OBJECT FAR *)(G.a_trees[ADCPALER]), 0);
	if (ml_dlpr)
		draw_dial(G.a_trees[ADCOPYDI]);
	graf_mouse(HRGLASS, 0x0L);
} /* do_namecon */

/* Draw a single field of a dialog box */
VOID draw_fld(LONG tree, WORD obj)
{
	GRECT	t;

	LWCOPY(ADDR(&t), OB_X(obj), 4);
	objc_offset((OBJECT FAR *)tree, obj, &t.g_x, &t.g_y);
	objc_draw((OBJECT FAR *)tree, obj, MAX_DEPTH, t.g_x, t.g_y, t.g_w, t.g_h);
} /* draw_fld */

BYTE *scan_slsh(BYTE *path)
{
	/* scan to first '*' */
	while (*path != '*')
		path++;
	/* back up to last slash */
	while (*path != '\\')
		path--;
	return(path);
}

/*
*	Add a new directory name to the end of an existing path.  This
*	includes appending a \*.*.
*/
VOID add_path(BYTE *path, BYTE *new_name)
{
	while (*path != '*')
		path++;
	strcpy(path, new_name);
	strcat(path, "\\*.*");
} /* add_path */

/* Remove the last directory in the path and replace it with *.*. */
VOID sub_path(BYTE *path)
{
	/* scan to last slash */
	path = scan_slsh(path);
	/* now skip to previous directroy in path */
	path--;
	while (*path != '\\')
		path--;
	/* append a *.* */
	strcpy(path, "\\*.*");
} /* sub_path */

/* Add a file name to the end of an existing path. */
VOID add_fname(BYTE *path, BYTE *new_name)
{
	while (*path != '*')
		path++;
	strcpy(path, new_name);
} /* add_fname */

/* Check if path is associated with an open window */
WORD fold_wind(BYTE *path)
{
	WORD	i;
	WNODE	*pwin;

	for(i = NUM_WNODES; i; i--)
	{
		pwin = win_ith(i);
		if ( (pwin->w_id) && (strcmp(&pwin->w_path->p_spec[0], path) == 0) )
			return(TRUE);
	}
	return(FALSE);
}

/*
*	Routine to check that the name we will be adding is like the 
*	last folder name in the path.
*/
VOID like_parent(BYTE *path, BYTE *new_name)
{
	BYTE	*pstart, *lastfold, *lastslsh;

	/* remember start of path*/
	pstart = path;
	/* scan to lastslsh	*/
	lastslsh = path = scan_slsh(path);
	/* back up to next to last slash if it exists */
	path--;
	while ( (*path != '\\') && (path > pstart) )
		path--;
	/* remember start of last folder name */
	if (*path == '\\')
		lastfold = path + 1;
	else
		lastfold = 0;

	if (lastfold)
	{
		*lastslsh = '\0';
		if ( strcmp(lastfold, new_name) == 0 )
			return;
		*lastslsh = '\\';
	}
	add_fname(pstart, new_name);
} /* like_parent */

/*
*	See if these two paths represent the same folder.  The first
*	path ends in \*.*, the second path ends with just the folder.
*/
WORD same_fold(BYTE *psrc, BYTE *pdst)
{
	WORD	ret;
	BYTE	*lastslsh;

	/* scan to lastslsh	*/
	lastslsh = scan_slsh(psrc);
	/* null it		*/
	*lastslsh = '\0';
	/* see if they match	*/
	ret = strcmp(psrc, pdst);	
	/* restore it		*/
	*lastslsh = '\\';
	/* return if same	*/
	return( ret == 0 );
}

/*
*	Remove the file name from the end of a path and append on
*	an \*.*
*/
VOID del_fname(BYTE *pstr)
{
	while (*pstr)
		pstr++;
	while (*pstr != '\\')
		pstr--;
	strcpy(pstr, "\\*.*");
} /* sub_path */

/*
*	Parse to find the filename part of a path and return a copy of it
*	in a form ready to be placed in a dialog box.
*/
VOID get_fname(BYTE *pstr, BYTE *newstr)
{
	while (*pstr)
		pstr++;
	while(*pstr != '\\')
		pstr--;
	pstr++;
	strcpy(&ml_ftmp[0], pstr);
	fmt_str(&ml_ftmp[0], newstr);
} /* get_fname */

WORD d_errmsg(VOID)
{
	if (DOS_ERR)
	{
		form_error(DOS_AX);
		return(FALSE);
	}
	else
		return(TRUE);
}

/* Directory routine to DO File DELeting. */
WORD d_dofdel(BYTE *ppath)
{ 
#if GEMDOS
	DOS_AX = Fdelete(ADDR(ppath));
	DOS_ERR = DOS_AX != 0;
#else
	dos_delete(ADDR(ppath));
#endif
	return( d_errmsg() );
} /* d_dofdel */

/* Directory routine to DO File COPYing. */
WORD d_dofcopy(BYTE *psrc_file, BYTE *pdst_file, WORD time, WORD date, WORD attr)
{
	LONG	tree;
	WORD	srcfh, dstfh;
#if GEMDOS
	LONG	amntrd, amntwr;
#else
	UWORD	amntrd, amntwr;
#endif
	WORD	copy, cont, more, samedir, ob;
#if MULTIAPP
	LONG	lavail;
#endif
#if GEMDOS
	DOSTIME	dtime;
#endif

	copy = TRUE;
	/* open the source file	*/
#if GEMDOS
	srcfh = Fopen(ADDR(psrc_file), 0);
	DOS_AX = srcfh;
	DOS_ERR = srcfh < 0;
#else
	srcfh = dos_open(ADDR(psrc_file), 0);
#endif
	more = d_errmsg();
	if (!more)
		return(more);
	else
	{
		/* open the dest file	*/
		cont = TRUE;
		while (cont)
		{
			copy = FALSE;
			more = TRUE;
#if GEMDOS
			dstfh = Fopen(ADDR(pdst_file), 0);
			DOS_ERR = (dstfh < 0);
			DOS_AX = dstfh;
#else
			dstfh = dos_open(ADDR(pdst_file), 0);
#endif
			/* handle dos error	*/
			if (DOS_ERR)
			{
				if (DOS_AX == E_FILENOTFND)
					copy = TRUE;
				else
					more = d_errmsg();
				cont = FALSE;
			}
			else
			{
				/* dest file already exists */
#if GEMDOS
				Fclose(dstfh);
#else
				dos_close(dstfh);
#endif
				/* get the filenames from the pathnames */
				get_fname(psrc_file, &ml_fsrc[0]);
				/* if same dir, then don't prefill the new name string */
				samedir = (strcmp(psrc_file, pdst_file) == 0);
				if (samedir)
					ml_fdst[0] = '\0';
				else
					get_fname(pdst_file, &ml_fdst[0]);
				/* put in filenames	in dialog */
				inf_sset(G.a_trees[ADCPALER], 2, &ml_fsrc[0]);
				inf_sset(G.a_trees[ADCPALER], 3, &ml_fdst[0]);
				/* show dialog */
				if ((G.g_covwrpref) || (samedir))
				{
					do_namecon();
					/* if okay then if its the same name then */
					/* overwrite else get new name and go */
					/* around to check it */
					tree = G.a_trees[ADCPALER];
					ob = inf_gindex(G.a_trees[ADCPALER], CAOK, 3) + CAOK;
					LWSET(OB_STATE(ob), NORMAL);
					if (ob == CASTOP)
						copy = more = FALSE;
					else if (ob == CACNCL)
						copy = FALSE;
					else
						copy = TRUE;
				}
				else
					copy = TRUE;
				if (copy)
				{
					cont = FALSE;
					inf_sget(G.a_trees[ADCPALER], 3, &ml_fdst[0]);
					unfmt_str(&ml_fdst[0], &ml_fstr[0]);
					if ( ml_fstr[0] == '\0' )
					{
						copy = FALSE;
#if GEMDOS
						Fclose(srcfh);
#else
						dos_close(srcfh);
#endif
					}
					else
					{
						del_fname(pdst_file);
						add_fname(pdst_file, &ml_fstr[0]);
					}
				}
				else
				{
#if GEMDOS
					Fclose(srcfh);
#else
					dos_close(srcfh);
#endif
					cont = copy = FALSE;
				}
			} /* else */
		} /* while cont */

		if ( copy && more )
#if GEMDOS
			dstfh = Fcreate(ADDR(pdst_file), attr);
			DOS_AX = dstfh;
			DOS_ERR = dstfh < 0;
#else
			dstfh = dos_create(ADDR(pdst_file), attr);
#endif
#if MULTIAPP
		G.g_xbuf = proc_malloc(0xfff0L, &lavail);
		if (G.g_xbuf == 0)
			G.g_xbuf = proc_malloc(lavail, &lavail);
		G.g_xlen = LLOWD(lavail);
#endif
		amntrd = copy;
		while( amntrd && more )
		{
			more = d_errmsg();
			if (more)
			{
#if GEMDOS
				amntrd = Fread(srcfh, (LONG)G.g_xlen, (void *)G.g_xbuf);
				DOS_AX = (WORD)amntrd;
				DOS_ERR = amntrd < 0L;
#else
				amntrd = dos_read(srcfh, G.g_xlen, G.g_xbuf);
#endif
				more = d_errmsg();
				if (more)
				{
					if (amntrd)
					{
#if GEMDOS
						amntwr = Fwrite(dstfh, amntrd, (void *)G.g_xbuf);
						DOS_AX = (WORD)amntwr;
						DOS_ERR = amntwr != amntrd;
#else
						amntwr = dos_write(dstfh, amntrd, G.g_xbuf);
#endif
						more = d_errmsg();
						if (more)
						{
							if (amntrd != amntwr)
							{
								/* disk full */
								graf_mouse(ARROW, 0x0L);
								fun_alert(1, STDISKFU, NULL);
								graf_mouse(HRGLASS, 0x0L);
								more = FALSE;
#if GEMDOS
								Fclose(srcfh);
								Fclose(dstfh);
								Fdelete(ADDR(pdst_file));
#else
								dos_close(srcfh);
								dos_close(dstfh);
								dos_delete(ADDR(pdst_file));
#endif
							} /* if */
						} /* if more */
					} /* if amntrd */
				} /* if more */
			} /* if more */
		} /* while */
		if (copy && more)
		{
#if GEMDOS
			dtime.time = time;
			dtime.date = date;
			DOS_AX = Fdatime( &dtime, dstfh, 1 );
			DOS_ERR = DOS_AX < 0;
			more = d_errmsg();
			Fclose(srcfh);
			Fclose(dstfh);
#else
			dos_setdt(dstfh, time, date);
			more = d_errmsg();
			dos_close(srcfh);
			dos_close(dstfh);
#endif
		}
		/* graf_mouse(ARROW, 0x0L); */
		return(more);
	}
} /* d_dofcopy */

/* Directory routine to DO an operation on an entire sub-directory. */
WORD d_doop(WORD op, LONG tree, WORD obj, BYTE *psrc_path, BYTE *pdst_path,
	WORD *pfcnt, WORD *pdcnt, WORD flag)
{
	BYTE	*ptmp;
	WORD	cont, skip, more, level;

	/* start recursion at level 0 */
	level = 0;
	/* set up initial DTA	*/
#if GEMDOS
	Fsetdta(ADDR(&G.g_fcbstk[level]));
	DOS_ERR = (Fsfirst(ADDR(psrc_path), 0x16) < 0);
	if (DOS_ERR)
		DOS_AX = E_NOFILES;
#else
	dos_sdta(ADDR(&G.g_fcbstk[level]));
	dos_sfirst(ADDR(psrc_path), 0x16);
#endif
	cont = more = TRUE;
	while (cont && more)
	{
		skip = FALSE;
		if (DOS_ERR)
		{
			/* no more files error */
			if ( (DOS_AX == E_NOFILES) || (DOS_AX == E_FILENOTFND) )
			{
				switch (op)
				{
					case OP_COUNT:
						G.g_ndirs++;
						break;
					case OP_DELETE:
						if (fold_wind(psrc_path))
						{
							DOS_ERR = TRUE;	/* trying to delete	*/
							DOS_AX = 16;	/* active directory	*/
						}
						else
						{
							ptmp = psrc_path;
							while (*ptmp != '*')
								ptmp++;
							ptmp--;
							*ptmp = '\0';
#if GEMDOS
							DOS_AX = Ddelete(ADDR(psrc_path));
							DOS_ERR = DOS_AX < 0;
#else
							dos_rmdir(ADDR(psrc_path));
#endif
						}
						more = d_errmsg();
						strcat(psrc_path, "\\*.*");
						break;
					case OP_COPY:
						break;
				}
				if (tree)
				{
					*pdcnt = -1;
					sprintf(&ml_dirs[0], "%d", *pdcnt);
					inf_sset(tree, ml_dlfo, &ml_dirs[0]);
					draw_fld(tree, ml_dlfo);
				}
				skip = TRUE;
				level--;
				if (level < 0)
					cont = FALSE;
				else
				{
					sub_path(psrc_path);
					if (op == OP_COPY)
						sub_path(pdst_path);
#if GEMDOS
					Fsetdta(ADDR(&G.g_fcbstk[level]));
#else
					dos_sdta(ADDR(&G.g_fcbstk[level]));
#endif
				}
			} /* if no more files */
			else
				more = d_errmsg();
		}
		if ( !skip && more )
		{
#if GEMDOS
			if ( G.g_fcbstk[level].d_attrib & FA_SUBDIR )
#else
			if ( G.g_fcbstk[level].fcb_attr & F_SUBDIR )
#endif
			{
				/* step down 1 level */
#if GEMDOS
				if ( (G.g_fcbstk[level].d_fname[0] != '.') &&
#else
				if ( (G.g_fcbstk[level].fcb_name[0] != '.') &&
#endif
					(level < (MAX_LEVEL-1)) )
				{
					/* change path name	*/
#if GEMDOS
					add_path(psrc_path, &G.g_fcbstk[level].d_fname[0]);
#else
					add_path(psrc_path, &G.g_fcbstk[level].fcb_name[0]);
#endif
					if (op == OP_COPY)
					{
#if GEMDOS
						add_fname(pdst_path, &G.g_fcbstk[level].d_fname[0]);
						DOS_AX = Dcreate(ADDR(pdst_path));
						DOS_ERR = DOS_AX < 0;
#else
						add_fname(pdst_path, &G.g_fcbstk[level].fcb_name[0]);
						dos_mkdir(ADDR(pdst_path));
#endif
						if ( (DOS_ERR) && (DOS_AX != E_NOACCESS) )
							more = d_errmsg();
						strcat(pdst_path, "\\*.*");
					}
					level++;
#if GEMDOS
					Fsetdta(ADDR(&G.g_fcbstk[level]));
#else
					dos_sdta(ADDR(&G.g_fcbstk[level]));
#endif
					if (more)
#if GEMDOS
						DOS_AX = (Fsfirst(ADDR(psrc_path), 0x16) < 0);
						if (DOS_ERR)
							DOS_AX = E_NOFILES;
#else
						dos_sfirst(ADDR(psrc_path), 0x16);
#endif
				} /* if not . or .. */
			} /* if not dir */
			else
			{
				if (op)
#if GEMDOS
					add_fname(psrc_path, &G.g_fcbstk[level].d_fname[0]);
#else
					add_fname(psrc_path, &G.g_fcbstk[level].fcb_name[0]);
#endif
				switch (op)
				{
					case OP_COUNT:
						G.g_nfiles++;
#if GEMDOS
						G.g_size += G.g_fcbstk[level].d_length;
#else
						G.g_size += G.g_fcbstk[level].fcb_size;
#endif
						break;
					case OP_DELETE:
						more = d_dofdel(psrc_path);
						break;
					case OP_COPY:
#if GEMDOS
						add_fname(pdst_path, &G.g_fcbstk[level].d_fname[0]);
						more = d_dofcopy(psrc_path, pdst_path,
						G.g_fcbstk[level].d_time,
						G.g_fcbstk[level].d_date,
						G.g_fcbstk[level].d_attrib);
#else
						add_fname(pdst_path, &G.g_fcbstk[level].fcb_name[0]);
						more = d_dofcopy(psrc_path, pdst_path,
						G.g_fcbstk[level].fcb_time,
						G.g_fcbstk[level].fcb_date,
						G.g_fcbstk[level].fcb_attr);
#endif
						del_fname(pdst_path);
						break;
				}
				if (op)
					del_fname(psrc_path);
				if (tree)
				{
					*pfcnt -= 1;
					sprintf(&ml_files[0], "%d", *pfcnt);
					inf_sset(tree, ml_dlfi, &ml_files[0]);
					draw_fld(tree, ml_dlfi);
				}
			}
		}
		if (cont)
		{
#if GEMDOS
			DOS_ERR = (Fsnext() < 0);
			if (DOS_ERR)
				DOS_AX = E_NOFILES;
#else
			dos_snext();
#endif
		}
	}
	if (op == OP_DELETE && !flag)
		blank_it(obj);
	return(more);
} /* d_doop */

/*
*	return pointer to next folder in path.
*	start at the current position of the ptr.
*	assume path will eventually end with \*.*
*/
BYTE *ret_path(REG BYTE *pcurr)
{
	REG BYTE	*path;

	/* find next level */
	while( (*pcurr) && (*pcurr != '\\') )
		pcurr++;
	pcurr++;
	/* get to current position */
	path = pcurr;
	/* find end of curr level */
	while( (*path) && (*path != '\\') )
		path++;
	*path = '\0';
	return(pcurr);
} /* ret_path */

/*
*	Check to see if source is a parent of the destination.
*	Return TRUE if all ok else FALSE.
* 	Must assume that src and dst paths both end with "\*.*".
*/
WORD par_chk(BYTE *psrc_path, FNODE *pflist, BYTE *pdst_path)
{
	REG BYTE	*tsrc, *tdst;
	WORD	same;
	REG FNODE	*pf;

	if (psrc_path[0] != pdst_path[0])	/* check drives	*/
		return(TRUE);
	else
	{
		tsrc = &G.g_srcpth[0];
		tdst = &G.g_dstpth[0];
		same = TRUE;
		do {
			/* new copies */
			strcpy(&G.g_srcpth[0], psrc_path);
			strcpy(&G.g_dstpth[0], pdst_path);
			/* get next paths */
			tsrc = ret_path(tsrc);
			tdst = ret_path(tdst);
			if ( strcmp(tsrc, "*.*") )
			{
				if ( strcmp(tdst, "*.*") )
					same = strcmp(tdst, tsrc);
				else
					same = FALSE;
			}
			else
			{
				/* check to same level	*/
				if ( !strcmp(tdst, "*.*") )
					same = FALSE;
				else
				{
					/* walk file list	*/
					for (pf=pflist; pf; pf=pf->f_next)
					{
						/* exit if same subdir	*/
						if ( (pf->f_obid != NIL) &&
							(G.g_screen[pf->f_obid].ob_state & SELECTED) &&
#if GEMDOS
							(pf->f_attr & FA_SUBDIR) &&
							!(pf->f_attr & FA_FAKE) &&
#else
							(pf->f_attr & F_SUBDIR) &&
							!(pf->f_attr & F_FAKE) &&
#endif
							(!strcmp(&pf->f_name[0], tdst)) )
						{
							/* INVALID	*/
							fun_alert(1, STBADCOP, NULL);
							return(FALSE);
						}
					}
					same = FALSE;	/* ALL OK */
				}
			}
		} while(same);
		return(TRUE);
	}
} /* par_chk */

/*
*	DIRectory routine that does an OPeration on all the selected files and
*	folders in the source path.  The selected files and folders are 
*	marked in the source file list.
*/
WORD dir_op(WORD op, BYTE *psrc_path, FNODE *pflist, BYTE *pdst_path,
	WORD *pfcnt, WORD *pdcnt, LONG *psize, WORD dulx, WORD duly,
	WORD from_disk, WORD src_ob)
{
	LONG	tree;
	FNODE	*pf;
	WORD	ret, more, obj;
	BYTE	*pglsrc, *pgldst;
#if MULTIAPP
#else
	LONG	lavail;
#endif

	/* BugFix */
	graf_mouse(HOURGLASS, 0x0L);
	pglsrc = &G.g_srcpth[0];
	pgldst = &G.g_dstpth[0];
	tree = 0x0L;
	ml_havebox = FALSE;
	switch(op)
	{
		case OP_COUNT:
			G.g_nfiles = 0x0L;
			G.g_ndirs = 0x0L;
			G.g_size = 0x0L;
			break;
		case OP_DELETE:
			ml_dlpr = G.g_cdelepref;
			if (ml_dlpr)
			{
				tree = G.a_trees[ADDELEDI];
				ml_dlfi = DDFILES;
				ml_dlfo = DDFOLDS;
				ml_dlok = DDOK;
				ml_dlcn = DDCNCL;
			}
			break;
		case OP_COPY:
#if MULTIAPP
			/* do malloc elsewhere */
#else
#if GEMDOS
			lavail = (LONG)Malloc(-1);
#else
			lavail = dos_avail();
#endif
			G.g_xlen = (lavail > 0x0000fff0L) ? 0xfff0 : LLOWD(lavail);
			G.g_xlen -= 0x0200;
			G.g_xbuf = (LONG)malloc( LW(G.g_xlen) );
#endif
			ml_dlpr = G.g_ccopypref;
			if (ml_dlpr)
			{
				tree = G.a_trees[ADCOPYDI];
				ml_dlfi = CDFILES;
				ml_dlfo = CDFOLDS;
				ml_dlok = CDOK;
				ml_dlcn = CDCNCL;
			}
			break;
	} /* switch */

	if (tree)
	{
		sprintf(&ml_files[0], "%d", *pfcnt);
		inf_sset(tree, ml_dlfi, &ml_files[0]);
		sprintf(&ml_dirs[0], "%d", *pdcnt);
		inf_sset(tree, ml_dlfo, &ml_dirs[0]);
		ml_havebox = TRUE;
		show_hide(FMD_START, tree);
		graf_mouse(ARROW, 0x0L);
		form_do((OBJECT FAR *)tree, 0);
		graf_mouse(HOURGLASS, 0x0L);
		ret = inf_what(tree, ml_dlok, ml_dlcn);
	}
	else
		ret = TRUE;

	more = ret;
	for (pf = pflist; pf && more; pf = pf->f_next)
	{
		if ( (pf->f_obid != NIL) &&
			(G.g_screen[pf->f_obid].ob_state & SELECTED) &&
#if GEMDOS
			!(pf->f_attr & FA_FAKE) )
#else
			!(pf->f_attr & F_FAKE) )
#endif
		{
			strcpy(pglsrc, psrc_path);
			if (op == OP_COPY)
			{
				strcpy(pgldst, pdst_path);
				if (!ml_dlpr)	/* show the moving icon! */
				{
					if (from_disk)
						obj = src_ob;
					else
						obj = pf->f_obid;
					move_icon(obj, dulx, duly);
	 			} /* if */
			} /* if OP_COPY */
#if GEMDOS
			if (pf->f_attr & FA_SUBDIR)
#else
			if (pf->f_attr & F_SUBDIR)
#endif
			{			   
				add_path(pglsrc, &pf->f_name[0]);
				if (op == OP_COPY)
				{
					like_parent(pgldst, &pf->f_name[0]);
#if GEMDOS
					DOS_AX = Dcreate(ADDR(pgldst));
					DOS_ERR = DOS_AX < 0;
#else
					dos_mkdir(ADDR(pgldst));
#endif
					while (DOS_ERR && more)
					{
						/* see if dest folder already exists */
						if (DOS_AX == E_NOACCESS)
						{
							if ( same_fold(pglsrc, pgldst) )
							{
								/* get the folder name from the pathnames */
								fmt_str(&pf->f_name[0], &ml_fsrc[0]);
								ml_fdst[0] = '\0';
								/* put in folder name in dialog */
								inf_sset(G.a_trees[ADCPALER], 2, &ml_fsrc[0]);
								inf_sset(G.a_trees[ADCPALER], 3, &ml_fdst[0]);
								/* show dialog */
								do_namecon();
								/* if okay then make dir or try again */
								/* until we succeed or cancel is hit */
								more = inf_what(G.a_trees[ADCPALER], 
									CAOK, CACNCL);

								if (more)
								{
									inf_sget(G.a_trees[ADCPALER], 3, 
										&ml_fdst[0]);
									unfmt_str(&ml_fdst[0], &ml_fstr[0]);
									del_fname(pgldst);
									if (ml_fstr[0] != '\0')
									{
										add_fname(pgldst, &ml_fstr[0]);
#if GEMDOS
										Dcreate(ADDR(pgldst));
#else
										dos_mkdir(ADDR(pgldst));
#endif
									} /* if */
									else
										more = FALSE;
								} /* if more */
							} /* if */
							else
								DOS_ERR = FALSE;
						} /* if NOACCESS */
						else
							more = FALSE;
					} /* while */
					strcat(pgldst, "\\*.*");
				} /* if */
				if (more)
					more = d_doop(op, tree, pf->f_obid, pglsrc, pgldst,
						pfcnt, pdcnt, ml_dlpr);
			} /* if SUBDIR */
			else
			{
				if (op)
					add_fname(pglsrc, &pf->f_name[0]);
				switch (op)
				{
					case OP_COUNT:
						G.g_nfiles++;
						G.g_size += pf->f_size;
						break;
					case OP_DELETE:
						more = d_dofdel(pglsrc);
						if (!ml_dlpr)
							blank_it(pf->f_obid);
						break;
					case OP_COPY:
						add_fname(pgldst, &pf->f_name[0]);
						more = d_dofcopy(pglsrc, pgldst, pf->f_time,
							pf->f_date, pf->f_attr);
						del_fname(pgldst);
						break;
				}
				if (op)
					del_fname(psrc_path);
				if (tree)
				{
					*pfcnt = -1;
					sprintf(&ml_files[0], "%d", *pfcnt);
					inf_sset(tree, ml_dlfi, &ml_files[0]);
					draw_fld(tree, ml_dlfi);
				} /* if tree */
			} /* else */
		} /* if */
	} /* for */

	switch(op)
	{
		case OP_COUNT:
			*pfcnt = (WORD)G.g_nfiles;
			*pdcnt = (WORD)G.g_ndirs;
			*psize = G.g_size;
			break;
		case OP_DELETE:
			break;
		case OP_COPY:
#if MULTIAPP
			/* no need to free with proc_malloc */
#else
			free((void *)G.g_xbuf);
#endif
			break;
	} /* switch */
	if (ml_havebox)
		show_hide(FMD_FINISH, G.a_trees[ADCPALER]);
	graf_mouse(HOURGLASS, 0x0L);
	return(TRUE);
} /* dir_op */

/* blank_it */
/* blit white over just-deleted icon */
VOID blank_it(WORD obid)
{
	WORD	blt_x, blt_y, blt_w, blt_h, pxy[4];
	GRECT	clipr;
	ICONBLK	*piblk;

	graf_mouse(M_OFF, 0x0L);
	wind_get(G.g_wlastsel, WF_WORKXYWH, &clipr.g_x, &clipr.g_y,
		&clipr.g_w, &clipr.g_h);
	gsx_sclip(&clipr);
	objc_offset(ADDR(&G.g_screen[0]), obid, &blt_x, &blt_y);
	if (G.g_iview == V_ICON)
	{
		piblk = (ICONBLK *)get_spec(G.g_screen, obid);
		blt_x += piblk->ib_xtext;
		blt_y += piblk->ib_yicon;
		blt_w = piblk->ib_wtext;
		blt_h = piblk->ib_hicon + piblk->ib_htext;
	} /* if V_ICON */
	else	/* view is V_TEXT */
	{
		blt_w = gl_wchar * MAX_TWIDTH;
		blt_h = gl_hchar + 1;
	} /* else */
	vswr_mode(gl_handle, MD_REPLACE);
	vsf_interior(gl_handle, FIS_SOLID);
	vsf_style(gl_handle, IP_SOLID);
	vsf_color(gl_handle, WHITE);
	pxy[0] = blt_x;
	pxy[1] = blt_y;
	pxy[2] = blt_x + blt_w - 1;
	pxy[3] = blt_y + blt_h - 1;
	vr_recfl( gl_handle, &pxy[0] );
	vsf_color(gl_handle, BLACK);
	vswr_mode(gl_handle, MD_XOR);
	gsx_attr(FALSE, MD_XOR, BLACK);
	graf_mouse(M_ON, 0x0L);
} /* blank_it */

/* move_icon */
/* animate an icon moving from its place on the desktop to dulx,duly */
VOID move_icon(WORD obj, WORD dulx, WORD duly)
{
	WORD	sulx, suly, w, h;

	objc_offset(ADDR(&G.g_screen[0]), obj, &sulx, &suly);
	if (G.g_iview == V_ICON)
	{
		w = G.g_wicon;
		h = G.g_hicon;
	} /* if V_ICON */
	else	/* view must be V_TEXT */
	{
		w = gl_wchar * MAX_TWIDTH;
		h = gl_hchar;
	} /* else */
	graf_mbox(w, h, sulx, suly, dulx, duly);
} /* move_icon */
