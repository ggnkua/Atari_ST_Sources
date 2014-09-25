**    Demo ST Mag / NAOS   **
** Programme DEMO BUILDER  **
**                         **
** Code par Ric / Naos     **
**       pour ST Mag 1993  **

; 1 pour ecrire le BOOT
BOOT	equ	1	
; 1 pour ecrire le reste
RESTE	equ	1

	include	e:\final\source\equiv.s
	
	opt x+

Write	MACRO
	move.w	\1,-(sp)	; combien
	move.w	\2,-(sp)	; face
	move.w	\3,-(sp)	; piste
	move.w	\4,-(sp)	; sect. depart
	move.w	#0,-(sp)	; disk A
	clr.l	-(sp)
	move.l	\5,-(sp)
	move.w	#9,-(sp)
	trap	#14
	lea	20(sp),sp
	ENDM

Affiche	MACRO
	pea	\1
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	ENDM

**********************************************
		
	bsr	GetDTA
	
	IFNE	BOOT
; 1 - Ecriture du boot secteur

; routine deja etudiee dans ST Mag, cree le
; boot secteur en memoire
	include	e:\final\source\mk_boot.s
	
; c'est fini, ‚criture du boot ‚x‚cutable
	Write 	#1,#0,#0,#1,#filebuf
	Affiche	text_boot
	ENDC
	
	IFNE	RESTE
	
;~~~~~~~~~~ PROCEDE AUTOMATIQUE ~~~~~~~~~~~
; init des variables d'exploitation du disque
Auto	moveq	#0,d6	; piste 0
	moveq	#2,d7	; dernier sect
	lea	Tablebuf,a5

; 2 - Ecriture du gestionnaire
	lea	gestion,a6
	bsr	process_it
	Affiche	text_gest
	lea	Tablebuf,a5
; nb sect occupes par le gestionnaire
	move.w	4(a5),(a5)

; 3 - Ecriture du loader

; pour ne pas ecraser les donn‚es
; du gestionnaire, on s'en ressert
	lea	Tablebuf+6,a5
	lea	loader,a6
	bsr	process_it

; reprise pour le cas loader 
	lea	Suite,a3
	lea	Tablebuf+2,a5
; nb sect du gest
	move.w	2(a5),(a5) 
; sect de depart du loader
	add.w	#2+1,(a5)+	
.loop	move.w	(a3)+,d0
	beq.s	.repris
	move.w	d0,(a5)+
	bra.s	.loop
.repris	move.w	#-1,(a5)+
	move.l	Length,(a5)+
	Affiche	text_load

; 4 - Ecriture eds autres ecrans

	lea	reset,a6
	bsr	process_it
	Affiche	text_reset

 	lea	intro,a6
	bsr	process_it
	Affiche	text_intro

	lea	main,a6
	bsr	process_it
	lea	unpacked_main,a6
	bsr	GetLength
; extra pour le main
	move.l	Length,(a5)+	
	Affiche	text_main

	lea	screen1,a6
	bsr	process_it
	Affiche	text_screen

	lea	screen2,a6
	bsr	process_it
	Affiche	text_screen

	Write	#1,#0,#0,#2,#Tablebuf
	Affiche	text_table
	
	ENDC
	
exit	Affiche	text_fin

	move.w	#7,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.w	-(sp)
	trap	#1

******************************************************

;~~~~~~~~  Routine d'ecriture des fichiers    ~~~~~~~~
;~~~~~~~~  et generation de la table d'acces  ~~~~~~~~

process_it
	lea	Suite,a3	; nb sect ecrits a chaque piste
; pointeur sur table = a5
	move.w	d6,(a5)+	; pist dep
	move.w	d7,d4
	addq.w	#1,d4
	move.w	d4,(a5)+	; sect dep
	move.w	d7,d5
	sub.w	#10,d5
	neg.w	d5
; nb de sect restants sur la piste = d5

; a6 precharge
	bsr	ReadFile
	
	tst.w	Sens
	bne	FACE2
	
	lea	filebuf,a6
	move.l	Length,d7	; taille
	divu	#512,d7
	addq.w	#1,d7	; nb sect pour ce fichier
	move.w	d7,(a5)+
	move.w	#0,(a5)+	; face de depart
	cmp.w	d5,d7	; a-t-on assez sur cette piste
	ble	moins_init

complete	sub.w	d5,d7
	move.w	d5,(a3)+
	Write 	d5,#0,d6,d4,a6	; on ecrit [d5] sect
	addq.w	#1,d6
	move.w	d5,d0
	mulu	#512,d0
	add.l	d0,a6	; increm le buffer
	cmp.w	#Nb_of_trk,d6
	beq	AUTRE_SENS
	
encore	cmp.w	#10,d7	; reste-t-il 10 sect
	ble	moins_fin
	move.w	#10,(a3)+
	Write 	#10,#0,d6,#1,a6	; on en ecrit 10
	sub.w	#10,d7	
	lea	10*512(a6),a6
	addq.w	#1,d6
	cmp.w	#Nb_of_trk,d6
	beq	AUTRE_SENS
	bra.s	encore
moins_fin
	move.w	d7,(a3)+
	Write 	d7,#0,d6,#1,a6
	bra	fin_process
moins_init	
	move.w	d7,(a3)+
	Write 	d7,#0,d6,d4,a6
	add.w	d4,d7
	subq.w	#1,d7
fin_process
	rts

AUTRE_SENS	move.w	#1,Sens
	subq.w	#1,d6
	Affiche	text_face
	bra	encore2
	
FACE2	lea	filebuf,a6
	move.l	Length,d7	; taille
	divu	#512,d7
	addq.w	#1,d7	; nb sect pour ce fichier
	move.w	d7,(a5)+
	move.w	#1,(a5)+	; face de depart
	cmp.w	d5,d7	; a-t-on assez sur cette piste
	ble	moins_init2

complete2	sub.w	d5,d7
	move.w	d5,(a3)+
	Write 	d5,#1,d6,d4,a6	; on ecrit [d5] sect
	subq.w	#1,d6
	move.w	d5,d0
	mulu	#512,d0
	add.l	d0,a6	; increm le buffer
	tst.w	d6
	bmi	error_pist
	
encore2	cmp.w	#10,d7	; reste-t-il 10 sect
	ble	moins_fin2
	move.w	#10,(a3)+
	Write 	#10,#1,d6,#1,a6	; on en ecrit 10
	sub.w	#10,d7	
	lea	10*512(a6),a6
	subq.w	#1,d6
	tst.w	d6
	bmi	error_pist
	bra.s	encore2
moins_fin2
	move.w	d7,(a3)+
	Write 	d7,#1,d6,#1,a6
	bra	fin_process2
moins_init2	
	move.w	d7,(a3)+
	Write 	d7,#1,d6,d4,a6
fin_process2
	rts


******************************************************

;~~~~~~~~  Routines de lecture des fichiers   ~~~~~~~~
	
GetDTA	move.w	#$2f,-(sp)
	trap	#1
	addq.l	#2,sp
	add.l	#26,d0
	move.l	d0,LengthPlace
	rts
	
GetLength	clr.w	-(sp)
	pea	(a6)
	move.w	#$4e,-(sp)		; Fsfirst
	trap	#1
	addq.l	#8,sp
	tst.w	d0
	bne	error_open
	move.l	LengthPlace,a1
	move.l	(a1),Length
	rts

ReadFile	bsr	GetLength
	move.w	#0,-(sp)
	pea	(a6)
	move.w	#$3d,-(sp)		; FOpen
	trap	#1
	addq.l	#8,sp
	move.l	d0,d1		; handle
	tst.l	d0
	bmi	error_file
	pea	filebuf
	move.l	Length,-(sp)
	move.w	d1,-(sp)		; handle
	move.w	#$3f,-(sp)		; FRead
	trap	#1
	add.l	#12,sp
	tst.l	d0
	bmi	error_file
	move.w	d1,-(sp)		; handle
	move.w	#$3e,-(sp)		; FClose
	trap	#1
	addq.l	#4,sp
	tst.l	d0
	bmi	error_file
	rts

error_open	Affiche	texterror_open
	rts
error_file	Affiche	texterror_file
	rts
error_boot	Affiche	texterror_boot
	rts
error_pist	Affiche	texterror_pist
	move.l	#exit,-(sp)
	rts
error_gest	Affiche	texterror_gest
	move.l	#exit,-(sp)
	rts

Prg	include	e:\final\source\boot.s
FinPrg

LengthPlace	dc.l	0
Length		dc.l	0
Sens		dc.w	0
	
texterror_open	dc.b	' Erreur : fichier non trouv‚',10,13,0
texterror_file	dc.b	' Erreur de lecture fichier',10,13,0
texterror_boot	dc.b	' Erreur : boot secteur trop gros',10,13,0
texterror_pist	dc.b	' Erreur : disquette pleine',10,13,0
texterror_gest	dc.b	' Erreur : gestionnaire trop gros',10,13,0

text_boot		dc.b	'Boot secteur ‚crit',10,13,0
text_gest		dc.b	'Gestionnaire ‚crit',10,13,0
text_load		dc.b	'Loader ‚crit',10,13,0
text_reset		dc.b	'Reset demo ‚crite',10,13,0
text_intro		dc.b	'Intro ‚crite',10,13,0
text_main		dc.b	'Main menu ‚crit',10,13,0
text_screen	dc.b	'Ecran de demo ‚crit',10,13,0
text_table		dc.b	'Table d"accŠs fichiers ‚crite',10,13,0
text_face		dc.b	'  Changement de face',10,13,0	
text_fin		dc.b	10,13,'Pressez une touche',0	
		even

gestion		dc.b	'e:\final\unpacked\gestion.bin',0
loader		dc.b	'e:\final\unpacked\loader.bin',0
reset		dc.b	'e:\final\packed\reset.ice',0
intro		dc.b	'e:\final\packed\intro.ice',0
main		dc.b	'e:\final\packed\main.ice',0
unpacked_main	dc.b	'e:\final\unpacked\main.tos',0
screen1		dc.b	'e:\final\packed\screen.ice',0
screen2		dc.b	'e:\final\packed\screen.ice',0
		even
		
	section bss
Suite		ds.w	80
Tablebuf		ds.b	512
filebuf		ds.l	25000
