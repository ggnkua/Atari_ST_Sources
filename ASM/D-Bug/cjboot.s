	pea supercode(pc)
	move.w #$26,-(a7)
	trap #14
	lea 6(a7),a7

	move.w #1,-(a7)
	pea -1
	pea -1
	move.w #5,-(a7)
	trap #14
	lea 12(a7),a7

	clr.w -(a7)
	trap #1

supercode
	lea $78000,a0
	move.w #32000/2,d0
.wipe	clr.w (a0)+
	dbra d0,.wipe

	lea screen(pc),a0
	move.b $ffff8201.w,(a0)+
	move.b $ffff8203.w,(a0)+
	move.l $70.w,(a0)+
	move.b $ffff8260.w,(a0)
	movem.l $ffff8240.w,d0-7
	movem.l d0-7,2(a0)

	clr.w -(a7)
	pea $78000
	pea $78000
	move.w #5,-(a7)
	trap #14
	lea 12(a7),a7
	
	lea mypal(pc),a0
	movem.l (a0),d0-7
	movem.l d0-7,$ffff8240.w
	lea myvbl(pc),a0
	move.l a0,$70.w	

	lea $78000,a0
	bsr .plotbox
	lea $78000+80+2,a0
	bsr .plotbox
	lea $78000+(100*160)+4,a0
	bsr .plotbox
	lea $78000+(100*160)+6+80,a0
	bsr .plotbox
	lea $78000+72,a0
	move.w #59,d0
.x1	move.l #$0000ffff,(a0)
	move.l #$ffff0000,12+(150*160)(a0)
	lea 160(a0),a0
	dbra d0,.x1
	lea $78000+(100*160),a0
	move.w #15,d1
.x2	move.w #4,d0
.x3	move.l #$ffff0000,(a0)+
	clr.l (a0)+
	clr.l 112-(160*16)(a0)
	move.l #$ffff,112-(160*16)+4(a0)
	dbra d0,.x3
	lea 120(a0),a0
	dbra d1,.x2

	pea txt(pc)
	move.w #9,-(a7)
	trap #1
	lea 6(a7),a7

	lea tick+2(pc),a0
.hold	cmp.w #5*60,(a0)
	bne.s .hold

	lea screen(pc),a0
	move.b (a0)+,$ffff8201.w
	move.b (a0)+,$ffff8203.w
	move.l (a0)+,$70.w
	move.b (a0),$ffff8260.w
	movem.l 2(a0),d0-7
	movem.l d0-7,$ffff8240.w

	rts

.plotbox	
	move.w #99,d0	
.1	move.w #9,d1
.2	move.w #$ffff,(a0)
	lea 8(a0),a0
	dbra d1,.2
	lea 80(a0),a0
	dbra d0,.1
	rts

mypal	dc.w $777
	dc.w $770,$000,$000,$070
	dc.w $007,$007,$007,$700
	dc.w $007,$007,$007,$007
	dc.w $007,$007,$007

myvbl	movem.l d0-d7/a0-a6,-(a7)
	lea tick(pc),a0
	addq.w #1,2(a0)
	addq.w #1,(a0)
	cmp.w #20,(a0)
	bne .rte
	clr.w (a0)
	lea $ffff8242.w,a0
	move.w (a0),d0
	move.w 2(a0),d1
	move.w 14(a0),d2
	move.w 6(a0),d3
	move.w d1,(a0)
	move.w d2,2(a0)
	move.w d3,14(a0)
	move.w d0,6(a0)

.rte	movem.l (a7)+,d0-d7/a0-a6
	rte

txt	dc.b 27,"Y",32+11,32+12,"  [LAMER-SCAN]  "
	dc.b 27,"Y",32+12,32+12," AVG VIRUS FREE "
	dc.b 27,"Y",32+13,32+12,"  [D-BUG 2006]  ",0
	even

tick	dc.w 0,0
screen	dc.b 0
vblold	dc.l 0
res	dc.w 0
pal	ds.w 16
