; Great British International ST Coding Party

; Zaks By Various

; Musics Hacked by the best GRZ/PHF

; Frqbars by Grz

; Multiple zak files yonder the file
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
music	incbin	barrs		; Makes Tizer
	incbin	gb_tm.mus
enmus
;name		screen				tempo value (change above)

; gb_dt.mus	;Digitallis			6
; gb_m4.mus	;Mega 4 - By Powapixel		8
; gb_m4_1.mus	;Mega 4 - By Powapixel		5
; gb_ei.mus	;Electronic Images - By Rhino?	6
; gb_tm.mus	;Torment - By Rhino		6
