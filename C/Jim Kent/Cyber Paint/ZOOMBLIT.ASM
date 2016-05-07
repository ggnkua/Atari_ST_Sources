
;:ts=8
; BLiTTER BASE ADDRESS

BLiTTER         equ     $FF8A00

; BLiTTER REGISTER OFFSETS

Halftone        equ     0
Src_Xinc        equ     32
Src_Yinc        equ     34
Src_Addr        equ     36
Endmask1        equ     40
Endmask2        equ     42
Endmask3        equ     44
Dst_Xinc        equ     46
Dst_Yinc        equ     48
Dst_Addr        equ     50
X_Count         equ     54
Y_Count         equ     56
HOP             equ     58
OP              equ     59
Line_Num        equ     60
Skew            equ     61



fLineBusy       equ     7
fLineHog        equ     6
fLineSmudge     equ     5

mHOP_Source     equ     $02
mHOP_Halftone   equ     $01

mSkewFXSR       equ     $80
mSkewNFSR       equ     $40

mLineBusy       equ     $80
mLineHog        equ     $40
mLineSmudge     equ     $20

	public _zoomblit
	public zoom_return

	;screen sized zoom.  source in a0 dest in a1 line count-1 in d2
_zoomblit
	lea	zbsource(pc),a2
	move.l	a0,(a2)+
	move.l	a1,(a2)+
	move.w	d2,(a2)+
	pea	zoomblit
trap1438
	move.w	#38,-(sp)
	trap 	#14
	addq	#6,sp
	jmp	zoom_return


zbsource	dc.l	0
zbdest		dc.l	0
zbcount		dc.w	0
pat4	dc.w $0000,$000f,$00f0,$00ff,$0f00,$0f0f,$0ff0,$0fff
	dc.w $f000,$f00f,$f0f0,$f0ff,$ff00,$ff0f,$fff0,$ffff

zoomblit

	; find the blitter
	move.l	#BLiTTER,a1
	move.l	a1,a2

	;stuff the pattern buffer
	lea	pat4(pc),a0

	move.w	#7,d0 ;stuff 16 words of pattern buffer with
pcp	move.l	(a0)+,(a2)+	;the zoom 4x pattern
	dbra	d0,pcp

	;all end masks on always...
	move.w	#-1,d0
	move.w	d0,Endmask1(a1)
	move.w	d0,Endmask2(a1)
	move.w	d0,Endmask3(a1)

	lea	Line_Num(a1),a0	; point a0 to "on" switch
	move.w	#7,d0		; load in busy bit#

	; now fetch source dest and linecount parameters.  Pc relative
	; so can cope with no a5 global data pointer inside software interrupt
	move.l	zbsource(pc),d1	
	move.l	zbdest(pc),a2
	move.w	zbcount(pc),d2
	add.w	#1,d2		; d2 was line-count minus 1


	; set up parameters for initial 16 blits.  These are grouped in
	; four sets of four.  Each set takes care of one bit-plane.
	; Within a set each blit will take a nibble of the source to
	; a word in the dest.
	move.w	#8,Src_Xinc(a1)		; hit every word of source plane
	move.w	#120+8,Src_Yinc(a1)
	move.w	#32,Dst_Xinc(a1)	; every 4th word of dest plane
	move.w	#32+(160*3),Dst_Yinc(a1)
	move.w	#5,X_Count(a1)
	move.b	#mHOP_Halftone,HOP(a1)
	move.b	#3,OP(a1)

	;now go do the zoom in the x direction
	bsr	zplane
	bsr	zplane
	bsr	zplane
	bsr	zplane

	;at this point every 4th line of the dest screen has been zoomed.
	;we want to replicate lines.  I'll do this in 3 steps.  Copy line
	;0 to line 1, then line1 to line2, and last line 2 to line 3.

	move.w	#2,Src_Xinc(a1)	;do copy as if single-bitplane image in one pass
	move.w	#480+2,Src_Yinc(a1) ; skip 3 lines
	move.w	#2,Dst_Xinc(a1)
	move.w	#480+2,Dst_Yinc(a1)
	move.w	#80,X_Count(a1)
	move.b	#mHOP_Source,HOP(a1)
	move.b	#3,OP(a1)
	move.b	#0,Skew(a1)

	suba	#8,a2
	bsr	rpl_line
	bsr	rpl_line
	bsr	rpl_line
	rts

restart
	bset.b	d0,(a0)		; see if busy
	nop
	bne		restart
	rts

	; take a nibble to a word 4 times to cover all nibbles in
	; source word.
zplane
	move.l	d1,Src_Addr(a1)
	move.b	#0,Skew(a1)
	adda	#24,a2
	move.l	a2,Dst_Addr(a1)
	move.w	d2,Y_Count(a1)
	move.b	#mLineBusy+mLineSmudge,(a0)
	bsr 	restart

	move.l	d1,Src_Addr(a1)
	move.b	#4,Skew(a1)
	suba	#8,a2
	move.l	a2,Dst_Addr(a1)
	move.w	d2,Y_Count(a1)
	move.b	#mLineBusy+mLineSmudge,(a0)
	bsr	restart

	move.l	d1,Src_Addr(a1)
	move.b	#8,Skew(a1)
	suba	#8,a2
	move.l	a2,Dst_Addr(a1)
	move.w	d2,Y_Count(a1)
	move.b	#mLineBusy+mLineSmudge,(a0)
	bsr	restart

	move.l	d1,Src_Addr(a1)
	move.b	#12,Skew(a1)
	suba	#8,a2
	move.l	a2,Dst_Addr(a1)
	move.w	d2,Y_Count(a1)
	move.b	#mLineBusy+mLineSmudge,(a0)
	bsr	restart

	add.l	#2,d1	; advance to next plane of source
	adda	#2,a2	; advance to next plane of dest

	rts


rpl_line
	move.l	a2,Src_Addr(a1)
	adda.w	#160,a2
	move.l	a2,Dst_Addr(a1)
	move.w	d2,Y_Count(a1)
	move.b	#mLineBusy,(a0)
	bra	restart

