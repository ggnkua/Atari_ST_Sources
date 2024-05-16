;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; 1024-Point, 3.39ms Non-In-Place FFT. 
; 
; Last Update 04 Feb 87   Version 1.0
;
fftr2e  macro   data,coef
fftr2e  ident   1,0
;
; 1024 Point Complex Fast Fourier Transform Routine
;
; This routine performs a 1024 point complex FFT on external data
; using the Radix 2, Decimation in Time, Cooley-Tukey FFT algorithm.
;
;    Complex input and output data
;        Real data in X memory
;        Imaginary data in Y memory
;    Normally ordered input data
;    Bit reversed output data
;       Coefficient lookup table
;        -Cosine values in X memory
;        -Sine values in Y memory
;
; Macro Call - fftr2e   data,coef
;
;       data       start of external data buffer
;       coef       start of sine/cosine table
;
; Radix 2, Decimation In Time Cooley-Tukey FFT algorithm
;             ___________
;            |           | 
; ar,ai ---->|  Radix 2  |----> ar',ai'
; br,bi ---->| Butterfly |----> br',bi'
;            |___________|
;                  ^
;                  |
;                wr,wi
;
;       ar' = ar + wr*br - wi*bi
;       ai' = ai + wi*br + wr*bi
;       br' = ar - wr*br + wi*bi = 2*ar - ar'
;       bi' = ai - wi*br - wr*bi = 2*ai - ai'
;
; Address pointers are organized as follows:
;
;  r0 = ar,ai input pointer     n0 = group offset       m0 = modulo (points)
;  r1 = br,bi input pointer     n1 = group offset       m1 = modulo (points)
;  r2 = ext. data base address  n2 = groups per pass    m2 = 256 pt fft counter
;  r3 = coef. offset each pass  n3 = coefficient base addr.     m3 = linear
;  r4 = ar',ai' output pointer  n4 = group offset       m4 = modulo (points)
;  r5 = br',bi' output pointer  n5 = group offset       m5 = modulo (points)
;  r6 = wr,wi input pointer     n6 = coef. offset       m6 = bit reversed
;  r7 = not used (*)            n7 = not used (*)       m7 = not used (*)
;
;       * - r7, n7 and m7 are typically reserved for a user stack pointer.
;
; Alters Data ALU Registers
;       x1      x0      y1      y0
;       a2      a1      a0      a
;       b2      b1      b0      b
;
; Alters Address Registers
;       r0      n0      m0
;       r1      n1      m1
;       r2      n2      m2
;       r3      n3      m3
;       r4      n4      m4
;       r5      n5      m5
;       r6      n6      m6
;
; Alters Program Control Registers
;       pc      sr
;
; Uses 8 locations on System Stack                                           
;
; Latest Revision - 4-Feb-87
;
_points equ     1024            ;number of FFT points
_intdata        equ     0       ;address of internal data workspace
        move    #data,r2        ;initialize input pointers
        move    r2,r0
        move    #_points/4,n0   ;initialize butterflies per group
        move    n0,n4           ;initialize pointer offsets
        move    n0,n6           ;initialize coefficient offset
        move    #coef,n3        ;initialize coefficient base address
        move    #_points-1,m0   ;initialize address modifiers
        move    m0,m1           ;for modulo(points) addressing
        move    m0,m4
        move    m0,m5
        move    #-1,m3          ;linear addressing for coefficient base offset
        move    #0,m2           ;initialize 256 point fft counter
        move    m2,m6           ;initialize coefficient address modifier
                                ;for reverse carry (bit reversed) addressing
;
; Do first and second Radix 2 FFT passes
;
        move            x:(r0)+n0,x0
        tfr     x0,a    x:(r0)+n0,y1

        do      n0,_twopass
        tfr     y1,b    x:(r0)+n0,y0
        add     y0,a    x:(r0),x1                       ;ar+cr
        add     x1,b    r0,r4                           ;br+dr
        add     a,b     (r0)+n0                         ;ar'=(ar+cr)+(br+dr)
        subl    b,a     b,x:(r0)+n0                     ;br'=(ar+cr)-(br+dr)
        tfr     x0,a    a,x0            y:(r0),b
        sub     y0,a                    y:(r4)+n4,y0    ;ar-cr
        sub     y0,b    x0,x:(r0)                       ;bi-di
        add     a,b                     y:(r0)+n0,x0    ;cr'=(ar-cr)+(bi-di)
        subl    b,a     b,x:(r0)                        ;dr'=(ar-cr)-(bi-di)
        tfr     x0,a    a,x0            y:(r4),b
        add     y0,a                    y:(r0)+n0,y0    ;bi+di
        add     y0,b    x0,x:(r0)+n0                    ;ai+ci
        add     b,a                     y:(r0)+,x0      ;ai'=(ai+ci)+(bi+di)
        subl    a,b                     a,y:(r4)+n4     ;bi'=(ai+ci)-(bi+di)
        tfr     x0,a                    b,y:(r4)+n4
        sub     y0,a    x1,b                            ;ai-ci
        sub     y1,b    x:(r0)+n0,x0                    ;dr-br
        add     a,b     x:(r0)+n0,y1                    ;ci'=(ai-ci)+(dr-br)
        subl    b,a                     b,y:(r4)+n4     ;di'=(ai-ci)-(dr-br)
        tfr     x0,a                    a,y:(r4)+
_twopass
;                                                                   
; Do remaining 8 FFT passes as four 256 point Radix 2 FFT's using internal data
; and external coefficients.
;
; Each 256 point Radix 2 FFT consists of 8 passes.  The first pass uses external
; input data and internal output data to move the data on-chip.  Intermediate
; passes use internal input data and internal output data to keep the data
; on-chip.  The last pass uses internal input data and external output data
; to move the data off-chip.
;
        do      #4,_end_fft     ;do 256 point fft four times
        move    r2,r0           ;get external data input address for first pass
        move    m2,r3           ;update coefficient offset
        move    #256/2,n0       ;initialize butterflies per group
        move    #1,n2           ;initialize groups per pass

        do      #7,_end_pass    ;do first 7 passes out of 8
        move    #_intdata,r4    ;initialize A output pointer
        move    n0,n1           ;initialize pointer offsets
        move    n0,n4
        move    n0,n5
        lua     (r0)+n0,r1      ;initialize B input pointer
        lua     (r4)+n4,r5      ;initialize B output pointer
        lua     (r3)+n3,r6      ;initialize W input pointer
        move    (r5)-

        do      n2,_end_grp
        move    x:(r1),x1       y:(r6),y0       ;lookup -sine value
        move    x:(r5),a        y:(r0),b
        move    x:(r6)+n6,x0            ;lookup -cosine value

                                                 
        do      n0,_end_bfy     ;Radix 2 DIT butterfly kernel with constant
        mac     x1,y0,b                         y:(r1)+,y1   ;twiddle factor
        macr    -x0,y1,b        a,x:(r5)+       y:(r0),a
        subl    b,a             x:(r0),b        b,y:(r4)
        mac     -x1,x0,b        x:(r0)+,a       a,y:(r5)
        macr    -y1,y0,b        x:(r1),x1
        subl    b,a             b,x:(r4)+       y:(r0),b
_end_bfy
        move    a,x:(r5)+n5     y:(r1)+n1,y1    ;dummy load of x1 and y1
        move    x:(r0)+n0,x1    y:(r4)+n4,y1
_end_grp
        move    n0,b1
        lsr     b       n2,a1   ;divide butterflies per group by two
        lsl     a       b1,n0   ;multiply groups per pass by two
        move            r3,b1
        lsr     b       a1,n2   ;divide coefficient offset by two
        move            b1,r3
        move            #_intdata,r0    ;intermediate passes use internal input data
_end_pass
;        
; Do last FFT pass and move output data off-chip to external data memory.
;
        move    n1,n0           ;correct pointer offset for last pass
        move    r2,r4           ;initialize A output pointer
        lua     (r0)+,r1        ;initialize B input pointer
        lua     (r4)-n4,r5      ;initialize B output pointer
        lua     (r3)+n3,r6      ;initialize W input pointer
        move    (r5)+
        move    x:(r1),x1       y:(r6),y0
        move    x:(r5),a        y:(r0),b

        do      n2,_lastpass    ;Radix 2 butterfly kernel with one butterfly
                                ;per group and changing twiddle factor
        mac     x1,y0,b         x:(r6)+n6,x0    y:(r1)+n1,y1
        macr    -x0,y1,b        a,x:(r5)+n5     y:(r0),a
        subl    b,a             x:(r0),b        b,y:(r4)
        mac     -x1,x0,b        x:(r0)+n0,a     a,y:(r5)
        macr    -y1,y0,b        x:(r1),x1       y:(r6),y0
        subl    b,a             b,x:(r4)+n4     y:(r0),b
_lastpass
        move    a,x:(r5)+n5
        move    m2,r6           ;get fft counter
        move    n6,n2           ;get fft data input offset
        move    m3,m2           ;external data pointer uses linear arithmetic
        move    (r6)+n6         ;increment fft counter (bit reversed)
        move    (r2)+n2         ;point to next 256 point fft input data
        move    r6,m2           ;save fft counter
_end_fft
        endm
