;***********************************************************************
;***********										 ***********
;***********										 ***********
;***********		 3D Gouraud Shading au DSP			 ***********
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
		DO		#<3501,Get_Inv_Table

GetInvTab	jclr		#<HRDF,X:<<HSR,GetInvTab
		movep	X:<<HRX,Y:(r0)+
Get_Inv_Table

; Recupere la table sinus/cosinus
		move		#SINTAB,r0
		DO		#<450,Get_Sinus_Table

GetSinTab	jclr		#<HRDF,X:<<HSR,GetSinTab
		movep	X:<<HRX,Y:(r0)+
Get_Sinus_Table

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
;		jeq		<Polygone_Rout
		cmp		x0,b
		jeq		<Gouraud_Rout
;		jmp		<Mapping_Rout

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

		move		Y:(r1),b					; Light Arrivee * 495
		move		Y:(r0),y1					; - Light Depart * 495
		sub		y1,b			Y:(r2+n2),x1	; = diff‚rence Light * 495
		move		b,x0
		mpy		x0,x1,a		#>$800000/495,x1
		move		a,x0						; Increment * 495
		mpy		x0,x1,a
		move		a,L:<Incr_Light			; Increment
		mpy		y1,x1,a		X:(r0)+,b

		tst		b			a,L:<Dep_Light
		jpl		<G_XMin_Ok
		move		b,x1
		mpy		-x0,x1,a		#>$800000/495/2,x1
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

Coeff_Light	DS		1
Z_Ptf		DC		300
Adr_Buffer	DC		BANDES0
Adr_Bandes1	DC		BANDES1
Adr_Bandes2	DC		BANDES2
Off7_Scr		DC		2*320
Adr_Scr		DS		1
Adr_Faces		DS		1
Adr_Points	DS		1

			org		L:10

Dep_Light		DS		1
Incr_Light	DS		1
Pente		DS		1

			org		X:13

; Tableaux pour effacage par bandes

BANDES1		DS		200
BANDES2		DS		200

Matrice		DS		12
Rotations		DS		3
Translations	DS		3

			org		Y:13

			DS		200
			DS		200

			org		X:End_Code

PTS_PROJ		DS		50
INTENSITES	DS		50

LIGHTS		DS		16
PTS_SCR		DS		16

			DS		200
XMIN			DS		400
XMAX			DS		400

; Tableaux pour effacage par bandes

BANDES0		DS		200

			org		Y:End_Code

			DS		50
			DS		50
			DS		16
			DS		16

			DS		200
LIGHTDEP		DS		400
LIGHTARR		DS		400

			DS		200

; Description des objets
; Adresse des points, nombre de points
; Adresse des faces, nombre de faces
; Coefficient pour le Gouraud Shading [rapport Intensit‚ / Profondeur (Z)]

OBJETS		DC		CUBE_POINTS,8,CUBE_FACES,6,$800000*495/1600
			DC		GATO_POINTS,16,GATO_FACES,10,$800000*495/1600
			DC		BOUZOU_POINTS,12,BOUZOU_FACES,20,$800000*495/900
			DC		DIAMOND_POINTS,17,DIAMOND_FACES,18,$800000*495/1800
			DC		ROND_POINTS,32,ROND_FACES,20,$800000*495/1200
			DC		OBJ_POINTS,24,OBJ_FACES,26,$800000*495/500
			DC		SPACE_POINTS,28,SPACE_FACES,17,$800000*495/1200

; Description des Faces
; Nombre de Points
; Liste des num‚ros de Point
; Type de polygone :	1 = Normal	Couleur
;					2 = Gouraud	Infos Adresse Couleurs
;					3 = Mapping	Infos Adresse Image + Coordonn‚es

CUBE_FACES	DC		4,0,1,2,3,2,GOURAUD1
			DC		4,7,6,5,4,2,GOURAUD2
			DC		4,1,5,6,2,2,GOURAUD3
			DC		4,0,3,7,4,2,GOURAUD4
			DC		4,0,4,5,1,2,GOURAUD10
			DC		4,3,2,6,7,2,GOURAUD11

CUBE_POINTS	DC		-50*512,-50*512,+50*512
			DC		+50*512,-50*512,+50*512
			DC		+50*512,+50*512,+50*512
			DC		-50*512,+50*512,+50*512
			
			DC		-50*512,-50*512,-50*512
			DC		+50*512,-50*512,-50*512
			DC		+50*512,+50*512,-50*512
			DC		-50*512,+50*512,-50*512


GATO_FACES	DC		8,0,1,2,3,4,5,6,7,2,GOURAUD8
			DC		8,15,14,13,12,11,10,9,8,2,GOURAUD8
			DC		4,1,0,8,9,2,GOURAUD8
			DC		4,2,1,9,10,2,GOURAUD8
			DC		4,3,2,10,11,2,GOURAUD8
			DC		4,4,3,11,12,2,GOURAUD8
			DC		4,5,4,12,13,2,GOURAUD8
			DC		4,6,5,13,14,2,GOURAUD8
			DC		4,7,6,14,15,2,GOURAUD8
			DC		4,0,7,15,8,2,GOURAUD8

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

BOUZOU_FACES	DC		3,0,1,2,2,GOURAUD7
			DC		3,5,4,3,2,GOURAUD7

			DC		3,0,2,11,2,GOURAUD7
			DC		3,0,11,6,2,GOURAUD7
			DC		3,0,6,7,2,GOURAUD7
			DC		3,1,0,7,2,GOURAUD7
			DC		3,1,7,8,2,GOURAUD7
			DC		3,1,8,9,2,GOURAUD7
			DC		3,2,1,9,2,GOURAUD7
			DC		3,2,9,10,2,GOURAUD7
			DC		3,2,10,11,2,GOURAUD7

			DC		3,3,11,5,2,GOURAUD7
			DC		3,3,6,11,2,GOURAUD7
			DC		3,3,7,6,2,GOURAUD7
			DC		3,4,7,3,2,GOURAUD7
			DC		3,4,8,7,2,GOURAUD7
			DC		3,4,9,8,2,GOURAUD7
			DC		3,5,9,4,2,GOURAUD7
			DC		3,5,10,9,2,GOURAUD7
			DC		3,5,11,10,2,GOURAUD7

ROND_POINTS	DC		0*512,-60*512,40*512
			DC		22*512,-55*512,40*512
			DC		41*512,-41*512,40*512
			DC		55*512,-22*512,40*512
			DC		60*512,0*512,40*512
			DC		55*512,22*512,40*512
			DC		41*512,41*512,40*512
			DC		22*512,55*512,40*512
			DC		0*512,60*512,40*512
			DC		-22*512,55*512,40*512
			DC		-41*512,41*512,40*512
			DC		-55*512,22*512,40*512
			DC		-60*512,0*512,40*512
			DC		-55*512,-22*512,40*512
			DC		-41*512,-41*512,40*512
			DC		-22*512,-55*512,40*512

			DC		0*512,-60*512,-40*512
			DC		22*512,-55*512,-40*512
			DC		41*512,-41*512,-40*512
			DC		55*512,-22*512,-40*512
			DC		60*512,0*512,-40*512
			DC		55*512,22*512,-40*512
			DC		41*512,41*512,-40*512
			DC		22*512,55*512,-40*512
			DC		0*512,60*512,-40*512
			DC		-22*512,55*512,-40*512
			DC		-41*512,41*512,-40*512
			DC		-55*512,22*512,-40*512
			DC		-60*512,0*512,-40*512
			DC		-55*512,-22*512,-40*512
			DC		-41*512,-41*512,-40*512
			DC		-22*512,-55*512,-40*512

ROND_FACES	DC		9
			DC		8,0,1,2,3,4,5,6,7
			DC		2,GOURAUD2
			DC		9
			DC		0,8,9,10,11,12,13,14,15
			DC		2,GOURAUD2
			DC		9
			DC		24,16,31,30,29,28,27,26,25
			DC		2,GOURAUD2
			DC		9
			DC		16,24,23,22,21,20,19,18,17
			DC		2,GOURAUD2
			DC		4
			DC		0,16,17,1
			DC		2,GOURAUD3
			DC		4
			DC		1,17,18,2
			DC		2,GOURAUD3
			DC		4
			DC		2,18,19,3
			DC		2,GOURAUD3
			DC		4
			DC		3,19,20,4
			DC		2,GOURAUD3
			DC		4
			DC		4,20,21,5
			DC		2,GOURAUD3
			DC		4
			DC		5,21,22,6
			DC		2,GOURAUD3
			DC		4
			DC		6,22,23,7
			DC		2,GOURAUD3
			DC		4
			DC		7,23,24,8
			DC		2,GOURAUD3
			DC		4
			DC		8,24,25,9
			DC		2,GOURAUD3
			DC		4
			DC		9,25,26,10
			DC		2,GOURAUD3
			DC		4
			DC		10,26,27,11
			DC		2,GOURAUD3
			DC		4
			DC		11,27,28,12
			DC		2,GOURAUD3
			DC		4
			DC		12,28,29,13
			DC		2,GOURAUD3
			DC		4
			DC		13,29,30,14
			DC		2,GOURAUD3
			DC		4
			DC		14,30,31,15
			DC		2,GOURAUD3
			DC		4
			DC		15,31,16,0
			DC		2,GOURAUD3


DIAMOND_POINTS	DC		-26*512,-60*512,-80*512
			DC		26*512,-60*512,-80*512
			DC		60*512,-26*512,-80*512
			DC		60*512,26*512,-80*512
			DC		26*512,60*512,-80*512
			DC		-26*512,60*512,-80*512
			DC		-60*512,26*512,-80*512
			DC		-60*512,-26*512,-80*512

			DC		-16*512,-44*512,-108*512
			DC		16*512,-44*512,-108*512
			DC		44*512,-16*512,-108*512
			DC		44*512,16*512,-108*512
			DC		16*512,44*512,-108*512
			DC		-16*512,44*512,-108*512
			DC		-44*512,16*512,-108*512
			DC		-44*512,-16*512,-108*512

			DC		0*512,0*512,0*512

DIAMOND_FACES	DC		3
			DC		0,1,16
			DC		2,GOURAUD4
			DC		3
			DC		1,2,16
			DC		2,GOURAUD4
			DC		3
			DC		2,3,16
			DC		2,GOURAUD4
			DC		3
			DC		3,4,16
			DC		2,GOURAUD4
			DC		3
			DC		4,5,16
			DC		2,GOURAUD4
			DC		3
			DC		5,6,16
			DC		2,GOURAUD4
			DC		3
			DC		6,7,16
			DC		2,GOURAUD4
			DC		3
			DC		7,0,16
			DC		2,GOURAUD4
			DC		4
			DC		1,0,8,9
			DC		2,GOURAUD4
			DC		4
			DC		0,7,15,8
			DC		2,GOURAUD4
			DC		4
			DC		7,6,14,15
			DC		2,GOURAUD4
			DC		4
			DC		6,5,13,14
			DC		2,GOURAUD4
			DC		4
			DC		5,4,12,13
			DC		2,GOURAUD4
			DC		4
			DC		4,3,11,12
			DC		2,GOURAUD4
			DC		4
			DC		3,2,10,11
			DC		2,GOURAUD4
			DC		4
			DC		2,1,9,10
			DC		2,GOURAUD4

			DC		5
			DC		13,9,8,15,14
			DC		2,GOURAUD4
			DC		5
			DC		9,13,12,11,10
			DC		2,GOURAUD4


SPACE_POINTS	DC		-20*512,-75*512,+0*512
			DC		+20*512,-75*512,+0*512
			DC		+60*512,+25*512,+0*512
			DC		+40*512,+55*512,10*512
			DC		-40*512,+55*512,10*512
			DC		-60*512,+25*512,+0*512
			DC		-26*512,+25*512,+30*512
			DC		+26*512,+25*512,+30*512
			DC		+40*512,+55*512,-10*512
			DC		-40*512,+55*512,-10*512
			DC		-20*512,+25*512,-20*512
			DC		+20*512,+25*512,-20*512

			DC		30*512,55*512,-10*512
			DC		20*512,55*512,-10*512
			DC		15*512,55*512,-5*512
			DC		15*512,55*512,5*512
			DC		20*512,55*512,10*512
			DC		30*512,55*512,10*512
			DC		35*512,55*512,5*512
			DC		35*512,55*512,-5*512
				
			DC		-30*512,55*512,-10*512
			DC		-20*512,55*512,-10*512
			DC		-15*512,55*512,-5*512
			DC		-15*512,55*512,5*512
			DC		-20*512,55*512,10*512
			DC		-30*512,55*512,10*512
			DC		-35*512,55*512,5*512
			DC		-35*512,55*512,-5*512

SPACE_FACES	DC		4
			DC		0,1,7,6,2,GOURAUD4
			DC		3
			DC		7,1,2,2,GOURAUD4
			DC		3
			DC		0,6,5,2,GOURAUD4
			DC		3
			DC		7,2,3,2,GOURAUD4
			DC		3
			DC		4,5,6,2,GOURAUD4
			DC		4
			DC		3,4,6,7,2,GOURAUD4
			DC		4
			DC		4,3,8,9,2,GOURAUD3
			DC		3
			DC		3,2,8,2,GOURAUD3
			DC		3
			DC		9,5,4,2,GOURAUD3
			DC		4
			DC		1,0,10,11,2,GOURAUD3
			DC		3
			DC		2,1,11,2,GOURAUD3
			DC		3
			DC		0,5,10,2,GOURAUD3
			DC		3
			DC		11,8,2,2,GOURAUD3
			DC		3
			DC		9,10,5,2,GOURAUD3
			DC		4
			DC		11,10,9,8,2,GOURAUD3

			DC		8,12,13,14,15,16,17,18,19,2,GOURAUD5
			DC		8
			DC		27,26,25,24,23,22,21,20,2,GOURAUD5


OBJ_FACES		DC		4,0,1,9,8,2,GOURAUD6
			DC		4,9,2,3,10,2,GOURAUD6
			DC		4,11,10,4,5,2,GOURAUD6
			DC		4,7,8,11,6,2,GOURAUD6
			DC		4,0,12,13,1,2,GOURAUD6
			DC		4,2,14,15,3,2,GOURAUD6
			DC		4,5,4,16,17,2,GOURAUD6
			DC		4,7,6,18,19,2,GOURAUD6
			DC		4,13,12,20,21,2,GOURAUD6
			DC		4,14,21,22,15,2,GOURAUD6
			DC		4,22,23,17,16,2,GOURAUD6
			DC		4,20,19,18,23,2,GOURAUD6
			DC		4,8,9,10,11,2,GOURAUD6
			DC		4,21,20,23,22,2,GOURAUD6
			DC		4,1,13,14,2,2,GOURAUD6
			DC		4,3,15,16,4,2,GOURAUD6
			DC		4,6,5,17,18,2,GOURAUD6
			DC		4,0,7,19,12,2,GOURAUD6
			DC		3,1,2,9,2,GOURAUD6
			DC		3,10,3,4,2,GOURAUD6
			DC		3,21,14,13,2,GOURAUD6
			DC		3,16,15,22,2,GOURAUD6
			DC		3,0,8,7,2,GOURAUD6
			DC		3,11,5,6,2,GOURAUD6
			DC		3,19,20,12,2,GOURAUD6
			DC		3,18,17,23,2,GOURAUD6

OBJ_POINTS	DC		-20*512,-60*512,20*512
			DC		20*512,-60*512,20*512
			DC		60*512,-20*512,20*512
			DC		60*512,20*512,20*512
			DC		20*512,60*512,20*512
			DC		-20*512,60*512,20*512
			DC		-60*512,20*512,20*512
			DC		-60*512,-20*512,20*512
			DC		-20*512,-20*512,60*512
			DC		20*512,-20*512,60*512
			DC		20*512,20*512,60*512
			DC		-20*512,20*512,60*512

			DC		-20*512,-60*512,-20*512
			DC		20*512,-60*512,-20*512
			DC		60*512,-20*512,-20*512
			DC		60*512,20*512,-20*512
			DC		20*512,60*512,-20*512
			DC		-20*512,60*512,-20*512
			DC		-60*512,20*512,-20*512
			DC		-60*512,-20*512,-20*512
			DC		-20*512,-20*512,-60*512
			DC		20*512,-20*512,-60*512
			DC		20*512,20*512,-60*512
			DC		-20*512,20*512,-60*512


; Table de Couleurs pour le Gouraud

			DC		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
			DC		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
GOURAUD6		DC		0,0,0,0,0,0,0,0,0,0,0,0
			DC		0*2049,1*2049,2*2049,3*2049,4*2049,5*2049
			DC		6*2049,7*2049,8*2049,9*2049,10*2049,11*2049
			DC		12*2049,13*2049,14*2049,15*2049,16*2049
			DC		17*2049,18*2049,19*2049,20*2049,21*2049,22*2049
GOURAUD1		DC		23*2049+01*65,24*2049+02*64,25*2049+03*64
			DC		26*2049+04*64,27*2049+05*64,28*2049+06*64
			DC		29*2049+07*64,30*2049+08*64,31*2049+09*64
			DC		63519+10*64,63519+11*64,63519+12*64
			DC		63519+13*64,63519+14*64,63519+15*64
			DC		63519+16*64,63519+17*64,63519+18*64
			DC		63519+19*64,63519+20*64,63519+21*64
			DC		63519+22*64,63519+23*64,63519+24*64
			DC		63519+25*64,63519+26*64,63519+27*64
			DC		63519+28*64,63519+29*64,63519+30*64
			DC		-1,-1,-1,-1,-1,-1,-1,-1

			DC		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
			DC		0*2048,1*2048,2*2048,3*2048,4*2048,5*2048
			DC		6*2048,7*2048,8*2048,9*2048,10*2048,11*2048
GOURAUD5		DC		12*2048,13*2048,14*2048,15*2048,16*2048
			DC		17*2048,18*2048,19*2048,20*2048,21*2048,22*2048
GOURAUD2		DC		23*2048+01*65,24*2048+02*65,25*2048+03*65
			DC		26*2048+04*65,27*2048+05*65,28*2048+06*65
			DC		29*2048+07*65,30*2048+08*65,31*2048+09*65
			DC		63518+10*65,63518+11*65,63518+12*65
			DC		63518+13*65,63518+14*65,63518+15*65
			DC		63518+16*65,63518+17*65,63518+18*65
			DC		63518+19*65,63518+20*65,63518+21*65
			DC		63518+22*65,63518+23*65,63518+24*65
			DC		63518+25*65,63518+26*65,63518+27*65
			DC		63518+28*65,63518+29*65,63518+30*65
			DC		-1,-1,-1,-1,-1,-1,-1,-1

			DC		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
			DC		0*1,1*1,2*1,3*1,4*1,5*1
			DC		6*1,7*1,8*1,9*1,10*1,11*1
			DC		12*1,13*1,14*1,15*1,16*1
GOURAUD3		DC		17*1,18*1,19*1,20*1,21*1,22*1
			DC		23*1+01*2112,24*1+02*2112,25*1+03*2112
GOURAUD8		DC		26*1+04*2112,27*1+05*2112,28*1+06*2112
			DC		29*1+07*2112,30*1+08*2112,31*1+09*2112
			DC		31+10*2112,31+11*2112,31+12*2112
			DC		31+13*2112,31+14*2112,31+15*2112
			DC		31+16*2112,31+17*2112,31+18*2112
			DC		31+19*2112,31+20*2112,31+21*2112
			DC		31+22*2112,31+23*2112,31+24*2112
			DC		31+25*2112,31+26*2112,31+27*2112
			DC		31+28*2112,31+29*2112,31+30*2112
			DC		-1,-1,-1,-1,-1,-1,-1,-1

			DC		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
			DC		0*1+1*64,1*1+1*64,2*1+2*64,3*1+2*64,4*1+3*64,5*1+3*64
			DC		6*1+4*64,7*1+4*64,8*1+5*64,9*1+5*64,10*1+6*64,11*1+6*64
			DC		12*1+7*64,13*1+7*64,14*1+8*64,15*1+8*64,16*1+9*64
GOURAUD4		DC		17*1+9*64,18*1+10*64,19*1+10*64,20*1+11*64,21*1+11*64,22*1+12*64
			DC		23*1+12*64+01*2048,24*1+13*64+02*2048,25*1+13*64+03*2048
			DC		26*1+14*64+04*2048,27*1+14*64+05*2048,28*1+15*64+06*2048
			DC		29*1+15*64+07*2048,30*1+16*64+08*2048,31*1+16*64+09*2048
			DC		31+10*2048+17*64,31+11*2048+17*64,31+12*2048+18*64
			DC		31+13*2048+18*64,31+14*2048+19*64,31+15*2048+19*64
			DC		31+16*2048+20*64,31+17*2048+20*64,31+18*2048+21*64
			DC		31+19*2048+21*64,31+20*2048+22*64,31+21*2048+22*64
			DC		31+22*2048+23*64,31+23*2048+23*64,31+24*2048+24*64
			DC		31+25*2048+24*64,31+26*2048+25*64,31+27*2048+25*64
			DC		31+28*2048+26*64,31+29*2048+26*64,31+30*2048+27*64
			DC		63519+28*64,63519+28*64,63519+29*64,63519+29*64,63519+30*64
			DC		63519+30*64,63519+31*64,63519+31*64

			DC		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
			DC		0*64+1*2048,1*64+1*2048,2*64+2*2048,3*64+2*2048,4*64+3*2048,5*64+3*2048
			DC		6*64+4*2048,7*64+4*2048,8*64+5*2048,9*64+5*2048,10*64+6*2048,11*64+6*2048
			DC		12*64+7*2048,13*64+7*2048,14*64+8*2048,15*64+8*2048,16*64+9*2048
			DC		17*64+9*2048,18*64+10*2048,19*64+10*2048,20*64+11*2048,21*64+11*2048,22*64+12*2048
GOURAUD10		DC		23*64+12*2048+01*1,24*64+13*2048+02*1,25*64+13*2048+03*1
			DC		26*64+14*2048+04*1,27*64+14*2048+05*1,28*64+15*2048+06*1
			DC		29*64+15*2048+07*1,30*64+16*2048+08*1,31*64+16*2048+09*1
			DC		1984+10*1+17*2048,1984+11*1+17*2048,1984+12*1+18*2048
			DC		1984+13*1+18*2048,1984+14*1+19*2048,1984+15*1+19*2048
			DC		1984+16*1+20*2048,1984+17*1+20*2048,1984+18*1+21*2048
			DC		1984+19*1+21*2048,1984+20*1+22*2048,1984+21*1+22*2048
			DC		1984+22*1+23*2048,1984+23*1+23*2048,1984+24*1+24*2048
			DC		1984+25*1+24*2048,1984+26*1+25*2048,1984+27*1+25*2048
			DC		1984+28*1+26*2048,1984+29*1+26*2048,1984+30*1+27*2048
			DC		2015+28*2048,2015+28*2048,2015+29*2048,2015+29*2048,2015+30*2048
			DC		2015+30*2048,2015+31*2048,2015+31*2048

			DC		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
			DC		0*2048+1*64,1*2048+1*64,2*2048+2*64,3*2048+2*64,4*2048+3*64,5*2048+3*64
			DC		6*2048+4*64,7*2048+4*64,8*2048+5*64,9*2048+5*64,10*2048+6*64,11*2048+6*64
GOURAUD7		DC		12*2048+7*64,13*2048+7*64,14*2048+8*64,15*2048+8*64,16*2048+9*64
			DC		17*2048+9*64,18*2048+10*64,19*2048+10*64,20*2048+11*64,21*2048+11*64,22*2048+12*64
GOURAUD11		DC		23*2048+12*64+01*1,24*2048+13*64+02*1,25*2048+13*64+03*1
			DC		26*2048+14*64+04*1,27*2048+14*64+05*1,28*2048+15*64+06*1
			DC		29*2048+15*64+07*1,30*2048+16*64+08*1,31*2048+16*64+09*1
			DC		63488+10*1+17*64,63488+11*1+17*64,63488+12*1+18*64
			DC		63488+13*1+18*64,63488+14*1+19*64,63488+15*1+19*64
			DC		63488+16*1+20*64,63488+17*1+20*64,63488+18*1+21*64
			DC		63488+19*1+21*64,63488+20*1+22*64,63488+21*1+22*64
			DC		63488+22*1+23*64,63488+23*1+23*64,63488+24*1+24*64
			DC		63488+25*1+24*64,63488+26*1+25*64,63488+27*1+25*64
			DC		63488+28*1+26*64,63488+29*1+26*64,63488+30*1+27*64
			DC		63519+28*64,63519+28*64,63519+29*64,63519+29*64,63519+30*64
			DC		63519+30*64,63519+31*64,63519+31*64

INVBEG		DS		500
INVTAB		DS		1
			DS		3000

SINTAB		DS		90
COSTAB		DS		360

			END
