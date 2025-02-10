

MFP			=	$FFFFFA00
ENABLE_A		=	MFP+$07		; int enable A
ENABLE_B		=	MFP+$09		; int enable B
PENDING_A		=	MFP+$0B		; int pending A
PENDING_B		=	MFP+$0D		; int pending B
IN_SERVICE_A	=	MFP+$0F		; int in-service A
IN_SERVICE_B	=	MFP+$11		; int in-service B
MASK_A		=	MFP+$13		; int mask A
MASK_B		=	MFP+$15		; int mask B
VECTOR		=	MFP+$17		; MFP vector base
CTRL_A		=	MFP+$19		; MFP timer A control
CTRL_B		=	MFP+$1B		; MFP timer B control
DATA_A		=	MFP+$1F		; timer A data
DATA_B		=	MFP+$21		; timer B data

HBI_VEC		=	$68
VBI_VEC		=	$70
TIMER_A		=	$134			; Horizontal Blank Vector
TIMER_B		=	$120			; Horizontal Blank Vector
TIMER_C		=	$114
KBD_VEC		=	$118
GVBI_VEC		=	$4D2

