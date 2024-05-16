; Zool Title Music

; By Patrick Phelan

; Hacked in 2 mins by Grazey of PHF! ( Portly Hull Fan ??? )

; Made PCR in 15 mins using G.S.R. V3.2

; Credit me if ya use this zak

; We're going up as fuckin champions.....

; Multiple Tunes , go to the end of this file.....
; ==============

grazey	opt x+

	clr.l	-(sp)				
	move.w	#$20,-(sp)			
	trap	#1					
	lea	6(sp),sp				
	move.l	d0,stack+2
	bclr	#0,$484.w				

	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,oldcols
	bsr	bars

	bsr	music
	sub.l	#$1a678,music+$5d4
	add.l	#music+$182,music+$5d4
	sub.l	#$1a678,music+$182+$2b0
	add.l	#music+$182,music+$182+$2b0
	sub.l	#$1a678,music+$182+$3be
	add.l	#music+$182,music+$182+$3be
 	jsr	music+4
	jsr	music+4
	jsr	music+4
	jsr	music+4
	move.l	#music+4,$4d2.w
	move.l	#ull,$4da.w

	move.w	#7,-(sp)				
	trap	#1					
	lea	2(sp),sp				

	clr.l	$4d2.w
	clr.l	$4da.w
	movem.l	oldcols,d0-d7
	movem.l	d0-d7,$ffff8240.w

	move	#$3f,d0
	moveq	#7,d1
	bsr	music+$8fa

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

music	incbin 	phelan.drv
spc	incbin	zooltitl.mus
endmus	

; Filenames

; zooltitl.mus		Title Zak
; zoolrock.mus		Rock Zak
; zoolfunk.mus		Funk Zak
; zoolgren.mus		Green Zak
; zoolrave.mus		Rave Zak

