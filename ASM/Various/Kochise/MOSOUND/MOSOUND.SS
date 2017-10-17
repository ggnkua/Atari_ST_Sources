; /// Motion Sound Player - KOSS 1999 ///
; Massive Extensive System    by KOSS       1999
; Sound Data & Sound Sequence by AGGRESSION 1995

; Hi Guivol, here's something REALY useless...
; Based on my original PRAW Player V1.29

	comment	HEAD=7
	
	SECTION	TEXT
	
	movea.l	(4,SP),A6	; Adresse de la BASEPAGE
	move.l	($C,A6),D0	; Taille du SEGMENT TEXT
	add.l	($14,A6),D0	; Additionne la taille du SEGMENT DATA … D0
	add.l	($1C,A6),D0	; Additionne la taille du SEGMENT BSS … D0
	addi.l	#$100,D0	; Additionne la taille de la BASEPAGE … D0
	addi.l	#$400,D0	; Additionne la taille de la future PILE (Ici, 256 positions longues (1024 OCTETS))
	move.l	D0,D1	; Copie D0 dans D1 (Taille … r‚server)
	move.l	D0,D7
	add.l	A6,D1	; Additionne l'adresse du d‚but du programme avec D1 (La taille … r‚server)
	andi.l	#-2,D1	; Rend D1 pair (Au cas o— il ne l'‚tait pas)
	subq.l	#8,D1	; Garde de la place pour l'adresse de la BASEPAGE
	move.l	(4,SP),D2	; Sauvegarde l'adresse de la BASEPAGE
	movea.l	D1,SP	; Installe l'adresse de fin du programme+place nouvelle PILE dans la PILE
	move.l	D2,(4,SP)	; R‚installe l'adresse de la BASEPAGE
	move.l	D0,-(SP)	; EmPILE la taille … r‚server
	move.l	A6,-(SP)	; EmPILE l'adresse du programme
	clr.w	-(SP)	; R‚serv‚
	move.w	#$4A,-(SP)	; - M_SHRINK -
	trap	#1	; *** GEMDOS ***
	lea	(12,SP),SP

	tst.w	D0
	BNE	P_Term
	
	pea	MotionText
	move.w	#9,-(SP)	; - C_CONWS -
	trap	#1	; *** GEMDOS ***
	addq.l	#6,SP
	
	; *** Massive Extensive System ***
	
	lea	MotionSeqBnk,A0
	
MotionPlayer	move.l	(A0)+,D0
	BEQ	MotionReturn
	
	move.l	D0,A1
	
	BRA	MotionNext
	
MotionReturn	subq.l	#8,A0	; Loop on the last Sequence

	BRA	MotionPlayer
	
MotionNext	clr.w	D0
	move.b	(A1)+,D0	; Sample Number
	BEQ	MotionPlayer	; End of a Sequence
	
	subq.w	#1,D0
	lea	MotionSmpBnk,A2
	move.l	(A2,D0.w*4),D2	; Start Address
	move.l	(4,A2,D0.w*4),D3	; End Address

	movem.l	A0-A2,-(SP)
	
	pea	SmpPlayer	; Play with DMA
	move.w	#$26,-(SP)	; - SUPEXEC -
	trap	#14	; *** XBIOS ***
	addq.l	#6,SP
	
	movem.l	(SP)+,A0-A2
	
	BRA	MotionNext	; Next Sample

P_Term	move.w	D0,-(SP)
	move.w	#$4C,-(SP)	; - P_TERM -
	trap	#1	; *** GEMDOS ***

	; *** SMP Player ***
	; Qual : 8Bits Mono
	; Freq : 12.5KHz

SmpPlayer	movea.l	#$FFFF8901,A3
	movea.l	#$FFFF890D,A4

	movep.l	D2,(A3)	; Start
	movep.l	D3,(A4)	; End

	move.w	#%10000001,$FFFF8920.w	; Init. DMA
	move.w	#1,$FFFF8900.w		; Run DMA

TestDMA	tst.w	$FFFF8900.w
	nop
	BNE	TestDMA	; Wait End of DMA

	RTS

	SECTION	DATA

MotionText	dc.b	27,"E/// Motion Sound Player - KOSS 1999 ///",13,10
	dc.b	"Massive Extensive System    by KOSS       1999",13,10
	dc.b	"Sound Data & Sound Sequence by AGGRESSION 1995",13,10,13,10
	dc.b	" To STOP the Music, just Reset your Machine...",13,10,0

	; *** Sound Data ***

MotionSmpBnk	dc.l	MotionBnk1
	dc.l	MotionBnk2
	dc.l	MotionBnk3
	dc.l	MotionBnk4
	dc.l	MotionBnk5
	dc.l	MotionBnk6
	dc.l	MotionBnk7
	dc.l	MotionBnk8
	dc.l	MotionBnk9
	dc.l	MotionBnkA

MotionBnk1	incbin	MOTION01.SMP
	EVEN
MotionBnk2	incbin	MOTION02.SMP
	EVEN
MotionBnk3	incbin	MOTION03.SMP
	EVEN
MotionBnk4	incbin	MOTION04.SMP
	EVEN
MotionBnk5	incbin	MOTION05.SMP
	EVEN
MotionBnk6	incbin	MOTION06.SMP
	EVEN
MotionBnk7	incbin	MOTION07.SMP
	EVEN
MotionBnk8	incbin	MOTION08.SMP
	EVEN
MotionBnk9	incbin	MOTION09.SMP
	EVEN
MotionBnkA	dc.w	0

	; *** Sequences ***

MotionSeqBnk	dc.l	MotionIntroSeq
	dc.l	MotionLoopSeq
	dc.l	0

MotionIntroSeq	dc.b	1,1,2,2,3,4,5,0
MotionLoopSeq	dc.b	3,4,6,7,9,8,9,6
	dc.b	3,4,8,6,7,9,5,9
	dc.b	8,6,6,5,2,0
	
	SECTION	BSS
	
	