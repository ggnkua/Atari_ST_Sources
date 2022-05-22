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

		CLR.L -(SP)
		MOVE.W #$20,-(SP)	
		TRAP #1
		ADDQ.L #6,SP
		MOVE.L D0,oldsp
		bsr	wait200
		MOVE.W #2,-(SP)
		TRAP #14
		ADDQ.L #2,SP
		move.l	$4ba.w,-(sp)
		LEA $FFFFA204.W,A0
		MOVE.L D0,A1
		LEA (blit_regs).W,A6
		MOVE.W #0,src_xinc(A6)
		MOVE.W #0,src_yinc(A6)
		MOVE.W #2,dst_xinc(A6)
		MOVE.W #2,dst_yinc(A6)
		move.B #2,HOP(a6)
		move.B #3,OP(a6)
		MOVE.B #%00000000,skew(A6)
		move.w	#$2500,sr
		MOVE #200-1,D7
lp		MOVE.L a0,src_addr(A6)
		MOVE.L a1,dst_addr(A6)
		MOVE.W #1,x_count(A6)
		MOVE.W #16384,y_count(A6)
		MOVE.B #%11000000,line_num(A6)
		nop
.wait:		BTST.B	#7,line_num(a6)
		bne.s	.wait
		DBF D7,lp
		move.l	(sp)+,d0
		sub.l	$4ba.w,d0
		neg.l	d0
		move.l	#16384*2*200*200,d1
		divu.l	d0,d1

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
		SECTION BSS
mem		DS.B 65536*2

