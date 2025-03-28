;******************************************************************************
;*   CPU_RT - Demonstrations-Programm zum horizontalen Scrollen mit der CPU   *
;******************************************************************************
            movea.l   4(sp),a5        ;Bildschirm-Adresse vom Stack holen
            move.w    #639,d0         ;640mal um 1 Px nach rechts schieben
page_loop:  movea.l   a5,a6           ;Adresse restaurieren
            move.w    #399,d1         ;400 Zeilen 1 Px nach rechts schieben
col_loop:   move      #0,ccr          ;X-Flag l”schen
            REPT 40                   ;'roxr.w  (a6)+' 40mal wiederholen
            roxr.w    (a6)+           ;1 Wort um 1 Bit nach rechts schieben
            ENDR
            dbra      d1,col_loop     ;n„chste Spalte
            dbra      d0,page_loop
            rts
;------------------------------------------------------------------------------
            END

