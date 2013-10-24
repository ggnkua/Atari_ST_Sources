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
period_vol	dc 0,0,0,0,0,0,0,0
len_buffer	dc 1000
data_sam	ds 8000

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
	jclr #0,X:HSR,*	;Periode reelle sur 24 Bits
	movep x:HTX,x:(r0)+
	jclr #0,X:HSR,*	;Periode entiere sur 24 Bits
	movep x:HTX,x:(r0)+
	jclr #0,X:HSR,*	;Nombre de mot a transferer-1 !!!!!
	movep x:HTX,y0
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
	move #data_sam+4000,r3
	jclr #0,X:HSR,*		;volume voie i
	movep x:HTX,x:(r0)+
load_period
	
	; CALCUL DES DEUX VOIES CHARGEES
	
	bset	#3,X:<<HCR
	move #period_vol,r0
	move x:len_buffer,n5	;Nombre de DO=longueur buffer replay
	move #data_sam,r2
	move r4,r1
	move #>2,n4
	lua (r1)+,r1
	
	jclr #0,n6,mix_all
	move #>0,n6
	jsr put_1voie
	move r1,r4
	move #data_sam+4000,r2
	jsr put_1voie
	jmp suite
mix_all	jsr mix_1voie
	move r1,r4
	move #data_sam+4000,r2
	jsr mix_1voie
suite	bclr	#3,X:<<HCR
	nop
calc_2voies	
	lua (r4)-,r4
	jmp start
	
mix_1voie	move x:(r0)+,x0
	clr a x:(r0)+,x1
	move r2,a1
	move x:(r0)+,y0		;Volume
	do n5,mix_v
	add x,a        x:(r2),y1	;Algo incremental !!!
	mpy y0,y1,b    y:(r4),y1 
	add y1,b	a1,r2
	clr b b,y:(r4)+n4			
mix_v
	rts
	
put_1voie	move x:(r0)+,x0
	clr a x:(r0)+,x1
	move r2,a1
	move x:(r0)+,y0	;Volume
	do n5,put_v
	add x,a 	x:(r2),y1	;Algo incremental !!!
	mpy y0,y1,b a1,r2
	move b,y:(r4)+n4			
put_v
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


