;
;       Assemblerteil fr INIT_VGA      (c) 1992 by Till Harbaum
;

.globl  clear_mem,adapter_ist_da
IOBASE  equ             $cf0000

;
;       Anzahl Bytes ab Adresse l”schen
;
clear_mem:
        lsr.l   #2,d0           ; Anzahl Bytes durch vier teilen
cl_lp:
        clr.l   (a0)+           ; l”schen
        subq.l  #1,d0
        bne.b   cl_lp
        rts

;
;       Testen, ob Adapter da ist
;       0 - kein Adapter da
;       1 - Adapter da
;
berr_stga:
        clr     d7                      ; Berr -> keine VGA
        bra.s   no_stga

adapter_ist_da:
        movem.l d1-d7/a0-a6,-(sp)
        clr.l   -(sp)
        move    #$20,-(sp)              ; Supervisor an
        trap    #1
        addq.l  #6,sp
        move.l  d0,-(sp)                ; alten Sp auf Stack

        move.l  8,a0                    ; alten Busfehlervektor sichern
        move.l  sp,a1                   ; alten Stack sichern
        move.l  #berr_stga,8            ; neuen Handler rein

        move.b  #$01,IOBASE+$3c3        ; Karte freigeben
        st      d7                      ; alle klar!
no_stga:
        move.l  a1,sp                   ; Stack restaurieren
        move.l  a0,8                    ; Busfehlervektor reparieren

        move    #$20,-(sp)
        trap    #1                      ; Supervisor aus
        addq.l  #6,sp

        move    d7,d0
        movem.l (sp)+,d1-d7/a0-a6
        rts
