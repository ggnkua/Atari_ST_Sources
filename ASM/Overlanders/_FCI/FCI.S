; Author: Benoit 'RATI' Durand and Herve 'Janek' Durand
; Demo Group: Overlanders
; Organization: The Union
; Date (dd/mm/yyyy): 07/10/2023
;
; Type: Library
;
; Usage:
; . Include (INCLUDE or INCBIN) the source code to integrate in '_source' label in DATA section of your MAIN program ('_')
;   Note that you can had additional code before/after the INCBIN in case its required (eg. initialising some variables for th eintegrated routine --> eg. setting the screen address in An)
;   Note that it must end with a 'RTS' or the end mark 'END '
; . Include this code (INCLUDE FCI.S) in your MAIN program
; . Call Init: 'bsr FCI_Inits'
; . Generate the code by calling as follows:
; . a0=points on source code to integrate
; . a1=points on the list of line's models to take into account for the code integration
; . a3=points on the space where the code must be generated
;	lea 	_source,a0					; a0=points on first instruction of the code to integrate
;	lea 	_generated_code,a3				; a3=where the code is generated
;	move.l 	_lines_list_ptr,a1				; a1=points on list of the lines structures to use for generating the code
; 	bsr 	FCI_generate_fullscreen_code			; generate the code
; . The integrated code is located in a3
; . You can get the address of the end of what has been generated in FCI_end_generated_code
; 	move.l 	FCI_end_generated_code,a0			; a0=end of generated code
;
; Notes:
; . You can define whatever line's model you want:
; 	. it must be defined in the MAIN program
; 	. line's model --> ref _FS_LINE_DEFAULT in data section for instance
; 	. lines_list: pointers to each lines --> default is a fullscreen starting in line 0
; . Your source code must:
; 	. Use linear code --> no multiple paths
; 	. not use registers a0,a1 and d0: they are used by the fullscreen code to switch resolution/frequency.
; 	. Unsupported instructions:
; 	  illegal, trap, link, unlk, reset, stop, rte, rtr, rts, trapv, jsr, jmp, DBcc, bra, bsr, Bcc
; 	. Rotation instructions for which duration is always the same:
; 	   asD #, lsD #, roxD #,roD #
; 	.  Not supported : asD Dn, lsD Dn, roxD Dn,roD Dn
; 	.  Not supported : mulu, muls, divu, divs
; . Notice that 'Prefetch' is not supported by this tool as it uses the trace exception
;
; How does it work:
; . The Opcodes are all in 2 bytes with the exception of the 'movem' instruction
; . The Opcode is copied (SMC) in Timer B IT (TB_opcode) space to be executed there
; . Timer B is used to analyze 1 instruction per scanline. When Timer B IT is triggered:
; 	. the video counter is measured
;	. then the Trace is enabled
;	. the video counter is measured within the Trace exception
; 	  --> allows to measure the length of the instruction in NOPs as 1 NOP=2 bytes passed in video counter
; 	. Trace enables to measure the size of the instruction as the return address is located in the stack
; . These information (number of NOPs consumed and size of the instruction) are used to generate the fullscreen code
; . Done

; ===========================================================
; Variables section
; ===========================================================

		ifnd 	FCI_color_indicators
FCI_color_indicators		EQU 	0			; 0 = do not display colors (red, green) when instructions are being analyzed
								; 1 = uses color codes to let know when instruyction are being analyzed
		endc

; ===========================================================
			SECTION TEXT
; ===========================================================

		opt	o-

; ----------------------------------------------------
; Init section
; ----------------------------------------------------

; Set vectors to catch instruction and adapt treatment
FCI_Inits:
	; Trace vector
	move.l	#FCI_TRACE_exception,$24.w 			; Trace vector
	; MFP Timer B
	move.b 	#0,$fffffa1b.w					; stop Timer B
	or.b 	#1,$fffffa07.w					; enable Timer B interrupt
 	or.b	#1,$fffffa13.w					; Timer B unmasked
	bclr 	#3,$FFFFFA17.w					; bit 3=0 - mode "Automatic End of Interrupt"
	move.l 	#FCI_TimerB_IT,$120.w				; set Timer B IT vector
	rts

FCI_DeInit:
	; Trace vector
	move.l 	#FCI_RTE,$24.w
	; MFP Timer B
	move.b 	#0,$fffffa1b.w					; stop Timer B
	rts

; ----------------------------------------------------
; Interrupt section
; ----------------------------------------------------

FCI_RTE:	rte

FCI_TimerB_IT:
	clr.b 	$fffffa1b.w					; stop Timer B
	IFNE 	FCI_color_indicators
		move.w 	#$700,$ffff8240.w			; visual marker - entering Timer B
	ENDC
	movem.l d0-d7/a0-a6,-(sp)
	; ensure counter is incrementing
.wait:	move.b 	$ffff8209.w,d0
	cmp.b 	$ffff8209.w,d0
	beq.s 	.wait
	IFNE 	FCI_color_indicators
		move.w 	#$070,$ffff8240.w			; visual marker - start analysing instruction
	ENDC
	; trigger Trace exception
	moveq 	#0,d3						; clear d3 as it can be used for a displacement (eg. (An,d3)) ---> $3000 will do that
	move.b 	$ffff8209.w,FCI_vid_counter_start+1		; (6 NOPs)
	or.w 	#$8000,sr					; (5 NOPs) enable trace for next instruction
FCI_TB_opcode:
	dc.w 	$0000						; instruction opcode --> this will trigger a trace exception
	dc.w 	$3000,$3000,$3000,$3000				; max instruction size=10 bytes (move.l $.l,$.l)
								; params of the instruction --> depends from the opcode
								; set in a way it does not create too many errors (ex: write to $0)
FCI_TB_return_from_trace:
	move.l 	#$30003000,FCI_TB_opcode+2			; reset params
	move.l 	#$30003000,FCI_TB_opcode+6			; reset params
	bsr 	FCI_check_instruction_post			; post treatment specific to some instructions (eg. 'pea')
	movem.l (sp)+,d0-d7/a0-a6
	st 	FCI_instruction_analyzed			; informs that this instruction has been handled
	IFNE 	FCI_color_indicators
		move.w 	#$777,$ffff8240.w			; marker end - end analyzing time
	ENDC
	rte

; Initiated as soon as Trace bit in SR is set --> we arrive here right after the opcode (in _TB_opcode) has finished its execution
FCI_TRACE_exception:						; (9 NOPs to reach this exception)
	; Determine the consumption of the instruction in NOPs
	moveq 	#0,d0						; (1 NOP) - clear d0
	move.b 	$ffff8209.w,d0					; d0=video counter after 'moveq #0,d0'
	sub.w 	FCI_vid_counter_start,d0			; d0=_vid_counter_end - vid_counter_start
	bpl.s 	.positive
	add.w 	#256,d0						; correction if substraction gives a negative result
.positive:
	sub.w 	#(6+5+9+1)*2,d0					; 1 NOP = 2 bytes passed in vid_counter so *2
								; 6+5+9+1 = all NOPs (=CPU) consumed that must not be counted
								; . 6 NOPs --> TB: move.b 	$ffff8209.w,FCI_vid_counter_start+1
								; . 5 NOPs --> TB: or.w 	#$8000,sr
								; . 9 NOPs --> Trace exception handling
								; . 1 NOP  --> Trace: moveq 	#0,d0
	lsr.w 	#1,d0						; d0=#NOPs consumed by the analyzed instruction
	move.w 	d0,FCI_current_instruction_nb_NOPs		; store number of NOPs consumed by current instruction
	; Determine the length of the instruction
	move.l 	2(a7),d0					; d0=return address
	sub.l 	#FCI_TB_opcode,d0				; d0=instruction size
	move.w 	d0,FCI_current_instruction_size			; store current instruction's size
	move.l 	#FCI_TB_return_from_trace,2(sp)			; fix return address
	st 	FCI_instruction_analyzed
	rtr  							; Do not restore the Trace mode

; Measure the duration (in NOPs) and size of the instruction and generates the fullscreen code accordingly
; Input:
; . a0=points on source code to integrate
; . a1=points on the list of line's models to take into account for the code integration
; . a3=points on the space where the code must be generated
FCI_generate_fullscreen_code:
	; Init stats variables
	move.w 	#0,FCI_nb_analyzed_instructions_bcd
	move.w 	#0,FCI_nb_retained_NOPs_bcd
	move.w 	#0,FCI_nb_NOPs_in_last_line_bcd
	move.w 	#0,FCI_nb_NOPs_in_last_line
	move.w 	#0,FCI_nb_generated_fullscreen_lines_bcd
	move.w 	#0,FCI_nb_generated_fullscreen_lines
	; Generate
.next_line_model:
	move.w 	#$2300,sr					; allow all ITs > 3
	cmp.l 	#-1,(a1)					; is IT the last line's model?
	bne.s 	.get_line_model					; if no, then find next line model to use
	rts							; if yes, then exit
.get_line_model:
	bsr 	FCI_1_more_generated_fullscreen_line		; count 1 more generated fullscreen line
	move.l 	(a1)+,a2					; a2=points on current line to use
.next_line_model_code:
	cmp.w 	#-1,(a2)					; is it the end of the line model?
	beq.s 	.next_line_model				; if yes then point on next line model
.copy_line_model_code:
	cmp.w 	#$4E71,(a2)					; is the current instruction a NOP?
	beq.s 	.count_successive_NOPs				; if yes, count the number of successive NOPs
								; otherwise, copy the instruction from the line's model to the target generated code
	move.w 	(a2)+,(a3)+					; copy instruction (and params if required)
	bra.s 	.copy_line_model_code
.count_successive_NOPs:
	moveq	#0,d0						; init counter
.count_NOPs:
	cmp.w 	#$4E71,(a2)					; is it a NOP?
	bne.s 	.not_a_NOP
	addq.w 	#1,d0						; d0=+1 NOP
	addq.l 	#2,a2						; pass the NOP and point on the next instruction
	bra.s 	.count_NOPs
.not_a_NOP:
	move.w 	d0,FCI_number_of_successive_NOPs		; store the number of successive NOPs
.next_instruction:
;	move.w 	#$2700,sr					; stop all ITs
	cmp.l 	#"END ",(a0)					; Do we meet the End Mark?
	beq 	.complete_line_before_exit			; that's the end of the code to integrate. Still the line's model must be completed to be valid for a fullscreen
	cmp.w 	#$4E75,(a0)					; other condition to exit is when we meet the 'RTS' instruction
	beq 	.complete_line_before_exit			; that's the end of the code to integrate. Still the line's model must be completed to be valid for a fullscreen
	; Analyze_instruction
	sf 	FCI_instruction_analyzed			; instruction not analyzed yet
	move.w 	(a0),FCI_TB_opcode				; copy opcode for analysis
	bsr 	FCI_check_instruction				; check if the instruction is valid
	tst.b 	FCI_unsupported_instruction
	beq.s 	.cont
	rts							; exit if an unsupported instruction has been found
	; Instruction analysis
	; . save registers before analysis in case they are destroyed during the analysis
.cont:	movem.l d0-d7/a0-a6,-(sp)
	; . makes it all 'writes' (if any) goes in an empty space in memory (eg. move. d4,-(a5))
	lea 	FCI_empty_space,a0
	move.l 	a0,a1
	move.l 	a0,a2
	move.l 	a0,a3
	move.l 	a0,a4
	move.l 	a0,a5
	move.l 	a0,a6
	; . enable Timer B IT for instruction analysis
;	clr.b 	$fffffa1b.w					; stop Timer B
	move.b 	#1,$fffffa21.w					; IT every 1 line (minimum as the Timer B treatment can last more than a line. That's the reason why the TB_IT is stopped within the IT itself)
	move.b 	#8,$fffffa1b.w 					; starts Timer B
;	move.w 	#$2500,sr					; enable MFP ITs --> Timer B that will measure the number of NOPs and size of the instruction
	; wait until the Timer B IT has done its job by measuring the time (#NOPs) consumed by the instruction as well as the instruction's length
.wait_end_compute:
	tst.b 	FCI_instruction_analyzed
	beq.s 	.wait_end_compute
	movem.l (sp)+,d0-d7/a0-a6				; restoring all registers to their values before analysis
	; Integrate in fullscreen code
	; . _current_instruction_nb_NOPs=#NOPs consumed by the instruction
	; . _current_instruction_size=nb bytes used by the instruction
	; . _number_of_successive_NOPs=available NOPs
;	move.w 	#$2700,sr					; stop all ITs
	move.w 	FCI_current_instruction_nb_NOPs,d0
	move.w 	FCI_number_of_successive_NOPs,d1
	cmp.w 	d1,d0						; are there enough available NOPs for the instruction to fit in
	bhi.s 	.not_enough_NOPs_available			; if no, then preserve the NOPs
	; Enough NOPs --> generate the instruction and update the number of available NOPs accordingly
	sub.w 	d0,FCI_number_of_successive_NOPs		; update number of available NOPs
	move.w 	FCI_current_instruction_size,d7		; d7=size_instruction in bytes
	lsr.w 	#1,d7						; d7=size_instruction in words
	subq.w 	#1,d7						; d7=counter
.copy_current_instruction:
	move.w 	(a0)+,(a3)+
	dbf 	d7,.copy_current_instruction
	bsr 	FCI_1_more_analyzed_instruction		; count 1 more analyzed instruction
	bra	.next_instruction				; next instruction to encode
	; Not enough NOPs -> fill in with NOPs
.not_enough_NOPs_available:
	subq.w 	#1,d1						; d1=counter
	bmi.s 	.no_NOP						; in case #avalilable NOPs=0
.copy_NOP:
	move.w 	#$4E71,(a3)+
	bsr 	FCI_1_more_retained_NOP			; count 1 more retained NOP
	dbf 	d1,.copy_NOP
.no_NOP:
	bra	.next_line_model_code				; advance in line's model code
	; Complete the last line of the generated code to fill in the last fullscreen line code
.complete_line_before_exit:
	; . generate NOPs
	move.w 	FCI_number_of_successive_NOPs,d1
	subq.w 	#1,d1						; d1=counter
	bmi.s 	.copy						; in case #avalilable NOPs=0
.gen_NOP:
	move.w 	#$4E71,(a3)+
	bsr 	FCI_1_more_NOP_in_last_line			; count unused NOPs in last line
	dbf 	d1,.gen_NOP
	; . copy line model till its end (dc.w -1)
.copy:	cmp.w 	#-1,(a2)
	beq.s 	.line_completed
	cmp.w 	#$4E71,(a2)
	bne.s 	.cc
	bsr 	FCI_1_more_NOP_in_last_line			; count 1 more retained NOP
.cc:	move.w 	(a2)+,(a3)+
	bra.s 	.copy
.line_completed:
	move.l 	a3,FCI_end_generated_code			; store end address of the generated code
	rts

; Ref this doc to understand the maks used for opcodes: http://goldencrystal.free.fr/M68kOpcodes-v2.3.pdf
; This routine:
; . checks if the instruction is authorized
; . ensure that a7 is not used so that the routine can work
FCI_check_instruction:
	; //// Unauthorized instructions ////
	sf 	FCI_unsupported_instruction			; instruction authorized by default
	; . detect 'illegal'
._illegal:
	move.w 	(a0),d0						; d0=opcode
	cmp.w 	#%0100101011111100,d0
	bne.s 	._trap
	st 	FCI_unsupported_instruction
	move.b 	#9,FCI_instID
	rts
	; . detect 'trap'
._trap:
	move.w 	(a0),d0						; d0=opcode
	and.w 	#%1111111111110000,d0
	cmp.w 	#%0100111001000000,d0
	bne.s 	.link_unlk
	st 	FCI_unsupported_instruction
	move.b 	#10,FCI_instID
	rts
	; . detect 'link/unlk'
.link_unlk:
	move.w 	(a0),d0						; d0=opcode
	and.w	#%1111111111110000,d0
	cmp.w 	#%0100111001010000,d0
	bne.s 	._reset
	st 	FCI_unsupported_instruction
	move.b 	#11,FCI_instID
	rts
	; . detect 'reset'
._reset:
	move.w 	(a0),d0						; d0=opcode
	cmp.w 	#%0100111001110000,d0
	bne.s 	._stop
	st 	FCI_unsupported_instruction
	move.b 	#12,FCI_instID
	rts
	; . detect 'stop'
._stop:
	move.w 	(a0),d0						; d0=opcode
	cmp.w 	#%0100111001110010,d0
	bne.s 	._rte
	st 	FCI_unsupported_instruction
	move.b 	#13,FCI_instID
	rts
	; . detect 'rte'
._rte:
	move.w 	(a0),d0						; d0=opcode
	cmp.w 	#%0100111001110011,d0
	bne.s 	._trapv
	st 	FCI_unsupported_instruction
	move.b 	#14,FCI_instID
	rts
;	; . detect 'rts'					; 'RTS' is used as End Mark so not necessary to test it here
;._rts:
;	move.w 	(a0),d0						; d0=opcode
;	cmp.w 	#%0100111001110101,d0
;	bne.s 	._trapv
;	st 	FCI_unsupported_instruction
;	move.b 	#15,FCI_instID
;	rts
	; . detect 'trapv'
._trapv:
	move.w 	(a0),d0						; d0=opcode
	cmp.w 	#%0100111001110110,d0
	bne.s 	._rtr
	st 	FCI_unsupported_instruction
	move.b 	#16,FCI_instID
	rts
	; . detect 'rtr'
._rtr:
	move.w 	(a0),d0						; d0=opcode
	cmp.w 	#%0100111001110111,d0
	bne.s 	._jsr
	st 	FCI_unsupported_instruction
	move.b 	#17,FCI_instID
	rts
	; . detect 'jsr'
._jsr:
	move.w 	(a0),d0						; d0=opcode
	and.w 	#%1111111111000000,d0
	cmp.w 	#%0100111010000000,d0
	bne.s 	._jmp
	st 	FCI_unsupported_instruction
	move.b 	#18,FCI_instID
	rts
	; . detect 'jmp'
._jmp:
	move.w 	(a0),d0						; d0=opcode
	and.w 	#%1111111111000000,d0
	cmp.w 	#%0100111011000000,d0
	bne.s 	._DBcc
	st 	FCI_unsupported_instruction
	move.b 	#19,FCI_instID
	rts
	; . detect 'DBcc'
._DBcc:
	move.w 	(a0),d0						; d0=opcode
	and.w 	#%1111000011111000,d0
	cmp.w 	#%0101000011001000,d0
	bne.s 	._bra
	st 	FCI_unsupported_instruction
	move.b 	#20,FCI_instID
	rts
	; . detect 'bra'
._bra:
	move.w 	(a0),d0						; d0=opcode
	and.w 	#%1111111100000000,d0
	cmp.w 	#%0110000000000000,d0
	bne.s 	._bsr
	st 	FCI_unsupported_instruction
	move.b 	#21,FCI_instID
	rts
	; . detect 'bsr'
._bsr:
	move.w 	(a0),d0						; d0=opcode
	and.w 	#%1111111100000000,d0
	cmp.w 	#%0110000100000000,d0
	bne.s 	._Bcc
	st 	FCI_unsupported_instruction
	move.b 	#22,FCI_instID
	rts
	; . detect 'Bcc'
._Bcc:
	move.w 	(a0),d0						; d0=opcode
	and.w 	#%1111000000000000,d0
	cmp.w 	#%0110000000000000,d0
	bne.s 	.divu_divs
	move.w 	(a0),d0						; d0=opcode
	and.w 	#%0000111000000000,d0
	beq.s 	.divu_divs
	st 	FCI_unsupported_instruction
	move.b 	#23,FCI_instID
	rts
	; . detect 'divu/divs'
.divu_divs:
	move.w 	(a0),d0						; d0=opcode
	and.w 	#%1111000011000000,d0
	cmp.w 	#%1000000011000000,d0
	bne.s 	.mulu_muls
	st 	FCI_unsupported_instruction
	move.b 	#24,FCI_instID
	rts
	; . detect 'divu/divs'
.mulu_muls:
	move.w 	(a0),d0						; d0=opcode
	and.w 	#%1111000011000000,d0
	cmp.w 	#%1100000011000000,d0
	bne.s 	._authorized_instructions
	st 	FCI_unsupported_instruction
	move.b 	#25,FCI_instID
	rts
	; //// Authorized instructions ////
._authorized_instructions:
	; . analyze src for all opcodes <= %0100101000000000
.opcodes_inf_egal_0100101:
	move.w 	(a0),d0						; d0.lw=opcode
	and.w	#%1111111000000000,d0
	cmp.w 	#%0100101000000000,d0
	bhi.s 	.inst_opcode_sup_0100101
	move.w 	(a0),d0						; d0=opcode
	and.w	#%0000000000111000,d0				; analyze src
	beq.s 	.src_analyzed					; it's a Dn
	cmp.w 	#%0000000000110000,d0
	bhi.s 	.src_analyzed					; it's not An
	bsr 	.chg_src
.src_analyzed:
	; . analyze 'move' instruction
	move.w 	(a0),d0						; d0=opcode
	and.w	#%0011000000000000,d0
	beq.s 	.not_move					; it's not a move
	; .. it's a move --> analyze destination
.analyze_dest:
	move.w 	(a0),d0						; d0=opcode
	and.w	#%0000000111000000,d0				; analyze destination
	bne.s 	.not_Dn
	rts							; it's a Dn so exit
.not_Dn:
	cmp.w 	#%0000000110000000,d0
	bls 	.chg_dest					; it's An -> ensure it's not a7
.not_move:
.inst_opcode_sup_0100101:
	; . detect 'move usp'
	move.w 	(a0),d0						; d0=opcode
	and.w	#%1111111111110000,d0
	cmp.w 	#%0100111001100000,d0
	beq 	.chg_src					; make sure it's not a7
	; 'detect movem'
._movem:
	move.w 	(a0),d0						; d0=opcode
	and.w	#%1111111110111000,d0
	cmp.w 	#%0100100010000000,d0
	beq 	.exit						; it's an 'ext' instruction so exit
	and.w	#%1111101110000000,d0
	cmp.w 	#%0100100010000000,d0
	bne.s 	._lea
	move.w 	2(a0),FCI_TB_opcode+2				; it's a 'movem' --> copy parameters
	bra 	.chg_src					; make sure it's not a7
	; detect 'lea xx,a7'
._lea:	move.w 	(a0),d0						; d0=opcode
	and.w 	#%1111111111000000,d0
	cmp.w 	#%0100111111000000,d0
	beq 	.chg_dest
	; detect 'lea xx,a7'
.addq_subq:
	move.w 	(a0),d0						; d0=opcode
	and.w 	#%1111000000000000,d0
	cmp.w 	#%0101000000000000,d0
	bne.s 	._Scc
	move.w 	(a0),d0						; d0=opcode
	and.w 	#%0000000011000000,d0
	cmp.w 	#%0000000011000000,d0
	bne 	.chg_src
	; . detect 'Scc'
._Scc:	move.w 	(a0),d0						; d0=opcode
	and.w	#%1111000011000000,d0
	cmp.w 	#%0101000011000000,d0
	bne.s 	._sbcd
	move.w 	(a0),d0						; d0=opcode
	and.w	#%0000000000111000,d0				; analyze src
	beq.s 	._sbcd						; it's a Dn
	cmp.w 	#%0000000000110000,d0
	bls 	.chg_src
	; . detect 'sbcd'
._sbcd: move.w 	(a0),d0						; d0=opcode
	and.w	#%1111000111111000,d0
	cmp.w 	#%1000000100001000,d0
	beq 	.chg_srcdest
	; . detect 'subx'
._subx: move.w 	(a0),d0						; d0=opcode
	and.w	#%1111000100111000,d0
	cmp.w 	#%1001000100001000,d0
	beq 	.chg_srcdest
	; . detect 'suba'
._suba: move.w 	(a0),d0						; d0=opcode
	and.w	#%1111000011000000,d0
	cmp.w 	#%1001000011000000,d0
	beq 	.chg_srcdest
	; . detect 'cmpm'
._cmpm: move.w 	(a0),d0						; d0=opcode
	and.w	#%1111000100111000,d0
	cmp.w 	#%1011000100001000,d0
	beq.s 	.chg_srcdest
	; . detect 'cmpa'
._cmpa: move.w 	(a0),d0						; d0=opcode
	and.w	#%1111000011000000,d0
	cmp.w 	#%1011000011000000,d0
	beq.s 	.chg_srcdest
	; . detect 'abcd'
._abcd: move.w 	(a0),d0						; d0=opcode
	and.w	#%1111000111111000,d0
	cmp.w 	#%1100000100001000,d0
	beq.s 	.chg_srcdest
	; . detect 'exg'
._exg:	move.w 	(a0),d0						; d0=opcode
	and.w	#%1111000100110000,d0
	cmp.w 	#%1100000100000000,d0
	beq.s 	.chg_srcdest
	; . detect 'addx'
._addx: move.w 	(a0),d0						; d0=opcode
	and.w	#%1111000100111000,d0
	cmp.w 	#%1101000100001000,d0
	beq.s 	.chg_srcdest
	; . detect 'suba'
._adda: move.w 	(a0),d0						; d0=opcode
	and.w	#%1111000011000000,d0
	cmp.w 	#%1101000011000000,d0
	beq.s 	.chg_srcdest
	; other opcodes >=%1000 and <=1110011 --> for these ones only src has to be altered
	move.w 	(a0),d0						; d0=opcode
	and.w	#%1111000000000000,d0
	cmp.w 	#%1000000000000000,d0
	blo.s 	.exit
	move.w 	(a0),d0						; d0=opcode
	and.w	#%1111111000000000,d0
	cmp.w 	#%1110011000000000,d0
	bhi.s 	.exit
	move.w 	(a0),d0						; d0=opcode
	and.w	#%0000000000111000,d0
	beq.s 	.exit
	cmp.w 	#%0000000000110000,d0
	bls.s 	.chg_src
.exit	rts
.chg_dest:
	and.w 	#%1111110111111111,FCI_TB_opcode		; make sure destination register is not a7
	rts
.chg_src:
	and.w 	#%1111111111111110,FCI_TB_opcode		; make sure source register is not a7
	rts
.chg_srcdest:
	and.w 	#%1111110111111110,FCI_TB_opcode		; make sure source and dest registers are not a7
	rts

FCI_check_instruction_post:
	; . detect 'pea'
._pea:
	move.w 	FCI_TB_opcode,d0				; d0=opcode
	and.w 	#%1111111111111000,d0
	cmp.w 	#%0100100001000000,d0
	beq.s 	.exit						; it's a 'swap' that is authorized
	and.w 	#%1111111111000000,d0
	cmp.w 	#%0100100001000000,d0				; it's a 'pea'
	bne.s 	.exit
	move.l 	(sp)+,(sp)					; fix stack
.exit:	rts

; Counts items (nb analyzed instructions, NOPs, generated lines)
; \1 = item counter
FCI_1_MORE_ITEM: 	MACRO
	move.b 	\1,d0						; [100-9999] numbers
	move.b 	\1+1,d3						; [0-99] numbers
	moveq	#1,d2
	abcd 	d2,d3
	bcc.s 	.no_carry
	moveq 	#0,d2 						; X will be added with abcd
	abcd	d2,d0
.no_carry:
	move.b 	d0,\1
	move.b 	d3,\1+1
	ENDM

; Count number of analyzed instructions
FCI_1_more_analyzed_instruction:
	FCI_1_MORE_ITEM	FCI_nb_analyzed_instructions_bcd
	rts

; Count retained NOPs --> those that can't be replaced by an instruction
FCI_1_more_retained_NOP:
	FCI_1_MORE_ITEM	FCI_nb_retained_NOPs_bcd
	rts

; Count NOPs in last line --> those NOPs are generated in the last line because there's no instruction left to integrate in the source code
FCI_1_more_NOP_in_last_line:
	FCI_1_MORE_ITEM	FCI_nb_NOPs_in_last_line_bcd
	addq.w 	#1,FCI_nb_NOPs_in_last_line
	rts

; Count number of generated fullscreen lines
FCI_1_more_generated_fullscreen_line:
	FCI_1_MORE_ITEM	FCI_nb_generated_fullscreen_lines_bcd
	addq.w 	#1,FCI_nb_generated_fullscreen_lines
	rts

; ===========================================================
			SECTION DATA
; ===========================================================

FCI_instruction_analyzed	dc.b 	0			; flag 0=not analyzed yet 	1=analyzed

			even

FCI_vid_counter_start 		dc.b 	0,0

FCI_number_of_successive_NOPs	dc.w 	0			; number of successive NOPs to feed with alayzed instruction

; Statistics
FCI_nb_analyzed_instructions_bcd		dc.w 	0	; number of analyzed instructions --> BCD encoded
FCI_nb_retained_NOPs_bcd			dc.w 	0	; number of NOPs that have not been allocated --> BCD encoded
FCI_nb_NOPs_in_last_line_bcd			dc.w 	0	; number of NOPs that belong to the very last line of the generated code --> BCD encoded
FCI_nb_NOPs_in_last_line			dc.w 	0	; number of NOPs that belong to the very last line of the generated code --> numeric
FCI_nb_generated_fullscreen_lines_bcd		dc.w 	0	; number of fullscreen lines generated when integrating the code --> BCD encoded
FCI_nb_generated_fullscreen_lines		dc.w 	0	; number of fullscreen lines generated when integrating the code --> numeric

; ===========================================================
			SECTION BSS
; ===========================================================

FCI_unsupported_instruction		ds.b 	1		; 1=an unauthorized instruction has been identfified
FCI_instID				ds.b 	1		; ID of the unauthorized instruction

; This is to ensure that we're not writing in a dangerous place when analyzing 'move.l d0,-(a4)' for example
					ds.b 	1000
FCI_empty_space				ds.b 	1000

; Current instruction --> the one being analized info
FCI_current_instruction_nb_NOPs	ds.w 	1			; stores number of NOPs consumed by the current instruction
FCI_current_instruction_size	ds.w 	1			; stores the size of the instruction in bytes

FCI_end_generated_code		ds.l 	1			; contains the end address of the generated code

