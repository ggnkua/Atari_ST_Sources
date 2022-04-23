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
 GLOBALS.C
 
 Thing
 Globale Variablen
 =========================================================================*/

#define _GLOBALS_
#include "..\include\globdef.h"
#include "..\include\types.h"
#include "..\include\thingrsc.h"

/*-------------------------------------------------------------------------
 Dialoge
 -------------------------------------------------------------------------*/
/* Warten ... */
FORMINFO fi_wait = { 0L, WAIT, 0, ROOT, 0, 0, 0, 0, 0L, 0L, 0, 0L, WFCANCEL, WFHELP };
FORMINFO fi_waitcopy = { 0L, WAITCOPY, 0, ROOT, 0, 0, 0, 0, 0L, 0L, 0, 0L, WCCANCEL, WCHELP };

/* Parameter fuer eine Appl. */
FORMINFO fi_param = { 0L, PARAM, 0, ROOT, 0, 0, 0, 0, 0L, 0L, 0, 0L, PACANCEL, PAHELP };

/* Auswahl der Applikation, falls mehrere fuer eine Datei */
FORMINFO fi_selapp = { 0L, SELAPP, 0, ROOT, 0, 0, 0, 0, 0L, 0L, 1, 0L, SACANCEL, SAHELP };
LISTINFO li_selapp = { &fi_selapp, 0L, SALIST, SASLIDE, SABOX, SAUP, SADOWN, 0, -1, 5, 32, 0 };

/* Ueber Thing */
FORMINFO fi_about = { 0L, ABOUT, 0, ROOT, 0, 0, 0, 0, 0L, 0L, 0, 0L, -1, ABHELP };
FORMINFO fi_ainfo1 = { 0L, AINFO1, 0, ROOT, 0, 0, 0, 0, 0L, 0L, 0, 0L, -1, AIHELP };

/* Datei->Info (Laufwerk) */
FORMINFO fi_diinfo = { 0L, DIINFO, 0, ROOT, 0, 0, 0, 0, 0L, 0L, 0, 0L, DICANCEL, DIHELP };

/* Datei->Info (Papierkorb) */
FORMINFO fi_trashinfo = { 0L, TRASHINFO, 0, ROOT, 0, 0, 0, 0, 0L, 0L, 0, 0L, TICANCEL, TIHELP };

/* Datei->Info (Ablage) */
FORMINFO fi_clipinfo = { 0L, CLIPINFO, 0, ROOT, 0, 0, 0, 0, 0L, 0L, 0, 0L, CICANCEL, CIHELP };

/* Datei->Info (Drucker) */
FORMINFO fi_prtinfo = { 0L, PRTINFO, 0, ROOT, 0, 0, 0, 0, 0L, 0L, 0, 0L, PRCANCEL, PRHELP };

/* Datei->Info (Applikation) */
POPMENU pop_short = { 0L, DAISHORT, DAISHORTS, 1, -1, 0, 0, -1, 0 },
		*shortpop[] = { &pop_short, 0L };
FORMINFO fi_dappinfo = { 0L, DAPPINFO, 0, ROOT, 0, 0, 0, 0, shortpop, 0L, 0, 0L, DAICANCEL, DAIHELP };
LISTINFO li_dappinfo = { &fi_dappinfo, 0L, DAELIST, DAESLIDE, DAEBOX, DAEUP, DAEDOWN, 20, -1, 6, 50, 0 };

/* Datei->Info (Dateien/Ordner) */
POPMENU pop_fkeyfd = { 0L, FLFKEY, FLFKEYS, 1, -1, 0, 0, -1, 0 }, pop_mem = {
		0L, FLPMEM, FLPMEMS, 1, -1, 0, 0, -1, 0 }, *shortpopfd[] = {
		&pop_fkeyfd, &pop_mem, 0L };
FORMINFO fi_fileinfo = { 0L, FLINFO, 0, ROOT, 0, 0, 0, 0, shortpopfd, 0L, 0, 0L, FICANCEL, FIHELP };

/* Datei->Info (Devices) */
FORMINFO fi_devinfo = { 0L, DEVINFO, 0, ROOT, 0, 0, 0, 0, 0L, 0L, 0, 0L, DVCANCEL, DVHELP };

/* Datei->Info (Parent) */
FORMINFO fi_parent = { 0L, PAINFO, 0, ROOT, 0, 0, 0, 0, 0L, 0L, 0, 0L, PNOK, PNHELP };

/* Datei->Info (bei mehreren Objekten in einem Verzeichnisfenster) */
FORMINFO fi_selinfo = { 0L, SELINFO, 0, ROOT, 0, 0, 0, 0, 0L, 0L, 0, 0L, SICANCEL, SIHELP };

/* Datei->Info ber Gruppe */
POPMENU pop_fkeydgi = { 0L, GIFUNC, GIFUNCS, 1, -1, 0, 0, -1, 0 },
		*shortpopdgi[] = { &pop_fkeydgi, 0L };
FORMINFO fi_grpinfo = { 0L, GROUPINFO, 0, ROOT, 0, 0, 0, 0, shortpopdgi, 0L, 0, 0L, GICANCEL, GIHELP };

/* Datei->Info ber Gruppeneintrag */
FORMINFO fi_gobinfo = { 0L, GOBINFO, 0, ROOT, 0, 0, 0, 0, 0L, 0L, 0, 0L, GECANCEL, GEHELP };

/* Datei->L”schen */
FORMINFO fi_delete = { 0L, DELETE, 0, ROOT, 0, 0, 0, 0, 0L, 0L, 0, 0L, DLCANCEL, DLHELP };

/* Datei->Kopieren */
FORMINFO fi_copy = { 0L, COPY, 0, ROOT, 0, 0, 0, 0, 0L, 0L, 0, 0L, CPCANCEL, CPHELP };

/* Datei->Formatieren */
FORMINFO fi_format = { 0L, FORMAT, 0, ROOT, 0, 0, 0, 0, 0L, 0L, 0, 0L, FMCANCEL, FMHELP };

/* Datei->Maske */
FORMINFO fi_mask = { 0L, MASK, 0, ROOT, 0, 0, 0, 0, 0L, 0L, 1, 0L, MACANCEL, MAHELP };
LISTINFO li_mask = { &fi_mask, 0L, MALIST, MASLIDE, MABOX, MAUP, MADOWN, 0, -1, 10, 33, 0 };

/* Datei->Darstellung */
POPLIST pl_font = { FOFONT, FOFONTA, FOFONTS, -1, 0, 32 }, pl_size = { FOSIZE,
		FOSIZEA, FOSIZES, -1, 0, 3 }, *fontpl[] = { &pl_font, &pl_size, 0L };
POPMENU pop_tcolor = { 0L, FOFCOL, FOFCOLS, 1, -1, 0, 0, -1, -1 }, pop_bcolor =
		{ 0L, FOBCOL, FOBCOLS, 1, -1, 0, 0, -1, -1 }, pop_bpat = { 0L, FOBPAT,
		FOBPATS, 1, -1, 0, 0, -1, -1 }, *fontpop[] = { &pop_tcolor, &pop_bcolor,
		&pop_bpat, 0L };
FORMINFO fi_font = { 0L, FONT, 0, ROOT, 0, 0, 0, 0, fontpop, fontpl, 0, 0L, FOCANCEL, FOHELP };
USERBLK usr_fontsample = { dl_font_usr, 0L };

/* Extra->Voreinstellung */
POPMENU pop_dcol = { 0L, CODCOL, CODCOLS, 1, -1, 0, 0, -1, -1 }, pop_dpat = {
		0L, CODPAT, CODPATS, 1, -1, 0, 0, -1, -1 }, pop_autox = { 0L,
		COAUTOSIZEX, COAUTOSIZEXS, 1, -1, 0, 0, -1, 0 }, pop_autoy = { 0L,
		COAUTOSIZEY, COAUTOSIZEYS, 1, -1, 0, 0, -1, 0 }, *configpop[] = {
		&pop_dcol, &pop_dpat, &pop_autox, &pop_autoy, 0L };
FORMINFO fi_config = { 0L, CONFIG, 0, ROOT, 0, 0, 0, 0, configpop, 0L, 0, 0L, COCANCEL, COHELP };

/* Extra->Funktionstasten */
FORMINFO fi_cfunc = { 0L, CFUNC, 0, ROOT, 0, 0, 0, 0, 0L, 0L, 0, 0L, CFCANCEL, CFHELP };

/* Extra->Applikationen */
FORMINFO fi_defappl = { 0L, DEFAPPL, 0, ROOT, 0, 0, 0, 0, 0L, 0L, 1, 0L, DAOK, DAHELP };
LISTINFO li_defappl = { &fi_defappl, 0L, DALIST, DASLIDE, DABOX, DAUP, DADOWN, 0, -1, 10, 48, 0 };

/* Extra->Aufl”sung wechseln */
POPMENU pop_rez = { 0L, CRREZ, CRREZS, 1, -1, 0, 0, -1, 0 }, *rezpop[] = {
		&pop_rez, 0L };
FORMINFO fi_rez = { 0L, CHANGEREZ, 0, ROOT, 0, 0, 0, 0, rezpop, 0L, 0, 0L, CRCANCEL, CRHELP };

/* Datei/Ordner umbenennen beim Kopieren */
FORMINFO fi_cren = { 0L, RENAMEFILE, 0, ROOT, 0, 0, 0, 0, 0L, 0L, 0, 0L, RFCANCEL, RFHELP };

/* Datei->Neu */
FORMINFO fi_new = { 0L, NEWOBJ, 0, ROOT, 0, 0, 0, 0, 0L, 0L, 0, 0L, NOCANCEL, NOHELP };

/* Extra->Schnellstarttasten */
FORMINFO fi_hotkeys = { 0L, HOTKEYS, 0, ROOT, 0, 0, 0, 0, 0L, 0L, 1, 0L, HKCLOSE, HKHELP };
LISTINFO li_hotkeys = { &fi_hotkeys, 0L, HKLIST, HKSLIDE, HKBOX, HKUP, HKDOWN, 0, -1, 10, 47, 0 };

/*-------------------------------------------------------------------------
 Sonstige
 -------------------------------------------------------------------------*/

/* Mauszeiger fuer "Aktion nicht moeglich" bei Drag&Drop */
MFORM mf_no =
		{ 8, 8, 1, 0, 1, { 0xE007, 0xF00F, 0xF81F, 0x7C3E, 0x3E7C, 0x1FF8,
				0x0FF0, 0x07E0, 0x07E0, 0x0FF0, 0x1FF8, 0x3E7C, 0x7C3E, 0xF81F,
				0xF00F, 0xE007 }, { 0x0000, 0x6006, 0x700E, 0x381C, 0x1C38,
				0x0E70, 0x07E0, 0x03C0, 0x03C0, 0x07E0, 0x0E70, 0x1C38, 0x381C,
				0x700E, 0x6006, 0x0000 } };

/* Mauszeiger fuer "Hotclose" */
MFORM mf_hotc = { 0, 4, 1, 0, 1, { 0x0E00, 0x1E00, 0x3E00, 0x7FE0, 0xFFF8,
		0xFFFC, 0xFFFE, 0x7FFE, 0x3E7F, 0x1E3F, 0x0E1F, 0x001F, 0x001F, 0x001F,
		0x001F, 0x001F }, { 0x0000, 0x0400, 0x0C00, 0x1C00, 0x3FC0, 0x7FF0,
		0x3FF8, 0x1C3C, 0x0C1C, 0x040E, 0x000E, 0x000E, 0x000E, 0x000E, 0x000E,
		0x0000 } };

GLOB glob; /* Globale Variablen */
CONF conf; /* Einstellungen */
GDOS gdos; /* Info ueber GDOS */

DESKINFO desk; /* Desktop */

WININFO *popwin, *topwin; /* Aktives Fenster */

char almsg[256]; /* Fuer variable Alerts */
#if defined(_MILAN)
char *altitle="Ming"; /* Titel fuer Alertboxen */
#elif defined(_NAES)
char *altitle="N.Thing"; /* Titel fuer Alertboxen */
#else
char *altitle = "Thing"; /* Titel fuer Alertboxen */
#endif

int aesmsg[8]; /* Nachrichtenaustausch mit anderen Applikationen */
char *aesbuf;
char *aesapname;

CONSOLE con; /* Console-Fenster fuer Single-TOS */
EVENT mevent; /* Globaler Event-Buffer */
APLIST aplist; /* Globale Struktur fuer dl_appl_list() */
APPLINFO defappl = { "Default-Applikation", /* title */
	"", /* name */
	"", /* startname */
	"", /* parm */
	1, /* fullcompare */
	0, /* paralways */
	1, /* homepath */
	1, /* fullpath */
	"", /* fileopen*/
	"", /* fileview */
	"", /* fileprint */
	0, /* getpar */
	1, /* vaproto */
	0, /* single */
	1, /* conwin */
	0, /* toswait */
	0, /* shortcut */
	0, /* usesel */
	0, /* autostart */
	0, /* overlay */
	0L, /* memlimit */
	0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L, /* evar[0..9] */
	0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L, /* evar[10..19] */
	0, /* euse */
	0, /* dodrag */
	0, /* unixpaths */
	"", /* alert */
	0L, /* prev */
	0L /* next */
}, default_defappl;

/* Fuer non-modale Dialoge etc. */
DAPP *dapp;
DCOPY *dcopy;
DIGOB *digob;
DMASK *dmask;
char *lbuf; /* Lokaler Buffer fuer Dateinamen beim Kopieren etc. */

RSINFO rinfo, rinfo2; /* Globale Resourceinfo */
int rcw, rch; /* Font-Ausmasse */
OBJECT **rs_trindex;
char **rs_frstr;

/* Prototyp-Variable der Hauptfunktion von ThingImg */
long cdecl (*call_thingimg)(long magic, int what, THINGIMG *img_info);

/* Tabelle fuer schnelles Wildcard-Erkennung */
int is_wild[256];

/*
 * Prototyp-Variable fuer Stringvergleich beim Sortieren und beim
 * Autolocator
 */

int (*strcompare)(const char *, const char *);

/* EOF */
