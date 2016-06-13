
***************************************************************************
*      			Routine de lecture de digits			  *
***************************************************************************

IREPLAY	movem.l	d0-a6,-(sp)
	lea.l 	DIGIDAT(pc),a6
	bsr.s	ICOLOR		scrolling de couleurs

	addq.b	#1,DEC(a6)
	cmp.b	#5,DEC(a6)
	bne.s	IREPL1
	clr.b	DEC(a6)
	bsr.s	DECOM
	
IREPL1	move.l	#$FF8800,A4	SOUND CHIP CNTRL REG
	lea.l	SND_OUT(PC),A3	LOOK UP TABLES
 	lea.l   BUFF(a6),A0
 	move.b	DEC(a6),d0
 	ext.w	d0
	move.b  (a0,d0.w),d7
INTOUTP	and.w	#$00FF,d7	MASK OFF RUBBISH
	add.b	#$80,d7		SIGN VALUE
	lsl.w	#3,d7		DOUBLE LONG WORD OFFSET
 	move.l  (a3,d7.w),d5	GET DATA #1
	move.w  4(a3,d7.w),d4	GET DATA #2
	movep.l d5,(a4)		PLAY #1
	movep.w d4,(a4)		PLAY #2
	movem.l (sp)+,d0-a6
	rte


***************************************************************************
**		  Changement de couleurs (scroll)  		         **
***************************************************************************

ICOLOR  move.l 	PTCOL(a6),a0
        move.w 	(a0)+,$FF8240
        cmp.l  	COLFIN(a6),a0
        bne.s  	ICOLOR1
        movea.l	COLDEB(a6),a0    
ICOLOR1 move.l 	a0,PTCOL(a6)
 	rts
 	

***************************************************************************
** 		    decompacteur dynamique de digit 	                 **
***************************************************************************

DECOM	move.l  PTDEB(a6),a0	POINTEUR SUR MUSIC
	cmp.l	PTFIN(a6),a0	EST CE LA FIN
	blt.s	DECOM0		NON ALORS DECOMPACTER LES 4 OCTETS SUIVANTS
	bsr.s   DECOM1		SINON MODIFIER LES POINTEURS

DECOM0	lea.l   BUFF(a6),a2	POINTE SUR LA ZONE BUFFER DE 5 OCTETS
	move.l  (a0)+,d0 	4 OCTETS --> 5 OCTETS  ( DECOMPACTE )
	move.l	a0,PTDEB(a6)
	move.l  d0,(a2)+	SAUVE LES 4 OCTETS DANS BUFF
	and.l   #$03030303,d0   GARDE LES BITS DU 5eme OCTET
	move.b  d0,d2		RECONSTITUE CE 5eme OCTET
	lsr.l	#6,d0
	or.b	d0,d2
	lsr.l	#6,d0
	or.b	d0,d2
	lsr.l	#6,d0
	or.b	d0,d2
	move.b	d2,(a2)		LE SAUVE DANS LE BUFFER
	rts
	
DECOM1	move.l  PTGIT(a6),a5	POINTEUR SUR MUSIC MIXEE
	addq.l	#8,a5 		PASSER AU MORCEAU SUIVANT
	cmp.l   FINGIT(a6),a5	EST CE LA FIN DES MORCEAUX
	bne.s   DECOM2		
	move.l	DEBGIT(a6),a5	SI OUI ALORS RECOMMENCER AU DEBUT
DECOM2	move.l	a5,PTGIT(a6) 	SINON PASSER AU MORCEAU SUIVANT
	move.l  (a5)+,PTDEB(a6)	CHANGER LES POINTEURS DE DEBUT
	move.l  (a5)+,PTFIN(a6)	ET DE FIN DU MORCEAU
 	move.l	PTDEB(a6),a0 	POINTE LE NOUVEAU MORCEAU
 	rts

*-------------------------------------------------------------------------*
*              Buffer des 5 octets de music decompactes			  *
*-------------------------------------------------------------------------*

BUFF	rs.b	 5			

*-------------------------------------------------------------------------*
*	  Compteur de lecture d'octets decompactes ( de 0 a 4 )		  *
*-------------------------------------------------------------------------*

DEC	rs.b	 1	

*-------------------------------------------------------------------------*
*		Pointeurs sur les morceaux et sur la music                *           
*-------------------------------------------------------------------------*

PTGIT	rs.l 	1  		POINTEUR SUR LA TABLE DES MORCEAUX
DEBGIT  rs.l 	1		ADRESSE DU DEBUT DES MORCEAUX
FINGIT	rs.l	1		ADRESSE DE FIN DES MORCEAUX
PTDEB   rs.l	1  		POINTEUR SUR LE DEBUT DE LA MUSIC COMPACTEE
PTFIN   rs.l	1  		POINTEUR SUR LA FIN DE LA MUSIC

PTCOL 	rs.l 	1		POINTEUR SUR COULEURS
COLDEB	rs.l 	1		POINTEUR SUR DEBUT PALLETTE
COLFIN  rs.l 	1		POINTEUR SUR FIN PALETTE

*-------------------------------------------------------------------------*
	
DIGIDAT ds.b	38		reservation de la place des 

*-------------------------------------------------------------------------*
*                    table de son interne				  *
*-------------------------------------------------------------------------*

SND_OUT	DC.W	$80C,$90B,$A09,0,$80C,$90B,$A09,0
	DC.W	$80D,$908,$A08,0,$80B,$90B,$A0B,0
	DC.W	$80D,$909,$A05,0,$80C,$90B,$A08,0
	DC.W	$80D,$909,$A02,0,$80D,$908,$A06,0
	DC.W	$80C,$90B,$A07,0,$80D,$907,$A07,0
	DC.W	$80C,$90B,$A06,0,$80C,$90A,$A09,0
	DC.W	$80B,$90B,$A0A,0,$80C,$90B,$A02,0
	DC.W	$80C,$90B,$A00,0,$80C,$90A,$A08,0

	DC.W	$80D,$906,$A04,0,$80D,$905,$A05,0
	DC.W	$80D,$905,$A04,0,$80C,$909,$A09,0
	DC.W	$80D,$904,$A03,0,$80B,$90B,$A09,0
	DC.W	$80C,$90A,$A05,0,$80B,$90A,$A0A,0
	DC.W	$80C,$909,$A08,0,$80B,$90B,$A08,0
	DC.W	$80C,$90A,$A00,0,$80C,$90A,$A00,0
	DC.W	$80C,$909,$A07,0,$80B,$90B,$A07,0
	DC.W	$80C,$909,$A06,0,$80B,$90B,$A06,0

	DC.W	$80B,$90A,$A09,0,$80B,$90B,$A05,0
	DC.W	$80A,$90A,$A0A,0,$80B,$90B,$A02,0
	DC.W	$80B,$90A,$A08,0,$80C,$907,$A07,0
	DC.W	$80C,$908,$A04,0,$80C,$907,$A06,0
	DC.W	$80B,$909,$A09,0,$80C,$906,$A06,0
	DC.W	$80A,$90A,$A09,0,$80C,$907,$A03,0
	DC.W	$80B,$90A,$A05,0,$80B,$909,$A08,0
	DC.W	$80B,$90A,$A03,0,$80A,$90A,$A08,0

	DC.W	$80B,$90A,$A00,0,$80B,$909,$A07,0
	DC.W	$80B,$908,$A08,0,$80A,$90A,$A07,0
	DC.W	$80A,$909,$A09,0,$80C,$901,$A01,0
	DC.W	$80A,$90A,$A06,0,$80B,$908,$A07,0
	DC.W	$80A,$90A,$A05,0,$80A,$909,$A08,0
	DC.W	$80A,$90A,$A02,0,$80A,$90A,$A01,0
	DC.W	$80A,$90A,$A00,0,$809,$909,$A09,0
	DC.W	$80A,$908,$A08,0,$80B,$908,$A01,0

	DC.W	$80A,$909,$A06,0,$80B,$907,$A04,0
	DC.W	$80A,$909,$A05,0,$809,$909,$A08,0
	DC.W	$80A,$909,$A03,0,$80A,$908,$A06,0
	DC.W	$80A,$909,$A00,0,$809,$909,$A07,0
	DC.W	$809,$908,$A08,0,$80A,$908,$A04,0
	DC.W	$809,$909,$A06,0,$80A,$908,$A01,0
	DC.W	$809,$909,$A05,0,$809,$908,$A07,0
	DC.W	$808,$908,$A08,0,$809,$909,$A02,0

	DC.W	$809,$908,$A06,0,$809,$909,$A00,0
	DC.W	$809,$907,$A07,0,$808,$908,$A07,0
	DC.W	$809,$907,$A06,0,$809,$908,$A02,0
	DC.W	$808,$908,$A06,0,$809,$906,$A06,0
	DC.W	$808,$907,$A07,0,$808,$908,$A04,0
	DC.W	$808,$907,$A06,0,$808,$908,$A02,0
	DC.W	$807,$907,$A07,0,$808,$906,$A06,0
	DC.W	$808,$907,$A04,0,$807,$907,$A06,0

	DC.W	$808,$906,$A05,0,$808,$906,$A04,0
	DC.W	$807,$906,$A06,0,$807,$907,$A04,0
	DC.W	$808,$905,$A04,0,$806,$906,$A06,0
	DC.W	$807,$906,$A04,0,$807,$905,$A05,0
	DC.W	$806,$906,$A05,0,$806,$906,$A04,0
	DC.W	$806,$905,$A05,0,$806,$906,$A02,0
	DC.W	$806,$905,$A04,0,$805,$905,$A05,0
	DC.W	$806,$905,$A02,0,$805,$905,$A04,0

	DC.W	$805,$904,$A04,0,$805,$905,$A02,0
	DC.W	$804,$904,$A04,0,$804,$904,$A03,0
	DC.W	$804,$904,$A02,0,$804,$903,$A03,0
	DC.W	$803,$903,$A03,0,$803,$903,$A02,0
	DC.W	$803,$902,$A02,0,$802,$902,$A02,0
	DC.W	$802,$902,$A01,0,$801,$901,$A01,0
	DC.W	$802,$901,$A00,0,$801,$901,$A00,0
	DC.W	$801,$900,$A00,0,$800,$900,$A00,0

	DC.W	$80E,$90D,$A0C,0,$80F,$903,$A00,0
	DC.W	$80F,$903,$A00,0,$80F,$903,$A00,0
	DC.W	$80F,$903,$A00,0,$80F,$903,$A00,0
	DC.W	$80F,$903,$A00,0,$80E,$90D,$A0B,0
	DC.W	$80E,$90D,$A0B,0,$80E,$90D,$A0B,0
	DC.W	$80E,$90D,$A0B,0,$80E,$90D,$A0B,0
	DC.W	$80E,$90D,$A0B,0,$80E,$90D,$A0B,0
	DC.W	$80E,$90D,$A0A,0,$80E,$90D,$A0A,0

	DC.W	$80E,$90D,$A0A,0,$80E,$90D,$A0A,0
	DC.W	$80E,$90C,$A0C,0,$80E,$90D,$A00,0
	DC.W	$80D,$90D,$A0D,0,$80D,$90D,$A0D,0
	DC.W	$80D,$90D,$A0D,0,$80D,$90D,$A0D,0
	DC.W	$80D,$90D,$A0D,0,$80D,$90D,$A0D,0
	DC.W	$80E,$90C,$A0B,0,$80E,$90C,$A0B,0
	DC.W	$80E,$90C,$A0B,0,$80E,$90C,$A0B,0
	DC.W	$80E,$90C,$A0B,0,$80E,$90C,$A0B,0

	DC.W	$80E,$90C,$A0B,0,$80E,$90C,$A0B,0
	DC.W	$80E,$90C,$A0A,0,$80E,$90C,$A0A,0
	DC.W	$80E,$90C,$A0A,0,$80E,$90C,$A0A,0
	DC.W	$80D,$90D,$A0C,0,$80D,$90D,$A0C,0
	DC.W	$80E,$90C,$A09,0,$80E,$90C,$A09,0
	DC.W	$80E,$90C,$A05,0,$80E,$90C,$A00,0
	DC.W	$80E,$90C,$A00,0,$80E,$90B,$A0B,0
	DC.W	$80E,$90B,$A0B,0,$80E,$90B,$A0B,0

	DC.W	$80E,$90B,$A0B,0,$80E,$90B,$A0A,0
	DC.W	$80E,$90B,$A0A,0,$80E,$90B,$A0A,0
	DC.W	$80D,$90D,$A0B,0,$80D,$90D,$A0B,0
	DC.W	$80D,$90D,$A0B,0,$80E,$90B,$A09,0
	DC.W	$80E,$90B,$A09,0,$80E,$90B,$A09,0
	DC.W	$80D,$90C,$A0C,0,$80D,$90D,$A0A,0
	DC.W	$80E,$90B,$A07,0,$80E,$90B,$A00,0
	DC.W	$80E,$90B,$A00,0,$80D,$90D,$A09,0

	DC.W	$80D,$90D,$A09,0,$80E,$90A,$A09,0
	DC.W	$80D,$90D,$A08,0,$80D,$90D,$A07,0
	DC.W	$80D,$90D,$A04,0,$80D,$90D,$A00,0
	DC.W	$80E,$90A,$A04,0,$80E,$909,$A09,0
	DC.W	$80E,$909,$A09,0,$80D,$90C,$A0B,0
	DC.W	$80E,$909,$A08,0,$80E,$909,$A08,0
	DC.W	$80E,$909,$A07,0,$80E,$908,$A08,0
	DC.W	$80E,$909,$A01,0,$80C,$90C,$A0C,0

	DC.W	$80D,$90C,$A0A,0,$80E,$908,$A06,0
	DC.W	$80E,$907,$A07,0,$80E,$908,$A00,0
	DC.W	$80E,$907,$A05,0,$80E,$906,$A06,0
	DC.W	$80D,$90C,$A09,0,$80E,$905,$A05,0
	DC.W	$80E,$904,$A04,0,$80D,$90C,$A08,0
	DC.W	$80D,$90B,$A0B,0,$80E,$900,$A00,0
	DC.W	$80D,$90C,$A06,0,$80D,$90C,$A05,0
	DC.W	$80D,$90C,$A02,0,$80C,$90C,$A0B,0

	DC.W	$80C,$90C,$A0B,0,$80D,$90B,$A0A,0
	DC.W	$80D,$90B,$A0A,0,$80D,$90B,$A0A,0
	DC.W	$80D,$90B,$A0A,0,$80C,$90C,$A0A,0
	DC.W	$80C,$90C,$A0A,0,$80C,$90C,$A0A,0
	DC.W	$80D,$90B,$A09,0,$80D,$90B,$A09,0
	DC.W	$80D,$90A,$A0A,0,$80D,$90A,$A0A,0
	DC.W	$80D,$90A,$A0A,0,$80C,$90C,$A09,0
	DC.W	$80C,$90C,$A09,0,$80C,$90C,$A09,0

	DC.W	$80D,$90B,$A06,0,$80C,$90B,$A0B,0
	DC.W	$80C,$90C,$A08,0,$80D,$90B,$A00,0
	DC.W	$80D,$90B,$A00,0,$80C,$90C,$A07,0
	DC.W	$80C,$90C,$A06,0,$80C,$90C,$A05,0
	DC.W	$80C,$90C,$A03,0,$80C,$90C,$A01,0
	DC.W	$80C,$90B,$A0A,0,$80D,$90A,$A05,0
	DC.W	$80D,$90A,$A04,0,$80D,$90A,$A02,0
	DC.W	$80D,$909,$A08,0,$80D,$909,$A08,0
	ds.b	26+22
*************************************************************
**                                                         **
**         DECOMPACTEUR DE DESSINS AU FORMAT TINY          **
**               Par METAL68 from M.D.K                    **
**                                                         **
*************************************************************
 
; Registres d'entree :       	 A0 : adresse reelle du pic
;                                A1 : adresse de stockage des couleurs
;				 A2 : adresse du buffer1
;				 A3 : adresse du buffer2
; 		        	 A6 : adresse de stockage
; il faut reserver 2 pages de 32000 octets pour le decompactage
; pointees par tinybuf1 et tinybuf2.Le pic doit etre prive du 1er octet.

tiny	lea.l   tinybuf1(pc),a4
	move.l	a2,(a4)+
	move.l  a3,(a4)

        movem.l (a0)+,d0-d7	sauvegarde des couleurs du dessin, ici A0
        movem.l d0-d7,(a1)	pointe sur la taille de la partie 1

        moveq 	#0,d0
        moveq   #0,d1
        move.w  (a0)+,d0	taille de la 1ere partie
        move.w  (a0)+,d1	taille de la 2eme partie/2
        move.l  d0,d6           sauvegarde de d0
        
        move.l  tinybuf1(pc),a1 	1er buffer de decompactage
        bsr 	deplac		deplacer la partie 1 dans le 1er buffer
        
        add.l	d6,a0 		a0 pointe sur la partie 2
	ext.l   d1
	asl.l	#1,d1           taille de la 2eme partie
	move.l  tinybuf2(pc),a1 	2eme buffer de decompactage
	bsr     deplac		deplacer partie 2 dans le 2eme buffer
	bsr     decomp		decompacter le dessin
	rts


deplac  move.l  a0,-(sp)	sauvegarde de a0
deplac1 move.b  (a0)+,(a1)+	 
	dbra 	d0,deplac1
	move.l  (sp)+,a0
	rts
	

decomp	CLR.L	D0
	CLR.L	D2
	CLR.L	D3
	movea.L	tinybuf1(pc),A2	buffer de la 1ere partie du dessin
	movea.L	tinybuf2(pc),A4    buffer de la 2eme partie du dessin
	MOVEA.L	a6,A3    	buffer d'arrive du dessin
	BRA	L19260

L191A6	CLR.L	D1
	TST.B	0(A2,D3.W)
	BEQ.S	L191C4
	CMPI.B	#1,0(A2,D3.W)
	BEQ.S	L191C4
	MOVE.B	0(A2,D3.W),D1
	EXT.W	D1
	ADDQ.W	#1,D3
	BRA.S	L191EA
L191C4	LEA	0(A2,D3.W),A0
	MOVE.B	(A0)+,D1
	LEA.L	tinydat(pc),a6
	MOVE.B	(A0)+,(a6)
	MOVE.B	(A0)+,1(a6)
	ADDQ.W	#3,D3
	CMP.B	#1,D1
	BNE.S	L191E4
	NEG.W	(a6)
L191E4	MOVE.W	(a6),D1
L191EA	RTS

L191EE	ADD.L	#$A0,D0
	CMP.L	#$7D00,D0
	BLT.S	L19214
	SUB.L	#$7CF8,D0
	CMP.L	#$A0,D0
	BLT.S	L19214
	SUB.L	#$9E,D0
L19214  RTS
	
L19236	BSR.s	L191A6
	TST.W	D1
	BGE.S	L1925A
	NEG.W	D1
	BRA.S	L1924C
L19242	MOVE.W	0(A4,D2.W),0(A3,D0.W)
	ADDQ.W	#2,D2
	BSR.S	L191EE
L1924C	DBF	D1,L19242
	BRA.S	L19260
L19252	MOVE.W	0(A4,D2.W),0(A3,D0.W)
	BSR.S	L191EE
L1925A	DBF	D1,L19252
	ADDQ.W	#2,D2
L19260	CMP.W	d6,D3
	BLT.S	L19236
	RTS

tinydat 	dc.w 0
tinybuf1	dc.l 0
tinybuf2	dc.l 0

