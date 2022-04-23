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
 GLOBDEF.H

 Thing
 Einbindung aller benoetigten Headerfiles und globale Definitionen
 =========================================================================*/

/* #define _DEBUG 1 */
/* #define _NAES 1 */

#include <portab.h>

#include <aes.h>
#include <vdi.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#include <tos.h>
#include "..\include\tosext.h"

#ifdef __MINT__
#include <support.h>
#define itoa	_itoa
#define ltoa	_ltoa
#define ultoa	_ultoa
#endif

#include <nkcc.h>
#include <thingtbx.h>
#include <vaproto.h>
#include <devlock.h>
#include <tos2gem.h>

#ifdef USE_PMALLOC
#include <malloc.h>
#else
#define pmalloc	malloc
#define pfree	free
#define prealloc realloc
#endif

#ifdef MEMDEBUG
#include <memdebug.h>
#endif
#include <new_rsc.h>

#include <dudolib.h>
#include <thingimg.h>

#define	UNUSED(x)	(void)(x)

/* Anzahl der Objektbaeume in der Hauptresource */
#define NUM_TREE 52

/* Versionsnummer von Thing */
#define _VERS 150

/* Versionsnummer des ThingImg-Protokolls */
#define THINGIMG_VERS	0x102

/* Verschiedene Konstanten */
#define MAXICON 92					/* Maximale Anzahl Icons auf dem Desktop */
#define MAXDRIVES 26				/* Anzahl Laufwerke auf dem Desktop maximal */
#define OBTRASH 27					/* Objektnummer des Papierkorbs */
#define OBCLIP 28					/* Objektnummer der Ablage */
#define OBPRT 29					/* Objektnummer des Druckers */
#define OBUSER 30					/* Objektnummer des ersten "normalen" Icons */

#define FNAME_INF "thing.inf"		/* Konfigurations-Datei */
#define FNAME_INT "thing.tmp"		/* Temporaere Konfigurations-Datei */
#define FNAME_RSC "icons.rsc"		/* Icon-Resourcen */
#define FNAME_ICN "icons.inf"		/* Icon-Regeln */
#define FNAME_IDX "thing.idx"		/* Verzeichnisabh„ngige Anzeigeinfo */
#define FNAME_PRG "thing.app"
#define FNAME_RUN "thingrun.prg"
#define FNAME_PAR "thingrun.par"
#define FNAME_IMG "thingimg.ovl"	/* Externes ThingImg-Programm */
#define FNAME_SND "sendto.grp"		/* Gruppe fuer "Senden an" */
#define FNAME_PAL "icons.pal"		/* Palette fuer die Icons */

#define MAX_PWIN  16				/* Anzahl Verzeichnisfenster maximal */
#define MAX_PLEN 513				/* Maximale Pfadlaenge (mit Nullbyte) */
#define MAX_CLEN 257				/* Maximale Kommandozeilenlaenge (mit Nullbyte) */
#define MAX_FLEN  65				/* Maximale Laenge von Dateinamen (mit Nullbyte) */
#define MAX_CMDLEN 8192				/* Groesse der globalen Kommandozeile */
#define MAX_AVLEN MAX_CMDLEN		/* AV-Buffergroesse fuer DRAGACCWIND etc. */

#define MAX_KBDLEN 16384L			/* Maximale Laenge fuer Kobold-Job */

#define GRP_MASK "*.GRP"			/* Wildcard fuer Gruppen */

/*-------------------------------------------------------------------------
 NAES-Cookie
 -------------------------------------------------------------------------*/
typedef struct {
	unsigned int version;
	unsigned int date;
	unsigned int time;
	unsigned int flags;
	unsigned long unused_1;
	unsigned long unused_2;
	unsigned long magic1;
	unsigned long magic2;
} NAESCOOK;

/*-------------------------------------------------------------------------
 GDOS
 -------------------------------------------------------------------------*/
/* Schriftart */
typedef struct {
	int id;		/* GDOS-Id */
	int size;	/* Groesse in Punkt (1/72") */
	int fcol;	/* Schriftfarbe */
	int bcol;	/* Hintergrundfarbe */
	int attr;	/* Attribute */
} GFONT;

/* Infos ueber GDOS (Fonts etc.) */
typedef struct {
	char *fontlist;		/* Buffer fuer die Namen der Zeichensaetze */

	/* Zeichensaetze insgesamt */
	int numfonts;		/* Anzahl der verfuegbaren Zeichensaetze */
	char **fontname;	/* Zeiger auf die Namen */
	int *fontid;		/* Liste der Font-IDs */

	/* Davon nicht-proportional (monospaced) */
	int mnumfonts;
	char **mfontname;
	int *mfontid;
} GDOS;

/*-------------------------------------------------------------------------
 Index
 -------------------------------------------------------------------------*/
/* Art der Darstellung in Fenstern */
typedef struct {
	int text;					/* Als Text */
	int sortby;					/* Sortierung */
	int show;					/* Anzeige von Groesse, Datum, Attributen */
	char wildcard[MAX_FLEN];	/* Maske */
} INDEX;

#define SORTNONE 0x00  /* INDEX.sortby */
#define SORTNAME 0x01
#define SORTSIZE 0x02
#define SORTDATE 0x03
#define SORTTYPE 0x04
#define SORTREV  0x100
#define SORTFOLD 0x200

#define SHOWSIZE 0x0001 /* INDEX.show */
#define SHOWDATE 0x0002
#define SHOWTIME 0x0008
#define SHOWATTR 0x0004

/*-------------------------------------------------------------------------
 Icons
 -------------------------------------------------------------------------*/
/* Icons in Fenstern und auf dem Desktop */
typedef struct {
	_CICONBLK ciconblk;		/* Lokale CICONBLK-Struktur */
	USERBLK userblk;		/* Lokale USERBLK-Struktur */
	DRAW_CICON draw_cicon;	/* Kopie der DRAW_CICON-Stuktur fuer Farbicons */
} WICON;

/* Icon-Zuordnungen */
typedef struct iconimg {
	ICONBLK *iconblk;		/* Zeiger auf das Icon in der Resource */
	DRAW_CICON *cblk;		/* ODER Zeiger bei Farbicons */
	void *ub_code;			/* ... plus Userdef-Routine */
	ICONBLK *siconblk;		/* Zeiger auf Mini-Icon */
	DRAW_CICON *scblk;		/* ODER Zeiger bei Mini-Farbicons */
	void *sub_code;			/* ... plus Userdef-Routine */
	char mask[MAX_FLEN];	/* Wildcard */
	int class;				/* 0 = Dateien/Programme, 1 = Ordner, 2 = Laufwerk */
	char tchar;				/* Zeichen fuer Textdarstellung oder 0 */
	int tcolor;				/* Farbe fuer Textdarstellung oder -1 */
} ICONIMG;

/*-------------------------------------------------------------------------
 Verschiedenes
 -------------------------------------------------------------------------*/

/* Bitmasken fuer Fileystemflags */
#define UPCASE    1   /* Nur Grossbuchstaben ja/nein */
#define TOS       2   /* TOS-Dateinamen (8+3) ja/nein */
#define UNIXATTR  4   /* Unix-Filemode ja/nein */
#define OWNER     8   /* Fileeigentuemer und -gruppe ja/nein */
#define STIMES    16  /* Spezialzeiten (atime/ctime) ja/nein */
#define SYMLINKS  32  /* Beherrscht symbolische Links */

/* Info ueber Dateisysteme */
typedef struct {
	int namelen;	/* Laenge von Dateinamen */
	int biosdev;	/* zugeordnetes BIOS-Device */
	int flags;		/* Verschiedene Flags; Bitbelegung siehe oben */
} FILESYS;

/* Alice-Cookie (Alice = All Iconify Enabler) */
typedef struct {
	long magic;			/* Magic - muss 'ALIC' sein */
	long version;		/* Versionsnummer von Alice */
	int redraw_ap_id;	/* Applikations-ID von Thing oder -1 */
} ALICE_COOKIE;

/* Alice-Fenster */
typedef struct alice_win {
	int handle;			/* Fenster-Handle */
	OBJECT tree[2];		/* Icon */
	char itext[13];		/* ... Text */
	_CICONBLK iblk;		/* ... Iconblk */
	DRAW_CICON cblk;	/* ... bei Farbicons */
	void *ub_code;		/* ... plus Userdef-Routine */
	USERBLK block;		/* ... plus USERBLK */
	struct alice_win *prev, *next; /* Verkettung */
} ALICE_WIN;

/*-------------------------------------------------------------------------
 Verzeichnisfenster/Gruppenfenster
 -------------------------------------------------------------------------*/
/* Eintrag in einem Verzeichnisfenster */
typedef struct wp_entry {
	int used;				/* Benutzt ja/nein (Um Dateien auszublenden) */
	int sel, prevsel;		/* Select-Status wie bei Desktop-Icons */
	int aptype;				/* Bei Dateien: ggf. Art der Applikation */
	char name[MAX_FLEN];	/* Dateiname */
	char *fext;				/* Position des Extensionspunktes oder NULL */
	int class;				/* 0=Ordner, 1=Datei, 2=Parent, 3=Device */
	int num;				/* Laufende Nummer (Index) */
	unsigned long size;		/* Groeže der Datei in Bytes (Index) */
	unsigned int date;		/* Datum der Datei (Index) */
	unsigned int time;		/* Zeit der Datei (Index) */
	int attr;				/* Attribute der Datei (Index) */
	unsigned int mode;		/* Erweiterte Dateiattribute */
	int link;				/* 0=normal, 1=sym. Link, 2=verwaister Link */
	int uid;				/* Eigner */
	int gid;				/* Gruppenzugehoerigkeit */
	unsigned int adate;		/* Datum des letzten Zugriffs */
	unsigned int atime;		/* Uhrzeit "    "        "    */
	unsigned int cdate;		/* Datum der letzten Attributaenderung */
	unsigned int ctime;		/* Uhrzeit "    "            "        */
	ICONIMG *iconimg;		/* Zeiger auf Iconzuordnung */
	char tchar;				/* Zeichen fuer Textdarstellung oder 0 */
	char tcolor;			/* Farbe fuer Textdarstellung oder -1 */
	int obnum;				/* Objektnummer im Baum oder Textliste */
} WP_ENTRY;

/* Info-Struktur fuer Verzeichnisfenster */
typedef struct {
	int num;				/* Laufende Nummer des Fensters */
	int rel;				/* Relativ: 0=normal, 1=relativ */
	char relname[MAX_FLEN];	/* Titel fuer Relativen Modus */
	FILESYS filesys;		/* Infos ueber das Dateisystem */
	int namelen;			/* Maximale Laenge von Dateinamen */
	char path[MAX_PLEN + MAX_FLEN + 2]; /* Pfad */
	char amask[MAX_FLEN];	/* Maske fuer Auto-Locator */
	unsigned int fdate, ftime; /* Datum und Zeit des Ordners fuer Infos */
	GFONT font;				/* Zeichensatz und Farben fuer Textdarstellung */
	int bpat;				/* Muster fuer Fenster */

	INDEX index;			/* Aktueller Index */
	INDEX cindex;			/* Letzter Index */
	INDEX oindex[10];		/* Index-"Stack" */
	int e_num;				/* Anzahl der Eintraege insgesamt */
	int e_total;			/* Anzahl der angezeigten Eintraege */
	int o_total;			/* Anzahl der angezeigten Objekte (Infozeile) */
	int e_files;			/* Anzahl der angezeigten Dateien */
	int e_sel;				/* Anzahl der selektierten Eintraege */
	int o_sel;				/* Anzahl der selektierten Objekte (Infozeile) */
	unsigned long s_total;	/* Umfang der angezeigten Dateien in Bytes */
	unsigned long s_sel;	/* Umfang der selektierten Dateien in Bytes */
	WP_ENTRY *list;			/* Array fuer Verzeichniseintraege */
	WP_ENTRY **lptr;		/* Zeigerarray fuer Verzeichniseintraege */
	OBJECT *tree;			/* Zeiger auf Objektbaum fuer Icon-Darstellung */
	WICON *wicon;			/* Zeiger auf Icons fur Icon-Darstellung */
	int tlen;				/* Laenge eines Eintrags bei Textdarstellung */
	int psize, pdate1;		/* Positionen der Textspalten (rechter Rand) */
	int pdate, ptime, pattr, pmode;
	int pext, pgid;
	int iw, ih;				/* Breite/Hoehe des Ordnericons */
	int cw, ch, clw, clh;	/* Groesse einer Textzelle bei Textdarstellung */
	int cw_p1, cw_p2;		/* Breite von '.' und ':' */
	int cw_nine;			/* Breite von '9' */
	int cw_sl, cw_x;		/* Breite von '-' und flag-Zeichen */
	int imx;				/* Anzahl Spalten */
	int imy;				/* Anzahl Zeilen */
	int offx, offy;			/* Offset des sichtbaren Ausschnitts */
	int focus;				/* Aktueller Focus */
	int iconok;				/* Icons ermittelt ja/nein */
} W_PATH;

/* Gruppeneintrag */
typedef struct wg_entry {
	int sel, prevsel;		/* Select-Status wie bei Desktop-Icons */
	int aptype;				/* Bei Dateien: ggf. Art der Applikation */
	char title[MAX_FLEN];	/* Titel und Iconbeschriftung */
	char name[MAX_PLEN];	/* Datei-/Ordnername */
	char parm[MAX_PLEN];	/* Parameter */
	int paralways;			/* Parameter auch bei D&D uebergeben */
	int class;				/* 0=Ordner, 1=Datei, 3=Device, 4=Gruppe, oder Objekt-ID fuer externe Module */
	ICONIMG *iconimg;		/* Zeiger auf Iconzuordnung */
	char tchar;				/* Zeichen fuer Textdarstellung oder 0 */
	char tcolor;			/* Farbe fuer Textdarstellung oder -1 */
	int obnum;				/* Objektnummer im Baum oder Textliste */
	struct wg_entry *prev, *next; /* Listenverkettung */
} WG_ENTRY;

typedef struct /* Gruppenfenster */
{
	int ext; /* 0=Thing-Gruppe, 1=Gruppe eines ext. Moduls */
	int eid; /* AES-ID des ext. Moduls */
	int id; /* Gruppen-ID fuer das Modul */
	char title[MAX_FLEN]; /* Titel und Iconbeschriftung */
	char name[MAX_PLEN]; /* Name der Gruppendatei */
	char info[MAX_PLEN]; /* Text fuer Infozeile durch ext. Module */
	int changed; /* Flag fuer Žnderung */
	int autosave; /* Automatisch sichern */
	int getattr; /* Unix-Attribute ermitteln */
	int autoclose; /* Nach Objektoeffnung schliessen? */
	char parent[MAX_PLEN]; /* Vaterobjekt */
	int e_num; /* Anzahl der Eintraege insgesamt */
	int text; /* Darstellung als Text oder Icons */
	GFONT font; /* Zeichensatz fuer Textdarstellung */
	int bcol, fcol; /* Hintergrund und Schrift bei < 16 Farben */
	int bcol16, fcol16; /* Hintergrund und Schrift bei >= 16 Farben */
	int bpat, bpat16; /* Pattern fuer < und >= 16 Farben */
	WG_ENTRY *entry; /* Zeiger auf Eintraege */
	OBJECT *tree; /* Zeiger auf Objektbaum fuer Icon-Darstellung */
	WICON *wicon; /* Zeiger auf Icons fuer Icon-Darstellung */
	int tlen; /* Laenge eines Eintrags */
	int iw, ih; /* Breite/Hoehe des Ordnericons */
	int cw, ch, clw, clh; /* Groesse einer Textzelle bei Textdarstellung */
	int imx; /* Anzahl Spalten */
	int imy; /* Anzahl Zeilen */
	int offx, offy; /* Offset des sichtbaren Ausschnitts */
	int focus; /* Aktueller Fokus */
	char img[MAX_PLEN]; /* Name des Hintergrundbildes */
	int img_planes; /* Zahl der Planes im Hintergrundbild */
	int img_ok; /* Wurde Bild erfolgreich geladen? */
	THINGIMG img_info; /* THINGIMG-Struktur des Bildes */
} W_GRP;

/*-------------------------------------------------------------------------
 Sonstige Infos ueber Fenster
 -------------------------------------------------------------------------*/

/* Klassen fuer Fenstereintraege in Verzeichnissen und Gruppen */
#define EC_FOLDER  0
#define EC_FILE    1
#define EC_PARENT  2
#define EC_DEVICE  3
#define EC_GROUP   4

/* Fensterklassen, die nicht in TOOLBOX.H definiert sind */
#define WCPATH  0x0100	/* Verzeichnisfenster */
#define WCGROUP 0x0200	/* Gruppenfenster */
#define WCCON   0x0300	/* Console-Fenster */
#define WCDUMMY 0x0400	/* Dummyfenster, Registrierung */

/* Info ueber offene Fenster beim Laden der Konfiguration */
typedef struct winopen {
	char title[MAX_PLEN]; /* Pfad/Name */
	int sh, sv; /* Slider */
	int class; /* Art des Fensters (WCPATH etc.) */
	int istop; /* Aktives Fenster ja/nein */
	/* Zusaetzliche Angaben fuer Verzeichnisse */
	int rel; /* Relativ */
	char relname[MAX_FLEN]; /* Titel */
	char wildcard[MAX_FLEN]; /* Maske */
	int text; /* Text/Icons */
	int sortby; /* Sortierung */
	int num; /* Fensternummer */
	struct winopen *next; /* Vorwaertsverkettung */
} WINOPEN;

/*-------------------------------------------------------------------------
 Desktop und Objekte darauf
 -------------------------------------------------------------------------*/
/* Desktop - Ablage */
typedef struct {
	char path[MAX_PLEN];
} D_CLIP;

/* Desktop - Laufwerk */
typedef struct {
	char deftitle[MAX_FLEN]; /* Standardtitel */
	int drive; /* Laufwerksnummer */
	int uselabel; /* Laufwerkslabel als Titel? */
	int autoinstall; /* Laufwerk automatisch an- und abmelden? */
} D_DRIVE;

/* Desktop - Datei */
typedef struct {
	char name[MAX_PLEN]; /* Name inkl. Pfad */
	unsigned int mode; /* Minix-Attribute */
} D_FILE;

/* Desktop - MiNT-Device */
typedef struct {
	char name[MAX_PLEN]; /* Name - z.B. 'U:\dev\con' */
} D_DEVICE;

/* Desktop - Ordner */
typedef struct {
	char path[MAX_PLEN]; /* Pfad */
} D_FOLDER;

#define MAX_EVAR 20 /* Max. Anzahl der Env.-Strings pro Applikation */

/* Applikation, auch auf dem Desktop */
typedef struct applinfo {
	char title[MAX_FLEN]; /* Titel und Text fuer Desktop-Icon */
	char name[MAX_PLEN]; /* Dateiname inkl. Pfad */
	char startname[MAX_PLEN]; /* Dateiname inkl. Pfad beim Start */
	char parm[61]; /* Parameter */
	int fullcompare; /* Kompletten Pfadnamen vergleichen? */
	int paralways; /* Parameter immer uebergeben? */
	int homepath; /* Startverzeichnis ist Applikation */
	int fullpath; /* Volle Pfadnamen uebergeben? */
	char fileopen[61]; /* Wildcards - ™ffnen */
	char fileview[61]; /* Wildcards - Anzeigen */
	char fileprint[61]; /* Wildcards - Drucken */
	int getpar; /* Parameter beim Start abfragen */
	int vaproto; /* AV-Protokoll verwenden */
	int single; /* Unter MagiC! im Single-Modus */
	int conwin; /* Unter Single-TOS im Console-Fenster */
	int toswait; /* Bei TOS/TTP auf Tastendruck warten */
	int shortcut; /* [Alternate]-Shortcut (1-10 oder 0) */
	int usesel; /* Auswahl bei Shortcut uebernehmen */
	int autostart; /* Autostart */
	int overlay; /* Overlay (Thing auslagern) */
	long memlimit; /* MultiTOS-Speicherlimit */
	char *evar[MAX_EVAR]; /* Environment */
	int euse; /* Env. benutzen ja/nein */
	int dodrag; /* Flag fuer Drag&Drop auf angem. Dateien */
	int unixpaths; /* Pfade im UNIX- statt GEMDOS-Stil? */
	char alert[61]; /* Warnungsalert vor dem Start */
	/* Listenverkettung */
	struct applinfo *prev, *next;
} APPLINFO;

/* Objekte auf dem Desktop */
typedef struct {
	int obnum; /* Objektnummer innerhalb des Baums */
	int class; /* Art des Icons (Laufwerk, Papierkorb etc.) */
	int select; /* Selektiert ja/nein */
	int prevsel; /* Select-Status fuer "Gummiband" */
	int x, y; /* Position */
	char title[MAX_FLEN]; /* Titel */
	/* Zeiger auf weitere Infos */
	union {
		D_CLIP *clip;
		D_DRIVE *drive;
		D_FILE *file;
		D_FOLDER *folder;
		D_DEVICE *device;
		void *data;
	} spec;
} ICONDESK;

#define IDFREE   0
#define IDDRIVE  1
#define IDTRASH  2
#define IDCLIP   3
#define IDFILE   4
#define IDFOLDER 5
#define IDPRT    6
#define IDDEVICE 7

/* Einige Informationen zur aktuellen Auswahl */
typedef struct {
	int desk; /* Desktop/Fenster */
	WININFO *win; /* Verweis auf das Fenster, falls Auswahl im Fenster */
	int numobs; /* Anzahl ausgewaehlter Objekte */
	int trash; /* Papierkorb ausgewaehlt */
	int clip; /* Ablage ausgewaehlt */
	int drives; /* Anzahl ausgewaehlter Laufwerke */
	int files; /* Anzahl ausgewaehlter Dateien */
	int folders; /* Anzahl ausgewaehlter Ordner */
	int parent; /* Falls 1, dann Parent-Verzeichnis selektiert */
	int printer; /* Drucker ausgewaehlt */
	int devices; /* Anzahl ausgewaehlter Devices */
} SEL_INFO;

/* Die globale Struktur fuer den Desktop */
typedef struct {
	WICON *wicon; /* Icons */
	ICONIMG *icon; /* Icon-Zuordnungen */
	int maxicon; /* Anzahl der Icon-Zuordnungen */
	ICONIMG ic_trash; /* Icon Papierkorb */
	ICONIMG ic_clip; /* Icon Ablage */
#if 0
	ICONIMG ic_floppy; /* Icon Floppy */
	ICONIMG ic_hard; /* Icon Harddisk */
	ICONIMG ic_ramdisk; /* Icon Ramdisk */
#endif
	ICONIMG ic_filesys; /* Icon Filesys */
	ICONIMG ic_file; /* Icon Datei */
	ICONIMG ic_appl; /* Icon Programm */
	ICONIMG ic_folder; /* Icon Ordner */
	ICONIMG ic_parent; /* Icon Parent */
	ICONIMG ic_prn; /* Icon Drucker */
	ICONIMG ic_dev; /* Icon Device */
	ICONIMG ic_grp; /* Icon Objektgruppe */
	ICONDESK *dicon; /* Objekte auf dem Desktop */
	APPLINFO *appl; /* Applikationen */
	SEL_INFO sel; /* Aktuelle Auswahl */
	USERBLK iuser; /* USERBLK fuer Desktop-Bild */
} DESKINFO;

/*-------------------------------------------------------------------------
 Allgemein
 -------------------------------------------------------------------------*/
/* Infos ueber eine AV-Applikation */
typedef struct avinfo {
	int id; /* Applikations-ID */
	char name[9]; /* Name */
	int state; /* Status */
	/* Listenverkettung */
	struct avinfo *prev, *next;
} AVINFO;

/* Infos ueber Accessory-Fenster */
typedef struct acwin {
	int id; /* Applikations-ID des Acc */
	int handle; /* AES-Handle des Fensters */
	/* Listenverkettung */
	struct acwin *prev, *next;
} ACWIN;

/* Status-Informationen eines Accessories */
typedef struct acstate {
	char name[9]; /* Name */
	char state[257]; /* Status */
	/* Listenverkettung */
	struct acstate *prev, *next;
} ACSTATE;

/* User- bzw. Gruppennamen */
typedef struct ugname {
	struct ugname *next;
	int id;
	char name[9];
} UGNAME;

/* Schnellstarttaste */
typedef struct hotkey {
	struct hotkey *prev, *next;
	int key; /* ASCII-Wert */
	char object[MAX_PLEN + MAX_FLEN];
} HOTKEY;

/* Globale Daten */
typedef struct {
	char langdec; /* Punkt fuer '1.000.000' */
	int tmp; /* Temporaere Konfiguration geladen */
	char cpath[MAX_PLEN]; /* Pfad der Konfigurationsdateien */
	char rname[10]; /* Name Datei fuer Desktop - aufloesungsabh. */
	char rnamesfx[4]; /* Suffix der Datei fuer Desktop */
	char rnamefb[14]; /* Name Fallback-Datei fuer Desktop */
	int done; /* 1: main_loop() wird beendet */
	int menu; /* 1: Menue gesetzt (fuer main_exit()) */
	DTA dta; /* Eigene DTA fuer Fsfirst() */
	char cmd[MAX_CMDLEN]; /* Zeiger auf globale Kommandozeile */
	int argv; /* AES kann ARGV-Verfahren */
	/* Fenster */
	int fmode, fdraw; /* Cursor in Verzeichnissen ja/nein, sichtbar */
	WININFO *fwin; /* Fenster, das gerade den Cursor enthaelt */
	/* Sonstige Dinge */
	WININFO win[MAX_PWIN]; /* Verzeichnisfenster */
	WINOPEN *openwin; /* Fuer das ™ffnen der Fenster beim Starten */
	AVINFO *avinfo; /* Zeiger auf angemeldete AV-Applikationen */
	ACWIN *accwin; /* Zeiger auf Accessory-Fenster */
	ACSTATE *accstate; /* Zeiger auf gesicherte Accessory-Stati */
	char gcmd[MAX_CLEN]; /* Buffer fuer Parameterabfrage im Dialog */
	OBJECT *rtree; /* Zeiger auf Baum mit den Icons */
	OBJECT *srtree; /* Dito - Mini-Icons */
	int sheight; /* Hoehe der Mini-Icons */
	RSINFO rinfo; /* Resourceinfo */
#ifdef _DEBUG
	int debug_level; /* Debug-Level fuer DEBUG.LOG */
	char debug_name[MAX_PLEN];
#endif
	/* Semaphores fuer Dialoge */
	int sm_selapp; /* Auswahl der zustaendigen Applikation */
	int sm_fontsel; /* Darstellung (Fontselector) */
	int sm_copy; /* Kopieren, Verschieben, Loeschen */
	int sm_info; /* Info anzeigen */
	int sm_format; /* Formatieren */
	int mode_config; /* Aktuelle Seiten bei mehrseitigen Dialogen */
	int gtimer; /* Timer fuer Gruppensicherungen */
	int toserr; /* Flag fuer Fehlermeldung bei TOSWIN-Pipe */
	/* Alice */
	ALICE_COOKIE *alice;
	ALICE_WIN *alicewin;
	/* ThingImg */
	int img_ok;
	THINGIMG img_info;
	int dir_ok;
	THINGIMG dir_img;
	/* NAES */
	NAESCOOK *naesinfo;
	/* Vermischtes */
	int initialisation; /* Thing ist noch in der Initiailierungsphase */
	int autoclose; /* Aktuelle Gruppe wird automatisch geschlossen */
	int closeall; /* Alle Fenster werden gerade geschlossen */
	int placement; /* Fenster interaktiv plazieren (1 = ja, 0 = nein)*/
	unsigned int umask; /* Zugriffsbiterzeugungsmaske */
	char *dateformat; /* Datumsformat */
	char *timeformat; /* Zeitformat */
	UGNAME *usernames; /* Usernamen aus /etc/passwd */
	UGNAME *groupnames; /* Gruppennamen aus /etc/group */
	HOTKEY *hotkeys; /* Schnellstarttasten */
	W_GRP *sendto; /* Gruppe fuer "Senden an" */
	char *editfields; /* Speicher fuer die Inhalte der Editfelder */
} GLOB;

/* Aktuelle Einstellungen */
typedef struct {
	int wdial, cdial; /* Dialoge im Fenster, zentrieren */
	int userdef; /* Dialoge zentrieren */
	int hotkeys; /* Hotkeys (1) oder Autolocator (0) */
	int autosave; /* Einstellungen automatisch sichern */
	int texit; /* Beim Programmstart unter Single-TOS auslagern */
	int bsel; /* Mausklick auch in Hintergrundfenster */
	int hscr; /* Horizontale Scrollbalken */
	int closebox; /* Closebox schliesst Fenster immer */
	int nohotcloser; /* Kein Hotcloser bei MagiC? */
	int altapp; /* PRX und ACX auch als Programme akzeptieren */
	int altcpx; /* CPX als Programme akzeptieren */
	int askacc; /* Vor ACC-Start nachfragen */
	int vastart; /* Leeres VA_START an Programme zulassen */
	int cdel; /* Bestaetigung fuer Loeschen */
	int ccopy; /* Bestaetigung fuer Kopieren */
	int creplace; /* Bestaetigung fuer šberschreiben */
	long cbuf; /* Kopierbuffer - 0=unbegrenzt */
	int dcolor; /* Farbe des Desktops */
	int dpattern; /* Muster des Desktops */
	GFONT font; /* Schriftart in Fenstern */
	int bpat; /* Muster in Fenstern */
	INDEX index; /* Art der Darstellung in Fenstern */
	int tosmode; /* TOS-Dateisysteme als '8+3' */
	char fkey[40][MAX_PLEN]; /* Funktionstastenbelegung */
	char tobj[10][MAX_PLEN]; /* Toolmenue - Objekte */
	char ttxt[10][18]; /* Toolmenue - Texte */
	int clickms; /* Zeitspanne fuer Verzoegerung bei Mausklicks, bevor
	 der Status nochmal abgefragt wird um Drag&Drop oder
	 Gummiband zu aktivieren */
	int scroll; /* Faktor fuer Echtzeitscrolling */
	int isnap; /* Icons auf dem Desktop einrasten */
	int snapx, snapy; /* Raster X/Y */
	int nowin; /* Offene Fenster nicht sichern */
	int autocon; /* Console automatisch schliessen */
	int toswait; /* Nach TOS/TTP auf Tastendruck warten */
	int uset2g; /* TOS2GEM benutzen */
	int autoupdate; /* Fenster automatisch aktualisieren */
	int autocomp; /* Autolocator mit 'Filenamecompletion' */
	int hidden; /* Versteckte Dateien anzeigen */
	int vert; /* Verzeichnisse spaltenweise */
	int qread; /* Keine Iconzuordnungen im Textmodus */
	int relwin; /* 'relative' Verzeichnisse zulassen */
	int autosel; /* Cursor mit automatischer Selektion */
	int autosize; /* Fenstergroessen automatisch anpassen */
	/* !!! */
	int autosizex; /* Fenster in x-Richtung automatisch anpassen */
	int autosizey; /* Fenster in y-Richtung automatisch anpassen */
	int autoplace; /* Fenster "intelligent" plazieren */
	int interactive; /* Fenster im Notfall interaktiv plazieren */
	int casesort; /* Case-sensitive sortieren */
	int caseloc; /* Auto-Locator ist case-sensitive */
	int rdouble; /* rechte Maustaste = Doppelklick */
	int imguse; /* Hintergrundbild verwenden */
	int imgcenter; /* Hintergrundbild zentrieren */
	int imgpal; /* Hintergrundbild - Palette setzen */
	int imgtrans; /* Hintergrundbild transpararent kopieren */
	int usedel; /* DEL auch als Shortcut fuer Shift-DEL */
	char imgname[MAX_PLEN]; /* Dateiname des Hintergrundbildes */
	char dirimg[MAX_PLEN]; /* Dateiname des Fensterhintergrundbildes */
	/* Externe Programme */
	char finder[MAX_PLEN];
	char format[MAX_PLEN];
	/* Kobold 2-Einstellung */
	char kb_prog[MAX_PLEN]; /* Programm */
	int kb_tosonly; /* Nur bei TOS-Filesystemen verwenden */
	int kbf_use; /* Formatieren ja/nein */
	int kbc_use; /* Kopieren ja/nein */
	int kbc_files; /* Anzahl der Dateien, ab der kopiert wird */
	long kbc_size; /* ... oder Umfang in kB */
	int kbd_use; /* Loeschen ja/nein */
	int kbd_files; /* Anzahl der Dateien, ab der geloescht wird */
	int kbd_two; /* Kompatibilitaetsmodus Kobold 2.0 */
	int nicelines; /* Nicelines zeichnen? */
} CONF;

/* Console-Fenster fuer Single-TOS */
typedef struct {
	TOS2GEM_COOKIE *tos2gem;
	GFONT font; /* Darstellung */
	WININFO win; /* Fenster */
	int vdi_handle; /* VDI-Handle fuer Text */
	int vdi_chandle; /* VDI-Handle fuer Cursor */
	int cw, ch; /* Ausmasse des Zeichensatzes */
	int xoff; /* X-Offset */
	int col, line, hist; /* Spalten, Zeilen, History */
	int color; /* Farbsupport 0=kein, 1=VT52, 2=VDI */
	int buffer; /* Bufferung 0=kein, 1=Groesse, 2=Zeit */
	int buftime; /* Zeit fuer Bufferung=2 */
	int flags; /* Fenster: 0x1=Titel, 0x2=VSlide, 0x4=HSlide */
	char *buf; /* Zeiger auf Textbuffer */
	char *tmp; /* Temporaerer Buffer fuer Sicherung beim Init */
} CONSOLE;

/* Fuer dl_appl_list() */
typedef struct {
	APPLINFO **appllist;
	char *ltext;
	char **list;
	int num;
} APLIST;

/*-------------------------------------------------------------------------
 Lokale Variablen fuer Dialoge
 -------------------------------------------------------------------------*/
/* Voreinstellung */
typedef struct {
	int mode;
	int imguse, imgcenter, imgpal, imgtrans;
	char imgname[MAX_PLEN];
	int tosmode, dcol, dpat, hidden, vert, bsel;
	char finder[MAX_PLEN], format[MAX_PLEN];
	char kprog[MAX_PLEN];
	int altapp, altcpx, ccolor, chist, cflags, use3d;
} DCONF;

#define WLMAX 50

/* Maske */
typedef struct {
	WININFO *win;
	W_PATH *wpath;
	char *wildcard;
	char wlist[WLMAX][34];
	char *wtext[WLMAX];
} DMASK;

/* Applikations-Info */
typedef struct {
	APPLINFO *appl;
	int mode;
	char apname[MAX_PLEN], aparam[MAX_PLEN];
	char *evar[MAX_EVAR], *ebuf;
	int new;
	char ftxt[5][61];
	char fval[5][61];
	char ftmp[5][61];
} DAPP;

/* Formatieren */
typedef struct {
	int track, side, drive, sec;
	unsigned char *buf;
	char label[16];
	int fast;
	int j_step;
} DFORMAT;

/* Neuer Ordner */
typedef struct {
	char path[MAX_PLEN];
	char *gpath;
} DNEWFOLD;

/* Funktionstastenbelegung */
typedef struct {
	char fkey[50][61];
	char txt[10][61];
	char tmp[10][61];
	char val[10][61];
	int off;
} DFUNC;

/* Info - Gruppenobjekt */
typedef struct {
	char txt[2][61];
	char tmp[2][61];
	char val[2][61];
} DIGOB;

/* Eintrag fuer DCOPY.stack */
typedef struct dstk {
	int class; /* 0=Datei, 1=Ordner */
	char *src; /* Quelle */
	char *dst; /* Ziel */
	struct dstk *prev, *next; /* Verkettung */
} DSTK;

/* Kopieren/Verschieben/Loeschen */
typedef struct {
	int mode, /* Modus (0 = Copy, 1 = Move, 2 = Link) */
	avid; /* AV-Client (>-1) */
	int follow; /* Links verfolgen? */
	int backup; /* Backupmodus? */
	DSTK *stack, *curr; /* Filestack */
	int nfiles, nfolders; /* Anzahl Dateien/Ordner */
	unsigned long total, ready, size, bsrc, bdst; /* Anzahl Bytes gelesen/geschrieben */
	int del, ren, crepl; /* Flags fuer Verschieben/Umbenennen etc. */
	long infh, outfh; /* Filehandles */
	char *buf; /* Kopierbuffer */
	unsigned long buflen; /* Anzahl der gelesenen Bytes im Buffer */
	char dlst[32]; /* Liste der betroffenen Laufwerke fuer Updates */
	int j_step;
} DCOPY;

/* Darstellung/Fontselektor */
typedef struct {
	int fmsg[8];
	int class, intern;
	int bpat;
	WININFO *fwin;
	char *sizename, **sizelist;
	GFONT lfont, mfont, *font;
	char dirimg[MAX_PLEN];
} DFONT;

/*-------------------------------------------------------------------------
 Globale Variablen aus GLOBALS.C
 -------------------------------------------------------------------------*/
#if !defined( _GLOBALS_ )
extern POPLIST pl_font, pl_size;
extern POPMENU pop_tcolor, pop_bcolor, pop_bpat, pop_dcol, pop_dpat, pop_autox,
		pop_autoy, pop_rez, pop_short, pop_fkeyfd, pop_fkeydgi, pop_mem;
extern FORMINFO fi_wait, fi_waitcopy, fi_param, fi_selapp, fi_about, fi_ainfo1,
		fi_reg, fi_diinfo, fi_trashinfo, fi_clipinfo, fi_dappinfo, fi_fileinfo,
		fi_prtinfo, fi_parent, fi_devinfo, fi_selinfo, fi_grpinfo, fi_gobinfo,
		fi_delete, fi_copy, fi_format, fi_mask, fi_font, fi_config, fi_cfunc,
		fi_defappl, fi_rez, fi_cren, fi_new, fi_hotkeys;
extern LISTINFO li_selapp, li_defappl, li_mask, li_dappinfo, li_hotkeys;
extern USERBLK usr_fontsample;

extern MFORM mf_no, mf_hotc;
extern GLOB glob;
extern CONF conf;
extern GDOS gdos;
extern DESKINFO desk;
extern char almsg[256], *altitle;
extern int aesmsg[8];
extern char *aesbuf;
extern char *aesapname;
extern CONSOLE con;
extern EVENT mevent;
extern APLIST aplist;
extern APPLINFO defappl, default_defappl;

extern DAPP *dapp;
extern DCOPY *dcopy;
extern DIGOB *digob;
extern DMASK *dmask;
extern char *lbuf;

extern RSINFO rinfo, rinfo2, mrinfo;
extern int rcw, rch;
extern OBJECT **rs_trindex;
extern char **rs_frstr;

extern long cdecl(*call_thingimg)
(long magic, int what, THINGIMG *img_info);

extern int is_wild[];

extern int (*strcompare)(const char *, const char *);

#endif
