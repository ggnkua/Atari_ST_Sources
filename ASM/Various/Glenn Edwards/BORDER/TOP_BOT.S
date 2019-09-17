; Top & bottom border removal (50Hz only)
; (C)1993 Glenn Edwards
;
; This is basically a combination of the two methods used in
; TOP.S and BOTTOM.S
;

 	opt	o+
	
; If the top border flickers (or doesn't work at all!!) on your ST/STe,
; you must alter the value below. Increment it or decrement it by 1 until
; the top border is stable.

delay	EQU	1435

start	movem.l	d0-d7/a0-a6,-(sp)		;Store registers
	bsr.s	super
	bsr	setup				;Setup ST
	bsr.s	main				;Call main loop
	bsr	restore				;Restore ST
	bsr.s	user
	movem.l	(sp)+,d0-d7/a0-a6		;Restore registers
exit	clr.w	-(sp)
	trap	#1
	
main	bsr	wvbl				;Wait for VBI
	cmp.b	#$39,$fffffc02.w		;Has space been pressed?
	bne.s	main				;No, then loop
	rts

newvbi	move.w	#delay,d0			;Pause until in the correct
	dbra	d0,*				;place for Hz switch
	clr.b	$ffff820a.w			;60Hz
	nop
	nop
	nop					;Pause a while
	nop
	nop
	nop
	move.b	#2,$ffff820a.w			;50Hz

	move.b	#229,$fffffa21.w		;Interrupt on line 229
	move.b	#8,$fffffa1b.w			;Timer B event-count mode
	st	vbiflag				;Flag that vbi has occured
	rte

tmrb	eori.b	#2,$ffff820a.w			;Toggle hertz rate
	nop
	nop					;Pause a while
	nop
	nop
	eori.b	#2,$ffff820a.w			;Toggle hertz rate
	clr.b	$fffffa1b.w			;Stop timer B
	bclr	#0,$fffffa0f.w			;Signal end of interrupt
	rte

super	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1				;Enter supervisor more
	addq.l	#6,sp
	move.l	d0,oldsp
	rts
	
user	move.l	oldsp(pc),-(sp)
	move.w	#$20,-(sp)
	trap	#1				;Enter user more
	addq.l	#6,sp
	rts

setup	move.l	$44e.w,oldscr			;Store physbase
	bsr	newscr				;Setup new screen	
	movem.l	$ffff8240.w,d0-d7		;Store palette
	movem.l	d0-d7,oldpal
	movem.l	pic+4(pc),d0-d7			;Install new palette
	movem.l	d0-d7,$ffff8240.w
 	move.l	#screen1,a0
	move.l	#pic+128,a1
	move.w	#16000,d0
.loop	move.w	(a1)+,(a0)+
	dbra	d0,.loop
	move.l	$70.w,oldvbi			;Store old vbi
	move.l	#newvbi,$70.w			;Install new vbi
	move.l	$120.w,oldtmrb			;Store old timer B
	move.l	#tmrb,$120.w			;Store new timer B
	move.b	$ffff8260.w,oldres		;Store old resolution
	bsr	wvbl				;Wait for vbi
	clr.b	$ffff8260.w			;Go into low res

	move.l	$fffffa06.w,ierab		;Store MFP ierab
	move.b	$fffffa13.w,imska		;Store MFP imska
	move.b	$fffffa1b.w,tmrBctl		;Store MFP timer B ctrl

	move.b	#1,$fffffa07.w			;Enable only MFP timer B
	move.b	#1,$fffffa13.w			;Set mask to allow timer B
	clr.b	$fffffa09.w			;Stop other MFP interrupts
	rts

restore	move.b	tmrBctl(pc),$fffffa1b.w		;Restore MFP timer B ctrl
	move.b	imska(pc),$fffffa13.w		;Restore MFP imska
	move.l	ierab(pc),$fffffa06.w		;Restore MFP interrupts

	bsr	wvbl				;Wait for vbi
	move.b	oldres(pc),$ffff8260.w		;Restore old resolution
	move.l	oldtmrb(pc),$120.w		;Restore timer b
	move.l	oldvbi(pc),$70.w		;Restore old vbi
	movem.l	oldpal(pc),d0-d7		:Restore old palette
	movem.l	d0-d7,$ffff8240.w
	move.l	oldscr(pc),d0
	bsr.s	setscr				;Restore original screen
	rts

newscr	move.l	#screen1,d0			;Get address of new screen
	add.l	#256,d0
	and.l	#$ffffff00,d0			;Put on 256 byte boundary
	bsr.s	setscr				;Set screen
	rts

setscr	lsr #8,d0
	move.l d0,$ffff8200.w			;Set up new physbase
	rts		

wvbl	sf	vbiflag				;Wait for a VBI
wait	tst.w	vbiflag
	beq.s	wait
	rts

cls	movem.l	d0-d7/a0-a6,-(sp)		;Quick cls
	lea	32000(a0),a0
	moveq	#0,d1				;Clear 13 registers
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	move.l	d1,a1
	move.l	d1,a2
	move.l	d1,a3
	move.l	d1,a4
	move.l	d1,a5
	move.l	d1,a6
	move.w	#204,d0

cs_loop	movem.l	d1-d7/a1-a6,-(a0)	;do it
	movem.l	d1-d7/a1-a6,-(a0)	;3 times for a
	movem.l	d1-d7/a1-a6,-(a0)	;very minor speedup
	dbra	d0,cs_loop
	movem.l d1-d5,-(a0)		;do the odd 20 bytes (5 regs)
	movem.l	(sp)+,d0-d7/a0-a6
	rts
	
pic	incbin	"a:\ictari.neo"

	section	bss
oldpal	ds.w	16
oldscr	ds.l	1
oldvbi	ds.l	1
oldtmrb	ds.l	1
oldsp	ds.l	1
ierab	ds.l	1
vbiflag	ds.w	1
imska	ds.b	1
tmrBctl	ds.b	1
oldres	ds.b	1
	even
screen1	ds.b	40000
