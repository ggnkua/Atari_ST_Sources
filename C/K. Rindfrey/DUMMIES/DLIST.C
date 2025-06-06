/*
 * Dieses Modul stellt doppelt verkettete Listen
 * und dazugeh�rige Funktionen zur Verf�gung.
 * Entwickelt mit Pure C von K. Rindfrey.
 * (c) MAXON Computer 1993
 */
#include <stdlib.h>
#include <stdio.h>
#include "dlist.h"

#define DN_ALLOC() malloc( sizeof( TDNode))
/*
 * ND_ALLOC reserviert Speicher f�r ein
 * Element vom Typ TDNode.
 */


TDList *dl_Create()
/*
 * Legt eine doppelt verkettete Liste an.
 * R�ckgabe: Zeiger auf eine leere Liste
 */
{
    register TDNode *a, /* Anker          */
                    *e; /* Ende der Liste */

    if( (a = DN_ALLOC()) == NULL ||
        (e = DN_ALLOC()) == NULL)  return( NULL);
    a->pval = a->next = e;
    a->prev = a;
    e->pval = e->next = NULL;
    e->prev = a;
    return( ( TDList *) a);
}

TDNode *dl_InsNext( TDNode *n, void *e) 
/*
 * F�ge e als Nachfolger von n ein.
 * R�ckgabe : Zeiger auf Nachfolgerknoten von n.
 */
{
    register TDNode *neu;

    if( ( neu = DN_ALLOC()) == NULL)
        return( NULL);
    neu->pval = e;
    neu->next = n->next;
    neu->prev = n;
    neu->next->prev = neu;
    n->next = neu;
    return( neu);
}

TDNode *dl_Remove( TDNode *n)
/*
 * Entferne Knoten *n
 * R�ckgabe n bzw. NULL
 */
{
    register TDNode *next, *prev;

    if( ( prev = n->prev) == n)
        return( NULL); /* Anker nicht entfernen */
    next = n->next;
    prev->next = next;
    next->prev = prev;
    return( n);
}

TDNode *dl_Search( void *p, TDList *a, 
                                TCmpF cmp)
/*
 * Suche Eintrag p in Liste a mit der
 * Vergleichsfunktion cmp.
 * R�ckgabe : Zeiger auf den Knoten mit
 * Eintrag p; NULL falls p nicht gefunden
 */
{
    TDNode *n, *end;

    end = ( TDNode *)a->pval;
    end->pval = p;   /* W�chter setzen */
    n = a->next;
    while( ( *cmp)(p, n->pval) != 0)
        n = n->next;
    end->pval = NULL; /* W�chter entfernen */
    return( n == end ? NULL : n);
}

TDNode *dl_RevSearch( void *p, TDList *a,
                                   TCmpF cmp)
/*
 * Durchsucht die Liste a wie dl_Search,
 * jedoch in umgekehrter Richtung, 
 * beginnend mit dem Endknoten.
 */
{
    TDNode *n, *end;

    end = ( TDNode *)a->pval;
    a->pval = p;     /* W�chter setzen */
    n = end->prev;
    while( ( *cmp)(p, n->pval) != 0)
        n = n->prev;
    a->pval = end;   /* Zeiger restaurieren */
    return( n == a ? NULL : n);
}

void dl_ForAll( TDList *a, Tv_pv func)
/*
 * Wendet die Funktion func auf
 * alle Eintr�ge der Liste a an.
 */
{
    TDNode *n;

    n = a->next;
    while( n->next != NULL){
        ( *func)( n->pval);
        n = n->next;
    }
}

