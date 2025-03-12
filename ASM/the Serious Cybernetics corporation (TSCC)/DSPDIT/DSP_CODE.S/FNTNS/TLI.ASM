;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; Linear Table Lookup/Interpolation Routine for Function Generation
; 
; Last Update 16 Apr 87   Version 1.1
;
;   This program provides a fixed-point implementation of a table
;   lookup/interpolation (of form given in TLI.HLP).
;
;       The example will generate a 255 point sine wave by
;       interpolating between the points of a 17 point sine wave.
;
        opt     cex,mex
        page    132,66,0,10

dataout equ     $fffe                   ; output file
deg     equ     3.141592654/180.0       ;conversion from radians to degrees

        org     x:$10
;
;       Function points Y(i)=f(X(i)): Sine wave of magnitude 1/2
;
bptbl                                   ;breakpoint table for function
        dc      @sin(0.0*deg)/2.0
        dc      @sin(22.5*deg)/2.0
        dc      @sin(45.0*deg)/2.0
        dc      @sin(67.5*deg)/2.0
        dc      @sin(90.0*deg)/2.0
        dc      @sin(112.5*deg)/2.0
        dc      @sin(135.0*deg)/2.0
        dc      @sin(157.5*deg)/2.0
        dc      @sin(180.0*deg)/2.0
        dc      @sin(202.5*deg)/2.0
        dc      @sin(225.5*deg)/2.0
        dc      @sin(247.5*deg)/2.0
        dc      @sin(270.0*deg)/2.0
        dc      @sin(292.5*deg)/2.0
        dc      @sin(315.0*deg)/2.0
        dc      @sin(337.5*deg)/2.0
        dc      @sin(360.0*deg)/2.0

n       equ     4                       ;number of bits in X(i)

        org     p:$100
;
;       Start of program
;
        move    #-1.0,a                 ;initial angle =0 degrees
;       note: A will vary from -1.0 to 1.0 to represent an angle
;             varying from 0.0 to 360.0
        move    a,x:0                   ;save it
        do      #255,_esine             ;do 255 steps


;
;       table lookup/interpolation routine
;
        clr     b  #$80,x0              ;mask for sign flip
        add     x0,a  #>bptbl,x0        ;flip sgn bit, point to fcn tbl
        do      #n,_es                  ;shift n bits into b
        lsl     a                       ;to become the index into the
        rol     b                       ;function breakpoint table
_es
        add     x0,b  #0,a2             ;add base to ptr, make A positive
        lsr     a  b1,r0                ;make A a fraction, move ptr
;                               This produces 2**(n-1) (X-X(i))
;                       Which is equal to (X-X(i))/(X(i+1)-X(i))
        move    a,x0                    ;move A for later mul
        move    x:(r0)+,b               ;get Y(i)
        move    x:(r0),a                ;get Y(i+1)
        sub     b,a                     ;find Y(i+1)-Y(i)
        move    a,y0                    ;move Y(i+1)-Y(i)
        macr    y0,x0,b         ;find Y(i)+(Y(i+1)-Y(i))*(X-X(i))/2**(n-1)
;
;       end of routine
;
        move    b,y:dataout             ;output data
        move    x:0,a                   ;get angle
        move    #$01,x0                 ;angle increment (fractional)
        add     x0,a                    ;increase angle
        move    a,x:0                   ;save output
_esine
        end
