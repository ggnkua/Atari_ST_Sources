;
; Bootsector Menu by MUG U.K - 18/10/1991
; ---------------------------------------
;
	opt p+,o+,d-,s-

color	move.w	#$007,$ff8240
	move.w	#$777,$ff825e

print	pea	text(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

get_key	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp

key1	cmp.b	#$31,d0	; was 1 pressed ???
	bne.s	key2	; no it wasn't - try for 2 or 3
	lea	file1(pc),a0	; if it was then set-up filename in (a0)
	bra.s	load	; and load it

key2	cmp.b	#$32,d0	; was 2 pressed ???
	bne.s	key3	; no it wasn't - try for 3
	lea	file2(pc),a0 ; if it was then set-up filename in (a0)
	bra.s	load	; and load it

key3	cmp.b	#$33,d0	; was 3 pressed ??
	bne.s	exit	; no it wasn't - so exit !!
	lea	file3(pc),a0	; if it was then set-up filename in (a0)


load	move.w	#$777,$ff8240	; reset palette
	move.w	#$000,$ff825e
	
	pea	xxx(pc)		; load file
	pea	xxx(pc)
	move.l	a0,-(sp)
	clr.w	-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	lea	16(sp),sp

exit	rts

xxx	dc.l 	0

file1	dc.b "snooker.zip",0

file2	dc.b "stack_up.tbe",0

file3	dc.b "columns.mug",0

text	dc.b "Another Disk Saver !!!",$d,$a
	dc.b "----------------------",$d,$a,$a,$a
	dc.b "Press: 1 for Snooker",$d,$a,$a
	dc.b "       2 for Stack Up",$d,$a,$a
	dc.b "       3 for Columns",$d,$a,$a
	dc.b "Any other = desktop",$d,$a,$a,$a
	dc.b "Bootsector menu coded by MUG U.K",191,$d,$a
	dc.b 0


blanks	ds.w	75
