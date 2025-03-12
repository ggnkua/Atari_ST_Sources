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

#define FORCE_GEMLIB_UDEF
#include "..\include\dudolib.h"

/*------------------------------------------------------------------*/
/*  private function prototypes                                     */
/*------------------------------------------------------------------*/
void handleEditfields(CARD *card, WORD objectIdx, BOOLEAN show);

/*------------------------------------------------------------------*/
/*  public functions                                                */
/*------------------------------------------------------------------*/

/**
 * Um Karteikarten verwenden zu koennen, muessen diese zunaechst verknuepft und
 * der Bibliothek bekannt gemacht werden. Fuer jeden Dialog, der Karteikarten
 * beinhaltet braucht es eine entsprechende Liste vom Typ CARD. Mit Hilfe dieser
 * Methode wird eine Karteikarte mit ihrem zugehoerigen Reiter in dieser Liste
 * gespeichert.
 *
 * @param **card Zeiger auf die Struktur der Karteikarten, die eine Einheit bilden
 * @param *objectTree Zeiger auf die Objekt-Struktur, die Reiter und Karte enthaelt
 * @param head Objekt-Index des Reiters
 * @param body Objekt-Index der Karteikarte
 */
short cardAdd(CARD **card, OBJECT *objectTree, WORD objectHeadIdx, WORD objectBodyIdx) {
	WORD i;
	CARD *newCard = NULL, *dummyCard = NULL;

	newCard = (CARD *) malloc(sizeof(CARD));
	if (newCard == NULL)
		return (USR_OUTOFMEMORY);

	newCard->objectTree = objectTree;
	newCard->head = objectHeadIdx;
	newCard->body = objectBodyIdx;
	newCard->redraw = NULL;
	for (i = 0; i < MAXOBJECTS; i++)
		newCard->savedObjectFlags[i] = 0;
	newCard->next = NULL;

	if (*card == NULL) {
		/*
		 * erste Karteikarte in der Struktur per default:
		 * -> gewaehlt, sichtbar
		 */
		setObjectSelected(newCard->objectTree, newCard->head);
		newCard->top = TRUE;
		setObjectFlags(newCard->objectTree, newCard->body, OF_HIDETREE, FALSE);
		handleEditfields(newCard, newCard->body, TRUE);

		*card = newCard;
	} else {
		dummyCard = *card;
		while ((*card)->next != NULL) {
			*card = (*card)->next;
		}

		/* alle weiteren Karteikarten liegen deaktiviert im Hintergrund */
		unsetObjectSelected(newCard->objectTree, newCard->head);
		newCard->top = FALSE;
		setObjectFlags(newCard->objectTree, newCard->body, OF_HIDETREE, TRUE);
		handleEditfields(newCard, newCard->body, FALSE);

		(*card)->next = newCard;
		*card = dummyCard;
	}

	return (USR_NOERROR);
}

/**
 * Mit Hilfe dieser Methode werden alle Karteikarten mit ihrem zugehoerigen
 * Reiter aus der Liste geloescht.
 *
 * @param *card Zeiger auf die Struktur der Karteikarte, die aus der Liste entfernt werden soll
 */
void cardRemoveAll(CARD *card) {
	CARD *dummyCard = NULL;

	if (card == NULL)
		return;

	while (card != NULL) {
		dummyCard = card;
		card = card->next;
		free(dummyCard);
		dummyCard = NULL;
	}
}

/**
 * Mit dieser Methode kann der entsprechenden Karteikarte eine eigene
 * Zeichenroutine zugewiesen werden.
 *
 * @param *card Zeiger auf die Struktur der Karteikarte, die eine eigene Zeichenroutine erhalten soll
 * @param (*redraw) Zeiger auf die Zeichenroutine, die das Objekt zeichnet
 */
void setCardRedraw(CARD *card, void(*redraw)(OBJECT *objectBodyTree, WORD objectBodyIdx, WORD x, WORD y, WORD w, WORD h)) {
	if (card == NULL)
		return;

	card->redraw = redraw;
}

/**
 * Diese Methode deaktiviert einen Reiter, so dass die Karteikarte
 * nicht mehr angewaehlt werden kann.
 *
 * @param *card Zeiger auf die Struktur der Karteikarten
 * @param objectHeadIdx Objekt-Index des Reiters
 */
void cardDisable(CARD *card, WORD objectHeadIdx) {
	CARD *disableCard = NULL, *activeCard = NULL;

	if (card == NULL)
		return;

	/* pruefen, ob der Reiter der aktiven Karte deaktiviert werden soll */
	activeCard = getActiveCard(card);
	if (activeCard == NULL || activeCard->head == objectHeadIdx)
		return;

	disableCard = card;
	while (disableCard->head != objectHeadIdx) {
		if (disableCard->next != NULL)
			disableCard = disableCard->next;
		else
			/* nicht gefunden */
			return;
	}

	setObjectDisabled(disableCard->objectTree, disableCard->head);
	setObjectFlags(disableCard->objectTree, disableCard->head, OF_SELECTABLE | OF_TOUCHEXIT, FALSE);
}

/**
 * Diese Methode aktiviert einen Reiter, so dass die Karteikarte
 * angewaehlt werden kann.
 *
 * @param *card Zeiger auf die Struktur der Karteikarten
 * @param objectHeadIdx Objekt-Index des Reiters
 */
void cardEnable(CARD *card, WORD objectHeadIdx) {
	CARD *enableCard = NULL;

	if (card == NULL)
		return;

	enableCard = card;
	while (enableCard->head != objectHeadIdx) {
		if (enableCard->next != NULL)
			enableCard = enableCard->next;
		else
			/* nicht gefunden */
			return;
	}

	unsetObjectDisabled(enableCard->objectTree, enableCard->head);
	setObjectFlags(enableCard->objectTree, enableCard->head, OF_SELECTABLE | OF_TOUCHEXIT, TRUE);
}

/**
 * Diese Methode liefert die aktive Karteikarte.
 *
 * @param *card Zeiger auf die Struktur der Karteikarten
 * @return Zeiger auf die Struktur der aktiven Karteikarte
 */
CARD *getActiveCard(CARD *card) {
	CARD *activeCard = NULL;

	if (card == NULL)
		return (NULL);

	activeCard = card;
	while (activeCard->top == FALSE) {
		if (activeCard->next != NULL)
			activeCard = activeCard->next;
		else
			return (NULL);
	}

	return (activeCard);
}

/**
 * Diese Methode liefert den Objekt-Index der aktiven Karteikarte.
 *
 * @param *card Zeiger auf die Struktur der Karteikarten
 * @return Objekt-Index der aktiven Karteikarte
 */
short getActiveCardBodyIdx(CARD *card) {
	CARD *activeCard = NULL;

	activeCard = getActiveCard(card);
	if (activeCard == NULL)
		return (-1); /* NIL */

	return (activeCard->body);
}

/**
 * Mit dieser Methode wird eine Karteikarte getoppt.
 *
 * @param *card Zeiger auf die Struktur der Karteikarten
 * @param objectHeadIdx Objekt-Index des Reiters, dessen zugehoerige Karteikarte angezeigt werden soll
 * @param redraw TRUE - Karteikarte/Reiter neu zeichnen, FALSE sonst
 */
void setActiveCard(CARD *card, short objectHeadIdx, BOOLEAN redraw) {
	BOOLEAN identicalCardBody;
	WORD x, y;
	CARD *activeCard, *newActiveCard;

	if (card == NULL)
		return;

	activeCard = getActiveCard(card);
	if (activeCard == NULL)
		return;

	/*
	 * Ist aktuelle Karteikarte identisch mit der Karteikarte, die getoppt
	 * werden soll? Dann braucht nichts gemacht zu werden -> zurueck.
	 */
	if (activeCard->head == objectHeadIdx)
		return;

	/* Zu toppende Karteikarte suchen. */
	newActiveCard = card;
	while (newActiveCard->head != objectHeadIdx) {
		if (newActiveCard->next != NULL)
			newActiveCard = newActiveCard->next;
		else
			return;
	}

	/* Reiter der aktuell aktiven Karte deselektieren. */
	unsetObjectSelected(activeCard->objectTree, activeCard->head);
	activeCard->top = FALSE;

	/* Reiter der zukuenftig aktiven Karte selektieren. */
	setObjectSelected(newActiveCard->objectTree, newActiveCard->head);
	newActiveCard->top = TRUE;

	/* wenn die Karteikarten identisch sind, sind wir fertig, sonst... */
	if (activeCard->body != newActiveCard->body) {
		identicalCardBody = FALSE;

		/* aktuelle Karteikarte verstecken */
		setObjectFlags(activeCard->objectTree, activeCard->body, OF_HIDETREE, TRUE);
		handleEditfields(activeCard, activeCard->body, FALSE);

		/* zukuenftig aktive Karteikarte anzeigen */
		setObjectFlags(newActiveCard->objectTree, newActiveCard->body, OF_HIDETREE, FALSE);
		handleEditfields(newActiveCard, newActiveCard->body, TRUE);
	} else {
		identicalCardBody = TRUE;
	}

	/* Reiter/Karteikarte ggf. neu zeichnen */
	if (redraw == TRUE) {
		/* vorher getoppter Reiter */
		objc_offset(activeCard->objectTree, activeCard->head, &x, &y);
		objc_draw(activeCard->objectTree, activeCard->head, MAX_DEPTH, x, y,
				activeCard->objectTree[activeCard->head].ob_width,
				activeCard->objectTree[activeCard->head].ob_height + 1);

		/* aktueller Reiter */
		objc_offset(newActiveCard->objectTree, newActiveCard->head, &x, &y);
		objc_draw(newActiveCard->objectTree, newActiveCard->head, MAX_DEPTH, x, y,
				newActiveCard->objectTree[newActiveCard->head].ob_width,
				newActiveCard->objectTree[newActiveCard->head].ob_height + 1);

		if (!identicalCardBody) {
			/* aktuelle Karteikarte */
			objc_offset(newActiveCard->objectTree, newActiveCard->body, &x, &y);
			if (newActiveCard->redraw != NULL) {
				(newActiveCard->redraw)(newActiveCard->objectTree,
						newActiveCard->body, x, y,
						newActiveCard->objectTree[newActiveCard->body].ob_width,
						newActiveCard->objectTree[newActiveCard->body].ob_height);
			} else {
				objc_draw(newActiveCard->objectTree, newActiveCard->body, MAX_DEPTH, x, y,
						newActiveCard->objectTree[newActiveCard->body].ob_width,
						newActiveCard->objectTree[newActiveCard->body].ob_height);
			}
		}
	}
}

/*------------------------------------------------------------------*/
/*  private functions                                               */
/*------------------------------------------------------------------*/

/**
 *
 * @param *card Zeiger auf die Struktur der Karteikarte
 * @param objectIdx Objekt-Index des Objekts
 * @param show Editfelder anzeigen (TRUE), verbergen (sonst)
 */
void handleEditfields(CARD *card, WORD objectIdx, BOOLEAN show) {
	WORD i;

	/*
	 * Laeuft ueber alle Kindobjeckte, der aktuellen Ebene.
	 * Abbruchbedingung:
	 *   i == objectIndex (i = letztes Objekt, ob_head = parent)
	 *   i == NIL (-1) (es gibt kein Kind)
	 */
	for (i = card->objectTree[objectIdx].ob_head; (i != objectIdx) && (i != -1); i = card->objectTree[i].ob_next) {
		/* editierbare Objekte finden: */
		if (show) {
			if (card->savedObjectFlags[i] & OF_EDITABLE) {
				/* -> gespeicherte Flags loeschen, Objekt-Flags anpassen */
				setObjectFlags(card->objectTree, i, OF_EDITABLE, TRUE);
				card->savedObjectFlags[i] &= ~OF_EDITABLE;
			}
		} else {
			if (getObjectFlags(card->objectTree, i, OF_EDITABLE)) {
				/* -> alte Flags merken, Objekt-Flags anpassen */
				card->savedObjectFlags[i] |= OF_EDITABLE;
				setObjectFlags(card->objectTree, i, OF_EDITABLE, FALSE);
			}
		}

		/* Kindobjekte bearbeiten. */
		handleEditfields(card, i, show);
	}
}
