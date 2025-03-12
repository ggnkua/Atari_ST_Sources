;******************************************************************************
;*        RND8FADE - Byteweises šberblenden zwischen zwei Bildschirmen        *
;*        mit Pseudo-Zufallszahlen              (c) - Andreas Hollmann        *
;******************************************************************************
            movea.l   4(sp),a0        ;src_adr holen
            movea.l   8(sp),a1        ;dst_adr holen

            move.w    #31999,d7       ;soviele Bytes werden kopiert
            moveq     #1,d0           ;Schiebe-Register mit Startwert 1 laden
;------------------------------------------------------------------------------
;Erzeugung von Pseudo-Zufallszahlen mit einem rckgekoppelten Schieberegister:
;
calc_rnd:   btst      #0,d0           ;1. Abgriff (Bit 0)
            beq.s     bits0x          ;falls Bit=0 ->

bits1x:     btst      #1,d0           ;2. Abgriff (Bit 1)
            beq.s     bits10
bits11:     lsr.l     #1,d0           ;kein Bit setzen, weil 1 eor 1 = 0 ist
            bra.s     chk_rnd
bits10:     lsr.l     #1,d0
            bset      #14,d0          ;weil 1 eor 0 = 1 ist
            bra.s     chk_rnd

bits0x:     btst      #1,d0           ;2. Abgriff (Bit 1)
            beq.s     bits00
bits01:     lsr.l     #1,d0
            bset      #14,d0          ;weil 0 eor 1 = 1 ist
            bra.s     chk_rnd
bits00:     lsr.l     #1,d0           ;kein Bit setzen, weil 0 eor 0 = 0 ist
;------------------------------------------------------------------------------
chk_rnd:    cmpi.w    #31999,d0       ;Zufallszahl nur von 0-31999 !
            bhi.s     calc_rnd        ;sonst neue Zufallszahl...

            move.w    #20,d6          ;Verz”gerungswert
delay:      dbra      d6,delay        ;Verz”gerungs-Schleife

            move.b    0(a0,d0.w),0(a1,d0.w) ;1 Byte kopieren
            dbra      d7,calc_rnd
;------------------------------------------------------------------------------
prg_end:    rts
            END
