*** PLAYER d'un module .DTM en mode FAST V1.00
**  TAB = 12
*
* Ce programme permet de lancer le player.
* (Voir le label module pour le nom du mod)
*
* Les restrictions sur les modules .DTM pour cette version :
*
* - Module en stereo
* - Son 8 bits mono
* - Nombre de voie paire....
*
* Excusez moi pour ces petites contraintes mais le temps de realisation
* de ce programme (1 apres midi) ne m'a pas permis de faire plus !!!
*
* Le player n'est aucunement optimis‚, et il peut l'etre GRANDEMENT !
*
* MC JEE / KAMIKAZES




* This program launch the player
* (See module for the name of the mod)
*
* There are some restrictions for this version on .DTM
*
* - Module in Stereo
* - Sound 8 bits mono
* - Number of voice even
*
* Wait the version 1.01 for 16 bits sounds.
* 
*
* This player is not optimised, you can optimise it !!!
*
* MC JEE / KAMIKAZES



	SECTION TEXT
	
TEMPS	equ 0

; Macro pour aligner le cache

Cache_macro	MACRO
.Cache\@	swap d0
	swap d0
	IIF (.Cache\@-Debut)-(.Cache\@-Debut)/4*4	nop
	ENDM
	
; Macro pour swaper superviseur / utilisateur 

Setsuper	MACRO
	move.l \1,-(sp)
	move.w #32,-(sp)
	trap #1
	move.l d0,old_sp
	addq.w #6,sp
	ENDM
	
; Macro pour charger un programme DSP binaire.
	
Boot_dsp	MACRO
	move.w #113,-(sp)
	trap #14
	addq.w #2,sp

	move.w d0,-(sp)
	move.l \1,-(sp)
	move.l \2,-(sp)
	move.w #110,-(sp)
	trap #14
	add.w #12,sp
 	ENDM


; Debut du programme...
	
Debut:	move.l 4(a7),a6	;Adresse base page
	move.l $c(a6),d0
	add.l $14(a6),d0
	add.l $1c(a6),d0
	add.l #$100,d0
	move.l #mystack,a7
	move.l d0,-(sp)
	move.l a6,-(sp)
	clr.w -(sp)
	move.w #$4A,-(sp)
	trap #1
	add.w #12,sp	;Garde que la memoire necessaire
	tst.w d0
	bmi FIN

	jsr do_note
	
	Setsuper #0		;Passe en superviseur
	lea mystack,a7	;Notre pile seulement

	movec cacr,d0	;Le cache doit etre actif !!
	move d0,old_cacr
	move.w #$3111,d0
	movec d0,cacr

	Boot_dsp #(dsp_buff_end-dsp_buff)/3,#dsp_buff
	
	jsr init_adc	;Initialise le son
	jsr Init_all	;
	lea module,a0
	jsr Init_module	;Initialisation du module
	tst.b d0		;Y'a une erreur ?
	bne FIN		;Si oui alors terminus
	
	jsr joue		;Player en marche
	
.wait	cmp.b #$39,$fffffc02.w	;Attend l'appui d'espace
	bne.s .wait

	jsr jouepas		;Arrete tous !

FIN	Setsuper old_sp	;Passe en utilisateur
	
	clr.w -(sp)		;Fin du programme
	trap #1 
	
	include load_dtm.s

	SECTION DATA
dsp_buff	incbin 'digidsp2.out'
dsp_buff_end
p_end	dc.l module_end
module	incbin 'c:\mod\new_pop3.dtm'
	dc.l 0
module_end	ds.l 50000		;Place necessaire suivant le module
	SECTION BSS
	ds.w 2000
mystack	ds.w 1
old_sp	ds.l 1
old_cacr	ds.l 1