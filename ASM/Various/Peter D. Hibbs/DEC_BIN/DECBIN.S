;Convert decimal number in RAM buffer to binary in d0.l	
;ENTRY a0 points at any digit of decimal number in RAM
;EXIT  d0.l=binary value

dec_bin	movem.l	d1/a0-a1,-(sp)
dec_bin1	add.l	#1,a0	find LSD
	bsr	numchk	check if numeric
	bcc	dec_bin1
	sub.l	#1,a0	a0=LSD

	lea	dec_table+36,a1	access powers of 10 table
	clr.l	d0	reset d0 to 0000
dec_bin2	move.b	(a0),d1	fetch digit
dec_bin3	cmp.b	#'0',d1	is it zero
	beq	dec_bin4	exit if yes
	add.l	(a1),d0	add power of 10
	sub	#1,d1	dec digit value
	bra	dec_bin3	loop
	
dec_bin4	sub.l	#1,a0	next ASCII digit
	sub.l	#4,a1	next power of 10
	bsr	numchk	check if end of string
	bcc	dec_bin2	loop if not
	movem.l	(sp)+,d1/a0-a1
	rts
	
;Number check
;ENTRY a0 points at RAM address holding value
;EXIT  Cy=1 if (a0) is non-numeric
;      Cy=0 if (a0) is 30H-39H

numchk	cmp.b	#'0',(a0)	(a0)<'0'
	bcs	numchk1	flag=1
	cmp.b	#'9'+1,(a0)	(a0)>'9'
	eor	#1,ccr	invert flag
numchk1	rts

dec_table	dc.l	1000000000
	dc.l	100000000
	dc.l	10000000
	dc.l	1000000
	dc.l	100000
	dc.l	10000
	dc.l	1000
	dc.l	100
	dc.l	10
	dc.l	1
