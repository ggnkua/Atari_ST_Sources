;-----------------------------------------------------------------------;
;                	 PowerPacker Decrunch util 			;
; 									;
; 			(C) 1993 Martin Griffiths.			;
;-----------------------------------------------------------------------;

letsgo		MOVE.L 4(SP),A5
		MOVE.L $C(A5),A4
		ADD.L $14(A5),A4
		ADD.L $1C(A5),A4
		LEA $100(A4),A4
		MOVE.L A4,-(SP)
		MOVE.L A5,-(SP)
		CLR -(SP)
		MOVE #$4A,-(SP)	
		TRAP #1				; reserve memory
		LEA 12(SP),SP
		BSR appl_ini
		MOVE.L #intalert,addr_in
		MOVE.W #1,int_in
		BSR form_alert	
		LEA filename(PC),A1
		LEA loadselecttxt(PC),A2
		BSR fileselect			; select file to save
		BSR Concate_path	
.readfile	LEA path_n_name(PC),A4
		BSR getflength

;		LEA path_n_name(PC),A4
;		LEA demo_buffer(PC),A5
;		MOVE.l filelength(pc),D7
;		BSR readfile			; go for load!

		LEA path_n_name(PC),A0
		BSR print
		MOVE.L filelength(PC),D1
		BSR conv
		MOVE #7,-(SP)
		TRAP #1
		ADDQ.L #2,SP

		BSR appl_exi
		CLR -(SP)			; and exit...
		TRAP #1

getflength	MOVE.W #$2F,-(SP)		;
		TRAP #1				; get_dta
		ADDQ.L #2,SP
		MOVE.L D0,A6
		CLR -(SP)
		PEA (A4)
		MOVE.W #$4E,-(SP)		; f_sfirst
		TRAP #1
		ADDQ.L #8,SP
		TST.L D0
		BMI.S .flenerr
		MOVE.L 26(A6),filelength	; store filelength		
.flenerr	MOVEQ #-1,D0
		RTS

filelength	DC.L 0

; Print text at ptr A0

print		MOVEM.L D0-D7/A0-A6,-(SP)		
		PEA (A0)
		MOVE #9,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		MOVEM.L (SP)+,D0-D7/A0-A6
		RTS

; Load a file of D7 bytes, Filename at A4 into address A5.

readfile	CLR -(SP)
		PEA (A4)
		MOVE.W #$3D,-(SP)
		TRAP #1
		ADDQ.L #8,SP
		MOVE D0,D4
.read		PEA (A5)
		MOVE.L D7,-(SP)
		MOVE D4,-(SP)
		MOVE #$3F,-(SP)
		TRAP #1
		LEA 12(SP),SP
.close		MOVE D4,-(SP)
		MOVE #$3E,-(SP)
		TRAP #1
		ADDQ.L #4,SP
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

; AES call for gemdos fileselector routine.
; A1 -> curr filename.
; A2 -> selection text.

fileselect	LEA control(PC),A0
		MOVE.W #90,(A0)+
		MOVE.W #0,(A0)+
		MOVE.W #2,(A0)+
		MOVE.W #4,(A0)+
		MOVE.W #0,(A0)+
		MOVE.L #path,addr_in
		MOVE.L A1,addr_in+4
		MOVE.L A2,addr_in+8
		BRA AES
		

form_alert	LEA control(PC),A0
		MOVE.W #52,(A0)+
		MOVE.W #1,(A0)+
		MOVE.W #1,(A0)+
		MOVE.W #1,(A0)+
		MOVE.W #0,(A0)+
		BRA AES

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
		
contrl		DS.W 12
intin		DS.W 30
ptsin		DS.W 30
intout		DS.W 45
ptsout		DS.W 12

AESparblock	DC.L control
		DC.L global
		DC.L int_in
		DC.L int_out
		DC.L addr_in
		DC.L addr_out 

; The Gem Fileselector returns a path and filename as seperate strings
; - this rout concatenates the two strings together into one (for loading).

Concate_path	LEA path(PC),A1
		MOVE.L A1,A0
.find_end	TST.B (A0)+		; search for end of path
		BNE.S .find_end
.foundit	CMP.B #'\',-(A0)	; now look back for slash
		BEQ.S .foundslash	
		CMP.L A1,A0		; (or if we reach start of path)
		BNE.S .foundit
.foundslash	SUB.L A1,A0		; number of bytes
		MOVE.W A0,D0
		LEA path_n_name(PC),A0
		TST.W D0
		BEQ.S .nonetodo		; if zero then not in subdir
.copypath	MOVE.B (A1)+,(A0)+	; copy path
		DBF D0,.copypath	
.nonetodo	LEA filename(PC),A1
.copy_filename	MOVE.B (A1),(A0)+	; concatenate file name
		TST.B (A1)+
		BNE.S .copy_filename
		RTS

control		DS.W 12
global		DS.W 16
int_in		DS.W 16
int_out		DS.W 16
addr_in		DS.L 10
addr_out	DS.L 10

loadselecttxt	DC.B "Select file to Decrunch    ",0
		EVEN

intalert	DC.B "[1]["
		DC.B "Amiga PowerPacker v2.0-4.0   |"
		DC.B "   File Depack Utility       |"
		DC.B "           By                |"
		DC.B "     Martin Griffiths         "
		DC.B "][ Select File! ]",10,13,0
		EVEN

aheadalert	DC.B "[1]["
		DC.B "                              |"
		DC.B "                              |"
		DC.B "                              |"
		DC.B "                               "
		DC.B "][Ok | Cancel]",10,13,0
		EVEN

		SECTION BSS
path		DS.B 128
path_n_name	DS.B 128
filename	DS.B 128
