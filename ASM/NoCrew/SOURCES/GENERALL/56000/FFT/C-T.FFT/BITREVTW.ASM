bitrevtwd56  macro   POINTS,COEF
bitrevtwd56  ident   1,2
;
;       bitrevtwd -     macro to sort sine and cosine coefficient
;                       lookup tables in bit reverse order for 56156
;
;       POINTS  -       number of points (2 - 32768, power of 2)
;       COEF    -       base address of sine/cosine table
;                       negative cosine (Wr) and negative sine (Wi) in X memory
;
; Wei Chen
; July-28, 1992
;


        move    #COEF,r1         ;twiddle factor start address
        move    #0,m0            ;bit reverse address
        move    #POINTS/8,n0     ;sincosr use N/4 points data, offset for bit rev. is N/8      
        move    #POINTS/4-1,n2
        move    r1,r0            ;r1 ptr to normal order data 
        move    (r1)+            ;no swap on 1st data
        move    (r0)+n0          ;r0 ptr to bitrev 
        do      n2,_end_bit      ;does N/4-1 points swap
        move    r1,x0
        move    r0,b
        cmp     x0,b
        jgt     _swap
        move    (r1)+            ;no swap but update points
        move    (r0)+n0
        jmp     _nothing
_swap    
        move    r1,r5
        move    r0,r4
        move    x:(r1),x0 y:(r5),y0
        move    x:(r0),a  y:(r4),b
        move    x0,x:(r0)+n0 y0,y:(r4)
        move    a,x:(r1)+  b,y:(r5)
_nothing
        nop
_end_bit
        endm    ;end of bitrevtwd macro
