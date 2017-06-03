r:		equ		38
v:		equ		48
b:		equ		28

point:		macro
		add.w		d6,d6		* Couleur point * 2
		move.w		(a2,d6.w),d6	* Eqvalent en ton
		add.w		d6,d6		*
		dc.w		$6404		* Si bit 3
		or.w		d7,8(a1)		
		add.w		d6,d6		
		dc.w		$6404		* Si bit 2
		or.w		d7,6(a1)
		add.w		d6,d6	
		dc.w		$6404		* Si bit 1
		or.w		d7,4(a1)
		add.w		d6,d6		
		dc.w		$6402		* Si bit 0 
		or.w 		d7,(a1)
		ror.w		#1,d7		
		dc.w		$6402
		addq.l		#8,a1		* Si fin de mot
		endm

		output	e:\code\synthy.art\curent\fichiers.inl\reduct.inl

*-------------------------------------------------------------------------*
*									  *
* 	-SYNTHETIC ARTS 3-		REDUCTION D'IMAGES 	  	  *
*					NOIR & BLANC (par luminance) 	  *
*					NORMAL			  	  *
*									  *
*-------------------------------------------------------------------------*

	tst.w		16(sp)			* Mode de reduction
	beq		simple

	move.l		4(sp),a0		* Chargement registres
	move.l		8(sp),a1
	move.l		12(sp),a3		* Adresse palette
	
	lea		table(pc),a2		
	moveq.l		#4,d4			* Prechargement
	moveq.l		#8,d5
	moveq.l		#7,d7
	move.w		#15,d0

calctable:
	move.w		(a3)+,d1		* Prend couleur palette
	move.w		d1,d3			*
	and.w		d7,d3			* And.w	#7,d3: garde B
	mulu.w		#b,d3
	
	move.w		d1,d2			*
	lsr.w		d4,d2
	and.w		d7,d2			* And.w	#7,d2
	mulu.w		#v,d2
	add.w		d2,d3			* Ajoute V

	move.w		d1,d2			*
	lsr.w		d5,d2			* Lsr.w	#8,d2
	and.w		d7,d2			* And.w	#7,d2
	mulu.w		#r,d2
	add.w		d2,d3			* Ajoute R

	divu.w		#100,d3
	and.w		#15,d3			* Verifie que c inferieur a 15
	ror.w		d4,d3			* Balance en haut du mot
	move.w		d3,(a2)+		* Met dans la table
	dbra.w		d0,calctable		

	lea		table(pc),a2
	move.l		#50*65536,d5		* Compteur double : d5 
	move.w		#%1000000000000000,d7	* Bit tournant : d7
		
loop1_1:	
		move.w		#20,d5
		moveq.l		#0,d6
		rept		10
		move.l		d6,(a1)+
		endr
		lea		-40(a1),a1				
loop1_2:
		move.w		(a0)+,d0
		move.w		(a0)+,d1
		move.w		(a0)+,d2
		move.w		(a0)+,d3

		moveq.l		#0,d6
		add.w		d3,d3
		addx.w		d6,d6
		add.w		d2,d2
		addx.w		d6,d6
		add.w		d1,d1
		addx.w		d6,d6
		add.w		d0,d0
		addx.w		d6,d6
		point
		
		rept		3
		moveq.l		#0,d6
		lsl.w		d4,d3
		addx.w		d6,d6
		lsl.w		d4,d2
		addx.w		d6,d6
		lsl.w		d4,d1
		addx.w		d6,d6
		lsl.w		d4,d0
		addx.w		d6,d6
		point
		endr

		subq.w		#1,d5
		bne		loop1_2
 
		lea		480(a0),a0
		lea		160-40(a1),a1
	
		sub.l		#65536,d5
		bne		loop1_1

		rts
		
simple:		incbin		e:\code\synthy.art\curent\fichiers.inl\retrc.inl

table:		ds.w		16
