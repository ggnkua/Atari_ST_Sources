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

#ifndef __TOOLBOX__
#define __TOOLBOX__

#include <aes.h>
#include <tos.h>
#include <portab.h>
#include <magx.h>
#include <fdmproto.h>

/*------------------------------------------------------------------*/
/*  global functions                                                */
/*------------------------------------------------------------------*/
/*------------------------------------------------------------------*/
/*  global definitions                                              */
/*------------------------------------------------------------------*/
#define UNUSED(x)	(void)(x)

#ifndef BOOLEAN
#define BOOLEAN		WORD
#endif
#ifndef TRUE
#define TRUE		(BOOLEAN)1
#endif
#ifndef FALSE
#define FALSE		(BOOLEAN)0
#endif

#define max(a,b)    (((a) > (b)) ? (a) : (b)) /* Maximum-Funktion */
#define min(a,b)    (((a) < (b)) ? (a) : (b)) /* Minimum Funktion */

/*-------------------------------------------------------------------------
 WINX/MTOS-Anpassung
 -------------------------------------------------------------------------*/
#define WM_BOTTOMED 33 /* AES-Message unter WINX/MultiTOS:
                          Fenster mit wind_set(handle, WF_BOTTOM, 0, 0, 0, 0)
                          nach hinten stellen */

/*-------------------------------------------------------------------------
 Weitere Protokolle
 -------------------------------------------------------------------------*/
/* Font-Protokoll von Christian Grunenberg
 (Christian_Grunenberg@LB.maus.de) */

#define FONT_CHANGED  0x7a18
#define FONT_SELECT   0x7a19
#define FONT_ACK      0x7a1a
#define XFONT_CHANGED 0x7a1b

/*-------------------------------------------------------------------------
 Verschiedene Definitionen, die in VDI.H bzw. AES.H von Pure C fehlen
 -------------------------------------------------------------------------*/
#define WF_BOTTOM       25

#define ALI_LEFT         0 /* horizontal text alignment */
#define ALI_CENTER       1
#define ALI_RIGHT        2

#define ALI_BASE         0 /* vertical text alignment */
#define ALI_HALF         1
#define ALI_ASCENT       2
#define ALI_BOTTOM       3
#define ALI_DESCENT      4
#define ALI_TOP          5

typedef struct {
	WORD x;
	WORD y;
	WORD w;
	WORD h;
} RECT;

#define FMD_BACKWARD -1
#define FMD_FORWARD -2
#define FMD_DEFLT -3

/*-------------------------------------------------------------------------
 Fensterverwaltung
 -------------------------------------------------------------------------*/
/* WININFO-Struktur */
typedef struct wininfo {
	/* Fensterparameter */
	int flags; /* AES-Flags fÅr das ôffnen */
	int state; /* Status vor/nach dem ôffnen */
	int class; /* Fensterklasse */
	char name[128], info[128]; /* Text der Titel- und Infozeile */
	void *user; /* Zeiger auf beliebige User-Daten */
	int handle; /* AES-Handle */
	RECT curr, full, work, save; /* Grîûe, Volle Grîûe und Arbeitsbereich */
	/* Zeiger auf die Handle-Routinen, vom Programm zu initialisieren ! */
	void (*update)(struct wininfo *win);
	void (*prepare)(struct wininfo *win);
	void (*redraw)(struct wininfo *win, RECT *area);
	void (*slide)(struct wininfo *win, int mode, int h, int v);
	/* Zeiger auf einen Objektbaum fÅr Iconify-Darstellung */
	OBJECT *ictree;
	/* Verkettung aller Fenster durch die Toolbox */
	struct wininfo *prev, *next;
} WININFO;

/* Flags fÅr Fensterstatus (state) */
#define WSINIT     0x0001  /* Fenster ist initialisiert */
#define WSOPEN     0x0002  /* Fenster ist geîffnet */
#define WSFULL     0x0004  /* Fenster hat volle Grîsse */
#define WSWORKSIZE 0x0100  /* Fenstergrîsse aus Arbeitsbereich berechnen */
#define WSDESKSIZE 0x0200  /* Desktopgrîsse als volle Fenstergrîsse */
#define WSFULLOPEN 0x0400  /* Fenster mit voller Grîsse îffnen */
#define WSFULLREDR 0x0800  /* Redraw bei Verkleinerung durchfÅhren */
#define WSICON     0x1000  /* Fenster ist ikonifiziert */

/* Fensterklassen (class) */
#define WCNONE     0x0000  /* Ohne spezifische Klasse */
#define WCDIAL     0x0001  /* Dialog */
#define WCTOOL     0x0002  /* Toolbox */
#define WCFILE     0x0003  /* Datei */

/* Modi fÅr win_slide() */
#define S_INIT 0  /* Initialisieren (nach GrîûenÑnderung etc.) */
#define S_ABS 1   /* Slider absolut (0-1000) setzen */
#define S_REL 2   /* Slider relativ (0, +/-1, +/-2) setzen */
#define S_PABS 3  /* Slide absolut in Pixeln (FensterabhÑngig) setzen */

/*-------------------------------------------------------------------------
 Erweiterte Dialoge, basierend auf MyDial
 -------------------------------------------------------------------------*/
struct sub;

/* POPMENU-Struktur, Beschreibung eines Popup-MenÅs */
typedef struct {
	OBJECT *tree; /* Tree, in dem sich das MenÅ befindet */
	int formobj; /* Nummer des Auslîsers */
	int formshort; /* Nummer des Shortcuts */
	int take; /* Falls 1, dann wird die Auswahl in den Dialog Åber-
	 nommen */
	int sel; /* Aktuelle Auswahl */
	int offx, offy; /* Offset um den das MenÅ ggf. verschoben werden muû */
	int formtype; /* GewÅnschter Objekttyp im Dialog oder -1 */
	int objoff; /* Offset zur verwendenden Objektnummer aus dem MenÅ */
	struct sub *subs;/* Eventuelle UntermenÅs, NULL-Abschluû */
} POPMENU;

/* POPLIST-Struktur, Beschreibung einer PopUp-Liste */
typedef struct {
	int formset; /* Nummer des Eingabefelds/Buttons */
	int formobj; /* Nummer des Auslîsers */
	int formshort; /* Nummer des Shortcuts */
	int sel; /* Aktuelle Auswahl oder -1, falls keine Auswahl */
	int num; /* Anzahl der EintrÑge */
	int len; /* LÑnge der EintrÑge */
	char **list; /* Zeiger auf String-Array fÅr die EintrÑge */
	OBJECT *copy; /* Interner Gebrauch */
} POPLIST;

/* POPSUBMENU-Struktur, Beschreibung eines Unter-Popup-MenÅs */
typedef struct sub {
	int type; /* 0: Popup, 1: Popup-Liste */
	union {
		POPMENU *popup; /* Zugehîriges Popup-MenÅ ... */
		POPLIST *poplist; /* ... oder zugehîrige Popup-Liste */
	} data;
	int obj; /* Objekt-Nummer des Auslîsers im "Vater"-MenÅ */
} POPSUBMENU;

/* FORMINFO-Struktur, Grundlage fÅr jeden Dialog */
typedef struct forminfo {
	OBJECT *tree; /* Zeiger auf Objektbaum */
	int bub_id; /* BubbleGEM-ID des Dialogs, oder -1 */
	int open; /* 1 = Dialog geîffnet */
	int start_obj; /* Nummer des ersten Editfeldes oder ROOT */
	int edit_obj; /* Nummer des aktuellen Eingabefeldes nach xform_do() */
	int edit_idx; /* Cursorposition des aktuellen Eingabefeldes */
	int exit_obj; /* Nummer des Exit-Objekts nach xform_do() */
	int state; /* Status (Normal, MyDial, Fenster) */
	POPMENU **popup; /* Zeiger auf ein nullterminiertes Zeiger-Array mit
	 allen Popup-MenÅs oder 0L, falls keine Popups
	 enthalten sind */
	POPLIST **poplist; /* Wie popup, jedoch fÅr Popup-Listen */
	int keyflag; /* Falls 1 werden NKCC-Tastaturcodes bestimmter Tasten in normkey mit exit_obj=0x8000 zurÅckgeliefert */
	void *userinfo; /* Zeiger auf beliebige Benutzerdaten fÅr ein Hilfesystem */
	int undo_obj; /* UNDO-Button oder -1, falls keiner vorhanden ist */
	int help_obj; /* HELP-Button oder -1, falls keiner vorhanden ist */
	unsigned int normkey;
	WININFO win; /* WININFO-Struktur fÅr Fensterdialoge */
	int drobj; /* FÅr Teilredraw in Fenstern: Nummer des Objekts */
	char *title; /* Fenstertitel, falls Dialogbox keinen Titel enthÑlt */
	int ty, wy; /* Y-Koordinaten fÅr Sicherung bei Fensterdialog */
	int cx, cy, cw, ch; /* Aussenrechteck */
	int cont; /* 1 = Keine Verarbeitung, 0 = Exit-Objekt */
	void (*init)(void); /* Zeiger auf Init-Funktion */
	void (*exit)(int mode, int ret); /* Zeiger auf Exit-Funktion */
	struct forminfo *oldtop; /* Bisheriger Dialog, falls ohne Fenster */
	struct forminfo *prev, *next; /* Listenverkettung */
} FORMINFO;

#define FST_NORM 1    /* GEM-Dialog (keine "FlyDial"-Erweiterung) */
#define FST_MYDIAL 2  /* FlyDial */
#define FST_WIN 3     /* Modaler Fenster-Dialog */

/*-------------------------------------------------------------------------
 Auswahllisten in Dialogen
 -------------------------------------------------------------------------*/
typedef struct {
	FORMINFO *fi;
	char **text;
	int ob_list;
	int ob_slide, ob_box;
	int ob_up, ob_down;
	int num;
	int sel;
	int view;
	int len;
	int offset;
} LISTINFO;

/*
 * BubbleGEM-Hilfe
 */
typedef struct bhelp {
	struct bhelp *lt, *ge;
	int bal;
	long id_and_obj;
	char txt[1];
} BHELP;

/*-------------------------------------------------------------------------
 Globale Variablen, die von der Toolbox bereitgestellt werden
 -------------------------------------------------------------------------*/
typedef struct {
	WININFO *win; /* Zeiger auf Window-Liste */
	WININFO *topwin; /* Aktives Fenster */
	WININFO *alwin; /* Zeiger auf aktuellen Alert, falls vorhanden */
	FORMINFO *fi; /* Zeiger auf Dialog-Liste */
	FORMINFO *topfi; /* Zeiger auf aktuellen Dialog, falls vorhanden */
	OBJECT *ictree; /* Objektbaum fÅr All-Iconify */
	OBJECT *ictreed; /* Objektbaum fÅr Dialog-Iconify */
	int app_id; /* AES-ID der Applikation */
	int scr_id; /* AES-ID des Screen-Managers */
	int vdi_handle; /* VDI-Handle der Applikation */
	int fn_id, fn_size; /* Font-ID/Grîsse des AES-Font "normal" */
	int ch_w, ch_h, ch_wb, ch_hb; /* Breite und Hîhe des Systemzeichensatzes */
	int fs_id, fs_size; /* Font-ID/Grîsse des AES-Font "klein" */
	int fs_cw, fs_ch; /* Zeichenzellengrîûe des kleinen AES-Fonts */
	int gdos; /* GDOS vorhanden */
	int numfonts; /* Anzahl verfÅgbarer Fonts */
	void (*msg_handler)(EVENT *mevent, FORMINFO *fi); /* Message-Handler fÅr Fenster-Dialoge */
	RECT desk; /* Desktop-Koordinaten */
	int planes; /* Farbtiefe */
	int truecolor; /* "True-Color"-Display? */
	BHELP *hlp; /* Zeiger auf die BubbleGEM-Hilfe der Applikation */
	int resx, resy; /* Auflîsung */
	long colors; /* Anzahl der Farben */
	MAGX_COOKIE *magx; /* MagiC-Cookie oder 0L */
	long sys; /* Verschiedene Systemeigenschaften */
	int sysLanguageId; /* System-Sprache */
	char sysLanguageCode[3]; /* System-Sprache ('de', 'en', ...) */
	char sysLanguageCodeLong[10]; /* System-Sprache ('german', 'english', ...) */
	char apname[13]; /* Dateiname der Applikation */
	char homepath[256]; /* Startverzeichnis der Applikation */
	int mform, mbusy; /* Aktuelle Mausform, Busy-Flag */
	int use3d; /* 3D-Effekte fÅr Dialoge */
	int backwin; /* MagiC-Workaround (Fenster vor Schlieûen nach hinten) */
	int fleft, /* AbstÑnde fÅr automatisches Fensterplazieren */
	fupper, fright, flower, fhor, fvert;
	/* Semaphores (>0 = gesetzt) */
	int sm_alert; /* Alertbox offen */
	int sm_nowdial; /* Systemmodale Dialogbox offen */
	int sm_dial; /* Dialog auf */
	int sm_modal; /* Modaler Dialog/Alert auf */
	void (*modal_on)(void); /* Zeiger auf Routine MenÅ-Disable etc. */
	void (*modal_off)(void); /* GegenstÅck zu modal_on() */
} TOOLINFO;

#define SY_MULTI   0x00000001L /* Multitasking */
#define SY_MAGX    0x00000002L /* MagiC vorhanden */
#define SY_MSHELL  0x00000004L /* Programm lÑuft als MagiC-Shell */
#define SY_MINT    0x00000008L /* MiNT vorhanden */
#define SY_MTOS    0x00000010L /* MultiTOS vorhanden */
#define SY_XALLOC  0x00000020L /* Mxalloc() fÅr public memory */
#define SY_CICON   0x00000040L /* Farbicons vorhanden */
#define SY_NRSC    0x00000080L /* Neues RSC-Format vorhanden */
#define SY_SHUT    0x00000100L /* Shutdown vorhanden */
#define SY_WINX    0x00000200L /* WINX vorhanden */
#define SY_ICONIFY 0x00000400L /* AES-Iconify fÅr Fenster vorhanden */
#define SY_NAES    0x00000800L /* N.AES vorhanden */
#define SY_GNVA    0x00001000L /* Geneva vorhanden */
#define SY_AGI     0x00002000L /* (Erweitertes) appl_getinfo() vorhanden */
#define SY_ASEARCH 0x00004000L /* appl_search() vorhanden */
#define SY_OWNER   0x00008000L /* WF_OWNER bei wind_get() vorhanden */
#define SY_POPUP   0x00010000L /* MultiTOS-Popup- und -SubmenÅs vorhanden */
#define SY_WUPDATE 0x00020000L /* wind_update() "check and set" vorhanden */

/* Konstanten fuer app_send */
#define PT34 1
#define PT45 2
#define PT56 4
#define PT67 8

#ifdef TOOLBOX_LIB
TOOLINFO tb;
#else
extern TOOLINFO tb;
#endif

#if 0
#if !defined( _TOOLBOX_ )
extern TOOLINFO tb;
#endif
#endif

/*-------------------------------------------------------------------------
 Funktionsprototypen
 -------------------------------------------------------------------------*/
/*-------------------------------------------------------------------------
 * 'debug.c'
 *-------------------------------------------------------------------------*/
#ifdef DEBUG
void debugLog(int init, char *logFile, const char *format, ...);
#define DEBUGLOG(x) debugLog x
#else
#define DEBUGLOG(x)
#endif

/*-------------------------------------------------------------------------
 * 'avclient.c'
 *-------------------------------------------------------------------------*/
void avcWindowOpen(int avId, int handle);
void avcWindowClose(int avId, int handle);

/*-------------------------------------------------------------------------
 * 'convert.c'
 *-------------------------------------------------------------------------*/
#if 0
void long2int(long lword, int *hi, int *lo);
unsigned long int2long(unsigned int hi, unsigned int lo);
#endif
int abs2rel(int rel, int abs, int value);

/*-------------------------------------------------------------------------
 * 'converta.s'
 *-------------------------------------------------------------------------*/
extern void long2int(long lword, int *iword1, int *iword2);
extern long int2long(int *iword1, int *iword2);

/*-------------------------------------------------------------------------
 * 'dragdrop.c'
 *-------------------------------------------------------------------------*/
void ddnak(EVENT *mevent);

/*-------------------------------------------------------------------------
 * 'gemdos.c'
 *-------------------------------------------------------------------------*/
void full2comp(char *full, char *path, char *file);
void comp2full(char *full, char *path, char *file);
int isValidPath(char *path);
int isValidFileMask(char *mask, int wild);
/*int isValidFileExtension(char *ext);*/
int full_fselect(char *full, char *deflt, char *ext, int dironly, char *title, int freedret, int freedid, FORMINFO *fi);

/*-------------------------------------------------------------------------
 * 'help.c'
 *-------------------------------------------------------------------------*/
WORD showSTGuideHelp(BYTE *helpfile, BYTE *reference);
void read_hlp(char *ext);
void free_hlp(BHELP *root);

/*-------------------------------------------------------------------------
 * 'string.c'
 *-------------------------------------------------------------------------*/
void strShortener(char *dest, char *src, int limit);
int isWildcard(char c);
int hasWildcards(char *str);
int patternMatching(register char *pattern, register char *str);
char *get_text(char *str, char *buf, int maxlen);

/*-------------------------------------------------------------------------
 * 'system.c'
 *-------------------------------------------------------------------------*/
WORD getSystemLanguage(BYTE *sysLanguageCode, BYTE *sysLanguageCodeLong);

/*-------------------------------------------------------------------------
 * 'toolbox.c'
 *-------------------------------------------------------------------------*/
void mybeep(void);
int getCookie(long cookie, long *p_value);
unsigned int normkey(int ks, int kr);
int rel2abs(char *path, char **dest);
int menu_key(OBJECT *tree, int key, int *title, int *item);

int tool_init(char *apname);
void tool_exit(void);

int obj_edit(OBJECT *ob_edtree, int ob_edobject, int ob_edchar, int ob_edstate,
		int *ob_edidx, int ob_edkind, int whandle);

int popup_menu(POPMENU *menu, int x, int y, int center_obj, int *ok,
		OBJECT *father);
void pop_set(FORMINFO *fi, POPMENU *pop);
void poplist_set(FORMINFO *fi, POPLIST *pop);
void poplist_get(FORMINFO *fi, POPLIST *pop);
int poplist_do(int mode, FORMINFO *fi, int obj, int ks, int kr, int *edit_obj,
		int *idx, int whandle, int *exit_obj);
int poplist_handle(POPLIST *pop, int x, int y, int width, int oh, int *pok,
		OBJECT *father);

void frm_restore(FORMINFO *fi);
void frm_edstring(FORMINFO *fi, int obj, char *str);
void frm_gotoedit(FORMINFO *fi, int obj);
void frm_norm(FORMINFO *fi);
void frm_start(FORMINFO *fi, int wd, int cd, int mode);
void frm_end(FORMINFO *fi);
void frm_redraw(FORMINFO *fi, int obj);
void frm_event(FORMINFO *fi, EVENT *mevent);
int frm_ecopy(FORMINFO *fi);
void frm_epaste(FORMINFO *fi);
void frm_ecut(FORMINFO *fi);
int frm_do(FORMINFO *fi, EVENT *mevent);
int frm_dial(FORMINFO *fi, EVENT *mevent);
int frm_alert(int defbut, char *alstr, char *altitle, int wd, void *userinfo);

void lst_prepare(LISTINFO *li, OBJECT *tree);
void lst_init(LISTINFO *li, int ilist, int islide, int dlist, int dslide);
int lst_handle(LISTINFO *li, int ret, int *dclick);
void lst_move(LISTINFO *li, int delta);
void lst_slide(LISTINFO *li);
void lst_up(LISTINFO *li);
void lst_down(LISTINFO *li);
void lst_select(LISTINFO *li, int sel);
void lst_key(LISTINFO *li, int key);

int rc_intersect(RECT *p1, RECT *p2);

void win_icon(WININFO *win, int x, int y, int w, int h);
void win_unicon(WININFO *win, int x, int y, int w, int h);
int win_open(WININFO *win, int mode);
void win_close(WININFO *win);
void win_redraw(WININFO *win, int x, int y, int w, int h);
void win_scroll(WININFO *win, int x, int y);
void win_pupdate(WININFO *win);
void win_size(WININFO *win, int x, int y, int w, int h);
void win_full(WININFO *win);
void win_newtop(WININFO *win);
void win_top(WININFO *win);
void win_updtinfo(WININFO *win);
void win_slide(WININFO *win, int mode, int h, int v);
WININFO *win_getwinfo(int handle);

void rs_user(OBJECT *tree);
void rs_fix(OBJECT *tree, int orig_cw, int orig_ch);
void rs_textadjust(OBJECT *tree, int bg);
void tree_win(OBJECT *tree, int mode);

void scrap_clear(void);
void mn_tnormal(OBJECT *tree, int title, int normal);

int fselect(char *fs_einpath, char *fs_einsel, int *fs_eexbutton, char *elabel, int fret, int fid);
void magx_switch(int id, int top);
int Screen2Buffer(int x, int y, int w, int h, int flag);
void grf_ghostbox(int *pxy, int n);
int grf_dragbox(int w, int h, int bx, int by, int bw, int bh, int sx, int sy, int *dx, int *dy);

void _v_opnvwk(int *work_in, int *handle, int *work_out);
int appl_getinfo(int ap_gtype, int *ap_gout1, int *ap_gout2, int *ap_gout3, int *ap_gout4);
char *appl_name(int id, char *deflt);
void appl_send(int id, int message, int pointers, long par1, long par2, long par3, long par4, long par5);
int calc_small_text_width(char *text);
int win_update(int mode);

/*-------------------------------------------------------------------------
 Aus TOOLMCOD.S
 -------------------------------------------------------------------------*/
extern SYSHDR *get_oshdr(void);
extern void get_twin(int *handle);

#endif
