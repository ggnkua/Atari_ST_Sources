;************************************************************
; file:sxxevb.asm                                           *
;                                                           *
; Read DSP56ADC16, correct for sin(x)/x of DAC, and write     *
; the PCM-56 D/A via the SSI TX register.  This is a        *
;  polled looping routine.                                  *
;                                                           *
;************************************************************

; Written by Charlie Thompson 9/27/88 - Rev 1.0 11/1/88
        
        opt     nomd,nocex,nocm,nomex   

        page 132

        include '48compeq'      ;FIR filter coefficient file

;  ---------------Constants and memory allocation------------------

ntaps   equ     50

        org x:0

firdata dsm ntaps       ;FIR shift register storage



;------------------------------------------------------------------

; FIR coefficient macro places the coefficients of the included file
; in y memory at location 'fircoef'
        
        org y:0

fircoef filtcoeff                       ;invoke the coefficient macro


; Program start address

     org     p:$40

; Set up ADS board in case of force break instead of force reset

                movep #0,x:$FFFE        ;set bcr to zero
                movec #0,sp             ;init stack pointer
                movec #0,sr             ;clear loop flag

;       set up register useage for FIR filter 
   
        move    #firdata,r0     ;point to filter data shift register 
        move    #ntaps-1,m0     ;mod(ntaps) 
        move    #fircoef,r4     ;point to filter coefficients 
        move    #ntaps-1,m4     ;mod(ntaps) 

; Set up the SSI to get data from the 
; The following code sets port C to function as SCI/SSI

                move #$0,a0                     ;zero PCC to cycle it
                movep a0,x:$FFE1
                
                move #$0001ff,a0
                movep a0,x:$FFE1                ;write PCC
                
; The following code sets the SSI CRA and CRB control registers for external
; continuous clock, synchronous, normal mode.

                move #$004000,a0                ;CRA pattern for word length=16 bits
                movep a0,x:$FFEC

                move #$003200,a0    ;CRB pattern for continous ck,sych,normal mode
                movep a0,x:$FFED    ;word long frame sync: FSL=0;ext ck/fs 

; Sample rate is controlled by DSP56ADC16 board.   

poll            move #$ffff00,x0        ;mask for zeroing out lower 8 bits              

;**********************************************************************
; Actual read A/D and write D/A loop  with sin(x)/x compensation FIR  *
;**********************************************************************

; The following routine reads the DSP56ADC16 and processes samples through
; a sin(x)/x compensation FIR (for D/A zero order hold correction) and
; writes the result to the PCM-56 D/A.

; The following code polls the RDF flag in the SSI-SR and waits for RDF=1
; and then reads the RX register to retrieve the data from the A/D converter.

                jclr #7,x:$FFEE,poll    ;loop until RDF bit = 1
                movep x:$FFEF,a         ;get A/D converter data

                and x0,a                                ;mask off lower 8 bits of 24 bit word


;----------FIR sin(x)/x correction filter routine------------

;This routine provides compensation for sin(x)/x droop of the D/A 
;zero order hold effects.  The coefficients are set up for 48 KHz 
;output sampling rate. Therefore the DSP56ADC16 should output data at 48 KHz
;This filter gives approximately 3dB of boost near Fs/2.
 
        ; FIR filter iteration for one input sample point 
        ; Should leave pointer in correct position in modulo buffer 
 
        move   a1,x0                                    ;move sample to x0
        clr     a    x0,x:(r0)+  y:(r4)+,y0     ;save first sample, get 1st coeff 
        rep     #ntaps-1                                        ;do all but last tap 
        mac     x0,y0,a  x:(r0)+,x0  y:(r4)+,y0  
 
        ; do the last tap based on data from parallel move above 
 
             macr    x0,y0,a  (r0)-             ;back up r0 by one due to post inc 

 
; Write the FIR output to the PCM-56 DAC

                move a,x:$FFEF                  ;write the PCM-56 D/A via SSI xmt reg.
                jmp poll                                ;loop indefinitely
                end
