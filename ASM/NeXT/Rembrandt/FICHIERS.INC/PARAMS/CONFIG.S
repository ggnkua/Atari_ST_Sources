; REMBRANDT 3.0 - ½  Dbug II
;
; Module de gestion du Cookie Jar. (1.1)
;
 ifeq _main_part
 <pREMB_xxx.S>q doit ˆtre assembl‚ !!!
 END
 endc

 TEXT

teste_machine
 pea lecture_cookies		Lecture des cookies en mode superviseur
 move #$26,-(sp)		Si D0=0  -> Ok, pas de problŠme
 trap #14			Si D0=-1 -> Y'a pas de cookie jar !
 addq #6,sp

 tst.b flag_cookie_jar
 beq.s .machine_pas_suffisante
 
 cmp.l #30,cookie_cpu		Il faut AU MOINS un 68030.
 blt .machine_pas_suffisante
 cmp.l #$30000,cookie_vdo	Il faut l'affichage Falcon.
 blt .machine_pas_suffisante
 cmp.l #$30000,cookie_mch	Il faut AU MOINS un Falcon 030.
 blt .machine_pas_suffisante
 moveq #0,d0
 rts
 
.machine_pas_suffisante
 move.l ptr_falcon_only,adresse_formulaire
 bra .quitte_test

.pas_de_cookie_jar
 move.l ptr_falcon_only,adresse_formulaire
 bra .quitte_test

 nop
  
.quitte_test
 bsr affiche_formulaire
 graf_mouse #0			On remet la souris
 bsr gere_formulaire
 bsr ferme_formulaire 
 moveq #-1,d0
 rts

lecture_cookies 
 move.l $5a0.w,d0	V‚rifie si le Cookie Jar est pr‚sent
 bne.s .cookie_jar_ok
 sf flag_cookie_jar
 rts
 
.cookie_jar_ok
 sf flag_affichage_normal		On peut commuter la r‚solution...
 move.l d0,a0
.boucle_lecture_cookies
 move.l (a0)+,d0			Identificateur
 beq .fin_boucle_lecture_cookies
 move.l (a0)+,d1			Valeur affect‚e … l'identificateur
 lea cookie_list,a1
.boucle_compare_cookie
 move.l (a1)+,d2
 beq.s .boucle_lecture_cookies		0-> Fin de la liste connue
 cmp.l d2,d0				Compare si on le connait ???
 beq .valide_cookie
 addq #6,a1				Cookie suivant
 bra.s .boucle_compare_cookie
.valide_cookie
 move.l d1,([a1])			Le cookie est m‚moris‚
 tst 4(a1)				Flag de commutation vid‚o..
 beq.s .commutation_possible
 st flag_affichage_normal		On peut commuter la r‚solution...
.commutation_possible
 bra .boucle_lecture_cookies
 
.fin_boucle_lecture_cookies 
 st flag_cookie_jar
 rts

 data

 even
; .l La valeur ASCII qui d‚crit le cookie
; .l L'adresse ou mettre la valeur du cookie
; .w 0-> Ignorer / 1-> Empecher l'affichage
;
cookie_list
 dc.l '_CPU',cookie_cpu			Type de processeur
 dc.w 0
 dc.l '_VDO',cookie_vdo			Type d'affichage vid‚o
 dc.w 0
 dc.l '_SND',cookie_snd			Type de systŠme sonore
 dc.w 0
 dc.l '_MCH',cookie_mch			ModŠle de la machine
 dc.w 0
 dc.l '_SWI',cookie_swi			???
 dc.w 0
 dc.l '_FRB',cookie_frb			???
 dc.w 0
 dc.l '_JPD',cookie_jpeg		Driver JPEG de Brainstorm
 dc.w 0
 dc.l 'NVDI',cookie_nvdi		NVDI
 dc.w nvdi_stop
 dc.l 'BLOW',cookie_blowup		Blow Up! (Etendeur de r‚solution)
 dc.w 1
 dc.l 'äFSC',cookie_falcon_screen	Falcon Screen (Idem)
 dc.w 1
 dc.l 'VSCR',cookie_virtual_screen	Screen Blaster (Idem)
 dc.w 1
 dc.l 'OSBC',cookie_screen_blaster	Screen Blaster (Idem)
 dc.w 1
 dc.l 0,0
 dc.w 0

 BSS

***                                                 ***
**** Ici, on trouve les cookies officiels d'atari. ****
***                                                 ***
 even
cookie_cpu		ds.l 1	Type de processeur
cookie_vdo		ds.l 1	Type de carte vid‚o
cookie_snd		ds.l 1	Type de sortie son
cookie_mch		ds.l 1	Type de machine
cookie_swi		ds.l 1	Configuration des switches
cookie_frb		ds.l 1 	Un bidule sur le DMA ???
cookie_jpeg		ds.l 1	Indique si le driver JPEG de brainstorm est l…

;;;                                                        ;;;
;;;; Ici, c'est les autres cookies... Les non officiels ! ;;;;
;;;                                                        ;;;
cookie_nvdi		ds.l 1	Indique si NVDI est actif ou non
cookie_blowup		ds.l 1	Blow Up! (Etendeur de r‚solution)
cookie_falcon_screen	ds.l 1	Falcon Screen (Idem)
cookie_virtual_screen	ds.l 1	Screen Blaster (Idem)
cookie_screen_blaster	ds.l 1	Screen Blaster (Idem)

