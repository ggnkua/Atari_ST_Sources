*******************************************
*	   NEW CORE OVERSCAN v1.0 	  *
*					  *
*	This ugly source was coded by	  *
*	The Gambler in January 1992.	  *
*-----------------------------------------*
* A big thanx to Belker for letting me    *
* use his STE now and then.		  *
* My computer is currently lying in pices *
* on my desk. I have been trying to put   *
* the whole machine into one of those     *
* tower cases but I haven`t been able to  *
* finish it because I have been waiting   *
* the last two months for Chara Data to   *
* get their fingers oot of their asses    *
* and send me a SCSI controller that      *
* actually works. Arrrrggghhhh!!!!!!!!!   *	
*******************************************


start	bra	real_start

TSR_start
*-------	here starts the code to be TSRed

	dc.b	"XBRASCAN"
savevbl	dc.l	1	
vbl:    clr.b   $fffffa1b.w		;Disable timer B
        move.l	a0,-(sp)
	move.l	line_a_pek,a0
        move	#29,-42(a0)
	move	#240,-4(a0)
	move	#240,-$2b2(a0)
	move.l	(sp)+,a0
	tst	$43e.w			;if disk access...
	bne.s	r„knare			;then skip overscan
	subq	#1,count
	tst	count
	bne.s	mod
	move	#1,count
	bset    #0,$fffffa07.w
        bset    #0,$fffffa13.w
        move.l  #hbl,$120.w
        move.b  #186,$fffffa21.w	;hbl at line 188
        move.b  #8,$fffffa1b.w		;enable timer B
        move.b  #17,$fffffa21.w		;makes magic
mod:	jmp	0

r„knare:
	move	#50,count
	bra.s	mod
	
count	dc.w	0

	dc.b	"XBRASCAN"
savehbl	dc.l	0
hbl:	move	#$2700,sr	;don't allow interruption
	movem.l	d0,-(sp)
	moveq.l	#0,d0
	btst.b	#7,$ffff8a3c.w
	bne	out
v„nta	cmpi.b	#11,$fffffa21.w	wait for line 192
	bne.s	v„nta
.wait	tst.b	$ffff8209.w	sync lock
	beq.s	.wait
	move.b	$ffff8209.w,d0
sync	jmp	sync+2(pc,d0.w)
	dcb.w	896,$4e71	wait 7 scanlines
	dcb.w	90,$4e71	wait until end of scanline 199
	bclr	#1,$ffff820a.w	set 60 Hz
	dcb.w	5,$4e71		let the MMU suffer for a while...
	bset	#1,$ffff820a.w	set 50 Hz
out:	move.l	(sp)+,d0
	clr.b   $fffffa21.w		;no more hbl
	clr.b   $fffffa1b.w		;Disable timer B
        bclr    #0,$fffffa0f.w		;End of hbl
        rte

line_a_pek:	ds.l	1

*-------	here ends the code to be TSRed
	EVEN
	
keep_length	EQU	*-start

real_start
	move	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	
	cmpi	#2,d0
	bge	exit
	
	dc.w	$a000
	move.l	a0,line_a_pek
	move	#29,-42(a0)
	move	#240,-4(a0)
	move	#240,-$2b2(a0)

	pea	0.w
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,oldsp

	move	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	
	move.l	d0,a1
	sub.l	#40*160,d0
	move.l	d0,$436.w	top of user ram
	move.l	d0,a0
	
	moveq	#100,d1		copy stack
copy	move	(a1)+,(a0)+
	dbra	d1,copy
	
	sub.l	#40*160,sp	flytta den
	
	move	#-1,-(sp)
	move.l	d0,-(sp)
	move.l	d0,-(sp)
	move	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	
	pea	text
	move	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	
	move	#$2700,sr
	clr.b	$fffffa1b.w
        clr.b   $fffffa21.w
        bset    #0,$fffffa07.w
        bset    #0,$fffffa13.w
        move.l  #hbl,$120.w
	move.l	$70.w,mod+2
        move.l	$70.w,savevbl
        move.l  #vbl,$70.w
	move	#$2300,sr

	move.l	oldsp,-(sp)
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

*-------	end initialisation

	clr.w	-(sp)
	move.l	#$100+keep_length,-(sp)		$100 for basepage
	move.w	#$31,-(sp)	p_termres
	trap	#1		that's the end


exit	pea	text2
	move	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	
	clr.w	-(sp)
	trap	#1
	
oldsp:	ds.l	1

text:	dc.b	27,"ETerminating lower border...",13,10,0

text2:	dc.b	13,10,"Can't remove border in this resolution!",13,10,0

