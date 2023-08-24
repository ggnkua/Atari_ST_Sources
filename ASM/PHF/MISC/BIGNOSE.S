;big nose music ripped by hot knife

	opt x+					
	clr.l -(sp)				
	move.w #$20,-(sp)			
	trap #1					
	lea 6(sp),sp				
	move.l d0,oldstk			
	bclr #0,$484.w				
	move.l	#1,d1
	clr.l d0
	jsr	music


        
	bsr	on
	move.w #7,-(sp)				
	trap #1					
	lea 2(sp),sp				

	bsr off

	move.l oldstk,-(sp)			
	move.w #$20,-(sp)			
	trap #1					
	lea 6(sp),sp  				
	clr.w -(sp)				
	trap #1			

yoho	movem.l d0-a6,-(sp)			
	jsr	music+4
	movem.l (sp)+,d0-a6			
	move.l oldint,-(sp)			
	rts					

on	move.l $70.w,oldint			
	move.l #yoho,$70.w			
	rts

off	move.l oldint,$70.w			
	move.l #$08080000,$ff8800		
	move.l #$09090000,$ff8800		
	move.l #$0a0a0000,$ff8800		
	rts

oldstk	dc.l 0
oldint	dc.l 0
music	incbin "bignose.mus"			
enmus
