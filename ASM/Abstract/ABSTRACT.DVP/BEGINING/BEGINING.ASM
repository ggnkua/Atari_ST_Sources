;*************************************************************************
;***********										 							***********
;***********		 Tridi codes by SKYNET From ABSTRACT			***********
;***********										 							***********
;***********				Au DSP, source DSP							***********
;***********										 							***********
;*************************************************************************

PBC		equ		$ffe0												; Port B Control Register
HSR		equ		$ffe9												; Host Status Register
HRX		equ		$ffeb												; Host Receive Register
HTX		equ		$ffeb												; Host Transmit Register

HRDF		equ		0													; Host Receive Data Full
HTDE		equ		1													; Host Transmit Data Empty

Host_Send_Data		Macro		Data
_Host_Request
		jclr		#<HTDE,X:<<HSR,_Host_Request			; On attend la dispo du port Host
		movep		Data,X:<<HTX								; On transfert la valeur sp‚cifi‚e
	EndM

Host_Get_Data		Macro		Data
_Host_Request
		jclr		#<HRDF,X:<<HSR,_Host_Request			
		movep		X:<<HRX,Data								
	EndM

;********************
;*      DEBUT       *
;********************

		ORG		P:0
	
		jmp		Start

		ORG		P:410

Start	
		movep	#1,X:<<PBC										; Port B en Host

; Pour v‚rifier la connexion
Conct_Get	
	Host_Get_Data		x0
		move		#>$4321,A							; Valeur qui doit normalement se trouver dans x0
		cmp		x0,A									; On compare le Magic Number
		jne		Conct_Get							; C pas le bon, on reboucle
	Host_Send_Data		#12345678

		jmp		Init_Tridi							; ON VA EFFECTUER LES INITS (GET_DATA_SCENE)
Gestion
	Host_Get_Data		A								; ON TEST LA SYNCHRO AVEC LE 030
		move		#>$1212,B
		cmp		A,B
		jne		Problem
	Host_Send_Data		#$2121						; On signale au 030 que tout a bien ete recu
		jmp		Loop			
Problem													; Ya un probleme, on renvoie tjrs la meme val
	Host_Send_Data		#$0101						; en rebouclant, pour ne pas stopper le 030
		jmp		Problem

;**********************************************************************
;***************  BOUCLE PRINCIPALE EN MEMOIRE INTERNE ****************
;**********************************************************************
Loop		
		move		#>$3210,B
Wait_Synchro_Vbl										; SYNCHRO VBL-030/DSP
	Host_Get_Data		A
		cmp		A,B
		jne		Wait_Synchro_Vbl	

		move		#Tab_Eff,r0
	DO				#<4,_Send_Clear_Zone
	Host_Send_Data		X:(r0)+
_Send_Clear_Zone	

		move		#Tab_1_030,r0
		move		X:Tab_030_Pos,A
_Send_Faces
		move		r0,x0
		cmp		x0,A									; Est-on a la fin du tablo ?
		jeq		_End_Tab
	Host_Send_Data		X:(r0)+						; On envoie la couleur
		move		X:(r0)+,x0							; Nombre de point de la face
	Host_Send_Data		x0								; On l'envoie au 030
	DO				x0,_Send_Pts_Face
		Host_Send_Data	X:(r0)+						; On envoie les coordonnees de la face
		Host_Send_Data	X:(r0)+
_Send_Pts_Face	
		jmp		_Send_Faces
_End_Tab		
	Host_Send_Data		#>$4321					; On envoie un flag pour indiquer que l'envoie est fini

;************* DEBUT DE LA ROUTINE DE GESTION DU MONDE ****************

; On recoit la position courante de l'objet
		bclr		#<2,OMR
		jsr		Get_State
; On reactualise la rotation des objets
		bclr		#<2,OMR
		jsr		Calc_Rotation
; On rotate les objets en fonction de leur position courante
		bclr		#<2,OMR
		jsr		Rotate_Objects
; On calcule le barycentre de chaques faces des objets
		bclr		#<2,OMR
		jsr		Calcule_Bary
; Vu que les barycentres sont calcules, on projete les points 3D
		bclr		#<2,OMR
		jsr		Proj_3D_Pts
; On scan le contour de l'objet pour obtnir le carre qui va l'effacer
		bclr		#<2,OMR
		jsr		Scan_Shape
; On va tester la visibilitee des faces, et stocke leur Barycentre, Adr de la face, Adr pts 2D
		bclr		#<2,OMR
		jsr		Sort_Faces
; On va srocker les faces visibles et triees sur Z
		bclr		#<2,OMR
		jsr		Make_Tab

		jmp		<Loop

Get_State
		move		#Scene_Descriptor,r0
		move		#<3,n0
	DO				#<3,_Get_Angle
	Host_Get_Data	X:(r0)+
_Get_Angle	
		lua		(r0)+n0,r0
	DO				#<3,_Get_Tr
	Host_Get_Data	x0
		move		X:(r0),A
		add		x0,A
		move		A,X:(r0)+
_Get_Tr	
	Rts

Scan_Shape
		move		#Points_Projeted,r0
		move		#Tab_Eff,r1
		move		X:Scene_Descriptor+9,r2
		move		#>4000,x0
		move		#>-4000,x1
		move		#>4000,y0
		move		#>-4000,y1
	DO				X:(r2),_Scan_Shape_Obj
		move		X:(r0)+,A
		cmp		x0,A
		jgt		_Xmax
		move		A,x0
_Xmax	cmp		x1,A
		jlt		_Ymin
		move		A,x1
_Ymin	move		X:(r0)+,A
		cmp		y0,A		
		jgt		_Ymax
		move		A,y0
_Ymax
		cmp		y1,A
		jlt		_Loop
		move		A,y1		
_Loop
	nop	
_Scan_Shape_Obj	

		move		x0,X:(r1)+
		move		x1,X:(r1)+
		move		y0,X:(r1)+
		move		y1,X:(r1)+

	Rts

Calc_Rotation
		move		#Scene_Descriptor,r0
		move		#<3,n0
		move		#>360,y1
		lua		(r0)+n0,r1
	DO				#<3,_Clip_Rot
			move		X:(r0)+,x0
			move		X:(r1),A
			add		x0,A
			cmp		y1,A
			jlt		_No_Clip
			sub		y1,A
_No_Clip	
			move		A,X:(r1)+				
_Clip_Rot
		Rts
					
Rotate_Objects
			move		#Scene_Descriptor+3,r1
			move		#Data_Matrice,r0						; matrice de rotation et translation de l'objet
		DO				#<6,_Tfr_Data
				move		X:(r1)+,x0
				move		x0,X:(r0)+					; on transfert les donnees pr le calcul de la matrice
_Tfr_Data
			move		#Data_Matrice,r0
			move		#Matrice,r1								; Matrice calculee
			Jsr		Calc_Matrice							; on calcule la matrice

			move		#Scene_Descriptor+9,r1				; Pointe sur l'adr DSP de l'objet
			move		#Buffer_Pts,r4							; Buffer source pour les points 3D a calculer
			move		X:(r1)+,r3								; On obtient l'adresse de l'objet
			move		#Points_Rotated,r2					; Buffer pour stocker les points 3D
			move		X:(r3)+,x0								; nombre de points 3D
			move		x0,A
			move		A,B
			addl		B,A										; On multiplie par 3
			move		#>256,y0
		DO				A,_Tfr_Pts_3D
				move		X:(r3)+,x1
				mpy		y0,x1,B								; fois 512
				move		b0,Y:(r4)+
_Tfr_Pts_3D
			move		#Matrice,r0								; matrice calculee
			move		#Buffer_Pts,r4							; buffer des points a calculer

			jsr		Rot_Trans_Pts							; on rotate tout les points.
		Rts

Calcule_Bary
			move		#Scene_Descriptor+9,r0
			move		#Inv_Tab,r5								; Table des inverses
			move		X:(r0)+,r1								; Adr DSP de la description de l'objet
			move		#Bary_Faces,r4							; Buffer ou l'on stocke les bary de chak faces
			move		X:(r1)+,A								; Nombre de points 3D
			move		A,B
			addl		B,A										; Fois 3, car comme tjrs 3 coordonnees/pts
			move		A,n1										; Offset pour sauter la Desc des points
			nop
			lua		(r1)+n1,r1								; On pointe sur le nbr de face
			nop
			move		X:(r1)+,x1								; Nombre de faces
			move		x1,X:(r4)+								; On l'inscrit dans le tablo pour les bary
		DO				x1,_Calc_1_Bary						; On calcule le barycentre de toutes les faces
				move		r1,r3									; On sauve l'adr pointant sur la desc de la face
				lua		(r1)+,r1								; On saute la couleur
				clr		A										; Zero point --> somme des Z a zero
				move		X:(r1)+,n5							; Nombre de points de la face
			DO				n5,_Add_Z
					move		#Points_Rotated,r2			; Buffer pour stocker les points 3D
					move		X:(r1)+,x1						; Numero du point
					move		x1,B
					add		x1,B								; Num * 2
					add		x1,B								; Num * 3
					move		B,n2								; Offset dans la table
					nop
					move		X:(r2+n2),y1					; on obtient le Z*512 du point
					add		y1,A								; on addition le Z pour pouvoir faire une moyenne
_Add_Z
				move		Y:(r5+n5),x1						; 1/Nbr de point
				move		A,y1									; somme des Z de la face
				mpy		x1,y1,A								; on obtient le barycentre de la face
				move		A,X:(r4)+							; on inscrit le barycentre de la face
				move		r3,X:(r4)+
_Calc_1_Bary
		Rts

Proj_3D_Pts
			move		#Scene_Descriptor+9,r0
			move		#Inv_Tab,r3								; table des inv pour eviter la division
			move		#Points_Projeted,r4					; Buffer pour les points projetes
			move		X:(r0)+,r1								; Adresse de la description de l'objet
			move		#Points_Rotated,r2
		DO				X:(r1),_Proj_Pts						; Nombre de point a projeter
				move		X:(r2)+,x0							; ZPts*512
				move		#>512,A								; 1*512
				move		Y:P_Fuite,y0						; 2^23/P_Fuite
				macr		-y0,x0,A								; (1-(Ze/P)*512 = Q*512
				move		A,n3									; Offset ds la table des inv pour obtenir 1/Q
				move		X:(r2)+,x1							; Xe*512
				move		Y:(r3+n3),x0						; 512/Q
				move		X:C_X,A
				mac		x1,x0,A								; Xp
				move		X:(r2)+,y0							; Ye*512
				move		X:C_Y,B
				mac		y0,x0,B								; Yp
				move		A,X:(r4)+							; Stocke X
				move		B,X:(r4)+							; Stocke Y
_Proj_Pts
		Rts	

Sort_Faces
		move		#Sort_Faces,r1								; Tablo contenant les adresses des face triees
		move		X:Bary_Faces,x0							; Nombre de faces
		move		x0,X:(r1)+
		move		#>8388606,y0								; Plus grande valeur
	DO				x0,_Sort_Faces
			move		#Bary_Faces,r0
			move		#>8388605,A
		DO				X:(r0)+,_Sort_1
			move		X:(r0)+,x0								; Barycentre de la face
			cmp		x0,A										; On compare avec le bary actuel
			jlt		_No										; Si l'actuel est plus grd, on continue
			move		x0,A
			move		r0,r2
_No		lua		(r0)+,r0									; On pointe sur le bary suivant
			nop
_Sort_1
			lua		(r2)-,r2									; On pointe sur la valeur du barycentre
			nop
			move		y0,X:(r2)+								; On la mets hors-concours
			move		X:(r2)+,r3								
			move		r3,X:(r1)+								; On obtient l'adr de la desc de la face
_Sort_Faces
	Rts
		
Make_Tab
		move		#Sort_Faces,r0								; Nombre de face + adresse de leur desc
		move		#Tab_1_030,r1								; Tablo de sortie

	DO				X:(r0)+,_Test_Visi_Face
			
			move		X:(r0)+,r2								; r2 = Adr de la face
			move		r2,r6										; On sauvegarde l'adr de la face
			move		#Points_Projeted,r3
			lua		(r6)+,r6									; On saute la couleur
			move		r3,r4										; On pointe sur le buffer de points 2D
			move		X:(r6)+,n2								; Nbr de points
			move		r3,r5										; Pareille tout comme miguel
			move		X:(r6)+,A								; A = numero du 1er point de la face
			lsl		A				X:(r6)+,B				; B = numero du 2eme point de la face 
			lsl		B				A,n3						; n3 = offset du 1er point ds le tps_pts
			move		X:(r6)+,A								; A = numero du 3eme point de la face
			lua		(r3)+n3,r3								; r3 pointe sur les coords du 1er point
			lsl		A				B,n4						; ect...
			move		A,n5				
			lua		(r4)+n4,r4								; r4 pointe sur les coords du 2eme point
			lua		(r5)+n5,r5								; r5 pointe sur les coords du 3eme point
		
			move		X:(r4)+,A
			move		X:(r3)+,x0				
			sub		x0,A				X:(r4),B							; XPts2 - XPts1 = y0
			move		X:(r3),x1				
			sub		x1,B				A,y0			X:(r5)+,A		; YPts2 - YPts1 = y1
			sub		x0,A				B,y1								; Xpts3 - XPts1 = x0
			move		A,x0
			mpy		y1,x0,A			X:(r5),B							; (XPts3 - XPts1) * (YPts2 - YPts1)
			sub		x1,B													; YPts3 - YPts1 = x0
			move		B,x0
			mpy		x0,y0,B												; (Xpts2 - Xpts1) * (YPts3 - YPts1)
			sub		B,A

			jpl		_Nxt_Face
			
			move		#Points_Projeted,r3
			move		X:(r2)+,x0							; Couleur de la face
			move		x0,X:(r1)+
			move		X:(r2)+,x0							; Nombre de points
			move		x0,X:(r1)+
		DO				x0,_Tfr_Pts
			move		X:(r2)+,A
			lsl		A
			move		A,n4
			move		r3,r4
			nop
			lua		(r4)+n4,r4
			nop
			move		X:(r4)+,x0
			move		x0,X:(r1)+			
			move		X:(r4)+,x0
			move		x0,X:(r1)+			
_Tfr_Pts
		nop
_Nxt_Face
		nop
_Test_Visi_Face

		move		r1,X:Tab_030_Pos
	Rts
	
Init_Tridi

		jsr		Get_Table_1_X
		jsr		Get_Table_Cosin
		jsr		Get_Variables
		
		move		#P_Fuite,r0								; Kestion de flemme !!!!
		move		X:Pt_Fuite,x0							; Point de fuite
		move		x0,Y:(r0)								; yop!!!
		
Get_Def_Objects
		move		#Objects_Descriptor,r0				; Buffer ou l'on va stocker les description des obj
		move		#Corresp_030_DSP,r1					; Adr du tableau de correspondance
	Host_Get_Data		x0									; Nbr d'objet en tout
	DO				x0,Get_All_Objects
	Host_Get_Data		X:(r1)+							; On inscrit l'adr 030 de l'objet qui va suivre
		move		r0,X:(r1)+								; On inscrit l'adr DSP de l'objet

	Host_Get_Data		A									; Nombre de points 3D
		move		A,X:(r0)+								; on inscrit le nombre de points ds la description
		move		A,B
		addl		B,A										; trois coordonnees par points
	DO				A,_Get_All_Pts
		Host_Get_Data		X:(r0)+						; on receptionne toutes les coords de chaques points
_Get_All_Pts		

	Host_Get_Data		x0									; Nombre de faces
		move		x0,X:(r0)+
	DO				x0,_Get_Faces
		Host_Get_Data		X:(r0)+						; Receptionne le numero de la couleur
		Host_Get_Data		x0								; Nombre de points pour la face
			move		x0,X:(r0)+
		DO				x0,_Get_Pts
			Host_Get_Data		X:(r0)+					; Inscrit le numero des points
_Get_Pts
			nop												; Ca evite un warning ki fait chier
_Get_Faces
		nop													; pareille
Get_All_Objects											; On reboucle pour transferer toutes les objets


Get_Def_Scene
		move		#Scene_Descriptor,r0					; Description de la 'scene'
		move		#Corresp_030_DSP+1,r1				; Tablo de correspondance des adr Obj
		DO				#<9,_Get_Header
		Host_Get_Data		X:(r0)+						; on recoit : Increment de rotation et etat T
_Get_Header
	Host_Get_Data		A									; Adresse 030 de l'objet
_Find_Corresp
		move		X:(r1)+,x0
		move		x0,X:(r0)+

	jmp			Gestion

Get_Table_Cosin
		move		#Cos_Tab,r0
	DO				#360,_Get_All_Cos
	Host_Get_Data	X:(r0)+
_Get_All_Cos	
		move		#Sin_Tab,r1
	DO				#360,_Get_All_Sin
	Host_Get_Data	X:(r1)+
_Get_All_Sin
	Rts

Get_Variables
		move		#Pt_Fuite,r0
	DO				#5,_Get_Variables
	Host_Get_Data		X:(r0)+
_Get_Variables	

	Rts

; Table de 1/x n‚cessaire aux routines. A charger en inits
Get_Table_1_X
		move		#Inv_Beg,r0
	DO				#<3351,Get_Inv_Table
	Host_Get_Data	Y:(r0)+
Get_Inv_Table
		Rts

; X:(r0) = Donn‚es de la matrice
; X:(r2) = Coordonn‚es du point rotat‚
; Y:(r4) = Pointe sur les coordonn‚es de d‚part du point
; x0 = nbr de point … calculer
Rot_Trans_Pts
		move		#>12,n0
	DO				x0,_Calc_All_Points

			move		X:(r0)+,A						Y:(r4)+,y0	; TZ                 | Xe
			move		X:(r0)+,x0						Y:(r4)+,y1	; C                  |          | Ye
			mac		x0,y0,A			X:(r0)+,x0					; C*Xe               | F        |
			mac		x0,y1,A			X:(r0)+,x0	Y:(r4)-,y1	; C*xe + F*Ye        | I        | Ze
			macr		x0,y1,A			X:(r0)+,B					; C*Xe + F*Ye + I*Ze | TX       | 
			move		A,X:(r2)+										; NZe                |          |

			move		X:(r0)+,x0
			mac		x0,y0,B			X:(r0)+,x0	Y:(r4)+,y1	; A*Xe               | D        | Ye
			mac		x0,y1,B			X:(r0)+,x0	Y:(r4)-,y1	; A*Xe + D*Ye        | G        | Ze
			macr		x0,y1,B			X:(r0)+,A					; A*Xe + D*Ye + G*Ze | TY       |
			move		B,X:(r2)+										; NZe                |          |
		
			move		X:(r0)+,x0
			mac		x0,y0,A			X:(r0)+,x0	Y:(r4)+,y1	; B*Xe               | E        | Ye
			mac		x0,y1,A			X:(r0)+,x0	Y:(r4)+,y1	; B*Xe + E*Ye        | H        | Ze
			macr		x0,y1,A			(r0)-n0						; B*Xe + E*Ye + H*Ze | Yc       |
			move		A,X:(r2)+										; NYe                |          |
		
_Calc_All_Points

	Rts		

; Calcule la matrice pour rotations 3D
; - r0 = Buffer contenant rotations et translations
; * r1 = Buffer de destination contenant la matrice
Calc_Matrice
		move		#Cos_Tab,r2			
		move		#Sin_Tab,r5
		move		r2,r3
		move		r5,r6

		move		X:(r0),n2						; Offset pour cos X dans la table sinus
		move		X:(r0)+,n5
		lua		(r2)+n2,r2						; Cos a
		lua		(r5)+n5,r5						; Sin a
		move		X:(r0)+,x0
		move		x0,n3
		move		x0,n6
		lua		(r3)+n3,r3						; Cos b
		lua		(r6)+n6,r6						; Sin b
		move		X:(r0)+,A
		sub		x0,A			#<2,n0
		move		A,n3								; Cos c
		move		A,n6								; Sin c

		move		X:(r0+n0),A						; Trans Z
		move		A,X:(r1)+

		move		X:(r6),A
		neg		A
		move		A,X:(r1)+

		move		X:(r3),x0
		move		X:(r5),y0
		mpyr		x0,y0,A
		move		A,X:(r1)+
		
		move		X:(r3),x0
		move		X:(r2),y0
		mpyr		x0,y0,A
		move		A,X:(r1)+

 		move		X:(r0)+,A						; Trans X
		move		A,X:(r1)+

		move		X:(r3),x0
		move		X:(r3+n3),y0
		mpyr		x0,y0,A
		move		A,X:(r1)+

		move		X:(r2),x0
		move		X:(r6+n6),y0
		mpy		-y0,x0,A
		move		X:(r3+n3),x0
		move		X:(r6),y0
		mpyr		x0,y0,B
		move		B,x0
		move		X:(r5),y0
		macr		y0,x0,A
		move		A,X:(r1)+

		move		X:(r6+n6),x0
		move		X:(r5),y0
		mpy		y0,x0,A
		move		X:(r3+n3),x0
		move		X:(r6),y0
		mpyr		x0,y0,B
		move		B,x0
		move		X:(r2),y0
		macr		y0,x0,A
		move		A,X:(r1)+

		move		X:(r0)+,A						; Trans Y
		move		A,X:(r1)+
		
		move		X:(r6+n6),y0
		move		X:(r3),x0
		mpyr		x0,y0,A
		move		A,X:(r1)+
		
		move		X:(r2),x0
		move		X:(r3+n3),y0
		mpy		y0,x0,A
		move		X:(r6+n6),x0
		move		X:(r6),y0
		mpyr		x0,y0,B
		move		B,x0
		move		X:(r5),y0
		macr		y0,x0,A
		move		A,X:(r1)+

		move		X:(r3+n3),x0
		move		X:(r5),y0
		mpy		-y0,x0,A
		move		X:(r6+n6),x0
		move		X:(r6),y0
		mpyr		x0,y0,B
		move		B,x0
		move		X:(r2),y0
		macr		y0,x0,A
		move		A,X:(r1)+
	Rts

;******************************************************************************************
	Org	X:$200	; On pointe sur la m‚moire interne car les symboles seront appel‚s souvent.

Nb_Faces							dc		0

Pt_Fuite							ds		1
C_X								ds		1
C_Y								ds		1
DX									ds		1
DY									ds		1

Data_Matrice					dc		0,0,0,0,0,0
Matrice							ds		12			; Emplacement pour matrice + translation

Centre							ds		2

Sav_Reg							ds		16

;***************************************************************************************

; Tableau pour stocker tout les points 3D rotater et translate
Points_Rotated					ds		3*100
; Tableau pour stocker tout les points 3D rotater et translate
Points_Projeted				ds		2*100
; Tableau pour stocker le barycentre de chaques faces
Bary_Faces						ds		2*100
; Tablo ou l'on stocke le carre a effacer
Tab_Eff							dc		10,20,10,20

; Description des objets dans la 'scene'
Scene_Descriptor				ds		1*10

; Tableau de correspondances des adr 030 et DSP des objets
Corresp_030_DSP				ds		2
; Description des objets fixes
Objects_Descriptor			ds		1000			; Emplacement pour la description des objets

; The last Tab
Tab_030_Pos						dc		Tab_1_030		; Adr courante du tableau de donnees pour le 030
Tab_1_030						ds		2000			; tableau final avec le necessaire pour le 030

Cos_Tab							ds		360
Sin_Tab							ds		360
	
;***************************************************************************************
	ORG	Y:$2000         ; A MODIFIER A CHAQUE CREATION DE NOUVEAUX BUFFERS

Buffer_Pts		ds		3*100
P_Fuite			ds		1
Inv_Beg			ds		350
Inv_Tab			ds		1
					ds		3000

