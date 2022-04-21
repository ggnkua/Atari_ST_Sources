;**************************************************************************
;* Toulouse 18/04/94, FRANCE
;*
;* Ce programme DSP est vraiment easy, vous pouvez l'adapter au nombre
;* de voies que vous voulez...
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
	dc 0,0,0,0,0,0,0,0
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

	move #period_vol,r0
	move #data_sam,r3
	move #>$8000,x1
	move #>1000,x0
	move x0,n3
	do n2,load_period
	jclr	#0,X:HSR,*		;Periode voie i
	movep	x:HTX,y0
	mpy x0,y0,a	y0,x:(r0)+	;Calcul nb octets et stocke periode...
	jclr	#1,X:HSR,*		;Envoie le nb d'octets voie i
	movep	a1,x:HTX
	move r3,r1
	move #>1,x0
	lsr a
	add x0,a
	move a1,y0
	jclr	#0,X:HSR,*		;1er sample... 
	movep	x:HTX,y1
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
	lua (r3)+n3,r3
	move #>1000,x0
	jclr	#0,X:HSR,*		;volume voie i
	movep	x:HTX,x:(r0)+
load_period

Calcule	bset	#3,X:<<HCR
	move #>2,n4
	move #period_vol,r0
	
	move #data_sam,r2
	move r4,r6
	jsr Put_one_voice
	move #data_sam+1000,r2
	move r6,r4
	jsr Mix_one_voice
	move #data_sam+2000,r2
	move r6,r4
	jsr Mix_one_voice
	move #data_sam+3000,r2
	move r6,r4
	jsr Mix_one_voice
	lua (r6)+,r6
	move #data_sam+4000,r2
	move r6,r4
	jsr Put_one_voice
	move #data_sam+5000,r2
	move r6,r4
	jsr Mix_one_voice
	move #data_sam+6000,r2
	move r6,r4
	jsr Mix_one_voice
	move #data_sam+7000,r2
	move r6,r4
	jsr Mix_one_voice
	lua (r4)-,r4
	bclr	#3,X:<<HCR
	jmp start
	
Put_one_voice
	clr b #>1000,n2
	clr a 	#>0,x1
	move x:(r0)+,b1
	lsl b	r2,a1
	move b1,x0		;Increment !!
	move x:(r0)+,y0		;Volume
	do n2,put_v
	add x,a        x:(r2),y1	;Algo incremental !!!
	mpy y0,y1,b    a1,r2
	move b,y:(r4)+n4			
put_v
	rts
	
Mix_one_voice
	clr b #>1000,n2
	clr a 	#>0,x1
	move x:(r0)+,b1
	lsl b	r2,a1
	move b1,x0		;Increment !!
	move x:(r0)+,y0		;Volume
	do n2,mix_v
	add x,a        x:(r2),y1	;Algo incremental !!!
	mpy y0,y1,b    y:(r4),y1 
	add y1,b	a1,r2
	clr b b,y:(r4)+n4			
mix_v
	rts
	
coupe	clr 	a 	#buffer_sam,r0
	move #>4000*2,x0
	do x0,eff2
	move a,y:(r0)+
	move a,y:(r0)+
eff2	
	jmp start
	
	end


