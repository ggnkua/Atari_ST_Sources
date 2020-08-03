		page	132

;******************************************************
;******************************************************
;*                                                    *
;*               DUAL 10-BAND IIR BAND-               *
;*           PASS FILTER GRAPHIC EQUALIZER            *
;*                                                    *
;******************************************************
;******************************************************
;
;**************************************************************************
; This program was originally available on the Motorola DSP bulletin board
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola
; DSP Operation, 6501 William Cannon Dr. W Austin, Texas  78735-8598.
;**************************************************************************
;--------------------------------------------------------------------------
;********************************
;*  SSI and other I/O EQUATES	*
;********************************

START		EQU	$0040
M_IPR		EQU	$FFFF
M_BCR		EQU	$FFFE
M_CRA		EQU	$FFEC
M_CRB		EQU	$FFED
M_PCC		EQU	$FFE1
M_SR		EQU	$FFEE
M_TX		EQU	$FFEF
M_RX		EQU	$FFEF

 				
;********************************
;*  RESET VECTOR                * 
;********************************

		ORG	P:$0000
		JMP	START


;********************************
;*  SSI RCV INTERRUPT VECTOR    * 
;********************************

		ORG	P:$000C
		JSR	LRTEST
		ORG	P:$000E
		JSR	LRTEST



;********************************
;*  MAIN PROGRAM                *
;********************************

		ORG	P:START

;-------------------
;    Mask Interrupts
;-------------------
		ORI	#$03,MR	

;-----------------------
;    Initialize SSI Port		
;-----------------------
		MOVEP	#$3300,X:M_BCR	;3 wait states for ADC and MUX.
		MOVEP	#$3000,X:M_IPR	;SSI RCV INT priority level.
		MOVEP	#$6000,X:M_CRA	;Set SSI word length = 24. 
       		MOVEP	#$3200,X:M_CRB	;Set SSI to synchronous,
					;and enable RE and TE.		
		MOVEP	#$01FF,X:M_PCC	;Turn on SSI Port.

;-----------------------------------------------
;   Move constants from P:mem to X:mem and Y:mem
;-----------------------------------------------
	
		MOVE	#$18D,R2	;** Filter Coefficients.
		MOVE	#$20,R3
					;Table located at X:$20.
		DO	#30,COLOOP	;Length of table = 30.
		MOVE	P:(R2)+,X0	;Order is ... beta, alpha,
		MOVE	X0,X:(R3)+	;gamma for each band.
COLOOP
	
		MOVE	#$1AB,R2        ;** Filter Gain Look-up.
		MOVE	#$40,R3
					;Table located at X:$40.
		DO	#32,FGLOOP	;Length of table = 32 (5 bits).
		MOVE	P:(R2)+,X0	;Minimum value is -.2, maximum
		MOVE	X0,X:(R3)+	;value is 0.999, center value is 0.
FGLOOP

		MOVE	#$1CB,R2        ;** Volume Gain Look-up.
		MOVE	#$60,R3
					;Table located at X:$60.
		DO	#32,VGLOOP	;Length of table = 32 (5 bits).
		MOVE	P:(R2)+,X0	;Minimum value is 0, maximum
		MOVE	X0,X:(R3)+	;value is 0.9999.
VGLOOP
		
		MOVE	#$1EB,R2        ;** Mux Sel Address.
    		MOVE	#0,R3
					;Table located at Y:$00.
		DO	#21,MSLOOP	;Length of table = 21.
		MOVE	P:(R2)+,X0	;These are the MUX select addresses
		MOVE	X0,Y:(R3)+	;for each of the 21 slide pots.
MSLOOP
	
	
;-------------------------
;    Set runtime variables
;-------------------------
		MOVE	#$200000,X0	;Constants used for data scaling.
		MOVE	X0,X:>$1D
		MOVE	#>$80,X0
		MOVE	X0,X:>$1E


;------------------------------------
;    Clear x(n) and y(n) table arrays
;------------------------------------
		CLR	A	  	;Clear Y:$20 to Y:$BF.
		MOVE	#$20,R2		
					;This area is used for runtime
		DO	#$A0,XYNCLR	;tables, x(n) and y(n).
		MOVE	A,Y:(R2)+	;X:$20..$22 - x(n) left chan.
XYNCLR					;X:$40..$42 - y(n) left chan. 31 Hz.
					;X:$44..$46 - y(n) left chan. 62 Hz.
					; ....
					;X:$60..$62 - y(n) left chan. 16 kHz.
			    
					;X:$30..$32 - x(n) right chan.
  					;X:$80..$82 - y(n) right chan. 31 Hz.
					;X:$84..$86 - y(n) right chan. 62 Hz.
					; ....
					;X:$A0..$A2 - y(n) right chan. 16 kHz.


;-------------------------------
;    Clear g(n) and SP(n) arrays
;-------------------------------
		CLR	A		;Clear X:$00 to X:$14.
		MOVE	#0,R2		;This is gain array which contains
					;fractional gain value from look-up
		DO	#21,GNCLR	;table used to scale filtered band.
		MOVE	A,X:(R2)+
GNCLR
		MOVE	#$80,R2		;Clear X:$80 to X:$94.
					;This is 8-bit value read from
		DO	#21,SWNCLR	;ADC slide pots.  This value when
		MOVE	A,X:(R2)+	;reduced to 5 bits is used as an
SWNCLR					;index into gain lookup table at
                                        ;X:$40.  The value from lookup table
					;is a 24-bit fraction which is stored
					;at X:$00..$X:$14.
                                         

;--------------------------------------------------
;    Setup Register Defaults for Interrupt Routines
;--------------------------------------------------

		MOVE	#$40,R4		;** Yi(n):L-ch		
		MOVE	#4,N4
		MOVE	#$80,R6		;** Yi(n):R-ch		
		MOVE	#4,N6
		MOVE	#$20,R5		;** X(n):L-ch		
		MOVE	#2,M5
		MOVE	#$30,R7		;** X(n):R-ch		
		MOVE	#2,M7
			     
		MOVE	#$20,R0		;** IIR Coeff
		MOVE	#29,M0
		MOVE	#0,R3		;** Gain Coeff
		MOVE	#20,M3
    		MOVE	#$80,N3

       
;-----------------------
;    Init SSI Interrupt		
;-----------------------
       		MOVEP	#$B200,X:M_CRB	;Enable SSI (RIE) interrupt.
		ANDI	#$FC,MR		;Unmask all interrupts.
		

;-----------------------------------
;    Main Loop to Monitor Slide Pots
;-----------------------------------

LOOP1		MOVE	#$40,R2	 	;R2 points to gain lookup table.

		DO	#21,BPCHAN	;Scan all 21 pots.
  		MOVE	Y:(R3),Y1	;MUX select address of pot.

		MOVE	Y1,Y:$8000	;Select MUX channel.
		DO	#200,ADC_RD1	;Wait for analog MUX to stabilize.
		NOP
ADC_RD1
		
		MOVE	Y:$1000,B	;WR strobe to ADC (starts data
		NOP			;conversion).
		NOP			;Note: A15 tied to WR of ADC.
		MOVE	Y:$8000,B
		DO	#500,ADC_RD2	;Wait for conversion ADC conversion.
		NOP
ADC_RD2
	
		CLR	B
		MOVE	Y:$8000,B	;Read slide pot data from ADC.

		MOVE	#>$FF,X1	;Mask off upper 16 bits.
		AND	X1,B
		MOVE	B1,X1		;X1 now contains 8-bit pot value.
			
		MOVE	X:(R3+N3),Y1	;Previous pot value.
		SUB	Y1,B
		ABS	B		;If absolute value of difference
		MOVE	#>9,Y1		;is less than 9, then skip.

		CMP	Y1,B		;Note: 9 is rather arbitrary.
		JMI	SKIP

		MOVE	X1,X:(R3+N3)	;If greater than 9, than update
SKIP		MOVE	(R3)+		;X:($80+pot_index).
BPCHAN					;This comparsion eliminates jitter
       		NOP			;about a point.
					;End of 21 pot scan.


		DO	#20,BPCHAN2	;For all pots except volume control.

		MOVE	X:(R3+N3),X1	;Load X1 with slide pot value.
		MOVE	X1,B

      		ASR	B		;Reduce to 5-bit value for gain
		ASR	B		;table lookup.
		ASR	B

		MOVE	B1,N2
		NOP
		MOVE	X:(R2+N2),X1	;Load X1 with fractional value 
       					;from table lookup.
		MOVE	X:(R3),B	;Compare gain fraction to previous
		CMP	X1,B		;value in X:(R3).
		JEQ	NOCHNG		;Skip if no change.
		JGT	NSLOPE		;If new value is greater than
					;previous value, go to negative
					;slope routine.

PSLOPE		MOVE	#0.0001,Y1	;Positive slope routine.
PRAMP  		ADD	Y1,B		;Increment previous gain value
		MOVE	B,X:(R3)	;by 0.0001 towards latest value
					;read from slide pot.
		CMP	X1,B		;Continue updating this value
		JLT	PRAMP		;until previous value exceeds
					;new value.
	      	JMP	NOCHNG		;Exit positive slope routine.
					;Note: In the course of this loop,
					;the SSI interrupt will occur many
					;times, so that the band-pass
					;filter response gain will be ramped
					;smoothly to its new value.  Thus,
					;clicking noises generated from a
					;coarse 5-bit gain table will be
                                        ;eliminated.

NSLOPE		MOVE	#-0.0001,Y1	;Negative slope routine.
NRAMP		ADD	Y1,B		;Same as above but negative ramp
		MOVE	B,X:(R3)	;to new gain value.
		CMP	X1,B
		JGT	NRAMP

NOCHNG		MOVE	X1,X:(R3)	;Update gain table with latest value
   		MOVE	(R3)+		;read from slide pot.
BPCHAN2
					;Continue for the all 20 of the
					;band-pass slide pots.

VOLUME		MOVE	#$60,R2		;Pot 21 (volume) is treated
  		MOVE	X:$94,B         ;seperately since it uses a different
		ASR	B		;gain lookup table.
		ASR	B		;Reduce 8-bit value from ADC volume
		ASR	B		;slide pot to 5-bits.

		MOVE	B1,N2		;Use this value for index into
		NOP			;lookup table.
		MOVE	X:(R2+N2),X1	;X1 now contains volume gain
	                                ;fraction.
		MOVE	Y:$1E,B		;Y:$1E is previous value of volume
		CMP	X1,B		;gain.
		JEQ	NOCHNG2		;If it has not changed, jump.
		JGT	NSLOPE2		;If it is different, decide whether
					;to ramp negative or positive.
PSLOPE2		MOVE	#0.00005,Y1	;Positive slope routine for volume.
PRAMP2 		ADD	Y1,B		;Increment previous value by 0.00005
		MOVE	B,Y:$1E		;towards new value until it has
		CMP	X1,B		;passed new value.  Then exit loop.
		JLT	PRAMP2		;Note: As before, this loop will be
					;interrupted many times by the SSI
					;receive flag full.  The volume gain
					;stored at Y:$1E will ramp smoothly
					;towards its new value.
	      	JMP	NOCHNG2

NSLOPE2		MOVE	#-0.00005,Y1	;Negative slope routine for volume.
NRAMP2		ADD	Y1,B		;Same as before, but ramps in the 
		MOVE	B,Y:$1E		;opposite direction.
		CMP	X1,B
		JGT	NRAMP2

		
NOCHNG2		MOVE	X1,Y:$1E	;Update volume gain value with
		MOVE	(R3)+		;newest value read from slide pot.

		JMP	LOOP1           ;Do everything all over again...
					;continuing slide pot scan loop.


;********************************
;   MAIN INTERRUPT ROUTINE      *
;********************************

LRTEST		JSET	#0,X:M_SR,RIGHT	;Check SC0 (LRCLK from CDP) to
					;determine which channel to process.
				     	
;********************************
;   LEFT CHANNEL SERVICE        *
;********************************

;Save registers

LEFT		MOVE	B,L:$1F		;Save register B.

;Recieve data
		MOVEP	X:M_RX,B        ;Read SSI data.

		MOVE	B,Y0		;Copy SSI data to Y0.
		MOVE	#2,M4		;Set y(n) modulo for 3 words.
		MOVE	#10,R1		;Set R1 index to filter gain values
					;for the left channel.

		CLR	A		X:$1E,X0	;X:$1E = $000080
		MPY	X0,Y0,B		(R4)+		;Scale input data
		MOVE	B0,Y:(R5)			;by 2^16.
		ORI	#$08,MR				;Set scale mode to
							;scale up (left
                                                        ;shift) when data is
							;moved from B to X0.
;----------------------
;    All 10 Filters ...
;----------------------
	DO	#10,LFBAND				;For all 10 bands of
							;left channel.
	CLR	B	  X:(R0)+,X0	Y:(R4)+,Y0	;X0=beta;Y0=y(n-2).
	MAC	-X0,Y0,B  X:(R0)+,X0	Y:(R5)+,Y0	;X0=alpha;Y0=x(n).
	MAC	X0,Y0,B	  Y:(R5)-,Y0			;X0=alpha;Y0=x(n-2).
	MAC	-X0,Y0,B  X:(R0)+,X0	Y:(R4)+,Y0	;X0=gamma;Y0=y(n-1).
	MACR	X0,Y0,B	  X:(R1)+,Y0			;Y0=gain for scaling.
	MOVE	B,X0	  B,Y:(R4)+			;X0=filter reponse.
	MAC	X0,Y0,A	  (R4)+N4			;A=scaled response.
LFBAND							;Continue for all
							;10 left chan bands.

		ANDI	#$F7,MR		;Turn off scale mode.	
		MOVE	#43,M4	      	;Set Yi(n) modulo to wrap around to
					;start of entire y(n) buffer.
;------------------
;    Volume Scaling
;------------------
		MOVE	X:$1D,X0			;X:$1D=$200000.
		MOVE	Y:(R5)+,Y0			;Y0=x(n).
		MAC	X0,Y0,A		Y:$1E,Y0	;scale x(n) down 
		MOVE	A,X0				;by 2^-2.  Add this
                                                        ;in to the total
                                                        ;filter response.
		MPY	X0,Y0,B				;Y0=volume gain.
							;Scale total left
							;data by volume.
		ASL	B		(R4)+N4		
		ASL	B				;Scale result by
							;2^2.
		MOVE	B,X0		#>$8000,Y0	;Now, move B to X0
		MPY	X0,Y0,B				;to force limiting.
							;Scale result down
;----------------------------				;by 2^-8.
;    Output Data to CD Player
;----------------------------

LXMIT		MOVEP	B,X:M_TX  	;Write result to SSI.

		MOVE	L:$1F,B		;Retrieve B register and return.
		RTI


;********************************
;   RIGHT CHANNEL SERVICE       *
;********************************

RIGHT		MOVE	B,L:$1F		    	;Right channel process
						;identical to Left channel,
		MOVEP	X:M_RX,B		;except right channel index
		MOVE	B,Y0			;registers (R6 and R7), and
		MOVE	#2,M6			;first 10 gain table values
		MOVE	#0,R1			;are used instead.

		CLR	A		X:$1E,X0
		MPY	X0,Y0,B		(R6)+
		MOVE	B0,Y:(R7)
		ORI	#$08,MR

;----------------------
;    All 10 Filters ...
;----------------------
		DO	#10,RFBAND
		CLR	B		X:(R0)+,X0	Y:(R6)+,Y0
		MAC	-X0,Y0,B	X:(R0)+,X0	Y:(R7)+,Y0
		MAC	X0,Y0,B		Y:(R7)-,Y0
		MAC	-X0,Y0,B	X:(R0)+,X0	Y:(R6)+,Y0
		MACR	X0,Y0,B		X:(R1)+,Y0
		MOVE	B,X0		B,Y:(R6)+
		MAC	X0,Y0,A		(R6)+N6
RFBAND

		ANDI	#$F7,MR
		MOVE	#43,M6

;------------------
;    Volume Scaling
;------------------
		MOVE	X:$1D,X0
		MOVE	Y:(R7)+,Y0
		MAC	X0,Y0,A		Y:$1E,Y0
		MOVE	A,X0
		MPY	X0,Y0,B

		ASL	B		(R6)+N6
		ASL	B

		MOVE	B,X0		#>$8000,Y0
		MPY	X0,Y0,B

;----------------------------
;    Output Data to CD Player
;----------------------------

RXMIT		MOVEP	B,X:M_TX

		MOVE	L:$1F,B
		RTI


;********************************
;* DATA VARIABLES and CONSTANTS *
;********************************

		ORG	P:$18D

;--------------------                  
;    IIR Coefficients                  
;--------------------                  

;  31 Hz
		DC	.4984587       		;beta
		DC	.0007706594		;alpha
		DC	.9984491		;gamma
;  62 Hz
		DC	.496876			
		DC	.001562013
		DC	.9968368
;  125 Hz
		DC	.4937405
		DC	.003129769
		DC	.9935817
;  250 Hz
		DC	.4876357
		DC	.006182143
		DC	.9870087
;  500 Hz
		DC	.4757282
		DC	.01213592
		DC	.9732514
; 1000 Hz
		DC	.4531951
		DC	.02340247
		DC	.9435273
; 2000 Hz
		DC	.4128511
		DC	.04357446
		DC	.8760584
; 4000 Hz
		DC	.3474929
		DC	.07625358
		DC	.7136286
; 8000 Hz
		DC	.2601072
		DC	.1199464
		DC	.3176087
; 16000 Hz
		DC	.180994
		DC	.159503
		DC	-.4435172


;--------------------------------
;    Filter Gain (G) Coefficients
;--------------------------------

		DC	-0.200
		DC	-0.187
		DC	-0.171
		DC	-0.160
		DC	-0.150
		DC	-0.137
		DC	-0.114
		DC	-0.103

		DC	-0.092
		DC	-0.080
		DC	-0.067
		DC	-0.051
		DC	-0.039
		DC	-0.027
		DC	-0.015
		DC 	 0.000

		DC       0.000
		DC	 0.030
		DC	 0.060
		DC	 0.090
		DC	 0.120
		DC	 0.150
		DC	 0.180
		DC	 0.210

		DC	 0.250
		DC	 0.290
		DC	 0.340
		DC	 0.380
		DC	 0.460
		DC	 0.540
		DC	 0.750
		DC	 0.999

;--------------------------------
;    Volume Gain (V) Coefficients
;--------------------------------

		DC	 0.0000 
		DC	 0.0000 
		DC	 0.0002   
		DC	 0.0005 
		DC	 0.0010 
		DC	 0.0030
		DC	 0.0100 
		DC	 0.0150 

		DC	 0.0200 
		DC	 0.0300 
		DC	 0.0400 
		DC	 0.0600 
		DC	 0.0800 
		DC	 0.1000 
		DC       0.1200 
		DC 	 0.1500 
			        
		DC       0.2000 
		DC	 0.2500 
		DC	 0.3000 
		DC	 0.3500 
		DC	 0.4000 
		DC	 0.4500 
		DC	 0.5000 
		DC	 0.6000 
			        
		DC	 0.7000 
		DC	 0.8000 
		DC	 0.9000 
		DC	 0.9999 
		DC	 0.9999 
		DC	 0.9999 
		DC	 0.9999 
		DC	 0.9999 


;---------------------
;  Slide Pot Addresses
;---------------------
		DC	$70
		DC	$71
		DC	$72
		DC	$73
		DC	$74
		DC	$75
		DC	$76
		DC	$77
		DC	$68	
		DC	$69
		DC	$6A
		DC	$6B
		DC	$6C
		DC	$6D
		DC	$6E
		DC	$6F
		DC	$58
		DC	$59
		DC	$5A
		DC	$5B
		DC	$5C

		END


