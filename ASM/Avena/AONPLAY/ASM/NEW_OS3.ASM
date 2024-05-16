;**********************************************
;*    Mini DSP Operating System (Dr-OSs??)    *
;*                                            *
;**********************************************
;* Version 1.0 (March 1994) Steven Tattersall *
;*   6 Derwent Drive, Littleborough, Lancs,   *
;*  OL15 0BT, England. (Other credits below)  *
;* Version 1.1 (June 95) + Tracker            *
;* Version 1.2 (July 95) + AonTracker         *
;**********************************************





;**********************************************
;* DSP Tracker (Non-SSI Output 24.5Khz)       *
;**********************************************

	include	'f:\dsp_new\asm\base.asm'

; ----------- Equates --------------
start		equ $40
huc1		equ 38
receive		equ 0
transmit	equ 1

	org	p:0
	jmp	start

	org	p:huc1
	jsr	player

	org	p:start
	movec	#0,sr			; kill loop and trace
	movep	#>0,x:<<$fffe		; BCR port B bus control
	movep	#$c00,x:<<$ffff		;     interrupt priority
	movep	#>1,x:<<$ffe0		; PBC port B control
	movep	#>4,x:<<$ffe8		;     host control
	andi	#$fc,mr			; allow all interrupts
	movec	#%10000010,omr		; allow ext. mem access,
					; no data rom, normal expanded.
	nop
	jsr	init_tracker		; go
	bset	#2,x:<<HCR		; allow ext. interrupt trigger


;--------------------------------------------------------------
; The problem seems to be extraneous data left in the host
; - Use the user-defined bits to allow transmission?
main_loop:
	 wait_receive
	movep	x:<<hrx,x0		; memory type/command
	move	#"RUN",a
	cmp	x0,a
	jeq	run_routine
	move	#"ROU",a
	cmp	x0,a
	jeq	fetch_loop		; "carry on, George!"
	jmp	main_loop


    ;---------- Routine reception section :)
fetch_loop:
	wait_receive
	movep	x:<<hrx,x0		; get memory type
	move	#"MEP",a
	cmp	x0,a
	jeq	p_memory
	move	#"MEX",a
	cmp	x0,a
	jeq	x_memory
	move	#"MEY",a
	cmp	x0,a
	jeq	y_memory
	move	#"END",a
	cmp	x0,a
	jeq	main_loop		;failed, assume done
	jmp	fetch_loop

;----------------------------------------
y_memory
	jsr	get_count
	do	n0,_loop
	  wait_receive
	  movep	x:<<hrx,y:(r0)+
_loop
	jmp	fetch_loop

p_memory
	jsr	get_count
	do	n0,_loop
	  wait_receive
	  movep	x:<<hrx,p:(r0)+
_loop
	jmp	fetch_loop

x_memory
	jsr	get_count
	do	n0,_loop
	  wait_receive
	  movep	x:<<hrx,x:(r0)+
_loop
	jmp	fetch_loop

;----------------------------------------
run_routine:
	 wait_receive
	movep	x:<<hrx,r0		; memory address
	nop
	jsr	(r0)
	jmp	main_loop

get_count:
	 wait_receive
	movep	x:<<hrx,r0		; address
	 wait_receive
	movep	x:<<hrx,n0		; counter
	rts






;----------------------------------------------------------------




;			T R A C K E R




;----------------------------------------------------------------

buffer_length		equ 25500/50			;max
temp_length		equ 600

init_tracker:
	move	#left_buffer,r0
	move	#buffer_length*2,n0
	clr	b			; pipeline error!!
	rep	n0			; clear the buffer
	 move	b1,x:(r0)+

	move	#>v1_data,r0
	rep	#6*4
	 move	b1,x:(r0)+

	move	#temp_buffer,r0
	rep	#temp_length
	 move	b1,x:(r0)+

; Allow vector commands:

	move	#"OK!",x0
	wait_transmit
	movep	x0,x:<<htx
	rts

;---------------------------------------------------------------------
player:
; OK, save the registers:
	;jmp	skip_player
	move	r0,x:save_r0
	move	#save_regs,r0
	andi	#<$f0,mr		;INTERRUPT LEVEL?
	nop
	move	a2,x:(r0)+
	move	a1,x:(r0)+
	move	a0,x:(r0)+
	move	b2,x:(r0)+
	move	b1,x:(r0)+
	move	b0,x:(r0)+

	move	x1,x:(r0)+
	move	x0,x:(r0)+
	move	y1,x:(r0)+
	move	y0,x:(r0)+

	move	r1,x:(r0)+
	move	r2,x:(r0)+
	move	r3,x:(r0)+
	move	r4,x:(r0)+
	move	r5,x:(r0)+
	move	r6,x:(r0)+
	move	r7,x:(r0)+

	move	n0,x:(r0)+
	move	n1,x:(r0)+
	move	n2,x:(r0)+
	move	n3,x:(r0)+
	move	n4,x:(r0)+
	move	n5,x:(r0)+
	move	n6,x:(r0)+
	move	n7,x:(r0)+

	;move	m0,x:(r0)+
	move	m1,x:(r0)+
	move	m2,x:(r0)+
	move	m3,x:(r0)+
	move	m4,x:(r0)+
	move	m5,x:(r0)+
	move	m6,x:(r0)+
	move	m7,x:(r0)+

	jsr	Save_Host_Internals

	move	#"TAT",x0
	 wait_transmit
	movep	x0,x:<<htx		;'dummy' value.

	 wait_receive
	movep	x:<<hrx,x0
	move	x0,x:frame
	movec	#-1,m0
	movec	#-1,m1
	movec	#-1,m2
	movec	#-1,m3
	movec	#-1,m4
	movec	#-1,m5
	movec	#-1,m6
	movec	#-1,m7
	move	#v1_data,r0
	jsr		receive_data
	move	#v1_data,r0
	move	#left_buffer,r1
	jsr		write_data

	move	#v2_data,r0
	jsr		receive_data
	move	#v2_data,r0
	move	#right_buffer,r1
	jsr		write_data

	move	#v3_data,r0
	jsr		receive_data
	move	#v3_data,r0
	move	#right_buffer,r1
	jsr		add_data

	move	#v4_data,r0
	jsr		receive_data
	move	#v4_data,r0
	move	#left_buffer,r1
	jsr		add_data

	jsr		return_data
;	move	#"TOK",x0
;		wait_transmit
;	movep	x0,x:<<htx		;'dummy'	value.
;		wait_transmit
;	movep	x:<<hrx,x0

	jsr	Restore_Host_Internals

	move	#save_regs,r0
	nop
	move	x:(r0)+,a2
	move	x:(r0)+,a1
	move	x:(r0)+,a0

	move	x:(r0)+,b2
	move	x:(r0)+,b1
	move	x:(r0)+,b0

	move	x:(r0)+,x1
	move	x:(r0)+,x0
	move	x:(r0)+,y1
	move	x:(r0)+,y0

	move	x:(r0)+,r1
	move	x:(r0)+,r2
	move	x:(r0)+,r3
	move	x:(r0)+,r4
	move	x:(r0)+,r5
	move	x:(r0)+,r6
	move	x:(r0)+,r7

	move	x:(r0)+,n0
	move	x:(r0)+,n1
	move	x:(r0)+,n2
	move	x:(r0)+,n3
	move	x:(r0)+,n4
	move	x:(r0)+,n5
	move	x:(r0)+,n6
	move	x:(r0)+,n7

	;move	x:(r0)+,m0
	move	x:(r0)+,m1
	move	x:(r0)+,m2
	move	x:(r0)+,m3
	move	x:(r0)+,m4
	move	x:(r0)+,m5
	move	x:(r0)+,m6
	move	x:(r0)+,m7
	move	x:save_r0,r0
skip_player:
	rti

;----------- Mixing section ---------------------
; r0 = volume data etc.
; r1 = sample buffer (in x memory!)

write_data:
	jsr	setup_regs
	do n0,_write_loop
	  add	x,b		x:(r2),y1
	  mpyr	y0,y1,a		b1,r2
	  move	a1,x:(r1)+
_write_loop:
	jsr	restore_regs
	rts

add_data:
	jsr	setup_regs
	do n0,_add_loop
	  move	x:(r2),y1
	  add	x,b 		x:(r1),a
	  macr	y0,y1,a		b1,r2
	  move	a1,x:(r1)+
_add_loop:
	jsr	restore_regs
	rts











setup_regs:
	move	r0,r3
	move	(r0)+		; ignore wholejump for minute
	clr	a
	move	x:(r0)+,y0	; y0 volume multiplier
	move	x:(r0)+,a0	; a is fraction-add
	asl	a
	asl	a

	move	a1,x1
	move	a0,x0		; x0/x1 now frac add
	move	#temp_buffer,b	; present whole
	move	x:(r0)+,y1	; old whole part
	add	y1,b		; offset it
	move	x:(r0),b0	; present fraction
	move	b1,r2		; for the 1st 'iteration'
	move	x:frame,n0
	jne	_a_1
	move	#>1,n0
_a_1	rts


restore_regs:
	move	b0,x:(r0)-	; save fraction for next time
	move	r2,b1		; how far have we
	move	#temp_buffer,x0 ; moved from
	sub	x0,b		; last time?
	move	b1,x:(r3)	; save wholejump
	move	#>1,x1
	and	x1,b
	move	b1,x:(r0)	; save old whole
	rts




; ------------ Data returning -------------
; NOTE: the sample is already signed (lowest $8000 highest $7fff)

; Convert to 2 bytes from 2 words....

return_data:
	move	#left_buffer,r0
	move	#right_buffer,r1
	move	x:frame,n0
	move	#>$ff0000,x0
	move	#>$80,x1			;multiplier2
	move	x:(r0)+,a
	move	#htx,r2

	do	n0,return_loop
	  and	x0,a		#>$8000,x0
	  move	x:(r0)+,a	a,y0
	  mpy	x0,y0,b		x:(r1)+,y1
	  mac	y1,x1,b		#>$ff0000,x0
	   wait_transmit
	  move	b,x:(r2)
return_loop
	rts


;---------------------------------------------------------------------
receive_data:
	 wait_transmit
	move	x:(r0)+,x1		; wholejump
	movep	x1,x:<<htx

	 wait_receive
	movep	x:<<htx,x1
	move	x1,x:(r0)+		;save volume

	 wait_receive
	movep	x:<<htx,x1
	move	x1,x:(r0)+		;save increment

	move	x:frame,x0
	mpy	x1,x0,b			;result in b (56-bit)
	asl	b
	asl	b
	move	(r0)+			;old whole
	move	(r0)+			;fraction (ignored)

	 wait_transmit
	movep	b1,x:<<htx		;send blocks to do * increment -> BLOCSIZE

	 wait_receive
	movep	x:<<hrx,x0		;receive 16bit chunks to send
	move	x0,x:(r0)+
	move	x0,r5

	move	#temp_buffer,r1
	move	#temp_buffer+1,r2
	move	#>2,n1
	move	#>2,n2
	move	#>$8000,y1		;first multiplier
	move	#>$ff,x1		;mask for accidental garbage

; Optimisation anyone?
	do r5,_receive_loop
	  wait_receive
	  movep	x:<<hrx,y0			;y0 - 00aabb
	  mpy	y1,y0,a				; a - aa bb0000
	  and	x1,a1		a0,x:(r2)+n2
	  move	a1,x0
	  mpy	y1,x0,b
	  move	b0,x:(r1)+n1
_receive_loop:
	rts

	include	'f:\dsp_new\asm\protect.asm'

			org	x:($3f00-buffer_length*2-temp_length)

Saved_Host_Data_1:
				ds	10
Saved_Host_Data_2:
				ds	10
v1_data:
v1_wholejump	ds 1
v1_volume		ds 1
v1_increment	ds 1
v1_whole		ds 1
v1_fraction		ds 1
v1_blocks		ds 1

v2_data:
v2_wholejump	ds 1
v2_volume		ds 1
v2_increment	ds 1
v2_whole		ds 1
v2_fraction		ds 1
v2_blocks		ds 1

v3_data:
v3_wholejump	ds 1
v3_volume		ds 1
v3_increment	ds 1
v3_whole		ds 1
v3_fraction		ds 1
v3_blocks		ds 1

v4_data:
v4_wholejump	ds 1
v4_volume		ds 1
v4_increment	ds 1
v4_whole		ds 1
v4_fraction		ds 1
v4_blocks		ds 1

frame			ds 1

; This takes us to..... about x:29
save_r0			ds 1
save_m0			ds 1
save_regs		ds 33

;------------------------------------------------
left_buffer		ds	buffer_length
right_buffer	ds	buffer_length
temp_buffer		ds	temp_length
