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

/*------------------------------------------------------------------*/
/*  private function prototypes                                     */
/*------------------------------------------------------------------*/
void activateCard(CARD *card);
void deactivateCard(CARD *card);
void cardShowFields(CARD *card, WORD objectIdx, WORD objectParentIdx);
void cardHideFields(CARD *card, WORD objectIdx, WORD objectParentIdx);

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
 * @param *head_tree Zeiger auf die Objekt-Struktur des Objekts, das den Reiter bildet
 * @param head Objekt-Index des Reiters
 * @param *body_tree Zeiger auf die Objekt-Struktur des Objekts, das die Karteikarte bildet
 * @param body Objekt-Index der Karteikarte
 * @param (*redraw) Zeiger auf die Zeichenroutine, die das Objekt zeichnet
 */
int cardAdd(CARD **card, OBJECT *head_tree, WORD head, OBJECT *body_tree,
		WORD body, void(*redraw)(OBJECT *body_tree, WORD body, WORD x, WORD y,
				WORD w, WORD h)) {
	WORD i;
	CARD *newCard = NULL, *dummyCard = NULL;

	newCard = (CARD *) malloc(sizeof(CARD));
	if (newCard == NULL)
		return USR_OUTOFMEMORY;

	newCard->head_tree = head_tree;
	newCard->head = head;
	newCard->body_tree = body_tree;
	newCard->body = body;
	newCard->redraw = redraw;
	for (i = 0; i < MAXOBJECTS; i++)
		newCard->state_list[i] = 0;
	newCard->next = NULL;

	if (*card == NULL) {
		/*
		 * erste Karteikarte in der Struktur per default:
		 * -> gewaehlt, sichtbar, getoppt
		 */
		activateCard(newCard);

		*card = newCard;
	} else {
		dummyCard = *card;
		while ((*card)->next != NULL) {
			*card = (*card)->next;
		}

		/* alle weiteren Karteikarten liegen deaktiviert im Hintergrund */
		deactivateCard(newCard);

		(*card)->next = newCard;
		*card = dummyCard;
	}

	return USR_NOERROR;
}

/**
 * Mit Hilfe dieser Methode wird eine Karteikarte mit ihrem zugehoerigen Reiter aus
 * der Liste geloescht.
 *
 * @param *card Zeiger auf die Struktur der Karteikarte, die aus der Liste entfernt werden soll
 */
void cardRemove(CARD *card) {
	CARD *dummyCard = NULL;

	if (card == NULL)
		return;

	while (card != NULL) {
		dummyCard = card;
		card = card->next;
		free(dummyCard);
	}
}

/**
 * Diese Methode deaktiviert einen Reiter, so dass die Karteikarte
 * nicht mehr angewaehlt werden kann.
 *
 * @param *card Zeiger auf die Struktur der Karteikarten
 * @param head Objekt-Index des Reiters
 */
void cardDisable(CARD *card, WORD head) {
	CARD *disableCard = NULL, *activeCard = NULL;

	if (card == NULL)
		return;

	/* pruefen, ob der Reiter der aktiven Karte deaktiviert werden soll */
	activeCard = getActiveCard(card);
	if (activeCard == NULL || activeCard->head == head)
		return;

	disableCard = card;
	while (disableCard->head != head) {
		if (disableCard->next != NULL)
			disableCard = disableCard->next;
		else
			/* nicht gefunden */
			return;
	}

	disableCard->head_tree[disableCard->head].ob_state |= DISABLED;
	disableCard->head_tree[disableCard->head].ob_flags &= ~(SELECTABLE | TOUCHEXIT);
}

/**
 * Diese Methode aktiviert einen Reiter, so dass die Karteikarte
 * angewaehlt werden kann.
 *
 * @param *card Zeiger auf die Struktur der Karteikarten
 * @param head Objekt-Index des Reiters
 */
void cardEnable(CARD *card, WORD head) {
	CARD *enableCard = NULL;

	if (card == NULL)
		return;

	enableCard = card;
	while (enableCard->head != head) {
		if (enableCard->next != NULL)
			enableCard = enableCard->next;
		else
			/* nicht gefunden */
			return;
	}

	enableCard->head_tree[enableCard->head].ob_state &= ~DISABLED;
	enableCard->head_tree[enableCard->head].ob_flags |= SELECTABLE | TOUCHEXIT;
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
		return NULL;

	activeCard = card;
	while (activeCard->top == FALSE) {
		if (activeCard->next != NULL)
			activeCard = activeCard->next;
		else
			return NULL;
	}

	return activeCard;
}

/**
 * Mit dieser Methode wird eine Karteikarte getoppt.
 *
 * @param *card Zeiger auf die Struktur der Karteikarten
 * @param head Objekt-Index des Reiters, dessen zugehoerige Karteikarte angezeigt werden soll
 * @param redraw TRUE - Karteikarte/Reiter neu zeichnen, FALSE sonst
 */
void setActiveCard(CARD *card, WORD head, BOOLEAN redraw) {
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
	if (activeCard->head == head)
		return;

	/*
	 * Aktuell getoppte Karte nach hinten legen:
	 * -> Reiter abwaehlen, Karteikarte verstecken
	 */
	deactivateCard(activeCard);

	/* Zu toppende Karteikarte suchen. */
	newActiveCard = card;
	while (newActiveCard->head != head) {
		if (newActiveCard->next != NULL)
			newActiveCard = newActiveCard->next;
		else
			return;
	}

	/* -> Reiter auswaehlen, Karteikarte anzeigen */
	activateCard(newActiveCard);

	/* Reiter/Karteikarte ggf. neu zeichnen */
	if (redraw == TRUE) {
		/* vorher getoppter Reiter */
		objc_offset(activeCard->head_tree, activeCard->head, &x, &y);
		objc_draw(activeCard->head_tree, activeCard->head, MAX_DEPTH, x, y,
				activeCard->head_tree[activeCard->head].ob_width,
				activeCard->head_tree[activeCard->head].ob_height + 1);

		/* aktueller Reiter */
		objc_offset(newActiveCard->head_tree, newActiveCard->head, &x, &y);
		objc_draw(newActiveCard->head_tree, newActiveCard->head, MAX_DEPTH, x,
				y, newActiveCard->head_tree[newActiveCard->head].ob_width,
				newActiveCard->head_tree[newActiveCard->head].ob_height + 1);

		/* aktuelle Karteikarte */
		if (newActiveCard->redraw != NULL) {
			objc_offset(newActiveCard->body_tree, newActiveCard->body, &x, &y);
			(newActiveCard->redraw)(newActiveCard->body_tree,
					newActiveCard->body, x, y,
					newActiveCard->body_tree[newActiveCard->body].ob_width,
					newActiveCard->body_tree[newActiveCard->body].ob_height);
		}
	}
}

/*------------------------------------------------------------------*/
/*  private functions                                               */
/*------------------------------------------------------------------*/

/**
 * Mit dieser Methode wird eine Karteikarte getoppt.
 *
 * @param *card Zeiger auf die Struktur der Karteikarte
 */
void activateCard(CARD *card) {
	if (card == NULL)
		return;

	card->top = TRUE;
	card->head_tree[card->head].ob_state |= SELECTED;
	card->body_tree[card->body].ob_flags &= ~HIDETREE;

	cardShowFields(card, card->body_tree[card->body].ob_head, card->body_tree[card->body].ob_next);
}

/**
 * Mit dieser Methode wird eine Karteikarte nach hinten gelegt.
 *
 * @param *card Zeiger auf die Struktur der Karteikarte
 */
void deactivateCard(CARD *card) {
	if (card == NULL)
		return;

	card->top = FALSE;
	card->head_tree[card->head].ob_state &= ~SELECTED;
	card->body_tree[card->body].ob_flags |= HIDETREE;

	cardHideFields(card, card->body_tree[card->body].ob_head, card->body_tree[card->body].ob_next);
}

void cardShowFields(CARD *card, WORD objectIdx, WORD objectParentIdx) {
	if (card == NULL)
		return;

	/*
	 * Alle Objekte auf gleicher Ebene durchlaufen.
	 */
	while (objectIdx != objectParentIdx) {
		/*
		 * selektier- und editierbare Objekte finden:
		 * -> gespeicherte Flags loeschen, Objekt-Flags anpassen
		 */
#if 0
		if (card->state_list[objectIdx] & SELECTABLE) {
			/*			setObjectFlags(card->body_tree, objectIdx, SELECTABLE, TRUE);*/
			card->body_tree[objectIdx].ob_flags |= SELECTABLE;
			card->state_list[objectIdx] &= ~SELECTABLE;
		}
#endif
		if (card->state_list[objectIdx] & EDITABLE) {
			/*			setObjectFlags(card->body_tree, objectIdx, EDITABLE, TRUE);*/
			card->body_tree[objectIdx].ob_flags |= EDITABLE;
			card->state_list[objectIdx] &= ~EDITABLE;
		}

		/*
		 * Kindobjekte bearbeiten.
		 */
		if (card->body_tree[objectIdx].ob_head != NIL)
			cardShowFields(card, card->body_tree[objectIdx].ob_head, objectIdx);

		objectIdx = card->body_tree[objectIdx].ob_next;
	}
}

void cardHideFields(CARD *card, WORD objectIdx, WORD objectParentIdx) {
	if (card == NULL)
		return;

	/*
	 * Alle Objekte auf gleicher Ebene durchlaufen.
	 */
	while (objectIdx != objectParentIdx) {

		/*
		 * selektier- und editierbare Objekte finden:
		 * -> alte Flags merken, Objekt-Flags anpassen
		 */
#if 0
		if (card->body_tree[objectIdx].ob_flags & SELECTABLE) {
			card->state_list[objectIdx] |= SELECTABLE;
			/*			setObjectFlags(card->body_tree, objectIdx, SELECTABLE, FALSE);*/

			card->body_tree[objectIdx].ob_flags &= ~SELECTABLE;
		}
#endif
		if (card->body_tree[objectIdx].ob_flags & EDITABLE) {
			card->state_list[objectIdx] |= EDITABLE;
			/*			setObjectFlags(card->body_tree, objectIdx, EDITABLE, FALSE);*/

			card->body_tree[objectIdx].ob_flags &= ~EDITABLE;
		}

		/*
		 * Kindobjekte bearbeiten.
		 */
		if (card->body_tree[objectIdx].ob_head != NIL)
			cardHideFields(card, card->body_tree[objectIdx].ob_head, objectIdx);

		objectIdx = card->body_tree[objectIdx].ob_next;
	}
}
