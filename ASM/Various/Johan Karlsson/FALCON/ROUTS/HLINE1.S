*
* HLINE1.S
*
*	@drawhline1
*
*	Draws a horizontal line in 8 bitplane mode. Clipping is implemented.
*	This routine only uses the six first bitplanes.
*
* In	a0.l=screenadr d0=xmin d1=xmax
*	d2.l - d4.l =6 bitplanes
*	xres equ  horizontal screen resolution
*	(destroys d0-d7/a0-a1)
*
* ex.	 move.l	screen,a0
*	 move #-34,d0		left xcord
*	 move #67,d1		right xcord
*	 move.l #$0,d2		don't set bitplane 0 or 1
*	 move.l	#$0000ffff,d3	set bitplane 3
*	 move.l	#$ffffffff,d4	set bitplane 4 and 5
*	 bsr @drawhline1
*

@drawhline1
	cmp	d0,d1
	bgt	.ok
	move	d0,d7
	move	d1,d0
	move	d7,d1
.ok	tst	d0
	ble	.dl1
	cmp	#xres-1,d1
	ble	.dl4
	cmp	#xres-1,d0
	bgt	.ut
	move	#xres-1,d1
.dl4	move	d0,d5
	move	d5,d7
	and.l	#$fff0,d5
	move	d1,d6
	and	#$fff0,d6
	cmp	d5,d6
	beq	.shortline
	add.l	d5,a0
	and	#$f,d0
	lsl	#2,d0
	move.l	#.leftmask,a1
	move.l	(a1,d0.w),d5

	tst.l	d2
	beq	.drw_a0		both zeroes
	tst	d2
	beq	.drw_a1		zero and one
	swap	d2
	tst	d2
	beq	.drw_a2		one and zero
	or.l	d5,(a0)+

.drw_b	tst.l	d3
	beq	.drw_b0		both zeroes
	tst	d3
	beq	.drw_b1		zero and one
	swap	d3
	tst	d3
	beq	.drw_b2		one and zero
	or.l	d5,(a0)+

.drw_c	tst.l	d4
	beq	.drw_c0		both zeroes
	tst	d4
	beq	.drw_c1		zero and one
	swap	d4
	tst	d4
	beq	.drw_c2		one and zero
	or.l	d5,(a0)+

.drw_d	addq.l	#4,a0
	sub	d7,d1
	not	d7
	and	#$f,d7
	sub	d7,d1
	subq	#1,d1
	bgt	.dl1
.ut	rts

.drw_a0	not.l	d5
	and.l	d5,(a0)+
	not.l	d5
	bra	.drw_b
.drw_a2	not	d5
	and	d5,(a0)+
	not	d5
	or	d5,(a0)+
	swap	d2
	bra	.drw_b
.drw_a1	or	d5,(a0)+
	not	d5
	and	d5,(a0)+
	not	d5
	bra	.drw_b

.drw_b0	not.l	d5
	and.l	d5,(a0)+
	not.l	d5
	bra	.drw_c
.drw_b2	not	d5
	and	d5,(a0)+
	not	d5
	or	d5,(a0)+
	swap	d3
	bra	.drw_c
.drw_b1	or	d5,(a0)+
	not	d5
	and	d5,(a0)+
	not	d5
	bra	.drw_c

.drw_c0	not.l	d5
	and.l	d5,(a0)+
	not.l	d5
	bra	.drw_d
.drw_c2	not	d5
	and	d5,(a0)+
	not	d5
	or	d5,(a0)+
	swap	d4
	bra	.drw_d
.drw_c1	or	d5,(a0)+
	not	d5
	and	d5,(a0)+
	bra	.drw_d




* Žnda ut till v„nster

.dl1	tst	d1
	blt	.ut
	cmp	#xres-1,d1
	bge	.dl2
	move	d1,d0
	addq	#1,d0
	lsr	#4,d0
	subq	#1,d0		antal 16pix
	blt	.dl5
.dl6	movem.l	d2-d4,(a0)	rita alla hela 16pix
	add.l	#16,a0
	dbra	d0,.dl6
	
.dl5	and	#$f,d1		rita resten
	cmp	#15,d1
	beq	.dl7
	lsl	#2,d1
	move.l	#.rightmask,a1
	move.l	(a1,d1.w),d0

.rest	tst.l	d2
	beq	.dl8		both zeroes
	tst	d2
	beq	.dl9		zero and one
	swap	d2
	tst	d2
	beq	.dl9b		one and zero
	or.l	d0,(a0)+

.dl10	tst.l	d3
	beq	.dl11		both zeroes
	tst	d3
	beq	.dl12		zero and one
	swap	d3
	tst	d3
	beq	.dl12b		one and zero
	or.l	d0,(a0)+

.dl13	tst.l	d4
	beq	.dl14		both zeroes
	tst	d4
	beq	.dl15		zero and one
	swap	d4
	tst	d4
	beq	.dl15b		one and zero
	or.l	d0,(a0)+
.dl7	rts	

.dl8	not.l	d0
	and.l	d0,(a0)+
	not.l	d0
	bra	.dl10
.dl9b	not	d0
	and	d0,(a0)+
	not	d0
	or	d0,(a0)+
	swap	d2
	bra	.dl10
.dl9	or	d0,(a0)+
	not	d0
	and	d0,(a0)+
	not	d0
	bra	.dl10

.dl11	not.l	d0
	and.l	d0,(a0)+
	not.l	d0
	bra	.dl13
.dl12b	not	d0
	and	d0,(a0)+
	not	d0
	or	d0,(a0)+
	swap	d3
	bra	.dl13
.dl12	or	d0,(a0)+
	not	d0
	and	d0,(a0)+
	not	d0
	bra	.dl13

.dl14	not.l	d0
	and.l	d0,(a0)+
	rts
.dl15b	not	d0
	and	d0,(a0)+
	not	d0
	or	d0,(a0)+
	swap	d4
	rts
.dl15	or	d0,(a0)+
	not	d0
	and	d0,(a0)+
	rts


* Linjen „r ™ver hela sk„rmen

.dl2	move	#xres/16/2-1,d5
.dl3	movem.l	d2-d4,(a0)
	add.l	#16,a0
	movem.l	d2-d4,(a0)
	add.l	#16,a0
	dbra	d5,.dl3
	rts

* Linjen befinner sig i endast en 16pix

.shortline
	add.l	d5,a0
	move.l	#.shortmask,a1
	and.l	#$f,d0
	lsl	#6,d0
	add.l	d0,a1
	and	#$f,d1
	lsl	#2,d1
	move.l	(a1,d1.w),d0
	bra	.rest	



.shortmask	dc.l	$80008000,$c000c000,$e000e000,$f000f000
		dc.l	$f800f800,$fc00fc00,$fe00fe00,$ff00ff00
		dc.l	$ff80ff80,$ffc0ffc0,$ffe0ffe0,$fff0fff0
		dc.l	$fff8fff8,$fffcfffc,$fffefffe,$ffffffff

		dc.l	$00000000,$40004000,$60006000,$70007000
		dc.l	$78007800,$7c007c00,$7e007e00,$7f007f00
		dc.l	$7f807f80,$7fc07fc0,$7fe07fe0,$7ff07ff0
		dc.l	$7ff87ff8,$7ffc7ffc,$7ffe7ffe,$7fff7fff

		dc.l	$00000000,$00000000,$20002000,$30003000
		dc.l	$38003800,$3c003c00,$3e003e00,$3f003f00
		dc.l	$3f803f80,$3fc03fc0,$3fe03fe0,$3ff03ff0
		dc.l	$3ff83ff8,$3ffc3ffc,$3ffe3ffe,$3fff3fff

		dc.l	$00000000,$00000000,$00000000,$10001000
		dc.l	$18001800,$1c001c00,$1e001e00,$1f001f00
		dc.l	$1f801f80,$1fc01fc0,$1fe01fe0,$1ff01ff0
		dc.l	$1ff81ff8,$1ffc1ffc,$1ffe1ffe,$1fff1fff

		dc.l	$00000000,$00000000,$00000000,$00000000
		dc.l	$08000800,$0c000c00,$0e000e00,$0f000f00
		dc.l	$0f800f80,$0fc00fc0,$0fe00fe0,$0ff00ff0
		dc.l	$0ff80ff8,$0ffc0ffc,$0ffe0ffe,$0fff0fff

		dc.l	$00000000,$00000000,$00000000,$00000000
		dc.l	$00000800,$04000400,$06000600,$07000700
		dc.l	$07800780,$07c007c0,$07e007e0,$07f007f0
		dc.l	$07f807f8,$07fc07fc,$07fe07fe,$07ff07ff

		dc.l	$00000000,$00000000,$00000000,$00000000
		dc.l	$00000000,$00000000,$02000200,$03000300
		dc.l	$03800380,$03c003c0,$03e003e0,$03f003f0
		dc.l	$03f803f8,$03fc03fc,$03fe03fe,$03ff03ff

		dc.l	$00000000,$00000000,$00000000,$00000000
		dc.l	$00000000,$00000000,$00000000,$01000100
		dc.l	$01800180,$01c001c0,$01e001e0,$01f001f0
		dc.l	$01f801f8,$01fc01fc,$01fe01fe,$01ff01ff

		dc.l	$00000000,$00000000,$00000000,$00000000
		dc.l	$00000000,$00000000,$00000000,$00000000
		dc.l	$00800080,$00c000c0,$00e000e0,$00f000f0
		dc.l	$00f800f8,$00fc00fc,$00fe00fe,$00ff00ff

		dc.l	$00000000,$00000000,$00000000,$00000000
		dc.l	$00000000,$00000000,$00000000,$00000000
		dc.l	$00000000,$00400040,$00600060,$00700070
		dc.l	$00780078,$007c007c,$007e007e,$007f007f

		dc.l	$00000000,$00000000,$00000000,$00000000
		dc.l	$00000000,$00000000,$00000000,$00000000
		dc.l	$00000000,$00000000,$00200020,$00300030
		dc.l	$00380038,$003c003c,$003e003e,$003f003f

		dc.l	$00000000,$00000000,$00000000,$00000000
		dc.l	$00000000,$00000000,$00000000,$00000000
		dc.l	$00000000,$00000000,$00000000,$00100010
		dc.l	$00180018,$001c001c,$001e001e,$001f001f

		dc.l	$00000000,$00000000,$00000000,$00000000
		dc.l	$00000000,$00000000,$00000000,$00000000
		dc.l	$00000000,$00000000,$00000000,$00000000
		dc.l	$00080008,$000c000c,$000e000e,$000f000f

		dc.l	$00000000,$00000000,$00000000,$00000000
		dc.l	$00000000,$00000000,$00000000,$00000000
		dc.l	$00000000,$00000000,$00000000,$00000000
		dc.l	$00000000,$00040004,$00060006,$00070007

		dc.l	$00000000,$00000000,$00000000,$00000000
		dc.l	$00000000,$00000000,$00000000,$00000000
		dc.l	$00000000,$00000000,$00000000,$00000000
		dc.l	$00000000,$00000000,$00020002,$00030003

		dc.l	$00000000,$00000000,$00000000,$00000000
		dc.l	$00000000,$00000000,$00000000,$00000000
		dc.l	$00000000,$00000000,$00000000,$00000000
		dc.l	$00000000,$00000000,$00000000,$00010001

.rightmask	dc.l	$80008000,$c000c000,$e000e000,$f000f000
		dc.l	$f800f800,$fc00fc00,$fe00fe00,$ff00ff00
		dc.l	$ff80ff80,$ffc0ffc0,$ffe0ffe0,$fff0fff0
		dc.l	$fff8fff8,$fffcfffc,$fffefffe
		
.leftmask	dc.l	$ffffffff,$7fff7fff,$3fff3fff,$1fff1fff,$0fff0fff
		dc.l	$07ff07ff,$03ff03ff,$01ff01ff,$00ff00ff
		dc.l	$007f007f,$003f003f,$001f001f,$000f000f
		dc.l	$00070007,$00030003,$00010001
