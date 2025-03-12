;
;
; SCRIPT.S
; rewritten 8.98 for binliner
; bigger and harder
;
;

; the main shell now calls the routines by sending the following
; information:
; d0 = number of the effects routine (e.g. fx1 = 0)
;
; d1 = the type of call (as a multiple of 4)
; a0 = position in the script (if sending a message)
; Sending a message should be treated as a special case
; .. it is the only one where a0 should not be saved!
;
; control is returned to the demo by use of RTS (ie. stack)
;
; the binmain MUST return a0 in the correct position
; else all will crash before us
;

; ------------------------------------------------------------------

 			include	system\malloc.s
			include	system\shared.s
; ------------------------------------------------------------------
handle_script:
 		move.w	#$2300,sr
 		move.l	a0,script_position
 		move.l	#$0009,d0
 		movec	d0,cacr
script_loop:
 		move.l	script_position,a0
 		move.l	(a0)+,d0		;command word
 		cmp.l	#"SYS_",d0
 		beq	script_init_system
 		cmp.l	#"LOAD",d0
 		beq	script_load_program
 		cmp.l	#"STPR",d0
 		beq	script_start_program
 		cmp.l	#"SETE",d0
 		beq	script_set_end
 		cmp.l	#"MESS",d0
 		beq	script_send_message
 		cmp.l	#"MUSI",d0
 		beq	script_start_music
 		cmp.l	#"STRT",d0
 		beq	script_start_effect
 		cmp.l	#"SESS",d0
 		beq	script_start_session
 		cmp.l	#"SEQ_",d0
 		beq	script_start_sequence
 		cmp.l	#"FRAM",d0
 		beq	script_do_frames
 		cmp.l	#"SEQE",d0
 		beq	script_end_sequence
 		cmp.l	#"SESE",d0
 		beq	script_end_session
 		cmp.l	#"SHUT",d0
 		beq	script_end_effect
 		cmp.l	#"END_",d0
 		beq	script_unload_program
 		cmp.l	#"FADE",d0
 		beq	script_fade
 		cmp.l	#"QUIT",d0
 		beq	script_quit

 		move.l	a0,script_position
 		bra	script_loop
script_quit:
 		rts

; ------------------------------------------------------------------
script_set_end:
		move.l	(a0)+,d0		;ignore for the moment
		move.l	(a0)+,d1
		move.l	(a0)+,d2
		move.l	a0,script_position
		move.w	d1,track_end_pattern
		move.w	d2,track_end_step
		bra	script_loop
		rts

; ------------------------------------------------------------------
script_send_message:
		move.l	(a0)+,a6		;program data
		move.l	(a0)+,d0		;fx number
		move.l	d7,d1			;routine number
		move.l	prog_loadaddr(a6),a5
		lea	$1c(a5),a5
		jsr	+8(a5)			;handle message
; BE CAREFUL WITH A0!
		move.l	a0,script_position
		bra	script_loop

; ------------------------------------------------------------------
script_start_effect:
		move.l	#main_on_loading,d7
		bra	script_general_run
script_start_session:
		;move.w	#$070,$ffff8240.w
		move.l	#main_on_session,d7
		bra	script_general_run

script_start_sequence:
		move.l	#main_on_sequence,d7
		bra	script_general_run
script_do_frames:
		;move.w	#$770,$ffff8240.w
		move.l	#main_do_frames,d7
		bra	script_general_run
script_end_sequence:
		move.l	#main_on_sequence_end,d7
		bra	script_general_run
script_end_session:
		move.l	#main_on_session_end,d7
		bra	script_general_run
script_end_effect:
		move.l	#main_on_loading_end,d7
		bra	script_general_run

; ------------------------------------------------------------------
script_general_run:
		move.l	(a0)+,a6		;program data
		move.l	(a0)+,d0		;fx number
		move.l	d7,d1			;routine number
		pea	(a0)

		move.l	prog_loadaddr(a6),a5
		lea	$1c(a5),a5
		jsr	+4(a5)

; call the routine x of the given 
		move.l	(a7)+,a0		;restore a0
		move.l	a0,script_position
		bra	script_loop

; ------------------------------------------------------------------
script_unload_program:
		move.l	(a0)+,a6		;program data
		move.l	a0,script_position
		move.l	prog_loadaddr(a6),a5
		lea	$1c(a5),a5
		pea	(a6)
		jsr	+12(a5)
		move.l	(a7)+,a6
; now deallocate the memory:
		move.l	prog_loadaddr(a6),a0
		jsr	mal_mfree

		bra	script_loop

; ------------------------------------------------------------------
script_start_program:
		;move.w	#$700,$ffff8240.w

		move.l	(a0)+,a6		;program data
 		move.l	a0,script_position

 		move.l	prog_loadaddr(a6),a5
		lea	$1c(a5),a5
 		jsr	0(a5)
 		bra	script_loop

; ------------------------------------------------------------------
script_restore_system
 		move.l	a0,script_position
 		bsr	restore_old_system
 		bra	script_loop

; ------------------------------------------------------------------
script_start_music:
 		move.l	a0,script_position
 		jsr	tracker_player+0
 		lea	module,a0
 		jsr	tracker_player+4
 		jsr	tracker_player+8
 		bra	script_loop

; ------------------------------------------------------------------
script_init_system
 		move.l	a0,script_position
 		bsr	init_my_system
 		bra	script_loop

; ------------------------------------------------------------------
script_fade:
 		move.l	a0,script_position
 		move.l	Master_Volume,d0
.fade:
 		bsr	script_wait_vbl
 		sub.l	#500,d0
 		move.l	d0,Master_Volume
 		bpl.s	.fade	
 		clr.l	Master_Volume
 		bra	script_loop

; ------------------------------------------------------------------
script_wait_vbl:
 		move.l	d0,-(a7)
 		move.l	$466.w,d0
.wv		cmp.l	$466.w,d0
 		beq.s	.wv
 		move.l	(a7)+,d0
 		rts

; ------------------------------------------------------------------
script_end_program:
 		move.l	(a0)+,a1
 		move.l	a0,script_position
 		clr.w	prog_activeflag(a1)
 		bra	script_loop


; ------------------------------------------------------------------
script_load_program:
		;move.w	#$007,$ffff8240.w
; first allocate memory for it:
 		move.l	(a0)+,a6
 		move.l	a0,script_position

		move.l	prog_memsize(a6),d0
		jsr	mal_malloc

		move.l	d0,prog_loadaddr(a6)
 		st	prog_activeflag(a6)

 		lea.l	prog_filename(a6),a0
 		move.l	prog_loadaddr(a6),a1
 		move.l	a0,file_name
 		move.l	a1,file_address
 		bsr	load_file

 		move.l	file_address,a0
 		bsr	relocate_program
 		move.l	file_address,a0
 		bsr	clear_program_bss
 		bra	script_loop

; ------------------------------------------------------------------
relocate_program:
 		move.l	2(a0),a2	;TEXT
 		add.l	6(a0),a2	;DATA?
 		add.l	$e(a0),a2	;SYMBOL
 		move.l	a0,a4
 		add.l	a4,a2		;a2 address of reloc info
 		add.l	#$1c,a2
 		lea	$1c(a4),a1	;a1 position in program
 		move.l	a1,a3		;a3 address of reloc info
 		tst.l	(a2)
 		beq	.relocate_end
 		move.l	(a2)+,d0
 		add.l	d0,a1
 		move.l	(a1),d1
 		add.l	a3,d1
 		move.l	d1,(a1)		;reloc first one
 		moveq	#1,d2
 		move.l	a3,d3
.relocate_loop
 		moveq	#0,d0
 		move.b	(a2)+,d0
 		beq	.relocate_end
 		cmp.b	d2,d0
 		beq	.extra_bytes
 		add.w	d0,a1
 		add.l	d3,(a1)
 		bra.s	.relocate_loop
.extra_bytes:
 		lea	254(a1),a1
 		bra.s	.relocate_loop
.relocate_end:
 		rts

clear_program_bss:
 		lea.l	$1c(a0),a1
 		add.l	$2(a0),a1		;text
 		add.l	$6(a0),a1		;symbol
 		move.l	$a(a0),d2
 		tst.l	d2
 		beq	.clear_bss_end
 		asr.l	#4,d2
 		moveq	#0,d0
.clear	move.l	d0,(a1)+
 		move.l	d0,(a1)+
 		move.l	d0,(a1)+
 		move.l	d0,(a1)+
 		subq.l	#1,d2
 		bne.s	.clear
.clear_bss_end
 		rts

; ------------------------------------------------------------------
script_execute_program:
		
 		move.l	a0,script_position

 		move.l	prog_loadaddr(a2),a6
 		move.l	d0,a0
 		jsr	(a6)
 		bra	script_loop

; ------------------------------------------------------------------

intro_script:		dc.l	"QUIT"
script_position:	ds.l	1
