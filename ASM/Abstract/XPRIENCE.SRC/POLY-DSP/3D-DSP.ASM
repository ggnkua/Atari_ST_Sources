;***********************************************************************
;***********										 ***********
;***********										 ***********
;***********	 3D Plein,Gouraud Shading et Mapp‚e au DSP	 ***********
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
		DO		#<2001,Get_Inv_Table

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

;
; Boucle principale
;

Loop		jclr		#<HRDF,X:<<HSR,Loop
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
		move		#INTENSITES,r3
		move		#LIGHTS,r4
		move		Y:(r0)+,n0
		move		r0,r5
		Do		n0,Scan_Points

		move		Y:(r0),n1
		move		Y:(r0)+,n3
		move		X:(r1+n1),x0
		move		x0,X:(r2)
		move		Y:(r1+n1),x0
		move		x0,Y:(r2)+
		move		X:(r3+n3),x0
		move		x0,X:(r4)+
Scan_Points
		move		Y:(r5),n3
		move		Y:(r5),n1
		move		X:(r3+n3),x0
		move		x0,X:(r4)
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
		jeq		<Polygone_Rout
		cmp		x0,b
		jeq		<Gouraud_Rout
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

		lua		(r6)+n6,r6
		move		X:(r2),x0
		move		Y:(r2)+,y0	x0,X:(r6)
		move		X:(r3),x0		y0,Y:(r6)
		move		Y:(r3)+,y0
		move		x0,X:(r5+n5)
		move		y0,Y:(r5+n5)
		jmp		<M_Fill_Next

M_Fill_Horiz_1
		move		a,X:(r6+n6)			; XMin = X2
		move		x0,X:(r5+n5)			; XMax = X1
		move		#XDEP,r6
		move		#XARR,r5

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

;
; Routine de Gouraud Shading
;

Gouraud_Rout
		jclr		#<HTDE,X:<<HSR,Gouraud_Rout
		movep	#2,X:<<HTX

		move		Y:(r0),x0
		move		x0,X:<Colors_Adress

		move		#LIGHTS,r2
		move		#PTS_SCR,r0
		lua		(r2)+,r3					; Pointe sur
		lua		(r0)+,r1					; Points suivants
		clr		a			#>199,x0		; Initialise
		move		x0,X:<YMin				; YMin … 199
		move		a,X:<YMax					; YMax … 0


; Boucle de trac‚ virtuel dans les tableaux
; des segments qui composent le polygone … l'‚cran
; et calcul des intensit‚s de d‚part/arriv‚e

		Do		n0,G_Virtual_Tracing


		move		X:<YMin,x0				; YMin
		move		Y:(r0),b					; Y1
		cmp		x0,b			X:<YMax,y0	; YMax
		jge		<G_No_YMin				; si Y1 < YMin
		move		b,X:<YMin					; c'est le nouveau YMin
G_No_YMin	cmp		y0,b			X:(r0)+,x0	; X1
		jle		<G_No_YMax				; si Y1 > YMax
		move		b,X:<YMax					; c'est le nouveau YMax
G_No_YMax

		move		#XMAX,r5					; Remplis XMax par d‚faut

		move		b,y0						; Y1
		move		X:(r1),a					; X2
		sub		x0,a			Y:(r1)+,b		; Calc dX	,Y2
		sub		y0,b			y0,n5		; dY
		jeq		<G_Fill_Horiz
		jpl		<G_Fill_XMax


G_Fill_Xmin
		move		r0,r4					; On monte, inverse
		move		#XMIN,r5					; tout et remplis XMin
		move		X:(r4),x0					; X2
		move		Y:(r4)-,y0				; Y2
		move		X:(r4),a					; X1
		sub		x0,a			Y:(r4),b		; Calc dX	,Y1
		sub		y0,b			y0,n5		; dY

		jsr		<G_Calcule_Pente

		move		X:(r2)+,a					; Light Arr
		move		X:(r3)+,x0				; Light Dep
		sub		x0,a						; Calc diff Light

		jmp		<G_Fill_Continue

G_Fill_XMax
		jsr		<G_Calcule_Pente

		move		X:(r3)+,a					; Light Arr
		move		X:(r2)+,x0				; Light Dep
		sub		x0,a						; Calc diff Light

G_Fill_Continue
		move		x0,b						; Depart Light

		move		a,x0						; dLight
		mpy		x0,x1,a					; * 1/Nb Pixels
		move		a0,y0					; = Increment Light
		move		a1,y1

		move		X:<Dep_X,a
		move		L:<Pente,x

		Do		n4,G_Fill_Tabs

		add		x,a			a,X:(r5)		; Sauve et Calcule X
		add		y,b			b,Y:(r5)+		; Sauve et Calcule Light
G_Fill_Tabs
		move		a,X:(r5)
		move		b,Y:(r5)

G_Fill_Next
		nop

G_Virtual_Tracing

; Maintenant que les tableaux sont remplis
; on les parcourt de YMin … YMax, on recueille les infos

		move		X:<YMin,b					; Premiere Ligne
		tst		b			#>199,x1
		jpl		<G_YMin_Ok
		clr		b
G_YMin_Ok	move		X:<YMax,a					; Derniere Ligne
		cmp		x1,a			b,x0
		jlt		<G_YMax_Ok
		move		x1,a
G_YMax_Ok	move		b,X:<YMin
		move		a,X:<YMax
		sub		x0,a			#>1,y0
		add		y0,a			X:<Screen_Adress,b0	; Nombre de Lignes

G_Send_Nb_Lines
		jclr		#<HTDE,X:<<HSR,G_Send_Nb_Lines
		movep	a,X:<<HTX
		move		a,n7

		move		Y:<Off7_Scr,y0				; Calcule offset
		mpy		x0,y0,a		X:<Colors_Adress,r3	; premiere ligne
		asr		a			#INVTAB,r2	; et adresse
		add		a,b			#>XMIN,a		; sur l'ecran
		move		b0,Y:<Adr_Scr

		add		x0,a			#>XMAX,b		; Pointe sur la
		add		x0,b			a,r0			; la premiere
		move		b,r1						; dans les tableaux


		Do		n7,Gouraud_Lines_Loop

		move		X:(r1),a					; XMax
		move		X:(r0),x0					; - XMin
 		sub		x0,a			#>1,y0
		jmi		<G_No_Pixels
		add		y0,a						; = Nombre de Pixels
		move		a,n2

		move		Y:(r1),b					; Light Arrivee * 987
		move		Y:(r0),y1					; - Light Depart * 987
		sub		y1,b			Y:(r2+n2),x1	; = diff‚rence Light * 987
		move		b,x0
		mpy		x0,x1,a		#>$800000/987,x1
		move		a,x0						; Increment * 987
		mpy		x0,x1,a
		move		a,L:<Incr_Light			; Increment
		mpy		y1,x1,a		X:(r0)+,b

		tst		b			a,L:<Dep_Light
		jpl		<G_XMin_Ok
		move		b,x1
		mpy		-x0,x1,a		#>$800000/987/2,x1
		move		a0,x0
		mpy		x0,x1,a		L:<Dep_Light,y		; Light suppl‚mentaire
		add		y,a
		clr		b			a,L:<Dep_Light		; Light Depart Clippee

G_XMin_Ok	move		#>319,x1
		move		X:(r1)+,a					; XMax
		cmp		x1,a
		jlt		<G_XMax_Ok
		move		x1,a

G_XMax_Ok	sub		b,a			#>1,x0
		jmi		<G_No_Pixels
		add		x0,a						; = Nombre de Pixels
		move		a,n2

G_Send_Nb_Pixels
		jclr		#<HTDE,X:<<HSR,G_Send_Nb_Pixels
		movep	n2,X:<<HTX

		move		Y:<Adr_Scr,a				; Offset X Ecran
		addl		a,b						; Adresse Ecran

G_Send_Adress_X
		jclr		#<HTDE,X:<<HSR,G_Send_Adress_X
		movep	b,X:<<HTX

		move		L:<Incr_Light,x			; Increment Light
		move		L:<Dep_Light,a				; Light Depart

		Do		n2,Gouraud_Line_Loop

		add		x,a			a,n3
G_Send_Pixel
		jclr		#<HTDE,X:<<HSR,G_Send_Pixel
		movep	Y:(r3+n3),X:<<HTX
Gouraud_Line_Loop

Gouraud_Next_Line
		move		Y:<Adr_Scr,a
		move		Y:<Off7_Scr,x0
		add		x0,a
		move		a,Y:<Adr_Scr

Gouraud_Lines_Loop
		jmp		<Showed_Face

G_No_Pixels
		jclr		#<HTDE,X:<<HSR,G_No_Pixels
		movep	#0,X:<<HTX
		jmp		<Gouraud_Next_Line


; Calcule l'incr‚ment de X … chaque ligne = la pente du segment

G_Calcule_Pente
		move		x0,X:<Dep_X				; X de d‚part
		move		b,n4						; Nombre de lignes
		move		#INVTAB,r4

		move		a,x0						; dX
		move		Y:(r4+n4),x1				; 1 / dY
		mpy		x0,x1,a		(r5)+n5		; dX / dY
		move		a,L:<Pente				; = Pente
		rts

; Cas d'un Segment Horizontal

G_Fill_Horiz
		add		x0,a		#XMIN,r6
		cmp		x0,a		n5,n6		; X2 < X1 ??
		jlt		<G_Fill_Horiz_1		; Oui

		move		x0,X:(r6+n6)			; XMin = X1
		move		a,X:(r5+n5)			; XMax = X2
		move		X:(r2)+,x0
		move		x0,Y:(r6+n6)
		move		X:(r3)+,x0
		move		x0,Y:(r5+n5)
		jmp		<G_Fill_Next

G_Fill_Horiz_1
		move		a,X:(r6+n6)			; XMin = X2
		move		x0,X:(r5+n5)			; XMax = X1
		move		X:(r3)+,x0
		move		x0,Y:(r6+n6)
		move		X:(r2)+,x0
		move		x0,Y:(r5+n5)
		jmp		<G_Fill_Next

;
; Routine de Polygone
;

Polygone_Rout
		jclr		#<HTDE,X:<<HSR,Polygone_Rout
		movep	#1,X:<<HTX

P_Send_Color
		jclr		#<HTDE,X:<<HSR,P_Send_Color
		movep	Y:(r0),X:<<HTX

		move		#PTS_SCR,r0
		clr		a			#>199,x0		; Initialise
		move		x0,X:<YMin				; YMin … 199
		move		a,X:<YMax					; YMax … 0
		lua		(r0)+,r1					; Pointe sur pt suivant


; Boucle de trac‚ virtuel dans les tableaux
; des segments qui composent le polygone … l'‚cran

		Do		n0,P_Virtual_Tracing


		move		X:<YMin,x0				; YMin
		move		Y:(r0),b					; Y1
		cmp		x0,b			X:<YMax,y0	; YMax
		jge		<P_No_YMin				; si Y1 < YMin
		move		b,X:<YMin					; c'est le nouveau YMin
P_No_YMin	cmp		y0,b			X:(r0)+,x0	; X1
		jle		<P_No_YMax				; si Y1 > YMax
		move		b,X:<YMax					; c'est le nouveau YMax
P_No_YMax

		move		#XMAX,r5					; Remplis XMax par d‚faut

		move		b,y0						; Y1
		move		X:(r1),a					; X2
		sub		x0,a			Y:(r1)+,b		; Calc dX	,Y2
		sub		y0,b			y0,n5		; dY
		jeq		<P_Fill_Horiz
		jpl		<P_Fill_XMax


P_Fill_Xmin
		move		r0,r4					; On monte, inverse
		move		#XMIN,r5					; tout et remplis XMin
		move		X:(r4),x0					; X2
		move		Y:(r4)-,y0				; Y2
		move		X:(r4),a					; X1
		sub		x0,a			Y:(r4),b		; Calc dX	,Y1
		sub		y0,b			y0,n5		; dY

P_Fill_XMax
		move		b,n4						; Nombre de lignes
		move		#INVTAB,r4

		move		x0,b						; X de d‚part

		move		a,x0						; dX
		move		Y:(r4+n4),x1				; 1 / dY
		mpy		x0,x1,a		(r5)+n5		; dX / dY = Pente

		Do		n4,P_Fill_Tabs

		add		a,b			b,X:(r5)+		; Sauve et Calcule X
P_Fill_Tabs
		move		b,X:(r5)

P_Fill_Next
		nop

P_Virtual_Tracing

; Maintenant que les tableaux sont remplis
; on les parcourt de YMin … YMax, on recueille les infos

		move		X:<YMin,b					; Premiere Ligne
		tst		b			#>199,x1
		jpl		<P_YMin_Ok
		clr		b
P_YMin_Ok	move		X:<YMax,a					; Derniere Ligne
		cmp		x1,a			b,x0
		jlt		<P_YMax_Ok
		move		x1,a
P_YMax_Ok	move		b,X:<YMin
		move		a,X:<YMax
		sub		x0,a			#>1,y0
		add		y0,a			X:<Screen_Adress,b0	; Nombre de Lignes

P_Send_Nb_Lines
		jclr		#<HTDE,X:<<HSR,P_Send_Nb_Lines
		movep	a,X:<<HTX
		move		a,n7

		move		Y:<Off7_Scr,y0				; Calcule offset
		mpy		x0,y0,a		X:<Colors_Adress,r3	; premiere ligne
		asr		a			#INVTAB,r2	; et adresse
		add		a,b			#>XMIN,a		; sur l'ecran
		move		b0,Y:<Adr_Scr

		add		x0,a			#>XMAX,b		; Pointe sur la
		add		x0,b			a,r0			; la premiere
		move		b,r1						; dans les tableaux


		move		Y:<Adr_Scr,b				; Adresse Ecran
		move		Y:<Off7_Scr,y0				; Offset entre 2 lignes

		move		#>319,x1
		move		#>1,y1

		Do		n7,Polygone_Lines_Loop

		move		X:(r0)+,a					; XMin
		tst		a			a,x0
		jpl		<P_XMin_Ok
		move		#<0,x0					; Clip Gauche

P_XMin_Ok	move		X:(r1)+,a					; XMax
		cmp		x1,a
		jle		<P_XMax_Ok
		move		x1,a						; Clip Droit
P_XMax_Ok

 		sub		x0,a						; = Nombre de Pixels
		jmi		<P_No_Pixels
		add		y1,a						; + 1

P_Send_Nb_Pixels
		jclr		#<HTDE,X:<<HSR,P_Send_Nb_Pixels
		movep	a,X:<<HTX

		move		x0,a						; X de d‚part
		addl		b,a						; Adresse Ecran

P_Send_Adress
		jclr		#<HTDE,X:<<HSR,P_Send_Adress
		movep	a,X:<<HTX

Polygone_Next_Line
		add		y0,b						; Ligne suivante

Polygone_Lines_Loop
		jmp		<Showed_Face

P_No_Pixels
		jclr		#<HTDE,X:<<HSR,P_No_Pixels
		movep	#0,X:<<HTX
		jmp		<Polygone_Next_Line

; Cas d'un Segment Horizontal

P_Fill_Horiz
		add		x0,a		#XMIN,r6
		cmp		x0,a		n5,n6		; X2 < X1 ??
		jlt		<P_Fill_Horiz_1		; Oui

		move		x0,X:(r6+n6)			; XMin = X1
		move		a,X:(r5+n5)			; XMax = X2
		jmp		<P_Fill_Next

P_Fill_Horiz_1
		move		a,X:(r6+n6)			; XMin = X2
		move		x0,X:(r5+n5)			; XMax = X1
		jmp		<P_Fill_Next


; Efface le buffer contenant la somme des polygones
; pour effacement par bandes

Clear_Buffer
		clr		a		#>319,x0
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

		move		X:(r0),n2				; Offset pour cos X dans la table sinus
		move		X:(r0)+,n5
		lua		(r2)+n2,r2			; Cos a
		lua		(r5)+n5,r5			; Sin a
		move		X:(r0)+,x0
		move		x0,n3
		move		x0,n6
		lua		(r3)+n3,r3			; Cos b
		lua		(r6)+n6,r6			; Sin b

		move		X:(r0)+,a
		sub		x0,a			#<2,n0
		move		a,n3					; Cos c
		move		a,n6					; Sin c

		move		X:(r0+n0),a			; Trans Z
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

 		move		X:(r0)+,a				; Trans X
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

		move		X:(r0)+,a				; Trans Y
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
		move		#INTENSITES,r3
		move		#INVTAB,r5
		move		Y:<Z_Ptf,n5
		move		#<11,n0
		lua		(r5)+n5,r6
		Do		X:<Nb_Points,Calculate_3D_Points

		move		X:(r0)+,a
		move		X:(r0)+,x0	Y:(r4)+,y0
		mpy		x0,y0,b		X:(r0)+,x0	Y:(r4)+,y1
		mac		x0,y1,b		X:(r0)+,x0	Y:(r4)-,y1
		macr		x0,y1,b		Y:<Coeff_Light,y1

		move		b,x0
		mpy		x0,y1,b		Y:(r6),y1
		move		b,X:(r3)+
		add		x0,a			X:(r0)+,b
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
Colors_Adress	DS		1
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

			org		L:13

Pente		DS		1
Pos_IX		DS		1
Pos_IY		DS		1
Incr_IX		DS		1
Incr_IY		DS		1
Dep_Light		DS		1
Incr_Light	DS		1

			org		X:20

BANDES1		DS		200
BANDES2		DS		200

Matrice		DS		12
Rotations		DS		3
Translations	DS		3

			org		Y:20

			DS		200
			DS		200

			org		X:End_Code

PTS_PROJ		DS		35
INTENSITES	DS		35

PTS_SCR		DS		12
PTS_IMG		DS		12
LIGHTS		DS		12

			DS		50
XMIN			DS		250
XMAX			DS		250
XDEP			DS		250
XARR			DS		250

; Tableaux pour effacage par bandes

BANDES0		DS		200

			org		Y:End_Code

			DS		35
			DS		35
			DS		12
			DS		12
			DS		12

			DS		50
LIGHTDEP		DS		250
LIGHTARR		DS		250
YDEP			DS		250
YARR			DS		250

			DS		200

; Description des objets
; Adresse des points, nombre de points
; Adresse des faces, nombre de faces
; Coefficient pour le Gouraud Shading [rapport Intensit‚ / Profondeur (Z)]

OBJETS		DC		CUBE_POINTS,8,CUBE_FACES,6,$800000*987/1400
			DC		OBJ_POINTS,16,OBJ_FACES2,10,$800000*987/1400
			DC		OBJ_POINTS,16,OBJ_FACES3,10,$800000*987/1400
			DC		SPACE_POINTS,12,SPACE_FACES,15,$800000*987/1400

; Description des Faces
; Nombre de Points
; Liste des num‚ros de Point
; Type de polygone :	1 = Normal	Couleur
;					2 = Gouraud	Infos Adresse Couleurs
;					3 = Mapping	Infos Adresse Image + Coordonn‚es

CUBE_FACES	DC		4,0,1,2,3,2,GOURAUD0
			DC		4,7,6,5,4,2,GOURAUD0
			DC		4,1,5,6,2,2,GOURAUD0
			DC		4,0,3,7,4,2,GOURAUD0
			DC		4,0,4,5,1,2,GOURAUD0
			DC		4,3,2,6,7,2,GOURAUD0

CUBE_POINTS	DC		-50*512,-50*512,+50*512
			DC		+50*512,-50*512,+50*512
			DC		+50*512,+50*512,+50*512
			DC		-50*512,+50*512,+50*512
			
			DC		-50*512,-50*512,-50*512
			DC		+50*512,-50*512,-50*512
			DC		+50*512,+50*512,-50*512
			DC		-50*512,+50*512,-50*512

OBJ_FACES2	DC		8,0,1,2,3,4,5,6,7,2,GOURAUD0
			DC		8,15,14,13,12,11,10,9,8,2,GOURAUD0
			DC		4,1,0,8,9,2,GOURAUD0
			DC		4,2,1,9,10,2,GOURAUD0
			DC		4,3,2,10,11,2,GOURAUD0
			DC		4,4,3,11,12,2,GOURAUD0
			DC		4,5,4,12,13,2,GOURAUD0
			DC		4,6,5,13,14,2,GOURAUD0
			DC		4,7,6,14,15,2,GOURAUD0
			DC		4,0,7,15,8,2,GOURAUD0

OBJ_FACES3	DC		8,0,1,2,3,4,5,6,7,3,MAPPING2
			DC		8,15,14,13,12,11,10,9,8,3,MAPPING2
			DC		4,1,0,8,9,3,MAPPING1
			DC		4,2,1,9,10,3,MAPPING1
			DC		4,3,2,10,11,3,MAPPING1
			DC		4,4,3,11,12,3,MAPPING1
			DC		4,5,4,12,13,3,MAPPING1
			DC		4,6,5,13,14,3,MAPPING1
			DC		4,7,6,14,15,3,MAPPING1
			DC		4,0,7,15,8,3,MAPPING1

OBJ_POINTS	DC		+80*512,+00*512,-13*512
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

SPACE_POINTS	DC		-10*512,-30*512,0*512
			DC		10*512,-30*512,0*512
			DC		30*512,10*512,0*512
			DC		20*512,30*512,0*512
			DC		-20*512,30*512,0*512
			DC		-30*512,10*512,0*512
			DC		-10*512,10*512,20*512
			DC		10*512,10*512,20*512

			DC		20*512,30*512,-10*512
			DC		-20*512,30*512,-10*512
			DC		-10*512,10*512,-20*512
			DC		10*512,10*512,-20*512

SPACE_FACES	DC		4,0,1,7,6,2,GOURAUD0		; Vitre

			DC		3,1,2,7,2,GOURAUD0			; Aile Droite
			DC		3,0,6,5,2,GOURAUD0			; Aile Gauche
			DC		3,7,2,3,2,GOURAUD0			; Arriere Droit
			DC		3,5,6,4,2,GOURAUD0			; Arriere Gauche
			DC		4,3,4,6,7,2,GOURAUD0		; Arriere Haut

			DC		4,11,10,0,1,2,GOURAUD0
			DC		3,11,2,1,2,GOURAUD0
			DC		3,10,5,0,2,GOURAUD0
			DC		3,11,3,2,2,GOURAUD0
			DC		3,10,5,4,2,GOURAUD0
			DC		4,11,10,9,8,2,GOURAUD0
			DC		4,4,3,8,9,2,GOURAUD0
			DC		3,3,2,8,2,GOURAUD0
			DC		3,9,5,4,2,GOURAUD0

; Adresse de l'image
; Offset entre deux lignes
; Coordonn‚es de points dans l'image

MAPPING1		DC		IMAGE1,80/2,0*987,0*987,79*987,0*987,79*987,79*987,0*987,79*987
MAPPING2		DC		IMAGE1,80/2,78*987,39*987,(39+27)*987,(39+27)*987
			DC		39*987,78*987,(39-27)*987,(39+27)*987,0*987,39*987
			DC		(39-27)*987,(39-27)*987,39*987,0*987,(39+27)*987,(39-27)*987

; Une zolie Nimage

IMAGE1		DS		80*80

; Table de Couleurs pour le Gouraud

			DC		0*2049,1*2049,2*2049,3*2049,4*2049,5*2049
			DC		6*2049,7*2049,8*2049,9*2049,10*2049,11*2049
			DC		12*2049,13*2049,14*2049,15*2049,16*2049
			DC		17*2049,18*2049,19*2049,20*2049,21*2049,22*2049
			DC		23*2049+01*65,24*2049+02*64,25*2049+03*64
GOURAUD0		DC		26*2049+04*64,27*2049+05*64,28*2049+06*64
			DC		29*2049+07*64,30*2049+08*64,31*2049+09*64
			DC		63519+10*64,63519+11*64,63519+12*64
			DC		63519+13*64,63519+14*64,63519+15*64
			DC		63519+16*64,63519+17*64,63519+18*64
			DC		63519+19*64,63519+20*64,63519+21*64
			DC		63519+22*64,63519+23*64,63519+24*64
			DC		63519+25*64,63519+26*64,63519+27*64
			DC		63519+28*64,63519+29*64,63519+30*64
			DC		-1,-1,-1,-1,-1,-1,-1,-1

INVBEG		DS		500
INVTAB		DS		1
			DS		1500

SINTAB		DS		90
COSTAB		DS		360

			END
