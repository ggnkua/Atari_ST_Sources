***********************************
*=================================*
* RESERVOIR GODS LIBRARY ROUTINES *
*=================================*
*       |                |        *
*       |KEYBOARD LIBRARY|        *
*       |                |        *
***********************************
* CODE: MR. PINK | (C): 19/02/96  *
***********************************
* UPDATE: 22/2/96  *
********************

**************************************************************************
;	SECTION CSECT
**************************************************************************

	xdef	rlkb_install_118
	xdef	rlkb_deinstall_118
	xdef	rlkb_read_powerpads
	xdef	rlkb_return_keyboard_block_ptr
	xdef	rlkb_clear_ikbd
	xdef	rlkb_send_ikbd
	xdef	rlkb_debug_on
	xdef	rlkb_midi_head
	xdef	rlkb_midi_tail
	xdef	rlkb_midi_buffer
	xdef	rlkb_midi_byte_waiting
	xdef	rlkb_return_midi_byte
	xdef	rlkb_midi_overflow_flag

**************************************************************************
;	SECTION TEXT
**************************************************************************

	TEXT

rlkb_install_118:
	move.w	sr,-(a7)
	ori.w	#$0700,sr
	move.l	$118.w,rlkb_old_118
	move.l	#rlkb_my_ikbd,$118.w

	move.l	#rlkb_key_buffer,rlkb_key_ptr
	move.w	(a7)+,sr
	rts


rlkb_deinstall_118:
	move.w	sr,-(a7)
	ori.w	#$0700,sr
	move.l	rlkb_old_118,$118.w
	move.w	(a7)+,sr
	rts


rlkb_clear_ikbd:
	move.l	d0,-(a7)
.clear_ikbd:
	btst    #0,$fffffc00.w
	beq.s   .ikbd_ok
	move.b  $fffffc02.w,D0
	bra.s   .clear_ikbd
.ikbd_ok:
	move.l	(a7)+,d0
	rts

rlkb_send_ikbd:
	move.l	a0,-(a7)
	movea.w	#$fc00,A0
.wait:
   	btst    #1,(a0)
	beq.s   .wait
	move.b  d0,2(a0)
	move.l	(a7)+,a0
	rts

rlkb_debug_on:
	move.w	#$4e71,rlkb_store_key
	rts

rlkb_return_keyboard_block_ptr:
	lea	rlkb_old_118,a0
	rts

rlkb_return_midi_byte:
	movem.l	a0/d1,-(a7)
	move.w	rlkb_midi_head,d1
	lea	rlkb_midi_buffer,a0
	move.b	(a0,d1.w),d0		
	addq.w	#1,d1
	and.w	#2047,d1
	move.w	d1,rlkb_midi_head
	movem.l	(a7)+,a0/d1		
	rts

rlkb_midi_byte_waiting:
	move.w	rlkb_midi_tail,d0
	sub.w	rlkb_midi_head,d0
	rts

rlkb_my_ikbd:
	move.w	#$2700,sr
	movem.l	d0-d2/a0-a2,-(a7)
.more:
	bsr	rlkb_midirec 
	bsr	rlkb_kbdrec
	btst	#4,$fffffa01.w
	beq.s	.more
	bclr	#6,$fffffa11.w	;signal end of ikbd interrupt
	movem.l	(a7)+,d0-d2/a0-a2
	rte

rlkb_midirec:
	movea.w	#$fffffc04,a0
	lea	rlkb_midisys(pc),a1
	bra.s	rlkb_read1
rlkb_kbdrec:
	movea.w	#$fffffc00,a0
	lea	rlkb_kbdsys(pc),a1

rlkb_read1:
	move.b	(a0),d1
	btst	#7,d1
	beq	.no_int
	btst	#0,d1
	beq	.full
	jsr	(a1)	
.full:
	and.b	#$20,d1
	beq.s	.no_int
	move.b	2(a0),d1
.no_int:
	rts	

rlkb_midisys:
	move.b	2(a0),d0

	move.w	rlkb_midi_tail,d2
	lea		rlkb_midi_buffer,a1
	move.b	d0,(a1,d2.w)
	addq.w	#1,d2
	and.w	#2047,d2
	cmp.w	rlkb_midi_head,d2
	beq.s	.full
	move.w	d2,rlkb_midi_tail
	rts
.full:
	move.w	#1,rlkb_midi_overflow_flag
	rts

rlkb_midi_overflow_flag:	dc.w	0
rlkb_midi_head:				dc.w	0
rlkb_midi_tail:				dc.w	0

rlkb_kbdsys:

rlkb_keyloop:
	moveq	#0,d0			;clear d0
	move.b	2(a0),d0		;read ikbd data
	tst.b	rlkb_key_cntr	;is this first byte
	beq	rlkb_chk_head		;yes, so check for header
		
	move.l	rlkb_key_ptr,a1	;ptr into key storage area
	move.b	d0,(a1)+		;store keyboard data
	move.l	a1,rlkb_key_ptr	;update ptr
	subq.b	#1,rlkb_key_cntr	;decrement data to get
	bne	rlkb_last_key_check	;more data to get

rlkb_process_packet:
	lea	rlkb_key_buffer,a1	;start of key storage data
	moveq	#0,d0			;clear d0
	move.b	(a1),d0			;get first byte
	sub.l	#$f6,d0			;minus default packet header value
;	and.w	#$f,d0			;mask off unwanted bits
	bmi	.nojj
	cmp.w	#10,d0			;is it a valid packet
	bge	.nojj			;no
	lsl.w	#2,d0
	lea	rlkb_key_handlers,a2
	move.l (a2,d0.w),a2
	jsr (a2)
;	jsr	([rlkb_key_handlers,d0.w*4])	;jump to packet handler routine
.nojj:
	bra	rlkb_last_key_check	;check for more key data

rlkb_chk_head:
	cmp.w	#$f6,d0			;is it packer header
	blt.s	rlkb_store_key		;no, store as a key

	move.b	d0,rlkb_key_buffer		;store packet header
	lea	rlkb_key_buffer+1,a1
	move.l	a1,rlkb_key_ptr		;init key pointer
	lea	rlkb_packet_table,a1		;packet table
	sub.b	#$f6,d0				;d0 is offset
	move.b	(a1,d0.w),rlkb_key_cntr	;bytes of data to be read
	bra	rlkb_last_key_check		;get data

rlkb_store_key:
	bra.s	.no_debug
	movem.l	d0-d7/a0-a6,-(a7)
	lea	$f96.w,a0
	move.l $1132.w,a6
;	jsr	([$1132.w])
	jsr	(a6)
	movem.l	(a7)+,d0-d7/a0-a6
.no_debug:
	bclr	#7,d0			;check 'release' bit
	beq.s	rlkb_setkey		;0, so set key press
	lea	rlkb_key_table,a2
	clr.b	(a2,d0.w)	;key released
	bra.s	rlkb_last_key_check	;get key data
rlkb_setkey:
	lea	rlkb_key_table,a2
	st.b	(a2,d0.w)	;set key pressed
	st.b	rlkb_key_pressed
	move.b	d0,rlkb_current_key

rlkb_last_key_check:	
	move.b	(a0),d0		;read ikbd control
	btst	#0,d0		;more data to read?
	bne	rlkb_keyloop	;yes, so process it
rlkb_endmykey:
	rts


rlkb_keyboard_packet_handler:
	moveq	#0,d0			;clear d0
	move.b	1(a0),d0		;get key
	bclr	#7,d0			;key pressed?
	beq.s	.setkey			;yes, set it
	lea	rlkb_key_table,a2
	clr.b	(a2,d0.w)	;indicate key release
	rts                             ;return
.setkey:
	lea	rlkb_key_table,a2
	st.b	(a2,d0.w)	;clear key
	st.b	rlkb_key_pressed
	move.b	d0,rlkb_current_key
	rts                             ;return

rlkb_absolute_mouse_handler:			;no absolute mouse handler!
	move.b	(a1),d0			;get mouse key info
	and.w	#%11,d0			;isolate l+r buttons
	move.b	d0,rlkb_mousek		;save mouse key info
	rts

rlkb_time_of_day_handler:			;no time of day handler!
rlkb_joystick_report_handler:
	move.b	1(a1),rlkb_j1_packet		;get joystick 1 packet
	move.b	2(a1),rlkb_j2_packet		;get joystick 2 packet
	rts                             ;return

rlkb_joystick0_handler:
	move.b	1(a1),rlkb_j1_packet		;save joystick 1 packet
	rts                             ;return
 
rlkb_joystick1_handler:
	move.b	1(a1),rlkb_j2_packet		;save joystick 2 packet
	rts                             ;return

rlkb_relative_mouse_handler:
	st.b	rlkb_mouse_moved		;indicate mouse moved

	move.b	(a1),d0			;get mouse key info
	and.w	#%11,d0			;isolate l+r buttons
	move.b	d0,rlkb_mousek	;save mouse key info
.nolimits:
	move.b	1(a1),d0		;mouse x movement
	ext.w	d0			;extend to signed word
	add.w	d0,rlkb_mousex	;update mouse x position
	move.b	2(a1),d0		;mouse y movement
	ext.w	d0			;extedn to signed word
	add.w	d0,rlkb_mousey	;update mouse y position

	move.w	rlkb_mousex,d0
	cmp.w	rlkb_mousex_min,d0
	bgt.s	.xok1
	move.w	rlkb_mousex_min,rlkb_mousex
	bra.s	.xok2
.xok1:
	cmp.w	rlkb_mousex_max,d0
	blt.s	.xok2
	move.w	rlkb_mousex_max,rlkb_mousex
.xok2:
	move.w	rlkb_mousey,d0
	cmp.w	rlkb_mousey_min,d0
	bgt.s	.yok1
	move.w	rlkb_mousey_min,rlkb_mousey
	bra.s	.yok2
.yok1:
	cmp.w	rlkb_mousey_max,d0
	blt.s	.yok2
	move.w	rlkb_mousey_max,rlkb_mousey
.yok2:
	rts

; DIRECTIONAL BYTE FORMAT
; -------------------
; Bit | Powerpad key
; ------------------
;  0  | Up
;  1  | Down
;  2  | Left
;  3  | Right
;  4  | (not used)
;  5  | Fire C
;  6  | Fire B
;  7  | Fire A

; KEY WORD FORMAT
; --------------
; Bit | Powerpad Key
; --------------
;  0  | *
;  1  | 7
;  2  | 4
;  3  | 1
;  4  | 0
;  5  | 8
;  6  | 5
;  7  | 2
;  8  | #
;  9  | 9
; 10  | 6
; 11  | 3
; 12  | Option
; 13  | Pause

rlkb_read_powerpads:
	movem.l	a0-a1/d0-d3,-(a7)
	bsr	rlkb_read_powerpad_a
	bsr	rlkb_read_powerpad_b
	movem.l	(a7)+,a0-a1/d0-d3
	rts

rlkb_read_powerpad_a:
	lea	$ffff9200.w,a0	;extended port address (read only)
	lea	2(a0),a1	;extended port address (read/write)
	moveq	#0,d2		;clear d2 - it will contain key information
	move.w	#$fffe,(a1)	;write mask
	move.w	(a1),d0		;read directional data
	move.w	(a0),d3		;read fire_a/pause data
	not.w	d0		;invert bits (0->1)
	move.w	d0,d1		;save directional data
	lsr.w	#8,d1		;shift into low bits (0-3)
	and.w	#%1111,d1	;mask off unwanted data
	lsr.w	#1,d3		;check bit 0 (pause data)
	bcs.s	rlkb_no_pause_a	;if set, pause is not pressed
	bset	#13,d2		;pause is pressed so set pause bit
rlkb_no_pause_a:
	lsr.w	#1,d3		;check bit 1 (fire a data)
	bcs.s	rlkb_no_firea_a	;if set, fire is not pressed
	bset	#7,d1		;fire_a is pressed, so set fire_a bit
rlkb_no_firea_a:
	move.w	#$fffd,(a1)	;write mask
	move.w	(a1),d0		;read key data
	move.w	(a0),d3		;read fire data
	not.w	d0		;invert bits (0->1)
	btst	#1,d3		;check fire_b
	bne.s	rlkb_no_fireb_a	;if set, fire_b is not pressed
	bset	#6,d1		;fire_b is pressed, set relevant bit
rlkb_no_fireb_a:
	lsr.w	#8,d0		;shift key data into bits 0-3
	and.w	#%1111,d0	;mask off unwanted data
	or.w	d0,d2		;store in key word

	move.w	#$fffb,(a1)	;write mask
	move.w	(a1),d0		;read key data
	move.w	(a0),d3		;read fire data
	not.w	d0		;invert bits (0->1)
	btst	#1,d3		;check for fire_c
	bne.s	rlkb_no_firec_a	;if set, fire_c is not pressed
	bset	#5,d1		;fire_c is pressed, set relevant bit
rlkb_no_firec_a:
	lsr.w	#4,d0		;shift key data into bits 4-7
	and.w	#%11110000,d0	;mask off unwanted data
	or.w	d0,d2		;store in key word

	move.w	#$fff7,(a1)	;write mask
	move.w	(a1),d0		;read key data
	move.w	(a0),d3		;read fire data
	not.w	d0		;invert bits (0->1)
	btst	#1,d3		;check for option
	bne.s	rlkb_no_option_a ;if set, option is not pressed
	bset	#12,d2		;set option bit
rlkb_no_option_a:
	and.w	#%111100000000,d0	;mask off unwanted bits
	or.w	d0,d2		;store key data

	move.b	d1,rlkb_ppa_dir	;save directional+fire data in variable
	move.w	d2,rlkb_ppa_key	;save key data in variable
	rts

rlkb_read_powerpad_b:
	lea	$ffff9200.w,a0	;extended port address (read only)
	lea	2(a0),a1	;extended port address (read/write)
	moveq	#0,d2		;clear d2 - it will contain key information
	move.w	#$ffef,(a1)	;write mask
	move.w	(a1),d0		;read directional data
	move.w	(a0),d3		;read fire_a/pause data
	not.w	d0		;invert bits (0->1)
	move.w	d0,d1		;save directional data
	lsr.w	#8,d1		;shift directional data down
	lsr.w	#4,d1		;shift into low bits (0-3)
	and.w	#%1111,d1	;mask off unwanted data
	btst	#2,d3		;check bit 2 (pause data)
	bne.s	rlkb_no_pause_b	;if set, pause is not pressed
	bset	#13,d2		;pause is pressed so set pause bit
rlkb_no_pause_b:
	btst	#3,d3		;check bit 3 (fire a data)
	bne.s	rlkb_no_firea_b	;if set, fire is not pressed
	bset	#7,d1		;fire_a is pressed, so set fire_a bit
rlkb_no_firea_b:
	move.w	#$ffdf,(a1)	;write mask
	move.w	(a1),d0		;read key data
	move.w	(a0),d3		;read fire data
	not.w	d0		;invert bits (0->1)
	btst	#3,d3		;check fire_b
	bne.s	rlkb_no_fireb_b	;if set, fire_b is not pressed
	bset	#6,d1		;fire_b is pressed, set relevant bit
rlkb_no_fireb_b:	
	lsr.w	#8,d0
	lsr.w	#4,d0		;shift key data into bits 0-3
	and.w	#%1111,d0	;mask off unwanted data
	or.w	d0,d2		;store in key word

	move.w	#$ffbf,(a1)	;write mask
	move.w	(a1),d0		;read key data
	move.w	(a0),d3		;read fire data
	not.w	d0		;invert bits (0->1)
	btst	#3,d3		;check for fire_c
	bne.s	rlkb_no_firec_b	;if set, fire_c is not pressed
	bset	#5,d1		;fire_c is pressed, set relevant bit
rlkb_no_firec_b:		
	lsr.w	#8,d0		;shift key data into bits 4-7
	and.w	#%11110000,d0	;mask off unwanted data
	or.w	d0,d2		;store in key word

	move.w	#$ff7f,(a1)	;write mask
	move.w	(a1),d0		;read key data
	move.w	(a0),d3		;read fire data
	not.w	d0		;invert bits (0->1)
	btst	#3,d3		;check for option
	bne.s	rlkb_no_option_b ;if set, option is not pressed
	bset	#12,d2		;set option bit
rlkb_no_option_b:
	lsr.w	#4,d0		;shift key data into bits 8-11
	and.w	#%111100000000,d0	;mask off unwanted bits
	or.w	d0,d2		;store key data

	move.b	d1,rlkb_ppb_dir	;save directional+fire data in variable
	move.w	d2,rlkb_ppb_key	;save key data in variable
	rts


rlkb_packet_table:
	dc.b	1	;$f6 - keyboard packet
	dc.b	5	;$f7 - absolute mouse packet
	dc.b	2	;$f8 - relative mouse position / no buttons
	dc.b	2	;$f9 - relative mouse / left button
	dc.b	2	;$fa - relative mouse / right button
	dc.b	2	;$fb - relative mouse / both buttons
	dc.b	6	;$fc - time of day
	dc.b	2	;$fd - joystick report
	dc.b	1	;$fe - joystick 0 event
	dc.b	1	;$ff - joystick 1 event

rlkb_key_handlers:
	dc.l	rlkb_keyboard_packet_handler	;$f6
	dc.l	rlkb_absolute_mouse_handler	;$f7
	dc.l	rlkb_relative_mouse_handler	;$f8
	dc.l	rlkb_relative_mouse_handler	;$f9
	dc.l	rlkb_relative_mouse_handler	;$fa
	dc.l	rlkb_relative_mouse_handler	;$fb
	dc.l	rlkb_time_of_day_handler	;$fc
	dc.l	rlkb_joystick_report_handler	;$fd
	dc.l	rlkb_joystick0_handler	;$fe
	dc.l	rlkb_joystick1_handler	;$ff

rlkb_old_118:		ds.l	1
rlkb_key_ptr:		ds.l	1
rlkb_caps_table:	ds.l	1
rlkb_shift_table:	ds.l	1
rlkb_normal_table:	ds.l	1
rlkb_mousex_min:	ds.w	1
rlkb_mousey_min:	ds.w	1
rlkb_mousex_max:	ds.w	1
rlkb_mousey_max:	ds.w	1
rlkb_ppa_key:		ds.w	1
rlkb_ppb_key:		ds.w	1
rlkb_mousex:		ds.w	1
rlkb_mousey:		ds.w	1
rlkb_key_table:		ds.b	128
rlkb_key_buffer:	ds.b	256
rlkb_ppa_dir:		ds.b	1
rlkb_ppb_dir:		ds.b	1
rlkb_key_cntr:		ds.b	1
rlkb_key_pressed:	ds.b	1
rlkb_current_key:	ds.b	1
rlkb_mousek:		ds.b	1
rlkb_j1_packet:		ds.b	1
rlkb_j2_packet:		ds.b	1
rlkb_mouse_moved:	ds.b	1

rlkb_midi_buffer:	ds.b	2048
					END
