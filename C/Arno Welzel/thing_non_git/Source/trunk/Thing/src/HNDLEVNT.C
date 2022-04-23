/**
 * Thing
 * Copyright (C) 1994-2012 Arno Welzel, Thomas Binder
 *
 * This program is free software: you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation, either
 * version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this program. If not, see
 * <http://www.gnu.org/licenses/>.
 *
 * @copyright  Arno Welzel, Thomas Binder 1994-2012
 * @author     Arno Welzel, Thomas Binder
 * @license    LGPL
 */

/*=========================================================================
 HNDLEVNT.C

 Thing
 Event-Handling
 =========================================================================*/

#include "..\include\globdef.h"
#include "..\include\types.h"
#include "..\include\thingrsc.h"
#include <ctype.h>
#include "..\include\dragdrop.h"
#include "..\include\tcmd.h"
#include "..\include\jobid.h"

#undef TIMER
#ifdef TIMER
#include <time.h>

static clock_t timer1;
static clock_t timer2;
#endif

/**-------------------------------------------------------------------------
 handle_menu()

 Verarbeiten einer Menueauswahl
 Wird auch von handle_key() bei Shortcuts aufgerufen
 -------------------------------------------------------------------------*/
void handle_menu(int title, int item, int ks) {
	WININFO *win;
	int i, j, k, font, fontid, whandle;

	font = 0;
	fontid = -1;
	whandle = -1;
	if (!tb.topwin) {
		if (tb.sys & SY_OWNER) {
			get_twin(&whandle);
			if (whandle)
				if (!wind_get(whandle, WF_OWNER, &fontid))
					fontid = -1;
		}
	} else {
		if (!(tb.topwin->state & WSICON) && tb.topwin->class != WCDIAL)
			font = 1;
	}

	if ((rs_trindex[MAINMENU][item].ob_state & DISABLED) || (rs_trindex[MAINMENU][title].ob_state & DISABLED))
		return;
	mn_tnormal(rs_trindex[MAINMENU], title, 0);
#ifdef OLD_MENU
	if(conf.wdial)
	{
		mn_tnormal(rs_trindex[MAINMENU],title,1);
	}
#endif
	if (ks & K_CTRL) {
		/* Hilfetext anzeigen, falls [Control] gedrÅckt */
		switch (item) {
		case MNEW:
			show_help(rs_frstr[HMNEW]);
			break;
		case MOPEN:
			show_help(rs_frstr[HMOPEN]);
			break;
		case MFIND:
			show_help(rs_frstr[HMFIND]);
			break;
		case MINFO:
			show_help(rs_frstr[HMINFO]);
			break;
		case MCLOSE:
			show_help(rs_frstr[HMCLOSE]);
			break;
		case MSHOW:
			show_help(rs_frstr[HMSHOW]);
			break;
		case MPRINT:
			show_help(rs_frstr[HMPRINT]);
			break;
		case MSAVEGROUP:
			show_help(rs_frstr[HMSAVEGROUP]);
			break;
		case MEJECT:
			show_help(rs_frstr[HMEJECT]);
			break;
		case MFORMAT:
			show_help(rs_frstr[HMFORMAT]);
			break;
		case MQUIT:
			show_help(rs_frstr[HMQUIT]);
			break;

		case MCOPY:
			show_help(rs_frstr[HMCOPY]);
			break;
		case MCUT:
			show_help(rs_frstr[HMCUT]);
			break;
		case MPASTE:
			show_help(rs_frstr[HMPASTE]);
			break;
		case MDELETE:
			show_help(rs_frstr[HMDELETE]);
			break;
		case MSELECTALL:
			show_help(rs_frstr[HMSELECTALL]);
			break;
		case MSELECTNONE:
			show_help(rs_frstr[HMSELECTNONE]);
			break;
		case MTEXT:
			show_help(rs_frstr[HMTEXT]);
			break;
		case MSYMTEXT:
			show_help(rs_frstr[HMSYMTEXT]);
			break;
		case MICONS:
			show_help(rs_frstr[HMICONS]);
			break;
		case MMASK:
			show_help(rs_frstr[HMMASK]);
			break;
		case MFONT:
			show_help(rs_frstr[HMFONT]);
			break;
		case MSORTFOLD:
			show_help(rs_frstr[HMSORT]);
			break;
		case MSORTVICE:
			show_help(rs_frstr[HMSORT]);
			break;
		case MSORTNAME:
			show_help(rs_frstr[HMSORT]);
			break;
		case MSORTSIZE:
			show_help(rs_frstr[HMSORT]);
			break;
		case MSORTDATE:
			show_help(rs_frstr[HMSORT]);
			break;
		case MSORTEXT:
			show_help(rs_frstr[HMSORT]);
			break;
		case MSORTNONE:
			show_help(rs_frstr[HMSORT]);
			break;
		case MSAVEINDEX:
			show_help(rs_frstr[HMSAVEINDEX]);
			break;
		case MDEFAULT:
			show_help(rs_frstr[HMDEFAULT]);
			break;

		case MNEXTWIN:
			show_help(rs_frstr[HMNEXTWIN]);
			break;
		case MCLOSEWIN:
			show_help(rs_frstr[HMCLOSEWIN]);
			break;
		case MCLOSEALLWIN:
			show_help(rs_frstr[HMCLOSEALLWIN]);
			break;
		case MDUPWIN:
			show_help(rs_frstr[HMDUPWIN]);
			break;

		case MAPPL:
			show_help(rs_frstr[HMAPPL]);
			break;
		case MFUNC:
		case MTOOLS:
			show_help(rs_frstr[HMFUNC]);
			break;
		case MCONFIG:
			show_help(rs_frstr[HMCONFIG]);
			break;
		case MHOTKEYS:
			show_help(rs_frstr[HMHOTKEYS]);
			break;
		case MHKACTIVE:
			show_help(rs_frstr[HMHKACTIVE]);
			break;
		case MDRIVE:
			show_help(rs_frstr[HMDRIVE]);
			break;
		case MCHANGEREZ:
			show_help(rs_frstr[HMCHANGEREZ]);
			break;
		case MEDITICONS:
			show_help(rs_frstr[HMEDITICONS]);
			break;
		case MLOADICONS:
			show_help(rs_frstr[HMLOADICONS]);
			break;
		case MCONSOLE:
			show_help(rs_frstr[HMCONSOLE]);
			break;
		case MFONTSEL:
			show_help(rs_frstr[HMFONTSEL]);
			break;
		case MAUTOSAVE:
			show_help(rs_frstr[HMAUTOSAVE]);
			break;
		case MSAVECONFIG:
			show_help(rs_frstr[HMSAVECONFIG]);
			break;
		case MLOADCONFIG:
			show_help(rs_frstr[HMLOADCONFIG]);
			break;

		default:
			show_help(rs_frstr[HMABOUT]);
			break;
		}
	} else {
		switch (item) {
		case MABOUT:
			fi_about.init();
			break;
		case MNEW:
			fi_new.init();
			break;
		case MOPEN:
			dl_open(ks);
			break;
		case MFIND:
			dl_find();
			break;
		case MINFO:
			dl_info();
			break;
		case MCLOSE:
			if (tb.topwin)
				handle_win(tb.topwin->handle, WM_CLOSED, 0, 0, 0, 0, 0);
			break;
		case MSHOW:
			dl_show(0, 0L);
			break;
		case MPRINT:
			dl_show(1, 0L);
			break;
		case MSAVEGROUP:
			dl_savegrp();
			break;
		case MEJECT:
			dl_eject();
			break;
		case MFORMAT:
			fi_format.init();
			break;
		case MQUIT:
			dl_quit();
			break;

		case MCOPY:
			if (tb.topfi)
				frm_ecopy(tb.topfi);
			else
				dl_copywin();
			break;
		case MCUT:
			if (tb.topfi)
				frm_ecut(tb.topfi);
			else
				dl_cutwin();
			break;
		case MPASTE:
			if (tb.topfi)
				frm_epaste(tb.topfi);
			else
				dl_pastewin();
			break;
		case MDELETE:
			dl_delete(0L);
			break;
		case MSELECTALL:
			dl_selall(1);
			break;
		case MSELECTNONE:
			dl_selall(0);
			break;

		case MTEXT:
			dl_itext(1);
			break;
		case MSYMTEXT:
			dl_itext(2);
			break;
		case MICONS:
			dl_itext(0);
			break;
		case MMASK:
			fi_mask.init();
			break;
		case MFONTSEL:
		case MFONT:
			if (((item == MFONTSEL) || ((ks & (K_LSHIFT | K_RSHIFT)) != 0 || !font)) && !glob.sm_fontsel) {
				aesmsg[0] = FONT_SELECT;
				if (fontid != -1) {
					aesmsg[1] = fontid;
					aesmsg[3] = whandle;
				} else {
					aesmsg[1] = tb.app_id;
					aesmsg[3] = -1;
				}
				aesmsg[2] = 0;
				aesmsg[4] = conf.font.id;
				aesmsg[5] = conf.font.size;
				aesmsg[6] = 1;
				aesmsg[7] = 0;
				appl_write(tb.app_id, 16, aesmsg);
			} else
				dl_font(0L);
			break;
		case MSORTFOLD:
			dl_isort(SORTFOLD);
			break;
		case MSORTVICE:
			dl_isort(SORTREV);
			break;
		case MSORTNAME:
			dl_isort(SORTNAME);
			break;
		case MSORTSIZE:
			dl_isort(SORTSIZE);
			break;
		case MSORTDATE:
			dl_isort(SORTDATE);
			break;
		case MSORTEXT:
			dl_isort(SORTTYPE);
			break;
		case MSORTNONE:
			dl_isort(SORTNONE);
			break;
		case MSAVEINDEX:
			dl_saveindex();
			break;
		case MDEFAULT:
			dl_default();
			break;

		case MNEXTWIN:
			dl_nextwin();
			break;
		case MCLOSEWIN:
			dl_closewin();
			break;
		case MCLOSEALLWIN:
			dl_closeallwin();
			break;
		case MDUPWIN:
			dl_dupwin();
			break;

		case MAPPL:
			dl_appl();
			break;
		case MFUNC:
			dl_cfunc(0);
			break;
		case MTOOLS:
			dl_cfunc(1);
			break;
		case MCONFIG:
			fi_config.init();
			break;
		case MHOTKEYS:
			fi_hotkeys.init();
			break;
		case MHKACTIVE:
			conf.hotkeys = !conf.hotkeys;
			mn_check();
			break;
		case MDRIVE:
			dl_drives(1, 0, ks & (K_LSHIFT | K_RSHIFT));
			break;
#ifndef _NAES
		case MCHANGEREZ:
			if ((tb.sys & SY_MAGX) && (tb.sys & SY_MSHELL)) {
				if (tb.magx->aesvars->version >= 0x400) {
					dl_changeres();
					break;
				} else {
					fi_rez.init();
					break;
				}
			} else
				dl_changeres_nomagic();
			break;
#else
			case MCHANGEREZ: dl_changeres_nomagic();
			break;
#endif /* _NAES */
		case MEDITICONS:
			dl_iconedit();
			break;
		case MLOADICONS:
			dl_iconload();
			break;
		case MCONSOLE:
			dl_conwin();
			break;
		case MAUTOSAVE:
			conf.autosave = !conf.autosave;
			mn_check();
			break;
		case MSAVECONFIG:
			dl_saveconf();
			break;
		case MLOADCONFIG:
			dl_loadconf();
			break;

		default:
			if (item >= MTOOL1 && item <= MTOOL1 + 9) {
				i = item - MTOOL1 + 1;
				j = 0;
				k = 0;
				while (j < 10) {
					if (conf.tobj[j][0])
						k++;
					if (k == i)
						break;
					else
						j++;
				}
				if (handle_fkey_or_tool(conf.tobj[j]))
					mn_check();
				else
					mybeep();
			}
			if (item >= MWIN1 && item <= MWIN10) {
				win = tb.win;
				for (i = 0; i < item - MWIN1; i++)
					win = win->next;
				win_top(win);
				magx_switch(tb.app_id, 0);
				mn_check();
			}
			break;
		}
	}
#ifdef TIMER
	timer1 = timer2 = clock();
#endif
	mn_tnormal(rs_trindex[MAINMENU], title, 1);
	mn_update();
}

/**-------------------------------------------------------------------------
 handle_win()

 Verarbeiten von Fensterereignissen
 -------------------------------------------------------------------------*/
void handle_win(int handle, int msg, int f1, int f2, int f3, int f4, int ks) {
	WININFO *win;
	FORMINFO *fi;
	W_PATH *wpath;
	W_GRP *wgrp;
	int top,new;
	int x, y, w, h;
	int mx, my, lks, mb, mc;
	int owner;
	int lshift, rshift;
	ALICE_WIN *awin;
	int ofull;
	int correct;

	/* Kein Redraw, wenn nicht im Fenster liegender Dialog aktiv ist */
	if (tb.sm_nowdial && (msg == WM_REDRAW))
		return;
	win = win_getwinfo(handle);
	if (!win) /* Kein eigenes Fenster */
	{
		/* Evtl. Redraw von Alice-Fenster? */
		if (msg == WM_REDRAW) {
			awin = alw_get(handle);
			if (awin)
				alw_draw(awin, f1, f2, f3, f4); /* Jo... */
		}
		return;
	}

	/* Timer fuer automatische Gruppensicherung setzen */
	glob.gtimer = 3;

	wpath = 0L;
	wgrp = 0L;
	fi = 0L;
	switch (win->class) {
		case WCDIAL:
		fi = (FORMINFO *)win->user;
		break;
		case WCPATH:
		wpath = (W_PATH *)win->user;
		break;
		case WCGROUP:
		wgrp = (W_GRP *)win->user;
		break;
	}

	lshift = rshift = new = 0;
	if (ks & K_ALT)
	new = 1;
	if (ks & K_LSHIFT)
		lshift = 1;
	if (ks & K_RSHIFT)
		rshift = 1;

	switch (msg) {
	case WM_ICONIFY:
		if (glob.fmode && glob.fwin == win)
			wf_clear();
		win_icon(win, f1, f2, f3, f4);
		mn_update();
		break;
	case WM_UNICONIFY:
		win_unicon(win, f1, f2, f3, f4);
		mn_update();
		break;
	case WM_ALLICONIFY:
		mybeep();
		break;
	case WM_M_BDROPPED: /* MagiC 2.0 */
	case WM_BOTTOMED: /* WINX */
		if (!tb.alwin || (win != tb.alwin)) {
			wind_set(win->handle, WF_BOTTOM, 0, 0, 0, 0);
			get_twin (&top);
			tb.topwin = win_getwinfo(top);
			win_newtop(tb.topwin);
			mn_check();
			mn_update();
			/* Workaround fÅr MagiC */
#ifndef _NAES
			if (tb.sys & SY_MAGX && !tb.topwin) {
				if (wind_get(top, WF_OWNER, &owner))
					magx_switch(owner, 0);
			}
#endif
		}
		break;
	case WM_UNTOPPED:
#ifdef TIMER
		timer1 = clock() - timer1;
		fprintf(stdout, "\033H\n\nZeit bis WM_UNTOPPED: %ld \n", (long)timer1);
#endif
		get_twin (&top);
		win = win_getwinfo(top);
		if (tb.topwin != win) {
			tb.topwin = win;
			win_newtop(tb.topwin);
			mn_check();
			mn_update();
		}
		break;
	case WM_REDRAW:
#ifdef TIMER
		timer2 = clock() - timer2;
		fprintf(stdout, "\033H\nZeit bis WM_REDRAW: %ld \n", (long)timer2);
#endif
		/*
		 * Workaround fuer Einblenden bei N.AES, das in diesem
		 * Fall kein WM_ONTOP verschickt ...
		 */
		get_twin(&top);
		if (top == handle) {
			win = win_getwinfo(top);
			if (tb.topwin != win) {
				tb.topwin = win;
				win_newtop(win);
				mn_update();
			}
		}
		win_redraw(win, f1, f2, f3, f4);
		break;
	case WM_NEWTOP:
	case WM_ONTOP:
		win_newtop(win);
#if 0
		if(tb.backwin) magx_switch(tb.app_id, 0);
#endif
		mn_check();
		mn_update();
		break;
	case WM_TOPPED:
		win_top(win);
#if 0
		magx_switch(tb.app_id, 0);
#endif
		mn_check();
		mn_update();
		break;
	case WM_CLOSED:
		if (tb.sm_alert) /* Alert offen? - dann geht kein Close! */
		{
			mybeep();
			if (tb.alwin)
				win_top(tb.alwin);
		} else {
			switch (win->class) {
				case WCDIAL:
				fi->exit(1,0);
				break;

				case WCPATH:
				if (!conf.closebox) {
					if (ks & K_CTRL) {
						/* Auf Loslassen der Maustaste warten */
						wind_update(BEG_MCTRL);
						do graf_mkstate(&mx,&my,&mb,&lks); while(mb&1);
						wind_update(END_MCTRL);

						if (wpath->path[3]) {
							/* Ggf. Wildcard-Dialog schlieûen */
							if(fi_mask.open) {if(dmask->win==win) fi_mask.exit(1,0);}

							wpath->rel=0;
							wpath->path[3]=0;
							wpath_update(win);
							win_redraw(win,tb.desk.x,tb.desk.y,tb.desk.w,tb.desk.h);
						}
					} else {
						if (lshift || rshift) {
							/* Auf Loslassen der Maustaste warten */
							wind_update(BEG_MCTRL);
							do graf_mkstate(&mx,&my,&mb,&lks); while(mb&1);
							wind_update(END_MCTRL);

							tb.topwin = win;
							dl_closewin();
						} else {
							if (new) {
								/* Verzeichnis in neuem Fenster îffnen */

								/* Auf Loslassen der Maustaste warten */
								wind_update(BEG_MCTRL);
								do
									graf_mkstate(&mx,&my,&mb,&lks);
								while (mb&1);
								wind_update(END_MCTRL);

								if (desk.sel.win) {
									((W_PATH *)desk.sel.win->user)->amask[0] = 0;
									wpath_esel(desk.sel.win,0L,0,0,1);
								}
								else icon_select(-1, 0, 0);
								if (!wpath_parent(win, 1, 1)) {
									tb.topwin = win;
									dl_closewin();
								}
							} else {
								/* Im gleichen Fenster */

								/* Falls bereits Root, dann schliessen */
								if (!((W_PATH *)win->user)->path[3]) {
									/* Auf Loslassen der Maustaste warten */
									wind_update(BEG_MCTRL);
									do
										graf_mkstate(&mx,&my,&mb,&lks);
									while (mb&1);
									wind_update(END_MCTRL);

									tb.topwin = win;
									dl_closewin();
								} else /* Kein Root */
								{
									/* Hotclose? */
									wind_update(BEG_MCTRL);
									evnt_timer(conf.clickms,0);
									graf_mkstate(&mx,&my,&mb,&lks);
									if(mb&1) {
										if(!wpath_parent(win,2,1)) {
											do
												graf_mkstate(&mx,&my,&mb,&lks);
											while(mb&1);
											tb.topwin=win;
											dl_closewin();
											mn_check();
										} else {
											graf_mouse(USER_DEF,&mf_hotc);
											mc=0;
											while (mb&1) {
												evnt_timer(100, 0);
												mc++;
												if (mc > 4) {
													mc = 0;
													if (!wpath_parent(win, 2, 1))
														mb = 0;
												}
												if (mb)
													graf_mkstate(&mx, &my, &mb, &lks);
											}
											do
												graf_mkstate(&mx,&my,&mb,&lks);
											while (mb&1);
											graf_mouse(ARROW,0L);
											wpath_update(win);
											win_slide(win,S_INIT,0,0);
											win_redraw(win,tb.desk.x,tb.desk.y,tb.desk.w,tb.desk.h);
										}
									} else /* Kein Hotclose */
									{
										if (!wpath_parent(win,0,1)) {
											tb.topwin = win;
											dl_closewin();
										}
									}
									wind_update(END_MCTRL);
								}
							}
						}
					}
				}
				else
				{
					/* Auf Loslassen der Maustaste warten */
					wind_update(BEG_MCTRL);
					do graf_mkstate(&mx,&my,&mb,&lks); while(mb&1);
					wind_update(END_MCTRL);
					tb.topwin=win;
					dl_closewin();
				}
				break;

				case WCGROUP:
				if (lshift || rshift)
				glob.autoclose = 1;
				default: /* FALL THROUGH */
				tb.topwin=win;
				dl_closewin();
				glob.autoclose = 0;
				break;
			}
			mn_check();
			mn_update();
		}
		break;
		case WM_FULLED:
		switch (win->class) {
			case WCCON:
			/* Console speziell behandeln */
			if(win->state&WSFULL)
				wind_get(win->handle,WF_PREVXYWH,&x,&y,&w,&h);
			else
				wind_get(win->handle,WF_FULLXYWH,&x,&y,&w,&h);
			win->curr.x=x;
			win->curr.y=y;
			win->curr.w=w;
			win->curr.h=h;
			win->state^=WSFULL;
			cwin_attr();
			break;
			case WCGROUP:
			/* Bei Gruppen ggf. Flag fÅr énderung setzen */
			if(!(win->state&WSICON))
			{
				wgrp_change(win);
				mn_update();
			}
			/* Fall through */
			case WCPATH:
			ofull = win->state & WSFULL;
			if((lshift || rshift) && !conf.autosize)
			{
				/* Mit Shift: Fuller auf Bildschirmgrîûe, falls nicht
				 automatische Grîûenanpassung */
				if (!ofull)
				{
#if 0
					win->full.x=tb.desk.x;win->full.y=tb.desk.y;
					win->full.w=tb.desk.w;win->full.h=tb.desk.h;
#else
					win->full = tb.desk;
					if (conf.autoplace)
					{
						win->full.x += tb.fleft;
						win->full.y += tb.fupper;
						win->full.w -= tb.fleft + tb.fright;
						win->full.h -= tb.fupper + tb.flower;
					}
#endif
				}
				win_full(win);
			} else {
				int as, asx, asy;

				/* Sonst: Nur optimale Groesse */
				as = conf.autosize;
				asx = conf.autosizex;
				asy = conf.autosizey;
				if (!as)
				conf.autosize = conf.autosizex = conf.autosizey = 1;
				w_full(win);
				conf.autosize = as;
				conf.autosizex = asx;
				conf.autosizey = asy;
			}
			if (ofull)
			win->state &= ~WSFULL;
			else
			win->state |= WSFULL;
			break;
		}
		break;
		case WM_ARROWED:
		switch (f1) {
			case WA_UPPAGE:
			win_slide(win,S_REL,0,-2);
			break;
			case WA_DNPAGE:
			win_slide(win,S_REL,0,2);
			break;
			case WA_UPLINE:
			win_slide(win,S_REL,0,-1);
			break;
			case WA_DNLINE:
			win_slide(win,S_REL,0,1);
			break;
			case WA_LFPAGE:
			win_slide(win,S_REL,-2,0);
			break;
			case WA_RTPAGE:
			win_slide(win,S_REL,2,0);
			break;
			case WA_LFLINE:
			win_slide(win,S_REL,-1,0);
			break;
			case WA_RTLINE:
			win_slide(win,S_REL,1,0)
			;break;
		}
		break;
		case WM_HSLID:
		win_slide(win,S_ABS,f1,-1);
		break;
		case WM_VSLID:
		win_slide(win,S_ABS,-1,f1);
		break;
		case WM_SIZED:
		/* Bei Console auf Zeichengroesse snappen */
		if(win->class==WCCON)
		{
			win->state&=~WSFULL;
			win->curr.w=f3;
			win->curr.h=f4;
			cwin_attr();
		}
		else
		{
			switch(win->class)
			{
				/* Bei Gruppen Flag fuer Aenderung setzen */
				case WCGROUP:
				wgrp_change(win);
				mn_update();
				break;
			}
			win_size(win,f1,f2,f3,f4);
		}
		break;
		case WM_MOVED:
		switch (win->class)
		{
			case WCGROUP:
			/* Bei Gruppen Flag fuer Aenderung setzen */
			if (!(win->state & WSICON))
			{
				/* Nur, wenn das Fenster nicht ausgeblendet war oder wird */
				/* Workaround: Fenster werden zweimal eingeblendet?? */
				if (((f1 != win->curr.x) || (f2 != win->curr.y)) &&
						(f1 < (tb.desk.x + tb.desk.w)) &&
						(f2 < (tb.desk.y + tb.desk.h)) &&
						(win->curr.x < (tb.desk.x + tb.desk.w)) &&
						(win->curr.y < (tb.desk.y + tb.desk.h)))
				{
					wgrp_change(win);
					mn_update();
				}
			}
			correct = wgrp->bpat;
			break;
			case WCPATH:
			correct = wpath->bpat;
			break;
			default:
			correct = 0;
			break;
		}
		/* Ggf. Position korrigieren wegen Hintergrundmuster */
		if ((correct != 0) && (correct != 7)) {
			f1 -= tb.desk.x;
			f2 -= tb.desk.y;
			f1 &= ~3;
			f2 &= ~3;
			f1 += tb.desk.x;
			f2 += tb.desk.y;
		}
		win_size(win,f1,f2,f3,f4);
		break;
	}
}

/**-------------------------------------------------------------------------
 handle_button()

 Verarbeiten von Mausklicks
 -------------------------------------------------------------------------*/
void handle_button(int mx, int my, int but, int ks, int br) {
	int whandle, obj;
	WININFO *win, *win1;
	WP_ENTRY *item;
	W_PATH *wpath;
	W_GRP *wgrp;
	WG_ENTRY *gitem, *gprev;
	int lmx, lmy, lmk, lks;
	int x, y, dx, dy;
	int i, istop, wait;
	int lshift, rshift, ctrl;
	int csim = 0, dsim = 0;
	int obut = but;

	wait = 1; /* Flag fuer Test auf Klick oder Drag&Drop */

	lshift = rshift = ctrl = 0;
	if (ks & K_LSHIFT)
		lshift = 1;
	if (ks & K_RSHIFT)
		rshift = 1;
	if (ks & K_CTRL)
		ctrl = 1;

	/* Rechtklick-Simulator */
	if (ctrl && (but == 1) && (br == 1)) {
		csim = 1;
		but = 2;
	}

	/* Klick im Fenster ? */
	whandle = wind_find(mx, my);
	if (whandle) /* Yo ... Fensterklick auswerten */
	{
		win = win_getwinfo(whandle); /* Fenster bekannt ? */
		if (win) /* Yo ... */
		{
			/* Fenster ikonifiziert? - dann keine weiteren Aktionen */
			if (win->state & WSICON)
				return;

			/* Ist das Fenster aktiv? */
			if (win != tb.topwin)
				istop = 0;
			else
				istop = 1;

			/* Falls Mausklick nicht im Arbeitsbereich, dann ignorieren
			 ist unter MTOS notwendig */
			if (mx < win->work.x || my < win->work.y
					|| mx >= win->work.x + win->work.w
					|| my >= win->work.y + win->work.h)
				return;

			/* Falls Auswahl im Hintergrund abgeschaltet, dann rechten
			 Mausknopf bei Hintergrundfenstern wie linken behandeln */
			if (!conf.bsel && !istop) {
				if (but != 1)
					but = 1;
			}
			/* Rechtsklick-Drag-Simulator fÅr MagiCMac-User */
			if ((br == 2) && (but == 1)) {
				wind_update (BEG_MCTRL);
				evnt_timer(conf.clickms, 0);
				graf_mkstate(&lmx, &lmy, &lmk, &lks);
				wind_update (END_MCTRL);
				if (lmk & 3) /* Linke Taste nach Doppelklick noch gedrÅckt? */
				{ /* Ja -> Rechtsklick simulieren */
					dsim = 1;
					but = 2;
					br = 1;
				}
			}

			switch (but) {
			case 1: /* Linke Maustaste */
				handle_button1: ;
				switch (win->class)
				{
					case WCPATH: /* Verzeichnisfenster */
					wpath=(W_PATH *)win->user;
					item=wpath_efind(win,mx,my);
					/* Objekt angeklickt ? */
					if(item) /* Yo ... */
					{
						/* Objekte in anderen Fenstern deselektieren */
						win1=tb.win;
						while(win1)
						{
							if(win1!=win)
							{
								switch(win1->class)
								{
									case WCPATH:
									((W_PATH *)win1->user)->amask[0]=0;
									wpath_esel(win1,0L,0,0,1);
									break;
									case WCGROUP:
									wgrp_esel(win1,0L,0,0);
									break;
								}
							}
							win1=win1->next;
						}
						icon_select(-1,0,0); /* Desktop-Objekte deselektieren */
						if(br > 1) /* Doppelklick oder Kontext */
						{
							wpath->amask[0]=0;
							wpath->focus=item->obnum-1;
							if (br == 2) /* Doppelklick */
							{
								wpath_esel(win,item,0,1,1); /* Objekt als einziges selektieren */
								icon_checksel(); /* Aktuelle Auswahl aktualisieren */
								/* Zusammen mit [Control] - Anzeigen */
								if(ctrl)
									dl_show(0,0L);
								else
									dl_open(ks); /* Sonst îffnen */
							}
							else /* Kontext */
							{
								if (!item->sel)
								{
									wpath_esel(win, item, 0, 1, 1);
									icon_checksel();
								}
								if (item->class == EC_PARENT)
								parent_popup(win, mx, my);
								else
								handle_context(mx, my, 0L);
							}
						}
						else /* Einfacher Klick */
						{
							wind_update(BEG_MCTRL);
							if(wait) evnt_timer(conf.clickms,0);
							graf_mkstate(&lmx,&lmy,&lmk,&lks);
							wind_update(END_MCTRL);
							if(lmk&3) /* Maustaste immer noch gedrÅckt -> Drag&Drop */
							{
								if(!item->sel && item->class!=EC_PARENT) /* Keine selektierte Gruppe */
								{
									wpath->amask[0]=0;
									wpath->focus=item->obnum-1;
									if(lshift || rshift)
									wpath_esel(win,item,1,1,1); /* [Shift] gedrÅckt */
									else
										wpath_esel(win,item,0,1,1);
								}
								icon_checksel(); /* Aktuelle Auswahl aktualisieren */

								/* Sonderbehandlung von Parent-Verzeichnissen... */
								if(item->class==EC_PARENT)
								{
									wpath->amask[0]=0;
									wpath->focus=item->obnum-1;
									wpath_esel(win,item,1,0,1);
									goto wrubber;
								}
								else /* ...sonst Drag&Drop ausfÅhren */
								{
									wpath->focus=item->obnum-1;
									wind_update(BEG_UPDATE);
									wpath_edrag(mx,my,lmk,lks);
									wind_update(END_UPDATE);
								}
							}
							else /* Nur angeklickt */
							{
								wpath->amask[0]=0;
								wpath->focus=item->obnum-1;
								if(lshift || rshift || item->sel)
								{
									/* Mausklick mit [Shift] oder selektiertes Objekt */
									if(item->sel || item->class!=EC_PARENT) {
										if(wpath->list->class==EC_PARENT && item!=wpath->list)
											wpath_esel(win,wpath->list,1,0,0);
										wpath_esel(win,item,1,1-item->sel,1);
									}
								}
								else
								/* Normaler Klick */
								wpath_esel(win,item,0,1-item->sel,1);
							}
						}
					}
					else /* Nein, kein Objekt ... */
					{
						if(br==1) /* Klick oder immer noch gedrÅckt? */
						{
							wind_update(BEG_MCTRL);
							if(wait) evnt_timer(conf.clickms,0);
							graf_mkstate(&lmx,&lmy,&lmk,&lks);
							wind_update(END_MCTRL);
							/* Hintergrund eines inaktiven Fensters angeklickt? */
							if(!istop && !(lmk&3)) {
								win_top(win);
								magx_switch(tb.app_id, 0);
								mn_check();
							} else {
								/* Objekte in anderen Fenster deselektieren */
								win1=tb.win;
								while(win1) {
									if(win1!=win) {
										switch(win1->class) {
											case WCPATH:
											((W_PATH *)win1->user)->amask[0]=0;
											wpath_esel(win1,0L,0,0,1);
											break;
											case WCGROUP:
											wgrp_esel(win1,0L,0,0);
											break;
										}
									}
									win1=win1->next;
								}
								/* Desktop-Objekte deselektieren und Auto-Locator
								 lîschen */
								icon_select(-1,0,0);
								wpath->amask[0]=0;
								wrubber:;
								/* Falls nicht mit [Shift] geklickt, dann alle Obj. deselekt. */
								if(!lshift && !rshift) wpath_esel(win,0L,0,0,1);
								if(lmk&3) /* Immer noch gedrÅckt - "Gummiband" aufziehen */
								{
									wind_update(BEG_MCTRL);wind_update(BEG_UPDATE);
									wpath_exsel(win,mx,my,lmk,ks);
									wind_update(END_MCTRL);wind_update(END_UPDATE);
								}
								/* Focus auf das erste selektierte Objekt */
								for(i=0;i<wpath->e_total;i++) {
									if(wpath->lptr[i]->sel) {
										wpath->focus=i;
										break;
									}
								}
							}
						}
						else if ((br == 3) || ((obut == 2) && (br == 2))) {
							if (istop) {
								icon_select(-1, 0, 0);
								handle_context(mx, my, win);
							} else {
								win_top(win);
								magx_switch(tb.app_id, 0);
								mn_check();
							}
						}
					}
					break;
					case WCGROUP: /* Gruppenfenster */
					wgrp=(W_GRP *)win->user;
					gitem=wgrp_efind(win,mx,my,&gprev);
					/* Objekt angeklickt ? */
					if(gitem) /* Yo ... */
					{
						/* Objekte in anderen Fenstern deselektieren */
						win1=tb.win;
						while(win1) {
							if(win1!=win) {
								switch(win1->class) {
									case WCPATH:
									((W_PATH *)win1->user)->amask[0]=0;
									wpath_esel(win1,0L,0,0,1);
									break;
									case WCGROUP:
									wgrp_esel(win1,0L,0,0);
									break;
								}
							}
							win1=win1->next;
						}
						/* Desktop-Objekte deselektieren */
						icon_select(-1,0,0);
						/* Gruppen-Objekt bearbeiten... */
						wgrp->focus=gitem->obnum-1;
						if(br > 1) /* Doppelklick oder Kontext */
						{
							if (br == 2) /* Doppelklick */
							{
								wgrp_esel(win,gitem,0,1);
								icon_checksel(); /* Aktuelle Auswahl aktualisieren */
								/* Zusammen mit [Control] - Anzeigen */
								if(ctrl) dl_show(0,0L);
								else dl_open(ks); /* Sonst îffnen */
							}
							else /* Kontext */
							{
								if (!gitem->sel) {
									wgrp_esel(win, gitem, 0, 1);
									icon_checksel();
								}
								handle_context(mx, my, 0L);
							}
						}
						else /* Einfacher Klick */
						{
							wind_update(BEG_MCTRL);
							if(wait) evnt_timer(conf.clickms,0);
							graf_mkstate(&lmx,&lmy,&lmk,&lks);
							wind_update(END_MCTRL);
							if(lmk&3) /* Maustaste immer noch gedÅckt - Drag&Drop */
							{
								if(!gitem->sel) {
									if(lshift || rshift) wgrp_esel(win,gitem,1,1);
									else wgrp_esel(win,gitem,0,1);
								}
								icon_checksel();
								wind_update(BEG_UPDATE);
								wgrp_edrag(mx,my,lmk,lks);
								wind_update(END_UPDATE);
							}
							else
							{
								if(gitem->sel) {
									wgrp_esel(win,gitem,1,0);
								} else {
									if (lshift || rshift)
										wgrp_esel(win,gitem,1,1-gitem->sel);
									else
										wgrp_esel(win,gitem,0,1);
								}
							}
						}
					}
					else /* Nein, kein Objekt ... */
					{
						if(br==1) /* Klick oder immer noch gedrÅckt? */
						{
							wind_update(BEG_MCTRL);
							if(wait) evnt_timer(conf.clickms,0);
							graf_mkstate(&lmx,&lmy,&lmk,&lks);
							wind_update(END_MCTRL);
							/* Hintergrund eines inaktiven Fensters angeklickt? */
							if(!istop && !(lmk&3)) {
								win_top(win);
								magx_switch(tb.app_id, 0);
								mn_check();
							} else {
								/* Objekte in anderen Fenster deselektieren */
								win1=tb.win;
								while(win1) {
									if(win1!=win) {
										switch(win1->class) {
											case WCPATH:
											((W_PATH *)win1->user)->amask[0]=0;
											wpath_esel(win1,0L,0,0,1);
											break;
											case WCGROUP:
											wgrp_esel(win1,0L,0,0);
											break;
										}
									}
									win1=win1->next;
								}
								/* Desktop-Objekte deselektieren */
								icon_select(-1,0,0);
								/* Falls nicht mit [Shift] geklickt, dann alle Obj. deselekt. */
								if(!lshift && !rshift) wgrp_esel(win,0L,0,0);
								if(lmk&3) /* Immer noch gedrÅckt - "Gummiband" aufziehen */
								{
									wind_update(BEG_MCTRL);wind_update(BEG_UPDATE);
									wgrp_exsel(win,mx,my,lmk,ks);
									wind_update(END_MCTRL);wind_update(END_UPDATE);
								}
								/* Focus auf das erste selektierte Objekt */
								gitem=wgrp->entry;
								while(gitem) {
									if(gitem->sel) {
										wgrp->focus=gitem->obnum-1;
										gitem=0L;
									} else
										gitem=gitem->next;
								}
							}
						} else if ((br == 3) || ((obut == 2) && (br == 2))) {
							if (istop) {
								icon_select(-1, 0, 0);
								handle_context(mx, my, win);
							} else {
								win_top(win);
								magx_switch(tb.app_id, 0);
								mn_check();
							}
						}
					}
					break;
					case WCCON:
					if ((br == 3) && istop)
						handle_context(mx, my, win);
					break;
				}
				break;
				case 2: /* Rechte Maustaste */
				wind_update(BEG_MCTRL);
				if(wait)
					evnt_timer(conf.clickms,0);
				graf_mkstate(&lmx,&lmy,&lmk,&lks);
				wind_update(END_MCTRL);
				if(lmk&3 && br==1) /* Taste immer noch gedrÅckt ? */
				{
					if (csim) {
						but = 1;
						csim = 0;
						goto handle_button1;
					}
					x=lmx;
					y=lmy;
					wind_update(BEG_MCTRL);
					graf_mouse(FLAT_HAND,0L);
					while(lmk&3) {
						dx=lmx-x;
						dy=lmy-y;
						dx*=conf.scroll;
						dy*=conf.scroll;
						if(dx!=0 || dy!=0) {
							win_slide(win,S_PABS,dx,dy);
							x=lmx;
							y=lmy;
						}
						graf_mkstate(&lmx,&lmy,&lmk,&lks);
					}
					graf_mouse(ARROW,0L);
					wind_update(END_MCTRL);
				} else {
					/* Einfacher Rechtsklick */
					if (br==1) {
						/* Doppelklick (2) oder Kontext (3) */
						br = 3 - !!(dsim || (!csim && conf.rdouble));
						/*
						 * Bei Rechtsklick in inaktives Fenster dieses toppen,
						 * wenn es kein simulierter Doppelklick ist
						 */
						if (!istop && (br == 3)) {
							win_top(win);
							magx_switch(tb.app_id, 0);
							mn_check();
						} else {
							but = 1;
							wait = 0;
							goto handle_button1;
						}
					}
				}
				break;
			}
		}
	}
	else /* Njet ... Klick auf dem Desktop */
	{
		/* Objekte in Fenstern deselektieren */
		win1=tb.win;
		while(win1) {
			switch(win1->class) {
				case WCPATH:
				((W_PATH *)win1->user)->amask[0]=0;
				wpath_esel(win1,0L,0,0,1);
				break;
				case WCGROUP:
				wgrp_esel(win1,0L,0,0);
				break;
			}
			win1=win1->next;
		}
		/* Objekt angeklickt ? */
		obj=icon_find(mx,my);
		/* "Doppelklick-Simulator" */
		if (conf.rdouble && !csim && (but != 1) && (obj != -1)) {
			but = 1;
			br = 2;
		}
		if(obj!=-1) /* Objekt angeklickt */
		{
			ICONDESK *p = desk.dicon + obj;

			if(br==2) /* Doppelklick */
			{
				if(but==1) {
					int du;

					icon_select(obj,0,1); /* Objekt als einziges selektieren */
					icon_checksel(); /* Aktuelle Auswahl aktualisieren */
					if(ks&K_ALT) /* Zusammen mit [Alternate] */
					{
						/* Verzeichnis îffnen, falls Datei */
						if(p->class!=IDFILE)
							mybeep();
						else
						{
							/* Verzeichnis îffnen */
							wpath_obfind(p->spec.file->name);
						}
					} else {
						if(ctrl)
							dl_show(0,0L);
						else
							dl_open(ks);
					}
					/* Auf Loslassen des Buttons warten */
					evnt_button(1, 3, 0, &du, &du, &du, &du);
				}
			}
			else /* Einfacher Klick */
			{
#if 0
				if(but==1) /* Klick mit linker Maustaste */
#endif
				{
					wind_update(BEG_MCTRL);
					if(wait) evnt_timer(conf.clickms,0);
					graf_mkstate(&lmx,&lmy,&lmk,&lks);
					wind_update(END_MCTRL);
					if(lmk&1) /* Linke Maustaste immer noch gedrÅckt -> Drag&Drop */
					{
						if(!p->select) /* Keine selektierte Gruppe */
						{
							if(lshift || rshift) icon_select(obj,1,1); /* [Shift] gedrÅckt */
							else
							{
								icon_select(-1,0,0);
								icon_select(obj,0,1);
							}
						}
						icon_checksel(); /* Aktuelle Auswahl aktualisieren */
						wind_update(BEG_UPDATE);
						icon_drag(mx,my,lmk,lks); /* Drag & Drop */
						wind_update(END_UPDATE);
					}
					else /* Nur angeklickt -> Objekt selektieren/deselektieren */
					{
						if ((but == 1) && (lshift || rshift || p->select))
						/* Linker Mausklick mit [Shift] oder selektiertes Objekt */
							icon_select(obj,1,1-p->select);
						else {
							if (but == 1) /* Normaler Klick */
								icon_select(obj,0,1-p->select);
							else {
								icon_select(obj, 0, 1);
								icon_checksel();
								handle_context(mx, my, 0L);
							}
						}
					}
				}
#if 0
				else /* Klick mit rechter Maustaste */
				{
				}
#endif
			}
		}
		else /* Kein Objekt angeklickt, sondern Desktop */
		{
			if (br==1) {
				if (but == 1) /* linke Maustaste, einfacher Klick */
				{
					/* Falls nicht mit [Shift] geklickt, dann alle Obj. deselekt. */
					if (!lshift && !rshift)
						icon_select(-1,0,0);
					wind_update(BEG_MCTRL);
					if(wait)
						evnt_timer(70,0);
					graf_mkstate(&lmx,&lmy,&lmk,&lks);
					wind_update(END_MCTRL);
					if(lmk&3) /* Immer noch gedrÅckt - "Gummiband" aufziehen */
					{
						wind_update(BEG_MCTRL);wind_update(BEG_UPDATE);
						icon_xsel(mx,my,lmk,ks);
						wind_update(END_MCTRL);wind_update(END_UPDATE);
					} else /* Sonst Thing "toppen" */
					magx_switch(-(tb.app_id + 1), 1);
				} else /* rechte Maustaste */
				{
					icon_select(-1, 0, 0);
					icon_checksel();
					desk_popup(mx, my);
				}
			}
		}
	}

	mn_update();
}

/**-------------------------------------------------------------------------
 handle_key()

 Verarbeiten von Tastatureingaben
 -------------------------------------------------------------------------*/
void call_smu(void) {
	int smu_id;

	if ((smu_id = appl_find("START   ")) >= 0)
		app_send(smu_id, VA_START, 0, 0, 0, 0, 0, 0);
	else
		mybeep();
}

/**
 *
 */
void handle_key(int ks, int kr) {
	unsigned int key;
	int title, item, l, i, j, k;
	char path[4], *p, akey;
	W_PATH *wpath;
	WP_ENTRY *litem;
	W_GRP *wgrp;
	WG_ENTRY *gitem;
	WININFO *win1;
	RECT wrect;
	int wrd, found, drv;
	char lmask[MAX_FLEN], fpath[MAX_PLEN], amask[MAX_FLEN];
	int focus;
	char *help;
	APPLINFO *aptr;
	int mx, my, d;

	graf_mkstate(&mx, &my, &d, &d);
	key = normkey(ks, kr);
	key &= ~(NKF_CAPS | NKF_RESVD); /* Nicht benîtigte Flags ausmaskieren */
	if (key & NKF_LSH || key & NKF_RSH)
		key |= NKF_SHIFT; /* Shift-Status */

	/* Pruefen, ob Menue-Shortcut vorliegt */
	if (menu_key(rs_trindex[MAINMENU], key, &title, &item)) {
		/* Shortcut vorhanden, Menuehandling ausfuehren */
		handle_menu(title, item, 0);
	} else /* Kein Shortcut, normale Verarbeitung */
	{
		char match[5];

		/* Shortcut fuer SMU-Aufruf? */
		i = 0;
		if (key & NKF_SHIFT)
			match[i++] = '\1';
		if (key & NKF_CTRL)
			match[i++] = '^';
		if (key & NKF_ALT)
			match[i++] = '\7';
		if (i != 0) {
			match[i++] = nkc_toupper(key & 0xff);
			match[i] = 0;
			if (!strcmp(rs_frstr[TXSCSTART], match)) {
				call_smu();
				return;
			}
		}
		/* Nein, also restliche Moeglichkeiten bearbeiten */
		switch (key) {
		case NKF_FUNC | NK_INS:
			if (glob.fmode)
				wf_clear();
			else {
				if (tb.topwin) {
					if (!(tb.topwin->state & WSICON)) {
						wf_set(tb.topwin);
						if (glob.fmode) {
							wf_draw();
							wf_sel(0, 0);
							wf_draw();
						}
					}
				}
			}
			break;
		case NKF_FUNC | NKF_SHIFT | NK_INS:
			if (glob.fmode) {
				if (glob.fdraw)
					wf_draw();
				wf_sel(1, 1);
				if (glob.fdraw)
					wf_draw();
			}
			break;
		case NKF_FUNC | NK_UNDO:
			if (tb.topwin)
				if ((tb.topwin->class==WCPATH) && !(tb.topwin->state&WSICON)) {
					if (!wpath_parent(tb.topwin, 0, 1))
						dl_closewin();
					mn_update();
				}
			break;
		case NKF_FUNC | NKF_ALT | NK_UNDO:
			if (tb.topwin) {
				if ((tb.topwin->class==WCPATH) && !(tb.topwin->state&WSICON))
					wpath_parent(tb.topwin, 1, 0);
				mn_update();
			}
			break;
		case NKF_FUNC | NK_HELP:
			help = "%I";
			if (tb.topwin) {
				if (tb.topwin->class==WCDIAL)
					help = 0L;
			}
			if (help) {
				show_help(help);
				mn_update();
			}
			break;
		case NKF_FUNC | NKF_CTRL | NK_UNDO:
			if (tb.topwin) {
				if ((tb.topwin->class==WCPATH) && !(tb.topwin->state&WSICON)) {
					wpath = (W_PATH *) tb.topwin->user;
					if (wpath->path[3]) {
						/* Ggf. Wildcard-Dialog schlieûen */
						if (fi_mask.open) {
							if (dmask->win == tb.topwin)
								fi_mask.exit(1, 0);
						}

						if (wpath->rel)
							wpath->rel = 0;
						wpath->path[3] = 0;
						wpath_update(tb.topwin);
#if 1
						w_draw(tb.topwin);
#else
						win_redraw(tb.topwin,tb.desk.x,tb.desk.y,tb.desk.w,tb.desk.h);
#endif
					}
					mn_update();
				}
			}
			break;
		case NKF_FUNC | NK_ESC:
		case NKF_FUNC | NKF_SHIFT | NK_ESC:
			if (tb.topwin) {
				if (!(tb.topwin->state & WSICON)) {
					switch (tb.topwin->class)
					{
						case WCPATH:
						wpath=(W_PATH *)tb.topwin->user;
						if(key&NKF_SHIFT)
						{
							/* Media-Change und Path-Update auslîsen */
							graf_mouse(BUSYBEE,0L);
							drv=wpath->filesys.biosdev;
							lock_device(drv);
							unlock_device(drv);
							app_send(tb.app_id, SH_WDRAW, 0, drv, 0, 0, 0, 0);
							graf_mouse(ARROW,0L);
						}
						else
						{
							/* wpath->offx=wpath->offy=0;*/
							wpath_update(tb.topwin);
#if 1
							w_draw(tb.topwin);
#else
							win_redraw(tb.topwin,tb.desk.x,tb.desk.y,tb.desk.w,tb.desk.h);
#endif
						}
						break;
						case WCGROUP: /* Gruppenfenster */
						if(key&NKF_SHIFT)
						{
							strcpy(fpath,((W_GRP *)tb.topwin->user)->name);
							dl_closewin();
							wgrp_open(fpath,0L, 0L);
						}
						break;
					}
					mn_update();
				}
			}
			break;
			case NKF_FUNC|NK_RET: /* Alternativer Shortcut "ôffnen" */
			case NKF_FUNC|NKF_NUM|NK_ENTER:
			case NKF_FUNC|NK_RET|NKF_ALT:
			case NKF_FUNC|NKF_NUM|NK_ENTER|NKF_ALT:
			case NKF_FUNC|NK_RET|NKF_SHIFT:
			case NKF_FUNC|NKF_NUM|NK_ENTER|NKF_SHIFT:
			if(desk.sel.desk || desk.sel.win) handle_menu(MFILE,MOPEN,ks);
			break;
			case NKF_FUNC|NKF_CTRL|NK_RET: /* Alternativer Shortcut "Anzeigen" */
			case NKF_FUNC|NKF_CTRL|NKF_NUM|NK_ENTER:
			case NKF_FUNC|NKF_CTRL|NK_RET|NKF_ALT:
			case NKF_FUNC|NKF_CTRL|NKF_NUM|NK_ENTER|NKF_ALT:
			handle_menu(MFILE,MSHOW,ks&(~K_CTRL));
			break;
			case NKF_FUNC|NK_TAB: /* Alternativer Shortcut "Info" */
			case NKF_FUNC|NKF_ALT|NK_TAB:
			handle_menu(MFILE,MINFO,0);
			break;
			case NKF_FUNC|NK_DEL: /* Alternativer Shortcut "Lîschen" */
			if(conf.usedel) handle_menu(MFILE,MDELETE,0);
			break;
			case NKF_FUNC|NKF_CTRL|NK_DEL:
			handle_menu(MFILE,MDELETE,0);
			break;
			case NKF_FUNC|NKF_CTRL|NK_BS: /* Parent-Popup */
			if (tb.topwin && (tb.topwin->class == WCPATH))
			{
				if ((wpath = (W_PATH *)tb.topwin->user)->path[3])
				{
#if 0
					wpath->amask[0] = 0;
					wpath_esel(tb.topwin, wpath->list, 0, 1, 1);
					icon_checksel();
#endif
					parent_popup(tb.topwin, -1, -1);
				}
				else
				mybeep();
			}
			else
			mybeep();
			break;
			default:
			if(tb.topwin) {
				if(!(tb.topwin->state&WSICON)) {
					/* Scroll, falls kein Cursor oder kein Verz.- bzw. Gruppenfenster */
					if(!glob.fmode || (tb.topwin->class!=WCPATH && tb.topwin->class!=WCGROUP)) {
						switch(key)
						{
							case NKF_FUNC|NK_UP: win_slide(tb.topwin,S_REL,0,-1);key_clr();break;
							case NKF_FUNC|NK_DOWN: win_slide(tb.topwin,S_REL,0,1);key_clr();break;
							case NKF_FUNC|NK_LEFT: win_slide(tb.topwin,S_REL,-1,0);key_clr();break;
							case NKF_FUNC|NK_RIGHT: win_slide(tb.topwin,S_REL,1,0);key_clr();break;
							case NKF_FUNC|NKF_SHIFT|NK_UP: win_slide(tb.topwin,S_REL,0,-2);key_clr();break;
							case NKF_FUNC|NKF_SHIFT|NK_DOWN: win_slide(tb.topwin,S_REL,0,2);key_clr();break;
							case NKF_FUNC|NKF_SHIFT|NK_LEFT: win_slide(tb.topwin,S_REL,-2,0);key_clr();break;
							case NKF_FUNC|NKF_SHIFT|NK_RIGHT: win_slide(tb.topwin,S_REL,2,0);key_clr();break;
							case NKF_FUNC|NK_CLRHOME: win_slide(tb.topwin,S_ABS,0,0);break;
							case NKF_FUNC|NKF_SHIFT|NK_CLRHOME: win_slide(tb.topwin,S_ABS,0,1000);break;
						}
					}
					else /* Cursor in Verzeichnissen bzw. Gruppen bewegen */
					{
						switch(key) {
							case NKF_FUNC|NK_UP: wf_move(-2,0);key_clr();break;
							case NKF_FUNC|NK_DOWN: wf_move(2,0);key_clr();break;
							case NKF_FUNC|NK_LEFT: wf_move(-1,0);key_clr();break;
							case NKF_FUNC|NK_RIGHT: wf_move(1,0);key_clr();break;
							case NKF_FUNC|NK_CLRHOME: wf_move(0,0);break;
							case NKF_FUNC|NKF_SHIFT|NK_CLRHOME: wf_move(9,0);break;
							case NKF_FUNC|NKF_SHIFT|NK_UP: wf_move(-2,1);key_clr();break;
							case NKF_FUNC|NKF_SHIFT|NK_DOWN: wf_move(2,1);key_clr();break;
							case NKF_FUNC|NKF_SHIFT|NK_LEFT: wf_move(-1,1);key_clr();break;
							case NKF_FUNC|NKF_SHIFT|NK_RIGHT: wf_move(1,1);key_clr();break;
						}
					}
				}
			}
			/* 'Alt'-Shortcut? */
			if(key>=(NKF_FUNC|NKF_ALT|'1') && key<=(NKF_FUNC|NKF_ALT|'9')) {
				akey=(key&0xff)-'0';
				aptr=desk.appl;
				while(aptr) {
					if(aptr->shortcut==akey) {
						app_opensel(aptr);
						aptr=0L;
					}
					if(aptr)
						aptr=aptr->next;
				}
			}
			/* Funktionstaste ? */
			if((key>=(NKF_FUNC|NK_F1) && key<=(NKF_FUNC|NK_F10))||
					(key>=(NKF_FUNC|NKF_SHIFT|NK_F1) && key<=(NKF_FUNC|NKF_SHIFT|NK_F10))||
					(key>=(NKF_FUNC|NKF_CTRL|NK_F1) && key<=(NKF_FUNC|NKF_CTRL|NK_F10))||
					(key>=(NKF_FUNC|NKF_ALT|NK_F1) && key<=(NKF_FUNC|NKF_ALT|NK_F10)))
			{
				if((key&(NKF_SHIFT|NKF_CTRL|NKF_ALT))==0)
					akey=key&0xf;
				if((key&(NKF_SHIFT|NKF_CTRL|NKF_ALT))==NKF_SHIFT)
					akey=(key&0xf)+10;
				if((key&(NKF_SHIFT|NKF_CTRL|NKF_ALT))==NKF_CTRL)
					akey=(key&0xf)+20;
				if((key&(NKF_SHIFT|NKF_CTRL|NKF_ALT))==NKF_ALT)
					akey=(key&0xf)+30;
				if (handle_fkey_or_tool(conf.fkey[akey]))
				mn_update();
				else
				mybeep();
			}
			else
			{
				akey=key&0xff;
				if(key&NKF_ALT)
				{
					/* Shortcuts fÅr Laufwerke */
					if((akey>='a' && akey<='z') || (akey>='A' && akey<='Z'))
					{
						path[0]=akey&0xdf;
						path[1]=':';path[2]='\\';path[3]=0;
						/* Nur ôffnen, wenn Laufwerk vorhanden */
						if(chk_drive((path[0] & ~32) - 'A')!=-1) {
#if 1
							dl_open_p(path, NULL, 0, "*", ks);
#else
							wrd=0;
							if(key&NKF_SHIFT) /* Aktuelles Fenster nehmen */
							{
								if(tb.topwin)
								{
									if((tb.topwin->class==WCPATH) && !(tb.topwin->state&WSICON))
									{
										wpath=(W_PATH *)tb.topwin->user;
										strcpy(wpath->path,path);
										wpath->offx=wpath->offy=0;
										wpath->rel=0;
										wpath_update(tb.topwin);
#if 1
										w_draw(tb.topwin);
#else
										win_redraw(tb.topwin,tb.desk.x,tb.desk.y,tb.desk.w,tb.desk.h);
#endif
										wrd=1;
									}
								}
							}

							if(!wrd)
							{
								/* Neues Fenster oeffnen */
								wpath_open(path, "*", 0, 0L, conf.index.text, -1, conf.index.sortby);
							}
#endif
						}
						else mybeep(); /* Sonst mosern */
					}
					mn_update();
				} else {
					if(!(key&NKF_CTRL) && (!(key&NKF_FUNC) || key==(NKF_FUNC|NK_BS))) {
						if (conf.hotkeys && (!tb.topfi || !tb.topfi->edit_obj)) {
							HOTKEY *p;

							if ((p = get_hotkey(akey)) != NULL) {
								if (!handle_fkey_or_tool(p->object))
								mybeep();
							}
							else
							mybeep();
						} else if (tb.topwin) {
							if(!(tb.topwin->state&WSICON)) {
								switch(tb.topwin->class) {
									case WCGROUP: /* Einfacher Auto-Locator in Gruppen */
									if(glob.fmode && akey==' ') /* Space zum Selektieren */
									{
										if(glob.fdraw)
											wf_draw();
										wf_sel(1,1);
										if(glob.fdraw)
											wf_draw();
									} else {
										/* Desktop-Icons deselektieren */
										icon_select(-1,0,0);
										/* EintrÑge in anderen Fenster deselektieren */
										win1=tb.win;
										while(win1) {
											if(win1!=tb.topwin) {
												switch(win1->class) {
													case WCPATH:
													((W_PATH *)win1->user)->amask[0]=0;
													wpath_esel(win1,0L,0,0,1);
													break;
													case WCGROUP:
													wgrp_esel(win1,0L,0,0);
													break;
												}
											}
											win1=win1->next;
										}
										/* Ausgehend vom aktuellen Objekt das nÑchste
										 passende suchen */
										wgrp=(W_GRP *)tb.topwin->user;
										gitem=wgrp->entry;
										akey=nkc_toupper(akey);

										/* Nur, wenn Åberhaupt Objekte vorhanden sind */
										if(gitem) {
											/* Selektiertes Objekt suchen */
											while(gitem && !gitem->sel) gitem=gitem->next;
											if(!gitem) gitem=wgrp->entry;

											/* Falls es bereits passt, dann Nachfolger,
											 sonst erstes Objekt */
											if(gitem->sel && nkc_toupper(gitem->title[0])==akey) gitem=gitem->next;
											else gitem=wgrp->entry;
											if(!gitem) gitem=wgrp->entry;

											found=0;
											while(gitem && !found) {
												if(nkc_toupper(gitem->title[0])==akey)
													found=1;
												if(!found)
													gitem=gitem->next;
											}
											if(!gitem) {
												gitem=wgrp->entry;
												while(gitem && !found) {
													if(nkc_toupper(gitem->title[0])==akey)
														found=1;
													if(!found)
														gitem=gitem->next;
												}
											}
											if(found && gitem) {
												wgrp_esel(tb.topwin,0L,0,0);
												wgrp_esel(tb.topwin,gitem,0,1);
												wgrp->focus=gitem->obnum-1;

												/* Falls mit [Shift], dann gleich ôffnen */
												if(key&NKF_SHIFT) {
													icon_checksel();
													dl_open(ks);
												}
											}
											else mybeep();
										}
									}
									break;
									case WCPATH: /* Auto-Locator in Verzeichnissen */
									wpath=(W_PATH *)tb.topwin->user;
									/* Falls kein Auto-Locator gesetzt ist und Cursor
									 aktiv, dann Leertaste zum Selektieren verwenden */
									if(!wpath->amask[0] && glob.fmode && akey==' ')
									{
										if(glob.fdraw) wf_draw();
										if(key&NKF_SHIFT) wf_sel(1,0); else wf_sel(1,1);
										if(glob.fdraw) wf_draw();
									}
									else /* Sonst normal verarbeiten */
									{
										/* Desktop-Icons deselektieren */
										icon_select(-1,0,0);
										/* EintrÑge in anderen Fenster deselektieren */
										win1=tb.win;
										while(win1)
										{
											if(win1!=tb.topwin)
											{
												switch(win1->class)
												{
													case WCPATH:
													((W_PATH *)win1->user)->amask[0]=0;
													wpath_esel(win1,0L,0,0,1);
													break;
													case WCGROUP:
													wgrp_esel(win1,0L,0,0);
													break;
												}
											}
											win1=win1->next;
										}
										/* Auto-Locator setzen */
										strcpy(lmask,wpath->amask);
										l=(int)strlen(lmask);
										if(key==(NKF_FUNC|NK_BS)) /* Backspace */
										{
											if(l>0) /* Auto-Locator vorhanden? */
											{
												/* Falls mit Filenamecompletion, dann
												 Auto-Locator immer komplett abschalten */
												if(conf.autocomp)
												{
													lmask[0]=0;l=0;
												}
												else /* Sonst nur die letzte Eingabe lîschen */
												{
													l--;
													if(l==1) lmask[0]=0;
													else
													{
														if(lmask[l]=='*')
														{
															lmask[l]=0;
															if(l>0) lmask[l-1]='*';
														}
														else
														{
															if(l>0) lmask[l]='*';
															else lmask[l]=0;
														}
													}
												}
											}
											else /* Kein AL, dann als 'Schlieûen' behandeln */
											{
												app_send(tb.app_id, MN_SELECTED, 0, MFILE, MCLOSE,
														0, 0, 0);
											}
										}
										else /* Jede andere Taste */
										{
											/* Schreibweise anpassen - immer groû */
											if (!conf.caseloc || (wpath->filesys.flags & UPCASE))
											akey=nkc_toupper(akey);
											if(l<wpath->filesys.namelen)
											{
												if(akey!=' ')
												{
													if(l>0)
													{
														if((l==1 && akey!='.') || l>1)
														if(lmask[l-1]=='*') l--;
													}
													lmask[l]=akey;
													if(l<wpath->filesys.namelen-1)
													{
														lmask[l+1]='*';
														lmask[l+2]=0;
													}
													else lmask[l+1]=0;
												}
												else
												{
													if(l>1)
													{
														l--;
														if(lmask[l]=='*') lmask[l]=0;
													}
												}
											}
											else
											{
												l--;
												if(lmask[l]=='*' && akey!='*')
												{
													if(akey!=' ') lmask[l]=akey;
													else lmask[l]=0;
												}
												else mybeep();
											}
										}
										/* Auto-Locator vorhanden ? */
										if(lmask[0])
										{
											/* Gibt es passende EintrÑge ? */
											wrd=0;found=0;
											for(i=0;i<wpath->e_total;i++)
											{
												litem=wpath->lptr[i];
												p=litem->name;
												j=0;
												while(p[j] && j<MAX_FLEN)
												{
													if (!conf.caseloc || (wpath->filesys.flags & UPCASE))
													amask[j] = nkc_toupper(p[j]);
													else
													amask[j] = p[j];
													j++;
												}
												amask[j]=0;
												if(wild_match1(lmask,amask))
												{
													if((litem->class!=EC_PARENT) || (litem->class==EC_PARENT && lmask[0]=='.'))
													{
														found++;
														if(found==1) focus=litem->obnum-1;
													}
												}
											}
											/* Alle EintrÑge entsprechend der Maske selektieren */
											if(found)
											{
												strcpy(wpath->amask,lmask);
												for(i=0;i<wpath->e_total;i++)
												{
													litem=wpath->lptr[i];
													p=litem->name;
													j=0;
													while(p[j] && j<MAX_FLEN)
													{
														if (!conf.caseloc || (wpath->filesys.flags & UPCASE))
														amask[j] = nkc_toupper(p[j]);
														else
														amask[j] = p[j];
														j++;
													}
													amask[j]=0;
													if(wild_match1(lmask,amask) &&
															((litem->class!=EC_PARENT) || (litem->class==EC_PARENT && lmask[0]=='.')))
													wpath_esel1(tb.topwin,litem,1,&wrect,&wrd);
													else
													wpath_esel1(tb.topwin,litem,0,&wrect,&wrd);
												}
												/* Bei Bedarf Auto-Locator automatisch erweitern */
												if(conf.autocomp)
												{
													int wild = 0;
													char last,
													*_mask;

													_mask = wpath->amask;
													l = (int)strlen(_mask);
													if (l)
													{
														l--;
														last = _mask[l];
														if (last == '*')
														_mask[l] = 0;
														wild = strchr(_mask, '*') || strchr(_mask, '?');
														_mask[l] = last;
													}
													if(!wild && akey!=' ' && key!=(NKF_FUNC|NK_BS) &&
															strcmp(_mask,"**")!=0)
													{
														l=-1;
														for(i=0;i<wpath->e_total;i++)
														{
															litem=wpath->lptr[i];
															if(litem->sel)
															{
																if(l==-1)
																{
#if 0
																	if(_mask[0]!='*')
#endif
																	{
																		j=0;
																		p=litem->name;
																		while(p[j] && j<MAX_FLEN)
																		{
																			if (!conf.caseloc || (wpath->filesys.flags & UPCASE))
																			amask[j] = nkc_toupper(p[j]);
																			else
																			amask[j] = p[j];
																			j++;
																		}
																		amask[j]=0;
																	}
#if 0
																	else
																	{
																		strcpy(amask,"*");
																		p=strrchr(litem->name,'.');
																		if(p) strcat(amask,p);
																		else
																		{
																			if(_mask[1]) strcat(amask,".");
																		}
																	}
#endif
																	l=(int)strlen(amask);
																}
																else
																{
																	for(j=k=0;j<l;)
																	{
																		if(amask[j]=='*')
																		{
																			j++;
																			if(amask[j]=='.') while(litem->name[k]!='.' && litem->name[k]) k++;
																			else while(litem->name[k]) k++;
																		}
																		else
																		{
																			if (!conf.caseloc || (wpath->filesys.flags & UPCASE))
																			{
																				if (amask[j] != nkc_toupper(litem->name[k]))
																				break;
																			}
																			else
																			{
																				if (amask[j] != litem->name[k])
																				break;
																			}
																		}
																		j++;k++;
																	}
																	amask[j]=0;l=j;
																}
															}
														}
														if(l!=-1)
														{
															if(l<wpath->filesys.namelen && found>1) strcat(amask,"*");
															strcpy(_mask,amask);
														}
													}
												}
												/* Fensterinhalt aktualisieren */
												if(found) wpath->focus=focus;
												if(wrd) win_redraw(tb.topwin,wrect.x,wrect.y,wrect.w,wrect.h);
												wpath_showsel(tb.topwin,1);
											}
											else mybeep();
										}
										else
										{
											if(wpath->amask[0])
											{
												wpath_esel(tb.topwin,0L,0,0,0);
											}
											wpath->amask[0]=0;
										}
									}
									wpath_info(tb.topwin);
									break;
								}
							}
							mn_update();
						}
					}
				}
			}
			break;
		}
	}
}

/**-------------------------------------------------------------------------
 handle_fmsg()

 Wird von der GEM-Toolbox fuer die Bearbeitung einer unbekannten
 AES-Message waehrend eines modalen Fensterdialogs aufgerufen
 -------------------------------------------------------------------------*/
void handle_fmsg(EVENT *mevent, FORMINFO *fi) {
	WININFO *win;
	FORMINFO *lfi;
	char *pipename = "U:\\PIPE\\DRAGDROP.AA";
	long fd;
	char c;

	aesmsg[1] = tb.app_id;
	aesmsg[2] = 0;
	aesmsg[3] = 0;
	aesmsg[4] = 0;
	aesmsg[5] = 0;
	aesmsg[6] = 0;
	aesmsg[7] = 0;

	if (mevent->ev_mwich & MU_MESAG) {
		switch (mevent->ev_mmgpbuf[0]) {
		case WM_REDRAW:
		case WM_TOPPED:
		case WM_FULLED:
		case WM_ARROWED:
		case WM_HSLID:
		case WM_VSLID:
		case WM_SIZED:
		case WM_MOVED:
		case WM_NEWTOP:
		case WM_ONTOP:
			handle_win(mevent->ev_mmgpbuf[3], mevent->ev_mmgpbuf[0],
					mevent->ev_mmgpbuf[4], mevent->ev_mmgpbuf[5],
					mevent->ev_mmgpbuf[6], mevent->ev_mmgpbuf[7],
					mevent->ev_mmokstate);
			break;
		case AP_TERM: /* Shutdown */
			/* Non-modale Dialoge oder Statusbox auf? */
			if (tb.sm_nowdial > 0 || fi == &fi_wait) {
				aesmsg[0] = AP_TFAIL;
				aesmsg[1] = 1;
				aesmsg[2] = 0;
				aesmsg[3] = 0;
				aesmsg[4] = 0;
				aesmsg[5] = 0;
				aesmsg[6] = 0;
				aesmsg[7] = 0;
				shel_write(SHW_AESSEND, 0, 0, (char *) aesmsg, 0L);
				frm_alert(1, rs_frstr[ALNOSHUT], altitle, 0, 0L);
			} else /* Nein - alles klar */
			{
				/* Falls als MagiC-Shell, dann globalen Shutdown auslîsen */
				if ((tb.sys & SY_MSHELL) && (mevent->ev_mmgpbuf[1] == -1))
					dl_shutdown();
				else
					glob.done = 2;
			}

			/* Hat Alles geklappt? */
			if (glob.done) {
				/* Jo - dann alle Fenster zumachen, Deinitialisieren und
				 beenden */
				win = tb.win;
				while (win) {
					switch (win->class)
					{
						case WCDIAL:
						lfi=(FORMINFO *)win->user;
						if(lfi->exit) lfi->exit(1,0); else frm_end(lfi);
						break;
						default:
						tb.topwin=win;
						dl_closewin();
					}
					win=win->next;
				}
				main_exit();
				Pterm0();
			}
			break;
		case AP_DRAGDROP:
			/* Dem Sender mitteilen, dass dieses Protokoll im Augenblick
			 nicht akzeptiert wird */
			pipename[18] = mevent->ev_mmgpbuf[7] & 0x00ff;
			pipename[17] = (mevent->ev_mmgpbuf[7] & 0xff00) >> 8;
			fd = Fopen(pipename, FO_RW);
			if (fd >= 0L) {
				c = DD_NAK;
				Fwrite((int) fd, 1, &c);
				Fclose((int) fd);
			}
			frm_alert(1, rs_frstr[ALWDIAL], altitle, 0, 0L);
			break;
		case FONT_SELECT:
		case FONT_CHANGED:
			frm_alert(1, rs_frstr[ALWDIAL], altitle, 0, 0L);
			break;
		case AV_PROTOKOLL:
			avs_protokoll(mevent->ev_mmgpbuf);
			break;
		case AV_GETSTATUS:
			avs_getstatus(mevent->ev_mmgpbuf);
			break;
		case AV_SENDKEY:
			mybeep();
			break;
		case AV_STATUS:
			avs_status(mevent->ev_mmgpbuf);
			break;
		case AV_ASKFILEFONT:
			avs_askfilefont(mevent->ev_mmgpbuf);
			break;
		case AV_ASKCONFONT:
			avs_askconfont(mevent->ev_mmgpbuf);
			break;
		case AV_OPENWIND:
			frm_alert(1, rs_frstr[ALWDIAL], altitle, 0, 0L);
			aesmsg[0] = VA_WINDOPEN;
			appl_write(mevent->ev_mmgpbuf[1], 16, aesmsg);
			break;
		case AV_STARTPROG:
			if (glob.initialisation)
				avs_startprog(mevent->ev_mmgpbuf);
			else {
				frm_alert(1, rs_frstr[ALWDIAL], altitle, 0, 0L);
				aesmsg[0] = VA_PROGSTART;
				aesmsg[7] = mevent->ev_mmgpbuf[7];
				appl_write(mevent->ev_mmgpbuf[1], 16, aesmsg);
			}
			break;
		case AV_ACCWINDOPEN:
			avs_accwindopen(mevent->ev_mmgpbuf);
			break;
		case AV_ACCWINDCLOSED:
			avs_accwindclosed(mevent->ev_mmgpbuf);
			break;
		case AV_PATH_UPDATE:
			avs_path_update(mevent->ev_mmgpbuf);
			break;
		case AV_COPY_DRAGGED:
			frm_alert(1, rs_frstr[ALWDIAL], altitle, 0, 0L);
			aesmsg[0] = VA_COPY_COMPLETE;
			appl_write(mevent->ev_mmgpbuf[1], 16, aesmsg);
			break;
		case AV_WHAT_IZIT:
			aesmsg[0] = VA_THAT_IZIT;
			aesmsg[3] = tb.app_id;
			appl_write(mevent->ev_mmgpbuf[1], 16, aesmsg);
			break;
		case AV_DRAG_ON_WINDOW:
			frm_alert(1, rs_frstr[ALWDIAL], altitle, 0, 0L);
			aesmsg[0] = VA_DRAG_COMPLETE;
			appl_write(mevent->ev_mmgpbuf[1], 16, aesmsg);
			break;
		case AV_EXIT:
			avs_exit(mevent->ev_mmgpbuf);
			break;
		case AV_XWIND:
			frm_alert(1, rs_frstr[ALWDIAL], altitle, 0, 0L);
			aesmsg[0] = VA_XOPEN;
			appl_write(mevent->ev_mmgpbuf[1], 16, aesmsg);
			break;
		case VA_START:
			frm_alert(1, rs_frstr[ALWDIAL], altitle, 0, 0L);
			break;
		case AV_VIEW:
			frm_alert(1, rs_frstr[ALWDIAL], altitle, 0, 0L);
			aesmsg[0] = VA_VIEWED;
			appl_write(mevent->ev_mmgpbuf[1], 16, aesmsg);
			break;
		case AV_FILEINFO:
			frm_alert(1, rs_frstr[ALWDIAL], altitle, 0, 0L);
			aesmsg[0] = VA_FILECHANGED;
			aesmsg[3] = mevent->ev_mmgpbuf[3];
			aesmsg[4] = mevent->ev_mmgpbuf[4];
			appl_write(mevent->ev_mmgpbuf[1], 16, aesmsg);
			break;
		case AV_COPYFILE:
			frm_alert(1, rs_frstr[ALWDIAL], altitle, 0, 0L);
			aesmsg[0] = VA_FILECOPIED;
			appl_write(mevent->ev_mmgpbuf[1], 16, aesmsg);
			break;
		case AV_DELFILE:
			frm_alert(1, rs_frstr[ALWDIAL], altitle, 0, 0L);
			aesmsg[0] = VA_FILEDELETED;
			appl_write(mevent->ev_mmgpbuf[1], 16, aesmsg);
			break;
		case AV_SETWINDPOS:
			mybeep();
			break;
		case THING_MSG: /* Thing-Command */
			/* Job? */
			if (mevent->ev_mmgpbuf[3] == TI_JOB
					&& mevent->ev_mmgpbuf[5] == 0x4711
					&& mevent->ev_mmgpbuf[1] == tb.app_id)
				handle_job(mevent);
			else {
				switch (mevent->ev_mmgpbuf[3]) {
				case AT_WINICONIFY: /* Alice immer beantworten */
				case AT_WINUNICONIFY:
					tp_handle(mevent);
					break;
				default: /* Alles andere geht jetzt net! */
					frm_alert(1, rs_frstr[ALWDIAL], altitle, 0, 0L);
					break;
				}
			}
			break;
		}
	}
	if (mevent->ev_mwich & MU_KEYBD && fi) {
		if (fi->normkey == (NKF_FUNC | NK_HELP) && fi->userinfo) {
			if (fi->state == FST_WIN)
				show_help(fi->userinfo);
			else
				frm_alert(1, rs_frstr[ALNOWDIAL], altitle, 0, 0L);
		}
	}
}

/**-------------------------------------------------------------------------
 Font-Protokoll
 -------------------------------------------------------------------------*/
void handle_fontmsg(int *msg) {
	WININFO *mwin, *win;
	W_GRP *wgrp;
	int i, j, w, ok, dummy;
	int dotest, wmin, wmax;
	int minade, maxade, dist[5], mw, eff[3];
	VDIPB vdipb;
	GFONT font;

	switch (msg[0]) {
	case FONT_SELECT:
		if (!glob.sm_fontsel)
			dl_font(msg);
		else
			frm_alert(1, rs_frstr[ALFONTSEL], altitle, 0, 0L);
		break;
	case FONT_CHANGED:
		ok = 0;
		if (msg[3] < 0)
			mwin = 0L;
		else
			mwin = win_getwinfo(msg[3]);
		font.id = msg[4];
		font.size = msg[5];
		font.fcol = msg[6];
		if (!mwin)
			mwin = tb.topwin;

		if (mwin) {
			switch (mwin->class)
			{
				case WCPATH:
				if (!font.id)
				font.id = conf.font.id;
				/* Pruefen, ob der Font ueberhaupt existiert */
				for (i = 0; i < gdos.numfonts; i++)
				if (gdos.fontid[i * 2L] == font.id)
				ok = 1;

				/* Falls ja, dann uebernehmen */
				if (ok) {
					conf.font.id = font.id;
					conf.font.size = font.size;
					conf.font.fcol = font.fcol;
					win = tb.win;
					while (win) {
						if (win->class == WCPATH) {
							wpath_iupdate(win, 0);
							wpath_tree(win);
							win_redraw(win, tb.desk.x, tb.desk.y, tb.desk.w, tb.desk.h);
							win_slide(win, S_INIT, 0, 0);
						}
						win = win->next;
					}
				}
				break;
				case WCGROUP: /* Gruppenfenster */
				wgrp = (W_GRP *)mwin->user;
				if (!font.id)
				font.id = wgrp->font.id;
				/* Pruefen, ob der Font ueberhaupt existiert */
				for (i = 0; i < gdos.numfonts; i++)
				if (gdos.fontid[i * 2L] == font.id)
				ok = 1;
				/* Falls ja, dann uebernehmen */
				if (ok) {
					wgrp->font.id = font.id;
					wgrp->font.size = font.size;
					wgrp->font.fcol = font.fcol;
					wgrp_tree(mwin);
					win_redraw(mwin, tb.desk.x, tb.desk.y, tb.desk.w, tb.desk.h);
					win_slide(mwin, S_INIT, 0, 0);
					wgrp_change(mwin);
				}
				break;
				case WCCON:
				if (!font.id)
				font.id = con.font.id;
				/* Pruefen, ob der Font ueberhaupt existiert */
				for(i=0;i<gdos.numfonts;i++) if(gdos.fontid[i*2L]==font.id) ok=1;
				/* Falls ja, dann pruefen, ob er fuer die Console geeignet ist */
				if(ok) {
					vdipb.contrl=_VDIParBlk.contrl;
					vdipb.intin=_VDIParBlk.intin;
					vdipb.ptsin=_VDIParBlk.ptsin;
					vdipb.intout=_VDIParBlk.intout;
					vdipb.ptsout=_VDIParBlk.ptsout;

					dotest=1;
					if(tb.gdos) /* Sicherheitshalber nur mit GDOS ;-) */
					{
						for(i=0;i<gdos.numfonts;i++) {
							if(gdos.fontid[i*2L]==font.id) {
								_VDIParBlk.contrl[0]=130;
								_VDIParBlk.contrl[1]=0;
								_VDIParBlk.contrl[3]=2;
								_VDIParBlk.contrl[5]=1;
								_VDIParBlk.contrl[6]=tb.vdi_handle;
								_VDIParBlk.intin[0]=gdos.fontid[i*2L+1];
								_VDIParBlk.intin[1]=0;
								vdi(&vdipb);
								/* Font monospaced? */
								if(_VDIParBlk.contrl[4]>=35) {
									dotest=0; /* Keine weiteren Tests nîtig */
									if((_VDIParBlk.intout[34]&0xff00)==0x0100)
										wmin=wmax=0;
									else {
										wmin=0;
										wmax=1;
									}
								}
							}
						}
					}

					if(dotest) /* Hat nicht geklappt ... also wie bisher :( */
					{
						vst_font(tb.vdi_handle,font.id);
						vqt_fontinfo(tb.vdi_handle,&minade,&maxade,dist,&mw,eff);
						wmin=32767;wmax=0;
						for(j=minade;j<=maxade;j++) {
							vqt_width(tb.vdi_handle,(char)j,&w,&dummy,&dummy);
							if(w>wmax) wmax=w;
							if(w<wmin) wmin=w;
						}
					}

					/* Font ok, dann setzen */
					if(wmin==wmax) {
						con.font.id=font.id;
						con.font.size=font.size;
						cwin_update();
					}
					else ok=0;
				}
				break;
			}
		}
		if(!ok) mybeep();
		break;
	}
}

/**-------------------------------------------------------------------------
 handle_job(), do_job()

 Multitasking fuer Arme ;-)
 -------------------------------------------------------------------------*/
void handle_job(EVENT *event) {
	switch (event->ev_mmgpbuf[4]) {
	case JB_FORMAT:
		job_format();
		break;
		/*  case JB_COPY:   job_copy();break; */
	}
}

void do_job(int j_id) {
	app_send(tb.app_id, THING_MSG, 0, TI_JOB, j_id, 0x4711, 0, 0);
}

/**-------------------------------------------------------------------------
 handle_dd()

 Drag&Drop-Anforderung bearbeiten
 -------------------------------------------------------------------------*/
int read_dd_data(char *buf, long len, int fd) {
	char c;

	buf[len] = 0;
	/* Je nach Art der Daten reagieren */
	c = DD_OK;
	Fwrite((int) fd, 1L, &c);
	Fread((int) fd, 1L, &c);
	if (c == DD_OK) /* Empfaenger einverstanden? */
	{
		return (Fread((int) fd, len, buf) == len);
	} else
		/* Nî :( */
		return (0);
}

void handle_dd(int *msg) {
	char *pipename = "U:\\PIPE\\DRAGDROP.AA";
	long fd;
	char c, ext[32];
	int i, j, hlen;
	int px, py, ks, whandle, dobj;
	WININFO *win;
	char hext[5];
	long dlen;
	char dname[MAX_PLEN];
	char *dbuf, *p;
	char name[MAX_FLEN], path[MAX_PLEN], full[MAX_PLEN];
	FILESYS fs;
	FORMINFO *fi;

	dbuf = 0L;
	px = msg[4];
	py = msg[5];
	ks = msg[6];
	pipename[18] = msg[7] & 0x00ff;
	pipename[17] = (msg[7] & 0xff00) >> 8;
	fd = Fopen(pipename, FO_RW);
	if (fd >= 0L) {
		/* Empfang bestaetigen */
		c = DD_OK;
		Fwrite((int) fd, 1L, &c);

		/* Extensions uebermitteln - ARGS und .TXT */
		for (i = 0; i < 32; i++)
			ext[i] = 0;
		strcpy(ext, "ARGS.TXT");
		Fwrite((int) fd, 32L, ext);

		/* Header lesen */
		Fread((int) fd, 2L, &hlen);
		Fread((int) fd, 4L, hext);
		hext[4] = 0;
		Fread((int) fd, 4L, &dlen);
		/* Name der Daten lesen */
		j = 9;
		i = 0;
		c = 1;
		while (j < hlen && i < MAX_PLEN && c != 0) {
			Fread((int) fd, 1L, &c);
			dname[i] = c;
			i++;
			j++;
		}
		dname[i] = 0;
		/* ueberschuessige Bytes abholen */
		while (j < hlen) {
			Fread((int) fd, 1L, &c);
			j++;
		}

		/* PATH wird noch nicht unterstuetzt! */
		if (!strcmp(hext, "PATH")) {
			dlen = 0L;
			dbuf = NULL;
			c = DD_NAK;
			Fwrite((int) fd, 1L, &c);
		}
		if (dlen > 0L) {
			dbuf = Malloc(dlen + 1L);
			if (dbuf == NULL) /* Kein Bufferspeicher mehr! */
			{
				c = DD_NAK;
				Fwrite((int) fd, 1L, &c);
			}
		}

		/* Daten entsprechend behandeln */
		if (dbuf) {
			if (!strcmp(hext, "ARGS")) /* Kommandozeile */
			{
				if (read_dd_data(dbuf, dlen, (int) fd)) {
					if (dlen > MAX_AVLEN)
						dlen = MAX_AVLEN;
					memcpy(aesbuf, dbuf, dlen);
					va_open(aesbuf);
				} else
					mybeep();
				Fclose((int) fd);
			} else /* Normale Daten */
			{
				strcpy(path, "X:\\");
				path[0] = tb.homepath[0];
				name[0] = 0;
				i = 0; /* Flag fuer Dateiauswahl/speichern */

				/* Zielobjekt ermitteln */
				whandle = wind_find(px, py);
				win = win_getwinfo(whandle);
				if (win) {
					switch (win->class)
					{
						case WCPATH:
						strcpy(path,((W_PATH *)win->user)->path);
						break;
						case WCDIAL:
						i=2;dobj=-1;
						if(!strcmp(hext,".TXT")) /* Auf Dialoge nur Text zulaessig! */
						{
							fi=(FORMINFO *)win->user;
							if((fi==&fi_cfunc || fi==&fi_mask || fi==&fi_dappinfo))
							{
								dobj=objc_find(fi->tree,ROOT,MAX_DEPTH,px,py);
								if(!(fi->tree[dobj].ob_flags&EDITABLE)) dobj=-1;
								if(fi==&fi_dappinfo && (dobj==DAILABEL || dobj==DAEVAL)) dobj=-1;
							}
						}

						if(dobj==-1)
						{
							mybeep();
							c = DD_NAK;
							Fwrite((int)fd, 1L, &c);
						}
						else
						{
							if (read_dd_data(dbuf, dlen, (int)fd))
							dl_wdrag_d(fi,dobj,dbuf,ks);
							else
							mybeep();
						}
						Fclose((int)fd);
						break;
						case WCGROUP:
						strcpy(path, ((W_GRP *)win->user)->name);
						if ((p = strrchr(path, '\\')) != NULL)
						p[1] = 0;
						break;
					}
				} else {
					dobj=icon_find(px,py);
					if(dobj) {
						ICONDESK *q = desk.dicon + dobj;
						switch(q->class) {
							case IDDRIVE:
							path[0]=q->spec.drive->drive+'A';
							break;
							case IDFOLDER:
							strcpy(path,q->spec.folder->path);
							break;
							case IDFILE:
							strcpy(path,q->spec.file->name);
							p=strrchr(path,'\\');if(p) p[1]=0;
							break;
							case IDCLIP:
							strcpy(path,q->spec.folder->path);
							strcpy(name,"SCRAP");strcat(name,hext);
							i=1; /* Daten kopieren, aber kein Fileselector */
							scrap_clear();
							break;
							case IDPRT:
							case IDTRASH:
							i = 2; /* Daten schon verarbeitet */
							c = (q->class == IDPRT) ? DD_PRINTER : DD_TRASH;
							Fwrite((int)fd, 1L, &c);
							Fclose((int)fd);
							break;
							default:
							c = DD_NAK;
							Fwrite((int)fd, 1L, &c);
							Fclose((int)fd);
							mybeep();
							i = 2;
						}
					}
				}

				if (i != 2) {
					if (!read_dd_data(dbuf, dlen, (int) fd)) {
						mybeep();
						i = 2;
					}
					Fclose((int) fd);
				}
				if (!i) {
					fsinfo(path, &fs);
					fsconv(path, &fs);
					strcat(path, "*");
					strcat(path, hext);
					fselect(path, name, &i, dname, 0, 0);
				}
				if (i == 1) {
					strcpy(full, path);
					p = strrchr(full, '\\');
					if (p)
						strcpy(&p[1], name);
					else
						strcat(full, name);
					fd = Fcreate(full, 0);
					if (fd < 0L)
						err_file(rs_frstr[ALFLCREATE], fd, full);
					else {
						Fwrite((int) fd, dlen, dbuf);
						Fclose((int) fd);
					}
				}
			}
			pfree(dbuf);
		} else
			Fclose((int) fd);
	} else
		mybeep();
}

/**
 * handle_fkey_or_tool
 *
 * Wertet einen Tool- oder Funktionstasteneintrag aus, îffnet also
 * entweder ein Fenster oder startet ein Programm.
 *
 * Eingabe:
 * entry: Zeiger auf den betreffenden Eintrag
 *
 * Rueckgabe:
 * 0: Eintrag war ungueltig
 * sonst: Eintrag OK (sagt nichts darueber aus, ob der Programmstart
 *        oder das ôffnen des Verzeichnisfensters erfolgreich war)
 */
int handle_fkey_or_tool(char *entry) {
	char fpath[MAX_PLEN], *p;

	if (get_buf_entry(entry, fpath, &p)) {
		if (*fpath) {
			while (*p == ' ')
				p++;
			if (fpath[strlen(fpath) - 1] == '\\') /* Verzeichnis */
			{
				if (*p) /* Mit Wildcard */
					wpath_open(fpath, p, 1, 0L, conf.index.text, -1, conf.index.sortby);
				else /* Ohne Wildcard */
					wpath_open(fpath, "*", 1, 0L, conf.index.text, -1, conf.index.sortby);
			} else
				/* Datei/Programm */
				va_open(entry);
			return (1);
		}
	}
	return (0);
}

/**
 * handle_context
 *
 * Stellt das Kontextmenue dar, abhaengig von den gerade selektierten
 * Eintraegen, und wertet es aus.
 *
 * Eingabe:
 * mx: x-Position der Maus
 * my: y-Position der Maus
 * win: Zeiger auf betroffenes Fenster (wenn das KontextmenÅ sich
 *      nicht auf bestimmte Eintraege bezieht) oder NULL
 */
void handle_context(int mx, int my, WININFO *win) {
	int pitem, i, count, cobj, ok, obj, d, ks, msg[8];
	char fname[MAX_PLEN], fpath[MAX_PLEN], **list;
	ICONDESK *p;
	OBJECT *tree;
	W_PATH *wpath;
	W_GRP *wgrp;
	WG_ENTRY *entry;
	POPMENU popsort, popshow, dummy;
	POPLIST plsendto;
	POPSUBMENU subpath[] = { { 0, NULL, POPCWSHOW }, { 0, NULL, POPCWSORT }, {
			0, NULL, 0 } }, subgroup[] = { { 0, NULL, POPCGSHOW },
			{ 0, NULL, 0 } }, subitem[] = { { 1, NULL, POPCSENDTO }, { 0, NULL,
			0 } };

	popsort.tree = rs_trindex[POPSORT];
	popshow.tree = rs_trindex[POPSHOW];
	popsort.subs = popshow.subs = dummy.subs = NULL;
	subpath[0].data.popup = &popshow;
	subpath[1].data.popup = &popsort;
	subgroup[0].data.popup = &popshow;
	subitem[0].data.poplist = &plsendto;

	for (tree = popsort.tree;; tree = popshow.tree) {
		for (i = 1;; i++) {
			if (tree[i].ob_flags & SELECTABLE)
				tree[i].ob_state &= ~(DISABLED | CHECKED);
			tree[i].ob_width = tree->ob_width - (tree->ob_width % tb.ch_w);
			if (tree[i].ob_flags & LASTOB)
				break;
		}
		if (tree == popshow.tree)
			break;
	}

	/* Kontextmenue fuer ein Fenster? */
	if (win) {
		switch (win->class)
		{
			case WCPATH:
			cobj = POPCWMASK;
			tree = rs_trindex[POPCWINDOW];
			break;
			case WCGROUP:
			case WCCON:
			cobj = POPCGFONT;
			tree = rs_trindex[POPCGRPWIN];
			break;
		}
		for (i = 1;; i++)
		{
			tree[i].ob_width = tree->ob_width - (tree->ob_width % tb.ch_w);
			if (tree[i].ob_flags & SELECTABLE)
			tree[i].ob_state &= ~(DISABLED|CHECKED);
			if (tree[i].ob_flags & LASTOB)
			break;
		}
		/* Waehlbare Eintraege anpassen */
		switch (win->class)
		{
			case WCPATH:
			wpath = (W_PATH *)win->user;
			switch (wpath->index.text)
			{
				case 0:
				obj = POPSHOWICONS;
				break;
				case 1:
				obj = POPSHOWTEXT;
				break;
				case 2:
				obj = POPSHOWSYMTEXT;
				break;
			}
			popshow.tree[obj].ob_state |= CHECKED;
			popshow.sel = obj;
			switch (wpath->index.sortby & ~(SORTREV|SORTFOLD))
			{
				case SORTNONE:
				obj = POPSORTNONE;
				break;
				case SORTNAME:
				obj = POPSORTNAME;
				break;
				case SORTSIZE:
				obj = POPSORTSIZE;
				break;
				case SORTDATE:
				obj = POPSORTDATE;
				break;
				case SORTTYPE:
				obj = POPSORTEXT;
				break;
			}
			popsort.tree[obj].ob_state |= CHECKED;
			popsort.sel = obj;
			if (wpath->index.sortby & SORTREV)
			popsort.tree[POPSORTREV].ob_state |= CHECKED;
			if (wpath->index.sortby & SORTFOLD)
			popsort.tree[POPSORTFOLD].ob_state |= CHECKED;
			if (tb.topwin != win)
			tree[POPCWPASTE].ob_state |= DISABLED;
			if ((tb.topwin != win) ||
					!drv_ejectable(wpath->filesys.biosdev))
			{
				tree[POPCWEJECT].ob_state |= DISABLED;
			}
			dummy.subs = subpath;
			break;
			case WCGROUP:
			wgrp = (W_GRP *)win->user;
			if (wgrp->changed)
			cobj = POPCGSAVEGROUP;
			else
			tree[POPCGSAVEGROUP].ob_state |= DISABLED;
			switch (wgrp->text)
			{
				case 0:
				obj = POPSHOWICONS;
				break;
				case 1:
				obj = POPSHOWTEXT;
				break;
				case 2:
				obj = POPSHOWSYMTEXT;
				break;
			}
			popshow.tree[obj].ob_state |= CHECKED;
			popshow.sel = obj;
			dummy.subs = subgroup;
			break;
			case WCCON:
			cobj = POPCGFONT;
			for (i = 1;; i++)
			{
				tree[i].ob_state |= DISABLED;
				if (tree[i].ob_flags & LASTOB)
				break;
			}
			tree[POPCGFONT].ob_state &= ~DISABLED;
			break;
		}
		dummy.tree = tree;
		wind_update(BEG_MCTRL);
		pitem = popup_menu(&dummy, mx, my, cobj, &ok, NULL);
		graf_mkstate(&d, &d, &d, &ks);
		wind_update(END_MCTRL);
		if (ok && (pitem > 0))
		{
			if (win->class != WCPATH)
			pitem |= 0x100;
			switch (pitem)
			{
				case POPCWNEW:
				case 0x100|POPCGNEW:
				fi_new.init();
				break;
				case 0x100|POPCGINFO:
				dl_groupinfo(win);
				break;
				case POPCWINFO:
				memset(msg, 0, sizeof(msg));
				msg[0] = AV_FILEINFO;
				msg[1] = tb.app_id;
				long2int((long)wpath->path, &msg[3], &msg[4]);
				avs_fileinfo(msg);
				break;
				case POPCWSHOW:
				case 0x100|POPCGSHOW:
				switch (popshow.sel)
				{
					case POPSHOWICONS:
					dl_itext(0);
					break;
					case POPSHOWTEXT:
					dl_itext(1);
					break;
					case POPSHOWSYMTEXT:
					dl_itext(2);
					break;
				}
				break;
				case POPCWSORT:
				switch (popsort.sel)
				{
					case POPSORTFOLD:
					dl_isort(SORTFOLD);
					break;
					case POPSORTREV:
					dl_isort(SORTREV);
					break;
					case POPSORTNONE:
					dl_isort(SORTNONE);
					break;
					case POPSORTNAME:
					dl_isort(SORTNAME);
					break;
					case POPSORTSIZE:
					dl_isort(SORTSIZE);
					break;
					case POPSORTDATE:
					dl_isort(SORTDATE);
					break;
					case POPSORTEXT:
					dl_isort(SORTTYPE);
					break;
				}
				break;
				case POPCWMASK:
				fi_mask.init();
				break;
				case POPCWFONT:
				case 0x100|POPCGFONT:
				dl_font(0L);
				break;
				case POPCWUPDATE:
				handle_key(ks, nkc_n2gem(NKF_FUNC|NK_ESC));
				break;
				case POPCWEJECT:
				dl_eject();
				break;
				case 0x100|POPCGSAVEGROUP:
				dl_savegrp();
				break;
				case POPCWPASTE:
				dl_pastewin();
				break;
				case POPCWSAVEINDEX:
				dl_saveindex();
				break;
			}
		}
		return;
	}
	/*
	 * Kontextmenue fuer ein Desktopobjekt, das kein abgelegter Ordner,
	 * keine abgelegte Datei und kein abgelegtes Device ist?
	 */
	if (desk.sel.desk) {
		p = desk.dicon + 1;
		for (obj = 1; obj <= MAXICON; obj++, p++) {
			if (p->select)
				break;
		}
		/* Paranoia */
		if ((obj > MAXICON) || (p->class == IDFREE)) {
			mybeep();
			return;
		}
		if ((p->class != IDFILE) && (p->class != IDFOLDER) &&
		(p->class != IDDEVICE)) {
			/* Ja, also spezielles Kontextmenue fuer Deskobjekte anzeigen */
			tree = rs_trindex[POPICONTEXT];
			for (i = 1;; i++) {
				tree[i].ob_width = tree->ob_width - (tree->ob_width % tb.ch_w);
				if (tree[i].ob_flags & SELECTABLE)
					tree[i].ob_state &= ~DISABLED;
				if (tree[i].ob_flags & LASTOB)
					break;
			}
			/* Waehlbare Eintraege anpassen */
			cobj = POPICOPEN;
			switch (p->class)
			{
				case IDDRIVE:
				if ((!*conf.format) && (p->spec.drive->drive > 1))
				tree[POPICFORMAT].ob_state |= DISABLED;
				if (!drv_ejectable(p->spec.drive->drive))
				tree[POPICEJECT].ob_state |= DISABLED;
				break;
				case IDTRASH:
				cobj = POPICINFO;
				tree[POPICOPEN].ob_state |= DISABLED;
				tree[POPICEJECT].ob_state |= DISABLED;
				tree[POPICFORMAT].ob_state |= DISABLED;
				tree[POPICDEL].ob_state |= DISABLED;
				break;
				case IDCLIP:
				tree[POPICEJECT].ob_state |= DISABLED;
				tree[POPICFORMAT].ob_state |= DISABLED;
				tree[POPICDEL].ob_state |= DISABLED;
				break;
				case IDPRT:
				cobj = POPICINFO;
				tree[POPICOPEN].ob_state |= DISABLED;
				tree[POPICEJECT].ob_state |= DISABLED;
				tree[POPICFORMAT].ob_state |= DISABLED;
				tree[POPICDEL].ob_state |= DISABLED;
				break;
			}
			wind_update (BEG_MCTRL);
			dummy.tree = tree;
			pitem = popup_menu(&dummy, mx, my, cobj, &ok, NULL);
			graf_mkstate(&d, &d, &d, &ks);
			wind_update (END_MCTRL);
			if (ok && (pitem > 0)) {
				switch (pitem) {
				case POPICOPEN:
					dl_open(ks);
					break;
				case POPICDEL:
					dl_delete(0L);
					break;
				case POPICEJECT:
					dl_eject();
					break;
				case POPICFORMAT:
					fi_format.init();
					break;
				case POPICINFO:
					dl_info();
					break;
				}
			}
			return;
		}
	}
	/* Sonst KontextmenÅ fÅr Dateien/Ordner anzeigen */
	tree = rs_trindex[POPCONTEXT];
	for (i = 1;; i++) {
		tree[i].ob_width = tree->ob_width - (tree->ob_width % tb.ch_w);
		if (tree[i].ob_flags & SELECTABLE)
			tree[i].ob_state &= ~DISABLED;
		if (tree[i].ob_flags & LASTOB)
			break;
	}
	/* Liste fÅr "Senden an" aufbauen */
	count = 0;
	if (glob.sendto) {
		for (entry = glob.sendto->entry; entry != NULL; entry = entry->next)
			count++;
		if (count) {
			plsendto.sel = plsendto.formshort = -1;
			plsendto.num = count;
			plsendto.len = 0;
			plsendto.list = list = pmalloc(count * sizeof(char *));
			if (list != NULL) {
				for (entry = glob.sendto->entry; entry != NULL;
						entry = entry->next) {
					*list++ = entry->title;
					if ((int) strlen(entry->title) > plsendto.len)
						plsendto.len = (int) strlen(entry->title);
				}
			} else
				count = 0;
		}
	}
	if (!count)
		tree[POPCSENDTO].ob_state |= DISABLED;
	/* WÑhlbare EintrÑge anpassen */
	cobj = POPCOPEN;
	if (desk.sel.numobs > 1) {
		cobj = POPCINFO;
		tree[POPCOPEN].ob_state |= DISABLED;
		tree[POPCVIEW].ob_state |= DISABLED;
		tree[POPCPRINT].ob_state |= DISABLED;
		tree[POPCAPPL].ob_state |= DISABLED;
	} else {
		if (desk.sel.files) {
			if (sel2buf(glob.cmd, fname, fpath, MAX_CMDLEN)) {
				if (get_buf_entry(glob.cmd, fname, NULL)) {
					strcpy(fpath, fname);
					for (i = 0; fpath[i]; i++)
						fpath[i] = nkc_toupper(fpath[i]);
					if (!is_appl(fname) && !app_match(0, fname, 0L)
							&& !wild_match(GRP_MASK, fpath)) {
						cobj = POPCVIEW;
						tree[POPCOPEN].ob_state |= DISABLED;
					}
					if (!app_match(1, fname, 0L)) {
						if (cobj == POPCVIEW)
							cobj = POPCINFO;
						tree[POPCVIEW].ob_state |= DISABLED;
					}
					if (!app_match(2, fname, 0L))
						tree[POPCPRINT].ob_state |= DISABLED;
				}
			}
		}
	}
	if (desk.sel.folders) {
		tree[POPCVIEW].ob_state |= DISABLED;
		tree[POPCPRINT].ob_state |= DISABLED;
		tree[POPCAPPL].ob_state |= DISABLED;
	}
	if (desk.sel.parent) {
		tree[POPCVIEW].ob_state |= DISABLED;
		tree[POPCPRINT].ob_state |= DISABLED;
		tree[POPCINFO].ob_state |= DISABLED;
		tree[POPCSENDTO].ob_state |= DISABLED;
		tree[POPCDEL].ob_state |= DISABLED;
		tree[POPCCOPY].ob_state |= DISABLED;
		tree[POPCCUT].ob_state |= DISABLED;
		tree[POPCAPPL].ob_state |= DISABLED;
	}
	if (desk.sel.devices) {
		cobj = POPCINFO;
		tree[POPCOPEN].ob_state |= DISABLED;
		tree[POPCVIEW].ob_state |= DISABLED;
		tree[POPCPRINT].ob_state |= DISABLED;
		tree[POPCINFO].ob_state |= DISABLED;
		tree[POPCSENDTO].ob_state |= DISABLED;
		tree[POPCDEL].ob_state |= DISABLED;
		tree[POPCCOPY].ob_state |= DISABLED;
		tree[POPCCUT].ob_state |= DISABLED;
		tree[POPCAPPL].ob_state |= DISABLED;
	}
	if (desk.sel.desk) {
		tree[POPCCOPY].ob_state |= DISABLED;
		tree[POPCCUT].ob_state |= DISABLED;
		setObjectText(tree, POPCDEL, rs_frstr[TXPOPREMOVE]);
	} else
		setObjectText(tree, POPCDEL, rs_frstr[TXPOPDEL]);
	if (!desk.sel.desk || !desk.sel.files)
		tree[POPCDIROPEN].ob_state |= DISABLED;
	wind_update (BEG_MCTRL);
	dummy.tree = tree;
	dummy.subs = subitem;
	pitem = popup_menu(&dummy, mx, my, cobj, &ok, NULL);
	graf_mkstate(&d, &d, &d, &ks);
	wind_update (END_MCTRL);
	if (ok && (pitem > 0)) {
		switch (pitem) {
		case POPCOPEN:
			dl_open(ks);
			break;
		case POPCDIROPEN:
			wpath_obfind(p->spec.file->name);
			break;
		case POPCVIEW:
			dl_show(0, 0L);
			break;
		case POPCPRINT:
			dl_show(1, 0L);
			break;
		case POPCINFO:
			dl_info();
			break;
		case POPCSENDTO:
			if (plsendto.sel >= 0) {
				count = 0;
				for (entry = glob.sendto->entry; entry != NULL;
						entry = entry->next) {
					if (count == plsendto.sel)
						break;
					count++;
				}
				/* Paranoia */
				if (entry == NULL)
					mybeep();
				else {
					if (dl_drag_on_gitem(glob.sendto, entry, ks, &d) && !d) {
						if (desk.sel.desk)
							icon_select(-1, 0, 0);
						else {
							switch (desk.sel.win->class)
							{
								case WCPATH:
								wpath_esel(desk.sel.win, 0L, 0, 0, 1);
								break;
								case WCGROUP:
								wgrp_esel(desk.sel.win, 0L, 0, 0);
								break;
							}
						}
						icon_checksel();
					}
				}
			}
			break;
			case POPCDEL:
			dl_delete(0L);
			break;
			case POPCCOPY:
			dl_copywin();
			break;
			case POPCCUT:
			dl_cutwin();
			break;
			case POPCAPPL:
			dl_appl();
			break;
		}
	}
	if (count)
		pfree(plsendto.list);
}

/*
 * desk_popup
 *
 * Spezielle Routine fÅr das KontextmenÅ des Desktophintergrunds.
 *
 * Eingabe:
 * mx: x-Position der Maus
 * my: y-Position der Maus
 */
void desk_popup(int mx, int my) {
	int i, j, max, first, nitems, oitems, maxw, px, py, ok, d, ks;
	char **eptr, *hlp, *q, *r, title[MAX_FLEN];
	ICONDESK *p, **icons;
	POPLIST items;

	if ((eptr = pmalloc(
			(MAXICON + 5)
					* (sizeof(char *) + MAX_FLEN + 8 + sizeof(ICONDESK *))))
			== NULL) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		return;
	}
	icons = (ICONDESK **) &eptr[MAXICON + 5];
	hlp = (char *) &icons[MAXICON + 5];
	for (i = 0; i < (MAXICON + 4); i++) {
		eptr[i] = hlp;
		hlp += MAX_FLEN + 8;
	}
	strcpy(eptr[0], rs_trindex[MAINMENU][MDRIVE].ob_spec.free_string);
	hlp = strrchr(eptr[0], 0) - 1;
	while (*hlp == ' ')
		*(hlp--) = 0;
	strcat(hlp, " ");
	maxw = (int) strlen(eptr[0]);
	strcpy(eptr[1], "-");
	strcpy(eptr[2], rs_trindex[MAINMENU][MCONFIG].ob_spec.free_string);
	hlp = strstr(eptr[2], "...");
	if (hlp == NULL) {
		hlp = strrchr(eptr[2], 0) - 1;
		while (*hlp == ' ')
			*(hlp--) = 0;
	} else
		hlp[3] = 0;
	strcat(hlp, " ");
	if ((int) strlen(eptr[2]) > maxw)
		maxw = (int) strlen(eptr[2]);
	strcpy(eptr[3], "-");
	nitems = oitems = 4;
	first = 0;
	p = desk.dicon + 1;
	for (i = 1; i <= MAXICON; i++, p++) {
		for (q = p->title; *q == ' '; q++)
			;
		strcpy(title, q);
		for (q = strrchr(title, 0) - 1; *q == ' '; *(q--) = 0)
			;
		if ((i <= MAXDRIVES) && (p->class == IDDRIVE)) {
			icons[nitems] = p;
			sprintf(eptr[nitems], "  %s (%c:) ",
					*title ? title : rs_frstr[TXFILESYS],
					p->spec.drive->drive + 'A');
			nitems++;
		} else if (i == OBCLIP) {
			icons[nitems] = p;
			sprintf(eptr[nitems], "  %s ", *title ? title : rs_frstr[TXCLIP]);
			nitems++;
		} else if ((i >= OBUSER) &&
		((p->class == IDFILE) || (p->class == IDFOLDER))) {
			if (!first)
				first = nitems;
			icons[nitems] = p;
			if (!*title) {
				strcpy(title, "?");
				if (p->class == IDFILE)
					hlp = p->spec.file->name;
				else
					hlp = p->spec.folder->path;
				q = strrchr(hlp, '\\');
				if (!q[1]) {
					*(r = q) = 0;
					q = strrchr(hlp, '\\');
				} else
					r = NULL;
				if ((q != NULL) && q[1])
					strcpy(title, ++q);
				if (r != NULL)
					*r = '\\';
			}
			sprintf(eptr[nitems], "  %s ", title);
			nitems++;
		}
		if (oitems != nitems) {
			oitems = nitems;
			if ((int) strlen(eptr[nitems - 1]) > maxw)
				maxw = (int) strlen(eptr[nitems - 1]);
		}
	}
	if (first) {
		/* EintrÑge sortieren */
		for (i = nitems - 1; i > first; i--) {
			max = i;
			for (j = first; j < i; j++) {
				if (strcasecmp(eptr[j], eptr[max]) > 0)
					max = j;
			}
			if (max != i) {
				hlp = eptr[i];
				eptr[i] = eptr[max];
				eptr[max] = hlp;
				p = icons[i];
				icons[i] = icons[max];
				icons[max] = p;
			}
		}
	}
	px = max(mx - (maxw * tb.ch_w) / 2, tb.desk.x);
	py = max(my - tb.ch_h - tb.ch_h / 2, tb.desk.y);
	if ((py + 8 + min(10, nitems) * tb.ch_h) >= (tb.desk.y + tb.desk.h))
		py = tb.desk.y + tb.desk.h - 1;
	memset(&items, 0, sizeof(POPLIST));
	items.formshort = -1;
	items.sel = -1;
	items.num = nitems;
	items.len = maxw;
	items.list = eptr;
	ok = poplist_handle(&items, px, py, maxw * tb.ch_w, 1, &d, NULL);
	graf_mkstate(&d, &d, &d, &ks);
	if (ok >= 0) {
		switch (items.sel) {
		case 0:
			dl_drives(1, 0, ks & (K_LSHIFT | K_RSHIFT));
			break;
		case 2:
			fi_config.init();
			break;
		default:
			desk.sel.numobs = desk.sel.desk = 1;
			p = icons[items.sel];
			p->select = 1;
			switch (p->class)
			{
				case IDDRIVE:
				desk.sel.drives = 1;
				break;
				case IDFILE:
				desk.sel.files = 1;
				break;
				case IDFOLDER:
				desk.sel.folders = 1;
				break;
			}
			dl_open(ks);
			icon_select(-1, 0, 0);
			icon_checksel();
			break;
		}
	}
	pfree(eptr);
}

/*
 * parent_popup
 *
 * Spezielle Routine fÅr das KontextmenÅ eines Elternverzeichnisses.
 *
 * Eingabe:
 * win: Betroffenes Fenster
 * mx: x-Position der Maus
 * my: y-Position der Maus
 */
void parent_popup(WININFO *win, int mx, int my) {
	int i, nitems, maxw, ok, d, ks;
	char **eptr, *hlp, *p, *q, path[MAX_PLEN + MAX_FLEN + 2];
	W_PATH *wpath;
	OBJECT dummy;
	POPLIST items, *poplist[] = { 0L, 0L };
	FORMINFO fi_dummy = { 0L, -1, 0, ROOT, 0, 0, 0, 0, 0L, 0L, 0, 0L, 0, 0 };

	wpath = (W_PATH *) win->user;
	nitems = count_char(wpath->path, '\\') - 1;
	if (nitems < 1) {
		mybeep();
		return;
	}
	if ((eptr = pmalloc((long) nitems * (sizeof(char *) + MAX_FLEN + 8)))
			== NULL) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		return;
	}
	hlp = (char *) &eptr[nitems];
	for (i = 0; i < nitems; i++) {
		eptr[i] = hlp;
		hlp += MAX_FLEN + 8;
	}
	strcpy(path, wpath->path);
	p = path + 3;
	strcpy(eptr[nitems - 1], "  \\ ");
	maxw = (int) strlen(eptr[nitems - 1]);
	for (i = nitems - 2; i >= 0; i--) {
		q = strtok(p, "\\");
		sprintf(eptr[i], "  %s\\ ", q);
		if ((int) strlen(eptr[i]) > maxw)
			maxw = (int) strlen(eptr[i]);
		p = NULL;
	}
	memset(&items, 0, sizeof(POPLIST));
	items.formshort = -1;
	items.sel = (mx < 0) ? 0 : -1;
	items.num = nitems;
	items.len = maxw;
	items.list = eptr;
	poplist[0] = &items;
	memset(&dummy, 0, sizeof(OBJECT));
	dummy.ob_type = G_STRING;
	dummy.ob_flags = LASTOB | TOUCHEXIT;
	dummy.ob_spec.free_string = "";
	dummy.ob_height = 0;
	dummy.ob_width = maxw;
	rsrc_obfix(&dummy, 0);
	if (mx >= 0) {
		mx -= dummy.ob_width / 2;
		my -= tb.ch_h / 2;
	} else {
		mx = win->work.x + 1;
		my = win->work.y + 1;
	}
	dummy.ob_x = max(mx, tb.desk.x);
	dummy.ob_y = max(my, tb.desk.y);
	if ((dummy.ob_y + 8 + min(7, nitems) * tb.ch_h)
			>= (tb.desk.y + tb.desk.h)) {
		dummy.ob_y = tb.desk.y + tb.desk.h - 1;
	}
	fi_dummy.tree = &dummy;
	fi_dummy.poplist = poplist;
	ok = poplist_do(1, &fi_dummy, 0, 0, 0, &d, &d, 0, &d);
	graf_mkstate(&d, &d, &d, &ks);
	if ((ok == 2) && (items.sel >= 0)) {
		if (ks & K_ALT) {
			strncpy(path, wpath->path, 2);
			path[2] = 0;
			for (i = nitems - 1; i >= items.sel; i--) {
				strcat(path, eptr[i] + 2);
				*strrchr(path, ' ') = 0;
			}
			wpath->amask[0] = 0;
			wpath_esel(win, 0L, 0, 0, 1);
			wpath_open(path, wpath->index.wildcard, 1, NULL, wpath->index.text, -1, wpath->index.sortby);
		} else {
			for (i = 0; i <= items.sel; i++) {
				if (!wpath_parent(win, 2, 0))
					break;
			}
			wpath_update(win);
			win_slide(win, S_INIT, 0, 0);
			w_draw(win);
		}
	}
	free(eptr);
}

/*
 * get_hotkey
 *
 * Ermittelt den HOTKEY-Eintrag zu einer Taste.
 *
 * Eingabe:
 * key: ASCII-Wert der gedrÅckten bzw. gesuchten Taste
 *
 * RÅckgabe:
 * NULL: Zu diesem ASCII-Wert gibt es keinen HOTKEY-Eintrag
 * sonst: Zeiger auf gefundenen HOTKEY-Eintrag
 */
HOTKEY *get_hotkey(int key) {
	HOTKEY *hk;

	for (hk = glob.hotkeys; hk != NULL; hk = hk->next) {
		if (hk->key == key)
			return (hk);
	}
	return (NULL);
}

/* EOF */
