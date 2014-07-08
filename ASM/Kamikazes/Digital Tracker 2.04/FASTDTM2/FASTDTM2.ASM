;* PLAYER DSP
;*
;* Only 8 bits, voice in stereo, Tempo
;*
;* No optimised in any way
;*
;* Mc JEE / KAMIKAZES

BCR	EQU     $FFFE           ; Port A Bus Control Register
HTX	EQU     $FFEB           ; Host Transmit Data Register
HSR   	EQU     $FFE9	; Host status register
RX	EQU     $FFEF           ; Serial Receive Data Register
TX	EQU     $FFEF           ; Serial Transmit Data Register
TSR	EQU     $FFEE	; don't care skip register
CRA  	EQU     $FFEC          	; SSI Control Register A
CRB   	EQU     $FFED           ; SSI Control Register B
SSR	EQU     $FFEE
IPR   	EQU     $FFFF           ; Interrupt Priority Register
PCC   	EQU     $FFE1           ; Port C Control Register
PCDDR 	EQU     $FFE3           ; Port C Data Direction Register

PBC	EQU     $ffe0			
HCR	EQU     $ffe8			
HRX	EQU     $ffeb			

	org x:0
period_vol	dc 0,0,0,0,0,0,0,0,0,0
len_buffer	dc 1000
volume	dc 0
f_stereo	dc 0
	org x:$200
data_sam	ds 16000

	org y:0
buffer_sam	ds 8000*2
	
	org	p:$0
	jmp	Reset

	org	p:$10
	MOVEP Y:(r5)+,X:<<RX
	
	org	p:$12
	MOVEP Y:(r5)+,X:<<RX

	org	P:$40
	
Reset	MOVEP X:<<HRX,X0
	MOVEC #<0,SP
	MOVEP #$004100,X:<<CRA
	MOVEP #$0001F8,X:<<PCC
	BTST  #4,X:<<SSR
	MOVEP #$000000,X:<<BCR
	MOVEP #$003000,X:<<IPR
	MOVEP #$000001,X:PBC
	MOVE  #<0,X0
 	MOVE  X0,Y:<0
 	clr a
	move #buffer_sam,r0
	move r0,r4
	move #>4000*2,x0
	do x0,eff
	move a,y:(r0)+
	move a,y:(r0)+
eff	
	move #buffer_sam+8000,r5 	
	move #8000*2-1,m4
	move m4,m5
	movep	#1,X:PBC	; configure for host port
	jclr	#0,X:HSR,*	;Attend le player pour la premiere fois
	ANDI  #<$FC,MR
	MOVEP #$005800,X:<<CRB	;Transmit seulement...
	jmp start2
start	jclr	#0,X:HSR,*	;Attend le player...
start2	movep	x:HTX,n2	;Nombre de voies...
	
	jclr	#0,X:HSR,*	
	movep	x:HTX,x:volume	;Nb voie * 32
	
	jclr	#0,X:HSR,*	
	movep	x:HTX,x:f_stereo
	
	jset	#15,n2,coupe
	jclr	#14,n2,begin
	jset	#0,r5,*
	jclr	#0,r5,*
	jset	#0,r5,*
	move #buffer_sam,r4
	move #buffer_sam+8000,r5 	
begin	bclr #14,n2
	
	jclr #0,X:HSR,*	;Longueur du buffer de replay
	movep x:HTX,x:len_buffer

	; CHARGEMENT DES VOIES PAR 2 !!!
	
	move r4,r6
	move #>1,n6
	do n2,calc_2voies
	
	move r6,r4
	move #period_vol,r0
	move #data_sam,r3
	move #>$8000,x1
	
	do #2,load_period
	jclr #0,X:HSR,*	;OLD CALC sur 24 Bits
	movep x:HTX,x:(r0)+
	jclr #0,X:HSR,*	;Periode reelle sur 24 Bits
	movep x:HTX,x:(r0)+
	jclr #0,X:HSR,*	;Periode entiere sur 24 Bits
	movep x:HTX,x:(r0)+
	jclr #0,X:HSR,*	;Nombre de mot a transferer-1 !!!!!
	movep x:HTX,y0
	bset #1,n6		;Normal
	bclr #2,n6		;Interpol
	bclr #3,n6		;Mono
	jclr #22,y0,no_inter
	bset #2,n6
	bclr #1,n6
no_inter	jclr #21,y0,no_mono
	bset #3,n6
	bclr #1,n6
no_mono	jclr #20,y0,no_intermono
	bset #4,n6
	bclr #1,n6
no_intermono	bclr #22,y0
	bclr #21,y0
	bclr #20,y0
	jset #23,y0,c16bit
	move #>$8000,x1
	move r3,r1
	jclr #0,X:HSR,*	;1er sample... 
	movep x:HTX,y1
	mpy x1,y1,a
	move a1,y1			;On a un mot...
	mpy x1,y1,b	
	move b0,x:(r1)+
	do y0,load_sam
	jclr	#0,X:HSR,*		;ieme sample 
	movep	x:HTX,y1
	mpy x1,y1,a	a0,x:(r1)+
	move a1,y1
	mpy x1,y1,b	
	move b0,x:(r1)+
load_sam
	move a0,x:(r1)+
	nop
	jmp goon
c16bit	bclr #23,y0
	move #>$80,x1
	move r3,r1
	jclr #0,X:HSR,*	;1er sample... 
	movep x:HTX,y1
	mpy x1,y1,a
	move a0,x:(r1)+
	do y0,load_sam16
	jclr	#0,X:HSR,*		;ieme sample 
	movep	x:HTX,y1
	mpy x1,y1,a
	move a0,x:(r1)+
load_sam16	
	nop
goon	nop
	do #2,get_vol
	clr	a
	jclr #0,X:HSR,*		;volume voie i
	movep x:HTX,a1
	move	x:<volume,x0
	and	#$FE,CCR
	rep	#$18
	div	x0,a
	move	a0,x:(r0)+
get_vol	
	move #data_sam+8000,r3
	nop
load_period
	
	; CALCUL DES DEUX VOIES CHARGEES
	
	bset	#3,X:<<HCR
	move #period_vol,r0
	move x:len_buffer,n5	;Nombre de DO=longueur buffer replay
	move #data_sam,r2
	move r4,r1
	move #>2,n4
	
	jclr #0,n6,mix_all
	bclr #0,n6
	jsset #1,n6,put_1voie
	jsset #2,n6,put_1voiei
	jsset #3,n6,put_1voiem
	jsset #4,n6,put_1voieim
	move r1,r4
	move #data_sam+8000,r2
	jsset #1,n6,put_1voie
	jsset #2,n6,put_1voiei
	jsset #3,n6,mix_1voiem
	jsset #4,n6,mix_1voieim
	jmp suite
mix_all	jsset #1,n6,mix_1voie
	jsset #2,n6,mix_1voiei
	jsset #3,n6,mix_1voiem
	jsset #4,n6,mix_1voieim
	move r1,r4
	move #data_sam+8000,r2
	jsset #1,n6,mix_1voie
	jsset #2,n6,mix_1voiei
	jsset #3,n6,mix_1voiem
	jsset #4,n6,mix_1voieim
	nop
suite	bclr	#3,X:<<HCR
	nop
calc_2voies	
	lua (r4)-,r4
	jmp start
	
mix_1voie	lua (r1)+,r1		;Pas mono
	clr a
	move x:(r0)+,a0
	move x:(r0)+,y0	;Periode 
	move x:(r0)+,y1
	move r2,a1
	move r2,r3
	clr b 	x:(r0)+,x0	;Volume
	
	do n5,mix_v
	add y,a	x:(r2),x1	y:(r4),b
	macr x0,x1,b a1,r2		
	clr b 	b,y:(r4)+n4
mix_v	
	lua (r0)+,r0
	rts
	
put_1voie	lua (r1)+,r1		;Pas mono	
	clr a
	move x:(r0)+,a0
	move x:(r0)+,y0	;Periode
	move x:(r0)+,y1
	move r2,a1
	move r2,r3
	move x:(r0)+,x0	;Volume
	do n5,put_v
	add y,a 	x:(r2),x1
	mpy x0,x1,b a1,r2	
	move	b,y:(r4)+n4
put_v
	lua (r0)+,r0
	rts
	
mix_1voiem	clr a
	move x:(r0)+,a0
	move x:(r0)+,y0	;Periode 
	move x:(r0)+,y1
	move r2,a1
	move r2,r3
	clr b 	x:(r0)+,x0	;1 er Volume
	do n5,mix_vm
	add y,a	x:(r2),x1	y:(r4)+,b
	macr x0,x1,b  	y:(r4)-,x0
	tfr x0,b	x:(r0)-,x0	b,y:(r4)+
	macr x0,x1,b	a1,r2	
	clr b 	x:(r0)+,x0	b,y:(r4)+
mix_vm	
	lua (r0)+,r0
	lua (r4)+,r4
	rts
	
put_1voiem	clr a
	move x:(r0)+,a0
	move x:(r0)+,y0	;Periode
	move x:(r0)+,y1
	move r2,a1
	move r2,r3
	move x:(r0)+,x0	;Volume
	do n5,put_vm
	add y,a 	x:(r2),x1	
	mpy x0,x1,b 	x:(r0)-,x0
	mpy x0,x1,b	x:(r0)+,x0	b,y:(r4)+
	move 	a1,r2
	move	b,y:(r4)+
put_vm
	lua (r0)+,r0
	lua (r4)+,r4
	rts
	
put_1voiei	lua (r1)+,r1		;Pas mono
	clr a
	move x:(r0)+,a0
	move x:(r0)+,y0	;Periode
	move x:(r0)+,y1
	move r2,a1
	move r2,r3
	clr b 
	
	do n5,put_vi
	add y,a	a0,b1	
	lsr b	x:(r2)+,x1
	tfr x1,b 	b1,x0
	macr -x0,x1,b	x:(r2),x1	;Xn-Xn*r
	macr x0,x1,b	x:(r0),x0	;Xn-Xn*r+(Xn+1*r)
	move 	b,x1	
	mpy x0,x1,b 	a1,r2
	move	b,y:(r4)+n4
put_vi	
	lua (r0)+,r0
	nop
	lua (r0)+,r0
	rts
	
mix_1voiei	lua (r1)+,r1		;Pas mono
	clr a
	move x:(r0)+,a0
	move x:(r0)+,y0	;Periode 
	move x:(r0)+,y1
	move r2,a1
	move r2,r3
	clr b 	
	do n5,mix_vi
	add y,a	a0,b1	
	lsr b	x:(r2)+,x1
	tfr x1,b 	b1,x0
	macr -x0,x1,b	x:(r2),x1	;Xn-Xn*r
	macr x0,x1,b	x:(r0),x0		;Xn-Xn*r+(Xn+1*r)
	abs a 	b,x1	y:(r4),b
	mac x0,x1,b 	a1,r2
	move	b,y:(r4)+n4
mix_vi
	lua (r0)+,r0
	nop
	lua (r0)+,r0
	rts
	

put_1voieim	clr a
	move x:(r0)+,a0
	move x:(r0)+,y0	;Periode
	move x:(r0)+,y1
	move r2,a1
	move r2,r3
	clr b 
	
	do n5,put_vim
	add y,a	a0,b1	
	lsr b	x:(r2)+,x1
	tfr x1,b 	b1,x0
	macr -x0,x1,b	x:(r2),x1	;Xn-Xn*r
	macr x0,x1,b	x:(r0)+,x0	;Xn-Xn*r+(Xn+1*r) & Charge volume
	move 	b,x1	
	mpy x0,x1,b 	x:(r0)-,x0	
	mpy x0,x1,b	b,y:(r4)+
	move	a1,r2
	move	b,y:(r4)+
put_vim	
	lua (r0)+,r0
	lua (r4)+,r4
	lua (r0)+,r0
	rts
	
mix_1voieim	clr a
	move x:(r0)+,a0
	move x:(r0)+,y0	;Periode 
	move x:(r0)+,y1
	move r2,a1
	move r2,r3
	clr b 	
	do n5,mix_vim
	add y,a	a0,b1	
	lsr b	x:(r2)+,x1
	tfr x1,b 	b1,x0
	macr -x0,x1,b	x:(r2),x1	;Xn-Xn*r
	macr x0,x1,b	x:(r0)+,x0	;Xn-Xn*r+(Xn+1*r)
	abs a 	b,x1	y:(r4)+,b
	mac x0,x1,b 	y:(r4)-,x0
	tfr x0,b	x:(r0)-,x0	b,y:(r4)+
	mac x0,x1,b	a1,r2
	move	b,y:(r4)+
mix_vim
	lua (r0)+,r0
	lua (r4)+,r4
	lua (r0)+,r0
	rts

	
	; COUPE LE SIFFLET
	
coupe	clr 	a 	#buffer_sam,r0
	move #>4000*2,x0
	do x0,eff2
	move a,y:(r0)+
	move a,y:(r0)+
eff2	
	jmp start
	
	end


