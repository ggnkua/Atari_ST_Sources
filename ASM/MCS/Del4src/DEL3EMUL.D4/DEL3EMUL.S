	TEXT
	
ECRAN	EQU	$70000

	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	
	MOVE.W	#$2700,SR

	CLR.B	$FFFF8260.W
	MOVE.B	#$7,$FFFF8201.W
	MOVE.B	#$0,$FFFF8203.W

	MOVE.W	#$60FE,$78000

	MOVE.L	#NULL,$120.W
	MOVE.L	#NULL_VBL,$70.W
	MOVE.L	#PLANTE,$8.W
	MOVE.L	#PLANTE,$C.W
	MOVE.L	#PLANTE,$10.W
	MOVE.L	#$31415926,$426.W
	MOVE.L	#$78000,$42A.W
	BCLR	#3,$FFFFFA17.W
	MOVE.W	#$2300,SR

	LEA	ECRAN,A0
	MOVEQ	#0,D0
	MOVE.W	#7999,D1
EFF_SCR
	MOVE.L	D0,(A0)+
	DBRA	D1,EFF_SCR

	MOVE.W	#$0,$FFFF8240.W
	MOVE.W	#$606,$FFFF8242.W

	LEA	ECRAN+160*32,A0
	LEA	INSERTD3,A1
	MOVE.W	#40*16-1,D1
AFF_INSERT_DEL_3
	MOVE.L	(A1)+,(A0)+
	DBRA	D1,AFF_INSERT_DEL_3

WAIT_SPACE
	CMP.B	#$39,$FFFC02
	BNE.S	WAIT_SPACE
	
	MOVEQ	#2,D2
	BSR	SETDRIVE

	MOVEQ	#0,D3
	BSR	SETSIDE

	MOVEQ	#14,D0
	BSR	LOAD_SEC

	LEA	ECRAN+160*32,A0
	LEA	DEL_2_75,A1
	MOVE.W	#40*32-1,D1
AFF_DEL275
	MOVE.L	(A1)+,(A0)+
	DBRA	D1,AFF_DEL275

	MOVEQ	#24,D0
	BSR	LOAD_SEC
	
	LEA	DEL_3,A1
	LEA	ECRAN+160*56,A0
	MOVE.W	#40*16-1,D1
AFF_DEL3
	MOVE.L	(A1)+,(A0)+
	DBRA	D1,AFF_DEL3
	
	MOVEQ	#29,D0
	BSR	LOAD_SEC

	
                lea     BOMBES,A0
                lea     ECRAN+160*92,A1
                moveq   #15,D1
AFF_BOMBES:
                move.w  (A0)+,D2
                move.w  D2,(A1)
                move.w  D2,8(A1)
                move.w  D2,16(A1)
                lea     160(A1),A1
                dbra    D1,AFF_BOMBES

	LEA	$FFFF8209.W,A0
	MOVE.W	#0,(A0)

LOAD_SEC
	MOVE.L	D0,D7
CHARGE_SEC
	MOVE.L	D7,-(SP)

	MOVE.L	D7,D0
	BSR	SEEK_TRACK

	MOVEQ	#1,D1
	LEA	BUF_SEC,A1
	BSR	READ_SECTOR

	MOVE.L	#6000,D1
BC_NOP
	DIVU	#1,D0
	DBRA	D1,BC_NOP

	MOVE.L	(SP)+,D7

	DBRA	D7,CHARGE_SEC

	RTS

NULL
	RTE
NULL_VBL
	CLR.B	$FFFF8260.W
	RTE
PLANTE
	BRA.S	PLANTE

;***********************  Restore FDC ****************************

RESTORE:

                move.w  #$80,$FFFF8606.W  ; S‚lection du Command-Reg.
                move.w  #1,D7		; Command => Restore
                bsr   WRT1772         ; Envoi de la commande
                bsr   FDCWAIT         ; Attente jusqu'… ce que FDC soit prˆt
                rts

;***********************  SEEK TRACK  ****************************

SEEK_TRACK:

                move.w  #$86,$FFFF8606.W  ; S‚lection du registre de donn‚es
                move.w  D0,D7           ; Tracknr. dans d7
                bsr   WRT1772         ; Ecrire Tracknr.
                move.w  #$80,$FFFF8606.W  ; S‚lection du Command-Reg.
                move.w  #$11,D7         ; Command => Seek
                bsr   WRT1772         ; Ecrire commande
                bsr   FDCWAIT         ; Attente jusqu'… ce que FDC soit prˆt
                rts

;*************************  Step in  *****************************

STEPIN:

                move.w  #$80,$FFFF8606.W  ; S‚lection du FDC-Commandreg.
                move.w  #$51,D7 	; Command => Step in
                bsr   WRT1772         ; Ecrire commande
                bsr   FDCWAIT         ; Attente jusqu'… ce que FDC soit prˆt
                rts

;***********************  Force Interrupt  ***********************

FORCE:

                move.w  #$D0,D7  ; Command => Force Interrupt
                bsr   WRT1772         ; Ecrire commande
                move.w  #$0100,D7       ; Boucle de temporisation
WTFRC:
                dbra    D7,WTFRC
                rts

;*********************  READ SECTOR(S)  **************************

READ_SECTOR:

                move.l  A1,D7           ; DMA-Adress sur tampon de secteur
                bsr   SETDMA

      	MOVE.W  #$90,$FF8606
      	MOVE.W  #$190,$FF8606
      	MOVE.W  #$90,$FF8606
      	MOVE.W  #1,$FF8604
      	MOVE.W  #$80,$FF8606
      	MOVE.W  #$80,$FF8604

                move.w  #$84,$FFFF8606.W  ; S‚lectionner Sector-Reg.
                move.w  D1,D7           ; Sektor-Nr. dans d7
                bsr   WRT1772         ; Ecrire Sektor-Nr.

                move.w  #$80,$FFFF8606.W  ; S‚lection du Command-Reg.
                move.w  #$84,D7         ; Command => Read multiple Sectors
                bsr     WRT1772         ; Ecrire commande

                bsr   FDCWAIT         ; attente jusqu'… ce que FDC soit prˆt
                bsr.s   READSTAT        ; Lire ‚tat et nbr d'octets
                rts

;********************  Set DMA-Transfer Adress  *****************

SETDMA:

                move.l  D7,ADD_DEB       ; Mettre Start-Adress dans FDC-Array
                move.b  D7,$FFFF860D.W       ; Ecrire d'abord  Low-Byte
                lsr.l   #8,D7
                move.b  D7,$FFFF860B.W       ; puis Mid-Byte
                lsr.l   #8,D7
                move.b  D7,$FFFF8609.W      ; et enfin  High-Byte

                move.l  ADD_DEB,D7       ; R‚cup‚ration de la Start-Adress
                moveq   #0,D6
		move.w	#512,d6
                add.l   D6,D7           ; Addition des deux
                move.l  D7,ADD_FIN       ; =Adresse de fin attendue
                rts

;*** Lecture du DMA-Status; calcul des octets … transf‚rer  ***

READSTAT:

                move.w  $FFFF8606.W,D5      ; Lecture du DMA-Status
                and.w   #$07,D5         ; Prendre seulement les 3 bits inf‚rieurs
                move.w  D5,14(A5)       ; ert aprŠs fdcout

                moveq   #0,D5           ; Lecture de la DMA-Endadress
                move.b  $FFFF8609.W,D5
                lsl.l   #8,D5
                move.b  $FFFF860B.W,D5
                lsl.l   #8,D5
                move.b  $FFFF860D.W,D5

                move.l  D5,24(A5)       ; End-Adress dans Array
                sub.l   20(A5),D5       ; End-Adr. moins Start-Adr.
                move.w  D5,18(A5)       ; =Nombre d'octets
                rts

;*****************    Ecriture du FDC-Register    *******************

WRT1772:

                bsr   WAIT
                move.w  D7,$FFFF8604.W      ; Ecrire FDC-Reg. ou DMA-Sectorcount
                bsr   WAIT
                rts

;*****************     Lecture du FDC-Register      ********************

READ1772:

                bsr   WAIT
                move.w  $FFFF8604.W,D5      ; Lire FDC-Reg. ou DMA-Sectorcount
                bsr   WAIT
                rts

;****************    Attente jusqu'… ce que FDC soit prˆt *****************

FDCWAIT:

                move.l  #$0180,D5       ; Attendre un peu jusqu'… ce Busy soit positionn‚
LITLWT:         dbra    D5,LITLWT
                move.l  #$040000,D5     ; d5 sert de compteur Timeout

READMFP         btst    #5,$FFFFFA01.W          ; Commande finie ?
                beq.s   FDCREADY        ; oui
                subq.l  #1,D5           ; non, D‚cr‚menter compteur Timeout
                beq.s   TIMEOUT         ; Si arriv‚ … la fin
                BRA.S   READMFP         ; non, Continuer le test
                move.b  $FFFF8609.W,ADD_FIN+1 ; C'est la  DMA-Endadress attendue
                move.b  $FFFF860B.W,ADD_FIN+2 ; d‚j… atteinte ?
                move.b  $FFFF860D.W,ADD_FIN+3
                move.l  ADD_FIN,D7
                cmp.l   ADD_END,D7
                blt.s   READMFP         ; non, continuer … tester
                bsr   FORCE           ; Si oui, interrompre la commande
                bra.s     FDCREADY        ; et quitter normalement la routine
TIMEOUT:
                move.w  $FFFF8604.W,D5      ; Lire l'‚tat avant l'interruption
                and.w   #$FF,D5         ; Masquer l'octet de poids fort
                move.w  D5,STATUS	;12(A5)       ; Et mettre dans l'Array
                bsr   FORCE           ; ArrŠter la commande
		MOVEQ	#-1,D4		* PROBLEME
                rts
FDCREADY:
                move.w  $FFFF8604.W,D5      ; Lire l'‚tat
                and.w   #$FF,D5         ; Masquer l'octet de poids fort
                move.w  D5,STATUS	;12(A5)       ; et mettre dans le FDC-Array	*ICI
                rts

;************  Attendre jusqu'… ce que le moteur soit arrŠt‚ ************

MOTOR_OFF:

                move.w  #$80,$FFFF8606.W  ; S‚lection du Statusreg.
TEST:
                bsr     READ1772        ; et lecture
                btst    #7,D5           ; Motor-on positionn‚
                bne.s   TEST            ; oui, continuer l'attente
                rts

;*************************    Wait   *****************************

WAIT:
                move    SR,-(SP)        ; Sauvegarder Status
                move.w  #$20,D5         ; d5 sert de compteur
WT2:
                dbra    D5,WT2
                move    (SP)+,SR        ; R‚cup‚rer Status
                rts

;*****************  SELECTION DE LA FACE  *******************************

SETSIDE
      MOVE    SR,-(A7)
      ORI.W   #$700,SR
      MOVE.B  #$E,$FFFF8800.W
      MOVE.B  $FFFF8800.W,D7 
      CMP.B   #0,D3
      BNE.S   FACE1
      BSET    #0,D7
      BRA.S   O.K.
FACE1 BCLR    #0,D7
O.K.  MOVE.B  D7,$FFFF8802.W 
      MOVE    (A7)+,SR
      RTS 

;*****************  S‚lection du lecteur et de la piste  ****************

SETDRIVE:
	      cmp.b   #0,d2
                bne.s   SET
                bsr.s   MOTOR_OFF        ; Si 0, d'abord d‚selectionner quand motor OFF
SET:
                eori.b  #7,D2           ; Inverser les Bits pour le  Hardware
                and.b   #7,D2           ; Seuls les 3 Low-Bits sont modifi‚s
                move    SR,-(SP)        ; Sauvegarder Status
                ori     #$0700,SR       ; D‚sactiver Interruptions
                move.b  #$0E,$FFFF8800.W   ; S‚lectionner Port A du Sound-Chips
                move.b  $FFFF8800.W,D5     ; Lire Port A
                and.b   #$F8,D5         ; Effacer Bits 0-2
                or.b    D5,D2           ; Positionner nouveaux bits
                move.b  D2,$FFFF8802.W  ; Et ‚crire sur  Port A
                move    (SP)+,SR        ; restore Status
	      bsr	    RESTORE
                rts

;***************************** FIN ******************************
ADD_DEB		DC.L	0
ADD_FIN		DC.L	0
ADD_END		DC.L	0
STATUS		DC.W	0

INSERTD3
	INCBIN	INSERTD3.IMG
DEL_2_75
	INCBIN	DEL2_75.IMG
DEL_3
	INCBIN	DEL_3.IMG
BOMBES:
                DC.W $0600,$2900,$80,$4840
                DC.W $11F0,$01F0,$07FC,$0FFE
                DC.W $0FFE,$1FFF,$1FEF,$0FEE
                DC.W $0FDE,$07FC,$03F8,$E0

BUF_SEC
	DS.B	512