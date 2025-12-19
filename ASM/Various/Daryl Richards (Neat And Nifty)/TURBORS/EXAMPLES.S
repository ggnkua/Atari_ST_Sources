;	--------------------------------------------------------
;	Detect_TurboRS - Will set Tbrs_Flag if TurboRS is found
;	   will also set Tbrs_Struct to point to TurboRS control
;	   structure if found via software
;	--------------------------------------------------------
Detect_TurboRS:
	clr	Tbrs_Flag	; Assume TurboRS not present
	pea	.work		; Run detection code in
	move	#38,-(sp)	;  Supervisor mode
	trap	#14		; Xbios : Supexec( .work )
	addq.l	#6,sp
	rts

;	Software Detection Code -- Run from Supervisor mode
;	 - Will set Tbrs_Flag if TurboRS is active
;	 - Will set Tbrs_Struct to the address of control structure
;
;	This code scans the cookie jar for the TBRS cookie
;	created by the driver and checks it for validity
;
;	! THIS IS THE PREFERRED METHOD OF DETECTING TURBORS !

.work:	move.l	$5A0.w,a0	; Get cookie jar pointer
	tst.l	a0		; Cookie jar present?
	beq	.done		;  if not, we're done
.loop:	tst.l	(a0)		; At end of cookie jar?
	beq	.done		;  if so, we're done
	cmp.l	#'TBRS',(a0)+	; TurboRS cookie found?
	beq	.found		;  if so, validate it
	addq.l	#4,a0		; Skip value of current cookie
	bra	.loop		; Keep Searching

.found: move.l	(a0)+,a1	; Valid TurboRS cookie?
	cmp.l	#$31415926,(a1) ;  if not, keep searching
	bne	.loop
	move.l	a1,Tbrs_Struct	; Save Structure Pointer
	move	#1,Tbrs_Flag	; Set Tbrs_Flag = Found
.done:	rts

;	Hardware Detection Code -- Run from Supervisor mode
;	 - Will set Tbrs_Flag if TurboRS is present
;
;	This codes detects the hardware by attempting to set it
;	to 115200 baud then verifying the set by counting the
;	number of characters it can send
;
;	! USE ONLY IF YOUR PROGRAM MUST DIRECTLY ACCESS THE ACIAS !

.work:	move.b	$FA07.w,d2	; Preserve MFP Interrupt State
	move.b	$FA13.w,d3
	and.b	#$E1,$FA07.w	; Mask Off Modem1 Interrupts
	and.b	#$E1,$FA13.w
	and.b	#$F0,$FA1D.w	; Set Timer D for 9600 Baud
	or.b	#1,$FA1D.w
	move.b	#2,$FA25.w
	move.b	#$D6,$FC00.w	; Set ACIAs for 115200 clock
	move.b	#$D5,$FC04.w
	bset	#0,$FA2D.w	; Ensure Transmitter Enabled
	move.l	$4BA.w,d1	; Set d1 = 1/10s from now
	add.l	#20,d1
	clr	d0		; Use d0 = character count

.loop:	move.b	#-1,$FA2F.w	; Transmit $FF
	addq	#1,d0		; Count Character
.flush:	btst	#7,$FA2D.w	; Character Transmitted?
	beq	.flush		;  nope, wait till it is
	cmp.l	$4BA.w,d1	; Time Expired?
	bgt	.loop		;  if not, transmit again

	move.b	#$96,$FC00.w	; Reset ACIAs for Timer D clock
	move.b	#$95,$FC04.w
	move.b	d2,$FA07.w	; Restore MFP Interrupt State
	move.b	d3,$FA13.w
	cmp	#200,d0 	; 200 or more characters sent?
	blt	.done		;  if not, we're done
	move	#1,Tbrs_Flag	; Set Tbrs_Flag = found
.done:	rts
