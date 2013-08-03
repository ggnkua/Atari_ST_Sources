*****************************************************************************
*                                                                           *
* Voici la source de la routine de points(STF/E-FALCON) en basse resolution *
*       Attention code pour 68000, n' est pas optimise pour 68030.          *
*                                                                           *
*                                        Code et article par -> LITHIUM     *
*                                                                           *
*****************************************************************************



*****************************************************************************
****************************** debut du programme ***************************
*****************************************************************************

	Section Text


	BRA      Init

RUN:

*****************************************************************************
**************** Calcul de la table des multiple de 160 *********************
*****************************************************************************

	lea	tableau,a0
	clr	d0
	move	#199,d1
turlututu
	move	d0,(a0)+
	add	#160,d0
	dbra	d1,turlututu

*****************************************************************************
******************************* Efface l'ecran ******************************
*****************************************************************************

	move.l	$44e.w,a0
	move.w	#7999,d0

cpy:	clr.l	(a0)+
	dbra	d0,cpy



*****************************************************************************
************************** Routine placee en syncro VBL *********************
*****************************************************************************

	move.l	#VSYNC,$70      * Met vsync en VBL

vbl:
	cmp.b	#1,flag         * Test si la vbl est finie, voir VSYNC
	bne.s	vbl		* mieu que le vsync avec un trap #14 
	move.b	#0,flag
	
	move	#$700,$ff8240	* Rouge en debut de vbl

	move.l	#500,d7	        * 500 fois 1 point
blop	
	move.w	#319,d0		* X		
	move.w	#199,d2		* Y
	bsr	plot
	dbra	d7,blop

	move	#$777,$ffff8240 * blanc en fin de vbl , ainsi on sait combien
                                * prend la routine sur l'ecran,c'est toute la
                                * la bande rouge ... 
	
	cmp.b	#$39,$fffffc02  * Test de la touche espace
	bne.s	vbl             * Part si elle est appuyee

	rts			* Retour aux initialisations


******************************************************************************
************** Routine de PLOT(X,Y) Avec d0 pour X et d2 pour Y **************
******************* Pour les explications voir l'article *********************
******************************************************************************


plot:
	
	lea	tableau,a0	* A retirer du BSR pour optimisation

	movea.l $44e,a1         * Adresse ecran dans a1
		
	add.w	d2,d2		* multiplie par 2 le registre d2		
	
	add.w	(a0,d2),a1
	lea	6(a1),a1		* 4eme plan
	
	move.w	d0,d1
	lsr	d1
	and	#248,d1
	add.w	d1,a1
	and	#15,d0

	move.b	#15,d2
	sub.b	d0,d2

	lsr	#3,d0
	beq.s	SoGood
	lea	1(a1),a1
SoGood:	
	bset	d2,(a1)
	rts

******************************************************************************	
******************************************************************************	
******************************************************************************	
	
* Routine VBL

VSYNC:
	move.b	#1,flag
	rte


* Data pour la routine de points

pointx	dc.l	0
flag	dc.b	0
	even

* Bss pour la table de mul

tableau	
	ds.w	200


******************************************************************************	
**************************** INITIALISATIONS *********************************
******************************************************************************	

Init:
                  CLR.W   -(A7) 
                  MOVE.W  #$20,-(A7)
                  TRAP    #1
                  ADDQ.L  #6,A7 

	          MOVE.L  D0,SAVE_SSP 
                  MOVE    #$2700,SR 
                  DC.B   $A0,$0A
                  MOVE.B  #0,$00000484.L
                  MOVE.B  -$7DF6,SAVE20A
                  MOVE.B  -$7DA0,SAVE260
                  MOVE.B  -$7DFF,SAVE201
                  MOVE.B  -$7DFD,SAVE203
                  MOVEM.L -$7DC0,D0-D7
                  MOVE.L  $00000436.L,EC1 
                  MOVE.W  #4,-(A7)
                  TRAP    #$E 
                  ADDA.L  #2,A7 
                  MOVE.W  D0,SAVE_REZ 
                  MOVE.W  #0,-(A7)
                  MOVE.L  #-1,-(A7) 
                  MOVE.L  #-1,-(A7) 
                  MOVE.W  #5,-(A7)
                  TRAP    #$E 
                  ADDA.L  #$C,A7
                  MOVE.B  -$5ED,SAVEA13 
                  MOVE.B  -$5EB,SAVEA15 
                  MOVE.L  $70,SAVE70
                  MOVE.L  $118,SAVE118
                  MOVE.L  $134,SAVE134
                  MOVE    #$2300,SR 
                  JSR     RUN
                  DC.B   'F',$FC,$27,$00,'!',$F9
                  DC.L    SAVE118 
                  DC.B   $01,$18,'!',$F9
                  DC.L    SAVE134 
                  DC.B   $01,'4',$11,$FC,$00,$08,$FC,$02
                  DC.B   '!',$F9
                  DC.L    SAVE70
                  DC.B   $00,'p?9'
                  DC.L    SAVE_REZ
                  DC.B   '/<',$FF,$FF,$FF,$FF,'/<'
                  DC.B   $FF,$FF,$FF,$FF,'?<',$00,$05 
                  DC.B   'NN',$DF,$FC,$00,$00,$00,$0C 
                  DC.B   $11,$F9
                  DC.L    SAVE201 
                  DC.B   $82,$01,$11,$F9
                  DC.L    SAVE203 
                  DC.B   $82,$03,$11,$F9
                  DC.L    SAVEA13 
                  DC.B   $FA,$13,$11,$F9
                  DC.L    SAVEA15 
                  DC.B   $FA,$15,$13,$FC,$00,$03,$00,$00
                  DC.B   $04,$84,'F',$FC,'#',$00,$11,$FC
                  DC.B   $00,$08,$88,$00,$11,$FC,$00,$00
                  DC.B   $88,$02,$11,$FC,$00,$09,$88,$00
                  DC.B   $11,$FC,$00,$00,$88,$02,$11,$FC
                  DC.B   $00,$0A,$88,$00,$11,$FC,$00,$00
                  DC.B   $88,$02,'/9' 
                  DC.L    SAVE_SSP
                  DC.B   '?<',$00,' NA\',$8F
                  *DC.B   '.y' 
                  *DC.L    SAVEA7
                  DC.B   'B',$A7,'NA' 
EC1:              DS.W    2 
SAVEA7:           DS.W    2 
SAVE70:           DS.W    2 
SAVE_SSP:         DS.W    2 
SAVE118:          DS.W    2 
SAVE134:          DS.W    2 
SAVE_REZ:         DC.B   $00,$00
SAVE260:          DC.B   $00,$00
SAVE201:          DC.B   $00
SAVE203:          DC.B   $00
SAVEA15:          DC.B   $00
SAVEA13:          DC.B   $00
SAVE20A:          DC.B   $00,$00
