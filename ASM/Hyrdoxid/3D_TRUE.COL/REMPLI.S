********INIT DIVERS***********************************************
INIT_FACE
	bsr	CLR_REGISTERS
	lea	DY,a0		;zone de coord des pts
	add.w	d1,a0		;offset de depart
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
	lea	TAB_ADR,a0
;init_TAB_ADR
	move.l	#POINT1,(a0)+
	move.l	#POINT2,(a0)+
	move.l	#POINT3,(a0)+
	move.l	#POINT4,(a0)+
	move.l	#POINT5,(a0)+
	move.l	#POINT6,(a0)+
	move.l	#POINT7,(a0)+
	move.l	#POINT8,(a0)+
	move.l	#POINT9,(a0)+
	move.l	#POINT10,(a0)+
	move.l	#POINT11,(a0)+
	move.l	#POINT12,(a0)+
	move.l	#POINT13,(a0)+
	move.l	#POINT14,(a0)+
	move.l	#POINT15,(a0)+
	move.l	#POINT16,(a0)+
;***
	lea	XMAX,a0
	lea	XMIN,a1
	move.l	WORKECR,a2
	lea	TAB_ADR,a3
	move.w	YMIN,d0	
	muls	#640,d0		;y de depart
	add.l	d0,a2
	move.w	HAUTEUR,d0		;nb de lignes
	sub.w	#1,d0	
	lea	-640(a2),a2
	moveq	#0,d2
	movem.l	CLR2,d3-d7/a5-a6
LOOP_LIGNE
	sub	d2,a2
	lea	640(a2),a2
	move.w	(a0)+,d1
	move.w	(a1)+,d2
	sub.w	d2,d1		;longueur de ligne
	asl	d2
	add.w	d2,a2
*	moveq	#15,d1
	move.l	(a3,d1.w*4),a4	
	jmp	(a4)
************************
POINT1
	move.w	d3,(a2)
	dbf	d0,LOOP_LIGNE
	rts
POINT2
	move.l	d3,(a2)
	dbf	d0,LOOP_LIGNE
	rts
POINT3
	move.l	d3,(a2)
	move.w	d3,4(a2)
	dbf	d0,LOOP_LIGNE	
	rts
POINT4
	move.l	d3,(a2)
	move.l	d3,4(a2)
	dbf	d0,LOOP_LIGNE
	rts
POINT5
	move.l	d3,(a2)
	move.l	d3,4(a2)
	move.w	d3,8(a2)
	dbf	d0,LOOP_LIGNE
	rts
POINT6
	move.l	d3,(a2)
	move.l	d3,4(a2)
	move.l	d3,8(a2)
	dbf	d0,LOOP_LIGNE
	rts
POINT7
	move.l	d3,(a2)
	move.l	d3,4(a2)
	move.l	d3,8(a2)
	move.w	d3,12(a2)
	dbf	d0,LOOP_LIGNE
	rts
POINT8
	move.l	d3,(a2)
	move.l	d3,4(a2)
	move.l	d3,8(a2)
	move.l	d3,12(a2)
	dbf	d0,LOOP_LIGNE
	rts
POINT9
	move.l	d3,(a2)
	move.l	d3,4(a2)
	move.l	d3,8(a2)
	move.l	d3,12(a2)
	move.w	d3,16(a2)
	dbf	d0,LOOP_LIGNE
	rts
POINT10
	move.l	d3,(a2)
	move.l	d3,4(a2)
	move.l	d3,8(a2)
	move.l	d3,12(a2)
	move.l	d3,16(a2)
	dbf	d0,LOOP_LIGNE
	rts
POINT11
	move.l	d3,(a2)
	move.l	d3,4(a2)
	move.l	d3,8(a2)
	move.l	d3,12(a2)
	move.l	d3,16(a2)
	move.w	d3,20(a2)
	dbf	d0,LOOP_LIGNE
	rts
POINT12
	move.l	d3,(a2)
	move.l	d3,4(a2)
	move.l	d3,8(a2)
	move.l	d3,12(a2)
	move.l	d3,16(a2)
	move.l	d3,20(a2)
	dbf	d0,LOOP_LIGNE
	rts
POINT13
	move.l	d3,(a2)
	move.l	d3,4(a2)
	move.l	d3,8(a2)
	move.l	d3,12(a2)
	move.l	d3,16(a2)
	move.l	d3,20(a2)
	move.w	d3,24(a2)
	dbf	d0,LOOP_LIGNE
	rts
POINT14
	lea	4*7(a2),a2
	movem.l	d3-d7/a5-a6,-(a2)
	dbf	d0,LOOP_LIGNE
	rts
POINT15
	lea	4*7+2(a2),a2
	movem.l	d3-d7/a5-a6,-(a2)
	move.w	d3,-(a2)
	dbf	d0,LOOP_LIGNE
	rts
POINT16
	lea	4*8(a2),a2
	movem.l	d3-d7/a5-a6,-(a2)
	move.l	d3,-(a2)
	dbf	d0,LOOP_LIGNE
	rts
	
