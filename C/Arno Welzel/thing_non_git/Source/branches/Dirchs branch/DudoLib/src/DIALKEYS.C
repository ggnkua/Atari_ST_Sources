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

#include "..\include\dudolib.h"

#include <string.h>
#include <ctype.h>
#ifdef __MINT__
#include <mintbind.h>
#else
#include <tos.h>
#endif

/**
 * Diese Routine laueft den Objektbaum durch und sucht nach tastatur-
 * bedienbaren Objekten. Werden welche gefunden, so wird eine
 * Dialkeys-Struktur fuer diesen Baum angelegt.
 *
 * @param *tree Zeiger auf Objekt-Baum
 *
 * @return DIALKEYS-Struktur mit tastaturbedienbaren Objekten falls vorhanden
 */
DIALKEYS *create_dialkeys(OBJECT *tree) {
	WORD i = 0;
	UBPARM *ubparm;
	DIALKEYS *dialkeys = NULL, *last_dialkey = NULL, *new_dialkey = NULL;

	if (tree == NULL)
		return (NULL);

	do {
		++i;

		/*
		 * Alle meine USERDEF-Objekte ueberpruefen, ob sie mit der
		 * Tastatur bedient werden koennen.
		 */
		if ((tree[i].ob_type & 0xff) == G_USERDEF) {
			ubparm = (UBPARM *) (tree[i].ob_spec.userblk->ub_parm);
			if (ubparm == NULL)
				break;

			/*
			 * Testen, ob es ein Userdef-Objekt von mir ist.
			 */
			if (ubparm->magic != 'DIRK') {
				if (!(tree[i].ob_flags & LASTOB))
					continue;
				else
					break;
			}

			/*
			 * Ist ein Objekt tastaturbedienbar? Dann hat die
			 * Position einen Wert >= 0.
			 * Ist dies der Fall so wird ein weiteres Listenelement
			 * fuer die DIALKEYS-Struktur erzeugt.
			 */
			if (ubparm->uline_pos >= 0) {
				new_dialkey = (DIALKEYS *) malloc(sizeof(DIALKEYS));
				if (new_dialkey == NULL) {
					/*
					 * bisher schon eingerichtete Elemente wieder
					 * freigeben.
					 */
					remove_dialkeys(dialkeys);
					return (NULL);
				}

				/*
				 * Taste und die zugehoerige Objektnummer eintragen.
				 */
				new_dialkey->object = i;
				new_dialkey->key[0] = '\a';
				new_dialkey->key[1] = toupper(ubparm->text[ubparm->uline_pos]);
				new_dialkey->key[2] = EOS;
				new_dialkey->next = NULL;

				/*
				 * Wenn es das erste Objekt ist, muss der Startzeiger
				 * auf dieses gesetzt werden.
				 */
				if (dialkeys == NULL)
					dialkeys = new_dialkey;
				else
					last_dialkey->next = new_dialkey;

				last_dialkey = new_dialkey;
			}
		}
	} while (!(tree[i].ob_flags & LASTOB));

	return (dialkeys);
}

DIALKEYS *create_menukeys(OBJECT *tree) {
#define CTRL_KEY	'^'			/* Menue-Control-Buchstabe */
#define ALT_KEY		0x07		/* Menue-Alternate-Buchstabe */
#define SHIFT_KEY	0x01		/* Menue-Shifttaste */
#define FUNC_KEY	'F'			/* Menue-Funktionstaste */

	BYTE *menue_str, keys[16];
	WORD i = 0, menuebox, item, title;
	DIALKEYS *dialkeys = NULL, *last_dialkey = NULL, *new_dialkey = NULL;

	menuebox = tree[ROOT].ob_tail;
	menuebox = tree[menuebox].ob_head; /* Box um erstes Untermenue */
	title = 3;

	do {
		item = tree[menuebox].ob_head; /* Erster Eintrag */

		do {
			if ((tree[item].ob_type & 0xFF) == G_STRING) {
				/*
				 * Feststellen, ob der akt. Menueeintrag tastaturbedienbar ist.
				 */
				menue_str = strdup(tree[item].ob_spec.free_string);

				/*
				 * Letztes Space abschneiden.
				 */
				menue_str[strlen(menue_str) - 1] = EOS;

				/*
				 * Von Rechts->Links innerhalb des menue_str gehen und
				 * das erste Space finden.
				 */
				for (i = (WORD) strlen(menue_str); (i >= 0) && (menue_str[i] != ' '); i--)
					;

/*printf("item: %s %i\n", menue_str, i);*/
				/*
				 * Zeichen rechts vom Space nach keys kopieren und
				 * feststellen, mit welchem Shortcut der Eintrag be-
				 * dient wird.
				 */
				strcpy(keys, &menue_str[++i]);

				switch (keys[0]) {
				case CTRL_KEY:
					keys[0] = '\x5e';
					keys[2] = EOS;
					break;

				case ALT_KEY:
					keys[0] = '\x07';
					keys[2] = EOS;
					break;

				case SHIFT_KEY:
					keys[0] = '\x01';
					keys[2] = EOS;
					break;

				case FUNC_KEY:
/*						keys[0] = 'F';
					 strcat(keys, "F");
					 if (*xyz >= '1' && *xyz <= '9')
					 {
					 strcat(keys, xyz);
					 }
					 else
					 strcpy(keys, "");*/
					break;

				default:
					strcpy(keys, "");
					break;
				}

				if (keys) {
/*printf("keys: %s\n", keys);*/
					new_dialkey = (DIALKEYS *) malloc(sizeof(DIALKEYS));
					if (new_dialkey == NULL) {
						/*
						 * bisher schon eingerichtete Elemente wieder
						 * freigeben.
						 */
						remove_dialkeys(dialkeys);
						return (NULL);
					}

					strcpy(new_dialkey->key, keys);
					new_dialkey->object = item;
					new_dialkey->title = title;
					new_dialkey->next = NULL;

					/*
					 * Wenn es das erste Objekt ist, muss der Startzeiger
					 * auf dieses gesetzt werden.
					 */
					if (dialkeys == NULL)
						dialkeys = new_dialkey;
					else
						last_dialkey->next = new_dialkey;

					last_dialkey = new_dialkey;
				}
			}

			item = tree[item].ob_next; /* Naechster Eintrag */
		} while (item != menuebox);

		menuebox = tree[menuebox].ob_next; /* Naechstes Drop-Down-Menue */
		title = tree[title].ob_next; /* Naechster Titel */
	} while (title != 2);

	return (dialkeys);
}

void get_menue_item(DIALKEYS *dialkeys, char *keystring, WORD *title, WORD *item) {
	if (dialkeys == NULL) {
		*title = -1;
		*item = -1;
		return;
	}

	do {
		if (!strcmp(keystring, dialkeys->key)) {
			*title = dialkeys->title;
			*item = dialkeys->object;
			return;
		}

		dialkeys = dialkeys->next;
	} while (dialkeys != NULL);

	*title = -1;
	*item = -1;
}

/*
 * Diese Routine laeuft die Dialkeys-Struktur durch und
 * gibt jedes allozierte Element frei. Diese Routine wird
 * am Ende des Programmes oder immer dann aufgerufen, wenn
 * man die Struktur fuer einen bestimmten Dialog freigeben
 * will.
 */
void remove_dialkeys(DIALKEYS *dialkeys) {
	DIALKEYS *help;

	while (dialkeys != NULL) {
		help = dialkeys;
		dialkeys = dialkeys->next;
		free(help);
	}
}

/*
 * Diese Routine fuegt eine neue Taste zur Dialkeys-Struktur
 * hinzu. Diese wird vor alle anderen gehaengt.
 */
WORD add_dialkeys(DIALKEYS **dialkeys, WORD object, char *keystring) {
	DIALKEYS *new_dialkey;

	new_dialkey = (DIALKEYS *) malloc(sizeof(DIALKEYS));
	if (new_dialkey == NULL)
		return USR_OUTOFMEMORY;

	strcpy(new_dialkey->key, keystring);
	new_dialkey->object = object;
	new_dialkey->next = NULL;

	if (*dialkeys == NULL)
		*dialkeys = new_dialkey;
	else {
		new_dialkey->next = *dialkeys;
		*dialkeys = new_dialkey;
	}
	return USR_NOERROR;
}

/*
 * Diese Routine wandelt den Wert der gedrueckten Taste in Klartext
 * um. Danach kann man mittels 'find_object' das zugehoerige Objekt
 * suchen.
 *
 * Sie wurde von Thomas Binder geschrieben und funktioniert schon
 * seit sehr langer Zeit in seinen Programmen.
 */
void key_change(WORD shift, UWORD key, char *keys) {
	WORD scancode, numeric = 0;
	char temp[2];
#ifdef __MINT__
	_KEYTAB *table;
#else
	KEYTAB *table;
#endif

	table = Keytbl((void *) -1L, (void *) -1L, (void *) -1L);
	scancode = (key >> 8);
	if (!scancode) {
		keys[0] = key;
		keys[1] = EOS;
		return;
	}
	strcpy(keys, "");
	if ((shift & 1) || (shift & 2))
		strcat(keys, "\x01");
	if (shift & 4)
		strcat(keys, "\x5e");
	if (shift & 8)
		strcat(keys, "\x07");
	switch (scancode) {
	case 1:
		strcat(keys, "Esc");
		break;
	case 14:
		strcat(keys, "Backspc");
		break;
	case 15:
		strcat(keys, "Tab");
		break;
	case 28:
		strcat(keys, "Return");
		break;
	case 114:
		strcat(keys, "[Enter]");
		break;
	case 71:
	case 119:
		strcat(keys, "Home");
		break;
	case 72:
		strcat(keys, "CurUp");
		break;
	case 75:
	case 115:
		strcat(keys, "CurLf");
		break;
	case 77:
	case 116:
		strcat(keys, "CurRt");
		break;
	case 80:
		strcat(keys, "CurDn");
		break;
	case 82:
		strcat(keys, "Ins");
		break;
	case 83:
		strcat(keys, "Del");
		break;
	case 97:
		strcat(keys, "Undo");
		break;
	case 98:
		strcat(keys, "Help");
		break;
	case 57:
		strcat(keys, "Space");
		break;
	default:
		if (((scancode >= 99) && (scancode <= 113)) || (scancode == 78)
				|| (scancode == 74)) {
			numeric = 1;
		}
		if (((scancode >= 59) && (scancode <= 68)) || ((scancode >= 84)
				&& (scancode <= 93))) {
			strcat(keys, "F");
			if (scancode > 68)
				scancode -= 25;
			if (scancode < 68) {
				temp[0] = (char) (scancode - 10);
				temp[1] = '\x00';
				strcat(keys, temp);
			} else
				strcat(keys, "10");
			return;
		}
		if ((scancode >= 120) && (scancode <= 131))
			scancode -= 118;

		temp[0] = key & 0xff;
		if (temp[0] && (temp[0] >= 32) && (((char *) table->unshift)[scancode]
				!= temp[0]) && (((char *) table->shift)[scancode] != temp[0])) {
			if (shift & 8)
				keys[strlen(keys) - 1] = 0;
		}
		if ((shift & 4) && (temp[0] >= 1) && (temp[0] <= 26))
			temp[0] = ((char *) table->shift)[scancode];
		if (temp[0] < 32) {
			if ((shift & 16) && !(shift & 3))
#ifdef __MINT__
				temp[0] = ((char *)table->caps)[scancode];
#else
				temp[0] = table->capslock[scancode];
#endif
			else {
				if (shift & 3)
					temp[0] = ((char *) table->shift)[scancode];
				else
					temp[0] = ((char *) table->unshift)[scancode];
			}
		}
		if ((shift & 8) && (temp[0] >= 'a') && (temp[0] <= 'z'))
			temp[0] &= ~32;
		temp[1] = '\x00';
		if (numeric)
			strcat(keys, "[");
		strcat(keys, temp);
		if (numeric)
			strcat(keys, "]");
	}
}

/*
 * Diese Routine sucht in der DIALKEYS-Struktur nach dem Objekt, das
 * zu der gedrueckten Taste gehoert. Ist es vorhanden, wird dessen
 * Objektnummer zurueckgeliefert, sonst -1.
 */
WORD find_object(DIALKEYS *dialkeys, char *keystring) {
	if (dialkeys == NULL)
		return (-1);

	do {
		if (!strcmp(keystring, dialkeys->key))
			return (dialkeys->object);

		dialkeys = dialkeys->next;
	} while (dialkeys != NULL);

	return (-1);
}
