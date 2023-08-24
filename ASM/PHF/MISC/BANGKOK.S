; Bangkok Knights

; By Rob Hubbard and Matt Gray

; ST Conversion By Big Alec From Delta Force

; Thanks to Big Alec for sending me this new music, and yes I did have
; hack it as it was originally in a prg file!!

; Hacked in under 1 minute using Monst 3 by 
; Grazey From The P.H.F. Of Kingston Upon Hull

; Credit me if ya use this zak!

; Bar code also by Grazey


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

	moveq	#1,d0
	jsr	music

	move.l	#vbl,$70.w
	
	move.w	#7,-(sp)				
	trap	#1					
	lea	2(sp),sp				


	move.l	old70,$70.w
	movem.l	col,d0-d7
	movem.l	d0-d7,$ffff8240.w
	clr	d0
	jsr	music


	move.l	stack,-(sp)			
	move.w	#$20,-(sp)			
	trap	#1					
	lea	6(sp),sp  				

	clr.w	-(sp)				
	trap	#1					


vbl	movem.l d0-a6,-(sp)			save registers
	jsr	music+8
	jsr	bars+186
	jsr	bars+298
	movem.l (sp)+,d0-a6			restore registers
	rte

stack	dc.l	0
old70	dc.l	0
col	ds.l	8
bars	incbin 	bars.bin
music	incbin 	bangkok.mus
endmus	
