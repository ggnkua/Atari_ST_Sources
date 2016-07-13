********************************************************************
		
		****
		
		; test resizing
test_resize:
		move.l	struc_pix_4+gpix_ptr,a0
		
		moveq	#0,d0
		moveq	#0,d1
		
		move.l	pix_w(a0),d0
		move.l	pix_h(a0),d1
		
		lsr.l	#1,d0
		lsr.l	#1,d1
		
		move.l	d1,-(sp)
		move.l	d0,-(sp)
		move.l	a0,-(sp)
		
		jsr	pix_resize
		
		lea	12(sp),sp
		
		move.w	#33,-(sp)
		move.l	form_main,-(sp)
		jsr	TAG_REDRAW
		lea	6(sp),sp
		
		moveq	#0,d0
		rts
		
		****


********************************************************************

		****
		
		; resizing d'un bitmap en structure PIX
		; (pour l'instant 16 bits uniquement)
		
		rsset	8
_pir_ptr		rs.l	1	pointeur d'individu pix
_pir_w		rs.l	1	nouvelle largeur
_pir_h		rs.l	1	nouvelle hauteur
		
		****
				
		rsset	-64
_w_bloc		rs.w	1
_h_bloc		rs.w	1
_y_counter	rs.l	1
_x_counter	rs.l	1

		****

pix_resize:
		link	a6,#-64
		movem.l	d1-a5,-(sp)
		
		
		move.l	_pir_ptr(a6),a5
		
		; calcul de ratio en x
		
		move.l	_pir_w(a6),d0
		
		move.l	pix_w(a5),d1
		swap	d1
		clr.w	d1
		
		divu.l	d0,d1
		swap	d1
		
		; calcul de ratio en y
		
		move.l	_pir_h(a6),d0
		move.l	d0,_y_counter(a6)
		
		move.l	pix_h(a5),d2
		swap	d2
		clr.w	d2
		
		divu.l	d0,d2
		swap	d2
		
		****
		
		move.l	pix_addr(a5),a0
		move.l	a0,a1
		
		; taille ligne source en octets
		
		move.l	pix_w(a5),d0
		add.l	#15,d0
		and.l	#~15,d0
		add.l	d0,d0
		move.l	d0,a4
		
		; taille ligne cible en octets
		
		move.l	_pir_w(a6),d0
		add.l	#15,d0
		and.l	#~15,d0
		add.l	d0,d0
		move.l	d0,a3
		
		moveq	#0,d4
		
		****
.boucle_y
		; calcul hauteur courante
		
		clr.w	d0
		clr.w	d4
		add.l	d2,d4
		addx.w	d0,d4
		
		move.w	d4,_h_bloc(a6)
		
		; pointer source suivante Y
		
		move.l	a4,d0
		mulu.w	d4,d0
		pea	(a0,d0.l)
		
		; pointer cible suivante Y
		
		pea	(a1,a3.l)
		
		move.l	_pir_w(a6),_x_counter(a6)
		moveq	#0,d3
		
		****
		
		move.l	d2,-(sp)
		move.l	d4,-(sp)
.boucle_x
		move.w	_h_bloc(a6),d7
		
		; calcul largeur courante
		
		clr.w	d0
		clr.w	d3
		add.l	d1,d3
		addx.w	d0,d3
		
		move.w	d3,_w_bloc(a6)
		
		; pointer source suivante en X
		
		pea	(a0,d3.w*2)
		
		; a0=source
		; a1=destination
		; a4=offset de ligne ...
		
		move.l	d1,-(sp)
		move.l	d3,-(sp)
		
		move.w	(a0),d0
		
		bfextu	d0{16:5},d3
		bfextu	d0{21:6},d4
		bfextu	d0{27:5},d5
.matrix_y
		pea	(a0,a4.l)
		move.w	_w_bloc(a6),d6
.matrix_x
		move.w	(a0)+,d0
		
		moveq	#$1F,d2
		and.w	d0,d2
		
		lsr.w	#5,d0
		moveq	#$3F,d1
		and.w	d0,d1
		
		lsr.w	#6,d0
		
		add.w	d0,d3
		lsr.w	#1,d3
		
		add.w	d1,d4
		lsr.w	#1,d4
		
		add.w	d2,d5
		lsr.w	#1,d5
		
		subq.w	#1,d6
		bgt.s	.matrix_x
		
		move.l	(sp)+,a0
		
		subq.w	#1,d7
		bgt.s	.Matrix_y
		
		; ‚criture du pixel
		
		ror.w	#5,d3
		or.w	d3,d5
		lsl.w	#5,d4
		or.w	d4,d5
		
		move.w	d5,(a1)+
		
		****
		
		move.l	(sp)+,d3
		move.l	(sp)+,d1
		move.l	(sp)+,a0
		
		subq.l	#1,_x_counter(a6)
		bgt.s	.boucle_x
		
		****
.fin_y
		move.l	(sp)+,d4
		move.l	(sp)+,d2
		move.l	(sp)+,a1
		move.l	(sp)+,a0
		
		subq.l	#1,_y_counter(a6)
		bgt	.boucle_y
		
		****
		
		; c'est fini !
.Fin
		move.l	_pir_ptr(a6),a5
		
		move.l	_pir_w(a6),d0
		move.l	d0,pix_w(a5)
		
		
		move.l	_pir_h(a6),d0
		move.l	d0,pix_h(a5)
		
		moveq	#0,d0
		
		movem.l	(sp)+,d1-a5
		unlk	a6
		rts
		
		********

********************************************************************
