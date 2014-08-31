;Exemple de source de module DMA
;par STGHOST/SECTOR ONE

;utilisation:
; - programmer le module
; - mettre les bons parametres (nom fichier,signe,...)
; - assembler en memoire et executer

;-tab_size: 9-

;*** il n'y a pas grand chose dans la section TEXT
; ...seulement quelques configs a faire:
;	-Changement du signe des samples
;	-Sauvegarde ou non du fichier
;	-Nom du fichier *.DMA
;*** dans la section DATA se trouve toute la description du module

	section	text
Signe	equ	0	;0=garder signe
			;1=changer signe
Sauve	equ	1	;0=le module ne sera pas sauvegarde
			;1=le module sera sauve

	opt	o+,ow+	;pour Devpac

	lea	dmatune(pc),a0
	move.l	#samp1,a1
	move.l	#finsamp,a2
	bsr.s	deltaspl
	ifne	Sauve
	bsr.s	saveit
	endc
	clr.w	-(sp)
	trap	#1

save_as	dc.b	'D:\EXEMPL.DMA',1	;mettre ici le nom du
				;fichier DMA a sauver
	even

deltaspl	moveq	#0,d0	;routine de pseudo-cryptage des samples
	moveq	#0,d1
	moveq	#0,d2
	move.b	(a1),d0
	ifne	Signe
	eor.b	#$80,d0
	endc
	move.b	d0,(a1)+
convert	move.b	(a1),d1
	ifne	Signe
	eor.b	#$80,d1
	endc
	move.b	d1,(a1)
	sub.b	d0,(a1)+
	move.b	d1,d0
	cmp.l	a2,a1
	bne.s	convert
	rts
saveit	move.l	a0,d6
	move.l	a1,d7
	sub.l	d6,d7
	lea	save_as(pc),a6
	move.w	#2,-(sp)
	pea	(a6)
	move.w	#61,-(sp)
	trap	#1
	addq.l	#8,sp
	tst.w	d0
	bpl.s	overwrite
	clr.w	-(sp)
	pea	(a6)
	move.w	#60,-(sp)
	trap	#1
	addq.l	#8,sp
	tst.w	d0
	bmi.s	error
overwrite
	move.w	d0,d5
	move.l	d6,-(sp)
	move.l	d7,-(sp)
	move.w	d5,-(sp)
	move.w	#64,-(sp)
	trap	#1
	lea	12(sp),sp
	move.l	d0,d4
	move.w	d5,-(sp)
	move.w	#62,-(sp)
	trap	#1
	addq.l	#4,sp
	tst.l	d4
	bmi.s	error
	rts
error	pea	file_err(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	rts

file_err	dc.b	13,10,'Error while saving...',13,10
	dc.b	'Press any key',13,10,10,0
	even

	section	data

;c'est ici que se trouve le module

dmatune

; * * * Entete * * *
	dc.l	'DMA!'		;module DMA 1ere generation

	dc.b	'Exemple de DMA'	;nom du module sur 20 octets
	ds.b	6		; 14 + 6 = 20 (dingue!)

	dc.b	130		;Mode: bits 7 6 5 4 3 2 1 0
				;0:stereo---+ |         | |
				;1:mono-----/ |         | |
				;0:8bits------+         | |
				;1:16bits-----/         | |
				;11:50KHZ---------------+-+
				;10:25KHZ---------------+-+
				;01:12.5KHZ-------------+-+
				;00:6.25KHZ(STE)--------+-/

	dc.b	1		;nombre d'instruments
				;et non pas nombre de samples

; * * * description des instruments * * *
	dc.b	'Refrain'	;nom sur 8 octets
	ds.b	1		; 7 + 1 = 8 (waow...)
	dc.l	samp1-dmatune	;adresse de debut de l'instrument
				; par rapport au debut du module
	dc.l	finsamp-samp1	;taille de l'intrument (en octets)

	;repeter cette structure pour chaque instrument
	;le 1er intrument porte le numero 0
	;le 2eme le numero 1 etc... (maxi 255 instruments)

; * * * partition * * *
	dc.b	1		;nombre de positions (max: 255)
	dc.b	0		;position de bouclage

	dc.b	0		;liste des positions:
			;chaque entree est 1 numero d'instrument
	even	;->accepte les nombres impairs de positions

; * * * samples * * *
samp1	incbin	'D:\DIGIT.SPL'	;charge 1 sample
		;il est possible d'en charger plusieurs
		; >> les samples doivent etre bruts, pas d'en-tete !!!
	even	;on ajuste la parite pour terminer
finsamp		;c'est fini... il n'y a plus qu'a sauver et tester

