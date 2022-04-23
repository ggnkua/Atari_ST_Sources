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
 DIALOG.C

 Thing
 Dialoge
 =========================================================================*/

#include "..\include\globdef.h"
#include "..\include\types.h"
#include "..\include\thingrsc.h"
#include <ctype.h>
#include <types.h>
#include <pwd.h>
#include <grp.h>
#ifndef __MINT__
#include <ext.h>
#endif
#include "..\include\dragdrop.h"

#undef ARNO_ORIGINAL

/* Lokale Prototypen sind auch nicht verkehrt... */
static void dl_copy_slupdate(unsigned long total, unsigned long ready,
		unsigned long size);
static int dl_runapp(char *iname, int itype, char *ititle, int *rex);

/**-------------------------------------------------------------------------
 dl_ddrag()

 Drag&Drop auf ein Desktop-Objekt bearbeiten
 -------------------------------------------------------------------------*/
void dl_ddrag(ICONDESK *icon, int ks) {
	int i, j;
#if 0
	int cont;
#endif
	int fin, rex;
	char name[MAX_PLEN], dname[4];
#if 0
	char apath[MAX_PLEN],aname[MAX_FLEN];
	APPLINFO app,*aptr;
#endif
	W_PATH *wpath;
	WP_ENTRY *item;
	W_GRP *wgrp;
	WG_ENTRY *gitem;

	fin = rex = 0; /* Flag fuer's automatische Deselektieren */
	wind_update( END_UPDATE); /* Update freigeben */

	if (desk.sel.desk) /* Objekte auf dem Desktop  */
	{
		ICONDESK *p = desk.dicon + 1;

		switch (icon->class) {
			case IDDEVICE:
			i=1;
			while((i <= MAXICON) && ((p->class == IDFREE) || !p->select)) {
				i++;
				p++;
			}
			fin=dl_devout(p->spec.file->name,icon->spec.device->name);
			break;
			case IDPRT:
			fin=dl_show(1,0L);
			rex=1;
			break;
			case IDFILE:
#if 1
			fin = dl_runapp(icon->spec.file->name,
			is_app(icon->spec.file->name,icon->spec.file->mode),
			icon->title, &rex);
#else
			/* Indirektes Ziel? */
			if(!is_app(icon->spec.file->name,icon->spec.file->mode))
			{
				aptr=app_isdrag(icon->spec.file->name);
				if(aptr)
				{
					/* Zieldatei zusammen mit Objekten Åbergeben */
					strcpy(glob.cmd,icon->spec.file->name);strcat(glob.cmd," ");
					i=(int)strlen(glob.cmd);
#ifdef ARNO_ORIGINAL
					cont=sel2buf(&glob.cmd[i],aname,apath,MAX_CLEN-i);
#else
					cont=sel2buf(&glob.cmd[i],aname,apath,MAX_CMDLEN-i);
#endif
					if(cont) fin=app_start(aptr,glob.cmd,apath,&rex);
					else
					{
						sprintf(almsg,rs_frstr[ALTOOMANY],aptr->title);
						frm_alert(1,almsg,altitle,conf.wdial,0L);
					}
				}
			}
			else
			{
				/* Als Applikation angemeldet ? */
				aptr=app_find(icon->spec.file->name);
				/* Nein */
				if(!aptr)
				{
					strcpy(app.name,icon->spec.file->name);
					app_default(&app);
					strcpy(app.title,icon->title);
					aptr=&app;
				}
				/* Alle selektierten Objekte als Kommandozeile Åbergeben */
				cont=sel2buf(glob.cmd,aname,apath,MAX_CMDLEN);
				/* Applikation starten */
				if(cont) fin=app_start(aptr,glob.cmd,apath,&rex);
				else
				{
					sprintf(almsg,rs_frstr[ALTOOMANY],aptr->title);
					frm_alert(1,almsg,altitle,conf.wdial,0L);
				}
			}
#endif
			break;
			case IDDRIVE: /* Zielobjekt Laufwerk */
				dname[0] = icon->spec.drive->drive + 'A';
				dname[1] = ':';
				dname[2] = '\\';
				dname[3] = 0;
				fin = dl_copy(dname, ks, 0L);
				break;
			case IDTRASH: /* Zielobjekt Papierkorb */
				dl_delete(0L);
				break;
			case IDCLIP: /* Objekt in die Ablage */
				for (i = 1; i <= MAXICON; i++, p++)
					if (p->class == IDFILE && p->select) {
						graf_mouse(BUSYBEE, 0L);
						fin = clip_file(p->spec.file->name);
						graf_mouse(ARROW, 0L);
					}
				break;
			case IDFOLDER: /* Objekt in Ordner kopieren */
				strcpy(name, icon->spec.folder->path);
				fin = dl_copy(name, ks, 0L);
				break;
		}
		if (fin)
			icon_select(-1, 0, 0);
	}
	else /* Objekte in einem Fenster ? */
	{
		if(desk.sel.win) {
			switch(desk.sel.win->class) {
				case WCPATH:
					wpath = (W_PATH *)desk.sel.win->user;
					switch(icon->class) {
					case IDDEVICE:
						for (j = 0; j < wpath->e_total; j++) {
							item = wpath->lptr[j];
							if (item->sel)
								break;
						}
	
						strcpy(name, wpath->path);
						strcat(name, item->name);
	
						fin = dl_devout(name, icon->spec.device->name);
						break;
					case IDPRT:
						fin = dl_show(1, 0L);
						rex = 1;
						break;
					case IDFILE:
#if 1
						fin = dl_runapp(icon->spec.file->name, is_app(icon->spec.file->name,icon->spec.file->mode), icon->title, &rex);
#else
					/* Indirektes Ziel? */
					if(!is_app(icon->spec.file->name,icon->spec.file->mode))
					{
						aptr=app_isdrag(icon->spec.file->name);
						if(aptr)
						{
							/* Zieldatei zusammen mit Objekten Åbergeben */
							strcpy(glob.cmd,icon->spec.file->name);strcat(glob.cmd," ");
							i=(int)strlen(glob.cmd);
#ifdef ARNO_ORIGINAL
							cont=sel2buf(&glob.cmd[i],aname,apath,MAX_CLEN-i);
#else
							cont=sel2buf(&glob.cmd[i],aname,apath,MAX_CMDLEN-i);
#endif
							if(cont) fin=app_start(aptr,glob.cmd,apath,&rex);
							else
							{
								sprintf(almsg,rs_frstr[ALTOOMANY],aptr->title);
								frm_alert(1,almsg,altitle,conf.wdial,0L);
							}
						}
					}
					else
					{
						/* Als Applikation angemeldet ? */
						aptr=app_find(icon->spec.file->name);
						/* Nein */
						if(!aptr)
						{
							strcpy(app.name,icon->spec.file->name);
							app_default(&app);
							strcpy(app.title,icon->title);
							aptr=&app;
						}
						/* Alle selektierten Objekte als Kommandozeile Åbergeben */
						cont=sel2buf(glob.cmd,aname,apath,MAX_CMDLEN);
						/* Applikation starten */
						if(cont) fin=app_start(aptr,glob.cmd,apath,&rex);
						else
						{
							sprintf(almsg,rs_frstr[ALTOOMANY],aptr->title);
							frm_alert(1,almsg,altitle,conf.wdial,0L);
						}
					}
#endif
						break;
					case IDDRIVE: /* Zielobjekt Laufwerk */
						dname[0] = icon->spec.drive->drive + 'A';
						dname[1] = ':';
						dname[2] = '\\';
						dname[3] = 0;
						fin = dl_copy(dname, ks, 0L);
						break;
					case IDTRASH: /* Zielobjekt Papierkorb */
						fin = dl_delete(0L);
						break;
					case IDCLIP: /* Objekt in die Ablage */
					for(j=0;j<wpath->e_total;j++) {
						item=wpath->lptr[j];
						if(item->class==EC_FILE && item->sel) {
							graf_mouse(BUSYBEE,0L);
							strcpy(name,wpath->path);strcat(name,item->name);
							fin=clip_file(name);
							graf_mouse(ARROW,0L);
						}
					}
					break;
					case IDFOLDER: /* Objekt in Ordner kopieren */
					strcpy(name,icon->spec.folder->path);
					fin=dl_copy(name,ks,0L);
					break;
				}
				if(fin && !rex) {
					wpath->amask[0]=0;
					wpath_esel(desk.sel.win,0L,0,0,1);
				}
				break;
				case WCGROUP:
				wgrp=(W_GRP *)desk.sel.win->user;
				gitem=wgrp->entry;while(!gitem->sel) gitem=gitem->next;
				wgrp_eabs(wgrp,gitem,name);
				switch(icon->class) {
					case IDDEVICE:
					if(gitem->class==EC_FILE)
						fin=dl_devout(name,icon->spec.device->name);
					break;
					case IDPRT:
					if(gitem->class==EC_FILE) {
						fin=dl_show(1,name);
						rex=1;
					}
					break;
					case IDFILE:
#if 1
					fin = dl_runapp(icon->spec.file->name,
							is_app(icon->spec.file->name,icon->spec.file->mode),
							icon->title, &rex);
#else
					/* Indirektes Ziel? */
					if(!is_app(icon->spec.file->name,icon->spec.file->mode))
					{
						aptr=app_isdrag(icon->spec.file->name);
						if(aptr)
						{
							/* Zieldatei zusammen mit Objekten Åbergeben */
							strcpy(glob.cmd,icon->spec.file->name);strcat(glob.cmd," ");
							i=(int)strlen(glob.cmd);
#ifdef ARNO_ORIGINAL
							cont=sel2buf(&glob.cmd[i],aname,apath,MAX_CLEN-i);
#else
							cont=sel2buf(&glob.cmd[i],aname,apath,MAX_CMDLEN-i);
#endif
							if(cont) fin=app_start(aptr,glob.cmd,apath,&rex);
							else
							{
								sprintf(almsg,rs_frstr[ALTOOMANY],aptr->title);
								frm_alert(1,almsg,altitle,conf.wdial,0L);
							}
						}
					}
					else
					{
						/* Als Applikation angemeldet ? */
						aptr=app_find(icon->spec.file->name);
						/* Nein */
						if(!aptr)
						{
							strcpy(app.name,icon->spec.file->name);
							app_default(&app);
							strcpy(app.title,icon->title);
							aptr=&app;
						}
						/* Alle selektierten Objekte als Kommandozeile Åbergeben */
						cont=sel2buf(glob.cmd,aname,apath,MAX_CMDLEN);
						/* Applikation starten */
						if(cont) fin=app_start(aptr,glob.cmd,apath,&rex);
						else
						{
							sprintf(almsg,rs_frstr[ALTOOMANY],aptr->title);
							frm_alert(1,almsg,altitle,conf.wdial,0L);
						}
						strcpy(glob.cmd,name);
					}
#endif
					break;
					case IDDRIVE:
					dname[0]=icon->spec.drive->drive+'A';
					dname[1]=':';dname[2]='\\';dname[3]=0;
					fin=dl_copy(dname,ks,0L);
					break;
					case IDTRASH:
					dl_delete(0L);
					break;
					case IDCLIP:
					if(gitem->class==EC_FILE)
						fin=clip_file(name);
					break;
					case IDFOLDER:
					fin=dl_copy(icon->spec.folder->path,ks,name);
					break;
				}
				if(fin && !rex)
					wgrp_esel(desk.sel.win,0L,0,0);
				break;
			}
		}
	}

	/* Update wieder sperren */
	wind_update(BEG_UPDATE);
}

/**-------------------------------------------------------------------------
 dl_wdrag()

 Drag&Drop auf ein Fenster bearbeiten
 -------------------------------------------------------------------------*/
void dl_wdrag_d(FORMINFO *fi, int obj, char *name, int ks) {
	int ok, i, j;
	char *p, *f;
	char fname[MAX_FLEN], *fpath, *full;

	fpath = pmalloc(MAX_PLEN * 2L);
	if (fpath == NULL) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		return;
	}
	full = fpath + MAX_PLEN;

	ok = 0;
	/* Falls Dialog iconified, dann abweisen */
	if (fi->state == FST_WIN && (fi->win.state & WSICON))
		obj = -1;
	if (!get_buf_entry(name, full, 0L))
		obj = -1;

	if (obj != -1) {
		/* Funktionstasten */
		if (fi == &fi_cfunc) {
			p = rs_trindex[CFUNC][obj].ob_spec.tedinfo->te_ptext;
			if (rs_trindex[CFUNC][CFSTOOL].ob_state & SELECTED) {
				full2comp(full, fpath, fname);
				if (!strchr(p, '|')) {
					strcpy(p, fname);
					strcat(p, "|");
					p = &p[(int) strlen(p)];
				} else {
					i = 0;
					while (p[i] != '|' && p[i])
						i++;
					if (i > 58)
						i--;
					p = &p[i + 1];
				}
			}
			i = j = 0;
			if (obj == fi_cfunc.edit_obj)
				obj_edit(fi_cfunc.tree, fi_cfunc.edit_obj, 0, 0, &fi_cfunc.edit_idx, ED_END, fi_cfunc.win.handle);
			if ((ks & K_CTRL) || (ks & K_ALT)) {
				while (p[i])
					i++;
				if (i > 0 && i < 60) {
					p[i++] = ' ';
					p[i] = 0;
				}
			}
			if ((i + strlen(name)) < 60) {
				strcat(&p[i], name);
				if (obj == fi_cfunc.edit_obj) {
					fi_cfunc.edit_idx = -1;
					obj_edit(fi_cfunc.tree, fi_cfunc.edit_obj, 0, 0, &fi_cfunc.edit_idx, ED_INIT, fi_cfunc.win.handle);
				}
				frm_redraw(&fi_cfunc, obj);
				ok = 1;
			}
		}
		/* Dateimaske */
		if (fi == &fi_mask) {
			p = rs_trindex[MASK][MAMASK].ob_spec.tedinfo->te_ptext;
			i = j = 0;
			f = strrchr(name, '\\');
			if (f) {
				if (f[1]) {
					f = strrchr(f, '.');
					if (!f)
						f = "";
					obj_edit(fi_mask.tree, fi_mask.edit_obj, 0, 0, &fi_mask.edit_idx, ED_END, fi_mask.win.handle);
					if ((ks & K_CTRL) || (ks & K_ALT)) {
						while (p[i])
							i++;
						if (i > 0 && i < MAX_FLEN) {
							p[i] = ',';
							p[i + 1] = 0;
							i++;
						}
					}
					if (i < MAX_FLEN) {
						p[i] = '*';
						p[i + 1] = 0;
						i++;
					}
					while (i < MAX_FLEN && f[j]) {
						p[i] = f[j];
						i++;
						j++;
					}
					p[i] = 0;
					fi_mask.edit_idx = -1;
					obj_edit(fi_mask.tree, fi_mask.edit_obj, 0, 0, &fi_mask.edit_idx, ED_INIT, fi_mask.win.handle);
					frm_redraw(&fi_mask, MAMASK);
					fi_mask.exit_obj = MAMASK;
					fi_mask.exit(0, 0);
					ok = 1;
				}
			}
		}
		/* Applikation */
		if (fi == &fi_dappinfo) {
			p = rs_trindex[DAPPINFO][obj].ob_spec.tedinfo->te_ptext;
			i = j = 0;
			if (obj == DAIPARAM || obj == DAEVAL)
				f = name;
			else {
				f = strrchr(name, '\\');
				f = &f[1];
				if (!f[0])
					f = 0L;
			}

			if (f) {
				if (obj == fi_dappinfo.edit_obj)
					obj_edit(fi_dappinfo.tree, fi_dappinfo.edit_obj, 0, 0, &fi_dappinfo.edit_idx, ED_END, fi_dappinfo.win.handle);
				if ((ks & K_CTRL) || (ks & K_ALT)) {
					while (p[i])
						i++;
					if (i > 0 && i < 60) {
						p[i] = ',';
						p[i + 1] = 0;
						i++;
					}
				}
				while (i < 60 && f[j]) {
					p[i] = nkc_tolower(f[j]);
					i++;
					j++;
				}
				p[i] = 0;
				if (obj == fi_dappinfo.edit_obj) {
					fi_dappinfo.edit_idx = -1;
					obj_edit(fi_dappinfo.tree, fi_dappinfo.edit_obj, 0, 0, &fi_dappinfo.edit_idx, ED_INIT, fi_dappinfo.win.handle);
				}
				frm_redraw(&fi_dappinfo, obj);
				ok = 1;
			}
		}
	}

	if (!ok)
		mybeep();
	pfree(fpath);
}

void dl_wdrag(WININFO *win, WP_ENTRY *item, WG_ENTRY *gitem, WG_ENTRY *gprev,
		int mx, int my, int ks) {
	int i, j, cont, fin, rex, ups, upd;
	char *full, *name, *iname;
	char *apath, aname[MAX_FLEN], title[MAX_FLEN], *p;
	APPLINFO *aptr;
#if 0
	APPLINFO app;
#endif
	W_PATH *wpath, *spath;
	WP_ENTRY *sitem;
	W_GRP *wgrp, *sgrp;
	WG_ENTRY *sgitem, *sgprev, *sgnext, *snitem;
	FORMINFO *fi;
	int obj;

	full = pmalloc(MAX_PLEN * 4L);
	if (full == NULL) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		return;
	}
	name = full + MAX_PLEN;
	iname = name + MAX_PLEN;
	apath = name + MAX_PLEN;

	fin = rex = 0; /* Flag fÅr's automatische Deselektieren */
	wind_update( END_UPDATE); /* Update freigeben */

	switch (win->class) {
		case WCDIAL: /* Dialogfenster */
		fi=(FORMINFO *)win->user;

		/* Auf bestimmte Dialoge und deren Eingabefelder begrenzen:
		 Funktionstasten - ein Objekt */
		obj=-1;
		if ((fi == &fi_cfunc || fi == &fi_mask || fi == &fi_dappinfo) && desk.sel.numobs == 1) {
			obj = objc_find(fi->tree, ROOT, MAX_DEPTH, mx, my);
			if (obj != -1) {
				if (!(fi->tree[obj].ob_flags & EDITABLE))
					obj = -1;
				if (fi == &fi_dappinfo && (obj == DAILABEL || obj == DAEVAL))
					obj = -1;
			}
		}
		break;
		case WCPATH: /* Verzeichnis */
		wpath=(W_PATH *)win->user;
		break;
		case WCGROUP: /* Gruppenfenster */
		fin=1;
		wgrp=(W_GRP *)win->user;
		break;
	}

	if (desk.sel.desk) /* Objekte auf dem Desktop  */
	{
		ICONDESK *q = desk.dicon + 1;

		switch (win->class) {
			case WCDIAL: /* Dialog */
			cont=sel2buf(name, aname, apath, MAX_PLEN);
			if (cont)
				dl_wdrag_d(fi, obj, name, ks);
			break;
			case WCPATH: /* Verzeichnisfenster */
			fin = dl_drag_on_ditem(wpath, item, ks, &rex);
			break;
			case WCGROUP: /* Gruppenfenster */
			fin = 1;
			if (!gitem) {
				cont=1;
				/* Alle selektierten Objekte in die Gruppe aufnehmen */
				for(i = 1; i <= MAXICON && cont; i++, q++) {
					if ((q->class != IDFREE) && q->select) {
						snitem = 0L;
						p = q->title;
						switch(q->class) {
							case IDDRIVE:
							name[0] = 'A' + q->spec.drive->drive;
							name[1] = ':';
							name[2] = '\\';
							name[3] = 0;
							sprintf(full, "%s (%c)", *p ? p : rs_frstr[TXFILESYS], *name);
							snitem = wgrp_add(wgrp, gprev, EC_FOLDER, full, name, "");
							break;
							case IDFILE:
							if (!p[0]) {
								p = strrchr(q->spec.file->name, '\\');
								if (!p)
									p = q->spec.file->name;
								else
									if (p[0] == '\\')
										p = &p[1];
							}
							snitem = wgrp_add(wgrp, gprev, EC_FILE, p, q->spec.file->name, "");
							break;
							case IDFOLDER:
							if (!p[0]) {
								p = q->spec.folder->path;
								j = (int)strlen(p) - 1;
								if (j > 0)
									j--;
								while (p[j] != '\\' && j > 0)
									j--;
								if (p[j] == '\\')
									j++;
								p = &p[j];
								j = 0;
								while (p[j] != '\\' && p[j]) {
									title[j] = p[j];
									j++;
								}
								title[j] = 0;
								p = title;
							}
							snitem = wgrp_add(wgrp, gprev, EC_FOLDER, p, q->spec.folder->path, "");
							break;
						}
						if (snitem)
							snitem->sel = 1;
						else
							cont = 0;
					}
					/* Falls es nicht geklappt hat, dann jammern */
					if (!cont) {
						fin = 0;
						frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
					}
				}
				/* Gruppe aktualisieren */
				wgrp_tree(win);
				win_redraw(win, tb.desk.x, tb.desk.y, tb.desk.w, tb.desk.h);
				win_slide(win, S_INIT, 0, 0);
				wgrp_change(win);
				if (snitem)
					wgrp->focus=snitem->obnum - 1;
			} else
				fin = dl_drag_on_gitem(wgrp, gitem, ks, &rex);
			break;
		}
		if (fin)
			icon_select(-1, 0, 0);
	}
	else /* Objekte in einem Fenster */
	{
		if(desk.sel.win) {
			switch(desk.sel.win->class) {
				case WCPATH:
				spath=(W_PATH *)desk.sel.win->user;
				switch(win->class) {
					case WCDIAL: /* Dialog */
					cont=sel2buf(name,aname,apath,MAX_PLEN);
					if(cont) dl_wdrag_d(fi,obj,name,ks);
					break;
					case WCPATH: /* Verzeichnisfenster */
					fin = dl_drag_on_ditem(wpath, item, ks, &rex);
					break;
					case WCGROUP: /* Gruppenfenster */
					fin=1;
					if(!gitem) {
						cont=1;
						/* Alle selektierten Objekte in die Gruppe aufnehmen */
						for(j=0;j<spath->e_total && cont;j++) {
							sitem=spath->lptr[j];
							strcpy(name,spath->path);
							if(sitem->sel) {
								snitem=0L;
								strcat(name,sitem->name);
								strcpy(title,sitem->name);
								if(sitem->class==EC_FILE) {
									/* Falls vorhanden, dann Applikationstitel verwenden */
									aptr=app_find(name);
									if(aptr)
										strcpy(title,aptr->title);

									snitem=wgrp_add(wgrp,gprev,EC_FILE,title,name,"");
								} else {
									strcat(name,"\\");
									snitem=wgrp_add(wgrp,gprev,EC_FOLDER,title,name,"");
								}
								if (snitem)
									snitem->sel=1;
								else
									cont=0;
							}
							/* Falls es nicht geklappt hat, dann jammern */
							if(!cont) {
								fin=0;
								frm_alert(1,rs_frstr[ALNOMEM],altitle,conf.wdial,0L);
							}
						}
						/* Gruppe aktualisieren */
						if(snitem)
							snitem->sel=1;
						wgrp_tree(win);
						win_redraw(win,tb.desk.x,tb.desk.y,tb.desk.w,tb.desk.h);
						win_slide(win,S_INIT,0,0);
						wgrp_change(win);
						if(snitem)
							wgrp->focus=snitem->obnum-1;
					} else {
						fin = dl_drag_on_gitem(wgrp, gitem, ks, &rex);
					}
					break;
				}
				if(fin && !rex) {
					spath->amask[0]=0;
					wpath_esel(desk.sel.win,0L,0,0,1);
				}
				break;
				case WCGROUP:
				sgrp=(W_GRP *)desk.sel.win->user;
				sgitem=sgrp->entry;
				while(!sgitem->sel)
					sgitem=sgitem->next;
				wgrp_eabs(sgrp,sgitem,name);

				switch(win->class) {
					case WCDIAL: /* Dialog */
					dl_wdrag_d(fi,obj,name,ks);
					break;
					case WCPATH: /* Verzeichnisfenster */
					if(!item) {
						fin=dl_copy(wpath->path,ks,0L);
					} else {
						switch(item->class) {
							case EC_FOLDER:
							case EC_PARENT:
							strcpy(iname,wpath->path);
							if(item->class==EC_PARENT) {
								i=(int)strlen(iname)-2;
								while(iname[i]!='\\')
									i--;
								iname[i+1]=0;
							} else {
								strcat(iname,item->name);
								strcat(iname,"\\");
							}
							fin=dl_copy(iname,ks,0L);
							break;
							case EC_FILE:
							strcpy(iname,wpath->path);strcat(iname,item->name);
#if 1
							fin = dl_runapp(iname, item->aptype, item->name, &rex);
#else
							/* Indirektes Ziel? */
							if(!item->aptype)
							{
								aptr=app_isdrag(iname);
								if(aptr)
								{
									/* Zieldatei zusammen mit Objekten Åbergeben */
									strcpy(glob.cmd,iname);strcat(glob.cmd," ");
									i=(int)strlen(glob.cmd);
#ifdef ARNO_ORIGINAL
									cont=sel2buf(&glob.cmd[i],aname,apath,MAX_CLEN-i);
#else
									cont=sel2buf(&glob.cmd[i],aname,apath,MAX_CMDLEN-i);
#endif
									if(cont) fin=app_start(aptr,glob.cmd,apath,&rex);
									else
									{
										sprintf(almsg,rs_frstr[ALTOOMANY],aptr->title);
										frm_alert(1,almsg,altitle,conf.wdial,0L);
									}
								}
							}
							else
							{
								/* Als Applikation angemeldet ? */
								aptr=app_find(iname);
								/* Nein */
								if(!aptr)
								{
									strcpy(app.name,iname);
									app_default(&app);
									strcpy(app.title,item->name);
									aptr=&app;
								}
								cont=sel2buf(glob.cmd,aname,apath,MAX_CMDLEN);
								if(cont) fin=app_start(aptr,glob.cmd,apath,&rex);
								else
								{
									sprintf(almsg,rs_frstr[ALTOOMANY],aptr->title);
									frm_alert(1,almsg,altitle,conf.wdial,0L);
								}
							}
#endif
							break;
						}
					}
					if(fin && !rex)
						wgrp_esel(desk.sel.win,0L,0,0);
					break;
					case WCGROUP: /* Gruppenfenster */
					if(!gitem) {
						ups=upd=0;

						/* Aktuellen Status sichern */
						sgitem=sgrp->entry;
						while(sgitem) {
							sgitem->prevsel=sgitem->sel;
							sgitem=sgitem->next;
						}

						/* Alle selektierten Objekte bearbeiten */
						sgitem=sgrp->entry;
						while(sgitem) {
							sgitem=sgrp->entry;
							while(sgitem) {
								if(!sgitem->prevsel)
									sgitem=sgitem->next;
								else break;
							}
							if(sgitem) {
								/* Vermerken, daû Objekt nicht mehr bearbeitet werden muû */
								sgitem->prevsel=0;

								/* Umsortierung innerhalb einer Gruppe */
								if(wgrp==sgrp) {
									/* Spezielle FÑlle berÅcksichtigen */
									if(gprev) {
										if(gprev->obnum>sgitem->obnum)
											gprev=gprev->next;
									}

									/* Nur umsortieren, falls Position sich wirklich Ñndert */
									if(wgrp->e_num>1 && gprev!=sgitem) {
										/* Eintrag aus der Liste ausklinken */
										sgprev=sgitem->prev;
										sgnext=sgitem->next;
										if(sgprev)
											sgprev->next=sgnext;
										else
											wgrp->entry=sgnext;
										if(sgnext)
											sgnext->prev=sgprev;

										/* Kein Eintrag angegeben, dann an das Ende der Liste
										 anhÑngen */
										if(!gprev) {
											sgnext=wgrp->entry;
											while(sgnext->next)
												sgnext=sgnext->next;
											sgnext->next=sgitem;
											sgitem->prev=sgnext;
										} else {
											/* Eintrag angegeben - davor einhÑngen */
											sgprev=gprev->prev;
											gprev->prev=sgitem;
											if(sgprev) sgprev->next=sgitem;
											else wgrp->entry=sgitem;
											sgitem->prev=sgprev;
										}
										sgitem->next=gprev;

										upd=1;
										wgrp->focus=sgitem->obnum-1;
									}
								}
								else /* Verlagern von einer Gruppe in die Andere */
								{
									wgrp_eabs(sgrp,sgitem,name);
									sgnext=wgrp_add(wgrp,gprev,sgitem->class,sgitem->title,name,"");
									if(!sgnext) {
										frm_alert(1,rs_frstr[ALNOMEM],altitle,conf.wdial,0L);
									} else {
										sgnext->sel=1;
										upd=1;
										wgrp->focus=sgnext->obnum-1;

										/* Falls gewÅnscht, dann Quellobjekt entfernen */
										if(ks&K_CTRL) {
											wgrp_remove(sgrp,sgitem);
											if(!sgrp->e_num) {
												if(glob.fwin==desk.sel.win) {
													glob.fmode=0;
													glob.fwin=0L;
												}
											} else {
												if(sgrp->focus>=sgrp->e_num)
													sgrp->focus--;
											}
										}
										else /* Andernfalls nur deselektieren */
										sgitem->sel=0;
										ups=1;
									}
								}
							}
						}
						/* Gruppen aktualisieren */
						if(ups) {
							wgrp_tree(desk.sel.win);
							win_redraw(desk.sel.win,tb.desk.x,tb.desk.y,tb.desk.w,tb.desk.h);
							win_slide(desk.sel.win,S_INIT,0,0);
							wgrp_change(desk.sel.win);
							wgrp->focus=0;
						}
						if(upd) {
							wgrp_tree(win);
							win_redraw(win,tb.desk.x,tb.desk.y,tb.desk.w,tb.desk.h);
							win_slide(win,S_INIT,0,0);
							wgrp_change(win);
						}
					} else {
						fin = dl_drag_on_gitem(wgrp, gitem, ks, &rex);
						if(fin && !rex)
							wgrp_esel(desk.sel.win,0L,0,0);
					}
					break;
				}
				break;
			}
		}
	}
	pfree(full);

	/* Update wieder sperren */
	wind_update(BEG_UPDATE);
}

/*-------------------------------------------------------------------------
 dl_awdrag()

 Drag&Drop auf ein Accessory-Fenster bearbeiten
 -------------------------------------------------------------------------*/
void dl_awdrag(ACWIN *accwin, int whandle, int mx, int my, int ks) {
	int dodrag, owner, ok;
	char *name, *path;
	/* ErgÑnzungen fÅr MT-D&D */
	int dfh, dret;
	char dext[32];
	long dsize;
	unsigned long dtype;
	void *dsig;

	name = pmalloc(MAX_PLEN * 2L);
	if (name == NULL) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		return;
	}
	path = name + MAX_PLEN;

	wind_update( END_UPDATE); /* Update freigeben */

	/* Objekte an Accessory melden */
	dodrag = sel2buf(aesbuf, name, path, MAX_AVLEN);
	if (dodrag) {
		/* Fenster Åber AV-Protokoll angemeldet? */
		if (accwin) {
			if (avp_check(accwin->id)) {
				if (!has_quotes(aesbuf) || avp_can_quote(accwin->id)) {
					app_send(accwin->id, VA_DRAGACCWIND, PT67, accwin->handle,
							mx, my, (long) aesbuf, 0);
				} else {
					sprintf(almsg, rs_frstr[ALNOQUOTE],
							avp_get(accwin->id)->name);
					frm_alert(1, almsg, altitle, conf.wdial, 0L);
				}
			}
		} else /* Fenster nicht angemeldet */
		{
			if (whandle) {
				/* EigentÅmer ermitteln */
				owner = -1;
				if (tb.sys & SY_OWNER)
					if (!wind_get(whandle, WF_OWNER, &owner))
						owner = -1;
				if (owner != -1 && owner != tb.app_id) {
					/* MultiTOS D&D probieren */
					ok = 1;
					if (tb.sys & SY_MULTI) {
						/* D&D-Pipe erzeugen */
						dfh = ddcreate(tb.app_id, owner, whandle, mx, my, ks, dext, &dsig);
						if (dfh >= 0) {
							/* PrÅfen, ob der EmpfÑnger 'ARGS' unterstÅtzt */
							dtype = 'ARGS';
							dsize = (long) strlen(aesbuf);
							dret = ddstry(dfh, dtype, "ARGS.TXT", dsize);
							if (dret == DD_OK) {
								/* Alles klar - dann senden */
								Fwrite(dfh, dsize, aesbuf);
							}
							ddclose(dfh, dsig);
						} else
							ok = 0;
					}

					/* D&D ging nicht, dann VA_START probieren */
					if (!ok)
						app_send(owner, VA_START, PT34, (long) aesbuf, 0, 0, 0, 0);
				} else
					frm_alert(1, rs_frstr[ALAVEDRAG], altitle, conf.wdial, 0L);
			}
		}
	} else /* Fehler - zuviele Objekte ... */
	{
		frm_alert(1, rs_frstr[ALEACDRAG], altitle, conf.wdial, 0L);
	}
	pfree(name);

	/* Update wieder sperren */
	wind_update( BEG_UPDATE);
}

/**-------------------------------------------------------------------------
 dl_ddriveinfo()

 Info ueber Laufwerk anzeigen/aendern
 -------------------------------------------------------------------------*/
int dl_ddriveinfo(ICONDESK *icon, int donext) {
	int cont, done, fret;
	char dtitle[80], drv[4];
#if 0
	DTA *odta, dta;
#endif
	char vname[MAX_FLEN], *nvname;
	char *vmask;
	char *dspec;
	long fcret;
	DISKINFO dinfo;
	double bar;
	FILESYS fsys;
#if 0
	long err;
#endif
	OBJECT *tree;
#if 0
	int oedit;
#endif
	char u1[4] = "\0kB", u2[5] = " kB)", units[] = " kMGT";
	double _free, used, total, clsizb;
	int i;

	tree = rs_trindex[DIINFO];

#ifdef DIRCH
	dspec = strdup(getObjectText(tree, DITITLE));
	if (dspec == NULL) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		return(1); /* uebersprungen */
	}
#endif

	nvname = tree[DINAME].ob_spec.tedinfo->te_ptext;

	graf_mouse(BUSYBEE, 0L);

	drv[0] = icon->spec.drive->drive + 'A';
	drv[1] = ':';
	drv[2] = drv[3] = 0;
	if (chk_drive(icon->spec.drive->drive) != -1)
		fret = Dfree(&dinfo, icon->spec.drive->drive + 1);
	else
		fret = 1;

	if (fret != 0) {
		/* Bei Fehler mosern und Nullwerte setzen */
		if (fret < 0)
			err_file(rs_frstr[ALNODRIVE], (long) fret, drv);
		_free = used = total = 0.0;

		/* Eingabe des Volume Label nicht mîglich */
		tree[DINAME].ob_state |= DISABLED;
		tree[DINAME].ob_flags &= ~EDITABLE;
		nvname[0] = 0;
	} else {
		/* Infos ueber das Laufwerk ermitteln */
		drv[2] = '\\';
		fsinfo(drv, &fsys);
		drv[2] = 0;
		clsizb = (double) dinfo.b_secsiz * (double) dinfo.b_clsiz;
		_free = (double) dinfo.b_free * clsizb;
		total = (double) dinfo.b_total * clsizb;
		used = total - _free;

		*nvname = 0;
		if (get_label(icon->spec.drive->drive, nvname, MAX_FLEN))
			*nvname = 0;

		tree[DINAME].ob_state &= ~DISABLED;
		tree[DINAME].ob_flags |= EDITABLE;

		/* Eingabemoeglichkeiten beim Volume Label an Filesystem anpassen */
		vmask = tree[DINAME].ob_spec.tedinfo->te_pvalid;
		if (fsys.flags & (TOS | UPCASE)) {
			for (; *vmask; vmask++)
				*vmask = 'x';
		} else {
			for (; *vmask; vmask++)
				*vmask = 'X';
		}
	}

	strcpy(vname, nvname);

	/* Daten in den Dialog eintragen */
	for (i = 0; (total > 999999999.0) && units[i + 1]; i++) {
		total /= 1024.0;
		_free /= 1024.0;
		used /= 1024.0;
	}
	if (i) {
		*u1 = ' ';
		u1[1] = units[i];
		u2[1] = units[i + 1];
	}
	prlong((unsigned long) used, tree[DIUSED].ob_spec.tedinfo->te_ptext);
	prlong((unsigned long) _free, tree[DIFREE].ob_spec.tedinfo->te_ptext);
	prlong((unsigned long) total, tree[DISIZE].ob_spec.tedinfo->te_ptext);
	if (*u1) {
		strcat(tree[DIUSED].ob_spec.tedinfo->te_ptext, u1);
		strcat(tree[DIFREE].ob_spec.tedinfo->te_ptext, u1);
		strcat(tree[DISIZE].ob_spec.tedinfo->te_ptext, u1);
	}
	prlong((unsigned long) (used / 1024.0 + 0.5), tree[DIUSEDKB].ob_spec.tedinfo->te_ptext + 1);
	prlong((unsigned long) (_free / 1024.0 + 0.5), tree[DIFREEKB].ob_spec.tedinfo->te_ptext + 1);
	prlong((unsigned long) (total / 1024.0 + 0.5), tree[DISIZEKB].ob_spec.tedinfo->te_ptext + 1);
	strcat(tree[DIUSEDKB].ob_spec.tedinfo->te_ptext, u2);
	strcat(tree[DIFREEKB].ob_spec.tedinfo->te_ptext, u2);
	strcat(tree[DISIZEKB].ob_spec.tedinfo->te_ptext, u2);
	if (total > 0.0) {
		bar = (double) tree[DIBTOTAL].ob_width - ((double) tree[DIBTOTAL].ob_width * (_free / total) + 0.5);
	} else
		bar = 0;
	if (bar < 1)
		bar = 1;
	tree[DIBUSED].ob_width = (int) bar;
	if (total > 0.0)
		bar =+ (used / total) * 100 + 0.5;
	else
		bar = 0;
	sprintf(tree[DIBVALUE].ob_spec.free_string, "%d%%", (int) bar);
#ifdef DIRCH
	setObjectState(tree, DIAUTOINSTALL, SELECTED, icon->spec.drive->autoinstall);
	setObjectState(tree, DIUSELABEL, SELECTED, icon->spec.drive->uselabel);
#else
	dial_setopt(tree, DIAUTOINSTALL, SELECTED, icon->spec.drive->autoinstall);
	dial_setopt(tree, DIUSELABEL, SELECTED, icon->spec.drive->uselabel);
#endif

	graf_mouse(ARROW, 0L);
	/* Sonstige Vorbereitungen */
#ifdef DIRCH
	setObjectState(tree, DINEXT, DISABLED, !donext);
	setObjectText(tree, DILABEL, icon->spec.drive->deftitle);

	sprintf(dtitle, dspec, drv);
	setObjectText(tree, DITITLE, dtitle);
#else
	dial_setopt(tree, DINEXT, DISABLED, !donext);
	strcpy(tree[DILABEL].ob_spec.tedinfo->te_ptext, icon->spec.drive->deftitle);

	dspec = tree[DITITLE].ob_spec.free_string;
	sprintf(dtitle, dspec, drv);
	tree[DITITLE].ob_spec.free_string = dtitle;
#endif

	/* Auf gehts ... */
	frm_start(&fi_diinfo, conf.wdial, conf.cdial, 1);
	done = 0;
	while (!done) {
		frm_dial(&fi_diinfo, &mevent);
		switch (fi_diinfo.exit_obj) {
		case DIHELP:
			show_help(fi_diinfo.userinfo);
			frm_norm(&fi_diinfo);
			break;
		case DICANCEL:
			cont = 0; /* Rueckgabe: Abbruch */
			done = 1;
			break;
		case DIOK:
			cont = 2; /* Rueckgabe: Icon geaendert */
			done = 1;
			break;
		case DINEXT:
			cont = 1; /* Rueckgabe: Icon uebersprungen */
			done = 1;
			break;
		}
	}
	frm_end(&fi_diinfo);
#ifdef DIRCH
	setObjectText(tree, DITITLE, dspec);
	free(dspec);
#else
	tree[DITITLE].ob_spec.free_string = dspec;
#endif

	if (fi_diinfo.exit_obj == DIOK) {
		strcpy(icon->spec.drive->deftitle, rs_trindex[DIINFO][DILABEL].ob_spec.tedinfo->te_ptext);
		strcpy(icon->title, icon->spec.drive->deftitle);

#ifdef DIRCH
		icon->spec.drive->uselabel = isObjectSelected(tree, DIUSELABEL);
		icon->spec.drive->autoinstall = isObjectSelected(tree, DIAUTOINSTALL);
#else
		icon->spec.drive->uselabel = dial_getopt(tree, DIUSELABEL, SELECTED);
		icon->spec.drive->autoinstall = dial_getopt(tree, DIAUTOINSTALL, SELECTED);
#endif
		/* Bei Bedarf Volume Label aendern */
		if (strcmp(vname, nvname) != 0) {
			sprintf(dtitle, "%c:\\", icon->spec.drive->drive + 'A');
			if (Dwritelabel(dtitle, nvname)) {
				/* Altes Label entfernen */
				if (vname[0]) {
					strcpy(&dtitle[3], vname);
					Fdelete(dtitle);
				}
				/* Neues Label erzeugen */
				if (nvname[0]) {
					strcpy(&dtitle[3], nvname);
					fcret = Fcreate(dtitle, FA_VOLUME);
					if (fcret >= 0L)
						Fclose((int) fcret);
					else {
						dtitle[2] = 0;
						sprintf(almsg, rs_frstr[ALDNAME], dtitle);
						frm_alert(1, almsg, altitle, conf.wdial, 0L);
					}
				}
			}
		}
		title_update(icon->spec.drive->drive);
	}

	return cont;
}

/**-------------------------------------------------------------------------
 dl_dtrashinfo()

 Info ueber Papierkorb anzeigen/aendern
 -------------------------------------------------------------------------*/
int dl_dtrashinfo(ICONDESK *icon, int donext) {
	int cont, done;
	OBJECT *tree;

	tree = rs_trindex[TRASHINFO];

	/* Dialog vorbereiten */
#ifdef DIRCH
	setObjectState(tree, TINEXT, DISABLED, !donext);
	setObjectText(tree, TILABEL, icon->title);
#else
	dial_setopt(tree, TINEXT, DISABLED, !donext);
	strcpy(tree[TILABEL].ob_spec.tedinfo->te_ptext, icon->title);
#endif
	/* Auf gehts ... */
	frm_start(&fi_trashinfo, conf.wdial, conf.cdial, 1);
	done = 0;
	while (!done) {
		frm_dial(&fi_trashinfo, &mevent);
		switch (fi_trashinfo.exit_obj) {
		case TIHELP:
			show_help(fi_trashinfo.userinfo);
			frm_norm(&fi_trashinfo);
			break;
		case TICANCEL:
			cont = 0; /* Rueckgabe: Abbruch */
			done = 1;
			break;
		case TIOK:
			cont = 2; /* Rueckgabe: Icon geaendert */
			done = 1;
			break;
		case TINEXT:
			cont = 1; /* Rueckgabe: Icon uebersprungen */
			done = 1;
			break;
		}
	}
	frm_end(&fi_trashinfo);

	if (fi_trashinfo.exit_obj == TIOK) {
#ifdef DIRCH
		strcpy(icon->title, getObjectText(tree, TILABEL));
#else
		strcpy(icon->title, tree[TILABEL].ob_spec.tedinfo->te_ptext);
#endif
	}

	return cont;
}

/**-------------------------------------------------------------------------
 dl_dclipinfo()

 Info ueber Ablage anzeigen/aendern
 -------------------------------------------------------------------------*/
int dl_dclipinfo(ICONDESK *icon, int donext) {
	int cont, done, ret, /*fret,*/ ok;
	char path[MAX_PLEN], /*name[MAX_FLEN],*/ *p;
	FILESYS filesys;
	int i;
	long l;
	W_PATH *wpath;
	OBJECT *tree;

	tree = rs_trindex[CLIPINFO];

	/* Dialog vorbereiten */
#ifdef DIRCH
	setObjectState(tree, CINEXT, DISABLED, !donext);
	setObjectText(tree, CILABEL, icon->title);
	setObjectText(tree, CIPATH, icon->spec.clip->path);
#else
	dial_setopt(tree, CINEXT, DISABLED, !donext);
	strcpy(tree[CILABEL].ob_spec.tedinfo->te_ptext, icon->title);
	strcpy(tree[CIPATH].ob_spec.tedinfo->te_ptext, icon->spec.clip->path);
#endif

	/* Auf gehts ... */
	frm_start(&fi_clipinfo, conf.wdial, conf.cdial, 1);
	done = 0;
	while (!done) {
		ret = frm_dial(&fi_clipinfo, &mevent);
		switch (fi_clipinfo.exit_obj) {
		case CIHELP:
			show_help(fi_clipinfo.userinfo);
			frm_norm(&fi_clipinfo);
			break;

		case CIPATH: /* Pfad suchen */
			if (!(ret & 0x8000))
				break;
#ifdef DIRCH
			strcpy(path, getObjectText(tree, CIPATH));
#else
			strcpy(path, tree[CIPATH].ob_spec.tedinfo->te_ptext);
#endif
			if (path[0]) {
				if (path[(int) strlen(path) - 1] != '\\')
					strcat(path, "\\");
			}
#if 0
			else
			{
				path[0]=(char)Dgetdrv()+65;
				path[1]=':';
				Dgetpath(&path[2],0);
				strcat(path,"\\");
			}
			strcat(path,"SCRAP.*");
			name[0]=0;
			/* Dateiauswahl durchfÅhren */
			fselect(path,name,&fret,rs_frstr[TXCLIPSEARCH],0,100);
			if(fi_clipinfo.state!=FST_WIN) frm_redraw(&fi_clipinfo,ROOT);
			if(fret==1) /* Dateiauswahl mit "OK" beendet */
			{
				/* Laufwerksbezeichnung immer gross */
				path[0]=nkc_toupper(path[0]);
				/* Bei Bedarf Schreibweise anpassen */
				fsinfo(path,&filesys);
				fsconv(path,&filesys);
				p=strrchr(path,'\\');if(p) p[1]=0;
				frm_edstring(&fi_clipinfo,CIPATH,path);
				frm_redraw(&fi_clipinfo,CIPATH);
			}
#else
			if (full_fselect(path, NULL, "SCRAP.*", 1, rs_frstr[TXCLIPSEARCH], 0, 100, &fi_clipinfo)) {
				p = strrchr(path, '\\');
				if (p)
					p[1] = 0;
				frm_edstring(&fi_clipinfo, CIPATH, path);
				frm_redraw(&fi_clipinfo, CIPATH);
			}
#endif
			break;

		case CICANCEL:
			cont = 0; /* Rueckgabe: Abbruch */
			done = 1;
			break;

		case CIOK:
			ok = 1;

#ifdef DIRCH
			strcpy(path, getObjectText(tree, CIPATH));
#else
			strcpy(path, tree[CIPATH].ob_spec.tedinfo->te_ptext);
#endif
			/* Laufwerksbezeichnung immer gross */
			path[0] = nkc_toupper(path[0]);

			/* Bei Bedarf Schreibweise anpassen */
			fsinfo(path, &filesys);
			fsconv(path, &filesys);
			frm_edstring(&fi_clipinfo, CIPATH, path);
			frm_redraw(&fi_clipinfo, CIPATH);

			/* Pfadangabe pruefen */
			p = path;
			if (ok)
				if (p[0]) {
					if (p[(int) strlen(p) - 1] != '\\')
						strcat(p, "\\");
					frm_edstring(&fi_clipinfo, CIPATH, path);
					frm_redraw(&fi_clipinfo, CIPATH);
				}
			if (ok)
				if (!valid_path(p)) {
					frm_alert(1, rs_frstr[ALILLPATH], altitle, conf.wdial, 0L);
					ok = 0;
				}
			if (ok) {
				cont = 2; /* Rueckgabe: Icon geaendert */
				done = 1;
			} else
				frm_norm(&fi_clipinfo);
			break;
		case CINEXT:
			cont = 1; /* Rueckgabe: Icon uebersprungen */
			done = 1;
			break;
		}
	}
	frm_end(&fi_clipinfo);

	if (fi_clipinfo.exit_obj == CIOK) {
#ifdef DIRCH
		strcpy(path, getObjectText(tree, CIPATH));
		strcpy(icon->title, getObjectText(tree, CILABEL));
#else
		strcpy(path, tree[CIPATH].ob_spec.tedinfo->te_ptext);
		strcpy(icon->title, tree[CILABEL].ob_spec.tedinfo->te_ptext);
#endif
		strcpy(icon->spec.clip->path, path);
		/* Ablage initialisieren */
		clip_init();

		/* Eventuell betroffene Verzeichnisfenster aktualisieren */
		l = strlen(icon->spec.clip->path);
		for (i = 0; i < MAX_PWIN; i++) {
			if (glob.win[i].state & WSOPEN) {
				wpath = (W_PATH *) glob.win[i].user;
				if (wpath->rel && !strncmp(wpath->path, icon->spec.clip->path, l)) {
					strcpy(wpath->relname, icon->title);
					wpath_iupdate(&glob.win[i], 0);
				}
			}
		}
	}

	return cont;
}

/**-------------------------------------------------------------------------
 dl_dappinfo()

 Info ueber Applikation anzeigen/aendern
 -------------------------------------------------------------------------*/
void dl_dappinfo_mode(int mode) {
	OBJECT *tree;

	tree = rs_trindex[DAPPINFO];

	fi_dappinfo.keyflag = 0;

	tree[DAILABEL].ob_flags &= ~EDITABLE;
	tree[DAIPARAM].ob_flags &= ~EDITABLE;
	tree[DAIOPEN].ob_flags &= ~EDITABLE;
	tree[DAIVIEW].ob_flags &= ~EDITABLE;
	tree[DAIPRINT].ob_flags &= ~EDITABLE;

	tree[DAOMAXMEM].ob_flags &= ~EDITABLE;
	tree[DAOALERT].ob_flags &= ~EDITABLE;

	tree[DAEVAL].ob_flags &= ~EDITABLE;

	switch (mode) {
		case 0:
			tree[DASUB].ob_head = DASGENERAL;
			tree[DASUB].ob_tail = DASGENERAL;
			tree[DASGENERAL].ob_next = DASUB;
			tree[DAILABEL].ob_flags |= EDITABLE;
			tree[DAIPARAM].ob_flags |= EDITABLE;
			fi_dappinfo.edit_obj = DAILABEL;
			fi_dappinfo.userinfo = rs_frstr[HMAPP0];
			break;
		case 1:
			tree[DASUB].ob_head = DASFILES;
			tree[DASUB].ob_tail = DASFILES;
			tree[DASFILES].ob_next = DASUB;
			tree[DAIOPEN].ob_flags |= EDITABLE;
			tree[DAIVIEW].ob_flags |= EDITABLE;
			tree[DAIPRINT].ob_flags |= EDITABLE;
			fi_dappinfo.edit_obj = DAIOPEN;
			fi_dappinfo.userinfo = rs_frstr[HMAPP1];
			break;
		case 2:
			tree[DASUB].ob_head = DASOPTIONS;
			tree[DASUB].ob_tail = DASOPTIONS;
			tree[DASOPTIONS].ob_next = DASUB;
			tree[DAOMAXMEM].ob_flags |= EDITABLE;
			tree[DAOALERT].ob_flags |= EDITABLE;
			fi_dappinfo.edit_obj = DAOMAXMEM;
			fi_dappinfo.userinfo = rs_frstr[HMAPP2];
			break;
		case 3:
			tree[DASUB].ob_head = DASENV;
			tree[DASUB].ob_tail = DASENV;
			tree[DASENV].ob_next = DASUB;

			tree[DAEVAL].ob_flags |= EDITABLE;
			fi_dappinfo.keyflag = 1;

			fi_dappinfo.edit_obj = DAEVAL;
			fi_dappinfo.userinfo = rs_frstr[HMAPP3];
			break;
	}
}

/*-----------------------------------------------------------------------*/
void dl_dappinfo_opt(int isap, int isdeflt) {
	OBJECT *appinfo;

	appinfo = rs_trindex[DAPPINFO];
	if (!isap && !isdeflt) {
		/* Kein Programm */

		/* Keine Optionen */
		appinfo[DAOPTIONS].ob_state |= DISABLED;
		/* Kein Environment */
		appinfo[DAENV].ob_state |= DISABLED;
		/* Kein Drag&Drop auf angem. Dateien */
		appinfo[DAIINDRAG].ob_state |= DISABLED;
		/* Kein spezifisches Startverzeichnis */
		appinfo[DAIWINDOW].ob_state |= DISABLED;
		appinfo[DAIFILE].ob_state |= DISABLED;
		appinfo[DAIAPPL].ob_state |= DISABLED;
		/* Keine spezifischen Parameter */
		appinfo[DAIPARAM].ob_state |= DISABLED;
		appinfo[DAIPARAM].ob_flags &= ~EDITABLE;
		appinfo[DAIALWAYS].ob_state |= DISABLED;
		/* Kein Speicherlimit */
		appinfo[DAOMAXMEM].ob_state |= DISABLED;
		appinfo[DAOMAXMEM].ob_flags &= ~EDITABLE;
		/* Kein Warnhinweis */
		appinfo[DAOALERT].ob_state |= DISABLED;
		appinfo[DAOALERT].ob_flags &= ~EDITABLE;
		if (dapp->mode == 2)
			fi_dappinfo.edit_obj = 0;
	} else {
		appinfo[DAOPTIONS].ob_state &= ~DISABLED;
		appinfo[DAENV].ob_state &= ~DISABLED;
		appinfo[DAIINDRAG].ob_state &= ~DISABLED;
		appinfo[DAIWINDOW].ob_state &= ~DISABLED;
		appinfo[DAIFILE].ob_state &= ~DISABLED;
		appinfo[DAIAPPL].ob_state &= ~DISABLED;
		appinfo[DAIPARAM].ob_state &= ~DISABLED;
		if (dapp->mode == 0)
			appinfo[DAIPARAM].ob_flags |= EDITABLE;
		appinfo[DAIALWAYS].ob_state &= ~DISABLED;
		appinfo[DAOMAXMEM].ob_state &= ~DISABLED;
		appinfo[DAOALERT].ob_state &= ~DISABLED;
		if (dapp->mode == 2) {
			appinfo[DAOALERT].ob_flags |= EDITABLE;
			appinfo[DAOMAXMEM].ob_flags |= EDITABLE;
		}
	}
#if 1
	if (isdeflt) {
		/* Defaultapplikation? */

		/* Keine Programmdatei */
		appinfo[DAISEARCH].ob_state |= DISABLED;
		/* Titel nicht aenderbar */
		appinfo[DAILABEL].ob_flags &= ~EDITABLE;
		/* Kein Shortcut */
		appinfo[DAISHORT].ob_state |= DISABLED;
		/* Keine aktuelle Auswahl */
		appinfo[DAIUSESEL].ob_state |= DISABLED;
		/* Keine Parameter */
		appinfo[DAIPARAM].ob_state |= DISABLED;
		appinfo[DAIPARAM].ob_flags &= ~EDITABLE;
		appinfo[DAIALWAYS].ob_state |= DISABLED;
		/* Keine Dateien */
		appinfo[DAFILES].ob_state |= DISABLED;
		/* Kein Pfadvergleich */
		appinfo[DAOFULL].ob_state |= DISABLED;
		/* Kein Autostart */
		appinfo[DAOAUTO].ob_state |= DISABLED;
		/* Keine Parameterabfrage */
		appinfo[DAOASKPARM].ob_state |= DISABLED;
		/* Kein Auslagern */
		appinfo[DAOOVERLAY].ob_state |= DISABLED;
		/* Kein Warten auf Tastendruck */
		appinfo[DAOWAITKEY].ob_state |= DISABLED;
		/* Kein Speicherlimit */
		appinfo[DAOMAXMEM].ob_state |= DISABLED;
		appinfo[DAOMAXMEM].ob_flags &= ~EDITABLE;
		/* Kein Warnhinweis */
		appinfo[DAOALERT].ob_state |= DISABLED;
		appinfo[DAOALERT].ob_flags &= ~EDITABLE;
		if (dapp->mode == 2)
			fi_dappinfo.edit_obj = 0;
		/* Kein Environment */
		appinfo[DAENV].ob_state |= DISABLED;
	} else {
		appinfo[DAISEARCH].ob_state &= ~DISABLED;
		if (dapp->mode == 0)
			appinfo[DAILABEL].ob_flags |= EDITABLE;
		appinfo[DAISHORT].ob_state &= ~DISABLED;
		appinfo[DAIUSESEL].ob_state &= ~DISABLED;
		appinfo[DAFILES].ob_state &= ~DISABLED;
		appinfo[DAOFULL].ob_state &= ~DISABLED;
		appinfo[DAOAUTO].ob_state &= ~DISABLED;
		appinfo[DAOASKPARM].ob_state &= ~DISABLED;
		appinfo[DAOOVERLAY].ob_state &= ~DISABLED;
		appinfo[DAOWAITKEY].ob_state &= ~DISABLED;
		if (isap) {
			appinfo[DAIPARAM].ob_state &= ~DISABLED;
			if (dapp->mode == 0)
				appinfo[DAIPARAM].ob_flags |= EDITABLE;
			appinfo[DAIALWAYS].ob_state &= ~DISABLED;
			appinfo[DAENV].ob_state &= ~DISABLED;
		}
	}
#endif
}

/*-----------------------------------------------------------------------*/
int dl_dappinfo(APPLINFO *appl, int del) {
	int i, j, isap;
	int obnum[5] = { DAIPARAM, DAIOPEN, DAIVIEW, DAIPRINT, DAEVAL },
			oblen[5] = { 60, 60, 60, 60, 50 };
	APPLINFO *aptr;
	OBJECT *tree;

	tree = rs_trindex[DAPPINFO];

	if (fi_dappinfo.open) {
		mybeep();
		frm_restore(&fi_dappinfo);
		return 0;
	}

	dapp = pmalloc(sizeof(DAPP));
	if (!dapp) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		return 0;
	}

	for (i = 0; i < 5; i++) {
		tree[obnum[i]].ob_spec.tedinfo->te_ptext = dapp->ftxt[i];
		tree[obnum[i]].ob_spec.tedinfo->te_ptmplt = dapp->ftmp[i];
		tree[obnum[i]].ob_spec.tedinfo->te_pvalid = dapp->fval[i];
		tree[obnum[i]].ob_spec.tedinfo->te_txtlen = oblen[i] + 1;
		tree[obnum[i]].ob_spec.tedinfo->te_tmplen = oblen[i] + 1;
		for (j = 0; j < oblen[i]; j++) {
			dapp->ftxt[i][j] = 0;
			dapp->ftmp[i][j] = '_';
			dapp->fval[i][j] = 'X';
		}
		dapp->ftxt[i][j] = 0;
		dapp->ftmp[i][j] = 0;
		dapp->fval[i][j] = 0;
	}

	/* Buffer fuer Environment */
	dapp->ebuf = pmalloc((long) (MAX_EVAR * 51));
	if (!dapp->ebuf) {
		pfree( dapp);
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		return 0;
	}
	for (i = 0; i < MAX_EVAR; i++) {
		dapp->evar[i] = &dapp->ebuf[i * 51];
		if (appl->evar[i])
			strcpy(dapp->evar[i], appl->evar[i]);
		else
			dapp->evar[i][0] = 0;
	}
	li_dappinfo.text = dapp->evar;

	/* Dialog vorbereiten */
	dapp->appl = appl;
	dial_setopt(tree, DAIDELETE, DISABLED, (del == 0) || (del == 2) || (appl == &defappl));

	/* Merken, ob es eine Neu-Anmeldung ist, die bei 'Abbruch' wieder
	 geloescht wird */
	if (del == 2)
		dapp->new = 1;
	else
		dapp->new = 0;

	dapp->mode = 0;
	dl_dappinfo_mode(dapp->mode);
	for (i = 0; i < 4; i++)
		tree[DAGENERAL + i].ob_state &= ~SELECTED;
	tree[DAGENERAL].ob_state |= SELECTED;

	/* Dialog - Allgemein */
	pop_short.sel = appl->shortcut + 1;
	dial_setopt(tree, DAIUSESEL, SELECTED, appl->usesel);
	strcpy(tree[DAILABEL].ob_spec.tedinfo->te_ptext, appl->title);
	strcpy(dapp->apname, appl->name);
	strcpy(dapp->aparam, appl->parm);
	str245(tree[DAINAME].ob_spec.tedinfo->te_ptext, dapp->apname);
	strcpy(tree[DAIPARAM].ob_spec.tedinfo->te_ptext, dapp->aparam);
	dial_setopt(tree, DAIALWAYS, SELECTED, appl->paralways);
	dial_setopt(tree, DAIAPPL, SELECTED, appl->homepath == 1);
	dial_setopt(tree, DAIWINDOW, SELECTED, appl->homepath == 2);
	dial_setopt(tree, DAIFILE, SELECTED, appl->homepath == 0);

	/* Dialog - Dateien */
	strcpy(tree[DAIOPEN].ob_spec.tedinfo->te_ptext, appl->fileopen);
	strcpy(tree[DAIVIEW].ob_spec.tedinfo->te_ptext, appl->fileview);
	strcpy(tree[DAIPRINT].ob_spec.tedinfo->te_ptext, appl->fileprint);
	dial_setopt(tree, DAIINDRAG, SELECTED, appl->dodrag);

	/* Dialog - Optionen */
	dial_setopt(tree, DAOFULL, SELECTED, appl->fullcompare);
	dial_setopt(tree, DAOAUTO, SELECTED, appl->autostart);
	dial_setopt(tree, DAOASKPARM, SELECTED, appl->getpar);
	dial_setopt(tree, DAOUNIXPATHS, SELECTED, appl->unixpaths);
	dial_setopt(tree, DAOVAPROT, SELECTED, appl->vaproto);
	dial_setopt(tree, DAOOVERLAY, SELECTED, appl->overlay);
	dial_setopt(tree, DAOSINGLE, SELECTED, appl->single);
	dial_setopt(tree, DAOCONWIN, SELECTED, appl->conwin);
	dial_setopt(tree, DAOWAITKEY, SELECTED, appl->toswait);
	if (appl->memlimit)
		ltoa(appl->memlimit, tree[DAOMAXMEM].ob_spec.tedinfo->te_ptext, 10);
	else
		*tree[DAOMAXMEM].ob_spec.tedinfo->te_ptext = 0;
	strcpy(tree[DAOALERT].ob_spec.tedinfo->te_ptext, appl->alert);

	/* Dialog - Environment */
	li_dappinfo.sel = 0;
	li_dappinfo.offset = 0;
	i = 0;
	while (dapp->evar[i][0] && i < MAX_EVAR - 1)
		i++;
	li_dappinfo.num = i + 1;
	lst_init(&li_dappinfo, 1, 1, 0, 0);
	strcpy(tree[DAEVAL].ob_spec.tedinfo->te_ptext, dapp->evar[li_dappinfo.sel]);

	dial_setopt(tree, DAEUSE, SELECTED, appl->euse);

	/* Im Popup-Menue alle nicht verfuegbaren Shortcuts abschalten */
	for (i = 2; i < 11; i++) {
		rs_trindex[POPSHORT][i].ob_state &= ~DISABLED;
		rs_trindex[POPSHORT][i].ob_flags |= SELECTABLE;
	}
	aptr = desk.appl;
	while (aptr) {
		if (aptr != appl) {
			if (aptr->shortcut) {
				rs_trindex[POPSHORT][aptr->shortcut + 1].ob_state |= DISABLED;
				rs_trindex[POPSHORT][aptr->shortcut + 1].ob_flags &= ~SELECTABLE;
			}
		}
		aptr = aptr->next;
	}

	/* Waehlbare Optionen - abhaengig von Datei/Programm */
	isap = is_appl(appl->name);
	dl_dappinfo_opt(isap, appl == &defappl);

	frm_start(&fi_dappinfo, conf.wdial, conf.cdial, 0);
	return 1;
}

/**-------------------------------------------------------------------------
 de_dappinfo()
 
 Dialog-Exit 'Info Åber Applikation'
 -------------------------------------------------------------------------*/
void de_dappinfo(int mode, int ret) {
	int done, cont, i, /*fret,*/ iret, ok, mode1, isap;
	int exit_obj;
	char *path, name[MAX_FLEN]; /*, *p;*/
	APPLINFO *appl, *aptr;
	char *aname;
	FILESYS filesys;
#ifdef OLD_SLIDER_HANDLING
	int mx,my,mb,ks,sx,sy,sd,sel,csel;
#else
	int sel, d;
#endif
	OBJECT *tree;

	path = pmalloc(MAX_PLEN * 2L);
	if (path == NULL) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		return;
	}
	aname = path + MAX_PLEN;

	tree = rs_trindex[DAPPINFO];

	done = cont = 0;
	appl = dapp->appl;

	if (!mode) {
		exit_obj = fi_dappinfo.exit_obj;
		sel = li_dappinfo.sel;
		mode1 = dapp->mode;
#ifdef OLD_SLIDER_HANDLING
		graf_mkstate(&mx,&my,&mb,&ks);
		objc_offset(tree,DAESLIDE,&sx,&sy);
#else
		if (!lst_handle(&li_dappinfo, ret, &d)) {
#endif
			/* Workaround fuer nicht waehlbare Seiten */
			if (!(fi_dappinfo.tree[exit_obj].ob_state & DISABLED))
				switch (exit_obj) {
				/* Programmdatei suchen */
				case DAISEARCH:
					if (mode == 0) {
						strcpy(aname, dapp->apname);
#if 0
						if(!aname[0])
						{
							aname[0]=(char)Dgetdrv()+65;
							aname[1]=':';
							Dgetpath(&aname[2],0);
							strcat(aname,"\\");
						}
						full2comp(aname,path,name);
						strcat(path,"*.*");
						/* Dateiauswahl durchfÅhren */
						fselect(path,name,&fret,rs_frstr[TXAPSEARCH],0,200);
						if(fi_dappinfo.state!=FST_WIN) frm_redraw(&fi_dappinfo,ROOT);
						/* Dateiauswahl mit "OK" beendet */
						if(fret==1)
						{
							p=strrchr(path,'\\');if(p) p[1]=0;
							comp2full(aname,path,name);

							/* Laufwerksbezeichnung immer gross */
							aname[0]=nkc_toupper(aname[0]);
							/* Bei Bedarf Schreibweise anpassen */
							fsinfo(aname,&filesys);
							fsconv(aname,&filesys);
#else
						if (full_fselect(aname, NULL, "*.*", 0, rs_frstr[TXAPSEARCH], 0, 200, &fi_dappinfo) == 1) {
#endif
							strcpy(dapp->apname, aname);
							str245(tree[DAINAME].ob_spec.tedinfo->te_ptext, aname);
							frm_redraw(&fi_dappinfo, DAINAME);

							/*
							 * Schauen, ob die betroffene Datei schon auf dem Desktop liegt
							 * und ggf. den dort eingetragenen Titel verwenden, falls
							 * bislang noch kein Titel eingetragen wurde
							 */
							if (!*tree[DAILABEL].ob_spec.tedinfo->te_ptext) {
								ICONDESK *p = desk.dicon + 1;

								for (i = 1; i <= MAXICON; i++, p++) {
									if ((p->class == IDFILE) && !strcmp(aname, p->spec.file->name)) {
										frm_edstring(&fi_dappinfo, DAILABEL, p->title);
										frm_redraw(&fi_dappinfo, DAILABEL);
										break;
									}
								}
							}

							/* Option "Parameterabfrage" an den Programmtyp anpassen */
							iret = is_appl(aname);
							switch (iret) {
							case 3: /* TTP - Parameter abfragen */
								if (!(tree[DAOASKPARM].ob_state & SELECTED))
									tree[DAOASKPARM].ob_state |= SELECTED;
								break;
							case 1: /* PRG, APP, TOS, ACC - Parameter nicht abfragen */
							case 2:
							case 4:
								if (tree[DAOASKPARM].ob_state & SELECTED)
									tree[DAOASKPARM].ob_state &= ~SELECTED;
								break;
							}
						}
						fi_dappinfo.exit_obj = exit_obj;

						frm_norm(&fi_dappinfo);

						/* Waehlbare Optionen anpassen - abhaengig von Datei/Programm */
						isap = is_appl(dapp->apname);
						dl_dappinfo_opt(isap, appl == &defappl);
						frm_redraw(&fi_dappinfo, ROOT);
					}
					break;
					/* Applikation abmelden */
				case DAIDELETE:
					sprintf(almsg, rs_frstr[ALAPPDEL], appl->title);
					if (frm_alert(1, almsg, altitle, conf.wdial, 0L) == 1) {
						app_remove(appl);
						appl = 0L;
						cont = 3; /* Rueckgabe: Geloescht */
						done = DAICANCEL;
					}
					fi_dappinfo.exit_obj = exit_obj;
					frm_norm(&fi_dappinfo);
					break;

					/* Abbrechen */
				case DAICANCEL:
					cont = 0; /* Rueckgabe: Abbruch */
					done = DAICANCEL;
					break;

					/* OK */
				case DAIOK:
					ok = 1;

					/* Dateiname angegeben? */
					if (dapp->apname[0]) {
						/* Bei Bedarf Schreibweise anpassen */
						fsinfo(dapp->apname, &filesys);
						fsconv(dapp->apname, &filesys);
						str245(tree[DAINAME].ob_spec.tedinfo->te_ptext, dapp->apname);
						if (dapp->mode == 0)
							frm_redraw(&fi_dappinfo, DAINAME);
						full2comp(dapp->apname, path, name);
					} else {
						/* Fuer die Defaultapplikation darf sowieso kein Name angegeben werden */
						if (appl != &defappl) {
							ok = 0;
							frm_alert(1, rs_frstr[ALAPPMISS], altitle, conf.wdial, 0L);
						}
					}

					/* Schon angemeldet? */
					if (ok) {
						aptr = app_find(dapp->apname);
						if (aptr && aptr != appl) {
							frm_alert(1, rs_frstr[ALAPPEXIST], altitle, conf.wdial, 0L);
							ok = 0;
						}
					}

					/* Falls kein Titel angegeben ist, dann Dateinamen verwenden */
					if (ok) {
						if (!tree[DAILABEL].ob_spec.tedinfo->te_ptext[0]) {
							frm_edstring(&fi_dappinfo, DAILABEL, name);
							if (dapp->mode == 0)
								frm_redraw(&fi_dappinfo, DAILABEL);
						}
					}

					/* Pruefen, ob der Titel eindeutig ist */
					if (ok) {
						char *newtitle;

						newtitle = tree[DAILABEL].ob_spec.tedinfo->te_ptext;
						aptr = app_get(newtitle);
						if ((aptr && (aptr != appl)) || ((appl != &defappl) && !strcmp(newtitle, rs_frstr[DEFAULTAPPL]))) {
							sprintf(almsg, rs_frstr[ALAPPLABEL], newtitle);
							frm_alert(1, almsg, altitle, conf.wdial, 0L);
							ok = 0;
						}
					}

					/* Wenn Alles ok ist, dann raus ... */
					if (ok) {
						cont = 2; /* RÅckgabe: Applikation geÑndert */
						done = DAIOK;
					} else {
						fi_dappinfo.exit_obj = exit_obj;
						frm_norm(&fi_dappinfo);
					}
					break;

					/* Umschalten der Seite */
				case DAGENERAL:
					dapp->mode = 0;
					break;
				case DAFILES:
					dapp->mode = 1;
					break;
				case DAOPTIONS:
					dapp->mode = 2;
					break;
				case DAENV:
					dapp->mode = 3;
					break;

					/* Environment */
				case DAEEDIT:
				case DAEDELETE:
					obj_edit(fi_dappinfo.tree, fi_dappinfo.edit_obj, 0, 0, &fi_dappinfo.edit_idx, ED_END, fi_dappinfo.win.handle);
					if (exit_obj == DAEEDIT && tree[DAEVAL].ob_spec.tedinfo->te_ptext[0]) {
						if (!*dapp->evar[sel])
							li_dappinfo.sel++;
						strcpy(dapp->evar[sel], tree[DAEVAL].ob_spec.tedinfo->te_ptext);
					} else {
						for (i = li_dappinfo.sel; i < MAX_EVAR - 1; i++)
							strcpy(dapp->evar[i], dapp->evar[i + 1]);
						dapp->evar[i][0] = 0;
					}

					i = 0;
					while (dapp->evar[i][0] && i < MAX_EVAR - 1)
						i++;
					li_dappinfo.num = i + 1;
					if (li_dappinfo.sel >= li_dappinfo.num)
						li_dappinfo.sel = li_dappinfo.num ? (li_dappinfo.num - 1) : 0;
					if (li_dappinfo.sel >= (li_dappinfo.offset + li_dappinfo.view))
						li_dappinfo.offset = li_dappinfo.sel - li_dappinfo.view + 1;
					strcpy(tree[DAEVAL].ob_spec.tedinfo->te_ptext, dapp->evar[li_dappinfo.sel]);
					if (li_dappinfo.num <= li_dappinfo.view)
						li_dappinfo.offset = 0;
					else {
						if (li_dappinfo.offset + li_dappinfo.view > li_dappinfo.num)
							li_dappinfo.offset = li_dappinfo.num - li_dappinfo.view;
					}

					fi_dappinfo.edit_idx = -1;
					obj_edit(fi_dappinfo.tree, fi_dappinfo.edit_obj, 0, 0, &fi_dappinfo.edit_idx, ED_INIT, fi_dappinfo.win.handle);
					frm_redraw(&fi_dappinfo, DAEVAL);
					lst_init(&li_dappinfo, 1, 1, 1, 1);
					fi_dappinfo.exit_obj = exit_obj;
					frm_norm(&fi_dappinfo);
					break;
#ifdef OLD_SLIDER_HANDLING
					case DAEUP:
					if(fi_selapp.state==FST_WIN) {wind_update(BEG_UPDATE);wind_update(BEG_MCTRL);}
					lst_up(&li_dappinfo);
					if(fi_selapp.state==FST_WIN) {wind_update(END_UPDATE);wind_update(END_MCTRL);}
					break;
					case DAEDOWN:
					if(fi_selapp.state==FST_WIN) {wind_update(BEG_UPDATE);wind_update(BEG_MCTRL);}
					lst_down(&li_dappinfo);
					if(fi_selapp.state==FST_WIN) {wind_update(END_UPDATE);wind_update(END_MCTRL);}
					break;
					case DAEBOX:
					if(fi_dappinfo.state==FST_WIN) {wind_update(BEG_UPDATE);wind_update(BEG_MCTRL);}
					if(my<sy) sd=-li_dappinfo.view;
					else sd=li_dappinfo.view;
					do
					{
						lst_move(&li_dappinfo,sd);
						graf_mkstate(&mx,&my,&mb,&ks);
					}
					while(mb&1);
					if(fi_dappinfo.state==FST_WIN) {wind_update(END_UPDATE);wind_update(END_MCTRL);}
					break;
					case DAESLIDE:
					if(fi_dappinfo.state==FST_WIN) {wind_update(BEG_UPDATE);wind_update(BEG_MCTRL);}
					lst_slide(&li_dappinfo);
					if(fi_dappinfo.state==FST_WIN) {wind_update(END_UPDATE);wind_update(END_MCTRL);}
					break;
					case -1:
					if(fi_dappinfo.state==FST_WIN) {wind_update(BEG_UPDATE);wind_update(BEG_MCTRL);}
					lst_key(&li_dappinfo,fi_dappinfo.normkey);
					if(fi_dappinfo.state==FST_WIN) {wind_update(END_UPDATE);wind_update(END_MCTRL);}
					break;
					default:
					if(exit_obj>=DAELIST+1 && exit_obj<=DAELIST+li_dappinfo.view)
					{
						csel=exit_obj-DAELIST-1+li_dappinfo.offset;
						if(li_dappinfo.num && csel<li_dappinfo.num)
						{
							if(fi_dappinfo.state==FST_WIN) {wind_update(BEG_UPDATE);wind_update(BEG_MCTRL);}
							lst_select(&li_dappinfo,csel);
							if(fi_dappinfo.state==FST_WIN) {wind_update(END_UPDATE);wind_update(END_MCTRL);}
						}
					}
					break;
#endif
				}
#ifndef OLD_SLIDER_HANDLING
		}
#endif

		/* Neue Auswahl im Environment uebernehmen */
		if (sel != li_dappinfo.sel) {
			obj_edit(fi_dappinfo.tree, fi_dappinfo.edit_obj, 0, 0, &fi_dappinfo.edit_idx, ED_END, fi_dappinfo.win.handle);
			strcpy(tree[DAEVAL].ob_spec.tedinfo->te_ptext, dapp->evar[li_dappinfo.sel]);
			fi_dappinfo.edit_idx = -1;
			obj_edit(fi_dappinfo.tree, fi_dappinfo.edit_obj, 0, 0, &fi_dappinfo.edit_idx, ED_INIT, fi_dappinfo.win.handle);
			frm_redraw(&fi_dappinfo, DAEVAL);
		}

		/* Bei Bedarf neue Seite aktivieren */
		if (dapp->mode != mode1) {
			if (fi_dappinfo.edit_obj) {
				obj_edit(fi_dappinfo.tree, fi_dappinfo.edit_obj, 0, 0, &fi_dappinfo.edit_idx, ED_END, fi_dappinfo.win.handle);
				fi_dappinfo.edit_obj = 0;
				fi_dappinfo.edit_idx = -1;
			}
			dl_dappinfo_mode(dapp->mode);
			if (fi_dappinfo.edit_obj)
				obj_edit(fi_dappinfo.tree, fi_dappinfo.edit_obj, 0, 0, &fi_dappinfo.edit_idx, ED_INIT, fi_dappinfo.win.handle);
#if 1
			isap = is_appl(dapp->apname);
			dl_dappinfo_opt(isap, appl == &defappl);
#endif
			frm_redraw(&fi_dappinfo, DASUB);
			mevent.ev_mwich = MU_M1;
			frm_do(&fi_dappinfo, &mevent);
		}
	} else
		done = DAICANCEL;

	if (done) {
		/* Falls mit "OK" beendet wurde, dann Angaben Åbernehmen */
		if (done == DAIOK) {
			/* Datei? */
			isap = is_appl(dapp->apname);

			strcpy(dapp->aparam, tree[DAIPARAM].ob_spec.tedinfo->te_ptext);

			strcpy(appl->title, tree[DAILABEL].ob_spec.tedinfo->te_ptext);
			strcpy(appl->name, dapp->apname);
			strcpy(appl->parm, dapp->aparam);
			appl->paralways = dial_getopt(tree, DAIALWAYS, SELECTED);
			if (tree[DAIAPPL].ob_state & SELECTED)
				appl->homepath = 1;
			if (tree[DAIWINDOW].ob_state & SELECTED)
				appl->homepath = 2;
			if (tree[DAIFILE].ob_state & SELECTED)
				appl->homepath = 0;
			strcpy(appl->fileopen, tree[DAIOPEN].ob_spec.tedinfo->te_ptext);
			strcpy(appl->fileview, tree[DAIVIEW].ob_spec.tedinfo->te_ptext);
			strcpy(appl->fileprint, tree[DAIPRINT].ob_spec.tedinfo->te_ptext);
			appl->dodrag = dial_getopt(tree, DAIINDRAG, SELECTED);
			appl->getpar = dial_getopt(tree, DAOASKPARM, SELECTED);
			appl->unixpaths = dial_getopt(tree, DAOUNIXPATHS, SELECTED);
			appl->vaproto = dial_getopt(tree, DAOVAPROT, SELECTED);
			appl->single = dial_getopt(tree, DAOSINGLE, SELECTED);
			appl->conwin = dial_getopt(tree, DAOCONWIN, SELECTED);
			appl->toswait = dial_getopt(tree, DAOWAITKEY, SELECTED);
			appl->fullcompare = dial_getopt(tree, DAOFULL, SELECTED);
			appl->autostart = dial_getopt(tree, DAOAUTO, SELECTED);
			appl->overlay = dial_getopt(tree, DAOOVERLAY, SELECTED);
			appl->usesel = dial_getopt(tree, DAIUSESEL, SELECTED);
			appl->memlimit = atol(tree[DAOMAXMEM].ob_spec.tedinfo->te_ptext);
			strcpy(appl->alert, tree[DAOALERT].ob_spec.tedinfo->te_ptext);
			appl->shortcut = pop_short.sel - 1;

			/* Environment */
			for (i = 0; i < MAX_EVAR; i++) /* Bisherige Eintraege loeschen */
			{
				if (appl->evar[i]) {
					pfree(appl->evar[i]);
					appl->evar[i] = 0L;
				}
			}
			sel = 0;
			ok = 1;
			/* Neue Eintraege aufnehmen */
			for (i = 0; i < MAX_EVAR; i++) {
				if (dapp->evar[i][0]) {
					appl->evar[sel] = pmalloc(strlen(dapp->evar[i]) + 1L);
					if (appl->evar[sel]) {
						strcpy(appl->evar[sel], dapp->evar[i]);
						sel++;
					} else
						ok = 0;
				}
			}
			/* Ggf. Fehler melden */
			if (!ok)
				frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
			appl->euse = dial_getopt(tree, DAEUSE, SELECTED);

			/* Anpassungen an Dateien als Appl. */
			if (!isap)
				appl->dodrag = 0;
		}

		if (done == DAICANCEL) {
			/* Falls Neu-Anmeldung, dann jetzt lîschen */
			if (dapp->new) {
				app_remove(appl);
				appl = 0L;
			}
		}

		frm_end(&fi_dappinfo);

		/* Ggf. Applikations-Listen-Dialog aktualisieren */
		if (fi_defappl.open && !mode) {
			if (cont == 2 || cont == 3) {
				/* Dialog ggf. schlieûen, wenn Update fehlgeschlagen ist */
				if (!dl_appl_update(cont, appl))
					fi_defappl.exit(1, 0);
				else {
					/* Sonst ggf. Buttons aktualisieren */
					if (li_defappl.sel != -1) {
						rs_trindex[DEFAPPL][DAEDIT].ob_state &= ~DISABLED;
						rs_trindex[DEFAPPL][DADELETE].ob_state &= ~DISABLED;
						frm_redraw(&fi_defappl, DAEDIT);
						frm_redraw(&fi_defappl, DADELETE);
					}
				}
			}
		}

		/* Lokale Dialogbuffer freigeben */
		pfree(dapp->ebuf);
		pfree( dapp);
	}
	pfree(path);
}

/* Eventuell betroffene Verzeichnisfenster aktualisieren
 l=strlen(icon->spec.folder->path);
 for(i=0;i<MAX_PWIN;i++)
 {
 if(glob.win[i].state&WSOPEN)
 {
 wpath=(W_PATH *)glob.win[i].user;
 if(wpath->rel && !strncmp(wpath->path,icon->spec.folder->path,l))
 {
 strcpy(wpath->relname,icon->title);
 wpath_iupdate(&glob.win[i],0);
 }
 }
 }
 
 */

/**-------------------------------------------------------------------------
 dl_prtinfo()

 Info ueber Drucker auf dem Desktop anzeigen/aendern
 -------------------------------------------------------------------------*/
int dl_prtinfo(ICONDESK *icon, int donext) {
	int cont, done;
	OBJECT *tree;

	tree = rs_trindex[PRTINFO];

	/* Dialog vorbereiten */
	dial_setopt(tree, PRNEXT, DISABLED, !donext);
	strcpy(tree[PRLABEL].ob_spec.tedinfo->te_ptext, icon->title);

	/* Auf gehts ... */
	frm_start(&fi_prtinfo, conf.wdial, conf.cdial, 1);
	done = 0;
	while (!done) {
		frm_dial(&fi_prtinfo, &mevent);
		switch (fi_prtinfo.exit_obj) {
		case PRHELP:
			show_help(fi_prtinfo.userinfo);
			frm_norm(&fi_prtinfo);
			break;
		case PRCANCEL:
			cont = 0; /* Rueckgabe: Abbruch */
			done = 1;
			break;
		case PROK:
			strcpy(icon->title, tree[PRLABEL].ob_spec.tedinfo->te_ptext);
			cont = 2; /* Rueckgabe: Icon geaendert */
			done = 1;
			break;
		case PRNEXT:
			cont = 1; /* Rueckgabe: Icon uebersprungen */
			done = 1;
			break;
		}
	}
	frm_end(&fi_prtinfo);

	return cont;
}

/**-------------------------------------------------------------------------
 dl_devinfo()

 Info ueber Device auf dem Desktop anzeigen/Ñndern
 -------------------------------------------------------------------------*/
int dl_devinfo(ICONDESK *icon, int donext) {
	int cont, done;
	OBJECT *tree;

	tree = rs_trindex[DEVINFO];

	/* Dialog vorbereiten */
	dial_setopt(tree, DVNEXT, DISABLED, !donext);
	strcpy(tree[DVLABEL].ob_spec.tedinfo->te_ptext, icon->title);
	str230(tree[DVNAME].ob_spec.free_string, icon->spec.device->name);

	/* Auf gehts ... */
	frm_start(&fi_devinfo, conf.wdial, conf.cdial, 1);
	done = 0;
	while (!done) {
		frm_dial(&fi_devinfo, &mevent);
		switch (fi_devinfo.exit_obj) {
		case DVHELP:
			show_help(fi_devinfo.userinfo);
			frm_norm(&fi_devinfo);
			break;
		case DVCANCEL:
			cont = 0; /* Rueckgabe: Abbruch */
			done = 1;
			break;
		case DVOK:
			cont = 2; /* Rueckgabe: Icon geaendert */
			done = 1;
			break;
		case DVNEXT:
			cont = 1; /* Rueckgabe: Icon uebersprungen */
			done = 1;
			break;
		}
	}
	frm_end(&fi_devinfo);

	if (fi_devinfo.exit_obj == DVOK) {
		strcpy(icon->title, tree[DVLABEL].ob_spec.tedinfo->te_ptext);
	}

	return cont;
}

/**-------------------------------------------------------------------------
 dl_fileinfo()

 Info ueber Dateien/Ordner anzeigen/aendern
 -------------------------------------------------------------------------*/
void dl_fileinfo_mode(int mode, int file, int desk) {
	OBJECT *tree;

	tree = rs_trindex[FLINFO];

	tree[FINAME].ob_flags &= ~EDITABLE;
	tree[FILABEL].ob_flags &= ~EDITABLE;
	tree[FPMAGIC].ob_flags &= ~EDITABLE;
	tree[FAUID].ob_flags &= ~EDITABLE;
	tree[FAGID].ob_flags &= ~EDITABLE;

	fi_fileinfo.edit_obj = -1;

	switch (mode) {
	case 0:
		tree[FLSUB].ob_head = FLSGENERAL;
		tree[FLSUB].ob_tail = FLSGENERAL;
		tree[FLSGENERAL].ob_next = FLSUB;

		if (!desk) {
			tree[FINAME].ob_flags |= EDITABLE;
			fi_fileinfo.edit_obj = FINAME;
		} else {
			tree[FILABEL].ob_flags |= EDITABLE;
			fi_fileinfo.edit_obj = FILABEL;
		}
		break;
	case 1:
		tree[FLSUB].ob_head = FLSPROG;
		tree[FLSUB].ob_tail = FLSPROG;
		tree[FLSPROG].ob_next = FLSUB;

#ifndef _NAES
		if (tb.sys & SY_MAGX) {
			tree[FPMAGIC].ob_flags |= EDITABLE;
			fi_fileinfo.edit_obj = FPMAGIC;
		}
#endif
		break;
	case 2:
		tree[FLSUB].ob_head = FLSATTR;
		tree[FLSUB].ob_tail = FLSATTR;
		tree[FLSATTR].ob_next = FLSUB;

		if (!desk) {
			if ((tree[FAUID].ob_flags & HIDETREE) == 0) {
				fi_fileinfo.edit_obj = FAUID;
				tree[FAUID].ob_flags |= EDITABLE;
				tree[FAGID].ob_flags |= EDITABLE;
			}
		}
		break;
	}
}

/**
 *
 */
static void dl_fileinfo_dmode(OBJECT *tree, int dmode, unsigned int atime,
		unsigned int adate, unsigned int mtime, unsigned int mdate,
		unsigned int ctime, unsigned int cdate) {
	unsigned int _time, _date;
	char *desc;

	switch (dmode) {
	case 0:
		_time = mtime;
		_date = mdate;
		desc = rs_frstr[TXMDATE];
		break;
	case 1:
		_time = atime;
		_date = adate;
		desc = rs_frstr[TXADATE];
		break;
	case 2:
		_time = ctime;
		_date = cdate;
		desc = rs_frstr[TXCDATE];
		break;
	}/* FLOFILE */
	sprintf(tree[FIDATE].ob_spec.tedinfo->te_ptext, glob.dateformat, _date & 0x1f, (_date & 0x1e0) >> 5, 1980 + ((_date & 0xfe00) >> 9));
	sprintf(tree[FITIME].ob_spec.tedinfo->te_ptext, glob.timeformat, (_time & 0xf800) >> 11, (_time & 0x7e0) >> 5);
	tree[FIDATETYPE].ob_spec.tedinfo->te_ptext = desc;
}

/**
 *
 */
int dl_fileinfo(char *path, int usepar, FILESYS *filesys, WP_ENTRY *item,
		ICONDESK *icon, int donext) {
	W_PATH *wpath1;
	char *wname, *lpath;
	char *fmask, *dlstr;
	int cont, done, ok, attr, fkey, atfirst, i, l, desk, file;
	int nfiles, nfolders, nlinks;
	unsigned long size;
	long fret;
	long magic[2];
	char name[MAX_FLEN], *oldname, *newname;
	int mode1;
	static int mode = 0;
	unsigned int tmode, imode;
	long fh;
	PH ph;
	int isp, ism, dvalid;
	DOSTIME dtime;
	OBJECT *tree;
	static int dmode = 0;
	struct passwd *pwd;
	struct group *grp;
	int newuid, newgid;
	HOTKEY *hk, *p;
	int key = 0;

	wname = pmalloc(MAX_PLEN * 4L);
	if (wname == NULL) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		return (0);
	}
	lpath = wname + MAX_PLEN;
	oldname = lpath + MAX_PLEN;
	newname = oldname + MAX_PLEN;

	tree = rs_trindex[FLINFO];

	/* Vorbereitungen: Datei auf Desktop? Datei/Ordner? */
	tree[FLPROG].ob_state |= DISABLED;
	tree[FLPROG].ob_flags &= ~(SELECTABLE | TOUCHEXIT);

	/* Erweiterte Attribute ja/nein? */
	tree[FLATTR].ob_state |= DISABLED;
	tree[FLATTR].ob_flags &= ~(SELECTABLE | TOUCHEXIT);

	/* Objekt ist symbolischer Link */
	tree[FILINK].ob_flags |= HIDETREE;
	tree[FILINKDEST].ob_flags |= HIDETREE;
	tree[FILINKDEST].ob_state &= ~DISABLED;

	if (item) {
		desk = 0;
		if (item->class==EC_FILE)
			file = 1;
		else
			file = 0;
		strcpy(oldname, path);
		strcat(oldname, item->name);
		if (item->link) {
			if (!Freadlink(MAX_PLEN, newname, oldname)) {
				tree[FILINK].ob_flags &= ~HIDETREE;
				tree[FILINKDEST].ob_flags &= ~HIDETREE;
				if (item->link == 2)
					tree[FILINKDEST].ob_state |= DISABLED;
				str230(getObjectText(tree, FILINKDEST), newname);
			}
		}
	} else {
		desk = 1;
		if (icon->class==IDFILE) {
			file = 1;
			strcpy(oldname, icon->spec.file->name);
		} else {
			file = 0;
			strcpy(oldname, icon->spec.folder->path);
		}
	}
	if (item && !file)
		strcat(oldname, "\\");
	for (hk = glob.hotkeys; hk != NULL; hk = hk->next) {
		if (!strcmp(hk->object, oldname))
			break;
	}
	if (item && !file)
		*strrchr(oldname, '\\') = 0;
	tree[FIHOTKEY].ob_spec.tedinfo->te_ptext[0] = hk ? hk->key : 0;

	/* Zeiger von 'Pfad: ..' im Dialog sichern */
	dlstr = tree[FIPATH - 1].ob_spec.free_string;

	/* Objekte im Verzeichnis */
	if (!desk) {
		tree[FILABEL].ob_flags &= ~EDITABLE;
		tree[FILABEL].ob_state |= DISABLED;
		tree[FILABEL].ob_flags |= HIDETREE;
		tree[FILABEL - 1].ob_flags |= HIDETREE;
		tree[FILABEL].ob_spec.tedinfo->te_ptext[0] = 0;
		tree[FLOFILE].ob_flags &= ~HIDETREE;

		if (file) /* Datei - ggf. Programmheader lesen */
		{
			/* Dialoganpassung */
			tree[FLOFOLD].ob_flags |= HIDETREE;
			tree[FLOFLAG].ob_flags &= ~HIDETREE;

			/* Dateiname */
			strcpy(tree[FINAME].ob_spec.tedinfo->te_ptext, item->name);

			isp = ism = dvalid = 0;
#if 0
			if(is_app(oldname,item->mode))
#endif
			{
				fh = Fopen(oldname, FO_READ);
				if (fh >= 0L) {
					/* Zeit/Datum sichern */
					Fdatime(&dtime, (int) fh, 0);
					if (dtime.time != 0 && dtime.date != 0)
						dvalid = 1;

					/* Programmheader lesen */
					if (Fread((int) fh, sizeof(PH), &ph) == sizeof(PH)) {
						if (ph.ph_branch == 0x601a)
							isp = 1;
					}
#ifndef _NAES
					/* MagiC-Speicherlimit ermitteln */
					if (isp && (tb.sys & SY_MAGX)) {
						Fseek(-8L, (int) fh, 2);
						if (Fread((int) fh, 8L, magic) == 8L) {
							if (magic[0] == 'MAGX' && magic[1] >= 0L)
								ism = 1;
						}
					}
#else
					magic[0] = 0L;
#endif /* _NAES */
					Fclose((int) fh);
				}
			}

			/* GEMDOS-Flags */
			dial_setopt(tree, FIFLAGRO, SELECTED, item->attr & FA_READONLY);
			dial_setopt(tree, FIFLAGH, SELECTED, item->attr & FA_HIDDEN);
			dial_setopt(tree, FIFLAGS, SELECTED, item->attr & FA_SYSTEM);
			dial_setopt(tree, FIFLAGA, SELECTED, item->attr & FA_ARCHIVE);

			/* Programmflags eintragen falls Datei ein Programm ist */
			if (isp) {
				tree[FLPROG].ob_state &= ~DISABLED;
				tree[FLPROG].ob_flags |= (SELECTABLE | TOUCHEXIT);

				dial_setopt(tree, FPFAST, SELECTED, !!(ph.ph_res2 & 0x1L));
				dial_setopt(tree, FPLALT, SELECTED, !!(ph.ph_res2 & 0x2L));
				dial_setopt(tree, FPMALT, SELECTED, !!(ph.ph_res2 & 0x4L));
				dial_setopt(tree, FPMINMEM, SELECTED, !!(ph.ph_res2 & 0x8L));
				dial_setopt(tree, FPSHARED, SELECTED, !!(ph.ph_res2 & 0x800L));
				pop_mem.sel = 1 + ((int) (ph.ph_res2 & 0x70L) >> 4);

				if (ism && magic[1] > 0L)
					ltoa(magic[1] / 1024L, tree[FPMAGIC].ob_spec.tedinfo->te_ptext, 10);
				else
					tree[FPMAGIC].ob_spec.tedinfo->te_ptext[0] = 0;
			}

			/* Reihenfloge der Flagaenderung merken */
			if (item->attr & FA_READONLY)
				atfirst = 1;
			else
				atfirst = 0;

			/* Weitere Daten eintragen */
			prlong11(item->size, tree[FISIZE].ob_spec.free_string);
		} else {
			/* Ordner */

			/* Dialoganpassung */
			tree[FLOFLAG].ob_flags |= HIDETREE;
			tree[FLOFOLD].ob_flags &= ~HIDETREE;

			strcpy(lpath, path);
			if (usepar) {
				i = (int) strlen(lpath) - 2;
				while (lpath[i] != '\\')
					i--;
				i++;
				strcpy(item->name, &lpath[i]);
				path[i] = 0;
				item->name[(int) strlen(item->name) - 1] = 0;
			}

			/* Infos ermitteln */
			strcpy(oldname, path);
			strcat(oldname, item->name);
			graf_mouse(BUSYBEE, 0L);
			nfiles = nfolders = nlinks = 0;
			size = 0L;
			fret = dir_check(oldname, &nfiles, &nfolders, &size, &nlinks, 0, 0);
			graf_mouse(ARROW, 0L);
			if (fret != 0) {
				pfree(wname);
				return 0; /* Bei Lesefehler raus */
			}

			/* Dialog vorbereiten */
			str230(tree[FIPATH].ob_spec.free_string, path);
			strcpy(oldname, path);
			strcat(oldname, item->name);
			strcat(oldname, "\\");

			strcpy(tree[FINAME].ob_spec.tedinfo->te_ptext, item->name);

			prlong11(size, tree[FISIZE].ob_spec.free_string);
			sprintf(tree[FLFILES].ob_spec.free_string, "%-6d", nfiles);
			sprintf(tree[FLFOLDERS].ob_spec.free_string, "%-6d", nfolders);
		}

		/* MiNT-Flags */
		tmode = S_IRUSR;
		for (i = 0; i < 12; i++) {
			dial_setopt(tree, FLMODE1 + i, SELECTED, item->mode & tmode);
			if (tmode != S_IXOTH)
				tmode >>= 1;
			else
				tmode = 04000; /* setuid */
		}

		/* Pfad */
		str230(tree[FIPATH].ob_spec.free_string, path);

		/* Datum/Zeit */
		tree[FIDATETYPE].ob_flags &= ~TOUCHEXIT;
		tree[FIDATETYPE].ob_flags &= ~HIDETREE;
		if (filesys->flags & STIMES)
			tree[FIDATETYPE].ob_flags |= TOUCHEXIT;
		else {
			tree[FIDATETYPE].ob_flags |= HIDETREE;
			dmode = 0;
		}
		dl_fileinfo_dmode(tree, dmode, item->atime, item->adate, item->time,
				item->date, item->ctime, item->cdate);

		/*
		 * Falls Dateisystem nicht case-sensitiv, dann im Dialog nur
		 * Grossbuchstaben.
		 */
/* todo */
		fmask = tree[FINAME].ob_spec.tedinfo->te_pvalid;
		i = 0;
		if (filesys->flags & (TOS | UPCASE)) {
			while (fmask[i]) {
				fmask[i] = 'x';
				i++;
			}
		} else {
			while (fmask[i]) {
				fmask[i] = 'X';
				i++;
			}
		}

		/* Bei entsprechende Filesystemen MiNT-Attribute-Page erlauben */
		if (filesys->flags & UNIXATTR) {
			tree[FLATTR].ob_state &= ~DISABLED;
			tree[FLATTR].ob_flags |= SELECTABLE | TOUCHEXIT;

			if (filesys->flags & OWNER) {
				tree[FAUID].ob_state &= ~HIDETREE;
				tree[FAGID].ob_state &= ~HIDETREE;

				pwd = getpwuid(item->uid);
				if ((pwd == NULL) || (strlen(pwd->pw_name) > 8)) {
					sprintf(tree[FAUID].ob_spec.tedinfo->te_ptext, "%u", (unsigned int) item->uid);
				} else
					strcpy(tree[FAUID].ob_spec.tedinfo->te_ptext, pwd->pw_name);

				grp = getgrgid(item->gid);
				if ((grp == NULL) || (strlen(grp->gr_name) > 8)) {
					sprintf(tree[FAGID].ob_spec.tedinfo->te_ptext, "%u", (unsigned int) item->gid);
				} else
					strcpy(tree[FAGID].ob_spec.tedinfo->te_ptext, grp->gr_name);
			} else {
				tree[FAUID].ob_state |= HIDETREE;
				tree[FAGID].ob_state |= HIDETREE;
			}
		}
	} else /* Objekt auf dem Desktop */
	{
		/* Dialoganpassung */
		tree[FLOFLAG].ob_flags |= HIDETREE;
		tree[FLOFOLD].ob_flags |= HIDETREE;
		tree[FLOFILE].ob_flags |= HIDETREE;

		tree[FILABEL].ob_flags |= EDITABLE;
		tree[FILABEL].ob_state &= ~DISABLED;
		tree[FILABEL].ob_flags &= ~HIDETREE;
		tree[FILABEL - 1].ob_flags &= ~HIDETREE;
		strcpy(tree[FILABEL].ob_spec.tedinfo->te_ptext, icon->title);

		str230(tree[FIPATH].ob_spec.free_string, oldname);

		if (icon->class==IDFILE) {
			/* Statt 'Pfad: ...' 'Name: ...' */
			tree[FIPATH - 1].ob_spec.free_string = tree[FINAME - 1].ob_spec.free_string;
		}
		tree[FINAME - 1].ob_flags |= HIDETREE;
		tree[FINAME].ob_flags |= HIDETREE;
	}

	/* Weitere Vorbereitungen */
	tree[FLGENERAL].ob_state &= ~SELECTED;
	tree[FLPROG].ob_state &= ~SELECTED;
	tree[FLATTR].ob_state &= ~SELECTED;

	mode1 = mode;
	if (((mode == 2) && (tree[FLATTR].ob_state & DISABLED)) || ((mode == 1) && (tree[FLPROG].ob_state & DISABLED))) {
		mode = mode1 = 0;
	}
	switch (mode) {
	case 0:
		tree[FLGENERAL].ob_state |= SELECTED;
		break;
	case 1:
		tree[FLPROG].ob_state |= SELECTED;
		break;
	case 2:
		tree[FLATTR].ob_state |= SELECTED;
		break;
	}

	dl_fileinfo_mode(mode, file, desk);

	pop_fkeyfd.sel = setfpop(oldname);
	fkey = pop_fkeyfd.sel;

	dial_setopt(tree, FINEXT, DISABLED, !donext);

	/* Auf gehts ... */
	frm_start(&fi_fileinfo, conf.wdial, conf.cdial, 1);
	done = 0;
	while (!done) {
		frm_dial(&fi_fileinfo, &mevent);
		mode1 = mode;
		switch (fi_fileinfo.exit_obj) {
		int d, mb;

	case FIDATETYPE:
		do
			graf_mkstate(&d, &d, &mb, &d);
		while (mb & 1);
		if (++dmode == 3)
			dmode = 0;
		dl_fileinfo_dmode(tree, dmode, item->atime, item->adate, item->time, item->date, item->ctime, item->cdate);
		if (mode == 0)
			frm_redraw(&fi_fileinfo, FLOFILE);
		break;
	case FIHOTKEYSEL:
		key = get_new_hotkey(hk);
		if (fi_fileinfo.state != FST_WIN)
			frm_redraw(&fi_fileinfo, ROOT);
		if (key) {
			tree[FIHOTKEY].ob_spec.tedinfo->te_ptext[0] = key;
			frm_redraw(&fi_fileinfo, FIHOTKEY);
		}
		frm_norm(&fi_fileinfo);
		break;
	case FIHELP:
		show_help(fi_fileinfo.userinfo);
		frm_norm(&fi_fileinfo);
		break;
	case FICANCEL:
		cont = 0; /* Rueckgabe: Abbruch */
		mode = 0;
		done = 1;
		break;
	case FIOK:
		ok = 1;

		/* Bei Verzeichnisobjekten Dateinamen und ggf. UID/GID pruefen */
		if (!desk) {
			char *p = tree[FINAME].ob_spec.tedinfo->te_ptext;
			if (!*p || !valid_mask(p, 0)) {
				frm_alert(1, rs_frstr[ALILLNAME], altitle, conf.wdial, 0L);
				ok = 0;
			}
			if (ok && ((filesys->flags & (UNIXATTR | OWNER)) == (UNIXATTR | OWNER))) {
				char *hlp, *err;
				unsigned long id;
				int isok = 1;

				hlp = tree[FAUID].ob_spec.tedinfo->te_ptext;
				if (isdigit(*hlp)) {
					id = strtoul(hlp, &err, 10);
					if (*err || (id > 65535UL))
						isok = 0;
					newuid = (int) id;
				} else {
					pwd = getpwnam(hlp);
					if (pwd != NULL)
						newuid = (int) pwd->pw_uid;
					else
						isok = 0;
				}
				if (!isok) {
					frm_alert(1, rs_frstr[ALUID], altitle, conf.wdial, 0L);
					ok = 0;
				} else {
					hlp = tree[FAGID].ob_spec.tedinfo->te_ptext;
					if (isdigit(*hlp)) {
						id = strtoul(hlp, &err, 10);
						if (*err || (id > 65535UL))
							isok = 0;
						newgid = (int) id;
					} else {
						grp = getgrnam(hlp);
						if (grp != NULL)
							newgid = (int) grp->gr_gid;
						else
							isok = 0;
					}
					if (!isok) {
						frm_alert(1, rs_frstr[ALGID], altitle, conf.wdial, 0L);
						ok = 0;
					}
				}
			}
		}

		if (ok) {
			cont = 2; /* Rueckgabe: Icon geaendert */
			done = 1;
		} else
			frm_norm(&fi_fileinfo);
		break;
	case FINEXT:
		cont = 1; /* Rueckgabe: Icon uebersprungen */
		done = 1;
		break;
	case FLGENERAL:
		mode = 0;
		break;
	case FLPROG:
		mode = 1;
		break;
	case FLATTR:
		mode = 2;
		break;
		}

		if (mode1 != mode) {
			if (mode1 == 2) {
				obj_edit(fi_fileinfo.tree, fi_fileinfo.edit_obj, 0, 0, &fi_fileinfo.edit_idx, ED_END, fi_fileinfo.win.handle);
				fi_fileinfo.edit_obj = 0;
				fi_fileinfo.edit_idx = -1;
			}
			dl_fileinfo_mode(mode, file, desk);
			fi_fileinfo.edit_idx = -1;
			if (fi_fileinfo.edit_obj != -1)
				obj_edit(fi_fileinfo.tree, fi_fileinfo.edit_obj, 0, 0, &fi_fileinfo.edit_idx, ED_INIT, fi_fileinfo.win.handle);
			frm_redraw(&fi_fileinfo, FLSUB);
		}
	}
	frm_end(&fi_fileinfo);

	if (fi_fileinfo.exit_obj == FIOK) {
		if (key) {
			p = get_hotkey(key);
			if ((hk != NULL) && (p != NULL) && (p != hk)) {
				if (hk->prev)
					hk->prev->next = hk->next;
				else
					glob.hotkeys = hk->next;
				if (hk->next)
					hk->next->prev = hk->prev;
				pfree(hk);
			}
			if (p == NULL) {
				if (hk == NULL) {
					if ((p = pmalloc(sizeof(HOTKEY))) == NULL)
						frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
					else {
						p->prev = NULL;
						p->next = glob.hotkeys;
						if (glob.hotkeys != NULL)
							glob.hotkeys->prev = p;
						glob.hotkeys = p;
					}
				} else
					p = hk;
			}
			if (p != NULL) {
				p->key = key;
				hk = p;
			}
		}
		if (!desk) /* Objekt im Verzeichnis */
		{
			strcpy(name, tree[FINAME].ob_spec.tedinfo->te_ptext);

			/* Bei Bedarf Schreibweise anpassen */
			fsconv(name, filesys);

			attr = item->attr;
			if (tree[FIFLAGRO].ob_state & SELECTED)
				attr |= FA_READONLY;
			else
				attr &= ~FA_READONLY;
			if (tree[FIFLAGH].ob_state & SELECTED)
				attr |= FA_HIDDEN;
			else
				attr &= ~FA_HIDDEN;
			if (tree[FIFLAGS].ob_state & SELECTED)
				attr |= FA_SYSTEM;
			else
				attr &= ~FA_SYSTEM;
			if (tree[FIFLAGA].ob_state & SELECTED)
				attr |= FA_ARCHIVE;
			else
				attr &= ~FA_ARCHIVE;

			imode = item->mode;
			tmode = S_IRUSR;
			for (i = 0; i < 12; i++) {
				if (tree[FLMODE1 + i].ob_state & SELECTED)
					imode |= tmode;
				else
					imode &= ~tmode;
				if (tmode != S_IXOTH)
					tmode >>= 1;
				else
					tmode = 04000; /* setuid */
			}

			/* Programmflags */
			if (file && isp) {
				ph.ph_res2 &= ~0x100f;
				if (tree[FPFAST].ob_state & SELECTED)
					ph.ph_res2 |= 0x1L;
				if (tree[FPLALT].ob_state & SELECTED)
					ph.ph_res2 |= 0x2L;
				if (tree[FPMALT].ob_state & SELECTED)
					ph.ph_res2 |= 0x4L;

				ph.ph_res2 &= ~0x70L;
				ph.ph_res2 |= (long) ((pop_mem.sel - 1) << 4);

				if (tree[FPSHARED].ob_state & SELECTED)
					ph.ph_res2 |= 0x1000L;
				if (tree[FPMINMEM].ob_state & SELECTED)
					ph.ph_res2 |= 0x8L;

				/* MagiC-Speicherlimit */
				magic[0] = 'MAGX';
				magic[1] = atol(tree[FPMAGIC].ob_spec.tedinfo->te_ptext)
						* 1024L;
			}

			if (atfirst) /* Falls Datei schreibgeschuetzt, dann erst Attr. */
			{
				strcpy(newname, oldname);
				goto dl_fileinfo2;
			}

			dl_fileinfo1:
			/* Falls Programm, dann Programmheader ersetzen */
			if (file && isp) {
				fh = Fopen(oldname, FO_RW);
				if (fh >= 0L) {
					Fwrite((int) fh, sizeof(PH), &ph);

					/* Bei Bedarf MagiC-Speicherlimit setzen/loeschen */
#ifndef _NAES
					if (magic[1] > 0L) /* Limit Ñndern/setzen */
					{
						if (ism)
							Fseek(-8L, (int) fh, 2);
						else
							Fseek(0L, (int) fh, 2);
						Fwrite((int) fh, 8L, magic);
					} else /* Limit lîschen */
					{
						if (ism) {
							Fseek(-8L, (int) fh, 2);
							Fwrite((int) fh, 0L, (void *) -1L); /* Achtung: Geht nur mit MagiC! */
						}
					}
#endif /* _NAES */

					/* Ggf. Datum/Zeit wiederherstellen */
					if (dvalid)
						Fdatime(&dtime, (int) fh, 1);

					Fclose((int) fh);
					/*
					 * Durch das Aendern wurde das FA_ARCHIVE-Flag gesetzt und muss
					 * daher im alten Attribut gesetzt werden, damit es anschliessend
					 * bei Bedarf wieder entfernt wird.
					 */
					item->attr |= FA_ARCHIVE;
					atfirst = 0;
				}
			}

			/* Datei/Ordner umbenennen */
			strcpy(newname, path);
			strcat(newname, name);
			if (!file) {
				i = 0;
				while (oldname[i])
					i++;
				if (i > 0)
					oldname[i - 1] = 0;
			}
			if (strcmp(oldname, newname) != 0)
				fret = (long) Frename(0, oldname, newname);
			else
				fret = 0L;
			if (fret != 0L) {
				err_file(rs_frstr[ALFLRENAME], fret, oldname);
				/*
				 * Alten Namen als neuen eintragen, damit im Verzeichnis nicht
				 * der falsche erscheint
				 */
				full2comp(oldname, path, name);
				cont = 1;
			} else {
				if (atfirst)
					goto dl_fileinfo3;
				dl_fileinfo2:
				/* Dateiattribute setzen */
				if (filesys->flags & UNIXATTR) {
					if (imode != item->mode) {
						fret = Fchmod(newname, imode & 07777);
						if (fret != 0L) {
							err_file(rs_frstr[ALFLATTR], fret, newname);
							cont = 1;
						} else {
							item->mode = imode;
						}
					}
					if ((filesys->flags & OWNER) && ((newuid != item->uid)
							|| (newgid != item->gid))) {
						fret = Fchown(newname, newuid, newgid);
						if (fret != 0L) {
							err_file(rs_frstr[ALFLATTR], fret, newname);
							cont = 1;
						} else {
							item->uid = newuid;
							item->gid = newgid;
						}
					}
				} else {
					if (file && attr != item->attr) {
						Fattrib(newname, 1, attr);
						fret = (long) Fattrib(newname, 0, attr);
						if ((int) fret != attr) {
							err_file(rs_frstr[ALFLATTR], fret, newname);
							cont = 1;
						} else {
							item->attr = attr;
						}
					}
				}
				if (atfirst)
					goto dl_fileinfo1;
			}

			dl_fileinfo3:
			/* Neuen Namen eintragen */
			strcpy(item->name, name);

			/* Bei Ordnern Pfade der Verzeichnisfenster anpassen */
			if (!file) {
				strcat(oldname, "\\");
				l = (int) strlen(oldname);

				for (i = 0; i < MAX_PWIN; i++) {
					if (glob.win[i].state & WSOPEN) {
						/* Pfad */
						wpath1 = (W_PATH *) glob.win[i].user;
						if (!strncmp(oldname, wpath1->path, (long) l)) {
							strcpy(wname, newname);
							if (wpath1->path[l - 1])
								strcat(wname, &wpath1->path[l - 1]);
							strcpy(wpath1->path, wname);
							wpath_iupdate(&glob.win[i], 0);
						}
					}
				}
			}

			/* F-Taste zuweisen */
			if (!file)
				strcat(newname, "\\");
			if (fkey > 4)
				conf.fkey[fkey - 5][0] = 0;
			if (pop_fkeyfd.sel > 4)
				strcpy(conf.fkey[pop_fkeyfd.sel - 5], newname);

			/* Hotkey zuweisen */
			if (hk)
				strcpy(hk->object, newname);
		} else /* Objekt auf dem Desktop */
		{
			strcpy(icon->title, tree[FILABEL].ob_spec.tedinfo->te_ptext);
			/* F-Taste zuweisen */
			if (fkey > 4)
				conf.fkey[fkey - 5][0] = 0;
			if (pop_fkeyfd.sel > 4)
				strcpy(conf.fkey[pop_fkeyfd.sel - 5], oldname);

			/* Hotkey zuweisen */
			if (hk)
				strcpy(hk->object, oldname);
		}
	}

	/* Ggf. neuen Pfadnamen bei Verzeichnisfenstern eintragen */
	if (!file && !desk && usepar) {
		strcat(path, item->name);
		strcat(path, "\\");
	}

	tree[FIPATH - 1].ob_spec.free_string = dlstr;
	tree[FINAME - 1].ob_flags &= ~HIDETREE;
	tree[FINAME].ob_flags &= ~HIDETREE;

	if (!donext || !cont)
		mode = dmode = 0;
	pfree(wname);
	return cont;
}

/**-------------------------------------------------------------------------
 dl_groupinfo()
 
 Info Åber Gruppe anzeigen/Ñndern
 -------------------------------------------------------------------------*/
void dl_groupinfo(WININFO *win) {
	W_GRP *wgrp;
	char *title, *parent, *parobj, /**path, *name,*/ *parm; /*, *p;*/
	int fkey, done, save, ret; /*, fret;*/
	WININFO *oldwin;
	OBJECT *tree;
#if 0
	FILESYS filesys;
#endif

	parobj = pmalloc(MAX_PLEN * 3L);
	if (parobj == NULL) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		return;
	}
#if 0
	path = parobj + MAX_PLEN;
	name = path + MAX_PLEN;
#endif
	tree = rs_trindex[GROUPINFO];

	wgrp = (W_GRP *) win->user;

	pop_fkeydgi.sel = setfpop(wgrp->name);
	fkey = pop_fkeydgi.sel;

	title = tree[GITITLE].ob_spec.tedinfo->te_ptext;
	strcpy(title, wgrp->title);
	parent = tree[GIPARENT].ob_spec.tedinfo->te_ptext;
	strcpy(parent, wgrp->parent);
	str245(tree[GIFILE].ob_spec.free_string, wgrp->name);
	dial_setopt(tree, GIAUTOSAVE, SELECTED, wgrp->autosave);
	dial_setopt(tree, GIGETATTR, SELECTED, wgrp->getattr);
	dial_setopt(tree, GIAUTOCLOSE, SELECTED, wgrp->autoclose);

	save = wgrp->autosave;

	frm_start(&fi_grpinfo, conf.wdial, conf.cdial, 1);
	done = 0;
	while (!done) {
		ret = frm_dial(&fi_grpinfo, &mevent);
		switch (fi_grpinfo.exit_obj) {
		case GIHELP:
			show_help(fi_grpinfo.userinfo);
			frm_norm(&fi_grpinfo);
			break;
		case GIPARENT:
			if (ret & 0x8000U) {
				parm = "";
				if (!get_buf_entry(wgrp->parent, parobj, &parm) || !*parobj)
					strcpy(parobj, wgrp->name);
#if 0
				full2comp(parobj, path, name);
				strcat(path, "*.*");
				/* Dateiauswahl durchfÅhren */
				fselect(path, name, &fret, rs_frstr[TXPARENTSEARCH], 0, 600);
				if (fi_grpinfo.state != FST_WIN)
				frm_redraw(&fi_grpinfo, ROOT);
				/* Dateiauswahl mit "OK" beendet */
				if(fret == 1)
				{
					if ((p = strrchr(path, '\\')) != NULL)
					p[1] = 0;
					comp2full(parobj, path, name);

					/* Laufwerksbezeichnung immer gross */
					*parobj = nkc_toupper(*parobj);
					/* Bei Bedarf Schreibweise anpassen */
					fsinfo(parobj, &filesys);
					fsconv(parobj, &filesys);
#else
				if (full_fselect(parobj, NULL, "*.*", 0, rs_frstr[TXPARENTSEARCH], 0, 600, &fi_grpinfo)) {
#endif
					quote(parobj);
					strcat(parobj, parm);
					strcpy(wgrp->parent, parobj);
					frm_edstring(&fi_grpinfo, GIPARENT, parobj);
					frm_redraw(&fi_grpinfo, GIPARENT);
				}
			}
			break;
		case GIOK:
			if (!title[0]) {
				frm_alert(1, rs_frstr[ALNOLABEL], altitle, conf.wdial, 0L);
				frm_norm(&fi_grpinfo);
			} else
				done = 1;
			break;
		case GICANCEL:
			done = 1;
			break;
		}
	}
	frm_end(&fi_grpinfo);

	if (fi_grpinfo.exit_obj == GIOK) {
		strcpy(wgrp->title, title);
		if (*parent)
			*parent = nkc_toupper(*parent);
		strcpy(wgrp->parent, parent);
		wgrp->autosave = dial_getopt(tree, GIAUTOSAVE, SELECTED);
		wgrp->getattr = dial_getopt(tree, GIGETATTR, SELECTED);
		wgrp->autoclose = dial_getopt(tree, GIAUTOCLOSE, SELECTED);
		wgrp->changed = 1;
		if (save || wgrp->autosave) {
			oldwin = tb.topwin;
			tb.topwin = win;
			dl_savegrp();
			tb.topwin = oldwin;
		} else
			wgrp_title(win);

		if (fkey > 4)
			conf.fkey[fkey - 5][0] = 0;
		if (pop_fkeydgi.sel > 4)
			strcpy(conf.fkey[pop_fkeydgi.sel - 5], wgrp->name);
	}
	pfree(parobj);
}

/**------------------------------------------------------------------------
 dl_giteminfo()

 Info Åber aktuelles Gruppenobjekt anzeigen
 -------------------------------------------------------------------------*/
int dl_giteminfo(WININFO *win, WG_ENTRY *item, int donext) {
	W_GRP *wgrp;
	int done, ret, ok, fret, i, j, b, rel, gplen, cont;
	int obnum[2] = { GEENTRY, GEPARAM };
	char *p, *entry, *gpath, name[MAX_FLEN], *path, *full;
	FILESYS filesys;
	OBJECT *tree;

	tree = rs_trindex[GOBINFO];

	digob = pmalloc(sizeof(DIGOB) + MAX_PLEN * 2L);
	if (!digob) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		return 0;
	}
	path = (char *) digob + sizeof(DIGOB);
	full = path + MAX_PLEN;

	for (i = 0; i < 2; i++) {
		tree[obnum[i]].ob_spec.tedinfo->te_txtlen = 61;
		tree[obnum[i]].ob_spec.tedinfo->te_tmplen = 61;
		tree[obnum[i]].ob_spec.tedinfo->te_ptext = digob->txt[i];
		tree[obnum[i]].ob_spec.tedinfo->te_pvalid = digob->val[i];
		tree[obnum[i]].ob_spec.tedinfo->te_ptmplt = digob->tmp[i];
		for (j = 0; j < 60; j++) {
			digob->txt[i][j] = 0;
			digob->tmp[i][j] = '_';
			digob->val[i][j] = 'X';
		}
		digob->txt[i][j] = 0;
		digob->tmp[i][j] = 0;
		digob->val[i][j] = 0;
	}

	wgrp = (W_GRP *) win->user;

	if (donext)
		tree[GESKIP].ob_state &= ~DISABLED;
	else
		tree[GESKIP].ob_state |= DISABLED;

	gpath = tree[GEPATH].ob_spec.free_string;
	strcpy(gpath, wgrp->name);
	p = strrchr(gpath, '\\');
	if (p)
		p[1] = 0;
	gplen = (int) strlen(gpath);

	entry = tree[GEENTRY].ob_spec.tedinfo->te_ptext;
	strcpy(tree[GETITLE].ob_spec.tedinfo->te_ptext, item->title);
	strcpy(entry, item->name);
	strcpy(tree[GEPARAM].ob_spec.tedinfo->te_ptext, item->parm);

	dial_setopt(tree, GEPARALWAYS, SELECTED, item->paralways);
	dial_setopt(tree, GEPARALWAYS, DISABLED, item->class != EC_FILE);

	frm_start(&fi_gobinfo, conf.wdial, conf.cdial, 1);
	done = 0;
	while (!done) {
		ret = frm_dial(&fi_gobinfo, &mevent);
		switch (fi_gobinfo.exit_obj) {
		case GEHELP:
			show_help(fi_gobinfo.userinfo);
			frm_norm(&fi_gobinfo);
			break;
		case GEOK:
			ok = 1;
			if (!entry[0]) {
				frm_alert(1, rs_frstr[ALNONAME], altitle, conf.wdial, 0L);
				ok = 0;
			}
			i = 0;
			while (entry[i] && ok) {
				if (entry[i] == '*' || entry[i] == '?' || (unsigned char) entry[i] < 32 || entry[i] == 34 || entry[i] == 64) {
					frm_alert(1, rs_frstr[ALILLNAME], altitle, conf.wdial, 0L);
					ok = 0;
				}
				i++;
			}
			if (ok) {
				if (strstr(entry, "\\\\")) {
					frm_alert(1, rs_frstr[ALILLNAME], altitle, conf.wdial, 0L);
					ok = 0;
				} else {
					if (entry[(int) strlen(entry) - 1] == '\\') {
						i = 0;
						b = 0;
						while (entry[i]) {
							if (entry[i] == '\\')
								b++;
							i++;
						}
						if (b < 1) {
							frm_alert(1, rs_frstr[ALILLNAME], altitle, conf.wdial, 0L);
							ok = 0;
						}
					}
				}
			}
			if (ok) {
				if (!tree[GETITLE].ob_spec.tedinfo->te_ptext[0]) {
					frm_alert(1, rs_frstr[ALNOLABEL], altitle, conf.wdial, 0L);
					ok = 0;
				}
			}
			if (!ok)
				frm_norm(&fi_gobinfo);
			else {
				cont = 2;
				done = 1;
			}
			break;
		case GECANCEL:
			cont = 0;
			done = 1;
			break;
		case GESKIP:
			cont = 1;
			done = 1;
			break;
		case GEENTRY:
			if (ret & 0x8000) {
				if (entry[1] == ':') {
					rel = 0;
					strcpy(full, entry);
				} else {
					rel = 1;
					strcpy(full, gpath);
					if (entry[0] == '\\')
						strcat(full, &entry[1]);
					else
						strcat(full, entry);
				}
				fsinfo(full, &filesys);
				fsconv(full, &filesys);
				full2comp(full, path, name);
				if (!path[0])
					strcpy(path, gpath);
				strcat(path, "*.*");
				fselect(path, name, &fret, rs_frstr[TXOBJSEARCH], 0, 400);
				if (fret == 1) {
					/* Laufwerksbezeichnung immer gross */
					path[0] = nkc_toupper(path[0]);
					/* Bei Bedarf Schreibweise anpassen */
					fsinfo(path, &filesys);
					fsconv(path, &filesys);
					p = strrchr(path, '\\');
					if (p)
						p[1] = 0;
					comp2full(full, path, name);
					if (rel) {
						if (!strncmp(gpath, full, (long) gplen))
							frm_edstring(&fi_gobinfo, GEENTRY, &full[gplen]);
						else
							rel = 0;
					}
					if (!rel)
						frm_edstring(&fi_gobinfo, GEENTRY, full);
					frm_redraw(&fi_gobinfo, GEENTRY);
				}
			}
			break;
		}
	}
	frm_end(&fi_gobinfo);

	if (fi_gobinfo.exit_obj == GEOK) {
		strcpy(item->title, tree[GETITLE].ob_spec.tedinfo->te_ptext);
		strcpy(item->name, entry);
		if(item->name[(int)strlen(item->name)-1]!='\\') item->class=EC_FILE;
		else item->class=EC_FOLDER;
		if (item->name[1] == ':') {
			fsinfo(item->name, &filesys);
			fsconv(item->name, &filesys);
		}
		strcpy(item->parm, tree[GEPARAM].ob_spec.tedinfo->te_ptext);
		item->paralways = dial_getopt(tree, GEPARALWAYS, SELECTED);
		wgrp_eupdate(wgrp, item);
		wgrp_tree(win);
		win_redraw(win, tb.desk.x, tb.desk.y, tb.desk.w, tb.desk.h);
		win_slide(win, S_INIT, 0, 0);
		wgrp_change(win);
	}

	pfree( digob);

	return cont;
}

/**-------------------------------------------------------------------------
 dl_copy()

 Alle selektierten Objekte in den angegebenen Pfad kopieren.
 Betroffene Verzeichnisfenster werden automatisch aktualisiert.

 Optional kann auch ein String mit Objektnamen angegeben werden, der
 dann statt der aktuellen Auswahl in Thing verwendet wird.
 -------------------------------------------------------------------------*/
static int cstop;

/* Unterfunktion: Kopieren einer einzelnen Datei */

static int dl_copy_file(char *src, char *dst, int *nfiles, int *nfolders,
		unsigned long total, unsigned long *ready, int link, int del, int ren,
		int *crepl, int backup, char *dlst) {
	FILESYS sfilesys, dfilesys;
	char *ldst;
	char *lpath;
	DTA dta, *odta;
	XATTR xattr, xattr2;
	int usemint;
	unsigned long size, desize, lsize;
	unsigned int date, time, attr, dedate, detime;
	DOSTIME dtime;
	long ret, ret2;
	int exist, move;
	char *buf, *p;
	unsigned long bufsize, inlen, outlen, s;
	long fin, fout;
	int doit, done, rdone;
	int mx, my, ks, mb;
	int alret, i, stop;
	char *fmask;
	OBJECT *tree;
	int rlink = 0;

LOG((0, "dl_copy_file(%s, %s)\n", src, dst));

	ldst = pmalloc(MAX_PLEN * 2L);
	if (ldst == NULL) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		return (-1);
	}
	lpath = ldst + MAX_PLEN;
	tree = rs_trindex[RENAMEFILE];

#ifdef _DEBUG
	sprintf(almsg,"CFIL: entering dl_copy_file() ...");main_debug(almsg);
#endif

	/* Event-Handling fÅr Fensterdialog/Tastatur */
	stop = dl_waitevent();
	if (!cstop)
		cstop = stop;

	/* Auf Abbruch prÅfen und ggf. raus */
	graf_mkstate(&mx, &my, &mb, &ks);
	if ((ks & (K_LSHIFT | K_RSHIFT)) == (K_LSHIFT | K_RSHIFT) || cstop) {
		alret = frm_alert(1, rs_frstr[ALBREAK], altitle, conf.wdial, 0L);
		graf_mouse(BUSYBEE, 0L);
		dl_waitevent();
		if (alret == 1) {
			pfree(ldst);
			return -1;
		} else
			cstop = stop = 0;
	}

	/* Art der Dateisysteme ermitteln */
	fsinfo(src, &sfilesys);
	fsinfo(dst, &dfilesys);

	/* Falls Zielsystem nicht case-sensitiv, dann im Dialog zur Umbennung
	 nur Grosbuchs. */
	fmask = tree[RFDNAME].ob_spec.tedinfo->te_pvalid;
	i = 0;
	if (dfilesys.flags & (TOS | UPCASE))
		while (fmask[i]) {
			fmask[i] = 'x';
			i++;
		}
	else
		while (fmask[i]) {
			fmask[i] = 'X';
			i++;
		}

	/* Feststellen, ob innerhalb eines Laufwerk verschoben wird -
	 bei Laufwerk U: wird grundsÑtzlich keine Verschiebung innerhalb
	 eines LWs vorgenommen - hier sollte besser ein Test der
	 evtl. vorhandenen Links erfolgen, die unter MagiC!3 auch
	 auf GEMDOS-LWs vorhanden sein kînnen (und auch auf MinixFS!) */
	move = 0;
	if (del && (src[0] != 'U') && (dst[0] != 'U')) {
		if (!strncmp(src, dst, 3L))
			move = 1;
	}

	/* Datei-Attribute der Quelldatei ermitteln */
	xattr.mode = S_IFREG;
	ret = Fxattr(!dcopy->follow, src, &xattr);
	if (ret == -32L) {
		usemint = 0;
		odta = Fgetdta();
		Fsetdta(&dta);
		ret = (long) Fsfirst(src, FA_HIDDEN | FA_SYSTEM);
		Fsetdta(odta);
		fill_xattr(src, &xattr, &dta);
		size = dta.d_length;
		attr = dta.d_attrib;
		time = dta.d_time;
		date = dta.d_date;
	} else {
		usemint = 1;
		size = xattr.size;
		attr = xattr.attr;
		time = xattr.mtime;
		date = xattr.mdate;

		/*
		 * Richtiger Test, ob Frename zum Verschieben mîglich ist: Wenn das dev-
		 * Feld der XATTR-Struktur von Quelldatei und Zielverzeichnis gleich
		 * sind, kann Frename benutzt werden.
		 */
		if (ret >= 0L) {
			if (del) {
				strcpy(ldst, dst);
				strcat(ldst, ".");
				ret2 = Fxattr(0, ldst, &xattr2);
				if (ret2 >= 0L) {
					if (xattr2.dev != xattr.dev)
						move = 0;
					else
						move = ((int) xattr.dev != -1);
				}
			}
		}
	}
	if (ret < 0L) /* Bei Fehler raus */
	{
		err_file(rs_frstr[ALFLREAD], ret, src);
		pfree(ldst);
		return (int) ret;
	}
	dtime.time = time;
	dtime.date = date;

	/* Quelldatei oeffnen, falls nicht verschoben wird */
	if (!move && !link) {
		if (!dcopy->follow && ((xattr.mode & S_IFMT) == S_IFLNK))
			rlink = 1;
		else {
			fin = Fopen(src, FO_READ);
			if (fin < 0L) /* Bei Fehler raus */
			{
				err_file(rs_frstr[ALFLREAD], fin, src);
				pfree(ldst);
				return (int) fin;
			}
		}
	}

	strcpy(ldst, dst); /* Namen der Zieldatei sichern */
	p = strrchr(src, '\\');
	if (p != 0L)
		strcat(ldst, ++p);
	else {
		/* Spezieller Fall: Link eines Wurzelverzeichnisses */
		char help[2] = "C";

		help[0] = *src;
		strcat(ldst, help);
	}
	rdone = 0;

	/* Falls Zielsystem case-sens. und Quellsystem nicht, dann
	 Zieldatei in Kleinbuchstaben umwandeln */
	if ((sfilesys.flags & (TOS | UPCASE)) && !(dfilesys.flags & UPCASE)) {
		s = (int) strlen(ldst) - 1;
		while (s > 0 && ldst[s] != '\\') {
			ldst[s] = nkc_tolower(ldst[s]);
			s--;
		}
	}

#ifdef _DEBUG
	sprintf(almsg,"CFIL: source     =%s",src);main_debug(almsg);
	sprintf(almsg,"CFIL: destination=%s",ldst);main_debug(almsg);
#endif

	/* Dateinamen im Dialog aktualisieren */
	p = rs_trindex[WAITCOPY][WCSRC].ob_spec.tedinfo->te_ptext;
	str245(p, src);
	i = (int) strlen(p);
	while (i < 45) {
		p[i] = ' ';
		i++;
	}
	p = rs_trindex[WAITCOPY][WCDST].ob_spec.tedinfo->te_ptext;
	str245(p, ldst);
	i = (int) strlen(p);
	while (i < 45) {
		p[i] = ' ';
		i++;
	}
	frm_redraw(&fi_waitcopy, WCNAMES);

	dl_copy_file1:

	/* Laufwerksbezeichnung immer gross */
	ldst[0] = nkc_toupper(ldst[0]);
	/* Schreibweise der Zieldatei ggf. anpassen */
	fsconv(ldst, &dfilesys);

	/* Auf existierende Zieldatei hin prÅfen */
	doit = 1;
	exist = !file_exists(ldst, 0, &xattr2);

	/* Bei Bedarf vor dem Ueberschreiben oder fuer Umbenennen nachfragen */
	if (((backup || *crepl || strcmp(src, ldst) == 0) && exist) || (ren && !rdone)) {
		XATTR *xa;
		int ask = 1;

		/* Dialog vorbereiten */
		if (exist && strcmp(src, ldst) && (ren && rdone || !ren)) {
			xa = &xattr2;
			tree[RFTITLE].ob_spec.free_string = rs_frstr[MSDFILE];
			if (backup) {
				if ((xa->mdate == date) && (xa->mtime == time) && (xa->size == size)) {
					if (!move && !link && !rlink)
						Fclose((int) fin);
					doit = 0;
					ask = -1;
				} else if (((unsigned int) xa->mdate < date)
						|| (((unsigned int) xa->mdate == date)
								&& ((unsigned int) xa->mtime < time))) {
					ask = 0;
				}
				if ((ask < 0) && del)
					Fdelete(src);
			}
		} else {
			xa = &xattr;
			tree[RFTITLE].ob_spec.free_string = rs_frstr[MSRFILE];
		}

		/* Ggf. neuen Namen erfragen */
		if (ask == 1) {
			/* Daten der Quelldatei */
			full2comp(src, lpath, tree[RFSNAME].ob_spec.free_string);
			str230(tree[RFSPATH].ob_spec.free_string, lpath);
			prlong11(size, tree[RFSSIZE].ob_spec.free_string);
			sprintf(tree[RFSDATE].ob_spec.free_string, glob.dateformat, date & 0x001f, (date & 0x01e0) >> 5, 1980 + ((date & 0xfe00) >> 9));
			sprintf(tree[RFSTIME].ob_spec.free_string, glob.timeformat, (time & 0xf800) >> 11, (time & 0x07e0) >> 5);

			/* Daten der Zieldatei */
			desize = xa->size;
			detime = xa->mtime;
			dedate = xa->mdate;

			full2comp(ldst, lpath, tree[RFDNAME].ob_spec.tedinfo->te_ptext);
			str230(tree[RFDPATH].ob_spec.free_string, lpath);
			prlong11(desize, tree[RFDSIZE].ob_spec.free_string);
			sprintf(tree[RFDDATE].ob_spec.free_string, glob.dateformat, dedate & 0x001f, (dedate & 0x01e0) >> 5, 1980 + ((dedate & 0xfe00) >> 9));
			sprintf(tree[RFDTIME].ob_spec.free_string, glob.timeformat, (detime & 0xf800) >> 11, (detime & 0x07e0) >> 5);

			/* Bei Umbenennen gibt es kein 'Alle' */
			if (xa == &xattr)
				tree[RFALL].ob_state |= DISABLED;
			else
				tree[RFALL].ob_state &= ~DISABLED;

			/* Und ausfuehren ... */
			key_clr();
			frm_start(&fi_cren, conf.wdial, conf.cdial, 1);
			graf_mouse(ARROW, 0L);
			done = 0;
			while (!done) {
				frm_dial(&fi_cren, &mevent);
				switch (fi_cren.exit_obj) {
				case RFHELP:
					show_help(fi_cren.userinfo);
					frm_norm(&fi_cren);
					break;
				case RFALL:
				case RFOK:
					p = tree[RFDNAME].ob_spec.tedinfo->te_ptext;
					if (!*p || !valid_mask(p, 0)) {
						frm_alert(1, rs_frstr[ALILLNAME], altitle, conf.wdial, 0L);
						frm_norm(&fi_cren);
					} else {
						char temp[MAX_PLEN];

						strcpy(temp, ldst);
						p = strrchr(temp, '\\');
						*(++p) = '\0';
						strcat(temp, tree[RFDNAME].ob_spec.tedinfo->te_ptext);
						if (!strcmp(src, temp)) {
							char msg[31];

							str230(msg, src);
							sprintf(almsg, rs_frstr[ALSAME], msg);
							frm_alert(1, almsg, altitle, conf.wdial, 0L);
							frm_norm(&fi_cren);
						} else
							done = 1;
					}
					break;
				case RFNEXT:
				case RFCANCEL:
					done = 1;
					break;
				}
			}
			frm_end(&fi_cren);
			graf_mouse(BUSYBEE, 0L);
			frm_redraw(&fi_waitcopy, ROOT);

			switch (fi_cren.exit_obj) {
			case RFHELP:
				show_help(fi_cren.userinfo);
				frm_norm(&fi_cren);
				break;
			case RFALL: /* 'Alle' - Alle Dateien kopieren */
				*crepl = 0;
				/* Fall through */
			case RFOK: /* 'OK' - Datei kopieren */
				doit = 1;
				break;
			case RFNEXT: /* 'Weiter' - Datei Åberspringen */
				if (!move && !link && !rlink)
					Fclose((int) fin);
				doit = 0;
				break;
			case RFCANCEL: /* 'Abbruch' - raus */
				if (!move && !link && !rlink)
					Fclose((int) fin);
				pfree(ldst);
				return -1;
			}

			/* Nochmals pruefen, falls 'OK' */
			if (doit) {
				p = strrchr(ldst, '\\');
				if (strcmp(++p, tree[RFDNAME].ob_spec.tedinfo->te_ptext) != 0 || (exist && ren && !rdone)) {
					strcpy(p, tree[RFDNAME].ob_spec.tedinfo->te_ptext);
					rdone = 1;
					goto dl_copy_file1;
				}
			}
		} else if (ask == 0)
			doit = 1;
	}

#ifdef _DEBUG
	sprintf(almsg,"CFIL: confirmation done",src);main_debug(almsg);
	sprintf(almsg,"CFIL: new source     =%s",src);main_debug(almsg);
	sprintf(almsg,"CFIL: new destination=%s",ldst);main_debug(almsg);
#endif

	if (doit) {
		/* Ziel aktualisieren - koennte veraendert sein */
		p = rs_trindex[WAITCOPY][WCDST].ob_spec.tedinfo->te_ptext;
		str245(p, ldst);
		i = (int) strlen(p);
		while (i < 45) {
			p[i] = ' ';
			i++;
		}
		frm_redraw(&fi_waitcopy, WCDST);

		/* Laufwerke fuer Updates merken */
		i = dfilesys.biosdev;
		if (i >= 0 && i <= 31)
			dlst[i] = 1;
		if (del) {
			i = sfilesys.biosdev;
			if (i >= 0 && i <= 31)
				dlst[i] = 1;
		}

		/* Buffer fuer's Kopieren anfordern */
		buf = 0L;
		if (!link && !move) {
			bufsize = max(MAX_PLEN, size);
			lsize = 0L;

			/* Auf maximal zugelassene Groesse beschraenken */
			if (conf.cbuf > 0L && bufsize > (conf.cbuf * 1024L))
				bufsize = conf.cbuf * 1024L;

			while (!buf && bufsize > 0L) {
				buf = pmalloc(bufsize);
				if (!buf) {
					bufsize = bufsize / 2;
					if (!bufsize) /* Kein Speicher mehr, dann raus */
					{
						Fclose((int) fin);
						frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
						pfree(ldst);
						return -1;
					}
				}
			}
		}

		/* Zieldatei ggf. vorher loeschen */
		if (exist) {
			ret = (long) Fdelete(ldst);
			if (ret != 0L) {
				if (!move && !link && !rlink)
					Fclose((int) fin);
				if (buf)
					pfree(buf);
				err_file(rs_frstr[ALFLDELETE], ret, ldst);
				pfree(ldst);
				return (int) ret;
			}
		}

		if (!link && !move) /* Dateien nur kopieren, wenn nicht verschoben wird */
		{
			/* Symbolischen Link Åber Dateigrenzen als solchen kopieren */
			if (rlink) {
				/* Link auslesen ... */
				ret = Freadlink((int) min(bufsize, 32767L), buf, src);
				if (ret >= 0L) {
					/* ... und anlegen */
					ret = Fsymlink(buf, ldst);
					if (ret < 0L) {
						done = 2;
						err_file(rs_frstr[ALLCREATE], ret, ldst);
					} else
						done = 1;
				} else {
					done = 2;
					err_file(rs_frstr[ALFLREAD], ret, src);
				}
				goto d_c_f_copy_finished;
			}

			/* Zieldatei erzeugen */
			fout = Fcreate(ldst, 0);
			if (fout < 0L) /* Bei Fehler raus */
			{
				Fclose((int) fin);
				if (buf)
					pfree(buf);
				err_file(rs_frstr[ALFLWRITE], fout, ldst);
				pfree(ldst);
				return (int) fout;
			}

			/* Dateiinhalt kopieren */
			done = 0;
			while (!done) {
				inlen = Fread((int) fin, bufsize, buf);
				if (inlen <= 0L) /* Lesefehler? */
				{
					done = 1;
					ret = (int) inlen;
					if (inlen < 0L) {
						err_file(rs_frstr[ALFLREAD], inlen, src);
						done = 2;
					}
				} else {
					outlen = Fwrite((int) fout, inlen, buf);
					if (outlen != inlen) {
						done = 2;
						if (outlen >= 0L) {
							/* Kein Fehlercode - dann Speicherplatzprobleme */
							frm_alert(1, rs_frstr[ALDISKFULL], altitle, conf.wdial, 0L);
							ret = -1L;
						} else {
							/* Fehlercode - ausgeben */
							err_file(rs_frstr[ALFLWRITE], outlen, ldst);
							ret = (int) outlen;
						}
					}
				}

				/* Status-Box aktualisieren */
				lsize += inlen;
				p = rs_trindex[WAITCOPY][WCSIZE].ob_spec.tedinfo->te_ptext;
				prlong11((unsigned long) (*ready - lsize - (long) *nfolders), p);
				i = (int) strlen(p);
				while (i < 15) {
					p[i] = ' ';
					i++;
				}
				dl_copy_slupdate(total, *ready, lsize);
				frm_redraw(&fi_waitcopy, WCSIZE);

				/* Event-Handling innerhalb einer Datei */
				if (!done)
					stop = dl_waitevent();
				if (!cstop)
					cstop = stop;
			}

			/* Datum/Zeit der Quelldatei auf die Zieldatei Åbertragen */
			Fdatime(&dtime, (int) fout, 1);

			/* Dateien schliessen */
			Fclose((int) fout);
			Fclose((int) fin);

			/* Bei Fehler Zieldatei lîschen, sonst
			 Attribute der Quelldatei auf die Zieldatei Åbertragen */
			if (done == 2)
				Fdelete(ldst);
			else {
				short timebuf[4];

				/* öbertragung der "Unix"-Zeiten */
				timebuf[0] = xattr.atime;
				timebuf[1] = xattr.adate;
				timebuf[2] = xattr.mtime;
				timebuf[3] = xattr.mdate;
				Dcntl(0x4603, ldst, (long) timebuf);

				/* öbertragung der DOS-Attribute */
				Fattrib(ldst, 1, attr);
				/*
				 * Falls vorhanden und mîglich, dann Zugriffsrechte und
				 * EigentÅmer/Gruppe Åbertragen
				 */
				if (usemint) {
					if ((sfilesys.flags & OWNER) && (dfilesys.flags & OWNER))
						Fchown(ldst, xattr.uid, xattr.gid);
					if (dfilesys.flags & UNIXATTR) {
						if (sfilesys.flags & UNIXATTR)
							Fchmod(ldst, (int) (xattr.mode & 07777));
						else {
							p = strrchr(src, '\\');
							if (is_app(++p, 0)) {
								ret = Fxattr(0, ldst, &xattr2);
								if (!ret)
									Fchmod(ldst, xattr.mode | (0111 & ~glob.umask));
							}
						}
					}
				}
			}

			d_c_f_copy_finished:
			/* Falls gewÅnscht, Quelldatei lîschen */
			if (ret == 0L && del && done != 2) {
				ret = (long) Fdelete(src);
				if (ret < 0L)
					err_file(rs_frstr[ALFLDELETE], ret, src);
			}
		} else /* Dateien innerhalb eines Laufwerks verschieben oder linken */
		{
			if (link) {
				XATTR xa;

				if (!file_exists(src, 1, &xa)
						&& ((xa.mode & S_IFMT) == S_IFDIR))
					strcat(src, "\\");
				if ((ret = Fsymlink(src, ldst)) < 0L)
					err_file(rs_frstr[ALLCREATE], ret, ldst);
			} else {
				if ((ret = (long) Frename(0, src, ldst)) < 0L)
					err_file(rs_frstr[ALFLRENAME], ret, src);
			}
		}

		/* Buffer freigeben */
		if (buf)
			pfree(buf);
	} else
		ret = 0L;

#ifdef _DEBUG
	sprintf(almsg,"CFIL: copy/move/del done",src);main_debug(almsg);
	sprintf(almsg,"CFIL: new source     =%s",src);main_debug(almsg);
	sprintf(almsg,"CFIL: new destination=%s",ldst);main_debug(almsg);
#endif

	/* Status-Box aktualisieren */
	(*nfiles)--;
	*ready = *ready - size;

	p = rs_trindex[WAITCOPY][WCFILES].ob_spec.tedinfo->te_ptext;
	itoa(*nfiles, p, 10);
	i = (int) strlen(p);
	while (i < 7) {
		p[i] = ' ';
		i++;
	}

	frm_redraw(&fi_waitcopy, WCFILES);
	dl_copy_slupdate(total, *ready, 0);

	pfree(ldst);
	return (int) ret;
}

/* Unterfunktion: Kopieren eines Ordners */

/**
 *
 */
static int dl_copy_folder(char *src, char *dst, int *nfiles, int *nfolders,
		unsigned long total, unsigned long *ready, int del, int ren,
		int *crepl, int backup, char *dlst) {
	FILESYS sfilesys, dfilesys;
	char *ldst, *lsrc;
	char *lpath;
	DTA dta, dta2, *odta;
	XATTR xattr;
	long dhandle;
	char dbuf[MAX_FLEN + 4];
	int usemint;
	long ret;
	int exist, isdir;
	int doit, done, rdone, rdoit;
	char *p;
	int mfiles, mfolders, mlinks, l;
	unsigned long msize, s;
	int mx, my, ks, mb;
	int stop, alret;
	char *fmask;
	int i, whandle;
	OBJECT *tree;
	short timebuf[4];
	XATTR xa;

LOG((0, "dl_copy_folder(%s, %s)\n", src, dst));

	tree = rs_trindex[RENAMEFILE];
	if ((ldst = pmalloc(MAX_PLEN * 3L)) == NULL) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		return (-1);
	}
	lsrc = ldst + MAX_PLEN;
	lpath = lsrc + MAX_PLEN;

#ifdef _DEBUG
	sprintf(almsg,"CFLD: entering dl_copy_folder() ...");main_debug(almsg);
#endif

	/* Event-Handling fÅr Fensterdialog/Tastatur */
	stop = dl_waitevent();
	if (!cstop)
		cstop = stop;

	/* Art der Dateisysteme ermitteln */
	fsinfo(src, &sfilesys);
	fsinfo(dst, &dfilesys);

	/* Falls Zielsystem case-sensitiv, dann im Dialog zur Umbennung
	 nur Grosbuchs. */
	fmask = tree[RFDNAME].ob_spec.tedinfo->te_pvalid;
	i = 0;
	if (dfilesys.flags & (TOS | UPCASE))
		while (fmask[i]) {
			fmask[i] = 'x';
			i++;
		}
	else
		while (fmask[i]) {
			fmask[i] = 'X';
			i++;
		}

	/* Feststellen, ob ein Ordner kopiert wird */
	if (src[2] && src[3]) {
		/* Attribute des Quellordners ermitteln */
		file_exists(src, 1, &xa);
		isdir = 1;
	} else
		isdir = 0;

	/* Verzeichnis îffnen */
	rdoit = 0;
	dhandle = Dopendir(src, 0);
	if (dhandle == -32L) {
		usemint = 0;
		odta = Fgetdta();
		Fsetdta(&dta);
		strcpy(lsrc, src);
		if (isdir)
			strcat(lsrc, "\\");
		strcat(lsrc, "*.*");
		ret = (long) Fsfirst(lsrc, FA_SUBDIR | FA_HIDDEN | FA_SYSTEM);
		while (!ret && (dta.d_attrib == 0xf)) /* VFAT unter TOS ausfiltern */
			ret = Fsnext();
		if (ret == 0L) {
			rdoit = 1;
			strcpy(lsrc, src);
			if (isdir)
				strcat(lsrc, "\\");
			strcat(lsrc, dta.d_fname);
			xattr.attr = dta.d_attrib;
			xattr.size = dta.d_length;
		}
	} else {
		usemint = 1;
		if ((dhandle & 0xff000000L) != 0xff000000L)
			ret = Dreaddir(MAX_FLEN + 4, dhandle, dbuf);
		else
			ret = dhandle;
		if (ret == 0L) {
			rdoit = 1;
			strcpy(lsrc, src);
			if (isdir)
				strcat(lsrc, "\\");
			strcat(lsrc, &dbuf[4]);
			Fxattr(!dcopy->follow, lsrc, &xattr);
		}
	}

	strcpy(ldst, dst); /* Name des Zielverzeichnisses erzeugen */
	if (isdir) {
		p = strrchr(src, '\\') + 1;
		strcat(ldst, p);
	} else /* Falls Root, dann an Ziel angehÑngtes '\' entfernen */
	{
		i = 0;
		while (ldst[i])
			i++;
		if (i > 1)
			ldst[i - 1] = 0;
	}
	rdone = 0;

	/* Falls Zielsystem case-sens. und Quellsystem nicht, dann
	 in Kleinbuchstaben umwandeln */
	if ((sfilesys.flags & (TOS | UPCASE)) && !(dfilesys.flags & UPCASE)) {
		s = (int) strlen(ldst) - 1;
		while (s > 0 && ldst[s] != '\\') {
			ldst[s] = nkc_tolower(ldst[s]);
			s--;
		}
	}

#ifdef _DEBUG
	sprintf(almsg,"CFLD: source     =%s",src);main_debug(almsg);
	sprintf(almsg,"CFLD: destination=%s",ldst);main_debug(almsg);
#endif

	/* Dateinamen im Dialog aktualisieren */
	p = rs_trindex[WAITCOPY][WCSRC].ob_spec.tedinfo->te_ptext;
	str245(p, src);
	i = (int) strlen(p);
	while (i < 45) {
		p[i] = ' ';
		i++;
	}
	p = rs_trindex[WAITCOPY][WCDST].ob_spec.tedinfo->te_ptext;
	str245(p, ldst);
	i = (int) strlen(p);
	while (i < 45) {
		p[i] = ' ';
		i++;
	}
	frm_redraw(&fi_waitcopy, WCNAMES);

	dl_copy_folder1:

	/* Laufwerksbezeichnung immer gross */
	ldst[0] = nkc_toupper(ldst[0]);
	/* Schreibweise des Zielverzeichnisses ggf. anpassen */
	fsconv(ldst, &dfilesys);

	/* Bei Bedarf auf existierenden Zielordner hin prÅfen */
	doit = 1;
	exist = 0;
	if (isdir) /* Nur wenn Quellpfad kein Rootverzeichnis */
	{
		if (usemint) {
			XATTR xattr;

			if (Fxattr(0, ldst, &xattr) == 0L)
				exist = 1 + backup;
		} else {
			usemint = 0;
			Fsetdta(&dta2);
			if (Fsfirst(ldst, FA_SUBDIR | FA_HIDDEN | FA_SYSTEM) == 0)
				exist = 1 + backup;
			Fsetdta(&dta);
		}
	}

	/* Bei Bedarf vor dem öberschreiben oder fÅr Umbenennen nachfragen */
	if ((((*crepl || strcmp(src, ldst) == 0) && (exist == 1)) || (ren && !rdone)) && isdir) {
		int renam;

		/* Dialog vorbereiten */
		if ((exist == 1) && strcmp(src, ldst) && (ren && rdone || !ren)) {
			renam = 0;
			tree[RFTITLE].ob_spec.free_string = rs_frstr[MSDFOLDER];
		} else {
			renam = 1;
			tree[RFTITLE].ob_spec.free_string = rs_frstr[MSRFOLDER];
		}

		/* Name des Quellordners */
		full2comp(src, lpath, tree[RFSNAME].ob_spec.free_string);
		str230(tree[RFSPATH].ob_spec.free_string, lpath);

		/* Name des Zielordners */
		full2comp(ldst, lpath, tree[RFDNAME].ob_spec.tedinfo->te_ptext);
		str230(tree[RFDPATH].ob_spec.free_string, lpath);

		/* Attribute werden nicht angezeigt */
		tree[RFSATTR].ob_flags |= HIDETREE;
		tree[RFDATTR].ob_flags |= HIDETREE;

		/* Bei Umbenennen gibt es kein 'Alle' */
		if (renam)
			tree[RFALL].ob_state |= DISABLED;
		else
			tree[RFALL].ob_state &= ~DISABLED;

		/* Und ausfÅhren ... */
		key_clr();
		frm_start(&fi_cren, conf.wdial, conf.cdial, 1);
		graf_mouse(ARROW, 0L);
		done = 0;
		while (!done) {
			frm_dial(&fi_cren, &mevent);
			switch (fi_cren.exit_obj) {
			case RFHELP:
				show_help(fi_cren.userinfo);
				frm_norm(&fi_cren);
				break;
			case RFALL:
			case RFOK:
				p = tree[RFDNAME].ob_spec.tedinfo->te_ptext;
				if (!*p || !valid_mask(p, 0)) {
					frm_alert(1, rs_frstr[ALILLFNAME], altitle, conf.wdial, 0L);
					frm_norm(&fi_cren);
				} else
					done = 1;
				break;
			case RFNEXT:
			case RFCANCEL:
				done = 1;
				break;
			}
		}
#ifndef _NAES
		if (fi_cren.state == FST_WIN && tb.sys & SY_MAGX) {
			wind_set(fi_cren.win.handle, WF_BOTTOM, 0, 0, 0, 0);
			get_twin(&whandle);
			win_newtop(win_getwinfo(whandle));
		}
#endif
		frm_end(&fi_cren);
		graf_mouse(BUSYBEE, 0L);
		tree[RFSATTR].ob_flags &= ~HIDETREE;
		tree[RFDATTR].ob_flags &= ~HIDETREE;
		frm_redraw(&fi_waitcopy, ROOT);

		switch (fi_cren.exit_obj) {
		case RFHELP:
			show_help(fi_cren.userinfo);
			frm_norm(&fi_cren);
			break;
		case RFALL: /* 'Alle' - alle kopieren */
			*crepl = 0;
		case RFOK: /* 'OK' - Ordner verwenden */
			doit = 1;
			break;
		case RFNEXT: /* 'Weiter' - Ordner Åberspringen */
			mfiles = mfolders = 0;
			msize = 0L;
			dir_check(src, &mfiles, &mfolders, &msize, &mlinks, dcopy->follow, 0);
			msize += (long) mfolders;
			*nfiles = *nfiles - mfiles;
			*nfolders = *nfolders - mfolders;
			*ready = *ready - msize;
			/* Workaround fÅr Kopieren von Root */
			if (*nfolders < 0)
				*nfolders = 0;
			if (*ready < 0L)
				*ready = 0L;
			doit = 0;
			break;
		case RFCANCEL: /* 'Abbruch' - raus */
			if (!usemint)
				Fsetdta(odta);
			else
				Dclosedir(dhandle);
			pfree(ldst);
			return -1;
		}

		/* Nochmals prÅfen, falls 'OK' */
		if (doit) {
			p = strrchr(ldst, '\\') + 1;
			if (strcmp(p, tree[RFDNAME].ob_spec.tedinfo->te_ptext) != 0 || ((exist == 1) && ren && !rdone)) {
				strcpy(p, tree[RFDNAME].ob_spec.tedinfo->te_ptext);
				rdone = 1;
				goto dl_copy_folder1;
			}
		}
	}

#ifdef _DEBUG
	sprintf(almsg,"CFLD: confirmation done");main_debug(almsg);
	sprintf(almsg,"CFLD: new source     =%s",src);main_debug(almsg);
	sprintf(almsg,"CFLD: new destination=%s",ldst);main_debug(almsg);
#endif

	/* Auf gehts ... Zielordner ggf. erzeugen und alle EintrÑge darin
	 rekursiv kopieren */
	if (doit) {
		p = rs_trindex[WAITCOPY][WCDST].ob_spec.tedinfo->te_ptext;
		str245(p, ldst);
		i = (int) strlen(p);
		while (i < 45) {
			p[i] = ' ';
			i++;
		}
		frm_redraw(&fi_waitcopy, WCDST);

		/* Laufwerke fÅr Updates merken */
		i = dfilesys.biosdev;
		if (i >= 0 && i <= 31)
			dlst[i] = 1;
		if (del) {
			i = sfilesys.biosdev;
			if (i >= 0 && i <= 31)
				dlst[i] = 1;
		}

		/* Event-Handling fÅr Fensterdialog/Tastatur */
		stop = dl_waitevent();
		if (!cstop)
			cstop = stop;

		/* Auf Abbruch prÅfen und ggf. raus */
		graf_mkstate(&mx, &my, &mb, &ks);
		if ((ks & (K_LSHIFT | K_RSHIFT)) == (K_LSHIFT | K_RSHIFT) || cstop) {
			alret = frm_alert(1, rs_frstr[ALBREAK], altitle, conf.wdial, 0L);
			graf_mouse(BUSYBEE, 0L);
			dl_waitevent();
			if (alret == 1) {
				if (!usemint)
					Fsetdta(odta);
				else
					Dclosedir(dhandle);
				pfree(ldst);
				return -1;
			} else
				cstop = stop = 0;
		}

		if (!exist && isdir) /* Zielordner ggf. erzeugen */
		{
			ret = (long) Dcreate(ldst);
			if (ret < 0L) /* Fehler? */
			{
				err_file(rs_frstr[ALFLCREATE], ret, ldst);
				if (!usemint)
					Fsetdta(odta);
				else
					Dclosedir(dhandle);
				pfree(ldst);
				return (int) ret;
			}
		}
		/* Rekursiv alle EintrÑge bearbeiten */
		strcpy(lpath, ldst);
		strcat(lpath, "\\");
		if (rdoit)
			rdone = 0;
		else
			rdone = 1;
		while (!rdone) {
			/* Auf Abbruch prÅfen und ggf. raus */
			graf_mkstate(&mx, &my, &mb, &ks);
			if ((ks & (K_LSHIFT | K_RSHIFT)) == (K_LSHIFT | K_RSHIFT)) {
				alret = frm_alert(1, rs_frstr[ALBREAK], altitle, conf.wdial, 0L);
				graf_mouse(BUSYBEE, 0L);
				dl_waitevent();
				if (alret == 1) {
					if (!usemint)
						Fsetdta(odta);
					else
						Dclosedir(dhandle);
					pfree(ldst);
					return -1;
				} else
					cstop = stop = 0;
			}
			/* Laufwerksbezeichnung immer gross */
			lsrc[0] = nkc_toupper(lsrc[0]);
			ldst[0] = nkc_toupper(ldst[0]);
			/* Schreibweise der Dateinamen ggf. anpassen */
			fsconv(lsrc, &sfilesys);
			fsconv(ldst, &dfilesys);

			/* Standard-EintrÑge '.' und '..' nicht verwenden */
			l = (int) strlen(lsrc);
			if (strcmp(&lsrc[l - 3], "\\..") != 0
					&& strcmp(&lsrc[l - 2], "\\.") != 0) {
				if ((!usemint && (xattr.attr & FA_SUBDIR)) || (usemint && (xattr.mode & S_IFMT) == S_IFDIR)) /* Weiterer Ordner */
				{
					ret = (long) dl_copy_folder(lsrc, lpath, nfiles, nfolders, total, ready, del, ren, crepl, backup, dlst);
				} else /* Datei oder Link */
				{
					ret = (long) dl_copy_file(lsrc, lpath, nfiles, nfolders, total, ready, 0, del, ren, crepl, backup, dlst);
				}
			} else
				ret = 0L;

			if (ret != 0L)
				rdone = 1; /* Fehler? Dann abbrechen */
			else /* Noe - dann weitermachen */
			{
				if (!usemint) {
					do {
						ret = (long) Fsnext();
					} while (!ret && (dta.d_attrib == 0xf));
					strcpy(lsrc, src);
					if (isdir)
						strcat(lsrc, "\\");
					strcat(lsrc, dta.d_fname);
					xattr.attr = dta.d_attrib;
					xattr.size = dta.d_length;
				} else {
					ret = Dreaddir(MAX_FLEN + 4, dhandle, dbuf);
					strcpy(lsrc, src);
					if (isdir)
						strcat(lsrc, "\\");
					strcat(lsrc, &dbuf[4]);
					Fxattr(!dcopy->follow, lsrc, &xattr);
				}
				if (ret != 0L) {
					rdone = 1;
					/* Ggf. Fehlermeldung ausgeben */
					if (ret != -49L && ret != -33L)
						err_file(rs_frstr[ALPREAD], ret, src);
					else
						ret = 0L;
				}
			}
		}

		if (usemint)
			Dclosedir(dhandle);

		/* Falls gewÅnscht, Quell-Ordner lîschen */
		if (del && ret == 0L && isdir) {
			ret = (int) Ddelete(src);
			if (ret < 0L)
				err_file(rs_frstr[ALPDELETE], ret, src);
		}

		if (!usemint)
			Fsetdta(odta);
		else {
			if (!doit)
				Dclosedir(dhandle);
		}
		/*
		 * Zeit und Zugriffsbits erst im Anschluû kopieren, weil durch das
		 * Kopieren mdate/mtime verÑndert worden sein kann und auûerdem das
		 * Schreiben je nach Zugriffsbits Åberhaupt nicht mîglich wÑre
		 */
		if (!exist && isdir) {
			/* öbertragung der "Unix"-Zeiten */
			timebuf[0] = xa.atime;
			timebuf[1] = xa.adate;
			timebuf[2] = xa.mtime;
			timebuf[3] = xa.mdate;
			Dcntl(0x4603, ldst, (long) timebuf);
			/* Attribute Åbertragen */
			if (usemint) {
				if ((sfilesys.flags & UNIXATTR) && (dfilesys.flags & UNIXATTR))
					Fchmod(ldst, (int) (xa.mode & 07777));
				if ((sfilesys.flags & OWNER) && (dfilesys.flags & OWNER))
					Fchown(ldst, xa.uid, xa.gid);
			}
		}
	}

	/* Status-Box aktualisieren */
	(*nfolders)--;
	(*ready)--;
	/* Workaround fÅr Kopieren von Root */
	if (*nfolders < 0)
		*nfolders = 0;
	if (*ready < 0L)
		*ready = 0L;

	p = rs_trindex[WAITCOPY][WCFILES].ob_spec.tedinfo->te_ptext;
	itoa(*nfiles, p, 10);
	i = (int) strlen(p);
	while (i < 7) {
		p[i] = ' ';
		i++;
	}
	p = rs_trindex[WAITCOPY][WCFOLDERS].ob_spec.tedinfo->te_ptext;
	itoa(*nfolders, p, 10);
	i = (int) strlen(p);
	while (i < 7) {
		p[i] = ' ';
		i++;
	}
	p = rs_trindex[WAITCOPY][WCSIZE].ob_spec.tedinfo->te_ptext;
	prlong11((unsigned long) (*ready - (long) *nfolders), p);
	i = (int) strlen(p);
	while (i < 15) {
		p[i] = ' ';
		i++;
	}
	dl_copy_slupdate(total, *ready, 0);
	frm_redraw(&fi_waitcopy, WCFILES);
	frm_redraw(&fi_waitcopy, WCFOLDERS);
	frm_redraw(&fi_waitcopy, WCSIZE);

#ifdef _DEBUG
	sprintf(almsg,"CFLD: copy/move/del done");main_debug(almsg);
	sprintf(almsg,"CFLD: (no names available now)");main_debug(almsg);
#endif
	pfree(ldst);
	return (int) ret;
}

/**
 *  Unterfunktion: Neuberechnung der Slidergrîûe
 */
static void dl_copy_slupdate(unsigned long total, unsigned long ready,
		unsigned long size) {
	double rel;
	long s;

	rel = (double) (total - ready + size) / (double) total;
	s = (long) ((double) rs_trindex[WAITCOPY][WCBOX].ob_width * rel);
	if (s < 1L)
		s = 1L;
	if (s > (long) rs_trindex[WAITCOPY][WCBOX].ob_width)
		s = (long) rs_trindex[WAITCOPY][WCBOX].ob_width;
	rs_trindex[WAITCOPY][WCSLIDE].ob_width = (int) s;

	frm_redraw(&fi_waitcopy, WCSLIDE);
}

/**
 *  Unterfunktion: BestÑtigung fÅr's Kopieren
 */
static void dl_copy_conf_mode(OBJECT *tree, int mode) {
	tree[CPCOPY].ob_state &= ~SELECTED;
	tree[CPLINK].ob_state &= ~SELECTED;
	tree[CPMOVE].ob_state &= ~DISABLED;
	tree[CPFOLLOW].ob_state &= ~DISABLED;
	tree[CPBACKUP].ob_state &= ~DISABLED;
	if (mode == 2) {
		tree[CPLINK].ob_state |= SELECTED;
		tree[CPMOVE].ob_state |= DISABLED;
		tree[CPFOLLOW].ob_state |= DISABLED;
		tree[CPBACKUP].ob_state |= DISABLED;
	} else
		tree[CPCOPY].ob_state |= SELECTED;
}

/**
 *
 */
static void dl_copy_conf(int *ok, int *del, int *ren, char *path,
		unsigned long size, int nfiles, int nfolders, int src, int *mode,
		int *follow, int *backup) {
	int done;
	OBJECT *tree;
	FILESYS fs;

	tree = rs_trindex[COPY];

	dial_setopt(tree, CPMOVE, SELECTED, *del);
	dial_setopt(tree, CPRENAME, SELECTED, *ren);
	dial_setopt(tree, CPFOLLOW, SELECTED, *follow);
	dial_setopt(tree, CPBACKUP, SELECTED, *backup);

	if (src == -1) {
		tree[CPSOURCE].ob_flags |= HIDETREE;
		tree[CPSOURCET].ob_flags |= HIDETREE;
	} else {
		tree[CPSOURCE].ob_flags &= ~HIDETREE;
		tree[CPSOURCET].ob_flags &= ~HIDETREE;
		tree[CPSOURCE].ob_spec.tedinfo->te_ptext[0] = (char) src + 65;
	}
	tree[CPDEST].ob_spec.tedinfo->te_ptext[0] = path[0];
	prlong11(size, tree[CPSIZE].ob_spec.free_string);
	sprintf(tree[CPFILES].ob_spec.free_string, "%-6d", nfiles);
	sprintf(tree[CPFOLDERS].ob_spec.free_string, "%-6d", nfolders);

	dl_copy_conf_mode(tree, *mode);

	fsinfo(path, &fs);
	if (fs.flags & SYMLINKS) {
		tree[CPCOPY].ob_flags |= TOUCHEXIT | SELECTABLE;
		tree[CPCOPY].ob_state &= ~DISABLED;
		tree[CPLINK].ob_flags |= TOUCHEXIT | SELECTABLE;
		tree[CPLINK].ob_state &= ~DISABLED;
		tree[CPFOLLOW].ob_state &= ~DISABLED;
	} else {
		tree[CPCOPY].ob_flags &= ~(TOUCHEXIT | SELECTABLE);
		tree[CPCOPY].ob_state |= DISABLED;
		tree[CPLINK].ob_flags &= ~(TOUCHEXIT | SELECTABLE);
		tree[CPLINK].ob_state |= DISABLED;
		tree[CPFOLLOW].ob_state |= DISABLED;
	}

	frm_start(&fi_copy, conf.wdial, conf.cdial, 1);
	done = 0;
	while (!done) {
		frm_dial(&fi_copy, &mevent);
		switch (fi_copy.exit_obj) {
		case CPOK:
		case CPCANCEL:
			done = 1;
			break;
		case CPCOPY:
			if (*mode == 2) {
				dl_copy_conf_mode(tree, *mode = 0);
				frm_redraw(&fi_copy, CPOPTBOX);
			}
			break;
		case CPLINK:
			if (*mode != 2) {
				dl_copy_conf_mode(tree, *mode = 2);
				frm_redraw(&fi_copy, CPOPTBOX);
			}
			break;
		case CPHELP:
			show_help(fi_copy.userinfo);
			frm_norm(&fi_copy);
			break;
		}
	}
	frm_end(&fi_copy);
	if (fi_copy.exit_obj == CPOK)
		*ok = 1;
	else
		*ok = 0;
	*del = dial_getopt(tree, CPMOVE, SELECTED);
	*ren = dial_getopt(tree, CPRENAME, SELECTED);
	*follow = dial_getopt(tree, CPFOLLOW, SELECTED);
	*backup = dial_getopt(tree, CPBACKUP, SELECTED);
	*mode = 2 * !dial_getopt(tree, CPCOPY, SELECTED);
}

/**
 *  Unterfunktion: Copy/Move-Befehl fÅr Kobold erzeugen
 */
static void dl_copy_kcmd(int del, int ren, char *kcmd) {
	strcpy(kcmd, "SRC_SELECT \\\n");
	if (del)
		strcat(kcmd, "MOVE ");
	else
		strcat(kcmd, "COPY ");
	if (!(conf.kbd_two & 1))
		strcat(kcmd, "OPEN_FOLDERS ");
	strcat(kcmd, "KEEP_FLAGS");
	if (ren)
		strcat(kcmd, " RENAME");
	strcat(kcmd, "\nSRC_SELECT ?\n");
}

/**
 * Unterfunktion: Umfang der Daten ermitteln, abhÑngig von
 * Linkverfolgung
 */
static int dl_copy_size(char *buf, char *dpath, int *nfiles, int *nfolders,
		unsigned long *size, int *nlinks, int *kdrv, int follow, int mode) {
	int j, ok;
	char name[MAX_PLEN], *bufpos;

	*nfiles = *nfolders = *nlinks = 0;
	*size = 0L;
	*kdrv = -2;
	ok = 1;
	bufpos = buf;
	while (get_buf_entry(bufpos, name, &bufpos) && ok) {
		j = (int) strlen(name);
		if (name[j - 1] == '\\') {
			/* Unzulaessige Operationen abfangen */
			if (!strncmp(dpath, name, strlen(name)))
				return (-1);
		}
		ok = !dir_check(name, nfiles, nfolders, size, nlinks, follow, (mode == 2) ? -1 : 0);

		/* Quelle merken */
		if (*kdrv == -2)
			*kdrv = name[0];
		else {
			if (*kdrv != name[0])
				*kdrv = -1;
		}
	}
	return (ok);
}

/* Und hier die eigentliche Funktion */

/**
 *
 */
int dl_copy(char *path, int ks, char *buf) {
	int i, j, ok, go, isf;
	char ipath[MAX_PLEN], iname[MAX_FLEN];
	char kcmd[100], kstr[MAX_CLEN];
	char *readbuf;
	int kdrv, kdrv1, kuse;
	int whandle;
	OBJECT *tree;
	int nlinks;
	FILESYS dfs;

	tree = rs_trindex[WAITCOPY];

	/* Mehrfaches Kopieren nicht moeglich! */
	if (glob.sm_copy) {
		if (fi_waitcopy.open && fi_waitcopy.state == FST_WIN)
			win_top(&fi_waitcopy.win);
		mybeep();
		return 0;
	}

	dcopy = pmalloc(sizeof(DCOPY));
	if (!dcopy) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		return 0;
	}
	glob.sm_copy = 1;
	cstop = 0;

#ifdef _DEBUG
	sprintf(almsg,"COPY: dcopy.init ok");main_debug(almsg);
#endif

	dcopy->mode = 0;
	dcopy->backup = 0;
	dcopy->avid = -1;
	dcopy->follow = 0;
	dcopy->j_step = 0;
	dcopy->stack = dcopy->curr = 0L;
	dcopy->bsrc = dcopy->bdst = 0L;
	dcopy->infh = dcopy->outfh = -1L;
	dcopy->buf = 0L;
	dcopy->buflen = 0L;
	for (i = 0; i < 32; i++)
		dcopy->dlst[i] = 0;

	ok = 0;
	lbuf = 0L;

	/*
	 * Entsprechend dem Tastaturstatus die Optionen 'Originale Loeschen',
	 * 'Kopien umbenennen', 'Links verfolgen' und 'Links anlegen'
	 * setzen
	 */
	if (ks & K_CTRL)
		dcopy->del = 1;
	else
		dcopy->del = 0;
	if (ks & K_ALT)
		dcopy->ren = 1;
	else
		dcopy->ren = 0;
	if (ks & K_RSHIFT)
		dcopy->follow ^= 1;
	if (ks & K_LSHIFT) {
		dcopy->mode = 2;
		dcopy->follow = 0;
	}

#ifdef _DEBUG
	sprintf(almsg,"COPY: mode.delete=%d, mode.rename=%d",dcopy->del,dcopy->ren);main_debug(almsg);
#endif

	/* String mit Objektnamen angegeben? */
	if (buf) {
		ok = 1;
#ifdef _DEBUG
		sprintf(almsg,"COPY: buffer -- START, contents=%s",buf);main_debug(almsg);
#endif
		dl_copy_buf: kdrv = -2;
		go = 1;
		graf_mouse(BUSYBEE, 0L);

		/* Stack aufbauen */
		go = dl_copy_size(buf, path, &dcopy->nfiles, &dcopy->nfolders, &dcopy->size, &nlinks, &kdrv, dcopy->follow, dcopy->mode);

		fsinfo(path, &dfs);
		if (!(dfs.flags & SYMLINKS)) {
			if ((dcopy->mode == 2) || (nlinks && !dcopy->follow)) {
				dcopy->mode = 0;
				dcopy->follow = 1;
				go = dl_copy_size(buf, path, &dcopy->nfiles, &dcopy->nfolders, &dcopy->size, &nlinks, &kdrv, dcopy->follow, dcopy->mode);
			}
		}

		if (kdrv == -2)
			kdrv = -1;
		else {
			if (kdrv >= 65)
				kdrv -= 65;
		}

		graf_mouse(ARROW, 0L);

		/* Wenn keine Objekte zum Kopieren vorhanden sind (z.B. leere
		 Laufwerke oder Desktop-Icons, zu denen die Dateien/Ordner nicht
		 physikalisch vorhanden sind), dann Fehlermeldung und Abbruch */
		if ((go < 1) || ((dcopy->nfiles + dcopy->nfolders) < 1)) {
			if (!go)
				frm_alert(1, rs_frstr[ALNOOBJ], altitle, conf.wdial, 0L);
			else
				frm_alert(1, rs_frstr[ALILLACT], altitle, conf.wdial, 0L);
			glob.sm_copy = 0;
			pfree( dcopy);
			dcopy = 0L;
			if (lbuf) {
				pfree( lbuf);
				lbuf = 0L;
			}
			return 0;
		}

		/* Auf Kobold pruefen */
		if (conf.kbc_use && (dcopy->mode != 2) && !dcopy->follow && (dcopy->nfiles >= conf.kbc_files || (dcopy->size / 1024L) >= conf.kbc_size))
			kuse = 1;
		else
			kuse = 0;
		if (kuse && conf.kb_tosonly) {
			FILESYS fs;

			fsinfo(path, &fs);
			if ((fs.flags & (TOS | UPCASE)) != (TOS | UPCASE))
				kuse = 0;
			else {
				readbuf = buf;
				while (get_buf_entry(readbuf, ipath, &readbuf)) {
					fsinfo(ipath, &fs);
					if ((fs.flags & (TOS | UPCASE)) != (TOS | UPCASE)) {
						kuse = 0;
						break;
					}
				}
			}
		}

		/* Ggf. Bestaetigung fuers Kopieren */
		if (go && !kuse && conf.ccopy) {
			int omode = dcopy->mode, ofollow = dcopy->follow;

			dl_copy_conf(&ok, &dcopy->del, &dcopy->ren, path, dcopy->size, dcopy->nfiles, dcopy->nfolders, kdrv, &dcopy->mode, &dcopy->follow, &dcopy->backup);
			if (dcopy->mode == 2)
				dcopy->follow = 0;
			if (ok && ((dcopy->follow != ofollow) || (dcopy->mode != omode))) {
				go = dl_copy_size(buf, path, &dcopy->nfiles, &dcopy->nfolders, &dcopy->size, &nlinks, &kdrv, dcopy->follow, dcopy->mode);
			}
		}
		/* Kobold-Job */
		if (kuse) /* Kobold ueberhaupt verwenden? */
		{
			graf_mouse(BUSYBEE, 0L);

			/* Copy/Move-Befehl fuer Kobold erzeugen */
			dl_copy_kcmd(dcopy->del, dcopy->ren, kcmd);

			/* Job anlegen */
			if (kbd_newjob()) {
				kdrv = kdrv1 = -1;
				kbd_addcmd("* Thing\n");
				if (!conf.ccopy && !conf.creplace)
					kbd_addcmd("DIALOG_LEVEL = 0\n");
				else {
					if (conf.ccopy)
						kbd_addcmd("DIALOG_LEVEL = 2\n");
					else
						kbd_addcmd("DIALOG_LEVEL = 1\n");
				}
				kbd_addcmd("DATE = KEEP\nSOURCE_TREATMENT = 1\n");
				sprintf(kstr, "DST_SELECT %s\n", path);
				kbd_addcmd(kstr);

				i = 0;
				readbuf = buf;
				while (get_buf_entry(readbuf, ipath, &readbuf)) {
					j = (int) strlen(ipath);
					if (ipath[j - 1] == '\\')
						j--;
					ipath[j] = 0;
					ipath[0] = nkc_toupper(ipath[0]);
					kdrv = ipath[0];
					if (kdrv1 == -1) {
						kdrv1 = kdrv;
						sprintf(kstr, "SRC_SELECT %c:\\\n", ipath[0]);
						kbd_addcmd(kstr);
					} else {
						if (kdrv != kdrv1) {
							kdrv1 = kdrv;
							kbd_addcmd(kcmd);
							sprintf(kstr, "SRC_SELECT %c:\\\n", ipath[0]);
							kbd_addcmd(kstr);
						}
					}
					/*
					 * Wenn es das Wurzelverzeichnis ist, mit CHOOSE arbeiten,
					 * sonst mit SRC_SELECT
					 */
					if (ipath[2]) {
						if (!(conf.kbd_two & 2))
							quote(&ipath[2]);
						sprintf(kstr, "SRC_SELECT + %s\n", &ipath[2]);
						kbd_addcmd(kstr);
					} else
						kbd_addcmd("CHOOSE *+\n");
				}
				kbd_addcmd(kcmd);
				kbd_addcmd("DIALOG_LEVEL = 0\nDST_SELECT ?\nSRC_SELECT ?\n");

				/* Job ausfuehren */
				kbd_startjob();
			}
			graf_mouse(ARROW, 0L);
			ok = 0;
		}

		/* Nicht mit Kobold kopiert - dann ... auf gehts ... */
		if (ok && go) {
			dcopy->total = dcopy->ready = dcopy->size + (long) dcopy->nfolders;
			dcopy->crepl = conf.creplace;
#ifdef _DEBUG
			sprintf(almsg,"COPY: no kobold copy, starting normal");main_debug(almsg);
			sprintf(almsg,"COPY: total=%ld, nfolders=%d",dcopy->total,dcopy->nfolders);main_debug(almsg);
#endif

			/* Status-Box vorbereiten und ausgeben */
			if (dcopy->mode == 2)
				strcpy(tree[WCTEXT].ob_spec.free_string, rs_frstr[MSLINK1]);
			else {
				if (dcopy->del)
					strcpy(tree[WCTEXT].ob_spec.free_string, rs_frstr[MSMOVE1]);
				else
					strcpy(tree[WCTEXT].ob_spec.free_string, rs_frstr[MSCOPY1]);
			}
			itoa(dcopy->nfiles, tree[WCFILES].ob_spec.tedinfo->te_ptext, 10);
			itoa(dcopy->nfolders, tree[WCFOLDERS].ob_spec.tedinfo->te_ptext, 10);
			prlong((unsigned long) (dcopy->total - (long) dcopy->nfolders), tree[WCSIZE].ob_spec.tedinfo->te_ptext);
			tree[WCSRC].ob_spec.tedinfo->te_ptext[0] = 0;
			tree[WCDST].ob_spec.tedinfo->te_ptext[0] = 0;
			tree[WCSLIDE].ob_width = 1;
			frm_start(&fi_waitcopy, conf.wdial, conf.cdial, 1);
			if (fi_waitcopy.state == FST_WIN)
				frm_redraw(&fi_waitcopy, ROOT);
			graf_mouse(BUSYBEE, 0L);

			/* Kopieren */
			i = 0;
			readbuf = buf;
			while (get_buf_entry(readbuf, ipath, &readbuf) && ok) {
				XATTR xattr;

				j = (int) strlen(ipath);
				if (ipath[j - 1] == '\\')
					j--;
				if (j > 2)
					ipath[j] = 0;
				xattr.mode = S_IFREG;
				file_exists(ipath, dcopy->follow, &xattr);
				isf = ((xattr.mode & S_IFMT) == S_IFDIR);

				if (dcopy->mode != 2) {
					if (!isf) {
#ifdef _DEBUG
						sprintf(almsg,"COPY: dl_copy_file(), mode=FILE, ipath=%s, path=%s",ipath,path);main_debug(almsg);
#endif
						if (dl_copy_file(ipath, path, &dcopy->nfiles,
								&dcopy->nfolders, dcopy->total, &dcopy->ready,
								0, dcopy->del, dcopy->ren, &dcopy->crepl,
								dcopy->backup, dcopy->dlst) != 0) {
							ok = 0;
						}
					} else {
#ifdef _DEBUG
						sprintf(almsg,"COPY: dl_copy_file(), mode=PATH, ipath=%s, path=%s",ipath,path);main_debug(almsg);
#endif
						if (dl_copy_folder(ipath, path, &dcopy->nfiles,
								&dcopy->nfolders, dcopy->total, &dcopy->ready,
								dcopy->del, dcopy->ren, &dcopy->crepl,
								dcopy->backup, dcopy->dlst) != 0) {
							ok = 0;
						}
					}
				} else {
					if (isf) {
						dcopy->nfolders--;
						dcopy->ready--;
						dcopy->nfiles++;
					}
					ok = !dl_copy_file(ipath, path, &dcopy->nfiles,
							&dcopy->nfolders, dcopy->total, &dcopy->ready, 1,
							0, dcopy->ren, &dcopy->crepl, dcopy->backup,
							dcopy->dlst);
				}
			}

			/* Status-Box wieder entfernen und Verzeichnis aktualisieren */
			frm_end(&fi_waitcopy);

			/* Aktives Fenster neu ermitteln - koennte veraendert sein! */
			get_twin(&whandle);
			tb.topwin = win_getwinfo(whandle);
			win_newtop(tb.topwin);

			graf_mouse(ARROW, 0L);
			for (i = 0; i < MAX_PWIN; i++)
				if (glob.win[i].state & WSOPEN) {
					/* VerÑnderte Laufwerke aktualisieren */
					j = ((W_PATH *) glob.win[i].user)->filesys.biosdev;
					if (j >= 0 && j <= 31) {
						if (dcopy->dlst[j]) {
							wpath_update(&glob.win[i]);
							win_redraw(&glob.win[i], tb.desk.x, tb.desk.y, tb.desk.w, tb.desk.h);
							win_slide(&glob.win[i], S_INIT, 0, 0);
						}
					}
				}
		}

		/* Und raus */
		glob.sm_copy = 0;
		pfree( dcopy);
		dcopy = 0L;
		if (lbuf) {
			pfree( lbuf);
			lbuf = 0L;
		}
		mn_update();

		return ok;
	}

	/* Kein Buffer angegeben - dann selber erzeugen */
	ok = 0;
	lbuf = pmalloc(MAX_KBDLEN);
	if (lbuf) {
		ok = sel2buf(lbuf, iname, ipath, (int) MAX_KBDLEN);
		if (ok) {
			buf = lbuf;
			goto dl_copy_buf;
		}
	}
	if (lbuf) {
		pfree( lbuf);
		lbuf = 0L;
	}
	if (!ok) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		glob.sm_copy = 0;
		pfree( dcopy);
		dcopy = 0L;
	}

	return ok;
}

/**-------------------------------------------------------------------------
 dl_devout()

 Ausgabe einer Datei Åber ein Device
 -------------------------------------------------------------------------*/
int dl_devout(char *file, char *dev) {
	long infh, outfh, inlen, outlen;
	unsigned long bufsize;
	char *buf, *p, *pd;
	int done, cret, copen;

	pd = strrchr(dev, '\\');
	pd = &pd[1];

	/* PrÅfen, ob Ausgabe Åber das Device Åberhaupt geht */
	outfh = Fopen(dev, FO_WRITE);
	if (outfh < 0L) /* Und ggf. mosern */
	{
		err_file(rs_frstr[ALNOOUTPUT], outfh, dev);
		return 0;
	}

	/* Nochmal nachfragen und ausgeben */
	p = strrchr(file, '\\');
	p = &p[1];
	sprintf(almsg, rs_frstr[ALDOOUTPUT], p, pd);
	if (frm_alert(1, almsg, altitle, conf.wdial, 0L) == 1) {
		copen = cret = 0;

		/* Buffer einrichten */
		buf = 0L;
		bufsize = 1024L * 64L;
		while (!buf && bufsize > 0L) {
			buf = pmalloc(bufsize);
			if (!buf) {
				bufsize = bufsize / 2;
				if (!bufsize) /* Kein Speicher mehr, dann raus */
				{
					Fclose((int) outfh);
					frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
					return 0;
				}
			}
		}

		/* Datei îffnen */
		infh = Fopen(file, FO_READ);
		if (infh < 0L) {
			pfree(buf);
			Fclose((int) outfh);
			err_file(rs_frstr[ALFLOPEN], infh, file);
			return 0;
		}

		/* Dateiinhalt auf dem Device ausgeben */
		graf_mouse(BUSYBEE, 0L);
		done = 0;
		while (!done) {
			inlen = Fread((int) infh, bufsize, buf);
			if (inlen < 0L) {
				Fclose((int) infh);
				pfree(buf);
				Fclose((int) outfh);
				graf_mouse(ARROW, 0L);
				if (cret > 0)
					cwin_endio();
				err_file(rs_frstr[ALFLREAD], inlen, file);
				if (!copen && cret > 0)
					cwin_close();
				return 0;
			}
			if (inlen > 0L) {
				outlen = Fwrite((int) outfh, inlen, buf);
				if (outlen != inlen) {
					Fclose((int) infh);
					pfree(buf);
					Fclose((int) outfh);
					if (outlen >= 0L)
						outlen = -36L;
					graf_mouse(ARROW, 0L);
					if (cret > 0)
						cwin_endio();
					err_file(rs_frstr[ALDEVWRITE], outlen, pd);
					if (!copen && cret > 0)
						cwin_close();
					return 0;
				}
			} else
				done = 1;
		}
		Fclose((int) infh);
		pfree(buf);
		Fclose((int) outfh);
		graf_mouse(ARROW, 0L);
		if (cret > 0)
			cwin_endio();
		if (!copen && cret > 0)
			cwin_close();
		return 1;
	} else {
		Fclose((int) outfh);
		return 0;
	}
}

/**-------------------------------------------------------------------------
 dl_waitevent()

 Verarbeiten von Events fÅr die Status-Anzeige im Fenster
 -------------------------------------------------------------------------*/
int dl_waitevent(void) {
	int ret, tlo, thi, mf;

	mf = mevent.ev_mflags;
	tlo = mevent.ev_mtlocount;
	thi = mevent.ev_mthicount;
	mevent.ev_mflags = MU_KEYBD | MU_BUTTON | MU_MESAG | MU_TIMER;
	mevent.ev_mtlocount = 10;
	mevent.ev_mthicount = 0;

	ret = 0;
	EvntMulti(&mevent);
	frm_do(&fi_waitcopy, &mevent);
	if (!fi_waitcopy.cont) {
		switch (fi_waitcopy.exit_obj) {
		case WCHELP:
			frm_norm(&fi_waitcopy);
			show_help(fi_waitcopy.userinfo);
			break;
		case WCCANCEL:
			frm_norm(&fi_waitcopy);
			ret = 1;
			break;
		}
	}
	if (mevent.ev_mwich & MU_MESAG)
		frm_event(&fi_waitcopy, &mevent);

	mevent.ev_mflags = mf;
	mevent.ev_mtlocount = tlo;
	mevent.ev_mthicount = thi;

	return ret;
}

/**
 * dl_drag_on_gitem
 *
 * Behandelt D&D selektierter Objekte auf Gruppenobjekte.
 *
 * Eingabe:
 * wgrp: Zeiger auf Gruppe
 * gitem: Zeiger auf betroffenes Gruppenobjekt
 * ks: Status der Sondertasten
 * rex: Zeiger auf int, in dem im Anschluû ein Wert ungleich Null
 *      zu finden ist, wenn Thing beim Start eines Programms
 *      "teilausgelagert" wurde (SingleTOS)
 *
 * RÅckgabe:
 * 0: Fehler aufgetreten
 * sonst: Alles klar
 */
int dl_drag_on_gitem(W_GRP *wgrp, WG_ENTRY *gitem, int ks, int *rex) {
	int fin, i, cont;
	APPLINFO *aptr, app;
	char *name, *apath, aname[MAX_FLEN];

	fin = *rex = 0;
	name = pmalloc(MAX_PLEN * 2L);
	if (name == NULL) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		return (0);
	}
	apath = name + MAX_PLEN;

	wgrp_eabs(wgrp, gitem, name);
	if (gitem->class==EC_FILE) /* D&D auf ein Programm */
	{
		/* Indirektes Ziel? */
		if (!wgrp->getattr)
			gitem->aptype = is_appl(name);
		if (!gitem->aptype) {
			aptr = app_isdrag(name);
			if (aptr) {
				/* Zieldatei zusammen mit Objekten Åbergeben */
				strcpy(glob.cmd, name);
				strcat(glob.cmd, " ");
				i = (int) strlen(glob.cmd);
				cont = sel2buf(&glob.cmd[i], aname, apath, MAX_CMDLEN - i);
				if (cont)
					fin = app_start(aptr, glob.cmd, apath, rex);
				else {
					sprintf(almsg, rs_frstr[ALTOOMANY], aptr->title);
					frm_alert(1, almsg, altitle, conf.wdial, 0L);
				}
			}
		} else {
			int always;

			always = gitem->paralways;
			if (ks & K_ALT)
				always = !always;
			/* Als Applikation angemeldet ? */
			aptr = app_find(name);
			/* Nein */
			if (!aptr) {
				strcpy(app.name, name);
				app_default(&app);
				strcpy(app.title, gitem->title);
				if (always)
					strcpy(app.parm, gitem->parm);
				aptr = &app;
			} else {
				if (always) {
					memcpy(&app, aptr, sizeof(APPLINFO));
					strcpy(app.parm, gitem->parm);
					aptr = &app;
				}
			}
			/* Alle selektierten Objekte als Kommandozeile Åbergeben */
			cont = sel2buf(glob.cmd, aname, apath, MAX_CMDLEN);
			if (cont)
				fin = app_start(aptr, glob.cmd, apath, rex);
			else {
				sprintf(almsg, rs_frstr[ALTOOMANY], aptr->title);
				frm_alert(1, almsg, altitle, conf.wdial, 0L);
			}
		}
	} else /* D&D auf einen Ordner */
	{
		fin = dl_copy(name, ks, 0L);
	}
	pfree(name);
	return (fin);
}

/**
 * dl_drag_on_ditem
 *
 * Behandelt D&D selektierter Objekte auf Verzeichnisobjekte.
 *
 * Eingabe:
 * wpath: Zeiger auf Verzeichnis
 * item: Zeiger auf betroffenes Verzeichnisobjekt
 * ks: Status der Sondertasten
 * rex: Zeiger auf int, in dem im Anschluû ein Wert ungleich Null
 *      zu finden ist, wenn Thing beim Start eines Programms
 *      "teilausgelagert" wurde (SingleTOS)
 *
 * RÅckgabe:
 * 0: Fehler aufgetreten
 * sonst: Alles klar
 */
int dl_drag_on_ditem(W_PATH *wpath, WP_ENTRY *item, int ks, int *rex) {
	char *name, *iname, *apath, aname[MAX_FLEN];
#if 0
	int cont;
#endif
	int fin, i;
#if 0
	APPLINFO *aptr,
	app;
#endif

	name = pmalloc(MAX_PLEN * 3L);
	if (name == NULL) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		return (0);
	}
	iname = name + MAX_PLEN;
	apath = iname + MAX_PLEN;

	if (!item) /* Kein Objekt - dann Kopieren in das Verzeichnis */
	{
		strcpy(name, wpath->path);
		fin = dl_copy(name, ks, 0L);
	} else {
		if (item->class==EC_FILE) /* Drag&Drop auf ein Programm */
		{
			strcpy(iname, wpath->path);
			strcat(iname, item->name);
#if 1
			fin = dl_runapp(iname, item->aptype, item->name, rex);
#else
			/* Indirektes Ziel? */
			if(!item->aptype)
			{
				aptr=app_isdrag(iname);
				if(aptr)
				{
					/* Zieldatei zusammen mit Objekten Åbergeben */
					strcpy(glob.cmd,iname);strcat(glob.cmd," ");
					i=(int)strlen(glob.cmd);
					cont=sel2buf(&glob.cmd[i],aname,apath,MAX_CMDLEN-i);
					if(cont) fin=app_start(aptr,glob.cmd,apath,rex);
					else
					{
						sprintf(almsg,rs_frstr[ALTOOMANY],aptr->title);
						frm_alert(1,almsg,altitle,conf.wdial,0L);
					}
				}
			}
			else
			{
				/* Als Applikation angemeldet ? */
				aptr=app_find(iname);
				/* Nein */
				if(!aptr)
				{
					strcpy(app.name,iname);
					app_default(&app);
					strcpy(app.title,item->name);
					aptr=&app;
				}
				/* Alle selektierten Objekte als Kommandozeile Åbergeben */
#ifdef ARNO_ORIGINAL
				cont=sel2buf(glob.cmd,aname,apath,MAX_CLEN);
#else
				cont=sel2buf(glob.cmd,aname,apath,MAX_CMDLEN);
#endif
				if(cont) fin=app_start(aptr,glob.cmd,apath,rex);
				else
				{
					sprintf(almsg,rs_frstr[ALTOOMANY],aptr->title);
					frm_alert(1,almsg,altitle,conf.wdial,0L);
				}
			}
#endif
		} else /* Device oder Ordner */
		{
			if (item->class==EC_DEVICE) {
				sel2buf(glob.cmd, aname, apath, MAX_CMDLEN);
				get_buf_entry(glob.cmd, name, NULL);
				strcpy(iname, wpath->path);
				strcat(iname, item->name);
				fin = dl_devout(name, iname);
			} else {
				strcpy(name, wpath->path);
				if (item->class==EC_PARENT) {
					i = (int) strlen(name) - 2;
					while (name[i] != '\\')
						i--;
					name[i + 1] = 0;
				} else {
					strcat(name, item->name);
					strcat(name, "\\");
				}
				fin = dl_copy(name, ks, 0L);
			}
		}
	}
	pfree(name);
	return (fin);
}

/**
 * dl_runapp
 *
 * Startet ein Programm mit der aktuellen Auswahl.
 *
 * Eingabe:
 * iname: Zugriffspfad des Programms
 * itype: Applikationstyp
 * ititle: Titel des Programms
 * rex: Zeiger auf int, in dem im Anschluû ein Wert ungleich Null
 *      zu finden ist, wenn Thing beim Start eines Programms
 *      "teilausgelagert" wurde (SingleTOS)
 *
 * RÅckgabe:
 * 0: Fehler aufgetreten
 * sonst: Alles klar
 */
static int dl_runapp(char *iname, int itype, char *ititle, int *rex) {
	char apath[MAX_PLEN], aname[MAX_FLEN];
	int cont, fin, i;
	APPLINFO *aptr, app;

	/* Indirektes Ziel? */
	if (!itype) {
		aptr = app_isdrag(iname);
		if (aptr) {
			/* Zieldatei zusammen mit Objekten Åbergeben */
			strcpy(glob.cmd, iname);
			strcat(glob.cmd, " ");
			i = (int) strlen(glob.cmd);
			cont = sel2buf(&glob.cmd[i], aname, apath, MAX_CMDLEN - i);
			if (cont)
				fin = app_start(aptr, glob.cmd, apath, rex);
			else {
				sprintf(almsg, rs_frstr[ALTOOMANY], aptr->title);
				frm_alert(1, almsg, altitle, conf.wdial, 0L);
			}
		}
	} else {
		/* Als Applikation angemeldet ? */
		aptr = app_find(iname);
		/* Nein */
		if (!aptr) {
			strcpy(app.name, iname);
			app_default(&app);
			strcpy(app.title, ititle);
			aptr = &app;
		}
		/* Alle selektierten Objekte als Kommandozeile Åbergeben */
		cont = sel2buf(glob.cmd, aname, apath, MAX_CMDLEN);
		if (cont)
			fin = app_start(aptr, glob.cmd, apath, rex);
		else {
			sprintf(almsg, rs_frstr[ALTOOMANY], aptr->title);
			frm_alert(1, almsg, altitle, conf.wdial, 0L);
		}
	}
	return (fin);
}

/* EOF */
