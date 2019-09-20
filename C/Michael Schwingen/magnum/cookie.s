********************************************************************************
* Routinen, um das "Cookie Jar" (siehe ST-Magazin 3/90) in eigenen Assembler-  *
* Programmen zu verwenden.                                                     *
*                                                                              *
* hunt_cookie(D0.l) - Sucht den Cookie mit dem Namen D0.l im Cookie Jar. Wurde *
*                     er gefunden, steht sein Wert in D0.l. Wurde er nicht ge- *
*                     funden, ist das N(egativ)-Flag des CCR-Registers gesetzt *
*                                                                              *
* insert_cookie(D0.l,D1.l,D2.l,A0.l) -                                         *
*                     TrÑgt einen Cookie mit dem Namen D0.l und dem Wert D1.l  *
*                     im Cookie Jar ein. Falls der Platz im Cookie Jar nicht   *
*                     mehr reicht, oder das Cookie Jar gar nicht existiert,    *
*                     wird es angelegt oder vergrî·ert. Wenn ein Cookie Jar    *
*                     neu angelegt wird, klinkt sich die Routine in den RESET- *
*                     vektor ein, um das Cookie Jar beim RESET zu entfernen.   *
*                     Wurde das Jar neu angelegt oder vergrî·ert, so MUSS das  *
*                     aufrufende Programm RESIDENT bleiben (ist bei Accessorys *
*                     nicht mîglich!!!). FÅr den Fall, da· ein Cookie Jar ein- *
*                     gerichtet werden mu·, mu· man stets in D2.l die LÑnge    *
*                     des eventuellen Cookie Jars in Langworten und in A0.l    *
*                     ein Zeiger auf den Buffer Åbergeben werden.              *
*                                                                              *
* ACHTUNG: beide Routinen mÅssen im Supervisor-Mode aufgerufen werden!!!       *
*                                                                              *
* Am Besten, wenn man sich das Demo-Programm ansieht.                          *
*                                                                              *
* Ω1990 ‰-soft, geschrieben von Markus Fritze fÅr den TurboAss V1.5            *
********************************************************************************
;Cookie mit dem Namen D0.l suchen und auf D1.l setzen
;Parameter:  D0.l : Name des Cookies
;            D1.l : neuer Wert
;            D0.l : Wert des gefundenen Cookies
;             N=1  : Cookie nicht gefunden (D0.l = LÑnge des bisherigen Jars)

change_cookie:  movem.l D1-D3/A0,-(SP)
                move.l  D0,D2           ;gesuchten Namen merken
                move.l  D1,D3           ; neuen Wert merken
                move.l  _p_cookies.w,D0 ;Zeiger auf das Cookie Jar holen
                beq.s   change_cookie2  ;ist leer => nix gefunden
                movea.l D0,A0
change_cookie1: move.l  (A0)+,D1        ;Namen eines Cookies holen
                move.l  (A0)+,D0        ;und den Wert holen
                cmp.l   D2,D1           ;Eintrag gefunden?
                beq.s   change_cookie4  ;Ja! =>
                tst.l   D1              ;Ende der Liste?
                bne.s   change_cookie1  ;Nein! => weiter vergleichen
change_cookie2: moveq   #-1,D1          ;N-Flag=1, d.h. nix gefunden
change_cookie3: movem.l (SP)+,D1-D3/A0
                rts
change_cookie4: move.l  D3,-(A0)
                bra.s   change_cookie3

;Cookie mit dem Namen D0.l suchen.
;Parameter:  D0.l : Name des Cookies
;            D0.l : Wert des gefundenen Cookies
;             N=1  : Cookie nicht gefunden (D0.l = LÑnge des bisherigen Jars)

hunt_cookie:    movem.l D1-D2/A0,-(SP)
                move.l  D0,D2           ;gesuchten Namen merken
                move.l  _p_cookies.w,D0 ;Zeiger auf das Cookie Jar holen
                beq.s   hunt_cookie2    ;ist leer => nix gefunden
                movea.l D0,A0
hunt_cookie1:   move.l  (A0)+,D1        ;Namen eines Cookies holen
                move.l  (A0)+,D0        ;und den Wert holen
                cmp.l   D2,D1           ;Eintrag gefunden?
                beq.s   hunt_cookie3    ;Ja! =>
                tst.l   D1              ;Ende der Liste?
                bne.s   hunt_cookie1    ;Nein! => weiter vergleichen
hunt_cookie2:   moveq   #-1,D1          ;N-Flag=1, d.h. nix gefunden
hunt_cookie3:   movem.l (SP)+,D1-D2/A0
                rts

;eigenen Cookie in das Cookie jar
;Parameter:  D0.l : Name des Cookies
;            D1.l : Wert des Cookies
;            D2.l : LÑnge eines eventuell einzurichtenden Cookie Jars (Langworte)
;            A0.l : Adresse eines eventuell einzurichtenden Cookie Jars
;            D0.w : 0 - alles ok, Cookie wurde eingetragen
;                    1 - wie (1), aber nun resetfest, d.h. resident bleiben
;                    2 - wie (2), aber nicht resetfest eingeklinkt
;                   <0 - Fehler aufgetreten, Cookie nicht eingetragen

insert_cookie:  movem.l D2-D5/A1,-(SP)
                move.l  D2,D5           ;LÑnge einer evtl. Liste merken
                move.l  _p_cookies.w,D3 ;Zeiger auf das Cookie Jar holen
                beq.s   insert_cookie_s ;ist leer => Liste einrichten
                movea.l D3,A1
                moveq   #0,D4           ;Anzahl der Slots
insert_cookie_h:addq.w  #1,D4           ;Slotanzahl erhîhen
                movem.l (A1)+,D2-D3     ;Namen und Wert eines Cookies holen
                tst.l   D2              ;leeren Cookie gefunden?
                bne.s   insert_cookie_h ;Nein => weiter suchen
                cmp.l   D3,D4           ;alle Slots belegt?
                beq.s   insert_cookie_n ;Ja! => neue Liste anlegen
                movem.l D0-D4,-8(A1)    ;neuen Cookie & Listenende einfÅgen
                moveq   #0,D0           ;alles ok!
                bra.s   insert_cookie_x ;und raus

insert_cookie_s:moveq   #2,D4
                cmp.l   D4,D2           ;weniger als 2 EintrÑge?
                blo.s   insert_cookie_e ;das ein Fehler! (Liste zu klein!)
;                move.l  resvector.w,old_resvector
;                move.l  resvalid.w,old_resvalid ;alten Reset-Vektor merken
;               move.l  #cookie_reset,resvector.w
;                move.l  #$31415926,resvalid.w ;und eigenen einsetzen
                move.l  A0,_p_cookies.w ;Cookie Jar initialisieren
                moveq   #0,D3           ;Markierung: Ende der Cookie-List
                exg     D2,D3           ;Anzahl der Slots nach D3
                movem.l D0-D3,(A0)      ;Namen und Wert des Cookies einsetzen
                moveq   #1,D0           ;Liste resetfest eingerichtet, alles ok
                bra.s   insert_cookie_x ;und raus

insert_cookie_e:moveq   #-1,D0          ;Fehler, Cookie nicht eingetragen
                bra.s   insert_cookie_x ;und raus


insert_cookie_n:cmp.l   D5,D4           ;reicht der Platz?
                ble.s   insert_cookie_e ;Nein => Fehler und raus
                movea.l _p_cookies.w,A1 ;Anfang der Liste erneut holen
                move.l  A0,_p_cookies.w ;neuen Cookie Jar eintragen
                subq.w  #2,D4           ;Ende nicht kopieren (-1 fÅr DBRA)
insert_cookie_m:move.l  (A1)+,(A0)+     ;EintrÑge der Liste kopieren
                move.l  (A1)+,(A0)+
                dbra    D4,insert_cookie_m
                move.l  D5,D3           ;Anzahl der Slots
                movem.l D0-D3,(A0)      ;eigenes Element eintragen + Listenende
                moveq   #2,D0           ;alles ok, resident bleiben
insert_cookie_x:movem.l (SP)+,D2-D5/A1
                rts
