*initialise interrupt
basepal         EQU $FFFF8242   ;2. Palettenregister
setv            EQU 5
xbtimer         EQU 31
bios            EQU 13
xbios           EQU 14

start:
                move.l  #-1,-(SP)       ;alten Vector mit Betriebssystemfunktion
                move.w  #28,-(SP)
                move.w  #setv,-(SP)     ;
                trap    #13             ;Bios 5
                addq.l  #8,SP
                lea     oldvec(PC),A1
                move.l  D0,(A1)         ;alten Vector retten
                pea     nvbl(PC)        ;neue VBL Routine
                move.w  #28,-(SP)       ;Installieren
                move.w  #setv,-(SP)
                trap    #bios
                addq.l  #8,SP
                pea     interupt(PC)    ;eigenen Vector Installieren
                move.w  #170,-(SP)      ;Zeile 170
                move.w  #8,-(SP)        ;EVENT COUNT
                move.w  #1,-(SP)        ;TIMER B
                move.w  #xbtimer,-(SP)
                trap    #xbios
                adda.l  #12,SP
                lea     palette1(PC),A0 ;Adresse der zwei Palettenpuffer
                lea     palette2(PC),A1 ;Palettenpuffer zurÅckgeben
                rts
interupt:
                pea     (A0)
                pea     (A1)
                lea     basepal.w,A1
                lea     palette2(PC),A0
loop:           cmpi.b  #156,$FFFFFA21.w ;warte auf richtige Zeile
                bgt.s   loop
                REPT 7          ; palette fÅr den unteren Teil kopieren
                move.l  (A0)+,(A1)+     ;palette wird ab Zeile 180 gesetzt
                ENDR
                movea.l (SP)+,A1
                movea.l (SP)+,A0
                move.b  #0,$FFFFFA1B.w  ; Timer B aus
                rte

****            neue VBL Routine

nvbl:
                pea     (A0)
                pea     (A1)
                lea     basepal.w,A1
                lea     palette1(PC),A0
                REPT 7
                move.l  (A0)+,(A1)+     ;Palette fÅr oberen Teil kopieren
                ENDR
                movea.l (SP)+,A1
                movea.l (SP)+,A0
                move.b  #170,$FFFFFA21.w ;Zeile 170
                move.b  #8,$FFFFFA1B.w  ; EVENT COUNT
                move.l  oldvec(PC),-(SP) ;springe alte Routine an
                rts

********* Hier folgen die zu wechselnden Paletten ********

palette1:       DC.W $0223,$0334,$0445,$0222,$0333,$0444,$0555
                DC.W $0666,$40,$0150,$0750,$0760,$0260,$0775
palette2:       DC.W $0200,$0300,$0301,$0402,$0503,$0604,$0705
                DC.W $0606,$0507,$0417,$0327,$0237,$0147,$0157
oldvec:         DC.L $12345678

                END
