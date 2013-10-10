*******
* Write part 2 (main) of POVERTY DEMO (STE version)
******
*

		clr.l	-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,oldstack

A=0
B=1


SECTORS		equ	10	;sectors per track

		lea	part2code,a6	;load address

		move.w	#40,d7		;track number start
		move.w	#A,side		;select side A
		move.w	#1,d6		;start sector
		move.w	#39-1,d5	;write 39 tracks on side A
		bsr	write_loop

		move.w	#1,d7		;track number
		move.w	#B,side		;select side A
		move.w	#1,d6		;start sector
		move.w	#75-1,d5	;write 74 tracks on side B
		bsr	write_loop

		move.l	oldstack,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp

		clr.w	-(sp)
		trap	#1

write_loop	move.w	#SECTORS,-(sp)	;no. sectors to write
		move.w	side,-(sp)	;side
		move.w	d7,-(sp)	;track
		move.w	d6,-(sp)	;sector
		clr.w	-(sp)		;floppy drive A
		clr.l	-(sp)		;reserved
		move.l	a6,-(sp)	;buffer to write from
		move.w	#9,-(sp)
		trap	#14
		lea	20(sp),sp
		tst.l	d0
		bmi.s	error

		move.l	d7,d0
		bsr	printn

		add.l	#SECTORS*512,a6
		add.w	#1,d7		;increase track number
		dbf	d5,write_loop
getout		rts


error		pea	error_mess
		move.w	#9,-(sp)
		trap	#1
		addq.w	#6,sp
		move.w	#7,-(sp)
		trap	#1
		addq.w	#2,sp
		bra.s	getout
;************************************
;* Print out any number in any base *
;*     D0.L=number / D1.L=base      *
;*         Uses D0, D1, A0          *
;************************************
printn
	move.l	#10,d1		;decimal
	LEA buffer(PC),A0	A0=buffer
	CLR.L (A0)+		Zero buffer
	CLR.L (A0)+
	CLR.L (A0)+
	CLR.L (A0)+
	CLR.L (A0)+       A0->buffer end
loop1
	DIVU D1,D0        D0 DIV D1
	SWAP D0           D0.low=remainder
	ADDI #'0',D0      Make into digit
	CMPI #'9',D0      Digit or letter?
	BLE ok
	ADDQ #7,D0        Make into letter
ok
	MOVE.B D0,-(A0)   Store character
	CLR D0
	SWAP D0           D0.low=quotient
	BNE loop1         Another one?
loop2
	MOVE.L A0,-(A7)
	pea	at
	MOVE	#9,-(A7)	Print string
	TRAP	#1		GEMDOS 9
	ADDQ.L	#6,A7		Tidy stack

_conws
	MOVE #9,-(A7)	Print string
	TRAP #1		GEMDOS 9
	ADDQ.L #6,A7	Tidy stack
	RTS
buffer
	DS.L 5		Number$ - 20 digits
	DC.B 0		Buffer end marker
	EVEN

error_mess	dc.b	27,'E'
		dc.b	"ERROR WRITING"
		dc.b	0
	even
side	dc.w	0

at	dc.b	27,'Y',32+0,32+0,"Writing track: ",27,'Y',32+0,32+15
oldstack	dc.l	0

part2code	incbin	e:\poverty\l.exe
part2end
		dcb.l	50,"POV!"
