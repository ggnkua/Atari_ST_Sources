*-------------------------------------------------------------------------*
		
		********
		TEXT
		********
				
		OPT	O+
		OPT	OW-
		OPT	X+
		
		********
		
		COMMENT HEAD=$7
		
		OUTPUT	\RUNE\RUN.APP
		
		********
		
_TIME_BASE	=	200
_FLAG_AUTOPEN	=	0
_FLAG_AUTORSC	=	1
_FLAG_NEWOBJ	=	1
_FLAG_MENUBAR	=	0
_FLAG_RIGHTCLIK	=	0

win_title_text_color_1	=	6
win_title_text_color_2	=	14
win_title_back_color_1	=	1
win_title_back_color_2	=	1
win_title_border_color_1	=	9
win_title_border_color_2	=	9

test_aes		=	0
tramage		=	8

		********
		
		* aes kernel:
		
		incdir	\wlib\
		include	KERNEL.S
		include	LIB_STR.S
		
		********
		
		incdir	\RUNE\
		include	RUN.TAG
		INCLUDE	FTREE.S
		
		********

*-------------------------------------------------------------------------*
		TEXT
*-------------------------------------------------------------------------*
		
		********
ACC_INIT:
		rts		
		
		********
APP_INIT:
		movem.l	d0-a6,-(sp)
		
		move.w	#"D",cur_drive
		
		move.l	_P_RSCADDR,a0
		
		_rsc_gaddr a0,#0,#0
		move.l	d0,tree_main
		
		_rsc_gaddr a0,#0,#1
		move.l	d0,tree_deux
		
		_rsc_gaddr a0,#0,#2
		move.l	d0,tree_trois
		
		****
		
		clr.l	-(sp)
		move.l	tree_main,-(sp)
		jsr	FORM_CREATE
		lea	8(sp),sp
		move.l	d0,form_main
		
		
		clr.l	-(sp)
		move.l	tree_deux,-(sp)
		jsr	FORM_CREATE
		lea	8(sp),sp
		move.l	d0,form_deux
		
		clr.l	-(sp)
		move.l	tree_trois,-(sp)
		jsr	FORM_CREATE
		lea	8(sp),sp
		move.l	d0,form_trois
		
		****
		
		move.w	#8,-(sp)
		move.l	form_main,-(sp)
		pea	cherche_chaine_curpath
		jsr	TAG_MULTI
		lea	10(sp),sp
		
		move.w	#20,-(sp)
		move.l	form_deux,-(sp)
		pea	cherche_img_a
		jsr	TAG_MULTI
		lea	10(sp),sp
		
		move.w	#21,-(sp)
		move.l	form_deux,-(sp)
		pea	cherche_img_b
		jsr	TAG_MULTI
		lea	10(sp),sp
		
		move.w	#22,-(sp)
		move.l	form_deux,-(sp)
		pea	cherche_img_c
		jsr	TAG_MULTI
		lea	10(sp),sp
		
		move.w	#23,-(sp)
		move.l	form_deux,-(sp)
		pea	cherche_icone_a
		jsr	TAG_MULTI
		lea	10(sp),sp
		
		
		move	#2,-(sp)
		move.l	form_main,-(sp)
		pea	cherche_frame_1
		jsr	TAG_MULTI
		lea	10(sp),sp
		
		move	#3,-(sp)
		move.l	form_main,-(sp)
		pea	cherche_frame_2
		jsr	TAG_MULTI
		lea	10(sp),sp
		
		move	#33,-(sp)
		move.l	form_main,-(sp)
		pea	cherche_pix_4
		jsr	TAG_MULTI
		lea	10(sp),sp
		
		********
		
		; creation du pix fond de directory tree
		
		lea	struc_pix_2,a2
		
		move.l	#chemin_pix_2,gpix_path(a2)
		clr.l	gpix_ptr(a2)
		clr.l	gpix_list(a2)
		clr.l	gpix_x(a2)
		clr.l	gpix_y(a2)
		move.l	#%11,gpix_flags(a2)
		
		****
		
		; creation du pix fond des fichiers
		
		lea	struc_pix_3,a2
		
		move.l	#chemin_pix_3,gpix_path(a2)
		clr.l	gpix_ptr(a2)
		clr.l	gpix_list(a2)
		move.l	#%11,gpix_flags(a2)
		clr.l	gpix_x(a2)
		clr.l	gpix_y(a2)
		
		
		********
		
		pea	test_dir
		gem	dsetpath
		
		bsr	build_directory
		
		********
		
		move.l	#$7fffffff,speed_factor
		
		********
		
		move.l	form_main,-(sp)
		move.w	#1,-(sp)
		clr.l	-(sp)
		jsr	FORM_OPEN
		lea	10(sp),sp
		
		; provoquer un redraw g‚n‚ral
		
		move	#3,_A_INTIN
		movem.w	_DESK_XYWH,d0-d3
		movem.w	d0-d3,_A_INTIN+2
		movem.w	d0-d3,_A_INTIN+10
		AES	FORM_DIAL
		
		********
.end
		movem.l	(sp)+,d0-a6
		rts
		
		********

****************************************************************

		********
create_background:		
		; creation d'un arbre de fond de bureau
		
		lea	arbre_fond,a0
		move.l	a0,_DESK_TREE
		
		move	#-1,ob_next(a0)
		move	#-1,ob_head(a0)
		move	#-1,ob_tail(a0)
		move	#%1<<5,ob_flags(a0)
		move	#0,ob_state(a0)
		move	#G_USERDEF,ob_type(a0)
		move.l	#parmblk_fond,ob_spec(a0)
		move.l	_DESK_XYWH,ob_x(a0)
		move.l	_DESK_XYWH+4,ob_w(a0)
		
		; creation d'un g_pix
		
		lea	objet_gpix_fond,a2
		
		move	#-1,ob_next(a2)
		move	#-1,ob_head(a2)
		move	#-1,ob_tail(a2)
		move	#%1<<5,ob_flags(a2)
		move	#0,ob_state(a2)
		move	#G_PIX,ob_type(a2)
		move.l	#struc_pix_1,ob_spec(a2)
		move.l	_DESK_XYWH,ob_x(a2)
		move.l	_DESK_XYWH+4,ob_w(a2)
		
		; reglage du gpix
		
		lea	struc_pix_1,a2
		
		move.l	#chemin_pix_1,gpix_path(a2)
		clr.l	gpix_ptr(a2)
		clr.l	gpix_list(a2)
		clr.l	gpix_x(a2)
		clr.l	gpix_y(a2)
		move.l	#%11,gpix_flags(a2)
		
		; reglage de l'user_parm
		
		lea	parmblk_fond,a2
		move.l	#dessine_fond,(a2)+
		move.l	#objet_gpix_fond,(a2)+
		
		; l'imposer au bureau
		
		lea	_A_INTIN,a1
		move.l	#$0000000e,(a1)+
		move.l	a0,(a1)+
		clr.l	(a1)+
		
		AES	WIND_SET
		
		rts
		
		********

*-------------------------------------------------------------------------*
		
		********
		
		; routines pour le fond de bureau
dessine_fond		
		link	a6,#0
		movem.l	d1-a5,-(sp)
		
		move.l	8(a6),a5
		
		move.l	pb_parm(a5),-(sp)
		move	#0,-(sp)
		move	#1,-(sp)
		pea	pb_xc(a5)
		
		jsr	_OBJ_DRAW
		
		moveq	#0,d0
		movem.l	(sp)+,d1-a5
		unlk	a6
		rts
		
		****
		BSS
		****

arbre_fond	ds.b	24*2

parmblk_fond	ds.l	2
		
objet_gpix_fond	ds.b	24

chemin_pix_4	ds.b	128
		even

		****
		
********************************************************************

		****
		TEXT
		****

test_slide
		
		move.l	FormMainPtr,-(sp)
		clr.l	-(sp)
		move.w	#44,-(sp)
		
		move	#1,-(sp)
		move	#1,-(sp)
		
		jsr	_FORM_SHIFT
		
		
		rts
		
		********

*-------------------------------------------------------------------------*
		
		********
pix_avant:
		move.l	a0,-(sp)
		
		move.l	struc_pix_4+gpix_ptr,d0
		beq	.fin
		
		move.l	d0,a0
		move.l	pix_next(a0),struc_pix_4+gpix_ptr
		
		move.w	#33,-(sp)
		move.l	form_main,-(sp)
		jsr	TAG_REDRAW
		lea	6(sp),sp
.fin		
		moveq	#0,d0
		
		move.l	(sp)+,a0
		rts


		********
pix_arriere:
		move.l	a0,-(sp)
		
		move.l	struc_pix_4+gpix_ptr,d0
		beq	.fin
		
		move.l	d0,a0
		move.l	pix_prev(a0),struc_pix_4+gpix_ptr
		
		move.w	#33,-(sp)
		move.l	form_main,-(sp)
		jsr	TAG_REDRAW
		lea	6(sp),sp
.fin		
		moveq	#0,d0
		
		move.l	(sp)+,a0
		rts

		********

*-------------------------------------------------------------------------*
		
		********
_MENU_MANAGER:
		rts
_RIGHT_CLICK:
		rts

		********

*-------------------------------------------------------------------------*

		********
GRUIK:
		link	a6,#0
		movem.l	a0/a1,-(sp)
		
		move.l	8(a6),a0
		move.l	4(a0),a1
		
		move.b	#G_PIX,ob_type+1(a1)
		lea	ob_spec(a1),a0
		move.l	a0,pix_spec
		
		movem.l	(sp)+,a0/a1
		unlk	a6
		rts
		
		********
		
cherche_chaine_curpath:
		
		link	a6,#0
		movem.l	a0/a1,-(sp)
		
		move.l	8(a6),a0
		move.l	4(a0),a0
		move.l	ob_spec(a0),a0
		
		move.l	te_ptext(a0),sptr_curpath
		
		move.w	#13-9,te_font(a0)
		
		movem.l	(sp)+,a0/a1
		unlk	a6
		rts
		
		********

cherche_frame_1:
		link	a6,#0
		movem.l	a0/a1,-(sp)
		
		move.l	8(a6),a0
		move.l	4(a0),a1
		
		move.w	8(a0),index_frame_1
		
		lea	struc_frame_1,a0
		move.l	a0,ob_spec(a1)
		
		clr.l	_gbo_tree(a0)
		clr.w	_gbo_first(a0)
		move.w	#16,_gbo_depth(a0)
		
		move.b	#G_BOUNDING,ob_type+1(a1)
		
		move.w	ob_w(a1),dir_w
		move.w	ob_h(a1),dir_h
		
		movem.l	(sp)+,a0/a1
		unlk	a6
		rts
		
		********
cherche_frame_2:
		link	a6,#0
		movem.l	a0/a1,-(sp)
		
		move.l	8(a6),a0
		move.l	4(a0),a1
		
		move.w	8(a0),index_frame_2
		
		lea	struc_frame_2,a0
		move.l	a0,ob_spec(a1)
		
		clr.l	_gbo_tree(a0)
		clr.w	_gbo_first(a0)
		move.w	#16,_gbo_depth(a0)
		
		move.b	#G_BOUNDING,ob_type+1(a1)
		
		movem.l	(sp)+,a0/a1
		unlk	a6
		rts
		
		********

cherche_pix_4:
		link	a6,#0
		movem.l	a0-a2,-(sp)
		
		move.l	8(a6),a0
		move.l	4(a0),a1
		
		
		
		lea	struc_pix_4,a2
		move.l	a2,ob_spec(a1)
		
		move.b	#G_PIX,ob_type+1(a1)
		
		movem.l	(sp)+,a0-a2
		unlk	a6
		rts
		
		********
		BSS
		********

struc_frame_1	ds.w	4
struc_frame_2	ds.w	4
index_frame_1	ds.W	1
index_frame_2	ds.W	1

dir_w		ds.w	1
dir_h		ds.w	1
directory_spec	ds.b	8

ZeGpix		ds.l	8

		********
		DATA
		********
		
		; pointeurs sur les structures
		; bitblk des images pour les objets
		; jointures de l'arborescence
		
bitblk_a		dc.l	0
bitblk_b		dc.l	0
bitblk_c		dc.l	0
iconblk_a		dc.l	0
		
		********
		TEXT
		********
cherche_img_a
		link	a6,#0
		movem.l	a0/a1,-(sp)
		
		move.l	8(a6),a0
		move.l	4(a0),a1
		
		move.l	ob_spec(a1),bitblk_a
		
		movem.l	(sp)+,a0/a1
		unlk	a6
		rts
		
		********
cherche_img_b
		link	a6,#0
		movem.l	a0/a1,-(sp)
		
		move.l	8(a6),a0
		move.l	4(a0),a1
		
		move.l	ob_spec(a1),bitblk_b
		
		movem.l	(sp)+,a0/a1
		unlk	a6
		rts
		
		********
cherche_img_c
		link	a6,#0
		movem.l	a0/a1,-(sp)
		
		move.l	8(a6),a0
		move.l	4(a0),a1
		
		move.l	ob_spec(a1),bitblk_c
		
		movem.l	(sp)+,a0/a1
		unlk	a6
		rts
		
		********
cherche_icone_a
		link	a6,#0
		movem.l	a0/a1,-(sp)
		
		move.l	8(a6),a0
		move.l	4(a0),a1
		
		move.l	ob_spec(a1),iconblk_a
		
		movem.l	(sp)+,a0/a1
		unlk	a6
		rts
		
		********
		
*-------------------------------------------------------------------------*
		
		****
		TEXT
		****
		
		; routine par d‚faut
		; pour ‚viter de gauffrer pendant les tests :-))
Rien:
		rts		
		
		********
		
*-------------------------------------------------------------------------*

		********
		
bleu		equ	4
jaune		equ	6
noir		equ	1
rouge		equ	2

text_width	equ	8
text_height	equ	8
		
		********
build_directory:
		movem.l	d0-a6,-(sp)
		
		move.l	FileInfoBuffer,-(sp)
		gem	mfree
		
		move.l	directory_tree,-(sp)
		gem	mfree
		
		****
		
		move.w	cur_drive,-(sp)
		move.l	#15000,-(sp)
		
		jsr	make_arbre
		
		move.l	d0,FileInfoBuffer
		
		****
		
		*move.l	FileInfoBuffer,-(sp)
		*jsr	ascii_dump
		
		
		move.l	FileInfoBuffer,-(sp)
		move.l	#15000,-(sp)
		pea	struc_pix_2
		jsr	aes_directory
		
		move.l	d0,directory_tree
		move.l	d0,struc_frame_1
		
		****
		
		movem.l	(sp)+,d0-a6
		rts
		
		********
		********
		
		; construction d'un arbre aes
		; representant l'arbre des dossiers
		; de la structure "fo" en parametre.
		
		rsset	8
_adi_pix		rs.l	1	; pointeur g_pix de fond
_adi_num		rs.l	1	; nombre de repertoires
_adi_fo		rs.l	1	; pointeur sur l'arbre de fichiers
		
		rsset	-8
_adi_tree		rs.l	1	; pointeur sur l'arbre aes allou‚
_adi_ted		rs.l	1	; pointeur sur le bloc de ted-info allou‚
		
		****
aes_directory:
		link	a6,#-8
		movem.l	d1-d7/a0-a5,-(sp)
		
		
		move.l	_adi_num(a6),d7
		addq.l	#2,d7
		
		moveq	#24,d6
		moveq	#28,d5
		
		mulu.l	d7,d6
		mulu.l	d7,d5
		
		move.l	d6,d0
		add.l	d5,d0
		
		move.l	d0,-(sp)
		gem	malloc
		move.l	d0,_adi_tree(a6)
		
		add.l	d6,d0
		move.l	d0,_adi_ted(a6)
		
		****
		
		; a0= pointeur racine
		; a1= pointeur objet aes courant
		
		move.l	_adi_tree(a6),a0
		lea	2*24(a0),a1
		
		; a2= pointeur "fo" courant
		; a3= pointeur ted_info courant
		
		move.l	_adi_fo(a6),a2
		move.l	d0,a3
		
		; d7= index ob_next courant
		; d6= x courant
		; d5= y courant
		
		moveq	#3,d7
		moveq	#0,d6
		moveq	#4,d5
		
		; numero de la generation en d4,
		; mappe des trous en d3
		
		moveq	#0,d4
		moveq	#0,d3
		
		; construction recursive en partant de la racine
		
		bsr	next_level
		
		****
		
		move.w	d5,directory_height
		
		subq.w	#1,d7
		move.w	#1,-24(a1)
		or.w	#LASTOB,-24+ob_flags(a1)
		
		****
		
		; construction structure g_bounded derriere les ted-info
		
		cmp.w	dir_h,d5
		bgt	.okw
		move.w	dir_h,d5
.okw
		
		clr.w	_gbd_flags(a3)
		move.l	tree_main,_gbd_tree(a3)
		move.w	index_frame_1,_gbd_index(a3)
		
		move.w	#-1,(a0)+
		move.w	#1,(a0)+
		move.w	#1,(a0)+
		move.w	#G_BOUNDED,(a0)+
		move.w	#0,(a0)+
		move.w	#0,(a0)+
		
		move.l	a3,(a0)+
		
		move.w	#0,(a0)+
		move.w	#0,(a0)+
		
		move.w	dir_w,(a0)+
		move.w	d5,(a0)+
		
		****
		
		move.w	#0,(a0)+
		move.w	#2,(a0)+
		move.w	d7,(a0)+
		move.w	#G_PIX,(a0)+
		move.w	#0,(a0)+
		move.w	#0,(a0)+
		
		move.l	_adi_pix(a6),(a0)+
		
		move.w	#0,(a0)+
		move.w	#0,(a0)+
		
		move.w	dir_w,(a0)+
		move.w	d5,(a0)+
		
		****
.eok
		move.l	_adi_tree(a6),d0
				
		movem.l	(sp)+,d1-d7/a0-a5
		unlk	a6
		rtd	#12
		
		********
		********
		
		; noyau recursif
		
		****
next_level
		movem.l	d3-d4/a2,-(sp)
		
		addq	#1,d4
		
		bsr	is_last
		
		add	d3,d3
		add	d0,d3

		add.w	#16,d6
		
		move.l	fo_child(a2),a2
		tst.l	a2
		beq.s	.end_level
.next_obj		
		cmp.w	#$10,fo_attr(a2)
		beq.s	.is_dir
.end_obj		
		move.l	fo_next(a2),a2
		tst.l	a2
		bne.s	.next_obj
.end_level
		sub.w	#16,d6
.void		
		movem.l	(sp)+,d3-d4/a2
		rts
		
		********
		
		; cr‚er objet(s) pour le repertoire courant
.is_dir		
		****
		
		; inits de la p'tite icone
		
		move.w	d7,ob_next(a1)
		move.w	#G_CICON,ob_type(a1)
		
		moveq	#-1,d0
		move.w	d0,ob_head(a1)
		move.w	d0,ob_tail(a1)
		
		move.l	iconblk_a,ob_spec(a1)
		
		move.w	#0,ob_flags(a1)
		move.w	#0,ob_state(a1)
		
		move.w	d6,ob_x(a1)
		move.w	d5,ob_y(a1)
		
		move.w	#16,ob_w(a1)
		move.w	#16,ob_h(a1)
		
		lea	24(a1),a1
		addq.w	#1,d7
		
		****
		
		; inits de la ted-info pour l'afficheur
		; du nom du sous-directory
		
		move.l	a2,te_ptext(a3)
		add.l	#fo_name,te_ptext(a3)
		
		move.w	#noir<<12+bleu<<8,te_color(a3)
		move.l	#fs_valid,te_pvalid(a3)
		move.w	#(13-9),te_font(a3)
		move.l	#fs_tmplt,te_ptmplt(a3)
		move.w	#12,te_tmplen(a3)
		clr.w	te_just(a3)
		clr.w	te_resvd1(a3)
		clr.w	te_resvd2(a3)
		clr.w	te_thickness(a3)
		
		move.l	a3,ob_spec(a1)
		lea	28(a3),a3
		
		; inits de l'objet repertoire lui-meme
		
		move.w	d7,ob_next(a1)
		move.w	#7<<8+G_BOXTEXT,ob_type(a1)
		
		moveq	#-1,d0
		move.w	d0,ob_head(a1)
		move.w	d0,ob_tail(a1)
		
		move.w	#%01<<9+EXIT+SELECTABLE,ob_flags(a1)
		move.w	#0<<8,ob_state(a1)
		
		move.w	d6,ob_x(a1)
		add	#16,ob_x(a1)
		
		move.w	d5,ob_y(a1)
		addq.w	#4,ob_y(a1)
		
		move.w	#(12*text_width),ob_w(a1)
		move.w	#16-8,ob_h(a1)
		
		lea	24(a1),a1
		addq.w	#1,d7
		
		****
		
		; puis il faut une jointure,
		; avec 2 liens si le repertoire
		; n'est pas le dernier.
		
		move.w	d7,ob_next(a1)
		move.w	#G_IMAGE,ob_type(a1)
		
		moveq	#-1,d0
		move.w	d0,ob_head(a1)
		move.w	d0,ob_tail(a1)
		
		clr.w	ob_flags(a1)
		clr.w	ob_state(a1)
		
		moveq	#16,d0
		
		move.w	d6,ob_x(a1)
		sub.w	d0,ob_x(a1)
		
		move.w	d5,ob_y(a1)
		
		move.w	d0,ob_w(a1)
		move.w	d0,ob_h(a1)
		
		
		; choix de la jointure double ou simple
		
		move.l	bitblk_b,ob_spec(a1)
		
		bsr	is_last
		
		tst.l	d0
		bne.s	.double
		
		move.l	bitblk_c,ob_spec(a1)
.double		
		lea	24(a1),a1
		addq.w	#1,d7
		
		****
		
		; il faut des barres verticales sauf aux
		; endroits situ‚s au dessous de dossiers qui
		; sont les derniers de leur generation,
		; (mappe des trous en d3).
		
		move.w	d3,d1
		
		move.w	d4,d0
		subq.w	#1,d0
		beq	.fin
		
		moveq	#-32,d2
		add.w	d6,d2
.vbar		
		lsr.w	#1,d1
		bcc	.trou
		
		move.l	bitblk_a,ob_spec(a1)
		
		move.w	d7,ob_next(a1)
		move.w	#G_IMAGE,ob_type(a1)
		
		move.w	#-1,ob_head(a1)
		move.w	#-1,ob_tail(a1)
		
		clr.w	ob_flags(a1)
		clr.w	ob_state(a1)
		
		move.w	d2,ob_x(a1)
		
		move.w	d5,ob_y(a1)
		move.w	#16,ob_w(a1)
		move.w	#16,ob_h(a1)
		
		lea	24(a1),a1
		addq.w	#1,d7
.trou
		sub	#16,d2
		subq.w	#1,d0
		bgt	.vbar
.fin		
		****
		
		add.w	#16,d5
		
		bsr	next_level
		
		bra	.end_obj
		
		********
		********
		
		; fonction qui renvoie en d0:
		; 0 si le directory en parametre
		; est le dernier de sa generation,
		; ou 1 sinon.
is_last		
		move.l	a2,-(sp)
.next		
		move.l	fo_next(a2),d0
		beq.s	.yes
		move.l	d0,a2
		
		cmp.w	#$10,fo_attr(a2)
		bne.s	.next
.no
		moveq	#1,d0
		move.l	(sp)+,a2
		rts
.yes		
		moveq	#0,d0
		move.l	(sp)+,a2
		rts
		
		********
		DATA
		********

fs_mask		dc.b	"*.*",0
		even
fs_valid		dc.b	"xxxxxxxxxxxxx",0
		even
fs_tmplt		dc.b	"_____________",0
		even

cur_drive		dc.w	"C"
		
		********
		BSS
		********

directory_height	ds.w	1

current_node	ds.l	1
sptr_curpath	ds.l	1

		********

****************************************************************

		****
		TEXT
		****
set_path:
		movem.l	a0-a1,-(sp)
		
		move.l	sptr_curpath,a1
		
		; recuperons le pointeur te_ptext
		; qui pointe aussi le debut de la  structure 'fo'
		
		move.l	_EXO_OBPTR(a6),a0
		move.l	([ob_spec,a0],te_ptext),a0
		
		lea	-fo_name(a0),a0
		move.l	a0,current_node
		
		; remontons jusqu'a la racine
		; en semant des petits cailloux sur
		; notre chemin
		
		clr.l	-(sp)
.back		
		move.l	a0,-(sp)
		
		move.l	fo_parent(a0),a0
		tst.l	a0
		bne.s	.back
		
		; on a plus qu'a suivre les petits
		; cailloux en copiant la chaine … chaque
		; fois...sans oublier les slash bien sur
.next		
		move.l	(sp)+,a0
		tst.l	a0
		beq	.bottom
		
		lea	fo_name(a0),a0
.copy		
		move.b	(a0)+,(a1)+
		bne.s	.copy
		
		move.b	#"\",-1(a1)
		bra.s	.next
.bottom
		clr.w	(a1)
		
		****
		
		move.l	current_node,-(sp)
		pea	disp_text
		
		bsr	gen_arbre_disp
		
		****
		
		move.w	#8,-(sp)
		move.l	form_main,-(sp)
		jsr	TAG_REDRAW
		lea	6(sp),sp
		
		move.w	#3,-(sp)
		move.l	form_main,-(sp)
		jsr	TAG_REDRAW
		lea	6(sp),sp
		
		****
		
		movem.l	(sp)+,a0-a1
		moveq	#0,d0
		rts

		********

*-------------------------------------------------------------------------*

		********
set_drive
		move.l	a0,-(sp)
		
		move.l	_EXO_OBPTR(a6),a0
		move.l	([ob_spec,a0],te_ptext),a0

		moveq	#0,d0
		move.b	(a0),d0
		
		move.w	d0,cur_drive
		
		****
		
		JSR	BUILD_DIRECTORY
		
		move.w	#2,-(sp)
		move.l	form_main,-(sp)
		jsr	TAG_REDRAW
		lea	6(sp),sp
		
		****
		
		moveq	#$01,d0
		move.l	(sp)+,a0
		rts
		
		
		********

*-------------------------------------------------------------------------*

		********
		
		; fonction de comptage des fichiers
		; contenus dans le dossier dont la structure
		; est point‚e par le parametre sur la pile
how_many_files
		moveq	#0,d0
		move.l	4(sp),a0
		
		tst.w	fo_kids(a0)
		beq.s	.fin
		
		move.l	fo_child(a0),a0
		tst.l	a0
		beq.s	.fin
.yop		
		cmp.w	#$10,fo_attr(a0)
		beq	.no_inc
		
		addq.l	#1,d0
.no_inc
		move.l	fo_next(a0),a0
		tst.l	a0
		bne.s	.yop
		
.fin
		rtd	#4
		
		********
		
*-------------------------------------------------------------------------*
		
		********
		
		; g‚n‚ration de table contenant la
		; liste des pointeurs sur les descripteurs
		; de fichiers contenus dans le dossier
		; r‚f‚renc‚.
		; retourne l'adresse de la table allou‚e en d0
		; (le premier long de la table est le nombre d'elements)
gen_table_tri
		link	a6,#0
		movem.l	a0/a4-a5,-(sp)
		
		move.l	8(a6),a5
		
		move.l	a5,-(sp)
		bsr	how_many_files
		move.l	d0,d7
		
		beq	.fin
		
		addq.l	#1,d0
		lsl.l	#2,d0
		
		move.l	d0,-(sp)
		gem	malloc
		
		move.l	d0,a4
		
		****
		
		move.l	d7,(a4)+
		
		; copie pointeurs en liste
		
		move.l	fo_child(a5),a5
.yop		
		cmp.w	#$10,fo_attr(a5)
		beq	.no_list
		
		move.l	a5,(a4)+
.no_list
		move.l	fo_next(a5),a5
		tst.l	a5
		bne.s	.yop

		
		****
.fin		
		movem.l	(sp)+,a0/a4-a5
		unlk	a6
		rtd	#4
		
		********

*-------------------------------------------------------------------------*
		
		********
		
		; construction de liste de fichiers
		
		; parametres:
		; pointeur descripteur du node,
		; pointeur sur routine userdef selon type d'affichage.
		
		; retour:
		; d0 = adresse bloc memoire allou‚
		; contenant l'arbre d'objets et la table d'usblk
		
		; structure bloc:
		; long: nombre d'elements presents
		; long: adresse arbre aes
		; long: adresse table des pointeurs indirects des objets

		****
gen_arbre_disp
		link	a6,#0
		movem.l	d1-a5,-(sp)
		
		move.l	8+4(a6),a4	; pointeur sur nodal
		
		****
		
		; nombre d'objets ?
		
		moveq	#0,d7
		move.w	fo_kids(a4),d7
		
		move.l	fo_child(a4),a4
		
		moveq	#12,d6
		
		; 24 octets par objet
		; (n+4) objets dans l'arbre...
		
		moveq	#24,d5
		move.l	d7,d0
		addq.l	#4,d0
		mulu.l	d0,d5
		
		; 2 pointeurs point‚s par objet
		
		moveq	#2*4,d4
		mulu.l	d7,d4
		
		; allocation memoire
		
		move.l	d5,d0
		add.l	d4,d0
		add.l	d6,d0
		
		move.l	d0,-(sp)
		gem	malloc
		
		move.l	d0,a3
		move.l	d0,a2
		
		move.l	d7,(a2)
		add.l	d6,a3
		move.l	a3,4(a2)
		add.l	d5,a3
		move.l	a3,8(a2)
		
		****
		
		move.l	4(a2),a0
		move.l	8(a2),a1
		
		; tout d'abord un g_bounded
		
		move.w	#-1,ob_next(a0)
		move.w	#1,ob_head(a0)
		move.w	#1,ob_tail(a0)
		move.w	#3<<8+G_BOUNDED,ob_type(a0)
		
		clr.w	ob_state(a0)
		clr.w	ob_flags(a0)
		
		clr.w	ob_x(a0)
		clr.w	ob_y(a0)
		
		move.w	#48*8,ob_w(a0)
		move.w	#1024,ob_h(a0)
		
		lea	24(a0),a0
		
		****
		
		; maintenant un objet racine
		; pour avoir un joli fond...
		
		move.w	#0,ob_next(a0)
		
		move.w	#2,ob_head(a0)
		move.w	#2,ob_tail(a0)
		
		move.w	#G_PIX,ob_type(a0)
		move.l	#struc_pix_3,ob_spec(a0)
		
		clr.w	ob_state(a0)
		clr.w	ob_flags(a0)
		
		clr.w	ob_x(a0)
		clr.w	ob_y(a0)
		
		move.w	#48*8,ob_w(a0)
		move.w	#1024,ob_h(a0)
		
		lea	24(a0),a0
		
		****
		
		move.l	d7,d3
		addq.l	#2,d3
		
		move.w	#1,ob_next(a0)
		
		move.w	#3,ob_head(a0)
		move.w	d3,ob_tail(a0)
		
		move.w	#G_TEXT,ob_type(a0)
		move.l	#la_ted_info,ob_spec(a0)
		
		clr.w	ob_state(a0)
		clr.w	ob_flags(a0)
		
		clr.w	ob_x(a0)
		clr.w	ob_y(a0)
		
		move.w	#48*8,ob_w(a0)
		move.w	#1024,ob_h(a0)
		
		lea	24(a0),a0
		
		****
		
		; ob_next courant en d3
		; pointeur base des usblk's en a1
		; y courant en d4
		
		moveq	#4,d3
		moveq	#0,d4
.hopla		
		move.w	d3,ob_next(a0)
		
		move.w	#-1,ob_head(a0)
		move.w	#-1,ob_tail(a0)
		
		move.w	#18<<8+G_STRING,ob_type(a0)
		
		move.w	#WHITEBACK,ob_state(a0)
		move.w	#INDIRECT+EXIT+SELECTABLE,ob_flags(a0)
		
		move.l	a1,ob_spec(a0)
		lea	fo_name(a4),a5
		move.l	a5,(a1)+
		move.l	a4,(a1)+
		
		clr.w	ob_x(a0)
		move.w	d4,ob_y(a0)
		
		move.w	#48*8,ob_w(a0)
		move.w	#8,ob_h(a0)
		
		add.w	#8,d4
		
		lea	24(a0),a0
		addq	#1,d3
		
		move.l	fo_next(a4),a4
		tst.l	a4
		bne.s	.hopla
		
		
		****
		
		move.w	#2,-24+ob_next(a0)
		or.w	#LASTOB,-24+ob_flags(a0)
		
		; completer le g_bounded
		
		clr.w	_gbd_flags(a0)
		move.l	tree_main,_gbd_tree(a0)
		move.w	index_frame_2,_gbd_index(a0)
		
		move.l	4(a2),a1
		move.l	a0,ob_spec(a1)
		move.l	a1,struc_frame_2
		
		****
		
		move.l	4(a2),d0
		movem.l	(sp)+,d1-a5
		unlk	a6
		rtd	#8
		
		********
		BSS
		********
		
		; pointeurs de tables pour le tri
		
table_tri		ds.l	1
table_spec	ds.l	1
table_objets	ds.l	1
table_usblk	ds.l	1
		
		********
		DATA
		********
la_ted_info		
		dcb.l	3,0
		dc.w	13-9		; fonte 9 pts
		dc.w	0		; junk1
		dc.w	0		; justif gauche
		dc.w	JAUNE<<8+7<<4	; couleurs
		dc.w	0		; junk2
		dc.w	0		; thickness
		dc.w	0		; txtlen
		dc.w	0		; tmplen

		********

*-------------------------------------------------------------------------*

		****
		TEXT
		****
		
		; tri_alpha (liste,spec)
		
		; tri la liste triable en parametre
		; suivant l'ordre alphabetique croissant
		; en triant dans le meme ordre la table
		; d'ob_spec indirects en parametre
		
tri_alpha
		link	a6,#0
		movem.l	d0-d1/a2-a5,-(sp)
		
		move.l	8+4(a6),a5
		move.l	8(a6),a4
		
		****
		
		move.l	(a4)+,d7
.yop_1		
			move.l	d7,d6
			move.l	a5,a3
			move.l	a4,a2
.yop_2		
				move.l	(a2),d0
				move.l	4(a2),d1
		
				cmp.l	d0,d1
				bgt.s	.ok
		
				; swappe les pointeurs
				
				move.l	d1,(a2)
				move.l	d0,4(a2)
				
				; swappe les ob_specs qui vont avec
				
				move.l	4(a3),d0
				move.l	(a3),4(a3)
				move.l	d0,(a3)
.ok		
			addq.l	#4,a2
			addq.l	#4,a3
			
			subq.l	#1,d6
			bgt.s	.yop_2
		
		subq.l	#1,d7
		bgt.s	.yop_1
		
		****
.fin		
		movem.l	(sp)+,d0-d1/a2-a5
		unlk	a6
		rtd	#8


		********

*-------------------------------------------------------------------------*

		********

		; userdef pour l'affichage suivant
		; les differents types d'apparence.
		
		********
disp_text:
		link	a6,#0
		movem.l	d1-a5,-(sp)
		
		; illegal
		
		move.l	8(a6),a5
		
		movem.w	pb_xc(a5),d1-d4
		add	d1,d3
		sub	#1,d3
		add	d2,d4
		sub	#1,d4
		
		move	#1,_V_CONTROL+_V_SINTIN
		move	#2,_V_CONTROL+_V_SPTSIN
		
		movem	d1-d4,_V_PTSIN
		move	#1,_V_INTIN
		
		VDI	VS_CLIP
		
		****
		
		move.l	pb_parm(a5),a0
		lea	_V_INTIN,a2
		
		; nom
		
		lea	fo_name(a0),a1
		lea	13*2(a2),a3
		
		moveq	#0,d0
		moveq	#12-1,d1
.nam		
		move.b	(a1)+,d0
		beq.s	.hop
		
		move.w	d0,(a2)+
		dbf	d1,.nam
		
		; espaces
.hop
		move.w	#" ",(a2)+
		cmp.l	a2,a3
		bgt.s	.hop
		
		; taille
		
		moveq	#8-1,d1
		move.l	fo_len(a0),d0
		
		lea	8*2(a2),a0
		clr.w	(a0)
.yo		
		divul.l	#10,d2:d0
		
		add.w	#"0",d2
		move.w	d2,-(a0)
		
		dbf	d1,.yo
		
		
		****
		
		move	#1,_V_CONTROL+_V_SPTSIN
		move	#22,_V_CONTROL+_V_SINTIN
		
		move.w	pb_x(a5),_V_PTSIN
		move.w	pb_y(a5),_V_PTSIN+2
		
		VDI	V_GTEXT
		
		****
		
		moveq	#0,d0
		
		movem.l	(sp)+,d1-a5
		unlk	a6
		rts

		********

*-------------------------------------------------------------------------*
		
		********
info_up
		add	#16,directory_tree+ob_y
		bra	scroll_redraw
info_down
		sub	#16,directory_tree+ob_y
		bra	scroll_redraw
scroll_redraw
		move	#13,-(sp)
		move.l	form_main,-(sp)
		jsr	TAG_REDRAW
		lea	6(sp),sp
		
		rts
		
		********
		
*-------------------------------------------------------------------------*

		********
		
		; ceci est un slider il recoit donc sur la
		; pile un pointeur sur une structure _MOV_PARAMS
		
		; WORD: x minimum
		; WORD: y minimum
		; WORD: x maximum
		; WORD: y maximum
		
		; WORD: x courant
		; WORD: y courant
		
		; WORD: d‚placement x souris
		; WORD: d‚placement y souris
		
		; WORD: d‚placement x effectif
		; WORD: d‚placement y effectif
		
		* _MOV_XMIN
		* _MOV_YMIN
		* _MOV_XMAX
		* _MOV_YMAX
		* _MOV_CURX
		* _MOV_CURY
		* _MOV_HMOM
		* _MOV_VMOM
		* _MOV_HMOV
		* _MOV_VMOV

		********
		
_SLIDE_PARAMS	set	8
		
		********
fsel_slide
		link	a6,#0
		movem.l	d0-a5,-(sp)
		
		move.l	_SLIDE_PARAMS(a6),a5
		
		; le slider a-t-il boug‚ en y ?
		
		move	_MOV_VMOV(a5),d0
		beq.s	.no_move
		
		; nouvelle position relative ?
		
		clr.l	d1
		clr.l	d2
		
		move	_MOV_YMAX(a5),d1
		sub	_MOV_YMIN(a5),d1
		
		move	_MOV_CURY(a5),d2
		sub	_MOV_YMIN(a5),d2
		
		move	dir_h,d3
		sub	directory_height,d3
		bpl	.no_move
		
		muls	d2,d3
		divs	d1,d3
		
		; application
.ok
		
		move	([directory_tree],ob_y),d4
		sub	d4,d3
		
		move.l	form_main,-(sp)
		clr.l	-(sp)
		move.w	index_frame_1,-(sp)
				
		move.w	#0,-(sp)	; deplacement x
		move.w	d3,-(sp)	; deplacement y
		
		jsr	_FORM_SHIFT
		
		********
		
		;move	#5,-(sp)
		;clr.l	-(sp)
		;clr.l	-(sp)
		;jsr	TAG_REDRAW
		;lea	10(sp),sp
.no_move		
		movem.l	(sp)+,d0-a5
		unlk	a6
		rts

		********

*-------------------------------------------------------------------------*
		
		********
		
		; gestion d‚placement d'image
move_pix:
		link	a6,#0
		movem.l	d0-a5,-(sp)
		
		move.l	_SLIDE_PARAMS(a6),a5
		
		clr.w	_mov_hmov(a5)
		clr.w	_mov_vmov(a5)
		
		
		move.l	mov_ob_ptr(a5),a4
		
		move.l	ob_spec(a4),a3
		move.l	gpix_ptr(a3),a3
		
		move.l	pix_w(a3),d0
		move.l	pix_h(a3),d1
		
		move.w	_mov_hmom(a5),d2
		move.w	_mov_vmom(a5),d3
		
		sub.l	d2,pix_relx(a3)
		ble.s	.okx
		clr.l	pix_relx(a3)
.okx
		sub.l	d3,pix_rely(a3)
		ble.s	.oky
		clr.l	pix_rely(a3)
.oky
		
		
		
		; redraw
		
		move	#33,-(sp)
		move.l	form_main,-(sp)
		jsr	TAG_REDRAW
		lea	6(sp),sp
		
		movem.l	(sp)+,d0-a5
		unlk	a6
		rts
		
		
		********
		
*-------------------------------------------------------------------------*
		
		********
		
		; redimensionnement d'une fenetre type image
resize_pix:
		link	a6,#0
		movem.l	d0-a5,-(sp)
		
		
		move.l	_SLIDE_PARAMS(a6),a5
		
		clr.w	_mov_hmov(a5)
		clr.w	_mov_vmov(a5)
		
		move.w	_mov_hmom(a5),d2
		move.w	_mov_vmom(a5),d3
		
		; redimensionnement fenetre AES
		
		move.l	mov_form_ptr(a5),a4
		
		lea	_A_INTIN,a3
		move.w	_FRM_HANDLE(a4),(a3)+
		move.w	#WF_CURRXYWH,(a3)+
		
		AES	WIND_GET
		
		lea	_A_INTIN,a3
		lea	_A_INTOUT+2,a2
		
		move.w	_FRM_HANDLE(a4),(a3)+
		move.w	#WF_CURRXYWH,(a3)+
		move.w	(a2)+,(a3)+
		move.w	(a2)+,(a3)+
		move.w	(a2)+,(a3)+
		move.w	(a2)+,(a3)+
		
		sub	d2,-4(a3)
		
		AES	WIND_SET
		
		****
		
		
		****
		
		movem.l	(sp)+,d0-a5
		unlk	a6
		rts
		
		
		********
		
*-------------------------------------------------------------------------*
		
		********
SelectFile:
		movem.l	d1-a5,-(sp)
		
		lea	chemin_pix_4,a1
		
		; recuperons le pointeur parm
		; qui pointe le debut de la  structure 'fo'
		
		move.l	_EXO_OBPTR(a6),a0
		move.l	ob_spec(a0),a0
		move.l	4(a0),a0
		
		; remontons jusqu'a la racine
		; en semant des petits cailloux sur
		; notre chemin
		
		clr.l	-(sp)
.back		
		move.l	a0,-(sp)
		move.l	fo_parent(a0),a0
		
		tst.l	a0
		bne.s	.back
		
		; on a plus qu'a suivre les petits
		; cailloux en copiant la chaine … chaque
		; fois...sans oublier les slash bien sur
.next		
		move.l	(sp)+,a0
		tst.l	a0
		beq	.bottom
		
		lea	fo_name(a0),a0
.copy		
		move.b	(a0)+,(a1)+
		bne.s	.copy
		
		move.b	#"\",-1(a1)
		bra.s	.next
.bottom
		clr.w	-1(a1)
		
		****
		
		pea	struc_pix_4
		jsr	pix_free
		lea	4(sp),sp
		
		****
		
		lea	struc_pix_4,a2
		
		move.l	#chemin_pix_4,gpix_path(a2)
		clr.l	gpix_ptr(a2)
		clr.l	gpix_list(a2)
		move.l	#%01,gpix_flags(a2)
		clr.l	gpix_x(a2)
		clr.l	gpix_y(a2)
		
		****
		
		move.w	#33,-(sp)
		move.l	form_main,-(sp)
		jsr	TAG_REDRAW
		lea	6(sp),sp
		
		
		moveq	#$01,d0
		
		movem.l	(sp)+,d1-a5
		rts
		
		********
		
*-------------------------------------------------------------------------*
		
		***************
drive_select:
		link	a6,#0
		movem.l	d0-a5,-(sp)
		
		;move.l	8(a6),a5
		;move.l	8(a5),a4
		;
		;move.l	OB_SPEC(a4),a3
		;move.l	TE_PTEXT(a3),a3
		;
		;moveq	#0,d0
		;move.b	(a3),d0
		;sub.b	#"A",d0
		
		
		move	#2,d0
		
		move.w	d0,-(sp)
		GEM	DSETDRV
		
		
		***************
		
		bsr	build_directory
		
		***************
		
		move	#5,-(sp)
		move.l	form_main,-(sp)
		jsr	TAG_REDRAW
		lea	6(sp),sp
.Fin
		movem.l	(sp)+,d0-a5
		unlk	a6
		rts

		***************

********************************************************************
		
		****
		
		; lib‚ration de structure PIX !
		
		rsset	8
_pif_adr		rs.l	1	ptr structure … lib‚rer

		****
pix_free:		
		link	a6,#0
		movem.l	d1-a5,-(sp)
		
		move.l	_pif_adr(a6),a4
		move.l	GPIX_LIST(a4),d7
		beq.s	.ram_ok
		
		clr.l	GPIX_LIST(a4)
		clr.l	GPIX_PTR(a4)
		move.l	d7,a5
.free		
		move.l	PIX_PALETTE(a5),d5
		beq.s	.nopal
		cmp.l	#"!SYS",d5
		beq.s	.nopal
		
		move.l	d5,-(sp)
		GEM	MFREE
.nopal		
		move.l	PIX_NEXT(a5),d5
		
		move.l	PIX_addr(a5),d4
		beq	.nodata
		
		lea	PIX_SIZEOF(a5),a3
		cmp.l	a3,d4
		beq	.nodata
		
		move.l	d4,-(sp)
		GEM	MFREE
.nodata		
		move.l	a5,-(sp)
		GEM	MFREE
		
		tst.l	d5
		beq.s	.ram_ok
		cmp.l	d5,d7
		beq.s	.ram_ok
		cmp.l	d5,a5
		beq.s	.ram_ok
		
		move.l	d5,a5
		bra.s	.free
.ram_ok		
		moveq	#0,d0
		
		movem.l	(sp)+,d1-a5
		unlk	a6
		rts
		
		****
		
********************************************************************

		**************
MASTER_PART:
		movem.l	d0-a6,-(sp)
		
		ifeq	1
		
		; chercher le 1e objet select‚
		
		lea	directory_tree+1*24,a0
		move	OB_TAIL(a0),d0
		sub	OB_HEAD(a0),d0
		
		lea	directory_tree+2*24,a1
		
		lea	liste_tedinfos,a4
.yopli		
		btst	#0,OB_STATE+1(a1)
		bne.s	.okok
		
		add	#24,a1
		dbf	d0,.yopli
		bra	import_error
		
		**************
.okok		
		move.l	OB_SPEC(a1),a2
		move.l	TE_PTEXT(a2),a2
		
		
		; copie du nom dans fsel_name
		
		move.l	a2,a3
		lea	fsel_name,a4
.erjuy
		move.b	(a3)+,(a4)+
		bne.s	.erjuy
		
		; d‚termination du chemin
		; si _mfs_up nul c'est le root local
		
		move.l	FileInfoBuffer,a1
		lea	260(a1),a1
		lea	char_buffer+100,a0
		clr.b	-(a0)
.loopup		
		move.b	#"\",-(a0)
		
		moveq	#0,d0
		move.w	_MFS_UP(a2),d0
		bmi	.locroot
		
		; sinon continue le chemin
		
		lsl.l	#5,d0
		lea	(a1,d0.l),a2
		
		lea	12(a2),a4
		clr.b	(a4)
.chz		
		tst.b	-(a4)
		beq.s	.chz
		addq	#1,a4
.cop		
		move.b	-(a4),-(a0)
		
		cmp.l	a2,a4
		bgt.s	.cop
		
		bra.s	.loopup
.locroot
		lea	1(a0),a4
		lea	fsel_path,a0
		
		move.l	FileInfoBuffer,a1
		addq	#4,a1
.hoho		
		move.b	(a1)+,(a0)+
		bne.s	.hoho
		
		subq	#1,a0
.haha		
		move.b	(a4)+,(a0)+
		bne.s	.haha
		
		move.b	#"\",-1(a0)
		
		pea	fsel_path
		GEM	DSETPATH
		
		**************
		
		; allocation d'une fenetre image
		
		lea	windows,a5
.sfr		tst.l	(a5)+
		bne.s	.sfr
		lea	-4(a5),a5
		
		pea	512.w
		GEM	MALLOC
		move.l	d0,(a5)
		beq	.bug
		
		; copie arbre
		
		move.l	d0,a1
		lea	256(a1),a2
		move.l	pix_spec,a3
		move.l	a2,(a3)
		
		move.l	FormPicture,a0
		moveq	#64,d0
.copt		
		move.l	(a0)+,(a1)+
		subq.w	#1,d0
		bgt.s	.copt
		
		move.w	#3,_GPIX_MODE(a2)
		move.l	#fsel_name,_GPIX_LIST(a2)
		
		move.w	#%0001,_GPIX_FLAGS(a2)
		;move.w	#%1001,_GPIX_FLAGS(a2)
		
		move.w	#2,-(sp)
		clr.w	-(sp)
		clr.w	-(sp)
		clr.l	-(sp)
		move.l	(a5),-(sp)
		jsr	_FORM_OPEN
		
		bra	.job_done
		
		**************
		
		; lib‚ration de la m‚moire pr‚c‚dente !
		
		lea	ZeGpix,a4
		move.l	_GPIX_LIST(a4),d7
		beq.s	.ram_ok
		
		clr.l	_GPIX_LIST(a4)
		clr.l	_GPIX_PTR(a4)
		move.l	d7,a5
.free		
		move.l	_PIX_PALETTE(a5),d5
		beq.s	.nopal
		cmp.l	#"!SYS",d5
		beq.s	.nopal
		
		move.l	d5,-(sp)
		GEM	MFREE
.nopal		
		move.l	_PIX_NEXT(a5),d5
		
		move.l	_PIX_MFDB+mfdb_addr(a5),d4
		beq	.nodata
		
		lea	_PIX_SIZEOF(a5),a3
		cmp.l	a3,d4
		beq	.nodata
		
		move.l	d4,-(sp)
		GEM	MFREE
.nodata		
		move.l	a5,-(sp)
		GEM	MFREE
		
		tst.l	d5
		beq.s	.ram_ok
		cmp.l	d5,d7
		beq.s	.ram_ok
		cmp.l	d5,a5
		beq.s	.ram_ok
		
		move.l	d5,a5
		bra.s	.free
.ram_ok		
		**************
		
		move.l	free_ram,d7
		
		pea	-1
		GEM	MALLOC
		move.l	d0,free_ram
		
		sub.l	d0,d7
		beq	.tout
		
.tout		
		**************
		
		lea	ZeGpix,a0
		move.w	#3,_GPIX_MODE(a0)
		move.l	#fsel_name,_GPIX_LIST(a0)
		move.w	#%0001,_GPIX_FLAGS(a0)
		;move.w	#%1001,_GPIX_FLAGS(a0)
		
		
.job_done		sf	no_more_data
		sf	user_stop
		
		;move	#show_mouse,_A_INTIN
		;AES	GRAF_MOUSE
		
		move	#0,_A_INTIN
		movem.w	_DESK_XYWH,d0-d3
		movem.w	d0-d3,_A_INTIN+2
		movem.w	d0-d3,_A_INTIN+10
		AES	FORM_DIAL
		
		move	#3,_A_INTIN
		movem.w	_DESK_XYWH,d0-d3
		movem.w	d0-d3,_A_INTIN+2
		movem.w	d0-d3,_A_INTIN+10
		AES	FORM_DIAL
		
		endc
.bug		
		movem.l	(sp)+,d0-a6
		rts
		
		**************
import_error	
		
		; tracage des mallocs
		
		clr.l	-(sp)
.yobloc		
		pea	-1.w
		GEM	MALLOC
		
		move.l	d0,-(sp)
		beq.s	.last
		
		GEM	MALLOC
		move.l	d0,-(sp)
		
		bra.s	.yobloc
.last		
		tst.l	(sp)+
.yayay		
		tst.l	(sp)
		beq.s	.fin
		
		GEM	MFREE
		
		bra	.yayay
.fin
		tst.l	(sp)+
.okok				
		move	file_handle,-(sp)
		GEM	FCLOSE
		clr.w	file_handle
		
		move.l	data_bank,-(sp)
		GEM	MFREE
		clr.l	data_bank
		
		movem.l	(sp)+,d0-a6
		rts
		
		**************

*-------------------------------------------------------------------------*

		**************
FREE_MEMORY:	
		movem.l	d0-1/a0-1,-(sp)
		
		move.l	disk_buffer,-(sp)
		GEM	MFREE

		move.l	gif_workspace,-(sp)
		GEM	MFREE
		
		move.l	data_bank,-(sp)
		GEM	MFREE
		
		movem.l	(sp)+,d0-1/a0-1
		rts

		**************
		
*-------------------------------------------------------------------------*

		**************
APP_EXIT:
		movem.l	d0-1/a0-1,-(sp)
		
		bsr	FREE_MEMORY
		
		;pea	_REMOVE_VBL
		;XBIOS	SUPEXEC
		
		movem.l	(sp)+,d0-1/a0-1
		rts
		
		**************

*-------------------------------------------------------------------------*
		
		**************
		
		; sur la pile :
		; word=etat touches speciales
		; word=caractere entre
		
		**************
K_KEYBOARD:
		link	a6,#0
		movem.l	d0-a6,-(sp)
		
		
		move	8(a6),d0
		
		cmp	#$4400,d0	; touche f10
		bne	.ajoute
		
		**************
		
		; entr‚e valid‚e :-)
		; test de la chaine ...
		
		lea	.cheat_table,a1
.next_str		
		lea	.tampon,a0
		
		move.l	(a1)+,d0
		beq	.a_plus
		
		addq	#4,a1
		move.l	d0,a2
		
		; comparaison
.go_str		
		move.b	(a0)+,d1
		beq	.fin_str
		
		cmp.b	(a2)+,d1
		beq	.go_str
		bra	.next_str
.fin_str
		tst.b	(a2)
		bne	.next_str
		
		; chaine trouvee
		
		move.l	-4(a1),a3
		
		jsr	(a3)
		
.a_plus		
		lea	.tampon,a0
		move.l	a0,.tampon_ptr
		clr.l	(a0)+
		clr.l	(a0)+
		
		bra	.fin
		
		**************
.ajoute		
		move.l	.tampon_ptr,a0
		move.b	d0,(a0)+
		move.l	a0,.tampon_ptr
		clr.b	(a0)
.fin		
		
		movem.l	(sp)+,d0-a6
		unlk	a6
		rts
		
		**************
		even
		**************
		
		; la cheat table !!
		; 1) long: pointeur sur la chaine
		; 2) long: pointeur sur la routine

.cheat_table	
		dc.l	.shit_text_1
		dc.l	.shit_proc_1
		
		dc.l	.shit_text_2
		dc.l	.shit_proc_2
		
		dc.l	0
		dc.l	0

		**************

.tampon		ds.b	128
.tampon_ptr	dc.l	.tampon
		
		**************
.shit_text_1
		dc.b	"quit",0
.shit_text_2
		dc.b	"reset",0
		
				
		
		
		**************
		even
		**************
.shit_proc_1
		jmp	APP_CLOSE
		
		**************
.shit_proc_2
		pea	$e00030
		XBIOS	SUPEXEC
		
		**************

*-------------------------------------------------------------------------*
		
		**************
active_sylvestre
		move	#0,ResizeMethod
		rts

active_albert
		move	#1,ResizeMethod
		rts

		**************
		
*-------------------------------------------------------------------------*
		
		**************
ouvrir_parametres
		rts
		
		**************
		
*-------------------------------------------------------------------------*
		
		**************
fermer_parametres		
		move.l	FormParams,-(sp)
		jsr	form_close
		lea	4(sp),sp
		
		rts
		
		**************
		
*-------------------------------------------------------------------------*
		
		**************
fermer_info_1		
		move.l	FormInfo1Ptr,-(sp)
		JSR	FORM_CLOSE
		LEA	4(SP),SP
		
		rts
		
		**************
		
*-------------------------------------------------------------------------*
		
		**************
fermer_info_2		
		move.l	FormInfo2Ptr,-(sp)
		JSR	FORM_CLOSE
		LEA	4(SP),SP
		
		rts
		
		**************
		
*-------------------------------------------------------------------------*
		
		**************
fermer_info_3		
		move.l	FormInfo3Ptr,-(sp)
		JSR	FORM_CLOSE
		LEA	4(SP),SP
		
		rts
		
		**************
		
*-------------------------------------------------------------------------*
		
		**************
fermer_info_4		
		move.l	FormInfo4Ptr,-(sp)
		JSR	FORM_CLOSE
		LEA	4(SP),SP
		
		rts
		
		**************
		
*-------------------------------------------------------------------------*
		SECTION DATA
*-------------------------------------------------------------------------*

mode_de_tramage	dc.w	tramage

ResizeMethod	dc.w	1

user_counter	dc.l	5
real_counter	dc.l	5*200
		
		*---------------*
		* flags
		*---------------*

time_flag		dc.b	$00
keep_ratio	dc.b	$ff

nouvelle_methode	dc.b	$00

transfer		dc.b	0
flip_y		dc.b	0
flip_x		dc.b	0
chunky		dc.b	0
planar		dc.b	0
no_align		dc.b	0

flag_ttp		dc.b	0
flag_shrink	dc.b	0
flag_revert	dc.b	0
flag_colormap	dc.b	0
flag_256		dc.b	0
flag_auto		dc.b	0
flag_grey		dc.b	0
selected_file	dc.b	0

user_stop		dc.b	0
ok_header		dc.b	0
ok_import		dc.b	0
ok_data		dc.b	0
DSK_error		dc.b	0


		even		

		****
		****

		****
		
		; fenetres images
		
windows		dcb.l	32,0
		
		****

*-------------------------------------------------------------------------*
		
		*---------------*
		
_P_ACCTITLE	dc.b	"  CENTView¿ x.4.9  ",0

_P_RSCFILE:
		dc.b	"RUN.RSC",0
		
		EVEN
		
		*---------------*

import_failure	dc.b	"[3][ |"
		dc.b	" L'import a ‚chou‚ ... "
		dc.b	"][ ooh? ]",0
		even

bad_extension	dc.b	"[3][ |"
		dc.b	" Type de fichier non support‚ !"
		dc.b	"][ morbleu ]",0
		even

bad_memory	dc.b	"[3][ |"
		dc.b	" ProblŠme de m‚moire (!) "
		dc.b	"][ Bigre ]",0
		even

file_not_found	dc.b	"[3][ |"
		dc.b	" Ce fichier n'a pu etre ouvert "
		dc.b	"][ fichtre ]",0
		even

		*---------------*
fsel_title	dc.b	"Choisissez une image !",0
fsel_mask		dc.b	"*.*",0
		*---------------*
		
		*******
		
struc_pix_1	dcb.l	8,0
struc_pix_2	dcb.l	8,0
struc_pix_3	dcb.l	8,0
struc_pix_4	dcb.l	8,0

chemin_pix_1	dc.b	"D:\RUNE\DECO\CYBER.JPG",0
		even
chemin_pix_2	dc.b	"D:\RUNE\DECO\BGRND005.JPG",0
		even
chemin_pix_3	dc.b	"D:\RUNE\DECO\BG031.GIF",0
		even

test_dir		dc.b	"D:\",0
		even
		
		********
		
*-------------------------------------------------------------------------*

		*---------------*
		SECTION BSS
		*---------------*

FileInfoBuffer	ds.l	1
FileInfoTotal	ds.l	1

tree_main		ds.l	1
tree_deux		ds.l	1
tree_trois	ds.l	1
form_main		ds.l	1
form_deux		ds.l	1
form_trois	ds.l	1

tx_stack		ds.l	1

directory_tree	ds.l	1

char_buffer	ds.b	100
edit_buffer	ds.l	1
sys_plans		ds.w	1

vision_mfdb	ds.w	8
vision_box	ds.w	5
ze_blougou	ds.b	8

bitmap_buffer	ds.l	1
line_a		ds.l	1
command_line	ds.b	100

FormMainPtr	ds.l	1
FormPicture	ds.l	1

FormInfo1Ptr	ds.l	1
FormInfo2Ptr	ds.l	1
FormInfo3Ptr	ds.l	1
FormInfo4Ptr	ds.l	1
FormParams	ds.l	1
FormTest		ds.l	1


moniteur		ds.w	1
video_ptr		ds.l	1
info_jump		ds.l	1
PAL_depth		ds.w	1
PAL_number	ds.w	1
PAL_start		ds.w	1
pixel_size	ds.w	1
pixel_number	ds.l	1
X_origin		ds.w	1
Y_origin		ds.w	1
old_vbase		ds.l	1

keybd_status	ds.w	1
mouse_status	ds.w	1
mousex		ds.w	1
mousey		ds.w	1
mouse_cliks	ds.w	1
keyboard		ds.l	1

p_width16		ds.w	1
P_width		ds.w	1
P_height		ds.w	1
S_width		ds.w	1
S_height		ds.w	1

tc_order		ds.l	1

screen_ptr	ds.l	1
screen_size	ds.l	1
type_code		ds.b	1

alert_button	ds.w	1
disk_buffer	ds.l	1
file_size		ds.l	1
buffer_size	ds.l	1
bytes_loaded	ds.l	1
file_handle	ds.w	1
data_size		ds.l	1
data_bank		ds.l	1
dummy		ds.l	1
offset_now	ds.l	1
final_size	ds.l	1
source_size	ds.l	1
gif_workspace	ds.l	1
conv_buffer	ds.l	1

n_plans		ds.w	1
s_plans		ds.w	1
line_size		ds.l	1

pix_spec		ds.l	1
test_thread	ds.l	1
speed_factor	ds.l	1

target_mfdb	ds.w	10
my_bench		ds.l	1
free_ram		ds.l	1

		END

*-------------------------------------------------------------------------*