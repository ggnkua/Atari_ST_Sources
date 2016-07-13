;	macro pour le PLAYER REAL SND v1.00
pl_data			equ	1	;fichier player.lib en data ou source ?...	
	ifeq	pl_data
offset	equ	0
	else
offset	equ	$1c	;offset d'un prg.
	endc
preloc			equ	0+offset
pinit_module		equ	4+offset
pinit_first_time	equ	8+offset
pinit_int		equ	12+offset
pend_player		equ	16+offset
pload_dsp_prg		equ	20+offset
info_module		equ	24+offset	;pointeur sur la structure suivante {
;	playing	  	 rs.b	2	;octet poids fort utilis‚
;	inc_volume	 rs.b	2	;(0< v >=$100)	
;	volume_general	 rs.b	2	
;	mix_voice_table	 rs.b	32	;pour chaque octet correspond chaque voie
;					{bit 0 =0 mixage a gauche
;					       =1 mixage a droite 
;					 bit 1 =gestion interne
;					=-1 => pas de voies
;	pour chaque voie	rs.b	32
;				{ rs.b	2 =volume
;				{ rs.b	30 =gestion interne	
;}	

;	autre macro

vsync	macro
	move.l	d0,-(sp)
	move.l	$466.w,d0
	cmp.l	$466.w,d0
	beq.s	*-4
	move.l	(sp)+,d0
	endm
;env	macro
	;btst	#1,$ffffa202.w
	;beq.s	*-4-2
	;endm
;rec	macro
	;btst	#0,$ffffa202.w
	;beq.s	*-4-2
	;endm

		rsreset
save_log	rs.l	1	
set_log		rs.l	1
restore_log	rs.l	1
save_reso	rs.l	1	
set_reso	rs.l	1
restore_reso	rs.l	1
save_pal	rs.l	1	
set_pal		rs.l	1
restore_pal	rs.l	1
set_pal2	rs.l	1	
debut_pal	rs.l	1
parametre1	rs.l	1
nb_coul		rs.w	1

asave_screen		macro
			clr.l	(save_log,[$40c.w])
			endm

asave_palette		macro
			clr.l	(save_pal,[$40c.w])
			endm

asave_video		macro
			clr.l	(save_reso,[$40c.w])
			endm

arestore_screen		macro
			clr.l	(restore_log,[$40c.w])
			endm

arestore_palette	macro
			clr.l	(restore_pal,[$40c.w])
			endm

arestore_video		macro
			clr.l	(restore_reso,[$40c.w])
			endm

aset_screen		macro
			move.l	\1,(set_log,[$40c.w])
			endm

aset_palette	macro
			move.l	\1,(set_pal,[$40c.w])
			endm

aset_video		macro
			move.l	\1,(set_reso,[$40c.w])
			endm

aset_nbcoul		macro
			move.l	\1,(set_pal2,[$40C.W])
			move.l	\2,(debut_pal,[$40c.w])
			move.w	\3,(nb_coul,[$40c.w])
			endm



