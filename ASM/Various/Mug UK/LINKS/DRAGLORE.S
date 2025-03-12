*************************************************************************
*		Brown Beer Bottle Developments GEM Link-Filer		*
*		---------------------------------------------		*
*									*
* Written by: MAC SYS DATA of PERSISTENCE OF VISION			*
*									*
* Additions by: MUG U.Kø and MAC SYS DATA				*
*									*
*									*
* Link file generator by: MUG UKø					*
*									*
* Last source update by MSD: 9th June 1993 v1.73			*
*									*
* Last source update by MUG UKø: 5th February 1993 v1.51		*
*    Last link generator update: 19th November 1992 v1.92		*
*                                                                       *
* Revisted source code in July 1997 to add support for Pacifist Emulator*
*									*
*************************************************************************
*
* NOTE: If it can load via a standard TRAP #1 loader (ie. FREAD used)
*	then you can link-file it !!
*
*************************************************************************
	opt	o+,w-,p+
	
;YES	equ	1
yes	equ	1
;NO	equ	0
no	equ	0

*** Switches to enable/disable settings ****************************

atom_33 	equ	no	; Atomik v3.3
atom_35 	equ	no	; Atomik v3.5
ice_240 	equ	yes	; Ice v2.40 (also v2.31)
fire_201	equ	no	; Fire v2.01
sen_205 	equ	no	; Sentry Packer v2.05
speed_2		equ	no	; Speed Packer 2
speed_3		equ	no	; Speed Packer 3

****** Usual MUG U.Kø options ******

ascii		equ	no	; Text required ??
wait_key	equ	no	; Wait for a key before continuing ??
res_84		equ	yes	; Restore Trap #1 (If a demo returns to desktop)
relocat 	equ	no	; Relocate Depack Routs to low memory address
flash		equ	no	; Depack Flash ??
exec		equ	yes	; YES to run a .PRG
				; NO to load a BIN to an address ??
quit		equ	yes	; Program has a quit option
reset		equ	no	; Hard reset upon quitting ??
				; Needs QUIT to be set to YES !!
meg_only	equ	no	; 1 Megabyte only ??
test_ste	equ	no
mouse_off	equ	no	; Turn beastie off

pacifist	equ	no	; Are we on a real ST or under Pacifist check !

prog_len	equ	0	; This must be set to the length of the program
				; file if you have merged the program file and
				; link-file as one.  DO NOT USE THIS AT ANY OTHER TIME
				; AS THE ROUTINE WILL NOT FIND ANY OF YOUR FILES !!
				; See docs for full explanation on how to use this option
*************************************************************************
start	move.l	4(a7),a0
	lea	our_stack(pc),a7
	move.l	#stop-start+$100,-(a7)	;only keep the bit we want
	move.l	a0,-(sp)
	clr.w	-(sp) 
	move.w	#$4a,-(sp)	;MSHRINK
	trap	#1
	lea	12(sp),sp

	bsr	set_super	; Go supervisor mode and
				; store old Trap #1 vector

*************************************************************************
* Has user only got 512K ????
		ifne	meg_only
		move.l	$42e,d0 	; Top of user RAM
		cmp.l	#$00080000,d0	; if it equals $80000
		beq	half_meg	; then get an upgrade !!
		endc	

*************************************************************************
* STE Test Routine - Sets 'ste_flg' true if the machine is STE and inits.
		ifne	test_ste	
		bsr	STE_test
		lea	STE_flag(pc),a6
		tst.w	(a6)		; Yes it's an STE
		bne.s	yes_STE
yep_STE 	pea	STE_text(pc)	; Print text accordingly
		move.w	#9,-(sp)
		trap	#1
		addq.l	#6,sp
		move.w	#7,-(sp)	; Wait for key
		trap	#1
		addq.l	#2,sp
		move.w	#$4c,-(sp)	; exit
		trap	#1
yes_STE
		endc

*************************************************************************
* Test whether this is running on a normal ST/E or under Pacifist Emulator!

		ifne pacifist
; FOR ST Programmers - How to detect PaCifiST (0.46 of greater)
;
; When Vsync is called with D6=D7='Emu?' and those registers are
; altered, you can assume you're running under an Emulator.
;
; If D6='PaCi' & D7='fiST', then it's under PaCifiST and A0 points out
; some extra hardware registers:
;
; 0     BYTE    major version (BCD)
; 1     BYTE    minor version (BCD)
;
; Special registers will be added with each version

        move.l  #'Emu?',d5
        move.l  d5,d7
        move.l  d5,d6
        move    #$25,-(a7)
        trap    #$e
        addq.l  #2,a7
        move.l  a0,regbase

        cmp.l   d5,d6
        bne.s   under_emu
        cmp.l   d5,d7
        beq.s   normal_st
under_emu:
        cmp.l  #'PaCi',d6
        bne.s  other_emu
        cmp.l  #'fiST',d7
        bne.s  other_emu

        move.l  regbase(pc),a0
        move.b  (a0),d0
        add.b   d0,majorv
        move.b  1(a0),d0
        move    d0,d1
        lsr     #4,d1
        and     #$f,d0
        and     #$f,d1
        add.b   d1,minorv
        add.b   d0,minorv+1
        
        lea     pacifist_emu(pc),a0
        bra.s   print
other_emu:
        lea     an_emu(pc),a0
	bra.s	print
normal_st:
        lea     no_emu(pc),a0
print:
        pea     (a0)
        move    #9,-(a7)
        trap    #1
        addq.l  #6,a7
        move    #1,-(a7)
        trap    #1
        addq.l  #2,a7

        endc

*************************************************************************
		ifne	mouse_off
		move.b	#$12,$fffffc02.w	;no mouse
		endc

		lea	OLD_84(pc),a6
		move.l	$84.w,(a6)		;Store old TRAP #1
		lea	new_trap1(pc),a0	;Set new TRAP #1
		move.l	a0,$84.W

*************************************************************************
* Rem these two lines out if you don't require them

		clr.w	$ffff8240.w	; border = black
		move.w	#-1,$ffff825e.w ; text = white

		bsr	set_user	; User mode
	
*************************************************************************
* Print ego trip if required

		ifne	ascii
		pea	fame_message(pc)
		move.w	#9,-(sp)
		trap	#1
		addq.l	#6,sp
		endc

*************************************************************************
* Wait for key if required

		ifne	wait_key
		move.w	#7,-(sp)
		trap	#1
		addq.l	#2,sp
		endc

*************************************************************************
* Relocation is optional, it simply moves the depack routine to low mem

		ifne	relocat
		lea	depack_routs(pc),a0	; relocate depack routines
		move.l	#stop-depack_routs,d6
		lea	$1a90.w,a2		;destination in lower memory
rel_loop	move.b	(a0)+,(a2)+ 
		sub.l	#1,d6
		bne.s	rel_loop
		endc

*************************************************************************
* Run program file
		ifne	exec
		pea	null(pc)
		pea	null(pc)
		pea	execfile(pc)
		clr.w	-(sp)
		move.w	#$4b,-(sp)	;PEXEC
		trap	#1
		lea	16(sp),sp

		pea	null(pc)
		pea	null(pc)
		pea	execfile2(pc)
		clr.w	-(sp)
		move.w	#$4b,-(sp)	;PEXEC
		trap	#1
		lea	16(sp),sp

	elseif

*************************************************************************
; This routine will load in a binary file to a certain address and
; JMP to it !!	The code will be searched for within the link-file, so
; it is worth having a quick hack at a 500-byte loader to see if it can
; be re-produced down here instead (1 less file !!)

loader		clr.w	-(sp)
		pea	filename(pc)
		move.w	#$3d,-(sp)	;FOPEN
		trap	#1
		addq.l	#8,sp
		tst.l	d0
		bmi.s	loader
		lea	handle(pc),a6
		move.w	d0,(a6)
		move.l	#$20000,-(sp)	; Address to load code from link to
		move.l	#1226,-(sp)	; >Length (original - not packed !!)
		move.w	(a6),-(sp)
		move.w	#$3f,-(sp)	;FREAD
		trap	#1
		lea	12(sp),sp
		move.w	(a6),-(sp)
		move.w	#$3e,-(sp)	;FCLOSE 
		trap	#1
		addq.l	#4,sp
		jmp	$20000	; address to run code

filename	dc.b	'slide.prg',0
		even
handle		dc.w	0
		endc

*************************************************************************
* Restore old TRAP 1 vector
		ifne	res_84
		bsr	set_super	; restore old vector
		move.l	OLD_84(PC),$84.w
		bsr	set_user
		endc

*************************************************************************
* Quit to Desktop or Hard Reset !!
		ifne	quit
		ifne	reset
		move.w	$4.w,a0
		jmp	(a0)
		elseif
		move.l	#$0000004c,-(sp)	;Always QUIT !!
		trap	#1
		endc
		endc


*************************************************************************
* Trap 512K owners when program requires 1 Meg+ to run !!
		ifne	meg_only
half_meg	pea	more_mem(pc)
		move.w	#9,-(sp)
		trap	#1
		addq.l	#6,sp
		move.w	#7,-(sp)
		trap	#1
		addq.l	#2,sp
		move.l	#$0000004c,-(sp)
		trap	#1

more_mem	dc.b	27,"E"
		dc.b	"NOT ENOUGH MEMORY !!",13,10
		dc.b	"--------------------",13,10,10
		dc.b	"You require 1 megabyte or",13,10
		dc.b	"more to run this program !",13,10,10
		dc.b	"Press any key !!",13,10
		dc.b	0
		even
		endc

		ifne	exec
		dc.l	0
null		dc.l	0
execfile	dc.b	'logo.dat',0
		even
execfile2	dc.b	'program.dat',0
		even
		endc

*************************************************************************
* Put ASCII message on screen
		ifne	ascii
fame_message	dc.b	27,'E',27,'f'
		dc.b	27,'Y',32+06,32+14,"Dragon Lore"
		dc.b	27,'Y',32+09,32+11,"Packed & linked by"
		dc.b	27,'Y',32+11,32+03,"MUG U.K(tm) - mikemee@lineone.net"
		dc.b	27,'Y',32+13,32+15,"July '97"
		dc.b	0
		even
		endc

*************************************************************************
* Test for STE by MSD of POV
		ifne	test_ste
STE_test	lea	$ffff8205.w,a5
		move.b	(a5),d0 	;get original value
		move.b	#"M",(a5)	;poke new value
		cmp.b	(a5),d0 	;get value again, is it same?
		beq	.notSTE 	;yes same so not ste
		move.b	d0,(a5) 	;yes so poke original value back
		lea	STE_flag(pc),a6
		move.w	#-1,(a6)	;set flag for STE to -1
.notSTE 	rts
STE_flag	dc.w 0
STE_text	dc.b	27,"E"
		dc.b	"YOU HAVEN'T GOT AN STE !!",13,10
		dc.b	"-------------------------",13,10,10
		dc.b	"You require an Atari STE ",13,10
		dc.b	"to run this program !",13,10,10
		dc.b	"Press any key !!",13,10
		dc.b	0
		even
		endc


********** Supervisor **************************
set_super	clr.l	-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,d7
		rts

********** User ********************************
set_user	move.l	d7,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		rts

*************************************************************************
* New TRAP #1 routine
new_trap1	move.l	a6,-(sp)

		lea	link_code_active(pc),a6
		tst.w	(a6)			;are we doing link
		bne	yeah_jump_to_rom	;no so go directly to ROM

		lea	reg_store(pc),a6
		movem.l d1-a5,(a6)
		move.l	(sp)+,52(a6)

		move.l	sp,a0
		btst	#5,(sp) 	;check for super
		bne.s	.in_super 
		move.l	USP,a0		;get user stack
		subq.l	#6,a0
.in_super	addq.l	#6,a0		;correct for return PC and SR

		lea	variables(pc),a6

		cmp.w	#$3d,(a0)	;file OPEN
		beq	F_OPEN

		cmp.w	#$3f,(a0)	;file READ
		beq.s	F_READ

jump_to_rom	lea	reg_store(pc),a6
		movem.l (a6),d1-a6
go_rom		jmp	0.l		;jump to official ROM entry
OLD_84		EQU	*-4
yeah_jump_to_rom	move.l	(sp)+,a6
			bra.s	go_rom

*************************************************************************
* New 'F_Read' Routine

F_READ		move.l	8(a0),load_address-variables(a6)
		lea	old_ret(pc),a5
		move.l	2(sp),(a5)		;official return PC
		lea	our_return(pc),a5
		move.l	a5,2(sp)		;put in our own return PC for our fiddle

		tst.w	open_done-variables(a6)
		beq.s	go_rom		;skip our F_READ

		move.l	link_bytes_to_load-variables(a6),d7
		move.l	4(a0),d6	;number of bytes to read


		sub.l	d6,d7
		bmi.s	.set_for_link
		sub.l	d6,link_bytes_to_load-variables(a6)
		bra.s	go_rom

.set_for_link	move.l	link_bytes_to_load-variables(a6),4(a0)	;put new bytes to load value on stack
		clr.l	link_bytes_to_load-variables(a6)
		bra.s	go_rom

our_return	tst.w	2(sp)		;was there a load error
		bmi.s	quitter 	;YES
		move.l	load_address(pc),a0
		move.l	a0,a1

		ifne	sen_205
		move.l	sentry_bytes-variables(a6),d0	; Sentry Packer requires length in d0 
		endc

		bsr	depack_routs

quitter 	movem.l reg_store(pc),d1-a6
		jmp	0.l		;official return to calling program
old_ret 	EQU	*-4



*************************************************************************
* New 'F_Open' Routine

F_OPEN		sf	open_done-variables(a6)	;set we have been here
		move.l	2(a0),a1	;filename to open

		move.l	a0,-(sp)
		move.l	a1,a0

******************************************************************
*takes a drive\directory(s)\filename and changes it to
*filename only
*pass 	a0 as start of filespec
*	a1 trashed
*return a0 as start of filename only
******************************************************************
preproc		cmp.b	#":",1(a0)
		bne.s	no_drive	;drive in path?
		addq.l	#2,a0
no_drive	move.l	a0,a1
do_parse	sub.w	#1,d3
		cmp.b	#"\",(a1)+
		bne.s	no_slash
		move.l	a1,a0		;save slash start
no_slash	tst.b	(a1)
		bne.s	do_parse	;until zero found

		move.l	a0,a1
		move.l	(sp)+,a0

;make higher case
		lea	filename_buffer(pc),a4

		move.l	#$20202020,(a4)		;clear old filename
		move.l	#$20202020,4(a4)
		move.l	#$20202020,8(a4)
		move.l	#$20202020,12(a4)
		move.l	#$20202020,16(a4)
		move.l	#$20202020,20(a4)
	
		move.l	a4,a2
		moveq	#0,d0

		moveq	#16-1,d1	;max filename FILENAME.EXT
.get_f_name	move.b	(a1)+,d0	;get a letter from filename
		beq.s	.end_of_name
		cmp.b	#'a',d0
		blt.s	.in_h_case
		andi.w	#$df,d0 	;make text higher case
.in_h_case	move.b	d0,(a2)+	;store letter in our filename buffer
		dbf	d1,.get_f_name
.end_of_name
		clr.b	(a2)	;put 0 at end of filename

; we have now got the filename the program wants to load in
; FILENAME_BUFFER so we want to search our list of filenames to see
; if it is in the LINK file..... 
;
; A1=filename the program wants to OPEN
;
		lea	FILENAMES(pc),a0
		moveq	#-1,d2
.name_search	addq.w	#1,d2
		move.l	a0,d0		;store position in filenames for later...

		move.l	a4,a1

.scan		move.b	(a1)+,d1	;get letter from filename to open
		beq	.found_file_match

		cmp.b	(a0)+,d1	;is this letter the same as our filename list?
		beq	.scan		;YEAH!!!

		move.l	d0,a0		;get present pos in our filename list
		adda.l	#17,a0		;goto next filename in our list
*** 17 bytes is FILENAME.EXT + 0 + offset file no. byte

		cmp.w	#FILES+1,d2	;MAX no. of filenames in link file
		beq	jump_to_rom

		bra	.name_search

.found_file_match
		move.l	d0,a0		;pos in filename list is in D0
		moveq	#0,d1
		move.b	16(a0),d1	;offset number for filename
*** 13 bytes gets offset after FILENAME.EXT

		lea	file_offset_table(pc),a5
		lsl.w	#2,d1		:offset number from filename * 4
		move.l	(a5,d1.w),a1	;offset to our file in LINK
		move.l	4(a5,d1.w),a2	;offset to next file in LINK

;A1=position in LINK where the file to load starts
;A2=position in LINK where next file starts
;
		move.l	a1,seek_offset-variables(a6)
		sub.l	a1,a2
					;  file to load 	(a1)
					; -next file in link	(a2)
					;  -----------------
					;  file to load length	(a2)
					;

					;number of bytes to load in A2
		move.l	a2,link_bytes_to_load-variables(a6)

		ifne	sen_205
		move.l	a2,sentry_bytes-variables(a6)	;for Sentry Packer only
		endc

		st	link_code_active-variables(a6)
		clr.w	-(sp)		;open file for read only
		pea	LINKFILE(pc)
		move.w	#$3d,-(sp)	;FOPEN
		trap	#1
		addq.l	#8,sp
		move.w	d0,d7		;handle of link file
		clr.w	-(sp)		;seek from beginning of file
		move.w	d7,-(sp)	;handle

		move.l	seek_offset-variables(a6),-(sp)	;number of bytes to seek

		ifne	prog_len	; Program length <>0 bytes
		add.l	#prog_len,(sp)
		endc

		move.w	#$42,-(sp)	;FSEEK
		trap	#1
		lea	10(sp),sp
		moveq	#0,d0 
		move.w	d7,d0 
		sf	link_code_active-variables(a6)
		st	open_done-variables(a6)
		movem.l reg_store(pc),d1-a6
		rte






depack_routs	
	ifne	atom_33
	bsr	atom_33_dpak
	endc

	ifne	atom_35
	bsr	atom_35_dpak
	endc

	ifne	ice_240
	bsr	ice	; check for & depack 'ICE2'
	endc

	ifne	fire_201
	bsr	fire	; check for & depack 'FIR2'
	endc

	ifne	sen_205
	bsr	sentry	; Sentry Packer v2.05
	endc

	ifne	speed_2
	bsr	speed_2_dpak	; Speed Packer 2
	endc

	ifne	speed_3
	bsr	speed_3_dpak	; Speed Packer 3
	endc

	rts

;-------------------------------------------------------------------------

	ifne	atom_33
;decrunch source code of ATOMIK v3.3 by ALTAIR	;je tiens a preciser
;A0=packed code 	;que j'ai entierement
;A1=depack adr. 	;ecris ce compacteur
;call it by bsr.		;environnement compris.
			;pic_algo=1 ; lenght=$18e
PIC_ALGO_33:	equ	1	;pic_algo=0 ; lenght=$148

atom_33_dpak	movem.l d0-a6,-(a7)
		cmp.l	#"ATOM",(a0)+
		bne	no_crunched
		move.l	a1,a5
		add.l	(a0)+,a5
		ifne	PIC_ALGO_33
		pea	(a5)
		endc
		move.l	(a0)+,d0	
		lea	0(a0,d0.l),a6
		move.b	-(a6),d7
		bra	make_jnk
tablus	 	lea	tablus_table(pc),a4
		moveq	#1,d6
		bsr.s	get_bit2
		bra.s	tablus2
decrunch	moveq	#6,d6
take_lenght	add.b	d7,d7
		beq.s	.empty1
.cont_copy	dbcc	d6,take_lenght
		bcs.s	.next_cod
		moveq	#6,d5
		sub	d6,d5
		bra.s	.do_copy
.next_cod	moveq	#3,d6
		bsr.s	get_bit2
		beq.s	.next_cod1
		addq	#6,d5
		bra.s	.do_copy
.next_cod1	moveq	#7,d6
		bsr.s	get_bit2
		beq.s	.next_cod2
		add	#15+6,d5
		bra.s	.do_copy
.empty1		move.b	-(a6),d7
		addx.b	d7,d7
		bra.s	.cont_copy
.next_cod2	moveq	#13,d6
		bsr.s	get_bit2
		add	#255+15+6,d5
.do_copy	move	d5,-(a7)
		bne.s	bigger
		lea	decrun_table2(pc),a4
		moveq	#2,d6
		bsr.s	get_bit2
		cmp	#5,d5
		blt.s	contus
		addq	#2,a7
		subq	#6,d5
		bgt.s	tablus
		move.l	a5,a4
		blt.s	.first4
		addq	#4,a4
.first4		moveq	#1,d6
		bsr.s	get_bit2
tablus2		move.b	0(a4,d5.w),-(a5)	
		bra.s	make_jnk
get_bit2	clr	d5
.get_bits	add.b	d7,d7
		beq.s	.empty
.cont		addx	d5,d5
		dbf	d6,.get_bits
		tst	d5
		rts
.empty	 	move.b	-(a6),d7
		addx.b	d7,d7
		bra.s	.cont
bigger 		lea	decrun_table(pc),a4
cont		moveq	#2,d6
		bsr.s	get_bit2
contus 		move	d5,d4
		move.b	14(a4,d4.w),d6
		ext	d6
		bsr.s	get_bit2
		add	d4,d4
		beq.s	.first
		add	-2(a4,d4.w),d5
.first	 	lea	1(a5,d5.w),a4
		move	(a7)+,d5
		move.b	-(a4),-(a5)
.copy_same	move.b	-(a4),-(a5)

		ifne	flash
		not.w	$ffff8240.w
		not.w	$ffff8240.w
		endc

		dbf	d5,.copy_same
make_jnk	moveq	#11,d6
		moveq	#11,d5
take_jnk	add.b	d7,d7
		beq.s	empty
cont_jnk	dbcc	d6,take_jnk
		bcs.s	next_cod
		sub	d6,d5
		bra.s	copy_jnk1
next_cod	moveq	#7,d6
		bsr.s	get_bit2
		beq.s	.next_cod1
		addq	#8,d5
		addq	#3,d5
		bra.s	copy_jnk1
.next_cod1	moveq	#2,d6
		bsr.s	get_bit2
		swap	d5
		moveq	#15,d6
		bsr.s	get_bit2
		addq.l	#8,d5
		addq.l	#3,d5	
copy_jnk1	subq	#1,d5
		bmi.s	.end_word
		moveq	#1,d6
		swap	d6
.copy_jnk	move.b	-(a6),-(a5)
		dbf	d5,.copy_jnk
		sub.l	d6,d5
		bpl.s	.copy_jnk
.end_word	cmp.l	a6,a0
.decrunch	bne	decrunch
		cmp.b	#$80,d7
		bne.s	.decrunch
		ifne	PIC_ALGO_33
		move.l	(a7)+,a0
		bsr.s	decod_picture
		endc
no_crunched	movem.l (a7)+,d0-a6
		rts
empty		move.b	-(a6),d7
		addx.b	d7,d7
		bra.s	cont_jnk
decrun_table	dc.w	32,32+64,32+64+256,32+64+256+512,32+64+256+512+1024
		dc.w	32+64+256+512+1024+2048,32+64+256+512+1024+2048+4096
		dc.b	4,5,7,8,9,10,11,12
decrun_table2	dc.w	32,32+64,32+64+128,32+64+128+256
		dc.w	32+64+128+256+512,32+64+128+256+512*2
		dc.w	32+64+128+256+512*3
		dc.b	4,5,6,7,8,8
tablus_table	dc.b	$60,$20,$10,$8
		ifne	PIC_ALGO_33
decod_picture	move	-(a0),d7
		clr	(a0)
.next_picture	dbf	d7,.decod_algo
		rts
.decod_algo	move.l	-(a0),d0
		clr.l	(a0)
		lea	0(a5,d0.l),a1
		lea	$7d00(a1),a2
.next_planes	moveq	#3,d6
.next_word	move	(a1)+,d0
		moveq	#3,d5
.next_bits	add	d0,d0
		addx	d1,d1
		add	d0,d0
		addx	d2,d2
		add	d0,d0
		addx	d3,d3
		add	d0,d0
		addx	d4,d4
		dbf	d5,.next_bits
		dbf	d6,.next_word
		movem	d1-d4,-8(a1)
		cmp.l	a1,a2
		bne.s	.next_planes
		bra.s	.next_picture
		endc
		endc
;--------------------------------------------------------------------------
	ifne	atom_35
;ATOMIK DECRUNCH SOURCE CODE v3.5 (non optimise, pas le temps. sorry...)

;ce depacker est indissociable du programme ATOMIK V3.5 tous les mecs
;qui garderons se source dans l'espoir de prendre de l'importance
;en se disant moi je l'ai et pas l'autre sont des lamers.

;MODE=1 depack data from a0 to a0 
;MODE=0 depack data from a0 to a1 (RESTORE SPACE a 1 inutile! si MODE=0)

;PIC_ALGO = 0 decrunch file not encoded with special picture algorythm.
;PIC_ALGO = 1 decrunch all files with or without picture algorythm.

;DEC_SPACE = (lesser decrunch space is gived after packing by atomik v3.5)
	     
;RESTORE_SPACE = 1 the allocated decrunch space will be restored .
;RESTORE_SPACE = 0 the allocated decrunch space will not be restored.

;call it by BSR DEPACK or JSR DEPACK but call it!

******** DO NOT ALTER THESE ***************************************
MODE		EQU	1	;a0-a1
PIC_ALGO	EQU	1
DEC_SPACE	EQU	$80	 ;MAX IS $7FFE (no odd value!)
RESTORE_SPACE	EQU	1
*******************************************************************
atom_35_dpak	movem.l d0-a6,-(sp)
		cmp.l	#"ATM5",(a0)+
		bne	not_packed
		link	a2,#-28
		move.l	(a0)+,d0	;get length
		ifne	MODE
		lea	4(a0,d0.l),a5
		move.l	d0,-(a7)
		elseif
		move.l	a1,a5
		add.l	d0,a5
		endc
		move.l	a5,a4
		ifne	MODE
		ifne	DEC_SPACE
		lea	DEC_SPACE(a4),a5
		endc
		endc
		lea	-$c(a4),a4
		move.l	(a0)+,d0
		move.l	a0,a6
		add.l	d0,a6
		ifne	PIC_ALGO
		moveq	#0,d0
		move.b	-(a6),d0
		move	d0,-2(a2)
		ifne	RESTORE_SPACE
		lsl	#2,d0
		sub	d0,a4
		endc
		elseif
		ifne	RESTORE_SPACE
		clr	-2(a2)
		endc
		subq	#1,a6
		endc
		ifne	RESTORE_SPACE
		lea	buff_marg(pc),a3
		move	-2(a2),d0
		lsl	#2,d0
		add	#DEC_SPACE+$C,d0
		bra.s	.save
.save_m 	move.b	(a4)+,(a3)+
		subq	#1,d0
.save		bne.s	.save_m
		movem.l a3-a4,-(a7)
		endc
		ifne	PIC_ALGO
		pea	(a5)
		endc
		move.b	-(a6),d7
		bra	take_type
decrunch35	move	d3,d5
.take_length	add.b	d7,d7
.cont_take	dbcs	d5,.take_length
		beq.s	.empty1
		bcc.s	.next_cod
		sub	d3,d5
		neg	d5
		bra.s	.do_copy1
.next_cod	moveq	#3,d6
		bsr.s	get_bit2_35
		beq.s	.next_cod1
		bra.s	.do_copy
.next_cod1	moveq	#7,d6
		bsr.s	get_bit2_35
		beq.s	.next_cod2
		add	#15,d5
		bra.s	.do_copy
.empty1 	move.b	-(a6),d7
		addx.b	d7,d7
		bra.s	.cont_take
.next_cod2	moveq	#13,d6
		bsr.s	get_bit2_35
		add	#255+15,d5
.do_copy	add	d3,d5
.do_copy1	lea	decrun_table_35(pc),a4
		move	d5,d2
		bne.s	bigger_35
		add.b	d7,d7
		bne.s	.not_empty
		move.b	-(a6),d7
		addx.b	d7,d7
.not_empty	bcs.s	.ho_kesako
		moveq	#1,d6
		bra.s	word
.ho_kesako	moveq	#3,d6
		bsr.s	get_bit2_35
		tst.b	-28(a2)
		beq.s	.ho_kesako1
		move.b	10-28(a2,d5.w),-(a5)
		bra	tst_end
.ho_kesako1	move.b	(a5),d0
		btst	#3,d5
		bne.s	.ho_kesako2
		bra.s	.ho_kesako3
.ho_kesako2	add.b	#$f0,d5
.ho_kesako3	sub.b	d5,d0
		move.b	d0,-(a5)
		bra	tst_end
get_bit2_35	clr	d5
.get_bits	add.b	d7,d7
		beq.s	.empty
.cont		addx	d5,d5

		ifne	flash
		not.w	$ffff8240.w
		not.w	$ffff8240.w
		endc

		dbf	d6,.get_bits
		tst	d5
		rts
.empty		move.b	-(a6),d7
		addx.b	d7,d7
		bra.s	.cont
bigger_35	moveq	#2,d6
word		bsr.s	get_bit2_35
		move	d5,d4
		move.b	14(a4,d4.w),d6
		ext	d6
		tst.b	1-28(a2)
		bne.s	.spe_ofcod1
		addq	#4,d6
		bra.s	.nospe_ofcod1
.spe_ofcod1	bsr.s	get_bit2_35
		move	d5,d1
		lsl	#4,d1
		moveq	#2,d6
		bsr.s	get_bit2_35
		cmp.b	#7,d5
		blt.s	.take_orof
		moveq	#0,d6
		bsr.s	get_bit2_35
		beq.s	.its_little
		moveq	#2,d6
		bsr.s	get_bit2_35
		add	d5,d5
		or	d1,d5
		bra.s	.spe_ofcod2
.its_little	or.b	2-28(a2),d1
		bra.s	.spe_ofcod3
.take_orof	or.b	3-28(a2,d5.w),d1
.spe_ofcod3	move	d1,d5
		bra.s	.spe_ofcod2
.nospe_ofcod1	bsr.s	get_bit2_35
.spe_ofcod2	add	d4,d4
		beq.s	.first
		add	-2(a4,d4.w),d5
.first		lea	1(a5,d5.w),a4
		move.b	-(a4),-(a5)
.copy_same	move.b	-(a4),-(a5)
		dbf	d2,.copy_same
		bra.s	tst_end
make_jnk_35	add.b	d7,d7
		bne.s	.not_empty
		move.b	-(a6),d7
		addx.b	d7,d7
.not_empty	bcs.s	string
		move.b	-(a6),-(a5)
tst_end 	cmp.l	a5,a3
		bne.s	make_jnk_35
		cmp.l	a6,a0
		beq.s	work_done
take_type	moveq	#0,d6
		bsr	get_bit2_35
		beq.s	.nospe_ofcod
		move.b	-(a6),d0
		lea	2-28(a2),a1
		move.b	d0,(a1)+
		moveq	#1,d1
		moveq	#6,d2
.next		cmp.b	d0,d1
		bne.s	.no_off_4b
		addq	#2,d1
.no_off_4b	move.b	d1,(a1)+
		addq	#2,d1
		dbf	d2,.next
		st	1-28(a2)
		bra.s	.spe_ofcod
.nospe_ofcod	sf	1-28(a2)
.spe_ofcod	moveq	#0,d6
		bsr	get_bit2_35
		beq.s	.relatif
		lea	10-28(a2),a1
		moveq	#15,d0
.next_f 	move.b	-(a6),(a1)+
		dbf	d0,.next_f
		st	-28(a2)
		bra.s	.freq
.relatif	sf	-28(a2)
.freq		clr	d3
		move.b	-(a6),d3
		move.b	-(a6),d0
		lsl	#8,d0
		move.b	-(a6),d0
		move.l	a5,a3
		sub	d0,a3
		bra.s	make_jnk_35
string		bra	decrunch35
work_done
	ifne	PIC_ALGO
	move.l	(a7)+,a0
	pea	(a2)
	bsr.s	decod_picture_35
	move.l	(a7)+,a2
	endc
	ifne	RESTORE_SPACE
	movem.l (a7)+,a3-a4
	endc
	ifne	MODE
	move.l	(a7)+,d0
	bsr	copy_decrun
	endc
	ifne	RESTORE_SPACE
	move	-2(a2),d0
	lsl	#2,d0
	add	#DEC_SPACE+$C,d0
	bra.s	.restore
.restore_m	move.b	-(a3),-(a4)
		subq	#1,d0
.restore	bne.s	.restore_m
		endc
		unlk	a2
not_packed	movem.l (sp)+,d0-a6
		rts
decrun_table_35	dc.w	32,32+64,32+64+256,32+64+256+512,32+64+256+512+1024
		dc.w	32+64+256+512+1024+2048,32+64+256+512+1024+2048+4096
		dc.b	0,1,3,4,5,6,7,8
		ifne	PIC_ALGO
decod_picture_35
		move	-2(a2),d7
.next_picture	dbf	d7,.decod_algo
		rts
.decod_algo	move.l	-(a0),d0
		lea	0(a5,d0.l),a1
.no_odd 	lea	$7d00(a1),a2
.next_planes	moveq	#3,d6
.next_word	move	(a1)+,d0
		moveq	#3,d5
.next_bits	add	d0,d0
		addx	d1,d1
		add	d0,d0
		addx	d2,d2
		add	d0,d0
		addx	d3,d3
		add	d0,d0
		addx	d4,d4
		dbf	d5,.next_bits
		dbf	d6,.next_word
		movem	d1-d4,-8(a1)
		cmp.l	a1,a2
		bne.s	.next_planes
		bra.s	.next_picture
		endc
		ifne	MODE
copy_decrun	lsr.l	#4,d0
		lea	-12(a6),a6
.copy_decrun	rept	4
		move.l	(a5)+,(a6)+
		endr
		dbf	d0,.copy_decrun
		rts
		endc
		ifne	RESTORE_SPACE
buff_marg	dcb.b	$90+DEC_SPACE+$C
		endc
		endc


;--------------------------------------------------------------------------
; ICE 2.31 depack
		ifne	ice_240
ice		move.l	#"ICE!",d2
		cmp.l	a0,a1
		bne.s	.depack_a0_a1 
		link	a3,#-120 
		movem.l d0-a6,-(sp)
		lea	120(a0),a4
		move.l	a4,a6

		bsr	.get_info 

		cmp.l	d2,d0		;is this packed data or what?
		bne.s	.not_packed
		bsr	.get_info
		lea	-8(a0,d0.l),a5
		bsr	.get_info
		move.l	d0,(sp)
		add.l	d0,a6
		move.l	a6,a1
		moveq	#119,d0
.save		move.b	-(a1),-(a3)
		dbf	d0,.save

		move.l	a6,a3
		move.b	-(a5),d7
		bsr	.normal_bytes
		move.l	a3,a6
		bsr	.get_1_bit
		bcc.s	.no_picture
		bsr.s	.do_dep
.no_picture
		movem.l (sp),d0-a3
.move		move.b	(a4)+,(a0)+
		subq.l	#1,d0
		bne.s	.move
		moveq	#119,d0
.rest		move.b	-(a3),-(a6)
		dbf	d0,.rest
.not_packed	movem.l (sp)+,d0-a6
		unlk	a3
		rts

;********************************************* unpacking routine of PACK-ICE
; a0 = Pointer to packed data
; a1 = Address to which the data is unpacked
.depack_a0_a1	movem.l d0-a6,-(sp)
		bsr.s	.get_info
		cmp.l	d2,d0		;is it packed?
		bne.s	.not_ice_pack
		bsr.s	.get_info 
		lea.l	-8(a0,d0.l),a5
		bsr.s	.get_info
		move.l	d0,(sp)
		move.l	a1,a4
		move.l	a1,a6
		adda.l	d0,a6
		move.l	a6,a3
		move.b	-(a5),d7
		bsr.s	.normal_bytes
		bsr.s	.get_1_bit
		bcc.s	.not_ice_pack
		bsr.s	.do_dep
.not_ice_pack	movem.l (sp)+,d0-a6
		rts

.do_dep 	move.w	#$f9f,d1
		bsr.s	.get_1_bit
		bcc.s	.ice_0
		moveq	#15,d0
		bsr.s	.get_d0_bits
.ice_0		move.w	d1,d7
.ice_00 	moveq	#3,d6
.ice_01 	move.w	-(a3),d4
		moveq	#3,d5
.ice_02 	add.w	d4,d4
		addx.w	d0,d0
		add.w	d4,d4
		addx.w	d1,d1
		add.w	d4,d4
		addx.w	d2,d2
		add.w	d4,d4
		addx.w	d3,d3
		dbf	d5,.ice_02
		dbf	d6,.ice_01

		movem.w d0-d3,(a3)
		dbf	d7,.ice_00

.get_info	moveq	#3,d1
.get_bytes	lsl.l	#8,d0
		move.b	(a0)+,d0
		dbf	d1,.get_bytes
		rts
 
.normal_bytes	bsr.s	.get_1_bit
		bcc.s	.test_if_end
		moveq	#0,d1
		bsr.s	.get_1_bit
		bcc.s	.copy_direkt
		lea	.direkt_tab(pc),a1
		moveq	#4,d3
.next_gb	move.l	-(a1),d0
		bsr.s	.get_d0_bits
		swap	d0
		cmp.w	d0,d1
		dbne	d3,.next_gb
		add.l	20(a1),d1
.copy_direkt	move.b	-(a5),-(a6)

		ifne	flash
		not.w	$ffff8240.w
		not.w	$ffff8240.w
		endc

		dbf	d1,.copy_direkt
.test_if_end	cmp.l	a4,a6
		bgt.s	.strings
		rts
.get_1_bit	add.b	d7,d7
		bne.s	.bit_found
		move.b	-(a5),d7
		addx.b	d7,d7
.bit_found	rts 

.get_d0_bits	moveq	#0,d1
.hole_bit_loop	add.b	d7,d7
		bne.s	.on_d0
		move.b	-(a5),d7
		addx.b	d7,d7
.on_d0		addx.w	d1,d1
		dbf	d0,.hole_bit_loop
		rts

.strings	lea	.length_tab(pc),a1
		moveq.l #3,d2
.get_length_bit bsr.s	.get_1_bit
		dbcc	d2,.get_length_bit
		moveq.l #0,d4
		moveq.l #0,d1
		move.b	1(a1,d2.w),d0
		ext.w	d0
		bmi.s	.no_len
		bsr.s	.get_d0_bits
.no_len 	move.b	6(a1,d2.w),d4
		add.w	d1,d4
		beq.s	.get_offset_2
		lea	.more_offset(pc),a1
		moveq.l #1,d2
.get_offs	bsr.s	.get_1_bit
		dbcc	d2,.get_offs
		moveq.l #0,d1
		move.b	1(a1,d2.w),d0
		ext.w	d0
		bsr.s	.get_d0_bits
		add.w	d2,d2
		add.w	6(a1,d2.w),d1
		bpl.s	.depack_bytes
		sub.w	d4,d1
		bra.s	.depack_bytes

.get_offset_2	moveq.l #0,d1
		moveq.l #5,d0
		moveq.l #-1,d2
		bsr.s	.get_1_bit
		bcc.s	.less_40
		moveq.l #8,d0
		moveq.l #$3f,d2
.less_40	bsr.s	.get_d0_bits
		add.w	d2,d1

.depack_bytes	lea.l	2(a6,d4.w),a1
		adda.w	d1,a1
		move.b	-(a1),-(a6)
.dep_b		move.b	-(a1),-(a6)
		dbf	d4,.dep_b
		bra	.normal_bytes


		dc.w	$7FFF,$000E,$00FF,$0007
		dc.w	$0007,$0002,$0003,$0001
		dc.w	$0003,$0001
.direkt_tab	dc.w	$0000,$010D,$0000,$000E
		dc.w	$0000,$0007,$0000,$0004
		dc.w	$0000,$0001

.length_tab	dc.w	$0901,$00FF,$FF08,$0402,$0100

.more_offset	dc.w	$0B04,$0700,$011F,$FFFF,$001F


	endc
	even

;----------------------------------------------------------------------------
; Fire Depacker ('FIRE' header)
;

	ifne	fire_201
fire		move.l	#"FIRE",d2	;depack a0 to a0
		cmp.l	a0,a1
		bne.s	.fire_a0a1

		link	a3,#-120
		movem.l	d0-a6,-(sp)
		lea	120(a0),a4
		move.l	a4,a6
		bsr	.getinfo
		cmp.l	d2,d0		;compare FIRE header
		bne.s	.not_packeda0a0
		bsr	.getinfo
		lea	-8(a0,d0.l),a5	; a5 = Ende der gepackten Daten
		bsr	.getinfo
		move.l	d0,(sp) 	; OriginallÑnge: spÑter nach d0
		adda.l	d0,a6		; a6 = Ende entpackte Daten
		move.l	a6,a1
		moveq	#119,d0 	; 120 Bytes hinter entpackten Daten
.save		move.b	-(a1),-(a3)
		dbf	d0,.save
		move.l	a6,a3		; merken fÅr spÑter

		bsr.s	.get_fire_info
		movem.l (sp),d0-a2/a5
.move		move.b	(a4)+,(a0)+
		subq.l	#1,d0
		bne.s	.move
		moveq	#119,d0 	; um Åberschriebenen Bereich
.rest		move.b	-(a5),-(a3)	; wieder herzustellen
		dbf	d0,.rest
.not_packeda0a0	movem.l (sp)+,d0-a6
		unlk	a3
		rts

.fire_a0a1	movem.l	d0-a6,-(sp)	;depack a0 to a1
		bsr.s	.getinfo
		cmp.l	d2,d0		;is FIRE?
		bne.s	.not_packeda0a1
		bsr.s	.getinfo
		lea	-8(a0,d0.l),a5
		bsr.s	.getinfo
		move.l	d0,(sp)
		move.l	a1,a4
		move.l	a1,a6
		add.l	d0,a6
		bsr.s	.get_fire_info
.not_packeda0a1	movem.l	(sp)+,d0-a6
		rts

.get_fire_info	move.b	-(a5),d7	; erstes Informationsbyte
		lea	.tabellen(pc),a2	; a2 = Zeiger auf Datenbereich
		moveq	#1,d6
		swap	d6		; d6 = $10000
		moveq	#0,d5		; d5 = 0 (oberes Wort: immer 0!)

.normal_bytes	bsr.s	.get_1_bit
		bcc.s	.test_if_end	; Bit %0: keine Daten
		moveq	#0,d1		; falls zu .copy_direkt
		bsr.s	.get_1_bit
		bcc.s	.copy_direkt	 ; Bitfolge: %10: 1 Byte direkt kop.
		move.l	a2,a0
		moveq	#3,d3
.nextgb 	move.l	-(a0),d0		; d0.w Bytes lesen
		bsr.s	.get_d0_bits
		swap	d0
		cmp.w	d0,d1		; alle gelesenen Bits gesetzt?
		dbne	d3,.nextgb	; ja: dann weiter Bits lesen
.no_more	add.l	16(a0),d1	; Anzahl der zu Åbertragenen Bytes
.copy_direkt	move.b	-(a5),-(a6)	; Daten direkt kopieren
		dbf	d1,.copy_direkt ; noch ein Byte
.test_if_end	cmp.l	a4,a6		; Fertig?
		bgt.s	.strings	; Weiter wenn Ende nicht erreicht
		rts

.getinfo	moveq	#3,d1
.glw		rol.l	#8,d0
		move.b	(a0)+,d0
		dbf	d1,.glw
		rts

.get_1_bit	add.b	d7,d7		; hole ein Bit
		beq.s	.no_bit_found
		rts
.no_bit_found	move.b	-(a5),d7
		addx.b	d7,d7
		rts

.get_d0_bits	moveq	#0,d1
.hole_bit_loop	add.b	d7,d7
		beq.s	.not_found	; quellfeld leer
.on_d0		addx.w	d1,d1		; und Åbernimm es
		dbf	d0,.hole_bit_loop	; bis alle Bits geholt wurden
		rts

.not_found	move.b	-(a5),d7	; hole sonst ein weiters longword
		addx.b	d7,d7		; hole ein Bit
		bra.s	.on_d0

.strings	moveq	#1,d0		; 2 Bits lesen
		bsr.s	.get_d0_bits
		subq.w	#1,d1
		bmi.s	.gleich_morestring	; %00
		beq.s	.length_2	; %01
		subq.w	#1,d1
		beq.s	.length_3	; %10
		bsr.s	.get_1_bit
		bcc.s	.bitset 	; %110
		bsr.s	.get_1_bit
		bcc.s	.length_4	; %1110
		bra.s	.length_5	; %1111
.get_short_offset
		moveq	#1,d0
		bsr.s	.get_d0_bits	; d1:  0,  1,  2,  3
		subq.w	#1,d1
		bpl.s	.contoffs
		moveq	#0,d0		; Sonderfall
		rts
.get_long_offset
		moveq	#1,d0		; 2 Bits lesen
		bsr.s	.get_d0_bits
.contoffs	add.w	d1,d1		; d1:  0,  2,  4,  6
		add.w	d1,d1		; d1:  0,  4,  8, 12
		movem.w .offset_table-.tabellen(a2,d1),d0/d5
		bsr.s	.get_d0_bits
		add.l	d5,d1
		rts
.gleich_morestring		; %00
		moveq	#1,d0		; 2 Bits lesen
		bsr.s	.get_d0_bits
		subq.w	#1,d1
		bmi.s	.gleich_string	; %0000
		add.w	d1,d1		; d1:	 0,  2,  4
		add.w	d1,d1		; d1:	 0,  4,  8
		movem.w .more_table-.tabellen(a2,d1),d0/d2
		bsr.s	.get_d0_bits
		add.w	d1,d2		; d2 = StringlÑnge
		bsr.s	.get_long_offset
		move.w	d2,d0		; d0 = StringlÑnge
		bra.s	.copy_longstring

.bitset 	moveq	#2,d0		; %110
		bsr.s	.get_d0_bits
		moveq	#0,d0
		bset	d1,d0
		bra.s	.put_d0
.length_2	moveq	#7,d0		; %01
		bsr.s	.get_d0_bits
		moveq	#2-2,d0
		bra.s	.copy_string
.length_3	bsr.s	.get_short_offset	; %10
		tst.w	d0
		beq	.put_d0 	; 0 ablegen
		moveq	#3-2,d0
		bra.s	.copy_string
.length_4	bsr.s	.get_short_offset	; %1110
		tst.w	d0
		beq.s	.vorgÑnger_kopieren
		moveq	#4-2,d0
		bra.s	.copy_string
.length_5	bsr.s	.get_short_offset	; %1111
		tst.w	d0
		beq.s	.put_ff
		moveq	#5-2,d0
		bra.s	.copy_string
.put_ff 	moveq	#-1,d0
		bra.s	.put_d0

.vorgÑnger_kopieren
		move.b	(a6),d0
.put_d0 	move.b	d0,-(a6)
		bra.s	.backmain

.gleich_string	bsr.s	.get_long_offset	; Anzahl gleicher Bytes lesen
		beq.s	.backmain	; 0: zurÅck
		move.b	(a6),d0
.copy_gl	move.b d0,-(a6)
		dbf	d1,.copy_gl
		sub.l	d6,d1
		bmi.s	.backmain
		bra.s	.copy_gl

.copy_longstring	subq.w	#2,d0	; StringlÑnge - 2 (wegen dbf)

.copy_string			; d1 = Offset, d0 = Anzahl Bytes -2
		lea.l	2(a6,d1.l),a0	; Hier stehen die Originaldaten
		add.w	d0,a0		; dazu die StringlÑnge-2
		move.b	-(a0),-(a6)	; ein Byte auf jeden Fall kopieren
.dep_b		move.b	-(a0),-(a6)	; mehr Bytes kopieren

		ifne	flash
		not.w	$ffff8240.w
		not.w	$ffff8240.w
		endc

		dbf	d0,.dep_b	; und noch ein Mal
.backmain bra	.normal_bytes	; Jetzt kommen wieder normale Bytes


.direkt_tab
		dc.l	$03ff0009,$00070002,$00030001,$00030001 ; Anzahl 1-Bits

.tabellen	dc.l	    15-1,      8-1,	 5-1,	   2-1	; Anz. Bytes

.offset_table
		dc.w	 3,	      0
		dc.w	 7,	   16+0
		dc.w	11,	 256+16+0
		dc.w	15, 4096+256+16+0
.more_table	dc.w	3,	 5
		dc.w	5,    16+5
		dc.w	7, 64+16+5

	endc


;----------------------------------------------------------------------------
***************************************
* Sentry Packer v2.01 Data Decruncher *
* Coded by Eagle. (20 Jan 1992)       *
* Source a0, d0: length packed data   *
* OUT: D0=depacked length	      *
***************************************
; PC relative by MSD/POV/BBB Dev.
;
; ***** WARNING *****
;
; While testing the link filer I found a bug in a version of the packer PRG.
; To ensure your pack is bug free ONLY use the PRG that is 6856 bytes long.
; The bug appears on other versions when using the picture extension algorithm
; it says all is well but it corrupts your pictures so they don't unpack
; correctly. The bug was confirmed by Eagle of Sentry on 25/3/93. If you
; have a version which is not 6856 bytes in size and wish the unbugged
; version please send a blank disc and return postage to me and I will
; send you copy.(MSD)
;
	ifne	sen_205
sentry	lea	(a1),a3
	lea	(a0,d0.l),a0
	tst.b	-1(a0)
	bne.s	.cont1
	subq.l	#1,a0
.cont1	moveq	#8,d6
	bsr	get_long1
	cmpi.l	#'2tnS',d0	; Snt2
	beq.s	.unpack
	rts
.unpack bsr	get_long1
	lea	(a3,d0.l),a2	; dest adres
	move.l	d0,-(sp)
	move.l	a2,a5		; save for picture depack
	bsr	get_long1
	moveq	#0,d1
	bsr	.getbyte
	move.l	a6,-(sp)
	lea	unp_pic(pc),a6
	move.w	d2,(a6)
	moveq	#0,d1
	bsr	.getbyte
	move.w	d2,unp_sam-unp_pic(a6)
	move.l	(sp)+,a6
	bne.s	.no_sam
	move.l	d0,-(sp)
	bsr	get_long1
	move.l	a6,-(sp)
	lea	samoff1(pc),a6
	move.l	d0,4(a6)
	bsr	get_long1
	move.l	d0,(a6)
	move.l	(sp)+,a6
	move.l	(sp)+,d0
.no_sam bsr.s	.unp_loop	; unpack data
	move.l	a6,-(sp)
	lea	unp_pic(pc),a6
	tst.w	(a6)
	bne.s	.no_pic
	bsr	unp_picture
.no_pic	tst	unp_sam-unp_pic(a6)
	bne.s	.no_mod
	bsr	samples
.no_mod	move.l	(sp)+,a6
	move.l	(sp)+,d0
	rts

.unp_loop
	bsr.s	.getbit
.cont	bcs.s	.blocks
	bsr.s	.getbit
	bcs.s	.copy_2
	move.b	-(a0),-(a2)	; 1 byte copy
	bra	.l_col
.copy_2 bsr.s	.getbit
	bcs.s	.c_more
	moveq	#1,d2		; copy 2 bytes
	bra.s	.copy
.c_more lea	copy_tab1(pc),a4
.c_loop move.l	(a4)+,d1
	bsr.s	.getbyte		; haal aantal
	subq.w	#1,d2
	bpl.s	.found
	bra.s	.c_loop
.found	swap	d1
	add.w	d1,d2

.copy	move.b	-(a0),-(a2)
	
	ifne	flash
	move.b	(a2),$ffff8240.w
	endc

	dbf	d2,.copy
	bra	.l_col

.get_off
	MOVEQ	#1,D1		;OFFSET
	BSR.S	.getbyte
	move.b	(a4,d2),d1	; bits
	ADD.W	D2,D2
	ext.w	d1
	move.w	4(a4,d2),d4
	bsr.s	.getbyte
	add.w	d4,d2
	rts
.getbit add.l	d0,d0	;LSR.L	#1,D0
	beq.s	.haha
	rts
.haha	bsr.s	get_long1
	addx.l	d0,d0	;ROXR.L  #1,D0
	rts
.haha1	bsr.s	get_long1
	addx.l	d0,d0	;ROXR.L  #1,D0
	bra.s	.getbyt
.getbyte
	CLR.W	D2
.loop	add.l	d0,d0	;LSR.L	#1,D0
	beq.s	.haha1
.getbyt addx.L	d2,D2 
	DBF	D1,.loop
	RTS

.blocks bsr.s	.getbit
	bcs.s	.string3
	moveq	#1,d3		; 2 bytes-string
	moveq	#8-1,d1 ; small-bits-offset
	bra.s	.string_copy
.string3
	lea	small_offset1(pc),a4
	bsr.s	.getbit
	bcs.s	.string_more
	moveq	#2,d3		; 3 bytes-string
	bra.s	.do_strings
.string_more
	moveq	#1,d1		; 2 bits-commando
	bsr.s	.getbyte
	subq.w	#1,d2		; large string?
	bmi.s	.large
	moveq	#3,d3		; minimaal 4 bytes-string
	add.w	d2,d3		; meer?
	bra.s	.do_strings
.large	lea	aantal_tab1(pc),a4
	bsr.s	.get_off
	move.w	d2,d3
	lea	offset_tab1(pc),a4
.do_strings
	bsr.s	.get_off
	bra.s	.s_copy
.string_copy
	bsr.s	.getbyte
.s_copy move.b	-1(a2,d2.w),-(a2) 
	dbf	d3,.s_copy

.l_col	cmpa.l	a2,a3 
	blt	.unp_loop
	RTS
get_long1
	move.b	-(a0),d0
	lsl.l	d6,d0
	move.b	-(a0),d0
	lsl.l	d6,d0
	move.b	-(a0),d0
	lsl.l	d6,d0
	move.b	-(a0),d0
	move.w	#$10,ccr
	rts
samples lea	samoff1(pc),a1
	move.l	a3,a0		; source adres
	add.l	(a1)+,a0
	move.l	(a1),d0
	lea	(a0,d0.l),a2
.loop	move.b	(a0)+,d0
	sub.b	d0,(a0)
	neg.b	(a0)
	cmp.l	a2,a0
	blt.s	.loop
	rts
unp_picture
.low	move.w	#$0f9f,d7
snt2_01 moveq	#3,d6
snt2_02 move.w	-(a5),d4
	moveq	#3,d5
snt2_03 add.w	d4,d4
	addx.w	d0,d0
	add.w	d4,d4
	addx.w	d1,d1
	add.w	d4,d4
	addx.w	d2,d2
	add.w	d4,d4
	addx.w	d3,d3
	dbra	d5,snt2_03
	dbra	d6,snt2_02
	movem.w d0-d3,(a5)
	dbra	d7,snt2_01
	rts
samoff1 dc.l	0,0
unp_pic dc.w	0
unp_sam dc.w	0
offset_tab1
	dc.b	5-1,8-1,9-1,13-1
	dc.w	1,1+32,1+32+256,1+32+256+512
aantal_tab1
	dc.b	2-1,3-1,5-1,9-1
	dc.w	6,6+4,6+4+8,6+4+8+32
small_offset1
	dc.b	4-1,5-1,7-1,9-1
	dc.w	1,1+16,1+16+32,1+16+32+128
copy_tab1
	dc.w	2,1
	dc.w	5,2
	dc.w	12,3
	dc.w	27,4
	
	endc

*** SPEEDPACKER II DEPACK

	ifne	speed_2

* UNPACK source SPACKER 2.0/FIREHAWKS	* SUPERVISER Mode (Flash)
* ---------------------------------------------------------------
* In	a0: ^ source buffer
* Out	d0: original length or 0 if not SP20 packed
* ===============================================================

speed_2_dpak:
	movem.l	d1-a6,-(sp)
	clr.l	-(sp)
	cmp.l	#'SP20',(a0)+
	bne.s	sp2_05
	tst.w	(a0)
	bne.s	sp2_05
	move.l	a0,a5
	move.l	(a0)+,d5
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	d1,(sp)
	tst.w	d5
	beq.s	sp2_01
	swap	d5
	btst	#1,$FFFF8260.W
	bne.s	sp2_01
	lea	$FFFF8240.W,a5
	move.w	(a5),d5
	swap	d5
sp2_01:	lea	64(a0),a1
	move.l	a1,a2
	add.l	d0,a0
	add.l	d1,a1
	move.l	a1,a3
	move.l	sp,a6
	moveq	#79,d0
sp2_02:	move.b	-(a3),-(a6)
	dbf	d0,sp2_02
	exg.l	a6,sp
	bsr.s	sp2_06
	lea	-80(a1),a3
	move.l	(a6),d0
sp2_03:	move.b	(a1)+,(a3)+
	subq.l	#1,d0
	bne.s	sp2_03
	exg.l	a6,sp
	moveq	#79,d0
sp2_04:	move.b	(a6)+,(a3)+
	dbf	d0,sp2_04
sp2_05:	movem.l	(sp)+,d0-a6
	rts	
sp2_06:	moveq	#0,d6
	moveq	#1,d7
	lea	sp2_38(pc),a3
	jsr	(a3)
	roxr.l	d7,d0
sp2_07:	add.l	d0,d0
	bne.s	sp2_08
	jsr	(a3)
sp2_08:	bcs.s	sp2_24
	move.b	-(a0),d1
	bra.s	sp2_13
sp2_09:	moveq	#2,d2
	bsr.s	sp2_16
	move.l	d6,d1
	bset	d2,d1
	bra.s	sp2_13
sp2_10:	add.l	d0,d0
	bne.s	sp2_11
	jsr	(a3)
sp2_11:	bcs	sp2_33
	moveq	#3,d2
	bsr.s	sp2_16
	add.w	d7,d2
	lsr.w	d7,d2
	bcc.s	sp2_12
	not.w	d2
sp2_12:	move.b	(a1),d1
	add.w	d2,d1
sp2_13:	move.b	d1,-(a1)
	clr.w	(a5)
sp2_14: cmp.l	a1,a2
	bne.s	sp2_07
	swap	d5
	move.w	d5,(a5)
	rts
sp2_15:	move.l	d7,d2
sp2_16:	move.l	d6,d1
sp2_17:	add.l	d0,d0
	bne.s	sp2_18
	jsr	(a3)
sp2_18:	addx	d1,d1

	ifne	flash		;flash
	not.w	$ffff8240.w
	not.w	$ffff8240.w
	endc

	dbf	d2,sp2_17
sp2_19:	move.l	d1,d2
	rts
sp2_20:	bsr.s	sp2_15
sp2_21:	beq.s	sp2_22
	move.b	-(a0),d1
	subq.w	#2,d2
	bcs.s	sp2_19
sp2_22:	add.w	d7,d2
	add.w	d2,d2
sp2_23:	add.w	d2,d2
	sub.w	d7,d2
	bra.s	sp2_17
sp2_24:	add.l	d0,d0
	bne.s	sp2_25
	jsr	(a3)
sp2_25:	bcs.s	sp2_27
	add.l	d0,d0
	bne.s	sp2_26
	jsr	(a3)
sp2_26:	bcs.s	sp2_10
	move.l	d6,d1
	move.b	-(a0),d1
	moveq	#0,d3
	bra.s	sp2_36
sp2_27:	add.l	d0,d0
	bne.s	sp2_28
	jsr	(a3)
sp2_28:	bcs.s	sp2_29
	bsr.s	sp2_15
	beq.s	sp2_13
	moveq	#1,d3
	bra.s	sp2_35
sp2_29:	add.l	d0,d0
	bne.s	sp2_30
	jsr	(a3)
sp2_30:	bcs	sp2_09
	add.l	d0,d0
	bne.s	sp2_31
	jsr	(a3)
sp2_31:	bcs.s	sp2_32
	bsr.s	sp2_15
	beq.s	sp2_12
	moveq	#2,d3
	bra.s	sp2_35
sp2_32:	moveq	#3,d3
	bsr.s	sp2_20
	bra.s	sp2_36
sp2_33:	bsr.s	sp2_15
	beq.s	sp2_34
	move.l	d6,d1
	add.w	d7,d2
	bsr.s	sp2_23
	move.l	d2,d3
	bsr.s	sp2_20
	bra.s	sp2_36
sp2_34:	bsr.s	sp2_20
	not.l	d1
	move.l	d2,d3
	bra.s	sp2_36
sp2_35:	move.l	d6,d1
	sub.w	d7,d2
	bsr.s	sp2_21
sp2_36:	move.l	a1,a4
	addq.l	#2,a4
	add.l	d1,a4
	add.l	d3,a4
	move.b	-(a4),-(a1)
sp2_37:	move.b	-(a4),-(a1)
	dbf	d3,sp2_37
	move.w	d5,(a5)
	bra	sp2_14
sp2_38:	move.w	a0,d4
	btst	d6,d4
	bne.s	sp2_39
	move.l	-(a0),d0
	addx.l	d0,d0
	rts
sp2_39:	move.l	-5(a0),d0
	lsl.l	#8,d0
	move.b	-(a0),d0
	subq.l	#3,a0
	add.l	d0,d0
	bset	d6,d0
	rts

	endc

;----------------------------------------------------------------------------
* UNPACK source for SPACKERv3	(C)THE FIREHAWKS'92
* -------------------------------------------------
* in	a0: even address start packed block
* out	d0: original length or 0 if not SPv3 packed
* =================================================
* Use AUTO_SP3.PRG for multiblk packed files

	ifne	speed_3
speed_3_dpak:
	moveq	#0,d0
	movem.l	d0-a6,-(sp)
	lea	sp3_53(pc),a6
	movea.l	a0,a1
	cmpi.l	#'SPv3',(a1)+
	bne.s	sp3_02
	tst.w	(a1)
	bne.s	sp3_02
	move.l	(a1)+,d5
	move.l	(a1)+,d0
	move.l	(a1)+,(sp)
	movea.l	a0,a2
	adda.l	d0,a0
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	adda.l	(sp),a1
	lea	sp3_58-sp3_53(a6),a3
	moveq	#128-1,d0
sp3_01:	move.l	(a2)+,(a3)+
	dbf	d0,sp3_01
	suba.l	a2,a3
	move.l	a3,-(sp)
	bsr.s	sp3_03
	bsr	sp3_21
	move.b	-(a0),d0
	adda.l	(sp)+,a0
	move.b	d0,(a0)+
	lea	sp3_58-sp3_53(a6),a2
	bsr	sp3_22
	bsr	sp3_15
sp3_02:	movem.l	(sp)+,d0-a6
	rts
sp3_03:	move.w	SR,d1
	andi.w	#$2000,d1
	beq.s	sp3_04
	move.w	$FFFF8240.W,2(a6)
	btst	#1,$FFFF8260.W
	bne.s	sp3_04
	swap	d5
sp3_04:	clr.w	d5
	move.w	-(a0),d6
	lea	sp3_54-sp3_53(a6),a3
	move.b	d6,(a3)+
	moveq	#1,d3
	moveq	#6,d4
sp3_05:	cmp.b	d6,d3
	bne.s	sp3_06
	addq.w	#2,d3
sp3_06:	move.b	d3,(a3)+
	addq.w	#2,d3
	dbf	d4,sp3_05
	moveq	#$10,d4
	move.b	-(a0),(a3)+
	move.b	d4,(a3)+
	move.b	-(a0),(a3)+
	move.b	d4,(a3)+
	move.b	-(a0),d4
	move.w	d4,(a6)
	lea	sp3_57-sp3_53(a6),a5
	move.b	-(a0),d4
	lea	1(a5,d4.w),a3
sp3_07:	move.b	-(a0),-(a3)
	dbf	d4,sp3_07
	move.b	-(a0),-(a3)
	beq.s	sp3_08
	suba.w	d4,a0
sp3_08:	moveq	#0,d2
	move.b	-(a0),d2
	move.w	d2,d3
	move.b	-(a0),d7
sp3_09:	bsr.s	sp3_10
	bsr.s	sp3_10
	dbf	d2,sp3_09
	rts
sp3_10:	not.w	d4
	add.b	d7,d7
	bne.s	sp3_11
	move.b	-(a0),d7
	addx.b	d7,d7
sp3_11:	bcs.s	sp3_12
	move.w	d2,d0
	subq.w	#1,d3
	sub.w	d3,d0
	add.w	d0,d0
	add.w	d4,d0
	add.w	d0,d0
	neg.w	d0
	move.w	d0,-(a3)
	rts
sp3_12:	moveq	#2,d1
	bsr	sp3_44
	add.w	d0,d0
	beq.s	sp3_13
	move.b	d0,-(a3)
	moveq	#2,d1
	bsr	sp3_44
	add.w	d0,d0
	move.b	d0,-(a3)
	rts
sp3_13:	moveq	#2,d1
	bsr	sp3_44
	move.w	sp3_55-sp3_53(a6),d1
	add.w	d0,d0
	beq.s	sp3_14
	move.w	sp3_55+2-sp3_53(a6),d1
sp3_14:	or.w	d1,d0
	move.w	d0,-(a3)
	rts
sp3_15:	move.w	SR,d1
	andi.w	#$2000,d1
	beq.s	sp3_16
	move.w	2(a6),$FFFF8240.W
sp3_16:	tst.w	d6
	bpl.s	sp3_20
	movea.l	a1,a2
	movea.l	a1,a3
	adda.l	4(sp),a3
sp3_17:	moveq	#3,d6
sp3_18:	move.w	(a2)+,d0
	moveq	#3,d5
sp3_19:	add.w	d0,d0
	addx.w	d1,d1
	add.w	d0,d0
	addx.w	d2,d2
	add.w	d0,d0
	addx.w	d3,d3
	add.w	d0,d0
	addx.w	d4,d4
	dbf	d5,sp3_19
	dbf	d6,sp3_18
	cmpa.l	a2,a3
	blt.s	sp3_20
	movem.w	d1-d4,-8(a2)
	cmpa.l	a2,a3
	bne.s	sp3_17
sp3_20:	rts
sp3_21:	move.b	-(a0),-(a1)
sp3_22:	swap	d5
	beq.s	sp3_23
	move.w	d5,$FFFF8240.W
sp3_23:	lea	sp3_56+2-sp3_53(a6),a3
	cmpa.l	a0,a2
	blt.s	sp3_25
	rts
sp3_24:	adda.w	d3,a3
sp3_25:	add.b	d7,d7
	bcc.s	sp3_28
	beq.s	sp3_27
sp3_26:	move.w	(a3),d3
	bmi.s	sp3_24
	bra.s	sp3_29
sp3_27:	move.b	-(a0),d7
	addx.b	d7,d7
	bcs.s	sp3_26
sp3_28:	move.w	-(a3),d3
	bmi.s	sp3_24
sp3_29:	ext.w	d3
	jmp	sp3_30(pc,d3.w)
sp3_30:	bra.s	sp3_30
	bra.s	sp3_41
	bra.s	sp3_41
	bra.s	sp3_41
	bra.s	sp3_41
	bra.s	sp3_41
	bra.s	sp3_37
	bra.s	sp3_36
	bra.s	sp3_32
	bra.s	sp3_33
	bra.s	sp3_31
	bra.s	sp3_34
	bra.s	sp3_21
sp3_31:	move.b	(a5),-(a1)
	bra.s	sp3_22
sp3_32:	bsr.s	sp3_43
	move.b	1(a5,d0.w),-(a1)
	bra.s	sp3_22
sp3_33:	bsr.s	sp3_43
	add.w	(a6),d0
	move.b	1(a5,d0.w),-(a1)
	bra.s	sp3_22
sp3_34:	moveq	#3,d1
	bsr.s	sp3_44
	lsr.w	#1,d0
	bcc.s	sp3_35
	not.w	d0
sp3_35:	move.b	(a1),d1
	add.w	d0,d1
	move.b	d1,-(a1)
	bra.s	sp3_22
sp3_36:	lea	sp3_52-2-sp3_53(a6),a4
	bsr.s	sp3_48
	addi.w	#16,d0
	lea	1(a1,d0.w),a3
	move.b	-(a3),-(a1)
	move.b	-(a3),-(a1)
	bra	sp3_22
sp3_37:	moveq	#3,d1
	bsr.s	sp3_44
	tst.w	d0
	beq.s	sp3_38
	addq.w	#5,d0
	bra.s	sp3_40
sp3_38:	move.b	-(a0),d0
	beq.s	sp3_39
	addi.w	#20,d0
	bra.s	sp3_40
sp3_39:	moveq	#13,d1
	bsr.s	sp3_44
	addi.w	#276,d0
sp3_40:	move.w	d0,d3
	add.w	d3,d3
sp3_41:	lea	sp3_52-sp3_53(a6),a4
	bsr.s	sp3_48
	lsr.w	#1,d3
	lea	1(a1,d0.w),a3
	move.b	-(a3),-(a1)
sp3_42:	move.b	-(a3),-(a1)
	dbf	d3,sp3_42
	bra	sp3_22
sp3_43:	moveq	#0,d1
	move.b	(a3),d1
sp3_44:	moveq	#0,d0
	cmpi.w	#7,d1
	bpl.s	sp3_47
sp3_45:	add.b	d7,d7
	beq.s	sp3_46
	addx.w	d0,d0
	dbf	d1,sp3_45
	rts
sp3_46:	move.b	-(a0),d7
	addx.b	d7,d7
	addx.w	d0,d0
	dbf	d1,sp3_45
	rts
sp3_47:	move.b	-(a0),d0
	subq.w	#8,d1
	bpl.s	sp3_45
	rts
sp3_48:	moveq	#0,d1
	move.b	(a3),d1
	adda.w	d1,a4
	move.w	(a4),d1
	bsr.s	sp3_44
	tst.b	d6
	beq.s	sp3_51
	move.w	d0,d4
	andi.w	#$FFF0,d4
	andi.w	#$000F,d0
	beq.s	sp3_50
	lsr.w	#1,d0
	beq.s	sp3_49
	roxr.b	#1,d7
	bcc.s	sp3_50
	move.b	d7,(a0)+
	moveq	#-128,d7
	bra.s	sp3_50
sp3_49:	moveq	#2,d1
	bsr.s	sp3_44
	add.w	d0,d0
	or.w	d4,d0
	bra.s	sp3_51
sp3_50:	lea	sp3_54-sp3_53(a6),a3
	or.b	(a3,d0.w),d4
	move.w	d4,d0
sp3_51:	add.w	18(a4),d0
	rts

	DC.W	3
sp3_52:	DC.W	4,5,7,8,9,10,11,12
	DC.W	-16
	DC.W	0,32,96,352,864,1888,3936,8032

sp3_53:	DS.L	1
sp3_54:	DS.B	8
sp3_55:	DS.W	2*64
sp3_56:	DS.W	2
	DS.B	1
sp3_57:	DS.B	1
	DS.B	2*64
sp3_58:	DS.B	512
	
	endc
;----------------------------------------------------------------------------

LINKFILE	dc.b	  'draglore.lnk',0
	even

; File Offset List
;
; The last longword is the length of the link file (all the files added together)
; All other longwords are the offsets into the linkfile where to
; find the start of the appropriate file.
;
; Use 'MAKELINK' by MUG U.Kø to generate your linkfile and the
; listings below.
;
; INCLUDE OUTPUT FROM MAKELINK.PRG HERE
file_offset_table
;

	dc.l	0
	dc.l	16088
	dc.l	62016
	dc.l	62048
	dc.l	75706
	dc.l	75738
	dc.l	89976
	dc.l	90008
	dc.l	102440
	dc.l	102472
	dc.l	114578
	dc.l	114610
	dc.l	122454
	dc.l	122486
	dc.l	123672
	dc.l	139718
	dc.l	139750
	dc.l	151082
	dc.l	151114
	dc.l	164814
	dc.l	164846
	dc.l	178136
	dc.l	178168
	dc.l	190098
	dc.l	190130
	dc.l	194888
	dc.l	194920
	dc.l	213068
	dc.l	213100
	dc.l	223412
	dc.l	223444
	dc.l	233440
	dc.l	233472
	dc.l	243408
	dc.l	243440
	dc.l	253938
	dc.l	253970
	dc.l	254484
	dc.l	258786
	dc.l	262988
	dc.l	266910
	dc.l	277274
	dc.l	277306
	dc.l	283990
	dc.l	291088
	dc.l	297138
	dc.l	303392
	dc.l	320688
	dc.l	321946
total:	dc.l	322714	Linkfile length
;
; Filenames follow on from here (padded with zeros and file no. follows)
;
FILENAMES:
	dc.b	'1632LOGO.SPC',0,0,0,0
	dc.b	0

	dc.b	'16_32.CPX',0,0,0,0,0,0,0

	dc.b	1

	dc.b	'16_32.PAL',0,0,0,0,0,0,0

	dc.b	2

	dc.b	'DECORS1.CPR',0,0,0,0,0

	dc.b	3

	dc.b	'DECORS1.PAL',0,0,0,0,0

	dc.b	4

	dc.b	'DECORS2.CPR',0,0,0,0,0

	dc.b	5

	dc.b	'DECORS2.PAL',0,0,0,0,0

	dc.b	6

	dc.b	'DECORS3.CPR',0,0,0,0,0

	dc.b	7

	dc.b	'DECORS3.PAL',0,0,0,0,0

	dc.b	8

	dc.b	'DECORS4.CPR',0,0,0,0,0

	dc.b	9

	dc.b	'DECORS4.PAL',0,0,0,0,0

	dc.b	10

	dc.b	'DRAG2.CPR',0,0,0,0,0,0,0

	dc.b	11

	dc.b	'DRAG2.PAL',0,0,0,0,0,0,0

	dc.b	12

	dc.b	'DRAGDEF3.SNG',0,0,0,0

	dc.b	13

	dc.b	'FOND1.CPR',0,0,0,0,0,0,0

	dc.b	14

	dc.b	'FOND1.PAL',0,0,0,0,0,0,0

	dc.b	15

	dc.b	'FOND2.CPR',0,0,0,0,0,0,0

	dc.b	16

	dc.b	'FOND2.PAL',0,0,0,0,0,0,0

	dc.b	17

	dc.b	'FOND3.CPR',0,0,0,0,0,0,0

	dc.b	18

	dc.b	'FOND3.PAL',0,0,0,0,0,0,0

	dc.b	19

	dc.b	'FOND4.CPR',0,0,0,0,0,0,0

	dc.b	20

	dc.b	'FOND4.PAL',0,0,0,0,0,0,0

	dc.b	21

	dc.b	'IMA.CPR',0,0,0,0,0,0,0,0,0

	dc.b	22

	dc.b	'IMA.PAL',0,0,0,0,0,0,0,0,0

	dc.b	23

	dc.b	'IMAGEFIN.CPR',0,0,0,0

	dc.b	24

	dc.b	'IMAGEFIN.PAL',0,0,0,0

	dc.b	25

	dc.b	'IMAGEPRS.CPR',0,0,0,0

	dc.b	26

	dc.b	'IMAGEPRS.PAL',0,0,0,0

	dc.b	27

	dc.b	'MONSTRE1.CPR',0,0,0,0

	dc.b	28

	dc.b	'MONSTRE1.PAL',0,0,0,0

	dc.b	29

	dc.b	'MONSTRE2.CPR',0,0,0,0

	dc.b	30

	dc.b	'MONSTRE2.PAL',0,0,0,0

	dc.b	31

	dc.b	'MONSTRE3.CPR',0,0,0,0

	dc.b	32

	dc.b	'MONSTRE3.PAL',0,0,0,0

	dc.b	33

	dc.b	'MONSTRE4.CPR',0,0,0,0

	dc.b	34

	dc.b	'MONSTRE4.PAL',0,0,0,0

	dc.b	35

	dc.b	'MUSI.',0,0,0,0,0,0,0,0,0,0,0

	dc.b	36

	dc.b	'OBJ2.PIC',0,0,0,0,0,0,0,0

	dc.b	37

	dc.b	'OBJ3.PIC',0,0,0,0,0,0,0,0

	dc.b	38

	dc.b	'OBJ4.PIC',0,0,0,0,0,0,0,0

	dc.b	39

	dc.b	'OBJETS.CPR',0,0,0,0,0,0

	dc.b	40

	dc.b	'OBJETS.PAL',0,0,0,0,0,0

	dc.b	41

	dc.b	'PLAN1.DAT',0,0,0,0,0,0,0

	dc.b	42

	dc.b	'PLAN2.DAT',0,0,0,0,0,0,0

	dc.b	43

	dc.b	'PLAN3.DAT',0,0,0,0,0,0,0

	dc.b	44

	dc.b	'PLAN4.DAT',0,0,0,0,0,0,0

	dc.b	45

	dc.b	'PROGV2.B',0,0,0,0,0,0,0,0

	dc.b	46

	dc.b	'SABLIER.PIC',0,0,0,0,0

	dc.b	47

	dc.b	'TABL.GRA',0,0,0,0,0,0,0,0

	dc.b	48

ENDFILE:	dc.w	0
	even

FILES	equ	49

;

	ifne	pacifist
regbase	dc.l	0

no_emu:
        dc.b    "It seems you're running under a",13,10
        dc.b    "mere ST.",0
an_emu:
        dc.b    "It seems you're running under an",13,10
        dc.b    "emulator.",0
pacifist_emu:
        dc.b    "You're running under PaCifiST",13,10,"v"
majorv: dc.b    "0."
minorv: dc.b    "00.",0

        EVEN
	endc
	

	SECTION BSS

variables
link_code_active	ds.w	1 

open_done		ds.w	1

seek_offset		ds.l	1

link_bytes_to_load	ds.l	1 

load_address		ds.l	1

filename_buffer 	ds.b	24

reg_store		ds.b	64


			ifne	sen_205
sentry_bytes		ds.l	1
			endc
		
			ds.b	1000
our_stack		ds.l	1
stop


