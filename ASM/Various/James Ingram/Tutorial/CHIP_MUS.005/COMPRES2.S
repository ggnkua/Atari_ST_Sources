* Compression V2 for music data
* by James Ingram, April 1994

* Program designed using JSP methodology
* the ONLY way to do stuff like this, guys & gals.
* LEARN IT.

	opt	x+,o-,ow-

	bsr	header
	bsr	body
	bsr	term
	clr.w	-(a7)
	trap	#1

header:
	move.l	#music,a0
	move.l	#compressed,a1
	move.l	#lengths,a2
	move.w	#11,no_of_channels
	rts

term:

* print out lengths etc and save out file...
	bsr	print_lengths

	lea	comp2(pc),a0
	move.l	#compressed,a1
	move.l	total_len,d0
	bsr	save_file

	rts

comp2:	dc.b	"mus.cmp",0
	even

	include	\includes\save.s

	


body:
* do each channel...
.while:
	tst.w	no_of_channels
	beq.s	.end_while

	bsr	do_a_channel

	subq.w	#1,no_of_channels
	bra.s	.while

.end_while:
	rts


do_a_channel:
	bsr	init_channel
	bsr	channel_body
	rts

init_channel:
	move.l	#chan_len,len_to_do
* do a read-ahead
* 3 reads to fill buffer completely
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7

	bsr	read
	bsr	read
	bsr	read
	rts

channel_body:
.while:
	tst.w	d5
	bmi.s	.end_while

	bsr	do_element

	bra.s	.while

.end_while:
* go to next channel length
	addq.l	#4,a2
	rts


do_element:
* selection
	bsr	test_for_block
	tst.w	d0
	beq.s	.block

	bsr	list
	rts

.block:
	bsr	block
	rts


list:
* deal with a list (may have to quit if it's a block...)

	bsr	list_header
	bsr	list_body
	bsr	list_write
	rts

list_header:
* We have a list situation!

	clr.w	list_len

* THIS BIT IS NOT STANDARD JSP...
	move.l	a1,counter_pos	; keep address of my flag
	addq.l	#1,a1		; go to where list will start

	rts


list_body:
* WHILE (not end of channel) AND (<128 bytes in list) AND (no block found to be next)

.while:
* not end of channel
	tst.w	d5
	bmi.s	.end_while	; end while if at end of channel

* < 128 bytes in list
	cmp.w	#128,list_len
	beq.s	.end_while

* no block next
	bsr	test_for_block
	tst.w	d0
	beq	.end_while

	bsr	do_byte_in_list
	bra	.while

.end_while:
	rts


do_byte_in_list:
* do a byte in the list
	move.b	d5,d0
	bsr	write

	addq.w	#1,list_len

	bsr	read
	rts

list_write:
* write out list header byte...
	move.l	counter_pos,a6	; get addr that flag was at
	move.w	list_len,d0	; get no of bytes in list
	bclr	#7,d0		; not a block
	move.b	d0,(a6)		; store flag & count

	addq.l	#1,(a2)	; increase length of compressed file
	addq.l	#1,total_len
	rts


block:
* We've admitted it's a block, not a list.
	bsr	block_header
	bsr	block_body
	bsr	block_write
	rts


block_header:
* We've got a block of at least 3 bytes the same.

	moveq	#1,d0		; 1 byte found
	move.b	d5,d1		; keep old byte

	bsr	read
	rts

block_body:
* get no of bytes which are the same as this one.

* WHILE (not end of channel) AND (byte is the same) AND (bytes the same < 128)

.while:
* not end of channel
	tst.w	d5
	bmi.s	.end_while

* byte is the same
	cmp.b	d5,d1
	bne.s	.end_while

* no of bytes is OK
	cmp.b	#128,d0
	beq.s	.end_while

	bsr	block_byte
	bra.s	.while

.end_while:
	rts


block_byte:
	addq.w	#1,d0
	bsr	read
	rts

block_write:
	bset	#7,d0		; set flag for block
	bsr	write
	move.b	d1,d0
	bsr	write
	rts



	
**********************
** COMMON ROUTINES  **
**********************

test_for_block:
* returns d0 = 0 if block found
* d0 = -1 if no block found

* test for 3 consecutive bytes of the same value...
* they are in d5 d6 d7

* if d7 is EOF then it cannot be a block!
	moveq	#-1,d0

	tst.w	d7
	bmi	.not_block

* if any are different then it cannot be a block
	cmp.b	d5,d6
	bne	.not_block
	
	cmp.b	d6,d7
	bne	.not_block

* IT IS A BLOCK!
	moveq	#0,d0
.not_block:
	rts


read:
	move.w	d6,d5		; bytes move down in buffer
	move.w	d7,d6

* is there any file left to read?
	tst.l	len_to_do
	beq.s	eof		; branch if at end of file

	move.b	(a0)+,d7	; get next byte...
	subq.l	#1,len_to_do	; 1 less byte to process
	rts

eof:
	moveq	#-1,d7		; negative value flags EOF
	rts

write:
* write a byte to the compressed file
* d0 = byte to write

	move.b	d0,(a1)+
	addq.l	#1,total_len
	addq.l	#1,(a2)
	rts

print_lengths:
* print out 11 longwords as decimal numbers
* with explaining text!

	move.l	#lengths,a6
	move.l	#texts,a5
	moveq	#11-1,d7

channel_print:
* print text at a5, and move a5 to next text address
	bsr	print_a5


* now get the WORD to convert
	move.l	(a6),d0
	bsr	bin_to_dec

* print the number
	bsr	print_mes

* assume it is smaller
	lea	smaller(pc),a0

* was it smaller than the original length???
	move.l	#chan_len,d0	; get orig length
	sub.l	(a6)+,d0	; take away new length

* if still positive, then is =< old length!
	bpl.s	.smaller

* it is bigger!  Oh no!
	lea	bigger(pc),a0
.smaller:
	bsr	print_mes	; print relevant message

	dbra	d7,channel_print

* now print total size...
	bsr	print_a5


	move.l	total_len,d0
	bsr	bin_to_dec
	bsr	print_mes

	bsr	print_a5
	move.w	#mus_len,d0
	bsr	bin_to_dec
	bsr	print_mes
	
	bsr	print_a5

	bsr	inp
	rts


print_a5:
	move.l	a5,a0
	bsr	print_mes	; print channel number

* search for next text
.nxt_txt:
	tst.b	(a5)+
	bne.s	.nxt_txt
	rts


smaller:	dc.b	" *",0
bigger:		dc.b	" ",27,"p!!!",27,"q",0
	even


bin_to_dec:
* convert WORD in d0 to decimal number in text
* return text address in a0

	clr.b	-(a7)		; zero on stack

	tst.w	d0
	beq.s	.zero		; branch if zero given!

.conv_loop:
	divu	#10,d0		; divide binary number by 10
	swap	d0		; get remainder
	add.b	#"0",d0		; as ASCII
	move.b	d0,-(a7)	; on stack for later

	clr.w	d0		; clear remainder
	swap	d0		; get integer back again

	tst.w	d0
	bne.s	.conv_loop	; go until integer is 0

.to_string:
* put ASCII on stack into a string to be printed

	move.l	#string,a0
	move.l	a0,a1

.put:
	move.b	(a7)+,(a1)+
	bne.s	.put

	rts

.zero:
	move.b	#"0",-(a7)
	bra.s	.to_string

string:
	ds.b	100


texts:
	dc.b	27,"E"
	dc.b	"COMPRESSION V2",10,13
	dc.b	"Original channel length is 4098 bytes",10,13
	dc.b	"Compressed sizes are as follows:",10,13
	dc.b	"(* indicates smaller size, ",27,"p!!!",27,"q"
	dc.b	" indicates larger)",10,13,10
	dc.b	"Channel 1  = ",0
	dc.b	10,13,"Channel 2  = ",0
	dc.b	10,13,"Channel 3  = ",0
	dc.b	10,13,"Channel 4  = ",0
	dc.b	10,13,"Channel 5  = ",0
	dc.b	10,13,"Channel 6  = ",0
	dc.b	10,13,"Channel 7  = ",0
	dc.b	10,13,"Channel 8  = ",0
	dc.b	10,13,"Channel 9  = ",0
	dc.b	10,13,"Channel 10 = ",0
	dc.b	10,13,"Channel 11 = ",0
	dc.b	10,13,10,"TOTAL SIZE = ",0
	dc.b	"  (original = ",0
	dc.b	")",0
	even


	include	\includes\misc.s




music	incbin	channel.bin
mus_len	equ	*-music
chan_len	equ	mus_len/11



	section	bss

* VARIABLES!
no_of_channels	ds.w	1	; channel counter
len_to_do	ds.l	1	; length of channel left to do
list_len	ds.w	1	; no of bytes in a list
counter_pos	ds.l	1	; store for addr of list header
total_len	ds.l	1	; total len of compressed file

compressed	ds.b	mus_len
lengths	ds.l	11




