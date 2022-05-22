; DSP Point rotation
; by Martin Griffiths
;

dist		EQU 320
timing		EQU 1				
max_points	EQU 2000
screensize	EQU 128000

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

		OUTPUT C:\5060HZ.PRG

		MOVE.W #-1,-(SP)
		MOVE.W #$58,-(SP)
		TRAP #14
		ADDQ.L #4,SP
		EOR.W #PAL,D0
		MOVE.W D0,-(SP)
		MOVE.W #$58,-(SP)
		TRAP #14
		ADDQ.L #4,SP
		
		clr -(sp)
		trap #1

