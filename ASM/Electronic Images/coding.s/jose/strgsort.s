;
; String sort version (see last paragraph).
;
; Yikes!  Quite a natty 32-bit quicksort routine here that I stole from
; a crappy demo...  It even came with labels too!  I put in a few comments
; as to the workings + I sped it up a bit and re-arranged some of its code
; so as to increase the efficiency (luckily I read up on quicksorting not
; too long ago!)...  Saves me doing most of the code anyway!
;
; Jose (Phanty wanty).
;
; Right, this is the string sort version, after Ben set me right on the
; workings of the 'compare until different character' method (in other
; words, it finally made sense to dumb old me!).
; So here it is...  It's the same as the original quicksort except that
; is uses 4 byte entries (longwords) holding the addresses of the strings,
; and the maximum string comparison (i.e.  how far you want it to go!) in
; D2 *minus one* (the -1 makes the quicksort slightly faster).
;
;

	lea	ween(pc),a0
	lea	weenend-4(pc),a1
	moveq	#2-1,d2
	bsr.s	quicksort
	lea	ween(pc),a5
	move.l	(a5)+,a0
	move.l	(a5)+,a1
	move.l	(a5)+,a2
	move.l	(a5)+,a3
	sub.l	a4,a4
	sub.l	a5,a5
	sub.l	a6,a6
	illegal	
	
	clr.w	-(sp)
	trap	#1


Quicksort:
	movem.l	a0-a3,-(a7)
	movea.l	a0,a2			; Copy regs.
	movea.l	a1,a3
	move.l	a1,d1
	sub.l	a0,d1			; Calc middle position.
	lsr.w	#1,d1
	andi.w	#$FFFc,d1
	move.l	0(a0,d1.w),d0		; Now get false 'median'.
Quicksortloop1:
	move.l	(a2),a4			; Get pointer.
	move.l	d0,a5			; Again.
	move.w	d2,d1			; Maximum string comparison.
c1:	cmpm.b	(a4)+,(a5)+		; Find a non-equal character.
	dbne	d1,c1
	beq.s	Quicksortloop2		; Ran out (all same), so skip.
	move.b	-(a5),d1		; Else compare for greatest.
	cmp.b	-(a4),d1
	ble.s	Quicksortloop2		; No, check other.
	addq.w	#4,a2			; Yup, Move top downwards.
	bra.s	Quicksortloop1
Quicksortloop2:
	move.l	(a3),a4			; Get pointer.
	move.l	d0,a5			; Again.
	move.w	d2,d1			; Maximum string comparison.
cstr2:	cmpm.b	(a4)+,(a5)+		; Find a non-equal character.
	dbne	d1,cstr2
	beq.s	Continue_some_more	; Ran out (all same), so skip.
	move.b	-(a5),d1		; Else compare for greatest.
	cmp.b	-(a4),d1
	bge.s	Continue_some_more	; No...  continue other checks.
	subq.w	#4,a3			; Yep...  Move end upwards.
	bra.s	Quicksortloop2
Continue_some_more:
	cmpa.l	a3,a2			; Have ends crossed over?
	bgt.s	Out_of_this_bit		; Yep, so re-set.
	move.l	(a2),d1			; Else swap (top) and (end) values.
	move.l	(a3),(a2)+		; Swap number.
	move.l	d1,(a3)
	lea	-4(a3),a3		; down and (end) 2 ptrs up.
	cmpa.l	a3,a2			; Check for crossover.
	ble.s	Quicksortloop1		; Nope...  Continue...
Out_of_this_bit:
	cmpa.l	a3,a0			; Has end crossed start?
	bge.s	Backfromrecursion1	; Yes, we have finished a box.
	move.l	a1,-(a7)		; Else store end pointer.
	movea.l	a3,a1			; Now make current this end.
	bsr.s	Quicksort		; And now do this half box.
	movea.l	(a7)+,a1		; Restore end pointer.
Backfromrecursion1:
	cmpa.l	a2,a1			; Has top crossed end?
	bge.s	Doquickagain2		; No, so continue sort...
	movem.l	(a7)+,a0-a3		; Yes!  Done quicksort.
	rts
Doquickagain2:
	movea.l	a2,a0			; Else make new top current top.
	bsr.s	Quicksort		; And continue sort...
	movem.l	(a7)+,a0-a3
	rts


ween:
	dc.l	str1
	dc.l	str2
	dc.l	str3
	dc.l	str4
weenend:	

str1:	dc.b	'Xanaduuu blah',0
str2:	dc.b	'And so is yours',0
str3:	dc.b	'Your momma is a slut',0
str4:	dc.b	'Abba rules hoho',0
