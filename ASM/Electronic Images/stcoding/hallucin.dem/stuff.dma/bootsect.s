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
		trap #1

; Hallucinations BootSector

; SetVideo() equates.

VERTFLAG	EQU $0100	; double-line on VGA, interlace on ST/TV ;
STMODES		EQU $0080	; ST compatible ;
OVERSCAN	EQU $0040	; Multiply X&Y rez by 1.2, ignored on VGA ;
PAL		EQU $0020	; PAL if set, else NTSC ;
VGA		EQU $0010	; VGA if set, else TV mode ;
COL80		EQU $0008	; 80 column if set, else 40 column ;
BPS16		EQU $0004
BPS8		EQU $0003
BPS4		EQU $0002
BPS2		EQU $0001
BPS1		EQU $0000


; The Boot Sector!

Boot_Sector	BRA.S Boot
		DC.B $00
		DC.B $00
		DC.B $00
		DC.B $00
		DC.B $00
		DC.B $00
serial		DC.B $00,$00,$00
byte_p_sect	DC.B $00,$02
sect_p_clus	DC.B $02
resrvd_sect	DC.B $01,$00
no_fats		DC.B $00
no_direct	DC.B $00,$00
no_sects	DC.B $68,$06   (82*10*2)
media		DC.B $F8
sect_p_fat	DC.B $00,$00
sect_p_trk	DC.B $0A,$00
no_sides	DC.B $02,$00
no_hidden	DC.B $00,$00

Boot		
		move.w #VERTFLAG+STMODES+VGA+BPS4,-(sp) ; VGA
		move.w #3,-(sp)
		move.l	#$78000,-(sp)
		move.l	#$78000,-(sp)
		move.w	#5,-(sp)
		trap #14
		lea 14(sp),sp

		LEA $FFFF8242.W,A0
		MOVEQ #14,D7
clrcols_lp	CLR.W (A0)+
		DBF D7,clrcols_lp
		LEA read(PC),A6
		MOVE #$666,D7
fadeloop	MOVE #37,-(SP)
		TRAP #14
		ADDQ.L #2,SP
		MOVE.W D7,$FFFF8240.W
		SUB #$111,D7
		BGE.S fadeloop
* Next loader is on side 1 track 0 sector 1
read		MOVE #9,-(SP)		; read 9 sectors
		CLR.L -(SP)		; track 0/side 0
		MOVE #02,-(SP)		; sector 1
		MOVE $446.W,-(SP)	; boot device
		CLR.L -(SP)		; filler
		PEA $70000		; address to load
		MOVE #$08,-(SP)		; _floprd
		TRAP #14		; xbios
		JMP $70000

messages	DC.B "(C) 1991-1995!! Electronic Images."
		EVEN
		DS.W $200
