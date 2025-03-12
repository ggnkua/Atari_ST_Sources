
;--------------------------------------------------------------------
; MFP REGISTERS + EQUATES
;--------------------------------------------------------------------

M_MFP		=	$FFFFFA00
M_MFP_NUMREGS	=	19
M_GENERAL_IO	=	M_MFP+1
M_ACTIVE_EDGE	=	M_MFP+3
M_DATA_DIR	=	M_MFP+5

M_ENABLE_A	=	M_MFP+7
M_A_MONODETECT	=	7
M_A_IO6		=	6
M_A_TIMERA	=	5
M_A_RXFULL	=	4
M_A_RXERROR	=	3
M_A_TXEMPTY	=	2
M_A_TXERROR	=	1
M_A_TIMERB	=	0

M_ENABLE_B	=	M_MFP+9
M_B_FDC		=	7
M_B_KEYBOARD	=	6
M_B_TIMERC	=	5
M_B_TIMERD	=	4
M_B_IO3		=	3
M_B_IO2		=	2
M_B_IO1		=	1
M_B_IO0		=	0

M_PENDING_A	=	M_MFP+$B
M_PENDING_B	=	M_MFP+$D
M_INSERVICE_A	=	M_MFP+$F
M_INSERVICE_B	=	M_MFP+$11
M_MASK_A	=	M_MFP+$13
M_MASK_B	=	M_MFP+$15

M_VECTOR	=	M_MFP+$17
M_SOFTWARE_END	=	3

M_CONTROL_A	=	M_MFP+$19
M_CONTROL_B	=	M_MFP+$1B
M_CONTROL_CD	=	M_MFP+$1D
M_CSHIFT	=	4
M_STOP		=	0
M_1000KHZ	=	1
M_400KHZ	=	2
M_250KHZ	=	3
M_80KHZ		=	4
M_62KHZ		=	5
M_40KHZ		=	6
M_20KHZ		=	7
M_EVENT_COUNT	=	8

M_DATA_A	=	M_MFP+$1F
M_DATA_B	=	M_MFP+$21
M_DATA_C	=	M_MFP+$23
M_DATA_D	=	M_MFP+$25

;--------------------------------------------------------------------
; MFP Macros
;--------------------------------------------------------------------

