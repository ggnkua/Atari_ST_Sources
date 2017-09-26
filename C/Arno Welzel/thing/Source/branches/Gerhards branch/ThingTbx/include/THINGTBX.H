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

#include <gem.h>
#include <mintbind.h>
#include <sysvars.h>
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
 Weitere Protokolle
 -------------------------------------------------------------------------*/
/* Font-Protokoll von Christian Grunenberg
 (Christian_Grunenberg@LB.maus.de) */

#define FONT_CHANGED  0x7a18
#define FONT_SELECT   0x7a19
#define FONT_ACK      0x7a1a
#define XFONT_CHANGED 0x7a1b

/*-------------------------------------------------------------------------
 Verschiedene Definitionen, die in der MiNTLib fehlen
 -------------------------------------------------------------------------*/

/* attributes for Fcreate/Fsfirst/Fsnext: */

#define FA_READONLY     0x01
#define FA_HIDDEN       0x02
#define FA_SYSTEM       0x04
#define FA_VOLUME       0x08
#define FA_SUBDIR       0x10
#define FA_ARCHIVE      0x20

/* Fopen modes: */

#define FO_READ         0
#define FO_WRITE        1
#define FO_RW           2

/*-------------------------------------------------------------------------
 Verschiedene Definitionen, die in der gemlib fehlen
 -------------------------------------------------------------------------*/

/* Object flags */

#define NONE            0x0000
#define SELECTABLE      0x0001
#define DEFAULT         0x0002
#define EXIT            0x0004
#define EDITABLE        0x0008
#define RBUTTON         0x0010
#define LASTOB          0x0020
#define TOUCHEXIT       0x0040
#define HIDETREE        0x0080
#define INDIRECT        0x0100


/* Object states */

#define NORMAL          0x00
#define SELECTED        0x01
#define CROSSED         0x02
#define CHECKED         0x04
#define DISABLED        0x08
#define OUTLINED        0x10
#define SHADOWED        0x20


#define ALI_LEFT         0 /* horizontal text alignment */
#define ALI_CENTER       1
#define ALI_RIGHT        2

#define ALI_BASE         0 /* vertical text alignment */
#define ALI_HALF         1
#define ALI_ASCENT       2
#define ALI_BOTTOM       3
#define ALI_DESCENT      4
#define ALI_TOP          5

#define FMD_BACKWARD -1
#define FMD_FORWARD -2
#define FMD_DEFLT -3

/* this is our special invention to increase evnt_multi performance */

typedef struct /* Special type for EventMulti */
{
        /* input parameters */
        short     ev_mflags, ev_mbclicks, ev_bmask, ev_mbstate, ev_mm1flags,
                ev_mm1x, ev_mm1y, ev_mm1width, ev_mm1height, ev_mm2flags,
                ev_mm2x, ev_mm2y, ev_mm2width, ev_mm2height, ev_mtlocount,
                ev_mthicount;
        /* output parameters */
        short     ev_mwich, ev_mmox, ev_mmoy, ev_mmobutton, ev_mmokstate,
                ev_mkreturn, ev_mbreturn;
        /* message buffer */
        short     ev_mmgpbuf[8];
} EVENT;


/*-------------------------------------------------------------------------
 Fensterverwaltung
 -------------------------------------------------------------------------*/
/* WININFO-Struktur */
typedef struct wininfo {
	/* Fensterparameter */
	short flags; /* AES-Flags fÅr das ôffnen */
	short state; /* Status vor/nach dem ôffnen */
	short class; /* Fensterklasse */
	char name[128], info[128]; /* Text der Titel- und Infozeile */
	void *user; /* Zeiger auf beliebige User-Daten */
	short handle; /* AES-Handle */
	GRECT curr, full, work, save; /* Grîûe, Volle Grîûe und Arbeitsbereich */
	/* Zeiger auf die Handle-Routinen, vom Programm zu initialisieren ! */
	void (*update)(struct wininfo *win);
	void (*prepare)(struct wininfo *win);
	void (*redraw)(struct wininfo *win, GRECT *area);
	void (*slide)(struct wininfo *win, short mode, short h, short v);
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
	short formobj; /* Nummer des Auslîsers */
	short formshort; /* Nummer des Shortcuts */
	short take; /* Falls 1, dann wird die Auswahl in den Dialog Åber-
	 nommen */
	short sel; /* Aktuelle Auswahl */
	short offx, offy; /* Offset um den das MenÅ ggf. verschoben werden muû */
	short formtype; /* GewÅnschter Objekttyp im Dialog oder -1 */
	short objoff; /* Offset zur verwendenden Objektnummer aus dem MenÅ */
	struct sub *subs;/* Eventuelle UntermenÅs, NULL-Abschluû */
} POPMENU;

/* POPLIST-Struktur, Beschreibung einer PopUp-Liste */
typedef struct {
	short formset; /* Nummer des Eingabefelds/Buttons */
	short formobj; /* Nummer des Auslîsers */
	short formshort; /* Nummer des Shortcuts */
	short sel; /* Aktuelle Auswahl oder -1, falls keine Auswahl */
	short num; /* Anzahl der EintrÑge */
	short len; /* LÑnge der EintrÑge */
	char **list; /* Zeiger auf String-Array fÅr die EintrÑge */
	OBJECT *copy; /* Interner Gebrauch */
} POPLIST;

/* POPSUBMENU-Struktur, Beschreibung eines Unter-Popup-MenÅs */
typedef struct sub {
	short type; /* 0: Popup, 1: Popup-Liste */
	union {
		POPMENU *popup; /* Zugehîriges Popup-MenÅ ... */
		POPLIST *poplist; /* ... oder zugehîrige Popup-Liste */
	} data;
	short obj; /* Objekt-Nummer des Auslîsers im "Vater"-MenÅ */
} POPSUBMENU;

/* FORMINFO-Struktur, Grundlage fÅr jeden Dialog */
typedef struct forminfo {
	OBJECT *tree; /* Zeiger auf Objektbaum */
	short bub_id; /* BubbleGEM-ID des Dialogs, oder -1 */
	short open; /* 1 = Dialog geîffnet */
	short start_obj; /* Nummer des ersten Editfeldes oder ROOT */
	short edit_obj; /* Nummer des aktuellen Eingabefeldes nach xform_do() */
	short edit_idx; /* Cursorposition des aktuellen Eingabefeldes */
	short exit_obj; /* Nummer des Exit-Objekts nach xform_do() */
	short state; /* Status (Normal, MyDial, Fenster) */
	POPMENU **popup; /* Zeiger auf ein nullterminiertes Zeiger-Array mit
	 allen Popup-MenÅs oder 0L, falls keine Popups
	 enthalten sind */
	POPLIST **poplist; /* Wie popup, jedoch fÅr Popup-Listen */
	short keyflag; /* Falls 1 werden NKCC-Tastaturcodes bestimmter Tasten in normkey mit exit_obj=0x8000 zurÅckgeliefert */
	void *userinfo; /* Zeiger auf beliebige Benutzerdaten fÅr ein Hilfesystem */
	short undo_obj; /* UNDO-Button oder -1, falls keiner vorhanden ist */
	short help_obj; /* HELP-Button oder -1, falls keiner vorhanden ist */
	unsigned short normkey;
	WININFO win; /* WININFO-Struktur fÅr Fensterdialoge */
	short drobj; /* FÅr Teilredraw in Fenstern: Nummer des Objekts */
	char *title; /* Fenstertitel, falls Dialogbox keinen Titel enthÑlt */
	short ty, wy; /* Y-Koordinaten fÅr Sicherung bei Fensterdialog */
	short cx, cy, cw, ch; /* Aussenrechteck */
	short cont; /* 1 = Keine Verarbeitung, 0 = Exit-Objekt */
	void (*init)(void); /* Zeiger auf Init-Funktion */
	void (*exit)(short mode, short ret); /* Zeiger auf Exit-Funktion */
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
	short ob_list;
	short ob_slide, ob_box;
	short ob_up, ob_down;
	short num;
	short sel;
	short view;
	short len;
	short offset;
} LISTINFO;

/*
 * BubbleGEM-Hilfe
 */
typedef struct bhelp {
	struct bhelp *lt, *ge;
	short bal;
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
	short app_id; /* AES-ID der Applikation */
	short scr_id; /* AES-ID des Screen-Managers */
	short vdi_handle; /* VDI-Handle der Applikation */
	short fn_id, fn_size; /* Font-ID/Grîsse des AES-Font "normal" */
	short ch_w, ch_h, ch_wb, ch_hb; /* Breite und Hîhe des Systemzeichensatzes */
	short fs_id, fs_size; /* Font-ID/Grîsse des AES-Font "klein" */
	short fs_cw, fs_ch; /* Zeichenzellengrîûe des kleinen AES-Fonts */
	short gdos; /* GDOS vorhanden */
	short numfonts; /* Anzahl verfÅgbarer Fonts */
	void (*msg_handler)(EVENT *mevent, FORMINFO *fi); /* Message-Handler fÅr Fenster-Dialoge */
	GRECT desk; /* Desktop-Koordinaten */
	short planes; /* Farbtiefe */
	short truecolor; /* "True-Color"-Display? */
	BHELP *hlp; /* Zeiger auf die BubbleGEM-Hilfe der Applikation */
	short resx, resy; /* Auflîsung */
	long colors; /* Anzahl der Farben */
	MAGX_COOKIE *magx; /* MagiC-Cookie oder 0L */
	long sys; /* Verschiedene Systemeigenschaften */
	short sysLanguageId; /* System-Sprache */
	char sysLanguageCode[3]; /* System-Sprache ('de', 'en', ...) */
	char sysLanguageCodeLong[10]; /* System-Sprache ('german', 'english', ...) */
	char apname[13]; /* Dateiname der Applikation */
	char homepath[256]; /* Startverzeichnis der Applikation */
	short mform, mbusy; /* Aktuelle Mausform, Busy-Flag */
	short use3d; /* 3D-Effekte fÅr Dialoge */
	short backwin; /* MagiC-Workaround (Fenster vor Schlieûen nach hinten) */
	short fleft, /* AbstÑnde fÅr automatisches Fensterplazieren */
	fupper, fright, flower, fhor, fvert;
	/* Semaphores (>0 = gesetzt) */
	short sm_alert; /* Alertbox offen */
	short sm_nowdial; /* Systemmodale Dialogbox offen */
	short sm_dial; /* Dialog auf */
	short sm_modal; /* Modaler Dialog/Alert auf */
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
void debugLog(short init, char *logFile, const char *format, ...);
#define DEBUGLOG(x) debugLog x
#else
#define DEBUGLOG(x)
#endif

/*-------------------------------------------------------------------------
 * 'avclient.c'
 *-------------------------------------------------------------------------*/
void avcWindowOpen(short avId, short handle);
void avcWindowClose(short avId, short handle);

/*-------------------------------------------------------------------------
 * 'convert.c'
 *-------------------------------------------------------------------------*/
#if 0
void long2int(long lword, short *hi, short *lo);
unsigned long int2long(unsigned short hi, unsigned short lo);
#endif
short abs2rel(short rel, short abs, short value);

/*-------------------------------------------------------------------------
 * 'converta.s'
 *-------------------------------------------------------------------------*/
extern void long2int(long lword, short *iword1, short *iword2);
extern long int2long(short *iword1, short *iword2);

/*-------------------------------------------------------------------------
 * 'dragdrop.c'
 *-------------------------------------------------------------------------*/
void ddnak(EVENT *mevent);

/*-------------------------------------------------------------------------
 * 'gemdos.c'
 *-------------------------------------------------------------------------*/
void full2comp(char *full, char *path, char *file);
void comp2full(char *full, char *path, char *file);
short isValidPath(char *path);
short isValidFileMask(char *mask, short wild);
/*int isValidFileExtension(char *ext);*/
short full_fselect(char *full, char *deflt, char *ext, short dironly, char *title, short freedret, short freedid, FORMINFO *fi);

/*-------------------------------------------------------------------------
 * 'help.c'
 *-------------------------------------------------------------------------*/
WORD showSTGuideHelp(BYTE *helpfile, BYTE *reference);
void read_hlp(char *ext);
void free_hlp(BHELP *root);

/*-------------------------------------------------------------------------
 * 'string.c'
 *-------------------------------------------------------------------------*/
void strShortener(char *dest, char *src, short limit);
short isWildcard(char c);
short hasWildcards(char *str);
short patternMatching(register char *pattern, register char *str);
char *get_text(char *str, char *buf, short maxlen);

/*-------------------------------------------------------------------------
 * 'system.c'
 *-------------------------------------------------------------------------*/
short getSystemLanguage(BYTE *sysLanguageCode, BYTE *sysLanguageCodeLong);

/*-------------------------------------------------------------------------
 * 'toolbox.c'
 *-------------------------------------------------------------------------*/
void mybeep(void);
unsigned short normkey(short ks, short kr);
short rel2abs(char *path, char **dest);
short menu_key(OBJECT *tree, short key, short *title, short *item);

short tool_init(char *apname);
void tool_exit(void);

short obj_edit(OBJECT *ob_edtree, short ob_edobject, short ob_edchar, short ob_edstate,
		short *ob_edidx, short ob_edkind, short whandle);

short popup_menu(POPMENU *menu, short x, short y, short center_obj, short *ok,
		OBJECT *father);
void pop_set(FORMINFO *fi, POPMENU *pop);
void poplist_set(FORMINFO *fi, POPLIST *pop);
void poplist_get(FORMINFO *fi, POPLIST *pop);
short poplist_do(short mode, FORMINFO *fi, short obj, short ks, short kr, short *edit_obj,
		short *idx, short whandle, short *exit_obj);
short poplist_handle(POPLIST *pop, short x, short y, short width, short oh, short *pok,
		OBJECT *father);

void frm_restore(FORMINFO *fi);
void frm_edstring(FORMINFO *fi, short obj, char *str);
void frm_gotoedit(FORMINFO *fi, short obj);
void frm_norm(FORMINFO *fi);
void frm_start(FORMINFO *fi, short wd, short cd, short mode);
void frm_end(FORMINFO *fi);
void frm_redraw(FORMINFO *fi, short obj);
void frm_event(FORMINFO *fi, EVENT *mevent);
short frm_ecopy(FORMINFO *fi);
void frm_epaste(FORMINFO *fi);
void frm_ecut(FORMINFO *fi);
short frm_do(FORMINFO *fi, EVENT *mevent);
short frm_dial(FORMINFO *fi, EVENT *mevent);
short frm_alert(short defbut, char *alstr, char *altitle, short wd, void *userinfo);

void lst_prepare(LISTINFO *li, OBJECT *tree);
void lst_init(LISTINFO *li, short ilist, short islide, short dlist, short dslide);
short lst_handle(LISTINFO *li, short ret, short *dclick);
void lst_move(LISTINFO *li, short delta);
void lst_slide(LISTINFO *li);
void lst_up(LISTINFO *li);
void lst_down(LISTINFO *li);
void lst_select(LISTINFO *li, short sel);
void lst_key(LISTINFO *li, short key);

void win_icon(WININFO *win, short x, short y, short w, short h);
void win_unicon(WININFO *win, short x, short y, short w, short h);
short win_open(WININFO *win, short mode);
void win_close(WININFO *win);
void win_redraw(WININFO *win, short x, short y, short w, short h);
void win_scroll(WININFO *win, short x, short y);
void win_pupdate(WININFO *win);
void win_size(WININFO *win, short x, short y, short w, short h);
void win_full(WININFO *win);
void win_newtop(WININFO *win);
void win_top(WININFO *win);
void win_updtinfo(WININFO *win);
void win_slide(WININFO *win, short mode, short h, short v);
WININFO *win_getwinfo(short handle);

void rs_user(OBJECT *tree);
void rs_fix(OBJECT *tree, short orig_cw, short orig_ch);
void rs_textadjust(OBJECT *tree, short bg);
void tree_win(OBJECT *tree, short mode);

void scrap_clear(void);
void mn_tnormal(OBJECT *tree, short title, short normal);

short fselect(char *fs_einpath, char *fs_einsel, short *fs_eexbutton, char *elabel, short fret, short fid);
void magx_switch(short id, short top);
short Screen2Buffer(short x, short y, short w, short h, short flag);
void grf_ghostbox(short *pxy, short n);
short grf_dragbox(short w, short h, short bx, short by, short bw, short bh, short sx, short sy, short *dx, short *dy);

void _v_opnvwk(short *work_in, short *handle, short *work_out);
short EvntMulti( EVENT *evnt_data );
char *appl_name(short id, char *deflt);
void appl_send(short id, short message, short pointers, long par1, long par2, long par3, long par4, long par5);
short calc_small_text_width(char *text);
short win_update(short mode);

/*-------------------------------------------------------------------------
 Aus TOOLMCOD.S
 -------------------------------------------------------------------------*/
extern OSHEADER *get_oshdr(void);
extern void get_twin(short *handle);

#endif
