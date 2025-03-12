; Harlequin Main Theme Muzak By Baz Leitch Of Imagitec

; Ripped and Relocated to Hi-Ram By Grazey

; From The P.H.F. Of Hull

; Muzak relocates to $63936

; If ya use this zak credit me!!!

; Press 'Space' to quit 
		
	opt x-
	clr.l -(sp)				
	move.w #$20,-(sp)			
	trap #1					
	lea 6(sp),sp				
	move.l d0,oldstk			
	bclr #0,$484.w				

	LEA	music,A0
        LEA	$63936,A1
	MOVE.L	#enmus-music,D0
muslup	MOVE.B	(A0)+,(A1)+
	DBF	D0,muslup

	move.l	#0,d0	
	jsr	$63936
	bsr	are

grz	cmp.b	#$39,$fffc02
	bne	grz

	bsr 	back

	move.l oldstk,-(sp)			
	move.w #$20,-(sp)			
	trap #1					
	lea 6(sp),sp  				
	clr.w -(sp)				
	trap #1					

tigers	movem.l d0-a6,-(sp)			
	jsr	$63a56
	movem.l (sp)+,d0-a6			
	move.l oldint,-(sp)			
	rts					

are	move.l $70.w,oldint			
	move.l #tigers,$70.w			
	rts

back	move.l oldint,$70.w			
	move.l #$08080000,$ff8800		
	move.l #$09090000,$ff8800		
	move.l #$0a0a0000,$ff8800		
	rts

oldstk	dc.l 0
oldint	dc.l 0
music	incbin "har1.rel"			
enmus

