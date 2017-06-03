	* Fantastic Stars, trouv‚ dans Gen‚ration 4 de juin '89

H=$10000

MOD=0
ARG=4
VMOD=8
AMOD=12
VARG=16
ADR=20
IMG=24
VMODD=28
	
N_DATA=32
N_ETOILES=200

	BSR	SUPER_ON

	MOVE.W	#4,-(SP)	sauve resolution
	TRAP	#14					* Demande de r‚solution
	MOVE.W	D0,SAVE_REZ  	
	MOVE.W	$FFFF8240,SAVE_COLOR_0 Sauvegarde palette
	MOVE.W	$FFFF8242,SAVE_COLOR_1
*	MOVE.L	$70,SAVE_VBL	 Sauvegarde vecteur VBL
*	MOVE.L	$FFFFFA06,SAVE_MFP	 Idem registre MFP

	CLR.W	-(SP)	force basse r‚solution
	MOVE.L	#-1,-(SP)
	MOVE.L	#-1,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14

	MOVE.W	#37,-(SP)	Attente de VBL
	TRAP	#14
	ADD.L	#16,SP

	CLR.W	$FFFF8240	Fond noir
	MOVE.W	#$777,$FFFF8242	Etoiles blanches 
*	CLR.B	$FFFFFA07		Vire toutes les Inter. du MFP
*	MOVE.B	#%10000000,$FFFFFA09	sauf le clavier
*	MOVE.L	#VBL,$70		Nouveau vecteur VBL

TOUCHE	bsr	vbl
	cmpi.b	#$39,$fffc02
	BEQ.S	FIN
	BRA.S	TOUCHE

*	MOVE.W	#7,-(SP)
*	TRAP	#1
*	ADDQ.L	#2,SP

	* Restitution de tous les registres

FIN	MOVE.W	SAVE_COLOR_0,$FFFF8240
	MOVE.W	SAVE_COLOR_1,$FFFF8242
*	MOVE.L	SAVE_VBL,$70
*	MOVE.L	SAVE_MFP,$FFFFFA06
	MOVE.W	SAVE_REZ,-(SP)
	MOVE.L	#-1,-(SP)
	MOVE.L	#-1,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	ADD.L	#12,SP

	BSR	SUPER_OFF

	MOVE.W	#0,-(SP)
	TRAP	#1
*-----------------------------------------------------*
SUPER_ON	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	MOVEA.L	#ANC_PILE,A0
	MOVE.L	D0,A0
	RTS
*-----------------------------------------------------*
SUPER_OFF	MOVE.L	#ANC_PILE,-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	RTS
*-----------------------------------------------------*

ETOILES
	LEA	SIN(PC),A6	Table de sinus
	LEA	COS(PC),A5	Table de cosinus
	MOVE.L	$44E,A4	Adresse de la memoire video
	LEA	DATA_ETOILES(PC),A0
	MOVE.W	#N_ETOILES-1,D7	Table des donn‚es


BOUCLE_ETOILES
	MOVE.W	ADR(A0),D1	Adresse pr‚c‚dente
	MOVE.W	IMG(A0),D0	Image pr‚c‚dente
	NOT.W	D0	On inverse et on fait...
	AND.W	D0,(A4,D1.W)	un 'AND' pour effacer

	MOVE.L	ARG(A0),D0
	ADD.L	VARG(A0),D0
	MOVE.L	D0,ARG(A0)
	SWAP	D0
	AND.W	#$7FE,D0

	MOVE.L	MOD(A0),D1
	MOVE.L	VMOD(A0),D5
	ADD.L	AMOD(A0),D5
	MOVE.L	D5,VMOD(A0)
	ADD.L	D5,D1
	MOVE.L	D1,AMOD(A0)
	SWAP	D1

	MOVE.W	0(A6,D0.W),D2
	MOVE.W	0(A5,D0.W),D3
	MULS	D1,D2
	MULS	D1,D3
	ROL.L	#1,D2
	SWAP	D2
	ROL.L	#1,D3
	SWAP	D3

	ADD.W	#100,D2	car il n'y a que 200 lignes
	BMI	PAS_AFFICHE
	CMP.W	#199,D2
	BPL	PAS_AFFICHE
	
	ADD.W	#160,D3
	BMI	PAS_AFFICHE
	CMP.W	#319,D3
	BPL	PAS_AFFICHE

	MOVE.W	D3,D4
	MULU	#160,D2	160 octets/ligne
	LSR.W	#1,D3
	AND.W	#$FFF8,D3
	ADD.W	D3,D2

	AND.W	#15,D4
	ADD.W	D4,D4
	MOVE.W	TABLE_IMAGES(PC,D4.W),D4
	OR.W	D4,(A4,D2.W)
	MOVE.W	D4,IMG(A0)
	MOVE.W	D2,ADR(A0)
	ADD.L	#N_DATA,A0
	DBRA	D7,BOUCLE_ETOILES

	RTS

PAS_AFFICHE
	MOVE.L	VMODD(A0),VMOD(A0)
	CLR.L	MOD(A0)
	ADD.L	#N_DATA,A0
	DBRA	D7,BOUCLE_ETOILES
	RTS

TABLE_IMAGES
	DC.W	32768,16384,8192,4096,2048,1024,512,256
	DC.W	128,64,32,16,8,4,2,1

VBL	MOVEM.L	D0-D7/A0-A6,-(SP)
	BSR	ETOILES
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

DATA_ETOILES
	INCBIN	"ETOILE.DAT"
	EVEN
SIN	INCBIN	"SINUS.DAT"
	EVEN

SAVE_REZ	DS.W	1
SAVE_VBL	DS.L	1
SAVE_MFP	DS.L	1
SAVE_COLOR_0	DS.W	1
SAVE_COLOR_1	DS.W	1
ANC_PILE	DS.L	1

COS	EQU	SIN+512
