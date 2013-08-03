* MAIN_1.S
* Main Demo Operating System
* Includes:
* Loading Routines, DSP OS and Tracker Music, Sequencing
* Vector/System saving and restoring
* Started 27/12/95


testing		equ	0
linkfile	equ	1
loop		equ	0

		opt	nodebug
		output	c:\_demo\sl.prg

		include	equates.s

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
 		bsr	print_string		;_only
		lea	clear_string(pc),a0
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
		ifne linkfile
		bsr	init_linkfile
		endc

		bsr	save_old_system

* Initialize I/O Loading System, Sequencing, Memory Allocation
* (All called via TRAP #6 command)
* Main demo loop:
* Load in music:

main_loop_loop:
		bsr	init_trap_6
		lea	module_name(pc),a0
		lea	module,a1
		moveq	#T6_Load,d0
		trap	#6

		;move.l	#$bffff,-(a7)
		;trap	#13
		;addq.l	#4,a7
		;btst	#3,d0
		;beq.s	.no_intro
		;bra.s	.no_intro		;part of the main demo?
		;lea	intro_script,a0
		;bsr	handle_script
.no_intro:
		lea	kick_in_script,a0
		bsr	handle_script

		lea	main_script,a0
		bsr	handle_script

.wait_music
		move.l	$466.w,d0
.wv		cmp.l	$466.w,d0
		beq	.wv

		move.l	Master_Volume,d0
		cmp.l	#100,d0
		blt.s	.done
		sub.l	#100,Master_Volume
		bra	.wait_music
.done
		clr.l	Master_Volume

		ifne	loop
		bra	main_loop_loop
		else
hangit		bra	hangit
		endc

* Restore all system stuff:
		bsr	restore_old_system

* Return:
		move.l	old_super_stack,a7
		rts

		include	script.s
		include	seq2.s
		include	oldsys2.s
		include	newsys.s
		include	unpack.s

		include	soundb.s

		ifne linkfile
		include	linkfile.s
		endc

*-------------------------------------
*
*
		section	data
*
*

* Resolution Data:
		even
res_1:		incbin	f:\data\tdf\res\blank.scp

		ifne	linkfile
link_file	dc.b	"SL.LNK",0
		even
		endc


* Text strings:
clear_screen_string:
clear_string:
			dc.b	27,"E",0

introduction_string:
			dc.b	27,"Es o n o l u m i n e s z e n z",13,10,10

			dc.b	"Bugfix Original Mix Version 1.2",13,10
			dc.b	"Release 15 April 1997",13,10,10

			dc.b	"press undo to exit",0

			even
;congratulations_string:	dc.b	27,"ETest finished",0,0
;			even
goodbye_string:		dc.b	27,"EThankyou for watching Sonolumineszenz",13,10,10
			dc.b	"...hardly worth it was it?...",13,10
			dc.b	"(c) 1997 Avena",0

error_string:		dc.b	" at address: $",0
hextable:		dc.b	"0123456789abcdef"
module_name:		dc.b	"DATA\ACIDTRIP.AON",0
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

module:			ds.b	367000		;enough for EIN.AON

load_address_install:	ds.b	128		;420000

load_address_1:		ds.b	150000
load_address_2:		ds.b	300000
load_address_bee:	ds.b	604000

load_address_mhed	=	load_address_2
load_address_inside	=	load_address_mhed+270000
load_address_tunnel	=	load_address_inside+300000
load_address_maphead	=	load_address_tunnel+235000
load_address_avena	=	load_address_maphead+467000

load_address_pic1	=	load_address_avena+275000+100000

load_address_3:		ds.b	load_address_pic1-load_address_3





*************	END OF FILE	************
