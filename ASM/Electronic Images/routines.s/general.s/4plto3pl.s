; 3 plane picture stripper utility.
; Takes a 4 plane degas piccy
; and converts to 3 plane.

		MOVE.L 4(A7),A5
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
		LEA my_stack(PC),A7
		DC.W $A00A
		BSR ini_aes
		LEA loadtext(PC),A0
		BSR print
		DC.W $A009
		LEA loadpath(PC),A1
		LEA loadname(PC),A2
		BSR fileselect
		DC.W $A00A
		LEA loading(PC),A0
		BSR print
		LEA loadname(PC),A4
		LEA piccy(PC),A5
		MOVE.L #32034,D7
		BSR loadfile
		BSR do_convert
		LEA savetext(PC),A0
		BSR print
		DC.W $A009
		LEA savepath(PC),A1
		LEA savename(PC),A2
		BSR fileselect
		DC.W $A00A
		LEA saving(PC),A0
		BSR print
		LEA savename(PC),A4
		LEA pl3piccy,A5
		MOVE.L #24016,D7
		BSR savefile
		LEA donetext(PC),A0
		BSR print
		MOVE #7,-(SP)
		TRAP #1
		ADDQ.L #2,SP
		DC.W $A009
		CLR -(SP)
		TRAP #1

; Do the actual converting

do_convert	PEA piccy+2(PC)
		MOVE #6,-(SP)
		TRAP #14
		ADDQ.L #6,SP
		MOVE #2,-(SP)
		TRAP #14
		ADDQ.L #2,SP
		MOVE.L D0,A2
		LEA piccy(PC),A0
		LEA pl3piccy,A1
		MOVEM.L 2(A0),D0-D3
		MOVEM.L D0-D3,(A1)
		LEA 34(A0),A0
		LEA 16(A1),A1
		MOVE #3999,D7
con_lp	MOVEM.W (A0)+,D0-D3
		MOVEM.W D0-D2,(A1)
		MOVEM.W D0-D3,(A2)
		ADDQ.L #8,A2
		ADDQ.L #6,A1
		DBF D7,con_lp
		MOVE #7,-(SP)
		TRAP #1
		ADDQ.L #2,SP
		RTS

*************************************
;            Subroutines		;
*************************************

; Print text at ptr A0

print		PEA (A0)
		MOVE #9,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		RTS

; Load a file of D7 bytes,
; Filename at A4 into address A5.

loadfile	CLR -(SP)
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
close		LEA 12(SP),SP
		MOVE D4,-(SP)
		MOVE #$3E,-(SP)
		TRAP #1
		ADDQ.L #4,SP
		RTS

* Save a file of D7 bytes,
* Filename at A4 at address A5.

savefile	MOVE #0,-(SP)
		MOVE.L A4,-(SP)
		MOVE #$3C,-(SP)
		TRAP #1
		ADDQ.L #8,SP
		MOVE D0,D4
write		MOVE.L A5,-(SP)
		MOVE.L D7,-(SP)
		MOVE D4,-(SP)
		MOVE #$40,-(SP)
		TRAP #1
		BRA.S close
		RTS

; AES call for gemdos fileselector routine.
; A2 points to filename address

fileselect	LEA control(PC),A0
		MOVE.W #90,(A0)+
		MOVE.W #0,(A0)+
		MOVE.W #2,(A0)+
		MOVE.W #2,(A0)+
		MOVE.L A1,addr_in
		MOVE.L A2,addr_in+4
		BSR AES
		RTS

; AES subroutine call.

AES		LEA AESparblock(PC),A0
		MOVE.L #control,(A0)
		MOVE.L A0,D1
		MOVE.L #200,D0
		TRAP #2
		RTS

ini_aes	LEA AESparblock(PC),A0
		MOVE.L #control,(A0)+
		MOVE.L #global,(A0)+
		MOVE.L #int_in,(A0)+
		MOVE.L #int_out,(A0)+
		MOVE.L #addr_in,(A0)+
		MOVE.L #addr_out,(A0)
		RTS

loadtext	DC.B 27
		DC.B "E     Select Degas picture to convert",10,13
		DC.B "     -------------------------------",0
		EVEN
savetext	DC.B 27
		DC.B "E    Select filename for 3 plane image",10,13
		DC.B "    ---------------------------------",0
donetext	DC.B 27,"EFile conversion completed successfully",10,13,10,13
		DC.B "Format of saved file",10,13
		DC.B "--------------------",10,13,10,13
		DC.B "8     words palette(3 plane=8 cols)",10,13
		DC.B "12000 words image data.",10,13
		DC.B "12008 words total = 24016 bytes"
		DC.B 10,13,10,13,10,13,10,13,10,13,10,13,10,13
		DC.B "Press a key to exit to GEM",0
		EVEN

loading	DC.B 27,"ELoading Picture:"
loadname	DS.B 14
loadpath	DC.B "A:\*.PI1"
		DS.B 20

saving	DC.B 27,"ESaving 3 plane image:"
savename	DS.B 14
savepath	DC.B "A:\*.IMG"
		SECTION BSS
		DS.B 20
		EVEN
		DS.L 256
my_stack	DS.L 1

AESparblock	DS.L 6
control	DS.W 5
global	DS.W 16
int_in	DS.W 16
int_out	DS.W 7
addr_in	DS.L 2
addr_out	DS.L 1
piccy		DS.B 32034
pl3piccy	DS.B 24016