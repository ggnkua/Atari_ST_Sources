;************************************************
;*          LABYRINTH - CREATOR                 *
;*          ===================                 *
;*                                              *
;* by Michael Krusemark                         *
;*    Ravensburger Str.44                       *
;*    7900 Ulm - 11                             *
;*    Tel.: 0731/42727                          *
;************************************************

XSTART    EQU 320
YSTART    EQU 200
XCLIP     EQU 10
YCLIP     EQU 10
WCLIP     EQU 620
HCLIP     EQU 380
XSTEP     EQU 10
YSTEP     EQU 10


          DC.W $A000          ;LineA - Init
          move.l A0,ABASE     ;LineA - Variablen

          moveq #-1,D0
          move.l D0,24(A0)    ;Farbe auf Schwarz
          move.l D0,28(A0)
          move.w D0,34(A0)    ;durchgezogene Linie

          DC.W $A00A          ;die Maus muû aus

          pea CLS(PC)         ;Bildschirm lîschen
          move.w #9,-(SP)     ;Print Line
          trap #1
          addq.l #6,SP

          lea BOX(PC),A5      ;auf Koordinaten
;                              der Box
          movem.w (A5)+,D4-D7 ;Koordinaten
          bsr LINE            ;Åbergeben
          movem.w (A5)+,D4-D7 ;und Linien
          bsr LINE            ;ziehen
          movem.w (A5)+,D4-D7
          bsr LINE
          movem.w (A5),D4-D7
          bsr LINE

          move.w #XSTART,D6
          move.w #YSTART,D7

          bsr.s LABY

          move.w #1,-(SP)     ;Cconin
          trap #1
          addq.l #2,SP

          clr.w -(SP)         ;Pterm
          trap #1


LABY:     move.w #4,D3        ;4 Richtungen testen
GET_DIR:  lea TESTED(PC),A4
          tst.w D3            ;Sackgasse?
          beq AUS             ;ja, --> zurÅck
          bsr RANDOM          ;neue Richtung holen
          tst.b 0(A4,D0.w)    ;Richtung probiert?
          bne.s GET_DIR       ;ja, --> noch einmal
          st  0(A4,D0.w)      ;Richtung getestet
          subi.w #1,D3        ;eine Richtung mehr

          move.w D6,D4        ;Xposition
          move.w D7,D5        ;Yposition
          lsl.w #2,D0         ;Richtung zu Offset
          lea STEPS(PC),A4    ;Tabelle
          add.w 0(A4,D0.w),D4 ;Xstep addieren
          add.w 2(A4,D0.w),D5 ;Ystep addieren

          movem.w D6-D7,-(SP) ;Register retten

          clr.l XADD          ;Steps = 0

          pea YTEST(PC)       ;bedingter Sprung
          cmp.w D6,D4         ;Step fÅr Schleife1
          blt XSMALLER        ;ermitteln und
          bgt XBIGGER         ;setzen
          addq.l #4,SP        ;Returnadr. lîschen


YTEST:    pea SCHLEIFE1(PC)   ;das selbe
          cmp.w D7,D5         ;wie oben
          blt YSMALLER        ;aber fÅr Schleife2
          bgt YBIGGER
          addq.l #4,SP

SCHLEIFE1:add.w XADD(PC),D6   ;Step addieren
          move.w 2(SP),D7     ;Startwert
SCHLEIFE2:add.w YADD(PC),D7   ;Step addieren

          movea.l ABASE(PC),A0 ;Test, ob der
          movea.l 12(A0),A0   ;Weg versperrt ist
          movem.w D6-D7,(A0)  ;Koordinaten
          DC.W $A002          ;Point

          tst.w D0            ;Hintergrundfarbe?
          beq.s NEXT          ;nein, -->
          movem.w (SP)+,D6-D7 ;restaurieren
          bra.s GET_DIR       ;neue Richtung

NEXT:     cmp.w D5,D7         ;Schleife beendet
          bne.s SCHLEIFE2     ;nein, --> zurÅck

          cmp.w D4,D6         ;das selbe fÅr die
          bne.s SCHLEIFE1     ;Ñussere Schleife

          movem.w (SP)+,D6-D7 ;restaurieren
          bsr.s LINE          ;Linie ziehen

GO_ON:    clr.l TESTED        ;Flags lîschen
          movem.w D6-D7,-(SP) ;Xpos,Ypos retten
          move.w D4,D6        ;neues Xpos
          move.w D5,D7        ;neues Ypos
          bsr LABY            ;Rekursion
          movem.w (SP)+,D6-D7 ;restaurieren

          bra LABY            ;nÑchste Richtung

AUS:      clr.l TESTED        ;Flags lîschen
          rts                 ;zurÅck, Backtracking

LINE:     movea.l ABASE(PC),A0 ;Basisadresse
          movem.w D4-D7,38(A0) ;Koordianten
          DC.W $A003          ;Arbitary Line
          rts

RANDOM:   move.w #$11,-(SP)   ;Zufallszahl
          trap #14            ;ermitteln
          addq.l #2,SP
          andi.w #3,D0        ;4 Bits fÅr
          rts                 ;4 Richtungen

XBIGGER:  move.w #1,XADD      ;Steps fÅr
          rts                 ;Schleifen
XSMALLER: move.w #-1,XADD     ;setzen
          rts                 ;dabei muû zwischen
YBIGGER:  move.w #1,YADD      ;aufwÑrts und
          rts                 ;abwÑrts
YSMALLER: move.w #-1,YADD     ;unterschieden
          rts                 ;werden

          DATA
STEPS:    DC.W XSTEP,0,-XSTEP,0,0,YSTEP,0,-YSTEP
; Tabelle fÅr die Steps in jede Richtung

BOX:      DC.W XCLIP,YCLIP,WCLIP+XCLIP,YCLIP
          DC.W WCLIP+XCLIP,YCLIP,WCLIP+XCLIP
          DC.W HCLIP+YCLIP
          DC.W XCLIP,HCLIP+YCLIP,WCLIP+XCLIP
          DC.W HCLIP+YCLIP
          DC.W XCLIP,HCLIP+YCLIP,XCLIP,YCLIP
;Koordinaten der Box

CLS:      DC.B 27,'E',0       ;Escape fÅr CLS

          BSS
ABASE:    DS.L 1              ;LineA-Basisadresse
XADD:     DS.W 1              ;Step fÅr Schleife1
YADD:     DS.W 1              ;und Schleife2
TESTED:   DS.B 4              ;Flags
          END

