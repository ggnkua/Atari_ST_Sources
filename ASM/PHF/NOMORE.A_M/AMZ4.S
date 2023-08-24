; Amazine 4 Animal Mine Intro

; By No More Of Animal Mine

; Hacked using Monst3 by the best GRZ/P.H.F. 

grazey	opt x-

	clr.l	-(sp)				
	move	#$20,-(sp)			
	trap	#1					
	lea	6(sp),sp				
	move.l	d0,stack+2
	bclr	#0,$484.w				
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,oldcols
	bsr	bars

	moveq	#0,d0
	jsr	music(pc)

	move.l	#music+6,$4d2.w
	move.l	#ull,$4da.w
	move	#7,-(sp)				
	trap	#1					
	lea	2(sp),sp				

	jsr	music+2(pc)
	clr.l	$4d2.w
	clr.l	$4da.w
	movem.l	oldcols,d0-d7
	movem.l	d0-d7,$ffff8240.w

stack	move.l	#stack,-(sp)			
	move	#$20,-(sp)			
	trap	#1					
	lea	6(sp),sp  				

	clr	-(sp)				
	trap	#1					

ull	jsr	bars+186
	jsr	bars+298
	rts

oldcols	ds.w	16
bars	incbin	bars.bin
music	incbin 	sid
	incbin	amz4.mus
endmus	



