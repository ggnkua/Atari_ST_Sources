;
; Exemple de SHELL appelant un programme TTP.
; Programmation : P-Jean Goulier.
; � Start Micro & P-Jean Goulier / 1994.
;
; Les sources ont �t� d�velopp�s sur ASSEMBLE � BRAINSTORM.
; 100% compatible avec l'assembleur traditionnel.
; Utilisation des biblioth�ques MACROSYS et UTILES � P-Jean Goulier.
; Utilisation de la biblioth�que AES � Brainstorm.


	TEXT
	
	bra	start			; Les biblioth�ques AES et VDI de ASSEMBLE
					; contiennent du code. Il faut donc les
					; sauter pour �viter un appel AES ill�gal !
	INCLUDE	AES.S
	INCLUDE	MACROSYS.S
	INCLUDE	UTILES.S
	
start:	init_prg #4096			; Initialisation du programme avec 4 Ko de pile.
	appl_init			; Initialisation de l'AES.
.main	bsr	fileselect		; S�lecteur jusqu'� ce que 
	tst	d0			; l'on clique sur [Annuler].
	beq	exit
	moveq	#0,d1			; D1 = Compteur de la cha�ne command_tail.
	lea	command+1,a0		; On laisse le 1er octet libre.
	lea	filename,a1
.loop	move.b	(a1)+,d0		; On copie le filename dans la cha�ne commande.
	move.b	d0,(a0)+
	tst.b	d0
	beq	.done
	inc.b	d1
	bra.s	.loop
.done	move.b	d1,command		; La longueur de la cha�ne est plac�e au d�but.
	mouseoff			; Plus de souris !
	pexec	#0,#coder,#command,#envt; On ex�cute CODEUR.TTP en envoyant la cha�ne.
	move.l	d0,-(sp)
	mouseon				; Bah oui...
	move.l	(sp)+,d0
	tst.l	d0			; D0 = Code de fin du TTP.
	bpl.s	.main			; D0>=0, tout s'est bien pass�.
	cmp	#-1,d0			; Si D0=-1, probl�me dans CODEUR.TTP...
	bne	.nf
	form_alert #1,#problem
	bra.s	exit
.nf	form_alert #1,#coder_not_found	; Sinon, CODEUR.TTP n'a pas �t� trouv�.
exit:	appl_exit			; Fin du progamme.
	pterm0
	
fileselect:
	move	#63,d0			; On efface le filename...
	lea	filename,a0
.clear	clr.b	(a0)+
	dbra	d0,.clear
	lea	path,a1 		; Path => A1.
	dgetdrv 			; Quel lecteur actif ?
	add.b	#65,d0
	move.b	d0,(a1)+			
	move.b	#":",(a1)+
	dgetpath #0,a1			; Quel chemin actif ?
	lea	path,a1 		; O� est la fin de la cha�ne (0) ?
.l1	move.b	(a1)+,d0
	bne.s	.l1
	sub.l	#1,a1			; 1 octet en arri�re.
	move.b	#"\",(a1)+
	lea	mask,a2
.l2	move.b	(a2)+,(a1)+		; Le masque est ajout�.
	bne.s	.l2
	fsel_input #path,#name		; S�lecteur de fichiers
	move	int_out+2,d0
	bne	.ok
	rts				; On a choisi [Annuler].
.ok	lea	path,a1 		; On copie le path dans filename.
	lea	filename,a2
.l5	move.b	(a1)+,(a2)+
	bne.s	.l5
	lea	filename,a1		; On ne garde que le path.
	lea	64(a1),a1
.l3	move.b	-(a1),d0		; On cherche le dernier "\".
	cmp.b	#"\",d0
	bne.s	.l3
	add.l	#1,a1
	lea	name,a2
.l4	move.b	(a2)+,(a1)+		; On ajoute le nom.
	bne.s	.l4
	rts


	DATA

coder:	DC.B	"CODEUR.TTP",0
mask:	DC.B	"*.*",0
name:	DC.B	"FILENAME.EXT",0
envt:	DC.B	0
coder_not_found:
	DC.B	"[2][|Le programme CODEUR.TTP|est introuvable...][Annuler]",0
problem:
	DC.B	"[2][|Un probl�me est survenu dans|le programme CODEUR.TTP...|Je ne peux continuer.][Annuler]",0

		
	BSS

path:	DS.W	32
filename:
	DS.W	32
command:
	DS.W	128
	