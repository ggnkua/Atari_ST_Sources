; ------------------------------------------------------------------------------
;
; Atari STE fast Blitter objects by Sascha 'Anima' Springer [June 2022]
;
; ./vasmm68k_mot fastbobs.s -nosym -quiet -Ftos -o fastbobs.prg
;
; ------------------------------------------------------------------------------

DISPLAY_WIDTH = 320
VIRTUAL_DISPLAY_WIDTH = 512
DISPLAY_HEIGHT = 256
DISPLAY_OFFSET = 0

NUMBER_OF_BOBS = 24

BUSY = %10000000
HOG = %01000000
FXSR = %10000000
NFSR = %01000000

; ------------------------------------------------------------------------------
	text
; ------------------------------------------------------------------------------
	
start
	jsr		init

	move	#$2700,sr

	jsr		prepare_data

	move	#%0000000000000000,$ffff8a00.w
	move	#%0000010110100000,$ffff8a02.w
	move	#%0000010110100000,$ffff8a04.w
	move	#%0000010110100000,$ffff8a06.w
	move	#%0000010110100000,$ffff8a08.w
	move	#%0000010110100000,$ffff8a0a.w
	move	#%0000010110100000,$ffff8a0c.w
	move	#%0000010110100000,$ffff8a0e.w
	move	#%0000110110110000,$ffff8a10.w
	move	#%0000110110110000,$ffff8a12.w
	move	#%0001110110111000,$ffff8a14.w
	move	#%0111100110011110,$ffff8a16.w
	move	#%0111100110011110,$ffff8a18.w
	move	#%0111000110001110,$ffff8a1a.w
	move	#%0110000110000110,$ffff8a1c.w
	move	#%0000000000000000,$ffff8a1e.w

	jsr		clear_screen

	; Start loop sample

	move.b	sample_addresses+1,$ffff8903.w
	move.b	sample_addresses+2,$ffff8905.w
	move.b	sample_addresses+3,$ffff8907.w

	move.b	sample_addresses+4+1,$ffff890f.w
	move.b	sample_addresses+4+2,$ffff8911.w
	move.b	sample_addresses+4+3,$ffff8913.w

	move.b	#%11000010,$ffff8921.w ; Mono, 8 bit, 25033 Hz

	move.b	#%00000011,$ffff8901.w ; Loop and start

	clr.b	$ffff8260.w ; Lo-Res
	move.b	#(512-320)/2/2,$ffff820f.w ; Virtual display size

	move	#$2300,sr

	; VBL loop

	move	#-2,vbl_counter

.vbl_loop
	cmpi.b  #$1+$80,$fffffc02.w ; Escape key pressed?
	beq		.key_release_loop

	tst		vbl_counter
	bmi		.vbl_loop

	jsr		clear_bobs
	jsr		draw_bobs

	move	#-1,vbl_counter

	bra		.vbl_loop

.key_release_loop
	tst.b	$fffffc02.w
	btst	#4,$fffffa01.w
	beq		.key_release_loop

	move	#-1,vbl_counter

.vbl_wait
	tst		vbl_counter
	beq		.vbl_wait

	jsr		restore

	clr		-(sp)
	trap	#1

	rts

; ------------------------------------------------------------------------------

init
	clr.l	-(sp)
	move	#$20,-(sp)
	trap	#1
	addq	#6,sp
	move.l  d0,old_ssp

	move	#$2700,sr

	movem.l $ffff8240.w,d0-d7
	movem.l d0-d7,old_palette

	move.b	$ffff8260.w,old_res
	move.b	$ffff820a.w,old_hz
	move.b	$ffff820f.w,old_linewid

	move.b	$ffff8201.w,old_screen+1
	move.b	$ffff8203.w,old_screen+2
	move.b	$ffff820d.w,old_screen+3

	move.b	$fffffa07.w,old_fa07
	move.b	$fffffa09.w,old_fa09
	move.b	$fffffa13.w,old_fa13
	move.b	$fffffa15.w,old_fa15
	move.b	$fffffa17.w,old_fa17
	move.b	$fffffa1b.w,old_fa1b
	move.b	$fffffa21.w,old_fa21

	move.b	$ffff8921.w,old_8921

	move.l	$68.w,old_hbl
	move.l	$70.w,old_vbl
	move.l	$120.w,old_timer_b
    move.l	$134.w,old_timer_a

	clr.b	$fffffa07.w
	clr.b	$fffffa09.w
	clr.b	$fffffa13.w
	clr.b	$fffffa15.w

	bclr	#3,$fffffa17.w ; Enable automatic end of interrupt

	move.l	#hbl,$68.w

	move.l	#vbl,$70.w

	; Timer B (display lines interrupt aka "rasters")

	move.l	#timer_b,$120.w
	bset	#0,$fffffa07.w ; Interrupt enable Timer B (comment out to disable Timer B interrupts)
	bset	#0,$fffffa13.w ; Interrupt mask Timer B

	; Timer A

	move.l	#timer_a,$134.w
    bset	#5,$fffffa07.w ; Interrupt enable (comment out to disable Timer A interrupts)
    bset	#5,$fffffa13.w ; Interrupt mask

	move	#$2300,sr

	rts

restore
	move	#$2700,sr

	movem.l old_palette,d0-d7
	movem.l d0-d7,$ffff8240.w

	move.b	old_res,$ffff8260.w
	move.b	old_hz,$ffff820a.w
	move.b	old_linewid,$ffff820f.w

	move.b	old_screen+1,$ffff8201.w
	move.b	old_screen+2,$ffff8203.w
	move.b	old_screen+3,$ffff820d.w

	move.b	old_fa07,$fffffa07.w
	move.b	old_fa09,$fffffa09.w
	move.b	old_fa13,$fffffa13.w
	move.b	old_fa15,$fffffa15.w
	move.b	old_fa17,$fffffa17.w
	move.b	old_fa1b,$fffffa1b.w
	move.b	old_fa21,$fffffa21.w

	clr.b	$ffff8901.w
	move.b	old_8921,$fffffa21.w

	move.l	old_hbl,$68.w
	move.l	old_vbl,$70.w
	move.l	old_timer_b,$120.w
	move.l	old_timer_a,$134.w

	move	#$2300,sr

	move.l	old_ssp,-(sp)    ; Supervisor off
	move	#$20,-(sp)
	trap	#1
	addq	#6,sp

	rts

; ------------------------------------------------------------------------------

clear_screen
	move	#2,$ffff8a20.w ; Source X increment
	move	#$ffff,$ffff8a28.w ; Endmask 1
	move	#$ffff,$ffff8a2a.w ; Endmask 2
	move	#$ffff,$ffff8a2c.w ; Endmask 3
	move	#2,$ffff8a2e.w ; Destination X increment
	move	#VIRTUAL_DISPLAY_WIDTH/2-3*4*2+2,$ffff8a30.w ; Destination Y Increment
	move.b	#1,$ffff8a3a.w ; HOP 1 (halftone only)
	move.b	#3,$ffff8a3b.w ; OP 3 (destination = source)
;	move.b	#0,$ffff8a3b.w ; OP 0 (destination = 0)
	clr.b	$ffff8a3d.w ; FXSR, NFSR, Skew
	move	#3*4,$ffff8a36.w ; X Count

	lea		$ffff8a32.w,a4
	lea		$ffff8a38.w,a5
	lea		$ffff8a3c.w,a6

	moveq	#16,d5
	moveq	#$ffffffc0,d0

	; Clear screen

	move.l	draw_screen_address,d1
;	sub.l	#DISPLAY_OFFSET*VIRTUAL_DISPLAY_WIDTH/2,d1

	move	#(DISPLAY_HEIGHT/16)-1,d7

.loop1
	move	#(DISPLAY_WIDTH/16)-1,d6

.loop2
	move.l	d1,(a4) ; Destination address
	move	d5,(a5) ; Y Count
	move.b	d0,(a6) ; Busy, Hog, Smudge, Line Number

	addq.l	#8,d1

	dbf		d6,.loop2

	add.l	#16*VIRTUAL_DISPLAY_WIDTH/2-(DISPLAY_WIDTH/16)*8,d1

	dbf		d7,.loop1

	; Draw screen

	move.l	draw_screen_address,d1
;	sub.l	#DISPLAY_OFFSET*VIRTUAL_DISPLAY_WIDTH/2,d1

	move	#(DISPLAY_HEIGHT/16)-1,d7

.loop3
	move	#(DISPLAY_WIDTH/16)-1,d6

.loop4
	move.l	d1,(a4) ; Destination address
	move	d5,(a5) ; Y Count
	move.b	d0,(a6) ; Busy, Hog, Smudge, Line Number

	addq.l	#8,d1

	dbf		d6,.loop4

	add.l	#16*VIRTUAL_DISPLAY_WIDTH/2-(DISPLAY_WIDTH/16)*8,d1

	dbf		d7,.loop3

	; Display screen

	move.l	display_screen_address,d1
;	sub.l	#DISPLAY_OFFSET*VIRTUAL_DISPLAY_WIDTH/2,d1

	move	#(DISPLAY_HEIGHT/16)-1,d7

.loop5
	move	#(DISPLAY_WIDTH/16)-1,d6

.loop6
	move.l	d1,(a4) ; Destination address
	move	d5,(a5) ; Y Count
	move.b	d0,(a6) ; Busy, Hog, Smudge, Line Number

	addq.l	#8,d1

	dbf		d6,.loop6

	add.l	#16*VIRTUAL_DISPLAY_WIDTH/2-(DISPLAY_WIDTH/16)*8,d1

	dbf		d7,.loop5

	rts

; ------------------------------------------------------------------------------

prepare_data
	; Align screen addresses

	move.l	#screen1,d0
	add.l	#$10000-1,d0
	and.l	#$ffff0000,d0
	move.l	d0,draw_screen_address
	add.l	#$20000,d0
	move.l	d0,display_screen_address

	; Set palette colors

	movem.l sprites+2,d0-d7
	movem.l d0-d7,$ffff8240.w

	; Reorder sprite

	lea		sprites+2+16*2,a0
	lea		enhanced_sprite1_reordered,a1
	lea		reorder_offset_table,a2

	move	#2-1,d7

.sprite_loop1
	move	(a0)+,d0
	swap	d0
	move	8-2(a0),d0
	lsr.l	#4,d0
	move	d0,(a1)+

	move	(a0)+,d0
	swap	d0
	move	8-2(a0),d0
	lsr.l	#4,d0
	move	d0,(a1)+

	move	(a0)+,d0
	swap	d0
	move	8-2(a0),d0
	lsr.l	#4,d0
	move	d0,(a1)+

	move	(a0)+,d0
	swap	d0
	move	8-2(a0),d0
	lsr.l	#4,d0
	move	d0,(a1)+

	add.l	(a2)+,a0

	dbf		d7,.sprite_loop1

	move	#2-1,d7

.sprite_loop2
	move	(a0)+,d0
	swap	d0
	move	8-2(a0),d0
	lsr.l	#7,d0
	move	d0,(a1)+

	move	(a0)+,d0
	swap	d0
	move	8-2(a0),d0
	lsr.l	#7,d0
	move	d0,(a1)+

	move	(a0)+,d0
	swap	d0
	move	8-2(a0),d0
	lsr.l	#7,d0
	move	d0,(a1)+

	move	(a0)+,d0
	swap	d0
	move	8-2(a0),d0
	lsr.l	#7,d0
	move	d0,(a1)+

	add.l	(a2)+,a0

	dbf		d7,.sprite_loop2

	move	#32-2-2-1,d7

.sprite_loop3
	move	(a0)+,(a1)+
	move	8-2(a0),(a1)+
	move	(a0)+,(a1)+
	move	8-2(a0),(a1)+
	move	(a0)+,(a1)+
	move	8-2(a0),(a1)+
	move	(a0)+,(a1)+
	move	8-2(a0),(a1)+

	add.l	(a2)+,a0

	dbf		d7,.sprite_loop3

	rts

; ------------------------------------------------------------------------------
;
; $ff8a00	00000000 00000000 						Halftone 0
; $ff8a02	00000000 00000000 						Halftone 1
; $ff8a04	00000000 00000000 						Halftone 2
; $ff8a06	00000000 00000000						Halftone 3
; $ff8a08	00000000 00000000						Halftone 4
; $ff8a0a	00000000 00000000						Halftone 5
; $ff8a0c	00000000 00000000						Halftone 6
; $ff8a0e	00000000 00000000						Halftone 7
; $ff8a10	00000000 00000000						Halftone 8
; $ff8a12	00000000 00000000						Halftone 9
; $ff8a14	00000000 00000000						Halftone 10
; $ff8a16	00000000 00000000						Halftone 11
; $ff8a18	00000000 00000000						Halftone 12
; $ff8a1a	00000000 00000000						Halftone 13
; $ff8a1c	00000000 00000000						Halftone 14
; $ff8a1e	00000000 00000000						Halftone 15
;
; $ff8a20	00000000 0000000-						Source X Increment
; $ff8a22	00000000 0000000-						Source Y Increment
; $ff8a24	-------- 00000000 00000000 0000000-		Source Address
;
; $ff8a28	00000000 00000000						Endmask 1
; $ff8a2a	00000000 00000000						Endmask 2
; $ff8a2c	00000000 00000000						Endmask 3
;
; $ff8a2e	00000000 0000000-						Destination X Increment
; $ff8a30	00000000 0000000-						Destination Y Increment
; $ff8a32	-------- 00000000 00000000 0000000-		Destination Address
;
; $ff8a36	00000000 00000000						X Count
; $ff8a38	00000000 00000000						Y Count
;
; $ff8a3a	------00								HOP
; $ff8a3b	----0000								OP
; $ff8a3c	000-0000								Busy, Hog, Smudge, Line Number
; $ff8a3d	00--0000								FXSR, NFSR, Skew

draw_bobs
	lea		bob_positions,a0
	move.l	draw_bobs_clear_infos_address,a1
	lea		.draw_bob_addresses,a2

	move	#NUMBER_OF_BOBS-1,d7

.update_loop
	move	(a0),d0 ; X position

	moveq	#$f,d2
	and		d0,d2
	add		d2,d2
	add		d2,d2
	move	d2,(a1)+ ; Store Bob shift for clear code selection

	moveq	#$fffffff0,d3
	and		d0,d3
	lsr		#1,d3

	move	4(a0),d1 ; Y position
	lsl		#8,d1
	add		d1,d3
	move	d3,(a1)+ ; Store Bob screen address (low word) for clearing
	move	d3,-(sp)

	move.l	(a2,d2.w),-(sp)

	; Update positions

	move.l	8(a0),d0
	add.l	(a0),d0
	bmi		.skip1

	cmp.l	#(DISPLAY_WIDTH-32)<<16,d0
	blt		.skip2

.skip1
	neg.l	8(a0)
	add.l	8(a0),d0

.skip2
	move.l	d0,(a0)

	move.l	12(a0),d0
	add.l	4(a0),d0
	bmi		.skip3

	cmp.l	#(256-32)<<16,d0
	blt		.skip4

.skip3
	neg.l	12(a0)
	add.l	12(a0),d0

.skip4
	move.l	d0,4(a0)

	lea		16(a0),a0

	dbf		d7,.update_loop

	; Prepare drawing

	move.b	#2,$ffff8a3a.w ; HOP 2 (source only)
	move.b	#3,$ffff8a3b.w ; OP 3 (destination = source)
	move	#2,$ffff8a20.w ; Source X increment
	move	#2,$ffff8a22.w ; Source Y increment
	move	#16/2,$ffff8a2e.w ; Destination X increment
	move	#%1111111111111111,$ffff8a2a.w ; Endmask 2
	move	draw_screen_address,$ffff8a32.w ; Destination address (high word)

	move	#-16*(2-1)/2+2,d0 ; Destination Y increment for X Count = 2
	move	#-16*(3-1)/2+2,d1 ; Destination Y increment for X Count = 3
	move.l	#(2<<16)+4,d2 ; X Count = 2 + Y Count = 4
	move.l	#(3<<16)+4,d3 ; X Count = 3 + Y Count = 4
	move	#VIRTUAL_DISPLAY_WIDTH/2-8,d4 ; Next line address offset
	move	#-VIRTUAL_DISPLAY_WIDTH/2-8,d5 ; Previous line address offset
	move.l	#(1<<16)+4,d6 ; X Count = 1 and Y Count = 4
	moveq	#$ffffffc0,d7 ; Start HOG mode blitting command (BUSY + HOG)
	
	lea		$ffff8a24.w,a0 ; Source Address
	lea		$ffff8a30.w,a1 ; Destination Y Increment
	lea		$ffff8a28.w,a2 ; Endmask 1
	lea		$ffff8a2c.w,a3 ; Endmask 3
	lea		$ffff8a32+2.w,a4 ; Destination Address (low word) | X Count + Y Count
	lea		$ffff8a38.w,a5 ; Y Count
	lea		$ffff8a3c.w,a6 ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew

	rts ; Start drawing

.draw_bob_addresses
	dc.l	.draw_bob_0,.draw_bob_1,.draw_bob_2,.draw_bob_3
	dc.l	.draw_bob_4,.draw_bob_5,.draw_bob_6,.draw_bob_7
	dc.l	.draw_bob_8,.draw_bob_9,.draw_bob_a,.draw_bob_b
	dc.l	.draw_bob_c,.draw_bob_d,.draw_bob_e,.draw_bob_f

.draw_bob_0
	move	(sp)+,(a4)+ ; Destination Address (low word)
	
	move.l	draw_sprite_data_address,(a0) ; Source Address

	; 0

	move	d0,(a1) ; Destination Y Increment

	move	#%0000000000001111,(a2) ; Endmask 1. [12]
	move	#%1111000000000000,(a3) ; Endmask 3. [12]
	move.l	d2,(a4) ; X Count, Y Count
	move	#((BUSY+HOG)<<8)+NFSR+12+0,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 31

	add		#-(0-31)*VIRTUAL_DISPLAY_WIDTH/2-8,-(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 30

	move	#%0000000001111111,(a2) ; Endmask 1. [12]
	move	#%1111111000000000,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move	#((BUSY+HOG)<<8)+NFSR+9+0,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 1

	add		#-(30-1)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 2

	move	#%0000000111111111,(a2) ; Endmask 1. [12]
	move	#%1111111110000000,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move	#((BUSY+HOG)<<8)+0,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 29

	add		#-(2-29)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 28

	move	#%0000001111111111,(a2) ; Endmask 1. [12]
	move	d7,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 3

	add		#-(28-3)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 4

	move	#%0000011111111111,(a2) ; Endmask 1. [12]
	move	#%1111111111100000,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 27

	add		#-(4-27)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 26

	move	#%0000111111111111,(a2) ; Endmask 1. [12]
	move	#%1111111111110000,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 5

	add		#-(26-5)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 6

	move	#%0001111111111111,(a2) ; Endmask 1. [12]
	move	#%1111111111111000,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 25

	add		#-(6-25)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 24

	move	#%0011111111111111,(a2) ; Endmask 1. [12]
	move	#%1111111111111100,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 23

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 7

	add		#-(23-7)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 8

	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 9

	move	#%0111111111111111,(a2) ; Endmask 1. [12]
	move	#%1111111111111110,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 10

	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 11

	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 22

	add		#-(11-22)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 21

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 20

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 19

	move	#%1111111111111111,(a2) ; Endmask 1. [12]
	move	#%1111111111111111,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 18

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 17

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 16

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 15

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 14

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 13

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 12

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	rts

.draw_bob_1
	move	(sp)+,(a4)+ ; Destination Address (low word)
	
	move.l	draw_sprite_data_address,(a0) ; Source Address

	; 0

	move	d0,(a1) ; Destination Y Increment

	move	#%0000000000000111,(a2) ; Endmask 1. [12]
	move	#%1111100000000000,(a3) ; Endmask 3. [12]
	move.l	d2,(a4) ; X Count, Y Count
	move	#((BUSY+HOG)<<8)+NFSR+12+1,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 31

	add		#-(0-31)*VIRTUAL_DISPLAY_WIDTH/2-8,-(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 30

	move	#%0000000000111111,(a2) ; Endmask 1. [12]
	move	#%1111111100000000,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move	#((BUSY+HOG)<<8)+NFSR+9+1,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 1

	add		#-(30-1)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 2

	move	#%0000000011111111,(a2) ; Endmask 1. [12]
	move	d7,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move	#((BUSY+HOG)<<8)+1,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 29

	add		#-(2-29)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 28

	move	#%0000000111111111,(a2) ; Endmask 1. [12]
	move	#%1111111111100000,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 3

	add		#-(28-3)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 4

	move	#%0000001111111111,(a2) ; Endmask 1. [12]
	move	#%1111111111110000,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 27

	add		#-(4-27)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 26

	move	#%0000011111111111,(a2) ; Endmask 1. [12]
	move	#%1111111111111000,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 5

	add		#-(26-5)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 6

	move	#%0000111111111111,(a2) ; Endmask 1. [12]
	move	#%1111111111111100,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 25

	add		#-(6-25)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 24

	move	#%0001111111111111,(a2) ; Endmask 1. [12]
	move	#%1111111111111110,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 23

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 7

	add		#-(23-7)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 8

	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 9

	move	#%0011111111111111,(a2) ; Endmask 1. [12]
	move	#%1111111111111111,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 10

	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 11

	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 22

	add		#-(11-22)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 21

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 20

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 19

	move	d1,(a1) ; Destination Y Increment

	move	#%0111111111111111,(a2) ; Endmask 1 + 2. [20]
	move	#%1000000000000000,(a3) ; Endmask 3. [12]
	add		d5,(a4)+ ; Destination Address. [12]
	move.l	d3,(a4) ; X Count, Y Count
	move	#((BUSY+HOG)<<8)+NFSR+1,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 18

	add		d5,-(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 17

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 16

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 15

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 14

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 13

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 12

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	rts

.draw_bob_2
	move	(sp)+,(a4)+ ; Destination Address (low word)
	
	move.l	draw_sprite_data_address,(a0) ; Source Address

	; 0

	move	d0,(a1) ; Destination Y Increment

	move	#%0000000000000011,(a2) ; Endmask 1. [12]
	move	#%1111110000000000,(a3) ; Endmask 3. [12]
	move.l	d2,(a4) ; X Count, Y Count
	move	#((BUSY+HOG)<<8)+NFSR+12+2,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 31

	add		#-(0-31)*VIRTUAL_DISPLAY_WIDTH/2-8,-(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 30

	move	#%0000000000011111,(a2) ; Endmask 1. [12]
	move	#%1111111110000000,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move	#((BUSY+HOG)<<8)+NFSR+9+2,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 1

	add		#-(30-1)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 2

	move	#%0000000001111111,(a2) ; Endmask 1. [12]
	move	#%1111111111100000,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move	#((BUSY+HOG)<<8)+2,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 29

	add		#-(2-29)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 28

	move	#%0000000011111111,(a2) ; Endmask 1. [12]
	move	#%1111111111110000,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 3

	add		#-(28-3)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 4

	move	#%0000000111111111,(a2) ; Endmask 1. [12]
	move	#%1111111111111000,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 27

	add		#-(4-27)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 26

	move	#%0000001111111111,(a2) ; Endmask 1. [12]
	move	#%1111111111111100,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 5

	add		#-(26-5)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 6

	move	#%0000011111111111,(a2) ; Endmask 1. [12]
	move	#%1111111111111110,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 25

	add		#-(6-25)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 24

	move	#%0000111111111111,(a2) ; Endmask 1. [12]
	move	#%1111111111111111,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 23

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 7

	add		#-(23-7)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 8

	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 9

	move	d1,(a1) ; Destination Y Increment

	move	#%0001111111111111,(a2) ; Endmask 1 + 2. [20]
	move	#%1000000000000000,(a3) ; Endmask 3. [12]
	add		d4,(a4)+ ; Destination Address. [12]
	move.l	d3,(a4) ; X Count, Y Count
	move	#((BUSY+HOG)<<8)+NFSR+2,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 10

	add		d4,-(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 11

	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 22

	add		#-(11-22)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 21

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 20

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 19

	move	#%0011111111111111,(a2) ; Endmask 1. [12]
	move	#%1100000000000000,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 18

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 17

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 16

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 15

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 14

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 13

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 12

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	rts

.draw_bob_3
	move	(sp)+,(a4)+ ; Destination Address (low word)
	
	move.l	draw_sprite_data_address,(a0) ; Source Address

	; 0

	move	d0,(a1) ; Destination Y Increment

	move	#%0000000000000001,(a2) ; Endmask 1. [12]
	move	#%1111111000000000,(a3) ; Endmask 3. [12]
	move.l	d2,(a4) ; X Count, Y Count
	move	#((BUSY+HOG)<<8)+NFSR+12+3,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 31

	add		#-(0-31)*VIRTUAL_DISPLAY_WIDTH/2-8,-(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 30

	move	#%0000000000001111,(a2) ; Endmask 1. [12]
	move	d7,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move	#((BUSY+HOG)<<8)+NFSR+9+3,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 1

	add		#-(30-1)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 2

	move	#%0000000000111111,(a2) ; Endmask 1. [12]
	move	#%1111111111110000,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move	#((BUSY+HOG)<<8)+3,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 29

	add		#-(2-29)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 28

	move	#%0000000001111111,(a2) ; Endmask 1. [12]
	move	#%1111111111111000,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 3

	add		#-(28-3)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 4

	move	#%0000000011111111,(a2) ; Endmask 1. [12]
	move	#%1111111111111100,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 27

	add		#-(4-27)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 26

	move	#%0000000111111111,(a2) ; Endmask 1. [12]
	move	#%1111111111111110,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 5

	add		#-(26-5)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 6

	move	#%0000001111111111,(a2) ; Endmask 1. [12]
	move	#%1111111111111111,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 25

	add		#-(6-25)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 24

	move	d1,(a1) ; Destination Y Increment

	move	#%0000011111111111,(a2) ; Endmask 1 + 2. [20]
	move	#%1000000000000000,(a3) ; Endmask 3. [12]
	add		d5,(a4)+ ; Destination Address. [12]
	move.l	d3,(a4) ; X Count, Y Count
	move	#((BUSY+HOG)<<8)+NFSR+3,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 23

	add		d5,-(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 7

	add		#-(23-7)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 8

	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 9

	move	#%0000111111111111,(a2) ; Endmask 1. [12]
	move	#%1100000000000000,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 10

	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 11

	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 22

	add		#-(11-22)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 21

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 20

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 19

	move	#%0001111111111111,(a2) ; Endmask 1. [12]
	move	#%1110000000000000,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 18

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 17

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 16

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 15

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 14

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 13

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 12

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	rts

.draw_bob_4
	move	(sp)+,(a4)+ ; Destination Address (low word)
	
	move.l	draw_sprite_data_address,(a0) ; Source Address

	; 0

	move	#-16*(1-1)/2+2,(a1) ; Destination Y Increment

	move	#%1111111100000000,(a2) ; Endmask 1. [12]
	move.l	d6,(a4) ; X Count, Y Count
	addq	#8,-(a4)
	move	#((BUSY+HOG)<<8)+0,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 31

	add		#-(0-31)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 30

	move	d0,(a1) ; Destination Y Increment

	move	#%0000000000000111,(a2) ; Endmask 1. [12]
	move	#%1111111111100000,(a3) ; Endmask 3. [12]
	add		#-(31-30)*VIRTUAL_DISPLAY_WIDTH/2-8-8,(a4)+ ; Destination Address. [16]
	move.l	d2,(a4) ; X Count, Y Count
	move	#((BUSY+HOG)<<8)+NFSR+9+4,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 1

	add		#-(30-1)*VIRTUAL_DISPLAY_WIDTH/2-8,-(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 2

	move	#%0000000000011111,(a2) ; Endmask 1. [12]
	move	#%1111111111111000,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move	#((BUSY+HOG)<<8)+4,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 29

	add		#-(2-29)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 28

	move	#%0000000000111111,(a2) ; Endmask 1. [12]
	move	#%1111111111111100,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 3

	add		#-(28-3)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 4

	move	#%0000000001111111,(a2) ; Endmask 1. [12]
	move	#%1111111111111110,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 27

	add		#-(4-27)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 26

	move	#%0000000011111111,(a2) ; Endmask 1. [12]
	move	#%1111111111111111,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 5

	add		#-(26-5)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 6

	move	d1,(a1) ; Destination Y Increment

	move	#%0000000111111111,(a2) ; Endmask 1 + 2. [20]
	move	#%1000000000000000,(a3) ; Endmask 3. [12]
	add		d4,(a4)+ ; Destination Address. [12]
	move.l	d3,(a4) ; X Count, Y Count
	move	#((BUSY+HOG)<<8)+NFSR+4,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 25

	add		#-(6-25)*VIRTUAL_DISPLAY_WIDTH/2-8,-(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 24

	move	#%0000001111111111,(a2) ; Endmask 1. [12]
	move	#%1100000000000000,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 23

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 7

	add		#-(23-7)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 8

	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 9

	move	#%0000011111111111,(a2) ; Endmask 1. [12]
	move	#%1110000000000000,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 10

	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 11

	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 22

	add		#-(11-22)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 21

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 20

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 19

	move	#%0000111111111111,(a2) ; Endmask 1. [12]
	move	#%1111000000000000,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 18

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 17

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 16

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 15

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 14

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 13

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 12

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	rts

.draw_bob_5
	move	(sp)+,(a4)+ ; Destination Address (low word)
	
	move.l	draw_sprite_data_address,(a0) ; Source Address

	; 0

	move	#-16*(1-1)/2+2,(a1) ; Destination Y Increment

	move	#%0111111110000000,(a2) ; Endmask 1. [12]
	move.l	d6,(a4) ; X Count, Y Count
	addq	#8,-(a4)
	move	#((BUSY+HOG)<<8)+1,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 31

	add		#-(0-31)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 30

	move	d0,(a1) ; Destination Y Increment

	move	#%0000000000000011,(a2) ; Endmask 1. [12]
	move	#%1111111111110000,(a3) ; Endmask 3. [12]
	add		#-(31-30)*VIRTUAL_DISPLAY_WIDTH/2-8-8,(a4)+ ; Destination Address. [16]
	move.l	d2,(a4) ; X Count, Y Count
	move	#((BUSY+HOG)<<8)+NFSR+9+5,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 1

	add		#-(30-1)*VIRTUAL_DISPLAY_WIDTH/2-8,-(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 2

	move	#%0000000000001111,(a2) ; Endmask 1. [12]
	move	#%1111111111111100,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move	#((BUSY+HOG)<<8)+5,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 29

	add		#-(2-29)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 28

	move	#%0000000000011111,(a2) ; Endmask 1. [12]
	move	#%1111111111111110,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 3

	add		#-(28-3)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 4

	move	#%0000000000111111,(a2) ; Endmask 1. [12]
	move	#%1111111111111111,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 27

	add		#-(4-27)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 26

	move	d1,(a1) ; Destination Y Increment

	move	#%0000000001111111,(a2) ; Endmask 1 + 2. [20]
	move	#%1000000000000000,(a3) ; Endmask 3. [12]
	add		d5,(a4)+ ; Destination Address. [12]
	move.l	d3,(a4) ; X Count, Y Count
	move	#((BUSY+HOG)<<8)+NFSR+5,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 5

	add		#-(26-5)*VIRTUAL_DISPLAY_WIDTH/2-8,-(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 6

	move	#%0000000011111111,(a2) ; Endmask 1. [12]
	move	#%1100000000000000,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 25

	add		#-(6-25)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 24

	move	#%0000000111111111,(a2) ; Endmask 1. [12]
	move	#%1110000000000000,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 23

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 7

	add		#-(23-7)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 8

	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 9

	move	#%0000001111111111,(a2) ; Endmask 1. [12]
	move	#%1111000000000000,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 10

	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 11

	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 22

	add		#-(11-22)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 21

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 20

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 19

	move	#%0000011111111111,(a2) ; Endmask 1. [12]
	move	#%1111100000000000,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 18

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 17

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 16

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 15

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 14

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 13

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 12

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	rts

.draw_bob_6
	move	(sp)+,(a4)+ ; Destination Address (low word)
	
	move.l	draw_sprite_data_address,(a0) ; Source Address

	; 0

	move	#-16*(1-1)/2+2,(a1) ; Destination Y Increment

	move	#%0011111111000000,(a2) ; Endmask 1. [12]
	move.l	d6,(a4) ; X Count, Y Count
	addq	#8,-(a4)
	move	#((BUSY+HOG)<<8)+2,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 31

	add		#-(0-31)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 30

	move	d0,(a1) ; Destination Y Increment

	move	#%0000000000000001,(a2) ; Endmask 1. [12]
	move	#%1111111111111000,(a3) ; Endmask 3. [12]
	add		#-(31-30)*VIRTUAL_DISPLAY_WIDTH/2-8-8,(a4)+ ; Destination Address. [16]
	move.l	d2,(a4) ; X Count, Y Count
	move	#((BUSY+HOG)<<8)+NFSR+9+6,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 1

	add		#-(30-1)*VIRTUAL_DISPLAY_WIDTH/2-8,-(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 2

	move	#%0000000000000111,(a2) ; Endmask 1. [12]
	move	#%1111111111111110,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move	#((BUSY+HOG)<<8)+6,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 29

	add		#-(2-29)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 28

	move	#%0000000000001111,(a2) ; Endmask 1. [12]
	move	#%1111111111111111,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 3

	add		#-(28-3)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 4

	move	d1,(a1) ; Destination Y Increment

	move	#%0000000000011111,(a2) ; Endmask 1 + 2. [20]
	move	#%1000000000000000,(a3) ; Endmask 3. [12]
	add		d4,(a4)+ ; Destination Address. [12]
	move.l	d3,(a4) ; X Count, Y Count
	move	#((BUSY+HOG)<<8)+NFSR+6,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 27

	add		#-(4-27)*VIRTUAL_DISPLAY_WIDTH/2-8,-(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 26

	move	#%0000000000111111,(a2) ; Endmask 1. [12]
	move	#%1100000000000000,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 5

	add		#-(26-5)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 6

	move	#%0000000001111111,(a2) ; Endmask 1. [12]
	move	#%1110000000000000,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 25

	add		#-(6-25)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 24

	move	#%0000000011111111,(a2) ; Endmask 1. [12]
	move	#%1111000000000000,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 23

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 7

	add		#-(23-7)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 8

	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 9

	move	#%0000000111111111,(a2) ; Endmask 1. [12]
	move	#%1111100000000000,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 10

	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 11

	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 22

	add		#-(11-22)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 21

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 20

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 19

	move	#%0000001111111111,(a2) ; Endmask 1. [12]
	move	#%1111110000000000,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 18

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 17

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 16

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 15

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 14

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 13

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 12

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	rts

.draw_bob_7
	move	(sp)+,(a4)+ ; Destination Address (low word)
	
	move.l	draw_sprite_data_address,(a0) ; Source Address

	; 0

	move	#-16*(1-1)/2+2,(a1) ; Destination Y Increment

	move	#%0001111111100000,(a2) ; Endmask 1. [12]
	move.l	d6,(a4) ; X Count, Y Count
	addq	#8,-(a4)
	move	#((BUSY+HOG)<<8)+3,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 31

	add		#-(0-31)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 30

	move	#%1111111111111100,(a2) ; Endmask 1. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move	#((BUSY+HOG)<<8)+0,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 1

	add		#-(30-1)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 2

	move	d0,(a1) ; Destination Y Increment

	move	#%0000000000000011,(a2) ; Endmask 1. [12]
	move	#%1111111111111111,(a3) ; Endmask 3. [12]
	add		#-(1-2)*VIRTUAL_DISPLAY_WIDTH/2-8-8,(a4)+ ; Destination Address. [16]
	move.l	d2,(a4) ; X Count, Y Count
	move	#((BUSY+HOG)<<8)+7,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 29

	add		#-(2-29)*VIRTUAL_DISPLAY_WIDTH/2-8,-(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 28

	move	d1,(a1) ; Destination Y Increment

	move	#%0000000000000111,(a2) ; Endmask 1 + 2. [20]
	move	#%1000000000000000,(a3) ; Endmask 3. [12]
	add		d5,(a4)+ ; Destination Address. [12]
	move.l	d3,(a4) ; X Count, Y Count
	move	#((BUSY+HOG)<<8)+NFSR+7,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 3

	add		#-(28-3)*VIRTUAL_DISPLAY_WIDTH/2-8,-(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 4

	move	#%0000000000001111,(a2) ; Endmask 1. [12]
	move	#%1100000000000000,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 27

	add		#-(4-27)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 26

	move	#%0000000000011111,(a2) ; Endmask 1. [12]
	move	#%1110000000000000,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 5

	add		#-(26-5)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 6

	move	#%0000000000111111,(a2) ; Endmask 1. [12]
	move	#%1111000000000000,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 25

	add		#-(6-25)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 24

	move	#%0000000001111111,(a2) ; Endmask 1. [12]
	move	#%1111100000000000,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 23

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 7

	add		#-(23-7)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 8

	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 9

	move	#%0000000011111111,(a2) ; Endmask 1. [12]
	move	#%1111110000000000,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 10

	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 11

	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 22

	add		#-(11-22)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 21

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 20

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 19

	move	#%0000000111111111,(a2) ; Endmask 1. [12]
	move	#%1111111000000000,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 18

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 17

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 16

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 15

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 14

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 13

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 12

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	rts

.draw_bob_8
	move	(sp)+,(a4)+ ; Destination Address (low word)
	
	move.l	draw_sprite_data_address,(a0) ; Source Address

	; 0

	move	#-16*(1-1)/2+2,(a1) ; Destination Y Increment

	move	#%0000111111110000,(a2) ; Endmask 1. [12]
	move.l	d6,(a4) ; X Count, Y Count
	addq	#8,-(a4) ; Destination Address. [12]
	move	#((BUSY+HOG)<<8)+4,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 31

	add		#-(0-31)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 30

	move	#%0111111111111110,(a2) ; Endmask 1. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move	#((BUSY+HOG)<<8)+1,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 1

	add		#-(30-1)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 2

	move	d1,(a1) ; Destination Y Increment

	move	#%0000000000000001,(a2) ; Endmask 1 + 2. [20]
	move	#%1000000000000000,(a3) ; Endmask 3. [12]
	add		#-(2-3)*VIRTUAL_DISPLAY_WIDTH/2-8-8,(a4)+ ; Destination Address. [16]
	move.l	d3,(a4) ; X Count, Y Count
	move	#((BUSY+HOG)<<8)+NFSR+8,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 29

	add		#-(2-29)*VIRTUAL_DISPLAY_WIDTH/2-8,-(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 28

	move	#%0000000000000011,(a2) ; Endmask 1. [12]
	move	#%1100000000000000,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 3

	add		#-(28-3)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 4

	move	#%0000000000000111,(a2) ; Endmask 1. [12]
	move	#%1110000000000000,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 27

	add		#-(4-27)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 26

	move	#%0000000000001111,(a2) ; Endmask 1. [12]
	move	#%1111000000000000,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 5

	add		#-(26-5)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 6

	move	#%0000000000011111,(a2) ; Endmask 1. [12]
	move	#%1111100000000000,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 25

	add		#-(6-25)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 24

	move	#%0000000000111111,(a2) ; Endmask 1. [12]
	move	#%1111110000000000,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 23

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 7

	add		#-(23-7)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 8

	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 9

	move	#%0000000001111111,(a2) ; Endmask 1. [12]
	move	#%1111111000000000,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 10

	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 11

	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 22

	add		#-(11-22)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 21

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 20

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 19

	move	#%0000000011111111,(a2) ; Endmask 1. [12]
	move	#%1111111100000000,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 18

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 17

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 16

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 15

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 14

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 13

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 12

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	rts

.draw_bob_9
	move	(sp)+,(a4)+ ; Destination Address (low word)
	
	move.l	draw_sprite_data_address,(a0) ; Source Address

	; 0

	move	#-16*(1-1)/2+2,(a1) ; Destination Y Increment

	move	#%0000011111111000,(a2) ; Endmask 1. [12]
	move.l	d6,(a4) ; X Count, Y Count
	addq	#8,-(a4) ; Destination Address. [12]
	move	#((BUSY+HOG)<<8)+5,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 31

	add		#-(0-31)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 30

	move	#%0011111111111111,(a2) ; Endmask 1. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move	#((BUSY+HOG)<<8)+2,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 1

	add		#-(30-1)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 2

	move	d0,(a1) ; Destination Y Increment

	move	#%1111111111111111,(a2) ; Endmask 1. [12]
	move	#%1100000000000000,(a3) ; Endmask 3. [12]
	add		d4,(a4)+ ; Destination Address. [16]
	move.l	d2,(a4) ; X Count, Y Count
	move	#((BUSY+HOG)<<8)+FXSR+NFSR+9,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 29

	add		#-(2-29)*VIRTUAL_DISPLAY_WIDTH/2-8,-(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 28

	move	d1,(a1) ; Destination Y Increment

	move	#%0000000000000001,(a2) ; Endmask 1 + 2. [12]
	move	#%1110000000000000,(a3) ; Endmask 3. [12]
	add		#-(29-28)*VIRTUAL_DISPLAY_WIDTH/2-8-8,(a4)+ ; Destination Address. [16]
	move.l	d3,(a4) ; X Count, Y Count
	move	#((BUSY+HOG)<<8)+NFSR+9,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 3

	add		#-(28-3)*VIRTUAL_DISPLAY_WIDTH/2-8,-(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 4

	move	#%0000000000000011,(a2) ; Endmask 1. [12]
	move	#%1111000000000000,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 27

	add		#-(4-27)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 26

	move	#%0000000000000111,(a2) ; Endmask 1. [12]
	move	#%1111100000000000,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 5

	add		#-(26-5)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 6

	move	#%0000000000001111,(a2) ; Endmask 1. [12]
	move	#%1111110000000000,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 25

	add		#-(6-25)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 24

	move	#%0000000000011111,(a2) ; Endmask 1. [12]
	move	#%1111111000000000,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 23

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 7

	add		#-(23-7)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 8

	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 9

	move	#%0000000000111111,(a2) ; Endmask 1. [12]
	move	#%1111111100000000,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 10

	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 11

	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 22

	add		#-(11-22)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 21

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 20

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 19

	move	#%0000000001111111,(a2) ; Endmask 1. [12]
	move	#%1111111110000000,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 18

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 17

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 16

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 15

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 14

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 13

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 12

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	rts

.draw_bob_a
	move	(sp)+,(a4)+ ; Destination Address (low word)
	
	move.l	draw_sprite_data_address,(a0) ; Source Address

	; 0

	move	#-16*(1-1)/2+2,(a1) ; Destination Y Increment

	move	#%0000001111111100,(a2) ; Endmask 1. [12]
	move.l	d6,(a4) ; X Count, Y Count
	addq	#8,-(a4) ; Destination Address. [12]
	move	#((BUSY+HOG)<<8)+6,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 31

	add		#-(0-31)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 30

	move	d0,(a1) ; Destination Y Increment

	move	#%0001111111111111,(a2) ; Endmask 1. [12]
	move	#%1000000000000000,(a3) ; Endmask 3. [12]
	add		d5,(a4)+ ; Destination Address. [12]
	move.l	d2,(a4) ; X Count, Y Count
	move	#((BUSY+HOG)<<8)+NFSR+3,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 1

	add		#-(30-1)*VIRTUAL_DISPLAY_WIDTH/2-8,-(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 2

	move	#%0111111111111111,(a2) ; Endmask 1. [12]
	move	#%1110000000000000,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move	#((BUSY+HOG)<<8)+FXSR+NFSR+10,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 29

	add		#-(2-29)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 28

	move	#%1111111111111111,(a2) ; Endmask 1. [12]
	move	#%1111000000000000,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 3

	add		#-(28-3)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 4

	move	d1,(a1) ; Destination Y Increment

	move.l	#%00000000000000011111111111111111,(a2) ; Endmask 1 + 2. [20]
	move	#%1111100000000000,(a3) ; Endmask 3. [12]
	add		#VIRTUAL_DISPLAY_WIDTH/2-8-8,(a4)+ ; Destination Address. [16]
	move.l	d3,(a4) ; X Count, Y Count
	move	#((BUSY+HOG)<<8)+NFSR+10,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 27

	add		#-(4-27)*VIRTUAL_DISPLAY_WIDTH/2-8,-(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 26

	move	#%0000000000000011,(a2) ; Endmask 1. [12]
	move	#%1111110000000000,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 5

	add		#-(26-5)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 6

	move	#%0000000000000111,(a2) ; Endmask 1. [12]
	move	#%1111111000000000,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 25

	add		#-(6-25)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 24

	move	#%0000000000001111,(a2) ; Endmask 1. [12]
	move	#%1111111100000000,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 23

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 7

	add		#-(23-7)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 8

	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 9

	move	#%0000000000011111,(a2) ; Endmask 1. [12]
	move	#%1111111110000000,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 10

	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 11

	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 22

	add		#-(11-22)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 21

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 20

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 19

	move	#%0000000000111111,(a2) ; Endmask 1. [12]
	move	d7,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 18

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 17

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 16

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 15

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 14

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 13

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 12

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	rts

.draw_bob_b
	move	(sp)+,(a4)+ ; Destination Address (low word)
	
	move.l	draw_sprite_data_address,(a0) ; Source Address

	; 0

	move	#-16*(1-1)/2+2,(a1) ; Destination Y Increment

	move	#%0000000111111110,(a2) ; Endmask 1. [12]
	move.l	d6,(a4) ; X Count, Y Count
	addq	#8,-(a4) ; Destination Address. [12]
	move	#((BUSY+HOG)<<8)+7,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 31

	add		#-(0-31)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 30

	move	d0,(a1) ; Destination Y Increment

	move	#%0000111111111111,(a2) ; Endmask 1. [12]
	move	#%1100000000000000,(a3) ; Endmask 3. [12]
	add		d5,(a4)+ ; Destination Address. [12]
	move.l	d2,(a4) ; X Count, Y Count
	move	#((BUSY+HOG)<<8)+NFSR+4,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 1

	add		#-(30-1)*VIRTUAL_DISPLAY_WIDTH/2-8,-(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 2

	move	#%0011111111111111,(a2) ; Endmask 1. [12]
	move	#%1111000000000000,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move	#((BUSY+HOG)<<8)+NFSR+FXSR+11,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 29

	add		#-(2-29)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 28

	move	#%0111111111111111,(a2) ; Endmask 1. [12]
	move	#%1111100000000000,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 3

	add		#-(28-3)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 4

	move	#%1111111111111111,(a2) ; Endmask 1. [12]
	move	#%1111110000000000,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 27

	add		#-(4-27)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 26

	move	d1,(a1) ; Destination Y Increment

	move	#%0000000000000001,(a2) ; Endmask 1 + 2. [20]
	move	#%1111111000000000,(a3) ; Endmask 3. [12]
	add		#-VIRTUAL_DISPLAY_WIDTH/2-8-8,(a4)+ ; Destination Address. [16]
	move.l	d3,(a4) ; X Count, Y Count
	move	#((BUSY+HOG)<<8)+NFSR+11,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 5

	add		#-(26-5)*VIRTUAL_DISPLAY_WIDTH/2-8,-(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 6

	move	#%0000000000000011,(a2) ; Endmask 1. [12]
	move	#%1111111100000000,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 25

	add		#-(6-25)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 24

	move	#%0000000000000111,(a2) ; Endmask 1. [12]
	move	#%1111111110000000,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 23

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 7

	add		#-(23-7)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 8

	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 9

	move	#%0000000000001111,(a2) ; Endmask 1. [12]
	move	d7,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 10

	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 11

	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 22

	add		#-(11-22)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 21

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 20

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 19

	move	#%0000000000011111,(a2) ; Endmask 1. [12]
	move	#%1111111111100000,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 18

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 17

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 16

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 15

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 14

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 13

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 12

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	rts

.draw_bob_c
	move	(sp)+,(a4)+ ; Destination Address (low word)
	
	move.l	draw_sprite_data_address,(a0) ; Source Address

	; 0

	move	#-16*(1-1)/2+2,(a1) ; Destination Y Increment

	move	#%0000000011111111,(a2) ; Endmask 1. [12]
	move.l	d6,(a4) ; X Count, Y Count
	addq	#8,-(a4) ; Destination Address. [12]
	move	#((BUSY+HOG)<<8)+8,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 31

	add		#-(0-31)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 30

	move	d0,(a1) ; Destination Y Increment

	move	#%0000011111111111,(a2) ; Endmask 1. [12]
	move	#%1110000000000000,(a3) ; Endmask 3. [12]
	add		d5,(a4)+ ; Destination Address. [12]
	move.l	d2,(a4) ; X Count, Y Count
	move	#((BUSY+HOG)<<8)+NFSR+5,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 1

	add		#-(30-1)*VIRTUAL_DISPLAY_WIDTH/2-8,-(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 2

	move	#%0001111111111111,(a2) ; Endmask 1. [12]
	move	#%1111100000000000,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move	#((BUSY+HOG)<<8)+FXSR+NFSR+12,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 29

	add		#-(2-29)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 28

	move	#%0011111111111111,(a2) ; Endmask 1. [12]
	move	#%1111110000000000,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 3

	add		#-(28-3)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 4

	move	#%0111111111111111,(a2) ; Endmask 1. [12]
	move	#%1111111000000000,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 27

	add		#-(4-27)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 26

	move	#%1111111111111111,(a2) ; Endmask 1. [12]
	move	#%1111111100000000,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 5

	add		#-(26-5)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 6

	move	d1,(a1) ; Destination Y Increment

	move	#%0000000000000001,(a2) ; Endmask 1 + 2. [20]
	move	#%1111111110000000,(a3) ; Endmask 3. [12]
	add		#VIRTUAL_DISPLAY_WIDTH/2-8-8,(a4)+ ; Destination Address. [16]
	move.l	d3,(a4) ; X Count, Y Count
	move	#((BUSY+HOG)<<8)+NFSR+12,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 25

	add		#-(6-25)*VIRTUAL_DISPLAY_WIDTH/2-8,-(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 24

	move	#%0000000000000011,(a2) ; Endmask 1. [12]
	move	d7,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 23

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 7

	add		#-(23-7)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 8

	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 9

	move	#%0000000000000111,(a2) ; Endmask 1. [12]
	move	#%1111111111100000,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 10

	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 11

	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 22

	add		#-(11-22)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 21

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 20

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 19

	move	#%0000000000001111,(a2) ; Endmask 1. [12]
	move	#%1111111111110000,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 18

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 17

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 16

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 15

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 14

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 13

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 12

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	rts

.draw_bob_d
	move	(sp)+,(a4)+ ; Destination Address (low word)
	
	move.l	draw_sprite_data_address,(a0) ; Source Address

	; 0

	move	d0,(a1) ; Destination Y Increment

	move	#%0000000001111111,(a2) ; Endmask 1. [12]
	move	#%1000000000000000,(a3) ; Endmask 3. [12]
	move.l	d2,(a4) ; X Count, Y Count
	addq	#8,-(a4) ; Destination Address. [12]
	move	#((BUSY+HOG)<<8)+NFSR+9,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 31

	add		#-(0-31)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 30

	move	#%0000001111111111,(a2) ; Endmask 1. [12]
	move	#%1111000000000000,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move	#((BUSY+HOG)<<8)+NFSR+6,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 1

	add		#-(30-1)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 2

	move	#%0000111111111111,(a2) ; Endmask 1. [12]
	move	#%1111110000000000,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move	#((BUSY+HOG)<<8)+NFSR+FXSR+13,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 29

	add		#-(2-29)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 28

	move	#%0001111111111111,(a2) ; Endmask 1. [12]
	move	#%1111111000000000,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 3

	add		#-(28-3)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 4

	move	#%0011111111111111,(a2) ; Endmask 1. [12]
	move	#%1111111100000000,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 27

	add		#-(4-27)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 26

	move	#%0111111111111111,(a2) ; Endmask 1. [12]
	move	#%1111111110000000,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 5

	add		#-(26-5)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 6

	move	#%1111111111111111,(a2) ; Endmask 1. [12]
	move	d7,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 25

	add		#-(6-25)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 24

	move	d1,(a1) ; Destination Y Increment

	move	#%0000000000000001,(a2) ; Endmask 1 + 2. [20]
	move	#%1111111111100000,(a3) ; Endmask 3. [12]
	add		#-VIRTUAL_DISPLAY_WIDTH/2-8-8,(a4)+ ; Destination Address. [16]
	move.l	d3,(a4) ; X Count, Y Count
	move	#((BUSY+HOG)<<8)+NFSR+13,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 23

	add		d5,-(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 7

	add		#-(23-7)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 8

	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 9

	move	#%0000000000000011,(a2) ; Endmask 1. [12]
	move	#%1111111111110000,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 10

	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 11

	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 22

	add		#-(11-22)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 21

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 20

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 19

	move	#%0000000000000111,(a2) ; Endmask 1. [12]
	move	#%1111111111111000,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 18

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 17

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 16

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 15

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 14

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 13

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 12

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	rts

.draw_bob_e
	move	(sp)+,(a4)+ ; Destination Address (low word)
	
	move.l	draw_sprite_data_address,(a0) ; Source Address

	; 0

	move	d0,(a1) ; Destination Y Increment

	move	#%0000000000111111,(a2) ; Endmask 1. [12]
	move	#%1100000000000000,(a3) ; Endmask 3. [12]
	move.l	d2,(a4) ; X Count, Y Count
	addq	#8,-(a4) ; Destination Address. [12]
	move	#((BUSY+HOG)<<8)+NFSR+10,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 31

	add		#-(0-31)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 30

	move	#%0000000111111111,(a2) ; Endmask 1. [12]
	move	#%1111100000000000,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move	#((BUSY+HOG)<<8)+NFSR+7,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 1

	add		#-(30-1)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 2

	move	#%0000011111111111,(a2) ; Endmask 2. [12]
	move	#%1111111000000000,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move	#((BUSY+HOG)<<8)+NFSR+FXSR+14,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 29

	add		#-(2-29)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 28

	move	#%0000111111111111,(a2) ; Endmask 1. [12]
	move	#%1111111100000000,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 3

	add		#-(28-3)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 4

	move	#%0001111111111111,(a2) ; Endmask 1. [12]
	move	#%1111111110000000,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 27

	add		#-(4-27)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 26

	move	#%0011111111111111,(a2) ; Endmask 1. [12]
	move	d7,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 5

	add		#-(26-5)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 6

	move	#%0111111111111111,(a2) ; Endmask 1. [12]
	move	#%1111111111100000,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 25

	add		#-(6-25)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 24

	move	#%1111111111111111,(a2) ; Endmask 1. [12]
	move	#%1111111111110000,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 23

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 7

	add		#-(23-7)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 8

	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 9

	move	d1,(a1) ; Destination Y Increment

	move	#%0000000000000001,(a2) ; Endmask 1 + 2. [20]
	move	#%1111111111111000,(a3) ; Endmask 3. [12]
	add		#VIRTUAL_DISPLAY_WIDTH/2-8-8,(a4)+ ; Destination Address. [16]
	move.l	d3,(a4) ; X Count, Y Count
	move	#((BUSY+HOG)<<8)+NFSR+14,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 10

	add		d4,-(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 11

	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 22

	add		#-(11-22)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 21

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 20

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 19

	move	#%0000000000000011,(a2) ; Endmask 1. [12]
	move	#%1111111111111100,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 18

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 17

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 16

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 15

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 14

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 13

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 12

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	rts

.draw_bob_f
	move	(sp)+,(a4)+ ; Destination Address (low word)
	
	move.l	draw_sprite_data_address,(a0) ; Source Address

	; 0

	move	d0,(a1) ; Destination Y Increment

	move	#%0000000000011111,(a2) ; Endmask 1. [12]
	move	#%1110000000000000,(a3) ; Endmask 3. [12]
	move.l	d2,(a4) ; X Count, Y Count
	addq	#8,-(a4) ; Destination Address. [12]
	move	#((BUSY+HOG)<<8)+NFSR+11,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 31

	add		#-(0-31)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 30

	move	#%0000000011111111,(a2) ; Endmask 1. [12]
	move	#%1111110000000000,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move	#((BUSY+HOG)<<8)+NFSR+8,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 1

	add		#-(30-1)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 2

	move	#%0000001111111111,(a2) ; Endmask 1. [12]
	move	#%1111111100000000,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move	#((BUSY+HOG)<<8)+NFSR+FXSR+15,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 29

	add		#-(2-29)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 28

	move	#%0000011111111111,(a2) ; Endmask 1. [12]
	move	#%1111111110000000,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 3

	add		#-(28-3)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 4

	move	#%0000111111111111,(a2) ; Endmask 1. [12]
	move	d7,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 27

	add		#-(4-27)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 26

	move	#%0001111111111111,(a2) ; Endmask 1. [12]
	move	#%1111111111100000,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 5

	add		#-(26-5)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 6

	move	#%0011111111111111,(a2) ; Endmask 1. [12]
	move	#%1111111111110000,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 25

	add		#-(6-25)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 24

	move	#%0111111111111111,(a2) ; Endmask 1. [12]
	move	#%1111111111111000,(a3) ; Endmask 3. [12]
	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 23

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 7

	add		#-(23-7)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 8

	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 9

	move	#%1111111111111111,(a2) ; Endmask 1. [12]
	move	#%1111111111111100,(a3) ; Endmask 3. [12]
	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 10

	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 11

	add		d4,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 22

	add		#-(11-22)*VIRTUAL_DISPLAY_WIDTH/2-8,(a4) ; Destination Address. [16]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 21

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 20

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 19

	move	d1,(a1) ; Destination Y Increment

	move	#%0000000000000001,(a2) ; Endmask 1 + 2. [20]
	move	#%1111111111111110,(a3) ; Endmask 3. [12]
	add		#-VIRTUAL_DISPLAY_WIDTH/2-8-8,(a4)+ ; Destination Address. [16]
	move.l	d3,(a4) ; X Count, Y Count
	move	#((BUSY+HOG)<<8)+NFSR+15,(a6) ; Busy, Hog, Smudge, Line Number, FXSR, NFSR, Skew. [8]

	; 18

	add		d5,-(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 17

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 16

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 15

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 14

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 13

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	; 12

	add		d5,(a4) ; Destination Address. [12]
	move	d6,(a5) ; Y Count. [8]
	move.b	d7,(a6) ; Busy, Hog, Smudge, Line Number. [8]

	rts

; ------------------------------------------------------------------------------

	rem 

restore_bobs
	move	#2,$ffff8a20.w ; Source X increment
	move	#$ffff,$ffff8a28.w ; Endmask 1
	move	#$ffff,$ffff8a2a.w ; Endmask 2
	move	#$ffff,$ffff8a2c.w ; Endmask 3
	move	#2,$ffff8a2e.w ; Destination X increment
	move.b	#2,$ffff8a3a.w ; HOP 2 (source only)
	move.b	#3,$ffff8a3b.w ; OP 3 (destination = source)
	clr.b	$ffff8a3d.w ; FXSR, NFSR, Skew

	move.l	draw_clear_data_address,a0
	move.l	draw_screen_address,a1
	move.l	draw_last_sprite_coordinates_address,a2

	move	#NUMBER_OF_BOBS-1,d7

.restore_sprite_loop
;	not		$ffff8240.w
	
	moveq	#0,d1

	move	(a2)+,d0
	move	(a2)+,d1

	moveq	#$fffffff0,d2
	and		d0,d2
	lsr		#1,d2
	lea		(a0,d2.w),a3
	lea		(a1,d2.w),a4

	move	d1,d2
	lsl		#5,d2
	move	d2,d3
	lsl		#2,d2
	add		d3,d2
	add		d2,a3

	lsl.l	#8,d1
	add.l	d1,a4

	move.l	a3,$ffff8a24.w ; Source address
	move.l	a4,$ffff8a32.w ; Destination address
	move	#32,$ffff8a38.w ; Y Count

	and		#$f,d0
	bne		.no_restore_skew

	move	#2*4,$ffff8a36.w ; X Count
	move	#320/2-2*4*2+2,$ffff8a22.w ; Source Y increment
	move	#VIRTUAL_DISPLAY_WIDTH/2-2*4*2+2,$ffff8a30.w ; Destination Y Increment

	move.b	#$c0,$ffff8a3c.w ; Busy, Hog, Smudge, Line Number

	dbf		d7,.restore_sprite_loop

	rts

.no_restore_skew
	move	#3*4,$ffff8a36.w ; X Count
	move	#320/2-3*4*2+2,$ffff8a22.w ; Source Y increment
	move	#VIRTUAL_DISPLAY_WIDTH/2-3*4*2+2,$ffff8a30.w ; Destination Y Increment

	move.b	#$c0,$ffff8a3c.w ; Busy, Hog, Smudge, Line Number

	dbf		d7,.restore_sprite_loop

	rts

	erem

; ------------------------------------------------------------------------------

clear_bobs
	rem ; This code part has been moved to timer_a!

	move	#2,$ffff8a20.w ; Source X increment
	move	#$ffff,$ffff8a28.w ; Endmask 1
	move	#$ffff,$ffff8a2a.w ; Endmask 2
	move	#$ffff,$ffff8a2c.w ; Endmask 3
	move	#2,$ffff8a2e.w ; Destination X increment
	move	#VIRTUAL_DISPLAY_WIDTH/2-4*2+2,$ffff8a30.w ; Destination Y Increment
	move.b	#1,$ffff8a3a.w ; HOP 1 (halftone only)

	move.b	#3,$ffff8a3b.w ; OP 3 (destination = source)
;	move.b	#15,$ffff8a3b.w ; OP 0 (destination = 1)
;	move.b	#0,$ffff8a3b.w ; OP 0 (destination = 0)

	move.b	#0,$ffff8a3d.w ; FXSR, NFSR, Skew
	move	#4,$ffff8a36.w ; X Count

	lea		$ffff8a32+2.w,a4
	lea		$ffff8a38.w,a5
	lea		$ffff8a3c.w,a6

	erem

	move	draw_screen_address,$ffff8a32.w ; Destination address (high word)
	
	; Prepare clearing

	move.l	draw_bobs_clear_infos_address,a0

	moveq	#NUMBER_OF_BOBS-1,d7

.prepare_loop
	move	(a0)+,d0

	move	(a0)+,-(sp)

	move.l	.clear_bob_table(pc,d0.w),-(sp)

	dbf		d7,.prepare_loop

	; Clear bobs

	move	#-VIRTUAL_DISPLAY_WIDTH/2*(32-0)+8,d1
	move	#7<<8,d2
	move	#9<<8,d3
	move	#$0f00,d4
	moveq	#32,d5
	move	#$c000,d6
	move	#15<<8,d7

	rts ; Start clearing

.clear_bob_table
	dc.l	.clear_bob_0, .clear_bob_1, .clear_bob_2, .clear_bob_3
	dc.l	.clear_bob_4, .clear_bob_5, .clear_bob_6, .clear_bob_7
	dc.l	.clear_bob_8, .clear_bob_9, .clear_bob_a, .clear_bob_b
	dc.l	.clear_bob_c, .clear_bob_d, .clear_bob_e, .clear_bob_f

;  0 |            00001111
;  1 |         00000001111111
;  2 |       000000000111111111
;  3 |      00000000001111111111
;  4 |     0000000000011111111111
;  5 |    000000000000111111111111
;  6 |   00000000000001111111111111
;  7 |  0000000000000011111111111111
;  8 |  0000000000000011111111111111
;  9 | 000000000000000111111111111111
; 10 | 000000000000000111111111111111
; 11 | 000000000000000111111111111111
; 12 |00000000000000001111111111111111
; 13 |00000000000000001111111111111111
; 14 |00000000000000001111111111111111
; 15 |00000000000000001111111111111111
; 16 |00000000000000001111111111111111
; 17 |00000000000000001111111111111111
; 18 |00000000000000001111111111111111
; 19 |00000000000000001111111111111111
; 20 | 000000000000000111111111111111
; 21 | 000000000000000111111111111111
; 22 | 000000000000000111111111111111
; 23 |  0000000000000011111111111111
; 24 |  0000000000000011111111111111
; 25 |   00000000000001111111111111
; 26 |    000000000000111111111111
; 27 |     0000000000011111111111
; 28 |      00000000001111111111
; 29 |       000000000111111111
; 30 |         00000001111111
; 31 |            00001111

.clear_bob_0
	move	(sp)+,d0
	move	d0,(a4) ; Destination address (low word)

	and		d4,d0
	or		d6,d0

	move	d5,(a5) ; Y Count
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	add		d1,(a4) ; Destination address (low word)
;	add		#0<<8,d0
	move	d5,(a5) ; Y Count
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	rts

;  0 |             00011111
;  1 |          00000011111111
;  2 |        000000001111111111
;  3 |       00000000011111111111
;  4 |      0000000000111111111111
;  5 |     000000000001111111111111
;  6 |    00000000000011111111111111
;  7 |   0000000000000111111111111111
;  8 |   0000000000000111111111111111
;  9 |  000000000000001111111111111111
; 10 |  000000000000001111111111111111
; 11 |  000000000000001111111111111111
; 12 | 00000000000000011111111111111112
; 13 | 00000000000000011111111111111112
; 14 | 00000000000000011111111111111112
; 15 | 00000000000000011111111111111112
; 16 | 00000000000000011111111111111112
; 17 | 00000000000000011111111111111112
; 18 | 00000000000000011111111111111112
; 19 | 00000000000000011111111111111112
; 20 |  000000000000001111111111111111
; 21 |  000000000000001111111111111111
; 22 |  000000000000001111111111111111
; 23 |   0000000000000111111111111111
; 24 |   0000000000000111111111111111
; 25 |    00000000000011111111111111
; 26 |     000000000001111111111111
; 27 |      0000000000111111111111
; 28 |       00000000011111111111
; 29 |        000000001111111111
; 30 |          00000011111111
; 31 |             00011111

.clear_bob_1
	move	(sp)+,d0
	move	d0,(a4) ; Destination address (low word)

	and		d4,d0
	or		d6,d0

	move	d5,(a5) ; Y Count
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	add		d1,(a4) ; Destination address (low word)
;	add		#0<<8,d0
	move	d5,(a5) ; Y Count
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	add		#-VIRTUAL_DISPLAY_WIDTH/2*(32-12)+8,(a4) ; Destination address (low word)
	add		#12<<8,d0
	move	#20-12,(a5) ; Y Count
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	rts

;  0 |              00111111
;  1 |           00000111111111
;  2 |         000000011111111111
;  3 |        00000000111111111111
;  4 |       0000000001111111111111
;  5 |      000000000011111111111111
;  6 |     00000000000111111111111111
;  7 |    0000000000001111111111111111
;  8 |    0000000000001111111111111111
;  9 |   000000000000011111111111111112
; 10 |   000000000000011111111111111112
; 11 |   000000000000011111111111111112
; 12 |  00000000000000111111111111111122
; 13 |  00000000000000111111111111111122
; 14 |  00000000000000111111111111111122
; 15 |  00000000000000111111111111111122
; 16 |  00000000000000111111111111111122
; 17 |  00000000000000111111111111111122
; 18 |  00000000000000111111111111111122
; 19 |  00000000000000111111111111111122
; 20 |   000000000000011111111111111112
; 21 |   000000000000011111111111111112
; 22 |   000000000000011111111111111112
; 23 |    0000000000001111111111111111
; 24 |    0000000000001111111111111111
; 25 |     00000000000111111111111111
; 26 |      000000000011111111111111
; 27 |       0000000001111111111111
; 28 |        00000000111111111111
; 29 |         000000011111111111
; 30 |           00000111111111
; 31 |              00111111

.clear_bob_2
	move	(sp)+,d0
	move	d0,(a4) ; Destination address (low word)

	and		d4,d0
	or		d6,d0

	move	d5,(a5) ; Y Count
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	add		d1,(a4) ; Destination address (low word)
	move	d5,(a5) ; Y Count
;	add		#0<<8,d0
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	add		#-VIRTUAL_DISPLAY_WIDTH/2*(32-9)+8,(a4) ; Destination address (low word)
	move	#23-9,(a5) ; Y Count
	add		d3,d0
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	rts

;  0 |               01111111
;  1 |            00001111111111
;  2 |          000000111111111111
;  3 |         00000001111111111111
;  4 |        0000000011111111111111
;  5 |       000000000111111111111111
;  6 |      00000000001111111111111111
;  7 |     0000000000011111111111111112
;  8 |     0000000000011111111111111112
;  9 |    000000000000111111111111111122
; 10 |    000000000000111111111111111122
; 11 |    000000000000111111111111111122
; 12 |   00000000000001111111111111111222
; 13 |   00000000000001111111111111111222
; 14 |   00000000000001111111111111111222
; 15 |   00000000000001111111111111111222
; 16 |   00000000000001111111111111111222
; 17 |   00000000000001111111111111111222
; 18 |   00000000000001111111111111111222
; 19 |   00000000000001111111111111111222
; 20 |    000000000000111111111111111122
; 21 |    000000000000111111111111111122
; 22 |    000000000000111111111111111122
; 23 |     0000000000011111111111111112
; 24 |     0000000000011111111111111112
; 25 |      00000000001111111111111111
; 26 |       000000000111111111111111
; 27 |        0000000011111111111111
; 28 |         00000001111111111111
; 29 |          000000111111111111
; 30 |            00001111111111
; 31 |               01111111

.clear_bob_3
	move	(sp)+,d0
	move	d0,(a4) ; Destination address (low word)

	and		d4,d0
	or		d6,d0

	move	d5,(a5) ; Y Count
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	add		d1,(a4) ; Destination address (low word)
	move	d5,(a5) ; Y Count
;	add		#0<<8,d0
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	add		#-VIRTUAL_DISPLAY_WIDTH/2*(32-7)+8,(a4) ; Destination address (low word)
	move	#25-7,(a5) ; Y Count
	add		d2,d0
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	rts

;  0 |                11111111
;  1 |             00011111111111
;  2 |           000001111111111111
;  3 |          00000011111111111111
;  4 |         0000000111111111111111
;  5 |        000000001111111111111111
;  6 |       00000000011111111111111112
;  7 |      0000000000111111111111111122
;  8 |      0000000000111111111111111122
;  9 |     000000000001111111111111111222
; 10 |     000000000001111111111111111222
; 11 |     000000000001111111111111111222
; 12 |    000000000000                2222
; 13 |    000000000000                2222
; 14 |    000000000000                2222
; 15 |    000000000000                2222
; 16 |    000000000000                2222
; 17 |    000000000000                2222
; 18 |    000000000000                2222
; 19 |    000000000000                2222
; 20 |     000000000001111111111111111222
; 21 |     000000000001111111111111111222
; 22 |     000000000001111111111111111222
; 23 |      0000000000111111111111111122
; 24 |      0000000000111111111111111122
; 25 |       00000000011111111111111112
; 26 |        000000001111111111111111
; 27 |         0000000111111111111111
; 28 |          00000011111111111111
; 29 |           000001111111111111
; 30 |             00011111111111
; 31 |                11111111

.clear_bob_4
	move	(sp)+,d0
	add		#-VIRTUAL_DISPLAY_WIDTH/2*(0-1),d0
	move	d0,(a4) ; Destination address (low word)

	and		d4,d0
	or		d6,d0

	move	#31-1,(a5) ; Y Count
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	add		#-VIRTUAL_DISPLAY_WIDTH/2*(31-0)+8,(a4) ; Destination address (low word)
	move	#12-0,(a5) ; Y Count
	add		d7,d0
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	add		#-VIRTUAL_DISPLAY_WIDTH/2*(12-20),(a4) ; Destination address (low word)
	move	#32-20,(a5) ; Y Count
	sub		#12<<8,d0
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	add		#-VIRTUAL_DISPLAY_WIDTH/2*(32-6)+8,(a4) ; Destination address (low word)
	move	#26-6,(a5) ; Y Count
	add		#2<<8,d0
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	rts

;  0 |                 11111111
;  1 |              00111111111111
;  2 |            000011111111111111
;  3 |           00000111111111111111
;  4 |          0000001111111111111111
;  5 |         000000011111111111111112
;  6 |        00000000111111111111111122
;  7 |       0000000001111111111111111222
;  8 |       0000000001111111111111111222
;  9 |      0000000000                2222
; 10 |      0000000000                2222
; 11 |      0000000000                2222
; 12 |     00000000000                22222
; 13 |     00000000000                22222
; 14 |     00000000000                22222
; 15 |     00000000000                22222
; 16 |     00000000000                22222
; 17 |     00000000000                22222
; 18 |     00000000000                22222
; 19 |     00000000000                22222
; 20 |      0000000000                2222
; 21 |      0000000000                2222
; 22 |      0000000000                2222
; 23 |       0000000001111111111111111222
; 24 |       0000000001111111111111111222
; 25 |        00000000111111111111111122
; 26 |         000000011111111111111112
; 27 |          0000001111111111111111
; 28 |           00000111111111111111
; 29 |            000011111111111111
; 30 |              00111111111111
; 31 |                 11111111

.clear_bob_5
	move	(sp)+,d0
	add		#-VIRTUAL_DISPLAY_WIDTH/2*(0-1),d0
	move	d0,(a4) ; Destination address (low word)

	and		d4,d0
	or		d6,d0

	move	#31-1,(a5) ; Y Count
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	add		#-VIRTUAL_DISPLAY_WIDTH/2*(31-0)+8,(a4) ; Destination address (low word)
	move	#9-0,(a5) ; Y Count
	add		d7,d0
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	add		#-VIRTUAL_DISPLAY_WIDTH/2*(9-23),(a4) ; Destination address (low word)
	move	#32-23,(a5) ; Y Count
	sub		d3,d0
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	add		#-VIRTUAL_DISPLAY_WIDTH/2*(32-5)+8,(a4) ; Destination address (low word)
	move	#27-5,(a5) ; Y Count
	sub		#2<<8,d0
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	rts

;  0 |                  11111111
;  1 |               01111111111111
;  2 |             000111111111111111
;  3 |            00001111111111111111
;  4 |           0000011111111111111112
;  5 |          000000111111111111111122
;  6 |         00000001111111111111111222
;  7 |        00000000                2222
;  8 |        00000000                2222
;  9 |       000000000                22222
; 10 |       000000000                22222
; 11 |       000000000                22222
; 12 |      0000000000                222222
; 13 |      0000000000                222222
; 14 |      0000000000                222222
; 15 |      0000000000                222222
; 16 |      0000000000                222222
; 17 |      0000000000                222222
; 18 |      0000000000                222222
; 19 |      0000000000                222222
; 20 |       000000000                22222
; 21 |       000000000                22222
; 22 |       000000000                22222
; 23 |        00000000                2222
; 24 |        00000000                2222
; 25 |         00000001111111111111111222
; 26 |          000000111111111111111122
; 27 |           0000011111111111111112
; 28 |            00001111111111111111
; 29 |             000111111111111111
; 30 |               01111111111111
; 31 |                  11111111

.clear_bob_6
	move	(sp)+,d0
	add		#VIRTUAL_DISPLAY_WIDTH/2*1,d0
	move	d0,(a4) ; Destination address (low word)

	and		d4,d0
	or		d6,d0

	move	#31-1,(a5) ; Y Count
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	add		#-VIRTUAL_DISPLAY_WIDTH/2*(31-0)+8,(a4) ; Destination address (low word)
	move	#7-0,(a5) ; Y Count
	add		d7,d0
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	add		#-VIRTUAL_DISPLAY_WIDTH/2*(7-25),(a4) ; Destination address (low word)
	move	#32-25,(a5) ; Y Count
	sub		d2,d0
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	add		#-VIRTUAL_DISPLAY_WIDTH/2*(32-4)+8,(a4) ; Destination address (low word)
	move	#28-4,(a5) ; Y Count
	sub		#5<<8,d0
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	rts

;  0 |                   11111111
;  1 |                11111111111111
;  2 |              001111111111111111
;  3 |             00011111111111111112
;  4 |            0000111111111111111122
;  5 |           000001111111111111111222
;  6 |          000000                2222
;  7 |         0000000                22222
;  8 |         0000000                22222
;  9 |        00000000                222222
; 10 |        00000000                222222
; 11 |        00000000                222222
; 12 |       000000000                2222222
; 13 |       000000000                2222222
; 14 |       000000000                2222222
; 15 |       000000000                2222222
; 16 |       000000000                2222222
; 17 |       000000000                2222222
; 18 |       000000000                2222222
; 19 |       000000000                2222222
; 20 |        00000000                222222
; 21 |        00000000                222222
; 22 |        00000000                222222
; 23 |         0000000                22222
; 24 |         0000000                22222
; 25 |          000000                2222
; 26 |           000001111111111111111222
; 27 |            0000111111111111111122
; 28 |             00011111111111111112
; 29 |              001111111111111111
; 30 |                11111111111111
; 31 |                   11111111

.clear_bob_7
	move	(sp)+,d0
	add		#VIRTUAL_DISPLAY_WIDTH/2*2,d0
	move	d0,(a4) ; Destination address (low word)

	and		d4,d0
	or		d6,d0

	move	#30-2,(a5) ; Y Count
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	add		#-VIRTUAL_DISPLAY_WIDTH/2*(30-0)+8,(a4) ; Destination address (low word)
	move	#6-0,(a5) ; Y Count
	add		#14<<8,d0
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	add		#-VIRTUAL_DISPLAY_WIDTH/2*(6-26),(a4) ; Destination address (low word)
	move	#32-26,(a5) ; Y Count
	sub		#6<<8,d0
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	add		#-VIRTUAL_DISPLAY_WIDTH/2*(32-3)+8,(a4) ; Destination address (low word)
	move	#29-3,(a5) ; Y Count
	sub		d2,d0
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	rts

;  0 |                    11111111
;  1 |                 11111111111111
;  2 |               011111111111111112
;  3 |              00111111111111111122
;  4 |             0001111111111111111222
;  5 |            0000                2222
;  6 |           00000                22222
;  7 |          000000                222222
;  8 |          000000                222222
;  9 |         0000000                2222222
; 10 |         0000000                2222222
; 11 |         0000000                2222222
; 12 |        00000000                22222222
; 13 |        00000000                22222222
; 14 |        00000000                22222222
; 15 |        00000000                22222222
; 16 |        00000000                22222222
; 17 |        00000000                22222222
; 18 |        00000000                22222222
; 19 |        00000000                22222222
; 20 |         0000000                2222222
; 21 |         0000000                2222222
; 22 |         0000000                2222222
; 23 |          000000                222222
; 24 |          000000                222222
; 25 |           00000                22222
; 26 |            0000                2222
; 27 |             0001111111111111111222
; 28 |              00111111111111111122
; 29 |               011111111111111112
; 30 |                 11111111111111
; 31 |                    11111111

.clear_bob_8
	move	(sp)+,d0
	add		#VIRTUAL_DISPLAY_WIDTH/2*2,d0
	move	d0,(a4) ; Destination address (low word)

	and		d4,d0
	or		d6,d0

	move	#30-2,(a5) ; Y Count
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	add		#-VIRTUAL_DISPLAY_WIDTH/2*(30-0)+8,(a4) ; Destination address (low word)
	move	#5-0,(a5) ; Y Count
	add		#14<<8,d0
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	add		#-VIRTUAL_DISPLAY_WIDTH/2*(5-27),(a4) ; Destination address (low word)
	move	#32-27,(a5) ; Y Count
	sub		#5<<8,d0
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	add		#-VIRTUAL_DISPLAY_WIDTH/2*(32-2)+8,(a4) ; Destination address (low word)
	move	#30-2,(a5) ; Y Count
	sub		d3,d0
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	rts

;  0 |                     11111111
;  1 |                  11111111111111
;  2 |                111111111111111122
;  3 |               01111111111111111222
;  4 |              0011111111111111112222
;  5 |             000111111111111111122222
;  6 |            0000                222222
;  7 |           00000                2222222
;  8 |           00000                2222222
;  9 |          000000                22222222
; 10 |          000000                22222222
; 11 |          000000                22222222
; 12 |         0000000                222222222
; 13 |         0000000                222222222
; 14 |         0000000                222222222
; 15 |         0000000                222222222
; 16 |         0000000                222222222
; 17 |         0000000                222222222
; 18 |         0000000                222222222
; 19 |         0000000                222222222
; 20 |          000000                22222222
; 21 |          000000                22222222
; 22 |          000000                22222222
; 23 |           00000                2222222
; 24 |           00000                2222222
; 25 |            0000                222222
; 26 |             000111111111111111122222
; 27 |              0011111111111111112222
; 28 |               01111111111111111222
; 29 |                111111111111111122
; 30 |                  11111111111111
; 31 |                     11111111

.clear_bob_9
	move	(sp)+,d0
	add		#VIRTUAL_DISPLAY_WIDTH/2*3,d0
	move	d0,(a4) ; Destination address (low word)

	and		d4,d0
	or		d6,d0

	move	#29-3,(a5) ; Y Count
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	add		#-VIRTUAL_DISPLAY_WIDTH/2*(29-0)+8,(a4) ; Destination address (low word)
	move	#6-0,(a5) ; Y Count
	add		#13<<8,d0
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	add		#-VIRTUAL_DISPLAY_WIDTH/2*(6-26),(a4) ; Destination address (low word)
	move	#32-26,(a5) ; Y Count
	sub		#6<<8,d0
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	add		#-VIRTUAL_DISPLAY_WIDTH/2*(32-2)+8,(a4) ; Destination address (low word)
	move	#30-2,(a5) ; Y Count
	add		#8<<8,d0
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	rts

;  0 |                      11111111
;  1 |                   11111111111112
;  2 |                 111111111111111222
;  3 |                11111111111111112222
;  4 |               0111111111111111122222
;  5 |              001111111111111111222222
;  6 |             00011111111111111112222222
;  7 |            0000                22222222
;  8 |            0000                22222222
;  9 |           00000                222222222
; 10 |           00000                222222222
; 11 |           00000                222222222
; 12 |          000000                2222222222
; 13 |          000000                2222222222
; 14 |          000000                2222222222
; 15 |          000000                2222222222
; 16 |          000000                2222222222
; 17 |          000000                2222222222
; 18 |          000000                2222222222
; 19 |          000000                2222222222
; 20 |           00000                222222222
; 21 |           00000                222222222
; 22 |           00000                222222222
; 23 |            0000                22222222
; 24 |            0000                22222222
; 25 |             00011111111111111112222222
; 26 |              001111111111111111222222
; 27 |               0111111111111111122222
; 28 |                11111111111111112222
; 29 |                 111111111111111222
; 30 |                   11111111111112
; 31 |                      11111111

.clear_bob_a
	move	(sp)+,d0
	add		#VIRTUAL_DISPLAY_WIDTH/2*4,d0
	move	d0,(a4) ; Destination address (low word)

	and		d4,d0
	or		d6,d0

	move	#28-4,(a5) ; Y Count
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	add		#-VIRTUAL_DISPLAY_WIDTH/2*(28-0)+8,(a4) ; Destination address (low word)
	move	#7-0,(a5) ; Y Count
	add		#12<<8,d0
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	add		#-VIRTUAL_DISPLAY_WIDTH/2*(7-25),(a4) ; Destination address (low word)
	move	#32-25,(a5) ; Y Count
	sub		d2,d0
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	add		#-VIRTUAL_DISPLAY_WIDTH/2*(32-1)+8,(a4) ; Destination address (low word)
	move	#31-1,(a5) ; Y Count
	add		#8<<8,d0
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	rts

;  0 |                       11111111
;  1 |                    11111111111122
;  2 |                  111111111111112222
;  3 |                 11111111111111122222
;  4 |                1111111111111111222222
;  5 |               011111111111111112222222
;  6 |              00111111111111111122222222
;  7 |             0001111111111111111222222222
;  8 |             0001111111111111111222222222
;  9 |            0000                2222222222
; 10 |            0000                2222222222
; 11 |            0000                2222222222
; 12 |           00000                22222222222
; 13 |           00000                22222222222
; 14 |           00000                22222222222
; 15 |           00000                22222222222
; 16 |           00000                22222222222
; 17 |           00000                22222222222
; 18 |           00000                22222222222
; 19 |           00000                22222222222
; 20 |            0000                2222222222
; 21 |            0000                2222222222
; 22 |            0000                2222222222
; 23 |             0001111111111111111222222222
; 24 |             0001111111111111111222222222
; 25 |              00111111111111111122222222
; 26 |               011111111111111112222222
; 27 |                1111111111111111222222
; 28 |                 11111111111111122222
; 29 |                  111111111111112222
; 30 |                    11111111111122
; 31 |                       11111111

.clear_bob_b
	move	(sp)+,d0
	add		#VIRTUAL_DISPLAY_WIDTH/2*5,d0
	move	d0,(a4) ; Destination address (low word)

	and		d4,d0
	or		d6,d0

	move	#27-5,(a5) ; Y Count
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	add		#-VIRTUAL_DISPLAY_WIDTH/2*(27-0)+8,(a4) ; Destination address (low word)
	move	#9-0,(a5) ; Y Count
	add		#11<<8,d0
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	add		#-VIRTUAL_DISPLAY_WIDTH/2*(9-23),(a4) ; Destination address (low word)
	move	#32-23,(a5) ; Y Count
	sub		d3,d0
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	add		#-VIRTUAL_DISPLAY_WIDTH/2*(32-1)+8,(a4) ; Destination address (low word)
	move	#31-1,(a5) ; Y Count
	add		#10<<8,d0
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	rts

;  0 |                        11111111
;  1 |                     11111111111222
;  2 |                   111111111111122222
;  3 |                  11111111111111222222
;  4 |                 1111111111111112222222
;  5 |                111111111111111122222222
;  6 |               01111111111111111222222222
;  7 |              0011111111111111112222222222
;  8 |              0011111111111111112222222222
;  9 |             000111111111111111122222222222
; 10 |             000111111111111111122222222222
; 11 |             000111111111111111122222222222
; 12 |            0000                222222222222
; 13 |            0000                222222222222
; 14 |            0000                222222222222
; 15 |            0000                222222222222
; 16 |            0000                222222222222
; 17 |            0000                222222222222
; 18 |            0000                222222222222
; 19 |            0000                222222222222
; 20 |             000111111111111111122222222222
; 21 |             000111111111111111122222222222
; 22 |             000111111111111111122222222222
; 23 |              0011111111111111112222222222
; 24 |              0011111111111111112222222222
; 25 |               01111111111111111222222222
; 26 |                111111111111111122222222
; 27 |                 1111111111111112222222
; 28 |                  11111111111111222222
; 29 |                   111111111111122222
; 30 |                     11111111111222
; 31 |                        11111111

.clear_bob_c
	move	(sp)+,d0
	add		#VIRTUAL_DISPLAY_WIDTH/2*6,d0
	move	d0,(a4) ; Destination address (low word)

	and		d4,d0
	or		d6,d0

	move	#26-6,(a5) ; Y Count
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	add		#-VIRTUAL_DISPLAY_WIDTH/2*(26-0)+8,(a4) ; Destination address (low word)
	move	#12-0,(a5) ; Y Count
	add		#10<<8,d0
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	add		#-VIRTUAL_DISPLAY_WIDTH/2*(12-20),(a4) ; Destination address (low word)
	move	#32-20,(a5) ; Y Count
	add		#4<<8,d0
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	add		#-VIRTUAL_DISPLAY_WIDTH/2*(32-1)+8,(a4) ; Destination address (low word)
	move	#31-1,(a5) ; Y Count
	sub		#3<<8,d0
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	rts

;  0 |                         11111112
;  1 |                      11111111112222
;  2 |                    111111111111222222
;  3 |                   11111111111112222222
;  4 |                  1111111111111122222222
;  5 |                 111111111111111222222222
;  6 |                11111111111111112222222222
;  7 |               0111111111111111122222222222
;  8 |               0111111111111111122222222222
;  9 |              001111111111111111222222222222
; 10 |              001111111111111111222222222222
; 11 |              001111111111111111222222222222
; 12 |             00011111111111111112222222222222
; 13 |             00011111111111111112222222222222
; 14 |             00011111111111111112222222222222
; 15 |             00011111111111111112222222222222
; 16 |             00011111111111111112222222222222
; 17 |             00011111111111111112222222222222
; 18 |             00011111111111111112222222222222
; 19 |             00011111111111111112222222222222
; 20 |              001111111111111111222222222222
; 21 |              001111111111111111222222222222
; 22 |              001111111111111111222222222222
; 23 |               0111111111111111122222222222
; 24 |               0111111111111111122222222222
; 25 |                11111111111111112222222222
; 26 |                 111111111111111222222222
; 27 |                  1111111111111122222222
; 28 |                   11111111111112222222
; 29 |                    111111111111222222
; 30 |                      11111111112222
; 31 |                         11111112

.clear_bob_d
	move	(sp)+,d0
	add		#VIRTUAL_DISPLAY_WIDTH/2*7,d0
	move	d0,(a4) ; Destination address (low word)

	and		d4,d0
	or		d6,d0

	move	#25-7,(a5) ; Y Count
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	add		#-VIRTUAL_DISPLAY_WIDTH/2*(25-0)+8,(a4) ; Destination address (low word)
	move	d5,(a5) ; Y Count
	add		d3,d0
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	add		d1,(a4) ; Destination address (low word)
	move	d5,(a5) ; Y Count
;	add		#0<<8,d0
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	rts

;  0 |                          11111122
;  1 |                       11111111122222
;  2 |                     111111111112222222
;  3 |                    11111111111122222222
;  4 |                   1111111111111222222222
;  5 |                  111111111111112222222222
;  6 |                 11111111111111122222222222
;  7 |                1111111111111111222222222222
;  8 |                1111111111111111222222222222
;  9 |               011111111111111112222222222222
; 10 |               011111111111111112222222222222
; 11 |               011111111111111112222222222222
; 12 |              00111111111111111122222222222222
; 13 |              00111111111111111122222222222222
; 14 |              00111111111111111122222222222222
; 15 |              00111111111111111122222222222222
; 16 |              00111111111111111122222222222222
; 17 |              00111111111111111122222222222222
; 18 |              00111111111111111122222222222222
; 19 |              00111111111111111122222222222222
; 20 |               011111111111111112222222222222
; 21 |               011111111111111112222222222222
; 22 |               011111111111111112222222222222
; 23 |                1111111111111111222222222222
; 24 |                1111111111111111222222222222
; 25 |                 11111111111111122222222222
; 26 |                  111111111111112222222222
; 27 |                   1111111111111222222222
; 28 |                    11111111111122222222
; 29 |                     111111111112222222
; 30 |                       11111111122222
; 31 |                          11111122

.clear_bob_e
	move	(sp)+,d0
	add		#VIRTUAL_DISPLAY_WIDTH/2*9,d0
	move	d0,(a4) ; Destination address (low word)

	and		d4,d0
	or		d6,d0

	move	#23-9,(a5) ; Y Count
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	add		#-VIRTUAL_DISPLAY_WIDTH/2*(23-0)+8,(a4) ; Destination address (low word)
	move	d5,(a5) ; Y Count
	add		d2,d0
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	add		d1,(a4) ; Destination address (low word)
	move	d5,(a5) ; Y Count
;	add		#0<<8,d0
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	rts

;  0 |                           11111222
;  1 |                        11111111222222
;  2 |                      111111111122222222
;  3 |                     11111111111222222222
;  4 |                    1111111111112222222222
;  5 |                   111111111111122222222222
;  6 |                  11111111111111222222222222
;  7 |                 1111111111111112222222222222
;  8 |                 1111111111111112222222222222
;  9 |                111111111111111122222222222222
; 10 |                111111111111111122222222222222
; 11 |                111111111111111122222222222222
; 12 |               01111111111111111222222222222222
; 13 |               01111111111111111222222222222222
; 14 |               01111111111111111222222222222222
; 15 |               01111111111111111222222222222222
; 16 |               01111111111111111222222222222222
; 17 |               01111111111111111222222222222222
; 18 |               01111111111111111222222222222222
; 19 |               01111111111111111222222222222222
; 20 |                111111111111111122222222222222
; 21 |                111111111111111122222222222222
; 22 |                111111111111111122222222222222
; 23 |                 1111111111111112222222222222
; 24 |                 1111111111111112222222222222
; 25 |                  11111111111111222222222222
; 26 |                   111111111111122222222222
; 27 |                    1111111111112222222222
; 28 |                     11111111111222222222
; 29 |                      111111111122222222
; 30 |                        11111111222222
; 31 |                           11111222

.clear_bob_f
	move	(sp)+,d0
	add		#VIRTUAL_DISPLAY_WIDTH/2*12,d0
	move	d0,(a4) ; Destination address (low word)

	and		d4,d0
	or		d6,d0

	move	#20-12,(a5) ; Y Count
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	add		#-VIRTUAL_DISPLAY_WIDTH/2*(20-0)+8,(a4) ; Destination address (low word)
	move	d5,(a5) ; Y Count
	add		#4<<8,d0
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	add		d1,(a4) ; Destination address (low word)
	move	d5,(a5) ; Y Count
;	add		#0<<8,d0
	move	d0,(a6) ; Busy, Hog, Smudge, Line Number

	rts

; ------------------------------------------------------------------------------

vbl
	move.l	display_screen_address,-(sp)
	move.l	draw_screen_address,display_screen_address
	move.l	(sp)+,draw_screen_address

	move.l	display_bobs_clear_infos_address,-(sp)
	move.l	draw_bobs_clear_infos_address,display_bobs_clear_infos_address
	move.l	(sp)+,draw_bobs_clear_infos_address

	move.l	draw_screen_address,.temp ; STE Note: Switching the screen address will be delayed to the next VBL!
	sub.l	#DISPLAY_OFFSET*VIRTUAL_DISPLAY_WIDTH/2,.temp

	move.b	.temp+1,$ffff8201.w
	move.b	.temp+2,$ffff8203.w
	move.b	.temp+3,$ffff820d.w

	clr.b	$fffffa1b.w
	move.b	#199+29,$fffffa21.w ; Timer B data
	move.b	#8,$fffffa1b.w ; Timer B control

    move.b	#97,$fffffa1f.w ; Timer A data
    move.b	#4,$fffffa19.w ; Timer A control

	move	#$1b2,$ffff8240+15*2.w

	rte

.temp
	ds.l	1

; ------------------------------------------------------------------------------

hbl
	rte

; ------------------------------------------------------------------------------

timer_b
	movem.l d0/a0,-(sp)

	lea		$fffffa21.w,a0
	move.b	(a0),d0

.wait1
	cmp.b	(a0),d0
	beq.s	.wait1

	clr.b   $ffff820a.w

	moveq	#2,d0

.wait2
	nop

	dbf		d0,.wait2

	nop
	nop
	nop
	nop
	nop

	move.b	#2,$ffff820a.w

	move.b	(a0),d0

.wait3
	cmp.b	(a0),d0
	beq.s	.wait3

	movem.l (sp)+,d0/a0

	rte

; ------------------------------------------------------------------------------

timer_a
    move	#$2100,sr ; Enable HBL
    stop	#$2100 ; Wait for HBL
    move	#$2700,sr ; Stop all interrupts

    clr.b	$fffffa19.w ; Stop Timer A

	; Code part moved from clear_bobs!

	move	#2,$ffff8a20.w ; Source X increment
	move	#$ffff,$ffff8a28.w ; Endmask 1
	move	#$ffff,$ffff8a2a.w ; Endmask 2
	move	#$ffff,$ffff8a2c.w ; Endmask 3
	move	#2,$ffff8a2e.w ; Destination X increment
	move	#VIRTUAL_DISPLAY_WIDTH/2-4*2+2,$ffff8a30.w ; Destination Y Increment
	move.b	#1,$ffff8a3a.w ; HOP 1 (halftone only)

	move.b	#3,$ffff8a3b.w ; OP 3 (destination = source)
;	move.b	#15,$ffff8a3b.w ; OP 0 (destination = 1)
;	move.b	#0,$ffff8a3b.w ; OP 0 (destination = 0)

	move.b	#0,$ffff8a3d.w ; FXSR, NFSR, Skew
	move	#4,$ffff8a36.w ; X Count

    rept 84-40
    nop
    endr

    clr.b	$ffff820a.w	; Remove the top border

	; Code part moved from clear_bobs!

	lea		$ffff8a32+2.w,a4
	lea		$ffff8a38.w,a5
	lea		$ffff8a3c.w,a6

    rept 9-6
    nop
    endr

    move.b	#2,$ffff820a.w

	addq	#1,vbl_counter

	rte

; ------------------------------------------------------------------------------
	data
; ------------------------------------------------------------------------------

draw_screen_address
	dc.l 	screen1
display_screen_address
	dc.l 	screen2

draw_bobs_clear_infos_address
	dc.l	bobs_clear_infos1
display_bobs_clear_infos_address
	dc.l	bobs_clear_infos2

draw_sprite_data_address
	dc.l	enhanced_sprite1_reordered
display_sprite_data_address
	dc.l	enhanced_sprite2_reordered

	even

reorder_offset_table
	dc.l	(31-0)*320/2-8 ; 0 -> 31

	dc.l	(30-31)*320/2-8 ; 31 -> 30

	dc.l	(1-30)*320/2-8 ; 30 -> 1
	
	dc.l	(2-1)*320/2-8 ; 1 -> 2

	dc.l	(29-2)*320/2-8 ; 2 -> 29
	
	dc.l	(28-29)*320/2-8 ; 29 -> 28

	dc.l	(3-28)*320/2-8 ; 28 -> 3
	
	dc.l	(4-3)*320/2-8 ; 3 -> 4

	dc.l	(27-4)*320/2-8 ; 4 -> 27
	
	dc.l	(26-27)*320/2-8 ; 27 -> 26

	dc.l	(5-26)*320/2-8 ; 26 -> 5
	
	dc.l	(6-5)*320/2-8 ; 5 -> 6

	dc.l	(25-6)*320/2-8 ; 6 -> 25

	dc.l	(24-25)*320/2-8 ; 25 -> 24
	dc.l	(23-24)*320/2-8 ; 24 -> 23

	dc.l	(7-23)*320/2-8 ; 23 -> 7
	dc.l	(8-7)*320/2-8 ; 7 -> 8

	dc.l	(9-8)*320/2-8 ; 8 -> 9
	dc.l	(10-9)*320/2-8 ; 9 -> 10
	dc.l	(11-10)*320/2-8 ; 10 -> 11

	dc.l	(22-11)*320/2-8 ; 11 -> 22
	dc.l	(21-22)*320/2-8 ; 22 -> 21
	dc.l	(20-21)*320/2-8 ; 21 -> 20

	dc.l	(19-20)*320/2-8 ; 20 -> 19
	dc.l	(18-19)*320/2-8 ; 19 -> 18
	dc.l	(17-18)*320/2-8 ; 18 -> 17
	dc.l	(16-17)*320/2-8 ; 17 -> 16
	dc.l	(15-16)*320/2-8 ; 16 -> 15
	dc.l	(14-15)*320/2-8 ; 15 -> 14
	dc.l	(13-14)*320/2-8 ; 14 -> 13
	dc.l	(12-13)*320/2-8 ; 13 -> 12
	
bob_positions
	include "position.s"

sprites
	incbin	"BALL.PI1",0,2+16*2+32*320/2

sample_addresses
	dc.l	.sample_start
	dc.l	.sample_end

.sample_start
	incbin	"anthem.raw"
.sample_end

; ------------------------------------------------------------------------------
	bss
; ------------------------------------------------------------------------------

old_ssp
	ds.l	1

old_screen
	ds.l	1
old_palette
	ds.l	256
old_videl
	ds.l	11

old_line_f
	ds.l	1
old_trap_f
	ds.l	1
old_hbl
	ds.l	1
old_vbl
	ds.l	1
old_timer_b
	ds.l	1
old_timer_a
	ds.l	1
old_keyboard
	ds.l	1

old_res
	ds.b	1
old_hz
	ds.b	1
old_linewid
	ds.b	1

old_fa07
	ds.b	1
old_fa09
	ds.b	1
old_fa13
	ds.b	1
old_fa15
	ds.b	1
old_fa17
	ds.b	1
old_fa1b
	ds.b	1
old_fa21
	ds.b	1

old_8921
	ds.b	1

	even

vbl_counter
	ds		1

bobs_clear_infos1
	ds		NUMBER_OF_BOBS*3
bobs_clear_infos2
	ds		NUMBER_OF_BOBS*3

enhanced_sprite1_reordered
	ds		2*4*32
enhanced_sprite2_reordered
	ds		2*4*32

enhanced_sprites_palette
	ds		16
enhanced_sprites1
	ds.b	320/2*200
	ds.l	1
enhanced_sprites_palette2
	ds		16
enhanced_sprites2
	ds.b	320/2*200

	align 4

screen1
	ds.b	$20000
screen2
	ds.b	$20000
	ds.b	$10000
	
; ------------------------------------------------------------------------------
	end
; ------------------------------------------------------------------------------
