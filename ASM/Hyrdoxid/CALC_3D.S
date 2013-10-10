********************************************************
*precalculs trigonometriques			*
*en entree:x_angle,y_angle,z_angle(angle de rotation)  *	
*en sortie:A,B,C,D,E,F,G,H,I*512		       	*				
********************************************************
	BSR	SP_TO_PL
TRIGO
	MOVEM.L	D0-D7/A4-A6,-(SP)
	LEA	COS_TAB,A4
	LEA	SIN_TAB,A5
*	LEA	X_ANGLE,A6
	MOVE.W	#10,D2	;d2=x angle
	MOVE.W	#20,D1	;d1=y ...
	MOVE.W	#0,D0	;d0=z ...

	MOVE.W	(A5,D2.W),D5	;d5=sinx
	MOVE.W	(A4,D2.W),D4	;d4=cosx
	MOVE.W	(A5,D1.W),D3	;d3=siny
	MOVE.W	(A4,D1.W),D2	;d2=cosy
	MOVE.W	(A5,D0.W),D1	;d1=sinz
	MOVE.W	(A4,D0.W),D0	;d0=cosz

	LEA	VAR_3D,A6		;zone sauvegarde calc intermediaire
	MOVEQ.W	#9,D7		;nombre de decalages pour/512

	;**********CALCUL DE C************
SP_C
	MOVE.W	D3,D6		;siny
	NEG.W	D6		;-siny	
	MOVE.W	D6,(A6)+
	;**********CALCUL DE F************
SP_F	
	MOVE.W	D2,D6		;cosy
	MULS	D5,D6		;cosy*sinx
	ASR.L	D7,D6		;/512
	MOVE.W	D6,(A6)+
	;**********CALCUL DE I************
SP_I
	MOVE.W	D2,D6		;cosy
	MULS	D4,D6		;cosy*cosx
	ASR.L	D7,D6		;/512
	MOVE.W	D6,(A6)+		
	;**********CALCUL DE A************
SP_A
	MOVE.W	D0,D6		;cosz
	MULS	D2,D6		;cosz*cosy
	ASR.L	D7,D6		
	MOVE.W	D6,(A6)+
	;**********CALCUL DE D************
SP_D
	MOVE.W	D1,D6		;sinz	
	MULS	D4,D6		;sinz*cosx
	ASR.L	D7,D6
	MOVE.W	D6,A4

	MOVE.W	D0,D6		;cosz
	MULS	D3,D6		;cosz*siny
	ASR.L	D7,D6		
	MULS	D5,D6		;cosz*siny*sinx
	ASR.L	D7,D6
	SUB.W	A4,D6		;(cosz*siny*sinx)-(sinz*cosx)
	MOVE.W	D6,(A6)+
	;**********CALCUL DE G************
SP_G
	MOVE.W	D7,D6		;sinz
	MULS	D5,D6		;sinz*sinx
	ASR.L	D7,D6
	MOVE.W	D6,A4

	MOVE.W	D0,D6		;cosz
	MULS	D3,D6		;cosz*siny
	ASR.L	D7,D6
	MULS	D4,D6		;cosz*siny*cosx
	ASR.L	D7,D6
	ADD.W	A4,D6		;(cosz*siny*cosx)+(sinz*sinx)
	MOVE.W	D6,(A6)+
	;**********CALCUL DE B************
SP_B
	MOVE.W	D1,D6		;sinz		
	MULS	D2,D6		;sinz*cosy
	ASR.L	D7,D6
	MOVE.W	D6,(A6)+
	;**********CALCUL DE E************
SP_E
	MOVE.W	D0,D6		;cosz
	MULS	D4,D6		;cosz*cosx
	ASR.L	D7,D6
	MOVE.W	D6,A4

	MOVE.W	D1,D6		;sinz
	MULS	D3,D6		;sinz*siny
	ASR.L	D7,D6
	MULS	D5,D6		;sinz*siny*sinx
	ASR.L	D7,D6
	ADD.W	A4,D6		;(sinz*siny*sinx)+(cosz*cosx)
	MOVE.W	D6,(A6)+	
	;**********CALCUL DE H*************
SP_H
	MOVE.W	D0,D6		;cosz
	MULS	D5,D6		;cosz*sinx
	ASR.L	D7,D6	
	MOVE.W	D6,A4

	MOVE.W	D1,D6		;sinz
	MULS	D3,D6		;sinz*siny		
	ASR.L	D7,D6
	MULS	D4,D6		;sinz*siny*cosx
	ASR.L	D7,D6
	SUB.W	A4,D6		;(sinz*siny*cosx)-(cosz*sinx)
	MOVE.W	D6,(A6)+
	MOVEM.L	(SP)+,D0-D7/A4-A6
	BSR	SP_TO_PL
	RTS
********************************************
*calcul des coordonnees planes		   *
*en entree:xe,ye,ze,z_pt_fuite   	   *
*en sortie:xp,yp coordonnees planes	   *
*new_xe,new_ye,new_ze nouvelles coord sp   *
********************************************

SP_TO_PL
	LEA	VAR_3D,A6
	MOVE	#-$58,(A6)+
	MOVE	#$2B,(A6)+
	MOVE	#$1F6,(A6)+
	MOVE	#$1F8,(A6)+
	MOVE	#$7,(A6)+
	MOVE	#$57,(A6)+
	MOVE	#0,(A6)+
	MOVE	#$1FE,(A6)+
	MOVE	#-$2C,(A6)+		
	MOVEM.L	D0-D7/A1-A6,-(SP)	
	
*	LEA	XE,A6
*	MOVEM.W	(A6)+,D0-D2
	MOVE	#50,D0
	MOVE	#30,D1
	MOVE	#-40,D2

	LEA	XDEP,A3
	MOVEM.W	(A3)+,D3-D5
	EXT.L	D3
	EXT.L	D4
	EXT.L	D5
	MOVEQ.W	#9,D6
	ASL.L	D6,D3		;xdep*512
	ASL.L	D6,D4		;ydep*512
	ASL.L	D6,D5		;zdep*512
	MOVE.L	D3,A1
	MOVE.L	D4,A2
	MOVE.L	D5,A3

	LEA	VAR_3D,A6
	MOVE.W	D0,D3
	MOVE.W	D1,D4
	MOVE.W	D2,D5

	MULS	(A6)+,D3	;d3=c*xe*512
	MULS	(A6)+,D4	;d4=f*ye*512
	MULS	(A6)+,D5	;d5=i*ze*512
	ADD.L	D4,D5		;+f*ye*512
	ADD.L	D3,D5		;+c*xe*512
	ADD.L	A3,D5		;+zdep*512
	MOVE.L	D5,A5		;a5=new_ze*512
	DIVS	#256,D5		;d5=new_ze/z_pt_fuite
	
	MOVE.W	#512,D7
	SUB.W	D5,D7		;d7=512*q
				;d7=512*(1-new_ze/z_pt_fuite)
	MOVE.W	D0,D3		;d3=xe
	MOVE.W	D1,D4		;d4=ye
	MOVE.W	D2,D5		;d5=ze

	MULS	(A6)+,D3	;d3=a*xe*512
	MULS	(A6)+,D4	;d4=d*ye*512
	MULS	(A6)+,D5	;d5=g*ze*512
	ADD.L	D4,D5		
	ADD.L	D3,D5
	ADD.L	A1,D5
	MOVE.L	D5,A4		;a4=new_xe*512
	DIVS	D7,D5		;d5=new_xe/q

	MULS	(A6)+,D0	;d0=b*xe*512
	MULS	(A6)+,D1	;d1=e*ye*512
	MULS	(A6)+,D2	;d2=h*ze*512
	ADD.L	D0,D1		
	ADD.L	D1,D2
	ADD.L	A2,D2
	MOVE.L	D2,D6		;d6=new_ye*512
	DIVS	D7,D2		;d2=new_ye/q

	LEA	XP,A6		;A6 pointe sur zone de sauve 
				;coord planes
	ADD.W	#192,D5
	MOVE.W	D5,(A6)+	;xp
	
	ADD.W	#120,D2
	MOVE.W	D2,(A6)+	;yp

	MOVE.L	A4,D5
	MOVE.L	A5,D7
	MOVEQ.W	#9,D0
	ASR.L	D0,D5
	ASR.L	D0,D6
	ASR.L	D0,D7
	;sauve nouvelles coordonnees spatiales
	MOVE.W	D5,(A6)+
	MOVE.W	D6,(A6)+
	MOVE.W	D7,(A6)+
	MOVEM.L	(SP)+,D0-D7/A1-A6
	RTS

	SECTION	DATA
COS_TAB		INCBIN	"C:\UTILS\CODE_UTI.LS\GFABASIC\COSIN.DAT"
SIN_TAB		EQU	COS_TAB+720	
	SECTION	BSS
	 	  																																		  																																																															SECTION	BSS
XE		DS.W	1
YE		DS.W	1
ZE		DS.W	1

XDEP		DS.W	1
YDEP		DS.W	1
ZDEP		DS.W	1

XP		DS.W	1
YP		DS.W	1

NEW_XE		DS.W	1
NEW_YE		DS.W	1
NEW_ZE		DS.W	1

X_ANGLE		DS.W	1
Y_ANGLE		DS.W	1
Z_ANGLE		DS.W	1

Z_PT_FUITE		DS.W	1

VAR_3D		DS.W	9
	END
