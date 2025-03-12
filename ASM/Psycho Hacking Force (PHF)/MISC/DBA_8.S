; D.B.A. 8 Intro Music

; By Iso of Sentry

; Hacked as in 1 min By Grazey/P.H.F. 

; Multiple tunes , yonder the file............

grazey	opt x-

	clr.l -(sp)				
	move.w	#$20,-(sp)			
	trap	#1					
	lea	6(sp),sp				
	move.l	d0,stack
	bclr	#0,$484.w				
	move.l	$70.w,old70

	move	#1,d0
	jsr	music

	move.l	#vbl,$70.w

	move.w	#7,-(sp)				
	trap	#1					
	lea	2(sp),sp				


	move.l	old70,$70.w

	move	#0,d0
	jsr	music

	move.l	stack,-(sp)			
	move.w	#$20,-(sp)			
	trap	#1					
	lea	6(sp),sp  				

	clr.w	-(sp)				
	trap	#1					

vbl	movem.l d0-a6,-(sp)			save registers
	jsr	music+2
	movem.l (sp)+,d0-a6			restore registers
	rte

stack	dc.l	0
old70	dc.l	0
music	incbin 	dba8_int.mus
endmus	

;dba8_int.mus
;dba8_mm.mus
