;*****************************************************************************
;                           PS2Atari_v1_1.asm                                *
;     PS2 PC mouse to Atari / Amiga mouse converter by Tom Kirk August 04    *
;			      Version 1.1                                    *
;*****************************************************************************
;                                                                            *
;   Enables a PS2 PC mouse to be used with Atari / Amiga computers using     *
;     the circuit in circuit.bmp with a PIC16F84(A)/C84 micrcontroller.       *
;                                                                            *
;	          Assembled using Microchip MPLAB and MPASM.                 *
;                                                                            *
;*****************************************************************************
;                                                                            *
;                          Version 1.1 August 04                             *	
;	                  Added support for Amiga.                           *
;                                                                            *
;*****************************************************************************


	; list directive to define processor
	list		p=16F84A

	; processor specific variable definitions
	#include	<p16F84A.inc>

	; define config bits	
	__CONFIG _CP_OFF & _WDT_OFF & _PWRTE_ON & _XT_OSC  

	;4 MHz Clock
 
;************************ Input output usage ********************

; RA0 Atari / Amiga select i/p
; RA1 PS2 mouse data
; RA2 PS2 mouse clock
; RA3 Not used
; RA4 Not used

; RB0 Atari XA / Amiga XA o/p
; RB1 Atari XB / Amiga YB o/p
; RB2 Atari YA / Amiga YA o/p
; RB3 Atari YB / Amiga XB o/p
; RB4 Left button o/p
; RB5 Right button o/p
; RB6 Not used
; RB7 Not used

;*******************************************************************


;********** I/O port equates **************


ps2data	equ	1	;ps2 mouse data signal
ps2clk	equ	2	;ps2 mouse clock signal


;********** User register equates *********

temp    equ     0ch     ;Temporary storage
byte1	equ	0dh	;Byte 1 store
byte2	equ	0eh	;Byte 2 store
byte3	equ	0fh	;Byte 3 store
xinc	equ	010h	;last x increment read
yinc	equ	011h	;last y increment read
xlow	equ	012h	;low byte of 16 bit x counter
xhigh	equ	013h	;high byte of 16 bit x counter
ylow	equ	014h	;low byte of 16 bit y counter
yhigh	equ	015h	;high byte of 16 bit y counter
xpat	equ	016h	;x pattern position
ypat	equ	017h	;y pattern position
bcnt    equ     018h    ;bit counter
brec    equ     019h    ;byte received
timer	equ	01ah	;timer counter
parity	equ	01bh	;parity store
flag	equ	01ch	;flag bits	(bit 0 = ack error flag)
			;	 	(bit 1 = parity error flag)
			;	   	(bit 2 = middle button pressed flag)
			;		(bit 3 = middle state flag)
			;		(bit 4 = left button flag)
 
;*****************************************************************************************

;***** initialise program *******

reset	clrwdt
        bcf     status,rp0      ;set page0
        clrf    intcon          ;disable interupts
        bsf     status,rp0
        movlw   084h            ;set tmr0 to int clk,prescale/32
        movwf   option_reg
        bcf     status,rp0
        clrf    porta           ;all porta outputs will be low when enabled
        movlw   030h            ;set mouse buttons and x y start levels
        movwf   portb
        bsf     status,rp0
        movlw   07h             ;set porta bits 0,1,and 2 as inputs
        movwf   trisa
        movlw   0               ;set portb to all outputs
        movwf   trisb
        bcf     status,rp0

        clrf    byte1		;set start up values 
        clrf    byte2
        clrf    byte3
        clrf    xinc
        clrf    yinc
        clrf    xlow
        clrf    xhigh
        clrf    ylow
        clrf    yhigh
        clrf    xpat
        clrf    ypat
	clrf	flag


;***************** set up ps2 mouse *********************


start	call	ps2read		;read power up self test report
	btfsc	flag,1		;parity error?
	goto	restart		;yes so jump
	movlw	0aah		;correct ?
	subwf	brec,w
	btfss	status,z
	goto	restart		;no so jump	
	
	call	ps2read		;read power up pc mouse id
	btfsc	flag,1		;parity error?
	goto	restart		;yes so jump
	movlw	0h		;correct ?
	subwf	brec,w
	btfss	status,z
	goto	restart		;no so jump	
	
restart	movlw	0ffh		;send reset pc mouse command
	call	ps2wri
	btfsc	flag,0		;ack bit?
	goto	restart		;no so jump
	
	call	ps2read		;ack returned
	btfsc	flag,1		;parity error?
	goto	restart		;yes so jump
	movlw	0fah		;correct ?
	subwf	brec,w
	btfss	status,z
	goto	restart		;no so jump	
	
	call	ps2read		;read self test report
	btfsc	flag,1		;parity error?
	goto	restart		;yes so jump
	movlw	0aah		;correct ?
	subwf	brec,w
	btfss	status,z
	goto	restart		;no so jump	
	
	call	ps2read		;read pc mouse id
	btfsc	flag,1		;parity error?
	goto	restart		;yes so jump
	movlw	0h		;correct ?
	subwf	brec,w
	btfss	status,z
	goto	restart		;no so jump	

	movlw	0f4h		;send enable reporting command
	call	ps2wri
	btfsc	flag,0		;ack bit?
	goto	restart		;no so jump
	
	call	ps2read		;ack returned
	btfsc	flag,1		;parity error?
	goto	restart		;yes so jump
	movlw	0fah		;correct ?
	subwf	brec,w
	btfss	status,z
	goto	restart	

	movlw	0f3h		;send set sample rate command
	call	ps2wri
	btfsc	flag,0		;ack bit?
	goto	restart		;no so jump
	
	call	ps2read		;ack returned
	btfsc	flag,1		;parity error?
	goto	restart		;yes so jump
	movlw	0fah		;correct ?
	subwf	brec,w
	btfss	status,z
	goto	restart	

	movlw	028h		;send sample rate (40)
	call	ps2wri
	btfsc	flag,0		;ack bit?
	goto	restart		;no so jump
	
	call	ps2read		;ack returned
	btfsc	flag,1		;parity error?
	goto	restart		;yes so jump
	movlw	0fah		;correct ?
	subwf	brec,w
	btfss	status,z
	goto	restart	

;******************* Main program loop ****************************

main	call    ps2read         ;read 3 byte pc mouse packet
	btfsc	flag,1		;parity error?
	goto	restart		;yes so jump
	movf    brec,w
        movwf   byte1
        call    ps2read
	btfsc	flag,1		;parity error?
	goto	restart		;yes so jump
        movf    brec,w
        movwf   byte2
        call    ps2read
	btfsc	flag,1		;parity error?
	goto	restart		;yes so jump
        movf    brec,w
        movwf   byte3

;adjust the 16 bit x counter

	clrf	temp		;use temp as high byte		
	btfsc	byte1,4		;extend sign bit into high byte
	decf	temp,f
		
	movf	byte2,w		;add low bytes
	addwf	xlow,f
	btfsc	status,c	;add carry to high
	incf	xhigh,f
	movf	temp,w		;add high bytes
	addwf	xhigh,f	

;adjust the 16 bit y counter

	clrf	temp		;use temp as high byte		
	btfsc	byte1,5		;extend sign bit into high byte
	decf	temp,f
		
	movf	byte3,w		;add low bytes
	addwf	ylow,f
	btfsc	status,c	;add carry to high
	incf	yhigh,f
	movf	temp,w		;add high bytes
	addwf	yhigh,f

;left button

	btfss	byte1,0		;is the left pc mouse button pressed
	goto	lbutt		;no so jump
	bsf	flag,4		;set left button flag
	goto	nbutt
lbutt	bcf	flag,4		;reset left button flag

;right button

nbutt	btfss	byte1,1		;is the right pc mouse button pressed
	goto	rbutt		;no so jump
	bcf	portb,5		;set right button as pressed
        goto    main
rbutt	bsf	portb,5		;set right button as not pressed

;middle button

	btfss	byte1,2		;check if middle button pressed		 
	goto	mbutt		;jump if not
	btfsc	flag,2		;check middle button pressed flag
	goto	mbex		;set so jump
	movlw	08h		;toggle middle state flag
	xorwf	flag,f
	bsf	flag,2		;set middle button pressed flag
	goto	mbex	

mbutt	btfss	flag,2
	goto	mbex
	bcf	flag,2		;reset middle button pressed flag
mbex

	btfsc	flag,3		;check middle state flag 
	goto	setlb		;jump if set
	btfsc	flag,4		;check left button flag
	goto	setlb		;jump if set
	bsf	portb,4		;no flags set so set left buuton not pressed
        goto    main
setlb	bcf	portb,4		;set left button pressed
	goto	main


;***************************** Subs *****************************************

;***** Read a byte from the ps2 mouse ******

ps2read btfss   porta,ps2data   ;data low ?
        goto    ps2r1           ;yes so start reading data
        call    trans           ;no so do emulated mouse move
        clrf    tmr0            ;clear rtcc before delay

oned    btfss   porta,ps2data   ;data low ?
        goto    ps2r1           ;yes so start reading data
        movlw   0dh             ;delay between emulated mouse moves
        subwf   tmr0,w
        btfss   status,z
        goto    oned            ;not done so jump
        goto    ps2read         ;check again

ps2r1	call	wlow		;wait until clock goes low for start bit
	
	call	whigh		;wait until clock is high		

	movlw	08h		;read 8 data bits
	movwf	bcnt
	clrf	parity		;clear parity counter

ps2r2   call	wlow		;wait until clock is low
	bcf	status,c	;clear carry flag
	btfss   porta,ps2data   ;data bit set ?
        goto	ps2r3		;no so jump
	incf	parity,f	;yes so inc the parity counter
	bsf	status,c	;set carry bit
ps2r3	rrf	brec,f          ;shift carry into destination

        call    whigh           ;wait until clock is high
	
        decfsz  bcnt,f          ;finished the 8 bits?
        goto    ps2r2           ;no so do again

	call	wlow		;for the parity bit
	btfsc   porta,ps2data   ;parity bit set?
        incf	parity,f	;yes so inc the parity counter	
	bcf	flag,1		;clear flag (no error)
	btfss	parity,0	;check calculated parity
	bsf	flag,1		;set flag (parity error!)
	call	whigh
	
	call	wlow		;for the stop bit
	call	whigh

        return			;and exit
	
;***** Write a byte to the ps2 mouse ******

ps2wri	movwf	brec		;speed not important at this point so 
	movwf	temp		;calculate parity seperate for sake of
	movlw	08h		;clarity
	movwf	bcnt
	clrf	parity
ps2w1	rrf	temp,f		;shift bit into carry
	movlw	01h		;preset for bit set
	btfss	status,c	;test carry
	clrw			;bit zero so no addition
	addwf	parity,f	;update parity
	decfsz	bcnt,f		;any more bits to do?
	goto	ps2w1		;yes so jump
	comf	parity,f	;only intrested in bit 0.
				;parity bit is complement of bit 0

	movlw	08h		;bit count to 8
	movwf	bcnt

	call	clkl		;set clock low
	
	movlw	021h		;wait 100 uS
	movwf	temp
ps2ww	decfsz	temp,f
	goto	ps2ww	

	call	datl		;set data low
	nop			;wait 5 uS
	nop
	nop
	nop
	nop
	call	clkh		;set clock high
		
ps2w2	call	wlow		;wait for clock to go low
	rrf	brec,f		;rotate bit into carry for testing
	btfss	status,c
	goto	ps2w3		;jump if bit is low
	call	dath		;set data high
	goto	ps2w4
ps2w3	call	datl		;set data low
ps2w4	call	whigh		;wait for clock to go high

	decfsz	bcnt,f		;any more bits to send?
	goto	ps2w2		;yes so jump	
	
	call	wlow		;wait for clock to go low
	btfss	parity,0	;send parity bit
	goto	ps2w5
	call	dath
	goto	ps2w6
ps2w5	call	datl
ps2w6	call	whigh
	
	call	wlow		;send stop bit
	call	dath
	call	whigh	

	call	wlow		;read ack from mouse
	bcf	flag,0
	btfsc	porta,ps2data
	bsf	flag,0
	call	whigh

	return


;******* wait for ps2 clock to go low **********

wlow	btfsc	porta,ps2clk
	goto	wlow
	return		


;******* wait for ps2 clock to go high **********

whigh	btfss	porta,ps2clk
	goto	whigh
	return		


;******* set ps2 clock low *********************

clkl	bsf	status,rp0
	bcf	trisa,ps2clk
	bcf	status,rp0
	return


;******* set ps2 clock high ********************

clkh	bsf	status,rp0
	bsf	trisa,ps2clk
	bcf	status,rp0
	return


;******* set ps2 data low *********************

datl	bsf	status,rp0
	bcf	trisa,ps2data
	bcf	status,rp0
	return


;******* set ps2 data high *********************

dath	bsf	status,rp0
	bsf	trisa,ps2data
	bcf	status,rp0
	return



;********* emulate mouse move ***************************

;move the emulated mouse by one step in the x direction if needed  

trans   movf    xlow,w          ;is the x counter zero?
	iorwf	xhigh,w
	btfsc	status,z
	goto	ymove		;no so jump to y direction
	
	btfsc	xhigh,7		;is the x counter positive or negative?
	goto	xneg		;jump if negative
	
	incf	xpat,f		;increment the pattern list position
	movlw	04h		;test if end of pattern list
	subwf	xpat,w
	btfsc	status,z
	clrf	xpat		;end of pattern list so reset
	movlw	0ffh		;subtract 1 from the 16 bit counter by adding ffffh
	addwf	xlow,f
	btfsc	status,c	;add carry to high byte
	incf	xhigh,f			 
	addwf	xhigh,f
	goto	ymove		;exit to y direction

xneg	decf	xpat,f		;decrement the pattern list position
	movlw	0ffh		;test if end of pattern list
	subwf	xpat,w
	btfss	status,z
	goto	xno	
	movlw	03h		;end of pattern list so reset
	movwf	xpat
xno	movlw	01h		;add 1 to the 16 bit counter
	addwf	xlow,f
	btfsc	status,c	;add carry to high byte
	incf	xhigh,f			 

;move the emulated mouse by one step in the y direction if needed  
	
ymove	movf	ylow,w		;is the y counter zero? 
	iorwf	yhigh,w
	btfsc	status,z
	goto	out		;no so jump to output pattern
	
	btfsc	yhigh,7		;is the y counter positive or negative?
	goto	yneg		;jump if negative
	
        incf    ypat,f          ;increment the pattern list position
	movlw	04h		;test if end of pattern list
	subwf	ypat,w
	btfsc	status,z
	clrf	ypat		;end of pattern list so reset
	movlw   0ffh            ;subtract 1 from the 16 bit counter by adding ffffh
	addwf	ylow,f
	btfsc	status,c	;add carry to high byte
	incf	yhigh,f			 
	addwf	yhigh,f
	goto	out		;exit to output pattern

yneg    decf    ypat,f          ;decrement the pattern list position
	movlw	0ffh		;test if end of pattern list
	subwf	ypat,w
	btfss	status,z
	goto	yno
	movlw	03h		;end of pattern list so reset
        movwf	ypat
yno	movlw   01h             ;add 1 to the 16 bit counter
	addwf	ylow,f
	btfsc	status,c	;add carry to high byte
	incf	yhigh,f		

;output new x and y patterns 	

out	btfsc	porta,0		;test if set for atari
	goto	amiga

	movf	xpat,w		;get the x pattern bits
	bsf	pclath,1	;set page 2
	call	pattx
	movwf	temp		;store the pattern in temp
	movf	ypat,w		;get the y pattern bits
	call	patty
	clrf	pclath		;set page 0
	iorwf	temp,f		;store the pattern in temp
	
	goto	outpat

amiga	movf	xpat,w		;get the x pattern bits
	bsf	pclath,1	;set page 2
	call	apatx
	movwf	temp		;store the pattern in temp
	movf	ypat,w		;get the y pattern bits
	call	apaty
	clrf	pclath		;set page 0
	iorwf	temp,f		;store the pattern in temp
	
outpat	movf	portb,w		;read port b
        andlw   0f0h            ;keep button state
	iorwf	temp,w		;merge with new x and y patterns
	movwf	portb		;ouput patterns

	
	return


;*************** pattern lists **************

	org	0200h

;atari patterns
pattx	addwf	pcl,f
	retlw	0
	retlw	1
	retlw	3
	retlw	2

patty	addwf	pcl,f
        retlw   0
        retlw   4
        retlw   0ch
        retlw   8
	
;amiga patterns
apatx	addwf	pcl,f
	retlw	0
	retlw	1
	retlw	9
	retlw	8

apaty	addwf	pcl,f
        retlw   0
        retlw   4
        retlw   6
        retlw   2

;*******************************************************************************

	END


