;***********************************************************************
;***********										 ***********
;***********										 ***********
;***********	 3D Filaire True Color Light Source au DSP	 ***********
;***********		   avec Morphing d'Objets			 ***********
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


		org		p:$0
		jmp		Start

		org		p:410

; Ca commence la !

Start	movep	#1,X:<<PBC			; Port B en Host

; Pour v‚rifier la connexion
Conct_Get	jclr		#<HRDF,X:<<HSR,Conct_Get
		movep	X:<<HRX,x0

Conct_Snd	jclr		#<HTDE,X:<<HSR,Conct_Snd
		movep	#12345678,X:<<HTX

; Recupere la table 1/x
		move		#INVBEG,r0
		Do		#<2001,Get_Inv_Table

GetInvTab	jclr		#<HRDF,X:<<HSR,GetInvTab
		movep	X:<<HRX,Y:(r0)+
Get_Inv_Table

; Recupere la table sinus/cosinus
		move		#SINTAB,r0
		Do		#<450,Get_Sinus_Table

GetSinTab	jclr		#<HRDF,X:<<HSR,GetSinTab
		movep	X:<<HRX,Y:(r0)+
Get_Sinus_Table

; Recupere les objets

GetNbrObj	jclr		#<HRDF,X:<<HSR,GetNbrObj
		movep	X:<<HRX,x0

		move		#<OBJETS,r0
		move		#DATA,r1
		Do		x0,Get_Objects

GetCfLght	jclr		#<HRDF,X:<<HSR,GetCfLght
		movep	X:<<HRX,Y:(r0)+		; Coefficent Lumiere sur Z

GetNbrLns	jclr		#<HRDF,X:<<HSR,GetNbrLns
		movep	X:<<HRX,x0
		move		x0,Y:(r0)+				; Nombre de Lignes
		move		#>6/2,x1
		mpy		x0,x1,a		r1,Y:(r0)+	; Adresse des Points

		Do		a0,Get_Points

Get_Coord	jclr		#<HRDF,X:<<HSR,Get_Coord
		movep	X:<<HRX,X:(r1)+
Get_Points
		nop
Get_Objects

;
; Boucle principale
;

Loop		move		#Rotations,r0
		Do		#<6,Get_Infos
Get_Info	jclr		#<HRDF,X:<<HSR,Get_Info
		movep	X:<<HRX,X:(r0)+
Get_Infos

Get_Obj	jclr		#<HRDF,X:<<HSR,Get_Obj
		movep	X:<<HRX,a
		tst		a
		jpl		<No_Morphing

Get_Obj_M	jclr		#<HRDF,X:<<HSR,Get_Obj_M
		movep	X:<<HRX,a
		tst		a
		jpl		<Init_Morphing

Do_Morphing
		move		X:<Coeff_Light,a
		move		X:<Morph_Coeff,x0
		add		x0,a
		move		a,X:<Coeff_Light

		move		#MORPH_3D,r0
		move		#POINTS_3D,r4

		move		X:<Nb_Lines,x0
		move		#>6/2,x1
		mpy		x0,x1,a

		Do		a0,Morph_Points
		move		Y:(r4),a
		move		Y:(r0)+,x0
		add		x0,a
		move		a,Y:(r4)+
Morph_Points
		jmp		<Calculs

Init_Morphing
		jclr		#<HRDF,X:<<HSR,Init_Morphing
		movep	X:<<HRX,n5
		move		#INVTAB,r5
		nop
		move		Y:(r5+n5),y1

		tfr		a,b
		addl		b,a			#>OBJETS,b
		add		b,a
		move		a,r0
		move		#POINTS_3D,r4
		move		Y:(r0)+,a
		move		X:<Coeff_Light,x0
		sub		x0,a
		move		a,y0
		mpy		y0,y1,a
		move		a,X:<Morph_Coeff

		move		Y:(r0)+,x0			; Nb Lignes
		move		Y:(r0),r1				; Adresses Points

		move		#MORPH_3D,r0

		move		#>6/2,x1
		mpy		x0,x1,a
		Do		a0,Init_Points

		move		X:(r1)+,a		Y:(r4)+,y0
		sub		y0,a
		move		a,y0
		mpy		y0,y1,a
		move		a,Y:(r0)+
Init_Points

		move		X:<Nb_Lines,a
		cmp		x0,a		x0,X:<Nb_Lines
		jle		<Calculs

		move		a,X:<Nb_Lines
		sub		x0,a
		move		a,x0
		mpy		x0,x1,a
		Do		a0,Init_Null_Points

		move		Y:(r4)+,y0
		mpy		-y0,y1,a
		move		a,Y:(r0)+
Init_Null_Points
		jmp		<Calculs

No_Morphing
		tfr		a,b
		addl		b,a			#>OBJETS,b
		add		b,a
		move		a,r0
		move		#POINTS_3D,r4
		move		Y:(r0)+,x0
		move		x0,X:<Coeff_Light
		move		Y:(r0)+,x0
		move		x0,X:<Nb_Lines
		move		Y:(r0),r1

		Do		x0,Copy_Points
		move		X:(r1)+,a
		move		X:(r1)+,a		a,Y:(r4)+	
		move		X:(r1)+,a		a,Y:(r4)+	
		move		X:(r1)+,a		a,Y:(r4)+	
		move		X:(r1)+,a		a,Y:(r4)+	
		move		X:(r1)+,a		a,Y:(r4)+	
		move					a,Y:(r4)+		
Copy_Points

		clr		a		#>150,b
		sub		x0,b
		Do		b,Null_Points
		move		a,Y:(r4)+
		move		a,Y:(r4)+
		move		a,Y:(r4)+
		move		a,Y:(r4)+
		move		a,Y:(r4)+
		move		a,Y:(r4)+
Null_Points

; Calcule Matrice et Points 3D

Calculs	jsr		<Calcule_Matrice
		jsr		<Calcule_Points

; G‚nŠre
		move		#POINTS_2D,r1
		move		#<2,n1
		move		#INTENSITES,r2
		move		#ADRESSES,r3

		Do		X:<Nb_Lines,Scan_Lines

		move		X:(r2)+,a					; Light D‚part
		move		X:(r2)+,x0				; Light Arriv‚e
		add		x0,a			#>16,b		; Centrage
		move		a,x0			#>$800000/2/29,y0
		mac		x0,y0,b					; Intensit‚ moyenne
		move		b,x0			#>2048+64+1,y0
		mpy		x0,y0,a		r1,X:(r3)		; Couleur, Adresse Coords
		asr		a			(r1)+n1
		move		a0,Y:(r3)+				; Couleur Ligne

Scan_Lines

		move		#>ADRESSES,b
		move		b,r3

		Do		X:<Nb_Lines,Tri_Lines

		move		Y:(r3),y0
		move		X:(r3)+,r0
		move		Y:(r3),a

		cmp		y0,a			X:(r3),r1
		jge		<Tri_No_Swap

		move		r3,r5
		nop

Tri_Swap	move		r0,X:(r5)
		move		y0,Y:(r5)-
		move		r1,X:(r5)
		move		a,Y:(r5)-
		move		r5,x0

		cmp		x0,b
		jgt		<Tri_No_Swap

		move		Y:(r5),y0
		move		X:(r5)+,r0
		move		Y:(r5),a

		cmp		y0,a			X:(r5),r1
		jlt		<Tri_Swap

Tri_No_Swap
		nop

Tri_Lines

; Les calculs sont finis

Send_NbLn	jclr		#<HTDE,X:<<HSR,Send_NbLn
		movep	X:Nb_Lines,X:<<HTX


		move		#ADRESSES,r3
		Do		X:<Nb_Lines,Send_Coordonnees

		move		X:(r3),r0

Send_Col	jclr		#<HTDE,X:<<HSR,Send_Col
		movep	Y:(r3)+,X:<<HTX

Send_XDep	jclr		#<HTDE,X:<<HSR,Send_XDep
		movep	X:(r0),X:<<HTX
Send_YDep	jclr		#<HTDE,X:<<HSR,Send_YDep
		movep	Y:(r0)+,X:<<HTX
Send_XArr	jclr		#<HTDE,X:<<HSR,Send_XArr
		movep	X:(r0),X:<<HTX
Send_YArr	jclr		#<HTDE,X:<<HSR,Send_YArr
		movep	Y:(r0),X:<<HTX

Send_Coordonnees
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
		move		#POINTS_2D,r2
		move		#INTENSITES,r3
		move		#POINTS_3D,r4
		move		#INVTAB,r5
		move		X:<Z_Ptf,n5
		move		X:<Nb_Lines,a
		lua		(r5)+n5,r6
		lsl		a			#<11,n0
		Do		a,Calculate_3D_Points

		move					X:(r0)+,a
		move					X:(r0)+,x0	Y:(r4)+,y0
		mpy		x0,y0,b		X:(r0)+,x0	Y:(r4)+,y1
		mac		x0,y1,b		X:(r0)+,x0	Y:(r4)-,y1
 		macr		x0,y1,b		X:<Coeff_Light,y1

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

Z_Ptf		DC		300
Center_X		DC		160
Center_Y		DC		100
Morph_Coeff	DS		1
Coeff_Light	DS		1
Nb_Lines		DS		1

Matrice		DS		12
Rotations		DS		3
Translations	DS		3

			org		Y:0

OBJETS		DS		3*70

			org		X:End_Code

ADRESSES		DS		200
POINTS_2D		DS		2*200
INTENSITES	DS		2*200
DATA			DS		10000


			org		Y:End_Code

LIGHTS		DS		200
			DS		2*200
POINTS_3D		DS		6*200
MORPH_3D		DS		6*200

INVBEG		DS		300
INVTAB		DS		1
			DS		1700

SINTAB		DS		90
COSTAB		DS		360

			END
