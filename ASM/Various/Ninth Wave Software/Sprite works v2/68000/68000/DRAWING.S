;
; GFA replacement draw routines.
;
; 	~C:plot(x,y,colour,L:screen)
;	~C:line(x1,y1,x2,y2,colour,L:screen)
;	~C:box(x1,y1,x2,y2,colour,L:screen)
;	~C:clipping(x1,y1,x2,y2)
;	~C:clip_on()
;	~C:clip_off()
;
; ------- Copyright Terry King Ninth Wave Software 1993-95 -------

	bra	plot
	bra	line
	bra	box
	bra	clipping
	bra	clip_on
	bra	clip_off

	opt	o+	

xmin=2
ymin=4
xmax=6
ymax=8

plot	movem.l	d1-3/a0,-(a7)
	lea	clip_vars(pc),a0
	moveq	#0,d0
	moveq	#0,d1
	move	20(a7),d0
	move	22(a7),d1
	tst	(a0)
	beq.s	.noclip
.clip	cmp	ymin(a0),d1
	blt.s	off_screen
	cmp	ymax(a0),d1
	bgt.s	off_screen
	cmp	xmin(a0),d0
	blt.s	off_screen
	cmp	xmax(a0),d0
	bgt.s	off_screen
.noclip	move	24(a7),d2		; colour
	move.l	26(a7),a0		; screen
	move	d1,d3
	lsl	#2,d1
	add	d3,d1
	lsl.l	#5,d1
	add.l	d1,a0
	move	d0,d3
	lsr	#1,d3
	and	#$fff8,d3
	add	d3,a0
	and	#$f,d0
	lsl	#2,d0
	move.l	pixmask(pc,d0),d0
	move.l	d0,d1
	not.l	d1
	and	#$f,d2
	add	d2,d2
	move	here(pc,d2),d2
	jsr	here(pc,d2)
off_screen
	movem.l	(a7)+,d1-3/a0
	rts
	
pixmask	dc.l	$80008000,$40004000,$20002000,$10001000
	dc.l	$08000800,$04000400,$02000200,$01000100
	dc.l	$00800080,$00400040,$00200020,$00100010
	dc.l	$00080008,$00040004,$00020002,$00010001
here	dc.w	colour0-here
	dc.w	colour1-here
	dc.w	colour2-here
	dc.w	colour3-here
	dc.w	colour4-here
	dc.w	colour5-here
	dc.w	colour6-here
	dc.w	colour7-here
	dc.w	colour8-here
	dc.w	colour9-here
	dc.w	colour10-here
	dc.w	colour11-here
	dc.w	colour12-here
	dc.w	colour13-here
	dc.w	colour14-here
	dc.w	colour15-here
	
colour0	and.l	d1,(a0)+
	and.l	d1,(a0)
	rts
colour1	or	d0,(a0)+
	and	d1,(a0)+
	and.l	d1,(a0)
	rts
colour2	and	d1,(a0)+
	or	d0,(a0)+
	and.l	d1,(a0)
	rts
colour3	or	d0,(a0)+
	or	d0,(a0)+
	and.l	d1,(a0)
	rts
colour4	and.l	d1,(a0)+
	or	d0,(a0)+
	and	d1,(a0)
	rts
colour5	or	d0,(a0)+
	and	d1,(a0)+
	or	d0,(a0)+
	and	d1,(a0)
	rts
colour6	and	d1,(a0)+
	or.l	d0,(a0)+
	and	d1,(a0)
	rts
colour7	or.l	d0,(a0)+
	or	d0,(a0)+
	and	d1,(a0)
	rts
colour8	and.l	d1,(a0)+
	and	d1,(a0)+
	or	d0,(a0)
	rts
colour9	or	d0,(a0)+
	and.l	d1,(a0)+
	or	d0,(a0)
	rts
colour10 and	d1,(a0)+
	or	d0,(a0)+
	and	d1,(a0)+
	or	d0,(a0)
	rts
colour11 or.l	d0,(a0)+
	and	d1,(a0)+
	or	d0,(a0)
	rts
colour12 and.l	d1,(a0)+
	or.l	d0,(a0)
	rts
colour13 or	d0,(a0)+
	and	d1,(a0)+
	or.l	d0,(a0)
	rts
colour14 and	d1,(a0)+
	or	d0,(a0)+
	or.l	d0,(a0)
	rts
colour15 or.l	d0,(a0)+
	or.l	d0,(a0)
	rts
	
line	movem.l	d1-7/a0-6,-(a7)
	movem	60(a7),d0-4
	move.l	70(a7),a0
	lea	plot0(pc),a2
	and	#$f,d4
	lsl	#2,d4
	move	d4,d5
	add	d5,d5
	add	d5,d4
	add	d4,a2
	lea	clip_vars(pc),a6
	tst	(a6)
	beq	noclip
.clip	cmp	d1,d3			; y2>=y1?
	bge.s	y2big
	exg	d1,d3			; re-order
	exg	d0,d2
y2big	cmp	ymin(a6),d3		; CLIP ON Y
	blt	nodraw			; totally below window? <ymin
	cmp	ymax(a6),d1
	bgt	nodraw			; totally above window? >ymax
	cmp	ymax(a6),d3		; CLIP ON YMAX
	ble.s	okmaxy			; check that y2<=ymax 
	move	ymax(a6),d5
	sub	d3,d5			; ymax-y
	move	d2,d4
	sub	d0,d4			; dx=x2-x1
	muls	d5,d4			; (ymax-y)*(x2-x1)
	move	d3,d5
	sub	d1,d5			; dy
	divs	d5,d4			; (ymax-y)*(x2-x1)/(y2-y1)
	add	d4,d2
	move	ymax(a6),d3		; y1=0
okmaxy	cmp	ymin(a6),d1		; CLIP TO YMIN
	bge.s	cliponx
	move	ymin(a6),d5
	sub	d1,d5			; ymin-y
	move	d2,d4
	sub	d0,d4			; dx=x2-x1
	muls	d5,d4			; (ymin-y1)*(x2-x1)
	move	d3,d5
	sub	d1,d5			; dy
	divs	d5,d4			; (ymin-y)*(x2-x1)/(y2-y1)
	add	d4,d0
	move	ymin(a6),d1		; y1=0
cliponx	cmp	d0,d2			; CLIP ON X				
	bge.s	x2big
	exg	d0,d2			; reorder
	exg	d1,d3
x2big	cmp	xmin(a6),d2		; totally outside <xmim
	blt	nodraw
	cmp	xmax(a6),d0		; totally outside >xmax
	bgt	nodraw
	cmp	xmax(a6),d2		; CLIP ON XMAX
	ble.s	okmaxx	
	move	xmax(a6),d5
	sub	d2,d5			; xmax-x2
	move	d3,d4
	sub	d1,d4			; y2-y1
	muls	d5,d4			; (xmax-x1)*(y2-y1)
	move	d2,d5
	sub	d0,d5			; x2-x1
	divs	d5,d4			; (xmax-x1)*(y2-y1)/(x2-x1)
	add	d4,d3
	move	xmax(a6),d2
okmaxx	cmp	xmin(a6),d0
	bge.s	noclip
	move	xmin(a6),d5		; CLIP ON XMIN
	sub	d0,d5			; xmin-x
	move	d3,d4
	sub	d1,d4			; y2-y1
	muls	d5,d4			; (xmin-x)*(y2-y1)
	move	d2,d5
	sub	d0,d5			; x2-x1
	divs	d5,d4			; (xmin-x)*(y2-y1)/(x2-x1)
	add	d4,d1
	move	xmin(a6),d0		; x=xmin
noclip	lea	offsets(pc),a5
	cmp	d0,d2
	ble.s	.noswap
	exg	d0,d2			; x2>x1
	exg	d1,d3
.noswap	cmp	d3,d1
	bge.s	.up
	move.l	#160,a6
	bra.s	.cd
.up	move.l	#-160,a6
.cd	sub	d0,d2			; dx
	bge.s	.dxp
	neg	d2
.dxp	sub	d1,d3			; dy
	bge.s	.dyp
	neg	d3
.dyp	cmp	d3,d2
	ble.s	steep
	
	moveq	#0,d5
	move	d1,d5
	lsl	#2,d5
	add	d1,d5
	lsl.l	#5,d5
	add.l	d5,a0
	move	d0,d4
	and	#$fff0,d4
	lsr	#1,d4
	add	d4,a0
	and	#$f,d0	
	add	d0,d0
	move	(a5,d0.w),d7
	move	d7,d1
	move	d3,d4
	add	d4,d4
	sub	d2,d4			; e=(2*dy)-dx
	move	d3,d5
	sub	d2,d5
	add	d5,d5			; inc1=2*(dy-dx)
	move	d3,d6
	add	d6,d6			; inc2=2*dy
	subq	#1,d2
.lp	tst	d4
	blt.s	.case2
	move	d1,d0
	not	d0
	jsr	(a2)
	moveq	#0,d1
	add	a6,a0
	add	d5,d4
	bra.s	.endcse
.case2	add	d6,d4
.endcse	add	d7,d7
	bne.s	.or
	moveq	#1,d7
	move	d1,d0
	not	d0
	jsr	(a2)
	moveq	#0,d1
	subq	#8,a0
.or	or	d7,d1
	dbf	d2,.lp
	move	d1,d0
	not	d0
	jsr	(a2)
	movem.l	(a7)+,d1-7/a0-6
	rts
	
steep	moveq	#0,d5
	move	d1,d5
	lsl	#2,d5
	add	d1,d5
	lsl.l	#5,d5
	add.l	d5,a0
	move	d0,d4
	and	#$fff0,d4
	lsr	#1,d4
	add	d4,a0
	and	#$f,d0
	add	d0,d0
	move	(a5,d0.w),d1
	move	d1,d0
	not	d0
	jsr	(a2)
	move	d2,d4
	add	d4,d4
	sub	d3,d4			; e=(2*dx)-dy
	move	d2,d5
	sub	d3,d5
	add	d5,d5			; inc1=2*(dx-dy)
	move	d2,d6
	add	d6,d6			; inc2=2*dx
	subq	#1,d3
	blt.s	nodraw
.lp	tst	d4
	blt.s	.case2
	add	d1,d1
	bne.s	.inside
	moveq	#1,d1
	subq	#8,a0
.inside	add	d5,d4
	bra.s	.endcse
.case2	add	d6,d4
.endcse	add	a6,a0
	move	d1,d0
	not	d0
	jsr	(a2)
	dbf	d3,.lp
nodraw	movem.l	(a7)+,d1-7/a0-6
	rts

plot0	move.l	a0,a1
	and	d0,(a1)+
	and	d0,(a1)+
	and	d0,(a1)+
	and	d0,(a1)
	rts
plot1	move.l	a0,a1
	or	d1,(a1)+
	and	d0,(a1)+
	and	d0,(a1)+
	and	d0,(a1)
	rts
plot2	move.l	a0,a1
	and	d0,(a1)+
	or	d1,(a1)+
	and	d0,(a1)+
	and	d0,(a1)
	rts
plot3	move.l	a0,a1
	or	d1,(a1)+
	or	d1,(a1)+
	and	d0,(a1)+
	and	d0,(a1)
	rts
plot4	move.l	a0,a1
	and	d0,(a1)+
	and	d0,(a1)+
	or	d1,(a1)+
	and	d0,(a1)
	rts
plot5	move.l	a0,a1
	or	d1,(a1)+
	and	d0,(a1)+
	or	d1,(a1)+
	and	d0,(a1)
	rts
plot6	move.l	a0,a1
	and	d0,(a1)+
	or	d1,(a1)+
	or	d1,(a1)+
	and	d0,(a1)
	rts
plot7	move.l	a0,a1
	or	d1,(a1)+
	or	d1,(a1)+
	or	d1,(a1)+
	and	d0,(a1)
	rts
plot8	move.l	a0,a1
	and	d0,(a1)+
	and	d0,(a1)+
	and	d0,(a1)+
	or	d1,(a1)
	rts
plot9	move.l	a0,a1
	or	d1,(a1)+
	and	d0,(a1)+
	and	d0,(a1)+
	or	d1,(a1)
	rts
plot10	move.l	a0,a1
	and	d0,(a1)+
	or	d1,(a1)+
	and	d0,(a1)+
	or	d1,(a1)
	rts
plot11	move.l	a0,a1
	or	d1,(a1)+
	or	d1,(a1)+
	and	d0,(a1)+
	or	d1,(a1)
	rts
plot12	move.l	a0,a1
	and	d0,(a1)+
	and	d0,(a1)+
	or	d1,(a1)+
	or	d1,(a1)
	rts
plot13	move.l	a0,a1
	or	d1,(a1)+
	and	d0,(a1)+
	or	d1,(a1)+
	or	d1,(a1)
	rts
plot14	move.l	a0,a1
	and	d0,(a1)+
	or	d1,(a1)+
	or	d1,(a1)+
	or	d1,(a1)
	rts
plot15	move.l	a0,a1
	or	d1,(a1)+
	or	d1,(a1)+
	or	d1,(a1)+
	or	d1,(a1)
	rts

offsets	dc.w	$8000,$4000,$2000,$1000
	dc.w	$0800,$0400,$0200,$0100
	dc.w	$0080,$0040,$0020,$0010
	dc.w	$0008,$0004,$0002,$0001

box	movem.l	d1-7/a0-6,-(a7)
	move	60(a7),d4
	move	62(a7),d1
	move	64(a7),d6
	move	66(a7),d3
	move	68(a7),d0
	
	lea	_c_bplanes(pc),a3	; Pointer to bit plane data
	moveq	#3,d7
.clp	roxr	#1,d0
	roxl	#1,d2
	and	#1,d2
	move	d2,(a3)+
	dbf	d7,.clp
	subq	#8,a3

	cmp	d4,d6
	bge.s	.xok
	exg	d4,d6
.xok	cmp	d1,d3
	bge.s	.yok
	exg	d1,d3
.yok	lea	clip_vars(pc),a0
	tst	(a0)
	beq.s	 .c4
	cmp	ymin(a0),d3
	blt	boxoff
	cmp	ymax(a0),d1
	bgt	boxoff
	cmp	xmin(a0),d6
	blt	boxoff
	cmp	xmax(a0),d4
	bgt	boxoff
	cmp	ymin(a0),d1
	bgt.s	.c1
	move	ymin(a0),d1
.c1	cmp	ymax(a0),d3
	blt.s	.c2
	move	ymax(a0),d3
.c2	cmp	xmin(a0),d4
	bgt.s	.c3
	move	xmin(a0),d4
.c3	cmp	xmax(a0),d6
	blt.s	.c4
	move	xmax(a0),d6
.c4	move.l	70(a7),a0
	sub	d1,d3
	move	d1,d5

	move	d4,d1		 ; D1=X1
	asr	#4,d1		 ; Divide X1 by 8
	move	d6,d2		 ; D2=X2
	asr	#4,d2		 ; Divide X2 by 8
	and	#$f,d4		 ; X1=X1 MOD 16
	add	d4,d4		 ; Double it
	move	ll_tab(pc,d4),d4 ; Bit pattern for right
	and	#$f,d6		 ; X2=X2 MOD 16
	add	d6,d6		 ; Double it
	move	rl_tab(pc,d6),d6 ; Bit pattern for left
	not	d6		 ; Invert bits for right side
	sub	d1,d2		 ; Are pixels within same word?
	bne.s	h_apart		 ; no
	and	d6,d4		 ; yes, AND bit patterns together
h_apart	and.l	#$ffff,d5
	move	d5,d7
	lsl	#2,d5
	add	d7,d5
	lsl.l	#5,d5
	add.l	d5,a0
	muls	#8,d1
	add	d1,a0
	moveq	#4-1,d7		 ; Number of bit planes
	not	d4	
	not	d6
.ylp	movem.l	d3/d7/a3,-(a7)
	bsr.s	fastline
	movem.l	(a7)+,d3/d7/a3
	lea	160(a0),a0
	dbf	d3,.ylp
boxoff	movem.l	(a7)+,d1-7/a0-6
	rts
	
ll_tab	dc.w	$ffff,$7fff,$3fff,$1fff
	dc.w	$0fff,$07ff,$03ff,$01ff
	dc.w	$00ff,$007f,$003f,$001f
	dc.w	$000f,$0007,$0003,$0001
rl_tab	dc.w	$7fff,$3fff,$1fff,$0fff
	dc.w	$07ff,$03ff,$01ff,$00ff
	dc.w	$007f,$003f,$001f,$000f
	dc.w	$0007,$0003,$0001,$0000

; d4=x1 d5=y d6=x2
fastline
	move.l	a0,a1
h_nxt_plane
	move.l	a1,a2		Restore screen address
	move	d2,d5		Restore integer width
	move	#-1,d3		Get fill pattern
	tst	(a3)+		Test bit plane, fill or blank ?
	bne.s	h_fill
	and	d4,(a1)+	Clear the FIRST pixels
	subq	#1,d5		Decrease integer width
	bcs.s	h_blank1
	subq	#1,d5		Decrease integer width
	bcs.s	h_blank2
	moveq	#0,d1		Clear D1
h_blank3
	addq	#8,a2		Increase screen address
	move	d1,(a2)		Clear the MIDDLE pixels
	dbf	d5,h_blank3
h_blank2
	move	d6,d1
	addq	#8,a2		Increase screen address
	and	d1,(a2)		Clear the LAST pixels
h_blank1
	dbf	d7,h_nxt_plane
	rts
h_fill	move	(a2),d1		Get screen data
	eor	d3,d1
	and	d4,d1		Mask off rubbish
	eor	d3,d1
	move	d1,(a1)+	Fill the FIRST pixels
	subq	#1,d5		Decrease integer width
	bcs.s	h_filled1
	subq	#1,d5		Decrease integer width
	bcs.s	h_filled2
h_filled3
	addq	#8,a2		Increase screen address
	move	d3,(a2)		Fill the MIDDLE pixels
	dbf	d5,h_filled3
h_filled2
	addq	#8,a2		Increase screen address
	move	(a2),d1		Get screen data
	eor	d3,d1
	and	d6,d1		Mask off rubbish
	eor	d3,d1
	move	d1,(a2)		Fill the LAST pixels
h_filled1
	dbf	d7,h_nxt_plane
	rts

_c_bplanes	dc.w	1,1,1,1

clip_vars
	dc.w	1		; clipping on/off
	dc.w	0		; x1
	dc.w	0		; y1
	dc.w	319		; x2
	dc.w	199		; y2

clip_on	move.l	a0,-(a7)
	lea	clip_vars(pc),a0
	move	#1,(a0)
	move.l	(a7)+,a0
	rts
clip_off move.l	a0,-(a7)
	lea	clip_vars(pc),a0
	clr	(a0)
	move.l	(a7)+,a0
	rts
clipping
	movem.l	d0-3/a0,-(a7)
	movem	24(a7),d0-3
	lea	clip_vars(pc),a0
	move	#1,(a0)+
	movem	d0-3,(a0)
	movem.l	(a7)+,d0-3/a0
	rts
