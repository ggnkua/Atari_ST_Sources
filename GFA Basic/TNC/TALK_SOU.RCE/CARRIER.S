* CARRIERINTRO MUSIC - ALLOY.B MèSTE LADDAS IN Pè ADDRESS $37F60
*                    - ALLOY.DTA MèSTE LADDAS IN Pè ADDRES $62000
* RIPPED BY REDHEAD
* MUZAX ON = JSR $37FE6
* VBL = JSR $38ED2

	clr.l -(a7)
	move.w #$20,-(a7)
	trap #1
	addq.l #6,a7
	move.l d0,save_usp
	
	pea init_msg
	move.w #9,-(a7)
	trap #1
	addq.l #6,a7

	move.w #0,-(a7)
	pea falloy
	move.w #$3d,-(a7)
	trap #1
	add.l #8,a7
	move.w d0,d7
	
	move.l #$37f60,-(a7)
	move.l #8000,-(a7)
	move.w d7,-(a7)
	move.w #$3f,-(a7)
	trap #1
	add.l #12,a7
	
	move.w d7,-(a7)
	move.w #$3e,-(a7)
	trap #1
	addq.l #4,a7

	move.w #0,-(a7)
	pea fdta
	move.w #$3d,-(a7)
	trap #1
	add.l #8,a7
	move.w d0,d7
	
	move.l #$60000,-(a7)
	move.l #8192,-(a7)
	move.w d7,-(a7)
	move.w #$3f,-(a7)
	trap #1
	add.l #12,a7
	
	move.w d7,-(a7)
	move.w #$3e,-(a7)
	trap #1
	addq.l #4,a7

	move.w #2,-(a7)
	trap #14
	addq.l #2,a7
	move.l d0,phys_bas

	bsr init

	jsr $37fe6
	move.w #$2700,sr
	move.l $70,save_vbl
	move.l #vbl,$70
	move.w #$2300,sr
waitloop	move.b $fffffc02.w,d0
	cmp.b #185,d0
	bne waitloop
	
	move.w #$2700,sr
	move.l save_vbl,$70
	move.l save_usp,-(a7)
	move.w #$20,-(a7)
	trap #1
	addq.l #6,a7
	move.w #0,-(a7)
	trap #1

save_vbl	dc.l 0
save_usp	dc.l 0

vbl	movem.l d0-d7/a0-a6,-(a7)

	jsr $38ed2

	move.l phys_bas,a0
	add.l #5160,a0

* Channel A Volume

	move.b #8,$ffff8800.w
	move.b $ffff8800.w,d0
	and.w #$f,d0
	move.w d0,d1
	move.l a0,a1
	move.w olda,d2
	cmp.b d0,d2
	beq chanb
	blt chanainc

	and.l #$f,d2
	mulu.w #240,d2
	sub.l d2,a1
	move.w #0,(a1)
	move.w #0,80(a1)
	subq.w #1,olda
	bra chanb

chanainc	and.l #$f,d2
	mulu.w #240,d2
	sub.l d2,a1
	move.w #-2,-160(a1)
	move.w #-2,-240(a1)
	addq.w #1,olda

* Channel B Volume

chanb	addq.l #2,a0
	move.b #9,$ffff8800.w
	move.b $ffff8800.w,d0
	and.w #$f,d0
	move.w d0,d1
	move.l a0,a1
	move.w oldb,d2
	cmp.b d0,d2
	beq chanc
	blt chanbinc

	and.l #$f,d2
	mulu.w #240,d2
	sub.l d2,a1
	move.w #0,(a1)
	move.w #0,80(a1)
	subq.w #1,oldb
	bra chanc

chanbinc	and.l #$f,d2
	mulu.w #240,d2
	sub.l d2,a1
	move.w #-2,-160(a1)
	move.w #-2,-240(a1)
	addq.w #1,oldb

* Channel C Volume

chanc	addq.l #2,a0
	move.b #$a,$ffff8800.w
	move.b $ffff8800.w,d0
	and.w #$f,d0
	move.w d0,d1
	move.l a0,a1
	move.w oldc,d2
	cmp.b d0,d2
	beq retest
	blt chancinc

	and.l #$f,d2
	mulu.w #240,d2
	sub.l d2,a1
	move.w #0,(a1)
	move.w #0,80(a1)
	subq.w #1,oldc
	bra retest

chancinc	and.l #$f,d2
	mulu.w #240,d2
	sub.l d2,a1
	move.w #-2,-160(a1)
	move.w #-2,-240(a1)
	addq.w #1,oldc

retest	move.l lastfreq,a1
	move.w #0,(a1)
	move.b #0,$ffff8800.w
	move.b $ffff8800.w,d0
	and.l #$ff,d0
	mulu.w #80,d0
	move.l phys_bas,a0
	add.l d0,a0
	move.w #-2,(a0)
	move.l a0,lastfreq
	movem.l (a7)+,d0-d7/a0-a6
	rte

init	move.l phys_bas,a0
	add.l #5160,a0
	move.w #15,d0
initloop	move.w #-2,(a0)
	move.w #-2,80(a0)
	move.w #-2,2(a0)
	move.w #-2,82(a0)
	move.w #-2,4(a0)
	move.w #-2,84(a0)
	lea -240(a0),a0
	dbra d0,initloop
	rts

olda	dc.w 15
oldb	dc.w 15
oldc	dc.w 15
lastfreq	dc.l initval
initval	dc.w 0

phys_bas	dc.l 0
falloy	dc.b "alloy.b",0
fdta	dc.b "carrier.dta",0
init_msg	dc.b 27,"E",0