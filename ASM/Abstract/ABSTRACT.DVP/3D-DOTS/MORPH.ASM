;***********************************************************************
;***********										 ***********
;***********										 ***********
;***********		    Points 3D au DSP56001			 ***********
;***********			Rotation, Projection			 ***********
;***********			et Morphing d'objets			 ***********
;***********										 ***********
;***********		   Par Simplet / ABSTRACT			 ***********
;***********										 ***********
;***********************************************************************

Nb_TX	equ		32

PBC		equ		$ffe0			; Port B Control Register
HSR		equ		$ffe9			; Host Status Register
HRX		equ		$ffeb			; Host Receive Register
HTX		equ		$ffeb			; Host Transmit Register

;	Host Status Register Bit Flags

HRDF		equ		0				; Host Receive Data Full
HTDE		equ		1				; Host Transmit Data Empty


		org		p:0
		jmp		Start

		org		p:410

; Projete les points

Calcule_Points
		move		#<Matrice,r0
		move		#COORDS,r4
		move		#INVTAB,r5
		move		X:<Z_Ptf,n5
		move		#<8,n0
		lua		(r5)+n5,r6
		move		#-1,m6

		move		X:(r0)+,x0	Y:(r4)+,y0

		move		#>4096,y1
		Do		y1,SendLoop

		mpy		x0,y0,a		X:(r0)+,x0	Y:(r4)+,y1
		mac		x0,y1,a		X:(r0)+,x0	Y:(r4)-,y1
		macr		x0,y1,a		Y:(r6),y1
		move		a,x0

		move		#>512,a
		macr		-x0,y1,a		X:(r0)+,x0
		move		a,n5

		mpy		x0,y0,b		X:(r0)+,x0	Y:(r4)+,y1
		mac		x0,y1,b		X:(r0)+,x0	Y:(r4)-,y1
		macr		x0,y1,b		Y:(r5+n5),x1
		move		b,y1

		mpyr		y1,x1,b		X:(r0)+,x0

		mpy		x0,y0,a		X:(r0)+,x0	Y:(r4)+,y1
		mac		x0,y1,a		X:(r0),x0		Y:(r4)+,y1
		macr		x0,y1,a		(r0)-n0
		move		a,x0

		mpyr		x0,x1,a		#>384,x1

SendOff7	asl		a			b,y1
		move		a,b0
		mac		x1,y1,b		X:<Adr_Scr,x0
		add		x,b			X:(r0)+,x0	Y:(r4)+,y0

; Envoie l'adresse ‚cran au 030

Send_Adr	jclr		#<HTDE,X:<<HSR,Send_Adr
		movep	b0,X:<<HTX
SendLoop
		rts


; Ca commence la !

Start	movep	#1,X:<<PBC			; Port B en Host

; Pour v‚rifier la connexion
Conct_Get	jclr		#<HRDF,X:<<HSR,Conct_Get
		movep	X:<<HRX,x0

Conct_Snd	jclr		#<HTDE,X:<<HSR,Conct_Snd
		movep	#12345678,X:<<HTX


; Recupere la table 1/x
		move		#INVBEG,r0
		Do		#<1101,Get_Inv_Table

GetInvTab	jclr		#<HRDF,X:<<HSR,GetInvTab
		movep	X:<<HRX,Y:(r0)+
Get_Inv_Table

; Recupere la table sinus/cosinus
		move		#SINTAB,r0
		Do		#<450,Get_Sinus_Table

GetSinTab	jclr		#<HRDF,X:<<HSR,GetSinTab
		movep	X:<<HRX,Y:(r0)+
Get_Sinus_Table


; Recoie les coordonn‚es des points
		move		#COORDS,r0
		move		#MORPH,r1
		clr		a	#>3*4096,x0
		Do		x0,Get_A_Coord

Get_Coord	jclr		#<HRDF,X:<<HSR,Get_Coord
		movep	X:<<HRX,Y:(r0)+
		move		a,X:(r1)+
Get_A_Coord


;
; Boucle principale
;

Loop		jclr		#<HRDF,X:<<HSR,Loop
		movep	X:<<HRX,X:Morph_Flag


Morphing	jclr		#<HRDF,X:<<HSR,Morphing
		movep	X:<<HRX,a
		tst		a
		jmi		<Projete

; Recoie les offsets pour le morphing

		move		#>MORPH,x0
		add		x0,a
		move		a,r0

		Do		#<Nb_TX*3,Get_An_Offset

Get_Off7	jclr		#<HRDF,X:<<HSR,Get_Off7
		movep	X:<<HRX,X:(r0)+
Get_An_Offset


; Recoie tous les parametres

Projete	move		#<Adr_Scr,r0
		Do		#<4,GetLoop

Get		jclr		#<HRDF,X:<<HSR,Get
		movep	X:<<HTX,X:(r0)+
GetLoop

		jsr		<Calcule_Matrice
		jsr		<Calcule_Points

; Maintenant, morphing sur chaque point
		move		X:<Morph_Flag,a
		tst		a
		jeq		<Loop

		move		#MORPH,r0
		move		#<2,n4
		move		#COORDS,r4
		move		n4,n5
		move		r4,r5
		move		X:(r0)+,x0
		move		Y:(r5)+,a

		move		#>3*4096/2,y0
		Do		y0,Morphing_Loop

		add		x0,a				X:(r0)+,x0	Y:(r5),b
		move		a,Y:(r4)+n4
		add		x0,b				X:(r0)+,x0	Y:(r4),a
		move		b,Y:(r5)+n5
Morphing_Loop

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
		move		X:(r0),a
		sub		x0,a			#<2,n0
		move		a1,n3					; Cos c
		move		a1,n6					; Sin c

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

Code_End

			org		X:0

Z_Ptf		DC		300
Adr_Scr		DS		1
Rotations		DS		3
Matrice		DS		9

Morph_Flag	DS		1

			org		X:Code_End

MORPH		DS		3*4096

			org		Y:Code_End

COORDS		DS		3*4096

INVBEG		DS		200
INVTAB		DS		1
			DS		900

SINTAB		DS		90
COSTAB		DS		360

			END
