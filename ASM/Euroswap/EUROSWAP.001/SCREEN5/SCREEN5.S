
 		;opt D+,o+
************************************************
*	screen5.prg coded by gfa from nothing  *
*	-helped by jedi of sector one          *
*	-helped by st mag,and by the vegetables*
*	-helped by st-connextion(for the hbl)  *
*	-helped by the fox for the low overscan*
*					       *
*			le 13/09/9	       *
*	last fix on 22/10/92		       *
*	last last fix on 04/11/92	       *
************************************************
*be carreful: the music must have more than one song******

*************************************************************
magic_number  EQU $4545
***************

SCRSIZ	=32000+6400
PHYSBASE 	EQU	2
CCONIN		EQU	1
LG_LIGNE	EQU	160
H_ECRAN		EQU	41
CADRE_GAUCHE	EQU	0
CADRE_HAUT	EQU	8*2
DEC=40		*pour les equas
HAUT=194	*tjrs pour les equas
SHRINK	EQU	$4A

;---------------
****super init pour le gem
	SECTION TEXT
PT_BASE:

       move.l sp,s_sp+2

	MOVE.L	4(A7),A0
	MOVE.L	$C(A0),D0
	ADD.L	$14(A0),D0
	ADD.L	$1C(A0),D0	;LIBERE LA MEMOIRE
	ADD.L	#$800,D0
	ANDI.L	#-2,D0
	LEA.L	0(A0,D0),A7
	
	MOVE.L	D0,-(A7)
	MOVE.L	A0,-(A7)
	CLR.W	-(A7)
	MOVE.W	#SHRINK,-(A7)
	TRAP	#1
	ADD.L	#12,A7

*******recherche de la place memoire multiple de 256

	MOVE.L	#SCR,D0
	AND.L	#$FFFFFF00,D0
	MOVEA.L	D0,A0
				;on cherche de la place pour
				;les 2 ecrans a switcher
	LEA	256(A0),A0	;multiple de 256 of course
	MOVE.L	A0,SCREEN
	LEA	32000(A0),A0
	LEA	6400(A0),A0
	MOVE.L	A0,SCREEN+4
		
	
	*SUPER
	
	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	LEA	SAVEALL(PC),A6
	MOVE.L	D0,(A6)+
	
	lea	stack,sp
	bsr	calc_txt
		
	move.l	#reset,$42a
	move.l	#$31415926,$426
	******on cache la souris
	
	DC.W	$A00A
	*********on nettoie ce putain d'ecran
	********qui est tout sale
	MOVE.L	$44E,A0
	MOVE.W	#7999,D0
CLR_SCR:
	CLR.L	(A0)+
	DBRA	D0,CLR_SCR

	*SAUVE PALETTE
	LEA	OLDPAL(PC),A0
	LEA	$FFFF8240.W,A2
	MOVEM.L	(A2),D0-D7
	MOVEM.L	D0-D7,(A0)


	
	BSR	PAUSE
	BSR	PAUSE
	
	MOVE	#$2700,SR
	
	lea	$ffff8240.w,a2
	clr.l	(a2)+
	clr.l	(a2)+
	clr.l	(a2)+
	clr.l	(a2)+
	clr.l	(a2)+
	clr.l	(a2)+
	clr.l	(a2)+
	clr.l	(a2)+

	*SAUVE LES MFPS
	
	MOVE.B	$FFFF8260.W,(A6)+	;RESO
	MOVE.B	$FFFF8201.W,(A6)+	;HIGH SCRADR BYTE
	MOVE.B	$FFFF8203.W,(A6)+	;LOW  SCRADR	BYTE
	MOVE.B	$FFFFFA07.W,(A6)+	;IERA
	MOVE.B	$FFFFFA09.W,(A6)+	;IERB
	MOVE.B	$FFFFFA13.W,(A6)+	;IMRA
	MOVE.B	$FFFFFA15.W,(A6)+	;IMRB
	MOVE.B	$FFFFFA17.W,(A6)+	;VECTOR REGISTER
	MOVE.B	$FFFFFA19.W,(A6)+	;TACR
	MOVE.B	$FFFFFA1B.W,(A6)+	;TBCR
	
	MOVE.L	$70.W,(A6)+		;VBI VECTOR
	MOVE.L	$120.W,(A6)+		;TB	VECTOR
	MOVE.L	$134.W,(A6)+		;TA	VECTOR
	
	MOVEQ	#0,D0
	MOVE.B	D0,$FFFFFA07.W	;CLEAR IERA
	MOVE.B	D0,$FFFFFA09.W	;CLEAR	IERB
	MOVE.B	D0,$FFFFFA13.W	;CLEAR IMRA
	MOVE.B	D0,$FFFFFA15.W	;CLEAR	IMRB
	BCLR.B	#3,$FFFFFA17.W	;AEI BIT IN VR
	
	*NOUVELLE ADRESSE
	STOP	#$2300
	STOP	#$2300
	MOVE.B	#$0,$FFFF8260.W
	MOVE.B	#$02,$FFFF820A.W
	
	
	MOVE.W	#$2300,SR
	
		
MAIN:
	*********************
	
	*****AFFICHAGE DE LOGO FUZION IN 'ROULEAU'
	
	
	
	lea	img_GFA+34,A0
	
	MOVE.L	$44E,A1
	move.l	#7999,d1
COPY
	MOVE.L	(A0)+,(A1)+
	DBRA	D1,COPY
	
	CLR.L	D0
	CLR.L	D1
	CLR.L	D2
	CLR.L	D3
	CLR.L	D4
	CLR.L	D5
	CLR.L	D6
	CLR.L	D7
        BSR	PAUSE
	
	MOVE.W	#8-1,D7
	
FADE:	LEA	IMG_GFA+2,A1
	LEA	$FFFF8240.W,A2
	MOVE.L	#16-1,D6
	
	
FADE1:
        BSR	PAUSE
	MOVE.W	(A2),D0		*A%
	MOVE.W	(A1)+,D1	*B%
	MOVE.W	D0,D3
	MOVE.W	D1,D4
	ANDI.W	#7,D3
	ANDI.W	#7,D4
	BSR	COMPARE		*COMPARE D3 ET D4 RENVOIE RESULT DANS D5
	SUB.W	D5,D0
	
	MOVE.W	D0,D3
	MOVE.W	D1,D4
	ANDI.W	#112,D3
	ANDI.W	#112,D4
	BSR	COMPARE		*COMPARE D3 ET D4 RENVOIE RESULT DANS D5
	MULU	#16,D5
	SUB.W	D5,D0
	
	MOVE.W	D0,D3
	MOVE.W	D1,D4
	ANDI.W	#1792,D3
	ANDI.W	#1792,D4
	BSR	COMPARE		*COMPARE D3 ET D4 RENVOIE RESULT DANS D5
	MULU	#256,D5
	SUB.W	D5,D0
	
	MOVE.W	D0,(A2)+
	
        
	DBRA	D6,FADE1
	DBRA	D7,FADE
	
	move.w	#$2700,sr
	
	MOVE.L	#IT_NULL,$70.W
	
	
*****************INTIT LES BUFFERS
	
	
	MOVEA.L	SCREEN,A0
	MOVEQ	#0,D0
	MOVE.W	#((2*SCRSIZ)/4)-1,D7
CLRSCR:
	MOVE.L	D0,(A0)+
	DBF	D7,CLRSCR
	
	
	BSR	PRECALC

	MOVEA.L	SCREEN,A0
	MOVEQ	#0,D0
	MOVE.W	#((2*SCRSIZ)/4)-1,D7
CLRSCR2:
	MOVE.L	D0,(A0)+
	DBF	D7,CLRSCR2
	
	LEA	BUFF_FD+34,A0
	MOVEM.L	SCREEN,D0-D1
	MOVE.L	D0,A1
	MOVE.L	D1,A2
	MOVE.W	#7999,D0
	
.LOOP:
	MOVE.L	(A0),(A1)+
	MOVE.L	(A0)+,(A2)+
	
	DBRA	D0,.LOOP

********PREPARE LE BAS DE L'ECRAN POUR L'OVERSCAN BAS
	
	lea	BUFF_IMG+34,A0
	MOVEM.L	SCREEN,D0-D1
	MOVE.L	D0,A1
	MOVE.L	D1,A2
	lea	158*160(a0),a0
	
	LEA	32000(A1),A1
	LEA	32000(A2),A2
	
	MOVE.W	#(160*40)/4-1,D0
		
.LOOP2:
	MOVE.L	(A0),(A1)+
	MOVE.L	(A0)+,(A2)+
	
	DBRA	D0,.LOOP2
**************************
	
	
	
	move.l	#80000,d0
	
ATTND2:	DBRA	D0,ATTND2
	
	MOVE.L	$44E,A0
	MOVE.W	#7999,D1
CLR:
	CLR.L	(A0)+
	DBRA	D1,CLR
	
	
	MOVE	#$2700,SR
	
	**********INIT DE LA COURBE RASTER
	lea	COURBE,A1
	LEA	(A1),A2
	
	LEA	COURBE_FUZ,A3

	LEA	-4(A3),A3
	MOVE.L	A3,POS_COURB
	
********INIT VARIABLES ET MUSIQUES

	moveQ	#3,d0	*put the value whant you want 1->9?
	jsr	music
	
	MOVE.L	#CAR_BDS,CAR_NEXT
	bsr	calc_txt
	
	MOVE.L	#BUFF_MT,BDS_MOT	;INITIALISE LA VARIABLE BDS_MOT
					;QUI CONTIENT L'ADRESSE DU PROCHAIN MOTIF
					
	MOVE.L	#REBOND,BDS_RB
	
	
	;
	*NOUVELLE ADRESSE
	STOP	#$2300
	STOP	#$2300
	MOVE.B	SCREEN+1(PC),$FFFF8201.W
	MOVE.B	SCREEN+2(PC),$FFFF8203.W
	
	MOVE.W	#$2700,SR
	

	
	*NOUVEAU VECTEURS
	
	LEA	VGTVBL(PC),A0
	MOVE.L	A0,$70.W
	LEA	hbl_init(PC),A0
	MOVE.L	A0,$120.W
	
	MOVE.B	#$01,$FFFFFA13.W	;DEMASK TB
	MOVE.B	#$01,$FFFFFA07.W	;OK TB
        andi.b #$df,$fffffa09.w

        clr.b $fffffa09.w
        clr.b $fffffa15.w

        bclr #6,$fffffa09.w
        bset #6,$fffffa09.w
			
	MOVE	#$2300,SR
			
******************************************
;ROUTINE KEY

WAIT0:	

              move.b $fffffc02.w,d0
f1:           cmpi.b #$3b,d0
              bne.s f2 ;* please next time put dis loader so we won't have
              move.l #nom1,nom+2 ;* to do it in your next intro.
              bra.s exit
f2:           cmpi.b #$3c,d0
              bne.s f3
              move.l #nom2,nom+2
              bra.s exit
f3:           cmpi.b #$3d,d0
              bne.s return
              move.l #nom3,nom+2

              bra.s exit	

return:       cmpi.b #$1c,d0
              bne.s wait0


	
;*****************FIN DE L'INTRO

EXIT:
	clr.l	$426
	
	*COUPE LES IT POUR RESTAURER
	
	MOVE	#$2700,SR
	move.l	#it_null,$70.w
	
	MOVE.B	#$00,$FFFFFA1B.W
	MOVEQ	#0,D0
	MOVE.B	D0,$FFFFFA07.W
	MOVE.B	D0,$FFFFFA09.W
	MOVE.B	D0,$FFFFFA13.W
	MOVE.B	D0,$FFFFFA15.W
	MOVE.L	#IT_NULL,$70.W
		
	*RETABLIT LA REZO:
	
	LEA	SAVREZ(PC),A6
	STOP	#$2300
	STOP	#$2300
	MOVE.B	(A6)+,$FFFF8260.W
	MOVE.B	(A6)+,$FFFF8201.W
	MOVE.B	(A6)+,$FFFF8203.W
			
	*RETABLIT LE MFP
	
	MOVE	#$2700,SR
	LEA	SAV07(PC),A6
	MOVE.B	(A6)+,$FFFFFA07.W
	MOVE.B	(A6)+,$FFFFFA09.W
	MOVE.B	(A6)+,$FFFFFA13.W
	MOVE.B	(A6)+,$FFFFFA15.W
	MOVE.B	(A6)+,$FFFFFA17.W
	MOVE.B	(A6)+,$FFFFFA19.W
	MOVE.B	(A6)+,$FFFFFA1B.W
	move.l	(a6)+,D7
	MOVE.L	(A6)+,$120.W
	MOVE.L	(A6)+,$134.W
	
	*VECTEUR VBL
	MOVE.L	D7,$70.W
	
	*REMET PALTETTE
	
	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp
	
	LEA	OLDPAL(PC),A0
	LEA	$FFFF8240.W,A2
	MOVEM.L	(A0),D0-D7
	MOVEM.L	D0-D7,(A2)
	
		*VIDE L'ACIA
.KFLUSH:
	BTST.B	#0,$FFFFFC00.W
	BEQ.S	.KFOK
	MOVE.B	$FFFFFC02.W,D0
	BRA.S	.KFLUSH
.KFOK:
	MOVE	#$2300,SR
	
	DC.W	$A009
	
	******STOP LA MUSIQUE
	
	
	MOVE.L	#$08000000,$FFFF8800.W
	MOVE.L	#$09000000,$FFFF8800.W
	MOVE.L	#$0A000000,$FFFF8800.W
	
	*USER
	
	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp
	
	 
	 	
	LEA	SAVEALL(PC),A6
	MOVE.L	(A6),-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP		

******TOUT EST COOL ON PEUT CHARGER
	
s_sp:         movea.l #0,sp

              tst.l nom+2
              beq quit

              lea buffer_load(pc),a6

              move.w #2,-(sp)
nom:          pea 0
              move.w #$3d,-(sp)
              trap #1
              addq.l #8,sp
              tst.w d0
              bmi error
              move.w d0,(a6)

              lea pt_base(pc),a1
              move.l a1,2(a6)
              lea -$1c(a1),a1
              move.l a1,6(a6)

              lea rel_deb(pc),a0
              lea -$0500(sp),a1
              movea.l a1,a2
              move.w #(rel_fin-rel_deb)/4,d0
cop_rel:      move.l (a0)+,(a1)+
              dbra d0,cop_rel

              jmp (a2)

rel_deb:      lea buffer_load(pc),a6
              bsr.s fread
              bsr.s protec
              bsr reloge
              bsr calc_bp

              movea.l 6(a6),a0
              movem.l eff_m(pc),d0-d6
              movem.l d0-d6,(a0)
              movea.l 2(a6),a3
              lea -$0100(a3),a1
              move.l 14(a6),d0
              lea -$32(sp),a6
              movea.l a4,a2

              jmp (a0)

fread:        move.l 6(a6),-(sp)
              pea $ffffff
              move.w (a6),-(sp)
              move.w #$3f,-(sp)
              trap #1
              lea 12(sp),sp
              tst.l d0
              bmi error
              move.l d0,10(a6)
              move.w (a6),-(sp)
              move.w #$3e,-(sp)
              trap #1
              addq.l #4,sp
              tst.w d0
              bmi error
              rts

protec:       movea.l 6(a6),a0
              movea.l a0,a1
              adda.l 10(a6),a1
              cmpi.w #$601a,(a0)
              beq.s ret_dec
              cmpi.w #'FZ',(a0)+
              bne error
              lea -1(a1),a2
              move.l 10(a6),d1
              move.l #'kGsL',d0
              move.w #magic_number,d2
              move.w #$cafe,d3
              not.w $1a(a0)

dec_cop:      add.l d1,d0
              eor.w d0,(a0)
              swap d0
              sub.w d2,(a0)
              eor.w d3,(a0)
              move.w (a0)+,d3
              cmpa.l a0,a2
              bgt.s dec_cop

ret_dec:      clr.b (a1)+
              clr.b (a1)+
              clr.b (a1)+
              clr.b (a1)+
              rts

reloge:       movea.l 6(a6),a0
              tst.w $1a(a0)
              bne.s rel_2
              movea.l 2(a6),a1
              move.l a1,d0
              adda.l 2(a0),a1
              adda.l 6(a0),a1
              adda.l 14(a0),a1
              moveq #0,d1
              move.l (a1)+,d2
              beq.s rel_4
rel_3:        add.l d0,$1c(a0,d2.l)
rel_4:        move.b (a1)+,d1
              beq.s rel_2
              add.l d1,d2
              cmp.b #1,d1
              bne.s rel_3
              addi.l #$fd,d2
              bra.s rel_4
rel_2:        rts

calc_bp:      movea.l 2(a6),a1
              movea.l 6(a6),a2
              lea -$0100(a1),a0
              move.l a1,d0
              move.l 2(a2),12(a0)
              add.l 12(a0),d0
              movea.l d0,a5
              move.l d0,16(a0)
              move.l 6(a2),20(a0)
              add.l 20(a0),d0
              movea.l d0,a4
              move.l d0,24(a0)
              move.l 10(a2),28(a0)
              rts

eff_m:        clr.l (a2)+
              cmpa.l a2,sp
              bge.s eff_m
              move.l a1,4(sp)
ssp:          move.l d0,(a6)
              move.l a3,6(a6)
              movem.l (a4),d0-a3
              movem.l d0-d6,pt_base-28

error:        pea err_sup(pc)
              move.w #$26,-(sp)
              trap #14
              addq.l #6,sp

quit:         clr.w -(sp)
              trap #1


err_sup:      movem.l $ffff8240.w,d0-d7
              movem.l d0-d7,-(sp)
              clr.w -(sp)
              move.b $ffff8260.w,1(sp)
              DC.W $a00a
              clr.b $0484.w
              move.w #1,-(sp)
              pea -1.w
              move.l (sp),-(sp)
              move.w #5,-(sp)
              trap #14
              lea 12(sp),sp
              move.w #$25,-(sp)
              trap #14
              addq.l #2,sp
              move.w #$07,$ffff8240.w
              move.w #$0777,$ffff8246.w
              pea aff_mes(pc)
              move.w #9,-(sp)
              trap #1
              addq.l #6,sp
attc:         cmpi.b #$39,$fffffc02.w
              bne.s attc
              pea -1.w
              move.l (sp),-(sp)
              move.w #5,-(sp)
              trap #14
              lea 12(sp),sp
              move.b #7,$0484.w
              move.w #$25,-(sp)
              trap #14
              addq.w #2,sp
              movem.l (sp)+,d0-d7
              movem.l d0-d7,$ffff8240.w
              rts

aff_mes:      DC.B 27,"E",27,"Y",41,32,7
              DC.B "                               - LOADING ERROR -",10,13
              DC.B 10,13
              DC.B "                     - MAYBE YOU SHOULD RECOPY THIS DISK -",10,13
              DC.B 10,13
              DC.B "                          - PRESS SPACE TO CONTINUE -",10,13
              DC.B 0
              EVEN
buffer_load:
              DS.W 1
              DS.L 4
rel_fin:      EVEN

nom1:         DC.B "1",0
              EVEN
nom2:         DC.B "2",0
              EVEN
nom3:         DC.B "3",0
              EVEN
	
SAVEALL:
SAVSSP:		DC.L	0
SAVREZ		DC.B	0
SAV8201:	DC.B	0
SAV8203		DC.B	0
SAV07:	DC.B	0
SAV09:	DC.B	0
SAV13:	DC.B	0
SAV15	DC.B	0
SAV17	DC.B	0
SAV19	DC.B	0
SAV1B	DC.B	0
SAVVBLREC	DC.L	0
SAVTAVEC	DC.L	0
SAVTBVEC	DC.L	0

OLDPAL:		DCB.W	16,0

IT_NULL:	RTE


COMPARE:
	********COMAPARE DEUX VALEURS DANS D3 ET D4***
	**SI EGALES ALORS D5=0 SINON D5=-1
	
	CMP.W	D3,D4
	BEQ.S	EQUAL
	MOVE.W	#-1,D5
	BRA.S	FIN_COMPARE
EQUAL:
	MOVE.W	#0,D5
	
FIN_COMPARE:
	RTS
	
	
***********ROUTINE DE VBL DE L'INTRO PRINCIPAL	
;----------------------
VGTVBL:
	;MOVE.W	#1911,$FFFF8240.W
	move.b	#0,$fffffa1b.w
					*ON BALANCE LA PALETTE
	move.w	#$765,$ffff8252.w	*DU LOGO FUZION
	move.w	#$210,$ffff8254.w
	move.w	#$321,$ffff8256.w
	move.w	#$432,$ffff8258.w
	move.w	#$543,$ffff825a.w
	move.w	#$222,$ffff825c.w
	
						
	MOVEM.L	SCREEN,D0-D1		*SWAP PHYS,LOG
	EXG	D0,D1
	MOVEM.L	D0-D1,SCREEN
	MOVE.B	SCREEN+1(PC),$FFFF8201.W
	MOVE.B	SCREEN+2(PC),$FFFF8203.W
	
	
	
	clr.l	d1
	
	MOVE.L	BDS_RB,A3
	CMP.L	#REBOND_END,A3
	Blo.S	FOLLOW
	LEA	REBOND,A3
FOLLOW:
	MOVE.l	(a3)+,REB
	MOVE.L	A3,BDS_RB
	
	MOVEM.L	REG1,A3/A4
	
	*COb%=A1 ADRESSE COURBE
	*POB%=A2 ADRESSE COURBE EN COURS
	*COU%=A3 NEW ADRESSE COURBE
	*W%=A5 VALEUR DE LA COURBE
	*NT%=A4 ADRESSE DU MOTIF EN COURS
	
	CMP.L	#COURBE_END-200,A2	*IF POB%<COB%+360
	BHS.S	.INIT1
	ADDA.L	#1,A2
	bra.s	.INIT2
.INIT1:
	LEA	(A1),A2

.INIT2:
	LEA	(A2),A3		*COU%=POB%
	LEA	BUFF_MT,A4
	ADDA.L	REB,A4			SINON ON SAUTE UNE LIGNE
	
.INIT4:
	MOVE.B	(A3),D1		*BYTE{COU%}
	LEA	(A4,D1),A5		*W%=NT%
	
	
	;ADDA.L	D1,A5		*W%=W%+NT%+BYTE{COU%}
	
	MOVEM.L	A3/A4,REG1
	
	MOVE.W	#193,HBL_CTR
	lea	coul,a6
	MOVE.B	#$04,$FFFFFA21.W
	move.l	#hbl_init,$120.w
	MOVE.B	#$08,$FFFFFA1B.W

	BSR	DISTORT
	movem.l	d0-a6,-(sp)
	jsr	music+8
	movem.l	(sp)+,d0-a6
	MOVE.L	SCREEN,PHYS		;ADRESSE PHYSIQUE
	BSR	AFF_EQUA1
	MOVE.L	SCREEN+4,PHYS		;ADRESSE PHYSIQUE
	BSR	AFF_EQUA1
	BSR	AFF_TXT
	MOVE.W	#0,$FFFF8240.W
	
	
	RTE
	
hbl_init:
	move.b	#$00,$fffffa1b.w
	move.b	#$01,$fffffa21.w
	move.l	#timerb,$120.w
	MOVE.B	#$08,$FFFFFA1B.W
	RTE
	
	
TIMERB:
	MOVE.L	(A5)+,$FFFF8242.l
	MOVE.L	(A5)+,$FFFF8246.l
	MOVE.L	(A5)+,$FFFF824A.l
	MOVE.L	(A5)+,$FFFF824E.l
	move.w	(a6)+,$ffff825c.w
	cmpi.w	#150,hbl_ctr
	bne.s	cont2
	move.w	#$000,$ffff8250.w	*CHARGE LES COULEURS DES FONTES
	move.w	#$100,$ffff8252.w
	move.w	#$210,$ffff8254.w
	move.w	#$310,$ffff8256.w
	move.w	#$420,$ffff8258.w
	move.w	#$520,$ffff825a.w
	move.w	#$630,$ffff825c.w
	move.l	#timerb2,$120.w
	
cont2:
	MOVEM.L	D1/A3/A4,-(SP)
	
	MOVEM.L	REG1,A3/A4
	
	lea	32(a4),a4
	
	MOVE.B	(A3)+,D1		*BYTE{COU%}
	LEA	(A4,d1),A5		*W%=NT%
	
	
	;ADDa.L	D1,A5		*W%=W%+NT%+BYTE{COU%}
	
	MOVEM.L	A3/A4,REG1
	
	MOVEM.L	(SP)+,D1/A3/A4
	
	subq.w	#1,hbl_ctr
	
	*
	RTE
	

TIMERB2:
	MOVE.L	(A5)+,$FFFF8242.l
	MOVE.L	(A5)+,$FFFF8246.l
	MOVE.L	(A5)+,$FFFF824A.l
	MOVE.L	(A5)+,$FFFF824E.l
	move.w	(a6)+,$ffff825e.w
	
	MOVEM.L	D1/A3/A4,-(SP)
	
	MOVEM.L	REG1,A3/A4
	
	lea	32(a4),a4
	
	MOVE.B	(A3)+,D1		*BYTE{COU%}
	LEA	(A4,d1),A5		*W%=NT%
	
	
	;ADDa.L	D1,A5		*W%=W%+NT%+BYTE{COU%}
	
	MOVEM.L	A3/A4,REG1
	
	MOVEM.L	(SP)+,D1/A3/A4
	
	subq.w	#1,hbl_ctr
	beq.s	hbl_end
	
	*
	RTE
	

hbl_end:
	move.b	#0,$fffffa1b.w
	move.w	#$000,$ffff8240.w	*CHARGE LES COULEURS
	move.w	#$510,$ffff8242.w	*DE L'OVERSCAN BAS
	move.w	#$410,$ffff8244.w
	move.w	#$533,$ffff8246.w
	move.w	#$544,$ffff8248.w
	move.w	#$467,$ffff824a.w
	move.w	#$356,$ffff824c.w
	move.w	#$777,$ffff824e.w
	
	move.b	#$01,$fffffa21.w
	move.l	#unten1,$120.w
	MOVE.B	#$08,$FFFFFA1B.W
	
	RTE
	
unten1:
        move.w	#$022,$ffff8250.w	*ET €A CONTINUE
	move.w	#$033,$ffff8252.w
	move.w	#$044,$ffff8254.w
	move.w	#$245,$ffff8256.w
	move.w	#$000,$ffff8258.w
	move.w	#$134,$ffff825a.w
	move.w	#$556,$ffff825c.w
	move.w	#$023,$ffff825e.w
	      move #$2700,sr
              movem.l d0/a0,-(sp)
              lea $fffffa21.w,a0
              clr.b -6(a0)
              move.b #16,(a0)
              move.l #unten2,$120		*bidon
              move.b #8,-6(a0)		*relance le timer b
              move.b (a0),d0
wrtx:         cmp.b (a0),d0		*attend la ligne suivante
              beq.s wrtx
              clr.b $ffff820a.w
              rept 15
              nop            	  *overscan	
              endr
              move.b #2,$ffff820a.w
              movem.l (sp)+,d0/a0
              rte


unten2:					*et ‡a continue
              move #$2700,sr
              movem.l d0/a0,-(sp)
              lea $fffffa21.w,a0
              clr.b -6(a0)
              move.b #240,(a0)
              move.b #8,-6(a0)
              move.b (a0),d0		*attend la ligne suivante
wrtx2:        cmp.b (a0),d0
              beq.s wrtx2
              clr.b $ffff820a.w
              rept 15
              nop
              endr
              move.b #2,$ffff820a.w
              movem.l (sp)+,d0/a0
              clr.b $fffffa1b.w
	      rte
              

*************************ROUTINES DE TRANSFORM QUI PREPARE LE LOGO FUZION ************

DECAL:
	MOVEM.L	D0-A6,-(SP)
	
	MOVE.L	SCREEN,A0
	MOVE.W	#H_ECRAN-1,D0

LIGNE_SUIVANTE:
	ROXR.W	(A0)
	ROXR.W	8(A0)
	ROXR.W	16(A0)
	ROXR.W	24(A0)
	ROXR.W	32(A0)
	ROXR.W	40(A0)
	ROXR.W	48(A0)
	ROXR.W	56(A0)
	ROXR.W	64(A0)
	ROXR.W	72(A0)
	ROXR.W	80(A0)
	ROXR.W	88(A0)
	ROXR.W	96(A0)
	ROXR.W	104(A0)
	ROXR.W	112(A0)
	ROXR.W	120(A0)
	ROXR.W	128(A0)
	ROXR.W	132(A0)		;1ER PLAN
	
	ROXR.W	2(A0)		;	2EME	PLAN
	ROXR.W	10(A0)
	ROXR.W	18(A0)
	ROXR.W	26(A0)
	ROXR.W	34(A0)
	ROXR.W	42(A0)
	ROXR.W	50(A0)
	ROXR.W	58(A0)
	ROXR.W	66(A0)
	ROXR.W	74(A0)
	ROXR.W	82(A0)
	ROXR.W	90(A0)
	ROXR.W	98(A0)
	ROXR.W	106(A0)
	ROXR.W	114(A0)
	ROXR.W	122(A0)
	ROXR.W	130(A0)
	ROXR.W	138(A0)
	
	ROXR.W	4(A0)		;	3EME PLAN
	ROXR.W	12(A0)
	ROXR.W	20(A0)
	ROXR.W	28(A0)
	ROXR.W	36(A0)
	ROXR.W	44(A0)
	ROXR.W	52(A0)
	ROXR.W	60(A0)
	ROXR.W	68(A0)
	ROXR.W	76(A0)
	ROXR.W	84(A0)
	ROXR.W	92(A0)
	ROXR.W	100(A0)
	ROXR.W	108(A0)
	ROXR.W	116(A0)
	ROXR.W	124(A0)
	ROXR.W	132(A0)
	ROXR.W	140(A0)
	
	ROXR.W	6(A0)		;	4EME	PLAN
	ROXR.W	14(A0)
	ROXR.W	22(A0)
	ROXR.W	30(A0)
	ROXR.W	38(A0)
	ROXR.W	46(A0)
	ROXR.W	54(A0)
	ROXR.W	62(A0)
	ROXR.W	70(A0)
	ROXR.W	78(A0)
	ROXR.W	86(A0)
	ROXR.W	94(A0)
	ROXR.W	102(A0)
	ROXR.W	110(A0)
	ROXR.W	118(A0)
	ROXR.W	126(A0)
	ROXR.W	134(A0)
	ROXR.W	142(A0)
	

	
	LEA	LG_LIGNE(A0),A0
	DBRA	D0,LIGNE_SUIVANTE
	MOVEM.L	(SP)+,D0-A6
	
	RTS
	
DECAL2:	
	MOVEM.L	D0-A6,-(SP)
	
	************routine de decalage 2‚me version
	************on decal en maskant
	************d3 pos de l'adresse video en cours
	************d4 decalage, en offset
	
	
	
	LEA	BUFF_SP,A1
	LEA	BUFF_MS,A4
	
	
	MOVE.L	SCREEN,A0
	
	LEA	160*60(A0),A0

	MOVEM.L	D0-A6,-(SP)
	
	***AFFICHAGE DU FOND
	
	
	LEA	BUFF_FD+34+160*60,A1
	LEA	(A1,D3),A1
	LEA	(A0,D3),A0
	
	REPT	41-1
	
	MOVEM.L	(A1)+,D0-D7/A2-A6
	MOVEM.L	D0-D7/A2-A6,(A0)
	LEA	52(A0),A0
	MOVEM.L	(A1)+,D0-D7/A2-A6
	MOVEM.L	D0-D7/A2-A6,(A0)
	LEA	52(A0),A0
	
	MOVEM.L (A1)+,D0-D7
	MOVEM.L	D0-D7,(A0)
	
	
	LEA	24+32(A0),A0
	LEA	24(A1),A1
	
	ENDR
	
		
	MOVEM.L	(SP)+,D0-A6
	
	
	
	MOVE.W	#40-1,D1
LIGNE5:

HOP	SET	0

	REPT	32*2
	;MOVE.L	HOP(A1,D4),HOP(A0,D3)
	
	
	MOVE.W	HOP(A4,D4),D5	;ON CHOPPE LE MASK
	
	NOT     D5
				*AFFICHAGE MASK
	AND.W	D5,HOP(A0,D3)
	MOVE.W	HOP(A1,D4),D5
	OR.W	D5,HOP(A0,D3)
	
HOP	SET	HOP+2	
	ENDR
	
	LEA	160(A0),A0
	LEA	132*16(A1),A1
	LEA	132*16(A4),A4
	
	
	DBRA	D1,LIGNE5
	
	
	
	MOVEM.L	(SP)+,D0-A6
	
	RTS
	
	********************INITIALISATIONS DU BUFFER_SP CONTENANT LE SPRITE FUZION PRECALC*****

PRECALC:	
	
	MOVEM.L	D0-A6,-(SP)
	
	MOVE.L	SCREEN,A0
	
	
	LEA	BUFF_IMG,A1
	LEA	34(A1),A1
	MOVE.W	#7999,D1
	
.LOOP:
	MOVE.L	(A1)+,(A0)+
	DBRA	D1,.LOOP
	
	****PREDECALAGE DU SPRITE
	
	MOVE.W	#16-1,D1	*16 TOURS OF COURSE
	LEA	BUFF_SP,A3

BOUCLE:

	BSR	DECAL		*DECAL LE SPRITE
	MOVE.L	SCREEN,A1
	LEA	(A3),A2
	LEA	132(A3),A3	*ON SAUTE UNE LIGNE DS BUFFER(1LIGNE=132 OCTETS)
	
	*******ON COPIE UNE LIGNE
	
	MOVE.W	#40-1,D2
LIGNE:
	
HOP	SET	0

	REPT	33	*COPIE LES LIGNES DS
			*BUFFER
	MOVE.L	HOP(A1),HOP(A2)
HOP	SET	HOP+4	
	ENDR
	LEA	160(A1),A1
	LEA	132*16(A2),A2	*LIGNE SUIVANTE 132*16(CAR 16 POSITIONS)
	DBRA	D2,LIGNE
	
	
	DBRA	D1,BOUCLE
	
	***ON AFFHICHE LE MASK
	
	LEA	BUFF_IMG+34+160*42,A1
	MOVE.L	SCREEN,A0
	MOVE.W	#2000,D1
	
.LOP:
	MOVE.L	(A1)+,(A0)+
	DBRA	D1,.LOP
	
	****PREDECALAGE DU MASK
	
	MOVE.W	#16-1,D1		*16 POS OF COURSE
	LEA	BUFF_MS,A3
	
BOUCLE2:
	BSR	DECAL
	MOVE.L	SCREEN,A1
	LEA	(A3),A2
	LEA	132(A3),A3
	
	*******ON COPIE UNE LIGNE
	
	MOVE.W	#40-1,D2
LIGNE2:
	
HOP	SET	0

	REPT	33
	
	MOVE.L	HOP(A1),HOP(A2)
HOP	SET	HOP+4	
	ENDR
	LEA	160(A1),A1
	LEA	132*16(A2),A2
	
	DBRA	D2,LIGNE2
	
	
	DBRA	D1,BOUCLE2
	
	*****on REcalcul le predecalage avec le fond adequate(ET NON PLUS UN FOND NOIR,DONC ON N'A PLUS DE MASK)
	
	LEA	BUFF_FD+34,A1
	MOVE.L	SCREEN,A0
	MOVE.W	#7999,D1
	
.LOOP3
	MOVE.L	(A1)+,(A0)+
	DBRA	D1,.LOOP3
	
	MOVEQ	#0,D3
	CLR.L	D4
	MOVE.W	#15,D7
	
	******DEBUT DE LA ROUTINE
	LEA	BUFF_SP,A3
	
RECOM:
	
	BSR	DECAL2
	ADD.L	#132,D4
	CLR.L	D5
	****SAUVEGARDE DES LIGNES DS BUFFER

	MOVE.L	SCREEN,A1
	LEA	160*60(A1),A1
	
	LEA	(A3),A2
	LEA	132(A3),A3
	
	*******ON COPIE UNE LIGNE
	
	MOVE.W	#40-1,D2
LIGNE4:
	
HOP	SET	0

	REPT	33	*COPIE LES LIGNES DS
			*BUFFER
	MOVE.L	HOP(A1),HOP(A2)
HOP	SET	HOP+4	
	ENDR
	LEA	160(A1),A1
	LEA	132*16(A2),A2	*LIGNE SUIVANTE 132*16
	DBRA	D2,LIGNE4
	
	DBRA	D7,RECOM
	
	MOVEM.L	(SP)+,D0-A6
	RTS

************************************************
***************ROUTINE DE DISTORTION************
*************MISE AU POINT LE 08/09/92 PAR GFA**
************************************************
	
DISTORT:
	MOVEM.L	D0-A4,-(SP)
	
	MOVEA.L	POS_COURB,A3
	
	****ON DISTORTE
	
	****A2=BUFFER SPRITE
	******D2=COMPTEUR
	******A0=ECRAN
	
	
	LEA	BUFF_SP,A1
	
	CMP.L	#COURBE_FUZ+2403*4,A3
	BHS.S	.INIT3
	ADDA.L	#4,A3
	BRA.S	.INIT4
.INIT3:
	LEA	COURBE_FUZ,A3
.INIT4:
	LEA	(A3),A2
	MOVE.W	(A2)+,D3		*ON LIT LE DACALAGE SUR L'CRAN
	MOVE.W	(A2)+,D4		*OFFSET DU SPRITE
	
	
	
	MOVE.L	SCREEN,A0
	LEA	160*6(A0),A0
	MOVEM.L	D0-A4,-(SP)
	
	***AFFICHAGE DU FOND
	
	LEA	BUFF_FD+34+160*60,A1
	LEA	-8(A1,D3),A1
	LEA	-8(A0,D3),A0
	
	REPT	41-1
	
	MOVEM.L	(A1)+,D0-D5
	MOVEM.L	D0-D5,(A0)
	LEA	96(A1),A1
	LEA	96+24(A0),A0
	MOVEM.L	(A1)+,D0-D5
	MOVEM.L	D0-D5,(A0)
	LEA	40(A0),A0
	LEA	16(A1),A1
	
	
	ENDR
	
		
	MOVEM.L	(SP)+,D0-A4
	
	
	MOVE.W	#40-1,D1
LIGNE3:
HOP	SET	0

	REPT	32
	MOVE.L	HOP(A1,D4),HOP(A0,D3)
	
HOP	SET	HOP+4	
	ENDR
	
	LEA	160(A0),A0
	LEA	132*16(A1),A1
	
	MOVE.W	(A2)+,D3
	MOVE.W	(A2)+,D4
	
	
	DBRA	D1,LIGNE3
	
	MOVE.L	A3,POS_COURB
	MOVEM.L	(SP)+,D0-A4
	
	RTS
*************FIN DE LA DISTORTE

*************ROUTINE D'EQUALIZERS

AFF_EQUA1
	MOVEM.L	A0-A4/D0-D7,-(SP)
	MOVE.L	PHYS,A3
	**********echange toutes les variables  	
	
	MOVEM.L	SAUV1,D0-D1
	EXG	D0,D1
	MOVEM.L	D0-D1,SAUV1
	MOVEM.L	SAUV2,D0-D1
	EXG	D0,D1
	MOVEM.L	D0-D1,SAUV2
	MOVEM.L	SAUV3,D0-D1
	EXG	D0,D1
	MOVEM.L	D0-D1,SAUV3
	
	MOVEM.L	EFF1,D0-D1
	EXG	D0,D1
	MOVEM.L	D0-D1,EFF1
	MOVEM.L	EFF2,D0-D1
	EXG	D0,D1
	MOVEM.L	D0-D1,EFF2
	MOVEM.L	EFF3,D0-D1
	EXG	D0,D1
	MOVEM.L	D0-D1,EFF3
	
	
	
	LEA	HAUT*160+DEC(A3),A1
	clr.l	d1
	CLR.L	D2
	
	MOVE.B	#8,$FF8800
	MOVE.B	$FF8800,D1
	move.L	sauv1,D2
	MOVE.L	D1,SAUV1
	SUB.L	D1,D2
	BLE.s	EQUA1
	BSR	EFF_EQUA
	BRA.S	AFF_EQUA2
	
	
EQUA1
	TST.L	D2
	BEQ.S	AFF_EQUA2
	mulU	#2,d1
	MOVE.L	D1,D2
	mulu	#160,D2
	MOVE.L	D2,EFF1
	
EQU1	
	MOVE.L	#$FFFF7FFF,0(A1)
	MOVE.L	#$7FFFFFFF,4(A1)
	MOVE.L	#$FFD4FF32,8(A1)
	MOVE.L	#$FF0EFF81,12(A1)
	LEA	-160(A1),A1
	DBRA	D1,EQU1


AFF_EQUA2
	LEA	HAUT*160+DEC+32(A3),A1
	clr.l	d1
	CLR.L	D2
	
	MOVE.B	#9,$FF8800
	MOVE.B	$FF8800,D1
	move.L	sauv2,D2
	MOVE.L	D1,SAUV2
	SUB.L	D1,D2
	BLE.s	EQUA2
	BSR	EFF_EQUA2
	BRA.S	AFF_EQUA3
	
	
EQUA2
	TST.L	D2		;SI LA DIFF=0 ON NE FAIT RIEN
	BEQ.S	AFF_EQUA3
	mulU	#2,d1
	MOVE.L	D1,D2
	mulu	#160,D2			;EFF2 PREND LE MAX DE L'EQUA2
	MOVE.L	D2,EFF2
	
EQU2	
	MOVE.L	#$FFFF7FFF,0(A1)
	MOVE.L	#$7FFFFFFF,4(A1)
	MOVE.L	#$FFD4FF32,8(A1)
	MOVE.L	#$FF0EFF81,12(A1)
	LEA	-160(A1),A1		;ON SAUTE 1 LIGNE
	DBRA	D1,EQU2

AFF_EQUA3
	LEA	HAUT*160+DEC+64(A3),A1
	clr.l	d1
	CLR.L	D2
	
	MOVE.B	#10,$FF8800
	MOVE.B	$FF8800,D1
	move.L	sauv3,D2
	MOVE.L	D1,SAUV3
	SUB.L	D1,D2
	BLE	EQUA3
	BSR	EFF_EQUA3
	BRA.S	FIN_EQUA
	
	
EQUA3
	TST.L	D2
	BEQ.S	FIN_EQUA
	mulU	#2,d1
	MOVE.L	D1,D2
	mulu	#160,D2			;EFF2 PREND LE MAX DE L'EQUA2
	MOVE.L	D2,EFF3
	
EQU3	
	MOVE.L	#$FFFF7FFF,0(A1)
	MOVE.L	#$7FFFFFFF,4(A1)
	MOVE.L	#$FFD4FF32,8(A1)
	MOVE.L	#$FF0EFF81,12(A1)
	LEA	-160(A1),A1
	DBRA	D1,EQU3

FIN_EQUA:	
	
	MOVEM.L	(SP)+,A0-A4/D0-D7
	RTS
	
EFF_EQUA
	LEA	HAUT*160+DEC(A3),A1
	
	SUBA.L	EFF1,A1
	SUB.L	#160*2,EFF1
	
	MOVE.l	#4,D1
	LEA	34+BUFF_FD+160*160+32,A0
		
EFF_EQ1
	MOVE.L	0(A0),0(A1)
	MOVE.L	12(A0),12(A1)
	MOVE.L	4(A0),4(A1)
	MOVE.L	8(A0),8(A1)
	LEA	160(A1),A1
	LEA	160(A0),A0
	
	DBRA	D1,EFF_EQ1

	RTS
	
	;***EFFACEMENT DES EQUAS
	
EFF_EQUA2
	LEA	HAUT*160+DEC+32(A3),A1
	MOVE.L	A1,D1
	SUBA.L	EFF2,A1
	CMP.L	#1280,EFF2
	BLO.S	RETOUR
	
	MOVE.l	#4,D1
	LEA	34+BUFF_FD+160*160+64,A0	
	
EFF_EQ2
	MOVE.L	0(A0),0(A1)
	MOVE.L	12(A0),12(A1)
	MOVE.L	4(A0),4(A1)
	MOVE.L	8(A0),8(A1)
	LEA	160(A1),A1
	LEA	160(A0),A0
	DBRA	D1,EFF_EQ2
RETOUR:
	RTS

EFF_EQUA3
	LEA	HAUT*160+DEC+64(A3),A1
	
	SUBA.L	EFF3,A1
	SUB.L	#160*2,EFF3		;POSITIONNE SUR LE BOUT A EFFACER
	
	MOVE.l	#4,D1
	LEA	34+BUFF_FD+160*160+96,A0
		
EFF_EQ3
	MOVE.L	0(A0),0(A1)
	MOVE.L	12(A0),12(A1)
	MOVE.L	4(A0),4(A1)
	MOVE.L	8(A0),8(A1)
	LEA	160(A1),A1
	LEA	160(A0),A0
	
	DBRA	D1,EFF_EQ3

	RTS

***********************ROUTINE D'AFFICHAGE DU TEXTE DU 10/09/92
***********************CODE BY GFA HIMSELF

AFF_TXT:
	MOVEM.L	D0-A4,-(SP)
	
	LEA	BUFF_IMG+34,A0
	MOVE.L	SCREEN,A1
	
	MOVE.L	CAR_NEXT,A3
	CMP.W	#8,(A3)
	BNE.S	FOLL
	LEA	CAR_BDS,A3
	
FOLL:
	MOVE.w	(A3),D0
	MOVE.w	2(A3),D1
	ADD.B	#1,TERM
	CMPI.B	#6,TERM		;temps d'attente avant d'afficher le prochain caractere
	BLO.S	FOLL2
	CLR.B	TERM	
	LEA	4(A3),A3
		
FOLL2:

	MOVE.L	A3,CAR_NEXT
	
	LEA	(A0,D1),A0
	LEA	(A1,D0),A1
	
	REPT	16 
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	LEA	160-8(A0),A0
	LEA	160-8(A1),A1
	
	
	ENDR
FIN_TXT:

	MOVEM.L	(SP)+,D0-A4
	
	rts
******************************CODE DU PRECALC DU TEXTE
****************FOR WHY???????************************

CALC_TXT:
	MOVEM.L	D0-A6,-(SP)
	LEA	CAR_BDS,A0
	LEA	TEXTE,A2
C5:
	
C4:
	CLR.L	D0
	CLR.L	D1
	CLR.L	D2
	CLR.L	D3
	CLR.L	D4
	
	MOVE.B	(A2)+,D0	;LIT LA LIGNE
	MULU	#160,D0
	MOVE.B	(A2)+,D1	;LIT LA POS SUR L'ECRAN
	ADD.L 	D0,D1
	MOVE.W	D1,D4		;SAUVE DANS CAR
	
c6:	
	LEA	TABLE,A1
	CLR.L	D0
	CLR.L	D1
	CLR.L	D2
	CLR.L	D3
	MOVE.B	(A2)+,D0	;LIT LE CARAC ASCII
	CMPI.B	#1,D0		;ON RECOMMENCE UNE NEW LIGNE
	BEQ.S	C4
	CMPI.B	#0,D0		;FIN
	BEQ.S	C3
	
	MOVE.B	(A1)+,D1
C2:	MOVE.B	(A1)+,D1	;STOCKE LA LIGNE DU CARAC DE FONTE
C1:	
	MOVE.B	(A1)+,D2	;CARAC DE LA TABLE
	CMPI.B	#1,D2
	BEQ.S	C2		;ON CHANGE DE LIGNE DS TABLE
	CMPI.B	#0,D2
	BEQ.S	C3
	ADDQ.W	#1,D3
	CMP.B	D0,D2		;ON A TROUVE LE CARACT
	BNE.S	C1
	MULU	#160,D1		;MULTIPLIE LA LIGNE PAR 160
	SUBQ.W	#1,D3		;OFFSET-1
	MULU	#8,D3		;*8 OCTETS
	ADD	D3,D1
	MOVE.W	D4,(A0)+
	ADD.W	#8,D4
	
	MOVE.W	D1,(A0)+	;MET LA POS DE LA FONTE DS CAR
	BRA.S	C6
C3:
	MOVE.W	#8,(A0)+
	
		
	
	MOVEM.L	(SP)+,D0-A6
	RTS
		
	
*******ROUTINE DE PAUSE
PAUSE:
	MOVEM.L	D0-A6,-(SP)
	MOVE.W	#5000,D0
ATTND:	DBRA	D0,ATTND
	MOVEM.L	(SP)+,D0-A6
	RTS
	
			
		************ROUTINE DE RESET DE VBL
VBL_RESET:
		
	addq.w	#1,d2
	cmpi.w	#264,d2
	bEq.s	FIN_VBL1
BOUCL2:
	BSR	BMOVE
	BSR	BMOVE2
	ADDA.L	#160,A0
	ADDA.L	#160,A1			****ON AFFICHE EN ROULEAU L'IMAGE
	SUBA.L	#160,A2
	ADDA.L	#160,A3
	
fin:
	
	movem.l	d0-a6,-(sp)
	JSR	MUSIC+8
	movem.l	(sp)+,d0-a6
	rte
FIN_VBL1:
	movem.l	d0-a6,-(sp)
	JSR	MUSIC+8
	movem.l	(sp)+,d0-a6
	MOVE.L	#VBL_RESET2,$70.W
	RTE
				;A%=-64

VBL_RESET2:
	
	movem.l	d0-a6,-(sp)
	JSR	MUSIC+8
	movem.l	(sp)+,d0-a6
	rte
	
*****************ROUTINE DE PREPARATION DE LA RESET-SCREEN	
reset:
	move	#$2700,sr
	
	movea.l	$436,a0
	lea	-4(a0),a0
	movea.l	a0,a7
	
	lea	$ffff8240.w,a2
	clr.l	(a2)+
	clr.l	(a2)+
	clr.l	(a2)+
	clr.l	(a2)+
	clr.l	(a2)+
	clr.l	(a2)+
	clr.l	(a2)+
	clr.l	(a2)+
	
r	cmpi.b	#0,$ffff8209.w
	bne.s	r			;ATTEND LE BALAYAGE
	move.b	#2,$ffff820a.w		
	
	
	
		
	MOVE.L	SCREEN,A0
	MOVEQ	#0,D0
	MOVE.W	#(scrsiz*2)/4,D7
.CLS:
	MOVE.L	D0,(A0)+
	DBF	D7,.CLS

	lea	buff_FD,A0		**ON NETTOIE LES BUFFERS
	MOVEQ	#0,D0			*POUR QUE TOUT SOIT PROPRE
	MOVE.W	#7999*2,D7
.CLS2:
	MOVE.L	D0,(A0)+
	DBF	D7,.CLS2

	
	LEA	BUFF_IMG_RESET+2,A1
	LEA	$FFFF8240.W,A2		**INSTALLE LA PALETTE
	MOVEM.L	(A1),D0-D7
	MOVEM.L	D0-D7,(A2)
	
	MOVE.B	SCREEN+1,$FFFF8201.W
	MOVE.B	SCREEN+2,$FFFF8203.W
	
	move.l	reg,d0
	jsr	music
	add.l	#1,reg
	CMPI.L	#11,REG
	BNE.S	OK
	CLR.L	REG
OK:

	
	MOVE.L	#VBL_RESET,$70			
	LEA	BUFF_IMG_RESET+34+31840,A0
	LEA	BUFF_IMG,A1
	move.w	#198,d1
boucl1:

	BSR	BMOVE
	adda.l	#160,a1			;PREPARE LE ROULEAU
	suba.l	#160,a0		
	
	dbra	d1,boucl1
	
	lea	BUFF_img_reset+34-10240,A0
	MOVE.L	SCREEN,A1
	LEA	-10240(A1),A1		;XBIOS(2)+A%*160
	LEA	BUFF_IMG+29120,A2
	move.l	SCREEN,a3
	LEA	-10240+160(A3),A3	;XBIOS(2)+A%*160+160
	move.w	#0,d2		;COMPTEUR A ZERO
	
	********ON Y VA
	
	move	#$2300,sr
SPACE_BAR:
	cmp.b	#$39,$fffffc02.w
	BNE	SPACE_BAR
	
	*********ON FAIT UN VRAI RESET
	clr.l	$426
	jmp	$e00030


*********************************************	
***ROUTINE DE BMOVE D0/D3=TAILLE	
***a0=source,a1=dest

BMOVE:
	MOVEM.L	D0-A6,-(SP)
	move.w	#40,d0
.COP:
	MOVE.L	(A0)+,(A1)+
	DBRA	D0,.COP
	
	MOVEM.L	(SP)+,D0-A6
	RTS
*********************************
***ROUTINE DE BMOVE 2EME FA€ON
***A2=SOURCE A3=DEST
***************
 
BMOVE2:
	MOVEM.L	D0-A6,-(SP)
	move.w	#1600,d3
.COP2:
	MOVE.L	(A2)+,(A3)+
	DBRA	D3,.COP2
	
	MOVEM.L	(SP)+,D0-A6
	RTS
*******routine de bmove pour le gfa
********

BMOVE3:
	MOVEM.L	D0/a0/a1,-(SP)
	lsr	#3,d0
	sub.w	#1,d0
	
.COP3:
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	DBRA	D0,.COP3
	
	
	MOVEM.L	(SP)+,D0/a0/a1
	RTS
BMOVE4:
	MOVEM.L	D3/a2/a3,-(SP)
	lsr	#3,d3
	sub.w	#1,d3  
.COP4:
	MOVE.L	(A2)+,(A3)+
	MOVE.L	(A2)+,(A3)+
	DBRA	D3,.COP4
	
	MOVEM.L	(SP)+,D3/a2/a3
	RTS
	
	
***************************************


	****FIN DES ROUTINES
	

	SECTION	DATA
	even
SCREEN
	DC.L	0
	DC.L	0

	even
	
BUFF_FD:		INCBIN		\SCREEN5\MOT.PI1
	even
BUFF_IMG		INCBIN		\SCREEN5\FUZ.PI1
	even
BUFF_MT:
		INCBIN		\SCREEN5\MOTIF.BIN
MOTIF_END:
	EVEN
BUFF_IMG_RESET	INCBIN		\SCREEN5\FUZ3.PI1

IMG_GFA		INCBIN		\SCREEN5\GFA.PI1

MUSIC	INCBIN	\SCREEN5\Mix.MUS	

	even
	****rasters pour les equas
coul:


   dc.w  2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,3,3,3,3
   dc.w  3,3,3,3,3,4,4,4,4,4,4,5,5,5,5,5,5,6,6
   dc.w  6,6,7,7,6,6,550,550,823,823,1857,1857,1857,1857,1857,1857,1857,1857,1857
   dc.w  1857,1857,1857,1857,1857,1857,1857,1857,1857,1857,1857,1857,1857,1857,1857,1857,1857,1857,1857
   dc.w  1857,1857,1857,1857,1857,1857,1857,1857,1857,1857,1857,1857,1857,1857,1857,1857,1857,1857,1857
   dc.w  1857,1857,1857,1857,1857,1857,1857,1857,1857,1857,1857,1857,1857,1857,1857,1857,1857,1857,1857
   dc.w  1857,1857,1857,1857,1857,1857,1857,1857,1857,1857,1857,1857,1857,1857,1857,1857,1857,1857,1857
   dc.w  1857,1857,1857,1857,1857,1857,1857,1857,1857,1857,1857,1857,1857,1857,1857,1857,1857,1857,1857
   dc.w  1857,1857,1857,1857,1857,0,1904,1904,1888,1888,1872,1872,1872,1872,1856,1856,1856,1856,1824
   dc.w  1824,1824,1824,1552,1552,1296,1296,1296,1296,1024,1024,768,768,768,768,512,512,512,512
   dc.w  0,0,0,0,0   
   

CAR_NEXT	DC.L	0
PHYS	DC.L	0
	even
REG1	DC.L	0
REG2	DC.L	0
REG	DC.L	4	***CHANGE DE MUSIQUE DS RESET DEMO
VBL	DC.B	0

	even
POS_COURB	DC.L	0
	even
HBL_CTR		DC.W	0	*COMPTEUR DE LIGNE POUE LE TIMERB

SAUV1		DC.L	0
		DC.L	0
SAUV2		DC.L	0
		DC.L	0
SAUV3		DC.L	0
		DC.L	0
EFF1		DC.L	0
		DC.L	0
EFF2		DC.L	0
		DC.L	0
EFF3		DC.L	0
		DC.L	0
BDS_MOT		DC.L	0
BDS_RB		DC.L	0
REB		DC.l	32

	even
	
COURBE_FUZ:

     DC.W 16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528
     DC.W 16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528
     DC.W 16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528
     DC.W 16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528
     DC.W 16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528
     DC.W 16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528
     DC.W 16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528
     DC.W 16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528
     DC.W 16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528
     DC.W 16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528
     DC.W 16,528,16,528,16,528,16,660,16,660,16,792,16,924,16,924,16,1056,16,1188,16,1188,16,1320,16,1320,16,1452,16,1584,16,1584
     DC.W 16,1716,16,1716,16,1848,16,1980,16,1980,24,0,24,0,24,132,24,264,24,264,24,396,24,396,24,528,24,528,24,660,24,792
     DC.W 24,792,24,924,24,924,24,1056,24,1056,24,1188,24,1188,24,1320,24,1320,24,1452,24,1452,24,1584,24,1584,24,1716,24,1716,24,1716
     DC.W 24,1848,24,1848,24,1980,24,1980,24,1980,32,0,32,0,32,132,32,132,32,132,32,264,32,264,32,264,32,396,32,396,32,396
     DC.W 32,528,32,528,32,528,32,528,32,660,32,660,32,660,32,660,32,792,32,792,32,792,32,792,32,792,32,792,32,924,32,924
     DC.W 32,924,32,924,32,924,32,924,32,924,32,924,32,924,32,924,32,924,32,924,32,924,32,1056,32,924,32,924,32,924,32,924
     DC.W 32,924,32,924,32,924,32,924,32,924,32,924,32,924,32,924,32,924,32,792,32,792,32,792,32,792,32,792,32,792,32,660
     DC.W 32,660,32,660,32,660,32,528,32,528,32,528,32,528,32,396,32,396,32,396,32,264,32,264,32,264,32,132,32,132,32,132
     DC.W 32,0,32,0,24,1980,24,1980,24,1980,24,1848,24,1848,24,1716,24,1716,24,1716,24,1584,24,1584,24,1452,24,1452,24,1320,24,1320
     DC.W 24,1188,24,1188,24,1056,24,1056,24,924,24,924,24,792,24,792,24,660,24,528,24,528,24,396,24,396,24,264,24,264,24,132
     DC.W 24,0,24,0,16,1980,16,1980,16,1848,16,1716,16,1716,16,1584,16,1584,16,1452,16,1320,16,1320,16,1188,16,1188,16,1056,16,924
     DC.W 16,924,16,792,16,660,16,660,16,528,16,528,16,396,16,264,16,264,16,132,16,0,16,0,8,1980,8,1848,8,1848,8,1716
     DC.W 8,1716,8,1584,8,1452,8,1452,8,1320,8,1320,8,1188,8,1056,8,1056,8,924,8,924,8,792,8,660,8,660,8,528,8,528
     DC.W 8,396,8,396,8,264,8,264,8,132,8,0,8,0,0,1980,0,1980,0,1848,0,1848,0,1716,0,1716,0,1584,0,1584,0,1452
     DC.W 0,1452,0,1320,0,1320,0,1320,0,1188,0,1188,0,1056,0,1056,0,1056,0,924,0,924,0,792,0,792,0,792,0,660,0,660
     DC.W 0,660,0,528,0,528,0,528,0,396,0,396,0,396,0,396,0,264,0,264,0,264,0,264,0,132,0,132,0,132,0,132
     DC.W 0,132,0,132,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
     DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,132,0,132,0,132
     DC.W 0,132,0,132,0,132,0,264,0,264,0,264,0,264,0,396,0,396,0,396,0,396,0,528,0,528,0,528,0,660,0,660
     DC.W 0,660,0,792,0,792,0,792,0,924,0,924,0,1056,0,1056,0,1056,0,1188,0,1188,0,1320,0,1320,0,1320,0,1452,0,1452
     DC.W 0,1584,0,1584,0,1716,0,1716,0,1848,0,1848,0,1980,0,1980,8,0,8,0,8,132,8,264,8,264,8,396,8,396,8,528
     DC.W 8,528,8,660,8,660,8,792,8,924,8,924,8,1056,8,1056,8,1188,8,1320,8,1320,8,1452,8,1452,8,1584,8,1716,8,1716
     DC.W 8,1848,8,1848,8,1980,16,0,16,0,16,132,16,264,16,264,16,396,16,528,16,528,16,660,16,660,16,792,16,924,16,924
     DC.W 16,1056,16,1188,16,1188,16,1320,16,1320,16,1452,16,1584,16,1584,16,1716,16,1716,16,1848,16,1980,16,1980,24,0,24,0,24,132
     DC.W 24,264,24,264,24,396,24,396,24,528,24,528,24,660,24,792,24,792,24,924,24,924,24,1056,24,1056,24,1188,24,1188,24,1320
     DC.W 24,1320,24,1452,24,1452,24,1584,24,1584,24,1716,24,1716,24,1716,24,1848,24,1848,24,1980,24,1980,24,1980,32,0,32,0,32,132
     DC.W 32,132,32,132,32,264,32,264,32,264,32,396,32,396,32,396,32,528,32,528,32,528,32,528,32,660,32,660,32,660,32,660
     DC.W 32,792,32,792,32,792,32,792,32,792,32,792,32,924,32,924,32,924,32,924,32,924,32,924,32,924,32,924,32,924,32,924
     DC.W 32,924,32,924,32,924,32,1056,32,924,32,924,32,924,32,924,32,924,32,924,32,924,32,924,32,924,32,924,32,924,32,924
     DC.W 32,924,32,792,32,792,32,792,32,792,32,792,32,792,32,660,32,660,32,660,32,660,32,528,32,528,32,528,32,528,32,396
     DC.W 32,396,32,396,32,264,32,264,32,264,32,132,32,132,32,132,32,0,32,0,24,1980,24,1980,24,1980,24,1848,24,1848,24,1716
     DC.W 24,1716,24,1716,24,1584,24,1584,24,1452,24,1452,24,1320,24,1320,24,1188,24,1188,24,1056,24,1056,24,924,24,924,24,792,24,792
     DC.W 24,660,24,528,24,528,24,396,24,396,24,264,24,264,24,132,24,0,24,0,16,1980,16,1980,16,1848,16,1716,16,1716,16,1584
     DC.W 16,1584,16,1452,16,1320,16,1320,16,1188,16,1188,16,1056,16,924,16,924,16,792,16,660,16,660,16,528,16,528,16,396,16,264
     DC.W 16,264,16,132,16,0,16,0,8,1980,8,1848,8,1848,8,1716,8,1716,8,1584,8,1452,8,1452,8,1320,8,1320,8,1188,8,1056
     DC.W 8,1056,8,924,8,924,8,792,8,660,8,660,8,528,8,528,8,396,8,396,8,264,8,264,8,132,8,0,8,0,0,1980
     DC.W 0,1980,0,1848,0,1848,0,1716,0,1716,0,1584,0,1584,0,1452,0,1452,0,1320,0,1320,0,1320,0,1188,0,1188,0,1056,0,1056
     DC.W 0,1056,0,924,0,924,0,792,0,792,0,792,0,660,0,660,0,660,0,528,0,528,0,528,0,396,0,396,0,396,0,396
     DC.W 0,264,0,264,0,264,0,264,0,132,0,132,0,132,0,132,0,132,0,132,0,0,0,0,0,0,0,0,0,0,0,0
     DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
     DC.W 0,0,0,0,0,0,0,0,0,0,0,132,0,132,0,132,0,132,0,132,0,132,0,264,0,264,0,264,0,264,0,396
     DC.W 0,396,0,396,0,396,0,528,0,528,0,528,0,660,0,660,0,660,0,792,0,792,0,792,0,924,0,924,0,1056,0,1056
     DC.W 0,1056,0,1188,0,1188,0,1320,0,1320,0,1320,0,1452,0,1452,0,1584,0,1584,0,1716,0,1716,0,1848,0,1848,0,1980,0,1980
     DC.W 8,0,8,0,8,132,8,264,8,264,8,396,8,396,8,528,8,528,8,660,8,660,8,792,8,924,8,924,8,1056,8,1056
     DC.W 8,1188,8,1320,8,1320,8,1452,8,1452,8,1584,8,1716,8,1716,8,1848,8,1848,8,1980,16,0,16,0,16,132,16,264,16,264
     DC.W 16,396,16,528,16,528,16,660,16,660,16,792,16,924,16,924,16,1056,16,1188,16,1188,16,1320,16,1320,16,1584,16,1716,16,1848
     DC.W 16,1980,24,0,24,132,24,264,24,396,24,396,24,528,24,528,24,528,24,528,24,528,24,528,24,528,24,396,24,396,24,264
     DC.W 24,132,24,0,16,1980,16,1716,16,1584,16,1452,16,1188,16,1056,16,792,16,528,16,396,16,132,8,1980,8,1848,8,1584,8,1452
     DC.W 8,1188,8,1056,8,924,8,792,8,660,8,528,8,396,8,264,8,264,8,132,8,132,8,132,8,0,8,132,8,132,8,132
     DC.W 8,132,8,264,8,264,8,396,8,528,8,660,8,792,8,924,8,1056,8,1188,8,1320,8,1452,8,1584,8,1716,8,1848,8,1980
     DC.W 16,0,16,132,16,264,16,264,16,396,16,528,16,528,16,660,16,792,16,792,16,792,16,924,16,924,16,924,16,924,16,924
     DC.W 16,924,16,924,16,924,16,1056,16,1056,16,1056,16,1056,16,1056,16,1056,16,1056,16,1056,16,1056,16,1056,16,1056,16,1188,16,1188
     DC.W 16,1188,16,1320,16,1320,16,1452,16,1584,16,1584,16,1716,16,1848,16,1980,24,0,24,132,24,264,24,396,24,528,24,660,24,792
     DC.W 24,924,24,924,24,1056,24,1188,24,1320,24,1320,24,1452,24,1452,24,1584,24,1584,24,1584,24,1584,24,1584,24,1584,24,1584,24,1452
     DC.W 24,1452,24,1320,24,1188,24,1056,24,924,24,792,24,660,24,528,24,264,24,132,16,1980,16,1848,16,1584,16,1452,16,1188,16,1056
     DC.W 16,792,16,528,16,396,16,264,16,0,8,1980,8,1848,8,1716,8,1584,8,1452,8,1320,8,1320,8,1320,8,1188,8,1188,8,1188
     DC.W 8,1188,8,1320,8,1320,8,1452,8,1584,8,1584,8,1716,8,1848,16,0,16,132,16,264,16,396,16,660,16,792,16,1056,16,1188
     DC.W 16,1320,16,1584,16,1716,16,1848,16,1980,24,0,24,132,24,264,24,396,24,396,24,528,24,528,24,528,24,528,24,528,24,528
     DC.W 24,528,24,396,24,396,24,264,24,132,24,0,16,1980,16,1716,16,1584,16,1452,16,1188,16,1056,16,792,16,528,16,396,16,132
     DC.W 8,1980,8,1848,8,1584,8,1452,8,1188,8,1056,8,924,8,792,8,660,8,528,8,396,8,264,8,264,8,132,8,132,8,132
     DC.W 8,0,8,132,8,132,8,132,8,132,8,264,8,264,8,396,8,528,8,660,8,792,8,924,8,1056,8,1188,8,1320,8,1452
     DC.W 8,1584,8,1716,8,1848,8,1980,16,0,16,132,16,264,16,264,16,396,16,528,16,528,16,660,16,792,16,792,16,792,16,924
     DC.W 16,924,16,924,16,924,16,924,16,924,16,924,16,924,16,1056,16,1056,16,1056,16,1056,16,1056,16,1056,16,1056,16,1056,16,1056
     DC.W 16,1056,16,1056,16,1188,16,1188,16,1188,16,1320,16,1320,16,1452,16,1584,16,1584,16,1716,16,1848,16,1980,24,0,24,132,24,264
     DC.W 24,396,24,528,24,660,24,792,24,924,24,924,24,1056,24,1188,24,1320,24,1320,24,1452,24,1452,24,1584,24,1584,24,1584,24,1584
     DC.W 24,1584,24,1584,24,1584,24,1452,24,1452,24,1320,24,1188,24,1056,24,924,24,792,24,660,24,528,24,264,24,132,16,1980,16,1848
     DC.W 16,1584,16,1452,16,1188,16,1056,16,792,16,528,16,396,16,264,16,0,8,1980,8,1848,8,1716,8,1584,8,1452,8,1320,8,1320
     DC.W 8,1320,8,1188,8,1188,8,1188,8,1188,8,1320,8,1320,8,1452,8,1584,8,1584,8,1716,8,1848,16,0,16,132,16,264,16,396
     DC.W 16,660,16,792,16,1056,16,1188,16,1320,16,1584,16,1716,16,1848,16,1980,24,0,24,132,24,264,24,396,24,396,24,528,24,528
     DC.W 24,528,24,528,24,528,24,528,24,528,24,396,24,396,24,264,24,132,24,0,16,1980,16,1716,16,1584,16,1452,16,1188,16,1056
     DC.W 16,792,16,528,16,396,16,132,8,1980,8,1848,8,1584,8,1452,8,1188,8,1056,8,924,8,792,8,660,8,528,8,396,8,264
     DC.W 8,264,8,132,8,132,8,132,8,0,8,132,8,132,8,132,8,132,8,264,8,264,8,396,8,528,8,660,8,792,8,924
     DC.W 8,1056,8,1188,8,1320,8,1452,8,1584,8,1716,8,1848,8,1980,16,0,16,132,16,264,16,264,16,396,16,528,16,528,16,660
     DC.W 16,792,16,792,16,792,16,924,16,924,16,924,16,924,16,924,16,924,16,924,16,924,16,1056,16,1056,16,1056,16,1056,16,1056
     DC.W 16,1056,16,1056,16,1056,16,1056,16,1056,16,1056,16,1188,16,1188,16,1188,16,1320,16,1320,16,1452,16,1584,16,1584,16,1716,16,1848
     DC.W 16,1980,24,0,24,132,24,264,24,396,24,528,24,660,24,792,24,924,24,924,24,1056,24,1188,24,1320,24,1320,24,1452,24,1452
     DC.W 24,1584,24,1584,24,1584,24,1584,24,1584,24,1584,24,1584,24,1452,24,1452,24,1320,24,1188,24,1056,24,924,24,792,24,660,24,528
     DC.W 24,264,24,132,16,1980,16,1848,16,1584,16,1452,16,1188,16,1056,16,792,16,528,16,396,16,264,16,0,8,1980,8,1848,8,1716
     DC.W 8,1584,8,1452,8,1320,8,1320,8,1320,8,1188,8,1188,8,1188,8,1188,8,1320,8,1320,8,1452,8,1584,8,1584,8,1716,8,1848
     DC.W 16,0,16,132,16,264,16,396,16,660,16,792,16,1056,16,1188,16,1320,16,1584,16,1716,16,1848,16,1980,24,0,24,132,24,264
     DC.W 24,396,24,396,24,528,24,528,24,528,24,528,24,528,24,528,24,528,24,396,24,396,24,264,24,132,24,0,16,1980,16,1716
     DC.W 16,1584,16,1452,16,1188,16,1056,16,792,16,528,16,396,16,132,8,1980,8,1848,8,1584,8,1452,8,1188,8,1056,8,924,8,792
     DC.W 8,660,8,528,8,396,8,264,8,264,8,132,8,132,8,132,8,0,8,132,8,132,8,132,8,132,8,264,8,264,8,396
     DC.W 8,528,8,660,8,792,8,924,8,1056,8,1188,8,1320,8,1452,8,1584,8,1716,8,1848,8,1980,16,0,16,132,16,264,16,264
     DC.W 16,396,16,528,16,528,16,660,16,792,16,792,16,792,16,924,16,924,16,924,16,924,16,924,16,924,16,924,16,924,16,1056
     DC.W 16,1056,16,1056,16,1056,16,1056,16,1056,16,1056,16,1056,16,1056,16,1056,16,1056,16,1188,16,1188,16,1188,16,1320,16,1320,16,1452
     DC.W 16,1584,16,1584,16,1716,16,1848,16,1980,24,0,24,132,24,264,24,396,24,528,24,660,24,792,24,924,24,924,24,1056,24,1188
     DC.W 24,1320,24,1320,24,1452,24,1452,24,1584,24,1584,24,1584,24,1584,24,1584,24,1584,24,1584,24,1452,24,1452,24,1320,24,1188,24,1056
     DC.W 24,924,24,792,24,660,24,528,24,264,24,132,16,1980,16,1848,16,1584,16,1452,16,1188,16,1056,16,792,16,528,16,396,16,264
     DC.W 16,0,8,1980,8,1848,8,1716,8,1584,8,1452,8,1320,8,1320,8,1320,8,1188,8,1188,8,1188,8,1188,8,1320,8,1320,8,1452
     DC.W 8,1584,8,1584,8,1716,8,1848,16,0,16,132,16,264,16,396,16,660,16,792,16,1056,16,1188,16,1320,16,1320,16,1188,16,1056
     DC.W 16,924,16,792,16,660,16,528,16,396,16,264,16,132,16,0,8,1980,8,1848,8,1716,8,1584,8,1452,8,1320,8,1188,8,1056
     DC.W 8,924,8,792,8,660,8,528,8,396,8,264,8,132,8,0,0,1980,0,1848,0,1716,0,1584,0,1452,0,1320,0,1320,0,1320
     DC.W 0,1320,0,1320,0,1320,0,1320,0,1320,0,1320,0,1320,0,1320,0,1320,0,1320,0,1452,0,1584,0,1848,8,0,8,396,8,792
     DC.W 8,1056,8,1452,8,1848,16,0,16,396,16,660,16,792,16,1056,16,1056,16,1188,16,1320,16,1320,16,1320,16,1320,16,1320,16,1320
     DC.W 16,1320,16,1320,16,1452,16,1584,16,1716,16,1980,24,132,24,396,24,792,24,1188,24,1584,24,1980,32,396,32,792,32,1188,32,1452
     DC.W 32,1716,32,1980,40,0,40,0,40,0,32,1980,32,1848,32,1584,32,1188,32,792,32,396,32,0,24,1584,24,1056,24,660,24,132
     DC.W 16,1848,16,1584,16,1320,16,1056,16,792,16,792,16,660,16,660,16,792,16,792,16,924,16,1056,16,1320,16,1452,16,1584,16,1584
     DC.W 16,1716,16,1716,16,1716,16,1716,16,1584,16,1452,16,1320,16,1056,16,792,16,660,16,396,16,264,16,132,16,0,8,1980,8,1980
     DC.W 8,1980,16,0,16,132,16,396,16,660,16,924,16,1320,16,1584,16,1980,24,264,24,528,24,924,24,1188,24,1320,24,1452,24,1584
     DC.W 24,1584,24,1584,24,1320,24,1188,24,924,24,660,24,264,16,1980,16,1584,16,1320,16,924,16,528,16,264,16,0,8,1980,8,1848
     DC.W 8,1716,8,1716,8,1848,8,1980,16,0,16,132,16,396,16,660,16,792,16,1056,16,1320,16,1452,16,1584,16,1584,16,1584,16,1584
     DC.W 16,1584,16,1452,16,1320,16,1056,16,792,16,660,16,396,16,132,8,1980,8,1848,8,1716,8,1584,8,1584,8,1584,8,1716,8,1848
     DC.W 8,1980,16,0,16,264,16,528,16,792,16,1056,16,1320,16,1452,16,1584,16,1716,16,1716,16,1716,16,1584,16,1452,16,1320,16,924
     DC.W 16,660,16,264,8,1980,8,1584,8,1056,8,660,8,264,8,0,0,1848,0,1584,0,1320,0,1320,0,1320,0,1320,0,1452,0,1584
     DC.W 0,1848,8,0,8,396,8,792,8,1056,8,1452,8,1848,16,0,16,396,16,660,16,792,16,1056,16,1056,16,1188,16,1320,16,1320
     DC.W 16,1320,16,1320,16,1320,16,1320,16,1320,16,1320,16,1452,16,1584,16,1716,16,1980,24,132,24,396,24,792,24,1188,24,1584,24,1980
     DC.W 32,396,32,792,32,1188,32,1452,32,1716,32,1980,40,0,40,0,40,0,32,1980,32,1848,32,1584,32,1188,32,792,32,396,32,0
     DC.W 24,1584,24,1056,24,660,24,132,16,1848,16,1584,16,1320,16,1056,16,792,16,792,16,660,16,660,16,792,16,792,16,924,16,1056
     DC.W 16,1320,16,1452,16,1584,16,1584,16,1716,16,1716,16,1716,16,1716,16,1584,16,1452,16,1320,16,1056,16,792,16,660,16,396,16,264
     DC.W 16,132,16,0,8,1980,8,1980,8,1980,16,0,16,132,16,396,16,660,16,924,16,1320,16,1584,16,1980,24,264,24,528,24,924
     DC.W 24,1188,24,1320,24,1452,24,1584,24,1584,24,1584,24,1320,24,1188,24,924,24,660,24,264,16,1980,16,1584,16,1320,16,924,16,528
     DC.W 16,264,16,0,8,1980,8,1848,8,1716,8,1716,8,1848,8,1980,16,0,16,132,16,396,16,660,16,792,16,1056,16,1320,16,1452
     DC.W 16,1584,16,1584,16,1584,16,1584,16,1584,16,1452,16,1320,16,1056,16,792,16,660,16,396,16,132,8,1980,8,1848,8,1716,8,1584
     DC.W 8,1584,8,1584,8,1716,8,1848,8,1980,16,0,16,264,16,528,16,792,16,1056,16,1320,16,1452,16,1584,16,1716,16,1716,16,1716
     DC.W 16,1584,16,1452,16,1320,16,924,16,660,16,264,8,1980,8,1584,8,1056,8,660,8,264,8,0,0,1848,0,1584,0,1320,0,1320
     DC.W 0,1320,0,1320,0,1452,0,1584,0,1848,8,0,8,396,8,792,8,1056,8,1452,8,1848,16,0,16,396,16,660,16,792,16,1056
     DC.W 16,1056,16,1188,16,1320,16,1320,16,1320,16,1320,16,1320,16,1320,16,1320,16,1320,16,1452,16,1584,16,1716,16,1980,24,132,24,396
     DC.W 24,792,24,1188,24,1584,24,1980,32,396,32,792,32,1188,32,1452,32,1716,32,1980,40,0,40,0,40,0,32,1980,32,1848,32,1584
     DC.W 32,1188,32,792,32,396,32,0,24,1584,24,1056,24,660,24,132,16,1848,16,1584,16,1320,16,1056,16,792,16,792,16,660,16,660
     DC.W 16,792,16,792,16,924,16,1056,16,1320,16,1452,16,1584,16,1584,16,1716,16,1716,16,1716,16,1716,16,1584,16,1452,16,1320,16,1056
     DC.W 16,792,16,660,16,396,16,264,16,132,16,0,8,1980,8,1980,8,1980,16,0,16,132,16,396,16,660,16,924,16,1320,16,1584
     DC.W 16,1980,24,264,24,528,24,924,24,1188,24,1320,24,1452,24,1584,24,1584,24,1584,24,1320,24,1188,24,924,24,660,24,264,16,1980
     DC.W 16,1584,16,1320,16,924,16,528,16,264,16,0,8,1980,8,1848,8,1716,8,1716,8,1848,8,1980,16,0,16,132,16,396,16,660
     DC.W 16,792,16,1056,16,1320,16,1452,16,1584,16,1584,16,1584,16,1584,16,1584,16,1452,16,1320,16,1056,16,792,16,660,16,396,16,132
     DC.W 8,1980,8,1848,8,1716,8,1584,8,1584,8,1584,8,1716,8,1848,8,1980,16,0,16,264,16,528,16,792,16,1056,16,1320,16,1452
     DC.W 16,1584,16,1716,16,1716,16,1716,16,1584,16,1452,16,1320,16,924,16,660,16,264,8,1980,8,1584,8,1056,8,660,8,264,8,0
     DC.W 0,1848,0,1584,0,1320,0,1320,0,1320,0,1320,0,1452,0,1584,0,1848,8,0,8,396,8,792,8,1056,8,1452,8,1848,16,0
     DC.W 16,396,16,660,16,792,16,1056,16,1056,16,1188,16,1320,16,1320,16,1320,16,1320,16,1320,16,1320,16,1320,16,1320,16,1452,16,1584
     DC.W 16,1716,16,1980,24,132,24,396,24,792,24,1188,24,1584,24,1980,32,396,32,792,32,1188,32,1452,32,1716,32,1980,40,0,40,0
     DC.W 40,0,32,1980,32,1848,32,1584,32,1188,32,792,32,396,32,0,24,1584,24,1056,24,660,24,132,16,1848,16,1584,16,1320,16,1056
     DC.W 16,792,16,792,16,660,16,660,16,792,16,792,16,924,16,1056,16,1320,16,1452,16,1584,16,1584,16,1716,16,1716,16,1716,16,1716
     DC.W 16,1584,16,1452,16,1320,16,1056,16,792,16,660,16,396,16,264,16,132,16,0,8,1980,8,1980,8,1980,16,0,16,132,16,396
     DC.W 16,660,16,924,16,1320,16,1584,16,1980,24,264,24,528,24,924,24,1188,24,1320,24,1452,24,1584,24,1584,24,1584,24,1320,24,1188
     DC.W 24,924,24,660,24,264,16,1980,16,1584,16,1320,16,924,16,528,16,264,16,0,8,1980,8,1848,8,1716,8,1716,8,1848,8,1980
     DC.W 16,0,16,132,16,396,16,660,16,792,16,1056,16,1320,16,1452,16,1584,16,1584,16,1584,16,1584,16,1584,16,1452,16,1320,16,1056
     DC.W 16,792,16,660,16,396,16,132,8,1980,8,1848,8,1716,8,1584,8,1584,8,1584,8,1716,8,1848,8,1980,16,0,16,264,16,528
     DC.W 16,792,16,1056,16,1320,16,1452,16,1584,16,1716,16,1716,16,1716,16,1584,16,1452,16,1320,16,924,16,660,16,264,8,1980,8,1584
     DC.W 8,1056,8,660,8,264,8,0,0,1848,0,1584,0,1320,0,1320,0,1452,0,1584,0,1716,0,1848,0,1980,8,0,8,132,8,264
     DC.W 8,396,8,528,8,660,8,792,8,924,8,1056,8,1188,8,1320,8,1452,8,1584,8,1716,8,1848,8,1980,16,0,16,132,16,264
     DC.W 16,396,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528
     DC.W 16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528
     DC.W 16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528,16,528   
     
COURBE_FUZ_END:
	even
REBOND	



     DC.l 0,0,0,0,32,64,64,96,160,192,256,288,352,416,480,576,640,736,800,896,1024,1120,1216,1344,1472,1568,1728,1856,1984,2144,2272,2432
     DC.l 2592,2784,2944,3104,3136,2944,2784,2592,2432,2304,2144,1984,1856,1728,1600,1472,1344,1216,1120,1024,896,800,736,640,576,480,416,352,288,256,192,160
     DC.l 96,64,64,32,0,0,0,0

REBOND_END:

	
	EVEN

TERM		DC.B	0

	*********en premier on met la ligne puis, le decalage en octects:8,16,32
	****et on met son texte,qd on veut changer de ligne->1 pour conclure->0
	even	

TEXTE:
	dc.b	120,0,"                    ",1
	dc.b	56,0,"SALUT INTRO FINISH.",1
	DC.B	78,0,"HELLO EVERYBODY 123",1
	DC.B	100,0,"FUCK OFF:MAN!,?",1
	DC.B	122,0,"WHAT CAN I SAY?",1
	DC.B	144,0,"CD-200....",1
	dc.b	56,0,"                    ",1
	DC.B	78,0,"                    ",1
	DC.B	100,0,"                ",1
	DC.B	122,0,"                ",1
	DC.B	144,0,"                ",0
	
	
	
	
	
texte_end:
	
	
	
	EVEN
	****table 1=new ligne suivit du numero de ligne et de tous les caracteres
	****de cette ligne  0=fin
	
TABLE:
	DC.B	1,93,"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T"
	DC.B	1,110,"U","V","W","X","Y","Z","!","?",".",":","0","1","2","3","4","5","6","7","8","9"
	dc.b	1,127,"-",","," ",0
	even
		
	***courbe de rastering pour le motif du fond
	***creation in gfa	

COURBE:

     DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
     DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
     DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
     DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
     DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
     DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
     DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
     DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
     DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
     DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
     DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
     DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
     DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,10,12,14,0,2,4,4,6,8,10,12,14,0
     DC.B 2,2,4,6,8,10,12,14,14,0,2,4,6,8,10,10,12,14,0,2,4,4,6,8,10,12,14,14,0,2,4,6
     DC.B 6,8,10,12,14,14,0,2,4,4,6,8,10,12,12,14,0,0,2,4,6,6,8,10,12,12,14,0,0,2,4,4
     DC.B 6,8,8,10,12,12,14,0,0,2,4,4,6,6,8,10,10,12,12,14,0,0,2,2,4,4,6,6,8,8,10,10
     DC.B 12,12,14,14,0,0,2,2,4,4,6,6,6,8,8,10,10,10,12,12,12,14,14,0,0,0,2,2,2,2,4,4
     DC.B 4,6,6,6,6,8,8,8,8,10,10,10,10,10,10,12,12,12,12,12,12,14,14,14,14,14,14,14,14,14,14,14
     DC.B 14,14,14,14,14,0,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,12,12,12,12,12,12,10,10,10,10
     DC.B 10,10,8,8,8,8,6,6,6,6,4,4,4,2,2,2,2,0,0,0,14,14,12,12,12,10,10,10,8,8,6,6
     DC.B 6,4,4,2,2,0,0,14,14,12,12,10,10,8,8,6,6,4,4,2,2,0,0,14,12,12,10,10,8,6,6,4
     DC.B 4,2,0,0,14,12,12,10,8,8,6,4,4,2,0,0,14,12,12,10,8,6,6,4,2,0,0,14,12,12,10,8
     DC.B 6,4,4,2,0,14,14,12,10,8,6,6,4,2,0,14,14,12,10,8,6,4,4,2,0,14,12,10,10,8,6,4
     DC.B 2,0,14,14,12,10,8,6,4,2,2,0,14,12,10,8,6,4,4,2,0,14,12,10,8,8,6,4,2,0,14,12
     DC.B 10,10,8,6,4,2,0,14,12,12,10,8,6,4,2,0,0,14,12,10,8,6,4,4,2,0,14,12,10,10,8,6
     DC.B 4,2,0,0,14,12,10,8,8,6,4,2,0,0,14,12,10,10,8,6,4,4,2,0,14,14,12,10,8,8,6,4
     DC.B 2,2,0,14,14,12,10,10,8,6,6,4,2,2,0,14,14,12,10,10,8,8,6,4,4,2,2,0,14,14,12,12
     DC.B 10,10,8,8,6,6,4,4,2,2,0,0,14,14,12,12,10,10,8,8,8,6,6,4,4,4,2,2,2,0,0,14
     DC.B 14,14,12,12,12,12,10,10,10,8,8,8,8,6,6,6,6,4,4,4,4,4,4,2,2,2,2,2,2,0,0,0
     DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2
     DC.B 2,2,2,2,4,4,4,4,4,4,6,6,6,6,8,8,8,8,10,10,10,12,12,12,12,14,14,14,0,0,2,2
     DC.B 2,4,4,4,6,6,8,8,8,10,10,12,12,14,14,0,0,2,2,4,4,6,6,8,8,10,10,12,12,14,14,0
     DC.B 2,2,4,4,6,8,8,10,10,12,14,14,0,2,2,4,6,6,8,10,10,12,14,14,0,2,2,4,6,8,8,10
     DC.B 12,14,14,0,2,4,4,6,8,10,10,12,14,0,0,2,4,6,8,8,10,12,14,0,0,2,4,6,8,10,10,12
     DC.B 14,0,2,4,4,6,8,10,12,14,0,0,2,4,6,8,10,12,12,14,0,2,4,6,8,10,10,12,14,0,2,4
     DC.B 6,8,8,10,14,2,4,8,12,14,2,4,8,10,12,0,2,4,6,8,8,10,12,12,12,14,14,14,12,12,12,10
     DC.B 10,8,6,4,0,14,12,8,4,2,14,10,4,0,12,8,2,12,8,2,12,6,0,10,6,14,8,2,12,6,0,10
     DC.B 4,14,8,2,12,8,2,12,8,2,14,8,4,0,12,8,4,0,14,12,8,6,4,2,2,0,0,0,0,0,0,0
     DC.B 2,2,4,6,8,12,14,0,4,8,12,0,4,8,14,2,8,12,2,8,12,2,8,14,4,10,0,6,12,2,8,14
     DC.B 6,10,0,6,12,2,8,12,2,8,12,0,4,10,14,2,4,8,12,14,0,4,6,8,10,10,12,12,12,14,14,14
     DC.B 12,12,12,10,8,8,6,4,2,0,12,10,8,4,2,14,12,8,4,2,14,10,8,4,0,12,10,6,2,0,12,10
     DC.B 6,4,2,14,12,10,8,6,6,4,2,2,2,0,0,0,2,2,2,4,6,6,8,10,14,0,2,6,10,12,0,4
     DC.B 10,14,2,8,12,2,6,12,2,8,14,4,8,0,6,12,2,8,14,4,10,0,6,12,2,6,12,2,6,12,0,6
     DC.B 10,14,2,6,10,14,0,2,6,8,10,12,12,14,14,14,0,14,14,14,12,12,10,8,6,2,0,14,10,6,2,14
     DC.B 10,6,0,12,6,2,12,6,2,12,6,0,10,4,14,8,2,12,6,0,8,4,14,8,2,12,6,2,12,8,2,14
     DC.B 10,4,0,12,10,6,2,0,14,10,8,6,6,4,2,2,2,0,0,0,2,2,2,4,6,6,8,10,12,14,2,4
     DC.B 6,10,12,0,2,6,10,12,0,4,8,10,14,2,4,8,12,14,2,4,8,10,12,0,2,4,6,8,8,10,12,12
     DC.B 12,14,14,14,12,12,12,10,10,8,6,4,0,14,12,8,4,2,14,10,4,0,12,8,2,12,8,2,12,6,0,10
     DC.B 6,14,8,2,12,6,0,10,4,14,8,2,12,8,2,12,8,2,14,8,4,0,12,8,4,0,14,12,8,6,4,2
     DC.B 2,0,0,0,0,0,0,0,2,2,4,6,8,12,14,0,4,8,12,0,4,8,14,2,8,12,2,8,12,2,8,14
     DC.B 4,10,0,6,12,2,8,14,6,10,0,6,12,2,8,12,2,8,12,0,4,10,14,2,4,8,12,14,0,4,6,8
     DC.B 10,10,12,12,12,14,14,14,12,12,12,10,8,8,6,4,2,0,12,10,8,4,2,14,12,8,4,2,14,10,8,4
     DC.B 0,12,10,6,2,0,12,10,6,4,2,14,12,10,8,6,6,4,2,2,2,0,0,0,2,2,2,4,6,6,8,10
     DC.B 14,0,2,6,10,12,0,4,10,14,2,8,12,2,6,12,2,8,14,4,8,0,6,12,2,8,14,4,10,0,6,12
     DC.B 2,6,12,2,6,12,0,6,10,14,2,6,10,14,0,2,6,8,10,12,12,14,14,14,0,14,14,14,12,12,10,8
     DC.B 6,2,0,14,10,6,2,14,10,6,0,12,6,2,12,6,2,12,6,0,10,4,14,8,2,12,6,0,8,4,14,8
     DC.B 2,12,6,2,12,8,2,14,10,4,0,12,10,6,2,0,14,10,8,6,6,4,2,2,2,0,0,0,2,2,2,4
     DC.B 6,6,8,10,12,14,2,4,6,10,12,0,2,6,10,12,0,4,8,4,6,8,10,12,14,0,2,4,6,8,10,12
     DC.B 14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12
     DC.B 14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12
     DC.B 14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12
     DC.B 14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12
     DC.B 14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12
     DC.B 14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12
     DC.B 14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12
     DC.B 14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12
     DC.B 14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12
     DC.B 14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12
     DC.B 14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12
     DC.B 14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12
     DC.B 14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12
     DC.B 14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12
     DC.B 14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12
     DC.B 14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12
     DC.B 14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12
     DC.B 14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12
     DC.B 14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12
     DC.B 14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12
     DC.B 14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12
     DC.B 14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12,14,0,2,4,6,8,10,12
     DC.B 14,0,2,4,12,4,14,8,2,12,6,0,8,14,2,4,6,8,8,8,8,8,10,12,2,8,0,10,4,0,10,6
     DC.B 0,10,0,6,8,8,4,14,6,12,0,4,8,12,0,6,14,8,2,0,0,0,2,4,8,10,12,12,10,8,4,0
     DC.B 10,2,12,4,14,8,4,2,2,4,10,0,8,2,12,8,2,10,4,10,14,0,14,12,6,0,8,0,8,14,8,0
     DC.B 12,10,8,10,12,0,4,10,14,2,6,8,8,8,4,0,10,2,10,4,12,6,2,14,14,0,4,8,0,10,4,14
     DC.B 8,0,8,14,2,4,4,0,12,6,14,8,0,8,2,12,10,8,8,12,0,6,12,4,10,2,6,12,14,0,0,12
     DC.B 10,6,0,12,8,4,2,2,4,8,14,4,14,10,4,0,12,6,14,6,10,12,10,8,2,10,0,6,12,2,8,14
     DC.B 6,0,12,10,8,6,6,8,8,6,4,2,12,6,14,4,10,14,4,8,14,4,14,8,6,6,10,0,8,2,14,10
     DC.B 6,2,14,8,0,8,12,14,14,14,12,10,8,4,2,2,4,6,10,14,4,12,2,10,0,6,10,12,12,10,4,14
     DC.B 6,12,2,8,12,4,10,4,0,14,0,2,8,14,6,14,8,0,6,14,2,4,6,4,2,14,10,4,0,12,8,6
     DC.B 6,8,10,14,4,12,4,10,2,8,12,0,0,14,10,6,14,4,10,0,8,14,6,0,12,10,10,14,2,8,0,8
     DC.B 14,6,12,2,4,6,6,2,14,8,2,10,4,12,8,2,0,14,14,2,4,8,14,2,8,10,12,12,10,8,0,10
     DC.B 0,4,10,14,2,8,0,8,4,2,4,6,12,4,14,8,2,12,6,0,8,14,2,4,6,8,8,8,8,8,10,12
     DC.B 2,8,0,10,4,0,10,6,0,10,0,6,8,8,4,14,6,12,0,4,8,12,0,6,14,8,2,0,0,0,2,4
     DC.B 8,10,12,12,10,8,4,0,10,2,12,4,14,8,4,2,2,4,10,0,8,2,12,8,2,10,4,10,14,0,14,12
     DC.B 6,0,8,0,8,14,8,0,12,10,8,10,12,0,4,10,14,2,6,8,8,8,4,0,10,2,10,4,12,6,2,14
     DC.B 14,0,4,8,0,10,4,14,8,0,8,14,2,4,4,0,12,6,14,8,0,8,2,12,10,8,8,12,0,6,12,4
     DC.B 10,2,6,12,14,0,0,12,10,6,0,12,8,4,2,2,4,8,14,4,14,10,4,0,12,6,14,6,10,12,10,8
     DC.B 2,10,0,6,12,2,8,14,6,0,12,10,8,6,6,8,8,6,4,2,12,6,14,4,10,14,4,8,14,4,14,8
     DC.B 6,6,10,0,8,2,14,10,6,2,14,8,0,8,12,14,14,14,12,10,8,4,2,2,4,6,10,14,4,12,2,10
     DC.B 0,6,10,12,12,10,4,14,6,12,2,8,12,4,10,4,0,14,0,2,8,14,6,14,8,0,6,14,2,4,6,4
     DC.B 2,14,10,4,0,12,8,6,6,8,10,14,4,12,4,10,2,8,12,0,0,14,10,6,14,4,10,0,8,14,6,0
     DC.B 12,10,10,14,2,8,0,8,14,6,12,2,4,6,6,2,14,8,2,10,4,12,8,2,0,14,14,2,4,8,14,2
     DC.B 8,10,12,12,10,8,0,10,0,4,10,14,2,8,0,8,4,2,4,6,12,0,0,0,0,0,0,0,0,0,0,0
     DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
     DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
     DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
     DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
     DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
     DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

COURBE_END:

	SECTION BSS
	EVEN
		
	
BUFF_SP	DS.B	84000
BUFF_MS	DS.B	84000	

	EVEN
	
CAR_BDS:
	DS.W	8000
	
CAR_END:

        DS.L 40
stack:

SCR	ds.b	SCRSIZ*2
	
	END
