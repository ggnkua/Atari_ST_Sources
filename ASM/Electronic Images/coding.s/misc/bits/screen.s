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

letsgo		MOVE.W #-1,-(SP)
		MOVE.W #$58,-(SP)
		TRAP #14
		ADDQ.L #4,SP
		MOVE.W D0,oldvideo
		MOVE.W #2,-(SP)
		TRAP #14		
		ADDQ.L #2,SP	
		MOVE.L D0,oldbase

		BSR save_pal

		BSR rest_pal
		MOVE.W #-1,-(SP)
		MOVE.L oldbase(PC),-(SP)
		MOVE.L oldbase(PC),-(SP)
		MOVE.W #5,-(SP)
		TRAP #14
		LEA 12(SP),SP
		MOVE.W oldvideo(pc),-(SP)
		MOVE.W #$58,-(SP)
		TRAP #14
		ADDQ.L #4,SP

oldvideo	DS.W 1
oldbase		DS.L 1
oldsp		DS.L 1


;-------------------------------------------------------------------------
; Interrupt setup routines

save_pal	MOVEM.L $FFFF8240.W,D0-D7
		MOVEM.L D0-D7,old_pal
		LEA $FFFF9800.W,A0
		LEA old_falcpal,A1
		MOVE #256-1,D0
.save_pallp	MOVE.L (A0)+,(A1)+
		DBF D0,.save_pallp		
		RTS

rest_pal	MOVEM.L old_pal,D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		LEA old_falcpal,A0
		LEA $FFFF9800.W,A1
		MOVE #256-1,D0
.rest_pallp	MOVE.L (A0)+,(A1)+
		DBF D0,.rest_pallp		
		RTS

		MOVE.W #PAL+BPS16,-(SP)
		MOVE.W #$58,-(SP)
		TRAP #14
		ADDQ.L #4,SP
