	title	'MULTICHANNEL DTMF RECEIVER MAIN PROGRAM'

;	SSI in network mode

	page	132,72,0,10

;**************

;;5/31/87 ; ec

; dtmfmstr.asm

;**************

;  Multichannel DTMF receiver master program:

;    	-using the SSI in network mode 

;  	-the SCI is used to display the results

;       

;	Polled I/O version

;

        opt     rc,mu,cc



dtmfmtr	ident	1,1	;main

 

; the following section define the location

; of the data in the X & Y memories

;

;********************************

	section divers

	xdef	keybrd,pret,pos

	xdef	ratio,samples,misc

	xdef	energy,twogrp,wddr,cddr

;

;	Data in internal Y memory

;

	org	xi:0

wddr	dsm	144		; memory of all filters

	org	xi:$90

twogrp	dsm	12		; high and low group input

	org	xi:$c0

energy	dsm	48		; 6*8 energies

;

;	Data in internal Y memory	

;

	org	yi:0

cddr	ds	60		; filter coef.

	org	yi:$40

samples	ds	6		; 6 input samples

	org	yi:$50

keybrd	ds	16		; data for display

pret	ds	61		; data for init display

pos	ds	18		; data for display result

ratio	ds	1		; energy division ratio

	org	yi:$f0

misc	dsm	12		; 6 lastone,lastone-1

;

	endsec

;********************************

;

	section	rezet

start	equ	$40	

	org	p:0

	jmp	<start

	endsec

;

;********************************

	section pcoeff

	xdef	pcddr

;temporary storage of

;filter coef. after bootstrap

	org	p:1

pcddr	dc	$0ac800,$11cc00,$fe9981,$2d8c00,$0ac180 

	dc	$1f6f00,$c4d101,$c69e81,$2fd480,$1f6380 

	dc	$160dc0,$e9f241,$13e480,$000000,$000000

	dc	$20237f,$eeda81,$1a6600,$296000,$201f80 

	dc	$015945,$000000,$c6605b,$3dbdab,$fea6bc

 	dc	$01717e,$000000,$d3990e,$3d967b,$fe8e83 

	dc	$01a283,$000000,$e334fc,$3d4579,$fe5d7e 

	dc	$01b643,$000000,$f46a6f,$3d22a6,$fe49be 

	dc	$021262,$000000,$282537,$3c7574,$fded9f 

	dc	$022cfe,$000000,$3ea63c,$3c5603,$fdd303 

	dc	$025efc,$000000,$54846e,$3c03c1,$fda105 

	dc	$0295d0,$000000,$67b680,$3bad5b,$fd6a31

	endsec

;

;********************************

; the following section transferts data 

; from P to Y memory after the bootstrap

;

	section	transfert

	xref	keybrd,pkeybrd,cddr,pcddr

;

	org	pli:

	move	#keybrd,r4

	move	#pkeybrd,r0

	do	#96,end_trf

	move	p:(r0)+,x0

	move	x0,y:(r4)+

end_trf

	move	#cddr,r4

	move	#pcddr,r0

	do	#60,end_trf1

	move	p:(r0)+,x0

	move	x0,y:(r4)+

end_trf1



	endsec

;********************************

;

	section	initperiph 

 	nolist

	include '\dsp56000.asm\ioequ'        

	list

	org	pli:

;

; SSI configuration:

; -network mode;internal clock;synchronous mode.

; -does not use interrupt but RDF/TDE flags.

; -Alaw expansion is using algln11 and 

;  DSP56001 internal data ROM address X:$180

;

;

acc     equ     $2222           ; external access time X_Y_P_IO

;

;  SSI setup

;**************

ps      equ     0<<M_PSR        ; change 0 to 1 for divide by 8

wl      equ     0<<M_WL0        ; change 0 to 3/1/2 for 24/12/16 bits/word

dc      equ     26<<8           ; used for 27 slots/frame in NW

pm      equ     2               ; to gen the 8x27(cdc)x8(bit)=1.728MHz rate

;**************

;  SCI setup

;**************

wl0	equ	6<<M_WDS0	

sbk	equ	0<<M_SBK

;

; start

;******

; first program PORT A & OPERATING MODE

start	move    #$4,omr		; mode 0 /ROM enable

        movep   #acc,x:M_BCR    ; wait states

;***********

; ssi setup

;***********

; step 1 of initialization of SSI is RESET ( already performed )

; step 2 of initialization of SSI

; start programming the SSI

        movep   #(ps|wl|dc|pm),x:M_CRA  ; PSR=0 , WL=0 , DC=19 , PM=3

        movep   #>$0A3C,x:M_CRB         ; RIE=0 , TIE=0 , RE=0  , TE=0

                                        ; MOD=0 , GCK=0 , SYN=1 , FSL=1

                                        ; *     , *     , SCKD=1, SCD2=1,

                                        ; SCD1=1, SCD0=1, OF1=0 , OF0=0

; start programming the SCI

	movep	#(sbk|wl0),x:M_SCR

        bset    #M_TE,x:M_SCR           ; enable the transmitter ( WDS=0 )

        movep   #269,x:M_SCCR           ; CD=269 for divide by 270

					; 320k/270=1185 baud #1200 baud)

; enable the SSI

	bclr	#4,x:M_PCDDR		;sc1/pc4 input	ack

	bclr	#1,x:M_PCDDR		;txd/pc1 input  busy

	bset	#0,x:M_PCDDR		;PC0 output  reset

        movep   #$1e4,x:M_PCC           ; set CC(8:3) as SSI pins

                                        ; set CC(2;1) as SCI pins

 	endsec

;

;********************************

	section	main1

	org	pli:

; 

	nolist

	include '\dsp56000.asm\ioequ'        

	list

;

	xdef	rien,enc

	xref	ready,misc,keybrd,pret,ret,pos,num,temp

;

; misc. init

;

	bclr 	#0,x:M_PCD		; start reset display

	jsr	temp			;temp

	bset 	#0,x:M_PCD		;end reset display

	jsr	temp			;temp

; 

	move	#pret,r6	;for ready message

	move	#61,n6		;on the display

	jsr	ready		;go to write to display

;

	move	#8,n2		;offset for energies      

	move	#2,n5		;offset for detect/last/lastone

;

	move	#(6*$18)-1,m0	;modulo 8f for filter samples

	move	#11,m1		;r1 mod 12 for two groups

	move	#(6*8)-1,m2	;modulo 48 for energies

	move	#$3b,m4		;modulo 3b for filter coefficient

	move	#$b,m5		;modulo 12 for last-1 & lastone

;

	move	#misc+1,r5 	; r5-> former detections

	rep	#12

	bset	#16,y:(r5)+	;last one &last-2= bidon

;

rien

enc

	endsec

;********************************

;

	section	detect 

; 	the linker will insert the 

;    	detection routine

	endsec

;

;********************************

	section	main2

	org	pli:

	xref	ready,misc,keybrd,pret,ret,pos,num,enc

;

	nolist

	include '\dsp56000.asm\ioequ'        

	list

;

	move	#keybrd,r7	;r7 -> ASCII code table

	move 	#pos,r6

	move	#3,n6

	move	#2,n3

	move	#$40,n4		

	move	#>1,y1

;

	do	#6,_edwrt

; 

	jset	#$10,x:(r5),ryen	;nothing if no detection

;	

; compare with last detection

;

	move	x:(r5),y0		;y0 = detected number

	move	y:(r5)-,b		; b = last one

	move	y:(r5),a		; a = last -2

	move 	b,y:(r5)+		; last one -> last -2

	cmp	y0,a	y0,y:(r5)	;y0 -> last one

	jeq	<ryen			;nothing if y0 =last-2

	cmp	y0,b			;compare y0 with last one

	jne	<enk			;double dectect necessary

;

; number detected and written

;

	move	y0,n7			;n7=  detected number

;

	lua	(r5)-,r5

	move	r6,r3

	move	y:(r7+n7),x0	;x0= ascii code of detected number

	move	x0,y:(r3+n3)	;write code to RS232 terminal

	jsr	ready	    	;go to write to display

	lua	(r6)-n6,r6

	move	n4,a

	jmp	<paseff		; go to another detection

;	

ryen	move	y:(r5)-,a	;lastone->last-2

	move	a,y:(r5)+

	bset	#16,y:(r5)-	;last one=bidon

	move	x:(r5),a

	sub	y1,a

	jne	<paseff

	move	r6,r3

	move	#>$20,x0

	move	x0,y:(r3+n3)

	jsr	ready			;go to write to display

	lua	(r6)-n6,r6

	move	#$ffffff,a

paseff	move	a,x:(r5)+

;

enk	lua	(r5)+n5,r5

	lua	(r6)+n6,r6

;

_edwrt

	jmp	<enc

	endsec

;

;********************************

;	section containing data

;	to be transfered to the Y

;	memory after the bootstrap

;

	section	PtoYmem

	xdef	pkeybrd

	org	pli:

pkeybrd	dc	'1','2','3','A','4','5','6','B','7','8','9'

	dc	'C','*','0','#','D'	

ppret	dc	$0e,$1b,0,'D','I','A','L','E','R','1',':'

	dc	$1b,$0D,'D','I','A','L','E','R','2',':'

	dc	$1b,$1A,'D','I','A','L','E','R','3',':'

	dc	$1b,$80,'D','I','A','L','E','R','4',':'

	dc	$1b,$8D,'D','I','A','L','E','R','5',':'

	dc	$1b,$9A,'D','I','A','L','E','R','6',':'

ppos	dc	$1b,$00+$0A,

	dc	$1b,$0D+$0A,

	dc	$1b,$1A+$0A,

	dc	$1b,$80+$0A,

	dc	$1b,$8D+$0A,

	dc	$1b,$9A+$0A,

pratio	dc	0.0125		;1/80

;

	endsec

;

	end





