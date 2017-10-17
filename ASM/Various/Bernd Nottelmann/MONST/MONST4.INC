*******************************
*  Monitor-Bibliothek Teil 3  *
*                             *
*       Copyright 1988        *
*     by Bernd Nottelmann     *
*******************************


getsnbl   move.w    (A3),D0             ; Zweites Nibble holen
          lsr.w     #8,D0               ; A3: Adresse des Maschinencodes
          and.w     #%1111,D0
          rts                           ; D0: Zweites Nibble (Bit 11-8)

getbwl    moveq     #0,D7               ; Operandengrîûe holen
          move.w    (A3),D7             ; A3: Adresse des Maschinencodes
          lsr.w     #6,D7
          and.w     #%11,D7
          addq.w    #1,D7
          rts                           ; D7: Operandengrîûe

geteano   move.w    D0,-(SP)            ; EA-Nummer berechnen
          move.w    D1,D4               ; D1: EA
          lsr.w     #3,D4
          addq.w    #1,D4
          cmp.w     #8,D4
          bcs.s     geanend
          move.w    D1,D0
          and.w     #%111,D0
          add.w     D0,D4
          cmp.w     #12,D4              ; GÅltige EA?
          bls.s     geanend
          clr.w     D4
geanend   move.w    (SP)+,D0
          tst.w     D4
          rts                           ; D4: EA-Nummer/Fehler

getea1    move.w    D0,-(SP)            ; Effektive Adresse ermitteln
          move.w    (A3),D1             ; A3: Adresse des Maschinencodes
          and.w     #%111111,D1
          bsr       geteano             ; EA-Nummer berechnen
          beq.s     geaerr1
          bsr       getbwl
          bra.s     geaend1
geaerr1   moveq     #0,D7
geaend1   move.w    (SP)+,D0            ; D1: EA
          tst.w     D4                  ; D4: EA-Nummer/Fehler
          rts                           ; D7: Operandengrîûe

getea2    moveq     #0,D2               ; Adresse/Adressdistanz holen
          cmp.w     #5,D4               ; D4: EA-Nummer
          bls.s     geaend              ; D7: Operandengrîûe
          cmp.w     #9,D4               ; A3: Adresse des Maschinencodes
          beq.s     gea3
          cmp.w     #12,D4              ; Konstante?
          bhi.s     geaerr2
          bcs.s     gea2                ; Alle anderen Adressierungsarten
          cmp.w     #1,D7               ; Byte?
          beq.s     gea1
          cmp.w     #3,D7               ; Langwort?
          beq.s     gea3
gea2      move.w    2(A3),D2            ; Adresse/Adressdistanz nach D2
          cmp.w     #8,D4               ; $xxxx?
          bne.s     geaend2
          ext.l     D2
          and.l     #$00FFFFFF,D2       ; Nur 24 Bit-Adresse
          bra.s     geaend2
gea1      move.b    3(A3),D2            ; Byte
          bra.s     geaend2
gea3      move.l    2(A3),D2
          bra.s     geaend2
geaerr2   clr.w     D4
          moveq     #0,D7
geaend2   tst.w     D4                  ; D2: Adresse/Adressdistanz
          rts                           ; D4: EA-Nummer/Fehler

getea     bsr       getea1              ; Effektive Adresse holen
          beq.s     geaend
          bra       getea2              ; Sonstige Angaben siehe oben
geaend    rts

ealen     cmp.w     #6,D4               ; LÑnge einer EA ermitteln
          bcs.s     ealend              ; D4: EA-Nummer
          cmp.w     #12,D4              ; D7: Operandengrîûe
          bhi.s     ealend              ; D6: Bisherige LÑnge
          bne.s     eal
          cmp.w     #3,D7
          bne.s     eal
          addq.l    #2,D6
eal       addq.l    #2,D6
          cmp.w     #9,D4
          bne.s     ealend
          addq.l    #2,D6
ealend    rts                           ; D6: Altes D6+LÑnge

getlen    moveq     #2,D6               ; BefehlslÑnge ermitteln
          bsr       ealen               ; D4: EA-Nummer EA1/EA-Nummer EA2
          swap      D4                  ; D7: Operandengrîûe
          bsr       ealen
          swap      D4
          rts                           ; D6: BefehlslÑnge

exgea     swap      D1                  ; Quelle und Ziel vertauschen
          exg       D2,D3
          swap      D4
          rts

getopaea  clr.w     D7                  ; EAs fÅr A-Operationen holen
          lsr.w     #1,D0               ; D1: EA
          addx.w    D7,D7               ; D4: EA-Nummer
          addq.w    #2,D7               ; D0: Zweites Nibble
          bsr       getea2              ; A3: Befehlsadresse
          cmp.w     #2,D7               ; Muû eine Wortkonstante vorzeichen-
          bne.s     nogoeext            ; richtig erweitert werden?
          cmp.w     #12,D4
          bne.s     nogoeext
          ext.l     D2
nogoeext  bsr       exgea               ; D1: EA1 (LW) und EA2 (HW)
          move.w    D0,D1               ; D2: Adresse/Adressdistanz EA1
          addq.w    #%1000,D1           ; D4: EA-Nummer EA1/EA-Nummer EA2
          move.w    #2,D4               ; D7: Operandengrîûe
          bsr       exgea               ; D6: BefehlslÑnge
          bra       getlen              ; D0: Adressregisternummer

getea3    bsr       getea2              ; EAs fÅr OR/AND/SUB/ADD/CMP/EOR
          bsr       exgea               ; holen
          move.w    D0,D1               ; D1: EA
          move.w    #1,D4               ; D4: EA-Nummer
          lsr.w     #1,D1               ; D7: Operandengrîûe
          bcs.s     geaend3             ; D0: Zweites Nibble
          bsr       exgea               ; A3: Befehlsadresse
geaend3   bra       getlen              ; D1: EA1 (LW) und EA2 (HW)
                                        ; D2/D3: Adresse/Adressdistanz
                                        ; D4: EA-Nummer EA1/EA-Nummer EA2
                                        ; D6: BefehlslÑnge

disasm    movem.l   D0/A2,-(SP)         ; Maschinencodebefehl in Zwischen-
          moveq     #0,D1               ; code umwandeln
          moveq     #0,D2               ; A3: Adresse des Maschinencodes
          moveq     #0,D3               ; D0: DC-Flag
          moveq     #0,D4
          moveq     #0,D5
          moveq     #0,D6
          moveq     #0,D7
          tst.b     D0                  ; DC.W- oder DC.L-Ausgabe?
          beq.s     nodc
          bpl.s     dcl
          bsr       defconst            ; DC.W bei $80 bis $FF in D0
dcl       bsr       deflong             ; DC.L bei $01 bis $7F in D0
nodc      move.w    (A3),D0
          lsr.w     #8,D0
          lsr.w     #4,D0
          lsl.w     #2,D0
          jsr       datab(PC,D0.w)      ; Opcodeanfang ist erstes
          bsr       tec                 ; Identifikationskriterium
datab     jmp       line0(PC)
          jmp       line123(PC)
          jmp       line123(PC)
          jmp       line123(PC)
          jmp       line4(PC)
          jmp       line5(PC)
          jmp       line6(PC)
          jmp       line7(PC)
          jmp       line8C(PC)
          jmp       line9D(PC)
          jmp       lineA(PC)
          jmp       lineB(PC)
          jmp       line8C(PC)
          jmp       line9D(PC)
          jmp       lineE(PC)
          jmp       lineF(PC)
line0     bsr       getsnbl             ; Zweites Nibble holen
          cmp.w     #8,D0               ; Bit-Manipulation mit Konstante?
          beq       da05
          lsr.w     #1,D0
          bcs.s     da02
          cmp.w     #7,D0
          beq       defconst
          lea       datab0(PC),A2       ; Befehlsnummer laden
          move.b    0(A2,D0.w),D5
          bsr       getea1
          beq       defconst
          cmp.w     #12,D4              ; CCR oder SR?
          bcs.s     da00
          cmp.w     #2,D7               ; .B oder .W?
          bhi       defconst
          addq.w    #3,D4
          sub.w     D7,D4
          swap      D1                  ; Konstante ist Quelle
          move.w    #%111100,D1
          swap      D4
          move.w    #12,D4
          bsr       getea2              ; Konstante holen
          bsr       getlen              ; LÑnge
          moveq     #0,D7               ; Keine Extension-Ausgabe
          rts
da00      cmp.w     #3,D7               ; öbrige Immediate-Befehle
          bhi       defconst
          swap      D1                  ; Konstante einlesen
          move.w    #%111100,D1
          swap      D4
          move.w    #12,D4
          bsr       getea2
          exg       D2,D3               ; Konstante retten
          movea.l   A3,A2
          addq.l    #2,A3
          cmp.w     #3,D7               ; .L?
          bne.s     da01
          addq.l    #2,A3
da01      swap      D4                  ; EA einlesen
          bsr       getea2
          exg       D2,D3
          swap      D4
          movea.l   A2,A3
          bra       getlen
da02      move.w    (A3),D6             ; MOVEP oder Bit-Befehle?
          lsr.w     #3,D6
          and.w     #%111,D6
          cmp.w     #%001,D6            ; MOVEP?
          bne.s     da04
          move.w    D0,D1               ; Datenregisternummer
          moveq     #1,D4               ; Dn
          swap      D1
          swap      D4
          move.w    (A3),D1             ; Adressregisternummer
          and.w     #%111,D1
          or.w      #%101000,D1         ; d(An)
          move.w    #6,D4
          move.w    2(A3),D2            ; Adressdistanz
          move.w    (A3),D0             ; Opmode
          lsr.w     #6,D0
          move.w    D0,D7               ; Grîûe
          and.w     #%001,D7
          addq.l    #2,D7
          btst      #1,D0               ; Quelle feststellen
          beq.s     da03
          bsr       exgea
da03      moveq     #69,D5              ; Befehlsnummer
          bra       getlen
da04      move.w    D0,D1               ; BCHG, BCLR, BSET, BTST
          moveq     #1,D4               ; Datenregister bestimmt Bit
          bsr       exgea
          bsr       getea1
          movea.l   A3,A2
          bra.s     da06
da05      moveq     #%111100,D1         ; Konstante ist Quelle
          move.w    2(A3),D2            ; Bitnummer
          and.w     #$00FF,D2
          moveq     #12,D4
          bsr       exgea
          bsr       getea1
          movea.l   A3,A2               ; Befehlsadresse merken
          addq.l    #2,A3
da06      moveq     #48,D5              ; Befehlsnummer berechnen
          add.l     D7,D5
          bsr       getea2              ; Adresse/Adressdistanz holen
          bsr       exgea
          movea.l   A2,A3
          moveq     #1,D7
          bsr       getlen
          moveq     #0,D7               ; Keine Extension
          rts
line123   moveq     #68,D5              ; MOVE, MOVEA
          bsr       getea1              ; Erste EA holen
          beq       defconst
          lsr.w     #2,D0               ; Operandengrîûe ermitteln
          move.w    D0,D7
          lsr.w     #1,D0
          eor.w     D0,D7
          cmp.w     #2,D4               ; An ist Quelle?
          bne.s     da10
          cmp.w     #1,D7               ; Byteoperand?
          beq       defconst
da10      bsr       getea2              ; Adresse/Adressdistanz holen
          bsr       ealen
          bsr       exgea
          move.w    (A3),D0             ; Zweite EA holen
          lsr.w     #3,D0               ; Obere und untere HÑlfte
          move.w    D0,D1               ; vertauschen
          and.w     #%111000,D1
          lsr.w     #6,D0
          and.w     #%000111,D0
          or.w      D0,D1
          bsr       geteano             ; EA-Nummer holen
          beq       defconst
          cmp.w     #2,D4               ; An ist Ziel?
          bne.s     da11
          cmp.w     #1,D7               ; Byteoperand?
          beq       defconst
          moveq     #46,D5
          bsr       exgea
          cmp.w     #2,D7               ; Muû Wortkonstante vorzeichen-
          bne.s     da12                ; richtig erweitert werden?
          cmp.w     #12,D4
          bne.s     da12
          ext.l     D2
          bra.s     da12
da11      adda.l    D6,A3
          bsr       getea2
          suba.l    D6,A3
          bsr       exgea
da12      bra       getlen
line4     bsr       getea1              ; EA holen
          beq       defconst
          bsr       getsnbl             ; Zweites Nibble holen
          lsr.w     #1,D0               ; CHK, LEA?
          bcc.s     da41
          bsr       exgea
          moveq     #58,D5              ; CHK wird angenommen
          move.w    D0,D1               ; Registernummer Åbertragen
          move.w    #1,D4
          cmp.w     #3,D7
          bcs       defconst
          beq.s     da40
          moveq     #56,D5              ; LEA
          addq.w    #%1000,D1           ; An ist Ziel-EA
          addq.w    #1,D4
da40      bsr       exgea
          clr.w     D7
          bsr       getea2
          cmp.w     #12,D4              ; Konstante ist Quelle?
          bne.s     da4Q
          ext.l     D2                  ; Dann vorzeichenrichtig erweitern
da4Q      bra       getlen
da41      lea       datab2(PC),A2       ; Befehlsnummer laden
          move.b    0(A2,D0.w),D5
          cmp.w     #3,D0               ; NEGX, CLR, NEG, NOT?
          bhi.s     da42
          cmp.w     #4,D7
          beq.s     da47
          bra.s     da46
da42      cmp.w     #4,D0               ; NBCD?
          bne.s     da43
          cmp.w     #1,D7
          bhi.s     da49
          bra.s     da45
da43      cmp.w     #5,D0               ; TST?
          bne.s     da44
          cmp.w     #4,D7
          beq       da4G
          bra.s     da46
da44      cmp.w     #6,D0               ; MOVEM?
          beq.s     da4C
          cmp.w     #1,D7
          beq       defconst
          cmp.w     #3,D7               ; JSR, JMP?
          bcs       da4H
          beq.s     da45
          moveq     #13,D5
da45      clr.w     D7
da46      bsr       getea2
          bra       getlen
da47      clr.w     D7                  ; Nur Wortgrîûe
          moveq     #68,D5              ; MOVE from SR/to CCR/to SR
          bsr       getea2
          bsr       exgea
          move.w    #%111100,D1         ; SR oder CCR
          cmp.w     #1,D0
          beq       defconst
          bhi.s     da48
          move.w    #13,D4              ; MOVE from SR
          bra       getlen
da48      move.w    #12,D4              ; MOVE to CCR, MOVE to SR
          subq.w    #1,D0
          eori.w    #3,D0
          add.w     D0,D4
          bsr       exgea
          bra       getlen
da49      cmp.w     #2,D7               ; PEA, SWAP?
          bne.s     da4B
          cmp.w     #1,D4               ; PEA?
          beq.s     da4A
          moveq     #15,D5
          bra       da45
da4A      moveq     #8,D5               ; SWAP
          bra       da45
da4B      cmp.w     #1,D4               ; EXT?
          bne.s     da4C
          moveq     #9,D5
          subq.w    #1,D7
          bra       da46
da4C      moveq     #117,D5             ; MOVEM
          cmp.w     #3,D7
          bcs       defconst
          subq.w    #1,D7
          addq.l    #2,A3
          bsr       getea2
          moveq     #4,D6               ; LÑnge berechnen
          bsr       ealen
          bsr       exgea
          clr.w     D1
          move.w    #1,D4
          move.w    (A3),D2             ; Registermaske holen
          subq.l    #2,A3
          swap      D4
          cmp.w     #4,D0               ; Register nach Speicher?
          bne.s     da4F
          cmp.w     #5,D4               ; -(An) ist Ziel?
          bne.s     da4E
          moveq     #15,D0
da4D      lsr.w     #1,D2               ; Registermaske umdrehen
          swap      D2
          addx.w    D2,D2
          swap      D2
          dbra      D0,da4D
          swap      D2
da4E      swap      D4
          rts
da4F      swap      D1                  ; Speicher nach Register
          exg       D2,D3
          rts
da4G      moveq     #33,D5              ; TAS
          cmp.w     #12,D4              ; BRK?
          bne       da45
          moveq     #1,D5
          clr.w     D1
          moveq     #0,D2
          clr.w     D4
          clr.w     D7
          moveq     #2,D6
          rts
da4H      clr.w     D7                  ; TRAP, LINK, UNLK, MOVE USP
          move.w    (A3),D0
          lsr.w     #4,D0
          and.w     #%11,D0
          move.w    (A3),D1             ; Vektor- oder Registernummer laden
          and.w     #%1111,D1
          lea       datab3(PC),A2
          move.b    0(A2,D0.w),D5       ; Befehlsnummer laden
          beq.s     da4O
          cmp.w     #1,D0               ; TRAP, LINK/UNLK oder MOVE USP?
          beq.s     da4I
          bhi.s     da4L
          move.w    D1,D2               ; TRAP
          moveq     #%111100,D1
          moveq     #12,D4
          moveq     #2,D6
          rts
da4I      btst      #3,D1               ; LINK?
          bne.s     da4J
          swap      D1
          move.w    #%111100,D1         ; Konstante wird geladen
          moveq     #12,D4
          move.w    2(A3),D2
          ext.l     D2                  ; Vorzeichenrichtig erweitern
          moveq     #2,D6
          bsr       exgea
          addq.w    #%1000,D1
          bra.s     da4K
da4J      moveq     #10,D5              ; UNLK
da4K      move.w    #2,D4
          addq.l    #2,D6               ; BefehlslÑnge
          rts
da4L      moveq     #2,D4               ; MOVE USP
          swap      D1
          swap      D4
          clr.w     D1
          move.w    #15,D4
          swap      D1
          btst      #3,D1               ; An -> USP?
          bne.s     da4M
          addq.w    #%1000,D1
          swap      D4
          bra.s     da4N
da4M      swap      D1
da4N      moveq     #2,D6               ; BefehlslÑnge
          rts
da4O      cmp.w     #7,D1               ; RESET, NOP, STOP, RTE,
          bhi       defconst            ; RTS, TRAPV, RTR
          lea       datab1(PC),A2
          move.b    0(A2,D1.w),D5       ; Befehlsnummer laden
          beq       defconst
          clr.w     D1
          clr.w     D4
          moveq     #2,D6
          cmp.w     #12,D5              ; STOP?
          bne.s     da4P
          moveq     #%111100,D1         ; Konstante folgt
          moveq     #12,D4
          move.w    2(A3),D2
          moveq     #4,D6
da4P      rts
line5     bsr       getea1              ; EA holen
          beq       defconst
          bsr       getsnbl             ; Zweites Nibble holen
          cmp.w     #3,D7               ; ADDQ, SUBQ?
          bhi.s     da52
          cmp.w     #2,D4               ; An ist Ziel?
          bne.s     da50
          cmp.w     #1,D7               ; ADDQ.B/SUBQ.B #Konstante,An ist
          beq       defconst            ; nicht erlaubt
da50      moveq     #47,D5              ; ADDQ wird zunÑchst angenommen
          lsr.w     #1,D0
          bcc.s     da51                ; Wenn Bit 8 gesetzt ist, dann
          moveq     #48,D5              ; zeigt die Befehlsnummer auf SUBQ
da51      bsr       getea2
          moveq     #2,D6
          bsr       ealen
          bsr       exgea
          move.w    #%111100,D1         ; Konstante ist Quelle
          move.w    #12,D4
          move.w    D0,D2
          subq.w    #1,D2               ; Aus 0 mach 8
          and.w     #%111,D2
          addq.w    #1,D2
          rts
da52      cmp.w     #2,D4               ; DBcc?
          bne.s     da53
          moveq     #93,D5              ; Befehlsnummern-Basis
          subq.w    #%1000,D1           ; Dn ist Quelle
          subq.w    #1,D4
          bsr       exgea
          move.w    #%111001,D1         ; Absolut lang ist Ziel
          move.w    #9,D4
          move.w    2(A3),D2            ; Adresse berechnen
          lea       2(A3,D2.w),A2
          move.l    A2,D2
          and.l     #$FFFFFF,D2
          bsr       exgea
          moveq     #4,D6
          bra.s     da54
da53      moveq     #17,D5              ; Befehlsnummern-Basis
          bsr       getea2
          moveq     #2,D6
          bsr       ealen
da54      add.w     D0,D5               ; Befehlsnummer berechnen
          clr.w     D7
          rts
line6     moveq     #77,D5              ; BRA, BSR, Bcc
          bsr       getsnbl
          add.w     D0,D5               ; Befehlsnummer berechnen
          moveq     #2,D6
          moveq     #4,D7
          move.w    #%111001,D1         ; Absolut lang
          move.w    #9,D4
          move.b    1(A3),D2            ; 8 Bit-Adressdistanz?
          ext.w     D2
          bne.s     da60
          move.w    2(A3),D2            ; 16 Bit-Adressdistanz
          addq.l    #2,D6
          moveq     #3,D7
da60      lea       2(A3,D2.w),A2       ; Adresse berechnen
          move.l    A2,D2
          and.l     #$FFFFFF,D2
          rts
line7     bsr       getsnbl             ; MOVEQ
          lsr.w     #1,D0
          bcs       defconst
          moveq     #70,D5              ; Befehlsnummer
          move.w    D0,D1               ; Register
          moveq     #1,D4               ; Dn ist Ziel
          bsr       exgea
          move.w    #%111100,D1         ; Konstante ist Quelle
          move.w    #12,D4
          move.b    1(A3),D2            ; Wird auf Langwort erweitert
          ext.w     D2
          ext.l     D2
          moveq     #2,D6               ; BefehlslÑnge
          rts
line8C    bsr       getea1              ; DIVU, DIVS, SBCD, OR,
          beq       defconst            ; MULU, MULS, ABCD, AND, EXG
          lsr.w     #2,D0
          swap      D0                  ; Erstes Nibble retten
          bsr       getsnbl             ; Zweites Nibble holen
          cmp.w     #4,D7               ; DIVU, DIVS?
          bcs.s     da82
          clr.w     D7
          bsr       getea2
          moveq     #59,D5
          lsr.w     #1,D0               ; DIVU oder DIVS?
          bcc.s     da80
          moveq     #61,D5              ; Wenn Bit 8=1, dann DIVS
          cmp.w     #12,D4              ; Wenn Konstante Quelle bei DIVS/MULS
          bne.s     da80                ; ist, dann vorzeichenrichtig erwei-
          ext.l     D2                  ; tern
da80      bsr       exgea
          move.w    D0,D1               ; Register
          move.w    #1,D4               ; Dn ist Ziel
          bsr       exgea
          swap      D0
          cmp.w     #%1100,D0           ; MULU, MULS?
          bne.s     da81
          addq.w    #1,D5
da81      bra       getlen
da82      btst      #0,D0               ; SBCD, ABCD?
          beq.s     da87                ; Wenn Bit 8=0, dann OR/AND
          cmp.w     #2,D4               ; Wenn Bit 5-3>%001, dann OR/AND
          bhi.s     da87
          cmp.w     #1,D7               ; Wenn Bit 7-6>%00, dann EXG
          bhi.s     da8A
          cmp.w     #2,D4               ; Wenn Bit 4=%1, dann -(An), sonst Dn
          bcs.s     da83
          add.w     #%011000,D1         ; -(An)
          addq.w    #3,D4
da83      swap      D1
          lsr.w     #1,D0
          move.w    D0,D1               ; Zielregister
          cmp.w     #1,D4
          beq.s     da84
          add.w     #%100000,D1         ; -(An)
          swap      D4
          move.w    #5,D4
          bra.s     da85
da84      swap      D4                  ; Dn
          move.w    #1,D4
da85      bsr       exgea
          moveq     #40,D5              ; SBCD wird zunÑchst angenommen
          swap      D0
          cmp.w     #%1100,D0           ; ABCD?
          bne.s     da86
          moveq     #39,D5
da86      clr.w     D7
          moveq     #2,D6
          rts
da87      bsr       getea3              ; OR, AND
          moveq     #67,D5              ; OR wird zunÑchst angenommen
          swap      D0
          cmp.w     #%1100,D0           ; AND?
          bne.s     da89
          moveq     #66,D5
da89      rts
da8A      swap      D1                  ; EXG
          lsr.w     #1,D0
          move.w    D0,D1
          swap      D0
          cmp.w     #%1100,D0           ; Line_C?
          bne       defconst
          cmp.w     #1,D4               ; Dx/Ax <-> Ay?
          beq.s     da8C
          cmp.w     #3,D7               ; Ax <-> Ay?
          beq.s     da8B
          addq.w    #%1000,D1
          swap      D4
          move.w    #2,D4
          bra.s     da8D
da8B      swap      D4                  ; Dx <-> Ay
          move.w    #1,D4
          bra.s     da8D
da8C      cmp.w     #3,D7               ; Dx <-> Dy
          beq       defconst
          bra.s     da8B
da8D      moveq     #55,D5              ; Befehlsnummer
          clr.w     D7
          moveq     #2,D6
          rts
line9D    bsr       getea1              ; SUBA, SUBX, SUB,
          beq       defconst            ; ADDA, ADDX, ADD
          lsr.w     #2,D0
          swap      D0                  ; Erstes Nibble retten
          bsr       getsnbl             ; Zweites Nibble holen
          cmp.w     #4,D7               ; SUBA?
          bcs.s     da91
          bsr       getopaea
          moveq     #44,D5              ; SUBA
          swap      D0
          cmp.w     #%1101,D0           ; ADDA?
          bne.s     da90
          moveq     #43,D5
da90      rts
da91      btst      #0,D0               ; SUBX?
          beq.s     da96                ; Wenn Bit 8=%0, dann SUB
          cmp.w     #2,D4
          bhi.s     da96
          bcs.s     da92                ; Wenn Bit 4=%1, dann -(An), sonst Dn
          add.w     #%011000,D1         ; -(A1)
          addq.w    #3,D4
da92      swap      D1
          lsr.w     #1,D0
          move.w    D0,D1               ; Zielregister
          cmp.w     #1,D4
          beq.s     da93
          add.w     #%100000,D1         ; -(An)
          swap      D4
          movE.w    #5,D4
          bra.s     da94
da93      swap      D4                  ; Dn
          move.w    #1,D4
da94      bsr       exgea
          moveq     #42,D5              ; SUBX wird zunÑchst angenommen
          swap      D0
          cmp.w     #%1101,D0           ; ADDX?
          bne.s     da95
          moveq     #41,D5
da95      moveq     #2,D6
          rts
da96      bsr       getea3              ; SUB, ADD
          cmp.w     #2,D4               ; An ist Quelle?
          bne.s     da98
          cmp.w     #1,D7               ; Byteoperand?
          beq       defconst
da98      moveq     #65,D5              ; SUB wird zuerst angenommen
          swap      D0
          cmp.w     #%1101,D0           ; ADD?
          bne.s     da99
          moveq     #64,D5
da99      rts
lineA     bra       defconst
lineB     bsr       getea1              ; CMPA, CMP, EOR, CMPM
          beq       defconst
          bsr       getsnbl
          cmp.w     #4,D7               ; CMPA?
          bcs.s     daB0
          moveq     #45,D5
          bra       getopaea
daB0      moveq     #63,D5              ; CMP wird zunÑchst angenommen
          btst      #0,D0
          beq.s     daB1
          moveq     #54,D5              ; EOR
          cmp.w     #2,D4
          beq.s     daB3
daB1      bsr       getea3
          cmp.w     #2,D4               ; An ist Quelle?
          bne.s     daB2
          cmp.w     #1,D7               ; Byteoperand?
          beq       defconst
daB2      rts
daB3      moveq     #53,D5              ; CMPM
          add.w     #%010000,D1         ; (An)+ ist einzige Adressierungsart
          addq.w    #2,D4
          bsr       exgea
          move.w    D0,D1
          lsr.w     #1,D1
          add.w     #%011000,D1
          move.w    #4,D4
          moveq     #2,D6
          bra       exgea
lineE     moveq     #109,D5             ; ASd, LSd, ROXd, ROd
          bsr       getsnbl
          bchg      #0,D0
          bsr       getbwl
          cmp.w     #4,D7               ; Adresse im Speicher?
          bcs.s     daE0
          bsr       getea1
          beq.s     defconst
          clr.w     D7
          bsr       getea2
          lsr.w     #1,D0               ; Befehlsnummer berechnen
          cmp.w     #3,D0
          bhi.s     defconst
          addx.w    D0,D5
          add.w     D0,D5
          bra       getlen
daE0      move.w    (A3),D1             ; Befehlsnummer berechnen
          lsr.w     #2,D1
          and.w     #%110,D1
          lsr.w     #1,D0
          addx.w    D1,D5
          move.w    (A3),D1
          and.w     #%111,D1            ; Dn ist in jedem Fall Ziel
          moveq     #1,D4
          bsr       exgea
          move.w    D0,D1               ; Konstante/Register Åbertragen
          move.w    #1,D4               ; Dn wird als Quelle angenommen
          move.w    (A3),D0
          btst      #5,D0               ; Konstante oder Register?
          bne.s     daE1
          move.w    D1,D2
          subq.w    #1,D2
          and.w     #%111,D2
          addq.w    #1,D2
          move.w    #%111100,D1
          move.w    #12,D4
daE1      moveq     #2,D6               ; BefehlslÑnge
          rts
lineF     bra.s     defconst
tec       move.l    D6,D0               ; Kombination der Adressierungs-
          lea       cmbpnttab(PC),A2    ; arten ÅberprÅfen
          moveq     #0,D6
          move.b    -1(A2,D5.w),D6
          and.b     #%11111,D6
          bsr       tsteacmb
          bne.s     defconend
defconst  moveq     #0,D2               ; DC.W
          move.w    (A3),D2
          moveq     #2,D7
          moveq     #2,D0               ; BefehlslÑnge von DC.W
          bra.s     initdc
deflong   move.l    (A3),D2             ; DC.L
          moveq     #3,D7
          moveq     #4,D0               ; BefehlslÑnge von DC.L
initdc    moveq     #118,D5             ; DC
          moveq     #%111000,D1
          moveq     #0,D3
          moveq     #8,D4
          cmp.l     #$8000,D2
          bcs.s     defconend           ; D1: EA1 (LW) und EA2 (HW)
          addq.w    #1,D1               ; D2: Adresse/Adressdistanz EA1
          addq.w    #1,D4               ; D3: Adresse/Adressdistanz EA2
defconend addq.l    #4,SP               ; D4: EA-Nummer EA1/EA-Nummer EA2
daend     move.l    D0,D6               ; D5: Befehlsnummer
          movem.l   (SP)+,D0/A2         ; D6: BefehlslÑnge
          rts                           ; D7: Extensionnummer

*************************************************
* Zur daoutmsk (Disassembler Output Mask):      *
*                                               *
* Bit | Bezieht sich auf          | Zustand 0/1 *
* ----|---------------------------|------------ *
*   0 | Befehlswort, Extension    | groû/klein  *
*   1 | Registernamen             | groû/klein  *
*   2 | Registername SP           | SP/A7       *
*   3 | Wordextension             | an/aus      *
*   4 | Branchextension           | an/aus      *
*   5 | Adressdistanz             | dez/hex     *
*   6 | Adresse                   | hex/dez     *
*   7 | Konstante                 | dez/hex/    *
*   8 |                           | ASCII/bin   *
*   9 | Konst. vorzeichenbehaftet | aus/an      *
*  10 | Tabulator                 | an/aus      *
* ----|---------------------------|------------ *
*  11 | 8 Bit-BinÑrkonstante      | aus/an      *
*  12 | 16 Bit-BinÑrkonstante     | aus/an      *
*  13 | Konstante nur positiv     | aus/an      *
*  14 | K. nur vorzeichenbehaftet | aus/an      *
*  15 | Adresse hex. vierstellig  | aus/an      *
*                                               *
* PS: Die letzten fÅnf Bits sind nur intern     *
*     ansteuerbar.                              *
*************************************************

wrtmnem   movem.l   D1-D3/A3-A4,-(SP)   ; Befehlswort in den Puffer
          lea       mcinstab(PC),A3     ; D5: Befehlswortnummer
          move.l    D5,D1               ; D7: Extension
          moveq     #59,D3              ; A4: Pufferadresse
          bsr       wrtstrbuf
          beq.s     wmnend
          move.w    daoutmsk(PC),D1
          tst.w     D7                  ; Extension vorhanden?
          beq.s     noext
          cmp.w     #77,D5              ; Test auf Branchextensions?
          bcs.s     nobccext
          cmp.w     #92,D5
          bhi.s     nobccext
          btst      #4,D6
          bne.s     noext
          bra.s     nowrdext
nobccext  cmp.w     #2,D7               ; Wordextension?
          bne.s     nowrdext
          btst      #3,D1               ; Wordextension ausgeben?
          bne.s     noext
nowrdext  adda.l    D2,A4               ; Extension anhÑngen
          move.b    #'.',(A4)+
          lea       exttab(PC),A3
          move.b    -1(A3,D7.w),(A4)+
          clr.b     (A4)
          addq.l    #2,D2
          lea       mnembuf(PC),A4
noext     btst      #0,D1               ; Kleinschreibung?
          beq.s     wmnend
loop81    tst.b     (A4)                ; Ende?
          beq.s     wmnend
          cmpi.b    #'A',(A4)           ; Groûbuchstaben?
          bcs.s     wmn
          cmpi.b    #'Z',(A4)
          bhi.s     wmn
          addi.b    #32,(A4)            ; In Kleinbuchstaben umwandeln
wmn       addq.l    #1,A4
          bra       loop81
wmnend    move.l    D2,D0
          movem.l   (SP)+,D1-D3/A3-A4
          rts                           ; D0: LÑnge

SPtst     and.b     #%111,D0            ; Test, ob SP ausgegeben wird
          cmp.b     #7,D0               ; D0: EA
          bne.s     SPtstend            ; D6: Ausgabemaske
          btst      #2,D6               ; D0: Registernummer
SPtstend  rts                           ; Z ist gesetzt, wenn SP-Ausgabe

setAn     bsr       SPtst               ; Adressregisternummer ausgeben
          bne.s     noSP1               ; D0: EA
          addq.l    #1,D1               ; D6: Ausgabemaske
          rts                           ; D1: Stringnummer
noSP1     add.b     #48,D0              ; A2: FÅllstring
          move.b    D0,(A2)+
          rts

setadrdis move.l    D1,-(SP)            ; Adressdistanz ausgeben
          ext.l     D2                  ; D2: Adressdistanz
          move.l    D2,D1               ; D6: Ausgabemaske
          moveq     #0,D2               ; A2: FÅllstring
          btst      #5,D6
          bne.s     hexdis              ; Dezimal- oder Hexadezimalausgabe?
          moveq     #dec,D3
          sf        D4                  ; Kein Formatkennzeichen
          bra.s     sadend
hexdis    moveq     #hex,D3
          st        D4                  ; Dollarzeichen ausgeben
sadend    st        D5                  ; Vorzeichenbehaftet
          bsr       changeval
          move.l    A5,D2               ; LÑnge berechnen
          sub.l     A4,D2
loop82    move.b    (A4)+,(A2)+         ; Zahlenstring Åbertragen
          cmpa.l    A5,A4
          bls       loop82
          move.l    (SP)+,D1            ; Stringnummer zurÅckholen
          rts                           ; D2: LÑnge des Zahlenstrings

setindex  movem.l   D1-D2,-(SP)         ; Indexregister anhÑngen
          move.l    D7,D1               ; D7: Adressdistanzwort
          lsr.w     #8,D1               ; D6: Ausgabemaske
          lsr.w     #4,D1               ; A2: FÅllstring
          cmp.w     #%1111,D1
          bne.s     noSP2
          btst      #2,D6
          bne.s     noSP2
          addq.w    #1,D1
noSP2     addq.w    #1,D1               ; Nummer in regtab2
          lea       regtab2(PC),A3      ; Registertabelle
          movea.l   A2,A4
          moveq     #0,D3
          bsr       wrtstrbuf           ; Registernamen anhÑngen
          addq.l    #2,A2
          lsr.w     #8,D7               ; Grîûe ermitteln
          lsr.w     #3,D7
          and.w     #1,D7
          addq.w    #2,D7
          cmp.w     #2,D7               ; Wordextension?
          bne.s     silw
          btst      #3,D6
          beq.s     silw
          clr.w     D7
          bra.s     siend
silw      lea       exttab(PC),A3       ; Extension anhÑngen
          move.b    -1(A3,D7.w),(A2)+
siend     movem.l   (SP)+,D1-D2
          tst.w     D7
          rts                           ; D7: Extension

setadr    move.l    D1,-(SP)            ; Adresse ausgeben
          move.l    D2,D1               ; D2: Adresse
          moveq     #0,D2               ; D6: Ausgabeformat
          btst      #6,D6               ; A2: FÅllstring
          bne.s     decadr              ; D7: Operandengrîûe (fÅr DC-Ausgabe)
          moveq     #hex,D3             ; Hexadezimal
          st        D4                  ; Dollarzeichen ausgeben
          btst      #15,D6              ; Adresse vier- oder achtstellig?
          beq.s     saend
          moveq     #4,D2               ; Vierstellig bei DC.W
          cmp.w     #3,D7               ; DC.L?
          bne.s     saend
          moveq     #8,D2               ; Dann achtstellig
          bra.s     saend
decadr    moveq     #dec,D3             ; Dezimal
          sf        D4
saend     sf        D5                  ; Immer positiv
          bsr       changeval
          move.l    A5,D2               ; LÑnge berechnen
          sub.l     A4,D2
loop83    move.b    (A4)+,(A2)+         ; Zahlenstring Åbertragen
          cmpa.l    A5,A4
          bls       loop83
          move.l    (SP)+,D1            ; Stringnummer zurÅckholen
          rts                           ; D2: LÑnge des Zahlenstrings

wrtea     movem.l   D1-D7/A1-A5,-(SP)   ; EA in den Puffer schreiben
          movea.l   A4,A1               ; D1: EA
          move.l    D1,D0               ; D2: Adresse/Adressdistanz
          lea       eastrtab(PC),A2     ; D4: EA-Nummer
          moveq     #0,D1               ; A3: Befehlsadresse
          move.b    0(A2,D4.w),D1       ; A4: Pufferadresse
          move.w    daoutmsk(PC),D6
          lea       fillstr(PC),A2
          move.w    D4,-(SP)
          lsl.w     #2,D4
          jsr       weatab(PC,D4.w)
          move.w    (SP)+,D4
          bra       wea
weatab    jmp       wea0(PC)
          jmp       wea1(PC)
          jmp       wea2(PC)
          jmp       wea2(PC)
          jmp       wea2(PC)
          jmp       wea2(PC)
          jmp       wea3(PC)
          jmp       wea4(PC)
          jmp       wea5(PC)
          jmp       wea6(PC)
          jmp       wea7(PC)
          jmp       wea8(PC)
          jmp       wea9(PC)
          jmp       wea0(PC)
          jmp       wea0(PC)
          jmp       wea0(PC)
wea0      moveq     #0,D2
          rts
wea1      and.b     #%111,D0            ; Dn
          add.b     #48,D0              ; Registernummer
          move.b    D0,(A2)+
          moveq     #0,D2
          rts
wea2      moveq     #0,D2               ; An, (An), (An)+, -(An)
          bra       setAn
wea3      bsr       setadrdis           ; d(An)
          bra       setAn
wea4      move.l    D2,D7               ; d(An,Rx)
          ext.w     D2                  ; Auf Wortgrîûe erweitern
          bsr       setadrdis
          bsr       setAn
          bsr       setindex
          beq.s     weaend4
          addq.l    #2,D1
weaend4   rts
wea5      ext.l     D2                  ; $xxxx
          and.l     #$FFFFFF,D2         ; Nur 24 Bit-Adresse
wea6      bra       setadr              ; $xxxxxxxx
wea7      lea       2(A3,D2.w),A3       ; d(PC)
          move.l    A3,D2
          and.l     #$FFFFFF,D2
          bra       setadr
wea8      move.l    D2,D7               ; d(PC,Rx)
          ext.w     D2
          lea       2(A3,D2.w),A3       ; Adresse berechnen
          move.l    A3,D2
          and.l     #$FFFFFF,D2
          bsr       setadr
          bsr       setindex
          beq.s     weaend8
          addq.l    #1,D1
weaend8   rts
wea9      move.l    D1,-(SP)            ; #
          move.l    D2,D1
          lea       bdhatab(PC),A3
          move.w    D6,D0
          lsr.w     #7,D0               ; Format ermitteln
          addq.w    #1,D0
          and.w     #%11,D0
          moveq     #0,D2               ; Beliebig viele Stellen
          moveq     #0,D3
          move.b    0(A3,D0.w),D3
          st        D4
          sf        D5
          cmp.b     #str,D3
          bne.s     nostrcnst
          cmp.l     #32,D1              ; Zeichen?
          bcs.s     deccnst
          cmp.l     #126,D1
          bhi.s     deccnst
          ror.l     #8,D1
          moveq     #1,D2               ; Nur ein Zeichen
          bra.s     nocnstsgn
deccnst   moveq     #dec,D3
          sf        D4
          bra.s     nocnstsgn
nostrcnst cmp.b     #dec,D3             ; Wenn dezimal, dann keine
          bne.s     nodeccnst           ; Markierung
          sf        D4
nodeccnst btst      #14,D6              ; Konstante darf nur vorzeichen-
          bne.s     sconst              ; behaftet sein?
          btst      #13,D6              ; Konstante darf nur positiv sein?
          bne.s     posconst
          btst      #9,D6               ; Vorzeichenbehaftet?
          beq.s     nocnstsgn
sconst    st        D5
          cmp.w     #1,D7               ; Konstante ist Byte?
          bne.s     nobycnst
          ext.w     D1
          moveq     #2,D7
nobycnst  cmp.w     #2,D7               ; Konstante ist Word?
          bne.s     nocnstsgn
          ext.l     D1
          bra.s     nocnstsgn
posconst  sf        D5
nocnstsgn btst      #12,D6              ; 16 Bit-BinÑrkonstante?
          beq.s     const8
          moveq     #16,D2
          bra.s     binconst
const8    btst      #11,D6              ; 8 Bit-BinÑrkonstante?
          beq.s     nobincnst
          moveq     #8,D2
binconst  moveq     #bin,D3
          st        D4
          sf        D5
nobincnst bsr       changeval
          move.l    A5,D2               ; LÑnge berechnen
          sub.l     A4,D2
          addq.l    #1,D2               ; Das '#' wird mit einbezogen
loop84    move.b    (A4)+,(A2)+         ; Zahlen oder Zeichenstring
          cmpa.l    A5,A4               ; Åbertragen
          bls       loop84
          move.l    (SP)+,D1
          rts
wea       move.l    D2,D0               ; LÑnge des Zahlenstrings retten
          lea       fillstr(PC),A2      ; String in Puffer schreiben
          lea       adrmdtab(PC),A3     ; Tabelle der Adressierungsarten
          movea.l   A1,A4               ; Pufferadresse
          moveq     #0,D3
          bsr       wrtstrbuf           ; EA in den Puffer schreiben
          cmp.w     #8,D4               ; $xxxx?
          beq.s     wrtvalbuf
          cmp.w     #9,D4               ; $xxxxxxxx?
          beq.s     wrtvalbuf
          cmp.w     #12,D4              ; #?
          bne.s     captst       
wrtvalbuf lea       0(A4,D2.w),A4       ; Zahlenstring Åbertragen
loop85    move.b    (A2),(A4)+
          tst.b     (A2)+
          bne       loop85
          bra.s     weaend
captst    exg       D0,D2
          lea       0(A1,D2.w),A4
loop86    tst.b     (A4)                ; Stringende?
          beq.s     weaend
          btst      #1,D6               ; Registernamen groû oder klein?
          beq.s     nocaplet
          cmpi.b    #'A',(A4)           ; Groûbuchstabe?
          bcs.s     nocaplet
          cmpi.b    #'Z',(A4)
          bhi.s     nocaplet
          addi.b    #32,(A4)
nocaplet  cmpi.b    #'.',(A4)+          ; Ist noch eine Extension da?
          bne       loop86
lpend86   btst      #0,D6               ; Extension groû oder klein
          beq.s     weaend              ; schreiben?
          addi.b    #32,(A4)
weaend    movem.l   (SP)+,D1-D7/A1-A5
          tst.l     D0
          rts                           ; D0: StringlÑnge

wrtreglst movem.l   D1/D3-D6/A3-A5,-(SP); Registerliste schreiben
          movea.l   A4,A5               ; D1: EA
          cmp.w     #1,D4               ; D2: Registermaske
          bne.s     nowrl               ; D4: EA-Nummer
          tst.w     D2                  ; A3: Befehlsadresse
          beq.s     wrlerr              ; A4: Pufferadresse
          moveq     #-1,D1
          st        D3                  ; Flag fÅr erstes Register
          sf        D5                  ; Flag fÅr Registerkette
loop90    addq.w    #1,D1
          cmp.w     #15,D1
          bls.s     noendmsk
          tst.b     D5
          bne.s     dntod7
          bra.s     wrlend
noendmsk  btst      D1,D2
          beq.s     wrlbitclr
          tst.b     D5                  ; Registerkette?
          beq.s     noregchn
          cmp.w     #8,D1               ; Registerkette geht Åber D7 hinaus?
          bne       loop90
          bra.s     dntod7
noregchn  tst.b     D3                  ; Erste Registerausgabe?
          beq.s     nofreg
          sf        D3
          bra.s     wrlregout
nofreg    move.b    #'/',(A4)+
          bra.s     wrlregout
wrlbitclr tst.b     D5                  ; Ende einer Registerkette?
          beq       loop90
dntod7    subq.w    #1,D1               ; Endregister der Kette
          cmp.w     D6,D1               ; Registerkette?
          beq.s     wrlroend
          move.b    #'-',(A4)+
wrlregout move.w    D1,D4               ; EA-Nummer berechnen
          lsr.w     #3,D4
          addq.w    #1,D4
          bsr       wrtea               ; Register in die Liste schreiben
          add.l     D0,A4
          move.w    D1,D6               ; Registernummer merken
wrlroend  not.b     D5
          bra       loop90
nowrl     addq.l    #2,A3               ; Normale EA schreiben
          bsr       wrtea
          add.l     D0,A4
          bra.s     wrlend
wrlerr    movea.l   A5,A4
wrlend    move.l    A4,D0               ; LÑnge berechnen
          sub.l     A5,D0
          movem.l   (SP)+,D1/D3-D6/A3-A5
          tst.l     D0
          rts                           ; D0: StringlÑnge

setdom    movem.l   D4/A1,-(SP)         ; Interne Flags von daoutmsk setzen
          lea       daoutmsk(PC),A5     ; D5: Befehlsnummer
          move.w    (A5),D6
          and.w     #%11111111111,D6
          swap      D4
          cmp.w     #14,D4              ; Ist CCR Ziel?
          bne.s     sdsrtst
          bset      #11,D6              ; Flag fÅr 8 Bit-BinÑrkonstante
          bra.s     sdend               ; setzen
sdsrtst   cmp.w     #13,D4              ; Ist SR Ziel?
          beq.s     sdset16
          cmp.w     #12,D5              ; STOP-Befehl?
          bne.s     sdposctst
sdset16   bset      #12,D6              ; Flag fÅr 16 Bit-BinÑrkonstante
          bra.s     sdend               ; setzen
sdposctst lea       daomtab0(PC),A1     ; Soll die Konstante nur positiv
loop91    tst.b     (A1)                ; sein?
          beq.s     sdsctst
          cmp.b     (A1)+,D5
          bne       loop91
          bset      #13,D6
          bra.s     sdend
sdsctst   lea       daomtab1(PC),A1     ; Soll die Konstante nur vorzeichen-
loop92    tst.b     (A1)                ; behaftet sein?
          beq.s     sddctst
          cmp.b     (A1)+,D5
          bne       loop92
          bset      #14,D6
          bra.s     sdend
sddctst   cmp.w     #118,D5             ; DC-Befehl soll mit vierstelliger
          bne.s     sdend               ; Hex-Adresse ausgegeben werden?
          bset      #15,D6
sdend     move.w    D6,(A5)
          movem.l   (SP)+,D4/A1
          rts                           ; D6: daoutmsk

wrtmcins  pea       (A5)                ; Assembler-Befehlsstring in Puffer
          lea       dcflag(PC),A5       ; schreiben
          move.b    (A5),D0             ; A3: Befehlsadresse
          beq.s     wmida               ; A4: Stringpuffer
          cmpa.l    dcbrk(PC),A3
          bne.s     wmida
          sf        (A5)                ; DC.W-Ausgabe wird abgebrochen
          sf        D0
wmida     bsr       disasm
          movea.l   (SP)+,A5
          movem.l   D1-D4/D6/A5,-(SP)
          bsr       setdom
          movea.l   A4,A5               ; Stringpufferadresse merken
          bsr       wrtmnem
          tst.w     D4
          beq       wmiend              
          adda.l    D0,A4
          move.b    #' ',(A4)+
          btst      #10,D6
          bne.s     noeatab
          subq.w    #8,D0               ; Zahl der Blanks berechnen
          neg.w     D0
loop89    move.b    #' ',(A4)+          ; Restliche Blanks
          dbra      D0,loop89
noeatab   cmp.w     #117,D5             ; MOVEM?
          bne.s     nowreglst
          bsr       wrtreglst           ; Erste EA
          beq.s     wreglerr
          adda.l    D0,A4
          swap      D1
          move.l    D3,D2
          swap      D4
          move.b    #',',(A4)+
          bsr       wrtreglst
          bne.s     wmilen
wreglerr  lea       dcflag(PC),A4       ; Der fehlerhafte MOVEM-Befehl wird
          st        (A4)                ; mit Hilfe von DC ausgegeben
          lea       dcbrk(PC),A4        ; DC.W-Ausgabe wird an der Adresse,
          move.l    A3,(A4)             ; die in dcbrk steht, abgebrochen
          move.l    16(SP),D6
          add.l     D6,(A4)
          movea.l   A5,A4
          movem.l   (SP)+,D1-D4/D6/A5
          bra       wrtmcins            ; Nochmal von vorne
nowreglst bsr       wrtea               ; Erste EA
          adda.l    D0,A4
wmiea2    cmp.w     #49,D5              ; BTST?
          bne.s     nobtst2
          cmp.w     #12,D4              ; Ist Konstante Quelle?
          bne.s     nobtst2
          addq.l    #2,A3               ; Befehlsadresse fÅr PC-relative EA
nobtst2   swap      D1                  ; erhîhen
          move.l    D3,D2
          swap      D4
          tst.w     D4                  ; Noch eine effektive Adresse?
          beq.s     wmilen2
          move.b    #',',(A4)+
          bsr       wrtea               ; D1: EA1 (LW) und EA2 (HW)
          cmp.w     #49,D5              ; BTST?
          bne.s     wmilen
          swap      D4
          cmp.w     #12,D4              ; Ist Konstante Quelle?
          bne.s     wmilen
          subq.l    #2,A3
wmilen    adda.l    D0,A4               ; D2: Adresse/Adressdistanz EA1
wmilen2   suba.l    A5,A4               ; D3: Adresse/Adressdistanz EA2
          move.l    A4,D0               ; D4: EA-Nummer EA1/EA-Nummer EA2
          movea.l   A5,A4               ; D5: Befehlsnummer
wmiend    movem.l   (SP)+,D1-D4/D6/A5   ; D6: BefehlslÑnge
          tst.l     D0                  ; D7: Extensionnummer
          rts                           ; D0: LÑnge des Befehlsstrings

initdom   pea       (A2)                ; daoutmsk initialisieren
          lea       daoutmsk(PC),A2
          clr.w     (A2)
          movea.l   (SP)+,A2
          rts

* Ende der Monitorbibliothek Teil 4

