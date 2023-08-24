; World of Wonder/NPG Zak, using the nostalgic future composer voice, aah

; By No More Of Animal Mine

; Hacked as always By Grazey/P.H.F. 

grazey	opt x-

	clr.l	-(sp)				
	move.w	#$20,-(sp)			
	trap	#1					
	lea	6(sp),sp				
	move.l	d0,stack
	bclr	#0,$484.w				

	moveq	#0,d0
	bsr	music

	move.l	#music+6,$4d2.w

	move.w	#7,-(sp)				
	trap	#1					
	lea	2(sp),sp				

	jsr	music+2

	clr.l	$4d2.w

	move.l	#$08080000,$ffff8800.w
	move.l	#$09090000,$ffff8800.w
	move.l	#$0a0a0000,$ffff8800.w

	move.l	stack,-(sp)			
	move.w	#$20,-(sp)			
	trap	#1					
	lea	6(sp),sp  				

	clr.w	-(sp)				
	trap	#1					

stack	dc.l	0
music	incbin 	worldw.mus
endmus	
