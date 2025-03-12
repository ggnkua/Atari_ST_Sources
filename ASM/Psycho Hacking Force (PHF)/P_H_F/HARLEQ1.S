; Harlequin Level Muzak By Baz Leitch Of Imagitec

; Ripped and Relocated to Hi-Ram By Grazey

; From The P.H.F. Of Hull

; Muzak Player relocates to $6e444

; Muzak Data relocates to $70cbe

; If ya use this zak credit me!!! DONT Be Lame!

; Press 'Space' to quit 

; All the other level muzak will be ripped/relocated within the next
; week!
		
start	opt x-
	clr.l -(sp)				
	move.w #$20,-(sp)			
	trap #1					
	lea 6(sp),sp				
	move.l d0,oldstk			
	bclr #0,$484.w				

	LEA	player,A0
        LEA	$6e444,A1
	MOVE.L	#plyend-player,D0
.reloc	MOVE.B	(A0)+,(A1)+
	DBF	D0,.reloc

	LEA	data,A0
        LEA	$70cbe,A1
	MOVE.L	#datend-data,D0
.reloc1	MOVE.B	(A0)+,(A1)+
	DBF	D0,.reloc1

	move.l	#0,d0	
	jsr	$6e444
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
	jsr	$6e562
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
player	incbin "harply.rel"			
plyend
data	incbin "har2.rel"			;Which level ?!
datend

; List Of Files

; har2.rel    	;The Clock Tower
; har3.rel	;The Clock Works
; har4.rel	;The Dream Mile
