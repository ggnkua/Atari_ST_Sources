

		section	text

; -------------------------------------------------------------------
;
; routine  : fade_table
;
; Fade the current color table (320x240xTC)from one shade
; TC word : |rrrrrggg|gggbbbbb|
; used :
; - a0 : screen_adr
; - d1,d2,d3 : Blue, Red, Green
; - d5 : current pixel modified
; - d7,d6 : loops
;
; -------------------------------------------------------------------
		
fade_table:		move.w	#-1,d7	; loop to scan all values (16 bits)
		
.loop_fade:		move.w	(a0),d5	; store current TC pixel
		move.b	d5,d1	; to get blue bits (need right byte)
		move.w	d5,d2	; to get green bits (need both bytes)
		move.w	d5,d3		; to get red word (need left byte...so get the word :( )
	
		and.b	blue_bits,d1	; save blue bits only
		and.w	red_bits,d3		; save red bits only

.test_blue:		cmp.b	fade_speed,d1	; no more blue ?
		blo	.end_blue
		sub.b	fade_speed,d1           ; decrease blue ton by 1 
		bra	.end_blue_test
.end_blue		clr.b	d1		

.end_blue_test:	lsr.w	#3,d3		; shift bits right to be able to test+sub it
		lsr.w	#8,d3
		cmp.b	fade_speed,d3	; no more red ? 
		blo	.end_red
		sub.b	fade_speed,d3	; decrease red ton by 1 
		bra	.end_red_test
.end_red		clr.b	d3
.end_red_test	lsl.w	#3,d3		; shift bits left to replace then at the begining of the word
		lsl.w	#8,d3

.test_green:	and.w	green_bits,d2	; save green bits
		lsr.w	#5,d2		; shit significants bits to test them
		cmp.b	fade_speed_green,d2	; nearly no more green ?
		blo	.end_green
		sub.b	fade_speed_green,d2	; decrease green ton by 2 
		bra	.end_green_test
.end_green:		clr.w	d2		; clear it if green luminance <2 
.end_green_test:	lsl.w	#5,d2		; shift green significant bits to the right

		clr.w	d5		; clear new pixel
		
		or.w	d3,d5		; copy red bits
		or.w	d2,d5		; copy green bits in the middle of the word
		or.b	d1,d5		; copy blue bits 
		

		move.w	d5,(a0)+		; replace old pixel			

		dbra	d7,.loop_fade	; replace next line 	

		rts

; -------------------------------------------------------------------
;
; subroutine 'init_fade'
;    
; precalc the pixel table...
;
; -------------------------------------------------------------------

init_fade:		tst.w	.fade_init		; do it one time
		bne.w	.no
		not.w	.fade_init
	
		lea	pixeltable,a0	; load pixeltable
		moveq.w	#0,d2		; clear d2=count
		moveq.w	#-1,d7		; for d7=$FFFF to 0	

.loop_init		move.w	d2,(a0)+		; pixeltable(d7)=count		
		addq.w	#1,d2		; count=count+1	

		dbra	d7,.loop_init
		
		lea	pixeltable,a0	; reload table at the beginning
		bsr	fade_table		; fade all colors
		;bsr	fade_table

		rts

.no		rts
.fade_init		ds.w	1

; -------------------------------------------------------------------
;
; subroutine 'table_fade'
;    
; Fade the screen using table method...
;
; -------------------------------------------------------------------


table_fade:		move.l	screen_adr,a0	; screen pointer
		lea	pixeltable,a1	; faded pixel table

		move.w	pic_height,d5
		move.w	pic_width,d7	; loop to scan all lines
.loopY:		move.w	d5,d6 		; loop to scan each pixel in one line

.loopX:		moveq.l	#0,d1
		move.w	(a0),d1		; get current pixel value
		
		move.w	0(a1,d1.l*2),(a0)+	; replace it by its value in table (color shaded) 	

		dbra	d6,.loopX 		; replace next one in the row

		dbra	d7,.loopY		; replace next line 	
		
		rts

; -------------------------------------------------------------------
;
; subroutine 'buffers_clear'
;    
; Clear the logical screens
;
; -------------------------------------------------------------------

buffers_clear:	move.l	screen_adr,a3
		move.l	screen_adr1,a0
		move.l	screen_adr2,a1
		move.l	screen_adr3,a2
		move.w	#320*240*2/64-1,d7
.loop:
		rept	16
		clr.l	(a0)+
		clr.l	(a1)+
		clr.l	(a2)+
		clr.l	(a3)+
		endr
		
		dbra	d7,.loop

		rts

; -------------------------------------------------------------------
;
; Data Section : constant data
;
; -------------------------------------------------------------------
		
		section 	data

blue_bits		dc.b	%00011111
		EVEN
red_bits		dc.w	%1111100000000000
green_bits		dc.w	%0000011111100000
fade_speed		dc.b	2	;0->31 values
fade_speed_green	dc.b	4	;0->63 values (should be 2xfade_speed)
nb_fadepass		dc.w	0
pic_width		dc.w	319
pic_height		dc.w	239

		section	bss

pixeltable		ds.w	65536

		section	text