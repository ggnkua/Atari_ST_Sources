; Tristar/Red Sector Incorporated Intro Music (Gonad! shading to you too!)

; By No More Of Animal Mine

; Hacked as always By Grazey/P.H.F. 

grazey	opt x+

	clr.l	-(sp)				
	move.w	#$20,-(sp)			
	trap	#1					
	lea	6(sp),sp				
	move.l	d0,stack
	bclr	#0,$484.w				
	move.l	$70.w,old70

	moveq	#0,d0
	jsr	music

	move.l	#vbl,$70.w

	move.w	#7,-(sp)				
	trap	#1					
	lea	2(sp),sp				

	jsr	music+4

	move.l	old70,$70.w
	move.l	#$08080000,$ffff8800.w
	move.l	#$09090000,$ffff8800.w
	move.l	#$0a0a0000,$ffff8800.w

	move.l	stack,-(sp)			
	move.w	#$20,-(sp)			
	trap	#1					
	lea	6(sp),sp  				

	clr.w	-(sp)				
	trap	#1					

vbl	movem.l d0-a6,-(sp)
	jsr	music+8
	movem.l (sp)+,d0-a6
	rte

stack	dc.l	0
old70	dc.l	0
music	incbin 	trsi.mus
endmus	
