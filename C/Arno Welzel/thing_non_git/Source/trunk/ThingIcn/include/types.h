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

#define FNAME_RSC "icons.rsc"     /* Icon-Resourcen */
#define FNAME_ICN "icons.inf"     /* Icon-Regeln */
#define FNAME_BAK "icons.bak"     /* Backupdatei fuer Icon-Regeln */
#define FNAME_LOG "thingicn.log"  /* Logbuch */
#define MAX_PLEN 256
#define MAX_FLEN 32
#define MAX_AVLEN 16384
#define MAX_ASSIGN 100

#define THING_MSG 0x46ff /* Thing-Protokoll */
#define AT_ILOAD 0x0001 /* Thing-Protokoll, Icons neuladen */

#define PT34 1 /* Konstanten fuer app_send */
#define PT45 2
#define PT56 4
#define PT67 8

typedef struct asinfo /* Icon-Zuordnung */
{
	int class;			/* Art: 0 = Datei, 1 = Ordner, 2 = Laufwerk */
	char txt;			/* Text-Kennzeichnung */
	int tcol;			/* Textfarbe (-1 = normale Zeichenfarbe) */
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
	int use3d,			/* 3d-Look verwenden */
	backwin,			/* Fenster vor Schliessen nach hinten stellen */
	tver;				/* Thing Versionsnummer */
	int done,			/* Programm beendet */
	menu,				/* Menuezeile aktiv */
	change;				/* Aenderungen gemacht? */
	int numassign, numicon;
	int multiple, missing, illegal;
	OBJECT *rtree;
	RSINFO rinfo;
	char rname[MAX_PLEN], iname[MAX_PLEN], lname[MAX_PLEN], bname[MAX_PLEN];
	WININFO *rwin;
	int avid, tid;
	int avflags;
	ICONINFO *icon;
	COMMENT *comments;
	int scroll, rclick;
	int offx, offy, focus, fdraw;
	int mx, my, iw, ih, ny;
	int autoplace, interactive;
	int fleft, fupper, fright, flower, fhor, fvert;
	/* Desktop-Hintergrund */
	int d_fill, d_color;
} GLOB;

void app_send(int id, int message, int pointers, long par1, long par2, long par3, long par4, long par5);
static int has_wildcards(char *s);
int wild_match(register char *p, register char *s);
int add_comment(char *line);
void long2int(long lword, int *hi, int *lo);
unsigned long int2long(unsigned int, unsigned int);
void show_help(char *helpfile, char *ref);
void mn_istate(int item, int enable);
void mn_disable(void);
void mn_update(void);
void av_wopen(int handle);
void av_wclose(int handle);
void di_about(void);
void de_about(int mode, int ret);
void dl_nextwin(void);
void dl_quit(void);
void dl_freeas(ASINFO *as);
int dl_editlist(ICONINFO * icon);
void dl_edit(void);
void dl_selinit(int i);
void de_edit(int mode, int ret);
void dl_find(int icon);
void de_find(int mode, int ret);
void key_clr(void);
void ddnak(EVENT *mevent);
void handle_menu(int title, int item, int ks);
void handle_win(int handle, int msg, int f1, int f2, int f3, int f4, int ks);
void handle_button(int mx, int my, int but, int ks, int br);
void handle_key(int ks, int kr);
void handle_fmsg(EVENT *mevent, FORMINFO *fi);
void w_draw(WININFO *win);
void w_showsel(void);
void w_update(struct wininfo *win);
void w_prepare(struct wininfo *win);
void w_redraw(struct wininfo *win, RECT *area);
void w_slide(struct wininfo *win, int mode, int h, int v);
void ic_tree(void);
void ic_fdraw(void);
void ic_sel(int obj);
void ic_move(int dir);
ASINFO *as_add(ICONINFO *icon);
void as_remove(ICONINFO *icon, ASINFO *as);
ICONINFO *as_findic(char *name);
ICONINFO *as_findas(char *name, int class);
void mw_info(void);
void mw_change(int changed);
int mw_init(void);
int loadAssignments(void);
void mw_exit(void);
char *get_text(char *str, char *buf, int maxlen);
void put_text(FILE *fh, char *str);
int get_buf_entry(char *buf, char *name, char **newpos);
int is_stdicon(ICONINFO *icon);
int main_init(void);
void main_loop(void);
void main_exit(void);
