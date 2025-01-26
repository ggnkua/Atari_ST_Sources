*------------------------------------------------------------------------------
* PRO-PACK Unpack Source Code - MC68000, Method 1
*
* Copyright (c) 1991,92 Rob Northen Computing, U.K. All Rights Reserved.
*
* File: RNC_1.S
*
* Date: 24.3.92
*------------------------------------------------------------------------------

*------------------------------------------------------------------------------
* Conditional Assembly Flags
*------------------------------------------------------------------------------

CHECKSUMS	EQU	0		; set this flag to 1 if you require
					; the data to be validated

PROTECTED	EQU	0		; set this flag to 1 if you are unpacking
					; a file packed with option "-K"

*------------------------------------------------------------------------------
* Return Codes
*------------------------------------------------------------------------------

NOT_PACKED	EQU	0
PACKED_CRC	EQU	-1
UNPACKED_CRC	EQU	-2

*------------------------------------------------------------------------------
* Other Equates
*------------------------------------------------------------------------------

PACK_TYPE	EQU	1
PACK_ID		EQU	"R"<<24+"N"<<16+"C"<<8+PACK_TYPE
HEADER_LEN	EQU	18
MIN_LENGTH	EQU	2
CRC_POLY	EQU	$A001
RAW_TABLE	EQU	0
POS_TABLE	EQU	RAW_TABLE+16*8
LEN_TABLE	EQU	POS_TABLE+16*8


		IFEQ	CHECKSUMS
BUFSIZE		EQU	16*8*3
		ELSEIF
BUFSIZE		EQU	512
		ENDC

counts		EQUR	d4
key		EQUR	d5
bit_buffer	EQUR	d6
bit_count	EQUR	d7

input		EQUR	a3
input_hi	EQUR	a4
output		EQUR	a5
output_hi	EQUR	a6

*------------------------------------------------------------------------------
* Macros
*------------------------------------------------------------------------------

getrawREP	MACRO
getrawREP2\@
		move.b	(input)+,(output)+
		IFNE PROTECTED
		eor.b	key,-1(output)
		ENDC
		dbra	d0,getrawREP2\@
		IFNE PROTECTED
		ror.w	#1,key
		ENDC
		ENDM

*------------------------------------------------------------------------------
* PRO-PACK Unpack Routine - MC68000, Method 1
*
* on entry,
*	d0.l = packed data key, or 0 if file was not packed with a key
*	a0.l = start address of packed file
*	a1.l = start address to write unpacked file
* on exit,
*	d0.l = length of unpacked file in bytes OR error code
*		 0 = not a packed file
*		-1 = packed data CRC error
*		-2 = unpacked data CRC error
*
*	all other registers are preserved
*------------------------------------------------------------------------------
Unpack
		movem.l	d0-d7/a0-a6,-(sp)
		lea	-BUFSIZE(sp),sp
		move.l	sp,a2

		IFNE PROTECTED
		move.w	d0,key
		ENDC

		bsr	read_long
		moveq.l	#NOT_PACKED,d1
		cmp.l	#PACK_ID,d0
		bne	unpack16
		bsr	read_long
		move.l	d0,BUFSIZE(sp)
		lea	HEADER_LEN-8(a0),input
		move.l	a1,output
		lea	(output,d0.l),output_hi
		bsr	read_long
		lea	(input,d0.l),input_hi

		IFNE	CHECKSUMS
		move.l	input,a1
		bsr	crc_block
		lea	-6(input),a0
		bsr	read_long
		moveq.l	#PACKED_CRC,d1
		cmp.w	d2,d0
		bne	unpack16
		swap	d0
		move.w	d0,-(sp)
		ENDC

		clr.w	-(sp)
		cmp.l	input_hi,output
		bcc.s	unpack7
		moveq.l	#0,d0
		move.b	-2(input),d0
		lea	(output_hi,d0.l),a0
		cmp.l	input_hi,a0
		bls.s	unpack7
		addq.w	#2,sp

		move.l	input_hi,d0
		btst	#0,d0
		beq.s	unpack2
		addq.w	#1,input_hi
		addq.w	#1,a0
unpack2
		move.l	a0,d0
		btst	#0,d0
		beq.s	unpack3
		addq.w	#1,a0
unpack3
		moveq.l	#0,d0
unpack4
		cmp.l	a0,output_hi
		beq.s	unpack5
		move.b	-(a0),d1
		move.w	d1,-(sp)
		addq.b	#1,d0
		bra.s	unpack4
unpack5
		move.w	d0,-(sp)
		add.l	d0,a0
		IFNE PROTECTED
		move.w	key,-(sp)
		ENDC
unpack6
		lea	-8*4(input_hi),input_hi
		movem.l	(input_hi),d0-d7
		movem.l	d0-d7,-(a0)
		cmp.l	input,input_hi
		bhi.s	unpack6
		sub.l	input_hi,input
		add.l	a0,input
		IFNE PROTECTED
		move.w	(sp)+,key
		ENDC

unpack7		
		moveq.l	#0,bit_count
		move.b	1(input),bit_buffer
		rol.w	#8,bit_buffer
		move.b	(input),bit_buffer
		moveq.l	#2,d0
		moveq.l	#2,d1
		bsr	input_bits
unpack8
		move.l	a2,a0
		bsr	make_huftable
		lea	POS_TABLE(a2),a0
		bsr	make_huftable
		lea	LEN_TABLE(a2),a0
		bsr	make_huftable
unpack9
		moveq.l	#-1,d0
		moveq.l	#16,d1
		bsr	input_bits
		move.w	d0,counts
		subq.w	#1,counts
		bra.s	unpack12		
unpack10
		lea	POS_TABLE(a2),a0
		moveq.l	#0,d0
		bsr.s	input_value
		neg.l	d0
		lea	-1(output,d0.l),a1
		lea	LEN_TABLE(a2),a0
		bsr.s	input_value
		move.b	(a1)+,(output)+
unpack11
		move.b	(a1)+,(output)+
		dbra	d0,unpack11
unpack12
		move.l	a2,a0
		bsr.s	input_value
		subq.w	#1,d0
		bmi.s	unpack13
		getrawREP
		move.b	1(input),d0
		rol.w	#8,d0
		move.b	(input),d0
		lsl.l	bit_count,d0
		moveq.l #1,d1
		lsl.w	bit_count,d1
		subq.w	#1,d1
		and.l 	d1,bit_buffer
		or.l	d0,bit_buffer
unpack13
		dbra	counts,unpack10
		cmp.l	output_hi,output
		bcs.s	unpack8

		move.w	(sp)+,d0
		beq.s	unpack15
		IFNE	CHECKSUMS
		move.l	output,a0
		ENDC
unpack14
		move.w	(sp)+,d1
		IFNE	CHECKSUMS
		move.b	d1,(a0)+
		ELSEIF
		move.b	d1,(output)+
		ENDC
		subq.b	#1,d0
		bne.s	unpack14
unpack15

		IFNE	CHECKSUMS
		move.l	BUFSIZE+2(sp),d0
		sub.l	d0,output
		move.l	output,a1
		bsr	crc_block
		moveq.l	#UNPACKED_CRC,d1
		cmp.w	(sp)+,d2
		beq.s	unpack17
		ELSEIF
		bra.s	unpack17
		ENDC
unpack16
		move.l	d1,BUFSIZE(sp)
unpack17
		lea	BUFSIZE(sp),sp
		movem.l	(sp)+,d0-d7/a0-a6
		rts

input_value
		move.w	(a0)+,d0
		and.w	bit_buffer,d0
		sub.w	(a0)+,d0
		bne.s	input_value
		move.b	16*4-4(a0),d1
		sub.b	d1,bit_count
		bge.s	input_value2
		bsr.s	input_bits3
input_value2
		lsr.l	d1,bit_buffer
		move.b	16*4-3(a0),d0
		cmp.b	#2,d0
		blt.s	input_value4
		subq.b	#1,d0
		move.b	d0,d1
		move.b	d0,d2
		move.w	16*4-2(a0),d0
		and.w	bit_buffer,d0
		sub.b	d1,bit_count
		bge.s	input_value3
		bsr.s	input_bits3
input_value3
		lsr.l	d1,bit_buffer
		bset	d2,d0
input_value4
		rts

input_bits
		and.w	bit_buffer,d0
		sub.b	d1,bit_count
		bge.s	input_bits2
		bsr.s	input_bits3
input_bits2
		lsr.l	d1,bit_buffer
		rts

input_bits3
		add.b	d1,bit_count
		lsr.l	bit_count,bit_buffer
		swap	bit_buffer
		addq.w	#4,input
		move.b	-(input),bit_buffer
		rol.w	#8,bit_buffer
		move.b	-(input),bit_buffer
		swap	bit_buffer
		sub.b	bit_count,d1
		moveq.l	#16,bit_count
		sub.b	d1,bit_count
		rts

read_long
		moveq.l	#3,d1
read_long2
		lsl.l	#8,d0
		move.b	(a0)+,d0
		dbra	d1,read_long2
		rts

make_huftable
		moveq.l	#$1f,d0
		moveq.l	#5,d1
		bsr.s	input_bits
		subq.w	#1,d0
		bmi.s	make_huftable8
		move.w	d0,d2
		move.w	d0,d3
		lea	-16(sp),sp
		move.l	sp,a1
make_huftable3
		moveq.l	#$f,d0
		moveq.l	#4,d1
		bsr.s	input_bits
		move.b	d0,(a1)+
		dbra	d2,make_huftable3
		moveq.l	#1,d0
		ror.l	#1,d0
		moveq.l	#1,d1
		moveq.l	#0,d2
		movem.l	d5-d7,-(sp)
make_huftable4
		move.w	d3,d4
		lea	12(sp),a1
make_huftable5
		cmp.b	(a1)+,d1
		bne.s	make_huftable7
		moveq.l	#1,d5
		lsl.w	d1,d5
		subq.w	#1,d5
		move.w	d5,(a0)+
		move.l	d2,d5
		swap	d5
		move.w	d1,d7
		subq.w	#1,d7
make_huftable6
		roxl.w	#1,d5
		roxr.w	#1,d6
		dbra	d7,make_huftable6
		moveq.l	#16,d5
		sub.b	d1,d5
		lsr.w	d5,d6
		move.w	d6,(a0)+
		move.b	d1,16*4-4(a0)
		move.b	d3,d5
		sub.b	d4,d5
		move.b	d5,16*4-3(a0)
		moveq.l	#1,d6
		subq.b	#1,d5
		lsl.w	d5,d6
		subq.w	#1,d6
		move.w	d6,16*4-2(a0)
		add.l	d0,d2
make_huftable7
		dbra	d4,make_huftable5
		lsr.l	#1,d0
		addq.b	#1,d1
		cmp.b	#17,d1
		bne.s	make_huftable4
		movem.l	(sp)+,d5-d7
		lea	16(sp),sp
make_huftable8
		rts

		IFNE	CHECKSUMS
crc_block
		move.l	a2,a0
		moveq.l	#0,d3
crc_block2
		move.l	d3,d1
		moveq.l	#7,d2
crc_block3
		lsr.w	#1,d1
		bcc.s	crc_block4
		eor.w	#CRC_POLY,d1
crc_block4
		dbra	d2,crc_block3
		move.w	d1,(a0)+
		addq.b	#1,d3
		bne.s	crc_block2
		moveq.l	#0,d2
crc_block5
		move.b	(a1)+,d1
		eor.b	d1,d2
		move.w	d2,d1
		and.w	#$ff,d2
		add.w	d2,d2
		move.w	(a2,d2.w),d2
		lsr.w	#8,d1
		eor.b	d1,d2
		subq.l	#1,d0
		bne.s	crc_block5
		rts
		ENDC
