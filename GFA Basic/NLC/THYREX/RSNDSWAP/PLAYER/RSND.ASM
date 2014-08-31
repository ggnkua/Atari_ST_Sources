;--------------------------------------------
;	 REAL SOUND PLAYER	n voix      -
;             v1.00                   	    -
;	coded by : NEW_FACE	            -
;	                             	    -
;	 ½95  EXA !!	           	    -
;                                    	    -
;--------------------------------------------
;
;
;*MEMORY NOTE:
; we use from y:$3a30 to y:$4000 (from p:$3a50 to p:$4000)
;    and from x:$3000 to x:$381e
;
;*REGISTERS NOTE
; we use R7 M7 for SSI transmit !
;you are free to change them !
;
;*DIVERS:
;you are to use this rout as long as you tell
;my name: NEW-FACE





	OPT NOW

PBC	equ	$ffe0	;Port B Control register
PCC	equ	$ffe1	;Port C Control register
PBDDR	equ	$ffe2	;Port B Data Direction Register
PCDDR	equ	$ffe3	;Port C Data Direction Register
PBD	equ	$ffe4	;Port B Data register
PCD	equ	$ffe5	;Port C Data register
HCR	equ	$ffe8	;Host Control Register
HSR	equ	$ffe9	;Host Status Register
HRX	equ	$ffeb	;Host Receive Register
HTX	equ	$ffeb	;Host Transmit Register
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
BCR	equ	$fffe	;Port A Bus Control Register
IPR	equ	$ffff	;Interrupt Priority Register

size_buffer	equ	$800

rhost	MACRO	dest
	jclr	#0,x:<<HSR,*
	movep	x:<<HRX,dest
	ENDM
whost	MACRO	source
	jclr	#1,x:<<HSR,*
	movep	source,x:<<HTX
	ENDM


	org	p:0
	jmp	start_snd
	
	org	p:$10
	movep	x:(r7)+,x:<<TX
	nop
	movep	x:(r7)+,x:<<TX	;exception transmission 
				;(eviter les trop grands REP, sinon le son est d‚geu )
	nop
	org	p:$26
	jsr	cmd
	jsr	loader
	
	org	p:$4000-$5d0
;--------------------------------------------
start_snd
	bclr	#3,x:<<HCR
	movep	#1,x:<<PBC		;Host enable
	movep	#$04,x:<<HCR		;Host Command
	movep	#>$3800,x:<<IPR 	;SSI en IPL3, Host en IPL2
	movep	#$4100,x:<<CRA		;SSI en 2 mots/frame, 16 bits
	movep	#$0800,x:<<CRB		;SSI off
	movep	#$01f8,x:<<PCC		;Port C en SSI
	movep	#$0008,x:<<PCDDR	;Idem
	andi	#%11110000,mr		
	jsr	init_buffer
	bset	#3,x:<<HCR	;fin d'initialisation (sources de plantages...)
	jmp	*

loader
	andi  #<$F0,mr
 	move 	#>-1,m0
 	move  #>1,n0
 	movec sp,r0
	ori   #<1,mr
 	lua   (r0)-n0,r0
	move  #>load_register,r1
	movec r0,sp
restart
	jsr   (r1)
 	move  x0,n2
	move  #list_cmd,r2
 	nop
 	move  p:(r2+n2),r2
	nop
 	jmp   (r2)
	dc	0
list_cmd
	dc    	memoryp
	dc    	memoryx
	dc    	memoryy
memoryp
	jsr   (r1)
 	move  x0,r0
 	jsr   (r1)
 	do    x0,_loop
 	rhost	p:(r0)+
_loop
 	jmp   restart

memoryx
 	jsr   (r1)
 	move  x0,r0
 	jsr   (r1)
 	do    x0,_loop
 	rhost	x:(r0)+
_loop
 	jmp   restart

memoryy
	jsr   (r1)
	move  x0,r0
	jsr   (r1)
	do    x0,_loop
	rhost	y:(r0)+
_loop
	jmp	restart
	
load_register	
	rhost	x0
	rts
	
;--------------------------------------------
cmd
	jsr	save_reg	
	bclr	#3,x:<<HCR
	rhost	a
	tst	a
	jeq	coupe
;--------------------------------------------
	clr	a	y:ptr_buf,r6
	movec	#size_buffer-1,m6
	move	a,y:move
	move	r7,a
	move	r6,x0
	sub	x0,a		#>size_buffer,x0		;r7-r6
	tst	a
	jgt	_go_for_that
	add	x0,a
_go_for_that
	asr	a
	clr	a	a,y:loop
	move	#2,n6
	move	n6,n1
	move	n6,n2

	move	#copy_mem,r1	;source
	move	#>5,a	;nb
	move	#$40,r2	;dest
	jsr	copy_double_dest
	
	move	#copy_mem2,r1	;source
	move	#>6,a	;nb
	jsr	copy_double_dest

	move	#>0,x0
	
	move	r6,r3
;	X:r6=r3=BUFFER_COURANT
;voix1
_loop_all_voice
	rhost	a
	move	#>$1234,x0
	cmp	x0,a
	jeq	_end_of_voice
	move	a1,y:control_data
	jsr	go_for_voice_8bits	;(tester si 16 bits)
	move	r3,r6
	nop
	move	(r6)+
	btst	#0,y:control_data
	tcc	x0,b	r3,r6		;si voix gauche.	
	jcs	_voix_droite
	bset	#0,y:move
	jmp	_next
_voix_droite
	bset	#1,y:move
_next
;{	reste identique pour du 8 ou 16 bits.
	move	#calc_freq_voice_move,r1
	move	#calc_freq_voice_add,r2
	btst	#1,y:control_data
	tcs	x0,b	r1,r2
	nop
	jsr	(r2)
	jmp	_loop_all_voice

;--------------------------------------------

;	si fini en voix droite soustraire 1 a r6
_end_of_voice
	move	y:loop,b
	move	#>1,y0
	move	r6,r2
	sub	y0,b	y:move,x0
	jset	#0,x0,_no_clr_left_data
	clr	a	r3,r6
	do	b,_no_clr_left_data
	move	a,x:(r6)+n6
_no_clr_left_data
	move	(r3)+
	jset	#1,x0,_no_clr_right_data
	clr	a	r3,r6
	do	b,_no_clr_right_data
	move	a,x:(r6)+n6
_loop_clr_right_data
_no_clr_right_data
	move	r2,r6
	btst	#0,y:control_data
	jcc	_voix_gauche
	move	(r6)-
_voix_gauche
	move	#copy_mem,r1	;source ;remet en etat la memoire interne
	move	#>5,a	;nb
	move	#$40,r2	;dest
	jsr	copy_double_dest

	move	#copy_mem2,r1	;source
	move	#>6,a	;nb
	jsr	copy_double_dest

	move	r6,y:ptr_buf

	movep	#>$5800,x:<<CRB
	bset	#3,x:<<HCR
	jsr	restore_reg
	rti

copy_double_dest
	do	a,_loop_copy
	move	y:(r1),a
	movem	p:(r2),x0
	move	x0,y:(r1)+
	move	a,p:(r2)+
_loop_copy
	rts


;--------------------------------------------
go_for_voice_8bits
	rhost	a
	move	a,y:vol_sample			;volume_sample
	rhost	x0				;freq sample
	move	x0,y:freq_sample
	move	y:loop,x1
	mpy	x0,x1,a		#buffer_inter,r1	;addresse_buffer_inter	
	whost	a				;nbr_octet_a_transferer	
	asr	a	#buffer_inter+1,r2
	move	#>0,a0
	tst	a	#>$ff0000,x1	
	jeq	_loop_nothing		;(sample nul)
	rhost	b1
	jclr	#0,b1,_no_first_parite
	rhost	y:(r1)+
	move	(r2)+
_no_first_parite
	move	#>$80,y0	
	move	#>$8000,y1
;separe_les_sample
	move	(r1)-n1

;{	
	do	a,_loop_separe_sample
	rhost	x0
	mpy	x0,y0,a		a,y:(r1)+n1	
	mpy	x0,y1,b		a0,a
	and	x1,a		b0,y:(r2)+n2
_loop_separe_sample
;}
	rhost	x0
	mpy	x0,y0,a		a,y:(r1)+n1
	mpy	x0,y1,b		a0,a	
	and	x1,a		b0,y:(r2)+n2
	move	a,y:(r1)+n1
	rts
_loop_nothing
	clr	a
	move	a,y:(r1)
	rts
;--------------------------------------------



;--------------------------------------------
;	sample_move
;--------------------------------------------
calc_freq_voice_move
	move	y:loop,b
	move	#>1,y0
	sub	y0,b	y:vol_sample,y0
	clr	b	b,n3
	move	y:freq_sample,b0	
	asl	b		#buffer_inter,r2
	move	r2,a	
	move	b1,x1		
	move	b0,x0		
	move	y:(r2),y1				;premier_sample
	move	r2,a		
	add	x,a
	mpy	y1,y0,b	
	jmp	$40
copy_mem
	org	pi:$40,p:
	do	n3,_loop_move_voice	;mettre en mem p:interne
	dc	$cd4eb8
	add	x,a		a,r2
_loop_move_voice
	rts
	org	p:
;--------------------------------------------
; 	dc $cd4eb8 	‚quivaut a
;	mpy y1,y0,b 	b,x:(r6)+n6	y:(r2),y1
;--------------------------------------------

;--------------------------------------------
;	sample_add
;--------------------------------------------
calc_freq_voice_add
	move	y:loop,b
	move	#>1,y0
	sub	y0,b	y:vol_sample,y0
	clr	b	b,n3
	move	y:freq_sample,b0	
	asl	b		#buffer_inter,r2
	move	b1,x1		
	move	b0,x0		
	move	r2,a		
	move	x:(r6),b
	move	y:(r2),y1
	mac	y1,y0,b		
	add	x,a
	move	a,r2
	jmp	$45
copy_mem2
	org	pi:$45,p:
	do	n3,_loop_add_voice	;mettre en mem p:interne
	add	x,a		b,x:(r6)+n6	
	move	x:(r6),b	y:(r2),y1
	mac	y1,y0,b		a,r2
_loop_add_voice
	rts
	org	p:
coupe
	movep	#$0800,x:<<CRB			;SSI off
	jsr	restore_reg
	rti
;--------------------------------------------
 

;--------------------------------------------
;	r6 r7
;--------------------------------------------

init_buffer				
	move	#>$0,x0
	move	#buffer,r7			;init_addresse
	rep	#size_buffer
	move	x0,x:(r7)+
	move	#buffer_inter,r6			;init_addresse
	rep	#1024
	move	x0,y:(r6)+
	move	#buffer,r7			;init_addresse
	move	#buffer,r6			;init_addresse
	movec	#size_buffer-1,M7
	move	r6,y:ptr_buf
	rts

;--------------------------------------------

save_reg
	andi	#%01010011,mr	;Virer: NO(scaling, trace, loop)
	move	r1,x:sauve
	move	#sauve+1,r1
	nop
	move	r6,x:(r1)+
	move	m6,x:(r1)+
	move	n6,x:(r1)+
	move	r2,x:(r1)+
	move	m2,x:(r1)+
	move	n2,x:(r1)+
	move	r3,x:(r1)+
	move	m3,x:(r1)+
	move	n3,x:(r1)+
	move	a2,x:(r1)+
	move	a1,x:(r1)+
	move	a0,x:(r1)+
	move	b2,x:(r1)+
	move	b1,x:(r1)+
	move	b0,x:(r1)+
	move	x0,x:(r1)+
	move	x1,x:(r1)+
	move	y0,x:(r1)+
	move	n1,x:(r1)+
	move	y1,x:(r1)+
	move	m1,x:(r1)+
	movec	#-1,m1
	movec	m1,m2
	movec	m1,m3
	move	#resend1,r1	;par NULLOS/DNT
	move	#'RSP',x0		;Identification du mixeur
	tfr	x0,a	x0,y0	;
	whost	x0		;On l'envoie au 030, les deux
_link	move	y0,y1		;tests ‚tant en quinconce.
	move	a,y0		;
	rhost	a		;Attendre celui donn‚ par le 030,
	cmp	x0,a		;en notant un ‚ventuel envoi Host
	jne	_link		;interrompu.
	whost	y0		;Echange avec le 030 ce que l'on
	whost	y1		;a intercept‚.
	rhost	y:(r1)+		;
	rhost	y:(r1)+		;
	rts
	
;--------------------------------------------
	

restore_reg
HostResend	;par NULLOS/DNT
	move	#'RSP',x0		;Remplir le port Host avec ce
	move	#resend1,r1	;qu'il contenait au moment de
	.loop	#2		;l'interruption … destination
	move	y:(r1)+,a		;du 68030...
	cmp	x0,a		;
	jeq	_nosend		;
	movep	a,x:<<HTX	;
_nosend	nop			;
	.endl			;
	move	#sauve+1,r1
	nop
	move	x:(r1)+,r6
	move	x:(r1)+,m6
	move	x:(r1)+,n6
	move	x:(r1)+,r2
	move	x:(r1)+,m2
	move	x:(r1)+,n2
	move	x:(r1)+,r3
	move	x:(r1)+,m3
	move	x:(r1)+,n3
	move	x:(r1)+,a2
	move	x:(r1)+,a1
	move	x:(r1)+,a0
	move	x:(r1)+,b2
	move	x:(r1)+,b1
	move	x:(r1)+,b0
	move	x:(r1)+,x0
	move	x:(r1)+,x1
	move	x:(r1)+,y0
	move	x:(r1)+,n1
	move	x:(r1)+,y1
	move	x:(r1)+,m1
	move	x:sauve,r1
	rts

;--------------------------------------------

end_prog	
move			ds	1
ptr_buf			ds	1
control_data		dc	2
resend1			ds	1
resend2			ds	1
vol_sample		dc	$400000
freq_sample		dc	$14d8dc
loop			ds	1
			ds	2
buffer_inter		ds	1024	
taille_prg		dc	*-start_snd
		org	x:$3000
buffer		ds	size_buffer
sauve		ds	30

;--------------------------------------------
