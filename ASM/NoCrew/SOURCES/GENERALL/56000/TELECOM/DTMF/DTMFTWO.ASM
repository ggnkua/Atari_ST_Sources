	title	'DTMF RECEIVER  AND GENERATOR MAIN PROGRAM'					     	
	page	132,66,0,10
;
;
;
;**********************************************************************
;This program is a single channel receiver and generator program.
;It uses sections det and sub which must be linked with this
;program to run
;**********************************************************************

        opt     rc,mu

dtmf	ident	1,1	;main
 




;**********************************************************************
;The following section loads definitions in X memory starting at xhi
;**********************************************************************




	SECTION define


	xdef	misc,keybrd,pret,ret,pos,num
	org	xhi:
misc	dc	$010000,$010000,tempo,1,troisl,$30
keybrd	dc	'1','2','3','A','4','5','6','B','7','8','9'
	dc	'C','*','0','#','D'	
pret	dc	$0a,$0d,'R','E','A','D','Y',':',$0a,$0d,
ret	dc	$0d,$0a
pos	dc	$20
num	dc	'0','0','0','1','0','2','0','3','0','4','0','5'
	dc	'0','6','0','7','0','8','0','9','1','0','1','1'
	dc	'1','2','1','3','1','4','1','5','1','6','1','7'
	dc	'1','8','1','9','2','0','2','1','2','2','2','3'
	dc	'2','4','2','5','2','6','2','7','2','8','2','9'
	dc	'3','0','3','1','3','2','3','3','3','4','3','5'
	dc	'3','6','3','7','3','8','3','9','4','0','4','1'
	dc	'4','2','4','3','4','4','4','5','4','6','4','7'
	endsec


;**********************************************************************
;The following section sets up the interupt vectors on the SCI receive
;port where the numbers 0-9 ABCD * or # are selected for tone
;generation
;**********************************************************************

	section vector
	org p:$0014       ;this is the SCI receive interupt vector location
	jsr tone          ;this is the generate subroutine
	org p:$0016       ;This is the SCI receive with exception vector
	jsr tone
	endsec




;**********************************************************************
;This section sets up the SSI and SCI tto transmit and receive.
;The SSI port is used to transmit and recive A-law data to/from
;a PCM codec.  The SCI port is used to display the results of
;detection to a RS232 terminal as well as to take inputs from
;the RS232 terminal to generate the desired tones.
;**********************************************************************




	section	periphials 
 	nolist
	include '\dsp56000.asm\ioequ'   ;This include file contains
	                                ;the i/o bit definitions
	list
	org	pli:
	ori #$03,mr                     ;Mask the interupts
	movep	#$c000,x:$ffff


;**************************************
; first program PORT A & OPERATING MODE
;**************************************

        movep   #$0,x:M_BCR	; no wait states
        move    #$4,omr		; mode 0 /ROM enable
		move	#M_SR,r6	;r6 -> ssi status reg.



;***********
; sci setup
;***********


;**************************************
;The SCI port is set up in the 10 bit
;asynchronous mode to operate with an
;RS232 terminal. The receiver and
;transmitter are enabled as well as the
;receiver interupt.
;**************************************

		movep	#0,x:M_SCR              ;zero the control register 
		bset	#M_WDS1,x:M_SCR         ;Set it for 10 bits 
        bset    #M_TE,x:M_SCR           ; enable the transmitter ( WDS=0 )
		bset	#M_RE,x:M_SCR           ;enable the receiver 
		bset	#M_RIE,x:M_SCR          ;enable the reciever interupt
        movep   #32,x:M_SCCR            ; CD=32 for divide by 33(2.5MHz/33)


;***********
; ssi setup
;***********


;**************************************
;The SSI is configured in the normal 
;mode with an external clock and in
;the synchronousmode.  Interupts are 
;not used but the RDF/TDE flags are.
;**************************************

        movep   #$1F03,x:M_CRA          ; PSR=0 , WL=0 , DC4-0=31 ,PM7-0=3
        movep   #$200,x:M_CRB 	        ; RIE=0,TIE=RE=TE=0 , MOD=0 , GCK=0
                                        ; SYN=1 , FSL=0 , SCKD=1 (int clk )
                                        ; SCD2=1(int TDE/RDE),OF(1:0)=0
        movep   #$1ff,x:M_PCC           ; set CC(8:3) as SSI pins
                                        ; set CC(2;0) as SCI pins
		movep	#$0,x:M_SR
        move    #$0,sr                  ; no mask ( enable all levels )
        movep	#$3200,x:M_CRB		    ; RIE=0,TIE=0, RE,TE = 1 
		andi	#$fc,mr                 ;unmask the interupts

	endsec


;**********************************************************************
;The following is the main section of the program which initializes
;the RS232 terminal and keeps track of detections to report to the
;RS232 terminal
;**********************************************************************
	section	main1
	org	pli:
; 
	xdef	tempo,troisl,rien,enc              ;internal subroutines
	xref	ready,misc,keybrd,pret,ret,pos,num ;external subroutines
;
tempo	equ	$2C
troisl	equ	16*3
thrshld	equ	$019000	;-35dB
	move	#pret,r0	;for ready message
	move	#10,n0		;on the display
	jsr	ready		    ;go to write to display
	move	#misc+1,r5 	; r5-> former detections
	move	#$a,m2		;r2 mod 11 for energies
	move	#$1,m1		;r1 mod 1 for two groups
	bset	#16,x:(r5)-	;last one = bidon
	bset	#16,x:(r5)+	;last-2 =bidon
rien
	move	x:(r5)-,a	;a=last one
	move	a,x:(r5)+	;last-2=last one
	bset	#16,x:(r5)+	;last one=bidon
	move	x:(r5)+,a	;a= 20ms silence decounter
	move	x:(r5)-,x0		;x0=1
	sub	x0,a
	tst	a	a,x:(r5)-
	jge	<enc		;if not zero, comtinue

;**************************************
;  if big silence,write num and RC,init tempo
;**************************************

	move	#pos,r0		;SPACE
	move	#1,n0		;
	jsr	ready		
	move	#num,r4		;r4 -> ascii(00)	
	move	n1,a		;a=num
	asl	a	#$1,n5	;a= 2*num, N5 == offset for tempo update
	move	a,n4		;n4=2*num
	move	#0,n1		;num=0
	move	#2,n0
	lua	(r4)+n4,r0	;r0=ascii(num)
	jsr	ready		;write num
	move	#ret,r0
	tst	a 	#1,n0
	jeq	nolf
	move	#2,n0
nolf	jsr	ready		
	move	#>tempo,x0
	move	x0,x:(r5+n5)
enc
	endsec


;**********************************************************************
;Section det is linked with this program and contains the acual
;detection routines used for receiving and detecting tones
;**********************************************************************

	section	det 
	endsec


;**********************************************************************
;The next section of code does several things for receiving tones and 
;and also contains the code which genrates the tone when there is an
;key depressed on the RS232 terminal causing an SCI receive interupt.
;**********************************************************************

	section write	
	org	pli:
	xref	ready,misc,keybrd,pret,ret,pos,num,enc
	xdef 	tone,toneptr,generate
;
msk13	equ	$fff800
inv		equ	$d5
	nolist
	include '\dsp56000.asm\ioequ'        
	list


;**************************************
;The current detected number is
;compared with the last detected 
;number to see if it has changed.
;**************************************

	move	n7,y0			;y0 = detected number
	move	x:(r5)-,b		; b = last one
	move	x:(r5),a		; a = last -2
	move 	b,x:(r5)+		; last one -> last -2
	cmp	y0,a	y0,x:(r5)	;y0 -> last one
	jeq	<rien			;nothing if y0 =last-2
	cmp	y0,b			;compare y0 with last one
	jne	<enc			;double dectect necessary

;**************************************
; number detected and written
;**************************************


	move	n1,r4		;r4= num
	move	x:(r7+n7),x0	;x0= ascii code of detected number
	movep	x0,x:M_STXL	;write code to RS232 terminal
	lua	(r4)+,n1	;increment n1 (num counter)
	move	#>tempo,x0  	;init tempo
	move	x0,x:(r5+n5) 
	jmp	<enc		;go to another detection

	jmp past

;**************************************
;input and generate subroutine
;which is called at the SCI interupt
;vector location.
;All register and pointers which are
;used in this subroutine are stored 
;to memory first so that the correct
;values may be restored at the end
;before returning to the program.
;**************************************



tone
   ;   save register state
	move	a,l:$61
	move 	x,l:$62
	move	n4,y:$63

   ;   receive data from sci port
	movep	x:M_SRXL,a

	jsr	toneptr

	move	#$f10,x0	; $f10 identifies bad i/o
	cmp	x0,a

	jeq notone

   ;   save register state
	move 	b,l:$64
	move	y,l:$65
	move	r3,y:$66
	move	r4,y:$67
	move	r5,y:$68

	jsr generate

   ; restore second save
	move	l:$64,b
	move	l:$65,y
	move	y:$66,r3
	move	y:$67,r4
	move	y:$68,r5
notone 	

   ; restore first save
	move	l:$61,a
	move 	l:$62,x
	move	y:$63,n4
	rti

;**************************************
;subroutine which determines the
;digit from the ascii input
;this is done by comparing the ascii
;input to the ascii hex representation
;of 0-9, a-d and the * and #. If there
;is no match then there is no tone 
;generated.
;If there is a match then the n4 
;register will contain the location
;tone coefficients to be used for
;generation.
;**************************************


toneptr
	move 	#>$39,x0
	cmp	x0,a	#>$30,x0
	jgt	alpha
	cmp	x0,a
	jlt 	punt1
	sub	x0,a
	move 	a1,n4
	rts

alpha
	move 	#>$61,x0
	cmp	x0,a	#>$64,x0
	jlt	badio
	cmp	x0,a	#>$57,x0
	jgt 	badio
	sub	x0,a
	move	a1,n4
	rts


punt1
	move	#>$23,x0
	cmp 	x0,a
	jne	punt2
	move	#$e,n4
	rts


punt2
	move 	#>$2a,x0
	cmp 	x0,a
	jne	badio
	move 	#$f,n4
	rts

badio
	move 	#$f10,a
	rts
	

;**************************************
;The generate subroutine actually 
;generates the points in the tone
;and then compresses the data and
;outputs it to the SSI port.  An
;second order oscillator is used to
;generate the tones. Each tone only
;needs one coefficient.
;**************************************

generate
	move	#$dd,r3
	move	#$e0,r4
	move	#$da,r5
	move	l:(r4+n4),x
	move	#>$400000,y1
	clr	a	y1,y0
	clr	b 	y0,x:(r5)+

   ;   some clue goes here
	do 	#<$360,loop1
	mac	-y0,x0,a
	neg	a
	mac	y0,x0,a
	mac	-y1,x1,b
	neg	b
	mac	y1,x1,b	
	tfr	y0,a	a,y0
	tfr	y1,b	b,y1
	move 	x0,x:(r5)-	b,y:(r3)+
	move	y1,y:(r3)+
	move	x:(r5)+,x0 	a,y:(r3)
	mpy	x0,y1,b
	mac	x0,y0,b
	move 	b1,y:$fffe
	tfr	b,a		#msk13,x0
	abs	a
	and	x0,a	#<inv,y1
	do 	#8,enloop
	jes 	<quit
	asl	a
enloop
	jmp	<seg
quit	lsl	a
	move 	lc,a2
	enddo
seg	rep	#3
	asr	a
	lsl	b
	ror	a
	eor	y1,a
	tfr 	a,b	b,a
	movep	b1,x:M_TX
	move	y:(r3)-,a
	move	y:(r3)-,y1
	move	x:(r5),x0	y:(r3),b     
	rep	#<$4c9	
	nop
loop1
	rts

past
	endsec
	end
