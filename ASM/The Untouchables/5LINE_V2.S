; 5 line STF/M Hardware Sync-Scroller coded by Tony B!
; 31.1.1992
;
; Uses no registers!
; Not STE compatible!
;
; Well those of you who read my document in issue 7 or 8, will know
; all about this. See "6LINE_V2.S" for more info.....
;
; I don't know if this is 100% on all STF/M's (who really gives a fuck!??).
;
; The only 100% safe combinations are:-
;
;	sync0, sync70, sync44, sync24, sync26, sync_2
;
; Credit me for the border routs. I will know.......
;
; Thanks, Tony B!
;
; Tabs =10
;

	opt	d+


	movea.l	4(sp),a5
	pea	$100.w
	pea	(a5)
	pea	$4a0000
	trap	#1
	lea	12(sp),sp

	pea	0.w
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,oldstk+2
	
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,savepal

	move.l	#scr,d0
	add.l	#256,d0
	clr.b	d0
	move.l	d0,base

	move.l	base,a1
	move	#32000/4-1,d0
cls	clr.l	(a1)+
	dbf	d0,cls
	
	lea	gfx+128,a0
	move.l	base,a1
	lea	160*30(a1),a1
	move	#32000/4-1,d0
cop	move.l	(a0)+,(a1)+
	dbf	d0,cop

	clr.b	$484.w
	
	clr.b	$ffff820a.w
	move	$468.w,d0
vwait	cmp	$468.w,d0
	beq.s	vwait
	clr.b	$ffff8260.w
	move.b	#2,$ffff820a.w

	move.b	$fffffa15.w,olda15+3
	clr.b	$fffffa15.w
	move.l	$70.w,old70+2
	move.l	#vbl,$70.w
	
*------------------- main loop
main_loop
	stop	#$2300
	
	bsr	set_sync_addr
	
	move.b	$fffffc02.w,d7

	cmp.b	#$4d,d7
	bne.s	s
	addq.l	#8,addoff
s
	cmp.b	#$4b,d7
	bne.s	s2
	subq.l	#8,addoff
s2
	cmp.b	#$48,d7
	bne.s	s3
	add.l	#640,addoff
s3
	cmp.b	#$50,d7
	bne.s	s4
	sub.l	#640,addoff
s4
	cmp.b	#$39,d7
	bne.s	main_loop

*-------------------
olda15	move.b	#0,$fffffa15.w
old70	move.l	#0,$70.w
	
	movem.l	savepal,d0-d7
	movem.l	d0-d7,$ffff8240.w
	
	move.b	#-1,$484.w
	
oldstk	lea	0.l,sp

	clr	-(sp)
	trap	#1

savepal	ds.w	16


*------------------- calculate sync values!
set_sync_addr
	move.l	base(pc),d0
	add.l	addoff(pc),d0
	moveq	#0,d1
	move.b	d0,d1
	move	d1,d2
	add	d1,d1
	add	d2,d1
	lea	supertable(pc),a0
	add	d1,a0
	lea	synclist+2(pc),a1
	move.l	(a0)+,(a1)
	move.l	(a0)+,6(a1)
	move.l	(a0)+,12(a1)
	move.l	(a0)+,18(a1)
	move.l	(a0)+,24(a1)
	add.l	(a0)+,d0
	lsr	#8,d0
	move.l	d0,$ffff8200.w
	rts


*------------------ sync scroller -vbi!
vbl
	move	#$2700,sr
	
	movem.l	d0-a6,-(sp)
	
	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	move.l	d0,d7
	movem.l	d0-d7,$ffff8240.w	;please don't think i use this top
				;border technique anymore!!!!!
	dcb.w	4247,$4e71
	
	move.b	#0,$ffff820a.w
	dcb.w	6,$4e71
	move.b	#2,$ffff820a.w
	
	dcb.w	61,$4e71
	
	moveq	#96,d0
	move.b	$ffff8209.w,d1
	sub	d1,d0
	lsl	d0,d1

	dcb.w	18,$4e71
	
synclist	jsr	sync0
	jsr	sync0
	jsr	sync0
	jsr	sync0
	jsr	sync0
	
	movem.l	gfx+4,d0-d7
	movem.l	d0-d7,$ffff8240.w
	
	movem.l	(sp)+,d0-a6
	addq	#1,$468.w
	move	#$2300,sr
	rte


*------------------- border routines!
sync0
	dcb.w	119,$4e71
	rts
sync70
	nop
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb.w	87,$4e71
	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	dcb.w	7,$4e71
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w
	rts
sync26
	nop
	nop
	move.b	#2,$ffff8260.w
	nop
	nop
	nop
	move.b	#0,$ffff8260.w
	dcb.w	106,$4e71
	rts
sync44
	dcb.w	96,$4e71
	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	dcb.w	15,$4e71
	rts
sync24
	nop
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb.w	85,$4e71
	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	dcb.w	17,$4e71
	rts
sync_80
	nop
	move.b	#2,$ffff8260.w
	nop
	nop
	nop
	nop
	move.b	#0,$ffff8260.w
	dcb.w	29,$4e71
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb.w	69,$4e71
	rts
sync_2
	dcb.w	94,$4e71
	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	dcb.w	17,$4e71
	rts
sync_106
	dcb.w	41,$4e71
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb.w	70,$4e71
	rts
sync_160
	dcb.w	16,$4e71
	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	dcb.w	95,$4e71
	rts
;sync_160
;	dcb.w	10-3,$4e71
;	move.b	#2,$ffff8260.w
;	move.b	#0,$ffff8260.w
;	dcb.w	110,$4e71
;	rts


*------------------- sync vars
supertable
	dc.l	sync0,sync0,sync0,sync0,sync0,0
	dc.l	sync44,sync44,sync_80,sync0,sync0,0
	dc.l	sync70,sync26,sync_80,sync0,sync0,0
	dc.l	sync24,sync0,sync0,sync0,sync0,0
	dc.l	sync70,sync70,sync_106,sync_2,sync0,0
	dc.l	sync70,sync26,sync24,sync_80,sync0,0
	dc.l	sync24,sync24,sync0,sync0,sync0,0
	dc.l	sync44,sync44,sync24,sync24,sync_80,0
	dc.l	sync44,sync24,sync_2,sync_2,sync0,0
	dc.l	sync24,sync24,sync24,sync0,sync0,0
	dc.l	sync_160,sync_160,sync_160,sync24,sync24,512
	dc.l	sync44,sync44,sync0,sync0,sync0,0
	dc.l	sync70,sync26,sync0,sync0,sync0,0
	dc.l	sync26,sync26,sync26,sync26,sync0,0
	dc.l	sync44,sync44,sync24,sync0,sync0,0
	dc.l	sync70,sync26,sync24,sync0,sync0,0
	dc.l	sync26,sync26,sync26,sync26,sync24,0
	dc.l	sync44,sync44,sync24,sync24,sync0,0
	dc.l	sync70,sync26,sync24,sync24,sync0,0
	dc.l	sync_160,sync_160,sync_160,sync_160,sync24,768
	dc.l	sync44,sync44,sync24,sync24,sync24,0
	dc.l	sync70,sync26,sync24,sync24,sync24,0
	dc.l	sync44,sync44,sync44,sync44,sync0,0
	dc.l	sync70,sync70,sync44,sync0,sync0,0
	dc.l	sync70,sync70,sync26,sync26,sync0,0
	dc.l	sync44,sync44,sync44,sync44,sync24,0
	dc.l	sync70,sync70,sync44,sync24,sync0,0
	dc.l	sync70,sync70,sync24,sync26,sync26,0
	dc.l	sync_80,sync26,sync24,sync_2,sync0,256
	dc.l	sync44,sync24,sync24,sync70,sync70,0
	dc.l	sync_106,sync70,sync_2,sync_2,sync24,256
	dc.l	sync_2,sync_2,sync_2,sync_2,sync0,256

base	ds.l	1
addoff	ds.l	1

gfx	incbin	apic.neo

scr
