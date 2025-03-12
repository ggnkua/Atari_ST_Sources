; Electras' Party Invite Screen Music

; By Scavenger Of Synergy

; Hacked By The best : Grazey From The PHF!

; Why is this music in GSR format you may be asking ?

; Well, normally I'd use the Independents' 'SID' player ( as used by
; No More ) which automatically relocates the player on initialisation.
; But for some reason or another when I put the TSSS and TSST files
; into the player some of the samples fucked and sounded rather hissy.
; So instead I've ripped the player which came with the song and now
; it sounds perfect! The only drawback is that it's now an extra
; $182 bytes long!!

; If you use this music credit me or die.........

; Hi to the best zak hackers :

; Vapour, Clog, Wanderer, Xer, Ozz, Mug, Chris, Dr C., Hedgehog.


hullcity
	opt x-

	clr.l	-(sp)				
	move.w	#$20,-(sp)			
	trap	#1					
	lea	6(sp),sp				
	move.l	d0,stack
	bclr	#0,$484.w				

	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,col
	clr	$ffff8240.w
 	bsr	bars

	lea	yikes,a0
	move.l	$70.w,(a0)+
	move.l	$114.w,(a0)+
	move.b	$fffffa07.w,(a0)+
	move.b	$fffffa09.w,(a0)+
	move.b	$fffffa13.w,(a0)+
	move.b	$fffffa15.w,(a0)+
	move.b	$fffffa17.w,(a0)+
	move.b	$fffffa1d.w,(a0)+

	bsr	music

	bsr	music+4
	bsr	music+12
	bsr	music+16

	move.l	#vbl,$70.w
	
.ull	cmp.b	#$39,$fffffc02.w
	bne.s	.ull

	movem.l	col,d0-d7
	movem.l	d0-d7,$ffff8240.w
	
	lea	yikes,a0
	move.l	(a0)+,$70.w
	move.l	(a0)+,$114.w
	move.b	(a0)+,$fffffa07.w
	move.b	(a0)+,$fffffa09.w
	move.b	(a0)+,$fffffa13.w
	move.b	(a0)+,$fffffa15.w
	move.b	(a0)+,$fffffa17.w
	move.b	(a0)+,$fffffa1d.w
	jsr	music+$4ee

	move.l	stack,-(sp)			
	move.w	#$20,-(sp)			
	trap	#1					
	lea	6(sp),sp  				

	clr.w	-(sp)				
	trap	#1					

vbl	movem.l d0-a6,-(sp)
	jsr	music+8(pc)
	bsr	bars+186
	bsr	bars+298
	movem.l (sp)+,d0-a6
	rte

stack	dc.l	0
yikes	ds.l	4
col	ds.l	8
bars	incbin 	bars.bin
music	incbin 	scavelec.gsr
endmus	
