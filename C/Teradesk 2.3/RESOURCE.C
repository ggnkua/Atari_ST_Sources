/*
 * Teradesk. Copyright (c) 1993, 1994, 2002 W. Klaren.
 *
 * This file is part of Teradesk.
 *
 * Teradesk is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * Teradesk is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Teradesk; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include <np_aes.h>			/* HR 151102: modern */
#include <stdlib.h>
#include <string.h>
#include <vdi.h>
#include <boolean.h>
#include <library.h>
#include <mint.h>
#include <xdialog.h>

#include "desk.h"
#include "resource.h"
#include "version.h"
#include "xfilesys.h"
#include "window.h"

OBJECT *menu,
	   *setprefs,
	   *setprgprefs,
	   *addprgtype,
	   *openfile,
	   *newfolder,
	   *driveinfo,
	   *folderinfo,
	   *fileinfo,
	   *infobox,
	   *addicon,
	   *getcml,
	   *nameconflict,
	   *copyinfo,
	   /* *print, DjV 031 080203 */
	   *setmask,
	   *applikation,
	   *seticntype,
	   /* *addicntype,DjV 034 050203 */
	   *loadmods,
	   *viewmenu,
	   *stabsize,
	   *wdoptions,
	   *wdfont,
	   *helpno1,     /* DjV 008 251202 */
	   *helpno2,     /* DjV 008 251202 */
	   *fmtfloppy,   /* DjV 006 251202 */ 
	   *vidoptions,  /* DjV 007 251202 */
	   *copyoptions; /* DjV 016 251202 */

char
	 *dirname,
	 *oldname,
	 *newname,
	 *finame,
	 *flname,
	 *cmdline,			/* HR 240203 */
	 *applcmdline,		/* HR 070303 */

	 *drvid,
	 *iconlabel,
/*	 *cmdline1,			/* HR 240203 */
	 *cmdline2,
*/	 *cpfile,
	 *cpfolder,
	 *filetype,
	 *tabsize,
	 *copybuffer,
	 *applname,
	 *appltype,
	 *applfkey,
	 *prgname,
	 *icnname,
	 *vtabsize;

char dirnametxt[132],		/* HR 021202: The 6 scrolling editable texts. */
     finametxt[132],
     flnametxt[132],
     oldnametxt[132],
     newnametxt[132],
     cmdlinetxt[132],		/* HR 240203 */
     applcmlntxt[132]		/* HR 070303 */
     ;

extern int xd_aes4_0; /* DjV 023 310103 it is a 3D aes */

static void set_menubox(int box)
{
	int x, dummy, offset;

	objc_offset(menu, box, &x, &dummy);

	if ((offset = x + menu[box].r.w + 2 * screen_info.fnt_w - max_w) > 0)
		menu[box].r.x -= offset;
}

/* DjV 023 310103
 * correction to compensate change of object size in 3D aes,
 * so that objects in sliders and similar do not overlap.
 * 
 * NOTE: but shouldn't all of this have been catered for
 * in XDIALOG routines ?
 */

extern int aes_hor3d, aes_ver3d;
static void rsc_xalign(OBJECT *tree, int left, int right, int object)
{
	/* DjV 023 310103 use aes_hor3d */
	tree[object].r.x = tree[left ].r.x + tree[left  ].r.w + (2*aes_hor3d + 1);
	tree[object].r.w = tree[right].r.x - tree[object].r.x - (2*aes_hor3d + 1);
}

static void rsc_yalign(OBJECT *tree, int up, int down, int object)
{
	/* DjV 023 310103 use aes_ver3d */
	tree[object].r.y = tree[up  ].r.y + tree[up    ].r.h + (2*aes_ver3d + 1);
	tree[object].r.h = tree[down].r.y - tree[object].r.y - (2*aes_ver3d + 1);
}

/* Funktie voor het verwijderen van een menupunt uit een menu */

static void mn_del(int item)
{
	int i, y, ch_h = screen_info.fnt_h;
	OBJECT *tree = menu;

	tree[MNOPTBOX].r.h -= ch_h;
	y = tree[item].r.y;
	i = tree[MNOPTBOX].ob_head;

	while (i != MNOPTBOX)
	{
		if (tree[i].r.y > y)
			tree[i].r.y -= ch_h;
		i = tree[i].ob_next;
	}

	objc_delete(menu, item);
}

static void rsc_fixmenus(void)
{
	RECT desk;

	if (tos2_0() == FALSE)
	{
		int dummy;
		long mnsize;
		RECT boxrect;
		MFDB mfdb;
		union
		{
			long size;
			struct
			{
				int high;
				int low;
			} words;
		} buffer;

		xd_objrect(menu, MNOPTBOX, &boxrect);
		mnsize = xd_initmfdb(&boxrect, &mfdb);

		if (tos1_4() == FALSE)
			buffer.size = 8000L;
		else
			wind_get(0, WF_SCREEN, &dummy, &dummy, &buffer.words.high, &buffer.words.low);

		if (mnsize > buffer.size)
		{
			mn_del(MAPPLIK);
			mn_del(MOPTIONS);
		}
	}

	set_menubox(MNOPTBOX);
	set_menubox(MNVIEWBX);

	xw_get(NULL, WF_WORKXYWH, &desk);
	menu[menu->ob_head].r.w = desk.w;
}

void rsc_init(void)
{
	char tmp[5], *tosversion;
	int v = get_tosversion(), i, o;

	xd_gaddr(R_TREE, MENU, &menu);
	xd_gaddr(R_TREE, OPTIONS, &setprefs);
	xd_gaddr(R_TREE, PRGOPTNS, &setprgprefs);
	xd_gaddr(R_TREE, ADDPTYPE, &addprgtype);
	xd_gaddr(R_TREE, OPENFILE, &openfile);
	xd_gaddr(R_TREE, NEWDIR, &newfolder);
	xd_gaddr(R_TREE, GETCML, &getcml);
	xd_gaddr(R_TREE, DRVINFO, &driveinfo);
	xd_gaddr(R_TREE, FLDRINFO, &folderinfo);
	xd_gaddr(R_TREE, FILEINFO, &fileinfo);
	xd_gaddr(R_TREE, INFOBOX, &infobox);
	xd_gaddr(R_TREE, ADDICON, &addicon);
	xd_gaddr(R_TREE, NAMECONF, &nameconflict);
	xd_gaddr(R_TREE, COPYINFO, &copyinfo);
	/* xd_gaddr(R_TREE, PRINT, &print); DjV 031 080203 */
	xd_gaddr(R_TREE, SETMASK, &setmask);
	xd_gaddr(R_TREE, APPLIKAT, &applikation);
	xd_gaddr(R_TREE, SETICONS, &seticntype);
	/* xd_gaddr(R_TREE, ADDITYPE, &addicntype); DJV 034 050203 */
	xd_gaddr(R_TREE, VIEWMENU, &viewmenu);
	xd_gaddr(R_TREE, STABSIZE, &stabsize);
	xd_gaddr(R_TREE, WOPTIONS, &wdoptions);
	xd_gaddr(R_TREE, WDFONT, &wdfont);
	xd_gaddr(R_TREE, HELP1, &helpno1);        /* DjV 008 251202 */
	xd_gaddr(R_TREE, HELP2, &helpno2);        /* DjV 008 251202 */
	xd_gaddr(R_TREE, FLOPPY, &fmtfloppy);     /* DjV 006 251202 */
	xd_gaddr(R_TREE, VOPTIONS, &vidoptions);  /* DjV 007 251202 */
	xd_gaddr(R_TREE, COPTIONS, &copyoptions); /* DjV 016 050103 */

/* HR 021202: use correct function! */
/*  handle pointers for scrolling editable texts. */
	dirname = xd_set_srcl_text(newfolder,    DIRNAME, dirnametxt );
	oldname = xd_set_srcl_text(nameconflict, OLDNAME, oldnametxt );
	newname = xd_set_srcl_text(nameconflict, NEWNAME, newnametxt );
	finame  = xd_set_srcl_text(folderinfo,   FINAME,  finametxt  );
	flname  = xd_set_srcl_text(fileinfo,     FLNAME,  flnametxt  );
	cmdline = xd_set_srcl_text(getcml,       CMDLINE, cmdlinetxt );		/* HR 240203 */
	applcmdline
	        = xd_set_srcl_text(applikation,  APCMLINE, applcmlntxt);	/* HR 070303 */

	cpfile = copyinfo[CPFILE].ob_spec.tedinfo->te_ptext;
	cpfolder = copyinfo[CPFOLDER].ob_spec.tedinfo->te_ptext;
	drvid = addicon[DRIVEID].ob_spec.tedinfo->te_ptext;
	iconlabel = addicon[ICNLABEL].ob_spec.tedinfo->te_ptext;
	filetype = setmask[FILETYPE].ob_spec.tedinfo->te_ptext;
	tabsize = setprefs[TABSIZE].ob_spec.tedinfo->te_ptext;
	copybuffer = copyoptions[COPYBUF].ob_spec.tedinfo->te_ptext;		/* DjV */
	applname = applikation[APNAME].ob_spec.tedinfo->te_ptext;
	appltype = applikation[APTYPE].ob_spec.tedinfo->te_ptext;
	applfkey = applikation[APFKEY].ob_spec.tedinfo->te_ptext;
	prgname = addprgtype[PRGNAME].ob_spec.tedinfo->te_ptext;
	/* icnname = addicntype[AITTYPE].ob_spec.tedinfo->te_ptext; DjV 034 050203 */
	icnname = addicon[ICNTYPE].ob_spec.tedinfo->te_ptext; /* DjV 034 050203 */
	vtabsize = stabsize[VTABSIZE].ob_spec.tedinfo->te_ptext;

	/* 
	 * DjV note: rsc_xalign and rsc_yalign below change the dimensions
	 * of dialog items so that they do not overlap with adjacent items;
	 * this is supposed to prevent overlapping of scrolling arrow buttons
	 * with scrolled-item fields.
	 */

	/* DjV 023 160203 ---vvv--- */

	/*
	printf ("delta:%i %i %i %i",xd_aes4_0, aes_hor3d, aes_ver3d, ncolors);
	getch();
	*/

	/*
	 * aes_hor3d and aes_ver3d are wrong in some AESses!!! below 
	 * is a temporary fix until the bug is repaired properly
	 *
	 * HR: It probaly depends on whether the AES knows objc_sysvar.
	 *       This patch at least sets the default according to The AES version.
	 */

	if (   xd_aes4_0
#if _MINT_
	    && !magx
#endif
	   )
	{
		aes_hor3d = 2;
		aes_ver3d = 2;
	}
	else
	{
		aes_hor3d = 0;
		aes_ver3d = 0;
	}


	/* DjV 023 160203 ---^^-- */

	rsc_xalign(applikation, APPREV, APNEXT, APTYPE);
	rsc_xalign(wdoptions, DSKPDOWN, DSKPUP, DSKPAT);
	rsc_xalign(wdoptions, DSKCDOWN, DSKCUP, DSKCOLOR);
	rsc_xalign(wdoptions, WINPDOWN, WINPUP, WINPAT);	/* DjV 023 310103 */
	rsc_xalign(wdoptions, WINCDOWN, WINCUP, WINCOLOR);	/* DjV 023 310103 */
	rsc_xalign(wdfont, WDFSUP, WDFSDOWN, WDFSIZE);

	rsc_yalign(addicon, ICNUP, ICNDWN, ICPARENT);
	rsc_yalign(setprgprefs, PUP, PDOWN, PSPARENT);
	/* rsc_yalign(addicntype, ITUP, ITDOWN, ITPARENT); DjV 034 050203 */
	rsc_yalign(seticntype, IUP, IDOWN, ISPARENT);
	rsc_yalign(setmask, FTUP, FTDOWN, FTSPAR);
	rsc_yalign(wdfont, WDFUP, WDFDOWN, FSPARENT);

	*drvid = 0;
	*iconlabel = 0;
/*	*cmdline1 = 0;			/* HR 240203 */
	*cmdline2 = 0;
*/
	infobox[INFOVERS].ob_spec.tedinfo->te_ptext = INFO_VERSION;
	infobox[COPYRGHT].ob_spec.tedinfo->te_ptext = INFO_COPYRIGHT;
	infobox[INFOSYS ].ob_spec.tedinfo->te_ptext = INFO_SYSTEMS; /* DjV 009 251202 */
	infobox[OTHRINFO].ob_spec.tedinfo->te_ptext = INFO_OTHER;   /* DjV 009 251202 */

	tosversion = infobox[INFOTV].ob_spec.tedinfo->te_ptext;

	o = (int) strlen(itoa(v, tmp, 16)) - 4;

	for (i = 0; i < 4; i++)
		tosversion[i] = ((i + o) >= 0) ? tmp[i + o] : ' ';

	/* DjV 009 120203 ---vvv--- */
	/* reuse  v and tosversion here to get AES version */
	v = _GemParBlk.glob.version;
	o = (int) strlen(itoa(v, tmp, 16)) - 4;
	tosversion = infobox[INFOAV].ob_spec.tedinfo->te_ptext;
	for (i = 0; i < 4; i++)
		tosversion[i] = ((i + o) >= 0) ? tmp[i + o] : ' ';
	/* DjV 009 120203 ---^^^--- */

	rsc_fixmenus();
}

void rsc_title(OBJECT *tree, int object, int title)
{
	OBSPEC s;

	xd_gaddr(R_STRING, title, &s);
	xd_set_obspec(tree + object, s);		/* HR 151102 */
/*	tree[object].ob_spec.userblk->ub_parm = (long) s; */
}

/*
 * Write a long into a formatted text field. Text is right justified
 * and padded with spaces.
 *
 * Parameters:
 *
 * tree		- object tree.
 * object	- index of formatted text field.
 * value	- value to convert.
 */

void rsc_ltoftext(OBJECT *tree, int object, long value)
{
	int l1, l2, i;
	char s[16], *p;
	TEDINFO *ti;

	ti = xd_get_obspec(tree + object).tedinfo;		/* HR 021202 */
	p = ti->te_ptext;
	l1 = (int) strlen(ti->te_pvalid);	/* Length of text field. */
	ltoa(value, s, 10);					/* Convert value to ASCII. */
	l2 = (int) strlen(s);				/* Length of number. */

	i = 0;

	while (i < (l1 - l2))
	{
		*p++ = ' ';						/* Fill with spaces. */
		i++;
	}

	strcpy(p, s);						/* Copy number. */
}
