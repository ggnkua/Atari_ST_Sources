
;Create preshifted graphics used for fonts and scroller

	SECTION	TEXT

;----------------------------------
;Create preshifts
preshiftinit
	bsr		preshiftcalcscorelarge			;Create score font preshifts
	bsr		preshiftcalcscoresmall
	bsr		preshiftcalcsparkles			;Create sparkle preshifts
	
	moveq.w	#6,d0							;Create constant preshifts for pipes
	lea		pipetopimg,a0
	lea		pipetoppreshift,a1
	bsr		preshiftcalcpipe

	moveq.w	#5,d0
	lea		pipebottomimg,a0
	lea		pipebottompreshift,a1
	bsr		preshiftcalcpipe

	moveq.w	#5,d0
	lea		pipecapspr,a0
	lea		pipecappreshift,a1
	bra		preshiftcalcpipespr				;(does RTS)

;----------------------------------
;Preshift large score font
preshiftcalcscorelarge
	lea		scorelargespr,a0
	lea		scorelargepreshift,a1
	
	moveq.w	#10-1,d2						;10 digits
.loop	

	moveq.w	#18-1,d3						;Font height
.loop2
	move.l	#$ffff0000,d0					;Clear Mask and Plane 1 registers
	moveq.l	#0,d1
	move.w	(a0)+,d0						;Read Mask and Plane 1
	move.w	(a0)+,d1
	move.l	a1,a2							;Copy destination for preshift loop

	moveq.w	#8-1,d4							;Preshift line for each X offset (even)
.loop3
	move.w	d0,(a2)+						;Write first word of Mask
	move.w	d1,(a2)+						;Write first word of Plane 1
	swap	d0								;Swap to upper words
	swap	d1
	move.w	d0,(a2)+						;Write second word of Mask
	move.w	d1,(a2)							;Write second word of Plane 1
	swap	d0								;Swap words back
	swap	d1	
	ror.l	#2,d0							;Shift Mask and Plane 1 by 2 pixels
	ror.l	#2,d1
	lea		144-6(a2),a2					;Next preshift digit, each is 144 bytes
	dbra.w	d4,.loop3
	
	addq.l	#8,a1							;Next destination line
	dbra.w	d3,.loop2

	lea		1152-144(a1),a1					;Next destination digit, each preshift is 1152 bytes
	dbra.w	d2,.loop
	rts
	
;----------------------------------
;Preshift small score font
preshiftcalcscoresmall
	lea		scoresmallspr,a0
	lea		scoresmallpreshift,a1
	
	moveq.w	#10-1,d2						;10 digits
.loop	

	moveq.w	#10-1,d3						;Font height
.loop2
	move.l	#$ffff0000,d0					;Clear Mask and Plane 1 registers
	moveq.l	#0,d1
	move.w	(a0)+,d0						;Read Mask and Plane 1
	move.w	(a0)+,d1
	move.l	a1,a2							;Copy destination for preshift loop

	moveq.w	#8-1,d4							;Preshift line for each X offset (even)
.loop3
	move.w	d0,(a2)+						;Write first word of Mask
	move.w	d1,(a2)+						;Write first word of Plane 1
	swap	d0								;Swap to upper words
	swap	d1
	move.w	d0,(a2)+						;Write second word of Mask
	move.w	d1,(a2)							;Write second word of Plane 1
	swap	d0								;Swap words back
	swap	d1	
	ror.l	#2,d0							;Shift Mask and Plane 1 by 2 pixels
	ror.l	#2,d1
	lea		80-6(a2),a2						;Next preshift digit, each is 80 bytes
	dbra.w	d4,.loop3
	
	addq.l	#8,a1							;Next destination line
	dbra.w	d3,.loop2

	lea		640-80(a1),a1					;Next destination digit, each preshift is 640 bytes
	dbra.w	d2,.loop
	rts
	
;----------------------------------
;Preshift sparkles
preshiftcalcsparkles
	lea		sparklespr,a0
	lea		sparklepreshift,a1
	
	moveq.w	#3-1,d4							;3 frames
.loop	

	moveq.w	#5-1,d3							;5 pixels high
.loop2
	move.l	#$ffff0000,d0					;Read Mask and Planes 1+2+3
	move.w	(a0)+,d0
	move.l	(a0)+,d1
	moveq.l	#0,d2
	move.w	(a0)+,d2
	move.l	a1,a2							;Copy destination for preshift loop
	moveq.l	#11,d5							;Halfway shift value

	moveq.w	#8-1,d6							;Preshift line for each X set (within word)
.loop3
	move.w	d0,(a2)+						;Write Mask as long
	move.w	d0,(a2)+
	move.l	d1,(a2)+						;Write Planes 1+2+3+4
	move.l	d2,(a2)
	cmp.w	#4,d6							;Halfway through?
	bne.s	.nothalfway
	rol.l	d5,d0							;Shift back to top bit for next set
	rol.l	d5,d1
	rol.l	d5,d2
	or.l	#$ffff0000,d0					;Fix Mask
	bra.s	.continue
.nothalfway
	ror.l	#2,d0							;Shift Mask and Plane 1+2+3+4 by 2 pixels
	ror.l	#2,d1
	ror.l	#2,d2
.continue
	lea		60-8(a2),a2						;Next preshift digit, each is 60 bytes	
	dbra.w	d6,.loop3
	
	lea		12(a1),a1						;Next destination line
	dbra.w	d3,.loop2

	lea		480-60(a1),a1					;Next destination sparkle, each preshift is 480 bytes
	dbra.w	d4,.loop
	rts

;----------------------------------
;Preshift 48 pixel wide pipe, pass d0.w as height, a0.l as source, a1.l as preshift destination
preshiftcalcpipe
	move.w	d0,d1
	subq.w	#1,d1
	move.w	d1,preshiftheight				;Store height-1 for loops
	
	;Copy source as our first frame
	move.l	a1,a2							;Keep pointer as last frame
	move.w	preshiftheight,d0
.loop
	move.l	(a0)+,(a1)+						;Planes 1+2+3+4 for 48 pixels
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra.w	d0,.loop

	;Create preshifts
	moveq.w	#15-1,d3						;Preshift 15 times
.loop2
	;Copy the last frame to our current one
	move.l	a1,a3
	move.w	preshiftheight,d0
.loop3
	move.l	(a2)+,(a1)+						;Copy 48 pixels
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	dbra.w	d0,.loop3
	move.l	a3,a1
	
	;Shift current image right by 1 pixel
	move.l	a1,a2							;Store pointer as last frame
	move.w	preshiftheight,d2
.loop4
	moveq.w	#4-1,d0							;Shift Planes 1+2+3+4 
.loop5
	move.w	16(a1),d1						;Wrap pixel on far right back to start using X bit
	roxr.w	#1,d1
	roxr.w	(a1)
	roxr.w	8(a1)
	roxr.w	16(a1)
	addq.w	#2,a1							;Next plane
	dbra.w	d0,.loop5
	lea		24-8(a1),a1						;Next line

	dbra.w	d2,.loop4

	dbra.w	d3,.loop2
	rts

;----------------------------------
;Preshift 48 pixel wide pipe sprite, pass d0.w as height, a0.l as source, a1.l as preshift destination
preshiftcalcpipespr
	move.w	d0,d1
	subq.w	#1,d1
	move.w	d1,preshiftheight				;Store height-1 for loops
	
	;Copy source as our first frame
	move.l	a1,a2							;Keep pointer as last frame
	move.w	preshiftheight,d0
.loop
	move.l	(a0)+,(a1)+						;Mask and Planes 1+2+3+4 for 48 pixels
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra.w	d0,.loop

	;Create preshifts
	moveq.w	#15-1,d3						;Preshift 15 times
.loop2
	;Copy the last frame to our current one
	move.l	a1,a3
	move.w	preshiftheight,d0
.loop3
	move.l	(a2)+,(a1)+						;Copy 48 pixels
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	dbra.w	d0,.loop3
	move.l	a3,a1
	
	;Shift current image right by 1 pixel
	move.l	a1,a2							;Store pointer as last frame
	move.w	preshiftheight,d2
.loop4
	moveq.w	#6-1,d0							;Shift Mask and Planes 1+2+3+4 
.loop5
	move.w	24(a1),d1						;Wrap pixel on far right back to start using X bit
	roxr.w	#1,d1
	roxr.w	(a1)
	roxr.w	12(a1)
	roxr.w	24(a1)
	addq.w	#2,a1							;Next plane
	dbra.w	d0,.loop5
	lea		36-12(a1),a1					;Next line

	dbra.w	d2,.loop4

	dbra.w	d3,.loop2
	rts

;----------------------------------
;Preshift pipe with sky, pass d0.w as height, a0.l as pipe source, a1.l as sky source and a2.l as preshift destination
preshiftcalcpipesky
	move.w	d0,d2
	subq.w	#1,d2
	move.w	d2,preshiftheight				;Store height-1 for loops
	move.w	d0,d2
	lsl.w	#3,d2							;*8
	move.w	d2,d3
	add.w	d3,d3							;*16
	add.w	d3,d2							;=*24
	move.w	d2,preshiftsize					;Store size of one preshift, 24*height
	
	moveq.w	#8,d5							;Start X offset in sky
	
	subq.w	#1,d1							;Number of copies-1 for loop
.loopy
	move.w	d1,-(sp)
	
	;Copy pipesky as Mask long+Planes 1+2+3+4 for 48 pixels to workspace
	lea		preshiftpipesky,a3
	move.l	(a0)+,(a3)+						;48 pixels Mask and Planes 1+2+3+4
	move.l	(a0)+,(a3)+
	move.l	(a0)+,(a3)+
	move.l	(a0)+,(a3)+
	move.l	(a0)+,(a3)+
	move.l	(a0)+,(a3)+
	move.l	(a0)+,(a3)+
	move.l	(a0)+,(a3)+
	move.l	(a0)+,(a3)+
	sub.w	#36,a0
	
	moveq.w	#16-1,d7						;16 preshifts
.loop
	move.w	d5,-(sp)
	move.l	a2,-(sp)
	lea		preshiftpipesky,a3
	
	moveq.w	#3-1,d6							;Write out 48 pixels
.loop1
	move.l	(a3)+,d0						;Mask
	move.l	(a3)+,d1						;Planes 1+2
	move.l	(a3)+,d2						;Planes 3+4
	addq.w	#8,d5							;Next 16 pixels in sky source
	and.w	#63,d5							;Wrap sky on pixels 0...128
	
	;Output vertical line of sky
	movem.l	d6/a1-a2,-(sp)
	move.w	preshiftheight,d6
.loop2
	movem.l	(a1,d5.w),d3-d4					;Sky
	and.l	d0,d3							;Combine with pipe
	and.l	d0,d4
	or.l	d1,d3
	or.l	d2,d4
	movem.l	d3-d4,(a2)						;Write output
	lea		80(a1),a1						;Next sky line
	lea		24(a2),a2						;Next output line
	dbra.w	d6,.loop2
	movem.l	(sp)+,d6/a1-a2

	addq.w	#8,a2							;Move to next 16 pixels in output
	dbra.w	d6,.loop1

	move.l	(sp)+,a2
	move.w	(sp)+,d5
	add.w	preshiftsize,a2					;Next destination preshift

	;Shift pipe source right by one pixel
	lea		preshiftpipesky,a3
	moveq.w	#6-1,d0							;Shift Mask and Planes 1+2+3+4 
.loop3
	move.w	24(a3),d1						;Wrap pixel on far right back to start using X bit
	roxr.w	#1,d1
	roxr.w	(a3)
	roxr.w	12(a3)
	roxr.w	24(a3)
	addq.w	#2,a3							;Next plane
	dbra.w	d0,.loop3

	dbra.w	d7,.loop

	addq.w	#8,d5							;Move to next 16 pixels in sky
	move.w	(sp)+,d1
	dbra.w	d1,.loopy
	rts

;----------------------------------

	SECTION	BSS

preshiftheight		ds.w	1				;Height-1 of preshift
preshiftsize		ds.w	1				;Size in bytes of a single preshift
preshiftpipesky		ds.b	36				;Workspace for shifted pipe column

;Preshifts, total 88672 bytes
pipesky3preshift	ds.b	24*9*4*16		;48x8 pixels, 13824 bytes
pipesky2preshift	ds.b	24*19*2*16		;48x8 pixels, 14592 bytes
pipesky1preshift	ds.b	24*11*8*16		;48x8 pixels, 33792 bytes
pipecappreshift		ds.b	36*5*16			;48x5 pixels, 2880 bytes
pipebottompreshift	ds.b	24*5*16			;48x5 pixels, 1920 bytes
pipetoppreshift		ds.b	24*6*16			;48x6 pixels, 2304 bytes
sparklepreshift		ds.b	60*3*8			;3 sparkles preshifted 8 times, total 1440 bytes
scoresmallpreshift	ds.b	80*10*8			;10 digits preshifted 8 times, total 6400 bytes
scorelargepreshift	ds.b	144*10*8		;10 digits preshifted 8 times, total 11520 bytes
	EVEN
