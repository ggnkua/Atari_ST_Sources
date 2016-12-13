	format	0-,1-,2-
	list	+
* QPAC : quick file packer v3.2
* with offset table string search and executable header
	list	-

test_version equ 0

*--------------------------------------------------------------
* packed file format:
*
* the packed file consists of a 24 byte header + packed bit-streamed data
*
* header:
*	dc.b	'QPAC2-JMP(c)1989'
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

error_sp ds.l	1

command_line ds.l 1

input_buffer ds.b 80+1
	even
input_cursor ds.w 1

	section	data

	ifne	test_version
demo_file dc.b	.end-.start
.start	dc.b	'qpac3.ttp'
.end	dc.b	0,0,0,0
	even
	endc

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
	bsr.s	start
exit	clr.w	-(sp)
	move.w	#$4C,-(sp)
	trap	#1

start	move.l	sp,error_sp		save error stack
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
	bsr	set_file_type
	bsr	scan_file
	lea	title,a0
	bsr	print_string
	move.l	command_line,a0
	bsr	print_string
	lea	data_mess,a0
	tst.w	file_type
	beq.s	.isdata
	lea	exec_mess,a0
.isdata	bsr	print_string
	lea	title2,a0
	bsr	print_string
	move.l	source_size,d0
	add.l	#1024,d0
	bsr	allocmem
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
	move.l	offsets_ptr,a1		use offsets table
	clr.w	colour_unpack
	bsr	unpack_file		for unpack workspace
undone	tst.w	d0
	bne	expand_error
	move.l	source_ptr,a0		error if not identical to source
	move.l	offsets_ptr,a1
	move.l	source_size,d7
.compare
	cmpm.b	(a0)+,(a1)+
	bne	expand_error
	subq.l	#1,d7
	bne.s	.compare
	lea	perc_mess,a0
	bsr	print_string
	move.l	source_size,d5
	move.l	dest_size,d6
	move.l	d6,d0		*100
	add.l	d6,d6
	add.l	d6,d6
	lsl.l	#5,d0
	add.l	d0,d6
	add.l	d0,d6
	add.l	d0,d6
	bsr	div32
	moveq	#0,d0
	move.w	d6,d0
	bsr	print_number
	lea	perc_mess2,a0
	bsr	print_string
	clr.w	input_cursor
	move.l	command_line,a0		dest name = source name + .QP2
	lea	input_buffer,a1
.copy	move.b	(a0)+,d0
	beq.s	.copy2
	cmp.b	#'.',d0
	beq.s	.copy2
	move.b	d0,(a1)+
	addq.w	#1,input_cursor
	bra.s	.copy
.copy2	move.b	#'.',(a1)+
	move.b	#'q',(a1)+
	move.b	#'p',(a1)+
	move.b	#'2',(a1)+
	addq.w	#4,input_cursor
	clr.b	(a1)
	lea	input_buffer,a0
	bsr	print_string
.input	bsr	get_key
	beq.s	.input
	cmp.w	#27,d0
	beq	quit
	cmp.w	#13,d0
	beq	.put
	cmp.w	#8,d0
	beq.s	.bs
	cmp.w	#'\',d0
	beq.s	.char
	cmp.w	#':',d0
	beq.s	.char
	cmp.w	#'.',d0
	beq.s	.char
	cmp.w	#'_',d0
	beq.s	.char
	cmp.w	#'0',d0
	bcs.s	.input
	cmp.w	#'9',d0
	bls.s	.char
	cmp.w	#'A',d0
	bcs.s	.input
	cmp.w	#'Z',d0
	bls.s	.char
	cmp.w	#'a',d0
	bcs.s	.input
	cmp.w	#'z',d0
	bhi.s	.input
.char	lea	input_buffer,a0
	move.w	input_cursor,d1
	cmp.w	#80,d1
	beq.s	.input
	move.b	d0,(a0,d1.w)
	clr.b	1(a0,d1.w)
	addq.w	#1,input_cursor
	bsr	outch
	bra.s	.input
.bs	lea	input_buffer,a0
	move.w	input_cursor,d1
	beq	.input
	clr.b	-1(a0,d1.w)
	subq.w	#1,input_cursor
	move.w	#8,d0
	bsr	outch
	move.w	#' ',d0
	bsr	outch
	move.w	#8,d0
	bsr	outch
	bra	.input
.put	lea	input_buffer,a0
	tst.b	(a0)
	beq	quit
	tst.w	file_type
	bne.s	.exec
.data	lea	input_buffer,a0
	move.l	dest_ptr,a1
	move.l	dest_size,d0
	bsr	put_data_file
	bcs.s	save_error
	rts
.exec	lea	exec_mess2,a0
	bsr	print_string
.wait	bsr	get_key
	beq.s	.wait
	cmp.w	#27,d0
	beq	quit
	cmp.w	#'Y',d0
	beq.s	.exec2
	cmp.w	#'y',d0
	bne.s	.data
.exec2	lea	exec_mess3,a0
	bsr	print_string
.wait2	bsr	get_key
	beq.s	.wait2
	cmp.w	#27,d0
	beq	quit
	cmp.w	#'Y',d0
	beq.s	.exec3a
	cmp.w	#'y',d0
	bne.s	.exec3b
.exec3a	move.w	#1,colour_unpack
.exec3b	lea	input_buffer,a0
	move.l	dest_ptr,a1
	move.l	dest_size,d0
	bsr	put_exec_file
	bcs.s	save_error
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
	dc.b	'QPAC v3.2 - The Fastest ST File Packer - by John M Phillips (C) 16 May 1990',13,10,13,10
	dc.b	'Press any key to abort',13,10,13,10
	dc.b	'Source file:',0

data_mess dc.b	27,'Y',' '+4,' '+40,'File type: Data',0
exec_mess dc.b	27,'Y',' '+4,' '+40,'File type: Executable',0

title2	dc.b	27,'Y',' '+6,' '
	dc.b	'Source          ',13,10,13,10
	dc.b	'Reading         ',13,10,13,10
	dc.b	'Writing         ',13,10,13,10
src_tab	dc.b	27,'Y',' '+6,' '+8,0
rd_tab	dc.b	27,'Y',' '+8,' '+8,0 
wr_tab	dc.b	27,'Y',' '+10,' '+8,0
	even
src_row	equ	(7*8+3)*160
rd_row	equ	(9*8+3)*160
wr_row	equ	(11*8+3)*160

time_mess
	dc.b	27,'Y',' '+13,' '
	dc.b	'Time taken = ',0
time_mess2
	dc.b	' seconds',13,10,0

perc_mess
	dc.b	'Packed to ',0
perc_mess2
	dc.b	'% of original',13,10,13,10
	dc.b	'Enter Filename (Return to save, ESC to abort)',13,10,13,10
	dc.b	'?',0

abort_mess
	dc.b	27,'Y',' '+13,' ','Aborted',0
overflow_mess
	dc.b	27,'Y',' '+13,' ','Packed file longer than original',0
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
exec_mess2
	dc.b	13,10,13,10,'Save as executable packed file ? Y/N , ESC to abort',0
exec_mess3
	dc.b	13,10,'Unpack with flashing border    ? Y/N , ESC to abort',0
	even

file_type dc.w 0	0=data/1=executable

source_ptr dc.l 0	ptrs to files
source_end dc.l 0
source_size dc.l 0

dest_ptr dc.l 0
dest_end dc.l 0
dest_size dc.l 0

offsets_ptr dc.l 0	ptr to offset table for fast 2-byte string search
offsets_size dc.l 0

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
	move.l	dest_ptr(pc),a6		a6=destination
	lea	header_name(pc),a0
	move.l	(a0)+,(a6)+		insert id
	move.l	(a0)+,(a6)+
	move.l	(a0)+,(a6)+
	move.l	(a0)+,(a6)+
	move.l	source_size(pc),(a6)+	insert unpacked size
	clr.l	(a6)+			skip checksum
	move.l	source_ptr(pc),a0	a0=source
	move.l	offsets_ptr(pc),a5	a5=offsets table
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

.loop	tst.w	(a5)			any matches ?
	beq	.no_string
	bsr	search_for_string	search for best saving
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

.copy2	addq.l	#1,com01
	moveq	#%01,d0			2 bytes : %01aaaaaaaa
	moveq	#2-1,d1
	bsr	put_bits
	move.w	d2,d0
	bsr	put_byte
	bra.s	.next

.copy3	addq.l	#1,com100
	moveq	#%100,d0		3 bytes : %100aaaaaaaaa
	moveq	#3-1,d1
	bsr	put_bits
	move.w	d2,d0
	moveq	#9-1,d1	
	bsr	put_bits
	bra.s	.next

.copy4	addq.l	#1,com101
	moveq	#%101,d0		4 bytes : %101aaaaaaaaaa
	moveq	#3-1,d1
	bsr	put_bits
	move.w	d2,d0
	moveq	#10-1,d1	
	bsr	put_bits
	bra.s	.next

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
	bra.s	.next

.no_string
	addq.w	#1,d5			if no copy then insert byte
	cmp.w	#264,d5			if full then save insert
	bcs.s	.nos2
	bsr	put_insert
.nos2	moveq	#1,d3
	bra.s	.next2

.next	add.w	d3,a4			update un-saves ptr after copy
.next2	add.w	d3,a0			bump source ptr by n bytes
	add.w	d3,d3			bump offsets ptr by n words
	add.w	d3,a5
	cmp.l	source_end(pc),a0	if >=end then done
	bge.s	.done
	tst.w	print_counter		every second
	bne	.loop
	move.w	#50,print_counter
	bsr	print_status		print status
	bcc	.loop			abort if key press
	bsr	cancel_irq
	sec
	rts

.done	bsr.s	put_insert		save any unsaved bytes
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
	bsr.s	put_bits
.small	move.b	(a4)+,d0
	bsr.s	put_byte
	subq.w	#1,d5
	bne.s	.small
.skip	rts
.big
	addq.l	#1,com111

	moveq	#%111,d0	else big insert (9..264 bytes)
	moveq	#3-1,d1			%111nnnnnnnn
	bsr.s	put_bits
	move.w	d5,d2
	cmp.w	#264,d2
	bcs.s	.big2
	move.w	#264,d2
.big2	subq.w	#1,d2
	move.w	d2,d0
	subq.w	#8,d0
	bsr.s	put_byte
.big3	move.b	(a4)+,d0
	bsr.s	put_byte
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
*	a5=offsets
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
	move.l	source_end(pc),d4	get bytes remaining
	sub.l	a0,d4			skip if <2
	cmp.l	#2,d4
	blt	.fail			d4=maximum size (up to 258)
	cmp.l	#258,d4
	bcs.s	.sok
	move.l	#258,d4
.sok	move.l	a5,a1			a1=ptr to chain of offsets
	move.l	a0,a3			a3=ptr to matching strings
	clr.w	string_saving		clear bits saved
.search	move.w	(a1),d0			get offset to previous string
	beq	.done			if =0 then no more matches
	add.w	d0,a3			goto matching string
	add.w	d0,d0			step back thru offset chain
	add.w	d0,a1			for next time round loop
	move.l	a0,d3
	sub.l	a3,d3			calculate distance
	cmp.l	#4096,d3		if >max then exit
	bgt	.done
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
	ble.s	.next
	move.w	d3,string_offset	save info
	move.w	d2,string_size
	move.w	d1,string_type
	move.w	d0,string_saving
	cmp.w	d4,d2			if size=max and max>=6 then
	bne.s	.next			search no further
	cmp.w	#6,d2
	bgt.s	.done
.next	bra	.search

.done	tst.w	string_saving		if nothing found then fail
	beq.s	.fail
	sec
	rts
.fail	clc
	rts

* scan source file and make offsets table
* takes about 1 second per 50k of source

scan_file
	move.l	source_size,d0	source_size words for offsets table
	add.l	d0,d0
	bsr	allocmem
	bcs	memory_error
	move.l	a0,offsets_ptr
	move.l	d0,offsets_size
	move.l	#4*65536,d0	64K longs for address list (temporary)
	bsr	allocmem
	bcs	memory_error
	move.l	a0,.buffer_ptr
	move.l	.buffer_ptr,a0	wipe buffer
	move.w	#65536-1,d0
.clear	clr.l	(a0)+
	dbra	d0,.clear
	move.l	offsets_ptr,a0	wipe offsets
	move.l	offsets_size,d7
	lsr.l	#1,d7
.clear2	clr.w	(a0)+
	subq.l	#1,d7
	bne.s	.clear2
	move.l	source_ptr,a0
	move.l	offsets_ptr,a1
	move.l	.buffer_ptr,a2
	move.l	#-4096,d6	max distance
	move.l	source_size,d7
	subq.l	#1,d7		for each 2 byte string
.scan	moveq	#0,d0
	movep.w	(a0),d0
	move.b	1(a0),d0
	lsl.l	#2,d0
	move.l	(a2,d0.l),d1		index address of previous occurence
	beq.s	.store			if exists then
	sub.l	a0,d1				convert to relative offset
	cmp.l	d6,d1				if >=max distance then
	blt.s	.store
	move.w	d1,(a1)					store offset
.store	move.l	a0,(a2,d0.l)		store address of latest occurence
	addq.w	#1,a0			source+1
	addq.w	#2,a1			offset+2
	subq.l	#1,d7			next source
	bne.s	.scan
	move.l	.buffer_ptr,a0
	bsr	freemem
	bcs	memory_error
	rts

.buffer_ptr dc.l 0

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
.si2	move.l	$70.w,old_vbl
	move.l	#my_vbl,$70.w
	rts

cancel_irq
	pea	.ci2
	move.w	#38,-(sp)
	trap	#14
	addq.l	#6,sp
	rts
.ci2	move.l	old_vbl,$70.w
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
	bsr.s	get_key			abort if key press
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
.no	tst.w	d0
	rts

print_number
	movem.l	d0-d2/a0,-(sp)
	move.l	d0,d1
	bpl.s	.pos
	neg.l	d1		if -ve then make positive
	move.b	#'-',d0		and print -
	bsr.s	outch
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
.show	bsr.s	outch		print char
	addq.w	#1,.count	bump count
.next	bra.s	.loop		next power
.done	movem.l	(sp)+,d0-d2/a0
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

outch	movem.l	d0/a0,-(sp)
	move.w	d0,-(sp)
	move.w	#2,-(sp)
	trap	#1
	addq.l	#4,sp
	movem.l	(sp)+,d0/a0
	rts

print_bar
	move.l	logbase,a0
	add.w	d7,a0
	cmp.w	#1,screen_res
	bcs.s	.low
	beq.s	.med
	bra	.hi

.low	rts

.med	move.l	d6,d5		*640
	add.l	d6,d6
	add.l	d6,d6
	add.l	d5,d6
	add.l	d6,d6
	lsl.l	#6,d6
	move.l	source_size,d5
	bsr	div32
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

* 32-bit signed division
* entry	d5=32 bit divisor
*	d6=32 bit dividend
* exit	d6=32 bit quotient

div32	movem.l	d2-d4,-(sp)
	tst.l	d5
	beq.s	.exit
	move.l	d6,d4
	eor.l	d5,d4
	tst.l	d5
	bpl.s	.pos0
	neg.l	d5
.pos0	tst.l	d6
	bpl.s	.pos1
	neg.l	d6
.pos1	moveq	#32-1,d2
	move.l	d5,d3
	moveq	#0,d5
.norm	add.l	d3,d3
	dbcs	d2,.norm
	roxr.l	#1,d3
	sub.w	#31,d2
	neg.w	d2
.loop	add.l	d5,d5
	cmp.l	d3,d6
	bcs.s	.next
	addq.l	#1,d5
	sub.l	d3,d6
.next	lsr.l	#1,d3
	dbra	d2,.loop
	tst.l	d4
	bpl.s	.exit
	neg.l	d5
.exit	move.l	d5,d6
	movem.l	(sp)+,d2-d4
	rts

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
	bsr	allocmem		allocate memory
	bcc.s	.ok
	bsr.s	.close
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
	bsr.s	.close
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

* put data file
* entry	a0=filename
*	a1=address
*	d0=length
* exit	carry set if error

put_data_file
	move.l	a0,.name		save parameters
	move.l	a1,.addr
	move.l	d0,.length
	move.l	.name,-(sp)		DELETE (just to be safe)
	move.w	#$41,-(sp)
	trap	#1
	add.l	#6,sp
	move.w	#0,-(sp)		CREATE new file
	move.l	.name,-(sp)
	move.w	#$3C,-(sp)
	trap	#1
	addq.l	#8,sp
	tst.l	d0			error ?
	bmi.s	.error
	cmp.l	#6,d0			valid handle ?
	bcs	.error
	cmp.l	#46,d0
	bcc	.error
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
	bmi.s	.error
	clc
	rts
.error	sec
	rts

.name	dc.l	0
.addr	dc.l	0
.handle	dc.w	0
.length	dc.l	0

* allocate memory
* entry	d0=amount
* exit	carry set if no room
*	a0=address
*	d0=amount

allocmem
	move.l	d0,.length
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

* free memory previously allocated
* entry	a0=address
* exit	carry set if error

freemem	move.l	a0,-(sp)
	move.w	#$49,-(sp)
	trap	#1
	addq.l	#6,sp
	tst.l	d0
	bmi.s	.error
	clc
	rts
.error	sec
	rts

* set file type (executable if extension TOS,PRG or APP)

set_file_type
	clr.w	file_type
	move.l	command_line,a0
	moveq	#0,d0
.scan	move.b	(a0)+,d0
	beq.s	.skip
	cmp.b	#'.',d0
	bne.s	.scan
.ext	move.b	(a0)+,d1
	beq.s	.ext2
	lsl.l	#8,d0
	move.b	d1,d0
	bra.s	.ext
.ext2	cmp.l	#'.TOS',d0
	beq	.exec
	cmp.l	#'.PRG',d0
	beq	.exec
	cmp.l	#'.TTP',d0
	beq	.exec
	cmp.l	#'.tos',d0
	beq	.exec
	cmp.l	#'.prg',d0
	beq	.exec
	cmp.l	#'.ttp',d0
	bne	.skip
.exec	move.w	#1,file_type
.skip	rts

* put executable file
* entry	a0=filename
*	a1=address
*	d0=length
* exit	carry set if error

put_exec_file
	move.l	a0,.name		save parameters
	move.l	a1,.addr
	move.l	d0,.length
	move.l	.name,-(sp)		DELETE (just to be safe)
	move.w	#$41,-(sp)
	trap	#1
	add.l	#6,sp
	move.w	#0,-(sp)		CREATE new file
	move.l	.name,-(sp)
	move.w	#$3C,-(sp)
	trap	#1
	addq.l	#8,sp
	tst.l	d0			error ?
	bmi	.error
	cmp.l	#6,d0			valid handle ?
	bcs	.error
	cmp.l	#46,d0
	bcc	.error
	move.w	d0,.handle
	move.w	#0,-(sp)		move file pointer to start
	move.w	.handle,-(sp)
	move.l	#0,-(sp)
	move.w	#$42,-(sp)
	trap	#1
	add.l	#10,sp
	move.l	.length,d0			set text size in header
	add.l	#exec_header_end-exec_text,d0
	move.l	d0,eh_text
	move.l	#exec_code_end-exec_code,d0	set data size in header
	move.l	d0,eh_data
	pea	exec_header			write header
	move.l	#exec_header_end-exec_header,-(sp)
	move.w	.handle,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	add.l	#12,sp
	tst.l	d0
	bmi.s	.close
	move.l	.addr,-(sp)			write data to file
	move.l	.length,-(sp)
	move.w	.handle,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	add.l	#12,sp
	tst.l	d0
	bmi.s	.close
	pea	exec_code			write unpacker code
	move.l	#exec_code_end-exec_code,-(sp)
	move.w	.handle,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	add.l	#12,sp
.close	move.l	d0,-(sp)
	move.w	.handle,-(sp)		close file
	move.w	#$3E,-(sp)
	trap	#1
	addq.l	#4,sp
	move.l	(sp)+,d0
	bmi.s	.error
	clc
	rts
.error	sec
	rts

.name	dc.l	0
.addr	dc.l	0
.handle	dc.w	0
.length	dc.l	0

	opt	p+				must be PC-relative

exec_header
	dc.w	$601A	identifier
eh_text	dc.l	0	text (header + packed file)
eh_data	dc.l	0	data (unpacker)
	dc.l	0	bss
	dc.l	0	symbols
	dc.l	0	reserved
	dc.l	0	reserved
	dc.w	-1	relocation (-1=none)

exec_text
	move.l	a6,-(sp)		save a6
	move.l	8(sp),a6		get basepage
	move.l	$10(a6),-(sp)		get start of data
	rts				goto unpacker
exec_copy
	move.w	-(a0),-(a1)
	subq.l	#1,d0
	bne.s	exec_copy
	jmp	(a2)

exec_header_end

* <--- packed file goes in here

exec_code
	lea	reg_save(pc),a6			save all registers
	movem.l	d0-d7/a0-a5,(a6)
	move.l	(sp)+,reg_a6-reg_save(a6)	old a6 was on stack
	move.l	4(sp),a6			get basepage
	lea	exec_code_end(pc),a0		get end of file
	move.l	4(a6),a1			get end of TPA
	lea	-$100(a1),a1			allow for stack
	move.l	$C(a6),d0			get text+data size
	add.l	$14(a6),d0
	lsr.l	#1,d0				word count
	move.l	a1,a2
	sub.w	#exec_code_end-.here,a2		a2=return address
	move.l	8(a6),a3			jump down to copier to
	add.w	#exec_copy-exec_text,a3		avoid wiping over self
	jmp	(a3)				(copies up to high memory)
.here	move.l	a1,a0
	add.w	#exec_header_end-exec_text,a0	a0=high copy of packed file
	move.l	8(a6),a1			a1=start of text
	bsr	unpack_file			unpack file
	move.l	d7,d0				d0=length
	move.l	4(sp),a6			get basepage again
	move.l	8(a6),a0			get header
	move.l	2(a0),d3			length of text
	move.l	6(a0),d4			length of data
	move.l	10(a0),d5			length of bss
	move.l	14(a0),d6			length of symbols
	move.w	26(a0),d7			relocation flag
	lea	28(a0),a1
	move.l	a0,a2				a2=address of reloc info
	add.l	d3,a2				   (when copied down !!)
	add.l	d4,a2
	add.l	d6,a2
	addq.w	#4,d0				copy down to remove header
	lsr.l	#2,d0
.copydown
	move.l	(a1)+,(a0)+
	subq.l	#1,d0
	bne.s	.copydown
	cmp.w	#-1,d7
	beq	.noreloc
	move.l	8(a6),a0			relocate
	move.l	a0,d2
	move.l	(a2)+,d0		get long index to first addr
	beq	.noreloc		if 0 then run
	add.l	d0,a0
	moveq	#0,d1
.reloc	add.l	d2,(a0)			add relocation offset
.rbyte	move.b	(a2)+,d1		get byte
	beq.s	.noreloc		if 0 then end of list so run
	cmp.b	#1,d1			if 1 then add 254 to address
	bne.s	.rsmall
	lea	254(a0),a0
	bra.s	.rbyte
.rsmall	add.w	d1,a0			else add byte 2..253 to address
	bra.s	.reloc			and relocate address
.noreloc
	move.l	d3,$C(a6)		set text size
	move.l	8(a6),d0		set data address
	add.l	d3,d0
	move.l	d0,$10(a6)
	move.l	d4,$14(a6)		set data size
	add.l	d4,d0
	move.l	d0,$18(a6)		set bss address
	move.l	d5,$1C(a6)		set bss length
	move.l	$18(a6),a0		wipe bss (if any)
	move.l	d5,d0
	beq.s	.nobss
	addq.w	#4,d0
	lsr.l	#2,d0
.wipebss
	clr.l	(a0)+
	subq.l	#1,d0
	bne.s	.wipebss
.nobss	move.l	8(a6),-(sp)			save start address
	movem.l	reg_save(pc),d0-d7/a0-a6	restore registers
	rts					jump to program

reg_save
	ds.l	14
reg_a6	ds.l	1

* unpack file
* entry	a0=addr of packed file
*	a1=addr of unpacked file
* exit	d0=error code
*		0 = ok
*		1 = not a QPAC2 file
*		2 = checksum failed
*		3 = file overflowed
*	d7=length
* note	self-contained, position independent

get_bit	macro
	add.l	d6,d6		get bit
	bne.s	.gb\@		if empty then
	move.l	(a0)+,d6	get next long
	eor.l	d6,d7		update checksum
	move.b	#%10000,ccr	get bit and set marker
	addx.l	d6,d6
.gb\@
	endm

colour_unpack dc.w 0		0=quiet/1=flash border

unpack_file
	move.l	a0,d6
	move.l	a1,d7
.v	lea	.v(pc),a2
	move.w	colour_unpack(pc),d0
	beq.s	.nobord
	move.l	.pcode1(pc),.patch1-.v(a2)
	move.l	.pcode2(pc),.next-.v(a2)
	move.l	.pcode3(pc),.patch2-.v(a2)
	pea	.start(pc)
	move.w	#38,-(sp)
	trap	#14
	addq.l	#6,sp
	rts
.nobord	move.l	.npcode(pc),d0
	move.l	d0,.patch1-.v(a2)
	move.l	d0,.next-.v(a2)
	move.l	d0,.patch2-.v(a2)
.start	move.l	d6,a0
	move.l	d7,a1
	move.l	a1,a6
	lea	.head(pc),a2
	moveq	#4-1,d0
.valid	cmpm.l	(a0)+,(a2)+
	bne	.error1
	dbra	d0,.valid
.patch1	move.w	$FFFF8240.w,d5		save border colour
	move.l	a1,a2		end of dest=dest+length of unpacked file
	add.l	(a0)+,a2
	move.l	(a0)+,d7	d7=checksum
	moveq	#0,d6		empty source
.loop	get_bit
	bcs	.com1xx
	get_bit
	bcs	.com01
.com00	moveq	#0,d2
	get_bit
	addx.b	d2,d2
	get_bit
	addx.b	d2,d2
	get_bit
	addx.b	d2,d2
.com00_loop
	get_bit			command %00nnn, insert 1..8 bytes
	addx.b	d0,d0
	get_bit
	addx.b	d0,d0
	get_bit
	addx.b	d0,d0
	get_bit
	addx.b	d0,d0
	get_bit
	addx.b	d0,d0
	get_bit
	addx.b	d0,d0
	get_bit
	addx.b	d0,d0
	get_bit
	addx.b	d0,d0
	move.b	d0,(a1)+
	dbra	d2,.com00_loop
	bra	.next
.com01	moveq	#8-1,d1		command %01aaaaaaaa, copy 2 bytes
	moveq	#2-1,d2
	bra.s	.copy
.com1xx	get_bit
	bcs.s	.com11x
	get_bit
	bcs.s	.com101
.com100	moveq	#9-1,d1		command %100a..a, copy 3 bytes
	moveq	#3-1,d2
	bra.s	.copy
.com101	moveq	#10-1,d1	command %101a..a, copy 4 bytes
	moveq	#4-1,d2
	bra.s	.copy
.com11x	get_bit
	bcs.s	.com111
.com110	bsr.s	.get_byte	command %110n..na..a, copy 3..258 bytes
	addq.w	#3-1,d2
	moveq	#12-1,d1
.copy	moveq	#0,d0
.copy2	get_bit
	addx.w	d0,d0
	dbra	d1,.copy2
	lea	-1(a1),a3
	sub.w	d0,a3			copy from dest-offset-1
.copy3	move.b	(a3)+,(a1)+
	dbra	d2,.copy3
.next	move.w	a1,$FFFF8240.w		alter border
	cmp.l	a2,a1
	bcs	.loop
.patch2	move.w	d5,$FFFF8240.w		restore border
	bra.s	.done
.com111	bsr.s	.get_byte		command %111n..n, insert 9..264 bytes
	addq.w	#9-1,d2
	bra	.com00_loop
.done	bne.s	.error3
	move.l	d7,d0
	move.l	a2,d7			start
	sub.l	a6,d7			end
	tst.l	d0
	bne.s	.error2
	rts
.error1	moveq	#1,d0
	rts
.error2	moveq	#2,d0
	rts
.error3	moveq	#3,d0
	rts

.get_byte
	moveq	#0,d2
	get_bit
	addx.b	d2,d2
	get_bit
	addx.b	d2,d2
	get_bit
	addx.b	d2,d2
	get_bit
	addx.b	d2,d2
	get_bit
	addx.b	d2,d2
	get_bit
	addx.b	d2,d2
	get_bit
	addx.b	d2,d2
	get_bit
	addx.b	d2,d2
	rts

.pcode1	move.w	$FFFF8240.w,d5
.pcode2	move.w	a1,$FFFF8240.w
.pcode3	move.w	d5,$FFFF8240.w

.npcode	nop
	nop

.head	dc.b	'QPAC2-JMP(C)1989'
	even

exec_code_end

