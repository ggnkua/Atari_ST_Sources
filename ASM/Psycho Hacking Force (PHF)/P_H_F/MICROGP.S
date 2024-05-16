; Microprose Grand Prix By Dave Lowe

; Hey Wild Bill! why did n't you use the tracker music which the Amiga 
; version used! Surely you could run that intro with tracker music!

; At least Geoff had nothing to do with it, he just wrote the cool game.

; Ripped By Grazey Of The P.H.F.

; If ya use this zak credit me!

		
	opt s-,x+				
	clr.l -(sp)				
	move.w #$20,-(sp)			
	trap #1					
	lea 6(sp),sp				
	move.l d0,oldstk			
	bclr #0,$484.w				

	LEA	music,A0
	LEA	$6dd00,A1
	MOVE.L	#enmus-music,D0
muslup	MOVE.B	(A0)+,(A1)+
	DBF	D0,muslup
	jsr	$6de2c
        
	bsr	on

	move.w #7,-(sp)				
	trap #1					
	lea 2(sp),sp				

s	bsr off

	move.l oldstk,-(sp)			
	move.w #$20,-(sp)			
	trap #1					
	lea 6(sp),sp  				
	clr.w -(sp)				
	trap #1					

yoho	movem.l d0-a6,-(sp)			
	jsr	$6e01e
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
music	incbin "microgp.mus"			
enmus
