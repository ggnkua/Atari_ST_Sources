; #########################################################################

; EINPLANE-FöLLROUTINE.

; Aufruf:   Initialisierung:  "calc_rand"
;                 Parameter:  a0     - linker Offsetbuffer (scr_h*4 groû)
;                             a1     - rechter               "

;                    FÅllen:  "h_line1"
;                Screenbase:  a0
;     Offsettabelle links  :  a3
;           "       rechts :  a4
;   Koordinatenarray links :  a5
;           "       rechts :  a6
;             Anzahl HLines:  d7

; Done:      April (Eastern) 1993 by BDC/AURA alias Jochen Knausi
; Version:   1.11
; L. Update: Jan. 95 (PMOD und Easy-Ass Anpassung).
; L. Update: MÑrz 95 (8 Tz und einen Buszugriff wegoptimiert...)

; #########################################################################

PLANES              EQU     4           ; Anzahl GrafikPLANES
PLAN_MUL            EQU     2           ; Planes: 2: 1, 4: 2, 8: 4

anz_mo              EQU     22          ; Anzahl der "move"-Bef. (+2 !)
x_aufl_max          EQU     336
by_scan             EQU     160         ; Bytes pro Scanline

ultra               EQU     1           ; 0 = letzten mîglichen Fehler 
ultra_smart         EQU     0           ; aussch. (x1 am Wortrand>x2)

PMOD                EQU     0

; *************************************************************************

; Single-Plane HLinefÅllroutine, fÅr Glenz... (das Blitter-XOR doch etwas
; langsam !)

; Screenbase                 :      a0
; Offset/Ranmdwerttabelle links  :  a3
;           "         rechts :      a4
; Koordinatenarray    links  :      a5
;     "               rechts :      a6
; Anzahl HLines              :      d7

; *************************************************************************

    IFEQ    PMOD                        ; BinÑrfile ?
            ORG     0
            
            MODUL   "f:\lib\hline_14.inc"
            MC68030

            bra.s   h_line_1            ; FÅllroutine.
            bra.w   calc_r_1            ; Offsettabellen.

            DC.B    'PMOD'              ; PMOD-Header
            DC.B    'H-Lines 1 Plane',0
            DC.B    'BDCannibal/AURA',0
            DC.B    '04930395'
            DC.B    '012020--'
            DC.B    '--------'
    ENDIF

h_line_1:   lea     end_loop(pc),a2 ; Pointer auf Ende der Schleife
            moveq   #-1,d2          ; FÅllwert $ffff
            move.l  #by_scan,d5     ; Scanoffset.

h_1_loop:   move.w  (a5)+,d3        ; Linke Koordinate
            move.w  (a6)+,d4        ; Rechte Koordinate

            move.l  (a3,d3.w*4),d0  ; Offset und Randwert links
            move.l  (a4,d4.w*4),d1  ;          "          rechts

            sub.w   d0,d1           ; LÑnge der HLine
            bgt.s   big_line        ; d1 > d0 => Linie mind. Åber 2 Vid.wo.
            IFEQ    ultra_smart
            bne.s   next_hline
            ENDIF

            IFEQ    ultra
            cmp.w   d3,d4
            blt.s   next_hline
            ENDIF

            and.l   d0,d1           ; Randwerte verknÅpfen
            swap    d1              ; auf Randwert gehen.
            or.w    d1,(a0,d0.w*PLAN_MUL)   ; reinknallen.

next_hline: adda.l  d5,a0           ; nÑchste Videozeile
            dbra    d7,h_1_loop
            rts

big_line:   lea     (a0,d0.w*PLAN_MUL),a1   ; Screenadresse

            swap    d0              ; linke Randgfx einwerfen.
            or.w    d0,(a1)

            move.w  d1,d3
            swap    d1              ; rechter Rand verodern
            or.w    d1,(a1,d3.w*PLAN_MUL)

            neg.w   d3              ; RÅckwÑrts einspringen
            jmp     4(a2,d3.w)

OFF         SET     (anz_mo-1)*PLANES*2 ; grîûter Offset am Anfang
       REPEAT                       ; Viva la cache ! Es geht noch rein !
            move.w  d2,OFF(a1)      ; $ffff reinknallen
OFF         SET     OFF-(PLANES*2)
       UNTIL  #(anz_mo-2)

end_loop:   adda.l  d5,a0
            dbra    d7,h_1_loop
            rts

; #########################################################################
; Berechnung der Randmuster und Offset fÅr jede Koordinate !
; FÅr HLine-Routine auf einem Plane (insg.: 8 Planes)
; Linke Tabelle:    a0
; Rechte Tab.  :    a1
; #########################################################################
calc_r_1:   movem.l d0-d1/d7,-(sp)

            move.w  #x_aufl_max-1,d7 ; FÅr jede Koord ein Wert.
            move.w  #$FFFF,d0       ; Startmaske (x=0)
            moveq   #0,d1           ; Offset.
left_loop:  move.w  d0,(a0)+        ; Maske.
            move.w  d1,(a0)+        ; Offset.

            lsr.w   #1,d0           ; nÑchster Status.
            bne.s   no_d_sh1

            move.w  #$FFFF,d0       ; alle 15 DurchgÑnge neu anfangen.
            addq.w  #4,d1           ; nÑchster Offset.

no_d_sh1:   dbra    d7,left_loop


            move.w  #x_aufl_max-1,d7 ; Offset analog links, Maske bit-
            move.l  #$7fff8000,d0   ; spiegelverkehrt zu links.
            moveq   #0,d1
right_loop: move.w  d0,(a1)+
            move.w  d1,(a1)+

            ror.l   #1,d0           ; nÑchsten Bitstatus.
            bcc.s   no_next_p2      ; durch ?

            addq.w  #4,d1           ; nÑchster Offset.
            move.l  #$7fff8000,d0   ; Bitstatus zurÅck.

no_next_p2: dbra    d7,right_loop

            movem.l (sp)+,d0-d1/d7
            rts