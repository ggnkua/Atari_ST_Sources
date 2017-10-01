/*	DESKINF.C	09/03/84 - 05/29/85	Gregg Morris		*/
/*	for 3.0	& 2.1	5/5/86			MDF			*/
/*	merge source	5/27/87  - 5/28/87	mdf			*/

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

#include <stdio.h>
#include <portab.h>
#include <machine.h>
#if GEMDOS
#if TURBO_C
#include <aes.h>
#include <vdi.h>
#include <tos_intr.h>
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
#include "deskinf.h"
#include "deskbind.h"
#include "deskdir.h"
#include "deskgraf.h"
#include "deskrsrc.h"
#include "optimize.h"
#include "deskinf.h"

EXTERN BYTE	gl_amstr[];
EXTERN BYTE	gl_pmstr[];

EXTERN LONG	ad_intin;

EXTERN GLOBES	G;

#define SFCB struct sfcb
SFCB
{
	BYTE		sfcb_junk;
	BYTE		sfcb_attr;
	WORD		sfcb_time;
	WORD		sfcb_date;
	LONG		sfcb_size;
	BYTE		sfcb_name[13];
};

/* my_itoa */
VOID my_itoa(UWORD number, BYTE *pnumstr)
{
	WORD	ii;

	for (ii = 0; ii < 2; pnumstr[ii++] = '0')
		;
	pnumstr[2] = '\0';
	if (number > 9)
		sprintf(pnumstr, "%d", number);
	else
		sprintf(pnumstr+1, "%d", number);
} /* my_itoa */

/*
*	Routine to format DOS style time.
*
*	15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0
*	<     hh     > <    mm    > <   xx  >
*	hh = binary 0-23
*	mm = binary 0-59
*	xx = binary seconds \ 2 
*
*	put into this form 12:45 pm
*/
VOID fmt_time(UWORD time, BYTE *ptime)
{
	WORD	pm, val;

	val = ((time & 0xf800) >> 11) & 0x001f;
	if (G.g_ctimeform)
	{
		if (val >= 12)
		{
			if (val > 12)
				val -= 12;
			pm = TRUE;
		}
		else
		{
			if (val == 0)
				val = 12;
			pm = FALSE;
		}
	}
	my_itoa( val, &ptime[0]);
	my_itoa( ((time & 0x07e0) >> 5) & 0x003f, &ptime[2]);
	if (G.g_ctimeform)
		strcpy(&ptime[4], (pm?&gl_pmstr[0]:&gl_amstr[0]));
	else
		strcpy(&ptime[4], "  ");
} /* fmt_time */

/*
*	Routine to format DOS style date.
*	
*	15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0
*	<     yy          > < mm  > <  dd   >
*	yy = 0 - 119 (1980 - 2099)
*	mm = 1 - 12
*	dd = 1 - 31
*/
VOID fmt_date(UWORD date, BYTE *pdate)
{
	if (G.g_cdateform)
	{
		my_itoa( (date & 0x01e0) >> 5, &pdate[0]);
		my_itoa(date & 0x001f, &pdate[2]);
	}
	else
	{
		my_itoa(date & 0x001f, &pdate[0]);
		my_itoa( (date & 0x01e0) >> 5, &pdate[2]);
	}
	my_itoa(80 + (((date & 0xfe00) >> 9) & 0x007f), &pdate[4]);
} /* fmt_date */

WORD ob_sfcb(LONG psfcb, BYTE *pfmt)
{
	SFCB	sf;
	BYTE	*pdst, *psrc;
	BYTE	pdate_str[7], ptime_str[7], psize_str[9];
	WORD	cnt;

	LBCOPY(ADDR(&sf.sfcb_junk), psfcb, sizeof(SFCB));
	pdst = pfmt;
	psrc = &sf.sfcb_name[0];
	*pdst++ = ' ';
#if GEMDOS
	*pdst++ = (sf.sfcb_attr & FA_SUBDIR) ? 0x07 : ' ';
#else
	*pdst++ = (sf.sfcb_attr & F_SUBDIR) ? 0x07 : ' ';
#endif
	*pdst++ = ' ';
#if GEMDOS
	if (sf.sfcb_attr & FA_DESKTOP)
#else
	if (sf.sfcb_attr & F_DESKTOP)
#endif
	{
		*pdst++ = sf.sfcb_junk;
		*pdst++ = ':';
		*pdst++ = ' ';
	}
	else
	{
		while( (*psrc) && (*psrc != '.') )
			*pdst++ = *psrc++;
		while( (pdst - pfmt) < 12 )
			*pdst++ = ' ';
		if (*psrc)
			psrc++;
		while (*psrc)
			*pdst++ = *psrc++;
	}
	while( (pdst - pfmt) < 16 )
		*pdst++ = ' ';
	psrc = &psize_str[0];
#if GEMDOS
	if (sf.sfcb_attr & FA_SUBDIR)
#else
	if (sf.sfcb_attr & F_SUBDIR)
#endif
		*psrc = '\0';
	else
		sprintf(&psize_str[0], "%ld", sf.sfcb_size);
	for(cnt = 8 - (WORD)strlen(psrc); cnt--; *pdst++ = ' ')
		;
	while (*psrc)
		*pdst++ = *psrc++;
	*pdst++ = ' ';
	*pdst++ = ' ';
	fmt_date(sf.sfcb_date, &pdate_str[0]);
	psrc = &pdate_str[0];
	for (cnt = 3; cnt--; )
	{
		*pdst++ = *psrc++;
		*pdst++ = *psrc++;
		if (cnt)
			*pdst++ = '-';
	}
	*pdst++ = ' ';
	*pdst++ = ' ';
	fmt_time(sf.sfcb_time, &ptime_str[0]);
	psrc = &ptime_str[0];
	for (cnt = 2; cnt--; )
	{
		*pdst++ = *psrc++;
		*pdst++ = *psrc++;
		if (cnt)
			*pdst++ = ':';
	}
	*pdst++ = ' ';
	strcpy(pdst, &ptime_str[4]);
	pdst += 3;
	return((WORD)(pdst - pfmt));
}	

WORD dr_fnode(UWORD last_state, UWORD curr_state,
	WORD x, WORD y, WORD w, WORD h, LONG psfcb)
{
	WORD	len;
	BYTE	dum[81];

	if ((last_state ^ curr_state) & SELECTED)
		bb_fill(MD_XOR, FIS_SOLID, IP_SOLID, x, y, w, h);
	else
	{
		len = ob_sfcb(psfcb, &G.g_tmppth[0]);
		strncpy(dum, ADDR(&G.g_tmppth[0]), 81);
		if (len > 80)
			dum[80] = '\0';
		gsx_attr(TRUE, MD_REPLACE, BLACK);
		gsx_tblt(IBM, x, y, dum);
		gsx_attr(FALSE, MD_XOR, BLACK);
	}
	return(curr_state);
}

WORD dr_code(LONG pparms)
{
	PARMBLK	pb;
	GRECT	oc;
	WORD	state;

	LBCOPY(ADDR(&pb), pparms, sizeof(PARMBLK));
	gsx_gclip(&oc);
	gsx_sclip((GRECT *)&pb.pb_xc);
	state = dr_fnode(pb.pb_prevstate, pb.pb_currstate,
		 pb.pb_x, pb.pb_y, pb.pb_w, pb.pb_h, pb.pb_parm);
	gsx_sclip(&oc);
	return(state);
}

/* Put up dialog box & call form_do. */
WORD inf_show(LONG tree, WORD start)
{
	WORD	xd, yd, wd, hd;

	form_center((OBJECT FAR *)tree, &xd, &yd, &wd, &hd);
	form_dial(FMD_START, 0, 0, 0, 0, xd, yd, wd, hd);
	objc_draw((OBJECT FAR *)tree, ROOT, MAX_DEPTH, xd, yd, wd, hd);
	form_do((OBJECT FAR *)tree, start);
	form_dial(FMD_FINISH, 0, 0, 0, 0, xd, yd, wd, hd);
	return(TRUE);
}

/* Routine for finishing off a simple ok-only dialog box */
VOID inf_finish(LONG tree, WORD dl_ok)
{
	inf_show(tree, 0);
	LWSET(OB_STATE(dl_ok), NORMAL);
}

/*
*	Routine to get number of files and folders and stuff them in
*	a dialog box.
*/
WORD inf_fifo(LONG tree, WORD dl_fi, WORD dl_fo, BYTE *ppath)
{
	WORD	junk, more;
	BYTE	nf_str[6], nd_str[6];

	G.g_nfiles = 0x0L;
	G.g_ndirs = 0x0L;
	G.g_size = 0x0L;
	more = d_doop(OP_COUNT, (LONG)NULL, NIL, ppath, ppath, &junk, &junk, 1);
	if (!more)
		return(FALSE);
	else
	{
		G.g_ndirs--;

		sprintf(&nf_str[0], "%ld", G.g_nfiles);
		inf_sset(tree, dl_fi, &nf_str[0]);

		sprintf(&nd_str[0], "%ld", G.g_ndirs);
		inf_sset(tree, dl_fo, &nd_str[0]);
		return(TRUE);
	}
}

VOID inf_dttmsz(LONG tree, FNODE *pf, WORD dl_dt, WORD dl_tm, WORD dl_sz,
	LONG *psize)
{
	BYTE	psize_str[9], ptime_str[7], pdate_str[7];

	fmt_date(pf->f_date, &pdate_str[0]);
	inf_sset(tree, dl_dt, &pdate_str[0]);

	fmt_time(pf->f_time, &ptime_str[0]);
	inf_sset(tree, dl_tm, &ptime_str[0]);

	sprintf(&psize_str[0], "%ld", *psize);
	inf_sset(tree, dl_sz, &psize_str[0]);
}

/* inf_file */
WORD inf_file(BYTE *ppath, FNODE *pfnode)
{
	LONG	tree;
	WORD	attr, more, nmidx;
	BYTE	poname[13], pnname[13];

	tree = G.a_trees[ADFILEIN];

	strcpy(&G.g_srcpth[0], ppath);
	strcpy(&G.g_dstpth[0], ppath);
	nmidx = 0;
	while (G.g_srcpth[nmidx] != '*')
		nmidx++;

	fmt_str(&pfnode->f_name[0], &poname[0]);

	inf_sset(tree, FINAME, &poname[0]);

	inf_dttmsz(tree, pfnode, FIDATE, FITIME, FISIZE, &pfnode->f_size);

#if GEMDOS
	inf_fldset(tree, FIRONLY, pfnode->f_attr, FA_READONLY,SELECTED, NORMAL);
	inf_fldset(tree, FIRWRITE, pfnode->f_attr, FA_READONLY,NORMAL,SELECTED);
#else
	inf_fldset(tree, FIRONLY, pfnode->f_attr, F_RDONLY,SELECTED, NORMAL);
	inf_fldset(tree, FIRWRITE, pfnode->f_attr, F_RDONLY,NORMAL,SELECTED);
#endif

	inf_show(tree, 0);
	/* now find out what happened was it OK or CANCEL? */
	if ( inf_what(tree, FIOK, FICNCL) )
	{
		graf_mouse(HOURGLASS, 0x0L);

		more = TRUE;
		inf_sget(tree, FINAME, &pnname[0]);
		/* unformat the strings */
		unfmt_str(&poname[0], &G.g_srcpth[nmidx]);
		unfmt_str(&pnname[0], &G.g_dstpth[nmidx]);
		/* do the DOS rename */
		if ( strcmp(&G.g_srcpth[nmidx], &G.g_dstpth[nmidx]) )
		{
#if GEMDOS
			Frename(0, ADDR(&G.g_srcpth[0]), ADDR(&G.g_dstpth[0]));
#else
			dos_rename(ADDR(&G.g_srcpth[0]), ADDR(&G.g_dstpth[0]));
#endif
			if ( (more = d_errmsg()) != 0 )
				strcpy(&pfnode->f_name[0], &G.g_dstpth[nmidx]);
		} /* if */
		/* update the attributes */
		attr = pfnode->f_attr;
#if GEMDOS
		if (LWGET(OB_STATE(FIRONLY)) & SELECTED)
			attr |= FA_READONLY;
		else
			attr &= ~FA_READONLY;
#else
		if (LWGET(OB_STATE(FIRONLY)) & SELECTED)
			attr |= F_RDONLY;
		else
			attr &= ~F_RDONLY;
#endif
		if ( (BYTE) attr != pfnode->f_attr )
		{
#if GEMDOS
			Fattrib(ADDR(&G.g_dstpth[0]), 1, attr);
#else
			dos_chmod(ADDR(&G.g_dstpth[0]), F_SETMOD, attr);
#endif
			if ( (more = d_errmsg()) != 0 )
				pfnode->f_attr = attr;
		}
		graf_mouse(ARROW, 0x0L);
		return(more);
	}
	else
		return(FALSE);
} /* inf_file */

/* inf_folder */
WORD inf_folder(BYTE *ppath, FNODE *pf)
{
	LONG	tree;
	WORD	more;
	BYTE	*pname, fname[13];

	graf_mouse(HOURGLASS, 0x0L);	

	tree = G.a_trees[ADFOLDIN];

	strcpy(&G.g_srcpth[0], ppath);
	pname = &G.g_srcpth[0];
	while (*pname != '*')
		pname++;
	pname = strcpy(pname, &pf->f_name[0]);
	strcpy(pname-1, "\\*.*");

	more = inf_fifo(tree, FOLNFILE, FOLNFOLD, &G.g_srcpth[0]);

	graf_mouse(ARROW, 0x0L);
	if (more)
	{
		fmt_str(&pf->f_name[0], &fname[0]);
		inf_sset(tree, FOLNAME, &fname[0]);

		inf_dttmsz(tree, pf, FOLDATE, FOLTIME, FOLSIZE, &G.g_size);
		inf_finish(tree, FOLOK);
	}
	return(TRUE);
} /* inf_folder */

#if GEMDOS

int Dlabel(int drive, char *name)
{
	DTA	*pold, new;
	int ret;

	pold = Fgetdta();
	Dsetdrv(drive);
	Fsetdta(&new);
	ret = Fsfirst("*.*", 0x08);
	if (ret == 0)
		strcpy(name,new.d_fname);
	else
		name[0] = '\0';
	Fsetdta(pold);
	return(ret);
}

#endif

/* inf_disk */
WORD inf_disk(BYTE dr_id)
{
	LONG	tree;
	LONG	avail;
	WORD	more;
	BYTE	puse_str[9], pav_str[9], plab_str[12];
	BYTE	drive[2];
#if GEMDOS
	DISKINFO	dinf;
#else
	LONG	total;
#endif

	graf_mouse(HOURGLASS, 0x0L);
	tree = G.a_trees[ADDISKIN];

	drive[0] = dr_id;
	drive[1] = '\0';
	G.g_srcpth[0] = drive[0];
	strcpy(&G.g_srcpth[1], ":\\*.*");

	more = inf_fifo(tree, DINFILES, DINFOLDS, &G.g_srcpth[0]);

	graf_mouse(ARROW, 0x0L);
	if (more)
	{
#if GEMDOS
		Dfree(&dinf, dr_id - 'A' + 1);
		avail = dinf.b_free * dinf.b_secsiz * dinf.b_clsiz;
		Dlabel(dr_id - 'A' + 1, &plab_str[0]);
#else
		dos_space(dr_id - 'A' + 1, &total, &avail);
		dos_label(dr_id - 'A' + 1, &plab_str[0]);
#endif

		inf_sset(tree, DIDRIVE, &drive[0]);
		inf_sset(tree, DIVOLUME, &plab_str[0]);

		sprintf(&puse_str[0], "%ld", G.g_size);
		inf_sset(tree, DIUSED, &puse_str[0]);

		sprintf(&pav_str[0], "%ld", avail);
		inf_sset(tree, DIAVAIL, &pav_str[0]);

		inf_finish(tree, DIOK);
	}
	return(TRUE);
} /* inf_disk */

/* Set preferences dialog. */
WORD inf_pref(VOID)
{
	LONG	tree;
	WORD	cyes, cno, i;
	WORD	sndefpref;
	WORD	rbld;

	tree = G.a_trees[ADSETPRE];
	rbld = FALSE;

	cyes = (G.g_cdelepref) ? SELECTED : NORMAL;
	cno = (G.g_cdelepref) ? NORMAL : SELECTED;
	LWSET(OB_STATE(SPCDYES), cyes);
	LWSET(OB_STATE(SPCDNO), cno);

	cyes = (G.g_ccopypref) ? SELECTED : NORMAL;
	cno = (G.g_ccopypref) ? NORMAL : SELECTED;
	LWSET(OB_STATE(SPCCYES), cyes);
	LWSET(OB_STATE(SPCCNO), cno);

	cyes = (G.g_covwrpref) ? SELECTED : NORMAL;
	cno = (G.g_covwrpref) ? NORMAL : SELECTED;
	LWSET(OB_STATE(SPCOWYES), cyes);
	LWSET(OB_STATE(SPCOWNO), cno);

	cyes = (G.g_cmclkpref) ? SELECTED : NORMAL;
	cno = (G.g_cmclkpref) ? NORMAL : SELECTED;
	LWSET(OB_STATE(SPMNCLKY), cyes);
	LWSET(OB_STATE(SPMNCLKN), cno);

	cyes = (G.g_ctimeform) ? SELECTED : NORMAL;
	cno = (G.g_ctimeform) ? NORMAL : SELECTED;
	LWSET(OB_STATE(SPTF12HR), cyes);
	LWSET(OB_STATE(SPTF24HR), cno);

	cyes = (G.g_cdateform) ? SELECTED : NORMAL;
	cno = (G.g_cdateform) ? NORMAL : SELECTED;
	LWSET(OB_STATE(SPDFMMDD), cyes);
	LWSET(OB_STATE(SPDFDDMM), cno);

	for(i=0; i<5; i++)
		LWSET(OB_STATE(SPDC1+i), NORMAL);

	G.g_cdclkpref = evnt_dclick(0, FALSE);
	LWSET(OB_STATE(SPDC1+G.g_cdclkpref), SELECTED);

#if GEM & (GEM2 | GEM3 | XGEM)
	sndefpref = !sound(FALSE, 0xFFFF, 0);
#else
	sndefpref = FALSE;
#endif

	cyes = (sndefpref) ? SELECTED : NORMAL;
	cno = (sndefpref) ? NORMAL : SELECTED;
	LWSET(OB_STATE(SPSEYES), cyes);
	LWSET(OB_STATE(SPSENO), cno);

	inf_show(tree, 0);

	if ( inf_what(tree, SPOK, SPCNCL) )
	{
		G.g_cdelepref = inf_what(tree, SPCDYES, SPCDNO);
		G.g_ccopypref = inf_what(tree, SPCCYES, SPCCNO);
		G.g_covwrpref = inf_what(tree, SPCOWYES, SPCOWNO);
		G.g_cmclkpref = inf_what(tree, SPMNCLKY, SPMNCLKN);
		menu_click(G.g_cmclkpref, TRUE);
		G.g_cdclkpref = inf_gindex(tree, SPDC1, 5);
		G.g_cdclkpref = evnt_dclick(G.g_cdclkpref, TRUE);
		sndefpref = inf_what(tree, SPSEYES, SPSENO);
		/* changes if file display? */
		cyes = inf_what(tree, SPTF12HR, SPTF24HR);
		if (G.g_ctimeform != cyes)
		{
			rbld = (G.g_iview == V_TEXT);
			G.g_ctimeform = cyes;
		}
		cyes = inf_what(tree, SPDFMMDD, SPDFDDMM);
		if (G.g_cdateform != cyes)
		{
			rbld |= (G.g_iview == V_TEXT);
			G.g_cdateform = cyes;
		}
#if GEM & (GEM2 | GEM3 | XGEM)
		sound(FALSE, !sndefpref, 0);
#endif
	}
	return(rbld);
} /* inf_pref */

/* Open application icon */
WORD opn_appl(BYTE *papname, BYTE *papparms, BYTE *pcmd, BYTE *ptail)
{
	LONG	tree;
	BYTE	poname[13];

	tree = G.a_trees[ADOPENAP];
	fmt_str(papname, &poname[0]);
	inf_sset(tree, APPLNAME, &poname[0]);
	inf_sset(tree, APPLPARM, papparms);
	inf_show(tree, APPLPARM);
	/* now find out what happened	*/
	if ( inf_what(tree, APPLOK, APPLCNCL) )
	{
		inf_sget(tree, APPLNAME, &poname[0]);
		unfmt_str(&poname[0], pcmd);
		inf_sget(tree, APPLPARM, ptail);
		return(TRUE);
	}
	else
		return(FALSE);
}
