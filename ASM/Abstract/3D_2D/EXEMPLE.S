* Little code by SKYNET/ABSTRACT                                          

Z_MAX		SET	0*512			
Z_INC		SET	20*512			

MFP	  	equ	$fffffa00

MFPIERA	equ	MFP+$07
MFPIERB	equ	MFP+$09
MFPISRA	equ	MFP+$0f
MFPISRB	equ	MFP+$11
MFPIMRA	equ	MFP+$13
MFPIMRB	equ	MFP+$15
MFPVR		equ	MFP+$17
MFPTACR	equ	MFP+$19
MFPTBCR	equ	MFP+$1b
MFPTADR	equ	MFP+$1f
MFPTBDR	equ	MFP+$21

*		opt o+

*************** QUELQUES MACRO ****************

calcul_constantes	macro
	move.w	#9,d7				
	move.w	(a2)+,d1
	move.w	(a2)+,d3			
	move.w	(a2)+,d5			
	move.w	(a0,d1.w),d0	
	move.w	(a1,d1.w),d1	
	move.w	(a0,d3.w),d2	
	move.w	(a1,d3.w),d3	
	move.w	(a0,d5.w),d4	
	move.w	(a1,d5.w),d5	
	move.w	d4,d6		

	move.w	d1,-(sp)	
	move.w	d0,-(sp)	
	move.w	d2,-(sp)	
	move.w	d5,-(sp)	

	muls		d1,d4				
	muls		d5,d1			
	muls		d0,d5				
	muls		d6,d0				
	muls		d6,d2				

	asr.l		d7,d4				
	asr.l		d7,d1				
	asr.l		d7,d5				
	asr.l		d7,d0				
	asr.l		d7,d2				
	move.w	d2,(a3)+			
	
	move.l	d4,d6				
	muls		d3,d6				
	asr.l		d7,d6				
	sub.w		d5,d6				
	move.w	d6,(a3)+
	muls		d3,d5			
	asr.l		d7,d5				
	neg.w		d4
	add.w		d5,d4			
	move.w	d4,6(a3)

	move.l	d1,d5				
	muls		d3,d5				
	asr.l		d7,d5			
	add.w		d0,d5			
	move.w	d5,4(a3)
	muls		d3,d0				
	asr.l		d7,d0				
	add.w		d0,d1				
	move.w	d1,(a3)+
	neg.w		d3					
	move.w	d3,6(a3)
	
	move.w	(sp)+,d0			
	move.w	(sp)+,d6			
	muls		d6,d0				
	asr.l		d7,d0				
	move.w	d0,(a3)+

	move.w	(sp)+,d0			
	move.w	(sp)+,d5			
	muls		d6,d0				
	asr.l		d7,d0			
	move.w	d0,8(a3)
	muls		d6,d5				
	asr.l		d7,d5				
	move.w	d5,6(a3)
	add.w		#10,a3			
	
	ENDM


	TEXT

	clr.l		-(sp)
	move.w	#$20,-(sp)
	trap		#1
	addq.l	#6,sp
	
	bsr		SAVE_STATE
	bsr		INSTALL_INTER
	bsr		SPE_INITS

WAIT_SPACE
	cmpi.b	#$39,$fffffc02.w
	bne.s		WAIT_SPACE
WAIT_NO_SPACE
	cmpi.b	#$39+$80,$fffffc02.w
	bne.s		WAIT_NO_SPACE
	
	move.w	#$2700,sr
	bsr		RESTORE_STATE
	move.w	#$2300,sr 

	pea		0.w
	trap		#1

***************************************************************************
*************************
* sauve l'etat initiale *
*************************
SAVE_STATE
	lea		$ffff8200.w,a6			
	lea		OLD_SHIFTER,a5				
	movep.l	(a6),d0
	move.l	d0,(a5)+					
	movem.l	$40(a6),d0-7
	movem.l	d0-7,(a5)					
	lea		32(a5),a5
	move.w	$60(a6),(a5)				
	
	move.l	$70.w,OLD_VBL				
	move.l	$118.w,OLD_KBD				
	move.b	MFPIERA.w,OLD_MFP			
	move.b	MFPIERB.w,OLD_MFP+1		
	move.b	MFPIMRA.w,OLD_MFP+2		
	move.b	MFPIMRB.w,OLD_MFP+3		
	RTS

INSTALL_INTER
; ON COUPE LA SOURIS 
*	move.b	#$12,$fffffc02.w			
*	dc.w		$a00a				 

; Interruptions
	clr.b		MFPIERA.w					
	move.b	#$40,MFPIERB.w				
	move.b	#$40,MFPIMRB.w				
	move.l	#VBL_RET,$70.w				
	stop		#$2300				
							
; Paramätres Çcran
	clr.w		$60(a6)				
	movem.l	PIC+2,d0-d7
	movem.l	d0-d7,$40(a6)				
	move.l	#SCREEN+256,d0				
	clr.b		d0				
	move.l	d0,ADR_SCR				
	move.l	d0,ADR_SCR2				
	add.l		#160*200,ADR_SCR2		
	lsr.l		#8,d0	
	movep.w	d0,$1(a6)				
	RTS

********************
* INSTAL LES       *
* ANCIENNES INTERS *
********************
RESTORE_STATE
	move.b	OLD_MFP,MFPIERA.w				
	move.b	OLD_MFP+1,MFPIERB.w	
	move.b	OLD_MFP+2,MFPIMRA.w		
	move.b	OLD_MFP+3,MFPIMRB.w	
	move.l	#VBL_RET,$70.w			
	stop		#$2300			
	stop		#$2300			
	move.w	#$2700,sr
	
; REINSTALLE LES REGISTRES DU SHIFTER
	lea		$ffff8200.w,a6		
	lea		OLD_SHIFTER,a5		
	move.l	(a5)+,d0						
	movep.l	d0,(a6)
	movem.l	(a5),d0-7
	movem.l	d0-7,$40(a6)			
	lea		32(a5),a5
	move.w	(a5),$60(a6)			
  	move.l	OLD_KBD,$118.w			
	move.l	OLD_VBL,$70.w			

TEST_KEY
	btst.b	#0,$fffffc00.w
	beq.s		NO_KEY
	move.b	$fffffc02.w,d0
	bra.s		TEST_KEY
NO_KEY
; Souris		
	dc.w		$a009			
	move.b	#8,$fffffc02.w			
	RTS

***************************************************************************
SPE_INITS
	
	move.l	ADR_SCR,a0
	move.l	ADR_SCR2,a1
	lea		160*70(a0),a0
	lea		160*70(a1),a1
	lea		PIC+34,a2
	move.w	#160*50/4-1,d7
.pic
	move.l	(a2),(a0)+
	move.l	(a2)+,(a1)+
	dbf		d7,.pic
	BRA		JMP_PIC
PIC		INCBIN	AST-01.PI1

JMP_PIC
	move.l	ADR_SCR,d0				
	lea		BUF_EFF,a1			
	move.w	#399,d7					
.fix_buf
	move.l	d0,(a1)+				
	dbf		d7,.fix_buf			

	move.l	ADR_SCR,a0				
	move.l	ADR_SCR2,a1			
	addq.w	#6,a0
	addq.w	#6,a1
	lea		TAB_Y,a2	
	lea		TAB_Y2,a3	
	move.w	#199,d7			
.make_y_tab
	move.l	a0,(a2)+
	move.l	a1,(a3)+
	lea		160(a0),a0
	lea		160(a1),a1
	dbf		d7,.make_y_tab	
	
	lea		TAB_X,a1	
	moveq		#0,d0		
	move.w	#19,d1			
.mk_tabx
	lea		TAB_X1_16,a0	
	rept		16		
	move.w	(a0)+,(a1)+
	move.w	d0,(a1)+
	endr
	addq.w	#8,d0			
	dbf		d1,.mk_tabx	

	lea		INC_CURVE(pc),a0	
	lea		DEF_ANGLES(pc),a1	
	move.w	(a0)+,(a1)+			
	move.l	a1,a2				
	moveq		#2,d0			
.make_curve
	move.l	a2,a1				
	addq.w	#2,a2				
	move.l	#720,d6				
	move.w	(a0)+,d5			
	move.w	d5,d7				
	lsr.w		#1,d7			
	subq.w	#1,d7				
	tst.w		d5			
	bne.s		.no_zero		
	dbf		d0,.make_curve		
	bra.s		.end_of_curve			
.no_zero
	divs		d5,d6						
	subq.w	#1,d6					
	move.w	d6,d4						
.make_all_circle
	moveq		#0,d2						
.add_angles
	move.w	d2,(a1)					
	add.w		d5,d2						
	addq.w	#6,a1						
	dbf		d6,.add_angles			
	move.w	d4,d6					
	dbf		d7,.make_all_circle	
	dbf		d0,.make_curve			
.end_of_curve

	lea		COS_TAB(pc),a0			
	lea		SIN_TAB(pc),a1			
	lea		DEF_ANGLES(pc),a2		
	lea		VAR_ANGLES(pc),a3		
	move.w	(a2)+,d7					
.make_all_variables
	move.w	d7,-(sp)					
	calcul_constantes					
	move.w	(sp)+,d7					
	dbf		d7,.make_all_variables	
	move.w	#$1234,(a3)			

	move.l	#INSTAL_VBL,$70.w
		RTS

INSTAL_VBL
	move.l	#VBL_PLAY,$70.w
VBL_RET	RTE

VBL_PLAY
	cmpi.b	#$66,$fffffc02.w		
	bne.s		.no_freez				
	rte
.no_freez
	move.l	C_Y2,d0					
	move.l	C_Y,C_Y2					
	move.l	d0,C_Y					
	move.l	C_EFF2,d0				
	move.l	C_EFF,C_EFF2			
	move.l	d0,C_EFF
	move.l	ADR_SCR2,d0				
	move.l	ADR_SCR,ADR_SCR2		
	move.l	d0,ADR_SCR
	lsr.w		#8,d0						
	move.l	d0,$ffff8200.w

	move.l	C_EFF2,a0			
	moveq		#0,d0						
	rept		120/6						
	movem.l	(a0)+,a1-6				
	move.w	d0,(a1)
	move.w	d0,(a2)
	move.w	d0,(a3)
	move.w	d0,(a4)
	move.w	d0,(a5)
	move.w	d0,(a6)
	endr									
	move.l	(a0)+,a1					
	move.w	d0,(a1)					

	move.l	Z_DEP,d0				 
	cmpi.l	#Z_MAX,d0			
	bge.s		.ok			
	move.l	#Z_INC,d0			
	add.l		d0,Z_DEP		
.ok	
	cmpi.l	#Z_MAX,Z_DEP			
	ble.s		.ko			
	move.l	#Z_MAX,Z_DEP
.ko
	cmpi.b	#$1d,$fffffc02.w		 
	bne.s		.no_tst_time		
	move.w	#$201,$ffff8240.w		
.no_tst_time
	lea		TAB_X,a4		
	move.l	C_Y,a5				
	move.l	C_EFF2,a6			
	lea		CO_POINTS,a0		
	move.l	CMPT_VAR,a3			
	cmpi.w	#$1234,(a3)			
	bne.s		.okcmp			
	move.l	#VAR_ANGLES,CMPT_VAR	
	move.l	CMPT_VAR,a3
.okcmp
	move.w	#120,d7			
.aff_points
	move.l	a3,a2			
	movem.w	(a0)+,d0-2		

	move.w	d0,d3			
	muls		(a2)+,d3	
	move.w	d1,d4			
	muls		(a2)+,d4	
	add.l		d3,d4		
	move.w	d2,d3			
	muls		(a2)+,d3	
	add.l		d3,d4		
		move.w	d0,d3		
	muls		(a2)+,d3	
	move.w	d1,d5			
	muls		(a2)+,d5	
	add.l		d3,d5		
	move.w	d2,d3			
	muls		(a2)+,d3	
	add.l		d3,d5		

	move.w	d0,d3			
	muls		(a2)+,d3	
	move.w	d1,d6			
	muls		(a2)+,d6	
	add.l		d3,d6		
	move.w	d2,d3			
	muls		(a2)+,d3	
	add.l		d3,d6		
	add.l		Z_DEP,d6	
	divs		P_FUITE,d6				
	sub.w		#512,d6					
	neg.w		d6						
	
	divs		d6,d4						
	divs		d6,d5						
	add.w		#160,d4					
	add.w		#100,d5					

	lsl.w		#2,d5
	move.l	(a5,d5.w),a1			
	lsl.w		#2,d4					
	move.w	(a4,d4.w),d2			
	move.w	2(a4,d4.w),d4			
	add.w		d4,a1						
	or.w		d2,(a1)					
	move.l	a1,(a6)+					

	dbf		d7,.aff_points			
	
	add.l	#18,CMPT_VAR			
	
	move.w	PIC+2,$ffff8240.w		
	
	RTE

***************************************************************************
* ZONE DATA *
*************

				DATA

COS_TAB		INCBIN	COSIN.DAT
SIN_TAB		EQU		COS_TAB+720
P_FUITE		DC.W		300
Z_DEP			DC.L		-2000*512

CO_POINTS	
Y	SET	-50
	REPT	11
	DC.W	-50,Y,15+Y
	DC.W	-40,Y,12+Y
	DC.W	-30,Y,9+Y
	DC.W	-20,Y,6+Y
	DC.W	-10,Y,3+Y
	DC.W	0,Y,0+Y
	DC.W	10,Y,-3+Y
	DC.W	20,Y,-6+Y
	DC.W	30,Y,-9+Y
	DC.W	40,Y,-12+Y
	DC.W	50,Y,-15+Y
Y	SET	Y+10
	ENDR

INC_CURVE	DC.W		360-1					
		DC.W		1*2			
  		DC.W		4*2					
		DC.W		1*2					
								
CMPT_VAR		DC.L		VAR_ANGLES
C_Y			DC.L		TAB_Y
C_Y2			DC.L		TAB_Y2
C_EFF			DC.L		BUF_EFF
C_EFF2		DC.L		BUF_EFF2
TAB_X1_16
	DC.W	$8000,$4000,$2000,$1000,$0800,$0400,$0200,$0100
	DC.W	$0080,$0040,$0020,$0010,$0008,$0004,$0002,$0001

***************************************************************************
* ZONE BSS *
************
					BSS

TAB_X			DS.W	420*2
TAB_Y			DS.L	300
TAB_Y2		DS.L	300
DEF_ANGLES	DS.W	360*4
VAR_ANGLES	DS.W	360*10+2
BUF_EFF		DS.L	200
BUF_EFF2		DS.L	200

OLD_SHIFTER
	DS.W		19
; SAUVEGARDE DES INTERUPTIONS
OLD_VBL									
	DS.L		1
OLD_KBD									
	DS.L		1
OLD_MFP									
	DS.B		4
FLAG 	
	DS.B		1						
			EVEN
ADR_SCR									
	DS.L		1
ADR_SCR2								
	DS.L		1
SCREEN	
	DS.B		320*400+256					




