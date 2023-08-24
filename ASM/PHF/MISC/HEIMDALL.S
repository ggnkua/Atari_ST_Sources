; Heimdall By 4-Mat Of Anarchy

; Hacked And Made PC-Relative By the best GRZ/PHF

; Credit me if you use this music

; I know this music is over 30k long but I couldn't be bothered to move
; all the relevant code into one bit of memory. But what I have done is
; blank all the superflous data areas so it should pack alot better.

	opt	x-
	clr.l	-(sp)			;Super mode
	move.w	#$20,-(sp)			
	trap	#1					
	lea	6(sp),sp				
	move.l	d0,oldstk			
	bclr	#0,$484.w		;Kill click	
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,oldcols
	jsr	bars

	jsr	music

	jsr	music+12
	clr	d0
	jsr	music+4
	jsr	music+8
			
	move.l	$70.w,old70		;Save old vbl
	move.l	#grazey,$70.w		;Install my new vbl	

	move.w	#8,-(sp)		;Wait for a key press	
	trap	#1					
	lea	2(sp),sp				

	move.l	old70,$70.w		;Restore old vbl
	move.l	#$08080000,$ffff8800.w	;Clear sound registers	
	move.l	#$09090000,$ffff8800.w		
	move.l	#$0a0a0000,$ffff8800.w		
	movem.l	oldcols,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.l	oldstk,-(sp)			

	move.w	#$20,-(sp)		;User mode	
	trap	#1					
	lea	6(sp),sp  				

	clr.w	-(sp)			;See yooo	
	trap	#1		
			
grazey	movem.l	d0-a6,-(sp)
	tst.b	$2309.w
	beq	.ll
	jsr	music+8
.ll	tst.b	$22ae.w
	bne.s	.ll2
	jsr	music+12
.ll2	jsr	bars+186
	jsr	bars+298
	movem.l	(sp)+,d0-a6
	move.l	old70,-(sp)
	rts

oldstk	dc.l	0
old70	dc.l	0
oldcols	ds.w	16
bars	incbin	bars.bin
music	incbin	heimdall.mus
endmus


