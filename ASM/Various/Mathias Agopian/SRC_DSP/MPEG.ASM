; (c) 1995 AGOPIAN Mathias
; Decodeur MPEG couche I
; Pour STMAG


        page    132,56,1,1


adc			EQU		$ffef		; ADC address
dac			EQU		$ffef		; DAC address
M_CRA		EQU		$FFEC		; SSI Control Register A
M_CRB		EQU		$FFED		; SSI Control Register B
M_SR		EQU		$FFEE		; SSI Status Register
M_PCC		EQU		$FFE1		; Port C Control Register
BCR			equ		$fffe
IPR			equ		$ffff
PBC			equ		$ffe0
HCR			equ		$ffe8		; Host Control Register
HSR			equ		$ffe9		; Host Status Register
HRX			equ		$ffeb		; Host Receive Register
HTX			equ		$ffeb		; Host Transmit Register



			org		x:0
coef_I_A	dc		0.0
			dc		0.0
			dc		0.33333333333
			dc		0.14285714286
			dc		0.06666666666
			dc		0.03225806452
			dc		0.01587301587
			dc		0.00787401575
			dc		0.00392156863
			dc		0.00195694716
			dc		0.00097751711
			dc		0.00048851979
			dc		0.00024420024
			dc		0.00012208522
			dc		0.00006103888
			dc		0.00003051851


			include 'scale.asm'

couche		ds		1

			org		x:2048
vect_V		dsm		2048			;	2048 (2048)
			include	'N_IK.ASM'		;	4096 (2048)






			org		y:0
coef_I_B	dc		0.0
			dc		0.0
			dc		0.25
			dc		0.125
			dc		0.0625
			dc		0.03125
			dc		0.015625
			dc		0.0078125
			dc		0.00390625
			dc		0.001953125
			dc		0.000976563
			dc		0.000488281
			dc		0.000244151
			dc		0.000122070
			dc		0.000061035
			dc		0.000030518



alloc_I		dsm		64
scale_I		dsm		64


			org		y:512
			include 'FENETRE.ASM'	;	512 (512)
vect_U		dsm		1024			;	1024 (1024) -> 2048
ptr_play	dsm		1536			;	2048 (1536)	-> 3584
samples		ds		768				;	3584 (0768) -> 4352



			org		p:$0
			jmp		start

			org		p:$10
			movep	y:(r7)+,x:dac


			org		p:$40
start		movep	#$01F8,X:M_PCC		; Mode SSI.
			movep	#$4100,X:M_CRA		; 16 bits, 2 voix.
			movep	#$5800,X:M_CRB		; Interruptions TX OK, activer TX, NetWork
			movep	#0,x:BCR			; Control du BUS: TOUJOURS ZERO
			movep	#1,x:PBC			; Port B = HOST
			ori		#3,mr				; Stopper les interruptions
			bclr	#4,x:HCR			; Dsp Occup‚
			movep   #$3000,x:IPR		; IPL 2 pour SSI

init		move	#vect_V,r0			; Parametres du filtre
			movec	#2048-1,m0
			move	#128,n0
			movec	#-1,m1
			movec	#-1,m2
			movec	#-1,m4
			move	#63,n4				; 64 - 1
			
			move	#ptr_play,r7
			movec	#1536-1,m7
			move	#768,n7
			move	r7,r3
			movec	m7,m3
			move	n7,n3
			
			movep	#$0800,X:M_CRB		; Ne pas autoriser la reception de donnee
			move	#0,y0				; A cause d'un bug du DSP pendant le REP	
			rep		#2048
			move	y0,x:(r0)+
			rep		#1536
			move	y0,y:(r7)+
			movep	#$5800,X:M_CRB		; Interruptions TX OK, activer TX, NetWork

			andi	#$fc,mr				; Activer les interruptions


main		bset	#4,x:HCR			; Dsp Pret
			jsr		Get_Data			; Attendre et charger les donnees
			bclr	#4,x:HCR			; Dsp Occupe

			lua		(r3)-n3,r3			; attendre que r7 = r3 - n3
			move	r7,x0
			move	r3,a			
waitf		cmp		x0,a	r7,x0
			jne		waitf
			lua		(r3)+n3,r3

			jsr		mpeg_decoder		; Decoder la sequence
			jmp		main

Get_Data	move	#alloc_I,r1			; Chargement du nombre de bit alloues par sous-bande et par voie
			do		#64,Get_alloc_I
			jclr	#0,x:HSR,*		
			movep	x:HRX,y:(r1)+
Get_alloc_I	move	#scale_I,r1			; Chargement des index sur les facteurs d'echelle
			do		#64,Get_scale_I
			jclr	#0,x:HSR,*		
			movep	x:HRX,y:(r1)+
Get_scale_I	move	#samples,r4			; Chargement des samples en couche I
			do		#768,Get_spl_I
			jclr	#0,x:HSR,*		
			movep	x:HRX,y:(r4)+
Get_spl_I	rts




mpeg_decoder
			jsr		requant_I
			jsr		synthese
			rts


synthese	move	#samples,r4

			do		#12,sous_bande

			move	#vect_Nik,r1
			clr		a		(r0)-n0										; effacer A  //  faire de la place
			clr		b				x:(r1)+,x0		y:(r4)+,y0			; lire Nik[k][sb]  //   lire sample[0][sb][i]
			do		#64,loop0											; boucle sur k
			do		#31,loop1											; boucle sur sb
			mac		x0,y0,a							y:(r4)+,y0			; V[k][0] + = Nik * sample  //   lire sample[1][sb][i]
			mac		x0,y0,b			x:(r1)+,x0		y:(r4)+,y0			; V[k][1] + = Nik * sample  //   lire Nik[k][sb]  //   lire sample[0][sb][i]
loop1		macr	x0,y0,a							y:(r4)-n4,y0
			macr	x0,y0,b			x:(r1)+,x0		y:(r4)+,y0
			clr		a				a,x:(r0)+							; efface a  // sauve V[k][0] (a)
			clr		b				b,x:(r0)+							; efface b  // sauve V[k][1] (b)
loop0



			lua		(r0)-n0,r0					; repositionne r0
			move	#vect_U,r6					; vecteur U
			movec	#1024-1,m6					;
			move	#63,n6						; deplacement 2*32 - 1
			move	x:(r0)+,a					; Lire V[k*128+sb][0]
			do		#8,loop_sb11				; repeter 8 fois sur k
			do		#31,loop_sb0				;	repeter 31 fois sur sb
			move	x:(r0)+,b		a,y:(r6)+	;   lire V[k*128+sb][1] // U[k*32+sb][0]=V[k*128+sb][0]
			move	x:(r0)+,a		b,y:(r6)+	;   lire V[k*128+sb][0] // U[k*32+sb][0]=V[k*128+sb][1]
loop_sb0	move	x:(r0)+,b		a,y:(r6)+	;   lire V[k*128+sb][1] // U[k*32+sb][0]=V[k*128+sb][0]
			move	(r0)+n0						; sb + 96
			move	x:(r0)+,a		b,y:(r6)+	;   lire V[k*128+sb][0] // U[k*32+sb][0]=V[k*128+sb][1]
			do		#32,loop_sb1				;	repeter 32 fois sur sb
			move	x:(r0)+,b		a,y:(r6)+	;
			move	x:(r0)+,a		b,y:(r6)+	;
loop_sb1	nop
loop_sb11	lua		(r0)-,r0					; corriger r0



			; r0 a avance de 128 * 8 = 1024 pas (2048 mots) -> retour a sa valeur initiale
			; r6 a avance de  64 * 8 =  512 pas (1024 mots) -> retour a sa valeur initiale

			move	#fenetre,r5									; fenetre de ponderation
			movec	#512-1,m5									; 512 valeurs
			move	#32,n5										; deplacement 32

			clr		a	(r4)+n4									; effacer a  //  corriger r4
			clr		b							y:(r5)+n5,y0	; effacer b  //  lire fen[sb]			
			do		#32,loop_r0									; repeter 32 fois sur sb
			do		#16,loop_r1									; repeter 16 fois sur k
			move								y:(r6)+,x0		; lire U[sb+k*32][0]
			mac		x0,y0,a						y:(r6)+n6,x0	; a + = U[sb+k*32][0] * fen[k*32+sb] // lire U[sb+k*32][0]
			mac		x0,y0,b						y:(r5)+n5,y0	; b + = U[sb+k*32][1] * fen[k*32+sb] // lire fen[sb+k*32]
loop_r1		asl		a	(r5)-n5									; a * 2 // corriger r5 -> r5 = #fenetre
			asl		b			x:(r6)+,x1		a,y:(r3)+		; b * 2 // incrementer R6  //  sauver A
			clr		a			x:(r6)+,x1		b,y:(r3)+		; effacer a // incrementer R6  //  sauver B
			clr		b	(r5)+									; effacer b // incrementer R5
			move								y:(r5)+n5,y0	; lire fen[sb]			
loop_r0		nop

sous_bande	rts


;
; Requantification en couche I
; ----------------------------
;

requant_I	move	#coef_I_A,r1
			move	#Scale_Factors,r2
			move	#samples,r4
			move	#alloc_I,r5
			movec	#64-1,m5
			move	#scale_I,r6			
			movec	m5,m6
			
			move	y:(r5)+,n1							; 1ere lecture du Nombre de bits
			move	y:(r6)+,n2							; 1ere lecture de l'Index sur le facteur d'echelle
			move	y:(r1+n1),y0						; 1ere Recuperation de B
			move	n1,b
			tst		b					b,x1			; aucun bit alloue?  //  Mise a zero de X1

			do		#768,loop_requant_I
			jeq		zero								; pas de bits alloue, alors chargement des prochaines valeurs
			move	y:(r4),x0							; Lire un echantillon
			mpy		x0,y0,a								; -> transformer en fraction
			bchg	#23,a0								; inverser MSB
			move	a0,a								; prendre le signe en compte
			add		y0,a				x:(r1+n1),x0	; Y+B  //  Recuperation de A
			move	a,y0								;
			macr	x0,y0,a				x:(r2+n2),x1	; (Y+B) + (Y+B) * A  //  Lecture du fecteur d'echelle
			move	a,y0								;
zero		mpy		x1,y0,a				y:(r5)+,n1		; [ (Y+B) + (Y+B) * A ] * Scale		 // Nombre de bits alloues
			macr	x1,y0,a				y:(r6)+,n2		; arrondi { [ (Y+B) + (Y+B) * A ] * Scale * 2 }	 // Index sur le facteur d'echelle
			move						y:(r1+n1),y0	; Recuperation de B
			move	n1,b
			tst		b		b,x1		a,y:(r4)+		; aucun bit alloue?  //  Mise a zero de X1  // Sauve le r‚sultat

loop_requant_I:
			rts

