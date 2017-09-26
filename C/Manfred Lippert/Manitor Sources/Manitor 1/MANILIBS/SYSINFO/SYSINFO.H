#ifndef __MANILIBS_SYSINFO_H__
#define __MANILIBS_SYSINFO_H__

/* Sysinfo ermittelt Atari-Spezifische Systeminformationen,
	und speichert diese in Strukturen ab.

	Auf anderen Systemen hat das Modul keine Wirkung.

	Die Strukturen mÅssen an diverse Atari-spezifische Funktionen
	Åbergeben werden.

	ACHTUNG: Die Strukturen mÅssen global (also nicht am Stack)
	angelegt sein, da manche Funktionen sich den Pointer auf
	die Struktur merken und spÑter wieder verwenden!!!
	(Beispiel: dyn_init/dyn_add...)
*/

#ifndef __PORTAB__
#include <portab.h>
#endif

#include <i:\c\fremde\manitor\manilibs\diverses\diverses.h>
#include <mgx_dos.h>

typedef struct {
	uint16 version;	/*  z.B. 0x0301 fÅr Version 3.01 */
	uint32 date;		/*  0xttmmjjjj, z.B. 0x18061990L fÅr 18.06.1990 */
} NVDI_COOKIE;

typedef struct _SYSINFO_ {
	int16 gemdosversion;			/* Gemdos-Version */

	boolean magic;					/* MagiC vorhanden? (Mit MagiC-AES, also nicht im AUTO-Ordner!) */
	int16 magic_ver;				/* MagiC-Version (Hex, z.B. 0x520) */
	uint32 magic_date;			/* MagiC-Datum (0xjjjjmmtt) */
	boolean magicmac;				/* MagiCMac vorhanden? */
	boolean magicpc;				/* MagiCPC vorhanden? */

	boolean mint;

	boolean Mxalloc;				/* Mxalloc vorhanden? */
	int16 Mxmask;					/* Maske fÅr Mxalloc */

	char *startpath;				/* Startpfad */

	boolean nvdi;					/* NVDI vorhanden? */
	NVDI_COOKIE nvdi_cookie;	/* NVDI-Cookie (Version/Datum) */
	boolean gdos;					/* GDOS vorhanden? */
	boolean speedo;				/* Speedo-Funktionen vorhanden? */

	boolean EdDI;					/* EdDI-Cookie vorhanden? */
	int16 EdDI_version;			/* EdDI-Version */
	int16 (*EdDI_dispatch)(int16 nr, ...);	/* EdDI-Dispatcher */

} SYSINFO;

typedef struct {
	int16 aes_handle;			/* VDI-Handle der AES */
	int16 wchar, hchar;		/* Zeichenbreite/Hîhe (Systemzeichensatz) */
	int16 wobfix, hobfix;	/* OBJECT-Raster der AES (obfix) */
	boolean wfbevent;			/* WF_BEVENT mîglich? */
	boolean wfowner;			/* wind_get(WF_OWNER) mîglich? */
	boolean wfbottom;			/* wind_set/get(WF_BOTTOM) mîglich? */
	boolean wfhotclose;		/* Hotcloser? */
	boolean newdeskget;		/* Ermitteln des aktiven Desktops mîglich? */
	boolean ap_term;			/* AP_TERM bekannt? -> SHW_INFRECGN machen! */
	boolean wficonify;		/* Iconify mîglich? */
	boolean wficonipos;		/* WM_ICONIFY liefert Koordinaten? */
	boolean edscroll;			/* System kann scrollbare Editfelder? */
	boolean gshortcut;		/* System hat G_SHORTCUT-Objekte? */
	int16 aes_font;			/* AES-Font */
	int16 aes_height;			/* AES-Font-Grîûe */
	boolean obj3d;				/* 3D-Objekte? */
	boolean magicobjc;		/* System hat MagiC-Objekte? */
	int16 breiter3d;			/* Verbreiterung bei 3D-Objekten (eine Richtung) */
	int16 hoeher3d;			/* dito hîher */
	RECT desk;					/* Ausmaûe des Desktops (Workbereich von Fenster 0) */

	boolean multitasking;	/* Multitasking? */
	boolean parallelstart;	/* shel_write(0) startet sofort? */
	boolean accstart;			/* shel_write(3) (ACC) mîglich? */

	boolean mint2aesid;		/* appl_find kann MiNT-ID in AES-ID wandeln? */
	boolean applsearch;		/* appl_search vorhanden? */

	boolean coloricons;		/* Farbicons mîglich? */

	int doex_bits;				/* mîgliche doex-Werte bei shel_write */

} AESINFO;

/* Ganz am Anfang (vor mîglichen Laufwerkswechseln) aufrufen: */
boolean get_sysinfo(SYSINFO *sysinfo);

/* Nach dem MT_appl_init aufrufen, sysinfo muû vorher ermittelt worden sein */
void get_aesinfo(AESINFO *info, SYSINFO *sysinfo, int16 *global);

void sysinfo_deinit(SYSINFO *sysinfo);

#endif
