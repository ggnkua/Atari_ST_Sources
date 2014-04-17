;
; This program, originally available on the Motorola DSP bulletin board,
; is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive, West, Austin, Texas  78735-8598.
;
        ident   1,1
        page    132,56,1,1

        opt     mex,nomd,cex
;
;       Discrete Cosine Transform (DCT)
;
;	V1.2
;	03 Oct 88
;
;       The DCT is implemented by using the method described in
;       "On the Computation of the Discrete Cosine Transform", IEEE
;       Transactions on Communications. Vol COM-26, No. 6, June 1978
;
;       The operation of this transform is as follows:
;           1.  Resort the original sequence.
;           2.  Perform an FFT on the modified sequence.
;           3.  Multiply the output of the FFT by a complex exponential
;               and take the real part.
;           4.  Perform a bit reversed sort to unscramble the result.
;
;       After the transform, the data needs to be scaled (according to
;       the previously cited reference):
;           g(0) = g(0)*1.414/N
;           g(k) = g(k)*2.0/N       k=1,2,...,N-1
;       This scaling is NOT performed by this program.  This type of scaling
;       is application dependent and some implementations may not require
;       the scaling.
;


        include 'sincos'
        include 'fftr2aa'

start   equ     $100            ;beginning of program in P memory
points  equ     16              ;number of points in dct
data    equ     0               ;address of data in Y memory
coef    equ     16              ;address of coefficients

        sincos  points,coef     ;generate twiddle factor for FFT.

;       Generate exponential table after twiddle factor table.
;
;       This generates the scale factor of EXP(-j*pi*k/(2*N)).
;       The real part is in Y memory and the imaginary part is
;       in X memory.  Note that the negative of the part in Y memory
;       is actually stored so that a -1 (exactly) can be represented
;       with the fractional arithmetic.  This negative sign is
;       compensated when the actual rotation is performed.
;
rot     equ     pi/@cvf(2*points)

        org     x:
exptbl
count   set     0
        dup     points
        dc      -@sin(@cvf(count)*rot)
count   set     count+1
        endm

        org     y:
count   set     0
        dup     points
        dc      -@cos(@cvf(count)*rot)
count   set     count+1
        endm



        org     p:start
;
;       Do inital sort. The input data is in Y, the sorted data goes to X.
;       This forms a new sequence in X memory from the sequence in Y memory
;       according to the definition:
;               x(k)=y(2k)
;               x(N-1-K)=x(2k+1)      k=0,1,...,N/2-1
;
        move    #$ffff,m0               ;set linear
        move    m0,m4                   ;ditto
        move    #data,r0                ;point to data
        move    #2,n0                   ;jump by even numbers
        move    r0,r4                   ;copy data pointer
        move    y:(r0)+n0,a             ;get first point
        rep     #points/2               ;sort even points
        move    y:(r0)+n0,a  a,x:(r4)+
        move    #data+1,r0              ;point to odds
        move    #data+points-1,r4       ;odds output
        move    y:(r0)+n0,a             ;get first odd
        rep     #points/2               ;sort odd points
        move    y:(r0)+n0,a  a,x:(r4)-
        clr     a       #data,r0        ;get a zero, point r0 to data
        rep     #points                 ;clear out original data
        move    a,y:(r0)+

;
;       Do an FFT on the new sequence
;
        fftr2aa  points,data,coef        ;do FFT

;
;       Multiply the output by a complex exponential and take the
;       real part.  dct=re[ (a+jb)*(c+jd)] = a*c-b*d where a+jb is the
;       output of the FFT and c+jd is the rotation factor. Note that
;       the data is still in bit reversed order but the rotation
;       table is in sequential order.  Thus, the data is accessed with
;       bit reversed addressing but the rotation table is addressed
;       with linear addressing.
;
        move    #exptbl,r0              ;point to exponential table
        move    #$ffff,m0               ;linear addressing

        move    #data,r4                ;point to output of fft
        move    r4,r5                   ;copy data pointer
        move    #0,m4                   ;bit reversed addressing
        move    m4,m5
        move    #points/2,n4
        move    n4,n5

        move    x:(r4),x0  y:(r0),y0                    ;get a,-c
        do      #points,_gf                             ;do all points
        mpy     -x0,y0,a  x:(r0)+,x1   y:(r4)+n4,y1     ;-a*c, get d,b
        macr    -x1,y1,a  x:(r4),x0    y:(r0),y0        ;-b*d, get a,c
        move              a,x:(r5)+n5                   ;save dct
_gf

;
;       Bit reverse the output. The rotated and bit reversed data from X
;       memory is transfered to Y memory and unscrambled.  The resulting
;       DCT is in Y memory starting at DATA with length POINTS.
;
        move    #data,r0                ;point to data
        move    #points/2,n0            ;number of points/2
        move    #0,m0                   ;set reverse carry

        move    r0,r4                   ;copy pointer
        move    #$ffff,m4               ;set linear

        move    x:(r0)+n0,a             ;do preload
        rep     #points                 ;unscramble
        move    x:(r0)+n0,a   a,y:(r4)+

        end
^Z
