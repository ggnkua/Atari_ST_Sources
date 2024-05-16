; Dr Who By ????

; Music Hacked by the best GRZ/PHF

; Blimey! A commercial game using Mega tizer/sweat/twong/takzo music

; Precals suck, realtime rules

; Multiple Tunes check the bottom of this file for the names!
; Remember to change the tempo value!!


	opt x-
	clr.l	-(sp)				
	move.w	#$20,-(sp)			
	trap	#1					
	lea	6(sp),sp				
	move.l	d0,oldstk			
	bclr	#0,$484.w
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,oldcols
	jsr	bars

	move	tempo,music+$204
	move	tempo,music+$4bc
	move	tempo,music+$772

	jsr	music

	move.l $70.w,oldint			
	move.l #yoho,$70.w			

	move.w	#7,-(sp)				
	trap	#1					
	lea	2(sp),sp				

	move.l oldint,$70.w			
	move.l #$08080000,$ffff8800.w		
	move.l #$09090000,$ffff8800.w	
	move.l #$0a0a0000,$ffff8800.w

	movem.l	oldcols,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.l	oldstk,-(sp)			
	move.w	#$20,-(sp)			
	trap	#1					
	lea	6(sp),sp  				
	clr.w	-(sp)				
	trap	#1			

yoho	movem.l d0-a6,-(sp)			
	jsr	music+8
	jsr	bars+186
	jsr	bars+298
	movem.l (sp)+,d0-a6			
	rte

oldcols	ds.w	16
oldstk	dc.l	0
oldint	dc.l	0
tempo	dc.w	6
bars	incbin	bars.bin
music	incbin	barrs		;makers of Tizer
	incbin	dr_who1.mus
endmus

;name		tempo value (change above)

;dr_who1.mus	6
;dr_who2.mus	6
;dr_who3.mus	5
;dr_who4.mus	4
;dr_who5.mus	7
;dr_who6.mus	5
;dr_who7.mus	5
