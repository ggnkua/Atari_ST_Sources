;************************************************************************
;
;       EQUATES for DSP56000 interrupts
;       Reference: DSP56000 User's Manual, Table 8.1, Interrupt Sources
;
;************************************************************************

intequ  ident   1,0

i_reset EQU     $0000   ; hardware _RESET
i_stack EQU     $0002   ; stack error
i_trace EQU     $0004   ; trace
i_swi   EQU     $0006   ; SWI
i_irqa  EQU     $0008   ; _IRQA
i_irqb  EQU     $000A   ; _IRQB
 
i_ssird EQU     $000C   ; SSI receive data
i_ssirde EQU    $000E   ; SSI receive data with exception status
i_ssitd EQU     $0010   ; SSI transmit data
i_ssitde EQU    $0012   ; SSI transmit data with exception status
 
i_scird EQU     $0014   ; SCI receive data
i_scirde EQU    $0016   ; SCI receive data with exception status
i_scitd EQU     $0018   ; SCI transmit data
i_sciil EQU     $001A   ; SCI idle line
i_scitm EQU     $001C   ; SCI timer
 
i_hstrd EQU     $0020   ; host receive data
i_hsttd EQU     $0022   ; host transmit data
i_hstcm EQU     $0024   ; host command (default)
