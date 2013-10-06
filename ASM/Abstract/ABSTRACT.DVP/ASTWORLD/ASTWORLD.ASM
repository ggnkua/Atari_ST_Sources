;*************************************************************************
;***********										 							***********
;***********		 Tridi codes by SKYNET From ABSTRACT			***********
;***********										 							***********
;***********				Au DSP, source DSP							***********
;***********										 							***********
;*************************************************************************
; Pour explication sur le principe Multi-Objet utilise voire en bas du source

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

; On envoie au 030 toutes les informations pour afficher les faces
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

;***** ON RECOIE LES POSITIONS COURANTES DE LA CAMERA
Get_Inc_Camera
		move		#Current_State_Camera,r0
		move		#131072,x1							; 2^23/64
	DO				#3,_Get_Camera_Angles
	Host_Get_Data		y0								; On receptionne un angle*64
		mpyr		y0,x1,A								; On divise l'angle par 64
		move		A,X:(r0)+
_Get_Camera_Angles

	DO				#3,_Get_Camera_Trans				; On chope la translation courante de la cam‚ra
	Host_Get_Data		A
		neg		A
		move		A,X:(r0)+							; TX*512,TY*512 et TZ*512
_Get_Camera_Trans

;************* DEBUT DE LA ROUTINE DE GESTION DU MONDE ****************

; Recoit l'etat de chaque objet
		bclr		#<2,OMR
		jsr		Get_New_State
; Recoit la nouvelle description de l'objet si morph en court
		bclr		#<2,OMR
		jsr		Get_Target_Object
; On calcule les nouvelles coordonnees si l'objet est en train de morpher
		bclr		#<2,OMR
		jsr		Calc_New_Object
; On clip les vectors objets
		bclr		#<2,OMR
		jsr		Clip_Objects
		move		X:Screen_Descriptor,A
		tst		A
		jne		Theres
		move		#Tab_1_030,x0
		move		x0,X:Tab_030_Pos
		jmp		Loop
Theres
; on calcule les vecteurs objets en fonction de la position de la camera
		bclr		#<2,OMR
		jsr		Calc_All_Vectors
; On rotate les objets en fonction de leur position courante
		bclr		#<2,OMR
		jsr		Rotate_Objects
; On roatate les objets et on les recentre par rapport a la camera
		bclr		#<2,OMR
		jsr		Rotate_With_Camera
; Vu que les barycentres sont calcules, on projete les points 3D
		bclr		#<2,OMR
		jsr		Proj_3D_Pts
; On calcule le barycentre de chaques faces des objets
		bclr		#<2,OMR
		jsr		Calcule_Bary
; On va tester la visibilitee des faces, et stocke leur Barycentre, Adr de la face, Adr pts 2D
		bclr		#<2,OMR
		jsr		Sort_Faces
; On va srocker les faces visibles et triees sur Z
		bclr		#<2,OMR
		jsr		Make_Tab
T_Loop
		jmp		<Loop

;********************** SOUS ROUTINES ************************

Get_New_State
		move		#Scene_Descriptor,r0
		move		#<6,n0
	DO				X:(r0)+,_Get_State				; Nombre d'objet a reactualiser
			lua		(r0)+n0,r0						; On saute les adr des diff buffer pr l'obj
		DO				#<6,_Get_Pos
		Host_Get_Data		X:(r0)+					; On recoit les 3 rotations et translations
_Get_Pos
		nop												; Fucking PipeLine
_Get_State
	Rts

Get_Target_Object
		move		#Scene_Descriptor,r0
		move		#<11,n0
	DO				X:(r0)+,_Get_Target
		Host_Get_Data		A					; Si A = 0, pas de morph, sinon reception d'1 nouvel obj
			tst		A				(r0)+		; On pointe sur l'adr de l'objet cible
			jeq		_Nxt_Obj
			move		X:(r0)+,r1				; Adresse du buffer de l'objet cible
			move		X:Nb_Inter,x0
			move		x0,X:(r0)-				; Nombre d'interpolations
			move		A,X:(r1)+				; On inscrit le nombre de points
			move		A,B
			addl		B,A						; Nombre de point fois 3 car 3coord par points
		DO				A,_Get_Pts
			Host_Get_Data		X:(r1)+
_Get_Pts
		nop
_Nxt_Obj
		lua		(r0)+n0,r0					; On pointe sur la structure de l'objet suivant
_Get_Target	
		Rts

; Recalcule le vecteur de chaque objets en fonction du Mvt de la camera
Calc_All_Vectors
		move		#Current_State_Camera,r0		; rotations et translations courantes de la camera
		move		#Camera_Matrice,r1

		jsr		Calc_Matrice							; On calcule la matrice de la camera

		move		#Scene_Descriptor,r1					; Description des objets de la scene
		move		#Buffer_Pts,r4							; Buffer ou l'on va stocker les vecteurs
		move		#<9,n1									; offset pour passer au prochain vecteur ds le SD
				
		move		X:(r1)+,x0								; Nombre d'objets
		lua		(r1)+n1,r1								; On pointe sur le vecteur
	DO				x0,_Copy_Pts
		move		X:(r1)+,x1								; On transfert les coordonnees du vecteur
		move		x1,Y:(r4)+
		move		X:(r1)+,x1
		move		x1,Y:(r4)+
		move		X:(r1)+,x1
		move		x1,Y:(r4)+
		lua		(r1)+n1,r1								; on pointe sur le vecteur suivant
		nop
_Copy_Pts

		move		#Buffer_Pts,r4							; Buffer qui contient les coords spa des vecteurs
		move		#Camera_Matrice,r0					; Elle est remplie c'te fois
		move		#Current_Vectors,r2					; Buffer pour le vecteur courant
		jsr		Rot_Trans_Pts							; ON ROTATE LES POINTS AVEC LES ANGLES DE LA CAMERA
	Rts

Calc_New_Object
		move		#Scene_Descriptor,r0
		nop
	DO				X:(r0)+,_Calc_Inter
			move		#<2,n0					; Offset pour atteindre le Inter_Flag
			nop
			move		X:(r0+n0),A				; Inter_Flag
			tst		A				#<12,n0
			jeq		_Nxt_Obj
			move		X:Nb_Inter,x0			; Nombre d'interpolations
			cmp		x0,A						; On compare pour savoir si c un nouvel objer cible
			jne		_Calc_New_Pos			; on va incrementer le Delta actuel pour morpher l'objet
			move		X:(r0)+,r1				; Objet courant
			move		#Inv_Tab,r4				; Table des inverses
			move		x0,n4						; Nombre d'interpolation
			move		X:(r0)-,r2				; Objet cible
			move		Y:(r4+n4),x0			; 1 / Nbr d'interpolation
			lua		(r2)+,r2					; On saute le nbr de pts de l'obj cible ( = a l'obj courant)
			move		X:(r1)+,A				; Nombre de points
			move		A,B
			addl		B,A						; Nombre de points * 3
		DO				A,_Calc_Delta			; On calcule au tant de delta que de points
			move		X:(r2),A					; Coordonnee cible
			move		X:(r1)+,x1				; Coordonnee actuelle
			sub		x1,A						; Delta
			move		A,x1
			mpyr		x1,x0,A					; Delta / Nbr d'interpolations = Increment par VBL
			move		A,X:(r2)+				; On stocke l'increment a la place de la coord cible
_Calc_Delta
			nop									; On commence a calculer l'interpolation, c mieux
_Calc_New_Pos
			move		X:(r0)+,r1				; Adr de l'objet a morpher
			move		X:(r0)+,r2				; Adr du buffer des Increments de morphing
			move		X:(r0),r3				; Nombre d'interpolations restantes
			move		X:(r1)+,A				; Nombre de points de l'objet
			lua		(r3)-,r3					; -1 car interpolation en cour
			move		#<9,n0					; Offset pour pointer sur la desc du prochain objet
			move		r3,X:(r0)+
			move		A,B
			addl		B,A
			lua		(r2)+,r2					; On saute le nombre de points
		DO				A,_New_Pos
			move		X:(r2)+,x0
			move		X:(r1),A
			add		x0,A
			move		A,X:(r1)+				; On stocke la nouvelle coordonnee
_New_Pos		
		nop
_Nxt_Obj
		lua		(r0)+n0,r0					; On pointe sur la description de l'objet suivant
_Calc_Inter	
	Rts

Clip_Objects
			move		#Scene_Descriptor,r0
			move		#Screen_Descriptor+1,r1				; Tablo de sorti identik au SD (obj clippes)
			move		#<0,r6										; Compteur d'objets clippes	
			move		#Current_Vectors,r4
			move		#Inv_Tab,r5
		DO				X:(r0)+,_Clip_Vectors
				move		#<12,n0								; Off7 pour passer a la Desc de l'objet suivant

				move		X:(r4)+,x1								; Coord Z
				move		X:(r4)+,y0								; Coord X
				move		X:(r4)+,y1								; Coord Y

; 				move		X:Lim_ZP,A
;				cmp		x1,A				X:Lim_ZM,B
;				jmi		_Again									; On clip sur Z
;				cmp		x1,B
;				jpl		_Again

;				move		Y:P_Fuite,x0
;				move		#>512,A
;				macr		-x0,x1,A									; 1-(Ze/Pf)
;				move		A,n5
;				move		X:Lim_XP,B
;				move		Y:(r5+n5),x0							; 1/Q
		
;				mpy		x0,y0,A									; On vient de projeter le X
;				cmp		A,B
;				jmi		_Again
;				move		X:Lim_XM,B
;				cmp		A,B				
;				jpl		_Again

;				mpy		x0,y1,A									; On vient de projeter le X
;				move		X:Lim_YP,B
;				cmp		A,B
;				jmi		_Again									; On clip sur Z
;				move		X:Lim_YM,B
;				cmp		A,B
;				jpl		_Again

				lua		(r6)+,r6
		DO			#<12,_Cop_SD_2_sD	
				move		X:(r0)+,x0
				move		x0,X:(r1)+
_Cop_SD_2_sD
				lua		(r0)-n0,r0
				nop
_Again
			lua		(r0)+n0,r0									; On passe a l'objet suivant
_Clip_Vectors
			move		r6,X:Screen_Descriptor				
		Rts

Rotate_Objects
			move		#Screen_Descriptor,r1
			move		#Points_Rotated,r2
		DO				X:(r1)+,_Calc_All_Points
				move		#<6,n1
				move		#Data_Matrice,r0				; matrice de rotation et translation de l'objet
				lua		(r1)+n1,r1						; On pointe sur l'etat courant de l'objet
			DO				#<3,_Tfr_Data
					move		X:(r1)+,x0
					move		x0,X:(r0)+					; on transfert les donnees pr le calcul de la matrice
_Tfr_Data
				move		#>0,x0
				move		x0,X:(r0)+
				move		x0,X:(r0)+
				move		x0,X:(r0)+
				
				move		#<9,n1							; Pour revenir au debut de la description
				move		#Data_Matrice,r0
				lua		(r1)-n1,r1						; On repointe sur le debut de la description
				move		r2,X:Sav_Reg+1					; On sauve l'adr du buffer points 3d
				move		r1,X:Sav_Reg					; On sauve l'adr de la descrition courante
				move		#Matrice,r1						; Matrice calculee

				Jsr		Calc_Matrice					; on calcule la matrice

				move		X:Sav_Reg,r1					; Debut de la description de l'objet
				move		X:Sav_Reg+1,r2					; Buffer tps de points 3d
				move		X:(r1)+,r3						; On obtient l'adresse de l'objet
				move		#Buffer_Pts,r4					; Buffer source pour les points 3D a calculer
				lua		(r1)+,r1							; On saute l'adr du buffer des increments
				move		X:(r3)+,x0						; Nombre de points 3D
				lua		(r1)+,r1							; On pointe sur l'adr du buffer pts 3d
				move		x0,A
				move		r2,X:(r1)+						; On inscrit l'adr du buffer de points 3d
				move		A,B
				addl		B,A				#<8,n1		; On multiplie par 3
		DO				A,_Tfr_Pts_3D						; On transfert les points  a calculer en Y:
					move		X:(r3)+,x1
					move		x1,Y:(r4)+
_Tfr_Pts_3D
				move		#Matrice,r0						; matrice calculee
				move		#Buffer_Pts,r4					; buffer des points a calculer
				lua		(r1)+n1,r1						; On po…intes sur la description de l'objet suivant

				jsr		Rot_Trans_Pts					; on rotate tout les points.
_Calc_All_Points
		Rts

Rotate_With_Camera
		move		#Current_State_Camera,r0		; rotations et translations courantes de la camera
		move		#Camera_Matrice,r1	
		jsr		Calc_Matrice
		
		move		#Screen_Descriptor,r5
		move		#Current_Vectors,r6
	DO				X:(r5)+,_Rot_With_Camera
			move		#<3,n5
			move		X:(r5),r1							; Adresse de l'objet
			lua		(r5)+n5,r5							; on pointe sur l'adresse du buffer 3d
			move		X:(r1),x0							; Nombre de points
			move		X:(r5),r1							; r1 = points 3d
			move		#Buffer_Pts,r4
			move		r1,r2									; Buffer de sortie, on ecrase l'ancien buffer
			move		#<9,n5
		DO				x0,_Tfr_Pts
				move		X:(r1)+,y0
				move		X:(r1)+,x1
				move		x1,Y:(r4)+
				move		X:(r1)+,x1
				move		x1,Y:(r4)+
				move		y0,Y:(r4)+
_Tfr_Pts
			lua		(r5)+n5,r5
			move		#Camera_Matrice,r0
			move		X:(r6)+,x1
			move		x1,X:(r0)

			move		#<4,n0
			move		X:(r6)+,x1
			move		x1,X:(r0+n0)

			move		#<8,n0
			move		X:(r6)+,x1
			move		x1,X:(r0+n0)
			
			move		#Camera_Matrice,r0
			move		#Buffer_Pts,r4
			
			jsr		Rot_Trans_Pts
			
_Rot_With_Camera
		Rts

Proj_3D_Pts
			move		#Screen_Descriptor,r0
			move		#Inv_Tab,r3							; table des inv pour eviter la division
			move		#Points_Projeted,r4				; Buffer pour les points projetes
		DO				X:(r0)+,_Proj_All_Pts
				move		#<3,n0
				move		X:(r0),r1						; Adresse de la description de l'objet
				lua		(r0)+n0,r0						; On pointe sur le buffer de points rotate
				move		#<7,n0
				move		X:(r0)+,r2						; Adr du buffer de points rotates
				move		r4,X:(r0)+						; On sauve l'adr du buffer de points 2d
			DO				X:(r1),_Proj_Pts				; Nombre de point a projeter
					move		X:(r2)+,x0					; ZPts*512
					move		#>512,A						; 1*512
					move		Y:P_Fuite,y0				; 2^23/P_Fuite
					macr		-y0,x0,A						; (1-(Ze/P)*512 = Q*512
					move		A,n3							; Offset ds la table des inv pour obtenir 1/Q
					move		X:(r2)+,x1					; Xe*512
					move		Y:(r3+n3),x0				; 512/Q
					move		X:C_X,A
					mac		x1,x0,A						; Xp
					move		X:(r2)+,y0					; Ye*512
					move		X:C_Y,B
					mac		y0,x0,B						; Yp
					move		A,X:(r4)+					; Stocke X
					move		B,X:(r4)+					; Stocke Y
_Proj_Pts
				lua		(r0)+n0,r0
_Proj_All_Pts
		Rts	

Calcule_Bary
			move		#Screen_Descriptor,r0
			move		#Bary_Faces+1,r4						; Buffer ou l'on stocke les bary de chak faces
			move		#<0,x0
			move		x0,X:Sav_Reg
		DO				X:(r0)+,_Calc_Bary_Of_All_Objects
				move		X:(r0)+,r1						; Adr DSP de la description de l'objet
				move		#Inv_Tab,r5						; Table des inverses
				move		X:(r1)+,A						; Nombre de points 3D
				move		A,B
				addl		B,A				#<2,n0		; Fois 3, car comme tjrs 3 coordonnees/pts
				move		A,n1								; Offset pour sauter la Desc des points
				lua		(r0)+n0,r0						; On pointe sur l'adr du buffer de points 3d
				lua		(r1)+n1,r1						; On pointe sur le nbr de face
				move		X:(r0)+,r2						; r2 = Adr du buffer de points 3d
				move		X:(r0)+,r6						; r6 = Adr du buffer de points 2d
				move		r4,X:(r0)+						; On inscrit l'adr du buffer pour les barycentres
				move		X:(r1)+,x1						; Nombre de faces
				move		X:Sav_Reg,A
				add		x1,A
				move		A,X:Sav_Reg						; On l'inscrit dans le tablo pour les bary
				move		#<6,n0
			DO				x1,_Calc_1_Bary				; On calcule le barycentre de toutes les faces
					move		r1,r3							; On sauve l'adr pointant sur la desc de la face
					lua		(r1)+,r1						; On saute la couleur
					clr		A								; Zero point --> somme des Z a zero
					move		X:(r1)+,n5					; Nombre de points de la face
				DO				n5,_Add_Z
						move		X:(r1)+,x1				; Numero du point
						move		x1,B
						add		x1,B						; Num * 2
						add		x1,B						; Num * 3
						move		B,n2						; Offset dans la table
						nop						
						move		X:(r2+n2),y1			; on obtient le Z*512 du point
						add		y1,A						; on addition le Z pour pouvoir faire une moyenne
_Add_Z
					move		Y:(r5+n5),x1				; 1/Nbr de point
					move		A,y1							; somme des Z de la face
					mpy		x1,y1,A						; on obtient le barycentre de la face
					move		A,X:(r4)+					; on inscrit le barycentre de la face
					move		r3,X:(r4)+					; On inscrit l'adr de la face correspondante
					move		r6,X:(r4)+					; On inscrit l'adr du buffer pts 2d correspondant
_Calc_1_Bary
				lua		(r0)+n0,r0						; On pointe sur la description de l'objet suivant
				nop
_Calc_Bary_Of_All_Objects
		move		X:Sav_Reg,x0
		move		x0,X:Bary_Faces
		Rts

Sort_Faces
		move		#Sort_Faces,r1								; Tablo contenant les adresses des face triees
		move		#Screen_Descriptor,r0
		move		X:Bary_Faces,x0							; Nombre de faces
		move		x0,X:(r1)+
		move		#>8388606,y0								; Plus grande valeur
	DO				x0,_Sort_Faces
			move		#Bary_Faces,r0
			move		#>8388605,A
			move		#<2,n0
		DO				X:(r0)+,_Sort_1
			move		X:(r0)+,x0								; Barycentre de la face
			cmp		x0,A										; On compare avec le bary actuel
			jlt		_No										; Si l'actuel est plus grd, on continue
			move		x0,A
			move		r0,r2
_No		lua		(r0)+n0,r0								; On pointe sur le bary suivant
			nop
_Sort_1
			lua		(r2)-,r2									; On pointe sur la valeur du barycentre
			nop
			move		y0,X:(r2)+								; On la mets hors-concours
			move		X:(r2)+,r3								
			move		r3,X:(r1)+								; On obtient l'adr de la desc de la face
			move		X:(r2)+,r3								
			move		r3,X:(r1)+								; On obtient l'adr du buffer de pts 2d
_Sort_Faces
	Rts
		
Make_Tab
		move		#Sort_Faces,r0								; Nombre de face + adresse de leur desc
		move		#Tab_1_030,r1								; Tablo de sortie

	DO				X:(r0)+,_Test_Visi_Face
			
			move		X:(r0)+,r2								; r2 = Adr de la face
			move		r2,r6										; On sauvegarde l'adr de la face
			move		X:(r0)+,r3								; Buffer de points projetes
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
			
			move		X:-(r0),r3							; Adr du buffer de points 2D
			move		X:(r2)+,x0							; Couleur de la face
			move		x0,X:(r1)+							; On stocke la couleur de la face
			move		X:(r0)+,x0							; huhuhuhu magouille de la mort !!!!
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
		move		#Scene_Descriptor,r1					; Tablo contenant l'adr des objets
		move		#Target_Obj_Desc,r2
		move		#>150,n2									; Offset pour reserver un buffer aux obj cible
		move		#<9,n1									; 8 words pour les tablos et etat de l'objet
	Host_Get_Data		x0									; Nbr d'objet en tout
		move		x0,X:(r1)+
	DO				x0,Get_All_Objects
			move		r0,X:(r1)+							; On inscrit l'adr DSP de l'objet
			move		r2,X:(r1)+							; Adr de l'objet cible
			move		#<0,x0
			move		x0,X:(r1)+						; 0 signifie qu'il n'y a pas d'interpolation en cours
			lua		(r2)+n2,r2
			lua		(r1)+n1,r1							; On pointe sur l'emplacement de l'objet suivant
		Host_Get_Data		A								; Nombre de points 3D
			move		A,X:(r0)+							; on inscrit le nombre de points ds la description
			move		A,B
			addl		B,A									; trois coordonnees par points
		DO				A,_Get_All_Pts
			Host_Get_Data		X:(r0)+					; on receptionne toutes les coords de chaques points
_Get_All_Pts		

		Host_Get_Data		x0								; Nombre de faces
			move		x0,X:(r0)+
		DO				x0,_Get_Faces
			Host_Get_Data		X:(r0)+					; Receptionne le numero de la couleur
			Host_Get_Data		x0							; Nombre de points pour la face
				move		x0,X:(r0)+
		DO				x0,_Get_Pts
				Host_Get_Data		X:(r0)+				; Inscrit le numero des points
_Get_Pts
			nop												; Ca evite un warning ki fait chier
_Get_Faces
		nop													; pareille
Get_All_Objects											; On reboucle pour transferer toutes les objets

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
	DO				#12,_Get_Variables
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
	Org	X:$00	; On pointe sur la m‚moire interne car les symboles seront appel‚s souvent.

Nb_Faces							ds		1

Pt_Fuite							ds		1
C_X								ds		1
C_Y								ds		1
DX									ds		1
DY									ds		1
Nb_Inter							ds		1
Lim_ZP							ds		1
Lim_ZM							ds		1
Lim_XP							ds		1
Lim_XM							ds		1
Lim_YP							ds		1
Lim_YM							ds		1

Data_Matrice					ds		6
Matrice							ds		12			; Emplacement pour matrice + translation

Centre							ds		2

Sav_Reg							ds		16

;***************************************************************************************

;	Org	X:$200

Current_State_Camera			ds		6
Camera_Matrice					ds		12
Current_Vectors				ds		3*50

; Tableau pour stocker tout les points 3D rotater et translate
Points_Rotated					ds		3*400
; Tableau pour stocker tout les points 3D rotater et translate
Points_Projeted				ds		2*400
; Tableau pour stocker le barycentre de chaques faces
Bary_Faces						ds		3*200

; Description des objets dans la 'scene'
Scene_Descriptor				ds		12*50
; Description des objets dans la 'scene'
Screen_Descriptor				ds		12*50

; Description des objets fixes
Objects_Descriptor			ds		2000
; Description des objets cibles
Target_Obj_Desc				ds		1000

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

