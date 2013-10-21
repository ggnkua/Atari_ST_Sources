;***********************************************************************
;***********										 ***********
;***********										 ***********
;***********			  Amiga DSP Replay				 ***********
;***********			  DSP Amiga Replay				 ***********
;***********			   with P56 Loader				 ***********
;***********										 ***********
;***********										 ***********
;***********		  By Simplet / FATAL DESIGN			 ***********
;***********										 ***********
;***********************************************************************

; The circular sample buffer must begin to an address multiple
; of the the first power of 2 greater than its size
; If you want an 50Hz VBL/Timer as maximum frequency,
; The size must be greater than :
; 2*984 for 49.1Khz, 2*656 for 32.8KHz, 2*492 for 24.5KHz, etc...

PBC		equ		$ffe0			; Port B Control Register
PCC		equ		$ffe1			; Port C Control register
HCR		equ		$ffe8			; Host Control Register
HSR		equ		$ffe9			; Host Status Register
HRX		equ		$ffeb			; Host Receive Register
HTX		equ		$ffeb			; Host Transmit Register
CRA		equ		$ffec			; SSI Control Register A
CRB		equ		$ffed			; SSI Control Register B
SSISR	equ		$ffee			; SSI Status Register
TX		equ		$ffef			; SSI Serial Transmit data/shift register
BCR		equ		$fffe			; Port A Bus Control Register
IPR		equ		$ffff			; Interrupt Priority Register

;	Host Control Register Bit Flags

HCIE		equ		2				; Host Command Interrupt Enable

;	Host Status Register Bit Flags

HRDF		equ		0				; Host Receive Data Full
HTDE		equ		1				; Host Transmit Data Empty


		org		p:$0
		jmp		>Start

		org		p:$10
		jsr		>Spl_Out
		org		p:$12
		jsr		>Spl_Out

		org		p:$24
		jmp		>P56_Loader
		org		p:$26
		jsr		>SoundTrack_Rout
		org		p:$28
		jsr		>Clear_Sample_Buffer

; Interrupt Routine that plays the sound with the SSI

		org		p:$40

Spl_Out	jset		#<2,X:<<SSISR,Right_Out	; detect the second transfer

Left_Out	movep	Y:(r7),X:<<TX
		rti
Right_Out	movep	X:(r7)+,X:<<TX
		rti

;
; It Begins here :
;

Start	movep	#1,X:<<PBC			; Port B in Host
		movep	#$1f8,X:<<PCC			; Port C in SSI
		movep	#$4100,X:<<CRA			; 1 voice 16 bits Stereo
		movep	#$5800,X:<<CRB			; enable X-mit IT
		movep	#$3800,X:<<IPR			; SSI at IPL 3
									; and Host at IPL 2
		bset		#<HCIE,X:<<HCR			; enable Host Command ITs

; Initialisation of Registers

		move		#-1,m0
		move		#2048-1,m7
		move		m0,m1
		move		m0,m2
		move		m0,m3
		move		m0,m4
		move		m0,m5
		move		m7,m6

; Clears the Sample-Buffer
		jsr		<Clear_Sample_Buffer

; Verify the connexion with the 030

Conct_Get	jclr		#<HRDF,X:<<HSR,Conct_Get
		movep	X:<<HRX,x0

Conct_Snd	jclr		#<HTDE,X:<<HSR,Conct_Snd
		movep	#12345678,X:<<HTX

; Enable interrupts (IPL0) and waits
		move		#Sample_Buffer,r7
		andi		#<%11111100,mr
Loop		jmp		<Loop

;
; Sound-Tracker Routine in Host Command
;

SoundTrack_Rout
		jclr		#<HTDE,X:<<HSR,SoundTrack_Rout
		movep	#'MGT',X:<<HTX

		move		#<Length,r0

		move		X:<Old_Adr,x0			; Number of Samples
		move		x0,X:<Calc_Adr			; to calculate = Current Pos
		move		r7,a					; - Old Position
		sub		x0,a			r7,X:Old_Adr
		jpl		<Length_Ok
		move		#>2048,x0				; Warning Modulo !
		add		x0,a
Length_Ok	move		a,X:(r0)+				; Sample Length

Get_MVolL	jclr		#<HRDF,X:<<HSR,Get_MVolL
		movep	X:<<HRX,X:(r0)+		; Left Master Volume
Get_MVolR	jclr		#<HRDF,X:<<HSR,Get_MVolR
		movep	X:<<HRX,X:(r0)+		; Right Master Volume

; Gets the number of Voices

Get_NbV	jclr		#<HRDF,X:<<HSR,Get_NbV
		movep	X:<<HRX,y0
		tfr		y0,b		#>2,a
		addr		a,b		#>1,a		; 2*b = Nb Voies + 4 voies FX

		andi		#<$fe,ccr				; Cancel Carry Bit
		Rep		#<24
		div		y0,a					; a0 = 1 / Nb Voices
		move		a0,X:(r0)

; Clears the sample-buffer before mixing
		clr		a		X:Calc_Adr,r6

		move		X:Length,x0
		Do		x0,Clear_Sample
		move		a,L:(r6)+
Clear_Sample

; Mix All Voices
		move		#Voices_Frac,r1

		Do		b,Mix_All_Voices_Loop

		jsr		<Request
		jsr		<Receive_Volume
		tst		a
		jeq		<Next_Voice_L
		jsr		<Receive_Frequency
		jsr		<Receive_X_Samples
		jsr		<Mix_Voice_Left

Next_Voice_L
		lua		(r1)+,r1

		jsr		<Request
		jsr		<Receive_Volume
		tst		a
		jeq		<Next_Voice_R
		jsr		<Receive_Frequency
		jsr		<Receive_Y_Samples
		jsr		<Mix_Voice_Right
		
Next_Voice_R
		lua		(r1)+,r1
Mix_All_Voices_Loop

; It's Finished for this time
Send_End	jclr		#<HTDE,X:<<HSR,Send_End
		movep	#0,X:<<HTX
		rti

; Calls the 030
Request	jclr		#<HTDE,X:<<HSR,Request
		movep	#-1,X:<<HTX
		rts

; Receives the Sample Volume
Receive_Volume
		move		#Voice_Volume,r0
		jclr		#<HRDF,X:<<HSR,Receive_Volume
		movep	X:<<HRX,a
		move		a,X:(r0)+				; Sample Volume
		rts

; Receives the sample frequency
Receive_Frequency
		jclr		#<HRDF,X:<<HSR,Receive_Frequency
		movep	X:<<HRX,x0				; Sample Frequency
		move		X:<Length,b
		lsl		b
		clr		b			b,x1
		move		X:(r1),b0					; Frac Part
		mac		x0,x1,b		x0,X:(r0)
Send_Length
		jclr		#<HTDE,X:<<HSR,Send_Length	; Length of Sample
		movep	b,X:<<HTX					; played in this frame
		rts

; Routine that mixes a new voice on the left channel

Mix_Voice_Left
		move		#Sample,r0
		move		X:<Calc_Adr,r6		; Adress

		move		X:<Voice_Volume,x0
		move		X:<Master_Vol_L,x1
		mpy		x0,x1,a	X:<Nb_Voices,x1
		move		a0,x0
		mpyr		x0,x1,a
		lsl		a
		move		a,x1				; Volume

		move		#>2,y0
		move		X:<Voice_Freq,y1	; Frequence
		move		r0,b
		move		X:(r1),b0			; Frac

		Do		X:<Length,Mix_Voice_Left_Loop

		mac		y0,y1,b		Y:(r6),a		X:(r0),x0
		mac		x0,x1,a		b,r0
		move					a,Y:(r6)+

Mix_Voice_Left_Loop
		move		b0,X:(r1)			; Frac
		rts

; Routine that mixes a new voice on the right channel

Mix_Voice_Right
		move		#Sample,r0
		move		X:<Calc_Adr,r6		; Adress

		move		X:<Voice_Volume,y0
		move		X:<Master_Vol_R,y1
		mpy		y0,y1,a	X:<Nb_Voices,y1
		move		a0,y0
		mpyr		y0,y1,a
		lsl		a
		move		a,y1				; Volume

		move		#>2,x0
		move		X:<Voice_Freq,x1	; Frequence
		move		r0,a
		move		X:(r1),a0			; Frac

		Do		X:<Length,Mix_Voice_Right_Loop

		mac		x0,x1,a		X:(r6),b		Y:(r0),y0
		mac		y0,y1,b		a,r0
		move					b,X:(r6)+

Mix_Voice_Right_Loop
		move		a0,X:(r1)			; Frac
		rts

; Routines that receive 8 bits samples in X/Y memory

Receive_X_Samples
		move		#Sample+1,r0
		move		#3,n0
		move		#>$ff0000,x1
		move		#>$000080,y0
		move		#>$008000,y1

		move		#>1,a
		addr		a,b
		Do		b,Receive_X_Loop_8
Receive_X_Sample_8
		jclr		#<HRDF,X:<<HSR,Receive_X_Sample_8
		movep	X:<<HRX,x0
		mpy		y0,x0,a
		mpy		y1,x0,a		a0,b
		and		x1,b			a0,X:(r0)-
		move		b,X:(r0)+n0
Receive_X_Loop_8
		rts

Receive_Y_Samples
		move		#Sample+1,r0
		move		#3,n0
		move		#>$ff0000,x1
		move		#>$000080,y0
		move		#>$008000,y1

		move		#>1,a
		addr		a,b
		Do		b,Receive_Y_Loop_8
Receive_Y_Sample_8
		jclr		#<HRDF,X:<<HSR,Receive_Y_Sample_8
		movep	X:<<HRX,x0
		mpy		y0,x0,a
		mpy		y1,x0,a		a0,b
		and		x1,b			a0,Y:(r0)-
		move		b,Y:(r0)+n0
Receive_Y_Loop_8
		rts

;
; Clears the sample buffer
;
Clear_Sample_Buffer
		move		a,X:<Save_a
		move		r0,X:<Save_r0
		clr		a		#Sample_Buffer,r0
		Do		#<2048,Clear_Sample_Buffer_Loop
		move		a,L:(r0)+
Clear_Sample_Buffer_Loop
		move		X:<Save_a,a
		move		X:<Save_r0,r0
		rti

;
; P56 Binary Program Loader in Host Command
;

P56_Loader
		jclr		#<HTDE,X:<<HSR,P56_Loader
		movep	#'P56',X:<<HTX

		move		#P56_Loader_Host_Receive,r1	; Routine Reception Host
		movec	#<0,sp					; Pile a zero

P56_Loader_Next_Section
		jsr		(r1)						; Type de Memoire
		tfr		x0,b		x0,n0
		tst		b		#Memory_Type,r0	; Si n‚gatif,
		jmi		<0						; Execute Programme
		movem	P:(r0+n0),r2				; Routine de Reception
		jsr		(r1)
		move		x0,r0					; Adresse de Depart
		jsr		(r1)						; Nombre de Blocs

		Do		x0,P56_Loader_Receive_Section
		jsr		(r1)						; Recoit Bloc
		jsr		(r2)						; Stocke-le
		nop
P56_Loader_Receive_Section
		jmp		<P56_Loader_Next_Section

P56_Loader_Host_Receive
		jclr		#<HRDF,X:<<HSR,P56_Loader_Host_Receive
		movep	X:<<HRX,x0
		rts

P56_Loader_P_Receive
		movem	x0,P:(r0)+
		rts
P56_Loader_X_Receive
		move		x0,X:(r0)+
		rts
P56_Loader_Y_Receive
		move		x0,Y:(r0)+
		rts

Memory_Type
		DC		P56_Loader_P_Receive
		DC		P56_Loader_X_Receive
		DC		P56_Loader_Y_Receive

External_Code_Begin

; Data Zone

			org		X:0

Old_Adr		DC		Sample_Buffer
Calc_Adr		DS		1
Length		DS		1
Master_Vol_R	DS		1
Master_Vol_L	DS		1
Nb_Voices		DS		1
Voice_Volume	DS		1
Voice_Freq	DS		1
Voices_Frac	DS		4+32
Save_r0		DS		1
Save_a		DS		1
Sample		DS		672

			org		L:6*2048

Sample_Buffer	DS		2048

			END
