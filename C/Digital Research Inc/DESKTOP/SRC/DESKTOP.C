/*	DESKTOP.C	05/04/84 - 09/05/85	Lee Lorenzen		*/
/*	for 3.0		3/12/86  - 1/29/87	MDF			*/
/*
*       Copyright 1999, Caldera Thin Clients, Inc.                      
*       This software is licenced under the GNU Public License.         
*       Please see LICENSE.TXT for further information.                 
*                                                                       
*                  Historical Copyright                                 
*	-------------------------------------------------------------
*	GEM Desktop					  Version 2.3
*	Serial No.  XXXX-0000-654321		  All Rights Reserved
*	Copyright (C) 1987			Digital Research Inc.
*	-------------------------------------------------------------
*/

#include <stddef.h>
#include <portab.h>
#include <machine.h>
#include <rclib.h>
#if GEMDOS
#if TURBO_C
#include <aes.h>
#include <vdi.h>
#include <tos.h>
#include <tos_intr.h>
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
#include "deskpro.h"
#include "deskmain.h"
#include "deskact.h"
#include "deskgraf.h"
#include "desksupp.h"
#include "deskdir.h"
#include "deskins.h"
#include "optimize.h"
#include "deskrsrc.h"
#include "deskbind.h"

#define abs(x) ( (x) < 0 ? -(x) : (x) )

/* keyboard shortcuts & others */
#define ESCAPE 0x011B		/* resort directory in window	*/
#define ALTA 0x1E00			/* Configure App		*/
#define ALTC 0x2E00			/* Enter DOS commands	*/
#define ALTD 0x2000			/* Delete				*/
#define ALTI 0x1700			/* Info/Rename			*/
#define ALTN 0x3100			/* Sort by Name			*/
#define ALTP 0x1900			/* Sort by Type			*/
#define ALTS 0x1F00			/* Show as Text/Icons	*/
#define ALTT 0x1400			/* Sort by Date			*/
#define ALTV 0x2F00			/* Save Desktop			*/
#define ALTZ 0x2C00			/* Sort by Size			*/
#define CNTLU 0x1615		/* To Output			*/
#define CNTLQ 0x1011		/* Exit To Dos			*/

#define BEG_UPDATE 1
#define END_UPDATE 0

#define NUM_BB	5

#define SPACE 0x20

EXTERN WORD	DOS_ERR;
EXTERN WORD	gl_hchar;
EXTERN WORD	gl_wchar;

EXTERN WORD	gl_wbox;
EXTERN WORD	gl_hbox;

EXTERN WORD	gl_handle;

GLOBAL BYTE	gl_amstr[4];
GLOBAL BYTE	gl_pmstr[4];

#if MULTIAPP

EXTERN LONG	pr_beggem;
EXTERN LONG	pr_begacc;
EXTERN LONG	pr_begdsk;
EXTERN LONG	pr_topdsk;
EXTERN LONG	pr_topmem;
EXTERN LONG	pr_ssize;
EXTERN LONG	pr_itbl;
EXTERN WORD	pr_kbytes;
EXTERN WORD	gl_fmemflg;

GLOBAL BYTE	gl_bootdr;
GLOBAL WORD	gl_untop;

#endif

EXTERN GLOBES	G;

GLOBAL WORD	ig_close;

GLOBAL WORD	gl_apid;

GLOBAL BYTE	ILL_ITEM[] = {L2ITEM,L3ITEM,L4ITEM,L5ITEM,0};
GLOBAL BYTE	ILL_FILE[] = {FORMITEM,IDSKITEM,0};
GLOBAL BYTE	ILL_DOCU[] = {FORMITEM,IDSKITEM,IAPPITEM,0};
GLOBAL BYTE	ILL_FOLD[] = {OUTPITEM,FORMITEM,IDSKITEM,IAPPITEM,0};
GLOBAL BYTE	ILL_FDSK[] = {OUTPITEM,IAPPITEM,0};
GLOBAL BYTE	ILL_HDSK[] = {FORMITEM,OUTPITEM,IAPPITEM,0};
GLOBAL BYTE	ILL_NOSEL[] = {OPENITEM,SHOWITEM,FORMITEM,DELTITEM,
				IDSKITEM,IAPPITEM,0};
GLOBAL BYTE	ILL_YSEL[] = {OPENITEM, IDSKITEM, FORMITEM, SHOWITEM, 0};

/* no easter egg
GLOBAL WORD	freq[]=
{
	262, 349, 329, 293, 349, 392, 440, 392, 349, 329, 262, 293,
	349, 262, 262, 293, 330, 349, 465, 440, 392, 349, 698
};

GLOBAL WORD	dura[]=
{
	4, 12, 4, 12, 4, 6, 2, 4, 4, 12, 4, 4, 
	4, 4, 4, 4, 4, 4, 4, 12, 4, 8, 4
};
*/

GLOBAL WORD	gl_swtblks[3] =
{
	160,
	160,
	160
};

GLOBAL LONG	ad_ptext;
GLOBAL LONG	ad_picon;

GLOBAL GRECT	gl_savewin[NUM_WNODES];	/* preserve window x,y,w,h	*/
GLOBAL GRECT	gl_normwin;		/* normal (small) window size	*/
GLOBAL WORD	gl_open1st;		/* index of window to open 1st	*/
GLOBAL BYTE	gl_defdrv;		/* letter of lowest drive	*/
GLOBAL WORD	can_iapp;		/* TRUE if INSAPP enabled	*/
GLOBAL WORD	can_show;		/* TRUE if SHOWITEM enabled	*/
GLOBAL WORD	can_del;		/* TRUE if DELITEM enabled	*/
GLOBAL WORD	can_output;		/* TRUE if OUTPITEM endabled	*/
GLOBAL WORD	gl_whsiztop;		/* wh of window fulled		*/
GLOBAL WORD	gl_idsiztop;		/* id of window fulled		*/

EXTERN BYTE	gl_afile[];

#define min(x,y) ((x)<(y)?(x):(y))

VOID copy_icon(LONG dst_tree, LONG tree, WORD dst_icon, WORD icon)
{
	LLSET(obaddr(dst_tree, dst_icon, 12), LLGET(OB_SPEC(icon)));
}

/* this routine is supposed to keep track of the windows between */
/* runs of the Desktop. it assumes pws has already been set up; */
/* gl_savewin is set up by app_start. */
VOID fix_wins(VOID)
{
	WSAVE	*pws0, *pws1;

	gl_open1st = 0;	/* default case */
	pws0 = &G.g_cnxsave.win_save[0];
	pws1 = &G.g_cnxsave.win_save[1];
	/* upper window is full	*/
	if ( (gl_savewin[0].g_y != gl_savewin[1].g_y) &&
		(gl_savewin[0].g_h != gl_savewin[1].g_h) )
	{
		/* which window is upper/lower?	*/
		if (gl_savewin[0].g_h > gl_savewin[1].g_h)
		{
			/* [0] is (full) upper window */
			gl_open1st = 1;
			gl_idsiztop = 0;
			pws0->y_save = G.g_yfull;
			pws0->h_save = G.g_hfull;
			pws1->y_save = gl_normwin.g_y + gl_normwin.g_h + (gl_hbox / 2);
			pws1->h_save = gl_normwin.g_h;
		}
		else
		{
			/* [1] is (full) upper window */
			gl_open1st = 0;
			gl_idsiztop = 1;
			pws1->y_save = G.g_yfull;
			pws1->h_save = G.g_hfull;
			pws0->y_save = gl_normwin.g_y + gl_normwin.g_h + (gl_hbox / 2);
			pws0->h_save = gl_normwin.g_h;
		} /* else */
	} /* if */
	/* case 3: lower window is full	*/
	else if ( (gl_savewin[0].g_y == gl_savewin[1].g_y) &&
		(gl_savewin[0].g_h != gl_savewin[1].g_h) )
	{
		/* which window is upper/lower?	*/
		if (gl_savewin[0].g_h > gl_savewin[1].g_h)
		{
			/* [0] is (full) lower window */
			gl_open1st = 1;
			gl_idsiztop = 0;
			pws0->y_save = G.g_yfull;
			pws0->h_save = G.g_hfull;
			pws1->y_save = gl_normwin.g_y;
			pws1->h_save = gl_normwin.g_h;
		}
		else
		{
			/* [1] is (full) lower window */
			gl_open1st = 0;
			gl_idsiztop = 1;
			pws1->y_save = G.g_yfull;
			pws1->h_save = G.g_hfull;
			pws0->y_save = gl_normwin.g_y;
			pws0->h_save = gl_normwin.g_h;
		} /* else */
	} /* if */
} /* fix_wins */

/*
*	Turn on the hour glass to signify a wait and turn it off when were
*	done.
*/
VOID desk_wait(WORD turnon)
{
	graf_mouse( (turnon) ? HOURGLASS : ARROW, 0x0L);
}

/* Routine to update all of the desktop windows */
VOID desk_all(WORD sort)
{
	desk_wait(TRUE);
	if (sort)
		win_srtall();
	win_bdall();
	win_shwall();
	desk_wait(FALSE);
}

/* Given an icon index, go find the ANODE which it represents */
ANODE *i_find(WORD wh, WORD item, FNODE **ppf, WORD *pisapp)
{
	ANODE 	*pa;
	BYTE 	*pname;
	WNODE	*pw;
	FNODE	*pf;

	pa = (ANODE *) NULL;
	pf = (FNODE *) NULL;

	pw = win_find(wh);
	pf = fpd_ofind(pw->w_path->p_flist, item);
	if (pf)
 	{
		pname = &pf->f_name[0];
		pa = pf->f_pa;
#if GEMDOS
		if ( (pf->f_attr & FA_DESKTOP) || (pf->f_attr & FA_SUBDIR) )
#else
		if ( (pf->f_attr & F_DESKTOP) || (pf->f_attr & F_SUBDIR) )
#endif
			*pisapp = FALSE;
		else 
			*pisapp = wildcmp(pa->a_pappl, pname);
	}
	*ppf = pf;
	return (pa);
}

/* Enable/Disable the menu items in dlist */
VOID men_list(LONG mlist, BYTE *dlist, WORD enable)
{
	while (*dlist)
		menu_ienable((OBJECT FAR *)mlist, *dlist++, enable);
}

/*
* 	Based on current selected icons, figure out which
*	menu items should be selected (deselected)
*/
VOID men_update(LONG tree)
{
	WORD	item, nsel, *pjunk, isapp;
	BYTE	*pvalue;
	ANODE	*appl;

	/* enable all items	*/
	for (item = OPENITEM; item <= PREFITEM; item++)
		menu_ienable((OBJECT FAR *)tree, item, TRUE);
	can_iapp = TRUE;
	can_show = TRUE;
	can_del = TRUE;
	can_output = TRUE;
	/* disable some items */
	men_list(tree, ILL_ITEM, FALSE);

	nsel = 0;
	for (item = 0; (item = win_isel(G.g_screen, G.g_croot, item)) != 0;
		nsel++)
	{
		appl = i_find(G.g_cwin, item, (FNODE **)&pjunk, &isapp);
		switch (appl->a_type)
		{
			case AT_ISFILE:
				if ( (isapp) || is_installed(appl) )
					pvalue = ILL_FILE;
				else
				{
					pvalue = ILL_DOCU;
					can_iapp = FALSE;
				} 
				break;
			case AT_ISFOLD:
				pvalue = ILL_FOLD;
				can_iapp = FALSE;
				can_output = FALSE;
				break;
			case AT_ISDISK:
#if GEMDOS
				if (appl->a_letter == 'A' || appl->a_letter == 'B')
					pvalue = ILL_FDSK;
				else
					pvalue = ILL_HDSK;
#else
				pvalue = (appl->a_aicon == IG_FLOPPY) ? ILL_FDSK : ILL_HDSK;
#endif
				can_iapp = FALSE;
				can_output = FALSE;
				break;
		} /* switch */
		men_list(tree, pvalue, FALSE);	/* disable certain items */
	} /* for */

	if ( nsel != 1 )
	{
		if (nsel)
		{
			pvalue = ILL_YSEL;
			can_show = FALSE;
		}
		else
		{
			pvalue = ILL_NOSEL;
			can_show = FALSE;
			can_del = FALSE;
			can_iapp = FALSE;
		}
		men_list(tree, pvalue, FALSE);
	} /* if */
} /* men_update */

WORD do_deskmenu(WORD item)
{
	WORD	done, touchob;
/*	WORD	i;*/
	LONG	tree;

	done = FALSE;
	switch( item )
	{
		case ABOUITEM:
			tree = G.a_trees[ADDINFO];
			/* draw the form	*/
			show_hide(FMD_START, tree);
			while( !done )
			{
				touchob = form_do((OBJECT FAR *)tree, 0);
				touchob &= 0x7fff;
				if ( touchob == DEICON )
				{
/*					for(i=0; i<23; i++)
						sound(TRUE, freq[i], dura[i]);
*/				}
				else
					done = TRUE;
			}
			LWSET(OB_STATE(DEOK), NORMAL);
			show_hide(FMD_FINISH, tree);
			done = FALSE;
			break;
	}
	return(done);
}

WORD do_filemenu(WORD item)
{
	WORD	done;
	WORD	curr, junk, first;
	WNODE	*pw;
	FNODE	*pf;
	BYTE	*pdst;
#if MULTIAPP
	ANODE	*pa;
#endif
	
	done = FALSE;
	pw = win_find(G.g_cwin);
	curr = win_isel(G.g_screen, G.g_croot, 0);
	switch( item )
	{
		case OPENITEM:
			if (curr)
				done = do_open(curr);
			break;
		case SHOWITEM:
			if (curr)
				do_info(curr);
			break;
		case DELTITEM:
			if (curr)
				fun_del(pw);
			break;
		case FORMITEM:
			if (curr)
				do_format(curr);
			break;   
		case OUTPITEM:
			/* build cmd tail that looks like this: */
			/* C:\path\*.*,file.ext,file.ext,file.ext */
			G.g_tail[1] = '\0';
			if (pw && curr)
			{
				pdst = strcpy(&G.g_tail[1], &pw->w_path->p_spec[0]);
				/* check for no path defined	*/
				if (pw->w_path->p_spec[0] == '@')
					G.g_tail[1] = gl_defdrv;
				/* while there are filenames append them in */
				first = TRUE;
				while(curr)
				{
					if (first)
					{
						while (*pdst != '\\')
							pdst--;
						pdst++;
						*pdst = '\0';
		 				first = FALSE;
					}
					else
					{
						pdst--;
						*pdst++ = ',';
					}
					i_find(G.g_cwin, curr, &pf, &junk);
					pdst = strcpy(pdst, &pf->f_name[0]);
					/* if there is room for	another filename &; */
					/* then go fetch it */
					if ( (&G.g_tail[127] - pdst) > 16 )
						curr = win_isel(G.g_screen, G.g_croot, curr);
					else
						curr = 0;
				} /* while */
			} /* if pw */
			strcpy(&G.g_cmd[0], ini_str(STGEMOUT));
#if MULTIAPP
			pa = app_afind(FALSE, AT_ISFILE, -1, &G.g_cmd[0], &junk);
			pr_kbytes = (pa ? pa->a_memreq : 256);
			pro_run(TRUE, -1, -1, -1);
#else
			done = pro_run(TRUE, TRUE, -1, -1);
#endif
			break;
		case QUITITEM:
#if MULTIAPP
			if (fun_alert(1,STEXTDSK,NULLPTR) == 2)		/* CANCEL */
				break;
			else
#endif
			pro_exit(G.a_cmd, G.a_tail);
			done = TRUE;
			break;
#if DEBUG
		case DBUGITEM:
			debug_run();
			break;
#endif
	}
	return(done);
} /* do_filemenu */

WORD do_viewmenu(WORD item)
{
	WORD	newview, newsort;
	LONG	ptext;

	newview = G.g_iview;
	newsort = G.g_isort;
	switch( item )
	{
		case ICONITEM:
			newview = (G.g_iview == V_ICON) ? V_TEXT : V_ICON;
			break;
		case NAMEITEM:
			newsort = S_NAME;
			break;
		case DATEITEM:
			newsort = S_DATE;
			break;
		case SIZEITEM:
			newsort = S_SIZE;
			break;
		case TYPEITEM:
			newsort = S_TYPE;
			break;
	}
	if ( (newview != G.g_iview) || (newsort != G.g_isort) )
	{
		if (newview != G.g_iview)
		{
			G.g_iview = newview;
			ptext = (newview == V_TEXT) ? ad_picon : ad_ptext;
			menu_text((OBJECT FAR *)G.a_trees[ADMENU], ICONITEM, (const BYTE FAR *)ptext);
		}
		if (newsort != G.g_isort)
		{
			menu_icheck((OBJECT FAR *)G.a_trees[ADMENU], G.g_csortitem, FALSE);
			G.g_csortitem = item;
			menu_icheck((OBJECT FAR *)G.a_trees[ADMENU], item, TRUE);
		}
		win_view(newview, newsort);
		return(TRUE);	/* need to rebuild */
	}
	else
		return( FALSE );
}

WORD do_optnmenu(WORD item)
{
	ANODE	*pa;
	WORD	done, rebld, curr, ret;
	FNODE	*pf;
	WORD	isapp;
	BYTE	*pstr;
#if MULTIAPP
	WORD	junk;
#endif

	done = FALSE;
	rebld = FALSE;

	curr = win_isel(G.g_screen, G.g_croot, 0);
	if (curr)
		pa = i_find(G.g_cwin, curr, &pf, &isapp);

	switch( item )
	{
		case IDSKITEM:
			if (pa)
				rebld = ins_disk(pa);
			if (rebld)
			{
				gl_defdrv = app_blddesk();
				do_chkall(TRUE);
			}
			break;
		case IAPPITEM:
			if (pa)
			{
				if (isapp)
					pstr = &pf->f_name[0];
				else if (is_installed(pa))
					pstr = pa->a_pappl;
				rebld = ins_app(pstr, pa);
				rebld = TRUE;	/* WORKAROUND for bug that shows up with */
				/* remove followed by cancel when icon is */
				/* partially covered by dialog.  Icon not */
				/* properly redrawn as deselected -- mdf   */
			}
			if (rebld)
				desk_all(FALSE);
			break;
#if MULTIAPP
		case IACCITEM:
			ins_acc();
			break;
#endif
		case PREFITEM:
			if (inf_pref())
				desk_all(FALSE);
			break;
		case SAVEITEM:
			desk_wait(TRUE);
			cnx_put();
			app_save(TRUE);
			desk_wait(FALSE);
			break;
		case DOSITEM:
#if MULTIAPP
			ret = appl_find(ADDR("COMMAND "));
			if (ret == -1)
			{
				ret = pro_cmd( "\0", "\0", FALSE);
				if (ret)
				{
					pa = app_afind(FALSE, AT_ISFILE, -1,"COMMAND.COM", &junk);
					pr_kbytes = (pa ? pa->a_memreq : 128);
					pro_run(FALSE, -1, -1, -1);
				}
			}
			else
			{
				menu_tnormal(G.a_trees[ADMENU], OPTNMENU, TRUE);
				proc_switch(ret);
			}
#else
			ret = pro_cmd( "\0", "\0", FALSE);
			if (ret)
				done = pro_run(FALSE, TRUE, -1, -1);
#endif
			break;
	}
	return(done);
}

WORD hndl_button(WORD clicks, WORD mx, WORD my, WORD button, WORD keystate)
{
	WORD	done, junk;
	GRECT	c;
	WORD	wh, dobj, dest_wh;

	done = FALSE;
	wh = wind_find(mx, my);
	if (wh != G.g_cwin)
		desk_clear(G.g_cwin);

	if (wh == 0)	/* if click outside win's */
	{
		men_update(G.a_trees[ADMENU]);
		wind_update(BEG_UPDATE);
		while (button & 0x0001)
			graf_mkstate(&junk, &junk, &button, &junk);
		wind_update(END_UPDATE);
		return(done);
	}
	else
	{
		desk_verify(wh, FALSE);

		wind_get(wh, WF_WORKXYWH, &c.g_x, &c.g_y, &c.g_w, &c.g_h);

		if (clicks == 1)
		{
			act_bsclick(G.g_cwin, G.a_screen, G.g_croot, mx, my,
				keystate, &c, FALSE);
			graf_mkstate(&junk, &junk, &button, &junk);
			if (button & 0x0001)
			{
				dest_wh = act_bdown(G.g_cwin, G.a_screen, G.g_croot, &mx, &my, 
					keystate, &c, &dobj);
				if ( (dest_wh != NIL) && (dest_wh != 0) )
				{
					fun_drag(wh, dest_wh, dobj, mx, my);
					desk_clear(wh);
				} /* if !NIL */
			} /* if button */
		} /* if clicks */
		else
		{
			act_bsclick(G.g_cwin, G.a_screen, G.g_croot, mx, my, keystate, &c, TRUE);
			done = do_filemenu(OPENITEM);
		} /* else */
		men_update(G.a_trees[ADMENU]);
		return(done);
	}
}

WORD hndl_kbd(WORD thechar)
{
	WORD	done;

	done = FALSE;

	switch(thechar)
	{
		case ESCAPE:
			do_chkall(TRUE);
			break;
		case ALTA:	/* Options: Install App	*/
			if (can_iapp)	/* if it's ok to install app */
			{
				menu_tnormal((OBJECT FAR *)G.a_trees[ADMENU], OPTNMENU, FALSE);
				done = hndl_menu(OPTNMENU, IAPPITEM);
			}
			break;
		case ALTC:	/* Options: Enter DOS commands */
			menu_tnormal((OBJECT FAR *)G.a_trees[ADMENU], OPTNMENU, FALSE);
			done = hndl_menu(OPTNMENU, DOSITEM);
			break;
		case ALTD:	/* File: Delete */
			if (can_del)
			{
				/* if it's ok to delete */
				menu_tnormal((OBJECT FAR *)G.a_trees[ADMENU], FILEMENU, FALSE);
				done = hndl_menu(FILEMENU, DELTITEM);
			}
			break;
		case ALTI:	/* File: Info/Rename */
			if (can_show)
			{
				/* if it's ok to show */
				menu_tnormal((OBJECT FAR *)G.a_trees[ADMENU], FILEMENU, FALSE);
				done = hndl_menu(FILEMENU, SHOWITEM);
			}
			break;
		case ALTN:	/* View: Sort by Name */
			menu_tnormal((OBJECT FAR *)G.a_trees[ADMENU], VIEWMENU, FALSE);
			done = hndl_menu(VIEWMENU, NAMEITEM);
			break;
		case ALTP:	/* View: Sort by Type */
			menu_tnormal((OBJECT FAR *)G.a_trees[ADMENU], VIEWMENU, FALSE);
			done = hndl_menu(VIEWMENU, TYPEITEM);
			break;
		case ALTS:	/* View: Show as Text/Icons	*/
			menu_tnormal((OBJECT FAR *)G.a_trees[ADMENU], VIEWMENU, FALSE);
			done = hndl_menu(VIEWMENU, ICONITEM);
			break;
		case ALTT:	/* View: Sort by Date */
			menu_tnormal((OBJECT FAR *)G.a_trees[ADMENU], VIEWMENU, FALSE);
			done = hndl_menu(VIEWMENU, DATEITEM);
			break;
		case ALTV:	/* Options: Save Desktop */
			menu_tnormal((OBJECT FAR *)G.a_trees[ADMENU], OPTNMENU, FALSE);
			done = hndl_menu(OPTNMENU, SAVEITEM);
			break;
		case ALTZ:	/* View: Sort by Size */
			menu_tnormal((OBJECT FAR *)G.a_trees[ADMENU], VIEWMENU, FALSE);
			done = hndl_menu(VIEWMENU, SIZEITEM);
			break;
		case CNTLU:
			if (can_output)
			{
				menu_tnormal((OBJECT FAR *)G.a_trees[ADMENU], FILEMENU, FALSE);
				done = hndl_menu(FILEMENU, OUTPITEM);
			}
			break;
		case CNTLQ:
			menu_tnormal((OBJECT FAR *)G.a_trees[ADMENU], FILEMENU, FALSE);
			done = hndl_menu(FILEMENU, QUITITEM);
			break;
	} /* switch */
	men_update(G.a_trees[ADMENU]);	/* clean up menu info */
	return(done);
} /* hndl_kbd */

WORD hndl_menu(WORD title, WORD item)
{
	WORD	done;

	done = FALSE;
	switch( title )
	{
		case DESKMENU:
			done = do_deskmenu(item);
			break;
		case FILEMENU:
			done = do_filemenu(item);
			break;
		case VIEWMENU:
			done = FALSE;
			/* for every window go sort again and rebuild views */
			if (do_viewmenu(item))
				desk_all(TRUE);
			break;
		case OPTNMENU:
			done = do_optnmenu(item);
			break;
	}
	menu_tnormal((OBJECT FAR *)G.a_trees[ADMENU], title, TRUE);
	return(done);
}

/* "close" the path but don't set a new dir. & don't redraw the window	*/
/* until the button is up or there are no more CLOSED messages		*/
VOID hot_close(WORD wh)
{
	WORD	drv, done, at_drvs, cnt;
	WORD	mx, my, button, kstate;
	BYTE	path[66], name[9], ext[4];
	BYTE	*pend, *pname, *ppath;
	WNODE	*pw;

	pw = win_find(wh);
	at_drvs = FALSE;
	done = FALSE;
	cnt = 0;
/*	wind_update(BEG_UPDATE);*/
	do {
		cnt++;
		ppath = &pw->w_path->p_spec[0];
		pname = &pw->w_name[0];
		fpd_parse(ppath, &drv, &path[0], &name[0], &ext[0]);
		if (path[0] == '\0')	/* No more path; show disk icons */
		{
			strcpy(pname, ini_str(STDSKDRV));
			ppath[3] = '*';
			ppath[4] = '.';
			ppath[5] = '*';
			ppath[6] = '\0';
			at_drvs = TRUE;
		}
		else
		{
			/* Some path left; scan off last dir. */
			pend = pname;
			pend += (strlen(pname) - 3);	/* skip trailing '\ ' */
			/* Remove last name	*/
			while ( (pend != pname) && (*pend != '\\') )
				pend--;
			pend++;	/* save trailing '\' */
/*			*pend++ = SPACE;*/
			*pend = '\0';
			/* now fix path */
			pend = ppath;
			pend += (strlen(ppath) - 5);	/* skip trailing '\*.*' */
			/* Remove last name	*/
			while ( (pend != ppath) && (*pend != '\\') )
				pend--;
			pend++;	/* save trailing '\' */
			*pend = '\0';
			strcat(ppath, "*.*");	/* put '*.*' back on */
		} /* else */
		wind_set(pw->w_id, WF_NAME, ADDR(&pw->w_name[0]), 0, 0);
/*		wind_update(END_UPDATE);*/
		graf_mkstate(&mx, &my, &button, &kstate);
		if (button == 0x0)
			done = TRUE;
		else
		{
			evnt_timer(750, 0);
			/* grab the screen	*/
/*			wind_update(BEG_UPDATE);*/
			graf_mkstate(&mx, &my, &button, &kstate);
			if (button == 0x0)
				done = TRUE;
		} /* else */
	} while ( !done );
/*	wind_update(END_UPDATE);*/
	if (cnt > 1)
		ig_close = TRUE;
/*	desk_verify(G.g_rmsg[3], FALSE);*/
	fpd_parse(ppath, &drv, &path[0], &name[0], &ext[0]);
	if (at_drvs)
		drv = '@';
	pw->w_cvrow = 0;	/* reset slider */
	do_fopen(pw, 0, drv, path, name, ext, FALSE, TRUE);
	cnx_put();
} /* hot_close */

WORD hndl_msg(VOID)
{
	WORD	done;
	WNODE	*pw;
	WORD	change, menu;

	done = change = menu = FALSE;
	if ( G.g_rmsg[0] == WM_CLOSED && ig_close )
	{
		ig_close = FALSE;
		return(done);
	}
	else
	{
		switch ( G.g_rmsg[0] )
		{
			case WM_TOPPED:
			case WM_CLOSED:
			case WM_FULLED:
			case WM_ARROWED:
			case WM_VSLID:
				desk_clear(G.g_cwin);
				break;
		}
		switch ( G.g_rmsg[0] )
		{
			case MN_SELECTED:
				desk_verify(G.g_wlastsel, FALSE);
				done = hndl_menu(G.g_rmsg[3], G.g_rmsg[4]);
				break;
			case WM_REDRAW:
				menu = TRUE;
#if MULTIAPP
				if (gl_untop)
				{
					gl_untop = FALSE;
					do_chkall(FALSE);
					men_update(G.a_trees[ADMENU]);	/* disable some items */
				}
#endif
				if (G.g_rmsg[3])
				{
					do_wredraw(G.g_rmsg[3], G.g_rmsg[4], G.g_rmsg[5], 
						G.g_rmsg[6], G.g_rmsg[7]);
				}
				break;
			case WM_TOPPED:
				wind_set(G.g_rmsg[3], WF_TOP, 0, 0, 0, 0);
				pw = win_find(G.g_rmsg[3]);
				if (pw)
				{
					win_top(pw);
					desk_verify(pw->w_id, FALSE);
				}
				change = TRUE;
				break;
#if MULTIAPP
			case WM_ONTOP:
				gl_untop = TRUE;
				break;
			case PR_FINISH:
				gl_fmemflg &= (0xff ^ (1 << G.g_rmsg[3]));
				break;
#endif
			case WM_CLOSED:
				hot_close(G.g_rmsg[3]);
				break;
			case WM_FULLED:
				pw = win_find(G.g_rmsg[3]);
				if (pw)
				{
					win_top(pw);
					do_wfull(G.g_rmsg[3]);
					desk_verify(G.g_rmsg[3], TRUE);
				}
				change = TRUE;
				break;
			case WM_ARROWED:
				win_arrow(G.g_rmsg[3], G.g_rmsg[4]);
				break;
			case WM_VSLID:
				win_slide(G.g_rmsg[3], G.g_rmsg[4]);
				break;
		}
		if (change)
			cnx_put();
		G.g_rmsg[0] = 0;
		if (!menu)
			men_update(G.a_trees[ADMENU]);
		return(done);
	}
} /* hndl_msg */

VOID cnx_put(VOID)
{
	WORD	iwin;
	WSAVE	*pws;
	WNODE	*pw;

	G.g_cnxsave.vitem_save = (G.g_iview == V_ICON) ? 0 : 1;
	G.g_cnxsave.sitem_save = G.g_csortitem - NAMEITEM;
	G.g_cnxsave.ccopy_save = G.g_ccopypref;
	G.g_cnxsave.cdele_save = G.g_cdelepref;
	G.g_cnxsave.covwr_save = G.g_covwrpref;
	G.g_cnxsave.cdclk_save = G.g_cdclkpref;
	G.g_cnxsave.cmclk_save = G.g_cmclkpref;
	G.g_cnxsave.ctmfm_save = G.g_ctimeform;
	G.g_cnxsave.cdtfm_save = G.g_cdateform;

	for (iwin = 0; iwin < NUM_WNODES; iwin++) 
	{
		pw = win_find(G.g_wlist[iwin].w_id);
		pws = &G.g_cnxsave.win_save[iwin];
		wind_get(pw->w_id, WF_CURRXYWH, &pws->x_save, &pws->y_save,
			&pws->w_save, &pws->h_save);
		do_xyfix(&pws->x_save, &pws->y_save);
		pws->hsl_save = pw->w_cvcol;
		pws->vsl_save = pw->w_cvrow;
		pws->obid_save = 0;
		strcpy(&pws->pth_save[0], pw->w_path->p_spec);
	} /* for */
} /* cnx_put */

/* cnx_open */
VOID cnx_open(WORD idx)
{
	WSAVE	*pws;
	WNODE	*pw;
	WORD	drv;
	BYTE	pname[9];
	BYTE	pext[4];

	pws = &G.g_cnxsave.win_save[idx];
	pw = win_alloc();
	if (pw)
	{
		if (idx == gl_idsiztop)	/* if a window is fulled */
			gl_whsiztop = pw->w_id;	/* save the wh */
		pw->w_cvcol = pws->hsl_save;
		pw->w_cvrow = pws->vsl_save;
		fpd_parse(&pws->pth_save[0], &drv, &G.g_tmppth[0], 
			&pname[0], &pext[0]);
		if (pname[0] == '\0')
			drv = '\0';
		do_xyfix(&pws->x_save, &pws->y_save);
		pro_chdir(drv, &G.g_tmppth[0]);
		if (DOS_ERR)
		{
			drv = '@';
			G.g_tmppth[0] = '\0';
			pname[0] = pext[0] = '*';
			pname[1] = pext[1] = '\0';
		} /* if */
		do_diropen(pw, TRUE, pws->obid_save, drv, &G.g_tmppth[0], 
			&pname[0], &pext[0], (GRECT *)&pws->x_save, TRUE);
	} /* if pw */
} /* cnx_open */

VOID cnx_get(VOID)
{
	G.g_iview = (G.g_cnxsave.vitem_save == 0) ? V_TEXT : V_ICON;
	do_viewmenu(ICONITEM);
	do_viewmenu(NAMEITEM + G.g_cnxsave.sitem_save);
	G.g_ccopypref = G.g_cnxsave.ccopy_save;
	G.g_cdelepref = G.g_cnxsave.cdele_save;
	G.g_covwrpref = G.g_cnxsave.covwr_save;
	G.g_cdclkpref = G.g_cnxsave.cdclk_save;
	G.g_cmclkpref = G.g_cnxsave.cmclk_save;
	G.g_ctimeform = G.g_cnxsave.ctmfm_save;
	G.g_cdateform = G.g_cnxsave.cdtfm_save;
	G.g_cdclkpref = evnt_dclick(G.g_cdclkpref, TRUE);
	menu_click(G.g_cmclkpref, TRUE);
	cnx_open(gl_open1st);
	cnx_open( abs(1 - gl_open1st) );
	cnx_put();
} /* cnx_get */

WORD gemain(VOID)
{
	WORD	ii, done, flags;
	WORD	ev_which, mx, my, button, kstate, kret, bret;
	WSAVE	*pws;
	LONG	tree, plong;
	WORD	hsave;
#if MULTIAPP
	WORD	junk1, junk2;
	LONG	csize;
	LONG	templn, templn2;
	BYTE	memszstr[4];
#endif
	BYTE	docopyrt;

	/* initialize libraries	*/
	gl_apid = appl_init();
	/* get GEM's vdi handle	*/
	gl_handle = graf_handle(&gl_wchar, &gl_hchar, &gl_wbox, &gl_hbox);
	/* open a virtual workstation for use by the desktop */
	gsx_vopen();
	/* init gsx and related device dependent variables */
	gsx_start();
	gl_whsiztop = NIL;
	gl_idsiztop = NIL;
	/* set clip to working desk and calc full */
	wind_get(0, WF_WORKXYWH, &G.g_xdesk, &G.g_ydesk, &G.g_wdesk, &G.g_hdesk);
	wind_get(0, WF_WORKXYWH, &G.g_xfull, &G.g_yfull, &G.g_wfull, &G.g_hfull);
	G.g_xfull += min(16, gl_wbox);
	G.g_yfull += gl_hbox;
	do_xyfix(&G.g_xfull, &G.g_yfull);
	G.g_wfull -= (2 * G.g_xfull);
	G.g_hfull -= (2 * gl_hbox);
	/* set up small window size	*/
	gl_normwin.g_x = G.g_xfull;
	gl_normwin.g_y = G.g_yfull;
	gl_normwin.g_w = G.g_wfull;
	gl_normwin.g_h = (G.g_hfull - (gl_hbox / 2)) / 2;
	/* init long addrs that will be used alot */
	G.a_cmd = (LONG)ADDR(&G.g_cmd[0]);
	G.a_tail = (LONG)ADDR(&G.g_tail[0]);
	G.a_fcb1 = (LONG)ADDR(&G.g_fcb1[0]);
	G.a_fcb2 = (LONG)ADDR(&G.g_fcb2[0]);
	G.a_rmsg = (LONG)ADDR(&G.g_rmsg[0]);
	/* initialize mouse	*/
	wind_update(BEG_UPDATE);
	desk_wait(TRUE);
	wind_update(END_UPDATE);
	/* initialize resources	*/
	rsrc_load( ADDR("DESKTOP.RSC") );
	/* initialize menus and dialogs */
	for(ii = 0; ii < NUM_ADTREES; ii++)
		rsrc_gaddr(0, ii, &G.a_trees[ii]);

#if MULTIAPP
	templn = G.a_trees[ADDINFO];
	if (gl_height <= 300)
	{
		/* get lo-res images */
		templn2 = G.a_trees[ADLRSINF];	
		copy_icon(templn, templn2, DEICON, LDEICON);
		copy_icon(templn, templn2, DENAME1, LDENAME1);
		copy_icon(templn, templn2, DENAME2, LDENAME2);
		copy_icon(templn, templn2, DENAME3, LDENAME3);
		copy_icon(templn, templn2, DENAME4, LDENAME4);
	}
#endif

	for (ii=0; ii<NUM_BB; ii++)	/* initialize bit images */
		app_tran(ii);

	shel_get(ADDR(&gl_afile[0]), 1);
	docopyrt = (gl_afile[0] != '#');

	if (docopyrt)
	{
		tree = G.a_trees[ADDINFO];	/* copyright notice	*/
		plong = OB_HEIGHT(ROOT);	/* just upper part */
		hsave = LWGET(plong);
		LWSET(plong, hsave - 10*gl_hchar);
		show_hide(FMD_START, tree);
	}

	rsrc_gaddr(R_STRING, STASTEXT, &ad_ptext);
	rsrc_gaddr(R_STRING, STASICON, &ad_picon);

	/* These strings are used by dr_code. Can't get */
	/* to resource then because that would reenter AES. */
	strcpy(&gl_amstr[0], ini_str(STAM));
	strcpy(&gl_pmstr[0], ini_str(STPM));
	/* initialize icons and apps from shell memory or */
	/* from DESKTOP.INF and DESKHI/LO.ICN */
	if (!app_start())
	{
		fun_alert(1, STNOFILE, NULL);
		pro_exit(G.a_cmd, G.a_tail);
		return(FALSE);
	}

#if MULTIAPP
	LSTCPY(G.a_cmd, ADDR("GEMVDI.EXE"));	/* get boot drive */
	shel_find(G.a_cmd);
	gl_bootdr = G.g_cmd[0];
	gl_untop = 0;

	proc_shrink(DESKPID);

	proc_info(DESKPID,&junk1,&junk2,&pr_begdsk,&csize,&pr_topmem,
		&pr_ssize,&pr_itbl);

	pr_begdsk = LOFFSET(pr_begdsk);	/* start of desk */
	pr_topdsk = pr_begdsk + csize;	/* addr above desktop */
	pr_topmem = LOFFSET(pr_topmem);

	csize = (pr_topmem - pr_begdsk) >> 10;	/* K app space */
	merge_str(&memszstr[0], "%L", &csize);	/* to ASCII	*/
	iac_strcop(G.a_trees[ADDINFO], DEMEMSIZ, ADDR(&memszstr[0]));
	
	proc_info(GEMPID,&junk1,&junk2,&pr_beggem,&csize,&templn,
		&pr_ssize,&templn);
	pr_beggem = LOFFSET(pr_beggem);
	pr_begacc = pr_beggem + csize;	/* start of acc's */
	iac_init();
#endif

	/* initialize windows */
	win_start();
	/* initialize folders, paths, and drives */
	fpd_start();
	/* show menu */
	desk_verify(0, FALSE); /* should this be here */
	wind_update(BEG_UPDATE);
	menu_bar((OBJECT FAR *)G.a_trees[ADMENU], TRUE);
	wind_update(END_UPDATE);
	/* establish menu items that need to be */
	/* checked, check 'em */
	G.g_iview = V_ICON;
	menu_text((OBJECT FAR *)G.a_trees[ADMENU], ICONITEM, (const BYTE *)ad_ptext);
	G.g_csortitem = NAMEITEM;
	menu_icheck((OBJECT FAR *)G.a_trees[ADMENU], G.g_csortitem, TRUE);
	/* set up initial prefs	*/
	G.g_ccopypref = TRUE;
	G.g_ctimeform = TRUE;
	G.g_cdateform = TRUE;
	G.g_cdclkpref = 3;
	/* initialize desktop and its objects */
	gl_defdrv = app_blddesk();
	/* fix up subwindows */
	for (ii = 0; ii < NUM_WNODES; ii++)
	{
		pws = &G.g_cnxsave.win_save[ii];
		rc_copy(&gl_normwin, (GRECT *)&pws->x_save);	/* copy in normal size */
		if (pws->pth_save[0])
			do_xyfix(&pws->x_save, &pws->y_save);
	} /* for */
	/* fix up y loc. of lower window */
	pws->y_save += pws->h_save + (gl_hbox / 2);

	if (docopyrt)
	{
		evnt_timer(1000, 0);
		LWSET(plong, hsave);	/* ABOUT height restored */
		show_hide(FMD_FINISH, tree);	/* copyright notice	*/
	}

	fix_wins();	/* update with latest window x,y,w,h */

	/* set up current parms	*/
	desk_verify(0, FALSE);
	/* establish desktop's state from info */
	/* found in app_start, open windows */
	wind_update(BEG_UPDATE);
	cnx_get();
	wind_update(END_UPDATE);
	men_update(G.a_trees[ADMENU]); 
	/* get ready for main loop */
	flags = MU_BUTTON | MU_MESAG | MU_KEYBD;
	done = FALSE;
	ig_close = FALSE;
	/* turn mouse on */
	desk_wait(FALSE);
	/* loop handling user input until done */

	while( !done )
	{
		/* block for input */
		ev_which = evnt_multi(flags, 0x02, 0x01, 0x01, 
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			(WORD *)G.a_rmsg, 0, 0, 
			&mx, &my, &button, &kstate, &kret, &bret);
		/* grab the screen */
		wind_update(BEG_UPDATE);
		/* handle keybd message */
		if (ev_which & MU_KEYBD)
			done = hndl_kbd(kret);

		/* handle button down */
		if (ev_which & MU_BUTTON)
			done = hndl_button(bret, mx, my, button, kstate);

		/* handle system message */
		while (ev_which & MU_MESAG)
		{
			done = hndl_msg();
			/* use quick-out to clean out all messages */
			if (done)
				break;
			ev_which = evnt_multi(MU_MESAG | MU_TIMER, 0x02, 0x01, 0x01, 
				0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
				(WORD *)G.a_rmsg, 0, 0, 
				&mx, &my, &button, &kstate, &kret, &bret);
		}

		/* free the screen	*/
		wind_update(END_UPDATE);
	}
	/* save state in memory	for when we come back to the desktop */
	cnx_put();
	app_save(FALSE);
	/* turn off the menu bar */
	menu_bar(0x0L, FALSE);
	/* close vdi virtual ws */
	v_clsvwk( gl_handle );
	/* exit the gem AES	*/
	appl_exit();
	return(TRUE);
} /* main */
