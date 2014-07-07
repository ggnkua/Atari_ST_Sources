;************************************************************************
;
;       EQUATES for DSP56000 interrupts
;       Reference: DSP56000 User's Manual, Table 8.1, Interrupt Sources
;
;************************************************************************

;intequ	ident	1,0

i_reset	EQU	$0000   ; hardware _RESET
i_stack	EQU	$0002   ; stack error
i_trace	EQU	$0004   ; trace
i_swi	EQU	$0006   ; SWI
i_irqa	EQU	$0008   ; _IRQA
i_irqb	EQU	$000A   ; _IRQB
 
i_ssird	EQU	$000C   ; SSI receive data
i_ssirde	EQU	$000E   ; SSI receive data with exception status
i_ssitd	EQU	$0010   ; SSI transmit data
i_ssitde	EQU	$0012   ; SSI transmit data with exception status
 
i_scird	EQU	$0014   ; SCI receive data
i_scirde	EQU	$0016   ; SCI receive data with exception status
i_scitd	EQU	$0018   ; SCI transmit data
i_sciil	EQU	$001A   ; SCI idle line
i_scitm	EQU	$001C   ; SCI timer
 
i_resh	EQU	$1e	; ???
 
i_hstrd	EQU	$0020	; host receive data
i_hsttd	EQU	$0022	; host transmit data
i_hstc	EQU	$0024	; host command
i_hstuc0	EQU	$0026	; host user command 0
i_hstuc1	EQU	$0028	; ---- ---- ------- 1
i_hstuc2	EQU	$002A	; etc...
i_hstuc3	EQU	$002C	;
i_hstuc4	EQU	$002C	;
i_hstuc5	EQU	$0030	;
i_hstuc6	EQU	$0032	;
i_hstuc7	EQU	$0034	;
i_hstuc8	EQU	$0036	;
i_hstuc9	EQU	$0038	;
i_hstuc10	EQU	$003A	;
i_hstuc11	EQU	$003C	;
i_illegal	EQU	$003E	; Illegal instruction
