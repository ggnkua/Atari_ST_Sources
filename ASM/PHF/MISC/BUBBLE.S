; Bubble Bobble Music.

; Dead old but I like it!, I've no idea who composed it,
; (probably some Japanese geezer at Taito )

; Hacked by the best GRZ/PHF

; Made PC-Relative Using GSR V3.2

; Frqbars by Grz

; Multiple zak files yonder the file

	opt x+
	clr.l	-(sp)				
	move.w	#$20,-(sp)			
	trap	#1					
	lea	6(sp),sp				
	move.l	d0,oldstk			
	bclr	#0,$484.w
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,oldcols
	jsr	bars
	jsr	music
	move.b	#0,music+$458+$182		;TUNES 0-8
	jsr	music+4
	jsr	music+8

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
	move.l oldint,-(sp)			
	rts					

oldcols	ds.w 16
oldstk	dc.l 0
oldint	dc.l 0
bars	incbin bars.bin
music	incbin bubble.mus
enmus

