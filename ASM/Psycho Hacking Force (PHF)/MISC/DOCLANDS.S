; Zoundragger/Mill Bros. Driver Zaks By Doclands/OVR

; - From the rather excellent 'The Never & Forever Demo'

; God, if this is what Stew can do in GFA, then don't for heavens sake
; give this guy an assembler otherwise Nick & Vincent (The Tops) best
; watch out.

; Musics Hacked by the best GRZ/PHF

; Frqbars by Grz

; Multiple zak files, yonder the file

	opt	x-
	clr.l	-(sp)				
	move.w	#$20,-(sp)			
	trap	#1					
	lea	6(sp),sp				
	move.l	d0,oldstk			
	bclr	#0,$484.w
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,oldcols
	jsr	bars
	clr.l	d0
	clr.l	d1
	clr.l	d2
	clr.l	d3
	clr.l	d4
	clr.l	d5
	clr.l	d6
	clr.l	d7
	move.l	#0,a0
	move.l	#0,a1
	move.l	#0,a2
	move.l	#0,a3
	move.l	#0,a4
	move.l	#0,a5
	move.l	#0,a6
	jsr	music
	move.l	#music+8,$4d6.w

	move.l $70.w,oldint			
	move.l #yoho,$70.w			

	move.w	#7,-(sp)				
	trap	#1					
	lea	2(sp),sp				

	move.l	oldint,$70.w
	clr.l	$4d6.w
	jsr	music+4
	move.l	#$08080000,$ffff8800.w		
	move.l	#09090000,$ffff8800.w	
	move.l	#$0a0a0000,$ffff8800.w

	movem.l	oldcols,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.l	oldstk,-(sp)			
	move.w	#$20,-(sp)			
	trap	#1					
	lea	6(sp),sp  				
	clr.w	-(sp)				
	trap	#1			

yoho	movem.l d0-a6,-(sp)			
	jsr	bars+186
	jsr	bars+298
	movem.l (sp)+,d0-a6			
	move.l oldint,-(sp)			
	rts					

oldcols	ds.w 16
oldstk	dc.l 0
oldint	dc.l 0
bars	incbin bars.bin
music	incbin docland2.mus
enmus

;list of ye ole files

;docland1.mus
;docland2.mus
;docland3.mus	;Also ED mainmenu

