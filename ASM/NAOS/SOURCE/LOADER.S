*
*     LOADER   F D C   sous Interruption
*                         par  Ric  de  NAOS
*     ST Mag , Fev. 1993, revu en Octobre
* 
*  … assembler sous loader.bin

	opt x+

TEST	EQU	0	; 1 pour tester
			; 0 pour version a ecrire

	include	e:\final\source\equiv.s

Starttrack	equ	$12
Startsect	equ	1
Nbtrack	equ	$11
Nbsect	equ	Nbtrack*10
StartSide	equ	0

MAIN	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,Stack 

	IFNE	TEST
Nb_of_trk	set	80
	; Init des variables locales
	move.w	#Starttrack,Track
	move.w	#Startsect,Sect
	move.w	#Nbsect,Sect_to_read
 	move.l	#$300000,Dest_adr
 	move.w	#StartSide,Side
 	st	EndMode
 	st	ClearRam
 	move.w	#Nb_of_trk,MaxTrack
	ENDC

**********************************************
*****    MISE EN PLACE DES ANIMATIONS    *****
**********************************************

	move.b	#0,$ffff8260.w
	lea	$ffff8240.w,a0
	move.w	#15,d0
Black	clr.w	(a0)+
	dbf	d0,Black

	move.l	screen,d0
	lsr.w	#8,d0
	move.b	d0,$ffff8203.w
	swap	d0
	move.b	d0,$ffff8201.w

	tst.b	ClearRam
	beq.s	nocls
; Reinitialisation des variables d'anim. 
	move.w	#0,Sd1
	move.w	#3*15*160,Sd2
	move.w	#0,AWait
	move.l	#Mess,PointMs
; Effacement de l'ecran
	move.l	screen,a0
	move.w	#7999,d7
cls	clr.l	(a0)+
	dbf	d7,cls
nocls
	move.w 	#$725,$ffff8250.w
 	move.w 	#$607,$ffff8242.w

	tst.b	zic_flag
	bne.s	pas_init
; Init de la musique la premiere fois seulement
	st	zic_flag
	moveq	#1,d0
	jsr	ZIC
pas_init
	move.l	$70.w,-(sp)

; Mise en place de la VBL d'anim.
	move.l	#VBL,$70.w
	
**********************************************
*****      DEBUT DE LA GESTION FDC      ******
**********************************************

	move.w	#1,$43e.w
	move.l	Dest_adr,Adr_DMA
; sauvegarde des vecteurs et registres d'IT
	move.l	$11c.w,-(sp)
	move.b	$fffffa09.w,-(sp)
	move.b	$fffffa15.w,-(sp)
	move.b	$fffffa17.w,-(sp)
; Automatic End of Interrupt
	bclr	#3,$fffffa17.w	

; S‚lection du drive
	moveq	#0,d0	; Drive A
	move.w	Side,d1
	bsr	Set_drive
	move.w	Side,d1
	tst.w	d1
	bne.s	InvSens
	move.w	#1,Sens
	bra.s	OkSens
InvSens	move.w	#-1,Sens
OkSens	
; Prepare l'octet de commande pour la commande STEP
	lsl.w	#5,d1
	add.w	#$53,d1
	move.w	d1,StepCmd
	
	bsr	Force_IT
;	bsr	Restore

; PremiŠre op‚ration et lancement du processus
	bsr	Lance

; Attente que tout se termine 
Wait	tst.w	Activity_Flag
	bne.s	Wait

	tst.b	EndMode
	beq.s	no_unselect
	bsr	Unselect_All
no_unselect	

; Restaure l'‚tat initial
	move.b	(sp)+,$fffffa17.w
	move.b	(sp)+,$fffffa15.w
	move.b	(sp)+,$fffffa09.w
	move.l	(sp)+,$11c.w
	clr.w	$43e.w

**********************************************
*****      FIN  DE LA GESTION FDC       ******
**********************************************

; Decompacteur	
	move.l	Dest_adr,a0
	jsr	decrunch
	
	tst.b	EndMode
	beq.s	no_fade
	
	move.w 	#$365,$ffff8250.w
	
cla	stop	#$2300
	cmp.b	#$39,$fffffc02.w
	bne.s	cla
	
	move.l	#vbl_fade,$70.w
	move.l	#$08000000,$ffff8800.w
	move.l	#$09000000,$ffff8800.w
	move.l	#$0A000000,$ffff8800.w
	
	lea	fade_seq,a6
	moveq	#3,d6	; 4 valeurs
fade	moveq	#8,d7
	bsr	sync
	move.w 	(a6)+,$ffff8250.w
 	move.w 	(a6)+,$ffff8242.w
 	dbf	d6,fade
 	clr.w	$ffff8250.w
 	clr.w	$ffff8242.w

no_fade	move.l	(sp)+,$70.w
	
	move.l	Stack,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	
	clr.w	-(sp)
	trap	#1

zic_flag	dc.w	0
fade_seq	dc.w	$365,$607,$243,$405,$122,$203,$011,$101

**********************************************
***       SOUS ROUTINES D'ANIMATION        ***
**********************************************

vbl_fade	addq.w	#1,cnt
	rte

sync	move.w	cnt,d0
.vbl	cmp.w	cnt,d0
	beq.s	.vbl
	dbf	d7,sync
	rts
cnt	dc.w	0
	
VBL:      	movem.l	d0-a6,-(sp)
	jsr	Zic+8

	move.l	screen,a4
	lea	Font,a0
	move.w	Sd1,d1	
	move.w	Sd2,d2
	move.l	PointMs,a1
	
	tst.w	AWait	; Est-on en attente ?
	beq	AllRight	;    Si oui...
	sub.w	#1,AWait 	; ... alors on passe son tour !
	bra	FinVbl
	
AllRight	clr.w	d0
	jsr	CursOff
	move.b	(a1)+,d0	; Carac suivant

	tst.b	d0	; Fin ?
	bne.s 	Suit1
	lea	Mess,a1
	clr.w	d1
	move.b	(a1)+,d0
	
Suit1	sub.b	#$20,d0

	cmp.b	#$43,d0	; Commande CLEAR ?	
	bne	Cont1	;   'c' 
	move.w	#3206,Time
	lea	6(a4,d2.w),a3
	move.w	#13*20,d7
	moveq	#0,d1	
ClsCom	move.w	d1,(a3)	
	lea	8(a3),a3
	dbf	d7,ClsCom
	bra	FinVbl

Cont1	cmp.b	#$57,d0	; Commande WAIT ?
	bne	Cont2	;   'w'
	move.w	#68,Time
	move.w	#20,AWait
	bra	FinVbl
	
Cont2	cmp.b	#$44,d0	; Commande DOWN ?
	bne	Cont3	;   'd'
	add.w	#15*160,d2		
	bra	FinVbl		
	
Cont3	cmp.b	#$55,d0	; Commande UP ?
	bne	Cont4	;   'u'
	sub.w	#15*160,d2		
	bra	FinVbl		

Cont4	cmp.b	#$46,d0	; Commande FEED ?
	bne	Cont5	;   'f'
	clr.w	d1		
	bra	FinVbl		
	
Cont5	cmp.b	#$42,d0		
	bne	Cont6		
	subq.w	#2,d1		
	bra	FinVbl		
		
Cont6	cmp.b	#39,d0		
	bls	Ok		
	add.w	#40*17,d0		
Ok	lea	0(a0,d0.w),a2	
	move.l	#0,a3		
	lea	Tab,a5		
	move.w	0(a5,d1.w),a3	
	add.l	a4,a3		
	add.w	d2,a3		
	add.w	#2,d1		
	move.w	#12,d7		
Copy	move.b	(a2),6(a3)		
	lea	160(a3),a3		
	lea	40(a2),a2		
	dbf	d7,Copy		
				
FinVbl	jsr	CursMove
	move.l	a1,PointMs
	move.w	d1,Sd1
	move.w	d2,Sd2
				
	move.w	Time,d0
	sub.w	#3206,d0
	divu	#12,d0
Rtd	dbf	d0,Rtd	

	movem.l	(sp)+,d0-a6
RTE	rte
 	
CursMove	lea	740(a0),a2		
	move.l	#0,a3		
	lea	Tab,a5	
	move.w	0(a5,d1.w),a3	
	add.l	a4,a3	
	add.w	d2,a3
	move.w	#12,d7
Copy2	move.b	(a2),(a3)
	lea	160(a3),a3
	lea	40(a2),a2
	dbf	d7,Copy2
	rts	

CursOff	move.l	#0,a3
	lea	Tab,a5
	move.w	0(a5,d1.w),a3
	add.l	a4,a3
	add.w	d2,a3	
	move.w	#12,d7	
Copy3	clr.b	(a3)	
	lea	160(a3),a3
	dbf	d7,Copy3
	rts	

**********************************************
** ICE UNPACKER 2.1
	include 	e:\final\pack_ice.2_1\ice_unp2.s

**********************************************
***          SOUS ROUTINES F D C           ***
**********************************************

Lance	st	Activity_Flag
; Positionnement du flag d'activit‚
	
	bclr	#7,$fffffa09.w
	move.l	#It_FDC,$11c.w
; Installation de l'interruption FDC
	bset	#7,$fffffa09.w
	bset	#7,$fffffa15.w
	
; Toggle ecriture/lecture
	move.w	#$90,$ffff8606.w
	move.w	#$190,$ffff8606.w		
	move.w	#$90,$ffff8606.w
; Sector Count Register		   
	move.w	#$a,$ffff8604.w		   
	
	move.l	Adr_DMA,d0
	bsr	Set_DMA
	
	st	Step_In_Flag
; Piste souhait‚e dans Data Register
	move.w	#$86,$ffff8606.w		
	move.w	Track,$ffff8604.w
; Command Register
	move.w	#$80,$ffff8606.w
	nop	
	nop	
; PremiŠre commande envoy‚e : Seek
	move.w	#$11,$ffff8604.w 
	
; A partir de l…, on quitte et les inter-
; ruptions vont enchainer les commandes
	rts

It_FDC	move.l	d0,-(sp)
	move.w	#$80,$ffff8606.w
; Status Register
	move.w	$ffff8604.w,d0
; RNF ou CRC Error ?
	and.w	#$18,d0
; => secteur pas lu
	beq.s	No_Error
	move.l	Adr_DMA,d0
	bsr	Set_DMA
	move.w	#$90,$ffff8606.w	
; Sector Count Register = 10
	move.w	#$a,$ffff8604.w
	bra.s	StepIn_Cmd
No_Error	
; Commande pr‚c‚dente = STEP IN ?
	tst.b	Step_In_Flag
	bne.s	StepIn_Cmd		
; Donc c'‚tait un READ : un secteur a ‚t‚ lu
	subq.w	#1,Sect_to_read
	beq	Stop_All
	addq.w	#1,Sect
	add.l	#$200,Adr_DMA
StepIn_Cmd
	sf	Step_In_Flag
; A-t-on lu les 10 secteurs ?
	cmp.w	#$b,Sect
	beq.s	Next_Track
Read
; Sector Register
	move.w	#$84,$ffff8606.w
; Nb secteurs lus +1 = No du prochain
; secteur … lire
	move.w	Sect,$ffff8604.w
; Command Register
	move.w	#$80,$ffff8606.w	
	nop
	nop
; -> Read sector ( no multiple )
	move.w	#$80,$ffff8604.w
	bra.s	Out
Next_Track	
; Nb de secteurs lus +1 remis … 1
	move.w	#1,Sect
	move.w	Sens,d0	
	add.w	d0,Track
; Sector Count Register
	move.w	#$90,$ffff8606.w
; -> remise … 10 sectors
	move.w	#$a,$ffff8604.w

	move.w	MaxTrack,d0
	cmp.w	Track,d0
	bne.s	normal
	add.w	#$20,StepCmd
	move.w	#-1,Sens
	moveq	#0,d0
	moveq	#1,d1
	bsr	Set_drive
	bra	Read
normal
; Command Register
	move.w	#$80,$ffff8606.w
	nop
	nop
; -> Step In/Out
	move.w	StepCmd,$ffff8604.w
; Positionnement du flag StepIN/OUT
	st	Step_In_Flag
Out	move.l	(sp)+,d0
	rte

Stop_All	bclr	#7,$fffffa09.w
	bclr	#7,$fffffa15.w
; C'est fini, flag d'activit‚ … FALSE
; Arret d‚finitif des It FDC
	sf	Activity_Flag
	move.l	(sp)+,d0
; couleur, voir plus haut
	rte

; Pour la suite, les fonctions annexes
; Toujours les memes routines...
Set_drive:	* Entree : d0=Drive(0/1)
	* 	d1=Face(0/1)
	addq.b	#1,d0
	add.b	d0,d0
	or.b	d1,d0
	eor.b	#7,d0
	move.b	#14,$ffff8800.w
	move.b	$ffff8800.w,d1
	and.b	#$f8,d1
	or.b	d0,d1
	move.b	d1,$ffff8802.w
	rts
Unselect_All:
	move.w	#$80,$ffff8606.w
.Motor	move.w	$ffff8604.w,d0
	and.w	#$80,d0
	bne.s	.Motor
; D‚selection Drive
	lea	$ffff8800.w,a0
	move.b	#14,(a0)
	move.b	(a0),d7
	ori.b	#$07,d7
	move.b	d7,2(a0)
	rts
Set_DMA:	* Entree : d0 = Adresse a valider 
;DMA Low
	move.b	d0,$ffff860d.w
	lsr.l	#8,d0
;DMA Middle
	move.b	d0,$ffff860b.w
	lsr.l	#8,d0
;DMA Hight
	move.b	d0,$ffff8609.w
	rts	
Force_IT:	move.w	#$80,$ffff8606.w
	nop
	nop
  	move.w  	#$d0,$fffff8604.w
	moveq	#40,d7
.wt	dbf	d7,.wt
	rts
Restore:	move.w	#$80,$ffff8606.w
	nop
	nop
  	move.w  	#$1,$fffff8604.w
	bsr	Wait_FDC
	rts
Wait_FDC:	move.l  	#$180,d5
.wt	dbf     	d5,.wt
  	move.l  	#$40000,d5
.mfp	btst    	#5,$fffffa01.w
  	beq     	.ok
  	subq.l  	#1,d5 
  	bne.s     	.mfp
  	bsr     	Error
.ok	rts 
Error:	bsr	Force_IT
  	rts 

Adr_DMA		dc.l	0
Step_In_Flag	dc.w	0
Activity_Flag	dc.w	0
StepCmd		dc.w	$53
Sens		dc.w	0
Cmd		dc.w	0	
CurrentDMA		dc.b	0
highdma		dc.b	0
middma		dc.b	0
lowdma		dc.b	0

**********************************************
***          DONNEES D'ANIMATION           ***
**********************************************
	
Stack	dc.l	0

screen	dc.l	@Upperram-$8000
Sd1	dc.w	0
Sd2	dc.w	3*15*160
Time	dc.w	0
AWait	dc.w	0
Mess	DC.B	'cw'
	DC.B	'   LL        OOOO      AA      DDDDD'
	DC.B	'dfc'
	DC.B	'   LL       OO  OO    AAAA     DD  DD'
	DC.B	'dfc'
	DC.B	'   LL       OO  OO   AA  AA    DD   DD'
	DC.B	'dfc'
	DC.B	'   LL       OO  OO   AA  AA    DD   DD'
	DC.B	'dfc'
	DC.B	'   LL       OO  OO   AAAAAA    DD   DD'
	DC.B	'dfc'
	DC.B	'   LL       OO  OO   AA  AA    DD  DD'
	DC.B	'dfc'
	DC.B	'   LLLLLL    OOOO    AA  AA    DDDDD'
	DC.B	'dfc'
	DC.B	'wwwwwwww'
	DC.B	'dduuuuuuuuuuuudddddddddddduuuuuuuuuuuudddddddddddduu'
	DC.B	'ucucucucucucuc',0

PointMs	dc.l	Mess 

Tab	dc.w	0,1,8,9,16,17,24,25,32,33,40,41,48,49
	dc.w	56,57,64,65,72,73,80,81,88,89,96,97
	dc.w	104,105,112,113,120,121,128,129,136,137
	dc.w	144,145,152,153

Zic	incbin	e:\music\ntmld_08.mus
Font	incbin	e:\litfont.pak

	section bss	
	ds.l	40
