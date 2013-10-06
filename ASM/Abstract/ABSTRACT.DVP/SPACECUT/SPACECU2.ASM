;***********************************************************************
;***********										 ***********
;***********										 ***********
;***********				Space-Cut					 ***********
;***********										 ***********
;***********										 ***********
;***********			 Par Simplet / ABSTRACT			 ***********
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

Loop

; Recoit toutes les informations
; concernant l'objet r‚f‚rence et l'objet … cutter

Get_First	jclr		#<HRDF,X:<<HSR,Get_First
		movep	X:<<HRX,x0
		move		#First_Rotations,r0
		Do		#<6,Get_Infos_First
Get_Info1	jclr		#<HRDF,X:<<HSR,Get_Info1
		movep	X:<<HRX,X:(r0)+
Get_Infos_First

GetSecond	jclr		#<HRDF,X:<<HSR,GetSecond
		movep	X:<<HRX,y1
		move		#Second_Rotations,r0
		Do		#<6,Get_Infos_Second
Get_Info2	jclr		#<HRDF,X:<<HSR,Get_Info2
		movep	X:<<HRX,X:(r0)+
Get_Infos_Second

; Initialise les pointeurs en cons‚quence

		move		#>5,x1
		mpy		x0,x1,a		#>OBJETS,b0
		addr		b,a			#<First_Adr_Points,r4
		move		a0,r0
		nop
		move		Y:(r0)+,x0
		move		Y:(r0)+,y0	x0,X:(r4)+
		move					y0,X:(r4)+
		move		Y:(r0)+,x0
		move		Y:(r0)+,y0	x0,X:(r4)+
		move					y0,X:(r4)+
		move		Y:(r0),x0

		mpy		y1,x1,a		x0,X:(r4)
		addr		b,a			#<Second_Adr_Points,r4
		move		a0,r0
		nop
		move		Y:(r0)+,x0
		move		Y:(r0)+,y0	x0,X:(r4)+
		move					y0,X:(r4)+
		move		Y:(r0)+,x0
		move		Y:(r0)+,y0	x0,X:(r4)+
		move					y0,X:(r4)+
		move		Y:(r0),x0
		move					x0,X:(r4)


		move		#FACES,r0
		move		r0,Y:<Faces_Pointer
		move		#POINTS,r0
		move		r0,Y:<Points_Pointer

; Calcule les Points 3D des deux objets

		move		#<First_Rotations,r0
		jsr		<Calcule_Matrice
		move		#FIRST_PTS_3D,r0
		move		X:<First_Nb_Points,x0
		move		X:<First_Adr_Points,r4
		jsr		<Rotate_Translate_3D_Points

		move		#<Second_Rotations,r0
		jsr		<Calcule_Matrice
		move		#SECOND_PTS_3D,r0
		move		X:<Second_Nb_Points,x0
		move		X:<Second_Adr_Points,r4
		jsr		<Rotate_Translate_3D_Points

; Projete les Points des objets pour tests de visibilit‚

		move		#FIRST_PTS_3D,r0
		move		#FIRST_PTS_2D,r1
		move		X:<First_Nb_Points,x0
		jsr		<Projete_3D_Points

		move		#SECOND_PTS_3D,r0
		move		#SECOND_PTS_2D,r1
		move		X:<Second_Nb_Points,x0
		jsr		<Projete_3D_Points

; On cr‚e le tableau des faces visibles des Objets

		move		X:<First_Adr_Faces,r0
		move		#FIRST_PTS_2D,r1
		move		#FIRST_PTS_3D,r2
		move		#FIRST_FACES,r4
		move		#FIRST_POINTS,r5
		move		#<0,r6
		move		X:<First_Nb_Faces,x0
		jsr		<Cree_Visibles
		move		r6,X:<FirstNbVisiFaces

		move		X:<Second_Adr_Faces,r0
		move		#SECOND_PTS_2D,r1
		move		#SECOND_PTS_3D,r2
		move		#SECOND_FACES,r4
		move		#SECOND_POINTS,r5
		move		#<0,r6
		move		X:<Second_Nb_Faces,x0
		jsr		<Cree_Visibles
		move		r6,X:<SecondNbVisiFaces

; On cutte les faces visibles de l'objet avec l'objet r‚f‚rence
; et on les ajoute au tableau total

		move		X:<First_Adr_Faces,r0
		move		r0,Y:<Ref_Faces
		move		#FIRST_PTS_3D,r0
		move		r0,Y:<Ref_Points
		move		X:<First_Nb_Faces,x0
		move		x0,Y:<Ref_Nb_Faces
		move		#SECOND_FACES,r0
		move		r0,Y:<Object_Faces
		move		#SECOND_POINTS-3,r0
		move		r0,Y:<Object_Points
		move		X:<SecondNbVisiFaces,x0
		move		x0,Y:<Obj_Visi_Faces
		jsr		<Cut_Object_Faces

  		move		Y:<Points_Pointer,a
		move		#>POINTS,x0
		sub		x0,a			#>$800000/3,x1
		move		a,x0
		mpyr		x0,x1,a
		move		a,Y:<First_Points

		move		X:<Second_Adr_Faces,r0
		move		r0,Y:<Ref_Faces
		move		#SECOND_PTS_3D,r0
		move		r0,Y:<Ref_Points
		move		X:<Second_Nb_Faces,x0
		move		x0,Y:<Ref_Nb_Faces
		move		#FIRST_FACES,r0
		move		r0,Y:<Object_Faces
		move		#FIRST_POINTS-3,r0
		move		r0,Y:<Object_Points
		move		X:<FirstNbVisiFaces,x0
		move		x0,Y:<Obj_Visi_Faces
		jsr		<Cut_Object_Faces

  		move		Y:<Points_Pointer,a
		move		#>POINTS,x0
		sub		x0,a			#>$800000/3,x1
		move		a,x0
		mpyr		x0,x1,a		Y:<First_Points,x0
		sub		x0,a
		move		a,Y:<Second_Points


; Compte le nombre de faces total

		move		Y:<Faces_Pointer,a
		move		#>FACES,x0
		sub		x0,a			#>$800000/3,y1
		move		a,y0
		mpyr		y0,y1,a
		jne		<Ok_Faces

Send_Ufu	jclr		#<HTDE,X:<<HSR,Send_Ufu
		movep	x0,X:<<HTX
		jmp		<Scan_Faces

Ok_Faces	move		a,Y:<Nb_Faces


; Projete les Points du Tableau Total

Projectature
		move		Y:<First_Points,x0
		move		Y:<Second_Points,a
		add		x0,a			#POINTS,r0
		move		a,x0
		move		#POINTS_2D,r1
		jsr		<Projete_3D_Points

; Cree les derniers Tableaux : Faces, Adresses et Bary

		move		#FACES,r0
		move		#POINTS,r1
		clr		a			#<3,n1
		move		#FINAL_TAB,r2
		move		#TRI_TAB,r3
		move		#INVTAB,r5

		Do		Y:<Nb_Faces,Create_Final_Tab

		clr		b			r2,X:(r3)		; Note adresse de la Face

		move		X:(r0)+,x0				; Nb Points
		move		x0,X:(r2)+					
		move		a,X:(r2)+					; Num‚ro Point de D‚part
		add		x0,a			x0,n5

		Do		x0,Calcule_Bary

		move		X:(r1)+n1,x0
		add		x0,b
Calcule_Bary
		move		b,x0
		move		Y:(r5+n5),y0
		mpy		x0,y0,b
		move		b,Y:(r3)+					; Note Barycentre

		move		X:(r0)+,x0
		move		x0,X:(r2)+				; Type Face
		move		X:(r0)+,x0
		move		x0,X:(r2)+				; Attribut Face

Create_Final_Tab

; Trie les Faces

		move		#TRI_TAB,r3
		move		r3,b
		move		#>1,x0
		move		Y:<Nb_Faces,a
		sub		x0,a
		jeq		<Tri_Faces

		Do		a,Tri_Faces

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

Tri_Faces

; Recherche les deux zones … effacer la prochaine fois

		move		#POINTS_2D,r0
		move		#First_MinMax,r1
		move		Y:<First_Points,a
		jsr		<Search_Minimas_Maximas

		move		Y:<Second_Points,a
		jsr		<Search_Minimas_Maximas

; Tout est fini, envoie les deux rectangles et recoit adresse de l'‚cran

		move		#First_MinMax,r0
		Do		#<4,Send_Mini_Maxi

Send_X	jclr		#<HTDE,X:<<HSR,Send_X
		movep	X:(r0),X:<<HTX
Send_Y	jclr		#<HTDE,X:<<HSR,Send_Y
		movep	Y:(r0)+,X:<<HTX
Send_Mini_Maxi

Get_Adr	jclr		#<HRDF,X:<<HSR,Get_Adr
		movep	X:<<HRX,Y:Screen_Adress

; Scanne les faces et appelle les routines

		move		#TRI_TAB,r0

		Do		Y:<Nb_Faces,Scan_Faces

		move		#POINTS_2D,r1
		move		X:(r0)+,r2				; Adresse de la Face
		move		r0,Y:<Save_r0

		move		X:(r2)+,n0				; Nombre de Points
		move		X:(r2)+,n1				; Num‚ro Point de D‚part
		move		#PTS_SCR,r4
		lua		(r1)+n1,r3
		lua		(r1)+n1,r1
		Do		n0,Scan_Points

		move		X:(r1),x0
		move		Y:(r1)+,y0	x0,X:(r4)
		move					y0,Y:(r4)+
Scan_Points
		move		X:(r3),x0					; Recopie dernier
		move		Y:(r3),y0		x0,X:(r4)		; point pour le
		move		X:(r2)+,b		y0,Y:(r4)		; dernier segment

		move		#>1,x0
		cmp		x0,b			#>2,x0
		jeq		<Polygone_Rout
;		cmp		x0,b
;		jeq		<Gouraud_Rout
;		jmp		<Mapping_Rout

Trace_Next_Face
		move		Y:<Save_r0,r0

Scan_Faces
		jclr		#<HTDE,X:<<HSR,Scan_Faces
		movep	#0,X:<<HTX

		jmp		<Loop


; Cutting de Faces

Cut_Object_Faces
		move		Y:<Ref_Faces,r0
		move		#<3,n0
		move		Y:<Ref_Points,r1

		move		Y:<Ref_Nb_Faces,a
		tst		a
		jeq		<Cut_Faces

		Do		a,Cut_Faces

		lua		(r0)+,r0					; Saute Nb Points
		move		#VECTORS,r5
		move		Y:(r0)+,a					; Num Pt1
		tfr		a,b
		addl		b,a
		move		a,n1
		move		Y:(r0)+,a					; Num Pt2
		lua		(r1)+n1,r2
		nop
		move		X:(r2)+,y1				; Z1
		tfr		a,b			X:(r2)+,x0	; X1
		addl		b,a			X:(r2),y0		; Y1
		move		a,n1
		nop
		lua		(r1)+n1,r2
		move					y1,b			; 		Z1
		move		X:(r2)+,y1				; Z2
		sub		y1,b			x0,a			; Z1-Z2	X1
		move		X:(r2)+,x0	b,Y:(r5)+		; X2		Z
		sub		x0,a			y0,b			; X1-X2	Y1
		move		X:(r2),y0					; Y2
		sub		y0,b			a,Y:(r5)+		; Y1-Y2	X

		move		Y:(r0)-,a					; Num Pt3
		tfr		a,b			b,Y:(r5)+		;		Y
		addl		b,a
		move		a,n1
		nop
		lua		(r1)+n1,r2
		nop
		move		X:(r2)+,b					; Z3
		sub		y1,b			#EQUATION,r6	; Z3-Z2	Z3
		move		X:(r2)+,b		b,Y:(r5)+		; X3		Z'
		sub		x0,b			#VECTORS+2,r3	; X3-X2
		move		X:(r2)+,b		b,Y:(r5)+		; Y3		X'
		sub		y0,b			#VECTORS+5,r4	; Y3-Y2
		move					b,Y:(r5)		;		Y'

		move		Y:(r3)-,x0				; Y
		move		Y:(r3)-,y0				; X
		move		Y:(r4)-,y1				; Y'
		mpy		y0,y1,b		Y:(r4)-,x1	; XY'	X'
		mac		-x0,x1,b		Y:(r4),y0		; -YX'	Z'
		Rep		#<11						; C
		asr		b
		mpy		x0,y0,a		Y:(r3)+,x0	; YZ'	Z
		mac		-x0,y1,a		b0,Y:(r6)+	; -ZY'
		Rep		#<11						; A
		asr		a
		mpy		x0,x1,b		Y:(r3),y1		; ZX'	X
		mac		-y1,y0,b		a0,Y:(r6)+	; -XZ'
		Rep		#<11						; B
		asr		b

		move		Y:(r0)-,a					; Num Pt2
		tfr		a,b			b0,Y:(r6)+
		addl		b,a			(r0)-
		move		a,n1
		nop
		lua		(r1)+n1,r2
		move		#EQUATION,r5
		nop
		move					X:(r2)+,x0	Y:(r5)+,y0	; Z2	C
		mpy		-x0,y0,a		X:(r2)+,x0	Y:(r5)+,y0	; X2	A
		mac		-x0,y0,a		X:(r2)+,x0	Y:(r5)+,y0	; Y2	B
		mac		-x0,y0,a
		move		a,L:<EQUA_D				; -D=A*X2+B*Y2+C*Z2

		move		Y:(r0)+n0,x0				; Nb Points
		move		r0,a						; Adr Face
		add		x0,a						; Fin Face
		move		a,r0

		move		r0,Y:<Save_r0
		move		r1,Y:<Save_r1

		move		Y:<Object_Faces,r2
		move		Y:<Object_Points,r3
		move		#<3,n3
		move		#<3,n1

		move		Y:<Faces_Pointer,r4
		move		Y:<Points_Pointer,r5

		Do		Y:Obj_Visi_Faces,Cut_A_Face

		move		r3,Y:<Point_Adr		; Adresse pr 1er Point
		clr		a		X:(r2)+,b		; Nb Points de la Face
		move		#>100,x0
		cmp		x0,b		a,Y:<Curr_Point
		jle		<Face_To_Cut

		sub		x0,b
		tfr		b,a		r3,x0		; Si Nombre Pts > 100
		addl		b,a		(r2)+		; c'est que la Face
		add		x0,a		(r2)+		; est d‚ja totalement
		move		a,r3					; visible, donc pas la peine
		jmp		<Cut_Next_Face			; de r‚afficher pour rien

Face_To_Cut
		move		b,Y:<Nb_Points

		jsr		<Calc_Potentiel		; Calcule Potentiel 1er Point

		tst		a			#<0,r0	; Compteur de Points … 0
		jpl		<First_Out

; Les Points sont devant la face

First_In	move		r3,r6				; Pointe sur le point
		move		a,Y:<Last_Potentiel		; et note son potentiel

		move		X:(r6)+,x0			; Recopie
		move		x0,X:(r5)+
		move		X:(r6)+,x0			; Le Point
		move		x0,X:(r5)+
		move		X:(r6)+,x0			; Valid‚
		move		x0,X:(r5)+	Y:(r0)+,y0	; Transfert Bidon Incr‚mt

		move		#>1,x0
		move		Y:<Curr_Point,a
		add		x0,a			Y:<Nb_Points,x0
		cmp		x0,a			a,Y:<Curr_Point
		jne		<First_In_Next

		move		#>100,x0
		move		X:-(r2),a
		add		x0,a
		move		a,X:(r2)+
		move		r3,Y:<Point_Adr
		jmp		<Create_Face

First_In_Next
		jsr		<Calc_Potentiel			; Calcule Potentiel Point
		tst		a
		jmi		<First_In

; Calcule Point d'intersection H si point suivant derriere la face

		move		Y:<Last_Potentiel,b		; P1
		move		a,Y:<Last_Potentiel		; P2
		sub		b,a		a,b			; b=P1-P2		a=P1
		move		a,x0

		andi		#<$fe,ccr				; Annule Carry Bit
		Rep		#<24
		div		x0,b					; b0 = P1 / ( P1 - P2 )
		move		b0,x0

		move		r3,r6				; Pointe sur Point 2

		Do		#<3,Calc_Intersect1

		move		X:(r6)+,y0			; ?1
		move		X:(r1)+,a				; ?2
		sub		y0,a					; ?2-?1
		move		a,x1
		mpy		x0,x1,a				; (?2-?1) * P1/(P1-P2)
		add		y0,a					; + ?1 = ?H
		move		a,X:(r5)+
		rnd		a
Calc_Intersect1

		lua		(r0)+,r0				; 1 pt de +
		lua		(r1)-n1,r1			; Revient bien sur pt pr‚c‚dent

First_In_Out
		move		#>1,x0
		move		Y:<Curr_Point,a
		add		x0,a
		move		a,Y:<Curr_Point

		jsr		<Calc_Potentiel			; Calcule Potentiel Point
		tst		a
		jmi		<First_In_In

		move		a,Y:<Last_Potentiel
		jmp		<First_In_Out


; Calcule Point d'intersection H si point suivant devant la face

First_In_In
		move		Y:<Last_Potentiel,b		; P1
		move		a,Y:<Last_Potentiel		; P2
		sub		a,b		b,a			; b=P1-P2		a=P1
		move		b,x0

		andi		#<$fe,ccr				; Annule Carry Bit
		Rep		#<24
		div		x0,a					; a0 = P1 / ( P1 - P2 )
		move		a0,x0

		move		r3,r6				; Pointe sur Point 2

		Do		#<3,Calc_Intersect2

		move		X:(r1)+,y0			; ?1
		move		X:(r6)+,a				; ?2
		sub		y0,a					; ?2-?1
		move		a,x1
		mpy		x0,x1,a				; (?2-?1) * P1/(P1-P2)
		add		y0,a					; + ?1 = ?H
		rnd		a
		move		a,X:(r5)+
Calc_Intersect2

		lua		(r0)+,r0				; 1 pt de +
		lua		(r1)-n1,r1			; Revient bien sur pt pr‚c‚dent

First_In_Loop
		move		#>1,x0
		move		Y:<Curr_Point,a
		add		x0,a		Y:<Nb_Points,x0
		cmp		x0,a		a,Y:<Curr_Point
		jgt		<Create_Face

		move		r3,r6				; Pointe sur le point
		nop
		move		X:(r6)+,x0			; Recopie
		move		x0,X:(r5)+
		move		X:(r6)+,x0			; Le Point
		move		x0,X:(r5)+
		move		X:(r6)+,x0			; Valid‚
		move		x0,X:(r5)+	Y:(r0)+,y0	; Transfert Bidon Incr‚mt

		jsr		<Calc_Potentiel			; Calcule Potentiel Point
		jmp		<First_In_Loop

; Le Premier Point est derriere la face :

First_Out	move		a,Y:<Last_Potentiel		; Note son potentiel

		move		#>1,x0
		move		Y:<Curr_Point,a
		add		x0,a			Y:<Nb_Points,x0
		cmp		x0,a			a,Y:<Curr_Point
		jle		<First_Out_Next

		move		X:(r2)+,x0		; Pointe bien sur
		move		X:(r2)+,x0		; les infos faces
		move		Y:<Point_Adr,r3	; et points suivants
		jmp		<Cut_Next_Face

First_Out_Next
		jsr		<Calc_Potentiel			; Calcule Potentiel Point
		tst		a
		jpl		<First_Out

; Calcule Point d'intersection H si point suivant devant la face

		move		Y:<Last_Potentiel,b		; P1
		move		a,Y:<Last_Potentiel		; P2
		sub		a,b		b,a			; b=P1-P2		a=P1
		move		b,x0

		andi		#<$fe,ccr				; Annule Carry Bit
		Rep		#<24
		div		x0,a					; a0 = P1 / ( P1 - P2 )
		move		a0,x0

		move		r3,r6				; Pointe sur Point 2

		Do		#<3,Calc_Intersect3

		move		X:(r1)+,y0			; ?1
		move		X:(r6)+,a				; ?2
		sub		y0,a					; ?2-?1
		move		a,x1
		mpy		x0,x1,a				; (?2-?1) * P1/(P1-P2)
		add		y0,a					; + ?1 = ?H
		rnd		a
		move		a,X:(r5)+
Calc_Intersect3

		lua		(r0)+,r0				; 1 pt de +
		lua		(r1)-n1,r1			; Revient bien sur pt pr‚c‚dent

First_Out_In
		move		r3,r6				; Pointe sur le point
		nop
		move		X:(r6)+,x0			; Recopie
		move		x0,X:(r5)+
		move		X:(r6)+,x0			; Le Point
		move		x0,X:(r5)+
		move		X:(r6)+,x0			; Valid‚
		move		x0,X:(r5)+	Y:(r0)+,y0	; Transfert Bidon Incr‚mt

		move		#>1,x0
		move		Y:<Curr_Point,a
		add		x0,a
		move		a,Y:<Curr_Point

		jsr		<Calc_Potentiel			; Calcule Potentiel Point
		tst		a
		jpl		<First_Out_Out

		move		a,Y:<Last_Potentiel
		jmp		<First_Out_In

; Calcule Point d'intersection H si point suivant derriere la face

First_Out_Out
		move		Y:<Last_Potentiel,b		; P1
		move		a,Y:<Last_Potentiel		; P2
		sub		b,a		a,b			; b=P1-P2		a=P1
		move		a,x0

		andi		#<$fe,ccr				; Annule Carry Bit
		Rep		#<24
		div		x0,b					; b0 = P1 / ( P1 - P2 )
		move		b0,x0

		move		r3,r6				; Pointe sur Point 2

		Do		#<3,Calc_Intersect4

		move		X:(r6)+,y0			; ?1
		move		X:(r1)+,a				; ?2
 		sub		y0,a					; ?2-?1
		move		a,x1
		mpy		x0,x1,a				; (?2-?1) * P1/(P1-P2)
		add		y0,a					; + ?1 = ?H
		rnd		a
		move		a,X:(r5)+
Calc_Intersect4

		lua		(r0)+,r0				; 1 pt de +
		lua		(r1)-n1,r1			; Revient bien sur pt pr‚c‚dent

First_Out_Loop
		move		#>1,x0
		move		Y:<Curr_Point,a
		add		x0,a			Y:<Nb_Points,x0
		cmp		x0,a			a,Y:<Curr_Point
		jgt		<Create_Face

		jsr		<Calc_Potentiel		; Calcule Potentiel Point
		jmp		<First_Out_Loop

; Creation de la Face

Create_Face
		move		r0,X:(r4)+				; Nombre de Points
		move		X:(r2)+,x0				; Type de Face
		move		x0,X:(r4)+
		move		X:(r2)+,x0				; Attribut de la Face
		move		x0,X:(r4)+

		move		Y:<Point_Adr,r3	; Pointe bien sur points suivants

Cut_Next_Face
		nop
Cut_A_Face
		move		r4,Y:<Faces_Pointer
		move		r5,Y:<Points_Pointer
		move		Y:<Save_r0,r0
		move		Y:<Save_r1,r1

Cut_Faces
		rts

; Calcul du Potentiel d'un point de l'objet
; par rapport au plan d'une face de r‚f‚rence
; r3 pointe sur les coordonn‚es 3D du Point
; r‚sultat dans a

Calc_Potentiel
		move		r3,r1			; Note Adresse point pr‚c‚dent

		move		Y:<Nb_Points,x0
		move		Y:<Curr_Point,a
		cmp		x0,a
		jne		<Calc_Potentiel_Ok

		move		Y:<Point_Adr,x0	; On rescanne le premier point
		move		r3,Y:<Point_Adr
		move		x0,r3
		
Calc_Potentiel_Ok
		move		#EQUATION,r6
		lua		(r3)+n3,r3		; Pointe point suivant
		move		L:<EQUA_D,a							; D
		move					X:(r3)+,x0	Y:(r6)+,y0	; + C * Z
		mac		x0,y0,a		X:(r3)+,x0	Y:(r6)+,y0	; + A * X
		mac		x0,y0,a		X:(r3)+,x0	Y:(r6)+,y0	; + B * Y
		mac		x0,y0,a		(r3)-n3
		Rep		#<19
		asr		a
		move		a0,a
		rts

; Cr‚ation d'un tableau des faces visibles d'un objet
; Registres en entr‚e :
; r0 = Pointe sur la description des faces de l'objet
; r1 = Pointe sur le Tableau des points 2D de l'objet
; r2 = Pointe sur le Tableau des points 3D de l'objet
; r4 = Pointeur sur le Tableau des Faces … cr‚er
; r5 = Pointeur sur le Tableau de Points … cr‚er

Cree_Visibles
		move		#<3,n0
		Do		x0,Cree_Tableau

		lua		(r0)+,r0					; Saute Nb Points
		nop
		move		Y:(r0)+,n1				; Num Pt1
		nop
		move		X:(r1+n1),x1				; X1
		move		Y:(r1+n1),y1				; Y1
		move		Y:(r0)+,n1				; Num Pt2
		nop
		move		X:(r1+n1),a				; X2
		sub		x1,a			Y:(r1+n1),b	; X2-X1		Y2
		sub		y1,b			a,x0			; Y2-Y1
		move		Y:(r0),n1					; Num Pt3
		move		b,y0
		move		X:(r1+n1),a				; X3
		sub		x1,a			Y:(r1+n1),b	; X3-X1		Y3
		sub		y1,b			a,x1			; Y3-Y1
		mpy		-x1,y0,a		b,y1			; -(X3-X1)*(Y2-Y1)
		mac		x0,y1,a		(r0)-n0		; +(X2-X1)*(Y3-Y1)

		jmi		<Next_Face

		lua		(r6)+,r6					; Une Face de Plus
		move		Y:(r0)+,x0				; Nb Pts de la Face
		move		x0,X:(r4)+

		Do		x0,Cree_Face

		move		Y:(r0)+,a					; Num Point
		tfr		a,b
		addl		b,a						; Num Point *3
		move		a,n2
		nop
		lua		(r2)+n2,r3
		nop
		move		X:(r3)+,x0
		move		x0,X:(r5)+
		move		X:(r3)+,x0
		move		x0,X:(r5)+
		move		X:(r3),x0
		move		x0,X:(r5)+

Cree_Face	move		Y:(r0)+,x0					; Type de Face
		move		Y:(r0)+,y0		x0,X:(r4)+
		move		y0,X:(r4)+					; Attribut de la Face
		jmp		<Ok_Face

Next_Face	move		Y:(r0)+n0,x0					; Nb Points
		move		r0,a							; Adr Face
		add		x0,a							; Fin Face
		move		a,r0
Ok_Face	nop

Cree_Tableau
		rts

; Recherche des Minimums et Maximums pour effacage par Zones Rectangulaires

Search_Minimas_Maximas
		tst		a
		jeq		<Search_No_Points

		move		#>319,x0			; Minimum	X
		move		#>199,y0			; Minimum	Y
		move		#<0,x1			; Maximum	X
		move		x1,y1			; Maximum	Y

		Do		a,Search_Mini_Maxi

		move		X:(r0),a			; Pt X
		cmp		x0,a		Y:(r0)+,b	; Pt Y
		jge		<No_Mini_X
		move		a,x0
No_Mini_X	cmp		x1,a
		jle		<No_Maxi_X
		move		a,x1
No_Maxi_X	cmp		y0,b
		jge		<No_Mini_Y
		move		b,y0
No_Mini_Y	cmp		y1,b
		jle		<No_Maxi_Y
		move		b,y1
No_Maxi_Y	nop	
Search_Mini_Maxi

		move		x0,a
		tst		a	y0,b
		jpl		<Mini_X_Ok
		clr		a
Mini_X_Ok	tst		b	a,X:(r1)
		jpl		<Mini_Y_Ok
		clr		b
Mini_Y_Ok	move		b,Y:(r1)+
		move		#>319,a
		cmp		x1,a		#>199,b
		jge		<Maxi_X_Ok
		move		a,x1
Maxi_X_Ok	cmp		y1,b		x1,X:(r1)
		jge		<Maxi_Y_Ok
		move		b,y1
Maxi_Y_Ok	move		y1,Y:(r1)+
		rts

Search_No_Points
		clr		a
		move		a,X:(r1)
		move		a,Y:(r1)+
		move		a,X:(r1)
		move		a,Y:(r1)+
		rts

;
; Routine de Polygone
;

Polygone_Rout
		jclr		#<HTDE,X:<<HSR,Polygone_Rout
		movep	#1,X:<<HTX

P_Send_Color
		jclr		#<HTDE,X:<<HSR,P_Send_Color
		movep	X:(r2)+,X:<<HTX

		move		#PTS_SCR,r0
		clr		a			#>199,x0		; Initialise
		move		x0,Y:<YMin				; YMin … 199
		move		a,Y:<YMax					; YMax … 0
		lua		(r0)+,r1					; Pointe sur pt suivant


; Boucle de trac‚ virtuel dans les tableaux
; des segments qui composent le polygone … l'‚cran

		Do		n0,P_Virtual_Tracing


		move		Y:<YMin,x0				; YMin
		move		Y:(r0),b					; Y1
		cmp		x0,b			Y:<YMax,y0	; YMax
		jge		<P_No_YMin				; si Y1 < YMin
		move		b,Y:<YMin					; c'est le nouveau YMin
P_No_YMin	cmp		y0,b			X:(r0)+,x0	; X1
		jle		<P_No_YMax				; si Y1 > YMax
		move		b,Y:<YMax					; c'est le nouveau YMax
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

		move		Y:<YMin,b					; Premiere Ligne
		tst		b			#>199,x1
		jpl		<P_YMin_Ok
		clr		b
P_YMin_Ok	move		Y:<YMax,a					; Derniere Ligne
		cmp		x1,a			b,x0
		jlt		<P_YMax_Ok
		move		x1,a
P_YMax_Ok	move		b,Y:<YMin
		move		a,Y:<YMax
		sub		x0,a			#>1,y0
		add		y0,a			Y:<Screen_Adress,b0	; Nombre de Lignes

P_Send_Nb_Lines
		jclr		#<HTDE,X:<<HSR,P_Send_Nb_Lines
		movep	a,X:<<HTX
		move		a,n7

		move		Y:<Off7_Scr,y0				; Calcule offset
		mpy		x0,y0,a					; premiere ligne
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
		jmp		<Trace_Next_Face

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

; Rotate et translate les points 3D
; Registres en entr‚e :
; x0 = Nombre de Points
; r0 = Adresse du Tableau des Points 3D Calcul‚s en X
; r4 = Adresse du Tableau des Points 3D de d‚part en Y

Rotate_Translate_3D_Points
		move		#Matrice,r1
		move		#<11,n1

		Do		x0,Rotate_Translate_Points

		move		X:(r1)+,a
		move		X:(r1)+,x0	Y:(r4)+,y0
		mac		x0,y0,a		X:(r1)+,x0	Y:(r4)+,y1
		mac		x0,y1,a		X:(r1)+,x0	Y:(r4)-,y1
		macr		x0,y1,a		X:(r1)+,b
		move		a,X:(r0)+					; New Ze

		move		X:(r1)+,x0
		mac		x0,y0,b		X:(r1)+,x0	Y:(r4)+,y1
		mac		x0,y1,b		X:(r1)+,x0	Y:(r4)-,y1
		macr		x0,y1,b		X:(r1)+,a
		move		b,X:(r0)+					; New Xe

		move		X:(r1)+,x0
		mac		x0,y0,a		X:(r1)+,x0	Y:(r4)+,y1
		mac		x0,y1,a		X:(r1),x0		Y:(r4)+,y1
		macr		x0,y1,a		(r1)-n1
		move		a,X:(r0)+					; New Ye

Rotate_Translate_Points
		rts

; Projete les Points 3D sur l'‚cran
; Registres en entr‚e :
; x0 = Nombre de Points
; r0 = Adresse du Tableau des Points 3D en X
; r1 = Adresse du Tableau des Points Projet‚s en X/Y

Projete_3D_Points
		move		#INVTAB,r5
		move		Y:<Z_Ptf,n5
		move		#<Center_X,r4
		move		Y:(r5+n5),y1				; 1 / Z_PtF

		move		#>512,x1

		Do		x0,Projete_Points

		move		X:(r0)+,x0
		move		x1,a
		macr		-x0,y1,a		X:(r0)+,x0
		move		a,n5
		move		Y:(r4)+,a
		move		Y:(r5+n5),y0
		macr		x0,y0,a		X:(r0)+,x0	Y:(r4)-,b
		macr		x0,y0,b		a,X:(r1)
		move		b,Y:(r1)+

Projete_Points
		rts

; Calcule la matrice pour rotations et translations 3D
; Registres en entr‚e :
; r0 = Adresse des 3 Rotations et 3 Translations en X

Calcule_Matrice
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

End_Code

			org		L:0

EQUA_D		DS		1

			org		X:1

First_MinMax		DS		2
Second_MinMax		DS		2

First_Rotations	DS		3
First_Translat		DS		3
First_Adr_Points	DS		1
First_Nb_Points	DS		1
First_Adr_Faces	DS		1
First_Nb_Faces		DS		1
First_CoeffLight	DS		1
FirstNbVisiFaces	DS		1

Second_Rotations	DS		3
Second_Translat	DS		3
Second_Adr_Points	DS		1
Second_Nb_Points	DS		1
Second_Adr_Faces	DS		1
Second_Nb_Faces	DS		1
Second_CoeffLight	DS		1
SecondNbVisiFaces	DS		1

Matrice			DS		12

			org		Y:1

			DS		4
Center_X		DC		160
Center_Y		DC		100
Z_Ptf		DC		300
Off7_Scr		DC		2*320
Adr_Scr		DS		1
YMin			DS		1
YMax			DS		1
Coeff_Light	DS		1
Screen_Adress	DS		1
Colors_Adress	DS		1
Save_r0		DS		1
Save_r1		DS		1
Faces_Pointer	DS		1
Points_Pointer	DS		1

First_Points	DS		1
Second_Points	DS		1

Object_Points	DS		1
Object_Faces	DS		1
Obj_Visi_Faces	DS		1
Ref_Points	DS		1
Ref_Faces		DS		1
Ref_Nb_Faces	DS		1

Nb_Faces		DS		1
Nb_Points		DS		1
Curr_Point	DS		1
Point_Adr		DS		1
Last_Potentiel	DS		1

VECTORS		DS		6
EQUATION		DS		4

			org		X:End_Code

			DS		100
XMIN			DS		300
XMAX			DS		300

PTS_SCR		DS		15
TRI_TAB		DS		200
POINTS_2D		DS		200*5

FIRST_PTS_2D	DS		35
SECOND_PTS_2D	DS		35
FIRST_PTS_3D	DS		35*3
SECOND_PTS_3D	DS		35*3

FIRST_FACES	DS		35*(1+1+1)
FIRST_POINTS	DS		35*4*3
SECOND_FACES	DS		35*(1+1+1)
SECOND_POINTS	DS		35*4*3

FACES		DS		200*(1+1+1)
POINTS		DS		200*5*3

FINAL_TAB		DS		200*(1+1+1+1)

			org		Y:End_Code

			DS		100
			DS		300
			DS		300
			DS		15
			DS		200
			DS		200*5
			DS		35
			DS		35

; Description des objets
; Adresse des points, nombre de points
; Adresse des faces, nombre de faces
; Coefficient pour le Gouraud Shading [rapport Intensit‚ / Profondeur (Z)]

OBJETS		
			DC		CUBE1_POINTS,8,CUBE1_FACES,6,$800000*987/1400
			DC		CUBE2_POINTS,8,CUBE2_FACES,6,$800000*987/1400
			DC		PLAQUE_POINTS,8,PLAQUE_FACES,6,$800000*987/1400
			DC		GATO_POINTS,24,GATO_FACES,26,$800000*987/500
			DC		GATO_POINTS,24,GATO2_FACES,26,$800000*987/500
			DC		CROIX1_POINTS,32,CROIX1_FACES,30,$800000*987/500
			DC		CRAYON_POINTS,13,CRAYON_FACES,13,$800000*987/500
			DC		CUBE3_POINTS,8,CUBE3_FACES,6,$800000*987/1400
			DC		GOMME_POINTS,8,GOMME_FACES,6,$800000*987/1400

; Description des Faces
; Nombre de Points
; Liste des num‚ros de Point
; Type de polygone :	1 = Normal	Couleur
;					2 = Gouraud	Infos Adresse Couleurs
;					3 = Mapping	Infos Adresse Image + Coordonn‚es

CROIX1_POINTS	DC		-10*512,-80*512,10*512
			DC		+10*512,-80*512,10*512
			DC		+10*512,-10*512,10*512
			DC		+80*512,-10*512,10*512
			DC		+80*512,+10*512,10*512
			DC		+10*512,+10*512,10*512
			DC		+10*512,+80*512,10*512
			DC		-10*512,+80*512,10*512
			DC		-10*512,+10*512,10*512
			DC		-80*512,+10*512,10*512
			DC		-80*512,-10*512,10*512
			DC		-10*512,-10*512,10*512
			
			DC		-10*512,-10*512,80*512
			DC		+10*512,-10*512,80*512
			DC		+10*512,+10*512,80*512
			DC		-10*512,+10*512,80*512

			DC		-10*512,-80*512,-10*512
			DC		+10*512,-80*512,-10*512
			DC		+10*512,-10*512,-10*512
			DC		+80*512,-10*512,-10*512
			DC		+80*512,+10*512,-10*512
			DC		+10*512,+10*512,-10*512
			DC		+10*512,+80*512,-10*512
			DC		-10*512,+80*512,-10*512
			DC		-10*512,+10*512,-10*512
			DC		-80*512,+10*512,-10*512
			DC		-80*512,-10*512,-10*512
			DC		-10*512,-10*512,-10*512
			
			DC		-10*512,-10*512,-80*512
			DC		+10*512,-10*512,-80*512
			DC		+10*512,+10*512,-80*512
			DC		-10*512,+10*512,-80*512

CROIX1_FACES	DC		4,0,1,2,11,1,6*2048+6*64+10
			DC		4,1,17,18,2,1,6*2048+7*64+10
			DC		4,16,27,18,17,1,6*2048+8*64+11
			DC		4,0,11,27,16,1,6*2048+9*64+11
			DC		4,0,16,17,1,1,7*2048+10*64+12

			DC		4,2,3,4,5,1,7*2048+11*64+12
			DC		4,2,18,19,3,1,7*2048+12*64+13
			DC		4,19,18,21,20,1,7*2048+13*64+13
			DC		4,5,4,20,21,1,8*2048+14*64+14
			DC		4,3,19,20,4,1,8*2048+15*64+14

			DC		4,8,5,6,7,1,8*2048+16*64+15
			DC		4,5,21,22,6,1,8*2048+17*64+15
			DC		4,21,24,23,22,1,9*2048+18*64+16
			DC		4,8,7,23,24,1,9*2048+19*64+16
			DC		4,7,6,22,23,1,9*2048+20*64+17

			DC		4,10,11,8,9,1,9*2048+21*64+17
			DC		4,10,26,27,11,1,10*2048+22*64+18
			DC		4,27,26,25,24,1,10*2048+23*64+18
			DC		4,9,8,24,25,1,10*2048+24*64+19
			DC		4,10,9,25,26,1,10*2048+25*64+19

			DC		4,12,13,14,15,1,11*2048+26*64+20
			DC		4,12,11,2,13,1,11*2048+27*64+20
			DC		4,13,2,5,14,1,11*2048+28*64+21
			DC		4,15,14,5,8,1,11*2048+29*64+21
			DC		4,12,15,8,11,1,12*2048+30*64+22

			DC		4,29,28,31,30,1,12*2048+31*64+22
			DC		4,18,29,30,21,1,12*2048+31*64+23
			DC		4,24,21,30,31,1,12*2048+31*64+23
			DC		4,27,24,31,28,1,13*2048+31*64+24
			DC		4,28,29,18,27,1,13*2048+31*64+24

CUBE1_FACES	DC		4,7,6,5,4,1,10*2048+10*64+30
			DC		4,0,3,7,4,1,10*2048+10*64+28
			DC		4,0,1,2,3,1,10*2048+10*64+26
			DC		4,1,5,6,2,1,10*2048+10*64+24
			DC		4,0,4,5,1,1,10*2048+10*64+22
			DC		4,3,2,6,7,1,10*2048+10*64+20

CUBE1_POINTS	
			DC		-50*512,-50*512,+50*512
			DC		+50*512,-50*512,+50*512
			DC		+50*512,+50*512,+50*512
			DC		-50*512,+50*512,+50*512
			
			DC		-50*512,-50*512,-50*512
			DC		+50*512,-50*512,-50*512
			DC		+50*512,+50*512,-50*512
			DC		-50*512,+50*512,-50*512

CUBE2_FACES	
			DC		4,7,6,5,4,1,30*2048+10*64+10
			DC		4,0,3,7,4,1,28*2048+10*64+12
			DC		4,0,1,2,3,1,26*2048+10*64+14
			DC		4,1,5,6,2,1,24*2048+10*64+16
			DC		4,0,4,5,1,1,22*2048+10*64+18
			DC		4,3,2,6,7,1,20*2048+10*64+20

CUBE2_POINTS	
			DC		-45*512,-45*512,+45*512
			DC		+45*512,-45*512,+45*512
			DC		+45*512,+45*512,+45*512
			DC		-45*512,+45*512,+45*512
			
			DC		-45*512,-45*512,-45*512
			DC		+45*512,-45*512,-45*512
			DC		+45*512,+45*512,-45*512
			DC		-45*512,+45*512,-45*512

CUBE3_FACES	
			DC		4,7,6,5,4,1,16*2048+0*64+10
			DC		4,0,3,7,4,1,18*2048+0*64+12
			DC		4,0,1,2,3,1,20*2048+0*64+14
			DC		4,1,5,6,2,1,22*2048+0*64+16
			DC		4,0,4,5,1,1,24*2048+0*64+18
			DC		4,3,2,6,7,1,26*2048+0*64+20

CUBE3_POINTS	
			DC		-30*512,-30*512,+30*512
			DC		+30*512,-30*512,+30*512
			DC		+30*512,+30*512,+30*512
			DC		-30*512,+30*512,+30*512
			
			DC		-30*512,-30*512,-30*512
			DC		+30*512,-30*512,-30*512
			DC		+30*512,+30*512,-30*512
			DC		-30*512,+30*512,-30*512


PLAQUE_FACES	
			DC		4,7,6,5,4,1,3*2048+2*64+10
			DC		4,0,3,7,4,1,4*2048+2*64+12
			DC		4,0,1,2,3,1,5*2048+2*64+14
			DC		4,1,5,6,2,1,6*2048+4*64+16
			DC		4,0,4,5,1,1,7*2048+4*64+18
			DC		4,3,2,6,7,1,8*2048+4*64+20

PLAQUE_POINTS	DC		-80*512,-80*512,+10*512
			DC		+80*512,-80*512,+10*512
			DC		+80*512,+80*512,+10*512
			DC		-80*512,+80*512,+10*512
			
			DC		-80*512,-80*512,-10*512
			DC		+80*512,-80*512,-10*512
			DC		+80*512,+80*512,-10*512
			DC		-80*512,+80*512,-10*512

GATO_FACES	DC		4,0,1,9,8,1,2048*17+31
			DC		4,9,2,3,10,1,2048*18+31
			DC		4,11,10,4,5,1,2048*6+7
			DC		4,7,8,11,6,1,2048*6+8
			DC		4,0,12,13,1,1,2048*7+9
			DC		4,2,14,15,3,1,2048*7+10
			DC		4,5,4,16,17,1,2048*8+11
			DC		4,7,6,18,19,1,2048*8+12
			DC		4,13,12,20,21,1,2048*9+13
			DC		4,14,21,22,15,1,2048*9+14
			DC		4,22,23,17,16,1,2048*10+15
			DC		4,20,19,18,23,1,2048*10+16
			DC		4,8,9,10,11,1,2048*11+17
			DC		4,21,20,23,22,1,2048*11+18
			DC		4,1,13,14,2,1,2048*12+19
			DC		4,3,15,16,4,1,2048*12+20
			DC		4,6,5,17,18,1,2048*13+21
			DC		4,0,7,19,12,1,2048*13+22
			DC		3,1,2,9,1,2048*14+23
			DC		3,10,3,4,1,2048*14+24
			DC		3,21,14,13,1,2048*15+25
			DC		3,16,15,22,1,2048*15+26
			DC		3,0,8,7,1,2048*16+27
			DC		3,11,5,6,1,2048*16+28
			DC		3,19,20,12,1,2048*17+29
			DC		3,18,17,23,1,2048*17+30

GATO2_FACES	DC		4,0,1,9,8,1,2048*27+64*8+16
			DC		4,9,2,3,10,1,2048*28+64*8+16
			DC		4,11,10,4,5,1,2048*29+64*8+17
			DC		4,7,8,11,6,1,2048*30+64*9+17
			DC		4,0,12,13,1,1,2048*5+64*2+6
			DC		4,2,14,15,3,1,2048*6+64*2+6
			DC		4,5,4,16,17,1,2048*7+64*2+7
			DC		4,7,6,18,19,1,2048*8+64*2+7
			DC		4,13,12,20,21,1,2048*9+64*3+8
			DC		4,14,21,22,15,1,2048*10+64*3+8
			DC		4,22,23,17,16,1,2048*11+64*3+9
			DC		4,20,19,18,23,1,2048*12+64*3+9
			DC		4,8,9,10,11,1,2048*13+64*4+10
			DC		4,21,20,23,22,1,2048*14+64*4+10
			DC		4,1,13,14,2,1,2048*15+64*4+11
			DC		4,3,15,16,4,1,2048*16+64*4+11
			DC		4,6,5,17,18,1,2048*17+64*5+12
			DC		4,0,7,19,12,1,2048*18+64*5+12
			DC		3,1,2,9,1,2048*19+64*5+13
			DC		3,10,3,4,1,2048*20+64*5+13
			DC		3,21,14,13,1,2048*21+64*6+14
			DC		3,16,15,22,1,2048*22+64*6+14
			DC		3,0,8,7,1,2048*23+64*6+15
			DC		3,11,5,6,1,2048*24+64*6+15
			DC		3,19,20,12,1,2048*25+64*7+16
			DC		3,18,17,23,1,2048*26+64*7+16

GATO_POINTS	DC		-20*512,-60*512,20*512
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

GOMME_FACES	DC		4,7,6,5,4,1,20*2048+3*64+5
			DC		4,0,3,7,4,1,22*2048+5*64+7
			DC		4,0,1,2,3,1,24*2048+7*64+9
			DC		4,1,5,6,2,1,26*2048+9*64+11
			DC		4,0,4,5,1,1,28*2048+11*64+13
			DC		4,3,2,6,7,1,30*2048+13*64+15

GOMME_POINTS	
			DC		-30*420,-20*420,+30*420
			DC		+55*420,-20*420,+30*420
			DC		+30*420,+20*420,+30*420
			DC		-55*420,+20*420,+30*420
			
			DC		-30*420,-20*420,-30*420
			DC		+55*420,-20*420,-30*420
			DC		+30*420,+20*420,-30*420
			DC		-55*420,+20*420,-30*420

CRAYON_FACES	DC		4,7,12,11,4,1,10*2048+10*64+30
			DC		4,11,12,6,5,1,10*2048+10*64+30
			DC		4,0,9,10,3,1,10*2048+10*64+26
			DC		4,10,9,1,2,1,10*2048+10*64+26
			DC		4,1,5,6,2,1,24*2048+10*64+10
			DC		4,0,4,11,9,1,10*2048+10*64+22
			DC		4,9,11,5,1,1,10*2048+10*64+22
			DC		4,3,10,12,7,1,10*2048+10*64+20
			DC		4,12,10,2,6,1,10*2048+10*64+20

			DC		3,3,8,0,1,20*2048+8*64+4
			DC		3,7,8,3,1,22*2048+10*64+6
			DC		3,4,8,7,1,24*2048+12*64+8
			DC		3,0,8,4,1,26*2048+14*64+10

CRAYON_POINTS	
			DC		-70*512,-10*512,+10*512
			DC		+70*512,-10*512,+10*512
			DC		+70*512,+10*512,+10*512
			DC		-70*512,+10*512,+10*512
			
			DC		-70*512,-10*512,-10*512
			DC		+70*512,-10*512,-10*512
			DC		+70*512,+10*512,-10*512
			DC		-70*512,+10*512,-10*512

			DC		-90*512,+00*512,+00*512

			DC		0*512,-10*512,+10*512
			DC		0*512,+10*512,+10*512
			DC		0*512,-10*512,-10*512
			DC		0*512,+10*512,-10*512

INVBEG		DS		500
INVTAB		DS		1
			DS		3000

SINTAB		DS		90
COSTAB		DS		360

			END
