dxsetpath	macro	; chemin
	XREF	dxsetpath_routine
	move.l	\1,-(sp)
	jsr	dxsetpath_routine
	addq.l	#4,sp
	endm

*********************
*** file_selector ***
*********************
* en entree chaine chemin defini le path ET l'extention du fichier a charger.
* en retour, la chaine_chemin sera rempli par le nom complet d'un fichier + son chemin
* si on a appuye sur cancel dans le file selector, d0 ne contient pas 0. (erreur de retour)
file_select	macro	; chaine_chemin,chaine_commentaire
	XREF	file_select_routine
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	jsr	file_select_routine
	addq.l	#8,sp
	endm

**************************************************************
*** sauve un fichier a partir de 2 adresses et d'un chemin ***
**************************************************************
sauve_file	macro	; adr_start,adr_end,path
	XDEF	sauve_file_routine
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	move.l	\3,-(sp)
	jsr	sauve_file_routine
	lea	12(sp),sp
	endm

***************************************************************
*** charge un fichier a partir de 2 adresses et d'un chemin ***
***************************************************************
charge_file	macro	; adr_start,adr_end,path
	XREF	charge_file_routine
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	move.l	\3,-(sp)
	jsr	charge_file_routine
	lea	12(sp),sp
	endm

*******************************************************************
*** execute un programme apres avoir effacer toute les fenetres ***
*** et enleve la bar de menu, ceci si on n'est pas sous MiNT.   ***
*** En effet, sous MiNT, on execute le prg demande en mode non  ***
*** exclusif (on profite du multitache).                        ***
*** Au retour, la fonction remet les fenetres en place.         ***
*******************************************************************
* parametre : cmd_line = ligne de commande envoyer au PRG
*             path     = chemin de l'executable
*             dset     = 0     -> pas de DSETPATH (repertoire courant)
*                        1     -> DSETPATH sur l'executable
pxexec	macro	; cmd_line,path,dset
	XREF	pxexec_routine
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	move.l	\3,-(sp)
	jsr	pxexec_routine
	endm

**********************************************************************
*** transforme une chaine de chiffre decimaux en un long word hexa ***
*** resultat dans d0                                               ***
**********************************************************************
chaine_2_long	macro	; chaine
	XREF	chaine_2_long_routine
	move.l	\1,-(sp)
	jsr	chaine_2_long_routine
	addq.l	#4,sp
	endm

********************************************************
*** Conversion d'un entier en chaine ascii (decimal) ***
********************************************************
long_2_chaine	macro	; valeur,pointeur_chaine,nombre_de_chiffres
	XREF	long_2_chaine_rout
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	move.w	\3,-(sp)
	jsr	long_2_chaine_rout
	lea	10(sp),sp
	endm

**********************************************************************
* Fourni une extention a partir d'un chemin complet ou un fichier seul
* en retour, d0 contien l'extention, ou un -1 si elle n'est pas trouve
* Si le pointeur d'entree pointe sur une chaine vide (des 0), alors on transmet -1 dans d0 en sortie
get_extention	macro	; path
	XREF	get_extention_routine
	movem.l	d6/a6,-(sp)
	move.l	\1,a1
	jsr	get_extention_rout
	movem.l	(sp)+,d6-d7/a1
	endm


