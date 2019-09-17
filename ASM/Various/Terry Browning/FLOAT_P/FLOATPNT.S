;68000 Floating point routines by Terry Browning (from PCW Magazine Nov 1985)

;The 32 bit internal architecture of the 68000 processor means that a floating
;point number with 24 bit mantissa and 8 bit exponent can be accommodated
;in a single data register, but no 68000 operations can be performed
;on three byte values without affecting the fourth byte so the exponent
;of each number has to be transferred to a second register for processing.
;As byte operations always use bits 7-0, the exponent is stored as the
;lowest-order byte in the packed number.
;With the exponent moved to another register, 32 bits are available
;for dealing with the overflow and rounding bits that result from
;operations on the 24 bit mantissa. 



;This routine acts as a primary entry to floating point suite, save working
;regs on stack and expand f.p. compressed format numbers to working format.
;ENTRY d0 and d1 are two f.p. numbers in the format :- 
;	bits 31-8 = 24 bit mantissa
;	bits 7-0  = 8 bit excess 128 exponent
;EXIT  d1-d5 saved on stack
;      CCR (NZVC all cleared) is on stack top
;      d2.L = sign extended exponent of number d0
;      d3.L = sign extended exponent of number d1
;      d0(31-7) = expanded mantissa of number d0
;      d1(31-7) = expanded mantissa of number d1
;      d4 = sign extended exponent of zero number

entry	movem.l	d1-d5,-(sp)	save regs
	clr	d2	form new CCR for stack
	roxl.b	#5,d2	with all flags but X
	move	d2,-(sp)	cleared
	
	move.b	d0,d2	move exponent 1 to d2 and
	ext	d2	sign extend
	clr.b	d0	clear mantissa 1 lo-byte
	asr.l	#1,d0	and expand 24 bit mantissa
	bchg	#30,d0	to 25 bit for easier overflow chks
	
	move.b	d1,d3	move exponent 2 to d3 and
	ext	d3	sign extend
	clr.b	d1	clear mantissa 2 lo-byte
	asr.l	#1,d1	and expand 24 bit mantissa
	bchg	#30,d1	to 25 bit for easier overflow chks
	
	move	#$ff80,d4	set d4=sign extended 'zero exponent'
	move.l	22(sp),-(sp)
	rts
	
;Floating point exit routine
;Provide exit points compressing f.p. result or setting appropriate 
;error flags and restoring working registers saved by 'entry'
;ENTRY d0,d2 = f.p. result number (result) or unknown error (all other entry points)
;EXIT  reg/flag	no error	error
;      d0	result	uncertain
;      d1-a7	as before entry	as before entry
;      X	as before entry	as before entry
;      N	result state	1 if neg input
;      Z	result state	1 if division by zero
;      V	0	1 if any error
;      C	0	0

dzexit	or	#$06,(sp)	set stacked V & Z flags show div by 0
	bra	exit
	
ngexit	or	#$0a,(sp)	set stacked V & N flags to show neg input
	bra	exit
	
ovexit	or	#$02,(sp)	set stacked V flag to show overflow error
	bra	exit
	
ufexit	or	#$04,(sp)	set stacked Z flag to show underflow
	move.b	#$80,d0	and set result exponent to 'zero' value
	bra	exit
	
result	cmp.b	#$80,d2	if result exponent is 0, then use underflow
	beq	ufexit	to set Z and zeroise
	asl.l	#1,d0	else compress result
	bchg	#31,d0	mantissa into highest 3 bytes of d0
	bne	posres	show mantissa sign in
	or	#$08,(sp)	stacked N flag
posres	move.b	d2,d0	store result exponent

exit	move	(sp)+,ccr	get result CCR
	movem.l	(sp)+,d1-d5	restore regs
	addq.l	#4,sp
	rts
	
;Normalise a working format f.p. number by left justifying the mantissa
;with correcting adjustment to the exponent
;ENTRY d0 holds expanded floating point mantissa
;      d2 holds sign extended floating point exponent
;EXIT  d4 changed
;      d0 normalised
;      d2 contains exponent of normalised number

justfy	bvs	justrr	skip if already justified
	moveq	#23,d4	else set loop limit
	
justlp	subq	#1,d2	decrease exponent and left
	add.l	d0,d0	shift mantissa, until
	dbvs	d4,justlp	overflow (justified) or count out (not justified)
	
	bvs	justrr	skip if justified, else
	addq.l	#4,sp	clear return address and
	bra	ufexit	exit with underflow
	
justrr	roxr.l	#1,d0	correct mantissa overflow
	addq	#1,d2	& adjust exponent, then
	rts		return to main routine
	
;Round and justify working format f.p. number
;ENTRY d0 holds expanded 25 bit floating point mantissa
;      d2 holds sign extended floating point exponent
;EXIT  d1/d4 changed
;      V=0: d0 rounded to 24 bit value and normalised
;           d2 contains exponent of normalised number
;      V=1: overflow error, d0/d2 uncertain

format	bsr	justfy	justify, then round up
	moveq	#$40,d1	any set bit in least
	add.l	d1,d0	significant place-1
	bsr	justfy	then justify again
	
	asr	#1,d2	test exponent by shifting
	roxl.b	#1,d2	and back to original place
	bvc	result	taking the exit
	bcs	ufexit	appropriate to the
	bra	ovexit	exponent condition
	
;Compute the product or quotient sign of two working format f.p.
;mantissa and return the absolutes value of each
;ENTRY d0 & d1 contain two's complement numbers
;EXIT  d0 & d1 contain absolute values
;      bit 31,d4=sign (d0) EOR sign (d1)

xtsign	moveq	#1,d4	clear result sign
	tst.l	d0	test 1st number and skip
	bpl	nxts1	if positive (absolute),
	neg.l	d0	else make absolute and
	neg	d4	change result sign

nxts1	tst.l	d1	test 2nd number and skip
	bpl	nxts2	if positive (absolute),
	neg.l	d1	else make absolute and
	neg	d4	change result sign
nxts2	rts		exit with result sign

;Subtract or add two floating point numbers, returning correctly 
;normalised result or error information
;ENTRY d0=1st number
;      d1=2nd number
;EXIT  reg/flag	no error	error
;      d0	result	uncertain
;      d1-a7	unchanged	unchanged
;      X	unchanged	unchanged
;      N	result state	0
;      Z	result state	0
;      V	0	1=overflow
;      C	0	0

fpsub	bsr	entry	conv i/p numbers to expanded format
	cmp	d4,d3	if 2nd No=0 then exit
	beq	result	with 1st number as result
	exg	d0,d1	else exchange numbers
	exg	d2,d3	and negate new 1st number
	neg.l	d0	for addition of negative
	bsr	justfy	value, justify it and
	bra	fpaddx	go to addition test
	
fpadd	bsr	entry	conv i/p numbers to expanded format
	cmp	d4,d2	test 1st number and if not
	bne	fpaddx	0 then skip, else
	move.l	d1,d0	2nd number is result, so
	move	d3,d2	move to result registers
	bra	result	and exit with result
	
fpaddx	cmp	d4,d3	if 2nd number=0 then
	beq	result	result is 1st number, else
	cmp	d3,d2	test magnitudes, placing
	bge	addnum	largest in result
	exg	d0,d1	registers, d0 & d2
	exg	d2,d3
	
addnum	move	d2,d4	get exponent difference
	sub	d3,d4	in d4 for later shift
	cmp	#24,d4	count, but test for shift count exceeding
	bhi	result	precision, if so exit with result=1st No
	asr.l	d4,d1	make 2nd mantissa same
	add.l	d1,d0	order as 1st and add it
	bra	format	then format and exit
	
;Multiply two f.p. numbers, returning correctly normalised result or error information
;ENTRY d0=multiplicand
;      d1=multiplier
;EXIT  reg/flag	no error	error
;      d0	product	uncertain
;      d1-a7	unchanged	unchanged
;      X	unchanged	unchanged
;      N	result state	0
;      Z	result state	0
;      V	0	1=overflow
;      C	0	0

fpmul	bsr	entry	convert i/p numbers to expanded format
	cmp	d4,d2	test 1st No for zero and if so 
	beq	ufexit	exit via underflow to return zero result
	
	cmp	d4,d3	test 2nd No for zero and if so 
	beq	ufexit	exit via underflow to return zero result
	
	bsr	xtsign	get absolute values and
	move	d4,-(sp)	stack product sign
	clr.l	d5	clr product accumulator
	moveq	#24,d4	set mul loop
	
muloop	add.l	d1,d1	test next multiplier bit
	bcc	mulpna	skip if no add this place
	add.l	d0,d5	else add multiplicand
mulpna	lsr.l	#1,d0	shift multiplicand to next
	dbra	d4,muloop	place, repeat for 25 bits ensuring correct rounding

	add	d3,d2	add exponents
	
prodct	move.l	d5,d0	put mantissa in result reg
	tst	(sp)+	and test result sign, skip
	bmi	prodmi	to 1 negate if negative
	neg.l	d0	negate at least once to
prodmi	neg.l	d0	give correct V flag
	bra	format	exit through format routine
	
;Divide two f.p. numbers, returning correctly normalised result or error info
;ENTRY d0=dividend
;      d1=divisor
;EXIT  reg/flag	no error	error
;      d0	quotient	uncertain
;      d1-a7	unchanged	unchanged
;      X	unchanged	unchanged
;      N	result state	0
;      Z	result state	1=division by zero
;      V	0	1=error flag
;      C	0	0

fpdiv	bsr	entry	conv numbers to expanded format
	cmp	d4,d3	if 2nd No=0 then 
	beq	dzexit	exit setting 'div/0' flag
	
	cmp	d4,d2	if 1st No=0 then exit
	beq	ufexit	via underflow with zero result
	
	bsr	xtsign	get absolute values and quotient sign, saving
	move	d4,-(sp)	sign on stack for later
	moveq	#24,d4	set div loop count
	lsr.l	#1,d0	adjust dividend to prevent
	addq	#1,d2	erroneous overflow
	
divlp	sub.l	d1,d0	try to subtract divisor
	bcc	divok	skip if subtraction OK
	add.l	d1,d0	else add divisor back
divok	addx.l	d5,d5	shift result complement
	add.l	d0,d0	shift dividend one place
	dbra	d4,divlp	repeat 25 times to ensure correct rounding
	
	not.l	d5	correct complemented
	asl.l	#7,d5	result & move to position
	sub	d3,d2	subtract exponents
	bra	prodct	complete as for mul
	
;Extracts the square root of a f.p. number returning correctly normalised
;result or error information
;ENTRY d0=square
;EXIT  reg/flag	no error	error
;      d0	root	uncertain
;      d1-a7	unchanged	unchanged
;      X	unchanged	unchanged
;      N	0	1=negative input
;      Z	root state	0
;      V	0	1=error flag
;      C	0	0
	
fpsqrt	bsr	entry	conv i/p number to expanded format
	cmp	d4,d2	if square=0 then exit
	beq	ufexit	via underflow to return 0 root
	
	tst.l	d0	if square=negative
	bmi	ngexit	then exit setting 'neg i/p' flag
	
	addq	#1,d2	root exponent by rounding
	asr	#1,d2	and halving, correcting
	bcc	sqrtns	mantissa if exponent was
	asl.l	#1,d0	even
	
sqrtns	rol.l	#8,d0	move mantissa into low
	moveq	#0,d1	byte d1 and high word d0,
	move.b	d0,d1	clearing all other bytes
	clr.b	d0	of d1, d0
	
	moveq	#$40,d3	set initial subtrahend
	moveq	#23,d4	set root loop count
	
sqloop	sub.l	d3,d1	try subtracting part root
	bcc	sqlsub	and skip of OK, else
	add.l	d3,d1	add back
	
sqlsub	roxr.b	#1,d3	shift part root up one
	addx.l	d3,d3	place getting corrected
	eor	#$100,d3	result in bit 8, leaving bit 6 set
	
	add.l	d0,d0	shift next bit pair of
	addx.l	d1,d1	square remainder up into
	add.l	d0,d0	place
	addx.l	d1,d1
	dbra	d4,sqloop	repeat 24 times giving 24 bit chopped root
	
	roxr.l	#1,d1	extract last bit
	lsr.l	#1,d3	for rounding
	cmp.l	d3,d1
	bcs	sqrtnx
	or.b	#$40,d3
	
sqrtnx	move.l	d3,d0	move root to result reg
	bra	format	and exit after formatting
