;
;
; Err...  You'll have to do with this one Marty poos; it's *almost* the
; latest one.  The latest one does adaptive compression and reads longs
; off the input stream (fast too!).  Unfortunately even I don't have it
; since Juan formatted the hard disk it was on (AGGG!), but I'm sure I
; have it on a disk somewhere...
;
;
; Bit check bug removed (I just *knew* there was something odd about
; checking the bit size of the new code, rather than the one just output!).
;
; For extra space in memory (according to code size; currently the table
; sizes are fixed) unpacking is faster now since it does not count the
; characters output, just extracts the count from a table.
;
; Bug removed where the first code was 'undefined' in the code size table;
; now it is set to 2, since first ever code is always two characters long.
;
; Position-independent version...

	opt	o+
;
; Err, undefined code bug removed!
;
; This one tests the thresholding packing and unpacking.
;
; Has over-run bug removed.

;-------------------------------------------------------------------------;
;		************ MACRO SECTION ************			  ;
;-------------------------------------------------------------------------;


output_8code	MACRO

	and.w	#$ff,d0
	lsl.w	d7,d0
	or.b	d0,(a1)
	lsr.w	#8,d0
	move.b	d0,-(a1)
	addq.w	#8,d7
	and.w	#7,d7

	ENDM
	
input_8code	MACRO

	move.b	-(a0),d0
	lsl.w	#8,d0
	move.b	1(a0),d0
	lsr.w	d7,d0
	and.w	#$ff,d0
	addq.w	#8,d7
	and.w	#7,d7

	ENDM



;
;---------------------
;
input_varcode	MACRO

;	moveq	#0,d0
	move.b	(a0),d4
	move.b	-(a0),d0
	lsl.w	#8,d0
	move.b	d4,d0

	move.w	d7,d4
	swap	d6
	add.w	d6,d7
	cmpi.w	#15,d7
	ble.s	sleepy\@
	swap	d0
	move.b	-(a0),d0
	swap	d0
sleepy\@
	lsr.l	d4,d0
	swap	d6
	and.w	d6,d0
	and.w	#7,d7
	
	ENDM

output_varcode	MACRO

	and.l	#$0000ffff,d0		; !!
	lsl.l	d7,d0
	or.b	d0,(a1)
	lsr.w	#8,d0
	move.b	d0,-(a1)
	
	add.w	bits(pc),d7
	cmpi.w	#15,d7
	ble.s	noddy\@
	swap	d0
	move.b	d0,-(a1)
noddy\@	
	and.w	#7,d7

	ENDM



;|=======================================================================|;
;-------------------------------------------------------------------------;
;		|~~|~~~~|~~ PROGRAM SECTION ~~|~~~~|~~|			  ;
;-------------------------------------------------------------------------;
;|-----------------------------------------------------------------------|;
;=========================================================================;	

codes		equ	1023		; TOTAL codes.
table_size	equ	5021		; Has to be a prime of codes.
threshold	equ	500		; Maximum no matches.

	bra.s	pp

source:	
	dc.l	pic
source_size:
	dc.l	32000
destination:
	dc.l	pend
pp:

	opt	p+

	move.w	#3,-(sp)
	trap	#14
	addq.w	#2,sp
	lea	scrnpos(pc),a0
	move.l	d0,(a0) 
	move.l	source(pc),a0
	move.l	scrnpos(pc),a1
	bsr	copy

pack:
	lea	code_value(pc),a4
	lea	prefix_code(pc),a5
	lea	append_character(pc),a6

	move.l	source(pc),a0
	move.l	a0,a2
	add.l	source_size(pc),a0
	lea	posize(pc),a1
	move.l	source_size(pc),(a1)	; Store original size in header.
	move.l	destination(pc),a1	; First or.b... (a1)..!
	subq.w	#1,a1
	clr.b	(a1)
; D6 has size of source.

	moveq	#0,d7			; Output switch to 0 (start).

restart_pack:
; Init string table.
	move.l	a4,a3			; Copy address.
	move.w	#table_size-1,d3
	moveq	#-1,d1
init_string_table:
	move.w	d1,(a3)+
	dbra	d3,init_string_table

	lea	last_bit_pos(pc),a3
	move.w	d7,(a3)+		; last_bit_pos
	move.l	a0,(a3)+		; last_source_pos
	move.l	a1,(a3)+		; last_dest_pos

;	illegal
	
	move.w	#256,d5			; NEXT_CODE = D5.
	moveq	#0,d1			; Upper bytes always clear!
	move.w	#threshold,d6		; Clear no match counter.

	moveq	#0,d0
	move.b	-(a0),d0		; Get STRING_CODE = D0.

pack_loop:
	moveq	#0,d1
	move.b	-(a0),d1		; CHARACTER = D1.

; Find (hashed) index.
; D0 is Hash_prefix and D1 is Hash_character here.
	move.w	d1,d2			; Copy Hash_character.
	lsl.w	#4,d2			; Hash it to x16 (to 4096).
	eor.w	d0,d2			; Then XOR/EOR hash_prefix.
; D2 = INDEX.

	bne.s	offset_ok		; Check if index is 0.
	moveq	#1,d3			; Yes; make offset 1.
	bra.s	cont_hash
offset_ok:		
; Index ok...  Calculate offset.
	move.w	#table_size,d3		; Get table size.
	sub.w	d2,d3			; Subtract index.

cont_hash:
	move.w	d2,d4			; Copy index.
	add.w	d4,d4			; And access table.
	
	tst.w	(a4,d4.w)		; Check if code value = -1.
	bmi.s	empty_code		; Yep, stop checking.
	cmp.w	(a5,d4.w),d0		; See if prefix code is same.
	bne.s	next_search		; No...  Continue search.
; Else check append character.
	cmp.b	(a6,d2.w),d1		; See if append character same.
	beq.s	hash_end		; Yes, we've found a match.
	
next_search:
; Else we continue searching...
	sub.w	d3,d2			; Index = index-offset.
	bge.s	cont_hash		; Check if < 0.
	add.w	#table_size,d2		; Yep...  Adjust.
	bra.s	cont_hash

hash_end:
; Right...  Hashing done...  We have the index in D2 and D2*2 in D4.
; This bit if a match has been found...
	move.w	(a4,d4.w),d0		; Get code.
;	bra.s	pack_loop		; And try to find a bigger match.
	cmp.l	a2,a0			; See if we have reached end.
	bgt.s	pack_loop		; If not, continue packing.


; Empty code...  Store it if we have any codes left.
empty_code:
	cmp.w	#codes-1,d5		; See if we have enough codes.
	bgt.s	no_match		; No...  Don't store new one.
; ELse we have room for this code, so store it.
	move.w	d5,(a4,d4.w)		; Store this code.
	move.w	d0,(a5,d4.w)		; Store prefix code.
	move.b	d1,(a6,d2.w)		; Store append character.
	move.w	d5,d2			; Copy code.
	subq.w	#1,d2			; Use previous code, not new one!
	lsr.w	#7,d2			; Access upper nibble and X2!
	bclr	#0,d2			; Throw out dirty bit.
	move.w	btab(pc,d2.w),-2(a4)	; And store bits used in output.
	addq.w	#1,d5			; We used one code!
	bra	output_string

btab:	dc.w	9
	dc.w	9
	dc.w	10,10
	dc.w	11,11,11,11
	dc.w	12,12,12,12,12,12,12,12

no_match:
	subq.w	#1,d6			; Else decrease threshold counter.
	bgt	output_string		; Not reached; carry on outputting.
; Check if packed chunk > normal chunk.
	move.l	last_dest_pos(pc),d0	; Get last dest pointer.
	sub.l	a1,d0			; Get packed chunk size.
	move.l	last_source_pos(pc),d1	; Get last source pointer.
	sub.l	a0,d1			; Get size of data looked at.
	cmp.l	d1,d0			; See if we packed it.
	blt.s	was_packed		; Yep, so send restart code.
	moveq	#0,d2			; Signal from normal pack (not end). 
; If it did not pack it, it's more efficient to store it as 8-bit raw data.
; We take advantage that <first code> is always 8-bit, so we can use bit 9
; to signal a raw run (since the first code is read as 9 bits anyway!).
; D0 = destination (packed) size.
; D1 = source size.

do_run:
	move.l	last_source_pos(pc),a0	; Get last source pointer.
	move.l	last_dest_pos(pc),a1	; Get last destination pointer.
	move.w	last_bit_pos(pc),d7	; Get last bit position.
	
	move.w	#%1111111100000000,d0	; Mask.
	rol.w	d7,d0			; And only use to clear new bits.
	and.b	d0,(a1) 		; Previous data is intact!
	
;	illegal
	
; First the raw count is output as a 16-bit number...  That should be ok
; since by the stage it gets to 32k the pack ratio would have been a lot
; greater than the unpacked.  We output the raw count in two 9 (8 + flag)
; and 8 bit data words, minimising the space used (only 17 bits).
	subq.w	#1,d1		; For dbra.
	move.w	#%100000000,d0	; Signal high bit = raw byte copy.
	move.b	d1,d0		; Lower byte...
	move.w	#9,-2(a4)	; Make sure a 9 bit code.
	output_varcode		; Output it.
	move.w	d1,d0		; Copy.
	lsr.w	#8,d0		; Upper byte...
	output_8code		; Store 8 bits from now on...
;	illegal
run_copy:
	move.b	-(a0),d0	; Get source byte.
	output_8code		; Output it (note 8 bits).
	dbra	d1,run_copy	; Do for number of unpacked bytes.
;	illegal
	tst.w	d2		; See if we're at the end of pack...
	beq	restart_pack	; End of raw copy; more bytes, so continue.
	bra.s	pack_end	; Else finito!
		
was_packed:	
	move.w	#codes,d0		; Yes, so ouput flag (last) code.
	output_varcode			; So now we re-start packing.
	lea	1(a3),a0		; And go back to where we were!
	bra	restart_pack		; code tables.
;a_match:

output_string:
	output_varcode
;	move.w	d0,(a1)+		; Output code if any.
	move.w	d1,d0			; String code is character.
	move.l	a0,a3			; Store our current pointer.
	cmp.l	a2,a0			; See if we have reached end.
	bgt	pack_loop		; If not, continue packing.
; End of source data...  Check if last chunk was packed.
	moveq	#-1,d2			; Signal end of pack (for raw run).
	move.l	last_dest_pos(pc),d0	; Get last dest pointer.
	sub.l	a1,d0			; Get size of packed chunk.
	move.l	last_source_pos(pc),d1	; Get last source pointer.
	sub.l	a0,d1			; Get size of data looked at.
	cmp.l	d1,d0			; See if packed > normal.
	bge	do_run			; Yep, do a raw copy.

pack_end:

	move.l	destination(pc),d0
	sub.l	a1,d0			; Packed length test!
	lea	ppsize(pc),a0
	move.l	d0,(a0)
	lea	header_end(pc),a0
	rept	18			; Store header.
	move.b	-(a0),-(a1)
	endr




	lea	crunched_addr(pc),a0
	move.l	a1,(a0)			; Store pack end address.
	move.l	scrnpos(pc),d0
	add.l	#32000,d0
	lea	decrunch_addr(pc),a0
	move.l	d0,(a0)
	
;	illegal				; Un-comment this line to see!


;	lea	destination,a1
;	move.l	#$fffffff,-2500(a1)	; To force a dud code! (testing)

	move.l	scrnpos(pc),a0
	moveq	#0,d1
	move.w	#1999,d0
cls:	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	dbra	d0,cls


	move.w	#1,-(sp)
	trap	#1
	addq.w	#2,sp

;	illegal

	opt	p-

	bra.s	sete

crunched_addr:
	ds.l	1
decrunch_addr:
	ds.l	1
error_code:
	ds.w	1

sete:
	opt	p+

;	illegal

	lea	error_code(pc),a0
	clr.w	(a0)
	move.l	crunched_addr(pc),a0	; First access is no offset (a0).
	move.l	decrunch_addr(pc),a1
	move.l	a1,a6
	sub.l	posize(pc),a6		; Subtract packed size.
	add.l	ppsize(pc),a0		; And point to end.
	lea	17(a0),a0		; Adjust! (-1 inc 16 byte header!).
	lea	append_character(pc),a2
	lea	prefix_code(pc),a3

unpack:
	moveq	#0,d7			; Input switch to 0 (start).

restart_unpack:

;	illegal

	moveq	#9,d6			; Start with nine bits.
	swap	d6
	move.w	#%0000000111111111,d6	; And its mask!!
	move.w	#256,d3			; Next_code.

	input_varcode			; Get first data (always non code).
	bclr	#8,d0			; Clear upper (9th) bit.
	beq.s	no_raw_unpack		; Check if a raw run; skip if so.
	move.w	d0,d1			; Else copy for count.
	input_8code			; We input 8 bit numbers now...
	lsl.w	#8,d0			; Shift to upper byte.
	or.w	d0,d1			; Now we have 16-bit count.
do_raw:	input_8code			; Get 8 bit (raw!) byte.
	move.b	d0,-(a1)		; Store at destination.
	dbra	d1,do_raw		; Do for number of dests.
	cmp.l	a6,a1			; See if we've done, finished.
	bgt.s	restart_unpack		; No, so continue unpack.
	bra	unpack_end		; End of data, kaput, so we end.

no_raw_unpack:
	move.w	d0,d1			; Old_code.
	move.w	d1,d2			; Character.
	move.b	d1,-(a1)		; Output old_code.

unpack_loop: 
	cmp.l	a6,a1			; See if we've done, finished.
	ble	unpack_end

	input_varcode			; Get new_code.

	cmp.w	#codes,d0		; Is it special code to re-set?
	beq	restart_unpack
;	blt.s	no_reset		; No, skip.
;	illegal
;	bra.s	restart_unpack		; Else re-start with new tables.
no_reset:
	lea	-1(a1),a4		; Store start of string.

	cmp.w	d3,d0			; Is it an undefined code?
	blt.s	unpack_code_ok		; No, decode it.
; Code undefined...  We create a new one.
	move.w	d3,d4			; Copy current code.
	sub.w	d0,d4			; And calculate difference.
;	cmp.w	#-1,d4
	bge.s	ok_code			; If more than one code out - error!
;	illegal
	lea	error_code(pc),a0	; Signal an error...
	bset.b	#0,1(a0)
	bra	unpack_end		; ... and quit!
ok_code:move.w	d1,d4			; Copy old code.
	bra.s	count_code		; Decode old_code.
	
unpack_code_ok:
	moveq	#-1,d2			; Signal a code ok.
	move.w	d0,d4			; Copy code.
count_code:
; Now we find number of characters to unpack.
	cmp.w	#255,d4			; Is it a code?
	ble.s	count_end		; No, it's a char - output it.
	move.w	d4,a5			; Store since used below.

	add.w	d4,d4			; X2.
	neg.w	d4			; Reverse access (saves an A reg!).
	move.w	(a2,d4.w),d5		; Length of write string.
	sub.w	d5,a1			; Now adjust write pointer.
	addq.w	#1,d5			; Then adjust for new code size.
	move.w	a5,d4			; Restore!
	bra.s	unpack_found_code	; Skip normal (no code) adjust.
count_end:
	subq.w	#1,a1			; Normal adjust (no code found).
	moveq	#2,d5			; So always two characters output!
unpack_found_code:
	move.l	a1,a5			; Copy.
; Check for undefined code (d2 the added character, else negative for ok).
	tst.w	d2
	bmi.s	code_loop
	move.b	d2,-1(a5)		; Undefined code, add character
	subq.w	#1,a1			; to stack and adjust write ptr!
	addq.w	#1,d5			; Adjust character count too.
; Now copy the data in <reverse> order!
code_loop:
	cmp.w	#255,d4			; Is it a code?
	ble.s	code_end		; No, it's a char - output it.
code_loop_copy:
	move.b	(a2,d4.w),(a5)+		; Output append character.
	add.w	d4,d4			; X2.
	move.w	(a3,d4.w),d4		; Get new (prefix) code.
	cmp.w	#255,d4			; Check if code or character.
	bgt.s	code_loop_copy		; Yep, go check it.
code_end:
	move.b	d4,(a5)+		; Output last character.

	moveq	#0,d2
	move.b	(a4),d2			; Character = start of string.

	cmp.w	#codes-1,d3		; See if we have any codes left.
	bgt.s	swap_codes		; None; don't bother with bits.
	move.w	d3,d4			; Else copy this code.
	add.w	d4,d4			; X2.
	move.w	d1,(a3,d4.w)		; Store prefix code.
	move.b	d2,(a2,d3.w)		; Store append character.
	addq.w	#1,d3			; Increase next_code.
	move.w	d3,d4			; Copy.
	add.w	d4,d4			; X2.
	neg.w	d4			; Reverse access (saves an A reg!).
	move.w	d5,(a2,d4.w)		; Store character count.
	move.w	d3,d5			; Copy code count.
	lsr.w	#6,d5			; And get upper nibble and X4!
	and.w	#%1111111111111100,d5	; Any duff bits out...
	move.l	btab2(pc,d5.w),d6	; Get bits used & mask in one go!

swap_codes:
	move.w	d0,d1			; Old code = new code.
	bra	unpack_loop

; Bit code table and mask.
btab2:
	dc.w	0,0
	dc.w	9,%0000000111111111
	rept	2
	dc.w	10,%0000001111111111
	endr
	rept	4
	dc.w	11,%0000011111111111
	endr
	rept	8
	dc.w	12,%0000111111111111
	endr

unpack_end:

	move.l	crunched_addr(pc),a1	; Check if we ran out of data!
	lea	16(a1),a1
	cmp.l	a1,a0
	ble.s	done_allbytes
;	illegal
	lea	error_code(pc),a0
	bset.b	#1,1(a0)		; Sigh...  Set it!
done_allbytes:


;	illegal

	
	move.l	scrnpos(pc),a0
	lea	32000(a0),a0
	sub.l	a1,a0
;	illegal

	move.l	scrnpos(pc),a0
	move.l	source(pc),a1
	move.w	#32000-1,d0
kk:	cmpm.b	(a0)+,(a1)+
	bne.s	agg
	dbra	d0,kk
	bra.s	phew
agg:	illegal
phew:


	move.w	#1,-(sp)
	trap	#1
	addq.w	#2,sp


	clr.w	-(sp)
	trap	#1	

copy:
	move.w	#1999,d0
cop:	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d0,cop
	rts



scrnpos:ds.l	1

last_bit_pos:
	ds.w	1
last_source_pos:
	ds.l	1
last_dest_pos:
	ds.l	1

header:	dc.b	'BhPacker'
posize:	ds.l	1	; Original size.
ppsize:	ds.l	1	; Packed size.
pcodes:	ds.w	1	; Codes used.
header_end:

bits:	ds.w	1			; NEEDS to be here to save A reg!
code_value:	ds.w	table_size
prefix_code:	ds.w	table_size
		ds.w	codes		; For unpacker code size lookup.
		dc.w	2		; The first code is always 2.
		ds.w	255		; Blank area makes things faster.
append_character:
		ds.b	table_size

	even

pic:	
	incbin	f:\arse.dat
;	dc.b	'\WE\WEB\WEE\WEEEEEEEE\WEB\WET\'
picend:
	ds.w	18000
pend:

		even
