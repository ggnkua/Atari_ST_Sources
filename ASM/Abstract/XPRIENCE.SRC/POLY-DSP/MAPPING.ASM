;***********************************************************************
;***********										 ***********
;***********										 ***********
;***********			3D Mapp‚e au DSP				 ***********
;***********										 ***********
;***********										 ***********
;***********		   Par Simplet / ABSTRACT			 ***********
;***********										 ***********
;***********************************************************************


PBC		equ		$ffe0			; Port B Control Register
HSR		equ		$ffe9			; Host Status Register
HRX		equ		$ffeb			; Host Receive Register
HTX		equ		$ffeb			; Host Transmit Register

;	Host Status Register Bit Flags

HRDF		equ		0				; Host Receive Data Full
HTDE		equ		1				; Host Transmit Data Empty


		org		p:0

 		jmp		<Start

		org		p:410


; Ca commence la !

Start	movep	#1,X:<<PBC

		move		Y:<Adr_Bandes1,r0
		jsr		<Clear_Buffer
		move		Y:<Adr_Bandes2,r0
		jsr		<Clear_Buffer

; Pour v‚rifier la connexion
Conct_Get	jclr		#<HRDF,X:<<HSR,Conct_Get
		movep	X:<<HRX,x0

Conct_Snd	jclr		#<HTDE,X:<<HSR,Conct_Snd
		movep	#12345678,X:<<HTX


; Recupere la table 1/x
		move		#INVBEG,r0
		DO		#<3001,Get_Inv_Table

GetInvTab	jclr		#<HRDF,X:<<HSR,GetInvTab
		movep	X:<<HRX,Y:(r0)+
Get_Inv_Table

; Recupere la table sinus/cosinus
		move		#SINTAB,r0
		DO		#<450,Get_Sinus_Table

GetSinTab	jclr		#<HRDF,X:<<HSR,GetSinTab
		movep	X:<<HRX,Y:(r0)+
Get_Sinus_Table

; Recupere les Images
		move		#80*80,n0
		move		#IMAGE1,r0
		Do		n0,Get_Img1
Get_Pix1	jclr		#<HRDF,X:<<HSR,Get_Pix1
		movep	X:<<HRX,Y:(r0)+
Get_Img1

		move		#IMAGE2,r0
		Do		n0,Get_Img2
Get_Pix2	jclr		#<HRDF,X:<<HSR,Get_Pix2
		movep	X:<<HRX,X:(r0)+
Get_Img2

		move		#IMAGE3,r0
		Do		n0,Get_Img3
Get_Pix3	jclr		#<HRDF,X:<<HSR,Get_Pix3
		movep	X:<<HRX,X:(r0)+
Get_Img3

;
; Boucle principale
;

Loop		jclr		#<HRDF,X:<<HSR,Loop
		movep	X:<<HRX,a

		tst		a
		jeq		<Get_Adr

Get_Dollar
		move		#140*58,x0
		move		#IMAGE2,r0
		Do		x0,GetDollar
Get_Dol	jclr		#<HRDF,X:<<HSR,Get_Dol
		movep	X:<<HRX,X:(r0)+
GetDollar


Get_Adr	jclr		#<HRDF,X:<<HSR,Get_Adr
		movep	X:<<HRX,X:Screen_Adress

Get_Obj	jclr		#<HRDF,X:<<HSR,Get_Obj
		movep	X:<<HRX,x0
		move		#>5,x1
		mpy		x0,x1,a		#>OBJETS,b0
		addr		b,a
		move		a0,r0
		nop
		move		Y:(r0)+,x0
		move		x0,Y:<Adr_Points
		move		Y:(r0)+,x0
		move		x0,X:<Nb_Points
		move		Y:(r0)+,x0
		move		x0,Y:<Adr_Faces
		move		Y:(r0)+,x0
		move		x0,X:<Nb_Faces
		move		Y:(r0),x0
		move		x0,Y:<Coeff_Light

		move		#Rotations,r0
		Do		#<6,Get_Infos
Get_Info	jclr		#<HRDF,X:<<HSR,Get_Info
		movep	X:<<HRX,X:(r0)+
Get_Infos

		jsr		<Calcule_Matrice
		jsr		<Calcule_Points

		move		Y:<Adr_Buffer,r0
		jsr		<Clear_Buffer

; Les calculs sont finis

Send_End	jclr		#<HTDE,X:<<HSR,Send_End
		movep	x0,X:<<HTX

; Scanne les faces et appelle les routines

		move		Y:<Adr_Faces,r0

		Do		X:<Nb_Faces,Scan_Faces

		move		#PTS_PROJ,r1
		move		#PTS_SCR,r2
		move		Y:(r0)+,n0
		move		r0,r5
		Do		n0,Scan_Points

		move		Y:(r0)+,n1
		nop
		move		X:(r1+n1),x0
		move		x0,X:(r2)
		move		Y:(r1+n1),x0
		move		x0,Y:(r2)+
Scan_Points
		move		Y:(r5),n1
		move		#PTS_SCR+1,r4
		move		X:(r1+n1),x1				; Recopie le
		move		x1,X:(r2)					; premier point
		move		Y:(r1+n1),y1				; pour le
		move		y1,Y:(r2)					; dernier segment

		move		X:(r4),a
		sub		x1,a			Y:(r4)+,b
		sub		y1,b			a,x0
		move		X:(r4),a		b,y0
		sub		x1,a			Y:(r4),b		; Test de Visibilit‚
		sub		y1,b			a,x1
		mpy		-x1,y0,a		b,y1
		mac		x0,y1,a		Y:(r0)+,b

		move		r0,X:<Save_r0
		jmi		<Hidden_Face

		move		#>1,x0
		cmp		x0,b			#>2,x0
;		jeq		<Polygone_Rout
		cmp		x0,b
;		jeq		<Gouraud_Rout
		jmp		<Mapping_Rout

Showed_Face
		jsr		<Add_Polygone

Hidden_Face
		move		X:<Save_r0,r0
		nop
		lua		(r0)+,r0

Scan_Faces
		jclr		#<HTDE,X:<<HSR,Scan_Faces
		movep	#0,X:<<HTX

		jmp		<Calc_Bandes

;
; Routine de Mapping
;

Mapping_Rout
		jclr		#<HTDE,X:<<HSR,Mapping_Rout
		movep	#3,X:<<HTX

		move		Y:(r0),r0
		move		#PTS_IMG,r2
		move		Y:(r0)+,x0
		move		x0,Y:<Adr_Img
		move		Y:(r0)+,x0
		move		x0,Y:<Off7_Img
		move		r2,r4

		Do		n0,M_Copy_Points

		move		Y:(r0)+,x0
		move		x0,X:(r4)		Y:(r0)+,y0
		move		y0,Y:(r4)+
M_Copy_Points
		move		X:(r2),x0					; Recopie pour
		move		x0,X:(r4)		Y:(r2),y0		; le dernier
		move		y0,Y:(r4)					; segment

		move		#PTS_SCR,r0
		lua		(r2)+,r3					; Pointe sur
		lua		(r0)+,r1					; Points suivants
		clr		a			#>199,x0		; Initialise
		move		x0,X:<YMin				; YMin … 199
		move		a,X:<YMax					; YMax … 0


; Boucle de trac‚ virtuel dans les tableaux
; des segments qui composent le polygone … l'‚cran
; et calcul des positions de d‚part/arriv‚e dans l'image … mapper

		Do		n0,M_Virtual_Tracing


		move		X:<YMin,x0				; YMin
		move		Y:(r0),b					; Y1
		cmp		x0,b			X:<YMax,x0	; YMax
		jge		<M_No_YMin				; si Y1 < YMin
		move		b,X:<YMin					; c'est le nouveau YMin
M_No_YMin	cmp		x0,b			X:(r0)+,x0	; X1
		jle		<M_No_YMax				; si Y1 > YMax
		move		b,X:<YMax					; c'est le nouveau YMax
M_No_YMax

		move		#XMAX,r5					; Remplis XMax
		move		#XARR,r6					; et XArr par d‚faut

		move		X:(r1),a		b,y0			; X2, Y1
		sub		x0,a			Y:(r1)+,b		; Calc dX	,Y2
		sub		y0,b			y0,n5		; dY
		jeq		<M_Fill_Horiz
		jpl		<M_Fill_XMax

M_Fill_Xmin
		move		r0,r4					; On monte, inverse
		move		#XMIN,r5					; tout et remplis
		move		#XDEP,r6					; XMin et XDep
		move		X:(r4),x0					; X2
		move		Y:(r4)-,y0				; Y2
		move		X:(r4),a					; X1
		sub		x0,a			Y:(r4),b		; Calc dX	,Y1
		sub		y0,b			y0,n5		; dY

		jsr		<M_Calcule_Pente

		move		X:(r2),a					; XDep
		move		Y:(r2)+,b					; YDep
		move		X:(r3),x1					; XArr
		sub		x1,a			Y:(r3)+,y1	; Calc dX	,YArr
		sub		y1,b			#<0,x0		; dY

		jmp		<M_Fill_Continue

M_Fill_XMax
		jsr		<M_Calcule_Pente

		move		X:(r3),a					; XArr
		move		Y:(r3)+,b					; YArr
		move		X:(r2),x1					; XDep
		sub		x1,a			Y:(r2)+,y1	; Calc dX	,YDep
		sub		y1,b			#<0,x0		; dY

M_Fill_Continue
		move		x,L:<Pos_IX
		move		x0,y0
		move		y,L:<Pos_IY
		jsr		<M_Calcule_Increments_Image

		move		X:<Dep_X,a
		move		L:<Pente,x

		Do		n4,M_Fill_Tabs

		move		a,X:(r5)+					; X courant du polygone
		add		x,a			L:<Incr_IX,y	; nouvel X
		move		L:<Pos_IX,b				; X courant sur l'image
		add		y,b			b,X:(r6)		; nouvel X
		move		b,L:<Pos_IX
		move		L:<Incr_IY,y
		move		L:<Pos_IY,b				; Y courant sur l'image
		add		y,b			b,Y:(r6)+		; nouvel Y
		move		b,L:<Pos_IY
M_Fill_Tabs
		move		a,X:(r5)
		move		b,Y:(r6)
		move		L:<Pos_IX,b
		move		b,X:(r6)

M_Fill_Next
		nop

M_Virtual_Tracing

; Maintenant que les tableaux sont remplis
; on les parcourt de YMin … YMax, on recueille les infos
; et on appelle la routine de Mapping de Ligne Horizontale … chaque fois

		move		X:<YMin,b					; Premiere Ligne
		tst		b			#>199,x1
		jpl		<M_YMin_Ok
		clr		b
M_YMin_Ok	move		X:<YMax,a					; Derniere Ligne
		cmp		x1,a			b,x0
		jlt		<M_YMax_Ok
		move		x1,a
M_YMax_Ok	move		b,X:<YMin
		move		a,X:<YMax

		sub		x0,a			#>1,y0
		add		y0,a			X:<Screen_Adress,b0
		move		a,n7						; Nombre de Lignes

M_Send_Nb_Lines
		jclr		#<HTDE,X:<<HSR,M_Send_Nb_Lines
		movep	n7,X:<<HTX

		move		Y:<Off7_Scr,y0				; Calcule offset
		mpy		x0,y0,a					; premiere ligne
		addr		b,a			#>XMIN,b		; et adresse sur l'ecran
		move		a0,Y:<Adr_Scr

		add		x0,b			#>XMAX,a
		move		b,r0						; Pointe sur la
		add		x0,a			#>XDEP,b
		move		a,r1						; premiere dans
		add		x0,b			#>XARR,a
		add		x0,a			b,r3			; les tableaux
		move		a,r4


		Do		n7,Mapping_Lines_Loop

		move		X:(r1)+,a					; XMax
		move		X:(r0)+,x0				; - XMin
 		sub		x0,a			#>1,y0
		jmi		<M_No_Pixels
		add		y0,a						; = Nombre de Pixels
		move		a,n2

M_Send_Nb_Pixels
		jclr		#<HTDE,X:<<HSR,M_Send_Nb_Pixels
		movep	n2,X:<<HTX

		move		Y:<Adr_Scr,b
		move		x0,a						; X de d‚part
		addl		b,a			Y:(r3),b		; Adresse Ecran

M_Send_Adress_X
		jclr		#<HTDE,X:<<HSR,M_Send_Adress_X
		movep	a,X:<<HTX

		move		b,X:<Dep_IY				; Coordonn‚es
		move		X:(r3)+,a		Y:(r4),b
		move		a,X:<Dep_IX				; de d‚part
		move		b,Y:<Arr_IY				; et d'arriv‚e
		move		X:(r4)+,a
		move		a,Y:<Arr_IX				; dans l'image

		move		r0,n0
		move		r1,n1					; Sauve les
		move		r3,n3					; registres
		move		r4,n4
		jsr		<Mapping_Line				; Appel Magique
		move		n0,r0
		move		n1,r1					; Restore les
		move		n3,r3					; registres
		move		n4,r4

Mapping_Next_Line
		move		Y:<Adr_Scr,a
		move		Y:<Off7_Scr,x0
		add		x0,a
		move		a,Y:<Adr_Scr

Mapping_Lines_Loop
		jmp		<Showed_Face

M_No_Pixels
		jclr		#<HTDE,X:<<HSR,M_No_Pixels
		lua		(r3)+,r3
		lua		(r4)+,r4
		movep	#0,X:<<HTX
		jmp		<Mapping_Next_Line


; Calcule les incr‚ments de X et Y de l'image … chaque ligne

M_Calcule_Increments_Image
		move		a,x0						; dX
		move		Y:(r4+n4),x1				; 1 / Nb Pixels
		mpy		x0,x1,a		(r5)+n5		; dX / Nb Pixels
		move		a,L:<Incr_IX				; = Incr_IX

		move		b,x0						; dY
		mpy		x0,x1,b		(r6)+n6		; dY / Nb Pixels
		move		b,L:<Incr_IY				; = Incr_IY
		rts

; Calcule l'incr‚ment de X … chaque ligne = la pente du segment

M_Calcule_Pente
		move		x0,X:<Dep_X				; X de d‚part
		move		b,n4						; Nombre de lignes
		move		#INVTAB,r4

		move		a,x0						; dX
		move		Y:(r4+n4),x1				; 1 / dY
		mpy		x0,x1,a		n5,n6		; dX / dY
		move		a,L:<Pente				; = Pente
		rts

; Cas d'un Segment Horizontal

M_Fill_Horiz
		add		x0,a			#XMIN,r6
		cmp		x0,a			n5,n6	; X2 < X1 ??
		jlt		<M_Fill_Horiz_1		; Oui

		move		x0,X:(r6+n6)			; XMin = X1
		move		a,X:(r5+n5)			; XMax = X2
		move		#XARR,r6
		move		#XDEP,r5

		jmp		<M_Fill_Horiz_2

M_Fill_Horiz_1
		move		a,X:(r6+n6)			; XMin = X2
		move		x0,X:(r5+n5)			; XMax = X1
		move		#XDEP,r6
		move		#XARR,r5

M_Fill_Horiz_2
		lua		(r6)+n6,r6
		move		X:(r3),x0
		move		Y:(r3)+,y0	x0,X:(r6)
		move		X:(r2),x0		y0,Y:(r6)
		move		Y:(r2)+,y0
		move		x0,X:(r5+n5)
		move		y0,Y:(r5+n5)
		jmp		<M_Fill_Next


; Mapping d'une ligne horizontale

Mapping_Line
		move		#<Pos_IX,r3
		move		#INVTAB,r2
		lua		(r3)+,r4
		move		#<Dep_IY,r0
		lua		(r4)+,r5

		move		Y:(r0),a					; Y Arriv‚e * 987
		lua		(r5)+,r1

		move		X:(r0)-,y1				; - Y D‚part * 987
		sub		y1,a			Y:(r2+n2),x1
		move		a,x0						; = dY * 987
		mpy		x0,x1,a		#>$800000/987,y0
		move		a,x0						; dY / Nb Pts * 987
		mpy		x0,y0,a
		move		a,L:(r1)					; dY / Nb Pts
		mpy		y0,y1,a
		move		a,L:(r4)					; Y d‚part

		move		Y:(r0),a					; X Arriv‚e * 987
		move		X:(r0)-,y1				; - X D‚part * 987
		sub		y1,a
		move		a,x0						; = dX * 987
		mpy		x0,x1,a		Y:<Adr_Img,r6
		move		a,x0						; dX / Nb Pts * 987
		mpy		x0,y0,a
		move		a,L:(r5)					; dX / Nb Pts
		mpy		y0,y1,a		#Off7_Img,r0
		move		a,L:(r3)					; X d‚part

		move		L:(r5),x					; Increment X
		move		L:(r1),y					; Incr‚ment Y

		Do		n2,Mapping_Line_Loop

		move		L:(r4),b					; Position Y
		add		y,b			b,y0			; Prend Ancienne et
		add		x,a			b,L:(r4)		; Sauve nouvelle
		move		a,b0
		lsl		b			Y:(r0),y1
		mac		y0,y1,b		L:(r1),y
		move		b0,n6

M_Send_Pixel
		jclr		#<HTDE,X:<<HSR,M_Send_Pixel
		movep	P:(r6+n6),X:<<HTX
Mapping_Line_Loop
		rts


; Efface le buffer contenant la somme des polygones
; pour effacement par bandes

Clear_Buffer
		clr		a			#>319,x0
		move		r0,r4
		Do		#<200,Clear_Buffer_Loop
		move		x0,X:(r0)+	a,Y:(r4)+
Clear_Buffer_Loop
		rts

; Ajoute un polygone pour l'effacement par bandes

Add_Polygone
		move		X:<YMax,b
		move		X:<YMin,x0
		sub		x0,b			#>1,y0
		add		y0,b			#>XMIN,a
		add		x0,a			b,n2
		move		#>XMAX,b
		add		x0,b			a,r0
		move		Y:<Adr_Buffer,a
		add		x0,a			b,r1
		move		a,r3
		move		a,r4

		Do		n2,Add_Poly_Loop

		move		X:(r1)+,x0	Y:(r4),a
		cmp		x0,a			X:(r0)+,y0
		jgt		<B_XMax_Ok
		move		x0,a
B_XMax_Ok	move		a,Y:(r4)+		X:(r3),b
		cmp		y0,b
		jlt		<B_XMin_Ok
		move		y0,b
B_XMin_Ok	move		b,X:(r3)+

Add_Poly_Loop
		rts

; Calcule la diff‚rence entre les sommes des polygones
; c'est … dire les bandes et demande effacement par le 030

Calc_Bandes
		move		Y:<Adr_Buffer,r0
		move		Y:<Adr_Bandes1,r4

		move		X:<Screen_Adress,b
		move		Y:<Off7_Scr,x1

		move		#>0-100,y0
		move		#>320+100,y1

		Do		#<200,Calc_Bandes_Loop		

		move		X:(r4),x0
		move		X:(r0),a
		cmp		y1,a
		jeq		<B_No_XMin
		sub		x0,a
		jle		<B_No_XMin

BMin_Send_Nb_Pixels
		jclr		#<HTDE,X:<<HSR,BMin_Send_Nb_Pixels
		movep	a,X:<<HTX

		move		x0,a
		addl		b,a
BMin_Send_Adr
		jclr		#<HTDE,X:<<HSR,BMin_Send_Adr
		movep	a,X:<<HTX

B_No_XMin	move		Y:(r4)+,a
		move		Y:(r0)+,x0
		sub		x0,a
		jle		<B_No_Xmax

BMax_Send_Nb_Pixels
		jclr		#<HTDE,X:<<HSR,BMax_Send_Nb_Pixels
		movep	a,X:<<HTX

		move		x0,a
		addl		b,a			#>2,x0
		add		x0,a
BMax_Send_Adr
		jclr		#<HTDE,X:<<HSR,BMax_Send_Adr
		movep	a,X:<<HTX

B_No_Xmax	add		x1,b					; Ligne suivante

Calc_Bandes_Loop
		jclr		#<HTDE,X:<<HSR,Calc_Bandes_Loop
		movep	#0,X:<<HTX

		move		Y:<Adr_Bandes2,x1
		move		Y:<Adr_Buffer,x0
		move		x0,Y:<Adr_Bandes2
		move		Y:<Adr_Bandes1,x0
		move		x0,Y:<Adr_Buffer
		move		x1,Y:<Adr_Bandes1

		jmp		<Loop


; Calcule la matrice pour rotations 3D

Calcule_Matrice
		move		#Rotations,r0
		move		#Matrice,r1
		move		#COSTAB,r2			
		move		#SINTAB,r5
		move		r2,r3
		move		r5,r6

		move		X:(r0),n2					; Offset pour cos X dans la table sinus
		move		X:(r0)+,n5
		lua		(r2)+n2,r2				; Cos a
		lua		(r5)+n5,r5				; Sin a
		move		X:(r0)+,x0
		move		x0,n3
		move		x0,n6
		lua		(r3)+n3,r3				; Cos b
		lua		(r6)+n6,r6				; Sin b
		move		X:(r0)+,a
		sub		x0,a			#<2,n0
		move		a,n3						; Cos c
		move		a,n6						; Sin c

		move		X:(r0+n0),a				; Trans Z
		move		a,X:(r1)+

		move		Y:(r6),a
		neg		a
		move		a,X:(r1)+

		move		Y:(r3),x0
		move		Y:(r5),y0
		mpyr		x0,y0,a
		move		a,X:(r1)+
		
		move		Y:(r3),x0
		move		Y:(r2),y0
		mpyr		x0,y0,a
		move		a,X:(r1)+

 		move		X:(r0)+,a					; Trans X
		move		a,X:(r1)+

		move		Y:(r3),x0
		move		Y:(r3+n3),y0
		mpyr		x0,y0,a
		move		a,X:(r1)+

		move		Y:(r2),x0
		move		Y:(r6+n6),y0
		mpy		-y0,x0,a
		move		Y:(r3+n3),x0
		move		Y:(r6),y0
		mpyr		x0,y0,b
		move		b,x0
		move		Y:(r5),y0
		macr		y0,x0,a
		move		a,X:(r1)+

		move		Y:(r6+n6),x0
		move		Y:(r5),y0
		mpy		y0,x0,a
		move		Y:(r3+n3),x0
		move		Y:(r6),y0
		mpyr		x0,y0,b
		move		b,x0
		move		Y:(r2),y0
		macr		y0,x0,a
		move		a,X:(r1)+

		move		X:(r0)+,a					; Trans Y
		move		a,X:(r1)+
		
		move		Y:(r6+n6),y0
		move		Y:(r3),x0
		mpyr		x0,y0,a
		move		a,X:(r1)+
		
		move		Y:(r2),x0
		move		Y:(r3+n3),y0
		mpy		y0,x0,a
		move		Y:(r6+n6),x0
		move		Y:(r6),y0
		mpyr		x0,y0,b
		move		b,x0
		move		Y:(r5),y0
		macr		y0,x0,a
		move		a,X:(r1)+

		move		Y:(r3+n3),x0
		move		Y:(r5),y0
		mpy		-y0,x0,a
		move		Y:(r6+n6),x0
		move		Y:(r6),y0
		mpyr		x0,y0,b
		move		b,x0
		move		Y:(r2),y0
		macr		y0,x0,a
		move		a,X:(r1)+
		rts

; Rotate et translates les points
; calcule l'intensite de lumiere
; et projete sur le plan de l'ecran

Calcule_Points
		move		#Matrice,r0
		move		#<Center_X,r1
		move		Y:<Adr_Points,r4
		move		#PTS_PROJ,r2
		move		#INVTAB,r5
		move		Y:<Z_Ptf,n5
		move		#<11,n0
		lua		(r5)+n5,r6
		Do		X:<Nb_Points,Calculate_3D_Points

		move		X:(r0)+,a
		move		X:(r0)+,x0	Y:(r4)+,y0
		mac		x0,y0,a		X:(r0)+,x0	Y:(r4)+,y1
		mac		x0,y1,a		X:(r0)+,x0	Y:(r4)-,y1
		macr		x0,y1,a		X:(r0)+,b		Y:(r6),y1

		move		a,x0
		move		#>512,a		
		macr		-x0,y1,a		X:(r0)+,x0
		move		a,n5

		mac		x0,y0,b		X:(r0)+,x0	Y:(r4)+,y1
		mac		x0,y1,b		X:(r0)+,x0	Y:(r4)-,y1
		macr		x0,y1,b		X:(r0)+,a
		move		b,y1			X:(r1)+,b

		move		Y:(r5+n5),x1
		macr		y1,x1,b		X:(r0)+,x0
		move		b,X:(r2)

		mac		x0,y0,a		X:(r0)+,x0	Y:(r4)+,y1
		mac		x0,y1,a		X:(r0),x0		Y:(r4)+,y1
		macr		x0,y1,a		X:(r1)-,b
		move		a,x0

		macr		x0,x1,b		(r0)-n0
		move		b,Y:(r2)+

Calculate_3D_Points
		rts

End_Code

			org		X:0

Dep_IX		DS		1
Dep_IY		DS		1
Dep_X		DS		1
Center_X		DC		160
Center_Y		DC		100
YMin			DS		1
YMax			DS		1
Nb_Faces		DS		1
Nb_Points		DS		1
Screen_Adress	DS		1
Save_r0		DS		1

			org		Y:0

Arr_IX		DS		1
Arr_IY		DS		1
Coeff_Light	DS		1
Z_Ptf		DC		300
Adr_Buffer	DC		BANDES0
Adr_Bandes1	DC		BANDES1
Adr_Bandes2	DC		BANDES2
Off7_Scr		DC		2*320
Adr_Scr		DS		1
Adr_Img		DS		1
Off7_Img		DS		1
Adr_Faces		DS		1
Adr_Points	DS		1

			org		L:11

Pente		DS		1
Pos_IX		DS		1
Pos_IY		DS		1
Incr_IX		DS		1
Incr_IY		DS		1

			org		X:16

BANDES1		DS		200
BANDES2		DS		200

Matrice		DS		12
Rotations		DS		3
Translations	DS		3

			DS		25
XMIN			DS		225
XMAX			DS		225

			org		Y:16

			DS		200
			DS		200

			org		X:End_Code

PTS_PROJ		DS		134

PTS_SCR		DS		10
PTS_IMG		DS		10

			DS		25
XDEP			DS		225
XARR			DS		225

; Tableaux pour effacage par bandes

BANDES0		DS		200

; Images pour le Mapping

IMAGE2		DS		80*80
IMAGE3		DS		80*80

End_X
			org		Y:End_Code

			DS		134
			DS		10
			DS		10

			DS		25
YDEP			DS		225
YARR			DS		225

			DS		200

; Description des objets
; Adresse des points, nombre de points
; Adresse des faces, nombre de faces
; Coefficient pour le Gouraud Shading [rapport Intensit‚ / Profondeur (Z)]

OBJETS		DC		CUBE_POINTS,8,CUBE_FACES,6,$800000*987/1400
			DC		GATO_POINTS,16,GATO_FACES,10,$800000*987/1400
			DC		SPHERE_POINTS,134,SPHERE_FACES,124,$800000*987/370
			DC		TETRAEDRE_POINTS,4,TETRAEDRE_FACES,4,$800000*800/1400
			DC		BOUZOU_POINTS,12,BOUZOU_FACES,20,$800000*987/1400

; Description des Faces
; Nombre de Points
; Liste des num‚ros de Point
; Type de polygone :	1 = Normal	Couleur
;					2 = Gouraud	Infos Adresse Couleurs
;					3 = Mapping	Infos Adresse Image + Coordonn‚es

CUBE_FACES	DC		4,1,5,6,2,3,MAPPING3
			DC		4,3,0,1,2,3,MAPPING2
			DC		4,0,4,5,1,3,MAPPING1
			DC		4,7,6,5,4,3,MAPPING3
			DC		4,0,3,7,4,3,MAPPING2
			DC		4,3,2,6,7,3,MAPPING1

CUBE_POINTS	DC		-50*512,-50*512,+50*512
			DC		+50*512,-50*512,+50*512
			DC		+50*512,+50*512,+50*512
			DC		-50*512,+50*512,+50*512
			
			DC		-50*512,-50*512,-50*512
			DC		+50*512,-50*512,-50*512
			DC		+50*512,+50*512,-50*512
			DC		-50*512,+50*512,-50*512

GATO_FACES	DC		8,0,1,2,3,4,5,6,7,3,MAPPING4
			DC		8,15,14,13,12,11,10,9,8,3,MAPPING4
			DC		4,0,8,9,1,3,MAPPING2
			DC		4,9,10,2,1,3,MAPPING3
			DC		4,2,10,11,3,3,MAPPING2
			DC		4,11,12,4,3,3,MAPPING3
			DC		4,4,12,13,5,3,MAPPING2
			DC		4,13,14,6,5,3,MAPPING3
			DC		4,6,14,15,7,3,MAPPING2
			DC		4,15,8,0,7,3,MAPPING3

GATO_POINTS	DC		+80*512,+00*512,-13*512
			DC		+56*512,-56*512,-13*512
			DC		+00*512,-80*512,-13*512
			DC		-56*512,-56*512,-13*512
			DC		-80*512,+00*512,-13*512
			DC		-56*512,+56*512,-13*512
			DC		+00*512,+80*512,-13*512
			DC		+56*512,+56*512,-13*512

			DC		+54*512,+00*512,+13*512
			DC		+39*512,-39*512,+13*512
			DC		+00*512,-54*512,+13*512
			DC		-39*512,-39*512,+13*512
			DC		-54*512,+00*512,+13*512
			DC		-39*512,+39*512,+13*512
			DC		+00*512,+54*512,+13*512
			DC		+39*512,+39*512,+13*512

SPHERE_FACES	DC		7,1,43,49,55,61,67,37,3,MAPPING5
			DC		7,37,31,25,19,13,7,1,3,MAPPING11

			DC		4,1,7,8,2,3,MAPPING7
			DC		4,2,8,9,3,3,MAPPING8
			DC		4,3,9,10,4,3,MAPPING7
			DC		4,4,10,11,5,3,MAPPING8
			DC		4,5,11,12,6,3,MAPPING7
			DC		4,7,13,14,8,3,MAPPING9
			DC		4,8,14,15,9,3,MAPPING10
			DC		4,9,15,16,10,3,MAPPING9
			DC		4,10,16,17,11,3,MAPPING10
			DC		4,11,17,18,12,3,MAPPING9
			DC		4,13,19,20,14,3,MAPPING7
			DC		4,14,20,21,15,3,MAPPING8
			DC		4,15,21,22,16,3,MAPPING7
			DC		4,16,22,23,17,3,MAPPING8
			DC		4,17,23,24,18,3,MAPPING7
			DC		4,19,25,26,20,3,MAPPING9
			DC		4,20,26,27,21,3,MAPPING10
			DC		4,21,27,28,22,3,MAPPING9
			DC		4,22,28,29,23,3,MAPPING10
			DC		4,23,29,30,24,3,MAPPING9
			DC		4,25,31,32,26,3,MAPPING7
			DC		4,26,32,33,27,3,MAPPING8
			DC		4,27,33,34,28,3,MAPPING7
			DC		4,28,34,35,29,3,MAPPING8
			DC		4,29,35,36,30,3,MAPPING7
			DC		4,31,37,38,32,3,MAPPING9
			DC		4,32,38,39,33,3,MAPPING10
			DC		4,33,39,40,34,3,MAPPING9
			DC		4,34,40,41,35,3,MAPPING10
			DC		4,35,41,42,36,3,MAPPING9

			DC		4,43,1,2,44,3,MAPPING9
			DC		4,44,2,3,45,3,MAPPING10
			DC		4,45,3,4,46,3,MAPPING9
			DC		4,46,4,5,47,3,MAPPING10
			DC		4,47,5,6,48,3,MAPPING9
			DC		4,49,43,44,50,3,MAPPING7
			DC		4,50,44,45,51,3,MAPPING8
			DC		4,51,45,46,52,3,MAPPING7
			DC		4,52,46,47,53,3,MAPPING8
			DC		4,53,47,48,54,3,MAPPING7
			DC		4,55,49,50,56,3,MAPPING9
			DC		4,56,50,51,57,3,MAPPING10
			DC		4,57,51,52,58,3,MAPPING9
			DC		4,58,52,53,59,3,MAPPING10
			DC		4,59,53,54,60,3,MAPPING9
			DC		4,61,55,56,62,3,MAPPING7
			DC		4,62,56,57,63,3,MAPPING8
			DC		4,63,57,58,64,3,MAPPING7
			DC		4,64,58,59,65,3,MAPPING8
			DC		4,65,59,60,66,3,MAPPING7
			DC		4,67,61,62,68,3,MAPPING9
			DC		4,68,62,63,69,3,MAPPING10
			DC		4,69,63,64,70,3,MAPPING9
			DC		4,70,64,65,71,3,MAPPING10
			DC		4,71,65,66,72,3,MAPPING9
			DC		4,37,67,68,38,3,MAPPING7
			DC		4,38,68,69,39,3,MAPPING8
			DC		4,39,69,70,40,3,MAPPING7
			DC		4,40,70,71,41,3,MAPPING8
			DC		4,41,71,72,42,3,MAPPING7

			DC		7,74,79,84,89,94,99,104,3,MAPPING5
			DC		7,104,109,114,119,124,129,74,3,MAPPING11

			DC		4,75,80,79,74,3,MAPPING8
			DC		4,76,81,80,75,3,MAPPING7
			DC		4,77,82,81,76,3,MAPPING8
			DC		4,78,83,82,77,3,MAPPING7
			DC		4,6,12,83,78,3,MAPPING8
			DC		4,80,85,84,79,3,MAPPING10
			DC		4,81,86,85,80,3,MAPPING9
			DC		4,82,87,86,81,3,MAPPING10
			DC		4,83,88,87,82,3,MAPPING9
			DC		4,12,18,88,83,3,MAPPING10
			DC		4,85,90,89,84,3,MAPPING8
			DC		4,86,91,90,85,3,MAPPING7
			DC		4,87,92,91,86,3,MAPPING8
			DC		4,88,93,92,87,3,MAPPING7
			DC		4,18,24,93,88,3,MAPPING8
			DC		4,90,95,94,89,3,MAPPING10
			DC		4,91,96,95,90,3,MAPPING9
			DC		4,92,97,96,91,3,MAPPING10
			DC		4,93,98,97,92,3,MAPPING9
			DC		4,24,30,98,93,3,MAPPING10
			DC		4,95,100,99,94,3,MAPPING8
			DC		4,96,101,100,95,3,MAPPING7
			DC		4,97,102,101,96,3,MAPPING8
			DC		4,98,103,102,97,3,MAPPING7
			DC		4,30,36,103,98,3,MAPPING8
			DC		4,100,105,104,99,3,MAPPING10
			DC		4,101,106,105,100,3,MAPPING9
			DC		4,102,107,106,101,3,MAPPING10
			DC		4,103,108,107,102,3,MAPPING9
			DC		4,36,42,108,103,3,MAPPING10

			DC		4,105,110,109,104,3,MAPPING8
			DC		4,106,111,110,105,3,MAPPING7
			DC		4,107,112,111,106,3,MAPPING8
			DC		4,108,113,112,107,3,MAPPING7
			DC		4,42,72,113,108,3,MAPPING8
			DC		4,110,115,114,109,3,MAPPING10
			DC		4,111,116,115,110,3,MAPPING9
			DC		4,112,117,116,111,3,MAPPING10
			DC		4,113,118,117,112,3,MAPPING9
			DC		4,72,66,118,113,3,MAPPING10
			DC		4,115,120,119,114,3,MAPPING8
			DC		4,116,121,120,115,3,MAPPING7
			DC		4,117,122,121,116,3,MAPPING8
			DC		4,118,123,122,117,3,MAPPING7
			DC		4,66,60,123,118,3,MAPPING8
			DC		4,120,125,124,119,3,MAPPING10
			DC		4,121,126,125,120,3,MAPPING9
			DC		4,122,127,126,121,3,MAPPING10
			DC		4,123,128,127,122,3,MAPPING9
			DC		4,60,54,128,123,3,MAPPING10
			DC		4,125,130,129,124,3,MAPPING8
			DC		4,126,131,130,125,3,MAPPING7
			DC		4,127,132,131,126,3,MAPPING8
			DC		4,128,133,132,127,3,MAPPING7
			DC		4,54,48,133,128,3,MAPPING8
			DC		4,130,75,74,129,3,MAPPING10
			DC		4,131,76,75,130,3,MAPPING9
			DC		4,132,77,76,131,3,MAPPING10
			DC		4,133,78,77,132,3,MAPPING9
			DC		4,48,6,78,133,3,MAPPING10


SPHERE_POINTS	DC		00*1*512,40*1*512,00*1*512
			DC		10*1*512,39*1*512,00*1*512
			DC		20*1*512,35*1*512,00*1*512
			DC		28*1*512,28*1*512,00*1*512
			DC		35*1*512,20*1*512,00*1*512
			DC		39*1*512,10*1*512,00*1*512
			DC		40*1*512,00*1*512,00*1*512
			DC		09*1*512,39*1*512,05*1*512
			DC		17*1*512,35*1*512,10*1*512
			DC		25*1*512,28*1*512,14*1*512
			DC		30*1*512,20*1*512,17*1*512
			DC		33*1*512,10*1*512,20*1*512
			DC		35*1*512,00*1*512,20*1*512
			DC		05*1*512,39*1*512,09*1*512
			DC		10*1*512,35*1*512,17*1*512
			DC		14*1*512,28*1*512,25*1*512
			DC		17*1*512,20*1*512,30*1*512
			DC		19*1*512,10*1*512,33*1*512
			DC		20*1*512,00*1*512,35*1*512
			DC		00*1*512,39*1*512,10*1*512
			DC		00*1*512,35*1*512,20*1*512
			DC		00*1*512,28*1*512,28*1*512
			DC		00*1*512,20*1*512,35*1*512
			DC		00*1*512,10*1*512,39*1*512
			DC		00*1*512,00*1*512,40*1*512
			DC		-5*1*512,39*1*512,09*1*512
			DC		-10*1*512,35*1*512,17*1*512
			DC		-14*1*512,28*1*512,25*1*512
			DC		-17*1*512,20*1*512,30*1*512
			DC		-19*1*512,10*1*512,33*1*512
			DC		-20*1*512,0*1*512,35*1*512
			DC		-9*1*512,39*1*512,5*1*512
			DC		-17*1*512,35*1*512,10*1*512
			DC		-25*1*512,28*1*512,14*1*512
			DC		-30*1*512,20*1*512,17*1*512
			DC		-33*1*512,10*1*512,20*1*512
			DC		-35*1*512,0*1*512,20*1*512
			DC		-10*1*512,39*1*512,0*1*512
			DC		-20*1*512,35*1*512,0*1*512
			DC		-28*1*512,28*1*512,0*1*512
			DC		-35*1*512,20*1*512,0*1*512
			DC		-39*1*512,10*1*512,0*1*512
			DC		-40*1*512,-0*1*512,0*1*512
			DC		9*1*512,39*1*512,-5*1*512
			DC		17*1*512,35*1*512,-10*1*512
			DC		25*1*512,28*1*512,-14*1*512
			DC		30*1*512,20*1*512,-17*1*512
			DC		33*1*512,10*1*512,-20*1*512
			DC		35*1*512,0*1*512,-20*1*512
			DC		5*1*512,39*1*512,-9*1*512
			DC		10*1*512,35*1*512,-17*1*512
			DC		14*1*512,28*1*512,-25*1*512
			DC		17*1*512,20*1*512,-30*1*512
			DC		19*1*512,10*1*512,-33*1*512
			DC		20*1*512,0*1*512,-35*1*512
			DC		0*1*512,39*1*512,-10*1*512
			DC		0*1*512,35*1*512,-20*1*512
			DC		0*1*512,28*1*512,-28*1*512
			DC		0*1*512,20*1*512,-35*1*512
			DC		0*1*512,10*1*512,-39*1*512
			DC		0*1*512,0*1*512,-40*1*512
			DC		-5*1*512,39*1*512,-9*1*512
			DC		-10*1*512,35*1*512,-17*1*512
			DC		-14*1*512,28*1*512,-25*1*512
			DC		-17*1*512,20*1*512,-30*1*512
			DC		-20*1*512,10*1*512,-33*1*512
			DC		-20*1*512,0*1*512,-35*1*512
			DC		-9*1*512,39*1*512,-5*1*512
			DC		-17*1*512,35*1*512,-10*1*512
			DC		-25*1*512,28*1*512,-14*1*512
			DC		-30*1*512,20*1*512,-17*1*512
			DC		-33*1*512,10*1*512,-20*1*512
			DC		-35*1*512,0*1*512,-20*1*512
			DC		00*1*512,-40*1*512,00*1*512
			DC		10*1*512,-39*1*512,00*1*512
			DC		20*1*512,-35*1*512,00*1*512
			DC		28*1*512,-28*1*512,00*1*512
			DC		35*1*512,-20*1*512,00*1*512
			DC		39*1*512,-10*1*512,00*1*512
			DC		09*1*512,-39*1*512,05*1*512
			DC		17*1*512,-35*1*512,10*1*512
			DC		25*1*512,-28*1*512,14*1*512
			DC		30*1*512,-20*1*512,17*1*512
			DC		33*1*512,-10*1*512,20*1*512
			DC		05*1*512,-39*1*512,09*1*512
			DC		10*1*512,-35*1*512,17*1*512
			DC		14*1*512,-28*1*512,25*1*512
			DC		17*1*512,-20*1*512,30*1*512
			DC		19*1*512,-10*1*512,33*1*512
			DC		00*1*512,-39*1*512,10*1*512
			DC		00*1*512,-35*1*512,20*1*512
			DC		00*1*512,-28*1*512,28*1*512
			DC		00*1*512,-20*1*512,35*1*512
			DC		00*1*512,-10*1*512,39*1*512
			DC		-5*1*512,-39*1*512,09*1*512
			DC		-10*1*512,-35*1*512,17*1*512
			DC		-14*1*512,-28*1*512,25*1*512
			DC		-17*1*512,-20*1*512,30*1*512
			DC		-19*1*512,-10*1*512,33*1*512
			DC		-9*1*512,-39*1*512,5*1*512
			DC		-17*1*512,-35*1*512,10*1*512
			DC		-25*1*512,-28*1*512,14*1*512
			DC		-30*1*512,-20*1*512,17*1*512
			DC		-33*1*512,-10*1*512,20*1*512
			DC		-10*1*512,-39*1*512,0*1*512
			DC		-20*1*512,-35*1*512,0*1*512
			DC		-28*1*512,-28*1*512,0*1*512
			DC		-35*1*512,-20*1*512,0*1*512
			DC		-39*1*512,-10*1*512,0*1*512
			DC		-9*1*512,-39*1*512,-5*1*512
			DC		-17*1*512,-35*1*512,-10*1*512
			DC		-25*1*512,-28*1*512,-14*1*512
			DC		-30*1*512,-20*1*512,-17*1*512
			DC		-33*1*512,-10*1*512,-20*1*512
			DC		-5*1*512,-39*1*512,-9*1*512
			DC		-10*1*512,-35*1*512,-17*1*512
			DC		-14*1*512,-28*1*512,-25*1*512
			DC		-17*1*512,-20*1*512,-30*1*512
			DC		-20*1*512,-10*1*512,-33*1*512
			DC		0*1*512,-39*1*512,-10*1*512
			DC		0*1*512,-35*1*512,-20*1*512
			DC		0*1*512,-28*1*512,-28*1*512
			DC		0*1*512,-20*1*512,-35*1*512
			DC		0*1*512,-10*1*512,-39*1*512
			DC		5*1*512,-39*1*512,-9*1*512
			DC		10*1*512,-35*1*512,-17*1*512
			DC		14*1*512,-28*1*512,-25*1*512
			DC		17*1*512,-20*1*512,-30*1*512
			DC		19*1*512,-10*1*512,-33*1*512
			DC		9*1*512,-39*1*512,-5*1*512
			DC		17*1*512,-35*1*512,-10*1*512
			DC		25*1*512,-28*1*512,-14*1*512
			DC		30*1*512,-20*1*512,-17*1*512
			DC		33*1*512,-10*1*512,-20*1*512


TETRAEDRE_POINTS
			DC		0*512,0*512,+80*512
			DC		80*512,0*512,-40*512
			DC		-40*512,70*512,-40*512
			DC		-40*512,-70*512,-40*512

TETRAEDRE_FACES
			DC		3,0,1,2,3,MAPPING6
			DC		3,0,2,3,3,MAPPING6
			DC		3,0,3,1,3,MAPPING6
			DC		3,1,3,2,3,MAPPING6

BOUZOU_POINTS	DC		40*512,0*512,55*512
			DC		-20*512,35*512,55*512
			DC		-20*512,-35*512,55*512

			DC		40*512,0*512,-55*512
			DC		-20*512,35*512,-55*512
			DC		-20*512,-35*512,-55*512

			DC		70*512,0*512,0*512
			DC		35*512,61*512,0*512
			DC		-35*512,61*512,0*512
			DC		-70*512,0*512,0*512
			DC		-35*512,-61*512,0*512
			DC		35*512,-61*512,0*512

BOUZOU_FACES	DC		3,0,1,2,3,MAPPING6
			DC		3,5,4,3,3,MAPPING6

			DC		3,0,2,11,3,MAPPING6
			DC		3,0,11,6,3,MAPPING6
			DC		3,0,6,7,3,MAPPING6
			DC		3,1,0,7,3,MAPPING6
			DC		3,1,7,8,3,MAPPING6
			DC		3,1,8,9,3,MAPPING6
			DC		3,2,1,9,3,MAPPING6
			DC		3,2,9,10,3,MAPPING6
			DC		3,2,10,11,3,MAPPING6

			DC		3,3,11,5,3,MAPPING6
			DC		3,3,6,11,3,MAPPING6
			DC		3,3,7,6,3,MAPPING6
			DC		3,4,7,3,3,MAPPING6
			DC		3,4,8,7,3,MAPPING6
			DC		3,4,9,8,3,MAPPING6
			DC		3,5,9,4,3,MAPPING6
			DC		3,5,10,9,3,MAPPING6
			DC		3,5,11,10,3,MAPPING6

; Adresse de l'image
; Offset entre deux lignes
; Coordonn‚es de points dans l'image

MAPPING1		DC		IMAGE1,80/2,1*987,1*987,79*987,1*987,79*987,79*987,1*987,79*987
MAPPING2		DC		IMAGE2+16384,80/2,1*987,1*987,79*987,1*987,79*987,79*987,1*987,79*987
MAPPING3		DC		IMAGE3+16384,80/2,1*987,1*987,79*987,1*987,79*987,79*987,1*987,79*987
MAPPING4		DC		IMAGE1,80/2,79*987,39*987,(39+27)*987,(39+27)*987
			DC		39*987,79*987,(39-27)*987,(39+27)*987,1*987,39*987
			DC		(39-27)*987,(39-27)*987,39*987,1*987,(39+27)*987,(39-27)*987

MAPPING5		DC		IMAGE2+16384,140/2,69*987,57*987,59*987,53*987,35*987,44*987
			DC		1*987,29*987,35*987,25*987,60*987,15*987,69*987,1*987
MAPPING11		DC		IMAGE2+16384,140/2,69*987,1*987,78*987,15*987,105*987,25*987
			DC		139*987,29*987,105*987,44*987,78*987,53*987,39*987,57*987

MAPPING6		DC		IMAGE1,80/2,39*987,1*987,79*987,79*987,1*987,79*987

MAPPING7		DC		IMAGE2+16384,140/2,1*987,1*987,69*987,1*987,69*987,28*987,1*987,28*987
MAPPING8		DC		IMAGE2+16384,140/2,1*987,29*987,69*987,29*987,69*987,57*987,1*987,57*987
MAPPING9		DC		IMAGE2+16384,140/2,70*987,1*987,139*987,1*987,139*987,28*987,70*987,28*987
MAPPING10		DC		IMAGE2+16384,140/2,70*987,29*987,139*987,29*987,139*987,57*987,70*987,57*987

; Encore une Nimage

IMAGE1		DS		80*80

INVBEG		DS		300
INVTAB		DS		1
			DS		2700

End_Y

SINTAB		DS		90
COSTAB		DS		360

			END
