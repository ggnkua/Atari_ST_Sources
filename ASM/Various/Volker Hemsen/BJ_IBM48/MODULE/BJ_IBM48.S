
; Externes Modul fÅr PAPYRUS
; druckt in vollen 360*360 dpi !!!
; entwickelt von Volker Hemsen, 03.10.1993
; Compiler: TurboAss 1.7.6

; Hilfsmittel:   ST-Computer 2/93  (SPOOL- Direkte Druckausgabe)
;                TOFFICE-Modul aus Papyrus
;                Desert Drain 1.55
;                ATARI Profibuch ST-STE-TT


                    OPT X+,F+       ;Fast-Load-Bit gesetzt
                    OUTPUT 'D:\PAPYRUS\MODULE\BJ_IBM48.MOD'
                    TEXT

                    lea       tabelle,A0     ;Tabelle an Papyrus melden
                    move.l    A0,D0
                    rts

init1:              clr.w     bufferw
                    clr.l     buffer
                    clr.w     bufflength
                    rts

init2:              move.w    #1,bufferw
                    move.l    #48,D0
                    rts

output:             movea.l   SP,A0
                    movem.l   D3-D7/A2-A6,-(SP) ;Register retten
                    movea.l   4(A0),A2       ;Buffer
                    moveq     #0,D7
                    move.w    12(A0),D7      ;d7=Bytes pro Zeile
                    lea       8(A0),A6       ;(a6).w=Anzahl der Zeilen

                    clr.l     -(SP)          ;Super(0)
                    move.w    #$20,-(SP)
                    trap      #1
                    addq.l    #6,SP
                    move.l    D0,oldstack
                    move.l    SP,startstack  ;SP retten (fÅr Druckabbruch)

;Zeilen kopieren
zeile:              tst.w     bufflength     ;noch alte Zeilen vorhanden?
                    beq.s     cpyzlnorm
                    movea.l   buffadr,A0     ;alte Adresse holen
                    move.w    bufflength,D0  ;wieviele Zeilen brauchen wir noch?
                    clr.w     bufflength     ;fÅr's nÑchste mal
                    bra.s     cpyzl3         ;und weitere Zeilen lesen

cpyzlnorm:          lea       buffer,A0      ;volle 48 Zeilen holen
                    move.w    #48,D0         ;d0=ZeilenzÑhler
                    cmp.w     (A6),D0        ;ist die Zeile vollstÑndig da?
                    blt.s     cpyzlkl        ;ja!
                    move.w    (A6),D0        ;nein, nur den Rest kopieren
cpyzlkl:            moveq     #48,D2         ;Restzeilen merken
                    sub.w     D0,D2
                    move.w    D2,bufflength
cpyzl3:             subq.w    #1,D0
cpylpzl:            move.w    D7,D1          ;d1=BytezÑhler
                    subq.w    #1,D1
cpylpbyte:          move.b    (A2)+,(A0)+    ;Zeilen kopieren
                    dbra      D1,cpylpbyte
                    subq.w    #1,(A6)
                    dbra      D0,cpylpzl
                    tst.w     bufflength     ;alle 48 Zeilen komplett?
                    beq.s     zeileok        ;ja!
                    move.l    A0,buffadr     ;nein, Bufferadresse merken
                    bra.s     zeileendeok    ;Hallo!,Die nÑchste bitte!

zeileok:            move.w    D7,D0          ;Zeile voller Nullen?
                    mulu      #48/4,D0       ;->nur LF
                    lea       buffer,A0
zeilefullloop:      tst.l     (A0)+
                    bne.s     zeilefull
                    dbra      D0,zeilefullloop
                    bra.s     linefeed
zeilefull:          lea       data_grafik,A1 ;Grafikheader senden
                    bsr       PRNwrite
                    move.w    D7,D0          ;n1+(n2*256)=Anzahl der hor.Pixel
                    asl.w     #3,D0          ;*8
                    bsr       PRNbyte        ;n1
                    move.w    D7,D0
                    asr.w     #5,D0          ;*8 /256
                    bsr       PRNbyte        ;n2

                    move.w    D7,D3          ;Zeile umwandeln und senden!!!
                    subq.w    #1,D3
                    lea       buffer,A3      ;a3,d3: waagerechter BytezÑhler
hor_loop1:          moveq     #7,D5          ;d5: waagerechter BitzÑhler
hor_loop2:          movea.l   A3,A4
                    moveq     #5,D6          ;d6: senkrechter BytezÑhler
byte_loop:          moveq     #7,D4          ;d4: senkrechter BitzÑhler
                    moveq     #0,D0
vert_loop:          btst      D5,(A4)
                    beq.s     PRN_zeile_nopoint
                    bset      D4,D0
PRN_zeile_nopoint:  adda.w    D7,A4
                    dbra      D4,vert_loop   ;for d3=7 downto 0
                    bsr.s     PRNbyte
                    dbra      D6,byte_loop   ;for d6=2/5 downto 0
                    dbra      D5,hor_loop2   ;for d5=7 downto 0
                    addq.w    #1,A3
                    dbra      D3,hor_loop1   ;for d3=breite-1 downto 0

linefeed:           lea       data_linefeed,A1 ;LF, oder Ñhnlich
                    bsr.s     PRNwrite

                    tst.w     (A6)
                    bgt       zeile

zeileendeok:        moveq     #0,D6          ;alles OK, bitte weitere Daten
zeileende:          move.l    oldstack,-(SP) ;Super(oldstack)
                    move.w    #$20,-(SP)
                    trap      #1
                    addq.l    #6,SP
                    move.l    D6,D0          ;Returnwert
                    movem.l   (SP)+,D3-D7/A2-A6
                    rts


ende1:              clr.w     bufferw
                    clr.l     -(SP)          ;Super(0)
                    move.w    #$20,-(SP)
                    trap      #1
                    addq.l    #6,SP
                    move.l    D0,oldstack
                    moveq     #12,D0         ;FF senden
                    bsr.s     PRNbyte
                    move.l    oldstack,-(SP) ;Super(oldstack)
                    move.w    #$20,-(SP)
                    trap      #1
                    addq.l    #6,SP
ende2:              rts



; nullterminierte Bytekette auf Drucker ausgeben, Zeiger in A1
PRNwrite:           moveq     #0,D0
PRNwriteloop:       move.b    (A1)+,D0
                    beq.s     PRNwriterts    ;Null->Ende
                    bsr.s     PRNbyte
                    bra.s     PRNwriteloop
PRNwriterts:        rts

; ein Byte an Drucker ausgeben, Datum in d0
PRNbyte:            lea       $FFFFFA00.w,A0 ;mfp
                    move.l    #1500000,D1    ;Ausfallschleife
PRNbytebusy:        subq.l    #1,D1
                    bmi.s     PRNoffline     ;Druckvorgang abbrechen
                    btst      #0,1(A0)
                    bne.s     PRNbytebusy
                    btst      #0,$0D(A0)
                    bne.s     PRNbytebusy
                    move      SR,D2          ;SR retten
                    ori       #$0700,SR      ;IR's ausmaskieren
                    lea       $FFFF8800.w,A0 ;gi
                    move.b    #7,(A0)        ;Reg 7 des Soundchips wÑhlen
                    move.b    (A0),D1        ;Reg 7 nach d1
                    bset      #7,D1          ;Port B auf Ausgabe
                    move.b    D1,2(A0)
                    move.b    #15,(A0)       ;Reg 15 auswÑhlen
                    move.b    D0,2(A0)       ;d0 zum Drucker senden
                    move.b    #14,(A0)       ;Reg 14 auswÑhlen
                    move.b    (A0),D1        ;Bit 5 des Port A
                    bclr      #5,D1          ;(Strobe)
                    move.b    D1,2(A0)       ;auf low setzen
                    bset      #5,D1          ;Strobe auf high
                    move.b    D1,2(A0)       ;setzen
                    move      D2,SR          ;SR wieder herstellen
                    rts

PRNoffline:         movea.l   startstack,SP  ;SP korrigieren
                    moveq     #$FF,D6        ;Fehlermeldung
                    bra       zeileende      ;und raus


                    DATA
tabelle:            DC.L init1      ;Tabelle fÅr Papyrus
                    DC.L init2
                    DC.L output
                    DC.L ende1
                    DC.L ende2
                    DC.L buffer

data_grafik:        DC.B $1C,$43,$42,4,4,0 ;360*360 dpi
data_linefeed:      DC.B $1C,$43,$4A,4,48,13,0 ;LF & CR oder Ñhnlich

                    BSS
bufferw:            DS.W 1          ;EmpfÑnger OK
buffer:             DS.B 20000      ;interner Buffer fÅr eine Druckzeile
bufflength:         DS.W 1          ;soviele Zeilen werden noch gebraucht
buffadr:            DS.L 1          ; hier reinschreiben
oldstack:           DS.L 1          ;Platz fÅr USP
startstack:         DS.L 1          ;SP beim Programmstart (fÅr Druckabbruch)

                    END
