;*******************************************************************
;*                                                                 *
;* Published in the Ledgers Disk Magazine Volume 8                 *
;*                                           Release Date : 1/2/92 *
;*                                                                 *
;*******************************************************************

; Sample Replay Routine for signed/un-signed samples at any KHz.
; Plays back on Timer D, so it's fully interruptable!!
; Uses the USP.
; Takes about 15% CPU time, at 7.68KHz.
; Coded by Tony B!
; DevPac v2.25, tabs set to 10



diskversion	=	-1


	opt	o+

	IIF	diskversion	opt	x+



	movea.l	4(sp),a5
	pea	$200.w
	pea	(a5)
	pea	$4a0000
	trap	#1
	lea	12(sp),sp

	pea	0.w
	move	#32,-(sp)
	trap	#1
	addq	#6,sp
	move.l	d0,oldstk+2
	
	move.b	#$12,$fffffc02.w
	clr.b	$484.w
	
*------------------- pre-sign sample data
	lea	sample(pc),a1
presign
	eor.b	#128,(a1)+
	cmpa.l	#eof_sample,a1
	bne.s	presign


*------------------- init the sound chip!

	lea	$ffff8800.w,a0
	moveq	#10,d0
set_ym
	move.b	d0,(a0)
	clr.b	2(a0)
	dbf	d0,set_ym
	move.b	#7,(a0)
	move.b	d0,2(a0)

*-------------------
	bsr	set_ints
*-------------------
	
scan
	bsr.s	vsync

	cmp.b	#57,$fffffc02.w
	bne.s	scan


*-------------------
	bsr	rem_ints
	
	lea	$ffff8800.w,a0
	move.l	#$0700ff00,(a0)
	move.l	#$08000000,(a0)
	move.l	#$09000000,(a0)
	move.l	#$0a000000,(a0)

	move.b	#-1,$484.w
	
	move.b	#8,$fffffc02.w


oldstk	lea	0.l,sp

	ifne	diskversion
	clr	-(sp)
	move	#11,-(sp)
	trap	#13		;Alt-X cure!
	addq	#4,sp
	endc

	clr	-(sp)
	trap	#1



*-------------------
vsync
	move	$468.w,d0
.vsync
	cmp	$468.w,d0
	beq.s	.vsync
	rts


*------------------- Timer D interrupt sample routine!
; sample in a6
timer_d
	pea	(a6)
	move.l	d7,-(sp)
	
	moveq	#0,d7
	move.l	usp,a6
	move.b	(a6)+,d7
	cmpa.l	#eof_sample,a6
	bne.s	.ok
	lea	sample(pc),a6
	move.b	(a6)+,d7
.ok
	move.l	a6,usp
	
	lsl	#3,d7
	lea	$ffff8800.w,a6
	move	s_table+4(pc,d7.w),(a6)
	move.l	s_table(pc,d7.w),d7
	movep.l	d7,(a6)
	
	move.l	(sp)+,d7
	move.l	(sp)+,a6
	rte

*------------------- vbl interrupt
vbi
	clr.b	$fffffa1d.w
	move.b	#32,$fffffa25.w	;61.44/7.68*4
	move.b	#2,$fffffa1d.w
	
	addq	#1,$468.w
	rte

s_table	incbin	look_up.tab

*-------------------
set_ints
	bsr	vsync
	move	#$2700,sr
	move.b	$fffffa09.w,mfp9+3
	move.b	$fffffa15.w,mfp15+3
	move.b	$fffffa1d.w,mfp1d+3
	move.b	$fffffa25.w,mfp25+3
	move.l	$110.w,int110+2
	move.l	$70.w,int70+2
	move.l	#vbi,$70.w
	move.l	#timer_d,$110.w
	clr.b	$fffffa1d.w
	bset	#4,$fffffa09.w
	bset	#4,$fffffa15.w
	bclr	#3,$fffffa17.w
	
	move.l	usp,a6
	move.l	a6,oldusp
	lea	sample(pc),a6
	move.l	a6,usp
	move	#$2300,sr
	rts


*-------------------
rem_ints
	bsr	vsync
	move	#$2700,sr
mfp9	move.b	#0,$fffffa09.w
mfp15	move.b	#0,$fffffa15.w
mfp1d	move.b	#0,$fffffa1d.w
mfp25	move.b	#0,$fffffa25.w
int70	move.l	#0,$70.w
int110	move.l	#0,$110.w
	bset	#3,$fffffa17.w
	
	move.l	oldusp,a6
	move.l	a6,usp
	move	#$2300,sr
	rts


*------------------- data

oldusp	ds.l	1

sample	incbin	tcb.spl
eof_sample

