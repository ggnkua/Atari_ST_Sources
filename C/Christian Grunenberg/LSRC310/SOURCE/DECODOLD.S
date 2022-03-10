
			EXPORT		DecodeOld

			IMPORT		OpenOut
			IMPORT		ProcInd
			IMPORT		shipout_decode
			IMPORT		fill_buf
			IMPORT		block_crc

			IMPORT		text_buf
			IMPORT		codesize
			IMPORT		blocksize
			IMPORT		file1
			IMPORT		outrec_decode
			IMPORT		has_crc
			IMPORT		buffer_3

N			.equ	4096
F			.equ	18
THRESHOLD	.equ	2


_empty_1:	MOVE.L		A5,4(A4)
			MOVE.L		D2,(A4)
			MOVEA.L		A4,A0
			BSR			fill_buf
			MOVE.B		D0,D3
			MOVE.L		(A4),D2
			MOVEA.L		4(A4),A5
			BRA			_got_1

_empty_2:	MOVE.L		A5,4(A4)
			MOVE.L		D2,(A4)
			MOVEA.L		A4,A0
			BSR			fill_buf
			MOVE.L		(A4),D2
			MOVEA.L		4(A4),A5
			BRA			_got_2

_empty_3:	MOVE.L		A5,4(A4)
			MOVE.L		D2,(A4)
			MOVEA.L		A4,A0
			BSR			fill_buf
			MOVE.W		D0,D1
			MOVE.L		(A4),D2
			MOVEA.L		4(A4),A5
			BRA			_got_3

_empty_4:	MOVE.L		A5,4(A4)
			MOVE.L		D2,(A4)
			MOVEA.L		A4,A0
			BSR			fill_buf
			MOVE.L		(A4),D2
			MOVEA.L		4(A4),A5
			BRA			_got_4

; void DecodeOld(void)
DecodeOld:	MOVEM.L 	D3-D7/A2-A6,-(A7)

;	ProcInd();
			JSR 		ProcInd

;	OpenOut(&outrec_decode);
			LEA.L		outrec_decode(PC),A0
			MOVE.L		buffer_3,A1
			BSR 		OpenOut
			LEA.L		outrec_decode(PC),A1
			MOVEA.L		(A1)+,A6
			MOVE.L		(A1),D7

			MOVE.W		#N-1,A2

;	register int r=N-F,*tbuf=(int *) text_buf;
			MOVE.W		#N-F,D4
			LEA.L		text_buf,A3

;	long todo=codesize,done=blocksize;
			MOVE.L		blocksize(PC),D6
			MOVE.L		codesize(PC),D5

;	uint flags=0;
			MOVEQ.L		#0,D3

;	for (c=0x2020,k=(N-F)>>1;--k>=0;)
			MOVE.W		#$2020,D0
			MOVE.W		#((N-F)>>1)-1,D1
			MOVEA.L 	A3,A0

;	   *tbuf++=c;
tbuf_init:	MOVE.W		D0,(A0)+
			DBRA		D1,tbuf_init

;	for (;;)
			MOVEA.L 	file1(PC),A4
			MOVE.L		(A4),D2
			MOVEA.L		4(A4),A5		; file1->_ptr

for:
;		if (!((flags>>=1) & 256))
			LSR.W		D3
			BTST.B		#8,D3
			BNE.B		no_flags

			MOVE.W		#$FF00,D3
;			flags=getc(file1)|0xff00;
			DBRA		D2,_get_1	; _cnt
			ADDQ.W		#1,D2
			SUBQ.L		#1,D2
			BMI			_empty_1

_get_1:
			MOVE.B		(A5)+,D3	; *_ptr++
_got_1:
;			if (--todo<0) break;
			SUBQ.L		#2,D5
			BPL.B		cont_0
			BRA			break

no_flags:
;		if (--todo<0) break;
			DBRA		D5,cont_0
			ADDQ.W		#1,D5
			SUBQ.L		#1,D5
			BMI	 		break

cont_0:
;		if (flags & 1)
			MOVEQ.L		#1,D0
			AND.W		D3,D0
			BEQ.B		flag_bit_0_eq

;			c=getc(file1);
			DBRA		D2,_get_2	; _cnt
			ADDQ.W		#1,D2
			SUBQ.L		#1,D2
			BMI			_empty_2

_get_2:
			MOVE.B		(A5)+,D0	; *_ptr++
_got_2:
;			text_buf[r++]=c;
			MOVE.B		D0,(A3,D4.W)
			ADDQ.W		#1,D4

;			r&=m;
			AND.W		#N-1,D4

;			putc(c);
			MOVE.B		D0,(A6)+
			DBRA		D7,_buf_exit_1
			ADDQ.W		#1,D7
			SUBQ.L		#1,D7
			BPL.B		_buf_exit_1

			BSR			ship

_buf_exit_1:
;			if (--done>0)
			DBRA		D6,for
			ADDQ.W		#1,D6
			SUBQ.L		#1,D6
			BPL.B		for

;				ProcInd();
			MOVE.L		D2,-(SP)
			JSR 		ProcInd
			MOVE.L		(SP)+,D2
			LEA.L		outrec_decode+4(PC),A1

;				done=blocksize;
			MOVE.L		blocksize(PC),D6
			BRA.B 		for

;		else


flag_bit_0_eq:
;			i=getc(file1);
			DBRA		D2,_get_3	; _cnt
			ADDQ.W		#1,D2
			SUBQ.L		#1,D2
			BMI			_empty_3

_get_3:
			MOVEQ.L		#0,D1
			MOVE.B		(A5)+,D1	; *_ptr++

_got_3:
;			if (--todo<0) break;
			DBRA		D5,cont_1
			ADDQ.W		#1,D5
			SUBQ.L		#1,D5
			BMI 		break;

cont_1:
;			i|=(((k=getc(file1)) & 0xf0)<<4);
			DBRA		D2,_get_4	; _cnt
			ADDQ.W		#1,D2
			SUBQ.L		#1,D2
			BMI			_empty_4

_get_4:
			MOVE.B		(A5)+,D0	; *_ptr++
_got_4:
			EXG.L		D2,A2
			SWAP		D3
			MOVE.W		D0,D3
			AND.W		#$0F,D3
			EOR.W		D3,D0
			LSL.W		#4,D0
			OR.W		D0,D1

;			k=(k & 0x0f) + THRESHOLD;
			ADDQ.W		#THRESHOLD,D3

for_k:
;				c=text_buf[i & m];
			AND.W		D2,D1
			MOVE.B		(A3,D1.W),D0

;				text_buf[r++]=c;
			MOVE.B		D0,(A3,D4.W)
			ADDQ.W		#1,D4

;				r&=m;
			AND.W		D2,D4

;				putc(c);
			MOVE.B		D0,(A6)+
			DBRA		D7,_buf_exit_2
			ADDQ.W		#1,D7
			SUBQ.L		#1,D7
			BPL.B		_buf_exit_2

			BSR			ship

_buf_exit_2:
;				if (--done<0)
			DBRA		D6,not_done
			ADDQ.W		#1,D6
			SUBQ.L		#1,D6
			BPL.B		not_done

;					ProcInd();
			MOVE.W		D1,-(SP)
			JSR 		ProcInd
			MOVE.W		#N-1,D2
			MOVE.W		(SP)+,D1
			LEA.L		outrec_decode+4(PC),A1

;					done=blocksize;
			MOVE.L		blocksize(PC),D6

not_done:
;			for (;--k>=0;i++)
			ADDQ.W		#1,D1
			DBRA		D3,for_k
			EXG.L		D2,A2
			SWAP		D3
			BRA 		for

break:
			MOVE.L		A5,4(A4)
			MOVE.L		D2,(A4)
;	shipout_decode();
			bsr			ship
;}
			MOVEM.L 	(A7)+,D3-D7/A2-A6
			RTS


ship:		MOVE.L		D7,(A1)
			MOVE.L		A6,-(A1)

			TST.B		has_crc
			BEQ.B		no_crc

			MOVE.L		8(A1),A0
			MOVE.L		A6,D0
			SUB.L		A0,D0
			JSR			block_crc

no_crc:		BSR			shipout_decode
			MOVEA.L		(A1)+,A6
			MOVE.L		(A1),D7
			RTS
