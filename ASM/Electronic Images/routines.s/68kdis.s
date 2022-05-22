; 68 dissassember by Martin Griffiths
; January 27th 1993

; a5 -> vars
; a6 -> data to dissassemble

fetch_nxt_inst:	move.w (a6)+,d0		; instruction word in d0
		move.w d0,d1
		rol.w #4,d1
		and.w #$f,d1		; instruction type.
		add.w d1,d1
		add.w d1,d1		
		move.l type_jmptab(pc,d1),a0
		jmp (a0)		
type_jmptab	dc.l handletype0
		dc.l handletype1

handletype0

handletype1

		
	DC.B "ABCD"
	DC.B "ADD"
	DC.B "ADDA"
	DC.B "ADDI"
	DC.B "ADDQ"
	DC.B "ADDX"
	DC.B "AND"
	DC.B "ANDI"
	DC.B "ASL"
	DC.B "ASR"
	DC.B "BCC"
	DC.B "BCHG"
	DC.B "BCLR"
	DC.B "BRA"
	DC.B "BSET"
	DC.B "BTST"
	DC.B "CHK"
	DC.B "CLR"
	DC.B "CMP"
	DC.B "CMPA"
	DC.B "CMPI"
	DC.B "CMPM"
	DC.B "DB"
	DC.B "DBT"
	DC.B "DBRA"
	DC.B "DIVS"
	DC.B "DIVU"
	DC.B "EOR"
	DC.B "EORI"
	DC.B "EXG"
	DC.B "EXT"
	DC.B "ILLEGAL"
	DC.B "JMP"
	DC.B "JSR"
	DC.B "LEA"
	DC.B "LINK"
	DC.B "LSL"
	DC.B "LSR
	DC.B "MOVE"
	DC.B "MOVE"
	DC.B "MOVE"
	DC.B "MOVE"
	DC.B "MOVE"
	DC.B "MOVEA"
	DC.B "MOVEM"
	DC.B "MOVEP"
	DC.B "MOVEQ"
	DC.B "MULS"
	DC.B "MULU"
	DC.B "NBCD"
	DC.B "NEG"
	DC.B "NEGX"
	DC.B "NOP"
	DC.B "NOT"
	DC.B "OR"
	DC.B "ORI"
	DC.B "PEA"
	DC.B "RESET"
	DC.B "ROL"
	DC.B "ROR"
	DC.B "ROXL"
	DC.B "ROXR"
	DC.B "RTE"
	DC.B "RTR"
	DC.B "RTS"
	DC.B "SBCD"
	DC.B "SCC"
	DC.B "STOP"
	DC.B "SUBA"
	DC.B "SUBI"
	DC.B "SUBQ"
	DC.B "SUBX"
	DC.B "SWAP"
	DC.B "TAS"
	DC.B "TRAP"
	DC.B "TRAPV"
	DC.B "TST"
	DC.B "UNLNK"

	even
ccodes:
	DC.B "T "
	DC.B "F "
	DC.B "HI"
	DC.B "LS"
	DC.B "CC"
	DC.B "CS"
	DC.B "NE"
	DC.B "EQ"
	DC.B "VC"
	DC.B "VS"
	DC.B "PL"
	DC.B "MI"
	DC.B "GE"
	DC.B "LT"
	DC.B "GT"
	DC.B "LE"

	