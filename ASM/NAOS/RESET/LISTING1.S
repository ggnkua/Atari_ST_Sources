*            LISTING No 1            *
*     Bloc gestionnaire de RESET     *
*                                    *
* Ce code est entierement relogeable * 
*   Son utilisation necessite juste  *
*     un appel a la routine Init     *
* Voir le listing d'exemple fournit  *
*                                    *
*    ST Mag - Ric de NAOS - 1993     *

TrapVect	equ	$80

; Placez plutot la base video en fin 
; de ram par defaut.
Video_base	equ	$78000

Init	move.l	#$31415926,$426.w
	lea	Reset(pc),a0
	move.l	a0,$42a.w
; Sauve le Vector Register du MFP
	lea	Mfp(pc),a0
	move.b	$fffffa17.w,(a0)
	rts

Reset	
* A > Initialisation hardware du ST
	move.w	#$2700,sr
; installation d'une pile
	lea	Pile(pc),sp
	
; Reinitialisation du MFP, mais 
; coupe toutes ses interruptions
	lea	$fffffa01.w,a0
; Autorisations IERA-IERB
	move.b	#0,6(a0)	
	move.b	#0,8(a0)
; En cours ISRA-ISRB
	move.b	#0,14(a0)
	move.b	#0,16(a0)
; Masques IMRA-IMRB
	move.b	#0,18(a0)
	move.b	#0,20(a0)
; Restaure le Vector Register
	move.b	Mfp(pc),22(a0)
; Controles TACR-TBCR et TCDCR
	move.b	#0,24(a0)
	move.b	#0,26(a0)
	move.b	#0,28(a0)
; it. VBL par d‚faut
	lea	Rte(pc),a0
	move.l	a0,$70.w
	stop	#$2300
; Chip Video
; (valide l'adresse video)
	move.l	#Video_base,d0
	move.l	d0,$44e.w
	lsr.w	#8,d0
	move.b	d0,$ffff8203.w
	swap	d0
	move.b	d0,$ffff8201.w
; (frequence video = 50 Hz)
	move.b	#2,$ffff820a.w
; (basse resolution)
	move.w	#0,$ffff8260.w

; (efface la ram video)
	move.w	#7999,d7
	moveq	#0,d0
	move.l	#Video_base,a0
ClrVIDEO	move.l	d0,(a0)+
	dbf	d7,ClrVIDEO

; D‚s‚lection des drives
	move.b	#14,$ffff8800.w
	move.b	$ffff8800.w,d7
; bits 0 … 3 mis … 1
	ori.b	#$7,d7
	move.b	d7,$ffff8802.w

* B > Initialisation soft du programme

; Routine de relocation (cf STMag 74)	
	lea	Charge(pc),a0
	move.l	2(a0),d0
	add.l	6(a0),d0		
	move.l	d0,d1
	add.l	$e(a0),d0	
	
	lea	$1c(a0),a0		
	add.l	a0,d1
; adresse de fin du programme
; (debut de la zone BSS)
	lea	End(pc),a2
	move.l	d1,(a2)
	lea	0(a0,d0.l),a1	
; on ne d‚place pas le programme
	lea	LogAdr(pc),a2
	move.l	a0,(a2)

	add.l	(a1)+,a0
	move.l	LogAdr(pc),d1
	add.l	d1,(a0)
	moveq	#0,d0
	
BclReloc	move.b	(a1)+,d0
	tst.b	d0	
	beq.s	FinReloc
	cmp.b	#1,d0
	beq.s	IncrAdr
	add.w	d0,a0
	move.l	LogAdr(pc),d1
	add.l	d1,(a0)
	bra.s	BclReloc
IncrAdr	lea	$fe(a0),a0
	bra.s	BclReloc

; Effacement de sa section BSS	
FinReloc	lea	Charge(pc),a0
	move.l	$a(a0),d0
	move.l	End(pc),a1
ClrBSS	clr.b	(a1)+
	dbf	d0,ClrBSS

; Reprise de quelques exceptions
	lea	TrapVect.w,a0
	lea	Trp1(pc),a1
	lea	Rte(pc),a2
	move.l	a1,4(a0)
	move.l	a2,4*13(a0)
	move.l	a2,4*14(a0)

; d‚sactive le reset aprŠs le premier
; appel (pour permettre a l'utilisateur
; de rebooter apres la reset demo)
	clr.l	$426.w
	clr.l	$4d2.w
	
; Execution de l'ecran en reset demo
	move.l	LogAdr(pc),a0
	jmp	(a0)

Rte	rte

Trp1	tst.w	6(sp)
	bne.s	FinTrp1
	move.l	$0,sp
	move.l	$4,a0
	jmp	(a0)
FinTrp1	rte

Mfp	dc.l	0
LogAdr	dc.l	0
End	dc.l	0

; une pile de 256 mots longs	
	ds.l	$100	
Pile	ds.l	1

; Normalement, vous chargez ici votre prg
Charge	incbin	a:\music.prg
