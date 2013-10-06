;
;
; ®Cookie Jar¯ Driver
; ½ 1993 Dbug II for Rembrandt system compatibility.
;
;

 pea super
 move #$26,-(sp)
 trap #14
 addq #6,sp
 clr -(sp)
 trap #1
 
super
 move.l $5a0.w,d0
 bne.s lecture_cookies
 moveq #-1,d0		Si on trouve pas, c'est qu'il y a une erreur !
 rts

lecture_cookies 
 move.l d0,a0
.boucle_lecture_cookies
 move.l (a0)+,d0			Identificateur
 beq .fin_boucle_lecture_cookies
 move.l (a0)+,d1			Valeur affect‚e … l'identificateur
 lea cookie_list,a1
.boucle_m‚morise_cookie
 cmp.l (a1)+,d0				Compare si on le connait ???
 beq .valide_cookie
 tst.l (a1)+				Ou bien, fin de la liste ???
 bne.s .boucle_m‚morise_cookie
 bra .boucle_lecture_cookies
.valide_cookie
 move.l d1,([a1])			Le cookie est m‚moris‚
 bra .boucle_lecture_cookies
 
.fin_boucle_lecture_cookies 
 rts

 data

cookie_list
 dc.l '_CPU',cookie_cpu
 dc.l '_VDO',cookie_vdo
 dc.l '_SND',cookie_snd
 dc.l '_MCH',cookie_mch
 dc.l '_SWI',cookie_swi
 dc.l '_FRB',cookie_frb
 dc.l '_JPD',cookie_jpeg
 dc.l 'NVDI',cookie_nvdi
 dc.l 0,0

 BSS

***                                                 ***
**** Ici, on trouve les cookies officiels d'atari. ****
***                                                 ***
cookie_cpu	ds.l 1	Type de processeur
cookie_vdo	ds.l 1	Type de carte vid‚o
cookie_snd	ds.l 1	Type de sortie son
cookie_mch	ds.l 1	Type de machine
cookie_swi	ds.l 1	Configuration des switches
cookie_frb	ds.l 1 	Un bidule sur le DMA ???
cookie_jpeg	ds.l 1	Indique si le driver JPEG de brainstorm est l…

;;;                                                        ;;;
;;;; Ici, c'est les autres cookies... Les non officiels ! ;;;;
;;;                                                        ;;;
cookie_nvdi	ds.l 1	Indique si NVDI est actif ou non


 end
 