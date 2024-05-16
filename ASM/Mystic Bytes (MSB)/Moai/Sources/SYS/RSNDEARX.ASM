;==========================================================================
; ringbuffer save/restore bug fixed by MiKRO (you couldn't use m1 register in your code)
; realsound mixer hack by earx (for qdsp)
; original code by newface
;
; we use from y:$3BF8 to y:$4000 (from p:$3BF8 to p:$4000)
;    and from x:$3000 to x:$3BA8 (from p:$7000 to p:$7BA8)
; we use R7 M7 for SSI transmit !

;= equates =================================================================

PBC:		=	$FFE0					;Port B Control register
PCC:		=	$FFE1					;Port C Control register
PCDDR:		=	$FFE3					;Port C Data Direction Register
HCR:		=	$FFE8					;Host Control Register
HSR:		=	$FFE9					;Host Status Register
HRX:		=	$FFEB					;Host Receive Register
HTX:		=	$FFEB					;Host Transmit Register
CRA:		=	$FFEC					;SSI Control Register A
CRB:		=	$FFED					;SSI Control Register B
TX:		=	$FFEF					;SSI Serial Transmit data/shift register
IPR:		=	$FFFF					;Interrupt Priority Register

size_buffer:	=	$0A00

;= macros ==================================================================

rhost:	MACRO	dest
	jclr	#0,x:<<HSR,*
	movep	x:<<HRX,\1
	ENDM

whost:	MACRO	source
	jclr	#1,x:<<HSR,*
	movep	\1,x:<<HTX
	ENDM

;= vectors =================================================================

	;org	P:$0000
	;jmp	>start

	org	P:$0010
	movep	x:(r7)+,x:<<TX
	nop
	movep	x:(r7)+,x:<<TX					; transmit exception
	nop

	org	P:$0026
	jsr	>mix
	jsr	>load

;= main code ===============================================================
	
	org	P:$4000+$3000+size_buffer+30

; Initialize the mixer..
start:	bclr	#3,x:<<HCR
	movep	#>1,x:<<PBC					;Host enable
	movep	#>$04,x:<<HCR					;Host Command
	movep	#>$3800,x:<<IPR 				;SSI en IPL3, Host en IPL2
	movep	#>$4100,x:<<CRA					;SSI en 2 mots/frame, 16 bits
	movep	#>$0800,x:<<CRB					;SSI off
	movep	#>$01f8,x:<<PCC					;Port C en SSI
	movep	#>$0008,x:<<PCDDR				;Idem
	andi	#%11110000,mr
	jsr	init_buffer
	bset	#3,x:<<HCR					;fin d'initialisation (sources de plantages...)
	rts

;= program loader interrupt ================================================
;
; Note: kills registers, no overlap checking!
;

load:	movec	#$FFFF,m0					; Set all adr-regs to linear!
	movec	m0,m1
	movec	m0,m2
	movec	m0,m3
	movec	m0,m4
	movec	m0,m5
	movec	m0,m6
	andi	#<$F0,mr					; Allow interrupts.
	move	#>load_register,r1
 	movec	#<0,sp						; Reset sp, cos level0 program has sp=0!
	ori	#<1,mr						; Allow interrupts, except IPL0.

restart:jsr	(r1)
 	move	x0,n2
	move	#list_cmd,r2
 	nop
 	move	p:(r2+n2),r2
	nop
 	jmp	(r2)

	dc	0
list_cmd:
	dc	memoryp
	dc	memoryx
	dc	memoryy

memoryp:jsr	(r1)
 	move			x0,r0
 	jsr	(r1)
 	do	x0,_loop
 	rhost	p:(r0)+
_loop: 	jmp	restart

memoryx:jsr	(r1)
 	move			x0,r0
 	jsr	(r1)
 	do	x0,_loop
 	rhost	x:(r0)+
_loop:	jmp	restart

memoryy:jsr	(r1)
	move			x0,r0
	jsr	(r1)
	do	x0,_loop
	rhost	y:(r0)+
_loop:	jmp	restart
	
load_register:
	rhost	x0
	rts
	
;= mixer interrupt =========================================================
;
; mixtime < consumptiontime = frametime - tick
; This holds only if tick and C are small enough.
;
; Mixtime is linear to mixlength is linear to tick:
; mixtime=C*mixlength=C*framesize*tick/frametime
; C is time per mixsampleword (relative to 1/speed).
;
; Worstcase: 49KHz gives 983 words per 20ms tick. 1280-983=297 words left.
; This means 6ms to do your stuff, certainly enough for 8chn.
; At 33KHz, you have almost 20ms to get the job done.
;
; Concluding: never ever make a tick longer than 20ms.
mix:	jsr	save_reg
	bclr	#3,x:<<HCR
	rhost	a
	tst	a
	jeq	coupe
; Space between ptr_buf (log) and r7 (phys) is forbidden zone.
; The rest can be used for mixing.
	clr	a		y:ptr_buf,r6
	movec	#size_buffer-1,m6
	move			a,y:control_data
	move			a,y:move			; Indicate l/r not moved yet!
	move			r7,a
	move			r6,x0
	sub	x0,a		#>size_buffer,x0		; a=phys-log_end
	jgt	_go_for_that
	add	x0,a
_go_for_that:
	asr	a		#<2,n6				; a=mixlength
	move			#<2,n1
	move			#<2,n2
	move			a,y:loop
	jsr	copy_double_dest
	move			r6,r3				; x:r6=r3=mixbuffer (left)

_voiceloop:
	rhost	a						; a=mixcommand
	move			#>$1234,x0			; x0=terminator
	cmp	x0,a		r3,r6				; Test for terminator, r6:left
	jeq	_end_mixing					; If it's the terminator, end mixing.
	move			a1,y:control_data		; Store commandflags.
	jsr	receive_sample					; Store sample from host to samplebuffer.
	move			(r6)+				; r6=right
	btst	#0,y:control_data				; Test if left..
	tcc	x0,b		r3,r6				; if left then r6:left, else r6:right
	jcs	_voix_droite
	bset	#0,y:move					; Indicate l used.
	jmp	_next
_voix_droite:
	bset	#1,y:move					; Indicate r used.

; Mix this voice and proceed to next..
_next:	move			#calc_freq_voice_move,r2
	move			#calc_freq_voice_add,r1
	btst	#1,y:control_data				; Test if voice is moved or added.
	tcs	x0,b		r2,r1				; if moved r1:moverout, else r1:addrout
	move			y:loop,n3			; n3=#samplewords to mix
	clr	b		y:vol_sample,y0			; y0=volume
	move			y:freq_sample,b0
	asl	b		#buffer_inter,r2		; b=freq, r2:splbuffer
	move			b1,x1
	move			b0,x0				; x=freq
	move			r2,a				; a1:splbuffer
	jsr	(r1)						; And mix it.
	jmp	_voiceloop

; All tracks done. If l/r unused -> clear
_end_mixing:
	jsr	copy_double_dest
	move			y:loop,b			; b=#samplewords mixed
	tst	b		b,n3				; n3=#samplewords mixed
	jeq	_clearing_done

; Store next buffer pointer..
	movec			m6,m3				; Set r3 to size_buffer modulo operation.
	move			r3,r2				; r2=ptr[n]
	move			(r3)+n3				; a=ptr[n]+loop
	move			(r3)+n3				; a=ptr[n+1]=ptr[n]+loop*2
	move					y:move,x0	; x0=y:move
	move			r3,y:ptr_buf			; Store ptr[n+1].

	jset	#0,x0,_no_clr_left_data
	clr	a		r2,r6				; r6: left
	do	b,_no_clr_left_data				; Clear left chan.
	move			a,x:(r6)+n6
_no_clr_left_data

	move			(r2)+
	jset	#1,x0,_no_clr_right_data
	clr	a		r2,r6				; r6: right
	do	b,_no_clr_right_data				; Clear right.
	move			a,x:(r6)+n6
_no_clr_right_data

_clearing_done:
	movep	#>$5800,x:<<CRB					; ssi on
	bset	#3,x:<<HCR
	jsr	restore_reg
	rti

; Swaps mixingloops with current program in internal p mem.
copy_double_dest:
	move			#mix_moved,r1			; r1:source
	move			#<11,a1				; a1=#words
	move			#<$40,r2			; r2:dest
	do	a1,_loop
	move	p:(r1),a
	movem	p:(r2),x0
	move	x0,p:(r1)+
	move	a,p:(r2)+
_loop:	rts

; Receive an 8b sample from host.
receive_sample:
	rhost	y:vol_sample					; Store volume.
	rhost	x0						; x0=frequency
	move			x0,y:freq_sample		; Store frequency.
	move			y:loop,x1			; x1: #spls to mix
	mpy	x0,x1,a		#buffer_inter,r1		; r1: start of buffer (even)
	whost	a						; a=#spls (bytes)
	lsr	a		#buffer_inter+1,r2		; a=#pairs, r2: start of buffer (odd)
	jeq	_loop_nothing					; if #pairs=0 -> end
	rhost	x0						; x0= cpu start address
	rhost	b						; b= negociated #pairs
	tst	b		#>$8000,x1			; x1=scalar
	jeq	_loop_nothing
	sub	b,a		b,y0				; a= size of empty tail /2, y0=#pairs
	jclr	#0,x0,_even_parity
	rhost	y:(r1)+						; Read and store 1st off spl.
	move			(r2)+
_even_parity:
	rhost	x0						; x0=first pair (xx<<16+spl[0]<<8+spl[1])
	mpy	x0,x1,a		a,y1				; a0=spl[1]<<16, a1=xx<<8+spl[0], y1=tailsize/2
	move			a1,x0				; x0=xx<<8+spl[0]
	mpy	x0,x1,b				a0,y:(r2)+n2	; b0=spl[0]<<16, Store spl[1]<<16.

	do	y0,_transloop					; n=2
	rhost	x0						; x0=spl[n]<<8+spl[n+1]
	mpy	x0,x1,a				b0,y:(r1)+n1	; a0=spl[n+1]<<16, a1=spl[n], Store spl[n-2]<<16.
	move			a1,x0				; x0=spl[n]
	mpy	x0,x1,b				a0,y:(r2)+n2	; b0=spl[n]<<16, Store spl[n+1]<<16.
_transloop:
	move					b0,y:(r1)+n1	; Store beforelast sample...

; Clear rest of buffer..
	clr	b		y1,a				; a=tailsize/2
	tst	a
	jeq	_empty_loop
	do	y1,_empty_loop					; Clear tailsize/2 pairs.
	move					b,y:(r1)+n1
	move					b,y:(r2)+n2
_empty_loop:

; n+1 (+1 odd) words read.
	rts

_loop_nothing
	clr	a
	move					a,y:(r1)
	rts

calc_freq_voice_move:
	add	x,a		y:(r2),y1			; y1=first source sample
	mpy	y1,y0,b		a,r2				; b=first mixed sample
	jmp	<$40						; mix_moved in internal p-ram

calc_freq_voice_add:
	add	x,a		x:(r6),b			; b=first chansample
	move			y:(r2),y1			; y1=first source sample
	mac	y1,y0,b		a,r2				; b=first mixed sample
	jmp	<$45						; mix_added in internal p-ram

;= mixing innerloops =======================================================
;
; These loops are relocated to internal p ram..
; So the loop addresses are adjusted to their relocated adrs.
;

; todo: remove testcity!

; this calculates 1 sample twice, but this bug was also in the org player.
mix_moved:
	do	n3,$44						; $40, 2
	add	x,a	 	b,x:(r6)+n6	y:(r2),y1	; $42, 1
	mpy	y1,y0,b		a,r2				; $43, 1
	rts							; $44, 1
								; $45
mix_added:
	do	n3,$4A						; $45, 2
	add	x,a		b,x:(r6)+n6			; $47, 1
	move			x:(r6),b	y:(r2),y1	; $48, 1
	mac	y1,y0,b		a,r2				; $49, 1
	rts							; $4A, 1
								; $4B

;= mixer housekeeping routines ==============================================
;

; Cut sound and return from interrupt.
coupe:	movep	#$0800,x:<<CRB					;SSI off
	jsr	restore_reg
	rti
 
init_buffer:
	clr	a		#buffer,r7			;init_addresse
	rep	#size_buffer
	move			a,x:(r7)+
	move			#buffer_inter,r6		;init_addresse
	rep	#1024
	move			a,y:(r6)+
	move			#buffer,r7			;init_addresse
	move			#buffer,r6			;init_addresse
	movec	#size_buffer-1,M7
	move			r6,y:ptr_buf
	rts

save_reg:
	andi	#%01010011,mr					;Virer: NO(scaling, trace, loop)
	move			r1,x:>sauve
	move			m1,x:>sauve+1
	movec	#-1,m1
	move			#>sauve+2,r1
	nop
	move			r6,x:(r1)+
	move			m6,x:(r1)+
	move			n6,x:(r1)+
	move			r2,x:(r1)+
	move			m2,x:(r1)+
	move			n2,x:(r1)+
	move			r3,x:(r1)+
	move			m3,x:(r1)+
	move			n3,x:(r1)+
	move			a2,x:(r1)+
	move			a1,x:(r1)+
	move			a0,x:(r1)+
	move			b2,x:(r1)+
	move			b1,x:(r1)+
	move			b0,x:(r1)+
	move			x0,x:(r1)+
	move			x1,x:(r1)+
	move			y0,x:(r1)+
	move			n1,x:(r1)+
	move			y1,x:(r1)+
	move			m4,x:(r1)+
	move			m5,x:(r1)+
	move			r0,x:(r1)+
	move			m0,x:(r1)+
	
	movec	m1,m2
	movec	m1,m3
	move			#>resend1,r1			;par NULLOS/DNT
	move			#'RSP',x0			;Identification du mixeur
	tfr	x0,a		x0,y0				;
	whost	x0						;On l'envoie au 030, les deux
_link	move			y0,y1				;tests ‚tant en quinconce.
	move			a,y0
	rhost	a						;Attendre celui donn‚ par le 030,
	cmp	x0,a						;en notant un ‚ventuel envoi Host
	jne	_link						;interrompu.
	whost	y0						;Echange avec le 030 ce que l'on
	whost	y1						;a intercept‚.
	rhost	y:(r1)+						;
	rhost	y:(r1)+						;
	rts
	
restore_reg:
	move			#'RSP',x0			;Remplir le port Host avec ce
	move			#>resend1,r1			;qu'il contenait au moment de

	do	#2,_loop
	move					y:(r1)+,a	;du 68030...
	cmp	x0,a
	jeq	_nosend

	whost	a						; test!
;	movep	a,x:<<HTX

_nosend	nop
_loop:
	move			#>sauve+2,r1
	nop
	move			x:(r1)+,r6
	move			x:(r1)+,m6
	move			x:(r1)+,n6
	move			x:(r1)+,r2
	move			x:(r1)+,m2
	move			x:(r1)+,n2
	move			x:(r1)+,r3
	move			x:(r1)+,m3
	move			x:(r1)+,n3
	move			x:(r1)+,a2
	move			x:(r1)+,a1
	move			x:(r1)+,a0
	move			x:(r1)+,b2
	move			x:(r1)+,b1
	move			x:(r1)+,b0
	move			x:(r1)+,x0
	move			x:(r1)+,x1
	move			x:(r1)+,y0
	move			x:(r1)+,n1
	move			x:(r1)+,y1
	move			x:(r1)+,m4
	move			x:(r1)+,m5
	move			x:(r1)+,r0
	move			x:(r1)+,m0
	
	move			x:>sauve,r1
	move			x:>sauve+1,m1
	rts

end_prog:

;= data ====================================================================

		org	X:$3000
buffer:		ds	size_buffer
sauve:		ds	30
end_x_mem:

		org	Y:$3C00-8
move:		ds	1
ptr_buf:	ds	1
control_data:	ds	1
resend1:	ds	2
vol_sample:	ds	1
freq_sample:	ds	1
loop:		ds	1
buffer_inter:	ds	1024	
end_y_mem:
