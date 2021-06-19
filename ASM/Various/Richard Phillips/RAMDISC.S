***************************
*  Atari ST Safe Ramdisc  *
*   By Richard Phillips   *
* Atari ST User July 1988 *
***************************

* Equate constants

* GEMDOS functions used
term	equ 0	terminate program
conin	equ 7	fetch character from keyboard
prntln	equ 9	print a line of text to the screen
k_proces	equ $31	terminate and stay resident
malloc	equ $48	allocate memory
setblock	equ $4a	release unwanted memory

* XBIOS routines used
protobt	equ 18	prototype boot sector
supexec	equ 38	execute routine in supervisor mode

* TOS variables used
hdv_bpb	equ $472	vector for BPB handler
hdv_rw	equ $476	vector for R/V handler
mediach	equ $47e vector for media change handler
drvbits	equ $4c2	BIOS logical disc status variable

* Initialisation routine
ramdisk
 move.l	4(sp),a6		store the base page pointer
 pea	banner		push address of string on stack
 move.w	#prntln,-(sp)	push number of GEMDOS routine
 trap 	#1		to be called, then call GEMDOS
 addq.l	#6,sp		adjust the stack
 pea	init
 move.w	#supexec,-(sp)	execute initialisation routine
 trap	#14		in supervisor mode
 addq.l	#6,sp
 tst.w	disk_flg		any errors occurred?
 bpl	no_err		if not indicate so
 pea	err_str		print a string to indicate
 move.w	#prntln,-(sp)	that an error has occurred
 trap	#1
 addq.l	#6,sp
 bra	exit		quit
no_err
 bsr	prnt_sz		print size of ramdisc installed
 pea	success
 move.w	#prntln,-(sp)	print message to indicate
 trap	#1		successful initialisation
 addq.l	#6,sp
exit
 pea	exit_str		print a message to encourage
 move.w	#prntln,-(sp)	the user to press a key
 trap	#1
 addq.l	#6,sp
 move.w	#conin,-(sp)	get a character from the console
 trap	#1
 addq.l	#2,sp
 tst.w	disk_flg		error occurred in initialisation?
 bmi	no_disk		if so then just quit
 clr.w	-(sp)
 move.l	#code_end-ramdisk,-(sp)	reserve required memory
 move.w	#k_proces,-(sp)		then exit program.
 trap	#1

* Routine called when an error occurres during installation
no_disk
 move.w	#term,-(sp)	quit without installing ramdisc
 trap	#1

* Routine which does the actual installation
init
 bsr	rels_mem		call routine which releases memory
 tst.w	disk_flg		back to GEMDOS
 bmi	initexit		if an error occurred then exit
 bsr	get_size		call routine which gets ramdisc size
 tst.w	disk_flg		if error then exit.
 bmi	initexit
 bsr	get_mem		call routine which allocates memory
 tst.w	disk_flg		for the ramdisc.
 bmi	initexit		if an error occurred then exit
 bsr	set_disk		call routine which inits disc
 bsr	setvec		call routine which sets up ramdisc
 bset	#3,drvbits+3	tell TOS about ramdisc
initexit
 rts

* Routine which gives all unused memory back to GEMDOS
rels_mem
 move.l	$c(a6),d0	get the length og the text section
 add.l	$14(a6),d0	add length of initialised data
 add.l	$1c(a6),d0	add length of uninitialised data
 add.l	#$100,d0		add length of the base page
 move.l	d0,-(sp)		push all of that on to the stack
 move.l	a6,-(sp)		push start address
 clr.w	-(sp)		null word
 move.w	#setblock,-(sp)	call GEMDOS routine which releases
 trap	#1		memory
 add.l	#12,sp		adjust the stack pointer
 tst.l	d0		has an error occurred?
 bne	rels_err		if yes jump to rels_err
 rts

* Routine which is called if GEMDOS signals an error when
* memory is being handed back to GEMDOS.
* This subroutine should never be called - hopefully!
rels_err
 subq.w	#1,disk_flg	make disk_flg reflect that an error
 pea	blk_str		has occurred
 move.w	#prntln,-(sp)	print a message to indicate thet an
 trap	#1		error has occurred.
 addq.l	#6,sp
 rts

* Routine which determines the size of ramdisk required
get_size
 lea	$81(a6),a0	get address of command line
 tst.b	(a0)		test for empty command line
 beq	usage		error - print program usage
spc_loop
 cmp.b	#' ',(a0)+	skip all space characters
 beq	spc_loop
 subq.l	#1,a0		kludge correct address
 cmp.b	#' ',(a0)	if end of string encountered
 ble	cmd_err		error out
 move.l	a0,a1		save start address of string for
 move.l	a0,strt_adr	use later
 clr.l	d0		clear counter
num_loop
 cmp.b	#' ',(a1)	if a non-numeric is encountered
 bgt	not_end
 clr.b	(a1)		kludge an end of string marker
 bra	end_str		and then break out of loop
not_end
 cmp.b	#'0',(a1)
 blt	cmd_err		if character is not numeric
 cmp.b	#'9',(a1)+	cause an error
 bgt	cmd_err
 addq.l	#1,d0		increament string counter
 bra	num_loop		loop again
end_str
 cmp.b	#2,d0		if string length < 2
 blt	too_smll		then error
 cmp.b	#4,d0		if string length > 4
 bgt	too_lrge		then error
 move.l	disk_siz,d0	initialise storage register
get_num
 mulu	#10,d0		multiply size by ten
 move.b	(a0)+,d1
 sub.b	#'0',d1		subtract ascii base to get digit
 add.l	d1,d0		add onto ramdisc size
 tst.b	(a0)		any more characters?
 bne	get_num		yes to loop again
 add.l	#9,d0		add 9K for TOS sector
 move.l	#10,d1
 asl.l	d1,d0		shift size to get size in bytes
 move.l	d0,disk_siz	store size
 move.l	#-1,-(sp)
 move.w	#malloc,-(sp)	see how much free memory there is
 trap	#1
 addq.l	#6,sp
 cmp.l	disk_siz,d0	ramdisk too large?
 blt	too_lrge		yes so error out
 rts			return to caller

* Routine which is called if no command line is supplied
usage
 sub.w	#1,disk_flg	make disk_flg reflect that error
 pea	usge_str		has occurred
 move.w	#prntln,-(sp)	print the error string
 trap	#1
 addq.l	#6,sp		restore sp
 rts			return to caller

* Routine which is called if dud command line is supplied
cmd_err
 sub.w	#1,disk_flg	make disk_flg reflect that an
 pea	cmd_str		error has occurred
 move.w	#prntln,-(sp)	print the error string
 trap	#1
 addq.l	#6,sp		restore sp
 rts			return to caller

* Routine called if size of ramdisc requested too small
too_smll
 sub.w	#1,disk_flg	make disk_flg reflect that an
 pea	smll_str		error has occurred
 move.w	#prntln,-(sp)	print the error string
 trap	#1
 addq.l	#6,sp
 rts

* Routine called if size of randisc requested is too large
too_lrge
 sub.w	#1,disk_flg	make disk_flg reflect that an
 pea	lrge_str		error has occurred
 move.w	#prntln,-(sp)	print the error string
 trap	#1
 addq.l	#6,sp
 rts

* Routine which attempts to reserve memory for the ramdisc
get_mem
 move.l	disk_siz,-(sp)	push the amount of memory required
 move.w	#malloc,-(sp)	use malloc to reserve the memory
 trap	#1
 addq.l	#6,sp
 cmp.l	#0,d0		has an error occurred?
 bls	mem_err		if so jump to mem_err
 move.l	d0,disk_adr	else store start addr of ramdisc
 rts

* Routine called if an error occurres allocating memory
mem_err
 subq.w	#1,disk_flg	indicate an error
 pea	mem_str
 move.w	#prntln,-(sp)	print message to indicate that
 trap	#1		memory could not be allacated
 addq.l	#6,sp		for the ramdisc
 rts

* Routine which prints the size of ramdisc
prnt_sz
 move.l	strt_adr,-(sp)	push address of string
 move.w	#prntln,-(sp)	call GEMDOS to ptint string
 trap	#1
 addq.l	#6,sp
 rts

* Routine which initialises the ramdisc
set_disk
 clr.w	-(sp)		use XBIOS to create boot sector
 move.w	#2,-(sp)		not executable, single sided
 move.l	#$1000000,-(sp)	random serial number
 move.l	disk_adr,-(sp)	address of Ramdisc buffer
 move.w	#protobt,-(sp)	call XBIOS
 trap	#14
 lea	14(sp),sp	quick and dirty way to reset stack
 move.l	disk_adr,a0	get address of ramdisc memory
 move.l	disk_siz,d0	get disc size in bytes
 move.l	#11,d1		convert to sectors
 asr.l	d1,d0
 lea	19(a0),a0	set up the number of sectors
 move.b	d0,(a0)+		on the disc in 8086 format
 lsr.b	#8,d0		swap lo and hi bytes of word
 move.b	d0,(a0)		store second 8086 byte
 move.l	disk_siz,d0	load size of disc
 subq.l	#1,d1
 asr.l	d1,d0		get the number of data clusters
 sub.l	#9,d0
 move.w	d0,numcl		store the number of clusters
 rts

* Routine which re-vectors the TOS hard disc bindings
setvec
 move.l	hdv_bpb,old_bpb	save address of old BPB
 move.l	hdv_rw,old_rw	save address of old R/W
 move.l	mediach,old_mdch	save address of old mediach
 move.l	#new_bpb,hdv_bpb	re-vector bpb handler
 move.l	#new_rw,hdv_rw	re-vector R/W handler
 move.l	#new_mdch,mediach	re-vector media change
 rts

new_bpb
 cmp.w	#3,4(sp)		is drive D required?
 beq	do_bpb		yes
 move.l	old_bpb,-(sp)	no, so call old BPB handler
 rts
do_bpb
 move.l	#bpb,d0		return to caller with address of
 rts			BPB in D0

new_rw
 cmp.w	#3,14(sp)	is drive D required?
 beq	do_rw		yes
 move.l	old_rw,-(sp)	no, call old handler
 rts
do_rw
 move.w	12(sp),d0	get the logical sector number
 move.l	#9,d1
 asl.l	d1,d0		times 512 to get byte offset
 add.l	disk_adr,d0	into ramdisc memory
 move.l	d0,a0		move into address register
 move.l	6(sp),a1		get the buffer address
 move.w	10(sp),d1	number of sector to transfer
 sub.w	#1,d1		alter number for dbcc opcode
 btst	#0,5(sp)		read or write
 beq	transfer		its read, don't swap registers
 exg	a0,a1		swap registers as same code used
transfer
 move.l	#127,d0		128 longwords per sector
l_sec_lp
 move.l	(a0)+,(a1)+	transfer longword
 dbra	d0,l_sec_lp	do 128 times (127 for dbcc)
 dbra	d1,transfer	do for required sectors
 clr.l	d0
 rts

new_mdch
 cmp.w	#3,4(sp)		is drive D requires?
 beq	do_mdch		yes
 move.l	old_mdch,-(sp)	no, call old handler
 rts
do_mdch
 clr.l	d0		ramdisc media never changes
 rts			return to caller

* Set up the BIOS Parameter Block (BPB) for the ramdisc
bpb
recsiz	dc.w $200	sector size in bytes
clsiz	dc.w 2		cluster size in sectors
clsizb	dc.w $400	cluster size in bytes
rdlen	dc.w 7		directory size in sectors
fsiz	dc.w 5		FAT size in sectors
fatrec	dc.w 6		sector number of 2nd FAT
datrec	dc.w 18		number of first data cluster
numcl	dc.w 0		number of data clusters (K's)
bflags	ds.l 4		BIOS flags

* Note: numcl isset to zero as it will be setup once size of
* disc is known.

* Variables used
old_bpb	ds.l 1		address of old BPB handler
old_rw	ds.l 1		address of old R/W handler
old_mdch	ds.l 1		address of old Mediach handler
disk_flg	ds.w 1		initialisation status variable
disk_adr	ds.l 1		address of ramdisc buffer
disk_siz	ds.l 1		size of disc
strt_adr	ds.l 1		start address of a string
code_end

* General output strings
banner	dc.b 'Atari ST Safe Ramdisc.',13,10
 dc.b '(c) Copyright 1987 Richard Phillips.',13,10,13,10,0
usge_str	dc.b 'usage : ramdisk.ttp <size>.',13,10,0
cmd_str	dc.b 'Error in command line parameter.',13,10,0
smll_str	dc.b 'Ramdisk size too small.',13,10,0
lrge_str	dc.b 'Ramdisk size too big.',13,10,0
blk_str	dc.b 'Cab',39,'t release memory.',13,10,0
mem_str	dc.b 'Error in memory allacation.',13,10,0
success	dc.b 'K Ramdisk installed.',13,10,0
err_str	dc.b 13,10,'No Ramdisk installed.',13,10,0
exit_str	dc.b 13,10,'Press any key to exit.',13,10,0
the_end	end