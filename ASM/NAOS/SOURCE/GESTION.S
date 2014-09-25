**      Demo ST Mag/ NAOS
**  Gestionnaire de la demo
**  controle du deroulement
**  … assembler sous GESTION.BIN

**   Code par Ric / Naos
**         pour ST Mag 1993

; 1 pour lancer sous DEVPAC
; 0 pour ecrire sur disque
TEST	EQU	0	

RUNINTRO	SET	0
INITRESET	SET	0

	IFEQ 	TEST
RUNINTRO	SET	1
INITRESET	SET	1
	ENDC

	include	e:\final\source\equiv.s

	opt x+

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~~~~          Gestionnaire           ~~~~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Load	MACRO	
; \1 adresse destination
; \2 End mode [0/1]
; \3 Clear Ram [0/1]
; init des variables
	move.l	PntTable(pc),a6
	move.w	(a6)+,Track
	move.w	(a6)+,Sect
	move.w	(a6)+,Sect_to_read
	move.w	(a6)+,Side
	lea	PntTable(pc),a0
	move.l	a6,(a0)
	move.l	#\1,Dest_adr
; appel loader
	move.l	#@Load,d0
	lea	.return(pc),a0
	move.l	a0,d1
	lea	FDCvar(pc),a0
	move.l	(a0),d2
	move.l	#-1,(a0)
	move.b	#\2,EndMode
	move.b	#\3,ClearRam
	bra	run_it
.return
	ENDM
Run	MACRO
; \1 adresse de retour
	move.l	#@Screen,d0
	lea	\1(pc),a0
	move.l	a0,d1
	moveq	#0,d2
	bra	run_it
.return
	ENDM
	
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	IFNE	TEST
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.w	#Nb_of_trk,MaxTrack

	move.w	#4,GestSect	
	move.l	#Suite,JMP+2
	bra.s	Lect
	include	e:\final\source\boot.s
	ENDC

Suite	lea	$fffffa06.w,a0
	clr.l	(a0)
	lea	RTE(pc),a0
	move.l	a0,$70.w
	move.w	#$2300,sr
	
	lea	Illegal(pc),a0
	move.l	a0,$10.w
	
; Charge et init le reset
Lreset	Load	@Reset,0,1
	IFNE	INITRESET
	jsr	@Reset
	ENDC
	
; Charge et lance l'intro
Lintro	Load	@Screen,1,0
	IFNE	RUNINTRO
Rintro	Run	.return
	ENDC

; Charge et lance le menu
	bsr	prepare_variables
; Test 1 mega de ram
	move.l	#$12345678,@upperram
	move.l	@Upperram,d0
	cmp.l	#$12345678,d0
	bne	pas_1_meg
_1_meg	
; pointe sur les donnees d'acces au menu
	lea	MenuTrk(pc),a0
	lea	PntTable(pc),a1
	move.l	a0,(a1)
	Load	@Upperram,1,1
	lea	Backmenu+2(pc),a0
	lea	To_menu(pc),a1
	move.l	a1,(a0)
To_menu
; transfert menu en ram basse
	lea	@Upperram,a0
	lea	@Screen,a1
	move.l	MenuSize(pc),d0
	lsr.l	#2,d0
	addq.l	#1,d0
.trsf	move.l	(a0)+,(a1)+
	subq.l	#1,d0
	bne	.trsf
; lance menu
	Run	call_screens
	
pas_1_meg	lea	Backmenu+2(pc),a0
	lea	To_menu2(pc),a1
	move.l	a1,(a0)
To_menu2	
; pointe sur les donnees d'acces au menu
	lea	MenuTrk(pc),a0
	lea	PntTable(pc),a1
	move.l	a0,(a1)
	Load	@Screen,1,1
Rmenu	Run	call_screens

prepare_variables
; recopie les donnees d'acces au main menu 
	move.l	PntTable(pc),a6
	lea	MenuTrk(pc),a0
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	lea	MenuSize(pc),a0
	move.l	(a6)+,(a0)
	lea	OldPntTable(pc),a0
	move.l	a6,(a0)
	rts

Backmenu	jmp	$0
To_menu3	lea	Backmenu+2(pc),a0
	lea	To_menu(pc),a1
	move.l	a1,(a0)
	lea	_1_meg(pc),a1
	jmp	(a1)

call_screens
; la table contient des lors une structure stable :
; a - track (.W)
; b - sect (.W)
; c - sect to read (.W)
; d - face du disque (.W)
;  Total 8 octets

	move.w	Choice,d0
; cas sp‚cial screen prends 1 meg
	cmp.w	#1,d0
	bne.s	no_special
	lea	Backmenu+2(pc),a0
	lea	To_menu2(pc),a1
	cmp.l	(a0),a1
	bne.s	go_for_special
; impossible de lancer cet ecran, retour au menu 
	jmp	(a1)
go_for_special
	lea	Backmenu+2(pc),a0
	lea	To_menu3(pc),a1
	move.l	a1,(a0)
no_special	
	mulu	#8,d0
	move.l	OldPntTable(pc),a0
	lea	0(a0,d0.w),a0
; ecrit le nouveau pointeur temporaire
	lea	PntTable(pc),a1
	move.l	a0,(a1)
	Load	@Screen,1,1
Rback	Run	Backmenu

Illegal	clr.w	-(sp)
	trap	#1
	
run_it		include	e:\final\source\run_it.s

	section data
	
OldPntTable	dc.l	0
PntTable		dc.l	@Table
MenuSize		dc.l	0
MenuTrk		dc.w	0
MenuSct		dc.w	0
MenuSct_to_read	dc.w	0
MenuSide		dc.w	0
FDCvar		dc.l	0

FinPrg		dc.l	0