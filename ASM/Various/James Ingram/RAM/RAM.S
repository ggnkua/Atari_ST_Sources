* Disk to Ram proggy

	opt	o+,ow-

hdv_bpb	equ	$472
hdv_rw	equ	$476
hdv_med	equ	$47e

trap14	equ	$b8

drv_bits	equ	$4c2
phystop	equ	$42e

res_valid	equ	$426
res_vec		equ	$42a

	lea	stack(pc),a7

	lea	ctrl(pc),a0
	move.w	#52,(a0)+
	move.w	#1,(a0)+
	move.w	#1,(a0)+
	move.w	#1,(a0)+
	move.w	#0,(a0)+

	move.l	#try,addrin
	move.w	#1,aintin


	move.l	#apb,d1
	move.w	#$c8,d0
	trap	#2

	tst.w	aintout
	beq.s	auto

	cmp.w	#2,aintout
	bne.s	not_auto

term:
	clr.w	-(a7)
	trap	#1


auto:
	lea	intro(pc),a0
	bsr	print_mes


	move.w	#-1,-(a7)
	move.w	#11,-(a7)
	trap	#13
	addq.l	#4,a7
	
	btst	#2,d0
	beq.s	no_ctrl

	lea	abort(pc),a0
	bsr	print_mes

	bra.s	term

no_ctrl:
not_auto:
	clr.l	-(a7)
	move.w	#32,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	d0,-(a7)


	clr.w	d1
	move.w	d1,my_drv
	add.b	#"A",d1
	move.b	d1,drv_no



	move.l	phystop.w,d0
	sub.l	#$200000,d0
	bmi	no_mem

* get disk number
	move.w	#$19,-(a7)
	trap	#1
	addq.l	#2,a7
	move.w	d0,drv
	move.w	d0,changed

	subq.w	#2,d0
	bpl	not_floppy	; branch if current disk is not a floppy

* 2 meg or more
	lea	mem(pc),a0
	bsr	print_mes

* now do copy

	clr.w	side
	move.w	#0,track
	move.w	#1,sector
	move.w	#1,count
	move.l	#boot_sec,buffer
	bsr	read_sec

	lea	boot_sec(pc),a0
	move.b	$14(a0),d0
	lsl.w	#8,d0
	move.b	$13(a0),d0	; d0 holds no of sectors

	moveq	#0,d1
	move.b	$18(a0),d1	; d1 holds secs per track

	moveq	#0,d2
	move.b	$1a(a0),d2	; d2 holds no of sides
	move.w	d2,sides

	move.w	d1,spt
	divu	d1,d0
	divu	d2,d0
	subq.w	#1,d0
	move.w	d0,tracks


	mulu	#512,d1
	move.l	d1,track_len

	move.l	#$100000+rout_len,buffer
	bsr	read_all	; read in all of disk


	move.w	drv,-(a7)
	move.l	hdv_bpb.w,a0
	jsr	(a0)
	addq.l	#2,a7

	move.l	d0,a0
	lea	hdv(pc),a1
	moveq	#50/2-1,d0
shft_bpb:
	move.w	(a0)+,(a1)+
	dbra	d0,shft_bpb


* now install reset proof proggy
	move.l	#$31415926,res_valid.w
	move.l	res_vec.w,res_to
	move.l	#$100000+4,res_vec.w

	move.l	#$100000,a0
	lea	routine(pc),a1
	move.w	#rout_len/2-1,d0
ins_res:
	move.w	(a1)+,(a0)+
	dbra	d0,ins_res

	move.l	#$100000,phystop.w

* now do a reset to install it ok
	move.l	4.w,a0
	jmp	(a0)


read_all:
* read in all of disk!
	move.w	#-1,-(a7)
	move.w	#11,-(a7)
	trap	#13
	addq.l	#4,a7

	btst	#2,d0
	bne	terminate3


	move.w	spt,count	; load all sectors
	bsr	read_sec
	tst.w	d0
	bpl.s	no_read_err	; branch if all ok

* if not all ok, then load sectors 1 by 1 to get the good ones
	move.w	#1,count

g_track:
	bsr	read_sec
	add.l	#512,buffer

	addq.w	#1,sector
	move.w	spt,d0
	sub.w	sector,d0
	bpl.s	g_track

	move.w	spt,count
	move.w	#1,sector

	bra.s	past_add

no_read_err:
	move.l	track_len,d0
	add.l	d0,buffer
past_add:

	move.l	track_len,d0
	add.l	d0,buffer

	addq.w	#1,track
	move.w	tracks,d0
	sub.w	track,d0
	bpl	read_all

* done whole of a side
	move.l	#$100000+rout_len,buffer
	move.l	track_len,d0
	add.l	d0,buffer

	move.w	#0,track

	addq.w	#1,side
	move.w	sides,d0
	subq.w	#1,d0
	sub.w	side,d0
	bpl	read_all


	rts




terminate3:
	lea	4(a7),a7
	bra.s	terminate2

terminate:
	move.w	#10,d0
	moveq	#-1,d1
pause:
	dbra	d1,pause
	dbra	d0,pause


terminate2:
	move.w	#32,-(a7)
	trap	#1
	addq.l	#6,a7

	clr.w	-(a7)
	trap	#1

read_sec:
	move.w	count,-(a7)
	move.w	side,-(a7)
	move.w	track,-(a7)
	move.w	sector,-(a7)
	move.w	drv,-(a7)
	clr.l	-(a7)
	move.l	buffer,-(a7)
	move.w	#8,-(a7)
	trap	#14
	lea	20(a7),a7

	rts


no_mem:
	cmp.l	#"HIYA",$100000
	bne.s	just_meg

	lea	here(pc),a0
	bsr	print_mes
	bra.s	terminate

just_meg:
	lea	not(pc),a0
	bsr	print_mes
	bra.s	terminate
not_floppy:
	lea	flop(pc),a0
	bsr	print_mes
	bra.s	terminate


print_mes:
	pea	(a0)
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	rts

routine:
	dc.b	"HIYA"

on_reset:
	move.l	phystop.w,a0
	sub.l	#$10000,a0

	move.l	a0,a2

	move.l	#$12123456,(a0)+
	move.l	a2,(a0)+

	lea	reset_rout(pc),a1
	move.w	#reset_len/2-1,d0
copy_res:
	move.w	(a1)+,(a0)+
	dbra	d0,copy_res

* get checksum for reset installer
	moveq	#0,d0
	move.w	#$fe,d1
chk:
	add.w	(a2)+,d0
	dbra	d1,chk

	move.w	#$5678,d1
	sub.w	d0,d1
	move.w	d1,(a2)

* now tidy up and jump
	clr.l	res_valid.w
	clr.l	res_vec.w

	lea	res_to(pc),a0
	tst.l	(a0)
	beq.s	only_me

	move.l	(a0),a0
	jmp	(a0)
only_me:
	jmp	(a6)
res_to:
	ds.l	1

reset_rout:
* install my routines

install	macro
	move.l	#\1-routine+$100000,a0
	move.l	#\3-routine+$100000,a1

	move.l	\2,2(a1)
	move.l	a0,\2
	endm

	install	my_rw,hdv_rw,j_to
	install	my_hdv,hdv_bpb,hdv_to
	install	my_med,hdv_med,med_to
	install	my_14,trap14,j_14


	move.l	#$31415926,res_valid.w
	move.l	#$100000+4,res_vec.w
	rts

end_res:
reset_len	equ	end_res-reset_rout


my_rw:
* got a r/w call!!!
pdrive	equ	14
precno	equ	12
pbuffer	equ	6
pnumber	equ	10
prwflag	equ	4

	move.w	pdrive(a7),d0
	lea	my_drv(pc),a0
	cmp.w	(a0),d0
	bne	j_to		; branch if not my drive

* got a r/w on my drive!!!

	lea	store(pc),a0
	movem.l	d0-7/a1-a3,(a0)

	moveq	#0,d0
	move.w	precno(a7),d0	; get recno
	lsl.l	#8,d0
	add.l	d0,d0		; as offset

	lea	boot_sec(pc),a0
	add.l	d0,a0		; get addr to read/write on RAMdisk

	move.l	pbuffer(a7),a1	; get buffer addr

	move.w	prwflag(a7),d0	; get r/w flag
	btst	#0,d0
	beq.s	reading

	exg.l	a0,a1		; swap addrs if writing
reading:

	moveq	#0,d0
	move.w	pnumber(a7),d0	; get count for sectors
	lsl.l	#8,d0
	add.l	d0,d0		; as no of bytes to shift


* do transfer
	move.w	$ffff8240.w,-(a7)

	bsr	mem_shft

	move.w	(a7)+,$ffff8240.w

	lea	store(pc),a0
	movem.l	(a0),d0-d7/a1-a3
	moveq	#0,d0
	rts

j_to
	jmp	0.l

mem_shft:
* first determine which of the two shift modes are relevant
* either shift forwards from start or backwards from end

* from a0 to a1, length d0

	tst.l	d0
	beq	dun_shft

* first decide which direction to go
	move.l	a0,d7

	sub.l	a1,d7		; see if a0 overlaps a1
	bmi	do_backwards

	beq	dun_shft	; end if the same - no point!
* do it forwards

	move.w	a0,d6
	move.w	a1,d7

	and.w	#1,d6
	and.w	#1,d7		; keep only even/odd bits to test

	move.w	d7,d5
	or.w	d6,d5
	beq	both_even	; even if no odd bits at all

	eor.w	d6,d7
	beq	both_odd	; both odd if odd bits cancel out

* one even, one odd!

	move.l	d0,d1
	and.w	#15,d1
	lsr.l	#4,d0

* do "left overs" first

lefts:
	tst.w	d1
	beq.s	dun_lefts

	move.b	(a0)+,(a1)+
	subq.w	#1,d1
	bra.s	lefts

dun_lefts:
* "left overs" done, so now do in groups of 16

	tst.l	d0
	beq	dun_shft

	not.w	$ffff8240.w

	movep.l	(a0),d1
	movep.l	1(a0),d2
	movep.l	4(a0),d3
	movep.l	5(a0),d4


	movep.l	d1,(a1)
	movep.l	d2,1(a1)
	movep.l	d3,4(a1)
	movep.l	d4,5(a1)

	addq.l	#8,a0
	addq.l	#8,a1

	movep.l	(a0),d1
	movep.l	1(a0),d2
	movep.l	4(a0),d3
	movep.l	5(a0),d4


	movep.l	d1,(a1)
	movep.l	d2,1(a1)
	movep.l	d3,4(a1)
	movep.l	d4,5(a1)

	addq.l	#8,a0
	addq.l	#8,a1

	subq.l	#1,d0
	bra.s	dun_lefts

both_odd:
	move.b	(a0)+,(a1)+
	subq.l	#1,d0
	beq	dun_shft

both_even:
* both addresses given are even

	move.w	d0,d1
	and.w	#31,d1
	lsr.l	#5,d0

f_movems:
	tst.l	d0
	beq	do_e_left

	not.w	$ffff8240.w

	movem.l	(a0)+,d2-d7/a2-a3
	movem.l	d2-d7/a2-a3,(a1)
	lea	32(a1),a1

	subq.l	#1,d0
	bra.s	f_movems

* do even leftovers

do_e_left:
	tst.w	d1
	beq.s	dun_shft

	move.b	(a0)+,(a1)+
	subq.w	#1,d1
	bra.s	do_e_left

dun_shft:
	rts

do_backwards:

	add.l	d0,a0
	add.l	d0,a1

	move.w	a0,d6
	move.w	a1,d7

	and.w	#1,d6
	and.w	#1,d7		; keep only even/odd bits to test

	move.w	d7,d5
	or.w	d6,d5
	beq	even_back	; even if no odd bits at all

	eor.w	d6,d7
	beq	back_odd	; both odd if odd bits cancel out

* one even, one odd!

	move.l	d0,d1
	and.w	#15,d1
	lsr.l	#4,d0

* do "left overs" first

b_lefts:
	tst.w	d1
	beq.s	dun_b_lefts

	move.b	-(a0),-(a1)
	subq.w	#1,d1
	bra.s	b_lefts

dun_b_lefts:
* now do main part in groups of 16

	tst.l	d0
	beq.s	dun_shft

	not.w	$ffff8240.w

	subq.l	#8,a0
	subq.l	#8,a1

	movep.l	(a0),d1
	movep.l	1(a0),d2
	movep.l	4(a0),d3
	movep.l	5(a0),d4

	movep.l	d1,(a1)
	movep.l	d2,1(a1)
	movep.l	d3,4(a1)
	movep.l	d4,5(a1)

	subq.l	#8,a0
	subq.l	#8,a1

	movep.l	(a0),d1
	movep.l	1(a0),d2
	movep.l	4(a0),d3
	movep.l	5(a0),d4

	movep.l	d1,(a1)
	movep.l	d2,1(a1)
	movep.l	d3,4(a1)
	movep.l	d4,5(a1)

	subq.l	#1,d0

	bra	dun_b_lefts


back_odd:
	move.b	-(a0),-(a1)
	subq.l	#1,d0
	beq	dun_shft

even_back:
	move.w	d0,d1
	and.w	#31,d1
	lsr.l	#5,d0

* first do the main block

l_movems:
	tst.l	d0
	beq	l_lefts

	not.w	$ffff8240.w

	lea	-32(a0),a0
	movem.l	(a0),d2-d7/a2-a3
	movem.l	d2-d7/a2-a3,-(a1)

	subq.l	#1,d0
	bra.s	l_movems


* "left overs" as usual!

l_lefts:
	tst.w	d1
	beq	dun_shft

	move.b	-(a0),-(a1)
	subq.w	#1,d1
	bra.s	l_lefts

my_med:
	lea	my_drv(pc),a0
	move.w	(a0),d0
	cmp.w	4(a7),d0
	beq.s	my_med2

med_to:
	jmp	0.l

my_med2:
	lea	changed(pc),a0
	move.w	(a0),d0
	clr.w	(a0)
	rts


my_hdv:
* my routine for getting bpb data
	lea	my_drv(pc),a0
	move.w	(a0),d0
	cmp.w	4(a7),d0
	bne.s	hdv_to

* my drive needs bpb!
	lea	hdv(pc),a0
	move.l	a0,d0
	rts

hdv_to:
	jmp	0.l

my_14:
* trap 14 has been called

	lea	store(pc),a0
	movem.l	d1-d7/a1-a6,(a0)

	btst.b	#5,(a7)
	bne.s	user

	move.l	USP,a0
	bra.s	got_stk
user:
	lea	6(a7),a0
got_stk:
	cmp.w	#8,(a0)
	beq.s	yes_yes
	cmp.w	#9,(a0)
	bne	end_trap

yes_yes:
* a read or write track operation!!!!!!!

buff14	equ	2
dev14	equ	10
sec14	equ	12
track14	equ	14
side14	equ	16
count14	equ	18


	lea	my_drv(pc),a1
	move.w	(a1),d0
	cmp.w	dev14(a1),d0
	bne	end_trap

* my drive!!!!
	lea	track_len(pc),a1
	move.l	(a1),d0

	lea	sides(pc),a1
	cmp.w	#1,(a1)
	beq.s	single

* double sided drive, so track len * 2

	add.l	d0,d0
single:
	move.w	track14(a0),d2	; get track number
	moveq	#0,d1

get_trk:
	tst.w	d2
	beq.s	got_trk
	add.l	d0,d1
	subq.w	#1,d2
	bra.s	get_trk

got_trk:
* got track offset
	lsr.l	#1,d0		; track len normal

	tst.w	side14(a0)
	beq.s	side_one

* side 2, so add!
	add.l	d0,d1

side_one:
* d1 now has correct trak position
	move.w	sec14(a0),d0	; get sector number
	subq.w	#1,d0
	mulu	#512,d0
	add.l	d0,d1		; d1 now has correct offset

	move.w	count14(a0),d0
	mulu	#512,d0		; d0 = length to copy in bytes

	move.l	buff14(a0),a1	; a1 = copy to

	lea	boot_sec(pc),a2
	add.l	d1,a2		; a2 = copy from

	cmp.w	#8,(a0)
	beq.s	trap_read

	exg.l	a1,a2
trap_read:
	move.l	a2,a0


	move.w	$ffff8240.w,-(a7)
	bsr	mem_shft
	move.w	(a7)+,$ffff8240.w

	moveq	#0,d0		; no error code

	lea	store(pc),a0
	movem.l	(a0),d1-d7/a1-a6
	rte

end_trap:
	lea	store(pc),a0
	movem.l	(a0),d1-d7/a1-a6
j_14:
	jmp	0.l
hdv:
	ds.b	50
my_drv:
	ds.w	1
changed:
	ds.w	1

spt:
	ds.w	1
tracks:
	ds.w	1
sides:
	ds.w	1
track_len:
	ds.l	1

end_routine:
rout_len	equ	end_routine-routine

boot_sec:
	ds.b	512

test:
	move.l	$b8,j+2
	move.l	#j,$b8


	move.w	#2,-(a7)
	move.w	#0,-(a7)
	move.w	#0,-(a7)
	move.w	#1,-(a7)
	clr.w	-(a7)
	clr.l	-(a7)
	pea	jjj(pc)
	move.w	#8,-(a7)
	trap	#14
	lea	20(a7),a7


j:
	jmp	0.l



flop:
	dc.b	"You are not loading from a floppy!?!",10,13
	dc.b	"I shall not use RAM access.",10,13,10,0

mem:
	dc.b	"You have 2 meg or more.",10,13
	dc.b	"I am copying this disk",10,13
	dc.b	"to RAM as drive "
drv_no:
	dc.b	"D.",10,13,10,0

here:
	dc.b	"RAM loader already present",10,13,10,0
intro:
	dc.b	10,13,10
	dc.b	27,"p"
	dc.b	"*******************************",10,13
	dc.b	"***       RAM LOADER        ***",10,13
	dc.b	"***  by James Ingram, 1992  ***",10,13
	dc.b	"*******************************"
	dc.b	27,"q",10,13,10
	dc.b	"Hold down CONTROL to abort",10,13,10
	dc.b	0


not:
	dc.b	"Not enough memory for RAM access.",10,13,10,0

try:
	dc.b	"[0][      RAM LOADER|by James Ingram, 1992  |"
	dc.b	"Insert disk to load.]"
	dc.b	"[OK|Cancel]",0

abort:
	dc.b	27,"p*** CONTROL pressed.  Aborting. ***",27,"q",10,13,10,0

	even

apb:
	dc.l	ctrl,global,aintin,aintout,addrin,addrout

	section	bss

ctrl:
	ds.w	5
global:
	ds.w	3
	ds.l	6
aintout:
	ds.w	8
aintin:
	ds.w	18
addrin:
	ds.l	3
addrout:
	ds.l	2


drv:
	ds.w	1
count:
	ds.w	1
buffer:
	ds.l	1
side:
	ds.w	1
track:
	ds.w	1
sector:
	ds.w	1


	ds.b	500
stack:
	ds.b	100
prog_len:
	ds.l	1
store:
	ds.b	32


one_track:
	ds.b	512*11*2
jjj: