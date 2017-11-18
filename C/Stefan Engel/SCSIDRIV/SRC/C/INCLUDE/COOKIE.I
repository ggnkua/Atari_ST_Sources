;* cookie.i: Deklarationen fuer Cookie-Funktionen
;*
;* $Id: cookie.i,v 1.5 1996/01/26 10:05:46 Steffen_Engel Exp Steffen_Engel $
;*
;* $Log: cookie.i,v $
;* Revision 1.5  1996/01/26  10:05:46  Steffen_Engel
;* getcookie liefert in D1 den Cookiewert
;*
;# Revision 1.4  1993/06/13  16:40:28  clausb
;# Madmac changes
;# revised docs
;#
;* Revision 1.3  1993/03/22  20:42:46  clausb
;* V4.29 sync
;*
;* Revision 1.2  1993/01/04  08:40:02  clausb
;* ausfuehrliche Kommentare eingebaut
;*
;*

;* C: typedef unsigned long COOKIEID;
;*    typedef unsigned long COOKIEVAL;
;*    typedef struct { COOKIEID id; COOKIEVAL val; } COOKIE;

        GLOBL   getcookie
                ; Sucht nach einem Cookie in der Cookie-Liste
                ; IN:  D0.L Gesuchtes Cookie, z.B. "_FRB" oder "CBHD"
                ; OUT: D0.L Zeiger auf Fundstelle (wenn gefunden, sonst 0)
                ;      D1.L Wert (wenn gefunden, sonst 0)
                ; Muss im Supervisormodus aufgerufen werden
                ;
                ; PC: COOKIE *getcookie(COOKIEID cid)
;
        GLOBL   insertcookie
                ; Legt ein Cookie in einer Cookieliste ab
                ; IN:  D0.L Cookie
                ;      D1.L Wert des Cookies
                ; OUT: D0.L Fehlercode
                ;          0:  OK
                ;          >0: Konnte nicht eingefÅgt werden; Returnwert
                ;              ist die Grîûe der Cookieliste in Cookies
                ;          -1: keine Liste da
                ; Muss im Supervisormodus aufgerufen werden
                ;
                ; PC: unsigned long insertcookie(COOKIEID cid,
                ;       COOKIEVAL cval);

        GLOBL   removecookie
                ; Entferne Cookie aus Cookieliste
                ; IN:  D0.L Cookie
                ; OUT: D0.L Fehlercode (0: OK, -1: Cookie nicht gefunden)
                ; RÅckgabewerte wie insertcookie
                ; Muss im Supervisormodus aufgerufen werden
                ;
                ; PC: unsigned long removecookie(COOKIEID cid);

        GLOBL   resetcookie
                ; Installiere Resethandler fÅr Cookieliste.
                ;
                ; PC: void resetcookie(void);

        GLOBL   installcookie
                ; Installiere neue Cookieliste
                ; IN: A0.L Zeiger auf neue Liste
                ;     D0.L Grîûe in Cookies
                ; Muss im Supervisormodus aufgerufen werden
                ;
                ; PC: void installcookie(unsigned long size,
                ;       COOKIE *newlist);

        GLOBL   inst_new_cookie
                ; Installiere neues Cookie
                ; IN:  D0.L Cookie
                ;      D1.L Cookiewert
                ;      A0.L Zeiger auf Speicherbereich, der fÅr eine
                ;           eventuell neu anzulegende Cookieliste
                ;           verwendet werden kann.
                ; OUT: D0.L fÅr neue Cookieliste verbrauchter
                ;           Speicher
                
