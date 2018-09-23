; REMBRANDT 3.0 - ½  Dbug II
;
; Module de choix des chemins d'accŠs (1.0)
;

 ifeq _main_part
 <pREMB_xxx.S>q doit ˆtre assembl‚ !!!
 END
 endc

 TEXT

choix_chemin_rim
choix_chemin_wim
choix_chemin_ifx
choix_chemin_gvl
choix_chemin_gvs
choix_chemin_efms
choix_chemin_clip
choix_chemin_work
 rts
 
;objet_chemin_confirmer	EQU 1
;objet_chemin_annuler	EQU 2

affiche_chemins
;
; On scanne les diff‚rents objets...
;
.boucle_gŠre_chemins	
 lea affectation_chemins,a0
.scanne_chemins
 move (a0)+,d1
 bmi .boucle_gŠre_chemins	Si -1, c'est la fin de la liste...
 move.l (a0)+,a1		Adresse de la chaine de titre
 move.l (a0)+,a2		Endroit, o— l'on ‚crit la chaine...
 move.l (a0)+,d2		L'extension...
 cmp d1,d0			Tant que diff‚rent, on continue … chercher.
 bne.s .scanne_chemins


 movem.l d0-a6,-(sp)
 fsel_exinput a2,#nom_vide,a1
 movem.l (sp)+,d0-a6

 tst int_out+2			Cas o— l'on a fait ANNULER...
 beq .zap
 tst int_out			Cas o— ???
 beq .zap
 rts
.zap
 rts 

 lea chemin_fichier,a0
 bsr analyse_chemin_fichier
 
 bra .boucle_gŠre_chemins

.ignore_param‚trages
 bsr ferme_formulaire
 rts

.confirme_param‚trages
 bsr ferme_formulaire
 rts

 
; cmp #objet_repertoire_rim,objet_exit
; bne .pas_changement_r‚pertoire_rim
; bsr choisie_repertoire_rim
;.pas_changement_r‚pertoire_rim

; move #objet_pref_fileselect*24,d0	Utilisation d'un fileselect standard ou non...
; lea flag_fileselect,a1			Le drapeau qui correspond
; bsr m‚morise_bouton 


 DATA
 
txt_repertoire_rim dc.b "R‚pertoire RIM",0
txt_repertoire_wim dc.b "R‚pertoire WIM",0
txt_repertoire_ifx dc.b "R‚pertoire IFX",0
txt_repertoire_gvl dc.b "R‚pertoire GVL",0
txt_repertoire_gvs dc.b "R‚pertoire GVS",0
txt_repertoire_efms dc.b "R‚pertoire EFMS",0
txt_repertoire_clip dc.b "Choix presse-papier",0
txt_repertoire_work dc.b "R‚pertoire de travail",0

nom_vide	dcb.b 20,0

 even
 
affectation_chemins
 dc.w -1
azertyu macro
 dc.w objet_chemin_rim
 dc.l txt_repertoire_rim
 dc.l chemin_drivers_rim
 dc.l '.RIM'
 
 dc.w objet_chemin_wim
 dc.l txt_repertoire_wim
 dc.l chemin_drivers_wim
 dc.l '.WIM'
 
 dc.w objet_chemin_ifx
 dc.l txt_repertoire_ifx
 dc.l chemin_drivers_ifx
 dc.l '.IFX'
 
 dc.w objet_chemin_gvl
 dc.l txt_repertoire_gvl
 dc.l chemin_drivers_gvl
 dc.l '.GVL'
 
 dc.w objet_chemin_gvs
 dc.l txt_repertoire_gvs
 dc.l chemin_drivers_gvs
 dc.l '.GVS'
 
 dc.w objet_chemin_efms
 dc.l txt_repertoire_efms
 dc.l chemin_drivers_efms
 dc.l '.EFM'
 
 dc.w objet_chemin_clipboard
 dc.l txt_repertoire_clip
 dc.l chemin_drivers_clip
 dc.w '.*',0

 dc.w objet_chemin_temp
 dc.l txt_repertoire_work
 dc.l chemin_drivers_work
 dc.w '.*',0
 
 dc.w -1
 endm
