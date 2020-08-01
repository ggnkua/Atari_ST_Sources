/*
*
* Bibliothek mit MagiC-spezifischen Funktionen
*
*/

#include <portab.h>
#include <tos.h>
#include <string.h>
#include <aes.h>
#include <magx.h>
#include "magxlib.h"


#ifndef NULL
#define NULL 0L
#endif
#define P_COOKIES	0x5a0



/*******************************************************************
*
* Cookie ermitteln.
*
*******************************************************************/

static LONG __init_cookie(void)
{
	return(* ((LONG *) P_COOKIES));
}

ULONG *get_cookie(ULONG val)
{
	ULONG *cookie;

	cookie = (ULONG *) Supexec(__init_cookie);
	if	(!cookie)
		return(NULL);
	while(*cookie)
		{
		if	(*cookie == val)
			return(cookie+1);
		cookie += 2;
		}
	return(NULL);
}


/*******************************************************************
*
* MagiC-Version ermitteln.
* ========================
*
* Falls <crdate> != NULL ist, wird das Erstelldatum in der
* Form jjjjmmdd geliefert. Durch "<" und ">" kann dann
* direkt ermittelt werden, ob eine bestimmte Funktion
* bei der vorliegenden MagiC- Version verfgbar ist.
*
* Rckgabe:	0		kein MagiC installiert
*			-1		bin noch im AUTO-Ordner
*			0x0a0b	Version a.b
*
*******************************************************************/

WORD get_MagiC_ver(ULONG *crdate)
{
	ULONG *cookie;
	AESVARS *av;

	cookie = get_cookie('MagX');
	if	(!cookie)
		return(0);
	av = ((MAGX_COOKIE *) (*cookie))->aesvars;
	if	(!av)
		return(-1);
	if	(crdate)
		{
		*crdate = av->date << 16L;				/* jjjj0000 */
		*crdate |= av->date >> 24L;				/* jjjj00tt */
		*crdate |= (av->date >> 8L) & 0xff00L;		/* jjjjmmtt */
		}
	return(av->version);
}


/****************************************************************
*
* Macht ein F(BOX)TEXT-Objekt scrollbar, wenn MagiC l„uft.
*
* Wenn <is_scroll> FALSE ist, wird nur das Textfeld auf eine
* Benutzerzeichenkette umgesetzt.
*
* Im RCS sollte das Textfeld leer gelassen werden, die Schablone
* und die Valid-Zeichenkette mssen jedoch eingegeben werden,
* weil sonst das RCS streikt.
* Fr scrollende Felder muž eine neue Schablone angelegt werden,
* die in der .RSC-Datei angemeldete kann nicht verwendet werden,
* weil sie zu kurz ist. Die hier angelegte Schablone besteht
* nur aus '_'-Zeichen, weil dies 99.9% aller Anwendungsf„lle
* fr scrollende Objekte abdeckt. Die L„nge der
* Valid-Zeichenkette ist egal, d.h. muž mindestens 1 sein, weil 
* das AES das letzte Zeichen der Valid-Zeichenkette
* automatisch vervielfacht, bis die L„nge des Textfeld erreicht
* ist.
*
* Die maximale L„nge fr die Eingabezeichenkette ist in jedem
* Fall (TEDINFO.te_txtlen - 1).
*
****************************************************************/

void init_scrlted(OBJECT *o, WORD is_scroll, XTED *xted,
				char *txt, char *tmplt, WORD len)
{
	TEDINFO *t;

	t = o->ob_spec.tedinfo;
	t->te_just = TE_LEFT;		/* wichtig! */
	t->te_ptext = txt;
	if	(is_scroll)
		{
		memset(tmplt, '_', len);	/* neue Schablone */
		tmplt[len] = '\0';
		xted->xte_ptmplt = tmplt;
		xted->xte_pvalid = t->te_pvalid;
		xted->xte_vislen = t->te_tmplen - 1;
		xted->xte_scroll = 0;
		
		t->te_tmplen = len+1;
		t->te_ptmplt = NULL;
		t->te_pvalid = (void *) xted;
		}
	t->te_txtlen = t->te_tmplen;
}
