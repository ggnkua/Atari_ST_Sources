* Start music:
handle_script:
	move.l	a0,script_position

	move.l	#$0009,d0
	movec	d0,cacr

	lea	res_1,a0
	move.w	#T6_SetRes,d0
	trap	#6

	clr.l	$ffff9800.w

script_loop:
	move.l	script_position,a0
	move.l	(a0)+,d0		;command word
	cmp.l	#"QUIT",d0
	beq	script_quit
	cmp.l	#"CLR_",d0
	beq	script_clear_screens
	cmp.l	#"MUSI",d0
	beq	script_start_music
	cmp.l	#"END_",d0
	beq	script_end_program
	cmp.l	#"WAIT",d0
	beq	script_wait_music
	cmp.l	#"REST",d0
	beq	script_restore_system
	cmp.l	#"SYS_",d0
	beq	script_init_system
	cmp.l	#"EXEC",d0
	beq	script_execute_program
	cmp.l	#"LOAD",d0
	beq	script_load_program
	cmp.l	#"FADE",d0
	beq	script_fade

	move.l	a0,script_position
	bra	script_loop
script_quit:
	rts

script_position
	ds.l	1


script_restore_system
	move.l	a0,script_position
	bsr	restore_old_system
	bra	script_loop

script_start_music:
	move.l	a0,script_position
	jsr	tracker_player+0
	lea	module,a0
	jsr	tracker_player+4
	jsr	tracker_player+8
	bra	script_loop

script_clear_screens:
	move.l	a0,script_position
	lea	screen_data,a6
	move.l	(a6)+,a0
	move.l	(a6)+,a1
	move.l	(a6)+,a2
	moveq	#0,d0
	move.w	#(ScreenSize/16)-1,d1
.wipe
	rept	4
	move.l	d0,(a0)+
	move.l	d0,(a1)+
	move.l	d0,(a2)+
	endr
	dbf	d1,.wipe
	bra	script_loop


script_init_system
	move.l	a0,script_position
	bsr	init_my_system
	bra	script_loop

;temp	ds.l	2

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

script_wait_vbl:
	move.l	d0,-(a7)
	move.l	$466.w,d0
.wv	cmp.l	$466.w,d0
	beq.s	.wv
	move.l	(a7)+,d0
	rts

script_wait_music:
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	a0,script_position

	asl.l	#2,d1			;multiply all by 4
	and.l	#$3fc,d1
	lea	aon_data,a6
.waitloop1:
	moveq	#0,d2
	move.b	aon_pos(a6),d2
	cmp.w	d2,d0
	blt.s	.gonetoofar
	bgt.s	.waitloop1		;if expected > current, wait
.waitloop2:
	move.w	aon_patcnt(a6),d2
	and.w	#$3fc,d2
	cmp.w	d2,d1
	bgt.s	.waitloop2
.gonetoofar:
	bra	script_loop

script_end_program:
	move.l	(a0)+,a1
	move.l	a0,script_position
	clr.w	prog_activeflag(a1)
	bra	script_loop


script_load_program:
	move.l	(a0)+,a1
	move.l	a0,script_position
	st	prog_activeflag(a1)
	lea.l	prog_filename(a1),a0
	move.l	prog_loadaddr(a1),a1
	move.l	a0,file_name
	move.l	a1,file_address
	bsr	load_file
	move.l	file_address,a0
	bsr	relocate_program
	move.l	file_address,a0
	bsr	clear_program_bss
	bra	script_loop

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

script_execute_program:
	move.l	(a0)+,a2
	move.l	(a0)+,d0
	move.l	(a0)+,a1		;sequencing data
	move.l	a0,script_position

	move.l	prog_loadaddr(a2),a6
	move.l	d0,a0
	jsr	(a6)
	bra	script_loop

intro_script:
	dc.l	"QUIT"
