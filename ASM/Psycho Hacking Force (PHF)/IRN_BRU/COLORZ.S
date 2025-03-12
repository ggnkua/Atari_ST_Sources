; Colorz trackmo / Hemoroids

; Hacked in 15 seconds using Monst3 by the best GRZ/P.H.F. 

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

	moveq	#1,d0
	bsr	music

	move.l	#music+8,$4d2.w
	move.l	#ull,$4da.w
	move	#7,-(sp)				
	trap	#1					
	lea	2(sp),sp				

	clr.l	$4d2.w
	clr.l	$4da.w
	movem.l	oldcols,d0-d7
	movem.l	d0-d7,$ffff8240.w
	clr	d0
	bsr	music

stack	move.l	#stack,-(sp)			
	move	#$20,-(sp)			
	trap	#1					
	lea	6(sp),sp  				

	clr	-(sp)				
	trap	#1					

ull	bsr	bars+186
	bsr	bars+298
	rts

oldcols	ds.w	16
bars	incbin	bars.bin
music	incbin 	barrs
	incbin	colorz.mus
endmus	



