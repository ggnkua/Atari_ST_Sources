/**
 * DudoLib - Dirchs user defined object library
 * Copyright (C) 1994-2012 Dirk Klemmt
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
 * @copyright  Dirk Klemmt 1994-2012
 * @author     Dirk Klemmt
 * @license    LGPL
 */

#ifndef __DUDOLIB__
#define __DUDOLIB__

#include <stdlib.h>
#include <portab.h>

#ifdef __PUREC__
#undef __STDC__
#include <gem.h>
#elif __GNUC__
#include <aesbind.h>
#include <vdibind.h>
#endif

#ifdef MEMDEBUG
#include <memdebug.h>
#endif

#ifndef BOOLEAN
#define BOOLEAN		short
#endif
#ifndef TRUE
#define TRUE		(BOOLEAN)1
#endif
#ifndef FALSE
#define FALSE		(BOOLEAN)0
#endif

#ifndef EOS
#define EOS			'\0'
#endif

#ifndef NIL
#define NIL			-1
#endif

#ifndef min(a, b)
#define min(a, b)  ((a) < (b) ? (a) : (b))
#endif
#ifndef max(a, b)
#define max(a, b)  ((a) > (b) ? (a) : (b))
#endif

#ifdef __GNUC__
/*
 * Fuelltypart fuer vsf_interior
 */
#define FIS_HOLLOW		0	/* leer */
#define FIS_SOLID		1	/* voll (einfarbig) */
#define FIS_PATTERN		2	/* Muster */
#define FIS_HATCH		3	/* Schraffur */
#define FIS_USER		4	/* frei definierbar */
#endif

/*
 * Textausrichtung fuer vst_alignment
 */
/* horizontale Ausrichtung */
#define TA_LEFT			0	/* linksjustiert */
#define TA_CENTER		1	/* zentriert */
#define TA_RIGHT		2	/* rechtsjustiert */
/* vertikale Ausrichtung */
#define TA_BASELINE		0	/* Basislinie */
#define TA_HALF			1	/* Halbline (Oberkante Kleinbuchstabe) */
#define TA_ASCENT		2	/* Zeichenoberkante */
#define TA_BOTTOM		3	/* Zeichenzellenunterkante */
#define TA_DESCENT		4	/* Zeichenunterkante */
#define TA_TOP			5	/* Zeichenzellenoberkante */

/*
 * Die globale Steuerungsstruktur fuer die Userdefs.
 * WICHTIG: alle Variablen sind privater Natur, d.h. es darf nur ueber
 * Funktionen darauf zugegriffen werden.
 */
typedef struct {
	WORD	vdi_handle,				/* das VDI-Handle fuer die WS der Userdefs */
			char_w,					/* Breite eines Buchstabens in Pixeln */
			char_h,					/* Hoehe eines Buchstabens in Pixeln */
			spaceChar_w,			/* Breite eines Leerzeichens */
			colors;					/* # der gleichzeitig darstellbaren Farben */
	WORD	img_size,
			img_width;
	BOOLEAN draw_3d;				/* bei >=16 Farben wird der Dialog mit 3D-Effekt gezeichnet */
	WORD	backgrd_color;			/* Hintergrundfarbe des Dialogs */
	WORD	uline_color;			/* Farbe des Unterstrichs */

	/* Variablen fuer die Dialoghintergrund-Box */
	BOOLEAN	backgrdborder;			/* 3D Rahmen beim Hintergrund */
} USERDEF;

#ifdef USERDEF_LIB
USERDEF *userdef = NULL;
#else
extern USERDEF *userdef;
#endif

#define IMGSIZE_16X16	1
#define IMGSIZE_16X8	2
#define IMGSIZE_NONE	3

typedef struct {
	LONG		magic;				/* 'DIRK' ist Magic value */
#ifdef __GNUC__
	U_OB_SPEC	ob_spec;			/* alter Wert von ob_spec */
#else
	OBSPEC		ob_spec;			/* alter Wert von ob_spec */
#endif
	UWORD		ob_type;			/* alter Objekttyp */
	GRECT		ob_size;			/* alte Objektgroesse */
	WORD		te_just,			/* VDI-Textjustierung */
				te_rahmencol,		/* VDI-Rahmenfarbe */
				te_textcol,			/* VDI-Textfarbe */
				te_thickness;		/* Rahmendicke */
    BYTE		*text;				/* enthaelt den Text des Objektes */
	WORD		uline_pos;			/* Buchstabenposition der unterstrichen werden muss */

	/* Variablen fuer die Dialoghintergrund-Box */
	WORD		backgrdoffset[4],	/* Offset in Pixeln der entsprechenden Richtungen */
				backgrdborderline;	/* zusaetzlich eine schwarze Linie um den Rahmen */
	BOOLEAN		isPopup;			/* kennzeichnet, ob es sich um den Hintergrund eines Popups handelt */

	/* Variablen fuer Separatoren */
	BOOLEAN		isMenu,				/* kennzeichnet, ob dieser Separator in der Menueleiste ist */
				separator3d;		/* 3D-Effekt */
#ifdef _USR_EDITFIELD_
	/* Variablen fuer scrollbare Editfelder */
	WORD		scrollOffset,
				cursorIndex;		/* Position des Cursors im Editfeld */
#endif
} UBPARM;

/*
 * Die lineare Liste, in der alle tastaturbedienbaren Objekte aufge-
 * fuehrt sind.
 */
typedef struct dial {
	BYTE		key[20];			/* Klartext der gedrueckten Taste */
	WORD		object,				/* Nummer des zugehoerigen Objekts */
				title;

	struct dial	*next;				/* Zeiger auf das naechste tastaturbedienbare Objekt */
} DIALKEYS;

/*
 * Die lineare Liste, in der alle Karteikarten eines Dialoges
 * aufgefuehrt sind.
 */
#define MAXOBJECTS	256

typedef struct card {
	BOOLEAN		top;				/* TRUE, wenn aktiv */
	WORD		head,				/* Kartenreiter + */
				body;				/* Karte, die zusammen gehoeren */
	OBJECT		*objectTree;
	WORD		savedObjectFlags[MAXOBJECTS];
	void		(*redraw)(OBJECT *objectBodyTree, WORD objectBodyIdx, WORD x, WORD y, WORD w, WORD h);
	struct card *next;				/* Zeiger auf naechste Karteikarte */
} CARD;

/*
 * Returncodes
 */
#define USR_NOERROR			0
#define USR_NOVDIHANDLE		1
#define USR_NOTINSTALLED	2
#define USR_OUTOFMEMORY		3
#define USR_NOOBJECT		4
#define USR_UNKNOWNUSERDEF	5

/*
 * Erweiterte Objekttypen fuer die Userdefined Objects.
 */
#define BACKGRDBOX	15				/* Dialoghintergrund */
#define ARROWBUT	16				/* Pfeil-Buttons */
#define DCRBUTTON	18				/* Checkboxen/Radiobuttons/Exitbuttons */
#define UNDERLINE	19				/* Ueberschrift */
#define GROUPBOX	20				/* Gruppenbox */
#define TRANSTEXT	25				/* transparente Textobjekte */
#define CARDBOX		30				/* Karteikartenbox */
#define CARDTITLE	31				/* Karteikartenreiter */
#define CARDLINE	32				/* Karteikartenlinie */
#define SEPARATOR	40				/* Separatoren horizontal/vertikal */

WORD cdecl arrowbutton(PARMBLK *parmblock);
WORD cdecl backgrdbox(PARMBLK *parmblock);
WORD cdecl cardbox(PARMBLK *parmblock);
WORD cdecl cardtitle(PARMBLK *parmblock);
WORD cdecl cardline(PARMBLK * parmblk);
WORD cdecl checkbox(PARMBLK *parmblock);
WORD cdecl exitbutton(PARMBLK *parmblock);
WORD cdecl groupbox(PARMBLK *parmblock);
WORD cdecl radiobutton(PARMBLK *parmblock);
WORD cdecl separator(PARMBLK *parmblock);
WORD cdecl transtext(PARMBLK *parmblock);
WORD cdecl underline(PARMBLK *parmblock);

/*------------------------------------------------------------------*/
/*  global function prototypes                                       */
/*------------------------------------------------------------------*/

/* Module 'dudolib.c' */
WORD initDudolib(void);
void releaseDudolib(void);
WORD setUserdefs(OBJECT *tree, BOOLEAN isMenu);
WORD unsetUserdefs(OBJECT *objectTree);
#ifdef __GNUC__
U_OB_SPEC get_obspec(OBJECT *tree, WORD object);
#else
OBSPEC get_obspec(OBJECT *tree, WORD object);
#endif
LONG get_obtype(OBJECT *tree, WORD object);
void set3dLook(BOOLEAN flag);
BOOLEAN get3dLook(void);
WORD getBackgroundColor(void);
void setShortcutLineColor(WORD color);
WORD getShortcutLineColor(void);

void clearObject(PARMBLK *parmblock);
void v_xgtext(WORD x, WORD y, WORD text_effects, UBPARM *ubparm, PARMBLK *parmblk);
void clipping(PARMBLK *parmblock, BOOLEAN useClipping);

/* Module 'objhelp.c' */
WORD getObjectParent(OBJECT *objectTree, WORD objectIdx);
BYTE *getObjectText(OBJECT *objectTree, WORD objectIdx);
WORD setObjectText(OBJECT *objectTree, WORD objectIdx, BYTE *text);
BOOLEAN getObjectFlags(OBJECT *objectTree, WORD objectIdx, BOOLEAN objectFlags);
void setObjectFlags(OBJECT *objectTree, WORD objectIdx, WORD objectFlags, BOOLEAN set);
BOOLEAN getObjectState(OBJECT *objectTree, WORD objectIdx, BOOLEAN objectState);
BOOLEAN isObjectSelected(OBJECT *objectTree, WORD objectIdx);
BOOLEAN isObjectDisabled(OBJECT *objectTree, WORD objectIdx);
void setObjectState(OBJECT *objectTree, WORD objectIdx, WORD objectState, BOOLEAN set);
void setObjectSelected(OBJECT *objectTree, WORD objectIdx);
void unsetObjectSelected(OBJECT *objectTree, WORD objectIdx);
void setObjectDisabled(OBJECT *objectTree, WORD objectIdx);
void unsetObjectDisabled(OBJECT *objectTree, WORD objectIdx);

/* Module 'backgrd.c' */
BOOLEAN getBackgroundBorder(void);
void setBackgroundBorder(BOOLEAN flag);
void setBackgroundBorderOffset(OBJECT *objectTree, WORD objectIdx, WORD x, WORD y, WORD w, WORD h);
BOOLEAN getBackgroundBorderLine(OBJECT *objectTree, WORD objectIdx);
void setBackgroundBorderLine(OBJECT *objectTree, WORD objectIdx, BOOLEAN flag);

/* Module 'dialkeys.c' */
DIALKEYS *create_dialkeys(OBJECT *tree);
DIALKEYS *create_menukeys(OBJECT *tree);
void remove_dialkeys(DIALKEYS *dialkeys);
WORD add_dialkeys(DIALKEYS **dialkeys, WORD object, char *keystring);
void key_change(WORD shift, UWORD key, char *keys);
void change_key(WORD shift, WORD key, char *keys);
WORD find_object(DIALKEYS *dialkeys, char *keystring);
void get_menue_item(DIALKEYS *dialkeys, char *keystring, WORD *title, WORD *item);

/* Module 'card.c' */
short cardAdd(CARD **card, OBJECT *objectTree, WORD objectHeadIdx, WORD objectBodyIdx);
void cardRemoveAll(CARD *card);
void setCardRedraw(CARD *card, void(*redraw)(OBJECT *objectBodyTree, WORD objectBodyIdx, WORD x, WORD y, WORD w, WORD h));
void cardDisable(CARD *card, WORD objectHeadIdx);
void cardEnable(CARD *card, WORD objectHeadIdx);
CARD *getActiveCard(CARD *card);
short getActiveCardBodyIdx(CARD *card);
void setActiveCard(CARD *card, short objectHeadIdx, BOOLEAN redraw);

#ifdef _USR_EDITFIELD_
WORD getScrollOffset(OBJECT *tree, WORD object);
void setScrollOffset(OBJECT *tree, WORD object, WORD scrollOffset);
WORD getCursorIndex(OBJECT *tree, WORD object);
void setCursorIndex(OBJECT *tree, WORD object, WORD cursorIndex);
#endif

#endif
