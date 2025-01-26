*------------------------------------------------------------------------------
* PRO-PACK Unpack Source Code (Compact Version) - MC68000, Method 2 
*
* Copyright (c) 1991,92 Rob Northen Computing, U.K. All Rights Reserved.
*
* File: RNC_2C.S
*
* Date: 24.03.92
*------------------------------------------------------------------------------

*------------------------------------------------------------------------------
* Equates
*------------------------------------------------------------------------------

input		EQUR	a0
output		EQUR	a1
temp		EQUR	a2

len		EQUR	d0
pos		EQUR	d1
bitbuf		EQUR	d2

*------------------------------------------------------------------------------
* Macros
*------------------------------------------------------------------------------

getbit		MACRO
		add.b	bitbuf,bitbuf
		ENDM

reload		MACRO
		move.b	(input)+,bitbuf
		addx.b	bitbuf,bitbuf
		ENDM

getraw		MACRO
		move.b	(input)+,(output)+
		ENDM

getrawREP	MACRO
getrawREP2\@
		move.b	(input)+,(output)+
		move.b	(input)+,(output)+
		move.b	(input)+,(output)+
		move.b	(input)+,(output)+
		dbra	pos,getrawREP2\@
		ENDM

*------------------------------------------------------------------------------
* Unpack Routine (Compact Version) - MC68000, Method 2
*
* on entry,
*	a0.l = start address of packed file
*	a1.l = start address to write unpacked file
*	(note: a1 cannot be equal to a0)
*	stack space required: $1C bytes
*
*	all other registers are preserved
*------------------------------------------------------------------------------
Unpack
		movem.l	d0-d2/a0-a2,-(sp)
		lea	18(input),input
		moveq	#-$80,bitbuf
		add.b	bitbuf,bitbuf
		reload
		getbit
		bra	GetBits2

*------------------------------------------------------------------------------

Fetch0
		reload
		bra.s	Back0
Fetch1
		reload
		bra.s	Back1
Fetch2
		reload
		bra.s	Back2
Fetch3
		reload
		bra.s	Back3
Fetch4
		reload
		bra.s	Back4
Fetch5
		reload
		bra.s	Back5
Fetch6
		reload
		bra.s	Back6
Fetch7
		reload
		bra.s	Back7

Raw
		moveq	#3,len
x4Bits
		add.b	bitbuf,bitbuf
		beq.s	Fetch0
Back0
		addx.w	pos,pos
		dbra	len,x4Bits
		addq.w	#2,pos
		getrawREP
		bra.s	GetBits2

*------------------------------------------------------------------------------

GetLen
		getbit
		beq.s	Fetch1
Back1
		addx.w	len,len
		getbit
		beq.s	Fetch2
Back2
		bcc.s	Copy
		subq.w	#1,len
		getbit
		beq.s	Fetch3
Back3
		addx.w	len,len

		cmp.b	#9,len
		beq.s	Raw

*------------------------------------------------------------------------------

Copy
		getbit
		beq.s	Fetch4
Back4
		bcc.s	ByteDisp2
		getbit
		beq.s	Fetch5
Back5
		addx.w	pos,pos
		getbit
		beq.s	Fetch6
Back6
		bcs.s	BigDisp
		tst.w	pos
		bne.s	ByteDisp
		addq.w	#1,pos
Another
		getbit
		beq.s	Fetch7
Back7
		addx.w	pos,pos

ByteDisp
		rol.w	#8,pos
ByteDisp2
		move.b	(input)+,pos
		move.l	output,temp
		sub.w	pos,temp
		subq.w	#1,temp
		lsr.w	#1,len
		bcc.s	ByteDisp3
		move.b	(temp)+,(output)+
ByteDisp3
		subq.w	#1,len
		tst.w	pos
		bne.s	ByteDisp5
		move.b	(temp),pos
ByteDisp4
		move.b	pos,(output)+
		move.b	pos,(output)+
		dbra	len,ByteDisp4
		bra.s	GetBits2
ByteDisp5
		move.b	(temp)+,(output)+
		move.b	(temp)+,(output)+
		dbra	len,ByteDisp5
		bra.s	GetBits2

*------------------------------------------------------------------------------

GetBits
		reload
		bcs.s	String
xByte
		getraw
GetBits2
		getbit
		bcs.s	Chkz
		getraw
		getbit
		bcc.s	xByte
Chkz
		beq.s	GetBits

*------------------------------------------------------------------------------

String
		moveq	#2,len
		moveq	#0,pos
		getbit
		beq.s	Fetch8
Back8
		bcc	GetLen

Smalls
		getbit
		beq.s	Fetch9
Back9
		bcc.s	ByteDisp2
		addq.w	#1,len
		getbit
		beq.s	Fetch10
Back10
		bcc.s	Copy

		move.b	(input)+,len
		beq.s	OverNout
		addq.w	#8,len
		bra.s	Copy

BigDisp
		getbit
		beq.s	Fetch11
Back11
		addx.w	pos,pos
		or.w	#4,pos
		getbit
		beq.s	Fetch12
Back12
		bcs.s	ByteDisp
		bra.s	Another

Fetch8
		reload
		bra.s	Back8
Fetch9
		reload
		bra.s	Back9
Fetch10
		reload
		bra.s	Back10
Fetch11
		reload
		bra.s	Back11
Fetch12
		reload
		bra.s	Back12
OverNout
		getbit
		bne.s	Check4end
		reload
Check4end
		bcs.s	GetBits2
		movem.l	(sp)+,d0-d2/a0-a2
		rts
