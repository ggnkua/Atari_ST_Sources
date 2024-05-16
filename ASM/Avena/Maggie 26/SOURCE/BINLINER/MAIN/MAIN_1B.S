* MAIN_1.S
* Main Demo Operating System
* Includes:
* Loading Routines, DSP OS and Tracker Music, Sequencing
* Vector/System saving and restoring
* Started 27/12/95

* Updated for Binliner 8/7/98

testing		equ	1
linkfile	equ	0
loop		equ	0

		opt	nodebug
		output	e:\test\binliner.tos

		include	system\shared.s
		;equates.s

program_start:
main_start:
* Allocate memory:
		move.l	a7,a5
		move.l	#user_stack,a7
		move.l	4(a5),a5		;a5 = basepage
		move.l	$c(a5),d0		;program area
		add.l	$14(a5),d0		;data area
		add.l	$1c(a5),d0		;bss area
		add.l	#$100,d0
		move.l	d0,-(a7)
		pea	(a5)
		pea	$4a0000
		trap	#1
		lea	12(a7),a7
		tst.l	d0
		bne	main_exit_program

* Check for RGB, Falcon etc.
		lea	introduction_string(pc),a0
 		bsr	print_string_only

* OK, run program:
		pea	main_start_system(pc)
		move.w	#$26,-(a7)
		trap	#14
		addq.l	#6,a7

		;lea	congratulations_string(pc),a0
		;bsr	print_string
main_exit_program:
		lea	goodbye_string(pc),a0
		bsr	print_string

		clr.w	-(a7)
		trap	#1



*-------------------------------------
main_start_system:
		move.l	#$0009,d0
		movec	d0,cacr

		move.l	a7,old_super_stack
		lea	my_super_stack,a7
* Save everything:
		print	<27,"EAvena Demo OS v1.0 by tat",13,13,10>
		print	<"Initialising linkfile... ">
		ifne linkfile
		bsr	init_linkfile
		endc
		bsr	init_file_system
		print	<"done",13,10>

		print	<10,"Installing 32-bit DOS extender... ",13,10>
		print	<"(c) 1884 Ripoff Systems Inc (Scaffold/Pietel)",13,10>
		print	<"Initialising system... ">
		bsr	save_old_system
		print	<'done',13,10>

* Initialize I/O Loading System, Sequencing, Memory Allocation
* (All called via TRAP #6 command)
* Main demo loop:
* Load in music:
		print	<'Checking hardware... done',13,10>

main_loop_loop:
		print	<'Loading module... '>
		bsr	init_trap_6
		lea	module_name(pc),a0
		lea	module,a1
		moveq	#T6_Load,d0
		trap	#6
		print	<'done',13,10>

		print	<'Initialising scripts...'>

		;lea	kick_in_script,a0
		;bsr	handle_script
		lea	main_script,a0
		bsr	handle_script

;.wait_music
;		move.l	$466.w,d0
;.wv		cmp.l	$466.w,d0
;		beq	.wv
;
;		move.l	Master_Volume,d0
;		cmp.l	#100,d0
;		blt.s	.done
;		sub.l	#100,Master_Volume
;		bra	.wait_music
;.done
;		clr.l	Master_Volume

		ifne	loop
		bra	main_loop_loop
		endc

* Restore all system stuff:
		bsr	restore_old_system
		print	<'Restoring old system... done',13,10>

* Return:
		move.l	old_super_stack,a7
		rts

		section	text
		include	soundpr2.s
		section	text
		include	newsys.s
		section	text
		include	script.s
		section	text
		include	binseq.s
		section	text
		include	oldsys2.s
		section	text
		include	unpack.s

		;include	soundb.s

		ifne linkfile
		include	linkfile.s
		endc

*-------------------------------------
*
*
		section	data
*
*

		ifne	linkfile
link_file	dc.b	"binliner.lnk",0
		even
		endc


* Text strings:
clear_screen_string:
clear_string:
			dc.b	27,"E",0

introduction_string:
			dc.b	27,"Ebinliner:1.0 by avena",13,10,10
			dc.b	0
			even

;congratulations_string:	dc.b	27,"ETest finished",0,0
;			even
goodbye_string:		dc.b	27,"E"
			dc.b	"music:       damian russell",13,10
			dc.b	"             nils feske",13,10,10
			dc.b	"programming: steven tattersall",13,10,10
			dc.b	"graphics:    kay tennemann",13,10
			dc.b	"             torsten keltsch",13,10
			dc.b	"(c) 1998",13,10
			dc.b	"Thankyou for watching",0
			even

error_string:		dc.b	" at address: $",0
start_string:		dc.b	13,10,"Program start address:",0
hextable:		dc.b	"0123456789abcdef"
;module_name:		dc.b	"test.aon",0
module_name:		dc.b	"mod\test.mod",0
			even


*-------------------------------------
*
*
		section	bss
*
*

old_super_stack:	ds.l	1
old_mfp_data:		ds.l	10
old_system_data:	ds.l	1400
old_loading_vectors:	ds.l	10

error_number:		ds.w	1
error_sr:		ds.w	1
error_address:		ds.l	1

			ds.l	30
user_stack:		equ	*
			ds.l	600
my_super_stack:		equ	*
			even
			ds.l	50

module:			ds.b	1100000		;*gulp*;enough for EIN.AON

load_address_install:	ds.b	128		;420000

load_address_1:		ds.b	150000
