; ----------------------------------------------------
; - Bernd Hbenett (RxT) 01.04.1994 Obertshausen     -
; -                                                  -
; - Dieses Program liefert nur im DC oder True-Color -
; - Mode des Falcon030 vernnftige Ergebnisse.       -
; - Das Programm sollte nur in Aufl”sungen mit       -
; - 320 Pixeln in X gestartet werden.                -
; ----------------------------------------------------

cnecin          EQU 8
logbase         EQU 3
super           EQU 32
vsync           EQU 37

start:          pea     0
                move.w  #super,-(SP)
                trap    #1
                addq.l  #6,SP
                move.l  D0,ssp

                move.w  #logbase,-(SP)
                trap    #14
                addq.l  #2,SP
                move.l  D0,scr

                lea     bin_file,A0     ; Startadress of the BIN-File
                move.l  (A0)+,D0        ; lenght in DSP-Words
                move.w  #3,-(SP)        ; ??????
                move.l  D0,-(SP)        ; Lenght
                move.l  A0,-(SP)        ; DSP-Data
                move.w  #109,-(SP)      ; DSP-ExecProg
                trap    #14
                lea     12(SP),SP

                pea     dta(PC)
                move.w  #26,-(SP)
                trap    #1
                addq.l  #6,SP

erstes_bild:    clr.w   -(SP)
                pea     suchmaske(PC)
                move.w  #78,-(SP)
                trap    #1
                addq.l  #8,SP
                tst.b   D0
                bmi     raus

bild_loop:      clr.w   -(SP)
                pea     dateiname(PC)
                move.w  #61,-(SP)
                trap    #1
                addq.l  #8,SP

                move.w  D0,D7
                pea     bild(PC)
                move.l  #192000,-(SP)
                move.w  D7,-(SP)
                move.w  #63,-(SP)
                trap    #1
                lea     12(SP),SP

                move.w  D7,-(SP)
                move.w  #62,-(SP)
                trap    #1
                addq.l  #4,SP

; ----------------------------------------------------
; - Routine die das ungepackte 24-Bit Bild in ein    -
; - Bild mit 16-Bit Farbtiefe umrechnet und auf dem  -
; - Bildschirm darstellt. Die XY-Aufl”sung von       -
; - 320x200 Pixeln bleibt unver„ndert.               -
; -                                                  -
; - Organisation:                                    -
; -                                                  -
; - RRRRRRRRGGGGGGGGBBBBBBBB -> RRRRRGGGGGXBBBBB     -
; ----------------------------------------------------

                lea     bild,A0
                lea     $FFFFA200,A2
                movea.l scr,A1
                move.l  #31999,D1
loop:           move.l  -1(A0),4(A2)    ; CPU->DSP via Host-Interface (24-Bit)
                move.w  6(A2),(A1)+     ; DSP->CPU via Host-Interface (16-Bit)
                nop
                move.l  2(A0),4(A2)     ; CPU->DSP via Host-Interface (24-Bit)
                move.w  6(A2),(A1)+     ; DSP->CPU via Host-Interface (16-Bit)
                addq.l  #6,A0
                dbra    D1,loop

tastatur:       move.w  #7,-(SP)
                trap    #1
                addq.l  #2,SP

                cmpi.b  #27,D0          ; ESC to leave Program
                beq     raus

                move.w  #79,-(SP)
                trap    #1
                addq.l  #2,SP
                tst.b   D0
                bpl     bild_loop

                bra     erstes_bild

raus:           move.l  ssp,-(SP)
                move.w  #super,-(SP)
                trap    #1
                addq.l  #6,SP

                clr.w   -(SP)
                trap    #1

                DATA
suchmaske:      DC.B '*.RAW',0
bin_file:       IBYTES '24BIT.BIN'
                EVEN
                BSS
scr:            DS.L 1
ssp:            DS.L 1
dta:            DS.B 30
dateiname:      DS.B 14
                EVEN
bild:           DS.L 50000
                END
