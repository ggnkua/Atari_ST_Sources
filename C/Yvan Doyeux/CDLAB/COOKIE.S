;******************
;* cookie.s:
;* Routinen fÅr den Cookie-Jar
;*
;* $Id: cookie.s,v 1.16 1996/02/14 11:43:38 Steffen_Engel Exp Steffen_Engel $
;*
;* $Log: cookie.s,v $
;* Revision 1.16  1996/02/14  11:43:38  Steffen_Engel
;* *** empty log message ***
;*
;* Revision 1.15  1996/01/26  10:06:16  Steffen_Engel
;* getcookie liefert in D1 den Cookiewert
;*
;* Revision 1.14  1996/01/22  22:34:18  S_Engel
;* Revision_4.55
;*
;* Revision 1.13  1995/12/14  16:19:26  S_Engel
;* *** empty log message ***
;*
;* Revision 1.12  1995/11/28  19:12:34  S_Engel
;* CBHD Revision 4.50
;*
;* Revision 1.11  1995/10/19  09:12:52  S_Engel
;* *** empty log message ***
;*
;* Revision 1.10  1995/03/04  18:12:52  S_Engel
;* *** empty log message ***
;*
;# Revision 1.9  1995/03/02  13:53:48  S_Engel
;# Systemvaribalen aus atari.i
;#
;# Revision 1.8  1994/11/08  12:32:22  S_Engel
;# Standard SCSI-Kommandos nach scsicmd.s extrahiert
;# diverse kleine Geschwindigkeitssteigerungen in den TT-SCSI-Routinen
;#
;# Revision 1.7  1993/06/13  16:41:30  clausb
;# Madmac fixes
;# New function inst_new_cookie
;# Various bug fixes
;#
;* Revision 1.6  1993/03/22  21:14:10  clausb
;* V4.29 sync
;*
;* Revision 1.5  1993/01/04  08:39:22  clausb
;* getcookie vereinfacht und an TC-Konventionen angepasst
;*
;* Revision 1.4  1992/10/24  13:12:44  clausb
;* Neue Cookiefunktionen
;*
;* Revision 1.3  1992/10/21  20:02:50  clausb
;* getcookie: D1 war nicht richtig gesetzt, wenn keine Cookieliste
;* gefunden wird.
;*
;******************

        INCLUDE "scsidrv\cookie.i" 
        INCLUDE "scsidrv\atari.i" 
         

**********************
* getcookie: Sucht nach einem Cookie in der Liste
* Muss im Supervisormodus aufgerufen werden
*
* IN:  D0.L Gesuchtes Cookie, z.B. "_FRB" oder "CBHD"
* OUT: D0.L Zeiger auf Fundstelle (wenn gefunden)
* USE D0, D1, A0
**********************
getcookie:
        movem.l d0,-(sp)                ; brauchen wir gleich noch
        bsr     GetJar   
        movem.l (sp)+,d0                ; und zurÅck
        move.l  a0,d1                   ; gleich 0?
        bne.s   getc1                   ; nein, weiter
getcerr:
        moveq   #0,d0    
        moveq   #0,d1                   ; Value lîschen
        suba.l  a0,a0                   ; fÅr PureC
        rts              
getc1:
        move.l  (a0),d1                 ; Cookie holen
        beq.s   getcerr                 ; gleich 0, dann raus
        cmp.l   d0,d1                   ; gesuchtes Cookie?
        bne.s   getcnext                ; nein, weiter

        move.l  4(a0),d1                ; Value holen
        move.l  a0,d0                   ; Zeiger abliefern
        rts              

getcnext:
        addq.w  #8,a0                   ; nÑchster Eintrag
        bra.s   getc1    

***************************
* installcookie: Installiere neue Cookieliste
* IN: A0.L Zeiger auf neue Liste
*     D0.L Grîûe in Cookies
* USES: D1, A0, A1
* TC
***************************
installcookie:
        movem.l a0/d0,-(sp)  
        bsr     SetJar                  ; neuen Zeiger setzen
        move.l  a0,a1                   ; alten nach a1
        movem.l (sp)+,a0/d0  
        move.l  a1,d1                   ; gab es eine alte Liste?
        bne.s   instc1   

        move.l  sysbase.w,a1  
        move.w  2(a1),d1                ; TOS-Version holen
        cmp.w   #$106,d1                ; mindestens TOS 1.06?
        bpl.s   instc2                  ; ja, weiter
        bsr     resetcookie  
instc2:
        clr.l   (a0)                    ; Abschluûcookie installieren
        move.l  d0,4(a0)  
        rts              
instc1:
        bsr.s   copycookies  
        move.l  d0,-4(a0)               ; neue Grîûe schreiben
        rts              

****************************
* copycookies: Kopiere Cookieliste um
* IN: A1.L Zeiger auf alte Liste
*     A0.L Zeiger auf neue Liste
* OUT: A0: Zeigt auf erstes Byte nach letztem Cookie
*          in der neuen Liste
* Hilfsroutine
****************************
copycookies:
        move.l  d0,-(sp)  
copycloop:
        addq.w  #8,a0    
        addq.w  #8,a1    
        move.l  -4(a1),-4(a0)  
        move.l  -8(a1),d0  
        move.l  d0,-8(a0)  
        bne.s   copycloop  
copycok:
        move.l  (sp)+,d0  
        rts              

***************************
* removecookie: Entferne Cookie aus Cookieliste
* IN: D0.L Cookie
* OUT: D0.L Fehlercode (0: OK, -1: Cookie nicht gefunden)
* RÅckgabewerte wie insertcookie
* TC
***************************
removecookie:
        movem.l d0,-(sp)                ; brauchen wir gleich noch
        bsr     GetJar   
        movem.l (sp)+,d0                ; und zurÅck
        move.l  a0,a1                   ; Zeiger auf Cookieliste
        move.l  a1,d1                   ; gibt es eine Liste?
        beq.s   icerr2   
rc1:
        move.l  4(a1),d1                ; Cookiewert
        move.l  (a1),d2                 ; Cookie aus Liste holen
        beq.s   icerr                   ; keiner mehr da -> Fehler
        addq.w  #8,a1    
        cmp.l   d0,d2                   ; Cookie gefunden?
        bne.s   rc1      

        lea     -8(a1),a0               ; Zeiger fÅr copycookies
        moveq   #0,d0                   ; einrichten
        bra.s   copycookies  

***************************
* insertcookie: Legt ein Cookie in einer
* Cookieliste ab
* IN:  D0.L Cookie
*      D1.L Wert des Cookies
* OUT: D0.L Fehlercode
*          0:  OK
*          >0: Konnte nicht eingefÅgt werden; Returnwert ist
*              die Grîûe der Cookieliste in Cookies
*          -1: keine Liste da
****************************
insertcookie:
        movem.l d1-d3/a0,-(sp)  
        movem.l d0,-(sp)                ; brauchen wir gleich noch
        bsr     GetJar   
        movem.l (sp)+,d0                ; und zurÅck
        move.l  a0,d2    
        beq.s   icerr2   
        moveq   #1,d2                   ; noch keine Cookies gefunden
ic0:
        addq.l  #1,d2                   ; CookiezÑhler
        move.l  (a0),d3                 ; Ende der Liste?
        beq.s   ic1                     ; ja, weiter
        addq.w  #8,a0                   ; auf nÑchsten Cookie
                                    ; positionieren
        cmp.l   d0,d3                   ; ist das unser Cookie?
        bne.s   ic0                     ; nein, zurÅck

        move.l  d1,-4(a0)               ; neuen Wert einfÅgen
        bra.s   icok     
ic1:
        move.l  4(a0),d3                ; Grîûe der Keksliste holen
        cmp.l   d3,d2                   ; Grîûe der Keksliste holen
        bmi.s   ic2                     ; noch Platz -> weiter

icerr:
        move.l  d3,d0    
        bra.s   icexit   
icerr2:
        moveq   #-1,d0   
icexit:
        movem.l (sp)+,d1-d3/a0  
        rts              

ic2:
        move.l  d0,(a0)+                ; neuen Cookie eintragen
        move.l  (a0),8(a0)  
        move.l  d1,(a0)+  
        clr.l   (a0)     
icok:
        moveq   #0,d0    
        bra.s   icexit   

***************************
* resetcookie: Installiere Resethandler
* fÅr Cookieliste.
***************************
resetcookie:
        move.l  resvalid.w,valsave  
        move.l  resvector.w,vecsave  
        move.l  #reshandler,resvector.w  
        move.l  #RESMAGIC,resvalid  
        rts              

        DATA             
valsave:        dc.l 0
        dc.l "XBRA" 
        dc.l "CBHD" 
vecsave:        dc.l 0
reshandler:     dc.w    $4ef9           ; jmp
        dc.l    preshandler             ; eigentliche Routine
        TEXT             
preshandler:
        clr.l   cookiejar.w  
        move.l  vecsave,resvector.w  
        move.l  valsave,resvalid.w  
        jmp     (a6)     

****************************
* inst_new_cookie:
* Installiert XHDI-Cookie
* IN:  A0 Zeiger auf freien Speicherbereich
*         Speicher kann benutzt werden zum Anlegen
*         eines neuen Cookie-Jars
*      D0 Cookie-Kennung
*      D1 Cookie-Wert
* OUT: D0 verbrauchter Speicher
*****************************
inst_new_cookie:
        movem.l d1/d3-d5/a3,-(sp)  
        move.l  a0,a3    
        moveq   #64,d3   
        move.l  d0,d4    
        move.l  d1,d5    
        bsr     insertcookie  
        bne.s   inst_own_buffer  
        moveq   #0,d0    
inst_cookie_exit:
        movem.l (sp)+,d1/d3-d5/a3  
        rts              

inst_own_buffer:
        bmi.s   new_buffer  
        add.l   d0,d0                   ; Puffer verdoppeln
        move.l  d0,d3    
new_buffer:             
        move.l  d3,d0                   ; d0 Cookies installieren
        move.l  a3,a0    
        bsr     installcookie  
        move.l  d4,d0    
        move.l  d5,d1    
        bsr     insertcookie  
        asl.l   #3,d3    
        move.l  d3,d0                   ; Cookieanzahl in Bytes umrechnen
        bra.s   inst_cookie_exit  


******************************************************************************
* Alten Cookiejar-Zeiger holen
* OUT   : a0/d0 : alter Zeiger
* Uses  : a0, d0
GetJar:         movem.l d1-d2/a1-a2,-(sp)
        move.l  #-1,-(sp)               ; inquire
        move.w  #$5a0/4,-(sp)           ; Cookievektor
        move.w  #5,-(sp)                ; Setexc
        trap    #13                     ; BIOS
        addq.l  #8,sp    
        move.l  d0,a0    
        movem.l (sp)+,d1-d2/a1-a2  
        rts              

******************************************************************************
* Neuen Cookiejar-Zeiger eintragen
* IN : a0
* OUT : a0/d0 : alter Zeiger
* Uses : a0, d0
SetJar:         movem.l d1-d2/a1-a2,-(sp)
        move.l  a0,-(sp)                ; neuer Vektor
        move.w  #cookiejar/4,-(sp)      ; Cookievektor
        move.w  #5,-(sp)                ; Setexc
        trap    #13                     ; BIOS
        addq.l  #8,sp    
        move.l  d0,a0    
        movem.l (sp)+,d1-d2/a1-a2  
        rts              

        END              
         
