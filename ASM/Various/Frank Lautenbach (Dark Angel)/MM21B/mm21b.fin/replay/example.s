; *************************************************************
; **** Beispiel fÅr die Einbindung eines mit "SAVE MODUL"  ****
; **** abgespeicherten Songs in Assembler.                 ****
; **** Es kînnen die Module aller Versionen abgespielt     ****
; **** werden!                                             ****
; *************************************************************

                pea     mes1(PC)
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP

; *** das Songmodul einladen: ***

                clr.w   -(SP)                ; OPEN
                pea     songname(PC)
                move.w  #$3D,-(SP)
                trap    #1
                addq.l  #8,SP

                tst.l   D0                   ; ERROR?
                bmi     error

                move.l  D0,D7

                pea     buffer               ; READ
                move.l  #15000,-(SP)
                move.w  D7,-(SP)
                move.w  #$3F,-(SP)
                trap    #1
                lea     12(SP),SP

                move.w  D7,-(SP)             ; CLOSE
                move.w  #$3E,-(SP)
                trap    #1
                addq.l  #4,SP

                pea     0                    ; --> SUPERVISOR
                move.w  #$20,-(SP)
                trap    #1
                addq.l  #6,SP
                move.l  D0,ssp_save

                bsr     routine+44           ; ACIA PATCH
                bsr     routine+60           ; SPURIOUS Interrupt Patch

; (ein Timer C-Patch ist nicht nîtig, da wir uns selbst dort reinhÑngen, und
;  entsprechende Maûnahmen selbst vornehmen!)

                lea     buffer,A0
                bsr     routine+28           ; * ASK MOD TYPE *

                btst    #0,D0                ; Digi-Modul?
                beq.s   nodigimodul

                lea     buffer,A0
                lea     modul(PC),A1
                bsr     routine+8            ; * INIT 2 (Digi-Pre-Init) *

                lea     modul(PC),A0
                move.w  #%1011,D0            ; Timer A,B,D duerfen fuer Digis, SIDs, etc. verwendet werden
                bsr     routine+4            ; * INIT 1 *

; * jetzt ist das Digi-Modul fertig initialisiert *
; * Nun folgt die Einbindung in die Interruptstruktur, hier in den TIMER C: *

                bsr.s   link_in

                move.w  #7,-(SP)             ; Warten auf Taste
                trap    #1
                addq.l  #2,SP

                move.l  old_vector(PC),$0114.w ; Routine wieder aushÑngen!

                bra.s   weider

; --------------------------------------------- Vorgehen bei Digilosen Modulen:

nodigimodul:    lea     buffer,A0
                move.w  #%1011,D0            ; Timer A,B,D duerfen fuer SIDs, etc. verwendet werden
                bsr     routine+4            ; * INIT 1 *

                bsr.s   link_in              ; und Routine einhÑngen!

                move.w  #7,-(SP)
                trap    #1
                addq.l  #2,SP

                move.l  old_vector(PC),$0114.w ; Routine wieder aushÑngen!

weider:
                bsr     routine+36           ; Timer restore (Digis,SIDs,etc.)
                bsr     routine+40           ; Sounds off!

                bsr     routine+48           ; ACIA-Patch rÅckgÑngig machen
                bsr     routine+64           ; SPURIOUS Interrupt Patch rÅckgÑngig

                move.l  ssp_save(PC),-(SP)   ; --> USER-Mode
                move.w  #$20,-(SP)
                trap    #1
                addq.l  #6,SP

                bra.s   noerror

error:          pea     mes2(PC)
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP

                move.w  #7,-(SP)
                trap    #1
                addq.l  #2,SP

noerror:        clr.w   -(SP)
                trap    #1

; *****************************************************************************

; ******* EinhÑngen in den Timer C (Systemroutine dabei rausschmeissen): ****
;                                   (dadurch gibt's keinen érger mit dem
;                                    Acia-Interrupt!)

link_in:        move.l  $0114.w,old_vector
                move.l  #new_tc,$0114.w
                rts

; ------------------------------------- Der Timer C - Handler:

new_tc:         andi    #$F4FF,SR            ; (fÅr den Fall, dass Digis,SIDs, etc.
;                                              gespielt werden!)

                bsr     routine+16           ; 200Hz-Ansprung (Register werden
;                                              alle gerettet)

;                                              ACHTUNG: bei einem Aufruf mit
;                                              50Hz (z.B. VBL) erfolgt der
;                                              Ansprung bei +12 !!!

                bclr    #5,$FFFA11           ; EOI (End of Interrupt)
                rte                          ; und weg!


; *******************************************************************************

                data

old_vector:     dc.l 0

mes1:           dc.b 27,'E'
                dc.b '*************************************',13,10
                dc.b '* Beispiel fÅr die Einbindung eines *',13,10
                dc.b '* Songmoduls beliebiger Version in  *',13,10
                dc.b '* Assembler!                        *',13,10
                dc.b '*                                   *',13,10
                dc.b '* Zum Abbrechen eine Taste drÅcken. *',13,10
                dc.b '*************************************',13,10
                dc.b 13,10,0

mes2:           dc.b 'Ich kann die Dateien nicht finden !!!',13,10,0

songname:       dc.b 'demo.mod',0

                even

routine:        ibytes 'REPLAY.INL' ; * die Abspielroutine *
                even

                bss

ssp_save:       ds.l 1

modul:          ds.b 50000         ; * Platz fÅr das Modul *
                even
buffer:         ds.b 50000         ; * Platz, um das Modul zwischenzuspeichern *
;                                      (nur bei Digi-MOdulen notwendig!)
                end
