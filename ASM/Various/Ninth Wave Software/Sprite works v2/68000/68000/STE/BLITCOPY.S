		bra	blit_copy
		bra	blit_get
		bra	blit_put
		bra	blit_clip
				
blit_buffer	dc.l	0	; source address
		dc.w	8	; offset between words in plane
		dc.w	160	; source width
		dc.w	2	; offset between planes
		dc.w	0	; source x
		dc.w	0	; source y
		
		dc.l	0	; destination address
		dc.w	8	; offset between words in plane
		dc.w	160	; destination width
		dc.w	2	; offset between planes
		dc.w	0	; destination x
		dc.w	0	; destination y
		
		dc.w	0	; width
		dc.w	0	; height
		dc.w	4	; bit planes
	
		dc.w	0	; mode

blit_window	dc.w	0,0,320,200
		
Src_Xinc	equ	32
Src_Yinc	equ	34
Src_Addr	equ	36
Endmask1	equ	40
Endmask2	equ	42
Endmask3	equ	44
Dst_Xinc	equ	46
Dst_Yinc	equ	48
Dst_Addr	equ	50
X_Count		equ	54
Y_Count		equ	56
HOP		equ	58
OP		equ	59
Line_Num	equ	60
Skew		equ	61

SRC_FORM	equ	0
SRC_NXWD	equ	4
SRC_NXLN	equ	6
SRC_NXPL	equ	8
SRC_XMIN	equ	10
SRC_YMIN	equ	12
DST_FORM	equ	14
DST_NXWD	equ	18
DST_NXLN	equ	20
DST_NXPL	equ	22
DST_XMIN	equ	24
DST_YMIN	equ	26
WIDTH		equ	28
HEIGHT		equ	30
PLANES		equ	32
MODE		equ	34
	opt	o+

blit_clip
	movem.l	d1-3/a0,-(a7)
	lea	blit_window(pc),a0
	movem	20(a7),d0-3
	addq	#1,d2
	addq	#1,d3
	movem	d0-3,(a0)
	movem.l	(a7)+,d1-3/a0
	rts
	
;	blit(source_width,source,x,y,width,height,dst_width,dst,x,y,mode)

blit_get
	movem.l	d1-7/a0-6,-(a7)
	moveq	#1,d7
	bra.s	blit_it
blit_put
	movem.l	d1-7/a0-6,-(a7)
	moveq	#2,d7
	bra.s	blit_it
blit_copy
	movem.l	d1-7/a0-6,-(a7)
	moveq	#0,d7
blit_it	lea	blit_buffer(pc),a4
	move	60(a7),SRC_NXLN(a4)	; source width
	move.l	62(a7),SRC_FORM(a4)
	movem	66(a7),d0-3		; x,y,width,height source
	move	d0,SRC_XMIN(a4)
	move	d1,SRC_YMIN(a4)
	move	d2,WIDTH(a4)
	move	d3,HEIGHT(a4)

	cmp	#1,d7
	blt	norm
	bgt.s	put

;	blit_get(source_width,source,x,y,width,height,destination)

get	move.l	74(a7),DST_FORM(a4)
	clr	DST_XMIN(a4)
	clr	DST_YMIN(a4)
	move.b	#3,MODE(a4)
	and	#$fff0,d2
	lsr	#1,d2
	beq.s	.int
	addq	#8,d2			; extra word width
.int	move	d2,DST_NXLN(a4)
	lea	do_blit(pc),a0
	move.l	a0,-(a7)
	move	#38,-(a7)
	trap	#14
	addq.l	#6,a7
	movem.l	(a7)+,d1-7/a0-6
	rts

;	blit_put(source_width,source,x,y,width,height,destination,mode)

put	move.l	74(a7),DST_FORM(a4)
	move	SRC_XMIN(a4),DST_XMIN(a4)
	move	SRC_YMIN(a4),DST_YMIN(a4)
	move	SRC_NXLN(a4),DST_NXLN(a4)
	clr	SRC_XMIN(a4)
	clr	SRC_YMIN(a4)
	move	78(a7),d0
	move.b	d0,MODE(a4)
	and	#$fff0,d2
	lsr	#1,d2
	beq.s	.int
	addq	#8,d2			; extra word width
.int	move	d2,SRC_NXLN(a4)
	move	DST_XMIN(a4),d0
	move	DST_YMIN(a4),d1
	bsr.s	clip
	tst	d7
	bmi.s	.our
	lea	do_blit(pc),a0
	move.l	a0,-(a7)
	move	#38,-(a7)
	trap	#14
	addq.l	#6,a7
.our	movem.l	(a7)+,d1-7/a0-6
	rts
	
norm	move	74(a7),DST_NXLN(a4)
	move.l	76(a7),DST_FORM(a4)
	movem	80(a7),d0-2		; x,y destination and mode
	move	d0,DST_XMIN(a4)
	move	d1,DST_YMIN(a4)
	move.b	d2,MODE(a4)

	bsr.s	clip
	tst	d7
	bmi.s	.our
	lea	do_blit(pc),a0
	move.l	a0,-(a7)
	move	#38,-(a7)
	trap	#14
	addq.l	#6,a7
.our	movem.l	(a7)+,d1-7/a0-6
	rts

clip	lea	blit_window(pc),a0
	cmp	(a0),d0			; xmin & x
	bge.s	.nc1
	add	d0,WIDTH(a4)		; +x
	move	(a0),d2
	sub	d2,WIDTH(a4)		; -xmin
	sub	d0,d2
	move	d2,SRC_XMIN(a4)		; src x=xmin-x
	move	(a0),DST_XMIN(a4)	; dst x=xmin
	bra.s	.nc2

.nc1	move	4(a0),d2		; xmax
	sub	WIDTH(a4),d2		; xmax-width
	cmp	d2,d0			; xmax & x
	ble.s	.nc2
	move	4(a0),d2
	sub	d0,d2
	move	d2,WIDTH(a4)		; width=xmax-x
	
.nc2	tst	WIDTH(a4)
	ble.s	.cour

	cmp	2(a0),d1		; ymin & y
	bge.s	.nc3
	add	d1,HEIGHT(a4)		; +y
	move	2(a0),d2
	sub	d2,HEIGHT(a4)		; -ymin
	sub	d1,d2
	move	d2,SRC_YMIN(a4)		; src y=ymin-y
	move	(a0),DST_YMIN(a4)	; dst y=ymin
	bra.s	.nc4

.nc3	move	6(a0),d2		; ymax
	sub	HEIGHT(a4),d2		; ymax-height
	cmp	d2,d1			; ymax & y
	ble.s	.nc4
	move	6(a0),d2
	sub	d1,d2
	move	d2,HEIGHT(a4)		; height=ymax-y
	
.nc4	tst	HEIGHT(a4)
	ble.s	.cour
	moveq	#0,d7
	rts
.cour	moveq	#-1,d7
	rts
	
lf_endmask
	dc.w	$ffff
rt_endmask
	dc.w	$7fff,$3fff,$1fff,$0fff
	dc.w	$07ff,$03ff,$01ff,$00ff
	dc.w	$007f,$003f,$001f,$000f
	dc.w	$0007,$0003,$0001,$0000

do_blit	lea	blit_buffer(pc),a4
	lea	$FFFF8A00.w,a5
	move	WIDTH(a4),d6
	subq	#1,d6
	move	SRC_XMIN(a4),d0
	move	d0,d1
	add	d6,d1
	move	DST_XMIN(a4),d2
	move	d2,d3
	add	d6,d3
	moveq	#$f,d6
	move	d2,d4
	and	d6,d4
	add	d4,d4
	move	lf_endmask(pc,d4.w),d4
	move	d3,d5
	and	d6,d5
	add	d5,d5
	move	rt_endmask(pc,d5.w),d5
	not	d5
	
	move	d2,d7
	and	d6,d7
	and	d0,d6
	sub	d6,d7
	clr	d6
	addx	d6,d6
	lsr	#4,d0
	lsr	#4,d1
	sub	d0,d1
	lsr	#4,d2
	lsr	#4,d3
	sub	d2,d3
	bne.s	set_endmasks
	and	d5,d4
	addq	#4,d6
set_endmasks
	move	d4,Endmask1(a5)
	move	#$ffff,Endmask2(a5)
	move	d5,Endmask3(a5)
	cmp	d1,d3
	bne.s	set_count
	addq	#2,d6
set_count
	move	d3,d4
	addq	#1,d4
	move	d4,X_Count(a5)
	
	move.l	SRC_FORM(a4),a0
	move	SRC_YMIN(a4),d4
	move	SRC_NXLN(a4),d5
	mulu	d5,d4
	add.l	d4,a0
	move	SRC_NXWD(a4),d4
	move	d4,Src_Xinc(a5)
	mulu	d4,d0
	add.l	d0,a0
	mulu	d4,d1
	sub	d1,d5
	move	d5,Src_Yinc(a5)
	
	move.l	DST_FORM(a4),a1
	move	DST_YMIN(a4),d4
	move	DST_NXLN(a4),d5
	mulu	d5,d4
	add.l	d4,a1
	move	DST_NXWD(a4),d4
	move	d4,Dst_Xinc(a5)
	mulu	d4,d2
	add.l	d2,a1
	mulu	d4,d3
	sub	d3,d5
	move	d5,Dst_Yinc(a5)
	
	and.b	#$0f,d7
	or.b	skew_flags(pc,d6.w),d7
	move.b	d7,Skew(a5)
	move.b	#2,HOP(a5)
	move.b	MODE(a4),OP(a5)
	lea	Line_Num(a5),a2
	move.b	#7,d2
	move	PLANES(a4),d7
	bra.s	begin

	
skew_flags
	dc.b	%01000000
	dc.b	%10000000
	dc.b	0
	dc.b	%11000000
	
	dc.b	0
	dc.b	%10000000
	dc.b	0
	dc.b	0
	
next_plane
	move.l	a0,Src_Addr(a5)
	move.l	a1,Dst_Addr(a5)
	move	HEIGHT(a4),Y_Count(a5)
	move.b	#$80,(a2)
	add	SRC_NXPL(a4),a0
	add	DST_NXPL(a4),a1
	
restart
	bset.b	d2,(a2)
	nop
	bne.s	restart
	
begin	dbf	d7,next_plane
	rts
