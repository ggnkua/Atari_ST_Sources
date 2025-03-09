        GLOBAL install,exstall

bios    EQU $B4                 ;adr des bios-
;                                vektors
gemdos  EQU $84                 ;adr des gemdos-
;                                vektors


anfang: bra     schluss
        DC.B "XBRABFOR"
oldbios:DC.L 1
mybios:
        movem.l D0-D1/A0-A1,-(SP)
        lea     22(SP),A0     ;funktionsnum-
;                              mer auf superstack
        move.w  -6(A0),D0     ;statusregister
        btst    #13,D0        ;alter Status
;                              == superviser?
        bne.s   aktiv         ;nein->zu aktiv
        move    USP,A0        ;sonst usp
;                              laden
aktiv:
        move.w  (A0),D0       ;funktionsnum-
;                              mer laden
        cmpi.w  #132,D0       ;meine umlenk-
;                              funktion?
        beq     newnumb       ;ja->
;                              neuumlenkung
        cmpi.w  #1,D0         ;nein, Bconin?
        beq.s   input         ;ja ->
;                              inputfunktion
        cmp.w   #2,D0         ;Bconstat?
        beq.s   input         ;ja
        cmpi.w  #3,D0         ;Bconout?
        beq.s   outputs       ;ja
        cmpi.w  #8,D0         ;Bcostat?
        beq.s   outputs       ;ja
back:     ;eigene arbeit erledigt
        movem.l (SP)+,D0-D1/A0-A1 ;weiter im
;                                  bios
        move.l  oldbios(PC),-(SP)
        rts

input:
        move.w  2(A0),D0      ;device in d0
        add.w   D0,D0         ;2* wegen word
        lea     itab(PC),A1   ;inputtab in a1
        cmpi.w  #6,0(A1,D0.w) ;wert in tab<6?
        bcs.s   biosin
;                              ja->
;                              umlenkung bleibt
;                              im bios

;   ab hier umlenkung in gemdos
        tst.b   isdos         ;aufruf aus
;                              gemdos?
        bne.s   back          ;ja, dann weiter
        cmpi.w  #1,(A0)       ;Bconstat?
        beq.s   info
;                              ja, dann wie
;                              Bcostat

dosin:  move.w  0(A1,D0.w),D0
;                              nein, gemdos
;                              lesen:
;                              device in d0
        pea     buf(PC)       ;alles klar-
;                              machen fÅr
;                              Fread
        move.l  #1,-(SP)
        move.w  D0,-(SP)
        move.w  #$3F,-(SP)
        trap    #1
        lea     12(SP),SP
inend:  movem.l (SP)+,D0-D1/A0-A1
        moveq   #0,D0         ;wegen long-
;                              rÅckgabe
;                              lîschen
        move.b  buf(PC),D0    ;ergebnis in d0
;                              bringen
        rte

;ende der gemdosarbeit

biosin: move.w  0(A1,D0.w),2(A0) ;funktions-
;                                 nummer aus
;                                 tabelle
;                                 Åbernehmen
        bra.s   back          ;weiter
;                              im bios


outputs:
        move.w  2(A0),D0      ;device in d0
        add.w   D0,D0         ;2* wegen word
        lea     otab(PC),A1   ;inputtab in a1
        cmpi.w  #6,0(A1,D0.w) ;wert in tab<6?
        bcs.s   biosout       ;ja-umlenkung
;                              bleibt im bios
        tst.b   isdos         ;aufruf aus
;                              gemdos?
        bne.s   back          ;ja, dann weiter
        cmpi.w  #8,(A0)       ;Bcostat?
        bne.s   dosout        ;nein, dann
;                              raus damit
info:   movem.l (SP)+,D0-D1/A0-A1 ;register
;                                  zurÅck
        move.l  #-1,D0        ;wert
;                              zurÅckgeben
        rte

dosout: move.w  0(A1,D0.w),D0 ;gemdos:
;                              newdev in d0
        move.w  4(A0),D1      ;zeichen-
        move.b  D1,buf        ;argument in
;                              buffer bringen
        pea     buf(PC)       ;alles klar-
        move.l  #1,-(SP)      ;machen fÅr
        move.w  D0,-(SP)      ;Fwrite
        move.w  #$40,-(SP)
        trap    #1
        lea     12(SP),SP
        bra.s   exit

biosout:move.w  0(A1,D0.w),2(A0) ;funktions-
;                                 nummer aus
;                                 tabelle
;                                 Åbernehmen
        bra     back          ;weiter im bios

newnumb:move.w  2(A0),D0      ;device
        add.w   D0,D0         ;2* wegen word
        move.w  4(A0),D1      ;neue device-
;                              nummer
        lea     itab(PC),A1   ;tabelle fÅr
;                              input
        tst.w   6(A0)         ;input
;                              gewÅnscht?
        beq.s   umleit        ;ja->dann los
        lea     otab(PC),A1   ;sonst output-
;                              tabelle
umleit:
        move.w  D1,0(A1,D0.w) ;neue num-
;                              mer eintragen
exit:   movem.l (SP)+,D0-D1/A0-A1
        rte

install::
        move.l  A0,-(SP)
        movea.l bios.w,A0
        cmpi.l  #"BFOR",-8(A0) ;schon
;                               installiert?
        beq.s   fast_ende
        move.l  A0,oldbios    ;alten bios
;                               retten
        move.l  #mybios,bios.w ;neuen ein-
;                               setzen
fast_ende:         ;nochmal das ganze mit gemdos
        movea.l gemdos.w,A0
        cmpi.l  #"BFOR",-8(A0)
        beq.s   ende
        move.l  A0,dosvek
        move.l  #mydos,gemdos.w
ende:   movea.l (SP)+,A0      ;und
        rts                   ;zurÅck



;hier kann man alles wieder rÅckgÑngig machen

exstall::cmpi.l #mybios,bios.w
        bne.s   fast_bye
        move.l  oldbios(PC),bios.w
fast_bye:
        cmpi.l  #mydos,gemdos.w
        bne.s   bye
        move.l  dosvek(PC),gemdos.w
bye:    rts



;einklinken in GEMDOS-Vektor

        DC.B "XBRABFOR"
dosvek: DC.L 1
mydos:
        movem.l D0/A0,-(SP)
        move.w  14(SP),D0     ;funktionsnummer
        btst    #5,8(SP)      ;statusregister
        bne.s   ok            ;supervisor
        move    USP,A0        ;sonst user
        move.w  (A0),D0       ;funktionsnummer
ok:
        cmp.w   #$4B,D0       ;pexec?
        beq.s   dosend        ;ja, dann ok
        move.l  10(SP),saveptr ;sonst
        move.l  #dosret,10(SP) ;einklinken
        st      isdos         ;bin in gemdos
dosend: movem.l (SP)+,D0/A0   ;weiter im
        move.l  dosvek(PC),-(SP) ;gemdos
        rts
dosret: clr.b   isdos         ;zurÅck aus
        move.l  saveptr(PC),-(SP) ;gemdos
        rts


saveptr:DC.L 1
itab:                         ;tabelle der
        DC.W 0                  ;eingabe-
        DC.W 1                  ;leitung
        DC.W 2
        DC.W 3
        DC.W 4
        DC.W 5

otab:   DC.W 0                  ;und der
        DC.W 1                  ;Ausgabe-
        DC.W 2                  ;umleitung
        DC.W 3
        DC.W 4
        DC.W 5

buf:
        DS.B 1                  ;puffer fÅr
;                                Fread
isdos:  DS.B 1                  ;semaphore fÅr
;                                gemdos-erkennung
        EVEN
;ein kleines installationsprogramm
schluss:pea     install(PC)   ;Supexec
        move.w  #38,-(SP)
        trap    #14
        addq.l  #6,SP
        clr.w   -(SP)         ;Ptermres
        move.l  #(256+schluss-anfang),-(SP)
        move.w  #$31,-(SP)
        trap    #1

        END

