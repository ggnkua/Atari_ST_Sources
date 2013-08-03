; BASE.ASM

; Base Equates and Macros

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

C_Length			equ	0
C_ObjCount			equ	1
C_BSP				equ	2
C_Objects			equ	3
		
O_Desc				equ	0		;see also O_Desc2
O_Points			equ	1
O_Point_Ptr			equ	2
O_Polys				equ	3
O_Poly_Ptr			equ	4
O_Normal_Ptr		equ	5
O_Gour_Ptr			equ	6
O_BSP_Ptr			equ	7
O_Tex_Ptr			equ	8
O_Desc2				equ	9		;describes the supplied data

								;bits: 0 - polygon normals
								;      1 - point normals
								;      2 - point values, texmap
								;      3 - point values, shading

O_Desc3				equ	10		;extra info for O_Desc:



BSP_Count			equ	0		;obsolete as of v2
BSP_Start			equ	1		;obsolete as of v2
BSP_Polys			equ	2		;obsolete as of v2
		
Object_Shape		equ	0
Object_X			equ	1
Object_Y			equ	2
Object_Z			equ	3
Object_Rot1			equ	4
Object_Rot2			equ	5
Object_Rot3			equ	6
Object_Misc			equ	7
Object_Size			equ	8

Drawlist_Address	equ	0
Drawlist_X			equ	1
Drawlist_Y			equ	2
Drawlist_Z			equ	3
Drawlist_Rotated_X	equ	4
Drawlist_Rotated_Y	equ	5
Drawlist_Rotated_Z	equ	6
Drawlist_Object_Size equ 7

OFF					equ	0
ON					equ	1	

xmin_bit			EQU	0
xmax_bit			EQU	1
ymin_bit			EQU	2
ymax_bit			EQU	3



;--------------------- MACROS --------------------------
wait_receive	MACRO
		jclr	#0,x:<<HSR,*
		ENDM
wait_transmit	MACRO
		jclr	#1,x:<<HSR,*
		ENDM
;-------------------------------------------------------
looptest	MACRO text,label
		move #"\text",x0
		cmp x0,a
		jeq \label
		ENDM

;-------------------------------------------------------
setdefault	MACRO label,value
			IF @DEF(label)
			ELSE
label			equ	value
			ENDIF
		ENDM
