

		section	text
;
; Fonts routine
;
; a1 = data pointer :
;	
credits1:		move.w	#0,d0
		move.w	#70,d1
		move.w	#319,d2
		move.w	#70,d3
		move.w	#-1,d4
		bsr	tc_line

		move.w	#0,d0
		move.w	#170,d1
		move.w	#319,d2
		move.w	#170,d3
		move.w	#-1,d4
		bsr	tc_line

		move.l	screen_adr,a0	; screen pointer

		lea	creditstext1,a1
		bsr	display_text
		
		move.l	screen_adr,a0
		lea	creditstext2,a1
		bsr	display_text
		
		move.l	screen_adr,a0
		lea	creditstext3,a1
		bsr	display_text
		rts
;
;
;

credits2:		move.w	#0,d0
		move.w	#86,d1
		move.w	#319,d2
		move.w	#86,d3
		move.w	#-1,d4
		bsr	tc_line

		move.w	#0,d0
		move.w	#154,d1
		move.w	#319,d2
		move.w	#154,d3
		move.w	#-1,d4
		bsr	tc_line

		move.l	screen_adr,a0	; screen pointer

		lea	creditstext4,a1
		bsr	display_text
		
		move.l	screen_adr,a0
		lea	creditstext5,a1
		bsr	display_text
		
		rts
;
;
;

credits3:		move.w	#0,d0
		move.w	#70,d1
		move.w	#319,d2
		move.w	#70,d3
		move.w	#-1,d4
		bsr	tc_line

		move.w	#0,d0
		move.w	#170,d1
		move.w	#319,d2
		move.w	#170,d3
		move.w	#-1,d4
		bsr	tc_line

		move.l	screen_adr,a0	; screen pointer

		lea	creditstext6,a1
		bsr	display_text
		
		move.l	screen_adr,a0
		lea	creditstext7,a1
		bsr	display_text
		
		move.l	screen_adr,a0
		lea	creditstext8,a1
		bsr	display_text

		rts
;
;
;

credits4:		move.w	#0,d0
		move.w	#54,d1
		move.w	#319,d2
		move.w	#54,d3
		move.w	#-1,d4
		bsr	tc_line

		move.w	#0,d0
		move.w	#186,d1
		move.w	#319,d2
		move.w	#186,d3
		move.w	#-1,d4
		bsr	tc_line

		move.l	screen_adr,a0	; screen pointer

		lea	creditstext9,a1
		bsr	display_text
		
		move.l	screen_adr,a0
		lea	creditstext10,a1
		bsr	display_text
		
		move.l	screen_adr,a0
		lea	creditstext11,a1
		bsr	display_text

		move.l	screen_adr,a0
		lea	creditstext12,a1
		bsr	display_text

		rts
;
;
;
endtext:		move.w	#0,d0
		move.w	#86,d1
		move.w	#319,d2
		move.w	#86,d3
		move.w	#-1,d4
		bsr	tc_line

		move.w	#0,d0
		move.w	#154,d1
		move.w	#319,d2
		move.w	#154,d3
		move.w	#-1,d4
		bsr	tc_line

		move.l	screen_adr,a0	; screen pointer

		lea	endtext1,a1
		bsr	display_text
		
		move.l	screen_adr,a0
		lea	endtext2,a1
		bsr	display_text
		
		rts
;
;
;
intro_text:		move.w	#0,d0
		move.w	#70,d1
		move.w	#319,d2
		move.w	#70,d3
		move.w	#-1,d4
		bsr	tc_line

		move.w	#0,d0
		move.w	#170,d1
		move.w	#319,d2
		move.w	#170,d3
		move.w	#-1,d4
		bsr	tc_line

		move.l	screen_adr,a0	; screen pointer

		lea	introtext1,a1
		bsr	display_text
		
		move.l	screen_adr,a0
		lea	introtext2,a1
		bsr	display_text
		
		move.l	screen_adr,a0
		lea	introtext3,a1
		bsr	display_text
		rts
;
; display routine
; a0 = screen buffer
; a1 = text data (x:w,y:w,nb chars-1:w,{text:b})
;
display_text:	move.w	(a1)+,d0		; x offset
		move.w	(a1)+,d1		; y offset
		mulu.w	#320,d1
		add.w	d0,d1		; save d1 for future offset
		lea	(a0,d1.l*2),a0	; set start offset		

		move.w	(a1)+,d2		; get textsize	
	
.textsizeloop:	lea	fonts+20,a2
		moveq.w	#0,d0		; erase d0
		move.b	(a1)+,d0		; get d2th character

		subi.b	#65,d0		; pos(A)=Asc(A)-65 as Asc(A)=65	

		ext.w	d0
		move.w	#10,d1

		cmp.w	d1,d0
		blt.w	.nextStep		; first 10 chars row
		
		sub.w	d1,d0
		lea	640*28(a2),a2	
	
		cmp.w	d1,d0
		blt.w	.nextStep		; second 10 chars row

		sub.w	d1,d0
		lea	640*28(a2),a2	; third 7 chars row	

.nextStep:		lsl.w	#6,d0		; = mulu.w #64,d0 -> d0=d0*64
		ext.l	d0
		lea	(a2,d0.l),a2	; set a char position
	
.nextStep2:		move.w	#31,d3		; each char = 32 pixels height
		moveq.l	#0,d4		

.drawChar:		
		rept	16
		move.l	(a2,d4.l*2),(a0,d4.l*2)	; copy 16 longwords = 32 pixels
		addq.l	#2,d4
		endr
		
		add.l	#288,d4		; d4=counter*320 (counter from 0 to 31)
				
		dbra	d3,.drawChar

		lea	64(a0),a0

		dbra	d2,.textsizeloop		

		rts

; -------------------------------------------------------------------
;
; routine 'copy_logo1'
; Display the first logo to the screen
;
; -------------------------------------------------------------------

copy_logo1:		lea.l	logo1+20,a1		;(apex hicol block)
		move.w	#320*192*2/64-1,sizelogo
		bra	copy_logo



; -------------------------------------------------------------------
;
; internal routine 'copy_logo'
; Display the given logo to the screen
;
; ------------------------------------------------------------------

copy_logo:

		move.l	screen_adr,a0
		adda.l	#640*27,a0	
		move.w	sizelogo,d7
.loop:
		rept	16
		move.l	(a1)+,(a0)+
		endr

		dbra	d7,.loop
		rts

; -------------------------------------------------------------------
;
; BSS Section : variables to initialise
;
; -------------------------------------------------------------------
		
		section	bss

sizelogo:		ds.w	1

; -------------------------------------------------------------------
;
; Data Section : constant data
;
; -------------------------------------------------------------------
		
		section	data

logo1:		incbin	'incbin\logo.apx'
fonts:		incbin	'incbin\fonts32.apx'
bool_init:		dc.w	1
introtext1:		dc.w	80,72,4
		dc.b	"TROLL",0
		EVEN
introtext2:		dc.w	64,104,5
		dc.b	"AND",94,"CO",0
		EVEN
introtext3:		dc.w	48,136,6
		dc.b	"PRESENT",0	
		EVEN

creditstext1:	dc.w	96,72,3
		dc.b	"CODE",0
		EVEN
creditstext2:	dc.w	48,104,6	
		dc.b	"MATT",94,"US",0
		EVEN
creditstext3:	dc.w	96,136,3
		dc.b	"ALEM",0	
		EVEN

creditstext4:	dc.w	80,88,4
		dc.b	"MUSIC",0
		EVEN
creditstext5:	dc.w	16,120,8	
		dc.b	"FIVEOFIVE",0
		EVEN

creditstext6:	dc.w	96,72,3
		dc.b	"LOGO",0	
		EVEN
creditstext7:	dc.w	16,104,8
		dc.b	"IDEA",94,"FROM",0
		EVEN
creditstext8:	dc.w	80,136,4	
		dc.b	"UKONX",0
		EVEN

creditstext9:	dc.w	32,56,7
		dc.b	"THANX",94,"TO",0	
		EVEN
creditstext10:	dc.w	112,88,2
		dc.b	"RAY",0
		EVEN
creditstext11:	dc.w	48,120,6	
		dc.b	"ZERKMAN",0
		EVEN
creditstext12:	dc.w	112,152,2
		dc.b	"SOS",0	
		EVEN

endtext1:	dc.w	0,88,9
		dc.b	"THAT",93,"S",94,"ALL",0
		EVEN
endtext2:	dc.w	48,120,6
		dc.b	"FOLKS",94,91,0
		EVEN


		section	text