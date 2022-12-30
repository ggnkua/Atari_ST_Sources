;;; PORTRAIT OF LIBERTY
;;; Original by John Jainschigg for Family Computing, Jul 1986
;;; Atari ST port by Michael Martin, Mar 2021

;;; A-Line equates
Init	= $A000
ALine	= $A003
SeedFill= $A00F

;;; A-Line variables
CUR_WORK= -$1D0
INTIN	= $08
PTSIN	= $0C
COLBIT0 = $18
COLBIT1 = $1A
COLBIT2 = $1C
COLBIT3 = $1E
LSTLIN	= $20
LNMASK	= $22
WMODE	= $24
X1	= $26
PATPTR	= $2E
PATMSK	= $32
MFILL	= $34
CLIP	= $36
MINCL	= $38
MAXCL	= $3C
SDABORT	= $76

	move.l	#cls,a3
	jsr	outstr

	move.w	#4,-(sp)		; GetRez() call
	trap	#14			; in XBIOS
	addq.l	#2,sp
	move.w	d0,mode			; Save it
	move.w	d0,d3

	dc.w	Init
	move.l	#vwork,CUR_WORK(a0)	; Fake VDI workspace in a6
	move.l	#ff_loc,PTSIN(a0)	; Flood fill array
	move.l	#ff_col,INTIN(a0)	; Color mode flood fill
	cmp.w	#2,d3			; Are we in hi-res mode?
	beq.s	black_ink
	move.l	#1,COLBIT0(a0)		; Color register 2: green
	bra.s	inked
black_ink:
	move.l	#$10000,COLBIT0(a0)	; Color register 1: black (mono)
	move.w	#1,vwork+30
inked:	clr.l	d0
	move.l	d0,COLBIT2(a0)
	move.w	d0,LSTLIN(a0)		; Write last line pixel
	move.w	#$FFFF,LNMASK(a0)	; Solid line style
	move.w	d0,WMODE(a0)		; Write mode replace
	move.l	#ff_pat,PATPTR(a0)	; Pattern pointer (just solid)
	move.w	d0,PATMSK(a0)		; Pattern length 1, single plane
	move.w	d0,MFILL(a0)
	move.w	#1,CLIP(a0)		; Enable clipping
	move.l	d0,MINCL(a0)		; Cliprect starts at (0,0)
	move.l	#$027f018f,MAXCL(a0)	; and ends at (639,399)
	move.l	#cont,SDABORT(a0)	; Never abort flood fill
	lea.l	X1(a0),a3	    	; a3 now points to line coords

	move.w	#gfx_pt_count-2,d3
	move.l	#gfx,a4
	jsr	read_val
	move.l	4(a3),(a3)
drawlp: jsr	read_val
	tst.w	6(a3)			; Did we read a 0 coord?
	bne	ok
	jsr	read_val		; Was 0, end of line
	subq	#1,d3
	jmp	next
ok:	move.l	4(a3),-(sp)
	dc.w	ALine
	tst.w	mode			; Are we in low-res mode?
	beq	pop			; If so, done.
	addq	#1,(a3)			; In med/high res, draw line two thick
	addq	#1,4(a3)
	dc.w	ALine
	cmp.w	#1,mode			; Are we in med-res mode?
	beq	pop			; If so, done.
	addq	#1,2(a3)		; In high res, line is two tall too
	addq	#1,6(a3)
	dc.w	ALine
	subq	#1,(a3)
	subq	#1,4(a3)
	dc.w	ALine
pop:	move.l	(sp)+,4(a3)
next:	move.l	4(a3),(a3)
	dbra	d3,drawlp

	;; Flood fills at (120,100), (183,102), and (173,133)
	move.l	#$00780064,ff_loc
	jsr	flood_fill
	move.l	#$00b70066,ff_loc
	jsr	flood_fill
	move.l	#$00ad0085,ff_loc
	jsr	flood_fill

	move.l	#banner,-(sp)
	jsr	song_init

play_song:
	jsr	song_step
	jsr	song_wait
	move.l	#$10002,(sp)		; Has a key been hit?
	trap	#13
	tst.w	d0
	beq.s	play_song

	jsr	song_end
	move.l	#$20002,(sp)		; Read key from console
	trap	#13
	addq.l	#4,a7

	move.l	#cursor_on,a3
	jsr	outstr
	move.w	#0,-(sp)		; Terminate program successfully
	trap	#1

read_val:
	clr.w	d0
	move.b	(a4)+,d0
	add.w	#gfx_x_bias,d0
	move.w	d0,4(a3)
	clr.w	d0
	move.b	(a4)+,d0
	move.w	d0,6(a3)
	move.w	mode,d0			; Coords are fine for low res
	beq.s	.done
	lsl.w	4(a3)			; non-lowres doubles X coords
	subq	#1,d0
	beq.s	.done
	lsl.w	6(a3)			; high res doubles both coords
.done:	rts

	;; Print zero-terminated string in a3 to console.
outstr: clr.w	d0
	move.b	(a3)+,d0
	beq	.done
	move.w	d0,-(sp)
	move.l	#$30002,-(sp)
	trap	#13
	addq.l	#6,sp
	jmp	outstr
.done:	rts

flood_fill:
	move.w	mode,d0
	beq.s	.go
	lsl.w	ff_loc
	subq	#1,d0
	beq.s	.go
	lsl.w	ff_loc+2
.go:	dc.w	SeedFill
	rts

cont:	clr.l	d0
	rts

	data
;;; Graphics data
gfx_x_bias	= $2e
gfx_pt_count	= $e3

gfx:	dc.b	$2F,$78,$40,$90,$4B,$AB,$6D,$B1,$7A,$AE,$8A,$99,$91,$8B
	dc.b	$88,$92,$83,$94,$72,$95,$67,$91,$5C,$87,$56,$76,$56,$6D
	dc.b	$5D,$6D,$5F,$6A,$65,$6A,$65,$68,$68,$68,$68,$6A,$6B,$6A
	dc.b	$6B,$68,$6D,$68,$71,$6D,$71,$73,$6D,$7D,$70,$7F,$76,$81
	dc.b	$78,$81,$81,$7F,$7F,$7D,$7C,$7D,$7A,$7D,$77,$7D,$74,$7D
	dc.b	$74,$73,$75,$68,$72,$63,$6C,$63,$5F,$63,$58,$65,$57,$62
	dc.b	$5E,$5C,$65,$5B,$75,$53,$7E,$59,$91,$5F,$96,$61,$9C,$6B
	dc.b	$9D,$70,$A2,$74,$A4,$74,$A5,$76,$A4,$77,$A2,$77,$A0,$7A
	dc.b	$9C,$7E,$9B,$82,$98,$84,$9C,$8D,$98,$A5,$9C,$A5,$9C,$AF
	dc.b	$A4,$B3,$C2,$B3,$BA,$A2,$BC,$A0,$B8,$9E,$B3,$86,$B1,$7F
	dc.b	$A8,$6F,$AC,$6B,$A4,$5E,$A4,$54,$A7,$4F,$D8,$4E,$AC,$45
	dc.b	$AC,$43,$E9,$3B,$A7,$3B,$9E,$37,$CC,$12,$8C,$2F,$7E,$2D
	dc.b	$75,$0F,$6D,$2E,$5D,$2F,$1D,$12,$4C,$35,$4C,$37,$44,$3B
	dc.b	$01,$3B,$3F,$43,$3F,$45,$10,$4F,$43,$4F,$48,$55,$3F,$6C
	dc.b	$2F,$78,$00,$00,$14,$4E,$40,$4A,$3F,$44,$00,$00,$04,$3C
	dc.b	$40,$3F,$44,$3C,$00,$00,$1F,$12,$58,$33,$56,$38,$5C,$37
	dc.b	$62,$2E,$00,$00,$7D,$2D,$71,$33,$87,$35,$95,$39,$95,$31
	dc.b	$CC,$12,$00,$00,$9F,$38,$9F,$3E,$A8,$44,$A9,$3E,$E8,$3B
	dc.b	$00,$00,$AB,$43,$AB,$4A,$D8,$4E,$00,$00,$A7,$69,$A1,$5C
	dc.b	$9E,$4E,$A6,$48,$A3,$45,$9A,$4B,$97,$49,$9C,$40,$98,$3E
	dc.b	$91,$47,$8B,$46,$8E,$3C,$88,$3A,$86,$45,$7D,$44,$7D,$39
	dc.b	$78,$39,$78,$44,$71,$45,$71,$3A,$6C,$3A,$6D,$44,$64,$44
	dc.b	$60,$3B,$5C,$3C,$5F,$45,$58,$47,$51,$3E,$4E,$40,$54,$4A
	dc.b	$58,$4A,$64,$47,$54,$4E,$4F,$55,$53,$58,$5E,$59,$68,$55
	dc.b	$70,$51,$76,$4D,$85,$58,$90,$5C,$98,$5D,$9C,$5E,$A0,$62
	dc.b	$A3,$66,$A4,$6A,$A7,$6A,$00,$00,$80,$68,$80,$67,$82,$64
	dc.b	$89,$63,$90,$64,$94,$68,$92,$6A,$8F,$6A,$8D,$68,$8B,$68
	dc.b	$8D,$68,$8B,$68,$88,$69,$87,$68,$85,$68,$85,$6A,$80,$68
	dc.b	$00,$00,$4C,$94,$50,$81,$52,$81,$52,$95,$4C,$94,$00,$00
	dc.b	$68,$86,$6A,$86,$73,$83,$76,$83,$7B,$84,$7C,$83,$81,$84
	dc.b	$88,$86,$81,$86,$7D,$86,$7B,$86,$78,$86,$76,$86,$71,$86
	dc.b	$70,$87,$71,$89,$7E,$8A,$7A,$8C,$78,$8C,$74,$8B,$71,$8C
	dc.b	$6D,$89,$69,$86,$69,$86

cls:	dc.b	27,'E',27,'f',0
cursor_on:
	dc.b	27,'e',0

ff_pat:
ff_col:	dc.w	$FFFF
vwork:	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2

	bss
ff_loc:	ds.l	1
mode:	ds.w	1

	include "protomus.asm"
	include "banner.asm"
