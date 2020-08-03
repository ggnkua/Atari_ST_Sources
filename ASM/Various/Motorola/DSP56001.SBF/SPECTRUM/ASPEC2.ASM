          title  'Log-Log Audio Spectrum Analyzer'
;**************************************************************************
;*     Motorola Austin DSP Operation  June 06, 1991                       *
;*                                                                        *
;*       *  ALTHOUGH THE INFORMATION CONTAINED HEREIN,    *               *
;*       *  AS WELL AS ANY INFORMATION PROVIDED RELATIVE  *               *
;*       *  THERETO, HAS BEEN CAREFULLY REVIEWED AND IS   *               *
;*       *  BELIEVED ACCURATE, MOTOROLA ASSUMES NO        *               *
;*       *  LIABILITY ARISING OUT OF ITS APPLICATION OR   *               *
;*       *  USE, NEITHER DOES IT CONVEY ANY LICENSE UNDER *               *
;*       *  ITS PATENT RIGHTS NOR THE RIGHTS OF OTHERS.   *               *
;*                                                                        *
;*  This program originally available on the Motorola DSP bulletin board. *
;*  It is provided under a DISCLAMER OF WARRANTY available from           *
;*  Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735. *
;*                                                                        *

;**********************************************************************
; Real time log-log scale spectrum analyzer program                   *
;**********************************************************************
;   Source file name :        aspec2.asm
;         0.0     Jan.  3 1990
;         1.0     Mar. 23 1990 
;         1.1     Jul. 26 1990      - speed-up for windowing
;         1.2     Oct. 18 1990      - collapsed into single Goertzel sub. 
;         2.0     Feb. 28 1990      - added interrupt driven input
;
; -This program will take in N samples from the DSP56ADC16 sigma delta 
;  converter and perform a DFT routine using Goertzel method.
; -The receive input buffer is filled under interrupt control
; -When the computations for the spectrum are completed, the input
;  buffer (RXBUFF) is copied into D_IN and a new set of computations
;  begin. During this time, RXBUFF continues to get new data samples,but
;  this does not corrupt the buffer move because the oldeset sample is
;  copied before the next input sample overwrites it. All other samples
;  will have adequate time to be copied before changed by the input.
; -Results are sent to a PCM-56 DAC
; -The spectrum is viewed on a scope.
;
; Notes: 60, 0, -60, and -120 dB output reference levels
;    DSP56001 REV C is required for SSI mixed length frame syncs
;    Requires ADC16EVB modified for async SSI
;-----------------------------------------------------------------------------
          page   255,66,3,3,5
          opt    nomd,nomex,nocex

BOOTMODE  equ    ROM                        ;1 == boot from ROM
start     equ    $40                        ;location of main routine
ROMBASE   equ    $4000                      ;load address of ROM - $8000
POINTS    equ    2048                       ;number of input data points($800)
D_IN      equ    0                          ;location of input data table
D_OUT     equ    POINTS                     ;location of output display table
COS_TABL  equ    POINTS/2                   ;sine and cosine table 
SIN_TABL  equ    POINTS/2+POINTS/4
BUF1      equ    POINTS                     ;location for 1024 data buffer
BUF2      equ    POINTS+POINTS/2            ;location for 512  data buffer
BUF3      equ    POINTS+POINTS/2+POINTS/4   ;location for 256  data buffer
WIN_TABL  equ    0                          ;location of Blackman_Harris window
RXBUFF    equ    2*POINTS                   ;location of input data

;----------------------------------------------------------------------------
;            ***** MEMORY MAP *****
;         -X-                       -Y-
;                                   $1800 --------
;                                   $1000 RXBUFFER   
;        $0F00 -----                  .
;        $0E00 BUF3                   .         
;        $0C00 BUF2                   .         
;                                   $0A00  Polynomial Coefficients
;        $0800 BUF1                 $0800  D_OUT
;                                   $0600  SINE   Table
;                                   $0400  COSINE Table
;        $0000 D_IN                 $0000  Window Table
;----------------------------------------------------------------------------

;    MOTOROLA DSP56001 Internal I/O Addresses

m_ipr     equ    $ffff       ;Interrupt Prioroty Register
m_bcr     equ    $fffe       ;Bus Control Register
m_sccr    equ    $fff2       ;SCI Clock Control Register
m_scr     equ    $fff0       ;SCI Control Register
m_tx      equ    $ffef       ;SSI Tx Data Register
m_rx      equ    $ffef       ;SSI Rx Data Register
m_sr      equ    $ffee       ;SSI Status  Register
m_crb     equ    $ffed       ;SSI Control Register A
m_cra     equ    $ffec       ;SSI Control Register B
m_bdr     equ    $ffe4       ;Port-B Data Register
m_bddr    equ    $ffe2       ;Port-B Data Direction Register
m_pcc     equ    $ffe1       ;Port-C Control register


          IF     BOOTMODE==1                ;*** if booting from ROM ***
          MSG    'Building Code for ROM Boot'
;--------------------------------------------------------------------------
;       RESET vector
;       first, move the tables from ROM into data memory
;--------------------------------------------------------------------------
          org    p:0,p:ROMBASE         ;RUN @ P:$0000, LOAD from P:$C000
GO        move   #$C000+(3*WIN_LOC),r0 ;points to start of tables in ROM
          move   #0,r5                 ;destination for tables in Y:
          do     #Tab_Len,_table       ;load all tables..., length <= $FFF
          do     #3,_word              ;3 bytes per word...
          move   P:(R0)+,A2            ;get a byte from P:ROM
          rep    #8                    ;shift it into position...
          asr    A                     ;...to form a 24-bit word
_word                                  
          move   A1,y:(r5)+            ;move complete word into y:memory
_table
          jmp    <SPEC

          ELSE
          MSG    'Building Code for ADM execution'
          org    p:$0C

          ENDIF
;-------------------------------------
;       SSI RX Interrupt vector
;-------------------------------------          
                                       ; *** org    p:$000C,P: ***
          movep  x:m_tx,y:(r1)+        ;input from ADC16
          nop
          movep  x:m_tx,y:(r1)+        ;input from ADC16
          nop
;-------------------------------------
;       SSI TX Interrupt vector
;-------------------------------------          
          movep  y:(r6)+,x:m_rx        ;output to D/A PCM-56
          nop
          movep  y:(r6)+,x:m_rx        ;output to D/A PCM-56
          nop

          DUP    $2C                   ;fill unused vectors w/ nops
          nop
          ENDM

;-------------------------------------
;  Initialization
;-------------------------------------
                                       ;this code s/b @ P:$0040
SPEC      movep  #0,x:m_bcr            ;set bcr to zero
          movec  #0,sp                 ;init stack pointer
          movec  #0,sr                 ;clear loop flag
          movep  #0,x:m_pcc            ;zero PCC to cycle it, reset peripherals
;-----------------------------------------------------------------------
; set the SCI to provide ADC16 clock
;-----------------------------------------------------------------------
          movep  #$1000,x:m_sccr       ;SCCR pattern for sclk= x16 baud rate
          movep  #$2,x:m_scr           ;SCR pattern for sclk= x16 baud rate
;-----------------------------------------------------------------------
; set the SSI to recieve ADC16's output 
; and to transmit to the PCM56 using asynchronous, normal mode. 
;-----------------------------------------------------------------------
          movep  #$4107,x:m_cra        ;CRA pattern for word length=16 bits                                       ;xmit bit rate
          movep  #$B1B0,x:m_crb        ;CRB pattern for cont.clk,async,normal mode 
          movep  #$0001FF,x:m_pcc      ;write PCC, enable peripherals
;--------------------------------------------------------------------------
;       Input sample rate is controlled by DSP56001 SCI via DSPADC16.   
;       Display rate is generated by DSP56001 (Fosc/512)
;--------------------------------------------------------------------------
          move   #D_OUT,r4             ;R4 for write into display buffer
          move   r4,r6                 ;R6 for read  from display buffer
          move   #RXBUFF,r1            ;R1 for write into RCV     buffer
          move   #POINTS/4-1,m4        ;both R4 & R6 use modulus addressing
          move   m4,m6                 ;MOD = buffer length = POINTS/2
          move   #POINTS-1,m1          ;...RCV BUFFER is also MOD addr.
          movep  #$3000,x:m_ipr        ;set SSI interrupt priority
          andi   #$fc,MR               ;unmask  interrupts
                                       ;...after reset, Mx=$FFFF


          page
;---------------------------------------------------------------------------
;                    ********************************
;                    *     MAIN PROGRAM ROUTINE     *
;                    ********************************
;
; The following registers have DEDICATED usage and should not be altered:
;         R1 - input buffer   write pointer   M1 - POINTS   - 1
;         R4 - display buffer write pointer   M4 - POINTS/4 - 1
;         R6 - display buffer read  pointer   M6 - same as M4
;---------------------------------------------------------------------------
;    get the oldest data in the input area and move it into the 
;        input buffer, shifting right 8-bits ( / 256 ) on the fly
;---------------------------------------------------------------------------

top       move   #D_IN,r0              ;pointer to input data buffer
          move   #>$008000,x0          ;scale input data by 1/256 (>> 8)
          move   #$0001,n1
          move   m1,m5                 ;input will use mod. addressing here
          lua    (r1)+n,r5             ;adjust pointer, 
          move   y:(r1),y1             ;get A/D converter oldest data
          mpy    y1,x0,a               ;and compute 1st output
          do     #POINTS,_readin       ;read in 2048 points, interruptable
          mpy    y1,x0,a    y:(r5)+,y1     a,x:(r0)+  ;shift, read, write  
_readin                                               ;...I like it!..
          move   #-1,m5              ;restore linear addressing

;---------------------------------------------------------------------------
; copy first 1024 points to BUF1 with a window function
;         NOTE:  data has been scaled by 1/256 during input
;---------------------------------------------------------------------------
          move   #WIN_TABL,r2          ;pointer to window in Y space
          move   #2,n2                 ;off-set register for every 2nd window
          move   #D_IN,r0              ;pointer to data in X space
          move   #D_IN+(POINTS/2)-1,r3 ;points to last input data point
          move   #BUF1,r5              ;point to 1024-point buffer
          move   #BUF1+(POINTS/2)-1,r7 ;points to end of output data buffer
          move   x:(r0)+,x0                 ;get 1st data point
          move   y:(r2)+n2,y0               ;get 1st window value

          do     #POINTS/4,wind1            ;do 512 pairs of points
          mpy    x0,y0,a     x:(r3)-,x0     ;apply window and get the sample
          mpy    x0,y0,a   a,x:(r5)+        ;apply window to last sample, store early sample
          move               x:(r0)+,x0     ;get next early sample..
          move   a,x:(r7)-   y:(r2)+n2,y0   ;store sample at end of buffer
wind1                                       ;get next window value
;---------------------------------------------------------------------------
;   copy 512 points to BUF2 with a window function
;         NOTE: samples are scaled up by a factor of 2 before storage
;               automatic scaling provides the shift
;---------------------------------------------------------------------------
          move   #WIN_TABL,r2               ;pointer to window in Y space
          move   #4,n2                      ;off-set for every 4-th window point
          move   #D_IN,r0                   ;pointer to data in X space
          move   #D_IN+(POINTS/4)-1,r3      ;points to last input data point
          move   #BUF2,r5                   ;point to 512 size buffer
          move   #BUF2+(POINTS/4)-1,r7      ;points to end of output data buffer
          move   x:(r0)+,x0                 ;get first sample
          move   y:(r2)+n2,y0               ;get first window value

          bset   #9,SR                      ;Scaling mode 2; ASL--> XDB,YDB
          do     #POINTS/8,wind2            ;do first 256 pairs of points
          mpy    x0,y0,a     x:(r3)-,x0     ;apply window, get end sample
          mpy    x0,y0,a   a,x:(r5)+        ;window end sample, store early sample
          move               x:(r0)+,x0     ;scale end sample, get next early sample
          move   a,x:(r7)-   y:(r2)+n2,y0   ;store end sample, get next window value
wind2
;---------------------------------------------------------------------------
;       copy 256 points to BUF3 with a window function
;         NOTE: data samples are scaled up by 2 bits before storage
;               scaling mode provides one bit of shift automatically...
;---------------------------------------------------------------------------
          move   #WIN_TABL,r2               ;pointer to window in Y space
          move   #8,n2                      ;off-set for every 4-th window point
          move   #D_IN,r0                   ;pointer to data in X space
          move   #D_IN+(POINTS/8)-1,r3      ;points to last input data point
          move   #BUF3,r5                   ;point to 512 size buffer
          move   #BUF3+(POINTS/8)-1,r7      ;points to end of output data buffer
          move   x:(r0)+,x0  
          move   y:(r2)+n2,y0               ;get proper window value

          do     #POINTS/16,wind3           ;do 128 pairs of points
          mpyr   x0,y0,a     x:(r3)-,x0     ;windowing
          asl    a
          mpyr   x0,y0,a   a,x:(r5)+        ;windowing
          asl    a           x:(r0)+,x0
          move   a,x:(r7)-   y:(r2)+n2,y0   ;store into input buffer
wind3
;---------------------------------------------------------------------------
;       Apply window to 2048 input data samples -- in place
;         NOTE: data is scaled down by one bit before storage
;---------------------------------------------------------------------------
          move   #WIN_TABL,r7               ;pointer to window     in Y space
          move   #D_IN,r0                   ;pointer to data start in X space
          move   #D_IN+POINTS-1,r2          ;pointer to data end   in X space

          bclr   #9,SR                      ;turn scaling OFF
          bset   #8,SR                      ;scale by ASR 1 bit
          do     #POINTS/2,wind4            ;do first 1024 pairs of points
          move   x:(r0),x0     y:(r7)+,y0   ;get start data and window value
          mpy    x0,y0,a       x:(r2),x0    ;...windowing...get end points
          mpy    x0,y0,a     a,x:(r0)+      ;store into input buffer
          move               a,x:(r2)-
wind4
          bclr  #8,SR                       ;turn scaling OFF
;---------------------------------------------------------------------
;       Place calibrated levels at start of the display table 
;       Levels 60, 0, -60, and -120.0 dB (15 dB/div on 8 div scope)
;---------------------------------------------------------------------
          move   #0.31143,a                 ;  60 dB level for trigger syncing
          clr    b         a,y:(r4)+        ;   0 dB level --> B
          neg    a         b,y:(r4)+        ; -60 dB level --> A
          asl    a         a,y:(r4)+        ;-120 dB level --> A
          move             a,y:(r4)+                  

          stitle             'main data processing loop'
          page       
;----------------------------------------------------------------------------
;  Data Processing Routine (N point DFT using the Goertzel algorithm)
;----------------------------------------------------------------------------
          move   #SIN_TABL+4,r5             ;R5 points to sin Ymem table 
          move   #COS_TABL+4,r3             ;R3 points to cos Xmem table 
;----------------------------------------------------------------------------
;  Run first 256-4 point DFT using the Goertzel algorithm
;----------------------------------------------------------------------------
          move   #D_IN,n2                   ;n2 points to input data Xmem table 
          move   #POINTS/8-4,n3             ;run first 256-4 points DFT
          move   #POINTS-1,n5               ;do 2048 point DFT
          jsr    Goertzel

;----------------------------------------------------------------------------
;  next 128 point DFT using the Goertzel algorithm
;----------------------------------------------------------------------------
          move   #BUF1,n2                   ;n2 points to input data Xmem table 
          move   #POINTS/16,n3              ;run next 128 point DFT
          move   #POINTS/2-1,n5             ;do 1024 points DFT
          jsr    Goertzel

;----------------------------------------------------------------------------
;  next  64 point DFT using the Goertzel algorithm
;----------------------------------------------------------------------------
          move   #BUF2,n2                   ;n2 points to input data Xmem table 
          move   #POINTS/32,n3              ;run next 64 point DFT
          move   #POINTS/4-1,n5             ;do 512 points DFT
          jsr    Goertzel

;----------------------------------------------------------------------------
;  last 64 point DFT using the Goertzel algorithm
;----------------------------------------------------------------------------
          move   #BUF3,n2                   ;n2 points to input data Xmem table 
          move   #POINTS/32,n3              ;run next 64 point DFT
          move   #POINTS/8-1,n5             ;do 256 points DFT
          jsr    Goertzel

          bset   #14,x:m_crb                ;enable SSI (TRE) interrupt
          jmp    top                        ;do main program over again 

          stitle             'Goertzel DFT Routine'
          page
;-------------------------------------------------------------------------
;    Goertzel Algorithm for computing DFT
;  solve for yr + yi = (x(n)+yr'*cosx-yi'*sinx) + i(yr'*sinx+yi'*cosx)
;
;         on entry:  n2 points to the input data buffer in Xmem
;                    n3 contains the number of output points
;                    n5 contains the number of input  points
;                    r3 points to cosine table
;                    r5 points to sine   table
;                    
;-------------------------------------------------------------------------
Goertzel
          do     n3,Goer_out                ;run DFT
          move   n2,r2
          clr    b         y:(r3)+,x1       ;x1=cos(x) from table
          move   b,x0      y:(r5)+,y1       ;y1=sin(x) from table
          move   x:(r2)+,a                  ;a=x(n)
                                            ;x0=yr', y0=yi'
          do     n5,Goer_in
          mac    x0,x1,a     b,y0           ;a=x(n)+cosx*yr'
          mac    -y0,y1,a                   ;a=x(n)+cosx*yr'-sinx*yi'
          mpy    x0,y1,b     a,x0           ;b=sinx*yr'
          mac    y0,x1,b     x:(r2)+,a      ;b=sinx*yr'+cosx*yi'
Goer_in
          mac    x0,x1,a     b,y0           ;a=x(n)+cosx*yr'
          macr  -y0,y1,a                    ;a=x(n)+cosx*yr'-sinx*yi'
          mpy    x0,y1,b                    ;b=sinx*yr'
          macr   y0,x1,b     a1,x0          ;b=sinx*yr'+cosx*yi'
;-------------------------------------------------------------------------
;  Convert to magnitude, in place, putting magnitude
;-------------------------------------------------------------------------
convert   mpy    x0,x0,a     b1,y0          ; A=yr**2,  put b into y0
          mac    y0,y0,a     #<$40,x0       ; A=yr**2+yi**2
          move   a1,y1                      ; transfer sum of squares to Y
          move   a0,y0  
;------------------------------------------------------------------------
;  Take a square root to get the resolution back into to 24 bits.
;   Full Precision Square Root by Polynomial Approximation. 
;   y(y1:y0) = double precision (48 bit) positive input number
;   b = 24 bit output root, x0 = guess, x1 = bit being tested
;------------------------------------------------------------------------
sqrt3     clr    b           x0,x1          ; init root and guess
                                            ; init bit to test
          do     #23,endsqrt
          mpy    -x0,x0,a                   ; square and negate the guess
          add    y,a                        ; compare to double precision input
          tge    x0,b                       ; update root if input >= guess
          tfr    x1,a                       ; get bit to test
          asr     a                         ; shift to next bit to test
          add    b,a  a,x1                  ; form new guess
          move   a,x0                       ; save new guess
endsqrt 
          page
;---------------------------------------------------------------------
;   Log base 2 conversion routine.  Converts the positive magnitude     
;   data to (log base 2)/32.
;   See 56001 Manual for detail reference
;------------------------------------------------------------------------
; log of zero fixup...uses -1 for the log of zero
;------------------------------------------------------------------------
          move      #>$000008,a
          cmp       a,b      #-0.6228,a     ;for the log of zero use -120 dB
          jle       <loga                   ;if argument is zero, force to max neg
          move      m3,r7                   ;m3 = -1 ($FFFF)
          rep       #23                     ;normalize to between .5 and 1.0
          norm      r7,b                    ;shift left and decrement r7 if needed
          move      #pcoef,r0               ;point to poly. coefs. for log2
          move      b,x0                    ;put normalized number in x0
          mpyr      x0,x0,a       y:(r0)+,y0   ;x**2, get a1
          mpy       x0,y0,a  a,x1 y:(r0)+,y0   ;a1*x, mv x**2, get a2
          mac       x1,y0,a       y:(r0)+,y0   ;a2* x**2, get a0
          add       y0,a                    ;add in a0
          asl       a                       ;multiply by 4
          asl       a
                    
          asl       a                       ;shift out sign bit
          move      r7,a2                   ;new sign = characteristic
          rep       #6                      ;divide by 32, create sign bit
          asr       a
loga      rnd       a                       ;round result
          move      a,y:(r4)+               ;update display table
Goer_out                                    ;***** END OF DO LOOP!!! *****
          rts                               ;return from Goertzel subroutine

;------------------------------------------------------------------------
;  static data storage
;------------------------------------------------------------------------
     IF     BOOTMODE==1                     ;*** if booting from ROM ***
WIN_LOC   set    *-GO                       ;convince assembler to compute
WIN_DAT                                     ;...get all tables together
       nolist                               ;...at the end of the code in ROM
       include   'window1'                  ;NOTE: the order IS important
       include   'cosine'
       include   'sine'
pcoef  dc    .9981958,-.3372223,-.6626105   ;start of polynomial coefficent table
          list
Tab_Len   equ    *-WIN_DAT                  ;length of tables
          
     ELSE                                   ;*** if testing in RAM ***

     nolist
	org	y:WIN_TABL
	include	'window1'
	org	y:COS_TABL
	include	'cosine'
	org	y:SIN_TABL
	include	'sine'
pcoef  dc    .9981958,-.3372223,-.6626105   ;start of polynomial coefficent table
     list
     ENDIF

          end    SPEC