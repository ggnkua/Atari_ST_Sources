* BOUNCE          The Bouncing Sprite

****************************************************
* Die Bounce-Routine stammt von Metacomco und wird *
* mit freundlicher Genehmigung von Pamela Clare -  *
* Director Metacomco- verwendet.                   *
* Das Original ist etwas schwer zu erkennen, weil  *
* ich es an meine LINE-A-Lib angepasst habe.       *
* Peter Wolschlaeger.                              *
****************************************************
      
       include  "linea.inc"

*hier geht es los 
*----------------
xmin   equ      8                  ;Setze das Bounce-Window
ymin   equ      8                  ;8 Pixels vom Rand
xmax   equ      631
ymax   equ      391

start  init                        ;Line-A initialisieren
       color    #1,#1,#1,#1        ;hochaufloesend
       move     #0,wrt_mode(a5)    ;Replace-Modus
       move.l   #filpat,patptr(a0) ;Zeige auf Fuellmuster
       move     #0,patmsk(a0)      ;keine Fuellmaske
       move     #0,multifil(a0)    ;nur eine Plane
       rectf    #1,#1,#638,#398    ;Schirm schwarz mit
                                   ;mit weissem Rand
;zeichne Sprite
       dsprite  xpos,ypos,sprdef,sprsave

movx   move     #-1,-(sp)          ;teste Sondertasten
       move     #11,-(sp)
       trap     #13
       addq.l   #4,sp
       btst     #2,d0              ;Control-Taste?
       beq      weiter             ;wenn nicht
       clr      -(sp)              ;sonst terminate
       trap     #1
weiter
       move     xpos,d0            ;hole X-Position
       add      xvel,d0            ;addiere Tempo (= Weg)
       cmp      #xmax,d0           ;am Anschlag?
       bgt      xbounce            ;wenn nicht "bounce"
       cmp      #xmin,d0           ;anderer Anschlag?
       bge      noxb               ;Bouce nicht in x

;Bouncing in X-Richtung
;----------------------
xbounce
      neg       xvel              ;Richtung umkehren
      bra       movx              ;neuer Versuch
noxb  move      d0,xpos

movy  move      ypos,d1           ;wie oben bei x
      add       yvel,d1
      cmp       #ymax,d1
      bgt       ybounce
      cmp       #ymin,d1
      bge       noyb

;Bounce in Y-Richtung
;--------------------
ybounce
      neg       yvel
      bra       movy              ;wie bei x

noyb  move     d1,ypos
      usprite  sprsave
      dsprite  xpos,ypos,sprdef,sprsave

      move     #37,-(sp)          ;Warte auf Austastluecke
      trap     #14
      addq.l   #2,sp
      bra      movx               ;und starte wieder
;---------------------------------------------------------
xpos  dc.w     100                ;hiermit fangen wir an
ypos  dc.w     100 
xvel  dc.w     3                  ;je groesser
yvel  dc.w     3                  ;desto schneller

      data

;hier sind die Daten fuer den Sprite (happy face)

sprdef
      dc.w     8          ;X-Offset vom Hot Spot
      dc.w     8          ;Y
      dc.w     -1         ;XOR-Sprite-Format
      dc.w     0          ;Hintergrundefarbe (keine)
      dc.w     1          ;Vordergrund schwarz

sprite
      dc.w     %0000000000000000   ;Hintergrund Zeile 0
      dc.w     %0000001111000000   ;Vordergund  Zeile 0
      dc.w     %0000000000000000   ;Hintergrund 1
      dc.w     %0000111111110000   ;Vordergrund 1
      dc.w     %0000000000000000   ;2
      dc.w     %0001111111111000
      dc.w     %0000000000000000   ;3
      dc.w     %0011111111111100
      dc.w     %0000000000000000   ;4
      dc.w     %0111111111111110
      dc.w     %0000000000000000   ;5
      dc.w     %0111111111111110
      dc.w     %0000000000000000   ;6
      dc.w     %1111011111001111
      dc.w     %0000000000000000   ;7
      dc.w     %1111001111001111
      dc.w     %0000000000000000   ;8
      dc.w     %1111111111111111
      dc.w     %0000000000000000   ;9
      dc.w     %1111111111111111
      dc.w     %0000000000000000   ;10
      dc.w     %0111111111111110
      dc.w     %0000000000000000   ;11
      dc.w     %0111101111011110
      dc.w     %0000000000000000   ;12
      dc.w     %0011110001111000
      dc.w     %0000000000000000   ;13
      dc.w     %0011111111111100
      dc.w     %0000000000000000   ;14
      dc.w     %0000111111110000
      dc.w     %0000000000000000   ;15
      dc.w     %0000001111000000

filpat dc.w    -1    ;Fuellmuster schwarz

sprsave ds.b   74    ;Speicher fuer Sprite

      end
