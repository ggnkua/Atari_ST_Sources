	clr.l	-(sp)
	move	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	
	lea	transfert_objet(pc),a6
	
	lea	objet1(pc),a0
	lea	surface1(pc),a1
	lea	objet_data(pc),a2
	lea	surface_data(pc),a3
	movem.l	a0-a3,obj_s(a6)
	bsr	init_tansfert_objet
	bsr	init_gouraud_face
			



init_tansfert_objet
	move.l	obj_s(a6),a0
	move.l	obj_d(a6),a1
	move	(a0)+,d0
	move	d0,(a1)+	;transfert_nbr_point
	subq	#1,d0
.loop
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	dbf	d0,.loop
	move.l	surf_s(a6),a0
	move.l	surf_d(a6),a1
	move	(a0)+,d0
	move	d0,(a1)+
	subq	#1,d0
.loop2
	move	(a0)+,d1
	cmp	#2,d1
	beq	.gouraud
	move	d1,(a1)+
	move	(a0)+,(a1)+	;tf_couleur
	move	(a0)+,d1	;nbr_point/surf
	move	d1,(a1)+
	subq	#1,d1
.loop3
	move	(a0)+,(a1)+
	dbf	d1,.loop3
	clr	(a1)+	;laisse_place pour offset surface pleine
	bra.s	.next_face	
.gouraud
	move	d1,(a1)+
	move	(a0)+,(a1)+	;tf_couleur
	move	(a0)+,d1	;nbr_point/surf
	move	d1,(a1)+
	subq	#1,d1
.loop4
	move	(a0)+,(a1)+
	dbf	d1,.loop4
.next_face
	dbf	d0,.loop2
	rts
init_gouraud_face
	move.l	obj_d(a6),a0
	move.l	surf_d(a6),a1
	move	(a1)+,d0	;nbr_face
	subq	#1,d0
	
	section	data	
objet1
	dc	12
	dc	-40,-40,-40
	dc	-40,40,-40
	dc	40,40,-40
	dc	40,-40,-40

	dc	-40,-40,40
	dc	-40,40,40
	dc	40,40,40
	dc	40,-40,40

	dc	-40,-40,80
	dc	-40,40,80
	dc	40,40,80
	dc	40,-40,80

surface1
	dc	3
	dc	0,1,4	;surface_pleine
	dc	0,1,2,3
	dc	2,1,4	;surface_gouraud
	dc	0,5,7,8
	dc	2,1,4	;surface_gouraud
	dc	8,4,5,6
	
	
	section	bss
	
	rsreset
transfert_objet
obj_s		rs.l	1
surf_s		rs.l	1
obj_d		rs.l	1
surf_d		rs.l	1
nbr_point	rs	1
	ds.l	4
	
a
objet_data
	ds.l	200
b
surface_data
	ds.l	200
	