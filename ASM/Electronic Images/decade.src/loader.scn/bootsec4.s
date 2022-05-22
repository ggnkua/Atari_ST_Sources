*************************************
* This code encodes and saves the   *
* demo bootsector onto the disk..   *
* It makes the disk executable. 	*
*************************************
* Now with ultra wicked encoding
* Encode the bootsector

Encode	LEA read(PC),A0
		EOR #$666,(A0)+
		EOR #$555,(A0)+
		EOR #$444,(A0)+
		EOR #$333,(A0)+
		EOR #$222,(A0)+
		EOR #$111,(A0)+
		EOR #$100,(A0)+
		MOVEQ #7,D7
A		LEA decoder(PC),A0
		LEA decode_from(PC),A2
		MOVE #end_code-decoder-1,D0
encode_lp	MOVE.B (A0),D1		get byte
		MOVE.B (A2),D2
		ROR.B #1,D2
		MOVE.B D2,(A2)+
		EOR.B D2,D1			encode byte
		MOVE.B D1,(A0)+		put back
		DBF D0,encode_lp
		DBF D7,A
		LEA Boot_Sector(PC),A0
		MOVEQ #0,D1
		MOVE #254,d0
addcheck_lp	ADD (A0)+,D1
		DBF D0,addcheck_lp 
		MOVE #$1234,D0
		SUB D1,D0
		MOVE D0,(A0)+		
write		MOVE #1,-(SP)
		MOVE #0,-(SP)
		MOVE #0,-(SP)
		MOVE #1,-(SP)
		MOVE #0,-(SP)
		CLR.L -(SP)
		PEA Boot_Sector(PC)
		MOVE #$9,-(SP)
		TRAP #14
		LEA 20(SP),SP
		CLR -(SP)
		TRAP #1

* The Decade Demo Boot Sector...
* this loads the main 'load' code.

Boot_Sector	BRA.S Boot
		DC.B $00
		DC.B $00
		DC.B $00
		DC.B $00
		DC.B $00
		DC.B $00
serial	DC.B $00,$00,$00
byte_p_sect	DC.B $00,$02
sect_p_clus	DC.B $02
resrvd_sect	DC.B $01,$00
no_fats	DC.B $00
no_direct	DC.B $00,$00
no_sects	DC.B $68,$06   (82*10*2)
media		DC.B $F8
sect_p_fat	DC.B $00,$00
sect_p_trk	DC.B $0A,$00
no_sides	DC.B $02,$00
no_hidden	DC.B $00,$00
Boot		CLR.L $24.W
		LEA $FFFF8242.W,A0
		MOVEQ #14,D7
clrcols_lp	CLR.W (A0)+
		DBF D7,clrcols_lp
		LEA read(PC),A6
		MOVEQ #6,D6
		MOVE #$666,D7
fadeloop	MOVE #37,-(SP)
		TRAP #14
		ADDQ.L #2,SP
		MOVE.W D7,$FFFF8240.W
		OR $24.W,D7
		EOR D7,(A6)+
		SUB #$111,D7
		DBF D6,fadeloop
		CLR -(SP)
		MOVE.L #$70000,-(SP)
		MOVE.L (SP),-(SP)
		MOVE #5,-(SP)
		TRAP #14
*		LEA 12(SP),SP
* Next loader is on side 1 track 0 sector 1
read		MOVE #10,-(SP)		read 10 sectors
		MOVE #01,-(SP)		side 1
		CLR -(SP)			track 0
		MOVE #01,-(SP)		sector 1
		MOVE $446.W,-(SP)		boot device
		CLR.L -(SP)			filler
		PEA $7c000			address to load
		MOVE #$08,-(SP)		_floprd
		TRAP #14			xbios
*		LEA 20(SP),SP		correct stack
decode_from	MOVE #$2700,SR		beat the crackers
		CLR.L $24.W
		LEA $80000,SP
		CLR.B $FFFFFA07.W		really
		CLR.B $FFFFFA09.W		fuck the
		CLR.B $FFFFFA13.W		crackers
		CLR.B $FFFFFA15.W
		LEA ret(PC),A0
		MOVE.L A0,$70.W
		LEA $8.W,A0
		MOVEQ #7,D0
clearvct_lp	CLR.L (A0)+			fuck the crackers
		DBF D0,clearvct_lp
		clr.l $42a.w
		clr.l $426.w
		LEA trace(PC),A0
		MOVE.L A0,$24.W
		MOVEQ #7,D7
		MOVE #$2300+32768,SR
		REPT 8
		NOP
		ENDR
		RESET
		DC.B "Fuck off Andy!"
		even
trace		MOVE #$2700,SR
		LEA decoder(PC),A0
		LEA decode_from(PC),A2
		MOVEQ #end_code-decoder-1,D0
rel_lp	MOVE.B (A0),D1		get byte
		MOVE.B (A2),D2
		ROL.B #1,D2
		MOVE.B D2,(A2)+
		EOR.B D2,D1			get decode byte
		MOVE.B D1,(A0)+		relocate
		DBF D0,rel_lp
		SUBQ #1,D7
		BMI.S decoder
ret		RTE
		DC.B "DECADE DEMO BOOTSECTOR V2"
		even
decoder	BRA.S Decade1
		DC.L $23472342
add1		DC.L 23031973+($7fa0/2)
		DC.B "CRACKTHIS!"
		EVEN
add2		DC.L 23031973
Decade1	LEA $7c000,A0
		MOVE #$9FF,D0
		MOVE.L add1(PC),D1
		SUB.L add2(PC),D1
		ADD D1,D1
decode_lp	EOR D1,(A0)+
		ROR #1,D1
		DBF D0,decode_lp
		JMP $7c000
		EVEN
end_code	

messages	DC.B "PROTECTION + DMA LOAD CODE BY GRIFF."
		DC.B "Hi to Mike Bourne!"
		DC.B "Crack this - send it to me! "
		DC.B "Griff,77 Stranraer Rd,Pembroke,Dyfed."
		EVEN
		DS.W 50
