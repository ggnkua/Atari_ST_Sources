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

#define USERDEF_LIB
#include "..\include\dudolib.h"

#include <stdio.h>
#include <string.h>
#include <mintbind.h>

#pragma warn -rpt
#pragma warn -sus
#include ".\rsrc\userimg.h"
#include ".\rsrc\userimg.rsh"
#pragma warn +rpt
#pragma warn +sus

/*------------------------------------------------------------------*/
/*  global variables                                                */
/*------------------------------------------------------------------*/
/*
 * Variablen, die die Images enthalten.
 */
UWORD CheckBoxSelected[64],				/* Checkbox angewaehlt */
	CheckBoxNormalDisabled[64],			/* Checkbox normal + disabled */
	CheckBoxSelectedDisabled[64];		/* 3D-Checkbox angewaehlt + disabled */
UWORD RadioButtonNormal[64],			/* Radiobutton normal */
	RadioButtonSelected[64];			/* Radiobutton angewaehlt */
UWORD RadioButtonNormalDisabled[64],	/* Radiobutton normal + disabled */
	RadioButtonSelectedDisabled[64],	/* Radiobutton angewaehlt + disabled */
	RadioButtonNormalBackgrd[64],
	RadioButtonNormalBackgrdLBLACK[64],
	RadioButtonSelectedBackgrd[64],
	RadioButtonSelectedBackgrdLBLACK[64];
UWORD arupnorm[64], arupnormdis[64], arupsel[64],
	ardnnorm[64], ardnnormdis[64], ardnsel[64],
	arltnorm[64], arltnormdis[64], arltsel[64],
	arrtnorm[64], arrtnormdis[64], arrtsel[64];

/*------------------------------------------------------------------*/
/*  local variables                                                 */
/*------------------------------------------------------------------*/
static BOOLEAN fontsLoaded = FALSE;

/*------------------------------------------------------------------*/
/*  local function prototypes                                       */
/*------------------------------------------------------------------*/
#if 0
static void fix_editfield(OBJECT *objectTree);
#endif
static void fixPopup(OBJECT *objectTree, WORD objectIdx);
static WORD set_BOX(OBJECT *objectTree, WORD object, UBPARM *ubparm);
static WORD set_BUTTON(OBJECT *objectTree, WORD object, UBPARM *ubparm);
#ifdef _USR_EDITFIELD_
static WORD set_TEXT(OBJECT *objectTree, WORD object, UBPARM *ubparm, BOOLEAN isEditfield);
#else
static WORD set_TEXT(OBJECT *objectTree, WORD object, UBPARM *ubparm);
#endif
static void set_arrowbut(OBJECT *objectTree, WORD object, USERBLK *userblk, UBPARM *ubparm);
static void set_dcrbutton(OBJECT *objectTree, WORD object, USERBLK *userblk, UBPARM *ubparm);
static void set_underline(OBJECT *objectTree, WORD object, UBPARM *ubparm);
#if 0
static void objc_create(OBJECT *objectTree, WORD obj, WORD next, WORD head, WORD tail,
		WORD type, WORD flags, WORD state, LONG spec, WORD x, WORD y, WORD w,
		WORD h);
#endif
static void transformImages(void);
static BOOLEAN get_cookie(LONG cookie, LONG *value);

/*------------------------------------------------------------------*/
/*  local definitions                                               */
/*------------------------------------------------------------------*/
/* AES-Font Cookie-Struktur */
typedef struct {
	LONG af_magic;		/* AES-Font ID (AFnt) */
	WORD version;		/* Highbyte Cookieversion (BCD-Format) */
	/* Lowbyte Programmversion (BCD-Format) */
	WORD installed;		/* Flag fuer Fonts angemeldet */
	WORD cdecl (*afnt_getinfo)(WORD af_gtype, WORD *af_gout1, WORD *af_gout2, WORD *af_gout3, WORD *af_gout4);
} AFNT;

/**
 * Diese Routine initialisiert die userdefinierten Objekte und oeffnet
 * fuer diese eine eigene VDI-Workstation.
 *
 * Rueckgabe-Variablen:
 *
 * Type WORD:
 *   als Return-Code werden folgende Werte zurueckgegeben:
 *
 *   USR_NOERROR       - kein Fehler/alles Ok
 *   USR_NOVDIHANDLE   - es konnte kein VDI-Handle benatragt werden
 *   USR_OUTOFMEMORY   - kein Speicher mehr frei
 */
WORD initDudolib(void) {
	WORD work_in[11] = { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2 }, work_out[57];
	WORD aeschar_w, aeschar_h, extentSpace[8], du;
	WORD fontheight, fontid, fonttype;
	WORD attrib[10];

#ifdef MEMDEBUG
	set_MemdebugOptions(c_On, c_On, c_On, c_On, c_On, c_Off, c_Off, c_Off, c_Off, "dudolib.out", "dudolib.err");
#endif

	userdef = (USERDEF *) malloc(sizeof(USERDEF));
	if (userdef == NULL)
		return (USR_OUTOFMEMORY);

	/* VDI-Workstation oeffnen. */
	userdef->vdi_handle = graf_handle(&aeschar_w, &aeschar_h, &du, &du);
	v_opnvwk(work_in, &(userdef->vdi_handle), work_out);
	if (userdef->vdi_handle <= 0) {
		free(userdef);
		userdef = NULL;
		return (USR_NOVDIHANDLE);
	}

	/* AES Font ermitteln und in dieser Groesse fuer die virtuelle Workstation setzen. */
	if (vq_gdos() != 0 && appl_xgetinfo(0, &fontheight, &fontid, &fonttype, &du) > 0) {
		/* Workaround fuer WDIALOG-Problem mit N.AES */
		while ((fontid == 0) && (fontheight == 0)) {
			evnt_timer(100L);
			appl_xgetinfo(0, &fontheight, &fontid, &fonttype, &du);
		}
		if (fontid != vst_font(userdef->vdi_handle, fontid)) {
			vst_load_fonts(userdef->vdi_handle, 0);
			fontsLoaded = TRUE;
		}

		vst_font(userdef->vdi_handle, fontid);
		vst_height(userdef->vdi_handle, fontheight, &du, &du, &userdef->char_w, &userdef->char_h);
	} else {
		vqt_attributes(userdef->vdi_handle, attrib);
		userdef->char_w = attrib[8];
		userdef->char_h = attrib[9];
	}

	/* Breite eines Leerzeichens ermitteln. */
	vqt_extent(userdef->vdi_handle, " ", extentSpace);
	userdef->spaceChar_w = extentSpace[2];

	/*
	 * Mittels der Systemfontgroesse feststellen, ob es Images in der
	 * richtigen Groesse gibt.
	 */
	if (userdef->char_h == 16 && userdef->char_w == 8)
		userdef->img_size = IMGSIZE_16X16;
	else if (userdef->char_h == 8 && userdef->char_w == 8)
		userdef->img_size = IMGSIZE_16X8;
	else
		userdef->img_size = IMGSIZE_NONE;

	if (userdef->char_w == userdef->char_h)
		userdef->img_width = 2 * userdef->char_w;
	else
		userdef->img_width = userdef->char_h;

	userdef->colors = work_out[13];

	/* default Einstellungen */
	vsf_perimeter(userdef->vdi_handle, 0);
	vsf_interior(userdef->vdi_handle, FIS_SOLID);

	if (userdef->colors < 16) {
		set3dLook(FALSE);
	} else {
		set3dLook(TRUE);
		setShortcutLineColor(G_RED);
	}
	setBackgroundBorder(TRUE);

	/* Images ins geraeteabhaengige Format konvertieren, falls fuer Fontgroesse vorhanden. */
	if (userdef->img_size != IMGSIZE_NONE)
		transformImages();

	return (USR_NOERROR);
}

/**
 * Diese Methode schliesst die VDI-Workstation und gibt die Struktur der Bibliothek
 * frei. Sie sollte vor Programmende aufgerufen werden.
 */
void releaseDudolib(void) {
	if (userdef == NULL)
		return;

	if (fontsLoaded == TRUE)
		vst_unload_fonts(userdef->vdi_handle, 0);

	v_clsvwk(userdef->vdi_handle);
	free(userdef);
	userdef = NULL;
}

/**
 * Diese Routine installiert die Userdefined Objects fuer einen bestimmten Dialog.
 *
 * @param *objectTree Zeiger auf Objekt-Baum, in dem Userdef's installiert werden sollen.
 * @param is_menu bei dem Objekt-Baum handelt es sich um eine Menueleiste (TRUE) oder nicht (FALSE)
 *
 * @return USR_NOERROR       - kein Fehler/alles Ok
 *         USR_NOTINSTALLED  - die Library wurde noch nicht initialisiert.
 *         USR_OUTOFMEMORY   - kein Speicher mehr frei.

 * Eingabe-Variablen:
 *
 * Typ BOOLEAN:
 *   is_menu - gibt an, ob der uebergebene Baum eine Menueleiste
 *             ist (TRUE) oder nicht (FALSE).
 * Typ OBJECT:
 *   *objectTree   - Zeiger auf den Dialog, in dem Userdef's installiert
 *             werden sollen.
 *
 * Rueckgabe-Variablen:
 *
 * Typ WORD:
 *   als Return-Code werden folgende Werte zurueckgegeben:
 *
 *   USR_NOERROR       - kein Fehler/alles Ok
 *   USR_NOTINSTALLED  - die Library wurde noch nicht initialisiert.
 *   USR_OUTOFMEMORY   - kein Speicher mehr frei.
 */
WORD setUserdefs(OBJECT *objectTree, BOOLEAN isMenu) {
#ifdef _USR_EDITFIELD_
	BOOLEAN isEditfield = FALSE;
#endif
	WORD i = -1;
	USERBLK *userblk;
	UBPARM *ubparm;

	if (userdef == NULL)
		return (USR_NOTINSTALLED);

	if (isMenu == TRUE) {
		/* Menue-Baum durchlaufen */
		do {
			++i;

			if ((objectTree[i].ob_type & 0xFF) == G_STRING) {
				if ((objectTree[i].ob_state & DISABLED) && (objectTree[i].ob_spec.free_string[0] == '-')) {
					userblk = (USERBLK *) malloc(sizeof(USERBLK));
					if (userblk == NULL)
						return (USR_OUTOFMEMORY);

					ubparm = (UBPARM *) malloc(sizeof(UBPARM));
					if (ubparm == NULL) {
						free(userblk);
						return (USR_OUTOFMEMORY);
					}

					/* Menueleisten-Trenner ist ein Separator mit best. Aussehen */
					ubparm->te_rahmencol = G_LBLACK;
					ubparm->te_thickness = 2;
					ubparm->isMenu = TRUE;
					ubparm->separator3d = FALSE;
					userblk->ub_code = separator;
					userblk->ub_parm = (LONG) ubparm;

					objectTree[i].ob_type &= 0xff00U;
					objectTree[i].ob_type |= G_USERDEF;
					objectTree[i].ob_spec.userblk = userblk;
				}
			}
		} while (!(objectTree[i].ob_flags & LASTOB));
	} else {
		do {
			++i;

			/*
			 * MagiC kompatible Objekttypen auf meine umbiegen, aber
			 * nur wenn noch kein erweiterter Objekttyp eingetragen
			 * wurde.
			 */
			if ((objectTree[i].ob_state & WHITEBAK) && (objectTree[i].ob_type & 0xFF00) == 0) {
				switch (objectTree[i].ob_type & 0xff) {
				case G_STRING:
					if ((objectTree[i].ob_state >> 8) == 255) {
						objectTree[i].ob_type &= 0xFF;
						objectTree[i].ob_type |= UNDERLINE << 8;
					} else {
						objectTree[i].ob_type &= 0xFF;
						objectTree[i].ob_type |= TRANSTEXT << 8;
					}
					break;
				case G_BUTTON:
					objectTree[i].ob_type &= 0xFF;
					objectTree[i].ob_type |= DCRBUTTON << 8;
					break;
				}
			}

			if ((i == 0) && (objectTree[i].ob_type & 0xff) == G_BOX && (objectTree[i].ob_state & OUTLINED)) {
				objectTree[i].ob_type &= 0xFF;
				objectTree[i].ob_type |= BACKGRDBOX << 8;
			}

#ifdef _USR_EDITFIELD_
			if ((objectTree[i].ob_flags & EDITABLE) && (objectTree[i].ob_type >> 8) > 0)
				isEditfield = TRUE;
			else
				isEditfield = FALSE;
#endif
	
			/*
			 * Ist ein erweiterter Objekttyp eingetragen? Wenn, so
			 * wird ueberprueft, welcher Userdef gesetzt werden muss.
			 */
#ifdef _USR_EDITFIELD_
			if ((objectTree[i].ob_type >> 8) > 0 || isEditfield == TRUE) {
#else
			if ((objectTree[i].ob_type >> 8) > 0) {
#endif
				userblk = (USERBLK *) malloc(sizeof(USERBLK));
				if (userblk == NULL)
					return (USR_OUTOFMEMORY);

				ubparm = (UBPARM *) malloc(sizeof(UBPARM));
				if (ubparm == NULL) {
					free(userblk);
					return (USR_OUTOFMEMORY);
				}

				/* es ist ein userdefined object dieser Library */
				ubparm->magic = 'DIRK';

				/* alte Objekt-Strukturen merken */
				ubparm->ob_spec = objectTree[i].ob_spec;
				ubparm->ob_type = objectTree[i].ob_type;
				ubparm->ob_size.g_x = objectTree[i].ob_x;
				ubparm->ob_size.g_y = objectTree[i].ob_y;
				ubparm->ob_size.g_w = objectTree[i].ob_width;
				ubparm->ob_size.g_h = objectTree[i].ob_height;

				/* Default-Werte setzen. */
				ubparm->uline_pos = -1;
				ubparm->te_just = TA_LEFT;
				ubparm->te_rahmencol = G_BLACK;
				ubparm->te_textcol = G_BLACK;
				ubparm->te_thickness = 1;
				ubparm->text = "";

				/*
				 * UBPARM-Struktur mit den Werten des Objekt-Typs
				 * fuellen.
				 */
				switch (objectTree[i].ob_type & 0xFF) {
				case G_BOX:
				case G_IBOX:
				case G_BOXCHAR:
					if (set_BOX(objectTree, i, ubparm) == USR_OUTOFMEMORY) {
						free(userblk);
						free(ubparm);
						return (USR_OUTOFMEMORY);
					}
					break;

				case G_STRING:
				case G_BUTTON:
					if (set_BUTTON(objectTree, i, ubparm) == USR_OUTOFMEMORY) {
						free(userblk);
						free(ubparm);
						return (USR_OUTOFMEMORY);
					}
					break;

				case G_TEXT:
				case G_BOXTEXT:
				case G_FTEXT:
				case G_FBOXTEXT:
#ifdef _USR_EDITFIELD_
					if (set_TEXT(objectTree, i, ubparm, isEditfield) == USR_OUTOFMEMORY) {
#else
					if (set_TEXT(objectTree, i, ubparm) == USR_OUTOFMEMORY) {
#endif
						free(userblk);
						free(ubparm);
						return (USR_OUTOFMEMORY);
					}
					break;
				}

				/*
				 * UBPARM-Struktur einhaengen und Typ G_USERDEF
				 * setzen.
				 * VORSICHT: Jetzt darf auf 'ob_type' und 'op_spec'
				 * nur noch ueber ubparm->ob_type und ubparm->ob_spec
				 * zugegriffen werden.
				 */
				userblk->ub_parm = (LONG) ubparm;
				objectTree[i].ob_type &= 0xff00U;
				objectTree[i].ob_type |= G_USERDEF;
				objectTree[i].ob_spec.userblk = userblk;

				/*
				 * Nun noch die Zeichenroutinen einhaengen.
				 */
#ifdef _USR_EDITFIELD_
				if (isEditfield == TRUE) {
					printf("editfield\n");
					ubparm->scrollOffset = 0;
					ubparm->cursorIndex = 0;
					objectTree[i].ob_flags &= ~EDITABLE;
					userblk->ub_code = backgrdbox;
				} else {
#endif
					switch (ubparm->ob_type >> 8) {
					case BACKGRDBOX:
						if (objectTree[i].ob_state & SHADOWED) {
							ubparm->isPopup = TRUE;
							fixPopup(objectTree, i);

							objectTree[i].ob_width += 7;
							objectTree[i].ob_height += 7;
						} else
							ubparm->isPopup = FALSE;

						objectTree[i].ob_state = NORMAL;
						ubparm->ob_spec.obspec.framesize = 0;
						userblk->ub_code = backgrdbox;

						setBackgroundBorderLine(objectTree, i, FALSE);
						setBackgroundBorderOffset(objectTree, i, 0, 0, 0, 0);
						break;

					case ARROWBUT:
						userblk->ub_code = arrowbutton;
/*						set_arrowbut(objectTree, i, userblk, ubparm);*/
						break;

					case DCRBUTTON:
						set_dcrbutton(objectTree, i, userblk, ubparm);
						break;

					case UNDERLINE:
						userblk->ub_code = underline;
						break;

					case TRANSTEXT:
						set_underline(objectTree, i, ubparm);
						userblk->ub_code = transtext;
						break;

					case GROUPBOX:
						userblk->ub_code = groupbox;
						break;

					case CARDBOX:
						objectTree[i].ob_width += 2;
						userblk->ub_code = cardbox;
						break;

					case CARDTITLE:
						objectTree[i].ob_height++;
						set_underline(objectTree, i, ubparm);
						userblk->ub_code = cardtitle;
						break;

					case CARDLINE:
						objectTree[i].ob_height++;
						objectTree[i].ob_width += 2;
						userblk->ub_code = cardline;
						break;

					case SEPARATOR:
						ubparm->isMenu = FALSE;
						if (objectTree[i].ob_state & DRAW3D)
							ubparm->separator3d = TRUE;
						else
							ubparm->separator3d = FALSE;

						userblk->ub_code = separator;
						break;

					default:
						/*
						 * Es gibt kein passendes Userdefined Object,
						 * deshalb muss der dafuer allozierte Speicher
						 * wieder freigegeben werden.
						 */
						objectTree[i].ob_spec = ubparm->ob_spec;
						objectTree[i].ob_type = ubparm->ob_type;
						free(userblk);
						free(ubparm);
					} /* switch */
#ifdef _USR_EDITFIELD_
				}
#endif
			}
		} while (!(objectTree[i].ob_flags & LASTOB));
	}

	return (USR_NOERROR);
}

/**
 * Mittels dieser Routine koennen die Userdefined Objects aus einem
 * Objektbaum wieder entfernt werden. Der reservierte Speicher wird
 * freigegeben.
 *
 * Eingabe-Variablen:
 *
 * Typ OBJECT:
 *   *objectTree - Zeiger auf den Objektbaum
 *
 * Rueckgabe-Variablen:
 *
 * Type WORD:
 *   als Return-Code werden folgende Werte zurueckgegeben:
 *
 *   USR_NOERROR       - kein Fehler/alles Ok
 */
WORD unsetUserdefs(OBJECT *objectTree) {
	WORD i = -1;
	LONG magic = -1l;
	USERBLK *userblk;
	UBPARM *ubparm;

	if (objectTree == NULL)
		return (USR_NOOBJECT);

	do {
		++i;

		if ((objectTree[i].ob_type & 0x00ff) == G_USERDEF) {
			userblk = objectTree[i].ob_spec.userblk;
			if ((ubparm = (UBPARM *) userblk->ub_parm) != NULL && ubparm->magic == 'DIRK') {
				magic = ubparm->magic;
				objectTree[i].ob_spec = ubparm->ob_spec;
				objectTree[i].ob_type = ubparm->ob_type;
				objectTree[i].ob_x = ubparm->ob_size.g_x;
				objectTree[i].ob_y = ubparm->ob_size.g_y;
				objectTree[i].ob_width = ubparm->ob_size.g_w;
				objectTree[i].ob_height = ubparm->ob_size.g_h;

				if (ubparm->text != NULL)
					free(ubparm->text);
				free(ubparm);
			}
			if (magic == 'DIRK') {
				if (userblk != NULL)
					free(userblk);
				magic = -1l;
			}
		}
	} while (!(objectTree[i].ob_flags & LASTOB));

	return (USR_NOERROR);
}

/**
 * Diese Methode liefert den OBSPEC des Userdefs.
 *
 * @param *objectTree Zeiger auf Objekt-Baum
 * @param objectIdx Objekt-Index des Text-Objekts im Objekt-Baum
 * @return
 */
#ifdef __GNUC__
U_OB_SPEC get_obspec(OBJECT *objectTree, WORD objectIdx) {
#else
OBSPEC get_obspec(OBJECT *objectTree, WORD objectIdx) {
#endif
	UBPARM *ubparm;

	if ((objectTree[objectIdx].ob_type & 0xFF) != G_USERDEF)
		return (objectTree[objectIdx].ob_spec);

	ubparm = (UBPARM *) objectTree[objectIdx].ob_spec.userblk->ub_parm;
	if (ubparm->magic == 'DIRK')
		return (ubparm->ob_spec);

	return (objectTree[objectIdx].ob_spec);
}

/**
 * Diese Methode liefert Object-Typ des allgemeinen Objekts oder des Userdefs.
 * Im Fall, dass es sich um ein fremdes Userdef handelt, wird NULL geliefert.
 *
 * @param *objectTree Zeiger auf Objekt-Baum
 * @param objectIdx Objekt-Index des Text-Objekts im Objekt-Baum
 * @return
 */
LONG get_obtype(OBJECT *objectTree, WORD objectIdx) {
	UBPARM *ubparm;

	if ((objectTree[objectIdx].ob_type & 0xFF) != G_USERDEF)
		return (objectTree[objectIdx].ob_type);

	ubparm = (UBPARM *) objectTree[objectIdx].ob_spec.userblk->ub_parm;
	if (ubparm->magic == 'DIRK')
		return (ubparm->ob_type);

	return (0L);
}

/**
 * Diese Methode liefert, ob zur Zeit 3D-Look verwendet wird (TRUE) oder nicht (FALSE).
 *
 * @return 3D-Look eingeschaltet (TRUE), ausgeschaltet (FALSE)
 */
BOOLEAN get3dLook(void) {
	if (userdef == NULL)
		return (FALSE);

	return (userdef->draw_3d);
}

/**
 * Mit dieser Methode kann der 3D-Look fuer alle benutzerdefinierten Objekte, die durch
 * diese Bibliothek verwaltet werden, ein- (TRUE) bzw. ausgeschaltet (FALSE) werden.
 * 3D-Look ist erst ab einer Farbtiefe von 16 moeglich.
 *
 * @param flag TRUE - 3D-Look verwenden, FALSE sonst
 */
void set3dLook(BOOLEAN flag) {
	if (userdef == NULL)
		return;

	if (flag == TRUE && userdef->colors >= 16) {
		userdef->draw_3d = TRUE;
		userdef->backgrd_color = G_LWHITE;
	} else {
		userdef->draw_3d = FALSE;
		userdef->backgrd_color = G_WHITE;
		setShortcutLineColor(G_BLACK);
	}
}

/**
 * Diese Methode liefert die aktuell verwendete Hintergrund-Farbe.
 *
 * @return Farbcode
 */
WORD getBackgroundColor(void) {
	if (userdef == NULL)
		return (G_BLACK);

	return (userdef->backgrd_color);
}

/**
 * Diese Methode liefert die aktuell verwendete Farbe der (Shortcut-)Taste.
 *
 * @return Farbcode
 */
WORD getShortcutLineColor(void) {
	if (userdef == NULL)
		return (G_BLACK);

	return (userdef->uline_color);
}

/**
 * Mit dieser Methode kann festgelegt werden in welcher Farbe der Unterstrich gezeichnet wird,
 * der anzeigt mit welcher (Shortcut-)Taste dieses Objekt angesprochen werden kann.
 *
 * @param color Farbcode
 */
void setShortcutLineColor(WORD color) {
	if (userdef == NULL)
		return;

	userdef->uline_color = color;
}

/*------------------------------------------------------------------*/
/*  private functions                                               */
/*------------------------------------------------------------------*/
#if 0
void fix_editfield(OBJECT *objectTree) {
	WORD i = -1,
	lastobj = -1;

	int test;

	do {
		++lastobj;
	} while (!(objectTree[lastobj].ob_flags & LASTOB));

	test = lastobj;
	do {
		i++;

		if (objectTree[i].ob_type == G_FTEXT) {
			/*
			 * Beim bisher letzten Objekt wird das Flag 'LASTOB'
			 * geloescht.
			 */
			objectTree[lastobj].ob_flags &= ~LASTOB;
			lastobj++;

			/*
			 * Neues Objekt erzeugen, das das Edit-Feld aufnehmen
			 * wird. Dieses wird zunaechst als letztes Objekt
			 * aufgenommen.
			 */
			objc_create(objectTree, lastobj, i, -1, -1,
					objectTree[i].ob_type, objectTree[i].ob_flags,
					objectTree[i].ob_state | LASTOB, (LONG)(objectTree[i].ob_spec.index),
					objectTree[i].ob_x, objectTree[i].ob_y,
					objectTree[i].ob_width, objectTree[i].ob_height);

			/*
			 * Das Edit-Feld durch die Box ersetzen.
			 */
			objectTree[i].ob_type = G_BUTTON|0x1300;
			objectTree[i].ob_flags &= ~EDITABLE;
			objectTree[i].ob_spec.free_string = "Test";

			/*
			 * Vater von dem Editfeld wird das neu erzeugte Objekt.
			 */
			objectTree[i].ob_head = lastobj;
			objectTree[i].ob_tail = lastobj;

			/*
			 * Das neue Objekt als Kind der Box hinzufuegen.
			 */
			/*			objc_add(objectTree, i, lastobj);*/

			/*
			 * Objektnummer des Edit-Feldes anpassen.
			 */
			/*			objc_order(objectTree, lastobj, i+1);*/
			/*			i++;*/

			/*	lastobj++;
			 objc_create(objectTree, lastobj, objectTree[i].ob_next, i, i,
			 G_BUTTON|0x0F00, 0x0400,
			 NORMAL|LASTOB, 0x00021100L,
			 objectTree[i].ob_x, objectTree[i].ob_y,
			 objectTree[i].ob_width, objectTree[i].ob_height);

			 /*
			 * Vater von dem Editfeld wird das neu erzeugte Objekt.
			 */
			/*	objectTree[i].ob_next = lastobj;*/

			/*
			 * Beim bisher letzten Objekt wird das Flag 'LASTOB' geloescht.
			 */
			objectTree[lastobj-1].ob_flags &= ~LASTOB;

			if (objectTree[objectTree[lastobj].ob_next].ob_head == lastobj)
			objectTree[objectTree[lastobj].ob_next].ob_head = lastobj;*/

			/*	objc_order(objectTree, lastobj, i-1);*/

		}

		/*objc_create(OBJECT *objectTree, WORD obj, WORD next, WORD head,
		 WORD tail, WORD type, WORD flags, WORD state,
		 LONG spec, WORD x, WORD y, WORD w, WORD h)

		 -1,        1,        1, G_BOX     ,   /* Object 0  */
		NONE, OUTLINED, (LONG)0x00021100L,
		0x0000, 0x0000, 0x0033, 0x000D,
		0, 2, 2, G_BUTTON |0x1900, /* Object 1  */
		SELECTABLE, NORMAL, (LONG)"Button",
		0x000B, 0x0802, 0x0015, 0x0001,
		1, -1, -1, G_FTEXT , /* Object 2  */
		EDITABLE|LASTOB, NORMAL, (LONG)&rs_tedinfo[0],
		0x0000, 0x0000, 0x000A, 0x0001*/

	} while (!(objectTree[i].ob_flags & LASTOB) && i < test);
}
#endif

/**
 *
 */
static void set_arrowbut(OBJECT *objectTree, WORD objectIdx, USERBLK *userblk, UBPARM *ubparm) {
	userblk->ub_code = arrowbutton;
	ubparm->text[0] = objectTree[objectIdx].ob_spec.obspec.character;
	ubparm->text[1] = EOS;
}

/**
 *
 */
static void fixPopup(OBJECT *objectTree, WORD objectIdx) {
	WORD j;

	j = objectTree[objectIdx].ob_head;
	if (j == NIL)
		return;

	do {
		objectTree[j].ob_x += 2;
		objectTree[j].ob_y += 2;
		j = objectTree[j].ob_next;
	} while (j != objectIdx);
}

/**
 *
 */
static void set_dcrbutton(OBJECT *objectTree, WORD object, USERBLK *userblk, UBPARM *ubparm) {
	WORD extent[8];

	set_underline(objectTree, object, ubparm);

	if ((objectTree[object].ob_flags & ~LASTOB) == TOUCHEXIT) {
		objectTree[object].ob_x--;
		objectTree[object].ob_y--;
		objectTree[object].ob_width += 2;
		objectTree[object].ob_height += 2;

		userblk->ub_code = exitbutton;
		return;
	}

	/* Exit-Button: EXIT, !RBUTTON */
	if ((objectTree[object].ob_flags & EXIT) && (objectTree[object].ob_flags & RBUTTON) == FALSE) {
		objectTree[object].ob_x -= 4;
		objectTree[object].ob_y -= 5;
		objectTree[object].ob_width += 8;
		objectTree[object].ob_height += 10;

		userblk->ub_code = exitbutton;
		return;
	}

	/* Radiobutton: RBUTTON */
	if (objectTree[object].ob_flags & RBUTTON) {
		userblk->ub_code = radiobutton;
	}
	/* Checkbox: !RBUTTON, !EXIT, !SHADOWED */
	else if ((objectTree[object].ob_flags & RBUTTON) == FALSE
			&& (objectTree[object].ob_flags & EXIT) == FALSE
			&& (objectTree[object].ob_flags & SHADOWED) == FALSE) {
		userblk->ub_code = checkbox;
	}
	/*
	 * Da noch die Checkbox oder der Radiobutton davorgezeichnet wird,
	 * muss die Breite des Objekts vergroessert werden.
	 * Bei Zeichenbreite 8 kommen 3 Zeichen dazu, sonst 2.
	 * Zur gleichen Zeit wird dann auch noch die Objektlaenge auf die
	 * richtige gestutzt, damit bei einem Hintergrund <> Weiss keine
	 * unschoenen Pixel bleiben, wenn das Objekt disabled ist.
	 */
	vqt_extent(userdef->vdi_handle, ubparm->text, extent);

	if (userdef->char_w <= 8)
		objectTree[object].ob_width = userdef->spaceChar_w * 3 + extent[2];
	else
		objectTree[object].ob_width = userdef->spaceChar_w * 2 + extent[2];
}

/**
 *
 */
static WORD set_BOX(OBJECT *objectTree, WORD object, UBPARM *ubparm) {
	ubparm->text = (BYTE *) malloc(2);
	if (ubparm->text == NULL)
		return (USR_OUTOFMEMORY);

	ubparm->text[0] = objectTree[object].ob_spec.obspec.character;
	ubparm->text[1] = EOS;
	ubparm->te_rahmencol = objectTree[object].ob_spec.obspec.framecol;
	ubparm->te_textcol = objectTree[object].ob_spec.obspec.textcol;
	ubparm->uline_pos = -1;

	return (USR_NOERROR);
}

/**
 *
 */
static WORD set_BUTTON(OBJECT *objectTree, WORD object, UBPARM *ubparm) {
	ubparm->text = (BYTE *) malloc(strlen(objectTree[object].ob_spec.free_string) + 1);
	if (ubparm->text == NULL)
		return (USR_OUTOFMEMORY);

	strcpy(ubparm->text, objectTree[object].ob_spec.free_string);

	if (objectTree[object].ob_state & WHITEBAK) {
		objectTree[object].ob_type &= 0xFF;
		objectTree[object].ob_type |= 18 << 8;
	}

	return (USR_NOERROR);
}

/**
 *
 */
#ifdef _USR_EDITFIELD_
static WORD set_TEXT(OBJECT *objectTree, WORD object, UBPARM *ubparm, BOOLEAN isEditfield) {
	if (isEditfield == TRUE) {
		ubparm->text = (BYTE *) malloc((ubparm->ob_type >> 8) + 1);
		if (ubparm->text == NULL)
			return (USR_OUTOFMEMORY);

		ubparm->ob_spec.tedinfo->te_ptext = ubparm->text;
	} else {
#else
static WORD set_TEXT(OBJECT *objectTree, WORD object, UBPARM *ubparm) {
#endif
		ubparm->text = (BYTE *) malloc(strlen(objectTree[object].ob_spec.tedinfo->te_ptext) + 1);
		if (ubparm->text == NULL)
			return (USR_OUTOFMEMORY);

		strcpy(ubparm->text, objectTree[object].ob_spec.tedinfo->te_ptext);
#ifdef _USR_EDITFIELD_
	}
#endif

	switch (objectTree[object].ob_spec.tedinfo->te_just) {
	case TE_LEFT:
		ubparm->te_just = TA_LEFT;
		break;

	case TE_RIGHT:
		ubparm->te_just = TA_RIGHT;
		break;

	case TE_CNTR:
		ubparm->te_just = TA_CENTER;
		break;
	}
	ubparm->te_rahmencol = (int) ((unsigned int) (objectTree[object].ob_spec.tedinfo->te_color) >> 12);
	ubparm->te_textcol = ((objectTree[object].ob_spec.tedinfo->te_color) >> 8) & 0x0F;
	ubparm->te_thickness = objectTree[object].ob_spec.tedinfo->te_thickness;
	if (ubparm->te_thickness < 0)
		ubparm->te_thickness *= -1;
	ubparm->uline_pos = -1;

	return (USR_NOERROR);
}

/**
 *
 */
void clearObject(PARMBLK *parmblock) {
	WORD pxy[4];

	pxy[0] = parmblock->pb_x;
	pxy[1] = parmblock->pb_y;
	pxy[2] = pxy[0] + parmblock->pb_w - 1;
	pxy[3] = pxy[1] + parmblock->pb_h - 1;

	vswr_mode(userdef->vdi_handle, MD_REPLACE);
	vsf_interior(userdef->vdi_handle, FIS_SOLID);
	vsf_color(userdef->vdi_handle, userdef->backgrd_color);
	v_bar(userdef->vdi_handle, pxy);
}

/**
 *
 */
void clipping(PARMBLK *parmblock, BOOLEAN useClipping) {
	WORD pxy[4];

	if (useClipping == TRUE) {
		pxy[0] = parmblock->pb_xc;
		pxy[1] = parmblock->pb_yc;
		pxy[2] = pxy[0] + parmblock->pb_wc - 1;
		pxy[3] = pxy[1] + parmblock->pb_hc - 1;
		vs_clip(userdef->vdi_handle, 1, pxy);
	} else
		vs_clip(userdef->vdi_handle, 0, pxy);
}

/**
 *
 */
static void set_underline(OBJECT *objectTree, WORD object, UBPARM *ubparm) {
	BYTE button_text[128];
	WORD i, j;

	/* Unterstrichposition feststellen. */
	strcpy(button_text, ubparm->text);/*ob_spec.free_string);*/

	ubparm->uline_pos = -1;

	if (objectTree[object].ob_state & WHITEBAK) {
		if (((objectTree[object].ob_state & ~0x8000) >> 8) != 0x7F)
			ubparm->uline_pos = (objectTree[object].ob_state & ~0x8000) >> 8;
/*		strcpy(ubparm->text, button_text);*/
	} else {
		i = j = 0;
		while (button_text[i] != EOS) {
			/*
			 * Wenn noch kein Unterstrich gefunden wurde und das
			 * aktuelle Zeichen '[' ist, so wird dieses aus dem String
			 * entfernt und die Position gemerkt, da an dieser Stelle
			 * der zu unterstreichende Buchstabe steht.
			 */
			if (button_text[i] == (BYTE) '[' && ubparm->uline_pos == -1)
				ubparm->uline_pos = i;
			else
				ubparm->text[j++] = button_text[i];

			i++;
		}
		ubparm->text[j] = EOS;
	}
}

/**
 *
 */
void v_xgtext(WORD x, WORD y, WORD text_effects, UBPARM *ubparm,
		PARMBLK *parmblk) {
	BYTE zeichen[2], temp[128];
	WORD extent[8];

	if (ubparm->uline_pos >= 0) {
		vst_effects(userdef->vdi_handle, text_effects | TF_UNDERLINED);

		if ((parmblk->pb_currstate & DISABLED) == FALSE
				&& ubparm->te_textcol != userdef->uline_color
				&& userdef->colors >= 16) {
			vst_color(userdef->vdi_handle, userdef->uline_color);
		} else
			vst_color(userdef->vdi_handle, ubparm->te_textcol);

		/*
		 * Laenge des Textstrings vor dem Zeichen, das unterstrichen
		 * werden soll, berechnen.
		 */
		strcpy(temp, ubparm->text);
		temp[ubparm->uline_pos] = EOS;
		vqt_extent(userdef->vdi_handle, temp, extent);
		zeichen[0] = ubparm->text[ubparm->uline_pos];
		zeichen[1] = EOS;

		v_gtext(userdef->vdi_handle, x + extent[2], y, zeichen);
	}
	vst_effects(userdef->vdi_handle, text_effects);
	vst_color(userdef->vdi_handle, ubparm->te_textcol);
	v_gtext(userdef->vdi_handle, x, y, ubparm->text);
}

#if 0
static void objc_create(OBJECT *objectTree, WORD obj, WORD next, WORD head, WORD tail,
		WORD type, WORD flags, WORD state, LONG spec, WORD x, WORD y, WORD w,
		WORD h) {
	objectTree[obj].ob_next = next;
	objectTree[obj].ob_head = head;
	objectTree[obj].ob_tail = tail;
	objectTree[obj].ob_type = type;
	objectTree[obj].ob_flags = flags;
	objectTree[obj].ob_state = state;
	objectTree[obj].ob_spec.index = spec;
	objectTree[obj].ob_x = x;
	objectTree[obj].ob_y = y;
	objectTree[obj].ob_width = w;
	objectTree[obj].ob_height = h;
}
#endif

static void transformImages(void) {
	WORD height;
	MFDB temp;
	MFDB checkbox_selected, checkbox_normaldisabled, checkbox_selecteddisabled;
	MFDB radiobutton_normal, radiobutton_selected;
	MFDB radiobutton_normaldisabled, radiobutton_selecteddisabled,
			radiobutton_normalbackgrd, radiobutton_normalbackgrdLBLACK,
			radiobutton_selectedbackgrd, radiobutton_selectedbackgrdLBLACK;
	MFDB arup_norm, arup_normdis, arup_sel, ardn_norm, ardn_normdis, ardn_sel,
			arlt_norm, arlt_normdis, arlt_sel, arrt_norm, arrt_normdis,
			arrt_sel;

	if (userdef->char_h < 16) {
		/* Kleiner Zeichensatz -> Images haben eine Hoehe von 8 Pixeln. */
		height = 8;

		memcpy((void *) CheckBoxSelected, rs_trindex[USERIMG][CBLSEL].ob_spec.bitblk->bi_pdata, 32L);
		memcpy((void *) CheckBoxNormalDisabled, rs_trindex[USERIMG][CBLNORMDIS].ob_spec.bitblk->bi_pdata, 32L);
		memcpy((void *) CheckBoxSelectedDisabled, rs_trindex[USERIMG][CBLSELDIS].ob_spec.bitblk->bi_pdata, 32L);

		memcpy((void *) RadioButtonNormal, rs_trindex[USERIMG][RBLNORM].ob_spec.bitblk->bi_pdata, 32L);
		memcpy((void *) RadioButtonSelected, rs_trindex[USERIMG][RBLSEL].ob_spec.bitblk->bi_pdata, 32L);
		memcpy((void *) RadioButtonNormalDisabled, rs_trindex[USERIMG][RBLNORMDIS].ob_spec.bitblk->bi_pdata, 32L);
		memcpy((void *) RadioButtonSelectedDisabled, rs_trindex[USERIMG][RBLSELDIS].ob_spec.bitblk->bi_pdata, 32L);
		memcpy((void *) RadioButtonNormalBackgrd, rs_trindex[USERIMG][RBLNORM_BGRD_3D].ob_spec.bitblk->bi_pdata, 32L);
		memcpy((void *) RadioButtonNormalBackgrdLBLACK, rs_trindex[USERIMG][RBLNORM_BGRD_LB].ob_spec.bitblk->bi_pdata, 32L);
		memcpy((void *) RadioButtonSelectedBackgrd, rs_trindex[USERIMG][RBLSEL_BGRD_3D].ob_spec.bitblk->bi_pdata, 32L);
		memcpy((void *) RadioButtonSelectedBackgrdLBLACK, rs_trindex[USERIMG][RBLSEL_BGRD_LB].ob_spec.bitblk->bi_pdata, 32L);

		memcpy((void *) arupnorm, rs_trindex[USERIMG][AUHNORM].ob_spec.bitblk->bi_pdata, 32L);
		memcpy((void *) arupsel, rs_trindex[USERIMG][AUHSEL].ob_spec.bitblk->bi_pdata, 32L);
		memcpy((void *) ardnnorm, rs_trindex[USERIMG][ADHNORM].ob_spec.bitblk->bi_pdata, 32L);
		memcpy((void *) ardnsel, rs_trindex[USERIMG][ADHSEL].ob_spec.bitblk->bi_pdata, 32L);
		memcpy((void *) arltnorm, rs_trindex[USERIMG][ALHNORM].ob_spec.bitblk->bi_pdata, 32L);
		memcpy((void *) arltsel, rs_trindex[USERIMG][ALHSEL].ob_spec.bitblk->bi_pdata, 32L);
		memcpy((void *) arrtnorm, rs_trindex[USERIMG][ARHNORM].ob_spec.bitblk->bi_pdata, 32L);
		memcpy((void *) arrtsel, rs_trindex[USERIMG][ARHSEL].ob_spec.bitblk->bi_pdata, 32L);
	} else {
		/* Standard Zeichensatz -> Images haben eine Hoehe von 16 Pixeln. */
		height = 16;

		memcpy((void *) CheckBoxSelected, rs_trindex[USERIMG][CBHSEL].ob_spec.bitblk->bi_pdata, 32L);
		memcpy((void *) CheckBoxNormalDisabled, rs_trindex[USERIMG][CBHNORMDIS].ob_spec.bitblk->bi_pdata, 32L);
		memcpy((void *) CheckBoxSelectedDisabled, rs_trindex[USERIMG][CBHSELDIS].ob_spec.bitblk->bi_pdata, 32L);

		memcpy((void *) RadioButtonNormal, rs_trindex[USERIMG][RBHNORM].ob_spec.bitblk->bi_pdata, 32L);
		memcpy((void *) RadioButtonSelected, rs_trindex[USERIMG][RBHSEL].ob_spec.bitblk->bi_pdata, 32L);
		memcpy((void *) RadioButtonNormalDisabled, rs_trindex[USERIMG][RBHNORMDIS].ob_spec.bitblk->bi_pdata, 32L);
		memcpy((void *) RadioButtonSelectedDisabled, rs_trindex[USERIMG][RBHSELDIS].ob_spec.bitblk->bi_pdata, 32L);
		memcpy((void *) RadioButtonNormalBackgrd, rs_trindex[USERIMG][RBHNORM_BGRD_3D].ob_spec.bitblk->bi_pdata, 32L);
		memcpy((void *) RadioButtonNormalBackgrdLBLACK, rs_trindex[USERIMG][RBHNORM_BGRD_LB].ob_spec.bitblk->bi_pdata, 32L);
		memcpy((void *) RadioButtonSelectedBackgrd, rs_trindex[USERIMG][RBHSEL_BGRD_3D].ob_spec.bitblk->bi_pdata, 32L);
		memcpy((void *) RadioButtonSelectedBackgrdLBLACK, rs_trindex[USERIMG][RBHSEL_BGRD_LB].ob_spec.bitblk->bi_pdata, 32L);

		memcpy((void *) arupnorm, rs_trindex[USERIMG][AUHNORM].ob_spec.bitblk->bi_pdata, 32L);
		memcpy((void *) arupnormdis, rs_trindex[USERIMG][AUHNORMDIS].ob_spec.bitblk->bi_pdata, 32L);
		memcpy((void *) arupsel, rs_trindex[USERIMG][AUHSEL].ob_spec.bitblk->bi_pdata, 32L);
		memcpy((void *) ardnnorm, rs_trindex[USERIMG][ADHNORM].ob_spec.bitblk->bi_pdata, 32L);
		memcpy((void *) ardnnormdis, rs_trindex[USERIMG][ADHNORMDIS].ob_spec.bitblk->bi_pdata, 32L);
		memcpy((void *) ardnsel, rs_trindex[USERIMG][ADHSEL].ob_spec.bitblk->bi_pdata, 32L);
		memcpy((void *) arltnorm, rs_trindex[USERIMG][ALHNORM].ob_spec.bitblk->bi_pdata, 32L);
		memcpy((void *) arltnormdis, rs_trindex[USERIMG][ALHNORMDIS].ob_spec.bitblk->bi_pdata, 32L);
		memcpy((void *) arltsel, rs_trindex[USERIMG][ALHSEL].ob_spec.bitblk->bi_pdata, 32L);
		memcpy((void *) arrtnorm, rs_trindex[USERIMG][ARHNORM].ob_spec.bitblk->bi_pdata, 32L);
		memcpy((void *) arrtnormdis, rs_trindex[USERIMG][ARHNORMDIS].ob_spec.bitblk->bi_pdata, 32L);
		memcpy((void *) arrtsel, rs_trindex[USERIMG][ARHSEL].ob_spec.bitblk->bi_pdata, 32L);
	}

	/* Hilfs-MFDB vorbelegen */
	temp.fd_w = 16;
	temp.fd_h = height;
	temp.fd_wdwidth = 1;
	temp.fd_stand = 1;
	temp.fd_nplanes = 1;
	checkbox_selected.fd_w = 16;
	checkbox_selected.fd_h = height;
	checkbox_selected.fd_wdwidth = 1;
	checkbox_selected.fd_stand = 0;
	checkbox_selected.fd_nplanes = 1;

	/* Check-Boxen in geraeteabhaengiges Format transferieren */
	checkbox_selected.fd_addr = temp.fd_addr = (void *) CheckBoxSelected;
	vr_trnfm(userdef->vdi_handle, &temp, &checkbox_selected);

	checkbox_normaldisabled = checkbox_selected;
	checkbox_normaldisabled.fd_addr = temp.fd_addr = (void *) CheckBoxNormalDisabled;
	vr_trnfm(userdef->vdi_handle, &temp, &checkbox_normaldisabled);

	checkbox_selecteddisabled = checkbox_selected;
	checkbox_selecteddisabled.fd_addr = temp.fd_addr = (void *) CheckBoxSelectedDisabled;
	vr_trnfm(userdef->vdi_handle, &temp, &checkbox_selecteddisabled);

	/* Radio-Buttons in geraeteabhaengiges Format transferieren */
	radiobutton_normal = checkbox_selected;
	radiobutton_normal.fd_addr = temp.fd_addr = (void *) RadioButtonNormal;
	vr_trnfm(userdef->vdi_handle, &temp, &radiobutton_normal);

	radiobutton_selected = checkbox_selected;
	radiobutton_selected.fd_addr = temp.fd_addr = (void *) RadioButtonSelected;
	vr_trnfm(userdef->vdi_handle, &temp, &radiobutton_selected);

	radiobutton_normaldisabled = checkbox_selected;
	radiobutton_normaldisabled.fd_addr = temp.fd_addr = (void *) RadioButtonNormalDisabled;
	vr_trnfm(userdef->vdi_handle, &temp, &radiobutton_normaldisabled);

	radiobutton_selecteddisabled = checkbox_selected;
	radiobutton_selecteddisabled.fd_addr = temp.fd_addr = (void *) RadioButtonSelectedDisabled;
	vr_trnfm(userdef->vdi_handle, &temp, &radiobutton_selecteddisabled);

	radiobutton_normalbackgrd = checkbox_selected;
	radiobutton_normalbackgrd.fd_addr = temp.fd_addr = (void *) RadioButtonNormalBackgrd;
	vr_trnfm(userdef->vdi_handle, &temp, &radiobutton_normalbackgrd);

	radiobutton_normalbackgrdLBLACK = checkbox_selected;
	radiobutton_normalbackgrdLBLACK.fd_addr = temp.fd_addr = (void *) RadioButtonNormalBackgrdLBLACK;
	vr_trnfm(userdef->vdi_handle, &temp, &radiobutton_normalbackgrdLBLACK);

	radiobutton_selectedbackgrd = checkbox_selected;
	radiobutton_selectedbackgrd.fd_addr = temp.fd_addr = (void *) RadioButtonSelectedBackgrd;
	vr_trnfm(userdef->vdi_handle, &temp, &radiobutton_selectedbackgrd);

	radiobutton_selectedbackgrdLBLACK = checkbox_selected;
	radiobutton_selectedbackgrdLBLACK.fd_addr = temp.fd_addr = (void *) RadioButtonSelectedBackgrdLBLACK;
	vr_trnfm(userdef->vdi_handle, &temp, &radiobutton_selectedbackgrdLBLACK);

	/* Arrows in geraeteabhaengiges Format transferieren */
	/* Pfeil hoch, normal */
	arup_norm = checkbox_selected;
	arup_norm.fd_addr = temp.fd_addr = (void *)arupnorm;
	vr_trnfm(userdef->vdi_handle, &temp, &arup_norm);
	/* Pfeil hoch, normal, disabled */
	arup_normdis = checkbox_selected;
	arup_normdis.fd_addr = temp.fd_addr = (void *)arupnormdis;
	vr_trnfm(userdef->vdi_handle, &temp, &arup_normdis);
	/* Pfeil hoch, selektiert */
	arup_sel = checkbox_selected;
	arup_sel.fd_addr = temp.fd_addr = (void *)arupsel;
	vr_trnfm(userdef->vdi_handle, &temp, &arup_sel);

	/* Pfeil runter, normal */
	ardn_norm = checkbox_selected;
	ardn_norm.fd_addr = temp.fd_addr = (void *)ardnnorm;
	vr_trnfm(userdef->vdi_handle, &temp, &ardn_norm);
	/* Pfeil runter, normal, disabled */
	ardn_normdis = checkbox_selected;
	ardn_normdis.fd_addr = temp.fd_addr = (void *)ardnnormdis;
	vr_trnfm(userdef->vdi_handle, &temp, &ardn_normdis);
	/* Pfeil runter, selektiert */
	ardn_sel = checkbox_selected;
	ardn_sel.fd_addr = temp.fd_addr = (void *)ardnsel;
	vr_trnfm(userdef->vdi_handle, &temp, &ardn_sel);

	/* Pfeil links, normal */
	arlt_norm = checkbox_selected;
	arlt_norm.fd_addr = temp.fd_addr = (void *)arltnorm;
	vr_trnfm(userdef->vdi_handle, &temp, &arlt_norm);
	/* Pfeil links, normal, disabled */
	arlt_normdis = checkbox_selected;
	arlt_normdis.fd_addr = temp.fd_addr = (void *)arltnormdis;
	vr_trnfm(userdef->vdi_handle, &temp, &arlt_normdis);
	/* Pfeil links, selektiert */
	arlt_sel = checkbox_selected;
	arlt_sel.fd_addr = temp.fd_addr = (void *)arltsel;
	vr_trnfm(userdef->vdi_handle, &temp, &arlt_sel);

	/* Pfeil rechts, normal */
	arrt_norm = checkbox_selected;
	arrt_norm.fd_addr = temp.fd_addr = (void *)arrtnorm;
	vr_trnfm(userdef->vdi_handle, &temp, &arrt_norm);
	/* Pfeil rechts, normal, disabled */
	arrt_normdis = checkbox_selected;
	arrt_normdis.fd_addr = temp.fd_addr = (void *)arrtnormdis;
	vr_trnfm(userdef->vdi_handle, &temp, &arrt_normdis);
	/* Pfeil rechts, selektiert */
	arrt_sel = checkbox_selected;
	arrt_sel.fd_addr = temp.fd_addr = (void *)arrtsel;
	vr_trnfm(userdef->vdi_handle, &temp, &arrt_sel);
}

/**
 *
 */
static BOOLEAN get_cookie(LONG cookie, LONG *value) {
	LONG oldstack, *cookiejar;

	/* Zeiger auf Cookiejar holen */
	if (Super((void *) 1L) == 0L) {
		oldstack = Super(0L);
		cookiejar = *((LONG **) 0x5a0L);
		Super((void *) oldstack);
	} else
		cookiejar = *(LONG **) 0x5a0;

	/* Ist der Cookiejar vorhanden ? */
	if (cookiejar == 0L)
		return (FALSE);

	do {
		if (cookiejar[0] == cookie) {
			if (value != NULL)
				*value = cookiejar[1];

			return (TRUE);
		} else
			cookiejar = &(cookiejar[2]);
	} while (cookiejar[-2]);

	return (FALSE);
}
