;-----------------------------------------------------------------------;
;                Hallucinations Source (dma save util )			;
; 									;
; Demo file save takes packed data + writes onto the demo disk.         ;
; (C) 1991-1992 Martin Griffiths.					;
;-----------------------------------------------------------------------;
;    main loader, sector 10  , 140 sectors, side 0, disk a
;  introduction , sector 150 , 230 sectors, side 0, disk a
;       cube    , sector 380 , 29  sectors, side 0, disk a
;    dot sphere , sector 409 , 13  sectors, side 0, disk a
;   line sphere , sector 422 , 17  sectors, side 0, disk a
;  solid sphere , sector 439 , 16  sectors, side 0, disk a
; raytraced frac, sector 455 , 355 sectors, side 1, disk a
; big raytrace! , sector 00  , 641 sectors, side 1, disk a
;  Gouraud      , sector 645 , 18  sectors, side 1, disk a
;  fractal part , sector 663 ,  6  sectors, side 1, disk a
;  threed world , sector 669 , 32  sectors, side 1, disk a
;  music ending , sector 00  , 297 sectors, side 1, disk b

side		EQU 0
sectoroffset 	EQU 10    ;loader

;side		EQU 0
;sectoroffset 	EQU 409

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
		LEA my_stack(PC),SP
		DC.W $A00A
		BSR appl_ini
		LEA title(PC),A0
		BSR print
		DC.W $A009
		LEA demoname(PC),A1
		BSR fileselect			; select file to save
		BSR Concate_path	

		DC.W $A00A
		LEA loading(PC),A0
		BSR print			; say were loading it
readfile	LEA path_n_name(PC),A4
		LEA demo_buffer(PC),A5
		MOVE.l #12345678,D7
		BSR load_file		 	; go for load!
		LEA file(PC),A0
		BSR print
		LEA demoname(PC),A0
		BSR print
		LEA lentext(PC),A0
		BSR print			; print crap about file!
		MOVE.L filelength(PC),D1
		BSR conv
		LEA secttext(PC),A0
		BSR print
		MOVE.L filelength(PC),D1
		DIVU #512,D1
		AND.L #$FFFF,D1
		ADDQ.W #1,D1
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
		CLR -(SP)			; and exit...
		TRAP #1

; Disk Xbios Save Rout!	
; A0.L -> Save address		    
; D0.L = No. of sectors to save, D1.L = Sector offset	

Sectptr		EQU 10

Do_save		DIVU #Sectptr,D1
		MOVE D1,D7
		SWAP D1
		MOVE.W D1,D6
		ADDQ #1,D6
		MOVE.L A0,A6
		MOVE D0,D5			; no. of sectors
		MOVEQ #side,D4
		SUB.L A5,A5
write_lp	MOVE.W #1,-(SP)
		MOVE.W D4,-(SP)			; side
		MOVE.W D7,-(SP)			; track
		MOVE.W D6,-(SP)			; sector
		MOVE.W A5,-(SP)			; DRIVE 0!
		PEA (A5)			; filler
		PEA (A6)			; address to save!
		MOVE.W #9,-(SP)
		TRAP #14			; DO IT
		LEA 20(SP),SP
		ADDQ #1,D6
		CMP #Sectptr,D6
		BLE.S NSTEPIN
		MOVEQ #1,D6			; reset sector count
		ADDQ #1,D7			; next track
NSTEPIN		LEA 512(A6),A6
		SUBQ #1,D5
		BNE.S write_lp
		RTS

; Print text at ptr A0

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
.nonetodo	LEA demoname(PC),A1
.copy_filename	MOVE.B (A1),(A0)+	; concatenate file name
		TST.B (A1)+
		BNE.S .copy_filename
		RTS

control		DS.W 12
global		DS.W 16
int_in		DS.W 16
int_out		DS.W 16
addr_in		DS.L 2
addr_out	DS.L 1
loading		DC.B 27,"E","Loading:"
path_n_name	DS.B 60
demoname	DC.B "MEGADEMO.TOS",0
		DS.B 30

path		DC.B "G:\*.*",0
		DS.B 30
title		DC.B 27,"E"
		DC.B "                          Save utility by Griff 1992",10,13,0
file		DC.B 10,13,"FILE:",0
lentext		DC.B "       LENGTH:",0
secttext	DC.B "       SECTORS:",0
text2		DC.B 10,13,"Insert Demo disk and press a key to save.",0
		even

filelength	ds.l 1

		SECTION BSS
		ds.l 499
my_stack	ds.l 3
save_start
demo_buffer	ds.b 1000000
