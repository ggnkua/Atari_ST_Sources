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

/**=========================================================================
 DLFONT.C

 Thing
 Fontdialog
 =========================================================================*/

#include "..\include\globdef.h"
#include "..\include\types.h"
#include "rsrc\thing.h"
#include "rsrc\thgtxt.h"
#include <mt_gemx.h>

/*------------------------------------------------------------------*/
/*  local variables                                                 */
/*------------------------------------------------------------------*/

static DFONT *dfont;
static char sample[30] = "Murphy's word is law!";

/**-------------------------------------------------------------------------
 dl_font()

 Schriftart
 -------------------------------------------------------------------------*/

/**
 * Unterfunktion: Routine fuer das User-Objekt zur Darstellung der
 * gewaehlten Schriftart im Beispiel
 *
 * @param *parmblock
 */
short cdecl dl_font_usr(PARMBLK *parmblock) {
	GFONT *font;
	short dummy,pxy[4],ah,av,cw,ch,tx,ty;
	GRECT orect,crect;

	font = (GFONT *)parmblock->pb_parm;

	/* Clipping-Rechteck und Objekt-Rechteck holen */
	crect.g_x = parmblock->pb_xc;
	crect.g_y = parmblock->pb_yc;
	crect.g_w = parmblock->pb_wc;
	crect.g_h = parmblock->pb_hc;

	orect.g_x = parmblock->pb_x;
	orect.g_y = parmblock->pb_y;
	orect.g_w = parmblock->pb_w;
	orect.g_h = parmblock->pb_h;

	/* Schnittflaeche bilden und nur ausgeben, wenn noetig */
	if (rc_intersect((GRECT *)&crect, (GRECT *)&orect)) {
		/* Attribute setzen */
		vst_font(tb.vdi_handle,font->id);
		if (font->size < 0)
			vst_height(tb.vdi_handle, -font->size, &cw, &ch, &dummy, &dummy);
		else
			vst_point(tb.vdi_handle, font->size, &cw, &ch, &dummy, &dummy);
		vst_alignment(tb.vdi_handle, 0, 3, &ah, &av);
		if (font->attr&0x0040) {
			vst_color(tb.vdi_handle, font->bcol);
			vsf_color(tb.vdi_handle, font->fcol);
		} else {
			vst_color(tb.vdi_handle, font->fcol);
			vsf_color(tb.vdi_handle, font->bcol);
		}
		if (dfont->bpat == 7)
			vsf_interior(tb.vdi_handle, FIS_SOLID);
		else if (dfont->bpat == 0)
			vsf_interior(tb.vdi_handle, FIS_HOLLOW);
		else {
			vsf_interior(tb.vdi_handle, FIS_PATTERN);
			vsf_style(tb.vdi_handle, dfont->bpat);
		}
		vsf_perimeter(tb.vdi_handle, 0);

		/* Clipping aktivieren und Mauszeiger abschalten */
		pxy[0] = orect.g_x;
		pxy[1] = orect.g_y;
		pxy[2] = pxy[0] + orect.g_w - 1;
		pxy[3] = pxy[1] + orect.g_h - 1;
		vs_clip(tb.vdi_handle, 1, pxy);

		/* Hintergrund zeichnen */
		pxy[0] = parmblock->pb_x;
		pxy[1] = parmblock->pb_y;
		pxy[2] = pxy[0] + parmblock->pb_w - 1;
		pxy[3] = pxy[1] + parmblock->pb_h - 1;
		vswr_mode(tb.vdi_handle, MD_REPLACE);
		v_bar(tb.vdi_handle, pxy);

		/* Beispieltext ausgeben */
		vswr_mode(tb.vdi_handle, MD_TRANS);
		tx = parmblock->pb_x;
		ty = parmblock->pb_y + parmblock->pb_h - 1;
		if (font->attr & 0x0020) {
			vst_effects(tb.vdi_handle, (font->attr & 0x001f) | 0x0002);
			cw >>= 3;
			if (cw < 2)
				cw = 2;
			ch >>= 3;
			if (ch < 2)
				ch = 2;
			v_gtext(tb.vdi_handle, tx + cw, ty, sample);
			ty -= ch;
		}
		vst_effects(tb.vdi_handle, font->attr & 0x001f);
		udef_v_gtext(tb.vdi_handle, tx, ty, sample);

		/* Mauszeiger einschalten, Clipping aus */
		vs_clip(tb.vdi_handle, 0, pxy);

		/* "Standard"-Attribute setzen */
		vswr_mode(tb.vdi_handle, MD_REPLACE);
		vst_alignment(tb.vdi_handle, ah,av, &ah, &av);
		vst_font(tb.vdi_handle, 1);
		vst_point(tb.vdi_handle, 10, &dummy, &dummy, &dummy, &dummy);
	}

	return (parmblock->pb_currstate);
}

/**
 * Unterfunktion: Ermitteln aller Schriftgroessen eines Fonts
 *
 * @param fid
 * @param **list
 * @param size
 */
void dl_font_size(short fid, char **list, short size) {
	short i, fontsize, du;

	pl_size.sel = -1;
	pl_size.num = 0;

	if (fid != -1) {
		/* Font setzen */
		vst_font(tb.vdi_handle, fid);

		/* Schriftgroessen ermitteln */
		for (i = 0; i < 100; i++) {
			fontsize = vst_point(tb.vdi_handle, i, &du, &du, &du, &du);
			if (fontsize == i) {
				itoa(fontsize, list[pl_size.num], 10);
				if (size == fontsize)
					pl_size.sel = pl_size.num;
				pl_size.num++;
			}
		}
		vst_font(tb.vdi_handle, 1);
	}
}

/**
 *
 *
 * @param mode
 * @param ret
 */
#pragma warn -par
void de_font(short mode, short ret) {
	short done, dos, show;
	AVINFO *avinfo, *avnext;
	WININFO *win;
	W_GRP *wgrp = NULL;
	GRECT frec;
	short mx, my, mb, ks, mx1, my1, dx, dy;
	short tx1, ty1, tx2, ty2;
	short w, d;
	short whandle, owner;
	ACWIN *acwin;
	OBJECT *objectTree;
	short fret;
	char path[MAX_PLEN];
	THINGIMG *timg = NULL;

	objectTree = rs_trindex[FONT];

	done = 0;
	if (!mode) {
		if (dfont->intern) {
			switch (dfont->class) {
			case WCPATH:
				timg = &glob.dir_img;
				break;
			case WCGROUP:
				wgrp = (W_GRP *)dfont->fwin->user;
				timg = &wgrp->img_info;
				break;
			}
		}
		dos = 0;
		wind_update(BEG_UPDATE);
		switch (fi_font.exit_obj) {
		case FOCANCEL:
		case FOOK:
			done = fi_font.exit_obj;
			break;
		case FOSAMPLE:
			/* Font D&D */
			if (!dfont->intern) {
				/* Rechteck berechnen */
				objc_offset(objectTree, FOSAMPLE, &frec.g_x, &frec.g_y);
				frec.g_w = objectTree[FOSAMPLE].ob_width;
				frec.g_h = objectTree[FOSAMPLE].ob_height;
				if (frec.g_x < tb.desk.g_x)
					frec.g_x = tb.desk.g_x;
				if (frec.g_y < tb.desk.g_y)
					frec.g_y = tb.desk.g_y;
				if (frec.g_x + frec.g_w > tb.desk.g_x + tb.desk.g_w)
					frec.g_x = tb.desk.g_x + tb.desk.g_w - frec.g_w;
				if (frec.g_y + frec.g_h > tb.desk.g_y + tb.desk.g_h)
					frec.g_y = tb.desk.g_y + tb.desk.g_h - frec.g_h;

				/* Ausgangskoordinaten sichern */
				tx1 = frec.g_x;
				ty1 = frec.g_y;
				tx2 = tx1 + frec.g_w;
				ty2 = ty1 + frec.g_h;

				/* Auf gehts... */
				wind_update(BEG_MCTRL);
				graf_mouse(FLAT_HAND, 0L);
				rub_frame(&frec);
				graf_mkstate(&mx, &my, &mb, &ks);
				mx1 = mx;
				my1 = my;
				while (mb&1) {
					/* Mausposition veraendert? */
					if (mx1 != mx || my1 != my) {
						dx = mx - mx1;
						dy = my - my1;
						/* Delta auf Desktop begrenzen */
						if (tx1 + dx < tb.desk.g_x)
							dx = tb.desk.g_x - tx1;
						if (ty1 + dy < tb.desk.g_y)
							dy = tb.desk.g_y - ty1;
						if (tx2 + dx > tb.desk.g_x + tb.desk.g_w)
							dx = (tb.desk.g_x + tb.desk.g_w) - tx2;
						if( ty2 + dy > tb.desk.g_y + tb.desk.g_h)
							dy = (tb.desk.g_y + tb.desk.g_h) - ty2;

						/* Nur aktualisieren, wenn Delta immer noch !=0 */
						if (dx != 0 || dy != 0) {
							rub_frame(&frec);
							tx1 += dx;
							ty1 += dy;
							tx2 += dx;
							ty2 += dy;
							frec.g_x = tx1;
							frec.g_y = ty1;
							rub_frame(&frec);
						}

						mx1 += dx;
						my1 += dy;
					}
					graf_mkstate(&mx, &my, &mb, &ks);
				}
				rub_frame(&frec);
				graf_mouse(ARROW, 0L);
				wind_update(END_MCTRL);

				/* Pruefen, ob Zielfenster vorhanden ist */
				whandle = wind_find(mx, my);
				if (whandle) {
					/* Ja, dann Eigentuemer ermitteln */
					owner = -1;
					if (tb.sys & SY_OWNER) {
						if (!wind_get(whandle, WF_OWNER, &owner, &d, &d, &d))
						owner = -1;
					} else {
						acwin = acwin_find(whandle);
						if (acwin)
							owner = acwin->id;
					}
					/* Falls vorhanden, dann an Eigentuemer FONT_CHANGED schicken */
					if (owner != -1 && owner != tb.app_id) {
						appl_send(owner, FONT_CHANGED, 0, whandle, dfont->lfont.id, dfont->lfont.size, dfont->lfont.fcol, dfont->lfont.attr);
					}
				}
			}
			break;
		case FOFONTA:
			/* Anderer Font, dann ID setzen und Groessen ermitteln */
			if (dfont->class == WCCON)
				dfont->lfont.id = gdos.mfontid[pl_font.sel * 2L];
			else
				dfont->lfont.id = gdos.fontid[pl_font.sel * 2L];

			dl_font_size(dfont->lfont.id, dfont->sizelist, dfont->lfont.size);
			sprintf(objectTree[FOID].ob_spec.tedinfo->te_ptext, "ID: %-5d", dfont->lfont.id);
			frm_redraw(&fi_font, FOID);
			dos = 1;
			break;
		case FOSIZE:
			poplist_get(&fi_font, &pl_size);
		case FOSIZEA:
			dfont->lfont.size = atoi(objectTree[FOSIZE].ob_spec.tedinfo->te_ptext);
			if (dfont->lfont.size < 1)
				dfont->lfont.size = dfont->font->size;
			dos = 1;
			break;
		case FOFCOL:
			dfont->lfont.fcol = pop_tcolor.sel / 2 - 1;
			dos = 1;
		break;
		case FOBCOL:
			dfont->lfont.bcol=pop_bcolor.sel / 2 - 1;
			dos = 1;
			break;
		case FOBPAT:
			dfont->bpat = pop_bpat.sel / 2 - 1;
			dos = 1;
			break;
		case FOATTR1:
		case FOATTR2:
		case FOATTR3:
		case FOATTR4:
		case FOATTR5:
		case FOATTR6:
		case FOATTR7:
			w = 1 << (fi_font.exit_obj - FOATTR1);
			if (isObjectSelected(objectTree, fi_font.exit_obj))
				dfont->lfont.attr |= w;
			else
				dfont->lfont.attr &= ~w;
			dos = 1;
			break;
		case FOIMGF:
			if (dfont->class == WCGROUP) {
				if (wgrp->img_ok && (wgrp->img_planes < tb.planes)) {
					if (frm_alert(1, rs_frstr[ALNEWIMG], altitle, conf.wdial, 0L) == 2) {
						frm_norm(&fi_font);
						break;
					}
				}
				frm_redraw(&fi_font, ROOT);
			}
			strcpy(path, dfont->dirimg);			
	/*		wind_update(END_UPDATE);*/
			fret = full_fselect(path, NULL, "*.IMG", 0, rs_frstr[TXIMGSEARCH], 0, 0, &fi_font);
/*			wind_update(BEG_UPDATE);*/
			if (fret) {
				if (fret == 2)
					*dfont->dirimg = 0;
				else if (desk_icheck(timg, path, 0))
					strcpy(dfont->dirimg, path);
				strShortener(objectTree[FOIMG].ob_spec.tedinfo->te_ptext, dfont->dirimg, 30);
				frm_redraw(&fi_font, FOIMG);
			}
			
			frm_norm(&fi_font);
			break;
		}
		/* Beispiel neu zeichnen, wenn noetig */
		if (dos) {
			dos = 0;
			frm_redraw(&fi_font, FOSAMPLE);
		}
		wind_update(END_UPDATE);
	} else {
		done = FOCANCEL;
	}

	if (done) {
		frm_end(&fi_font);

		/* Speicher fuer die Popup-Listen wieder freigeben */
		pfree(dfont->sizelist);
		pfree(dfont->sizename);

		/* Falls "OK" angeklickt, dann Einstellungen uebernehmen */
		if (done == FOOK) {
			if (dfont->intern) {
				/* Thing-intern */
				memcpy(dfont->font, &dfont->lfont, sizeof(GFONT));
				graf_mouse(BUSYBEE, 0L);
				/* Fenster aktualisieren */
				switch(dfont->class) {
				case WCCON: /* Console */
					cwin_update();
					break;
				case WCPATH: /* Verzeichnisse */
					conf.bpat = dfont->bpat;
					if (strcmp(conf.dirimg, dfont->dirimg)) {
						desk_ifree(&glob.dir_img);
						strcpy(conf.dirimg, dfont->dirimg);
						if (*conf.dirimg) {
							glob.dir_ok = desk_iload(&glob.dir_img, conf.dirimg, 0, ALDIRIMGERR);
						}
					}
					win = tb.win;
					while (win) {
						if (win->class == WCPATH) {
							show = 0;
							if (isObjectSelected(objectTree, FOVSIZE))
								show |= SHOWSIZE;
							if (isObjectSelected(objectTree, FOVDATE))
								show |= SHOWDATE;
							if (isObjectSelected(objectTree, FOVTIME))
								show |= SHOWTIME;
							if (isObjectSelected(objectTree, FOVFLAG))
								show |= SHOWATTR;
							if (show != conf.index.show) {
								conf.index.show = show;
								mn_check();
								graf_mouse(BUSYBEE, 0L);
								wpath_iupdate(0L, 1);
								graf_mouse(ARROW, 0L);
							} else {
								wpath_iupdate(win, 0);
								wpath_tree(win);
								w_draw(win);
								win_slide(win, S_INIT, 0, 0);
							}
						}
						win = win->next;
					}
					break;
					case WCGROUP: /* Gruppe */
					if (strcmp(wgrp->img, dfont->dirimg)) {
						if (wgrp->img_ok)
							desk_ifree(&wgrp->img_info);
						strcpy(wgrp->img, dfont->dirimg);
						if (*wgrp->img) {
							wgrp->img_ok = desk_iload(&wgrp->img_info, wgrp->img, 0, ALDIRIMGERR);
							wgrp->img_planes = tb.planes;
						} else
						wgrp->img_ok = 0;
					}
					wgrp->font.id = dfont->lfont.id;
					wgrp->font.size = dfont->lfont.size;
					wgrp->font.fcol = dfont->lfont.fcol;
					wgrp->font.bcol = dfont->lfont.bcol;
					if (tb.colors < 16) {
						wgrp->fcol = wgrp->font.fcol;
						wgrp->bcol = wgrp->font.bcol;
						wgrp->bpat = dfont->bpat;
					} else {
						wgrp->fcol16 = wgrp->font.fcol;
						wgrp->bcol16 = wgrp->font.bcol;
						wgrp->bpat16 = dfont->bpat;
					}
					wgrp_tree(dfont->fwin);
					win_redraw(dfont->fwin, tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h);
					win_slide(dfont->fwin, S_INIT, 0, 0);
					wgrp_change(dfont->fwin);
					break;
				}

				/* Bei Bedarf VA_FONTCHANGED an die betroffenen Applikationen schicken */
				if (dfont->class == WCPATH || dfont->class == WCCON) {
					avinfo = glob.avinfo;
					while (avinfo) {
						avnext = avinfo->next;
						if (avinfo->state & 0x0008) {
							/* Nur, falls entsprechend angemeldet */
							if (avp_check(avinfo->id)) {
								appl_send(avinfo->id, VA_FONTCHANGED, 0, conf.font.id, conf.font.size, con.font.id, con.font.size, 0);

								/* Spezialbehandlung von TreeView */
								if (!strcmp(avinfo->name, "TREEVIEW"))
									appl_send(avinfo->id, VA_FILEFONT, 0, conf.font.id, conf.font.size, 0, 0, 0);
							}
						}
						avinfo = avnext;
					}
				}
				graf_mouse(ARROW, 0L);
			} else {
				/* Font-Protokoll */
				/* Antwort an den Absender schicken */
				if(dfont->fmsg[1]!=-1) {
					appl_send(dfont->fmsg[1], FONT_CHANGED, 0, dfont->fmsg[3],
							dfont->lfont.id, dfont->lfont.size, dfont->lfont.fcol,
							dfont->lfont.attr);
				}
			}
		}

		/* Semaphore loeschen, Speicher freigeben */
		pfree(dfont);
		glob.sm_fontsel = 0;
	}
}
#pragma warn .par

/**
 * Init dialog
 *
 * @param *msg: Pointer to the message from the FRONT protocol or
 *              0 if intern.
 */
void dl_font(short *msg) {
	short i, j;
	short minade, maxade, dist[5], mw, eff[3];
	short w, wmin, wmax, dummy;
	short dotest;
	short hlp;
	char name[40];
	short ret, font_format, flags;
	OBJECT *objectTree;

	objectTree = rs_trindex[FONT];

	if (fi_font.open) {
		mybeep();
		frm_restore(&fi_font);
		return;
	}

	dfont = pmalloc(sizeof(DFONT));
	if (!dfont) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		return;
	}

	glob.sm_fontsel = 1; /* Semaphore setzen */

	/* Spezielle Attribute komplett abschalten */
  objectTree[FOSATTR].ob_flags |= HIDETREE;
  objectTree[FOSVIEW].ob_flags |= HIDETREE;
	for (i = FOATTR1; i <= FOATTR7; i++) {
		objectTree[i].ob_state |= DISABLED;
		objectTree[i].ob_flags &= ~(SELECTABLE | TOUCHEXIT);
	}

	objectTree[FOIMG].ob_flags |= HIDETREE;
	objectTree[FOIMGF].ob_flags |= HIDETREE;

	wind_update(BEG_UPDATE);
	if (!msg) {
		/* Thing-intern */
		dfont->intern = 1;
		/* Einstellungen abhaengig vom aktiven Fenster */
		dfont->class = WCPATH;
		dfont->fwin = tb.topwin;
		if (tb.topwin)
			dfont->class = tb.topwin->class;

		switch (dfont->class) {
		case WCCON: /* Console-Fenster */
			dfont->intern = 2;
			/* Bei Bedarf Liste der moeglichen Console-Fonts aufbauen */
			if (!gdos.mnumfonts) {
				graf_mouse(BUSYBEE, 0L);
				for (i = 0; i < gdos.numfonts; i++) {
					dotest = 1;
					/* Sicherheitshalber nur mit GDOS ;-) */
					if (tb.gdos) {
						ret = vqt_ext_name (tb.vdi_handle, gdos.fontid[i * 2L + 1], name, &font_format, &flags);

						/* Function present?, Font monospaced? */
						if (ret)
						{
							dotest=0; /* Keine weiteren Tests noetig */
							if ( flags & 0x01)
								wmin = wmax = 0;
							else {
								wmin = 0;
								wmax = 1;
							}
						}
					}

					/* Hat nicht geklappt ... also wie bisher :( */
					if (dotest) {
						vst_font(tb.vdi_handle,gdos.fontid[i * 2L]);
						vqt_fontinfo(tb.vdi_handle, &minade, &maxade, dist, &mw, eff);
						wmin = 32767;
						wmax = 0;
						for (j = minade; j <= maxade; j++) {
							vqt_width(tb.vdi_handle, (char)j, &w, &dummy, &dummy);
							if (w > wmax)
								wmax = w;
							if (w < wmin)
								wmin = w;
						}
					}

					if (wmin == wmax) {
						gdos.mfontname[gdos.mnumfonts] = gdos.fontname[i];
						gdos.mfontid[gdos.mnumfonts * 2L] = gdos.fontid[i * 2L];
						gdos.mfontid[gdos.mnumfonts * 2L + 1] = gdos.fontid[i * 2L + 1];
						gdos.mnumfonts++;
					}
				}
				graf_mouse(ARROW, 0L);
			}

			setObjectText(objectTree, FOTITLE, rs_frstr[TXFTCONSOLE]);

			dfont->bpat = 7;
			dfont->font = &con.font;
			pl_font.list = gdos.mfontname;
			pl_font.num = gdos.mnumfonts;
			for (i = 0; i < gdos.mnumfonts; i++)
				if (gdos.mfontid[i * 2L] == dfont->font->id)
					pl_font.sel = i;

			setObjectDisabled(objectTree, FOFCOL);
			setObjectDisabled(objectTree, FOFCOLS);
			setObjectDisabled(objectTree, FOBCOL);
			setObjectDisabled(objectTree, FOBCOLS);
			setObjectDisabled(objectTree, FOBPAT);
			setObjectDisabled(objectTree, FOBPATS);
			break;

		case WCPATH: /* Verzeichnis */
		  objectTree[FOSVIEW].ob_flags &= ~HIDETREE;
			objectTree[FOIMG].ob_flags &= ~HIDETREE;
			objectTree[FOIMGF].ob_flags &= ~HIDETREE;

			hlp = conf.index.show;
			setObjectState(objectTree, FOVSIZE, SELECTED, hlp & SHOWSIZE);
			setObjectState(objectTree, FOVDATE, SELECTED, hlp & SHOWDATE);
			setObjectState(objectTree, FOVTIME, SELECTED, hlp & SHOWTIME);
			setObjectState(objectTree, FOVFLAG, SELECTED, hlp & SHOWATTR);

			strcpy(dfont->dirimg, conf.dirimg);
			strShortener(objectTree[FOIMG].ob_spec.tedinfo->te_ptext, dfont->dirimg, 30);

			setObjectText(objectTree, FOTITLE, rs_frstr[TXFTPATH]);

			dfont->font = &conf.font;
			pl_font.list = gdos.fontname;
			pl_font.num = gdos.numfonts;
			for (i = 0; i < gdos.numfonts; i++)
			if (gdos.fontid[i * 2L] == dfont->font->id)
				pl_font.sel = i;
			dfont->bpat = conf.bpat;

			unsetObjectDisabled(objectTree, FOFCOL);
			unsetObjectDisabled(objectTree, FOFCOLS);
			unsetObjectDisabled(objectTree, FOBCOL);
			unsetObjectDisabled(objectTree, FOBCOLS);
			unsetObjectDisabled(objectTree, FOBPAT);
			unsetObjectDisabled(objectTree, FOBPATS);
			break;

		case WCGROUP: /* Gruppe */
			dfont->intern = 2;
			setObjectText(objectTree, FOTITLE, rs_frstr[TXFTGRP]);

			dfont->font = &((W_GRP *)tb.topwin->user)->font;
			if (tb.colors < 16)
				dfont->bpat = ((W_GRP *)tb.topwin->user)->bpat;
			else
				dfont->bpat = ((W_GRP *)tb.topwin->user)->bpat16;
			pl_font.list = gdos.fontname;
			pl_font.num = gdos.numfonts;
			for (i = 0; i < gdos.numfonts; i++)
				if (gdos.fontid[i * 2L] == dfont->font->id)
					pl_font.sel = i;
			strcpy(dfont->dirimg, ((W_GRP *)tb.topwin->user)->img);
			strShortener(objectTree[FOIMG].ob_spec.tedinfo->te_ptext, dfont->dirimg, 30);

			unsetObjectDisabled(objectTree, FOFCOL);
			unsetObjectDisabled(objectTree, FOFCOLS);
			unsetObjectDisabled(objectTree, FOBCOL);
			unsetObjectDisabled(objectTree, FOBCOLS);
			unsetObjectDisabled(objectTree, FOBPAT);
			unsetObjectDisabled(objectTree, FOBPATS);

			objectTree[FOIMG].ob_flags &= ~HIDETREE;
			objectTree[FOIMGF].ob_flags &= ~HIDETREE;
			break;
		}
	} else {
		/* Auswahl durch Font-Protokoll */
		dfont->intern = 0;
	  objectTree[FOSATTR].ob_flags &= ~HIDETREE;
		for (i = FOATTR1; i <= FOATTR7; i++) {
			unsetObjectDisabled(objectTree, i);
			objectTree[i].ob_flags |= (SELECTABLE | TOUCHEXIT);
		}

		for (i = 0; i < 8; i++)
			dfont->fmsg[i] = msg[i];

		dfont->mfont.id = msg[4];
		dfont->mfont.size = msg[5];
		dfont->mfont.fcol = msg[6];
		dfont->mfont.bcol = 0;
		dfont->mfont.attr = msg[7];

		pl_font.list = gdos.fontname;
		pl_font.num = gdos.numfonts;
		pl_font.sel = 0;
		for (i = 0; i < gdos.numfonts; i++)
			if (gdos.fontid[i * 2L] == dfont->mfont.id)
				pl_font.sel = i;

		dfont->mfont.id = gdos.fontid[pl_font.sel * 2L];
		if (dfont->mfont.size == 0)
			dfont->mfont.size = 10;
		dfont->font = &dfont->mfont;
		dfont->bpat = 7;

		unsetObjectDisabled(objectTree, FOFCOL);
		unsetObjectDisabled(objectTree, FOFCOLS);
		setObjectDisabled(objectTree, FOBCOL);
		setObjectDisabled(objectTree, FOBCOLS);
		setObjectDisabled(objectTree, FOBPAT);
		setObjectDisabled(objectTree, FOBPATS);

		setObjectText(objectTree, FOTITLE, rs_frstr[TXFTFONTSEL]);
	}

	/* Parameter lokal sichern */
	memcpy(&dfont->lfont, dfont->font, sizeof(GFONT));

	/* Einige Sicherheitschecks */
	if (dfont->lfont.size < 1)
		dfont->lfont.size = 1;
	dfont->lfont.fcol &= 15;
	dfont->lfont.bcol &= 15;
	dfont->bpat &= 7;

	/* User-Objekt fuer Schriftgroesse initialisieren */
	usr_fontsample.ub_parm = (long)&dfont->lfont;

	/* Attribute eintragen */
	w = 0x0001;
	hlp = dfont->lfont.attr;
	for (i = 0; i < 7; i++) {
		setObjectState(objectTree, FOATTR1 + i, SELECTED, hlp & w);
		w <<= 1;
	}

	/* Popup-Liste fuer Schriftgroessen einrichten */
	pl_size.sel = -1;
	pl_size.num = 0;

	/* ... Speicher fuer Schriftgroessen (maximal 1-100) reservieren */
	dfont->sizename=pmalloc((long)(100*4));
	if (!dfont->sizename) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		glob.sm_fontsel = 0;
		pfree(dfont);
		return;
	}

	/* ... Speicher fuer Zeigerarray auf die Schriftgroessen reservieren */
	dfont->sizelist = pmalloc(sizeof(char *)*(long)100);
	if (!dfont->sizelist) {
		pfree(dfont->sizename);
		pfree(dfont);
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		glob.sm_fontsel = 0;
		return;
	}

	/* ... Zeigerarray initialisieren und Fontgroessen eintragen */
	for (i = 0; i < 100; i++)
		dfont->sizelist[i] = &dfont->sizename[i * 4];
	pl_size.list = dfont->sizelist;
	dl_font_size(dfont->lfont.id, dfont->sizelist, dfont->lfont.size);

	/* Sonstige Dialogelemente */
	itoa(dfont->lfont.size, objectTree[FOSIZE].ob_spec.tedinfo->te_ptext,10);
	pop_tcolor.sel = dfont->lfont.fcol * 2 + 2;
	pop_bcolor.sel = dfont->lfont.bcol * 2 + 2;
	pop_bpat.sel = dfont->bpat * 2 + 2;
	sprintf(objectTree[FOID].ob_spec.tedinfo->te_ptext, "ID: %-5d", dfont->lfont.id);

	/* Kontexthilfe */
	if (dfont->intern)
		fi_font.userinfo = rs_frstr[HMFONT];
	else
		fi_font.userinfo = rs_frstr[HMFONTSEL];
	wind_update(END_UPDATE);

	frm_start(&fi_font, conf.wdial, conf.cdial,0);
}
