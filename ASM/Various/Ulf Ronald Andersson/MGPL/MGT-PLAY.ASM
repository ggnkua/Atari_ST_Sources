;***********************************************************************
;***********										 ***********
;***********										 ***********
;***********		  DSP-Replay MegaTracker v1.1			 ***********
;***********										 ***********
;***********										 ***********
;***********		   by Simplet / FATAL DESIGN			 ***********
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
		move		m7,m2
		move		m0,m3
		move		m0,m4
		move		m0,m5
		move		m7,m6

; Clears the sample buffer
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

; Gets the Master Volumes
		move		#>$0000ff,x1
		move		#>$008000,y1

Get_MVol	jclr		#<HRDF,X:<<HSR,Get_MVol
		movep	X:<<HRX,a
		and		x1,a			a,x0
		mpy		y1,x0,a		a,X:(r0)+		; Right Master Volume
		move					a,X:(r0)+		; Left Master Volume

Get_GVol	jclr		#<HRDF,X:<<HSR,Get_GVol
		movep	X:<<HRX,X:(r0)+			; Global Volume

; Gets the number of Voices

Get_NbV	jclr		#<HRDF,X:<<HSR,Get_NbV
		movep	X:<<HRX,y0
		move		#>1024,x0
		mpy		x0,y0,a	#>2,b
		add		y0,b		a0,x0		; b = Nb Voies + 2 voies FX

		move		#>1,a
		andi		#<$fe,ccr				; Cancel Carry Bit
		Rep		#<24
		div		x0,a					; a0 = 1 / (1024 * Nb Voices)
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

; Calls the 030
Request	jclr		#<HTDE,X:<<HSR,Request
		movep	#-1,X:<<HTX

; Receives the voices' info

Receive_Voice
		move		#<Voice_Vol_R,r0
		move		#>$0000ff,x1
		move		#>$000080,y0
		move		#>$008000,y1
Receive_Pan
		jclr		#<HRDF,X:<<HSR,Receive_Pan
		movep	X:<<HRX,a
		tst		a
		jeq		<Next_Voice
		and		x1,a			a1,x0
		mpy		y1,x0,a		a1,X:(r0)+	; Voice Right Volume
		and		x1,a			X:<Length,b
		mpy		y0,x0,a		a1,X:(r0)+	; Voice Left Volume
		lsl		b			a1,X:(r0)+	; Voice Attributes
Receive_Volume
		jclr		#<HRDF,X:<<HSR,Receive_Volume
		movep	X:<<HRX,X:(r0)+			; Sample Volume
Receive_Frequence
		jclr		#<HRDF,X:<<HSR,Receive_Frequence
		movep	X:<<HRX,a					; Sample Frequence
		tst		a		a,x0
		jne		<Receive_Ordinary_Voice

; The sample frequency is greater than the replay frequency

		jsr		<Treat_030_Voice
		jmp		<Next_Voice

; The sample frequency is lower than the replay frequency

Receive_Ordinary_Voice
		clr		b			b,x1
		move		X:(r1),b0					; Frac Part
		mac		x0,x1,b		x0,X:(r0)
Send_Length
		jclr		#<HTDE,X:<<HSR,Send_Length	; Length of Sample
		movep	b,X:<<HTX					; played in this frame

		jsr		<Treat_Ordinary_Voice

Next_Voice
		lua		(r1)+,r1
Mix_All_Voices_Loop

; It's Finished for this time
Send_End	jclr		#<HTDE,X:<<HSR,Send_End
		movep	#0,X:<<HTX
		rti


; Routine that mixes a new voice on the left channel

Mix_Voice_Left
		move		#Sample,r0
		move		X:<Calc_Adr,r6		; Adress
		move		X:<Voice_Vol_L,x1	; Left Volume

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
		move		X:<Voice_Vol_R,y1	; Right Volume

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

; Routine that mixes a new voice on both channels

Mix_Voice	move		#Sample,r0
		move		X:<Calc_Adr,r6		; Adress
		move		#<Voice_Vol_R,r4	; Right Volume
		move		r6,r2
		move		X:(r4)+,x1
		move		X:<Voice_Freq,y1	; Frequence

		move		#>2,x0
		move		r0,b
		move		X:(r1),b0			; Frac

		Do		X:<Length,Mix_Voice_Loop

		mac		x0,y1,b		X:(r6),a		Y:(r0),y0
		mac		y0,x1,a		X:(r4)-,x1
		move					Y:(r2),a		a,X:(r6)+
		mac		y0,x1,a		b,r0
		move					X:(r4)+,x1	a,Y:(r2)+

Mix_Voice_Loop
		move		b0,X:(r1)			; Frac
		rts

; The sample frequency is greater than the replay frequency
; then the 030 sends us only the necessary amount of samples
; by making the frequency calc, and the DSP only mix it

Treat_030_Voice
		jsr		<Calc_Volumes

		move		#>$000080,x1

		move		X:<Length,b
		move		#>1,x0
		sub		x0,b		X:<Calc_Adr,r6

		move		X:<Voice_Atrbts,a
		btst		#<2,a
		jcs		<Treat_030_16_Bits_Voice
		btst		#<3,a
		jcs		<Treat_030_8_Bits_Stereo_Voice

Treat_030_8_Bits_Mono_Voice
		move		X:<Length,b
		add		x0,b
		lsr		b
		sub		x0,b		b,y0
		jclr		#<HTDE,X:<<HSR,Treat_030_8_Bits_Mono_Voice
		movep	b,X:<<HTX

		move		#>$008000,y1
		move		r6,r2
		move		#<Voice_Vol_R,r5
		move		#<Dummy,r3

		move		Y:-(r2),a

		Do		y0,Treat_030_8_Bits_Mono_Voice_Loop

		jclr		#<HRDF,X:<<HSR,*
		movep	X:<<HRX,Y:(r3)

		move					X:(r5)+,x0	Y:(r3),y0
		mpy		y0,x1,a		X:(r6),b		a,Y:(r2)+
		move		a0,y0
		mac		y0,x0,b		X:(r5)-,x0	Y:(r2),a
		mac		y0,x0,a		b,X:(r6)+

		move					X:(r5)+,x0	Y:(r3),y0
		mpy		y0,y1,a		X:(r6),b		a,Y:(r2)+
		move		a0,y0
		mac		y0,x0,b		X:(r5)-,x0	Y:(r2),a
		mac		y0,x0,a		b,X:(r6)+

Treat_030_8_Bits_Mono_Voice_Loop
		rts

Treat_030_8_Bits_Stereo_Voice
		jclr		#<HTDE,X:<<HSR,Treat_030_8_Bits_Stereo_Voice
		movep	b,X:<<HTX

		move		#>$008000,y1
		move		r6,r2
		move		#<Voice_Vol_L,r5
		move		#<Dummy,r3

		move		#>$7fffff,y0
		move		X:-(r6),x0
		Do		X:Length,Treat_030_8_Bits_Stereo_Voice_Loop

		jclr		#<HRDF,X:<<HSR,*
		movep	X:<<HRX,Y:(r3)
		mac		y0,x0,b		X:(r5)-,x0	Y:(r3),y0
		mpy		y0,x1,a		Y:(r2),b		b,X:(r6)+
		move		a0,y0
		mac		y0,x0,b		X:(r5)+,x0	Y:(r3),y0
		mpy		y0,y1,a		X:(r6),b		b,Y:(r2)+
		move		a0,y0

Treat_030_8_Bits_Stereo_Voice_Loop
		mac		y0,x0,b
		move		b,X:(r6)+
		rts

Treat_030_16_Bits_Voice
		btst		#<3,a
		jcs		<Treat_030_16_Bits_Stereo_Voice

Treat_030_16_Bits_Mono_Voice
		jclr		#<HTDE,X:<<HSR,Treat_030_16_Bits_Mono_Voice
		movep	b,X:<<HTX

		move		X:<Voice_Vol_L,y0
		move		X:<Voice_Vol_R,y1

		Do		X:Length,Treat_030_16_Bits_Mono_Voice_Loop

		jclr		#<HRDF,X:<<HSR,*
		movep	X:<<HRX,x0
		mpy		x0,x1,a		Y:(r6),b
		move		a0,x0
		mac		x0,y0,b		X:(r6),a
		mac		x0,y1,a		b,Y:(r6)
		move					a,X:(r6)+
Treat_030_16_Bits_Mono_Voice_Loop
		rts

Treat_030_16_Bits_Stereo_Voice
		jclr		#<HTDE,X:<<HSR,Treat_030_16_Bits_Stereo_Voice
		movep	b,X:<<HTX

		move		X:<Voice_Vol_L,y0
		move		X:<Voice_Vol_R,y1

		Do		X:Length,Treat_030_16_Bits_Stereo_Voice_Loop

		jclr		#<HRDF,X:<<HSR,*
		movep	X:<<HRX,x0
		mpy		x0,x1,a		Y:(r6),b
		move		a0,x0
		mac		x0,y0,b		X:(r6),a
		jclr		#<HRDF,X:<<HSR,*
		movep	X:<<HRX,x0
		mpy		x0,x1,b		b,Y:(r6)
		move		b0,x0
		mac		x0,y1,a
		move					a,X:(r6)+
Treat_030_16_Bits_Stereo_Voice_Loop
		rts


; Routine that calculates the Volumes

Calc_Volumes
		move		#<Voice_Vol_R,r0
		move		X:<Voice_Volume,x0
		move		X:<Global_Vol,x1
		mpy		x0,x1,a			X:<Nb_Voices,x1
		move		a0,x0
		mpy		x0,x1,a
		move		a,x0				; Global Volume / 1024
								; * Voice Volume / Nb Voices

		move		X:(r0)+,y0
		mpy		x0,y0,a
		asr		a		X:<Master_Vol_R,y1
		move		a0,y0
		mpy		y0,y1,a	X:(r0)-,y0
		mpy		x0,y0,b	a0,X:(r0)+
		asr		b		X:<Master_Vol_L,y1
		move		b0,y0
		mpy		y0,y1,b
		move		b0,X:(r0)
		rts

; The sample frequency is lower than the replay frequency
; we receive the sample in DSP memory
; and makes the frequency calcul and mix it

Treat_Ordinary_Voice
		move		X:<Voice_Atrbts,a
		btst		#<3,a
		jcs		<Treat_Stereo_Voice

Treat_Mono_Voice
		move		X:<Voice_Vol_L,a
		tst		a
		jeq		<Treat_Mono_Right_Voice
		move		X:<Voice_Vol_R,a
		tst		a
		jeq		<Treat_Mono_Left_Voice

		jsr		<Receive_Y_Samples
		jsr		<Calc_Volumes
		jmp		<Mix_Voice

Treat_Mono_Left_Voice
		jsr		<Receive_X_Samples
		jsr		<Calc_Volumes
		jmp		<Mix_Voice_Left

Treat_Mono_Right_Voice
		jsr		<Receive_Y_Samples
		jsr		<Calc_Volumes
		jmp		<Mix_Voice_Right

Treat_Stereo_Voice
		jsr		<Receive_Stereo_Samples
		jsr		<Calc_Volumes
		jsr		<Mix_Voice_Left
		jmp		<Mix_Voice_Right


; Routines that receive 8/16 bits mono samples in X memory

Receive_X_Samples
		move		X:<Voice_Atrbts,a
		btst		#<2,a
		jcs		<Receive_X_Samples_16

Receive_X_Samples_8
		move		#Sample+1,r0
		move		#>$ff0000,x1

		move		#>1,a
		addr		a,b			#3,n0

		Do		b,Receive_X_Loop_8
Receive_X_Sample_8
		jclr		#<HRDF,X:<<HSR,Receive_X_Sample_8
		movep	X:<<HRX,x0
		mpy		y0,x0,a
		mpy		y1,x0,a		a0,b
		and		x1,b			a0,X:(r0)-
		move		b1,X:(r0)+n0
Receive_X_Loop_8
		rts

Receive_X_Samples_16
		move		#>1,a
		add		a,b			#Sample,r0

		Do		b,Receive_X_Loop_16
Receive_X_Sample_16
		jclr		#<HRDF,X:<<HSR,Receive_X_Sample_16
		movep	X:<<HRX,x0
		mpy		y0,x0,a
		move		a0,X:(r0)+
Receive_X_Loop_16
		rts

; Routines that receive 8/16 bits mono samples in Y memory

Receive_Y_Samples
		move		X:<Voice_Atrbts,a
		btst		#<2,a
		jcs		<Receive_Y_Samples_16

Receive_Y_Samples_8
		move		#Sample+1,r0
		move		#>$ff0000,x1

		move		#>1,a
		addr		a,b			#3,n0

		Do		b,Receive_Y_Loop_8
Receive_Y_Sample_8
		jclr		#<HRDF,X:<<HSR,Receive_Y_Sample_8
		movep	X:<<HRX,x0
		mpy		y0,x0,a
		mpy		y1,x0,a		a0,b
		and		x1,b			a0,Y:(r0)-
		move		b1,Y:(r0)+n0
Receive_Y_Loop_8
		rts

Receive_Y_Samples_16
		move		#>1,a
		add		a,b			#Sample,r0

		Do		b,Receive_Y_Loop_16
Receive_Y_Sample_16
		jclr		#<HRDF,X:<<HSR,Receive_Y_Sample_16
		movep	X:<<HRX,x0
		mpy		y0,x0,a
		move		a0,Y:(r0)+
Receive_Y_Loop_16
		rts

; Routines that receive 8/16 bits stereo samples

Receive_Stereo_Samples
		move		X:<Voice_Atrbts,a
		btst		#<2,a
		jcs		<Receive_Stereo_Samples_16

Receive_Stereo_Samples_8
		move		#>$ff0000,x1
		move		#>1,a
		add		a,b			#Sample,r0

		Do		b,Receive_Stereo_Loop_8
Receive_Stereo_Sample_8
		jclr		#<HRDF,X:<<HSR,Receive_Stereo_Sample_8
		movep	X:<<HRX,x0
		mpy		y0,x0,a
		mpy		y1,x0,a		a0,b
		and		x1,b			a0,X:(r0)		; Right
		move		b1,Y:(r0)+				; Left
Receive_Stereo_Loop_8
		rts

Receive_Stereo_Samples_16
		move		#>1,a
		add		a,b			#Sample,r0

		Do		b,Receive_Stereo_Loop_16
Receive_Left_Sample_16
		jclr		#<HRDF,X:<<HSR,Receive_Left_Sample_16
		movep	X:<<HRX,x0
		mpy		y0,x0,a
		move		a0,Y:(r0)
Receive_Right_Sample_16
		jclr		#<HRDF,X:<<HSR,Receive_Right_Sample_16
		movep	X:<<HRX,x0
		mpy		y0,x0,a
		move		a0,X:(r0)+
Receive_Stereo_Loop_16
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

; Data Zone

			org		X:0

Old_Adr		DC		Sample_Buffer
Calc_Adr		DS		1
Length		DS		1
Master_Vol_R	DS		1
Master_Vol_L	DS		1
Global_Vol	DS		1
Nb_Voices		DS		1
Voice_Vol_R	DS		1
Voice_Vol_L	DS		1
Voice_Atrbts	DS		1
Voice_Volume	DS		1
Voice_Freq	DS		1
Voices_Frac	DS		34
Save_r0		DS		1
Save_a		DS		1

			org		Y:0

Dummy		DS		1

			org		L:6*2048

Sample_Buffer	DS		2048

Sample		DS		1500

			END
