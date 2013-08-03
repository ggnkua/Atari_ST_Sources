; Schnelle Lîschroutine
; diese Routine verwendet auch den Stackpointer. Damit das mîglich ist,
; muû es die alte Adresse zuerst sichern, und alle Interrupts ausschalten.
; Wenn man das nicht macht, kann es passieren, das ein Interrupt auftritt
; und der Prozessor die Return-Adresse auf den Stack schreiben will, er
; es aber irgendo in den Speicher schreibt, und somit unkontrolliert
; in den Speicher schreibt.
; Auûerdem wird der Lîschbefehl nicht in einer Schleife bearbeitet, sondern
; er wird direkt im BSS (Nicht Initialisierte Daten liegen da) hinter-
; einander geschrieben. Dadurch wird die Routine um einiges schneller...
; Copyright by Kai Jourdan.
             move.l    #0,-(sp)
             move.w    #$20,-(sp)
             trap      #1
             addq.l    #6,sp
             move.l    d0,ssp
main:        bsr.s     build_clr
clr1:        move.w    #$25,-(sp)       ; auf nÑchsten Bildschirmaufbau warten
             trap      #14
             addq.l    #2,sp

             move.w    #$777,$ff8240
             move.l    #white,patch1+4  ; Bildschirm lîschen
             bsr       clr_routine
             move.w    #$0000,$ff8240

             move.l    #black,patch1+4  ; Bildschirm schwarz
             bsr       clr_routine

             subq.w    #1,counter
             bne.s     clr1

             move.w    #$777,$ff8240    ; Hintergrundfarbe wieder auf Weiû
             move.l    ssp,-(sp)
             move.w    #$20,-(sp)
             trap      #1
             addq.l    #6,sp
             clr.w     -(sp)
             trap      #1
counter:     .DC.w 500

; Erzeugt FÅllprogramm im BSS
build_clr:   move.w    #2,-(sp)
             trap      #14              ; hole Screen-Adr.
             addq.l    #2,sp
             addi.l    #32000,d0        ; von hinten beginnen
             move.l    d0,scr_patch+2   ; in Befehl schreiben
             move.l    code2,d0         ; jetzt 533 * movem.l
             move.w    #533-1,d1
             lea.l     patch2,a0
l1:          move.l    d0,(a0)+
             dbf       d1,l1
             move.l    code3,(a0)+      ; movem.l d0-d4...
             lea.l     stackrette,a1    ; movea.l oldsp,a7
             move.w    (a1)+,(a0)+
             move.w    (a1)+,(a0)+
             move.w    (a1)+,(a0)+
             move.w    code4,(a0)       ; rts
             rts       

; es folgen die Codes fÅr die verwendeten Befehle
stackrette:  movea.l   oldsp,sp
code2:       movem.l   d0-d7/a0-a6,-(sp)          ; 4 Bytes
code3:       movem.l   d0-d4,-(sp)      ; 4 Bytes
code4:       rts                        ; 2 Bytes
; FÅllmuster, mit dem die Register d0-a6 geladen werden
white:       .DC.l 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

black:       .DC.l -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1

; die halbfertige Routine
clr_routine: move.l    sp,oldsp
scr_patch:   
             lea.l     $fffff,sp        ; Screenende ( 6 Bytes )
patch1:      movem.l   white,d0-d7/a0-a6          ; Reg lîschen ( 8 Bytes )
patch2:      
             .BSS 
; Lîschbefehle ins BSS
             .DS.b 2290                 ; (533*4)+4+2
ssp:         .DS.l 1
oldsp:       .DS.l 1

