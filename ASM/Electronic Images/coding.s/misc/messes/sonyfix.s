; Little program to fix set_video for sony TVs :)
; Griff '93

		output c:\sonyfix.prg

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

; Falcon video register equates

vwrap           EQU $FFFF8210
_spshift        EQU $FFFF8266
hht             EQU $FFFF8282
hbb             EQU $FFFF8284
hbe             EQU $FFFF8286
hdb             EQU $FFFF8288
hde             EQU $FFFF828A
hss             EQU $FFFF828C
hfs             EQU $FFFF828E
hee             EQU $FFFF8290
vft             EQU $FFFF82A2
vbb             EQU $FFFF82A4
vbe             EQU $FFFF82A6
vdb             EQU $FFFF82A8
vde             EQU $FFFF82AA
vss             EQU $FFFF82AC
vco             EQU $FFFF82C2


start_res	BRA.W install
		DC.L 'XBRA'
oldxbios	DC.L 0
		DC.L 'SONY'
handler		MOVE.L SP,A0
		BTST.B #5,(a0)
		BNE.S .is_super
		MOVE.L USP,A0
		SUBQ.L #8,A0
.is_super	CMP.W #$58,8(A0)
		BEQ.S .issetvideo
.notsetvideo	JMP ([oldxbios])

.issetvideo	CMP.W #-1,10(A0)
		BEQ.S .notsetvideo
		MOVE 10(A0),setvideo_param
		MOVE.L 8(A0),-(SP)	;
		CLR -(SP)
		PEA ere(PC)
		MOVE.W SR,-(SP)
		JMP ([oldxbios])
ere		ADDQ.L #4,SP
		BTST #6,setvideo_param+1
		BNE.S .ok
		RTE
.ok		AND.W #COL80,setvideo_param
		BEQ.S .is_40
.is_80		ADD.W #50,(hdb).w
		ADD.W #50,(hde).w
		RTE
.is_40		;ADD.W #25,(hdb).w
		;ADD.W #25,(hde).w
		RTE

setvideo_param	DC.W 0
		DC.L 0
end_res		
install		PEA install_trap14(PC)
		MOVE.W #$26,-(SP)		; super exec
		TRAP #14
		ADDQ.L #6,SP
		MOVE.W #-1,-(SP)
		MOVE.W #$58,-(SP)
		TRAP #14
		ADDQ.L #4,SP
		CLR -(SP)
		MOVE.L #(end_res-start_res)+256,-(SP) 
		MOVE.W #$31,-(SP)		; terminate and stay resident
		TRAP #1

install_trap14	MOVE.L $B8.W,oldxbios
		MOVE.L #handler,$B8.W
		RTS