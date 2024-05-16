;**********************************************
;* DSP Tracker (SSI Output 49Khz)             *
;*                                            *
;* Update for 4-8 Tracks Jun '95              *
;* Bug fixing, "unlimited" tracks Aug 96      *
;**********************************************
;*  Version 2.2 (Aug 1996) Steven Tattersall  *
;*   6 Derwent Drive, Littleborough, Lancs,   *
;*  OL15 0BT, England. (Other credits below)  *
;**********************************************

CRA	equ	$ffec	;SSI Control Register A
CRB	equ	$ffed	;SSI Control Register B
SSISR	equ	$ffee	;SSI Status Register
SSITSR	equ	$ffee	;SSI Time Slot Register
RX	equ	$ffef	;SSI Serial Receive data/shift register
TX	equ	$ffef	;SSI Serial Transmit data/shift register
SCR	equ	$fff0	;SCI Control Register
SSR	equ	$fff1	;SCI Status Register
SCCR	equ	$fff2	;SCI Clock Control Register
STXA	equ	$fff3	;SCI Transmit data Address Register
SRX	equ	$fff4	;SCI Receive data register (4-5-6)
STX	equ	$fff4	;SCI Transmit data register (4-5-6)
IPR	equ	$ffff	;Interrupt Priority Register

	include	'd:\dsp\asm\base.asm'

receive	equ	0
transmit equ	1

maxtracks	equ 8

; Assume non-cia timing.
; At 49Khz, buffer size will be 2*(49170/50) words, or 1967
; Let's make it 4Kwords in size

buffer_length	equ 4096		;remember, stereo...
temp_length	equ 1000		;theoretically up to 2195!
huc1		equ 38

start		equ $40

	org 	p:0
	jmp 	start

	org	p:16
	movep	y:(r7)+,x:<<RX

	org	p:start
	ori	#$03,mr			; interrupts?
	movec	#0,sr
	movep	#>0,x:<<$fffe		; port B bus control
	movep	#$c00,x:<<$ffff		; interrupt priority
	movep	#>1,x:<<$ffe0		; port B control
	movep	#>4,x:<<$ffe8		; host control
	andi	#$00,omr		; operating mode

	move	#output_buffer,r5	; Starts at x:$1000
	move	#output_buffer,r6
	move	#output_buffer,r7
	movec	#buffer_length-1,m5
	movec	#buffer_length-1,m6
	movec	#buffer_length-1,m7

	clr	b
	move	#buffer_length,n0
	rep	n0			; clear the buffer
	move	b1,y:(r6)+

	move	#>v1_data,r0
	rep	#totalsize*maxtracks	; clear rubbish out of
	move	b1,x:(r0)+		; voice registers

	move	#receive_buffer,r0
	do	#maxtracks,clear_buf4
	rep	#temp_length
	move	b1,y:(r0)+
clear_buf3:
	nop
clear_buf4:
	jsr	initialize_ssi

; Allow vector commands:
	bset	#2,x:<<HCR
; Send 'INI'
	move	#"INI",x0
	 wait_transmit
	movep	x0,x:<<htx

;---------------------------------------------------------------------
tracker_loop:
; OK, save the registers:
	andi	#<$f0,mr

	move	#"tra",x0
_wait_for_init
	 wait_receive
	movep	x:<<hrx,a
	cmp	x0,a
	jne	_wait_for_init

	move	x:blocks_to_do,x0
	 wait_transmit
	movep	x0,x:<<htx		;'dummy' value.

wait_r7	move	r7,a
	jset	#0,a1,wait_r7		;wait for even val


; We continue to fill r6
; Current play position is r7
; We fill up to r7....
	move	r6,x0
	sub	x0,a
	jpl	noadd
	move	#buffer_length,x1
	add	x1,a
noadd
	asr	a			;two words due to stereo...
	move	a,x:blocks_to_do

	 wait_receive
	movep	x:<<hrx,x0
	move	x0,x:track_count	;how many tracks

	move	#receive_buffer,r1
	move	#v1_data,r0
	move	x:track_count,n6
	do	n6,_receive_loop
	  move	r0,x:save_pos
	   jsr	receive_data
	  move	x:save_pos,r0
	  move	#totalsize,n0
	  nop
	  lua	(r0)+n0,r0
_receive_loop:

	move	#v1_data,r0
	move	#conv_and_move,r1
	move	x:track_count,n6

	do	n6,_mix_loop
	  move	r0,x:save_pos
	   jsr	(r1)
	  move	x:save_pos,r0
	  move	#totalsize,n0
	  move	#conv_and_add,r1
	  lua	(r0)+n0,r0
_mix_loop:

	move	r5,r6
	jmp	tracker_loop


; ------------ Data reception -------------
receive_data:
; First of all, send last time's jump:
	 wait_transmit
	move	x:(r0)+,x1		; wholejump
	movep	x1,x:<<htx

; volume:
	 wait_receive
	movep	x:<<htx,x1
	move	x1,x:(r0)+		;save volume

	 wait_receive
	movep	x:<<htx,x1
	move	x1,x:(r0)+		;save volume2

	 wait_receive
	movep	x:<<htx,x1
	move	x1,x:(r0)+		;save period

	move	x:blocks_to_do,x0
	mpy	x1,x0,b			;result in b (56-bit)
	asl	b

	 wait_receive
	movep	x:<<htx,a
	tst	a
	jeq	_skip_old

	clr	a
	move	a,x:(r0)+		;kill old whole
	move	a,x:(r0)+		; and fraction
	jmp	_done_old
_skip_old:
	move	(r0)+			;old whole
	move	(r0)+			;fraction (ignored)
_done_old:
	 wait_transmit
	movep	b1,x:<<htx		;send blocks to do * increment -> BLOCSIZE

	 wait_receive
	movep	x:<<hrx,x0		;receive 16bit chunks to send
	move	x0,x:(r0)+

	move	r1,x:(r0)+		;store pos of sampledata
	do	x0,receive_loop
	  wait_receive
	  movep	x:<<hrx,x0
	  move	x0,p:(r1)+
receive_loop:
	rts

;----------- Mixing section ---------------------
; r0 = volume data etc.
; r1 = sample buffer
; x0 = offset within output_buffer


conv_and_move:
	jsr	convert_buffer
	jsr	init_regs

	do	n0,write_loop
	  move	x:(r2),y1
	  add	x,b	    x:(r4)+,y0
	  mpy	y0,y1,a	    b1,r2  	; volumize, transfer to addr reg
	  move	x:(r4)-,y0
	  mpy	y0,y1,a     a1,y:(r5)+	; volumize, transfer to addr reg
	  move	a1,y:(r5)+
write_loop:
	jmp	end_regs

;-------------------------------
conv_and_add:
	jsr	convert_buffer
	jsr	init_regs

	do	n0,add_loop
	  move	x:(r2),y1
	  move	y:(r5),a
	  add	x,b	    x:(r4)+,y0	; whole.fractional add
	  mac	y0,y1,a	    x:(r4)-,y0	; volumize, transfer to addr reg
	  move  a1,y:(r5)+
	  move	y:(r5),a
	  mac	y0,y1,a	    b1,r2	; volumize, transfer to addr reg
	  move	a1,y:(r5)+
add_loop:


end_regs:
	move	b0,x:(r0)-	; save fraction for next time
	move	r2,b1		; how far have we
	move	#conv_buffer,x0 ; moved from
	sub	x0,b		; last time?
	move	b1,x:(r3)	; save wholejump

	move	#>1,x1
	and	x1,b
	move	b1,x:(r0)	; save old whole
	rts

;------------------------------------------------
init_regs:
	move	r0,r3
	move	(r0)+		; ignore wholejump for minute
	nop

	move	r0,r4
	move	(r0)+		; y0 volume multiplier
	clr	a	(r0)+

	move	x:(r0)+,a0	; a is fraction-add
	asl	a
	clr	b	a1,x1
	move	a0,x0		; x0/x1 now frac add
	move	#conv_buffer,b1 ; present whole
	move	x:(r0)+,y1	; old whole part
	add	y1,b	  r6,r5	; offset it, set dest. buffer
	move	x:(r0),b0	; present fraction
	move	b1,r2
	move	x:blocks_to_do,n0
	jne	_a_2
	move	#>1,n0
_a_2:	rts











;------------------------------------------------
convert_buffer:
	move	#blocks,n0
	move	#>$8000,y1		; first multiplier
	move	x:(r0+n0),n1		; number of blocks to 'decode'
	move	#samplepos,n0
	move	#conv_buffer,r2		; in x mem!
	move	x:(r0+n0),r1

	move	#conv_buffer,r2
	move	#conv_buffer+1,r3
	move	#>2,n2
	move	#>2,n3
	move	#>$ff,x1		;mask for accidental garbage

; Optimisation anyone?
	do n1,_decode_loop
	  move	y:(r1)+,y0			;y0 - 00aabb
	  mpy	y1,y0,a				; a - aa bb0000
	  and	x1,a1		a0,x:(r3)+n3
	  move	a1,x0
	  mpy	y1,x0,b
	  move	b0,x:(r2)+n2
_decode_loop:
	rts

;------------------------------------------------
initialize_ssi
; Set up IO/ SSI registers
	movep	#$3c00,x:<<IPR		; Control Reg A
	movep	#$4100,x:<<CRA		; Control Reg B
	movep	#$5800,x:<<CRB		; Port C control
	movep	#$1f8,x:<<PCC		; Port C Data Direction
	movep	#>0,x:<<PCDDR
	andi	#$fc,mr
	rts

;------------------------------------------------
; Data Offsets:
wholejump	equ 0
volume1		equ 1
volume2		equ 2
increment	equ 3
whole		equ 4
fraction	equ 5
blocks		equ 6
samplepos	equ 7

totalsize	equ 8

;------------------------------------------------
;	x memory
;------------------------------------------------

	org	x:$3ff0-(totalsize-maxtracks)-3-(temp_length*2)

v1_data		ds	totalsize*maxtracks
save_pos	ds	1
blocks_to_do	ds	1
track_count	ds	1

;------------------------------------------------
conv_buffer	ds	temp_length*2




;------------------------------------------------
;	y memory
;------------------------------------------------
		org	y:$0000
output_buffer	dsm	buffer_length		;allows buffers of
						;any size to wrap
						;without error
output_start	equ	output_buffer


;------------------------------------------------
;	p/y memory
;------------------------------------------------
		org	p:buffer_length+20
receive_buffer:



