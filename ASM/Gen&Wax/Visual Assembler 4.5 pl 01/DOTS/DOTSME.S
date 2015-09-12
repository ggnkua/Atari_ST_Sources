	; Utilise DOTS.LOD	:  2650 < < 2900 avec couleur

prec=1
nb_points=2500	; DOIT ETRE UN MULTIPLE DE [MULTIPLE]
MULTIPLE=10

INIT_DOTS:	bsr initialisation_dsp
	cmp.w #GWVA_NO_ERROR_GENERIC,d7
	bne .erreur_init_dsp

; On r‚serve les buffers d'‚mition et de r‚ception

	MXALLOC #MX_PREFTTRAM,#3*nb_points*4	; on reserve des .l (X,Y,Z)
	tst.l d0
	beq .plus_de_memoire1
	move.l d0,ptr_table_send

	MXALLOC #MX_PREFTTRAM,#2*nb_points*3	; Offset, motif
	tst.l d0
	beq .plus_de_memoire2
	move.l d0,ptr_table_receive

; On envoie au DSP la r‚solution

	move.l ptr_table_send,a0
	clr.l d0
	move.w GWVA_ROOT_VDI_WORKSTATION_EXTD+4*2,d0
	lsl.l #8,d0			; on construit le mot DSP sur 24 bits, cal‚ … gauche
	move.l d0,(a0)

	clr.l -(sp)
	clr.l -(sp)
	move.l #1,-(sp)		; un mot DSP … envoyer
	pea (a0)
	appel xbios,dsp_blkhandshake,18

; On envoie tous les points

	lea table_pts_sph,a0
	cmp.w #FCHX_RBTON_SPH,choix_objet_dots
	beq.s .choix_sphere
	lea table_pts_tore,a0
.choix_sphere:

	move.l ptr_table_send,a1
	move.w #nb_points*3-1,d1
.transf_vect:
	clr.l d0
	move.w (a0)+,d0
	swap d0			; d‚calage de 8 bits … gauche pour un mot DSP sur 24 bits
				; + 8 d‚calages … gauche pour la precision (les valeurs sont multipli‚es par 256)
	move.l d0,(a1)		; le mot bas = 0
	lea 3(a1),a1		; taille d'un mot DSP
	dbf d1,.transf_vect

	clr.l -(sp)
	clr.l -(sp)
	move.l #nb_points*3,-(sp)	; … envoyer
	move.l ptr_table_send,-(sp)
	appel xbios,dsp_blkhandshake,18

; On envoie les premier angles
	
	clr.w angles
	clr.w angles+2
	clr.w angles+4

	bsr calcule_envoie_cos_sin

	moveq #GWVA_NO_ERROR_GENERIC,d7
.erreur_init_dsp:
	rts

.plus_de_memoire2:
	MFREE ptr_table_send
.plus_de_memoire1:
	bsr restore_dsp

	move.w #ALERT_NO_MEMORY,d0
	move #1,d1
	bsr GWVA_RSC_ALERT_BOX

	moveq #GWVA_ERROR_GENERIC,d7
	rts

	;----------------------------------------------

calcule_envoie_cos_sin:

	lea table_sin,a0
	move.l ptr_table_send,a1
	lea angles,a2

	moveq #3-1,d1
.cos_sin:	move.w (a2)+,d0
	move.l (90*prec*4,a0,d0.w*4),d2	; cosinus en 1er
	lsl.l #8,d2
	move.l d2,(a1)
	lea 3(a1),a1
	move.l (a0,d0.w*4),d2		; sinus
	lsl.l #8,d2
	move.l d2,(a1)
	lea 3(a1),a1
	dbf d1,.cos_sin

	clr.l -(sp)
	clr.l -(sp)
	move.l #3*2,-(sp)		; … envoyer
	move.l ptr_table_send,-(sp)
	appel xbios,dsp_blkhandshake,18

	rts

;------------------------------------------------------------------------------

FIN_DOTS:	bsr restore_dsp
	MFREE ptr_table_send
	MFREE ptr_table_receive
	rts

;------------------------------------------------------------------------------

ROTATION_DOTS:
	bsr efface_buffer_image

	move.l #nb_points*2,-(sp)	; … recevoir (Offset non sign‚, motif)
	move.l ptr_table_receive,-(sp)
	clr.l -(sp)
	clr.l -(sp)
	appel xbios,dsp_blkhandshake,18

	lea objet_fenetre2,a0
	move.l GWVA_WBITM_OBJ_DATA_PTR(a0),a1

	move.l ptr_table_receive,a0
	move.w #nb_points-1,d0
	move.w #8,d1

.affiche_points:
	move.l (a0)+,d2	; +3 pour l'offset, +1 pour l'octet haut du motif
	lsr.l d1,d2
	move.w (a0)+,d3	; motif
	or.w d3,(a1,d2.l)
	dbf d0,.affiche_points

	sub #1*prec,angles
	add #2*prec,angles+2
	add #1*prec,angles+4

	bsr verif_angles

	bsr calcule_envoie_cos_sin

	rts

	;----------------------------------------------

verif_angles:
	lea angles,a0
	move.w #3-1,d1

.all_a:	move.w (a0),d0
.redo1:	bpl.s .cool1
	add.w #360*prec,d0
	bra.s .redo1
.cool1:	cmp.w #360*prec,d0
	blt.s .cool2
	sub.w #360*prec,d0
	bra.s .cool1
.cool2:	move.w d0,(a0)+
	dbf d1,.all_a
	rts

	;----------------------------------------------

efface_buffer_image:
	lea objet_fenetre2,a0

	lea GWVA_ROOT_MFDB_DEST,a2
	move.l GWVA_WBITM_OBJ_DATA_PTR(a0),(a2)+	; pointeur image
	move.l GWVA_WBITM_OBJ_IMG_WIDTH(a0),(a2)+	; largeur image pixel

	move.w GWVA_WBITM_OBJ_IMG_WIDTH(a0),d5
	add.w #15,d5
	ext.l d5
	divu #16,d5
	move.w d5,(a2)+			; largeur image en mots

	move.w #0,(a2)+			; device dependent

	move.w GWVA_WBITM_OBJ_NB_BITPLANES(a0),(a2)+
	clr.w (a2)+				; reserv‚s
	clr.w (a2)+
	clr.w (a2)+

	clr.l GWVA_ROOT_MFDB_SRC

	moveq #0,d0
	moveq #0,d1
	move.w GWVA_WBITM_OBJ_IMG_WIDTH(a0),d2
	sub.w #1,d2
	move.w GWVA_WBITM_OBJ_IMG_HEIGHT(a0),d3
	sub.w #1,d3
	movem.w d0-d3,ptsin
	movem.w d0-d3,ptsin+8			; x,y,w,h

	vro_cpyfm #0,#GWVA_ROOT_MFDB_SRC,#GWVA_ROOT_MFDB_DEST	; All zeros mode

	rts

;------------------------------------------------------------------------------

initialisation_dsp:

	MXALLOC #MX_PREFTTRAM,#10*1024
	tst.l d0
	beq .plus_de_memoire

	save.l d0
	appel xbios,dsp_lock,2		; on essaie de bloquer la ressource DSP
	load.l a0
	tst.w d0
	bne .it_s_locked

	save.l a0
	appel xbios,dsp_requestuniqueability,2	; On demande un identifiant unique pour le programme
	move d0,ability
	load.l a0

	ifnd OPT_FULL_PATHNAMES
	lea GWVA_ROOT_STARTED_PATH,a1	; on reconstruit le nom du fichier .LOD
	lea file_lod,a2
	COPY_STRING_0 a1,a2
	lea -1(a2),a2
	lea file_lod_base,a1
	COPY_STRING_0 a1,a2
	endc

	save.l a0
	pea (a0)
	move.w ability,-(sp)
	pea file_lod
	appel xbios,dsp_loadprog,12	; on charge le fichier .LOD, il est converti, envoy‚ au DSP et ex‚cut‚
	load.l a0

	save.w d0
	MFREE a0
	load.w d0

	tst.w d0
	bmi .erreur_file_lod

	moveq #GWVA_NO_ERROR_GENERIC,d7
	rts

.it_s_locked:
	MFREE a0

	appel xbios,dsp_getprogability,2	; le prog charg‚ est-il le notre ?
	cmp.w ability,d0
	beq.s .its_my_dsp_prog

	move #ALERT_DSP_LOCKED,d0	; si le DSP est occup‚ par un autre prog que le notre ...
	move #2,d1			; on demande si on veut l'arrˆter.
	bsr GWVA_RSC_ALERT_BOX
	cmp.w #2,d0
	beq.s .pas_de_deblocage

.its_my_dsp_prog:
	bsr restore_dsp
	bra initialisation_dsp

.pas_de_deblocage:
	moveq #GWVA_ERROR_GENERIC,d7
	rts

.plus_de_memoire:
	move.w #ALERT_NO_MEMORY,d0
	move #1,d1
	bsr GWVA_RSC_ALERT_BOX
	moveq #GWVA_ERROR_GENERIC,d7
	rts

.erreur_file_lod:
	bsr restore_dsp

	move.w #ALERT_FILE,d0
	move #1,d1
	bsr GWVA_RSC_ALERT_BOX
	moveq #GWVA_ERROR_GENERIC,d7
	rts

	;--------------------------------------------

restore_dsp:
	appel xbios,dsp_unlock,2	; on libŠre la ressource DSP
	clr.w ability
	rts

;------------------------------------------------------------------------------

 DATA
	ifd OPT_FULL_PATHNAMES
file_lod:	dc.b 'd:\assemble\sources.v45\dots\dots.lod',0
	else
file_lod_base:	dc.b 'dots.lod',0
	endc
 even

table_sin:	incbin sin_dsp.tab
table_pts_sph:
	incbin boule.pts
 even
table_pts_tore:
	incbin tore.pts
 even

;------------------------------------------------------------------------------

 BSS
 even
ability:	ds.w 1
size_bin:	ds.l 1

angles:	ds.w 3

	ifnd OPT_FULL_PATHNAMES
file_lod:	ds.b GWVA_ROOT_MAX_PATH_LENGTH
	endc

ptr_table_send:	ds.l 1

ptr_table_receive:	ds.l 1

 TEXT
