;******************************************************************************
;*       ADD1FADE - pixelweises šberblenden zwischen zwei Bildschirmen        *
;*       mit Konstanten-Addition                  (c) Andreas Hollmann        *
;******************************************************************************
parameter:  movea.l   4(sp),a0        ;src_Adr holen
            movea.l   8(sp),a1        ;dst_Adr holen
            move.l    12(sp),d1       ;Add-Wert holen
;------------------------------------------------------------------------------
            move.l    #255999,d0      ;soviele Pixel (+1) mssen kopiert werden
            moveq     #0,d2           ;Z„hler ist am Anfang 0
            move.l    #255999,d5      ;fr Vergleich (schneller !)
            moveq     #7,d6           ;fr AND-Bit (schneller !)
            move.l    #256000,d7      ;fr SUB (schneller !)
;------------------------------------------------------------------------------
px_loop:    move.l    d2,d3           ;Z„hler in d3 kopieren
            asr.l     #3,d3           ;d3/8 = Byte-Adr
            move.b    d2,d4           ;Z„hler in d4 kopieren
            and.b     d6,d4           ;Pixel berechnen
            eor.b     d6,d4           ;Bit berechnen
            btst      d4,0(a0,d3.w)   ;entsprechendes Bit testen
            bne.s     bit_1           ;S_Bit ist 1 => verzweigen
            bclr      d4,0(a1,d3.w)   ;S_Bit ist 0 => D_Bit l”schen
            bra.s     inc_count       ;->

bit_1:      bset      d4,0(a1,d3.w)   ;D_Bit setzen

inc_count:  add.l     d1,d2           ;zum Z„hler Add-Wert addieren
            cmp.l     d5,d2           ;Z„hler mit 255999 vergleichen
            bhi.s     dec_count       ;Z„hler gr”žer ->
            bra.s     loop_end        ;zum Schleifenende

dec_count:  sub.l     d7,d2           ;Z„hler um 256000 verringern
loop_end:   subq.l    #1,d0           ;1 Pixel kopiert
            bpl.s     px_loop
;------------------------------------------------------------------------------
            rts
            END

