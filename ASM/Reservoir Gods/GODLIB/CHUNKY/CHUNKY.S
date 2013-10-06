********************************************************************
;	EQUATES
********************************************************************

dCHUNKY_WIDTH	EQU	160
dCHUNKY_HEIGHT	EQU	100


********************************************************************
	SECTION	TEXT
********************************************************************

*------------------------------------------------------------------*
* FUNCTION : Chunky_Init( void )
* ACTION   : builds chunky to pixel table (with x2 horizontal copy)
* CREATION : 16.07.01 PNK
*------------------------------------------------------------------*

Chunky_Init:
	lea		gChunkyToPixelTable,a0

	lea		gChunkyQuads3,a1
	lea		gChunkyQuads1,a2
	lea		gChunkyQuads2,a3
	lea		gChunkyQuads0,a4

.	moveq	#0,d3
.l3:
	move.l	(a1,d3.w),d4
	moveq	#0,d2
.l2:
	move.l	(a2,d2.w),d5
	or.l	d4,d5
	moveq	#0,d1
.l1:
	move.l	(a3,d1.w),d6
	or.l	d5,d6
	moveq	#0,d0
.l0:
	move.l	(a4,d0.w),d7
	or.l	d6,d7
	move.l	d7,(a0)+

	addq.l	#4,d0
	cmp.b	#(15*4),d0
	ble.s	.l0
	addq.l	#4,d1
	cmp.b	#(15*4),d1
	ble.s	.l1
	addq.l	#4,d2
	cmp.b	#(15*4),d2
	ble.s	.l2
	addq.l	#4,d3
	cmp.b	#(15*4),d3
	ble.s	.l3

	rts


*------------------------------------------------------------------*
* FUNCTION : Chunky_Clear( void )
* ACTION   : clears chunky buffer
* CREATION : 16.07.01 PNK
*------------------------------------------------------------------*

Chunky_Clear:

	lea		gChunkyBuffer,a0

	moveq	#dCHUNKY_HEIGHT-1,d1
.ly:
	moveq	#dCHUNKY_WIDTH-1,d0
.lx:
	clr.b	(a0)+
	dbra	d0,.lx
	dbra	d1,.ly

	rts


*------------------------------------------------------------------*
* FUNCTION : Chunky_FromBitplane( U16 * apDst, U16 *apSrc, U16 aWidth, U16 aHeight )
* ACTION   : clears chunky buffer
* CREATION : 16.07.01 PNK
*------------------------------------------------------------------*

Chunky_FromBitplane:

	subq.w	#1,d1
	bmi		.return
.ly:
	moveq	#0,d2
.lx:
	moveq	#$f,d7
	and.w	d2,d7
	bne.s	.notplane

	move.w	(a0)+,d3
	move.w	(a0)+,d4	
	move.w	(a0)+,d5
	move.w	(a0)+,d6
.notplane:

	moveq	#0,d7
	lsl.w	#1,d6
	bcc.s	.notb0
	addq.w	#1,d7
.notb0
	lsl.w	#1,d5
	bcc.s	.notb1
	addq.w	#2,d7
.notb1:
	lsl.w	#1,d4
	bcc.s	.notb2
	addq.w	#4,d7
.notb2:
	lsl.w	#1,d3
	bcc.s	.notb3
	addq.w	#8,d7
.notb3:
	move.b	d7,(a0)+
	addq.w	#1,d2
	cmp.w	d0,d2
	blt		.lx
	dbra	d1,.ly

.return:
	rts


*------------------------------------------------------------------*
* FUNCTION : Chunky_Render( U16 * apScreen )
* ACTION   : draws chunky buffer to screen
* CREATION : 16.07.01 PNK
*------------------------------------------------------------------*

Chunky_Render:

	lea		gChunkyBuffer,a1
	lea		gChunkyToPixelTable,a2

	move.w	#dCHUNKY_HEIGHT-1,d1
.ly:
	move.w	#(dCHUNKY_WIDTH/8)-1,d0
.lx:
	moveq	#0,d2
	move.w	(a1)+,d2
	lsl.w	#4,d2
	or.w	(a1)+,d2
	lsl.l	#2,d2
	move.l	(a2,d2.l),d2
	movep.l	d2,0(a0)
	movep.l	d2,160(a0)

	moveq	#0,d2
	move.w	(a1)+,d2
	lsl.w	#4,d2
	or.w	(a1)+,d2
	lsl.l	#2,d2
	move.l	(a2,d2.l),d2
	movep.l	d2,1(a0)
	movep.l	d2,161(a0)

	lea		8(a0),a0

	dbra	d0,.lx

	lea		((320-(dCHUNKY_WIDTH/8))/16)*8(a0),a0

	dbra	d1,.ly

	rts


********************************************************************
	SECTION	DATA
********************************************************************

gChunkyQuads3:
	dc.l	$00000000
	dc.l	$C0000000
	dc.l	$00C00000
	dc.l	$C0C00000
	dc.l	$0000C000
	dc.l	$C000C000
	dc.l	$00C0C000
	dc.l	$C0C0C000
	dc.l	$000000C0
	dc.l	$C00000C0
	dc.l	$00C000C0
	dc.l	$C0C000C0
	dc.l	$0000C0C0
	dc.l	$C000C0C0
	dc.l	$00C0C0C0
	dc.l	$C0C0C0C0
gChunkyQuads2:
	dc.l	$00000000
	dc.l	$30000000
	dc.l	$00300000
	dc.l	$30300000
	dc.l	$00003000
	dc.l	$30003000
	dc.l	$00303000
	dc.l	$30303000
	dc.l	$00000030
	dc.l	$30000030
	dc.l	$00300030
	dc.l	$30300030
	dc.l	$00003030
	dc.l	$30003030
	dc.l	$00303030
	dc.l	$30303030
gChunkyQuads1:
	dc.l	$00000000
	dc.l	$0C000000
	dc.l	$000C0000
	dc.l	$0C0C0000
	dc.l	$00000C00
	dc.l	$0C000C00
	dc.l	$000C0C00
	dc.l	$0C0C0C00
	dc.l	$0000000C
	dc.l	$0C00000C
	dc.l	$000C000C
	dc.l	$0C0C000C
	dc.l	$00000C0C
	dc.l	$0C000C0C
	dc.l	$000C0C0C
	dc.l	$0C0C0C0C
gChunkyQuads0:
	dc.l	$00000000
	dc.l	$03000000
	dc.l	$00030000
	dc.l	$03030000
	dc.l	$00000300
	dc.l	$03000300
	dc.l	$00030300
	dc.l	$03030300
	dc.l	$00000003
	dc.l	$03000003
	dc.l	$00030003
	dc.l	$03030003
	dc.l	$00000303
	dc.l	$03000303
	dc.l	$00030303
	dc.l	$03030303


********************************************************************
	SECTION	BSS
********************************************************************

gChunkyToPixelTable:	ds.l	(16*16*16*16)
gChunkyBuffer:			ds.b	(dCHUNKY_WIDTH*dCHUNKY_HEIGHT)