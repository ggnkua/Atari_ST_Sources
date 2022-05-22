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

; Cache Control Register Equates (CACR)

ENABLE_CACHE		EQU 1   ; Enable instruction cache
FREEZE_CACHE		EQU 2   ; Freeze instruction cache
CLEAR_INST_CACHE_ENTRY	EQU 4   ; Clear instruction cache entry
CLEAR_INST_CACHE	EQU 8   ; Clear instruction cache
INST_BURST_ENABLE	EQU 16  ; Instruction burst enable
ENABLE_DATA_CACHE	EQU 256 ; Enable data cache
FREEZE_DATA_CACHE	EQU 512 ; Freeze data cache
CLEAR_DATA_CACHE_ENTRY	EQU 1024 ; Clear data cache entry
CLEAR_DATA_CACHE	EQU 2048 ; Clear data cache
DATA_BURST_ENABLE	EQU 4096 ; Instruction burst enable
WRITE_ALLOCATE		EQU 8192 ; Write allocate 

; Blitter Equates 

blit_regs	EQU $FFFF8A00
halftone	EQU 0
src_xinc	EQU $20
src_yinc	EQU $22
src_addr	EQU $24
endmask1	EQU $28
endmask2	EQU $2A
endmask3	EQU $2C
dst_xinc	EQU $2E
dst_yinc	EQU $30
dst_addr	EQU $32
x_count		EQU $36
y_count		EQU $38
HOP		EQU $3A
OP		EQU $3B
line_num	EQU $3C
skew		EQU $3D

wait_blit	MACRO
.waitblit\@	BTST.B #7,line_num(\1)
		BNE.S .waitblit\@
		ENDM

		MOVE.W #-1,-(SP)
		MOVE.W #$58,-(SP)
		TRAP #14
		ADDQ.L #4,SP
		MOVE.W D0,oldvideo
		MOVE.W #2,-(SP)
		TRAP #14		
		ADDQ.L #2,SP	
		MOVE.L D0,oldbase
 		CLR.L -(SP)
		MOVE.W #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		MOVE.L D0,oldsp
		MOVEC.L CACR,D0
		MOVE.L D0,oldcacr
		MOVE.L #ENABLE_CACHE+ENABLE_DATA_CACHE+CLEAR_DATA_CACHE+CLEAR_INST_CACHE,D0
		MOVEC.L D0,CACR

		MOVE.W	#STMODES+BPS16,-(SP)
		MOVE.W #$58,-(SP)
		TRAP #14
		ADDQ.L #4,SP

		LEA $FFFFA206.W,A0
		MOVE.L D0,A1
		LEA (blit_regs).W,A6
		MOVE.W #0,src_xinc(A6)
		MOVE.W #0,src_yinc(A6)
		MOVE.W #2,dst_xinc(A6)
		MOVE.W #2,dst_yinc(A6)
		move.B #2,HOP(a6)
		move.B #3,OP(a6)
		MOVE.B #%00000000,skew(A6)
		MOVE #200-1,D7
lp		
.wait:		BTST.B	#7,line_num(a6)
		bne.s	.wait
		MOVE.L a0,src_addr(A6)
		MOVE.L a1,dst_addr(A6)
		MOVE.W #1,x_count(A6)
		MOVE.W #16000,y_count(A6)
		MOVE.B #%11000000,line_num(A6)
		DBF D7,lp
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
		MOVE.L oldcacr(PC),D0
		MOVEC.L D0,CACR
		MOVE.L oldsp(PC),-(SP)
		MOVE.W #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP

		CLR -(SP)
		TRAP #1

wait200:	move.l	$4ba.w,d0
.wait:		cmp.l	$4ba.w,d0
		beq.s	.wait
		rts

oldsp		DC.L 0
oldcacr		DS.L 1
oldvideo	DS.W 1
oldbase		DS.L 1

		SECTION BSS
mem		DS.B 65536*2

