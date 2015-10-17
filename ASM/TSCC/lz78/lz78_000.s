******************************************************
*  void d_lz78(a0.l * LZ78Stream, a1.l * outputStream)
*
* Variable length LZ78 decoder. Modifies d0-d7/a0-a5.
******************************************************

;>DEBUG:				; Uncomment this for debugging mode
CODE_BITS	=	12		; Bitwidth of a input stream codeword
MAX_VALUE	=	(1<<CODE_BITS)-1; Termination value
MAX_CODE	=	MAX_VALUE-1	; Maximum code value
STACK_LEN	=	4000		; Length of the decoding stack

		section text
d_lz78: 	lea.l	decodeStack,a2
		lea.l	prefixCode,a3
		lea.l	appendChar,a4

		move.w	#256,d5		; Next available code to define

		addq.l	#4,a0		; Skip original length
		bsr.s	inputCode	; Read in the first code and initialize
		move.w	d0,d6		; oldCode
		move.b	d0,d7		; char
		move.b	d7,(a1)+

.decodeLoop:	bsr.s	inputCode	; inputCode() == MAX_VALUE?
		cmpi.w	#MAX_VALUE,d0
		beq.s	.return


; Handle special case with string+character+string+character+string

		cmp.w	d5,d0		; newCode >= nextCode?
		blo.s	.normal
		move.b	d7,(a2)+	; *decodeStack++ = char
		move.w	d6,d4	 	; decodeString(decodeStack,oldCode)
		bra.s	.decodeString


; Do a straight decode otherwise

.normal:	move.w	d0,d4		; decodeString(decodeStack,newCode)
.decodeString:	bsr.s	decodeString


; Output string in reverse order

		move.b	(a2)+,d7	; char = *stack
		lea.l	decodeStack,a5

.output:	move.b	-(a2),(a1)+
		cmpa.l	a5,a2
		bhi.s	.output


; Add a new record to the string table if possible

		cmpi.w	#MAX_CODE,d5	; nextCode <= MAX_CODE?
		bhi.s	.next		; yes, go and add new code

		move.w	d5,d4
		add.w	d4,d4
		move.w	d6,(a3,d4.w)	; prefixCode[nextCode] = oldCode
		move.b	d7,(a4,d5.w)	; appendChar[nextCode] = char
		addq.w	#1,d5		; nextCode++

.next:		move.w	d0,d6		; oldCode = newCode
		bra.s	.decodeLoop

.return:	rts


******************************************************
*  a2.l * decodeString(a2.l * stack, d4.w code,
*		       a4.l appendCharTable[],
*		       a3.l prefixCodeTable[])
*
* Return the decoded string to a given code value.
******************************************************

decodeString:
	ifd	DEBUG
		moveq.l	#0,d1		; i = 0
	endc

.appendLoop:	cmpi.w	#255,d4
		bls.s	.break

		move.b	(a4,d4.w),(a2)+	; *stack++ = appendChar[code]
		add.w	d4,d4
		move.w	(a3,d4.w),d4	; code = prefixCode[code]

	ifd	DEBUG
		cmpi.w	#MAX_CODE,d1	; i < MAX_CODE?
		blo.s	.codeOk
		illegal 		; Error during decoding process

.codeOk:	addq.w	#1,d1		; i++
	endc
		bra.s	.appendLoop

.break: 	move.b	d4,(a2)		; *stack = code
		rts


******************************************************
*  d0.w inputCode(a0.l * inputStream)
*
* Read a variable length bitfield from the packed input
* stream.
******************************************************

inputCode:	lea.l	.bitcount(pc),a5
		move.w	(a5)+,d0	; Load current shift value

		moveq.l #7,d1		; bitcount % 8
		and.w	d0,d1

		lsr.w	#3,d0		; bitcount / 8 (# bytes to read)
		moveq.l #0,d2

.readByte:	lsl.l	#8,d2
		move.b	(a0)+,d2
		subq.w	#1,d0
		bne.s	.readByte

		lsl.l	d1,d2		; Shift input into position and
		or.l	(a5)+,d2	; merge bitfields

		moveq.l #CODE_BITS,d3	; return(bitbuffer >> (32-CODE_BITS))
		rol.l	d3,d2		; Sloooow... (use swap.w + rol.l instead
		move.w	#MAX_VALUE,d0	; for speed)
		and.w	d2,d0

		eor.w	d0,d2		; bitbuffer <<= CODE_BITS
		move.l	d2,-(a5)
		add.w	d3,d1		; bitcount += CODE_BITS
		move.w	d1,-(a5)
		rts

.bitcount:	dc.w 32
.bitbuffer:	dc.l 0


		section bss
prefixCode:	ds.w	1<<CODE_BITS	; Prefix codes
appendChar:	ds.b	1<<CODE_BITS	; Chars appended during the decode
decodeStack:	ds.b	STACK_LEN	; String decode buffer
		even
