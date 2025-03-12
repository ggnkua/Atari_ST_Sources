;----------------------------------------------------------------------
; DSP 4 channel Player.
; 56001 source. (very fast)
; By Martin Griffiths, August 1993
; uses $6000-$8000 in both X and Y memory...
;----------------------------------------------------------------------

host_receive	macro dest
_wait 		jclr    #0,X:HSR,_wait     
		movep	x:HRX,dest
		endm

host_send	macro source
_wait 		jclr    #1,X:HSR,_wait     
		movep	source,x:HRX
		endm

no_channels	equ	32

IPR		EQU	$FFFF
BCR		EQU	$FFFE
PBC		EQU	$FFE0
PCC		EQU	$FFE1
PCDDR		EQU	$FFE3		; Port C data direction
PCD		EQU	$FFE5		; Port C data register
RX		EQU	$FFEF
TX		EQU	$FFEF
CRA		EQU	$FFEC
CRB		EQU	$FFED
HCR		EQU	$FFE8		; host command register
HSR		EQU	$FFE9		; host status register
HRX		EQU	$FFEB
HTX		EQU	$FFEB

; Voice Structure.

stereo_offset	equ 0
frequency       equ 1   ; frequency fraction for voice. (24bit fraction) 
curr_fraction   equ 2   ; current fraction part. 
last_sample	equ 3   ; 
			; 


cbufsize	EQU $1000
bufsize		EQU $f80

; Sample buffer X: memory address for each voice.

		org x:$0
chn1buf		ds bufsize
vc1_data	ds 4*no_channels


; Circular buffer for dac output in Y: memory.

		org y:$1000
circbuf 	ds cbufsize

	org	p:$0
	jmp	start			; -> start

; DAC xmit FAST interrupt.

	org	p:$10			; ssi transmit data
xmit_int
	movep	y:(r7)+,x:RX		; output sample word

; Music routine, host command 2.

	org	p:$26
	jsr	musicplayer_int		; host command 2
	
	org	p:$40
start	movep	#0,x:BCR
	movep	#1,x:PBC
	jmp	setup_player

; Add a voice to the buffer (interpolate)
; r0 -> sample buffer to apply volume and frequency shift too.
; r1 -> voice structure for this voice
; n2 -> no. of sample words to do.
; r6 -> fill place

add_voice_int
	clr	b	l:(r1)+,x 	; frequency fraction
	move	x0,a1
	move	#>$fffffe,y1
	and	y1,a	
	move	a1,x0
	move	r0,b1 	
	clr	a	x:(r1),b0	; current fraction
	do	n2,end_li
	add	x,b		b0,a1
	lsr	a		x:(r0),y1
	move	x:(r0)+,a	a,y0		
	mac	-y0,y1,a	x:(r0),y1
	mac	y0,y1,a		y:(r6),y1
	add	y1,a		b1,r0
	clr	a		a,y:(r6)+n6	
end_li
	move	b0,x:(r1)	; store current fraction
	rts

; Add a voice to the buffer (NO interpolation)
; r0 -> sample buffer to apply volume and frequency shift too.
; r1 -> voice structure for this voice
; n2 -> no. of sample words to do.
; r6 -> fill place

add_voice_ni
	clr	b	l:(r1)+,x 	; frequency int/fraction
	clr	a	x:(r1)+,b0	
	move	r0,b1 	
	do	n2,end_lni
	add	x,b	x:(r0),a	y:(r6),y1	
	add	y1,a	b1,r0
	move	a,y:(r6)+n6	
end_lni
	move	x:(r0),a		
	move	a,x:(r1)-		; store "last sample"
	move	b0,x:(r1)		; store current fraction
	rts

; The music player interrupt

musicplayer_int
	andi	#$f0,mr		; unmask interrupts
	bset	#3,x:HCR
	bset	#4,x:HCR

	host_receive a

	move	#>add_voice_ni,r2	; r2 -> non-interpolated add voice
	move	#>add_voice_int,r3	; r3 -> interpolated add voice
	tst	a			; 0  = no interpolation
	tne	x1,a	r3,r2		; >0 = interpolation
	host_receive a1			; fetch no of voices.
	move	a1,n1
waite	move	r7,b			; current pos in circular buffer
	jset	#0,b1,waite		;
	move	r6,x0			; last position in buffer 
	sub	x0,b			; difference 
	jpl	ok
	move	#cbufsize,x0
	add 	x0,b	
ok	asr	b	r6,r5		; /2 , R5=r6 (-> fill start)
	move	b1,n2			; store no of samples to do.

clrbuf	clr	a	
	do	n2,end_clearlp
	move	a,y:(r6)+
	move	a,y:(r6)+
end_clearlp
	move	r6,n3

; Fetch channels

	move	#>vc1_data,r4
	move	#>4,n4

	do	n1,getchnlp
waitf	jclr	#0,x:HSR,waitf		
	movep	x:HRX,a			 
	tst	a
	jeq	nextvoice
	move	r4,r1
	clr	a	#>chn1buf,r0	;
	host_receive x:(r1)+
	host_receive a1
	host_receive a0
	host_receive y1			; receive volume
	move	a,l:(r1)+		; store fraction part
	move	a1,y0			; whole part
	move	a0,a1
	lsr	a	n2,x0		; no. of samples to do = curr fracrtion +
	clr	b	a1,x1
	mpy	y0,x0,a	x:(r1)+,b0	; current fraction
	asr	a
	move	a0,b1
	mac	x1,x0,b	#>$80,y0	; frequency fraction * no. of samples to do.
	host_send b1			; send amount of sample words to send.
	move	x:(r1),a
	move	a,x:(r0)+
	do	b1,end_gc		; - for x no. of samples
	host_receive x1
	mpy     y0,x1,a  
	move	a0,x1
	mpy	y1,x1,a	
	move	a,x:(r0)+	; store "last sample"
end_gc	
	move	a,x:(r1)
	host_receive x1
	mpy     y0,x1,a   

	move	a0,x1
	mpy	y1,x1,a	
	move	a,x:(r0)+	; store "last sample"

	move	r4,r1
	move	r5,a
	move	x:(r1)+,y0		; 
	add	y0,a	#>chn1buf,r0	; r0-> channel buffer
	move	a1,r6

	jsr	(r2)			; add voice 1

nextvoice
	lua	(r4)+n4,r4
getchnlp
	move	n3,r6
	bclr	#3,x:HCR
	bclr	#4,x:HCR
	rti

setup_player
	clr	a	#>vc1_data,r5	; voice
	rep	#(no_channels*4)
	move	a,x:(r5)+		
	move	#circbuf,r6		; circular buffer pointers 
	move	#cbufsize-1,m6		; and modulos.. 
	move	r6,r7			; 
	move	#>2,n6			; interleaved stereo voices 
	movec	m6,m7			; 
	rep	n0			; and clear the buffer
	move	a,y:(r6)+		;
	bset	#2,x:HCR		; enable host commands	
	bclr	#3,x:HCR
	bclr	#4,x:HCR
	movep	#$0c00,x:IPR		; Set the IPR for HOST COMMANDS 

; Setup DAC output.	
	movep	#$3c00,x:IPR		; Set the IPR for ssi interrupts, and ENABLE HOST COMMANDS HPL0,HPL1
	movep	#$4100,x:CRA		; set wordlength to 16bits and 2 words per "frame".
	movep	#$5800,x:CRB		; transmit int enable | transmitter enable | enable network mode(word request)
	movep	#$1f8,x:PCC		; turn on SSI port(Port C control reg)
	movep	#0,x:PCDDR		; 
	andi	#$f0,mr			; unmask interrupts
	move	#$475249,b
sendgo1	jclr	#1,x:HSR,sendgo1	;
	movep	b1,x:HRX		; 
	move	#$464621,b
sendgo2	jclr	#1,x:HSR,sendgo2	;
	movep	b1,x:HRX		; 
forever	jmp 	forever

	end	