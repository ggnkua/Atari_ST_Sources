********INIT DIVERS***********************************************
INIT_FACE
	bsr	CLR_REGISTERS
	lea	DY,a0		;zone de coord des pts
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
;initialisation des tableaux des xmin et xmax
	lea	XMAX,a0
	lea	XMIN,a1
	MOVE.L	#$3111,D6		;cache on	
	MOVEC.L	D6,CACR
INIT_X	
	move.w	#-1,(a0)+
	move.w	#$FFF,(a1)+
	dbf	d0,INIT_X
	MOVE.L	#$2510,D6		;cache off	
	MOVEC.L	D6,CACR		
	rts
********REMPLI TABLEAUX******************************************
TRACE_FACE
;trace virtuellement les lignes et stock ds xmin et xmax
	INCLUDE	"C:\UTILS\CODE_UTI.LS\GEN_ASM\FULLFACE\FULLFAC2.S"
********ROUTINE DE REMPLISSAGE*********************************** 
REMPLI
	lea	XMAX,a0
	lea	XMIN,a1
	move.l	WORKECR,a2
	move.w	YMIN,d0
	muls	#640,d0		;y de depart
	add.l	d0,a2
	move.w	HAUTEUR,d1
	sub.w	#1,d1
	MOVE.L	#$3111,D6		;cache on		
	MOVEC.L	D6,CACR
AFF_FACE
	move.w	#320,d4
	move.w	(a0)+,d2		;xmax
	move.w	(a1)+,d3		;xmin
	sub.w	d3,d2
	sub.w	d2,d4
	
	jmp	PREC(pc,d4.w*8)
PREC
CRIS	set	638
	rept	320
	move.w	d5,(CRIS,a2,d3.w*2)
CRIS	set	CRIS-2
	endr
	lea	640(a2),a2		;ligne suivante
	dbf	d1,AFF_FACE
	MOVE.L	#$2510,D6		;cache off	
	MOVEC.L	D6,CACR		
	rts
