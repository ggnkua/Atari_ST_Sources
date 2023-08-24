; Wings Of Death 2 - Lethal Xcess

; By Jochen Hippel Of The Exceptions

; Ripped By Grazey From The P.H.F. Of Kingston-Upon-Hull

; Note: D0 Selects the tune and A0 points to the music data  

; D1 Selects hertz ( I think! )

; The sample drums install on 110.w 

; Credit me if ya use this zak! 


	opt x-				;ha ha ripper
	clr.l -(sp)			
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp
	bclr #0,$484.w			;shhhh


	lea store(pc),a0		;save mfp,vbl etc
	move.l $70.w,(a0)+		
	move.l $110.w,(a0)+		
	move.b $fffffa07.w,(a0)+	
	move.b $fffffa09.w,(a0)+	
	move.b $fffffa13.w,(a0)+	
	move.b $fffffa15.w,(a0)+
	move.b $fffffa17.w,(a0)+
	move.b $fffffa1d.w,(a0)+

	move.l	#egotrip,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#2,sp

	move.w	#1,d1
	lea	data,a0			; Points to data (COSO)
	move.w	#1,D0
	JSR	driver
	move.b	#$40,$fffffa17.w

	move.l	#vbl,$70.W		;Install zak on vbl


grazey	cmp.b	#$39,$ffffc02
	bne	grazey

	move.w sr,-(sp)			
	move.w #$2700,sr		
	lea store(pc),a0		
	move.l (a0)+,$70.w
	move.l (a0)+,$110.w
	clr.l	$4da.w
	move.b (a0)+,$fffffa07.w	;restore mfp
	move.b (a0)+,$fffffa09.w	
	move.b (a0)+,$fffffa13.w	
	move.b (a0)+,$fffffa15.w
	move.b (a0)+,$fffffa17.w
	move.b (a0)+,$fffffa1d.w

	lea $ffff8800.w,a0		;clr yammy
	move.l #$0707ffff,(a0)
	move.l #$08080000,(a0)
	move.l #$09090000,(a0)
	move.l #$0a0a0000,(a0)

	move.b #$c0,$fffffa23.w		
	bset #0,$484.w			
	move.w (sp)+,sr			

	clr.w -(sp)			;ta ta
	trap #1

; 	PLEASE NOTE: You must call the music as below, by that I mean
;	the vbl must end with an rte and NOT an RTS. Also don't save
;       the registers on the stack!

vbl	jsr	driver+8
	rte


store	dc.l 0,0,0,0				
driver	incbin "driver.mus"	
data	incbin "wodmain.mus"	

egotrip	dc.b	27,"E","Lethal Xcess - Wings Of Death 2 Zak",13,10,13,10
	dc.b	"By Jochen Hippel From The Exceptions",13,10,13,10
	dc.b	"Ripped By : Grazey Of The P.H.F. ",13,10,13,10
	dc.b	"( Possibly the best music ripper on the ST, modest aren't I !! )",13,10,0

; wodmain.mus		Main Menu	1 tune
; wodlev1.mus		Level 1		2 tunes		
; wodlev2.mus		Level 2		1 tune		
; wodlev3.mus		Level 3		1 tune
; wodlev4.mus		Level 4		1 tune		
; wodlev5.mus		Level 5		1 tune		
