;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; Discrete Hilbert Transform in the frequency domain
; 
; Last Update 18 Aug 88   Version 1.0
;
dhit macro points,data
dhit ident 1,0
     opt nomd,mex
;
;Compute Hilbert transform in the frequency domain. This routine
;starts with "points" frequency domain data, located at "data", with real part
;in X-memory and imaginary part in Y-memory. The program gives the first 
;half of the frequency data a phase shift of -90 degrees ("positive 
;frequency" part) and the second half of the data a phase shift of +90
;degrees ("negative frequency" part). The magnitude of the complex
;data remains unchanged. The output data points are located at the same
;location.
;
     move #data,r0           ;point to the positive-frequency data (real part)
     move #-1,m0              ;linear addressing for 
     move m0,m1               ;all pointers
     move m0,m4
     move m0,m5
     move #data+points/2,r1  ;point to the negative-frequency data (real part)
     move r0,r4               ;point to the positive-frequency data (imaginary part)
     move r1,r5               ;point to the negative-frequency data (imaginary part)

     do #points/2,endloop      ;do for all frequency points

     move x:(r0),a  y:(r4),b            ;real -> a, imaginary -> b
     neg a                              ;real part becomes - imaginary part
     move      b,x:(r0)+ a,y:(r4)+      ;store real and imaginary parts
     move      x:(r1),a  y:(r5),b       ;get negative-frequency data
     neg  b                             ;imaginary part becomes - real part    
     move      b,x:(r5)+ a,y:(r1)+      ;store negative-frequency data
endloop
     endm

^Z