;gem_asm.s (module de base pour portage WinG->GEM) (partie asm)
;a linker avec gem_wing.c
;dans Options->Assembler choisir "Privileged Instructions"
;Guillaume LAMONOCA
;Supelec (94)

;pour devpac 2, remplacer IF par IFD, et produire un objet DRI sur disk
;pour desactiver keymap[], donnez lui la valeur 0

KEYMAP	equ		1

	xref	ptr_work_screen,ptr_view_screen,screen_size
	xref	matrice,haut,larg,ecran,matrice2
	xref	recal,recal2,masque,masque2
	xref	cur_color,cur_fg_color,xcur,ycur
	xref	clut256

	xdef	cls,drawba
	xdef	copyba,putpba,affchara

	IF KEYMAP
	xdef	unbuf
	ENDC





;void cls(void)
cls:
		clr.w	xcur
		clr.w	ycur
		move.l  ptr_work_screen,A0
		move.b	cur_fg_color,D1
		swap D1
		move.b  cur_fg_color,D1
		lsl.l	#8,D1
		move.b	cur_fg_color,D1
		swap D1	
		move.b	cur_fg_color,D1
		move.l  screen_size,D0
		lsr.l	#2,D0
w0:
		move.l	D1,(A0)+
		subq.l	#1,D0
		bne.s	w0
		
		rts





drawba:
		movem.l	D3/A2,-(A7)
		lea.l	clut256,A2
		move.l 	matrice,A0
		move.l	matrice2,A1
		move.w	haut,D0
		move.w  larg,D2

l3zz:
		move	D2,D1
l4zz:
		clr.w	D3
		move.b	(A0)+,D3
		add.w	D3,D3
		move.w	0(A2,D3.w),(A1)+
		dbf		D1,l4zz
		adda.l	recal,A0
		adda.l	recal2,A1
		dbf	 	D0,l3zz

		movem.l	(A7)+,D3/A2
		rts


copyba:
		move.w	larg,D2
		addq.w	#1,D2
		move.l	matrice,D0
		or.l	matrice2,D0
		or.w	D2,D0
		and.w	#3,D0
		beq fastc
		
		move.l 	matrice,A0
		move.l	matrice2,A1
		move.w	haut,D0
		move.w  larg,D2

l3z:
		move	D2,D1
l4z:
		move.b	(A0)+,(A1)+
		dbf		D1,l4z
		adda.l	recal,A0
		adda.l	recal2,A1
		dbf	 	D0,l3z

		rts
fastc:
		move.l 	matrice,A0
		move.l	matrice2,A1
		move.w	haut,D0
		move.w	larg,D2
		addq.w	#1,D2
		lsr.w 	#2,D2
		subq.w	#1,D2
fl3z:
		move	D2,D1
fl4z:
		move.l	(A0)+,(A1)+
		dbf		D1,fl4z
		adda.l	recal,A0
		adda.l	recal2,A1
		dbf	 	D0,fl3z

		rts



putpba:
		move.l D3,-(A7)
		move.l matrice,A0
		move.l matrice2,A1		
		move.w haut,D0
		move.w larg,D2
cont_18b:
		move.w D2,D1
cont_19b:      
		move.b (A0)+,D3
		cmp.b	#255,D3
		beq.w trspp
		move.b D3,(A1)
trspp:
		addq.l #1,A1
		dbf.w  D1,cont_19b
		adda.l recal,A0
		adda.l recal2,A1
		dbf.w  D0,cont_18b
		move.l (A7)+,D3
		rts


		
affchara:
		movem.l D3-D7/A2,-(A7)
		move.b cur_fg_color,D5
		move.b cur_color,D6
		move.l ecran,A1
		move.l matrice,A0
		move.l A0,A2
		adda.l #8,A2
		move.w #7,D0
cont_c133:      
		move.b (A0)+,D2
		move.b (A2)+,D3

		move.w #7,D4
cont_c134:
		lsl.b #1,D2
		bcs.s crg1
		move.b D5,(A1)
crg1:
		lsl.b #1,D3
		bcc.s crg4
		move.b D6,(A1)
crg4:
		addq.l #1,A1

		dbf.w D4,cont_c134

		adda.l recal,A1
		dbf.w D0,cont_c133

		movem.l (A7)+,D3-D7/A2
		rts
		


