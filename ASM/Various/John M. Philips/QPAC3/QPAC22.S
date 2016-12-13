	format	0-,1-,2-
	list	+
* QPAC : quick file packer v2.2
* with turbo string search
	list	-

test_version equ 0

*--------------------------------------------------------------
* packed file format:
*
* the packed file consists of a 24 byte header + packed bit-streamed data
*
* header:
*	dc.b	'QPACbyJMP(c)1989'
*	dc.l	length of unpacked file
*	dc.l	checksum of unpacked file (=XOR of dest bytes)
* bit-streamed data:
* %00nnn			insert next 1..8 bytes
* %01aaaaaa,%aa			copy 2 bytes from ptr-(1..256)
* %100aaaaa,%aaaa		copy 3 bytes from ptr-(=1..512)
* %101aaaaa,%aaaaa		copy 4 bytes from ptr-(=1..1024)
* %110nnnnn,%nnnaaaaa,%aaaaaaa	copy 3..258 bytes from ptr-(1..4096)
* %111nnnnn,%nnn		insert next 9..264 bytes
*
*--------------------------------------------------------------

	ifne	test_version
	opt	x+
	endc

sec	macro
	ori	#1,ccr
	endm
clc	macro
	andi	#~1,ccr
	endm

	section	bss

stack	ds.l	256
stack_end

counts ds.w 65536	counters for no. of occurrences of each possible
*			byte-pair within the last 1024 bytes scanned
*			(also used for finding least common byte)

error_sp ds.l	1

command_line ds.l 1

input_buffer ds.b 64+1+1
	even

	section	data

demo_file dc.b	.end-.start
.start	dc.b	'd:\packers\packer.s'
.end	dc.b	0,0,0,0

header_name dc.b 'QPAC2-JMP(C)1989'
	even

	section	text

	move.l	4(sp),a3	standard header
	move.l	$C(a3),d0
	add.l	$14(a3),d0
	add.l	$1C(a3),d0
	add.l	#$100,d0
	lea	stack_end,sp
	move.l	d0,-(sp)
	move.l	a3,-(sp)

	ifeq	test_version
	add.w	#128,a3
	move.l	a3,command_line
	elseif
	move.l	#demo_file,command_line
	endc

	clr.w	-(sp)
	move.w	#$4A,-(sp)
	trap	#1
	add.l	#12,sp
	bsr	setup_screen
	bsr	start
exit	clr.w	-(sp)
	move.w	#$4C,-(sp)
	trap	#1

start	move.l	sp,error_sp		save error stack
	bsr	make_turbo_search
	move.l	command_line,a0
	tst.b	(a0)
	beq	load_error
	moveq	#0,d0
	move.b	(a0)+,d0
	clr.b	(a0,d0.w)
	move.l	a0,command_line
	bsr	get_file
	bcs	load_error
	move.l	a0,source_ptr
	move.l	d0,source_size
	add.l	d0,a0
	move.l	a0,source_end
	lea	title,a0
	bsr	print_string
	move.l	command_line,a0
	bsr	print_string
	lea	title2,a0
	bsr	print_string
	move.l	source_size,d0
	add.l	#1024,d0
	bsr	alloc
	bcs	memory_error
	move.l	a0,dest_ptr
	move.l	d0,dest_size
	add.l	d0,a0
	move.l	a0,dest_end
	bsr	pack_file
done	bcs	abort_error
	lea	time_mess,a0
	bsr	print_string
	moveq	#0,d0
	move.w	d7,d0
	bsr	print_number
	lea	time_mess2,a0
	bsr	print_string
	move.l	dest_ptr,a0
	move.l	dest_size,d0
	move.l	source_ptr,a1
	bsr	unpack_file
undone	tst.w	d0
	bne	expand_error
	lea	perc_mess,a0
	bsr	print_string
	move.l	dest_size,d0
	mulu	#100,d0
	move.l	source_size,d1
.ld	cmp.l	#65536,d1
	bcs.s	.sd
	lsr.l	#1,d0
	lsr.l	#1,d1
	bra.s	.ld
.sd	divu	d1,d0
	cmp.w	#100,d0
	bls.s	.ok
	move.w	#100,d0
.ok	and.l	#$FFFF,d0
	bsr	print_number
	lea	perc_mess2,a0
	bsr	print_string
.wait	bsr	get_key
	beq.s	.wait
	cmp.b	#'Y',d0
	bne	quit
	lea	perc_mess3,a0
	bsr	print_string
	move.b	#64,input_buffer
	pea	input_buffer
	move.w	#$0A,-(sp)
	trap	#1
	addq.l	#6,sp
	tst.b	input_buffer+1
	beq.s	.qp2
	lea	input_buffer+2,a0
	moveq	#0,d0
	move.b	input_buffer+1,d0
	clr.b	(a0,d0.w)
	move.l	a0,command_line
	bra.s	.put
.qp2	move.l	command_line,a0
	clr.l	d7
.qp2b	move.b	(a0)+,d0
	beq.s	.qp2c
	cmp.b	#'.',d0
	bne.s	.qp2b
	move.l	a0,d7
	bra.s	.qp2b
.qp2c	tst.l	d7
	beq.s	.qp2d
	move.l	d7,a0
.qp2d	subq.w	#1,a0
	move.b	#'.',(a0)+
	move.b	#'Q',(a0)+
	move.b	#'P',(a0)+
	move.b	#'2',(a0)+
	clr.b	(a0)+
.put	move.l	command_line,a0
	move.l	dest_ptr,a1
	move.l	dest_size,d0
	bsr	put_file
	bcs	save_error
	rts

save_error
	lea	save_mess,a0
	bra.s	exit_fail
memory_error
	lea	memory_mess,a0
	bra.s	exit_fail
load_error
	lea	load_mess,a0
	bra.s	exit_fail
expand_error
	lea	expand_mess,a0
	bra.s	exit_fail
abort_error
	lea	abort_mess,a0
	bra.s	exit_fail
overflow_error
	lea	overflow_mess,a0
exit_fail
	move.l	error_sp,sp
	bsr	print_string
	lea	key_mess,a0
	bsr	print_string
.wait	bsr	get_key
	beq.s	.wait
quit	rts

title	dc.b	27,'E',27,'f'
	dc.b	'QPAC2 by JMP (C) 9th Aug 1989',13,10,13,10
	dc.b	'Source file:',0
title2	dc.b	27,'Y',' '+4,' '
	dc.b	'Source          ',13,10,13,10
	dc.b	'Reading         ',13,10,13,10
	dc.b	'Writing         ',13,10,13,10
src_tab	dc.b	27,'Y',' '+4,' '+8,0
rd_tab	dc.b	27,'Y',' '+6,' '+8,0 
wr_tab	dc.b	27,'Y',' '+8,' '+8,0
	even
src_row	equ	(5*8+3)*160
rd_row	equ	(7*8+3)*160
wr_row	equ	(9*8+3)*160

time_mess
	dc.b	27,'Y',' '+11,' '
	dc.b	'Time taken = ',0
time_mess2
	dc.b	' seconds',13,10,0

perc_mess
	dc.b	'Packed to ',0
perc_mess2
	dc.b	'% of original',13,10,13,10
	dc.b	'Save file (Y)es or (N)o',0
perc_mess3
	dc.b	13,10,13,10,'Press RETURN to save .QP2 file',13,10
	dc.b	'or enter new filename',13,10,13,10
	dc.b	'?',0

abort_mess
	dc.b	27,'Y',' '+11,' ','Aborted',0
overflow_mess
	dc.b	27,'Y',' '+11,' ','Packed file longer than original',0
expand_mess
	dc.b	13,10,'Packed file failed to unpack',0
load_mess
	dc.b	27,'E',27,'f','Error while loading source file',0
memory_mess
	dc.b	27,'E',27,'f','Insufficient memory for packing',0
save_mess
	dc.b	27,'E',27,'f','Error while saving file',0
key_mess
	dc.b	13,10,'press any key to exit',0
	even

source_ptr dc.l 0	ptrs to files
source_end dc.l 0
source_size dc.l 0

dest_ptr dc.l 0
dest_end dc.l 0
dest_size dc.l 0

com00	dc.l	0
com01	dc.l	0
com100	dc.l	0
com101	dc.l	0
com110	dc.l	0
com111	dc.l	0

* pack file
* entry	source_ptr/end/size,dest_ptr
* exit	dest_end/size
*	carry set if aborted by key press
*	d7=time taken (in seconds)

pack_file
	bsr	setup_irq
	clr.l	print_timer		reset timer
	lea	counts,a0		clear counters
	move.w	#65536/8-1,d0		for 65536 pair counts
	moveq	#0,d1
.wipe	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	dbra	d0,.wipe
	move.l	dest_ptr(pc),a6		a6=destination
	lea	header_name(pc),a0
	move.l	(a0)+,(a6)+		insert id
	move.l	(a0)+,(a6)+
	move.l	(a0)+,(a6)+
	move.l	(a0)+,(a6)+
	move.l	source_size(pc),(a6)+	insert unpacked size
	clr.l	(a6)+			skip checksum
	lea	counts,a5		a5=counters
	move.l	source_ptr(pc),a0	a0=source
	moveq	#1,d7			d7=destination long
	moveq	#0,d6			d6=checksum
	move.l	a0,a4			a4=ptr to last un-saved byte
	moveq	#0,d5			d5=no. of un-saved bytes

	movem.l	d0-d7/a0-a6,-(sp)
	lea	src_tab,a0
	bsr	print_string
	move.l	source_size,d0
	bsr	print_number
	move.l	source_size,d6
	move.w	#src_row,d7
	bsr	print_bar
	movem.l	(sp)+,d0-d7/a0-a6
	bsr	print_status
	move.w	#50,print_counter

.loop	moveq	#0,d0			if possible string copy then
	movep.w	(a0),d0
	move.b	1(a0),d0
	add.l	d0,d0
	tst.w	(a5,d0.l)
	beq	.no_string
	bsr	search_for_string	search for copy
	bcc	.no_string		if copy then save insert
.save	bsr	put_insert
	tst.w	d5			(may require multiple save)
	bne.s	.save
	movem.w	string_offset,d2-d4	get offset,size,type
	subq.w	#1,d2			size-1 for range 0..255/../4095
	cmp.w	#1,d4			save according to size
	bcs.s	.copy2
	beq.s	.copy3
	cmp.w	#2,d4
	beq.s	.copy4
	bra.s	.copy_big
.copy2
	addq.l	#1,com01

	moveq	#%01,d0			2 bytes : %01aaaaaaaa
	moveq	#2-1,d1
	bsr	put_bits
	move.w	d2,d0
	bsr	put_byte
	move.w	d3,d0
	bra	.update_after_copy
.copy3
	addq.l	#1,com100

	moveq	#%100,d0		3 bytes : %100aaaaaaaaa
	moveq	#3-1,d1
	bsr	put_bits
	move.w	d2,d0
	moveq	#9-1,d1	
	bsr	put_bits
	move.w	d3,d0
	bra	.update_after_copy
.copy4
	addq.l	#1,com101

	moveq	#%101,d0		4 bytes : %101aaaaaaaaaa
	moveq	#3-1,d1
	bsr	put_bits
	move.w	d2,d0
	moveq	#10-1,d1	
	bsr	put_bits
	move.w	d3,d0
	bra	.update_after_copy
.copy_big

	addq.l	#1,com110

	moveq	#%110,d0	3..258 bytes : %110nnnnnnnnaaaaaaaaaaaa
	moveq	#3-1,d1
	bsr	put_bits
	move.w	d3,d0
	subq.w	#3,d0
	bsr	put_byte
	move.w	d2,d0
	moveq	#12-1,d1	
	bsr	put_bits
	move.w	d3,d0
	bra	.update_after_copy

.no_string
	addq.w	#1,d5			if no copy then insert byte
	cmp.w	#264,d5			if full then save insert
	bcs.s	.nos2
	bsr	put_insert
.nos2	moveq	#1,d0			update 1 byte
	bra.s	.update

.update_after_copy
	lea	(a0,d0.w),a4		reset un-saved ptr if copy
*					then update d0 bytes
.update	lea	-4096(a0),a1		un-count pair at tail
	cmp.l	source_ptr(pc),a1
	bcs.s	.up3
	moveq	#0,d1
	movep.w	(a1),d1			get byte pair
	move.b	1(a1),d1
	add.l	d1,d1
	subq.w	#1,(a5,d1.l)
.up3	addq.w	#1,a0
	cmp.l	source_end(pc),a0	if end of source then done
	beq.s	.done
	lea	-2(a0),a1		count pair at head
	cmp.l	source_ptr(pc),a1
	bcs.s	.up4
	moveq	#0,d1			
	movep.w	(a1),d1			get byte pair
	move.b	1(a1),d1
	add.l	d1,d1
	addq.w	#1,(a5,d1.l)
.up4	subq.w	#1,d0
	bne.s	.update			for each byte

	tst.w	print_counter		every second
	bne	.loop
	move.w	#50,print_counter
	bsr	print_status		print status
	bcc	.loop			abort if key press
	bsr	cancel_irq
	sec
	rts

.done	bsr	put_insert		save any unsaved bytes
	tst.w	d5
	bne.s	.done
	moveq	#4-1,d2			pad with 32 bits to ensure
.last	moveq	#0,d0			final long stored
	bsr	put_byte
	dbra	d2,.last
	move.l	dest_ptr,a5
	move.l	d6,20(a5)		store checksum
	move.l	a6,dest_end
	move.l	a6,d0
	sub.l	a5,d0
	move.l	d0,dest_size
	movem.l	d0-d7/a0-a6,-(sp)
	lea	wr_tab,a0
	bsr	print_string
	move.l	dest_size,d0
	bsr	print_number
	movem.l	(sp)+,d0-d7/a0-a6
	bsr	print_status
	bsr	cancel_irq
	move.l	print_timer,d7
	divu	#50,d7
	clc
	rts

* put 'insert' bytes
* entry	a4=ptr to start of string
*	d5=no. of bytes

put_insert
	tst.w	d5
	beq.s	.skip
	cmp.w	#9,d5		if 1..8 bytes then small insert
	bcc.s	.big
	move.w	d5,d0
	subq.w	#1,d0			%00nnn + bytes

	addq.l	#1,com00

	moveq	#5-1,d1
	bsr	put_bits
.small	move.b	(a4)+,d0
	bsr	put_byte
	subq.w	#1,d5
	bne.s	.small
.skip	rts
.big
	addq.l	#1,com111

	moveq	#%111,d0	else big insert (9..264 bytes)
	moveq	#3-1,d1			%111nnnnnnnn
	bsr	put_bits
	move.w	d5,d2
	cmp.w	#264,d2
	bcs.s	.big2
	move.w	#264,d2
.big2	subq.w	#1,d2
	move.w	d2,d0
	subq.w	#8,d0
	bsr	put_byte
.big3	move.b	(a4)+,d0
	bsr	put_byte
	subq.w	#1,d5
	dbra	d2,.big3
	rts

* put group of bits into dest
* entry	d7=current long (if 1 shifted out then store)
*	d6=checksum
*	a6=dest ptr
*	d0=bits to put
*	d1=bit count-1

put_byte
	cmp.l	#$01000000,d7	if 8 bits then quicker if long <24 bits
	bcc.s	.slow
	lsl.l	#8,d7
	move.b	d0,d7
	rts
.slow	moveq	#8-1,d1
put_bits
	eor.w	#15,d1		left justify
	lsl.w	d1,d0
	eor.w	#15,d1
.loop	add.w	d0,d0		get bit
	addx.l	d7,d7		put bit
	bcs.s	.save		if overflow then
	dbra	d1,.loop	next bit
	rts
.save	move.l	d7,(a6)+	save long
	cmp.l	dest_end(pc),a6	if dest file too big then abort
	bcc.s	.overflow
	eor.l	d7,d6		update checksum
	moveq	#1,d7		clear
	dbra	d1,.loop	next bit
	rts
.overflow
	bsr	print_status
	bsr	cancel_irq
	bra	overflow_error

* search for string copy
* entry	a0=source
*	a5=counts table
* exit	carry clear if no copy found
*	carry set if copy
*		string_offset = backward offset to string 1..4096
*		string_size   = size 2..258
*		string_saving = number of bits saved by packing
*		string_type   =	0 : 2 bytes in range 1..256
*				1 : 3 bytes in range 1..512
*				2 : 4 bytes in range 1..1024
*				3 : 3..258 bytes in range 1..4096
*	d5-d7/a4-a6 preserved

string_offset dc.w 0
string_size dc.w 0
string_type dc.w 0
string_saving dc.w 0		no. of bits saved by best choice

search_for_string
	lea	turbo_search,a2		quick search
	move.l	source_end(pc),d4	get bytes remaining
	sub.l	a0,d4			skip if <2
	cmp.l	#2,d4
	blt	.fail			d4=maximum size (up to 258)
	cmp.w	#258,d4
	bcs.s	.sok
	move.w	#258,d4
.sok	lea	-4096(a0),a3		get start of search area
	cmp.l	source_ptr(pc),a3	if <start then =start
	bcc.s	.ok
	move.l	source_ptr(pc),a3
.ok	move.l	a0,d3			d3=distance (1..4096)
	sub.l	a3,d3
	beq	.fail			skip if start of file
	clr.w	string_saving		clear bits saved
.search	move.b	(a0),d0			get first byte
	move.w	d3,d2			quick search
	add.w	d2,d2			jump to turbo_search+6*(4096-dist)
	add.w	d3,d2
	add.w	d2,d2
	neg.w	d2
	add.w	#6*4096,d2
	jsr	(a2,d2.w)
	bcc	.done			done if no match
	subq.w	#1,a3			adjust ptr
	move.l	a0,d3
	sub.l	a3,d3			recalculate distance
	move.b	1(a0),d0		quick skip if 2nd byte <>
	cmp.b	1(a3),d0
	bne	.next
	movem.l	a0/a3,-(sp)		save ptrs
	addq.w	#2,a0			skip 1st,2nd bytes
	addq.w	#2,a3
	moveq	#2,d2			count=2
	cmp.w	d4,d2
	beq.s	.end
.compare
	cmpm.b	(a0)+,(a3)+		compare
	bne.s	.end			if <> then exit
	addq.w	#1,d2			count+1
	cmp.w	d4,d2			loop if count<max
	bne.s	.compare
.end	movem.l	(sp)+,a0/a3		restore ptrs
	cmp.w	#3,d2			check if better then previous best
	bcs.s	.got_two
	beq.s	.got_three
	cmp.w	#4,d2
	beq.s	.got_four
	bra.s	.got_big
.got_two
	cmp.w	#256,d3			got 2 bytes
	bgt.s	.next			skip if >256 bytes away
	moveq	#6,d0			saves 6 bits
	moveq	#0,d1			type 0
	bra.s	.check_if_better
.got_three
	cmp.w	#512,d3			got 3 bytes
	bgt.s	.got_big		if >512 bytes away then big
	moveq	#12,d0			saves 12 bits
	moveq	#1,d1			type 1
	bra.s	.check_if_better
.got_four
	cmp.w	#1024,d3		got 4 bytes
	bgt.s	.got_big		if >1024 bytes away then big
	moveq	#19,d0			saves 19 bits
	moveq	#2,d1			type 2
	bra.s	.check_if_better
.got_big
	move.w	d2,d0			got big string
	lsl.w	#3,d0
	sub.w	#23,d0			saves 8*size-23 bits
	moveq	#3,d1			type 3
.check_if_better
	cmp.w	string_size,d0		skip if worse saving
	blt.s	.next
	move.w	d3,string_offset	save info
	move.w	d2,string_size
	move.w	d1,string_type
	move.w	d0,string_saving
	cmp.w	d4,d2			if size=max and max>=6 then
	bne.s	.next			search no further
	cmp.w	#6,d2
	bgt.s	.done
.next	addq.w	#1,a3			update ptr
	subq.w	#1,d3			distance-1
	bne	.search			if >0 then again

.done	tst.w	string_saving		if nothing found then fail
	beq.s	.fail
	sec
	rts
.fail	clc
	rts

	section	bss

turbo_search ds.b	4096*6+12
	even

	section	text

make_turbo_search
	lea	turbo_search,a0		make table of 4096 times
	move.w	#$6*4096+4-2,d0		cmp.b (a3)+, beq .found
	move.w	#4096-1,d1
	move.w	.compar,d2
	move.w	.branch,d3
.loop	move.w	d2,(a0)+
	move.w	d3,(a0)+
	move.w	d0,(a0)+
	subq.w	#6,d0
	dbra	d1,.loop
	lea	.fail,a1
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	rts

.compar	cmp.b	(a3)+,d0
.branch	beq	.found
.fail	clc
	rts
.found	sec
	rts

*--------------------------------------------------------------
* print status

print_timer dc.l 0
print_counter dc.w 0

old_vbl dc.l	0

setup_irq
	pea	.si2
	move.w	#38,-(sp)
	trap	#14
	addq.l	#6,sp
	rts
.si2	move.l	$70,old_vbl
	move.l	#my_vbl,$70
	rts

cancel_irq
	pea	.ci2
	move.w	#38,-(sp)
	trap	#14
	addq.l	#6,sp
	rts
.ci2	move.l	old_vbl,$70
	rts

my_vbl	addq.l	#1,print_timer
	tst.w	print_counter
	beq.s	.skip
	subq.w	#1,print_counter
.skip	move.l	old_vbl,-(sp)
	rts

screen_res dc.w	0
logbase	dc.l	0

setup_screen
	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	d0,screen_res
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,logbase
	rts

* print packing status
* exit	all registers preserved
*	carry set if key pressed

print_status
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	a0,a5			a5=source,a6=dest pointers
	move.l	a5,d6
	sub.l	source_ptr,d6
	move.w	#rd_row,d7
	bsr	print_bar
	move.l	a6,d6
	sub.l	dest_ptr,d6
	move.w	#wr_row,d7
	bsr	print_bar
	bsr	get_key			abort if key press
	beq.s	.no_key
	movem.l	(sp)+,d0-d7/a0-a6
	sec
	rts
.no_key	movem.l	(sp)+,d0-d7/a0-a6
	clc
	rts

print_string
	move.l	a0,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

get_key	move.w	#$0B,-(sp)
	trap	#1
	addq.l	#2,sp
	tst.w	d0
	beq.s	.no
	move.w	#$08,-(sp)
	trap	#1
	addq.l	#2,sp
	cmp.w	#'a',d0
	bcs.s	.no
	cmp.w	#'z'+1,d0
	bcc.s	.no
	and.w	#223,d0
.no	tst.w	d0
	rts

print_number
	movem.l	d0-d2/a0,-(sp)
	move.l	d0,d1
	bpl.s	.pos
	neg.l	d1		if -ve then make positive
	move.b	#'-',d0		and print -
	bsr	.char
.pos	clr.w	.count		clear char count
	lea	.powers,a0	for powers of ten 1000000000..1
.loop	move.l	(a0)+,d2	if end of list then done
	beq.s	.done
	move.b	#'0',d0		set char = 0
	cmp.l	d2,d1		if number<power then
	bge.s	.nozero			char = 0
	tst.w	.count			if not leading zero then print
	bne.s	.show
	cmp.l	#1,d2			if last char then print
	beq.s	.show
	bra.s	.next
.nozero	addq.w	#1,d0		if number>=power then
	sub.l	d2,d1			repeated subtraction
	bcc.s	.nozero
	subq.w	#1,d0			adjust for correct value
	add.l	d2,d1
.show	bsr	.char		print char
	addq.w	#1,.count	bump count
.next	bra.s	.loop		next power
.done	movem.l	(sp)+,d0-d2/a0
	rts

.char	movem.l	d0/a0,-(sp)
	move.w	d0,-(sp)
	move.w	#2,-(sp)
	trap	#1
	addq.l	#4,sp
	movem.l	(sp)+,d0/a0
	rts

.count	dc.w	0

.powers	dc.l	1000000000
	dc.l	100000000
	dc.l	10000000
	dc.l	1000000
	dc.l	100000
	dc.l	10000
	dc.l	1000
	dc.l	100
	dc.l	10
	dc.l	1
	dc.l	0

print_bar
	move.l	logbase,a0
	add.w	d7,a0
	cmp.w	#1,screen_res
	bcs	.low
	beq	.med
	bra	.hi

.low	rts

.med	mulu	#639,d6
	move.l	source_size,d5
.med_ld	cmp.l	#65536,d5
	bcs.s	.med_sd
	lsr.l	#1,d5
	lsr.l	#1,d6
	bra.s	.med_ld
.med_sd	divu	d5,d6
	cmp.w	#640,d6
	bcs.s	.med2
	move.w	#639,d6
.med2	move.w	#40-1,d7
	moveq	#-1,d5
	moveq	#0,d4
.med_loop
	cmp.w	#16,d6
	bgt.s	.med_fill
	tst.w	d6
	ble.s	.med_blank
	move.w	d6,d0
	subq.w	#1,d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.med_masks(pc,d0.w),(a0)+
	bra.s	.med_next
.med_blank
	move.l	d4,(a0)+
	bra.s	.med_next
.med_fill
	move.l	d5,(a0)+
.med_next
	sub.w	#16,d6
	dbra	d7,.med_loop
	move.w	#160/4-1,d7
.med_copy
	move.l	-160(a0),(a0)+
	dbra	d7,.med_copy
	rts

.med_masks
	dc.l	$80008000,$C000C000,$E000E000,$F000F000
	dc.l	$F800F800,$FC00FC00,$FE00FE00,$FF00FF00
	dc.l	$FF80FF80,$FFC0FFC0,$FFE0FFE0,$FFF0FFF0
	dc.l	$FFF8FFF8,$FFFCFFFC,$FFFEFFFE,$FFFFFFFF

.hi	rts

* unpack file

	include	qunpack.s


* get file
* entry	a0=filename
* exit	carry set if error
*	a0=address
*	d0=length

get_file
	move.l	a1,.addr		attempt to open file
	move.w	#0,-(sp)		READ ONLY
	move.l	a0,-(sp)
	move.w	#$3D,-(sp)
	trap	#1
	addq.l	#8,sp
	tst.l	d0			error ?
	bmi	.error
	move.w	d0,.handle
	move.w	#2,-(sp)		move file pointer to end
	move.w	.handle,-(sp)
	move.l	#0,-(sp)
	move.w	#$42,-(sp)
	trap	#1
	add.l	#10,sp			now D0=length of file
	move.l	d0,.length
	bsr	alloc			allocate memory
	bcc.s	.ok
	bsr	.close
	bra	memory_error
.ok	move.l	a0,.addr
	move.w	#0,-(sp)		move file pointer to start
	move.w	.handle,-(sp)
	move.l	#0,-(sp)
	move.w	#$42,-(sp)
	trap	#1
	add.l	#10,sp
	move.l	.addr,-(sp)		read file to address
	move.l	.length,-(sp)
	move.w	.handle,-(sp)
	move.w	#$3F,-(sp)
	trap	#1
	add.l	#12,sp
	bsr	.close
	move.l	.addr,a0
	move.l	.length,d0
	clc
	rts
.error	sec
	rts

.close	move.w	.handle,-(sp)		close file
	move.w	#$3E,-(sp)
	trap	#1
	addq.l	#4,sp
	rts

.addr	dc.l	0
.handle dc.w	0
.length dc.l	0

* put file
* entry	a0=filename
*	a1=address
*	d0=length
* exit	carry set if error

put_file
	move.l	a0,.name		save parameters
	move.l	a1,.addr
	move.l	d0,.length
	bsr	delete_file		delete if exists
	move.w	#0,-(sp)		CREATE new file
	move.l	.name,-(sp)
	move.w	#$3C,-(sp)
	trap	#1
	addq.l	#8,sp
	tst.l	d0			error ?
	bmi	.error
	move.w	d0,.handle
	move.w	#0,-(sp)		move file pointer to start
	move.w	.handle,-(sp)
	move.l	#0,-(sp)
	move.w	#$42,-(sp)
	trap	#1
	add.l	#10,sp
	move.l	.addr,-(sp)		write to file
	move.l	.length,-(sp)
	move.w	.handle,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	add.l	#12,sp
	move.l	d0,-(sp)
	move.w	.handle,-(sp)		close file
	move.w	#$3E,-(sp)
	trap	#1
	addq.l	#4,sp
	move.l	(sp)+,d0
	bmi	.error
	clc
	rts
.error	sec
	rts

.name	dc.l	0
.addr	dc.l	0
.handle	dc.w	0
.length	dc.l	0
	rts

* allocate memory
* entry	d0=amount
* exit	carry set if no room
*	a0=address
*	d0=amount

alloc	move.l	d0,.length
	move.l	d0,-(sp)
	move.w	#$48,-(sp)
	trap	#1
	addq.l	#6,sp
	tst.l	d0
	bmi.s	.error
	move.l	d0,a0
	move.l	.length,d0
	clc
	rts
.error	sec
	rts

.length	dc.l	0

* delete file
* entry	a0=filename terminated by 0
* exit	carry clear if deleted ok
*	carry set if error, d0=error code

delete_file
	move.l	a0,-(sp)
	move.w	#$41,-(sp)
	trap	#1
	add.l	#6,sp
	tst.l	d0
	bmi	.error
	clc
	rts
.error	sec
	rts

