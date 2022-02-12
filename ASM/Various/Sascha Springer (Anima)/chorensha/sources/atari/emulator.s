
	xdef start_emulator
	xdef vbl_handler
	xdef timer_b_handler
	xdef line_f_handler
	xdef trap_2_handler
	xdef trap_4_handler
	xdef trap_f_handler

	xdef game_heap_address
	xdef vbl_wait_counter
	xdef iocs_joystick_data
	xdef saved_stack_address

; ------------------------------------------------------------------------------
	text
; ------------------------------------------------------------------------------

; a0	メモリ管理ポインタのアドレス "Address of a pointer to memory management"
; a1	プログラムの終わり+1 のアドレス "+1 Address of the end of the program"
; a2	コマンドラインのアドレス "Address of the command line"
; a3	環境のアドレス "Address of the environment"
; a4	プログラムの実行開始アドレス "Execution of the program start address"
; sr	ユーザーモード "User-mode"
; usp	親のスタック "Stack of the parent"
; ssp	システムのスタック "Stack of the system"

start_emulator:
	move.l	sp,saved_stack_address

	move.l	game_heap_address,a0
	move.l	a0,a1
	move.l	a0,a2
	move.l	a0,a3
	lea		_start,a4

	jmp		(a4)

; ------------------------------------------------------------------------------

vbl_handler:
;	tst		program_exit_request
;	beq		.no_exit_request

;	move.l	saved_stack_address,sp
;	rts

;.no_exit_request:
	move.b	display_window_address+1,$ffff8201.w
	move.b	display_window_address+2,$ffff8203.w
	move.b	display_window_address+3,$ffff820d.w

	addq	#1,vbl_wait_counter

	clr.b	$fffffa1b.w
	move.b	#255,$fffffa21.w
	move.b	#8,$fffffa1b.w

	clr.l	$ffff9800.w
	
	bsr		joypad_handler
	bsr		graphics_engine

;	not.l	$ffff9800.w
	
	move.l	L_00000118,-(sp)
	rts

; ------------------------------------------------------------------------------

joypad_handler:
	movem.l	d0/a0,-(sp)

	lea		last_joypad_data,a0

	move	#$fffe,$ffff9202.w ; Select joypad input group 4.

	move	$ffff9200.w,d0

	cmp		(a0),d0
	beq		.button_a_unchanged
	
	btst	#1,d0
	beq		.button_a_down
	
	bset	#5,iocs_joystick_data+3 ; Joystick button #2 up.	

	bra		.button_a_unchanged
	
.button_a_down:
	bclr	#5,iocs_joystick_data+3 ; Joystick button #2 down.	

.button_a_unchanged:
	move	d0,(a0)+

	move	$ffff9202.w,d0

	cmp		(a0),d0
	beq		.direction_unchanged
	
	btst	#8,d0 ; Joypad up.
	beq		.up
	
	bset	#0,iocs_joystick_data+3 ; Not joystick up.

	bra		.not_up
	
.up:
	bclr	#0,iocs_joystick_data+3 ; Joystick up.

.not_up:
	btst	#9,d0 ; Joypad down.
	beq		.down
	
	bset	#1,iocs_joystick_data+3 ; Not joystick down.

	bra		.not_down
	
.down:
	bclr	#1,iocs_joystick_data+3 ; Joystick down.

.not_down:
	btst	#10,d0 ; Joypad left.
	beq		.left
	
	bset	#2,iocs_joystick_data+3 ; Not joystick left.

	bra		.not_left
	
.left:
	bclr	#2,iocs_joystick_data+3 ; Joystick left.

.not_left:
	btst	#11,d0 ; Joypad right.
	beq		.right
	
	bset	#3,iocs_joystick_data+3 ; Not joystick right.

	bra		.not_right
	
.right:
	bclr	#3,iocs_joystick_data+3 ; Joystick right.

.not_right:
.direction_unchanged:
	move	d0,(a0)+

	move	#$fffd,$ffff9202.w ; Select joypad input group 3.

	move	$ffff9200.w,d0

	cmp		(a0),d0
	beq		.button_b_unchanged
	
	btst	#1,d0
	beq		.button_b_down
	
	bset	#6,iocs_joystick_data+3 ; Joystick button #1 up.	

	bra		.button_b_unchanged
	
.button_b_down:
	bclr	#6,iocs_joystick_data+3 ; Joystick button #1 down.	

.button_b_unchanged:
	move	d0,(a0)+

	movem.l	(sp)+,d0/a0

	rts

; ------------------------------------------------------------------------------

timer_b_handler:
	rte

; ------------------------------------------------------------------------------

LINE_F_OFFSET=2 ; 0 = 68000, 2 = 68030

line_f_handler:
	movem.l	d1-d2/a0-a2,-(sp)

	move.l	22(sp),a0
	move	(a0),d1
	addq.l	#2,22(sp)

	cmp		#$fe00,d1 ; __LMUL
	bne		.not__lmul

	muls.l	(sp),d0

	bra		.exit

.not__lmul:
	cmp		#$fe01,d1 ; __LDIV
	bne		.not__ldiv

	divs.l	(sp),d0

	bra		.exit

.not__ldiv:
	cmp		#$fe0d,d1 ; __SRAND
	bne		.not__srand

	clr.l	d0

	bra		.exit

.not__srand:
	cmp		#$ff06,d1 ; _INPOUT
	bne		.not_inpout

	clr.l	d0

	bra		.exit

.not_inpout:
	cmp		#$ff20,d1 ; _SUPER
	bne		.not_super

	move.l	26+LINE_F_OFFSET+0(sp),a0

	clr.l	d0

	bra		.exit

.not_super:
	cmp		#$ff23,d1 ; _CONCTRL
	bne		.not_conctrl

	clr.l	d0

	bra		.exit

.not_conctrl:
	cmp		#$ff25,d1 ; _INTVCS
	bne		.not_intvcs

	move	26+LINE_F_OFFSET+0(sp),d0
	move	26+LINE_F_OFFSET+4(sp),a0

	clr.l	d0

	bra		.exit

.not_intvcs:
	cmp		#$ff36,d1 ; _DSKFRE
	bne		.not_dskfre

	move.l	#10000000,d0

	bra		.exit

.not_dskfre:
	cmp		#$ff37,d1 ; _NAMECK
	bne		.not_nameck

	clr.l	d0

	bra		.exit

.not_nameck:
	cmp		#$ff3d,d1 ; _OPEN
	bne		.not_open

	move.l	26+LINE_F_OFFSET+0(sp),a0
	move	26+LINE_F_OFFSET+4(sp),d0

	rem

	movem.l	d0/a0,-(sp)

	pea		(a0)
	move	#9,-(sp)
	trap	#1
	addq	#6,sp

	pea		.new_line
	move	#9,-(sp)
	trap	#1
	addq	#6,sp

	movem.l	(sp)+,d0/a0

	erem

	move	d0,-(sp)
	pea		(a0)
	move	#61,-(sp)
	trap	#1
	addq	#8,sp

	bra		.exit

.new_line:
	dc.b	10,13,0,0

.not_open:
	cmp		#$ff3f,d1 ; _READ
	bne		.not_read

	move	26+LINE_F_OFFSET+0(sp),d0
	move.l	26+LINE_F_OFFSET+2(sp),a0
	move.l	26+LINE_F_OFFSET+6(sp),d1
	and.l	#$7fffffff,d1

	pea		(a0)
	move.l	d1,-(sp)
	move	d0,-(sp)
	move	#63,-(sp)
	trap	#1
	lea		12(sp),sp

	bra		.exit

.not_read:
	cmp		#$ff3e,d1 ; _CLOSE
	bne		.not_close

	move	26+LINE_F_OFFSET+0(sp),d0

	move	d0,-(sp)
	move	#62,-(sp)
	trap	#1
	addq	#4,sp

	bra		.exit

.not_close:
	cmp		#$ff40,d1 ; _WRITE
	bne		.not_write

	move	26+LINE_F_OFFSET+0(sp),d0
	move.l	26+LINE_F_OFFSET+2(sp),a0
	move.l	26+LINE_F_OFFSET+6(sp),d1

	pea		(a0)
	move.l	d1,-(sp)
	move	d0,-(sp)
	move	#64,-(sp)
	trap	#1
	lea		12(sp),sp

	bra		.exit	

.not_write:
	cmp		#$ff42,d1 ; _SEEK
	bne		.not_seek

	move	26+LINE_F_OFFSET+0(sp),d0
	move.l	26+LINE_F_OFFSET+2(sp),a0
	move	26+LINE_F_OFFSET+6(sp),d1

	move	d1,-(sp)
	move	d0,-(sp)
	move.l	a0,-(sp)
	move	#66,-(sp)
	trap	#1
	lea		10(sp),sp

	bra		.exit	

.not_seek:
	cmp		#$ff44,d1 ; _IOCTRL
	bne		.not_ioctrl

	clr.l	d0

	bra		.exit

.not_ioctrl:
	cmp		#$ff4a,d1 ; _SETBLOCK
	bne		.not_setblock

	move.l	26+LINE_F_OFFSET+4(sp),d0

	cmp.l	#$ffffff,d0
	beq		.1

	clr.l	d0

	bra		.exit

.1:
	move.l	#$81200000,d0

	bra		.exit

.not_setblock:
	illegal

	clr.l	d0

.exit:
	movem.l	(sp)+,d1-d2/a0-a2

	rte

; ------------------------------------------------------------------------------

trap_2_handler:
	rte

; ------------------------------------------------------------------------------

trap_4_handler:
	rte

; ------------------------------------------------------------------------------

trap_f_handler:
	cmp.b	#$4,d0 ; _BITSNS
	bne		.no_bitsns

	clr.l	d0

	rte

.no_bitsns:
	cmp.b	#$10,d0 ; _CRTMOD
	bne		.no_crtmod

	clr.l	d0

	rte

.no_crtmod:
	cmp.b	#$14,d0 ; _TPALET2
	bne		.no_tpalet2

	movem.l	d1-d2/a0,-(sp)

	lea		L_00E82000+$200,a0
	and		#$f,d1

	clr.l	d0

	tst.l	d2
	bmi		.tpalet2_get_color

	move	d2,(a0,d1.w*2)

	bra		.tpalet2_skip

.tpalet2_get_color:
	move	(a0,d1.w*2),d0

.tpalet2_skip:
	movem.l	(sp)+,d1-d2/a0

	rte

.no_tpalet2:
	cmp.b	#$20,d0 ; _B_PUTC
	bne		.no_b_putc

	clr.l	d0

	rte

.no_b_putc:
	cmp.b	#$22,d0 ; _B_COLOR
	bne		.no_b_color

	clr.l	d0

	rte

.no_b_color:
	cmp.b	#$23,d0 ; _B_LOCATE
	bne		.no_b_locate

	clr.l	d0

	rte

.no_b_locate:
	cmp.b	#$3b,d0 ; _JOYGET
	bne		.no_joyget

	move.l	iocs_joystick_data,d0

	rte

.no_joyget:
	cmp.b	#$60,d0 ; _ADPCMOUT
	bne		.no_adpcmout

	movem.l	d0-d2/a0-a2,-(sp)

;	WavePlay #0,#12571,(a1),d2
;	movem.l	(sp)+,d0-d2/a0-a2
;	rte

;	move	#$200b,$ffff8932.w
;	clr.b	$ffff8936.w

	clr		$ffff8900.w

	move.b	#$81,$ffff8921.w ; Mono & 12571 Hz.

	move.l	a1,d0
	move.b	d0,$ffff8907.w
	lsr		#8,d0
	move.b	d0,$ffff8905.w
	swap	d0
	move.b	d0,$ffff8903.w

	move.l	a1,d0
	add.l	d2,d0
	move.b	d0,$ffff8913.w
	lsr		#8,d0
	move.b	d0,$ffff8911.w
	swap	d0
	move.b	d0,$ffff890f.w

	move	#1,$ffff8900.w

	movem.l	(sp)+,d0-d2/a0-a2

	clr.l	d0

	rte

.no_adpcmout:
	cmp.b	#$66,d0 ; _ADPCMSNS
	bne		.no_adpcmsns

	clr.l	d0

	btst	#0,$ffff8901.w
	beq		.replay_not_running

	moveq.l	#2,d0
	
.replay_not_running:
	rte

.no_adpcmsns:
	cmp.b	#$67,d0 ; _ADPCMMOD
	bne		.no_adpcmmod

	clr.l	d0

	rte

.no_adpcmmod:
	cmp.b	#$7d,d0 ; _SKEY_MOD
	bne		.no_skey_mod

	rte

.no_skey_mod:
	cmp.b	#$7f,d0 ; _ONTIME
	bne		.no_ontime

	move.l	#100*100,d0
	clr.l	d1

	rte

.no_ontime:
	cmp.b	#$81,d0 ; _B_SUPER
	bne		.no_b_super

	move.l	#-1,d0

	rte

.no_b_super:
	cmp.b	#$87,d0 ; _B_WPOKE
	bne		.no_b_wpoke

	rte

.no_b_wpoke:
	cmp.b	#$90,d0 ; _G_CLR_ON
	bne		.no_g_clr_on

	rte

.no_g_clr_on:
	cmp.b	#$92,d0 ; (未公開)	プライオリティ設定
	bne		.no_prio_set

	rte

.no_prio_set:
	cmp.b	#$ae,d0 ; _OS_CURON
	bne		.no_os_curon

	rte

.no_os_curon:
	cmp.b	#$af,d0 ; _OS_CUROFF
	bne		.no_os_curoff

	rte

.no_os_curoff:
	cmp.b	#$b1,d0 ; _APAGE
	bne		.no_apage

	clr.l	d0

	rte

.no_apage:
	cmp.b	#$b2,d0 ; _VPAGE
	bne		.no_vpage

	clr.l	d0

	rte

.no_vpage:
	cmp.b	#$b3,d0 ; _HOME
	bne		.no_home

	clr.l	d0

	rte

.no_home:
	cmp.b	#$b4,d0 ; _WINDOW
	bne		.no_window

	clr.l	d0

	rte

.no_window:
	cmp.b	#$b5,d0 ; _WIPE
	bne		.no_wipe

	clr.l	d0

	rte

.no_wipe:
	cmp.b	#$c1,d0 ; _SP_ON
	bne		.no_sp_on

	rte

.no_sp_on:
	cmp.b	#$c2,d0 ; _SP_OFF
	bne		.no_sp_off

	rte

.no_sp_off:
	cmp.b	#$ca,d0 ; _BGCTRLST
	bne		.no_bgctrlst

	rte

.no_bgctrlst:
	cmp.b	#$ce,d0 ; _BGTEXTGT
	bne		.no_bgtextgt

	clr.l	d0

	rte

.no_bgtextgt:
	cmp.b	#$cf,d0 ; _SPALET
	bne		.no_spalet

	movem.l	d1-d3/a0,-(sp)

	lea		L_00E82000+$200,a0
	lsl		#4,d2
	add		d1,d2

	clr.l	d0

	tst.l	d3
	bmi		.spalet_get_color

	move	d3,(a0,d2.w*2)

	bra		.spalet_skip

.spalet_get_color:
	move	(a0,d2.w*2),d0

.spalet_skip:
	movem.l	(sp)+,d1-d3/a0

	rte

.no_spalet:
	illegal

; ------------------------------------------------------------------------------
	data
; ------------------------------------------------------------------------------

last_joypad_data:
	dc		-1,-1,-1

iocs_joystick_data:
	dc.l	-1

vbl_wait_counter:
	dc		0

; ------------------------------------------------------------------------------
	bss
; ------------------------------------------------------------------------------

saved_stack_address:
	ds.l	1

game_heap_address:
	ds.l	1

; ------------------------------------------------------------------------------
	end
; ------------------------------------------------------------------------------

