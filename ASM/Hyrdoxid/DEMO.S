*****************************************************
*************PREMIERE DEMO SUR FALCON****************
**************by HYDROXID !!!!!!!!!******************
*****************************************************

	OPT	O+,W-		;Optimisations, pas de Warnings
	include	f:\bordel\tos_030.s	;
	include	f:\bordel\hard_sys.s	;
	include	f:divers.dsp\sndtrack.dsp\dsp_play.inc	;D‚finitions du soundtracker

ReadHost	MACRO	dst
.\@	btst	#0,$ffffa202.w
	beq.s	.\@
	move.l	$ffffa204.w,\1
	ENDM
WritHost	MACRO	src
.\@	btst	#1,$ffffa202.w
 	beq.s	.\@
	move.l	\1,$ffffa204.w
	ENDM
*****************************************
	SECTION	TEXT
points=460

start	
	LEA.L	PILE,SP	
	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	CLR.B	$484.W
	MOVE.B	#18,$FFFFC02
	BSR	INITS
	MOVE.W	#0,$FFFF8240
	BSR	CLR_REGISTERS
	BSR	CLS
	CLR.L	$FFFF9800
******************
	BSR	PART1	
;	
	BSR	PART3
******************
	BRA	END
**********************************************************************************************
*******************PART1:STARFIELD 3 AXES************************************************************************
**********************************************************************************************
PART1
	MOVE.L	#$AAAA00AA,$FFFF9804
	MOVE.L	#$FFFF00FF,$FFFF9808
	MOVE.L	#$FFFF00FF,$FFFF980C
	BSR	VBL
	BSR	INIT_MOD
	CLR.W	COMPT
	MOVE.L	#SAVE_POINT,SAVE1
	MOVE.L	#SAVE_POINT2,SAVE2
LOOP
	CLR.L	$FFFF9800
	BSR	EFFA2	
	ADD.W	#1,COMPT
	CMPI.W	#1000,COMPT
	BLS.S	NO_BYE
	SUB.W	#20,ZDEP
NO_BYE
	MOVE.L	SAVE1,A1
	CMPI.W	#192,XADD
	BLE.S	STOP_MOVE
	SUBQ.W	#1,XADD
	BRA.S	STOP_ZOOM
STOP_MOVE
	CMPI.W	#160,ZDEP
	BGT.S	STOP_ZOOM
	ADDQ.W	#8,ZDEP
STOP_ZOOM
	BSR	MAKE_DOTS
	MOVEM.L	A1-A2,-(SP)		; syncro ecran
	MOVE.L	AFFECR,A1
	MOVE.L	WORKECR,A2
	MOVE.L	A2,AFFECR
	MOVE.L	A1,WORKECR
	move.b affecr+1,$ffff8201.w
	move.b affecr+2,$ffff8203.w
	MOVE.L	SAVE1,A1		;swap zones de sauvegarde
	MOVE.L	SAVE2,A2
	MOVE.L	A1,SAVE2
	MOVE.L	A2,SAVE1
	MOVEM.L	(SP)+,A1-A2
	CMPI.B	#56,$FFFFC02
	BNE.S	NO_ALT
	MOVE.L	#$FF,$FFFF9800
NO_ALT
	BSR	VBL
	CMPI.W	#1500,COMPT
	BHI.S	FIN_PART1
	CMPI.B	#57,$FFFFC02
	BNE	LOOP
FIN_PART1
	BSR	CLS
	RTS
**********************************************************************************************
*******************PART3:DOTSBALL ************************************************************************
**********************************************************************************************
PART3
	MOVE.L	#SCREEN,D0	
	ADD.L	#10000,D0
	ANDI.L	#$FFFFFF00,D0
	MOVE.L	D0,SCREEN_ADD

	move.b	#%000,$ff82c2
	move	#50,$FFFF82A8.w		;OVER HAUT
	move	#611,$FFFF82AA.w		;BAS
	bsr	vbl

 	move.l 	$44e.w,d0
	MOVE.L	d0,A1
	add.l	#74240*4,d0
	MOVE.L	d0,A2
	MOVE.L	A1,AFFECR
	MOVE.L	A2,WORKECR
	MOVE.L	#TIMER,$4D2
	BSR	FADE_TO_BLEU
	BSR	INIT_RAST 
LOOP2
	BSR	VBL
	CMPI.B	#57,$FFFFC02
	BNE.S	LOOP2
	RTS
**********************************************************************************************
******************************SOUS ROUTINES*****************************************
**********************************************************************************************
FADE_TO_BLEU
	MOVEQ.L	#0,D2
	MOVEQ.L	#0,D3
	MOVEQ.L	#0,D4
	MOVE.W	#$80,D6
BLEU
	CMPI.L	#$00500000,D2
	BEQ.S	NOINC
	ADD.L	#$00010000,D2
NOINC
	CMPI.L	#$00000070,D3
	BEQ.S	NOINC2
	ADD.L	#$00000001,D3
NOINC2
	MOVEQ.L	#0,D4
	OR.L	D2,D4
	OR.L	D3,D4
	MOVE.L	D4,$FFFF9800
	BSR	VBL
	DBF	D6,BLEU
	RTS
TIMER
	MOVE.L	#$00500070,$FFFF9800
*	MOVEM.L	D0-D7/A0-A7,-(SP)	
	BSR	DSP_PLAY+12
*	MOVEM.L	(SP)+,D0-D7/A0-A7
	CMPI.B	#200,STAB
	BEQ.S	NOSTAB
	SUB.B	#1,STAB
NOSTAB
	MOVE.L	#TIMER_B1,$120.W
	MOVE.B	STAB,$FFFFFA21.W
	MOVE.B	#8,$FFFFA1B
	RTS
TIMER_B1	
	MOVE.W	#$2700,SR
	MOVE.L	#$00400050,$FFFF9800
	CLR.B	$FFFFA21	
	CLR.B	$FFFFA1B
	BCLR	#0,$FFFFFA0F.W	
	MOVE.W	#$2300,SR	
	RTE

VBL:
	MOVE.L	D0,-(SP)
	move.l	$466.w,d0		
VSYNC2:	cmp.l	$466.w,d0
	BEQ.S	VSYNC2
	MOVE.L	(SP)+,D0
	RTS
CLS
	MOVEM.L	D0/A0-a1,-(SP)
	MOVE.L	AFFECR,A0
	MOVE.L	WORKECR,A1
	MOVEQ.L	#0,D1
	MOVE.W	#18269,D0
OK
	MOVE.L	D1,(A0)+
	MOVE.L	D1,(A1)+
	DBF	D0,OK
	MOVEM.L	(SP)+,D0/A0-a1
	RTS
CLR_REGISTERS
	movem.l	clr,d0-d6/a0-a6
	rts
EFFA2
	MOVE.L	WORKECR,A0		
	MOVE.W	#points,D1
	MOVEQ.W	#0,D2
	MOVEQ.W	#0,D5
	MOVE.L	SAVE1,A1
	MOVE.W	#9,D0
	MOVEC	D0,CACR
	MOVE.L	#$3111,D0		;coupe cache
	MOVEC.L	D0,CACR
EFF2
	MOVE.W	(A1)+,D5
	MOVE.W	D2,(A0,D5.L)
	DBF	D1,EFF2
	MOVE.L	#$2510,D0		;coupe cache
	MOVEC.L	D0,CACR
	RTS
****************************ROUTINE DE CALCUL************************************
********************************************************
*precalculs trigonometriques			*
*en entree:x_angle,y_angle,z_angle(angle de rotation)  *	
*en sortie:A,B,C,D,E,F,G,H,I*512		       	*				
********************************************************


TRIGO
	MOVEM.L	D0-D7/A4-A6,-(SP)
	LEA	COS_TAB,A4
	LEA	SIN_TAB,A5
	LEA	X_ANGLE,A6
	MOVE.W	(A6)+,D2	;d2=x angle
	MOVE.W	(A6)+,D1	;d1=y ...
	MOVE.W	(A6)+,D0	;d0=z ...

	MOVE.W	(A5,D2.W),D5	;d5=sinx
	MOVE.W	(A4,D2.W),D4	;d4=cosx
	MOVE.W	(A5,D1.W),D3	;d3=siny
	MOVE.W	(A4,D1.W),D2	;d2=cosy
	MOVE.W	(A5,D0.W),D1	;d1=sinz
	MOVE.W	(A4,D0.W),D0	;d0=cosz

	LEA	VAR_3D,A6	;zone sauvegarde calc intermediaire
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
	RTS
*********************
MAKE_DOTS
*	ADD.W	#2,X_ANGLE
*	CMPI.W	#720,X_ANGLE
*	BLT.S	NO_STOP
*	CLR.W	X_ANGLE
*NO_STOP
	ADD.W	#2,Y_ANGLE
	CMPI.W	#720,Y_ANGLE
	BLT.S	NO_STOP2
	CLR.W	Y_ANGLE
NO_STOP2
	ADD.W	#2,Z_ANGLE
	CMPI.W	#720,Z_ANGLE
	BLT.S	NO_STOP3
	CLR.W	Z_ANGLE
NO_STOP3
	LEA	Y_TABLE,A5
	LEA	TAB,A4
	MOVE.L	WORKECR,A0
	BSR	TRIGO
	MOVE.W	#points,D7
	LEA	COORD,A2
	MOVE.L	#$3111,D0		;active cache
	MOVEC.L	D0,CACR
AFF_BALL
	MOVE.L	(A2)+,XE
	MOVE.W	(A2),ZE
	ADDQ.W	#2,(A2)+
	CMPI.W	#50,-2(A2)
	BLE.S	OKOK
	MOVE.W	#-50,-2(A2)
OKOK
**COORD SPAT TO PLAN******
	LEA	XE,A6
	MOVE.W	(A6)+,D0
	MOVE.W	(A6)+,D1
	MOVE.W	(A6),D2
	MOVE.W	ZDEP,D5
	MOVEQ.B	#9,D6
	ASL.L	D6,D5		;zdep*512
	MOVE.L	D5,A3
	LEA	VAR_3D,A6
	MOVE.W	D0,D3
	MOVE.W	D1,D4
	MOVE.W	D2,D5
	MULS	(A6)+,D3		;d3=c*xe*512
	MULS	(A6)+,D4		;d4=f*ye*512
	MULS	(A6)+,D5		;d5=i*ze*512
	ADD.L	D4,D5		;+f*ye*512
	ADD.L	D3,D5		;+c*xe*512
	ADD.L	A3,D5		;+zdep*512
	LSR.L	#8,D5
	MOVE.W	D5,NEW_ZE

	MOVE.W	#512,D6
	SUB.W	D5,D6		;d7=512*q				;d7=512*(1-new_ze/z_pt_fuite)
	MOVE.W	D0,D3		;d3=xe
	MOVE.W	D1,D4		;d4=ye
	MOVE.W	D2,D5		;d5=ze
	MULS	(A6)+,D3		;d3=a*xe*512
	MULS	(A6)+,D4		;d4=d*ye*512
	MULS	(A6)+,D5		;d5=g*ze*512
	ADD.L	D4,D5		
	ADD.L	D3,D5
	DIVS	D6,D5		;d5=new_xe/q
	MULS	(A6)+,D0		;d0=b*xe*512
	MULS	(A6)+,D1		;d1=e*ye*512
	MULS	(A6)+,D2		;d2=h*ze*512
	ADD.L	D0,D1		
	ADD.L	D1,D2
	DIVS	D6,D2		;d2=new_ye/q
*************
	ADD.W	XADD,D5
	BMI.S	NO_DOTS
	ADD.W	#120,D2
	BMI.S	NO_DOTS
	CMPI.W	#300,NEW_ZE
	BGT.S	PLAN2
	MOVEQ	#0,D3
	MOVE.W	(A5,D2.W*2),D3 		; coord y
	MOVE.L	(A4,D5.W*4),D6		; coord x
	ADD.W	D6,D3
	SWAP	D6
	OR.W	D6,(A0,D3.L)	
	MOVE.W	D3,(A1)+
	DBF	D7,AFF_BALL
	MOVE.L	#$2510,D0		;coupe cache
	MOVEC.L	D0,CACR
	RTS
PLAN2
	MOVEQ	#2,D3
	ADD.W	(A5,D2.W*2),D3 		; coord y
	MOVE.L	(A4,D5.W*4),D6		; coord x
	ADD.W	D6,D3
	SWAP	D6
	OR.W	D6,(A0,D3.L)	
	MOVE.W	D3,(A1)+
NO_DOTS
	DBF	D7,AFF_BALL
	MOVE.L	#$2510,D0		;coupe cache
	MOVEC.L	D0,CACR
	RTS
**********************************************************************************************
***************************INITIALISATIONS***************************************************
**********************************************************************************************
INIT_RAST:
	move.l	$120.W,SAVE_HBL
	move.b	$ffffa1b,SAVE_A1B
	move.b	$ffffa09,SAVE_A09
	move.b	$ffffa21,SAVE_A21
	move.b	$ffffa07,SAVE_A07
	move.b	$ffffa13,SAVE_A13
	
	and.b	#$40,$fffa09
	or.b	#1,$fffa07
	or.b	#1,$fffa13	
	RTS
INIT_MOD
	lea	mod,a0		;Adresse du module NTK4
	lea	freq_buf,a1	;Buffer pour les fr‚quences
	jsr	dsp_play		;Pof, la routine s'initialise
	move.l	dsp_play+8,a0	;Adresse des variables internes
	clr.b	song_stop(a0)	;->D‚bloque
	st.b	dma2dsp(a0)	;->Transfert par le port Host
	lea	MFP_base.w,a6	;
	move.b	VR(a6),save_vr	;MFP en mode AEI
	bclr	#3,VR(a6)		;
	move.l	V_TB.w,save_vtb	;
	move.l	#dsp_play+12,$4d2
	RTS
INITS
	MOVEC	CACR,D0			
	MOVE.L	D0,OLD_CACR
	MOVE.L	#$2510,D0		;coupe cache
	MOVEC.L	D0,CACR

	MOVE.W	#2,-(SP)
	TRAP	#14
	ADDQ.L	#2,SP
	MOVE.L	D0,OLDXBIOS2
	
	MOVE.W	#-1,-(SP)		
	MOVE.W	#88,-(SP)		
	TRAP	#14			
	ADDQ.L	#4,SP			
	MOVE.W	D0,OLDMODECODE	

	MOVE.L	#SCREEN,D0	
	ADD.L	#10000,D0
	ANDI.L	#$FFFFFF00,D0
	MOVE.L	D0,SCREEN_ADD

;		  XXXXXXXFSOPV8NNN : flags pour rezs
 	MOVE.W	#%0000000001100010,-(SP)	
	MOVE.W	#3,-(SP)
	MOVE.L	SCREEN_ADD,-(SP)
	MOVE.L	SCREEN_ADD,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	14(SP),SP

	move	#50,$FFFF82A8.w		;OVER HAUT
	move	#611,$FFFF82AA.w		;BAS

 	move.l $44e.w,d0
	MOVE.L	d0,A1
	add.l	#74240,d0
	MOVE.L	d0,A2
	MOVE.L	A1,AFFECR
	MOVE.L	A2,WORKECR
	RTS

**********************************************************************************************
***************************SORTIE************************************************
**********************************************************************************************
END	
	clr.l	$4d2
	MOVE.B	SAVE_A09,$FFFFA09
	MOVE.B	SAVE_A07,$FFFFA07	
	MOVE.L	SAVE_HBL,$120.W
	MOVE.B	SAVE_A1B,$FFFFA1B	
	MOVE.B	SAVE_A21,$FFFFA21	
	MOVE.B	SAVE_A13,$FFFFA13	
	MOVE.B	#15,$484.W
	MOVE.B	#8,$FFFFC02
	MOVE.W	OLDMODECODE,-(SP)
	MOVE.W	#3,-(SP)	
	MOVE.L	OLDXBIOS2,-(SP)
	MOVE.L	OLDXBIOS2,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	14(SP),SP		
	move.w	#$fff,$ffff8240
	bsr	vbl
	clr.b	TBCR(a6)		;D‚branche tout, et cassos
	bclr	#0,IERA(a6)	;
 	bclr	#0,IMRA(a6)	;
	move.l	save_vtb,V_TB.w	;
	move.b	save_vr,VR(a6)	;
fini	clr.b	$ffff8901.w	;
	clr.l	-(sp)		;Coupe la sortie son du DSP,
	Xbios	Snd_DspTriState	;pour pas merder.
	trap	#1		;Cassos
	moveq	#6,d7		;R‚glages sonores: 
	moveq	#3,d6		;(6,3);(5,3);(4,3);(1,$x0);(0,$x0)
.soundsys	cmp.w	d6,d7		;couple (3,3) ?
	bne.s	.soundset		;
	moveq	#1,d7		;Oui->passe au couple (1,$x0)
	move.w	#$e0,d6		;La valeur est modifi‚e en court
.soundset	move.w	d6,-(sp)		;de route..
	move.w	d7,-(sp)		;Un couple...
	Xbios	Snd_Cmd		;
	dbf	d7,.soundsys	;Suivant
.pcm_frq	move.w	#1,-(sp)		;Voil…, on a remis le son
	clr.l	-(sp)		;dans un ‚tat correct.
	pea	8.w		;
	Xbios	Snd_DevConnect	;
	clr.w	(sp)		;Et on se casse !!.
	trap	#1		;

**************************

	SECTION	DATA
COMPT		DC.W	0
SCREEN_ADD		DC.L	0
AFFECR:		DC.L 	0
WORKECR:		DC.L 	0
OLDXBIOS2:		DC.L	0
OLDMODECODE	DC.W	0
save_vr		dc.b	0
save_vtb		dc.l	0
XADD		DC.W	470
SAVE1		DC.L	0
SAVE2		DC.L	0
CURVE_COMPT	DC.W	0
COORD		INCBIN	"C:\UTILS\CODE_UTI.LS\GFABASIC\CUBE.INL"
COS_TAB		INCBIN	"C:\UTILS\CODE_UTI.LS\GFABASIC\COSIN.DAT"
SIN_TAB		EQU	COS_TAB+720	
**************************
Y_TABLE
OXO	SET	0
	REPT	280
	DC.W	OXO
OXO	SET	OXO+192
	ENDR
	DCB.L	100*2
TAB	
OXO	SET	0	
	REPT	24
	DC	32768,OXO,16384,OXO,8192,OXO,4096,OXO
	DC	2048,OXO,1024,OXO,512,OXO,256,OXO
	DC	128,OXO,64,OXO,32,OXO,16,OXO
	DC	8,OXO,4,OXO,2,OXO,1,OXO
OXO	SET	OXO+8
	ENDR
	DCB.L	16*24*4	
*****************
XE		DC.W	0
YE		DC.W	0
ZE		DC.W	0
ZDEP		DC.W	0
X_ANGLE		DC.W	2
Y_ANGLE		DC.W	2
Z_ANGLE		DC.W	2
Z_PT_FUITE		DC.W	256
OLD_CACR		DC.L	0
SAVE_HBL:		DC.L	0
SAVE_A1B:		DC.B	0
SAVE_A21:		DC.B	0
SAVE_A07:		DC.B	0
SAVE_A09:		DC.B	0
SAVE_A13:		DC.B	0
STAB		DC.B	255 
	even

yoman		incbin	f:divers.dsp\sndtrack.dsp\dsp_play.bin	;Routine de mixage!
dsp_play		equ	yoman+$1c
	even
mod		incbin	f:\mods\shadow.ntk	;Mettez votre module NTK ici
	SECTION	BSS
XP		DS.W	1
YP		DS.W	1
NEW_XE		DS.W	1
NEW_YE		DS.W	1
NEW_ZE		DS.W	1
VAR_3D		DS.W	9
SAVE_POINT		DS.W	8000
SAVE_POINT2	DS.W	8000
freq_buf		ds.l	907-108+1		;Buffer indispensable
SCREEN		DS.W	500000
		DS.L	2000
PILE		DS.L	10
CLR		DS.L	17
	END
																																		  																																																																																																												 	  																																		  																																																														