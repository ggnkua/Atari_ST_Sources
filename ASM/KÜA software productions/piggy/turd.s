	;opt x+,p+

debug=0

	ifne debug

	clr.w -(sp)
	move.l #-1,-(sp)
	move.l (sp),-(sp)
	move.w #5,-(sp)
	trap #14
	lea 12(a0),a0
	
	pea code(pc)
	move.w #$26,-(sp)
	trap #14

	move.w #1,-(sp)
	move.l #-1,-(sp)
	move.l (sp),-(sp)
	move.w #5,-(sp)
	trap #14
	lea 12(a0),a0

	clr.w -(sp)
	trap #1
	endc

code
	ifne debug
	movem.l $ffff8240.w,d0-7
	movem.l d0-7,-(sp)
	endc
	
	movem.l pal(pc),d0-3
	movem.l d0-d3,$ffff8240.w
	
	move.w #2,-(sp)
	trap #14
	addq.l #2,sp

	move.l d0,a6
	lea 89*160+72(a6),a6
	lea pig1(pc),a5
	moveq #1,d6
	moveq #20,d7
	pea message(pc)

drawcrap
	movem.w (a5)+,d0-d5
	movem.w d0-2,(a6)
	movem.w d3-5,8(a6)
	lea 160(a6),a6
	dbra d7,drawcrap

	move.w #9,-(sp)
	trap #1
	move.w #1,-(sp)
	trap #1
	addq.l #8,sp
	pea message2(pc)

	lea -160*18(a6),a6
	moveq #6,d7

	dbra d6,drawcrap
	addq.l #4,sp

	ifne debug
	movem.l (sp)+,d0-3
	movem.l d0-3,$ffff8240.w
	endc

	rts



; Palette
pal
 DC.W $046,$333,$000,$432,$730,$543,$666,$777
;DC.W $777,$777,$777,$777,$777,$777,$777,$777

; w32 h44 p3
pig1
 DC.W $0,$6,$0,$0,$6000,$0
 dc.w $6,$9,$6,$6000,$9000,$6000
 dc.w $E,$19,$6,$E000,$9000,$6000
 dc.w $6,$1F,$F,$6000,$F800,$F000
 DC.W $F,$1FFF,$1F,$F000,$FC00,$F800
 dc.w $1FFF,$301F,$FFF,$F800,$FC00,$F800
 dc.w $3FFC,$401F,$3FFC,$C800,$FC00,$C800
 dc.w $7FFC,$C01F,$3FFC,$C000,$FFE0,$C800
 DC.W $7FEF,$801F,$7FFF,$E000,$E010,$FFE0
 dc.w $7FF6,$800F,$7FFF,$4000,$C008,$FFF0
 dc.w $7FFF,$8000,$7FFF,$C440,$CC8,$F330
 dc.w $7FFF,$8000,$7FFF,$C440,$CC8,$F330
 DC.W $7FFF,$8000,$7FFF,$C000,$8,$FFF0
 dc.w $7FFF,$C000,$3FFF,$E000,$10,$FFE0
 dc.w $7FFF,$8000,$3FFF,$FFC0,$FE0,$F000
 dc.w $BFFF,$4000,$3FFF,$FFC0,$FE0,$F000
 DC.W $3C3E,$43C1,$383C,$480,$FFC0,$480
 dc.w $3BBD,$47C3,$3838,$C000,$EFC0,$480
 dc.w $3BBB,$47C7,$3838,$8000,$C480,$0
; dc.w $3BBB,$47C7,$3838,$8000,$C000,$0
 DC.W $3BBB,$47C7,$3838,$8000,$C000,$0
 dc.w $3BBB,$5555,$0,$8000,$4000,$0
pig2
; dc.w $0,$6,$0,$0,$6000,$0
; dc.w $6,$9,$6,$6000,$9000,$6000
; DC.W $E,$19,$6,$E000,$9000,$6000
 dc.w $F,$18,$7,$F000,$1800,$E000
 dc.w $1F,$1FF0,$F,$F800,$C00,$F000
 dc.w $1FFF,$3000,$FFF,$F800,$400,$F800
 DC.W $3FFF,$4009,$3FF6,$F800,$4C00,$B000
 dc.w $7FFF,$C006,$3FF9,$F800,$3FE0,$C000
 dc.w $7FFF,$8000,$7FFF,$E000,$10,$FFE0
 dc.w $7FFF,$8000,$7FFF,$C000,$8,$FFF0
; DC.W $7FFF,$8000,$7FFF,$C440,$CC8,$F330
; dc.w $7FFF,$8000,$7FFF,$C440,$CC8,$F330
; dc.w $7FFF,$8000,$7FFF,$C000,$8,$FFF0
; dc.w $7FFF,$C000,$3FFF,$E000,$10,$FFE0
; DC.W $7FFF,$8000,$3FFF,$FFC0,$FE0,$F000
; dc.w $BFFF,$4000,$3FFF,$FFC0,$FE0,$F000
; dc.w $3C3E,$43C1,$383C,$480,$FFC0,$480
; dc.w $3BBD,$47C3,$3838,$C000,$EFC0,$480
; DC.W $3BBB,$47C7,$3838,$8000,$C480,$0
; dc.w $3BBB,$47C7,$3838,$8000,$C000,$0
; dc.w $3BBB,$47C7,$3838,$8000,$C000,$0
; dc.w $3BBB,$5555,$0,$8000,$4000,$0
 
message:
	dc.b    'Press a key',0
message2:
	dc.b 13,'You lose :P',0
endcode
