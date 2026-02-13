* TDISP  Demo Trap-Dispatcher

;Um den Dispatcher zu testen, wird Trap #7 benutzt
;-------------------------------------------------
        pea      tdisp         ;Adresse des Dispatchers
        move     #39,-(sp)     ;Vektor 39 = Trap #7
        move     #5,-(sp)      ;BIOS-Funktion SETEXCEP
        trap     #13           ;aufrufen
        addq.l   #8,sp

;nun folgen 3 Aufrufe
;-------------------
        move     #'A',-(sp)    ;wir simulieren
        move     #2,-(sp)      ;conout
        trap     #7            
        addq.l   #4,sp

        move     #1,-(sp)      ;und nun das neue conin
        trap     #7
        addq.l   #2,sp

        clr      -(sp)         ;und schliesslich term
        trap     #7

;hier startet eine Kopie des Trap-Dispatchers des ST
;im ROM-TOS ab $FC074E
;---------------------------------------------------
tdisp
        lea     table(pc),a0      ;Adressen der Routinen
        move.l  #save,a1          ;Datensicherungsbereich
                                  ;im Original $4A2
        move    (sp)+,d0          ;SR holen
        move    d0,-(a1)          ;und retten
        move.l  (sp)+,-(a1);      ;PC holen und retten
        movem.l d3-d7/a3-a7,-(a1) ;und Register retten
        move.l  a1,save           ;Zeiger retten
        btst    #13,d0            ;Aufruf im Supervisor-Modus?
        bne.s   super             ;wenn so
        move.l  usp,sp            ;benutze USP
super   move    (sp)+,d0          ;hole Funktionsnummer
        cmp     (a0)+,d0          ;vergleiche mit Count
        bge.s   exit              ;Abbruch wenn groesser
        lsl     #2,d0             ;Funkionsnummer mal 4
        move.l  0(a0,d0),d0       ;Adresse der Routine
        move.l  d0,a0             ;auch noch nach a0
        bpl.s   direct            ;wenn kein Vektor (Bit 31=0)
        move.l  (a0),a0           ;sonst ARI
direct  sub.l   a5,a5             ;a5 loeschen
        jsr     (a0)
exit    move.l  save,a1           ;auf Sicherungsbereich
        movem.l (a1)+,d3-d7/a3-a7 ;Register zurueck
        move.l  (a1)+,-(sp)       ;PC wieder auf Stack
        move    (a1)+,-(sp)       ;SR dto.
        move.l  a1,save           ;Zeiger zurueck
        rte

;hier werden 3 Routinen simuliert
;--------------------------------   
table   dc.w    3                 ;Anzahl der Routinen
        dc.l    term              ;Adress-Tabelle
        dc.l    conin
        dc.l    conout

term    move.l   (sp)+,(sp)
        clr      -(sp)
        trap     #1  
      
conin   move    #1,-(sp)
        trap    #1
        addq.l  #2,sp
        rts

conout  move    4(sp),-(sp)    
        move    #2,-(sp)
        trap    #1
        addq.l  #4,sp
        rts

        ds.l    20
save    equ     *
        
        end
