;***********************************************************************
;***********										 ***********
;***********										 ***********
;***********		Routine de Replay Soundtracker		 ***********
;***********			  2 + 2 * x  voies				 ***********
;***********										 ***********
;***********		 Transmission par port Host			 ***********
;***********										 ***********
;***********		   Par Simplet / ABSTRACT			 ***********
;***********										 ***********
;***********************************************************************


PBC		equ		$ffe0			; Port B Control Register
PCC		equ		$ffe1			; Port C Control register
HSR		equ		$ffe9			; Host Status Register
HRX		equ		$ffeb			; Host Receive Register
HTX		equ		$ffeb			; Host Transmit Register
CRA		equ		$ffec			; SSI Control Register A
CRB		equ		$ffed			; SSI Control Register B
SSISR	equ		$ffee			; SSI Status Register
TX		equ		$ffef			; SSI Serial Transmit data/shift register
IPR		equ		$ffff			; Interrupt Priority Register

;	Host Status Register Bit Flags

HRDF		equ		0				; Host Receive Data Full
HTDE		equ		1				; Host Transmit Data Empty


		org		p:$0
		jmp		Start

; Routine sous interruption de Replay du son par le SSI

		org		p:$10
		jsr		Spl_Out

		org		p:$40

Spl_Out	jset		#<2,X:<<SSISR,Right_Out	; D‚tecte le premier transfert

Left_Out	movep	X:(r7),X:<<TX
		rti
Right_Out	movep	Y:(r7)+,X:<<TX
		rti

;
; Ca commence la :
;

Start	movep	#1,X:<<PBC			; Port B en Host
		movep	#$1f8,X:<<PCC			; Port C en SSI
		movep	#$4100,X:<<CRA			; 1 voie 16 bits Stereo
		movep	#$5800,X:<<CRB			; autorise l'IT d'‚mission
		movep	#$3000,X:<<IPR			; le SSI au niveau d'IT 3


; Pour v‚rifier la connexion

Conct_Get	jclr		#<HRDF,X:<<HSR,Conct_Get
		movep	X:<<HRX,x0

Conct_Snd	jclr		#<HTDE,X:<<HSR,Conct_Snd
		movep	#12345678,X:<<HTX

		move		#-1,m0
		move		#1699,m7
		move		m0,m1
		move		m7,m6
		move		#>680,n4
		move		m0,m4

; Efface le buffer
		clr		b
		move		#SampleBuffer,r0

		DO		#1700,Clear_Sample
		move		b,X:(r0)
		move		b,Y:(r0)+
Clear_Sample

		move		#SampleBuffer,r7

; Autorise les interruptions (IPL0)
		andi		#<%11111100,mr

; Boucle principale

Wait_IT	jclr		#<HRDF,X:<<HSR,Wait_IT
		movep	X:<<HRX,a
		tst		a
		jeq		<LAFINDELAMORTQUITUELAVIEVIVANTE

Get_NbVox	jclr		#<HRDF,X:<<HSR,Get_NbVox
		movep	X:<<HRX,X:Nb_Voices_Sup

		move		a1,X:<Length
		move		r7,r5

; Recoie les deux premieres voies
		move		#Voice_1,r0
		jsr		<Receive_Voice_Left
		move		#Voice_2,r0
		jsr		<Receive_Voice_Right

; Recoie les x autres paires de voies supplementaires

		move		#Voices_Sup,r4
		DO		X:<Nb_Voices_Sup,Receive_Voices_Sup

		move		r4,r0
		jsr		<Receive_Voice_Left
		move		r4,r0
		jsr		<Receive_Voice_Right

		lua		(r4)+n4,r4
Receive_Voices_Sup

; Calcule les deux premieres voies
		move		#Voice_1,r0
		jsr		<Calc_Voice_Left
		move		#Voice_2,r0
		jsr		<Calc_Voice_Right

; Mixe les x autres paires de voies supplementaires

		move		#Voices_Sup,r4
		DO		X:<Nb_Voices_Sup,Mix_Voices_Sup

		move		r4,r0
		jsr		<Mix_Voice_Left
		move		r4,r0
		jsr		<Mix_Voice_Right

		lua		(r4)+n4,r4
Mix_Voices_Sup


Fin_Calc	jclr		#<HTDE,X:<<HSR,Fin_Calc
		movep	x0,X:<<HTX

		move		r5,X:<Calc
		jmp		<Wait_IT


LAFINDELAMORTQUITUELAVIEVIVANTE
		ori		#<%11,mr			; Coupe les interruptions
		jmp		<LAFINDELAMORTQUITUELAVIEVIVANTE


; Routine de r‚ception d'infos voie et sample … Gauche

Receive_Voice_Left
Receive_Left_Volume
		jclr		#<HRDF,X:<<HSR,Receive_Left_Volume
		movep	X:<<HRX,X:(r0)+
Receive_Left_Frequence
		jclr		#<HRDF,X:<<HSR,Receive_Left_Frequence
		movep	X:<<HRX,x0
		move		x0,X:(r0)+
		move		X:<Length,x1
		mpy		x0,x1,a		(r0)+
Send_Left_Length
		jclr		#<HTDE,X:<<HSR,Send_Left_Length
		movep	a1,X:<<HTX
Receive_Left_Length
		jclr		#<HRDF,X:<<HSR,Receive_Left_Length
		movep	X:<<HRX,x0

		move		#>$80,y0
		move		#>$8000,y1

		DO		x0,Receive_Left_Loop
Receive_Left_Sample
		jclr		#<HRDF,X:<<HSR,Receive_Left_Sample
		movep	X:<<HRX,x0
		mpy		x0,y0,a		x0,X:(r0)+
		mpy		x0,y1,a		a0,X:(r0)+
		move		a0,X:(r0)+
Receive_Left_Loop
		rts

; Routine de calcul de la premiere voie a Gauche

Calc_Voice_Left
		move		X:<Calc,r6		; Adresse
		move		X:(r0)+,x1		; Volume
		lua		(r0)+,r1
		move		X:(r0)+,y1		; Fr‚quence
		move		X:(r1)+,b			; Fractionnaire

		move		X:(r1),x0			; Premier
		mpy		x0,x1,a			; Sample

		move		#CL_NoNext,r2
		move		#>$7fffff,y0

		DO		X:<Length,Calc_Voice_Left_Loop

		add		y1,b
		jec		(r2)
		and		y0,b			X:(r1)+,x0
		mpy		x0,x1,a
CL_NoNext	move		a1,X:(r6)+

Calc_Voice_Left_Loop
		move		b,X:(r0)
		rts

; Routine de calcul d'une voie suppl‚mentaire … Gauche

Mix_Voice_Left
		move		X:<Calc,r6		; Adresse
		move		X:(r0)+,x1		; Volume
		lua		(r0)+,r1
		move		X:(r0)+,y1		; Fr‚quence
		move		X:(r1)+,b			; Fractionnaire

		move		X:(r1),x0			; Premier Sample

		move		#ML_NoNext,r2
		move		#>$7fffff,y0

		DO		X:<Length,Mix_Voice_Left_Loop

		add		y1,b			X:(r6),a
		jec		(r2)
		and		y0,b			X:(r1)+,x0
ML_NoNext	mac		x0,x1,a
		move		a1,X:(r6)+

Mix_Voice_Left_Loop
		move		b,X:(r0)
		rts

; Routine de r‚ception d'infos voie et sample … Droite

Receive_Voice_Right
Receive_Right_Volume
		jclr		#<HRDF,X:<<HSR,Receive_Right_Volume
		movep	X:<<HRX,Y:(r0)+
Receive_Right_Frequence
		jclr		#<HRDF,X:<<HSR,Receive_Right_Frequence
		movep	X:<<HRX,x0
		move		x0,Y:(r0)+
		move		X:<Length,x1
		mpy		x0,x1,a		(r0)+
Send_Right_Length
		jclr		#<HTDE,X:<<HSR,Send_Right_Length
		movep	a1,X:<<HTX
Receive_Right_Length
		jclr		#<HRDF,X:<<HSR,Receive_Right_Length
		movep	X:<<HRX,x0

		move		#>$80,y0
		move		#>$8000,y1

		DO		x0,Receive_Right_Loop
Receive_Right_Sample
		jclr		#<HRDF,X:<<HSR,Receive_Right_Sample
		movep	X:<<HRX,x0
		mpy		x0,y0,a		x0,Y:(r0)+
		mpy		x0,y1,a		a0,Y:(r0)+
		move		a0,Y:(r0)+
Receive_Right_Loop
		rts

; Routine de calcul de la premiere voie a Droite

Calc_Voice_Right
		move		X:<Calc,r6		; Adresse
		move		Y:(r0)+,x1		; Volume
		lua		(r0)+,r1
		move		Y:(r0)+,y1		; Fr‚quence
		move		Y:(r1)+,b			; Fractionnaire

		move		Y:(r1),x0			; Premier
		mpy		x0,x1,a			; Sample

		move		#CR_NoNext,r2
		move		#>$7fffff,y0

		DO		X:<Length,Calc_Voice_Right_Loop

		add		y1,b
		jec		(r2)
		and		y0,b			Y:(r1)+,x0
		mpy		x0,x1,a
CR_NoNext	move		a1,Y:(r6)+

Calc_Voice_Right_Loop
		move		b,Y:(r0)
		rts

; Routine de calcul d'une voie suppl‚mentaire … Droite

Mix_Voice_Right
		move		X:<Calc,r6		; Adresse
		move		Y:(r0)+,x1		; Volume
		lua		(r0)+,r1
		move		Y:(r0)+,y1		; Fr‚quence
		move		Y:(r1)+,b			; Fractionnaire

		move		Y:(r1),x0			; Premier Sample

		move		#MR_NoNext,r2
		move		#>$7fffff,y0

		DO		X:<Length,Mix_Voice_Right_Loop

		add		y1,b			Y:(r6),a
		jec		(r2)
		and		y0,b			Y:(r1)+,x0
MR_NoNext	mac		x0,x1,a
		move		a1,Y:(r6)+

Mix_Voice_Right_Loop
		move		b,Y:(r0)
		rts


; Zone de donn‚es

			org		X:0

Nb_Voices_Sup	DC		1
Calc			DC		SampleBuffer
Length		DS		1

			org		X:1*680
Voice_1
Voice_2
			org		X:2*680
Voices_Sup

			org		X:14*1024
SampleBuffer
			END
