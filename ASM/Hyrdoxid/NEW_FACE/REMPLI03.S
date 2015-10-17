********INIT DIVERS***********************************************
INIT_FACE
	movem.l	clr,d0/d2-d7/a0-a6
	lea	PTS,a0		;zone de coord des pts
	move.w	#nbpts-1,d7
	move.w	#-1,d0		;d0=ymax
	move.w	#$FFF,d1		;d1=ymin
	MOVE.L	#$3111,D6		;cache on	
	MOVEC.L	D6,CACR
;recherche des ymax et ymin et calcul de la hauteur du polygone
TRI_Y
	move.w	(a0,d2.w),d3	
	addq.w	#2,d2
	cmp.w	d3,d1
	ble.s	NO_YMIN
	move.w	d3,d1		;D1=new ymin
NO_YMIN
	cmp.w	d3,d0
	bgt.s	NO_YMAX
	move.w	d3,d0		;D0=new ymax
NO_YMAX
	DBF	d7,TRI_Y
	MOVE.L	#$2510,D6		;cache off	
	MOVEC.L	D6,CACR		
	move.w	d0,YMAX
	move.w	d1,YMIN	
	sub.w	d1,d0		;D0=hauteur	
	move.w	d0,HAUTEUR
	lsr	d0
	addq	#1,d0
;initialisation des tableaux des xmin et xmax
	lea	XMAX1,a0
	lea	XMIN1,a1
	MOVE.L	#$3111,D6		;cache on	
	MOVEC.L	D6,CACR
	moveq	#-1,d1
	move.l	#$FFF0FFF,d2
INIT_X	
	move.l	d1,(a0)+
	move.l	d2,(a1)+
	dbf	d0,INIT_X
	MOVE.L	#$2510,D6		;cache off	
	MOVEC.L	D6,CACR		
	rts
********REMPLI TABLEAUX******************************************
TRACE_FACE
;trace virtuellement les lignes et stock ds xmin et xmax
	INCLUDE	"C:\UTILS\CODE_UTI.LS\GEN_ASM\FULLFACE\NEW_FACE\NEWLINE.S"
********ROUTINE DE REMPLISSAGE*********************************** 
REMPLI
	lea	Y_TABLE,a4
	move.l	WORKECR,a2
	add	d4,a2
	lea	XMAX1,a3
	lea	XMIN1,a1
	move.w	YMIN,d0
	add.l	(a4,d0.w*4),a2	;pos y de depart du polygone
	move.l	a2,d3
	move.w	HAUTEUR,d1
	tst	d1
	bne.s	REMPLI_OK
	rts
REMPLI_OK
	lea	RETOUR,a2
	lea	ADR_TAB,a5
	lea	PIX_TAB,a6
	MOVE.L	#$3111,D6		;cache on		
	MOVEC.L	D6,CACR
*********************
AFF_FACE
	move.l	d3,a0		;restitue adresse ecran
	move.w	(a3)+,d7		;xmax
	move.w	(a1)+,d6		;xmin
****
	move	d6,d4
	sub.w	d6,d7

	andi.w	#$fff0,d6	
	andi.w	#$f,d4		;valeur du bloc de depart
	add.w	(a6,d4.w*2),d7	;fixe pixel de depart
	add.w	d6,a0
	move.l	(a5,d7.w*4),a4
	jmp	(a4.l)
RETOUR
	add.l	#384,d3		;new ligne
	dbf	d1,AFF_FACE
	MOVE.L	#$2510,D6		;cache off	
	MOVEC.L	D6,CACR		
	rts
																																																																																																																																				