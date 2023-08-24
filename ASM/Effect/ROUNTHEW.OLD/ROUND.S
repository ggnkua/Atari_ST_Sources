; Around The World, presented by Floopyshop

; Hacked by Tronic of Tronic PDL of Sunset

; If ya use this zak, credit me!

; Write to me; 10 BEECHWOOD, CHURCH HILL, CATERHAM, SURREY. CR3 6SB. U.K.

	opt	x-
	clr.l	-(sp)			;Super mode
	move.w	#$20,-(sp)			
	trap	#1					
	lea	6(sp),sp				
	move.l	d0,oldstk			
	bclr	#0,$484.w		;Kill click	

	moveq	#0,d0
	bsr	music			;Relocation

	move.l	$70.w,old70		;Save old vbl
	move.l	#vbl,$70.w		;Install my new vbl	

	move.w	#8,-(sp)		;Wait for a key press	
	trap	#1					
	lea	2(sp),sp				

	bsr	music+2			;Restore MFP

	move.l	old70,$70.w		;Restore old vbl

	move.l	oldstk,-(sp)			
	move.w	#$20,-(sp)		;User mode	
	trap	#1					
	lea	6(sp),sp  				

	clr.w	-(sp)			;See yooo	
	trap	#1		
			
vbl	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#$fff,d0
loop	dbf	d0,loop
  
 	move.w	#$735,$ffff8240.w
	jsr	music+6
	move.w	#$777,$ffff8240.w
	movem.l	(sp)+,d0-d7/a0-a6
	rte


col	ds.l	8
oldstk	dc.l	0
old70	dc.l	0

music	incbin "round.mus"		
zx

