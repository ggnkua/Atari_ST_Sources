/*	DESKINS.C	09/22/84 - 06/19/85	Lee Lorenzen		*/
/*	for 3.0		02/28/86			MDF		*/
/*	merge source	5/27/87	 - 5/28/87		mdf		*/

/*
*	-------------------------------------------------------------
*	GEM Desktop					  Version 2.3
*	Serial No.  XXXX-0000-654321		  All Rights Reserved
*	Copyright (C) 1985 - 1987		Digital Research Inc.
*	-------------------------------------------------------------
*/

#include <stddef.h>
#include <string.h>
#include <rclib.h>
#include <portab.h>
#include <machine.h>
#if GEMDOS
#if TURBO_C
#include <aes.h>
#endif
#else
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
#include "deskdir.h"
#include "deskrsrc.h"
#include "optimize.h"
#include "deskins.h"

EXTERN WORD	gl_hbox;
EXTERN BYTE	gl_lngstr[256];

#if ALCYON
EXTERN BYTE	*gl_pstart;
#else
EXTERN WORD	gl_pstart;
#endif

EXTERN WORD	gl_numics;

EXTERN GLOBES	G;

GLOBAL ICONBLK	gl_aib;
GLOBAL ICONBLK	gl_dib;

#define max(x,y) ((x)>(y)?(x):(y))

/* Routine to tell if an icon has an associated document type. */
WORD is_installed(ANODE *pa)
{
	return ( !((*pa->a_pappl == '*') || (*pa->a_pappl == '?') ||
		(*pa->a_pappl == '\0')  ) );
}

/*
*	Routine to find out if this icon is the last disk icon on the
*	screen.
*/
WORD lastdisk(VOID)
{
	WORD	i;
	ANODE	*pa;

	i = 0;
	for(pa=G.g_ahead; pa; pa=pa->a_next)
	{
		if (pa->a_type == AT_ISDISK)
			i++;
	}
	return( (i < 2) );
}

/*
*	Routine to place disk icon between the current disk icon and
*	the trash can
*/
/*
VOID ins_posdisk(WORD dx, WORD dy, WORD *pdx, WORD *pdy)
{
	WORD	tx, ty;
	WORD	xdiff, ydiff, xdir, ydir;
	ANODE	*pa;

	for(pa=G.g_ahead; pa; pa=pa->a_next)
	{
		if (pa->a_type == AT_ISTRSH)
		{
			tx = pa->a_xspot;
			ty = pa->a_yspot;
			break;
		}
	}

	xdiff = tx - dx;
	ydiff = ty - dy;

	xdir = (xdiff < 0) ? -1 : 1;
	ydir = (ydiff < 0) ? -1 : 1;

	xdiff *= xdir;
	ydiff *= ydir;

	if (ydiff > xdiff)
	{
		*pdx = dx;
		*pdy = dy + (G.g_ich * ydir);
	}
	else
	{
		*pdx = dx + (G.g_icw * xdir);
		*pdy = dy;
	}
}
*/

/*
*	Routine to find out if there is another icon with this letter already
*	on the desktop.
*/
ANODE *get_disk(WORD letter)
{
	ANODE	*pa;

	for (pa=G.g_ahead; pa; pa=pa->a_next)
	{
		if ((pa->a_type == AT_ISDISK) && (pa->a_letter == letter) )
			return(pa);
	}
	return( 0 );
}

/* ins_disk */
WORD ins_disk(ANODE *pa)
{
	LONG	tree;
	WORD	change, icon, flop, hard, fld;
	BYTE	cletter[2], clabel[13];
	BYTE	nletter[2], nlabel[13];
	ANODE	*newpa;

	tree = G.a_trees[ADINSDIS];

	change = FALSE;
	cletter[0] = pa->a_letter;
	cletter[1] = '\0';
	strcpy(&clabel[0], pa->a_pappl);

	inf_sset(tree, DRID, &cletter[0]);
	inf_sset(tree, DRLABEL, &clabel[0]);

	flop = (pa->a_aicon == IG_FLOPPY) ? SELECTED : NORMAL;
	hard = (pa->a_aicon == IG_HARD) ? SELECTED : NORMAL;
	LWSET(OB_STATE(DRFLOPPY), flop);
	LWSET(OB_STATE(DRHARD), hard);
	LWSET(OB_STATE(DRREM), (lastdisk()) ? DISABLED : NORMAL ); 

	inf_show(tree, 0);	

	inf_sget(tree, DRID, &nletter[0]);
	inf_sget(tree, DRLABEL, &nlabel[0]);
	fld = inf_gindex(tree, DRINST, 3);	/* which exit button?	*/
	LWSET(OB_STATE(DRINST + fld), NORMAL);
	icon = ( LWGET(OB_STATE(DRFLOPPY)) & SELECTED );
	icon = (icon) ? IG_FLOPPY : IG_HARD;
	if ( fld == 0 )	/* Install */
	{
		if ( (cletter[0] != nletter[0]) && (nletter[0] != '\0') )
		{
			newpa = get_disk(nletter[0]);
			if (!newpa)
			{
				newpa = app_alloc(FALSE);
				if (newpa)
				{
					newpa->a_flags = pa->a_flags;
					newpa->a_type = pa->a_type;
					newpa->a_obid = pa->a_obid;
					newpa->a_pappl = pa->a_pappl;
					scan_str("@", &newpa->a_pdata);
					newpa->a_aicon = pa->a_aicon;
					newpa->a_dicon = NIL;
					newpa->a_letter = nletter[0];
				} /* if newpa */
				else
					fun_alert(1, STAPGONE, NULL);
			} /* if !newpa */
			if (newpa)
				pa = newpa;
			change = TRUE;
		} /* if cletter */
		/* see if icon changed	*/
		if (pa->a_aicon != icon)
		{
			pa->a_aicon = icon;
			change = TRUE;
		}
		/* see if label changed	*/
		if ( (!strcmp(&clabel[0], &nlabel[0])) && (nlabel[0] != '\0') )
		{
			nlabel[ strlen(&nlabel[0]) ] = '@';
			scan_str(&nlabel[0], &pa->a_pappl);
			change = TRUE;
		}
	} /* if INSTALL */
	else if ( fld == 1 )	/* Remove  */
	{
		/* find matching anode delete it */
		for (pa = G.g_ahead; pa; pa = pa->a_next)
		{
			if ( (pa->a_aicon == icon) && (pa->a_letter == nletter[0]) )
			{
				app_free(pa);
				change = TRUE;
			}
		} /* for */
	} /* if REMOVE */
	return(change);
} /* ins_disk */

VOID insa_icon(LONG tree, WORD obj, WORD nicon, ICONBLK *pic, BYTE *ptext)
{
	memcpy(pic, &G.g_iblist[nicon], sizeof(ICONBLK));
	pic->ib_ptext = ADDR( ptext );
	LWSET(OB_TYPE(obj), G_ICON);
	LLSET(OB_SPEC(obj), ADDR(pic));
}

VOID insa_elev(LONG tree, WORD nicon, WORD numics)
{
	WORD	y, h, th;
	LONG	lp;

	y = 0;
	th = h = LWGET(OB_HEIGHT(APFSVSLI));  
	if ( numics > 1)
	{
#if M68000
		h = h / numics;
#else
		h = mul_div(1, h, numics);
#endif
		h = max((gl_hbox/2)+2, h);	/* min size elevator */
#if M68000
		y = (WORD)((LONG)nicon * (LONG)(th-h) / (LONG)(numics-1));
#else
		y = mul_div(nicon, th-h, numics-1);
#endif
	}
	LWSET(OB_Y(APFSVELE), y);
	LWSET(OB_HEIGHT(APFSVELE), h);

	strcpy(&G.g_1text[0], ini_str(STAPPL));
	insa_icon(tree, APF1NAME, IA_GENERIC+nicon, &gl_aib, &G.g_1text[0]);

	strcpy(&G.g_2text[0], ini_str(STDOCU));
	insa_icon(tree, APF2NAME, ID_GENERIC+nicon, &gl_dib, &G.g_2text[0]);
#if ALCYON
	lp = G.a_datastart + *((BYTE **)(G.a_datastart + gl_pstart +
		(nicon * sizeof(BYTE *)) ) );
#else
	lp = G.a_datastart + LWGET(G.a_datastart + gl_pstart +
		(nicon * sizeof(BYTE *)) );
#endif
	LSTCPY(lp, ADDR(&gl_lngstr[0]));
	inf_sset(tree, APFTITLE, &gl_lngstr[0] );
} /* insa_elev */

WORD insa_dial(LONG tree, WORD nicon, WORD numics)
{
	WORD	firstslot, nstate, ystate, i;
	WORD	touchob, oicon, value;
	WORD	mx, my, kret, bret, cont;
	BYTE	*pstr, doctype[4];
	GRECT	pt;

	/* draw the form */
	show_hide(FMD_START, tree);
	/* init for while loop by forcing initial fs_newdir call */
	cont = TRUE;
	while ( cont )
	{
		firstslot = 6;
		for (i = 0; i < firstslot; i++)
		{
			pstr = &doctype[0];
			inf_sget(tree, APDFTYPE+i, pstr);
			if (*pstr == '\0')
				firstslot = i;
		}
		touchob = form_do((OBJECT FAR *)tree, APDFTYPE+firstslot);
		graf_mkstate(&mx, &my, &kret, &bret);

		value = nstate = ystate = 0;
		touchob &= 0x7fff;
		switch ( touchob )
		{
			case APINST:
			case APREMV:
			case APCNCL:
				cont = FALSE;
				break;
			case APFUPARO:
				value = -1;
				break;
			case APFDNARO:
				value = 1;
				break;
			case APGEM:
				nstate = SELECTED;
				ystate = DISABLED;
				break;
			case APDOS:
			case APPARMS:
				nstate = LWGET(OB_STATE(APNMEM));
				ystate = LWGET(OB_STATE(APYMEM));
				if ( ystate == DISABLED )
				{
					nstate = SELECTED;
					ystate = NORMAL;
				}
				break;
			case APFSVSLI:
				ob_actxywh(tree, APFSVELE, &pt);
				pt.g_x -= 3;
				pt.g_w += 6;
				if ( rc_inside(&pt, mx, my) )
					goto dofelev;
				value = (my <= pt.g_y) ? -1 : 1;
				break;
			case APFSVELE:
dofelev:		wind_update(3);
				ob_relxywh(tree, APFSVSLI, &pt);
				pt.g_x += 3;
				pt.g_w -= 6;
				LWSET(OB_X(APFSVSLI), pt.g_x);
				LWSET(OB_WIDTH(APFSVSLI), pt.g_w);
				value = graf_slidebox((OBJECT FAR *)tree, APFSVSLI, APFSVELE, TRUE);
				pt.g_x -= 3;
				pt.g_w += 6;
				LWSET(OB_X(APFSVSLI), pt.g_x);
				LWSET(OB_WIDTH(APFSVSLI), pt.g_w);
				wind_update(2);
#if M68000
				value = (WORD)((LONG)value * (LONG)(numics-1) / 1000) - nicon;
#else
				value = mul_div(value, numics-1, 1000) - nicon;
#endif
				break;
		}
		if (nstate != ystate)
		{
			LWSET(OB_STATE(APNMEM), nstate);
			LWSET(OB_STATE(APYMEM), ystate);
			draw_fld(tree, APMEMBOX);
		}
		if (value)
		{
			oicon = nicon;
			nicon += value;
			if (nicon < 0)
				nicon = 0;
			if (nicon >= numics)
				nicon = numics - 1;	
			if (oicon != nicon)
			{
				insa_elev(tree, nicon, numics);
				draw_fld(tree, APFTITLE);
				draw_fld(tree, APFSVSLI);
				draw_fld(tree, APFILEBO);
			}
		}
	}
	/* undraw the form	*/
	show_hide(FMD_FINISH, tree);
	return(nicon);
}

VOID insa_gtypes(LONG tree, BYTE *ptypes)
{
	WORD	i, j;
	BYTE	*pstr, doctype[4];

	j = 0;
	*ptypes = '\0';
	for(i=0; i<8; i++)
	{
		pstr = &doctype[0];
		inf_sget(tree, APDFTYPE+i, pstr);
		if (*pstr)
		{
			if (j != 0)
				ptypes[j++] = ','; 
			strcpy(&ptypes[j], "*.*");
			strcpy(&ptypes[j+2], pstr);
			j += 2 + (WORD)strlen(pstr);
		}
	}
}

VOID insa_stypes(LONG tree, BYTE *pdata)
{
	WORD	i;
	BYTE	*pstr, doctype[4];

	for(i=0; i<8; i++)
	{
		pdata = scasb(pdata, '.');
		if (*pdata == '.')
			pdata++;
		pstr = &doctype[0];
		while ( (*pdata) && (*pdata != ',') )
			*pstr++ = *pdata++;
		*pstr = '\0';
		inf_sset(tree, APDFTYPE+i, &doctype[0]);
	}
}


#if MULTIAPP

WORD ins_latoi(LONG st_ad)
{
	WORD	retval;
	BYTE	ch;

	retval = 0;
	while ((ch = LBGET(st_ad)) != '\0')
	{
		retval = retval*10 + ch - '0';
		st_ad += 1;
	}
	return(retval);
}

#endif

/* ins_app */
WORD ins_app(BYTE *pfname, ANODE *pa)
{			       
	LONG	tree;
	ANODE	*newpa;
	BYTE	pname[12];
	BYTE	ntypes[6*8];
	WORD	oicon, nicon;
	WORD	oflag, nflag;
	WORD	change, field;
	WORD	uninstalled, h;
#if MULTIAPP
	BYTE	memszstr[4];
	WORD	omemsz, nmemsz;
#endif

	tree = G.a_trees[ADINSAPP];
#if MULTIAPP
	LWSET(OB_NEXT(APMEMBOX),APMEMSZ);
#endif
	h = LWGET(OB_HEIGHT(APSCRLBA));
	LWSET(OB_HEIGHT(APFUPARO), gl_hbox + 2);
	LWSET(OB_Y(APFSVSLI), gl_hbox + 2);
	LWSET(OB_HEIGHT(APFSVSLI), h - (2 * (gl_hbox + 2)));
	LWSET(OB_Y(APFDNARO), h - (gl_hbox + 2));
	LWSET(OB_HEIGHT(APFDNARO), gl_hbox + 2);

	uninstalled = !is_installed(pa);
	LWSET(OB_STATE(APREMV), (uninstalled) ? DISABLED : NORMAL );
	/* stuff in appl name */
	fmt_str(pfname, &pname[0]);
	inf_sset(tree, APNAME, &pname[0]);
	/* stuff in docu types */
	insa_stypes(tree, pa->a_pdata);
	LWSET(OB_STATE(APYMEM), NORMAL);
	oflag = pa->a_flags;
	if (pa->a_flags & AF_ISCRYS)
	{
		field = APGEM;
		LWSET(OB_STATE(APYMEM), DISABLED);
	}
	else
		field = (pa->a_flags & AF_ISPARM) ? APPARMS : APDOS;
	LWSET(OB_STATE(field), SELECTED);

	field = (pa->a_flags & AF_ISFMEM) ? APYMEM : APNMEM;
	LWSET(OB_STATE(field), SELECTED);

	oicon = pa->a_aicon - IA_GENERIC;

#if MULTIAPP
	omemsz = pa->a_memreq;
	merge_str(&memszstr[0], "%W", &omemsz);
	inf_sset(tree, APMEMSZ, &memszstr[0]);
#endif

	insa_elev(tree, oicon, gl_numics);
	nicon = insa_dial(tree, oicon, gl_numics);
	change = FALSE;

#if MULTIAPP
	nmemsz = ins_latoi(LLGET(LLGET(OB_SPEC(APMEMSZ))));
#endif

	/* set memory flag */
	field = inf_gindex(tree, APYMEM, 2);
	nflag = (field == 0) ? AF_ISFMEM : 0;
	LWSET(OB_STATE(APYMEM + field), NORMAL);
	/* set type flags */
	field = inf_gindex(tree, APGEM, 3);
	if (field == 0)
		nflag = AF_ISCRYS | AF_ISGRAF;
	if (field == 2)
		nflag |= AF_ISPARM;
	LWSET(OB_STATE(APGEM + field), NORMAL);
	/* get button selection	*/
	field = inf_gindex(tree, APINST, 3);
	LWSET(OB_STATE(APINST + field), NORMAL);

	if ( field == 0 )
	{
		/* install the appl. if its uninstalled or has new types */
		insa_gtypes(tree, &ntypes[0]);
		if ( (uninstalled) || (!strcmp(&ntypes[0], pa->a_pdata)) )
		{
			newpa = (uninstalled) ? app_alloc(TRUE) : pa;

			if (newpa)
			{
				if ( (uninstalled) || (!strcmp(&ntypes[0], pa->a_pdata)) )
				{
					change = TRUE;
					ntypes[ strlen(&ntypes[0]) ] = '@';
					scan_str(&ntypes[0], &newpa->a_pdata);
				}

				if (newpa != pa)
				{
					uninstalled = change = TRUE;
					strcpy(&ntypes[0], pfname);
					ntypes[ strlen(&ntypes[0]) ] = '@';
					scan_str(&ntypes[0], &newpa->a_pappl);
					newpa->a_flags = nflag;
					newpa->a_type = AT_ISFILE;
					newpa->a_obid = NIL;
					newpa->a_letter = '\0';
					newpa->a_xspot = 0x0;
					newpa->a_yspot = 0x0;
				}
				pa = newpa;
			}
			else
				fun_alert(1, STAPGONE, NULL);
		}
		/* see if icon changed or flags changed */
		if ( (uninstalled) ||
#if MULTIAPP
			(omemsz != nmemsz) ||
#endif
			(oicon != nicon) ||
			(oflag != nflag) )
		{
			change = TRUE;
			pa->a_aicon = nicon + IA_GENERIC;
			pa->a_dicon = nicon + ID_GENERIC;
			pa->a_flags = nflag;
#if MULTIAPP
			pa->a_memreq = nmemsz;
#endif
		}
	}
	else if ( field == 1 )
	{
		/* remove installed app	*/
		if ( !uninstalled )
		{
			app_free(pa);
			change = TRUE;
		}
	}
	return(change);
} /* ins_app */

/* ob_actxywh */
VOID ob_actxywh(LONG tree, WORD obj, GRECT *p)
{
	/* get x,y,w,h for specified object	*/
	objc_offset((OBJECT FAR *)tree, obj, &p->g_x, &p->g_y);
	p->g_w = LWGET(OB_WIDTH(obj));
	p->g_h = LWGET(OB_HEIGHT(obj));
} /* ob_actxywh */

/* ob_relxywh */
VOID ob_relxywh(LONG tree, WORD obj, GRECT *prect)
{
	/* get x,y,w,h for specified object	*/
	LWCOPY(ADDR(prect), OB_X(obj), sizeof(GRECT) / 2);
} /* ob_relxywh */
