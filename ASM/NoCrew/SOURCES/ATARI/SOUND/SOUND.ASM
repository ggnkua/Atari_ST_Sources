; DSP 56001 SSI/Host
; DSP Audio program
; Author: Fredrik Noring

; I/O Port Programming
M_BCR   EQU     $FFFE           ; Port A Bus Control Register
M_PBC   EQU     $FFE0           ; Port B Control Register
M_PBDDR EQU     $FFE2           ; Port B Data Direction Register
M_PBD   EQU     $FFE4           ; Port B Data Register
M_PCC   EQU     $FFE1           ; Port C Control Register
M_PCDDR EQU     $FFE3           ; Port C Data Direction Register
M_PCD   EQU     $FFE5           ; Port C Data Register

; Host Interface
M_HCR   EQU     $FFE8           ; Host Control Register
M_HSR   EQU     $FFE9           ; Host Status Register
M_HRX   EQU     $FFEB           ; Host Receive Data Register
M_HTX   EQU     $FFEB           ; Host Transmit Data Register

; SSI, Synchronous Serial Interface
M_RX    EQU     $FFEF           ; Serial Receive Data Register
M_TX    EQU     $FFEF           ; Serial Transmit Data Register
M_CRA   EQU     $FFEC           ; SSI Control Register A
M_CRB   EQU     $FFED           ; SSI Control Register B
M_SR    EQU     $FFEE           ; SSI Status Register
M_TSR   EQU     $FFEE           ; SSI Time Slot Register

; Exception Processing
M_IPR   EQU     $FFFF           ; Interrupt Priority Register

	org x:$0
commands
volume_l	dc	$07ff00		; 0 volume left
volume_r	dc	$07ff00		; 1 volume right
flag_mono	dc	$000000		; 2 mono on/off
flag_karaoke	dc	$000000		; 3 karaoke on/off
flag_flange	dc	$000000		; 4 flange on/off
		ds	10
echo_read	dc	echo_buf
echo_mix1	dc	0.3
echo_mix2	dc	0.26

flange_delay	dc	1
flange_step	dc	1
flange_delta	dc	0.005116623	; 512 / 50033
flange_read	dc	flange_buf
flange_mix1	dc	0.6
flange_mix2	dc	0.6

in_l		dc	1
in_r		dc	1
tmp_l		dc	1
tmp_r		dc	1
out_l		dc	1
out_r		dc	1
temp		dc	1
temp1		dc	1
inflag		dc	1
outflag		dc	1
sync		dc	0

host_sync	dc	0
host_read	dc	0

	org	X:4096
echo_buf	ds	4096
pitchA		ds	1024
pitchB		ds	1024
flange_buf	ds	512
	org	Y:4096
		ds	4096
		ds	1024
		ds	1024
		ds	512

	org	P:$0
	jmp	start

	org p:$000c
	jsr datain

	org p:$0010
	jsr dataout

	org p:$40
start	movec	#<0,SP
	movep	X:<<M_HRX,x0
	movep	#$0,X:<<M_BCR
	movep	#$1,X:<<M_PBC
	movep	#$0000,X:<<M_PCC
	movep	#$01F8,X:<<M_PCC
	movep	#$4100,X:<<M_CRA
	movep	#$F800,X:<<M_CRB
	btst	#4,X:<<M_SR
	movep	#$3000,X:<<M_IPR
	andi	#<$FC,MR

	bclr	#0,X:>host_sync
main	jclr	#0,X:<host_sync,not	; Send value to host?
	jclr	#1,X:<<M_HSR,not
	move	X:<host_read,x0
	movep	x0,X:<<M_HTX
	bclr	#0,X:<host_sync
not	jclr	#0,X:<sync,main

	move	X:<in_l,x0
	move	X:<volume_l,x1
	mpy	x0,x1,A
	lsl	A
	lsl	A
	lsl	A
	lsl	A
	move	A,X:<tmp_l

	move	X:<in_r,x0
	move	X:<volume_r,x1
	mpy	x0,x1,A
	lsl	A
	lsl	A
	lsl	A
	lsl	A
	move	A,X:<tmp_r

	jsset	#23,X:<flag_karaoke,karaoke
	jsset	#23,X:<flag_mono,mono
;	jsr	echo
	jsset	#23,X:<flag_flange,flange
	jsr	pitch

	move	X:<tmp_r,x0
	move	X:<tmp_l,x1
	move	x0,X:<out_l
	move	x1,X:<out_r
	bclr	#0,X:<sync

	jsset	#0,X:<<M_HSR,host_command
	jmp	<main

host_command
;	bit	meaning
;	0-6	command # (offset address)
;	7	0=read, 1=write
;	8-23	data (16 bit)
	movep	X:<<M_HRX,x0
	move	#>$7f,A
	and	x0,A
	move	A1,r0
	jset	#7,x0,write
read	bset	#0,X:<host_sync
	move	X:(r0),x0
	move	x0,X:<host_read
	rts
write	move	#>$ffff00,A
	and	x0,A
	move	A1,X:(r0)
	rts

; Interrupts
datain	MOVE	X0,X:<temp
	MOVE	X1,X:<temp1
	JCLR	#0,X:<inflag,>do_leftin
do_rightin
	MOVEP	X:<<M_RX,X1
	MOVE	X1,X:<in_r
	BCLR	#0,X:<inflag
	MOVE	X:<temp,X0
	MOVE	X:<temp1,X1
	RTI
do_leftin
	MOVEP	X:<<M_RX,X0
	MOVE	X0,X:<in_l
	BSET	#0,X:<inflag
	MOVE	X:<temp,X0
	MOVE	X:<temp1,X1
	BSET	#0,X:<sync
	RTI

dataout	MOVE	X0,X:<temp
	MOVE	X1,X:<temp1
	JCLR	#0,X:<outflag,>do_leftout
do_rightout
	MOVE	X:<out_r,X1
	MOVEP	X1,X:<<M_RX
	BCLR	#0,X:<outflag
	MOVE	X:<temp,X0
	MOVE	X:<temp1,X1
	RTI
do_leftout
	MOVE	X:<out_l,X0
	MOVEP	X0,X:<<M_RX
	BSET	#0,X:<outflag
	MOVE	X:<temp,X0
	MOVE	X:<temp1,X1
	rti

karaoke	move	X:<tmp_l,x0
	move	X:<tmp_r,A
	sub	x0,A
	move	A,X:<tmp_l
	move	A,X:<tmp_r
	rts

mono	move	#0.5,x0
	move	X:<tmp_l,x1
	mpyr	x0,x1,A
	move	X:<tmp_r,x1
	macr	x0,x1,A
	move	A,X:<tmp_l
	move	A,X:<tmp_r
	rts

echo	move	#1,n0
	move	#8192,m0
	move	X:<echo_read,r0
	move	X:<echo_mix2,x0
	move	X:(r0),y0
	move	Y:(r0)+,y1
	move	X:<tmp_l,A
	move	X:<tmp_r,B
	macr	x0,y0,A
	macr	x0,y1,B
	move	r0,X:<echo_read
	lua	(r0)-n0,r0
	move	A,X:<tmp_l
	move	B,X:<tmp_r

	move	X:<echo_mix1,x0
	move	X:<tmp_l,A
	move	X:<tmp_r,B
	macr	x0,y0,A
	macr	x0,y1,B
	move	A,X:(r0)
	move	B,Y:(r0)
	move	#-1,m0
	rts

flange	move	#512,m0
	move	X:<flange_read,r0
	move	X:<flange_mix1,x0
	move	#0.9999999,B
	sub	x0,B
	move	B,x1
	move	X:<tmp_l,y0
	move	X:<tmp_r,y1
	mpyr	x1,y0,A
	mpyr	x1,y1,B
	move	X:(r0),y0
	move	Y:(r0)+,y1
	macr	x0,y0,A
	macr	x0,y1,B
	move	A,X:(r0)
	move	B,Y:(r0)
	move	r0,X:<flange_read

	move	X:<flange_delay,x0
	move	X:<flange_delta,x1
	mpy	x0,x1,A (r0)-
	asr	A
	move	A1,n0
	move	A0,x0
	nop
	nop
	nop
	nop
	lua	(r0)-n0,r0
	nop
	nop
	nop
	move	X:(r0),y0
	move	Y:(r0),y1
	move	X:-(r0),A
	move	Y:(r0)+,B
	sub	y0,A
	sub	y1,B
	move	A,y0
	move	B,y1
	mpyr	y0,x0,A
	mpyr	y1,x0,B
	asr	A
	asr	B
	move	X:(r0),y0
	move	Y:(r0),y1
	add	y0,A
	add	y1,B
	move	A,y0
	move	B,y1
	move	X:<flange_mix2,x0
	move	#0.9999999,B
	sub	x0,B
	move	B,x1
	mpyr	x0,y0,A
	mpyr	x0,y1,B
	move	X:<tmp_l,y0
	move	X:<tmp_r,y1
	macr	x1,y0,A
	macr	x1,y1,B
	move	A,X:<tmp_l
	move	B,X:<tmp_r

	move	X:<flange_step,x0
	move	X:<flange_delay,A
	move	#>$18000,B	; 2*50033
	jset	#7,A2,flange_swap
	cmp	A,B
	jgt	flange_ok1
flange_swap
	move	x0,B
	neg	B
	move	B,X:<flange_step
	move	B,x0
flange_ok1
	add	x0,A
	move	A,X:<flange_delay
	move	#-1,m0
	rts

pitch	rts

	end



