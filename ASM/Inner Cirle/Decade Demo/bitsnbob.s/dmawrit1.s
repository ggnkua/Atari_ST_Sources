* Decade demo dma file save
* Takes .PRG/.TOS packed demo
* and dma writes onto the demo disk
* (C)1990 Martin Griffiths

side		 = 0
sectoroffset = 1

		MOVE.L 4(SP),A5
		MOVE.L $C(A5),A4
		ADD.L $14(A5),A4
		ADD.L $1C(A5),A4
		LEA $100(A4),A4
		MOVE.L A4,-(SP)
		MOVE.L A5,-(SP)
		CLR -(SP)
		MOVE #$4A,-(SP)
		TRAP #1
		LEA 12(SP),SP
		CLR.L -(SP)
		MOVE #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		LEA my_stack(PC),SP
		DC.W $A00A
		BSR appl_ini
		LEA title(PC),A0
		BSR print
		DC.W $A009
		LEA demoname(PC),A1
		BSR fileselect
		DC.W $A00A
		LEA loading(PC),A0
		BSR print
readfile	LEA demoname(PC),A4
		LEA demo_buffer(PC),A5
		MOVE.l #12345678,D7
		BSR load_file		
		LEA file(PC),A0
		BSR print
		LEA demoname(PC),A0
		BSR print
		LEA lentext(PC),A0
		BSR print
		MOVE.L filelength(PC),D1
		BSR conv
		LEA secttext(PC),A0
		BSR print
		MOVE.L filelength(PC),D1
		LSR.L #8,D1
		LSR.L #1,D1
		ADDQ.L #2,D1
		MOVE.L D1,D0
		BSR conv
		LEA text2(PC),A0
		BSR print
waitkey2	MOVE.L D0,-(SP)
		MOVE #7,-(SP)
		TRAP #1
		ADDQ.L #2,SP
		MOVE.L (SP)+,D0
		LEA save_start(PC),A0
		MOVE.L #sectoroffset,D1
		BSR Do_save
		BSR appl_exi
		CLR -(SP)
		TRAP #1

*************************************
*	   Disk DMA load Code	      *
* A0.L = Save address			*
* D0.L = No. of sectors to save	*
* D1.L = Sector offset			*
*************************************

Seekrate	EQU 3
Sectptr	EQU 10

Do_save	ST $43E.W
		SF FIN_SAVE
		DIVU #Sectptr,D1
		MOVE D1,SEEKTRACK
		MOVE D1,CURRTRACK
		SWAP D1
		ADDQ #1,D1
		MOVE D1,SECTOR
		MOVE.L A0,POINTER		
		MOVE D0,NO_SECTS				no. of sectors
SET_INTS	BCLR #5,$FFFFFA03.W			active edge
		BSET #7,$FFFFFA09.W			set int enable for fdc int
		BSET #7,$FFFFFA15.W			set int mask for fdc int
		BCLR #7,$FFFFFA11.W			clear int in service for fdc int
		BCLR #7,$FFFFFA0D.W			clear int pending for fdc int
		MOVE.L #WRITE_ROUT,$11C.W
INITSAVE	BSR seldrive
DO_SEEK	MOVE #$86,$FFFF8606.W
		MOVE SEEKTRACK(PC),$FFFF8604.W	track we want
		MOVE #$80,$FFFF8606.W
		MOVE #$14!0,$FFFF8604.W 		seek with verify
WAIT_DISK	TST.B FIN_SAVE
		BEQ.S WAIT_DISK
		BCLR #7,$FFFFFA09.W			clear int enable for fdc int
		BCLR #7,$FFFFFA15.W			clear int mask for fdc int
		BSR MOTOR_OFF
		SF $43E.W
		RTS

WRITE		ADDQ #1,SECTOR
		CMP #Sectptr,SECTOR
		BGT.S STEPIN
WRITE_ROUT	MOVE.B POINTER+3(PC),$FFFF860D.W
		MOVE.B POINTER+2(PC),$FFFF860B.W
		MOVE.B POINTER+1(PC),$FFFF8609.W
		MOVE.W #$190,$FFFF8606.W
		MOVE.W #$90,$FFFF8606.W
		MOVE.W #$190,$FFFF8606.W
		MOVE.W #1,$FFFF8604.W 			write 1 sector
		MOVE.W #$184,$FFFF8606.W
		MOVE.W SECTOR(PC),$FFFF8604.W		say which sector
		MOVE.W #$180,$FFFF8606.W			write it
		MOVE.W #$80+32,$FFFF8604.W			
		ADD.L #512,POINTER
		SUBQ #1,NO_SECTS
		BEQ.S INT_DONE
		MOVE.L #WRITE,$11C.W
		BCLR #7,$FFFFFA11.W
		RTE

STEPIN	MOVE #1,SECTOR
		ADDQ #1,CURRTRACK
		MOVE.L #WRITE_ROUT,$11C.W
STEP		MOVE #$80,$FFFF8606.W
		MOVE #$58+4,$FFFF8604.W
		BCLR #7,$FFFFFA11.W
		RTE

INT_DONE	MOVE.L #INT_EXIT,$11C.W
		ST FIN_SAVE
INT_EXIT	BCLR #7,$FFFFFA11.W
		RTE

* Select drive 0 side 0

seldrive	MOVE.W $446.W,D0				get bootdevice
		AND #1,D0					isolate first bit
		ADDQ #1,D0
		ADD D0,D0					calc right bit
		OR #side,D0
		EOR.B #7,D0
select	MOVE.B #$E,$FFFF8800.W			select psg
		MOVE.B $FFFF8800.W,D1				
		AND.B #$F8,D1				
		OR.B D0,D1
		MOVE.B D1,$FFFF8802.W			select drive/side
		RTS

MOTOR_OFF:	MOVE.W #$80,$FFFF8606.W
		MOVE.W $FFFF8604.W,D0
		BTST #7,D0
		BNE.S MOTOR_OFF
		MOVE.B #14,$FFFF8800.W
		BSET #1,$FFFF8802.W
		RTS

SEEKTRACK	DS.W 1
CURRTRACK	DS.W 1
POINTER	DS.L 1
NO_SECTS	DS.W 1
SECTOR	DS.W 1
FIN_SAVE	DS.W 1

* Print text at ptr A0

print		MOVEM.L D0-D7/A0-A6,-(SP)		
		PEA (A0)
		MOVE #9,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		MOVEM.L (SP)+,D0-D7/A0-A6
		RTS

* Load a file of D7 bytes,
* Filename at A4 into address A5.

load_file	CLR -(SP)
		MOVE.L A4,-(SP)
		MOVE #$3D,-(SP)
		TRAP #1
		ADDQ.L #8,SP
		MOVE D0,D4
read		MOVE.L A5,-(SP)
		MOVE.L D7,-(SP)
		MOVE D4,-(SP)
		MOVE #$3F,-(SP)
		TRAP #1
		LEA 12(SP),SP
		MOVE.L D0,filelength
close		MOVE D4,-(SP)
		MOVE #$3E,-(SP)
		TRAP #1
		ADDQ.L #4,SP
		RTS

* 32bit Number convertor using the very
* quick exponent table method...

conv:		movem.l d0-d3/a0,-(sp)
		moveq #0,d3
		lea.l	pten(pc),a0
wrnpos:	neg.l	d1
wrnnext:	move.l (a0)+,d2
		beq.s	wrndone
		clr.b	d0
wrnloop:	add.l	d2,d1
		bgt.s	wrndig
		addq.b #1,d0
		bra.s	wrnloop
wrndig:	sub.l	d2,d1
wrnconv:	addi.b #'0',d0
writit:	movem.l a0-a3/d0-d3,-(sp)	
		move d0,-(sp)
		move #6,-(sp)
		trap #1
		addq.l #4,sp
		movem.l (sp)+,a0-a3/d0-d3
		bra.s	wrnnext
wrndone:	movem.l (sp)+,d0-d3/a0
		rts

pten:		dc.l	100000,10000
		dc.l	1000,100,10,1
		dc.l	0

; AES call for gemdos fileselector routine.
; A1 has address of curr filename.

fileselect	LEA control(PC),A0
		MOVE.W #90,(A0)+
		MOVE.W #0,(A0)+
		MOVE.W #2,(A0)+
		MOVE.W #2,(A0)+
		MOVE.L #path,addr_in
		MOVE.L A1,addr_in+4
		BSR AES
		RTS

; Routines for VDI and AES access By Martin Griffiths 1990
; Call appl_ini at start of a program and appl_exi before terminating.

; VDI subroutine call.

VDI		LEA VDIparblock(PC),A0
		MOVE.L #contrl,(A0)
		MOVE.L A0,D1
		MOVEQ #115,D0
		TRAP #2
		RTS

; AES subroutine call.

AES		LEA AESparblock(PC),A0
		MOVE.L #control,(A0)
		MOVE.L A0,D1
		MOVE.L #200,D0
		TRAP #2
		RTS

* 1st BDOS call is APPL_INI

appl_ini	LEA control(PC),A0
		MOVE #10,(A0)+
		MOVE #0,(A0)+
		MOVE #1,(A0)+
		MOVE #0,(A0)+
		BSR AES
		RTS

* Last BDOS call is APPL_EXI

appl_exi	LEA control(PC),A0
		MOVE #19,(A0)+
		MOVE #0,(A0)+
		MOVE #1,(A0)+
		MOVE #0,(A0)+
		BSR AES
		RTS

; VDI & AES Reserved arrays

VDIparblock	DC.L contrl
		DC.L intin
		DC.L ptsin
		DC.L intout
		DC.L ptsout
		
contrl	DS.W 12
intin		DS.W 30
ptsin		DS.W 30
intout	DS.W 45
ptsout	DS.W 12

AESparblock	DC.L control
		DC.L global
		DC.L int_in
		DC.L int_out
		DC.L addr_in
		DC.L addr_out 

control	DS.W 12
global	DS.W 16
int_in	DS.W 16
int_out	DS.W 16
addr_in	DS.L 2
addr_out	DS.L 1
loading	DC.B 27,"E","Loading:"
demoname	DC.B "MEGADEMO.TOS",0
		DS.B 30
path		DC.B "A:\*.*",0
		DS.B 30
title		DC.B 27,"E"
		DC.B "                     Dma save utility by Griff 1990",10,13
		DC.B "                     ------------------------------",10,13,0
file		DC.B 10,13,"FILE:",0
lentext	DC.B "       LENGTH:",0
secttext	DC.B "       SECTORS:",0
text2		DC.B 10,13,"Insert Decade demo disk and press a key to save."
		ds.l 199
my_stack	ds.l 1
filelength	ds.l 1
save_start
demo_buffer