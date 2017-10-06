* Reset proof - auto booting RAM disk (hopefully)
*  by James Ingram, 1992

	opt	o+,ow-

drv_bits	equ	$4c2

hdv_bpb	equ	$472
hdv_med	equ	$47e
hdv_rw	equ	$476

phystop	equ	$42e

res_val	equ	$426
res_vec	equ	$42a


bootdev	equ	$446

star:
	bra.s	flagg
flag:
	dc.b	"GBD!"
proof_flag:
	dc.b	"y"
boot_flag:
	dc.b	"y"
flagg:
	lea	path(pc),a0
	move.l	#"A:\*",(a0)+
	move.w	#".*",(a0)

	lea	present(pc),a0
	bsr	super

	sub.l	#"GBD!",d0
	bne.s	not_here

* already there!!!
	move.b	#"y",here_flag

not_here:
	move.l	4(a7),a5

	move.l	4(a5),d0	; get top of memory
	sub.l	#boot_sec,d0
	sub.l	#40000,d0	; space for op sys
	sub.l	#11*1024,d0	; space for management

	bpl.s	mem_ok1

no_mem:
* no memory
	lea	no_mem(pc),a0
	bsr	print_mes

terminate:
	cmp.b	#"y",auto
	beq.s	no_inp

	move.w	#7,-(a7)
	trap	#1
	addq.l	#2,a7

no_inp:
terminate2:
	lea	new_line(pc),a0
	bsr	print_mes
	lea	new_line(pc),a0
	bsr	print_mes

	clr.w	-(a7)
	trap	#1


mem_ok1:
	moveq	#10,d1
	lsr.l	d1,d0		; d0 has max size in K

	move.w	d0,max_k

	tst.w	d0
	beq.s	no_mem

	lea	jim(pc),a0
	bsr	print_mes

	move.w	#-1,-(a7)
	move.w	#11,-(a7)
	trap	#13
	addq.l	#4,a7
	btst	#2,d0
	beq.s	no_control

	lea	abort(pc),a0
	bsr	print_mes

	clr.w	-(a7)
	trap	#1

no_control:
	lea	ctrl(pc),a0
	move.w	#52,(a0)+
	move.w	#1,(a0)+
	move.w	#1,(a0)+
	move.w	#1,(a0)+
	move.w	#0,(a0)+

	move.l	#intro,addrin
	move.w	#1,aintin
	bsr	aes

	move.b	#"n",auto

	tst.w	aintout
	bne	not_auto_load
* from AUTO
	move.b	#"y",auto

* check present
	cmp.b	#"y",here_flag
	bne.s	no_ex
* AUTO folder and already here
	lea	here(pc),a0
	bsr	print_mes
	bra	terminate2

no_ex:
* AUTO folder load, so load in BOOTUP.DAT
	move.b	#"n",file

	lea	bootup(pc),a0
	bsr	open

	move.w	d0,d7
	bmi	no_file

* file opened
	pea	store(pc)
	move.l	#32,-(a7)
	move.w	d7,-(a7)
	move.w	#$3f,-(a7)
	trap	#1		; read first 32 bytes
	lea	12(a7),a7

	bsr	close


* now get all data for RAM disk from file
	lea	store(pc),a0
	cmp.b	#"~",(a0)+
	bne	no_file		; branch if first char is NOT a ~

	moveq	#0,d0
	move.b	(a0)+,d0	; drive letter

	or.b	#$20,d0
	sub.b	#"a",d0
	bmi.s	file_err
	cmp.b	#$f,d0
	bhi.s	file_err

	move.w	d0,drv_no

	lea	string(pc),a1
	pea	(a1)
	pea	(a1)
trans_size:
	move.b	(a0)+,(a1)+
	cmp.b	#13,-1(a1)
	bne.s	trans_size

	clr.b	-1(a1)

	move.l	(a7)+,a0
	bsr	chk_all
	dbra	d0,chk_file_good

file_err:
	addq.l	#4,a7
	move.b	#"n",file
	lea	file_e(pc),a0
	bsr	print_mes
	bra	no_file

chk_file_good:
	move.l	(a7)+,a0
	bsr	dec_bin

	move.w	d0,ram_size
	move.b	#"y",file
	bra	auto_rej

open:
	move.w	#2,-(a7)
	pea	(a0)
	move.w	#$3d,-(a7)
	trap	#1
	addq.l	#8,a7
	rts

close:
	move.w	d7,-(a7)
	move.w	#$3e,-(a7)
	trap	#1
	addq.l	#4,a7
	rts


not_auto_load:
* option selected from menu
	cmp.w	#3,aintout
	beq	terminate2

	cmp.w	#1,aintout
	beq	size_loop

* configure
	move.l	$c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	add.l	#$100,d0
	move.l	d0,-(a7)
	move.l	a5,-(a7)
	clr.w	-(a7)
	move.w	#$4a,-(a7)
	trap	#1
	lea	12(a7),a7

	moveq	#1,d1
	move.b	proof_flag,d0
	sub.b	#"y",d0
	beq.s	yes_proof

	moveq	#2,d1

yes_proof:
	move.l	#proof,addrin
	move.w	d1,aintin
	bsr	aes

	move.b	#"y",proof_flag
	cmp.w	#1,aintout
	beq.s	yes_again

	move.b	#"n",proof_flag
	move.b	#"n",boot_flag
	bra	dun_opts

yes_again:
	moveq	#1,d1
	move.b	boot_flag,d0
	sub.b	#"y",d0
	beq.s	yes_boot

	moveq	#2,d1

yes_boot:
	move.l	#boot,addrin
	move.w	d1,aintin
	bsr	aes

	move.b	#"y",boot_flag
	cmp.w	#1,aintout
	beq	boot_again

	move.b	#"n",boot_flag
boot_again:
dun_opts:
* got flags ok

	lea	my_name(pc),a0
open_me:
	bsr	open
	move.w	d0,d7
	bpl	me_here		; branch if can't find me!

* can't find me!
	move.l	#missing,addrin
	move.w	#1,aintin
	bsr	aes

	cmp.w	#2,aintout
	beq	terminate2

* option to use path name
set_name:
	move.w	#$19,-(a7)
	trap	#1
	addq.l	#2,a7
	move.b	d0,path




	lea	ctrl(pc),a0
	move.w	#90,(a0)+
	clr.w	(a0)+
	move.l	#$00020002,(a0)+
	clr.w	(a0)+

	move.l	#path,addrin
	move.l	#file_name,addrin+4

	bsr	aes
* done file selector

	cmp.l	#$00010001,aintout
	bne	terminate2

	moveq	#0,d0
	move.b	path,d0
	sub.b	#"A",d0
	move.w	d0,-(a7)
	move.w	#$e,-(a7)
	trap	#1		; set drive
	addq.l	#4,a7

	lea	path(pc),a0
get_z:
	tst.b	(a0)+
	bne.s	get_z

get_s:
	cmp.b	#"\",-(a0)
	bne.s	get_s

	addq.l	#1,a0
	move.b	(a0),-(a7)
	move.l	a0,-(a7)
	clr.b	(a0)

	pea	path+2(pc)
	move.w	#$3b,-(a7)
	trap	#1		; set pathname
	addq.l	#6,a7

	move.l	(a7)+,a0
	move.b	(a7)+,(a0)

	lea	ctrl(pc),a0
	move.w	#52,(a0)+
	move.l	#$00010001,(a0)+
	move.l	#$00010000,(a0)+

	lea	path(pc),a1
	lea	new_name(pc),a0

get_end_path:
	move.b	(a1)+,(a0)+
	bne.s	get_end_path

get_slash2:
	cmp.b	#"\",-(a0)
	bne.s	get_slash2

	addq.l	#1,a0
	lea	file_name(pc),a2
copy_name:
	move.b	(a2)+,(a0)+
	bne.s	copy_name

	lea	new_name(pc),a0
	bra	open_me

me_here:
	move.w	#1,-(a7)
	move.w	d7,-(a7)
	move.l	#$1c,-(a7)
	move.w	#$42,-(a7)
	trap	#1		; move $1c bytes in
	lea	10(a7),a7

	pea	star(pc)
	pea	6.w
	move.w	d7,-(a7)
	move.w	#$3f,-(a7)
	trap	#1
	lea	12(a7),a7
	cmp.l	#6,d0
	bne	file_error

	cmp.l	#"GBD!",flag
	bne	file_error

	pea	proof_flag(pc)
	pea	2.w
	move.w	d7,-(a7)
	move.w	#$40,-(a7)
	trap	#1		; write new flags
	lea	12(a7),a7

	tst.l	d0
	bmi	file_error

	bsr	close

	bra	terminate2

file_error:
	bsr	close

	move.l	#ferr,addrin
	move.w	#1,aintin
	bsr	aes

	cmp.w	#1,aintout
	beq	set_name
	bra	terminate2


no_file:
size_loop:
	move.w	max_k,d0
	bsr	bin_dec

	pea	(a0)
	lea	max(pc),a0
	bsr	print_mes
	move.l	(a7)+,a0
	bsr	print_mes
	lea	max2(pc),a0
	bsr	print_mes

	lea	get_siz(pc),a0
	bsr	print_mes

	pea	size(pc)
	move.w	#10,-(a7)
	trap	#1		; get size
	addq.l	#6,a7

	tst.w	d0
	beq	no_inp

* check for all digits!
	lea	size+2(pc),a0
	clr.b	(a0,d0.w)
	bsr	chk_all

	dbra	d0,chk_good

	lea	digits(pc),a0
	bsr	print_mes

	bra	size_loop

chk_good:
	lea	size+2(pc),a0
	bsr	dec_bin

auto_rej:
	tst.w	d0
	beq	no_inp

	move.w	d0,ram_size

	move.w	max_k,d1
	sub.w	d0,d1
	bpl.s	size_valid

* size too big
	lea	big(pc),a0
	bsr	print_mes
	bra	size_loop


size_valid:
* now get the drive letter
	cmp.b	#"y",file
	beq	file_drv

	lea	drives(pc),a0
	bsr	print_mes

	lea	get_drv(pc),a0
	bsr	super
	move.l	d0,d7

	moveq	#0,d6

show_drvs:
	move.b	#"A",d0
	add.b	d6,d0

	move.w	d0,-(a7)

	btst	d6,d7
	beq.s	no_drv

* drive for this letter
	lea	inv_on(pc),a0
	bsr	print_mes

no_drv:
	move.w	#2,-(a7)
	trap	#1
	addq.l	#4,a7

	lea	inv_off(pc),a0
	bsr	print_mes

	addq.w	#1,d6
	and.w	#$f,d6
	bne.s	show_drvs

	lea	new_line(pc),a0
	bsr	print_mes

	move.w	#1,-(a7)
	trap	#1		; get drive letter
	addq.l	#2,a7

	cmp.b	#$1b,d0
	beq	no_inp

	or.b	#$20,d0
	sub.b	#"a",d0
	bmi.s	drv_nono

	cmp.b	#15,d0
	ble.s	drv_ok
drv_nono:
* invalid drive letter
	move.b	#"n",file

	lea	inval(pc),a0
	bsr	print_mes
	bra	size_valid

file_drv:
	move.w	drv_no,d0
drv_ok:
* drive ok
	move.w	d0,drv_no

	lea	install(pc),a0
	bsr	super

* now clear bootsector FATS etc

	lea	boot_sec(pc),a0
	move.w	#11*1024/4-1,d0
clr:
	clr.l	(a0)+
	dbra	d0,clr


* now terminate, leaving space for RAM disk!

	lea	inst(pc),a0
	bsr	print_mes

	move.w	ram_size,d0
	bsr	bin_dec
	bsr	print_mes

	move.w	drv_no,d0
	add.b	#"A",d0
	move.b	d0,drv_let

	lea	as(pc),a0
	bsr	print_mes

	cmp.b	#"n",proof_flag
	bne.s	yyy

	lea	not(pc),a0
	bsr	print_mes
yyy:
	lea	reset(pc),a0
	bsr	print_mes

	cmp.b	#"n",boot_flag
	bne.s	yyyy

	lea	not(pc),a0
	bsr	print_mes
yyyy:
	lea	bboot(pc),a0
	bsr	print_mes


	cmp.b	#"y",auto
	beq.s	no_wait

	move.w	#7,-(a7)
	trap	#1
	addq.l	#2,a7
no_wait:

	clr.w	-(a7)

	moveq	#0,d0
	move.w	ram_size,d0
	lsl.l	#8,d0
	add.l	d0,d0
	add.l	d0,d0
	add.l	#boot_sec-star+$100,d0
	add.l	#11*1024,d0		; dir FATs etc
	move.l	d0,-(a7)
	move.w	#$31,-(a7)
	trap	#1


present:
	move.l	phystop.w,a0
	move.l	2(a0),d0
	rts


chk_all:
	move.b	(a0)+,d0
	beq.s	all_chked

	cmp.b	#"0",d0
	blo.s	not_digit

	cmp.b	#"9",d0
	bhi.s	not_digit

	bra.s	chk_all

not_digit:
	moveq	#0,d0
	rts
all_chked:
	moveq	#1,d0
	rts

install:
	lea	drv_no(pc),a0
	move.w	(a0),d0
	lea	my_bpb(pc),a0
	move.w	d0,2(a0)
	lea	my_med(pc),a0
	move.w	d0,2(a0)
	lea	my_rw(pc),a0
	move.w	d0,2(a0)
	lea	changed(pc),a0
	move.w	d0,(a0)

* create bpb
	lea	ram_size(pc),a0
	lea	bpb_size(pc),a1
	move.w	(a0),(a1)
	addq.w	#2,(a1)


vectors:
	lea	bpb_to(pc),a0
	move.l	hdv_bpb.w,2(a0)
	lea	rw_to(pc),a0
	move.l	hdv_rw.w,2(a0)
	lea	med_to(pc),a0
	move.l	hdv_med.w,2(a0)

	lea	my_rw(pc),a0
	move.l	a0,hdv_rw.w

	lea	my_med(pc),a0
	move.l	a0,hdv_med.w

	lea	my_bpb(pc),a0
	move.l	a0,hdv_bpb

	lea	proof_flag(pc),a1
	cmp.b	#"y",(a1)+
	bne.s	no_reset


	lea	reset_to(pc),a0
	move.l	res_vec.w,(a0)

	lea	reset_maj(pc),a0
	move.l	res_val.w,(a0)

	move.l	#$31415926,res_val.w

	lea	my_reset(pc),a0
	move.l	a0,res_vec.w

no_reset:
* set drive bit!
	lea	drv_no(pc),a0
	move.w	(a0),d0
	move.l	drv_bits.w,d1
	bset	d0,d1
	move.l	d1,drv_bits.w


	cmp.b	#"y",(a1)
	bne.s	no_bootdrv

	move.w	d0,bootdev.w
no_bootdrv:
	rts


my_reset:
* jumps here on reset
	lea	reset_maj(pc),a0
	move.l	(a0),res_val

	lea	reset_to(pc),a0
	move.l	(a0),res_vec	; reset vector as we found it!

	lea	first(pc),a0
	cmp.b	#"y",(a0)
	bne	other_resets	; don't copy above memory if not first reset

* copy above phystop etc etc
	move.b	#"n",(a0)

	move.l	phystop.w,d0	; get current phystop
	move.l	d0,a3

	lea	ram_size(pc),a0
	moveq	#0,d1
	move.w	(a0),d1
	lsl.l	#8,d1
	lsl.l	#2,d1		; get size in bytes of RAM disk

	add.l	#boot_sec-star+$100,d1
	add.l	#11*1024,d1	; dir FATs etc
	add.l	#511,d1
	and.w	#$fe00,d1	; ensure 1/2 K boundary at least!

	sub.l	d1,d0
	move.l	d0,phystop.w	; shrink memory
	move.l	d0,a0		; a0 = where to shove everything

* now ensure there are no reset - proof proggys in area I am about to overwrite!

	move.l	a0,a1
	move.l	a0,a2
	sub.l	#$8600,a1	; a1 = where to start putting them

chk_res:
	cmp.w	#$1212,(a1)
	bne.s	nnot_here

* found reset-proof prog

	movem.l	a2/a1,-(a7)
	move.w	#512/4-1,d0
shft:
	move.l	(a1)+,(a2)+
	dbra	d0,shft

	movem.l	(a7)+,a2/a1
	lea	-1024(a1),a1

nnot_here:
	lea	512(a1),a1
	cmp.l	a1,a3
	bne.s	chk_res

* any reset resident progs have now been shifted to safe areas

* shove all my stuff into memory at a0!
	lea	star(pc),a1
	move.l	d1,d0



	move.l	a0,a3

	add.l	d0,a1
	add.l	d0,a0
	lsr.l	#5,d0		; divide d2 by 32

shft2:
	lea	-32(a1),a1
	movem.l	(a1),d1-d7/a4
	movem.l	d1-d7/a4,-(a0)
	subq.l	#1,d0
	bne.s	shft2

	lea	install(pc),a0
	lea	star(pc),a1
	sub.l	a1,a0		; get install as relative addr

	add.l	a3,a0		; add phystop for abs

	lea	res2_to(pc),a2
	move.l	a0,2(a2)
	bra	dun_first

other_resets:

	lea	install(pc),a0
	lea	res2_to(pc),a1
	move.l	a0,2(a1)

dun_first:
	not.w	$ffff8240
	move.l	phystop.w,a0
	sub.l	#$8600,a0

get_free:
	cmp.w	#$1212,(a0)
	bne.s	got_free

	lea	-512(a0),a0
	bra.s	get_free

got_free:
* copy reset resident proggy
	lea	res2(pc),a1
	move.l	a0,a2

	move.l	#$12123456,(a0)+
	move.l	a2,(a0)+
	move.w	#rout_len/2-1,d0
shft3:
	move.w	(a1)+,(a0)+
	dbra	d0,shft3

	move.w	#$f00,$ffff8240

	moveq	#0,d0
	move.w	#$fe,d1
sum:
	add.w	(a2)+,d0
	dbra	d1,sum

	move.w	#$5678,d1
	sub.w	d0,d1
	move.w	d1,(a2)

	jmp	(a6)

reset_maj:
	ds.l	1
reset_to:
	ds.l	1
first:
	dc.b	"y"
	even

res2:
	lea	res2(pc),a0
	clr.l	-8(a0)		; take out magic number

res2_to:
	jmp	0.l
end_res:
rout_len	equ	end_res-res2


my_rw:
	cmp.w	#0,14(a7)
	beq.s	yes_rw

rw_to:
	jmp	0.l

yes_rw:
	lea	store(pc),a0
	movem.l	d1-d7/a0-a3,(a0)

	moveq	#0,d0
	move.w	12(a7),d0	; rec no
	lsl.l	#8,d0
	add.l	d0,d0		; x 512

	lea	boot_sec(pc),a3
	add.l	d0,a3

	move.l	6(a7),a1	; buffer

	move.w	a1,d0
	btst	#0,d0
	bne	odd_rw		; branch if odd addr in memory!!!

	move.w	10(a7),d0	; no of secs
	subq.w	#1,d0		; - 1

	move.w	4(a7),d1

	btst	#0,d1
	beq.s	reading

	exg.l	a3,a1
reading:
mov	macro
	movem.l	(a3)+,d1-d7/a2
	movem.l	d1-d7/a2,\1(a1)
	endm

	mov	0
	mov	32
	mov	64
	mov	96
	mov	128
	mov	160
	mov	192
	mov	224
	mov	256
	mov	288
	mov	320
	mov	352
	mov	384
	mov	416
	mov	448
	mov	480

	lea	512(a1),a1

	dbra	d0,reading

	moveq	#0,d0
	movem.l	(a0),a1-a3/d1-d7

	rts

odd_rw:
	move.w	10(a7),d0	; no of secs
	subq.w	#1,d0		; - 1

	move.w	4(a7),d1

	btst	#0,d1
	beq.s	reading2

	exg.l	a3,a1
reading2:
	move.w	#512-1,d2
do_odd:
	move.b	(a3)+,(a1)+
	dbra	d2,do_odd

	dbra	d0,reading2

	moveq	#0,d0
	movem.l	(a0),a1-a3/d1-d7

	rts

my_bpb:
	cmp.w	#0,4(a7)
	beq.s	yes_bpb

bpb_to:
	jmp	0.l

yes_bpb:
	lea	bpb(pc),a0
	move.l	a0,d0
	rts

my_med:
	cmp.w	#0,4(a7)
	beq.s	yes_med
med_to:
	jmp	0.l

yes_med:
	lea	changed(pc),a0
	move.w	(a0),d0
	clr.w	(a0)
	rts



get_drv:
	move.l	drv_bits.w,d0
	rts

super:
	pea	(a0)
	move.w	#38,-(a7)
	trap	#14
	addq.l	#6,a7
	rts


dec_bin:
	moveq	#0,d0
	moveq	#0,d1

do_dec:
	move.b	(a0)+,d1
	beq.s	end_dec

	sub.b	#"0",d1
	bmi.s	end_dec

	cmp.b	#9,d1
	bhi.s	end_dec

	mulu	#10,d0
	add.w	d1,d0
	bra.s	do_dec

end_dec:
	rts


bin_dec:
	clr.b	-(a7)

	swap	d0
	clr.w	d0
	swap	d0

	tst.w	d0
	beq	zero

more_bin:
	divu	#10,d0
	swap	d0
	add.b	#"0",d0
	move.b	d0,-(a7)
	clr.w	d0
	swap	d0
	tst.w	d0
	bne.s	more_bin

	bra.s	put_string
zero:
	move.b	#"0",-(a7)

put_string:
	lea	string(pc),a0
pstring:
	move.b	(a7)+,(a0)+
	bne.s	pstring

	lea	string(pc),a0

	rts

print_mes:
	pea	(a0)
	dc.w	$a00a
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	dc.w	$a009
	rts

aes:
	move.l	#apb,d1
	move.w	#$c8,d0
	trap	#2
	rts

jim:
	dc.b	27,"E"
	dc.b	27,"p"
	dc.b	"**************************",10,13
	dc.b	"*           THE          *",10,13
	dc.b	"*       GINGER BREAD     *",10,13
	dc.b	"*         RAM DISK       *",10,13
	dc.b	"*  by James Ingram, 1992 *",10,13
	dc.b	"**************************",10,13
	dc.b	27,"q",10
	dc.b	"Hold down CONTROL to abort",10,13,10
	dc.b	0
max:
	dc.b	"Maximum amount of memory for RAM disk:",10,13
	dc.b	0
max2:
	dc.b	"K",10,13,10,0
get_siz:
	dc.b	"Please enter amount you require:",10,13,0
digits:
	dc.b	10,13,"Please enter only numbers!!",10,13,10,0
big:
	dc.b	10,13,"Disk size is too big!",10,13
	dc.b	"Please re-select...",10,13,10,0
inval:
	dc.b	10,13,"Invalid drive letter.",10,13,10,0
file_e:
	dc.b	10,13,"Error in BOOTUP.DAT",10,13,10,0
bootup:
	dc.b	"BOOTUP.DAT",0
inst:
	dc.b	10,13,0
as:
	dc.b	"K RAM disk has been installed",10,13
	dc.b	"as drive "
drv_let:
	dc.b	"X.",10,13
	dc.b	"Will ",0
not:
	dc.b	"NOT ",0

reset:
	dc.b	"be reset proof.",10,13
	dc.b	"Will ",0
bboot:
	dc.b	"boot from RAM disk",10,13,10,0


abort:
	dc.b	27,"pCONTROL pressed.",27,"q",10,13,10,0
here_flag:
	dc.b	"n"
here:
	dc.b	"The GINGER BREAD RAM DISK",10,13
	dc.b	"is installed already!",10,13,10,0
intro:
	dc.b	"[0][Ginger Bread Options  ]"
	dc.b	"[Install|Config|Quit]",0
proof:
	dc.b	"[0][Reset proof?  ]"
	dc.b	"[Yes|No]",0
boot:
	dc.b	"[0][Boot from RAM ?  ]"
	dc.b	"[Yes|No]",0
missing:
	dc.b	"[0][Cannot find myself!  ]"
	dc.b	"[Select|Cancel]",0
ferr:
	dc.b	"[0][Error writing options  ]"
	dc.b	"[Retry|Cancel]",0

drives:
	dc.b	10,13,"Please select a drive letter:"
new_line:
	dc.b	10,13,0
inv_on:
	dc.b	27,"p",0
inv_off:
	dc.b	27,"q",0
size:
	dc.b	10,0
	ds.b	10
my_name:
	dc.b	"RAM_DISK.PRG",0

auto:
	ds.b	1
file:
	ds.b	1
	even

bpb:
	dc.w	$200,2,$400,7,5,6,18
bpb_size:
	dc.w	1
	ds.l	4

apb:
	dc.l	ctrl,global,aintin,aintout,addrin,addrout

	section	bss
path:
	ds.b	128
file_name:
	ds.b	14
new_name:
	ds.b	128

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

max_k:
	ds.w	1
ram_size:
	ds.w	1
drv_no:
	ds.w	1
changed:
	ds.w	1

string:
	ds.b	10
store:
	ds.b	32
boot_sec:

