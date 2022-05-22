; Example Dma Interrupt loader code.

		CLR.L -(SP)
		MOVE #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		MOVE #$2700,SR
clearscreen	LEA $78000,A0
		MOVE #3999,D0
.cls		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		DBF D0,.cls
		LEA old_vects(PC),A0
		MOVE.L $70.W,(A0)+
		MOVE.L $118.W,(A0)+
		MOVE.L $11C.W,(A0)+
		MOVE.B $FFFFFA07.W,(A0)+		
		MOVE.B $FFFFFA09.W,(A0)+
		MOVE.B $FFFFFA13.W,(A0)+		
		MOVE.B $FFFFFA15.W,(A0)+		
		CLR.B $FFFFFA07.W
		CLR.B $FFFFFA09.W
		CLR.B $FFFFFA13.W
		CLR.B $FFFFFA15.W
		MOVE.L #vbl,$70.W
		BSR flush
		MOVE.L #key,$118.W
		BSET.B #6,$FFFFFA09.W
		BSET.B #6,$FFFFFA15.W
		BCLR.B #3,$FFFFFA17.W
		MOVE #$2300,SR
		MOVEQ #50,D0
		MOVEQ #0,D1
		MOVEQ #0,D2
		LEA $78000,A0
		BSR Do_load
Exit		MOVE #$2700,SR
		BSET.B #3,$FFFFFA17.W
		LEA old_vects(PC),A0
		MOVE.L (A0)+,$70.W
		MOVE.L (A0)+,$118.W
		MOVE.L (A0)+,$11C.W
		MOVE.B (A0)+,$FFFFFA07.W		
		MOVE.B (A0)+,$FFFFFA09.W		
		MOVE.B (A0)+,$FFFFFA13.W		
		MOVE.B (A0)+,$FFFFFA15.W		
		MOVE #$2300,SR
		BSR flush
		CLR.W -(SP)
		TRAP #1

old_vects	DS.L 4

vbl		RTE

key		MOVE #$2500,SR
		MOVE D0,-(SP)
		MOVE.B $FFFFFC00.W,D0
		BTST #7,D0
		BEQ.S end
		BTST #0,D0
		BEQ.S end
key_read	MOVE.B $FFFFFC02.W,ckey
end		MOVE (SP)+,D0
		RTE
ckey		DC.W 0

flush		BTST.B #0,$FFFFFC00.W
		BEQ.S flok
		MOVE.B $FFFFFC02.W,D0
		BRA.S flush
flok		RTS

;-----------------------------------------------------------------------;
;                           The dma load code                      	;
;			    -----------------				;	
; A0 -> points to address to read into. D2 - side to read.		;
; D0 - no of sectors to load, D1 - logical sector offset to load from.	;				;
;-----------------------------------------------------------------------;

Sectptr		EQU 10

Do_load		SF fin_load				haven't finished yet
		AND.L #$FFFF,D1
		DIVU #Sectptr,D1			calc track offset
		MOVE D1,seektrack			seek this track
		MOVE D1,currtrack				
		MOVE D2,side
		SWAP D1					remainder+1 =
		ADDQ #1,D1				start sector within
		MOVE D1,sector				sector.
		MOVE.L A0,pointer				
		MOVE D0,no_sects			sectors to go
		BSR setdiskint				setup interrupts
		BSR seldrive				select drive & side
		BSR do_seek				do the seek
wait_disk	TST.B fin_load
		BEQ.S wait_disk
		MOVE SR,-(SP)
		MOVE #$2700,SR
		BCLR #7,$FFFFFA09.W			clear int enable for fdc int
		BCLR #7,$FFFFFA15.W			clear int mask for fdc int
		BSET #5,$FFFFFA03.W			unactive!
		MOVE.W (SP)+,SR
		RTS

* Setup mfp for disk interrupts.

setdiskint	MOVE.W SR,-(SP)
		MOVE #$2700,SR
		BCLR #5,$FFFFFA03.W			active edge
		BSET #7,$FFFFFA09.W			set int enable for fdc int
		BSET #7,$FFFFFA15.W			set int mask for fdc int
		MOVE.L #read_rout,$11C.W
		MOVE.W (SP)+,SR
		RTS

* Send a seek command and track to seek to the floppy controller.

do_seek		MOVE #$86,$FFFF8606.W
		MOVE seektrack(PC),$FFFF8604.W
		MOVE #$80,$FFFF8606.W
		MOVE #16+4+3,$FFFF8604.W
		RTS

loaderror	ADDQ #1,no_sects
		SUB.L #512,pointer			retry loading!
		MOVE.W (SP)+,D0
		BRA.S errorcont

read		MOVE.W D0,-(SP)
		MOVE.W #$80,$FFFF8606.W			select status
		MOVE.W $FFFF8604.W,D0			read status from last load
		BTST #3,D0				
		BNE.S loaderror
		BTST #4,D0
		BNE.S loaderror
		BTST #5,D0
		BNE.S loaderror
noerror		MOVE.W (SP)+,D0
		ADDQ #1,sector				next sector
errorcont	CMP #Sectptr,sector			new track?
		BGT.S stepin				yes/no -
read_rout	MOVE.B pointer+3(PC),$FFFF860D.W	load sector
		MOVE.B pointer+2(PC),$FFFF860B.W	dma address count
		MOVE.B pointer+1(PC),$FFFF8609.W
		MOVE.W #$90,$FFFF8606.W
		MOVE.W #$190,$FFFF8606.W		fifo enable read
		MOVE.W #$90,$FFFF8606.W
		MOVE.W #1,$FFFF8604.W 			read 1 sector
		MOVE.W #$84,$FFFF8606.W
		MOVE.W sector(PC),$FFFF8604.W		say which sector
		MOVE.W #$80,$FFFF8606.W			read it
		MOVE.W #$80,$FFFF8604.W			
		ADD.L #512,pointer			add to pointer
		SUBQ #1,no_sects			decrement total sects
		BEQ.S INT_DONE				to load.if done exit
		MOVE.L #read,$11C.W			
		RTE

* Step in a track and then continue reading

stepin		MOVE #1,sector				reset sector count
		ADDQ #1,currtrack			next track
		MOVE.L #read_rout,$11C.W		continue reading
step		MOVE #$80,$FFFF8606.W			send seek
		MOVE #64+16+8+3,$FFFF8604.W		command to controller(+4 for verify)
		RTE

INT_DONE	MOVE.L #INT_EXIT,$11C.W			sectors loaded
		ST fin_load				set flag to say so
INT_EXIT	RTE

* Select current drive/side

seldrive	MOVE.W $446.W,D0			get bootdevice
		AND #1,D0				isolate first bit
		ADDQ #1,D0
		ADD D0,D0				calc right bit
		OR side(PC),D0
		EOR.B #7,D0
select		MOVE.B #$E,$FFFF8800.W			select psg
		MOVE.B $FFFF8800.W,D1				
		AND.B #$F8,D1				
		OR.B D0,D1
		MOVE.B D1,$FFFF8802.W			select drive/side
		RTS

seektrack	DS.W 1
currtrack	DS.W 1
pointer		DS.L 1
no_sects	DS.W 1
side		DS.W 1
sector		DS.W 1
fin_load	DS.W 1
