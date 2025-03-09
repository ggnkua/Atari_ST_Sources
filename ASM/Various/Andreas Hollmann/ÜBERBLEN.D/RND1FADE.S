;******************************************************************************
;*        RND1FADE - Pixelweises šberblenden zwischen zwei Bildschirmen       *
;*        mit Pseudo-Zufallszahlen                 (c) Andreas Hollmann       *
;******************************************************************************
            movea.l   4(sp),a0        ;src_adr holen
            movea.l   8(sp),a1        ;dst_adr holen
;------------------------------------------------------------------------------
            moveq     #1,d0           ;Schiebe-Register mit Startwert 1 laden
            move.l    #255999,d3      ;fr Vergleich obere Grenze (schneller !)
            moveq     #0,d4           ;fr 1. Abgriff (schneller !)
            moveq     #7,d5           ;fr 2. Abgriff (schneller !)
            move.w    #17,d6          ;fr linkes Bit (schneller !)
            move.l    #255999,d7      ;soviele Bits werden kopiert
;------------------------------------------------------------------------------
;Erzeugung von Pseudo-Zufallszahlen mit einem rckgekoppelten Schieberegister:
;
calc_rnd:   btst      d4,d0           ;1. Abgriff (Bit 0)
            beq.s     bits0x          ;falls Bit=0 ->

bits1x:     btst      d5,d0           ;2. Abgriff (Bit 1)
            beq.s     bits10
bits11:     lsr.l     #1,d0           ;kein Bit setzen, weil 1 eor 1 = 0 ist
            bra.s     chk_rnd
bits10:     lsr.l     #1,d0
            bset      d6,d0           ;weil 1 eor 0 = 1 ist
            bra.s     chk_rnd

bits0x:     btst      d5,d0           ;2. Abgriff (Bit 1)
            beq.s     bits00
bits01:     lsr.l     #1,d0
            bset      d6,d0           ;weil 0 eor 1 = 1 ist
            bra.s     chk_rnd
bits00:     lsr.l     #1,d0           ;kein Bit setzen, weil 0 eor 0 = 0 ist
;------------------------------------------------------------------------------
chk_rnd:    cmp.l     d3,d0           ;max. 255999 ! (in d3 steht 255999)
            bhi.s     calc_rnd        ;sonst neue Zufallszahl...

            move.b    d0,d1           ;Zufallszahl in d1 kopieren
            and.b     #7,d1           ;Pixel berechnen
            move.l    d0,d2           ;Zufallszahl in d2 kopieren
            asr.l     #3,d2           ;Byte berechnen

            btst      d1,0(a0,d2.w)   ;src_adr-Bit abfragen
            beq.s     clr_bit
            bset      d1,0(a1,d2.w)   ;dst_adr-Bit setzen
            bra.s     dec_count
clr_bit:    bclr      d1,0(a1,d2.w)   ;dst_adr-Bit l”schen

dec_count:  subq.l    #1,d7           ;Pixel-Z„hler dekrementieren
            bpl.s     calc_rnd
;------------------------------------------------------------------------------
            rts
            END
