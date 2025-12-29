.IMPORT _sscreen

.EXPORT set_maus
.EXPORT set_button
.EXPORT set_point
.EXPORT clr_point
.EXPORT tst_point

.MODULE set_maus
			   movem.w d0/d1,-(sp)
            move.l  a2,-(sp)
            .DC.w $a000
            movea.l (sp)+,a2
            movem.w (sp)+,d0/d1
            move.w  d0,-$25a(a0)   ;X-Koordinate
            move.w  d1,-$258(a0)   ;Y-Koordinate
            move.b  #-1,-$154(a0)  ;beim n„chsten VBlank neu zeichnen
            rts     
.ENDMOD

*******************************************************
.MODULE set_button
            move.w  d0,button
            movem.l d3/a2/a3,-(sp)
            .DC.w $a000
            movem.l (sp)+,d3/a2/a3
            move.w  button,-$254(a0)    ; Maus-Button
            rts     
button:     .DC.w 0
.ENDMOD

*******************************************************
.MODULE set_point
            bsr     popel
            bset    d1,0(a0,d2.w)  ; Bit setzen
            rts     

clr_point:  bsr     popel
            bclr    d1,0(a0,d2.w)
            rts     

tst_point:  bsr     popel
            btst    d1,0(a0,d2.w)
            beq     noset
            moveq   #-1,d0
            rts     
noset:      sub.l   d0,d0
            rts     

popel:      movea.l _sscreen,a0    ; Screen Startadresse
            move.w  d1,d2          ; y*80
            lsl.w   #2,d2
            add.w   d1,d2
            lsl.w   #4,d2
            adda.w  d2,a0          ; X-Offset zur Startadresse
            move.w  d0,d2
            lsr.w   #3,d2
            move.w  #7,d1          ; Bitnummer = 7-(x%8)
            andi.w  #7,d0          ; Rest der Division durch 8
            sub.w   d0,d1          ; Bitnummer berechnen
            rts     
.ENDMOD
