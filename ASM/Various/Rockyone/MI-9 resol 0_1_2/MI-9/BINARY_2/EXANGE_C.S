;rockyone			pour MI-9			05.11.2018
;
;		- echange deux index de couleur
;		- copy un index sur un autre
;
;		Image basse ou moyenne resolution
;
;
;buf_ecr	Buffer image format Degas 32034/32066 bytes
;Op%		0 echange les index de couleur et les couleurs
;		1 copy index color1 sur index color2
;limit%		Nombre d'octets a recopier sur l'‚cran
;color1%	
;color2%	Nouvelle position du cusseur  
;
;					d0	d1
;	call 	exange_c( L buf_ecr, color1%, color2%, op%, limit%)
;			    64       68       70       72   74  
;
;
;-------------------------------------------------------------------------
;used a0-a2/d0-d7
;
		movem.l	d0-d7/a0-a6,-(sp)
		move.l	64(sp),a0
		movem.w	68(sp),d0-d2		
	
		lea.l	34(a0),a1	; adresse de l'image
		lea.l	32000(a1),a2	; fin image

		tst.b	1(a0)		; r‚solution de l'image ?
		bne	resol_1
;---------------------------------------
		move.w	d0,d3
		tst.b	d2		; copy or exange ?
		beq.s	exange
		move.b	d1,d0	

exange:		swap	d0
		move.b	d1,d0
		eor.b	d3,d1		; plan(s) … modifier
		move.b	d1,masq
	
;.......................................
resol_0:	moveq.l	#15,d2
		movem.w	(a1),d3-d6
		moveq.l	#0,d1

all_bit:	moveq.l	#0,d7

		btst.b	d2,d3
		beq.s	bit_1	
		addq.l	#%1,d7

bit_1:		btst.b	d2,d4
		beq.s	bit_2	
		addq.b	#%10,d7

bit_2:		btst.b	d2,d5
		beq.s	bit_3	
		addq.b	#%100,d7

bit_3:		btst.b	d2,d6
		beq.s	cmp_index
		addq.b	#%1000,d7
	
cmp_index:	cmp.b	d0,d7		; = index 1?
		beq.s	masq_word

		swap	d0
		cmp.b	d0,d7		; = index 2 ?
		bne.s	next_bit

masq_word:	bset.b	d2,d1		; masque des 16 bits a modifier

next_bit:	dbra.w	d2,all_bit


		move.b	masq,d7
plan_1:		btst.b	#0,d7
		beq.s	plan_2
		eor.w	d1,d3		(a1)

plan_2:		btst.b	#1,d7
		beq.s	plan_3
		eor.w	d1,d4		2(a1)

plan_3:		btst.b	#2,d7
		beq.s	plan_4
		eor.w	d1,d5		4(a1)

plan_4:		btst.b	#3,d7
		beq.s	save_word
		eor.w	d1,d6		6(a1)	

save_word:	movem.w	d3-d6,(a1)
		addq.l	#8,a1

		cmpa.l	a1,a2
		bhi.s	resol_0	
;..............................................	
copy_to_screen:	movem.w	68(sp),d0-d3	
		tst.b	d2			; echange index ?
		bne.s	copy_pic
	
		lsl.b	#1,d0
		lsl.b	#1,d1
		move.w	2(a0,d0.w),d4
		move.w	2(a0,d1.w),2(a0,d0.w)
		move.w	d4,2(a0,d1.w)

copy_pic:	move.l	$44e,a1			; adresse ‚cran
		lea.l	0(a1,d3.w),a2
		adda.w	#34,a0
copy:		move.l	(a0)+,(a1)+
		cmpa.l	a1,a2
  		bhi.s	copy

;..............................................
_end:		movem.l	(sp)+,d0-d7/a0-a6
		rts

masq:		dc.b	0
		even
;-------------------------------------------------------------------------
;
;			  Moyenne r‚solution
;
;-------------------------------------------------------------------------
; La palette et dans l'odre hardware du systme:                     "0123"
; Les valeurs de color1 et color2 corespondent aux valeurs hardware 
; La couleur des pixels est index‚ sur la palette en valeur VDI:    "0213"
; Donc les index de couleur ‚gal  … 1 et 2 sont invers‚
;-------------------------------------------------------------------------

resol_1:	tst.b	d2		; copy or exange  ?
		bne.s	start_copy
		move.w	d0,d7
		add.b	d1,d7
		bra	start_exange

;Hard index                             ; VDI index	  d1 = new index 
;-----------------------------------------------------------------------
start_copy:	tst.b	d1		 		
		beq.s	zero		 		

		cmpi.b	#1,d1		; 2		   
		beq.s	deux				   	

		cmpi.b	#2,d1		; 1		   
		beq.s	un
;........................................
add_t:		addq.l	#4,a1
		cmpa.l	a1,a2
		beq.s	copy_to_screen
		move.l	(a1),d3
trois:		and.w	(a1),d3
		tst.b	d0		
		bne.s	t_2		

t_0:		eor.w	d3,2(a1)	; 0 on 3	
		cmpi.b	#1,d1		
		beq.s	add_t		
t_2:		eor.w	d3,(a1)	 	; 1 on 3	
		bra.s	add_t
;........................................ 
add_z:		addq.l	#4,a1
		cmpa.l	a1,a2
		beq.s	copy_to_screen
		move.l	(a1),d3
zero:		not.l	d3		
		cmpi.b	#1,d0		; 2 ?
		beq.s	z_1
		swap	d3
		cmpi.b	#3,d0		
		beq.s	z_3		; d0  d1
z_2:		or.w	d3,2(a1)	; 1 on 0	
		bra.s	add_z
z_1:		or.w	d3,(a1)		; 2 on 0		
		bra.s	add_z		; 3 on 0
z_3:		or.l	d3,(a1)		
		bra.s	add_z
;........................................
;'deux' = 1 Harware 
;------------------
add_d:		addq.l	#4,a1
		cmpa.l	a1,a2
		beq	copy_to_screen
		move.l	(a1),d3
deux:		cmpi.b	#3,d0
		beq.s	d_3		
d_0		and.w	d3,(a1) 	; 0 on 2   
		tst.b	d0
		beq.s	add_d
d_3:		swap	d3			
		or.w	d3,2(a1)	; 3 on 2 
		bra.s	add_d
;........................................
;'un' = 2 harware
;----------------
add_u:		addq.l	#4,a1
		cmpa.l	a1,a2
		beq	copy_to_screen
		move.l	(a1),d3
un:		tst.b	d0
		beq.s	u_0
u_3:		or.w	d3,(a1)		; 3 on 1
		cmpi.w	#3,d0
		beq.s	add_u
u_0		swap	d3		; 0 on 1
		and.w	d3,2(a1)
		bra.s	add_u
;.........................................................
ex_ange:	addq.l	#4,a1
		cmpa.l	a1,a2
		beq	copy_to_screen

start_exange:	movem.w	(a1),d3-d4
		
		tst.b	d0
		beq.s	ex_0
		tst.b	d1
		beq.s	ex_0

		cmpi.b	#4,d7
		beq.s	ex_1_3
		cmpi.b	#5,d7
		beq.s	ex_2_3
		bra.s	ex_1_2
;.................................		
ex_0:		not.w	d4		
		cmpi.b	#2,d7
		beq.s	ex_0_2
		cmpi.b	#3,d7
		beq.s	ex_0_3	

;					; 1_3
ex_2_3:					

ex_0_1:		eor.w	d4,(a1)   	; 0_2 
		bra.s	ex_ange
ex_0_2:		eor.w	d4,d3		; 0_1 
		move.w	d3,2(a1)
		bra.s	ex_ange

ex_0_3:		not.w	d3		; 0_3
ex_1_2:		move.w	d4,(a1)		
		move.w	d3,2(a1)
		bra.s	ex_ange	
ex_1_3:		eor.w	d3,2(a1)	; 2_3
		bra.s	ex_ange	

		end
