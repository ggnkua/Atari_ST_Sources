/**
 * ThingIcn - Thing Icon Manager
 * Copyright (C) 1995-2012 Arno Welzel, Thomas Binder, Dirk Klemmt
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
 * @copyright  Arno Welzel, Thomas Binder, Dirk Klemmt 1995-2012
 * @author     Arno Welzel, Thomas Binder, Dirk Klemmt
 * @license    LGPL
 */

#define NUM_TREE 8

#define FNAME_RSC "icons.rsc"		/* Icon-Resourcen */
#define FNAME_ICN "icons.inf"		/* Icon-Regeln */
#define FNAME_BAK "icons.bak"		/* Backupdatei fuer Icon-Regeln */
#define FNAME_LOG "thingicn.log"	/* Logbuch */
#define PNAME_RSC "rsrc"			/* Resourcen */
#define PNAME_CON "config"			/* Konfiguration */
#define PNAME_DOC "doc"				/* Hypertexte */
#define MAX_PLEN 256
#define MAX_FLEN 32
#define MAX_AVLEN 16384
#define MAX_ASSIGN 100

#define THING_MSG 0x46ff /* Thing-Protokoll */
#define AT_ILOAD 0x0001 /* Thing-Protokoll, Icons neuladen */

typedef struct asinfo /* Icon-Zuordnung */
{
	short class;			/* Art: 0 = Datei, 1 = Ordner, 2 = Laufwerk */
	char txt;			/* Text-Kennzeichnung */
	short tcol;			/* Textfarbe (-1 = normale Zeichenfarbe) */
	char wildcard[33];	/* Wildcard */
	struct asinfo *prev, *next; /* Verkettung */
} ASINFO;

typedef struct /* Icon */
{
	char *name;			/* Name des Icons in der Resource */
	ASINFO *as;			/* Zuordnungen */
} ICONINFO;

typedef struct comment {
	struct comment *next;
	char line[1];
} COMMENT;

typedef struct {
	short use3d,			/* 3d-Look verwenden */
	backwin,			/* Fenster vor Schliessen nach hinten stellen */
	tver;				/* Thing Versionsnummer */
	short done,			/* Programm beendet */
	menu,				/* Menuezeile aktiv */
	change;				/* Aenderungen gemacht? */
	short numassign, numicon;
	short multiple, missing, illegal;
	OBJECT *rtree;
	RSINFO rinfo;
	char rname[MAX_PLEN], iname[MAX_PLEN], lname[MAX_PLEN], bname[MAX_PLEN];
	WININFO *rwin;
	short avid, tid;
	short avflags;
	ICONINFO *icon;
	COMMENT *comments;
	short scroll, rclick;
	short offx, offy, focus, fdraw;
	short mx, my, iw, ih, ny;
	short autoplace, interactive;
	short fleft, fupper, fright, flower, fhor, fvert;
	/* Desktop-Hintergrund */
	short d_fill, d_color;
} GLOB;

short add_comment(char *line);
void mn_istate(short item, short enable);
void mn_disable(void);
void mn_update(void);
void av_wopen(short handle);
void av_wclose(short handle);
void di_about(void);
void de_about(short mode, short ret);
void dl_nextwin(void);
void dl_quit(void);
void dl_freeas(ASINFO *as);
short dl_editlist(ICONINFO * icon);
void dl_edit(void);
void dl_selinit(short i);
void de_edit(short mode, short ret);
void dl_find(short icon);
void de_find(short mode, short ret);
void key_clr(void);
void handle_menu(short title, short item, short ks);
void handle_win(short handle, short msg, short f1, short f2, short f3, short f4, short ks);
void handle_button(short mx, short my, short but, short ks, short br);
void handle_key(short ks, short kr);
void handle_fmsg(EVENT *mevent, FORMINFO *fi);
void w_draw(WININFO *win);
void w_showsel(void);
void w_update(struct wininfo *win);
void w_prepare(struct wininfo *win);
void w_redraw(struct wininfo *win, GRECT *area);
void w_slide(struct wininfo *win, short mode, short h, short v);
void ic_tree(void);
void ic_fdraw(void);
void ic_sel(short obj);
void ic_move(short dir);
ASINFO *as_add(ICONINFO *icon);
void as_remove(ICONINFO *icon, ASINFO *as);
ICONINFO *as_findic(char *name);
ICONINFO *as_findas(char *name, short class);
void mw_info(void);
void mw_change(short changed);
short mw_init(void);
short loadAssignments(void);
void mw_exit(void);
void put_text(FILE *fh, char *str);
short get_buf_entry(char *buf, char *name, char **newpos);
short is_stdicon(ICONINFO *icon);
short main_init(void);
void main_loop(void);
void main_exit(void);
