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
 * @copyright  Dirk Klemmt 1994-2016
 * @author     Dirk Klemmt, Gerhard Stoll
 * @license    LGPL
 */

#include "string.h"

#define FORCE_GEMLIB_UDEF
#include "..\include\dudolib.h"

/**
 * Wandelt ein Objekt in ein scrollbares Edit-Feld
 *
 * Rueckgabe-Variablen:
 *
 * Typ WORD:
 *   als Return-Code werden folgende Werte zurueckgegeben:
 *
 *   USR_NOERROR       - kein Fehler/alles Ok
 *   USR_OUTOFMEMORY   - kein Speicher mehr frei.
 */

WORD setSrcollEditfield(OBJECT *objectTree, WORD object, WORD len) {

	/* TEDINFO-Object in XTED fr scrollbares Edit-Feld umwandeln */
	XTEDINFO	*xt;

	xt=(XTEDINFO*)malloc(sizeof(XTEDINFO));
	if (xt == NULL)
		return (USR_OUTOFMEMORY);
	
	xt->te_ptext = (BYTE *) calloc(len + 1, 1);
	if (xt->te_ptext == NULL) {
		free(xt);
		return (USR_OUTOFMEMORY);
	}

	objectTree[object].ob_spec.tedinfo->te_ptext[0]=0;	/* String l”schen */
	objectTree[object].ob_spec.tedinfo->te_ptext[objectTree[object].ob_spec.tedinfo->te_txtlen-1]=0;	/* String terminieren, damit das bei objc_edit nicht dauernd gemacht werden muž */
	objectTree[object].ob_spec.tedinfo->te_just = TE_LEFT;
	xt->ti=*(objectTree[object].ob_spec.tedinfo);
	xt->magic='XTED';
	xt->maxlen=len;
	xt->offset=0;
	*((XTEDINFO**)&(objectTree[object].ob_spec.tedinfo))=xt;

	return (USR_NOERROR);
}

/**
 *	Rueckwandlung eines scrollbares Edit-Feld in ein normales Edit-Feld
 */

VOID unsetSrcollEditfield(OBJECT *objectTree, WORD object) {
	XTEDINFO	*xt;

	if (xted(objectTree, object)->magic == 'XTED') {
		xt=*((XTEDINFO**)&(objectTree[object].ob_spec.tedinfo));
		*(objectTree[object].ob_spec.tedinfo)=xt->ti;
		free (xt->te_ptext);
		free (xt);
	}
}


/**
 *	Kopiert die vergoesserte Zeichenkette ins Edit-Feld
 */

VOID strcpySrcollEditfield(OBJECT *tree, WORD ob) {
	BYTE	*src, *dst;
	WORD	len;
	
	dst=tree[ob].ob_spec.tedinfo->te_ptext;
	src=&(xted(tree, ob)->te_ptext[xted(tree, ob)->offset]);

	len=(WORD)strlen(xted(tree, ob)->te_ptext)-xted(tree, ob)->offset;

	if(len > tree[ob].ob_spec.tedinfo->te_txtlen-1)
		len=tree[ob].ob_spec.tedinfo->te_txtlen-1;
	while(len--)
		*dst++=*src++;
}

/**
 *	Erstmaliges setzen des Edit-Feld
 */

VOID firstsetSrcollEditfield (OBJECT *tree, WORD ob, BYTE *text) {
	xted(tree, ob)->te_ptext=text;
	xted(tree, ob)->offset=0;
	strcpySrcollEditfield(tree, ob);
}

/**
 *	Text ins Edit-Feld kopieren
 */

VOID cpyEditfield(OBJECT *tree, WORD ob, BYTE *text) {
	strncpy(xted(tree, ob)->te_ptext,text,xted(tree, ob)->maxlen);
	xted(tree, ob)->offset=0;
	strcpySrcollEditfield(tree, ob);
}


/**
 *	Ermittelt die Laenge des Strings des Edit-Feld
 */

LONG getlenSrcollEditfield(OBJECT *tree, WORD ob) {
	if(xted(tree, ob)->magic != 'XTED')
		return(strlen(tree[ob].ob_spec.tedinfo->te_ptext));

	return(strlen(xted(tree, ob)->te_ptext));
}

/**
 *	Gibt den Zeiger auf den langen Text zurueck, falls es sich 
 * um ein scrollbares Edit-Feld handelt. Sonst den normalen
 */

BYTE *getTextLongSrcollEditfield(OBJECT *tree, WORD ob) {
	if(xted(tree, ob)->magic != 'XTED')
		return( tree[ob].ob_spec.tedinfo->te_ptext );

	return( xted(tree, ob)->te_ptext );
}
