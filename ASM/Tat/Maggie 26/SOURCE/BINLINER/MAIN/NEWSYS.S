BytesPerLine = 768
ScreenLines  = 480			;should be enough?
ScreenSize = BytesPerLine*ScreenLines
aonon		equ	0

		include	system\malloc.s

init_my_system:
	bsr	get_monitor_type
	bsr	init_my_screens
	bsr	init_trap_6
	bsr	init_my_vectors
	clr.b	$fffffa19.w		;timer A off at first
	bsr	init_my_interrupts
	move.l	#return,$14.w
	rts

get_monitor_type:
		move.w	#0,d7

		move.w	#$59,-(a7)
		trap	#14
		addq.l	#2,a7

		and.b	#%11,d0
		cmp.b	#2,d0
		bne.s	.notvga
		move.w	#2,d7
.notvga:	move.w	d7,d0
		move.w	d0,monitor_type
		rts

init_my_screens:
	lea	screen_data,a6
	move.l	$44e.w,d0
	sub.l	#ScreenSize,d0
	sub.b	d0,d0
	move.l	d0,a3			;third
	sub.l	#ScreenSize,d0
	sub.b	d0,d0
	move.l	d0,a2			;logic
	sub.l	#ScreenSize,d0
	sub.b	d0,d0
	move.l	d0,a1			;physic
	move.l	a1,(a6)+
	move.l	a1,(a6)+
	move.l	a2,(a6)+
	move.l	a3,(a6)+
	rts



init_my_vectors:
	;move.l	#tracey,$24.w
	;ori	#$8000,sr
	move.w	#$2700,sr
	lea	$8.w,a0
	lea	handle_error(pc),a1
	moveq	#8,d0
.copy1	move.l	a1,(a0)+
	dbf	d0,.copy1
	move.w	#$2300,sr
	rts

tracey:	move.l	#0,d0
	movec	d0,vbr
	rte

return:	rte

init_my_interrupts:
	move.b	#$40,$fffffa17.w
	move.l	#system_vbl,$70.w
	;move.l	#aonfalc_vbl,$134.w
	move.l	#track_vbl,$134.w
	move.l	#$00200000,$fffffa06.w
	move.l	#$00200000,$fffffa12.w
	rts

init_trap_6:
	lea	trap_6_vector(pc),a0
	move.l	a0,($80+(6*4)).w
	rts



system_vbl:
	movem.l	d0-a6,-(a7)
	tst.w	scp_flag
	beq.s	._1
	bsr	set_scp_resolution
._1	addq.l	#1,$466.w
	cmp.b	#$61+$80,$fffffc02.w
	beq	space_pressed
	move.l	my_vbl(pc),a0
	tst.l	a0
	beq.s	._2
	jsr	(a0)
._2	movem.l	(a7)+,d0-a6
	rte

space_pressed:
	move.w	#44,error_number
	move.l	#$cabba9e,error_address
	bra	exit_with_error


*
*--------------------- ERROR HANDLER -------------------
*

exit_with_error2:
	movem.l	d0-a6,-(a7)
	movem.l	d0-a6,register_save
	bra	exit_with_error_2_patch

handle_error:
	move.w	#$2700,sr
	move.w	(a7)+,error_sr
	move.l	(a7)+,error_address
	move.w	(a7)+,error_number
exit_with_error:
	movem.l	d0-a6,-(a7)
	movem.l	d0-a6,register_save

	bsr	restore_old_system
	jsr	stop_tracker
	move.w	#$2300,sr

	move.l	#$7770000,$ffff8240.w
	move.l	#$0000000,$ffff8246.w

exit_with_error_2_patch:
	move.w	error_number(pc),d7
	bmi.s	.no_error

	ifeq testing
	 cmp.w	#44,error_number
	 beq	.no_error
	endc

	cmp.w	#4*50,d7
	bgt.s	.no_error
	and.w	#$fffc,d7
; Display:

	lea	clear_screen_string(pc),a0
	bsr	print_string_only
	move.l	(error_list.l,d7.w),a0
	bsr	print_string_only

	lea	error_string(pc),a0
	bsr	print_string_only
	move.l	error_address(pc),d0
	bsr	print_hex

	lea	start_string(pc),a0
	bsr	print_string_only
	move.l	#program_start,d0
	bsr	print_hex
	bsr	print_registers

	bsr	wait_key
	movem.l	(a7)+,d0-a6			;restore registers
	illegal
.no_error:
	movem.l	(a7)+,d0-a6			;restore registers
	bra	main_exit_program

error_list:
	dc.l	0,0
	dc.l	.bus		;8
	dc.l	.addr		;12
	dc.l	.ill		;16
	dc.l	.zero		;20
	dc.l	.chk		;24
	dc.l	.trapv		;28
	dc.l	.priv		;32
	dc.l	.trace		;36
	dc.l	.linea		;40
	dc.l	.space		;44
	dc.l	.disk		;48
	
.bus:	dc.b	"Bus error",0
.addr:	dc.b	"Address error",0
.ill:	dc.b	"Illegal instruction",0
.zero:	dc.b	"Zero divide",0
.chk	dc.b	"CHK instruction",0
.trapv:	dc.b	"TRAPV",0
.priv:	dc.b	"Privilege violation",0
.trace:	dc.b	"TRACE",0
.linea	dc.b	"Line-A error",0
.space	dc.b	"Space pressed",0
.disk	dc.b	"My Disk error",0
	even

register_save:	ds.l	16
newline:	dc.b	13,10,0
	even

print_registers:
	lea	register_save,a6
	moveq	#15-1,d7
.copy:
	lea	newline(pc),a0
	bsr	print_string_only
	move.l	(a6)+,d0
	movem.l	d7/a6,-(a7)
	bsr	print_hex
	movem.l	(a7)+,d7/a6
	dbf	d7,.copy
	rts


print_string:
	bsr	print_string_only
	bsr	wait_key
	rts

print_string_only:
	pea	(a0)
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	rts

wait_key:
	move.w	#8,-(a7)
	trap	#1
	addq.l	#2,a7
	rts

print_hex:
	lea	hextable(pc),a6
	move.l	d0,d7
	moveq	#8-1,d6
.loop:	rol.l	#4,d7
	move.l	d7,d0
	and.w	#%1111,d0
	move.b	(a6,d0.w),d0
	move.w	d0,-(a7)
	move.w	#2,-(a7)
	trap	#1
	addq.l	#4,a7
	dbf	d6,.loop
	rts


*
*-------------------- TRAP 6 -----------------------
*


trap_6_vector:
	movem.l	d2-d7/a1-a6,-(a7)
	tst.w	d0
	bmi.s	.no_trap
	cmp.w	#trap_6_maximum,d0
	bgt.s	.no_trap
	move.l	(trap_6_list,pc,d0.w*4),a5
	jsr	(a5)
.no_trap:
	movem.l	(a7)+,d2-d7/a1-a6
	rte

trap_6_list:
	dc.l	trap_6_load_file	;0
	dc.l	trap_6_set_res		;1
	dc.l	trap_6_install_dsp	;2
	dc.l	trap_6_run_dsp		;3
	dc.l	0			;4 (unpack_file)
	dc.l	trap_6_get_music	;5
	dc.l	trap_6_install_vbl	;6
	dc.l	trap_6_get_feedback	;7
	dc.l	trap_6_get_colour	;8
	dc.l	trap_6_get_screens	;9
	dc.l	trap_6_update_screens	;10
	dc.l	trap_6_get_monitor	;11
	dc.l	trap_6_malloc		;12
	dc.l	trap_6_mfree		;13
	dc.l	trap_6_testifdone	;14

trap_6_load_file:
	move.l	a0,file_name
	move.l	a1,file_address
	bsr	load_file
	rts

trap_6_set_res:
	move.l	a0,scp_address
	move.w	#-1,scp_flag
	rts

trap_6_install_dsp:
	jsr	Dsp_Library+4
	rts

trap_6_run_dsp:
	jsr	Dsp_Library+8
	rts

trap_6_get_music:
	lea	music_data,a0
	rts

trap_6_update_screens:
	lea	screen_data,a6
	move.l	a0,(a6)+
	move.l	a1,(a6)+
	move.l	a2,(a6)+
	move.l	a3,(a6)+
	rts

trap_6_get_screens:
	lea	screen_data,a0
	rts

trap_6_get_feedback:
	lea	feedback_data,a0
	rts

trap_6_get_colour:
	lea	colour_data,a0
	rts

trap_6_install_vbl:
	move.l	a0,my_vbl		;0 = no vbl routine
	rts

trap_6_get_monitor:
	move.w	monitor_type,d0
	rts

trap_6_malloc:
	move.l	d1,d0
	jsr	mal_malloc
	rts

trap_6_mfree:
	jsr	mal_mfree
	rts

; we are done if:
; - (current pattern > endpattern)
; OR (current pattern = endpattern AND currstep >= endstep)

trap_6_testifdone:
	moveq	#0,d0			;assume OK
	move.w	track_end_pattern,d1	;d1 = endpatt
	move.w	track_end_step,d2	;d2 = endstep
	move.l	pt_SongPosition,d3	;d3 = currpatt
	move.l	pt_patternposition,d4
	asr.l	#4,d4			;divide by 16
					;d4 = currstep
	cmp.w	d1,d3
	bgt.s	.yes
	beq.s	.teststep
	;moveq	#0,d0
	rts
.teststep:
	cmp.w	d2,d4
	bge.s	.yes
	;moveq	#0,d0
	rts
.yes:	moveq	#-1,d0
	rts


music_data:
	ifne	aonon
	dc.l	aon_data
	dc.l	mix_data+0*mix_datasize
	dc.l	mix_data+1*mix_datasize
	dc.l	mix_data+2*mix_datasize
	dc.l	mix_data+3*mix_datasize
	endc
*--------------------------------------------------------
init_file_system:
	pea	.filepath(pc)
	move.w	#$3b,-(a7)			;gemdos $3b, chdir
	trap	#1
	addq.l	#6,a7
	rts

.filepath:
	dc.b	"data",0
	even

load_file:
	move.w	#$2300,sr
	bsr	restore_loading_vectors
	bsr	patch_loading_vectors
	bsr	open_file
	bsr	read_file
	bsr	close_file
	bsr	disable_loading_vectors
	move.l	file_address(pc),a0
	move.l	a0,a1
	bsr	try_unpack_file
	rts

patch_loading_vectors:
	move.l	$70.w,bodge_70
	move.l	#load_patch,$70.w
	rts

load_patch:
	movem.l	d0-a6,-(a7)
	addq.l	#1,$466.w
	cmp.b	#$61+$80,$fffffc02.w
	beq	space_pressed
	move.l	my_vbl(pc),a0
	tst.l	a0
	beq.s	._2
	jsr	(a0)
._2	movem.l	(a7)+,d0-a6

bodge_70 equ *+2
	jmp	$12345678

	ifeq	linkfile
open_file:
	clr.w	-(a7)
	move.l	file_name(pc),-(a7)
	move.w	#$3d,-(a7)
	trap	#1
	addq.l	#8,a7
	move.w	d0,file_handle
	rts

close_file:
	move.w	file_handle(pc),-(a7)
	move.w	#$3e,-(a7)
	trap	#1
	addq.l	#4,a7
	rts

read_file:
	move.l	file_address(pc),-(a7)
	pea	$ffffff
	move.w	file_handle(pc),-(a7)
	move.w	#$3f,-(a7)
	trap	#1
	lea	12(a7),a7
	rts
	endc

files_error:
	move.w	d0,-(a7)

	move.w	#65000,d0
.error	add.l	#$12345678,$ffff9800.w
	add.w	#$2345,$ffff8240.w
	dbf	d0,.error
	subq.l	#8,a7

	move.w	(a7)+,d0
	move.w	#48,error_number
	jmp	exit_with_error


;files_folder:	dc.b	"data",0
;		even

*-----------------------------------------------------------

set_scp_resolution:
	clr.w	scp_flag
	move.l	scp_address(pc),a0
	lea	122(a0),a0
	move.l	(a0)+,$ffff8282.w
	move.l	(a0)+,$ffff8286.w
	move.l	(a0)+,$ffff828a.w
	;move.w	(a0)+,$ffff828c.w

	move.l	(a0)+,$ffff82a2.w
	move.l	(a0)+,$ffff82a6.w
	move.l	(a0)+,$ffff82aa.w
	;move.w	(a0)+,$ffff82ac.w

	move.w	(a0)+,$ffff820a.w
	move.w	(a0)+,$ffff82c0.w
	clr.w	$FFFF8266.w
	move.l	(a0)+,d0
	bmi.s	.ste_comp
	clr.b	$FFFF8260.w
	move.w	d0,$FFFF8266.w
	bra.s	.set_vide
.ste_comp
	clr.w	$FFFF8266.w
	swap	d0
	move.b	d0,$FFFF8260.w
.set_vide:
	move.w	(a0)+,$ffff82c2.w
	move.w	(a0)+,$ffff8210.w
	rts

screen_data		ds.l	4
file_name		ds.l	1
file_address		ds.l	1
file_handle		ds.w	1
scp_flag		dc.w	0
scp_address		dc.l	0
my_vbl			dc.l	0
old_70			ds.l	1
feedback_data		ds.l	1
colour_data		ds.l	1
monitor_type		ds.w	1
track_end_pattern:	dc.w	0
track_end_step:		dc.w	0

