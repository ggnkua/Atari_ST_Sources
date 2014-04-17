;************************************************************************
;
;       EQUATES for DSP56000 interrupts
;       Reference: DSP56000 User's Manual, Table 8.1, Interrupt Sources
;
;************************************************************************

intequ  ident   1,0

I_RESET EQU     $0000   ; hardware _RESET
I_STACK EQU     $0002   ; stack error
I_TRACE EQU     $0004   ; trace
I_SWI   EQU     $0006   ; SWI
I_IRQA  EQU     $0008   ; _IRQA
I_IRQB  EQU     $000A   ; _IRQB
 
I_SSIRD EQU     $000C   ; SSI receive data
I_SSIRDE EQU    $000E   ; SSI receive data with exception status
I_SSITD EQU     $0010   ; SSI transmit data
I_SSITDE EQU    $0012   ; SSI transmit data with exception status
 
I_SCIRD EQU     $0014   ; SCI receive data
I_SCIRDE EQU    $0016   ; SCI receive data with exception status
I_SCITD EQU     $0018   ; SCI transmit data
I_SCIIL EQU     $001A   ; SCI idle line
I_SCITM EQU     $001C   ; SCI timer
 
I_HSTRD EQU     $0020   ; host receive data
I_HSTTD EQU     $0022   ; host transmit data
I_HSTCM EQU     $0024   ; host command (default)
