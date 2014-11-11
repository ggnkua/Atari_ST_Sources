FFTR2BF    macro    points,passes,data,twiddle,temp
;
; Radix 2 Decimation-in-Time In-Place Block Floating Point
; Fast Fourier Transform Macro
;
;    Version with 2 butterflies, scratch storage
;
;    Complex input and output data
;        Real data in X memory
;        Imaginary data in Y memory
;    Normally ordered input data
;    Bit reversed output data
;    Twiddle factors lookup table
;        Cosine value in X memory
;        -Sine value in Y memory
;
; Macro Call - FFTR2BF points,passes,data,twiddle
;
;       points     number of points (4-32768, power of 2)
;       passes     number of fft passes (log2 points)
;       data       start of data buffer
;       twiddle    start of sine/cosine table
;       temp       low address of four consecutive x:y scratch memory
;                  (should be internal memory for fast program operation)
;                  on output, x:(temp)+2 contains the number of bits scaled;
;                  x:(temp)+3 shows, in base-4, the number of bits scaled per
;                  each stage
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
;
;       r4      n4      m4
;       r5      n5      m5
;       r6      n6      m6
;       r7      n7      m7
;
; Alters Program Control Registers
;       pc      sr
;
; Uses 11 locations on System Stack
;
; Latest Revision - June 13, 1988
;
        move    #temp+2,r2      ;initialize temporary data storage pointer
        clr     a               ;initialize the number of bits scaled to zero
        move    a,x:(r2)+
        move    a,x:(r2)
        move    #1,n2           ;initialize groups per pass
        nop
        move    n2,y:(r2)       ;initialize stage overflow indicator
        move    #temp,r2        ;initialize temporary data storage pointer
        move    #points,n0      ;initialize butterflies per group
        move    #-1,m0          ;initialize address modifier for linear addressing
        move    #points/4,n6    ;initialize twiddle offset
        move    m0,m1           ;initialize address modifiers for linear addressing
        move    m0,m4
        move    m0,m5
        move    m0,m2
        move    m0,m3
        move    m0,m7
        move    #0,m6           ;initialize twiddle factor address modifier
                                ;  for reverse carry (bit reversed) addressing
;
; Perform all FFT passes with triple nested DO loop
;
        do      #passes,_end_pass
        move    n0,a1                           ;divide butterflies per group by two
        lsr     a       #data,r0                ;and initialize A input pointer
        move    a1,n0                           ;update butterflies per group
        move    r0,r4                           ;initialize A output pointer
        lua     (r0)+n0,r1                      ;initialize B input pointer
        move    n0,n1
        move    r1,r5                           ;initialize B output pointer
        move    n0,n4                           ;initialize pointer offsets
        move    n0,n5
        move    x:(r0),x0                       ;clear downshift flag
        movec   sr,x:(r0)
        bclr    #10,x:(r0)
        movec   x:(r0),sr
        move    x0,x:(r0)


        move    n2,r6                           ;get group count
        move    m0,m6                           ;set linear addressing
        move    y:(r0),b                        ;do t.f.=1 butterflies
        move    y:(r1),a
        sub     a,b             ab,l:(r2)+

        do      n0,_end_bf0
        addl    b,a     x:(r0)+,b       b,y:(r5)
        move            x:(r1)+,a       a,y:(r4)
        sub     a,b             ab,l:(r2)-
        addl    b,a     b,x:(r5)+       y:(r0),b
        move            a,x:(r4)+       y:(r1),a
        jls     _ov_bf0_go                      ;test for overflow--FORCE SHORT JUMP WHEN POSSIBLE
_ov_bf0_ret
        sub     a,b             ab,l:(r2)+
_end_bf0
        lua     (r2)-,r2

        lua     (r6)-,r6                        ;update pointers and test for no more groups
        lua     (r4)+n4,r4
        move    #0,m6                           ;set bit-reverse mode for t.f.
        move    r6,a
        move    r6,n7                           ;save group counter
        move    #twiddle,r6
        lua     (r0)+n0,r0
        lua     (r1)+n1,r1
        lua     (r6)+n6,r6
        tst     a       (r5)+n5
        jle     _sk_grp


        do      n7,_end_grp                     ;do the normal butterflies
        move    r2,r7                           ;set pointer to temp storage
        move    x:(r1),x1       y:(r6),y0       ;lookup -sine value
        move    x:(r6)+n6,x0    y:(r0),b        ;lookup cosine value

        mac     x1,y0,b         b,x:(r7)+       y:(r1)+,y1      ;Radix 2 DIT butterfly kernel
        do      n0,_end_bf2
        macr    x0,y1,b         x1,x:(r7)-      y:(r0),a
        subl    b,a             x:(r0),b        b,y:(r4)
        mac     x1,x0,b         x:(r1),x1       b,y:(r7)
        macr    -y1,y0,b        x:(r0)+,a       a,y:(r5)
        subl    b,a             b,x:(r4)+
        move                    a,x:(r5)+       y:(r0),b
        jls     _ov_bf2_go                      ;test for overflow --FORCE SHORT JUMP WHEN POSSIBLE
_ov_bf2_ret
        mac     x1,y0,b         b,x:(r7)+       y:(r1)+,y1
_end_bf2

        lua     (r1)-,r1
        lua     (r5)+n5,r5                      ;update data pointers
        lua     (r1)+n1,r1
        lua     (r0)+n0,r0
        lua     (r4)+n4,r4
_end_grp
_sk_grp
        move    n2,a1
        lsl     a                               ;multiply groups per pass by two
        move    a1,n2                           ;update groups per pass

        move    #temp+3,r2
        nop
        move    y:(r2),a1
        lsl     a
        lsl     a
        move    a1,y:(r2)
        move    #temp,r2
_end_pass

        move    x:(r0),x0                       ;clear downshift flag
        movec   sr,x:(r0)
        bclr    #10,x:(r0)
        movec   x:(r0),sr
        move    x0,x:(r0)
        jmp     _bsfft_end

;
;  OVERFLOW MANAGEMENT CODE
;

;
; overflow correction code, full butterfly
;
_ov_bf2_go
        lua     (r4)-,r7
        lua     (r5)-,r3
        movec   sr,y:(r7)                       ;reset limit flag
        bclr    #6,y:(r7)
        movec   y:(r7),sr


        jclr    #10,y:(r7),_bf2_ndov            ;double overflow, previous overflow

        jsr     _c_ov                           ;increment the scaling counter
        jsr     _d_sc                           ;scale all the data

        lua     (r5)-,r3
        move                    y1,a            ;scale down data element
        move    x:(r2)+,b       a,y1            ;recompute butterfly
        move            x:(r2)-,a
        move            a,x1
        mac     x1,y0,b
        macr    x0,y1,b         x:(r2),a
        subl    b,a             b,y:(r7)
        move                    y:(r2),b
        mac     x1,x0,b         a,y:(r3)
        macr    -y1,y0,b        y:(r2),a
        subl    b,a     b,x:(r7)
        move            a,x:(r3)

        move            x:(r1),x1               ;reload data for next butterfly
        move            y:(r0),b

        move    r2,r7                           ;recover temp storage pointer
        jmp     _ov_bf2_ret


_bf2_ndov
        bset    #10,y:(r7)                      ;set downshift
        movec   y:(r7),sr
        jsr     _c_ov                           ;increment the scaling counter

        move            x:(r2)+,b               ;recompute butterfly
        move            x:(r2)-,x1
        mac     x1,y0,b
        macr    x0,y1,b         x:(r2),a
        subl    b,a             b,y:(r7)
        move                    y:(r2),b
        mac     x1,x0,b         a,y:(r3)
        macr    -y1,y0,b        y:(r2),a
        subl    b,a     b,x:(r7)
        move            a,x:(r3)

        jlc     _bf2_sk_1                       ;double overflow, NO previous overflow
        movec   sr,y:(r7)                       ;reset limit bit
        bclr    #6,y:(r7)
        movec   y:(r7),sr
        jsr     _c_ov                           ;increment the scaling counter

        jsr     _d_sc                           ;scale all the data down by one bit

        lua     (r5)-,r3
        move            x:(r2)+,b               ;recompute butterfly
        move            x:(r2)-,x1
        mac     x1,y0,b
        macr    x0,y1,b         x:(r2),a
        asr     b
        asr     a
        subl    b,a             b,y:(r7)
        move                    y:(r2),b
        mac     x1,x0,b         a,y:(r3)
        macr    -y1,y0,b        y:(r2),a
        asr     b
        asr     a
        subl    b,a     b,x:(r7)
        move            a,x:(r3)

_bf2_sk_1
        jsr     _pb_sc                          ;scale previously completed butterflies

        move            x:(r1),x1               ;reload data for next butterfly
        move            y:(r0),b
        move    r2,r7                           ;recover temp storage pointer
        jmp     _ov_bf2_ret                     ;return to the butterfly loop

;
; butterfly 0 overflow correction code
;
_ov_bf0_go
        lua     (r4)-,r7                        ;recover data addresses
        lua     (r5)-,r3
        movec   sr,x:(r7)                       ;reset limit flag
        bclr    #6,x:(r7)
        bset    #10,x:(r7)                      ;set downshift
        movec   x:(r7),sr
        jsr     _c_ov                           ;increment the scaling counter

        move            l:(r2)+,ab              ;recompute butterfly
        sub     a,b
        addl    b,a             b,y:(r3)
        move                    a,y:(r7)
        move            l:(r2)-,ab
        sub     a,b
        addl    b,a     b,x:(r3)
        move            a,x:(r7)

        move    #data,r3                        ;set index registers
        move    n0,n3
        move    n0,n7
        lua     (r3)+n3,r7

        move    lc,a                            ;get butterfly loop count
        move    n0,b                            ;compute number of butterflies to scale
        sub     a,b
        jle     _bf0_b_sk

        lsl     b                               ;precorrect for shift
        do      b,_bf0_spb                      ;scale these butterflies
        move    x:(r3),a        y:(r7),b
        move    a,x:(r3)        b,y:(r7)
        move    y:(r3),a        x:(r7),b
        move    a,y:(r3)+       b,x:(r7)+
_bf0_spb

_bf0_b_sk
        move    y:(r0),b                        ;recover data for next butterfly
        move    y:(r1),a

        jmp     _ov_bf0_ret                     ;return to the butterfly loop

;
;  SUBROUTINES
;
;  _d_sc:  Subroutine to scale down the entire stage by a factor of
;          two in the event of a second overflow in a stage.
;
_d_sc
        move    #data,r3                        ;set pointer to start of data

        do      #points,_sc_lp
        move    l:(r3),ab
        move    ab,l:(r3)+
_sc_lp

        rts

;
; _pb_sc   Subroutine to scale previously completed butterflies
;
_pb_sc
        move    #2,r3                           ;set stack pointer to group loop counter
        movec   sp,a
        move    r3,b
        movec   sp,r3                           ;save stack pointer
        sub     b,a
        lsl     a
        movec   a,sp

        move    n2,a                            ;compute number of completed groups
        movec   ssl,b
        move    n2,a
        sub     b,a
        movec   r3,sp                           ;restore stack pointer
        move    #data,r3                        ;set index registers
        move    n0,n3
        move    n0,n7
        lua     (r3)+n3,r7

        jle     _pb_g_sk

        lsl     a                               ;precorrect loop count for shift
        do      a,_pb_glp                       ;scale down these groups
        do      n0,_pb_blp_1
        move    x:(r3),a        y:(r7),b
        move    a,x:(r3)        b,y:(r7)
        move    y:(r3),a        x:(r7),b
        move    a,y:(r3)+       b,x:(r7)+
_pb_blp_1
        lua     (r3)+n3,r3
        lua     (r7)+n7,r7
_pb_glp

_pb_g_sk
        move    lc,a                            ;get butterfly loop count
        move    n0,b                            ;compute number of butterflies to scale
        sub     a,b
        jle     _pb_b_sk

        lsl     b                               ;precorrect for shift
        do      b,_pb_blp_2                     ;scale these butterflies
        move    x:(r3),a        y:(r7),b
        move    a,x:(r3)        b,y:(r7)
        move    y:(r3),a        x:(r7),b
        move    a,y:(r3)+       b,x:(r7)+
_pb_blp_2

_pb_b_sk

        rts
;
;  _c_ov:  Subroutine to increment the number-of-bits-scaled counter
;
_c_ov
        move    #temp+2,r2              ;change pointer to (temp)+2
        nop
        move    r3,y:(r2)               ;save r3
        move    x:(r2),r3               ;increment number-of-bits-scaled
        nop
        lua     (r3)+,r3
        nop
        move    r3,x:(r2)               ;store number-of-bits-scaled
        move    y:(r2)+,r3              ;restore r3 and reset (temp) pointer
        move    l:(r2),ab
        add     b,a
        lsl     a
        move    a,x:(r2)
        move    #temp,r2
        rts

_bsfft_end
        endm^Z