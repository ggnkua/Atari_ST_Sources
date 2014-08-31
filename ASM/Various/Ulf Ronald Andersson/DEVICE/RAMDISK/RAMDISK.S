;File name:	RAMDISK.S		Revision date:	1992.03.09
;Revised by:	Ulf Ronald Andersson	Disassembled:	1992.03.03
;
;
	output	.TTP
;
	include	URAn_SYS.S
	include URAn_DOS.S
	include	URAn_XB.S
;
;
version_date	=	$19920309
;
;
	section	text
;
	opt	a+
	opt	o+
;
startup:
bp	=	startup-$100
	bra	main		;this code re_iz'd to version_date
;
drive_id:
	dc.w	0003		;3 == drive D:
;
max_sector:
	dc.w	0		;re_iz'd to total sector count
;
ram_bpb:
	dc.w	$0200,$0002,$0400
	dc.w	$0007,$0005,$0006
	dc.w	$0012,$0000,$0000	;bpb_data_clusts re_iz'd
;
sectbase_p:
	dc.l	0
;
;
	XB_define	nu_hdv_bpb,'RAMA'
	move	drive_id(pc),d0
	sub	4(sp),D0
	beq.s	ram_hdv_bpb
	XB_gonext_d	nu_hdv_bpb(pc)
;
ram_hdv_bpb:
	lea	ram_bpb(pc),a0
	move.l	a0,d0
	rts
;
;
	XB_define	nu_hdv_rw,'RAMA'
	move	drive_id(pc),d0
	sub	14(sp),d0
	beq.s	ram_hdv_rw
	XB_gonext_d	nu_hdv_rw(pc)
;
ram_hdv_rw:
	move	max_sector(pc),d2
	clr.l	d0
	move	12(sp),d0
	sub	d0,d2
	lsl.l	#8,d0
	lsl.l	#1,d0		;d0= sector * $200
	add.l	sectbase_p(pc),d0
	move.l	d0,a0		;a0->sector
	move.l	6(sp),a1	;a1->buffer
	move	10(sp),d1	;d1= count
	cmp	d2,d1
	bls.s	ram_rw_min_count
	exg	d1,d2
	moveq	#-1,d2
ram_rw_min_count:
	subq	#1,d1		;adj for dbra
	btst	#0,5(sp)
	beq.s	ram_rw_loop
	exg	a0,a1
ram_rw_loop:
	rept	512
	move.b	(a0)+,(a1)+
	endr
	dbra	d1,ram_rw_loop
	tst	d2
	bmi.s	ram_rw_error
	clr.l	d0
	rts
;
ram_rw_error:
	moveq	#-1,d0
ram_hdv_mediach:
	rts
;
;
	XB_define	nu_hdv_mediach,'RAMA'
	clr.l	d0
	move	drive_id(pc),d0
	sub	4(sp),d0
	beq.s	ram_hdv_mediach
	XB_gonext_d	nu_hdv_mediach(pc),-(sp)
;
;
tsr_limit:
;
;
main:
	move.l	4(sp),a6
	lea	local_stack(pc),sp
	move.l	#version_date,startup-bp(a6)
	gemdos	Cconws,copyright_s(pc)
	xbios	Supexec,sup_try_install(pc)
	move.l	izerror_flag,d7
	bpl.s	good_install
	gemdos	Cconws,not_installed_s(pc)
	bra.s	wait_userkey
;
good_install:
	gemdos	Cconws,installed_s(pc)
	bsr	show_size_string
	gemdos	Cconws,KBytes_s
wait_userkey:
	gemdos	Cconws,press_exit_s(pc)
	gemdos	Crawcin
	tst.l	d7
	bmi.s	bad_install
	gemdos	Ptermres,#tsr_limit-bp,d7
;
;
bad_install:
	gemdos	Pterm,d7
;
;
busy_slot:
	pea	busy_slot_s(pc)
	bra	show_error
;
sup_try_install:
	bsr.s	release_TPA
	tst.l	d7
	bmi.s	stop_install
	bsr	convert_parm
	tst.l	d7
	bmi.s	stop_install
	move	drive_id(pc),d0
	move.l	(_drvbits).w,d1
	btst	d0,d1
	bne.s	busy_slot
	bsr	take_disk_RAM
	tst.l	d7
	bmi.s	stop_install
	move	drive_id(pc),d0
	move.l	(_drvbits).w,d1
	bset	d0,d1
	bne.s	busy_slot
	move.l	d1,(_drvbits).w
	add.b	d0,7+nu_hdv_bpb-bp(a6)
	add.b	d0,7+nu_hdv_rw-bp(a6)
	add.b	d0,7+nu_hdv_mediach-bp(a6)
	bsr	fix_disk
	move	SR,d5
	ori	#$0700,SR
	move.l	(hdv_bpb).w,8+nu_hdv_bpb-bp(a6)
	move.l	(hdv_rw).w,8+nu_hdv_rw-bp(a6)
	move.l	(hdv_mediach).w,8+nu_hdv_mediach-bp(a6)
	lea	12+nu_hdv_bpb(pc),a0
	move.l	a0,(hdv_bpb).w
	lea	12+nu_hdv_rw(pc),a0
	move.l	a0,(hdv_rw).w
	lea	12+nu_hdv_mediach(pc),a0
	move.l	a0,(hdv_mediach).w
	move	d5,SR
stop_install:
	rts
;
release_TPA:
	gemdos	Mfree|_ind,bp_environ_p(a6)
	gemdos	Mshrink,!,(a6),#prog_limit-bp
	tst.l	d0
	bne.s	show_release_error
	rts
;
;
show_release_error:
	pea	no_release_s(pc)
	bra	show_error
;
;
convert_parm:
	lea	bp_arglen(a6),a0
	move.b	(a0)+,d0
	beq	show_parmerror
	clr.b	(a0,d0)
.skip_space_1:
	cmpi.b	#' ',(a0)+
	beq.s	.skip_space_1
	cmpi.b	#HT,-1(a0)
	beq.s	.skip_space_1
	subq.l	#1,a0			;step a0 back -> 1'st non_space
	cmpi.b	#' ',(a0)
	ble	show_parmerror
	move.l	a0,a1			;a1 -> 1'st visible non_space
	move.l	a0,conv_buf_p-bp(a6)
	clr.l	d0
L126:
	cmpi.b	#'0',(a1)
	blt	show_parmerror
	cmpi.b	#'9',(a1)+
	bgt	show_parmerror
	addq.l	#1,d0
	cmpi.b	#' ',(a1)
	bgt.s	L126
	cmp.b	#2,d0
	blt.s	show_small_error
	cmp.b	#4,d0
	bgt.s	show_big_error
	move.l	a1,a2
.skip_space_2:
	cmp.b	#' ',(a1)+
	beq.s	.skip_space_2
	cmp.b	#HT,-1(a1)
	beq.s	.skip_space_2
	tst.b	-(a1)
	beq.s	.default_drive
	clr	d0
	move.b	(a1),d0
	and.b	#$5F,d0
	sub.b	#'A',d0
	ble.s	show_parmerror
	cmp	#32,d0
	bhs.s	show_parmerror
	move	d0,drive_id-bp(a6)
.default_drive:
	clr.b	(a2)
	add	#'A',d0
	move.b	d0,partition_s-bp(a6)
	clr.l	d0
	clr.l	d1
L160:
	mulu	#10,d0
	move.b	(a0)+,d1
	subi.b	#'0',d1
	add.l	d1,d0
	cmpi.b	#' ',(a0)
	bgt.s	L160
	addi.l	#9,d0		;Adds 9 KByte to requested size
	lsl.l	#8,d0
	lsl.l	#2,d0
	move.l	d0,d6
	gemdos	Malloc,?
	cmp.l	d6,d0
	blt.s	show_big_error
	rts
;
;
show_parmerror:
	pea	parmerror_s(pc)
	bra.s	show_error
;
;
show_small_error:
	pea	toosmall_s(pc)
	bra.s	show_error
;
;
show_big_error:
	pea	toobig_s(pc)
show_error:
	moveq	#-1,d7
	move.l	d7,izerror_flag-bp(a6)
show_string:
	gemdos	Cconws,()
	rts
;
;
take_disk_RAM:
	gemdos	Malloc,d6
	tst.l	d0
	beq.s	show_mallocerror
	move.l	d0,sectbase_p-bp(a6)
	rts
;
;
show_mallocerror:
	pea	mallocerror_s(pc)
	bra.s	show_error
;
;
show_size_string:
	move.l	conv_buf_p(pc),-(sp)
	bra.s	show_string
;
;
fix_disk:
	move.l	d6,d0
	lsr.l	#8,d0
	lsr.l	#2,d0
	subi.l	#9,d0		;subtracts 9 KByte, to produce requested size
	move	d0,bpb_data_clusts+ram_bpb-bp(a6)
	move.l	d6,d0
	lsr.l	#8,d0
	lsr.l	#1,d0
	move	d0,max_sector-bp(a6)
	lea	bs_disk_sects+dummy_bs(pc),a0
	move.b	d0,(a0)+
	lsr.b	#8,d0
	move.b	d0,(a0)
	lea	dummy_bs(pc),a0		;a0 -> boot data
	move.l	sectbase_p(pc),a1	;a1 -> boot sector
	moveq	#(limit_bs-dummy_bs)/4-1,d0
.loop:
	move.l	(a0)+,(a1)+
	dbra	d0,.loop
	rts
;
;
	section	data
;
izerror_flag:
	dc.l	0
conv_buf_p:
	dc.l	0
;
;
copyright_s:
	dc.b	CR,LF
	dc.b	'Atari ST  Reset_able Ramdisk.',CR,LF
	dc.b	'(C)1992 Ulf Ronald Andersson ',CR,LF,CR,LF,NUL
installed_s:
	dc.b	'New Ramdisk is '
partition_s:
	dc.b	'D:\ with ',NUL
KBytes_s:
	dc.b	' KBytes.',CR,LF,NUL
press_exit_s:
	dc.b	CR,LF
	dc.b	'Press any key to exit.',CR,LF,NUL
busy_slot_s:
	dc.b	'Requested drive slot was not free ! ',CR,LF,NUL
parmerror_s:
	dc.b	'Error in command line parameter ! ',CR,LF
	dc.b	CR,LF
	dc.b	'Use:	RAMDISK.TTP size_k [partition]',CR,LF
	dc.b	CR,LF
	dc.b	'eg1:	RAMDISK.TTP 200 D',CR,LF
	dc.b	'eg2:	RAMDISK.TTP 200',CR,LF
	dc.b	'eg3:	RAMDISK.TTP 1500 C:',CR,LF
	dc.b	CR,LF
	dc.b	"NB: 'D' is default so examples 1 & 2",CR,LF
	dc.b	'NB: both create D: with 200 KByte.',CR,LF
	dc.b	CR,LF
	dc.b	'NB: Characters after partition letter',CR,LF
	dc.b	'NB: will be ignored as batch comment.',CR,LF
	dc.b	NUL
toosmall_s:
	dc.b	'Ramdisk size too small ! ',CR,LF,NUL
toobig_s:
	dc.b	'Ramdisk size too big ! ',CR,LF,NUL
no_release_s:
	dc.b	"Can't release memory ! ",CR,LF,NUL
mallocerror_s:
	dc.b	'Error in memory allocation ! ',CR,LF,NUL
not_installed_s:
	dc.b	CR,LF
	dc.b	'No Ramdisk installed.',CR,LF,NUL
	even
;
dummy_bs:
	DC.L	$E9004E4E,$4E4E4E4E,$56022100,$02020100
	DC.L	$02700033,$33F90500,$09000200,$00004E4E
	DC.L	$4E4E4E4E,$4E4E4E4E,$4E4E4E4E,$4E4E4E4E
	DC.L	$4E4E4E4E,$4E4E4E4E,$4E4E4E4E,$00000000
limit_bs:
;
;
	section	bss
;
	ds.l	$100
local_stack:
;
;
prog_limit:
;
;
	end	;of file:	RAMDISK.S
