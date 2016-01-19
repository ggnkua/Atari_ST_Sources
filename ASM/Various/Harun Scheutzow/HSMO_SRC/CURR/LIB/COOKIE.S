
;Routinen zur Nutzung des Cookie Jar
;Harun Scheutzow, 15.07.1993, mit GFA-Assembler
;MODIFIZIERT am 11.11.1993: jetzt komplett frei verschiebbar

RESMAGIC  = $31415926
_resvalid           = $426
_resvector          = $42a
_p_cookies          = $5a0           ;Adresse des Zeigers auf Cookie Jar

cookie_find:        
;Aufruf im Supervisormode.
;C-Prototyp: void * cookie_find(ULONG cookiename);
;sucht Cookie und liefert Zeiger auf den Namen
;in:   C-mÑûig auf Stack der Name des gesuchten Cookies als LONG
;out:  D0 Zeiger auf Name des Cookies oder 0 fÅr nicht gefunden
;kill: A0,D1
          move.l    4(sp),d1         ;gesuchter Cookie
          move.l    _p_cookies,d0
          beq.s     .ende            ;kein Cookie Jar
          movea.l   d0,a0
.suche:   move.l    (a0),d0
          beq.s     .ende            ;Nullcookie erreicht
          cmp.l     d0,d1
          beq.s     .gefund          ;Cookie gefunden
          addq.l    #8,a0
          bra       .suche
.gefund:  move.l    a0,d0
.ende:    rts       


cookie_insert:      
;Aufruf im Supervisormode.
;C-Prototyp:
;LONG cookie_insert(ULONG co_name, ULONG co_value, void * mem_start,
;                   LONG mem_max);
;FÅgt den Cookie co_name mit Wert co_value in den Cookie Jar ein. Falls
;Platz nicht reicht, wird Cookie Jar nach mem_start umkopiert und noch
;8 leere Cookies hinzugefÅgt. Es werden maximal mem_max Byte dafÅr belegt.
;Ist der Cookie vorhanden, wird sein Wert geÑndert. Ist mem_start 0,
;wird nicht umkopiert.
;RÅckgabe: umkopiert: Anzahl belegter Byte (immer >0)
;          Operation ok: -1
;          Fehler: 0 (kein Cookie Jar, Platz reichte auch zum Kopieren nicht)
;in:   C-mÑûig auf Stack
;out:  D0
;kill: A0,A1,D1
          movem.l   d2/a2,-(sp)
          move.l    _p_cookies,d0
          beq       .nojar           ;kein Cookie Jar, -> einrichten
          move.l    8+4(sp),-(sp)
          bsr       cookie_find      ;Cookie suchen
          addq.l    #4,sp
          movea.l   d0,a0            ;setzt leider keine Flags
          tst.l     d0
          bne.s     .vset            ;gefunden, nur Wert setzen
          movea.l   _p_cookies,a0
          moveq.l   #0,d2
.nsuch:   
          move.l    0(a0,d2.l),d1    ;suche Ende der Liste, den Nullcookie
          beq.s     .lend            ;gefunden
          addq.l    #8,d2
          bra       .nsuch
.lend:    
          lea       0(a0,d2.l),a1    ;Zeiger auf Nullcookie
          lsr.l     #3,d2            ;Anzahl Cookies bestimmen, 8 Byte pro C.
          addq.l    #1,d2            ;Korrektur
          move.l    4(a1),d1         ;Maximalanzahl (Nullcookie Wert)
          moveq.l   #-1,d0           ;ok signalisieren
          cmp.l     d1,d2
          bcc.s     .newj            ;kein Platz zum AnhÑngen
;zuerst Nullcookie neu anlegen, kînnte sonst bei irgendwann Multitasking
;im Supervisormode fatal werden, wenn jemand dazwischenkommt
          clr.l     8(a1)            ;Nullcookie Name
          move.l    d1,12(a1)        ;Nullcookie Wert
          move.l    8+4(sp),(a1)+    ;Cookie Name
          move.l    8+8(sp),(a1)+    ;Cookie Wert
          bra.s     .ende

.newj:    move.l    8+12(sp),d0      ;Adresse des Ausweichplatzes
          beq.s     .ende            ;Fehler, kann nicht umkopieren
          movea.l   d0,a2            ;Zeiger auf zukÅnftigen Cookie Jar
          move.l    a1,d2            ;wieviel Platz fÅr Kopie?
          sub.l     a0,d2
          addi.l    #80,d2           ;+ Nullcookie, +1 Cookie, +8 freie PlÑtze
          moveq.l   #0,d0            ;vorsorglich Fehlermeldung
          cmp.l     8+16(sp),d2
          bhi.s     .ende            ;kein Platz zum Umkopieren
.copy:    move.l    (a0)+,(a2)+      ;je 1 Cookie kopieren
          move.l    (a0)+,(a2)+
          cmpa.l    a1,a0
          bcs       .copy
          addq.l    #4,d1            ;Maximalanzahl um 9 erhîhen
          addq.l    #5,d1
          move.l    d2,d0            ;RÅckmeldung: belegter Platz in D0

          move.l    8+4(sp),(a2)+    ;Cookie Name
          move.l    8+8(sp),(a2)+    ;Cookie Wert
          clr.l     (a2)+            ;Nullcookie Name
          move.l    d1,(a2)+         ;Nullcookie Wert
          move.l    8+12(sp),_p_cookies           ;Adresse auf neuen fertigen C.J.
          bra.s     .ende

.vset:    
          move.l    8+8(sp),4(a0)    ;Wert eintragen
.okend:   
          moveq.l   #-1,d0           ;ok
.ende:    
          movem.l   (sp)+,d2/a2
          rts       

.nojar:   
;Kein Jar da, einrichten
          move.l    8+12(sp),d0      ;habe ich Speicher?
          beq       .ende            ;nein
          movea.l   d0,a0            ;Adr. des Speichers merken
          moveq.l   #0,d0            ;vorausschauende Fehlermeldung
          move.l    #(.resfend-.resfest)+8*8,d2   ;und merken
;Platz fÅr Cookie-Lîscher und 8 Cookies
          cmp.l     8+16(sp),d2      ;reicht Speicher?
          bhi       .ende            ;nein

          lea       .resfest(pc),a2  ;(wegen Verschiebbarkeit)

          move.l    _resvector,.oldres-.resfest(a2)         ;alten Resetvektor kopieren
          move.l    _resvalid,.oldval-.resfest(a2)          ;altes Resetvalid kopieren

          move.l    #(.resfend-.resfest)-1,d0     ;soviel Byte mit dbf kopieren
          movea.l   a0,a1
.njcop:   move.b    (a2)+,(a1)+
          dbf       d0,.njcop

          move.l    a1,d0            ;Adr. Cookie Jar merken
          move.l    8+4(sp),(a1)+    ;Cookie eintragen
          move.l    8+8(sp),(a1)+    ;Wert
          clr.l     (a1)+            ;Nullcookie
          move.l    #8,(a1)          ;Wert

          adda.l    #.newres-.resfest,a0          ;Adr. der Resetroutine ermitteln
          move.l    a0,_resvector    ;neuer Resetvektor
          move.l    #RESMAGIC,_resvalid           ;gÅltig machen
          move.l    d0,_p_cookies    ;Cookie Jar installieren

          move.l    d2,d0            ;Anzahl zusÑtzlich residenter Byte
          bra       .ende            ;Ende mit OK

.resfest: 
;Wird benîtigt und an den Anfang des Platzes fÅr Cookie Jar kopiert,
;wenn noch kein Cookie Jar existierte. FÅr TOS1.00, 1.02, 1.04 evtl. nîtig.
;Muû in sich frei verschiebbar sein!!!
.oldval:  DC.l 0   ;alter Resvalid-Wert
          DC.b 'XBRACKJR'           ;Kennung aus Profibuch geklaut
.oldres:  DC.l 0   ;alter Resetvektor
.newres:  clr.l     _p_cookies       ;Cookie Jar lîschen
          move.l    .oldres(pc),_resvector
          move.l    .oldval(pc),_resvalid
          jmp       (a6)             ;weiter im Reset
.resfend: 


