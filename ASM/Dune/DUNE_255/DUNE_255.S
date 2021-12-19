; 255 bytes demo
; Thadoss / Dune 2K21
; d7 is the demo timer (+1 every 1/50 hz)
; a0 ; a1 ; a2 are the 3 screen buffers pointers



			opt		p=68030/68882,NOCASE,W+,O+	; Optimized compilation
			comment 	HEAD=%111
			output		DUNE_255.PRG


; --------------------------------------------------------------
			section	text
; --------------------------------------------------------------

			; Supervisor mode
			moveq		#$20,d7
			move.w		d7,-(sp)			; SUPER
			trap		#1				; Gemdos

			; Set physical/logical screens addresses
			swap		d7
			move.l		d7,a0				; a0 = $20000
			lea.l		(a0,d7.l),a1			; a1 = $40000
			lea.l		(a1,d7.l),a2			; a2 = $60000

			; Init the melody pattern
			moveq		#9,d6

			; Custom VBL routine
			lea.l		my_vbl(pc),a3
			move.l		a3,$70.w

			moveq		#-128,d4			; Counter
			sub.l		a4,a4				; The effect sequencer

mainloop:
			; Swap the physical and the 2 logicals screens
			exg.l		a0,a2
			exg.l		a1,a2

			; Set the new phy screen
			move.l		a0,$ffff8200.w

			movea.l		a1,a3				; screen_log ==> a3

			; Y_loop
			move.w		#200-1,d0

			; Fix the time value for this frame
			move.w		d4,d7
			add.w		d7,d7

			; Select the current effect to display
			move.w		a4,d3
			lsr.w		d3
			bcc.s		effect_clear_scr


			; Rotozoom sequence (code automodified)
			and.w		#3,d3
			move.l		effects(pc,d3.w*4),instruction_1

			; Enable the iCache and clear it.
			moveq		#9,d2
			movec		d2,cacr

ef2_loop_outer:		move.w		#320-1,d1

			move.w		d7,d3
			add.w		d0,d3
			muls.w		d7,d3
			asr.l		#8,d3
			add.w		d1,d3
ef2_loop_inner:
			move.w		d1,d2				; d7 instead of d1 gives an funny image distort
			muls.w		d7,d2
			asr.l		#8,d2
			add.w		d0,d2

			addq.w		#1,d3

instruction_1:		; automodified code
			nop
			nop

			; Write pixel
			move.w		d2,(a3)+

			dbf		d1,ef2_loop_inner
			dbf		d0,ef2_loop_outer

			bra.s		mainloop


effect_clear_scr:	; Fractal clear screen sequence
ef1_loop_outer:		move.w		#320-1,d3
ef1_loop_inner:		move.w		d3,d2
			or.w		d0,d2
			add.w		d7,d2
			sne		d2
			move.w		d2,(a3)+
			dbf		d3,ef1_loop_inner
			dbf		d0,ef1_loop_outer
			bra.s		mainloop


my_vbl:			; Play music (50hz)

			addq.b		#1,d4				; Main counter
			bvc.s		.no_change
			addq.l		#1,a4
.no_change:
			ext.w		d4

			; Set the new note and bass
			lea.l		YMbuffer(pc),a6			; YM buffer

			rol.b		d6
			bcc.s		.no_new_note

			rol.b		d4,d6				; Rol the melody pattern
			bcc.s		.no_new_note

			move.w		d3,d5				; New note
			and.w		#7,d5

			move.b		notes(pc,d5.w),1(a6)		; Yamaha Melody channel
			move.b		d7,3(a6)			; Yamaha Bass channel
.no_new_note:

.feed_YM:		move.b		(a6)+,$ffff8800.w		; YM Register select
			move.b		(a6)+,$ffff8802.w		; YM Write data
			bne.s		.feed_YM
.end_vbl:		rte


; --------------------------------------------------------------
			section	data
; --------------------------------------------------------------

effects:		dc.l	$b74256c2				; eor.w     d3,d2	// sne       d2
			dc.l	$b7424e71				; eor.w     d3,d2	// nop
			dc.l	$c4434e71				; and.w     d3,d2	// nop
			dc.l	$c44356c2				; and.w     d3,d2	// sne       d2


notes:			; Gamme si mineur naturel
			dc.b	253	; si
			dc.b	226	; do#
			dc.b	213	; re
			dc.b	190	; mi
			dc.b	169	; fa#
			dc.b	159	; sol
			dc.b	142	; la
			dc.b	127	; si


YMbuffer:		dc.w	$0400					; channel C freq
			dc.w	$0300					; channel B freq
			dc.w	$0A0D					; channel C volume
			dc.w	$090E					; channel B volume
			dc.w	$0739					; Mixer

			end
