DENTRIES cdrawtext wdrawtext4x

| ( screen scrwidth string color ) - draw string to byte-organized screen
CODE_XT cdrawtext
	move.l  d4,d1 ; POPD  | d1: color
	move.l  d4,a0 ; POPD  | a0: null-terminated string
	move.l  d4,d3 ; POPD  | d3: screen width in bytes
	move.l  d4,a1         | a1: screen address
	lea     _font_8x16,a2 | a2: font
	movem.l a3-a5,-(sp)
1:	moveq   #0,d0
	move.b  (a0)+,d0
	beq.s   2f            | check null termination
	bsr     _cdraw_glyph
	addq.l  #8,a1
	bra     1b
2:
	movem.l (sp)+,a3-a5
	POPD
	NEXT

| d0: character
| d1: color
| d3: screen width in bytes
| a1: destination address
| a2: font
_cdraw_glyph:
	lsl.l #4,d0
	lea   (a2,d0.w),a3      | a3: first byte of glyph
	move.l a1,a4            | a4: destination address on screen
	moveq.l #16-1,d7        | d7: y-loop count
2:
	move.b (a3)+,d2         | d2.b: bitmask of current glyph line

	.REP 8                  | draw one line of the glyph
	rol.b #1,d2             | set color of bit is pushed out
	bcc.s 1f
	move.b d1,(a4)
1:	addq.l #1,a4
	.ENDR

	lea    -8(a4,d3.w),a4   | a4: start of next line on screen
	dbf    d7,2b
	rts


| ( monoscreen scrwidth string ) - draw white string to monochrome screen
CODE_XT wdrawtext4x
	move.l  d4,a0 ; POPD  | a0: null-terminated string
	move.l  d4,d3 ; POPD  | d3: screen width in bytes
	move.l  d4,a1         | a1: screen address
	lea     _font_8x16,a2 | a2: font
	movem.l a3-a5,-(sp)
1:	moveq   #0,d0
	move.b  (a0)+,d0
	beq.s   2f            | check null termination
	bsr     _wdraw4x_glyph
	addq.l  #4,a1
	bra     1b
2:
	movem.l (sp)+,a3-a5
	POPD
	NEXT

| d0: character
| d3: screen width in bytes
| a1: destination address
| a2: font
_wdraw4x_glyph:
	lsl.l #4,d0
	lea   (a2,d0.w),a3      | a3: first byte of glyph
	move.l a1,a4            | a4: destination address on screen
	moveq.l #16-1,d7        | d7: y-loop count
2:
	move.b (a3)+,d2         | d2.b: bitmask of current glyph line

	moveq.l #-1,d4          | d4.l: will contain 4x spread bits
	.REP 8
	rol.l #4,d4
	rol.b #1,d2             | evaluate bit that is pushed out
	bcc.s 1f
	and.b  #0xf,d4          | clear lowest four bits
1:
	.ENDR
	ror.l #4,d4

	.REP 4                  | write same pattern at four lines
	and.l d4,(a4)
	add.l  d3,a4            | next screen line
	.ENDR

	dbf    d7,2b
	rts

.DATA

_font_8x16:
	.incbin "../lib/font_8x16.dat"

.TEXT

| vim: set ts=16:
