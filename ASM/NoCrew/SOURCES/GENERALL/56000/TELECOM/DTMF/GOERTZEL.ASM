

		section		goertzel

		opt            mu,cc,mex,nomd

		include	'StdDefs'

		xdef		goe_it



;***********************************************************************************************

;

; Perform one iteration of Goertzel algorithm for four channels

;

;***********************************************************************************************



goe_it	jsr			<win_calc					; calculate	windowing function

		move		y:<n_samps,r1				; read number of samples since start

		move		#<ch1_mem,r0				; set up data pointer for channel 1

		move		x:DTMF_IN,x0				; read channel 1 data from RX reg. 

		move		(r1)+						;increment count

		move		r1,y:<n_samps				; store new count

		jsr			<goertzel					; process channel 1

		move		#<ch2_mem,r0				; set up data pointer for channel 2

		move		x:DTMF_IN+1,x0				; read channel 2 data from RX reg.

		jsr			<goertzel					; process channel 2

		move		#<ch3_mem,r0				; set up data pointer for channel 3

		move		x:DTMF_IN+2,x0				; read channel 3 data from RX reg.

		jsr			<goertzel					; process channel 3

		move		#<ch4_mem,r0				; set up data pointer for channel 4

		move		X:DTMF_IN+3,x0				; read channel 4 data from RX reg.

		jsr			<goertzel					; process channel 4

		move		#<ch5_mem,r0				; set up data pointer for channel 5

		move		X:DTMF_IN+4,x0				; read channel 5 data from RX reg.

		jsr			<goertzel					; process channel 5

		move		#<ch6_mem,r0				; set up data pointer for channel 6

		move		X:DTMF_IN+5,x0				; read channel 6 data from RX reg.

		jsr			<goertzel					; process channel 6

		rts





;*********************************************************************************************

; Power calculation for dial tone detector

; 

; Calling Setup :

;

;		x0		:		contains log input data

;		r0		:		contains address of data tables for channel

;

; Perform one iteration of Goertzel algorithm on channel whose rows and columns are at

; the addresses from (r0) (columns).  Input sample in x0.

;

; memory storage 	:	y(n-1) in x:(r0), y(n-2) in y:(r0)

; 					Ck in y:(r5)

;

;***********************************************************************************************



goertzel	move	x:<cshift,y0

			mpy		x0,y0,a         x:<cmask,x1

			and		x1,a            y:<tab_val,r1

			move	a1,n1

			move	#<tab1,m1

			cmpm	y0,a			y:<win_val,x0			; check sign to see about invert

			move	x:(r1+n1),y0							; read value

			jge		<_end_s									; do we need to invert? if so...

			mpy		-x0,y0,a	#<coeffL1,r5				; apply negative windowing function

			jmp		<_endp									; and exit window stage

_end_s		mpy		x0,y0,a		#<coeffL1,r5				; apply positive windowing function

		

_endp		move	a,b										; save result of conversion

			move	#0.5,x1	

			or		#8,mr									; enable scaling	



			do		#n_dtmf,_e_goert						; repeat for all n row/column tones

			tfr					b,a				y:(r0),y0 	; fetch x(n) and y(n-2)

			mac		-x1,y0,a	x:(r0),x0		y:(r5)+,y0	; form x(n)-y(n-2), fetch y(n-1) and Ck

			macr	x0,y0,a		x0,y:(r0)					; form x(n)+b1*y(n-1)-2*y(n-2), save y(n-1)

			move	a,x:(r0)+								; save y(n)

_e_goert	and		#$f7,mr									; disable scaling

			rts

			



;*********************************************************************************************

; Generate a data smoothing window coefficient - in this case, Hanning

;

; Result in y:win_val

;

; Should only be called when a window is definitely wanted.

; Will clear "req_win" on exit, preventing further calls

; unless explicitly requested.

;

; This generates the smoothing window used for all channels.

;***********************************************************************************************



win_calc	clr		a			y:<n_samps,x0	; read position in window

			move	y:<win_scal,x1				; read scale factor

			mpy		x1,x0,a		#$100,x1		; scale window data, get number of points in table

			

			asl		a			#>$40,y0		; start offset into table

			add		y0,a		#>$ff,y0		; add to form access offset

			and		y0,a						; limit to 8 bits

			add		x1,a						; add table start address

			move	a,r1						; and use for access

			move	#0.5,b						; scale factor

			move	y:(r1+n1),a					; read table entry

			asr		a							; divide by 2

			sub		a,b							; window function coefficient calculated

			move	b,x1		y:fiddle,y0	; shift into y0....

			mpy		x1,y0,a						; and scale coefficient

			move	a,y:<win_val

			rts



			endsec

			

