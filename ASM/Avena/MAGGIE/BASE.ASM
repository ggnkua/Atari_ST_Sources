; BASE.ASM

; Base Equates and Macros
;  for the 'Tour de Falcon' Demo




;--------------------- EQUATES--------------------------


PBC	equ	$ffe0	;Port B Control register
PCC	equ	$ffe1	;Port C Control register
PBDDR	equ	$ffe2	;Port B Data Direction Register
PCDDR	equ	$ffe3	;Port C Data Direction Register
PBD	equ	$ffe4	;Port B Data register
PCD	equ	$ffe5	;Port C Data register
HCR	equ	$ffe8	;Host Control Register
HSR	equ	$ffe9	;Host Status Register
hsr	equ	$ffe9

HRX	equ	$ffeb	;Host Receive Register
hrx	equ	$ffeb

HTX	equ	$ffeb	;Host Transmit Register
htx	equ	$ffeb

BCR	equ	$fffe	;Port A Bus Control Register

; OB3 Equates:
C_Length	equ	0
C_ObjCount	equ	1
C_BSP		equ	2
C_Objects	equ	3

O_Desc		equ	0
O_Points	equ	1
O_Point_Ptr	equ	2
O_Polys		equ	3
O_Poly_Ptr	equ	4
O_Normal_Ptr	equ	5
O_Gour_Ptr	equ	6
O_BSP_Ptr	equ	7

BSP_Count	equ	0
BSP_Start	equ	1
BSP_Polys	equ	2

;--------------------- MACROS --------------------------
wait_receive	MACRO
		jclr	#0,x:<<HSR,*
		ENDM
wait_transmit	MACRO
		jclr	#1,x:<<HSR,*
		ENDM
;-------------------------------------------------------
