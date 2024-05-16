
putpixel
; Culls pixels outside the x 0-319 and y 0-199 range
; In: d0 - x
;     d1 - y
;			d2 - color
;     a0 - address to screen
; Uses: a0-a4, d0-d2
; Destroys: nothing
	cmp.l #0,d0
	blt .culled
	cmp.l #320,d0
	bge .culled
	cmp.l #0,d1
	blt .culled
	cmp.l #200,d1
	bge .culled

	move.l a0,-(sp)
	move.l a1,-(sp)
	move.l a2,-(sp)
	move.l a3,-(sp)
	move.l a4,-(sp)
	move.l d0,-(sp)
	move.l d1,-(sp)
	move.l d2,-(sp)

	move.l a0,a3
	lea pixelxtable,a1		; bit shapes
	lea pixelxtable2,a2		; x offset
	;--first, y
	lsl.l #5,d1
	add.l d1,a0
	lsl.l #2,d1
	add.l d1,a0 ; and that takes care of y

	;--then, the mask
	move.l d0,d1
	and.l #$f,d1
	add.l d1,a1
	add.l d1,a1
	move.w (a1),d1 ; and now the mask is in d1

	;--finally, the x
	lsl.l #2,d0
	add.l d0,a2
	move.l (a2),d0
	add.l d0,a0

	;-- a0 finally points at the first bitplane
	move.l d2,d0
	and.l #$f,d0 ;mask out illegal colors, because they will cause bad jumps
	move.w d1,d2 ; copy positive mask to d2
	eor.w #$ffff,d2 ; negate it... now d1 is positive mask, d2 is negative
	add.l d0,d0
	add.l d0,d0

	move.l a0,a4 ; offset address
	sub.l a3,a4
	move.l a4,putpixeloffsetaddress
	jsr .pixeljumptable(pc,d0.l)

	move.l (sp)+,d2
	move.l (sp)+,d1
	move.l (sp)+,d0
	move.l (sp)+,a4
	move.l (sp)+,a3
	move.l (sp)+,a2
	move.l (sp)+,a1
	move.l (sp)+,a0

.culled
	rts

.pixeljumptable
	bra.w .color00
	bra.w .color01
	bra.w .color02
	bra.w .color03
	bra.w .color04
	bra.w .color05
	bra.w .color06
	bra.w .color07
	bra.w .color08
	bra.w .color09
	bra.w .color10
	bra.w .color11
	bra.w .color12
	bra.w .color13
	bra.w .color14
	bra.w .color15

.color00
	and.w d2,(a0)+
	and.w d2,(a0)+
	and.w d2,(a0)+
	and.w d2,(a0)
	rts
.color01
	or.w d1,(a0)+
	and.w d2,(a0)+
	and.w d2,(a0)+
	and.w d2,(a0)
	rts
.color02
	and.w d2,(a0)+
	or.w d1,(a0)+
	and.w d2,(a0)+
	and.w d2,(a0)
	rts
.color03
	or.w d1,(a0)+
	or.w d1,(a0)+
	and.w d2,(a0)+
	and.w d2,(a0)
	rts
.color04
	and.w d2,(a0)+
	and.w d2,(a0)+
	or.w d1,(a0)+
	and.w d2,(a0)
	rts
.color05
	or.w d1,(a0)+
	and.w d2,(a0)+
	or.w d1,(a0)+
	and.w d2,(a0)
	rts
.color06
	and.w d2,(a0)+
	or.w d1,(a0)+
	or.w d1,(a0)+
	and.w d2,(a0)
	rts
.color07
	or.w d1,(a0)+
	or.w d1,(a0)+
	or.w d1,(a0)+
	and.w d2,(a0)
	rts
.color08
	and.w d2,(a0)+
	and.w d2,(a0)+
	and.w d2,(a0)+
	or.w d1,(a0)
	rts
.color09
	or.w d1,(a0)+
	and.w d2,(a0)+
	and.w d2,(a0)+
	or.w d1,(a0)
	rts
.color10
	and.w d2,(a0)+
	or.w d1,(a0)+
	and.w d2,(a0)+
	or.w d1,(a0)
	rts
.color11
	or.w d1,(a0)+
	or.w d1,(a0)+
	and.w d2,(a0)+
	or.w d1,(a0)
	rts
.color12
	and.w d2,(a0)+
	and.w d2,(a0)+
	or.w d1,(a0)+
	or.w d1,(a0)
	rts
.color13
	or.w d1,(a0)+
	and.w d2,(a0)+
	or.w d1,(a0)+
	or.w d1,(a0)
	rts
.color14
	and.w d2,(a0)+
	or.w d1,(a0)+
	or.w d1,(a0)+
	or.w d1,(a0)
	rts
.color15
	or.w d1,(a0)+
	or.w d1,(a0)+
	or.w d1,(a0)+
	or.w d1,(a0)
	rts


putpixeldontdarken
; Culls pixels outside the x 0-319 and y 0-199 range
; In: d0 - x
;     d1 - y
;			d2 - color
;     a0 - address to screen
; Uses: a0-a2, d0-d2
; Destroys: a1-a2
	cmp.l #0,d0
	blt .culled
	cmp.l #320,d0
	bge .culled
	cmp.l #0,d1
	blt .culled
	cmp.l #200,d1
	bge .culled

	move.l a0,-(sp)
	move.l d0,-(sp)
	move.l d1,-(sp)
	move.l d2,-(sp)
	move.l d3,-(sp)
	move.l d4,-(sp)

	lea pixelxtable,a1		; bit shapes
	lea pixelxtable2,a2		; x offset
	;--first, y
	lsl.l #5,d1
	add.l d1,a0
	lsl.l #2,d1
	add.l d1,a0 ; and that takes care of y

	;--then, the mask
	move.l d0,d1
	and.l #$f,d1
	add.l d1,a1
	add.l d1,a1
	move.w (a1),d1 ; and now the mask is in d1

	;--finally, the x
	lsl.l #2,d0
	add.l d0,a2
	move.l (a2),d0
	add.l d0,a0

	;-- a0 finally points at the first bitplane

	; Now read the existing pixel, and if it is brighter, dont set the new one

	move.l #0,d4
	move.w (a0)+,d3
	and.w d1,d3
	cmp.w #0,d3
	beq .no1
	add.b #1,d4
.no1
	move.w (a0)+,d3
	and.w d1,d3
	cmp.w #0,d3
	beq .no2
	add.b #2,d4
.no2
	move.w (a0)+,d3
	and.w d1,d3
	cmp.w #0,d3
	beq .no3
	add.b #4,d4
.no3
	move.w (a0),d3
	and.w d1,d3
	cmp.w #0,d3
	beq .no4
	add.b #8,d4
.no4

	cmp.b d4,d2
	blt	.dontsetpixel

	sub.l #6,a0

	move.l d2,d0
	and.l #$f,d0 ;mask out illegal colors, because they will cause bad jumps
	move.w d1,d2 ; copy positive mask to d2
	eor.w #$ffff,d2 ; negate it... now d1 is positive mask, d2 is negative
	add.l d0,d0
	add.l d0,d0
	jsr .pixeljumptable(pc,d0.l)
.dontsetpixel
	move.l (sp)+,d4
	move.l (sp)+,d3
	move.l (sp)+,d2
	move.l (sp)+,d1
	move.l (sp)+,d0
	move.l (sp)+,a0
.culled
	rts

.pixeljumptable
	bra.w .color00
	bra.w .color01
	bra.w .color02
	bra.w .color03
	bra.w .color04
	bra.w .color05
	bra.w .color06
	bra.w .color07
	bra.w .color08
	bra.w .color09
	bra.w .color10
	bra.w .color11
	bra.w .color12
	bra.w .color13
	bra.w .color14
	bra.w .color15

.color00
	and.w d2,(a0)+
	and.w d2,(a0)+
	and.w d2,(a0)+
	and.w d2,(a0)
	rts
.color01
	or.w d1,(a0)+
	and.w d2,(a0)+
	and.w d2,(a0)+
	and.w d2,(a0)
	rts
.color02
	and.w d2,(a0)+
	or.w d1,(a0)+
	and.w d2,(a0)+
	and.w d2,(a0)
	rts
.color03
	or.w d1,(a0)+
	or.w d1,(a0)+
	and.w d2,(a0)+
	and.w d2,(a0)
	rts
.color04
	and.w d2,(a0)+
	and.w d2,(a0)+
	or.w d1,(a0)+
	and.w d2,(a0)
	rts
.color05
	or.w d1,(a0)+
	and.w d2,(a0)+
	or.w d1,(a0)+
	and.w d2,(a0)
	rts
.color06
	and.w d2,(a0)+
	or.w d1,(a0)+
	or.w d1,(a0)+
	and.w d2,(a0)
	rts
.color07
	or.w d1,(a0)+
	or.w d1,(a0)+
	or.w d1,(a0)+
	and.w d2,(a0)
	rts
.color08
	and.w d2,(a0)+
	and.w d2,(a0)+
	and.w d2,(a0)+
	or.w d1,(a0)
	rts
.color09
	or.w d1,(a0)+
	and.w d2,(a0)+
	and.w d2,(a0)+
	or.w d1,(a0)
	rts
.color10
	and.w d2,(a0)+
	or.w d1,(a0)+
	and.w d2,(a0)+
	or.w d1,(a0)
	rts
.color11
	or.w d1,(a0)+
	or.w d1,(a0)+
	and.w d2,(a0)+
	or.w d1,(a0)
	rts
.color12
	and.w d2,(a0)+
	and.w d2,(a0)+
	or.w d1,(a0)+
	or.w d1,(a0)
	rts
.color13
	or.w d1,(a0)+
	and.w d2,(a0)+
	or.w d1,(a0)+
	or.w d1,(a0)
	rts
.color14
	and.w d2,(a0)+
	or.w d1,(a0)+
	or.w d1,(a0)+
	or.w d1,(a0)
	rts
.color15
	or.w d1,(a0)+
	or.w d1,(a0)+
	or.w d1,(a0)+
	or.w d1,(a0)
	rts

getpixel:
; In: d0 - x
;     d1 - y
;     a0 - address of screen
; Out: d2 - pixelcolor
; Destroys: nothing
	move.l d4,-(sp)
	move.l a0,-(sp)
	move.l a1,-(sp)
	move.l a2,-(sp)
	move.l d0,-(sp)
	move.l d1,-(sp)
	move.l d2,-(sp)
	move.l d3,-(sp)
	lea pixelxtable,a1		; bit shapes
	lea pixelxtable2,a2		; x offset
	;--first, y
	lsl.l #5,d1
	add.l d1,a0
	lsl.l #2,d1
	add.l d1,a0 ; and that takes care of y

	;--then, the mask
	move.l d0,d1
	and.l #$f,d1
	add.l d1,a1
	add.l d1,a1
	move.w (a1),d1 ; and now the mask is in d1

	;--finally, the x
	lsl.l #2,d0
	add.l d0,a2
	move.l (a2),d0
	add.l d0,a0

	;-- a0 finally points at the first bitplane

	move.l #0,d4
	move.w (a0)+,d3
	and.w d1,d3
	cmp.w #0,d3
	beq .no1
	add.b #1,d4
.no1
	move.w (a0)+,d3
	and.w d1,d3
	cmp.w #0,d3
	beq .no2
	add.b #2,d4
.no2
	move.w (a0)+,d3
	and.w d1,d3
	cmp.w #0,d3
	beq .no3
	add.b #4,d4
.no3
	move.w (a0),d3
	and.w d1,d3
	cmp.w #0,d3
	beq .no4
	add.b #8,d4
.no4

	move.l (sp)+,d3
	move.l (sp)+,d2
	move.l (sp)+,d1
	move.l (sp)+,d0
	move.l (sp)+,a2
	move.l (sp)+,a1
	move.l (sp)+,a0
	move.l d4,d2
	move.l (sp)+,d4
	rts

pixelcolor	dc.l 0

pixelxtable:
	dc.w %1000000000000000
	dc.w %0100000000000000
	dc.w %0010000000000000
	dc.w %0001000000000000
	dc.w %0000100000000000
	dc.w %0000010000000000
	dc.w %0000001000000000
	dc.w %0000000100000000
	dc.w %0000000010000000
	dc.w %0000000001000000
	dc.w %0000000000100000
	dc.w %0000000000010000
	dc.w %0000000000001000
	dc.w %0000000000000100
	dc.w %0000000000000010
	dc.w %0000000000000001

pixelxtable2:
	rept 16
	dc.l 0
	endr
	rept 16
	dc.l 8
	endr
	rept 16
	dc.l 16
	endr
	rept 16
	dc.l 24
	endr
	rept 16
	dc.l 32
	endr
	rept 16
	dc.l 40
	endr
	rept 16
	dc.l 48
	endr
	rept 16
	dc.l 56
	endr
	rept 16
	dc.l 64
	endr
	rept 16
	dc.l 72
	endr
	rept 16
	dc.l 80
	endr
	rept 16
	dc.l 88
	endr
	rept 16
	dc.l 96
	endr
	rept 16
	dc.l 104
	endr
	rept 16
	dc.l 112
	endr
	rept 16
	dc.l 120
	endr
	rept 16
	dc.l 128
	endr
	rept 16
	dc.l 136
	endr
	rept 16
	dc.l 144
	endr
	rept 16
	dc.l 152
	endr

putpixeloffsetaddress
	dc.l 0