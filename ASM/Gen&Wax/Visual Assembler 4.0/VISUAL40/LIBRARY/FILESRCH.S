******************************************************************
* Module de recherche r‚cursive de fichiers * (c) Wax 30/12/1993 *
* Adapt‚ au V 4.0 la 21/06/96
******************************************************************
;	Entr‚e :	a0.l : chemin de d‚part : U:\PATH
;		a1.l : pointeur sur un masque multiple termin‚ par 0 0 max 100 car
;		exemple : *.F?D 0 AZERTY.* 0 *.MOD 0 0
;		a2.l : adresse de la routine o— sauter
;		d0.w : 0 recherche normale, 1 recursive
;	Sortie :	d7.w : 0 =OK -2=bad path -1=user stop(vous avez rendu d0<0)
;
;	Appel de votre routine :
;	Entr‚e :	a0 : pathname du fichier U:\PATH
;	Sortie :	faites un rts avec d0=0 = continue; d0=-1 arrˆte l…

SEARCH_FILE_RECURSIVELY:
	movem.l a0-a2,FILESEARCH_PATH
	move d0,FILESEARCH_MODE

	FGETDTA
	move.l d0,FILESEARCH_SAVE_DTA

	clr d0
	move.b ([FILESEARCH_PATH]),d0
	sub.b #'A',d0
	DSETDRV d0

	move.l FILESEARCH_PATH,a0
	lea 2(a0),a0
	DSETPATH (a0)
	tst d0
	bne .end_with_erreur

	move.l FILESEARCH_PATH,a0
	lea 2(a0),a0
	lea FILESEARCH_CURRENT_PATH,a1
	bsr .copy_for_next
	lea FILESEARCH_CURRENT_PATH,a0
	bsr .put_anti_at_end

	move.l FILESEARCH_MASK,a0	; est-ce un masque ou un nom ?
.retest:	tst.b (a0)
	beq.s .its_not_mask
	cmp.b #'*',(a0)
	beq.s .its_mask
	cmp.b #'?',(a0)+
	beq.s .its_mask
	bra.s .retest

.its_not_mask:
	move.l FILESEARCH_MASK,a0
	DSETPATH (a0)
	tst d0
	bne.s .not_a_dir

	lea FILESEARCH_MASK_2POINTS,a0
	DSETPATH (a0)

	move.l FILESEARCH_MASK,a0
	lea FILESEARCH_NEXT_CD_DIR,a1
	bsr .copy_for_next

	move.l #FILESEARCH_MASK_EVERYTHING,FILESEARCH_MASK
	bra.s .continuons

.its_mask:
.not_a_dir:	move.w #'.'*256,FILESEARCH_NEXT_CD_DIR

.continuons:bsr.s .find_recurse

	save.w d0
	move.l FILESEARCH_SAVE_DTA,a0
	FSETDTA (a0)
	load.w d7
	rts

.end_with_erreur:
	moveq #-2,d7
	rts


;---------------------------------------------------------------------------
for_link=44+2

.find_recurse:
	link a6,#-for_link		; dans nom : le chemin
	move.l a7,a5

	clr.w 44(a5)
	cmp.w #'.'*256,FILESEARCH_NEXT_CD_DIR
	bne.s .pas_root
	move.w #1,44(a5)		; pour pas faire cd .. sur root
.pas_root:

	DSETPATH FILESEARCH_NEXT_CD_DIR
	tst d0
	bne .please_stop_here		; dŠs fois que ... l'util soit s‚vŠrement burn‚

	tst 44(a5)
	bne.s .no_no
	lea FILESEARCH_NEXT_CD_DIR,a0
	bsr .add_to_path
	lea FILESEARCH_CURRENT_PATH,a0
	bsr .put_anti_at_end
.no_no:
	bsr .fset_dta
	FSFIRST #%010011,FILESEARCH_MASK_EVERYTHING	; tous les dirs + fichiers (p.67)
	tst d0
	bne .no_dir_here

.next_dir:	cmp.b #'.',30(a5)		; ne marche pas sous Unix
	beq.s .next_research

	btst.b #4,21(a5)
	beq.s .its_a_file

	tst FILESEARCH_MODE		; r‚cursif ?
	beq.s .next_research

	lea 30(a5),a0
	lea FILESEARCH_NEXT_CD_DIR,a1
	bsr .copy_for_next

	save.l a5
	bsr .find_recurse
	load.l a5
	tst d0
	bmi .please_stop_here
	bra.s .next_research

.its_a_file:bsr .compare_to_mask
	tst d0
	bmi.s .next_research

	bsr.s .make_name
	save.l a5-a6
	lea FILESEARCH_RETURN_NAME,a0
	jsr ([FILESEARCH_ROUTINE])
	load.l a5-a6
	tst d0
	bmi.s .please_stop_here

	clr d0
	move.b ([FILESEARCH_PATH]),d0
	sub #'A',d0
	DSETDRV d0
	DSETPATH FILESEARCH_CURRENT_PATH		; dŠs fois que le GROC

.next_research:
	bsr.s .fset_dta
	FSNEXT
	tst d0
	beq .next_dir
.no_dir_here:

	tst.w 44(a5)
	bne.s .its_root
	bsr .sub_one_path
	DSETPATH FILESEARCH_MASK_2POINTS

.its_root:
	clr d0

.please_stop_here:
	unlk a6
	rts

.fset_dta:	FSETDTA (a5)
	rts

.make_name:	lea FILESEARCH_RETURN_NAME,a1
	move.b ([FILESEARCH_PATH]),(a1)+		; drive
	move.b #':',(a1)+
	lea FILESEARCH_CURRENT_PATH,a0		; path
	bsr .copy_for_next

	lea -1(a1),a1
	lea 30(a5),a0
	bsr .copy_for_next		; filename
	rts

.compare_to_mask:
	clr d0
	move.l FILESEARCH_MASK,a0
.one_more_chance:
	lea 30(a5),a1

.rec:	tst.b (a0)		; a0:mask , a1:=nom
	beq.s .end_of_mask
	tst.b (a1)
	beq.s .end_not_ok	; plus de comparaison mais encore du masque NOT OK
	cmp.b #'*',(a0)	; car on a d‚fil‚ tout le nom avec la 1Šre *
	beq.s .its_etoile
	cmp.b #'?',(a0)
	beq.s .its_interro

	cmp.b (a0)+,(a1)+
	beq.s .rec

.end_not_ok:

.f0:	tst.b (a0)+	; si comparaison pas cool avnt la fin du mask
	bne.s .f0
	lea -1(a0),a0

	tst.b 1(a0)
	beq.s .last_mask
	lea 1(a0),a0
	bra.s .one_more_chance

.last_mask:	move.w #-1,d0
.end_ok_cmp:	rts

.end_of_mask:tst.b (a1)
	beq.s .end_ok_cmp	; plus de masque et pas sorti : OK
			; si fin du nom … comparer aussi
	bra.s .end_not_ok	; sinon (ex. : *.PR -> TXT.PRG)

.its_etoile:	lea 1(a0),a0
	move.b (a0),d1
.find:	tst.b (a1)
	beq.s .rec		; fin du nom de fichier atteint
	cmp.b (a1)+,d1
	bne.s .find
	lea -1(a1),a1	; si c'‚tait 0, il faut le comparer...
	bra.s .rec

.its_interro:
	lea 1(a0),a0
	lea 1(a1),a1
	bra.s .rec

;---------------------------------------------------------------------------

.add_to_path:lea FILESEARCH_CURRENT_PATH,a1
.find0:	tst.b (a1)+
	bne.s .find0
	lea -1(a1),a1		; sur le 0

.copy_for_next:
	COPY_STRING_0 a0,a1
	rts

.sub_one_path:
	lea FILESEARCH_CURRENT_PATH,a0
.find1:	tst.b (a0)+
	bne.s .find1
	lea -2(a0),a0
.not_anti:	cmp.b #'\',-(a0)
	bne.s .not_anti
	clr.b 1(a0)
	rts

.put_anti_at_end:
.not_0:	tst.b (a0)+
	bne.s .not_0
	cmp.b #'\',-2(a0)
	beq.s .already	; si root
	move.b #'\',-1(a0)
	clr.b (a0)
.already:	rts
;---------------------------------------------------------------------------

	DATA
FILESEARCH_MASK_EVERYTHING:	dc.b '*.*',0
FILESEARCH_MASK_2POINTS:	dc.b '..',0
	even

	BSS
FILESEARCH_PATH:	ds.l 1	; chemin ou commencer la recherche
FILESEARCH_MASK:	ds.l 1	; masque de recherche
FILESEARCH_ROUTINE:	ds.l 1	; ad. routien o— sauter
FILESEARCH_MODE:	ds.w 1	; doit-on faire une recherche r‚cursive (0=non)

FILESEARCH_SAVE_DTA:	ds.l 1
FILESEARCH_CURRENT_PATH:ds.b GWVA_MAX_PATH_LENGTH
	; path pour construire les noms de fichier
	; path courant durant le traitement r‚cursif...

FILESEARCH_NEXT_CD_DIR:	ds.b 8+1+3+1	; chemin o— rentrer pour le prochain appel r‚cursif
FILESEARCH_RETURN_NAME:	ds.b GWVA_MAX_PATH_LENGTH	; nom renvoy‚ aux abon‚s traiteurs
 even
	TEXT
