; Flame concept : 
; To generate the glow
; Fill the bottom 2 lines with random numbers
;
;	for  x = 0 to 2*screenwidth-1:
;     		screen[(screenheight-2)*screenwidth] := random(255);
;

	Section	Text

;
; Init routine to create text effects (I'M A & TROLL)
;
Init_Flame1:	lea 	FlameText1,a1	; text to display
		lea	ImgBufferTC,a0	; destination buffer (320x100)
		bsr	display_text	; generate text
		
		lea	ImgBufferTC,a0	; reload buffer at the beginning
		lea	ImgBuffer1,a2	; this buffer will contains the text (160x100)
		bsr	Init_Flame		; call flame init

		rts

;
; Init routine2
;
Init_Flame2:	lea 	FlameText2,a1	; same for second text
		lea	ImgBufferTC,a0
		bsr	display_text	; generate text
		
		lea	ImgBufferTC,a0
		lea	ImgBuffer2,a2
		bsr	Init_Flame

		rts
;
; 320*240to160*100 routine (TC->TC)
; a2 = ImgBuffer destination
; a1 = text data	


Init_Flame:		moveq	#99,d1		; 100 pixels height
.loopy:
		moveq	#9,d2		; 10*16 pixels width = 160 pixels
.loopx:		
		REPT	16		; copy first 16 pixels from TC buffer to small buffer 
		move.w	(a0)+,(a2)+
		ENDR

		dbra	d2,.loopx
		adda.l	#320,a0		; forget last 160 right pixels
		dbra	d1,.loopy

		rts
;
; Entry point routine to display Text1 in Flame effect
;
Text_Flames1:
		tas	logo1_flag		; test and set to display the text one time only
		bne.s	FlameCredits	; if set, go directly to the flame routine
		lea	ImgBuffer1,a1
		move.w	#0,logo2_flag
		bra.s	DisplayText		; else display the text before the flame effect

logo1_flag		dc.w	0

;
; Entry point routine to display Text2 in Flame effect
;

Text_Flames2:
		tas	logo2_flag		; test & set
		bne.s	FlameCredits	
		lea	ImgBuffer2,a1
		move.w	#0,logo1_flag
		bra.s	DisplayText

logo2_flag		dc.w	0

;
; Add the 'Text' in the Flame buffer (160x100) 
;

DisplayText		lea	FireBuffer,a0	; Flame buffer (160x100)
	
		move.w	#160*100/2,d0	; logo 160*100 in TC (/2 for longwords)
.loopDisp:
		move.l	(a1)+,d1		; get 2 pixels  
		or.l	d1,(a0)+  		; copy pixels to screen_adr
		dbra	d0,.loopDisp	; loop

;
; Generate random blue pixels on the bottom of the buffer to create new flames
;

FlameCredits:	
		move.w	#319,d0		; plot 2 lines of rnd pixels
.noimg		lea	FireBuffer+320*120,a0	; go to last line-2 to fill the 2 hidden lines (321 & 322)
.loop1:		move.l	seedFlame,d1
		rol.l       d1,d1		; generate new rnd
		addq.l      #5,d1
		move.l	d1,seedFlame	; save it
		andi.w 	#$3fff,d1		; generate 14 bits color
	

		move.w	d1,(a0)+		; put this random blue pixel on this line

		dbra	d0,.loop1
;
; Flame algo...
;
;	for  x = screenwidth to screenwidth*(screenheight-1)-1:
;     		color = screen[x]+screen[x-1]+screen[x+1]+screen[x+screenwidth]
;     		color /= 4 (color shr 2)
;
;     		color -= 1;
;
;     		screen[x-screenwidth] = color
;


		lea	FireBuffer+320,a0	; apply effect on the visible area + 2 hidden lines (160*2)
		move.l	#160*120-1,d0	; for d0=160*120-1 to 0

.loop2:		move.w	(a0)+,d1		; d1=color at x	
		add.w	(a0),d1		; d1=d1+color at x+1 		
		add.w	-4(a0),d1		; d1=d1+color at x-1		
		add.w	320-2(a0),d1	; d1=d1+color at x+scrwidth

		lsr.w	#2,d1		; d1=d1/4
;		beq.s 	.overflow		
		sub.w	#250,d1		; d1=d1-250
		bpl.s	.overflow		; if <0
		moveq	#0,d1		; d1 = 0
.overflow:		move.w	d1,-320-2(a0)	; else plot d1 one line before 	

		subq.l      #1,d0		; d0--
		;tst.l       d0
		bpl.s       .loop2		; next d0
		
;
; at this point all pixels in the buffer are processed
;
		lea	FireBuffer,a0	; the flame buffer
		move.l	screen_adr,a1	; the screen

		moveq.w	#119,d0		; loop for cols

.loopCol		move.w	#159,d1		; loop for rows
		
.loopRow		move.w	(a0)+,d2 		; get pixel from buffer, generate blue color from 14 bits value
		moveq	#9,d3		; d3=9, lsr can't use immediate >8
		lsr	d3,d2		; pixel value=value/512 -> get a 5bits value = blue value
		move	d2,d3		; d3=lw(d2) -> only the lower word is filled
		swap	d3		; exchange words in d3 to save the blue pixel
		move	d2,d3		; d3=(lw(d2),lw(d2)) = 2 blue pixels in each word 
		
		move.l	d3,(a1)+		; copy them 2 times(1 long = 2 words = 2 pixels)

		move.l	d3,636(a1)		; copy them on the next scanlines (we use a quarter screen buffer 160x100)

		dbra	d1,.loopRow		; do it for the whole width (160x2 pixels = 320)

		adda.l	#640,a1		; skip one scanline (already filled)

		dbra	d0,.loopCol		; restart for the next row+1

		rts

	Section	Data

seedFlame:		dc.l	012345678
FlameText1:		dc.w	0,30,4
		dc.b	"I",93,"M",94,"A",0
		EVEN
FlameText2:		dc.w	0,30,4
		dc.b	"TROLL",0
		EVEN

	Section 	BSS

FireBuffer:		ds.w	160*122
ImgBuffer1:		ds.w	160*100
ImgBuffer2:		ds.w	160*100
ImgBufferTC:	ds.w	320*100


	Section	Text

