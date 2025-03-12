; Legends Of Valour 

; By that old timer Ben Daglish

; Hacked in 1 min by Grazey of PHF! ( Portly Hull Fan ??? )

; Credit me if ya use this zak

; Multiple Tunes 
; ==============

grazey	opt x-

	clr.l	-(sp)				
	move.w	#$20,-(sp)			
	trap	#1					
	lea	6(sp),sp				
	move.l	d0,stack+2
	bclr	#0,$484.w				

	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,oldcols
	bsr	bars

	moveq	#5,d0		;Tunes 0-6
	bsr	music

	move.l	#music+4,$4d2.w
	move.l	#ull,$4da.w

	move.w	#7,-(sp)				
	trap	#1					
	lea	2(sp),sp				

	clr.l	$4d2.w
	clr.l	$4da.w
	movem.l	oldcols,d0-d7
	movem.l	d0-d7,$ffff8240.w

	clr	d0
	bsr	music

stack	move.l	#0,-(sp)			
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

music	incbin 	lov.mus
endmus	


