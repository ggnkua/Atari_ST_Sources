;	image processing with dsp
;	deriche filter
; T.AL 95
; tab=16

SEND_FACTOR	equ 1	; function opcode
S_FILTER	equ 2
D_FILTER	equ 3

BCR	EQU $FFFE	; Port A Bus Control Register
PBC	EQU $FFE0	; Port B Control Register
HCR	EQU $FFE8	; Host Control Register
HSR	EQU $FFE9	; Host Status Register
HRX	EQU $FFEB	; Host Receive Data Register
HTX	EQU $FFEB	; Host Transmit Data Register


	org p:0
	jmp $40
	
	org p:$40
	movep #1,X:PBC		;port b = host interface

;reception de donnees sur le port host
;	jclr #0,X:HSR,*
;	movep X:HRX,x0
	
;envoie de donnes sur le port host
;	jclr #1,X:HSR,*
;	movep b1,X:HTX

wait_opcode	jclr #0,X:HSR,*
	movep X:HRX,a

	move #>SEND_FACTOR,x0
	cmp x0,a
	jeq receive_factor
                
	move #>S_FILTER,x0
	cmp x0,a
	jeq s_filter
	
	move #>D_FILTER,x0
	cmp x0,a
	jeq d_filter
	
	jmp wait_opcode

;------------------------------------------------
receive_factor

;sa	ds 4	;filtre de lissage
;sb	ds 2
;da	ds 1	;filtre de derivation
;db	ds 2

	move #factors,r0

	do #nb_factors,end_receive_loop
	jclr #0,X:HSR,*		;attente
	movep X:HRX,x0		;lecture facteur
	move x0,X:(r0)+		;stocke facteur
end_receive_loop
	
	jmp wait_opcode
	

;------------------------------------------------
s_filter	jclr #0,X:HSR,*		;attente
	movep X:HRX,x0		;lecture taille buffer
	move x0,X:bufsize

	jclr #0,X:HSR,*		;attente
	movep X:HRX,x1		;lecture nb buf
	move x1,X:n_buf
	
	do x1,end_s_filter	;n_buf calculs
	
	move #data,r5
	move r5,X:sigbuf	;buffer donnees
	                
	jclr #0,X:HSR,*		;attente
	movep X:HRX,y0		;lecture 1ere donnee
	
	move y0,Y:(r5)+
	move y0,Y:(r5)+		;init fir + ordre 2
	move y0,Y:(r5)+		;premiere donnee

	move X:bufsize,a
	move #>1,x1
	sub x1,a		;reste bufsize-1 donnees
	
	do a,receive_sig
	jclr #0,X:HSR,*		;attente
	movep X:HRX,y0		;lecture donnee
	move y0,Y:(r5)+
receive_sig
	move y0,Y:(r5)+
	move y0,Y:(r5)+		;init fir - ordre 2
	
	move r5,X:filter_p	;debut second buffer
	
	
;-----------------------------------------------
;calcul de y(m)= y-(m) + y+(m), m= 1->N
;avec y-(m)= a2*x(m+1) + a3*x(m+2) - b1*y-(m+1) - b2*y-(m+2), m= N->1
;et   y+(m)= a0*x(m)   + a1*x(m-1) - b1*y+(m-1) - b2*y+(m-2), m= 1->N

;-----------------------------------------------
;               calcul de y+(m)
; copie les coeff utilises

	move #factorbuf,r0	;dans factorbuf
	move X:sa+1,y0		;a1
	move y0,X:(r0)+
	move X:sa,y0		;a0
	move y0,X:(r0)+
	move X:sb+1,y0		;b2
	move y0,X:(r0)+
	move X:sb,y0		;b1
	move y0,X:(r0)+

;init calcul
	move #factorbuf,r0
	move #>4,n0
	move X:sigbuf,r4	;x(m-2)
	move #>1,n4
	;move X:filter_p,r5	;y+(m-2)
	move #>4,n5
	move r5,r6
	clr a	(r4)+	;x(m-1)
	move a0,Y:(r6)+
	move a0,Y:(r6)		;efface y+(m-1) et y+(m-2)
	move #0.0001220703,x1	;decalage >>12+1

;corps du calcul
	do X:bufsize,end_sp_loop
	move X:(r0)+,x0	Y:(r4)+,y0	;x0: a1, y0: x(m-1)
	mpy x0,y0,a		;a= a1*x(m-1)
	
	move X:(r0)+,x0 Y:(r4),y0	;x0: a0, y0: x(m)
	mac x0,y0,a		;a+= a0*x(m)
	
	move X:(r0)+,x0	Y:(r5)+,y0	;x0: b2, y0: y+(m-2)
	mac -x0,y0,a		;a-= b2*y+(m-2)
	
	move X:(r0)+,x0	Y:(r5)+,y0	;x0: b1, y0: y+(m-1)
	mac -x0,y0,a	(r0)-n0	;a-= b1*y+(m-1)

	move a0,x0
	mpy x1,x0,a		;decalage >>12+1
	move a1,Y:(r5)-		;y+(m)= a
end_sp_loop

	move (r5)+n5
	move r5,X:filter_m	;second buffer de calcul
	
;-----------------------------------------------
;               calcul de y-(m)
; copie les coeff utilises

	move #factorbuf,r0	;dans factorbuf
	move X:sa+3,y0		;a3
	move y0,X:(r0)+
	move X:sa+2,y0		;a2
	move y0,X:(r0)+
	move X:sb+1,y0		;b2
	move y0,X:(r0)+
	move X:sb,y0		;b1
	move y0,X:(r0)+

;init calcul
	move X:bufsize,n5
	move (r0)-n0
	move (r4)+		;Y:(r4)= x(m+2), X:(r0)= factorbuf
	clr a	(r4)+
	move (r5)+n5		;Y:(r5)= y-(N)
	move (r5)+
	move (r5)+
	move a0,Y:(r5)+
	move a0,Y:(r5)		;efface y-(m+1) et y-(m+2)
	move #0.0001220703,x1	;decalage >>12+1
	
;corps du calcul
	do X:bufsize,end_sm_loop
	move X:(r0)+,x0	Y:(r4)-,y0	;x0: a3, y0: x(m+2)
	mpy x0,y0,a		;a= a3*x(m+2)
	
	move X:(r0)+,x0 Y:(r4),y0	;x0: a2, y0: x(m+1)
	mac x0,y0,a		;a+= a2*x(m+1)
	
	move X:(r0)+,x0	Y:(r5)-,y0	;x0: b2, y0: y+(m+2)
	mac -x0,y0,a		;a-= b2*y-(m+2)
	
	move X:(r0)+,x0	Y:(r5)-,y0	;x0: b1, y0: y+(m+1)
	mac -x0,y0,a	(r0)-n0	;a-= b1*y-(m+1)
	
	move a0,x0
	mpy x1,x0,a		;decalage >>12+1
	move a1,Y:(r5)+		;y-(m)= a
end_sm_loop

;-----------------------------------------------
;calcul de y(m)= y-(m) + y+(m), n= 1->N                

	move X:filter_p,r0	;transmet le buffer resultat
	move X:filter_m,r1
	move (r0)+
	move (r0)+
	move (r1)+
	move (r1)+
	clr a

	do X:bufsize,end_s_loop
	move Y:(r0)+,a
	move Y:(r1)+,x0
	add x0,a
                
	jclr #1,X:HSR,*
	movep a,X:HTX		;envoye le resultat
end_s_loop	
	nop
end_s_filter
	jmp wait_opcode



;------------------------------------------------
d_filter	
	jmp wait_opcode


;------------------------------------------------
	org x:0

factors	equ *
sa	ds 4
sb	ds 2

da	ds 1
db	ds 2
nb_factors	equ *-factors

factorbuf	ds 4

bufsize	ds 1		;taille buffer
n_buf	ds 1		;nb de buf a traiter

sigbuf	ds 1		;buffer signal Y:
filter_p	ds 1		;buffer filtrage + Y:
filter_m	ds 1		;buffer filtrage - Y:

;------------------------------------------------
	org y:$200
data	equ *		;espace reserve aux buffers

	
;------------------------------------------------
	end
