;***************************************************************
;
;	basic run-time
;
;***************************************************************
	include	'ioequ.inc'
;
; vectors
;
	org	p:$0000
        movep	#$0f0f,x:m_bcr			;wait: RAM:0;ROM,I/O:15
	jmp	<start

	org	p:$000C
	jsr	<ssi_int			;go handle SSI interrupt
	org	p:$0010
ssix	jsr	<ssi_int			;go handle SSI interrupt

;
; global data areas
;
	org	x:$0
in_l	dc	0	   			;input queue
in_r	dc	0
in_ls	dc	0   				;saved left
in_rs	dc	0   				;and right
out_l	dc	0				;output queue
out_r	dc	0

savea10 dc	0				;places to save regs
savea2	dc	0				;N.B. uses YMEM also!
saveb10	dc	0
saveb2	dc	0
savex	dc	0
savey	dc	0

;
; global register assignments
;
; r5,m5		Stereo input queue pointer (alternating L/R)
; r4,m4		Stereo output queue pointer (alternating L/R)

;***************************************************************
;
;	initialization
;
;***************************************************************
	org	p:$40		;$$$ move to external RAM
start
	movec	#$0300,sr			;go to IPL 3

	jsr	hf_init
;
; set up SSI
;
	movep	#2<<13|1<<8,x:m_cra		;16-bit word, 2 time slots
	movep	#1<<14|3<<12|1<<11|1<<9,x:m_crb	;sync,network,enable,SC2 in

	movep	#0,x:m_pcddr			;port C is SSI/SCI
	movep	#$1FF,x:m_pcc			;port C is SSI/SCI
	jsr	init_stereo
;
; enable interrupts
;
	movep	#1<<12,x:m_ipr			;SSI at 1, others off
	movec	#0,sr				;lower IPL
	jset	#0,x:m_sr,*			;sync up with left chan
	jclr	#0,x:m_sr,*			;
	jsr	init_stereo

	jmp	mainloop

init_stereo
	move		#>in_l,r5		;base of stereo input queue
	move		#>out_l,r4		;base of stereo output queue
 	movec		#2-1,m5			;modulus of stereo input queue
	movec		#2-1,m4			;modulus of stereo output queue
	rts

;***************************************************************
;
;	main loop
;
;***************************************************************
mainloop
;       
;	do any polling or foreground tasks here
;
	jmp	<mainloop

;***************************************************************
;
;	interrupt service
;
;***************************************************************
	
;
; SSI interrupt routine
;

; keep in on-chip RAM

ssi_int
	movep	x:m_rx,x:(r5)+			;bring in L or R
	movep	x:(r4)+,x:m_tx			;and output L or R
	jsset	#0,x:m_sr,hf_comp		;
	rti

saveregs
	move		a2,x:<savea2
	move		a1,x:<savea10
	move		a0,y:<savea10
	move		x,l:<savex
	move		b2,l:<saveb2
	move		b1,x:<saveb10
	move		b0,y:<saveb10
	move		y,l:<savey
	rts

restregs
	move		l:<savea10,a
	move		x:<savea2,a2
	move		l:<savex,x
	move		l:<saveb10,b
	move		x:<saveb2,b2
	move		l:<savey,y
	rts

