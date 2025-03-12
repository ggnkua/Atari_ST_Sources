;******************************************************************************
;*       ADD8FADE - Byteweises šberblenden zwischen zwei Bildschirmen         *
;*       mit Konstanten-Addition                 von Andreas Hollmann         *
;*			 (c) 1992 MAXON Computer GmbH																					*
;******************************************************************************
GLOBL		add8fade;

add8fade:   movea.l   4(sp),a1        ;src_adr holen
            movea.l   8(sp),a0        ;dst_adr holen
            move.l    12(sp),d1       ;Add-Wert holen
;------------------------------------------------------------------------------
            move.w    #10,d7          ;Verz”gerungs-Wert
            move.l    #31999,d0       ;Schleifenz„hler
            moveq     #0,d2           ;Z„hler ist am Anfang 0
;------------------------------------------------------------------------------
copy_loop:  move.b    0(a1,d2.w),0(a0,d2.w) ;1 Byte kopieren
            move.w    #20,d7          ;Verz”gerungswert restaurieren
delay:      dbra      d7,delay        ;Brems-Schleife

            add.l     d1,d2           ;zum Z„hler Add-Wert addieren
            cmpi.l    #31999,d2
            bgt.s     sub_count       ;falls Z„hler > 31999, ->
            bra.s     loop_end        ;zum Schleifenende

sub_count:  sub.l     #32000,d2       ;Z„hler um 32000 verringern
loop_end:   dbra      d0,copy_loop
;------------------------------------------------------------------------------
            rts
            END

