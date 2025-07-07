;=========================================================================;
;                            DSP SoundTracking                            ;
;                    (C)oderight Nullos / DNT-Crew 1994                   ;
;'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`';
;Ce source contient une partie des routines du soundtracker DSP.          ;
;A savoir:                                                                ;
;         o D‚finition des variables & buffer du soundtracker.            ;
;                                                                         ;
;Comme d'habitude, un 'tab settings' = 11 est le bienvenu...              ;
;'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`';
;Le cas d'un programme en tache de fond utilisant une routine de reception;
;ou transmission Host, est correctement trait‚, s'il utilise les registres;
;(r4,n4,m4) pour son driver d'interruption.                               ;
;'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`';
;Ceci est un programme freeware, MAIS ce n'est pas du domaine public.     ;
;Si vous utilisez tout ou partie de ce source ou d'un autre source formant;
;ma routine de soundtracker au DSP, dans un but non-lucratif, n'oubliez   ;
;pas de me le signaler.                                                   ;
;Si par contre il s'agit d'une utilisation dans le cadre d'un programme   ;
;commercial, il faudra demander mon autorisation, certes par simple       ;
;formalit‚ mais quand mˆme...                                             ;
;======================================================= Version 2.7 =====;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;; Travail de la boucle de mixage, en m‚moire interne
	org	x:$0
pos_frac	ds	1
nb_ech	ds	1
mask	dsm	8
	ds	1
iram_size	equ	(*-pos_frac)
;;;;;;;;;;; Variables 'lentes' de travail global.
	org	x:(BASEAD-maxspl-MixVarSize)
			;Zone de travail, pour le mixage.
lvol1	ds	1	;Volume gauche voix 1
rvol1	ds	1	;Volume droit
bala1	ds	1	;Balance
avol1	ds	1	;Volume original, amiga
incr1	ds	1	;Incr‚ment de fr‚quence
nspl1	ds	1	;Nb de paquets de 2 … traiter
npar1	ds	1	;Parit‚ de l'envoi DMA

lvol2	ds	1
rvol2	ds	1
bala2	ds	1
avol2	ds	1
incr2	ds	1
nspl2	ds	1
npar2	ds	1

lvol3	ds	1
rvol3	ds	1
bala3	ds	1
avol3	ds	1
incr3	ds	1
nspl3	ds	1
npar3	ds	1

lvol4	ds	1
rvol4	ds	1
bala4	ds	1
avol4	ds	1
incr4	ds	1
nspl4	ds	1
npar4	ds	1

rx_mode	ds	1


r_lvol1	ds	1	;Ceci est la zone de r‚ception des
r_rvol1	ds	1	;infos pour les samples. Elle est
r_bala1	ds	1	;remplie par le GetVoice, et
r_avol1	ds	1	;transf‚r‚e en zone de travail
r_incr1	ds	1	;avec un d‚lai pour la reception.
r_nspl1	ds	1
r_npar1	ds	1
r_lvol2	ds	1
r_rvol2	ds	1
r_bala2	ds	1
r_avol2	ds	1
r_incr2	ds	1
r_nspl2	ds	1
r_npar2	ds	1
r_lvol3	ds	1
r_rvol3	ds	1
r_bala3	ds	1
r_avol3	ds	1
r_incr3	ds	1
r_nspl3	ds	1
r_npar3	ds	1
r_lvol4	ds	1
r_rvol4	ds	1
r_bala4	ds	1
r_avol4	ds	1
r_incr4	ds	1
r_nspl4	ds	1
r_npar4	ds	1
r_rx_mode	ds	1
r_nb_ech	ds	1

fracs	ds	4	;Positions d‚cimales actuelles
r_fracs	ds	4	;Idem, mais pour r‚ception
;Nb: On commande la r‚ception R(n+1), et on mixe M(n). Or fracx correspond au
;d‚part de M(n), alors que pour R(n+1) on a besoin des positions terminales
;de M(n). Donc on a besoin d'un double pour la r‚ception, dont la coh‚sion est
;assur‚ par l'‚quit‚ du calcul (par n*add .. en mix, et mpy n,.. en r‚ception)
;La seule diff‚rence est un facteur 2 dans les valeurs.

last_get1	ds	1	;Points de d‚part et de fin, pour la
last_get2	ds	1	;r‚ception des samples.
last_calc1	ds	1	;Idem pour le mixage. Ils renseignent
last_calc2	ds	1	;sur l'interruption pr‚c‚dente.

save_r0	ds	1
save_m0	ds	1
save_n0	ds	1
save_a2	ds	1
save_a1	ds	1
save_a0	ds	1
save_b2	ds	1
save_b1	ds	1
save_b0	ds	1
save_r1	ds	1
save_m1	ds	1
save_n1	ds	1
save_r2	ds	1
save_m2	ds	1
save_n2	ds	1
save_r5	ds	1
save_m5	ds	1
save_n5	ds	1
save_code	ds	MixOverlaySize
save_xram	ds	iram_size
save_r6	ds	1
save_m6	ds	1
save_n6	ds	1
save_x1	ds	1
save_x0	ds	1
save_y1	ds	1
save_y0	ds	1

re_send1	ds	1
re_send2	ds	1

save_cx0	ds	1

	IF	(*-lvol1)>MixVarSize
	fail	'Variables plus grandes que pr‚vu!!'
	ENDIF
;;;;;;;;;;; Buffers de mixage
	org	y:BASEAD-maxspl
buff24	ds	maxspl

	org	y:BASEAD
restitbuf	dsm	$1000

	org	x:BASEAD
receptbuf	dsm	$1000
