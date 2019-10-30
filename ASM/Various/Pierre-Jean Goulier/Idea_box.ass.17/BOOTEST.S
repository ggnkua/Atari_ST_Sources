;
; Programme permettant de tester le boot secteur d'une disquette,
; et de l'activer / d‚sactiver en une op‚ration logique.
; Ce programme peut ˆtre assembler en PRG ou en ACC en mettant la
; variable type … 0 (ACC) ou … 1 (PRG). De plus, s'il est assembl‚
; en ACC, il pourra ˆtre renomm‚ ult‚rieurement avec le suffixe PRG
; et fonctionnera indiff‚remment dans les 2 modes (ACC ou PRG).
;
; Programmation : P-Jean Goulier.
; ½ Start Micro & P-Jean Goulier / 1994.
;

	section text
	
type	equ	1				; 1 pour .PRG, 0 pour .ACC

	ifeq	type				; Si type = 0, sortie … l'assemblage en ACC.
	output	.acc
	elseif
	output	.prg
	endc

	include	gemmacro.s			; Chargement des bibliothŠques.
	include	macrosys.s
	include	utiles.s

	ifeq	type				; Si ACC, on place une nouvelle pile
start:	move.l	#pile,a7			; et c'est tout...
	elseif
start:	init_prg #4096				; Si PRG, on initialise le programme.
	endc
	
	appl_init				; On initialise l'AES.
	move.w	d0,ap_id			; On sauve l'ap_id.
	beq.s 	prog				; Si ap_id = 0, c'est un programme !
	
	graf_handle				; Initialisation du handle.
	move.w	d0,hdle				; On le sauve.
	
	lea	intin,a0			; Il faut ouvrir une station virtuelle.
	moveq	#10-1,d0
.loop:	move.w	#1,(a0)+
	dbf	d0,.loop
	move.w	#2,(a0)+
	v_opnvwk
	
	ifeq	type				; Si c'est un ACC, 
	menu_register	ap_id,#acc_name		; on met son nom au menu.
	
evnt_gem:
	evnt_mesag	#buffer			; Gestion des ‚vŠnements.
	move.l	#buffer,a0
	move	(a0),d0
	cmp	#40,d0				; Accessoire choisi ?
	bne.s	evnt_gem			; Non, retour.
	jsr	program				; Oui, let's go !
	bra.s	evnt_gem			; et on y retourne...
	endc
	
prog:
	graf_mouse #0				; Une belle souris...
	jsr program				; On y va...
	v_clsvwk				; On ferme la workstation,
	appl_exit				; et on s'en va !
	pterm0

***************************************************************************
*
*                        Programme principal
*
***************************************************************************

program:
	form_alert #1,#welcome			; BoŒte d'accueil.
	move	int_out,d0
	cmp	#3,d0				; => Quitter.
	beq	exit
	subq	#1,d0
	move	d0,device			; Sinon, choix = lecteur.
	
	floprd	#buf_boot,device,#1,#0,#0,#1	; Lire le boot-secteur.
	tst	d0
	bmi	read_error			; => Erreur.
	clr	d0				; Faire la check-Sum.
	lea	buf_boot,a0
	move	#$ff,d1
sum:	add	(a0)+,d0
	dbra	d1,sum
	cmp	#$1234,d0			; et comparer … $1234.
	beq	execute				; BS ex‚cutable !
	lea	buf_boot,a0			; Sinon, regarder si il
	move	(a0),d0				; y a un 'BRA' au d‚but.
	cmp	#$6038,d0
	beq	exist				; Il y a un programme !
	form_alert #1,#ok			; Sinon, tout est normal.
	move	int_out,d0
	cmp	#1,d0				; => 'Suite' ou 'Quitter' ?
	bne	exit
	bra	program
	
execute:
	form_alert #1,#warning1			; Message d'avertissement.
	move	int_out,d0
	cmp	#1,d0				; => Activer le prg du boot,
	bne	program
activate:
	lea	buf_boot,a0			; en faisant un XOR 4 avec
	eor	#4,510(a0)			; la Check-Sum.
	flopwr	#buf_boot,device,#1,#0,#0,#1	; Ecrire le boot.
	tst	d0
	bmi	write_error
	bra	program
	
exist:
	form_alert #2,#warning2			; Message d'avertissement.
	move	int_out,d0			; Idem que pr‚c‚demment, car
	cmp	#1,d0				; c'est la mˆme op‚ration.
	bne	program
	bra	activate
exit:
	rts
	
read_error:
	form_alert #1,#re_message
	bra	program
	
write_error:
	form_alert #1,#we_message
	bra	program
	

	section data

device:	dc.w	0

acc_name:
	dc.b	"  Boot-Test  ",0
welcome:
	dc.b	"[3][BOOT-TEST|(c) PJ Goulier & Start Micro|Testez le  boot secteur de la|disquette sur le lecteur :][A|B|Quitter]",0
ok:
	dc.b	"[1][|Ce   boot  secteur  n'est  pas|ex‚cutable,  et il ne contient|pas de programme...][Suite|Quitter]",0
warning1:
	dc.b	"[1][|Attention...  Ce  boot secteur|est  ex‚cutable  ! Voulez-vous|le rendre inop‚rant ?][Oui|Non]",0
warning2:
	dc.b	"[1][Ce boot secteur n'est pas ex‚-|cutable,  mais il contient un|programme.  Voulez-vous tenter|de l'activer ?][Oui|Non]",0
re_message:
	dc.b	"[2][|ProblŠme … la lecture !|La  disquette est probablement|absente ou endommag‚e...][???]",0
we_message:
	dc.b	"[2][|ProblŠme … l'‚criture !|La  disquette est probablement|absente,  prot‚g‚e ou endomma-|g‚e...][???]",0
	

	section bss

ap_id:	ds.w	1
hdle:	ds.w	1
buffer:	ds.w	8
buf_boot:
	ds.w	256

	ifeq	type
	ds.l	1023				; Notre pile de 4 Ko.
pile:	ds.l	1				; (1024+1)*4=4096
	endc


	ifeq	__LK			
	include	aeslib.s		
	include vdilib.s
	endc
