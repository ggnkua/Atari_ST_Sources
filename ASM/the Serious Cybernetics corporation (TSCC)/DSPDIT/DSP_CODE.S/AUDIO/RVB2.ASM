;   filename: RVB2.ASM
;
;
;	This code is an optimized version of the reverberation algorithm
;	found in file RVB1.ASM.  This program makes use of the parallel
;	move functionality of the 56001.  While this tends to make the
;	code less readible, it does increase its speed.  This version
;	is intended to run on the DSP56000ADSx (Application Development
;	System) board rev #2, with memory expansion.  The memory should 
;	be configured figured for 8K p-memory, 16K x-memory, 8K y-memory.
;	
;	Further gains in algorithm speed could be realized on boards not
;	constrained by the ADS memory limitations.  For example, due to
;	the need for 4 comb filters' worth of storage (each using about 
;	3500 samples - which takes 4096 samples each after using the DSM
;	statement) to fit into the 16K available for the x memory, we
;	must start at address $0000.  Thus, we are forced to use all the
;	56000's internal memory for sample storage.  Without being forced
;	to start sample storage at $0000, the 56000's internal memory could
;	be used for coefficient storage, allowing better use of parallel 
;	x and y moves.
;
;				Motorola DSP Group
;				Austin, Texas
;
;**************************************************************************
; This program was originally available on the Motorola DSP bulletin board
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola
; DSP Operation, 6501 William Cannon Dr. W Austin, Texas  78735-8598.
;**************************************************************************
;--------------------------------------------------------------------------
;	This reverberation program is a variation of the reverberation
;	system and structures as described by James Moorer's article entitled
;	 'About this Reverberation Business', Computer Music Journal,
;	 3(2):13-28, 1979
;
;	Structure is:
;							.----------.
;			     .------------.   .-----.	| All Pass |
;			  +->| Comb Filter|-->| SUM |-->| Reverb   |
;   Note: All Comb	  |  |   #1       |   '-----'	|	   |
;	  Filters	  |  '------------'   ^  ^  ^	'----------'
;	  Have a 1st	  |  .------------.   |  |  |	     |
;	  Order IIR 	  |->| Comb Filter|---+  |  |	 .---V---.
;	  LPF in their	  |  |   #2       |      |  |	 | align |
;	  feedback	  |  '------------'      |  |	 | delay |
;	  loop		  |  .------------.      |  |	 '---|---'
;			  |->| Comb Filter|------+  |	     |
;			  |  |   #3       |         |	   -----   reverb	  
;			  |  '------------'         |	    \./     gain
;			  |  .------------.         |	     |
;			  |->| Comb Filter|---------+	     |
;			  |  |   #4       |	     	     |
;			  |  '------------'		     |
;			  |				     V
;	  .------------.  |        FIR gain          .----------.
;   	  |   Early    |  |         |\               |          |
;input -->| Reflection |--+---------|  >------------>|  summer  |--- output
;      |  |    FIR     |	    |/               |          |
;      |  '------------'                             '----------'      
;      |		 		                  ^
;      |		 		                  |
;      |		             dry gain             |
;      |			      |\                  |
;      +------------------------------|  >----------------+
;				      |/
;	
;.............................................................................
;  COMB FILTER SUB STRUCTURE:
;				 .-------.
;      comb i        .-----.     | long  | 		      comb i
;      input  ------>| sum |---->| delay |-------+--------->  output
;		     '-----'     '-------'	 |
;			^		         |
;			|		  	 V
;			|       /| 	      .-----.
;			+-----<   ------------| sum |<--------+
;				\|	      '-----'	      |
;			     fdbck i		 |	     / \  lpf i gain
;			      gain		 V	   /_____\
;			      gain           .----------.     |
;					     | 1 sample |     |
;					     |	delay	|-----+
;					     '----------'
;.............................................................................
;   UNIT (ALL PASS) REVERBERATOR STRUCTURE:
;   based on Schroeder as outlined in Griesinger: 'Practical Processors and
;   Programs for Digital Reverberation', Audio in Digital Times, 7th AES
;   conference, Toronto, Ontario, 1989
;   (the structure outlined in Moorer is a variation of this)
;
;   			        -g
;			     |\
;		 +---------->|  >--------------------------+
;		 |	     |/				   |
;		 |					   |
;		 |					   V
;    unit	 |    .-----.   .--------.       |\     .-----.	      unit
;    input ------+--->| sum |-->| delay  |--+--->|  >-->| sum |-----> output
;		      '-----'   '--------'  |    |/     '-----'
;			 ^		    |	1-g**2
;			 |     g	    | 
;			 |       /|	    |
;			 +-----<  |---------+
;			         \|
;
;...........................................................................
;
;	one multi-tap fir structure - to handle early reflections
;
;	followed by 4 parallel comb (iir) filters (each comb having 
;	a first order LPF in its feedback loop
;	
;	followed by an 'allpass' reverberator whose output is then 
;	delayed so that its first output follows after the last "early
;	reflection" output 
;
;__________________________________________________________________________
;
	opt cex
	page 132

;--------------------------------------------------constant declarations
adc	equ	$ffef		; ADC address
dac	equ	$ffef		; DAC address

ntap	equ	7		; number of taps 
ntapp10 equ	ntap+10		; # taps + 10 for other variables
tapmod	equ	ntapp10-1	; number of taps minus 1	 
dlymx 	equ	4000		; length of delay line in samples

cmbdly1 equ	2205		; COMB FILTER CONSTANTS
cmbdly2 equ	2690		; delay values (in samples)
cmbdly3 equ	3175
cmbdly4 equ	3440

cmbmod1 equ	  3490 	        ; modulo for comb #1 delay line   THESE ARE
cmbmod2 equ	  3490 		;   "         "   #2   "   "	  ALSO THE 
cmbmod3	equ	  3490 		;   "         "   #3  "    "	  MAX DELAYS
cmbmod4	equ	  3490 		;   "         "   #4  "    "	  ALLOWED FOR
				;				  CHOSEN DSM
				;				  VALUE

untrvbdly	equ	265		    ; delay	UNIT (or ALLPASS)
unt_g	     	equ	0.7		    ; gains (g)    REVERBERATOR
neg_g		equ	-unt_g		    ;	    (-g)
one_m_g2	equ	(1-unt_g*unt_g)	    ;	"   (1-g**2)


cmb_g		equ	0.86		; (OVERALL) COMB FILTER FEEDBACK GAIN 
					; controls reverb decay time: smaller
					; values give quicker decay, larger
					; values yield slower decay

lpf1		equ	0.408		; lpf filter coefficient in the 
lpf2		equ	0.448		; feedback loop of the combs,
lpf3		equ	0.476		; these LPF's simulate the high freq
lpf4		equ	0.496		; attentuation in real acoustic reverb

fdbck1		equ	cmb_g*(1-lpf1)	; actual comb feedback gain
fdbck2		equ	cmb_g*(1-lpf2)	; is determined by the lpf filter
fdbck3		equ	cmb_g*(1-lpf3)	; coefficient and the overall feed-
fdbck4		equ	cmb_g*(1-lpf4)	; back gain to insure stability


aligndly		equ	1305   	; alignment delay (see diagram above)
alignmod		equ	1390	;     "     mod

	
reverbg		equ	0.35		; reverberation output gain value
firg		equ	0.15		; early rflctn FIR output gain value
dryg		equ	0.9999-(reverbg+firg) ; dry signal gain is rest  
					; CHOOSE THE MIX YOU LIKE


	org x:0
chead1	dsm 3500		; allocates 3500 data spaces for use as
chead2	dsm 3500		; comb filter tap delay lines, CHEAD1 refers
chead3	dsm 3500		; to the Comb filter HEAD (beginning) for 
chead4	dsm 3500		; filter #1  

	org x:$0f00
ofst_bf	dsm	ntapp10		; this reserves "ntap" contiguous addresses
	org x:ofst_bf		; starting at the closest appropriate modulo
ofst0	dc	1		; x address space.  Then starts filling the 
ofst1	dc	877		; offset buffer at this location with   
ofst2	dc	1561		; the right delay values for the 
ofst3	dc	1716		; EARLY REFLECTION FIR
ofst4	dc	1826
ofst5	dc	3083	  ; IMPORTANT - to get no delay for the first 
ofst6   dc	3510	  ; early reflection, use a "1".  This is due the use
			  ; of an instruction code pre-decrement, a "0" value 
			  ; will cause a maximum delay equal to the tap delay
			  ; line length

untdly	dc	untrvbdly	; define the UNIT REVERBERATOR delay
untmod	dc	untrvbdly-1	; modulo for    "         "

algndly	dc	aligndly
algnmod	dc	alignmod

	org y:$0f00
gain_bf dsm ntapp10
	org y:gain_bf		; starting at y address zero this reserves
				; "ntap" contiguous addresses then starts
				; filling these addresses with the desired
gain0	dc	0.213		; tap "gain" values for EARLY REFLECTION FIR
gain1	dc	0.217		; recommended by moorer
gain2	dc	0.174		;
gain3	dc	0.135		; it is recommended to keep many early 
gain4	dc	0.153		; reflection returns, as these are fed into
gain5	dc	0.157		; comb filters, than can contribute greatly
gain6	dc	0.051		; to the later impulse response density
c1g2	dc	fdbck1
c2g2	dc	fdbck2
c3g2	dc	fdbck3
c4g2	dc	fdbck4
c1out	ds	1
untg2	dc	neg_g
untg3	dc	one_m_g2
untg1	dc	unt_g
firgain	dc	firg
drygain	dc	dryg
rvbgain	dc	reverbg

	org y:0
c1g1	dc	lpf1		; comb #1 g1 (LPF gain)
c2g1	dc	lpf2		;      #2      
c3g1	dc	lpf3		;      #3
c4g1	dc	lpf4 		;      #4


sample	 ds 1			; input sample storage address
firout   ds 1			; early ref FIR OUTput storage address

				; COMB filter    output storage address
c2out  ds 1			;  "      "   #2   "       "       "

lpfst1	ds 1			;  "	  "   #1 Low Pass Filter state
lpfst2	ds 1			;  "	  "   #2  "    "    "      "
lpfst3  ds 1			;  "	  "   #3  "    "    "      "
lpfst4	ds 1			;  "	  "   #4  "    "    "      "

				; allocates modulo memory for the unit
udlyln	dsm	300		; (allpass) reverberator delay line 

algndlyln dsm	1400		; allocates modulo memory for alignment delay  
				; line

dlyline	dsm dlymx		; allocates mod memory for the FIR delay line

;--------------------------------------------------------------------------
     org     p:$40		; program start address

; Set up ADS board in case of force break instead of force reset
       movep #0,x:$FFFE         ;set bcr to zero
       movec #0,sp              ;init stack pointer
       movec #0,sr              ;clear loop flag

; Set up the SSI for operation with the DSP56ADC16EVB
; The following code sets port C to function as SCI/SSI
       move #$0,a0              ;zero PCC to cycle it
       movep a0,x:$FFE1
       move #$0001ff,a0
       movep a0,x:$FFE1         ;write PCC

; The following code sets the SSI CRA and CRB control registers for external
; continuous clock, synchronous, normal mode.
       move #$004000,a0         ;CRA pattern for word length=16 bits
       movep a0,x:$FFEC
       move #$003200,a0    ;CRB pattern for continous ck,sych,normal mode
       movep a0,x:$FFED    ;word long frame sync: FSL=0;ext ck/fs 

; -------------------------------------------------------------------------
				; initialize registers MO,RO, etc
	move #dlymx-1,m0	; tap line modulus
	move #dlyline,r0 	; start of delay line
	move #0,n0	 	; 

	move #tapmod,m1		; tap gain line modulo
	move #gain_bf,r1 	; tap gain & tap delay pointer

	move #cmbmod1,m2	; initialize the modulo registers
	move #cmbmod2,m3	; for comb filter buffers 1 thru 5
	move #cmbmod3,m4
	move #cmbmod4,m5

	move #cmbdly1,n2	; initialize the offset register
	move #cmbdly2,n3	; for Comb filters 1 thru 5
	move #cmbdly3,n4
	move #cmbdly4,n5

	move #chead1,r2		; initialize the pointer values for
	move #chead2,r3		; Comb filters 1 thru 5
	move #chead3,r4
	move #chead4,r5

	move x:algnmod,m6	; initialize alignment delay line
	move x:algndly,n6	; offset, modulo, and pointer registers
	move #algndlyln,r6

	move x:untmod,m7	; initialize unit reverberator (allpass)
	move x:untdly,n7	; offset, modulo, and pointer registers
	move #udlyln,r7

;---------------------------------------------------------------------------
; The following code polls the RDF flag in the SSI-SR and waits for RDF=1
; and then reads the RX register to retrieve the data from the A/D converter.
; Sample rate is controlled by DSP56ADC16 board.   

poll    jclr #7,x:$FFEE,poll     ;loop until RDF bit = 1
        movep x:adc,a            ;get A/D converter data
;---------------------------------------------------------------------------
	asr a
	asr a			; obtain data sample 
				; and shift right for headroom
	move a,y:sample		; keep dry sample

;  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
; FIR for early reflections
	move a,y:(r0)-		; push sample into delay line
	clr a	x:(r1),n0	; clr A and load offset into N0
	do #ntap,fir	 	; loop over the (ntaps-1),exclude fb tap now
	   move y:(r1)+,y1	;  "   "   "   gain   "      "  Y
	   move y:(r0+n0),x1	; get delayed sample
	   mac x1,y1,a	x:(r1),n0 ; MAC gain and sample & update offset
fir  	move a,y:firout		; save FIR OUTput to y memory
;  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
; COMB 1
	move x:(r2+n2),b	; get delayed sample & put in b
	move b,y:c1out		; move output to y memory space

	move y:c1g1,x1			; get LPF filter coeff
	move y:lpfst1,y1		; get LPF filter state
	mac x1,y1,b	y:(r1)+,x1	; compute LPF output
	move b,y:lpfst1			; save LPF output to LPF state

	move b,y1			; put LPF output in Y1
	mac x1,y1,a	x:(r3+n3),b	; compute feedback term in A
	move a,x:(r2)-			; store output into delay queue

;  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
; COMB 2
	move y:firout,a		; comb filter #1 with LPF in feed back
	move b,y:c2out		; move output to y memory space

	move y:c2g1,x1			; get LPF filter coeff
	move y:lpfst2,y1		; get LPF filter state
	mac x1,y1,b	y:(r1)+,x1	; compute LPF output
	move b,y:lpfst2			; save LPF output to LPF state

	move b,y1			; put LPF output in Y1
	mac x1,y1,a	x:(r4+n4),b	; compute feedback term in A
	move a,x:(r3)-			; store output into delay queue

;  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
; COMB 3
	move y:firout,a		; comb filter #1 with LPF in feed back
	move b,x0

	move y:c3g1,x1			; get LPF filter coeff
	move y:lpfst3,y1		; get LPF filter state
	mac x1,y1,b	y:(r1)+,x1	; compute LPF output
	move b,y:lpfst3			; save LPF output to LPF state

	move b,y1			; put LPF output in Y1
	mac x1,y1,a	x:(r5+n5),b	; compute feedback term in A
	move a,x:(r4)-			; store output into delay queue
;  -  -  -  -  -  -   -    -    -    -   -   -   -    -   -     -   - 
; COMB 4
	move y:firout,a		; 
	move b,y0

	move y:c4g1,x1			; get LPF filter coeff
	move y:lpfst4,y1		; get LPF filter state
	mac x1,y1,b	y:(r1)+,x1	; compute LPF output
	move b,y:lpfst4			; save LPF output to LPF state

	move b,y1			; put LPF output in Y1
	mac x1,y1,a	y:(r1)+,x1	; compute feedback term in A,c1out to x1
	move a,x:(r5)-			; store output into delay queue
;  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
	move y:c2out,a		; add output of add four combs
	add x1,a       		;  c2out + c1out
	add x0,a	y:(r7+n7),x0	   ; +c3out
	add y0,a	y:(r1)+,y1	   ; +c4out

;	asr a	
;  -  -  -  -  -  -  -  -  -   -   -      -   -    -   -  -  -    -  
; 				all pass unit reverberator				
	move a,x1
	mpy x1,y1,b	y:(r1)+,y1

	mac x0,y1,b	y:(r1)+,y1	; MAC into b for output (B CONTAINS OUTPUT)
	move b,y:(r6)-

	mac x1,y1,a	y:(r6+n6),y1
	move a,y:(r7)-		; put new+g*delayed into delay line/inc r7
;  -    -     -     -     -     -     -     -     -     -     -      -     -
	move y:rvbgain,y0
	mpy y1,y0,a	y:(r1)+,x1

	move y:firout,y1
	mac x1,y1,a	y:(r1)+,x1

	move y:sample,y1	; mix in the dry sample
	mac x1,y1,a		; A now contains the output sample
	asr a
;  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
; Write DSP56ADC16 A/D converter data to the PCM-56

           move a,x:dac          ;write the PCM-56 D/A via SSI xmt reg.
           jmp poll                ;loop indefinitely

           end
     
