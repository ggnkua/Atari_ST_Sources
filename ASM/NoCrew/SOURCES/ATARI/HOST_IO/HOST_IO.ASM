; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;          - DSP Host Port I/O -
;        a NoCrew production MCMXCV
;
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; DSP 56001 module.

	include	"equates.asm"

	org	p:$0
	jmp	<start

	org	p:$40
start	jsr	<Host_get
	move	x0,y1	; y1 = a
	jsr	<Host_get
	move	x0,y0	; y0 = b
	jsr	<Host_get	; x0 = c

	move	y1,A	; a
	add	x0,A	; + c
	add	y0,A	; + b
	jsr	<Host_send	; = a+b+c

	move	y1,A	; a
	move	#0.3,x1	; 0.3
	mac	x0,x1,A	; + c * 0.3
	jsr	<Host_send	; = a+0.3*c

	move	y1,A	; a
	move	#0.8,x1	; 0.8
	macr	-y0,x1,A	; - b * 0.8
	jsr	<Host_send	; = a-0.8*b

	jmp	<start

; Host I/O routines.
Host_get	jclr	#0,X:<<M_HSR,<Host_get
	movep	X:<<M_HRX,x0
	rts
Host_send	jclr	#1,X:<<M_HSR,<Host_send
	movep	A,X:<<M_HTX
	rts
