/*
 * cookie.h: Deklarationen fuer Cookie-Funktionen
 *
 * $Id: cookie.h,v 1.2 1995/10/22 15:43:34 S_Engel Exp Steffen_Engel $
 *
 * $Log: cookie.h,v $
 * Revision 1.2  1995/10/22  15:43:34  S_Engel
 * *** empty log message ***
 *
 * Revision 1.1  1995/10/06  10:39:24  S_Engel
 * Initial revision
 *
 *
 *
 */

#ifndef _COOKIE_H
#define _COOKIE_H

typedef unsigned long COOKIEID;
typedef unsigned long COOKIEVAL;
typedef struct { COOKIEID id; COOKIEVAL val; } COOKIE;

/*
        GLOBL   getcookie
                ; Sucht nach einem Cookie in der Cookie-Liste
                ; IN:  D0.L Gesuchtes Cookie, z.B. "_FRB" oder "CBHD"
                ; OUT: A0/D0.L Zeiger auf Fundstelle (wenn gefunden)
                ; Muss im Supervisormodus aufgerufen werden
                ;
*/
COOKIE *getcookie(COOKIEID cid);

/*
        GLOBL insertcookie
                ; Legt ein Cookie in einer Cookieliste ab
                ; IN:  D0.L Cookie
                ;      D1.L Wert des Cookies
                ; OUT: D0.L Fehlercode
                ;          0:  OK
                ;          >0: Konnte nicht eingefügt werden; Returnwert
                ;              ist die Gröže der Cookieliste in Cookies
                ;          -1: keine Liste da
                ; Muss im Supervisormodus aufgerufen werden
                ;
*/
unsigned long insertcookie(COOKIEID cid,
                           COOKIEVAL cval);

/*
        GLOBL   removecookie
                ; Entferne Cookie aus Cookieliste
                ; IN:  D0.L Cookie
                ; OUT: D0.L Fehlercode (0: OK, -1: Cookie nicht gefunden)
                ; Rückgabewerte wie insertcookie
                ; Muss im Supervisormodus aufgerufen werden
                ;
*/
unsigned long removecookie(COOKIEID cid);

/*
        GLOBL   resetcookie
                ; Installiere Resethandler für Cookieliste.
                ;
*/
void resetcookie(void);

/*
        GLOBL   installcookie
                ; Installiere neue Cookieliste
                ; IN: A0.L Zeiger auf neue Liste
                ;     D0.L Gröže in Cookies
                ; Muss im Supervisormodus aufgerufen werden
                ;
*/
void installcookie(unsigned long size,
                   COOKIE *newlist);

/*
        GLOBL   inst_new_cookie
                ; Installiere neues Cookie
                ; IN:  D0.L Cookie
                ;      D1.L Cookiewert
                ;      A0.L Zeiger auf Speicherbereich, der für eine
                ;           eventuell neu anzulegende Cookieliste
                ;           verwendet werden kann.
                ; OUT: D0.L für neue Cookieliste verbrauchter
                ;           Speicher
*/
unsigned long inst_new_cookie(COOKIEID cid, COOKIEVAL cval,
                              COOKIE *newlist);

#endif