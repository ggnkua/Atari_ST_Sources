	title	'DTMF DETECTION '

	page	132,66,0,10





;*******************************************************************

;This section does the actual detection of the dual tones as well

;as checking twist and energy.

;*******************************************************************







        opt     rc,mu,cc

det	IDENT	1,1	;20 ms detection



	section	det

	xref	rien,rdlgn,iiraspi,enerac

nbwdw	equ	80

energy	equ	$20

twogrp	equ	$1C

ratio	equ	$60





;******************************************

;threshold values

;******************************************





tmin	equ	@pow(10,-3.5)	;-35dB

mi8	equ	@pow(10,-.8)	;-8dB =10logX

mi4	equ	@pow(10,-.4)	;-4dB =10logX

mi6	equ	@pow(10,-.6)	;-6dB





;******************************************

; data for the filters

;******************************************





wddr	equ 	0	;w1(n-1) w2(n-1),...

cddr	equ 	0	;b0,b1,a1,a2,b2

	org	yhi:

vratio	dc	0.0125	;1/80

	org	pli:





;******************************************

; the analysis will be done

; on 80 samples at 4 Khz (20 ms)

;******************************************





	move	#energy,r2	;r2 -> 8 energies

	move	#twogrp,r1	;r1 -> low and high group

	move	#keybrd,r7	;r7 -> ASCII code table

	move	#ratio,r6	;r6 -> 1/80

	move	#0,x0	

	rep	#$b		;zero in the 11

	move	x0,x:(r2)+	;energies

;

	do #nbwdw,_edwdw

;

	jsr	rdlgln

	move	a,y1

	jsr	enerac

	move	y1,a



;******************************************

; 6th order Band Pass filter for :

; - dial tone rejection

; - low frequency group selection

; the 15 coefficents from the file

; BPF.LOD are located in the Y data

; memory at locations Y:0..$0E

;******************************************



	move 	#wddr,r0	;r0 -> samples

	move	#cddr,r4	;r4 -> coefficients

	move	#2,n0

	jsr	iiraspi

	move 	a,x:(r1)+	;x1(n) stored in x:(r1)

	jsr	enerac



;******************************************

; High Pass filtering  for :

; - high frequency group selection

; The 15 coefficients from the file

; HPF.LOD are located in the Y data

; memory at locations Y:$0D..1D

;******************************************



	move 	y1,a

	jsr	iiraspi

	move 	a,x:(r1)-	;x2(n) stored in x:(r1)

	jsr	enerac



;******************************************

; 8 Band Pass filtering with 

; 8 full wave rectifiers

;******************************************



	move	#1,n0

	do 	#2,_endfwr	;loop on the 2 frequency groups

	move	x:(r1)+,y1

	do	#4,_endgrp	;loop in a group

	move	y1,a

	jsr	iiraspi		;BP biquad for each frequency

	jsr	enerac

_endgrp

	nop

_endfwr

	jsr	rdlgln

_edwdw



;******************************************

; Threshold test and decision

;  look for high group peak

;******************************************



	move	#energy+10,r2	;r2 -> energy(1633hz)

	move	#>3,x0		;x0 = 3 (index of energy max)

	move	x:(r2)-,y0	;y0 = energy max= energy(1633hz)

	move	x:(r2)-,a	;a  = energy(1477hz)

	move 	#3,r3

	do	#3,edcol

	cmp	y0,a	(r3)-	;compare y0 and a

	jlt	<saut		;jump if a<y0 (no max update)

	move	a,y0 		;if a>y0, y0= new max= a

	move 	r3,x0

saut	move	x:(r2)-,a	;a= next energy to check

edcol

;

;******************************************

;  look for low group peak

;******************************************



	move	#>3,x1	a,y1	;x1 = 3 (index of energy max)

				;y1 = energy max = energy(941hz)

	move	x:(r2)-,a	;a = energy (852hz)

	move #3,r3

	do	#3,edrow

	cmp	y1,a	(r3)-		;compare  y1 and a

	jlt	<sau		;jump if a < y1	(no max update)	  	

	move	a,y1		;if a > y1 ,then y1=a

	move 	r3,x1

sau	move	x:(r2)-,a 	;a = next energy to check

edrow

;

;******************************************

;  test if above minimun threshold

;******************************************



	move 	#tmin,a	;a= threshlod min

	cmp	y0,a	;compare max in low group with threshold

	jgt	<rien	;no detection if below threshlod

	cmp	y1,a 	;compare max in high group with threshold

	jgt	<rien	;no detection if below

;

;******************************************

; computer the detected number: 4 x X1 +X0

; (4 x low freq. index + high freq. index)

;******************************************

; 

	move 	x1,a	;a=x1

	asl	a	;a=2. x1

	asl	a	;a=4. x1

	add	x0,a	;a=4.x1+x0

	move	a,n7	;n7= index in keybrd 

;

;******************************************

; check for the twist 

;******************************************

;

	move	y1,b	;b= low group max

	cmp	y0,b	;compare with high group max

	jge	<lowmax	;jump if low group max energy bigger

;

;******************************************

; high group maxminum value > low group maximum value

; +4 db are allowed

;******************************************

; 

hghmax	move	#mi4,x0	;x0=attenaution

	mpy	x0,y0,a	;a= high group max -4dB

	cmp	y1,a	;compare with high group

	jge	<rien	;no detect if difference > than 8 dB

;

;******************************************

; low group max. can be 8dB higher than high group

;******************************************

;

lowmax	move	#mi8,x1	;x1= attenuation

	mpy	x1,y1,a	;a=low group max- 8dB

	cmp	y0,a	;compare with high group

	jge	<rien	;no detect if difference > than 4 dB

;

;******************************************

; in each group, the max should be

; at least +8 db above the other frequencies

;******************************************

;

	move	#mi8,x1		;x1=attenuation

	mpy	x1,y1,a	#>2,y1

	move	#energy+3,r2	;prepare r2 for coming test

	move	#>1,b	

	move	x:(r2)+,x0

	do	#4,endlw

	cmp	x0,a		;compare with lowmax-8dB

	jge	<lit		;continue if max-8dB bigger

 	asl	b

lit	move	x:(r2)+,x0	;x0=energy



endlw	cmp	y1,b 		;test b;if more than one

	jgt	<rien		;energy is bigger -> no dectect

;

	move	#>1,b

	mpy	x1,y0,a		;a=highmax-8dB

	do	#4,endhg

	cmp	x0,a		;compare with lowmax-8dB

	jge	<lit2		;continue if max-8dB bigger

	asl	b

lit2	move	x:(r2)+,x0	;x0=energy



endhg	cmp	y1,b   		;test b;if more than one

	jgt	<rien		;energy is bigger -> no dectect

;

	endsec

	end

