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

		CLR.L -(SP)
		MOVE.W #$20,-(SP)	
		TRAP #1
		ADDQ.L #6,SP
		MOVE.L D0,oldsp

		MOVE #200-1,D7
lp		
		NOT.L $FFFF9800+(14*4).W
		NOT.w $FFFF8240.W
		MOVE.W #37,-(SP)
		TRAP #14
		ADDQ.L #2,SP
		move.w #0,$ffffa206.w
		MOVE.L #ENABLE_CACHE,d0
		movec.l d0,CACR
		
		MOVE.W #$2700,SR
		NOT.w $FFFF8240.W
		NOT.L $FFFF9800+(14*4).W
		move.w #2,-(sp)
		trap #14
		addq.l #2,sp
		move.l d0,a1
		LEA mem,A0
		;LEA $FFFFA206.W,A1
		MOVE.L #(32768/64)-1,d6
.lp			
		REPT 32
		move.w (a0),(A1)+
		ENDR
		dbf d6,.lp
		MOVE.W #$2300,SR
		MOVE.L #ENABLE_CACHE,d0
		movec.l d0,CACR

		DBF D7,lp


		MOVE.L oldsp(PC),-(SP)
		MOVE.W #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP	
		CLR -(SP)
		TRAP #1
oldsp		DC.L 0
		SECTION BSS
mem		DS.B 65536*2

