; Streetfighter 2

; King of the beatemup ? Like hellas like! Try Body Blows or IK+

; Hacked in under 5 minutes using Monst by 
; Grazey From The P.H.F. Of Kingston Upon Hull

; Made PC-Relative with GSR V3.1

; Credit me if ya use this zak!

; Bar code also by Grazey

; Multiple Tunes

grazey	opt x+

	clr.l -(sp)				
	move.w	#$20,-(sp)			
	trap	#1					
	lea	6(sp),sp				
	move.l	d0,stack
	bclr	#0,$484.w				

	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,col
	clr.w	$ffff8240.w
	jsr	bars

	move.l	$70.w,old70

	jsr	music
	jsr	music+$22c
	move.w	#3,music+$180+10		;Tunes 1-5
	jsr	music+$180+$d8
	jsr	music+$318

	move.l	#vbl,$70.w
	
	move.w	#7,-(sp)				
	trap	#1					
	lea	2(sp),sp				


	move.l	old70,$70.w
	movem.l	col,d0-d7
	movem.l	d0-d7,$ffff8240.w
	jsr	music+$22c

	move.l	stack,-(sp)			
	move.w	#$20,-(sp)			
	trap	#1					
	lea	6(sp),sp  				

	clr.w	-(sp)				
	trap	#1					


vbl	movem.l d0-a6,-(sp)			save registers
	jsr	music+$318
	jsr	bars+186
	jsr	bars+298
	movem.l (sp)+,d0-a6			restore registers
	rte

stack	dc.l	0
old70	dc.l	0
col	ds.l	8
bars	incbin 	bars.bin
music	incbin 	sf2.gsr
endmus	








