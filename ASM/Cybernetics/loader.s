*-------------------------------------------------------------------------*
*									  *
*	LOADER					- CYBERNETICS 1992 -	  * 
*									  *
*-------------------------------------------------------------------------*

	output	e:\code\effects.grx\bootsecs\pakload.bin

MVOL:	EQU $80
						
LEN:		EQU 250				* 12.5 Khz
FREQ:		EQU 1
INC:		EQU $011DF989		
Face_1:		Equ $0E002500 
Face_2:		Equ $0E002400 
adr_base:	Equ 52000
system:		Equ 0
*-------------------------------------------------------------------------*
		opt		o+

aigus:		set		9
graves:		set		10
cpu:		set		0
esc:		set		0
*-------------------------------------------------------------------------*

	ifne	system
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.w	#6,sp

	move.b	#2,$ffff820a.w

	clr.w	-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp

	move.w	#1,$210.w
	move.w	#1,$208.w

	lea	$21a.w,a0
	rept	3
	move.w	#8,(a0)+
	move.w	#49,(a0)+
	move.w	#45,(a0)+
	move.l	#face_1,(a0)+
	move.w	#1,(a0)+
	endr	

	lea	$2b0.w,a0
	rept	3
	move.w	#4,(a0)+
	move.w	#252,(a0)+
	move.w	#9,(a0)+
	move.l	#face_2,(a0)+
	move.w	#2,(a0)+
	endr	
	move.w	#-1,$216.w		
	endc

	move.l		sp,a6
	move.l		$8.w,d0			* Mega ste Ö 16 mhz
	move.l		#suite,$8.w
	move.b		#3,$ffff8e21.w
suite:	move.l		d0,$8.w
	move.l		a6,sp

	lea		$ffff8240.w,a0
	rept		8
	clr.l		(a0)+
	endr

	move.l		#buffer_ec,d0
	sub.b		d0,d0
	move.l		d0,bufferec
	move.l		d0,ecran
	move.l		d0,physb
	clr.b		$ffff820d.w
	lsr.w		#8,d0	
	move.b		d0,$ffff8203.w
	swap		d0
	move.b		d0,$ffff8201.w
	
	bsr		initsound

	move.l		bufferec,a0
	move.w		#(256+200*160*2)/4-1,d0
effbss:	clr.l		(a0)+
	dbra.w		d0,effbss	

	tst.w		$216.w
	beq.s		noinit
	move.l		bufferec,a1
	lea		60*160(a1),a1
	lea		loading(pc),a0
	lea		0.w,a2
	moveq.l		#62,d0
	bsr		decomp
	move.l		a1,a2
	lea		32000(a2),a2
	move.w		#64*160/4-1,d0
copy:	move.l		(a1)+,(a2)+
	dbra.w		d0,copy

	*------------------------*
	* Inits Blitter		 *
	*------------------------*
noinit:		
	move.w		#-1,$ffff8a2a.w		* Masque
	move.w		#-1,$ffff8a28.w		* Masque
	move.w		#-1,$ffff8a2c.w		* Masque
	move.w		#8,$ffff8a2e.w		* Increment horizontal dest
	move.w		#4000,$ffff8a36.w	* Horizontal size
	clr.b		$ffff8a3a.w		* Mode demi-teinte & combinaison logique
	clr.b		$ffff8a3B.w		* Mode demi-teinte & combinaison logique
	clr.b		$ffff8a3D.w		* Mode demi-teinte & combinaison logique

	jsr		muson			* Zik on

	tst.w		$216.w
	bne.s		okpap
	move.w		#$666,$ffff8242.w
okpap:


*-------------------------------------------------------------------------*
*  Chargement								  *
*-------------------------------------------------------------------------*
	move.w		$208.w,d0
	mulu.w		#12,d0
	lea		$21a.w,a4
	add.w		d0,a4
	move.w		(a4)+,d0		* Secteur de depart
	move.w		(a4)+,d1		* Nombre de sect a lire
	move.w		(a4)+,d2		* Piste de depart
	move.l		(a4)+,d3		* Face

	bsr		insertcontrol

	lea		adr_base,a5		* Adresse de chargement
	move.l		d3,$ffff8800.w
	bsr		raymond			* Chargement ecran

	lea		adr_base,a0		* Depack
	bsr		ice_decrunch_2

	lea		adr_base,a0
	bsr		reloc
	
	move.w		$210.w,d0		* Numero du module
	beq.s		fin

	lea		adr_base,a5		* Cherche adresse chargement
	move.l		#'Here',d1		* module
search:	addq.w		#2,a5
	cmp.l		(a5),d1
	bne.s		search
	move.l		a5,zizi
		
	mulu.w		#14,d0
	lea		$2b0.w,a4
	add.w		d0,a4
	move.w		(a4)+,d0		* Secteur de depart
	move.w		(a4)+,d1		* Nombre de sect a lire
	move.w		(a4)+,d2		* Piste de depart
	move.l		(a4)+,d3		* Face

	bsr		insertcontrol

	move.l		zizi(pc),a5
	move.l		d3,$ffff8800.w
	bsr		raymond
	
	tst.w		2(a4)
	beq.s		fin
	move.l		zizi(pc),a0		* Depack module
	bsr		depack_module

	*--------------------------------------------*
	* Reinit & fin 		 		     *
	*--------------------------------------------*

fin:	tst.w	$216.w
	beq.s	nofade
	bsr	fadesound
   	move.l	#vbl2,$70.w

	lea	$ffff8240.w,a0
	rept	8
	clr.l	(a0)+
	endr
		***** RESET SHIFTER *****
	
	MOVEQ	#5,D6
.CHIANT	MOVE.B	#1,$ffff8260.W
	STOP	#$2300
	CLR.B	$ffff8260.W		* BASSE RESOLUTION
	STOP	#$2300
	DBF	D6,.CHIANT

	STOP	#$2300
	CLR.B	$ffff8260.W		* BASSE RESOLUTION

nofade:	move.b	#2,$ffff820a.w		
	move.w	#$2700,sr
	lea	$ffff8240.w,a0
	rept	8
	clr.l	(a0)+
	endr
	move.w	#-1,$216.w
	
	move.l		sp,a6
	move.l		$8.w,d0			* Mega ste Ö 8 mhz
	move.l		#suite2,$8.w
	clr.b		$ffff8e21.w
suite2:	move.l		d0,$8.w
	move.l		a6,sp
	
	jmp	adr_base

zizi:	dc.l	0
*-------------------------- CONTROL DISK

insertcontrol:	movem.l		d0-d3,-(sp)		* Sauvegarde registres
		moveq.l		#1,d0			* Secteur de depart
		moveq.l		#1,d1			* Nombre de sect a lire
		moveq.l		#0,d2			* Piste de depart
		move.l		#face_1,$ffff8800.w	* Face
		lea		sector,a5		* Adresse de chargement
		
		bsr		raymond			* Charge

		move.w		(a4),d0			*
		cmp.w		sector+508,d0		*
		beq.s		okdisk1			*

		move.l		bufferec,a1		
		lea		165*160+48(a1),a1	* Affichage message
		move.l		a1,a2
		lea		aff2(pc),a0
		bsr.s		affload
		lea		32000(a2),a1
		lea		aff2(pc),a0
		bsr.s		affload

		lea		56(a2),a1		* Affichage message
		lea		aff3-12(pc),a0
		move.w		(a4),d0
		mulu.w		#2*5+2,d0
		add.w		d0,a0
		move.l		a0,a3
		bsr.s		affload	
		move.l		a3,a0
		lea		32000+56(a2),a1
		bsr.s		affload
	
		movem.l		(sp)+,d0-d3	
		bra.s		insertcontrol

okdisk1:	move.l	bufferec,a0		* Efface ecran
		lea	165*160(a0),a0
		move.l	a0,a1
		add.l	#200*160,a1
		move.w	#20*5-1,d0
eff:		clr.w	(a0)
		clr.w	(a1)
		addq.w	#8,a0
		addq.w	#8,a1
		dbra.w	d0,eff

		movem.l		(sp)+,d0-d3
		rts

affload:	move.w	(a0)+,d7			
		moveq.l	#19,d5
		sub.w	d7,d5
		lsl.w	#3,d5		

		moveq.l	#4,d6				* 5 Lignes
affvert:	move.w	d7,d0				* Longueur	
affhor:		move.w	(a0)+,(a1)		
		addq.w	#8,a1				* Affichage 1 plan
		dbra.w	d0,affhor
		add.w	d5,a1				* Saut a la ligne suivante
		dbra.w	d6,affvert

		rts					* Return

aff2:		incbin	e:\code\effects.grx\bootsecs\l_img1.dat
aff3:		incbin	e:\code\effects.grx\bootsecs\l_img2.dat
aff4:		incbin	e:\code\effects.grx\bootsecs\l_img3.dat
aff5:		incbin	e:\code\effects.grx\bootsecs\l_img4.dat
sector:		DS.B	512

***************************************************************************
* 	Routine de relocation 						  *
***************************************************************************

reloc:	move.l	a0,-(a7)		; Empile adresse du programme
	move.l	2(a0),d0		; D0 = Nombre octets zone texte
	add.l	6(a0),d0		; + Nombre octets zone data
	add.l	$e(a0),d0		; + Nombre octet table des symboles 
	lea	$1c(a0),a0		; A0 pointe sur debut code

	movea.l	a0,a1			; A1 = A0 = Adresse debut code
	movea.l	a0,a2			; A2 = A0 = Adresse debut code
	move.l	a0,d1			; D1 = A0 = Valeur adr debut code
	adda.l	d0,a1			; A1 = A1 + D0 
					; A1 = Adresse table de relocation
	move.l	(a1)+,d0		; D0 = Premier offset pour trouver
					; la prochaine adresse Ö modifier

	adda.l	d0,a2			; A2 = A2 + D0
					; A2 = Adresse de la relocation
	add.l	d1,(a2)			; A2 = A2 + D1
					; Ajoute l'adresse du debut du code
					; Ö la valeur Ö reloger
	moveq	#0,d0			; Raz de d0

reloc2:	move.b	(a1)+,d0		; D0 = Offset du mot long suivant
	beq.s	f_reloc			; Si d0 = 0, fin de la relocation
	cmp.b	#1,d0			; Si d0 = 1, c'est qu'il y Ö plus
	beq.s	reloc3			; de $fe octet avant la prochaine
					; info Ö reloger
	adda.l	d0,a2			; A2 = A2 + D0
					; A2 = Adresse de la relocation
	add.l	d1,(a2)			; A2 = A2 + D1
					; Ajoute l'adresse du debut du code
					; Ö la valeur Ö reloger
	bra.s	reloc2			; Reboucle
reloc3:	lea	$fe(a2),a2		; A2 = A2 + $FE
	bra.s	reloc2			; Reboucle
f_reloc:move.l	(a7)+,a0		; Restaure A0 
	rts				; Fin s/p

************************************************************************
*
* SIMPLE ROUTINE DE DMA-LOADER par LE PIPOZOR from ...censured
*
* Loader codex pour l'inoubliable DEUS-EX-MACHINA HYPRADEMO
*
* Copyright pour toutes les countries, URSS (include) 1956 - 
*
* DevelopÇde sur un banal Çmulateur ATARI on AMIGAAARGH (bien sur)
*
************************************************************************

MAX_SECTOR      EQU 10           * Nombre de secteurs par piste = 10


	******* INIT POUR DMA-LOADER ****************************
	*                                                       *
	* A5.L   = DESTINATION -> DEBUT ADRESSE EN RAM          *
	*                                                       *
	* (A4.L) = $0E002500 sÇlection face 0                   *
	* (A4.L) = $0E002400 sÇlection face 1                   *
	*                                                       *
	* D0.W   = SECTEUR DE DEPART SUR LA PISTE (1-9/10/11)   *
	* D1.W   = NOMBRE DE SECTEURS A LIRE                    *
	* D2.W   = PISTE DE DEPART (0-79)                       *
	*                                                       *
	*********************************************************
			
	
***************** LOADER **********************************************


RAYMOND	LEA       $FFFF8606.W,A1 
	LEA       -2(A1),A0             * SOIT $FFFF8604.W DANS A0
	BRA.S     READER
BYEBYE  RTS

	***** DMA-LOADER *****

*****************************************       
CHARGE  LEA     SAVER(PC),A3    *
	MOVE.L  A5,(A3)         *
	MOVE.B  3(A3),$FFFF860D.W       * FIXER BASE DMA
	MOVE.B  2(A3),$FFFF860B.W       *
	MOVE.B  1(A3),$FFFF8609.W       *
	MOVE.W  #$90,(A1)               * CPT DE SECTEURS/LECTURE REG ETAT
	MOVE.W  #$190,(A1)              * CPT DE SECTEURS/ECRITURE REG CMD
	MOVE.W  #$90,(A1)               * CPT DE SECTEURS/LECTURE REG ETAT
	MOVE.W  #1,(A0)                 *
	MOVE.W  #$84,(A1)               * FDC-DMA/LECTURE REG DE SECTEUR
	MOVE.W  D0,(A0)        		* No DU SECTEUR DE LA PISTE
	MOVE.W  #$80,(A1)               * FDC-DMA/LECTURE REG D'ETAT
	MOVE.W  #$88,(A0)               *
	LEA     SAVER(PC),A6    	*
	MOVEM.L A5/D0-D2,(A6)  		*
	LEA     PIPIM(PC),A2    	*
	SUBQ.W  #1,D1           	* 1 SECTEUR LU (DONC -1 A LIRE !)
	BNE.S   POPOM           	*
	LEA     BYEBYE(PC),A3   	* TOUT LU ?
	BRA.S   WAITER          	* SI OUI ON TERMINE LA ROUTINE...
*****************************************

*****************************************
POPOM   LEA       CHARGE(PC),A3   	*
	ADDQ.W    #1,D0           	* +1 SECTEUR SUR LA PISTE EN COURS
	LEA       512(A5),A5      	* ADRESSE DATA +512 OCTETS
	CMPI.W    #MAX_SECTOR+1,D0	* TOUS LES SECTEURS DE LA PISTE
				  	* SONT CHARGES  (SOIT 10 SECT.3) ?
	BNE.S     WAITER          	* SI, NON: ALORS ON CONTINUE...
	MOVEQ     #1,D0           	* SI, OUI: ON REPART SUR SECTEUR 1
	ADDQ.W    #1,D2           	* DE LA PISTE SUIVANTE (+1 A PISTE)
	LEA       READER(PC),A3   	*
	BRA.S     WAITER          	*
*****************************************

*****************************************
READER  MOVE.W    #$86,(A1)     	* FDC-DMA/LECTURE REG DE DONNEES
	MOVE.W    D2,(A0)               * -> No DE PISTE
	MOVE.W    #$80,(A1)       	* FDC-DMA/LECTURE REG D'ETAT
	MOVE.W    #27,(A0)       	* -> 
	LEA       CHARGE(PC),A2   	*
WAITER  BTST.B    #5,$fffffa01.W        * WAIT INTERRUPT FDC
	BNE.S     WAITER          	*
	JMP             (A2)            * -> GOTO CHARGE
*****************************************

*****************************************       
PIPIM   MOVE.W          #$80,(A1)       * FDC-DMA/LECTURE REG D'ETAT
	MOVE.W          (A0),D3         *
	ANDI.W          #28,D3          *
	BNE.S           .ICI            *
	JMP     (A3)            	*
.ICI    MOVEM.L         SAVER(PC),A5/D0-D2*
	BRA.S           READER          *
*****************************************

SAVER   DS.L 4

;*************************** Unpacking routine of PACK-ICE
; a0 = Adress of packed data
; "bsr" or "jsr" to ice_decrunch_2 with register a0 prepared.

ice_decrunch_2:
	link	a3,#-120
	movem.l	d0-a6,-(sp)
	lea	120(a0),a4
	move.l	a4,a6
	bsr.s	.getinfo
	bsr.s	.getinfo
	lea.l	-8(a0,d0.l),a5
	bsr.s	.getinfo
	move.l	d0,(sp)
	adda.l	d0,a6
	move.l	a6,a1

	moveq	#119,d0
.save:	move.b	-(a1),-(a3)
	dbf	d0,.save
	move.l	a6,a3
	move.b	-(a5),d7
	bsr.s	.normal_bytes
	move.l	a3,a5


	bsr	.get_1_bit
	bcc.s	.no_picture
	move.w	#$0f9f,d7
	bsr	.get_1_bit
	bcc.s	.ice_00
	moveq	#15,d0
	bsr	.get_d0_bits
	move.w	d1,d7
.ice_00:	moveq	#3,d6
.ice_01:	move.w	-(a3),d4
	moveq	#3,d5
.ice_02:	add.w	d4,d4
	addx.w	d0,d0
	add.w	d4,d4
	addx.w	d1,d1
	add.w	d4,d4
	addx.w	d2,d2
	add.w	d4,d4
	addx.w	d3,d3
	dbra	d5,.ice_02
	dbra	d6,.ice_01
	movem.w	d0-d3,(a3)
	dbra	d7,.ice_00
.no_picture
	movem.l	(sp),d0-a3

.move	move.b	(a4)+,(a0)+
	subq.l	#1,d0
	bne.s	.move
	moveq	#119,d0
.rest	move.b	-(a3),-(a5)
	dbf	d0,.rest
.not_packed:
	movem.l	(sp)+,d0-a6
	unlk	a3
	rts

.getinfo: moveq	#3,d1
.getbytes: lsl.l	#8,d0
	move.b	(a0)+,d0
	dbf	d1,.getbytes
	rts

.normal_bytes:	
	bsr.s	.get_1_bit
	bcc.s	.test_if_end
	moveq.l	#0,d1
	bsr.s	.get_1_bit
	bcc.s	.copy_direkt
	lea.l	.direkt_tab+20(pc),a1
	moveq.l	#4,d3
.nextgb:	move.l	-(a1),d0
	bsr.s	.get_d0_bits
	swap.w	d0
	cmp.w	d0,d1
	dbne	d3,.nextgb
.no_more: add.l	20(a1),d1
.copy_direkt:	
	move.b	-(a5),-(a6)
	dbf	d1,.copy_direkt
.test_if_end:	
	cmpa.l	a4,a6
	bgt.s	.strings
	rts	

.get_1_bit:
	add.b	d7,d7
	bne.s	.bitfound
	move.b	-(a5),d7
	addx.b	d7,d7
.bitfound:
	rts	

.get_d0_bits:	
	moveq.l	#0,d1
.hole_bit_loop:	
	add.b	d7,d7
	bne.s	.on_d0
	move.b	-(a5),d7
	addx.b	d7,d7
.on_d0:	addx.w	d1,d1
	dbf	d0,.hole_bit_loop
	rts	


.strings: lea.l	.length_tab(pc),a1
	moveq.l	#3,d2
.get_length_bit:	
	bsr.s	.get_1_bit
	dbcc	d2,.get_length_bit
.no_length_bit:	
	moveq.l	#0,d4
	moveq.l	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bmi.s	.no_Åber
.get_Åber:
	bsr.s	.get_d0_bits
.no_Åber:	move.b	6(a1,d2.w),d4
	add.w	d1,d4
	beq.s	.get_offset_2


	lea.l	.more_offset(pc),a1
	moveq.l	#1,d2
.getoffs: bsr.s	.get_1_bit
	dbcc	d2,.getoffs
	moveq.l	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bsr.s	.get_d0_bits
	add.w	d2,d2
	add.w	6(a1,d2.w),d1
	bpl.s	.depack_bytes
	sub.w	d4,d1
	bra.s	.depack_bytes


.get_offset_2:	
	moveq.l	#0,d1
	moveq.l	#5,d0
	moveq.l	#-1,d2
	bsr.s	.get_1_bit
	bcc.s	.less_40
	moveq.l	#8,d0
	moveq.l	#$3f,d2
.less_40: bsr.s	.get_d0_bits
	add.w	d2,d1

.depack_bytes:
	lea.l	2(a6,d4.w),a1
	adda.w	d1,a1
	move.b	-(a1),-(a6)
.dep_b:	move.b	-(a1),-(a6)
	dbf	d4,.dep_b
	bra	.normal_bytes
.direkt_tab:
	dc.l $7fff000e,$00ff0007,$00070002,$00030001,$00030001
	dc.l     270-1,	15-1,	 8-1,	 5-1,	 2-1
.length_tab:
	dc.b 9,1,0,-1,-1
	dc.b 8,4,2,1,0
.more_offset:
	dc.b	  11,   4,   7,  0	; Bits lesen
	dc.w	$11f,  -1, $1f		; Standard Offset
ende_ice_decrunch_2:

************************************************************
; depack routine for module packer
; In :
; a0 = Pointer on module

depack_module:  bsr.s     analyse_module       ; find sample start/end
                bsr     init_depack
                movea.l sample_start(PC),A0  ; packed sample
                move.l  sample_end(PC),D0
                sub.l   A0,D0                ; unpacked length

                move.l  D0,-(A7)
                bsr.s     depack_sample        ; depack over source
                move.l  (A7)+,D0
                rts
; a0=module address
analyse_module: move.l  A0,-(A7)
                lea     $03b8(A0),A1
                moveq   #$7f,D0
                moveq   #0,D4
mt_loop:        move.l  D4,D2
                subq.w  #1,D0
mt_lop2:        move.b  (A1)+,D4
                cmp.b   D2,D4
                bgt.s   mt_loop
                dbra    D0,mt_lop2
                addq.b  #1,D2

                asl.l   #8,D2
                asl.l   #2,D2
                add.l   #$043c,D2
                move.l  D2,D1
                add.l   A0,D2
                movea.l D2,A2

                move.l  A2,sample_start

                moveq   #$1e,D0
mt_lop3:
                moveq   #0,D4
                move.w  42(A0),D4
                add.l   D4,D4
                adda.l  D4,A2
                adda.l  #$1e,A0
                dbra    D0,mt_lop3

                move.l  A2,sample_end

                movea.l (A7)+,A0

                rts

; a0=packed sample (also destination)
; d0=unpacked length

depack_sample:
                lea     depack_hi(PC),A2
                lea     depack_lo(PC),A3

                addq.l  #1,D0
                and.b   #-2,D0               ; round length up
                move.l  D0,D7
                lsr.l   #1,D7                ; sample length in words

                lea     0(A0,D0.l),A1        ; destination end
                adda.l  D7,A0                ; source end

                move.w  #128,D0              ; last byte
                moveq   #0,D1                ; clear temp

depack_loop:    move.b  -(A0),D1             ; get 2 distances
                add.b   0(A2,D1.w),D0
                move.b  D0,-(A1)
                add.b   0(A3,D1.w),D0
                move.b  D0,-(A1)

                subq.l  #1,D7
                bne.s   depack_loop

                rts

init_depack:

                lea     depack_lo(PC),A1
                move.w  #15,D7
init1:          lea     power_bytes(PC),A0
                move.w  #15,D6
init2:          move.b  (A0)+,(A1)+
                dbra    D6,init2
                dbra    D7,init1

                lea     power_bytes(PC),A0
                lea     depack_hi(PC),A1
                move.w  #15,D7
init3:          move.w  #15,D6
                move.b  (A0)+,D0
init4:          move.b  D0,(A1)+
                dbra    D6,init4
                dbra    D7,init3

                rts

power_bytes:    DC.B -128,-64,-32,-16,-8,-4,-2,-1,0,1,2,4,8,16,32,64
sample_start:   DC.L 0
sample_end:     DC.L 0
depack_lo:      DS.B 256
depack_hi:      DS.B 256

*---------------------------- Datas & variables 3D curves
tch:		dc.w	0
x:		dc.w	20
ic:		dc.w	-2
pal3:		incbin	e:\code\effects.grx\grafik_s\pal3.bin
tablex:		incbin	e:\code\effects.grx\grille\table2.dat
tabley:		incbin	e:\code\effects.grx\grille\table1.dat
loading:	incbin	loading.dat
*-------------------------------------------------------------------------*
decomp:					
	movem.l	a0-a3/d0-d4,-(sp)	

	move.w	(a0)+,d4		*a0: image compactee
	lea	32(a0),a0		*a1: ecran dest
	cmp.l	#0,a2			*a2: pal 
	beq.s	endifdec2		*d0: hauteur-1
	lea	-32(a0),a0
	rept	8
	move.l	(a0)+,(a2)+
	endr
endifdec2:
	move.l	a0,a2			
	lsl.w	#2,d4			
	add.w	d4,a2	
	moveq.w	#39,d4
	moveq.w	#0,d2
	moveq.l	#0,d3
	move.l	a1,a3
dec:	move.l	a3,a1
	addq.l	#4,a3
	move.w	d0,d1			
dec2:	tst.w	d2
	bne.s	endifdec
	move.b	(a2)+,d2
	move.l	(a0)+,d3
endifdec:
	move.l	d3,(a1)
	lea	160(a1),a1
	subq.w	#1,d2
	dbra.w	d1,dec2
	dbra.w	d4,dec
	
	movem.l	(sp)+,a0-a3/d0-d4
	rts

initsound:
	move.w		#$7ff,$ffff8924.w		* Init microwire
dmwr:	cmp.w		#$7ff,$ffff8924.w
	bne.s		dmwr
	move.w		#%10011101000,d0		* Volume max
	bsr.s		microwrite
	move.w		#%10010000000+aigus,d0		* Aigus 
	bsr.s		microwrite
	move.w		#%10001000000+graves,d0		* Graves
	bsr.s		microwrite
	rts

microwrite:
	moveq.l		#127,d1
wait:	dbra.w		d1,wait
	move.w		d0,$ffff8922.w
	rts


fadesound:	
	moveq.l		#20,d0
temp2:	move.w		#$4c0,d2
	or.w		d0,d2
	add.w		#20,d2
	move.w		d2,$ffff8922.w
	move.w		#7000,d1
temp1:	move.l		4(sp),4(sp)
	dbra.w		d1,temp1
	dbra.w		d0,temp2
	rts

*-------------------------------------------------------------------------*	
save:		dc.w		0
vsync:		dc.w		0
ecran:		dc.l		buffer_ec
flipaff:	dc.w		0
flip_ec:	dc.w		0
bufferec:	dc.l		buffer_ec

*-------------------------------------------------------------------------*	
*-------------------------------------------------------------------------*	
*-------------------------------------------------------------------------*	
*	REPLAY ROUTINE							  *
*-------------------------------------------------------------------------*	
*-------------------------------------------------------------------------*	

muson:	
	move.w	#$2700,sr
	clr.b	$fffffa07.w
	clr.b	$fffffa09.w

	tst.w	$216.w
	beq.s	adieu
	
	bsr.s	vol			; Calculate volume tables
	bsr	incrcal			; Calculate tonetables
                 
	jsr	init			; Initialize music
	jsr	prepare			; Prepare samples

	bclr.b	#3,$fffffa17.w		* Auto vectors
	move.l	#stereo,$70.w
	move.b	#FREQ+1,$FFFF8921.w	; Frequency
	lea	$FFFF8907.w,a0
	move.l	#sample1,d0
	move.b	d0,(a0)
	lsr.w	#8,d0
	move.l	d0,-5(a0)
	move.l	#sample1+LEN*4,d0
	move.b	d0,12(a0)
	lsr.w	#8,d0
	move.l	d0,7(a0)
	move.b	#1,$FFFF8901.w		; Start DMA
	move.w	#$2300,sr
	rts
adieu:	
	move.l	#vbl2,$70.w
	move.w	#$2300,sr
	rts

physb:		dc.l	0
;--------------------------------------------------------- Volume table --
vol:	moveq.l	#64,d0
	lea	vtabend(pc),a0

.ploop:	move.w	#255,d1
.mloop:	move.w	d1,d2
	ext.w	d2
	muls	d0,d2
	divs	#MVOL,d2		; <---- Master volume
	move.b	d2,-(a0)
	dbra	d1,.mloop
	dbra	d0,.ploop

	rts

vtab:	DS.B 65*256
vtabend:

;------------------------------------------------------ Increment-table --
incrcal:lea	stab(pc),a0
	move.w	#$30,d1
	move.w	#$039F-$30,d0
	move.l	#INC,d2

recalc:	swap	d2
	moveq.l	#0,d3
	move.w	d2,d3
	divu	d1,d3
	move.w	d3,d4
	swap	d4

	swap	d2
	move.w	d2,d3
	divu	d1,d3
	move.w	d3,d4
	move.l	d4,(a0)+

	addq.w	#1,d1
	dbra	d0,recalc
	rts

itab:	DS.L $30
stab:	DS.L $03A0-$30

;-------------------------------------------------------- DMA interrupt --
cpt:	dc.l	0

stereo:
	move.b	#1,$FFFF8901.w		; Start DMA

	movem.l	d0-a6,-(sp)
	
	move.l	physb,d0
	move.b	d0,$ffff8209.w
	lsr.w	#8,d0
	move.b	d0,$ffff8207.w
	swap	d0
	move.b	d0,$ffff8205.w
	
	addq.l	#1,cpt
	cmp.l	#10,cpt
	ble.s	okpal
	lea	loading+2,a0
	lea	$ffff8240.w,a1
	rept	8
	move.l	(a0)+,(a1)+
	endr

	moveq.l	#0,d5
	move.w	x,d5			* Palette
	divu.w	#23,d5
	add.w	d5,d5
	lea	pal3,a4			* pointe sur couleur grille
	add.w	d5,a4			
	move.w	(a4),$ffff8240+16.w	* registres shifter
okpal:

	clr.w	vsync

	ifne	cpu
	move.w	#$7,$ffff8240.w
	endc

	move.l	samp1(pc),d0
	move.l	samp2(pc),samp1
	move.l	d0,samp2

	lea	$FFFF8907.w,a0

	move.l	samp1(pc),d0
	move.b	d0,(a0)
	lsr.w	#8,d0
	move.l	d0,-5(a0)
	
	move.l	samp1(pc),d0
	add.l	#LEN*4,d0
	move.b	d0,12(a0)
	lsr.w	#8,d0
	move.l	d0,7(a0)
	
	bsr	music

	lea	itab(pc),a5
	lea	vtab(pc),a3
	moveq.l	#0,d0
	moveq.l	#0,d4

v1:	movea.l	wiz2lc(pc),a0

	move.w	wiz2pos(pc),d0
	move.w	wiz2frc(pc),d1

	move.w	aud2per(pc),d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	0(a5,d7.w),d2

	movea.w	2(a5,d7.w),a4

	move.w	aud2vol(pc),d7
	asl.w	#8,d7
	lea	0(a3,d7.w),a2

	movea.l	wiz3lc(pc),a1

	move.w	wiz3pos(pc),d4
	move.w	wiz3frc(pc),d5

	move.w	aud3per(pc),d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	0(a5,d7.w),d6
	movea.w	2(a5,d7.w),a5

	move.w	aud3vol(pc),d7
	asl.w	#8,d7
	lea	0(a3,d7.w),a3

	movea.l	samp1(pc),a6
	bsr	calc

	cmp.l	wiz2len(pc),d0
	blt.s	.ok2
	sub.w	wiz2rpt(pc),d0

.ok2:	move.w	d0,wiz2pos
	move.w	d1,wiz2frc

	cmp.l	wiz3len(pc),d4
	blt.s	.ok3
	sub.w	wiz3rpt(pc),d4

.ok3:	move.w	d4,wiz3pos
	move.w	d5,wiz3frc

	lea	itab,a5
	lea	vtab,a3
	moveq.l	#0,d0
	moveq.l	#0,d4

v2:	movea.l	wiz1lc(pc),a0

	move.w	wiz1pos(pc),d0
	move.w	wiz1frc(pc),d1

	move.w	aud1per(pc),d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	0(a5,d7.w),d2
	movea.w	2(a5,d7.w),a4

	move.w	aud1vol(pc),d7
	asl.w	#8,d7
	lea	0(a3,d7.w),a2

	movea.l	wiz4lc(pc),a1

	move.w	wiz4pos(pc),d4
	move.w	wiz4frc(pc),d5

	move.w	aud4per(pc),d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	0(a5,d7.w),d6
	movea.w	2(a5,d7.w),a5

	move.w	aud4vol(pc),d7
	asl.w	#8,d7
	lea	0(a3,d7.w),a3

	movea.l	samp1(pc),a6
	addq.w	#1,a6
	bsr	calc

	cmp.l	wiz1len(pc),d0
	blt.s	.ok1
	sub.w	wiz1rpt(pc),d0

.ok1:	move.w	d0,wiz1pos
	move.w	d1,wiz1frc

	cmp.l	wiz4len(pc),d4
	blt.s	.ok4
	sub.w	wiz4rpt(pc),d4

.ok4:	move.w	d4,wiz4pos
	move.w	d5,wiz4frc

	ifne		cpu
	move.w		#3,$ffff8240.w
	endc

	move.l		bufferec,a0		*********** Flip ec
	not.w		flip_ec
	move.w		flip_ec,d0
	and.w		#32000,d0
	add.w		d0,a0
	move.l		a0,ecran
	move.l		a0,physb

	ifne		cpu
	move.w		#$30,$ffff8240.w
	endc

	move.w		ic,d0			* Gestion  zoom
	add.w		d0,x
	move.w		x,d1
	cmp.w		#179*2,d1
	bne.s		ok3
	neg.w		ic
ok3:	cmp.w		#2,d1
	bne.s		ok4
	neg.w		ic
ok4:	
	lea		tabley,a0
	lea		tablex,a1
	move.w		d1,d0
	mulu.w		#13,d1
	add.w		d1,a1

	mulu.w		#20,d0
	add.w		d0,a0

	* AFFICHAGE GRILLE VERTICALE AU BLITTER

	lea		$ffff8a20.w,a5
	move.w		#2,(a5)				* Inc X source
	move.w		#-38,$8a22-$8a20(a5)		* Inc Y source
	move.l		a0,$8a24-$8a20(a5)		* Adr source
	move.l		#$80008,$8a2e-$8a20(a5)		* Inc X & Y dest
	move.l		ecran(pc),a0			*
	addq.w		#6,a0				*
	move.l		a0,$8a32-$8a20(a5)		* Adr dest
	move.l		#20*65536+200,$8a36-$8a20(a5)	* X & Y size
	move.w		#$203,$8a3a-$8a20(a5)		* Hog & combi
	move.b		#%11000000,$8a3c-$8a20(a5)	* Go
	
	ifne		cpu
	move.w		#$70,$ffff8240.w
	endc


	* AFFICHAGE GRILLE HORIZONTALE AU BLITTER

	move.w		#15,$8a3a-$8a20(a5)		* Hog
	
	move.l		ecran(pc),a4
	addq.w		#6,a4
	move.w		#200,d7
	move.w		#%11000000,d6
	moveq.l		#1,d5
	lea		$8a32-$8a20(a5),a5

grillex:
	move.w		(a1)+,d3

	rept		16
	add.w		d3,d3
	dc.w		$6400+10

	move.w		d5,$8a38-$8a32(a5)		* Y size
	move.l		a4,(a5)				* Adr dest
	move.b		d6,$8a3c-$8a32(a5)		* Go

	lea		160(a4),a4
	subq.w		#1,d7				* Compteur	
	beq		endx
	endr

	bra		grillex
endx:

	movem.l	(sp)+,d0-a6

	ifne	cpu
	clr.w	$ffff8240.w
	endc

	ifne	esc
	cmp.b	#1,$fffffc02.w
	bne.s	nofin
	jmp	fin
nofin:
	endc

vbl2:	move.b	$fffffc02.w,tch
	
	rte

calc:	move.w	#$2700,sr
	moveq.l	#0,d3
	exg.l	a6,sp

	rept	len
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.b	d7,(sp)+
	move.b	d7,(sp)+
	endr

	exg.l	a6,sp
	move.w	#$2500,sr
	rts

;-------------------------------------------- Hardware-registers & data --
wiz1lc:		DC.L sample1
wiz1len:	DC.L 0
wiz1rpt:	DC.W 0
wiz1pos:	DC.W 0
wiz1frc:	DC.W 0

wiz2lc:		DC.L sample1
wiz2len:	DC.L 0
wiz2rpt:	DC.W 0
wiz2pos:	DC.W 0
wiz2frc:	DC.W 0

wiz3lc: 	DC.L sample1
wiz3len:	DC.L 0
wiz3rpt:	DC.W 0
wiz3pos:	DC.W 0
wiz3frc:	DC.W 0

wiz4lc: 	DC.L sample1
wiz4len:	DC.L 0
wiz4rpt:	DC.W 0
wiz4pos:	DC.W 0
wiz4frc:	DC.W 0

aud1lc: 	DC.L dummy
aud1len:	DC.W 0
aud1per:	DC.W 0
aud1vol:	DC.W 0
		DS.W 3

aud2lc: 	DC.L dummy
aud2len:	DC.W 0
aud2per:	DC.W 0
aud2vol:	DC.W 0
		DS.W 3

aud3lc:		DC.L dummy
aud3len:	DC.W 0
aud3per:	DC.W 0
aud3vol:	DC.W 0
		DS.W 3

aud4lc:		DC.L dummy
aud4len:	DC.W 0
aud4per:	DC.W 0
aud4vol:	DC.W 0

dmactrl:	DC.W 0

dummy:		DC.L 0

samp1:		DC.L sample1
samp2:		DC.L sample2

sample1:	DS.W LEN*2
sample2:	DS.W LEN*2

;========================================================= EMULATOR END ==

prepare:lea	workspc,a6
	movea.l	samplestarts(pc),a0
	movea.l	end_of_samples(pc),a1

tostack:move.w	-(a1),-(a6)
	cmpa.l	a0,a1			; Move all samples to stack
	bgt.s	tostack

	lea	samplestarts(pc),a2
	lea	data(pc),a1		; Module
	movea.l	(a2),a0			; Start of samples
	movea.l	a0,a5			; Save samplestart in a5

	moveq	#30,d7

roop:	move.l	a0,(a2)+		; Sampleposition

	tst.w	$2A(a1)
	beq.s	samplok			; Len=0 -> no sample

	tst.w	$2E(a1)			; Test repstrt
	bne.s	repne			; Jump if not zero


repeq:	move.w	$2A(a1),d0		; Length of sample
	move.w	d0,d4
	subq.w	#1,d0

	movea.l	a0,a4
fromstk:move.w	(a6)+,(a0)+		; Move all samples back from stack
	dbra	d0,fromstk

	bra.s	rep



repne:	move.w	$2E(a1),d0
	move.w	d0,d4
	subq.w	#1,d0

	movea.l	a6,a4
get1st:	move.w	(a4)+,(a0)+		; Fetch first part
	dbra.w	d0,get1st

	adda.w	$2A(a1),a6		; Move a6 to next sample
	adda.w	$2A(a1),a6



rep:	movea.l	a0,a5
	moveq.l	#0,d1
toosmal:movea.l	a4,a3
	move.w	$30(a1),d0
	subq.w	#1,d0
moverep:move.w	(a3)+,(a0)+		; Repeatsample
	addq.w	#2,d1
	dbra.w	d0,moverep
	cmp.w	#320*5,d1		; Must be > 320
	blt.s	toosmal

	move.w	#320*5/2-1,d2
last320:move.w	(a5)+,(a0)+		; Safety 320 bytes
	dbra.w	d2,last320

done:	add.w	d4,d4

	move.w	d4,$2A(a1)		; length
	move.w	d1,$30(a1)		; Replen
	clr.w	$2E(a1)

samplok:lea	$1E(a1),a1
	dbra.w	d7,roop

	cmp.l	#workspc,a0
	bgt.s	.nospac

	rts

.nospac: illegal

end_of_samples:	DC.L 0

;------------------------------------------------------ Main replayrout --
init:	lea	data(pc),a0
	lea	$03B8(a0),a1

	moveq.l	#$7F,d0
	moveq.l	#0,d1
loop:	move.l	d1,d2
	subq.w	#1,d0
lop2:	move.b	(a1)+,d1
	cmp.b	d2,d1
	bgt.s	loop
	dbra.w	d0,lop2
	addq.b	#1,d2

	lea	samplestarts(pc),a1
	asl.l	#8,d2
	asl.l	#2,d2
	add.l	#$043C,d2
	add.l	a0,d2
	movea.l	d2,a2

	moveq.l	#$1E,d0
lop3:	clr.l	(a2)
	move.l	a2,(a1)+
	moveq.l	#0,d1
	move.w	42(a0),d1
	add.l	d1,d1
	adda.l	d1,a2
	adda.l	#$1E,a0
	dbra.w	d0,lop3

	move.l	a2,end_of_samples	;
	rts

music:	lea	data(pc),a0
	addq.w	#$01,counter
	move.w	counter(pc),d0
	cmp.w	speed(pc),d0
	blt.s	nonew
	clr.w	counter
	bra	getnew

nonew:	lea	voice1(pc),a4
	lea	aud1lc(pc),a3
	bsr	checkcom
	lea	voice2(pc),a4
	lea	aud2lc(pc),a3
	bsr	checkcom
	lea	voice3(pc),a4
	lea	aud3lc(pc),a3
	bsr	checkcom
	lea	voice4(pc),a4
	lea	aud4lc(pc),a3
	bsr	checkcom
	bra	endr

arpeggio:
	moveq.l	#0,d0
	move.w	counter(pc),d0
	divs.w	#$03,d0
	swap	d0
	tst.w	d0
	beq.s	arp2
	cmp.w	#$02,d0
	beq.s	arp1

	moveq.l	#0,d0
	move.b	$03(a4),d0
	lsr.b	#4,d0
	bra.s	arp3

arp1:	moveq.l	#0,d0
	move.b	$03(a4),d0
	and.b	#$0F,d0
	bra.s	arp3

arp2:	move.w	$10(a4),d2
	bra.s	arp4

arp3:	add.w	d0,d0
	moveq.l	#0,d1
	move.w	$10(a4),d1
	lea	periods(pc),a0
	moveq.l	#$24,d4
arploop:move.w	0(a0,d0.w),d2
	cmp.w	(a0),d1
	bge.s	arp4
	addq.l	#2,a0
	dbra.w	d4,arploop
	rts

arp4:	move.w	d2,$06(a3)
	rts

getnew:	lea	data+$043C(pc),a0
	lea	-$043C+$0C(a0),a2
	lea	-$043C+$03B8(a0),a1

	moveq.l	#0,d0
	move.l	d0,d1
	move.b	songpos(pc),d0
	move.b	0(a1,d0.w),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.w	pattpos(pc),d1
	clr.w	dmacon

	lea	aud1lc(pc),a3
	lea	voice1(pc),a4
	bsr.s	playvoice
	lea	aud2lc(pc),a3
	lea	voice2(pc),a4
	bsr.s	playvoice
	lea	aud3lc(pc),a3
	lea	voice3(pc),a4
	bsr.s	playvoice
	lea	aud4lc(pc),a3
	lea	voice4(pc),a4
	bsr.s	playvoice
	bra	setdma

playvoice:
	move.l	0(a0,d1.l),(a4)
	addq.l	#4,d1
	moveq.l	#0,d2
	move.b	$02(a4),d2
	and.b	#$F0,d2
	lsr.b	#4,d2
	move.b	(a4),d0
	and.b	#$F0,d0
	or.b	d0,d2
	tst.b	d2
	beq.s	setregs
	moveq.l	#0,d3
	lea	samplestarts(pc),a1
	move.l	d2,d4
	subq.l	#$01,d2
	asl.l	#2,d2
	mulu.w	#$1E,d4
	move.l	0(a1,d2.l),$04(a4)
	move.w	0(a2,d4.l),$08(a4)
	move.w	$02(a2,d4.l),$12(a4)
	move.w	$04(a2,d4.l),d3
	tst.w	d3
	beq.s	noloop
	move.l	$04(a4),d2
	add.w	d3,d3
	add.l	d3,d2
	move.l	d2,$0A(a4)
	move.w	$04(a2,d4.l),d0
	add.w	$06(a2,d4.l),d0
	move.w	d0,8(a4)
	move.w	$06(a2,d4.l),$0E(a4)
	move.w	$12(a4),$08(a3)
	bra.s	setregs

noloop:	move.l	$04(a4),d2
	add.l	d3,d2
	move.l	d2,$0A(a4)
	move.w	$06(a2,d4.l),$0E(a4)
	move.w	$12(a4),$08(a3)
setregs:move.w	(a4),d0
	and.w	#$0FFF,d0
	beq	checkcom2
	move.b	$02(a4),d0
	and.b	#$0F,d0
	cmp.b	#$03,d0
	bne.s	setperiod
	bsr	setmyport
	bra	checkcom2

setperiod:
	move.w	(a4),$10(a4)
	andi.w	#$0FFF,$10(a4)
	move.w	$14(a4),d0
	move.w	d0,dmactrl
	clr.b	$1B(a4)

	move.l	$04(a4),(a3)
	move.w	$08(a4),$04(a3)
	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	move.w	d0,$06(a3)
	move.w	$14(a4),d0
	or.w	d0,dmacon
	bra	checkcom2

setdma:	move.w	dmacon(pc),d0

	btst.l	#0,d0			;-------------------
	beq.s	wz_nch1			;
	move.l	aud1lc(pc),wiz1lc	;
	moveq.l	#0,d1			;
	moveq.l	#0,d2			;
	move.w	aud1len(pc),d1		;
	move.w	voice1+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz1len		;
	move.w	d2,wiz1rpt		;
	clr.w	wiz1pos			;

wz_nch1:btst.l	#1,d0			;
	beq.s	wz_nch2			;
	move.l	aud2lc(pc),wiz2lc	;
	moveq.l	#0,d1			;
	moveq.l	#0,d2			;
	move.w	aud2len(pc),d1		;
	move.w	voice2+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz2len		;
	move.w	d2,wiz2rpt		;
	clr.w	wiz2pos			;

wz_nch2:btst.l	#2,d0			;
	beq.s	wz_nch3			;
	move.l	aud3lc(pc),wiz3lc	;
	moveq.l	#0,d1			;
	moveq.l	#0,d2			;
	move.w	aud3len(pc),d1		;
	move.w	voice3+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz3len		;
	move.w	d2,wiz3rpt		;
	clr.w	wiz3pos			;

wz_nch3:btst.l	#3,d0			;
	beq.s	wz_nch4			;
	move.l	aud4lc(pc),wiz4lc	;
	moveq.l	#0,d1			;
	moveq.l	#0,d2			;
	move.w	aud4len(pc),d1		;
	move.w	voice4+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz4len		;
	move.w	d2,wiz4rpt		;
	clr.w	wiz4pos			;-------------------

wz_nch4:addi.w	#$10,pattpos
	cmpi.w	#$0400,pattpos
	bne.s	endr
nex:	clr.w	pattpos
	clr.b	break
	addq.b	#1,songpos
	andi.b	#$7F,songpos
	move.b	songpos(pc),d1
	cmp.b	data+$03B6(pc),d1
	bne.s	endr
	move.b	data+$03B7(pc),songpos
endr:	tst.b	break
	bne.s	nex
	rts

setmyport:
	move.w	(a4),d2
	and.w	#$0FFF,d2
	move.w	d2,$18(a4)
	move.w	$10(a4),d0
	clr.b	$16(a4)
	cmp.w	d0,d2
	beq.s	clrport
	bge.s	rt
	move.b	#$01,$16(a4)
	rts

clrport:clr.w	$18(a4)
rt:	rts

myport:	move.b	$03(a4),d0
	beq.s	myslide
	move.b	d0,$17(a4)
	clr.b	$03(a4)
myslide:tst.w	$18(a4)
	beq.s	rt
	moveq.l	#0,d0
	move.b	$17(a4),d0
	tst.b	$16(a4)
	bne.s	mysub
	add.w	d0,$10(a4)
	move.w	$18(a4),d0
	cmp.w	$10(a4),d0
	bgt.s	myok
	move.w	$18(a4),$10(a4)
	clr.w	$18(a4)

myok:	move.w	$10(a4),$06(a3)
	rts

mysub:	sub.w	d0,$10(a4)
	move.w	$18(a4),d0
	cmp.w	$10(a4),d0
	blt.s	myok
	move.w	$18(a4),$10(a4)
	clr.w	$18(a4)
	move.w	$10(a4),$06(a3)
	rts

vib:	move.b	$03(a4),d0
	beq.s	vi
	move.b	d0,$1A(a4)

vi:	move.b	$1B(a4),d0
	lea	sin(pc),a1
	lsr.w	#$02,d0
	and.w	#$1F,d0
	moveq.l	#0,d2
	move.b	0(a1,d0.w),d2
	move.b	$1A(a4),d0
	and.w	#$0F,d0
	mulu	d0,d2
	lsr.w	#$06,d2
	move.w	$10(a4),d0
	tst.b	$1B(a4)
	bmi.s	vibmin
	add.w	d2,d0
	bra.s	vib2

vibmin:	sub.w	d2,d0
vib2:	move.w	d0,$06(a3)
	move.b	$1A(a4),d0
	lsr.w	#$02,d0
	and.w	#$3C,d0
	add.b	d0,$1B(a4)
	rts

nop:	move.w	$10(a4),$06(a3)
	rts

checkcom:
	move.w	$02(a4),d0
	and.w	#$0FFF,d0
	beq.s	nop
	move.b	$02(a4),d0
	and.b	#$0F,d0
	tst.b	d0
	beq	arpeggio
	cmp.b	#$01,d0
	beq.s	portup
	cmp.b	#$02,d0
	beq	portdown
	cmp.b	#$03,d0
	beq	myport
	cmp.b	#$04,d0
	beq	vib
	cmp.b	#$05,d0
	beq	port_toneslide
	cmp.b	#$06,d0
	beq	vib_toneslide
	move.w	$10(a4),$06(a3)
	cmp.b	#$0A,d0
	beq.s	volslide
	rts

volslide:
	moveq.l	#0,d0
	move.b	$03(a4),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.s	voldown
	add.w	d0,$12(a4)
	cmpi.w	#$40,$12(a4)
	bmi.s	vol2
	move.w	#$40,$12(a4)
vol2:	move.w	$12(a4),$08(a3)
	rts
 
voldown:moveq.l	#0,d0
	move.b	$03(a4),d0
	and.b	#$0F,d0
	sub.w	d0,$12(a4)
	bpl.s	vol3
	clr.w	$12(a4)
vol3:	move.w	$12(a4),$08(a3)
	rts

portup:	moveq.l	#0,d0
	move.b	$03(a4),d0
	sub.w	d0,$10(a4)
	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	cmp.w	#$71,d0
	bpl.s	por2
	andi.w	#$F000,$10(a4)
	ori.w	#$71,$10(a4)
por2:	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	move.w	d0,$06(a3)
	rts

port_toneslide:
	bsr	myslide
	bra.s	volslide

vib_toneslide:
	bsr	vi
	bra.s	volslide

portdown:
	clr.w	d0
	move.b	$03(a4),d0
	add.w	d0,$10(a4)
	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	cmp.w	#$0358,d0
	bmi.s	por3
	andi.w	#$F000,$10(a4)
	ori.w	#$0358,$10(a4)
por3:	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	move.w	d0,$06(a3)
	rts

checkcom2:
	move.b	$02(a4),d0
	and.b	#$0F,d0
	cmp.b	#$0D,d0
	beq.s	pattbreak
	cmp.b	#$0B,d0
	beq.s	posjmp
	cmp.b	#$0C,d0
	beq.s	setvol
	cmp.b	#$0F,d0
	beq.s	setspeed
	rts

pattbreak:
	st	break
	rts

posjmp:	move.b	$03(a4),d0
	subq.b	#$01,d0
	move.b	d0,songpos
	st	break
	rts

setvol:	moveq.l	#0,d0
	move.b	$03(a4),d0
	cmp.w	#$40,d0
	ble.s	vol4
	move.b	#$40,$03(a4)
vol4:	move.b	$03(a4),$09(a3)
	move.b	$03(a4),$13(a4)
	rts

setspeed:
	cmpi.b	#$1F,$03(a4)
	ble.s	sets
	move.b	#$1F,$03(a4)
sets:	move.b	$03(a4),d0
	beq.s	rts2
	move.w	d0,speed
	clr.w	counter
rts2:	rts

sin:	DC.B $00,$18,$31,$4A,$61,$78,$8D,$A1,$B4,$C5,$D4,$E0,$EB,$F4,$FA,$FD
	DC.B $FF,$FD,$FA,$F4,$EB,$E0,$D4,$C5,$B4,$A1,$8D,$78,$61,$4A,$31,$18

periods:DC.W $0358,$0328,$02FA,$02D0,$02A6,$0280,$025C,$023A,$021A,$01FC,$01E0
	DC.W $01C5,$01AC,$0194,$017D,$0168,$0153,$0140,$012E,$011D,$010D,$FE
	DC.W $F0,$E2,$D6,$CA,$BE,$B4,$AA,$A0,$97,$8F,$87
	DC.W $7F,$78,$71,$00,$00

speed:	DC.W $06
counter:DC.W $00
songpos:DC.B $00
break:	DC.B $00
pattpos:DC.W $00

dmacon:		DC.W $00
samplestarts:	DS.L $1F

voice1:	DS.W 10
	DC.W $01
	DS.W 3
voice2:	DS.W 10
	DC.W $02
	DS.W 3
voice3:	DS.W 10
	DC.W $04
	DS.W 3
voice4:	DS.W 10
	DC.W $08
	DS.W 3

data:	incbin	d:\sndtrack\modules\tcn\loader.mod

	Section 	bss

		DS.b	22500			; Workspace
workspc:	DS.W	1
*-------------------------------------------------------------------------* 
*	Buffer ecran							  *
*-------------------------------------------------------------------------* 

		ds.b	256
buffer_ec:	ds.b	200*160*2

</xmp>
