		
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
		; long: adresse table usblk

		****
gen_arbre_disp
		link	a6,#0
		movem.l	d1-a5,-(sp)
		
		;illegal
		
		move.l	8(a6),a5		; pointeur code userdef
		move.l	8+4(a6),a4	; pointeur node
		
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
		
		; 8 octets par userblk
		
		moveq	#8,d4
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
		
		move.w	#18<<8+G_USERDEF,ob_type(a0)
		
		clr.w	ob_state(a0)
		move.w	#EXIT+SELECTABLE,ob_flags(a0)
		
		move.l	a1,ob_spec(a0)
		move.l	a5,(a1)+
		move.l	a4,(a1)+
		
		clr.w	ob_x(a0)
		move.w	d4,ob_y(a0)
		
		move.w	#48*8,ob_w(a0)
		move.w	#8,ob_h(a0)
		
		add	#8,d4
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
