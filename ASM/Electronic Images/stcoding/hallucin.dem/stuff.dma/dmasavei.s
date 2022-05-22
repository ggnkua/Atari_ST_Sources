; Include file for dmasave

letsgo		CLR.L -(SP)
		MOVE #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP

		LEA text2(PC),A0
		BSR print
		LEA flength(PC),A0
		BSR print
	
		MOVE.L #save_end-save_start,D1
		MOVE.L D1,filelength

		BSR conv
		PEA nsects(PC)
		MOVE #9,-(SP)
		TRAP #1
		ADDQ.L #6,SP

		MOVE.L filelength(PC),D1
		DIVU #512,D1
		AND.L #$FFFF,D1
		ADDQ.W #1,D1
		MOVE.L D1,D0
		MOVE.L D0,-(SP)
		BSR conv
waitkey2	MOVE #7,-(SP)
		TRAP #1
		ADDQ.L #2,SP
		MOVE.L (SP)+,D0
		LEA save_start(PC),A0
		MOVE.L #sectoroffset,D1
		BSR Do_save

		CLR -(SP)			; and exit...
		TRAP #1

*************************************
*	   Disk DMA load Code	    *
* A0.L = Save address		    *
* D0.L = No. of sectors to save	    *
* D1.L = Sector offset		    *
*************************************

Seekrate	EQU 3
SectptrS	EQU 10

Do_save		ST $43E.W
		SF FIN_SAVE
		DIVU #SectptrS,D1
		MOVE D1,SEEKTRACK
		MOVE D1,CURRTRACK
		SWAP D1
		ADDQ #1,D1
		MOVE D1,SECTOR
		MOVE.L A0,POINTER		
		MOVE D0,NO_SECTS			; no. of sectors
SET_INTS	BCLR #5,$FFFFFA03.W			; active edge
		BSET #7,$FFFFFA09.W			; set int enable for fdc int
		BSET #7,$FFFFFA15.W			; set int mask for fdc int
		BCLR #7,$FFFFFA11.W			; clear int in service for fdc int
		BCLR #7,$FFFFFA0D.W			; clear int pending for fdc int
		MOVE.L #WRITE_ROUT,$11C.W
INITSAVE	BSR seldriveS
DO_SEEK		MOVE #$86,$FFFF8606.W
		MOVE SEEKTRACK(PC),$FFFF8604.W	track we want
		MOVE #$80,$FFFF8606.W
		MOVE #$14!Seekrate,$FFFF8604.W 	seek with verify
WAIT_DISK	TST.B FIN_SAVE
		BEQ.S WAIT_DISK
		BCLR #7,$FFFFFA09.W			; clear int enable for fdc int
		BCLR #7,$FFFFFA15.W			; clear int mask for fdc int
		BSR MOTOR_OFF
		SF $43E.W
		RTS

WRITE		ADDQ #1,SECTOR
		CMP #SectptrS,SECTOR
		BGT.S STEPIN
WRITE_ROUT	MOVE.B POINTER+3(PC),$FFFF860D.W
		MOVE.B POINTER+2(PC),$FFFF860B.W
		MOVE.B POINTER+1(PC),$FFFF8609.W
		MOVE.W #$190,$FFFF8606.W
		MOVE.W #$90,$FFFF8606.W
		MOVE.W #$190,$FFFF8606.W
		MOVE.W #1,$FFFF8604.W 			; write 1 sector
		MOVE.W #$184,$FFFF8606.W
		MOVE.W SECTOR(PC),$FFFF8604.W		; say which sector
		MOVE.W #$180,$FFFF8606.W		; write it
		MOVE.W #$80+32+8+2,$FFFF8604.W			
		ADD.L #512,POINTER
		SUBQ #1,NO_SECTS
		BEQ.S INT_DONES
		MOVE.L #WRITE,$11C.W
		BCLR #7,$FFFFFA11.W
		RTE

STEPIN		MOVE #1,SECTOR
		ADDQ #1,CURRTRACK
		MOVE.L #WRITE_ROUT,$11C.W
STEP		MOVE #$80,$FFFF8606.W
		MOVE #$58!Seekrate,$FFFF8604.W
		BCLR #7,$FFFFFA11.W
		RTE

INT_DONES	MOVE.L #INT_EXITS,$11C.W
		BCLR #7,$FFFFFA11.W
		RTE
INT_EXITS	ST FIN_SAVE
		BCLR #7,$FFFFFA11.W
		RTE

* Select drive 0 side 0

seldriveS	MOVE.W $446.W,D0			; get bootdevice
		AND #1,D0				; isolate first bit
		ADDQ #1,D0
		ADD D0,D0				; calc right bit
		OR #side,D0
		EOR.B #7,D0
selectS		MOVE.B #$E,$FFFF8800.W			; select psg
		MOVE.B $FFFF8800.W,D1				
		AND.B #$F8,D1				
		OR.B D0,D1
		MOVE.B D1,$FFFF8802.W			; select drive/side
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
POINTER		DS.L 1
NO_SECTS	DS.W 1
SECTOR		DS.W 1
FIN_SAVE	DS.W 1

; Print text at ptr A0

print		MOVEM.L D0-D7/A0-A6,-(SP)		
		PEA (A0)
		MOVE #9,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		MOVEM.L (SP)+,D0-D7/A0-A6
		RTS

; 32bit Number convertor using the very quick exponent table method...

conv:		movem.l d0-d3/a0,-(sp)
		moveq #0,d3
		lea.l	pten(pc),a0
wrnpos:		neg.l	d1
wrnnext:	move.l (a0)+,d2
		beq.s	wrndone
		clr.b	d0
wrnloop:	add.l	d2,d1
		bgt.s	wrndig
		addq.b #1,d0
		bra.s	wrnloop
wrndig:		sub.l	d2,d1
wrnconv:	addi.b #'0',d0
writit:		movem.l a0-a3/d0-d3,-(sp)	
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
flength		DC.B 10,13,"FileLength:",0
nsects		DC.B 10,13,"Sectors:",0
text2		DC.B 10,13,"Insert Demo disk and press a key to save.",0
		EVEN
filelength	ds.l 1
