;******************************************************************************
;*    CPU_UP - Demonstrations-Programm zum vertikalen Scrollen mit der CPU    *
;******************************************************************************
            movea.l   4(sp),a5        ;Bildschirm-Adresse vom Stack holen
            move.w    #399,d0         ;400 mal um 1 Pixel nach oben schieben
page_loop:  movea.l   a5,a6           ;Adresse restaurieren
            move.w    #399,d1         ;400 Zeilen 1 Pixel nach oben schieben
line_loop:  movem.l   80(a6),d2-a3    ;1. H„lfte einer Zeile laden
            movem.l   d2-a3,(a6)      ;1. H„lfte einer Zeile schreiben
            lea       40(a6),a6       ;Adresse 1/2 Zeile (40 Byte) weitersetzen
            movem.l   80(a6),d2-a3    ;2. H„lfte einer Zeile laden
            movem.l   d2-a3,(a6)      ;2. H„lfte einer Zeile schreiben
            lea       40(a6),a6       ;Adresse 1/2 Zeile (40 Byte) weitersetzen
            dbra      d1,line_loop    ;n„chste Zeile
            dbra      d0,page_loop
            rts
;------------------------------------------------------------------------------
            END

