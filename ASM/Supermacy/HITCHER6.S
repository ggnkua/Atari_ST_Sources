COUL_0  EQU     $FF8240
        SECTION TEXT

        MOVE.L  #0,-(SP)                * SI MODE VAUT 0-> PASSAGE EN SUPERVISEUR
        MOVE.W  #$20,-(SP)              * SI MODE= ANCIENNE USP -> UTILISATEUR
        TRAP    #1                      * EN SORTIE:
        ADDQ.L  #6,SP                   * RENVOIE ANCIENNE USP (A SAUVEGARDER)
        MOVE.L  D0,SAUVE

        move.w  #$12,d0
        bsr     send_cmd
        move.w  #$15,d0
        bsr     send_cmd
	
        move.w  #2,-(sp)
        trap    #14
        addq    #2,sp
        move.l  d0,ecran2
	move.l  d0,ECRAN1
        MOVE.W  #0,-(SP)                * BASSE RESOLUTION
        MOVE.L  #-1,-(SP)               * PHYSBASE A ECRAN1
        MOVE.L  #-1,-(SP)               * LOGBASE A ECRAN1
        MOVE.W  #5,-(SP)                * FONCTION SETSCREEN
        TRAP    #14                     * DU XBIOS
        LEA     12(SP),SP
	
	
	PEA PI1+2
	MOVE.W #6,-(SP)
	TRAP #14
	ADDQ.L #6,SP	        
        
        MOVE.L  #7999,D0
	MOVE.L  #PI1+34,A0
        MOVE.L  ECRAN1,A1
CLS     MOVE.L  (A0)+,(A1)+
        DBF     D0,CLS
	
	MOVEQ #1,D0
	MOVE.L #ZIK+$8,$4D2.W
	JSR ZIK
        MOVE.L #MES_A,MES_PNT           * MESSAGE EN ANGLAIS EN PREMIER
        BSR SPACE
        MOVE.B  #4,NB_BIT
	
	  
BOUCLE: 
        MOVE.W  #37,-(SP)
        TRAP    #14                     * VSYNC
        ADDQ.L  #2,SP
        BSR     SCR_TXT
	cmp.b	#$3b,$fffc02	*TOUCHE F1
	bne	f2
	LEA	FILE1,A2
	LEA	FILE,A3
EN	MOVE.B	(A2)+,(A3)+
	CMP.B	#'{',(A2)
	BNE	EN
	BRA	FIN
f2	cmp.b	#$3c,$fffc02	*TOUCHE F2
	bne	f3
	LEA	FILE2,A2
	LEA	FILE,A3
EN1	MOVE.B	(A2)+,(A3)+
	CMP.B	#'{',(A2)
	BNE	EN1
	BRA	FIN
f3	cmp.b	#$3d,$fffc02	*TOUCHE F3
	bne	espace
	LEA	FILE3,A2
	LEA	FILE,A3
EN2	MOVE.B	(A2)+,(A3)+
	CMP.B	#'{',(A2)
	BNE	EN2
	BRA	FIN
espace  CMP.B   #$39,$FFFC02	*TOUCHE ESPACE
        BNE     BOUCLE
       	LEA	FILE4,A2
	LEA	FILE,A3
EN3	MOVE.B	(A2)+,(A3)+
	CMP.B	#'{',(A2)
	BNE	EN3

	BRA	FIN

       	  
        
FIN     MOVE.W  #0,-(SP)                * ANCIENNE RESOLUTION
        MOVE.L  #-1,-(SP)               * ANCIEN ECRAN PHYSIQUE
        MOVE.L  #-1,-(SP)               * ANCIEN ECRAN LOGIQUE
        MOVE.W  #5,-(SP)                * FONCTION SETSCREEN
        TRAP    #14                     * DU XBIOS
        LEA.L   12(SP),SP               * CORRIGE LA PILE
        CLR.L	$4D2.W
        PEA	STOPM_D
        MOVE.W	#$20,-(A7)
        TRAP	#14
        ADDQ.L	#6,A7
        
        
        
        
        MOVE.L  SAUVE,-(SP)             * SI MODE VAUT 0-> PASSAGE EN SUPERVISEUR
        MOVE.W  #$20,-(SP)              * SI MODE= ANCIENNE USP -> UTILISATEUR
        TRAP    #1                      * EN SORTIE:
        ADDQ.L  #6,SP                   * RENVOIE ANCIENNE USP (A SAUVEGARDER)
        BRA	start
        CLR.W   -(SP)                   * FIN DU PROGRAMME
         

SCR_TXT MOVEQ   #32,D0                  * 15 FOIS 2 LIGNES A DECALER
        MOVE.L  #160,D1                 * VALEUR D'INCREMENT (2 LIGNES)
        LEA.L   CAR_BUF,A5              * ADRESSE DU BUFFER CARACTERE
        MOVE.L  ECRAN1,A4               * ADRESSE DE L'ECRAN
        ADDA.L  #160*163,A4
DECAL:
        
PLAN1   MOVE.B  160*0+1(A4),160*0(A4)
        MOVE.B  160*0+8(A4),160*0+1(A4)
        MOVE.B  160*1+9(A4),160*0+8(A4)
        MOVE.B  160*2+16(A4),160*1+9(A4)
        MOVE.B  160*3+17(A4),160*2+16(A4)
        MOVE.B  160*3+24(A4),160*3+17(A4)
        MOVE.B  160*2+25(A4),160*3+24(A4)
        MOVE.B  160*1+32(A4),160*2+25(A4)
        MOVE.B  160*0+33(A4),160*1+32(A4)
        MOVE.B  160*0+40(A4),160*0+33(A4)
        MOVE.B  160*1+41(A4),160*0+40(A4)
        MOVE.B  160*2+48(A4),160*1+41(A4)
        MOVE.B  160*3+49(A4),160*2+48(A4)
        MOVE.B  160*3+56(A4),160*3+49(A4)
        MOVE.B  160*2+57(A4),160*3+56(A4)
        MOVE.B  160*1+64(A4),160*2+57(A4)
        MOVE.B  160*0+65(A4),160*1+64(A4)
        MOVE.B  160*0+72(A4),160*0+65(A4)       
        MOVE.B  160*1+73(A4),160*0+72(A4)
        MOVE.B  160*2+80(A4),160*1+73(A4)
        MOVE.B  160*3+81(A4),160*2+80(A4)
        MOVE.B  160*3+88(A4),160*3+81(A4)
        MOVE.B  160*2+89(A4),160*3+88(A4)
        MOVE.B  160*1+96(A4),160*2+89(A4)
        MOVE.B  160*0+97(A4),160*1+96(A4)
        MOVE.B  160*0+104(A4),160*0+97(A4)
        MOVE.B  160*1+105(A4),160*0+104(A4)
        MOVE.B  160*2+112(A4),160*1+105(A4)
        MOVE.B  160*3+113(A4),160*2+112(A4)
        MOVE.B  160*3+120(A4),160*3+113(A4)
        MOVE.B  160*2+121(A4),160*3+120(A4)
        MOVE.B  160*1+128(A4),160*2+121(A4)
        MOVE.B  160*0+129(A4),160*1+128(A4)
        MOVE.B  160*0+136(A4),160*0+129(A4)
        MOVE.B  160*1+137(A4),160*0+136(A4)
        MOVE.B  160*2+144(A4),160*1+137(A4)
        MOVE.B  160*3+145(A4),160*2+144(A4)
        MOVE.B  160*3+152(A4),160*3+145(A4)
        MOVE.B  160*2+153(A4),160*3+152(A4)
        
        MOVE.B  (A5),160*2+153(A4)      *
        MOVE.B  1(A5),(A5)              * SCROLL LE BUFFER
        MOVE.B  6(A5),1(A5)             * PREMIERS PLANS
        MOVE.B  7(A5),6(A5)             *

PLAN2   MOVE.B  160*0+3(A4),160*0+2(A4)
        MOVE.B  160*0+10(A4),160*0+3(A4)
        MOVE.B  160*1+11(A4),160*0+10(A4)
        MOVE.B  160*2+18(A4),160*1+11(A4)
        MOVE.B  160*3+19(A4),160*2+18(A4)
        MOVE.B  160*3+26(A4),160*3+19(A4)
        MOVE.B  160*2+27(A4),160*3+26(A4)
        MOVE.B  160*1+34(A4),160*2+27(A4)
        MOVE.B  160*0+35(A4),160*1+34(A4)
        MOVE.B  160*0+42(A4),160*0+35(A4)
        MOVE.B  160*1+43(A4),160*0+42(A4)
        MOVE.B  160*2+50(A4),160*1+43(A4)
        MOVE.B  160*3+51(A4),160*2+50(A4)
        MOVE.B  160*3+58(A4),160*3+51(A4)
        MOVE.B  160*2+59(A4),160*3+58(A4)
        MOVE.B  160*1+66(A4),160*2+59(A4)
        MOVE.B  160*0+67(A4),160*1+66(A4)
        MOVE.B  160*0+74(A4),160*0+67(A4)       
        MOVE.B  160*1+75(A4),160*0+74(A4)
        MOVE.B  160*2+82(A4),160*1+75(A4)
        MOVE.B  160*3+83(A4),160*2+82(A4)
        MOVE.B  160*3+90(A4),160*3+83(A4)
        MOVE.B  160*2+91(A4),160*3+90(A4)
        MOVE.B  160*1+98(A4),160*2+91(A4)
        MOVE.B  160*0+99(A4),160*1+98(A4)
        MOVE.B  160*0+106(A4),160*0+99(A4)
        MOVE.B  160*1+107(A4),160*0+106(A4)
        MOVE.B  160*2+114(A4),160*1+107(A4)
        MOVE.B  160*3+115(A4),160*2+114(A4)
        MOVE.B  160*3+122(A4),160*3+115(A4)
        MOVE.B  160*2+123(A4),160*3+122(A4)
        MOVE.B  160*1+130(A4),160*2+123(A4)
        MOVE.B  160*0+131(A4),160*1+130(A4)
        MOVE.B  160*0+138(A4),160*0+131(A4)
        MOVE.B  160*1+139(A4),160*0+138(A4)
        MOVE.B  160*2+146(A4),160*1+139(A4)
        MOVE.B  160*3+147(A4),160*2+146(A4)
        MOVE.B  160*3+154(A4),160*3+147(A4)
        MOVE.B  160*2+155(A4),160*3+154(A4)
        
        MOVE.B  2(A5),160*2+155(A4)     *
        MOVE.B  3(A5),2(A5)             * SCROLL LE BUFFER
        MOVE.B  8(A5),3(A5)             * SECONDS PLANS
        MOVE.B  9(A5),8(A5)             *

PLAN3   MOVE.B  160*0+5(A4),160*0+4(A4)
        MOVE.B  160*0+12(A4),160*0+5(A4)
        MOVE.B  160*1+13(A4),160*0+12(A4)
        MOVE.B  160*2+20(A4),160*1+13(A4)
        MOVE.B  160*3+21(A4),160*2+20(A4)
        MOVE.B  160*3+28(A4),160*3+21(A4)
        MOVE.B  160*2+29(A4),160*3+28(A4)
        MOVE.B  160*1+36(A4),160*2+29(A4)
        MOVE.B  160*0+37(A4),160*1+36(A4)
        MOVE.B  160*0+44(A4),160*0+37(A4)
        MOVE.B  160*1+45(A4),160*0+44(A4)
        MOVE.B  160*2+52(A4),160*1+45(A4)
        MOVE.B  160*3+53(A4),160*2+52(A4)
        MOVE.B  160*3+60(A4),160*3+53(A4)
        MOVE.B  160*2+61(A4),160*3+60(A4)
        MOVE.B  160*1+68(A4),160*2+61(A4)
        MOVE.B  160*0+69(A4),160*1+68(A4)
        MOVE.B  160*0+76(A4),160*0+69(A4)       
        MOVE.B  160*1+77(A4),160*0+76(A4)
        MOVE.B  160*2+84(A4),160*1+77(A4)
        MOVE.B  160*3+85(A4),160*2+84(A4)
        MOVE.B  160*3+92(A4),160*3+85(A4)
        MOVE.B  160*2+93(A4),160*3+92(A4)
        MOVE.B  160*1+100(A4),160*2+93(A4)
        MOVE.B  160*0+101(A4),160*1+100(A4)
        MOVE.B  160*0+108(A4),160*0+101(A4)
        MOVE.B  160*1+109(A4),160*0+108(A4)
        MOVE.B  160*2+116(A4),160*1+109(A4)
        MOVE.B  160*3+117(A4),160*2+116(A4)
        MOVE.B  160*3+124(A4),160*3+117(A4)
        MOVE.B  160*2+125(A4),160*3+124(A4)
        MOVE.B  160*1+132(A4),160*2+125(A4)
        MOVE.B  160*0+133(A4),160*1+132(A4)
        MOVE.B  160*0+140(A4),160*0+133(A4)
        MOVE.B  160*1+141(A4),160*0+140(A4)
        MOVE.B  160*2+148(A4),160*1+141(A4)
        MOVE.B  160*3+149(A4),160*2+148(A4)
        MOVE.B  160*3+156(A4),160*3+149(A4)
        MOVE.B  160*2+157(A4),160*3+156(A4)
        
        MOVE.B  4(A5),160*2+157(A4)     *
        MOVE.B  5(A5),4(A5)             * SCROLL LE BUFFER
        MOVE.B  10(A5),5(A5)            * TROISIEMES PLANS
        MOVE.B  11(A5),10(A5)           *
        
        ADDA.L  #12,A5
        ADDA.L D1,A4                    * AJOUTE 2 LIGNES
        DBF D0,DECAL                    * ET ON BOUCLE 15 FOIS
        SUBQ.B #1,NB_BIT                * ON DECREMENTE LE COMPTEUR
        BEQ.S NEXTCHAR                  * SI 0, PREND LE CARACTERE SUIVANT
        RTS                             * RETOUR

NEXTCHAR:
        MOVE.B  #4,NB_BIT               * REMET LE COMPTEUR A 32
        MOVEQ   #0,D0                   * NETOIE D0
        MOVE.L  MES_PNT,A0              * POINTEUR TEXTE DANS D0
        MOVE.B  (A0)+,D0                * MET LE CARACTERE SUIVANT DANS D0
        CMPI.B  #-1,D0                  * SI -1, ON RECOMMENCE LE TEXTE
        BEQ      AGAIN                  *
        MOVE.L  A0,MES_PNT              * SAUVE LE POINTEUR
        CMPI.B  #-2,D0                  * SI -2, ESPACE
        BEQ     SPACE                   *
        CMPI.B  #39,D0
        BGT     LINE5
        CMPI.B  #29,D0                  * SI D0 > 29 -> QUATRIEME RANGE
        BGT.S   LINE4                   * DANS LA PAGE GRAPHIQUE
        CMPI.B  #19,D0                  * SI D0> > 19 -> TROISIEME RANGE
        BGT.S   LINE3                   * DANS LA PAGE GRAPHIQUE
        CMPI.B  #9,D0                   * SI D0 > 9 -> DEUXIEME RANGE
        BGT.S   LINE2                   * DANS LA PAGE GRAPHIQUE
LINE1:  LSL.L   #4,D0                   * MULTIPLIE D0 PAR 16
        MOVEA.L #IMAGE,A1               * ADRESSE DES FONTS EN MEMOIRE
        ADDA.L  #34,A1                  * ON SAUTE LES DATAS INUTILES
        ADDA.L  D0,A1                   * ADRESSE DU PROCHAIN CAR DANS A1
        MOVE.L  A1,CAR_ADR              * SAUVE SON ADRESSE DANS CAR_ADR
        BSR     LOAD_C                  * COPIE LE CARACTERE DANS BUFFER
        RTS                             *
LINE2:  SUB.B   #10,D0                  * POSITION DU CAR DANS LA LIGNE
        LSL.L   #4,D0                   * MULTIPLIE PAR 16
        MOVEA.L #IMAGE,A1               * ADRESSE DES FONTS EN MEMOIRE
        ADDA.L  #34,A1                  * SAUTE LES DATAS INUTILES
        ADDA.L  #160*33,A1              * (160*32): 32 LIGNES...
        ADDA.L  D0,A1                   * POUR POINTE SUR LE CARACTERE
        MOVE.L  A1,CAR_ADR              * SAUVE ADRESSE DANS CAR_ADR
        BSR     LOAD_C                  * COPIE LE CARACTERE DANS LE BUFFER
        RTS                             * RETOUR
LINE3:  SUB.B   #20,D0                  *
        LSL.L   #4,D0                   *
        MOVEA.L #IMAGE,A1               *
        ADDA.L  #34,A1                  *
        ADDA.L  #160*66,A1              *
        ADDA.L  D0,A1                   *
        MOVE.L  A1,CAR_ADR              *
        BSR     LOAD_C                  *
        RTS                             *
LINE4:  SUB.B   #30,D0                  *
        LSL.L   #4,D0                   *
        MOVEA.L #IMAGE,A1               *
        ADDA.L  #34,A1                  *
        ADDA.L  #160*99,A1              *
        ADDA.L  D0,A1                   *
        MOVE.L  A1,CAR_ADR              *
        BSR     LOAD_C                  *
        RTS                             *
LINE5:  SUB.B   #40,D0                  *
        LSL.L   #4,D0                   *
        MOVEA.L #IMAGE,A1               *
        ADDA.L  #34,A1                  *
        ADDA.L  #160*132,A1             *
        ADDA.L  D0,A1                   *
        MOVE.L  A1,CAR_ADR              *
        BSR     LOAD_C                  *
        RTS                             *

SPACE   LEA     CAR_BUF,A0              * ADRESSE DU BUFFER DANS A0
     REPT 33                            *
        CLR.L   (A0)+                   * ON EFFACE LE BUFFER (DATA A 0)
        CLR.L   (A0)+                   * ON EFFACE LE BUFFER (DATA A 0)
        CLR.L   (A0)+                   * ON EFFACE LE BUFFER (DATA A 0)
     ENDR                               *
        RTS                             * RETOUR
	 
AGAIN   MOVE.L  #MES_A,MES_PNT          * REINITIALISE LE POINTEUR TEXTE
        BRA     NEXTCHAR                * ET ON RECOMMENCE...

plana:     bsr        PLAN1
           ADDA.L       #12,A5
        ADDA.L     D1,A4                        * AJOUTE 2 LIGNES
        DBF        D0,plana                     * ET ON BOUCLE 15 FOIS
        rts

 
LOAD_C  MOVE.L  CAR_ADR,A0              * ADRESSE DU CAR DANS A0
        LEA     CAR_BUF,A1              * ADRESSE DU BUFFER DANS A1
        MOVE.L  #160,D0                 * VALEUR D'INCREMENT
     REPT  33                           *
        MOVE.W  (A0),(A1)+              * COPIE LE PREMIER PLAN
        MOVE.W  2(A0),(A1)+
        MOVE.W  4(A0),(A1)+
        MOVE.W  8(A0),(A1)+             * COPIE LE PREMIER PLAN SUIVANT
        MOVE.W  10(A0),(A1)+
        MOVE.W  12(A0),(A1)+
        ADDA.L  D0,A0                   * ON AJOUTE 160 (LIGNE SUIVANTE)
     ENDR                               *
        RTS                             * ET HOP...RETOUR

RESET   MOVE.W  $000,COUL_0


send_cmd:  move.w   d0,-(sp)
           move.w   #4,-(sp)
           move.w   #3,-(sp)
           trap     #13
           add.l    #6,sp
           rts

	
	opt s-
start:	move.l	a7,a5
	move.l	4(a5),a5
	move.l	#20000,-(sp)
	move.l	a5,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	add.l	#12,sp
	pea	env
	pea	com
	PEA	file
	clr.w	-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	add.l	#16,sp
env	dc.l	0
com	dc.l	0
file	ds.b	16
file1	dc.b	"ton.prg","{"	*nom du prg avec F1
file2	dc.b	"ton1.prg","{"	*NOM DU PRG AVEC F2
file3	dc.b	"ton2.prg","{"	*NOM DU PRG AVEC F3
file4	dc.b	"ton3.prg","{"	*NOM DU PRG AVEC ESPACE



        SECTION DATA
IMAGE   INCBIN dabv.PI1
        EVEN
STOPM_D	DC.B	7,$FF,6,0,8,0,9,0,$A,0
	EVEN
ZIK     INCBIN sowat_0b.MUS
	EVEN
MES_A   DC.B 19,7,4,47,47,1,4,18,19,47,45,45,45,15,20,11,18,8,14,13,45,45,45,47,47,15,17,4,18,4,13,19,47,47,24,14,20,47,47,19,7,8,18,47,47,18,14,5,19,47,47,2,17,0,2,10,4,3,47,47,1,24,47,19,3,22,47,47
      	dc.b 2,4,47,47,18,14,5,19,47,47,18,4,47,47,2,14,15,8,4,47,47,0,20,47,47,5,0,18,19,47,47,26,14,14,47,47
        DC.B 14,10,26,47,47,12,0,8,13,19,4,13,0,13,19,47,11,4,18,47,12,4,12,1,17,4,18,47,3,4,47,15,20,11,18,8,14,13,47,47,47
	DC.B 45,47,19,7,4,47,47,7,8,19,2,7,4,17,47,45,47,47,45,47,3,17,4,0,12,47,47,22,0,17,17,8,14,17,47,45,47,47,45,47,19,4,18,19,0,12,4,13,19,47,45,47,47,45,47,2,14,17,15,47,45,47,47,45,47,19,3,22,47,45,47,47,45,47,15,20,1,11,8,2,47,47,4,13,13
	dc.b 4,12,24,47,45,47,47,47,47,11,4,18,47,47,12,4,12,1,17,4,18,47,47,3,4,47,47,11,46,47,0,11,11,8,0,13,2,4,47,47,19,7,4,47,47,7,4,0,21,24,47,47,10,8,11,11,4,17,18,47,47,18,14,13,19,47,47,46,47,15,20,11,18,8,14,13,47,46,47,47,46
	dc.b 14,20,19,18,8,3,4,17,18,47,46,47,46,18,4,2,19,14,17,47,14,13,4,47,46,47,46,26,14,14,26,47,2,17,4,22,47,46,47,18,19,47,17,20,13,13,4,17,18,47,46,47,23,15,11,14,18,8,14,13,47,46,47,5,14,17,6,14,19,19,4,13,47,2,17,4,22,47,46,47
	dc.b 4,11,4,12,4,13,19,0,11,47,46,47,0,17,18,4,13,8,2,47,46,47,12,4,6,0,47,1,11,0,18,19,47,46,47,25,0,15,47,2,17,4,0,19,8,14,13,47,46,47,47,47,47,47,18,15,4,2,8,0,11,47,47,6,17,4,4,19,8,6,18,47,47,19,14,47,47,19,7,4,47,47,4,12,15,8,17,4
	dc.b 47,47,19,7,4,47,47,17,4,15,11,8,2,0,13,19,18,47,47,7,8,3,3,4,13,47,47,0,13,3,47,47,25,20,11,11,47,47,5,14,5,47,47,19,2,1,47,47,2,13,2,47,47,19,4,17,12,8,13,0,19,14,17,18,47,47,0,20,19,0,12,0,19,8,14,13,47,47,15,14,12,14,4,24,47,47
	dc.b 15,8,17,0,19,4,47,47,12,0,3,47,21,8,18,8,14,12,47,47,0,13,3,47,47,19,14,47,47,24,14,20,47,47,45,45,45,45,47,47
	dc.b 47,47,2,14,13,19,0,2,19,47,47,20,18,47,47,28,31,26,30,47,47,17,19,4,11,27,47,47,2,0,11,47,47,15,20,11,18,8,14,13,47,47,47,48,47,1,24,4,47,1,24,4,47,48,47,47,47,47,47,47,47,47,47,47,-1
	DC.B -1
        EVEN
palette    dc.w      $000,$676,$565,$454,$343,$232
           dc.w      $653,$660,$003,$004,$005,$222
           dc.w	     $007,$333,$444,$776
           even
PI1     incbin pls9.PI1
        EVEN
        SECTION BSS
        EVEN
SAUVE   DS.L    1                       * SAUVE PILE
ECRAN1  DS.L    1                        * ADRESSE DE L'ECRAN
ecran2  ds.l    1
CAR_BUF DS.L    99                      * BUFFER POUR FONTS
MES_PNT DS.L    1                       * POINTEUR SUR MESSAGE
CAR_ADR DS.L    1                       * ADRESSE DATA DU CARACTERE
NB_BIT  DS.B    1
