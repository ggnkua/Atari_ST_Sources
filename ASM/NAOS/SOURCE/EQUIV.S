
** STRUCTURE DISQUE
* pist 0, sect 1 	= boot
*         sect 2 	= table d'acces disque
* Gestionnaire
* Loader 
* Reset, Intro, Main, Ecrans...


** FORMAT DE LA TABLE D'ACCES DISQUE
* Organisation des ecrans :
*	1 - gestionnaire
*	2 - loader
*	3 - reset
*	4 - intro
*	5 - main menu
*	6... - les differents ecrans
* Pour loader
*	a - piste 0, nb sect (.W)
*	b - piste 1, nb sect (.W)
*	c - etc, fin = -1 (.W)
*	d - taille en octets du loader (.L)
* Pour chaque partie ecran, ex : intro
* 	a - piste de depart (.W)
* 	b - secteur de depart (.W)
* 	c - nb de secteurs occupes (.W)
*	d - face de la disquette (.W)
* Pour le menu en plus
* 	e - taille en octets du main (.L)
**

** MAPPING MEMOIRE
* $800 -> $8FF	[256]	= Variables FDC
* $900 -> $AFF	[512]	= Table
* $B00 -> $15FF	[] 	= Gestionnaire
* $1600 -> $5FFF	[]	= Loader Depacker
* $6000 -> $7FFF	[]	= Reset Demo
* $8000 -> fin_ram	[]	= Ecrans

Base		equ	$0

@Table		equ	Base+$900
@Gest		equ	Base+$B00
@Load		equ	Base+$1600
@Reset		equ	Base+$6000
@Screen		equ	Base+$8000
@Upperram		equ	Base+$80000
@Bootbuffer	equ	Base+$40000

Track		equ	$800
Sect		equ	$802
Sect_to_read	equ	$804
Dest_adr 		equ	$806
Side		equ	$80A
ClearRam		equ	$80C
EndMode		equ	$80E
MaxTrack		equ	$810
Choice		equ	$812

; Caracteristique de la disquette sur laquelle on ecrit la demo 
Nb_of_trk		set	80

