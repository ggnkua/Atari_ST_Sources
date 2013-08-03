;***********************************************************************
;***********										 ***********
;***********										 ***********
;***********			DSP Sample Program				 ***********
;***********	to test Amiga DSP-Replay under interrupt	 ***********
;***********										 ***********
;***********										 ***********
;***********		  By Simplet / FATAL DESIGN			 ***********
;***********										 ***********
;***********************************************************************

HSR		equ		$ffe9			; Host Status Register
HRX		equ		$ffeb			; Host Receive Register
HTX		equ		$ffeb			; Host Transmit Register

;	Host Status Register Bit Flags

HRDF		equ		0				; Host Receive Data Full
HTDE		equ		1				; Host Transmit Data Empty


; The P56 Loader jumps here :

		org		p:$0
		jmp		<Start

; You must start your program after the Amiga DSP Replay and P56 Loader
; You can't get a lot of internal memory unless you modify
; the AMGDSPIT.ASM source and place all the slow tracker routines
; in external memory...

; You can freely use the Host Commands (but $24 and $26)
; Warning, You can't use the r7 and m7 registers !!!
; don't modify the m0->m5 registers too, I don't save them

		org		p:$191

Start

;
; Main Loop
;
		move		#Reelle,r0
		move		#C_Re,r1
		move		#C_Im,r2
		move		#Imaginaire,r4

Loop		jclr		#<HRDF,X:<<HSR,Loop
		movep	X:<<HRX,X:X_Dep	; X de depart
		jclr		#<HRDF,X:<<HSR,*
		movep	X:<<HRX,Y:(r4)		; Y de depart
		jclr		#<HRDF,X:<<HSR,*
		movep	X:<<HRX,y1		; Increment
		jclr		#<HRDF,X:<<HSR,*
		movep	X:<<HRX,X:(r1)		; Re(Cst)
		jclr		#<HRDF,X:<<HSR,*
		movep	X:<<HRX,X:(r2)		; Im(Cst)

		Do		#100,Screen_Loop

		move		X:X_Dep,x0
		move		x0,X:(r0)
		
		Do		#320,Line_Loop

		move		#>4,b
		move		X:(r0),x0		Y:(r4),y0

Pixel_Loop
		mpy		x0,x0,a
		mac		y0,y0,a
		asl		a
		asl		a
		jes		<Send_PixL	; > (2^2/4) ?

		mpy		x0,x0,a
		mac		-y0,y0,a		X:(r1),x1
		asl		a
		asl		a
		add		x1,a			X:(r2),x1

		mpy		x0,y0,a		a,x0
		rep		#<3
		asl		a
		add		x1,a			#>1,x1
		add		x1,b			#>32,x1
		cmp		x1,b			a,y0
		jlt		<Pixel_Loop

Send_PixL	jclr		#<HTDE,X:<<HSR,Send_PixL
		movep	b1,X:<<HTX

		move		X:(r0),a
		add		y1,a
		move		a,X:(r0)
		
Line_Loop

		move		Y:(r4),a
		add		y1,a
		move		a,Y:(r4)
Screen_Loop

		jmp		<Loop


			org		x:$1f8

Reelle		DS		1
X_Dep		DS		1
C_Re			DS		1
C_Im			DS		1

			org		y:$1f8

Imaginaire	DS		1
