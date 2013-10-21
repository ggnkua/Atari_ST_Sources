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

		org		p:420


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

		move		#FACES,r0

		Do		#<14,Scan_Faces

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
		mac		x0,y1,a

		move		r0,X:<Save_r0
		jmi		<Hidden_Face

		jmp		<Gouraud_Rout

Showed_Face
		jsr		<Add_Polygone

Hidden_Face
		move		X:<Save_r0,r0

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

		move		#LIGHTS,r2
		move		#PTS_SCR,r0
		lua		(r2)+,r3					; Pointe sur
		lua		(r0)+,r1					; Points suivants
		clr		a			#>239,x0		; Initialise
		move		x0,X:<YMin				; YMin … 239
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
		tst		b			#>239,x1
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
		mpy		x0,y0,a		#GOURAUD1,r3	; premiere ligne
		asr		a			#INVTAB,r2	; et adresse
		add		a,b			#>XMIN,a		; sur l'ecran
		move		b0,Y:<Adr_Scr

		add		x0,a			#>XMAX,b		; Pointe sur la
		add		x0,b			a1,r0		; la premiere
		move		b1,r1					; dans les tableaux


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
		move		a,L:<Dep_Light				; Light d‚part

		tst		b
		jpl		<G_XMin_Ok
		move		b,x1
		mpy		-x0,x1,a		#>$800000/987/2,x1
		move		a0,x0
		mpy		x0,x1,a		L:<Dep_Light,y		; Light suppl‚mentaire
		add		y,a
		clr		b			a,L:<Dep_Light		; Light Depart Clippee

G_XMin_Ok	move		#>383,x1
		move		X:(r1)+,a					; XMax
		cmp		x1,a
		jlt		<G_XMax_Ok
		move		x1,a
G_XMax_Ok

		sub		b,a			#>1,x0
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
		move		#>384+100,x0
		move		#>0-100,y0
		move		r0,r4
		Do		#<240,Clear_Buffer_Loop
		move		x0,X:(r0)+	y0,Y:(r4)+
Clear_Buffer_Loop
		rts

; Ajoute un polygone pour l'effacement par bandes

Add_Polygone
		move		X:<YMax,b
		move		X:<YMin,x0
		sub		x0,b			#>1,y0
		add		y0,b			#>XMIN,a
		add		x0,a			b1,n2
		move		#>XMAX,b
		add		x0,b			a1,r0
		move		Y:<Adr_Buffer,a
		add		x0,a			b1,r1
		move		a1,r3
		move		a1,r4

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

		clr		b	Y:<Off7_Scr,x1	; on veut l'offset et non l'adresse

		move		#>0-100,y0
		move		#>384+100,y1

		Do		#<240,Calc_Bandes_Loop

		move		X:(r4),x0
		move		X:(r0),a
		cmp		y1,a
		jeq		<B_No_XMin
		sub		x0,a
		jle		<B_No_XMin

BMin_Send_Nb_Pixels
		jclr		#<HTDE,X:<<HSR,BMin_Send_Nb_Pixels
		movep	a1,X:<<HTX

		move		x0,a
		addl		b,a
BMin_Send_Adr
		jclr		#<HTDE,X:<<HSR,BMin_Send_Adr
		movep	a1,X:<<HTX

B_No_XMin	move		Y:(r0)+,x0
		move		Y:(r4),a
		sub		x0,a
		jle		<B_No_XMax

BMax_Send_Nb_Pixels
		jclr		#<HTDE,X:<<HSR,BMax_Send_Nb_Pixels
		movep	a1,X:<<HTX

		move		x0,a
		addl		b,a			#>2,x0
		add		x0,a
BMax_Send_Adr
		jclr		#<HTDE,X:<<HSR,BMax_Send_Adr
		movep	a1,X:<<HTX

B_No_XMax	add		x1,b			(r4)+		; Ligne suivante

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
		move		a1,n3					; Cos c
		move		a1,n6					; Sin c

		move		X:(r0+n0),a		; Trans Z
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

 		move		X:(r0)+,a			; Trans X
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

		move		X:(r0)+,a			; Trans Y
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
		move		#POINTS,r4
		move		#PTS_PROJ,r2
		move		#INTENSITES,r3
		move		#INVTAB,r5
		move		Y:<Z_Ptf,n5
		move		#<11,n0
		lua		(r5)+n5,r6
		Do		#<12,Calculate_3D_Points

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
		move		a1,n5

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
Center_X		DC		192
Center_Y		DC		120
YMin			DS		1
YMax			DS		1
Screen_Adress	DS		1
Save_r0		DS		1

			org		Y:0

Coeff_Light	DC		$800000*987/1200
Z_Ptf		DC		300
Adr_Buffer	DC		BANDES0
Adr_Bandes1	DC		BANDES1
Adr_Bandes2	DC		BANDES2
Off7_Scr		DC		2*384
Adr_Scr		DS		1


			org		L:7

Dep_Light		DS		1
Incr_Light	DS		1
Pente		DS		1

			org		X:10

Matrice		DS		12
Rotations		DS		3
Translations	DS		3

			org		X:End_Code

PTS_PROJ		DS		12
INTENSITES	DS		12

LIGHTS		DS		5
PTS_SCR		DS		5

XMIN			DS		240
XMAX			DS		240

; Tableaux pour effacage par bandes

BANDES0		DS		240
BANDES1		DS		240
BANDES2		DS		240

			org		Y:End_Code

			DS		12
			DS		12
			DS		5
			DS		5

LIGHTDEP		DS		240
LIGHTARR		DS		240

			DS		240
			DS		240
			DS		240

; Description des Faces
; Nombre de Points et liste des num‚ros de Point

FACES		DC		4,0,1,2,3
			DC		4,11,10,9,8
			DC		4,1,4,9,5
			DC		4,3,6,11,7
			DC		4,0,7,8,4
			DC		4,2,5,10,6

			DC		3,1,5,2
			DC		3,1,0,4
			DC		3,5,9,10
			DC		3,9,4,8
			DC		3,6,10,11
			DC		3,8,7,11
			DC		3,3,2,6
			DC		3,0,3,7

; Description des points : X,Y et Z

POINTS		DC		-50*512,0*512,+50*512
			DC		0*512,-50*512,+50*512
			DC		+50*512,0*512,+50*512
			DC		0*512,+50*512,+50*512

			DC		-50*512,-50*512,0*512
			DC		+50*512,-50*512,0*512
			DC		+50*512,+50*512,0*512
			DC		-50*512,+50*512,0*512

			DC		-50*512,0*512,-50*512
			DC		0*512,-50*512,-50*512
			DC		+50*512,0*512,-50*512
			DC		0*512,+50*512,-50*512

; Table de Couleurs pour le Gouraud

			DC		0,0,0,0,0
			DC		0*1,1*1,2*1,3*1,4*1,5*1
			DC		6*1,7*1,8*1,9*1,10*1,11*1
			DC		12*1,13*1,14*1,15*1,16*1
			DC		17*1,18*1,19*1,20*1,21*1,22*1
GOURAUD1		DC		23*1+01*2112,24*1+02*2112,25*1+03*2112
			DC		26*1+04*2112,27*1+05*2112,28*1+06*2112
			DC		29*1+07*2112,30*1+08*2112,31*1+09*2112
			DC		31+10*2112,31+11*2112,31+12*2112
			DC		31+13*2112,31+14*2112,31+15*2112
			DC		31+16*2112,31+17*2112,31+18*2112
			DC		31+19*2112,31+20*2112,31+21*2112
			DC		31+22*2112,31+23*2112,31+24*2112
			DC		31+25*2112,31+26*2112,31+27*2112
			DC		31+28*2112,31+29*2112,31+30*2112
			DC		-1,-1,-1,-1,-1,-1,-1,-1

INVBEG		DS		500
INVTAB		DS		1
			DS		3000

SINTAB		DS		90
COSTAB		DS		360

			END
