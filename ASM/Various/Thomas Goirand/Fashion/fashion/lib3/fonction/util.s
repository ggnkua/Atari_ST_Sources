	text
	include	gemdos.i
	include	aes.i
	include	structs.s
	include	zlib.i
	XREF	tab_adr,tab_handle
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
**********************************************************
* fonction fixant un repertoire et un lecteur par defaut *
* a partir d'un chemin de fichier                        *
**********************************************************
* on entrait avec a6...
	XDEF	dxsetpath_routine
dxsetpath_routine
	movem.l	d0-d2/a0-a4,-(sp)
	move.l	36(sp),a4

	clr.w	d0
	move.b	(a4),d0
	sub.b	#"A",d0
	Dsetdrv	d0
	move.l	#dxsetpath_buff,a3	; on recopie la chaine de commande
.loop1					; dans un buffer tampon ou sera stoke uniquement
	move.b	(a4)+,(a3)+		; le repertoire dans lequel se trouve le fichier
	bne	.loop1
.loop2	cmp.b	#"/",-(a3)
	beq	.ok
	cmp.b	#"\",(a3)
	bne	.loop2
.ok
	addq.l	#1,a3
	move.b	#0,(a3)+
	move.b	#0,(a3)+

	Dsetpath	#dxsetpath_buff
	movem.l	(sp)+,d0-d2/a0-a4
	rts
	bss
dxsetpath_buff		ds.b	1024
	text
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*********************
*** file_selector ***
*********************
* en entree chaine chemin defini le path ET l'extention du fichier a charger.
* en retour, la chaine_chemin sera rempli par le nom complet d'un fichier + son chemin
* si on a appuye sur cancel dans le file selector, d0 ne contient pas 0. (erreur de retour)
* si on a choisi un fichier mais qu'on le trouve pas sur le disk, alors message d'erreur,
* et renvois du code correspondant dans d0.
	XDEF	file_select_routine
file_select_routine
	movem.l	d1-a6,-(sp)
	move.l	60+4(sp),a6	; le chemin
	move.l	60+0(sp),a5	; la chaine de commentaire

* Trouve la fin du chemin complet
	move.l	#file_path,a4
	move.l	a6,a3
.trouve_fin
	move.b	(a3)+,(a4)+
	bne	.trouve_fin

* Trouve l'extention
find_extend
	cmp.b	#".",-(a4)
	bne	find_extend

* Et copie cette extention dans le buffer
	move.l	#file_extend,a0
	move.b	#"*",(a0)+
cp_extend
	move.b	(a4)+,(a0)+
	bne	cp_extend

* Trouve le nom du fichier par defaut
	subq.l	#1,a4
find_fname
	cmp.b	#"/",(a4)
	beq	fname_ok
	cmp.b	#"\",(a4)
	beq	fname_ok
	subq.l	#1,a4
	bra	find_fname
fname_ok

* Et le copie dans la chaine prevue
	move.l	#file_name,a0
	addq.l	#1,a4
	move.l	a4,a2
cp_filename
	move.b	(a4)+,(a0)+
	bne	cp_filename

* Copie l'extention du fichier a la fin du chemin
	move.l	#file_extend,a1
cp_extendpath
	move.b	(a1)+,(a2)+
	bne	cp_extendpath

	fsel_exinput	#file_path,#file_name,a5

	tst.w	d0
	beq	fsel_cancel
	move.w	int_out+2,d0
	tst.w	d0
	beq	fsel_cancel

* Trouve la fin de path
	move.l	#file_path,a1
find_endpath
	tst.b	(a1)+
	bne	find_endpath
	subq.l	#1,a1

find_before
	cmp.b	#"/",(a1)
	beq	ok_trouved
	cmp.b	#"\",(a1)
	beq	ok_trouved
	subq.l	#1,a1
	bra	find_before
ok_trouved
	addq.l	#1,a1

* Copy le nom de fichier trouve en fin de chaine "path"
	move.l	#file_name,a5
concatene_rsc
	move.b	(a5)+,(a1)+
	bne	concatene_rsc

;	Fsfirst	#%111,#file_path
;	tst.w	d0
;	blt	fsel_cancel

	move.l	#file_path,a1
cp_chemin_complet
	move.b	(a1)+,(a6)+
	bne	cp_chemin_complet

	move.w	#0,d0
	movem.l	(sp)+,d1-a6
	rts

fsel_cancel
	moveq.l	#-1,d0				; on renvois -1 si il y a eu erreur
	movem.l	(sp)+,d1-a6
	rts

	bss
file_name	ds.b	256
file_path	ds.b	1024
file_extend	ds.b	64
	text
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
**************************************************************
*** sauve un fichier a partir de 2 adresses et d'un chemin ***
**************************************************************
	XDEF	sauve_file_routine
sauve_file_routine
	movem.l	d5-d7/a4-a6,-(sp)
	move.l	28+0,a6	; path
	move.l	28+4,a5	; end_adr
	move.l	28+8,a4	; start_adr

	Fcreate	#0,a6
	move.w	d0,d5

	move.l	a4,d6
	move.l	a5,d7
	sub.l	d6,d7	; calcul de la longueur du fichier

	Fwrite	a4,d7,d5

	Fclose	d5

	movem.l	(sp)+,d1-a6
	rts
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
***************************************************************
*** charge un fichier a partir de 2 adresses et d'un chemin ***
***************************************************************
	XDEF	charge_file_routine
charge_file_routine
	movem.l	d1-a6,-(sp)
	move.l	60+0(sp),a6	; path
	move.l	60+4(sp),a5	; end_adr
	move.l	60+8(sp),a4	; start_adr

	Fsfirst	#0,a6
	tst.w	d0
	bne		erreur

	Fopen	#%10,a6
	move.w	d0,d5

	move.l	a4,d6
	move.l	a5,d7
	sub.l	d6,d7	; calcul de la taille a charger

	Fread	a4,d7,d5

	Fclose	d5

	move.w	#0,d0
	movem.l	(sp)+,d1-a6
	rts
erreur
	move.w	#-1,d0
	movem.l	(sp)+,d1-a6
	rts
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
**********************************************************************
*** transforme une chaine de chiffre decimaux en un long word hexa ***
*** resultat dans d0                                               ***
**********************************************************************
	XDEF	chaine_2_long_routine
chaine_2_long_routine
	movem.l	d1/d3/d4/d7/a5/a6,-(sp)
	move.l	28(sp),a6
	move.l	a6,d7
	clr.l	d0
* on compte le nombre de chiffre(s) de la chaine
.loop1
	cmp.b	#"_",(a6)
	beq	.sort
	tst.b	(a6)+
	beq	.sort
	addq.w	#1,d0	; le resultat dans d0
	bra	.loop1	; represente aussi le rang du chiffre a additionner

.sort
	tst.w	d0
	beq		end_chaine_2_long
	move.l	d7,a6		; a6 est la chaine de chiffre
	clr.l	d3			; le resultat de la boucle est dans d3
.loop2
	lea		table_puis_10,a5
	clr.l	d4
	move.b	(a6)+,d4
	sub.w	#"0",d4		; d4 = le chifre pointe dans la chaine
	lsl.l	#2,d4		; *4 (car il sagit d'un long_word
	add.l	d4,a5		; et on l'ajoute comme offset dans le tableau

*on calcule : le_2e_offset = largeur_tabeau * rang_de_chiffre-1
	clr.l	d1
	move.w	d0,d1	; d1 = d0..
	lsl.l	#3,d1	; *8...
	add.w	d0,d1	; + d0..
	add.w	d0,d1	; + d0..		; resultat dans d1
	add.l	d1,d1	; d1 = d1*4
	add.l	d1,d1
	sub.w	#10*4,d1			; moins une ligne de tableau
*on ajoute le 2e offset au pointeur de tableau
	add.l	d1,a5
	add.l	(a5),d3
*puis on reactualise le compteur qui est aussi le rang de chiffre
	subq.w	#1,d0
	bne	.loop2

	move.l	d3,d0
end_chaine_2_long
	movem.l	(sp)+,d1/d3/d4/d7/a5/a6
	rts
	data
table_puis_10		; tableau a 2 dimention : de $0 a $7fff ffff
	dc.l	0,1,2,3,4,5,6,7,8,9
	dc.l	0,10,20,30,40,50,60,70,80,90
	dc.l	0,100,200,300,400,500,600,700,800,900
	dc.l	0,1000,2000,3000,4000,5000,6000,7000,8000,9000
	dc.l	0,10000,20000,30000,40000,50000,60000,70000,80000,90000
	dc.l	0,100000,200000,300000,400000,500000,600000,700000,800000,900000
	dc.l	0,1000000,2000000,3000000,4000000,5000000,6000000,7000000,8000000,9000000
	dc.l	0,10000000,20000000,30000000,40000000,50000000,60000000,70000000,80000000,90000000
	dc.l	0,100000000,200000000,300000000,400000000,500000000,600000000,700000000,800000000,900000000
	dc.l	0,1000000000,2000000000
table_puis_10_last_val
	dc.l	3000000000
table_puis_10_end
	text


*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
**********************************************************************
* Fourni une extention a partir d'un chemin complet ou un fichier seul
* en retour, d0 contien l'extention, ou un -1 si elle n'est pas trouve
* Si le pointeur d'entree pointe sur une chaine vide (des 0), alors on transmet -1 dans d0 en sortie
	XDEF	get_extention_routine
get_extention_routine
	tst.b	(a1)
	beq		no_extention

	clr.w	d6
get_extention_loop
	addq.w	#1,d6				; d6 compte le nombre de caractere du path
	tst.b	(a1)+
	bne.s	get_extention_loop	; a1 pointe la fin du path

.loop2
	subq.w	#1,d6		; si d6 = 0, alors pas d'extention trouve
	beq		no_extention
	cmp.b	#".",-(a1)	; a1 pointe l'extention
	bne		.loop2

	move.b	(a1)+,d0
	lsl.l	#8,d0
	move.b	(a1)+,d0
	lsl.l	#8,d0
	move.b	(a1)+,d0
	lsl.l	#8,d0
	move.b	(a1)+,d0

	rts
	move.w	#-1,d0
no_extention
